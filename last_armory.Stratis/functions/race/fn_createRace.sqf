params ["_participants", "_lobbyMarker", "_distance", ["_possibleCustomMarkers", []]];
[format ["Creating Race via %1. isDedicated:%2, isServer:%3 hasInterface:%4", clientOwner, isDedicated, isServer, hasInterface]] call SCO_fnc_printDebug;

//add AI to race if there are not a lot of players
if (count _participants < 2) then
{
	for "_i" from (count _participants) to 2 do
	{
		private _group = createGroup [west, true];
		private _unit = _group createUnit ["B_Soldier_VR_F", getMarkerPos _lobbyMarker, [], 0, "NONE"]; 
		[_unit, format ["AI Racer %1", _i]] remoteExec ["setName", 0, true];
		_participants pushBack _unit;
	};
};

//establish what vehicle will be raced with
private _nearestVehicle = nearestObject [getMarkerPos _lobbyMarker, "LandVehicle"];
if (_nearestVehicle distance2D getMarkerPos _lobbyMarker > 20) then
{
	_nearestVehicle = objNull;
};
private _raceCarClassname = typeOf _nearestVehicle;
if (_raceCarClassname == "") then
{
	_raceCarClassname = selectRandom ["B_MRAP_01_F", "B_LSV_01_unarmed_F", "B_Quadbike_01_F", "O_MRAP_02_F", "O_LSV_02_unarmed_F", "I_MRAP_03_F"];
};

//set up starting positions
private _startPositions = [];
private _positionWidth = 6;
private _numColumns = 4;
private _numPositions = 16; //max num players
for "_i" from 0 to _numPositions-1 do
{
	private _col = _i % _numColumns;
	private _row = floor (_i / _numColumns);

	private _backOffset = _positionWidth * _row;
	private _leftOffset = _positionWidth * (_col - (_numColumns-1)/2);
	private _relPos = [_leftOffset, (-22 - _backOffset), 0];
	_startPositions pushBack _relPos;
	//[format ["starting%1", _i], race_start modelToWorld _relPos, "", [0.5, 0.5], "ColorOrange", "ICON", "mil_dot"] call SCO_fnc_createMarker;
}; 

//spawn the vehicles
private _raceVehicles = [];
for "_i" from 0 to (count _participants) - 1 do
{
	//end if there are not enough slots
	if (_i > count _startPositions - 1) then { break; };

	//create vehicle
	private _pos = race_start modelToWorld (_startPositions select _i);
	private _veh = createVehicle [_raceCarClassname, _pos, [], 0, "CAN_COLLIDE"];
	_veh allowDamage false;
	_veh setDir getDir race_start;
	_veh setVehicleAmmo 0;
	_veh setFuel 0;
	_raceVehicles pushBack _veh;

	//add in the driver
	private _driver = _participants select _i;
	[_driver, _veh] remoteExec ["moveInDriver", _driver];
	//_driver moveInDriver _veh;
	if (!(isPlayer _driver)) then
	{
		_veh lock true; 
	};
};

//create the finish post somewhere, then place it in a moment
private _finishPost = createVehicle ["Land_FinishGate_01_narrow_F", [0,0,0], [], 0, "CAN_COLLIDE"];

