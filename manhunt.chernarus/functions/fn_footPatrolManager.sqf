/*
	Author: Scouter

	Description:
		Depends on SCO_fnc_spawnFootPatrolGroup. Tracks and spawns units in the specified locations.
		Should be spawned rather than called; must be run concurrently with mission.
		
	Parameter(s):
		0: Side - (required) side of the players
		1: Array of Locations - (required) All locations that should have patrols
		2: Side - (required) side of the enemies to spawn
		3: Array of Strings - (optional) classnames of possible units
		4: Number - (optional) how many more groups should a town have patrolling
		
	Returns:
		Void
*/

params ["_playerSide", "_locations", "_enemySide", ["_patrolUnitPool", []], ["_multiplier", 1]];

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
		//also check if the spawn limit for that town has been reached. (based on its size)
		if (({_x distance2D locationPosition _loc < _size*3} count units _playerSide) > 0 and _timesSpawned < ceil (_size/400) * _multiplier) then
		{
			//if spawning is allowed, spawn a group
			[locationPosition _loc, _enemySide, floor random [3, 6, 8], _patrolUnitPool, [0.2, 0.4], 0, _size] call SCO_fnc_spawnFootPatrolGroup;
			_x set [2, (_x select 2) + 1];
			//systemChat format ["Spawned patrol in %1", text _loc];
		};
	} forEach _footPatrolTracker;
};
