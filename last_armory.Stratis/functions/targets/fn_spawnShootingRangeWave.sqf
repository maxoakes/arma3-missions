params ["_target", "_caller", "_actionId", "_arguments"];
_arguments params ["_radius", "_spawns", "_waveAmount", "_amountPerWave", "_waveInterval"];

SCO_SHOOTING_RANGE_WAVE_ACTIVE = true;
publicVariable "SCO_SHOOTING_RANGE_WAVE_ACTIVE";

private _scoreCalculator = [_target, _radius, _caller, _waveAmount*_amountPerWave] spawn {
	params ["_center", "_radius", "_player", "_maxScore"];
	private _bodies = [];
	//while there are east units in the shooting range
	while {({_center distance2D _x < _radius and alive _x} count units east > 0) and ({_center distance2D _x < _radius and alive _x} count units west > 0)} do
	{
		sleep 1;
		{
			if (side _x == east) then { _bodies pushBackUnique _x; };
		} forEach (_center nearObjects ["Man", 8]);
		hint format ["Score is %1/%2", _maxScore - (count _bodies), _maxScore];
	};
	_player sideChat format ["I finished shooting range wave with a score of %1/%2", _maxScore - (count _bodies), _maxScore];
};

private _allUnits = [];
for "_i" from 1 to _waveAmount do
{
	
	for "_j" from 1 to _amountPerWave do
	{
		private _group = createGroup [east, true];	
		private _moveWP = _group addWaypoint [getPos _target, 0];
		_moveWP setWaypointType "MOVE";
		private _unit = _group createUnit ["O_Soldier_VR_F", getPos (selectRandom _spawns), [], 0, "CAN_COLLIDE"];
		_unit allowFleeing 0;
		{	
			_unit disableAI _x;
		} forEach ["MINEDETECTION", "RADIOPROTOCOL", "SUPPRESSION", "AUTOCOMBAT"];
		_unit setBehaviour "CARELESS";
		_allUnits pushBack _unit;
	};
	sleep _waveInterval;
};

waitUntil {{alive _x} count _allUnits == 0};
["Ending shooting range wave function"] call SCO_fnc_printDebug;
SCO_SHOOTING_RANGE_WAVE_ACTIVE = false;
publicVariable "SCO_SHOOTING_RANGE_WAVE_ACTIVE";