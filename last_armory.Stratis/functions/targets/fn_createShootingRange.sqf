params ["_areaMarker"];

private _centerPos = getMarkerPos _areaMarker;
private _radius = getMarkerSize _areaMarker select 0;

//outer wall
private _shootingRangeWall = [_centerPos, _radius, ["Land_ConcreteWall_01_l_8m_F"], 7.98, 0] call SCO_fnc_createBorder;

//spawn points
private _spawnPoints = [_centerPos, _radius - 2, ["Sign_Arrow_Pink_F"], 8, 0] call SCO_fnc_createBorder;

//center
private _centerRim = [_centerPos, 1.8, ["Land_BagFence_Round_F"], (2 * pi * 1.6)/4, 180] call SCO_fnc_createBorder;
private _centerObject = createVehicle ["Flag_Nato_F", _centerPos, [], 0, "CAN_COLLIDE"];
["shooting_range_name", _centerPos, "Shooting Range", [0.5, 0.5], "ColorYellow", "ICON", "mil_dot"] call SCO_fnc_createMarker;

//obsticles
private _classnames = ["Land_Shoot_House_Wall_Long_Prone_F"];
private _numRows = 6;
private _rowSpacing = ((_radius - 2) - 2)/_numRows;
private _obsticles = [];
for "_i" from 2 to _numRows do
{
	private _currRadius = _rowSpacing * _i;
	private _rowObjects = [_centerPos, _currRadius, _classnames, 4, 0, 0, true, random [-20, 0, 20]] call SCO_fnc_createBorder;
	_obsticles append _rowObjects;
};

missionNamespace setVariable ["SCO_SHOOTING_RANGE_WAVE_ACTIVE", false, true];

//addActions
[_centerObject, ["Add Ammo for this Weapon", { _this call SCO_fnc_refillWeapon }, 4]] remoteExec ["addAction", 0, true];
[_centerObject, ["Spawn Waves (Easy)", { _this call SCO_fnc_spawnShootingRangeWave }, [_radius, _spawnPoints, 10, 2, 5], 2, true, true, "", "!SCO_SHOOTING_RANGE_WAVE_ACTIVE"]] remoteExec ["addAction", 0, true];
[_centerObject, ["Spawn Waves (Medium)", { _this call SCO_fnc_spawnShootingRangeWave }, [_radius, _spawnPoints, 5, 5, 4], 2, true, true, "", "!SCO_SHOOTING_RANGE_WAVE_ACTIVE"]] remoteExec ["addAction", 0, true];
[_centerObject, ["Spawn Waves (Hard)", { _this call SCO_fnc_spawnShootingRangeWave }, [_radius, _spawnPoints, 4, 10, 5], 2, true, true, "", "!SCO_SHOOTING_RANGE_WAVE_ACTIVE"]] remoteExec ["addAction", 0, true];

[_centerObject, ["Teleport to spawn", {
	params ["_target", "_caller", "_id", "_args"];
	_args params ["_center", "_radius"];
	(_this select 1) setPos getMarkerPos "respawn_west";
	{
		if (side _x == east) then { deleteVehicle _x; };
	} forEach (_center nearObjects ["Man", _radius + 2]);
}, [_centerPos, _radius]]] remoteExec ["addAction", 0, true];