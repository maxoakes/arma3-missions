//get a list of the possible mags for the input weapon. If it is night, find all of the tracer mags
//returns array of strings that contain magazine classnames
params ["_weaponClassname", "_isTracer"];
private _availableMags = getArray (configfile >> "CfgWeapons" >> _weaponClassname >> "magazines");
private _returnMags = [];

if (_isTracer) then
{
	{
		//find all mags that are tracers
		if (("tracer" in toLower getText (configFile >> "CfgMagazines" >> _x >> "displayName")) or ("tracer" in toLower _x)) then
		{
			//add them to the list that is returned
			_returnMags pushBack _x;
		};
	} forEach _availableMags;

	//if there are no mags with tracers, just use the first mag listed for the weapon
	if (count _returnMags isEqualTo 0) then
	{
		_returnMags pushBack (_availableMags select 0);
	};
}
else
{
	//if we are not looking for tracers, just use the first ammo type of that weapon
	_returnMags pushBack (_availableMags select 0);
};
_returnMags;