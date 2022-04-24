scriptName "LND\functions\TaskFramework\fn_newTask.sqf";
/*
	Author:
		Landric

	Description:
		Creates a suitable Combat Air Patrol task, based on the allowed list of functions in LND_taskTypes

	Parameter(s):
		None
	
	Returns:
		None

	Example Usage:
		call LND_fnc_newTask;
*/


// TODO: Wait until (all?) players are airborne before starting a task

if(!isServer) exitWith { }; // TODO: Probably not needed? Does it hinder?

LND_taskCounter = LND_taskCounter + 1;

if(LND_intel >= 4) then { systemChat format["Generating task #%1...", LND_taskCounter]; };


_whitelist = ([15000] call LND_fnc_getPlayerPositions);
_blacklist = [LND_safeZone];
_blacklist append ([2000] call LND_fnc_getPlayerPositions);
_position = [_whitelist, _blacklist] call BIS_fnc_randomPos;

[_position] call selectRandom LND_taskTypes;


// TODO: Should we even bother about AAA/SAMs for this mission?

// _whitelist = [];
// _whitelist append _aaCorridors;
// _whitelist pushBack [_position, 1000];
// _blacklist = ["water", LND_safeZone, [_position, 500]];
// _blacklist append ([700] call LND_fnc_getPlayerPositions);

// if(count LND_activeAA == 0 and (LND_aaaThreat > 0 or LND_samThreat > 0)) then {

// 	for "_i" from 0 to ([0, 2] call BIS_fnc_randomInt) do {
// 		if(([1, 100] call BIS_fnc_randomInt) <= LND_aaaThreat) then {
// 			_p = [_whitelist, _blacklist] call BIS_fnc_randomPos;
// 			_p = [
// 				_p,						// centre
// 				0,						// minDist
// 				100,					// maxDist
// 				10,						// objDist
// 				0,						// waterMode (land)
// 				0.2,					// maxGrad
// 				0,						// shoreMode (land)
// 				_blacklist - ["water"]  // blacklist
// 			] call BIS_fnc_findSafePos;

// 			if (not (_p isEqualTo [0, 0])) then {
// 				_aa_group = [_p, east, selectRandom LND_opforManpads] call BIS_fnc_spawnGroup;
// 				_aa_group setFormation "DIAMOND";

// 				if(LND_intel >= 2) then {
// 					private _radius = switch (LND_intel) do {
// 						case 2: { 200 };
// 						case 3: { 100 };
// 						default {   0 };
// 					};
// 					private _markerPos = [[[_p, _radius]]] call BIS_fnc_randomPos;
// 					_m = createMarkerLocal [format ["marker_aa_%1", groupId _aa_group], _markerPos];
// 					_m setMarkerType "o_antiair";
// 					if(_radius > 0) then {
// 						_m = createMarkerLocal [format ["marker_aa_area_%1", groupId _aa_group], _markerPos];
// 						_m setMarkerShapeLocal "ELLIPSE";
// 						_m setMarkerSizeLocal [_radius, _radius];
// 						_m setMarkerColorLocal "ColorEAST";
// 						_m setMarkerBrushLocal "DiagGrid";
// 						_m setMarkerAlpha 0.5;
// 					};
// 				};			
// 			};
// 		}
// 		else {
// 			break;
// 		};
// 	};
// 	_whitelist = [];
// 	_whitelist append _aaCorridors;
// 	_whitelist pushBack [_position, 3000];
// 	_blacklist = ["water", LND_safeZone, [_position, 1000]];
// 	_blacklist append ([2000] call LND_fnc_getPlayerPositions);
// 	if(([1, 100] call BIS_fnc_randomInt) <= LND_samThreat) then {
// 		_p = [_whitelist, _blacklist] call BIS_fnc_randomPos;
// 		_p = [
// 			_p,						// centre
// 			0,						// minDist
// 			100,					// maxDist
// 			10,						// objDist
// 			0,						// waterMode (land)
// 			0.2,					// maxGrad
// 			0,						// shoreMode (land)
// 			_blacklist - ["water"]  // blacklist
// 		] call BIS_fnc_findSafePos;
// 		if (not (_p isEqualTo [0, 0])) then {
// 			_aaa_vic = [_p, random 360, selectRandom LND_opforAAA, east] call BIS_fnc_spawnVehicle;

// 			if(LND_intel >= 2) then {
// 				private _radius = switch (LND_intel) do {
// 					case 2: { 200 };
// 					case 3: { 100 };
// 					default {   0 };
// 				};
// 				private _markerPos = [[[_p, _radius]]] call BIS_fnc_randomPos;
// 				_m = createMarkerLocal [format ["marker_aa_%1", groupId _aa_group], _markerPos];
// 				_m setMarkerType "o_antiair";
// 				if(_radius > 0) then {
// 					_m = createMarkerLocal [format ["marker_aa_area_%1", groupId _aa_group], _markerPos];
// 					_m setMarkerShapeLocal "ELLIPSE";
// 					_m setMarkerSizeLocal [_radius, _radius];
// 					_m setMarkerColorLocal "ColorEAST";
// 					_m setMarkerBrushLocal "DiagGrid";
// 					_m setMarkerAlpha 0.5;
// 				};
// 			};
// 		};
// 	};
// };

if(count LND_bluforUnits > 0) then {
	[_position, group (LND_bluforUnits select 0)] call LND_fnc_taskIntel;
}
else {
	[_position, selectRandom ["HQ", "BLU"]] call LND_fnc_taskIntel;
};


format ["tsk%1", LND_taskCounter] call BIS_fnc_taskSetCurrent;