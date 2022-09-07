params ["_marker"];

race_start allowDamage false;
private _centerPos = getMarkerPos _marker;
private _angle = markerDir _marker;
private _placementArray = [
	["Land_Cargo_HQ_V1_F",[0,0,-3.8754],0], //0 building
	["B_Slingload_01_Cargo_F",[-0.375,2.125,-0.749884],254.18], //1 slingload
	["Land_ClutterCutter_small_F",[4.5,0.75,-3.8754],0], //2 lobby center
	["MapBoard_stratis_F",[6.25293,3.25464,-3.27694],30.0032], //3 race object
	["Land_TripodScreen_01_dual_v1_black_F",[0.903564,2.11108,-3.27469],255.005], //4 utility
	["Land_PhoneBooth_01_malden_F",[-6.08203,-0.856934,-3.8754],90], //5 battleground
	["Land_MapBoard_Enoch_F",[-3.42603,2.30005,-3.27694],316.128], //6 sector control
	["Land_Camping_Light_F",[-0.0559082,0.5271,-2.39018],359.942],
	["Land_PortableCabinet_01_closed_black_F",[0.733154,0.630127,-2.94317],165.001],
	["Land_PortableDesk_01_black_F",[-0.0527344,1.44531,-3.27469],269.998],
	["Sign_Sphere10cm_F",[1.5,-1,-2.6254],0],
	["Land_PortableCabinet_01_bookcase_olive_F",[1.4043,0.24585,-3.27472],89.9947],
	["Land_PortableCabinet_01_closed_black_F",[0.717285,0.602783,-3.27472],179.999],
	["Sign_Sphere10cm_F",[1.5,-1.5,-2.6254],0],
	["Sign_Sphere10cm_F",[1.5,-2,-2.6254],0],
	["Land_DeskChair_01_black_F",[-0.606445,2.25317,-3.27473],359.994],
	["Sign_Sphere10cm_F",[1.5,-2.5,-2.6254],0],
	["Land_PlasticBarrier_01_line_x4_F",[2.04297,1.35645,-3.27373],90],
	["Land_WoodenCrate_01_stack_x5_F",[0.694092,3.51904,-3.27373],180],
	["Land_FoodSacks_01_cargo_white_idap_F",[-3.2334,-1.13599,-3.27473],90.0009],
	["Land_PaperBox_01_small_closed_brown_food_F",[-0.591797,3.53906,-2.85617],359.941],
	["Sign_Sphere10cm_F",[1.5,-3.5,-2.6254],0],
	["Land_PaperBox_01_small_closed_white_IDAP_F",[-0.485596,3.52173,-3.26565],358.919],
	["Land_Pallet_MilBoxes_F",[-1.79321,3.48291,-3.27373],270],
	["Land_PaperBox_01_small_closed_white_med_F",[-0.635742,4.06641,-2.86004],180.147],
	["Sign_Sphere10cm_F",[1.5,-4,-2.6254],0],
	["Land_PaperBox_01_small_closed_white_med_F",[-0.482666,4.01172,-3.27082],358.973],
	["CargoNet_01_box_F",[-1.625,-4.375,-3.27473],360],
	["Sign_Sphere10cm_F",[1.5,-4.5,-2.6254],0],
	["Land_CampingChair_V2_F",[-0.367432,-4.76416,-3.27473],179.995],
	["Land_CampingChair_V2_white_F",[0.486084,-4.75684,-3.27473],171.311],
	["FlexibleTank_01_forest_F",[-5.00342,0.108398,-3.15432],9.15505],
	["Land_PaperBox_01_small_closed_brown_IDAP_F",[-4.63623,1.47241,-3.15431],90.0012],
	["Land_PaperBox_01_small_closed_white_IDAP_F",[-4.82056,0.860107,-3.15431],0.00207918],
	["CargoNet_01_barrels_F",[-3.5481,3.61621,-3.27473],85.2629],
	["Land_PaperBox_01_small_closed_white_IDAP_F",[-4.99219,1.61426,-2.74444],0.0138714],
	["Sign_Sphere10cm_F",[1.5,-5,-2.6254],0],
	["Box_NATO_AmmoVeh_F",[-3.28345,-4.36621,-3.24418],0.000596176],
	["Land_PaperBox_01_small_closed_brown_F",[-5.125,1.5,-3.15431],269.996],
	["SignAd_Sponsor_ARMEX_F",[-4.75,3.25,-3.8754],90],
	["Land_PortableDesk_01_black_F",[-0.148438,-5.87207,-3.15428],359.999],
	["Land_KartStand_01_F",[4.05396,-4.60742,-3.27473],267.507],
	["Land_Trophy_01_bronze_F",[4,5.24976,-2.34327],0.000808725],
	["Land_Stretcher_01_olive_F",[-2.5564,-5.86499,-3.15431],89.9995],
	["Land_Trophy_01_silver_F",[4.5,5.25,-2.34329],359.998],
	["SignAd_Sponsor_Redstone_F",[-4.75,-4.75,-3.8754],90],
	["Land_KartTyre_01_x4_F",[5.33813,-4.11963,-3.28576],282.583],
	["Land_CampingTable_F",[4.5,5.25,-3.1569],359.997],
	["Land_Trophy_01_gold_F",[5,5.25,-2.3433],0.011044],
	["Land_KartTyre_01_x4_F",[5.32861,-4.69043,-3.28576],359.926],
	["Land_PlasticBarrier_01_line_x6_F",[4.18066,6.16211,-3.15331],0],
	["Land_PlasticBarrier_01_line_x2_F",[7.37109,0.723633,-3.27373],270],
	["Land_KartTrolly_01_F",[8.12915,-1.74951,-3.15431],0.000423011]
];

