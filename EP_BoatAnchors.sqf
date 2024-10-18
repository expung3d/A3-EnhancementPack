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
if(missionNamespace getVariable ["MAZ_EP_boatAnchors",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Boat Anchors already running!";};

private _varName = "MAZ_System_EnhancementPack_BA";
private _myJIPCode = "MAZ_EPSystem_BA_JIP";

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["Boat Anchors","Whether to enable the Boat Anchors system.","MAZ_EP_boatAnchors",true,"TOGGLE",[],"MAZ_BA"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_anchorPoints = [
		["Boat_Armed_01_base_F",[0,0.2,-1.2]],
		["Boat_Civil_01_base_F",[0,-2.275,-0.3]],
		["Rubber_duck_base_F",[0,0,-1]],
		["Boat_Transport_02_base_F",[0,0,-0.05]]
	];
	publicVariable "MAZ_anchorPoints";

	MAZ_EP_fnc_boatAnchorsCarrier = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_BA"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};
		MAZ_fnc_boatAnchorServerLoop = {
			if(time < (missionNamespace getVariable ["MAZ_BA_loopTime",time])) exitWith {};
			call MAZ_fnc_setupBoatAnchor;
			missionNamespace setVariable ["MAZ_BA_loopTime",time + 1];
		};

		MAZ_fnc_setupBoatAnchor = {
			{
				if(!(typeOf _x isKindOf "Boat_F")) then {continue};
				if(typeOf _x isKindOf "SDV_01_base_F") then {continue};
				private _isSetup = _x getVariable ["MAZ_boatAnchor_isSetup",false];
				if(!_isSetup) then {
					_x setVariable ["MAZ_boatAnchor_isSetup",true,true];
					[_x,{
						waitUntil {!isNil "MAZ_fnc_boatAnchorActions"};
						[_this] call MAZ_fnc_boatAnchorActions;
					}] remoteExec ['spawn',0,_x];
				};
			}forEach vehicles;
		};

		MAZ_fnc_canDeployAnchor = {
			params ["_boat","_caller"];
			if(!MAZ_EP_boatAnchors) exitWith {false};
			if(!(_caller in _boat) || (driver _boat) != _caller) exitWith {false};
			if(!(surfaceIsWater (getPos _boat))) exitWith {false};
			private _isAnchorDeployed = _boat getVariable ["MAZ_anchorDeployed",false];
			private _isAnchorBroken = _boat getVariable ["MAZ_anchorBroken",false];
			if(_isAnchorDeployed || _isAnchorBroken) exitWith {false};
			if(speed _boat > 15) exitWith {false};
			true
		};

		MAZ_fnc_canRetractAnchor = {
			params ["_boat","_caller"];
			if(!MAZ_EP_boatAnchors) exitWith {false};
			if(!(_caller in _boat) || (driver _boat) != _caller) exitWith {false};
			private _isAnchorDeployed = _boat getVariable ["MAZ_anchorDeployed",false];
			private _isAnchorBroken = _boat getVariable ["MAZ_anchorBroken",false];
			if(!_isAnchorDeployed || _isAnchorBroken) exitWith {false};
			true
		};

		MAZ_fnc_boatAnchorActions = {
			params ["_boat"];
			private _deploy = _boat addAction [
				"Deploy Anchor",
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
					[_target] call MAZ_fnc_anchorBoat;
				},
				nil,
				1.5,
				true,
				false,
				"",
				"[_originalTarget,_this] call MAZ_fnc_canDeployAnchor"
			];
			_boat setUserActionText [_deploy,"Deploy Anchor","<img size='1.8' image='a3\3den\data\cfgwaypoints\hook_ca.paa' />"];

			private _stow = _boat addAction [
				"Stow Anchor",
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
					[_target] spawn MAZ_fnc_stowAnchor;
				},
				nil,
				1.5,
				true,
				false,
				"",
				"[_originalTarget,_this] call MAZ_fnc_canRetractAnchor"
			];
			_boat setUserActionText [_stow,"Stow Anchor","<img size='1.8' image='a3\3den\data\cfgwaypoints\unhook_ca.paa' />"];
		};

		MAZ_fnc_getAnchorPosition = {
			params ["_boat"];
			private _pos = [0,0,0];
			{
				_x params ["_type","_attachPos"];
				if(typeOf _boat isKindOf _type) exitWith {
					_pos = _attachPos;
				};
			}forEach MAZ_anchorPoints;
			_pos;
		};

		MAZ_fnc_anchorBoat = {
			params ["_boat"];
			private _anchorObject = "Land_VergeRock_01_F" createVehicle [0,0,0];
			_anchorObject allowDamage false;
			_anchorObject setMass (getMass _anchorObject * 50);
			(getPosATL _boat) params ["_x","_y","_z"];
			_anchorObject setPosATL [_x,_y,_z - 3];
			private _attPos = [_boat] call MAZ_fnc_getAnchorPosition;
			_boat setVariable [
				"MAZ_anchorRope",
				(ropeCreate [_boat,_attPos,_anchorObject,[0,0,0],_z + 10]),
				true
			];
			_boat setVariable [
				"MAZ_EH_ropeBreak_Anchor",
				_boat addEventHandler ["RopeBreak", {
					params ["_tower", "_rope", "_towed"];
					[_tower,_rope,_towed] spawn MAZ_fnc_anchorBroken;
				}], 
				true
			];
			private _captain = driver _boat;
			if(!isNull _captain) then {
				[_boat,"Anchor deployed..."] remoteExec ['vehicleChat'];
			};
			_boat setVariable ["MAZ_anchorObject",_anchorObject,true];
			_boat setVariable ["MAZ_anchorDeployed",true,true];
		};

		MAZ_fnc_stowAnchor = {
			params ["_boat"];
			private _rope = _boat getVariable "MAZ_anchorRope";
			private _anchorObject = _boat getVariable "MAZ_anchorObject";
			_anchorObject setMass (getMass _anchorObject / 750);
			private _eh = _boat getVariable ["MAZ_EH_ropeBreak_Anchor",-1];
			_boat removeEventHandler ["RopeBreak",_eh];
			ropeUnwind [_rope,5,-(ropeLength _rope),false];
			waitUntil {_anchorObject distance _boat < 3.5};
			deleteVehicle _anchorObject;
			ropeDestroy _rope;
			private _captain = driver _boat;
			if(!isNull _captain) then {
				[_boat,"Anchor stowed..."] remoteExec ['vehicleChat'];
			};
			_boat setVariable ["MAZ_anchorRope",objNull,true];
			_boat setVariable ["MAZ_anchorObject",objNull,true];
			_boat setVariable ["MAZ_anchorDeployed",false,true];
		};

		MAZ_fnc_anchorBroken = {
			params ["_boat","_rope","_anchor"];
			_boat setVariable ["MAZ_anchorBroken",true,true];
			deleteVehicle _anchor;
			ropeUnwind [_rope,5,-(ropeLength _rope) + 5,false];
			private _captain = driver _boat;
			if(!isNull _captain) then {
				[_boat,"Seems we broke the anchor..."] remoteExec ['vehicleChat'];
			};
		};

		if(isServer) then {
			waitUntil {!isNil "MAZ_EP_fnc_addFunctionToMainLoop"};
			["MAZ_fnc_boatAnchorServerLoop"] call MAZ_EP_fnc_addFunctionToMainLoop;
		};
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		["Boat Anchors","Boats will have the ability to deploy anchors which will prevent the vehicle from moving from its position and from drifting away when stopped."] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Boat Anchors System has been loaded! All boats now have anchors to prevent them from drifting!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	[] spawn MAZ_EP_fnc_boatAnchorsCarrier;
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