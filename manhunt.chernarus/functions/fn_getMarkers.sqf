/*
	Author: Scouter

	Description:
		given a prefix, returns all markers with that prefix, since the BIS implementation of this
		does not work they way I want.

	Parameter(s):
		0: String - (required) prefix
		1: Position - (optional) center position to check for markers in a radius
		2: Number - (optional) radius to search

	Returns:
		Array of markers that have that prefix
*/
params ["_prefix", "_center", "_radius"];

//create default search area. entire map by default
if (isNil "_center" or isNil "_radius") then
{
	_center = [worldSize / 2, worldsize / 2, 0];
	_radius = worldSize;
};

private _markers = [];
{
	private _inRange = _center distance2D getMarkerPos _x < _radius;
	if (_x find _prefix == 0 and _inRange) then
	{
		_markers pushBack _x;
	};
} forEach allMapMarkers;

//return
_markers;