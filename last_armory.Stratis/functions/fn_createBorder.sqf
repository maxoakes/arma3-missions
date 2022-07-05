//create a border around a location using the params
//returns nothing
params ["_center", "_radius", "_objects", "_spacing", "_relativeDir", "_makeExits"];

private _count = round ((2 * 3.14592653589793 * _radius) / _spacing);
private _step = 360 / _count;
private _angle = 0;
private _factors = [_count] call compile preprocessFile "functions\fn_getPrimeFactorization.sqf";
private _largestFactor = 0;
if (count _factors != 0) then
{
	_largestFactor = _factors select ((count _factors) - 1);
};
for "_i" from 0 to (_count - 1) do
{
	private _pos = [
		(_center select 0) + (sin(_angle)* _radius),
		(_center select 1) + (cos(_angle)* _radius),
		(_center select 2) + 0
	];

	if (_makeExits) then
	{
		if (count _factors == 0) then
		{
			if (_i == 0) then
			{
				_angle = _angle + _step;
				continue;
			};
		}
		else
		{
			if (_i mod (_largestFactor) == 0) then
			{
				//skip every n objects OR if it is a prime number, remove only the front object
				_angle = _angle + _step;
				continue;
			};
		};
	};
	private _post = createVehicle [selectRandom _objects, _pos, [], 0, "CAN_COLLIDE"];
	_post setDir _angle + _relativeDir;
	_post allowDamage false;
	_angle = _angle + _step;
};