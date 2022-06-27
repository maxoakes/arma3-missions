params ["_cfg", "_category"];

private _list = (configFile >> _cfg) call BIS_fnc_getCfgSubClasses;
private _types = [];
private _accompanyingConfigs = [[]];

{
	if (getnumber (configFile >> _cfg >> _x >> "scope") > 1) then {
		private _obj = _x call BIS_fnc_objectType;
		if (_obj select 0 == _category) then
		{
			private _index = _types find (_obj select 1);
			if (_index > -1) then
			{
				private _thisSubArray = _accompanyingConfigs select _index;
				_thisSubArray pushBack _x;
				_accompanyingConfigs set [_index, _thisSubArray]; 
			}
			else
			{
				private _newIndex = _types pushBack (_obj select 1);
				_accompanyingConfigs set [_newIndex, [_x]]; 
			};
		};
	};
} foreach _list;

private _return = [[]];
for "_i" from 0 to (count _types) do
{
	private _a = [_types select _i, _accompanyingConfigs select _i];
	_return pushBack _a;
};
_return;