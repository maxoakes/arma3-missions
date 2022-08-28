params ["_areaMarker", ["_cellWallClassname","Land_wall_IndCnc_2deco_F"], ["_cellSideLength", 3]];

//set up physical maze area and measurements
private _baseAngle = markerDir _areaMarker;
private _mazeDimensions = (getMarkerSize _areaMarker) apply {(ceil (_x/_cellSideLength) * _cellSideLength) * 2};
private _numCells = _mazeDimensions apply {_x / _cellSideLength};
private _segmentCount = _numCells apply {_x + 2};
[
	format ["Maze '%1' of size %2 meters: Cell Size: %3m, Cell Dimensions: %4 units. Number of walls: %5 segments", 
	_areaMarker, _mazeDimensions, _cellSideLength, _numCells, _segmentCount]
] call SCO_fnc_printDebug;

private _mazeObjects = [];

//translated from Java to SQF from https://algs4.cs.princeton.edu/41graph/Maze.java.html
//fill wall placement indicator arrays
private _north = [[]];
private _east = [[]];
private _west = [[]];
private _south = [[]];
private _visited = [[]];
_north resize [_segmentCount select 0, []];
_east resize [_segmentCount select 0, []];
_west resize [_segmentCount select 0, []];
_south resize [_segmentCount select 0, []];
_visited resize [_segmentCount select 0, []];
private _isDone = false;

for "_col" from 0 to (_segmentCount select 0)-1 do 
{
	for "_row" from 0 to (_segmentCount select 1)-1 do
	{
		(_north select _col) set [_row, true];
		(_east select _col) set [_row, true];
		(_west select _col) set [_row, true];
		(_south select _col) set [_row, true];
		(_visited select _col) set [_row, false];
	};
};

// initialize border cells as already visited
for "_col" from 0 to (_segmentCount select 0)-1 do
{
	(_visited select _col) set [0, true];
	(_visited select _col) set [(_segmentCount select 1)-1, true];
};

for "_row" from 0 to (_segmentCount select 1)-1 do
{
	(_visited select 0) set [_row, true];
	(_visited select (_segmentCount select 0)-1) set [_row, true];
};

SCO_fnc_deleteWall = {
	params ["_col", "_row", "_dir"];
	if (_dir == "n") then
	{
		if (!((_north select _col) select _row)) exitWith {false};
		(_north select _col) set [_row, false];
		(_south select _col) set [_row + 1, false];
	};
	if (_dir == "s") then
	{
		if (!((_south select _col) select _row)) exitWith {false};
		(_south select _col) set [_row, false];
		(_north select _col) set [_row - 1, false];
	};
	if (_dir == "w") then
	{
		if (!((_west select _col) select _row)) exitWith {false};
		(_west select _col) set [_row, false];
		(_east select _col - 1) set [_row, false];
	};
	if (_dir == "e") then
	{
		if (!((_east select _col) select _row)) exitWith {false};
		(_east select _col) set [_row, false];
		(_west select _col + 1) set [_row, false];
	};
	true;
};
//generate maze
SCO_fnc_generate = {
	params ["_col", "_row"];
	//visited[col][row] = true;
	(_visited select _col) set [_row, true];

	// while there is an unvisited neighbor
	//while (!visited[col][row + 1] || !visited[col + 1][row] || !visited[col][row - 1] || !visited[col - 1][row])
	while {!((_visited select _col) select (_row + 1)) or !((_visited select _col + 1) select (_row))
		or !((_visited select _col) select (_row - 1)) or !((_visited select _col - 1) select (_row))} do
	{

		// pick random neighbor (could use Knuth's trick instead)
		while {true} do
		{
			scopeName "recurse";
			private _random = selectRandom ["n", "e", "w", "s"];
			if (_random == "n" && !((_visited select _col) select (_row + 1))) then
			{
				[_col, _row, "n"] call SCO_fnc_deleteWall;
				[_col, _row + 1] call SCO_fnc_generate;
				break;
			};

			if (_random == "e" && !((_visited select _col + 1) select (_row))) then
			{
				[_col, _row, "e"] call SCO_fnc_deleteWall;
				[_col + 1, _row] call SCO_fnc_generate;
				break;
			};

			if (_random == "s" && !((_visited select _col) select (_row - 1))) then
			{
				[_col, _row, "s"] call SCO_fnc_deleteWall;
				[_col, _row - 1] call SCO_fnc_generate;
				break;
			};

			if (_random == "w" && !((_visited select _col - 1) select (_row))) then
			{
				[_col, _row, "w"] call SCO_fnc_deleteWall;
				[_col - 1, _row] call SCO_fnc_generate;
				break;
			};
		};
	};
};

