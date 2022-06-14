setDate [2018, 4, 2, ("Time" call BIS_fnc_getParamValue), 30];
0 setFog ("Fog" call BIS_fnc_getParamValue)/100;
0 setOvercast ("Clouds" call BIS_fnc_getParamValue)/100;
0 setRain ("Rain" call BIS_fnc_getParamValue)/100;

if (rain > 0.5) then {0 setLightnings rain};
forceWeatherChange;

EVAC_TIME = "TimeEvac" call BIS_fnc_getParamValue;
AIRDROP_TIME = "TimeDrop" call BIS_fnc_getParamValue;
KILL_REWARD = ("RewardKill" call BIS_fnc_getParamValue)/1000;
HIT_REWARD = ("RewardHit" call BIS_fnc_getParamValue)/1000;
DEATH_REWARD = ("RewardDeath" call BIS_fnc_getParamValue)/1000;
ENEMY_CAP = "AmountEnemyCapture" call BIS_fnc_getParamValue;

isDoneFail = false;
isDoneWin = false;

[west,"US1"] call BIS_fnc_addRespawnInventory;
[west,"US2"] call BIS_fnc_addRespawnInventory;
[west,"US3"] call BIS_fnc_addRespawnInventory;
[west,"US4"] call BIS_fnc_addRespawnInventory;
[west,"US5"] call BIS_fnc_addRespawnInventory;
[west,"US6"] call BIS_fnc_addRespawnInventory;
[west,"US7"] call BIS_fnc_addRespawnInventory;
[west,"US8"] call BIS_fnc_addRespawnInventory;
[west,"US9"] call BIS_fnc_addRespawnInventory;
[west,"US10"] call BIS_fnc_addRespawnInventory;
[west,"US11"] call BIS_fnc_addRespawnInventory;

//global variables
capSize = markerSize "cap_size" select 0;
safeDist = markerSize "areaSize" select 0;;

evacVehicleType = "CUP_B_M1126_ICV_MK19_Desert_Slat";
driverType = "CUP_B_US_Soldier";
planeType = "CUP_B_C130J_USMC";
crateType = "B_supplyCrate_F";

extractionAvailable = false;
airdropAvailable = true;

#include "initCurator.sqf"
if (isServer) then
{
	{
		_x addMPEventHandler ["MPKilled",{gm addCuratorPoints KILL_REWARD;}];
		_x addMPEventHandler ["MPHit",{gm addCuratorPoints HIT_REWARD;}];
	} forEach units (playableUnits select 0);
	
	[] spawn
	{
		while {!(extractionAvailable)} do {
			sleep 1;
			_enemyCount = {(alive _x) && (_x distance (getMarkerPos "cap") < capSize) && (side _x == east)} count allUnits;
			if (_enemyCount != 0) then {format ["Warning: %1 enemy(s) in the capture zone! (Max = %2)",_enemyCount,ENEMY_CAP] remoteExec ["hint"];};
			if (_enemyCount == 0) then {"" remoteExec ["hint"];};
			if (_enemyCount >= ENEMY_CAP) then {missionNamespace setVariable ["isDoneFail", true, true];};
		};
	};
};

_allBuildingsOnMap = nearestObjects [getMarkerPos "cap", ["House","Building","Land_BagFence_Long_F","Land_BagFence_Round_F"], 200];
{
	_x allowDamage false;
} forEach _allBuildingsOnMap;
	
_weaponList = (configFile >> "cfgWeapons") call BIS_fnc_getCfgSubClasses;
_magList = (configFile >> "cfgMagazines") call BIS_fnc_getCfgSubClasses;
_weaponTypes = ["AssaultRifle","MachineGun","SniperRifle","Shotgun","Rifle","SubmachineGun","MissileLauncher","RocketLauncher"];
_attchmentTypes = ["AccessoryMuzzle","AccessoryPointer","AccessorySights","AccessoryBipod"];
_ammoTypes = ["Artillery","Flare","Grenade","Laser","Missile","Rocket","Shell","ShotgunShell","SmokeShell"];

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
						if ((_baseName find "_AK" == -1) and (_baseName find "_RPK" == -1) and (_baseName find "_SVD" == -1) and (_baseName find "_SA" == -1) and (_baseName find "_PK" == -1) and (_baseName find "_VSS" == -1) and (_baseName find "ksvk" == -1) and (_baseName find "RPG" == -1) and (_baseName find "CZ" == -1) and (_baseName find "_Sa58" == -1) and (_baseName find "_UK59" == -1)) then
						{
							weaponClassnames pushBack _baseName;
						};
					};
				};
			};
		};
	};
} foreach _weaponList;

attach allowDamage false;
attach addAction ["Call for Airdrop","airdrop.sqf",nil,5,false,true,"","airdropAvailable"];

if (isServer) then
{
	clearWeaponCargoGlobal attach;
	clearItemCargoGlobal attach;
	clearBackpackCargoGlobal attach;
	clearMagazineCargoGlobal attach;
	
	{
		attach addItemCargoGlobal [_x, 8];
	} foreach attachmentClassnames;

	//evac timer
	[] spawn {
		sleep EVAC_TIME;
		missionNamespace setVariable ["extractionAvailable", true, true]; 
		[] execVM "evac.sqf";
	};
	
	//end tracker
	[] spawn {
		waitUntil {sleep 2; (isDoneFail) or (isDoneWin)};
		if (isDoneWin) then {"EveryoneWon" call BIS_fnc_endMissionServer;};
		if (isDoneFail) then {"EveryoneLost" call BIS_fnc_endMissionServer;};
	};
};

