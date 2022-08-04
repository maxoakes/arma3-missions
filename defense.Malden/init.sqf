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
	missionNamespace setVariable ["SCO_WAVES_STARTED", false, true];
	missionNamespace setVariable ["SCO_ACTIVE_WAVE", false, true];
	missionNamespace setVariable ["SCO_CURRENT_WAVE", 0, true];

	//set up crate and its actions 
	private _centerCrate = missionNamespace getVariable format ["crate_%1", _locID];
	_centerCrate allowDamage false;

	//initial action that allows for the game to start
	private _startWavesAction = [_centerCrate, [
		"<t color='#ff0000'>Start the game</t>",
		{ missionNamespace setVariable ["SCO_WAVES_STARTED", true, true]; }, nil,
		5, false, true, "", "SCO_CURRENT_WAVE == 0", 5
	]];

	//action to add mags to the current weapon of the player
	private _addMagAction = [_centerCrate, [
		"<t color='#0000ff'>Add Magazines of Current Weapon</t>",
		{ _this call SCO_fnc_refillWeapon }, 4,
		4, false, true, "", "!SCO_ACTIVE_WAVE and SCO_WAVES_STARTED", 5
	]];

	//action to give a random weapon to the player
	private _randomWeaponAction = [_centerCrate, [
		"<t color='#ff00ff'>Get a Random Primary Weapon</t>",
		{ _this call SCO_fnc_getRandomWeapon }, 
		["AssaultRifle", "MachineGun", "SniperRifle", "Shotgun", "Rifle", "SubmachineGun"],
		3, false, true, "", "!SCO_ACTIVE_WAVE and SCO_WAVES_STARTED", 5
	]];

	//action to heal the player
	private _healAction = [_centerCrate, [
		"<t color='#ffff00'>Heal Yourself</t>",
		{ (_this select 1) setDamage 0; }, nil,
		3, false, true, "", "!SCO_ACTIVE_WAVE and SCO_WAVES_STARTED", 5
	]];

	//action to get the nearest enemies approx distance and dir
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

	//apply those actions to the crate
	_startWavesAction remoteExec ["addAction", 0, true];
	_addMagAction remoteExec ["addAction", 0, true];
	_randomWeaponAction remoteExec ["addAction", 0, true];
	_pingAction remoteExec ["addAction", 0, true];
	_healAction remoteExec ["addAction", 0, true];
	["AmmoboxInit", [
		_centerCrate, true, { 
			(_this distance _target) < 10 and 
			("AllowArsenal" call BIS_fnc_getParamValue) call SCO_fnc_parseBoolean and !SCO_ACTIVE_WAVE
		}]
	] call BIS_fnc_arsenal;

	//clear the crate's cargo
	clearItemCargoGlobal _centerCrate;
	clearBackpackCargoGlobal _centerCrate;
	clearWeaponCargoGlobal _centerCrate;

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

	//create 3D border for capture zone
	[getPos _centerCrate, _captureZoneSize, ["VR_3DSelector_01_default_F"], 6, 0, 3] call SCO_fnc_createBorder;

	//move any AI to the correct play area
	{
		private _pos = [getPos _centerCrate, 2, _captureZoneSize, 2, 0, 0, 0, [], [getPos _centerCrate, getPos _centerCrate]] call BIS_fnc_findSafePos;
		_x setVehiclePosition [_pos, [], 0, "NONE"];
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

	//thread to manage the spawning of the waves
	private _waveSpawner = [_centerCrate, _captureZoneSize, _missionZoneSize, _module] spawn
	{
		params ["_crate", "_captureRadius", "_missionRadius", "_module"];
		private _skill = ("MaxEnemySkill" call BIS_fnc_getParamValue)/10;
		private _squadSize = ("SquadSize") call BIS_fnc_getParamValue;
		private _waveCount = ("WaveCount" call BIS_fnc_getParamValue);
		private _numSquadMultiplier = ("WaveSquadMultiplier" call BIS_fnc_getParamValue)/100;

		//set up pool of possible enemies
		private _allOpforUnitClassnames = "
			getNumber (_x >> 'scope') >= 2 && 
			configName _x isKindOf 'Man' && 
			getNumber (_x >> 'side') == 0 &&
			count getArray (_x >> 'weapons') > 2" 
			configClasses (configFile >> "CfgVehicles") apply {(configName _x)};

		//generate reward pool
		private _weaponAwardPool = [];
		private _equipmentAwardPool = [];
		private _itemAwardPool = [];
		{
			private _itemType = _x call bis_fnc_itemType;
			_itemType params ["_cat", "_type"];
			switch _cat do
			{
				case "Weapon":
				{
					_weaponAwardPool pushBackUnique ([_x] call BIS_fnc_baseWeapon);
				};
				case "Item":
				{				
					_itemAwardPool pushBack _x;
				};
				case "Equipment":
				{
					if (((_type == "Headgear") and 
						(getNumber (configFile >> "CfgWeapons" >> _x >> 'ItemInfo' >> 'HitpointsProtectionInfo' >> 'Head' >> 'armor') > 8)) or 
						((_type == "Vest") and 
						(getNumber (configFile >> "CfgWeapons" >> _x >> 'ItemInfo' >> 'HitpointsProtectionInfo' >> 'Chest' >> 'armor') > 50))) then
					{
						_equipmentAwardPool pushBack _x;
					};				
				};
			};
		} forEach ([["Weapon", "Item", "Equipment", "Object"], ["MachineGun", "SniperRifle", "Rifle", "Throw",
			"AccessoryMuzzle", "AccessorySights", "AccessoryBipod", "FirstAidKit", "Medikit",
			"Headgear", "Vest", "NVGoggles"]] call SCO_fnc_getItemClassnames);

		//wait until someone starts the game
		"Go to the center crate to start the game." remoteExec ["systemChat", 0];
		waitUntil { SCO_WAVES_STARTED };

		//main wave loop
		for "_i" from 1 to _waveCount do
		{
			missionNamespace setVariable ["SCO_ACTIVE_WAVE", true, true];
			missionNamespace setVariable ["SCO_CURRENT_WAVE", _i, true];
			[[format ["<t size='3'>Wave %1 is starting</t>", _i ],"PLAIN DOWN", 5, true, true]] remoteExec ["cutText"];

			private _numSquads = ceil (_i * _numSquadMultiplier);
			private _waveUnits = [];
			private _waveMarkers = [];

			//generate enemies and spawn them
			for "_j" from 1 to _i do
			{
				//pick the unit type and squad spawn position
				private _chosenUnitClassname = selectRandom _allOpforUnitClassnames;
				private _chosenUnitName = getText (configFile >> "CfgVehicles" >> _chosenUnitClassname >> "displayName");
				private _safePos = [getPos _crate, _missionRadius, _missionRadius * 1.5, 4, 0, 0.8, 0] call BIS_fnc_findSafePos;

				//spawn them
				private _squad = [
					_safePos, east, getPos _crate, 
					_squadSize, [_chosenUnitClassname], 
					[(_skill - 0.1) max 0, (_skill + 0.1) min 1.0]
				] call SCO_fnc_spawnHitSquad;
				_waveUnits append (units _squad);

				//place their origin marker
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

			//remove any text on screen
			sleep 8;
			[["","PLAIN DOWN", 5, true, true]] remoteExec ["cutText"];

			//wait until the enemies are dead or the zone has been captured
			waitUntil {	sleep 1; ({alive _x} count _waveUnits == 0) or (_module getVariable "owner" == east); };

			//end-of-wave phase
			{ deleteMarker _x; } forEach _waveMarkers;
			missionNamespace setVariable ["SCO_ACTIVE_WAVE", false, true];

			//check if there is a win or loss condition met
			if (_module getVariable "owner" == east or _i == _waveCount) exitWith { systemChat "End condition met." };

			private _givenTickets = ceil (_numSquads / 2) + (count (allDead arrayIntersect allPlayers));
			private _sleepTime = round random [30, 45, 60];

			//Wave award message message
			[[format [
					"<t size='2'>Completed wave %1.<br/>Awarding %2 respawn ticket(s).<br/>Next wave will start in %3 seconds.</t>",
					_i, _givenTickets, _sleepTime], 
				"PLAIN DOWN", -1, true, true
			]] remoteExec ["cutText"];

			//add item awards to the center crate
			for "_j" from 1 to ((count allPlayers) * 2) do
			{
				private _categorizedPool = [_weaponAwardPool, _equipmentAwardPool, _itemAwardPool];
				private _selectedCategory = selectRandom _categorizedPool;
				private _selectedAward = selectRandom _selectedCategory;
				if ((_selectedAward call BIS_fnc_itemType select 0) == "Weapon") then
				{
					_crate addWeaponCargoGlobal [_selectedAward, 1];
				}
				else
				{
					_crate addItemCargoGlobal [_selectedAward, 1];
				};
			};

			//award respawn tickets
			[west, _givenTickets] call BIS_fnc_respawnTickets;

			//text transition
			sleep 8;
			[["","PLAIN DOWN", 5, true, true]] remoteExec ["cutText"];
			sleep (_sleepTime - 11);
			[["<t size='3' color='#ff0000'>3</t>","PLAIN DOWN", 5, true, true]] remoteExec ["cutText"];
			sleep 1;
			[["<t size='3' color='#ff0000'>2</t>","PLAIN DOWN", 5, true, true]] remoteExec ["cutText"];
			sleep 1;
			[["<t size='3' color='#ff0000'>1</t>","PLAIN DOWN", 5, true, true]] remoteExec ["cutText"];
			sleep 1;

			//prep for next wave
			{ deleteVehicle _x; } forEach _waveUnits;
		};
	};

	private _endMissionChecker = [_module, _waveSpawner] spawn
	{
		params ["_module", "_waveScript"];
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
