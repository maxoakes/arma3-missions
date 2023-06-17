/*
	Author: Scouter

	Description:
		Given a position, spawn a building filled with stuff. 

	Parameter(s):
		0: Object - (required) the unit that will have the inventory filled
		1: String - (optional) classname of primary weapon
		2: String - (optional) classname of secondary weapon
		3: Array of Strings - (optional) classnames of items to add to the inventory
		4: Array of Strings - (optional) classnames of linked items to add the inventory
		5: String - (optional) classname of uniform to add
		6: String - (optional) classname of vest to add
		7: String - (optional) classname of backpack to add
		8: String - (optional) classname of hat to add
		9: String - (optional) classname of goggles to add

	Returns:
		Void
*/
params ["_unit", ["_primary", ""], ["_secondary", ""], ["_otherItems", []], ["_linkedItems", []], ["_uniform", ""], ["_vest", ""], ["_backpack", ""], ["_headgear", ""], ["_goggles", ""]];

//change clothes if specified
removeAllItems _unit;
if (_uniform != "") then
{
	_unit addUniform _uniform;
};

if (_vest != "") then
{
	_unit addVest _vest;
};

if (_backpack != "") then
{
	_unit addBackpack _vest;
};

if (_headgear != "") then
{
	_unit addHeadgear _headgear;
};

if (_goggles != "") then
{
	_unit addGoggles _goggles;
};

//change weapons if specified
private _primaryMags = [];
private _secondaryMags = [];
if (_primary != "") then
{
	_unit addWeapon _primary;
	private _m = getArray (configFile >> "CfgWeapons" >> _primary >> "magazines") select 0;
	for "_i" from 1 to 3 do
	{
		_primaryMags pushBack _m;
	};
	_unit addWeaponItem [_primary, _m];
};

if (_secondary != "") then
{
	_unit addWeapon _secondary;
	private _m = getArray (configFile >> "CfgWeapons" >> _secondary >> "magazines") select 0;
	for "_i" from 1 to 3 do
	{
		_secondaryMags pushBack _m;
	};
	_unit addHandgunItem _m;
};

//add items if specified
removeAllAssignedItems _unit;
removeAllItems _unit;
{
	if (_unit canAdd _x) then
	{
		_unit addItem _x;
	};
} forEach _otherItems;

{
	_unit addMagazine _x;
} forEach _primaryMags + _secondaryMags;

{
	_unit linkItem _x;
} forEach _linkedItems;