//perform maze generation
[1,1] call SCO_fnc_generate;

//place [0,0] corner origin object
private _markerCenterPos = getMarkerPos _areaMarker;
private _centerObject = createVehicle ["Sign_Arrow_Large_Pink_F", _markerCenterPos, [], 0, "CAN_COLLIDE"];
_centerObject setDir _baseAngle;
private _originObject = createVehicle ["Sign_Arrow_Large_Pink_F", _markerCenterPos, [], 0, "CAN_COLLIDE"];
private _relPos = (_mazeDimensions apply {_x / -2}) + [0];
_originObject setPos (_centerObject modelToWorld _relPos);
_originObject setDir _baseAngle;
_originObject setVectorUp [0, 0, 1];


SCO_fnc_getSegmentPos = {
	params ["_col", "_row"];
	private _relPosX = (_col - 1) * _cellSideLength;
	private _relPosY = (_row - 1) * _cellSideLength;
	if (_dir == 90) then {_relPosY = _relPosY + (_cellSideLength/2)};
	if (_dir == 0) then {_relPosX = _relPosX + (_cellSideLength/2)};
	//literal set for the "Sign_Arrow_Large_Pink_F" object
	private _finalPosATL = _originObject modelToWorld [_relPosX, _relPosY, -1.5];
	_finalPosATL;
};

SCO_fnc_placeWallFromConfig = {
	params ["_col", "_row", "_dir"];

	//get the world position
	private _pos = [_col, _row] call SCO_fnc_getSegmentPos;

	//check if there is already a wall there
	if (count (nearestObjects [_pos ,[_cellWallClassname], 0.5, true]) == 0) then
	{
		//create object
		private _obj = createVehicle [_cellWallClassname, getPos _originObject, [], 0, "CAN_COLLIDE"];
		_obj allowDamage false;
		_obj setDir _dir;
		_obj setVectorUp [0, 0, 1];

		//place it correctly
		_obj setPos _pos;
		_obj setDir (getDir _obj + _baseAngle);
		_mazeObjects pushBack _obj;
	};
};


//place walls based on cardinal direction arrays
private _entryColumn = round random [1, (_numCells select 0)/2, _numCells select 0];
private _exitColumn = round random [1, (_numCells select 0)/2, _numCells select 0];
for "_col" from 1 to (_numCells select 0) do
{
	for "_row" from 1 to (_numCells select 1) do
	{
		if ((_south select _col) select _row) then
		{
			
			if (!(_row == 1 and _col == _entryColumn)) then
			{
				[_col, _row, 0] call SCO_fnc_placeWallFromConfig;
			}
			//create the south-side entry
			else
			{
				private _pos = [_col + 0.5, _row] call SCO_fnc_getSegmentPos;
				[format ["%1_entry", _areaMarker], _pos, "Entry", [0.5, 0.5], "ColorYellow", "ICON", "mil_dot"] call SCO_fnc_createMarker;
				private _groundArrow = createVehicle ["Sign_Arrow_Direction_Yellow_F", _pos, [], 0, "CAN_COLLIDE"];
				_groundArrow setDir _baseAngle;
				_mazeObjects pushBack _groundArrow;
			};
		};
		if ((_north select _col) select _row) then
		{
			
			if (!(_row == (_numCells select 1) and _col == _exitColumn)) then
			{
				[_col, _row + 1, 0] call SCO_fnc_placeWallFromConfig;
			}
			//create the north-side exit
			else
			{
				private _pos = [_col + 0.5, _row + 1] call SCO_fnc_getSegmentPos;
				[format ["%1_exit", _areaMarker], _pos, "Exit", [0.5, 0.5], "ColorYellow", "ICON", "mil_dot"] call SCO_fnc_createMarker;
				private _groundArrow = createVehicle ["Sign_Arrow_Direction_Yellow_F", _pos, [], 0, "CAN_COLLIDE"];
				_groundArrow setDir _baseAngle;
				_mazeObjects pushBack _groundArrow;
			};
		};
		if ((_west select _col) select _row) then
		{
			[_col, _row, 90] call SCO_fnc_placeWallFromConfig;
		};
		if ((_east select _col) select _row) then
		{
			[_col + 1, _row, 90] call SCO_fnc_placeWallFromConfig;
		};
	};
};

//cleanup measurement objects
deleteVehicle _originObject;
deleteVehicle _centerObject;

[format ["%1 maze objects created for %2", count _mazeObjects, _areaMarker]] call SCO_fnc_printDebug;

//return
_mazeObjects;