_eventSize = 10;

_i = locPool call BIS_fnc_selectRandom;
_loc = getMarkerPos _i;
_nearObj = _loc nearObjects _eventSize;
_nearAI = _loc nearEntities ["Man", _eventSize*2];

sleep 2;

if (count _nearObj > 1) then
{
	{deleteVehicle _x} forEach _nearAI;
	{deleteVehicle _x} forEach _nearObj;
	sleep 5;
};

eventActive = true;
_obj1 = createVehicle ["Land_Razorwire_F",[(_loc Select 0)-3, ( _loc Select 1)+3.3, (_loc Select 2)], [], 0, "CAN_COLLIDE"];
_obj2 = createVehicle ["C_Van_01_transport_F", _loc, [], 0, "CAN_COLLIDE"];

_obj3 = createVehicle ["Box_NATO_AmmoVeh_F",[(_loc Select 0)+1, ( _loc Select 1)-5, (_loc Select 2)], [], 0, "CAN_COLLIDE"];
_obj3 setDir 25;
_obj3 allowDamage false;

_obj4 = createVehicle ["Box_NATO_AmmoVeh_F",[(_loc Select 0)-1, ( _loc Select 1)-5, (_loc Select 2)], [], 0, "CAN_COLLIDE"];
_obj4 setDir 10;
_obj4 allowDamage false;

_obj3 addItemCargoGlobal ["H_Beret_blk", 2];
_obj3 addItemCargoGlobal ["H_Beret_blk_POLICE", 2];
_obj3 addItemCargoGlobal ["H_Beret_brn_SF", 2];
_obj3 addItemCargoGlobal ["H_Beret_grn", 2];
_obj3 addItemCargoGlobal ["H_Beret_grn_SF", 2];
_obj3 addItemCargoGlobal ["H_Beret_ocamo", 2];
_obj3 addItemCargoGlobal ["H_Beret_red", 2];
_obj3 addItemCargoGlobal ["H_Booniehat_dgtl", 2];
_obj3 addItemCargoGlobal ["H_Booniehat_dirty", 2];
_obj3 addItemCargoGlobal ["H_Booniehat_grn", 2];
_obj3 addItemCargoGlobal ["H_Booniehat_indp", 2];
_obj3 addItemCargoGlobal ["H_Booniehat_khk", 2];
_obj3 addItemCargoGlobal ["H_Booniehat_mcamo", 2];
_obj3 addItemCargoGlobal ["H_Booniehat_tan", 2];
_obj3 addItemCargoGlobal ["H_Cap_brn_SPECOPS", 2];
_obj3 addItemCargoGlobal ["H_Cap_khaki_specops_UK", 2];
_obj3 addItemCargoGlobal ["H_Cap_oli", 2];
_obj3 addItemCargoGlobal ["H_Cap_red", 2];
_obj3 addItemCargoGlobal ["H_Cap_tan", 2];
_obj3 addItemCargoGlobal ["H_Cap_tan_specops_US", 2];
_obj3 addItemCargoGlobal ["H_MilCap_blue", 2];
_obj3 addItemCargoGlobal ["H_MilCap_dgtl", 2];
_obj3 addItemCargoGlobal ["H_MilCap_gry", 2];
_obj3 addItemCargoGlobal ["H_MilCap_mcamo", 2];
_obj3 addItemCargoGlobal ["H_MilCap_ocamo", 2];
_obj3 addItemCargoGlobal ["H_MilCap_oucamo", 2];
_obj3 addItemCargoGlobal ["H_MilCap_rucamo", 2];
_obj3 addItemCargoGlobal ["H_Watchcap_blk", 2];
_obj3 addItemCargoGlobal ["H_Watchcap_camo", 2];
_obj3 addItemCargoGlobal ["H_Watchcap_khk", 2];
_obj3 addItemCargoGlobal ["H_Watchcap_sgg", 2];
_obj3 addItemCargoGlobal ["H_Bandanna_camo", 2];
_obj3 addItemCargoGlobal ["H_Bandanna_cbr", 2];
_obj3 addItemCargoGlobal ["H_Bandanna_gry", 2];
_obj3 addItemCargoGlobal ["H_Bandanna_khk", 2];
_obj3 addItemCargoGlobal ["H_Bandanna_mcamo", 2];
_obj3 addItemCargoGlobal ["H_Bandanna_sgg", 2];
_obj3 addItemCargoGlobal ["H_BandMask_blk", 2];
_obj3 addItemCargoGlobal ["H_BandMask_demon", 2];
_obj3 addItemCargoGlobal ["H_BandMask_khk", 2];
_obj3 addItemCargoGlobal ["H_BandMask_reaper", 2];
_obj3 addItemCargoGlobal ["H_Bandanna_surfer", 2];
_obj3 addItemCargoGlobal ["H_Cap_blk", 2];
_obj3 addItemCargoGlobal ["H_Cap_blk_CMMG", 2];
_obj3 addItemCargoGlobal ["H_Cap_blk_ION", 2];
_obj3 addItemCargoGlobal ["H_Cap_blk_Raven", 2];
_obj3 addItemCargoGlobal ["H_Cap_blu", 2];
_obj3 addItemCargoGlobal ["H_Cap_grn", 2];
_obj3 addItemCargoGlobal ["H_Cap_grn_BI", 2];
_obj3 addItemCargoGlobal ["H_Cap_headphones", 2];
_obj4 addItemCargoGlobal ["H_Hat_blue", 2];
_obj4 addItemCargoGlobal ["H_Hat_brown", 2];
_obj4 addItemCargoGlobal ["H_Hat_camo", 2];
_obj4 addItemCargoGlobal ["H_Hat_checker", 2];
_obj4 addItemCargoGlobal ["H_Hat_grey", 2];
_obj4 addItemCargoGlobal ["H_Hat_tan", 2];
_obj4 addItemCargoGlobal ["H_Shemag_khk", 2];
_obj4 addItemCargoGlobal ["H_Shemag_olive", 2];
_obj4 addItemCargoGlobal ["H_Shemag_tan", 2];
_obj4 addItemCargoGlobal ["H_ShemagOpen_khk", 2];
_obj4 addItemCargoGlobal ["H_ShemagOpen_tan", 2];
_obj4 addItemCargoGlobal ["H_StrawHat", 2];
_obj4 addItemCargoGlobal ["H_StrawHat_dark", 2];
_obj4 addItemCargoGlobal ["H_TurbanO_blk", 2];
_obj4 addItemCargoGlobal ["H_CrewHelmetHeli_B", 2];
_obj4 addItemCargoGlobal ["H_CrewHelmetHeli_I", 2];
_obj4 addItemCargoGlobal ["H_CrewHelmetHeli_O", 2];
_obj4 addItemCargoGlobal ["H_HelmetB", 2];
_obj4 addItemCargoGlobal ["H_HelmetB_camo", 2];
_obj4 addItemCargoGlobal ["H_HelmetB_light", 2];
_obj4 addItemCargoGlobal ["H_HelmetB_paint", 2];
_obj4 addItemCargoGlobal ["H_HelmetB_plain_blk", 2];
_obj4 addItemCargoGlobal ["H_HelmetB_plain_mcamo", 2];
_obj4 addItemCargoGlobal ["H_HelmetCrew_B", 2];
_obj4 addItemCargoGlobal ["H_HelmetCrew_I", 2];
_obj4 addItemCargoGlobal ["H_HelmetCrew_O", 2];
_obj4 addItemCargoGlobal ["H_HelmetIA", 2];
_obj4 addItemCargoGlobal ["H_HelmetIA_camo", 2];
_obj4 addItemCargoGlobal ["H_HelmetIA_net", 2];
_obj4 addItemCargoGlobal ["H_HelmetLeaderO_ocamo", 2];
_obj4 addItemCargoGlobal ["H_HelmetLeaderO_oucamo", 2];
_obj4 addItemCargoGlobal ["H_HelmetO_ocamo", 2];
_obj4 addItemCargoGlobal ["H_HelmetO_oucamo", 2];
_obj4 addItemCargoGlobal ["H_HelmetSpecB", 2];
_obj4 addItemCargoGlobal ["H_HelmetSpecB_blk", 2];
_obj4 addItemCargoGlobal ["H_HelmetSpecB_paint1", 2];
_obj4 addItemCargoGlobal ["H_HelmetSpecB_paint2", 2];
_obj4 addItemCargoGlobal ["H_HelmetSpecO_blk", 2];
_obj4 addItemCargoGlobal ["H_HelmetSpecO_ocamo", 2];
_obj4 addItemCargoGlobal ["H_PilotHelmetFighter_B", 2];
_obj4 addItemCargoGlobal ["H_PilotHelmetFighter_I", 2];
_obj4 addItemCargoGlobal ["H_PilotHelmetFighter_O", 2];
_obj4 addItemCargoGlobal ["H_PilotHelmetHeli_B", 2];
_obj4 addItemCargoGlobal ["H_PilotHelmetHeli_I", 2];
_obj4 addItemCargoGlobal ["H_PilotHelmetHeli_O", 2];

