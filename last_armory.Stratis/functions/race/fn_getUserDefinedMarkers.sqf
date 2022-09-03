params ["_string"];

private _userDefinedMarkers = [];
{
	private _markers = _x;
	//if it is a user-placed marker in global chat that has 'finish' in the text
	if (("_USER_DEFINED" in _markers) and ("finish" in (markerText _markers)) and (markerChannel _markers == 0)) then
	{
		_userDefinedMarkers pushBack _markers;
	};
} forEach allMapMarkers;

//return
_userDefinedMarkers;