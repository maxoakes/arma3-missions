params ["_posCenter", "_radius", "_numUnits", "_possibleUnitClassnames", "_skillRange", "_mode"];

private _groupUnitClassnames = [];
for "_i" from 0 to _numUnits - 1 do
{
	_groupUnitClassnames pushBack selectRandom _possibleUnitClassnames;
};

private _spawnPosition = [_posCenter, 8, (50 min _radius), 8, 0, 1.0, 0, [], [_posCenter, _posCenter]] call BIS_fnc_findSafePos;
private _squad = [_spawnPosition, east, _groupUnitClassnames, [], [], _skillRange] call BIS_fnc_spawnGroup;
_squad allowFleeing 0;

private _numGroups = {side _x == east} count allGroups;

if (_mode == 0) then
{
	_squad setGroupId [format ["Foot Patrol %1", _numGroups]];
	[_squad, _posCenter, _radius] call BIS_fnc_taskPatrol;
};
if (_mode == 1) then
{
	_squad setGroupId [format ["Foot Defense %1", _numGroups]];
	[_squad, _posCenter] call BIS_fnc_taskDefend;
};
