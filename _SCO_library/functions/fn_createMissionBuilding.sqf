/*
	Author: Scouter

	Description:
		Given a position, spawn a building filled with stuff. 

	Parameter(s):
		0: Position - (required) center position to spawn tent. can be 2D or 3D
		1: Array - (required) See note
		2: Number - (required)index of the primary reference object/building
		3: Number - (optional) angle to place building

	Returns:
		Array of references to the spawned objects in order that they were given.

	NOTE: Array obtained using in-game console with the following script.
	Once the array of obtained, the entry that contains the tent should be 
	moved be placed at the head of the array.

		private _objects = [];
		private _originObject = cursorObject;
		{
			private _classname = typeOf _x;
			private _posRel = _originObject worldToModel getPos _x; 
			private _dir = getDir _x;
			_objects pushBack [_classname, _posRel, _dir];
		} forEach nearestObjects [_originObject, [], 20];
		_objects;
*/
params ["_pos", "_placementArray", ["_idxBuilding", 0], ["_angle", 0]];

//create reference object
private _building = createVehicle [(_placementArray select _idxBuilding) select 0, _pos, [], 0, "CAN_COLLIDE"];
_building allowDamage false;
_building setDir _angle;
private _spawned = [];

//fill building with stuff
for "_i" from 0 to count _placementArray-1 do
{
	(_placementArray select _i) params ["_className", "_relPos", "_dir"];
	if (_i == _idxBuilding) then
	{
		_spawned pushBack _building;
		continue;
	};
	private _obj = createVehicle [_className, _building modelToWorld _relPos, [], 0, "CAN_COLLIDE"];
	_obj setDir (_dir + _angle);
	_obj allowDamage false;

	_spawned pushBack _obj;
};

//return
_spawned;
