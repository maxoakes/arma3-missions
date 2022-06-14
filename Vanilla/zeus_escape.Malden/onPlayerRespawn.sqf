player enableStamina false;
player setUnitTrait ["engineer",true];
player setUnitTrait ["Medic",true];

if (backpack player isEqualTo "") then {player addBackpack "B_Carryall_cbr";};
removeAllItems player;
removeAllAssignedItems player;
{player removeMagazine _x} forEach magazines player;

_primaryMag = getArray (configFile >> "CfgWeapons" >> primaryWeapon player >> "magazines");
_handgunMag = getArray (configFile >> "CfgWeapons" >> handgunWeapon player >> "magazines");

player addPrimaryWeaponItem (_primaryMag select 0);
for "_i" from 1 to 4 do {
	player addMagazine (_primaryMag select 0);
	sleep 0.01;
};
for "_j" from 1 to 3 do {
	player addMagazine (_handgunMag select 0);
	sleep 0.01;
};

player addMagazine "MiniGrenade";
player addMagazine "MiniGrenade";
player addMagazine "SmokeShell";

player addItem "ItemGPS";
player assignItem "ItemGPS";
player addItem "ItemCompass";
player assignItem "ItemCompass";
player addItem "ItemWatch";
player assignItem "ItemWatch";
player addItem "ItemRadio";
player assignItem "ItemRadio";
player addItem "FirstAidKit";
player addItem "FirstAidKit";