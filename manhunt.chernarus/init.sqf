//apply time and weather settings
setDate [2018, 10, 15, ("Time" call BIS_fnc_getParamValue), 0];
setTimeMultiplier ("TimeScale" call BIS_fnc_getParamValue);
0 setOvercast ("OvercastPercent" call BIS_fnc_getParamValue)/100;
0 setFog ("FogPercent" call BIS_fnc_getParamValue)/100;
0 setRain ("RainPercent" call BIS_fnc_getParamValue)/100;
forceWeatherChange;

//global variables
AI_SKILL_MAX = ("MaxEnemySkill" call BIS_fnc_getParamValue)/10;
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

	//extract vehicle does not run out of fuel
	exfiltration addEventHandler ["Fuel", {
		params ["_vehicle", "_hasFuel"];
		if (fuel _vehicle < 1.0) then
		{
			_vehicle setFuel 1.0;
		};
	}];

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
	private _possibleHQMarkers = ["hq_"] call SCO_fnc_getMarkersWithPrefix;
	private _posHQ = getMarkerPos (selectRandom _possibleHQMarkers);
	_hqMarker setMarkerPos _posHQ;
	_hqMarker setMarkerAlpha 1; //show HQ marker now that it is finally set
	private _nearbyClutter = nearestObjects [_posHQ, ["Mass_Grave"], 100, true];
	{
		deleteVehicle _x;
	} forEach _nearbyClutter;

	//object classnames, relative position and rotation for HQ tent
	//generated from a different script
	private _placementArray = [
		["Land_MedicalTent_01_CSAT_brownhex_generic_open_F",[0,0,0],0],
		["Land_MedicalTent_01_floor_light_F",[0,0,0],0],
		["Land_CampingChair_V2_white_F",[-1.44043,-0.301097,-1.37448],97.2297],
		["Land_Laptop_Intel_01_F",[-2.30078,-0.0440507,-0.37651],119.858],
		["Land_CampingChair_V2_F",[-1.91797,-1.43323,-1.37449],139.457],
		["Land_CampingTable_white_F",[-2.4668,-0.43909,-1.37708],112.439],
		["Land_CampingChair_V2_F",[2.23926,1.24913,-1.37426],261.168],
		["Newspaper_01_F",[-2.64258,-1.00747,-0.37653],359.993],
		["Land_SatellitePhone_F",[3.06641,1.33533,-0.37612],87.1279],
		["Land_MultiScreenComputer_01_black_F",[3.05078,2.18107,-0.37384],88.6554],
		["Land_PortableLight_02_double_yellow_F",[-3.22266,1.95623,-1.37373],311.475],
		["Land_PortableDesk_01_black_F",[3.07813,2.16546,-1.37155],271.236],
		["Land_Computer_01_black_F",[3.00195,2.97065,-0.37186],41.0214],
		["Land_Sun_chair_green_F",[3.02832,-3.18494,-1.35389],359.978],
		["Box_NATO_Support_F",[1.94141,-4.07574,-1.37453],344.716],
		["Land_Camping_Light_F",[2.04785,-4.14002,-0.38705],0.0134262],
		["Land_PortableCabinet_01_closed_black_F",[-1.95215,4.12042,-1.37061],174.886],
		["O_supplyCrate_F",[-2.24453,-3.49035,-1.3745],40],
		["Land_PortableCabinet_01_4drawers_black_F",[-3.36328,3.34279,-1.36412],326.209],
		["Land_PortableCabinet_01_bookcase_black_F",[-2.80664,3.8257,-1.37099],333.618],
		["Land_PortableCabinet_01_medical_F",[2.81641,3.91601,-1.36751],53.3696],
		["Box_NATO_AmmoVeh_F",[1.93945,5.84517,-1.33292],359.839],
		["Box_FIA_Support_F",[-2.05762,6.40834,-1.36661],0.360727],
		["SatelliteAntenna_01_Olive_F",[-3.89551,6.19535,-1.37167],344.466],
		["O_CargoNet_01_ammo_F",[3.49805,7.11149,-1.35801],91.1991]
	];

	//create the tent and get the tent object and intel within it
	private _missionObjects = [_posHQ, _placementArray, 0, 3, 17] call SCO_fnc_createMissionBuilding;
	_missionObjects params ["_tent", "_intel", "_crate"];
	["AmmoboxInit", [_crate, true, { (_this distance _target) < 10 }]] call BIS_fnc_arsenal;
	[_crate, [localize "STR_ACTION_HEAL", "(_this select 1) setDamage 0;"]] remoteExec ["addAction", 0, true];
	[_crate, [localize "STR_ACTION_AMMO", "functions\fn_refillWeapon.sqf", 4]] remoteExec ["addAction", 0, true];

	//create parked cars near HQ
	[getPos _tent, 3, (_conveyVehiclePool + _conveyVehiclePoolCUP), 5] call SCO_fnc_spawnParkedVehicles;

	//pick a meeting position
	private _possibleMeetingMarkers = ["meet_"] call SCO_fnc_getMarkersWithPrefix;
	private _meetingPosition = getMarkerPos (selectRandom _possibleMeetingMarkers);
	"meeting" setMarkerPos _meetingPosition;

	//create meeting
	private _warlordUnit = [_meetingPosition, 4, "Land_Campfire_F", (_meetingUnitPool + _meetingUnitPoolCUP), _primaryWeaponPool, AI_SKILL_MAX] call SCO_fnc_spawnEnemyMeeting;
	
	//create parked cars near meeting location
	[_meetingPosition, 4, (_conveyVehiclePool + _conveyVehiclePoolCUP), 5] call SCO_fnc_spawnParkedVehicles;

	//create tasks for players on a different thread
	private _taskManager = [_tent, _intel, _meetingPosition, _warlordUnit, exfiltration, end] spawn SCO_fnc_taskManager;

	//spawn enemy unit ground patrols
	[_meetingPosition, 500, 6, _patrolUnitPool, [(AI_SKILL_MAX / 2), AI_SKILL_MAX], _patrol] call SCO_fnc_spawnGroundPatrolGroup;
	[getPos _tent, 50, 6, _patrolUnitPool, [(AI_SKILL_MAX / 2), 1.0 min (AI_SKILL_MAX + 0.1)], _patrol] call SCO_fnc_spawnGroundPatrolGroup;

	//define all cities to spawn patrols in
	private _allTowns = nearestLocations [
		getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), 
		["Name", "NameVillage", "NameCity", "NameCityCapital"], 
		worldSize];

	{
		private _size = ((size _x select 0) max (size _x select 1))*2;
		[
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
	private _numRegionVehicles = "RegionVehiclePatrols" call BIS_fnc_getParamValue;
	[_allTowns, _patrolUnitPool, "CityFootPatrolMultiplier" call BIS_fnc_getParamValue] spawn SCO_fnc_footPatrolManager;
	[_allTowns, _conveyVehiclePool + _conveyVehiclePoolCUP, _numRegionVehicles] spawn SCO_fnc_vehiclePatrolManager;

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
