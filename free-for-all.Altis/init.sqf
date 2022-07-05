//weather settings
setDate [2018, 3, 30, ("Time" call BIS_fnc_getParamValue), 0];
0 setOvercast ("Clouds" call BIS_fnc_getParamValue)/100;
0 setFog ("Fog" call BIS_fnc_getParamValue)/100;
0 setRain ("Rain" call BIS_fnc_getParamValue)/100;
forceWeatherChange;

//needed on all clients so the trigger can be created for everyone
//get the specified location from the parameters
private _loc_id = "LocationCenter" call BIS_fnc_getParamValue;
private _arenaCenterPos =  getMarkerPos format ["site_%1", _loc_id];
private _arenaRadius = (getMarkerSize format ["site_%1", _loc_id]) select 0;

//create trigger to kill those outside of area
private _zone = createTrigger ["EmptyDetector", _arenaCenterPos];
_zone setTriggerArea [_arenaRadius+1, _arenaRadius+1, 0, false];
_zone setTriggerActivation ["ANY", "PRESENT", true];
_zone setTriggerStatements [
	"not(vehicle player in thislist)", 
	"vehicle player setDamage 1", 
	"hint 'Do not leave the play area.'"];

if (isServer) then
{
	//create the respawn inventories
	{
		[independent, _x] call BIS_fnc_addRespawnInventory;
	} foreach ["Light1", "Light2", "Light3", "Medium1", "Medium2", "Medium3"];

	//create the physical border of the spawn area
	[
		_arenaCenterPos, //center of border circle
		_arenaRadius, //radius
		["Sign_Sphere100cm_F"], //what can be the border be made of
		3, //distance between objects
		0, //relative rotation of the objects
		1 //vertical offset
	] call compile preprocessFile "functions\fn_createBorder.sqf";

	//create the random respawn markers
	private _respawnMarkers = [];
	//at most 10, at least 3. follows trend of the arena's radius
	private _numRespawnMarkers = ((ceil (_arenaRadius/100)) min 10) max 3; 
	for "_i" from 1 to _numRespawnMarkers do
	{
		private _respawnAreaRadius = _arenaRadius/5;
		private _safePos = [
			_arenaCenterPos, 
			0, _arenaRadius - _respawnAreaRadius, 1, 
			0, 0.7, 0,
			_respawnMarkers,
			[_arenaCenterPos, _arenaCenterPos]] call BIS_fnc_findSafePos;

		private _marker = [
			format ["respawn_guerrila_%1", _i], //var name
			_safePos, //position
			format ["Respawn %1", _i], //display name
			[_respawnAreaRadius, _respawnAreaRadius], //size
			"ColorGreen", //color string
			"ELLIPSE", //type
			"Border", //style
			0, //direction
			0 //alpha
		] call compile preprocessFile "functions\fn_createMarker.sqf";
		_respawnMarkers pushBack _marker;
	};

	//get all possible weapons that can spawn in vehicles
	private _arenaItems = [
		["Weapon", "Item", "Equipment", "Object"], 
		["AssaultRifle", "Handgun", "MachineGun", 
			"SubmachineGun", "SniperRifle", "Rifle", "Throw",
			"MissileLauncher", "RocketLauncher", "AccessoryMuzzle", 
			"AccessoryPointer", "AccessorySights", "AccessoryBipod",
			"Headgear", "Vest", "Uniform", "Backpack", "NVGoggles"]
	] call compile preprocessFile "functions\fn_getItemOfType.sqf";
	private _possibleWeapons = [];
	private _possibleAttachments = [];
	private _possibleEquipment = [];
	private _possibleBackpacks = []; //done in the vehicle list loop, since they are considered objects

	//unit used as a reference to check if a certain uniform is allowed
	private _g = createGroup [independent, true];
	private _refernceUnit = _g createUnit ["I_Survivor_F", _arenaCenterPos, [], 0, "NONE"];
	_refernceUnit allowDamage false;
	{
		if (_x call BIS_fnc_itemType select 0 == "Weapon") then 
		{
			_possibleWeapons pushBackUnique _x;
		};
		if (_x call BIS_fnc_itemType select 0 == "Item") then 
		{
			_possibleAttachments pushBackUnique _x;
		};
		if (_x call BIS_fnc_itemType select 0 == "Equipment") then 
		{
			if (_x call BIS_fnc_itemType select 1 == "Uniform") then
			{
				if (_refernceUnit isUniformAllowed _x) then
				{
					_possibleEquipment pushBackUnique _x;
				};
			}
			else
			{
				_possibleEquipment pushBackUnique _x;
			};
		};
	} forEach _arenaItems;
	deleteVehicle _refernceUnit;

	//get list of possible vehicles for the arena based on its size
	//also get the types of crates for the care package thread
	private _vehicleTypes = ["Car", "Motorcycle"];
	if (_arenaRadius >= 1000) then
	{
		_vehicleTypes append ["Helicopter"];
	};
	if (_arenaRadius >= 2000) then
	{
		_vehicleTypes append ["WheeledAPC", "TrackedAPC", "Tank"];
	};

	//build the list of vehicles and crates
	private _vehicleList = (configFile >> "cfgVehicles") call BIS_fnc_getCfgSubClasses;
	private _possibleVehicles = [];
	private _possibleCrates = [];
	{
		if (getnumber (configFile >> "cfgVehicles" >> _x >> "scope") > 1) then {
			private _objectType = _x call BIS_fnc_objectType;
			if (((_objectType select 0) == "Vehicle") && ((_objectType select 1) in _vehicleTypes)) then
			{
				_possibleVehicles pushBackUnique _x;
			};
			if (_objectType select 0 == "Object" and _objectType select 1 == "AmmoBox" and 
				(getNumber (configFile >> "cfgVehicles" >> _x >> "maximumLoad") > 3000) and
				(("box" in toLower _x ) or ("supplycrate" in toLower _x))) then
			{
				_possibleCrates pushBackUnique _x;
			};
			if ([["Object", "Backpack"], _objectType] call BIS_fnc_areEqual) then
			{
				_possibleBackpacks pushBackUnique _x;
			}
		};
	} foreach _vehicleList;

	//spawn vehicles and manage them in its own thread
	private _vehicleManager = [_arenaCenterPos, _arenaRadius, 
		_possibleWeapons, _possibleAttachments, _possibleEquipment, 
		_possibleBackpacks, _possibleVehicles] spawn
	{
		params ["_center", "_radius", "_weapons", "_attachments", "_equipment", "_backpacks", "_vehicles"];

		//spawn vehicles up to the cap
		private _arenaArea = 3.1416 * ((_radius/1000) ^ 2); //sq. km
		private _maxCount = (ceil _arenaArea) * ("Vehicles" call BIS_fnc_getParamValue);
		format ["Max number of active vehicles is %1.", _maxCount] remoteExec ["systemChat"];

		private _activeVehicles = [];
		while {true} do
		{
			sleep 0.1;
			if ({canMove _x} count _activeVehicles <= _maxCount) then
			{
				//get a safe location to spawn the vehicle
				private _safePos = [
					_center, 0, _radius, 10, 0, 0.5, 0, [], [_center, _center]
				] call BIS_fnc_findSafePos;
				private _newVehicle = createVehicle [selectRandom _vehicles, _safePos, [], 0, "NONE"];
				_newVehicle setDir random 360;
				clearItemCargoGlobal _newVehicle;

				//add random stuff to the vehicle
				private _possibleThings = _weapons + _attachments + _equipment;
				for "_i" from 1 to (ceil random [5, 6, 12]) do
				{
					//pick an item
					private _randomItem = selectRandom _possibleThings;
					if (!(_newVehicle canAdd _randomItem)) then {continue};
					private _type = _randomItem call BIS_fnc_itemType;
					if (_type select 0 == "Weapon") then
					{
						//if it is a weapon, pick a weapon and some random mags that it can take
						_newVehicle addWeaponCargoGlobal [_randomItem, 1];
						private _magArray = getArray (configfile >> "CfgWeapons" >> _randomItem >> "magazines");
						private _mag = selectRandom _magArray;
						if (!isNil "_mag") then
						{
							_newVehicle addMagazineCargo [_mag, 3];
						};			
					}
					else
					{
						//if it is an item, add one of that item
						_newVehicle addItemCargoGlobal [_randomItem, 1];
					};
				};

				//add some backpacks seperately, as they are not seen with BIS_fnc_itemType
				for "_i" from 1 to 2 do
				{
					private _randomItem = selectRandom _backpacks;
					_newVehicle addBackpackCargoGlobal [_randomItem, 1];
				};
				//if it is night time, add NVGs
				private _isDayTime = call compile preprocessFile "functions\fn_isDayTime.sqf";
				if (!_isDayTime) then
				{
					_newVehicle addItemCargoGlobal ["NVGoggles_INDEP", 2];
				};
				//add this vehicle to track them if they were to expire
				_activeVehicles pushBack _newVehicle;
			};
		};
	};

	//spawn a crate in the play area every so often
	private _crateManager = [_arenaCenterPos, _arenaRadius, _possibleCrates, _possibleAttachments, _possibleWeapons] spawn
	{
		params ["_center", "_radius", "_crates", "_attachments", "_weapons"];
		//get all possible crate objects
		private _crateRespawnTime = "CrateTimeBetween" call BIS_fnc_getParamValue;
		private _crateAliveTime = "CrateTimeAlive" call BIS_fnc_getParamValue;

		while {true} do
		{
			//for the rest of the game, await respawn time
			sleep _crateRespawnTime;
			//when a crate is ready, find a location
			private _safePos = [
				_center, 0, _radius, 10, 0, 0.5, 0, [], [_center, _center]
			] call BIS_fnc_findSafePos;

			//spawn introductory visuals and the crate
			private _crate = createVehicle [selectRandom _crates, _safePos, [], 0, "CAN_COLLIDE"];
			private _smoke = createVehicle ["SmokeShellGreen", [_safePos select 0, _safePos select 1, 2], [], 0, "CAN_COLLIDE"];
			private _flare = createVehicle ["F_40mm_Red", [_safePos select 0, _safePos select 1, 10], [], 0, "CAN_COLLIDE"];
			private _marker = [
				format ["crate%1", time], //var name
				_safePos, //position
				"Care Package", //display name
				[1, 1], //size
				"ColorRed", //color string
				"ICON", //type
				"mil_destroy" //style
			] call compile preprocessFile "functions\fn_createMarker.sqf";
			"A care package as spawned!" remoteExec ["systemChat"];

			//add things to the crate
			clearBackpackCargoGlobal _crate;
			clearItemCargoGlobal _crate;
			clearWeaponCargoGlobal _crate;
			clearMagazineCargoGlobal _crate;
			[_crate, ["Add Ammo for weapon in hand", "functions\fn_refillWeapon.sqf", 2, 4, true, true, "", "true", 5]] remoteExec ["addAction"];
			[_crate, ["Get a random primary weapon", "functions\fn_getRandomWeapon.sqf", nil, 1.5, true, true, "", "true", 5]] remoteExec ["addAction"];

			private _availableWeapons = [];
			{
				private _type = _x call BIS_fnc_itemType;
				if (_type select 1 in ["SniperRifle", "Throw", "MissileLauncher", "RocketLauncher"]) then
				{
					_availableWeapons pushBackUnique _x;
				}
			} forEach _weapons;
			for "_i" from 1 to (ceil random [4, 5, 10]) do
			{
				private _randomAttachment = selectRandom _attachments;
				_crate addItemCargoGlobal [_randomAttachment, 2];

				private _randomWeapon = selectRandom _availableWeapons;
				_crate addItemCargoGlobal [_randomWeapon, 1];
			};
			
			//wait for the crate to reach end-of-life
			sleep _crateAliveTime;

			//announce that the crate will be leaving
			"The care package is despawning! Get away from it!" remoteExec ["systemChat"];
			private _alarm = createSoundSource ["Sound_Alarm", _safePos, [], 0];
			sleep 10;

			//delete this instance
			deleteVehicle _smoke;
			deleteVehicle _flare;
			deleteVehicle _crate;
			deleteVehicle _alarm;
			deleteMarker _marker;
			private _explosion = "ammo_Bomb_SDB" createVehicle _safePos;
		};
	};
};