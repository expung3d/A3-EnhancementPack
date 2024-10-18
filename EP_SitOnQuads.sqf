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
if(missionNamespace getVariable ["MAZ_EP_sitOnQuadbikes",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Sit On Quadbikes already running!";};

private _varName = "MAZ_System_EnhancementPack_SOQ";
private _myJIPCode = "MAZ_EPSystem_SOQ_JIP";

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["Sit On Quadbikes","Whether to enable the Sit on Quadbikes system.","MAZ_EP_sitOnQuadbikes",true,"TOGGLE",[],"MAZ_SOQ"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_EP_fnc_quadbikesCarrier = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_SOQ"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};
		MAZ_fnc_quadbikeServerLoop = {
			if(time < (missionNamespace getVariable ["MAZ_EP_SOQ_setupLoopTime",time])) exitWith {};
			[] call MAZ_fnc_quadbikeServerInit;
			missionNamespace setVariable ["MAZ_EP_SOQ_setupLoopTime",time + 0.1];
		};
		
		MAZ_fnc_quadbikeServerInit = {
			{
				if(!(typeOf _x isKindOf "Quadbike_01_base_F")) then {continue};
				private _isSetup = _x getVariable ["MAZ_quad_isSetup",false];
				if(!_isSetup) then {
					_x setVariable ["MAZ_sittingOnFront",objNull,true];
					_x setVariable ["MAZ_quad_isSetup",true];
					[_x, {
						waitUntil {!isNil "MAZ_fnc_sitOnQuadbikeAction"};
						_this call MAZ_fnc_sitOnQuadbikeAction;
					}] remoteExec ['spawn',0,_x];
				};
			}forEach vehicles;
		};

		MAZ_fnc_canSitOnQuadbike = {
			params ["_quad","_caller"];
			if(!MAZ_EP_sitOnQuadbikes) exitWith {false};
			private _sitter = _quad getVariable ["MAZ_sittingOnFront",objNull];
			if(_quad distance _caller > 2.75) exitWith {false};
			if(_caller in _quad) exitWith {false};
			if(!isNull _sitter) exitWith {false};
			true
		};

		MAZ_fnc_sitOnQuadbikeAction = {
			params ["_quad"];
			private _actionId = _quad addAction [
				"Get in Quad Bike Sit on Front",
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
					[_target] spawn MAZ_fnc_sitOnQuadbike;
				},
				nil,
				5.15,
				true,
				true,
				"",
				"[_target,_this] call MAZ_fnc_canSitOnQuadbike"
			];
			_quad setUserActionText [_actionId,"Get in Quad Bike Sit on Front","<img size='1.8' image='a3\ui_f\data\igui\cfg\actions\getincargo_ca.paa' />"];
		};

		MAZ_fnc_sitOnQuadbike = {
			params ["_quad"];
			_quad setVariable ["MAZ_sittingOnFront",player,true];
			player setVariable ["MAZ_quad_launcher",secondaryWeapon player];
			player removeWeapon secondaryWeapon player;
			player attachTo [_quad,[0,0.75,-0.5]];
			player action ['SWITCHWEAPON',player,player,-1];
			[player,"bench_Heli_Light_01_get_in"] remoteExec ['switchMove'];
			sleep 3.9;
			[player,"Acts_HeliCargoTalking_loop"] remoteExec ["switchMove",0];
			[] spawn MAZ_fnc_quadBikeCam;
			MAZ_standUpFromQuadbike = (findDisplay 46) displayAddEventHandler ["KeyDown", {
				if(_this select 1==200) then {
					call MAZ_fnc_getOffQuad;
				};
			}];

			MAZ_EH_AnimChanged_Quad = player addEventHandler ["AnimChanged", {
				params ["_unit", "_anim"];
				[_unit,"Acts_HeliCargoTalking_loop"] remoteExec ["switchMove",0];
			}];
			titleText ["<t color='FFFFFF' size='1.5'>Press UP ARROW KEY to get off.</t>","PLAIN DOWN",2,true,true];
			[] spawn MAZ_fnc_dismountIfDead;
		};

		MAZ_fnc_dismountIfDead = {
			waitUntil {
				sleep 0.5;
				lifeState player == "INCAPACITATED" ||
				!alive player
			};
			call MAZ_fnc_getOffQuad;
		};

		MAZ_fnc_getOffQuad = {
			private _quad = attachedTo player;
			_quad setVariable ['MAZ_sittingOnFront',objNull,true];
			detach player;
			player setPos [(getPos player select 0),(getPos player select 1)+1,(getPos player select 2)];
			[player,''] remoteExec ['switchMove',0];
			private _plyrLauncher = player getVariable ['MAZ_quad_launcher',""];
			player addWeapon _plyrLauncher;
			player setVariable ['MAZ_quad_launcher',nil];
			(findDisplay 46) displayRemoveEventHandler ['KeyDown',MAZ_standUpFromQuadbike];
			player removeEventHandler ["AnimChanged",MAZ_EH_AnimChanged_Quad];
			[] spawn MAZ_fnc_quadBikeCamKill;
		};

		MAZ_fnc_quadBikeCam = {
			private _cam = "camera" camCreate getPosATL player;
			player setVariable ["MAZ_quad_cam",_cam];
			MAZ_MEH_EachFrame_quadCam = addMissionEventHandler ["EachFrame",{
				_thisArgs params ["_cam"];
				[_cam] call MAZ_fnc_updateQuadCam;
			},[_cam]];
		};

		MAZ_fnc_updateQuadCam = {
			params ["_cam"];
			private _targetPos = player getPos [9,getDir player];
			_cam camSetTarget player;
			_cam camSetRelPos [0.75, -2.6, 0.9];
			_cam camCommit 0;
			_cam camSetTarget (_targetPos vectorAdd [0,0,1.5]);
			_cam camCommit 0;
			if(isNull (findDisplay 312)) then {
				_cam cameraEffect ["internal", "back"];
			};
		};

		MAZ_fnc_quadBikeCamKill = {
			private _camera = player getVariable "MAZ_quad_cam";
			if(isNil "_camera") exitWith {};
			_camera cameraEffect ["terminate", "back"];
			camDestroy _camera;
			player setVariable ["MAZ_quad_cam",nil];
			removeMissionEventHandler ["EachFrame",MAZ_MEH_EachFrame_quadCam];
		};

		if(isServer) then {
			waitUntil {!isNil "MAZ_EP_fnc_addFunctionToMainLoop"};
			["MAZ_fnc_quadbikeServerLoop"] call MAZ_EP_fnc_addFunctionToMainLoop;
		};
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		["Sit on Quadbikes", "Allows players to sit on the front of quadbikes as an additional seat."] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Sit on Quadbikes System has been loaded! Now you can third wheel on a quadbike!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	[] spawn MAZ_EP_fnc_quadbikesCarrier;
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