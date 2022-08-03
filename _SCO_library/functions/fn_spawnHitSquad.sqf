params ["_pos", "_side", "_firstWaypointPos", "_numUnits", "_possibleClassnames", "_skillRange"];

private _spawnArray = [];
for "_i" from 1 to _numUnits do
{
	_spawnArray pushBack (selectRandom _possibleClassnames);
};
private _squad = [_pos, _side, _spawnArray, [], [], _skillRange, [], [], _pos getDir _firstWaypointPos, false] call BIS_fnc_spawnGroup;

_squad setBehaviour "COMBAT";
_squad setCombatMode "RED";
_squad setFormation "STAG COLUMN";
private _wp = _squad addWaypoint [_firstWaypointPos, 0];
_wp setWaypointType "SAD";

//return
_squad;