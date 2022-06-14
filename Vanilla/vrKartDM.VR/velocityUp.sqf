_veh = assignedVehicle player;
_vel = velocity _veh;
_dir = direction _veh;
_speed = 20;
_veh setVelocity [(_vel select 0) + (sin _dir * _speed),(_vel select 1) + (cos _dir * _speed),(_vel select 2) + 1];