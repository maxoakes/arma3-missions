params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

_newUnit enableStamina false;
_newUnit setUnitTrait ["engineer", true];
_newUnit setUnitTrait ["Medic", true];

if (backpack _newUnit isEqualTo "") then
{
	_newUnit addBackpack "B_Carryall_cbr";
};

removeAllItems _newUnit;
removeAllAssignedItems _newUnit;

{
	_newUnit removeMagazine _x
} forEach magazines _newUnit;

private _primaryMag = getArray (configFile >> "CfgWeapons" >> primaryWeapon _newUnit >> "magazines");
private _handgunMag = getArray (configFile >> "CfgWeapons" >> handgunWeapon _newUnit >> "magazines");

_newUnit addPrimaryWeaponItem (_primaryMag select 0);
for "_i" from 1 to 4 do
{
	_newUnit addMagazine (_primaryMag select 0);
	sleep 0.01;
};
for "_j" from 1 to 3 do
{
	_newUnit addMagazine (_handgunMag select 0);
	sleep 0.01;
};

_newUnit addMagazine "MiniGrenade";
_newUnit addMagazine "MiniGrenade";
_newUnit addMagazine "SmokeShell";

_newUnit addItem "ItemGPS";
_newUnit assignItem "ItemGPS";
_newUnit addItem "ItemRadio";
_newUnit assignItem "ItemRadio";
_newUnit addItem "FirstAidKit";
_newUnit addItem "FirstAidKit";