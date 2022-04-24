scriptName "LND\functions\TaskFramework\fn_taskCAP.sqf";
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
		call LND_fnc_taskCAP;
*/

LND_fnc_generateIntel = {

	private _optionalMap = param [0, []];

	private _intelGrammar = createHashMapFromArray [
		["origin", "#hostile# #aircraft# #inbound#"],
		["hostile", ["hostile", "enemy", "OPFOR"]],
		["aircraft", ["aircraft", "fighters", "CAP", "Combat Air Patrol", "fast air", "fixed-wing aircraft"]],
		["inbound", ["inbound", "in the #AO#", "closing on #you#", "en route to #you#"]],
		["AO", ["AO", "area of operations", "vicinity", "area"]],
		["you", ["you", "your location"]]
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
private _taskTitle = if(LND_intel > 0) then { "Intercept enemy CAP" } else { "Combat Air Patrol" };
private _task = [true, format ["tsk%1", LND_taskCounter], ["", _taskTitle, _position],  objNull, true, -1, true, _taskIcon] call BIS_fnc_taskCreate;


private _trg = createTrigger ["EmptyDetector", _position, false];
_trg setTriggerArea [0, 0, 0, false];
_trg setVariable ["_task", _task];
_trg setTriggerStatements 
[
	"({((getPosATL _x) select 2) > 30} count allPlayers) == 0",
	"[""FAILED""] call LND_fnc_taskCleanup; deleteVehicle thisTrigger",
	""
];



{
	private _opforAircraft = [];
	for "_i" from 1 to ([1,3] call BIS_fnc_randomInt) do {
		_opforAircraft pushBack selectRandom LND_opforCAP;
	};
	[
		_opforAircraft,
		_position,
		["SEEK", _x, 0]
	] call LND_fnc_spawnOpfor;
} forEach allPlayers;


if(LND_intel >= 1) then {
	[] call LND_fnc_generateIntel;
	[format ["tsk%1", LND_taskCounter], _position] call BIS_fnc_taskSetDestination;
};

if(LND_intel >= 2) then {
	[format ["tsk%1", LND_taskCounter], LND_opforTargets select 0] call BIS_fnc_taskSetDestination;
};