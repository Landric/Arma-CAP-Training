scriptName "LND\functions\Utilities\fn_garrisonBuilding.sqf";
/*
	Author:
		Landric

	Description:
		Creates a provided set of units, and garrisons a given building

	Parameter(s):
		Required:
			_building	- the building to garrison
			_units 		- array of units
		Optional:
			_side 		- the side to create the units on

	Returns:
		None

	Example Usage:
		Not yet implemented
*/

params ["_building", "_units"];
private _side = param [2, east];

throw "Not yet implemented";

private _positions = _building buildingPos -1;

if(count _positions <= 0) then {
	throw "Not a building, or not enterable!";
};

