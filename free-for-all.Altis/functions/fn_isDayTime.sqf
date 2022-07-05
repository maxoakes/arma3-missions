//check if the mission is currently day time
//returns boolean
private _isDayTime = true;
if (dayTime < 6 or dayTime > 18) then
{
	_isDayTime = false;
};
_isDayTime;