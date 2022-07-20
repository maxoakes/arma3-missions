/*
	Author: Scouter

	Description:
		Fill the map with clutter. Clutter can be car wrecks and/or graves

	Parameter(s):
		0: Boolean - perform spawning of road wrecks
		1: Boolean - perform spawning of graves in open spaces

	Returns:
		Void
*/
params ["_doSpawnWrecks", "_doSpawnGraves"];
"Currently generating map clutter and mission objects. Please wait..." remoteExec ["systemChat", 0];

private _startTime = diag_tickTime;
private _mapCenter = [1000, 1000, 0];
private _allClutterLocations = nearestLocations [
	getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), 
	["NameVillage", "NameCity", "NameCityCapital"], 
	worldSize];
private _wreckClassnames = ["Land_Wreck_Skodovka_F", "Land_Wreck_Truck_F", "Land_Wreck_Car2_F", "Land_Wreck_HMMWV_F", 
	"Land_Wreck_Car_F", "Land_Wreck_Car3_F", "Land_Wreck_Van_F", "Land_Wreck_Offroad_F", "Land_Wreck_Offroad2_F",
	"Land_Wreck_UAZ_F", "Land_Wreck_Ural_F", "Land_V3S_Wreck_F", "Land_Wreck_T72_hull_F", "Land_Wreck_T72_turret_F"];
private _wreckClassnamesCUP = ["BMP2Wreck", "LADAWreck", "JeepWreck1", "JeepWreck2", "JeepWreck3", "hiluxWreck", 
	"datsun01Wreck", "datsun02Wreck", "SKODAWreck", "UAZWreck"];
private _liveVehiclesCUP = ["CUP_C_Datsun", "CUP_C_Datsun_4seat", "CUP_C_Golf4_black", "CUP_C_Golf4_blue",
	"CUP_C_Golf4_white", "CUP_C_Golf4_yellow", "C_Offroad_02_unarmed_F", "CUP_C_Octavia_CIV", "C_Tractor_01_F", 
	"CUP_C_Skoda_CR_CIV", "CUP_C_Skoda_Blue_CIV", "CUP_C_Skoda_Green_CIV", "CUP_C_Skoda_Red_CIV", "CUP_C_Skoda_White_CIV", 
	"CUP_C_Lada_CIV", "CUP_C_Lada_Red_CIV", "CUP_C_Ural_Open_Civ_03", "CUP_C_Ural_Civ_03"];

private _graves = [];
private _wrecks = [];
{
	private _locName = className _x;
	private _populationRadius = (size _x select 0) * 1.5;

	if (_doSpawnGraves) then
	{
		//create graves
		for "_i" from 0 to (ceil _populationRadius)/10 do
		{
			private _posGrave = [locationPosition _x, 0, _populationRadius, 8, 0, 0.1, 0, [], [_mapCenter, _mapCenter]] call BIS_fnc_findSafePos;
			//if the position that was found for a grave is a poor one, skip its placement
			if ((count (_posGrave nearRoads 10) > 0) or ([_mapCenter, _posGrave] call BIS_fnc_areEqual)) then
			{
				continue;
			};
			//if the position is good, place the grave
			private _grave = createVehicle ["Mass_Grave", _posGrave, [], 0, "CAN_COLLIDE"];
			_grave setDir random 360;
			_grave setVectorUp surfaceNormal getPos _grave;
			_graves pushBack _grave;
		};
	};

	if (_doSpawnWrecks) then
	{
		//create wrecks on (or very close to) roads
		private _roads = (locationPosition _x) nearRoads 1000;
		if (count _roads == 0) then
		{
			systemChat format ["No roads near %1", _locName]
		}
		else
		{
			for "_i" from 0 to (ceil _populationRadius)/10 do
			{
				private _roadSegment = selectRandom _roads;
				private _roadPos = getPos _roadSegment;
				private _posWreck = [_roadPos, 0, 10, 8, 0, 0.45, 0, [], [_mapCenter, _mapCenter]] call BIS_fnc_findSafePos;
				//check if the chosen position of the wreck is valid
				if ([_mapCenter, _posWreck] call BIS_fnc_areEqual) then
				{
					continue;
				};
				//if it is valid, continue with placement
				//small chance to have the wreck be a working vehicle
				private _wreckClassname = selectRandom (_wreckClassnames + _wreckClassnamesCUP);
				if (random 1 > 0.95) then
				{
					_wreckClassname = selectRandom _liveVehiclesCUP;
				};
				private _wreck = createVehicle [_wreckClassname, _posWreck, [], 0, "CAN_COLLIDE"];
				_wreck setDir random 360;
				_wreck setVectorUp surfaceNormal getPos _wreck;
				_wrecks pushBack _wreck;
			};
		};
	};
} forEach _allClutterLocations;

private _stopTime = diag_tickTime;
(format ["%1 sec to populate map with clutter. Wrecks: %2, Graves: %3", 
	_stopTime - _startTime, count _wrecks, count _graves]) remoteExec ["systemChat", 0];