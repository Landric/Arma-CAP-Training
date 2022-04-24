scriptName "LND\functions\Utilities\fn_getPlayerPositions.sqf";
/*
	Author:
		Landric

	Description:
		Returns the position of all players, with an optional radius
		(Useful for creating white/blacklists for BIS_fnc_randomPos)

	Parameter(s):
		Optional:
			_radius	- a radius to be appended to each position (for generating position white/blacklists)

	Returns:
		Array of positions, or array of [position, radius] pairs

	Example Usage:
		[] call LND_fnc_getPlayerPositions; // Returns [[0, 0], [10, 10], [20, 20]]
		[100] call LND_fnc_getPlayerPositions; // Returns [[[0, 0], 100], [[10, 10], 100], [[20, 20], 100]]		
*/

private _radius = param [0, -1];
private _positions = [];

{
	_positions pushBack (getPos _x);
} forEach allPlayers;


if(_radius > 0) then {

	_rpos = [];
	{
		_rpos pushBack [_x, _radius]
	} foreach _positions;
	_positions = _rpos;
};

_positions