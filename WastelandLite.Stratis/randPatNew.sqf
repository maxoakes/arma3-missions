_spawnMark = getMarkerPos "mainMap";
_spawnMarkRadius = ((getMarkerSize "mainMap") select 0) / 2;
_group = createGroup east;
_loc = [_spawnMark, random _spawnMarkRadius, random 360] call BIS_fnc_relPos;
_locWP = [_spawnMark, random _spawnMarkRadius, random 360] call BIS_fnc_relPos;

while {surfaceIsWater _loc} do 
{
		_loc = [_spawnMark, random _spawnMarkRadius, random 360] call BIS_fnc_relPos;
		sleep 0.2;
};

while {surfaceIsWater _locWP} do 
{
		_locWP = [_spawnMark, random _spawnMarkRadius, random 360] call BIS_fnc_relPos;
		sleep 0.2;
};

_opPool = ["O_G_Soldier_F","O_G_Soldier_lite_F","O_G_Soldier_SL_F","O_G_Soldier_TL_F","O_G_Soldier_AR_F",
			"O_G_medic_F","O_G_engineer_F","O_G_Soldier_exp_F","O_G_Soldier_GL_F","O_G_Soldier_M_F",
			
			"O_G_Soldier_LAT_F","O_G_Soldier_A_F","O_G_officer_F","O_officer_F","O_Soldier_02_F",
			"O_Soldier_F","O_Soldier_lite_F","O_Soldier_GL_F","O_Soldier_AR_F","O_Soldier_SL_F",
			
			"O_Soldier_TL_F","O_soldier_M_F","O_Soldier_LAT_F","O_medic_F","O_soldier_repair_F",
			"O_soldier_exp_F","O_helipilot_F","O_Soldier_A_F","O_Soldier_AT_F","O_Soldier_AA_F",
			
			"O_engineer_F","O_crew_F","O_Pilot_F","O_helicrew_F","O_soldier_PG_F",
			"O_soldier_UAV_F","O_diver_F","O_diver_TL_F","O_diver_exp_F","O_spotter_F",
			
			"O_sniper_F","O_recon_F","O_recon_M_F","O_recon_LAT_F","O_recon_medic_F",
			"O_recon_exp_F","O_recon_JTAC_F","O_recon_TL_F","O_Soldier_AAR_F","O_Soldier_AAT_F",
			
			"O_Soldier_AAA_F","O_support_MG_F","O_support_GMG_F","O_support_Mort_F","O_support_AMG_F",
			"O_support_AMort_F","O_soldierU_F","O_soldierU_AR_F","O_soldierU_AAR_F","O_soldierU_LAT_F",
			
			"O_soldierU_AT_F","O_soldierU_AAT_F","O_soldierU_AA_F","O_soldierU_AAA_F","O_soldierU_TL_F",
			"O_SoldierU_SL_F","O_soldierU_medic_F","O_soldierU_repair_F","O_soldierU_exp_F","O_engineer_U_F",
			"O_soldierU_M_F","O_soldierU_A_F","O_SoldierU_GL_F"];
			
_i = random floor count _opPool;

_unitAI = _group createUnit [(_opPool select _i), _loc, [], 0, "NONE"];
_unitAI setskill .35;
_unitAI doMove _locWP;
_ball = "Sign_Sphere200cm_F" createVehicle (getPos _unitAI);
_ball attachTo [_unitAI, [0, 0, 6]];

_unitAI globalChat (format ["AI unit No. %1 has spawned.", east countSide allUnits]);

while {true} do
{
	waitUntil {_unitAI distance _locWP < 3};
	sleep 1;
	
	_locWP2 = [_spawnMark, random _spawnMarkRadius, random 360] call BIS_fnc_relPos;
	while {surfaceIsWater _locWP2} do 
	{
		_locWP2 = [_spawnMark, random _spawnMarkRadius, random 360] call BIS_fnc_relPos;
	};
	_unitAI doMove _locWP2;
	
	waitUntil {_unitAI distance _locWP2 < 3};
	sleep 1;
	
	while {surfaceIsWater _locWP} do 
	{
		_locWP = [_spawnMark, random _spawnMarkRadius, random 360] call BIS_fnc_relPos;
	};
	_unitAI doMove _locWP;
};