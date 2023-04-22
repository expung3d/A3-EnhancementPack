
if(!isNull (findDisplay 312) && {!isNil "this"} && {!isNull this}) then {
	deleteVehicle this;
};

if(missionNamespace getVariable ["MAZ_EP_CoreEnabled",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Core pack already running! Add the features you want.";};

private _varName = "MAZ_System_EnhancementPackCore";
private _myJIPCode = "MAZ_EPSystem_Core_JIP";

MAZ_dropSmokeInjuredToggle = true;
publicVariable 'MAZ_dropSmokeInjuredToggle';

MAZ_globalLaserMarkers = false;
publicVariable "MAZ_globalLaserMarkers";

MAZ_EP_CoreEnabled = true;
publicVariable "MAZ_EP_CoreEnabled";

private _value = (str {
	if(isNil "MAZ_keyAr" && isNil "MAZ_fnc_keybindCarrier") then {
		MAZ_fnc_keybindCarrier = {
			MAZ_isChangingKeybind = false;

			MAZ_fnc_newKeybind = {
				params ["_displayName","_description","_keyCode","_code",["_shift",false],["_ctrl",false],["_alt",false],["_zeusKeybind",false]];
				if(isNil "MAZ_KeybindData") then {
					MAZ_KeybindData = [];
				};
				private _display = if(_zeusKeybind) then {findDisplay 312} else {findDisplay 46};

				MAZ_KeybindData pushBack [_displayName,_description,_display,_keyCode,_code,[_shift,_ctrl,_alt]];
			};

			MAZ_fnc_removeKeybind = {
				params ["_keybindID"];
				if((count MAZ_KeybindData - 1) >= _keybindID) exitWith {
					MAZ_KeybindData deleteAt _keybindID;
					true
				};
				false
			};

			MAZ_fnc_changeKeybindKey = {
				params ["_index","_newKeyCode","_modifierDataNew"];
				private _KeybindData = MAZ_KeybindData select _index;
				_KeybindData params ["_displayName","_description","_display","_keyCode","_code","_modifierData"];
				if(_keyCode != _newKeyCode) then {
					MAZ_KeybindData set [_index,[_displayName,_description,_display,_newKeyCode,_code,_modifierDataNew]]
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
					{
						_x params ["","","_displayBind","_keyCode","_code","_modifiers"];
						_modifiers params ["_isShift","_isCtrl","_isAlt"];
						if(_shift == _isShift && _ctrl == _isCtrl && _alt == _isAlt && _key == _keyCode && _displayBind == _display && !MAZ_isChangingKeybind) then {
							[] call _code;
						};
					}forEach MAZ_KeybindData;
				}];
				if(!isNil "MAZ_Key_Keybinds312") then {
					(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_Key_Keybinds312];
				};
				MAZ_Key_Keybinds312 = (findDisplay 312) displayAddEventHandler ["KeyDown",{
					params ['_display', '_key', '_shift', '_ctrl', '_alt'];
					{
						_x params ["","","_displayBind","_keyCode","_code","_modifiers"];
						_modifiers params ["_isShift","_isCtrl","_isAlt"];
						if(_shift == _isShift && _ctrl == _isCtrl && _alt == _isAlt && _key == _keyCode && _displayBind == _display && !MAZ_isChangingKeybind) then {
							[] call _code;
						};
					}forEach MAZ_KeybindData;
				}];
			};

			comment "Ctrl + 0";
			[] spawn {
				waitUntil {uisleep 0.1;!isNull (findDisplay 46) && alive player};
				sleep 0.1;
				[] spawn MAZ_fnc_KeybindSystemInit;
				if(isNil "MAZ_Key_MainKey") then {
					MAZ_Key_MainKey = ["Keybinds Menu","Edit the in-game keybinds.",11,{[] call MAZ_fnc_modifyKeybindsInterface;},false,true] call MAZ_fnc_newKeybind;
				};
			};
		};
		call MAZ_fnc_keybindCarrier;
	};

	MAZ_EP_fnc_defaultKeybindsCarrier = {
		MAZ_smokeGrenades = [
			'SmokeShell',
			'SmokeShellOrange',
			'SmokeShellBlue',
			'SmokeShellRed',
			'SmokeShellPurple',
			'SmokeShellGreen'
		];
		publicVariable 'MAZ_smokeGrenades';

		MAZ_fnc_earplugsLite = {
			private _isEarplugsIn = player getVariable ['isEarplugsIn',false];
			if(_isEarplugsIn) then {
				1 fadeSound 1;
				player setVariable ['isEarplugsIn',false];
				[] call MAZ_fnc_deleteEarplugIcon;
			} else {
				1 fadeSound 0.1;
				player setVariable ['isEarplugsIn',true];
				[] call MAZ_fnc_createEarplugIcon;
			};
		};

		MAZ_fnc_createEarplugIcon = {
			with uiNamespace do {
				_display = findDisplay 46;

				earplugsIcon = _display ctrlCreate ["RscPicture",-1];
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

		MAZ_fnc_sitDown = {
			private _chair = cursorObject;

			private _chairType = [
				"Land_CampingChair_V2_F",
				"Land_CampingChair_V2_white_F",
				"Land_CampingChair_V1_F", 
				"Land_Chair_EP1", 
				"Land_RattanChair_01_F", 
				"Land_Bench_F", 
				"Land_ChairWood_F", 
				"Land_OfficeChair_01_F",
				"Land_WoodenLog_F",
				"Land_ChairPlastic_F",
				"Land_ArmChair_01_F",
				"Land_ChairWood_F"
			];
			
			private _type_id = [
				"Land_CampingChair_V2_F",
				"Land_CampingChair_V2_white_F",
				"Land_CampingChair_V1_F", 
				"Land_Chair_EP1", 
				"Land_RattanChair_01_F", 
				"Land_Bench_F", 
				"Land_ChairWood_F", 
				"Land_OfficeChair_01_F",
				"Land_WoodenLog_F",
				"Land_ChairPlastic_F",
				"Land_ArmChair_01_F",
				"Land_ChairWood_F"
			] find (typeOf _chair);
			
			
			player setVariable ["chair",_chair];
			if ((player distance _chair) < 4) then {
				if((typeOf _chair) in _chairType) then {
					private _unit = player;
					if (isNil "_unit") exitWith {};
					_ehAnimDone = _unit addEventHandler ["AnimDone", {
						private["_unit","_animset","_anim"];
						_unit = player;
						_animset = ["HubSittingChairA_idle1","HubSittingChairA_idle2","HubSittingChairA_idle3","HubSittingChairA_move1"];

						if (alive _unit) then {
							_anim = _animset select (round (random (count _animset - 1)));
							[_unit,_anim] remoteExec ["switchMove", 0];
						};
					}];
					private _playerDir = direction player;
					_unit setVariable ["MAZ_animEH",_ehAnimDone];
					[_unit,"HubSittingChairA_idle1"] remoteExec ["switchMove",0];
					private _offset = [[0,-0.1,-0.5],[0,-0.1,-0.5], [0,-0.1,-0.5], [0,0,-0.5], [0,0,-0.5], [0,0,-0.2], [0,0,0], [0,0,-0.6],[0,0,-0.2],[0,0,-0.5],[0,0,-0.6],[0,0,-0.5]] select _type_id;
					private _dir = [180, 180, 180, 90, 180, 90, 180, 180,_playerDir, 90,360,90] select _type_id;
					_unit attachTo [_chair, _offset];
					_unit allowDamage false;
					_unit setDir _dir;
					comment "[_unit, _dir] remoteExec ['setDir',0,true]";
					_unit setVariable ["sitting", true];
					if(isNull (player getVariable "chair")) then {
						[_unit,""] remoteExec ["switchMove",0];
						detach _unit;
						_unit removeEventHandler ["AnimDone",_unit getVariable ["MAZ_animEH",0]];
						_unit setVariable ["sitting", false];
					};
				};
			};
		};

		MAZ_fnc_standUp = {
			private _unit = player;
			
			private _chair = player getVariable "chair";
			private _positionPlayer = getPosATL player;
			if ((_unit getVariable ["sitting", false])) then {
				_unit removeEventHandler ["AnimDone",_unit getVariable ["MAZ_animEH",0]];
				[_unit, ""] remoteExec ["switchMove", 0];
				detach _unit;
				player allowDamage true;
				_unit setPos [(_positionPlayer select 0), (_positionPlayer select 1) + 0.8,(_positionPlayer select 2) -0.5];
				_unit setVariable ["sitting", false];
			};
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

		MAZ_fnc_liteViewDistanceMenu = {
			MAZ_currentViewDistance = viewDistance;
			with uiNamespace do {
				viewDistLite = (findDisplay 46) createDisplay "RscDisplayEmpty";
				showChat true;

				viewDistChanger = viewDistLite ctrlCreate ["RscStructuredText", 1100];
				viewDistChanger ctrlSetStructuredText parseText "Change View Distance";
				viewDistChanger ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.429 * safezoneH + safezoneY,0.12375 * safezoneW,0.022 * safezoneH];
				viewDistChanger ctrlSetTextColor [1,1,1,1];
				viewDistChanger ctrlSetBackgroundColor [0.1,0.5,0,1];
				viewDistChanger ctrlCommit 0;

				viewDistBG = viewDistLite ctrlCreate ["RscPicture", 1200];
				viewDistBG ctrlSetText "#(argb,8,8,3)color(0,0,0,0.65)";
				viewDistBG ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.456 * safezoneH + safezoneY,0.12375 * safezoneW,0.088 * safezoneH];
				viewDistBG ctrlCommit 0;

				viewDistFrame = viewDistLite ctrlCreate ["RscFrame", 1800];
				viewDistFrame ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.456 * safezoneH + safezoneY,0.12375 * safezoneW,0.088 * safezoneH];
				viewDistFrame ctrlCommit 0;

				viewDistEdit = viewDistLite ctrlCreate ["RscEdit", 1400];
				viewDistEdit ctrlSetText format ["%1",missionNamespace getVariable 'MAZ_currentViewDistance'];
				viewDistEdit ctrlSetPosition [0.443281 * safezoneW + safezoneX,0.467 * safezoneH + safezoneY,0.113437 * safezoneW,0.033 * safezoneH];
				viewDistEdit ctrlCommit 0;

				viewDistButton = viewDistLite ctrlCreate ["RscButtonMenu", 2400];
				viewDistButton ctrlSetStructuredText parseText "Apply";
				viewDistButton ctrlSetPosition [0.448438 * safezoneW + safezoneX,0.511 * safezoneH + safezoneY,0.103125 * safezoneW,0.022 * safezoneH];
				viewDistButton ctrlAddEventHandler ["ButtonClick",{
					private _newDistance = parseNumber (ctrlText (uiNamespace getVariable 'viewDistEdit'));
					setViewDistance _newDistance;
					with uiNamespace do {viewDistLite closeDisplay 0;};
				}];
				viewDistButton ctrlCommit 0;
			};
		};

		MAZ_fnc_holsterWeapon = {
			player action ['SWITCHWEAPON',player,player,-1];
			waitUntil {currentWeapon player == '' or {primaryWeapon player == '' && handgunWeapon player == ''}};
		};

		MAZ_fnc_repackButton = {
			disableSerialization;
			waitUntil{!isNull (findDisplay 602)};
			with uiNamespace do {
				repackButton = (findDisplay 602) ctrlCreate ["RscButtonMenu", 1600];
				repackButton ctrlSetBackgroundColor [0,0,0,0.6];
				repackButton ctrlSetPosition [0.433069 * safezoneW + safezoneX,0.7545 * safezoneH + safezoneY,0.3025 * safezoneW,0.027 * safezoneH];
				repackButton ctrlSetEventHandler ["ButtonClick","[] spawn MAZ_fnc_newRepack;"];
				repackButton ctrlSetStructuredText parseText "<t size='0.05'>&#160;</t><br/><t align='center' size='1.01'>Repack Magazines</t>";
				repackButton ctrlSetFont "PuristaSemiBold";
				repackButton ctrlCommit 0;
			};
			showChat true;
		};

		MAZ_fnc_newRepack = {
			_mags = magazinesAmmoFull player;
			_primWep = primaryWeapon player;
			_primWepCompatMags = [_primWep] call BIS_fnc_compatibleMagazines;
			_secWep = handgunWeapon player;
			_secWepCompatMags = [_secWep] call BIS_fnc_compatibleMagazines;
			_totalPrimAmmo = 0;
			_magPrimArray = [];
			_ammoPrimArray = [];
			_locPrimArray = [];
			_totalSecAmmo = 0;
			_magSecArray = [];
			_ammoSecArray = [];
			_locSecArray = [];
			_maxPrim = 0;
			_maxSec = 0;
			_glRounds = [
				'1rnd_he_grenade_shell',
				'3rnd_he_grenade_shell',
				'1rnd_smoke_grenade_shell',
				'3rnd_smoke_grenade_shell',
				'1rnd_smokered_grenade_shell',
				'3rnd_smokered_grenade_shell',
				'1rnd_smokegreen_grenade_shell',
				'3rnd_smokegreen_grenade_shell',
				'1rnd_smokeyellow_grenade_shell',
				'3rnd_smokeyellow_grenade_shell',
				'1rnd_smokepurple_grenade_shell',
				'3rnd_smokepurple_grenade_shell',
				'1rnd_smokeblue_grenade_shell',
				'3rnd_smokeblue_grenade_shell',
				'1rnd_smokeorange_grenade_shell',
				'3rnd_smokeorange_grenade_shell'
			];

			{
				_magClass = (_x select 0);
				_magAmmo = (_x select 1);
				_magType = (_x select 3);
				_magLoc = (_x select 4);

				if(_magType == -1) then {
					if ((toLower _magClass) in _primWepCompatMags && !((toLower _magClass) in _glRounds)) then {
						_magPrimArray pushback _magClass;
						_ammoPrimArray pushback _magAmmo;
						_locPrimArray pushback _magLoc;
						player setVariable ["PrimMag",_magClass];
						_maxPrim = getNumber (configfile >> "CfgMagazines" >> _magClass >> "count");
					};
					if ((toLower _magClass) in _secWepCompatMags) then {
						_secMagClass = _magClass;
						_magSecArray pushback _magClass;
						_ammoSecArray pushback _magAmmo;
						_locSecArray pushback _magLoc;
						
						player setVariable ["SecMag",_secMagClass];
						_maxSec = getNumber (configfile >> "CfgMagazines" >> _magClass >> "count");
					};
				};
			} forEach _mags;

			comment "Finds total amount of ammo.";
			{
				_totalPrimAmmo = _totalPrimAmmo + (_x);
			} forEach _ammoPrimArray;
			{
				_totalSecAmmo = _totalSecAmmo + (_x);
			} forEach _ammoSecArray;

			comment "Removes magazines";
			{
				player removeMagazine _x;
			} forEach _magPrimArray;
			{
				player removeMagazine _x;
			} forEach _magSecArray;
			sleep 0.1;

			comment "Adds magazines back to player with proper amounts";
			_primMagType = player getVariable "PrimMag";
			_secMagType = player getVariable "SecMag";
			
			comment "Loading bar";
			_timeForBar = 0;
			_primAmmoTime = 0;
			_secAmmoTime = 0;
			if(_maxSec != 0) then {
				_secAmmoTime = (_totalSecAmmo / _maxSec);
			};
			if(_maxPrim != 0) then {
				_primAmmoTime = (_totalPrimAmmo / _maxPrim);
			};
			_timeForBar = (_primAmmoTime + _secAmmoTime - 1);
			[_timeForBar] spawn MAZ_fnc_repackLoadingBar;

			while {_maxPrim < _totalPrimAmmo} do {
				player addMagazine [_primMagType, _maxPrim];
				_totalPrimAmmo = _totalPrimAmmo - _maxPrim;
				sleep 1;
			};
			if (_totalPrimAmmo <= _maxPrim) then {
				if(_totalPrimAmmo > 0) then {
					player addMagazine [_primMagType, _totalPrimAmmo];
				};
			};
			while {_maxSec < _totalSecAmmo} do {
				player addMagazine [_secMagType, _maxSec];
				_totalSecAmmo = _totalSecAmmo - _maxSec;
				sleep 1;
			};
			if (_totalSecAmmo <= _maxSec) then {
				if(_totalSecAmmo > 0) then {
					player addMagazine [_secMagType, _totalSecAmmo];
				};
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

			magsRepackDone = false;
			[] spawn MAZ_fnc_repackAnimation;

			with uiNamespace do {
				progressBarForeground ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.753 * safezoneH + safezoneY,0.4125 * safezoneW,0.022 * safezoneH];
				progressBarForeground ctrlCommit _amountOfMags;
				
				uiSleep _amountOfMags;

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
			magsRepackDone = true;
			player playActionNow "stop";
		};

		MAZ_fnc_repackAnimation = {
			while {magsRepackDone == false} do {
				player playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
				sleep 5;
			};
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
			if(((getPosATL player) select 2) >= 1500 && backpack player != "B_Parachute") then {
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
									_listBox lbSetData [lbWhite, "White"];
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
			private _smokeType = _listBox lbText _smokeIndex;
			private _smokeData = _listBox lbData _smokeIndex;
			private _mags = magazines player;
			switch (_smokeData) do {
				case "White": {player removeMagazine "SmokeShell"; "SmokeShell" createVehicle position player;};
				case "Red": {player removeMagazine "SmokeShellRed"; "SmokeShellRed" createVehicle position player;};
				case "Orange": {player removeMagazine "SmokeShellOrange"; "SmokeShellOrange" createVehicle position player;};
				case "Yellow": {player removeMagazine "SmokeShellYellow"; "SmokeShellYellow" createVehicle position player;};
				case "Green": {player removeMagazine "SmokeShellGreen"; "SmokeShellGreen" createVehicle position player;};
				case "Blue": {player removeMagazine "SmokeShellBlue"; "SmokeShellBlue" createVehicle position player;};
				case "Purple": {player removeMagazine "SmokeShellPurple"; "SmokeShellPurple" createVehicle position player;};
			};
			uiNamespace getVariable ['dropSmokeMenu',displayNull] closeDisplay 0;
		};

		MAZ_fnc_addKeybinds = {
			waitUntil {uisleep 0.1;!isNull (findDisplay 46) && alive player};
			sleep 0.1;
			waitUntil {!isNil "MAZ_fnc_newKeybind"};
			if(!isNil "MAZ_DEH_KeyDown_Earplugs") then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_DEH_KeyDown_Earplugs];
			};
			if(!isNil "earplugsBind_Comp_MAZ") then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown",earplugsBind_Comp_MAZ];
				[[],{}] remoteExec ['spawn',0,'MAZ_testEarplugs'];
			};
			MAZ_Key_Earplugs = ["Toggle Earplugs","Toggle your earplugs.",207,{call MAZ_fnc_earplugsLite;},false,false] call MAZ_fnc_newKeybind;
			MAZ_Key_Holster = ["Holster Weapon","Holster your weapon.",35,{[] spawn MAZ_fnc_holsterWeapon;},false,false] call MAZ_fnc_newKeybind;
			MAZ_Key_ViewDist = ["Edit View Distance","Edit your view distance (Local).",73,{[] spawn MAZ_fnc_liteViewDistanceMenu;},false,false] call MAZ_fnc_newKeybind;
			MAZ_Key_Unflip = ["Unflip Vehicle","Unflip the vehicle you look at.",12,{[] spawn MAZ_liteUnflip;},false,true] call MAZ_fnc_newKeybind;
			MAZ_Key_SitDown = ["Sit Down","Sit down in the chair.",208,{[] spawn MAZ_fnc_sitDown;},false,false] call MAZ_fnc_newKeybind;
			MAZ_Key_StandUp = ["Stand Up","Stand up from the chair.",200,{[] spawn MAZ_fnc_standUp;},false,false] call MAZ_fnc_newKeybind;
			MAZ_Key_DeploySmoke = ["Deploy Smokes","Use smoke while injured.",57,{[] spawn MAZ_fnc_openSmokeGrenadeMenu;},false,false] call MAZ_fnc_newKeybind;

			if(!isNil "MAZ_DEH_KeyDown_Jump") then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_DEH_KeyDown_Jump];
			};
			MAZ_jumpKeyBind = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call MAZ_fnc_doJump;"];

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

			if(!isNil "MAZ_EH_GetInMan_VehicleAnimations") then {
				player removeEventHandler ["GetInMan",MAZ_EH_GetInMan_VehicleAnimations];
			};
			MAZ_EH_GetInMan_VehicleAnimations = player addEventHandler ["GetInMan",{
				params ["_unit", "_role", "_vehicle", "_turret"];
				comment "
					TODO MUST REWRITE
				";
			}];

			if(!isNil "MAZ_EH_GetOutMan_VehicleAnimations") then {
				player removeEventHandler ["GetOutMan",MAZ_EH_GetOutMan_VehicleAnimations];
			};
			MAZ_EH_GetOutMan_VehicleAnimations = player addEventHandler ["GetOutMan",{
				params ["_unit", "_role", "_vehicle", "_turret"];
				comment "
					TODO MUST REWRITE
				";
			}];

			if(!isNil "MAZ_EH_GetOutMan_AutoHALO") then {
				player removeEventHandler ["GetOutMan",MAZ_EH_GetOutMan_AutoHALO];
			};
			MAZ_EH_GetOutMan_AutoHALO = player addEventHandler ["GetOutMan", {
				[] spawn MAZ_fnc_autoHALO;
			}];

			waitUntil {!isNull (findDisplay 12)};
			MAZ_DEH_PreventDeleteMarkers = (findDisplay 12) displayAddEventHandler ["KeyDown", {
				params ["","_key"];
				if(_key != 211) exitWith {false}; comment "Don't override anything but the delete key";
				private _pos = (findDisplay 12 displayCtrl 51) ctrlMapScreenToWorld getMousePosition;
				private _marker = [allMapMarkers,[],{_pos distanceSqr (getMarkerPos _x)},"ASCEND"] call BIS_fnc_sortBy;
				_marker = _marker select 0;
				private _dist = (getMarkerPos _marker) distance2D _pos;
				if(_dist > 150) exitWith {false}; comment "Not deleting a marker";
				private _str = format ["%1_Owner",_marker];
				private _id = getPlayerUID player;
				private _markerOwner = missionNamespace getVariable [_str,""];
				if((allPlayers findIf {getPlayerUID _x == _markerOwner}) == -1) exitWith {false}; comment "Not in server";
				if(_id == _markerOwner || (call BIS_fnc_admin) != 0) exitWith {false}; comment "If you are the marker owner or admin";
				comment "Otherwise prevent marker deletion";
				true
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

		MAZ_EP_fnc_createBaseDiary = {
			MAZ_EP_DiarySubject = player createDiarySubject ["MAZ_EP_DiarySubject","Enhancement Pack"];
		};

		MAZ_EP_fnc_addDiaryRecord = {
			params ["_displayName","_description"];
			waitUntil {!isNil "MAZ_EP_DiarySubject"};
			player createDiaryRecord ["MAZ_EP_DiarySubject",[format ["[EP] : %1",_displayName],format ["<font color='#db8727' size='18' face='PuristaSemibold'>%1</font><br/><font size='16' face='PuristaSemibold'>%2</font>",_displayName,_description]]];
		};

		MAZ_EP_fnc_systemMessage = {
			params ["_text",["_sound",""]];
			systemChat format ["[ EP ] : %1",_text];
			if(_sound != "") then {
				playSound _sound;
			};
		};

		call MAZ_EP_fnc_createBaseDiary;
		["Core Pack","The Enhancement Pack Core adds the base functionality required for the rest of the EP. This adds the keybind framework and various other systems. To see all keybinds available, press CTRL + 0 (on your main keyboard)."] spawn MAZ_EP_fnc_addDiaryRecord;

		["Z.A.M. Server Enhancement Pack running!","addItemOk"] call MAZ_EP_fnc_systemMessage;
		[] spawn MAZ_fnc_globalLaserMarkers;
		[] spawn MAZ_fnc_addKeybinds;
		if(isServer) then {
			call MAZ_fnc_initDefaultAddonServer;
		};
	};
	call MAZ_EP_fnc_defaultKeybindsCarrier;
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