private _objects = [_centerPos, _placementArray, 0, _angle, true, 1] call SCO_fnc_placeObjectsFromArray;
{ _x enableSimulationGlobal false; } forEach _objects;
_objects params ["_building", "_initialSlingload", "_lobbyCenterObject", "_raceObject", "_utilitiesObject", "_battlegroundObject", "_sectorControlObject"];

//building
_building enableSimulationGlobal true;
private _lobbyRespawn = ["respawn_west_lobby", (getMarkerPos _marker) getPos [10, markerDir _marker + 250], "Mission and Lobby Building", [1, 1], "Default", "ICON", "Empty"] call SCO_fnc_createMarker;

//slingload
private _slingloadableClassnames = [
	"Land_Device_slingloadable_F", "B_Slingload_01_Ammo_F", 
	"B_Slingload_01_Cargo_F", "B_Slingload_01_Fuel_F", 
	"B_Slingload_01_Medevac_F", "B_Slingload_01_Repair_F",
	"Land_Pod_Heli_Transport_04_covered_F", "Land_Pod_Heli_Transport_04_medevac_F"
];
private _slingloadPos = getPosASL _initialSlingload;
private _slingloadDir = getDir _initialSlingload;
deleteVehicle _initialSlingload;

//lobby center
private _lobbyMarker = ["lobby_area", getPos _lobbyCenterObject, "Lobby Range", [3, 5.4], "ColorOrange", "RECTANGLE", "SolidBorder", _angle, 0.5] call SCO_fnc_createMarker;

//race object
if (["EnableRacing" call BIS_fnc_getParamValue] call SCO_fnc_parseBoolean) then
{
	//race center
	["race_object", getPos _raceObject, "", [0.5, 0.5], "ColorOrange", "ICON", "mil_triangle"] call SCO_fnc_createMarker;
	missionNamespace setVariable ["SCO_RACE_ACTIVE", false, true];
	{
		_x params ["_mode", "_distance", "_enableDamage"];

		//set the title of the action to start race
		private _raceTitle = "";
		switch _mode do
		{
			case 0:
			{
				_raceTitle = format ["Random %1m Race", _distance];
			};
			case 1:
			{
				_raceTitle = "User Defined Land Race";
			};
			case 3:
			{
				_raceTitle = "User Defined Heli Race";
			};
			default
			{
				_raceTitle = "Unknown Race Type";
			}
		};
		private _raceTitle = format ["%1 (Vehicle Damage: %2)", _raceTitle , _enableDamage];

		//create the addAction
		[_raceObject, [format ["Start %1", _raceTitle], 
		{
			//function to start race
			params ["_target", "_caller", "_id", "_args"];
			_args params ["_lobby", "_raceSettings"];
			_raceSettings params ["_mode", "_distance", "_enableDamage"];

			//disable races from being created at this point, until this race is done
			missionNamespace setVariable ["SCO_RACE_ACTIVE", true, true];

			//get all of the people that want to participate
			private _participants = allPlayers inAreaArray _lobby;
			format ["Stay in the race lobby for the next 5 seconds to participate in the race: %1", _participants apply {name _x}] remoteExec ["systemChat", 0];
			sleep 5;
			_participants = allPlayers inAreaArray _lobby;

			//attempt to interpret all race settings
			private _startRace = true; //if any errors are caught, this will stop the race from starting
			private _chosenMarker = "";
			if (_mode == 1 or _mode == 3) then //it is a user-defined race
			{
				private _finishMarkers = ["finish"] call SCO_fnc_getUserDefinedMarkers;
				if (count _finishMarkers == 0) then
				{
					_startRace = false;
					"No custom finish line markers found. No race will be created." remoteExec ["systemChat", 0];
					missionNamespace setVariable ["SCO_RACE_ACTIVE", false, true];
				}
				else
				{
					_chosenMarker = selectRandom _finishMarkers;
					if (_mode != 3) then
					{
						private _distToRoad = (getMarkerPos _chosenMarker) distance2D ([getMarkerPos _chosenMarker, 6000] call BIS_fnc_nearestRoad);
						if (_distToRoad < 10) then
						{
							_mode = 1; //place it on the nearest road
						}
						else
						{
							_mode = 2; //place it off road
						};
					};
				};
			};
			if (_startRace) then
			{
				[[_participants, _lobby, _mode, _distance, _chosenMarker, _enableDamage], "functions\race\fn_createRace.sqf"] remoteExec ["execVM", 2];
			};
		}, [_lobbyMarker, _x], 2, true, true, "", "!SCO_RACE_ACTIVE"]] remoteExec ["addAction", 0, true];
	} forEach [[0, 5000, false], [0, 5000, true], [0, 10000, true], [1, 0, false], [1, 0, true], [3, 0, true]]; //[mode, distance, allowDamage]
}
else
{
	deleteVehicle _raceObject;
};

