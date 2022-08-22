/*
	Author: Scouter

	Description:
		Gets the current weapon and adds a number of magazines for that weapon to the player inventory.
		Should be called only from addAction call

	Parameter(s):
		0: Object - The object that that the player is aiming at (unused)
		1: Object - The player
		2: Number - Action ID (unused)
		3: Number - number of magazines to add the player inventory

	Returns:
		Void
*/
params ["_target", "_caller", "_actionId", "_numMags"];

if (currentWeapon _caller != "") then
{
	private _possibleMuzzles = currentMuzzle _caller; getArray (configFile >> "CfgWeapons" >> currentWeapon _caller >> "muzzles");
	private _currentMuzzle = currentMuzzle _caller;

	private _magazines = [];
	if (_currentMuzzle == currentWeapon _caller) then
	{
		_magazines = getArray (configFile >> "CfgWeapons" >> currentWeapon _caller >> "magazines");
	}
	else
	{
		_magazines = getArray (configFile >> "CfgWeapons" >> currentWeapon _caller >> _currentMuzzle >> "magazines");
	};

	private _regularMag = _magazines select 0;
	private _magName = getText (configFile >> "CfgMagazines" >> _regularMag >> "displayName");

	for "_i" from 1 to _numMags do
	{
		_caller addMagazine _regularMag;
		sleep 0.1;
	};
		
	hint format ["Filled inventory with %1.", _magName];
}
else
{
	hint "You are not holding a weapon.";
};
