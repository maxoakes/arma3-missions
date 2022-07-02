//add a specified number of the appropriate mag to the weapon that the caller is holding
//returns nothing
params ["_target", "_caller", "_actionId", "_numMags"];

private _magazines = getArray (configFile >> "CfgWeapons" >> currentWeapon _caller >> "magazines");
private _regularMag = _magazines select 0;
private _magName = getText (configFile >> "CfgMagazines" >> _regularMag >> "displayName");

for "_i" from 1 to _numMags do {
	player addMagazine _regularMag;
	sleep 0.1;
};
	
hint format ["Filled inventory with %1.", _magName];