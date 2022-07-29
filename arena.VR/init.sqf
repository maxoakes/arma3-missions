//parse parameters of mission
setDate [2022, 6, 16, ("Time" call BIS_fnc_getParamValue), 0];
private _startingTickets = ("Tickets" call BIS_fnc_getParamValue);
[west, _startingTickets] call BIS_fnc_respawnTickets;
[east, _startingTickets] call BIS_fnc_respawnTickets;

if (isServer) then
{
	private _startTime = diag_tickTime;

	//add the possible loadouts to the respawn menu
	{
		[west,_x] call BIS_fnc_addRespawnInventory;
		[east,_x] call BIS_fnc_addRespawnInventory;
	} foreach ["Sniper1","Sniper2","Sniper3","Sniper4","Sniper5",
		"LMG1","LMG2","LMG3","LMG4","MMG1","MMG2","MMG3",
		"Assault1","Assault2","Assault3","Assault4","Assault5","Assault6",
		"Assault7","Assault8","Assault9","Assault10","Assault11",
		"SMG1","SMG2","SMG3","SMG4","SMG5"];

	//remove ramps if the parameters call for it
	private _useRamps = [("Ramps" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean;
	{
		if (_useRamps) then 
		{
			private _angle = getDir _x;
			private _pos = getPos _x;
			private _block = createVehicle ["Land_VR_Block_05_F", _pos, [], 0, "CAN_COLLIDE"];
			_block setDir _angle;
			deleteVehicle _x;
		};
	} forEach [ramp, ramp_1, ramp_2, ramp_3, ramp_4, ramp_5, ramp_6, ramp_7];

	private _shoothouseObjects = [
		"Land_Shoot_House_Wall_Stand_F", "Land_Shoot_House_Wall_Prone_F",
		"Land_Shoot_House_Wall_Crouch_F", "Land_Shoot_House_Wall_F",
//		"Land_Shoot_House_Tunnel_Stand_F", "Land_Shoot_House_Tunnel_Prone_F",
//		"Land_Shoot_House_Tunnel_Crouch_F", "Land_Shoot_House_Tunnel_F",
		"Land_Shoot_House_Panels_Windows_F", "Land_Shoot_House_Panels_Window_F",
		"Land_Shoot_House_Panels_Vault_F", "Land_Shoot_House_Panels_Prone_F",
		"Land_Shoot_House_Panels_Crouch_F", "Land_Shoot_House_Panels_F"];

	private _vrObjects = [
		"Land_VR_Shape_01_cube_1m_F", "Land_VR_CoverObject_01_stand_F", 
		"Land_VR_CoverObject_01_kneelLow_F", "Land_VR_CoverObject_01_kneel_F",
		"Land_VR_CoverObject_01_standHigh_F", "Land_VR_CoverObject_01_kneelHigh_F"];

	//get all of the node markers
	private _nodeMarkers = [];
	{
		if ("node_" in _x) then
		{
			_nodeMarkers pushBack _x;
		};
	} forEach allMapMarkers;

	//choose the set of objects to populate arena
	private _isVR = [("Type" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean;
	private _arenaObjectSelection = [];
	private _placementRadius = 0;
	if (_isVR) then 
	{
		_arenaObjectSelection = _vrObjects;
		_placementRadius = 1;
	}
	else
	{
		_arenaObjectSelection = _shoothouseObjects;
	};

	//populate the arena by placing objects at node markers on the map
	private _mapDensity = ("Density" call BIS_fnc_getParamValue);
	private _possibleAngles = [0, 90, 180, 270];
	{
		if ((random 100) >= _mapDensity) then { continue };
		private _chosenObject = selectRandom _arenaObjectSelection;
		private _pos = getMarkerPos _x;
		private _obj = createVehicle [_chosenObject, _pos, [], _placementRadius, "CAN_COLLIDE"];
		_obj setDir selectRandom _possibleAngles;
	} forEach _nodeMarkers;

	//enable weapon and ammo options at base
	{
		[_x, ["Add Ammo for weapon in hand", "functions\addAction\fn_refillWeapon.sqf", 4]] remoteExec ["addAction"];
		[_x, ["Get a random primary weapon", "functions\addAction\fn_getRandomWeapon.sqf", 
			["AssaultRifle", "MachineGun", "SniperRifle", "Shotgun", "Rifle", "SubmachineGun"]]] remoteExec ["addAction"];
	} forEach [crate, crate1];

	//spawn thread to listen for end condition
	[] spawn
	{
		waitUntil {
			sleep 2;
			//count number of west players that are on the island
			private _aliveWest = {alive _x} count (allPlayers select {side _x == west});
			private _aliveEast = {alive _x} count (allPlayers select {side _x == east});
			private _ticketsWest = [west, 0] call BIS_fnc_respawnTickets;
			private _ticketsEast = [east, 0] call BIS_fnc_respawnTickets;
			//(format ["West: a=%1:t=%2. East: a=%3:t=%4", _aliveWest, _ticketsWest, _aliveEast, _ticketsEast]) remoteExec ["systemChat", 0];
			private _isOver = false;
			if ((_aliveWest == 0 and _ticketsWest <= 0) or (_aliveEast == 0 and _ticketsEast <= 0)) then
			{
				_isOver = true;
			};
			_isOver;
		};
		sleep 3;
		"SideScore" call BIS_fnc_endMissionServer;
	};

	private _stopTime = diag_tickTime;
	(format ["init.sqf took %1 sec to complete", _stopTime - _startTime]) remoteExec ["systemChat", 0];
};