private _poiTypes = ["NameVillage", "NameCity", "NameCityCapital", "NameLocal", "Name", "NameMarine", "Hill"];
if (count _possibleCustomMarkers == 0) then
{
	if (_distance == -1) then
	{
		_distance = random [2000, 4000, 6000];
		["No custom markers defined, choosing random distance"] call SCO_fnc_printDebug;
	};

	//use a random location
	private _blackListed = [];
	{
		_blackListed append nearestLocations [getMarkerPos _x, _poiTypes, 500];
	} foreach allMapMarkers;

	private _poiList = (nearestLocations [getPos race_start, _poiTypes, _distance + 1000] - nearestLocations [getPos race_start, _poiTypes, _distance - 1000]) - _blackListed;

	private _finishRoad = [race_start getPos [_distance, getDir race_start], 6000] call BIS_fnc_nearestRoad;
	if (count _poiList > 0) then
	{
		["Found Race finish line based on random location at correct distance"] call SCO_fnc_printDebug;
		[locationPosition selectRandom _poiList, 6000] call BIS_fnc_nearestRoad;
	};

	//place the finish line
	private _info = getRoadInfo _finishRoad;
	_info params ["_mapType", "_width", "_isPedestrian", "_texture", "_textureEnd", "_material", "_begPos", "_endPos", "_isBridge"];
	_finishPost setPos (getPos _finishRoad);
	_finishPost setDir (_begPos getDir _endPos);
}
else
{
	//use a user-defined finish line
	private _marker = selectRandom _possibleCustomMarkers;

	//find a good exect position for the finish line, and a backup position if one cannot be found
	private _safeRoad = [getMarkerPos _marker, 3000] call BIS_fnc_nearestRoad;
	//private _safePos = [getMarkerPos _marker, 0, 50, 12, 0, 1, 0, [], [_safeRoad, _safeRoad]] call BIS_fnc_findSafePos;
	_finishPost setPos getPos _safeRoad;

	//set the direction to be that of the nearest road
	private _info = getRoadInfo _safeRoad;
	_info params ["_mapType", "_width", "_isPedestrian", "_texture", "_textureEnd", "_material", "_begPos", "_endPos", "_isBridge"];
	[format ["Selected %1 since it was closest to desired distance at %2", _marker, getMarkerPos _marker distance2D race_start]] call SCO_fnc_printDebug;
	_finishPost setDir (_begPos getDir _endPos);
};

//place markers
_finishPost allowDamage false;
private _raceStartMarker = ["race_start", getPos race_start, "Start", [1, 1], "ColorOrange", "ICON", "mil_arrow", getDir race_start] call SCO_fnc_createMarker;
private _raceEndMarker = ["race_end", getPos _finishPost, "End", [1, 1], "ColorOrange", "ICON", "mil_flag"] call SCO_fnc_createMarker;

//give all participants waypoints
{
	private _raceWP = group _x addWaypoint [getPos _finishPost, 0];
	_raceWP setWaypointType "MOVE";
	_raceWP setWaypointSpeed "FULL";
	_raceWP setWaypointName "Race";
	_raceWP setWaypointCompletionRadius 5;
	_raceWP setWaypointStatements ["true", "deleteWaypoint [group this, currentWaypoint group this];" ];
} forEach _participants;

//start race procedure
private _nearestLocations = nearestLocations [getPos _finishPost, _poiTypes, 2000];
if (count _nearestLocations > 0) then
{
	format ["Race finish line has been placed near %1", text (_nearestLocations select 0)] remoteExec ["systemChat", 0];
}
else
{
	format ["Race finish line has been placed %1 meters away", race_start distance2D _finishPost] remoteExec ["systemChat", 0];
};

sleep 5;
"The race will start in 8 seconds when the flare appears" remoteExec ["systemChat", 0];
sleep 5;

//start the race
//private _startAlarm = createSoundSource ["Sound_Alarm", getPos race_start, [], 0];
private _startFlare = createVehicle ["F_40mm_White", getPos race_start vectorAdd [0,0,1], [], 0, "CAN_COLLIDE"];
sleep 3; //takes a moment for the flare to deploy

{
	[_x, 1] remoteExec ["setFuel", 0, true]; //locality is hard. send this command to everyone for some reason
} forEach _raceVehicles;

