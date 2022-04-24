scriptName "LND\functions\TaskFramework\fn_spawnOpfor.sqf";
/*
	Author:
		Landric

	Description:
		Spawns a provided set of OPFOR units around a particular position, and optionally provides them a (custom) (set of) waypoint(s)

	Parameter(s):
		Required:
			_vehicles	- array of vehicle classnames
			_position	- position to spawn the vehicles
		Optional:
			_waypoint 	- array of [waypoint type, location, radius]; type can also include "SEEK" to track a given player
	
	Returns:
		bool - success

	Example Usage:
		[
			["O_Plane_Fighter_02_F", "O_Plane_Fighter_02_F"],
			[[getMarkerPos "marker_opfor", 200]],
			["MOVE", getMarkerPos "marker_destination", 250]
		] call LND_fnc_spawnOpfor;
*/

params ["_vehicles", "_position"];
private _waypoint = param [2, []]; // Expected [type, location, radius]

if(LND_intel >= 4) then { systemChat "Spawning OPFOR..."; };


private _group = createGroup east;
{   // forEach _vehicles;

	private _dir = [_position, getMarkerPos "respawn_start"] call BIS_fnc_DirTo;
	
	_v = [[0,0,100], _dir, _x, east] call BIS_fnc_spawnVehicle;
	_v = _v select 0;

	{[_x] joinSilent _group;} forEach crew _v;
	
	if(_v isKindOf "Plane") then { _v flyInHeight 400; };
	_v setVehiclePosition [_position, [], 200, "FLY"];
	//_v setUnloadInCombat [false, false];
	if(_v isKindOf "Plane") then {
		private _speed = 200;
		_v setVelocity [
			(sin _dir * _speed), 
			(cos _dir * _speed), 
			100
		];
	};
	
	_v addEventHandler ["Hit", {
		params ["_unit", "_source", "_damage", "_instigator"];

		if(LND_intel >=4) then { systemChat format ["Vehicle %1 HIT by %2", _unit, _instigator]; };
		[_unit] spawn {
			params ["_unit"];
			sleep 3; // Wait a moment to see if the vehicle is disabled
			if(LND_intel >=4) then { systemChat "Checking if disabled...."; };
			if((not canFire _unit) or (not canMove _unit) or {alive _x} count crew _unit <= 0 ) then {
				if(LND_intel >=4) then { systemChat "Vehicle disabled!"; };
				call LND_fnc_taskSuccessCheck;
			}
			else{
				if(LND_intel >=4) then { systemChat "Vehicle not disabled!"; };
			};
		};
	}];

	_v addEventHandler ["Killed", {
		params ["_unit", "_killer", "_instigator", "_useEffects"];
		if(LND_intel >=4) then { systemChat format ["Vehicle %1 KILLED by %2", _unit, _killer]; };
		call LND_fnc_taskSuccessCheck;
	}];

	// TODO: Move "main" task location if "main" vehicle destroyed

	LND_opforTargets pushBack _v;

	if(LND_intel >= 3) then {
		private _t = format ["tsk%1_%2", LND_taskCounter, (str _v splitString " -:" joinString "_")];
		_task = [true, [_t, format ["tsk%1", LND_taskCounter]], ["", "Destroy Hostiles", _position], [_v, true], "CREATED", -1, false, "destroy"] call BIS_fnc_taskCreate;
		_trg = createTrigger ["EmptyDetector", _position, false];
		_trg setTriggerArea [0, 0, 0, false];
		_trg setVariable ["_v", vehicle _v];
		_trg setVariable ["_task", _task];
		_trg setTriggerStatements 
		[
			"((thisTrigger getVariable ""_task"") call BIS_fnc_taskExists) and (((not canFire (thisTrigger getVariable ""_v"")) and (not canMove (thisTrigger getVariable ""_v""))) or ({alive _x} count crew (thisTrigger getVariable ""_v"") <= 0))",
			"[(thisTrigger getVariable ""_task""), ""SUCCEEDED""] call BIS_fnc_taskSetState; deleteVehicle thisTrigger",
			""
		];
	};
} forEach _vehicles;

if(count _waypoint > 0) then {
	if(count _waypoint != 3) then { throw format ["Unexpected waypoint passed: %1", _waypoint] };
	switch (_waypoint select 0) do {
		case "SAD": {
			_op_waypoint = _group addWaypoint [_waypoint select 1, _waypoint select 2];
			_op_waypoint setWaypointType (_waypoint select 0);
			_group setCombatMode "RED";
		};

		case "SEEK": {
			_group setCombatMode "RED";
			[_group, _waypoint select 1] spawn {
				params ["_opfor", "_player"];
				while{(not (_opfor isEqualTo grpNull)) and alive _player} do {
					private _p = [position _player select 0, position _player select 1];						
					if (count waypoints _opfor > 0) then {
						((waypoints _opfor) select 0) setWaypointPosition [_p, -1];
					}
					else{
						_wp = _opfor addWaypoint [_p, 0];
						_wp setWaypointType "SAD";
						_wp setWaypointCombatMode "RED";
					};
					sleep 3;
				};
			};
		};

		default { 
			_op_waypoint = _group addWaypoint [_waypoint select 1, _waypoint select 2];
			_op_waypoint setWaypointType (_waypoint select 0);
			//throw format ["Unexpected waypoint provided: %1", _waypoint select 0];
		};
	};
};


true