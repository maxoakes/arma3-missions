_exp = allMissionObjects "I_supplyCrate_F";
_gun = allMissionObjects "Box_FIA_Wps_F";

while {true} do {
	{ _x execVM "crates\guns.sqf"; } forEach _gun;
	{ _x execVM "crates\explosives.sqf"; } forEach _exp;
	sleep 600;
};