_unit = _this;
removeAllWeapons _unit;
_unit addEventHandler ["respawn", {removeallweapons (_this select 0)}];
_unit addEventHandler ["respawn", {(_this select 0) addItem "ItemGPS"}];
_unit addEventHandler ["respawn", {(_this select 0) assignItem "ItemGPS"}];
_unit addEventHandler ["respawn", {player enableFatigue false}];
player enableFatigue false;