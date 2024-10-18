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
if(missionNamespace getVariable ["MAZ_EP_slowOffroadVehiclesEnabled",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Slow Offroad Vehicles already running!";};

private _varName = "MAZ_System_EnhancementPack_SOV";
private _myJIPCode = "MAZ_EPSystem_SOV_JIP";

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["Slow Offroad Vehicles","Whether to enable the Slow Offroad Vehicles system.","MAZ_EP_slowOffroadVehiclesEnabled",true,"TOGGLE",[],"MAZ_SOV"] call MAZ_EP_fnc_addNewSetting;
	["Max Offroad Speed","The maximum speed vehicles can go while offroad.","MAZ_EP_maxVehicleOffroadSpeed",47,"SLIDER",[30,70],"MAZ_SOV"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_slowOffroadVehicleCarrier = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_SOV"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};
		MAZ_fnc_camShakeWhenOffroad = {
			private _speedVehicle = abs (speed (vehicle player));
			private _fq = 0;
			private _pw = 0;

			if ((_speedVehicle >= 10) and (_speedVehicle < 25)) then {
				_fq = 3;
				_pw = 1;
			};
			if ((_speedVehicle >= 25) and (_speedVehicle < 50)) then {
				_fq = 5;
				_pw = 1.4;
			};
			if (_speedVehicle >= 50) then {
				_fq = 6;
				_pw = 1.8;
			};

			addCamShake [_pw, 1, _fq];
		};

		MAZ_fnc_toggleVehicleSlowness = {
			params ["_toggle"];
			if(_toggle) then {
				vehicle player setCruiseControl [MAZ_EP_maxVehicleOffroadSpeed,false];
			} else {
				vehicle player setCruiseControl [0,false];
			};
		};

		MAZ_fnc_offroadVehiclesLoopForServer = {
			if(time < (missionNamespace getVariable ["MAZ_EP_SOV_setupLoopTime",time])) exitWith {};
			call MAZ_SOV_fnc_setupVehicles;
			missionNamespace setVariable ["MAZ_EP_SOV_setupLoopTime",time + 0.1];
		};

		MAZ_SOV_fnc_setupVehicles = {
			{
				if(!((typeOf _x) isKindOf "LandVehicle")) then {continue};
				if((typeOf _x) isKindOf "Tank") then {continue};
				private _isSetup = _x getVariable ["MAZ_offroad_isSetup",false];
				if(!_isSetup) then {
					_x setVariable ["MAZ_offroad_isSetup",true];
					[_x] spawn MAZ_fnc_offroadPerVehicleLoop;
				};
			}forEach vehicles;
		};

		MAZ_fnc_offroadPerVehicleLoop = {
			params ["_vehicle"];
			while{!isNull _vehicle && alive _vehicle} do {
				if(!MAZ_EP_slowOffroadVehiclesEnabled) exitWith {sleep 0.5;};
				if(
					(isOnRoad (ASLToAGL (getPosASL _vehicle))) ||
					("Concrete" in (surfaceType (getPos _vehicle)))
				) then {
					comment "On road";
					[[], {
						[false] call MAZ_fnc_toggleVehicleSlowness;
					}] remoteExec ['spawn',driver _vehicle];
					_vehicle limitSpeed -1;
					(driver _vehicle) setCruiseControl [-1,false];
				} else {
					comment "Offroad";
					[[], {
						[true] call MAZ_fnc_toggleVehicleSlowness;
					}] remoteExec ['spawn',driver _vehicle];
					[[], {
						call MAZ_fnc_camShakeWhenOffroad;
					}] remoteExec ['spawn',crew _vehicle];
					_vehicle limitSpeed MAZ_EP_maxVehicleOffroadSpeed;
					(driver _vehicle) setCruiseControl [MAZ_EP_maxVehicleOffroadSpeed,false];
				};
				sleep 0.5;
			};
		};

		if(isServer) then {
			waitUntil {!isNil "MAZ_EP_fnc_addFunctionToMainLoop"};
			["MAZ_fnc_offroadVehiclesLoopForServer"] call MAZ_EP_fnc_addFunctionToMainLoop;
		};
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		["Slow Offroad Vehicles", "Vehicles will drive slower offroad and will have camera shake when doing so at high speeds."] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Slow Offroad Vehicles System has been loaded! Vehicles are way slower, they weren't meant for this abuse!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	[] spawn MAZ_slowOffroadVehicleCarrier;
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