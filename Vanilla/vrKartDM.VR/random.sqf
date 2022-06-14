_veh = _this;

_weapons = ["LMG_Minigun",
			"LMG_RCWS",
			"LMG_M200",
			"LMG_Minigun_heli",
			
			"HMG_127",
			"HMG_127_APC",
			"HMG_01",
			"HMG_NSVT",
			
			"M134_minigun",
			"GMG_20mm",
			
			"GMG_40mm",
			"autocannon_40mm_CTWS",
			"gatling_20mm",
			"gatling_30mm",
			
			"LMG_Minigun_Transport",
			
			"cannon_120mm",
			"gatling_25mm",
			"autocannon_35mm"
			];
			
_magazines = ["200Rnd_65x39_Belt",
			"200Rnd_65x39_Belt",
			"200Rnd_65x39_Belt",
			"200Rnd_65x39_Belt",
			
			"500Rnd_127x99_mag",
			"500Rnd_127x99_mag",
			"500Rnd_127x99_mag",
			"450Rnd_127x108_Ball",
			
			"5000Rnd_762x51_Belt",
			"200Rnd_20mm_G_belt",
			
			"200Rnd_40mm_G_belt",
			"60Rnd_40mm_GPR_shells",
			"2000Rnd_20mm_shells",
			"250Rnd_30mm_HE_shells",
			
			"1000Rnd_65x39_Belt",
			
			"32Rnd_120mm_APFSDS_shells",
			"1000Rnd_25mm_shells",
			"680Rnd_35mm_AA_shells"
			];

_i = random floor count _weapons;

removeAllWeapons _veh;

_veh addMagazine (_magazines select _i);
_veh addMagazine (_magazines select _i);
_veh addMagazine (_magazines select _i);
_veh addMagazine (_magazines select _i);
_veh addMagazine (_magazines select _i);
_veh addMagazine (_magazines select _i);
_veh addMagazine (_magazines select _i);
_veh addMagazine (_magazines select _i);
_veh addMagazine (_magazines select _i);
_veh addMagazine (_magazines select _i);

_veh addWeapon (_weapons select _i);
_veh selectWeapon (_weapons select _i);
(driver _veh) globalChat format ["I have %1 equipped!", _weapons select _i ];