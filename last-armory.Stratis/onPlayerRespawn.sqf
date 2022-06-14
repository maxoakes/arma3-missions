removeAllWeapons player;
removeAllItems player;
removeAllAssignedItems player;
removeVest player;
player enableFatigue false;
player addItem "ItemMap";
player assignItem "ItemMap";

onMapSingleClick "
	_nearModule = (_pos nearEntities ['ModuleSector_F', 5000]) select 0;
	if ((_nearModule distance2D _pos < sectorSize*4) and (_nearModule distance2D _pos > sectorSize) and (player distance2D spawnCenter < 1000)) then {vehicle player setPos _pos; true;} else {false;};
	";