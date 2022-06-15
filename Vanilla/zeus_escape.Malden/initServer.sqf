//if a player is damaged or killed, the zeus gets points
{
	_x addMPEventHandler ["MPKilled", {gm addCuratorPoints KILL_REWARD;}];
	_x addMPEventHandler ["MPHit", {gm addCuratorPoints HIT_REWARD;}];
} forEach units (playableUnits select 0);

//make a zeus editing area around each capture and hold point
{
	_thisEditAreaID = parseNumber mapGridPosition getPos _x;
	gm addCuratorEditingArea [_thisEditAreaID, getPos _x, 100];
} forEach nearestObjects [
	getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), ["ModuleSector_F"], worldSize];

campMarkers = [
	"ec_0", "ec_1", "ec_2", "ec_3", "ec_4", "ec_5", "ec_6", "ec_7", "ec_8",
	"ec_9", "ec_10","ec_11", "ec_12", "ec_13", "ec_14", "ec_15", "ec_16", 
	"ec_17", "ec_18", "ec_19"];

//make a zeus editing area around each enemy camp
{
	_thisEditAreaID = parseNumber mapGridPosition getMarkerPos _x;
	gm addCuratorEditingArea [_thisEditAreaID,getMarkerPos _x, 200];
} forEach campMarkers;

//spawn a thread to check for win condition: everyone gets outside of the island
[] spawn
{
	waitUntil {
		sleep 30;
		//count number of west players that are on the island
		_westOnCarrier = {
			(_x distance2D getMarkerPos "carrier" < 150) and (side group _x == west)
		} count allPlayers;
		_westTotal = west countSide allPlayers;
		_westOnCarrier == _westTotal; //wait until this is true
	};
	["Everyone as escaped the island. Good job."] remoteExec ["systemChat"];
	sleep 3;
	"EveryoneWon" call BIS_fnc_endMissionServer;
};