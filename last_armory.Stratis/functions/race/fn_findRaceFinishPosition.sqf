params ["_startObject", ["_mode", 0], ["_distance", 2000], ["_marker", ""]];
private _chosenPos = [0,0,0];
private _chosenDir = 0;

private _poiTypes = ["NameVillage", "NameCity", "NameCityCapital", "NameLocal", "Name", "NameMarine", "Hill"];
switch _mode do
{
	case 0: //random distance race
	{
		//use a random location (that is not near a marker)
		private _blackListed = [];
		{
			_blackListed append nearestLocations [getMarkerPos _x, _poiTypes, 500];
		} foreach allMapMarkers;

		//list of locations that is +/- 1000m the desired distance, and excludes locations near markers
		private _poiList = (nearestLocations [getPos _startObject, _poiTypes, _distance + 1000] - nearestLocations [getPos _startObject, _poiTypes, _distance - 1000]) - _blackListed;

		private _finishRoad = [_startObject getPos [_distance, getDir _startObject], 6000] call BIS_fnc_nearestRoad;
		if (count _poiList > 0) then
		{
			[locationPosition selectRandom _poiList, 6000] call BIS_fnc_nearestRoad;
		};

		//place the finish line
		private _info = getRoadInfo _finishRoad;
		_info params ["_mapType", "_width", "_isPedestrian", "_texture", "_textureEnd", "_material", "_begPos", "_endPos", "_isBridge"];

		_chosenPos = getPos _finishRoad;
		_chosenDir = _begPos getDir _endPos;
	};
	case 1: //on road
	{
		private _safeRoad = [getMarkerPos _marker, 1000] call BIS_fnc_nearestRoad;
		_chosenPos = getPos _safeRoad;

		//set the direction to be that of the nearest road
		private _info = getRoadInfo _safeRoad;
		_info params ["_mapType", "_width", "_isPedestrian", "_texture", "_textureEnd", "_material", "_begPos", "_endPos", "_isBridge"];
		_chosenDir = (_begPos getDir _endPos);
	};
	case 2: //off road
	{
		_chosenPos = [getMarkerPos _marker, 0, 50, 8, 0, 0.5, 0, [], [getMarkerPos _marker, getMarkerPos _marker]] call BIS_fnc_findSafePos;
		_chosenDir = _startObject getDir (getMarkerPos _marker);
	};
	case 3: //heli race
	{
		_chosenPos = [getMarkerPos _marker, 0, 500, 20, 0, 0.5, 0, [], [getMarkerPos _marker, getMarkerPos _marker]] call BIS_fnc_findSafePos;
	};
};

private _nearestLocations = nearestLocations [_chosenPos, _poiTypes, 1000];
if (count _nearestLocations > 0) then
{
	format ["Race finish line has been placed near %1", text (_nearestLocations select 0)] remoteExec ["systemChat", 0];
}
else
{
	format ["Race finish line has been placed %1 meters away", _startObject distance2D _finishPost] remoteExec ["systemChat", 0];
};

//return
[_chosenPos, _chosenDir];