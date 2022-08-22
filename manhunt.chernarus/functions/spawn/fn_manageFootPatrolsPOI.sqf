params ["_playerSide", "_locations", "_enemySide", ["_patrolUnitPool", []], ["_skillRange", [0.3,0.5]], ["_unitsPerSquad", 4], ["_numSquadsPerArea", 1]];

private _footPatrolTracker = [];
{
	_footPatrolTracker pushBack [_x, 0];
} forEach _locations;
["Starting foot patrol manager for POI"] call SCO_fnc_printDebug;

while {_numSquadsPerArea > 0} do 
{
	sleep 1;
	{
		_x params ["_loc", "_timesSpawned"];
		private _area = ((size _loc select 0) * (size _loc select 1) * pi) / 1000000; //area in sq km
		private _spawningDistance = (size _loc select 0) max (size _loc select 1)+1000;
		private _thisAreaSpawnLimit = (ceil (_area*5) * _numSquadsPerArea) min 12;
		//check if a player unit is nearby a town
		//also check if the spawn limit for that town has been reached. (based on its area)
		if ((({_x distance2D locationPosition _loc < _spawningDistance} count units _playerSide) > 0) and 
			(_timesSpawned < _thisAreaSpawnLimit)) then
		{
			//if spawning is allowed, spawn a group
			private _numUnits = random [(0 max _unitsPerSquad - 2), _unitsPerSquad, (_unitsPerSquad + 2)];
			[locationPosition _loc, _enemySide, _numUnits, _patrolUnitPool, _skillRange, 0, (size _loc) call BIS_fnc_arithmeticMean] call SCO_fnc_spawnFootPatrolGroup;
			_x set [1, _timesSpawned + 1];
			[format ["Spawned patrol in %1 with A=%2 sq km. Now at %3/%4", text _loc, _area, _x select 1, _thisAreaSpawnLimit]] call SCO_fnc_printDebug;
			
		};
	} forEach _footPatrolTracker;
};
