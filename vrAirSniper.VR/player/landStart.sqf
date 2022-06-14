_unit = _this;

_weapons = ["arifle_MXC_Holo_F",
			"arifle_Katiba_C_ACO_pointer_F",
			"arifle_MXC_Holo_pointer_F",
			
			"SMG_01_Holo_pointer_F",
			"hgun_PDW2000_F",
			"hgun_PDW2000_Holo_F",
			"srifle_EBR_ARCO_pointer_F"
			];
			
_magazines = ["30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_mag",
			
			"30Rnd_45ACP_Mag_SMG_01",
			"30Rnd_9x21_Mag",
			"30Rnd_9x21_Mag",
			"20Rnd_762x51_Mag"
			];

_i = random floor count _weapons;

_tank = ["B_MRAP_01_gmg_F",
		"I_MRAP_03_gmg_F",
		"O_MRAP_02_gmg_F",
		"B_MRAP_01_hmg_F",
		"I_MRAP_03_hmg_F",
		"O_MRAP_02_hmg_F",
		"I_G_Offroad_01_armed_F",
		"B_MBT_01_mlrs_F"
		];

_j = random floor count _tank;

removeAllWeapons _unit;
removeAllItems _unit;
_unit enableFatigue false;
_unit addWeapon (_weapons select _i);
_unit selectWeapon (_weapons select _i);
_unit addMagazine (_magazines select _i);
_unit addMagazine (_magazines select _i);

_unit addWeapon "hgun_P07_snds_F";
_unit addMagazine "16Rnd_9x21_Mag";

_veh = createVehicle [(_tank select _j), position _unit, [], 0, "NONE"];
_unit moveInDriver _veh;