scriptName "LND\functions\LoadMods\fn_loadVehicles.sqf";
/*
	Author:
		Landric

	Description:
		Loads a predefined list of vehicles from compatible mods if they are loaded, and spawns them at predefined markers

	Parameter(s):
		None
	
	Returns:
		None

	Example Usage:
		call LND_fnc_loadVehicles;
*/

LND_fnc_addVehicleScripts = {
	params ["_vehicle"];

	LND_playerVehicles pushBack _vehicle;

	_vehicle setVariable ["_respawnPos", getPos _vehicle];
	_vehicle setVariable ["_respawnDir", getDir _vehicle];
	
	_vehicle addEventHandler ["Killed", {
		params ["_unit", "_killer", "_instigator", "_useEffects"];
		{ _x setDamage 0; _x setPos getMarkerPos "respawn_start"; } forEach crew _unit;
		_unit setPos [0,0,0];
		_type = typeOf _unit;
		_pos = _unit getVariable "_respawnPos";
		_dir = _unit getVariable "_respawnDir";
		deleteVehicle _unit;
		LND_playerVehicles = LND_playerVehicles - [objNull];

		[_type, _pos, _dir] spawn {
			params ["_type", "_pos", "_dir"];
			sleep 0.5;
			_v = _type createVehicle _pos;
			_v setDir _dir;
			[_v] call LND_fnc_addVehicleScripts;
		};
	}];

	if (["RepairOnDemand", 1] call BIS_fnc_getParamValue == 1) then {
		_vehicle addAction [ 
			"Repair and Resupply", 
			{ 
				_target = _this select 0;
				_target setDamage 0;
				_target setFuel 1;
				_target setVehicleAmmo 1;
				{ _x setDamage 0; } forEach crew _target;
			}, 
			nil, 
			10, 
			false, 
			true 
		];
	};
	
};

_plane_locations = [];
{
	private "_a";
	_a = toArray _x;
	_a resize 12;
	if (toString _a isEqualTo "marker_plane") then {
		_plane_locations pushBack _x;
	};
} forEach allMapMarkers;

private _dir = 68;
_mod_planes = ["B_AMF_PLANE_FIGHTER_02_F", "rhsusf_f22", "rhs_mig29s_vvs", "RHS_T50_vvs_generic_ext", "rhssaf_airforce_o_l_18_101", "vn_b_air_f4c_cap"];
{
	if(count _plane_locations < 1) then {
		break;
	};
	_plane = _x createVehicle (getMarkerPos (_plane_locations select 0));
	if(isNull _plane) then { continue; }
	else {
		if(_dir == 221) then {
			_plane setDir 221;
			_dir = 68;
		}
		else{
			_plane setDir 68;
			_dir = 221;
		};
		// TODO: better to deliberately choose the spawn location in editor so that it is always (say) south, for cross-map compatibility
		_plane_locations deleteAt 0;
	};
} forEach _mod_planes;


{
	[_x] call LND_fnc_addVehicleScripts;
} forEach vehicles;