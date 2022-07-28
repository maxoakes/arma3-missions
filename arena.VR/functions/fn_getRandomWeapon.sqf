/*
	Author: Scouter

	Description:
		Gives the player a random weapon with random attachments.
		Built to be called via addAction.

	Parameter(s):
		0: Object - The object that that the player is aiming at (unused)
		1: Object - The player
		2: Number - Action ID (unused)
		3: Array of Strings - number of magazines to add the player inventory

	Returns:
		Void
*/
params ["_target", "_caller", "_id", "_possibleWeaponTypes"];

private _allWeapons = (configFile >> "cfgWeapons") call BIS_fnc_getCfgSubClasses;

//get all possible primary weapons via configs
private _possiblePrimaries = [];
{
	if (getnumber (configFile >> "cfgWeapons" >> _x >> "scope") > 1) then {
		private _itemType = _x call bis_fnc_itemType;
		if (((_itemType select 0) == "Weapon") && ((_itemType select 1) in _possibleWeaponTypes)) then
		{
			private _baseName = _x call BIS_fnc_baseWeapon;
			if (!(_baseName in _possiblePrimaries)) then
			{
				_possiblePrimaries pushBack _baseName;
			};
		};
	};
} foreach _allWeapons;

//delete the current primary weapon and its ammo
{
	_caller removeMagazines _x;
} forEach getArray (configFile >> "CfgWeapons" >> primaryWeapon _caller >> "magazines");
_caller removeWeapon primaryWeapon _caller;

private _isDayTime = [] call SCO_fnc_isDayTime;

//add primary weapon
private _selectedPrimary = selectRandom _possiblePrimaries;
_caller addWeapon _selectedPrimary;
private _selectedPrimaryMag = selectRandom ([_selectedPrimary, !_isDayTime] call compile preprocessFile "functions\fn_getRoundsForWeapon.sqf");
_caller addPrimaryWeaponItem _selectedPrimaryMag;
for "_i" from 1 to 4 do {
	_caller addMagazine _selectedPrimaryMag;
	sleep 0.1;
};

_weaponItems = (primaryWeapon _caller) call BIS_fnc_compatibleItems;
for "_j" from 1 to 6 do {
	_caller addPrimaryWeaponItem selectRandom _weaponItems;
	sleep 0.1;
};

if (!_isDayTime) then
{
	_caller addPrimaryWeaponItem "acc_flashlight";
	_caller addPrimaryWeaponItem "acc_flashlight_smg_01"; //in case the first one fails
};

hint format ["Obtained %1.", getText (configFile >> "cfgWeapons" >> _selectedPrimary >> "DisplayName")];