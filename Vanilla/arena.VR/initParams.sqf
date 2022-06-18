setDate [2022, 6, 16, ("Time" call BIS_fnc_getParamValue), 0];
private _startingTickets = ("Tickets" call BIS_fnc_getParamValue);
[west, _startingTickets] call BIS_fnc_respawnTickets;
[east, _startingTickets] call BIS_fnc_respawnTickets;

SCO_DENSITY = ("Density" call BIS_fnc_getParamValue);

SCO_IS_VR = true; //if true, the map will consist of VR blocks.
//if false, the map will consist of shoot house panels
if (("Type" call BIS_fnc_getParamValue) == 1) then
{
	SCO_IS_VR = false;
}
else
{
	SCO_IS_VR = true;
};

_useRamps = ("Ramps" call BIS_fnc_getParamValue);
{
	if (_useRamps == 0) then 
	{
		private _angle = getDir _x;
		private _pos = getPos _x;
		private _block = createVehicle ["Land_VR_Block_05_F", _pos, [], 0, "CAN_COLLIDE"];
		_block setDir _angle;
		deleteVehicle _x;
	};
} forEach [ramp, ramp_1, ramp_2, ramp_3, ramp_4, ramp_5, ramp_6, ramp_7];

