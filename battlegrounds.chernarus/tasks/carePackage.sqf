waitUntil { scriptDone listInit };

while {true} do
{
	sleep carePackageDelay;
	_loc = [getMarkerPos centerMarker, 0, ((getMarkerSize centerMarker) select 0), 8, 0, .2, 0] call BIS_fnc_findSafePos;
	_loc append [5];
	
	_care = nil;
	if (not (_loc select 0 == 0))then
	{
		//CREATE CRATE
		_care = createVehicle [crateContainerType, _loc, [], 0, "NONE"];
		_care setDir random 360;
		_care allowDamage false;
		_care setVectorUp surfaceNormal position _care;
		
		//CREATE INVENTORY
		clearWeaponCargoGlobal _care;
		clearMagazineCargoGlobal _care;
		clearBackpackCargoGlobal _care;
		clearItemCargoGlobal _care;

		for "_i" from 1 to 3 do {
			_w = cratePool select (random floor count cratePool);
			
			_care addWeaponCargoGlobal[_w, 1];
			_mags = (getArray (configFile >> "CfgWeapons" >> _w >> "magazines"));
			for "_j" from 1 to 3 do
			{
				_care addMagazineCargoGlobal[_mags select floor (random (count _mags)), 2];
			};
			for "_k" from 1 to 3 do
			{
				_care addItemCargoGlobal [attachmentPool select floor (random (count attachmentPool)), 1];
			};
		};
		for "_j" from 1 to 2 do
		{
			_bag = bagPool select (random (floor count bagPool));
			_care addBackpackCargoGlobal [_bag,1];
			_care addItemCargoGlobal [(helmetPool select (random (floor count helmetPool))),1];

		};
		_care addItemCargoGlobal [(ghilliePool select (random (floor count ghilliePool))),1];
		_care addItemCargoGlobal [(vestPool select (random (floor count vestPool))),1];
		_care addItemCargoGlobal ["NVGoggles_INDEP", 1];
		
		//MAKE MARKER
		_carePackageMarker = createMarker ["pack", getPos _care];
		_carePackageMarker setMarkerType "mil_Destroy";
		_carePackageMarker setMarkerColor "ColorRed";
		_carePackageMarker setMarkerText "Care Package";
		
		//MAKE VISUALS
		_smoke = createVehicle ["SmokeShellRed", getPos _care, [], 0, "CAN_COLLIDE"];
		_flare = createVehicle ["F_40mm_Red", [getPos _care select 0, getPos _care select 1, 50], [], 0, "CAN_COLLIDE"];
		
		_ring = createVehicle [carePackageTimerObject, [getPos _care select 0, getPos _care select 1, -5], [], 0, "CAN_COLLIDE"];
		systemChat "A care package as spawned!";
		for "_x" from carePackageActiveTime*4 to 3 step -1 do{
			_ring attachTo [_care,[0,0,_x]];
			_ring setVectorDirAndUp [[0,0,-1],[0,1,0]];
			sleep 0.25;
		};
		
		//END SEQUENCE
		_alarm = createSoundSource ["Sound_Alarm", position _care, [], 0];
		sleep carePackageWarningTime;
		
		deleteVehicle _care;
		deleteVehicle _ring;
		deleteMarker _carePackageMarker;
		deleteVehicle _alarm;
		_boom = airstrikeTypeBomb createVehicle _loc;
	};
};

