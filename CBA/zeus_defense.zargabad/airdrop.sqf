missionNamespace setVariable ["airdropAvailable", false, true]; 

_centerPos = getMarkerPos "cap";
_startPos = [(_centerPos select 0)-2000,(_centerPos select 1),200];
_endPos = [(_centerPos select 0)+2000,(_centerPos select 1),200];

_grp = createGroup west;
_aimRadius = 50;
_wp0 = _grp addWaypoint [_centerPos, _aimRadius];
_wp1 = _grp addWaypoint [_endPos, 300];

[_grp, 0] setWaypointType 'Move';

_plane = createVehicle [planeType,_startPos,[],100,'FLY'];

_dir = 90;
_plane setDir _dir;
_speed = 150;
_plane setVelocity [(sin _dir * _speed),(cos _dir * _speed), 0];

_pilot = _grp createUnit [driverType, _centerPos, [], 0, 'NONE'];
_pilot moveInDriver _plane;
_pilot setSkill 1;

waitUntil {(_plane distance2D getMarkerPos "cap") < _aimRadius};
_grp setCurrentWaypoint [_grp, 1];

_crate = createVehicle [crateType,[(getPos _plane select 0)-10, (getPos _plane select 1), (getPos _plane select 2)-10],[], 0, "CAN_COLLIDE"];
_crate allowDamage false;

clearWeaponCargoGlobal _crate;
clearItemCargoGlobal _crate;
clearBackpackCargoGlobal _crate;
clearMagazineCargoGlobal _crate;

_crate setVelocity [((velocity _plane select 0)/20),((velocity _plane select 1)/20), -5];
_crate addAction ["Add Ammo for this Weapon","refill.sqf"];
_crate addAction ["Destroy this crate","destroy.sqf"];

{
	_crate addWeaponCargoGlobal [_x, 2];
} foreach weaponClassnames;
{
	_crate addItemCargoGlobal [_x, 8];
} forEach ammoClassnames;

sleep 30;
deleteVehicle _plane;
deleteVehicle _pilot;

sleep AIRDROP_TIME;
missionNamespace setVariable ["airdropAvailable", true, true]; 