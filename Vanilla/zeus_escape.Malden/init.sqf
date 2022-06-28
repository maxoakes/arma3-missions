#include "initCurator.sqf"

//weather settings
setDate [2018, 3, 30, ("Time" call BIS_fnc_getParamValue), 0];
0 setOvercast ("Clouds" call BIS_fnc_getParamValue)/100;
0 setFog ("Fog" call BIS_fnc_getParamValue)/100;
0 setRain ("Rain" call BIS_fnc_getParamValue)/100;
forceWeatherChange;

//global variables
AIRDROP_AVAILABLE = true;
publicVariable "AIRDROP_AVAILABLE";
COST_MULT = ("CostMultiplier" call BIS_fnc_getParamValue)/100;
AIRDROP_TIME = "TimeDrop" call BIS_fnc_getParamValue;
KILL_REWARD = ("RewardKill" call BIS_fnc_getParamValue)/1000;
HIT_REWARD = ("RewardHit" call BIS_fnc_getParamValue)/1000;
DEATH_REWARD = ("RewardDeath" call BIS_fnc_getParamValue)/1000;
ENEMY_CAP = "AmountEnemyCapture" call BIS_fnc_getParamValue;

//fill list of usable west weapons, items and ammo. used in airdrop code
private _weaponList = (configFile >> "cfgWeapons") call BIS_fnc_getCfgSubClasses;
private _magList = (configFile >> "cfgMagazines") call BIS_fnc_getCfgSubClasses;
private _weaponTypes = ["AssaultRifle","MachineGun","SniperRifle","Shotgun","Rifle","SubmachineGun","MissileLauncher","RocketLauncher"];
private _attchmentTypes = ["AccessoryMuzzle","AccessoryPointer","AccessorySights","AccessoryBipod"];
private _ammoTypes = ["Artillery","Flare","Grenade","Laser","Missile","Rocket","Shell","ShotgunShell","SmokeShell"];

AMMO_CLASSNAMES = [];
{
	if (getText (configFile >> "cfgMagazines" >> _x >> "picture") != "") then {
		private _itemType = _x call bis_fnc_itemType;
		if (((_itemType select 0) == "Magazine") && ((_itemType select 1) in _ammoTypes)) then
		{
			AMMO_CLASSNAMES pushBack _x;
		};
	};
} foreach _magList;

ATTACHMENT_CLASSNAMES = [];
{
	if (getnumber (configFile >> "cfgWeapons" >> _x >> "scope") > 1) then {
		private _itemType = _x call bis_fnc_itemType;
		if (((_itemType select 0) == "Item") && ((_itemType select 1) in _attchmentTypes)) then
		{
			ATTACHMENT_CLASSNAMES pushBack _x;
		};
	};
} foreach _weaponList;

WEAPON_CLASSNAMES = [];
{
	//check if usable weapon
	if (getnumber (configFile >> "cfgWeapons" >> _x >> "scope") > 1) then {
		private _itemType = _x call bis_fnc_itemType;
		if (((_itemType select 0) == "Weapon") && ((_itemType select 1) in _weaponTypes)) then
		{
			private _baseName = _x call BIS_fnc_baseWeapon;
			if ((_baseName isEqualTo _x)) then
			{
				if (!(_baseName in WEAPON_CLASSNAMES)) then
				{
					if ((_baseName find "CUP" != -1)) then
					{
						if ((_baseName find "_AK" == -1) and
						(_baseName find "_RPK" == -1) and
						(_baseName find "_SVD" == -1) and
						(_baseName find "_SA" == -1) and
						(_baseName find "_PK" == -1) and
						(_baseName find "_VSS" == -1) and
						(_baseName find "ksvk" == -1) and
						(_baseName find "RPG" == -1) and
						(_baseName find "CZ" == -1) and
						(_baseName find "_Sa58" == -1) and
						(_baseName find "_UK59" == -1)) then
						{
							WEAPON_CLASSNAMES pushBack _baseName;
						};
					};
				};
			};
		};
	};
} foreach _weaponList;

"carrier" execVM "fn_spawnCarrier.sqf";