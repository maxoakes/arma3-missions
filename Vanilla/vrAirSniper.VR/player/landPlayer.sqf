_unit = _this;
_unit execVM "player\landStart.sqf";
_unit addEventHandler ["respawn", {(_this select 0) execVM "player\landStart.sqf"}];