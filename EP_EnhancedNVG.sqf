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

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["[ENV] Enhanced Night Vision","Whether to enable the Enhanced Night Vision system.","MAZ_EP_enhancedNightVisionEnabled",true,"TOGGLE",[],"MAZ_ENV"] call MAZ_EP_fnc_addNewSetting;
	["[ENV] 3PP in Vehicles","Whether to allow players to use 3rd person in vehicles with night vision.","MAZ_ENV_allowThirdPersonVehicles",true,"TOGGLE",[],"MAZ_ENV"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_EP_fnc_enhancedNightVisionCarrier = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_ENV"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};
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
			"H_HelmetB_camo",
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

		MAZ_ENV_fnc_isNightTime = {
			([date] call BIS_fnc_sunriseSunsetTime) params ["_sunrise","_sunset"];
			dayTime > _sunset || dayTime < _sunrise
		};

		MAZ_ENV_fnc_adjustAIAtNightServerLoop = {
			while {MAZ_EP_enhancedNightVisionEnabled} do {
				waitUntil {uiSleep 1; call MAZ_ENV_fnc_isNightTime;};
				call MAZ_ENV_fnc_makeAIDumbAtNight;
				waitUntil {uiSleep 1; !(call MAZ_ENV_fnc_isNightTime);};
				call MAZ_ENV_fnc_makeAISmartAtDay;
			};
		};

		MAZ_ENV_fnc_makeAIDumbAtNight = {
			{
				private _unit = _x;
				{
					private _skillValue = _unit skill _x;
					_unit setSkill [_x,_skillValue / 2];
				}forEach ["aimingAccuracy","aimingShake","aimingSpeed","spotDistance","spotTime","courage","reloadSpeed","commanding"];
				_unit setVariable ["MAZ_ENV_dumbAtNight",true];
			}forEach (allUnits - allPlayers);
		};

		MAZ_ENV_fnc_makeAISmartAtDay = {
			{
				if !(_x getVariable ["MAZ_ENV_dumbAtNight",false]) then {continue};
				private _unit = _x;
				{
					private _skillValue = _unit skill _x;
					_unit setSkill [_x,_skillValue * 2];
				}forEach ["aimingAccuracy","aimingShake","aimingSpeed","spotDistance","spotTime","courage","reloadSpeed","commanding"];
				_unit setVariable ["MAZ_ENV_dumbAtNight",false];
			}forEach (allUnits - allPlayers);
		};

		MAZ_ENV_fnc_canEnter3PP = {
			if(!MAZ_EP_enhancedNightVisionEnabled) exitWith {true};
			if((currentVisionMode player) == 0) exitWith {true};
			private _veh = vehicle player;
			if(_veh == player) exitWith {false};
			if(MAZ_ENV_allowThirdPersonVehicles) exitWith {true};
			false;
		};

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
				_light setLightDayLight false;
				_light setLightIR true;
				_light setLightAmbient [1,1,1];
				_light setLightUseFlare false;
				_light setLightIntensity _intensity;
				_light setLightConePars [30,3,1.5];
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
							_light setLightDayLight false;
							_light setLightIR true;
							_light setLightAmbient [1,1,1];
							_light setLightUseFlare false;
							_light setLightIntensity _intensity;
							_light setLightConePars [30,3,1.5];
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
			playSound3D ['a3\sounds_f_epb\weapons\noise\switch_mod_01.wss', player,false,getPosASL player,5,1,3];
		};

		MAZ_ENV_fnc_toggleIRIlluminatorDiffuseMode = {
			private _currentWep = currentWeapon player;
			private _attachments = player weaponAccessories _currentWep;
			if !("acc_pointer_IR" in _attachments) exitWith {};
			private _diffuseMode = player getVariable ["MAZ_ENV_irIllumDiffuse",false];
			player setVariable ["MAZ_ENV_irIllumDiffuse",!_diffuseMode];
			playSound3D ['a3\sounds_f_epb\weapons\noise\switch_mod_01.wss', player,false,getPosASL player,5,1,3];
		};

		MAZ_ENV_fnc_toggleLaserSound = {
			private _currentWep = currentWeapon player;
			private _attachments = player weaponAccessories _currentWep;
			if !("acc_pointer_IR" in _attachments || "acc_flashlight" in _attachments) exitWith {};
			playSound3D ['a3\sounds_f_epb\weapons\noise\switch_mod_01.wss', player,false,getPosASL player,5,1,3];
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
			if(!alive player) exitWith {};
            if(vehicle player != player) exitwith {["Cannot attach IR Strobes while in vehicles"] call MAZ_EP_fnc_systemMessage};
			if (!isNil "MAZ_ENV_attachedStrobe" && {!isNull MAZ_ENV_attachedStrobe}) exitwith {
				call MAZ_ENV_fnc_deleteAttachedStrobeLight;
				call MAZ_ENV_fnc_removeStrobeEH;
				["You turned off your IR Strobe."] call MAZ_EP_fnc_systemMessage;
                playSound3D ['A3\Sounds_F_Orange\MissionSFX\Orange_Start_Sim.wss', player,false,getPosASL player,5,1,7.5,1];
				player addItem MAZ_ENV_strobeThrowable;
			};
			if (!((headgear player) in MAZ_ENV_strobeCompatibleHelmets)) exitwith {["Not wearing a compatible helmet.","addItemFailed"] call MAZ_EP_fnc_systemMessage};
			private _throwable = currentThrowable player;
			if(count _throwable == 0) exitWith {["You don't have any grenades!"] call MAZ_EP_fnc_systemMessage};
			private _currentLightClass = switch (_throwable select 0) do {
				case "B_IR_Grenade": {"B_IRStrobe"};
				case "O_R_IR_Grenade";
				case "O_IR_Grenade": {"O_IRStrobe"};
				case "I_E_IR_Grenade";
				case "I_IR_Grenade": {"I_IRStrobe"};
				default {""}
			}; 
			if (_currentLightClass == "") exitWith {["Cannot attach your current throwable."] call MAZ_EP_fnc_systemMessage};
			MAZ_ENV_strobeThrowable = _throwable select 0;
            [_currentLightClass] call MAZ_ENV_fnc_createAttachedStrobe;
			playSound3D ['A3\Sounds_F_Orange\MissionSFX\Orange_Start_Sim.wss', player,false,getPosASL player,5,1,7.5,1];
			player removeItem MAZ_ENV_strobeThrowable;
			["You turned on your IR Strobe."] call MAZ_EP_fnc_systemMessage;
			private _timeToDelete = time + 240;
			while {!isNull MAZ_ENV_attachedStrobe} do {
				if(time >= _timeToDelete) then {
					private _type = typeOf MAZ_ENV_attachedStrobe;
					call MAZ_ENV_fnc_deleteAttachedStrobeLight;
                    [_type] call MAZ_ENV_fnc_createAttachedStrobe;
					_timeToDelete = time + 240;
				};
				sleep 1;
			};
		};

        MAZ_ENV_fnc_removeStrobeEH = {			
			if(!isNil "MAZ_ENV_EH_Killed_Strobe") then {
				player removeEventHandler ["Killed",MAZ_ENV_EH_Killed_Strobe];	
			};
			if(!isNil "MAZ_ENV_EH_GetInMan_IRStrobe") then {
				player removeEventHandler ["GetInMan",MAZ_ENV_EH_GetInMan_IRStrobe];
			};
		};

		MAZ_ENV_fnc_createAttachedStrobe = {
            params ["_strobeClassName"];
            call MAZ_ENV_fnc_removeStrobeEH;
            MAZ_ENV_EH_Killed_Strobe = player addEventHandler ["Killed", {
				call MAZ_ENV_fnc_deleteAttachedStrobeLight;
				call MAZ_ENV_fnc_removeStrobeEH;
			}];
            MAZ_ENV_EH_GetInMan_IRStrobe = player addEventHandler ["GetInMan", {
				if (isNil "MAZ_ENV_attachedStrobe" || {isNull MAZ_ENV_attachedStrobe}) exitwith {};
                call MAZ_ENV_fnc_deleteAttachedStrobeLight;
				call MAZ_ENV_fnc_removeStrobeEH;
                ["You turned off your IR Strobe."] call MAZ_EP_fnc_systemMessage;
                playSound3D ['A3\Sounds_F_Orange\MissionSFX\Orange_Start_Sim.wss', player,false,getPosASL player,5,1,5,1];
                player addItem MAZ_ENV_strobeThrowable;
			}];
            MAZ_ENV_attachedStrobe = _strobeClassName createVehicle [0,0,0];
			MAZ_ENV_attachedStrobe attachto [player, [0,-0.08,0.125], "pilot",true];
			MAZ_ENV_attachedStrobe addEventHandler ["Deleted", {
				params ["_object"];
				{
					deleteVehicle _x;
				}forEach (attachedObjects _object); 
			}];
		};

		MAZ_ENV_fnc_deleteAttachedStrobeLight = {
			deleteVehicle MAZ_ENV_attachedStrobe;
		};

		MAZ_ENV_fnc_pointShootOnKeyDown = {
			params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];
			if(_key != 42) exitWith {};
			if (!(missionNamespace getVariable ["MAZ_ENV_heldDown",false]) && !(missionNamespace getVariable ["MAZ_ENV_holdBreathCooldown",false])) then {
				MAZ_ENV_heldDown = true;
				player setCustomAimCoef 0.3;
				MAZ_holdBreathTime = time;
				[] spawn {
					if(true) exitWith {};
					private _sound = playSound3D [format ["a3\sounds_f\characters\human-sfx\p02\breath_aiming_%1.wss",selectRandom ["1","2"]], player, false, getPosASL player, 5, 1, 5, 0, true];
					sleep 1;
					stopSound _sound;
				};
			};
			if((time - MAZ_holdBreathTime) > 5 && !(missionNamespace getVariable ["MAZ_ENV_holdBreathCooldown",false])) then {
				player setCustomAimCoef 1;
				MAZ_ENV_holdBreathCooldown = true;
				MAZ_ENV_heldDown = false;
				[] spawn {
					sleep (4 + (random 3));
					MAZ_ENV_holdBreathCooldown = false;
					player setCustomAimCoef 1;
					'playSound3D [format ["a3\sounds_f\characters\human-sfx\p02\breath_aiming_%1.wss",selectRandom ["1","2"]], player, false, getPosASL player, 5, 1, 10, 1, true]';
				};
			};
		};

		MAZ_ENV_fnc_pointShootOnKeyUp = {
			params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];
			if(_key != 42) exitWith {};
			if (missionNamespace getVariable ["MAZ_ENV_heldDown",false]) then {
				player setCustomAimCoef 1;
				'playSound3D [format ["a3\sounds_f\characters\human-sfx\p02\breath_aiming_%1.wss",selectRandom ["1","2"]], player, false, getPosASL player, 5, 1, 10, 1, true]';
				missionNamespace setVariable ["MAZ_ENV_heldDown",false];
			};
		};

		MAZ_ENV_fnc_canPlaceIRMarker = {
			if(vehicle player != player) exitWith {false};
			private _throwable = currentThrowable player;
			if(count _throwable == 0) exitWith {false};
			if !((_throwable select 0) in ["B_IR_Grenade","O_R_IR_Grenade","O_IR_Grenade","I_E_IR_Grenade","I_IR_Grenade"]) exitWith {false};
			private _frontPos = if(currentWeapon player == "" || weaponLowered player) then {
				AGLtoASL (screenToWorld [0.5,0.5])
			} else {
				eyePos player vectorAdd ((player weaponDirection (currentWeapon player)) vectorMultiply 5);
			};
			private _intersects = lineIntersectsSurfaces [eyePos player,_frontPos,player];
			if((count _intersects) == 0) exitWith {false};
			(_intersects # 0) params ["_interPosASL","_surfaceNormal","","_interObject"];
			if((_interPosASL distance (getPosASL player)) > 5) exitWith {false};
			if(isNull _interObject) exitWith {false};
			private _strAr = (str _interObject) splitString " ";
			if(isNull _interObject || {(count _strAr > 1) && {((_strAr # 1) select [0,2]) in ["b_"]}}) exitWith {false};
			if(_interObject isKindOf "CAManBase") exitWith {false};
			true;
		};

		MAZ_ENV_fnc_addPickupStrobeAction = {
			params ["_strobe"];
			_strobe addAction [
				"Pickup IR Marker",
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
					deleteVehicle _target;
					player action ["TakeWeapon", objNull, primaryWeapon player];
				},
				nil,
				1.5,
				false,
				true,
				"",
				"_this distance _target < 4"
			];
		};
		
		MAZ_ENV_fnc_addIRMarkerAction = {
			if(!isNil "MAZ_ENV_StrobeMarker") then {
				player removeAction MAZ_ENV_StrobeMarker;
			};
			MAZ_ENV_StrobeMarker = player addAction [
				"Place IR Marker",
				{
					private _frontPos = if(currentWeapon player == "" || weaponLowered player) then {
						AGLtoASL (screenToWorld [0.5,0.5])
					} else {
						eyePos player vectorAdd ((player weaponDirection (currentWeapon player)) vectorMultiply 5);
					};
					private _intersects = lineIntersectsSurfaces [eyePos player,_frontPos,player];
					(_intersects # 0) params ["_interPosASL","_surfaceNormal","","_interObject"];
					private _throwable = currentThrowable player;
					if(count _throwable == 0) exitWith {["You don't have any grenades!"] call MAZ_EP_fnc_systemMessage};
					private _currentLightClass = switch (_throwable select 0) do {
						case "B_IR_Grenade": {"B_IRStrobe"};
						case "O_R_IR_Grenade";
						case "O_IR_Grenade": {"O_IRStrobe"};
						case "I_E_IR_Grenade";
						case "I_IR_Grenade": {"I_IRStrobe"};
						default {""}
					}; 
					if(_currentLightClass == "") exitWith {};
					player removeItem (_throwable select 0);
					private _strobe = _currentLightClass createVehicle [0,0,0];
					_strobe addEventHandler ["Deleted", {
						params ["_object"];
						{
							deleteVehicle _x;
						}forEach (attachedObjects _object); 
					}];
					player action ["TakeWeapon", objNull, primaryWeapon player];
					if(_interObject in (nearestTerrainObjects [ASLtoAGL _interPosASL, [], 10, false, true])) exitWith {
						_strobe setPosASL _interPosASL;
					};
					private _relPos = _interObject worldToModel (ASLtoAGL _interPosASL);
					_strobe attachTo [_interObject,_relPos];
				},
				nil,
				1.5,
				false,
				true,
				"",
				"call MAZ_ENV_fnc_canPlaceIRMarker"
			];
		};

		if(!isNil "MAZ_ENV_DEH_KeyDown_pointShoot") then {
			(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_ENV_DEH_KeyDown_pointShoot];
		};
		MAZ_ENV_DEH_KeyDown_pointShoot = (findDisplay 46) displayAddEventHandler ["KeyDown", {
			_this call MAZ_ENV_fnc_pointShootOnKeyDown;
		}]; 
		if(!isNil "MAZ_ENV_DEH_KeyUp_pointShoot") then {
			(findDisplay 46) displayRemoveEventHandler ["KeyUp",MAZ_ENV_DEH_KeyUp_pointShoot];
		};
		MAZ_ENV_DEH_KeyUp_pointShoot = (findDisplay 46) displayAddEventHandler ["KeyUp", {
			_this call MAZ_ENV_fnc_pointShootOnKeyUp;
		}]; 

		if(!isNil "MAZ_ENV_MEH_Draw3D_WeaponOptics") then {
			removeMissionEventHandler ["Draw3D",MAZ_ENV_MEH_Draw3D_WeaponOptics];
		};
		MAZ_ENV_MEH_Draw3D_WeaponOptics = addMissionEventHandler ["Draw3D", {
			call {
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

		MAZ_ENV_fnc_toggleWhitePhosor= {
			private _whitePhosor = player getVariable "MAZ_ENV_toggleWhitePhosor";
			player setVariable ["MAZ_ENV_toggleWhitePhosor",(!_whitePhosor)];
			playSound3D ['a3\sounds_f_mark\arsenal\sfx\bipods\bipod_op_down.wss', player,false,getPosASL player,5,1,2];
		};
		player setVariable ["MAZ_ENV_toggleWhitePhosor",false];

		if(!isNil "MAZ_ENV_MEH_Draw3D_WhitePhosphor") then {
			removeMissionEventHandler ["Draw3D",MAZ_ENV_MEH_Draw3D_WhitePhosphor];
		};
		MAZ_ENV_MEH_Draw3D_WhitePhosphor = addMissionEventHandler ["Draw3D", {
			call {
				if(!MAZ_EP_enhancedNightVisionEnabled || !isNull (findDisplay 312)) exitWith {
					MAZ_PP_FilmGrain_NVG ppEffectEnable false;
					MAZ_PP_ColorCorrect_NVG ppEffectEnable false;
				};
				if(currentVisionMode player == 0) then {
					if(!isNil "MAZ_PP_FilmGrain_NVG") then {	
						MAZ_PP_FilmGrain_NVG ppEffectEnable false;
					};
				};
				if(currentVisionMode player != 0) then {
					if(isNil "MAZ_PP_FilmGrain_NVG") then {
						MAZ_PP_FilmGrain_NVG = ppEffectCreate ["FilmGrain",2000];
					};
					private _grainIntensity = 0.27 + (0.32 * (1 - overcast));
					private _sharpness = 0.56 + (0.22 * (1 - overcast));
					MAZ_PP_FilmGrain_NVG ppEffectEnable true;
					MAZ_PP_FilmGrain_NVG ppEffectForceInNVG true;
					MAZ_PP_FilmGrain_NVG ppEffectAdjust [_grainIntensity,_sharpness,1,0.64,0.24,true];
					MAZ_PP_FilmGrain_NVG ppEffectCommit 0;
				};
				if(currentVisionMode player == 1 && (player getVariable ["MAZ_ENV_toggleWhitePhosor",false])) then {
					if(isNil "MAZ_PP_ColorCorrect_NVG") then {
						MAZ_PP_ColorCorrect_NVG = ppEffectCreate ["ColorCorrections",1500];
					};
					private _contrast = 0.3 + (0.4 * (1 - overcast));
					MAZ_PP_ColorCorrect_NVG ppEffectForceInNVG true;
					MAZ_PP_ColorCorrect_NVG ppEffectEnable true;
					MAZ_PP_ColorCorrect_NVG ppEffectAdjust [
						1.05, 
						_contrast, 
						0, 
						[0,0.05,0.05,0], 
						[0.25,0.75,0.85,0], 
						[1,1,1,0],
						[0,0,0,0,0,0,0]
					];
					MAZ_PP_ColorCorrect_NVG ppEffectCommit 0;
				} else {
					MAZ_PP_ColorCorrect_NVG ppEffectEnable false;
				};
			};
		}];

		if(!isNil "MAZ_EH_VisionModeChanged_ENV") then {
			player removeEventHandler ["VisionModeChanged",MAZ_EH_VisionModeChanged_ENV];
		};
		MAZ_EH_VisionModeChanged_ENV = player addEventHandler ["VisionModeChanged", {
			params ["_person", "_visionMode", "_TIindex", "_visionModePrev", "_TIindexPrev", "_vehicle", "_turret"];
			if(!MAZ_EP_enhancedNightVisionEnabled) exitWith {};
			if(_visionModePrev == 0) then {
				playSound3D ['A3\ui_f_curator\data\sound\CfgSound\visionMode.wss', _person,false,getPosASL _person,5,1,4];
				if !(call MAZ_ENV_fnc_canEnter3PP) then {
					if(cameraView == "External") then {
						player switchCamera "Internal";
					};
				};
			};
			if(_visionMode > 1) then {
				player action ["nvGogglesOff", player];
			};
			playSound3D ['a3\sounds_f_mark\arsenal\sfx\bipods\bipod_op_down.wss', _person,false,getPosASL _person,5,1,3,0.1];
		}];
		if(!isNil "MAZ_ENV_DEH_KeyDown_firstPerson") then {
			(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_ENV_DEH_KeyDown_firstPerson];
		};
		MAZ_ENV_DEH_KeyDown_firstPerson = (findDisplay 46) displayAddEventHandler ["KeyDown", {
			params ["_display","_key"];
			private _return = false;
			if(_key in (actionKeys "personView") && !(call MAZ_ENV_fnc_canEnter3PP)) then {
				_return = true;
			};
			_return
		}];
		if(!isNil "MAZ_ENV_EH_GetOutMan_3PP") then {
			player removeEventHandler ["GetOutMan",MAZ_ENV_EH_GetOutMan_3PP];
		};
		MAZ_ENV_EH_GetOutMan_3PP = player addEventHandler ["GetOutMan", {
			if(cameraView == "External" && !(call MAZ_ENV_fnc_canEnter3PP)) then {
				player switchCamera "Internal";
			};
		}];
		if(!isNil "MAZ_ENV_EH_Respawn_IRMarker") then {
			player removeEventHandler ["Respawn",MAZ_ENV_EH_Respawn_IRMarker];
		};
		MAZ_ENV_EH_Respawn_IRMarker = player addEventHandler ["Respawn", {
			call MAZ_ENV_fnc_addIRMarkerAction;
		}];

		[] spawn {
			waitUntil {uisleep 0.1;!isNull (findDisplay 46) && alive player};
			sleep 0.1;
			waitUntil {!isNil "MAZ_fnc_newKeybind"};
			MAZ_Key_ENV_ToggleIRIlluminator = ["Toggle IR Illuminator","Turn on or off the IR Illuminator.",38,{call MAZ_ENV_fnc_toggleIRIlluminator;},false,true,false,true,false,"MAZ_IRIllum"] call MAZ_fnc_newKeybind;
			MAZ_Key_ENV_ToggleIRIlluminatorDiffuseMode = ["Toggle IR Diffuser","Turn on or off the IR diffuser.",38,{call MAZ_ENV_fnc_toggleIRIlluminatorDiffuseMode;},false,false,true,true,false,"MAZ_IRIllumMode"] call MAZ_fnc_newKeybind;
			MAZ_Key_ENV_AttachStrobe = ["Toggle Attached Strobe","Attach/Detach current selected IR strobe to helmet.",34,{[] spawn MAZ_ENV_fnc_attachStrobeLightToHelmet;},false,false,true,true,false,"MAZ_IRStrobe"] call MAZ_fnc_newKeybind; 
			MAZ_Key_ENV_WhitePhosphor = ["White Phosphor NVG","Toggles the white phosphor on NVGs.",49,{call MAZ_ENV_fnc_toggleWhitePhosor;},false,true,false,true,false,"MAZ_phosphor"] call MAZ_fnc_newKeybind;

			call MAZ_ENV_fnc_addIRMarkerAction;
			if(!isNil "MAZ_DEH_KeyDown_LaserSound") then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_DEH_KeyDown_LaserSound];
			};
			MAZ_DEH_KeyDown_LaserSound = (findDisplay 46) displayAddEventHandler ["KeyDown", {
				params ["_display","_key"];
				if !(_key in (actionKeys "headlights")) exitWith {};
				call MAZ_ENV_fnc_toggleLaserSound;
			}];
		};

		if(isServer) then {
			[] spawn MAZ_ENV_fnc_adjustAIAtNightServerLoop;
		};
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		[
			"Enhanced Nightvision", 
			"This makes NVGs more realistic and adds a ton of features for nighttime operations. Makes you feel super dooper tacticool and operator.",
			[
				"Dynamic grain and brightness for NVGs",
				"Cannot use magnified optics with NVGs, only 1x sights",
				"NVGs force you into first person, except for in vehicles",
				"Thermal night vision is disabled",
				"Optional white phosphor Tubes (Default CTRL + N)",
				"IR Illuminators are built into the PEQ lasers (Default CTRL + L)",
				"Adds holding breath for point shooting with lasers (Default hold Shift)",
				"Adds attachable IR strobes for helmets (Default ALT + G)",
				"Evens the playing field at nighttime by making AI slightly dumber"
			]
		] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Enhanced Night Vision System has been loaded! Night Vision has more grain and you have IR illuminators now!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	[] spawn MAZ_EP_fnc_enhancedNightVisionCarrier;
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