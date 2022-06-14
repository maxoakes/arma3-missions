_poiList = ["NameVillage","NameCity","NameCityCapital","NameLocal"];
_towns = nearestLocations [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), _poiList, worldSize];

_blackListed = [];
{
	_blackListed append nearestLocations [getMarkerPos _x, _poiList, 1000];
} foreach blackListedMarkers;

//map addAction ["<t color='#0000ff'>Random Location","base\teleport.sqf",[false,0]];
{
	map addAction [format ["%1",text(_x)],"base\teleport.sqf",[true,_x]];
} foreach (_towns - _blackListed);
