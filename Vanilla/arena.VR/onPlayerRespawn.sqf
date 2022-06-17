params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

_newUnit enableStamina false;

if (side _newUnit == west) then
{
	_newUnit addUniform "U_B_Protagonist_VR";
}
else
{
	_newUnit addUniform "U_O_Protagonist_VR";
};

private _isDayTime = call fn_isDayTime;
private _primaryMags = [primaryWeapon _newUnit, !_isDayTime] call fn_getRoundsForWeapon;
private _handgunMags = [handgunWeapon _newUnit, !_isDayTime] call fn_getRoundsForWeapon;

private _selectedPrimaryMag = selectRandom _primaryMags;
_newUnit addPrimaryWeaponItem _selectedPrimaryMag;
for "_i" from 1 to 4 do {
	_newUnit addMagazine _selectedPrimaryMag;
	sleep 0.1;
};

private _selectedHandgunMag = selectRandom _handgunMags;
for "_j" from 1 to 3 do {
	_newUnit addMagazine _selectedHandgunMag;
	sleep 0.1;
};

private _smokeType = "SmokeShellBlue";
if (side _newUnit == east) then
{
	_smokeType = "SmokeShellRed";
};

for "_k" from 1 to 2 do {
	_newUnit addMagazine _smokeType;
};

{
	_newUnit addItem _x;
	_newUnit assignItem _x;
} foreach ["ItemCompass", "ItemWatch"];