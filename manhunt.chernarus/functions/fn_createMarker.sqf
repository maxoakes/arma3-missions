/*
	Author: Scouter

	Description:
		create a marker using several parameters
		
	Parameter(s):
		0: String - (required) variable name of the marker
		1: Position - (required) position of the marker
		2: String - (optional) the text that is visible to the user (optional)
		3: Array of Numbers - (optional) size of the marker. Only two entries.
		4: String - (optional) Color of the marker
		5: String - (optional) Shape of the marker. Can be "ELLIPSE", "RECTANGLE", "ICON"
		6: String - (optional) how the icon looks. Varies by the shape of the marker
		7: Number - (optional) direction of the marker between 0 and 360
		8: Number - (optional) alpha between 0 and 1

	Returns:
		Marker - the marker that was created
*/
params ["_name", "_pos", ["_text", ""], ["_size", [1,1]], ["_color", "ColorBlack"], ["_shape", "ICON"], ["_style", "mil_marker"], ["_dir", 0], ["_alpha", 1]];

private _marker = createMarker [_name, _pos];
_marker setMarkerColor _color;
_marker setMarkerSize _size;
_marker setMarkerText _text;
_marker setMarkerShape _shape;
_marker setMarkerDir _dir;
_marker setMarkerAlpha _alpha;

if (_shape == "ICON") then
{
	_marker setMarkerType _style;
}
else
{
	_marker setMarkerBrush _style;
};

//return
_marker;