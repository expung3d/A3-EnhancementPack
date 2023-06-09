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

MAZ_EP_flashNFragsEnabled = true;
publicVariable "MAZ_EP_flashNFragsEnabled";

private _value = (str {
	MAZ_flashBangCarrier = {
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
			private _nearestUnits = _bangPosATL nearEntities ["Man",15];
			{
				private _unit = _x; 
				private _vis1 = [objNull,"VIEW"] checkVisibility [eyePos _unit,_bangPosATL];
				private _vis2 = [objNull,"VIEW"] checkVisibility [eyePos _unit,_bangPosASL];
				if(((_vis1>0.03 || _vis2>0.03) && (_unit distance _bangPosATL) < 50) || (_unit distance _bangPosATL) < 1.5)then{
					if(isPlayer _unit)then{
						[_unit] spawn MAZ_flashbangFlashed;
					} else {
						[[_unit], {
							params ["_unit"];
							[_unit,"Acts_CrouchingCoveringRifle01"]remoteExec["switchMove",0];
							sleep 4+random 3;
							[_unit,""]remoteExec["switchMove",0];
							[_unit,"Crouch"] remoteExec ["playAction",0];
						}] remoteExec ["spawn",_unit];
					};
				};
			}forEach _nearestUnits;
			sleep .3;
			deleteVehicle _bangLight;
		};

		MAZ_flashBangCheckForExist = {
			params ["_fbang"];
			sleep 4.8;
			if(!isNull _fbang) then {deleteVehicle _fbang};
		};

		MAZ_flashbangFlashed = {
			params ["_unit"];
			if(isPlayer _unit)then{
				[[], {
					[] spawn MAZ_flashEffect;
				}] remoteExec ["spawn",_unit];
			};
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
			[player,"Acts_CrouchingCoveringRifle01"] remoteExec ["switchMove",0]; 
			sleep 4+random 3; 
			PP_wetD = ppEffectCreate ["WetDistortion",300];
			PP_wetD ppEffectEnable true;
			PP_wetD ppEffectAdjust [0,0,0,1,1,1,1,0.05,0.01,0.05,0.01,0.1,0.1,0.2,0.2];
			PP_wetD ppEffectCommit 15;
			[player,""] remoteExec ["switchMove",0];
			[player,"Crouch"] remoteExec ["playAction",0];
		};
		if(!isNil "MAZ_EH_FiredMan_FlashAndFrag") then {
			player removeEventHandler ["FiredMan",MAZ_EH_FiredMan_FlashAndFrag];
		};
		MAZ_EH_FiredMan_FlashAndFrag = player addEventHandler ["FiredMan",{
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
			if(MAZ_EP_flashNFragsEnabled) then {
				if(_magazine == "MiniGrenade") then {
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
			};
		}];
	};
	if(!isNil "MAZ_EP_fnc_addDiaryRecord") then {
		["Flash n' Frags", "Replaces the otherwise useless RGN grenades with flashbangs that will stun players and AI who are looking at the flash or within a certain distance. Adds physical fragmentation to RGO grenades, making them more lethal and scarier."] call MAZ_EP_fnc_addDiaryRecord;
	};
	call MAZ_flashBangCarrier;
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