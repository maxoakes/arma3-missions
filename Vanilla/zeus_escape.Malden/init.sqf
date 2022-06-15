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

airdropAvailable = true;
campMarkers = [
	"ec_0", "ec_1", "ec_2", "ec_3", "ec_4", "ec_5", "ec_6", "ec_7", "ec_8",
	"ec_9", "ec_10","ec_11", "ec_12", "ec_13", "ec_14", "ec_15", "ec_16", 
	"ec_17", "ec_18", "ec_19"];

if (isServer) then
{
	//if a player is damaged or killed, the zeus gets points
	{
		_x addMPEventHandler ["MPKilled", {gm addCuratorPoints KILL_REWARD;}];
		_x addMPEventHandler ["MPHit", {gm addCuratorPoints HIT_REWARD;}];
	} forEach units (playableUnits select 0);
	
	//make a zeus editing area around each capture and hold point
	{
		_thisEditAreaID = parseNumber mapGridPosition getPos _x;
		gm addCuratorEditingArea [_thisEditAreaID, getPos _x, 100];
	} forEach nearestObjects [
		getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), ["ModuleSector_F"], worldSize];
	
	//make a zeus editing area around each enemy camp
	{
		_thisEditAreaID = parseNumber mapGridPosition getMarkerPos _x;
		gm addCuratorEditingArea [_thisEditAreaID,getMarkerPos _x, 200];
	} forEach campMarkers;
	
	//spawn a thread to check for win condition: everyone gets outside of the island
	[] spawn
	{
		waitUntil {
			sleep 30;
			//count number of west players that are on the island
			_westOnCarrier = {
				(_x distance2D getMarkerPos "carrier" < 150) and (side group _x == west)
			} count allPlayers;
			_westTotal = west countSide allPlayers;
			_westOnCarrier == _westTotal; //wait until this is true
		};
		["Everyone as escaped the island. Good job."] remoteExec ["systemChat"];
		sleep 3;
		"EveryoneWon" call BIS_fnc_endMissionServer;
	};
};
	
//fill list of usable west weapons, items and ammo
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

//spawn carrier
if (isServer) then {
	// Spawn Carrier on Server
	_carrier = createVehicle ["Land_Carrier_01_base_F", getMarkerPos "marker_0", [], 0, "None"];
	_carrier setPosWorld getMarkerPos "carrier";
	_carrier setDir 270;
	[_carrier] call BIS_fnc_Carrier01PosUpdate;

	// Broadcast Carrier ID over network
	missionNamespace setVariable ["USS_FREEDOM_CARRIER", _carrier];
	publicVariable "USS_FREEDOM_CARRIER";
}
else
{
	[] spawn {
		// Clients wait for carrier
		waitUntil {
			!(isNull (missionNamespace getVariable ["USS_FREEDOM_CARRIER",objNull]))
		};

		// Work around for missing carrier data not being broadcast as expected
		if (count (USS_FREEDOM_CARRIER getVariable ["bis_carrierParts", []]) == 0) then {
			["Carrier %1 is empty. Client Fixing.",str "bis_carrierParts"] call BIS_fnc_logFormatServer;
			private _carrierPartsArray = (configFile >> "CfgVehicles" >> typeOf USS_FREEDOM_CARRIER >> "multiStructureParts") call BIS_fnc_getCfgDataArray;
			private _partClasses = _carrierPartsArray apply {_x select 0};
			private _nearbyCarrierParts = nearestObjects [USS_FREEDOM_CARRIER,_partClasses,500];
			{
				private _carrierPart = _x;
				private _index = _forEachIndex;
				{
					if ((_carrierPart select 0) isEqualTo typeOf _x) exitWith { _carrierPart set [0,_x]; };
				} forEach _nearbyCarrierParts;
				_carrierPartsArray set [_index,_carrierPart];
			} forEach _carrierPartsArray;
			USS_FREEDOM_CARRIER setVariable ["bis_carrierParts",_nearbyCarrierParts];
			["Carrier %1 was empty. Now contains %2.",str "bis_carrierParts",USS_FREEDOM_CARRIER getVariable ["bis_carrierParts", []]] call BIS_fnc_logFormatServer;
		};

		// Client Initiate Carrier Actions with slight delay to ensure carrier is sync'd
		[USS_FREEDOM_CARRIER] spawn { sleep 1; _this call BIS_fnc_Carrier01Init};
	};
};