//utilites object
["util_object", getPos _utilitiesObject, "", [0.5, 0.5], "ColorOrange", "ICON", "mil_triangle"] call SCO_fnc_createMarker;
[_utilitiesObject, ["Teleport to spawn", { (_this select 1) setPos getMarkerPos "respawn_west"}]] remoteExec ["addAction", 0, true];

if (["EnableZeus" call BIS_fnc_getParamValue] call SCO_fnc_parseBoolean) then
{
	[_utilitiesObject, ["Give me Zeus ability", { [_this select 1, curator1] remoteExec ["assignCurator", 2] }, nil, 1.5, true, true, "", "isNull getAssignedCuratorUnit curator1"]] remoteExec ["addAction", 0, true];
	[_utilitiesObject, ["Remove my Zeus ability", {	[curator1] remoteExec ["unassignCurator", 2] }, nil, 1.5, true, true, "", "getAssignedCuratorUnit curator1 == _this"]] remoteExec ["addAction", 0, true];
};

{
	[_utilitiesObject, [format ["Spawn %1 on roof", getText (configFile >> "cfgVehicles" >> _x >> "displayName")], 
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			_arguments params ["_classname", "_pos", "_dir", "_array"];
			private _nearestSlingloads = nearestObjects [_pos, _array, 20];
			if (count _nearestSlingloads == 0) then
			{
				private _veh = createVehicle [_classname, _pos, [], 0, "CAN_COLLIDE"];
				_veh setDir _dir;
			}
			else
			{
				hint format ["There is already a slingload object nearby (Count: %1)", count _nearestSlingloads];
			};
		}, [_x, _slingloadPos, _slingloadDir, _slingloadableClassnames]]] remoteExec ["addAction", 0, true];
} forEach _slingloadableClassnames;

//battleground object
if (["EnableBattleground" call BIS_fnc_getParamValue] call SCO_fnc_parseBoolean) then
{
	//build a list of locations that one can teleport to
	["battleground_object", getPos _battlegroundObject, "", [0.5, 0.5], "ColorOrange", "ICON", "mil_triangle"] call SCO_fnc_createMarker;
	private _radius = ["TargetSize", 400] call BIS_fnc_getParamValue;
	private _poiList = ["NameVillage", "NameCity", "NameCityCapital", "NameLocal"];
	private _towns = nearestLocations [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), _poiList, worldSize];

	//exclude locations that are within some distance of the spawn
	private _blackListed = [];
	{
		_blackListed append nearestLocations [getMarkerPos _x, _poiList, _radius * 3];
	} foreach SCO_BLACKLISTED_MARKERS;

	{
		[_battlegroundObject, [format ["Battleground: %1", text _x], { _this call SCO_fnc_generateBattlegroundAndTeleport }, [_x, _radius, _lobbyRespawn]]] remoteExec ["addAction", 0, true];
	} foreach (_towns - _blackListed);
}
else
{
	deleteVehicle _battlegroundObject;
};

//sector control object
if (["EnableSectorControl" call BIS_fnc_getParamValue] call SCO_fnc_parseBoolean) then
{
	["sector_object", getPos _sectorControlObject, "", [0.5, 0.5], "ColorOrange", "ICON", "mil_triangle"] call SCO_fnc_createMarker;
	{
		[_sectorControlObject, [
			format ["Sector Control: %1 waves", _x], 
			{ [_this, "functions\sector\fn_generateRandomSectorControl.sqf"] remoteExec ["execVM", 2] },
			_x, 1.5, true, true, "", "count (entities 'ModuleSector_F') == 0"
		]] remoteExec ["addAction", 0, true];
	} forEach [1, 2, 3, 4, 5, 8, 10];
	
	[_sectorControlObject, ["Teleport near active sector",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			private _activeSector = entities 'ModuleSector_F' select 0;
			if (!isNil "_activeSector") then
			{
				private _startRadius = _activeSector getVariable "size";
				private _safePos = [getPos _activeSector, _startRadius, _startRadius + 100, 3, 0, 0, 0, [], [getPos _caller, getPos _caller]] call BIS_fnc_findSafePos;
				_caller setPos _safePos;
				_caller setDir (_safePos getDir _activeSector);
			};
		}, nil, 1.5, true, true, "", "count (entities 'ModuleSector_F') > 0"]
	] remoteExec ["addAction", 0, true];
}
else
{
	deleteVehicle _sectorControlObject;
};