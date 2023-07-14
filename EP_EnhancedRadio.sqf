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

MAZ_EP_enhancedRadioEnabled = true;
publicVariable 'MAZ_EP_enhancedRadioEnabled';

MAZ_EP_enhancedRadioLeaderOnly = false;
publicVariable "MAZ_EP_enhancedRadioLeaderOnly";

MAZ_EP_enhancedRadioAnim = true;
publicVariable "MAZ_EP_enhancedRadioAnim";

private _value = (str {
	MAZ_fnc_enhancedRadioCarrier = {
		MAZ_fnc_radioIn = {
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
			while {MAZ_EP_enhancedRadioEnabled} do {
				if(!MAZ_EP_enhancedRadioLeaderOnly) then {
					if ("ItemRadio" in assignedItems player) then {
						0 enableChannel [true,true];
						1 enableChannel [true,true];
						2 enableChannel [true,true];
						3 enableChannel [true,true];
					} else {
						0 enableChannel [true,false];
						1 enableChannel [true,false]; 
						2 enableChannel [true,false];
						3 enableChannel [true,false];
					};
				};
				sleep 1;
			};
		};

		MAZ_fnc_disableChannels = {
			while{MAZ_EP_enhancedRadioLeaderOnly} do {
				private _grpPlyr = group player;
				private _ldrGrp = leader _grpPlyr;

				if(_ldrGrp == player) then {
					0 enableChannel [true,true];
					1 enableChannel [true,true];
					2 enableChannel [true,true];
				} else {
					0 enableChannel [true,false];
					1 enableChannel [true,false];
					2 enableChannel [true,false];
				};
				sleep 1;
			};
			0 enableChannel [true,true];
			1 enableChannel [true,true];
			2 enableChannel [true,true];
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
		[] spawn MAZ_radioRequirement;
		
		if(MAZ_EP_enhancedRadioLeaderOnly) then {
			[] spawn MAZ_disableChannels;
		};
	};
	if(!isNil "MAZ_EP_fnc_addDiaryRecord") then {
		["Enhanced Radio", "This makes radio noises happen when talking through global, side, command, and group channels. These sounds are audible to everyone around you, so when in PvP be aware of this."] call MAZ_EP_fnc_addDiaryRecord;
	};
	if(!isNil "MAZ_EP_fnc_createNotification") then {
		[
			"Enhanced Radio System has been loaded! Beep! Beep! Over!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	call MAZ_fnc_enhancedRadioCarrier;
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