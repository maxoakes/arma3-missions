_list = nearestObjects [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), ["CraterLong"], worldSize];
{deleteVehicle _x} foreach _list;