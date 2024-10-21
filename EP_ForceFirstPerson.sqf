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

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["Force First Person","Whether to enable the Force First Person system.","MAZ_EP_forcedFirstPersonEnabled",true,"TOGGLE",[],"MAZ_FFP"] call MAZ_EP_fnc_addNewSetting;
	["Allow 3PP in Vehicles (All)","Whether to allow players to use third person while in vehicles.","MAZ_EP_FFP_AllowVehicle",false,"TOGGLE",[],"MAZ_FFP"] call MAZ_EP_fnc_addNewSetting;
	["Allow 3PP in Vehicles (Driver Only)","Whether to allow vehicle drivers to use third person, but not the crew.","MAZ_EP_FFP_DriverOnly",false,"TOGGLE",[],"MAZ_FFP"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_fnc_forceFirstPersonCarrier = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_FFP"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};
		MAZ_FFP_fnc_canEnter3PP = {
			if !(MAZ_EP_forcedFirstPersonEnabled) exitWith {true};
			private _veh = vehicle player;
			if(_veh == player) exitWith {false};
			if(MAZ_EP_FFP_AllowVehicle) exitWith {true};
			if(MAZ_EP_FFP_DriverOnly && (driver _veh == player || currentPilot _veh == player)) exitWith {true};
			false; 
		};

		if(!isNil "MAZ_FFP_DEH_KeyDown_ForceFirstPerson") then {
			(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_FFP_DEH_KeyDown_ForceFirstPerson];
		};
		MAZ_FFP_DEH_KeyDown_ForceFirstPerson = (findDisplay 46) displayAddEventHandler ["KeyDown", {
			params ["_display","_key"];
			if !(_key in (actionKeys "personView")) exitWith {};
			private _return = false;
			if(cameraView != "External" && {!(call MAZ_FFP_fnc_canEnter3PP)}) then {
				_return = true;
			};
			_return
		}];

		if(!isNil "MAZ_FFP_EH_GetOutMan_3PP") then {
			player removeEventHandler ["GetOutMan",MAZ_FFP_EH_GetOutMan_3PP];
		};
		MAZ_FFP_EH_GetOutMan_3PP = player addEventHandler ["GetOutMan", {
			if(cameraView == "External" && !(call MAZ_FFP_fnc_canEnter3PP)) then {
				player switchCamera "Internal";
			};
		}];
		if(!isNil "MAZ_EH_SeatSwitchedMan_3PP") then {
			player removeEventHandler ["SeatSwitchedMan",MAZ_EH_SeatSwitchedMan_3PP];
		};
		MAZ_EH_SeatSwitchedMan_3PP = player addEventHandler ["SeatSwitchedMan", {
			if(cameraView == "External" && !(call MAZ_FFP_fnc_canEnter3PP)) then {
				player switchCamera "Internal";
			};
		}];

		if(cameraView == "External" && !(call MAZ_FFP_fnc_canEnter3PP)) then {
			player switchCamera "Internal";
		};
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		["Force First Person", "This is so self explanatory that if I need to explain it to you then you probably shouldn't be here."] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Force First Person System has been loaded! You can't enter third person anymore!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	[] spawn MAZ_fnc_forceFirstPersonCarrier;
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