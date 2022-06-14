_thePlayer = (_this select 1);
_set = (_this select 3) select 0;
_loc = (_this select 3) select 1;
_pos = getMarkerPos "respawn_west";

if (_set) then 
{
	_pos = [getPos _loc, 0, maxDistFromArea, 5, 0, maxGradient, 0] call BIS_fnc_findSafePos;
	hint format ["Teleporting to %1...\nPlease wait.",text(_loc)];
}
else
{
	_pos = [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), 0, worldSize/2, 12, 0, maxGradient, 0, blackListedMarkers] call BIS_fnc_findSafePos;
	_nearLoc = nearestLocations[_pos,["NameVillage","NameCity","NameCityCapital","NameLocal"],1000];
	if (count _nearLoc == 0) then
	{
		hint "Teleporting to bumfuck nowhere...\nPlease wait.";
	}
	else
	{
		hint format ["Teleporting to somewhere near %1...\nPlease wait.",text (_nearLoc select 0)];
	};
};

if ((_pos select 0 == 0) and (_pos select 1 == 0)) exitWith {hint "No safe destination found there.";};
_start = createVehicle [battlegroundCenterObject, _pos, [], 0, "CAN_COLLIDE"];
_start setVectorUp [0,0,1];
_start allowDamage false;

_randomName = format ["%1",floor random 999999];
_markerPhone = createMarker [ format ["x%1", _randomName], _pos];
_markerPhone setMarkerShape "ICON";
_markerPhone setMarkerText format ["%1's Battleground Center",name _thePlayer];
_markerPhone setMarkerType "mil_flag";
_markerPhone setMarkerColor "ColorBlue";

player setPos [(_pos select 0),(_pos select 1)-2];

//dynamic markers
_markerManager = [_pos,_randomName,_thePlayer] spawn
{
	//create markers

	_marker1 = createMarker [ format ["m%1", _this select 1], _this select 0];
	_marker1 setMarkerShape "ICON";
	_marker1 setMarkerText format ["%1",name (_this select 2)];
	_marker1 setMarkerType "mil_destroy";
	_marker1 setMarkerColor "ColorRed";

	_marker2 = createMarker [ format ["c%1", _this select 1], _this select 0];
	_marker2 setMarkerShape "ELLIPSE";
	_marker2 setMarkerBrush "Border";
	_marker2 setMarkerColor "ColorRed";
	_marker2 setMarkerSize [maxSpawnDistance,maxSpawnDistance];
	
	while {(alive (_this select 2)) and ((_this select 2) distance2D spawnCenter > 10)} do
	{
		_marker1 setMarkerPos getPos (_this select 2);
		_marker2 setMarkerPos getPos (_this select 2);
		sleep 0.5;
	};
	deleteMarker _marker1;
	deleteMarker _marker2;
};

_start addAction ["<t color='#00ff00'>I am done. Go back to base.","removeAllActions (_this select 0);"];
_start addAction ["<t color='#ffffff'>Spawn Squad","target\spawnTargets.sqf",["Squad",0.2,4]];
_start addAction ["<t color='#ffffff'>Spawn Horde","target\spawnTargets.sqf",["Horde",0.05,10]];
_start addAction ["<t color='#ffffff'>Spawn Snipers","target\spawnTargets.sqf",["Snipers",0.5,2]];
_start addAction ["<t color='#ffffff'>Spawn Single Aimbot","target\spawnTargets.sqf",["Aimbot",1.0,1]];
_start addAction ["<t color='#ffffff'>Spawn Technicals","target\spawnTargets.sqf",["Technicals",0.15,2]];
_start addAction ["<t color='#ffffff'>Spawn Tank","target\spawnTargets.sqf",["Tank",0.2,1]];
_start addAction ["<t color='#ffffff'>Spawn Attack Helicopter","target\spawnTargets.sqf",["Helo",0.1,1]];
_start addAction ["<t color='#ffffff'>Spawn The DayZ Special","target\spawnTargets.sqf",["DayZ Special",0.2,1]];

_counter = _thePlayer spawn
{
	//_sense = _this addAction ["<t color='#ff0000'>Sense nearest enemy","target\sense.sqf",[],10,false,false];
	_return = _this addAction ["<t color='#ff0000'>Return to center point",
	"
		_home = getPos (nearestObjects [(_this select 1),[battlegroundCenterObject],maxSpawnDistance] select 0);
		(_this select 1) setPos [(_home select 0), ((_home select 1)-2)];
	",[],10,false,false];
	
	while {(alive _this) and (_this distance2D (getMarkerPos "respawn_west") > 10)} do
	{
		_countU = 0;
		_countV = 0;
		{
			if ((side _x == east) and (alive _x) and (_x isKindOf "Man")) then
			{
				_countU = _countU + 1;
			};
			if ((_x isKindOf "Car") or (_x isKindOf "Tank") or (_x isKindOf "Helicopter")) then
			{
				_countV = _countV + 1;
			};
		} foreach (nearestObjects [_this, ["Man","Car","Tank","Helicopter"], maxSpawnDistance]);
		hint format ["Enemies remaining: %1\n Vehicles remaining: %2", _countU,_countV];
		sleep 0.5;
	};
	hint "";
	_this removeAction _return;
	//_this removeAction _sense;
};

//clean up
waitUntil { (not alive _thePlayer) or (count actionIDs _start == 0)};

deleteVehicle _start;
deleteMarker _markerPhone;

if (alive _thePlayer) then {_thePlayer setPos spawnCenter;};