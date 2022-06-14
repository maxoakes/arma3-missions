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
blackListedMarkers = ["respawn_west","plane_spawn"];
vehicleSpawnRadius = 50;
maxSpawnDistance = "TargetSize" call BIS_fnc_getParamValue;
sectorSize = "SectorSize" call BIS_fnc_getParamValue;
maxGradient = .45;
maxDistFromArea = 75;
battlegroundCenterObject = "Land_PhoneBooth_01_F";

spawnCenter = getMarkerPos "respawn_west";
spawnCenterRadius = getMarkerSize "respawn_west" select 0;

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
[false] execVM "base\createSpawn.sqf"; //create spawn area with vehicle spawn pillars
[false] execVM "base\getLocations.sqf"; //create list of locations to teleport to
[false] execVM "base\getVehicles.sqf"; //fill pillars with all vehicles

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
