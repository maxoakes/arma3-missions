//take in a list of weapon categories and types
//returns all of the weapons/items that fall within those categories and types
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