class CfgFunctions
{
	class SCO
	{
		tag = "SCO";
		class NormalFunctions
		{
			file = "functions";
			class getRoundsForWeapon {};
			class isDayTime {};
			class parseBoolean {};
		};
		class ActionFunctions
		{
			file = "functions\addAction";
			class getRandomWeapon {};
			class refillWeapon {};
		};
	};
};