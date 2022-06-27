params ["_target", "_caller", "_actionId", "_loc"];

private _pos = [getPos _loc, 0, 100, 5, 0, MAX_GRADIENT, 0] call BIS_fnc_findSafePos;
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

private _markerBorder = createMarker [ format ["c%1", _this select 1], _pos];
_markerBorder setMarkerShape "ELLIPSE";
_markerBorder setMarkerBrush "SolidFull";
_markerBorder setMarkerAlpha 0.25;
_markerBorder setMarkerColor "ColorBlack";
_markerBorder setMarkerSize [BATTLEGROUND_RADIUS, BATTLEGROUND_RADIUS];

private _markerCenter = createMarker [ format ["x%1", _randomName], _pos];
_markerCenter setMarkerShape "ICON";
_markerCenter setMarkerText format ["%1's Battleground", name _caller];
_markerCenter setMarkerType "mil_flag";
_markerCenter setMarkerColor "ColorBlue";

//teleport the player
player setPos [(_pos select 0),(_pos select 1)-2];

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
	_thisAction set [1, "functions\fn_spawnBattleGroundWave.sqf"];
	_thisAction set [2, _x];
	_spawn addAction _thisAction;
} forEach _targetOptions;

//spawn a thread to track if the player is dead and within the battleground
//also track number of remaining enemies
private _counter = [_caller, _pos] spawn
{
	params ["_player", "_center"];
	while {(alive _player) and (_player distance2D _center < BATTLEGROUND_RADIUS)} do
	{
		//while the player is in the battleground, track the number of enemy units alive
		private _numEnemyAlive = 0;
		{
			if ((side _x == east) and (alive _x)) then
			{
				_numEnemyAlive = _numEnemyAlive + 1;
			};
		} foreach (nearestObjects [_center, ["Man", "Car", "Helicopter"], BATTLEGROUND_RADIUS]);
		hint format ["Enemies remaining: %1", _numEnemyAlive];
		sleep 1;
	};
	//then the player is no longer in the battleground, stop tracking
	hint "";
};

//clean up
waitUntil {(not alive _caller) or (count actionIDs _spawn == 0) or (isNull _caller)};
deleteVehicle _spawn;
deleteMarker _markerCenter;
deleteMarker _markerBorder;
if (alive _caller) then
{
	_caller setPos SPAWN_POS;
};