boat allowDamage false;
plane allowDamage false;
helo allowDamage false;

car allowDamage false;
apc allowDamage false;
tank allowDamage false;

//get config list for all vehicles
_vehicleList = (configFile >> "cfgVehicles") call BIS_fnc_getCfgSubClasses;
_vehicleTypes = ["Ship","Submarine","Helicopter","Plane"]+["Car","Motorcycle","TrackedAPC","Tank","WheeledAPC"];
_vehicleClassnames = [];

//get list of land vehicles for spawning
{
	if (getnumber (configFile >> "cfgVehicles" >> _x >> "scope") > 1) then {
		_objectType = _x call BIS_fnc_objectType;
		if (((_objectType select 0) == "Vehicle") && ((_objectType select 1) in _vehicleTypes)) then
		{
			if (!(_x in _vehicleClassnames)) then
			{
				_vehicleClassnames pushBack _x;
			};
		};
	};
} foreach _vehicleList;

{
	//get the weapon type for sorting
	_type = _x call bis_fnc_objectType;
	_displayName = getText(configFile >> "cfgVehicles" >> _x >> "displayName");
	
	switch (_type select 1) do {
		case "Ship" : 		{boat addAction [format ["<t color='#0000ff'>%1",_displayName],"base\spawnVehicle.sqf",_x];};
		case "Submarine" : 	{boat addAction [format ["<t color='#0000cc'>%1",_displayName],"base\spawnVehicle.sqf",_x];};
		case "Helicopter" : {helo addAction [format ["<t color='#ff0000'>%1",_displayName],"base\spawnVehicle.sqf",_x];};
		case "Plane" : 		{plane addAction [format ["<t color='#00ff00'>%1",_displayName],"base\spawnVehicle.sqf",_x];};
		
		case "Car" : 		{car addAction [format ["<t color='#ffff00'>%1",_displayName],"base\spawnVehicle.sqf",_x];};
		case "Motorcycle" :	{car addAction [format ["<t color='#00ffff'>%1",_displayName],"base\spawnVehicle.sqf",_x];};
		case "TrackedAPC" : {apc addAction [format ["<t color='#00ff00'>%1",_displayName],"base\spawnVehicle.sqf",_x];};
		case "WheeledAPC" :	{apc addAction [format ["<t color='#00ffcc'>%1",_displayName],"base\spawnVehicle.sqf",_x];};
		case "Tank" : 		{tank addAction [format ["<t color='#f0ff0f'>%1",_displayName],"base\spawnVehicle.sqf",_x];};
		
		default				{hint format ["wut is type %1",_type]};
	};	
} forEach _vehicleClassnames;