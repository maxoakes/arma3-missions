params ["_target", "_caller", "_actionId", "_waveLimit"];
format [
	"fn_generateRandomSectorControl.sqf started from %1. isDedicated:%2, isServer:%3 hasInterface:%4", 
	_caller, isDedicated, isServer, hasInterface
] remoteExec ["systemChat", 0];

//units that are actual, opfor, and have weapons (more than 'put' and 'throw')
private _allOpforUnitClassnames = "
	getNumber (_x >> 'scope') >= 2 && 
	configName _x isKindOf 'Man' && 
	getNumber (_x >> 'side') == 0 &&
	count getArray (_x >> 'weapons') > 2" 
	configClasses (configFile >> "CfgVehicles") apply {(configName _x)};

//vehicles that are actual, opfor, are a type of car, have some type of turrent
private _allLightOpforVehicleClassnames = "
	getNumber (_x >> 'scope') >= 2 && 
	configName _x isKindOf 'Car' && 
	getNumber (_x >> 'side') == 0 &&
	count ((configName _x) call BIS_fnc_vehicleCrewTurrets) > 1" 
	configClasses (configFile >> "CfgVehicles") apply {(configName _x)};

//identify possible locations to put sector
private _objectTypes = ["House", "Building"];
private _possibleSectorCenterObjects = nearestObjects [
	getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), //center position
	_objectTypes, //types of objects to center on
	worldSize/1.5, //search radius
	true //is 2D mode
];

//get a list of buildings that are close to the spawn or its markers
private _blacklistedBuildings = [];
{
	_blacklistedBuildings append nearestObjects [getMarkerPos _x, _objectTypes, 2000];
} forEach BLACKLISTED_MARKERS;

//get the position of a random building from the valid selection
private _sectorPos = getPos (selectRandom (_possibleSectorCenterObjects - _blacklistedBuildings));
private _sectorName = "Sector"; //a default name if it is in the middle of nowhere
private _nearbyLocations = nearestLocations [_sectorPos, ["NameVillage", "NameCity", "NameCityCapital", "NameLocal"], 2000];
if (count _nearbyLocations > 0) then
{
	_sectorName = text (_nearbyLocations select 0);
};

//create the sector control module
private _logic = createGroup sideLogic;
private _module = _logic createUnit ["ModuleSector_F", _sectorPos, [], 0, "CAN_COLLIDE"];
_module setVariable ["DefaultOwner","0"];
_module setVariable ["Name", _sectorName];
_module setVariable ["OnOwnerChange", ""];
_module setVariable ["OwnerLimit", 1];
_module setVariable ["TaskDescription", "Capture %1 from OPFOR then defend the sector until the time runs out."];
_module setVariable ["TaskOwner", 2];
_module setVariable ["TaskTitle", "Capture and Defend %1"];
_module setVariable ["sides", [east, west]];
_module setvariable ["BIS_fnc_initModules_disableAutoActivation", false];
_module setVariable ["size", SECTOR_CONTROL_RADIUS];

waitUntil {!isNil {_module getVariable "finalized"} && {!(_module getVariable "finalized")}};
format ["Sector %1: Created.", _sectorName] remoteExec ["systemChat", 0];

//spawn initial number of squads. 2 to 4, weighted to 3
private _initialNumSquads = floor random [2,3,5];
private _initialSafePosArray = [_sectorPos, 0, SECTOR_CONTROL_RADIUS, 5, 0, 0, 0, [], [_sectorPos, _sectorPos]];
for "_i" from 1 to _initialNumSquads do
{
	private _safePos = _initialSafePosArray call BIS_fnc_findSafePos;
	private _group = createGroup [east, true];
	private _numUnits = floor random [2,3,5];
	private _chosenUnitClassname = selectRandom _allOpforUnitClassnames;
	private _chosenUnitName = getText (configFile >> "CfgVehicles" >> _chosenUnitClassname >> "displayName");
	private _unitClassnameArray = [];
	for "_j" from 1 to _numUnits do
	{
		_unitClassnameArray pushBack _chosenUnitClassname;
	};
	
	//create an east squad at the safe position composed of array with a specified skill level
	private _squad = [_safePos,	east, _unitClassnameArray, [], [], [0.1, 0.2], [], [], 0, true] call BIS_fnc_spawnGroup;
	format ["Sector %1: Spawned %2 of '%3'.", _sectorName, _numUnits, _chosenUnitName] remoteExec ["systemChat", 0];
};

//spawn one initial vehicle
private _safePos = _initialSafePosArray call BIS_fnc_findSafePos;
private _array = [_safePos, 0, selectRandom _allLightOpforVehicleClassnames, east] call BIS_fnc_spawnVehicle;
private _vehicleName = getText (configFile >> "CfgVehicles" >> typeOf (_array select 0) >> "displayName");
format ["Sector %1: Spawned %2.", _sectorName, _vehicleName] remoteExec ["systemChat", 0];

