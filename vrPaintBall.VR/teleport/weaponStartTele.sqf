_weapon = (_this select 3) select 0;
_ammo = (_this select 3) select 1;
_team = side player;

player addWeapon _weapon;
player addMagazine _ammo;
player addMagazine _ammo;
player addMagazine _ammo;
player addMagazine _ammo;
player addMagazine _ammo;
player addMagazine _ammo;
player addMagazine _ammo;
player addMagazine _ammo;

player addWeapon "hgun_Pistol_heavy_01_F";
player addMagazine "11Rnd_45ACP_Mag";
player addMagazine "11Rnd_45ACP_Mag";
player addMagazine "11Rnd_45ACP_Mag";
player addMagazine "11Rnd_45ACP_Mag";

player addItem "FirstAidKit";
player addItem "FirstAidKit";

player addMagazine "HandGrenade";
player addMagazine "HandGrenade";

if (_team == west) then
{
	player SetPos (getMarkerPos "blueTeam");
	player setDir 180;
	player addMagazine "SmokeShellBlue";
	player addMagazine "SmokeShellBlue";
	
};

if (_team == east) then
{
	player SetPos (getMarkerPos "redTeam");
	player setDir 315;
	player addMagazine "SmokeShellRed";
	player addMagazine "SmokeShellRed";
};

if (_team == resistance) then
{
	player SetPos (getMarkerPos "greenTeam");
	player setDir 45;
	player addMagazine "SmokeShellGreen";
	player addMagazine "SmokeShellGreen";
};