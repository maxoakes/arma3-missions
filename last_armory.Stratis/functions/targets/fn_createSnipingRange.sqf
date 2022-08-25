params ["_rangeMarker", ["_createShootingRange", true], ["_steps", [0, 200, 400, 600, 800, 1000]], ["_angleOffset", 0]];

private _angle = markerDir _rangeMarker + _angleOffset;
private _posRoot = getMarkerPos _rangeMarker;

if (_createShootingRange) then
{
	//create shooting range
	private _shootingRange = [
		["Land_PierWooden_02_hut_F",[0,0,15.212],0],
		["Land_PierWooden_02_ladder_F",[2.10376,-5.7876,15.212],180],
		["Land_Camping_Light_F",[-0.875,-1.875,17.6013],359.99],
		["ShootingMat_01_OPFOR_F",[2.37402,1.97266,17.6026],0],
		["ShootingMat_01_folded_OPFOR_F",[3.25,1.23193,17.595],179.988],
		["ShootingMat_01_folded_Olive_F",[3.16528,1.18945,17.6442],344.863],
		["ShootingMat_01_folded_Khaki_F",[3.20984,1.98975,17.595],164.944],
		["Land_MysteriousBell_01_F",[0.125,-2.25,17.6026],270],
		["B_supplyCrate_F",[-1.875,-1.375,17.6016],14.9994]
	];
	private _shootingRange = [ASLToATL _posRoot, _shootingRange, 0, _angle, false, 2, true] call SCO_fnc_placeObjectsFromArray;
	private _crate = _shootingRange select 8;
	["AmmoboxInit", [_crate, true, { (_this distance _target) < 10 }]] call BIS_fnc_arsenal;
	[_crate, ["Add Ammo for this Weapon", { _this call SCO_fnc_refillWeapon }, 4]] remoteExec ["addAction", 0, true];
	[_crate, ["Teleport back to spawn", { (_this select 1) setPos getMarkerPos "respawn_west"}]] remoteExec ["addAction", 0, true];
	["respawn_west_sniper_range", _posRoot getPos [-10, _angle], "Sniper Range", [1, 1], "Default", "ICON", "Empty", 0, 1] call SCO_fnc_createMarker;
};

private _shootingRow = [
	["Land_PierConcrete_01_end_F",[0,0,4.47086],0],
	["Land_PierLadder_F",[5,1.25,2.59586],270],
	["TargetP_Inf2_Acc1_F",[-0.933838,1.6123,5.31037],0],
	["TargetP_Inf3_Acc1_F",[-2.18848,-0.0688477,5.31037],0],
	["Target_Swivel_01_right_F",[-1,0.15,5.59586],0],
	["TargetP_Civ3_F",[2.25,-1.75,5.31037],0],
	["TargetP_Inf4_Acc1_F",[-1,-3.125,5.31037],0],
	["Land_Shoot_House_Wall_Long_Crouch_F",[0.875,0.25,5.31037],0],
	["Target_Swivel_01_ground_F",[-2.75,-2.375,5.31037],0],
	["Land_Shoot_House_Tunnel_Stand_F",[-2.5,0.25,5.31037],0],
	["Land_Target_Dueling_01_F",[3.48035,-3.42285,5.31037],0],
	["Land_Shoot_House_Wall_Long_Crouch_F",[1.75,-2.625,5.31037],345],
	["TargetP_Inf9_Acc1_F",[-3.125,-3.375,5.31037],0],
	["Land_Shoot_House_Wall_Long_Prone_F",[-1.625,-3.625,5.31037],0],
	["Land_Target_Dueling_01_F",[-1.89099,-0.887207,7.31687],0],
	["Target_Swivel_01_left_F",[-4,1.125,6.09586],0]
];

{
	private _posAGL = _posRoot getPos [_x, _angle];
	private _distanceIndicators = [];
	private _currentX = -2.75;
	for "_i" from 1 to ceil (_x/100) do
	{
		_distanceIndicators pushBack ["Sign_Sphere25cm_F",[_currentX,-3.875,4.97086],0];
		_currentX = _currentX + 0.5;
	};
	[_posAGL, _shootingRow + _distanceIndicators, 0, _angle, false, ((_forEachIndex)*3)+1, true] call SCO_fnc_placeObjectsFromArray;
	[format ["target%1", _x], _posAGL, format ["%1m", _x], [0.5, 0.5], "ColorYellow", "ICON", "mil_dot"] call SCO_fnc_createMarker;
} forEach _steps;
