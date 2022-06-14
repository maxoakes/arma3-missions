waitUntil { scriptDone listInit };
_vehType = vehPool select (random floor count vehPool);
_loc = [getMarkerPos centerMarker, 0, ((getMarkerSize centerMarker) select 0)-10, 15, 0, .35, 0] call BIS_fnc_findSafePos;

currentVehicleCount = currentVehicleCount + 1;
_veh = createVehicle [_vehType, _loc, [], 0, "CAN_COLLIDE"];
_veh setDir random 360;
_veh setVectorUp surfaceNormal position _veh;
_veh setDamage random 0.1;
_veh setFuel random 1;

clearWeaponCargoGlobal _veh;
clearMagazineCargoGlobal _veh;
clearItemCargoGlobal _veh;

for "_i" from 1 to 3 do {
	_w = spawnPool select (random floor count spawnPool);
	_mags = (getArray (configFile >> "CfgWeapons" >> _w >> "magazines"));
	_veh addWeaponCargoGlobal[_w, 1];
	_veh addMagazineCargoGlobal[_mags select 0, 3];
	_veh addMagazineCargoGlobal[_mags select floor (random (count _mags)), 2];
	_veh addItemCargoGlobal [attachmentPool select floor (random (count attachmentPool)), 1];
};

_veh spawn
{
	waitUntil {sleep 10; !alive _this};
	currentVehicleCount = currentVehicleCount - 1;
};