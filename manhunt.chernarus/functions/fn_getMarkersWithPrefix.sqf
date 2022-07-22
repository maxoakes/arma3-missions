/*
	Author: Scouter

	Description:
		given a prefix, returns all markers with that prefix, since the BIS implementation of this
		does not work they way I want.

	Parameter(s):
		0: String - prefix

	Returns:
		Array of markers that have that prefix
*/
params ["_prefix"];

private _markers = [];
{
	if (_x find _prefix == 0) then
	{
		_markers pushBackUnique _x;
	};
} forEach allMapMarkers;

//return
_markers;