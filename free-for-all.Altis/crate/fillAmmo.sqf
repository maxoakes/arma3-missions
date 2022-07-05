_thePlayer = (_this select 1);
package removeAction addActionAmmo;

_weapon = currentWeapon _thePlayer;
_mag = (getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines")) select 0;

for "_i" from 1 to 12 do {
	_thePlayer addMagazine _mag;
	sleep 0.1;
};
	
hint format ["Filled inventory with %1 for %2.",getText (configFile >> "CfgMagazines" >> _mag >> "displayName"),getText (configFile >> "CfgWeapons" >> _weapon >> "displayName")];
