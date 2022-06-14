_center = getPos (_this select 0);
_type = (_this select 3) select 0;
_skill = (_this select 3) select 1;
_amount = (_this select 3) select 2;

_targetLoc = getPos player;
_spawnPos = [getPos player, maxSpawnDistance/2, maxSpawnDistance, 20, 0, maxGradient, 0] call BIS_fnc_findSafePos;

_randomName = format ["e%1",floor random 99999999];
_marker = createMarker [_randomName, _spawnPos];
_marker setMarkerShape "ICON";
_marker setMarkerText format ["Spawn: %1", _type];
_marker setMarkerType "mil_destroy";
_marker setMarkerColor "ColorBlue";

_group = createGroup east;
_group setBehaviour "COMBAT";
_group setSpeedMode "FULL";
_group setFormation "STAG COLUMN";
_wp = _group addWaypoint [(_targetLoc), 0];
_wp setWaypointType "SAD";
_wp setWaypointCombatMode "RED";

_squadUnits = [];
_squadHelpers = [];

switch (_type) do
{
	case "Squad" : 
	{
		for "_i" from 1 to _amount do
		{
			_unit = _group createUnit [unitSoldierType, _spawnPos, [], 0, "NONE"];
			_unit setSkill _skill;

			_thing = helperType createVehicle position player;
			_thing attachTo [_unit, [0, 0, 5]];
			
			_squadUnits pushBack _unit;
			_squadHelpers pushBack _thing;
		};
		
		//while any player is alive and within sight meters of the center, and there is atleast one enemy remaining, do not despawn them
		while {(({ (alive _x) and ((getPos _x distance2D _center) < (maxSpawnDistance*2))} count allPlayers) > 0) and (({ alive _x } count units _group) > 0)} do
		{
			_wp setWPPos position player;
			sleep 3;
		};
		
		{
			vehicle _x setDamage 1;
		} foreach _squadUnits;
		
		{
			deleteVehicle _x;
		} foreach _squadHelpers;
		deleteMarker _marker;
	};
	
	case "Horde" : 
	{
		for "_i" from 1 to _amount do
		{
			_unit = _group createUnit [unitSoldierType, _spawnPos, [], 0, "NONE"];
			_unit setSkill _skill;

			_thing = helperType createVehicle position player;
			_thing attachTo [_unit, [0, 0, 5]];
			
			_squadUnits pushBack _unit;
			_squadHelpers pushBack _thing;
		};
		
		while {(({ (alive _x) and ((getPos _x distance2D _center) < (maxSpawnDistance*2))} count allPlayers) > 0) and (({ alive _x } count units _group) > 0)} do
		{
			_wp setWPPos position player;
			sleep 3;
		};
		
		{
			vehicle _x setDamage 1;
		} foreach _squadUnits;
		
		{
			deleteVehicle _x;
		} foreach _squadHelpers;
		deleteMarker _marker;
	};
	
	case "Snipers" : 
	{
		for "_i" from 1 to _amount do
		{
			_unit = _group createUnit [unitSniperType, _spawnPos, [], 0, "NONE"];
			_unit setSkill _skill;

			_thing = helperType createVehicle position player;
			_thing attachTo [_unit, [0, 0, 5]];
			
			_squadUnits pushBack _unit;
			_squadHelpers pushBack _thing;
		};
		
		while {(({ (alive _x) and ((getPos _x distance2D _center) < (maxSpawnDistance*2))} count allPlayers) > 0) and (({ alive _x } count units _group) > 0)} do
		{
			_wp setWPPos position player;
			sleep 3;
		};
		
		{
			vehicle _x setDamage 1;
		} foreach _squadUnits;
		
		
		{
			deleteVehicle _x;
		} foreach _squadHelpers;
		deleteMarker _marker;
	};
	
	case "Aimbot" : 
	{
		for "_i" from 1 to _amount do
		{
			_unit = _group createUnit [unitCQCType, _spawnPos, [], 0, "NONE"];
			_unit setSkill _skill;
			
			_thing = helperType createVehicle position player;
			_thing attachTo [_unit, [0, 0, 5]];
			
			_squadUnits pushBack _unit;
			_squadHelpers pushBack _thing;
		};
		
		while {(({ (alive _x) and ((getPos _x distance2D _center) < (maxSpawnDistance*2))} count allPlayers) > 0) and (({ alive _x } count units _group) > 0)} do
		{
			_wp setWPPos position player;
			sleep 3;
		};
		
		{
			vehicle _x setDamage 1;
		} foreach _squadUnits;
		
		{
			deleteVehicle _x;
		} foreach _squadHelpers;
		deleteMarker _marker;
	};
	
	case "Technicals" :
	{	
		for "_i" from 1 to _amount do
		{
			_veh = createVehicle [vehicleTechnicalType, _spawnPos, [], 5, "NONE"];
			
			_squadUnits append ([_veh,_group] call BIS_fnc_spawnCrew);
			{
				_x setSkill _skill;
			} foreach _squadUnits;
			
			_squadUnits pushBack _veh;
			
			_veh lock true;
		};
		
		while {(({ (alive _x) and ((getPos _x distance2D _center) < (maxSpawnDistance*2))} count allPlayers) > 0) and (({ alive _x } count units _group) > 0)} do
		{
			_wp setWPPos position player;
			sleep 3;
		};
		
		{
			vehicle _x setDamage 1;
		} foreach _squadUnits;
		
		deleteMarker _marker;
	};
	
	case "Tank" :
	{	
		for "_i" from 1 to _amount do
		{
			_veh = createVehicle [vehicleTankType, _spawnPos, [], 10, "NONE"];
			
			_squadUnits append ([_veh,_group] call BIS_fnc_spawnCrew);
			{
				_x setSkill _skill;
			} foreach _squadUnits;
			
			_squadUnits pushBack _veh;
			
			_veh lock true;
		};
		
		while {(({ (alive _x) and ((getPos _x distance2D _center) < (maxSpawnDistance*2))} count allPlayers) > 0) and (({ alive _x } count units _group) > 0)} do
		{
			_wp setWPPos position player;
			sleep 3;
		};
		
		{
			vehicle _x setDamage 1;
		} foreach _squadUnits;
		
		deleteMarker _marker;
	};
	
	case "Helo" :
	{	
		for "_i" from 1 to _amount do
		{
			_veh = createVehicle [vehicleHeloType, _spawnPos, [], 0, "FLY"];
			
			_squadUnits append ([_veh,_group] call BIS_fnc_spawnCrew);
			{
				_x setSkill _skill;
			} foreach _squadUnits;
			
			_squadUnits pushBack _veh;
		};
		
		while {(({ (alive _x) and ((getPos _x distance2D _center) < (maxSpawnDistance*2))} count allPlayers) > 0) and (({ alive _x } count units _group) > 0)} do
		{
			_wp setWPPos position player;
			sleep 3;
		};
		
		{
			vehicle _x setDamage 1;
		} foreach _squadUnits;
		
		deleteMarker _marker;
	};
	
	case "DayZ Special" :
	{	
		for "_i" from 1 to _amount do
		{
			_veh = createVehicle [vehicleBusType, _spawnPos, [], 10, "NONE"];
			
			for "_j" from 1 to 17 do
			{
				_unit = _group createUnit [unitCrewType, _spawnPos, [], 0, "NONE"];
				_unit setSkill _skill;
				_squadUnits pushBack _unit;				
			};
			_squadUnits pushBack _veh;
			
			(_squadUnits select 0) moveInDriver _veh;
			for "_j" from 1 to 16 do
			{
				(_squadUnits select _j) moveInCargo _veh;		
			};
			
			//_veh lock true;
		};
		
		//while any player is alive and within 1200 meters of this enemies spawn, and there is atleast one enemy remaining, do not despawn them
		while {(({ (alive _x) and ((getPos _x distance2D _spawnPos) < (maxSpawnDistance*2))} count allPlayers) > 0) and (({ alive _x } count units _group) > 0)} do
		{
			_wp setWPPos position player;
			sleep 3;
		};
		
		{
			vehicle _x setDamage 1;
		} foreach _squadUnits;
		
		deleteMarker _marker;
	};
	
	default
	{
		hint "wut";
	};
};



