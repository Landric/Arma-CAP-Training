scriptName "LND\functions\TaskFramework\fn_taskCAS.sqf";
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
		call LND_fnc_taskCAS;
*/

LND_fnc_generateIntel = {

	private _optionalMap = param [0, []];

	private _intelGrammar = createHashMapFromArray [
		["origin", "we're under attack from #hostile# #aircraft##assist#"],
		["hostile", ["hostile", "enemy", "OPFOR"]],
		["aircraft", ["aircraft", "CAS", "Close Air Support"]],
		["assist", ["", ", need #urgent# assistance"]],
		["urgent", ["urgent", "immediate"]]
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


LND_fnc_spawnBlufor = {
	params ["_position"];

	private _blufor_group = [_position, west, (selectRandom LND_bluforInfantry)] call BIS_fnc_spawnGroup;
	private _blu_waypoint = _blufor_group addWaypoint [_position, 20];
	_blu_waypoint setWaypointType "HOLD";
	{
		_x addeventhandler ["handledamage", {
			(_this select 2) / 4
		}];
		_x addEventHandler ["Killed", {
			params ["_unit", "_killer"];
			if(isPlayer _killer) then {
				private _ffString = format ["%1, BLUE ON BLUE, SAY AGAIN, BLUE ON BLUE, THOSE ARE FRIENDLIES!", toUpper LND_playerCallsign];
				if (isNull leader _unit || not alive leader _unit) then {
					[west, "HQ"] sideChat _ffString;
				}
				else{
					leader _unit sideChat _ffString;
				};

				LND_ffIncidents = LND_ffIncidents + 1;

				if(LND_ffIncidents > 2) then {
					["FAILED"] call LND_fnc_taskCleanup;
				};
			};
			LND_bluforUnits = LND_bluforUnits - [_unit];
			if({alive _x} count LND_bluforUnits < 1) then {
				["FAILED"] call LND_fnc_taskCleanup;
			};
		}];
	} forEach units _blufor_group;
	LND_bluforUnits append units _blufor_group;

	LND_smoke = "SmokeShellBlue_Infinite" createVehicle _position;
	LND_smoke attachTo [LND_bluforUnits select 0];
};


// TODO: Generate urban variant of task, with blufor garrisoned in building

params ["_position"];

private _taskIcon = if(LND_intel > 0) then { "defend" } else { "" };
private _taskTitle = if(LND_intel > 0) then { "Intercept enemy CAS" } else { "Combat Air Patrol" };
private _task = [true, format ["tsk%1", LND_taskCounter], ["", _taskTitle, _position],  objNull, true, -1, true, _taskIcon] call BIS_fnc_taskCreate;


private _bluforSpawn = [0,0];
private _radius = 4000;
private _blacklist = ["water", LND_safeZone];
_blacklist append ([2000] call LND_fnc_getPlayerPositions);
while { _bluforSpawn isEqualTo [0,0]} do {
	private _whitelist = [[_position, _radius]];	
	_bluforSpawn = [_whitelist, _blacklist] call BIS_fnc_randomPos;
	_radius = _radius + 2000;
};
[_bluforSpawn] call LND_fnc_spawnBlufor;


private _possibleTargets = +LND_opforCAS;
_possibleTargets = _possibleTargets + LND_opforHeloAttack;
private _target = selectRandom _possibleTargets;
{
	private _opforAircraft = [];
	for "_i" from 1 to ([1,3] call BIS_fnc_randomInt) do {
		_opforAircraft pushBack _target;
	};

	[
		_opforAircraft,
		_position,
		["SAD", _bluforSpawn, 0]
	] call LND_fnc_spawnOpfor;
} forEach allPlayers;


if(LND_intel >= 1) then {
	[] call LND_fnc_generateIntel;
};

if(LND_intel >= 1) then {
	[format ["tsk%1", LND_taskCounter], _bluforSpawn] call BIS_fnc_taskSetDestination;
};

if(LND_intel >= 2) then {
	[format ["tsk%1", LND_taskCounter], LND_bluforUnits select 0] call BIS_fnc_taskSetDestination;
};