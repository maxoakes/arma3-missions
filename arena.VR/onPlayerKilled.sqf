params ["_oldUnit", "_killer", "_respawn", "_respawnDelay"];
if (side _killer != side _oldUnit) then
{
	private _killerSideTickets = [side _killer, 1] call BIS_fnc_respawnTickets;
	private _victimSideTickets = [side _oldUnit] call BIS_fnc_respawnTickets
	(format ["%1 has %2 tickets. %3 has %4 tickets.", side _killer, _killerSideTickets, side _oldUnit, _victimSideTickets]) remoteExec ["systemChat", 0];	
}
else
{
	//(format ["No reward. %1 on %2.", side _killer, side _oldUnit]) remoteExec ["systemChat", 0];
};