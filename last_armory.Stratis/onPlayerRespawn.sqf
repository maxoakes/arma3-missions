params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

removeAllWeapons _newUnit;
removeAllItems _newUnit;
removeAllAssignedItems _newUnit;
removeVest _newUnit;

_newUnit enableFatigue false;
_newUnit addItem "ItemGPS";
_newUnit assignItem "ItemGPS";

_newUnit execVM "simpleEP.sqf";
SCO_PREVIOUS_LOADOUT = getUnitLoadout _oldUnit;

_newUnit setPosATL [getPos _newUnit select 0, getPos _newUnit select 1, 0];
_newUnit spawn
{
	private _radius = (getMarkerSize MAP_TELEPORT_ORIGIN_MARKER) select 0;
	while {alive _this} do
	{
		if (_this distance2D getMarkerPos MAP_TELEPORT_ORIGIN_MARKER < _radius) then
		{
			hint "If you are in the circle, single left-click on the map to teleport to that position.";
			_this onMapSingleClick
			{
				(vehicle _this) setPos _pos;
			};
		}
		else
		{
			_this onMapSingleClick { }; //do nothing
		};
		sleep 0.5;
	};
};