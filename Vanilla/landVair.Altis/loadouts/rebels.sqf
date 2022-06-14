_unit = _this;

_unit enableFatigue false;

removeAllWeapons _unit;
removeBackpackGlobal _unit;
removeGoggles _unit;
removeVest _unit;

_unit addVest "V_PlateCarrierIA2_dgtl";
_unit addBackpackGlobal "B_Carryall_oucamo";
_unit addMagazine "11Rnd_45ACP_Mag";
_unit addWeapon "hgun_Pistol_heavy_01_MRD_F";