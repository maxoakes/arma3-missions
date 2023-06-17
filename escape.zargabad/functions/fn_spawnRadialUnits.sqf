/*
	Author: Scouter

	Description:
		Spawn units around some position with the intent that one of them is a target for players

	Parameter(s):
		0: Position - center of where to place units
		1: Number - number of units spawned. Should be more than 0
		2: Number - distance from the center that the units are spawned
		3: Array of Strings - classnames of unit types that can be created
		4: Number - between 0.0 and 1.0, the maximum skill of a unit
		5: String - classname of the object that is in the center
		6: Array of Strings - classnames of what weapons the units can be using
	
	Returns:
		Object - the intented 'leader' of the 'meeting'
*/
params ["_posCenter", "_numAttendees", "_radius", "_possibleBaseUnitClassnames", ["_skill", 0.5], ["_centerObjectClassname", ""]];

//create center object
if (_centerObjectClassname != "") then
{
	private _centerObj = createVehicle [_centerObjectClassname, _posCenter, [], 0, "CAN_COLLIDE"];
	_centerObj setDir random 360;
};

private _step = 360 / _numAttendees;
private _angle = 0;
private _units = [];

//spawn and initialize each meeting member
for "_i" from 1 to _numAttendees do
{
	//set up group
	private _group = createGroup east;
	_group setCombatMode "RED";
	_group setBehaviour "COMBAT";

	private _pos = [
		(_posCenter select 0) + (sin(_angle)* _radius),
		(_posCenter select 1) + (cos(_angle)* _radius)
	];

	private _unit = _group createUnit [selectRandom _possibleBaseUnitClassnames, _pos, [], 0, "CAN_COLLIDE"];
	_group setGroupIdGlobal [format ["Faction Leader %1", _i]];
	_unit setSkill _skill;
	
	_unit setDir ([_unit, _posCenter] call BIS_fnc_dirTo);
	_angle = _angle + _step;
	_units pushBack _unit;
};

//return
_units select 0;