#include "initCurator.sqf"

//set weather conditions, settings based on parameters
setDate [2018, 4, 2, ("Time" call BIS_fnc_getParamValue), 30];
0 setFog ("Fog" call BIS_fnc_getParamValue)/100;
0 setOvercast ("Clouds" call BIS_fnc_getParamValue)/100;
0 setRain ("Rain" call BIS_fnc_getParamValue)/100;

if (rain > 0.5) then {0 setLightnings rain};
forceWeatherChange;

COST_MULT = ("CostMultiplier" call BIS_fnc_getParamValue)/100;
AIRDROP_TIME = "TimeDrop" call BIS_fnc_getParamValue;
KILL_REWARD = ("RewardKill" call BIS_fnc_getParamValue)/1000;
HIT_REWARD = ("RewardHit" call BIS_fnc_getParamValue)/1000;
DEATH_REWARD = ("RewardDeath" call BIS_fnc_getParamValue)/1000;
ENEMY_CAP = "AmountEnemyCapture" call BIS_fnc_getParamValue;

{
	[west,_x] call BIS_fnc_addRespawnInventory;
} forEach ["US1", "US2", "US3", "US4", "US5", "US6",
	"US7", "US8", "US9", "US10", "US11"];

AIRDROP_AVAILABLE = true;
	
//fill list of usable west weapons, items and ammo. used in airdrop code
private _weaponList = (configFile >> "cfgWeapons") call BIS_fnc_getCfgSubClasses;
private _magList = (configFile >> "cfgMagazines") call BIS_fnc_getCfgSubClasses;
private _weaponTypes = ["AssaultRifle","MachineGun","SniperRifle","Shotgun","Rifle","SubmachineGun","MissileLauncher","RocketLauncher"];
private _attchmentTypes = ["AccessoryMuzzle","AccessoryPointer","AccessorySights","AccessoryBipod"];
private _ammoTypes = ["Artillery","Flare","Grenade","Laser","Missile","Rocket","Shell","ShotgunShell","SmokeShell"];

attachmentClassnames = [];
weaponClassnames = [];
ammoClassnames = [];

{
	if (getText (configFile >> "cfgMagazines" >> _x >> "picture") != "") then {
		_itemType = _x call bis_fnc_itemType;
		if (((_itemType select 0) == "Magazine") && ((_itemType select 1) in _ammoTypes)) then
		{
			ammoClassnames pushBack _x;
		};
	};
} foreach _magList;

{
	if (getnumber (configFile >> "cfgWeapons" >> _x >> "scope") > 1) then {
		_itemType = _x call bis_fnc_itemType;
		if (((_itemType select 0) == "Item") && ((_itemType select 1) in _attchmentTypes)) then
		{
			attachmentClassnames pushBack _x;
		};
	};
} foreach _weaponList;

{
	//check if usable weapon
	if (getnumber (configFile >> "cfgWeapons" >> _x >> "scope") > 1) then {
		_itemType = _x call bis_fnc_itemType;
		if (((_itemType select 0) == "Weapon") && ((_itemType select 1) in _weaponTypes)) then
		{
			_baseName = _x call BIS_fnc_baseWeapon;
			if ((_baseName isEqualTo _x)) then
			{
				if (!(_baseName in weaponClassnames)) then
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
							weaponClassnames pushBack _baseName;
						};
					};
				};
			};
		};
	};
} foreach _weaponList;

"carrier" execVM "fn_spawnCarrier.sqf";