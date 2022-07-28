/*
	Author: Scouter

	Description:
		Returns true if it is 'daytime', false if 'night time'

	Parameter(s):
		0: Number - (optional) hour of start of day
		1: Number - (optional) hour of start of night

	Returns:
		Boolean
*/
params [["_day", 6], ["_night", 18]];
private _isDayTime = true;
systemChat format ["day:%1, night:%2", _day, _night];
if (dayTime < _day or dayTime > _night) then
{
	_isDayTime = false;
};

//return
_isDayTime;