while {true} do {
	if ((getMarkerPos "pack" select 0) != 0) then
	{
		package = nearestObject [getMarkerPos "pack", crateContainerType];
		addActionBomb = package addAction ["Send airstrike","crate\airstrike.sqf"];
		addActionAmmo = package addAction ["Fill Inventory with Rifle Ammo","crate\fillAmmo.sqf"];
	};
	waitUntil {((getMarkerPos "pack") select 0) == 0};
	sleep 5;
};