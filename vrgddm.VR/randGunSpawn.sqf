_maxGun = 25;

while {count ((getMarkerPos "mainMap") nearObjects ["groundWeaponHolder", (((getMarkerSize "mainMap") select 0))]) < _maxGun} do {sleep 1; [] execVM "randGun.sqf";};

sleep 5;

systemChat "Waiting to spawn floor guns.";
waitUntil{count ((getMarkerPos "mainMap") nearObjects ["groundWeaponHolder", (((getMarkerSize "mainMap") select 0))]) < _maxGun};

sleep 5;
