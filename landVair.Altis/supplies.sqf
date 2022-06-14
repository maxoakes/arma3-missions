// Settings
_amountLauncher = 5;
_amountRocket = 15;
_amountItem = 5;
_amountBoom = 5;
_this allowDamage false;
clearWeaponCargoGlobal _this;
clearItemCargoGlobal _this;
clearBackpackCargoGlobal _this;
clearMagazineCargoGlobal _this;

_this addMagazineCargoGlobal ["ATMine_Range_Mag", _amountBoom];
_this addMagazineCargoGlobal ["APERSMine_Range_Mag", _amountBoom];
_this addMagazineCargoGlobal ["ClaymoreDirectionalMine_Remote_Mag", _amountBoom];
_this addMagazineCargoGlobal ["DemoCharge_Remote_Mag", _amountBoom];
_this addMagazineCargoGlobal ["APERSBoundingMine_Range_Mag", _amountBoom];
_this addMagazineCargoGlobal ["SLAMDirectionalMine_Wire_Mag", _amountBoom];
_this addMagazineCargoGlobal ["APERSTripMine_Wire_Mag", _amountBoom];
_this addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", _amountBoom];
_this addMagazineCargoGlobal ["HandGrenade", _amountBoom];

_this AddWeaponCargoGlobal ["launch_I_Titan_F", _amountLauncher*2];
_this AddMagazineCargoGlobal ["Titan_AA", _amountRocket*2];
_this AddWeaponCargoGlobal ["launch_I_Titan_short_F", _amountLauncher];
_this AddMagazineCargoGlobal ["Titan_AP", _amountRocket];
_this AddMagazineCargoGlobal ["Titan_AT", _amountRocket];
_this AddWeaponCargoGlobal ["launch_NLAW_F", _amountLauncher];
_this AddMagazineCargoGlobal ["NLAW_F", _amountRocket];
_this addWeaponCargoGlobal ["launch_RPG32_F", _amountLauncher];
_this AddMagazineCargoGlobal ["RPG32_F", _amountRocket];
_this AddMagazineCargoGlobal ["RPG32_HE_F", _amountRocket];