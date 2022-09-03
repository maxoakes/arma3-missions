params ["_participants", "_lobbyMarker", ["_mode", 0], ["_distance", 5000], ["_customFinishMarker", ""], ["_enableDamage", false]];

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
private _chosenVehicleClassname = "";
switch _mode do
{
	case 0;
	case 1;
	case 2:
	{
		private _nearestVehicle = nearestObject [getMarkerPos _lobbyMarker, "LandVehicle"];
		if (_nearestVehicle distance2D getMarkerPos _lobbyMarker > 20) then
		{
			_chosenVehicleClassname = selectRandom ["B_MRAP_01_F", "B_LSV_01_unarmed_F", "B_Quadbike_01_F", "O_MRAP_02_F", "O_LSV_02_unarmed_F", "I_MRAP_03_F"];
		}
		else
		{
			_chosenVehicleClassname = typeOf _nearestVehicle;
		};
	};
	case 3:
	{
		private _nearestVehicle = nearestObject [getMarkerPos _lobbyMarker, "Helicopter"];
		if (_nearestVehicle distance2D getMarkerPos _lobbyMarker > 50) then
		{
			_chosenVehicleClassname = selectRandom ["B_Heli_Light_01_F"];
		}
		else
		{
			_chosenVehicleClassname = typeOf _nearestVehicle;
		};
	};
};

//set up starting positions
private _startPositions = [];
private _positionWidth = 6;
if (_mode == 3) then { _positionWidth = 12; };
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
	private _veh = createVehicle [_chosenVehicleClassname, _pos, [], 0, "CAN_COLLIDE"];
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
private _postClassname = "Land_FinishGate_01_narrow_F";
if (_mode == 3) then { _postClassname = "Land_HelipadCircle_F"; };
private _finishPost = createVehicle [_postClassname, [0,0,0], [], 0, "CAN_COLLIDE"];

private _finishPosDir = [race_start, _mode, _distance, _customFinishMarker] call SCO_fnc_findRaceFinishPosition;
_finishPosDir params ["_finishPos", "_finishDir"];
_finishPost setPos _finishPos;
_finishPost setDir _finishDir;

//place markers
_finishPost allowDamage false;
private _raceStartMarker = ["race_start", getPos race_start, "Start", [1, 1], "ColorOrange", "ICON", "mil_arrow", getDir race_start] call SCO_fnc_createMarker;
private _raceEndMarker = ["race_end", getPos _finishPost, "End", [1, 1], "ColorOrange", "ICON", "mil_flag"] call SCO_fnc_createMarker;
private _dnfTimeout = 30 max (getMarkerPos _raceStartMarker distance2D getMarkerPos _raceEndMarker)/100;

//give all participants waypoints
private _finishRadius = 5;
if (_mode == 3) then { _finishRadius = 20; };
{
	private _raceWP = group _x addWaypoint [getPos _finishPost, 0];
	_raceWP setWaypointType "MOVE";
	_raceWP setWaypointSpeed "FULL";
	_raceWP setWaypointName "Race";
	_raceWP setWaypointCompletionRadius 5;
	_raceWP setWaypointStatements ["true", "deleteWaypoint [group this, currentWaypoint group this];" ];
} forEach _participants;

//start race procedure
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

private _scoreTracker = [_participants, _finishPost, _dnfTimeout, _finishRadius] spawn SCO_fnc_raceScoreTracker;

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