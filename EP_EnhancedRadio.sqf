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
if(missionNamespace getVariable ["MAZ_EP_enhancedRadioEnabled",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Enhanced Radio already running!";};

private _varName = "MAZ_System_EnhancementPack_ER";
private _myJIPCode = "MAZ_EPSystem_ER_JIP";

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["[ER] Enhanced Radio","Whether to enable the Enhanced Radio system.","MAZ_EP_enhancedRadioEnabled",true,"TOGGLE",[],"MAZ_ER"] call MAZ_EP_fnc_addNewSetting;
	["[ER] Radio Only for Squad Leader","Whether to limit GLOBAL, SIDE, and COMMAND to Squad Leaders.","MAZ_EP_enhancedRadioLeaderOnly",true,"TOGGLE",[],"MAZ_ER"] call MAZ_EP_fnc_addNewSetting;
	["[ER] Radio Animation","Whether to play an animation when using GLOBAL, SIDE, and COMMAND.","MAZ_EP_enhancedRadioAnim",true,"TOGGLE",[],"MAZ_ER"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_fnc_enhancedRadioCarrier = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_ER"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};
		MAZ_fnc_radioIn = {
			if(!MAZ_EP_enhancedRadioEnabled) exitWith {};
			if("ItemRadio" in assignedItems player) then {
				private _channel = currentChannel;
				if(_channel < 4) then {
					switch(_channel) do {
						case 0 : {
							if(MAZ_EP_enhancedRadioAnim) then {
								[player,"HandSignalRadio"] remoteExec ["playAction",0];
							};
							{
								playSound3D ["A3\Dubbing_Radio_F\Sfx\in2a.ogg",_x,false,getPosASL _x,5,1,10];
							} forEach allPlayers;
						}; comment "Global";
						case 1 : {
							if(MAZ_EP_enhancedRadioAnim) then {
								[player,"HandSignalRadio"] remoteExec ["playAction",0];
							};
							
							{
								playSound3D ["A3\Dubbing_Radio_F\Sfx\in2a.ogg",_x,false,getPosASL _x,5,1,10];
							} forEach units (side player);
						}; comment "Side";
						case 2 : {
							if(MAZ_EP_enhancedRadioAnim) then {
								[player,"HandSignalRadio"] remoteExec ["playAction",0];
							};
							{
								private _leader = leader (group _x);
								if(_leader == _x) then {
									playSound3D ["A3\Dubbing_Radio_F\Sfx\in2a.ogg",_x,false,getPosASL _x,5,1,10];
								};
							} forEach units (side player);
						}; comment "Command";
						case 3 : {
							if(MAZ_EP_enhancedRadioAnim) then {
								[player,"HandSignalRadio"] remoteExec ["playAction",0];
							};
							private _groupUnits = units group player;
							{
								playSound3D ["A3\Dubbing_Radio_F\Sfx\in2a.ogg",_x,false,getPosASL _x,5,1,10];
							} forEach _groupUnits;
						}; comment "Group";
					};
					player setVariable ['radioClickIn',true];
				};
			};
		};

		MAZ_fnc_radioOut = {
			if(!MAZ_EP_enhancedRadioEnabled) exitWith {};
			if("ItemRadio" in assignedItems player) then {
				private _channel = currentChannel;
				if(_channel < 4) then {
					[] spawn MAZ_fnc_startRadioCooldown;
					switch(_channel) do {
						case 0 : {
							{
								playSound3D ["A3\Dubbing_Radio_F\Sfx\out2a.ogg",_x,false,getPosASL _x,5,1,10];
							} forEach allPlayers;
						}; comment "Global";
						case 1 : {
							{
								playSound3D ["A3\Dubbing_Radio_F\Sfx\out2a.ogg",_x,false,getPosASL _x,5,1,10];
							} forEach units (side player);
						}; comment "Side";
						case 2 : {
							{
								private _leader = leader (group _x);
								if(_leader == _x) then {
									playSound3D ["A3\Dubbing_Radio_F\Sfx\out2a.ogg",_x,false,getPosASL _x,5,1,10];
								};
							} forEach units (side player);
						}; comment "Command";
						case 3 : {
							private _groupUnits = units group player;
							{
								playSound3D ["A3\Dubbing_Radio_F\Sfx\out2a.ogg",_x,false,getPosASL _x,5,1,10];
							} forEach _groupUnits;
						}; comment "Group";
					};
					player setVariable ['radioClickIn',false];
				};
			};
		};

		MAZ_fnc_radioRequirement = {
			if(!MAZ_EP_enhancedRadioEnabled) exitWith {
				0 enableChannel true;
				1 enableChannel true;
				2 enableChannel true;
				3 enableChannel true;
				["MAZ_fnc_radioRequirement"] call MAZ_EP_fnc_removeFunctionFromMainLoop;
			};
			if(time < (missionNamespace getVariable ["MAZ_EP_ER_radioCheckLoopTime",time])) exitWith {};
			if ("ItemRadio" in assignedItems player) then {
				0 enableChannel true;
				1 enableChannel true;
				2 enableChannel true;
				3 enableChannel true;
			} else {
				0 enableChannel [true,false];
				1 enableChannel [true,false]; 
				2 enableChannel [true,false];
				3 enableChannel [true,false];
			};
			
			if(MAZ_EP_enhancedRadioLeaderOnly) then {
				private _grpPlyr = group player;
				private _ldrGrp = leader _grpPlyr;

				if(_ldrGrp == player) then {
					0 enableChannel true;
					1 enableChannel true;
					2 enableChannel true;
				} else {
					0 enableChannel [true,false];
					1 enableChannel [true,false];
					2 enableChannel [true,false];
				};
			};
			missionNamespace setVariable ["MAZ_EP_ER_radioCheckLoopTime",time + 1];
		};

		MAZ_fnc_startRadioCooldown = {
			MAZ_EP_RadioCoolDown = true;
			sleep 1;
			MAZ_EP_RadioCoolDown = false;
		};

		MAZ_EP_RadioCoolDown = false;
		MAZ_EH_Key_RadioIn = (findDisplay 46) displayAddEventHandler ["KeyDown","
			_radioClickIn = player getVariable ['radioClickIn',false];
			if(MAZ_EP_RadioCoolDown) exitWith {};
			if(((_this select 1) in (actionKeys'pushToTalk'+actionKeys'pushToTalkGroup')) && !_radioClickIn) then {
				[] spawn MAZ_fnc_radioIn;
			};
		"];
		MAZ_EH_Key_RadioOut = (findDisplay 46) displayAddEventHandler ["KeyUp","
			if(MAZ_EP_RadioCoolDown) exitWith {};
			if((_this select 1) in (actionKeys'pushToTalk'+actionKeys'pushToTalkGroup')) then {
				[] spawn MAZ_fnc_radioOut;
			};
		"];
		MAZ_EH_Key_RadioInZeus = (findDisplay 312) displayAddEventHandler ["KeyDown","
			_radioClickIn = player getVariable ['radioClickIn',false];
			if(MAZ_EP_RadioCoolDown) exitWith {};
			if(((_this select 1) in (actionKeys'pushToTalk'+actionKeys'pushToTalkGroup')) && !_radioClickIn) then {
				[] spawn MAZ_fnc_radioIn;
			};
		"];
		MAZ_EH_Key_RadioOutZeus = (findDisplay 312) displayAddEventHandler ["KeyUp","
			if(MAZ_EP_RadioCoolDown) exitWith {};
			if((_this select 1) in (actionKeys'pushToTalk'+actionKeys'pushToTalkGroup')) then {
				[] spawn MAZ_fnc_radioOut;
			};
		"];
		waitUntil {!isNil "MAZ_EP_fnc_addFunctionToMainLoop"};
		["MAZ_fnc_radioRequirement"] call MAZ_EP_fnc_addFunctionToMainLoop;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		[
			"Enhanced Radio", 
			"This makes radio noises happen when talking through global, side, command, and group channels. These sounds are audible to everyone around you, so when in PvP be aware of this.",
			[
				"Radio communications make beeping noises, audible to everyone, even your enemies",
				"Radio channels are global, side, command, and group",
				"Optionally makes it so only Squad Leaders can speak on radio channels, the rest are stuck to direct and vehicle chat",
				"When using radio channels you will hold the push to talk on your radio"
			]	
		] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Enhanced Radio System has been loaded! Beep! Beep! Over!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	[] spawn MAZ_fnc_enhancedRadioCarrier;
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