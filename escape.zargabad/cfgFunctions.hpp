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
			class placeObjectsFromArray {};
			class generateMapClutter {};
			class getItemClassnames {};
			class getMarkers {};
			class parseBoolean {};
			class pickFromArray {};
			class spawnFootPatrolGroup {};
			class spawnHitSquad {};
			class spawnParkedVehicles {};
			class spawnRadialUnits {};

			//custom
			class printDebug {};
		};
		class SpawnFunctions
		{
			file = "functions\spawn";
			class manageFootPatrolsPOI {};
			class manageFootPatrolsGrid {};
			class manageAirPatrols {};
			class manageTargetedFootPatrol {};
			class manageTargetedVehiclePatrol {};
			class manageTasks {};
			class manageVehiclePatrols {};
		};
	};
};