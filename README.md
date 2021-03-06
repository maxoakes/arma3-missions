Arma 3 missions that I have created over the years.

I have decided to go through all of the viable missions and revamp them. Many were created when I did not have an appreciation for quality programming styling and programming knowledge.

* Zeus Escape: Malden
    * Originally created 2018
    * Last updated June 15, 2022
    * Tested with multiplier: not yet
    * Escape Malden via air or sea. Enemies are controlled by Zeus. Requires at at least one Zeus game manager to play.
* Paintball: VR
    * Originally created 2014
    * Last updated June 17, 2022
    * Tested with multiplier: not yet
    * Originally there were seperate missions for night-time laser tag and day-time paintball and seperate arenas. Now, there is a single mission with parameters to switch between day and night, and VR-style arena or paintball-style arena. Also is procedurally generated.
* Last Armory: Stratis
    * Originally created June 2020
    * Last updated June 27, 2022
    * Hopefully the last "armory" mission that I need to make. Allows the use of all vehicles and weapons, and also allows teleporting from spawn, on-demand sector control missions and wave clearance games.
    * First mission that I went in-depth to make the netcode work for a dedicated server as well as player-hosted. This mission should be used as an example for future missions.
    * Also actually had to make a prime factorization script. Never thought an interview question would be actually used...
* Free-for-all: Altis
    * Originally created March 2018 on Chernarus
    * Last updated July 2, 2022
    * A popular game mode that was orignally created by picking a location on a map, and creating a whole mission for that location only. Any code updates would need to be applied to all of the missions.
    * This mission allows for naming of a marker ellipse a certain naming convention, and the arena will be available (once added to Description.ext parameters).
    * Cleaned locality and potential vehicle/weapon/item spawning from previous version.
    * Vehicles will spawn randomly that hold completely random items.
    * A care package will spawn occasionally that holds weapons and attachments. Contains addActions for getting a random weapon with random attachments, as well as mag refilling. Will also violently despawn with a warning.
    * If it is nighttime, night vision goggles will sometimes spawn in vehicles.
* Manhunt: Chernarus
    * Created July 5, 2022
    * Last updated July 20, 2022
    * Admittedly, Chernarus is a big map, so this mission is a lot of walking and driving
    * A new type of mission. Goal is for players to locate, kill and confirm a target. After the kill is confirmed, all players must leave the map via their extraction vehicle.
    * Requires A3 CBA, CUP Weapons, CUP Units, CUP Vehicles, CUP Terrains - Core, CUP Terrains - Maps and CUP Terrains - CWA
    * For recreating this mission in other maps, the following objects are needed in the mission editor:
        * Some number of west (blufor) units. This implimentation has 8.
        * One "respawn_west" marker
        * Ammobox with variable name "arsenal"
        * A vehicle that can carry at least the maximum number of players with variable name "extract"
        * A marker to indicate an HQ location with variable name "confirmed"
        * One or more invisible (empty) markers with a variable name starting with "hq_", all on flat surfaces that are at least 5 meters away from any object
        * One or more markers with variable name starting with "meet_". All markers should be in at least a somewhat flat area of about 3m radius
    * This is the first mission to utilize CfgFunctions. Will expand to the other missions when this one is successful
* Functions:
    * See function headers for description, parameters and return value(s)
    * createMarker
        * Manhunt Chernarus
    * createMissionBuilding
        * Manhunt Chernarus
    * footPatrolManager
        * Called via 'spawn'
        * Manhunt Chernarus
    * getMarkersWithPrefix
        * Manhunt Chernarus
    * generateMapClutter
        * Manhunt Chernarus
    * parseBoolean
        * Manhunt Chernarus
    * refillWeapon
        * Manhunt Chernarus
    * spawnEnemyMeeting
        * Manhunt Chernarus
    * spawnGroundPatrolGroup
        * Manhunt Chernarus
    * spawnParkedVehicles
        * Manhunt Chernarus
    * spawnRepeatingSingleVehiclePatrol
        * Manhunt Chernarus
    * taskManager
        * Manhunt Chernarus
    * vehiclePatrolManager
        * Called via 'spawn'
        * Manhunt Chernarus