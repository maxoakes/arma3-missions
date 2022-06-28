//GLOBAL VARABLES, PARAM INITS
setDate [2018, 3, 30, ("Time" call BIS_fnc_getParamValue), 0];
0 setFog ("Fog" call BIS_fnc_getParamValue)/100;
0 setOvercast ("Clouds" call BIS_fnc_getParamValue)/100;
0 setRain ("Rain" call BIS_fnc_getParamValue)/100;

if (rain > 0.5) then {0 setLightnings rain};
forceWeatherChange;
radius = "Size" call BIS_fnc_getParamValue;
numberVehiclesParam = "Vehicles" call BIS_fnc_getParamValue;

killZone = true;
if (radius > 500) then {killZone = false;};

carePackageActiveTime = 240;
carePackageWarningTime = 15;
carePackageDelay = 60;
cannonWaveTime = 300;
crateMultiplier = 1;

siteID = "LocationCenter" call BIS_fnc_getParamValue;
respawnPoints = ["respawn_guerrila"];
centerMarker = "center";

borderObject = "Land_City2_4m_F"; //"Sign_Sphere25cm_F"
_distanceBetweenPosts = 3.5; //radius/50
_borderElev = 0;

boxObjectType = "Box_NATO_Ammo_F";
carePackageTimerObject = "Sign_Circle_F";
crateContainerType = "C_IDAP_supplyCrate_F";
airstrikeTypeBomb = "Bo_GBU12_LGB";
airstrikeTypePilot = "B_Pilot_F";
airsrikeTypePlane = "B_Plane_Fighter_01_F";

defaultHandgun = "hgun_Rook40_F";
defaultHandgunMag = "16Rnd_9x21_Mag";
spawnVestPool = ["V_Chestrig_oli","V_Rangemaster_belt","V_BandollierB_khk","V_TacVestIR_blk",
"V_TacVest_blk","V_TacVest_brn","V_TacVest_camo","V_TacVest_khk","V_TacVest_oli",
"V_I_G_resistanceLeader_F","V_TacVest_gen_F","V_TacVest_blk_POLICE","V_Press_F"];

dlcs = [571710,395180];
spawnPool = [];
pistolPool = [];
vehPool = [];
cratePool = [];
attachmentPool = [];
bagPool = [];

ghilliePool = ["U_I_GhillieSuit","U_I_FullGhillie_lsh","U_I_FullGhillie_ard"];
vestPool = ["V_PlateCarrierL_CTRG","V_PlateCarrierIAGL_dgtl","V_PlateCarrierIAGL_oli",
"V_PlateCarrierIA2_dgtl","V_PlateCarrier2_blk","V_PlateCarrierH_CTRG",
"V_PlateCarrierSpec_rgr","V_PlateCarrierSpec_mtp"];

helmetPool = ["H_HelmetSpecO_blk","H_HelmetSpecO_ghex_F","H_HelmetSpecO_ocamo","H_HelmetSpecB",
"H_HelmetSpecB_blk","H_HelmetSpecB_paint2","H_HelmetSpecB_paint1","H_HelmetSpecB_sandH_HelmetSpecB_snakeskin",
"H_HelmetB_Enh_tna_F","H_HelmetLeaderO_ghex_F","H_HelmetLeaderO_ocamo","H_HelmetLeaderO_oucamo","H_HelmetO_ViperSP_ghex_F","H_HelmetO_ViperSP_hex_F"];

//SET LOCATION
if (isServer) then
{
	if (siteID == -1) then
	{
		_allBuildingsOnMap = nearestObjects [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), ["House", "Building"], worldSize/1.5];
		_randomLocation = getPos (_allBuildingsOnMap select (random count _allBuildingsOnMap));
		//_randomLocation = [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), 0, worldSize/2, 15, 0, .3, 0] call BIS_fnc_findSafePos;
		centerMarker setMarkerPos _randomLocation;
	}
	else
	{
		centerMarker setMarkerPos getMarkerPos (format ["site_%1",siteID]);
	};
	centerMarker setMarkerSize [radius, radius];
	"respawn_guerrila" setMarkerPos (getMarkerPos centerMarker);
};

