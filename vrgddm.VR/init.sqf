/*
titleCut ["", "BLACK FADED", 999];
[] Spawn
{
	waitUntil{!(isNil "BIS_fnc_init")};

	titleText ["Welcome to Gun Drop Deathmatch by Scouter!","PLAIN DOWN"]; 
	titleFadeOut 12;
	sleep 2;

	titleText ["Weapons will randomly spawn throughout the playing area.\n
				Once a weapon is picked up, you have 10 seconds to get the items with it\n
				Vehicles may also appear.\n
				Report bugs and suggestions to Scouter or another admin.\n
				Teamspeak 3 IP: ts.ckwgaming.com\n
				Have fun.","PLAIN"];
	titleFadeOut 8;
	sleep 12;
	
	"dynamicBlur" ppEffectEnable true;   
	"dynamicBlur" ppEffectAdjust [6];   
	"dynamicBlur" ppEffectCommit 0;     
	"dynamicBlur" ppEffectAdjust [0.0];  
	"dynamicBlur" ppEffectCommit 2;  

	titleCut ["", "BLACK IN", 3];
};

waitUntil{!(isNil "BIS_fnc_init")};
*/
sleep 2;
[] execVM "randGunSpawn.sqf";
[] execVM "randVehSpawn.sqf";
[] execVM "randHeloSpawn.sqf";