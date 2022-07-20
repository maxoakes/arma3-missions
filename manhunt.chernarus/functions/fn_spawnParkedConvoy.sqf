/*
	Author: Scouter

	Description:
		Spawn vehicles on parking spots on the side of a road that is closest to some position
		
	Parameter(s):
		0: Position - position of the that the nearest roads should be chosen from
		1: Number - maximum number of vehicles to spawn. Should be more than 0
		2: Array of Strings - classnames of vehicle types that can be created

	Returns:
		Array of Objects - vehicles that end up being spawned
*/
params ["_pos", "_numVehicles", "_possibleVehicleClassnames"];

private _startTime = diag_tickTime;

//find the nearest road to place the convoy
private _nearestRoad = [_pos, 1000] call BIS_fnc_nearestRoad;
private _nearestRoads = [_nearestRoad];

//accumulate connected roads. Get at most a specific amount of road segments
private _limit = 2 * _numVehicles;
private _iterations = 0;
while {count _nearestRoads < _numVehicles and _iterations <= _limit} do
{
	for "_i" from 0 to (count _nearestRoads - 1) do 
	{
		private _newRoads = roadsConnectedTo (_nearestRoads select _i);
		{
			_nearestRoads pushBackUnique _x;
		} forEach _newRoads;
	};
	_iterations = _iterations + 1;
};

//obtain several positions from the road segment. should end up with far more than the number of specified vehicles
private _roadPositions = []; 
{
	private _info = getRoadInfo _x;
	_info params ["_mapType", "_width", "_isPedestrian", "_texture", "_textureEnd", "_material", "_begPos", "_endPos", "_isBridge"];
	private _additions = [ASLToAGL _begPos, ASLToAGL _endPos, ASLToAGL getPos _x];
	for "_i" from 0 to 2 do
	{
		if ({(_additions select _i) distance2D _x < 8} count _roadPositions == 0) then
		{
			_roadPositions pushBackUnique (_additions select _i);
		}
	};
} forEach _nearestRoads;

//create a list of positions on the shoulder of each road position
private _parkingPositionDirections = [];
{
	//get the road width and direction
	private _thisRoad = roadAt _x;
	private _info = getRoadInfo _thisRoad;
	_info params ["_mapType", "_width", "_isPedestrian", "_texture", "_textureEnd", "_material", "_begPos", "_endPos", "_isBridge"];
	private _dir = _begPos getDir _endPos;

	//get parking positions
	private _distFromCenter = _width/2;
	private _posRight = _x getPos [_distFromCenter, _dir + 90];
	private _posLeft = _x getPos [_distFromCenter, _dir + 270];

	//add to the list
	_parkingPositionDirections pushBackUnique [_posRight, _dir];
	_parkingPositionDirections pushBackUnique [_posLeft, _dir + 180];
} forEach _roadPositions;

//sort the markers by distance to original position
private _sortedDistances = [_parkingPositionDirections, [_pos], { _input0 distance2D (_x select 0) }, "ASCEND"] call BIS_fnc_sortBy;

//spawn up to the desired amount of vehicles onto the closest road parking positions closest to the desired position
private _convoy = [];
for "_i" from 0 to (count _sortedDistances)-1 do
{
	_sortedDistances select _i params ["_thisPos", "_thisDir"];

	//stop if we reach the desrired number of vehicles
	if (count _convoy >= _numVehicles) then
	{
		break;
	};

	//spawn a vehicle in the nearest open parking spot
	private _selectedVehicle = selectRandom _possibleVehicleClassnames;
	private _blacklistedObjectTypes = ["LandVehicle", "Building", "Thing", "Static"];
	if (count (nearestObjects [_thisPos, _blacklistedObjectTypes, sizeOf _selectedVehicle]) == 0) then
	{
		//place the vehicle onto the road at the direction of the road
		private _vehicle = createVehicle [_selectedVehicle, _thisPos, [], 0, "NONE"];
		_vehicle setDir (_thisDir + random [-10, 0, 10]);
		
		_vehicle setVectorUp surfaceNormal getPos _vehicle;
		_vehicle setFuel random [0.3, 0.5, 1];
		_convoy pushBack _vehicle;
	};
};

private _stopTime = diag_tickTime;
(format ["%1 sec to generate convoy with %2 possible road positions. %3 of %4 vehicles spawned", 
	_stopTime - _startTime, count _sortedDistances, count _convoy, _numVehicles]) remoteExec ["systemChat", 0];

//return
_convoy;