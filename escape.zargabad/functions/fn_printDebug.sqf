params ["_string"];
private _isDebug = [("Debug" call BIS_fnc_getParamValue)] call SCO_fnc_parseBoolean;
if (_isDebug or is3DENPreview) then
{
	if (_isDebug) then
	{
		_string = "DEBUG:= " + _string;
	}
	else
	{
		if (is3DENPreview) then
		{
			_string = "3DEN:= " + _string;
		}
	};
	_string remoteExec ["systemChat", 0];
};
diag_log format ["SCO_fnc_printDebug =: %1", _string];