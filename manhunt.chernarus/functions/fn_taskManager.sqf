params ["_tent", "_intel", "_posMeeting", "_warlord", "_boat", "_end"];

[
	west, //side
	"taskKill", //id 
	[ //desc
		"It is likely that the warload is in his HQ tent. Eliminate him and confirm your kill.", 
		"Identify and Eliminate the Warlord", 
		"HQ Tent"
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
		"The warlord is not in his tent.",
		"Kill the Warlord",
		"Unknown"
	]
] call BIS_fnc_taskSetDescription;
["taskKill", objNull] call BIS_fnc_taskSetDestination;

//create secondary objective to track down warlord's location
[
	west, //side
	"taskIntel", //id 
	[ //desc
		"The warload is not at their tent. Find intel that can help ascertain his whereabouts.", 
		"Find the warlord's location", 
		"Computer"
	], 
	_intel, //dest
	true, //state
	-1, //priority
	true, //show notification
	"interact", //type
	true //visible in 3d
] call BIS_fnc_taskCreate;

//assign an action to the intel object to make visible the warlord meeting location
private _intelAction = ["Read Messages", { REVEAL_WARLORD_MEETING = true; }, nil, 3, true, true, "", "true", 2];
[_intel, _intelAction] remoteExec ["addAction", 0, true];

//wait until someone finds the warlord's meeting location
waitUntil { REVEAL_WARLORD_MEETING or (CONFIRMED_KILL and !(alive _warlord)); };

//complete the secondary objective, update the primary one
["taskIntel", "SUCCEEDED"] call BIS_fnc_taskSetState;
["taskKill", _posMeeting] call BIS_fnc_taskSetDestination;
"meeting" setMarkerAlpha 1;

//wait until the kill is confirmed
waitUntil { (CONFIRMED_KILL and !(alive _warlord)); };
["taskKill", "SUCCEEDED"] call BIS_fnc_taskSetState;
_boat lock false;

//create next objective to leave the map
[
	west, //side
	"taskBoat", //id 
	[ //desc
		"The warlord has been confirmed dead. Get to the extraction vehicle.", 
		"Get to the Extraction Vehicle", 
		"Boat"
	], 
	_boat, //dest
	true, //state
	-1, //priority
	true, //show notification
	"getin", //type
	true //visible in 3d
] call BIS_fnc_taskCreate;

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
		"Use the extraction vehicle to get to the ship off of the coast.", 
		"Leave the Area", 
		"Ship"
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