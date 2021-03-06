//give the caller a random primary weapon. Also give a number of mags, and random attachments.
//if it is night time, try to add a mounted flashlight and tracer rounds.
//returns nothing
params ["_target", "_caller"];

private _allWeapons = (configFile >> "cfgWeapons") call BIS_fnc_getCfgSubClasses;
private _possibleWeaponTypes = [
	"AssaultRifle", "MachineGun",
	"SniperRifle", "Shotgun",
	"Rifle", "SubmachineGun"];

private _possiblePrimaries = [];
{
	//check if usable weapon
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

//delete primary weapon and its ammo
private _possibleCurrentPrimaryMags = getArray (configFile >> "CfgWeapons" >> primaryWeapon _caller >> "magazines");
{
	_caller removeMagazines _x;
} forEach _possibleCurrentPrimaryMags;
removeAllPrimaryWeaponItems _caller;
_caller removeWeapon primaryWeapon _caller;

private _isDayTime = call compile preprocessFile "functions\fn_isDayTime.sqf";

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