private _scoreTracker = [_participants, _finishPost] spawn
{
	params ["_players", "_endPos"];
	private _startTime = diag_tickTime;
	private _firstPlaceTime = -1;
	private _dnfTimeout = 60;
	private _inProgressCode = -1;
	private _dnfCode = -2;
	private _completedTable = [];
	{
		_completedTable pushBack [_x, _inProgressCode]; //-1=in progress, real int=finish time, -2=dnf
	} forEach _players;

	while {{(_x select 1) == _inProgressCode} count _completedTable > 0} do
	{
		sleep 0.2;
		private _activeRacers = {(_x select 1) == _inProgressCode} count _completedTable;

		//print stats for each racer
		private _string = format ["<t size='1.5' align='left'>Distances (%1 active):</t><br/>", _activeRacers];
		
		{
			_x params ["_racer", "_time"];

			private _playerDistance = _racer distance _endPos;

			//if the player has not yet been observed winning, but now is, update their finish time
			if (_playerDistance < 10 and _time == _inProgressCode) then
			{
				private _time = diag_tickTime - _startTime;
				_x set [1, _time];

				if (_firstPlaceTime == -1) then
				{
					_firstPlaceTime = diag_tickTime;
				};
			};

			//dnf if the racer dies, or the timer expires. they must be currently racing for dnf status to be applied
			if (_time == _inProgressCode and (!alive _racer or ((diag_tickTime - _firstPlaceTime > _dnfTimeout) and (_firstPlaceTime != -1)))) then
			{
				_x set [1, _dnfCode];
			};

			switch (_time) do
			{
				case _dnfCode: 
				{
					_string = _string + format ["<t align='left'>(Inactive) %1: DNF</t><br/>", name _racer];
				};
				case _inProgressCode:
				{
					_string = _string + format ["<t align='left'>(Racing) %1:  %2m</t><br/>", name _racer, floor (_racer distance _endPos)];
				};
				default
				{
					_string = _string + format ["<t align='left'>(Finished) %1:  %2 sec</t><br/>", name _racer, _time toFixed 1];
				};
			};
		} forEach _completedTable;

		if (_firstPlaceTime != -1) then
		{
			//if a player has completed, the DNF timer will appear
			_string = _string + format ["<t size='0.75' align='left'>DNF time in %1 seconds</t>", floor (_dnfTimeout - (diag_tickTime - _firstPlaceTime))];
		};
		(parseText _string) remoteExec ["hint", _players apply {group _x}];
	};

	//print the race results to chat
	[format ["Race Results:%1", _completedTable]] call SCO_fnc_printDebug;
	"" remoteExec ["hint", _players apply {group _x}];
	private _finishers = [_completedTable, [], {_x select 1}, "ASCEND", {(_x select 1) > 0}] call BIS_fnc_sortBy;
	private _dnf = [_completedTable, [], {_x select 1}, "ASCEND", {(_x select 1) < 0}] call BIS_fnc_sortBy;
	"Race Results:" remoteExec ["systemChat", 0];
	//print status of finishers
	{
		_x params ["_racer", "_time"];
		format ["%1 finished %2 in %3 seconds", name _racer, [_forEachIndex+1] call BIS_fnc_ordinalNumber, _time toFixed 1] remoteExec ["systemChat", 0];
	} forEach _finishers;

	//print those that did not finish
	{
		_x params ["_racer", "_status"];
		switch (_status) do
		{
			case _dnfCode: 
			{
				format ["%1 did not finish", name _racer] remoteExec ["systemChat", 0];
			};
			case -1:
			{
				format ["%1 is still racing", name _racer] remoteExec ["systemChat", 0];
			};
			default
			{
				format ["%1 has an unknown status: %2", name _racer, _status] remoteExec ["systemChat", 0];
			};
		};
	} forEach _dnf;
	["score tracker is done"] call SCO_fnc_printDebug;
};

//delete the start alarm since it would be annoying
sleep 10;
deleteVehicle _startFlare;

waitUntil {scriptDone _scoreTracker};
["Race Ended"] call SCO_fnc_printDebug;
missionNamespace setVariable ["SCO_RACE_ACTIVE", false, true];

sleep 5;
{
	if (isPlayer _x) then
	{
		_x setPos getMarkerPos "respawn_west";
	}
	else
	{
		deleteVehicle _x;
	};
} forEach _participants;

//cleanup
{
	deleteVehicle _x;
} forEach _raceVehicles;
deleteVehicle _finishPost;
deleteMarker _raceStartMarker;
deleteMarker _raceEndMarker;