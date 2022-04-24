scriptName "LND\functions\Utilities\fn_getRadioName.sqf";
/*
	Author:
		Landric

	Description:
		Returns the display name of a given (vehicle) classname, stripping off any parenthesised content from the end

	Parameter(s):
		_classname - String, classname of the (vehicle) object

	Returns:
		string - parenthesis-stripped display-name

	Example:
		["RHS_Mi8mt_Cargo_vvsc"] call LND_fnc_getRadioName; // Returns "Mi-8MT" (instead of "Mi-8MT (Cargo)")
*/

params ["_classname"];

private _display = getText (configFile >> "CfgVehicles" >> _classname >> "DisplayName");

if (not ((_display select [(count _display)-1, 1]) isEqualTo ")")) exitWith {
	trim _display
};

private _depth = 0;
private _outString = "";
{
	if(toString [_x] isEqualTo "(") then {
		_depth = _depth + 1;
	}
	else{
		if(toString [_x] isEqualTo ")") then {
			_depth = _depth - 1;
		}
		else{
			if(_depth <= 0) then {
				_outString = _outString + (toString [_x]);
			};
		};
	};
} forEach toArray _display;

trim _outString