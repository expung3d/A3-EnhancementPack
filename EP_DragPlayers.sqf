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
if(missionNamespace getVariable ["MAZ_EP_dragPlayersEnabled",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Dragging Players already running!";};

private _varName = "MAZ_System_EnhancementPack_DP";
private _myJIPCode = "MAZ_EPSystem_DP_JIP";

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["Drag Players","Whether to allow the dragging system.","MAZ_EP_dragPlayersEnabled",true,"TOGGLE",[],"MAZ_DP"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_EP_fnc_dragPlayersCarrier = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_DP"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};
		MAZ_fnc_dragPlayerActions = {
			params ["_unit"];
			private _dragAction = _unit getVariable ["MAZ_DragAction",-1];
			if(_dragAction != -1) then {
				_unit removeAction _dragAction;
			};
			_unit setVariable ["MAZ_DragAction",
				_unit addAction [
					"Drag Player",
					{
						params ["_target", "_caller", "_actionId", "_arguments"];
						[_target,_caller] call MAZ_fnc_dragBody;
					},
					nil,
					1.5,
					true,
					false,
					"",
					"[_originalTarget,_this] call MAZ_fnc_canDragPlayer"
				]
			];

			private _bagAction = _unit getVariable ["MAZ_TakeBagAction",-1];
			if(_bagAction != -1) then {
				_unit removeAction _bagAction;
			};
			_unit setVariable ["MAZ_TakeBagAction",
				_unit addAction [
					"Take Backpack",
					{
						params ["_target", "_caller", "_actionId", "_arguments"];
						[_target,_caller] call MAZ_fnc_takeDownedBackpack;
					},
					nil,
					1.5,
					true,
					false,
					"",
					"[_originalTarget,_this] call MAZ_fnc_canDragPlayer && [_originalTarget,_this] call MAZ_fnc_canTakeBag"
				]
			];

			private _loadAction = _unit getVariable ["MAZ_LoadAction",-1];
			if(_loadAction != -1) then {
				_unit removeAction _loadAction;
			};
			_unit setVariable ["MAZ_LoadAction",
				_unit addAction [
					"Load Player in Vehicle",
					{
						params ["_target", "_caller", "_actionId", "_arguments"];
						private _vehicleToMoveIn = [_target] call MAZ_fnc_getNearestVehicleCanMoveIn;
						if(!isNull _vehicleToMoveIn) then {
							private _dragger = attachedTo _target;
							if(_dragger getVariable ["MAZ_isDragging",false]) then {
								[_dragger,1] call MAZ_fnc_releaseBody;
							};
							[[_vehicleToMoveIn], {
								_this call MAZ_fnc_moveInVehicle;
							}] remoteExec ['spawn',_target];
						};
					},
					nil,
					1.5,
					true,
					false,
					"",
					"[_originalTarget,_this] call MAZ_fnc_canLoadPlayer"
				]
			];
		};

		MAZ_fnc_addDropPlayerAction = {
			private _releaseAction = player getVariable ["MAZ_ReleaseAction",-1];
			if(_releaseAction != -1) then {
				player removeAction _releaseAction;
			};
			player setVariable ["MAZ_ReleaseAction",
				player addAction [
					"Release Player",
					{
						params ["_target", "_caller", "_actionId", "_arguments"];
						[_caller,1] call MAZ_fnc_releaseBody;
					},
					nil,
					1.5,
					true,
					false,
					"",
					"[_originalTarget] call MAZ_fnc_canDropPlayer"
				]
			];
		};

		MAZ_fnc_canDragPlayer = {
			params ["_dragged","_dragger"];
			if(!MAZ_EP_dragPlayersEnabled) exitWith {false};
			if(_dragged == _dragger) exitWith {false};
			if(_dragged distance _dragger > 4) exitWith {false};
			if(!alive _dragged) exitWith {false};
			private _isDragged = _dragged getVariable ["MAZ_isDragged",false];
			private _isDragging = _dragger getVariable ["MAZ_isDragging",false];
			private _draggingObject = _dragger getVariable ["MAZ_draggingObject",objNull];
			if(!isNull _draggingObject) exitWith {false};
			if(_isDragged) exitWith {false};
			if(_isDragging) exitWith {false};
			if !(animationState _dragged in ["unconsciousrevivedefault","unconsciousfaceup"]) exitWith {false};
			private _isPlayerDowned = _dragged getVariable "noParamsDowned";
			private _out = false;
			if(((lifeState _dragged) isEqualTo "INCAPACITATED") || (!isNil "_isPlayerDowned")) then {
				if(!isNil "_isPlayerDowned") exitWith {
					if(_isPlayerDowned) then {
						_out = true;
					};
				};
				_out = true;
			};
			_out
		};

		MAZ_fnc_canDropPlayer = {
			params ["_dragger"];
			private _draggingObject = _dragger getVariable ["MAZ_draggingObject",objNull];
			if(isNull _draggingObject) exitWith {false};
			if(_draggingObject == _dragger) exitWith {false};
			if(!alive _draggingObject) exitWith {false};
			true
		};

		MAZ_fnc_canTakeBag = {
			params ["_dragged","_dragger"];
			if(backpack _dragger != "") exitWith {false};
			if(backpack _dragged == "") exitWith {false};
			if(!("Medikit" in backpackItems _dragged) && !("FirstAidKit" in backpackItems _dragged)) exitWith {false};
			true 
		};

		MAZ_fnc_dragBody = {
			params ["_body","_dragger"];
			_body attachTo [_dragger,[0,1,0]];
			[[_body], {
				params ["_body"];
				waitUntil {!isNil "MAZ_fnc_dragDirectChange"};
				[_body] spawn MAZ_fnc_dragDirectChange;
			}] remoteExec ["spawn",0];
			_body setPos getPos _body;
			_body setVariable ["MAZ_isDragged",true,true];
			_dragger setVariable ["MAZ_isDragging",true,true];
			_dragger setVariable ["MAZ_draggingObject",_body,true];

			[_body] spawn {
				[player,"AmovPercMstpSlowWrflDnon_AcinPknlMwlkSlowWrflDb_1"] remoteExec ["playMove"];
				[(_this select 0),"AinjPpneMrunSnonWnonDb"] remoteExec ["switchMove"];
			};
			[_body,_dragger] spawn MAZ_fnc_waitUntilNotDraggingOrDead;
		};

		MAZ_fnc_releaseBody = {
			params ["_dragger","_mode"];
			private _body = _dragger getVariable ["MAZ_draggingObject",objNull];
			detach _body;
			_body setVariable ["MAZ_isDragged",false,true];
			_dragger setVariable ["MAZ_isDragging",false,true];
			_dragger setVariable ["MAZ_draggingObject",objNull,true];
			[_body,"UnconsciousFaceUp"] remoteExec ["switchMove"];
			switch(_mode) do {
				case 0 : {[_dragger,"UnconsciousFaceUp"] remoteExec ["switchMove"];};
				case 1 : {[_dragger,"AcinPknlMstpSrasWrflDnon_AmovPknlMstpSrasWrflDnon"] remoteExec ["playMove"];};
				case 2 : {};
			};
		};

		MAZ_fnc_dragDirectChange = {
			params ["_body"];
			_body setDir 180;
		};

		MAZ_fnc_takeDownedBackpack = {
			params ["_body","_caller"];
			private _backpack = backpack _body;
			private _backpackItems = backpackItems _body;
			_caller addBackpack _backpack;
			{
				_caller addItemToBackpack _x;
			} forEach _backpackItems;
			removeBackpackGlobal _body;
		};

		MAZ_fnc_waitUntilNotDraggingOrDead = {
			params ["_dragged","_dragger"];

			waitUntil {
				sleep 1;
				!(_dragger getVariable ["MAZ_isDragging",true]) ||
				((lifeState _dragger) isEqualTo "INCAPACITATED") || 
				!((lifeState _dragged) isEqualTo "INCAPACITATED") ||
				!(_dragger getVariable ["noParamsDowned",true]) ||
				!alive _dragger ||
				!alive _dragged ||
				(attachedTo _dragged != _dragger) ||
				!(vehicle _dragger == _dragger) ||
				(vectorMagnitude (velocity _dragger)) > 1.2
			};

			if(
				(lifeState _dragger) isEqualTo "INCAPACITATED" || 
				!alive _dragged || 
				!alive _dragger || 
				!((lifeState _dragged) isEqualTo "INCAPACITATED")
			) then {
				[_dragger,1] call MAZ_fnc_releaseBody;
			};

			if(vehicle _dragger != _dragger || (vectorMagnitude (velocity _dragger)) > 1.2) then {
				[_dragger,2] call MAZ_fnc_releaseBody;
			};
		};

		MAZ_fnc_getNearestVehicleCanMoveIn = {
			params ["_unit"];
			private _nearVehicles = nearestObjects [_unit,["LandVehicle","Air"],6];
			private _vehicleToMoveIn = objNull;
			{
				if((fullCrew [_x,"cargo",true] findIf {isNull (_x select 0)}) != -1) exitWith {
					_vehicleToMoveIn = _x;
				};
			}forEach _nearVehicles;
			_vehicleToMoveIn
		};

		MAZ_fnc_canLoadPlayer = {
			params ["_dragged","_dragger"];
			if(!MAZ_EP_dragPlayersEnabled) exitWith {false};
			if(_dragged == _dragger) exitWith {false};
			if(_dragged distance _dragger > 4) exitWith {false};
			if(!alive _dragged) exitWith {false};
			private _isPlayerDowned = _dragged getVariable "noParamsDowned";
			if(!(((lifeState _dragged) isEqualTo "INCAPACITATED") || (!isNil "_isPlayerDowned" && {_isPlayerDowned}))) exitWith {false};
			private _vehicleToMoveIn = [_dragged] call MAZ_fnc_getNearestVehicleCanMoveIn;
			!isNull _vehicleToMoveIn
		};

		MAZ_fnc_carryPlayer = {
			params ["_dragged","_dragger"];
			_dragged attachTo [_dragger,[0.3,0.3,0]];
			[[_dragged], {
				params ['_unit'];
				waitUntil {!isNil "MAZ_fnc_changePlayerDir"};
				[_unit,180] call MAZ_fnc_changePlayerDir;
			}] remoteExec ['spawn'];
			[_dragged, "AinjPfalMstpSnonWnonDnon_carried_up"] remoteExec ["playMoveNow"];
			waitUntil {animationState _dragged == "AinjPfalMstpSnonWnonDnon_carried_up"};
			[_dragger,"AcinPknlMstpSrasWrflDnon_AcinPercMrunSrasWrflDnon"] remoteExec ["switchMove"];
			MAZ_CARRYOBJ ATTACHtO [PLAYER,[0.15,0.1,0.1]];
		};

		MAZ_fnc_dropCarryPlayer = {
			params ["_dragged","_dragger"];
			[_dragged, "AinjPfalMstpSnonWnonDnon_carried_down"] remoteExec ["playMoveNow"];
			[[_dragger], {
				params ['_unit'];
				waitUntil {!isNil "MAZ_fnc_changePlayerDir"};
				[_unit,90] call MAZ_fnc_changePlayerDir;
			}] remoteExec ['spawn'];
			detach _dragged;
			[_dragger,"AcinPercMrunSrasWrflDf_AmovPercMstpSlowWrflDnon"] remoteExec ["switchMove"];
		};

		MAZ_fnc_changePlayerDir = {
			params ['_body','_dir'];
			_body setDir _dir;
		};

		MAZ_fnc_moveInVehicle = {
			params ["_vehicle"];
			player moveInCargo _vehicle;
			[] spawn {
				sleep 0.1;
				[player,"die"] remoteExec ['playAction'];
			};
		};

		[] spawn {
			waitUntil {uisleep 0.1;!isNull (findDisplay 46) && alive player};
			sleep 0.1;

			if(!isNil "MAZ_EH_RespawnDrag") then {
				player removeEventHandler ["Respawn",MAZ_EH_RespawnDrag];
			};
			MAZ_EH_RespawnDrag = player addEventhandler ["Respawn",{
				params ["_unit", "_corpse"];
				_unit setVariable ["MAZ_isDragged",false,true];
				_unit setVariable ["MAZ_isDragging",false,true];
				_unit setVariable ["MAZ_draggingObject",objNull,true];
				call MAZ_fnc_addDropPlayerAction;
				[[_unit],{
					params ["_unit"];
					waitUntil {!isNil "MAZ_fnc_dragPlayerActions"};
					[_unit] call MAZ_fnc_dragPlayerActions;
				}] remoteExec ['spawn',0,_unit];
			}];

			call MAZ_fnc_addDropPlayerAction;
			[[player],{
				params ["_unit"];
				waitUntil {!isNil "MAZ_fnc_dragPlayerActions"};
				[_unit] call MAZ_fnc_dragPlayerActions;
			}] remoteExec ['spawn',0,player];
		};
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		[
			"Player Dragging", 
			"You can drag injured friendlies and load them into vehicles. Allowing you to move them to safety before reviving them.",
			[
				"Dragging downed players",
				"Take the backpack of a downed player",
				"Load injured players into vehicles for transport"
			]
		] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Drag Players System has been loaded! You can now drag your injured friends to safety!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	[] spawn MAZ_EP_fnc_dragPlayersCarrier;
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