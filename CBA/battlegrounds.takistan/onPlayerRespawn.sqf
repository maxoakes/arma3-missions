player allowDamage false;
waitUntil{BIS_fnc_init};
//find safe spawn position not near another player
_pos = getMarkerPos centerMarker;
_posFound = false;
_i = 0;
_startingDistance = radius/2;
_distanceStep = (radius/400);
while {!(_posFound)} do
{
	_i = _i+1;
	_pos = [getMarkerPos centerMarker, 0, radius-4, 2, 0, 0, 0, [], [getMarkerPos centerMarker,getMarkerPos centerMarker]] call BIS_fnc_findSafePos;
	_enemyList = _pos nearEntities ["Man", _startingDistance];
	if ((count _enemyList == 0) and ((_pos distance (_this select 1)) > _startingDistance)) then
	{
		_this select 0 setPos _pos;
		_posFound = true;
	};
	_startingDistance = _startingDistance-_distanceStep;
};
player groupChat format ["Safe spawn found in %1 iteration(s), finishing at %2m check.",_i,_startingDistance+_distanceStep];

player enableStamina false;
player addRating -4000;

removeallweapons player;
removeAllItems player;
removeAllAssignedItems player;
{player removeMagazine _x} forEach magazines player;
removeBackpack player;
removeVest player;

player addVest (spawnVestPool select (random (count spawnVestPool)));

_w = spawnPool select (random floor count spawnPool);
if (!(isNil "_w")) then
{
	player addWeapon _w;
	player addPrimaryWeaponItem "acc_flashlight";
	player addSecondaryWeaponItem "acc_flashlight_pistol";

	if (((player weaponAccessories _w) select 2) isEqualTo "") then
	{
		player addPrimaryWeaponItem "optic_Aco";
		player addPrimaryWeaponItem "optic_Aco_smg";
	};

	_mag = (getArray (configFile >> "CfgWeapons" >> _w >> "magazines")) select 0;
	for "_i" from 1 to 4 do
	{
		player addMagazine _mag;
	};

	player addPrimaryWeaponItem _mag;
};

_p = pistolPool select (random floor count pistolPool);
if (!(isNil "_p")) then
{
	player addWeapon _p;
	_pmag = (getArray (configFile >> "CfgWeapons" >> _p >> "magazines")) select 0;
	for "_i" from 1 to 3 do
	{
		player addMagazine _pmag;
	};
}
else
{
	player addWeapon defaultHandgun;
	player addMagazine defaultHandgunMag;
	player addMagazine defaultHandgunMag;
	player addMagazine defaultHandgunMag;
};

if (radius >= 250) then {player addItem "optic_DMS";};
player addMagazine "HandGrenade";
player addMagazine "HandGrenade";

player addItem "ItemMap";
player assignItem "ItemMap";
player addItem "ItemCompass";
player assignItem "ItemCompass";
player addItem "ItemWatch";
player assignItem "ItemWatch";
player addItem "ItemRadio";
player assignItem "ItemRadio";
player addItem "FirstAidKit";

player allowDamage true;