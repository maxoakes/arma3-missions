params ["_input"];

private _startTime = diag_tickTime;
private _reduced = _input;
private _i = 2;
private _factors = [];
while {_i <= ceil (_input/2)} do
{
	if (_reduced mod _i == 0) then
	{
		//input is a factor of _i
		_factors pushBack _i;
		_reduced = _reduced / _i;
		_i = 2;
	}
	else
	{
		_i = _i + 1;
	};
};

private _stopTime = diag_tickTime;
(format ["Prime factorization of %1 took %2 sec to complete, returning %3.", _input, _stopTime - _startTime, _factors]) remoteExec ["systemChat", 0];
_factors;