params ["_locations", "_patrolVehiclePool", "_enemySide", "_playerSide"];
private _waypointSize = 100;
private _locationTypes = ["Name", "NameVillage", "NameCity", "NameCityCapital"];
["Starting nearby vehicle patrol manager."] call SCO_fnc_printDebug;

while {true} do 
{
	
	//pick random west unit position. If no units are spawned yet, target the spawn
	private _midpointTarget = getMarkerPos "respawn_west";
	if (count playableUnits > 0) then
	{
		_midpointTarget = getPos selectRandom (units _playerSide arrayIntersect playableUnits);
	};

	//get a lot of towns that are far away from the player
	private _locationPool = nearestLocations [_midpointTarget, _locationTypes, 3000] - nearestLocations [_midpointTarget, _locationTypes, 1500];

	//pick some starting town and a town that is the furthest away from the start.
	//Mathmatically, this should be the town that is as far to the other side of the circle as possible
	private _startLocation = selectRandom _locationPool;
	private _startRoad = [locationPosition _startLocation, 2000] call BIS_fnc_nearestRoad;
	(getRoadInfo _startRoad) params ["_mapType", "_width", "_isPedestrian", "_texture", "_textureEnd", "_material", "_begPos", "_endPos", "_isBridge"];
	private _roadDir = _begPos getDir _endPos;
	private _target = [_midpointTarget, 2000] call BIS_fnc_nearestRoad;
	private _proposedEndPos = _target getPos [1500, (_startRoad getDir _target)];
	private _endLocation = ([_locationPool, [_proposedEndPos], { _input0 distance2D (locationPosition _x) }, "ASCEND"] call BIS_fnc_sortBy) select 0;

	//pick a safe spawn position to place vehicle
	private _spawnPos = [getPos _startRoad, 0, 100, 10, 0, 1, 0, [], [getPos _startRoad, getPos _startRoad]] call BIS_fnc_findSafePos;
	private _result = [_spawnPos, 180, selectRandom _patrolVehiclePool, east] call BIS_fnc_spawnVehicle;
	_result params ["_vehicle", "_crew", "_group"];
	_vehicle setVehiclePosition [_spawnPos, [], 0, "NONE"];
	_vehicle setDir _roadDir;
	_group setGroupIdGlobal [format ["Repeating Patrol %1", ({side _x == _enemySide} count allGroups)]];
	[format ["Spawning targeted vehicle patrol starting at %1, ending at %2.", text _startLocation, text _endLocation]] call SCO_fnc_printDebug;
	
	//check if the vehicle is stuck. It can happen if they need to turn around at the player-near-point
	//should be running for the entirety of the vehicles existance
	//if this loop ends, that means the vehicle is stuck and will be terminted later
	private _stuckCheck = _result spawn
	{
		params ["_vehicle", "_crew", "_group"];
		while {true} do 
		{
			private _maxSpeed = 0;
			for "_i" from 0 to 30 do
			{
				sleep 1;
				_maxSpeed = _maxSpeed max speed _vehicle;
			};
			if (_maxSpeed < 15) then
			{
				break;
			};
		};
		["Vehicle is probably stuck. Forcing end to this loop."] call SCO_fnc_printDebug;
	};

	//create waypoints near player and at end of route
	if (_target == objNull) then
	{
		_target = selectRandom (units _playerSide arrayIntersect playableUnits);
	};
	private _goToPlayerWP = _group addWaypoint [_target, 0];
	_goToPlayerWP setWaypointCompletionRadius _waypointSize;
	_goToPlayerWP setWaypointBehaviour "CARELESS";
	_goToPlayerWP setWaypointType "MOVE";

	//once the vehicle reaches the waypoint, create another waypoint in a town in the same direction
	private _goToEndWP = _group addWaypoint [locationPosition _endLocation, 0];
	_goToEndWP setWaypointCompletionRadius _waypointSize;
	_goToEndWP setWaypointBehaviour "CARELESS";
	_goToEndWP setWaypointType "LOITER";

	//wait until the vehicle reachest the end destination, the crew is dead, or the vehicle is badly damaged, or the vehicle is stuck
	waitUntil {
		_vehicle distance2D locationPosition _endLocation < _waypointSize or 
		{alive _x} count _crew == 0 or 
		damage _vehicle > 0.5 or 
		scriptDone _stuckCheck and ({_x distance2D _vehicle < 1000} count allPlayers == 0)
	};

	//only despawn vehicle if it is stuck or if it reached the waypoint
	//if the players kill the crew, they can have the vehicle without it despawning
	if (_vehicle distance2D locationPosition _endLocation < _waypointSize or scriptDone _stuckCheck) then
	{
		deleteVehicle _vehicle;
		{
			deleteVehicle _x;
		} forEach _crew;
		deleteGroup _group;
		["Cleaning up vehicle and crew"] call SCO_fnc_printDebug;
	};
	["Vehicle patrol tracking ended"] call SCO_fnc_printDebug;
};


