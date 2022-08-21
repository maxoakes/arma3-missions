params ["_blacklistedPos", "_possibleClassnames", ["_skillRange", [0.3, 0.5]]];
["Starting nearby foot patrol manager."] call SCO_fnc_printDebug;

while {true} do 
{
	private _despawnDistance = 1500;
	//pick a player that is not in a safe zone
	private _possibleTargets = [];
	{
		if (_x distance2D _blacklistedPos > 200 and alive _x) then
		{
			_possibleTargets pushBack _x;
		};
	} forEach allPlayers;
	private _player = selectRandom _possibleTargets;

	if (count _possibleTargets == 0) then { continue; };
	[format ["Spawning foot patrol targeting %1", name _player]] call SCO_fnc_printDebug;

	//pick a spawn position that is roughly on the path with the player to the objective
	//halfway between the player's looking dir and the dir to the objective
	private _playerDestinationDir = (_player getDir taskDestination (currentTask _player));
	private _playerLookingDir = getDir _player;
	private _dirDiff = abs (_playerDestinationDir - _playerLookingDir);
	private _dirMid = [_playerDestinationDir, _playerLookingDir] call BIS_fnc_arithmeticMean;
	if (_dirDiff > 180) then
	{
		_dirMid = ((360 - _dirDiff)/2) + ([_playerDestinationDir, _playerLookingDir] call BIS_fnc_greatestNum);
	};
	
	//pick a spawn position that is safe to spawn enemeies that is not too close to players
	private _spawnCenterPos = _player getPos [600, _dirMid];
	private _blacklistedAreas = [];
	{
		_blacklistedAreas pushBack ([getPos _x, 500]);
	} forEach allPlayers;

	[format ["Target: %1, LookDir: %2, DestDir: %3, MidDir: %4, SelectedPos: %5", name _player, _playerDestinationDir, _playerLookingDir, _dirMid, mapGridPosition _spawnCenterPos]] call SCO_fnc_printDebug;
	private _spawnPos = [_spawnCenterPos, 0, 200, 4, 0, 20, 0, _blacklistedAreas, [[0,0,0], [0,0,0]]] call BIS_fnc_findSafePos;
	if ((_spawnPos select 0) == 0 and (_spawnPos select 1) == 0) then
	{
		["Failed to find suitable targeted foot patrol spawn location."] call SCO_fnc_printDebug;
		sleep 1;
		continue;
	};

	//spawn the squad and pick the initial waypoint
	private _waypointPosition = _player getPos [100, _playerLookingDir];
	if (surfaceIsWater _waypointPosition) then
	{
		_waypointPosition = getPos _player;
	};
	private _squad = [_spawnPos, east, _waypointPosition, 4, _possibleClassnames, _skillRange, "AWARE", "RED", "LINE"] call SCO_fnc_spawnHitSquad;
	_squad setGroupIdGlobal [format ["Targeted Foot Patrol %1", ({side _x == east} count allGroups)]];

	while {true} do
	{
		private _currentWaypoint = [_squad, currentWaypoint _squad];
		_currentWaypoint setWaypointCompletionRadius 25;
		if ([("Debug" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean) then
		{
			deleteMarker "fps";
			deleteMarker "fpsp";
			deleteMarker "fpsr";
			deleteMarker "fpo";
			[
				"fps", //var name
				_spawnPos, //position
				"Spawn", //display name
				[0.5, 0.5], //size
				"ColorOrange", //color string
				"ICON", //type
				"mil_join" //style
			] call SCO_fnc_createMarker;

			[
				"fpsp", //var name
				_spawnCenterPos, //position
				"Spawn Center", //display name
				[0.5, 0.5], //size
				"ColorOrange", //color string
				"ICON", //type
				"hd_start" //style
			] call SCO_fnc_createMarker;

			[
				"fpsr", //var name
				_spawnCenterPos, //position
				"", //display name
				[200, 200], //size
				"ColorOrange", //color string
				"ELLIPSE", //type
				"Border" //style
			] call SCO_fnc_createMarker;

			[
				"fpo", //var name
				_waypointPosition, //position
				"Target", //display name
				[0.5, 0.5], //size
				"ColorOrange", //color string
				"ICON", //type
				"mil_objective" //style
			] call SCO_fnc_createMarker;
		};

		[format ["Current waypoint is %1", _currentWaypoint]] call SCO_fnc_printDebug;
		waitUntil {
			({_x distance2D waypointPosition _currentWaypoint < 20 } count units _squad > 0) or 
			({(alive _x) and (_x distance2D _player < _despawnDistance)} count units _squad == 0)
		};
		if ({(alive _x) and (_x distance2D _player < _despawnDistance)} count units _squad == 0) then
		{
			break;
		};
		
		//pick the nearest active player from that previous waypoint
		private _sortedPlayers = [allPlayers, [waypointPosition _currentWaypoint], { _input0 distance2D _x }, "ASCEND"] call BIS_fnc_sortBy;
		if (count _sortedPlayers == 0) then
		{
			_squad deleteGroupWhenEmpty true;
			{
				deleteVehicle _x;
			} forEach units _squad;
			break;
		};
		_player = selectRandom _sortedPlayers;

		//reset the waypoint
		deleteWaypoint _currentWaypoint;
		_squad addWaypoint [getPos _player, 0];
		["Foot patrol waypoint updated"] call SCO_fnc_printDebug;
	};

	//only delete the units if they are still alive.
	//If we get here, the units are out of range from a player or the units are dead
	_squad deleteGroupWhenEmpty true;
	{
		if (alive _x) then
		{
			deleteVehicle _x;
		};
	} forEach units _squad;
	["End of foot patrol loop"] call SCO_fnc_printDebug;
	sleep 5;
};


