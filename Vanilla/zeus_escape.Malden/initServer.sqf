{
	[west,_x] call BIS_fnc_addRespawnInventory;
} forEach ["US1", "US2", "US3", "US4", "US5", "US6", "US7", "US8", "US9", "US10", "US11"];

//if a player is damaged or killed, the zeus gets points
{
	_x addMPEventHandler ["MPKilled", {gm addCuratorPoints KILL_REWARD;}];
	_x addMPEventHandler ["MPHit", {gm addCuratorPoints HIT_REWARD;}];
} forEach units (playableUnits select 0);

//make a zeus editing area around each capture and hold point
{
	private _thisEditAreaID = parseNumber mapGridPosition getPos _x;
	gm addCuratorEditingArea [_thisEditAreaID, getPos _x, 100];
} forEach nearestObjects [
	getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), ["ModuleSector_F"], worldSize];

//get all of the node markers
private _campMarkers = [];
{
	if ("enemy_camp_" in _x) then
	{
		_campMarkers pushBack _x;
	};
} forEach allMapMarkers;

//make a zeus editing area around each enemy camp
{
	private _pos = getMarkerPos _x;
	private _size = markerSize _x select 0;
	private _id = parseNumber mapGridPosition _pos;
	gm addCuratorEditingArea [_id, getMarkerPos _x, _size];
} forEach _campMarkers;

//spawn a thread to check for win condition: everyone gets to the carrier
[] spawn
{
	//wait for checking for everyone until someone is near the carrier
	waitUntil
	{
		{(_x distance2D getMarkerPos "carrier" < 1000) and (side _x == west)} count allUnits > 0
	};
	//once someone is on the carrier, start checking to see if everyone is on there
	waitUntil
	{
		sleep 2;
		//count number of west players that are on the carrier
		private _westOnCarrier = {
			(_x distance2D getMarkerPos "carrier" < 200) and 
			(side group _x == west) and
			(speed vehicle _x < 10) and
			(alive _x) and
			(isPlayer _x)
		} count allUnits;
		private _westTotal = count allPlayers;
		[format ["cond %1 == %2", _westOnCarrier, _westTotal]] remoteExec ["systemChat"];
		_westOnCarrier == _westTotal; //wait until this is true
	};
	["Everyone as escaped the island. Good job."] remoteExec ["systemChat"];
	sleep 5;
	"EveryoneWon" call BIS_fnc_endMissionServer;
};