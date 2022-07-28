/*
	Author: Scouter

	Description:
		Get all items that are within a category and/or type as stated in configs

	Parameter(s):
		0: Array of Strings - (required) array of item config categories
		1: Array of Strings - (required) array of item config types
	Returns:
		Array of Strings
*/
params ["_categories", "_types"];

private _allItems = (configFile >> "cfgWeapons") call BIS_fnc_getCfgSubClasses;
private _items = [];
{
	if (getnumber (configFile >> "cfgWeapons" >> _x >> "scope") > 1) then
	{
		private _itemType = _x call BIS_fnc_itemType;
		if (((_itemType select 0) in _categories) && ((_itemType select 1) in _types)) then
		{
			_items pushBackUnique _x;
		};
	};
} forEach _allItems;
_items; //return