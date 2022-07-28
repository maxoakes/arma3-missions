/*
	Author: Scouter

	Description:
		Takes in some data and returns a boolean that the input represents

	Parameter(s):
		0: Anything - Only Numbers and strings are interpeted correctly.

	Returns:
		Boolean
*/
params ["_input"];
private _result = false;

//only change if the input evaluates to true
switch (typeName _input) do
{
	case "SCALAR":
	{
		if (_input != 0) then
		{
			_result = true;
		};
	};
	case "STRING":
	{
		if (toLower _input == "true" or toLower _input == "t") then
		{
			_result = true;
		};
	};
	case "BOOL":
	{
		_result = _input;
	};
	default
	{
		throw format ["Type %1 cannot be casted to Boolean", typeName _input];
	};
};
_result;