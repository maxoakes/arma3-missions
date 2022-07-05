//init settings for zeus
gm setCuratorCoef ["place",-1];
gm setCuratorCoef ["edit",0];
gm setCuratorCoef ["delete",0.5];
gm setCuratorCoef ["destroy",0.25];
gm setCuratorCoef ["group",0];
gm setCuratorCoef ["synchronize",0];
gm setCuratorCameraAreaCeiling 200;

[gm, "player",["%ALL"]] call BIS_fnc_setCuratorAttributes;
[gm, "object",["%ALL"]] call BIS_fnc_setCuratorAttributes;
[gm, "group",["%ALL"]] call BIS_fnc_setCuratorAttributes;
[gm, "waypoint",["%ALL"]] call BIS_fnc_setCuratorAttributes;
[gm, "marker",["%ALL"]] call BIS_fnc_setCuratorAttributes;

//points: 0.5+0.00666t
gm addCuratorPoints 0.5;
[] spawn
{
	while {true} do
	{
		sleep 0.5;
		gm addCuratorPoints 0.00333;
	};
};

gm addEventHandler [
	"CuratorObjectRegistered",
	{
		params ["_curator", "_input"];
		private _costs = [];
		//for each CfgVehicle class, do the following:
		{
			private _available = false;
			private _cost = 0;

			private _category = _x call BIS_fnc_objectType select 0;
			private _type = _x call BIS_fnc_objectType select 1;
			
			if ((toLower _x) find "o_" != 0) then
			{
				if ("Animals" in _x) then
				{
					_available = true;
					_cost = COST_MULT * 0.1;
				};
				if (("CAS" in _x) or ("Ordnance" in _x)) then
				{
					_available = true;
					_cost = COST_MULT * 0.6;
				};
				if (("Flare" in _x) or ("Smokeshell" in _x)) then
				{
					_available = true;
					_cost = COST_MULT * 0.05;
				};
				if ("Lightning" in _x) then
				{
					_available = true;
					_cost = COST_MULT * 0.6;
				};
			}
			else
			{
				switch (_category) do
				{
					case "Soldier";
					case "Object":
					{
						_cost = COST_MULT * 0.1;
						_available = true;
					};
					case "Vehicle";
					case "VehicleAutonomous":
					{
						_available = true;
						if ((_type in ["Car","Motorcycle"])) then
						{
							_cost = COST_MULT*0.2;
						};
						if ((_type in ["Ship","Submarine","StaticWeapon"])) then
						{
							_cost = COST_MULT*0.3;
						};
						if ((_type in ["Helicopter","Plane"])) then
						{
							_cost = COST_MULT*0.5;
						};
						if ((_type in ["TrackedAPC","Tank","WheeledAPC"])) then
						{
							_cost = COST_MULT*0.7;
						};
					};
				};
			};
			_costs pushBack [_available, _cost];
			
		} forEach _input; // Go through all classes and assign cost for each of them
		_costs;
	}
];

//custom properties for a placed zeus object
_curatorObjectPlaced = {

	private _object = _this select 1;
	private _veh = vehicle _object;
	_object addeventhandler ["killed", {gm addCuratorPoints DEATH_REWARD;}];
	
	_object allowCrewInImmobile false;
	_object setskill 0.333;
	_object allowfleeing 0;
	
	if (_veh != _object) then
	{
		_veh flyinheight 40;
		_veh addeventhandler ["fired", {
			if (side group (_this select 0) == east) then
			{
				(_this select 0) setvehicleammo 1;
			};
		}];
	}
	else
	{
		_object addPrimaryWeaponItem "acc_flashlight";
	};
};
