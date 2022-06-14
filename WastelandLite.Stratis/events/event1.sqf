_eventSize = 15;

_i = locPool call BIS_fnc_selectRandom;
_loc = getMarkerPos _i;
_nearObj = _loc nearObjects _eventSize;
_nearAI = _loc nearEntities ["Man", _eventSize*2];

sleep 2;

if (count _nearObj > 1) then
{
	{deleteVehicle _x} forEach _nearAI;
	{deleteVehicle _x} forEach _nearObj;
	sleep 5;
};

sleep 2;
eventActive = true;
_obj1 = createVehicle ["Land_HBarrier_Big_F",[(_loc Select 0), ( _loc Select 1)-8, (_loc Select 2)], [], 0, "CAN_COLLIDE"];
_obj2 = createVehicle ["CamoNet_OPFOR_big_F", _loc, [], 0, "CAN_COLLIDE"];

_obj3 = createVehicle ["Box_NATO_AmmoVeh_F",[(_loc Select 0)-1, ( _loc Select 1)-3, (_loc Select 2)], [], 0, "CAN_COLLIDE"];
_obj3 setDir 25;
_obj3 allowDamage false;

_obj4 = createVehicle ["Box_NATO_AmmoVeh_F",[(_loc Select 0)+1.5, ( _loc Select 1)-2, (_loc Select 2)], [], 0, "CAN_COLLIDE"];
_obj4 setDir 10;
_obj4 allowDamage false;
_obj3 addWeaponCargoGlobal["launch_NLAW_F",2];
_obj3 addWeaponCargoGlobal["launch_RPG32_F",2];
_obj4 addWeaponCargoGlobal["launch_Titan_F",2];
_obj4 addWeaponCargoGlobal["launch_Titan_short_F",2];
_obj3 addMagazineCargoGlobal["NLAW_F",2];
_obj3 addMagazineCargoGlobal["RPG32_F",2];
_obj3 addMagazineCargoGlobal["RPG32_HE_F",2];
_obj4 addMagazineCargoGlobal["Titan_AA",2];
_obj4 addMagazineCargoGlobal["Titan_AT",2];

_obj5 = createVehicle ["O_HMG_01_high_F",[(_loc Select 0)+6, ( _loc Select 1)-9, (_loc Select 2)], [], 0, "CAN_COLLIDE"];
_obj5 setDir 165;

sleep 2;

_unit1 = opforGroup createUnit ["O_SoldierU_AA_F", _loc, [], 3, "CAN_COLLIDE"];
_unit2 = opforGroup createUnit ["O_Soldier_AA_F", _loc, [], 3, "CAN_COLLIDE"];
_unit3 = opforGroup createUnit ["O_Soldier_AAA_F", _loc, [], 3, "CAN_COLLIDE"];
_unit4 = opforGroup createUnit ["O_Soldier_AAT_F", _loc, [], 3, "CAN_COLLIDE"];
_unit5 = opforGroup createUnit ["O_SoldierU_AT_F", _loc, [], 3, "CAN_COLLIDE"];
_unit6 = opforGroup createUnit ["O_Soldier_AT_F", _loc, [], 3, "CAN_COLLIDE"];
_unit7 = opforGroup createUnit ["O_Soldier_lite_F",[(_loc Select 0)-5, ( _loc Select 1)-10, (_loc Select 2)], [], 0, "CAN_COLLIDE"];
_unit8 = opforGroup createUnit ["O_Soldier_lite_F",[(_loc Select 0)+5, ( _loc Select 1)-10, (_loc Select 2)], [], 0, "CAN_COLLIDE"];

_eventMen = ["O_SoldierU_AA_F","O_Soldier_AA_F","O_Soldier_AAA_F","O_Soldier_AAT_F","O_SoldierU_AT_F","O_Soldier_AT_F","O_Soldier_lite_F"];

_nearObj = _loc nearObjects _eventSize;
_nearAI = _loc nearEntities ["Man", _eventSize*2];

sleep 2;

hint "An AA and AT team have set up base! Check your map for the location.";

sleep 2;

_i setMarkerText "AT/AA Team Camp";
_i setMarkerType "mil_destroy";

sleep 20;
waitUntil {count (_loc nearEntities [_eventMen, _eventSize*3]) == 0};

sleep 1;
hint "The AA/AT team as been taken out.";
sleep clearTime;
{deleteVehicle _x} forEach _nearAI;
{deleteVehicle _x} forEach _nearObj;
systemChat "event1 objects deleted";

sleep 2;

_i setMarkerType "Empty";

sleep 2;

eventActive = false;