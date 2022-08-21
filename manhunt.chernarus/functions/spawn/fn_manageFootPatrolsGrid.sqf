params ["_playerSide", "_markers", "_enemySide", ["_patrolUnitPool", []], ["_skillRange", [0.3, 0.5]], ["_unitsPerSquad", 4], ["_spawnDistance", 1000]];

private _footPatrolTracker = [];
{
	_footPatrolTracker pushBack [_x, 0];
} forEach _markers;
["Starting foot patrol manager for grid"] call SCO_fnc_printDebug;

while {true} do 
{
	sleep 1;
	{
		_x params ["_marker", "_timesSpawned"];
		//check if a player unit is nearby and if the node has spawned a unit yet
		if ((({_x distance2D getMarkerPos _marker < _spawnDistance} count units _playerSide) > 0) and (_timesSpawned == 0)) then
		{
			//if spawning is allowed, spawn a group
			private _numUnits = random [(0 max _unitsPerSquad - 1), _unitsPerSquad, (_unitsPerSquad + 1)];
			[getMarkerPos _marker, _enemySide, _numUnits, _patrolUnitPool, _skillRange, 0, 500] call SCO_fnc_spawnFootPatrolGroup;
			_x set [1, _timesSpawned + 1];
			[format ["Spawned patrol at node %1", _x select 0]] call SCO_fnc_printDebug;
		};
	} forEach _footPatrolTracker;
};
