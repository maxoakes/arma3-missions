params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

_newUnit enableFatigue ([("PlayerStamina" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean);