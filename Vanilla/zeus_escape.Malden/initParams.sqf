//set weather conditions, settings based on parameters
setDate [2018, 4, 2, ("Time" call BIS_fnc_getParamValue), 30];
0 setFog ("Fog" call BIS_fnc_getParamValue)/100;
0 setOvercast ("Clouds" call BIS_fnc_getParamValue)/100;
0 setRain ("Rain" call BIS_fnc_getParamValue)/100;

if (rain > 0.5) then {0 setLightnings rain};
forceWeatherChange;

COST_MULT = ("CostMultiplier" call BIS_fnc_getParamValue)/100;
AIRDROP_TIME = "TimeDrop" call BIS_fnc_getParamValue;
KILL_REWARD = ("RewardKill" call BIS_fnc_getParamValue)/1000;
HIT_REWARD = ("RewardHit" call BIS_fnc_getParamValue)/1000;
DEATH_REWARD = ("RewardDeath" call BIS_fnc_getParamValue)/1000;
ENEMY_CAP = "AmountEnemyCapture" call BIS_fnc_getParamValue;