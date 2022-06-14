_thePlayer = (_this select 1);
_type = (_this select 3);

_landVehicleTypes = ["Car","Motorcycle","TrackedAPC","Tank","WheeledAPC"];
_vehicleType = (_type call BIS_fnc_objectType) select 1;

if (_vehicleType in _landVehicleTypes) then
{
	_posSpawn = [armoryLocation, 15, armorySize, 25, 0, maxGradient, 0] call BIS_fnc_findSafePos;
	_veh = createVehicle [_type, _posSpawn, [], 0, "CAN_COLLIDE"];
	_veh setVectorUp surfaceNormal _posSpawn;
	_thePlayer moveInDriver _veh;
}
else
{
	_posSpawn = [armoryLocation, 0, armorySize, 20, 2, 0, 1] call BIS_fnc_findSafePos;
	_veh = createVehicle [_type, _posSpawn, [], 0, "FLY"];
	_veh setVectorUp [0,0,0];
	_thePlayer moveInDriver _veh;
};