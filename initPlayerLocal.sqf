
params ["_player", "_didJIP"];

_player createDiaryRecord ["Diary", ["CAS Training", "Welcome to Combat Air Patrol Training!<br/><br/>Complete an infinite amount of missions in order to hone your skills in a variety of aircraft"]];

if(isClass(configFile >> "CfgPatches" >> "ace_interaction")) then {
	_player addItem "ACE_Flashlight_XL50";
	_player addItem "ACE_MapTools";

	for "_i" from 0 to 7 do {
		_player addItem "ACE_packingBandage";
		_player addItem "ACE_quikclot";	
	};
};

if( ["_playerDamage", 1] call BIS_fnc_getParamValue == 0) then {
	_player allowDamage false;
};

if( ["_playerDamage", 1] call BIS_fnc_getParamValue == 1) then {
	_player addeventhandler ["handledamage",{ (_this select 2) / 6 }];
};


if( ["RespawnOnDemand", 1] call BIS_fnc_getParamValue == 1) then {

	startPos = getPos _player;
	startDir = getDir _player;

	_player addAction [  
		"Respawn",  
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			_caller setDamage 0; 
			_caller setPos startPos;
			_caller setDir startDir;
			_caller setVelocity [0, 0, 0];
		},  
		nil,  
		10,  
		false,  
		true,
		"",
		"_originalTarget isEqualTo _this",
		50,
		true
	];
};


_player addEventHandler ["GetOutMan", {
	params ["_unit", "_role", "_vehicle", "_turret"];

	if(!alive _vehicle) then {
		_unit setDamage 0;
		_unit setPos startPos;
		_unit setDir startDir;
		_unit setVelocity [0, 0, 0];
	}
	else{
		if (count crew _vehicle == 0) then {
			[_vehicle] spawn {
				params ["_vehicle"];

				waitUntil {
					sleep 1; 
					private _abandoned = true;
					{
						if(_x distance _vehicle < 100) then { _abandoned = false; break; };
					} forEach allPlayers;
					_abandoned or count crew _vehicle > 0
				};	
				if (count crew _vehicle == 0) then {
					_vehicle setPos [0,0,0];
					_vehicle setDamage 1;
				};
			};
		};
	};
}];


_player addEventHandler ["HandleRating", {
	params ["_unit", "_rating"];

	// Prevent players being turned "renegade" after crashing
	// (or killing friendlies)
	// This is a practice scenario after all
	0
}];