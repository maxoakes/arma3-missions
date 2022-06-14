_magazines = getArray (configFile >> "CfgWeapons" >> currentWeapon (_this select 1) >> "magazines");
_regularMag = _magazines select 0;

for "_i" from 1 to 4 do {
	player addMagazine _regularMag;
	sleep 0.01;
};
	
hint format ["Filled inventory with %1.",getText (configFile >> "CfgMagazines" >> _regularMag >> "displayName")];
