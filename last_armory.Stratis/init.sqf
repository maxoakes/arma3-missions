//weather settings
setDate [2022, 8, 24, ("Time" call BIS_fnc_getParamValue), 0];
setTimeMultiplier ("TimeScale" call BIS_fnc_getParamValue);
0 setOvercast ("Clouds" call BIS_fnc_getParamValue)/100;
0 setFog ("Fog" call BIS_fnc_getParamValue)/100;
0 setRain ("Rain" call BIS_fnc_getParamValue)/100;
forceWeatherChange;

//global variables
SCO_BLACKLISTED_MARKERS = allMapMarkers; //all pre-placed markers
SCO_MAX_GRADIENT = 0.45;
private _spawnPos = getMarkerPos "respawn_west";
private _spawnRadius = getMarkerSize "respawn_west" select 0;
private _spawnDir = markerDir "respawn_west";

//easily accessible local variables
private _vehicleNameColor = "#f7f0db";
private _vehicleObjectTextColor = "#bababa";

//create safezone for all players
private _safeZoneTrigger = createTrigger ["EmptyDetector", _spawnPos, true];
_safeZoneTrigger setTriggerArea [_spawnRadius, _spawnRadius, 0, false, _spawnRadius];
_safeZoneTrigger setTriggerActivation ["ANY", "PRESENT", true];
_safeZoneTrigger setTriggerStatements ["player in thisList", "player allowDamage false", "player allowDamage true"];

