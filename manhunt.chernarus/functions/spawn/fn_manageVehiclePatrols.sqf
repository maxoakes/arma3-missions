params ["_locations", "_patrolVehiclePool", "_maxVehicles", "_side"];

[format ["Spawning %1 region patrol vehicles", _maxVehicles]] call SCO_fnc_printDebug;
private _spawnedGroups = [];
for "_i" from 1 to _maxVehicles do
{
	//pick a starting location to spawn a vehicle
	private _startLocation = selectRandom _locations;
	private _locSize = ((size _startLocation select 0) max (size _startLocation select 1))*2;

	//pick a safe spawn position to place vehicle
	private _nearestRoad = [locationPosition _startLocation, 2000] call BIS_fnc_nearestRoad;
	private _spawnPos = [locationPosition _startLocation, 0, _locSize, 15, 0, 0.5, 0, [], [getPos _nearestRoad, getPos _nearestRoad]] call BIS_fnc_findSafePos;

	//spawn the vehicle
	private _result = [_spawnPos, 0, selectRandom _patrolVehiclePool, _side] call BIS_fnc_spawnVehicle;
	_spawnedGroups pushBack _result;
	_result params ["_vehicle", "_crew", "_group"];
	_vehicle setVehiclePosition [_spawnPos, [], 0, "NONE"];
	_group setGroupIdGlobal [format ["Region Vehicle Patrol %1", {side _x == _side} count allGroups]];

	//make it so the vehicles do not run out of fuel when driving
	_vehicle addEventHandler ["Fuel", {
		params ["_vehicle", "_hasFuel"];
		if (side driver _vehicle == _side and fuel _vehicle < 0.05) then
		{
			_vehicle setFuel random [0.5, 0.8, 0.95];
		};
	}];

	//create waypoints
	for "_w" from 1 to 12 do
	{
		private _wpPos = locationPosition selectRandom _locations;
		private _wp = _group addWaypoint [[_wpPos, 1000] call BIS_fnc_nearestRoad, 0];
		_wp setWaypointCompletionRadius 50;
		_wp setWaypointBehaviour "CARELESS";
		_wp setWaypointType "MOVE";
		_wp setWaypointSpeed selectRandom ["NORMAL", "LIMITED", "LIMITED"];
	};
	//loop the waypoints
	private _wpCycle = _group addWaypoint [[_spawnPos, 1000] call BIS_fnc_nearestRoad, 0];
	_wpCycle setWaypointCompletionRadius 50;
	_wpCycle setWaypointType "CYCLE";
};
["All vehicles region patrol vehicles spawned"] call SCO_fnc_printDebug;