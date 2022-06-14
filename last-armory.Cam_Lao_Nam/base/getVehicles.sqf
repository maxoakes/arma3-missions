//get config list for all vehicles
_vehicleList = (configFile >> "cfgVehicles") call BIS_fnc_getCfgSubClasses;
_vehicleTypes = ["Ship","Submarine","Helicopter","Plane"]+["Car","Motorcycle","TrackedAPC","Tank","WheeledAPC"];
_vehicleClassnames = [];
_addActionDistance = 6;


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


boat addAction [format ["<t color='#bababa'>%1","Water Vehicles"],{hint hintStr},"",8,true,true,"","true",_addActionDistance,false,"",""];
helo addAction [format ["<t color='#bababa'>%1","Helicopters"],{hint hintStr},"",8,true,true,"","true",_addActionDistance,false,"",""];
plane addAction [format ["<t color='#bababa'>%1","Planes and Jets"],{hint hintStr},"",8,true,true,"","true",_addActionDistance,false,"",""];
car addAction [format ["<t color='#bababa'>%1","Land Vehicles"],{hint hintStr},"",8,true,true,"","true",_addActionDistance,false,"",""];
apc addAction [format ["<t color='#bababa'>%1","APCs"],{hint hintStr},"",8,true,true,"","true",_addActionDistance,false,"",""];
tank addAction [format ["<t color='#bababa'>%1","Tanks"],{hint hintStr},"",8,true,true,"","true",_addActionDistance,false,"",""];

{
	//get the weapon type for sorting
	_type = _x call bis_fnc_objectType;
	_displayName = getText(configFile >> "cfgVehicles" >> _x >> "displayName");
	
	switch (_type select 1) do {
		case "Ship" : 		{boat addAction [format ["<t color='#0000ff'>%1",_displayName],"base\spawnVehicle.sqf",_x,1.5,true,true,"","true",_addActionDistance,false,"",""];};
		case "Submarine" : 	{boat addAction [format ["<t color='#0000cc'>%1",_displayName],"base\spawnVehicle.sqf",_x,1.5,true,true,"","true",_addActionDistance,false,"",""];};
		case "Helicopter" : {helo addAction [format ["<t color='#ff0000'>%1",_displayName],"base\spawnVehicle.sqf",_x,1.5,true,true,"","true",_addActionDistance,false,"",""];};
		case "Plane" : 		{plane addAction [format ["<t color='#00ff00'>%1",_displayName],"base\spawnVehicle.sqf",_x,1.5,true,true,"","true",_addActionDistance,false,"",""];};
		
		case "Car" : 		{car addAction [format ["<t color='#ffff00'>%1",_displayName],"base\spawnVehicle.sqf",_x,1.5,true,true,"","true",_addActionDistance,false,"",""];};
		case "Motorcycle" :	{car addAction [format ["<t color='#00ffff'>%1",_displayName],"base\spawnVehicle.sqf",_x,1.5,true,true,"","true",_addActionDistance,false,"",""];};
		case "TrackedAPC" : {apc addAction [format ["<t color='#00ff00'>%1",_displayName],"base\spawnVehicle.sqf",_x,1.5,true,true,"","true",_addActionDistance,false,"",""];};
		case "WheeledAPC" :	{apc addAction [format ["<t color='#00ffcc'>%1",_displayName],"base\spawnVehicle.sqf",_x,1.5,true,true,"","true",_addActionDistance,false,"",""];};
		case "Tank" : 		{tank addAction [format ["<t color='#f0ff0f'>%1",_displayName],"base\spawnVehicle.sqf",_x,1.5,true,true,"","true",_addActionDistance,false,"",""];};
		
		default				{hint format ["wut is type %1",_type]};
	};	
} forEach _vehicleClassnames;