scriptName "LND\functions\TaskFramework\fn_taskSuccessCheck.sqf";
/*
	Author:
		Landric

	Description:
		Determines if the requirements of the current task have been met;
		Requirements are:
			100% of vehicles must be gun AND mobility killed, or crew killed

	Parameter(s):
		None

	Returns:
		None

	Example Usage:
		call LND_fnc_taskSuccessCheck;	
*/

if(LND_intel >=4) then {
	systemChat "Checking task success...";
	systemChat format ["%1 targets still active", {(canFire _x || canMove _x) and ({alive _x} count crew _x) > 0} count LND_opforTargets];
};

if( {(canFire _x || canMove _x) and ({alive _x} count crew _x) > 0} count LND_opforTargets <= 0) then {
	["SUCCEEDED"] call LND_fnc_taskCleanup;
};