_maxVeh = 180;

while {(count vehicles) <= _maxVeh} do {sleep .5; [] execVM "randVeh.sqf";};

sleep 600;

systemChat "Waiting to spawn vehicles at _maxVeh/2.";
waitUntil{(count vehicles) <= _maxVeh/2};

sleep 5;

while {(count vehicles) <= _maxVeh} do {sleep .5; [] execVM "randVeh.sqf";};