_unit = _this;
_unit execVM "player\airStart.sqf";
_unit addEventHandler ["respawn", {(_this select 0) execVM "player\airStart.sqf"}];