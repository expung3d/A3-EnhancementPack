
if(!isNull (findDisplay 312) && {!isNil "this"} && {!isNull this}) then {
	deleteVehicle this;
};

if(missionNamespace getVariable ["MAZ_EP_CoreEnabled",false]) exitWith {
	[] spawn {
		private _result = [
			parseText "
			<t size='1.3' align='center' color='#00BFBF'>Enhancement Pack Core is already running</t><br/>
			<t size='1.0' align='center'>If you'd like to edit the settings of the systems that are running press OK, otherwise press CANCEL to continue Zeusing.</t> ", 
			"Enhancement Pack Already Running", 
			true, 
			true,
			(findDisplay 312)
		] call BIS_fnc_guiMessage;
		showChat true;
		if (_result) then {
			isNil {call MAZ_EP_fnc_editSettings};
		};
	};
};

private _varName = "MAZ_System_EnhancementPackCore";
private _myJIPCode = "MAZ_EPSystem_Core_JIP";

MAZ_dropSmokeInjuredToggle = true;
publicVariable 'MAZ_dropSmokeInjuredToggle';

MAZ_globalLaserMarkers = false;
publicVariable "MAZ_globalLaserMarkers";

MAZ_EP_CoreEnabled = true;
publicVariable "MAZ_EP_CoreEnabled";

