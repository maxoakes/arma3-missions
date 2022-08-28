params ["_target", "_caller", "_actionId", "_arguments"];
_arguments params ["_vehicleClassname", "_landMarkers", "_planeMarkers", "_waterMarkers"];

private _vehicleType = _vehicleClassname call BIS_fnc_objectType;
private _runwaySpawnTypes = ["Plane"];
private _waterSpawnTypes = ["Ship", "Submarine"];

private _spawningZoneMarker = "";
private _mustBeInWater = 0;
if (!((_vehicleType select 1) in _runwaySpawnTypes + _waterSpawnTypes)) then
{
	_spawningZoneMarker = selectRandom _landMarkers;
};

//if it is a plane, use the runway marker
if ((_vehicleType select 1) in _runwaySpawnTypes) then
{
	_spawningZoneMarker = selectRandom _planeMarkers;
	//modify the safe position function's parameters to allow for plane spawning
};
//if it is a boat, use the water marker
if ((_vehicleType select 1) in _waterSpawnTypes) then
{
	_spawningZoneMarker = selectRandom _waterMarkers;
	_mustBeInWater = 2;
};

//create a default spawn position somewhere in the area
private _findSafePosArray = [
	getMarkerPos _spawningZoneMarker, //0, center
	0, //1, min search radius
	getMarkerSize _spawningZoneMarker select 0, //2, max search radius
	12, //3, min dist to other objects
	_mustBeInWater, //4, cannot be in water
	1.0, //5, max allowable ground slope
	0, //6, does not need to be on shore
	[], //7, cannot be near select markers
	[getMarkerPos _spawningZoneMarker, getMarkerPos _spawningZoneMarker] //8, default locations
];

private _pos = _findSafePosArray call BIS_fnc_findSafePos;
private _veh = createVehicle [_vehicleClassname, _pos, [], 0, "NONE"];
_veh setDir markerDir _spawningZoneMarker;
_veh setVectorUp surfaceNormal _pos;

//return
_veh;