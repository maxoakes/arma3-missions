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
			class getMarkers {};
			class placeObjectsFromArray {};
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
		class Maze
		{
			file = "functions\maze";
			class createWallMaze {};
		};
		class TargetPractice
		{
			file = "functions\targets";
			class createSnipingRange {};
			class createShootingRange {};
			class spawnShootingRangeWave {};
		};
		class Spawning
		{
			file = "functions\spawning";
			class spawnEmptyVehicle {};
		};
		class Racing
		{
			file = "functions\race";
			class createRaceBuilding {};
			class createRace {};
		};
		class Sector
		{
			file = "functions\sector";
			class generateRandomSectorControl {};
		};
	};
};