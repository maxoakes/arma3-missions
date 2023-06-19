/*
	Author: Scouter

	Description:
		Given a list of classnames and weights, randomly add things to the cargo. 

	Parameter(s):
		0: Object - (required) Cargo/Vehicle/Crate to add things to 
		1: Array of Strings - (required) Classnames of guns, equipment or ammo to add
		2: Array of floats - (required) Weights (likelyhood) of each corresponding classname to spawn
		3: Integer (required) - Number of attempts to spawn things

	Returns:
		Void
*/
params ["_vehicle", ["_classnames", [""]], ["_weights", [1]], ["_num", 1]];

if (_num > 0) then
{
	for "_i" from 1 to _num do
	{
		private _selectedClassname = _classnames selectRandomWeighted _weights;
		private _categories = _selectedClassname call BIS_fnc_itemType;
		switch (_categories # 0) do
		{
			case "": {continue};
			case "Weapon": {_vehicle addWeaponCargoGlobal [_selectedClassname, 1]};
			case "Item": {_vehicle addItemCargoGlobal [_selectedClassname, 1]};
			case "Magazine": {_vehicle addMagazineCargoGlobal [_selectedClassname, 1]};
			case "Equipment": {
				switch _categories # 1 do
				{
					case "Glasses";
					case "Headgear";
					case "Uniform";
					case "Vest": {_vehicle addItemCargoGlobal [_selectedClassname, 1]};
					case "Backpack":{_vehicle addBackpackCargoGlobal [_selectedClassname, 1]}
				}
			};
			default {diag_log format ["SCO_fnc_addToCargoRandom =: Unknown category for %1 -> %2", _selectedClassname, _categories]};
		}
	};
};
