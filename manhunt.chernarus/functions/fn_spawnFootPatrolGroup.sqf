/*
	Author: Scouter

	Description:
		Spawn a group of units that randomly walk around some area
		
	Parameter(s):
		0: Position - (required) original location units should patrol
		1: Side - (required) side of units to spawn
		2: Number - (required) number of units in the group
		3: Array of Strings - (required) possible classnames that the units can be
		4: Array of Numbers - (optional) two numbers (between 0.0 and 1.0) that are the range of skill of each unit
		5: Number - (optional) 0 or 1, indicates if it is a patrol or defensive group
		6: Number - (optional) maximum range each waypoint can be from the next

	Returns:
		Group of the units that was spawned
*/
params ["_posCenter", "_groupSide", "_numUnits", "_possibleUnitClassnames", ["_skillRange", [0.0, 1.0]], ["_mode", 0], ["_radius", 100]];

private _groupUnitClassnames = [];
for "_i" from 0 to _numUnits - 1 do
{
	_groupUnitClassnames pushBack selectRandom _possibleUnitClassnames;
};

private _spawnPosition = [_posCenter, 8, (50 min _radius), 8, 0, 1.0, 0, [], [_posCenter, _posCenter]] call BIS_fnc_findSafePos;
private _squad = [_spawnPosition, _groupSide, _groupUnitClassnames, [], [], _skillRange] call BIS_fnc_spawnGroup;
_squad allowFleeing 0;

private _numGroups = {side _x == _groupSide} count allGroups;

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

//return
_squad;