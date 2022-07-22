/*
	Author: Scouter

	Description:
		given a position, spawn a building filled with stuff

	Parameter(s):
		0: Position
		1: Array - See note
		2: index of the reference object/building
		3: index of the intel that the player uses
		4: index of the main crate

	Returns:
		Array of Objects in format [Building object, intel object, crate object]

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
params ["_pos", "_placementArray", "_idxBuilding", "_idxIntel", "_idxCrate"];

//create reference object
private _baseDir = getDir (nearestBuilding _pos) + 90; //align it with a nearby building
private _building = createVehicle [(_placementArray select _idxBuilding) select 0, _pos, [], 0, "CAN_COLLIDE"];
_building allowDamage false;
_building setDir _baseDir;
private _intel = objNull;
private _crate = objNull;

//fill building with stuff
for "_i" from 0 to count _placementArray-1 do
{
	(_placementArray select _i) params ["_className", "_relPos", "_dir"];
	if (_i == _idxBuilding) then
	{
		continue;
	};
	private _obj = createVehicle [_className, _building modelToWorld _relPos, [], 0, "CAN_COLLIDE"];
	_obj setDir (_dir + _baseDir);
	_obj allowDamage false;

	if (_i == _idxIntel) then
	{
		_intel = _obj;
	};
	if (_i == _idxCrate) then
	{
		_crate = _obj;
	};
} forEach _placementArray;

//return
[_building, _intel, _crate];
