class CfgFunctions
{
	class SCO
	{
		tag = "SCO";
		class NormalFunctions
		{
			file = "functions";
			class createBorder {};
			class getObjectClassnames {};
			class getPrimeFactorization {};
		};
		class ActionFunctions
		{
			file = "functions\addAction";
			class refillWeapon {};
		};
		class CustomActions
		{
			file = "functions\custom";
			class generateBattlegroundAndTeleport {};
			class generateRandomSectorControl {};
			class spawnBattlegroundWave {};
			class spawnEmptyVehicleAndMoveInto {};
		};
	};
};