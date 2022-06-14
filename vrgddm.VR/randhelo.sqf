_spawnMark = getMarkerPos "mainMap";
_spawnMarkRadius = ((getMarkerSize "mainMap") select 0);

_loc = [_spawnMark, random _spawnMarkRadius, random 360] call BIS_fnc_relPos;

//while {(surfaceIsWater _loc) || (count (_loc nearObjects 5) == 0)} do
while {(surfaceIsWater _loc)} do 
{
	_loc = [_spawnMark, random _spawnMarkRadius, random 360] call BIS_fnc_relPos;
	sleep 0.2;
};

_airVehPool = ["B_Heli_Light_01_F","B_Heli_Light_01_armed_F","B_Heli_Attack_01_F",
				"B_Heli_Transport_01_F","B_Heli_Transport_01_camo_F","B_Heli_Transport_03_black_F",
				"O_Heli_Light_02_F","O_Heli_Light_02_v2_F","O_Heli_Attack_02_F","O_Heli_Attack_02_black_F",
				"I_Heli_light_03_F","C_Heli_Light_01_civil_F"];

_weaponPool = ["launch_NLAW_F","launch_RPG32_F","launch_I_Titan_F","launch_I_Titan_short_F"];
			
_ammoPool = ["NLAW_F","RPG32_F","Titan_AA","Titan_AT"];
			
_equipPool = ["ItemGPS","Binocular","Rangefinder","NVGoggles","FirstAidKit",
			"Medikit","ToolKit","Laserdesignator",
			
			"HandGrenade_Stone","HandGrenade","MiniGrenade","SmokeShell","SmokeShellYellow",
			"SmokeShellGreen","SmokeShellRed","SmokeShellPurple","SmokeShellOrange","SmokeShellBlue",
			
			"Chemlight_green","Chemlight_red","Chemlight_yellow","Chemlight_blue","B_IR_Grenade",
			"O_IR_Grenade","I_IR_Grenade","DemoCharge_Remote_Mag","SatchelCharge_Remote_Mag","ATMine_Range_Mag",
			
			"ClaymoreDirectionalMine_Remote_Mag","APERSMine_Range_Mag","APERSBoundingMine_Range_Mag","SLAMDirectionalMine_Wire_Mag",
			"APERSTripMine_Wire_Mag"];
			
_i = random floor count _airVehPool;
_j = random floor count _weaponPool;
_l = random floor count _equipPool;
_m = random floor count _equipPool;

_veh = createVehicle [(_airVehPool select _i), _loc, [], 0, "NONE"];
_veh setDir random 360;

clearWeaponCargo _veh;
clearMagazineCargo _veh;
clearItemCargo _veh;

_veh addWeaponCargoGlobal[_weaponPool select _j, 1];
_veh addMagazineCargoGlobal[_ammoPool select _j, 1];
_veh addMagazineCargoGlobal[_ammoPool select _j, 1];
_veh addItemCargoGlobal[_equipPool select _l, 1];
_veh addItemCargoGlobal[_equipPool select _m, 1];

_ball = "Sign_Sphere200cm_F" createVehicle (getPos _veh);
_ball attachTo [_veh, [0, 0, 6]];

systemChat (format ["Helo spawned %1.", time]);

sleep 5;

waitUntil{(damage _veh) > .9};

sleep 10;

deleteVehicle _veh;
deleteVehicle _ball;
systemChat "Helocopter deleted";