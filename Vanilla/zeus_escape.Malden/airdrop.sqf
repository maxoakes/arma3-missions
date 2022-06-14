_caller = (_this select 1);
missionNamespace setVariable ["airdropAvailable", false, true]; 

_centerPos = getPos _caller;
_startPos = [(_centerPos select 0)-3000,(_centerPos select 1),200];
_endPos = [(_centerPos select 0)+3000,(_centerPos select 1),200];

_grp = createGroup west;
_aimRadius = 50;
_wp0 = _grp addWaypoint [_centerPos, _aimRadius];
_wp1 = _grp addWaypoint [_endPos, 300];

[_grp, 0] setWaypointType 'Move';

_plane = createVehicle ["CUP_B_C130J_USMC",_startPos,[],100,'FLY'];

_dir = 90;
_plane setDir _dir;
_speed = 150;
_plane setVelocity [(sin _dir * _speed),(cos _dir * _speed), 0];

_pilot = _grp createUnit ["CUP_B_US_Soldier", _centerPos, [], 0, 'NONE'];
_pilot moveInDriver _plane;
_pilot setSkill 1;

waitUntil {(_plane distance2D _centerPos) < _aimRadius};
_grp setCurrentWaypoint [_grp, 1];

//crate 1 - weapons
_crateWeapons = createVehicle ["B_supplyCrate_F",[(getPos _plane select 0)-10, (getPos _plane select 1), (getPos _plane select 2)-10],[], 0, "CAN_COLLIDE"];
_crateWeapons allowDamage false;
_crateWeapons setVelocity [((velocity _plane select 0)/20),((velocity _plane select 1)/20), -5];
_crateWeapons addAction ["Add Ammo for this Weapon","refill.sqf"];
_crateWeapons addAction ["Destroy this crate","destroy.sqf"];

sleep 0.25;
//crate 2 - attachments
_crateAtt = createVehicle ["C_IDAP_supplyCrate_F",[(getPos _plane select 0)-10, (getPos _plane select 1), (getPos _plane select 2)-10],[], 0, "CAN_COLLIDE"];
_crateAtt allowDamage false;
_crateAtt setVelocity [((velocity _plane select 0)/20),((velocity _plane select 1)/20), -5];

//fill both crates
clearWeaponCargoGlobal _crateWeapons;
clearItemCargoGlobal _crateWeapons;
clearBackpackCargoGlobal _crateWeapons;
clearMagazineCargoGlobal _crateWeapons;

clearWeaponCargoGlobal _crateAtt;
clearItemCargoGlobal _crateAtt;
clearBackpackCargoGlobal _crateAtt;
clearMagazineCargoGlobal _crateAtt;
{
	_crateAtt addItemCargoGlobal [_x, 8];
} foreach attachmentClassnames;
{
	_crateWeapons addWeaponCargoGlobal [_x, 2];
} foreach weaponClassnames;
{
	_crateWeapons addItemCargoGlobal [_x, 8];
} forEach ammoClassnames;

sleep 20;
deleteVehicle _plane;
deleteVehicle _pilot;

sleep AIRDROP_TIME;
missionNamespace setVariable ["airdropAvailable", true, true]; 