private _value = (str {
	if(isNil "MAZ_fnc_keybindCarrier") then {
		MAZ_fnc_keybindCarrier = {
			MAZ_isChangingKeybind = false;

			MAZ_fnc_newKeybind = {
				params ["_displayName","_description","_keyCode","_code",["_shift",false],["_ctrl",false],["_alt",false],["_override",false],["_zeusKeybind",false],["_keySave",""]];
				if(isNil "MAZ_KeybindData") then {
					MAZ_KeybindData = [];
				};
				private _modifiers = [_shift,_ctrl,_alt];
				private _display = if(_zeusKeybind) then {findDisplay 312} else {findDisplay 46};
				private _savedKey = [_keySave] call MAZ_fnc_getKeybindData;
				if !(_savedKey isEqualTo []) then {
					_savedKey params ["_key","_mod"];
					_keyCode = _key;
					_modifiers = _mod;
				};

				MAZ_KeybindData pushBack [_displayName,_description,_display,_keyCode,_code,_modifiers,_override,_keySave];
			};

			MAZ_fnc_removeKeybind = {
				params ["_keybindID"];
				if((count MAZ_KeybindData - 1) >= _keybindID) exitWith {
					MAZ_KeybindData deleteAt _keybindID;
					true
				};
				false
			};

			MAZ_fnc_resetSavedKeybinds = {
				profileNamespace setVariable ["MAZ_SavedKeybinds",[]];
				saveProfileNamespace;
			};

			MAZ_fnc_getKeybindData = {
				params ["_nameSearch"];
				private _savedKeys = profileNamespace getVariable ["MAZ_SavedKeybinds",[]];
				private _keyData = [];
				{
					_x params ["_name","_data"];
					if(toLower _nameSearch == toLower _name) then {
						_keyData = _data;
						break;
					};
				}forEach _savedKeys;
				_keyData;
			};

			MAZ_fnc_getSavedKeybindIndex = {
				params ["_nameSearch"];
				private _savedKeys = profileNamespace getVariable ["MAZ_SavedKeybinds",[]];
				private _index = -1;
				{
					_x params ["_name","_data"];
					if(toLower _nameSearch == toLower _name) then {
						_index = _forEachIndex;
						break;
					};
				}forEach _savedKeys;
				_index;
			};

			MAZ_fnc_saveKeybind = {
				params ["_name","_key","_mod"];
				private _savedKeys = profileNamespace getVariable ["MAZ_SavedKeybinds",[]];
				private _keyIndex = [_name] call MAZ_fnc_getSavedKeybindIndex;
				if(_keyIndex == -1) then {
					_savedKeys pushBack [_name,[_key,_mod]];
				} else {
					_savedKeys set [_keyIndex,[_name,[_key,_mod]]];
				};
				profileNamespace setVariable ["MAZ_SavedKeybinds",_savedKeys];
				saveProfileNamespace;
			};

			MAZ_fnc_changeKeybindKey = {
				params ["_index","_newKeyCode","_modifierDataNew"];
				private _KeybindData = MAZ_KeybindData select _index;
				_KeybindData params ["_displayName","_description","_display","_keyCode","_code","_modifierData","_override","_keySave"];
				if(_keyCode != _newKeyCode || !(_modifierData isEqualTo _modifierDataNew)) then {
					MAZ_KeybindData set [_index,[_displayName,_description,_display,_newKeyCode,_code,_modifierDataNew,_override,_keySave]];
					[_keySave,_newKeyCode,_modifierDataNew] call MAZ_fnc_saveKeybind;
				};
			};

			MAZ_fnc_populateKeybindsInterface = {
				params ["_listnbox"];
				if(isNil "MAZ_KeybindData") exitWith {};
				{
					_x params ["_displayName","_description","","_keyCode","","_modiferData"];
					private _KeybindText = (keyName _keyCode) trim ['"',0];
					{
						if(_x) then {
							switch (_forEachIndex) do {
								case 0: {
									_KeybindText = _KeybindText insert [0,"[SHIFT] + "];
								};
								case 1: {
									_KeybindText = _KeybindText insert [0,"[CTRL] + "];
								};
								case 2: {
									_KeybindText = _KeybindText insert [0,"[ALT] + "];
								};
							};
						};
					}forEach _modiferData;
					private _descriptionText = _description;
					if(count _descriptionText > 28) then {
						_descriptionText = [_descriptionText,0,27] call BIS_fnc_trimString;
						_descriptionText = _descriptionText insert [28,"..."];
					};
					private _index = _listnbox lnbAddRow [_KeybindText,_displayName,_descriptionText];
					_listnBox lnbSetTooltip [[_index,0],_description];
				}forEach MAZ_KeybindData;
			};

			MAZ_fnc_changeKeybindInterface = {
				params ["_index"];
				private _indexRow = _index + 1;
				private _listNBox = uiNamespace getVariable 'KeybindListnBox';
				private _KeybindMenu = uiNamespace getVariable 'MAZ_KeybindMenu';
				if(isNil "MAZ_isChangingKeybind") then {
					MAZ_isChangingKeybind = false;
					MAZ_isChangingKeybindIndex = -1;
					MAZ_isChangingKeybindEH = -1;
				};

				if(MAZ_isChangingKeybind) then {
					private _data = MAZ_KeybindData select (MAZ_isChangingKeybindIndex - 1);
					_data params ["","","","_keyCode","","_modifierData"];
					private _KeybindText = keyName _keyCode;
					{
						if(_x) then {
							switch (_forEachIndex) do {
								case 0: {
									_KeybindText = _KeybindText insert [0,"[SHIFT] + "];
								};
								case 1: {
									_KeybindText = _KeybindText insert [0,"[CTRL] + "];
								};
								case 2: {
									_KeybindText = _KeybindText insert [0,"[ALT] + "];
								};
							};
						};
					}forEach _modifierData;
					_listnbox lnbSetText [[MAZ_isChangingKeybindIndex,0],_KeybindText];
					_KeybindMenu displayRemoveEventHandler ["KeyDown",MAZ_isChangingKeybindEH];
				};

				MAZ_isChangingKeybind = true;
				MAZ_isChangingKeybindIndex = _indexRow;
				_listnbox lnbSetText [[MAZ_isChangingKeybindIndex,0],"Recording input..."];
				MAZ_isChangingKeybindEH = _KeybindMenu displayAddEventHandler ["KeyDown",{
					params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];
					if(_key == 29 || _key == 56 || _key == 42) exitWith {};
					if(_key == 1) exitWith {
						MAZ_isChangingKeybind = false;
						MAZ_isChangingKeybindIndex = -1;
						_displayOrControl displayRemoveEventHandler [_thisEvent,_thisEventHandler];
						MAZ_isChangingKeybindEH = nil;
					};
					[MAZ_isChangingKeybindIndex - 1,_key,[_shift,_ctrl,_alt]] call MAZ_fnc_changeKeybindKey;
					private _listNBox = uiNamespace getVariable 'KeybindListnBox';
					private _KeybindText = keyName _key;
					{
						if(_x) then {
							switch (_forEachIndex) do {
								case 0: {
									_KeybindText = _KeybindText insert [0,"[SHIFT] + "];
								};
								case 1: {
									_KeybindText = _KeybindText insert [0,"[CTRL] + "];
								};
								case 2: {
									_KeybindText = _KeybindText insert [0,"[ALT] + "];
								};
							};
						};
					}forEach [_shift,_ctrl,_alt];
					_listnbox lnbSetText [[MAZ_isChangingKeybindIndex,0],_KeybindText];


					MAZ_isChangingKeybind = false;
					MAZ_isChangingKeybindIndex = -1;
					_displayOrControl displayRemoveEventHandler [_thisEvent,_thisEventHandler];
					MAZ_isChangingKeybindEH = nil;
				}];
			};

			MAZ_fnc_modifyKeybindsInterface = {
				if(!isNull (uiNamespace getVariable ["MAZ_KeybindMenu",displayNull])) exitWith {};
				if(!isNull (findDisplay 49)) then {
					(findDisplay 49) closeDisplay 0;
					waitUntil {(isNull (findDisplay 49))};
				};
				with uiNamespace do {
					private _fn_convertGUIGRID = {
						params ["_mode","_value"];

						comment "Defines";
							private _GUI_GRID_WAbs = ((safeZoneW / safeZoneH) min 1.2);
							private _GUI_GRID_HAbs = (_GUI_GRID_WAbs / 1.2);
							private _GUI_GRID_W = (_GUI_GRID_WAbs / 40);
							private _GUI_GRID_H = (_GUI_GRID_HAbs / 25);
							private _GUI_GRID_X = (safeZoneX);
							private _GUI_GRID_Y = (safeZoneY + safeZoneH - _GUI_GRID_HAbs);

							private _GUI_GRID_CENTER_WAbs = _GUI_GRID_WAbs;
							private _GUI_GRID_CENTER_HAbs = _GUI_GRID_HAbs;
							private _GUI_GRID_CENTER_W = _GUI_GRID_W;
							private _GUI_GRID_CENTER_H = _GUI_GRID_H;
							private _GUI_GRID_CENTER_X = (safeZoneX + (safeZoneW - _GUI_GRID_CENTER_WAbs)/2);
							private _GUI_GRID_CENTER_Y = (safeZoneY + (safeZoneH - _GUI_GRID_CENTER_HAbs)/2);

						comment "Mode Selection";
						private _return = switch (toUpper _mode) do {
							case "X": {((_value) * _GUI_GRID_W + _GUI_GRID_CENTER_X)};
							case "Y": {((_value) * _GUI_GRID_H + _GUI_GRID_CENTER_Y)};
							case "W": {((_value) * _GUI_GRID_W)};
							case "H": {((_value) * _GUI_GRID_H)};
						};
						_return
					};
					createDialog "RscDisplayEmpty";
					showchat true;
					MAZ_KeybindMenu = findDisplay -1;

					private _label = MAZ_KeybindMenu ctrlCreate ["RscText", 1000];
					_label ctrlSetText "Modify Keybinds";
					_label ctrlSetPosition [["X",7] call _fn_convertGUIGRID, ["Y",5] call _fn_convertGUIGRID, ["W",26] call _fn_convertGUIGRID, ["H",1] call _fn_convertGUIGRID];
					_label ctrlSetTextColor [1,1,1,1];
					_label ctrlSetBackgroundColor [(profilenamespace getvariable ['GUI_BCG_RGB_R',0.13]),(profilenamespace getvariable ['GUI_BCG_RGB_G',0.54]),(profilenamespace getvariable ['GUI_BCG_RGB_B',0.21]),(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])];
					_label ctrlCommit 0;

					private _bg = MAZ_KeybindMenu ctrlCreate ["IGUIBack", 2200];
					_bg ctrlSetPosition [["X",7] call _fn_convertGUIGRID, ["Y",6.2] call _fn_convertGUIGRID, ["W",26] call _fn_convertGUIGRID, ["H",13.8] call _fn_convertGUIGRID];
					_bg ctrlSetBackgroundColor [0,0,0,0.5];
					_bg ctrlCommit 0;

					private _listBG = MAZ_KeybindMenu ctrlCreate ["RscText", 1001];
					_listBG ctrlSetPosition [["X",7.5] call _fn_convertGUIGRID, ["Y",6.5] call _fn_convertGUIGRID, ["W",25] call _fn_convertGUIGRID, ["H",1] call _fn_convertGUIGRID];
					_listBG ctrlSetBackgroundColor [0,0,0,1];
					_listBG ctrlCommit 0;

					private _listBG2 = MAZ_KeybindMenu ctrlCreate ["RscText", 1002];
					_listBG2 ctrlSetPosition [["X",7.5] call _fn_convertGUIGRID, ["Y",7.5] call _fn_convertGUIGRID, ["W",25] call _fn_convertGUIGRID, ["H",12.2] call _fn_convertGUIGRID];
					_listBG2 ctrlSetBackgroundColor [0,0,0,0.4];
					_listBG2 ctrlCommit 0;

					private _listBG2 = MAZ_KeybindMenu ctrlCreate ["RscText", 1002];
					_listBG2 ctrlSetPosition [["X",7.5] call _fn_convertGUIGRID, ["Y",7.5] call _fn_convertGUIGRID, ["W",25] call _fn_convertGUIGRID, ["H",12.2] call _fn_convertGUIGRID];
					_listBG2 ctrlSetBackgroundColor [0,0,0,0.4];
					_listBG2 ctrlCommit 0;

					private _listBG3 = MAZ_KeybindMenu ctrlCreate ["RscText", 1002];
					_listBG3 ctrlSetPosition [["X",12.95] call _fn_convertGUIGRID, ["Y",7.5] call _fn_convertGUIGRID, ["W",9.8] call _fn_convertGUIGRID, ["H",12.2] call _fn_convertGUIGRID];
					_listBG3 ctrlSetBackgroundColor [0.25,0.25,0.25,0.4];
					_listBG3 ctrlCommit 0;

					KeybindListnBox = MAZ_KeybindMenu ctrlCreate ["RscListNBox", 1500];
					KeybindListnBox ctrlSetPosition [["X",7.5] call _fn_convertGUIGRID, ["Y",6.5] call _fn_convertGUIGRID, ["W",25] call _fn_convertGUIGRID, ["H",13.2] call _fn_convertGUIGRID];
					KeybindListnBox ctrlSetBackgroundColor [0,0,0,0.5];
					lnbClear KeybindListnBox;
					for "_i" from 0 to 10 do {	
						KeybindListnBox lnbDeleteColumn _i;
					};
					KeybindListnBox lnbAddColumn 0;
					KeybindListnBox lnbAddColumn 0.2;
					KeybindListnBox lnbAddColumn 0.8;
					KeybindListnBox lnbAddRow ["Keybind","Action","Description"];
					KeybindListnBox ctrlAddEventHandler ["lbDblClick",{
						params ["_control", "_selectedIndex"];
						[_selectedIndex - 1] call MAZ_fnc_changeKeybindInterface;
					}];
					KeybindListnBox ctrlCommit 0;

					private _cancel = MAZ_KeybindMenu ctrlCreate ["RscButtonMenuCancel",2700];
					_cancel ctrlSetPosition [["X",7] call _fn_convertGUIGRID, ["Y",20.1] call _fn_convertGUIGRID, ["W",6] call _fn_convertGUIGRID, ["H",1] call _fn_convertGUIGRID];
					_cancel ctrlAddEventHandler ["ButtonClick",{
						params ["_control"];
						(uiNamespace getVariable 'MAZ_KeybindMenu') closeDisplay 2;
					}];
					_cancel ctrlCommit 0;

					private _confirm = MAZ_KeybindMenu ctrlCreate ["RscButtonMenuOk",2600];
					_confirm ctrlSetPosition [["X",27] call _fn_convertGUIGRID, ["Y",20.1] call _fn_convertGUIGRID, ["W",6] call _fn_convertGUIGRID, ["H",1] call _fn_convertGUIGRID];
					_confirm ctrlAddEventHandler ["ButtonClick",{
						params ["_control"];
						(uiNamespace getVariable 'MAZ_KeybindMenu') closeDisplay 1;
					}];
					_confirm ctrlCommit 0;
				};
				[uiNamespace getVariable 'KeybindListnBox'] call MAZ_fnc_populateKeybindsInterface;
			};

			MAZ_fnc_KeybindSystemInit = {
				waitUntil {uisleep 0.1;!isNull (findDisplay 46) && alive player};
				sleep 0.1;
				if(isNil "MAZ_KeybindData") then {
					MAZ_KeybindData = [];
				};
				if(!isNil "MAZ_Key_Keybinds46") then {
					(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_Key_Keybinds46];
				};
				MAZ_Key_Keybinds46 = (findDisplay 46) displayAddEventHandler ["KeyDown",{
					params ['_display', '_key', '_shift', '_ctrl', '_alt'];
					private _doSkip = false;
					{
						_x params ["","","_displayBind","_keyCode","_code","_modifiers","_override"];
						_modifiers params ["_isShift","_isCtrl","_isAlt"];
						private _dontRun = false;
						if((_isShift && !_shift) || (_isCtrl && !_ctrl) || (_isAlt && !_alt)) then {_dontRun = true;};
						if(_key == _keyCode && !_dontRun && _displayBind == _display && !MAZ_isChangingKeybind) then {
							[] call _code;
							if(_override) then {
								_doSkip = true;
							};
						};
					}forEach MAZ_KeybindData;
					_doSkip
				}];
				if(!isNil "MAZ_Key_Keybinds312") then {
					(findDisplay 312) displayRemoveEventHandler ["KeyDown",MAZ_Key_Keybinds312];
				};
				MAZ_Key_Keybinds312 = (findDisplay 312) displayAddEventHandler ["KeyDown",{
					params ['_display', '_key', '_shift', '_ctrl', '_alt'];
					private _doSkip = false;
					{
						_x params ["","","_displayBind","_keyCode","_code","_modifiers","_override"];
						_modifiers params ["_isShift","_isCtrl","_isAlt"];
						private _dontRun = false;
						if((_isShift && !_shift) || (_isCtrl && !_ctrl) || (_isAlt && !_alt)) then {_dontRun = true;};
						if(_key == _keyCode && !_dontRun && _displayBind == _display && !MAZ_isChangingKeybind) then {
							[] call _code;
							if(_override) then {
								_doSkip = true;
							};
						};
					}forEach MAZ_KeybindData;
					_doSkip
				}];
			};

			comment "Ctrl + 0";
			[] spawn {
				waitUntil {uisleep 0.1;!isNull (findDisplay 46) && alive player};
				sleep 0.1;
				[] spawn MAZ_fnc_KeybindSystemInit;
				if(isNil "MAZ_Key_MainKey") then {
					MAZ_Key_MainKey = ["Keybinds Menu","Edit the in-game keybinds.",11,{[] call MAZ_fnc_modifyKeybindsInterface;},false,true,false,false,false,"MAZ_KeyMenu"] call MAZ_fnc_newKeybind;
				};
			};
		};
		call MAZ_fnc_keybindCarrier;
	};

	MAZ_EP_fnc_coreInit = {
		MAZ_EP_userActions = [];
		
		MAZ_smokeGrenades = [
			'SmokeShell',
			'SmokeShellOrange',
			'SmokeShellBlue',
			'SmokeShellRed',
			'SmokeShellPurple',
			'SmokeShellGreen'
		];

		MAZ_fnc_earplugsLite = {
			private _isEarplugsIn = player getVariable ['isEarplugsIn',false];
			if(_isEarplugsIn) then {
				1 fadeSound 1;
				call MAZ_fnc_deleteEarplugIcon;
			} else {
				1 fadeSound 0.1;
				call MAZ_fnc_createEarplugIcon;
			};
			player setVariable ["isEarplugsIn",!_isEarplugsIn];
		};

		MAZ_fnc_createEarplugIcon = {
			with uiNamespace do {
				earplugsIcon = (findDisplay 46) ctrlCreate ["RscPicture",-1];
				earplugsIcon ctrlSetText "a3\ui_f\data\igui\rscingameui\rscunitinfoairrtdfull\ico_cpt_sound_off_ca.paa";
				earplugsIcon ctrlSetTextColor [1,1,1,0.7];
				earplugsIcon ctrlSetPosition [0.00499997 * safezoneW + safezoneX,0.137 * safezoneH + safezoneY,0.0257812 * safezoneW,0.044 * safezoneH];
				earplugsIcon ctrlCommit 0;
			};
		};

		MAZ_fnc_deleteEarplugIcon = {
			with uiNamespace do {
				ctrlDelete earplugsIcon;
			};
		};

		MAZ_fnc_disableMovement = {
			params [["_disableRotate",true]];
			call MAZ_fnc_enableMovement;
			MAZ_DEH_KeyDown_OverrideMovement = (findDisplay 46) displayAddEventHandler ["KeyDown", {
				params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];
				private _actions = ["MoveForward","MoveBack","TurnLeft","TurnRight","MoveFastForward","MoveSlowFoward","MoveLeft","MoveRight"];
				private _keys = [];
				{
					_keys = _keys + (actionKeys _x);
				}forEach _actions;
				(_key in _keys)
			}];
			if(_disableRotate) then {
				[
					"MAZ_OverrideTurning",
					"onEachFrame",
					{
						params ["_direction"];
						if(abs (getDir player - _direction) > 0.1) then {
							player setDir _direction;
						};
					},
					[getDir player]
				] call BIS_fnc_addStackedEventHandler;
			};
		};

		MAZ_fnc_enableMovement = {
			if(!isNil "MAZ_DEH_KeyDown_OverrideMovement") then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_DEH_KeyDown_OverrideMovement];
			};
			["MAZ_OverrideTurning", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
		};

		MAZ_fnc_removeSitAnimation = {
			if(!isNil "MAZ_EH_AnimDone_SitAnimation") then {
				player removeEventHandler ["AnimDone",MAZ_EH_AnimDone_SitAnimation];
			};
			if(!isNil "MAZ_EP_Sitting_BackpackType") then {
				player addBackpackGlobal MAZ_EP_Sitting_BackpackType;
				MAZ_EP_Sitting_BackpackType = nil;
			};
			if(!isNil "MAZ_EP_Sitting_BackpackHolder") then {
				deleteVehicle MAZ_EP_Sitting_BackpackHolder;
				MAZ_EP_Sitting_BackpackHolder = nil;
				[backpackContainer player,[0,(MAZ_EP_Sitting_BackpackTexture # 0)]] remoteExec ["setObjectTexture"];
				MAZ_EP_Sitting_BackpackTexture = nil;
			};
		};

		MAZ_fnc_doSitAnimation = {
			params [["_hideBag",true]];
			call MAZ_fnc_removeSitAnimation;
			MAZ_EP_Sitting_AnimSet = selectRandom [
				["HubSittingChairA_idle1","HubSittingChairA_idle2","HubSittingChairA_idle3","HubSittingChairA_move1"],
				["HubSittingChairB_idle1","HubSittingChairB_idle2","HubSittingChairB_idle3","HubSittingChairB_move1"],
				["HubSittingChairC_idle1","HubSittingChairC_idle2","HubSittingChairC_idle3","HubSittingChairC_move1"],
				["HubSittingChairUA_idle1","HubSittingChairUA_idle2","HubSittingChairUA_idle3"],
				["HubSittingChairUB_idle1","HubSittingChairUB_idle2","HubSittingChairUB_idle3"],
				["HubSittingChairUC_idle1","HubSittingChairUC_idle2","HubSittingChairUC_idle3"]
			];
			MAZ_EH_AnimDone_SitAnimation = player addEventHandler ["AnimDone", {
				if (alive player) then {
					private _anim = selectRandom MAZ_EP_Sitting_AnimSet;
					[player,_anim] remoteExec ["switchMove"];
				};
			}];
			[player,selectRandom MAZ_EP_Sitting_AnimSet] remoteExec ["switchMove"];
			if(_hideBag) then {
				if(backpack player != "") then {
					MAZ_EP_Sitting_BackpackHolder = "groundweaponholder" createVehicle (getpos player);  
					MAZ_EP_Sitting_BackpackHolder addBackpackCargoGlobal [backpack player,1];  
					MAZ_EP_Sitting_BackpackHolder attachTo [player,[-0.1,0.9,0.65]];
					MAZ_EP_Sitting_BackpackHolder setVectorDirAndUp [[0,1,0],[0,0,1]];
					MAZ_EP_Sitting_BackpackTexture = getObjectTextures (backpackContainer player);
					if((backpack player) isKindOf "Weapon_Bag_Base") then {
						MAZ_EP_Sitting_BackpackType = backpack player;
						removeBackpack player;
					} else {
						[backpackContainer player,[0,""]] remoteExec ["setObjectTexture"];
					};
				};
			};
		};

		MAZ_fnc_sitDown = {
			if(player getVariable ["MAZ_EP_Sitting",false]) exitWith {call MAZ_fnc_standUp};
			private _chair = cursorObject;
			if(isNull _chair) exitWith {};
			if(player distance _chair > 4) exitWith {};

			private _chairTypes = [
				["land_campingchair_v2_f",180,[0,-0.1,-0.5]],
				["land_campingchair_v2_white_f",180,[0,-0.1,-0.5]],
				["land_campingchair_v1_f",180,[0,-0.1,-0.5]],
				["land_chairplastic_f",90,[0.05,0,-0.5]],
				["land_rattanchair_01_f",180,[0,-0.1,-1]],
				["land_armchair_01_f",0,[0,0,-1.5]],
				["land_chairwood_f",180,[0,0,-0.5]],
				["land_officechair_01_f",180,[0,-0.05,-0.4]]
			];
			private _benchTypes = [
				["land_bench_01_f",[[-0.65,-0.1,-1],[0,-0.1,-1],[0.65,-0.1,-1]]],
				["land_bench_02_f",[[-0.65,-0.1,-1],[0,-0.1,-1],[0.65,-0.1,-1]]],
				["land_bench_03_f",[[-0.65,-0.1,-1],[0,-0.1,-1],[0.65,-0.1,-1]]],
				["land_bench_04_f",[[-0.65,0.1,-0.35],[0,0.1,-0.35],[0.65,0.1,-0.35]],true],
				["land_bench_05_f",[[-0.65,-0.1,-1],[0,-0.1,-1],[0.65,-0.1,-1]]],
				["land_sofa_01_f",[[-0.6,0.1,-0.45],[0,0.1,-0.45],[0.6,0.1,-0.45]],true]
			];
			private _logs = [
				["land_woodenlog_f"],
				["land_woodenlog_02_f"]
			];

			private _sat = false;
			private _type = typeOf _chair;
			if(_type == "") then {
				private _split = (str _chair) splitString " ";
				if(count _split == 2) then {
					private _model = _split # 1;
					_model = _model select [0,count _model - 4];
					_type = "land_" + _model;
				};
			};
			private _index = _chairTypes findIf {toLower _type in _x};
			if(_index != -1) then {
				(_chairTypes select _index) params ["_type","_dir","_offset"];
				private _pos = _chair modelToWorld _offset;
				player setVelocity [0,0,0];
				player setPos _pos;
				player allowDamage false;
				player setDir (getDir _chair + _dir);
				_sat = true;
			};
			_index = _benchTypes findIf {toLower _type in _x};
			if(_index != -1) then {
				(_benchTypes select _index) params ["_type","_offsets",["_attach",false]];
				private _spots = _chair getVariable ["MAZ_EP_BenchSpots",[]];
				if(_spots isEqualTo []) then {
					_spots resize [(count _offsets),objNull];
				};
				private _indexes = [];
				{
					if(isNull _x) then {
						_indexes pushBack _forEachIndex;
					};
				}forEach _spots;

				private _index = selectRandom _indexes;
				private _offset = _offsets select _index;
				_spots set [_index,player];
				_chair setVariable ["MAZ_EP_BenchSpots",_spots,true];
				
				private _pos = _chair modelToWorld _offset;
				player setVelocity [0,0,0];
				if(_attach) then {
					player attachTo [_chair,_offset];
				} else {
					player setPos _pos;
				};
				player allowDamage false;
				
				if(!_attach) then {
					player setDir (getDir _chair + 180);
				} else {
					if(toLower _type == "land_bench_04_f") then {
						player setDir 180;
					};
				};
				_sat = true;
				
			};
			_index = _logs findIf {toLower _type in _x};
			if(_index != -1) then {
				player disableCollisionWith _chair;
				_chair disableCollisionWith player;
				private _pos = _chair modelToWorld [0,0,-0.5];
				player setVelocity [0,0,0];
				player setPos _pos;
				player allowDamage false;
				if(_type == "Land_WoodenLog_F") then {
					private _dir = getDir player;
					player attachTo [_chair,[0,0,-0.2]];
					player setDir _dir;
				};

				player setVariable ["MAZ_EP_Chair",_chair];
				player setVariable ["MAZ_EP_Sitting",true];
				[false] call MAZ_fnc_doSitAnimation;
				sleep 0.1;
				[false] call MAZ_fnc_disableMovement;
			};
			if(_sat) then {
				player setVariable ["MAZ_EP_Chair",_chair];
				player setVariable ["MAZ_EP_Sitting",true];
				[] call MAZ_fnc_doSitAnimation;
				sleep 0.1;
				[] call MAZ_fnc_disableMovement;
			};
		};

		MAZ_fnc_standUp = {
			private _chair = player getVariable "MAZ_EP_Chair";
			private _playerPos = getPosATL player;
			[player,""] remoteExec ["switchMove"];
			detach player;
			player allowDamage true;
			player setPos (player getPos [0.75,getDir player]);
			player enableCollisionWith _chair;
			player setVariable ["MAZ_EP_Chair",objNull];
			player setVariable ["MAZ_EP_Sitting",false];

			private _spots = _chair getVariable "MAZ_EP_BenchSpots";
			if(!isNil "_spots") then {
				private _index = _spots find player;
				_spots set [_index,objNull];
				_chair setVariable ["MAZ_EP_BenchSpots",_spots,true];
			};
			
			call MAZ_fnc_removeSitAnimation;
			call MAZ_fnc_enableMovement;
		};

		MAZ_liteUnflip = {
			private _vehicle = cursorTarget;
			private _distVeh = (player distance _vehicle);
			if(typeOf _vehicle isKindOf "Man") exitWith {};
			if(isNil "MAZ_EP_isPushing") then {
				MAZ_EP_isPushing = false;
			};
			if(_distVeh < 10 && !MAZ_EP_isPushing) then {
				if(typeOf _vehicle isKindOf "Car") then {
					systemChat "[Z.A.M.] - Unflipping vehicle...";
					MAZ_EP_isPushing = true;
					sleep 5;
					MAZ_EP_isPushing = false;
					_vehicle setVectorUp surfaceNormal getPos _vehicle;
					_vehicle setPosATL [getPosATL _vehicle select 0, getPosATL _vehicle select 1, 0.2];
					systemChat "[Z.A.M.] - Vehicle unflipped.";
				};
				if(typeOf _vehicle isKindOf "Plane") then {
					systemChat "[Z.A.M.] - Pushing vehicle...";
					MAZ_EP_isPushing = true;
					sleep 2;
					MAZ_EP_isPushing = false;
					_vehicle setVectorUp surfaceNormal getPos _vehicle;
					_vel = velocity _vehicle;
					_dir = direction _vehicle;
					_speed = -7; comment "Added speed";
					_vehicle setVelocity [
						(_vel select 0) + (sin _dir * _speed), 
						(_vel select 1) + (cos _dir * _speed), 
						(_vel select 2)
					];
					systemChat "[Z.A.M.] - Vehicle pushed.";
				};
				if(typeOf _vehicle isKindOf "Ship") then {
					systemChat "[Z.A.M.] - Pushing vehicle...";
					MAZ_EP_isPushing = true;
					sleep 2;
					MAZ_EP_isPushing = false;
					_vehicle setVectorUp surfaceNormal getPos _vehicle;
					_vel = velocity _vehicle;
					_dir = direction _vehicle;
					_speed = -5; comment "Added speed";
					_vehicle setVelocity [
						(_vel select 0) + (sin _dir * _speed), 
						(_vel select 1) + (cos _dir * _speed), 
						(_vel select 2)
					];
					systemChat "[Z.A.M.] - Vehicle pushed.";
				};
			};
		};

		MAZ_fnc_assignSavedViewDistance = {
			private _distance = profileNamespace getVariable ["MAZ_defaultViewDistance",[]];
			if(_distance isEqualType 1600) then {
				_distance = [];
			};
			if(_distance isEqualTo []) then {
				_distance = [[1600,1600],[2500,2000],[3000,2500]];
				profileNamespace setVariable ["MAZ_defaultViewDistance",_distance];
				saveProfileNamespace;
			};
			private _dist = _distance # 0;
			setViewDistance (_dist # 0);
			setObjectViewDistance (_dist # 1);
		};

		MAZ_fnc_saveViewDistance = {
			params ["_distance","_objectDist","_mode"];
			private _savedDist = profileNamespace getVariable ["MAZ_defaultViewDistance",[]];
			_savedDist set [_mode,[_distance,_objectDist]];
			profileNamespace setVariable ["MAZ_defaultViewDistance",_savedDist];
			saveProfileNamespace;
		};

		MAZ_fnc_getSavedViewDistance = {
			params ["_mode"];
			private _savedDist = profileNamespace getVariable ["MAZ_defaultViewDistance",[]];
			(_savedDist # _mode);
		};

		MAZ_fnc_newViewDistanceMenu = {
			with uiNamespace do {
				MAZ_ViewDist_Display = (findDisplay 46) createDisplay "RscDisplayEmpty";
				MAZ_ViewDist_Display displayAddEventHandler ["Unload", {
					call MAZ_fnc_confirmViewDistance;
				}];
				MAZ_ViewDist_ControlGroup = MAZ_ViewDist_Display ctrlCreate ["RscControlsGroupNoScrollbars",3010];
				MAZ_ViewDist_ControlGroup ctrlSetPosition [0.3,0.12,0.4,0];
				MAZ_ViewDist_ControlGroup ctrlCommit 0;
				
				private _bg = MAZ_ViewDist_Display ctrlCreate ["RscPicture",-1,MAZ_ViewDist_ControlGroup];
				_bg ctrlSetPosition [0,0.045,0.4,0];
				_bg ctrlSetText "#(argb,8,8,3)color(0,0,0,0.7)";

				private _color = ["GUI", "BCG_RGB"] call BIS_fnc_displayColorGet;
				private _text = MAZ_ViewDist_Display ctrlCreate ["RscText",-1,MAZ_ViewDist_ControlGroup];
				_text ctrlSetText "CHANGE VIEW DISTANCE";
				_text ctrlSetPosition [0,0,0.4,0.04];
				_text ctrlSetTextColor (["GUI", "TITLETEXT_RGB"] call BIS_fnc_displayColorGet);
				_text ctrlSetBackgroundColor _color;
				_text ctrlCommit 0;

				private _yPos = 0.05;
				private _spacing = 0.01;

				MAZ_ViewDist_LabelCtrls = [];
				{
					private _typeText = MAZ_ViewDist_Display ctrlCreate ["RscStructuredText",-1,MAZ_ViewDist_ControlGroup];
					_typeText ctrlSetStructuredText parseText (format ["<t align='right'>%1</t>",_x]);
					_typeText ctrlSetPosition [0,_yPos,0.1,0.04];
					_typeText ctrlSetBackgroundColor [0,0,0,0.8];
					_typeText ctrlCommit 0;
					MAZ_ViewDist_LabelCtrls pushBack _typeText;
					_yPos = _yPos + 0.04 + _spacing;

					private _viewDistanceIndex = _forEachIndex;
					private _viewDistances = [_viewDistanceIndex] call (missionNamespace getVariable ["MAZ_fnc_getSavedViewDistance",{}]);
					private _sliders = [];
					{
						private _viewDistLabel = MAZ_ViewDist_Display ctrlCreate ["RscStructuredText",-1,MAZ_ViewDist_ControlGroup];
						_viewDistLabel ctrlSetStructuredText parseText (format ["<t align='right'>%1:</t>",_x]);
						_viewDistLabel ctrlSetPosition [0,_yPos,0.1,0.04];
						_viewDistLabel ctrlCommit 0;

						private _viewDistanceSlider = MAZ_ViewDist_Display ctrlCreate ["RscXSliderH",-1,MAZ_ViewDist_ControlGroup];
						_viewDistanceSlider ctrlSetPosition [0.1,_yPos,0.2,0.04];
						_viewDistanceSlider sliderSetRange [1000,12000];
						_viewDistanceSlider sliderSetPosition (_viewDistances # _forEachIndex);
						_viewDistanceSlider ctrlAddEventHandler ["sliderPosChanged", {
							params ["_ctrlSlider", "_value"];
							private _ctrlEdit = _ctrlSlider getVariable "MAZ_SliderLinkedEdit";
							private _roundedValue = round _value;
							_ctrlEdit ctrlSetText format ["%1",_roundedValue];
						}];
						_viewDistanceSlider ctrlCommit 0;
						_sliders pushBack _viewDistanceSlider;

						private _viewDistanceEdit = MAZ_ViewDist_Display ctrlCreate ["RscEdit",-1,MAZ_ViewDist_ControlGroup];
						_viewDistanceEdit ctrlSetPosition [0.31,_yPos,0.08,0.04];
						_viewDistanceEdit ctrlSetText (str (_viewDistances # _forEachIndex));
						_viewDistanceEdit ctrlAddEventHandler ["KeyUp", {
							params ["_control", "_key", "_shift", "_ctrl", "_alt"];
							private _num = parseNumber (ctrlText _control);
							private _sliderCtrl = _control getVariable "MAZ_EditLinkedSlider";
							_sliderCtrl sliderSetPosition _num;
						}];
						_viewDistanceEdit ctrlCommit 0;

						_viewDistanceEdit setVariable ["MAZ_EditLinkedSlider",_viewDistanceSlider];
						_viewDistanceEdit setVariable ["MAZ_SliderLinkedEdit",_viewDistanceEdit];

						_yPos = _yPos + 0.04 + _spacing;
					}forEach ["VIEW","OBJECT"];
					_typeText setVariable ["MAZ_ViewDist_Sliders",_sliders];
				}forEach ["ON FOOT","IN CAR","IN AIR"];
				_yPos = _yPos - 0.04;
				_bg ctrlSetPositionH _yPos;
				_bg ctrlCommit 0;

				private _closeButton = MAZ_ViewDist_Display ctrlCreate ["RscButtonMenu",-1,MAZ_ViewDist_ControlGroup];
				_closeButton ctrlSetPosition [0,_yPos + 0.05,0.4,0.04];
				_closeButton ctrlSetText "CLOSE";
				_closeButton ctrlAddEventHandler ["ButtonClick",{
					with uiNamespace do {
						MAZ_ViewDist_Display closeDisplay 0;
					};
				}];
				_closeButton ctrlCommit 0;
				_yPos = _yPos + 0.09;

				MAZ_ViewDist_ControlGroup ctrlSetPositionH _yPos;
				MAZ_ViewDist_ControlGroup ctrlSetPositionY (0.5 - (_yPos / 2));
				MAZ_ViewDist_ControlGroup ctrlCommit 0;
			};
		};

		MAZ_fnc_confirmViewDistance = {
			private _labels = uiNamespace getVariable ["MAZ_ViewDist_LabelCtrls",[]];
			private _viewDistances = [];
			{
				private _sliders = _x getVariable ["MAZ_ViewDist_Sliders",[]];
				private _viewDist = [];
				{
					_viewDist pushBack (round (sliderPosition _x));
				}forEach _sliders;
				_viewDistances pushBack _viewDist;
			}forEach _labels;

			{
				private _saved = [_forEachIndex] call MAZ_fnc_getSavedViewDistance;
				if(_x isEqualTo _saved) then {continue};
				[_x # 0, _x # 1,_forEachIndex] call MAZ_fnc_saveViewDistance;
			}forEach _viewDistances;
			call MAZ_fnc_setViewDistance;
		};

		MAZ_fnc_setViewDistance = {
			if(vehicle player == player) exitWith {
				private _dist = [0] call MAZ_fnc_getSavedViewDistance;
				setViewDistance (_dist # 0);
				setObjectViewDistance (_dist # 1);
			};
			private _veh = vehicle player;
			if(_veh isKindOf "Air") exitWith {
				private _dist = [2] call MAZ_fnc_getSavedViewDistance;
				setViewDistance (_dist # 0);
				setObjectViewDistance (_dist # 1);
			};
			private _dist = [1] call MAZ_fnc_getSavedViewDistance;
			setViewDistance (_dist # 0);
			setObjectViewDistance (_dist # 1);
		};

		MAZ_fnc_holsterWeapon = {
			if(currentWeapon player == "") exitWith {};
			player action ['SWITCHWEAPON',player,player,-1];
			playSound3D ["a3\sounds_f\characters\stances\rifle_to_handgun.wss", player, false, getPosASL player, 5, 1, 7.5];
			waitUntil {currentWeapon player == '' or {primaryWeapon player == '' && handgunWeapon player == ''}};
		};

		MAZ_fnc_repackButton = {
			disableSerialization;
			waitUntil{!isNull (findDisplay 602)};
			with uiNamespace do {
				repackButton = (findDisplay 602) ctrlCreate ["RscButtonMenu", 1600];
				repackButton ctrlSetBackgroundColor [0,0,0,0.6];
				repackButton ctrlSetPosition [0.433069 * safezoneW + safezoneX,0.7545 * safezoneH + safezoneY,0.3025 * safezoneW,0.027 * safezoneH];
				repackButton ctrlSetEventHandler ["ButtonClick","[] spawn MAZ_fnc_repackMagazines;"];
				repackButton ctrlSetStructuredText parseText "<t size='0.05'>&#160;</t><br/><t align='center' size='1.01'>Repack Magazines</t>";
				repackButton ctrlSetFont "PuristaSemiBold";
				repackButton ctrlCommit 0;
			};
			showChat true;
		};

		MAZ_fnc_repackMagazines = {
			private _allMags = magazinesAmmoFull player;
			private _primWep = primaryWeapon player;
			private _primWepCompatMags = [_primWep] call BIS_fnc_compatibleMagazines;
			private _secWep = handgunWeapon player;
			private _secWepCompatMags = [_secWep] call BIS_fnc_compatibleMagazines;

			private _ammoCountPrimary = 0;
			private _ammoCountSecondary = 0;
			private _primaryMagazines = [];
			private _secondaryMagazines = [];
			private _fullMagTimeReduction = 0;
			{
				_x params ["_magClass","_magAmmo","_loaded","_magType","_magLoc"];
				_magClass = toLower _magClass;
				if("grenade" in _magClass) then {continue};
				if("shell" in _magClass) then {continue};
				if(_magType != -1) then {continue};
				private _maxMagCapacity = getNumber (configfile >> "CfgMagazines" >> _magClass >> "count");
				if(_magAmmo == _maxMagCapacity) then {
					_fullMagTimeReduction = _fullMagTimeReduction + _magAmmo;
				};
				if(_magClass in _primWepCompatMags) then {
					_ammoCountPrimary = _ammoCountPrimary + _magAmmo;
					_primaryMagazines pushBack [_magClass,_maxMagCapacity,_magLoc];
				};
				if(_magClass in _secWepCompatMags) then {
					_ammoCountSecondary = _ammoCountSecondary + _magAmmo;
					_secondaryMagazines pushBack [_magClass,_maxMagCapacity,_magLoc];
				};
			}forEach _allMags;

			_primaryMagazines = [_primaryMagazines,[],{_x select 1},"DESCEND"] call BIS_fnc_sortBy; 
			_secondaryMagazines = [_secondaryMagazines,[],{_x select 1},"DESCEND"] call BIS_fnc_sortBy; 
			{
				player removeMagazine (_x select 0);
			}forEach (_primaryMagazines + _secondaryMagazines);
			
			private _timeToLoad = (_ammoCountPrimary + _ammoCountSecondary - _fullMagTimeReduction) * 0.25;
			private _magIndex = 0;
			while {_ammoCountPrimary > 0 && _magIndex < (count _primaryMagazines)} do {
				private _mag = _primaryMagazines select _magIndex;
				_mag params ["_type","_max"];
				private _bullets = if(_ammoCountPrimary < _max) then {_ammoCountPrimary} else {_max};
				player addMagazine [_type, _bullets];

				_ammoCountPrimary = _ammoCountPrimary - _bullets;
				_magIndex = _magIndex + 1;
			};
			_magIndex = 0;
			while {_ammoCountSecondary > 0 && _magIndex < (count _secondaryMagazines)} do {
				private _mag = _secondaryMagazines select _magIndex;
				_mag params ["_type","_max"];
				private _bullets = if(_ammoCountSecondary < _max) then {_ammoCountSecondary} else {_max};
				player addMagazine [_type, _bullets];

				_ammoCountSecondary = _ammoCountSecondary - _bullets;
				_magIndex = _magIndex + 1;
			};

			if(_timeToLoad > 0) then {
				[_timeToLoad] spawn MAZ_fnc_repackLoadingBar;
			};
		};

		MAZ_fnc_repackLoadingBar = {
			params ['_amountOfMags'];
			(findDisplay 602) closeDisplay 2;

			disableSerialization;
			with uiNamespace do {
				display = findDisplay 46;
				
				progressBarBackground = display ctrlCreate ['RscStructuredText' ,-1];
				progressBarBackground ctrlSetBackgroundColor [0,0,0,0.5];
				progressBarBackground ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.753 * safezoneH + safezoneY,0.4125 * safezoneW,0.022 * safezoneH];
				progressBarBackground ctrlSetFade 1;
				progressBarBackground ctrlCommit 0;
				progressBarBackground ctrlSetFade 0;
				progressBarBackground ctrlCommit 1;
				
				progressBarForeground = display ctrlCreate ['RscText' ,-1];
				progressBarForeground ctrlSetBackgroundColor [0.3,1,0.2,0.7];
				progressBarForeground ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.753 * safezoneH + safezoneY,0 * safezoneW,0.022 * safezoneH];
				progressBarForeground ctrlSetFade 1;
				progressBarForeground ctrlCommit 0;
				progressBarForeground ctrlSetFade 0;
				progressBarForeground ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.753 * safezoneH + safezoneY,0.020625 * safezoneW,0.022 * safezoneH];
				progressBarForeground ctrlCommit 1;

				progressBarText = display ctrlCreate ['RscStructuredText' ,-1];
				progressBarText ctrlSetBackgroundColor [0,0,0,0.5];
				progressBarText ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.753 * safezoneH + safezoneY,0.4125 * safezoneW,0.022 * safezoneH];
				progressBarText ctrlSetStructuredText parseText "<t align='center'>Repacking Mags...</t>";
				progressBarText ctrlSetFade 1;
				progressBarText ctrlCommit 0;
				progressBarText ctrlSetFade 0;
				progressBarText ctrlCommit 1;
				
				uiSleep 1;
				
			};

			MAZ_magRepackDone = false;
			[] spawn MAZ_fnc_repackAnimation;

			with uiNamespace do {
				progressBarForeground ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.753 * safezoneH + safezoneY,0.4125 * safezoneW,0.022 * safezoneH];
				progressBarForeground ctrlCommit _amountOfMags;
				
				uiSleep _amountOfMags;

				missionNamespace setVariable ["MAZ_magRepackDone",true];
				player playActionNow "stop";

				progressBarText ctrlSetStructuredText parseText "<t align='center'>Magazines Repacked.</t>";
				progressBarText ctrlCommit 0;

				uiSleep 5;
				
				
				progressBarBackground ctrlSetFade 1;
				progressBarBackground ctrlCommit 1;
				
				progressBarForeground ctrlSetFade 1;
				progressBarForeground ctrlCommit 1;

				progressBarText ctrlSetFade 1;
				progressBarText ctrlCommit 1;


				
				uiSleep 1;
				
				ctrlDelete progressBarBackground;
				ctrlDelete progressBarForeground;
				ctrlDelete progressBarText;
			};
		};

		MAZ_fnc_repackAnimation = {
			while {!MAZ_magRepackDone && vehicle player == player} do {
				player playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
				sleep 5;
			};
		};

		MAZ_fnc_climbDebugView = {
			if(isMultiplayer) exitWith {};
			MAZ_ClimbDebug = true;
			onEachFrame {
				if(!isNil "MAZ_Climb_aboveBottom" && !isNil "MAZ_Climb_aboveTop") then {
					drawLine3D [ASLtoAGL MAZ_Climb_aboveBottom,ASLtoAGL MAZ_Climb_aboveTop,[1,0,0,1]];
				};

				if(!isNil "MAZ_Climb_frontNear" && !isNil "MAZ_Climb_frontFar") then {
					drawLine3D [ASLtoAGL MAZ_Climb_frontNear,ASLtoAGL MAZ_Climb_frontFar,[0,1,0,1]];
				};

				if(!isNil "MAZ_Climb_topBottom" && !isNil "MAZ_Climb_topTop") then {
					drawLine3D [ASLtoAGL MAZ_Climb_topTop,ASLtoAGL MAZ_Climb_topBottom,[0,0,1,1]];
				};
			};
		};

		MAZ_fnc_climbOnObject = {
			"GetInHelicopterCargoRf1 Step Up Anim";
			"Check conditions";
			if !(
				(player == vehicle player) &&
				(isTouchingGround player) &&
				((stance player == "STAND") || (stance player == "CROUCH")) &&
				(getFatigue player + 0.20) < 1 &&
				!(missionNamespace getVariable ["MAZ_EP_isClimbing",false])
			) exitWith {false};

			"Debug object";
			if(isNil "MAZ_testObjectPosition" && !isMultiplayer) then {
				MAZ_testObjectPosition = "Sign_Arrow_Blue_F" createVehicle [0,0,0];
			};

			"Check for bushes and trees";
			private _object = cursorObject;
			private _strAr = (str _object) splitString " ";
			if(isNull _object || {(count _strAr > 1) && {((_strAr # 1) select [0,2]) in ["b_","t_"]}}) exitWith {
				if(!isMultiplayer) then {MAZ_testObjectPosition setPos [0,0,0];};
				false;
			};

			"Check if blocked above";
			private _posASL = getPosASL player;
			private _aboveIntersect = lineIntersectsSurfaces [(_posASL vectorAdd [0,0,0.5]), (_posASL vectorAdd [0,0,3.55]),player,objNull,true,1,"GEOM"];
			if(missionNamespace getVariable ["MAZ_ClimbDebug",false]) then {
				MAZ_Climb_aboveBottom = (_posASL vectorAdd [0,0,0.5]);
				MAZ_Climb_aboveTop = (_posASL vectorAdd [0,0,3.55]);
			};
			if(count _aboveIntersect != 0) exitWith {
				if(!isMultiplayer) then {
					systemChat "Object above player, can't climb";
				};
			};

			"Check object intersect in front of player";
			private _frontPos = if(currentWeapon player == "" || weaponLowered player) then {
				eyePos player vectorAdd (eyeDirection player vectorMultiply 5);
			} else {
				eyePos player vectorAdd ((player weaponDirection (currentWeapon player)) vectorMultiply 5);
			};
			private _intersects = lineIntersectsSurfaces [eyePos player, _frontPos, player,objNull,true,1,"GEOM"];
			if(missionNamespace getVariable ["MAZ_ClimbDebug",false]) then {
				MAZ_Climb_frontNear = eyePos player;
				MAZ_Climb_frontFar = _frontPos;
			};
			if(count _intersects == 0) exitWith {
				if(!isMultiplayer) then {systemChat "No intersect";};
				false;
			};
			private _intersect = _intersects # 0;
			_intersect params ["_interPosASL","_surfaceNormal","_interObj","_parentObj"];
			if(_object != _interObj) exitWith {
				if(!isMultiplayer) then {systemChat "Intersect wrong object"; systemChat format ["Object: %1. InterObj: %2",_object, _interObj]};
				false;
			};
			
			"Get position further into object than intersect position";
			private _dirToPlayer = _interPosASL getDir _posASL;
			private _climbPos = _interPosASL getPos [0.3,_dirToPlayer + 180];
			_climbPos set [2, ((_interPosASL # 2) + 1.5)];
			private _ground = +_interPosASL;
			_ground set [2,0];

			"Check top intersect for object for height";
			private _intersectTop = lineIntersectsSurfaces [_climbPos, _ground, player,objNull, true, 1, "GEOM"];
			if(missionNamespace getVariable ["MAZ_ClimbDebug",false]) then {
				MAZ_Climb_topBottom = _ground;
				MAZ_Climb_topTop = _climbPos;
			};
			if(count _intersectTop == 0) exitWith {
				if(!isMultiplayer) then {systemChat "Intersect top fail";};
				false;
			};
			private _topIntersect = _intersectTop # 0;
			_topIntersect params ["_topInterPosASL","_surfaceNormal","_topInterObj"];
			if(_topInterObj != _interObj) exitWith {
				if(!isMultiplayer) then {systemChat "Top intersect wrong object"; systemChat format ["Object: %1. Top: %2",_interObj,_topInterObj]};
				false;
			};
			if((_topInterPosASL distance _climbPos) < 0.02) exitWith {
				if(!isMultiplayer) then {
					systemChat "Top inside object";
					systemChat str (_topInterPosASL distance _climbPos);
				};
				false;
			};

			"Check distance to the intersect";
			private _dist2D = _posASL distance2D _topInterPosASL;
			if(_dist2D > 3) exitWith {
				if(!isMultiplayer) then {systemChat "Wanted position too far";};
				false;
			};

			"Check height limits";
			private _heightDiff = (_topInterPosASL # 2) - (_posASL # 2);
			if(!isMultiplayer) then {systemChat format ["HeightDiff: %1",_heightDiff];};
			if(_heightDiff < 0) exitWith {
				if(!isMultiplayer) then {systemChat "Wanted position is below player";};
				false;
			};
			if(_heightDiff < 1.5) exitWith {
				if(!isMultiplayer) then {systemChat "Object is too short";};
				false;
			};
			if(_heightDiff > 2.55) exitWith {
				if(!isMultiplayer) then {systemChat "Object too high";};
				false;
			};

			"Do climb";
			if(!isMultiplayer) then {MAZ_testObjectPosition setPosASL _topInterPosASL;};
			[_topInterPosASL,_object] spawn {
				params ["_climbPos","_climbObject"];
				[] call MAZ_fnc_disableMovement;
				MAZ_EP_isClimbing = true;
				if(currentWeapon player != "") then {
					player action ['SWITCHWEAPON',player,player,-1];
					sleep 2.4;
				} else {
					sleep 0.1;
				};
				[player,"GetInHemttBack"] remoteExec ["switchMove"];
				[] spawn {
					private _timeToStop = time + 3.6;
					while {time < _timeToStop} do {
						private _index = selectRandom [1,2,3,4,5];
						private _terrain = selectRandom ["dirt","gravel","sand"];
						private _sound = playSound3D [format ["a3\sounds_f\characters\crawl\%1_crawl_%2.wss",_terrain,_index],player,false, getPosASL player, 1,1,15];
						waitUntil { (soundParams _sound) isEqualTo [] };
						sleep (0.1 + random 0.2);
					};
				};
				sleep 3.6;
				call MAZ_fnc_enableMovement;
				player setPosASL _climbPos;
				if(primaryWeapon player != "") then {
					player action ["SwitchWeapon", player, player, 1];
				};
				player setFatigue (getFatigue player + 0.30);
				MAZ_EP_isClimbing = false;
			};
			true;
		};

		MAZ_fnc_doJump = {
			params ["_displayCode","_keyCode","_isShift","_isCtrl","_isAlt"];
			private _handled = false;
			if ((_keyCode in actionKeys "GetOver" && _isShift) && (animationState player != "AovrPercMrunSrasWrflDf")) then {
				private ["_height","_velocity","_direction","_speed"];
				if (
					(player == vehicle player) && 
					(isTouchingGround player) && 
					((stance player == "STAND") || (stance player == "CROUCH")) &&
					(getFatigue player + 0.10) < 1
				) exitWith {
					private _height = (3.20 - (load player));
					private _velocity = velocity player;
					private _direction = direction player;
					private _speed = 0.40;
					player setVelocity [(_velocity select 0) + (sin _direction * _speed), (_velocity select 1) + (cos _direction * _speed), ((_velocity select 2) * _speed) + _height];
					[player,"AovrPercMrunSrasWrflDf"] remoteExec ["switchMove"];
					[player,"AovrPercMrunSrasWrflDf"] remoteExec ["playMoveNow"];
					player setFatigue (getFatigue player + 0.10);
					_handled = true;
				};
			};
			_handled
		};

		MAZ_fnc_autoHALO = {
			if(((getPosATL player) select 2) >= MAZ_EP_autoHALOHeight && backpack player != "B_Parachute") then {
				if(backpack player != "") then {
					private _backPack = backpack player;
					private _backPackItems = backpackItems player;
					private _haloBackPack = "B_Parachute";
							
					systemChat "[Z.A.M.] - Since you jumped at a high altitude your backpack has been placed on your chest and you've been equipped with a parachute.";
					removeBackPack player;
					player addBackpack _haloBackPack;
					private _backpackHolder = "groundweaponholder" createVehicle getpos player;   
					_backpackHolder addBackpackCargoGlobal [_backPack,1];   
					_backpackHolder attachTo [player,[-0.3,0.72,-0.47],'RightShoulder',true];   
					_backpackHolder setVectorDirAndUp [[0,0,-1],[0,1,0]];
					waitUntil {(getPos player select 2) < 1};
					removeBackpack player;
					player addBackpack _backPack;
					{player addItemToBackpack _x} forEach _backPackItems;
					deleteVehicle _backpackHolder;
				} else {
					player addBackpack "B_Parachute";
					systemChat "[Z.A.M.] - You seriously jumped out without a parachute? I should've let you die but I'm too nice.";
				};
			};
		};

		MAZ_fnc_canDropSmoke = {
			if(lifeState player != "INCAPACITATED") exitWith {false};
			private _hasSmokeGrenade = false;
			{
				if(_x in MAZ_smokeGrenades) exitWith {
					_hasSmokeGrenade = true;
				};
			}forEach magazines player;
			_hasSmokeGrenade
		};

		MAZ_fnc_openSmokeGrenadeMenu = {
			if(call MAZ_fnc_canDropSmoke) then {
				[] spawn MAZ_dropSmokeActionMenu;
			};
		};

		MAZ_dropSmokeActionMenu = {
			disableSerialization;
			with uiNamespace do {
				if(!isNil "lbWhite") then {lbWhite = nil;};
				if(!isNil "lbRed") then {lbRed = nil;};
				if(!isNil "lbOrng") then {lbOrng = nil;};
				if(!isNil "lbYlw") then {lbYlw = nil;};
				if(!isNil "lbGrn") then {lbGrn = nil;};
				if(!isNil "lbBlu") then {lbBlu = nil;};
				if(!isNil "lbPrpl") then {lbPrpl = nil;};
				dropSmokeMenu = (findDisplay 46) createDisplay "RscDisplayEmpty";
				showChat true;
					
				comment "Backgrounds";

					frame1 = dropSmokeMenu ctrlCreate ["RscFrame", 1800];
					frame1 ctrlSetPosition [0.4175 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.175313 * safezoneW,0.352 * safezoneH];
					frame1 ctrlCommit 0;

					frame1BG = dropSmokeMenu ctrlCreate ["RscPicture", 1800];
					frame1BG ctrlSetPosition [0.4175 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.175313 * safezoneW,0.352 * safezoneH];
					frame1BG ctrlSetTextColor [0,0,0,0.65];
					frame1BG ctrlSetText "#(argb,8,8,3)color(1,1,1,1)";
					frame1BG ctrlCommit 0;

					frame2 = dropSmokeMenu ctrlCreate ["RscFrame", 1801];
					frame2 ctrlSetPosition [0.427812 * safezoneW + safezoneX,0.412 * safezoneH + safezoneY,0.154687 * safezoneW,0.187 * safezoneH];
					frame2 ctrlCommit 0;

				comment "Images";

					whiteSmokeImg = dropSmokeMenu ctrlCreate ["RscPicture",1200];
					whiteSmokeImg ctrlSetPosition [0.412344 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0515625 * safezoneW,0.088 * safezoneH];
					whiteSmokeImg ctrlSetText "\A3\weapons_f\data\ui\gear_smokegrenade_white_ca.paa";
					whiteSmokeImg ctrlCommit 0;

					redSmokeImg = dropSmokeMenu ctrlCreate ["RscPicture",1201];
					redSmokeImg ctrlSetPosition [0.479375 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0515625 * safezoneW,0.088 * safezoneH];
					redSmokeImg ctrlSetText "\A3\weapons_f\data\ui\gear_smokegrenade_red_ca.paa";
					redSmokeImg ctrlCommit 0;

					greenSmokeImg = dropSmokeMenu ctrlCreate ["RscPicture",1202];
					greenSmokeImg ctrlSetPosition [0.546406 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0515625 * safezoneW,0.088 * safezoneH];
					greenSmokeImg ctrlSetText "\A3\weapons_f\data\ui\gear_smokegrenade_green_ca.paa";
					greenSmokeImg ctrlCommit 0;

				comment "Button";

					deploySmokeButton = dropSmokeMenu ctrlCreate ["RscButtonMenu",2400];
					deploySmokeButton ctrlSetPosition [0.443281 * safezoneW + safezoneX,0.61 * safezoneH + safezoneY,0.12375 * safezoneW,0.044 * safezoneH];
					deploySmokeButton ctrlSetStructuredText parseText "<t size='1.02' align='center'>DEPLOY SMOKE GRENADE</t>";
					deploySmokeButton ctrlSetFont "PuristaSemiBold";
					deploySmokeButton ctrlSetBackgroundColor [0.6,0,0,0.75];
					deploySmokeButton ctrlSetTextColor [1,1,1,1];
					deploySmokeButton ctrlSetEventHandler ["ButtonClick","
						[] spawn MAZ_deploySmoke;
					"];
					deploySmokeButton ctrlCommit 0;

				comment "Listbox";

					smokeGrenadeList = dropSmokeMenu ctrlCreate ["RscListbox",1500];
					smokeGrenadeList ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.423 * safezoneH + safezoneY,0.144375 * safezoneW,0.165 * safezoneH];
					smokeGrenadeList ctrlCommit 0;
			};
			[] call MAZ_populateSmokeList;
		};

		MAZ_populateSmokeList = {
			private _listBox = uiNamespace getVariable ['smokeGrenadeList',displayNull];
			private _pMags = magazines player;
			{
				if(_x in MAZ_smokeGrenades) then {
					with uiNamespace do {
						switch (_x) do {
							case "SmokeShell": {
								if(isNil "lbWhite") then {
									lbWhite = _listBox lbAdd "Smoke Grenade (White)";
									_listBox lbSetData [lbWhite, ""];
								};
							};
							case "SmokeShellRed": {
								if(isNil "lbRed") then {
									lbRed = _listBox lbAdd "Smoke Grenade (Red)";
									_listBox lbSetData [lbRed, "Red"];
								};
							};
							case "SmokeShellOrange": {
								if(isNil "lbOrng") then {
									lbOrng = _listBox lbAdd "Smoke Grenade (Orange)";
									_listBox lbSetData [lbOrng, "Orange"];
								};
							};
							case "SmokeShellYellow": {
								if(isNil "lbYlw") then {
									lbYlw = _listBox lbAdd "Smoke Grenade (Yellow)";
									_listBox lbSetData [lbYlw, "Yellow"];
								};
							};
							case "SmokeShellGreen": {
								if(isNil "lbGrn") then {
									lbGrn = _listBox lbAdd "Smoke Grenade (Green)";
									_listBox lbSetData [lbGrn, "Green"];
								};
							};
							case "SmokeShellBlue": {
								if(isNil "lbBlu") then {
									lbBlu = _listBox lbAdd "Smoke Grenade (Blue)";
									_listBox lbSetData [lbBlu, "Blue"];
								};
							};	
							case "SmokeShellPurple": {
								if(isNil "lbPrpl") then {
									lbPrpl = _listBox lbAdd "Smoke Grenade (Purple)";
									_listBox lbSetData [lbPrpl, "Purple"];
								};
							};
						};
					};
				};
			} forEach _pMags;
		};

		MAZ_deploySmoke = {
			private _listBox = uiNamespace getVariable ['smokeGrenadeList',displayNull];
			private _smokeIndex = lbCurSel _listBox;
			private _smokeData = _listBox lbData _smokeIndex;
			MAZ_EP_smokeToDeploy = "SmokeShell" + _smokeData;
			uiNamespace getVariable ['dropSmokeMenu',displayNull] closeDisplay 0;
			["", "Aim and click LMB to throw the smoke grenade. Click RMB to cancel."] spawn BIS_fnc_showSubtitle;
			if(!isNil "MAZ_EP_DEH_MouseDown_deploySmoke") then {
				(findDisplay 46) displayRemoveEventHandler ["MouseButtonDown",MAZ_EP_DEH_MouseDown_deploySmoke];
			};
			MAZ_EP_DEH_MouseDown_deploySmoke = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {
				params ["_display","_button"];
				if(_button != 0) then {
					["", "Smoke deploy cancelled."] spawn BIS_fnc_showSubtitle;
				};
				if(lifeState player != "INCAPACITATED" || _button != 0) exitWith {
					if(!isNil "MAZ_EP_DEH_MouseDown_deploySmoke") then {
						(findDisplay 46) displayRemoveEventHandler ["MouseButtonDown",MAZ_EP_DEH_MouseDown_deploySmoke];
					};
				};
				private _viewDirVector = getCameraViewDirection player;
				private _normVector = vectorNormalized _viewDirVector;
				private _vel = _normVector vectorMultiply 8;
				player removeMagazine MAZ_EP_smokeToDeploy;
				private _smoke = MAZ_EP_smokeToDeploy createVehicle (position player);
				_smoke setPosATL (getPosATL player vectorAdd [0,0,0.1]);
				_smoke setVelocity _vel;
				if(!isNil "MAZ_EP_DEH_MouseDown_deploySmoke") then {
					(findDisplay 46) displayRemoveEventHandler ["MouseButtonDown",MAZ_EP_DEH_MouseDown_deploySmoke];
				};
			}];
		};

		MAZ_fnc_addKeybinds = {
			waitUntil {uisleep 0.1;!isNull (findDisplay 46) && alive player};
			sleep 0.1;
			waitUntil {!isNil "MAZ_fnc_newKeybind"};
			call MAZ_fnc_assignSavedViewDistance;
			if(!isNil "MAZ_DEH_KeyDown_Earplugs") then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_DEH_KeyDown_Earplugs];
			};
			if(!isNil "earplugsBind_Comp_MAZ") then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown",earplugsBind_Comp_MAZ];
				[[],{}] remoteExec ['spawn',0,'MAZ_testEarplugs'];
			};
			MAZ_Key_Earplugs = ["Toggle Earplugs","Toggle your earplugs.",207,{call MAZ_fnc_earplugsLite;},false,false,false,false,false,"MAZ_Earplugs"] call MAZ_fnc_newKeybind;
			MAZ_Key_Holster = ["Holster Weapon","Holster your weapon.",35,{[] spawn MAZ_fnc_holsterWeapon;},false,false,false,false,false,"MAZ_Holster"] call MAZ_fnc_newKeybind;
			MAZ_Key_ViewDist = ["Edit View Distance","Edit your view distance (Local).",73,{[] spawn MAZ_fnc_newViewDistanceMenu;},false,false,false,true,false,"MAZ_ViewDistance"] call MAZ_fnc_newKeybind;
			MAZ_Key_Unflip = ["Unflip Vehicle","Unflip the vehicle you look at.",12,{[] spawn MAZ_liteUnflip;},false,true,false,false,false,"MAZ_Unflip"] call MAZ_fnc_newKeybind;
			MAZ_Key_SitDown = ["Sit Down","Sit down in the chair.",57,{[] spawn MAZ_fnc_sitDown;},false,false,false,false,false,"MAZ_Sit"] call MAZ_fnc_newKeybind;
			MAZ_Key_DeploySmoke = ["Deploy Smokes","Use smoke while injured.",57,{[] spawn MAZ_fnc_openSmokeGrenadeMenu;},false,false,false,false,false,"MAZ_UseSmoke"] call MAZ_fnc_newKeybind;

			if(!isNil "MAZ_DEH_KeyDown_Jump") then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_DEH_KeyDown_Jump];
			};
			MAZ_jumpKeyBind = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call MAZ_fnc_doJump;"];
			MAZ_Key_Climb = ["Climb Object","Climb onto objects.",57,{call MAZ_fnc_climbOnObject;},true,false,false,true,false,"MAZ_Climb"] call MAZ_fnc_newKeybind;

			if(!isNil "MAZ_EH_InventoryOpened_LockBackpacks") then {
				player removeEventHandler ["InventoryOpened",MAZ_EH_InventoryOpened_LockBackpacks];
			};
			MAZ_EH_InventoryOpened_LockBackpacks = player addEventHandler ["InventoryOpened",{
				params ["_unit","_container"];
				private _override = false;
				private _allUnitBackpackContainers = [];
				{
					if(alive _x && (group _x != group player)) then {
						_allUnitBackPackContainers pushBack (backpackContainer _x);
					};
				} forEach allPlayers;

				if (_container in _allUnitBackpackContainers) then {
					systemChat "[Z.A.M.] - Unit's backpack is locked since they're not in your group";
					_override = true;
				};
				[] spawn MAZ_fnc_repackButton;
				_override
			}];

			if(!isNil "MAZ_EH_GetOutMan_General") then {
				player removeEventHandler ["GetOutMan",MAZ_EH_GetOutMan_General];
			};
			MAZ_EH_GetOutMan_General = player addEventHandler ["GetOutMan", {
				[] spawn MAZ_fnc_setViewDistance;
				[] spawn MAZ_fnc_autoHALO;
			}];
			if(!isNil "MAZ_EH_GetInMan_General") then {
				player removeEventHandler ["GetOutMan",MAZ_EH_GetInMan_General];
			};
			MAZ_EH_GetInMan_General = player addEventHandler ["GetInMan", {
				[] spawn MAZ_fnc_setViewDistance;
			}];

			if(!isNil "MAZ_EH_FiredMan_ImproveWeapons") then {
				player removeEventHandler ["FiredMan",MAZ_EH_FiredMan_ImproveWeapons];
			};
			MAZ_EH_FiredMan_ImproveWeapons = player addEventHandler ["FiredMan", {
				params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
				if("40mm_Smoke" in _ammo) then {
					[_projectile,_ammo] spawn {
						params ["_round","_ammo"];
						waitUntil {(getPosATL _round) # 2 < 0.25};
						private _pos = getPosATL _round;
						private _vecDirAndUp = [vectorDir _round, vectorUp _round];
						deleteVehicle _round;
						private _index = _ammo find "Smoke";
						private _color = _ammo select [(_index + 5)];
						private _smoke = ("SmokeShell" + _color) createVehicle [0,0,0];
						_pos set [2,0];
						_smoke setPosATL _pos;
						[_smoke,true] remoteExec ['hideObject'];
						private _slug = createSimpleObject ["\A3\weapons_f\Ammo\UGL_slug", [0,0,0]];
						_slug setPosATL _pos;
						_slug setVectorDirAndUp _vecDirAndUp;
						sleep 60;
						deleteVehicle _slug;
					};
				};
				if(_ammo == "M_NLAW_AT_F") then {
					private _missileTwo = "R_MRAAWS_HEAT_F" createVehicle [0,0,50];
					_missileTwo attachTo [_projectile,[0,-0.1,0]];
				};
			}];
			
			if((player getVariable ["LM_MEH_playerNames",-1]) != -1) then {
				removeMissionEventHandler ['Draw3D', (player getVariable ['LM_MEH_playerNames',-1])];
			};
			if((player getVariable ["LM_MEH_killFeed",-1]) != -1) then {
				removeMissionEventHandler ['EntityKilled', (player getVariable ['LM_MEH_killFeed',-1])];
			};  

			waitUntil {!isNull (findDisplay 12)};
			if(!isNil "MAZ_DEH_PreventDeleteMarkers") then {
				(findDisplay 12) displayRemoveEventHandler ["KeyDown",MAZ_DEH_PreventDeleteMarkers];
			};
			MAZ_DEH_PreventDeleteMarkers = (findDisplay 12) displayAddEventHandler ["KeyDown", {
				params ["","_key"];
				if(_key != 211) exitWith {}; comment "Don't override anything but the delete key";
				private _pos = (findDisplay 12 displayCtrl 51) ctrlMapScreenToWorld getMousePosition;
				private _marker = [allMapMarkers,[],{_pos distanceSqr (getMarkerPos _x)},"ASCEND"] call BIS_fnc_sortBy;
				_marker = _marker select 0;
				private _dist = (getMarkerPos _marker) distance2D _pos;
				if(_dist > 150) exitWith {}; comment "Not deleting a marker";
				private _str = format ["%1_Owner",_marker];
				private _id = getPlayerUID player;
				private _markerOwner = missionNamespace getVariable [_str,""];
				if((allPlayers findIf {getPlayerUID _x == _markerOwner}) == -1) exitWith {}; comment "Not in server";
				if(_id == _markerOwner || (call BIS_fnc_admin) != 0) exitWith {}; comment "If you are the marker owner or admin";
				comment "Otherwise prevent marker deletion";
				true
			}];

			if(!isNil "MAZ_EH_WepAssembled_AutoTurrets") then {
				player removeEventHandler ["WeaponAssembled",MAZ_EH_WepAssembled_AutoTurrets];
			};
			MAZ_EH_WepAssembled_AutoTurrets = player addEventHandler ["WeaponAssembled", {
				params ["_unit", "_staticWeapon", "_primaryBag", "_secondaryBag"];
				if(_staticWeapon isKindOf "StaticWeapon" || _staticWeapon isKindOf "UGV_02_Base_F") then {
					{
						private _unit = _x;
						{
							_unit disableAI _x;
						}forEach ["ANIM","AUTOTARGET","CHECKVISIBLE","FSM","MOVE","PATH","TARGET","WEAPONAIM"]
					}forEach (crew _staticWeapon);
				};
			}];

			if(!isNil "MAZ_EH_WeaponChanged_WeaponSounds") then {
				player removeEventHandler ["WeaponChanged",MAZ_EH_WeaponChanged_WeaponSounds];
			};
			MAZ_EH_WeaponChanged_WeaponSounds = player addEventHandler ["WeaponChanged", {
				params ["_object", "_oldWeapon", "_newWeapon", "_oldMode", "_newMode", "_oldMuzzle", "_newMuzzle", "_turretIndex"];
				if(_oldWeapon == "") then {
					playSound3D ["a3\sounds_f\characters\stances\rifle_to_handgun.wss", player, false, getPosASL player, 5, 1, 7.5];
				};
			}];
		};

		MAZ_fnc_initDefaultAddonServer = {
			MAZ_MEH_MarkerCreated_PreventDeleteMarkers = addMissionEventHandler ["MarkerCreated", {
				params ["_marker", "_channelNumber", "_owner", "_local"];
				private _id = getPlayerUID _owner;
				private _str = format ["%1_Owner",_marker];
				missionNamespace setVariable [_str,_id,true];
			}];
		};

		MAZ_fnc_globalLaserMarkers = {
			private _markerName = format ["LaserMarker_%1",getPlayerUID player];
			private _laserDesignators = ["Laserdesignator","Laserdesignator_01_khk_F","Laserdesignator_02","Laserdesignator_02_ghex_F","Laserdesignator_03"];
			while {MAZ_globalLaserMarkers} do {
				if(isNil "MAZ_LaserMarker") then {
					MAZ_LaserMarker = createMarker [_markerName,[0,0,0]];
				};
				if(currentWeapon player in _laserDesignators && isLaserOn player) then {
					private _target = laserTarget player;
					private _pos = getPos _target;
					MAZ_LaserMarker setMarkerType "mil_destroy";
					MAZ_LaserMarker setMarkerColor "ColorRed";
					MAZ_LaserMarker setMarkerPos _pos;
				} else {
					MAZ_LaserMarker setMarkerType "EmptyIcon";
				};

				sleep 5;
			};
		};

		MAZ_fnc_hasWetsuit = {
			(uniform player) in ["U_B_Wetsuit","U_O_Wetsuit","U_I_Wetsuit","U_B_survival_uniform"];
		};

		MAZ_fnc_removeTrollBackpacks = {
			if(time < (missionNamespace getVariable ["MAZ_EP_trollBagsLoopTime",time])) exitWith {};
			comment "Prevent pistol whippers";
			if(!(missionNamespace getVariable ["MAZ_BetterSprint",false])) then {
				private _animSpeed = getAnimSpeedCoef player;
				if(currentWeapon player == handgunWeapon player && weaponLowered player && stance player == "CROUCH" && _animSpeed > 0.8) then {
					player setAnimSpeedCoef 0.8;
				} else {
					if(_animSpeed < 1) then {
						player setAnimSpeedCoef 1;
					};
				};
				if(((getPosASL player) # 2) < -1.9 && !(call MAZ_fnc_hasWetsuit)) then {
					if(_animSpeed < 1.75) then {
						player setAnimSpeedCoef 1.75;
					};
				} else {
					if(_animSpeed > 1) then {
						player setAnimSpeedCoef 1;
					};
				};
			};

			comment "Prevent respawn bags and turrets";
			if(missionNamespace getVariable ["MAZ_EP_DisableRespawnTents",false]) then {
				private _bp = backpack player;
				if("respawn" in (toLower _bp)) then {
					removeBackpackGlobal player;
					continue;
				};
			};
			missionNamespace setVariable ["MAZ_EP_trollBagsLoopTime",time + 0.1];
		};

		MAZ_EP_fnc_createBaseDiary = {
			MAZ_EP_DiarySubject = player createDiarySubject ["MAZ_EP_DiarySubject","Enhancement Pack"];
		};

		MAZ_EP_fnc_addDiaryRecord = {
			params ["_displayName","_description",["_featureList",[]]];
			waitUntil {!isNil "MAZ_EP_DiarySubject"};
			if(count _featureList == 0) then {
				player createDiaryRecord ["MAZ_EP_DiarySubject",[format ["[EP] : %1",_displayName],format ["<font color='#db8727' size='18' face='PuristaBold'>%1</font><br/><font size='14' face='PuristaMedium'>%2</font>",_displayName,_description]]];
			} else {
				private _textWithFeatures = format ["<font color='#db8727' size='18' face='PuristaBold'>%1</font><br/><font size='14' face='PuristaMedium'>%2</font><br/><br/><font size='16' face='PuristaSemibold'>Features:</font><font size='14' face='PuristaMedium'>",_displayName,_description];
				{
					_textWithFeatures = _textWithFeatures + (format ["<br/> • %1",_x]);
				}forEach _featureList;
				_textWithFeatures = _textWithFeatures + "</font>";
				player createDiaryRecord ["MAZ_EP_DiarySubject",[format ["[EP] : %1",_displayName],_textWithFeatures]];
			};
		};

		MAZ_EP_fnc_systemMessage = {
			params ["_text",["_sound",""]];
			systemChat format ["[ EP ] : %1",_text];
			if(_sound != "") then {
				playSound _sound;
			};
		};

		MAZ_EP_QueueObject = [
			["#flags", ["sealed"]],
			["#create", {
				_this params [["_forever",false]];
				[_self,_forever] spawn {
					params ["_self","_forever"];
					private _queueStarted = false;
					private _stopQueue = false;
					while{(_self get "active") && (!_stopQueue || _forever)} do {
						if(count (_self get "queue") == 0 && _stopQueue) then {
							sleep 0.1;
							continue;
						};
						if(count (_self get "queue") > 0) then {
							_queueStarted = true;
							_stopQueue = false;
							private _queue = _self get "queue";
							(_queue # 0) params ["_parameters", "_function"];
							_parameters call _function;
							_queue deleteAt 0;
							_self set ["queue",_queue];
						} else {
							if(_queueStarted && !_stopQueue) then {
								_stopQueue = true;
							};
						};
					};
				};
			}],
			["#delete", {}],
			["#str",{"A queue object"}],
			["active",true],
			["queue",[]],
			["addToQueue",{
				private _queue = _self get "queue";
				_queue pushBack _this;
				_self set ["queue",_queue];
			}]
		];

		MAZ_EP_NotificationQueue = createHashMapObject [MAZ_EP_QueueObject,[true]];

		MAZ_EP_fnc_addToExecQueue = {
			params ["_parameters","_function"];
			if(isNil "MAZ_EP_ExecQueueStarted") then {
				MAZ_EP_ExecQueueStarted = false;
			};
			if(isNil "MAZ_EP_ExecQueue") then {
				MAZ_EP_ExecQueue = [];
			};
			
			MAZ_EP_ExecQueue pushBack [_parameters,_function];
			if(!MAZ_EP_ExecQueueStarted) then {
				MAZ_EP_ExecQueueStarted = true;
				[] spawn MAZ_EP_fnc_startExecQueue;
			};
		};

		MAZ_EP_fnc_startExecQueue = {
			while {count MAZ_EP_ExecQueue > 0} do {
				(MAZ_EP_ExecQueue select 0) params ["_parameters","_function"];
				_parameters call _function;
				MAZ_EP_ExecQueue deleteAt 0;
			};
			MAZ_EP_ExecQueueStarted = false;
		};

		MAZ_EP_fnc_createNotification = {
			params [["_text",""],["_title","System Notification"],["_duration",5],["_sound",""],["_image","a3\modules_f_curator\data\portraitradiochannelcreate_ca.paa"]];
			if(_text == "") exitWith {};
			private _activeNotifications = missionNamespace getVariable ["MAZ_EP_notifications",[]];

			if(count _activeNotifications > 3) exitWith {
				MAZ_EP_NotificationQueue call ["addToQueue",[_text,_title,_duration,_sound,_image],{
					sleep 0.1;
					_this spawn MAZ_EP_fnc_createNotification;
				}];
			};
			getResolution params ["","","","","","_uiScale"];
			private _scaleUI = switch (_uiScale) do {
				case 0.47: {
					0.8545454545454545;
				};
				case 0.55: {
					1;
				};
				case 0.7: {
					1.27273;
				};
				case 0.85: {
					1.545454545454545;
				};
				case 1: {
					2;
				};
			};
			private _posY = ((0.159*_scaleUI) * safezoneH + safezoneY);
			{
				(ctrlPosition _x) params ["","","","_posH"];
				_posY = _posY + _posH + 0.025;
			}forEach _activeNotifications;

			if(_sound != "") then {
				playSound _sound;
			};

			with uiNamespace do {
				private _display = findDisplay 46;
				if(!isNull (findDisplay 312)) then {
					_display = findDisplay 312;
				};

				private _contentGroup = _display ctrlCreate ["RscControlsGroupNoScrollbars",3010];
				_contentGroup ctrlSetPosition [-1.3,_posY,0.3625,0];
				_contentGroup ctrlCommit 0;

				private _bg = _display ctrlCreate ["RscPicture",3020,_contentGroup];
				_bg ctrlSetPosition [0,0,(0.149531*_scaleUI) * safezoneW,0];
				_bg ctrlSetText "#(argb,8,8,3)color(0,0,0,0.7)";
				_bg ctrlCommit 0;

				private _label = _display ctrlCreate ["RscText",3030,_contentGroup];
				_label ctrlSetPosition [0,0,(0.149531*_scaleUI) * safezoneW,(0.022*_scaleUI) * safezoneH];
				_label ctrlSetTextColor (["GUI", "TITLETEXT_RGB"] call BIS_fnc_displayColorGet);
				_label ctrlSetBackgroundColor (["GUI", "BCG_RGB"] call BIS_fnc_displayColorGet);
				_label ctrlSetText _title;
				_label ctrlCommit 0;

				private _picture = _display ctrlCreate ["RscPicture",3040,_contentGroup];
				_picture ctrlSetPosition [0.3375,0.005,(0.00825*_scaleUI) * safezoneW,(0.0165*_scaleUI) * safezoneH];
				_picture ctrlSetText _image;
				_picture ctrlCommit 0;

				private _textCtrl = _display ctrlCreate ["RscStructuredText",3050,_contentGroup];
				_textCtrl ctrlSetStructuredText parseText _text;
				_textCtrl ctrlSetPosition [0,0.05,0.149531 * safezoneW,0.143 * safezoneH];
				_textCtrl ctrlSetTextColor (["GUI", "TITLETEXT_RGB"] call BIS_fnc_displayColorGet);
				_textCtrl ctrlSetBackgroundColor [0,0,0,0];
				private _height = ((ceil ((count _text) / 40))) * (ctrlFontHeight _textCtrl);
				_textCtrl ctrlSetPosition [0,0.05,(0.149531*_scaleUI) * safezoneW,_height];
				_textCtrl ctrlCommit 0;
				_height = _height + 0.065;

				_contentGroup ctrlSetPositionH _height;
				_contentGroup ctrlCommit 0;
				_bg ctrlSetPositionH _height;
				_bg ctrlCommit 0;
				_contentGroup ctrlSetPosition [0.0101562 * safezoneW + safezoneX,_posY,(0.149531*_scaleUI) * safezoneW,_height];
				_contentGroup ctrlCommit 0.5;

				private _activeNotifications = missionNamespace getVariable ["MAZ_EP_notifications",[]];
				_activeNotifications pushBack _contentGroup;
				missionNamespace setVariable ["MAZ_EP_notifications",_activeNotifications];

				private _fnc = missionNamespace getVariable "MAZ_EP_fnc_removeNotification";
				sleep _duration;
				[_contentGroup] spawn _fnc;
			};
		};

		MAZ_EP_fnc_removeNotification = {
			params ["_contentGroup"];
			(ctrlPosition _contentGroup) params ["_posX","","","_posH"];
			_contentGroup ctrlSetPositionX (_posX - 1);
			_contentGroup ctrlCommit 0.5;

			private _activeNotifications = missionNamespace getVariable ["MAZ_EP_notifications",[]];
			private _index = _activeNotifications find _contentGroup;
			_activeNotifications deleteAt _index;
			missionNamespace setVariable ["MAZ_EP_notifications",_activeNotifications];
		};

		MAZ_EP_fnc_updateNotificationHeight = {
			private _activeNotifications = missionNamespace getVariable ["MAZ_EP_notifications",[]];
			private _posY = -0.12;
			{
				comment "This fixes jittering, but makes them move around more unpredictably. Not sure what is worse.";
				comment "if !(ctrlCommitted _x) then {continue;}";
				(ctrlPosition _x) params ["","_xPosY","","_posH"];
				if(_xPosY != _posY) then {
					_x ctrlSetPositionY _posY;
					_x ctrlCommit 0.3;
				};
				_posY = _posY + _posH + 0.025;
			}forEach _activeNotifications;
		};

		MAZ_EP_fnc_event_onNotificationCountChanged = {
			private _oldCount = count (missionNamespace getVariable ["MAZ_EP_notifications",[]]);
			MAZ_EP_notificationSystem = true;
			while {MAZ_EP_notificationSystem} do {
				private _notifications = missionNamespace getVariable ["MAZ_EP_notifications",[]];
				if(count _notifications != _oldCount) then {
					call MAZ_EP_fnc_updateNotificationHeight;
				};
				uiSleep 0.1;
			};
		};

		MAZ_EP_fnc_addCamoFacesToArsenal = {
			if(!isNil "MAZ_SEH_arsenalOpened_CamoFaces") then {
				[missionNamespace,"arsenalOpened",MAZ_SEH_arsenalOpened_CamoFaces] call BIS_fnc_removeScriptedEventHandler;
			};
			MAZ_SEH_arsenalOpened_CamoFaces = [missionNamespace, "arsenalOpened", {
				params ["_display","_togglespace"];

				with uiNamespace do {
					private _face = 15;
					private _ctrlList = _display displayCtrl (960 + 15);
					{
						_x params ["_faceType","_number"];
						for "_i" from 1 to _number do {
							private _strI = if(_i < 10) then {"0" + (str _i)} else {str _i};
							private _camoFaceClass = format ["CamoHead_%1_%2_F",_faceType,_strI];
							private _normalHead = if(_faceType in ["Persian","Greek","Asian"]) then {
								format ["%1Head_A3_%2",_faceType,_strI];
							} else {
								format ["%1Head_%2",_faceType,_strI];
							};
							private _displayName = getText (configfile >> "CfgFaces" >> "Man_A3" >> _normalHead >> "DisplayName");
							_displayName = _displayName + " (Camo)";
							
							private _lbAdd = _ctrlList lbAdd _displayName;
							_ctrlList lbSetdata [_lbAdd, _camoFaceClass];
							_ctrlList lbSetTooltip [_lbAdd, format ["%1\n%2",_displayName,_camoFaceClass]];
						};
					}forEach [
						["White",21],
						["Greek",9],
						["Asian",3],
						["Persian",3],
						["African",3]
					];
					private _ctrlSort = _display displayctrl (800 + 15);
					private _sortValues = uinamespace getvariable ["bis_fnc_arsenal_sort",[]];
					["lbSort",[[_ctrlSort,_sortValues param [15,0]],15]] call bis_fnc_arsenal;
				};
			}] call BIS_fnc_addScriptedEventHandler;
		};

		comment "User Actions System";
			if(false) then {
				MAZ_EP_fnc_addUserAction = {
					params [
						["_actionText","User Action",[""]],
						["_actionCondition",{true},[{}]],
						["_actionCode",{},[{}]],
						["_icon","a3\ui_f\data\map\markers\military\dot_ca.paa",[""]],
						["_childrenActions",[],[[]]],
						["_position","",[""]]
					];

					if(isNil "MAZ_EP_userActions") then {
						MAZ_EP_userActions = [];
					};
					MAZ_EP_userActions pushBack [_actionText,_actionCondition,_actionCode,_icon,_childrenActions,_position];
				};

				MAZ_EP_fnc_addUserActionChild = {
					params [
						["_userActionId",-1,[1,[]]],
						["_actionText","User Action",[""]],
						["_actionCondition",{true},[{}]],
						["_actionCode",{},[{}]],
						["_icon","a3\ui_f\data\map\markers\military\dot_ca.paa",[""]],
						["_childrenActions",[],[[]]],
						["_position","",[""]]
					];
					if(isNil "MAZ_EP_userActions") exitWith {};
					if(_userAction isEqualType -1 && {_userActionId == -1}) exitWith {};

					private _parentAction = [];
					if(_userActionId isEqualType []) then {
						_parentAction = +MAZ_EP_userActions;
						{
							if(_forEachIndex == 0) then {
								_parentAction = _parentAction select _x;
								continue;
							};

							_parentAction = _parentAction select 4 select _x;
						}forEach _userActionId;

					} else {
						_parentAction = MAZ_EP_userActions select _userActionId;
					};

					_parentAction params ["_pActionText","_pActionCondition","_pActionCode","_pIcon","_pChildrenActions","_pPosition"];

					private _newChildren = _pChildrenActions + [[_actionText,_actionCondition,_actionCode,_icon,_childrenActions,_position]];
					_parentAction set [4, _newChildren];

					if(_userActionId isEqualType []) then {
						private _tempParent = +MAZ_EP_userActions;
						private _tempOld = [];
						
						{
							if(_forEachIndex == 0) then {
								_tempOld pushBack (_tempParent select _x);
								continue;
							};
							private _temp = (_tempOld select (_forEachIndex - 1)) select 4 select _x;
							
							_tempOld pushBack _temp;
						}forEach _userActionId;

						_tempOld pushBack [_actionText,_actionCondition,_actionCode,_icon,_childrenActions,_position];

						{
							if (_forEachIndex == (count _tempOld - 1)) then {continue};
							private _action = _x;
							private _actions = _action select 4;

							_actions set [(_userActionId select _forEachIndex), (_tempOld select (_forEachIndex + 1))];
							_action set [4, _actions];
							_tempOld set [_forEachIndex, _action];
						}forEachReversed _tempOld; 

						MAZ_EP_userActions set [(_userActionId select 0), _tempOld select 0];
					} else {
						MAZ_EP_userActions set [_userActionId,_parentAction];
					};
				};

				MAZ_EP_fnc_createUserActions = {
					MAZ_EP_userActionsShown = true;
					MAZ_EP_userActionPlayerPos = getPos player;
					if(isNil "MAZ_EP_userActionsDrawn") then {
						MAZ_EP_userActionsDrawn = [];
					};

					private _actionsToDraw = [];
					{
						_x params ["_text","_condition","_actionCode","_icon","_childrenActions","_position"];
						if !(call _condition) then {continue};

						_actionsToDraw pushBack _forEachIndex;
					}forEach MAZ_EP_userActions;

					private _actionCount = count _actionsToDraw;

					if(_actionCount == 0) exitWith {
						MAZ_EP_userActionsDrawn pushBack [-1,positionCameraToWorld [0, 0, 2]];
					};

					private _radius = 0.15;
					private _intervals = 360 / _actionCount;
					private _origin = positionCameraToWorld [0, 0, 2];
					{
						private _action = MAZ_EP_userActions select _x;

						private _circumferencePos = _forEachIndex * _intervals;
				
						private _xPos2D = 0.5 + _radius * cos(_circumferencePos);
						private _yPos2D = 0.5 + _radius * sin(_circumferencePos);
						private _pos = screenToWorld [_xPos2D, _yPos2D];

						private _alignRight = true;
						if(false) then {
							_alignRight = false;
						};

						MAZ_EP_userActionsDrawn pushBack [_x,_pos,_alignRight];
					}forEach _actionsToDraw;
				};

				MAZ_EP_fnc_destroyUserActions = {
					MAZ_EP_userActionsDrawn = [];
					if(!isNil "MAZ_EP_selectedUserAction") then {
						private _action = MAZ_EP_userActions select MAZ_EP_selectedUserAction;
						_action params ["_text","_condition","_actionCode","_icon","_childrenActions","_position"];
						call _actionCode;
						MAZ_EP_selectedUserAction = nil;
					};
				};

				MAZ_EP_fnc_showUserActions = {
					params [["_mode","self",[""]]];

					if((getPos player distance MAZ_EP_userActionPlayerPos) > 0.3) exitWith {};

					switch (_mode) do {
						case "self": {

						};
						case "external": {

						};
					};
					comment "private _cursorPos = positionCameraToWorld [0, 0, 2]";
					private _cursorPos = screenToWorld [0.5,0.5];

					private _centerDot = drawIcon3D ["a3\ui_f\data\igui\cfg\cursors\selectover_ca.paa",[0.8,0,0,1], _cursorPos, 1,1, 0];
					if(isNil "MAZ_EP_userActionsDrawn") then {
						MAZ_EP_userActionsDrawn = [];
					};

					if(count MAZ_EP_userActionsDrawn == 1 && {(MAZ_EP_userActionsDrawn select 0 select 0) == -1}) exitWith {
						private _pos = MAZ_EP_userActionsDrawn select 0 select 1;
						private _noActions = drawIcon3D [
							"a3\ui_f\data\map\markers\military\dot_ca.paa",
							[1,1,1,1], 
							_pos, 
							1, 
							1, 
							0, 
							"No Actions", 
							2, 
							0.035, 
							"PuristaMedium", 
							"right", 
							false, 
							0, 
							-0.025
						];
					};

					private _closestAction = -1;
					private _closestDrawPos = [];
					private _closestValue = -1;
					{
						_x params ["_actionIndex","_drawPos","_alignRight"];

						systemChat (str _x);
						private _action = MAZ_EP_userActions select _actionIndex;
						_action params ["_text","_condition","_actionCode","_icon","_childrenActions","_position"];

						if(_alignRight) then {
							private _icon = drawIcon3D [_icon,[1,1,1,1], _drawPos, 1, 1, 0, _text, 2, 0.035, "PuristaMedium", "right", false, 0, -0.025];
						} else {
							private _icon = drawIcon3D [_icon,[1,1,1,1], _drawPos, 1, 1, 0, _text, 2, 0.035, "PuristaMedium", "left", false, 0, -0.025];
						};

						private _distanceToCursor = [0.5,0.5] distance2D (worldToScreen _drawPos);
						if(_distanceToCursor < 0.1 && (_distanceToCursor < _closestValue || _closestValue == -1)) then {
							systemChat "Closest";
							_closestAction = _actionIndex;
							_closestDrawPos = _drawPos;
							_closestValue = _distanceToCursor;
						};
					}forEach MAZ_EP_userActionsDrawn;

					if(_closestAction != -1) then {
						private _selectedIcon = drawIcon3D ["a3\ui_f\data\map\groupicons\selector_selected_ca.paa",[0.8,0,0,0.8], _closestDrawPos, 1, 1, 0];
						MAZ_EP_selectedUserAction = _closestAction;
					} else {
						MAZ_EP_selectedUserAction = nil;
					};
				};
				if(!isNil "MAZ_EP_MEH_Draw3D_UserAction") then {
					removeMissionEventHandler ["Draw3D", MAZ_EP_MEH_Draw3D_UserAction];
				};
				MAZ_EP_MEH_Draw3D_UserAction = addMissionEventHandler ["Draw3D", {
					if(missionNamespace getVariable ["MAZ_EP_userActionsShown",false]) then {
						["self"] call MAZ_EP_fnc_showUserActions;
					};
				}];

				if(!isNil "MAZ_EP_DEH_KeyDown_UserAction") then {
					(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_EP_DEH_KeyDown_UserAction];
				};
				MAZ_EP_DEH_KeyDown_UserAction = (findDisplay 46) displayAddEventHandler ["KeyDown",{
					params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];
					if(_key != 	219 || MAZ_EP_userActionsShown) exitWith {};
					if(!MAZ_EP_userActionsShown) then {
						call MAZ_EP_fnc_createUserActions;
					};
				}];

				if(!isNil "MAZ_EP_DEH_KeyUp_UserAction") then {
					(findDisplay 46) displayRemoveEventHandler ["KeyUp",MAZ_EP_DEH_KeyUp_UserAction];
				};
				MAZ_EP_DEH_KeyUp_UserAction = (findDisplay 46) displayAddEventHandler ["KeyUp",{
					params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];
					if(_key != 	219) exitWith {};
					MAZ_EP_userActionsShown = false;
					call MAZ_EP_fnc_destroyUserActions;
				}];
			};

		comment "Stackable inGameUISetEventHandler System";
			MAZ_EP_StackedUIEHs = [];

			MAZ_EP_fnc_callInGameUIEHs = {
				private _result = false;
				{
					private _resultTemp = false;
					if(typeName _x == typeName "") then {
						private _fnc = missionNamespace getVariable [_x,{}];
						_resultTemp = _this call _fnc;
					};
					if(typeName _x == typeName {}) then {
						_resultTemp = _this call _x;	
					};
					if(_resultTemp) exitWith {_result = true};
				}forEach MAZ_EP_StackedUIEHs;
				_result;
			};

			MAZ_EP_fnc_addInGameUIEH = {
				params [["_function",{},["",{}]]];
				MAZ_EP_StackedUIEHs pushBack _function;
			};

			'inGameUISetEventHandler ["Action",MAZ_EP_fnc_callInGameUIEHs]';

		comment "Settings System";

			MAZ_EP_fnc_addNewSetting = {
				params ["_displayName","_description","_variableName","_value",["_type","TOGGLE"],["_params",[],[[]]],["_settingsGroup","",[""]]];
				if(isNil "_displayName" || isNil "_description" || isNil "_variableName" || isNil "_value") exitWith {false};
				_type = toUpper _type;
				if !(_type in ["TOGGLE","SLIDER"]) exitWith {false};
				if (!isServer) exitWith {
					private _savedVar = [_variableName,_value] call MAZ_EP_fnc_getSavedSettingFromProfile;
					if((_this select 4) == "SLIDER") then {
						(_this select 5) params ["_min","_max"];
						private _temp = _savedVar;
						_savedVar = [_savedVar,_min,_max] call BIS_fnc_clamp;
						if(_savedVar != _temp) then {
							systemChat (format ["[ Settings Alert ] : Your setting %1 was outside of the allowed bounds.",_this select 0]);
						};
					};
					_this set [3,_savedVar];
					[_this,{
						waitUntil {!isNil "MAZ_EP_QueueObject"};
						if(isNil "MAZ_EP_SettingsQueue") then {
							MAZ_EP_SettingsQueue = createHashMapObject [MAZ_EP_QueueObject,[true]];
						};
						waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
						MAZ_EP_NotificationQueue call ["addToQueue",[_this,MAZ_EP_fnc_addNewSetting]];
					}] remoteExec ['spawn',2];
					"Ran on server";
				};
				if(isNil "MAZ_EP_Settings") then {
					MAZ_EP_Settings = [];
				};
				missionNamespace setVariable [_variableName,_value,true];
				MAZ_EP_Settings pushBack [_displayName,_description,_variableName,_value,_type,_params,_settingsGroup];
				MAZ_EP_Settings = [MAZ_EP_Settings,[],{
					_x params ["","","","","","",["_settingsGroup",""]];
					_settingsGroup;
				}] call BIS_fnc_sortBy;
				publicVariable "MAZ_EP_Settings";
				true;
			};

			MAZ_EP_fnc_getSettingsFromSettingsGroup = {
				params ["_settingsGroup"];
				private _settings = [];
				{
					private _group = _x select 6;
					if(toLower _settingsGroup == toLower _group) then {
						_settings pushBack _forEachIndex;
					};
				}forEach MAZ_EP_Settings;
				_settings;
			};

			MAZ_EP_fnc_isSettingsGroupInitiliazed = {
				params ["_settings"];
				private _init = true;
				{
					private _setting = MAZ_EP_Settings select _x;
					private _varName = _setting select 2;
					private _var = missionNamespace getVariable [_varName,nil];
					if(isNil "_var") then {
						_init = false;
						break;
					};
				}forEach _settings;
				_init;
			};

			MAZ_EP_fnc_updateSetting = {
				params ["_index","_varName","_value"];
				if(!isServer) exitWith {
					[_varName,_value] call MAZ_EP_fnc_saveSettingToProfile;
					[_this, {
						_this call MAZ_EP_fnc_updateSetting;
					}] remoteExec ['spawn',2];
				};
				private _setting = MAZ_EP_Settings select _index;
				_setting set [3,_value];
				MAZ_EP_Settings set [_index,_setting];
				missionNamespace setVariable [_varName,_value,true];
				publicVariable "MAZ_EP_Settings";
			};

			MAZ_EP_fnc_saveSettingToProfile = {
				params ["_name","_value"];
				private _existingSettings = profileNamespace getVariable ["MAZ_EP_SavedSettings",nil];
				if(isNil "_existingSettings") then {
					_existingSettings = [];
				};
				if((_existingSettings select 0) isEqualType false) then {
					_existingSettings = [];
				};

				private _found = false;
				{
					_x params ["_xName","_xValue"];
					if(toLower _xName != toLower _name) then {continue};
					_found = true;
					_existingSettings set [_forEachIndex,[_name,_value]];
				}forEach _existingSettings;
				if(!_found) then {
					_existingSettings pushBack [_name,_value];
				};
				profileNamespace setVariable ["MAZ_EP_SavedSettings",_existingSettings];
				saveProfileNamespace;
			};

			MAZ_EP_fnc_getSavedSettingFromProfile = {
				params ["_name","_default"];
				private _existingSettings = profileNamespace getVariable ["MAZ_EP_SavedSettings",nil];
				if(isNil "_existingSettings") exitWith {_default};
				private _savedValue = nil;
				{
					_x params ["_xName","_xValue"];
					if(toLower _xName != toLower _name) then {continue};
					_savedValue = _xValue;
					break;
				}forEach _existingSettings;
				if(isNil "_savedValue") then {
					_savedValue = _default;
					[_name,_default] call MAZ_EP_fnc_saveSettingToProfile;
				};
				_savedValue
			};

			MAZ_EP_fnc_initSettings = {
				{
					_x params ["","","_varName","_value","",""];
					missionNamespace setVariable [_varName,_value];
				}forEach MAZ_EP_Settings;
				MAZ_EP_SettingsLoaded = true;
			};

			MAZ_EP_fnc_editSettings = {
				if(canSuspend) exitWith {
					isNil {call MAZ_EP_fnc_editSettings};
				};
				if(count MAZ_EP_Settings <= 0) exitWith {
					["There are no settings to edit!"] call MAZ_EP_fnc_systemMessage;
				};
				with uiNamespace do {
					createDialog "RscDisplayEmpty";
					showchat true;
					MAZ_EP_settingsDialog = findDisplay -1;

					private _maxWidth = 0.4125 * safezoneW;

					private _contentGroup = MAZ_EP_settingsDialog ctrlCreate ["RscControlsGroupNoHScrollbars",110];
					_contentGroup ctrlSetPosition [(0.5 * safezoneW + safezoneX) - (_maxWidth / 2),0.269 * safezoneH + safezoneY,_maxWidth,0];
					_contentGroup ctrlCommit 0;

					private _bg = MAZ_EP_settingsDialog ctrlCreate ["RscPicture",-1,_contentGroup];
					_bg ctrlSetPosition [0,0,_maxWidth,0];
					_bg ctrlSetText "#(argb,8,8,3)color(0.2,0.2,0.2,0.9)";

					private _color = ["GUI", "BCG_RGB"] call BIS_fnc_displayColorGet;
					private _label = MAZ_EP_settingsDialog ctrlCreate ["RscText",-1,_contentGroup];
					_label ctrlSetPosition [0,0,_maxWidth,0.022 * safezoneH];
					_label ctrlSetText "Enhancement Pack Settings";
					_label ctrlSetTextColor (["GUI", "TITLETEXT_RGB"] call BIS_fnc_displayColorGet);
					_label ctrlSetBackgroundColor _color;
					_label ctrlCommit 0;

					private _yPos = 0.05;
					private _settingHeight = 0.06;
					private _settingsWidth = _maxWidth * 0.98;
					private _xOffset = (_maxWidth - _settingsWidth) / 2;

					private _settings = [];
					{
						_x params ["_displayName","_tooltip","_varName","_value","_type","_params"];
						private _settingGroup = MAZ_EP_settingsDialog ctrlCreate ["RscControlsGroupNoScrollbars",-1,_contentGroup];
						_settingGroup ctrlSetPosition [_xOffset,_yPos,_settingsWidth,_settingHeight];
						_settingGroup ctrlCommit 0;

						private _settingBg = MAZ_EP_settingsDialog ctrlCreate ["RscPicture",-1,_settingGroup];
						_settingBg ctrlSetPosition [0,0,_settingsWidth,_settingHeight];
						_settingBg ctrlSetText "#(argb,8,8,3)color(0.2,0.2,0.2,0.9)";
						_settingBg ctrlCommit 0;

						private _settingLabel = MAZ_EP_settingsDialog ctrlCreate ["RscText",-1,_settingGroup];
						if(count _displayName > 34) then {
							_tooltip = _displayName + "\n" + _tooltip;
							_displayName = (_displayName select [0,34]) + "...";
						};
						_settingLabel ctrlSetText _displayName;
						_settingLabel ctrlSetTooltip _tooltip;
						_settingLabel ctrlSetBackgroundColor [0,0,0,0.2];
						_settingLabel ctrlSetPosition [0,0,_settingsWidth * 0.4,_settingHeight];
						_settingLabel ctrlCommit 0;

						private _settingCtrl = controlNull;
						switch (_type) do {
							case "TOGGLE": {
								_settingCtrl = MAZ_EP_settingsDialog ctrlCreate ["RscToolbox",10,_settingGroup];
								_settingCtrl ctrlSetPosition [_settingsWidth * 0.4,0,_settingsWidth * 0.6,_settingHeight];
								lbClear _settingCtrl;
								_settingCtrl lbAdd "Disabled";
								_settingCtrl lbAdd "Enabled";
								_settingCtrl lbSetCurSel (parseNumber _value);
								_settingCtrl ctrlCommit 0;
							};
							case "SLIDER": {
								_params params ["_minValue","_maxValue"];
								_settingCtrl = MAZ_EP_settingsDialog ctrlCreate ["RscXSliderH",20,_settingGroup];
								_settingCtrl ctrlSetPosition [_settingsWidth * 0.4,0,_settingsWidth * 0.5,_settingHeight];
								_settingCtrl sliderSetRange [_minValue,_maxValue];
								_settingCtrl sliderSetPosition _value;
								_settingCtrl ctrlAddEventHandler ["sliderPosChanged", {
									params ["_ctrlSlider", "_value"];
									private _controlGroup = ctrlParentControlsGroup _ctrlSlider;
									private _ctrlEdit = _controlGroup controlsGroupCtrl 21;
									private _roundedValue = round _value;
									_ctrlEdit ctrlSetText format ["%1",_roundedValue];
								}];
								_settingCtrl ctrlCommit 0;

								private _sliderEdit = MAZ_EP_settingsDialog ctrlCreate ["RscEdit",21,_settingGroup];
								_sliderEdit ctrlSetPosition [_settingsWidth * 0.9, 0, _settingsWidth * 0.1, _settingHeight];
								_sliderEdit ctrlSetText (str _value);
								_sliderEdit ctrlAddEventHandler ["KeyUp",{
									params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];
									private _num = parseNumber (ctrlText _displayOrControl);
									private _ctrlGroup = ctrlParentControlsGroup _displayOrControl;
									private _sliderCtrl = _ctrlGroup controlsGroupCtrl 20;
									_sliderCtrl sliderSetPosition _num;
								}];
								_sliderEdit ctrlCommit 0;
							};
						};
						_settingCtrl setVariable ["MAZ_settingVarName", _varName];
						_settings pushBack _settingCtrl;

						_yPos = _yPos + _settingHeight + 0.01;
					}forEach (missionNamespace getVariable ["MAZ_EP_Settings",[]]);

					_contentGroup setVariable ["MAZ_settingsCtrls",_settings];

					_bg ctrlSetPositionH _yPos;
					_bg ctrlCommit 0;

					if(_yPos > 1.3) then {
						_yPos = 1.3;
					} else {
						_yPos = _yPos - _settingHeight + 0.02;
					};

					private _cancelButton = MAZ_EP_settingsDialog ctrlCreate ["RscButtonMenu",-1];
					_cancelButton ctrlSetPosition [(0.5 * safezoneW + safezoneX) - (_maxWidth / 2),1.1775,0.0567187 * safezoneW,0.022 * safezoneH];
					_cancelButton ctrlSetStructuredText parseText "Cancel";
					_cancelButton ctrlAddEventHandler ["ButtonClick", {
						params ["_control"];
						private _display = ctrlParent _control;
						_display closeDisplay 2;
					}];
					_cancelButton ctrlCommit 0;

					private _confirmButton = MAZ_EP_settingsDialog ctrlCreate ["RscButtonMenu",-1];
					_confirmButton ctrlSetPosition [(0.5 * safezoneW + safezoneX) + (_maxWidth / 2) - (0.0567187 * safezoneW),1.1775,0.0567187 * safezoneW,0.022 * safezoneH];
					_confirmButton ctrlSetStructuredText parseText "Confirm";
					_confirmButton ctrlAddEventHandler ["ButtonClick", {
						params ["_control"];
						private _display = ctrlParent _control;
						private _parentGroup = _display displayCtrl 110;
						private _settings = _parentGroup getVariable ["MAZ_settingsCtrls",[]];
						{
							private _value = null;
							switch (ctrlType _x) do {
								case 6: {
									comment "Toolbox";
									_value = [false, true] select (lbCurSel _x);
								};
								case 43: {
									comment "Slider";
									_value = round (sliderPosition _x);
								};
							};
							
							[_forEachIndex,_x getVariable "MAZ_settingVarName",_value] call MAZ_EP_fnc_updateSetting;
						}forEach _settings;

						_display closeDisplay 1;
					}];
					_confirmButton ctrlCommit 0;

					_yPos = _yPos + 0.04;
					

					private _contentYPos = (0.5 - (_yPos / 2));
					private _buttonYPos = (0.5 + (_yPos / 2)) + 0.01;
					_contentGroup ctrlSetPositionH _yPos;
					_contentGroup ctrlSetPositionY _contentYPos;
					_confirmButton ctrlSetPositionY _buttonYPos;
					_cancelButton ctrlSetPositionY _buttonYPos;
					_confirmButton ctrlCommit 0;
					_cancelButton ctrlCommit 0;
					_contentGroup ctrlCommit 0;
				};
			};

			MAZ_EP_fnc_settingsStressTest = {
				params [["_numOfTests",16]];
				if(!canSuspend) exitWith {};
				private _succCount = 0;
				private _failCount = 0;
				for "_i" from 1 to _numOfTests do {
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
					private _timeToInit = time + 1;
					waitUntil {
						_set = ["MAZ_CC"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
						(([_set] call MAZ_EP_fnc_isSettingsGroupInitiliazed) ||
						time >= _timeToInit)
					};
					_settings = ["MAZ_CC"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
					if([_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed) then {
						_succCount = _succCount + 1;
					} else {
						systemChat "ERROR: System failed to initialize.";
						_failCount = _failCount + 1;
					};


					MAZ_EP_CC_combatCalloutsEnabled = nil;
					MAZ_EP_CC_callMedicToggle = nil;
					MAZ_EP_CC_callReloadToggle = nil;
					MAZ_EP_CC_callSuppressedToggle = nil;
					MAZ_EP_CC_callFFToggle = nil;
					MAZ_EP_CC_callDeadFriendlyToggle = nil;
					MAZ_EP_CC_callHurtToggle = nil;
					MAZ_EP_CC_callKillToggle = nil;
					MAZ_EP_CC_callDirectionToggle = nil;
					MAZ_EP_CC_callNadeToggle = nil;
					MAZ_EP_CC_callNadeThrowToggle = nil;
				};
				systemChat format ["System failed %1 times. Succeeded %2 times.",_failCount,_succCount];
			};

		comment "Enhancement Pack Loop";

			MAZ_EP_fnc_mainLoop = {
				while {sleep 0.01;MAZ_EP_CoreEnabled} do {
					{
						private _fnc = missionNamespace getVariable [_x,{}];
						call _fnc;
					}forEach (missionNamespace getVariable ["MAZ_EP_loopFunctions",[]]);
				};
			};

			MAZ_EP_fnc_addFunctionToMainLoop = {
				params [["_functionName","",[""]]];
				if(_functionName == "") exitWith {false};
				if(typeName (missionNamespace getVariable [_functionName,""]) != typeName {}) exitWith {false};
				private _val = missionNamespace getVariable ["MAZ_EP_loopFunctions",[]];
				_val pushBack _functionName;
				missionNamespace setVariable ["MAZ_EP_loopFunctions",_val];
				true;
			};

			MAZ_EP_fnc_removeFunctionFromMainLoop = {
				params [["_functionName","",[""]]];
				if(_functionName == "") exitWith {false};
				if(typeName (missionNamespace getVariable [_functionName,""]) != typeName {}) exitWith {false};
				private _val = missionNamespace getVariable ["MAZ_EP_loopFunctions",[]];
				_val deleteAt (_val find _functionName);
				missionNamespace setVariable ["MAZ_EP_loopFunctions",_val];
				true;
			};

			["MAZ_fnc_removeTrollBackpacks"] call MAZ_EP_fnc_addFunctionToMainLoop;

		call MAZ_EP_fnc_initSettings;
		call MAZ_EP_fnc_createBaseDiary;
		call MAZ_EP_fnc_addCamoFacesToArsenal;
		[
			"Core Pack",
			"The Enhancement Pack Core adds the base functionality required for the rest of the EP, like keybinds and automated systems. It also implements a ton of small quality of life improvements. To see all keybinds available, press CTRL + 0.",
			[
				"Adjustable keybinds (Default CTRL + 0)",
				"Earplugs (Default END)",
				"Holstering weapon (Default H)",
				"Adjust view distance (Default 9 [NUM])",
				"Sit down in chairs (Default DOWN ARROW KEY)",
				"Automatic parachutes for HALO jumps",
				"Throw smokes while injured",
				"Unflip vehicles",
				"Repack magazines",
				"Improved vaulting",
				"Additional camo faces in the arsenal",
				"Anti-Troll measures",
				"Fixed GL smoke grenades from going to the stratosphere"
			]
		] spawn MAZ_EP_fnc_addDiaryRecord;
		
		[] spawn MAZ_EP_fnc_event_onNotificationCountChanged;
		[
			"Enhancement Pack Core has been loaded! Open your map and go to the Enhancement Pack section to learn more about the systems.",
			"System Initialization Notification",
			12
		] spawn MAZ_EP_fnc_createNotification;
		
		["Z.A.M. Server Enhancement Pack running!","addItemOk"] call MAZ_EP_fnc_systemMessage;
		[] spawn MAZ_fnc_globalLaserMarkers;
		[] spawn MAZ_fnc_addKeybinds;

		enableSentences false;
		enableRadio false;
		disableMapIndicators [false, true, true, false];

		if(isServer) then {
			call MAZ_fnc_initDefaultAddonServer;
		};
		[] spawn MAZ_EP_fnc_mainLoop;
	};
	call MAZ_EP_fnc_coreInit;
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

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["Auto HALO Altitude","The altitude at which players will be automatically equipped with a parachute.","MAZ_EP_autoHALOHeight",1000,"SLIDER",[300,2000]] call MAZ_EP_fnc_addNewSetting;
	["Disable Respawn Tents","Whether to remove respawn tents from player loadouts.","MAZ_EP_DisableRespawnTents",true,"TOGGLE",[]] call MAZ_EP_fnc_addNewSetting;
};

comment "
Cool stuff:
Group direction indicator: 'a3\ui_f\data\igui\rscingameui\rscunitinfo\groupdir_ca.paa'
Altimeter Watch Background: 'a3\ui_f\data\igui\rscingameui\rscunitinfoairrtdfulldigital\digital_background_altitude_imp_ca.paa'
Watch Hand: 'a3\ui_f\data\igui\rscingameui\rscunitinfoairrtdfulldigital\digital_arrow_vsi_ca.paa'

Cease Fire: Acts_PercMstpSlowWrflDnon_handup2
Stop: Acts_PercMstpSlowWrflDnon_handup2b
Wave: Acts_PercMstpSlowWrflDnon_handup1b

Laying Wounded: Acts_SittingWounded_in/loop/wave/out/breath

Open Terminal: Acts_TerminalOpen

Waking Up Lean: Acts_Waking_Up_Player | Acts_Getting_Up_Player

Injured Leaning Tell to Go: Acts_Injured_Driver_go/Loop


";