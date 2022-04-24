scriptName "LND\functions\TaskFramework\fn_taskIntel.sqf";
/*
	Author:
		Landric

	Description:
		Generates an intel briefing (based on global LND_intel level) for the current task, displays it in sideChat, and sets the current task's description

		Intel levels are:
		0 (None) 		- Grid coordinates only, no task marker
		1 (Sparse)		- Grid coordinates, task marker, mission type
		2 (Moderate)	- As above, plus opfor composition/strength, approximate markers on AA positions
		3 (Maximal)		- As above, plus sub tasks/map markers on groups, accurate markers on AA positions
		4 (Debug)		- All of the above, plus real-time map markers for every unit, and additional debug information printed to systemChat

		// TODO: If composition is tied to difficulty, there's no (real) benefit to including it

	Parameter(s):
		Required:
			- _position - position of the task, used to generate grid coordinates
		Optional:
			- _caller 	- the desired "caller" on the radio; can be a group, or a string (e.g. "HQ", "BLU", etc.)

	Returns:
		None

	Example Usage:
		[getMarkerPos "marker_task", "HQ"] call LND_fnc_taskIntel;	
*/


LND_fnc_displayIntel = {
	params ["_intelString"];
	private _caller = param [1, "HQ"];

	{ _caller sideChat _x } forEach (_intelString splitString (toString [13,10]));

	_desc = format ["tsk%1", LND_taskCounter] call BIS_fnc_taskDescription;
	[
		format ["tsk%1", LND_taskCounter],
		[
			format ['"%1"', ((_intelString splitString (toString [13,10])) joinString "<br/>")],
			_desc select 1,
			_desc select 2
		]
	] call BIS_fnc_taskSetDescription;	
};

params ["_position", "_caller"];

private _intelStrings = [];

private "_callerName";
if(typeName _caller isEqualTo "GROUP") then {
	_callerName = _caller call LND_fnc_groupName;
	_caller = leader _caller;
}
else {
	_callerName = switch(_caller) do {
		case "HQ":    {"Crossroad"};
		case "BLU":   {"Broadway"};
		case "OPF":   {"Griffin"};
		case "IND":   {"Phalanx"};
		case "IND_G": {"Slingshot"};
		default       {"Unknown"};
	};
	_caller = [west, _caller];
};

private "_calleeName";
if(isMultiplayer) then {
	_calleeName = format ["%1-Wing", LND_playerCallsign];
}
else {
	_calleeName = format ["%1 1-1", LND_playerCallsign];
};


private _targetCount = createHashMap;
{
	private _name = [typeOf _x] call LND_fnc_getRadioName;
	if(_name in _targetCount) then {
		_targetCount set [_name, (_targetCount get _name)+1];
	}
	else{
		_targetCount set [_name, 1];
	};
} forEach LND_opforTargets;


private _composition = [];
{

	if(_y > 1) then {
		private _lastChar = _x select [(count _x)-1];
		
		if(_lastChar isEqualTo "y") exitWith {
			_x = (_x select [0, (count _x)-1]) + "ies";
		};
		if(_lastChar isEqualTo "s") exitWith {
			_x = _x + "es";
		};
		_x = _x + "s";
	}
	else {
		private _a = toArray _x; 
		if ((_x select [0, 1]) in ["a", "e", "i", "o", "u"]) then {
			_x = "an "+_x;
		}
		else{
			_x = "a "+_x;
		};		
	};

	if(_y > 5) then {
		_composition pushBack (format ["#multiple# %1", _x]);
	} else {
		if(_y > 1) then {
			_composition pushBack (format ["#%1# %2", _y, _x]);
		}
		else{
			_composition pushBack _x;		
		};
	};	
} forEach _targetCount;

if(count _composition > 1) then {
	private _last = _composition select ((count _composition) - 1);
	_composition = _composition - [_last];

	if(count _composition > 1) then {
		_composition = format ["%1, and %2", (_composition joinString ", "), _last];
	}
	else{
		_composition = format ["%1 and %2", _composition select 0, _last];
	};
}
else {
	_composition = _composition select 0;
};

_intelGrammar = createHashMapFromArray [
	["origin", format ["#greeting#,#intro# over.%1#request.capitalise# #out#.", endl]],

	["greeting", [
		format ["%1, this is %2", _calleeName, _callerName],
		format ["Hello %1, hello %1, this is %2", _calleeName, _callerName],
		format ["Hello %1", _calleeName],
		format ["%1, %2", _calleeName, _callerName]
	]],
	["intro", [
		"",
		" message",
		" tasking for you,",
		" #CAP# mission for you,",
		" priority tasking for you,"
	]],
	["request", [
		format ["Requesting #CAP# #at# grid %1", mapGridPosition _position],
		format ["#CAP# #required# #at# grid %1", mapGridPosition _position]
	]],
	["CAP", ["CAP", "Combat Air Patrol"]],
	["at", ["at", "in the vicinity of"]],
	["required", ["required", "requested", "needed", "wanted"]],

	["composition", ["expected composition is #units#", "reports indicate composition is #units#"]],
	["units", _composition],

	["2", ["two",   "#multiple#"]],
	["3", ["three", "#multiple#"]],
	["4", ["four",  "#multiple#"]],
	["5", ["five",  "#multiple#"]],
	["multiple", ["multiple", "several"]],


	["out", [
		"Out",
		"Out to you"
	]]
];

switch(LND_intel) do {
	case 0: {_intelGrammar set ["origin", format ["#greeting#,#intro# over.%1#request.capitalise# #out#.", endl]];};
	case 1;
	case 2: {_intelGrammar set ["origin", format ["#greeting#,#intro# over.%1#request.capitalise#. #mission.capitalise#. #out#.", endl]];};
	case 3;
	case 4: {_intelGrammar set ["origin", format ["#greeting#,#intro# over.%1#request.capitalise#. #mission.capitalise#.%1#composition.capitalise#. #out#.", endl]];};
};


// Incorporate any task-specific information (that has previously been pushed to the task description) as part of the intel package
_intelGrammar set ["mission", (format ["tsk%1", LND_taskCounter] call BIS_fnc_taskDescription) select 0 select 0]; // Not sure why this requires two "select 0"s?!

_intelString = [_intelGrammar] call LND_fnc_parseGrammar;
[_intelString, _caller] call LND_fnc_displayIntel;
_intelString