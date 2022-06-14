_list = player nearEntities [["Man", "Air", "Car", "Motorcycle", "Tank"], maxSpawnDistance*4];
_nearest = (_list select {side _x == east}) select 0;
//_nearest = player findNearestEnemy getPos player;

if (!(isNil "_nearest")) then
{
	_angle = [player, _nearest] call BIS_fnc_dirTo;
	_distance = player distance _nearest;
	
	if (_distance > maxSpawnDistance*2) then
	{
		player groupChat format ["I sense someone more than %1 meters away.", 100 * round (_distance/100)];
	}
	else
	{
		player groupChat format ["I sense someone %1 meters away at my %2.", 10 * round (_distance/10), 10 * round (_angle/10)];
	};
}
else
{
	player groupChat "I sense nobody in the area.";
};