params ["_tent", "_intel", "_posMeeting", "_warlord", "_extract", "_enemyUnitClassnames", "_vehicleClassnames"];
missionNamespace setVariable ["REVEAL_WARLORD_MEETING", false, true];
//create task to kill warlord
[
	west, //side
	"taskKill", //id 
	[ //desc
		"$STR_TASK_TENT_DESC", 
		"$STR_TASK_TENT_TITLE", 
		"$STR_TASK_TENT_LOC"
	], 
	_tent, //dest
	true, //state
	-1, //priority
	true, //show notification
	"kill", //type
	true //visible in 3d
] call BIS_fnc_taskCreate;

//wait until a unit is at the tent to continue
waitUntil { ({_x distance2D _tent < 8} count units west) > 0 or REVEAL_WARLORD_MEETING or (CONFIRMED_KILL and !(alive _warlord)); };

//hide task objective until the warlord is found
[
	"taskKill",
	[
		"$STR_TASK_TENT_UPDATE_DESC",
		"$STR_TASK_TENT_UPDATE_TITLE",
		"$STR_TASK_TENT_UPDATE_LOC"
	]
] call BIS_fnc_taskSetDescription;
["taskKill", objNull] call BIS_fnc_taskSetDestination;

//add diary entry for all players
{player createDiaryRecord ["Diary", [localize "STR_DIARY_TENT_TITLE", localize "STR_DIARY_TENT_TEXT"], taskNull, "", false]} remoteExec ["call", 0, true];

//create secondary objective to track down warlord's location
[
	west, //side
	"taskIntel", //id 
	[ //desc
		"$STR_TASK_INTEL_DESC",
		"$STR_TASK_INTEL_TITLE",
		"$STR_TASK_INTEL_LOC"
	], 
	_intel, //dest
	true, //state
	-1, //priority
	true, //show notification
	"interact", //type
	true //visible in 3d
] call BIS_fnc_taskCreate;

//assign an action to the intel object to make visible the warlord meeting location
private _intelAction = [localize "STR_ACTION_INTEL", { missionNamespace setVariable ["REVEAL_WARLORD_MEETING", true, true]; }, nil, 3, true, true, "", "true", 2];
[_intel, _intelAction] remoteExec ["addAction", 0, true];

//wait until someone finds the warlord's meeting location
waitUntil { REVEAL_WARLORD_MEETING or (CONFIRMED_KILL and !(alive _warlord)); };

//make a respawn checkpoint and remove original
[
	"respawn_west_tent", //var name
	_tent getPos [7, getDir _tent], //position
	"HQ Tent", //display name
	[1, 1], //size
	"ColorBLUFOR", //color string
	"ICON", //type
	"Empty" //style
] call SCO_fnc_createMarker;
deleteMarker "respawn_west";

//complete the secondary objective, update the primary one
["taskIntel", "SUCCEEDED"] call BIS_fnc_taskSetState;
["taskKill", _posMeeting] call BIS_fnc_taskSetDestination;
"meeting" setMarkerAlpha 1;
{player createDiaryRecord ["Diary", [localize "STR_DIARY_MEETING_TITLE", localize "STR_DIARY_MEETING_TEXT"], taskNull, "", false]} remoteExec ["call", 0, true];
//wait until the kill is confirmed
waitUntil { (CONFIRMED_KILL and !(alive _warlord)); };
["taskKill", "SUCCEEDED"] call BIS_fnc_taskSetState;

//make a respawn checkpoint at the meeting site
[
	"respawn_west_meeting", //var name
	_tent getPos [7, getDir _tent], //position
	"Meeting Location", //display name
	[1, 1], //size
	"ColorBLUFOR", //color string
	"ICON", //type
	"Empty" //style
] call SCO_fnc_createMarker;

//create next objective to leave the map
[
	west, //side
	"tastExtract", //id 
	[ //desc
		"$STR_TASK_EXTRACT_DESC", 
		"$STR_TASK_EXTRACT_TITLE", 
		"$STR_TASK_EXTRACT_LOC"
	], 
	_extract, //dest
	true, //state
	-1, //priority
	true, //show notification
	"getin", //type
	true //visible in 3d
] call BIS_fnc_taskCreate;

