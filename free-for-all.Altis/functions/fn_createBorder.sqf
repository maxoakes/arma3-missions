/*
	Author: Scouter

	Description:
		Gives the player a random weapon with random attachments.
		Built to be called via addAction.

	Parameter(s):
		0: Position - (required) Center of circle that the borders indicate
		1: Number - (required) radius of border area
		2: Array of Strings - (required) Array of Classnames that will be randomly selected as a border segment
		3: Number - (required) Spacing in meters between the center of each segment
		4: Number - (optional) Rotation of each border object relative to how it should be positioned
		5: Number - (optional) vertical offset in meters above ground level
	Returns:
		Array of Objects
*/
params ["_center", "_radius", "_objects", "_spacing", ["_relativeDir", 0], ["_verticalOffset", 0]];

private _count = round ((2 * 3.14592653589793 * _radius) / _spacing);
private _step = 360 / _count;
private _angle = 0;
private _borderObjects = [];
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
	_borderObjects pushBack _post;
};

//return
_borderObjects;