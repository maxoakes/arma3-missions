_target = (_this select 0);
_caller = (_this select 1);
_numMags = (_this select 3);
_magazines = getArray (configFile >> "CfgWeapons" >> currentWeapon _caller >> "magazines");
_regularMag = _magazines select 0;
_magName = getText (configFile >> "CfgMagazines" >> _regularMag >> "displayName");

for "_i" from 1 to _numMags do {
	player addMagazine _regularMag;
	sleep 0.1;
};
	
hint format ["Filled inventory with %1.", _magName];
