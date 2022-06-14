//param inits
setDate [2018, 3, 30, ("Time" call BIS_fnc_getParamValue), 0];
0 setFog ("Fog" call BIS_fnc_getParamValue)/100;
0 setOvercast ("Clouds" call BIS_fnc_getParamValue)/100;
0 setRain ("Rain" call BIS_fnc_getParamValue)/100;

if (rain > 0.6) then {0 setLightnings rain};
0 setWaves (overcast+rain)/2;
forceWeatherChange;

//global vars
waveCount = "SectorWaveCount" call BIS_fnc_getParamValue;
unitsPerWave = "SectorWaveUnitCount" call BIS_fnc_getParamValue;
sectorSize = 100;
originalBoatPosition = getPos target_boat;
blackListedMarkers = ["baseCamp","armoryArea"];
spawnHeightAboveSeaLevel = 2.5;
armorySize = 500;
armoryLocation = getMarkerPos "armoryArea";
"armoryArea" setMarkerSize [armorySize, armorySize];
maxSpawnDistance = "TargetSize" call BIS_fnc_getParamValue;
sectorSize = "SectorSize" call BIS_fnc_getParamValue;
maxGradient = .45;
locationTeleportArea = 75;
centerObject = "Land_PhoneBooth_01_F";
centerVehicleObject = "Land_City_Pillar_F";

unitSoldierType = "O_Soldier_F";
unitCQCType = "O_Soldier_AT_F";
unitSniperType = "O_sniper_F";
unitCrewType = "O_helicrew_F";
vehicleTechnicalType = "O_G_Offroad_01_armed_F";
vehicleTankType = "O_MBT_02_cannon_F";
vehicleHeloType = "O_Heli_Attack_02_F";
vehicleBusType = "C_Truck_02_covered_F";
helperType = "Sign_Arrow_Large_F";

//Autoruns
player execVM "simpleEP.sqf";
[false] execVM "base\getLocations.sqf";
[false] execVM "base\getVehicles.sqf";
defense addEventHandler ["Fired",{(_this select 0) setVehicleAmmo 1}];
defense allowDamage false;
defense lockDriver true;

arsenal allowDamage false; 
arsenal addAction ["Heal Yourself","(_this select 1) setDamage 0;"];
arsenal addAction ["Add ammo for this Weapon","base\fillMag.sqf"];

missions allowDamage false;
missions addAction ["Create a Capture and Hold Mission",{"mission\capture.sqf" remoteExec ["execVM", 2];}];

target_boat_control allowDamage false;
target_boat_control addAction ["Set Boat to original position","base\boat.sqf",0];
target_boat_control addAction ["Set Boat to 25 meters","base\boat.sqf",25];
target_boat_control addAction ["Set Boat to 50 meters","base\boat.sqf",50];
target_boat_control addAction ["Set Boat to 100 meters","base\boat.sqf",100];
target_boat_control addAction ["Set Boat to 200 meters","base\boat.sqf",200];
target_boat_control addAction ["Set Boat to 300 meters","base\boat.sqf",300];
target_boat_control addAction ["Set Boat to 400 meters","base\boat.sqf",400];
target_boat_control addAction ["Set Boat to 500 meters","base\boat.sqf",500];
target_boat_control addAction ["Set Boat to 600 meters","base\boat.sqf",600];
target_boat_control addAction ["Set Boat to 700 meters","base\boat.sqf",700];
target_boat_control addAction ["Set Boat to 800 meters","base\boat.sqf",800];
target_boat_control addAction ["Set Boat to 900 meters","base\boat.sqf",900];
target_boat_control addAction ["Set Boat to 1000 meters","base\boat.sqf",1000];
target_boat_control addAction ["Set Boat to 1200 meters","base\boat.sqf",1200];
target_boat_control addAction ["Set Boat to 1400 meters","base\boat.sqf",1400];
target_boat_control addAction ["Set Boat to 1600 meters","base\boat.sqf",1600];

//create Armory Zone
_armoryCenterWallWest = createVehicle ["Land_BagFence_Round_F", [(getMarkerPos "armoryArea" select 0)-2,(getMarkerPos "armoryArea" select 1)], [], 0, "CAN_COLLIDE"];
_armoryCenterWallEast = createVehicle ["Land_BagFence_Round_F", [(getMarkerPos "armoryArea" select 0)+2,(getMarkerPos "armoryArea" select 1)], [], 0, "CAN_COLLIDE"];
_armoryCenterWallNorth = createVehicle ["Land_BagFence_Round_F", [(getMarkerPos "armoryArea" select 0),(getMarkerPos "armoryArea" select 1)+2], [], 0, "CAN_COLLIDE"];
_armoryCenterWallSouth = createVehicle ["Land_BagFence_Round_F", [(getMarkerPos "armoryArea" select 0),(getMarkerPos "armoryArea" select 1)-2], [], 0, "CAN_COLLIDE"];
_armoryCenterWallWest setDir 90;
_armoryCenterWallEast setDir 270;
_armoryCenterWallNorth setDir 180;
_armoryCenterWallSouth setDir 0;
_armoryCenterWallWest allowDamage false;
_armoryCenterWallEast allowDamage false;
_armoryCenterWallNorth allowDamage false;
_armoryCenterWallSouth allowDamage false;

_armoryCenterObject = createVehicle ["Sign_Sphere100cm_Geometry_F", [(getMarkerPos "armoryArea" select 0),(getMarkerPos "armoryArea" select 1),(getMarkerPos "armoryArea" select 2)+2.2], [], 0, "CAN_COLLIDE"];
_armoryCenterObject addAction ["<t color='#ff0000'>Return to base</t>","(_this select 1) setPos [(getPos respawnPad select 0),(getPos respawnPad select 1),(getPos respawnPad select 2)+spawnHeightAboveSeaLevel];"];
_armoryCenterObject addAction ["<t color='#0000ff'>Open Garage</t>",
{
	_thePlayer = (_this select 1);
	_pos = [armoryLocation, 10, armorySize, 20, 0, 0.1, 0] call BIS_fnc_findSafePos;
	_center = createVehicle ["Land_HelipadEmpty_F",_pos,[],0,"CAN_COLLIDE"];
	["Open",[true, _center]] call BIS_fnc_garage; 
}];

if (true) then {
	//Safe Zone at spawn
	_trg = createTrigger ["EmptyDetector", getMarkerPos "respawn_west", true];
	_trg setTriggerArea [15, 15, 0, true, 15];
	_trg setTriggerActivation ["ANY", "PRESENT", true];
	_trg setTriggerStatements ["player in thisList", "player allowDamage false", "player allowDamage true"];
};

//vehicle list generator for missions
vehicleList = (configFile >> "cfgVehicles") call BIS_fnc_getCfgSubClasses;
vehicleTypes = ["Car","WheeledAPC"];
vehicleLandPool = [];
{
	if (getnumber (configFile >> "cfgVehicles" >> _x >> "scope") > 1) then {
		_objectType = _x call BIS_fnc_objectType;
		if (((_objectType select 0) == "Vehicle") && ((_objectType select 1) in vehicleTypes)) then
		{
			if (!(([_x, false] call BIS_fnc_allTurrets) isEqualTo []) and (_x find "O_" != -1) and (_x find "NATO" == -1) and (_x find "_BM" == -1)) then
			{
				if (!(_x in vehicleLandPool)) then
				{
					vehicleLandPool pushBack _x;
				};
			};
		};
	};
} foreach vehicleList;

