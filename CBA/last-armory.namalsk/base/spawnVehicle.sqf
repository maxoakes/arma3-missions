_thePlayer = (_this select 1);
_type = (_this select 3);

_landVehicleTypes = ["Car","Motorcycle","TrackedAPC","Tank","WheeledAPC","Helicopter"];
_planeVehicleTypes = ["Plane"];
_vehicleType = (_type call BIS_fnc_objectType) select 1;

if (_vehicleType in _landVehicleTypes) then
{
	_posSpawn = [spawnCenter, 25, vehicleSpawnRadius, 15, 0, maxGradient, 0,[], getMarkerPos "plane_spawn"] call BIS_fnc_findSafePos;
	_veh = createVehicle [_type, _posSpawn, [], 0, "NONE"];
	_veh setVectorUp surfaceNormal _posSpawn;
	_thePlayer moveInDriver _veh;
}
else {

	if (_vehicleType in _planeVehicleTypes) then {
		_nearest = ASLToAGL getMarkerPos "plane_spawn" nearEntities [_planeVehicleTypes + _landVehicleTypes, 15];
		if (count _nearest > 0) then
		{
			_thePlayer globalChat "I want to summon a plane at the airstrip!";
		} else
		{
			_veh = createVehicle [_type, getMarkerPos "plane_spawn", [], 0, "CAN_COLLIDE"];
			_veh setDir MarkerDir "plane_spawn";
			_thePlayer moveInDriver _veh;
		}
	} else {
		_posSpawn = [spawnCenter, 25, vehicleSpawnRadius*2, 15, 2] call BIS_fnc_findSafePos;
		_veh = createVehicle [_type, _posSpawn, [], 0, "CAN_COLLIDE"];
		_thePlayer moveInDriver _veh;
	};
};