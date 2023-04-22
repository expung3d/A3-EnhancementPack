if(!isNull (findDisplay 312) && {!isNil "this"} && {!isNull this}) then {
	deleteVehicle this;
};

if !(missionNamespace getVariable ["MAZ_EP_CoreEnabled",false]) exitWith {
	[] spawn {
		private _display = findDisplay 46;
		if(!isNull (findDisplay 312)) then {
			_display = findDisplay 312;
		};
		playSound "addItemFailed";
		[
			parseText "<t size='1.3' color='#00BFBF'>You're missing the Enhancement Pack - Core!</t><br/>
			<t align='center'>To use the Enhancement Pack the Core pack must be ran prior. This will add the systems for keybinds, holstering, earplugs, etc. 
			<br/>Download it from the </t><t align='center' underline='1'><a colorLink='#00BFBF' href=''>Workshop (by Z.A.M. Arma)</a>.</t>", 
			"Missing Core Dependency", 
			true, 
			true,
			_display
		] call BIS_fnc_guiMessage;
		showChat true;
	};
};
if(missionNamespace getVariable ["MAZ_EP_forcedFirstPersonEnabled",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - First Person Only already running!";};

private _varName = "MAZ_System_EnhancementPack_1PP";
private _myJIPCode = "MAZ_EPSystem_1PP_JIP";

MAZ_EP_forcedFirstPersonEnabled = true;
publicVariable 'MAZ_EP_forcedFirstPersonEnabled';

private _value = (str {
	MAZ_fnc_forceFirstPersonCarrier = {
		MAZ_fnc_forceFirstPerson = {
			while {MAZ_EP_forcedFirstPersonEnabled} do {
				if(cameraView == "External") then {
					player switchCamera "Internal";
				};
				sleep 0.1;
			};
		};
		[] spawn MAZ_fnc_forceFirstPerson;
	};
	if(!isNil "MAZ_EP_fnc_addDiaryRecord") then {
		["Force First Person", "This is so self explanatory that if I need to explain it to you you shouldn't be here."] call MAZ_EP_fnc_addDiaryRecord;
	};
	call MAZ_fnc_forceFirstPersonCarrier;
}) splitString "";

_value deleteAt (count _value - 1);
_value deleteAt 0;

_value = _value joinString "";
_value = _value + "removeMissionEventhandler ['EachFrame',_thisEventHandler];";
_value = _value splitString "";

missionNamespace setVariable [_varName,_value,true];

[[_varName], {
	params ["_ding"];
	private _data = missionNamespace getVariable [_ding,[]];
	_data = _data joinString "";
	addMissionEventhandler ["EachFrame", _data];
}] remoteExec ['spawn',0,_myJIPCode];