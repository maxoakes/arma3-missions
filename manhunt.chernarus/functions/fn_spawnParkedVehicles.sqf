/*
	Author: Scouter

	Description:
		Spawn vehicles on parking spots on the side of a road that is closest to some position
		
	Parameter(s):
		0: Position - position of the that the nearest roads should be chosen from
		1: Number - maximum number of vehicles to spawn. Should be more than 0
		2: Array of Strings - classnames of vehicle types that can be created
		3: Number - maximum angle that the vehicle can be misaligned. (0=perfectly parked, 180=randomly rotated)
		4: Array of two Numbers - Range that the fuel of each car could be
		5: Array of two Numbers - Range that the overall damage of each car could be
		6: Array of two Numbers - Range that the ammo of each car could be

	Returns:
		Array of Objects - vehicles that end up being spawned
*/
params ["_pos", "_numVehicles", "_possibleVehicleClassnames", ["_alignment", 0], ["_fuelRange", [0.6, 0.9, 1.0]], ["_damageRange", [0.0, 0.1, 0.3]], ["_ammoRange", [0.5, 0.9, 1.0]]];

//find the nearest road to place the convoy
private _searchRadius = 2000;
private _nearestRoad = [_pos, _searchRadius] call BIS_fnc_nearestRoad;
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
		_vehicle setDir (_thisDir + random [0-_alignment, 0, _alignment]);
		
		_vehicle setVectorUp surfaceNormal getPos _vehicle;
		_vehicle setFuel random _fuelRange;
		_vehicle setDamage random _damageRange;
		_vehicle setVehicleAmmo random _ammoRange;
		_convoy pushBack _vehicle;
	};
};

//return
_convoy;