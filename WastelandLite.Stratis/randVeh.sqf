_spawnMark = getMarkerPos "mainMap";
_spawnMarkRadius = ((getMarkerSize "mainMap") select 0) / 2;

_loc = [_spawnMark, random _spawnMarkRadius, random 360] call BIS_fnc_relPos;

//while {(surfaceIsWater _loc) || (count (_loc nearObjects 5) == 0)} do
while {(surfaceIsWater _loc)} do 
{
	_loc = [_spawnMark, random _spawnMarkRadius, random 360] call BIS_fnc_relPos;
	sleep 0.2;
};

_landVehPool = ["O_Quadbike_01_F","O_G_Quadbike_01_F","I_Quadbike_01_F","I_G_Quadbike_01_F","B_Quadbike_01_F",
				"B_G_Quadbike_01_F","B_Truck_01_mover_F","B_Truck_01_box_F","B_Truck_01_ammo_F","B_Truck_01_fuel_F",
				
				"B_Truck_01_repair_F","O_Truck_03_ammo_F","O_Truck_03_fuel_F","O_Truck_03_repair_F","O_Truck_03_device_F",
				"I_Truck_02_ammo_F","I_Truck_02_fuel_F","I_Truck_02_repair_F","O_Truck_02_ammo_F","O_Truck_02_fuel_F",
				
				"O_Truck_02_box_F","C_Van_01_box_F","C_Van_01_fuel_F","B_G_Van_01_fuel_F",
				"C_SUV_01_F","C_Hatchback_01_F","C_Hatchback_01_sport_F","C_Offroad_01_F","B_G_Offroad_01_F",
				
				"B_MRAP_01_F","O_MRAP_02_F","C_Van_01_transport_F","B_G_Van_01_transport_F","O_Truck_03_medical_F","O_Truck_03_transport_F",
				"O_Truck_03_covered_F","I_Truck_02_covered_F","I_Truck_02_transport_F","O_Truck_02_covered_F","O_Truck_02_transport_F",
				
				"O_Truck_02_medical_F","B_Truck_01_medical_F","B_Truck_01_covered_F","B_Truck_01_transport_F","I_MRAP_03_F",
				"B_G_Offroad_01_armed_F","B_MRAP_01_hmg_F","O_MRAP_02_hmg_F","I_MRAP_03_hmg_F","B_MRAP_01_gmg_F",
				"O_MRAP_02_gmg_F","I_MRAP_03_gmg_F",
				
				"C_SUV_01_F","C_Hatchback_01_F","C_Hatchback_01_sport_F","C_Offroad_01_F","O_Quadbike_01_F",
				"O_G_Quadbike_01_F","I_Quadbike_01_F","I_G_Quadbike_01_F","B_Quadbike_01_F","B_G_Quadbike_01_F",
				
				"C_SUV_01_F","C_Hatchback_01_F","C_Hatchback_01_sport_F","C_Offroad_01_F","O_Quadbike_01_F",
				"O_G_Quadbike_01_F","I_Quadbike_01_F","I_G_Quadbike_01_F","B_Quadbike_01_F","B_G_Quadbike_01_F",
				
				"C_SUV_01_F","C_Hatchback_01_F","C_Hatchback_01_sport_F","C_Offroad_01_F","O_Quadbike_01_F",
				"O_G_Quadbike_01_F","I_Quadbike_01_F","I_G_Quadbike_01_F","B_Quadbike_01_F","B_G_Quadbike_01_F",
				
				"C_SUV_01_F","C_Hatchback_01_F","C_Hatchback_01_sport_F","C_Offroad_01_F","O_Quadbike_01_F",
				"O_G_Quadbike_01_F","I_Quadbike_01_F","I_G_Quadbike_01_F","B_Quadbike_01_F","B_G_Quadbike_01_F"];

