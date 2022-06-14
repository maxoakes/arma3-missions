//create player spawn zone border
_centerCircleRadius = spawnCenterRadius*1.5;

_borderSpacing = 1.5;
_count = round((2 * 3.14592653589793 * _centerCircleRadius) / _borderSpacing);
_step = 360/_count;
_angle = 0;

for "_x" from 0 to _count do
{
	_a = (spawnCenter select 0)+(sin(_angle)*_centerCircleRadius);
	_b = (spawnCenter select 1)+(cos(_angle)*_centerCircleRadius);

	_pos = [_a,_b,(spawnCenter select 2) + 0];

	_post = "Land_WallCity_01_pillar_pink_F" createVehicle _pos;
	_post setPos _pos;
	_post setDir _angle;
	_post allowDamage false;
	_angle = _angle + _step;
};

//create safezone
if (true) then {
	_trg = createTrigger ["EmptyDetector", spawnCenter, true];
	_trg setTriggerArea [_centerCircleRadius, _centerCircleRadius, 0, true, _centerCircleRadius];
	_trg setTriggerActivation ["ANY", "PRESENT", true];
	_trg setTriggerStatements ["player in thisList", "player allowDamage false", "player allowDamage true"];
};

_grassCutter = createVehicle ["Land_ClutterCutter_medium_F", spawnCenter, [], 0, "CAN_COLLIDE"];
//create spawning pillars
_numPillars = 10;

_facing = 0;
map = createVehicle ["Land_PhoneBooth_01_malden_F", [(spawnCenter select 0)+(sin(_facing)*spawnCenterRadius), (spawnCenter select 1)+(cos(_facing)*spawnCenterRadius), (spawnCenter select 2)], [], 0, "CAN_COLLIDE"];
map setDir _facing;
map allowDamage false;

_facing = _facing + (360/_numPillars);
missions = createVehicle ["Land_WallCity_01_pillar_whiteblue_F", [(spawnCenter select 0)+(sin(_facing)*spawnCenterRadius), (spawnCenter select 1)+(cos(_facing)*spawnCenterRadius), (spawnCenter select 2)], [], 0, "CAN_COLLIDE"];
missions setDir _facing;
missions allowDamage false;
missions addAction ["Create a Capture and Hold Mission",{"mission\capture.sqf" remoteExec ["execVM", 2];}];

_facing = _facing + (360/_numPillars);
helo = createVehicle ["Land_SignM_forSale_F", [(spawnCenter select 0)+(sin(_facing)*spawnCenterRadius), (spawnCenter select 1)+(cos(_facing)*spawnCenterRadius), (spawnCenter select 2)], [], 0, "CAN_COLLIDE"];
helo setDir _facing;
helo allowDamage false;

_facing = _facing + (360/_numPillars);
plane = createVehicle ["SignAd_Sponsor_IDAP_F", [(spawnCenter select 0)+(sin(_facing)*spawnCenterRadius), (spawnCenter select 1)+(cos(_facing)*spawnCenterRadius), (spawnCenter select 2)], [], 0, "CAN_COLLIDE"];
plane setDir _facing;
plane allowDamage false;

_facing = _facing + (360/_numPillars);
boat = createVehicle ["SignAd_Sponsor_ARMEX_F", [(spawnCenter select 0)+(sin(_facing)*spawnCenterRadius), (spawnCenter select 1)+(cos(_facing)*spawnCenterRadius), (spawnCenter select 2)], [], 0, "CAN_COLLIDE"];
boat setDir _facing;
boat allowDamage false;

_facing = _facing + (360/_numPillars);
lamp = createVehicle ["Land_LampHarbour_F", [(spawnCenter select 0)+(sin(_facing)*spawnCenterRadius), (spawnCenter select 1)+(cos(_facing)*spawnCenterRadius), (spawnCenter select 2)], [], 0, "CAN_COLLIDE"];
lamp setDir _facing + 180;
lamp allowDamage false;

_facing = _facing + (360/_numPillars);
car = createVehicle ["Land_SignM_taxi_F", [(spawnCenter select 0)+(sin(_facing)*spawnCenterRadius), (spawnCenter select 1)+(cos(_facing)*spawnCenterRadius), (spawnCenter select 2)], [], 0, "CAN_COLLIDE"];
car setDir _facing;
car allowDamage false;

_facing = _facing + (360/_numPillars);
apc = createVehicle ["Land_SignM_WarningMilAreaSmall_english_F", [(spawnCenter select 0)+(sin(_facing)*spawnCenterRadius), (spawnCenter select 1)+(cos(_facing)*spawnCenterRadius), (spawnCenter select 2)], [], 0, "CAN_COLLIDE"];
apc setDir _facing;
apc allowDamage false;

_facing = _facing + (360/_numPillars);
tank = createVehicle ["Land_Sign_MinesDanger_Greek_F", [(spawnCenter select 0)+(sin(_facing)*spawnCenterRadius), (spawnCenter select 1)+(cos(_facing)*spawnCenterRadius), (spawnCenter select 2)], [], 0, "CAN_COLLIDE"];
tank setDir _facing;
tank allowDamage false;

_facing = _facing + (360/_numPillars);
arsenal = createVehicle ["Land_Sign_WarningNoWeapon_F", [(spawnCenter select 0)+(sin(_facing)*spawnCenterRadius), (spawnCenter select 1)+(cos(_facing)*spawnCenterRadius), (spawnCenter select 2)], [], 0, "CAN_COLLIDE"];
arsenal setDir _facing;
arsenal allowDamage false;
removeAllWeapons arsenal;
removeAllItems arsenal;
{arsenal removeMagazine _x} forEach magazines arsenal;
[ "AmmoboxInit", [ arsenal, true, {(_this distance _target) < 10} ] ] call BIS_fnc_arsenal;
arsenal addAction ["Heal Yourself","(_this select 1) setDamage 0;"];
arsenal addAction ["Add ammo for this Weapon","base\fillMag.sqf"];

//broken, OP armory
//_armoryCenterObject = createVehicle ["Sign_Sphere100cm_Geometry_F", [(spawnCenter select 0),(spawnCenter select 1),(spawnCenter select 2)+2.2], [], 0, "CAN_COLLIDE"];
//_armoryCenterObject addAction ["<t color='#ff0000'>Return to base</t>","(_this select 1) setPos spawnCenter;"];
//_armoryCenterObject addAction ["<t color='#0000ff'>Open Garage</t>",
//{
//	_thePlayer = (_this select 1);
//	_pos = [armoryLocation, 10, armorySize, 20, 0, 0.1, 0] call BIS_fnc_findSafePos;
//	_center = createVehicle ["Land_HelipadEmpty_F",_pos,[],0,"CAN_COLLIDE"];
//	["Open",[true, _center]] call BIS_fnc_garage; 
//}];

