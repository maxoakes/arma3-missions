params ["_player", "_didJIP"];

//create diary entry for all players to describe all armory features
_player createDiaryRecord ["Diary",
[
	"Upcoming features",
	"Scouter is always looking to add fun stuff to the armory. Let him know of suggestions."
], taskNull, "", false];

_player createDiaryRecord ["Diary",
[
	"Racing",
	"The race manager object is the map in the lobby area. When a race distance/type is selected from that map, all players in the lobby will be subject to race participation. After 5 seconds, all players still in the lobby will be teleported into driver seats of race vehicles. After about 10 seconds, a flare will appear, indicating that the race has started. Reach the finishing line to complete the race. Any racer that is killed is disqualified. Once the first racer completes the race, a timer will start. Any racer that does not complete the race before the timer expires will be marked as DNF.<br/><br/>An experimental feature allows for anyone to choose a finish line location. If a marker is placed in global chat with the word 'finish' in the text, this will be one possible finish line location. To choose a race that uses one of these user-placed markers, choose a 'User Defined Race' option from the race lobby board. <br/><br/>Additionally, any vehicle that is placed closest to the race center (a vehicle that is actually close to the race center) will be picked as the race vehicle."
], taskNull, "", false];

_player createDiaryRecord ["Diary",
[
	"Sector Control",
	"The map board in the lobby building allows for the creation of a classic Arma 'sector control' objective that anyone can take part in. When one is created, it will be up to players to make their way to the sector and kill any enemies. Once the initial enemy squad is killed, players will need to defend the sector against some number of waves of enemies. The number of enemy units increases each wave. If the sector is re-taken by the enemy, the mission is failed and sector will be deleted. Only one sector can be active at a time."
], taskNull, "", false];

_player createDiaryRecord ["Diary",
[
	"Battleground",
	"The telephone booth lists all major locations in the map. When you select one of these locations, you will be teleported somewhere in or around that location with a new telephone booth. At this new telephone booth, you will be able to spawn a handful of different types of squads, ranging from patrols, to sniper groups, to tank patrols and an armed helicopter. Any spawned group will target the telephone booth. The purpose of this feature is for live target practice. You can teleport back to spawn whenever you want and the spawned units will be cleaned up for you."
], taskNull, "", false];

_player createDiaryRecord ["Diary",
[
	"Lobby Building Features",
	"The lobby building is the hub of mini-games, missions and utilities. The 'lobby' part of the building is the back half that is sectioned off with glowing orbs. Any features for multiplayer game modes will be housed there.<br/><br/>In the front of the building is a phonebooth for battlegrounds.<br/><br/>In the front room is a map for starting sector control.<br/><br/>Also in the front room is computer for small niche features, such as spawning slingloadable containers on the roof that some helicopters can carry."
], taskNull, "", false];

_player createDiaryRecord ["Diary",
[
	"360 Shooting Range",
	"This feature is an abstract live fire range. The range is a perfect circle with randomly placed low walls. When a player selects a wave spawn action from the flag pole in the center, VR units will start to spawn on the outer part of the circle and will try to move to the center toward the flag pole. The goal is to kill all of the units before they reach the center. For any unit that reaches within a few meters of the sand bags, one point is deducted. Once the waves are completed, a final score will be shared to all. Can you get a perfect score? This feature can technically have more than one player, but only the player that started the wave will see the live score."
], taskNull, "", false];

_player createDiaryRecord ["Diary",
[
	"Sniping Range",
	"The sniping range features several stands with moving targets. Each stand has some number of glowing orbs in front of it to indicate how far it is away from the sniping range hut. Each orb is equal to 100 meters. At the hut of the sniping range is a crate with an arsenal, ammo resupply function, and a way to teleport back to the spawn."
], taskNull, "", false];

_player createDiaryRecord ["Diary",
[
	"Maze",
	"This is really an experiment in translating common algorithms into Arma's SQF language. Two mazes are available, a smaller and larger one. They utilize a DFS spanning tree algorithm, meaning that all cells are accessible, and there is guarenteed to be a path through them that reaches an exit."
], taskNull, "", false];

_player createDiaryRecord ["Diary",
[
	"Arsenal Sign",
	"The large sign in the spawn features inventory and unit management."
], taskNull, "", false];

_player createDiaryRecord ["Diary",
[
	"Map Teleportation",
	"Next to the spawn, there is a circle on the ground. If you (or a vehicle you are in) are in this circle, this gives you the ability to single-left-click anywhere on the map, and you (and your vehicle) will be teleported to that exact position. Be careful though! There is no checking to see if that position is at all safe for you or your vehicle. It is recommended to click on a flat(-ish) position that is clear of objects and trees. Any air vehicles that manage to use this feature will be teleported to ground level, so keep this in mind."
], taskNull, "", false];

_player createDiaryRecord ["Diary",
[
	"Vehicle Spawning",
	"Most objects in the spawn are for spawning vehicles. To spawn a vehicle, approach an object in the spawn and scroll. A list of all of the vehicles of a certain type will be available. The categories are helicopters, planes, boats/ships, APCs/tanks, and 'land vehicles', which is a catch-all for every other vehicle. When you select one of these vehicles from the list, you will be teleported into the driver seat of a newly spawned vehicle in an appropriate location."
], taskNull, "", false];

_player createDiaryRecord ["Diary",
[
	"Spawn",
	"The spawn area allows access to most features of the armory.<br/><br/>Vehicle spawning is possible via several objects placed radially.<br/><br/>The map board is used to fast travel to major armory landmarks.<br/><br/>All objects use 'actions' which can be viewed by scrolling while looking at an object."
], taskNull, "", false];
