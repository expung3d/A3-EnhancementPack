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
if(missionNamespace getVariable ["MAZ_EP_CC_combatCalloutsEnabled",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Combat Callouts already running!";};

private _varName = "MAZ_System_EnhancementPack_CC";
private _myJIPCode = "MAZ_EPSystem_CC_JIP";

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["[CC] Combat Callouts","Whether to enable the Combat Callouts system.","MAZ_EP_CC_combatCalloutsEnabled",true,"TOGGLE",[],"MAZ_CC"] call MAZ_EP_fnc_addNewSetting;
	["[CC] Call for Medic","Whether to enable calling for a medic when injured.","MAZ_EP_CC_callMedicToggle",true,"TOGGLE",[],"MAZ_CC"] call MAZ_EP_fnc_addNewSetting;
	["[CC] Call Reload","Whether to enable calling out when you're reloading.","MAZ_EP_CC_callReloadToggle",true,"TOGGLE",[],"MAZ_CC"] call MAZ_EP_fnc_addNewSetting;
	["[CC] Call Suppressed","Whether to enable calling out when you're being suppressed.","MAZ_EP_CC_callSuppressedToggle",true,"TOGGLE",[],"MAZ_CC"] call MAZ_EP_fnc_addNewSetting;
	["[CC] Call Friendly Fire","Whether to enable calling out when you're being shot by friendlies.","MAZ_EP_CC_callFFToggle",true,"TOGGLE",[],"MAZ_CC"] call MAZ_EP_fnc_addNewSetting;
	["[CC] Call Dead Squadmate","Whether to enable calling out when one of your group members dies.","MAZ_EP_CC_callDeadFriendlyToggle",true,"TOGGLE",[],"MAZ_CC"] call MAZ_EP_fnc_addNewSetting;
	["[CC] Call Hit","Whether to enable calling out when you get hurt.","MAZ_EP_CC_callHurtToggle",true,"TOGGLE",[],"MAZ_CC"] call MAZ_EP_fnc_addNewSetting;
	["[CC] Call Kill","Whether to enable calling out when you kill an enemy.","MAZ_EP_CC_callKillToggle",true,"TOGGLE",[],"MAZ_CC"] call MAZ_EP_fnc_addNewSetting;
	["[CC] Call Direction","Whether to enable calling out the direction when you ping a location.","MAZ_EP_CC_callDirectionToggle",true,"TOGGLE",[],"MAZ_CC"] call MAZ_EP_fnc_addNewSetting;
	["[CC] Call Grenade","Whether to enable calling out when a grenade is nearby.","MAZ_EP_CC_callNadeToggle",true,"TOGGLE",[],"MAZ_CC"] call MAZ_EP_fnc_addNewSetting;
	["[CC] Call Throwing Grenade","Whether to enable calling out when you throw a grenade.","MAZ_EP_CC_callNadeThrowToggle",true,"TOGGLE",[],"MAZ_CC"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_EP_CC_delayToCallMedic = 15;
	MAZ_EP_CC_MAZ_EP_CC_delayToCallSuppressedTimer = 45;
	MAZ_EP_CC_delayToCallReload = 5;
	
	MAZ_CC_fnc_combatCalloutsCarrier = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_CC"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};
		MAZ_autoCallMedic = {
			if(!MAZ_EP_CC_combatCalloutsEnabled || !MAZ_EP_CC_callMedicToggle) exitWith {};
			if(time < (missionNamespace getVariable ["MAZ_EP_CC_loopTime",time])) exitWith {};
			private _lState = lifeState player;
			if(_lState isEqualTo "INCAPACITATED") then {
				private _medicLines = [
					"HealthIAmBadlyHurt.ogg",
					"HealthIAmWounded.ogg",
					"HealthINeedHelpNow.ogg",
					"HealthMedic.ogg",
					"HealthNeedHelp.ogg",
					"HealthNeedMedicNow.ogg",
					"HealthSomebodyHelpMe.ogg",
					"HealthWounded.ogg"
				];
				private _medicLine = selectRandom _medicLines;
				[player] spawn MAZ_makeLipSync;

				private _speaker = toLower (speaker player);
				private _folderPath = _speaker select [6];
				private _isSaid = false;
				if("chi" in _speaker || "fre" in _speaker || "engfre" in _speaker) then {
					_isSaid = true;
					playSound3D [format ["A3\dubbing_radio_f_exp\data\%1\%2\RadioProtocol%4\Normal\140_Com_Status\%3",_folderPath,_speaker,_medicLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
				};
				if("pol" in _speaker || "rus" in _speaker) then {
					_isSaid = true;
					playSound3D [format ["A3\dubbing_radio_f_enoch\data\%1\%2\Normal\140_Com_Status\%3",_folderPath,_speaker,_medicLine], player,false,getPosASL player,5,1,75];
				};
				if(!_isSaid) then {
					playSound3D [format ["A3\dubbing_radio_f\data\%1\%2\RadioProtocol%4\Normal\140_Com_Status\%3",_folderPath,_speaker,_medicLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
				};
			};
			missionNamespace setVariable ["MAZ_EP_CC_loopTime",time + MAZ_EP_CC_delayToCallMedic];
		};

		MAZ_callOutReload = {
			if(!MAZ_EP_CC_reloadCooldown) then {
				[player] spawn MAZ_makeLipSync;

				private _reloadLines = [
					"ReloadingE_1.ogg",
					"ReloadingE_2.ogg",
					"ReloadingE_3.ogg",
					"ReloadingE_4.ogg",
					"ReloadingE_5.ogg",
					"ReloadingE_6.ogg",
					"ReloadingE_7.ogg"
				];

				private _reloadLine = selectRandom _reloadLines;
				private _behaviorPlayer = "COMBAT";

				private _speaker = toLower (speaker player);
				private _folderPath = _speaker select [6];
				private _isSaid = false;
				if("chi" in _speaker || "fre" in _speaker || "engfre" in _speaker) then {
					_isSaid = true;
					playSound3D [format ["A3\dubbing_radio_f_exp\data\%1\%2\RadioProtocol%5\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_reloadLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
				};
				if("pol" in _speaker || "rus" in _speaker) then {
					_isSaid = true;
					playSound3D [format ["A3\dubbing_radio_f_enoch\data\%1\%2\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_reloadLine], player,false,getPosASL player,5,1,75];
				};
				if(!_isSaid) then {
					playSound3D [format ["A3\dubbing_radio_f\data\%1\%2\RadioProtocol%5\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_reloadLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
				};
				MAZ_EP_CC_reloadCooldown = true;
			};
		};

		MAZ_callSuppressed = {
			params ["_unit","_distance","_shooter"];
			if(side (group _unit) == side (group _shooter) && (_unit distance _shooter) > 15) exitWith {[] spawn MAZ_callFriendlyFire;};
			if((_unit distance _shooter) < 10) exitWith {};
			MAZ_EP_CC_delayToCallSuppress = true;
			sleep ([0,1] call BIS_fnc_randomNum);
			private _suppressedLines = [
				"UnderFireE_1.ogg",
				"UnderFireE_2.ogg",
				"UnderFireE_3.ogg",
				"UnderFireE_4.ogg",
				"UnderFireE_5.ogg",
				"UnderFireE_6.ogg"
			];
			private _supLine = selectRandom _suppressedLines;
			private _behaviorPlayer = "COMBAT";
			[player] spawn MAZ_makeLipSync;
			private _speaker = toLower (speaker player);
			private _folderPath = _speaker select [6];
			private _isSaid = false;
			if("chi" in _speaker || "fre" in _speaker || "engfre" in _speaker) then {
				_isSaid = true;
				playSound3D [format ["A3\dubbing_radio_f_exp\data\%1\%2\RadioProtocol%5\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_supLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
			};
			if("pol" in _speaker || "rus" in _speaker) then {
				_isSaid = true;
				playSound3D [format ["A3\dubbing_radio_f_enoch\data\%1\%2\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_supLine], player,false,getPosASL player,5,1,75];
			};
			if(!_isSaid) then {
				playSound3D [format ["A3\dubbing_radio_f\data\%1\%2\RadioProtocol%5\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_supLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
			};
			sleep MAZ_EP_CC_MAZ_EP_CC_delayToCallSuppressedTimer;
			MAZ_EP_CC_delayToCallSuppress = false;
		};

		MAZ_callFriendlyFire = {
			if(!MAZ_EP_CC_delayToCallSuppress) then {
				MAZ_EP_CC_delayToCallSuppress = true;
				sleep 0.5;
				private _ffLine = "CheckYourFire.ogg";
				private _behaviorPlayer = "NORMAL";
				[player] spawn MAZ_makeLipSync;
				private _speaker = toLower (speaker player);
				private _folderPath = _speaker select [6];
				private _isSaid = false;
				if("chi" in _speaker || "fre" in _speaker || "engfre" in _speaker) then {
					_isSaid = true;
					playSound3D [format ["A3\dubbing_radio_f_exp\data\%1\%2\RadioProtocol%5\%3\100_Commands\%4",_folderPath,_speaker,_behaviorPlayer,_ffLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
				};
				if("pol" in _speaker || "rus" in _speaker) then {
					_isSaid = true;
					playSound3D [format ["A3\dubbing_radio_f_enoch\data\%1\%2\%3\100_Commands\%4",_folderPath,_speaker,_behaviorPlayer,_ffLine], player,false,getPosASL player,5,1,75];
				};
				if(!_isSaid) then {
					playSound3D [format ["A3\dubbing_radio_f\data\%1\%2\RadioProtocol%5\%3\100_Commands\%4",_folderPath,_speaker,_behaviorPlayer,_ffLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
				};
				sleep 5;
				MAZ_EP_CC_delayToCallSuppress = false;
			};
		};

		MAZ_callFriendlyFireMessage = {
			params ["_unit","_shooter"];
			if(!MAZ_EP_CC_delayToCallSuppress) then {
				[_unit,format ["%1 hold your fire! You're shooting friendlies!",name _shooter]] remoteExec ['sideChat'];
			};
		};

		MAZ_callDeadFriendly = {
			params ["_unit"];
			private _nearestMen = nearestObjects [_unit,["Man"],20];
			_nearestMen deleteAt 0;
			private _nearestTeammate = nil;
			{
				if((group _unit == group _x) && ((_unit distance _x) < 15) && (_unit != _x) && (alive _x)) exitWith {_nearestTeammate = _x;};
			}forEach _nearestMen;
			if(isNil "_nearestTeammate") exitWith {};
			[[], {
				[] spawn MAZ_callDeadFriendlyExec;
			}] remoteExec ["spawn",_nearestTeammate];
		};

		MAZ_callDeadFriendlyExec = {
			private _manDownLines = [
				"ManDownE_1.ogg",
				"ManDownE_2.ogg",
				"ManDownE_3.ogg",
				"WeGotAManDownE_1.ogg",
				"WeGotAManDownE_2.ogg",
				"WeGotAManDownE_3.ogg",
				"WeLostOneE_1.ogg",
				"WeLostOneE_2.ogg",
				"WeLostOneE_3.ogg"
			];
			private _deadLine = selectRandom _manDownLines;
			private _behaviorPlayer = "NORMAL";
			sleep 2;
			[player] spawn MAZ_makeLipSync;
			private _speaker = toLower (speaker player);
			private _folderPath = _speaker select [6];
			private _isSaid = false;
			if("chi" in _speaker || "fre" in _speaker || "engfre" in _speaker) then {
				_isSaid = true;
				playSound3D [format ["A3\dubbing_radio_f_exp\data\%1\%2\RadioProtocol%5\%3\140_Com_Status\%4",_folderPath,_speaker,_behaviorPlayer,_deadLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
			};
			if("pol" in _speaker || "rus" in _speaker) then {
				_isSaid = true;
				playSound3D [format ["A3\dubbing_radio_f_enoch\data\%1\%2\%3\140_Com_Status\%4",_folderPath,_speaker,_behaviorPlayer,_deadLine], player,false,getPosASL player,5,1,75];
			};
			if(!_isSaid) then {
				playSound3D [format ["A3\dubbing_radio_f\data\%1\%2\RadioProtocol%5\%3\140_Com_Status\%4",_folderPath,_speaker,_behaviorPlayer,_deadLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
			};
		};

		MAZ_callOutGotHit = {
			params ["_unit","_source"];
			if(!(_source isKindOf "Man")) exitWith {};
			if(side group _source == side group _unit && _source != _unit) exitWith {
				if(MAZ_EP_CC_callFFToggle) then {
					[_unit,_source] spawn MAZ_callFriendlyFireMessage; [] spawn MAZ_callFriendlyFire;
				};
			};
			if(!MAZ_EP_CC_delayToCallHit) then {
				[_unit] spawn MAZ_makeLipSync;

				private _isCallOutLoud = (random 1) < 0.2;
				private _behaviorPlayer = "";
				private _path = "";
				private _deadLine = "";
				if(_isCallOutLoud) then {
					_behaviorPlayer = "NORMAL";
					_path = "140_Com_Status";
					_deadLine = selectRandom [
						"HealthIAmBadlyHurt.ogg",
						"HealthIAmWounded.ogg"
					];
				} else {
					_behaviorPlayer = "COMBAT";
					_path = "200_CombatShouts";
					_deadLine = selectRandom [
						"EndangeredE_1.ogg",
						"EndangeredE_2.ogg",
						"EndangeredE_3.ogg",
						"ScreamingE_1.ogg",
						"ScreamingE_2.ogg",
						"ScreamingE_3.ogg",
						"ScreamingE_4.ogg"
					];
				};
				private _speaker = toLower (speaker player);
				private _folderPath = _speaker select [6];
				private _isSaid = false;
				if("chi" in _speaker || "fre" in _speaker || "engfre" in _speaker) then {
					_isSaid = true;
					playSound3D [format ["A3\dubbing_radio_f_exp\data\%1\%2\RadioProtocol%5\%3\%6\%4",_folderPath,_speaker,_behaviorPlayer,_deadLine,_folderPath select [0,3],_path], player,false,getPosASL player,5,1,75];
				};
				if("pol" in _speaker || "rus" in _speaker) then {
					_isSaid = true;
					playSound3D [format ["A3\dubbing_radio_f_enoch\data\%1\%2\%3\%5\%4",_folderPath,_speaker,_behaviorPlayer,_deadLine,_path], player,false,getPosASL player,5,1,75];
				};
				if(!_isSaid) then {
					playSound3D [format ["A3\dubbing_radio_f\data\%1\%2\RadioProtocol%5\%3\%6\%4",_folderPath,_speaker,_behaviorPlayer,_deadLine,_folderPath select [0,3],_path], player,false,getPosASL player,5,1,75];
				};
				MAZ_EP_CC_delayToCallHit = true;
				sleep 5;
				MAZ_EP_CC_delayToCallHit = false;
			};
		};

		MAZ_makeLipSync = {
			params ["_unit"];
			[_unit,true] remoteExec ['setRandomLip'];
			sleep 1.25;
			[_unit,false] remoteExec ['setRandomLip'];
		};

		MAZ_scratchOneCall = {
			MAZ_EP_CC_delayToCallKill = true;
			sleep 1;
			private _scratchOneLines = [
				"HeIsDown.ogg",
				"HostileDown.ogg",
				"IVeGotHim.ogg",
				"ScratchOne.ogg",
				"TargetEliminated.ogg",
				"TargetIsDown.ogg",
				"TargetIsNeutralized.ogg",
				"WitnessKilledE_1.ogg",
				"WitnessKilledE_2.ogg",
				"WitnessKilledE_3.ogg"
			];
			private _killLine = selectRandom _scratchOneLines;
			private _behaviorPlayer = behaviour player;
			[player] spawn MAZ_makeLipSync;
			if(_behaviorPlayer == "CARELESS" || _behaviorPlayer == "AWARE" || _behaviorPlayer == "SAFE") then {
				_behaviorPlayer = "COMBAT";
			};
			private _type = "110_Com_Announce";
			if(_killLine in ["WitnessKilledE_1.ogg","WitnessKilledE_2.ogg","WitnessKilledE_3.ogg"]) then {
				_type = "200_CombatShouts";
			};

			private _speaker = toLower (speaker player);
			private _folderPath = _speaker select [6];
			private _isSaid = false;
			if("chi" in _speaker || "fre" in _speaker || "engfre" in _speaker) then {
				_isSaid = true;
				playSound3D [format ["A3\dubbing_radio_f_exp\data\%1\%2\RadioProtocol%5\%3\%6\%4",_folderPath,_speaker,_behaviorPlayer,_killLine,_folderPath select [0,3],_type], player,false,getPosASL player,5,1,75];
			};
			if("pol" in _speaker || "rus" in _speaker) then {
				_isSaid = true;
				playSound3D [format ["A3\dubbing_radio_f_enoch\data\%1\%2\%3\%5\%4",_folderPath,_speaker,_behaviorPlayer,_killLine,_type], player,false,getPosASL player,5,1,75];
			};
			if(!_isSaid) then {
				playSound3D [format ["A3\dubbing_radio_f\data\%1\%2\RadioProtocol%5\%3\%6\%4",_folderPath,_speaker,_behaviorPlayer,_killLine,_folderPath select [0,3],_type], player,false,getPosASL player,5,1,75];
			};
			sleep 3;
			MAZ_EP_CC_delayToCallKill = false;
		};

		MAZ_getDirectionForCallout = {
			private _cardinals = ["north","northeast","east","southeast","south","southwest","west","northwest","north"];
			private _index = round ((getDir player) * 8 / 360);

			_cardinals select _index
		};

		MAZ_callDirection = {
			private _directionPlayer = [] call MAZ_getDirectionForCallout;
			private _selection = selectRandom ["1","2"];
			private _callOut = format ["%1_%2.ogg",_directionPlayer,_selection];
			private _behaviorPlayer = "NORMALWatch";
			[player] spawn MAZ_makeLipSync;

			private _speaker = toLower (speaker player);
			private _folderPath = _speaker select [6];
			private _isSaid = false;
			if("chi" in _speaker || "fre" in _speaker || "engfre" in _speaker) then {
				_isSaid = true;
				playSound3D [format ["A3\dubbing_radio_f_exp\data\%1\%2\RadioProtocol%5\%3\DirectionCompass1\%4",_folderPath,_speaker,_behaviorPlayer,_callOut,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
			};
			if("pol" in _speaker || "rus" in _speaker) then {
				_isSaid = true;
				playSound3D [format ["A3\dubbing_radio_f_enoch\data\%1\%2\%3\DirectionCompass1\%4",_folderPath,_speaker,_behaviorPlayer,_callOut], player,false,getPosASL player,5,1,75];
			};
			if(!_isSaid) then {
				playSound3D [format ["A3\dubbing_radio_f\data\%1\%2\RadioProtocol%5\%3\DirectionCompass1\%4",_folderPath,_speaker,_behaviorPlayer,_callOut,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
			};

			sleep 15;
			MAZ_EP_CC_delayToCallDirection = false;
		};

		MAZ_changeVoiceAndFace = {
			if(!MAZ_EP_CC_combatCalloutsEnabled) exitWith {};
			if(time < (missionNamespace getVariable ["MAZ_EP_CC_faceLoopTime",time])) exitWith {};
			private _world = worldName;
			private _americanVoice = [
				"Male01ENG",
				"Male02ENG",
				"Male03ENG",
				"Male04ENG",
				"Male05ENG",
				"Male06ENG",
				"Male07ENG",
				"Male08ENG",
				"Male09ENG",
				"Male10ENG",
				"Male11ENG",
				"Male12ENG"
			] apply {toLower _x};
			private _britishVoice = [
				"Male01ENGB",
				"Male02ENGB",
				"Male03ENGB",
				"Male04ENGB",
				"Male05ENGB"
			] apply {toLower _x};
			private _altianVoice = [
				"Male01GRE",
				"Male02GRE",
				"Male03GRE",
				"Male04GRE",
				"Male05GRE",
				"Male06GRE"
			] apply {toLower _x};
			private _chineseVoice = [
				"Male01CHI",
				"Male02CHI",
				"Male03CHI"
			] apply {toLower _x};
			private _persianVoice = [
				"Male01PER",
				"Male02PER",
				"Male03PER"
			] apply {toLower _x};
			private _frenchVoice = [
				"Male01FRE",
				"Male02FRE",
				"Male03FRE"
			] apply {toLower _x};
			private _frenchEnglishVoice = [
				"Male01ENGFRE",
				"Male02ENGFRE"
			] apply {toLower _x};
			private _polishVoice = [
				"Male01POL",
				"Male02POL",
				"Male03POL"
			] apply {toLower _x};
			private _russianVoice = [
				"Male01RUS",
				"Male02RUS",
				"Male03RUS"
			] apply {toLower _x};

			private _whiteHeads = [
				"WhiteHead_01",
				"WhiteHead_02",
				"WhiteHead_03",
				"WhiteHead_04",
				"WhiteHead_05",
				"WhiteHead_06",
				"WhiteHead_07",
				"WhiteHead_08",
				"WhiteHead_09",
				"WhiteHead_10",
				"WhiteHead_11",
				"WhiteHead_12",
				"WhiteHead_13",
				"WhiteHead_14",
				"WhiteHead_15",
				"WhiteHead_16",
				"WhiteHead_17",
				"WhiteHead_18",
				"WhiteHead_19",
				"WhiteHead_20",
				"WhiteHead_21",
				"WhiteHead_22_a",
				"WhiteHead_22_l",
				"WhiteHead_22_sa",
				"WhiteHead_23",
				"WhiteHead_24",
				"WhiteHead_25",
				"WhiteHead_26",
				"WhiteHead_27",
				"WhiteHead_28",
				"WhiteHead_29",
				"WhiteHead_30",
				"WhiteHead_31",
				"WhiteHead_32",
				"Miller",
				"Kerry",
				"Kerry_A_F",
				"Kerry_B1_F",
				"Kerry_B2_F",
				"Kerry_C_F",
				"Jay",
				"Ivan",
				"Pettka",
				"Dwarden",
				"Hladas",
				"CamoHead_White_01_F",
				"CamoHead_White_02_F",
				"CamoHead_White_03_F",
				"CamoHead_White_04_F",
				"CamoHead_White_05_F",
				"CamoHead_White_06_F",
				"CamoHead_White_07_F",
				"CamoHead_White_08_F",
				"CamoHead_White_09_F",
				"CamoHead_White_10_F",
				"CamoHead_White_11_F",
				"CamoHead_White_12_F",
				"CamoHead_White_13_F",
				"CamoHead_White_14_F",
				"CamoHead_White_15_F",
				"CamoHead_White_16_F",
				"CamoHead_White_17_F",
				"CamoHead_White_18_F",
				"CamoHead_White_19_F",
				"CamoHead_White_20_F",
				"CamoHead_White_21_F",
				"CamoHead_African_01_F",
				"CamoHead_African_02_F",
				"CamoHead_African_03_F",
				"AfricanHead_01",
				"AfricanHead_02",
				"AfricanHead_03"
			];
			private _altianHeads = [
				"GreekHead_A3_01",
				"GreekHead_A3_02",
				"GreekHead_A3_03",
				"GreekHead_A3_04",
				"GreekHead_A3_05",
				"GreekHead_A3_06",
				"GreekHead_A3_07",
				"GreekHead_A3_08",
				"GreekHead_A3_09",
				"GreekHead_A3_11",
				"GreekHead_A3_12",
				"GreekHead_A3_13",
				"GreekHead_A3_14",
				"GreekHead_A3_10_a",
				"GreekHead_A3_10_sa",
				"GreekHead_A3_10_l",
				"IG_Leader",
				"CamoHead_Greek_01_F",
				"CamoHead_Greek_02_F",
				"CamoHead_Greek_03_F",
				"CamoHead_Greek_04_F",
				"CamoHead_Greek_05_F",
				"CamoHead_Greek_06_F",
				"CamoHead_Greek_07_F",
				"CamoHead_Greek_08_F",
				"CamoHead_Greek_09_F"
			];
			private _persianHeads = [
				"PersianHead_A3_01",
				"PersianHead_A3_02",
				"PersianHead_A3_03",
				"PersianHead_A3_04_a",
				"PersianHead_A3_04_sa",
				"PersianHead_A3_04_l",
				"O_Colonel",
				"CamoHead_Persian_01_F",
				"CamoHead_Persian_02_F",
				"CamoHead_Persian_03_F"
			];
			private _chineseHead = [
				"AsianHead_A3_01",
				"AsianHead_A3_02",
				"AsianHead_A3_03",
				"AsianHead_A3_04",
				"AsianHead_A3_05",
				"AsianHead_A3_06",
				"AsianHead_A3_07",
				"PersianHead_A3_04_a",
				"PersianHead_A3_04_sa",
				"PersianHead_A3_04_l",
				"CamoHead_Asian_01_F",
				"CamoHead_Asian_02_F",
				"CamoHead_Asian_03_F"
			];
			private _tanoanHead = [
				"TanoanHead_A3_01",
				"TanoanHead_A3_02",
				"TanoanHead_A3_03",
				"TanoanHead_A3_04",
				"TanoanHead_A3_05",
				"TanoanHead_A3_06",
				"TanoanHead_A3_07",
				"TanoanHead_A3_08",
				"TanoanHead_A3_09",
				"PersianHead_A3_04_a",
				"PersianHead_A3_04_sa",
				"PersianHead_A3_04_l",
				"CamoHead_African_01_F",
				"CamoHead_African_02_F",
				"CamoHead_African_03_F",
				"TanoanBossHead"
			];
			private _polishHead = [
				"LivonianHead_1",
				"LivonianHead_2",
				"LivonianHead_3",
				"LivonianHead_4",
				"LivonianHead_5",
				"LivonianHead_6",
				"LivonianHead_7",
				"LivonianHead_8",
				"LivonianHead_9",
				"LivonianHead_10",
				"WhiteHead_22_a",
				"WhiteHead_22_l",
				"WhiteHead_22_sa",
				"CamoHead_White_01_F",
				"CamoHead_White_02_F",
				"CamoHead_White_03_F",
				"CamoHead_White_04_F",
				"CamoHead_White_05_F",
				"CamoHead_White_06_F",
				"CamoHead_White_07_F",
				"CamoHead_White_08_F",
				"CamoHead_White_09_F",
				"CamoHead_White_10_F",
				"CamoHead_White_11_F",
				"CamoHead_White_12_F",
				"CamoHead_White_13_F",
				"CamoHead_White_14_F",
				"CamoHead_White_15_F",
				"CamoHead_White_16_F",
				"CamoHead_White_17_F",
				"CamoHead_White_18_F",
				"CamoHead_White_19_F",
				"CamoHead_White_20_F",
				"CamoHead_White_21_F"
			];
			private _russianHead = [
				"RussianHead_1",
				"RussianHead_2",
				"RussianHead_3",
				"RussianHead_4",
				"RussianHead_5",
				"WhiteHead_22_a",
				"WhiteHead_22_l",
				"WhiteHead_22_sa",
				"CamoHead_White_01_F",
				"CamoHead_White_02_F",
				"CamoHead_White_03_F",
				"CamoHead_White_04_F",
				"CamoHead_White_05_F",
				"CamoHead_White_06_F",
				"CamoHead_White_07_F",
				"CamoHead_White_08_F",
				"CamoHead_White_09_F",
				"CamoHead_White_10_F",
				"CamoHead_White_11_F",
				"CamoHead_White_12_F",
				"CamoHead_White_13_F",
				"CamoHead_White_14_F",
				"CamoHead_White_15_F",
				"CamoHead_White_16_F",
				"CamoHead_White_17_F",
				"CamoHead_White_18_F",
				"CamoHead_White_19_F",
				"CamoHead_White_20_F",
				"CamoHead_White_21_F"
			];

			if(_world == "Altis" || _world == "Stratis" || _world == "VR") then {
				switch (side (group player)) do {
					case west: {
						if((!(speaker player in _americanVoice)) && (!(speaker player in _britishVoice))) then {
							[player,selectRandom _americanVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _whiteHeads)) then {
							[player,selectRandom _whiteHeads] remoteExec ['setFace'];
						};
					};
					case east: {
						if(!(speaker player in _persianVoice)) then {
							[player,selectRandom _persianVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _persianHeads)) then {
							[player,selectRandom _persianHeads] remoteExec ['setFace'];
						};
					};
					case independent: {
						if(!(speaker player in _altianVoice)) then {
							[player,selectRandom _altianVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _altianHeads)) then {
							[player,selectRandom _altianHeads] remoteExec ['setFace'];
						};
					};
					case civilian: {
						if(!(speaker player in _altianVoice)) then {
							[player,selectRandom _altianVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _altianHeads)) then {
							[player,selectRandom _altianHeads] remoteExec ['setFace'];
						};
					};
				};
			};
			if(_world == "Malden") then {
				switch (side (group player)) do {
					case west: {
						if((!(speaker player in _americanVoice)) && (!(speaker player in _britishVoice)) && (!(speaker player in _frenchVoice)) && (!(speaker player in _frenchEnglishVoice))) then {
							[player,selectRandom _americanVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _whiteHeads)) then {
							[player,selectRandom _whiteHeads] remoteExec ['setFace'];
						};
					};
					case east: {
						if(!(speaker player in _chineseVoice)) then {
							[player,selectRandom _chineseVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _chineseHead)) then {
							[player,selectRandom _chineseHead] remoteExec ['setFace'];
						};
					};
					case independent: {
						if((!(speaker player in _frenchVoice)) && (!(speaker player in _frenchEnglishVoice))) then {
							[player,selectRandom _frenchVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _whiteHeads)) then {
							[player,selectRandom _whiteHeads] remoteExec ['setFace'];
						};
					};
					case civilian: {
						if((!(speaker player in _frenchVoice)) && (!(speaker player in _frenchEnglishVoice))) then {
							[player,selectRandom _frenchVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _whiteHeads)) then {
							[player,selectRandom _whiteHeads] remoteExec ['setFace'];
						};
					};
				};
			};
			if(_world == "Tanoa") then {
				switch (side (group player)) do {
					case west: {
						if((!(speaker player in _americanVoice)) && (!(speaker player in _britishVoice)) && (!(speaker player in _frenchVoice)) && (!(speaker player in _frenchEnglishVoice))) then {
							[player,selectRandom _americanVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _whiteHeads)) then {
							[player,selectRandom _whiteHeads] remoteExec ['setFace'];
						};
					};
					case east: {
						if(!(speaker player in _chineseVoice)) then {
							[player,selectRandom _chineseVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _chineseHead)) then {
							[player,selectRandom _chineseHead] remoteExec ['setFace'];
						};
					};
					case independent: {
						if((!(speaker player in _frenchVoice)) && (!(speaker player in _frenchEnglishVoice))) then {
							[player,selectRandom _frenchVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _tanoanHead)) then {
							[player,selectRandom _tanoanHead] remoteExec ['setFace'];
						};
					};
					case civilian: {
						if((!(speaker player in _frenchVoice)) && (!(speaker player in _frenchEnglishVoice))) then {
							[player,selectRandom _frenchVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _tanoanHead)) then {
							[player,selectRandom _tanoanHead] remoteExec ['setFace'];
						};
					};
				};
			};
			if(_world == "Enoch") then {
				switch (side (group player)) do {
					case west: {
						if((!(speaker player in _americanVoice)) && (!(speaker player in _britishVoice)) && (!(speaker player in _polishVoice))) then {
							[player,selectRandom _americanVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _whiteHeads)) then {
							[player,selectRandom _whiteHeads] remoteExec ['setFace'];
						};
					};
					case east: {
						if(!(speaker player in _russianVoice)) then {
							[player,selectRandom _russianVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _russianHead)) then {
							[player,selectRandom _russianHead] remoteExec ['setFace'];
						};
					};
					case independent: {
						if(!(speaker player in _polishVoice)) then {
							[player,selectRandom _polishVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _polishHead)) then {
							[player,selectRandom _polishHead] remoteExec ['setFace'];
						};
					};
					case civilian: {
						if(!(speaker player in _polishVoice)) then {
							[player,selectRandom _polishVoice] remoteExec ['setSpeaker'];
						};
						if(!(face player in _polishHead)) then {
							[player,selectRandom _polishHead] remoteExec ['setFace'];
						};
					};
				};
			};
			missionNamespace setVariable ["MAZ_EP_CC_faceLoopTime",time + 1];
		};

		MAZ_fnc_detectNadeLoop = {
			if(time < (missionNamespace getVariable ["MAZ_EP_CC_nadeLoopTime",time])) exitWith {};
			call MAZ_fnc_detectEnemyGrenade;
			missionNamespace setVariable ["MAZ_EP_CC_nadeLoopTime", time + 1];
		};

		MAZ_fnc_detectEnemyGrenade = {
			if(missionNamespace getVariable ["MAZ_delayCallEnemyFrag",false]) exitWith {};
			private _nearGrenades = (nearestObjects [getPos player,["GrenadeHand"],7]) select {
				typeOf _x == "GrenadeHand" && 
				(((getPosATL _x) select 2) < 1) &&
				speed _x < 1.5
			};
			if(count _nearGrenades > 0) then {
				if(random 1 < 0.3) then {
					[] spawn MAZ_fnc_callEnemyGrenade;
				};
			};
		};

		MAZ_fnc_callEnemyGrenade = {
			[player] spawn MAZ_makeLipSync;
			MAZ_delayCallEnemyFrag = true;
			private _enemyGrenade = [
				"IncomingGrenadeE_1.ogg",
				"IncomingGrenadeE_2.ogg",
				"IncomingGrenadeE_3.ogg"
			];
			private _nadeLine = selectRandom _enemyGrenade;
			private _speaker = toLower (speaker player);
			private _behaviorPlayer = "COMBAT";
			private _folderPath = _speaker select [6];
			if("chi" in _speaker || "fre" in _speaker || "engfre" in _speaker) exitWith {
				playSound3D [format ["A3\dubbing_radio_f_exp\data\%1\%2\RadioProtocol%5\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_nadeLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
			};
			if("pol" in _speaker || "rus" in _speaker) exitWith {
				playSound3D [format ["A3\dubbing_radio_f_enoch\data\%1\%2\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_nadeLine], player,false,getPosASL player,5,1,75];
			};
			playSound3D [format ["A3\dubbing_radio_f\data\%1\%2\RadioProtocol%5\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_nadeLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
			sleep 10;
			MAZ_delayCallEnemyFrag = false;
		};

		MAZ_fnc_callGrenadeThrow = {
			[player] spawn MAZ_makeLipSync;
			private _throwGrenade = [
				"ThrowingGrenadeE_1.ogg",
				"ThrowingGrenadeE_2.ogg",
				"ThrowingGrenadeE_3.ogg"
			];
			private _nadeLine = selectRandom _throwGrenade;

			private _speaker = toLower (speaker player);
			private _behaviorPlayer = "COMBAT";
			private _folderPath = _speaker select [6];
			if("chi" in _speaker || "fre" in _speaker || "engfre" in _speaker) exitWith {
				playSound3D [format ["A3\dubbing_radio_f_exp\data\%1\%2\RadioProtocol%5\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_nadeLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
			};
			if("pol" in _speaker || "rus" in _speaker) exitWith {
				playSound3D [format ["A3\dubbing_radio_f_enoch\data\%1\%2\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_nadeLine], player,false,getPosASL player,5,1,75];
			};
			playSound3D [format ["A3\dubbing_radio_f\data\%1\%2\RadioProtocol%5\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_nadeLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
		};

		MAZ_fnc_callSmokeThrow = {
			[player] spawn MAZ_makeLipSync;
			private _speaker = toLower (speaker player);
			private _throwSmoke = [
				"ThrowingSmokeE_1.ogg",
				"ThrowingSmokeE_2.ogg"
			];
			private _behaviorPlayer = "COMBAT";
			private _folderPath = _speaker select [6];
			private _smokeLine = selectRandom _throwSmoke;
			if("chi" in _speaker || "fre" in _speaker || "engfre" in _speaker) exitWith {
				playSound3D [format ["A3\dubbing_radio_f_exp\data\%1\%2\RadioProtocol%5\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_smokeLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
			};
			if("pol" in _speaker || "rus" in _speaker) exitWith {
				playSound3D [format ["A3\dubbing_radio_f_enoch\data\%1\%2\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_smokeLine], player,false,getPosASL player,5,1,75];
			};
			playSound3D [format ["A3\dubbing_radio_f\data\%1\%2\RadioProtocol%5\%3\200_CombatShouts\%4",_folderPath,_speaker,_behaviorPlayer,_smokeLine,_folderPath select [0,3]], player,false,getPosASL player,5,1,75];
		};

		MAZ_fnc_callReadyToFire = {
			private _readyLines = [
				"IAmReady.ogg",
				"Ready.ogg"
			];
			private _readyLine = selectRandom _readyLines;
			private _speaker = toLower (speaker player);
			private _folderPath = _speaker select [6];
			private _behavior = "NORMAL";
			if(_readyLine == "Ready.ogg" && (random 1) < 0.8) then {
				_behavior = "Combat";
			};
			private _isSaid = false;
			if("chi" in _speaker || "fre" in _speaker || "engfre" in _speaker) then {
				_isSaid = true;
				playSound3D [format ["A3\dubbing_radio_f_exp\data\%1\%2\RadioProtocol%4\%5\110_Com_Announce\%3",_folderPath,_speaker,_readyLine,_folderPath select [0,3],_behavior], player,false,getPosASL player,5,1,75];
			};
			if("pol" in _speaker || "rus" in _speaker) then {
				_isSaid = true;
				playSound3D [format ["A3\dubbing_radio_f_enoch\data\%1\%2\%4\110_Com_Announce\%3",_folderPath,_speaker,_readyLine,_behavior], player,false,getPosASL player,5,1,75];
			};
			if(!_isSaid) then {
				playSound3D [format ["A3\dubbing_radio_f\data\%1\%2\RadioProtocol%4\%5\110_Com_Announce\%3",_folderPath,_speaker,_readyLine,_folderPath select [0,3],_behavior], player,false,getPosASL player,5,1,75];
			};
		};
		comment '(vehicle player) addEventHandler ["Fired", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
			private _timeToReload = getNumber (configFile >> "CfgWeapons" >> _weapon >> "ReloadTime");
			[_unit, _gunner, _timeToReload] spawn {
				params ["_vehicle","_gunner","_timeToReload"];
				sleep _timeToReload;
				if(_gunner in _vehicle) then {
					[[], {
						call MAZ_fnc_callReadyToFire;
					}] remoteExec ["spawn",_gunner];
				};
			};
		}]';

		waitUntil {uisleep 0.1;!isNull (findDisplay 46) && alive player};
		sleep 0.1;

		MAZ_EH_FiredMan_callThrowGrenade = player addEventHandler ["FiredMan", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
			if(!MAZ_EP_CC_callNadeThrowToggle) exitWith {};
			if(_weapon == "Throw") then {
				private _grenadesClass = [
					"HandGrenade",
					"MiniGrenade"
				];
				private _smokesClass = [
					'SmokeShell',
					'SmokeShellOrange',
					'SmokeShellBlue',
					'SmokeShellRed',
					'SmokeShellPurple',
					'SmokeShellGreen'
				];

				if(_magazine in _grenadesClass) exitWith {
					call MAZ_fnc_callGrenadeThrow;
				};
				if(_magazine in _smokesClass) exitWith {
					call MAZ_fnc_callSmokeThrow;
				};
			};
		}];
		
		[] spawn {
			waitUntil {!isNil "MAZ_EP_fnc_addFunctionToMainLoop"};
			["MAZ_autoCallMedic"] call MAZ_EP_fnc_addFunctionToMainLoop;
			["MAZ_fnc_detectNadeLoop"] call MAZ_EP_fnc_addFunctionToMainLoop;
			["MAZ_changeVoiceAndFace"] call MAZ_EP_fnc_addFunctionToMainLoop;
		};

		MAZ_EP_CC_reloadCooldown = false;
		if(!isNil "MAZ_Key_callReload") then {
			(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_Key_callReload];
		};
		MAZ_Key_callReload = (findDisplay 46) displayAddEventHandler ["KeyDown", {
			if(!MAZ_EP_CC_combatCalloutsEnabled || !MAZ_EP_CC_callReloadToggle) exitWith {};
			if ((_this select 1) in actionKeys "ReloadMagazine") then {
				[] spawn MAZ_callOutReload;
			};
		}];
		if(!isNil "MAZ_EH_Reloaded_resetTimer") then {
			player removeEventHandler ["Reloaded",MAZ_EH_Reloaded_resetTimer];
		};
		MAZ_EH_Reloaded_resetTimer = player addEventHandler ["Reloaded",{MAZ_EP_CC_reloadCooldown = false;}];
		
		MAZ_EP_CC_delayToCallKill = false;
		MAZ_EP_CC_delayToCallSuppress = false;
		if(!isNil "MAZ_EH_Suppressed_callSuppressed") then {
			player removeEventHandler ["Suppressed",MAZ_EH_Suppressed_callSuppressed];
		};
		MAZ_EH_Suppressed_callSuppressed = player addEventHandler ["Suppressed", {
			params ["_unit", "_distance", "_shooter", "_instigator", "_ammoObject", "_ammoClassName", "_ammoConfig"];
			if(!MAZ_EP_CC_combatCalloutsEnabled || !MAZ_EP_CC_callSuppressedToggle) exitWith {};
			if(!MAZ_EP_CC_delayToCallSuppress) then {
				[_unit,_distance,_shooter] spawn MAZ_callSuppressed;
			};
		}];
		if(!isNil "MAZ_EH_Killed_CallDeadFriendly") then {
			player removeEventHandler ["Killed",MAZ_EH_Killed_CallDeadFriendly];
		};
		MAZ_EH_Killed_CallDeadFriendly = player addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];
			if(!MAZ_EP_CC_combatCalloutsEnabled || !MAZ_EP_CC_callDeadFriendlyToggle) exitWith {};
			[_unit] spawn MAZ_callDeadFriendly;
		}];

		MAZ_EP_CC_delayToCallHit = false;
		if(!isNil "MAZ_EH_Hit_CallHit") then {
			player removeEventHandler ["Hit",MAZ_EH_Hit_CallHit];
		};
		MAZ_EH_Hit_CallHit = player addEventHandler ["Hit",{
			params ["_unit", "_source", "_damage", "_instigator"];
			if(!MAZ_EP_CC_combatCalloutsEnabled || !MAZ_EP_CC_callHurtToggle) exitWith {};
			[_unit,_source] spawn MAZ_callOutGotHit;
		}];
		MAZ_EP_CC_delayToCallDirection = false;
		if(!isNil "MAZ_Key_callDirection") then {
			(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_Key_callDirection];
		};
		MAZ_Key_callDirection = (findDisplay 46) displayAddEventHandler ["KeyDown",{
			if(!MAZ_EP_CC_combatCalloutsEnabled || !MAZ_EP_CC_callDirectionToggle) exitWith {};
			if(inputAction 'TacticalPing' > 0 && !MAZ_EP_CC_delayToCallDirection) then {
				MAZ_EP_CC_delayToCallDirection = true;
				[] spawn MAZ_callDirection;
			};
		}];
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		[
			"Combat Callouts", 
			"Players will make callouts like 'Reloading!' and 'I need a medic' in appropriate contexts. This can help with noticing injured friendlies by audio ques rather than having to look for them. Forces those without microphones to communicate, at least, through their character.",
			[
				"Reload callouts",
				"Kill confirmation callouts",
				"Callout direction when pinging positions",
				"Callout when taking fire",
				"Callout dead friendly",
				"Callout when throwing grenades",
				"Call for a medic when incapacitated",
				"Face and voices change to match your side dependent on the map"
			]	
		] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Combat Callouts System has been loaded! Your character suddenly gained a voice box!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	[] spawn MAZ_CC_fnc_combatCalloutsCarrier;
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

[[], {
	MAZ_MEH_EntityKilled_CC = addMissionEventHandler ["EntityKilled", {
		params ["_killed", "_killer"];
		if(!MAZ_EP_CC_combatCalloutsEnabled || !MAZ_EP_CC_callKillToggle) exitWith {};
		if (((side (group _killed)) != (side (group _killer))) && isPlayer _killer) then {
			if((side (group _killed) == civilian) && _killed isKindOf "CAManBase") exitWith {
				[[],{
					[player,"F##k! I accidentally killed a civilian!"] remoteExec ['sideChat'];
				}] remoteExec ["spawn",owner (_killer)];
			};
			if(_killed isKindOf "CAManBase") then {
				[[], {
					if(!MAZ_EP_CC_delayToCallKill) then {
						[] spawn MAZ_scratchOneCall;
					};
				}] remoteExec ["spawn",owner (_killer)];
			};
		};
	}];
}] remoteExec ["spawn",2];