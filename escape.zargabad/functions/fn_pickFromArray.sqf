/*
	Author: Scouter

	Description:
		Given a number, return that many randomly selected from the given array.

	Parameter(s):
		0: Array
		1: Number of unqiue elements to pick

	Returns:
		Array of picked elements
*/
params ["_array", "_num"];

_temp = _array;
_output = [];

for "_i" from 0 to _num do
{
	private _randInd = floor(random (count _array));
	_output pushBackUnique (_temp select _randInd);
 	_temp deleteAt _randInd;
};

//return
_output;