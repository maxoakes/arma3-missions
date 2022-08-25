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
			class getObjectClassnames {};
			class getPrimeFactorization {};
			class parseBoolean {};
			class printDebug {};
		};
		class ActionFunctions
		{
			file = "functions\addAction";
			class refillWeapon {};
		};
		class Battleground
		{
			file = "functions\battleground";
			class generateBattlegroundAndTeleport {};
			class spawnBattlegroundWave {};
		};
		class Spawning
		{
			file = "functions\spawning";
			class spawnEmptyVehicle {};
		};
		class Sector
		{
			file = "functions\sector";
			class generateRandomSectorControl {};
		};
	};
};