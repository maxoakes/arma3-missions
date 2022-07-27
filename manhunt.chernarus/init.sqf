//apply time and weather settings
setDate [2018, 10, 15, ("Time" call BIS_fnc_getParamValue), 0];
setTimeMultiplier ("TimeScale" call BIS_fnc_getParamValue);
0 setOvercast ("OvercastPercent" call BIS_fnc_getParamValue)/100;
0 setFog ("FogPercent" call BIS_fnc_getParamValue)/100;
0 setRain ("RainPercent" call BIS_fnc_getParamValue)/100;
forceWeatherChange;

//global variables
AI_SKILL = ("MaxEnemySkill" call BIS_fnc_getParamValue)/10;
REVEAL_WARLORD_MEETING = false;
CONFIRMED_KILL = false;
private _extractVeh = extract;
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
private _wreckClassnames = ["Land_Wreck_Skodovka_F", "Land_Wreck_Truck_F", "Land_Wreck_Car2_F", "Land_Wreck_HMMWV_F", 
	"Land_Wreck_Car_F", "Land_Wreck_Car3_F", "Land_Wreck_Van_F", "Land_Wreck_Offroad_F", "Land_Wreck_Offroad2_F",
	"Land_Wreck_UAZ_F", "Land_Wreck_Ural_F", "Land_V3S_Wreck_F", "Land_Wreck_T72_hull_F", "Land_Wreck_T72_turret_F"];
private _wreckClassnamesCUP = ["BMP2Wreck", "LADAWreck", "JeepWreck1", "JeepWreck2", "JeepWreck3", "hiluxWreck", 
	"datsun01Wreck", "datsun02Wreck", "SKODAWreck", "UAZWreck"];
private _liveVehiclesCUP = ["CUP_C_Datsun", "CUP_C_Datsun_4seat", "CUP_C_Golf4_black", "CUP_C_Golf4_blue",
	"CUP_C_Golf4_white", "CUP_C_Golf4_yellow", "C_Offroad_02_unarmed_F", "CUP_C_Octavia_CIV", "C_Tractor_01_F", 
	"CUP_C_Skoda_CR_CIV", "CUP_C_Skoda_Blue_CIV", "CUP_C_Skoda_Green_CIV", "CUP_C_Skoda_Red_CIV", "CUP_C_Skoda_White_CIV", 
	"CUP_C_Lada_CIV", "CUP_C_Lada_Red_CIV", "CUP_C_Ural_Open_Civ_03", "CUP_C_Ural_Civ_03"];
private _graveClassnames = ["Mass_Grave"];

