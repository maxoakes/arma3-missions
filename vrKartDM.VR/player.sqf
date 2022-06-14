_unit = _this;
removeAllWeapons _unit;
removeAllItems _unit;
_unit addRating -2500;
_veh = createVehicle ["C_Kart_01_F", position player, [], 0, "FLY"];
_unit moveInDriver _veh;
(vehicle _unit) execVM "random.sqf";
(vehicle _unit) addAction ["Explosive Suicide","boom.sqf"];
(vehicle _unit) addAction ["Leap","leap.sqf"];
(vehicle _unit) addAction ["Speed Boost","velocityUp.sqf"];
(vehicle _unit) lock true;


_unit addEventHandler ["respawn", {removeallweapons (_this select 0)}];
_unit addEventHandler ["respawn", {removeAllItems (_this select 0)}];
_unit addEventHandler ["respawn", {_veh = createVehicle ["C_Kart_01_F", position player, [], 0, "FLY"]; player moveInDriver _veh;}];
_unit addEventHandler ["respawn", {(vehicle player) execVM "random.sqf"; (vehicle player) lock true;}];
_unit addEventHandler ["respawn", {(vehicle player) addAction ["Explosive Suicide","boom.sqf"]}];
_unit addEventHandler ["respawn", {(vehicle player) addAction ["Leap","leap.sqf"]}];
_unit addEventHandler ["respawn", {(vehicle player) addAction ["Speed Boost","velocityUp.sqf"]}];