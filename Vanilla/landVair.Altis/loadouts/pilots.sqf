_unit = _this;

_unit enableFatigue false;
removeAllWeapons _unit;
removeBackpackGlobal _unit;
removeGoggles _unit;
removeVest _unit;

_unit addMagazine "11Rnd_45ACP_Mag";
_unit addWeapon "hgun_Pistol_heavy_01_MRD_F";
_unit addMagazine "30Rnd_9x21_Mag";
_unit addWeapon "hgun_PDW2000_F";
_marker = createMarkerLocal ["target", getMarkerPos "border"];
"target" setMarkerShapeLocal "icon";
"target" setMarkerTypeLocal "hd_destroy";
"target" setMarkerColorLocal "ColorRed";
"target" setMarkerTextLocal "Rebel Base";