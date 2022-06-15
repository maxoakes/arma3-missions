#include "initCurator.sqf"
#include "initParams.sqf"

[west,"US1"] call BIS_fnc_addRespawnInventory;
[west,"US2"] call BIS_fnc_addRespawnInventory;
[west,"US3"] call BIS_fnc_addRespawnInventory;
[west,"US4"] call BIS_fnc_addRespawnInventory;
[west,"US5"] call BIS_fnc_addRespawnInventory;
[west,"US6"] call BIS_fnc_addRespawnInventory;
[west,"US7"] call BIS_fnc_addRespawnInventory;
[west,"US8"] call BIS_fnc_addRespawnInventory;
[west,"US9"] call BIS_fnc_addRespawnInventory;
[west,"US10"] call BIS_fnc_addRespawnInventory;
[west,"US11"] call BIS_fnc_addRespawnInventory;

airdropAvailable = true;
	
//fill list of usable west weapons, items and ammo
_weaponList = (configFile >> "cfgWeapons") call BIS_fnc_getCfgSubClasses;
_magList = (configFile >> "cfgMagazines") call BIS_fnc_getCfgSubClasses;
_weaponTypes = ["AssaultRifle","MachineGun","SniperRifle","Shotgun","Rifle","SubmachineGun","MissileLauncher","RocketLauncher"];
_attchmentTypes = ["AccessoryMuzzle","AccessoryPointer","AccessorySights","AccessoryBipod"];
_ammoTypes = ["Artillery","Flare","Grenade","Laser","Missile","Rocket","Shell","ShotgunShell","SmokeShell"];

attachmentClassnames = [];
weaponClassnames = [];
ammoClassnames = [];

{
	if (getText (configFile >> "cfgMagazines" >> _x >> "picture") != "") then {
		_itemType = _x call bis_fnc_itemType;
		if (((_itemType select 0) == "Magazine") && ((_itemType select 1) in _ammoTypes)) then
		{
			ammoClassnames pushBack _x;
		};
	};
} foreach _magList;

{
	if (getnumber (configFile >> "cfgWeapons" >> _x >> "scope") > 1) then {
		_itemType = _x call bis_fnc_itemType;
		if (((_itemType select 0) == "Item") && ((_itemType select 1) in _attchmentTypes)) then
		{
			attachmentClassnames pushBack _x;
		};
	};
} foreach _weaponList;

{
	//check if usable weapon
	if (getnumber (configFile >> "cfgWeapons" >> _x >> "scope") > 1) then {
		_itemType = _x call bis_fnc_itemType;
		if (((_itemType select 0) == "Weapon") && ((_itemType select 1) in _weaponTypes)) then
		{
			_baseName = _x call BIS_fnc_baseWeapon;
			if ((_baseName isEqualTo _x)) then
			{
				if (!(_baseName in weaponClassnames)) then
				{
					if ((_baseName find "CUP" != -1)) then
					{
						if ((_baseName find "_AK" == -1) and
						(_baseName find "_RPK" == -1) and
						(_baseName find "_SVD" == -1) and
						(_baseName find "_SA" == -1) and
						(_baseName find "_PK" == -1) and
						(_baseName find "_VSS" == -1) and
						(_baseName find "ksvk" == -1) and
						(_baseName find "RPG" == -1) and
						(_baseName find "CZ" == -1) and
						(_baseName find "_Sa58" == -1) and
						(_baseName find "_UK59" == -1)) then
						{
							weaponClassnames pushBack _baseName;
						};
					};
				};
			};
		};
	};
} foreach _weaponList;

"carrier" execVM "fn_spawnCarrier.sqf";