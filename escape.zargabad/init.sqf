//apply time and weather settings
setDate [2009, 10, 15, ("Time" call BIS_fnc_getParamValue), 0];
setTimeMultiplier ("TimeScale" call BIS_fnc_getParamValue);
0 setOvercast ("OvercastPercent" call BIS_fnc_getParamValue)/100;
0 setFog ("FogPercent" call BIS_fnc_getParamValue)/100;
0 setRain ("RainPercent" call BIS_fnc_getParamValue)/100;
forceWeatherChange;

//global variables
REVEAL_WARLORD_MEETING = false;
CONFIRMED_KILL = false;

private _aiSkillRange = [(("MaxEnemySkill" call BIS_fnc_getParamValue)/10)-0.3 max 0, (("MaxEnemySkill" call BIS_fnc_getParamValue)/10)+0.1 min 1.0];
private _aiSkill = ("MaxEnemySkill" call BIS_fnc_getParamValue)/10;
private _numAATargets = ("NumberAA" call BIS_fnc_getParamValue);
private _numDemoTargets = ("NumberTargets" call BIS_fnc_getParamValue);

//easily configurable variables
private _parkedVehiclesHighPool = ["C_Hatchback_01_F","C_Hatchback_01_sport_F","C_SUV_01_F"];
private _parkedVehiclesLowPool = ["C_Offroad_01_F","C_Offroad_01_covered_F","C_Van_01_fuel_F","C_Van_01_transport_F","C_Van_01_box_F","C_Truck_02_transport_F","C_Truck_02_covered_F","C_Truck_02_fuel_F","C_Truck_02_box_F"];
private _parkedVehiclesDesertPool = ["CUP_C_S1203_CIV","CUP_C_S1203_Ambulance_CIV","CUP_C_Volha_Gray_TKCIV","CUP_C_Volha_Blue_TKCIV","CUP_C_Volha_Limo_TKCIV","CUP_O_Hilux_unarmed_TK_CIV_Red","CUP_O_Hilux_unarmed_TK_CIV_White","CUP_O_Hilux_unarmed_TK_CIV_Tan","CUP_C_Ikarus_TKC","CUP_C_V3S_Open_TKC","CUP_C_UAZ_Unarmed_TK_CIV","CUP_C_UAZ_Open_TK_CIV","CUP_C_Lada_TK_CIV","CUP_C_Lada_GreenTK_CIV","CUP_C_Lada_TK2_CIV"];
private _parkedVehiclesEuropePool = ["CUP_C_Skoda_CR_CIV","CUP_C_Skoda_Blue_CIV","CUP_C_Skoda_Green_CIV","CUP_C_Skoda_Red_CIV","CUP_C_Skoda_White_CIV","CUP_C_Datsun_Covered","CUP_C_Datsun_Plain","CUP_C_Datsun_Tubeframe","CUP_C_Volha_CR_CIV","CUP_C_Lada_CIV","CUP_LADA_LM_CIV","CUP_C_Lada_Red_CIV","CUP_C_Lada_White_CIV","CUP_C_SUV_CIV","CUP_C_Ikarus_Chernarus","CUP_C_Golf4_red_Civ","CUP_C_Golf4_CR_Civ","CUP_C_Golf4_Sport_CR_Civ"];
private _convoyVehicle2035Pool = ["O_MRAP_02_hmg_F","O_LSV_02_armed_F","O_LSV_02_AT_F","O_G_Offroad_01_armed_F"];
private _convoyVehicleRussiaPool = ["CUP_O_UAZ_Open_RU","CUP_O_UAZ_MG_CSAT","CUP_O_UAZ_AGS30_CSAT","CUP_O_Hilux_M2_OPF_G_F","CUP_O_Hilux_AGS30_OPF_G_F","CUP_O_Hilux_unarmed_OPF_G_F"];
private _convoyVehicleDesertPool = ["CUP_O_Hilux_DSHKM_TK_INS","CUP_O_Hilux_ilga_TK_INS","CUP_O_Hilux_M2_TK_INS","CUP_O_Hilux_metis_TK_INS","CUP_O_LR_MG_TKM","CUP_O_LR_SPG9_TKM","CUP_O_Hilux_zu23_TK_INS","CUP_O_BTR40_MG_TKM","CUP_I_Datsun_PK_TK","CUP_I_Datsun_PK_TK_Random","CUP_B_HMMWV_M2_GPK_USA"];
private _convoyTankRussiaPool = ["CUP_O_T72_RU", "CUP_O_T90_RU", "CUP_O_BRDM2_RUS", "CUP_O_BMP2_RU", "CUP_O_GAZ_Vodnik_PK_RU"];
private _convoyTankDesertPool = ["CUP_I_BRDM2_TK_Gue","CUP_O_T55_TK","CUP_O_T72_TK"];
private _airPatrolRussiaPool = ["CUP_O_Mi8_RU", "CUP_O_Mi8_RU", "CUP_O_Mi8AMT_RU", "CUP_O_Ka52_RU"];
private _airPatrolDesertPool = ["CUP_O_UH1H_gunship_TKA","CUP_O_UH1H_slick_TKA","CUP_O_Mi24_D_Dynamic_TK"];
private _patrolUnitRussiaPool = ["CUP_O_INS_Soldier_AA","CUP_O_INS_Soldier_Ammo","CUP_O_INS_Soldier_AT","CUP_O_INS_Soldier_AR","CUP_O_INS_Soldier_Engineer","CUP_O_INS_Soldier_MG","CUP_O_INS_Soldier","CUP_O_INS_Soldier_AK74","CUP_O_INS_Soldier_LAT","CUP_O_INS_Sniper","CUP_O_INS_Villager3","CUP_O_INS_Woodlander3","CUP_O_INS_Worker2"];
private _patrolUnitDesertPool = ["CUP_O_TK_INS_Soldier_AA","CUP_O_TK_INS_Soldier_AR","CUP_O_TK_INS_Guerilla_Medic","CUP_O_TK_INS_Soldier_MG","CUP_O_TK_INS_Bomber","CUP_O_TK_INS_Mechanic","CUP_O_TK_INS_Soldier_GL","CUP_O_TK_INS_Soldier","CUP_O_TK_INS_Soldier_FNFAL","CUP_O_TK_INS_Soldier_Enfield","CUP_O_TK_INS_Soldier_AAT","CUP_O_TK_INS_Soldier_AT","CUP_O_TK_INS_Sniper","CUP_O_TK_INS_Soldier_TL","CUP_O_TK_Commander","CUP_O_TK_Soldier,AT","CUP_O_TK_Soldier_AR","CUP_O_TK_SpecOps_MG","CUP_O_TK_SpecOps","CUP_O_TK_SpecOps_TL"];
private _aaDesertPool = [];

