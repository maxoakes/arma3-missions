//apply time and weather settings
setDate [2018, 10, 15, ("Time" call BIS_fnc_getParamValue), 0];
setTimeMultiplier ("TimeScale" call BIS_fnc_getParamValue);
0 setOvercast ("OvercastPercent" call BIS_fnc_getParamValue)/100;
0 setFog ("FogPercent" call BIS_fnc_getParamValue)/100;
0 setRain ("RainPercent" call BIS_fnc_getParamValue)/100;
forceWeatherChange;

//global variables
REVEAL_WARLORD_MEETING = false;
CONFIRMED_KILL = false;

if (isServer) then
{
	private _startTime = diag_tickTime;
	private _hqMarker = "confirmed";
	_hqMarker setMarkerAlpha 0; //initially hide HQ marker as it is not properly set
	"meeting" setMarkerAlpha 0;

	//create the respawn inventories
	{
		[west, _x] call BIS_fnc_addRespawnInventory;
	} foreach ["Unit1", "Unit2", "Unit3", "Unit4", "Unit5", "Unit6", "Unit7", "Unit8"];

	//set up the ARMA arsenal functionality
	arsenal allowDamage false;
	clearItemCargoGlobal arsenal;
	clearWeaponCargoGlobal arsenal;
	clearMagazineCargoGlobal arsenal;
	["AmmoboxInit", [arsenal, true, { (_this distance _target) < 10 }]] call BIS_fnc_arsenal;
	[arsenal, ["Heal Yourself", "(_this select 1) setDamage 0;"]] remoteExec ["addAction", 0, true];
	[arsenal, ["Add Ammo for this Weapon", "functions\fn_refillWeapon.sqf", 4]] remoteExec ["addAction", 0, true];

	//setup exfil boat
	private _exfilMarker = [
		"exfil", //var name
		getPos exfiltration, //position
		"Exfiltration Boat", //display name
		[1, 1], //size
		"ColorBLUFOR", //color string
		"ICON", //type
		"mil_pickup" //style
	] call compile preprocessFile "functions\fn_createMarker.sqf";
	exfiltration allowDamage false;
	exfiltration lock true;

	//update marker for the boat since it is important to the mission
	[_exfilMarker, exfiltration] spawn
	{
		while {true} do
		{
			sleep 2;
			(_this select 0) setMarkerPos getPos (_this select 1);
		};
	};

	//populate the map with random graves and wrecks
	if (("Clutter" call BIS_fnc_getParamValue) == 1) then
	{
		[_mapCenter] call compile preprocessFile "functions\fn_generateMapClutter.sqf";
	};

	//once an HQ location is found, mark it on the map and delete any mass graves near it
	private _possibleHQMarkers = ["hq_"] call BIS_fnc_getMarkers;
	private _posHQ = getMarkerPos (selectRandom _possibleHQMarkers);
	_hqMarker setMarkerPos _posHQ;
	_hqMarker setMarkerAlpha 1; //show HQ marker now that it is finally set
	private _nearbyClutter = nearestObjects [_posHQ, ["Mass_Grave"], 100, true];
	{
		deleteVehicle _x;
	} forEach _nearbyClutter;

	//create the tent and get the tent object and intel within it
	private _missionObjects = [_posHQ] call compile preprocessFile "functions\fn_createHQTent.sqf";
	private _tent = _missionObjects select 0;
	private _intel = _missionObjects select 1;

	//find all location types that would be fine for a warlord meeting area
	private _allMajorLocations = nearestLocations [
		getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), 
		["Name", "NameVillage", "NameCity", "NameLocal", "Hill"], 
		worldSize
	];

	//build list of valid locations
	private _minDistanceToSpawn = 2500;
	private _minDistanceToHQ = 2000;
	private _possibleMeetingLocations = [];
	{
		private _isCity = type _x in ["NameVillage", "NameCity"];
		private _isNearbyLandmark = type _x in ["NameLocal"] and 
			count (nearestLocations [locationPosition _x, ["Name", "NameCityCapital", "NameVillage", "NameCity"], 1000]) > 0;
		private _isCloseToSpawn = (locationPosition _x distance2D getMarkerPos "respawn_west") < _minDistanceToSpawn;
		private _isCloseToHQ = (locationPosition _x distance2D getMarkerPos _hqMarker) < _minDistanceToHQ;

		if ((_isCity or _isNearbyLandmark) and !_isCloseToSpawn and !_isCloseToHQ) then
		{
			_possibleMeetingLocations pushBack _x;
		};
	} forEach _allMajorLocations;

	//pick a valid location, pick one of those buildings as a meeting area
	private _defaultMeetingPos = getMarkerPos "meeting";
	private _selectedLocation = selectRandom _possibleMeetingLocations;
	private _nearestBuildings = nearestTerrainObjects [
		locationPosition _selectedLocation, 
		["Chapel", "Fuelstation", "House", "Fortress", "Fountain", "Hospital", "Busstop", "Transmitter"], 
		((size _selectedLocation select 0) max (size _selectedLocation select 1)) max 1000];

	//find a position to place the meeting and place it
	private _meetingPosition = _defaultMeetingPos;
	if (count _nearestBuildings > 0) then
	{
		_meetingPosition = [getPos selectRandom _nearestBuildings, 2, 50, 6, 0, 0.2, 0, [], [_defaultMeetingPos, _defaultMeetingPos]] call BIS_fnc_findSafePos;
	};
	private _warlordUnits = [_meetingPosition, 3] call compile preprocessFile "functions\fn_spawnEnemyMeeting.sqf";

	//"meeting" setMarkerText format ["Scheduled meeting area at %1", text nearestLocationWithDubbing _meetingPosition];
	"meeting" setMarkerPos _meetingPosition;

	//create tasks for players on a different thread
	private _taskManager = [_tent, _intel, _meetingPosition, _warlordUnits select 0, exfiltration, end] spawn
	{
		params ["_tent", "_intel", "_posMeeting", "_warlord", "_boat", "_end"];

		[
			west, //side
			"taskKill", //id 
			[ //desc
				"It is likely that the warload is in his HQ tent. Eliminate him and confirm your kill.", 
				"Identify and Eliminate the Warlord", 
				"HQ Tent"
			], 
			_tent, //dest
			true, //state
			-1, //priority
			true, //show notification
			"kill", //type
			true //visible in 3d
		] call BIS_fnc_taskCreate;

		//wait until a unit is at the tent to continue
		waitUntil { ({_x distance2D _tent < 8} count units west) > 0 or REVEAL_WARLORD_MEETING or (CONFIRMED_KILL and !(alive _warlord)); };

		//hide task objective until the warlord is found
		[
			"taskKill",
			[
				"The warlord is not in his tent.",
				"Kill the Warlord",
				"Unknown"
			]
		] call BIS_fnc_taskSetDescription;
		["taskKill", objNull] call BIS_fnc_taskSetDestination;

		//create secondary objective to track down warlord's location
		[
			west, //side
			"taskIntel", //id 
			[ //desc
				"The warload is not at their tent. Find intel that can help ascertain his whereabouts.", 
				"Find the warlord's location", 
				"Computer"
			], 
			_intel, //dest
			true, //state
			-1, //priority
			true, //show notification
			"interact", //type
			true //visible in 3d
		] call BIS_fnc_taskCreate;

		//assign an action to the intel object to make visible the warlord meeting location
		private _intelAction = ["Read Messages", { REVEAL_WARLORD_MEETING = true; }, nil, 3, true, true, "", "true", 2];
		[_intel, _intelAction] remoteExec ["addAction", 0, true];

		//wait until someone finds the warlord's meeting location
		waitUntil { REVEAL_WARLORD_MEETING or (CONFIRMED_KILL and !(alive _warlord)); };

		//complete the secondary objective, update the primary one
		["taskIntel", "SUCCEEDED"] call BIS_fnc_taskSetState;
		["taskKill", _posMeeting] call BIS_fnc_taskSetDestination;
		"meeting" setMarkerAlpha 1;

		//wait until the kill is confirmed
		waitUntil { (CONFIRMED_KILL and !(alive _warlord)); };
		["taskKill", "SUCCEEDED"] call BIS_fnc_taskSetState;
		_boat lock false;

		//create next objective to leave the map
		[
			west, //side
			"taskBoat", //id 
			[ //desc
				"The warlord has been confirmed dead. Get to the extraction vehicle.", 
				"Get to the Extraction Vehicle", 
				"Boat"
			], 
			_boat, //dest
			true, //state
			-1, //priority
			true, //show notification
			"getin", //type
			true //visible in 3d
		] call BIS_fnc_taskCreate;

		//wait until everyone is in the boat
		waitUntil {
			sleep 0.5;
			private _everyoneInVehicle = true;
			{
				if (vehicle _x != exfiltration) then
				{
					_everyoneInVehicle = false;
				};
			} forEach call BIS_fnc_listPlayers;
			_everyoneInVehicle;
		};

		["taskBoat","SUCCEEDED"] call BIS_fnc_taskSetState;
		//update the destination when everyone is in the boat
		[
			west, //side
			"taskExfiltrate", //id 
			[ //desc
				"Use the extraction vehicle to get to the ship off of the coast.", 
				"Leave the Area", 
				"Ship"
			], 
			_end, //dest
			true, //state
			-1, //priority
			true, //show notification
			"takeoff", //type
			true //visible in 3d
		] call BIS_fnc_taskCreate;

		//wait until everyone is at the ship
		waitUntil {
			sleep 0.5;
			{alive _x} count allPlayers == {alive _x && _x distance2D _end < 200} count allPlayers;
		};

		["taskExfiltrate", "SUCCEEDED"] call BIS_fnc_taskSetState;
		"EveryoneWon" call BIS_fnc_endMissionServer;
	};
	
	_stopTime = diag_tickTime;
	(format ["%1 sec to finish init.sqf", _stopTime - _startTime]) remoteExec ["systemChat", 0];
};
