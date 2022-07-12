//takes in position where the meeting will take place and number of units other than the leader attending
//returns an array of the units that are spawned from this function
params ["_posCenter", "_numAttendees"];

private _startTime = diag_tickTime;

//setup group
private _baseUnitTypes = ["O_G_Soldier_F", "O_G_Soldier_lite_F", "O_G_Soldier_SL_F", "O_G_Soldier_TL_F", "O_G_Soldier_AR_F", "O_G_medic_F"];
private _primaryWeaponPool = ["arifle_AK12U_F", "arifle_RPK12_lush_arco_pointer_F", "arifle_AK12U_lush_snds_pointer_F", "arifle_AK12U_lush_holo_pointer_F"];
private _facePool = ["RussianHead_2", "RussianHead_3", "RussianHead_4", "RussianHead_5", "LivonianHead_10"];

private _numUnits = _numAttendees + 1;
private _distFromCenter = 2;
private _step = 360 / _numUnits;
private _angle = 0;
private _units = [];

//create a table in the center
private _table = createVehicle ["Land_CampingTable_F", _posCenter, [], 0, "CAN_COLLIDE"];
_table setDir random 360;

for "_i" from 1 to _numUnits do
{
	//set up group
	private _group = createGroup east;
	_group setCombatMode "RED";
	_group setBehaviour "COMBAT";

	private _pos = [
		(_posCenter select 0) + (sin(_angle)* _distFromCenter),
		(_posCenter select 1) + (cos(_angle)* _distFromCenter)
	];

	private _unit = _group createUnit [selectRandom _baseUnitTypes, _pos, [], 0, "CAN_COLLIDE"];

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
		_unit setName "Dmitri Panteley Kozlov";
		[_unit, [format ["Confirm Identity of %1", name _unit],	{CONFIRMED_KILL = true}, nil, 3, true, true, "", "true", 3, false, "", ""]] remoteExec ["addAction", 0, true];
	}
	else
	{
		[_unit, selectRandom _facePool] remoteExec ["setFace", 0, _unit];
	};
	_unit setDir (_unit getDir _table);
	_angle = _angle + _step;
	_units pushBack _unit;
};

private _stopTime = diag_tickTime;
(format ["%1 sec to generate warlord meeting.",	_stopTime - _startTime]) remoteExec ["systemChat", 0];

//return
_units;