listInit = [] spawn
{
	_vehicleList = (configFile >> "cfgVehicles") call BIS_fnc_getCfgSubClasses;
	_weaponList = (configFile >> "cfgWeapons") call BIS_fnc_getCfgSubClasses;

	_spawnTypes = ["AssaultRifle","Shotgun","SubmachineGun"];
	_crateTypes = ["AssaultRifle","MachineGun","SniperRifle","Rifle","MissileLauncher","RocketLauncher"];
	_attchmentTypes = ["AccessoryMuzzle","AccessorySights","AccessoryBipod"];
	_bagTypes = ["Backpack"];
	
	_vehicleTypes = ["Car","Motorcycle"];
	if (radius >= 750) then {_vehicleTypes append ["Helicopter"];};
	if (radius >= 1000) then {_vehicleTypes append ["WheeledAPC","TrackedAPC","Tank"];};

	//FOR VEHICLE LIST
	{
		if (getnumber (configFile >> "cfgVehicles" >> _x >> "scope") > 1) then {
			_objectType = _x call BIS_fnc_objectType;
			if (((_objectType select 0) == "Vehicle") && ((_objectType select 1) in _vehicleTypes)) then
			{
				if (!(_x in vehPool)) then
				{
					vehPool pushBack _x;
				};
			};
		};
	} foreach _vehicleList;

	//FOR CRATE AND SPAWN WEAPON LISTS
	{
		if (getnumber (configFile >> "cfgWeapons" >> _x >> "scope") > 1) then {
			_itemType = _x call bis_fnc_itemType;
			if (((_itemType select 0) == "Weapon") && ((_itemType select 1) in _crateTypes)) then
			{
				if (!(_x in cratePool)) then
				{
					cratePool pushBack _x;
				};
			};
			if (((_itemType select 0) == "Weapon") && ((_itemType select 1) in _spawnTypes) && (_x find "_srifle" == -1)) then
			{
				if (!(_x in spawnPool)) then
				{
					spawnPool pushBack _x;
				};
			};
			if (((_itemType select 0) == "Weapon") && ((_itemType select 1) == "Handgun")) then
			{
				if (!(_x in spawnPool)) then
				{
					pistolPool pushBack _x;
				};
			};
		};
	} foreach _weaponList;

	//FOR ATTACHMENTS
	//get list of attachments
	{
		if (getnumber (configFile >> "cfgWeapons" >> _x >> "scope") > 1) then {
			_itemType = _x call bis_fnc_itemType;
			if (((_itemType select 0) == "Item") && ((_itemType select 1) in _attchmentTypes)) then
			{
				attachmentPool pushBack _x;
			};
		};
	} foreach _weaponList;

	//FOR PERSONAL BAGS
	{
		_capacity = getnumber (configFile >> "cfgVehicles" >> _x >> "maximumLoad");
		if (getnumber (configFile >> "cfgVehicles" >> _x >> "scope") > 0) then {
			_itemType = _x call bis_fnc_itemType;
			if (((_itemType select 1) in _bagTypes) and _capacity >= 200) then
			{
				bagPool pushBack _x;
			};
		};
	} foreach _vehicleList;
};
//background tasks
currentVehicleCount = 0;
if (isServer) then {

	//MOVE ALL INIT POSITIONS TO PLAY ZONE
	_maxPlayers = (count playableUnits);
	_step = 360/_maxPlayers;
	_angle = 0;
	for "_x" from 0 to _maxPlayers-1 do
	{
		_dist = radius/1.1;
		_a = ((getMarkerPos centerMarker) select 0)+(sin(_angle)*_dist);
		_b = ((getMarkerPos centerMarker) select 1)+(cos(_angle)*_dist);
		_angle = _angle + _step;
		(playableUnits select _x) setPos [_a,_b];
		(playableUnits select _x) setDir _angle+180;
	};

	//CREATE BORDER
	_borderCount = round((2 * 3.14592653589793 * radius) / _distanceBetweenPosts);
	_step = 360/_borderCount;
	_angle = 0;
	for "_x" from 0 to _borderCount do
	{
		_a = ((getMarkerPos centerMarker) select 0)+(sin(_angle)*radius);
		_b = ((getMarkerPos centerMarker) select 1)+(cos(_angle)*radius);

		_pos = [_a,_b,_borderElev];
		_angle = _angle + _step;
		
		_post = createVehicle [borderObject,_pos,[],0,"CAN_COLLIDE"];
		_post setDir _angle;
		_post allowDamage false;
	};

	if (killZone) then {
		_zone = createTrigger ["EmptyDetector", getMarkerPos centerMarker];
		_zone setTriggerArea [radius+1, radius+1, 0, false];
		_zone setTriggerActivation ["ANY", "PRESENT", true];
		_zone setTriggerStatements ["not(vehicle player in thislist)", "player setDamage 1", ""];
	};

	[] execVM "tasks\carePackage.sqf";
	[] spawn
	{
		while {true} do
		{
			for "_i" from 1 to (count allPlayers)*crateMultiplier do
			{
				sleep 1;
				[] execVM "tasks\itemCannon.sqf";
			};
			sleep cannonWaveTime;
		};
	};
	[] spawn
	{
		while {true} do
		{
			while {currentVehicleCount < numberVehiclesParam} do {_v = [] execVM "spawnVehicle.sqf"; waitUntil {scriptDone _v};};
			systemChat format ["Spawned vehicles to limit: %1 of %2.",currentVehicleCount,numberVehiclesParam];
			waitUntil{currentVehicleCount < numberVehiclesParam};
		};
	};
};

[] execVM "tasks\carePackageActions.sqf";

waitUntil{BIS_fnc_init};