if (isServer) then
{
	private _debugMode = [("Debug" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean or is3DENPreview;
	private _timestampTuples = [];
	_timestampTuples pushBack [0, "Start of isServer"];

	//create the respawn inventories
	{
		[independent, _x] call BIS_fnc_addRespawnInventory;
	} forEach ["Light1", "Light2", "Light3"];

	private _possibleAAMarkers = ["aa_"] call SCO_fnc_getMarkers;
	private _possibleDemoMarkers = ["cache_"] call SCO_fnc_getMarkers;

	//hide all markers.
	//Not originally invisible because they are a pain to move in the editor when they are like that
	{
		_x setMarkerAlpha 0;
	} forEach _possibleAAMarkers + _possibleDemoMarkers;

	private _selectedAA = [_possibleAAMarkers, _numAATargets] call SCO_fnc_pickFromArray;
	private _selectedDemo = [_possibleDemoMarkers, _numDemoTargets] call SCO_fnc_pickFromArray;
	[format ["AA:%1, Demo:%2", _selectedAA, _selectedDemo]] call SCO_fnc_printDebug;

	private _posSpawn = getMarkerPos "respawn_guerrila_0";
	{
		_x setPos _posSpawn; 
	} forEach units independent;

	_timestampTuples pushBack [diag_tickTime, "Done setting up markers"];

	// BEGIN spawn parked vehicles
	// get the expected mission area and radius
	private _mapCenterMarker = "map_center";
	private _missionRadius = 700;
	{
		private _thisDistance = getMarkerPos _x distance2D getMarkerPos "map_center";
		if (_thisDistance > _missionRadius) then
		{
			_missionRadius = _thisDistance;
		};
	} forEach _selectedAA + _selectedDemo;
	_missionRadius = _missionRadius + 100;
	_mapCenterMarker setMarkerSize [_missionRadius, _missionRadius];

	// find "populated" zones in mission area and get roads to spawn vehicles
	private _poiTypes = ["Name", "NameVillage", "NameCity", "NameCityCapital", "NameLocal", "Airport", 
		"Hill", "RockArea", "VegetationBroadleaf", "VegetationFir", "VegetationPalm", "VegetationVineyard", "ViewPoint"];
	private _allMissionPOI = nearestLocations [getMarkerPos _mapCenterMarker, _poiTypes, _missionRadius * 1.2] - nearestLocations [_posSpawn, _poiTypes, 500];
	private _parkedVehicleSegments = [];
	{
		// create marker for poi
		private _size = size _x vectorMultiply 2;
		[format ["poi-%1", _forEachIndex], locationPosition _x, text _x, _size, "ColorOpfor", "ELLIPSE", "Border"] call SCO_fnc_createMarker;
		// get all roads
		private _roads = (locationPosition _x) nearRoads (_size select 0);
		private _area = 3.14 * (_size select 0)^2;
		private _numParkingPositions = ceil random [count _roads/20, count _roads/20, ceil (_area/16000)];
		private _chosen = [_roads, _numParkingPositions] call SCO_fnc_pickFromArray;
		_parkedVehicleSegments append _chosen;
		[format ["POI %1 with %2 roads, A=%3 sq m, Score=%4.", text _x, count _roads, _area, _numParkingPositions]] call SCO_fnc_printDebug;
	} forEach _allMissionPOI;

	_parkedVehicleSegments = flatten _parkedVehicleSegments;
	_timestampTuples pushBack [diag_tickTime, "Done getting mission area"];

	// perform the vehicle spawning
	{
		getRoadInfo _x params ["_mapType", "_width", "_isPedestrian", "_texture", "_textureEnd", "_material", "_begPos", "_endPos", "_isBridge"];
		private _thisRoadSegmentPos = (_begPos vectorAdd _endPos) vectorMultiply 0.5;
		private _thisRoadSegmentDir = _begPos getDir _endPos;
		if (_debugMode) then
		{
			[
				format ["parked-vehicle-centeroid-%1", _forEachIndex], //var name
				_thisRoadSegmentPos, //position
				"", //display name
				[0.5, 0.5], //size
				"ColorGreen", //color string
				"ICON", //type
				"mil_triangle", //style
				_thisRoadSegmentDir
			] call SCO_fnc_createMarker;
			[_thisRoadSegmentPos, ceil random 3, _parkedVehiclesDesertPool, 5] call SCO_fnc_spawnParkedVehicles;
		};
	} forEach _parkedVehicleSegments;
	
	_timestampTuples pushBack [diag_tickTime, "Done spawning parked vehicles"];

	//setup vehicle patrols
	private _numRegionVehicles = (("AreaVehiclePatrolDensity" call BIS_fnc_getParamValue) * (count _allMissionPOI)) min 10;
	[_allMissionPOI, _convoyTankDesertPool + _convoyVehicleDesertPool, _numRegionVehicles, east] spawn SCO_fnc_manageVehiclePatrols;

	//setup foot patrols for all demo targets
	{
		[getMarkerPos _x, east, (ceil random 4) + 4, _patrolUnitDesertPool, _aiSkillRange, 0, 200] call SCO_fnc_spawnFootPatrolGroup;
		if (_debugMode) then
		{
			[
				format ["demo-site-%1", _forEachIndex], //var name
				getMarkerPos _x, //position
				"Demo", //display name
				[0.5, 0.5], //size
				"ColorRed", //color string
				"ICON", //type
				"mil_destroy" //style
			] call SCO_fnc_createMarker;
		};
	} forEach _selectedDemo;
	{
		[getMarkerPos _x, east, (ceil random 4) + 4, _patrolUnitDesertPool, _aiSkillRange, 0, 300] call SCO_fnc_spawnFootPatrolGroup;
		if (_debugMode) then
		{
			[
				format ["aa-site-%1", _forEachIndex], //var name
				getMarkerPos _x, //position
				"AA", //display name
				[0.5, 0.5], //size
				"ColorYellow", //color string
				"ICON", //type
				"mil_destroy" //style
			] call SCO_fnc_createMarker;
		};
	} forEach _selectedAA;

	// [_tent, _intel, _posMeeting, _warlordUnit, _extractVeh, _patrolUnitPool, _convoyVehiclePool + _convoyVehiclePoolCUP] spawn SCO_fnc_manageTasks;
	
	[independent, _allMissionPOI, east, _patrolUnitDesertPool, _aiSkillRange, 5, "POIFootPatrolMultiplier" call BIS_fnc_getParamValue] spawn SCO_fnc_manageFootPatrolsPOI;
	
	// setup air patrols
	[_mapCenterMarker, _missionRadius*2, _posSpawn, 1000, _airPatrolDesertPool, "NumberAirPatrols" call BIS_fnc_getParamValue, east] spawn SCO_fnc_manageAirPatrols;

	// setup vehicle patrols that target players
	private _numNearbyVehicles = "NearbyVehiclePatrol" call BIS_fnc_getParamValue;
	if (_numNearbyVehicles > 0) then
	{
		for "_i" from 1 to _numNearbyVehicles do
		{
			[_allMissionPOI, _convoyVehicleDesertPool, east, independent] spawn SCO_fnc_manageTargetedVehiclePatrol;
		};
	};

	// setup foot patrols that target players
	private _numNearbyPatrols = "NearbyFootPatrol" call BIS_fnc_getParamValue;
	private _footPatrolInterval = "TargetedFootPatrolInterval" call BIS_fnc_getParamValue;
	if (_numNearbyPatrols > 0 and _footPatrolInterval > 0) then
	{
		for "_i" from 1 to _numNearbyPatrols do
		{
			[_posSpawn, _patrolUnitDesertPool, _aiSkillRange, _footPatrolInterval] spawn SCO_fnc_manageTargetedFootPatrol;
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
				private _vis = 1;
				if (!_debugMode) then { _vis = 0 };
				if (getTerrainHeightASL _pos > 0 and (_pos distance2D _posSpawn > _spawnDistance)) then
				{
					[
						format ["patrol-%1-%2", _xAxis, _yAxis], //var name
						_pos, //position
						"", //display name
						[0.5, 0.5], //size
						"ColorRed", //color string
						"ICON", //type
						"mil_box", //style
						0, _vis
					] call SCO_fnc_createMarker;
				};
			};
		};
		[independent, _mapPatrolGridMarkers, east, _patrolUnitDesertPool, _aiSkillRange, 4, _spawnDistance] spawn SCO_fnc_manageFootPatrolsGrid;
	};

	_timestampTuples pushBack [diag_tickTime, "Done spawning all patrol types"];

	// setup functionality to move a respawn point every _interval seconds
	private _interval = "DynamicRespawnUpdateInterval" call BIS_fnc_getParamValue;
	if (_interval > 0) then
	{
		private _dynamicRespawnMarker = [
				"respawn_guerrila_dynamic", //var name
				_posSpawn, //position
				"Dynamic Respawn", //display name
				[1, 1], //size
				"ColorBlufor", //color string
				"ICON", //type
				"respawn_inf" //style
			] call SCO_fnc_createMarker;
			
		private _dynamicRespawnMarkerManager = [_dynamicRespawnMarker, _interval] spawn
		{
			params ["_marker", "_interval"];
			["Starting dynamic respawn marker manager"] call SCO_fnc_printDebug;

			while {true} do
			{
				sleep _interval;
				private _allPlayers = playableUnits;
				if (count _allPlayers == 0) then { continue; };

				//calculate 2D centroid of all players
				private _sum = [0, 0, 0];
				{
					_sum = _sum vectorAdd getPos _x; 
				} forEach _allPlayers;
				private _newPos = _sum vectorMultiply (1/(count _allPlayers));
				private _safePos = [_newPos, 0, 50, 5, 0, 20, 0, [], [_newPos, _newPos]] call BIS_fnc_findSafePos;

				_marker setMarkerPos _safePos;
				[format ["Dynamic respawn marker updated to %1 based on %2 units.", _newPos, count _allPlayers]] call SCO_fnc_printDebug;
			};
		};
	};

	_timestampTuples pushBack [diag_tickTime, "Done creating dynamic respawn marker"];
	//end setting up management threads

	//print timings
	private _prevTime = 0;
	{
		[format ["%1sec: %2", (_x select 0) - _prevTime, _x select 1]] call SCO_fnc_printDebug;
		_prevTime = _x select 0;
	} forEach _timestampTuples;
};
