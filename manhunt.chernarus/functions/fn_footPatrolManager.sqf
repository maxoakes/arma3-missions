params ["_locations", "_patrolUnitPool"];

private _footPatrolTracker = [];
{
	_footPatrolTracker pushBack [_x, ((size _x select 0) max (size _x select 1))*2, 0];
} forEach _locations;

while {true} do 
{
	sleep 1;
	{
		_x params ["_loc", "_size", "_timesSpawned"];
		//check if a west unit is close to a town
		if (({_x distance2D locationPosition _loc < _size*3} count units west) > 0 and _timesSpawned < ceil (_size/200)) then
		{
			//if one is, spawn a patrol
			[locationPosition _loc, _size, floor random [3, 6, 8], _patrolUnitPool, [0.2, 0.4], 0] call compile preprocessFile "functions\fn_spawnGroundPatrolGroup.sqf";
			_x set [2, (_x select 2) + 1];
			systemChat format ["Spawned patrol in %1", text _loc];
		};
	} forEach _footPatrolTracker;
};


