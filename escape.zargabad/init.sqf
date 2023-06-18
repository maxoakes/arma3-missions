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
private _parkedVehiclesDesertPool = ["CUP_C_S1203_CIV","CUP_C_S1203_Ambulance_CIV","CUP_C_Volha_Gray_TKCIV","CUP_C_Volha_Blue_TKCIV","CUP_C_Volha_Limo_TKCIV","CUP_O_Hilux_unarmed_TK_CIV_Red","CUP_O_Hilux_unarmed_TK_CIV_White","CUP_O_Hilux_unarmed_TK_CIV_Tan","CUP_C_V3S_Open_TKC","CUP_C_UAZ_Unarmed_TK_CIV","CUP_C_UAZ_Open_TK_CIV","CUP_C_Lada_TK_CIV","CUP_C_Lada_GreenTK_CIV","CUP_C_Lada_TK2_CIV"];
private _parkedVehiclesEuropePool = ["CUP_C_Skoda_CR_CIV","CUP_C_Skoda_Blue_CIV","CUP_C_Skoda_Green_CIV","CUP_C_Skoda_Red_CIV","CUP_C_Skoda_White_CIV","CUP_C_Datsun_Covered","CUP_C_Datsun_Plain","CUP_C_Datsun_Tubeframe","CUP_C_Volha_CR_CIV","CUP_C_Lada_CIV","CUP_LADA_LM_CIV","CUP_C_Lada_Red_CIV","CUP_C_Lada_White_CIV","CUP_C_SUV_CIV","CUP_C_Golf4_red_Civ","CUP_C_Golf4_CR_Civ","CUP_C_Golf4_Sport_CR_Civ"];
private _convoyVehicle2035Pool = ["O_MRAP_02_hmg_F","O_LSV_02_armed_F","O_LSV_02_AT_F","O_G_Offroad_01_armed_F"];
private _convoyVehicleRussiaPool = ["CUP_O_UAZ_Open_RU","CUP_O_UAZ_MG_CSAT","CUP_O_UAZ_AGS30_CSAT","CUP_O_Hilux_M2_OPF_G_F","CUP_O_Hilux_AGS30_OPF_G_F","CUP_O_Hilux_unarmed_OPF_G_F"];
private _convoyVehicleDesertPool = ["CUP_O_Hilux_DSHKM_TK_INS","CUP_O_Hilux_ilga_TK_INS","CUP_O_Hilux_M2_TK_INS","CUP_O_Hilux_metis_TK_INS","CUP_O_LR_MG_TKM","CUP_O_LR_SPG9_TKM","CUP_O_Hilux_zu23_TK_INS","CUP_O_BTR40_MG_TKM","CUP_I_Datsun_PK_TK","CUP_I_Datsun_PK_TK_Random"];
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
	private _resupplyMarkers = ["resupply_"] call SCO_fnc_getMarkers;

	//hide all markers.
	//Not originally invisible because they are a pain to move in the editor when they are like that
	{
		_x setMarkerAlpha 0;
	} forEach _possibleAAMarkers + _possibleDemoMarkers + _resupplyMarkers;

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
		private _numParkingPositions = ceil random [count _roads/30, count _roads/25, ceil (_area/24000)];
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

	// spawn resupply caches
	private _numResupplyCaches = "NumberResupplyCaches" call BIS_fnc_getParamValue;
	if (_numResupplyCaches > 0) then
	{
		private _resupplyUS = [
			["CUP_BOX_US_ARMY_AmmoVeh_F",[0,0,-1.72329],0,[3987.05,4012.98,5]],
			["CUP_BOX_US_ARMY_Support_F",[1.41089,-0.0612887,-1.72329],179.999,[3988.47,4012.92,5]],
			["CUP_BOX_US_ARMY_Wps_F",[-1.46216,-0.824713,-1.72329],360,[3985.59,4012.16,5]],
			["CUP_BOX_US_ARMY_WpsSpecial_F",[-0.896484,1.5017,-1.72652],0.00484826,[3986.16,4014.48,4.99677]],
			["CUP_BOX_US_ARMY_AmmoOrd_F",[-1.74341,0.724848,-1.72329],0.00101044,[3985.31,4013.71,5]],
			["CUP_BOX_US_ARMY_WpsLaunch_F",[1.65015,-1.26344,-1.72328],300,[3988.7,4011.72,5]],
			["Box_NATO_Equip_F",[0.268799,-1.88477,-1.72321],90.0112,[3987.32,4011.1,5.00008]],
			["Box_B_UAV_06_medical_F",[-1.42017,-1.96607,-1.07671],0.0125795,[3985.63,4011.02,5.64657]],
			["Land_WoodenCrate_01_F",[-1.05444,-1.98194,-1.72325],269.995,[3986,4011,5.00004]],
			["CUP_B_M2StaticMG_US",[1.37061,2.19945,-1.73978],9.82444,[3988.43,4015.18,4.98351]],
			["CUP_BOX_US_ARMY_Grenades_F",[1.96484,1.031,-1.72329],183.238,[3989.02,4014.01,5]],
			["CUP_BOX_US_ARMY_Ammo_F",[2.79883,0.84203,-1.72329],93.8812,[3989.85,4013.82,5]],
			["CUP_B_M1151_M2_USA",[3.94434,-3.98146,-1.70907],216.535,[3991,4009,5.01421]]
		];

		private _resupplyTakistan = [
			["Box_FIA_Ammo_F",[0,0,-1.36077],0.00126176,[3957.82,4012.72,5]],
			["CUP_BOX_TKGUE_Wps_F",[-0.447266,2.26856,-1.36078],270.002,[3957.38,4014.99,5]],
			["CUP_BOX_TK_MILITIA_Ammo_F",[0.894775,2.11112,-1.05001],14.9981,[3958.72,4014.83,5.31075]],
			["CUP_BOX_TK_MILITIA_AmmoOrd_F",[0.850342,2.15848,-1.36068],270,[3958.67,4014.88,5.00009]],
			["CUP_BOX_TKGUE_Ammo_F",[1.78809,1.47637,-1.36076],90.0014,[3959.61,4014.19,5]],
			["Box_FIA_Support_F",[2.53711,-1.00555,-1.36075],135,[3960.36,4011.71,5]],
			["CUP_BOX_TK_MILITIA_Uniforms_F",[-2.63013,0.696487,-1.36079],0.0003189,[3955.19,4013.41,5]],
			["CUP_BOX_TKGUE_WpsLaunch_F",[-1.14087,-2.95973,-1.36077],90,[3956.68,4009.76,5]],
			["CUP_BOX_TKGUE_WpsSpecial_F",[-2.39868,-3.07255,-1.36401],90.0044,[3955.43,4009.64,4.99677]],
			["CUP_BOX_TK_MILITIA_Wps_F",[3.73682,0.78232,-1.39013],105.011,[3961.56,4013.5,4.97061]],
			["CUP_BOX_TKGUE_Uniforms_F",[-3.6687,1.18719,-1.36079],89.999,[3954.16,4013.9,5]],
			["CUP_BOX_TKGUE_WpsSpecial_F",[-3.75293,-1.84992,-1.36231],179.999,[3954.07,4010.87,4.99848]],
			["CUP_BOX_TK_MILITIA_WpsLaunch_F",[-4.26904,-0.150473,-1.39024],90.004,[3953.55,4012.57,4.97055]],
			["Box_CSAT_Equip_F",[-4.80029,-1.35263,-1.35837],180.449,[3953.02,4011.36,5.00242]]
		];

		private _resupplyUN = [
			["CUP_BOX_US_ARMY_AmmoVeh_F",[0,-9.84333e-005,-1.72329],360,[4020.45,4013.17,5]],
			["CUP_BOX_UN_Wps_F",[-2.0752,-0.799165,-1.72329],90.0022,[4018.37,4012.37,4.99999]],
			["CUP_BOX_UN_Ammo_F",[-1.88525,0.537504,-1.72328],270,[4018.56,4013.71,5]],
			["CUP_BOX_UN_WpsLaunch_F",[2.2854,-0.890974,-1.72329],90,[4022.73,4012.28,5]],
			["CUP_BOX_UN_Support_F",[-0.334229,-2.76719,-1.72328],0.0008673,[4020.12,4010.41,5]],
			["CUP_BOX_UN_Uniforms_F",[-2.23584,-1.31943,-1.72328],269.999,[4018.21,4011.85,5]],
			["CUP_BOX_UN_Grenades_F",[2.16479,1.35366,-1.72329],135.001,[4022.61,4014.53,5]],
			["CUP_BOX_UN_AmmoOrd_F",[2.81323,0.724991,-1.72329],134.996,[4023.26,4013.9,5]],
			["CUP_BOX_UN_WpsSpecial_F",[-1.76416,-2.77988,-1.72652],90.0044,[4018.69,4010.39,4.99677]],
			["Box_NATO_Support_F",[-3.06055,-1.5892,-1.72328],179.995,[4017.39,4011.58,5]],
			["CUP_I_UAZ_MG_UN",[2.49414,-3.2213,-1.71552],240,[4022.94,4009.95,5.00776]]
		];

		private _resupplyScenes = [_resupplyUS, _resupplyTakistan, _resupplyUN];
		private _selectedResupply = [_resupplyMarkers, _numResupplyCaches] call SCO_fnc_pickFromArray;
		{
			private _selectedResupplyScene = _resupplyScenes # floor random count _resupplyScenes;
			private _selectedPos = getMarkerPos _x;
			private _resupplyDir = getDir (nearestBuilding _selectedPos) + 90; //align it with a nearby building
			private _objects = [_selectedPos, _selectedResupplyScene, 0, _resupplyDir, true, 1, true] call SCO_fnc_placeObjectsFromArray;
			[
				format ["resupply-site-%1", _forEachIndex], //var name
				_selectedPos, //position
				"Resupply", //display name
				[1, 1], //size
				"ColorBlue", //color string
				"ICON", //type
				"mil_flag" //style
			] call SCO_fnc_createMarker;
		} forEach _selectedResupply;
	};

	_timestampTuples pushBack [diag_tickTime, "Done spawning resupply caches"];

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

	private _enemyMode = "DebugSpawnPatrols" call BIS_fnc_getParamValue;
	if (_enemyMode == 1) then
	{
		//setup vehicle patrols
		private _numRegionVehicles = (("AreaVehiclePatrolDensity" call BIS_fnc_getParamValue) * (count _allMissionPOI)) min 10;
		[_allMissionPOI, _convoyTankDesertPool + _convoyVehicleDesertPool, _numRegionVehicles, east] spawn SCO_fnc_manageVehiclePatrols;

		// [_tent, _intel, _posMeeting, _warlordUnit, _extractVeh, _patrolUnitPool, _convoyVehiclePool + _convoyVehiclePoolCUP] spawn SCO_fnc_manageTasks;
		
		[independent, _allMissionPOI, east, _patrolUnitDesertPool, _aiSkillRange, 5, "POIFootPatrolMultiplier" call BIS_fnc_getParamValue] spawn SCO_fnc_manageFootPatrolsPOI;
		
		// setup air patrols
		[_mapCenterMarker, _missionRadius*1.25, _posSpawn, 1000, _airPatrolDesertPool, "NumberAirPatrols" call BIS_fnc_getParamValue, east] spawn SCO_fnc_manageAirPatrols;

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
