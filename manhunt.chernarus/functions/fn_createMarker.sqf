/*
	Author: Scouter

	Description:
		create a marker using several parameters
		
	Parameter(s):
		0: String - variable name of the marker
		1: Position - position of the marker
		2: String - the text that is visible to the user
		3: Array of Numbers - size of the marker. Only two entries.
		4: String - Color of the marker
		5: String - Shape of the marker. Can be "ELLIPSE", "RECTANGLE", "ICON"
		6: String - how the icon looks. Varies by the shape of the marker
		7: Number - direction of the marker between 0 and 360
		8: Number - alpha between 0 and 1

	Returns:
		Marker - the marker that was created
*/
params ["_name", "_pos", "_text", "_size", "_color", "_shape", "_style", "_dir", "_alpha"];

private _marker = createMarker [_name, _pos];
_marker setMarkerColor _color;
_marker setMarkerSize _size;
_marker setMarkerText _text;
_marker setMarkerShape _shape;

if (_shape == "ICON") then
{
	_marker setMarkerType _style;
}
else
{
	_marker setMarkerBrush _style;
};

if (!isNil "_dir") then
{
	_marker setMarkerDir _dir;
};
if (!isNil "_alpha") then
{
	_marker setMarkerAlpha _alpha;
};

//return
_marker;