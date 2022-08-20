params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

private _enableStamina = [("PlayerStamina" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean;
_newUnit enableStamina _enableStamina;
_newUnit execVM "simpleEP.sqf";