//wait until sector is under west control
waitUntil {sleep 1; _module getVariable "owner" == west};

//start spawning waves
private _waveSpawnDistance = (SECTOR_CONTROL_RADIUS * 2) max 100;
for "_i" from 1 to _waveLimit do
{
	private _spawnedUnits = [];
	private _spawnedVehicles = [];

	//spawn squad
	format ["Sector %1: Starting wave %2.", _sectorName, _i] remoteExec ["systemChat", 0];
	private _numUnits = _i * SECTOR_CONTROL_UNITS_PER_WAVE;
	private _chosenUnitClassname = selectRandom _allOpforUnitClassnames;
	private _chosenUnitName = getText (configFile >> "CfgVehicles" >> _chosenUnitClassname >> "displayName");
	private _unitClassnameArray = [];
	for "_j" from 1 to _numUnits do
	{
		_unitClassnameArray pushBack _chosenUnitClassname;
	};
	private _safePos = [_sectorPos, _waveSpawnDistance, _waveSpawnDistance + 25, 8, 0, MAX_GRADIENT, 0, [], [_sectorPos, _sectorPos]] call BIS_fnc_findSafePos;

	//create an east squad at the safe position composed of array with a skill level that varies by the wave count
	private _squad = [_safePos, east, _unitClassnameArray, [], [], [0.1, _waveLimit / 10], [], [], 0, true ] call BIS_fnc_spawnGroup;
	_spawnedUnits append (units _squad);
	format ["Sector %1: Spawned %2 of '%3'.", _sectorName, _numUnits, _chosenUnitName] remoteExec ["systemChat", 0];
	
	//create a waypoint to try to capture sector
	_squad setBehaviour "COMBAT";
	_squad setCombatMode "RED";
	_squad setFormation "STAG COLUMN";
	private _wp = _squad addWaypoint [_sectorPos, 0];
	_wp setWaypointType "SAD";

	//every third round, spawn a vehicle
	if ((_i mod 3) == 0) then
	{
		private _array = [
			[_safePos, 10, 60, 5, 0, 0, 0] call BIS_fnc_findSafePos, 
			0, selectRandom _allLightOpforVehicleClassnames, east] call BIS_fnc_spawnVehicle;
		private _vehicleName = getText (configFile >> "CfgVehicles" >> typeOf (_array select 0) >> "displayName");
		_spawnedUnits append (_array select 1);
		_spawnedVehicles pushBack (_array select 0);
		format ["Sector %1: Spawned %2.", _sectorName, _vehicleName] remoteExec ["systemChat", 0];

		//create a waypoint for that vehicle
		(_array select 2) setBehaviour "COMBAT";
		(_array select 2) setCombatMode "RED";
		private _wp = (_array select 2) addWaypoint [_sectorPos, 0];
		_wp setWaypointType "SAD";
	};
	
	//make a marker to show where they are coming from
	private _startMarker = createMarker [(str _i), (getPos ((units _squad) select 0))];
	_startMarker setMarkerShape "ICON";
	_startMarker setMarkerType "mil_arrow";
	_startMarker setMarkerColor "ColorOPFOR";
	_startMarker setMarkerDir ([_module, getMarkerPos _startMarker] call BIS_fnc_relativeDirTo) + 180;
	_startMarker setMarkerText format ["Wave %1 start point", _i];
	
	//wait until sector is re-captured by east or all wave units are dead
	waitUntil {
		sleep 1; 
		({alive _x and (_x distance2D _sectorPos < _waveSpawnDistance * 1.25)} count _spawnedUnits == 0) or 
		(_module getVariable "owner" == east);
	};

	//clean up
	deleteMarker _startMarker;
	sleep 5;
	{
		deleteVehicle _x;
	} forEach _spawnedUnits + _spawnedVehicles;

	//if wave units are dead, move onto next wave
	//if the sector is captured, skip all the next waves and move to end-condition check
	if (_module getVariable "owner" == east) then
	{
		//if we get here, the mission failed and will end wave spawning
		break;
	}
	else
	{
		format ["Sector %1: Completed wave %2.", _sectorName, _i] remoteExec ["systemChat", 0];
	};
};

if (_module getVariable "owner" == east) then
{
	format ["Sector %1: Mission failed.", _sectorName] remoteExec ["systemChat", 0];
}
else
{
	format ["Sector %1: Mission successful. Returning all nearby players to spawn.", _sectorName] remoteExec ["systemChat", 0];
};

sleep 3;
//final clean up
deleteVehicle _module;

//teleport players back to spawn
{
	if (_x distance2D _sectorPos < SECTOR_CONTROL_RADIUS * 4) then
	{
		(vehicle _x) setPos ([SPAWN_POS, SPAWN_RADIUS, 50, 5, 0, 0, 0, [], [SPAWN_POS, SPAWN_POS]] call BIS_fnc_findSafePos);
	}
} foreach allPlayers;
