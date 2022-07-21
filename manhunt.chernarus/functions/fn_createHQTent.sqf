/*
	Author: Scouter

	Description:
		given a position, spawn a tent filled with furniture

	Parameter(s):
		0: Position

	Returns:
		Array of Objects in format [Tent object, Laptop object, crate object]

	array obtained using in-game console with the following script:

	private _objects = [];
	private _originObject = cursorObject;
	{
		private _classname = typeOf _x;
		private _posRel = _originObject worldToModel getPos _x; 
		private _dir = getDir _x;
		_objects pushBack [_classname, _posRel, _dir];
	} forEach nearestObjects [_originObject, [], 20];
	_objects;
*/
params ["_pos"];

private _startTime = diag_tickTime;

//object classnames, relative position and rotation for HQ tent
//generated from a different script
private _hqPlacementArray = [
	["Land_MedicalTent_01_floor_light_F",[0,0,0],0],
	["Land_CampingChair_V2_white_F",[-1.44043,-0.301097,-1.37448],97.2297],
	["Land_Laptop_Intel_01_F",[-2.30078,-0.0440507,-0.37651],119.858],
	["Land_CampingChair_V2_F",[-1.91797,-1.43323,-1.37449],139.457],
	["Land_CampingTable_white_F",[-2.4668,-0.43909,-1.37708],112.439],
	["Land_CampingChair_V2_F",[2.23926,1.24913,-1.37426],261.168],
	["Newspaper_01_F",[-2.64258,-1.00747,-0.37653],359.993],
	["Land_SatellitePhone_F",[3.06641,1.33533,-0.37612],87.1279],
	["Land_MultiScreenComputer_01_black_F",[3.05078,2.18107,-0.37384],88.6554],
	["Land_PortableLight_02_double_yellow_F",[-3.22266,1.95623,-1.37373],311.475],
	["Land_PortableDesk_01_black_F",[3.07813,2.16546,-1.37155],271.236],
	["Land_Computer_01_black_F",[3.00195,2.97065,-0.37186],41.0214],
	["Land_Sun_chair_green_F",[3.02832,-3.18494,-1.35389],359.978],
	["Box_NATO_Support_F",[1.94141,-4.07574,-1.37453],344.716],
	["Land_Camping_Light_F",[2.04785,-4.14002,-0.38705],0.0134262],
	["Land_PortableCabinet_01_closed_black_F",[-1.95215,4.12042,-1.37061],174.886],
	["O_supplyCrate_F",[-2.24453,-3.49035,-1.3745],40],
	["Land_PortableCabinet_01_4drawers_black_F",[-3.36328,3.34279,-1.36412],326.209],
	["Land_PortableCabinet_01_bookcase_black_F",[-2.80664,3.8257,-1.37099],333.618],
	["Land_PortableCabinet_01_medical_F",[2.81641,3.91601,-1.36751],53.3696],
	["Box_NATO_AmmoVeh_F",[1.93945,5.84517,-1.33292],359.839],
	["Box_FIA_Support_F",[-2.05762,6.40834,-1.36661],0.360727],
	["SatelliteAntenna_01_Olive_F",[-3.89551,6.19535,-1.37167],344.466],
	["O_CargoNet_01_ammo_F",[3.49805,7.11149,-1.35801],91.1991]
];

//create shell of HQ
private _baseDir = getDir (nearestBuilding _pos) + 90; //align it with a nearby building
private _tent = createVehicle ["Land_MedicalTent_01_CSAT_brownhex_generic_open_F", _pos, [], 0, "CAN_COLLIDE"];
_tent allowDamage false;
_tent setDir _baseDir;
private _intel = objNull;
private _crate = objNull;

//fill tent with stuff
{
	private _obj = createVehicle [_x select 0, _tent modelToWorld (_x select 1), [], 0, "CAN_COLLIDE"];
	_obj setDir ((_x select 2) + _baseDir);
	_obj allowDamage false;
	if (typeOf _obj == "Land_Laptop_Intel_01_F") then
	{
		_intel = _obj;
	};
	if (typeOf _obj == "O_supplyCrate_F") then
	{
		_crate = _obj;
	}
} forEach _hqPlacementArray;

private _stopTime = diag_tickTime;
(format ["%1 sec to create the HQ tent", _stopTime - _startTime]) remoteExec ["systemChat", 0];

//return
[_tent, _intel, _crate];
