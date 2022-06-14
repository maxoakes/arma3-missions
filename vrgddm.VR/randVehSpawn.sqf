_maxVeh = 7;

while {("Car" countType vehicles) < _maxVeh} do {sleep 1; [] execVM "randVeh.sqf";};

sleep 5;

systemChat "Waiting to spawn vehicles.";
waitUntil{("Car" countType vehicles) < _maxVeh};

sleep 5;
