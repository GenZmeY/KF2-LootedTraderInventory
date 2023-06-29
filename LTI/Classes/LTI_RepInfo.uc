class LTI_RepInfo extends ReplicationInfo;

const Trader       = class'Trader';
const LocalMessage = class'LTI_LocalMessage';

var public  bool PendingSync;

var private LTI LTI;
var private E_LogLevel LogLevel;
var private Array<class<KFWeaponDefinition> > RemoveItems;
var private bool ReplaceMode;
var private bool RemoveHRG;
var private bool RemoveDLC;

var private int  Recieved;
var private int  SyncSize;

var private KFPlayerController      KFPC;
var private KFGFxWidget_PartyInGame PartyInGameWidget;
var private GFxObject               Notification;

var private String NotificationHeaderText;
var private String NotificationLeftText;
var private String NotificationRightText;
var private int    NotificationPercent;

var private int    WaitingGRI;
var private int    WaitingGRILimit;

replication
{
	if (bNetInitial && Role == ROLE_Authority)
		LogLevel, ReplaceMode, RemoveHRG, RemoveDLC, SyncSize;
}

public simulated function bool SafeDestroy()
{
	`Log_Trace();

	return (bPendingDelete || bDeleteMe || Destroy());
}

public function PrepareSync(
	LTI _LTI,
	E_LogLevel _LogLevel,
	Array<class<KFWeaponDefinition> > _RemoveItems,
	bool _ReplaceMode,
	bool _RemoveHRG,
	bool _RemoveDLC)
{
	`Log_Trace();

	LTI                 = _LTI;
	LogLevel            = _LogLevel;
	RemoveItems         = _RemoveItems;
	ReplaceMode         = _ReplaceMode;
	RemoveHRG           = _RemoveHRG;
	RemoveDLC           = _RemoveDLC;
	SyncSize            = RemoveItems.Length;
}

private simulated function KFPlayerController GetKFPC()
{
	`Log_Trace();

	if (KFPC != None) return KFPC;

	KFPC = KFPlayerController(Owner);

	if (KFPC == None && ROLE < ROLE_Authority)
	{
		KFPC = KFPlayerController(GetALocalPlayerController());
	}

	return KFPC;
}

public reliable client function WriteToChatLocalized(
	E_LTI_LocalMessageType LMT,
	optional String HexColor,
	optional String String1,
	optional String String2,
	optional String String3)
{
	`Log_Trace();

	WriteToChat(LocalMessage.static.GetLocalizedString(LogLevel, LMT, String1, String2, String3), HexColor);
}

public reliable client function WriteToChat(String Message, optional String HexColor)
{
	local KFGFxHudWrapper HUD;

	`Log_Trace();

	if (GetKFPC() == None) return;

	if (KFPC.MyGFxManager.PartyWidget != None && KFPC.MyGFxManager.PartyWidget.PartyChatWidget != None)
	{
		KFPC.MyGFxManager.PartyWidget.PartyChatWidget.SetVisible(true);
		KFPC.MyGFxManager.PartyWidget.PartyChatWidget.AddChatMessage(Message, HexColor);
	}

	HUD = KFGFxHudWrapper(KFPC.myHUD);
	if (HUD != None && HUD.HUDMovie != None && HUD.HUDMovie.HudChatBox != None)
	{
		HUD.HUDMovie.HudChatBox.AddChatMessage(Message, HexColor);
	}
}

private simulated function SetPartyInGameWidget()
{
	`Log_Trace();

	if (GetKFPC() == None) return;

	if (KFPC.MyGFxManager == None) return;
	if (KFPC.MyGFxManager.PartyWidget == None) return;

	PartyInGameWidget = KFGFxWidget_PartyInGame(KFPC.MyGFxManager.PartyWidget);
	Notification = PartyInGameWidget.Notification;
}

private simulated function bool CheckPartyInGameWidget()
{
	`Log_Trace();

	if (PartyInGameWidget == None)
	{
		SetPartyInGameWidget();
	}

	return (PartyInGameWidget != None);
}

private simulated function HideReadyButton()
{
	`Log_Trace();

	if (CheckPartyInGameWidget())
	{
		PartyInGameWidget.SetReadyButtonVisibility(false);
	}
}

private simulated function ShowReadyButton()
{
	`Log_Trace();

	if (CheckPartyInGameWidget())
	{
		Notification.SetVisible(false);
		PartyInGameWidget.SetReadyButtonVisibility(true);
		PartyInGameWidget.UpdateReadyButtonText();
		PartyInGameWidget.UpdateReadyButtonVisibility();
	}
}

private simulated function UpdateNotification(String Title, String Left, String Right, int Percent)
{
	`Log_Trace();

	if (CheckPartyInGameWidget() && Notification != None)
	{
		Notification.SetString("itemName", Title);
		Notification.SetFloat("percent", Percent);
		Notification.SetInt("queue", 0);
		Notification.SetString("downLoading", Left);
		Notification.SetString("remaining", Right);
		Notification.SetObject("notificationInfo", Notification);
		Notification.SetVisible(true);
	}
}

