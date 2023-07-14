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
if(missionNamespace getVariable ["MAZ_EP_enhancedNightVisionEnabled",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Enhanced Night Vision already running!";};

private _varName = "MAZ_System_EnhancementPack_ENV";
private _myJIPCode = "MAZ_EPSystem_ENV_JIP";

MAZ_EP_enhancedNightVisionEnabled = true;
publicVariable "MAZ_EP_enhancedNightVisionEnabled";

MAZ_ENV_allowThirdPersonVehicles = true;
publicVariable "MAZ_ENV_allowThirdPersonVehicles";

private _value = (str {
	MAZ_EP_fnc_enhancedNightVisionCarrier = {
		MAZ_ENV_whitelistedNVGOptics = [
			"optic_Aco",
			"optic_ACO_grn",
			"optic_Aco_smg",
			"optic_ACO_grn_smg",
			"optic_Holosight",
			"optic_Holosight_smg",
			"optic_Holosight_blk_F",
			"optic_Holosight_khk_F",
			"optic_Holosight_smg_blk_F",
			"optic_Holosight_smg_khk_F",
			"optic_NVS",
			"optic_Nightstalker",
			"optic_tws",
			"optic_tws_mg",
			"optic_Holosight_lush_F",
			"optic_Holosight_arid_F",
			"optic_MRCO",
			"optic_ico_01_camo_f",
			""
		];

		MAZ_ENV_greylistedNVGOptics = [
			"optic_Hamr","Hamr2Collimator",
			"optic_Hamr_khk_F","Hamr2Collimator",
			"optic_ERCO_blk_F","ARCO2collimator",
			"optic_ERCO_khk_F","ARCO2collimator",
			"optic_ERCO_snd_F","ARCO2collimator",
			"optic_Arco","ARCO2collimator",
			"optic_Arco_arid_F","ARCO2collimator",
			"optic_Arco_blk_F","ARCO2collimator",
			"optic_Arco_ghex_F","ARCO2collimator",
			"optic_Arco_lush_F","ARCO2collimator",
			"optic_Arco_AK_arid_F","ARCO2collimator",
			"optic_Arco_AK_blk_F","ARCO2collimator",
			"optic_Arco_AK_lush_F","ARCO2collimator",
			"optic_SOS","Iron",
			"optic_SOS_khk_F","Iron",
			"optic_KHS_blk","Iron",
			"optic_KHS_hex","Iron",
			"optic_KHS_tan","Iron",
			"optic_DMS","Iron",
			"optic_DMS_ghex_F","Iron",
			"optic_DMS_weathered_F","Iron",
			"optic_DMS_weathered_Kir_F","Iron",
			"optic_AMS","Iron",
			"optic_AMS_khk","Iron",
			"optic_AMS_snd","Iron"
		];

		MAZ_ENV_strobeCompatibleHelmets = [
			"H_HelmetHBK_headset_F",
			"H_HelmetHBK_chops_F",
			"H_HelmetHBK_ear_F",
			"H_HelmetHBK_F",
			"H_HelmetB",
			"H_HelmetB_black",
			"H_HelmetB_desert",
			"H_HelmetB_grass",
			"H_HelmetB_sand",
			"H_HelmetB_snakeskin",
			"H_HelmetB_tna_F",
			"H_HelmetB_plain_wdl",
			"H_HelmetSpecB",
			"H_HelmetSpecB_blk",
			"H_HelmetSpecB_paint2",
			"H_HelmetSpecB_paint1",
			"H_HelmetSpecB_sand",
			"H_HelmetSpecB_snakeskin",
			"H_HelmetB_Enh_tna_F",
			"H_HelmetSpecB_wdl",
			"H_HelmetB_light",
			"H_HelmetB_light_black",
			"H_HelmetB_light_desert",
			"H_HelmetB_light_grass",
			"H_HelmetB_light_sand",
			"H_HelmetB_light_snakeskin",
			"H_HelmetB_Light_tna_F",
			"H_HelmetB_light_wdl",
			"H_HelmetIA",
			"H_HelmetB_TI_tna_F",
			"H_HelmetB_TI_arid_F"
		];

		MAZ_ENV_fnc_createIRIlluminator = {
			params [["_diffuse",false,[false]]];
			private _light = player getVariable ["MAZ_ENV_irIllum",objNull];
			if(!isNull _light) then {
				deleteVehicle _light;
				player setVariable ["MAZ_ENV_irIllum",objNull,true];
			};
			private _intensity = 5000;
			if(_diffuse) then {
				_intensity = _intensity * 0.25;
			};
			_light = "#lightreflector" createVehicle [0,0,0];
			player setVariable ["MAZ_ENV_irIllum",_light,true];
			[[_light,_intensity], {
				params ["_light","_intensity"];
				[_light,false] remoteExec ["setLightDayLight",0,_light];
				[_light,true] remoteExec ["setLightIR",0,_light];
				[_light,[1,1,1]] remoteExec ["setLightAmbient",0,_light];
				[_light,false] remoteExec ["setLightUseFlare",0,_light];
				[_light,_intensity] remoteExec ["setLightIntensity",0,_light];
				[_light,[30,3,1.5]] remoteExec ["setLightConePars",0,_light];
			}] remoteExec ['spawn',0,_light];
			_light attachTo [player,[0.036,0.2,0.1],"proxy:\a3\characters_f\proxies\weapon.001",true];
			comment 'player modelToWorld  (player selectionPosition "proxy:\a3\characters_f\proxies\weapon.001")';
			_light spawn {
				private _oldDiffuseMode = player getVariable ["MAZ_ENV_irIllumDiffuse",false];
				while {!(isNull (player getVariable ["MAZ_ENV_irIllum",objNull]))} do {
					private _currentWep = currentWeapon player;
					private _attachments = player weaponAccessories _currentWep;
					if !("acc_pointer_IR" in _attachments) exitWith {
						call MAZ_ENV_fnc_deleteIRIlluminator;
					};
					private _diffuseMode = player getVariable ["MAZ_ENV_irIllumDiffuse",false];
					if(_diffuseMode != _oldDiffuseMode) then {
						_oldDiffuseMode = _diffuseMode;
						private _intensity = 5000;
						if(_oldDiffuseMode) then {
							_intensity = _intensity * 0.25;
						};
						[[_this,_intensity], {
							params ["_light","_intensity"];
							[_light,false] remoteExec ["setLightDayLight",0,_light];
							[_light,true] remoteExec ["setLightIR",0,_light];
							[_light,[1,1,1]] remoteExec ["setLightAmbient",0,_light];
							[_light,false] remoteExec ["setLightUseFlare",0,_light];
							[_light,_intensity] remoteExec ["setLightIntensity",0,_light];
							[_light,[30,3,1.5]] remoteExec ["setLightConePars",0,_light];
						}] remoteExec ['spawn',0,_this];
					};
					sleep 0.1;
				};
			};
		};

		MAZ_ENV_fnc_deleteIRIlluminator = {
			private _light = player getVariable ["MAZ_ENV_irIllum",objNull];
			if(!isNull _light) then {
				deleteVehicle _light;
				player setVariable ["MAZ_ENV_irIllum",objNull,true];
			};
		};

		MAZ_ENV_fnc_toggleIRIlluminator = {
			private _currentWep = currentWeapon player;
			private _attachments = player weaponAccessories _currentWep;
			if !("acc_pointer_IR" in _attachments) exitWith {};
			private _light = player getVariable ["MAZ_ENV_irIllum",objNull];
			if(!isNull _light) then {
				call MAZ_ENV_fnc_deleteIRIlluminator;
			} else {
				private _diffuseMode = player getVariable ["MAZ_ENV_irIllumDiffuse",false];
				[_diffuseMode] call MAZ_ENV_fnc_createIRIlluminator;
			};
		};

		MAZ_ENV_fnc_toggleIRIlluminatorDiffuseMode = {
			private _diffuseMode = player getVariable ["MAZ_ENV_irIllumDiffuse",false];
			player setVariable ["MAZ_ENV_irIllumDiffuse",!_diffuseMode];
		};

		MAZ_ENV_fnc_createAdminLight = {
			params [["_ir",false,[false]]];
			private _light = player getVariable ["MAZ_ENV_adminLight",objNull];
			if(!isNull _light) then {
				deleteVehicle _light;
			};
			private _showInDay = true;
			private _lightColor = [0.5,0,0];
			private _intensity = 50;
			if(_ir) then {
				_showInDay = false;
				_lightColor = [1,1,1];
				_intensity = 20;
			};
			_light = "#lightreflector" createVehicle [0,0,0];
			player setVariable ["MAZ_ENV_adminLight",_light,true];
			[_light,_showInDay] remoteExec ["setLightDayLight",0,_light];
			[_light,_ir] remoteExec ["setLightIR",0,_light];
			[_light,_lightColor] remoteExec ["setLightAmbient",0,_light];
			[_light,_intensity] remoteExec ["setLightIntensity",0,_light];
			[_light,[2,4,4,0,9,10]] remoteExec ["setLightAttenuation",0,_light];
			[_light,[45,10,2.5]] remoteExec ["setLightConePars",0,_light];
			_light attachTo [player, [0.3,-0.5,0.15], "head", true];
			_light setDir -20;
		};

		MAZ_ENV_fnc_attachStrobeLightToHelmet = {
			private _headGear = headgear player;
			if (!(_headGear in MAZ_ENV_strobeCompatibleHelmets)) exitwith {["Not wearing a compatible helmet.","addItemFailed"] call MAZ_EP_fnc_systemMessage};			
			private _currentLight = currentThrowable player select 0; 
			private _currentLightClass = switch (_currentLight) do
			{
				case "B_IR_Grenade": {"B_IRStrobe"};
				case "O_R_IR_Grenade";
				case "O_IR_Grenade": {"O_IRStrobe"};
				case "I_E_IR_Grenade";
				case "I_IR_Grenade": {"I_IRStrobe"};
				default {""}
			}; 
			if (_currentLightClass == "") exitWith {["Cannot attach your current grenade."] call MAZ_EP_fnc_systemMessage};
			private _attachedLight = _currentLightClass createVehicle position player;
			_attachedLight attachto [player, [0,-0.08,.125], 'pilot',true];
			player removeItem _currentLight;
		};
		
		MAZ_pointShootOnKeyDown = {
			params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];
			if(_key != 42) exitWith {};
			if (!(missionNamespace getVariable ["MAZ_TAG_heldDown",false]) && !(missionNamespace getVariable ["MAZ_TAG_holdBreathCooldown",false])) then {
				MAZ_TAG_heldDown = true;
				player setCustomAimCoef 0.3;
				MAZ_holdBreathTime = time;
			};
			if((time - MAZ_holdBreathTime) > 5 && !(missionNamespace getVariable ["MAZ_TAG_holdBreathCooldown",false])) then {
				player setCustomAimCoef 1;
				MAZ_TAG_holdBreathCooldown = true;
				MAZ_TAG_heldDown = false;
				0 = [] spawn {
					sleep (4 + (random 3));
					MAZ_TAG_holdBreathCooldown = false;
					player setCustomAimCoef 1;
				};
			};
		};

		MAZ_pointShootOnKeyUp = {
			params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];
			if(_key != 42) exitWith {};
			if (missionNamespace getVariable ["MAZ_TAG_heldDown",false]) then {
				player setCustomAimCoef 1;
				missionNamespace setVariable ["MAZ_TAG_heldDown",false];
			};
		};

		MAZ_DEH_KeyDown_ENV_pointShoot = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call MAZ_pointShootOnKeyDown;"]; 
		MAZ_DEH_KeyUp_ENV_pointShoot = (findDisplay 46) displayAddEventHandler ["KeyUp", "_this call MAZ_pointShootOnKeyUp;"]; 

		addMissionEventHandler ["Draw3D", {
			call {
				comment "
					IF player tries to enter third person outside of a vehicle THEN switch internal
					IF player tries to enter third person in vehicle without setting THEN switch internal
				";
				if (
					(currentVisionMode player) != 0 && 
					(cameraView == "External") && 
					currentWeapon player != "" &&
					(
						vehicle player == player || 
						((vehicle player != player) && !MAZ_ENV_allowThirdPersonVehicles)
					)
				) exitWith {
					player switchCamera "INTERNAL";
				};

				comment "
					IF optic not whitelisted but greylisted check optic mode THEN switch optic mode
					IF player tries to aim with improper sight on dual optic THEN switch optic mode
				";
				if (
					cameraOn == player && 
					(currentVisionMode player) != 0 && 
					!((primaryWeaponItems player) select 2 in MAZ_ENV_whitelistedNVGOptics) && 
					((primaryWeaponItems player) select 2 in MAZ_ENV_greylistedNVGOptics) &&
					(player getOpticsMode 0 != MAZ_ENV_greylistedNVGOptics select ((MAZ_ENV_greylistedNVGOptics find ((primaryWeaponItems player) select 2)) + 1)) &&
					currentWeapon player == primaryWeapon player &&
					cameraView != "INTERNAL"
				) exitWith {
					player setOpticsMode (MAZ_ENV_greylistedNVGOptics select ((MAZ_ENV_greylistedNVGOptics find ((primaryWeaponItems player) select 2)) + 1))
				};

				comment "
					IF weapon optic not whitelisted OR greylisted THEN force internal
				";
				if (
					cameraOn == player && 
					(currentVisionMode player) != 0 && 
					!((primaryWeaponItems player) select 2 in MAZ_ENV_whitelistedNVGOptics) && 
					!((primaryWeaponItems player) select 2 in MAZ_ENV_greylistedNVGOptics) &&
					currentWeapon player == primaryWeapon player &&
					cameraView != "INTERNAL"
				) exitWith {
					player switchCamera "INTERNAL"
				};
			};
		}];

		addMissionEventHandler ["Draw3D", {
			call {
				if(currentVisionMode player == 0) then {
					if(!isNil "MAZ_PP_FilmGrain_NVG") then {	
						MAZ_PP_FilmGrain_NVG ppEffectEnable false;
					};
				};
				if(currentVisionMode player != 0) then {
					if(isNil "MAZ_PP_FilmGrain_NVG") then {
						MAZ_PP_FilmGrain_NVG = ppEffectCreate ["FilmGrain",2000];
					};
					MAZ_PP_FilmGrain_NVG ppEffectEnable true;
					MAZ_PP_FilmGrain_NVG ppEffectForceInNVG true;
					MAZ_PP_FilmGrain_NVG ppEffectAdjust [0.42,0.71,0.2,0.57,0.24,true];
					MAZ_PP_FilmGrain_NVG ppEffectCommit 0;
				};
				if(currentVisionMode player == 1 && ((assignedItems player) findIf {_x in ["NVGogglesB_blk_F","NVGogglesB_grn_F","NVGogglesB_gry_F"]}) != -1) then {
					if(isNil "MAZ_PP_ColorCorrect_NVG") then {
						MAZ_PP_ColorCorrect_NVG = ppEffectCreate ["ColorCorrections",1500];
					};
					MAZ_PP_ColorCorrect_NVG ppEffectForceInNVG true;
					MAZ_PP_ColorCorrect_NVG ppEffectEnable true;
					MAZ_PP_ColorCorrect_NVG ppEffectAdjust [
						1.1, 
						0.7, 
						0, 
						[0,0.05,0.05,0], 
						[0.25,0.75,0.8,0], 
						[1,1,1,0],
						[0,0,0,0,0,0,0]
					];
					MAZ_PP_ColorCorrect_NVG ppEffectCommit 0;
				} else {
					MAZ_PP_ColorCorrect_NVG ppEffectEnable false;
				};
			};
		}];

		MAZ_EH_VisionModeChanged_ENV = player addEventHandler ["VisionModeChanged", {
			params ["_person", "_visionMode", "_TIindex", "_visionModePrev", "_TIindexPrev", "_vehicle", "_turret"];
			if(_visionModePrev == 0) then {
				playSound3D ['A3\ui_f_curator\data\sound\CfgSound\visionMode.wss', _person,false,getPosASL _person,5,1,5];
			};
			if(_visionMode > 1) then {
				player action ["nvGogglesOff", player];
			};
		}];

		0 = [] spawn {
			waitUntil {uisleep 0.1;!isNull (findDisplay 46) && alive player};
			sleep 0.1;
			waitUntil {!isNil "MAZ_fnc_newKeybind"};
			MAZ_Key_ENV_ToggleIRIlluminator = ["Toggle IR Illuminator","Turn on or off the IR Illuminator.",38,{call MAZ_ENV_fnc_toggleIRIlluminator;},false,true] call MAZ_fnc_newKeybind;
			MAZ_Key_ENV_ToggleIRIlluminatorDiffuseMode = ["Toggle IR Diffuser","Turn on or off the IR diffuser.",38,{call MAZ_ENV_fnc_toggleIRIlluminatorDiffuseMode;},false,false,true] call MAZ_fnc_newKeybind;
			comment 'MAZ_Key_ENV_AttachLight = ["Attach Light","Attach current selected IR or chem Light to helmet.",35,{[] spawn MAZ_ENV_fnc_attachStrobeLightToHelmet;},false,false,true] call MAZ_fnc_newKeybind'; 
		};
	};
	if(!isNil "MAZ_EP_fnc_addDiaryRecord") then {
		["Enhanced Nightvision", "This makes NVGs more realistic by adding extra film grain when using them and preventing the use of magnified optics. With NVGs you will still be able to use 1x optics, however, zoomed optics aren't available. In addition, you will be forced into first person when using NVGs. Also, ENVGs have white phosphor tubes... because its cool."] call MAZ_EP_fnc_addDiaryRecord;
	};
	if(!isNil "MAZ_EP_fnc_createNotification") then {
		[
			"Enhanced Night Vision System has been loaded! Night Vision has more grain and you have IR illuminators now!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	call MAZ_EP_fnc_enhancedNightVisionCarrier;
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