_weaponPool = ["srifle_EBR_F","srifle_GM6_F","srifle_LRR_F","LMG_Mk200_F","hgun_P07_F",
			"hgun_Rook40_F","arifle_Katiba_F","arifle_Katiba_C_F","arifle_Katiba_GL_F","arifle_MXC_F",
			
			"arifle_MX_F","arifle_MX_GL_F","arifle_MX_SW_F","arifle_MXM_F","arifle_MX_GL_ACO_F",
			"arifle_SDAR_F","arifle_TRG21_F","arifle_TRG20_F","arifle_TRG21_GL_F","LMG_Zafir_F",
			
			"hgun_ACPC2_F","arifle_Mk20_F","arifle_Mk20_plain_F","arifle_Mk20C_F","arifle_Mk20C_plain_F",
			"arifle_Mk20_GL_F","arifle_Mk20_GL_plain_F","SMG_01_F","SMG_02_F","srifle_DMR_01_F",
			
			"hgun_Pistol_heavy_01_F","hgun_Pistol_heavy_02_F","arifle_MXC_Black_F","arifle_MX_Black_F","arifle_MX_GL_Black_F",
			"arifle_MX_SW_Black_F","arifle_MXM_Black_F","hgun_PDW2000_F"];
			
			
_ammoPool = ["20Rnd_762x51_Mag","5Rnd_127x108_Mag","7Rnd_408_Mag","200Rnd_65x39_cased_Box","16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_mag",
			
			"30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","100Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag",
			"20Rnd_556x45_UW_mag","30Rnd_556x45_Stanag","30Rnd_556x45_Stanag","30Rnd_556x45_Stanag","150Rnd_762x51_Box",
			
			"9Rnd_45ACP_Mag","30Rnd_556x45_Stanag","30Rnd_556x45_Stanag","30Rnd_556x45_Stanag","30Rnd_556x45_Stanag",
			"30Rnd_556x45_Stanag","30Rnd_556x45_Stanag","30Rnd_45ACP_Mag_SMG_01","30Rnd_9x21_Mag","10Rnd_762x51_Mag",
			
			"11Rnd_45ACP_Mag","6Rnd_45ACP_Cylinder","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag",
			"100Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_9x21_Mag"];
			
_atPool = ["muzzle_snds_H","muzzle_snds_L","muzzle_snds_M","muzzle_snds_B","muzzle_snds_H_MG",
			"optic_Arco","optic_Hamr","optic_Aco","optic_ACO_grn","optic_Aco_smg",
			
			"optic_ACO_grn_smg","optic_Holosight","optic_Holosight_smg","optic_SOS","acc_flashlight",
			"acc_pointer_IR","optic_MRCO","muzzle_snds_acp","optic_DMS","optic_Yorris",
			
			"optic_MRD","optic_LRPS","optic_NVS","optic_Nightstalker","optic_tws",
			"optic_tws_mg"];
			
_equipPool = ["ItemGPS","Binocular","Rangefinder","NVGoggles","FirstAidKit",
			"Medikit","ToolKit","Laserdesignator",
			
			"HandGrenade_Stone","HandGrenade","MiniGrenade","SmokeShell","SmokeShellYellow",
			"SmokeShellGreen","SmokeShellRed","SmokeShellPurple","SmokeShellOrange","SmokeShellBlue",
			
			"Chemlight_green","Chemlight_red","Chemlight_yellow","Chemlight_blue","B_IR_Grenade",
			"O_IR_Grenade","I_IR_Grenade","DemoCharge_Remote_Mag","SatchelCharge_Remote_Mag","ATMine_Range_Mag",
			
			"ClaymoreDirectionalMine_Remote_Mag","APERSMine_Range_Mag","APERSBoundingMine_Range_Mag","SLAMDirectionalMine_Wire_Mag",
			"APERSTripMine_Wire_Mag"];
			
_i = random floor count _landVehPool;
_j = random floor count _weaponPool;
_k = random floor count _atPool;
_l = random floor count _equipPool;
_m = random floor count _equipPool;

_veh = createVehicle [(_landVehPool select _i), _loc, [], 0, "NONE"];
_veh setDir random 360;

clearWeaponCargo _veh;
clearMagazineCargo _veh;
clearItemCargo _veh;

_veh addWeaponCargoGlobal[_weaponPool select _j, 1];
_veh addMagazineCargoGlobal[_ammoPool select _j, 1];
_veh addMagazineCargoGlobal[_ammoPool select _j, 1];
_veh addMagazineCargoGlobal[_ammoPool select _j, 1];
_veh addItemCargoGlobal[_atPool select _k, 1];
_veh addItemCargoGlobal[_equipPool select _l, 1];
_veh addItemCargoGlobal[_equipPool select _m, 1];

_ball = "Sign_Sphere200cm_F" createVehicle (getPos _veh);
_ball attachTo [_veh, [0, 0, 6]];

systemChat (format ["Vehicle No. %1 has spawned.", (count vehicles)]);
