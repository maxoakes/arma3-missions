_group = createGroup [west, true];

t1 = createVehicle [evacVehicleType, getMarkerPos "evacStart", [], 10, "NONE"];
t1 allowDamage false;

d1 = _group createUnit [driverType, getMarkerPos "evacStart", [], 5, "NONE"];
g1 = _group createUnit [driverType, getMarkerPos "evacStart", [], 5, "NONE"];

d1 moveInDriver t1;
g1 moveInTurret [t1,[0]];
t1 lockDriver true;

_group setBehaviour "CARELESS";
_group move getMarkerPos "landing";

[[d1,"Hey guys! I will be your savior today! I will be at your location in a few seconds coming from the south. Meet me at the west gate of the compound."],"sidechat"] call BIS_fnc_MP;

//evac timer
[t1] spawn {
	waitUntil {!(alive (_this select 0))};
	["Shit, our extraction vehicle was destroyed! We need to find some other way to leave the city.","systemChat"] call BIS_fnc_MP;
};

waitUntil {(t1 distance2D getMarkerPos "landing" < 20)};
[[d1,"Stand back while I stop."],"sidechat"] call BIS_fnc_MP;
defenders = [];
{
	if (((side _x) == West) && (isPlayer _x)) then
	{
		defenders pushBack _x;
	};
} forEach allUnits;

[[d1,format ["I am waiting for %1 people to get in!", count defenders]],"sidechat"] call BIS_fnc_MP;
["We don't need to worry about OPFOR overrunning the compound anymore.","systemChat"] call BIS_fnc_MP;
waitUntil {{_x in crew t1} count defenders >= count defenders};

[[d1,"One of you guys can drive if you want."],"sidechat"] call BIS_fnc_MP;
t1 allowDamage true;
t1 lockDriver false;

_group move getMarkerPos "exit";
[[d1,"Everyone is in, time to go! We need to leave the city!"],"sidechat"] call BIS_fnc_MP;
waitUntil {sleep 5; _n = {(_x distance2D getMarkerPos "landing" < safeDist) and (side _x == west)} count allPlayers;_n == 0};

missionNamespace setVariable ["isDoneWin", true, true]; 