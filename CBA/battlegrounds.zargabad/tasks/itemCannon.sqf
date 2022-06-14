waitUntil { scriptDone listInit };

_pos = [(getMarkerPos centerMarker select 0),(getMarkerPos centerMarker select 1), 4];
_box = createVehicle [boxObjectType, _pos, [], 0, "CAN_COLLIDE"];
_box allowDamage false;
_dir = random 360;
_speed = random (radius/8);
_vel = [0,0,0];
_box setVelocity [
	(_vel select 0) + (sin _dir * _speed), 
	(_vel select 1) + (cos _dir * _speed), 
	(_vel select 2) + 30
];

//CREATE INVENTORY
clearWeaponCargoGlobal _box;
clearMagazineCargoGlobal _box;
clearBackpackCargoGlobal _box;
clearItemCargoGlobal _box;

for "_i" from 1 to 2 do {
	_w = cratePool select (random floor count cratePool);
	
	_box addWeaponCargoGlobal[_w, 1];
	_mags = (getArray (configFile >> "CfgWeapons" >> _w >> "magazines"));
	for "_j" from 1 to 1 do
	{
		_box addMagazineCargoGlobal[_mags select floor (random (count _mags)), 2];
	};
	for "_k" from 1 to 2 do
	{
		_box addItemCargoGlobal [attachmentPool select floor (random (count attachmentPool)), 1];
	};
};

sleep cannonWaveTime;

//deletion sequence
_smoke = createVehicle ["SmokeShell", getPos _box, [], 0, "CAN_COLLIDE"];
sleep 8;
deleteVehicle _box;