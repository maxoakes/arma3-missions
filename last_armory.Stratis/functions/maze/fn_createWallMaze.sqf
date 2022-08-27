params ["_areaMarker", ["_cellWallClassnames",["Land_wall_IndCnc_2deco_F"]], ["_cellSideLength", 3]];

//set up physical maze area and measurements
private _baseAngle = markerDir _areaMarker;
private _mazeDimensions = (getMarkerSize _areaMarker) apply {_x * 2};
private _numCells = _mazeDimensions apply {_x / _cellSideLength};
[format ["Maze: Cell Size: %1m, Num Cells [x,y]: %2", _cellSideLength, _numCells]] call SCO_fnc_printDebug;

//init maze configuration by creating wall placement array
private _segmentCount = _numCells apply {_x + 2};
[format ["Wall segment size: %1x%2", _segmentCount select 0, _segmentCount select 1]] call SCO_fnc_printDebug;

//translated from Java to SQF from https://algs4.cs.princeton.edu/41graph/Maze.java.html
//fill wall placement indicator arrays
SCO_north = [[]];
SCO_east = [[]];
SCO_west = [[]];
SCO_south = [[]];
SCO_visited = [[]];
SCO_north resize [_segmentCount select 0, []];
SCO_east resize [_segmentCount select 0, []];
SCO_west resize [_segmentCount select 0, []];
SCO_south resize [_segmentCount select 0, []];
SCO_visited resize [_segmentCount select 0, []];
private _isDone = false;

for "_col" from 0 to (_segmentCount select 0)-1 do 
{
	for "_row" from 0 to (_segmentCount select 1)-1 do
	{
		(SCO_north select _col) set [_row, true];
		(SCO_east select _col) set [_row, true];
		(SCO_west select _col) set [_row, true];
		(SCO_south select _col) set [_row, true];
		(SCO_visited select _col) set [_row, false];
	};
};

// initialize border cells as already visited
for "_col" from 0 to (_segmentCount select 0)-1 do
{
	(SCO_visited select _col) set [0, true];
	(SCO_visited select _col) set [(_segmentCount select 0)-1, true];
};

for "_row" from 0 to (_segmentCount select 1)-1 do
{
	(SCO_visited select 0) set [_row, true];
	(SCO_visited select (_segmentCount select 1)-1) set [_row, true];
};