private reliable client function ClientSync(class<KFWeaponDefinition> WeapDef)
{
	`Log_Trace();

	if (WeapDef == None)
	{
		`Log_Fatal("WeapDef is:" @ WeapDef);
		Cleanup();
		ConsoleCommand("Disconnect");
		SafeDestroy();
		return;
	}

	if (!IsTimerActive(nameof(KeepNotification)))
	{
		SetTimer(0.1f, true, nameof(KeepNotification));
	}

	RemoveItems.AddItem(WeapDef);

	Recieved = RemoveItems.Length;

	NotificationHeaderText  = "-" @ WeapDef.static.GetItemName();
	NotificationLeftText    = LocalMessage.static.GetLocalizedString(LogLevel, LTI_SyncItems);
	NotificationRightText   = Recieved @ "/" @ SyncSize;
	if (SyncSize != 0)
	{
		NotificationPercent = (float(Recieved) / float(SyncSize)) * 100;
	}

	`Log_Debug("ClientSync: -" @ String(WeapDef) @ NotificationRightText);

	ServerSync();
}

private simulated function KeepNotification()
{
	HideReadyButton();
	UpdateNotification(
		NotificationHeaderText,
		NotificationLeftText,
		NotificationRightText,
		NotificationPercent);
}

private simulated reliable client function ClientSyncFinished()
{
	local KFGameReplicationInfo KFGRI;

	`Log_Trace();

	if (WorldInfo.GRI == None && WaitingGRI++ < WaitingGRILimit)
	{
		`Log_Debug("ClientSyncFinished: Waiting GRI" @ WaitingGRI);
		NotificationHeaderText = LocalMessage.static.GetLocalizedString(LogLevel, LTI_WaitingGRI);
		NotificationLeftText   = String(WaitingGRI) $ LocalMessage.static.GetLocalizedString(LogLevel, LTI_SecondsShort);
		NotificationRightText  = "";
		NotificationPercent    = 0;
		SetTimer(1.0f, false, nameof(ClientSyncFinished));
		return;
	}

	NotificationHeaderText = "";
	NotificationLeftText   = "";
	NotificationRightText  = "";
	NotificationPercent    = 0;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if (KFGRI != None)
	{
		`Log_Debug("ClientSyncFinished: Trader.static.ModifyTrader");
		Trader.static.ModifyTrader(KFGRI, RemoveItems, ReplaceMode, RemoveHRG, RemoveDLC, LogLevel);
	}
	else
	{
		`Log_Error("Incompatible Replication info:" @ String(WorldInfo.GRI));
		WriteToChatLocalized(
			LTI_IncompatibleGRI,
			class'KFLocalMessage'.default.InteractionColor,
			WorldInfo.GRI == None ? "None" : String(WorldInfo.GRI.class));
		WriteToChatLocalized(
			LTI_IncompatibleGRIWarning,
			class'KFLocalMessage'.default.InteractionColor);
	}

	ClearTimer(nameof(KeepNotification));
	ShowReadyButton();

	Cleanup();
	SafeDestroy();
}

private reliable server function Cleanup()
{
	`Log_Trace();

	`Log_Debug("Cleanup");
	if (!LTI.DestroyRepInfo(Controller(Owner)))
	{
		`Log_Debug("Cleanup (forced)");
		SafeDestroy();
	}
}

public reliable server function ServerSync()
{
	`Log_Trace();

	PendingSync = false;

	if (bPendingDelete || bDeleteMe) return;

	if (SyncSize <= Recieved || WorldInfo.NetMode == NM_StandAlone)
	{
		`Log_Debug("ServerSync: Finished");
		ClientSyncFinished();
	}
	else
	{
		if (Recieved < RemoveItems.Length)
		{
			`Log_Debug("ServerSync[-]:" @ (Recieved + 1) @ "/" @ SyncSize @ RemoveItems[Recieved]);
			ClientSync(RemoveItems[Recieved++]);
		}
	}
}

defaultproperties
{
	bAlwaysRelevant               = false
	bOnlyRelevantToOwner          = true
	bSkipActorPropertyReplication = false

	PendingSync = false
	Recieved    = 0

	NotificationPercent    = 0
	WaitingGRI             = 0
	WaitingGRILimit        = 15
}
