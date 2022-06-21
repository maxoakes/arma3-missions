params ["_module", "_newOwner", "_oldOwner"];

_loc = ((nearestLocations [getPos _module, ["NameCity","NameCityCapital","NameLocal","NameVillage"], 1000]) select 0);
_thisEditAreaID = parseNumber mapGridPosition getPos _module;
_markerName = format ["respawn_west_%1", mapGridPosition getPos _module];

if (_newOwner == west) then
{
	gm removeCuratorEditingArea _thisEditAreaID;
	private _pos = [getPos _module, 0, 30, 3, 0, 20, 0] call BIS_fnc_findSafePos;
	if (_pos distance2D getPos _module > 100) then 
	{
		_pos = getPos _module;
	};
	private _respawn = createMarker [_markerName, _pos];
	_respawn setMarkerShape "ICON";
	_respawn setMarkerType "mil_flag";
	_respawn setMarkerColor "ColorWEST";
	_respawn setMarkerText text _loc;
};
if (_newOwner == east) then
{
	deleteMarker _markerName;
	gm addCuratorEditingArea [_thisEditAreaID, getPos _module, 100];
};