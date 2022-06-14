removeAllWeapons _this;
removeAllItems _this;
_this enableFatigue false;
_this allowDamage false;

_this addWeapon "hgun_Rook40_F";
_this addMagazine "16Rnd_9x21_Mag";
_this addMagazine "16Rnd_9x21_Mag";
_this addMagazine "16Rnd_9x21_Mag";

_this addEventHandler ["respawn", {removeallweapons _this}];
_this addEventHandler ["respawn", {removeAllItems _this}];
_this addEventHandler ["respawn", {_this addWeapon "hgun_Rook40_F"}];
_this addEventHandler ["respawn", {_this addMagazine "16Rnd_9x21_Mag"}];
_this addEventHandler ["respawn", {_this addMagazine "16Rnd_9x21_Mag"}];
_this addEventHandler ["respawn", {_this addMagazine "16Rnd_9x21_Mag"}];
_this addEventHandler ["respawn", {_this enableFatigue false}];