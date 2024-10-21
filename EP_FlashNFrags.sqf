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
if(missionNamespace getVariable ["MAZ_EP_flashNFragsEnabled",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Flash n' Frags already running!";};

private _varName = "MAZ_System_EnhancementPack_FNF";
private _myJIPCode = "MAZ_EPSystem_FNF_JIP";

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["Flash n' Frags","Whether to enable the Flash n' Frags system.","MAZ_EP_flashNFragsEnabled",true,"TOGGLE",[],"MAZ_FF"] call MAZ_EP_fnc_addNewSetting;
	["RGN Flashbangs","Whether to have RGNs be replaced with flashbangs.","MAZ_EP_flashbangsEnabled",true,"TOGGLE",[],"MAZ_FF"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_flashBangCarrier = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_FF"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};
		MAZ_flashbangExplode = {
			params ["_fbang"];
			[_fbang] spawn MAZ_flashBangCheckForExist;

			sleep 4.8;
			private _bangPosATL = getPosATL _fbang;
			private _bangPosASL = getPosASL _fbang;
			sleep 0.2;
			
			playSound3D [format ["A3\sounds_f\arsenal\explosives\grenades\GrenadeLight_midExp_0%1.wss",selectRandom [1,2,3,4]], _bangPosASL,false,_bangPosASL,5,1,100];

			private _bangLight = createVehicle["#lightpoint",_bangPosATL,[],0,"can_collide"];
			[_bangLight,[1,1,0.9]] remoteExec ['setLightAmbient'];
			[_bangLight,900] remoteExec ['setLightIntensity'];
			[_bangLight,[1,1,0.9]] remoteExec ['setLightColor'];
			[_bangLight,[0,0.29,17.79,4.69,9.64,0]] remoteExec ['setLightAttenuation'];
			[_bangLight,false] remoteExec ['setLightUseFlare'];
			[_bangLight,true] remoteExec ['setLightDayLight'];
			private _zeuses = allPlayers select {!isNull (getAssignedCuratorLogic _x)};
			private _nearestUnits = _bangPosATL nearEntities ["Man",15];
			{
				private _unit = _x; 
				private _vis1 = [objNull,"VIEW"] checkVisibility [eyePos _unit,_bangPosATL];
				private _vis2 = [objNull,"VIEW"] checkVisibility [eyePos _unit,_bangPosASL];

				comment "TODO : Make unit fall over when damage is greater than a certain amount (Hit)";
				comment "TODO : Make unit exit animation when killed (Killed)";
				if(((_vis1>0.03 || _vis2>0.03) && (_unit distance _bangPosATL) < 50) || (_unit distance _bangPosATL) < 1.5) then {
					if(isPlayer _unit) then {
						[[], {
							[] spawn MAZ_flashEffect;
						}] remoteExec ["spawn",_unit];
					} else {
						[[_unit], {
							params ["_unit"];
							[_unit,"Acts_CrouchingCoveringRifle01"]remoteExec["switchMove"];
							[_unit] call MAZ_FF_fnc_addUnitEventhandlers;
							_unit setVariable ["MAZ_flash_canExit",true,true];
							sleep 4+random 3;
							[_unit] call MAZ_FF_fnc_removeUnitEventhandlers;
							if(_unit getVariable ["MAZ_flash_canExit",true]) then {
								[_unit,"amovpknlmstpsraswrfldnon"] remoteExec ["switchMove"];
							};
						}] remoteExec ["spawn",owner _unit];
					};
				};
			}forEach (_nearestUnits - _zeuses);
			sleep .3;
			deleteVehicle _bangLight;
		};

		MAZ_flashBangCheckForExist = {
			params ["_fbang"];
			sleep 4.8;
			if(!isNull _fbang) then {deleteVehicle _fbang};
		};

		MAZ_flashEffect = {
			0 cutText["","WHITE OUT",0.1];
			playSound "combat_deafness";
			private _isEarplugsIn = player getVariable ['isEarplugsIn',false];
			if(!_isEarplugsIn) then {
				0 fadeSound 0.01;
				0 fadeRadio 0.01;
			};
			sleep 1;
			0 cutText["","WHITE IN",8];
			PP_wetD = ppEffectCreate ["WetDistortion",300];
			PP_wetD ppEffectEnable true;
			PP_wetD ppEffectAdjust [6.23,0.4,0.4,1,1,1,1,0.05,0.01,0.05,0.01,0.1,0.1,0.2,0.2];
			PP_wetD ppEffectCommit 0.2;
			if(!_isEarplugsIn) then {
				9 fadeSound 1;
				9 fadeRadio 1;
			};
			[player,"Acts_CrouchingCoveringRifle01"] remoteExec ["switchMove"]; 
			[player] call MAZ_FF_fnc_addUnitEventhandlers;
			sleep 4+random 3; 
			PP_wetD = ppEffectCreate ["WetDistortion",300];
			PP_wetD ppEffectEnable true;
			PP_wetD ppEffectAdjust [0,0,0,1,1,1,1,0.05,0.01,0.05,0.01,0.1,0.1,0.2,0.2];
			PP_wetD ppEffectCommit 15;
			[player] call MAZ_FF_fnc_removeUnitEventhandlers;
			if(player getVariable ["MAZ_flash_canExit",true]) then {
				[player,"amovpknlmstpsraswrfldnon"] remoteExec ["switchMove"];
			};
		};

		MAZ_fnc_setRagdoll = {
			params[
				["_unit",objNull,[objNull]],
				["_force",[0,0,0],[[]],[3]],
				["_position","spine1",["string"]]
			];

			if(!(_unit isKindOf "Man"))exitWith{};

			private _damageState = isDamageAllowed _unit;
			if(_damageState)then{_unit allowDamage false};

			private _pos =  (AGLtoASL(_unit modelToWorldVisual (_unit selectionPosition _position))) ;
			private _collider = "Land_Can_V3_F" createVehicleLocal [0,0,0];
			_collider setMass 10^10;
			_collider setPosASL _pos;
			_collider setVelocity _force;

			[_collider,_damageState,_unit] spawn {
				params ["_collider","_damageState","_unit"];
				sleep 0.1;
				deleteVehicle _collider;
				if(_damageState)then{_unit allowDamage true};
			};
		};

		MAZ_FF_fnc_addUnitEventhandlers = {
			params ["_unit"];
			private _ehHit = _unit addEventHandler ["Dammaged",{
				params ["_unit", "_selection", "_damage", "_hitIndex", "_hitPoint", "_shooter", "_projectile"];
				if((damage _unit > 0.7 && alive _unit) || _damage > 0.2) then {
					_unit setVariable ["MAZ_flash_canExit",false,true];
					private _beh = behaviour _unit;
					_unit setBehaviour "CARELESS";
					[_unit,"amovpknlmstpsraswrfldnon"] remoteExec ["switchMove"];
					[_unit,[0,0,6]] call MAZ_fnc_setRagdoll;
					[_unit,_beh] spawn {
						params ["_unit","_beh"];
						sleep 0.1;
						_unit setBehaviour _beh;
						[_unit] call MAZ_FF_fnc_removeUnitEventhandlers;
					};
				};
			}];
			private _ehKilled = _unit addEventHandler ["Killed", {
				params ["_unit", "_killer", "_instigator", "_useEffects"];
				if(animationState _unit == "Acts_CrouchingCoveringRifle01") then {
					_unit setVariable ["MAZ_flash_canExit",false,true];
					[_unit,"amovpknlmstpsraswrfldnon"] remoteExec ["switchMove"];
					[_unit] call MAZ_FF_fnc_removeUnitEventhandlers;
				};
			}];
			_unit setVariable ["MAZ_flash_kill",_ehKilled];
			_unit setVariable ["MAZ_flash_hit",_ehHit];
		};

		MAZ_FF_fnc_removeUnitEventhandlers = {
			params ["_unit"];
			private _ehKilled = _unit getVariable ["MAZ_flash_kill",-420];
			private _ehHit = _unit getVariable ["MAZ_flash_hit",-420];
			if(_ehKilled != -420) then {
				_unit removeEventhandler ["Killed",_ehKilled];
				_unit setVariable ["MAZ_flash_kill",nil];
			};
			if(_ehHit != -420) then {
				_unit removeEventHandler ["Dammaged",_ehHit];
				_unit setVariable ["MAZ_flash_hit",nil];
			};
		};

		[] spawn {
			waitUntil {uisleep 0.1;!isNull (findDisplay 46) && alive player};
			sleep 0.1;

			if(!isNil "MAZ_EH_FiredMan_FlashAndFrag") then {
				player removeEventHandler ["FiredMan",MAZ_EH_FiredMan_FlashAndFrag];
			};
			MAZ_EH_FiredMan_FlashAndFrag = player addEventHandler ["FiredMan",{
				params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
				if(!MAZ_EP_flashNFragsEnabled) exitWith {};
				if(_magazine == "MiniGrenade" && MAZ_EP_flashbangsEnabled) then {
					[_projectile] spawn MAZ_flashbangExplode;
				};
				if(_magazine == "HandGrenade") then {
					[_projectile] spawn {
						params ["_grenade"];
						_numBullets = [25,45] call BIS_fnc_randomInt;

						sleep 4.8;
						private _bangPosATL = getPosATL _grenade;
						private _bangPosASL = getPosASL _grenade;
						private _vectorDir = vectorDir _grenade;
						private _vectorUp = vectorUp _grenade;
						private _grenadeDir = getDir _grenade;
						sleep 0.2;

						for "_i" from 0 to _numBullets do {
							private _fragment = createVehicle ["B_45ACP_Ball", [0,0,0], [], 0, "CAN_COLLIDE"];
							
							_fragment setPosATL (_bangPosATL vectorAdd [0,0,0.1]);

							_fragment setDir (random 360);
							[_fragment, random 50, random 40] call BIS_fnc_setPitchBank;

							_fragment setVelocityModelSpace [0, 20 + (random 15), 0];
						};
					};
				};
			}];
		};
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		[
			"Flash n' Frags", 
			"Replaces the otherwise useless RGN grenades with flashbangs that will stun players and AI who are looking at the flash or within a certain distance. Adds physical fragmentation to RGO grenades, making them more lethal and scarier.",
			[
				"RGNs are replaced with flashbang grenades",
				"Adds physical fragmentation to RGO grenades that can deal extra damage"
			]	
		] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Flash n' Frags System has been loaded! Watch out for extra fragmentation from grenades and flashbangs!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	[] spawn MAZ_flashBangCarrier;
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