/*
	Author: Scouter

	Description:
		Spawn a standard squad and set combat behaviors and first waypoint

	Parameter(s):
		0: Position - starting position
		1: Side - side of the squad
		2: Position - position that the units will go to upon spawning
		3: Number - number of units in the squad
		4: Array of Strings - List of classnames that the units could be
		5: Array of two numbers - range of skill
		6: String - combat behavior. per setBehaviour
		7: String - combat mode. per setCombatMode
		8: String - formation. per setFormation

	Returns:
		Group
*/

params ["_pos", "_side", "_firstWaypointPos", "_numUnits", "_possibleClassnames", ["_skillRange", [0.3, 0.5]], ["_behaviour", "COMBAT"], ["_combatMode", "RED"], ["_formation", "STAG COLUMN"]];

private _spawnArray = [];
for "_i" from 1 to _numUnits do
{
	_spawnArray pushBack (selectRandom _possibleClassnames);
};
private _squad = [_pos, _side, _spawnArray, [], [], _skillRange, [], [], _pos getDir _firstWaypointPos, false] call BIS_fnc_spawnGroup;

_squad setBehaviour _behaviour;
_squad setCombatMode _combatMode;
_squad setFormation _formation;
private _wp = _squad addWaypoint [_firstWaypointPos, 0];
_wp setWaypointType "SAD";

//return
_squad;