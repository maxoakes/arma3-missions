/*
	Author: Scouter

	Description:
		Get the prime factorization of a number. Basically an interview question.

	Parameter(s):
		0: Number - (required) 
	Returns:
		Array of Numbers
*/

params ["_input"];

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

//return
_factors;