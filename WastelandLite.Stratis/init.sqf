titleCut ["", "BLACK FADED", 999];
[] Spawn
{
	waitUntil{!(isNil "BIS_fnc_init")};

	titleText ["Welcome to Wasteland Lite by Scouter!","PLAIN DOWN"]; 
	titleFadeOut 12;
	sleep 2;

	titleText ["There are random patrolling AI.\n
				There will be a constant amount of them.\n
				When you kill one, another will spawn.\n
				Report bugs and suggestions to Scouter or another admin.\n
				Teamspeak 3 IP: ts.ckwgaming.com\n
				Have fun.","PLAIN"];
	titleFadeOut 4;
	sleep 10;
	
	"dynamicBlur" ppEffectEnable true;   
	"dynamicBlur" ppEffectAdjust [6];   
	"dynamicBlur" ppEffectCommit 0;     
	"dynamicBlur" ppEffectAdjust [0.0];  
	"dynamicBlur" ppEffectCommit 2;  

	titleCut ["", "BLACK IN", 3];
};

waitUntil{!(isNil "BIS_fnc_init")};

sleep 2;
[] execVM "randPatSpawnNew.sqf";
sleep 2;
[] execVM "randVehSpawn.sqf";
sleep 2;
[] execVM "events\eventLoop.sqf";