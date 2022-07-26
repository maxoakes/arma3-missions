/*
	Author: Scouter

	Description:
		Get all item classnames that are of a certain category, type and/or classname
		
	Parameter(s):
		0: Array of Strings - categories of items
		1: Array of Strings - types of items
		2: String - a substring that needs to be in all sought classnames

	Returns:
		Array of strings of classnames
*/
params ["_categories", "_types", "_substring"];

private _unusedCategories = (count _categories) == 0;
private _unusedTypes = (count _types) == 0;
private _unusedSubstring = _substring == "";
private _items = [];
{
	//check if usable weapon
	if (getnumber (configFile >> "cfgWeapons" >> _x >> "scope") > 1) then
	{
		private _itemType = _x call bis_fnc_itemType;
		_itemType params ["_c", "_t"];

		//check if the weapon is an AK-style weapon per the classname
		if ((_unusedCategories or _c in _categories) && 
			(_unusedTypes or _t in _types) && 
			(_unusedSubstring or _substring in _x)) then
		{
			_items pushBackUnique _x;
		};
	};
} foreach ((configFile >> "cfgWeapons") call BIS_fnc_getCfgSubClasses);

//return
_items;