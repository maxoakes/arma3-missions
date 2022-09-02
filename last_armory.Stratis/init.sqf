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

	//create spawn building
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
		[[],"Land_PhoneBooth_01_malden_F", 0], //battleground object
		[[],"MapBoard_stratis_F", 0], //sector control spawner
		[["Helicopter"], "Land_PortableWeatherStation_01_white_F", 0], //helicopter spawn
		[["Plane"], "Land_LandMark_F", 90], //plane spawn
		[["Ship", "Submarine"], "Land_WaterBottle_01_stack_F", 0], //boat spawn
		[[], "Land_LampHarbour_F", 0], //lighting
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
			case 0: //battleground teleport object
			{
				if (["EnableBattleground" call BIS_fnc_getParamValue] call SCO_fnc_parseBoolean) then
				{
					//build a list of locations that one can teleport to
					private _radius = ["TargetSize", 400] call BIS_fnc_getParamValue;
					private _poiList = ["NameVillage", "NameCity", "NameCityCapital", "NameLocal"];
					private _towns = nearestLocations [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), _poiList, worldSize];

					//exclude locations that are within some distance of the spawn
					private _blackListed = [];
					{
						_blackListed append nearestLocations [getMarkerPos _x, _poiList, _radius * 3];
					} foreach SCO_BLACKLISTED_MARKERS;

					{
						private _thisAction = _baseAction;
						_thisAction set [0, format ["Battleground: %1", text _x]];
						_thisAction set [1, { _this call SCO_fnc_generateBattlegroundAndTeleport }];
						_thisAction set [2, [_x, _radius]];
						[_obj, _thisAction] remoteExec ["addAction", 0, true]; //add action to all players
					} foreach (_towns - _blackListed);
				};
			};
			case 1: //sector control spawner
			{
				if (["EnableSectorControl" call BIS_fnc_getParamValue] call SCO_fnc_parseBoolean) then
				{
					{
						private _thisAction = _baseAction;
						_thisAction set [0, format ["Sector Control: %1 waves", _x]];
						_thisAction set [1, { [_this, "functions\sector\fn_generateRandomSectorControl.sqf"] remoteExec ["execVM", 2]; }];
						_thisAction set [2, _x];
						_thisAction set [7, "count (entities 'ModuleSector_F') == 0"];
						[_obj, _thisAction] remoteExec ["addAction", 0, true];
					} forEach [1, 2, 3, 4, 5, 8, 10];
				};
			};
			case 2: //helicopter spawner
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Helicopters"]];
				[_obj, _thisAction] remoteExec ["addAction", 0, true];
			};
			case 3: //plane spawner
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Planes and Jets"]];
				[_obj, _thisAction] remoteExec ["addAction", 0, true];
			};
			case 4: //boat spawner
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Water Vehicles"]];
				[_obj, _thisAction] remoteExec ["addAction", 0, true];
			};
			case 5: //lighting
			{

			};
			case 6: //car spawn
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Land Vehicles"]];
				[_obj, _thisAction] remoteExec ["addAction", 0, true];
			};
			case 7: //apc spawn
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "APCs"]];
				[_obj, _thisAction] remoteExec ["addAction", 0, true];
			};
			case 8: //tank spawn
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Tanks"]];
				[_obj, _thisAction] remoteExec ["addAction", 0, true];
			};
			case 9: //arsenal manager and utilities
			{
				["AmmoboxInit", [_obj, true, { (_this distance _target) < 10 }]] call BIS_fnc_arsenal;
				[_obj, ["Heal Yourself", "(_this select 1) setDamage 0;"]] remoteExec ["addAction", 0, true];
				[_obj, ["Add Ammo for this Weapon", { _this call SCO_fnc_refillWeapon }, 4]] remoteExec ["addAction", 0, true];
				[_obj, ["Teleport to sniper range", { (_this select 1) setPos getMarkerPos "sniping_range"}]] remoteExec ["addAction", 0, true];
				[_obj, ["Teleport to 360 shooting range", { (_this select 1) setPos getMarkerPos "shooting_range"}]] remoteExec ["addAction", 0, true];
				[_obj, ["Open BIS Garage", {
					private _vehicle = createVehicle [ "Land_HelipadEmpty_F", getMarkerPos "teleport", [], 0, "CAN_COLLIDE"];
					["Open", [true, _vehicle]] call BIS_fnc_garage;
					}]
				] remoteExec ["addAction", 0, true];
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
	//end maze creation

	//short-range live shooting range with AI
	//utilities building
	//race controller
	if (["EnableRacing" call BIS_fnc_getParamValue] call SCO_fnc_parseBoolean) then
	{
		["race_center"] call SCO_fnc_createRaceBuilding;
	};

	private _time5 = diag_tickTime;
	[format ["%1sec to build spawn", _time1 - _time0]] call SCO_fnc_printDebug;
	[format ["%1sec to build addAction objects", _time2 - _time1]] call SCO_fnc_printDebug;
	[format ["%1sec to create shooting ranges", _time3 - _time2]] call SCO_fnc_printDebug;
	[format ["%1sec to create maze", _time4 - _time3]] call SCO_fnc_printDebug;
	[format ["%1sec to create race center", _time5 - _time4]] call SCO_fnc_printDebug;
};
