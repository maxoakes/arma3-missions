params ["_target", "_caller", "_actionId", "_p"];
_p params ["_loc", "_radius", "_returnMarker"];

private _pos = [getPos _loc, 0, 100, 5, 0, SCO_MAX_GRADIENT, 0] call BIS_fnc_findSafePos;
private _center = getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition");

if ((_center select 0 == _pos select 0) and (_center select 1 == _pos select 1)) exitWith
{
	systemChat format ["Not able to find an available location. Cancelling. %1==%2.", _center, _pos];
};

//a location was found
hint format ["Teleporting to %1.", text _loc];

//create the battleground manager object
private _spawn = createVehicle ["Land_PhoneBooth_01_F", _pos, [], 0, "CAN_COLLIDE"];
_spawn setVectorUp [0,0,1];
_spawn allowDamage false;

//create the markers for the battleground area
private _randomName = format ["%1",floor random 999999];

private _markerBorder = [format ["c%1", _this select 1], _pos, "", [_radius, _radius], "ColorBlack", "ELLIPSE", "SolidFull", 0, 0.25] call SCO_fnc_createMarker;
private _markerCenter = [format ["x%1", _randomName], _pos, format ["%1's Battleground", name _caller], [1, 1], "ColorBlue", "ICON", "mil_flag"] call SCO_fnc_createMarker;

//teleport the player
player setPos [(_pos select 0), (_pos select 1)-2];

//create the actions on the battleground manager to spawn enemy waves
private _baseAction = [
	"<t color='#00ff00'>Return to spawn and delete battleground</t>",
	{ removeAllActions (_this select 0) },
	"", 8, true, true, "", "true", 6, false, "", ""];

//allow an action for the player to return to spawn
_spawn addAction _baseAction;

//available wave settings
private _targetOptions = [
	["Squad", "O_Soldier_F", "", 0.2, 4],
	["Horde", "O_Soldier_F", "", 0.01, 10],
	["Snipers", "O_sniper_F", "", 0.5, 2],
	["Aimbot", "O_Soldier_F", "", 1.0, 1],
	["Technicals", "O_Soldier_F", "O_G_Offroad_01_armed_F", 0.15, 2],
	["Tank", "O_crew_F", "O_MBT_02_cannon_F", 0.2, 1],
	["Helo", "O_helicrew_F", "O_Heli_Attack_02_black_F", 0.5, 1],
	["DayZ Special", "O_crew_F", "C_Truck_02_covered_F", 0.2, 1]
];

//add the actions for each wave setting
{
	private _thisAction = _baseAction;
	_thisAction set [0, format ["<t color='#ffffff'>Spawn %1</t>", _x select 0]];
	_thisAction set [1, { _this call SCO_fnc_spawnBattleGroundWave }];
	_thisAction set [2, _x + [_radius]];
	_spawn addAction _thisAction;
} forEach _targetOptions;

//spawn a thread to track if the player is dead and within the battleground
//also track number of remaining enemies
private _counter = [_caller, _pos, _radius] spawn
{
	params ["_player", "_center", "_radius"];
	while {(alive _player) and (_player distance2D _center < _radius)} do
	{
		//while the player is in the battleground, track the number of enemy units alive
		private _numEnemyAlive = 0;
		{
			if ((side _x == east) and (alive _x)) then
			{
				_numEnemyAlive = _numEnemyAlive + 1;
			};
		} foreach (nearestObjects [_center, ["Man", "Car", "Helicopter"], _radius]);
		hint format ["Enemies remaining: %1", _numEnemyAlive];
		sleep 1;
	};
	//then the player is no longer in the battleground, stop tracking
	hint "";
};

//TODO: if a player disconnects prematurely, all objects and markers from this script remain on the server.
//If the player reconnects, they do not have the addActions.

//clean up
waitUntil {(not alive _caller) or (count actionIDs _spawn == 0) or (isNull _caller)};
deleteVehicle _spawn;
deleteMarker _markerCenter;
deleteMarker _markerBorder;
if (alive _caller) then
{
	_caller setPos getMarkerPos _returnMarker;
};