params ["_blacklistedPos", "_possibleClassnames", ["_skillRange", [0.3, 0.5]]];
systemChat "Starting nearby foot patrol manager.";

while {true} do 
{
	//get the list of players that are not in a safe zone, like the spawn
	private _possibleTargets = [];
	{
		if (_x distance2D _blacklistedPos > 200 and alive _x) then
		{
			_possibleTargets pushBack _x;
		}
	} forEach allPlayers;
	//pick a spawn position in a player's path
	private _player = selectRandom _possibleTargets;

	if (count _possibleTargets == 0) then { continue; };
	systemChat format ["Spawning foot patrol targeting", name _player];

	private _waypointPosition = _player getPos [100, getDir _player];
	private _playerDestinationDir = (_player getDir taskDestination (currentTask _player)) + 360;
	private _playerLookingDir = getDir _player + 360;
	private _spawnCenterPos = _player getPos [800, [_playerDestinationDir, _playerLookingDir] call BIS_fnc_arithmeticMean];
	private _blacklistedAreas = [];
	{
		_blacklistedAreas pushBack ([getPos _x, 500]);
	} forEach allPlayers;

	systemChat format ["Target: %1, LookDir: %2, DestDir: %3, SelectedPos: %4", name _player, _playerDestinationDir, _playerLookingDir, mapGridPosition _spawnCenterPos];
	private _spawnPos = [_spawnCenterPos, 0, 500, 4, 0, 20, 0, _blacklistedAreas, [[0,0,0], [0,0,0]]] call BIS_fnc_findSafePos;
	if ((_spawnPos select 0) == 0 and (_spawnPos select 1) == 0) then
	{
		systemChat "Failed to find suitable targeted foot patrol spawn location.";
		continue;
	};

	//spawn the squad
	private _squad = [_spawnPos, east, _waypointPosition, 4, _possibleClassnames, _skillRange, "AWARE", "RED", "LINE"] call SCO_fnc_spawnHitSquad;
	_squad setGroupIdGlobal [format ["Targeted Foot Patrol %1", ({side _x == east} count allGroups)]];

	while {{(alive _x) and (_x distance2D _player < 2000)} count units _squad > 0} do
	{
		if ([("Debug" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean) then
		{
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
				[500, 500], //size
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

		waitUntil {{ _x distance2D _waypointPosition < 25 } count units _squad > 0};
		_waypointPosition = getPos _player;
		systemChat "Foot patrol waypoint updated";
	};
	sleep 5;
	systemChat "End of foot patrol loop";
};


