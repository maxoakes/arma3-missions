_allBuildingsOnMap = nearestObjects [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), ["House", "Building"], worldSize/1.5];
_blackListedArea0 = nearestObjects [getMarkerPos "respawn_west", ["House", "Building"], 2000];
_blackListedArea1 = nearestObjects [getMarkerPos "armoryArea", ["House", "Building"], 1000];
_availableCenter = _allBuildingsOnMap - _blackListedArea0 - _blackListedArea1;

_location = getPos (_availableCenter select (random count _availableCenter));
_locationName = text ((nearestLocations[_location,["NameVillage","NameCity","NameCityCapital","NameLocal"],2000]) select 0);

_groupLogic = createGroup sideLogic;
_module = _groupLogic createUnit ["ModuleSector_F",_location,[],0,"CAN_COLLIDE"];
_module setVariable ["CostAir","1"];
_module setVariable ["CostInfantry","1"];
_module setVariable ["CostPlayers","1"];
_module setVariable ["CostTracked","3"];
_module setVariable ["CostWater","1"];
_module setVariable ["CostWheeled","2"];

_module setVariable ["DefaultOwner","0"];
_module setVariable ["Name",_locationName];
_module setVariable ["OnOwnerChange",""];
_module setVariable ["OwnerLimit","1"];
_module setVariable ["TaskDescription","Capture %1 from OPFOR then defend the sector until the time runs out."];
_module setVariable ["TaskOwner","2"];
_module setVariable ["TaskTitle","Capture and Defend %1"];
_module setVariable ["sides",[east,west]];
_module setvariable ["BIS_fnc_initModules_disableAutoActivation", false ];

waitUntil {!isNil {_module getVariable [ "finalized", nil ]} && {!(_module getVariable [ "finalized", true ])}};

//trigger
_trgSize = sectorSize;
_module setVariable [ "size", sectorSize];
[_module,[],true,"area"] call BIS_fnc_moduleSector;

_trg = (_module getVariable "areas") select 0;
_mrk = (_trg getVariable "markers") select 0;
_mrk setMarkerSize [_trgSize, _trgSize];

//spawn initial opfor defense
_amountSquads = floor random [2,2,4];

for "_i" from 1 to _amountSquads do
{
	_amountUnits = floor random [2,3,6];
	_safePos = [_location, 0, sectorSize, 5, 0, 0, 0,[], [_location, _location]] call BIS_fnc_findSafePos;
	_group = [_safePos, EAST, _amountUnits] call BIS_fnc_spawnGroup;
	{
		_x setSkill random [0.2, 0.4, 0.7];
	} foreach units _group;
	_wp =_group addWaypoint [_location, 0];
	[_group, 0] setWaypointCombatMode "RED";
	[_group, 0] setWaypointBehaviour "AWARE";
	[_group, 0] setWaypointType "HOLD";
	systemChat format ["Spawned %1 units.", _amountUnits];
};
for "_i" from 1 to floor (_amountSquads/1.5) do
{
	_group = createGroup [east, true];
	_thisType = vehicleLandPool select (floor random (count vehicleLandPool));
	_safePos = [_location, 0, sectorSize, 5, 0, 0, 0,[], [_location, _location]] call BIS_fnc_findSafePos;	
	_vehArray = [_safePos, 0, _thisType, _group] call bis_fnc_spawnvehicle;
	
	{
		_x setSkill random [0.2, 0.4, 0.7];
	} foreach units _group;
	
	[_group, 0] setWaypointCombatMode "RED";
	[_group, 0] setWaypointBehaviour "CARELESS";
	[_group, 0] setWaypointType "HOLD";
	systemChat format ["Spawned %1", _thisType];
};

//wait until sector is under west control
systemChat "Waiting until side owner west";
waitUntil {sleep 1; _module getVariable "owner" == west};
systemChat "Side owner is west";

[_module,_trg,_location] spawn
{	
	systemChat "Wait until side owner is east";
	waitUntil {sleep 5; (_this select 0) getVariable "owner" == east};
	_allMissionUnits = (nearestObjects [(_this select 2), ["Man","LandVehicle"], sectorSize*4]) - allPlayers;
	{deleteVehicle _x} foreach _allMissionUnits;
	
	[format ["Mission failed at %1 capture zone.",((_this select 0) getVariable "Name")],"systemChat"] call BIS_fnc_MP;
	deleteVehicle (_this select 0);
	deleteVehicle (_this select 1);
};

//spawn more shit from random directions, all waypoint'd toward sector
for "_i" from 1 to waveCount do
{
	if (isNull _module) exitWith {systemChat "isNil _module"};
	[format ["Spawning wave %1 at %2 capture zone.", _i,(_module getVariable "Name")],"systemChat"] call BIS_fnc_MP;
	_numUnits = unitsPerWave*_i;
	_safePos = [_location, sectorSize+100, (sectorSize*2)+100, 5, 0, 0, 0] call BIS_fnc_findSafePos;
	_group = [_safePos, EAST, _numUnits] call BIS_fnc_spawnGroup;
	{
		_x setSkill random [0.2, 0.4, 0.7];
	} foreach units _group;
	
	if ((_i mod 2) == 0) then
	{
		_thisType = vehicleLandPool select (floor random (count vehicleLandPool));
		_vehArray = [[_safePos, 10, 60, 5, 0, 0, 0] call BIS_fnc_findSafePos, 0, _thisType, _group] call bis_fnc_spawnvehicle;
	};
	
	_wp =_group addWaypoint [_location, 0];
	[_group, 0] setWaypointCombatMode "RED";
	[_group, 0] setWaypointBehaviour "SAFE";
	[_group, 0] setWaypointType "MOVE";
	[_group, 0] setWaypointFormation "WEDGE";
	
	_startMarker = createMarker [(str _i),(getPos ((units _group) select 0))];
	_startMarker setMarkerShape "ICON";
	_startMarker setMarkerType "mil_arrow";
	_startMarker setMarkerColor "ColorOPFOR";
	_startMarker setMarkerDir ([((units _group) select 0),_module] call BIS_fnc_relativeDirTo);
	_startMarker setMarkerText format ["Wave %1 start point", _i];
	
	systemChat format ["Spawned %1 units.", _numUnits];
	systemChat "Waiting until all units are dead";
	waitUntil {sleep 1; ({alive _x} count units _group == 0)};
	deleteMarker _startMarker;
};

if (!(isNull _module)) then
{
	_allMissionUnits = (nearestObjects [_location, ["Man"], 1500]) - allPlayers;
	{deleteVehicle _x} foreach _allMissionUnits;
	[format ["congration, you done it. %1 capture zone is cleared.",(_module getVariable "Name")],"systemChat"] call BIS_fnc_MP;

	deleteVehicle _module;
	deleteVehicle _trg;
}
else
{
	systemChat "Cannot end with win statements.";
};

[["Returning all nearby players to the spawn..."],"systemChat"] call BIS_fnc_MP;
sleep 2;
_allPlayers = (nearestObjects [_location, ["Man"], sectorSize*4]) arrayIntersect allPlayers;
{
	_x setPos [(getPos respawnPad select 0),(getPos respawnPad select 1),(getPos respawnPad select 2)+spawnHeightAboveSeaLevel];
} foreach _allPlayers;
