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
if(missionNamespace getVariable ["MAZ_EP_suppressionEnabled",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Suppression Effects already running!";};

private _varName = "MAZ_System_EnhancementPack_SUP";
private _myJIPCode = "MAZ_EPSystem_SUP_JIP";

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["Suppression","Whether to enable the Suppression system.","MAZ_EP_suppressionEnabled",true,"TOGGLE",[],"MAZ_SUP"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_EP_fnc_suppressionCarrier = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_SUP"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};
		if(!isNil "MAZ_EH_suppression") then {
			player removeEventHandler ["Suppressed",MAZ_EH_suppression];
		};

		MAZ_EH_suppression = player addEventHandler ["Suppressed", {
			params ["_unit", "_distance", "_shooter", "_instigator", "_ammoObject", "_ammoClassName", "_ammoConfig"];
			if !(MAZ_EP_suppressionEnabled) exitWith {};
			[_distance] spawn {
				params ["_distance"];
				private _supressedValue = .55 * _distance;
				if(isNil 'MAZ_PP_SuppressionEffect') then {
					MAZ_PP_SuppressionEffect = ppEffectCreate ["ColorCorrections",1500];
				};
				MAZ_PP_SuppressionEffect ppEffectEnable true;
				player setCustomAimCoef 2.5;
				MAZ_PP_SuppressionEffect ppEffectAdjust [0,1,0,[0,0,0,0],[1,1,1,1],[0.33,0.33,0.33,0],[.66,.66,0,0,0,0,_supressedValue]];
				MAZ_PP_SuppressionEffect ppEffectCommit 0;
				sleep 1;
				MAZ_PP_SuppressionEffect ppEffectAdjust [1,1,0,[0,0,0,0],[1,1,1,1],[0.33,0.33,0.33,0],[.66,.66,0,0,0,0,.75]];
				player setCustomAimCoef 1;
				MAZ_PP_SuppressionEffect ppEffectCommit 4.5;
			};
		}];
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		["Suppression Effects", "When you are suppressed by enemies you will have a tunnel vision effect similar to that seen in Squad."] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Suppression System has been loaded! Bullets are way scarier now!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	[] spawn MAZ_EP_fnc_suppressionCarrier;
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