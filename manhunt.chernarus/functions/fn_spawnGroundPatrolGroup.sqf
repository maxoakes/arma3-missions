/*
	Author: Scouter

	Description:
		Spawn a group of units that randomly walk around some area
		
	Parameter(s):
		0: Position - original location units should patrol
		1: Number - maximum range each waypoint can be from the next
		2: Number - number of units in the group
		3: Array of Strings - possible classnames that the units can be
		4: Array of Numbers - two numbers (between 0.0 and 1.0) that are the range of skill of each unit
		5: Number - 0 or 1, indicates if it is a patrol or defensive group

	Returns:
		Void
*/
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
