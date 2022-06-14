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
		_vehTier1 = ["Car","Motorcycle"];
		_vehTier2 = ["Ship","Submarine","StaticWeapon"];
		_vehTier3 = ["Helicopter","Plane"];
		_vehTier4 = ["TrackedAPC","Tank","WheeledAPC"];
		
		_classes = _this select 1;
		_costs = [];
		{
			_showing = false;
			_cost = COST_MULT*0;
			
			_unitType0 = _x call BIS_fnc_objectType select 0;
			_unitType1 = _x call BIS_fnc_objectType select 1;
			if (_x find "CUP_O_" != -1) then
			{
				_showing = true;
				if ((_unitType0 isEqualTo "Soldier") or (_unitType0 isEqualTo "Object")) then
				{
					_cost = COST_MULT*0.0125;
				};
				if ((_unitType0 isEqualTo "Vehicle") or (_unitType0 isEqualTo "VehicleAutonomous")) then
				{
					_cost = COST_MULT*0.3;
					if ((_unitType1 in _vehTier1)) then
					{
						_cost = COST_MULT*0.1;
					};
					if ((_unitType1 in _vehTier2)) then
					{
						_cost = COST_MULT*0.25;
					};
					if ((_unitType1 in _vehTier3)) then
					{
						_cost = COST_MULT*0.5;
					};
					if ((_unitType1 in _vehTier4)) then
					{
						_cost = COST_MULT*0.666;
					};
				};
			};
			if (_x find "Module" != -1) then
			{
				_showing = true;
				if (_x find "Animals" != -1) then
				{
					_cost = COST_MULT*0.1;
				};
				if ((_x find "CAS" != -1) or (_x find "Ordnance" != -1)) then
				{
					_cost = COST_MULT*0.6;
				};
				if ((_x find "Effects" != -1) or (_x find "Environment" != -1) or (_x find "Misc" != -1)) then
				{
					_cost = COST_MULT*0;
				};
				if ((_x find "Flares" != -1) or (_x find "Smokeshells" != -1)) then
				{
					_cost = COST_MULT*0.05;
				};
				if (_x find "Lightning" != -1) then
				{
					_cost = COST_MULT*0.6;
				};
				if (_x find "Mines" != -1) then
				{
					_cost = COST_MULT*0.25;
				};
				if ((_x find "Multiplayer" != -1) or (_x find "Objective" != -1) or (_x find "Respawn" != -1) or (_x find "Intel" != -1) or (_x find "Diary" != -1) or (_x find "Mission" != -1)) then
				{
					_showing = false;
				};
			};
			_costs = _costs + [[_showing,_cost]];
			
		} forEach _classes; // Go through all classes and assign cost for each of them
		_costs
	}
];

_curatorObjectPlaced = {

	_object = _this select 1;
	_veh = vehicle _object;
	_object addeventhandler ["killed",{gm addCuratorPoints DEATH_REWARD;}];
	
	_object allowCrewInImmobile false;
	_object setskill 0.333;
	_object allowfleeing 0;
	
	if (_veh != _object) then
	{
		_veh flyinheight 40;
		_veh addeventhandler ["fired",{if (side group (_this select 0) == east) then {(_this select 0) setvehicleammo 1;};}];
	}
	else
	{
		_object addPrimaryWeaponItem "acc_flashlight";
	};
};
