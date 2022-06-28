private _startTime = diag_tickTime;

//weather settings
setDate [2018, 3, 30, ("Time" call BIS_fnc_getParamValue), 0];
0 setOvercast ("Clouds" call BIS_fnc_getParamValue)/100;
0 setFog ("Fog" call BIS_fnc_getParamValue)/100;
0 setRain ("Rain" call BIS_fnc_getParamValue)/100;
forceWeatherChange;

//global variables
SECTOR_CONTROL_UNITS_PER_WAVE = "SectorWaveUnitCount" call BIS_fnc_getParamValue;
SECTOR_CONTROL_RADIUS = "SectorSize" call BIS_fnc_getParamValue;
BATTLEGROUND_RADIUS = "TargetSize" call BIS_fnc_getParamValue;
BLACKLISTED_MARKERS = ["respawn_west", "plane_spawn", "boat_spawn", "teleport"];
MAX_GRADIENT = 0.45;
SPAWN_POS = getMarkerPos "respawn_west";
SPAWN_RADIUS = getMarkerSize "respawn_west" select 0;

//easily accessible local variables
private _vehicleNameColor = "#f7f0db";
private _vehicleObjectTextColor = "#bababa";

if (isServer) then
{
	//create the physical border of the spawn area
	[
		SPAWN_POS, //center of border circle
		SPAWN_RADIUS * 1.1, //radius
		["Land_HBarrier_1_F"], //what can be the border be made of
		1.65, //distance between objects
		90, //relative rotation of the objects
		true //are exits needed?
	] call compile preprocessFile "functions\fn_createBorder.sqf";

	//create safezone
	private _safeZoneTrigger = createTrigger ["EmptyDetector", SPAWN_POS, true];
	_safeZoneTrigger setTriggerArea [_borderRadius, _borderRadius, 0, false, _borderRadius];
	_safeZoneTrigger setTriggerActivation ["ANY", "PRESENT", true];
	_safeZoneTrigger setTriggerStatements ["player in thisList", "player allowDamage false", "player allowDamage true"];

	//create spawn building
	private _teleportAreaObject = createVehicle ["Land_JumpTarget_F", getMarkerPos "teleport", [], 0, "CAN_COLLIDE"];
	private _teleportAreaMarker = [_teleportAreaObject] call BIS_fnc_boundingBoxMarker;
	_teleportAreaMarker setMarkerShape "ELLIPSE";
	_teleportAreaMarker setMarkerColor "ColorGreen";
	_teleportAreaMarker setMarkerBrush "Border";
	missionNamespace setVariable ["MAP_TELEPORT_ORIGIN_MARKER", _teleportAreaMarker, true];

	//anonymous grass cutter
	createVehicle ["Land_ClutterCutter_large_F", SPAWN_POS, [], 0, "CAN_COLLIDE"];

	//a list of sudo-class/object containing basic information for the utility objects in the spawn
	private _objectSet = [
		//[list of vehicle types to spawn, model classname of the object, direction offset]
		[[],"Land_PhoneBooth_01_malden_F", 0], //battleground object
		[[],"Land_Target_Single_01_F", 0], //sector control spawner
		[["Helicopter"], "Land_FeedRack_01_F", 0], //helicopter spawn
		[["Plane"], "Land_LuggageHeap_03_F", 0], //plane spawn
		[["Ship", "Submarine"], "Land_ConcreteWell_02_F", 0], //boat spawn
		[[], "Land_LampHarbour_F", 0], //lighting
		[["Car", "Motorcycle"], "Land_fs_feed_F", 0], //car spawn
		[["WheeledAPC"], "Land_ScrapHeap_1_F", 60], //apc spawn
		[["Tank", "TrackedAPC"], "Land_Tombstone_07_F", 180], //tank spawn
		[[], "Land_Sign_WarningNoWeapon_F", 0] //arsenal manager
	];

	//an emulation of a dictionary object. 'key' is the type of vehicle (Car, Ship, Plane, etc)
	//value is an array of vehicle classnames of that type
	private _vehicleDictionary = ["cfgVehicles", "Vehicle"] call compile preprocessFile "functions\fn_getAllCfgSubClasses.sqf";

	//iterate over the sudo-objects and assign objects and behaviors to each of them
	private _numObjects = count _objectSet;
	private _dir = 0;
	for "_i" from 0 to (_numObjects - 1) do
	{
		//parent action that all utility actions will overwrite
		private _baseAction = [
			format ["<t color='#bababa'>%1</t>", "BASE-ADD-ACTION"], 
			{ hint "Scroll while looking at this object to select a vehicle." },
			"", 8, true, true, "", "true", 6, false, "", ""];

		//create the physical object and place them in a circle pattern using the specified object models
		private _pos = [
			(SPAWN_POS select 0)+(sin(_dir)*(SPAWN_RADIUS/1.3)),
			(SPAWN_POS select 1)+(cos(_dir)*(SPAWN_RADIUS/1.3)),
			(SPAWN_POS select 2)
		];
		private _obj = createVehicle [(_objectSet select _i) select 1, _pos, [], 0, "CAN_COLLIDE"];		
		_obj allowDamage false;
		_obj setDir _dir + ((_objectSet select _i) select 2);
		_dir = _dir + (360/_numObjects);

		//change the behavior of the spawned object
		switch (_i) do
		{
			case 0: //battleground teleport object
			{
				//build a list of locations that one can teleport to
				private _poiList = ["NameVillage", "NameCity", "NameCityCapital", "NameLocal"];
				private _towns = nearestLocations [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), _poiList, worldSize];

				//exclude locations that are within some distance of the spawn
				private _blackListed = [];
				{
					_blackListed append nearestLocations [getMarkerPos _x, _poiList, BATTLEGROUND_RADIUS * 3];
				} foreach BLACKLISTED_MARKERS;

				{
					private _thisAction = _baseAction;
					_thisAction set [0, format ["%1", text(_x)]];
					_thisAction set [1, "functions\fn_generateBattlegroundAndTeleport.sqf"];
					_thisAction set [2, _x];
					//_obj addAction _thisAction;
					[_obj, _thisAction] remoteExec ["addAction", 0, true]; //add action to all players
				} foreach (_towns - _blackListed);
			};
			case 1: //sector control spawner
			{
				{
					//_obj addAction [format ["Create Sector Control with %1 waves", _x], "functions\fn_generateRandomSectorControl.sqf", _x];
					//[_obj, [format ["Create Sector Control with %1 waves", _x], "functions\fn_generateRandomSectorControl.sqf", _x]] remoteExec ["addAction", 0, true]; //add action to all players
					//add the action for all players, including JIP. The action will have the server generate a random sector control point
					[
						_obj, 
						[format ["Create Sector Control with %1 waves", _x], 
						{
							[_this, "functions\fn_generateRandomSectorControl.sqf"] remoteExec ["execVM", 2];
						}, 
						_x]
					] remoteExec ["addAction", 0, true];
					
				} forEach [1, 2, 3, 4, 5, 8, 10]
			};
			case 2: //helicopter spawner
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Helicopters"]];
				//_obj addAction _thisAction;
				[_obj, _thisAction] remoteExec ["addAction", 0, true]; //add action to all players
			};
			case 3: //plane spawner
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Planes and Jets"]];
				//_obj addAction _thisAction;
				[_obj, _thisAction] remoteExec ["addAction", 0, true]; //add action to all players
			};
			case 4: //boat spawner
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Water Vehicles"]];
				//_obj addAction _thisAction;
				[_obj, _thisAction] remoteExec ["addAction", 0, true]; //add action to all players
			};
			case 5: //lighting
			{

			};
			case 6: //car spawn
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Land Vehicles"]];
				//_obj addAction _thisAction;
				[_obj, _thisAction] remoteExec ["addAction", 0, true]; //add action to all players
			};
			case 7: //apc spawn
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "APCs"]];
				//_obj addAction _thisAction;
				[_obj, _thisAction] remoteExec ["addAction", 0, true]; //add action to all players
			};
			case 8: //tank spawn
			{
				private _thisAction = _baseAction;
				_thisAction set [0, format ["<t color='%1'>%2</t>", _vehicleObjectTextColor, "Tanks"]];
				//_obj addAction _thisAction;
				[_obj, _thisAction] remoteExec ["addAction", 0, true]; //add action to all players
			};
			case 9: //arsenal manager
			{
				["AmmoboxInit", [_obj, true, { (_this distance _target) < 10 }]] call BIS_fnc_arsenal;
				// _obj addAction ["Heal Yourself", "(_this select 1) setDamage 0;"];
				// _obj addAction ["Add Ammo for this Weapon", "functions\fn_refillWeapon.sqf", 4];
				[_obj, ["Heal Yourself", "(_this select 1) setDamage 0;"]] remoteExec ["addAction", 0, true]; //add action to all players
				[_obj, ["Add Ammo for this Weapon", "functions\fn_refillWeapon.sqf", 4]] remoteExec ["addAction", 0, true]; //add action to all players
			};
		};

		//refer to the object set list of vehicle types and the vehicle dictionary, and create actions to spawn the applicable vehicles
		{
			if (_x select 0 in ((_objectSet select _i) select 0)) then
			{
				{
					private _spawnAction = _baseAction;
					_spawnAction set [0, format ["<t color='%1'>%2</t>", _vehicleNameColor, getText(configFile >> "cfgVehicles" >> _x >> "displayName")]];
					_spawnAction set [1, "functions\fn_spawnEmptyVehicleAndMoveInto.sqf"];
					_spawnAction set [2, [_x, "respawn_west"]];
					//_obj addAction _spawnAction;
					[_obj, _spawnAction] remoteExec ["addAction", 0, true]; //add action to all players
				} forEach (_x select 1);
			};
		} forEach _vehicleDictionary;
	};
};

private _stopTime = diag_tickTime;
(format ["init.sqf took %1 sec to complete. isDedicated:%2, isServer:%3 hasInterface:%4", _stopTime - _startTime, isDedicated, isServer, hasInterface]) remoteExec ["systemChat", 0];