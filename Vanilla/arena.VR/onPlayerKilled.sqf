params ["_oldUnit", "_killer", "_respawn", "_respawnDelay"];
if (side _killer != side _oldUnit) then
{
	private _n = [side _killer, _startingTickets] call BIS_fnc_respawnTickets;
	(format ["A player was killed by enemy unit. %1 now has %2 tickets.", side _killer, _n]) remoteExec ["systemChat", 0];	
}
else
{
	(format ["No reward. %1 on %2.", side _killer, side _oldUnit]) remoteExec ["systemChat", 0];
};