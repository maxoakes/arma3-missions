class CfgFunctions
{
	class SCO
	{
		tag = "SCO";
		class NormalFunctions
		{
			file = "functions";
			class addToUnitInventory {};
			class createMarker {};
			class createMissionBuilding {};
			class generateMapClutter {};
			class getItemClassnames {};
			class getMarkers {};
			class parseBoolean {};
			class spawnFootPatrolGroup {};
			class spawnHitSquad {};
			class spawnParkedVehicles {};
			class spawnRadialUnits {};
		};
		class SpawnFunctions
		{
			file = "functions\spawn";
			class manageFootPatrolsPOI {};
			class manageFootPatrolsGrid {};
			class manageTargetedFootPatrol {};
			class manageTargetedVehiclePatrol {};
			class manageTasks {};
			class manageVehiclePatrols {};
		};
	};
};