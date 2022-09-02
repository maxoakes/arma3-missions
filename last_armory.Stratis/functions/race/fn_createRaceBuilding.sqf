params ["_marker"];

race_start allowDamage false;
private _centerPos = getMarkerPos _marker;
private _angle = markerDir _marker;
private _placementArray = [
	["Land_Cargo_HQ_V1_F",[0,0,-3.0754],0], //0, main building
	["B_Slingload_01_Cargo_F",[-0.5,2,-0.749884],254.18], //1, slingload position object
	["MapBoard_stratis_F",[6.25269,3.25488,-3.27695],29.993], //2, race object
	["Land_ClutterCutter_small_F",[4.5,0.75,-3.08],0], //3, marker center object
	["Land_TripodScreen_01_dual_v1_black_F",[-0.864624,0.758301,-3.27468],180.003], //4, utilities object
	["Land_PlasticBarrier_03_F",[0.549561,0.129883,-3.27473],175.969],
	["I_E_CargoNet_01_ammo_F",[0.753418,1.57422,-3.27472],268.077],
	["PlasticBarrier_03_orange_F",[-1.31543,-0.359375,-3.27473],343.942],
	["Sign_Sphere10cm_F",[1.5,-1,-2.6254],0],
	["B_supplyCrate_F",[-0.979736,2.08496,-3.27473],178.324],
	["Sign_Sphere10cm_F",[1.5,-1.5,-2.6254],0],
	["Sign_Sphere10cm_F",[1.5,-2,-2.6254],0],
	["VirtualReammoBox_camonet_F",[-2.80396,1.2793,-3.27473],91.3817],
	["Sign_Sphere10cm_F",[1.5,-2.5,-2.6254],0],
	["Land_PlasticBarrier_01_line_x4_F",[2.04297,1.35645,-3.27373],90],
	["B_CargoNet_01_ammo_F",[0.618164,3.47607,-3.27473],268.267],
	["Land_Pallet_MilBoxes_F",[-3.25,-1,-3.27373],270],
	["Sign_Sphere10cm_F",[1.5,-3.5,-2.6254],0],
	["CargoNet_01_barrels_F",[-1.84741,3.56982,-3.27473],0.000724815],
	["Sign_Sphere10cm_F",[1.5,-4,-2.6254],0],
	["Land_CampingChair_V2_F",[-1.9801,-4.10352,-3.27473],209.995],
	["Sign_Sphere10cm_F",[1.5,-4.5,-2.6254],0],
	["Land_CampingChair_V2_F",[-0.367432,-4.76416,-3.27473],179.995],
	["Land_CampingChair_V2_white_F",[0.485962,-4.75684,-3.27473],171.311],
	["Land_CampingChair_V2_F",[-1.19116,-4.64014,-3.27473],209.995],
	["CargoNet_01_box_F",[-3.42212,3.54199,-3.27473],360],
	["FlexibleTank_01_forest_F",[-4.92773,0.197266,-3.15432],9.15385],
	["FlexibleTank_01_forest_F",[-4.90576,0.8125,-3.15432],62.0192],
	["Sign_Sphere10cm_F",[1.5,-5,-2.6254],0],
	["FlexibleTank_01_sand_F",[-5.05371,1.51855,-3.15432],134.655],
	["Box_NATO_AmmoVeh_F",[-3.28333,-4.36621,-3.24418],6.77898e-005],
	["SignAd_Sponsor_ARMEX_F",[-4.75,3.25,-3.8754],90],
	["Land_Stretcher_01_olive_F",[-0.344727,-5.90234,-3.15431],89.9981],
	["Land_KartStand_01_F",[4.05396,-4.60742,-3.27473],267.507],
	["Land_Trophy_01_bronze_F",[4,5.25,-2.3433],0.0352424],
	["Land_Trophy_01_silver_F",[4.5,5.25,-2.3433],0.0379381],
	["SignAd_Sponsor_Redstone_F",[-4.75,-4.75,-3.8754],90],
	["Land_KartTyre_01_x4_F",[5.33826,-4.11963,-3.28576],282.581],
	["Land_CampingTable_F",[4.5,5.25,-3.1569],0.000900539],
	["Land_Trophy_01_gold_F",[5,5.25,-2.3433],0.0385555],
	["Land_KartTyre_01_x4_F",[5.32849,-4.69043,-3.28576],359.928],
	["Land_PlasticBarrier_01_line_x6_F",[4.18066,6.16211,-3.15331],0],
	["Land_PlasticBarrier_01_line_x2_F",[7.37109,0.723633,-3.27373],270],
	["Land_KartTrolly_01_F",[8.12927,-1.74951,-3.15431],0.000426723]
];

private _objects = [_centerPos, _placementArray, 0, _angle, true, 1] call SCO_fnc_placeObjectsFromArray;
{ _x enableSimulationGlobal false; } forEach _objects;
_objects params ["_building", "_initialSlingload", "_raceObject", "_raceLobbyObject", "_utilitiesObject"];
_building enableSimulationGlobal true;

//race center
missionNamespace setVariable ["SCO_RACE_ACTIVE", false, true];
private _lobbyMarker = ["race_lobby", getPos _raceLobbyObject, "Lobby Range", [3, 5.4], "ColorOrange", "RECTANGLE", "SolidBorder", _angle, 0.5] call SCO_fnc_createMarker;
{
	private _distance = _x;
	private _raceTitle = format ["%1m Race", _distance];
	if (_distance == -1) then { _raceTitle = "User Defined Race"; };
	[_raceObject, [format ["Start %1", _raceTitle], 
	{
		params ["_target", "_caller", "_id", "_args"];
		_args params ["_lobby", "_distance"];
		missionNamespace setVariable ["SCO_RACE_ACTIVE", true, true];
		private _participants = allPlayers inAreaArray _lobby;
		format ["Stay in the race lobby for the next 5 seconds to participate in the race: %1", _participants apply {name _x}] remoteExec ["systemChat", 0];
		sleep 5;

		_participants = allPlayers inAreaArray _lobby;
		private _userDefinedMarkers = [];
		{
			private _markers = _x;
			//if it is a user-placed marker in global chat that has 'finish' in the text
			if (("_USER_DEFINED" in _markers) and ("finish" in (markerText _markers)) and (markerChannel _markers == 0)) then
			{
				_userDefinedMarkers pushBack _markers;
			};
		} forEach allMapMarkers;
		[[_participants, _lobby, _distance, _userDefinedMarkers], "functions\race\fn_createRace.sqf"] remoteExec ["execVM", 2];
		
	}, [_lobbyMarker, _x], 2, true, true, "", "!SCO_RACE_ACTIVE"]] remoteExec ["addAction", 0, true];
} forEach [-1, 1000, 2000, 3000, 4000, 5000, 6000, 8000, 10000];


//utilites object
[_utilitiesObject, ["Add Ammo for this Weapon", { _this call SCO_fnc_refillWeapon }, 4]] remoteExec ["addAction", 0, true];