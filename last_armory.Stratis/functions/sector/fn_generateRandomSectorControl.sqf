params ["_waveLimit"];
[format ["Creating sector via %1. isDedicated:%2, isServer:%3 hasInterface:%4", clientOwner, isDedicated, isServer, hasInterface]] call SCO_fnc_printDebug;
private _unitsPerWave = ["SectorWaveUnitCount", 1] call BIS_fnc_getParamValue;
private _radius = ["SectorSize", 25] call BIS_fnc_getParamValue;

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

//pick a random location, then a random building in that location
private _locationTypes = ["Name", "NameCity", "NameCityCapital", "NameLocal", "NameMarine", "NameVillage", "ViewPoint", "Hill", "Airport"];
private _locations = nearestLocations [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), _locationTypes, worldSize];
private _blacklisted = [];
{
	_blacklisted append nearestLocations [getMarkerPos _x, _locationTypes, 1500];
} foreach SCO_BLACKLISTED_MARKERS;

private _possibleLocations = _locations - _blacklisted;
private _selectedLocation = selectRandom _possibleLocations;
private _possibleSectorCenterObjects = nearestObjects [locationPosition _selectedLocation, ["House", "Building"], 1000, true];

//get the position of a random building from the valid selection
private _sectorPos = getPos selectRandom _possibleSectorCenterObjects;
private _sectorName = "Sector";

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
_module setVariable ["size", _radius];

waitUntil {!isNil {_module getVariable "finalized"} && {!(_module getVariable "finalized")}};
private _nearbyLocation = nearestLocations [_sectorPos, ["NameVillage", "NameCity", "NameCityCapital", "NameLocal"], 2000] select 0;
format ["Sector Control created near %1", text _nearbyLocation] remoteExec ["systemChat", 0];

//spawn initial number of squads. 2 to 4, weighted to 3
private _initialNumSquads = floor random [2,3,5];
private _initialSafePosArray = [_sectorPos, 0, _radius, 10, 0, 0, 0, [], [_sectorPos, _sectorPos]];
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
	format ["Sector Control: Spawned %1 of '%1'.", _numUnits, _chosenUnitName] remoteExec ["systemChat", 0];
};

//spawn one initial vehicle
private _safePos = _initialSafePosArray call BIS_fnc_findSafePos;
private _array = [_safePos, 0, selectRandom _allLightOpforVehicleClassnames, east] call BIS_fnc_spawnVehicle;
private _vehicleName = getText (configFile >> "CfgVehicles" >> typeOf (_array select 0) >> "displayName");
(_array select 0) setVehiclePosition [_safePos, [], 0, "NONE"];
format ["Sector Control: Spawned %1.", _vehicleName] remoteExec ["systemChat", 0];

//wait until sector is under west control
waitUntil {sleep 1; _module getVariable "owner" == west};

//start spawning waves
private _waveSpawnDistance = (_radius * 2) max 100;
for "_i" from 1 to _waveLimit do
{
	private _spawnedUnits = [];
	private _spawnedVehicles = [];

	//spawn squad
	format ["Sector Control: Starting wave %1.", _i] remoteExec ["systemChat", 0];
	private _numUnits = _i * _unitsPerWave;
	private _chosenUnitClassname = selectRandom _allOpforUnitClassnames;
	private _chosenUnitName = getText (configFile >> "CfgVehicles" >> _chosenUnitClassname >> "displayName");
	private _unitClassnameArray = [];
	for "_j" from 1 to _numUnits do
	{
		_unitClassnameArray pushBack _chosenUnitClassname;
	};
	private _safePos = [_sectorPos, _waveSpawnDistance, _waveSpawnDistance + 25, 8, 0, SCO_MAX_GRADIENT, 0, [], [_sectorPos, _sectorPos]] call BIS_fnc_findSafePos;

	//create an east squad at the safe position composed of array with a skill level that varies by the wave count
	private _squad = [_safePos, east, _unitClassnameArray, [], [], [0.1, _waveLimit / 10], [], [], 0, true ] call BIS_fnc_spawnGroup;
	_spawnedUnits append (units _squad);
	format ["Sector Control: Spawned %1 of '%2'.", _numUnits, _chosenUnitName] remoteExec ["systemChat", 0];
	
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
		format ["Sector Control: Spawned %1.", _vehicleName] remoteExec ["systemChat", 0];

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
		format ["Sector Control: Completed wave %1.", _i] remoteExec ["systemChat", 0];
	};
};

if (_module getVariable "owner" == east) then
{
	"Sector Control: Mission failed." remoteExec ["systemChat", 0];
}
else
{
	"Sector Control: Mission successful. Returning all nearby players to spawn." remoteExec ["systemChat", 0];
};

sleep 3;
//final clean up
deleteVehicle _module;
missionNamespace setVariable ["SCO_SECTOR_ACTIVE", false, true];

//teleport players back to spawn
private _returnPos = getMarkerPos "respawn_west";
{
	if (_x distance2D _sectorPos < _radius * 4) then
	{
		if (vehicle _x == _x) then
		{
			_x setPos _returnPos;
		}
		else
		{
			(vehicle _x) setPos ([_returnPos, 50, 500, 10, 0, 0, 0, [], [_returnPos, _returnPos]] call BIS_fnc_findSafePos);
		};
	};
} foreach allPlayers;
