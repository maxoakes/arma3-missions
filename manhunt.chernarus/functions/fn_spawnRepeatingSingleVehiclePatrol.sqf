/*
	Author: Scouter

	Description:
		Spawn a vehicle patrol near a random player. The vehicle will go as close to the player as possible
		while still being on a road. Should be spawned rather than called.
		Must be run concurrently with mission
		
	Parameter(s):
		0: Array of Locations - All locations that should have patrols
		1: Array of Strings - classnames of possible vehicles

	Returns:
		Void
*/
params ["_locations", "_patrolVehiclePool"];
private _waypointSize = 100;
systemChat "Starting nearby vehicle patrol manager.";

while {true} do 
{
	
	//pick random west unit position. If no units are spawned yet, target the spawn
	private _midpointTarget = getMarkerPos "respawn_west";
	if (count playableUnits > 0) then
	{
		_midpointTarget = getPos selectRandom (units west arrayIntersect playableUnits);
	};

	//get a lot of towns that are far away from the player
	private _locationPool = nearestLocations [_midpointTarget, ["Name", "NameVillage", "NameCity", "NameCityCapital"], 3000] - 
		nearestLocations [_midpointTarget, ["Name", "NameVillage", "NameCity", "NameCityCapital"], 1500];

	//pick some starting town and a town that is the furthest away from the start.
	//Mathmatically, this should be the town that is as far to the other side of the circle as possible
	private _startLocation = selectRandom _locationPool;
	private _endLocation = ([_locationPool, [locationPosition _startLocation], { _input0 distance2D (locationPosition _x) }, "DESCEND"] call BIS_fnc_sortBy) select 0;

	//pick a safe spawn position to place vehicle
	private _spawnPos = [locationPosition _startLocation, 0, 500, 7, 0, 0.7, 0, [], [locationPosition _startLocation, locationPosition _startLocation]] call BIS_fnc_findSafePos;
	private _result = [_spawnPos, 180, selectRandom _patrolVehiclePool, east] call BIS_fnc_spawnVehicle;
	_result params ["_vehicle", "_crew", "_group"];
	_vehicle setVehiclePosition [_spawnPos, [], 0, "NONE"];
	_group setGroupId [format ["Repeating Patrol %1", ({side _x == east} count allGroups)]];
	systemChat "Spawning nearby vehicle patrol.";
	
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
		systemChat "vehicle is probably stuck. forcing end to loop";
	};

	//create waypoints near player and at end of route
	private _goToPlayerWP = _group addWaypoint [[_midpointTarget, 1000] call BIS_fnc_nearestRoad, 0];
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
		systemChat "Cleaning up vehicle and crew";
	};
	systemChat "Vehicle patrol tracking ended";
};


