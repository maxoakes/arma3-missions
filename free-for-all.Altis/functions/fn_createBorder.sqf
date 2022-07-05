//create a border around a location using the params
//returns nothing
//modified from original (last_armory.Stratis). removed exits, added vertical offset
params ["_center", "_radius", "_objects", "_spacing", "_relativeDir", "_verticalOffset"];

private _count = round ((2 * 3.14592653589793 * _radius) / _spacing);
private _step = 360 / _count;
private _angle = 0;
for "_i" from 0 to (_count - 1) do
{
	private _pos = [
		(_center select 0) + (sin(_angle)* _radius),
		(_center select 1) + (cos(_angle)* _radius),
		(_center select 2) + _verticalOffset
	];

	private _post = createVehicle [selectRandom _objects, _pos, [], 0, "CAN_COLLIDE"];
	_post setDir _angle + _relativeDir;
	_post allowDamage false;
	_angle = _angle + _step;
};