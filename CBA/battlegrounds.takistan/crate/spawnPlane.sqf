_c = createCenter west;
_grp = createGroup _c;
done = false;
_wp = _grp addWaypoint [(_this select 0), 0];
_wp setWaypointStatements ["true", "done = true"];
[_grp, 0] setWaypointType 'Move';

_plane = createVehicle [airsrikeTypePlane,[((_this select 0) select 0), ((_this select 0) select 1)-1000,0],[],0,'FLY'];
_plane engineOn true;
_dir = 0;
_plane setDir _dir;
_speed = 160;
_plane setVelocity [(sin _dir * _speed),(cos _dir * _speed), 0];

_pilot = _grp createUnit [airstrikeTypePilot, (_this select 0), [], 0, 'NONE'];
_pilot moveInDriver _plane;
_pilot setSkill 1;

waitUntil {done};

_vel = velocity _plane;
_dir = direction _plane;
_slow = 15;

_b1 = createVehicle [airstrikeTypeBomb,[(getPos _plane select 0)-1, (getPos _plane select 1)-1, (getPos _plane select 2)-7],[], 0, "CAN_COLLIDE"];
_b1 setVelocity [(_vel select 0)/_slow,(_vel select 1)/_slow,(_vel select 2)-5];
_b2 = createVehicle [airstrikeTypeBomb,[(getPos _plane select 0)+1, (getPos _plane select 1), (getPos _plane select 2)-8],[], 0, "CAN_COLLIDE"];
_b2 setVelocity [(_vel select 0)/_slow,(_vel select 1)/_slow,(_vel select 2)-5];

done = false;
_end = _grp addWaypoint [[2500,5000,0], 0];
sleep 45;
deleteVehicle _plane;
deleteVehicle _pilot;