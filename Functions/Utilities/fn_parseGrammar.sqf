scriptName "LND\functions\Utilities\fn_parseGrammar.sqf";
/*
	Author:
		Landric

	Description:
		Navigates a Tracery-like grammar, and uses it to generate a string
		This is by no means needed, but it was fun to write

		Keys can optionally contain:
			.capitalise - capitalises the start of the replacement string
			.a 			- naively adds an indefinite articles (i.e. "a"/"an") to the start of the replacement string
			.s 			- naively pluralises the replacement string

	Parameter(s):
		_grammar - Hashmap grammar; one key must be "origin"

	Returns:
		string generated from the provided grammar

	Example:
		_grammar = createHashMapFromArray [
			["origin", "Some text describing #fruit.a# or #other food#"],
			["fruit", ["apple","banana","cherry"]],
			["other food", ["#baked good#", "#fried food#"]],
			["baked good", ["croissant","cupcake","muffin"]],
			["fried food", ["chips", "mars bar", "fish"]]
		];

		[_grammar] call LND_fnc_parseGrammar; // Returns "Some text describing a banana or croissant"
*/

params ["_grammar"];

// https://forums.bohemia.net/forums/topic/216673-quick-stringreplace/
GOM_fnc_replaceInString = {
	params ["_string","_find","_replaceWith"];
	_pos = (_string find _find);
	if (_pos isEqualTo -1) exitWith {_string};
	[
		[
			(_string select [0,_pos]),
			_replaceWith,
			_string select [_pos + count _find,count _string]
		] joinString "",
		_find,
		_replaceWith
	] call GOM_fnc_replaceInString;
};

LND_fnc_getKeys = {
	params ["_string"];
	private _keys = [];
	private _recording = false;
	private _recordedString = "";
	{
		if((toString [_x]) isEqualTo "#") then {
			if(_recording) then {
				_recording = false;
				_keys pushBack _recordedString;
				_recordedString = "";
			}
			else{
				_recording = true;
			};
		}
		else{
			if(_recording) then {
				_recordedString = _recordedString + (toString [_x]);
			};
		};
	} forEach toArray _string;
	_keys
};

LND_fnc_replaceKeys = {
	params ["_string"];
	{
		private _key = _x;

		private _indefinite = not ((_x find ".a") isEqualTo -1);
		_key = [_key,".a",""] call GOM_fnc_replaceInString;

		private _capitalise = not ((_x find ".capitalise") isEqualTo -1);
		_key = [_key,".capitalise",""] call GOM_fnc_replaceInString;

		private _pluralise = not ((_x find ".s") isEqualTo -1);
		_key = [_key,".s",""] call GOM_fnc_replaceInString;

		_v = _grammar get _key;

		if(isNil "_v") then {
			continue;
		};

		if(typeName _v isEqualTo "ARRAY") then {
			_v = selectRandom _v;
		};

		_v = ([_v] call LND_fnc_replaceKeys);

		if(_indefinite) then {
			private _a = toArray _v; 
			if ((_v select [0, 1]) in ["a", "e", "i", "o", "u"]) then {
				_v = "an "+_v;
			}
			else{
				_v = "a "+_v;
			};
		};
		if(_capitalise) then {
			_v = format ["%1%2", (toUpper (_v select [0,1])), _v select [1]];
		};
		if(_pluralise) then {
			private _lastChar = _v select [(count _v)-1];
			
			if(_lastChar isEqualTo "y") exitWith {
				_v = (_v select [0, (count _v)-1]) + "ies";
			};
			if(_lastChar isEqualTo "s") exitWith {
				_v = _v + "es";
			};
			_v = _v + "s";
		};
		_string = [_string, format ["#%1#", _x], _v] call GOM_fnc_replaceInString;
	} forEach ([_string] call LND_fnc_getKeys);
	_string
};

[_grammar get "origin"] call LND_fnc_replaceKeys