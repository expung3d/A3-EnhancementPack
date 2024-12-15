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

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["[AN] Ambient Noises","Whether to enable the Ambient Noises system.","MAZ_ambientNoisesToggle",true,"TOGGLE",[],"MAZ_AN"] call MAZ_EP_fnc_addNewSetting;
	["[AN] Dog Barking","Whether to have dog barking be heard when players are in towns.","MAZ_AN_dogBarking",true,"TOGGLE",[],"MAZ_AN"] call MAZ_EP_fnc_addNewSetting;
	["[AN] Tree Creaking","Whether to have trees creak when players are walking in forests.","MAZ_AN_treeCreaks",true,"TOGGLE",[],"MAZ_AN"] call MAZ_EP_fnc_addNewSetting;
	["[AN] Frog Croaks","Whether to have frogs croak when players are in swamps.\nThe only swamp is on Altis.","MAZ_AN_frogCroaks",true,"TOGGLE",[],"MAZ_AN"] call MAZ_EP_fnc_addNewSetting;
	["[AN] Gas Mask Sounds","Whether to have players wearing gas masks make gas mask breathing noises.","MAZ_AN_gasMaskSounds",true,"TOGGLE",[],"MAZ_AN"] call MAZ_EP_fnc_addNewSetting;
	["[AN] Gas Mask Overlay","Whether to have players wearing gas masks have an overlay of a gas mask when in first person.","MAZ_AN_gasMaskOverlay",true,"TOGGLE",[],"MAZ_AN"] call MAZ_EP_fnc_addNewSetting;
	["[AN] Roosters","Whether to have roosters make noise during sunrise.","MAZ_AN_roosters",true,"TOGGLE",[],"MAZ_AN"] call MAZ_EP_fnc_addNewSetting;
	["[AN] Scared Birds","Whether to have birds fly away from players when they shoot within a forest with unsuppressed guns.","MAZ_AN_scaredBirds",true,"TOGGLE",[],"MAZ_AN"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_AN_fnc_ambientNoisesMainLoop = {
		if(!MAZ_ambientNoisesToggle) exitWith {};
		[] spawn MAZ_AN_fnc_handleDogBarking;
		[] spawn MAZ_AN_fnc_handleTreeCreaking;
		[] spawn MAZ_AN_fnc_handleSwampFrogs;
		[] spawn MAZ_AN_fnc_handleGasMaskSound;
		[] spawn MAZ_AN_fnc_handleGasMaskOverlay;
		[] spawn MAZ_AN_fnc_handleRoosterSound;
	};
	[] spawn {
		waitUntil {!isNil "MAZ_EP_fnc_addFunctionToMainLoop"};
		["MAZ_AN_fnc_ambientNoisesMainLoop"] call MAZ_EP_fnc_addFunctionToMainLoop;
	};

	MAZ_AN_fnc_handleDogBarking = {
		if(!MAZ_AN_dogBarking) exitWith {};
		if(isNil "MAZ_AN_dogBarkTime") then {
			MAZ_AN_dogBarkTime = time;
		};
		if(time < MAZ_AN_dogBarkTime) exitWith {};
		if !( 
			(count (nearestTerrainObjects [position player,["House","Building","Church","Chapel"],200,false,true])) > 120
		) exitWith {};

		private _randomPos = [[[position player,175]],[]] call BIS_fnc_randomPos;
		private _randomType = selectRandom ["01","02","03","04","05","06","07","08","09","10"];
		playSound3D [format ["A3\sounds_f_oldman\environment\sfx\misc\distant\sfx0%1.wss",_randomType],nil,false,_randomPos, 5, 1, 400,0,true];
		if((random 1) < 0.01) then {
			sleep 5;
			private _randomDir = round (random 360);
			_randomPos = player getRelPos [200,_randomDir];
			_randomType = selectRandom ["01","02","03","04","05","06","07","08"];
			playSound3D [format ["A3\sounds_f_orange\missionSFX\PastAmbiences\Kindergarten\Orange_Kindergarten_Kids_%1.wss",_randomType],nil,false,_randomPos, 5, 1, 300];
		};
		private _randomSleep = selectRandom [15,16,17,18,19,20,21,22,23,24,25];
		MAZ_AN_dogBarkTime = time + _randomSleep;
	};

	MAZ_AN_fnc_handleTreeCreaking = {
		if(!MAZ_AN_treeCreaks) exitWith {};
		if(isNil "MAZ_AN_treeCreakTime") then {
			MAZ_AN_treeCreakTime = time;
		};
		if(time < MAZ_AN_treeCreakTime) exitWith {};
		if !( 
			(count (nearestTerrainObjects [position player,["Tree"],125,false,true])) > 100 && 
			!((count (nearestTerrainObjects [position player,["House","Building","Church","Chapel"],150,false,true])) > 75)
		) exitWith {};

		private _randomPos = selectRandom (nearestTerrainObjects [position player,["Small Tree","Tree"],50,false,true]);
		private _randomType = selectRandom ["1","2","3","4","5","6","7","8","9"];
		private _volume = (player distance _randomPos) + 55;
		playSound3D [format ["A3\sounds_f\environment\sfx\tree_creaking\creacking_%1.wss",_randomType],nil,false,_randomPos, 5, 1, _volume,0,true];
		if((random 1) < 0.01) then {
			sleep ((ceil (random 3)) + 1);
			private _randomDir = round (random 360);
			_randomPos = player getRelPos [200,_randomDir];
			_randomType = selectRandom ["falling_broadleaf_tree_big","falling_broadleaf_tree_small"];
			playSound3D [format ["A3\sounds_f\environment\sfx\falling_trees\%1.wss",_randomType],nil,false,_randomPos, 5, 1, 225,0,true];
		};
		private _randomSleep = selectRandom [7,8,9,10,11,12,13,14];
		MAZ_AN_treeCreakTime = time + _randomSleep;
	};

	MAZ_AN_fnc_handleSwampFrogs = {
		if(!MAZ_AN_frogCroaks) exitWith {};
		if(isNil "MAZ_AN_frogCroakTime") then {
			MAZ_AN_frogCroakTime = time;
		};
		if(time < MAZ_AN_frogCroakTime) exitWith {};
		if !(call MAZ_AN_fnc_checkForNearSwamp) exitWith {};

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

		private _randomSleep = selectRandom [5,6,7,8,9];
		MAZ_AN_frogCroakTime = time + _randomSleep;
	};

	MAZ_AN_fnc_checkForNearSwamp = {
		private _return = false;
		if(player distance [21057.9,14751.2] < 1000 && (count (nearestTerrainObjects [player,["BUSH"],100,false,true]) > 50)) then {
			_return = true;
		};
		_return
	};

	MAZ_AN_fnc_handleGasMaskSound = {
		if(!MAZ_AN_gasMaskSounds) exitWith {};
		if(isNil "MAZ_AN_gasMaskTime") then {
			MAZ_AN_gasMaskTime = time;
		};
		if(time < MAZ_AN_gasMaskTime) exitWith {};
		if !(call MAZ_AN_fnc_checkForGasMask || call MAZ_AN_fnc_checkForPilotHelmet) exitWith {};

		private _randomType = selectRandom [1,2,3,4];
		private _soundData = if(call MAZ_AN_fnc_checkForPilotHelmet) then {[5,175,true]} else {[2,5,false]};
		playSound3D [format ["A3\sounds_f\characters\human-sfx\diver-breath-%1.wss",_randomType],player,false,getPosASL player, _soundData # 0, 1, _soundData # 1, 0, _soundData # 2];
		playSound3D [format ["A3\sounds_f\characters\human-sfx\diver-breath-%1.wss",_randomType],player,false,getPosASL player, _soundData # 0, 1, _soundData # 1, 0, _soundData # 2];
		if(call MAZ_AN_fnc_checkForPilotHelmet && !isNil "MAZ_AE_aircraftEnhancementEnable") then {
			(call MAZ_AE_fnc_getGForces) params ["_current","_avgStr"];
			private _fatigue = 1 - _avgStr;
			private _randomSleep = (selectRandom [2.5,2.75,3,3.25,3.5]) * _fatigue;
			if(_randomSleep < 1.5) then {
				_randomSleep = 1.5;
			};
			MAZ_AN_gasMaskTime = time + _randomSleep;
		} else {
			private _fatigue = 1 - (getFatigue player);
			private _randomSleep = (selectRandom [2.5,2.75,3,3.25,3.5]) * _fatigue;
			if(_randomSleep < 1.5) then {
				_randomSleep = 1.5;
			};
			MAZ_AN_gasMaskTime = time + _randomSleep;
		};
	};

	MAZ_AN_fnc_handleGasMaskOverlay = {
		if(!MAZ_AN_gasMaskOverlay) exitWith {};
		if !(call MAZ_AN_fnc_checkForGasMask) exitWith {call MAZ_AN_fnc_destroyGasMaskOverlay;};

		if(backpack player in ["B_CombinationUnitRespirator_01_F","B_SCBA_01_F"]) then {
			call MAZ_AN_fnc_addGasMaskHose;
		};
		
		if (cameraView == "External") exitWith {
			call MAZ_AN_fnc_destroyGasMaskOverlay;
		};

		private _gasMaskOverlay = uiNamespace getVariable ["gasMaskOverlay",controlNull];
		if(isNull _gasMaskOverlay) then {
			with uiNamespace do {
				private _gasMaskType = "";
				switch (goggles player) do {
					case "G_AirPurifyingRespirator_01_nofilter_F";
					case "G_AirPurifyingRespirator_01_F": {_gasMaskType = "\a3\ui_f_enoch\data\objects\data\optics_apr_ca.paa";};
					case "G_AirPurifyingRespirator_02_sand_F";
					case "G_AirPurifyingRespirator_02_olive_F";
					case "G_AirPurifyingRespirator_02_black_nofilter_F";
					case "G_AirPurifyingRespirator_02_black_F": {_gasMaskType = "\a3\ui_f_enoch\data\objects\data\optics_APR_02_CA.paa";};
					case "G_RegulatorMask_F": {_gasMaskType = "\a3\ui_f_enoch\data\objects\data\optics_regulator_CA.paa";};
				};
				gasMaskOverlay = (findDisplay 46) ctrlCreate ["RscPicture",-1];
				gasMaskOverlay ctrlSetPosition [0 * safezoneW + safezoneX,0 * safezoneH + safezoneY,1.00547 * safezoneW,1.012 * safezoneH];
				gasMaskOverlay ctrlSetText _gasMaskType;
				gasMaskOverlay ctrlSetAngle [180,0.5,0.5];
				gasMaskOverlay ctrlCommit 0;
			};
		};
	};

	MAZ_AN_fnc_checkForGasMask = {
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

	MAZ_AN_fnc_checkForPilotHelmet = {
		private _helmets = [
			"H_PilotHelmetFighter_I",
			"H_PilotHelmetFighter_O",
			"H_PilotHelmetFighter_B",
			"H_PilotHelmetFighter_I_E"
		];
		private _return = false;
		if(headgear player in _helmets && (vehicle player) isKindOf "Plane") then {
			_return = true;
		};
		_return
	};

	MAZ_AN_fnc_addGasMaskHose = {
		private _hoseTexture = "a3\supplies_f_enoch\bags\data\b_cur_01_co.paa";
		private _bp = backpack player;
		private _ggl = goggles player;

		if(_bp == "B_SCBA_01_F") exitWith {
			private _textures = [];
			if(_ggl == "G_RegulatorMask_F") then {
				_textures = ["",_hoseTexture];
			} else {
				_textures = [_hoseTexture,""];
			};
			{[backpackContainer player, [_forEachIndex + 1,_x]] remoteExec ["setObjectTexture"]} forEach _textures;
		};

		[backpackContainer player, [1, _hoseTexture]] remoteExec ['setObjectTexture'];
		[backpackContainer player, [2, _hoseTexture]] remoteExec ['setObjectTexture'];

		if(_ggl in ["G_AirPurifyingRespirator_02_black_F","G_AirPurifyingRespirator_01_F"]) then {
			removeGoggles player;
			private _newGoggles = _ggl insert [(count _ggl) - 1, "noFilter_"];
			player linkItem _newGoggles;
		};
	};

	MAZ_AN_fnc_destroyGasMaskOverlay = {
		private _gasMaskOverlay = uiNamespace getVariable ["gasMaskOverlay",controlNull];
		if(!isNull _gasMaskOverlay) then {
			ctrlDelete _gasMaskOverlay;
			uiNamespace setVariable ["gasMaskOverlay",controlNull];
		}
	};

	MAZ_AN_fnc_handleRoosterSound = {
		if(!MAZ_AN_roosters) exitWith {};
		if(isNil "MAZ_AN_roosterTime") then {
			MAZ_AN_roosterTime = time;
		};
		if(time < MAZ_AN_roosterTime) exitWith {};
		if !(dayTime > 5 && dayTime < 5.6) exitWith {};

		private _randomDir = round (random 360);
		private _randomPos = player getRelPos [150,_randomDir];
		playSound3D ["a3\sounds_f\environment\animals\chickens\chicken_01.wss",nil,false,_randomPos, 5, 1, 250,0,true];

		private _randomSleep = selectRandom [15,16,17,18,19,20,21,22,23,24,25];
		MAZ_AN_roosterTime = time + _randomSleep;
	};

	MAZ_AN_fnc_scaredBirds = {
		if !( (count (nearestTerrainObjects [position player,["Tree"],125,false,true])) > 75) exitWith {};
		
		private _suppressor = (player weaponAccessories (currentWeapon player)) select 0;
		if(_suppressor != "") exitWith {};

		if(isNil "MAZ_AN_birdTime") then {
			MAZ_AN_birdTime = time;
		};
		if(time < MAZ_AN_birdTime) exitWith {};

		private _randomPos = selectRandom (nearestTerrainObjects [position player,["Small Tree","Tree"],50,false,true]);
		playSound3D ["A3\sounds_f\environment\animals\scared_animal6.wss",nil,false,_randomPos, 5, 1, 200,0,true];
		playSound3D ["A3\sounds_f\environment\animals\scared_animal6.wss",nil,false,_randomPos, 5, 1, 200,0,true];
		playSound3D ["A3\sounds_f\environment\animals\scared_animal6.wss",nil,false,_randomPos, 5, 1, 200,0,true];
		playSound3D ["A3\sounds_f\environment\animals\scared_animal6.wss",nil,false,_randomPos, 5, 1, 200,0,true];
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

	[] spawn {
		waitUntil {uisleep 0.1;!isNull (findDisplay 46) && alive player};
		sleep 0.1;
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_AN"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};

		MAZ_EH_FiredMan_ambientNoises = player addEventHandler ["FiredMan",{
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
			if(!MAZ_AN_scaredBirds) exitWith {};
			call MAZ_AN_fnc_scaredBirds;
			MAZ_AN_birdTime = time + 300;
		}];

		[] spawn MAZ_AN_fnc_ambientNoisesMainLoop;
	};

	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		[
			"Ambient Noises", 
			"Around the map you will be able to hear various ambient noises. Generally meant to add immersion and make the world less empty.",
			[
				"Dogs bark in towns",
				"Gas masks and pilot helmets make breathing noises",
				"Birds get scared off when players shoot in forests unsuppressed",
				"Froaks croak in swamps",
				"Roosters crow in the mornings"
			]
		] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Ambient Noises System has been loaded! The world is suddenly less soulless and empty!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
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