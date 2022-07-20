//apply time and weather settings
setDate [2018, 10, 15, ("Time" call BIS_fnc_getParamValue), 0];
setTimeMultiplier ("TimeScale" call BIS_fnc_getParamValue);
0 setOvercast ("OvercastPercent" call BIS_fnc_getParamValue)/100;
0 setFog ("FogPercent" call BIS_fnc_getParamValue)/100;
0 setRain ("RainPercent" call BIS_fnc_getParamValue)/100;
forceWeatherChange;

//global variables
MAX_REGION_VEHICLE_PATROLS = "RegionVehiclePatrols" call BIS_fnc_getParamValue;
REVEAL_WARLORD_MEETING = false;
CONFIRMED_KILL = false;
private _patrol = 0;
private _defense = 1;

//easily configurable variables
private _conveyVehiclePool = ["O_MRAP_02_hmg_F", "O_LSV_02_armed_F", "O_LSV_02_AT_F", "O_G_Offroad_01_armed_F"];
private _conveyVehiclePoolCUP = ["CUP_O_UAZ_Open_RU", "CUP_O_UAZ_MG_CSAT", "CUP_O_UAZ_AGS30_CSAT", 
	"CUP_O_Hilux_M2_OPF_G_F", "CUP_O_Hilux_AGS30_OPF_G_F", "CUP_O_Hilux_unarmed_OPF_G_F"];
private _meetingUnitPool = ["O_G_Soldier_F", "O_G_Soldier_lite_F", "O_G_Soldier_SL_F", "O_G_Soldier_TL_F", "O_G_Soldier_AR_F", "O_G_medic_F"];
private _meetingUnitPoolCUP = ["CUP_O_INS_Officer", "CUP_O_INS_Story_Bardak", "CUP_O_INS_Story_Lopotev", "CUP_O_INS_Commander"];
private _patrolUnitPool = ["CUP_O_INS_Soldier_AA", "CUP_O_INS_Soldier_Ammo", "CUP_O_INS_Soldier_AT", "CUP_O_INS_Soldier_AR", 
	"CUP_O_INS_Soldier_Engineer", "CUP_O_INS_Soldier_MG", "CUP_O_INS_Soldier", "CUP_O_INS_Soldier_AK74", "CUP_O_INS_Soldier_LAT", 
	"CUP_O_INS_Sniper", "CUP_O_INS_Villager3", "CUP_O_INS_Woodlander3", "CUP_O_INS_Worker2"];

