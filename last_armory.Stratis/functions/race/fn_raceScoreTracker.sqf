params ["_players", "_endPos", "_dnfTimeout", "_finishRadius"];

private _startTime = diag_tickTime;
private _firstPlaceTime = -1;
private _inProgressCode = -1;
private _dnfCode = -2;
private _completedTable = [];
{
	_completedTable pushBack [_x, _inProgressCode]; //-1=in progress, real int=finish time, -2=dnf
} forEach _players;

while {{(_x select 1) == _inProgressCode} count _completedTable > 0} do
{
	sleep 0.2;
	private _activeRacers = {(_x select 1) == _inProgressCode} count _completedTable;

	//print stats for each racer
	private _string = format ["<t size='1.5' align='left'>Distances (%1 active):</t><br/>", _activeRacers];
	
	{
		_x params ["_racer", "_time"];

		private _playerDistance = _racer distance _endPos;

		//if the player has not yet been observed winning, but now is, update their finish time
		if (_playerDistance < _finishRadius and _time == _inProgressCode) then
		{
			private _time = diag_tickTime - _startTime;
			_x set [1, _time];

			if (_firstPlaceTime == -1) then
			{
				_firstPlaceTime = diag_tickTime;
			};
		};

		//dnf if the racer dies, or the timer expires. they must be currently racing for dnf status to be applied
		if (_time == _inProgressCode and (!alive _racer or ((diag_tickTime - _firstPlaceTime > _dnfTimeout) and (_firstPlaceTime != -1)))) then
		{
			_x set [1, _dnfCode];
		};

		switch (_time) do
		{
			case _dnfCode: 
			{
				_string = _string + format ["<t align='left'>(Inactive) %1: DNF</t><br/>", name _racer];
			};
			case _inProgressCode:
			{
				_string = _string + format ["<t align='left'>(Racing) %1:  %2m</t><br/>", name _racer, floor (_racer distance _endPos)];
			};
			default
			{
				_string = _string + format ["<t align='left'>(Finished) %1:  %2 sec</t><br/>", name _racer, _time toFixed 1];
			};
		};
	} forEach _completedTable;

	if (_firstPlaceTime != -1) then
	{
		//if a player has completed, the DNF timer will appear
		_string = _string + format ["<t size='0.75' align='left'>DNF time in %1 seconds</t>", floor (_dnfTimeout - (diag_tickTime - _firstPlaceTime))];
	};
	(parseText _string) remoteExec ["hint", _players apply {group _x}];
};

//print the race results to chat
[format ["Race Results:%1", _completedTable]] call SCO_fnc_printDebug;
"" remoteExec ["hint", _players apply {group _x}];
private _finishers = [_completedTable, [], {_x select 1}, "ASCEND", {(_x select 1) > 0}] call BIS_fnc_sortBy;
private _dnf = [_completedTable, [], {_x select 1}, "ASCEND", {(_x select 1) < 0}] call BIS_fnc_sortBy;
"Race Results:" remoteExec ["systemChat", 0];
//print status of finishers
{
	_x params ["_racer", "_time"];
	format ["%1 finished %2 in %3 seconds", name _racer, [_forEachIndex+1] call BIS_fnc_ordinalNumber, _time toFixed 1] remoteExec ["systemChat", 0];
} forEach _finishers;

//print those that did not finish
{
	_x params ["_racer", "_status"];
	switch (_status) do
	{
		case _dnfCode: 
		{
			format ["%1 did not finish", name _racer] remoteExec ["systemChat", 0];
		};
		case -1:
		{
			format ["%1 is still racing", name _racer] remoteExec ["systemChat", 0];
		};
		default
		{
			format ["%1 has an unknown status: %2", name _racer, _status] remoteExec ["systemChat", 0];
		};
	};
} forEach _dnf;
["score tracker is done"] call SCO_fnc_printDebug;