SCO_fnc_deleteWall = {
	params ["_col", "_row", "_dir"];
	if (_dir == "n") then
	{
		if (!((SCO_north select _col) select _row)) exitWith {false};
		(SCO_north select _col) set [_row, false];
		(SCO_south select _col) set [_row + 1, false];
	};
	if (_dir == "s") then
	{
		if (!((SCO_south select _col) select _row)) exitWith {false};
		(SCO_south select _col) set [_row, false];
		(SCO_north select _col) set [_row - 1, false];
	};
	if (_dir == "w") then
	{
		if (!((SCO_west select _col) select _row)) exitWith {false};
		(SCO_west select _col) set [_row, false];
		(SCO_east select _col - 1) set [_row, false];
	};
	if (_dir == "e") then
	{
		if (!((SCO_east select _col) select _row)) exitWith {false};
		(SCO_east select _col) set [_row, false];
		(SCO_west select _col + 1) set [_row, false];
	};
	true;
};
//generate maze
SCO_fnc_generate = {
	params ["_col", "_row"];
	//visited[col][row] = true;
	(SCO_visited select _col) set [_row, true];

	// while there is an unvisited neighbor
	//while (!visited[col][row + 1] || !visited[col + 1][row] || !visited[col][row - 1] || !visited[col - 1][row])
	while {!((SCO_visited select _col) select (_row + 1)) or !((SCO_visited select _col + 1) select (_row))
		or !((SCO_visited select _col) select (_row - 1)) or !((SCO_visited select _col - 1) select (_row))} do
	{

		// pick random neighbor (could use Knuth's trick instead)
		while {true} do
		{
			scopeName "recurse";
			private _random = selectRandom ["n", "e", "w", "s"];
			if (_random == "n" && !((SCO_visited select _col) select (_row + 1))) then
			{
				[_col, _row, "n"] call SCO_fnc_deleteWall;
				[_col, _row + 1] call SCO_fnc_generate;
				break;
			};

			if (_random == "e" && !((SCO_visited select _col + 1) select (_row))) then
			{
				[_col, _row, "e"] call SCO_fnc_deleteWall;
				[_col + 1, _row] call SCO_fnc_generate;
				break;
			};

			if (_random == "s" && !((SCO_visited select _col) select (_row - 1))) then
			{
				[_col, _row, "s"] call SCO_fnc_deleteWall;
				[_col, _row - 1] call SCO_fnc_generate;
				break;
			};

			if (_random == "w" && !((SCO_visited select _col - 1) select (_row))) then
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
private _centerObject = createVehicle ["Land_ChairWood_F", _markerCenterPos, [], 0, "CAN_COLLIDE"];
_centerObject setDir _baseAngle;
private _originObject = createVehicle ["FlagPole_F", _markerCenterPos, [], 0, "CAN_COLLIDE"];
private _relPos = (_mazeDimensions apply {_x / -2}) + [0];
_originObject setPos (_centerObject modelToWorld _relPos);
_originObject setDir _baseAngle;
deleteVehicle _centerObject;

// SCO_fnc_getSegmentPos = {
// 	params ["_col", "_row", "_cellLength"];
// 	private _relPosX = _col * _cellLength;
// 	private _relPosY = _row * _cellLength;
// 	if (_dir == 90) then {_relPosY = _relPosY + (_cellLength/2)};
// 	if (_dir == 0) then {_relPosX = _relPosX + (_cellLength/2)};
// 	private _finalPosATL = _originObject modelToWorld [_relPosX, _relPosY, -4];
// 	_finalPosATL;
// };

SCO_fnc_placeWallFromConfig = {
	params ["_originObject", "_classname", "_cellLength", "_col", "_row", "_dir"];

	//create object
	private _obj = createVehicle [_classname, getPos _originObject, [], 0, "CAN_COLLIDE"];
	_obj allowDamage false;
	_obj setDir _dir;
	_obj setVectorUp [0, 0, 1];

	//place it correctly
	private _relPosX = _col * _cellLength;
	private _relPosY = _row * _cellLength;
	if (_dir == 90) then {_relPosY = _relPosY + (_cellLength/2)};
	if (_dir == 0) then {_relPosX = _relPosX + (_cellLength/2)};
	private _finalPosATL = _originObject modelToWorld [_relPosX, _relPosY, 0];
	
	_obj setPos (_originObject modelToWorld _finalPosATL);
	_obj setDir (getDir _obj + getDir _originObject);
};


//place walls based on cardinal direction arrays
private _entryColumn = round random [1, (_numCells select 0)/2, _numCells select 0];
private _exitColumn = round random [1, (_numCells select 0)/2, _numCells select 0];
for "_col" from 1 to (_numCells select 0) do
{
	for "_row" from 1 to (_numCells select 1) do
	{
		if ((SCO_south select _col) select _row) then
		{
			
			if (!(_row == 1 and _col == _entryColumn)) then
			{
				[_originObject, selectRandom _cellWallClassnames, _cellSideLength, _col, _row, 0] call SCO_fnc_placeWallFromConfig;
			}
			//create the south-side entry
			else
			{
				private _pos = [_col, _row, _cellSideLength] call SCO_fnc_getSegmentPos;
				["maze_entry", _pos, "Entry", [0.5, 0.5], "ColorYellow", "ICON", "mil_dot"] call SCO_fnc_createMarker;
			};
		};
		if ((SCO_north select _col) select _row) then
		{
			
			if (!(_row == (_numCells select 1) and _col == _exitColumn)) then
			{
				[_originObject, selectRandom _cellWallClassnames, _cellSideLength, _col, _row + 1, 0] call SCO_fnc_placeWallFromConfig;
			}
			//create the north-side exit
			else
			{
				private _pos = [_col, _row, _cellSideLength] call SCO_fnc_getSegmentPos;
				["maze_exit", _pos, "Exit", [0.5, 0.5], "ColorYellow", "ICON", "mil_dot"] call SCO_fnc_createMarker;
			};
		};
		if ((SCO_west select _col) select _row) then
		{
			[_originObject, selectRandom _cellWallClassnames, _cellSideLength, _col, _row, 90] call SCO_fnc_placeWallFromConfig;
		};
		if ((SCO_east select _col) select _row) then
		{
			[_originObject, selectRandom _cellWallClassnames, _cellSideLength, _col + 1, _row, 90] call SCO_fnc_placeWallFromConfig;
		};
	};
};

