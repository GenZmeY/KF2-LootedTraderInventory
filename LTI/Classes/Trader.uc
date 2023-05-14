class Trader extends Object
	abstract;

private delegate int ByPrice(class<KFWeaponDefinition> A, class<KFWeaponDefinition> B)
{
	return A.default.BuyPrice > B.default.BuyPrice ? -1 : 0;
}

public static function KFGFxObject_TraderItems GetTraderItems(optional KFGameReplicationInfo KFGRI = None, optional E_LogLevel LogLevel = LL_Trace)
{
	local String TraderItemsPath;

	if (KFGRI == None)
	{
		TraderItemsPath = class'KFGameReplicationInfo'.default.TraderItemsPath;
	}
	else
	{
		TraderItemsPath = KFGRI.TraderItemsPath;
	}

	return KFGFxObject_TraderItems(DynamicLoadObject(TraderItemsPath, class'KFGFxObject_TraderItems'));
}

public static function Array<class<KFWeaponDefinition> > GetTraderWeapDefs(optional KFGameReplicationInfo KFGRI = None,optional E_LogLevel LogLevel = LL_Trace)
{
	local Array<class<KFWeaponDefinition> > KFWeapDefs;
	local KFGFxObject_TraderItems TraderItems;
	local STraderItem Item;

	TraderItems = GetTraderItems(KFGRI, LogLevel);

	foreach TraderItems.SaleItems(Item)
	{
		if (Item.WeaponDef != None)
		{
			KFWeapDefs.AddItem(Item.WeaponDef);
		}
	}

	return KFWeapDefs;
}

public static function Array<class<KFWeapon> > GetTraderWeapons(optional KFGameReplicationInfo KFGRI = None,optional E_LogLevel LogLevel = LL_Trace)
{
	local Array<class<KFWeapon> > KFWeapons;
	local class<KFWeapon> KFWeapon;
	local KFGFxObject_TraderItems TraderItems;
	local STraderItem Item;

	TraderItems = GetTraderItems(KFGRI, LogLevel);

	foreach TraderItems.SaleItems(Item)
	{
		if (Item.WeaponDef != None)
		{
			KFWeapon = class<KFWeapon> (DynamicLoadObject(Item.WeaponDef.default.WeaponClassPath, class'Class'));
			if (KFWeapon != None)
			{
				KFWeapons.AddItem(KFWeapon);
			}
		}
	}

	return KFWeapons;
}

public static simulated function ModifyTrader(
	KFGameReplicationInfo KFGRI,
	Array<class<KFWeaponDefinition> > RemoveItems,
	bool ReplaceMode,
	bool RemoveHRG,
	bool RemoveDLC,
	E_LogLevel LogLevel)
{
	local KFGFxObject_TraderItems TraderItems;
	local STraderItem Item;
	local class<KFWeaponDefinition> WeapDef;
	local Array<class<KFWeaponDefinition> > WeapDefs;
	local int MaxItemID;

	`Log_TraceStatic();

	TraderItems = GetTraderItems(KFGRI, LogLevel);

	if (!ReplaceMode)
	{
		foreach TraderItems.SaleItems(Item)
		{
			if (Item.WeaponDef != None
			&& RemoveItems.Find(Item.WeaponDef) == INDEX_NONE
			&& (!RemoveHRG || (RemoveHRG && InStr(Item.WeaponDef, "_HRG", true) == INDEX_NONE))
			&& (!RemoveDLC || (RemoveDLC && Item.WeaponDef.default.SharedUnlockId == SCU_None)))
			{
				WeapDefs.AddItem(Item.WeaponDef);
			}
		}
	}

	WeapDefs.Sort(ByPrice);

	TraderItems.SaleItems.Length = 0;
	MaxItemID = 0;
	foreach WeapDefs(WeapDef)
	{
		Item.WeaponDef = WeapDef;
		Item.ItemID = ++MaxItemID;
		TraderItems.SaleItems.AddItem(Item);
	}

	TraderItems.SetItemsInfo(TraderItems.SaleItems);

	KFGRI.TraderItems = TraderItems;
}

defaultproperties
{

}
