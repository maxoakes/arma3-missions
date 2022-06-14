_maxVeh = 3;

while {("Air" countType vehicles) < _maxVeh} do {sleep 1; [] execVM "randhelo.sqf";};

sleep 5;

systemChat "Waiting to spawn Helos.";
waitUntil{("Air" countType vehicles) < _maxVeh};

sleep 5;
