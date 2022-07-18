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

	_parkingPositionDirections pushBackUnique [_posRight, _dir];
	_parkingPositionDirections pushBackUnique [_posLeft, _dir + 180];
} forEach _roadPositions;

//sort the markers by distance to original position
private _sortedDistances = [_parkingPositionDirections, [_pos], { _input0 distance2D (_x select 0) }, "ASCEND"] call BIS_fnc_sortBy;
systemChat format ["%1 possible road positions", count _sortedDistances];
private _convoy = [];

for "_i" from 0 to (count _sortedDistances)-1 do
{
	_sortedDistances select _i params ["_thisPos", "_thisDir"];
	if (count _convoy >= _numVehicles) then
	{
		systemChat format ["Convoy limit reached: actual:%1 >= setlimit:%2 on i:%3", count _convoy, _numVehicles, _i];
		break;
	};

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
(format ["%1 sec to generate convoy.",	_stopTime - _startTime]) remoteExec ["systemChat", 0];

_convoy;