if (isServer) then
{
	//start creating spawn area
	private _time0 = diag_tickTime;

	//create the physical border of the spawn area and delete anything that is there already
	private _addActionObjectRadius = 0;
	if (["EnableSpawnDome" call BIS_fnc_getParamValue] call SCO_fnc_parseBoolean) then
	{
		{
			_x allowDamage false;
			hideObjectGlobal _x;
		} forEach nearestObjects [_spawnPos, [], 17, true];

		private _dome = createVehicle ["Land_Dome_Small_F", _spawnPos, [], 0, "CAN_COLLIDE"];
		_dome allowDamage false;
		_dome setDir _spawnDir;
		_addActionObjectRadius = 9;
	}
	else
	{
		{
			_x allowDamage false;
			hideObjectGlobal _x;
		} forEach nearestObjects [_spawnPos ,[], _spawnRadius + 2, true];

		[_spawnPos, _spawnRadius, ["Land_HBarrier_1_F"], 1.65, 90, 0, true, _spawnDir] call SCO_fnc_createBorder;
		_addActionObjectRadius = _spawnRadius - 3;
	};

	//create teleport area
	private _teleportAreaObject = createVehicle ["Land_JumpTarget_F", getMarkerPos "teleport", [], 0, "CAN_COLLIDE"];
	private _teleportAreaMarker = [_teleportAreaObject] call BIS_fnc_boundingBoxMarker;
	_teleportAreaMarker setMarkerShape "ELLIPSE";
	_teleportAreaMarker setMarkerColor "ColorGreen";
	_teleportAreaMarker setMarkerBrush "Border";
	missionNamespace setVariable ["MAP_TELEPORT_ORIGIN_MARKER", _teleportAreaMarker, true];

	private _time1 = diag_tickTime;
	//end creating spawn area

	//start creating addAction objects within spawn
	//a list of sudo-class/object containing basic information for the utility objects in the spawn
	private _objectSet = [
		//[list of vehicle types to spawn, model classname of the object, direction offset]
		[[],"MapBoard_stratis_F", 0], //fast travel
		[["Helicopter"], "Land_PortableWeatherStation_01_white_F", 0], //helicopter spawn
		[["Plane"], "Land_LandMark_F", 90], //plane spawn
		[["Ship", "Submarine"], "Land_WaterBottle_01_stack_F", 0], //boat spawn
		[["Car", "Motorcycle"], "Land_fs_feed_F", 0], //car spawn
		[["WheeledAPC"], "Land_Pallet_MilBoxes_F", 0], //apc spawn
		[["Tank", "TrackedAPC"], "Land_TankTracks_01_long_F", 90], //tank spawn
		[[], "Land_Sign_WarningNoWeapon_F", 0] //arsenal manager
	];

	//an emulation of a dictionary object. 'key' is the type of vehicle (Car, Ship, Plane, etc)
	//value is an array of vehicle classnames of that type
	private _vehicleDictionary = [["Vehicle"]] call SCO_fnc_getObjectClassnames;
	private _allLandSpawns = ["land_spawn"] call SCO_fnc_getMarkers;
	private _allWaterSpawns = ["boat_spawn"] call SCO_fnc_getMarkers;
	private _allPlaneSpawns = ["plane_spawn"] call SCO_fnc_getMarkers;

	//iterate over the sudo-objects and assign objects and behaviors to each of them
	private _numObjects = count _objectSet;
	private _dir = _spawnDir;
	for "_i" from 0 to (_numObjects - 1) do
	{
		(_objectSet select _i) params ["_vehicleTypes", "_objectClassname", "_dirOffset"];

		//parent action that all utility actions will overwrite
		private _baseAction = ["addAction", { hint "Scroll while looking at this object to select a vehicle." }, "", 8, true, true, "", "true", 6, false, "", ""];

		//create the physical object and place them in a circle pattern using the specified object models
		private _pos = _spawnPos getPos [_addActionObjectRadius, _dir];
		private _obj = createVehicle [_objectClassname, _pos, [], 0, "CAN_COLLIDE"];		
		_obj allowDamage false;
		_obj enableSimulationGlobal false;
		_obj setDir _dir + _dirOffset;
		_dir = _dir + (360/_numObjects);

		//change the behavior of the spawned object
		switch (_i) do
		{
			case 0: //fast travel
			{
				[_obj, ["Teleport to sniper range",
					{
						params ["_target", "_caller", "_actionId", "_arguments"];
						_caller setPos getMarkerPos "sniping_range";
						_caller setDir markerDir "sniping_range";
					}]
				] remoteExec ["addAction", 0, true];

				[_obj, ["Teleport to 360 shooting range",
					{
						params ["_target", "_caller", "_actionId", "_arguments"];
						private _safePos = [getMarkerPos "shooting_range", 2, 10, 0.5, 0, 0, 0, [], [getMarkerPos "shooting_range", getMarkerPos "shooting_range"]] call BIS_fnc_findSafePos;
						_caller setPos _safePos;
						_caller setDir random 360;
					}]
				] remoteExec ["addAction", 0, true];

				[_obj, ["Teleport to lobby building",
					{
						params ["_target", "_caller", "_actionId", "_arguments"];
						private _pos = (getMarkerPos "lobby_center") getPos [10, markerDir "lobby_center" + 270];
						_caller setPos _pos;
						_caller setDir (_pos getDir (getMarkerPos "lobby_center"));
					}]
				] remoteExec ["addAction", 0, true];

				[_obj, ["Teleport near active sector",
					{
						params ["_target", "_caller", "_actionId", "_arguments"];
						private _activeSector = entities 'ModuleSector_F' select 0;
						if (!isNil "_activeSector") then
						{
							private _startRadius = ["SectorSize", 50] call BIS_fnc_getParamValue;
							private _safePos = [getPos _activeSector, _startRadius, _startRadius + 100, 3, 0, 0, 0, [], [getPos _caller, getPos _caller]] call BIS_fnc_findSafePos;
							_caller setPos _safePos;
							_caller setDir (_safePos getDir _activeSector);
						};
					}, nil, 1.5, true, true, "", "count (entities 'ModuleSector_F') > 0"]
				] remoteExec ["addAction", 0, true];
			};
			case 1: //helicopter spawner
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Helicopters"]];
				[_obj, _thisAction] remoteExec ["addAction", 0, true];
			};
			case 2: //plane spawner
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Planes and Jets"]];
				[_obj, _thisAction] remoteExec ["addAction", 0, true];
			};
			case 3: //boat spawner
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Water Vehicles"]];
				[_obj, _thisAction] remoteExec ["addAction", 0, true];
			};
			case 4: //car spawn
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Land Vehicles"]];
				[_obj, _thisAction] remoteExec ["addAction", 0, true];
			};
			case 5: //apc spawn
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "APCs"]];
				[_obj, _thisAction] remoteExec ["addAction", 0, true];
			};
			case 6: //tank spawn
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Tanks"]];
				[_obj, _thisAction] remoteExec ["addAction", 0, true];
			};
			case 7: //arsenal manager and utilities
			{
				["AmmoboxInit", [_obj, true, { (_this distance _target) < 10 }]] call BIS_fnc_arsenal;
				[_obj, ["Restore Previous Loadout", "(_this select 1) setUnitLoadout SCO_PREVIOUS_LOADOUT", nil, 1.5, true, true, "", "!isNil 'SCO_PREVIOUS_LOADOUT'"]] remoteExec ["addAction", 0, true];
				[_obj, ["Heal Yourself", "(_this select 1) setDamage 0;"]] remoteExec ["addAction", 0, true];
				[_obj, ["Add Ammo for this Weapon", { _this call SCO_fnc_refillWeapon }, 4]] remoteExec ["addAction", 0, true];
				// [_obj, ["Open BIS Garage", {
				// 	private _vehicle = createVehicle [ "Land_HelipadEmpty_F", getMarkerPos "teleport", [], 0, "CAN_COLLIDE"];
				// 	["Open", [true, _vehicle]] call BIS_fnc_garage;
				// 	}]
				// ] remoteExec ["addAction", 0, true];
			};
		};

		//refer to the object set list of vehicle types and the vehicle dictionary, and create actions to spawn the applicable vehicles
		{
			if (_x select 0 in _vehicleTypes) then
			{
				{
					private _spawnAction = _baseAction;
					_spawnAction set [0, format ["<t color='%1'>%2</t>", _vehicleNameColor, getText(configFile >> "cfgVehicles" >> _x >> "displayName")]];
					_spawnAction set [1, {
						private _veh = _this call SCO_fnc_spawnEmptyVehicle;
						if (_veh != objNull) then
						{
							(_this select 1) moveInDriver _veh;
						};
					}];
					_spawnAction set [2, [_x, _allLandSpawns, _allPlaneSpawns, _allWaterSpawns]];
					[_obj, _spawnAction] remoteExec ["addAction", 0, true];
				} forEach (_x select 1);
			};
		} forEach _vehicleDictionary;
	};

	private _time2 = diag_tickTime;

	//start creation of shooting ranges
	if (["EnableShootingRanges" call BIS_fnc_getParamValue] call SCO_fnc_parseBoolean) then
	{
		if (getMarkerColor "sniping_range" != "") then
		{
			//if the sniping range marker exists, start its creation
			private _snipingRange = "snipingRange";
			["sniping_range", true, [200, 400, 600], 0] call SCO_fnc_createSnipingRange;
			["sniping_range", false, [100, 200, 300], 5] call SCO_fnc_createSnipingRange;
			["sniping_range", false, [800, 1000, 1200], -5] call SCO_fnc_createSnipingRange;
		};

		if ((getMarkerColor "shooting_range" != "") and (getMarkerSize "shooting_range" select 0 > 10)) then
		{
			["shooting_range"] call SCO_fnc_createShootingRange;
		};
	};

	private _time3 = diag_tickTime;
	//end create shooting ranges

	//start maze creation
	if (["EnableMazes" call BIS_fnc_getParamValue] call SCO_fnc_parseBoolean) then
	{
		["maze"] call SCO_fnc_createWallMaze;
		["maze_1"] call SCO_fnc_createWallMaze;
	};

	private _time4 = diag_tickTime;

	["lobby_center"] call SCO_fnc_createRaceBuilding;

	//start zeus creation
	private _time5 = diag_tickTime;

	curator1 addCuratorEditingArea [0, getMarkerPos "respawn_west", 500];
	curator1 setCuratorEditingAreaType false;
	[curator1, ["A3_Modules_F_Bootcamp",
		"A3_Modules_F_Bootcamp_Misc",
		"A3_Modules_F_Curator_Respawn",
		"A3_Modules_F_Curator_Multiplayer",
		"A3_Modules_F_Curator_Curator",
		"A3_Modules_F_Curator_Intel",
		"A3_Modules_F_Curator_Misc"
	]] remoteExec ["removeCuratorAddons", 0, true];

	private _time6 = diag_tickTime;
	[format ["%1sec to build spawn", _time1 - _time0]] call SCO_fnc_printDebug;
	[format ["%1sec to build addAction objects", _time2 - _time1]] call SCO_fnc_printDebug;
	[format ["%1sec to create shooting ranges", _time3 - _time2]] call SCO_fnc_printDebug;
	[format ["%1sec to create maze", _time4 - _time3]] call SCO_fnc_printDebug;
	[format ["%1sec to create race center", _time5 - _time4]] call SCO_fnc_printDebug;
	[format ["%1sec to create zeus functionality", _time6 - _time5]] call SCO_fnc_printDebug;
};