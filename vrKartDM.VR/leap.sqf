_veh = assignedVehicle player;
_vel = velocity _veh;
_dir = direction _veh;

_veh setVelocity [(_vel select 0),(_vel select 1),(_vel select 2) + 5];