//apply time and weather settings
setDate [2018, 10, 15, ("Time" call BIS_fnc_getParamValue), 0];
setTimeMultiplier ("TimeScale" call BIS_fnc_getParamValue);
0 setOvercast ("OvercastPercent" call BIS_fnc_getParamValue)/100;
0 setFog ("FogPercent" call BIS_fnc_getParamValue)/100;
0 setRain ("RainPercent" call BIS_fnc_getParamValue)/100;
forceWeatherChange;

//global variables
REVEAL_WARLORD_MEETING = false;
CONFIRMED_KILL = false;
private _extractVeh = extract;

//easily configurable variables
private _aiSkillRange = [(("MaxEnemySkill" call BIS_fnc_getParamValue)/10)-0.3 max 0, (("MaxEnemySkill" call BIS_fnc_getParamValue)/10)+0.1 min 1.0];
private _aiSkill = ("MaxEnemySkill" call BIS_fnc_getParamValue)/10;
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
]; //generated from a different script

if (isServer) then
{
	private _time1 = diag_tickTime;

	//hide all markers.
	//Not originally invisible because they are a pain to move in the editor when they are like that
	{
		_x setMarkerAlpha 0;
	} forEach (["objective_"] call SCO_fnc_getMarkers) + (["start_"] call SCO_fnc_getMarkers);

	//set up markers
	private _markerHQ = "confirmed";
	_markerHQ setMarkerAlpha 0; //initially hide HQ marker as it is not properly set
	"meeting" setMarkerAlpha 0;

	//create the respawn inventories
	{
		[west, _x] call BIS_fnc_addRespawnInventory;
	} foreach ["Unit1", "Unit2", "Unit3", "Unit4", "Unit5", "Unit6", "Unit7", "Unit8"];

	//set up insertion point and extraction vehicle
	//get location from parameters and check if it is valid (it should be)
	private _spawnLocationID = "StartPosition" call BIS_fnc_getParamValue;
	private _spawnMarker = format ["start_%1", _spawnLocationID];
	if (!([_spawnMarker, [0,0,0]] call BIS_fnc_areEqual)) then
	{
		extract setPos (getMarkerPos _spawnMarker);
		extract setVectorUp surfaceNormal getPos extract;
		arsenal setPos (extract getRelPos [5, 250]);
		arsenal setVectorUp surfaceNormal getPos arsenal;
		lamp setPos (arsenal getRelPos [2, random 360]);
		lamp setVectorUp surfaceNormal getPos lamp;
		"respawn_west" setMarkerPos (extract getRelPos [10, 200]);
	};
	private _posSpawn = getMarkerPos "respawn_west";
	{
		_x setPos _posSpawn; 
	} forEach units west;

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
	//end setup for insertion point

	private _time2 = diag_tickTime;

	//populate the map with random graves and wrecks
	private _doSpawnWrecks = [("ClutterWreck" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean;
	private _doSpawnGraves = [("ClutterGraves" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean;
	[_doSpawnWrecks, (_wreckClassnames + _wreckClassnamesCUP), _doSpawnGraves, _graveClassnames] call SCO_fnc_generateMapClutter;

	private _time3 = diag_tickTime;

	//identify all valid markers for each type of objective
	private _minDistanceToObjective = "MinObjectiveDistance" call BIS_fnc_getParamValue;
	private _minDistanceFromHQ = "MinMeetingDistanceFromHQ" call BIS_fnc_getParamValue;
	private _nearestPickLimit = "PickNNearestObjectives" call BIS_fnc_getParamValue;
	private _allObjectiveHQMarkers = ["objective_tent_"] call SCO_fnc_getMarkers;
	private _allObjectiveMeetingMarkers = ["objective_meet_"] call SCO_fnc_getMarkers;
	private _allObjectiveMarkers = _allObjectiveHQMarkers + _allObjectiveMeetingMarkers;
	private _invalidObjectiveMarkers = ["objective_", _posSpawn, _minDistanceToObjective] call SCO_fnc_getMarkers;

	//of the set (_allObjectiveMarkers - _invalidObjectiveMarkers), get the N closest markers to the spawn point
	private _validHQMarkers = [_allObjectiveHQMarkers - _invalidObjectiveMarkers, [_posSpawn], { _input0 distance2D getMarkerPos _x }, "ASCEND"] call BIS_fnc_sortBy;
	_validHQMarkers resize (_nearestPickLimit min count _validHQMarkers);
	private _posHQ = getMarkerPos (selectRandom _validHQMarkers);

	//build a list of markers that are too close to the spawn or the HQ tent
	private _invalidMeetingMarkers = (["objective_", _posHQ, _minDistanceFromHQ] call SCO_fnc_getMarkers);
	{
		_invalidMeetingMarkers pushBackUnique _x;
	} forEach _invalidObjectiveMarkers;

	//of the set (_allObjectiveMarkers - _invalidMeetingMarkers), get the N closest markers to the spawn point
	private _validMeetingMarkers = [_allObjectiveMarkers - _invalidMeetingMarkers, [_posHQ], { _input0 distance2D getMarkerPos _x }, "ASCEND"] call BIS_fnc_sortBy;
	_validMeetingMarkers resize (_nearestPickLimit min count _validMeetingMarkers);
	private _posMeeting = getMarkerPos (selectRandom _validMeetingMarkers);

	private _expectedMissionRadius = ((_posSpawn distance2D _posMeeting) max (_posSpawn distance2D _posHQ))*1.2;
	//end getting all objective positions

	private _time4 = diag_tickTime;

	//set up HQ tent
	_markerHQ setMarkerPos _posHQ;
	_markerHQ setMarkerAlpha 1; //show HQ marker now that it is finally set
	{
		deleteVehicle _x;
	} forEach nearestObjects [_posHQ, _graveClassnames, 100, true];

	//create the tent and get the tent object and intel within it
	private _hqDir = getDir (nearestBuilding _posHQ) + 90; //align it with a nearby building
	private _missionObjects = [_posHQ, _placementArray, 0, _hqDir] call SCO_fnc_createMissionBuilding;
	private _tent = _missionObjects select 0;
	private _intel = _missionObjects select 3;
	private _crate = _missionObjects select 17;

	["AmmoboxInit", [_crate, true, { (_this distance _target) < 10 }]] call BIS_fnc_arsenal;
	[_crate, [localize "STR_ACTION_HEAL", "(_this select 1) setDamage 0;"]] remoteExec ["addAction", 0, true];
	[_crate, [localize "STR_ACTION_AMMO", "functions\fn_refillWeapon.sqf", 4]] remoteExec ["addAction", 0, true];

	[getPos _tent, 3, (_conveyVehiclePool + _conveyVehiclePoolCUP), 5] call SCO_fnc_spawnParkedVehicles;
	//end setting up HQ tent

	private _time5 = diag_tickTime;

	//set up meeting
	"meeting" setMarkerPos _posMeeting;
	{
		deleteVehicle _x;
	} forEach nearestObjects [_posMeeting, _graveClassnames, 100, true];

	//create meeting and set identity of warlord
	private _warlordUnit = [_posMeeting, 4, 2, (_meetingUnitPool + _meetingUnitPoolCUP), (_aiSkill + 0.3 max 1.0)] call SCO_fnc_spawnRadialUnits;
	missionNamespace setVariable ["CONFIRMED_KILL", false, true];
	[_warlordUnit, "WhiteHead_24"] remoteExec ["setFace", 0, _warlordUnit];
	[_warlordUnit, "STAND", "RANDOM"] call BIS_fnc_ambientAnimCombat;
	_warlordUnit setName "Dmitri Kozlov";
	[_warlordUnit, [format [localize "STR_ACTION_CONFIRM", name _warlordUnit], {missionNamespace setVariable ["CONFIRMED_KILL", true, true];}, nil, 3, true, true, "", "true", 3, false, "", ""]] remoteExec ["addAction", 0, true];

	//create parked cars near meeting location
	[_posMeeting, 4, (_conveyVehiclePool + _conveyVehiclePoolCUP), 5] call SCO_fnc_spawnParkedVehicles;
	//end setting up meeting

	private _time6 = diag_tickTime;

	//define all cities to spawn patrols in. The expected maximum mission area minus areas very close to spawn
	private _poiTypes = ["Name", "NameVillage", "NameCity", "NameCityCapital", "NameLocal", "Airport"];
	private _allMissionPOI = nearestLocations [_posSpawn, _poiTypes, _expectedMissionRadius] -
		nearestLocations [_posSpawn, _poiTypes, 500];

	{
		[
			format ["t%1", _forEachIndex], //var name
			locationPosition _x, //position
			text _x, //display name
			size _x, //size
			"ColorOpfor", //color string
			"ELLIPSE", //type
			"SolidBorder", //style
			0, 0.5
		] call SCO_fnc_createMarker;
	} forEach _allMissionPOI;

	//set up management threads for tasks, patrols and vehicles
	private _numRegionVehicles = (("AreaVehiclePatrolDensity" call BIS_fnc_getParamValue) * (count _allMissionPOI)) min 50;

	//spawn threads
	[_tent, _intel, _posMeeting, _warlordUnit, _extractVeh, _patrolUnitPool] spawn SCO_fnc_manageTasks;
	[_posMeeting, east, 6, _patrolUnitPool, _aiSkillRange, 0, 500] call SCO_fnc_spawnFootPatrolGroup;
	[getPos _tent, east, 6, _patrolUnitPool, _aiSkillRange, 0, 50] call SCO_fnc_spawnFootPatrolGroup;
	[west, _allMissionPOI, east, _patrolUnitPool, _aiSkillRange, 5, "POIFootPatrolMultiplier" call BIS_fnc_getParamValue] spawn SCO_fnc_manageFootPatrolsPOI;
	[_allMissionPOI, _conveyVehiclePool + _conveyVehiclePoolCUP, _numRegionVehicles, east] spawn SCO_fnc_manageVehiclePatrols;

	private _numNearbyVehicles = "NearbyVehiclePatrol" call BIS_fnc_getParamValue;
	if (_numNearbyVehicles > 0) then
	{
		for "_i" from 1 to _numNearbyVehicles do
		{
			[_allMissionPOI, _conveyVehiclePool + _conveyVehiclePoolCUP, east, west] spawn SCO_fnc_manageTargetedVehiclePatrol;
		};
	};

	private _numNearbyPatrols = "NearbyFootPatrol" call BIS_fnc_getParamValue;
	if (_numNearbyPatrols > 0) then
	{
		for "_i" from 1 to _numNearbyPatrols do
		{
			[_posSpawn, _patrolUnitPool] spawn SCO_fnc_manageTargetedFootPatrol;
		};
	};

	//generate grid for region patrols
	private _mapPatrolGridMarkers = [];
	private _step = "AreaFootPatrolDensity" call BIS_fnc_getParamValue;
	if (_step > 0) then
	{
		private _offset = _step/2;
		private _spawnDistance = 800;
		for "_xAxis" from _offset to worldSize step _step do
		{
			for "_yAxis" from _offset to worldSize step _step do
			{
				private _pos = [_xAxis, _yAxis];
				if (getTerrainHeightASL _pos > 0 and (_pos distance2D _posSpawn > _spawnDistance)) then
				{
					private _m = [
						format ["patrol-%1-%2", _xAxis, _yAxis], //var name
						_pos, //position
						"", //display name
						[0.5, 0.5], //size
						"ColorUnknown", //color string
						"ICON", //type
						"mil_dot", //style
						0, 0
					] call SCO_fnc_createMarker;
					_mapPatrolGridMarkers pushBack _m;
					};
			};
		};
		[west, _mapPatrolGridMarkers, east, _patrolUnitPool, _aiSkillRange, 4, _spawnDistance] spawn SCO_fnc_manageFootPatrolsGrid;
	};
	//end setting up management threads

	//print timings
	private _time7 = diag_tickTime;
	[format ["init.sqf: %1sec to build spawn", _time2 - _time1]] call SCO_fnc_printDebug;
	[format ["init.sqf: %1sec to generate clutter", _time3 - _time2]] call SCO_fnc_printDebug;
	[format ["init.sqf: %1sec to identify objective markers", _time4 - _time3]] call SCO_fnc_printDebug;
	[format ["init.sqf: %1sec to build HQ tent", _time5 - _time4]] call SCO_fnc_printDebug;
	[format ["init.sqf: %1sec to build meeting", _time6 - _time5]] call SCO_fnc_printDebug;
	[format ["init.sqf: %1sec to start management threads", _time7 - _time6]] call SCO_fnc_printDebug;

	private _debugMode = [("Debug" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean;
	if (_debugMode) then
	{
		{
			_x setMarkerAlpha 1;
		} forEach _mapPatrolGridMarkers;
		{
			_x setMarkerAlpha 1;
			_x setMarkerColor "ColorWhite";
			_x setMarkerType "mil_dot";
		} forEach (["objective_"] call SCO_fnc_getMarkers);
		{
			_x setMarkerColor "ColorRed";
		} forEach _invalidObjectiveMarkers;
		{
			_x setMarkerColor "ColorBlue";
			_x setMarkerType "mil_triangle";
		} forEach _validHQMarkers;
		{
			if (getMarkerColor _x == "ColorRed") then
			{
				_x setMarkerColor "ColorBrown";
			}
			else
			{
				_x setMarkerColor "ColorOrange";
			};
		} forEach _invalidMeetingMarkers;
		{
			_x setMarkerColor "ColorGreen";
		} forEach _validMeetingMarkers;
		[
			"spawnradius", //var name
			_posSpawn, //position
			"", //display name
			[_minDistanceToObjective, _minDistanceToObjective], //size
			"ColorBlufor", //color string
			"ELLIPSE", //type
			"Border" //style
		] call SCO_fnc_createMarker;

		[
			"hqradius", //var name
			_posHQ, //position
			"", //display name
			[_minDistanceFromHQ, _minDistanceFromHQ], //size
			"ColorBlack", //color string
			"ELLIPSE", //type
			"Border" //style
		] call SCO_fnc_createMarker;

		[
			"missionradius", //var name
			_posSpawn, //position
			"", //display name
			[_expectedMissionRadius, _expectedMissionRadius], //size
			"ColorPink", //color string
			"ELLIPSE", //type
			"Border" //style
		] call SCO_fnc_createMarker;
	};
};
