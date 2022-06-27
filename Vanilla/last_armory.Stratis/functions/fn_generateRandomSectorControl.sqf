params ["_target", "_caller", "_actionId", "_waveLimit"];
(format ["fn_generateRandomSectorControl.sqf started from %1. isDedicated:%2, isServer:%3 hasInterface:%4", _caller, isDedicated, isServer, hasInterface]) remoteExec ["systemChat", 0];

//types of possible vehicles that may spawn
private _vehiclePool = ["O_MRAP_02_F", "O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F", "O_G_Offroad_01_armed_F", "O_G_Offroad_01_AT_F", "O_LSV_02_armed_F", "O_LSV_02_armed_viper_F"];

//identify possible locations to put sector
private _objectTypes = ["House", "Building"];
private _possibleSectorCenterObjects = nearestObjects [
	getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), //center position
	_objectTypes, //types of objects to center on
	worldSize/1.5, //search radius
	true //is 2D mode
];

private _blacklistedBuildings = [];
{
	_blacklistedBuildings append nearestObjects [getMarkerPos _x, _objectTypes, 2000];
} forEach BLACKLISTED_MARKERS;

//get the position of a random building the valid possible selection
private _pos = getPos (selectRandom (_possibleSectorCenterObjects - _blacklistedBuildings));
private _name = "Sector"; //a default name if it is in the middle of nowhere
_name = text ((nearestLocations [_pos, ["NameVillage", "NameCity", "NameCityCapital", "NameLocal"], 2000]) select 0);

//create the sector control module
private _logic = createGroup sideLogic;
private _module = _logic createUnit ["ModuleSector_F", _pos, [], 0, "CAN_COLLIDE"];
_module setVariable ["DefaultOwner","0"];
_module setVariable ["Name", _name];
_module setVariable ["OnOwnerChange", ""];
_module setVariable ["OwnerLimit", 1];
_module setVariable ["TaskDescription", "Capture %1 from OPFOR then defend the sector until the time runs out."];
_module setVariable ["TaskOwner", 2];
_module setVariable ["TaskTitle", "Capture and Defend %1"];
_module setVariable ["sides", [east, west]];
_module setvariable ["BIS_fnc_initModules_disableAutoActivation", false];
_module setVariable ["size", SECTOR_CONTROL_RADIUS];

waitUntil {!isNil {_module getVariable "finalized"} && {!(_module getVariable "finalized")}};

format ["Sector %1: Created.", _name] remoteExec ["systemChat", 0];

//spawn initial number of squads. 1 to 4, weighted to 2
private _initialNumSquads = floor random [1,2,5];
for "_i" from 1 to _initialNumSquads do
{
	private _group = createGroup [east, true];
	private _numUnits = floor random [2,3,5];
	private _safePos = [_pos, 0, SECTOR_CONTROL_RADIUS, 5, 0, 0, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;

	//create a squad
	private _squad = [
		_safePos, //position
		east, //side
		_numUnits, //number of units
		[], // relative emptyPositions
		[], // ranks
		[0.1, 0.2], //skill ranges
		[], //ammo ranges
		[], //random variations
		0, //azimuth
		true //precise position
	] call BIS_fnc_spawnGroup;
	format ["Sector %1: Spawned %2 units.", _name, _numUnits] remoteExec ["systemChat", 0];
};

//spawn one initial vehicle
private _safePos = [_pos, 0, SECTOR_CONTROL_RADIUS, 5, 0, 0, 0,[], [_pos, _pos]] call BIS_fnc_findSafePos;	
private _array = [_safePos, 0, selectRandom _vehiclePool, east] call BIS_fnc_spawnVehicle;
format ["Sector %1: Spawned vehicle.", _name] remoteExec ["systemChat", 0];

//wait until sector is under west control
waitUntil {sleep 1; _module getVariable "owner" == west};

//start spawning waves
private _waveSpawnDistance = (SECTOR_CONTROL_RADIUS * 2) max 100;
for "_i" from 1 to _waveLimit do
{
	private _spawnedUnits = [];
	private _spawnedVehicles = [];

	//spawn squad
	format ["Sector %1: Starting wave %2.", _name, _i] remoteExec ["systemChat", 0];
	private _numUnits = _i * SECTOR_CONTROL_UNITS_PER_WAVE;
	private _safePos = [_pos, _waveSpawnDistance, _waveSpawnDistance + 25, 8, 0, MAX_GRADIENT, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;

	private _squad = [
		_safePos, //position
		east, //side
		_numUnits, //number of units
		[], // relative emptyPositions
		[], // ranks
		[0.1, _waveLimit / 10], //skill ranges
		[], //ammo ranges
		[], //random variations
		0, //azimuth
		true //precise position
	] call BIS_fnc_spawnGroup;
	_spawnedUnits append (units _squad);
	format ["Sector %1: Spawned %2 units.", _name, _numUnits] remoteExec ["systemChat", 0];
	
	//every third round, spawn a vehicle
	if ((_i mod 3) == 0) then
	{
		private _array = [
			[_safePos, 10, 60, 5, 0, 0, 0] call BIS_fnc_findSafePos, 
			0, selectRandom _vehiclePool, east] call bis_fnc_spawnvehicle;

		_spawnedUnits append (_array select 1);
		_spawnedVehicles pushBack (_array select 0);
		format ["Sector %1: Spawned vehicle.", _name] remoteExec ["systemChat", 0];
	};
	
	//create a waypoint to try to capture sector
	_squad setBehaviour "COMBAT";
	_wp setCombatMode "RED";
	_wp setFormation "STAG COLUMN";
	private _wp = _squad addWaypoint [_pos, 0];
	_wp setWaypointType "SAD";
	
	//make a marker to show where they are coming from
	private _startMarker = createMarker [(str _i), (getPos ((units _squad) select 0))];
	_startMarker setMarkerShape "ICON";
	_startMarker setMarkerType "mil_arrow";
	_startMarker setMarkerColor "ColorOPFOR";
	_startMarker setMarkerDir ([_module, getMarkerPos _startMarker] call BIS_fnc_relativeDirTo) + 180;
	_startMarker setMarkerText format ["Wave %1 start point", _i];
	
	//wait until sector is captured by east or all wave units are dead
	//if wave units are dead, move onto next wave
	//if the sector is captured, end
	waitUntil {
		sleep 1; 
		({alive _x and (_x distance2D _pos < _waveSpawnDistance * 1.25)} count _spawnedUnits == 0) or (_module getVariable "owner" == east)
	};

	//clean up
	deleteMarker _startMarker;
	sleep 5;
	{
		deleteVehicle _x;
	} forEach _spawnedUnits + _spawnedVehicles;

	//check end conditions
	if (_module getVariable "owner" == east) then
	{
		//if we get here, the mission failed and will end wave spawning
		break;
	}
	else
	{
		format ["Sector %1: Completed wave %2.", _name, _i] remoteExec ["systemChat", 0];
	};
};

if (_module getVariable "owner" == east) then
{
	format ["Sector %1: Mission failed.", _name] remoteExec ["systemChat", 0];
}
else
{
	format ["Sector %1: Mission successful. Returning all nearby players to spawn.", _name] remoteExec ["systemChat", 0];
};

sleep 3;
deleteVehicle _module;

//teleport players back to spawn
{
	if (_x distance2D _pos < SECTOR_CONTROL_RADIUS * 3) then
	{
		(vehicle _x) setPos ([SPAWN_POS, getMarkerSize "respawn_west" select 0, 
			50, 5, 0, 0, 0, [], [SPAWN_POS, SPAWN_POS]] call BIS_fnc_findSafePos);
	}
	
} foreach allPlayers;
