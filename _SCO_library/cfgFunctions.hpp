class CfgFunctions
{
	class SCO
	{
		tag = "SCO";
		class NormalFunctions
		{
			file = "functions";
			class addToUnitInventory {};
			class createBorder {};
			class createMarker {};
			class createMissionBuilding {};
			class generateMapClutter {};
			class getItemClassnames {};
			class getMarkers {};
			class getObjectClassnames {};
			class getPrimeFactorization {};
			class getRoundsForWeapon {};
			class isDayTime {};
			class parseBoolean {};
			class spawnFootPatrolGroup {};
			class spawnParkedVehicles {};
			class spawnRadialUnits {};
		};
		class SpawnFunctions
		{
			file = "functions\spawn";
			class manageFootPatrols {};
			class manageTargetedVehiclePatrol {};
			class manageTasks {};
			class manageVehiclePatrols {};
		};
		class ActionFunctions
		{
			file = "functions\addAction";
			class getRandomWeapon {};
			class refillWeapon {};
		};
	};
};