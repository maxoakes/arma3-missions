/*
	Author: Scouter

	Description:
		Given a position, spawn a building filled with stuff. 

	Parameter(s):
		0: Position - (required) ATL center position to spawn root object.
		1: Array - (required) See note
		2: Number - (required) index of the primary reference object/building
		3: Number - (optional) angle to place building
		4: Boolean - (optional) is the given position ATL (or ASL?)
		5: Number - (optional) vertical offset from the sea or terrain level
		6: Boolean - (optional) are the objects placed flat along side the root, or do they follow terrain?

	Returns:
		Array of references to the spawned objects in order that they were given.

	NOTE: Array obtained using in-game console with the following script.
	Once the array of obtained, the entry that contains the tent should be 
	moved be placed at the head of the array.

		private _objects = [];
		private _originObject = cursorObject;
		{
			private _classname = typeOf _x;
			if (_classname == "#mark" or _classname == "" or _classname == "#animator") then { continue; };
			private _posRel = _originObject worldToModel getPosATL _x; 
			private _dir = getDir _x;
			_objects pushBack [_classname, _posRel, _dir, getPosASL _x];
		} forEach nearestObjects [_originObject, [], 30];
		_objects;
*/
params ["_pos", "_placementArray", ["_idxPrimaryObject", 0], ["_angle", 0], ["_isATL", true], ["_verticalOffsetAboveLevel", 0], ["_isRootFlat", false]];

//create reference object
private _rootObject = createVehicle [(_placementArray select _idxPrimaryObject) select 0, _pos, [], 0, "CAN_COLLIDE"];
_rootObject allowDamage false;

if (_isATL) then
{
	_rootObject setPosATL _pos;
}
else //isASL
{
	private _posASL = [_pos select 0, _pos select 1, 0];
	_rootObject setPosASL (_posASL vectorAdd [0, 0, _verticalOffsetAboveLevel]);
};
if (_isRootFlat) then {	_rootObject setVectorUp [0, 0, 1]; };
_rootObject setDir _angle;

//fill building with stuff
private _spawned = [];
for "_i" from 0 to count _placementArray-1 do
{
	(_placementArray select _i) params ["_className", "_relPos", "_dir"];
	if (_i == _idxPrimaryObject) then
	{
		_spawned pushBack _rootObject;
		continue;
	};
	private _obj = createVehicle [_className, _pos, [], 0, "CAN_COLLIDE"];
	_obj setDir (_dir + _angle);
	if (_isRootFlat) then {	_obj setVectorUp [0, 0, 1];	};
	_obj allowDamage false;
	private _correctPosASL = _rootObject modelToWorldWorld _relPos;
	_obj setPosASL _correctPosASL;
	
	_spawned pushBack _obj;
};

//return
_spawned;
