scriptName "LND\functions\Utilities\fn_groupName.sqf";
/*
	Author:
		Landric

	Description:
		Returns the human-readable name (i.e. trims the first two characters) of a given group

	Parameter(s):
		_group - the group

	Returns:
		string - name of the passed group

	Example Usage:
		[group player] call LND_fnc_groupName; // Returns "Alpha 1-1"
*/
params ["_group"];
[format ["%1", _group], 2] call BIS_fnc_trimString