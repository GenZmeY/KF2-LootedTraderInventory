class LTI_LocalMessage extends Object
	abstract;

var const             String SyncItemsDefault;
var private localized String SyncItems;

var const             String SyncFinishedDefault;
var private localized String SyncFinished;

var const             String WaitingGRIDefault;
var private localized String WaitingGRI;

var const             String IncompatibleGRIDefault;
var private localized String IncompatibleGRI;

var const             String DisconnectDefault;
var private localized String Disconnect;

var const             String SecondsShortDefault;
var private localized String SecondsShort;

enum E_LTI_LocalMessageType
{
	LTI_SyncItems,
	LTI_SyncFinished,
	LTI_WaitingGRI,
	LTI_IncompatibleGRI,
	LTI_Disconnect,
	LTI_SecondsShort
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
			
		case LTI_SyncFinished:
			return (default.SyncFinished != "" ? default.SyncFinished : default.SyncFinishedDefault);
		
		case LTI_WaitingGRI:
			return (default.WaitingGRI != "" ? default.WaitingGRI : default.WaitingGRIDefault);
		
		case LTI_IncompatibleGRI:
			return (default.IncompatibleGRI != "" ? default.IncompatibleGRI : default.IncompatibleGRIDefault);
		
		case LTI_Disconnect:
			return (default.Disconnect != "" ? default.Disconnect : default.DisconnectDefault);
		
		case LTI_SecondsShort:
			return (default.SecondsShort != "" ? default.SecondsShort : default.SecondsShortDefault);
	}
	
	return "";
}

defaultproperties
{
	SyncItemsDefault       = "Sync items:"
	SyncFinishedDefault    = "Sync finished."
	WaitingGRIDefault      = "Waiting GRI..."
	IncompatibleGRIDefault = "Incompatible GRI:"
	DisconnectDefault      = "Disconnect..."
	SecondsShortDefault    = "s"
}