params ["_cachePairs", "_aaObjects", "_resupplyMarkers", "_escapeVehicles", "_spawnMarker", "_playerSide", "_extractionMarker"];

// hide extraction marker initially
_extractionMarker setMarkerAlpha 0; 

//create task to resupply (if one exists)
if (count _resupplyMarkers > 0) then
{
	//find the nearest resupply (if there are more than one)
	private _nearestResupply = _resupplyMarkers select 0;
	if (count _resupplyMarkers > 1) then
	{
		{
			if ((getMarkerPos _spawnMarker distance2D getMarkerPos _x) > (getMarkerPos _spawnMarker distance2D getMarkerPos _nearestResupply)) then
			{
				_nearestResupply = _x;
			}
		} forEach _resupplyMarkers;
	};
	[
		_playerSide, //side
		"taskResupply", //id 
		[ //desc
			"$STR_TASK_RESUPPLY_DESC", 
			"$STR_TASK_RESUPPLY_TITLE", 
			"$STR_TASK_RESUPPLY_LOC"
		], 
		_nearestResupply, //dest
		true, //state
		0, //priority
		false, //show notification
		"rearm", //type
		true //visible in 3d
	] call BIS_fnc_taskCreate;
	{player createDiaryRecord ["Diary", [localize "STR_DIARY_RESUPPLY_TITLE", localize "STR_DIARY_RESUPPLY_TEXT"], taskNull, "", false]} remoteExec ["call", 0, true];
};

//create task to destroy caches (if any)
private _cacheTasks = [];
if (count _cachePairs > 0) then
{
	{
		_x params ["_cacheListener", "_cacheMarker"];
		private _cacheID = _forEachIndex + 1;
		private _taskName = format ["taskCache%1", _cacheID];
		[
			_playerSide, //side
			_taskName, //id 
			[ //desc
				"$STR_TASK_CACHE_DESC", 
				"$STR_TASK_CACHE_TITLE", 
				"$STR_TASK_CACHE_LOC"
			], 
			getMarkerPos _cacheMarker, //dest
			true, //state
			_cacheID, //priority
			false, //show notification
			"destroy", //type
			true //visible in 3d
		] call BIS_fnc_taskCreate;
		_cacheTasks pushBackUnique _taskName;

		// objective completion check
		[_cacheListener, _taskName] spawn
		{
			_this params ["_eventListeners", "_task"];
			waitUntil {{!(scriptDone _x)} count _eventListeners == 0};
			[_task, "SUCCEEDED"] call BIS_fnc_taskSetState;
		};
	} forEach _cachePairs;
	{player createDiaryRecord ["Diary", [localize "STR_DIARY_CACHE_TITLE", localize "STR_DIARY_CACHE_TEXT"], taskNull, "", false]} remoteExec ["call", 0, true];
};

//create task to destroy AA (if any)
private _aaTasks = [];
if (count _aaObjects > 0) then
{
	{
		private _aaID = _forEachIndex + 1;
		private _taskName = format ["taskAA%1", _aaID];
		[
			_playerSide, //side
			_taskName, //id 
			[ //desc
				"$STR_TASK_AA_DESC", 
				"$STR_TASK_AA_TITLE", 
				"$STR_TASK_AA_LOC"
			], 
			_x, //dest
			true, //state
			(count _cachePairs) + _aaID, //priority
			true, //show notification
			"destroy", //type
			true //visible in 3d
		] call BIS_fnc_taskCreate;
		_aaTasks pushBackUnique _taskName;

		// objective completion check
		[_x, _taskName] spawn
		{
			_this params ["_aa", "_task"];
			waitUntil {(damage _aa) > 0.9};
			[_task, "SUCCEEDED"] call BIS_fnc_taskSetState;
		};
	} forEach _aaObjects;
	{player createDiaryRecord ["Diary", [localize "STR_DIARY_AA_TITLE", localize "STR_DIARY_AA_TEXT"], taskNull, "", false]} remoteExec ["call", 0, true];
};

//wait until all AA and caches are dead to continue
waitUntil { ({!(_x call BIS_fnc_taskCompleted)} count _aaTasks) == 0 and ({!(_x call BIS_fnc_taskCompleted)} count _cacheTasks) == 0};
["taskResupply","CANCELED", false] call BIS_fnc_taskSetState;

//create next objective to leave the map
[
	_playerSide, //side
	"taskExtract", //id 
	[ //desc
		"$STR_TASK_EXTRACT_DESC", 
		"$STR_TASK_EXTRACT_TITLE", 
		"$STR_TASK_EXTRACT_LOC"
	], 
	selectRandom _escapeVehicles, //dest
	true, //state
	100, //priority
	true, //show notification
	"getin", //type
	true //visible in 3d
] call BIS_fnc_taskCreate;

//create next objective to leave the map
[
	_playerSide, //side
	"taskWin", //id 
	[ //desc
		"$STR_TASK_WIN_DESC", 
		"$STR_TASK_WIN_TITLE", 
		"$STR_TASK_WIN_LOC"
	], 
	_extractionMarker, //dest
	true, //state
	99, //priority
	true, //show notification
	"default", //type
	true //visible in 3d
] call BIS_fnc_taskCreate;

//add diary entry for all players
{player createDiaryRecord ["Diary", [localize "STR_DIARY_EXTRACT_TITLE", localize "STR_DIARY_EXTRACT_TEXT"], taskNull, "", false]} remoteExec ["call", 0, true];
// _extractionMarker setMarkerAlpha 1;

waitUntil {({(getMarkerPos _extractionMarker distance2D _x) < 1000 and alive _x} count units _playerSide == count units _playerSide) or (({canMove _x} count _escapeVehicles) == 0)};

if (({canMove _x} count _escapeVehicles) == 0) then
{
	["taskExtract","FAILED", true] call BIS_fnc_taskSetState;
	["taskWin","FAILED", false] call BIS_fnc_taskSetState;
	"EveryoneLost" call BIS_fnc_endMissionServer;
}
else
{
	["taskExtract","SUCCEEDED", true] call BIS_fnc_taskSetState;
	["taskWin","SUCCEED", false] call BIS_fnc_taskSetState;
	"EveryoneWon" call BIS_fnc_endMissionServer;
};