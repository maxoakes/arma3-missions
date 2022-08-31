params ["_participants", "_lobbyMarker", "_distance"];

//add AI to race if there are not a lot of players
// if (_participants < 2) then
// {
// 	private _group = createGroup [west, true];
// 	for "_i" from 1 to 2 do
// 	{
// 		_participants pushBack (_group createUnit ["B_Soldier_VR_F", getMarkerPos _lobbyMarker, [], 0, "NONE"]); 
// 	};
// };

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
private _numPositions = count _participants;
for "_i" from 1 to _numPositions do
{
	private _backOffset = ceil (_positionWidth/4);
	private _leftOffset = _positionWidth * (_numPositions+1)/2;
	private _relPos = [(_i * _positionWidth) - _leftOffset, -22, -1];
	_startPositions pushBack _relPos;
	[format ["starting%1", _i], race_start modelToWorld _relPos, "", [1, 1], "ColorOrange", "ICON", "mil_dot"] call SCO_fnc_createMarker;
}; 

//spawn the vehicles
private _raceVehicles = [];
{
	if ((count _participants) -1 < _forEachIndex) then { break; };
	private _pos = race_start modelToWorld _x;
	private _veh = createVehicle [_raceCarClassname, _pos, [], 0, "CAN_COLLIDE"];
	_veh allowDamage false;
	_veh setDir getDir race_start;
	_veh setVehicleAmmo 0;
	_veh setFuel 0;
	private _driver = _participants select _forEachIndex;
	_driver moveInDriver _veh;
	if (!(isPlayer _driver)) then
	{
		_veh lock true; 
	};
} forEach _startPositions;