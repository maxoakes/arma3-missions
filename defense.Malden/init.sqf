//apply time and weather settings
setDate [2022, 10, 15, ("Time" call BIS_fnc_getParamValue), 0];
setTimeMultiplier ("TimeScale" call BIS_fnc_getParamValue);
0 setOvercast ("OvercastPercent" call BIS_fnc_getParamValue)/100;
0 setFog ("FogPercent" call BIS_fnc_getParamValue)/100;
0 setRain ("RainPercent" call BIS_fnc_getParamValue)/100;
forceWeatherChange;

//global variables
private _captureZoneSize = ("CaptureZoneSize" call BIS_fnc_getParamValue);
private _missionZoneSize = ("AreaSize" call BIS_fnc_getParamValue);
private _locID = ("StartPosition" call BIS_fnc_getParamValue);
SCO_CURRENT_WAVE = 0;
SCO_ACTIVE_WAVE = false;
SCO_WAVES_STARTED = false;

if (isServer) then
{
	//set up crate and its actions 
	private _centerCrate = missionNamespace getVariable format ["crate_%1", _locID];
	_centerCrate allowDamage false;
	private _startWavesAction = [_centerCrate, [
		"<t color='#ff0000'>Start the game</t>",
		{ missionNamespace setVariable ["SCO_WAVES_STARTED", true, true]; }, nil,
		5, false, true, "", "SCO_CURRENT_WAVE == 0", 5
	]];
	private _addMagAction = [_centerCrate, [
		"<t color='#0000ff'>Add Magazines of Current Weapon</t>",
		{ _this call SCO_fnc_refillWeapon }, 4,
		4, false, true, "", "!SCO_ACTIVE_WAVE and SCO_WAVES_STARTED", 5
	]];
	private _randomWeaponAction = [_centerCrate, [
		"<t color='#ff00ff'>Get a Random Primary Weapon</t>",
		{ _this call SCO_fnc_getRandomWeapon }, 
		["AssaultRifle", "MachineGun", "SniperRifle", "Shotgun", "Rifle", "SubmachineGun"],
		3, false, true, "", "!SCO_ACTIVE_WAVE and SCO_WAVES_STARTED", 5
	]];
	private _healAction = [_centerCrate, [
		"<t color='#ffff00'>Heal Yourself</t>",
		{ (_this select 1) setDamage 0; }, nil,
		3, false, true, "", "!SCO_ACTIVE_WAVE and SCO_WAVES_STARTED", 5
	]];
	private _pingAction = [_centerCrate, [
		"<t color='#00ff00'>Ping for enemy<\t>",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			private _allEast = units east;
			if (count _allEast == 0) then 
			{
				[_caller, "No enemies in the area."] remoteExec ["sideChat"];
			}
			else
			{
				private _nearest = _allEast select 0;
				{
					if ((_caller distance2D _nearest) < (_caller distance2D _x)) then
					{
						_nearest = _x;
					}
				} forEach _allEast;

				private _dir = _caller getDir _nearest;
				private _dist = _caller distance2D _nearest;
				[
					_caller, 
					format ["Closest enemy is approx %1m away to the %2 (%3 deg)", (round (_dist/10)) * 10, [_dir] call SCO_fnc_dirToString, round _dir]
				] remoteExec ["sideChat"];
			};
		}, 
		nil,
		3, false, true, "", "SCO_ACTIVE_WAVE and SCO_WAVES_STARTED", 5
	]];

	_startWavesAction remoteExec ["addAction", 0, true];
	_addMagAction remoteExec ["addAction", 0, true];
	_randomWeaponAction remoteExec ["addAction", 0, true];
	_pingAction remoteExec ["addAction", 0, true];
	_healAction remoteExec ["addAction", 0, true];

	//create playzone markers
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

	//move any AI to the correct play area
	{
		_x setVehiclePosition [getPos _centerCrate, [], 0, "NONE"];
	} forEach units west;

	//create the sector control module
	private _sideLogic = createGroup sideLogic;
	private _module = _sideLogic createUnit ["ModuleSector_F", getPos _centerCrate, [], 0, "CAN_COLLIDE"];
	_module setVariable ["DefaultOwner", "1"];
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
	[west, 2] call BIS_fnc_respawnTickets;

	private _waveSpawner = [_centerCrate, _captureZoneSize, _missionZoneSize, _module] spawn
	{
		params ["_crate", "_captureRadius", "_missionRadius", "_module"];
		private _skill = ("MaxEnemySkill" call BIS_fnc_getParamValue)/10;
		private _squadSize = ("SquadSize") call BIS_fnc_getParamValue;
		private _waveCount = ("WaveCount" call BIS_fnc_getParamValue);
		private _numSquadMultiplier = ("WaveSquadMultiplier" call BIS_fnc_getParamValue)/100;

		private _allOpforUnitClassnames = "
			getNumber (_x >> 'scope') >= 2 && 
			configName _x isKindOf 'Man' && 
			getNumber (_x >> 'side') == 0 &&
			count getArray (_x >> 'weapons') > 2" 
			configClasses (configFile >> "CfgVehicles") apply {(configName _x)};

		"Go to the center crate to start the game." remoteExec ["systemChat", 0];
		waitUntil { SCO_WAVES_STARTED };

		for "_i" from 1 to _waveCount do
		{
			format ["Starting wave %1.", _i] remoteExec ["systemChat", 0];
			SCO_ACTIVE_WAVE = true;
			SCO_CURRENT_WAVE = _i;
			private _numSquads = ceil (_i * _numSquadMultiplier);

			private _waveUnits = [];
			private _waveMarkers = [];
			for "_j" from 1 to _i do
			{
				private _chosenUnitClassname = selectRandom _allOpforUnitClassnames;
				private _chosenUnitName = getText (configFile >> "CfgVehicles" >> _chosenUnitClassname >> "displayName");
				private _safePos = [getPos _crate, _missionRadius, _missionRadius * 1.5, 4, 0, 0.8, 0] call BIS_fnc_findSafePos;

				private _squad = [
					_safePos, east, getPos _crate, 
					_squadSize, [_chosenUnitClassname], 
					[(_skill - 0.1) max 0, (_skill + 0.1) min 1.0]
				] call SCO_fnc_spawnHitSquad;
				_waveUnits append (units _squad);

				private _startMarker = [
					format ["%1-%2", _i, _j], //var name
					_safePos, //position
					"", //display name
					[0.8, 0.8], //size
					"ColorOPFOR", //color string
					"ICON", //type
					"mil_arrow", //style
					_safePos getDir getPos _crate //direction
				] call SCO_fnc_createMarker;
				_waveMarkers pushBack _startMarker;
				systemChat format ["Spawned squad %1-%2 consisting of %3, (%4 units)", _i, _j, _chosenUnitName, count units _squad];
			};

			//wait for the end of the wave
			waitUntil {	sleep 1; ({alive _x} count _waveUnits == 0) or (_module getVariable "owner" == east); };
			{ deleteMarker _x; } forEach _waveMarkers;
			SCO_ACTIVE_WAVE = false;
			if (_module getVariable "owner" == east) exitWith {	};

			//end-of-wave phase
			private _givenTickets = ceil (_i / 3);
			private _sleepTime = round random [15, 30, 40];
			format ["Completed wave %1. Awarding %2 respawn ticket(s). Next wave will start in %3 seconds.", _i, _givenTickets, _sleepTime] remoteExec ["systemChat", 0];
			[west, _givenTickets] call BIS_fnc_respawnTickets;

			sleep _sleepTime;

			//prep for next wave
			{ deleteVehicle _x; } forEach _waveUnits;
			
		};
	};

	private _endMissionChecker = [_module, _waveSpawner] spawn
	{
		params ["_module", "_waveScript"]
		private _waveCount = ("WaveCount" call BIS_fnc_getParamValue);
		while {true} do
		{
			sleep 5;
			private _tickets = [west] call BIS_fnc_respawnTickets;

			if (scriptDone _waveScript and _module getVariable "owner" == west) exitWith
			{			
				"EveryoneWon" call BIS_fnc_endMissionServer;
			};
			if (_tickets == 0 or _module getVariable "owner" == east) exitWith
			{
				"EveryoneLost" call BIS_fnc_endMissionServer;
			};
		};
	};
};
