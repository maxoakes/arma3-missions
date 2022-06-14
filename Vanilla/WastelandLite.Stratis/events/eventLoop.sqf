eventActive = false;
locPool = ["event1","event2","event3","event4","event5","event6","event7","event8","event9","event10","event11","event12","event13","event14","event15","event16","event17","event18","event19","event20","event21","event22","event23","event24","event25","event26","event27","event28","event29","event30"];
opforGroup = createGroup east;
clearTime = 600;
waitTime = 600;

_eventPool = ["events\event1.sqf","events\event2.sqf"];
_i = random floor count _eventPool;

while {true} do
{
	sleep 0.2;
	_i = random floor count _eventPool;
	systemChat "Before eventLoop first sleep";
	sleep 10;
	systemChat "Waiting.";
	waitUntil {!(eventActive)};
	systemChat "Event complete/not active. Wait time starting.";
	sleep waitTime; //Time between events
	systemChat "Wait time ended. Starting event.";
	[] execVM (_eventPool select _i);
	sleep 0.2;
	systemChat "Event started. Looping.";
};