
LND_intel = ["Intel", 3] call BIS_fnc_getParamValue;
LND_samThreat = ["SAM", 0] call BIS_fnc_getParamValue;
LND_aaaThreat = ["AAA", 0] call BIS_fnc_getParamValue;
LND_AARefresh = ["AARefresh", 2] call BIS_fnc_getParamValue;
LND_activeAA = [];

LND_safeZone = [getMarkerPos "respawn_start", 1500];
LND_playerCallsign = selectRandom ["Hornet", "Banshee", "Shriek", "Thunderfoot", "Hammer", "Big-Bird", "Alchemist"];


LND_difficulty = ["MissionCAP", 4] call BIS_fnc_getParamValue;

setTimeMultiplier 0.1;

LND_playerVehicles = [];

LND_bluforInfantry = [];

LND_opforAAA = [];
LND_opforSAM = [];
LND_opforRADAR = [];
LND_opforCAP = [];
LND_opforCAS = [];
LND_opforTransportPlane = [];
LND_opforTransportHelo = [];
LND_opforHeloLight = [];
LND_opforHeloAttack = [];

call LND_fnc_loadFactions;
call LND_fnc_loadVehicles;

LND_taskTypes = [];
if(LND_difficulty >= 1 and (count LND_opforTransportHelo > 0 or count LND_opforTransportPlane > 0)) then { LND_taskTypes pushBack LND_fnc_taskTransport };
if(LND_difficulty >= 2 and count LND_taskTypes == 0 and count LND_opforHeloLight > 0) then { LND_taskTypes pushBack LND_fnc_taskTransport };
if(LND_difficulty >= 3 and (count LND_opforHeloAttack > 0 or count LND_opforCAS > 0)) then { LND_taskTypes pushBack LND_fnc_taskCAS; LND_taskTypes pushBack LND_fnc_taskCAS };
if(LND_difficulty >= 4 and count LND_opforCAP > 0) then { LND_taskTypes pushBack LND_fnc_taskCAP; LND_taskTypes pushBack LND_fnc_taskCAP };

LND_taskCounter = 0;
LND_smoke = objNull;
LND_bluforUnits = [];
LND_ffIncidents = 0;

LND_opforTargets = [];


if(LND_intel == 4) then {
	[] spawn {
		while{true} do{
			sleep 0.5;
			{
				private _a = toArray _x;
				_a resize 11;
				if (toString _a == "marker_unit") then {
					deleteMarker _x;
				};
			} forEach allMapMarkers;
			_c = 0;
			{
				_c = _c+1;
			    _marker = createMarkerLocal [format ["marker_unit_%1", _c], getPos _x];

			    if(isPlayer _x) then {
			    	_marker setMarkerColorLocal "ColorYellow";	
			    }
				else{
					_marker setMarkerColorLocal (
						switch (side _x) do {
							case west: { "ColorWEST" };
							case east: { "ColorEAST" };
							case resistance: { "ColorGUER" };
							default { "ColorWhite" };
						}
					);
				};
				_marker setMarkerType "hd_dot";
			} forEach allUnits;
		};
	};
};

if(count LND_taskTypes == 0) then {
	systemChat "No task types enabled!";
	systemChat "The selected faction may not have appropriate aircraft for the selected task-types";
	systemChat "Selected a different faction, or enable more tasks in the lobby parameters";
	systemChat "(Or just enjoy flying around!)";
}
else {
	call LND_fnc_newTask;
};