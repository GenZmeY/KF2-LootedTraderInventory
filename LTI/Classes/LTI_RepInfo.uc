class LTI_RepInfo extends ReplicationInfo;

const CAPACITY = 64; // max: 128

const Trader       = class'Trader';
const LocalMessage = class'LTI_LocalMessage';

struct ReplicationStruct
{
	var int Size;
	var int Transfered;

	var class<KFWeaponDefinition> Items[CAPACITY];
	var int Length;
};

var public  bool PendingSync;

var private LTI LTI;
var private E_LogLevel LogLevel;

var private KFPlayerController      KFPC;
var private KFGFxWidget_PartyInGame PartyInGameWidget;
var private GFxObject               Notification;

var private String NotificationHeaderText;
var private String NotificationLeftText;
var private String NotificationRightText;
var private int    NotificationPercent;

var private int    WaitingGRI;
var private int    WaitingGRILimit;

var private ReplicationStruct                 RepData;
var private Array<class<KFWeaponDefinition> > RepArray;

replication
{
	if (bNetInitial && Role == ROLE_Authority)
		LogLevel;
}

public simulated function bool SafeDestroy()
{
	`Log_Trace();

	return (bPendingDelete || bDeleteMe || Destroy());
}

public function PrepareSync(LTI _LTI, E_LogLevel _LogLevel)
{
	`Log_Trace();

	LTI                 = _LTI;
	LogLevel            = _LogLevel;
}

public function Replicate(const out Array<class<KFWeaponDefinition> > WeapDefs)
{
	`Log_Trace();

	RepArray = WeapDefs;
	RepData.Size = RepArray.Length;

	if (WorldInfo.NetMode == NM_StandAlone)
	{
		Progress(RepArray.Length, RepArray.Length);
		return;
	}

	Sync();
}

private reliable server function Sync()
{
	local int LocalIndex;
	local int GlobalIndex;

	`Log_Trace();

	LocalIndex = 0;
	GlobalIndex = RepData.Transfered;

	while (LocalIndex < CAPACITY && GlobalIndex < RepData.Size)
	{
		RepData.Items[LocalIndex++] = RepArray[GlobalIndex++];
	}

	if (RepData.Transfered == GlobalIndex) return; // Finished

	RepData.Transfered = GlobalIndex;
	RepData.Length = LocalIndex;

	Send(RepData);

	Progress(RepData.Transfered, RepData.Size);
}

private reliable client function Send(ReplicationStruct RD)
{
	local int LocalIndex;

	`Log_Trace();

	for (LocalIndex = 0; LocalIndex < RD.Length; LocalIndex++)
	{
		RepArray.AddItem(RD.Items[LocalIndex]);
	}

	Progress(RD.Transfered, RD.Size);

	Sync();
}

private simulated function Progress(int Value, int Size)
{
	`Log_Trace();

	`Log_Debug("Replicated:" @ Value @ "/" @ Size);

	if (ROLE < ROLE_Authority)
	{
		NotifyProgress(Value, Size);
		if (Value >= Size) Finished();
	}
}

private simulated function Finished()
{
	local KFGameReplicationInfo KFGRI;

	`Log_Trace();

	if (WorldInfo.GRI == None && WaitingGRI++ < WaitingGRILimit)
	{
		`Log_Debug("Finished: Waiting GRI" @ WaitingGRI);
		NotifyWaitingGRI();
		SetTimer(1.0f, false, nameof(Finished));
		return;
	}

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if (KFGRI != None)
	{
		`Log_Debug("Finished: Trader.static.OverwriteTraderItems");
		Trader.static.OverwriteTraderItems(KFGRI, RepArray, LogLevel);
		`Log_Info("Trader items successfully synchronized!");
	}
	else
	{
		`Log_Error("Incompatible Replication info:" @ String(WorldInfo.GRI));
		NotifyIncompatibleGRI();
	}

	ShowReadyButton();
	ClientCleanup();
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

	ClearTimer(nameof(KeepNotification));

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

private simulated function KeepNotification()
{
	HideReadyButton();
	UpdateNotification(
		NotificationHeaderText,
		NotificationLeftText,
		NotificationRightText,
		NotificationPercent);
}

private simulated function ClientCleanup()
{
	ServerCleanup();
	SafeDestroy();
}

private reliable server function ServerCleanup()
{
	`Log_Trace();

	`Log_Debug("Cleanup");
	if (!LTI.DestroyRepInfo(GetKFPC()))
	{
		`Log_Debug("Cleanup (forced)");
		SafeDestroy();
	}
}

private simulated function NotifyWaitingGRI()
{
	if (!IsTimerActive(nameof(KeepNotification)))
	{
		SetTimer(0.1f, true, nameof(KeepNotification));
	}

	NotificationHeaderText = LocalMessage.static.GetLocalizedString(LogLevel, LTI_WaitingGRI);
	NotificationLeftText   = String(WaitingGRI) $ LocalMessage.static.GetLocalizedString(LogLevel, LTI_SecondsShort);
	NotificationRightText  = LocalMessage.static.GetLocalizedString(LogLevel, LTI_PleaseWait);
	NotificationPercent    = 0;
	KeepNotification();
}

private simulated function NotifyProgress(int Value, int Size)
{
	if (!IsTimerActive(nameof(KeepNotification)))
	{
		SetTimer(0.1f, true, nameof(KeepNotification));
	}

	NotificationHeaderText  = LocalMessage.static.GetLocalizedString(LogLevel, LTI_SyncItems);
	NotificationLeftText    = Value @ "/" @ Size;
	NotificationRightText   = LocalMessage.static.GetLocalizedString(LogLevel, LTI_PleaseWait);
	NotificationPercent     = (float(Value) / float(Size)) * 100;
	KeepNotification();
}

private simulated function NotifyIncompatibleGRI()
{
	WriteToChatLocalized(
		LTI_IncompatibleGRI,
		class'KFLocalMessage'.default.InteractionColor,
		String(WorldInfo.GRI.class));
	WriteToChatLocalized(
		LTI_IncompatibleGRIWarning,
		class'KFLocalMessage'.default.InteractionColor);
}

defaultproperties
{
	bAlwaysRelevant               = false
	bOnlyRelevantToOwner          = true
	bSkipActorPropertyReplication = false

	PendingSync = false

	NotificationPercent    = 0
	WaitingGRI             = 0
	WaitingGRILimit        = 30
}
