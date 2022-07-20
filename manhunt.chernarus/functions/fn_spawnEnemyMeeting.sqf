/*
	Author: Scouter

	Description:
		Spawn units around some position with the intent that one of them is a target for players

	Parameter(s):
		0: Position - center of where to place units
		1: Number - number of units spawned. Should be more than 0
		2: String - classname of the object that is in the center
		3: Array of Strings - classnames of unit types that can be created
		4: Array of Strings - classnames of what weapons the units can be using

	Returns:
		Object - the intented 'leader' of the 'meeting'
*/
params ["_posCenter", "_numAttendees", "_centerObjectClassname", "_possibleBaseUnitClassnames", "_possibleWeaponClassnames"];

private _startTime = diag_tickTime;

//create center object
private _centerObj = createVehicle [_centerObjectClassname, _posCenter, [], 0, "CAN_COLLIDE"];
_centerObj setDir random 360;

private _distFromCenter = 2;
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
		(_posCenter select 0) + (sin(_angle)* _distFromCenter),
		(_posCenter select 1) + (cos(_angle)* _distFromCenter)
	];

	private _unit = _group createUnit [selectRandom _possibleBaseUnitClassnames, _pos, [], 0, "CAN_COLLIDE"];
	_group setGroupId [format ["Faction Leader %1", _i]];

	//set the unit inventory
	removeAllWeapons _unit;
	removeAllItems _unit;
	removeAllAssignedItems _unit;
	removeGoggles _unit;

	_unit addItemToVest "MiniGrenade";
	for "_i" from 1 to 3 do {_unit addItemToVest "30Rnd_762x39_AK12_Mag_F";};
	for "_i" from 1 to 3 do {_unit addItemToVest "6Rnd_45ACP_Cylinder";};
	
	_unit linkItem "ItemWatch";
	_unit linkItem "ItemRadio";
	_unit linkItem "ItemGPS";

	private _selectedWeapon = selectRandom _primaryWeaponPool;
	_unit addWeapon _selectedWeapon;
	private _magazines = getArray (configFile >> "CfgWeapons" >> _selectedWeapon >> "magazines");
	for "_i" from 1 to 3 do {
		_unit addMagazine (_magazines select 0);
	};
	_unit addWeapon "hgun_Pistol_heavy_02_F";
	_unit addHandgunItem "6Rnd_45ACP_Cylinder";

	//set the identify of the unit if it is the leader
	if (_i == 1) then
	{
		[_unit, "WhiteHead_24"] remoteExec ["setFace", 0, _unit];
		[_unit, "STAND", "RANDOM"] call BIS_fnc_ambientAnimCombat;
		_unit setName "Dmitri Kozlov";
		[_unit, [format [localize "STR_ACTION_CONFIRM", name _unit], {CONFIRMED_KILL = true}, nil, 3, true, true, "", "true", 3, false, "", ""]] remoteExec ["addAction", 0, true];
	};
	
	_unit setDir (_unit getDir _centerObj);
	_angle = _angle + _step;
	_units pushBack _unit;
};

private _stopTime = diag_tickTime;
(format ["%1 sec to generate warlord meeting.",	_stopTime - _startTime]) remoteExec ["systemChat", 0];

//return
_units select 0;