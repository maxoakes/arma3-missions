//create a marker given many parameters
//return the created marker
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