/*
	Author: Scouter

	Description:
		Given categories of objects, return all objects within those categories sorted into types

	Parameter(s):
		0: Array of Strings - (required) list of categories of objects to find 
	Returns:
		Array of Array of Strings in format:
			["objType",["obj1", "obj2", "obj3"]]
*/
params ["_categories"];

private _list = (configFile >> "cfgVehicles") call BIS_fnc_getCfgSubClasses;
private _types = [];
private _dictionary = [[]];

{
	//check each object for category
	if (getnumber (configFile >> "cfgVehicles" >> _x >> "scope") > 1) then
	{
		private _obj = _x call BIS_fnc_objectType;
		_obj params ["_category", "_type"];
		if (_category in _categories) then
		{
			private _typeIndex = _types find _type;

			//if there is already a list being built for this object type
			if (_typeIndex > -1) then
			{
				//append this current object to this sub-list
				private _objectList = _dictionary select _typeIndex;
				_objectList pushBack _x;
				_dictionary set [_typeIndex, _objectList]; 
			}
			else
			{
				//if it is a new type of object, add this type to the main array and add this object
				private _newIndex = _types pushBack _type;
				_dictionary set [_newIndex, [_x]]; 
			};
		};
	};
} foreach _list;

private _return = [[]];
for "_i" from 0 to (count _types) do
{
	private _a = [_types select _i, _dictionary select _i];
	_return pushBack _a;
};
_return;