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
	};
	if(!isNil "MAZ_EP_fnc_addDiaryRecord") then {
		["Enhanced Nightvision", "This makes NVGs more realistic by adding extra film grain when using them and preventing the use of magnified optics. With NVGs you will still be able to use 1x optics, however, zoomed optics aren't available. In addition, you will be forced into first person when using NVGs. Also, ENVGs have white phosphor tubes... because its cool."] call MAZ_EP_fnc_addDiaryRecord;
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