if (isServer) then
{
	private _startTime = diag_tickTime;

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

	private _extractMarker = [
		"extract", //var name
		getPos _extractVeh, //position
		localize "STR_MARKER_EXTRACT", //display name
		[1, 1], //size
		"ColorBLUFOR", //color string
		"ICON", //type
		"mil_pickup" //style
	] call SCO_fnc_createMarker;
	_extractVeh allowDamage false;
	_extractVeh lock true;

	//extract vehicle does not run out of fuel
	_extractVeh addEventHandler ["Fuel", {
		params ["_vehicle", "_hasFuel"];
		if (fuel _vehicle < 1.0) then
		{
			_vehicle setFuel 1.0;
		};
	}];

	//update marker for the boat since it is important to the mission
	[_extractMarker, _extractVeh] spawn
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
	[_doSpawnWrecks, (_wreckClassnames + _wreckClassnamesCUP), _doSpawnGraves, _graveClassnames] call SCO_fnc_generateMapClutter;

	//once an HQ location is found, mark it on the map and delete any mass graves near it
	private _possibleHQMarkers = ["objective_tent_"] call SCO_fnc_getMarkers;
	private _posHQ = getMarkerPos (selectRandom _possibleHQMarkers);
	_hqMarker setMarkerPos _posHQ;
	_hqMarker setMarkerAlpha 1; //show HQ marker now that it is finally set
	{
		deleteVehicle _x;
	} forEach nearestObjects [_posHQ, _graveClassnames, 100, true];

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
	private _hqDir = getDir (nearestBuilding _posHQ) + 90; //align it with a nearby building
	private _missionObjects = [_posHQ, _placementArray, 0, _hqDir] call SCO_fnc_createMissionBuilding;
	private _tent = _missionObjects select 0;
	private _intel = _missionObjects select 3;
	private _crate = _missionObjects select 17;

	["AmmoboxInit", [_crate, true, { (_this distance _target) < 10 }]] call BIS_fnc_arsenal;
	[_crate, [localize "STR_ACTION_HEAL", "(_this select 1) setDamage 0;"]] remoteExec ["addAction", 0, true];
	[_crate, [localize "STR_ACTION_AMMO", "functions\fn_refillWeapon.sqf", 4]] remoteExec ["addAction", 0, true];

	//create parked cars near HQ
	[getPos _tent, 3, (_conveyVehiclePool + _conveyVehiclePoolCUP), 5] call SCO_fnc_spawnParkedVehicles;

	//pick a meeting position
	private _possibleMeetingMarkers = ["objective_"] call SCO_fnc_getMarkers;
	private _meetingPosition = getMarkerPos (selectRandom _possibleMeetingMarkers);
	"meeting" setMarkerPos _meetingPosition;
	{
		deleteVehicle _x;
	} forEach nearestObjects [_meetingPosition, _graveClassnames, 100, true];

	//create meeting and set identity of warlord
	private _warlordUnit = [_meetingPosition, 4, 2, (_meetingUnitPool + _meetingUnitPoolCUP), AI_SKILL] call SCO_fnc_spawnRadialUnits;
	missionNamespace setVariable ["CONFIRMED_KILL", false, true];
	[_warlordUnit, "WhiteHead_24"] remoteExec ["setFace", 0, _warlordUnit];
	[_warlordUnit, "STAND", "RANDOM"] call BIS_fnc_ambientAnimCombat;
	_warlordUnit setName "Dmitri Kozlov";
	[_warlordUnit, [format [localize "STR_ACTION_CONFIRM", name _warlordUnit], {missionNamespace setVariable ["CONFIRMED_KILL", true, true];}, nil, 3, true, true, "", "true", 3, false, "", ""]] remoteExec ["addAction", 0, true];

	//create parked cars near meeting location
	[_meetingPosition, 4, (_conveyVehiclePool + _conveyVehiclePoolCUP), 5] call SCO_fnc_spawnParkedVehicles;

	//create tasks for players on a different thread
	private _taskManager = [_tent, _intel, _meetingPosition, _warlordUnit, _extractVeh] spawn SCO_fnc_manageTasks;

	//spawn enemy unit ground patrols
	[_meetingPosition, east, 6, _patrolUnitPool, [(AI_SKILL / 2), AI_SKILL], _patrol, 500] call SCO_fnc_spawnFootPatrolGroup;
	[getPos _tent, east, 6, _patrolUnitPool, [(AI_SKILL / 2), 1.0 min (AI_SKILL + 0.1)], _patrol, 50] call SCO_fnc_spawnFootPatrolGroup;

	//define all cities to spawn patrols in
	private _allTowns = nearestLocations [
		getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), 
		["Name", "NameVillage", "NameCity", "NameCityCapital"], worldSize];

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
	[west, _allTowns, east, _patrolUnitPool, AI_SKILL, "CityFootPatrolMultiplier" call BIS_fnc_getParamValue] spawn SCO_fnc_manageFootPatrols;
	[_allTowns, _conveyVehiclePool + _conveyVehiclePoolCUP, _numRegionVehicles, east] spawn SCO_fnc_manageVehiclePatrols;

	private _numNearbyVehicles = "NearbyVehiclePatrol" call BIS_fnc_getParamValue;
	if (_numNearbyVehicles > 0) then
	{
		for "_i" from 1 to _numNearbyVehicles do
		{
			[_allTowns, _conveyVehiclePool + _conveyVehiclePoolCUP, east, west] spawn SCO_fnc_spawnRepeatingSingleVehiclePatrol;
		};
	};
	
	_stopTime = diag_tickTime;
	(format ["%1 sec to finish init.sqf", _stopTime - _startTime]) remoteExec ["systemChat", 0];
};