if (isServer) then
{
	private _startTime = diag_tickTime;

	//build non-literal variables
	private _primaryWeaponPool = [];
	{
		//check if usable weapon
		if (getnumber (configFile >> "cfgWeapons" >> _x >> "scope") > 1) then
		{
			private _itemType = _x call bis_fnc_itemType;
			//check if the weapon is an AK-style weapon per the classname
			if (((_itemType select 0) == "Weapon") && ("arifle_AK" in _x)) then
			{
				_primaryWeaponPool pushBackUnique _x;
			};
		};
	} foreach ((configFile >> "cfgWeapons") call BIS_fnc_getCfgSubClasses);

	//set up markers
	private _hqMarker = "confirmed";
	_hqMarker setMarkerAlpha 0; //initially hide HQ marker as it is not properly set
	"meeting" setMarkerAlpha 0;

	//create the respawn inventories
	{
		[west, _x] call BIS_fnc_addRespawnInventory;
	} foreach ["Unit1", "Unit2", "Unit3", "Unit4", "Unit5", "Unit6", "Unit7", "Unit8"];

	//set up the ARMA arsenal functionality
	arsenal allowDamage false;
	clearItemCargoGlobal arsenal;
	clearWeaponCargoGlobal arsenal;
	clearMagazineCargoGlobal arsenal;
	["AmmoboxInit", [arsenal, true, { (_this distance _target) < 10 }]] call BIS_fnc_arsenal;
	[arsenal, [localize "STR_ACTION_HEAL", "(_this select 1) setDamage 0;"]] remoteExec ["addAction", 0, true];
	[arsenal, [localize "STR_ACTION_AMMO", "functions\fn_refillWeapon.sqf", 4]] remoteExec ["addAction", 0, true];

	//setup exfil boat
	private _exfilMarker = [
		"exfil", //var name
		getPos exfiltration, //position
		localize "STR_MARKER_BOAT", //display name
		[1, 1], //size
		"ColorBLUFOR", //color string
		"ICON", //type
		"mil_pickup" //style
	] call SCO_fnc_createMarker;
	exfiltration allowDamage false;
	exfiltration lock true;

	//update marker for the boat since it is important to the mission
	[_exfilMarker, exfiltration] spawn
	{
		while {true} do
		{
			sleep 2;
			(_this select 0) setMarkerPos getPos (_this select 1);
		};
	};

	//populate the map with random graves and wrecks
	private _doSpawnWrecks = [("ClutterWreck" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean;
	private _doSpawnGraves = [("ClutterGraves" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean;
	[_doSpawnWrecks, _doSpawnGraves] call SCO_fnc_generateMapClutter;

	//once an HQ location is found, mark it on the map and delete any mass graves near it
	private _possibleHQMarkers = ["hq_"] call BIS_fnc_getMarkers;
	private _posHQ = getMarkerPos (selectRandom _possibleHQMarkers);
	_hqMarker setMarkerPos _posHQ;
	_hqMarker setMarkerAlpha 1; //show HQ marker now that it is finally set
	private _nearbyClutter = nearestObjects [_posHQ, ["Mass_Grave"], 100, true];
	{
		deleteVehicle _x;
	} forEach _nearbyClutter;

	//create the tent and get the tent object and intel within it
	private _missionObjects = [_posHQ] call SCO_fnc_createHQTent;
	_missionObjects params ["_tent", "_intel"];

	//pick a meeting position
	private _possibleMeetingMarkers = ["meet_"] call BIS_fnc_getMarkers;
	private _meetingPosition = getMarkerPos (selectRandom _possibleMeetingMarkers);
	"meeting" setMarkerPos _meetingPosition;

	//create meeting
	private _warlordUnit = [_meetingPosition, 4, "Land_Campfire_F", (_meetingUnitPool + _meetingUnitPoolCUP), _primaryWeaponPool] call SCO_fnc_spawnEnemyMeeting;
	
	//create parked cars near meeting location
	private _convoy = [_meetingPosition, 4, (_conveyVehiclePool + _conveyVehiclePoolCUP)] call SCO_fnc_spawnParkedConvoy;

	//create tasks for players on a different thread
	private _taskManager = [_tent, _intel, _meetingPosition, _warlordUnit, exfiltration, end] spawn SCO_fnc_taskManager;

	//spawn enemy unit ground patrols
	[_meetingPosition, 500, 6, _patrolUnitPool, [0.2, 0.6], _patrol] call SCO_fnc_spawnGroundPatrolGroup;
	[getPos _tent, 50, 6, _patrolUnitPool, [0.3, 0.5], _patrol] call SCO_fnc_spawnGroundPatrolGroup;

	//define all cities to spawn patrols in
	private _allTowns = nearestLocations [
		getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), 
		["Name", "NameVillage", "NameCity", "NameCityCapital"], 
		worldSize];

	{
		private _size = ((size _x select 0) max (size _x select 1))*2;
		private _townBorder = [
			format ["t%1", _forEachIndex], //var name
			locationPosition _x, //position
			text _x, //display name
			[_size, _size], //size
			"ColorRed", //color string
			"ELLIPSE", //type
			"DiagGrid" //style
		] call SCO_fnc_createMarker;
	} forEach _allTowns;

	//vehicle and unit patrol managers
	[_allTowns, _patrolUnitPool, "CityFootPatrolMultiplier" call BIS_fnc_getParamValue] spawn SCO_fnc_footPatrolManager;
	[_allTowns, _conveyVehiclePool + _conveyVehiclePoolCUP, 30] spawn SCO_fnc_vehiclePatrolManager;

	private _numNearbyVehicles = "NearbyVehiclePatrol" call BIS_fnc_getParamValue;
	if (_numNearbyVehicles > 0) then
	{
		for "_i" from 1 to _numNearbyVehicles do
		{
			[_allTowns, _conveyVehiclePool + _conveyVehiclePoolCUP] spawn SCO_fnc_spawnRepeatingSingleVehiclePatrol;
		};
	};
	
	_stopTime = diag_tickTime;
	(format ["%1 sec to finish init.sqf", _stopTime - _startTime]) remoteExec ["systemChat", 0];
};