//add diary entry for all players
{player createDiaryRecord ["Diary", [localize "STR_DIARY_EXTRACT_TITLE", localize "STR_DIARY_EXTRACT_TEXT"], taskNull, "", false]} remoteExec ["call", 0, true];

private _nearbyUnitCount = { side _x == west } count (getPos _extract nearEntities ["Man", 500]);
[format ["Nearby west units at spawn: %1", _nearbyUnitCount]] call SCO_fnc_printDebug;

private _squad = grpNull;
private _numUnits = (count allPlayers)*5;
private _parkedSpawnConvoy = [getPos _extract, count allPlayers, _vehicleClassnames, 5] call SCO_fnc_spawnParkedVehicles;

//if there are west units at the spawn, then a squad will approach from nearby
//if there are no units nearby, spawn a fortified squad
if (_nearbyUnitCount == 0) then
{
	//spawn static items
	private _staticItemPool = ["O_HMG_01_high_F", "CUP_O_DSHKM_ChDKZ", "CUP_O_KORD_high_RU_M_BeigeDigital", 
		"Land_BagFence_Round_F", "Land_BagFence_Long_F"];

	for "_i" from 1 to (count allPlayers)*3 do
	{
		private _safePos = [getPos _extract, 10, 40, 4, 0, 0.5, 0, [], [[0,0,0], [0,0,0]]] call BIS_fnc_findSafePos;
		if (_safePos select 0 == 0 and _safePos select 1 == 0) then {continue; };
		private _veh = createVehicle [selectRandom _staticItemPool, _safePos, [], 0, "NONE"];
		_veh setDir (_extract getDir _safePos);
	};

	//spawn enemy units around helicopter, the squad and a guard point
	
	createGuardedPoint [east, getPos _extract, -1, objNull];
	_squad = [getPos _extract, east, _numUnits, _enemyUnitClassnames, [0.3, 0.5], 1, 25] call SCO_fnc_spawnFootPatrolGroup;
}
else
{
	private _startPos = getPos (_parkedSpawnConvoy select 0);
	_squad = [_startPos, east, getPos _extract, _numUnits, _enemyUnitClassnames, [0.3, 0.5], "AWARE", "RED", "LINE"] call SCO_fnc_spawnHitSquad;
};

//marker to indicate what to clear
[
	"secureRadius", //var name
	getPos _extract, //position
	"", //display name
	[150, 150], //size
	"ColorOpfor", //color string
	"ELLIPSE", //type
	"DiagGrid", //style
	0, 0.5
] call SCO_fnc_createMarker;

//wait until a player gets close to the extraction helo to make a secondary objective
waitUntil { ({_x distance2D _extract < 200} count units west) > 0; };
{player createDiaryRecord ["Diary", [localize "STR_DIARY_SECURE_TITLE", localize "STR_DIARY_SECURE_TEXT"], taskNull, "", false]} remoteExec ["call", 0, true];
//create task to kill warlord
[
	west, //side
	"taskSecure", //id 
	[ //desc
		"$STR_TASK_SECURE_DESC", 
		"$STR_TASK_SECURE_TITLE", 
		"$STR_TASK_SECURE_LOC"
	], 
	_extract, //dest
	true, //state
	-1, //priority
	true, //show notification
	"defend", //type
	true //visible in 3d
] call BIS_fnc_taskCreate;

waitUntil { { (_extract distance2D _x < 150) and (alive _x) } count units _squad == 0; };
["taskSecure", "SUCCEEDED"] call BIS_fnc_taskSetState;
_extract lock false;

//wait until everyone is in the vehicle
waitUntil {
	sleep 0.5;
	private _everyoneInVehicle = true;
	{
		if (vehicle _x != _extract) then
		{
			_everyoneInVehicle = false;
		};
	} forEach call BIS_fnc_listPlayers;
	_everyoneInVehicle;
};

["tastExtract","SUCCEEDED"] call BIS_fnc_taskSetState;
"EveryoneWon" call BIS_fnc_endMissionServer;