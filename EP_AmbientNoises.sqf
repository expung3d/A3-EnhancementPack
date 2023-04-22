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
if(missionNamespace getVariable ["MAZ_ambientNoisesToggle",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Ambient noises already running!";};

private _varName = "MAZ_System_EnhancementPack_AN";
private _myJIPCode = "MAZ_EPSystem_AN_JIP";

MAZ_ambientNoisesToggle = true;
publicVariable "MAZ_ambientNoisesToggle";

private _value = (str {
	MAZ_airCondition = false;
	publicVariable "MAZ_airCondition";

	MAZ_fnc_dogBarkingInTownCarrier = {
		MAZ_shotRecently = 0;
		MAZ_fnc_dogBarkingLoop = {
			while {MAZ_ambientNoisesToggle} do {
				if( (count (nearestTerrainObjects [position player,["House","Building","Church","Chapel"],200,false,true])) > 75) then {
					private _randomPos = [[[position player,175]],[]] call BIS_fnc_randomPos;
					private _randomType = selectRandom ["01","02","03","04","05","06","07","08","09","10"];
					playSound3D [format ["A3\sounds_f_oldman\environment\sfx\misc\distant\sfx0%1.wss",_randomType],nil,false,_randomPos, 5, 1, 400,0,true];
					private _laughingKids = (random 1) < 0.01;
					if(_laughingKids) then {
						sleep 5;
						private _randomDir = round (random 360);
						_randomPos = player getRelPos [200,_randomDir];
						_randomType = selectRandom ["01","02","03","04","05","06","07","08"];
						playSound3D [format ["A3\sounds_f_orange\missionSFX\PastAmbiences\Kindergarten\Orange_Kindergarten_Kids_%1.wss",_randomType],nil,false,_randomPos, 5, 1, 300];
					};
				};
				private _randomSleep = selectRandom [15,16,17,18,19,20,21,22,23,24,25];
				sleep _randomSleep;
			};
		};

		MAZ_fnc_treesCreakingLoop = {
			while{MAZ_ambientNoisesToggle} do {
				if( (count (nearestTerrainObjects [position player,["Tree"],125,false,true])) > 75 && !((count (nearestTerrainObjects [position player,["House","Building","Church","Chapel"],200,false,true])) > 75)) then {
					private _randomPos = selectRandom (nearestTerrainObjects [position player,["Small Tree","Tree"],75,false,true]);
					private _randomType = selectRandom ["1","2","3","4","5","6","7","8","9"];
					private _volume = (player distance _randomPos) + 35;
					playSound3D [format ["A3\sounds_f\environment\sfx\tree_creaking\creacking_%1.wss",_randomType],nil,false,_randomPos, 5, 1, _volume,0,true];
					if((random 1) < 0.01) then {
						sleep 2;
						private _randomDir = round (random 360);
						_randomPos = player getRelPos [200,_randomDir];
						_randomType = selectRandom ["falling_broadleaf_tree_big","falling_broadleaf_tree_small"];
						playSound3D [format ["A3\sounds_f\environment\sfx\falling_trees\%1.wss",_randomType],nil,false,_randomPos, 5, 1, 250,0,true];
					};
				};
				private _randomSleep = selectRandom [7,8,9,10,11,12,13,14];
				sleep _randomSleep;
			};
		};

		MAZ_fnc_airConditioningLoop = {
			while {MAZ_airCondition} do {
				waitUntil{((count (nearestTerrainObjects [position player,["House"],10,false,true])) > 0)};
				if((count (nearestTerrainObjects [position player,["House"],10,false,true])) > 0) then {
					private _randomPos = (nearestTerrainObjects [position player,["House"],10,true,true]) select 0; 
					private _randomType = selectRandom ["1","2","3","4","5"]; 
					playSound3D [format ["A3\sounds_f\environment\structures\objects\aircondition_%1.wss",_randomType],nil,true,_randomPos, 5, 1, 50,0,true];
				};
				sleep 7.5;
			};
		};

		MAZ_fnc_scaredBirds = {
			if( (count (nearestTerrainObjects [position player,["Tree"],125,false,true])) > 75) then {
				private _randomPos = selectRandom (nearestTerrainObjects [position player,["Small Tree","Tree"],50,false,true]);
				playSound3D ["A3\sounds_f\environment\animals\scared_animal6.wss",nil,false,_randomPos, 5, 1, 200,0,true];
				playSound3D ["A3\sounds_f\environment\animals\scared_animal6.wss",nil,false,_randomPos, 5, 1, 200,0,true];
				playSound3D ["A3\sounds_f\environment\animals\scared_animal6.wss",nil,false,_randomPos, 5, 1, 200,0,true];
				playSound3D ["A3\sounds_f\environment\animals\scared_animal6.wss",nil,false,_randomPos, 5, 1, 200,0,true];
			};
		};

		MAZ_fnc_startShotTimerAmbient = {
			while {MAZ_shotRecently > 0} do {
				MAZ_shotRecently = MAZ_shotRecently - 1;
				sleep 1;
			};
		};

		MAZ_fnc_checkForNearSwamp = {
			private _return = false;
			if(player distance [21057.9,14751.2] < 1000 && (count (nearestTerrainObjects [player,["BUSH"],100,false,true]) > 50)) then {
				_return = true;
			};
			_return
		};

		MAZ_fnc_swampSoundLoop = {
			while{MAZ_ambientNoisesToggle} do {
				waitUntil{[] call MAZ_fnc_checkForNearSwamp};
				if([] call MAZ_fnc_checkForNearSwamp) then {
					private _randomDir = round (random 360);
					private _randomPos = player getRelPos [150,_randomDir];
					private _randomType1 = selectRandom [1,2,3,4,5];
					private _randomType2 = 0;
					switch (_randomType1) do {
						case 1: {
							_randomType2 = selectRandom [1,2,3,4,5];
						};
						case 2: {
							_randomType2 = selectRandom [1,2,3,4,5,6,7];
						};
						case 3: {
							_randomType2 = selectRandom [1,2,3,4];
						};
						case 4: {
							_randomType2 = selectRandom [1,2,3,4,5,6,7,8];
						};
						case 5: {
							_randomType2 = selectRandom [1,2,3,4,5,6,7,8,9];
						};
					};
					playSound3D [format ["A3\sounds_f_exp\environment\animals\frogs\forest\mid\frog0%1_0%2.wss",_randomType1,_randomType2],nil,false,_randomPos, 5, 1, 200,0,true];
				};
				private _randomSleep = selectRandom [5,6,7,8,9];
				sleep _randomSleep;
			};
		};

		MAZ_fnc_checkForGasMask = {
			private _masks = [
				"G_AirPurifyingRespirator_01_F",
				"G_AirPurifyingRespirator_02_sand_F",
				"G_AirPurifyingRespirator_02_olive_F",
				"G_AirPurifyingRespirator_02_black_F",
				"G_RegulatorMask_F",
				"G_AirPurifyingRespirator_02_black_nofilter_F",
				"G_AirPurifyingRespirator_01_nofilter_F"
			];
			private _return = false;
			if(goggles player in _masks) then {
				_return = true;
			};
			_return
		};

		MAZ_fnc_createMaskOverlay = {
			gasMaskType = "";
			switch (goggles player) do {
				case "G_AirPurifyingRespirator_01_nofilter_F";
				case "G_AirPurifyingRespirator_01_F": {gasMaskType = "\a3\ui_f_enoch\data\objects\data\optics_apr_ca.paa";};
				case "G_AirPurifyingRespirator_02_sand_F": {gasMaskType = "\a3\ui_f_enoch\data\objects\data\optics_APR_02_CA.paa";};
				case "G_AirPurifyingRespirator_02_olive_F": {gasMaskType = "\a3\ui_f_enoch\data\objects\data\optics_APR_02_CA.paa";};
				case "G_AirPurifyingRespirator_02_black_nofilter_F";
				case "G_AirPurifyingRespirator_02_black_F": {gasMaskType = "\a3\ui_f_enoch\data\objects\data\optics_APR_02_CA.paa";};
				case "G_RegulatorMask_F": {gasMaskType = "\a3\ui_f_enoch\data\objects\data\optics_regulator_CA.paa";};
			};
			with uiNamespace do {
				gasMaskOverlay = (findDisplay 46) ctrlCreate ["RscPicture",-1];
				gasMaskOverlay ctrlSetPosition [0 * safezoneW + safezoneX,0 * safezoneH + safezoneY,1.00547 * safezoneW,1.012 * safezoneH];
				gasMaskOverlay ctrlSetText (missionNamespace getVariable 'gasMaskType');
				gasMaskOverlay ctrlSetAngle [180,0.5,0.5];
				gasMaskOverlay ctrlCommit 0;
			};
		};

		MAZ_fnc_checkForDupedGasMask = {
			private _return = false;
			private _gasMaskOverlayTypes = [
				"\a3\ui_f_enoch\data\objects\data\optics_apr_ca.paa",
				"\a3\ui_f_enoch\data\objects\data\optics_APR_02_CA.paa",
				"\a3\ui_f_enoch\data\objects\data\optics_regulator_CA.paa"
			];
			{
				if(ctrlText _x in _gasMaskOverlayTypes) then {
					_return = true;
				};
			}forEach allControls (findDisplay 46);
			_return
		};

		MAZ_fnc_gasMaskSoundsLoop = {
			while{MAZ_ambientNoisesToggle} do {
				if(call MAZ_fnc_checkForGasMask) then {
					private _randomType = selectRandom [1,2,3,4];
					playSound3D [format ["A3\sounds_f\characters\human-sfx\diver-breath-%1.wss",_randomType],player,false,getPosASL player, 2, 1, 5];
					playSound3D [format ["A3\sounds_f\characters\human-sfx\diver-breath-%1.wss",_randomType],player,false,getPosASL player, 2, 1, 5];
					private _fatigue = 1 - (getFatigue player);
					private _randomSleep = (selectRandom [2,2.25,2.5,2.75,3,3.25,3.5]) * _fatigue;
					if(_randomSleep < 1.25) then {
						_randomSleep = 1.25;
					};
					sleep _randomSleep;
				};
				sleep 1;
			};
		};

		MAZ_fnc_addGasMaskHose = {
			if(backpack player == "B_SCBA_01_F") exitWith {
				if(goggles player == "G_RegulatorMask_F") exitWith {
					[(backpackContainer player), [1, ""]] remoteExec ['setObjectTexture'];
					[(backpackContainer player), [2, "a3\supplies_f_enoch\bags\data\b_cur_01_co.paa"]] remoteExec ['setObjectTexture'];
				};
				[(backpackContainer player), [1, "a3\supplies_f_enoch\bags\data\b_cur_01_co.paa"]] remoteExec ['setObjectTexture'];
				[(backpackContainer player), [2, ""]] remoteExec ['setObjectTexture'];
			};
			[(backpackContainer player), [1, "a3\supplies_f_enoch\bags\data\b_cur_01_co.paa"]] remoteExec ['setObjectTexture'];
			[(backpackContainer player), [2, "a3\supplies_f_enoch\bags\data\b_cur_01_co.paa"]] remoteExec ['setObjectTexture'];
			if(goggles player == "G_AirPurifyingRespirator_02_black_F") then {
				removeGoggles player;
				player linkItem "G_AirPurifyingRespirator_02_black_nofilter_F"; 
			};
			if(goggles player == "G_AirPurifyingRespirator_01_F") then {
				removeGoggles player;
				player linkItem "G_AirPurifyingRespirator_01_nofilter_F";
			};
		};

		MAZ_fnc_gasMaskOverlayLoop = {
			while{MAZ_ambientNoisesToggle} do {
				if(call MAZ_fnc_checkForGasMask && (cameraView != "External")) then {
					private _gasMaskOverlay = uiNamespace getVariable ['gasMaskOverlay',nil];
					if(isNil "_gasMaskOverlay") then {
						[] spawn MAZ_fnc_createMaskOverlay;
					};
				} else {
					private _gasMaskOverlay = uiNamespace getVariable 'gasMaskOverlay';
					if(!isNil "_gasMaskOverlay") then {
						ctrlDelete _gasMaskOverlay;
						uiNamespace setVariable ['gasMaskOverlay',nil];
					} else {
						if([] call MAZ_fnc_checkForDupedGasMask) then {
							private _gasMaskOverlayTypes = [
								"\a3\ui_f_enoch\data\objects\data\optics_apr_ca.paa",
								"\a3\ui_f_enoch\data\objects\data\optics_APR_02_CA.paa",
								"\a3\ui_f_enoch\data\objects\data\optics_regulator_CA.paa"
							];
							{
								if(ctrlText _x in _gasMaskOverlayTypes) then {
									ctrlDelete _x;
								};
							}forEach allControls (findDisplay 46);
						};
					};
					
				};
				if([] call MAZ_fnc_checkForGasMask && backpack player in ["B_CombinationUnitRespirator_01_F","B_SCBA_01_F"]) then {
					call MAZ_fnc_addGasMaskHose;
				};
				sleep 0.1;
			};
		};

		MAZ_fnc_roosterSoundsLoop = {
			while{MAZ_ambientNoisesToggle} do {
				waitUntil {dayTime > 5 && dayTime < 5.6};
				private _randomDir = round (random 360);
				private _randomPos = player getRelPos [150,_randomDir];
				playSound3D ["a3\sounds_f\environment\animals\chickens\chicken_01.wss",nil,false,_randomPos, 5, 1, 250,0,true];

				private _randomSleep = selectRandom [15,16,17,18,19,20,21,22,23,24,25];
				sleep _randomSleep;
			};
		};

		MAZ_EH_FiredMan_ambientNoises = player addEventHandler ["FiredMan",{
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
			if(MAZ_shotRecently == 0) then {
				MAZ_shotRecently = 300;
				[] spawn MAZ_fnc_scaredBirds;
				[] spawn MAZ_fnc_startShotTimerAmbient;
			} else {
				MAZ_shotRecently = 300;
			};
		}];

		[] spawn MAZ_fnc_dogBarkingLoop;
		[] spawn MAZ_fnc_treesCreakingLoop;
		[] spawn MAZ_fnc_airConditioningLoop;
		[] spawn MAZ_fnc_swampSoundLoop;
		[] spawn MAZ_fnc_gasMaskSoundsLoop;
		[] spawn MAZ_fnc_gasMaskOverlayLoop;
		[] spawn MAZ_fnc_roosterSoundsLoop;
	};
	if(!isNil "MAZ_EP_fnc_addDiaryRecord") then {
		["Ambient Noises", "Around the map you will be able to hear various ambient noises. Dogs barking in towns, trees creaking in the woods, gas mask sounds while wearing them, etc. Generally meant to add immersion."] call MAZ_EP_fnc_addDiaryRecord;
	};
	
	call MAZ_fnc_dogBarkingInTownCarrier;
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