while {true} do {
	_craters = nearestObjects [(getMarkerPos "border"), ["CraterLong"], 200];
	{deleteVehicle _x} foreach _craters;
	sleep 5;
	
	_karts = nearestObjects [(getMarkerPos "border"), ["Car"], 200];
	{if (!isPlayer (driver _x)) then {deleteVehicle _x;}} foreach _karts;
	hint "Debris Cleaned";
	sleep 120;
};