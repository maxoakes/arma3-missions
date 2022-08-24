params ["_target", "_caller", "_actionId", "_arguments"];
private _type = _arguments select 0;
private _unitClassname = _arguments select 1;
private _vehicleClassname = _arguments select 2;
private _skill = _arguments select 3;
private _amount = _arguments select 4;

//get a location on the outer edge of the battleground radius
private _spawnPos = [getPos _target, BATTLEGROUND_RADIUS / 1.5, BATTLEGROUND_RADIUS, 20, 0, MAX_GRADIENT, 0] call BIS_fnc_findSafePos;
private _mapOrigin = getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition");

if ((_mapOrigin select 0 == _spawnPos select 0) and (_mapOrigin select 1 ==_spawnPos select 1)) exitWith
{
	hint "Unable to find suitable enemy spawn location. Cancelling...";
};

//create a marker at the spawn location that was chosen
private _marker = createMarker [format ["e%1",floor random 99999999], _spawnPos];
_marker setMarkerShape "ICON";
_marker setMarkerText format ["%1 spawn", _type];
_marker setMarkerType "mil_destroy";
_marker setMarkerColor "ColorRed";

//create the group and destination waypoint
private _group = createGroup east;
_group setCombatMode "RED";
_group setBehaviourStrong "COMBAT";
_group setSpeedMode "FULL";
_group setFormation "WEDGE";

private _wp = _group addWaypoint [(getPos _caller), 0];
_wp setWaypointType "SAD";

private _squad = [];
private _vehicles = [];

//if a vehicle is not named, just spawn the units
if (_vehicleClassname == "") then
{
	//create the units and set their target to the player
	for "_i" from 1 to _amount do
	{
		private _unit = _group createUnit [_unitClassname, _spawnPos, [], 0, "NONE"];
		_unit setSkill _skill;
		_unit commandTarget _caller;
		_squad pushBack _unit;
	};
}
//if a vehicle is named, create and fill a vehicle
else
{
	for "_i" from 1 to _amount do
	{
		//create the vehicles and the units that go into it
		private _veh = createVehicle [_vehicleClassname, _spawnPos, [], 5, "FLY"];
		_vehicles pushBack _veh;
		while {true} do
		{
			//have the units target the player
			private _unit = _group createUnit [_unitClassname, _spawnPos, [], 0, "NONE"];
			private _success = _unit moveInAny _veh;
			if (_success) then
			{
				_unit setSkill _skill;
				_unit commandTarget _caller;
				_squad pushBack _unit;
			}
			else
			{
				deleteVehicle _unit;
				break;
			};
		};
	};
};

//wait until the player is dead, outside the battlegrounds or all units from this wave are dead
waitUntil {
	sleep 1;
	((!alive _caller) or 
	 ({ alive _x } count units _group == 0) or 
	 ((_caller distance2D _target) > BATTLEGROUND_RADIUS * 1.5)
	);
};

//when they are notify everyone and cleanup
if (alive _caller) then
{
	_caller globalChat "I have eliminated one battleground enemy wave.";
}
else
{
	_caller globalChat "I died. My battleground location has been cleaned up.";
};

{
	deleteVehicle _x;
} forEach _vehicles + _squad;
deleteMarker _marker;
