scriptName "LND\functions\TaskFramework\fn_taskCleanup.sqf";
/*
	Author:
		Landric

	Description:
		Completes the current task, cleans up any remaining units/wrecks/markers, and calls LND_fnc_newTask

	Parameter(s):
		_state 	- state the current task should be completed with, i.e. "SUCCEEDED"/"FAILED"
	
	Returns:
		None

	Example Usage:
		["SUCCEEDED"] call LND_fnc_taskCleanup;
*/

params ["_state"];

if(!isServer) exitWith { }; // TODO: is this needed? Does it hinder?

if (not (format ["tsk%1", LND_taskCounter] call BIS_fnc_taskCompleted)) then {

	[format ["tsk%1", LND_taskCounter], _state] call BIS_fnc_taskSetState;	

	{ if(side _x != west and not (_x in LND_activeAA) ) then {deleteVehicle _x }; } forEach allUnits;
	{ deleteVehicle _x } forEach LND_bluforUnits;
	{ deleteVehicle _x } forEach allDead;
	{ if(not (_x in LND_playerVehicles)) then { deleteVehicle _x; }; } forEach vehicles;
	if(not isNull LND_smoke) then {	deleteVehicle LND_smoke; };

	// if(LND_AARefresh > 0 and LND_taskCounter % LND_AARefresh == 0) then {
	// 	{
	// 		private "_a";
	// 		_a = toArray _x;
	// 		_a resize 9;
	// 		if (toString _a isEqualTo "marker_aa") then {
	// 			deleteMarker _x;
	// 		};
	// 	} forEach allMapMarkers;
	// };

	LND_opforTargets = [];
	LND_bluforUnits = [];
	LND_ffIncidents = 0;

	[] spawn {
		sleep 3;
		call LND_fnc_newTask;
	};
};