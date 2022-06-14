_module = _this select 0;
_newOwner = _this select 1;
_oldOwner = _this select 2;

_loc = ((nearestLocations [getPos _module, ["NameCity","NameCityCapital","NameLocal","NameVillage"], 1000]) select 0);
_thisEditAreaID = parseNumber mapGridPosition getPos _module;
_markerName = format ["respawn_west_%1", mapGridPosition getPos _module];

if (_newOwner == west) then
{
	gm removeCuratorEditingArea _thisEditAreaID;
	_respawn = createMarker [_markerName,getPos _module];
	_respawn setMarkerShape "ICON";
	_respawn setMarkerType "mil_flag";
	_respawn setMarkerColor "ColorWEST";
	_respawn setMarkerText text _loc;
};
if (_newOwner == east) then
{
	deleteMarker _markerName;
	_radius = (((size _loc select 0)+(size _loc select 1))/2);
	gm addCuratorEditingArea [_thisEditAreaID, getPos _module, 100];
};