_unit1 = opforGroup createUnit ["O_recon_F",[(_loc Select 0)-4, ( _loc Select 1)-1, (_loc Select 2)], [], 1, "CAN_COLLIDE"];
_unit2 = opforGroup createUnit ["O_recon_F",[(_loc Select 0)-4, ( _loc Select 1)+1, (_loc Select 2)], [], 1, "CAN_COLLIDE"];
_unit3 = opforGroup createUnit ["O_recon_M_F",[(_loc Select 0)+4, ( _loc Select 1)-1, (_loc Select 2)], [], 1, "CAN_COLLIDE"];
_unit4 = opforGroup createUnit ["O_sniper_F",[(_loc Select 0)+4, ( _loc Select 1)+1, (_loc Select 2)], [], 1, "CAN_COLLIDE"];
_unit7 = opforGroup createUnit ["O_Soldier_lite_F",[(_loc Select 0)-5, ( _loc Select 1)-5, (_loc Select 2)], [], 0, "CAN_COLLIDE"];
_unit8 = opforGroup createUnit ["O_Soldier_lite_F",[(_loc Select 0)+5, ( _loc Select 1)-5, (_loc Select 2)], [], 0, "CAN_COLLIDE"];

_eventMen = ["O_recon_F","O_recon_M_F","O_sniper_F","O_Soldier_lite_F"];

_nearObj = _loc nearObjects _eventSize;
_nearAI = _loc nearEntities ["Man", _eventSize*2];

sleep 2;

hint "A hat salesmen was ambushed and killed! Get to his truck and get his wares!";

sleep 2;

_i setMarkerText "Hat Salesman Ambush";
_i setMarkerType "mil_destroy";

sleep 2;
waitUntil {count (_loc nearEntities [_eventMen, _eventSize*3]) == 0};

sleep 1;
hint "The hats have been secured.";
sleep clearTime;
{deleteVehicle _x} forEach _nearAI;
{deleteVehicle _x} forEach _nearObj;
systemChat "event2 objects deleted";

sleep 2;

_i setMarkerType "Empty";

sleep 2;

eventActive = false;