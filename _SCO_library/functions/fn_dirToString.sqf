params ["_dir"];

private _directions = [];
for "_i" from 0 to 16 do
{
	_directions pushBack (_i*22.5);
};
private _closest = [_directions, _dir] call BIS_fnc_nearestNum;
if (_closest == _directions select 0) exitWith {"N"};
if (_closest == _directions select 1) exitWith {"NNE"};
if (_closest == _directions select 2) exitWith {"NE"};
if (_closest == _directions select 3) exitWith {"ENE"};
if (_closest == _directions select 4) exitWith {"E"};
if (_closest == _directions select 5) exitWith {"ESE"};
if (_closest == _directions select 6) exitWith {"SE"};
if (_closest == _directions select 7) exitWith {"SSE"};
if (_closest == _directions select 8) exitWith {"S"};
if (_closest == _directions select 9) exitWith {"SSW"};
if (_closest == _directions select 10) exitWith {"SW"};
if (_closest == _directions select 11) exitWith {"WSW"};
if (_closest == _directions select 12) exitWith {"W"};
if (_closest == _directions select 13) exitWith {"WNW"};
if (_closest == _directions select 14) exitWith {"NW"};
if (_closest == _directions select 15) exitWith {"NNW"};
if (_closest == _directions select 16) exitWith {"N"};