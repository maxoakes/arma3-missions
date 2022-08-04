class CfgFunctions
{
	class SCO
	{
		tag = "SCO";
		class NormalFunctions
		{
			file = "functions";
			class createBorder {};
			class createMarker {};
			class dirToString {};
			class getItemClassnames {};
			class getRoundsForWeapon {};
			class isDayTime {};
			class parseBoolean {};
			class spawnHitSquad {};
		};
		class SpawnFunctions
		{
			file = "functions\spawn";
		};
		class ActionFunctions
		{
			file = "functions\addAction";
			class getRandomWeapon {};
			class refillWeapon {};
		};
		class CustomActions
		{
			file = "functions\custom";
		};
	};
};