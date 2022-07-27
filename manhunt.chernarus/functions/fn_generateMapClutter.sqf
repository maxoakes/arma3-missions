/*
	Author: Scouter

	Description:
		Fill the map with clutter. Clutter can be car wrecks and/or graves

	Parameter(s):
		0: Boolean - (required) perform spawning of road wrecks
		2: Array of Strings - (required) types of objects to clutter roads with
		1: Boolean - (required) perform spawning of graves in open spaces
		3: Array of Strings - (required) types of objects to clutter fields near roads with

	Returns:
		Void
*/
params ["_doSpawnWrecks", "_roadClutter", "_doSpawnGraves", "_fieldClutter"];
"Currently generating map clutter and mission objects. Please wait..." remoteExec ["systemChat", 0];

private _mapCenter = [1000, 1000, 0];

//get all locations to place clutter
private _allClutterLocations = nearestLocations [
	getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), 
	["NameVillage", "NameCity", "NameCityCapital"], worldSize];

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
			private _grave = createVehicle [selectRandom _fieldClutter, _posGrave, [], 0, "CAN_COLLIDE"];
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
			//systemChat format ["No roads near %1", _locName];
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
				private _wreckClassname = selectRandom _roadClutter;
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