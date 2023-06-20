params ["_patrolCenter", "_patrolRadius", "_blacklistedPos", "_blacklistedRadius", "_patrolVehiclePool", "_maxVehicles", "_side"];

[format ["Spawning %1 air patrol vehicles", _maxVehicles]] call SCO_fnc_printDebug;
private _spawnedGroups = [];
for "_i" from 1 to _maxVehicles do
{
	private _spawnPos = [[[getMarkerPos _patrolCenter, _patrolRadius]], [[_blacklistedPos, _blacklistedRadius]]] call BIS_fnc_randomPos;

	//spawn the vehicle
	private _result = [_spawnPos, 0, selectRandom _patrolVehiclePool, _side] call BIS_fnc_spawnVehicle;
	_spawnedGroups pushBack _result;
	_result params ["_vehicle", "_crew", "_group"];
	_group setGroupIdGlobal [format ["Air Vehicle Patrol %1", {side _x == _side} count allGroups]];

	//create patrol destinations
	[_group, getMarkerPos _patrolCenter, _patrolRadius] call BIS_fnc_taskPatrol;

	//unlimited fuel
	_vehicle addEventHandler ["Fuel", {
		params ["_vehicle", "_hasFuel"];
		if (fuel _vehicle < 0.5) then
		{
			_vehicle setFuel 1;
		};
	}];
};
["All air patrols spawned"] call SCO_fnc_printDebug;