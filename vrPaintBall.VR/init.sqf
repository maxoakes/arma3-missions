titleCut ["", "BLACK FADED", 999];
[] Spawn {
waitUntil{!(isNil "BIS_fnc_init")};

titleText ["Welcome to [CKW] Scouter's Virtual Reality Paintball!\n
			\n
			Go to the object in the center of the spawn to chose your gun.\n
			You will be teleported to your side of the arena with that gun.\n","PLAIN"]; 
titleFadeOut 7;
sleep 9;

sleep 1;
"dynamicBlur" ppEffectEnable true;   
"dynamicBlur" ppEffectAdjust [6];   
"dynamicBlur" ppEffectCommit 0;     
"dynamicBlur" ppEffectAdjust [0.0];  
"dynamicBlur" ppEffectCommit 2;  

titleCut ["", "BLACK IN", 3];
};

waitUntil{!(isNil "BIS_fnc_init")};