//apply time and weather settings
setDate [2022, 10, 15, ("Time" call BIS_fnc_getParamValue), 0];
setTimeMultiplier ("TimeScale" call BIS_fnc_getParamValue);
0 setOvercast ("OvercastPercent" call BIS_fnc_getParamValue)/100;
0 setFog ("FogPercent" call BIS_fnc_getParamValue)/100;
0 setRain ("RainPercent" call BIS_fnc_getParamValue)/100;
forceWeatherChange;

//global variables
private _skill = ("MaxEnemySkill" call BIS_fnc_getParamValue)/10;
private _captureZoneSize = ("CaptureZoneSize" call BIS_fnc_getParamValue);
private _missionZoneSize = ("AreaSize" call BIS_fnc_getParamValue);
private _waveCount = ("WaveCount" call BIS_fnc_getParamValue);
private _numUnitsMultiplier = ("WaveUnitMultiplier" call BIS_fnc_getParamValue)/100;

private _locID = ("StartPosition" call BIS_fnc_getParamValue);
if (_locID == -1) then
{
	_locID = 0;
};

if (isServer) then
{
	//create playzone markers
	private _centerCrate = missionNamespace getVariable format ["crate_%1", _locID];
	private _respawnMarker = [
		"respawn_west", //var name
		getPos _centerCrate, //position
		"", //display name
		[_captureZoneSize, _captureZoneSize], //size
		"ColorBLUFOR", //color string
		"ELLIPSE", //type
		"SolidBorder", 0, 0.5 //style
	] call SCO_fnc_createMarker;

	private _respawnMarker = [
		"missionZone", //var name
		getPos _centerCrate, //position
		"", //display name
		[_missionZoneSize, _missionZoneSize], //size
		"ColorOPFOR", //color string
		"ELLIPSE", //type
		"Border" //style
	] call SCO_fnc_createMarker;

	//create the sector control module
	private _sideLogic = createGroup sideLogic;
	private _module = _sideLogic createUnit ["ModuleSector_F", getPos _centerCrate, [], 0, "CAN_COLLIDE"];
	_module setVariable ["DefaultOwner", "-1"];
	_module setVariable ["Name", "Defense"];
	_module setVariable ["Designation", ""];
	_module setVariable ["CaptureCoef", "0.2"];
	_module setVariable ["OnOwnerChange", ""];
	_module setVariable ["OwnerLimit", 1];
	_module setVariable ["TaskTitle", "Wave Defense"];
	_module setVariable ["TaskDescription", "Defend %1 from multiple waves of OPFOR."];
	_module setVariable ["TaskOwner", 1];
	_module setVariable ["sides", [east, west]];
	_module setvariable ["BIS_fnc_initModules_disableAutoActivation", false];
	_module setVariable ["size", _captureZoneSize];
	_module call BIS_fnc_moduleSector;

	waitUntil {!isNil {_module getVariable "finalized"} && {!(_module getVariable "finalized")}};

	//hide the area marker that came with the sector since the size is innaccurate
	{
		private _marker = (_x getVariable "markers") select 0;
		if (markerShape _marker == "ELLIPSE") then
		{
			_marker setMarkerAlpha 0;
		};
	} forEach (_module getVariable "areas");

	//set up tickets
	[west, 4] call BIS_fnc_respawnTickets;
};
