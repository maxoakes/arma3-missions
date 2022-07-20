/*
	Author: Scouter

	Description:
		Manage the tasks of the mission. Should be spawned rather than called. 
		Must be run concurrently.
		
	Parameter(s):
		0: Object - the tent that is the initial destination for players
		1: Object - the object that has the intel that says where the meeting is taking place
		2: Position - where the meeting actually is
		3: Object - the leader that is the target of the players
		4: Object - the boat the players will escape the region on
		5: Object - the final destination for the players to end the mission

	Returns:
		Void
*/
params ["_tent", "_intel", "_posMeeting", "_warlord", "_boat", "_end"];
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
[player, ["Diary", [localize "STR_DIARY_TENT_TITLE", localize "STR_DIARY_TENT_TEXT"], taskNull, "", false]] remoteExec ["createDiaryRecord", 0, true];

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

//complete the secondary objective, update the primary one
["taskIntel", "SUCCEEDED"] call BIS_fnc_taskSetState;
["taskKill", _posMeeting] call BIS_fnc_taskSetDestination;
"meeting" setMarkerAlpha 1;
[player, ["Diary", [localize "STR_DIARY_MEETING_TITLE", localize "STR_DIARY_MEETING_TEXT"], taskNull, "", false]] remoteExec ["createDiaryRecord", 0, true];

//wait until the kill is confirmed
waitUntil { (CONFIRMED_KILL and !(alive _warlord)); };
["taskKill", "SUCCEEDED"] call BIS_fnc_taskSetState;
_boat lock false;

//create next objective to leave the map
[
	west, //side
	"taskBoat", //id 
	[ //desc
		"$STR_TASK_EXTRACT_DESC", 
		"$STR_TASK_EXTRACT_TITLE", 
		"$STR_TASK_EXTRACT_LOC"
	], 
	_boat, //dest
	true, //state
	-1, //priority
	true, //show notification
	"getin", //type
	true //visible in 3d
] call BIS_fnc_taskCreate;

//add diary entry for all players
[player, ["Diary", [localize "STR_DIARY_EXTRACT_TITLE", localize "STR_DIARY_EXTRACT_TEXT"], taskNull, "", false]] remoteExec ["createDiaryRecord", 0, true];

//wait until everyone is in the boat
waitUntil {
	sleep 0.5;
	private _everyoneInVehicle = true;
	{
		if (vehicle _x != exfiltration) then
		{
			_everyoneInVehicle = false;
		};
	} forEach call BIS_fnc_listPlayers;
	_everyoneInVehicle;
};

["taskBoat","SUCCEEDED"] call BIS_fnc_taskSetState;
//update the destination when everyone is in the boat
[
	west, //side
	"taskExfiltrate", //id 
	[ //desc
		"$STR_TASK_EXTRACT_UPDATE_DESC", 
		"$STR_TASK_EXTRACT_UPDATE_TITLE", 
		"$STR_TASK_EXTRACT_UPDATE_LOC"
	], 
	_end, //dest
	true, //state
	-1, //priority
	true, //show notification
	"takeoff", //type
	true //visible in 3d
] call BIS_fnc_taskCreate;

//wait until everyone is at the ship
waitUntil {
	sleep 0.5;
	{alive _x} count allPlayers == {alive _x && _x distance2D _end < 200} count allPlayers;
};

["taskExfiltrate", "SUCCEEDED"] call BIS_fnc_taskSetState;
"EveryoneWon" call BIS_fnc_endMissionServer;