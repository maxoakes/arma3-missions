params ["_playerSide", "_locations", "_enemySide", ["_patrolUnitPool", []], ["_skillRange", [0.3,0.5]], ["_unitsPerSquad", 4], ["_numSquadsPerArea", 1]];

private _footPatrolTracker = [];
{
	_footPatrolTracker pushBack [_x, 0];
} forEach _locations;
systemChat "Starting foot patrol manager for POI";

while {true} do 
{
	sleep 1;
	{
		_x params ["_loc", "_timesSpawned"];
		private _area = ((size _loc select 0) * (size _loc select 1) * pi) / 100000; //area in sq km
		private _spawningDistance = (size _loc select 0) max (size _loc select 1)+1000;
		private _thisAreaSpawnLimit = (ceil (_area) * _numSquadsPerArea) min 8;
		//check if a player unit is nearby a town
		//also check if the spawn limit for that town has been reached. (based on its area)
		if ((({_x distance2D locationPosition _loc < _spawningDistance} count units _playerSide) > 0) and 
			(_timesSpawned < _thisAreaSpawnLimit)) then
		{
			//if spawning is allowed, spawn a group
			private _numUnits = random [(0 max _unitsPerSquad - 2), _unitsPerSquad, (_unitsPerSquad + 2)];
			[locationPosition _loc, _enemySide, _numUnits, _patrolUnitPool, _skillRange, 0, (size _loc) call BIS_fnc_arithmeticMean] call SCO_fnc_spawnFootPatrolGroup;
			_x set [1, _timesSpawned + 1];
			systemChat format ["Spawned patrol in %1 for A=%2 and lim=%3. Now at %4", text _loc, _area, _thisAreaSpawnLimit, _x select 1];
			
		};
	} forEach _footPatrolTracker;
};
