scriptName "LND\functions\TaskFramework\fn_taskTransport.sqf";
/*
	Author:
		Landric

	Description:
		Creates a Combat Air Patrol task to destroy hostile aircraft

	Parameter(s):
		_position - position to create the task
	
	Returns:
		None

	Example Usage:
		call LND_fnc_taskTransport;
*/

LND_fnc_generateIntel = {

	private _optionalMap = param [0, []];

	private _intelGrammar = createHashMapFromArray [
		["origin", "Enemy transport aircraft in the AO"]
	];

	if(count _optionalMap > 0) then {
		_intelGrammar merge _optionalMap;
	};

	private _intelString = [_intelGrammar] call LND_fnc_parseGrammar;

	private _desc = format ["tsk%1", LND_taskCounter] call BIS_fnc_taskDescription;
	[
		format ["tsk%1", LND_taskCounter],
		[
			_intelString,
			_desc select 1,
			_desc select 2
		]
	] call BIS_fnc_taskSetDescription;	
};

params ["_position"];

private _taskIcon = if(LND_intel > 0) then { "attack" } else { "" };
private _taskTitle = if(LND_intel > 0) then { "Intercept enemy transport" } else { "Combat Air Patrol" };
private _task = [true, format ["tsk%1", LND_taskCounter], ["", _taskTitle, _position],  objNull, true, -1, true, _taskIcon] call BIS_fnc_taskCreate;

private _opforAircraft = [];

private _transportType = [];
if (count LND_opforTransportPlane > 0) then { _transportType pushBack LND_opforTransportPlane };
if (count LND_opforTransportHelo > 0) then { _transportType pushBack LND_opforTransportHelo };
if (count LND_opforHeloLight > 0) then { _transportType pushBack LND_opforHeloLight };
_transportType = selectRandom _transportType;
// TODO: Do something to detect what type of transport is selected, for pushing to the intel description

for "_i" from 1 to count allPlayers do {
	for "_j" from 1 to ([2,4] call BIS_fnc_randomInt) do {
		_opforAircraft pushBack selectRandom _transportType;
	};
};

{
  // code...
} forEach LND_activeAA; //TODO: generate blacklist

private _destination = [nil, ["water", [_position, 10000], LND_safeZone] ] call BIS_fnc_randomPos;

[
	_opforAircraft,
	_position,
	["MOVE", _destination, 250]
] call LND_fnc_spawnOpfor;

if(LND_intel >= 1) then {
	[true, [format ["tsk%1_dest", LND_taskCounter], format ["tsk%1", LND_taskCounter]], ["", "Projected destination", _destination],  _destination, true, -1, true, "land"] call BIS_fnc_taskCreate;
	[format ["tsk%1", LND_taskCounter], _position] call BIS_fnc_taskSetDestination;
	[] call LND_fnc_generateIntel;
};

if(LND_intel >= 2) then {
	[format ["tsk%1", LND_taskCounter], LND_opforTargets select 0] call BIS_fnc_taskSetDestination;
};