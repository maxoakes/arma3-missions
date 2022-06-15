params ["_carrierMarker"];

//spawn carrier
if (isServer) then {
	// Spawn Carrier on Server
	_carrier = createVehicle ["Land_Carrier_01_base_F", getMarkerPos "marker_0", [], 0, "None"];
	_carrier setPosWorld getMarkerPos _carrierMarker;
	_carrier setDir 270;
	[_carrier] call BIS_fnc_Carrier01PosUpdate;

	// Broadcast Carrier ID over network
	missionNamespace setVariable ["USS_FREEDOM_CARRIER", _carrier];
	publicVariable "USS_FREEDOM_CARRIER";
}
else
{
	[] spawn {
		// Clients wait for carrier
		waitUntil {
			!(isNull (missionNamespace getVariable ["USS_FREEDOM_CARRIER",objNull]))
		};

		// Work around for missing carrier data not being broadcast as expected
		if (count (USS_FREEDOM_CARRIER getVariable ["bis_carrierParts", []]) == 0) then {
			["Carrier %1 is empty. Client Fixing.",str "bis_carrierParts"] call BIS_fnc_logFormatServer;
			private _carrierPartsArray = (configFile >> "CfgVehicles" >> typeOf USS_FREEDOM_CARRIER >> "multiStructureParts") call BIS_fnc_getCfgDataArray;
			private _partClasses = _carrierPartsArray apply {_x select 0};
			private _nearbyCarrierParts = nearestObjects [USS_FREEDOM_CARRIER,_partClasses,500];
			{
				private _carrierPart = _x;
				private _index = _forEachIndex;
				{
					if ((_carrierPart select 0) isEqualTo typeOf _x) exitWith { _carrierPart set [0,_x]; };
				} forEach _nearbyCarrierParts;
				_carrierPartsArray set [_index,_carrierPart];
			} forEach _carrierPartsArray;
			USS_FREEDOM_CARRIER setVariable ["bis_carrierParts",_nearbyCarrierParts];
			["Carrier %1 was empty. Now contains %2.",str "bis_carrierParts",USS_FREEDOM_CARRIER getVariable ["bis_carrierParts", []]] call BIS_fnc_logFormatServer;
		};

		// Client Initiate Carrier Actions with slight delay to ensure carrier is sync'd
		[USS_FREEDOM_CARRIER] spawn { sleep 1; _this call BIS_fnc_Carrier01Init};
	};
};