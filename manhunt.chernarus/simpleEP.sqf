private _simpleEP = [
	"<t color='#ffff33'>Put on ear plugs</t>",
	{
		_caller = _this select 1;
		_actionID = _this select 2;
		if (soundVolume == 1) then {
			1 fadeSound 0.25;
			_caller setUserActionText [_actionID,"<t color='#ffff33'>Take off ear plugs</t>"]
		}
		else
		{
			1 fadeSound 1;
			_caller setUserActionText [_actionID,"<t color='#ffff33'>Put on ear plugs</t>"]
		}
	},
	[],
	10,
	false,
	true,
	"",
	"_target == vehicle player"
];

_this addAction _simpleEP;
_this addEventHandler ["Respawn",{
	1 fadeSound 1;
	(_this select 0) addAction sepa;
}];