_maxAI = 50;

while {east countSide allUnits <= _maxAI} do {sleep 1; [] execVM "randPatNew.sqf";};
sleep 3;

while {true} do
{
	waitUntil {east countSide allUnits < _maxAI;};
	[] execVM "randPatNew.sqf";
	sleep 3;
};