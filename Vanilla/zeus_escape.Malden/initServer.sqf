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

//spawn a thread to check for win condition: everyone gets outside of the island
[] spawn
{
	waitUntil {
		sleep 30;
		//count number of west players that are on the island
		private _westOnCarrier = {
			(_x distance2D getMarkerPos "carrier" < 150) and (side group _x == west)
		} count allPlayers;
		private _westTotal = west countSide allPlayers;
		_westOnCarrier == _westTotal; //wait until this is true
	};
	["Everyone as escaped the island. Good job."] remoteExec ["systemChat"];
	sleep 30000;
	"EveryoneWon" call BIS_fnc_endMissionServer;
};