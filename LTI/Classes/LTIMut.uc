class LTIMut extends KFMutator;

var private LTI LTI;

public simulated function bool SafeDestroy()
{
	return (bPendingDelete || bDeleteMe || Destroy());
}

public event PreBeginPlay()
{
	Super.PreBeginPlay();

	if (WorldInfo.NetMode == NM_Client) return;

	foreach WorldInfo.DynamicActors(class'LTI', LTI)
	{
		break;
	}

	if (LTI == None)
	{
		LTI = WorldInfo.Spawn(class'LTI');
	}

	if (LTI == None)
	{
		`Log_Base("FATAL: Can't Spawn 'LTI'");
		WorldInfo.Game.RemoveMutator(Self);
		SafeDestroy();
	}
}

public function AddMutator(Mutator Mut)
{
	if (Mut == Self) return;

	if (Mut.Class == Class)
		LTIMut(Mut).SafeDestroy();
	else
		Super.AddMutator(Mut);
}

public function NotifyLogin(Controller C)
{
	LTI.NotifyLogin(C);

	Super.NotifyLogin(C);
}

public function NotifyLogout(Controller C)
{
	LTI.NotifyLogout(C);

	Super.NotifyLogout(C);
}

DefaultProperties
{
	GroupNames.Add("TraderItems")
}