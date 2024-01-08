class LTI_LocalMessage extends Object
	abstract;

var const             String SyncItemsDefault;
var private localized String SyncItems;

var const             String WaitingGRIDefault;
var private localized String WaitingGRI;

var const             String IncompatibleGRIDefault;
var private localized String IncompatibleGRI;

var const             String IncompatibleGRIWarningDefault;
var private localized String IncompatibleGRIWarning;

var const             String NoneGRIDefault;
var private localized String NoneGRI;

var const             String NoneGRIWarningDefault;
var private localized String NoneGRIWarning;

var const             String SecondsShortDefault;
var private localized String SecondsShort;

var const             String PleaseWaitDefault;
var private localized String PleaseWait;

enum E_LTI_LocalMessageType
{
	LTI_SyncItems,
	LTI_WaitingGRI,
	LTI_IncompatibleGRI,
	LTI_IncompatibleGRIWarning,
	LTI_NoneGRI,
	LTI_NoneGRIWarning,
	LTI_SecondsShort,
	LTI_PleaseWait
};

public static function String GetLocalizedString(
	E_LogLevel LogLevel,
	E_LTI_LocalMessageType LMT,
	optional String String1,
	optional String String2,
	optional String String3)
{
	`Log_TraceStatic();

	switch (LMT)
	{
		case LTI_SyncItems:
			return (default.SyncItems != "" ? default.SyncItems : default.SyncItemsDefault);

		case LTI_WaitingGRI:
			return (default.WaitingGRI != "" ? default.WaitingGRI : default.WaitingGRIDefault);

		case LTI_IncompatibleGRI:
			return (default.IncompatibleGRI != "" ? default.IncompatibleGRI : default.IncompatibleGRIDefault) @ String1;

		case LTI_IncompatibleGRIWarning:
			return (default.IncompatibleGRIWarning != "" ? default.IncompatibleGRIWarning : default.IncompatibleGRIWarningDefault);

		case LTI_NoneGRI:
			return (default.NoneGRI != "" ? default.NoneGRI : default.NoneGRIDefault);

		case LTI_NoneGRIWarning:
			return (default.NoneGRIWarning != "" ? default.NoneGRIWarning : default.NoneGRIWarningDefault);

		case LTI_SecondsShort:
			return (default.SecondsShort != "" ? default.SecondsShort : default.SecondsShortDefault);

		case LTI_PleaseWait:
			return (default.PleaseWait != "" ? default.PleaseWait : default.PleaseWaitDefault);
	}

	return "";
}

defaultproperties
{
	SyncItemsDefault              = "Sync items:"
	WaitingGRIDefault             = "Waiting GRI..."
	IncompatibleGRIDefault        = "Incompatible GRI:"
	IncompatibleGRIWarningDefault = "You can enter the game, but the trader may not work correctly.";
	NoneGRIDefault                = "GRI is not initialized!"
	NoneGRIWarningDefault         = "It is recommended to reconnect. If you enter the game right now, the trader may not work correctly.";
	SecondsShortDefault           = "s"
	PleaseWaitDefault             = "Please wait"
}