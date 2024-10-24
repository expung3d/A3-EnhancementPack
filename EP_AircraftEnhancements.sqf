comment "
	Credit to [TW] Aaren for his mod 'Advance Aero Effects'. Without it this wouldn't be possible.
	https://steamcommunity.com/sharedfiles/filedetails/?id=2309871702
";

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
if(missionNamespace getVariable ["MAZ_AE_aircraftEnhancementEnable",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Aircraft enhancements already running!";};

private _varName = "MAZ_System_EnhancementPack_AE";
private _myJIPCode = "MAZ_EPSystem_AE_JIP";

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["[AE] Aircraft Enhancements","Whether to enable the Aircraft Enhancements system.\nDisabling this mid-game will keep the systems running on aircraft already spawned.","MAZ_AE_aircraftEnhancementEnable",true,"TOGGLE",[],"MAZ_AE"] call MAZ_EP_fnc_addNewSetting;
	["[AE] Collision Lights","Whether to add new, brighter collision lights to aircraft.\nVery buggy and experimental.","MAZ_AE_NewLights",false,"TOGGLE",[],"MAZ_AE"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	
	MAZ_AE_aircraftWingspans = [["I_Plane_Fighter_03_dynamicLoadout_F",9.46],["B_Plane_CAS_01_dynamicLoadout_F",17.53],["O_Plane_CAS_02_dynamicLoadout_F",13.62],["B_UAV_02_dynamicLoadout_F",14],["O_UAV_02_dynamicLoadout_F",14],["I_UAV_02_dynamicLoadout_F",14],["C_Plane_Civil_01_F",14],["C_Plane_Civil_01_racing_F",14],["I_C_Plane_Civil_01_F",14],["O_T_UAV_04_CAS_F",14],["B_T_VTOL_01_infantry_F",14],["B_T_VTOL_01_vehicle_F",14],["B_T_VTOL_01_armed_F",14],["O_T_VTOL_02_infantry_dynamicLoadout_F",14],["O_T_VTOL_02_vehicle_dynamicLoadout_F",14],["B_Plane_Fighter_01_F",13.56],["B_Plane_Fighter_01_Stealth_F",13.56],["O_Plane_Fighter_02_F",14.1],["O_Plane_Fighter_02_Stealth_F",14.1],["I_Plane_Fighter_04_F",8.6],["B_UAV_05_F",14]];

	MAZ_AE_groundTypes = [
		[[1,1,0.46,0],[1,1,0.46,0.01],[1,1,0.46,0.02],[1,1,0.46,0.06],[1,1,0.46,0.05],[1,1,0.46,0.02],[1,1,0.46,0]],
		[[1,1,0.46,0],[1,1,0.46,0.01],[1,1,0.46,0.02],[1,1,0.46,0.06],[1,1,0.46,0.05],[1,1,0.46,0.02],[1,1,0.46,0]],
		[[0.25,0.25,0.2,0],[0.25,0.25,0.2,0.04],[0.25,0.25,0.2,0.08],[0.25,0.25,0.2,0.24],[0.25,0.25,0.2,0.20],[0.25,0.25,0.2,0.08],[0.25,0.25,0.2,0.04],[0.25,0.25,0.2,0]],
		[[0.7,0.8,1,0],[0.7,0.8,1,0.05],[0.7,0.8,1,0.1],[0.7,0.8,1,0.12],[0.7,0.8,1,0.08],[0.7,0.8,1,0.04],[0.7,0.8,1,0.02],[0.85,0.9,1,0]]
	];
	comment "
		0 - Default, 
		1 - Beach, 
		2 - Dust, 
		3 - Water
	";

	MAZ_AE_LightConfig = [
		[
			"Plane_CAS_01_base_F",
			[
				[[-8.69,-0.25,0.25]],
				[[8.69,-0.25,0.25]],
				[[0,-7.8,-0.21]]
			],
			[
				[-8.7,-0.25,0.25],
				[8.69,-0.25,0.25],
				[0,2.58,0.97],
				[-0.05,3.725,-0.88]
			],
			[
				[0.1,0.9],
				[0.1,0.9],
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				],true],
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				],true]
			]
		],
		[
			"Plane_Fighter_01_Base_F",
			[
				[[-6.2,-4.2,-0.45],[-1.5,1.65,-0.15],[-1.75,-5.75,2.05]],
				[[6.2,-4.2,-0.45],[1.5,1.65,-0.15],[1.755,-5.75,2.05]],
				[]
			],
			[
				[1.85,-6.9,2.28],
				[-1.77,-6.9,2.28]
			],
			[
				[0.1,0.9],
				[0.1,0.9]
			]
		],
		[
			"Plane_Civil_01_base_F",
			[
				[[-5.42,0.4,-0.55]],
				[[5.43,0.4,-0.55]],
				[]
			],
			[
				[0,-1.19,-0.65],
				[-5.42,0.35,-0.56],
				[5.43,0.35,-0.56],
				[0.01,0.4,0.52]
			],
			[
				[0.1,0.9,[
					[0.1,0.1,0.1],
					[25,25,25]
				],true],
				[0.2,0.8,[
					[0.1,0.1,0.1],
					[25,25,25]
				]],
				[0.2,0.8,[
					[0.1,0.1,0.1],
					[25,25,25]
				]],
				[0.1,0.9,[
					[0.1,0.1,0.1],
					[25,25,25]
				],true]
			]
		],
		[
			"VTOL_01_base_F",
			[
				[[-16.5,3.95,-0.9]],
				[[16.5,3.95,-0.9]],
				[[4,-13.3,1.55],[-4,-13.3,1.55]]
			],
			[
				[-4,-11.8,1.8]
			],
			[
				[0.1,0.9]
			]
		],
		[
			"UAV_04_base_F",
			[
				[[-4.45,-1.78,-0.55]],
				[[4.45,-1.78,-0.55]],
				[]
			],
			[
				[0.0,-0.8,0.05],
				[0.0,-0.45,-0.88]
			],
			[
				[0.1,0.9],
				[0.1,0.9]
			]
		],
		[
			"UAV_02_base_F",
			[
				[[-5.04,-2.4,-0.4]],
				[[5.04,-2.4,-0.4]],
				[]
			],
			[
				
			],
			[
				
			]
		],
		[
			"Plane_CAS_02_base_F",
			[
				[[-1.6,0.45,-1.0]],
				[[1.6,0.45,-1.0]],
				[[0.0,-7.7,1.65]]
			],
			[
				[0.0,-2.7,-0.25]
			],
			[
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				]]
			]
		],
		[
			"Plane_Fighter_02_Base_F",
			[
				[[-7.6,-6.65,0.0]],
				[[7.6,-6.65,0.0]],
				[]
			],
			[
				[0.0,-10.25,-0.2]
			],
			[
				[0.1,0.9]
			]
		],
		[
			"VTOL_02_base_F",
			[
				[[-8.175,-0.35,-0.95],[-3.475,0.15,-1.6]],
				[[8.175,-0.35,-0.95],[3.475,0.15,-1.6]],
				[[-3.835,-8.39,2.85],[3.835,-8.39,2.85]]
			],
			[
				[0.0,2.7,-2.45]
			],
			[
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				]]
			]
		],
		[
			"Plane_Fighter_04_Base_F",
			[
				[[-1.05,1.5,-0.85],[-0.55,-5.8,-0.5]],
				[[1.05,1.5,-0.85],[0.55,-5.8,-0.5]],
				[]
			],
			[
				[0.0,-5.35,2.25]
			],
			[
				[0.1,0.9]
			]
		],
		[
			"Plane_Fighter_03_base_F",
			[
				[[-5.075,0.725,-1.2]],
				[[5.075,0.725,-1.2]],
				[[0.0,-6.45,2.45]]
			],
			[
				[0.0,-1.825,0.25]
			],
			[
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				]]
			]
		]
	];

	MAZ_AE_LightConfigHeli = [
		[
			"Heli_Transport_01_base_F",
			[
				[[-1.35,5.1,-1.065]],
				[[1.35,5.1,-1.065]],
				[[0.0,-8.25,1.25]]
			],
			[
				[0.0,-3.06,-1.725]
			],
			[
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				]]
			]
		],
		[
			"Heli_Light_01_base_F",
			[
				[[-1.08,2.435,-1.5]],
				[[1.08,2.435,-1.5]],
				[[0.0,-4.3,0.2]]
			],
			[
				[0.12,-4.57,1.0]
			],
			[
				[0.1,0.9]
			]
		],
		[
			"Heli_Attack_01_base_F",
			[
				[[-1.0,3.05,-0.635]],
				[[1.0,3.05,-0.635]],
				[[-0.1,-6.75,-0.1]]
			],
			[
				[0.1,1.55,-1.625]
			],
			[
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				]]
			]
		],
		[
			"Heli_Transport_03_base_F",
			[
				[[-2.35,1.45,-1.64]],
				[[2.35,1.45,-1.64]],
				[[0.0,-6.7,0.54]]
			],
			[
				[-0.04,0.9,-2.7]
			],
			[
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				]]
			]
		],
		[
			"UAV_03_base_F",
			[
				[[-0.55,1.9,-0.47],[-0.22,-4.335,0.075]],
				[[0.55,1.9,-0.47],[0.22,-4.335,0.075]],
				[[0.0,-5.2,0.72]]
			],
			[
				[0.0,1.6,-0.9]
			],
			[
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				]]
			]
		],
		[
			"UAV_01_base_F",
			[
				[[-0.2,0.22,0.01],[-0.2,-0.18,0.01]],
				[[0.2,0.22,0.01],[0.2,-0.18,0.01]],
				[]
			],
			[
				[0.0,-0.2,0.05]
			],
			[
				[0.1,0.9]
			]
		],
		[
			"Heli_Attack_02_base_F",
			[
				[[-3.4,-0.9,-1.25]],
				[[3.4,-0.9,-1.25]],
				[[0.0,-7.55,-1.8]]
			],
			[
				[0.0,1.45,-2.635]
			],
			[
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				],true]
			]
		],
		[
			"Heli_Light_02_base_F",
			[
				[[-0.825,4.2,-1.45]],
				[[0.825,4.2,-1.45]],
				[[0.1,-7.8,-0.1]]
			],
			[
				[0.0,0.4,1.1]
			],
			[
				[0.1,0.9]
			]
		],
		[
			"Heli_Transport_04_base_F",
			[
				[[-3.735,-0.3,-1.0]],
				[[3.735,-0.3,-1.0]],
				[[0.0,-8.75,-0.25]]
			],
			[
				[0.0,-1.65,1.0],
				[0.0,3.525,-2.3]
			],
			[
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				]],
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				],true]
			]
		],
		[
			"Heli_light_03_base_F",
			[
				[[-1.0,3.75,-1.025]],
				[[0.975,3.75,-1.025]],
				[[0.0,-7.3,1.05]]
			],
			[
				[-0.065,-6.9,1.325],
				[0.0,1.975,-1.35]
			],
			[
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				]],
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				]]
			]
		],
		[
			"Heli_Transport_02_base_F",
			[
				[[-2.25,0.55,-2.5]],
				[[2.25,0.55,-2.5]],
				[[0.0,-9.8,0.05]]
			],
			[
				[-0.3,-10.3,2.2],
				[0.7,1.065,-2.925]
			],
			[
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				]],
				[0.2,1.3,[
					[0.1,0,0],
					[10,0,0]
				]]
			]
		]
	];

	comment "
		[
			PlaneType,
			[CollisionLights (Solid)
				AttachPos (Red),
				AttachPos (Green),
				AttachPos (White)
			],
			[StrobeLights (Flashing)
				AttachPos,
				AttachPos,
				...
			],
			[
				[For each StrobeLight
					flashDuration,
					pauseDuration,
					[colorOverride
						ambient,
						color
					],
					hideInFirst
				]
			]
		]
	";

	MAZ_AE_weaponShakeIntesity = [
		["20mm",[
			[1],
			[7,6,5]
		]],
		["30mm",[
			[1],
			[7,6,5]
		]],
		["40mm",[
			[1.5,2],
			[8,7,6]
		]],
		["105mm",[
			[4,5,6],
			[5,6,7]
		]],
		["m134_minigun",[
			[1],
			[6,5,4]
		]],
		["dar",[
			[1,1.5],
			[4,5,6]
		]],
		["dagr",[
			[1,1.5],
			[4,5,6]
		]],
		["lmg_minigun_transport",[
			[1],
			[6,5,4]
		]],
		["bomb",[
			[2,2.5],
			[3,4,5]
		]],
		["gbu",[
			[2,2.5],
			[3,4,5]
		]]
	];

	MAZ_AE_fnc_aircraftEnhancementSystem = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_AE"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};

		GForces = [];
		GForces resize 30;
		GForces = GForces apply {1};
		GForcesIndex = 0;
		lastUpdateTime = 0;
		oldVel = [0,0,0];

		MAZ_AE_fnc_serverLoop = {
			if(time < (missionNamespace getVariable ["MAZ_AE_loopTime",time])) exitWith {};
			call MAZ_AE_fnc_initLoop;
			missionNamespace setVariable ["MAZ_AE_loopTime",time + 1.5];
		};
		
		MAZ_AE_fnc_initLoop = {
			if(!MAZ_AE_aircraftEnhancementEnable) exitWith {};
			{
				if(!((typeOf _x) isKindOf "Plane") && !((typeOf _x) isKindOf "Helicopter")) then {continue};
				private _isSetup = _x getVariable ["MAZ_AE_isSetup",false];
				if(!_isSetup) then {
					if((typeOf _x) isKindOf "Plane") then {
						[_x] call MAZ_AE_fnc_findEngines;
						private _wingspan = [_x] call MAZ_AE_fnc_getWingspan;
						_x setVariable ["MAZ_AE_wingspan",_wingspan,true];
						_x setVariable ["MAZ_AE_vaporHeight",2000 + (random 20),true];
						[_x] call MAZ_AE_fnc_resetVehicleOnDeath;
						[_x] call MAZ_AE_fnc_weaponFiringShake;
						[_x,{
							waitUntil {!isNil "MAZ_AE_fnc_loopForVehicle"};
							[_this] spawn MAZ_AE_fnc_loopForVehicle;
						}] remoteExec ["spawn",0,_x];
					};
					if((typeOf _x) isKindOf "Helicopter") then {
						[_x] call MAZ_AE_fnc_handleAddHelicopterDoorActions;
						[_x] call MAZ_AE_fnc_resetVehicleOnDeath;
						[_x,{
							waitUntil {!isNil "MAZ_AE_fnc_loopForHelicopter"};
							[_this] spawn MAZ_AE_fnc_loopForHelicopter;
							[_this] call MAZ_AE_fnc_heliCrashLanding;
						}] remoteExec ["spawn",0,_x];
					};
					_x setVariable ["MAZ_AE_isSetup",true,true];
				};
			}forEach vehicles;
		};

		MAZ_AE_fnc_loopForVehicle = {
			params ["_vehicle"];
			if((isMultiplayer && !isServer) || (!isMultiplayer)) then {
				while {!isNull _vehicle && alive _vehicle} do {
					[_vehicle] call MAZ_AE_fnc_mainLoop;
					sleep 0.5;
				};
			};
		};

		MAZ_AE_fnc_loopForHelicopter = {
			params ["_heli"];
			if(!isServer) then {
				while {!isNull _heli && alive _heli} do {
					[_heli] call MAZ_AE_fnc_mainLoopHeli;
					sleep 1;
				};
			};
		};

		MAZ_AE_fnc_mainLoopHeli = {
			params ["_heli"];
			if(!isNull _heli) then {
				private _isLightsOn = _heli getVariable ["MAZ_AE_colLightsEHOn",false];
				if(!_isLightsOn) then {
					_heli spawn MAZ_AE_fnc_CollisionLightsOnEH;
				};
				if((typeOf _heli) isKindOf "UAV_01_base_F" || (typeOf _heli) isKindOf "UAV_03_base_F" || (typeOf _heli) isKindOf "UAV_06_base_F") exitWith {};
				private _alt = (getPosATL _heli) # 2;
				if(
					(isEngineOn _heli) && 
					(_alt < 15 || (getPosASL _heli) # 2 < 15) && 
					!("Concrete" in (surfaceType (getPos _heli)))
				) then {
					private _isGE = _heli getVariable ["MAZ_AE_groundEffectActive",false];
					if(!_isGE) then {	
						[_heli,8] spawn MAZ_AE_fnc_groundEffect;
					};
					_heli setVariable ["MAZ_AE_groundEffectActive",true];
				} else {
					_heli setVariable ["MAZ_AE_groundEffectActive",false];
				};
			} else {
				_heli setVariable ["MAZ_AE_groundEffectActive",false];
			};
		};

		MAZ_AE_fnc_mainLoop = {
			params ["_plane"];
			private _exCount = _plane getVariable ["MAZ_AE_ExhaustsCount",0];
			private _exPos = _plane getVariable ["MAZ_AE_Exhaust_POS",[]];
			private _engineOffsets = _plane getVariable ["MAZ_AE_vehicleEngineOffset",[]];
			private _planePlayer = cameraOn;
			private _speed = speed _plane;
			private _speedPlayer = speed _planePlayer;
			if(player in _plane) then {
				if(isNil "GForces_Filter") then {
					GForces_Filter = ppEffectCreate ["ColorCorrections", 6500];
					GForces_Filter ppEffectForceInNVG true;
					GForces_Filter ppEffectAdjust [1,1,0,[0,0,0,0],[0,0,0,0],[1,1,1,1],[10,10,0,0,0,0.1,0.5]];
					GForces_Filter ppEffectCommit 0.4;
					GForces_Filter ppEffectEnable true;
				};
				[_planePlayer] call MAZ_AE_fnc_gForce; 
				private _turbDistanceFound = _planePlayer getVariable ["MAZ_AE_TurbulentSourceDistance_Found",false];
				if(cameraView == "Internal") then {
					[_plane,_exCount,_engineOffsets,cameraOn] call MAZ_AE_fnc_exhaustOffsets;

					if(isTouchingGround _planePlayer) then {
						[_planePlayer,_speedPlayer] call MAZ_AE_fnc_taxiEffect;
					} else {
						comment "Turb plane";
						if(_speed > 200 && _turbDistanceFound) then {
							[_planePlayer,_exCount] call MAZ_AE_fnc_turbulence;
						};

						comment "Turb world";
						private _posPlane = getPosASL _plane;
						private _bottomPos = +_posPlane;
						_bottomPos set [2,0];
						private _intersects = lineIntersectsSurfaces [getPosASL _plane,_bottomPos];
						(_intersects select 0) params ["_posASL","","","_intersectObject","",""];
						private _heightAboveGround = (_posPlane # 2) - (_posASL # 2);
						
						[_plane,_heightAboveGround,_speed] call MAZ_AE_fnc_turbulenceWorld;
						
						comment "Gear Factor";
						[_plane,_speed] call MAZ_AE_fnc_GearFactor;
					};
				};
			};
			if(!isNull _plane) then {
				private _isLightsOn = _plane getVariable ["MAZ_AE_colLightsEHOn",false];
				if(!_isLightsOn) then {
					_plane spawn MAZ_AE_fnc_CollisionLightsOnEH;
				};

				private _landedEH = _plane getVariable ["MAZ_AE_landedEventhandler",-1];
				if(_landedEH == -1) then {
					_plane setVariable [
						"MAZ_AE_landedEventhandler",
						_plane addEventHandler ["LandedTouchDown",{
							params ["_plane","_airportID"];
							[_plane] call MAZ_AE_fnc_landedEH;
						}],true
					];
				};
				if(isTouchingGround player && _speed >= 150 && !(player in _plane)) then {
					_plane call MAZ_AE_fnc_camShake;
				};

				private _alt = (getPosATL _plane) # 2;
				if(_alt > (_plane getVariable "MAZ_AE_vaporHeight")) then {
					private _isVaporActive = _plane getVariable ["MAZ_AE_vaporActive",false];
					if(!_isVaporActive) then {
						[_plane,_exCount,_exPos] spawn MAZ_AE_fnc_vaporEffect;
						_plane setVariable ["MAZ_AE_vaporActive",true];
					};
				} else {
					_plane setVariable ["MAZ_AE_vaporActive",false];
				};

				private _geHeight = [_plane] call MAZ_AE_fnc_getGroundEffectHeight;
				if(
					!(isTouchingGround _plane) && 
					(_alt < _geHeight || (getPosASL _plane) # 2 < _geHeight) && 
					!("Concrete" in (surfaceType (getPos _plane)))
				) then {
					private _isGE = _plane getVariable ["MAZ_AE_groundEffectActive",false];
					if(!_isGE) then {	
						[_plane,-5] spawn MAZ_AE_fnc_groundEffect;
					};
					_plane setVariable ["MAZ_AE_groundEffectActive",true];
				} else {
					_plane setVariable ["MAZ_AE_groundEffectActive",false];
				};
			} else {
				_plane setVariable ["MAZ_AE_groundEffectActive",false];
				_plane setVariable ["MAZ_AE_vaporActive",false];
			};
		};

		MAZ_AE_fnc_findEngines = {
			params["_plane"];
			private _exhausts = "true" configClasses (configFile >> "CfgVehicles" >> typeOf _plane >> "Exhausts");

			private _exhaustsCount = _plane getVariable ["MAZ_AE_ExhaustsCount",count _exhausts];
			private _exhaustPos = _plane getVariable ["MAZ_AE_Exhaust_POS",[]];
			private _engineOffset = _plane getVariable ["MAZ_AE_vehicleEngineOffset",[]];
			private _exhaustDir = _plane getVariable ["MAZ_AE_ExhaustDirection",[]];

			_plane setVariable ["MAZ_AE_ExhaustsCount",count _exhausts,true];

			for "_i" from 0 to (_exhaustsCount - 1) do {
				private _engine = _exhausts # _i;
				private _pos = getText (_engine >> "position");
				_exhaustPos pushback _pos;

				private _offset = _plane selectionPosition _pos;
				_engineOffset pushback _offset;

				private _dir = _plane selectionVectorDirAndUp [_pos, "Memory"];
				private _backDir = [((_dir # 0) vectorMultiply -1), ((_dir # 1) vectorMultiply -1)];
				_exhaustDir pushback _backDir;
			};

			_plane setVariable ["MAZ_AE_Exhaust_POS",_exhaustPos,true];
			_plane setVariable ["MAZ_AE_vehicleEngineOffset",_engineOffset,true];
			_plane setVariable ["MAZ_AE_ExhaustDirection",_exhaustDir,true];
			_plane setVariable ["MAZ_AE_findEngine",true,true];
		};

		MAZ_AE_fnc_turbulence = {
			params ["_plane","_exCount"];
			private _sourceDistance = _plane getVariable "MAZ_AE_TurbulentSourceDistance";
			_sourceDistance params [["_dis0",-1],["_dis1",-1],["_dis2",-1],["_dis3",-1]];
			private _dis = selectMin _sourceDistance;

			private _fq = 10;
			if(_dis > 0 && _dis <= 30 && _dis > 20) then {
				_fq = 35;
			};
			if(_dis > 0 && _dis <= 20) then {
				_fq = 45;
			};
			if(_dis > 0 && _dis <= 10) then {
				addCamShake [2, 2, _fq];
			};
		};

		MAZ_AE_fnc_doStallWarning = {
			params ["_plane"];
			waitUntil {
				playSound3D ["A3\Sounds_F\air\Heli_Attack_02\alarm.wss", _plane, false, getPosASL _plane, 1, 1, 0];
				sleep 1.25;
				
				!(_plane getVariable ["MAZ_AE_isStalling",false])
			};
		};

		MAZ_AE_fnc_turbulenceWorld = {
			params ["_plane","_alt","_speed"];
			comment 'if (_plane iskindof "VTOL_Base_F") exitWith {}';
			private _stallSpeed = getNumber (configFile >> "CfgVehicles" >> typeOf _plane >> "stallSpeed");
			private _maxSpeed = getNumber (configFile >> "CfgVehicles" >> typeOf _plane >> "maxSpeed");
			if (_plane iskindof "VTOL_Base_F") then {_stallSpeed = 130;};
			private _fqT = selectRandom [8,5,6];
			if(_speed >= 50) then {
				if(_speed < _stallSpeed && _alt > 5) then {
					comment "Stalling";
					addCamShake [1,1,_fqT];
					private _isStalling = _plane getVariable ["MAZ_AE_isStalling",false];
					if(!_isStalling) then {
						[_plane] spawn MAZ_AE_fnc_doStallWarning;
						_plane setVariable ["MAZ_AE_isStalling",true];
					};
				} else {
					_plane setVariable ["MAZ_AE_isStalling",false];
				};
				if(_speed > 700 && _alt < 50) then {
					addCamShake [1,2,_fqT];
				};
			};
		};

		MAZ_AE_fnc_getWingspan = {
			params ["_plane"];
			private _wingspan = -1;
			{
				_x params ["_type","_span"];
				if((typeOf _plane) == _type) exitWith {_wingspan = _span};
			}forEach MAZ_AE_aircraftWingspans;
			_wingspan
		};

		MAZ_AE_fnc_getGroundEffectHeight = {
			params ["_vehicle"];
			private _speed = speed _vehicle;
			(_vehicle call BIS_fnc_getPitchBank) params ["_pitch","_bank"];
			if (_pitch > 90) then {
				_pitch = 90;
			};
			if (_pitch < 0) then {
				_pitch = 0;
			};

			private _ground_speed_var = (0.1 * _speed) + 1;
			if (_ground_speed_var > 2) then {
				_ground_speed_var = 2;
			};

			private _ground_result_var = 0.5 * _pitch * _ground_speed_var;
			private _ground_result = 50 + _ground_result_var;
			private _wingspan = _vehicle getVariable ["MAZ_AE_wingspan",-1];
			if (_wingspan != -1) then {
				_ground_result = _wingspan + _ground_result_var;
			};
			_ground_result
		};

		MAZ_AE_fnc_camShake = {
			private _plane = _this;
			if ((_plane iskindof "UAV_02_base_F") || (_plane iskindof "UAV_04_base_F")) exitWith {};
			private _dist = player distance _plane;
			if ((_dist > 5) and (_dist <= 50)) then {
				addCamShake [3, 2, 10];
			};
		};

		MAZ_AE_fnc_surfaceTypeEH = {
			params ["_plane","_depos","_currentType"];
			if (surfaceIsWater _depos) then {
				_plane setVariable ["MAZ_AE_GroundType","Water"];
			} else {
				comment "Beach";
				if ((surfaceType _depos == "#GdtBeach")) then {
					_plane setVariable ["MAZ_AE_GroundType","Beach"];
				};
				comment "Dust";
				if ((surfaceType _depos != "#GdtStratisConcrete") and (surfaceType _depos != "#GdtConcrete") and (surfaceType _depos != "#GdtSeabed") and (surfaceType _depos != "#GdtBeach")) then {
					_plane setVariable ["MAZ_AE_GroundType","Dust"];
				};
			};

			_plane setVariable ["MAZ_AE_GroundTypeChanged",false];
			if ((_plane getVariable ["MAZ_AE_GroundType","Default"]) != _currentType) then {
				_plane setVariable ["MAZ_AE_GroundTypeChanged",true];
			};
		};

		MAZ_AE_fnc_resetVehicleOnDeath = {
			params ["_plane"];
			_plane setVariable [
				"MAZ_AE_EH_Killed",
				_plane addEventHandler ["Killed",{
					params ["_unit", "_killer", "_instigator", "_useEffects"];
					_unit setVariable ["MAZ_AE_groundEffectActive",false];
					_unit setVariable ["MAZ_AE_vaporActive",false];
					private _particles = _unit getVariable ["MAZ_AE_GroundParticles",[]];
					{
						deleteVehicle _x;
					}forEach _particles;
					_unit setVariable ["MAZ_AE_GroundParticles", []];
				}],true
			];
			_plane setVariable [
				"MAZ_AE_EH_Delete",
				_plane addEventHandler ["Deleted",{
					params ["_unit"];
					_unit setVariable ["MAZ_AE_groundEffectActive",false];
					_unit setVariable ["MAZ_AE_vaporActive",false];
					private _particles = _unit getVariable ["MAZ_AE_GroundParticles",[]];
					{
						deleteVehicle _x;
					}forEach _particles;
					_unit setVariable ["MAZ_AE_GroundParticles", []];
				}],true
			];
		};

		MAZ_AE_fnc_groundEffect = {
			params ["_plane","_backDist"];
			_particle_Setups = {
				params [
					"_source00","_source01",
					"_ParticleShape",
					"_Particle00_Time","_Particle01_Time",
					"_velocity","_speed",
					"_weight","_volume",
					"_Particle00_Size","_Particle01_Size",
					"_SurfaceType_Pick"
				];
				_source00 setParticleParams [
					_ParticleShape, "", "Billboard",
					1, _Particle00_Time, [0, (((_velocity # 1) * 0.05) - (_speed*0.05)), 0], [0, 0, 0], 1.25, _weight, _volume, 0.1, _Particle00_Size,
					_SurfaceType_Pick,
					[1000], 0.1, 0.05, "", "", _source00, 0, true
				];

				_source01 setParticleParams [
					_ParticleShape, "", "Billboard",
					1, _Particle01_Time, [0, (((_velocity # 1) * 0.05) - (_speed*0.05)), 0], [0, 0, 0], 1.25, _weight, _volume, 0.1, _Particle01_Size,
					_SurfaceType_Pick,
					[1000], 0.1, 0.05, "", "", _source01, 0, true
				];
			};

			_particles = {
				params["_plane","_SurfaceType_Pick","_Depos","_velocity","_speed","_ParticleShape","_Particle_Settings","_Particle00_Setups","_Particle01_Setups","_particle_Setups","_backDist"];

				_Particle_Settings params ["_weight","_volume"];

				_Particle00_Setups params ["_Particle00_Time","_Particle00_Size"];
				_Particle01_Setups params ["_Particle01_Time","_Particle01_Size","_particle01_CycleSpeed"];

				_SurfaceChanged = _plane getVariable ["MAZ_AE_GroundTypeChanged",false];

				_Engine_Offset = -0.06*_speed;

				if (_speed <= 300) then {
					_speed = 300;
				};
				if (_speed >= 500) then {
					_speed = 500;
				};

				_source00 = objNull;
				_source01 = objNull;

				_Ground_Paricles = _plane getVariable ["MAZ_AE_GroundParticles",[]];
				_Particle_Count = count _Ground_Paricles;

				if (_Particle_Count == 0) then {
					_source00 = "#particlesource" createVehicleLocal _Depos;
					_source01 = "#particlesource" createVehicleLocal _Depos;
					_plane setVariable ["MAZ_AE_GroundParticles", [_source00,_source01]];

					[
						_source00, _source01,
						_ParticleShape,
						_Particle00_Time, _Particle01_Time,
						_velocity, _speed,
						_weight, _volume,
						_Particle00_Size, _Particle01_Size,
						_SurfaceType_Pick
					] call _particle_Setups;
				};

				if (_Particle_Count > 0) then {
					_source00 = _Ground_Paricles # 0;
					_source01 = _Ground_Paricles # 1;
					if(_backDist == 0) then {
						_source00 attachTo [_plane, [0,0,0]];
						_source01 attachTo [_plane, [0,0,0]];
					} else {
						_source00 attachTo [_plane, [0, (_backDist + _Engine_Offset),0]];
						_source01 attachTo [_plane, [0, (_backDist + _Engine_Offset),0]];
					};

					_source00 setParticleCircle [1.2, [(_speed*0.02), (_speed*0.02), 1]];
					_source00 setParticleRandom [0.8, [0, 0, 0], [0, 0, 0], 10, 0.4, [0, 0, 0, 0], 0.1, 0.05, 0];
					_source00 setDropInterval 0.005;
					
					_source01 setParticleCircle [5, [(_speed*_particle01_CycleSpeed), (_speed*_particle01_CycleSpeed), 0]];
					_source01 setParticleRandom [0.8, [0, 0, 0], [0.1,0.1,2], 20, 0.4, [0, 0, 0, 0], 0.1, 0.05, 0];
					_source01 setDropInterval 0.005;
				};

				if ((isNull _plane) or !(_plane getVariable "MAZ_AE_groundEffectActive") or (_SurfaceChanged) or (!alive _plane)) then {
					if (_Particle_Count > 0) then {
						{deleteVehicle _x} foreach _Ground_Paricles;
						_plane setVariable ["MAZ_AE_GroundParticles", []];
						_plane setVariable ["MAZ_AE_groundEffectActive",false];
					};
				};
			};

			_effect = {
				params["_plane","_Particle_Pick","_Depos","_velocity","_speed","_particles","_ParticleShape","_Particle_Settings","_Particle00_Setups","_Particle01_Setups","_particle_Setups","_backDist"];
				_SurfaceType_Pick = switch (_Particle_Pick) do {
					case "Default": {0};
					case "Beach": {1};
					case "Dust": {2};
					case "Water": {3};
				};
				_SurfaceType_Pick = MAZ_AE_groundTypes select _SurfaceType_Pick;
				[_plane,_SurfaceType_Pick,_Depos,_velocity,_speed,_ParticleShape,_Particle_Settings,_Particle00_Setups,_Particle01_Setups,_particle_Setups,_backDist] call _particles;
			};

			private _Particle_Pick = _plane getVariable ["MAZ_AE_GroundType","Default"];
			private _groundParticles = [];
			waitUntil {
				private _ParticleShape = ["\A3\Data_F\ParticleEffects\Universal\Universal", 16, 12, 13, 0];

				private _Particle00_Time = 2;
				private _Particle01_Time = 4;

				private _Particle00_Size = [4,6];
				private _Particle01_Size = [5,10,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15];

				private _particle01_CycleSpeed = 0.02;

				private _weight = 2.2;
				private _volume = 0.8;

				private _Depos = _plane modelToWorld [0,_backDist,0];

				private _speed = speed _plane;
				private _velocity = velocity _plane;

				[_plane,_depos,_Particle_Pick] call MAZ_AE_fnc_surfaceTypeEH;

				if (surfaceIsWater _Depos) then {
					_Particle01_Size = [3,5,8,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7];

					_Particle00_Time = 1;
					_Particle01_Time = 2;

					_ParticleShape = ["\A3\data_f\ParticleEffects\Universal\Universal", 16, 13, 10, 0];
				};

				[
					_plane,_Particle_Pick,_Depos,_velocity,_speed,_particles,_ParticleShape,
					[_weight,_volume],
					[_Particle00_Time,_Particle00_Size],
					[_Particle01_Time,_Particle01_Size,_particle01_CycleSpeed],
					_particle_Setups,_backDist
				] call _effect;
				_groundParticles = _plane getVariable ["MAZ_AE_GroundParticles",[]];

				!(_plane getVariable ["MAZ_AE_groundEffectActive",false])
			};

			if ((count _groundParticles) > 0) then {
				{deleteVehicle _x} foreach _groundParticles;
				_plane setVariable ["MAZ_AE_GroundParticles", []];
				_plane setVariable ["MAZ_AE_groundEffectActive",false];
			};
		};

		MAZ_AE_fnc_vaporEffect = {
			params ["_plane","_exCount","_exPoses"];
			private _source = "#particlesource";
			private _sources = [];

			for "_i" from 0 to (_exCount - 1) do {
				private _engine = _exPoses # _i;
				private _particleSource = _source createVehicleLocal [0,0,0];
				_particleSource attachTo [_plane,[0,-5,0],_engine];

				_particleSource setParticleParams [
					["\A3\Data_F\ParticleEffects\Universal\Universal",16,12,8,0], "", "Billboard",
					1, 20, [0,0,0], [0, 0, 0], 20, 1.25, 1, 0.01, [8,15,25,30,40],
					[[0.7,0.8,1,0],[0.7,0.8,1,0.3],[0.7,0.8,1,0.5],[0.7,0.8,1,0.3],[0.7,0.8,1,0.2],[0.7,0.8,1,0.1],[0.7,0.8,1,0]],
					[1000], 0.1, 0.05, "", "", _particleSource];
				_particleSource setParticleRandom [2,[2,2,0.5],[0.4,0.4,0.4],3,0.4,[0,0,0,0.12],0,0,1];

				_sources pushBack _particleSource;
				_plane setVariable ["MAZ_AE_VaporParticles",_sources];
			};

			private _vaporParticles = _plane getVariable ["MAZ_AE_VaporParticles",[]];

			waitUntil {
				{
					_interval = 0.025-(0.000013*(Speed _plane));
					if(_interval <= 0.01) then {_interval = 0.01};
					_x setDropInterval _interval;
				} forEach _vaporParticles;

				!(_plane getVariable ["MAZ_AE_vaporActive",false])
			};

			{deleteVehicle _x;} forEach _vaporParticles;
			_plane setVariable ["MAZ_AE_VaporParticles",[]];
		};

		MAZ_AE_fnc_exhaustOffsets = {
			params ["_plane","_exCount","_engOff","_planePlayer"];

			private _planes = nearestObjects [_planePlayer,["Plane"],50];
			_engOff params [["_engine1",[0,0,0]],["_engine2",[0,0,0]],["_engine3",[0,0,0]],["_engine4",[0,0,0]]];

			{
				if(_x != cameraOn) then {
					private _plane = _x;
					private _result = switch (_exCount) do {
						case 1: {
							private _source00 = _plane modelToWorldVisual [(_engine1 # 0), (_engine1 # 1)+(-10-10),(_engine1 # 2)];
							private _dis0 = _planePlayer distance _source00;
							[
								[_source00],
								[_dis0]
							]
						};
						case 2: {
							private _source00 = _plane modelToWorldVisual [(_engine1 # 0), (_engine1 # 1)+(-10-10),(_engine1 # 2)];
							private _source01 = _plane modelToWorldVisual [(_engine2 # 0), (_engine2 # 1)+(-10-10),(_engine2 # 2)];

							private _dis0 = _planePlayer distance _source00;
							private _dis1 = _planePlayer distance _source01;

							[
								[_source00,_source01],
								[_dis0,_dis1]
							]
						};
						case 3: {
							private _source00 = _plane modelToWorldVisual [(_engine1 # 0), (_engine1 # 1)+(-10-10),(_engine1 # 2)];
							private _source01 = _plane modelToWorldVisual [(_engine2 # 0), (_engine2 # 1)+(-10-10),(_engine2 # 2)];
							private _source02 = _plane modelToWorldVisual [(_engine3 # 0), (_engine3 # 1)+(-10-10),(_engine3 # 2)];

							private _dis0 = _planePlayer distance _source00;
							private _dis1 = _planePlayer distance _source01;
							private _dis2 = _planePlayer distance _source02;

							[
								[_source00,_source01,_source02],
								[_dis0,_dis1,_dis2]
							]
						};
						case 4: {
							private _source00 = _plane modelToWorldVisual [(_engine1 # 0), (_engine1 # 1)+(-10-10),(_engine1 # 2)];
							private _source01 = _plane modelToWorldVisual [(_engine2 # 0), (_engine2 # 1)+(-10-10),(_engine2 # 2)];
							private _source02 = _plane modelToWorldVisual [(_engine3 # 0), (_engine3 # 1)+(-10-10),(_engine3 # 2)];
							private _source03 = _plane modelToWorldVisual [(_engine4 # 0), (_engine4 # 1)+(-10-10),(_engine4 # 2)];

							private _dis0 = _planePlayer distance _source00;
							private _dis1 = _planePlayer distance _source01;
							private _dis2 = _planePlayer distance _source02;
							private _dis3 = _planePlayer distance _source03;

							[
								[_source00,_source01,_source02,_source03],
								[_dis0,_dis1,_dis2,_dis3]
							]
						};
					};

					_plane setVariable ["MAZ_AE_TurbulentSources",_result # 0];
					_planePlayer setVariable ["MAZ_AE_TurbulentSourceDistance",_result # 1];
					_planePlayer setVariable ["MAZ_AE_TurbulentSourceDistance_Found",true];
				};
			}forEach _planes;
		};

		MAZ_AE_fnc_taxiEffect = {
			params ["_plane","_speed"];
			private _fq = 0;
			private _pw = 0;

			if ((_speedPlayer >= 10) and (_speedPlayer < 60)) then {
				_fq = 3;
				_pw = 0.3;
			};
			if ((_speedPlayer >= 60) and (_speedPlayer < 150)) then {
				_fq = 5;
				_pw = 1;
			};
			if (_speedPlayer >= 150) then {
				_fq = 6;
				_pw = 1;
			};

			addCamShake [_pw, 1, _fq];
		};
		
		MAZ_AE_fnc_deleteCollisionLights = {
			params ["_plane"];
			private _currentLights = _plane getVariable ["MAZ_AE_CollisionLights",[]];
			{
				deleteVehicle _x;
			}forEach _currentLights;
			_plane setVariable ["MAZ_AE_CollisionLights",[]];
		};

		MAZ_AE_fnc_deleteStrobeLights = {
			params ["_plane"];
			private _currentLights = _plane getVariable ["MAZ_AE_StrobeLights",[]];
			{
				deleteVehicle _x;
			}forEach _currentLights;
			_plane setVariable ["MAZ_AE_StrobeLights",[]];
		};

		MAZ_AE_fnc_createCollisionLights = {
			params ["_plane","_positions"];
			comment "Red, green, white";
			private _colorsFull = [
				[
					[0.1,0,0],
					[10,0,0]
				],
				[
					[0,0.8,0],
					[0,10,0]
				],
				[
					[0.1,0.1,0.1],
					[25,25,25]
				]
			];
			private _currentLights = _plane getVariable ["MAZ_AE_CollisionLights",[]];
			if(count _currentLights == 0) then {
				private _lights = [];
				{
					private _colors = _colorsFull select _forEachIndex;
					_colors params ["_ambient","_color"];
					private _positions = _x;
					{
						private _light = "#lightpoint" createVehicleLocal [0,0,0];
						_light setLightAmbient _ambient;
						_light setLightColor _color;
						_light setLightUseFlare true;
						_light setLightBrightness 1;
						_light setLightFlareSize 0.15;
						_light setLightIntensity 50;
						_light setLightFlareMaxDistance 5000;
						_light setLightAttenuation [0,0,5,1,1,8];
						_light setLightDayLight true;
						_light attachTo [_plane,_x];
						
						_lights pushBack _light;
					}forEach _positions;
				}forEach _positions;

				_plane setVariable ["MAZ_AE_CollisionLights",_lights];
			};
		};

		MAZ_AE_fnc_doStrobeBlinking = {
			params ["_light","_blinkLength","_pauseLength","_ambient","_color","_hideFPV"];
			while {!isNull _light} do {
				sleep _blinkLength;
				_light setLightAmbient [0,0,0];
				_light setLightColor [0,0,0];
				sleep _pauseLength;
				if(!(_hideFPV && cameraView == "Internal")) then {
					_light setLightAmbient _ambient;
					_light setLightColor _color;
				};
			};
		};

		MAZ_AE_fnc_createStrobeLights = {
			params ["_plane","_positions","_rates"];
			private _currentLights = _plane getVariable ["MAZ_AE_StrobeLights",[]];
			if(count _currentLights == 0) then {
				private _lights = [];
				{
					(_rates select _forEachIndex) params [
						"_blinkLength",
						"_pauseLength",
						[
							"_colorOverride",
							[
								[0.1,0.1,0.1],
								[50,50,50]
							]
						],
						[
							"_hideFPV",
							false
						]
					];
					_colorOverride params ["_ambient","_color"];
					private _light = "#lightpoint" createVehicleLocal [0,0,0];
					_light setLightAmbient _ambient;
					_light setLightColor _color;
					_light setLightUseFlare true;
					_light setLightBrightness 1;
					_light setLightFlareSize 1;
					_light setLightIntensity 300;
					_light setLightFlareMaxDistance 5000;
					_light setLightAttenuation [0,0,10,0.01,1,2];
					_light setLightDayLight true;
					_light attachTo [_plane,_x];
					[_light,_blinkLength,_pauseLength,_ambient,_color,_hideFPV] spawn MAZ_AE_fnc_doStrobeBlinking;

					_lights pushBack _light;
				}forEach _positions;
				_plane setVariable ["MAZ_AE_StrobeLights",_lights];
			};
		};

		MAZ_AE_fnc_CollisionLightsOnEH = {
			private _plane = _this;
			_plane setVariable ["MAZ_AE_colLightsEHOn",true];
			waitUntil {isCollisionLightOn _plane};
			private _event = -1;
			if(MAZ_AE_NewLights) then {
				private _list = [];
				if(typeOf _plane isKindOf "Plane") then {_list = MAZ_AE_LightConfig;} else {_list = MAZ_AE_LightConfigHeli;};
				{
					_x params ["_type","_collision","_strobe1","_strobe2"];
					if(!(typeOf _plane isKindOf _type)) then {continue};
					[_plane,_collision] call MAZ_AE_fnc_createCollisionLights;
					[_plane,_strobe1,_strobe2] call MAZ_AE_fnc_createStrobeLights;
					_event = _plane addEventHandler ["Deleted",{
						params ["_entity"];
						[_entity] call MAZ_AE_fnc_deleteCollisionLights;
						[_entity] call MAZ_AE_fnc_deleteStrobeLights;
					}];
				}forEach _list;
			};
			waitUntil {!isCollisionLightOn _plane};
			if(MAZ_AE_NewLights) then {
				[_plane] call MAZ_AE_fnc_deleteCollisionLights;
				[_plane] call MAZ_AE_fnc_deleteStrobeLights;
				_plane removeEventhandler ["Deleted",_event];
			};
			_plane setVariable ["MAZ_AE_colLightsEHOn",false];
		};

		MAZ_AE_fnc_GearFactor = {
			params ["_plane","_speed"];
			private _gear = _plane getSoundController "gear";

			if ((_gear < 0.6) and (_speed > 600)) then {
				addCamShake [2, 2, 2];
			};
		};

		MAZ_AE_fnc_landedCooldown = {
			params ["_plane"];
			if(_plane getVariable "MAZ_AE_LandedCooldown") then {
				sleep 1;
				_plane setvariable ["MAZ_AE_LandedCooldown",false];
			};
		};

		MAZ_AE_fnc_landedEH = {
			params ["_plane"];
			private _cooldown = _plane getVariable ["MAZ_AE_LandedCooldown",false];
			if(_cooldown) exitWith {};
			private _wheels = _plane getVariable ["MAZ_AE_wheelSelections",[]];

			if (_wheels isEqualTo []) then {
				_wheels = [_plane] call MAZ_AE_fnc_findWheels;
				_plane setVariable ["MAZ_AE_wheelSelections",_wheels];
			};

			if(speed _plane <= 100) exitWith {};

			_wheels = _plane getVariable ["MAZ_AE_wheelSelections",[]];
			private _gears = _wheels # 5;
			private _pos = [0,0,0];
			private _particleSources = [];

			for "_i" from 0 to (count _gears) -1 do {
				private _gear = _gears # _i;
				private _effect = "#particlesource" createVehicleLocal _pos;
				_effect attachTo [_plane,_gear];

				private _behind = false;
				if(_gear # 1 < 0) then {
					_behind = true;
				};

				_particleSources pushBack _effect;

				private _script = [_wheels,_effect,_particleSources,_behind] spawn MAZ_AE_fnc_landedEffect;
				[_effect,_particleSources,_plane,_script] spawn {
					params ["_effect","_particleSources","_plane","_script"];
					private _index = _particleSources find _effect;

					waitUntil {
						scriptDone _script
					};
					sleep 0.25;
					_particleSources deleteAt _index;
					deleteVehicle _effect;
				};
			};
			_plane setvariable ["MAZ_AE_LandedCooldown",true];
			[_plane] spawn MAZ_AE_fnc_landedCooldown;
		};

		MAZ_AE_fnc_landedEffect = {
			params ["_array1","_effect","_particleSources","_behind"];

			_array1 params [
				"_plane","_lifetime","_size",
				"_hVar","_hVarR",
				"_gears",
				"_offset","_offsetF"
			];

			private _config = configFile >> "CfgVehicles" >> typeOf _plane;
			private _speedLimit = (getNumber (_config >> "landingSpeed") - (20 + random 10));
			if(_speedLimit > 180) then {_speedLimit = 180};

			private _color = [[0.7,0.8,1,0.8],[0.7,0.8,1,0.5],[0.7,0.8,1,0.3],[0.7,0.8,1,0.15],[0.7,0.8,1,0.05],[0.7,0.8,1,0.01],[0.7,0.8,1,0.0]];
			private _posVar = [4.5,1,0.01];

			if(!_behind) then {
				_size = [1,3,6,20];
				_posVar = [2,1,0.01];
			};

			private _tailhookInit = getNumber(_config >> "AnimationSources" >> "TailHook" >> "initPhase");
			if(surfaceIsWater (getPos _plane)) then {
				_hVar = 24.8;
				_hVarR = 24.8;
			};

			private _velocity = velocity _plane;
			private _velocityFX = [0.4*(_Velocity select 0),0.4*(_Velocity select 1), 0];

			waitUntil {
				((getPos _effect) # 2 <= _hVar)
			};

			if(speed _plane < _speedLimit) exitWith {};

			_effect setParticleParams [
			["\A3\Data_F\ParticleEffects\Universal\Universal", 16, 12, 16, 0], "", "Billboard",
			0, _lifetime, [0, 0, 0], _velocityFX, 1.25, 1.2, 1, 0, _size,
			_color,
			[0], 0.5, 0, "", "", _effect];
			_effect setDropInterval 0.01;
			_effect setParticleRandom [0.5, [0, 0, 0], _posVar, 0.5, 0.5, [0, 0, 0, 0], 0.1, 0.02, 90];
			private _hook = _plane getVariable ["MAZ_AE_HookSparks",false];
			private _hookActive = (
				(_plane animationPhase "tailhook" != _tailhookInit) and
				!(_hook) and
				(_behind)
			);

			if(_hookActive) then {
				private _hook_effect = "#particlesource" createVehicleLocal [0,0,0];
				_hook_effect attachTo [_plane, [0,0,0],(getText(_config >> "CarrierOpsCompatability" >> "ArrestHookMemoryPoint"))];
				_hook_effect setParticleClass "ExpSparks1";
				_plane setVariable ["MAZ_AE_HookSparks",true];

				sleep 0.25;

				deleteVehicle _hook_effect;
				_plane setVariable ["MAZ_AE_HookSparks",false];
			};
		};

		MAZ_AE_fnc_findWheels = {
			params ["_plane"];
			private _gears = [];
			private _offset = 0;
			private _offsetF = 0;

			private _config = configFile >> "CfgVehicles" >> typeOf _plane;
			private _selection = getArray (_config >> "driveOnComponent");
			if(_selection isEqualTo []) then {
				_selection = _plane selectionNames "LandContact";
				if (_plane isKindOf "Plane_Fighter_01_Base_F") then {
					_selection = ["gear_f" , _selection # 1, _selection # 2];
					_OffsetF = -1;
				};
				if (_plane isKindOf "VTOL_01_base_F") then {
					_selection = ["wheel_1_1" , "wheel_2_2", "wheel_3_2"];
				};
				if (_plane isKindOf "Plane_Fighter_03_base_F") then {
					_selection = ["wheel_1_axis" , "wheel_2_axis", "wheel_3_axis"];
				};
				if (_plane isKindOf "UAV_02_base_F") then {
					_selection = ["wheel_1", "wheel_2", "wheel_3"];
				};
			};

			if (_selection isEqualTo []) exitWith {};

			for "_i" from 0 to (count _selection - 1) do {
				private _gear = _selection # _i;
				private _gearPos = _plane selectionPosition _gear;
				_gears pushBack _gearPos;
			};

			private _lifetime = 3;
			private _size = [2,4,6,10,12];
			private _mass = getMass _plane;

			if (_mass >= 100000) then {
				_lifetime = 5;
				_size = [2,5,8,10,12];
			} else {
				if (_mass <= 1500) then {
					_lifetime = 3;
				};
				if (_mass >= 10000) then {
					_lifetime = 3;
				};
				if (_mass >= 16200) then {
					_lifetime = 3;
				};
				if (_mass >= 20000) then {
					_lifetime = 3;
					_size = [2,4,6,10,12];
				};
			};

			private _hVar = 0.84;
			private _hVarR = 0.84;

			[_plane,_lifetime,_size,_hVar,_hVarR,_gears,_offset,_offsetF];
		};

		MAZ_AE_fnc_getGForces = {
			private _plane = vehicle player;
			private _interval = 0.2; 
			private _maxVirtualG = 5; 
			private _minVirtualG = 2.5;
			private _newVel = velocity _plane; 
			private _accel = (_newVel vectorDiff oldVel) vectorMultiply (1 / _interval); 
			private _currentGForce = (((_accel vectorDotProduct (vectorUp _plane)) / 11) max -10) min 10;

			_currentGForce = (round (_currentGForce * 100)) / 100;

			private _average = 0;
			private _count = {_average = _average + _x; true} count GForces;
			if(_count > 0) then {
				_average = _average/_count;
			};

			private _gBlackOut = _maxVirtualG / 0.55 + _maxVirtualG / 1 - _maxVirtualG;
			private _strength = ((_average - 0.30 * _gBlackOut) / (0.70 * _gBlackOut)) max 0;

			[_currentGForce,_strength];
		};

		MAZ_AE_fnc_gForce = {
			params ["_plane"];
			private _cfg = configFile >> "CfgVehicles" >> typeOf _plane;
			private _interval = 0.2;
			private _maxVirtualG = 5;
			private _minVirtualG = 2.5;

			if((time - lastUpdateTime) < _interval) exitWith {};
			lastUpdateTime = time;

			private _newVel = velocity _plane;
			private _accel = (_newVel vectorDiff oldVel) vectorMultiply (1 / _interval);
			private _currentGForce = (((_accel vectorDotProduct (vectorUp _plane)) / 11) max -10) min 10;

			if(_currentGForce >= 7) then {
				comment "Hold breath hard";

			};

			GForces set [GForcesIndex,_currentGForce];
			GForcesIndex = (GForcesIndex + 1) % 30;
			oldVel = _newVel;

			private _average = 0;
			private _count = {_average = _average + _x; true} count GForces;
			if(_count > 0) then {
				_average = _average/_count;
			};

			private _gBlackOut = _maxVirtualG / 0.55 + _maxVirtualG / 1 - _maxVirtualG;
			private _strength = ((_average - 0.30 * _gBlackOut) / (0.70 * _gBlackOut)) max 0;
			_plane setVariable ["MAZ_AE_currentGForce",_strength];
			comment '
			if(_currentGForce > 8.5) then {
				call MAZ_AE_fnc_disableControlOverG;
			} else {
				call MAZ_AE_fnc_removeDisableControlOverG;
			}';
			if(_average > 0.30 * _gBlackOut) then {
				GForces_Filter ppEffectAdjust [1,1,0,[0,0,0,1],[0,0,0,0],[1,1,1,1],[2 * (1 - _strength),(1 - _strength),0,0,0,0.1,0.5]];
				if(_strength > 0.77) then {
					call MAZ_AE_fnc_disableControlOverG;
				} else {
					if(_strength < 0.70) then {
						call MAZ_AE_fnc_removeDisableControlOverG;
					};
				};
				
				if(_currentGForce >= 3 && cameraView == "internal") then {
				
				};
			} else {
				private _gRedOut = _minVirtualG / 0.55;
				if(_average < -0.3 * _gRedOut) then {
					_strength = ((abs _average - 0.30 * _gRedOut) / (0.70 * _gRedOut)) max 0;
					GForces_Filter ppEffectAdjust [1,1,0,[1,0.2,0.2,1],[0,0,0,0],[1,1,1,1],[2 * (1 - _strength),1 * (1 - _strength),0,0,0,0.1,0.5]];
				} else {
					GForces_Filter ppEffectAdjust [1,1,0,[0,0,0,1],[0,0,0,0],[1,1,1,1],[10,10,0,0,0,0.1,0.5]];
				};
			};
			GForces_Filter ppEffectCommit 0.6;
		};

		MAZ_AE_fnc_weaponFiringShakeExec = {
			params [["_weapon",currentWeapon (vehicle player)]];
			private _pow = 0;
			private _freq = 0;
			{
				_x params ["_type","_intensityArray"];
				_intensityArray params ["_power","_frequency"];
				if((toLower _type) in (toLower _weapon)) exitWith {
					_pow = selectRandom _power;
					_freq = selectRandom _frequency;
				};
			}forEach MAZ_AE_weaponShakeIntesity;
			if(_pow < 3 && cameraView == "GUNNER") exitWith {};
			addCamShake [_pow,1,_freq];
		};

		MAZ_AE_fnc_weaponFiringShake = {
			params ["_vehicle"];
			_vehicle setVariable [
				"MAZ_AE_EH_Fired",
				_vehicle addEventHandler ["Fired", {
					params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
					(getShotParents _projectile) params ["_plane","_shooter"];

					{
						[[_weapon],{
							params ["_weapon"];
							[_weapon] call MAZ_AE_fnc_weaponFiringShakeExec;
						}] remoteExec ['spawn',_x];
					}forEach (crew _plane);
				}],
				true
			];
		};

		fn_isUnitCopilot = {
			if(vehicle _this == _this) exitWith {false};

			private ["_veh", "_cfg", "_trts", "_return", "_trt"];
			_veh = (vehicle _this);
			_cfg = configFile >> "CfgVehicles" >> typeOf(_veh);
			_trts = _cfg >> "turrets";
			_return = false;

			for "_i" from 0 to (count _trts - 1) do {
				_trt = _trts select _i;

				if(getNumber(_trt >> "iscopilot") == 1) exitWith {
					_return = (_veh turretUnit [_i] == _this);
				};
			};

			_return
		};

		MAZ_AE_fnc_resetGForceEffectLoop = {
			while {MAZ_AE_aircraftEnhancementEnable} do {
				if(!isNil "GForces_Filter" && !((typeOf (vehicle player)) isKindOf "Plane")) then {
					GForces_Filter ppEffectAdjust [1,1,0,[0,0,0,1],[0,0,0,0],[1,1,1,1],[10,10,0,0,0,0.1,0.5]];
					GForces_Filter ppEffectCommit 0.6;
					call MAZ_AE_fnc_removeDisableControlOverG;
				};
				sleep 2;
			};
		};

		MAZ_AE_fnc_helicopterDoorAction = {
			params ["_heli","_doorName","_animationName"];
			_heli addAction [
				format ["Open %1",_doorName],
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
					_target animateDoor [_arguments,1];
				},
				_animationName,
				1.5,
				false,
				true,
				"",
				format ['((_this in _target) && (_this call fn_isUnitCopilot || driver _target == _this)) && ((_target doorPhase %1) < 0.5)',str _animationName]
			];

			_heli addAction [
				format ["Close %1",_doorName],
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
					_target animateDoor [_arguments,0];
				},
				_animationName,
				1.5,
				false,
				true,
				"",
				format ['((_this in _target) && (_this call fn_isUnitCopilot || driver _target == _this)) && ((_target doorPhase %1) > 0.5)',str _animationName]
			];
		};

		MAZ_AE_fnc_helicopterDoorActionOrca = {
			params ["_heli","_doorName","_animationName"];
			_heli addAction [
				format ["Open %1",_doorName],
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
					_target animate [_arguments,1];
				},
				_animationName,
				1.5,
				false,
				true,
				"",
				format ['((_this in _target) && (_this call fn_isUnitCopilot || driver _target == _this)) && ((_target animationPhase %1) < 0.5)',str _animationName]
			];

			_heli addAction [
				format ["Close %1",_doorName],
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
					_target animate [_arguments,0];
				},
				_animationName,
				1.5,
				false,
				true,
				"",
				format ['((_this in _target) && (_this call fn_isUnitCopilot || driver _target == _this)) && ((_target animationPhase %1) > 0.5)',str _animationName]
			];
		};

		MAZ_AE_fnc_handleAddHelicopterDoorActions = {
			params ["_heli"];
			private _typeOf = typeOf _heli;
			if(_typeOf isKindOf "Heli_Transport_03_base_F") exitWith {
				[_heli,{
					waitUntil{!isNil "MAZ_AE_fnc_helicopterDoorAction"};
					[_this,"Left Door","Door_l_Source"] call MAZ_AE_fnc_helicopterDoorAction;
					[_this,"Right Door","Door_r_Source"] call MAZ_AE_fnc_helicopterDoorAction;
				}] remoteExec ['spawn',0,_heli];
			};
			if(_typeOf isKindOf "Heli_Transport_04_base_F") exitWith {
				[_heli,{
					waitUntil{!isNil "MAZ_AE_fnc_helicopterDoorAction"};
					[_this,"Left Door","Door_4_source"] call MAZ_AE_fnc_helicopterDoorAction;
					[_this,"Right Door","Door_5_source"] call MAZ_AE_fnc_helicopterDoorAction;
				}] remoteExec ['spawn',0,_heli];
			};
			if(_typeOf isKindOf "Heli_Transport_01_base_F") exitWith {
				[_heli,{
					waitUntil{!isNil "MAZ_AE_fnc_helicopterDoorAction"};
					[_this,"Left Door","Door_L"] call MAZ_AE_fnc_helicopterDoorAction;
					[_this,"Right Door","Door_R"] call MAZ_AE_fnc_helicopterDoorAction;
				}] remoteExec ['spawn',0,_heli];
			};
			if(_typeOf isKindOf "Heli_Transport_02_base_F") exitWith {
				[_heli,{
					waitUntil{!isNil "MAZ_AE_fnc_helicopterDoorAction"};
					[_this,"Left Door","Door_Back_L"] call MAZ_AE_fnc_helicopterDoorAction;
					[_this,"Right Door","Door_Back_R"] call MAZ_AE_fnc_helicopterDoorAction;
				}] remoteExec ['spawn',0,_heli];
			};
			if(_typeOf isKindOf "Heli_Light_02_base_F") exitWith {
				[_heli,{
					waitUntil{!isNil "MAZ_AE_fnc_helicopterDoorActionOrca"};
					[_this,"Left Door","dvere1_posunZ"] call MAZ_AE_fnc_helicopterDoorActionOrca;
					[_this,"Right Door","dvere2_posunZ"] call MAZ_AE_fnc_helicopterDoorActionOrca;
				}] remoteExec ['spawn',0,_heli];
			};
		};

		MAZ_AE_fnc_heliCrashAddSmoke = {
			params ["_heli"];
			private _exhausts = "true" configClasses (configFile >> "CfgVehicles" >> typeOf _heli >> "Exhausts");

			private _smokeObjects = [];
			{
				private _pos = getText (_x >> "position");
				private _offset = _heli selectionPosition _pos;
				private _smokeObject = createVehicle ["test_EmptyObjectForSmoke",[0,0,0],[],0,"CAN_COLLIDE"];
				_smokeObject attachTo [_heli,_offset];

				_smokeObjects pushBack _smokeObject;
			}forEach _exhausts;

			if((_heli getVariable ["MAZ_AE_crashLandDeleteSmoke",-420]) == -420) then {
				_heli setVariable ["MAZ_AE_crashLandDeleteSmoke",
					(_heli addEventHandler [
						"Deleted", {
							params ["_entity"];
							{
								deleteVehicle _x;
							}forEach (attachedObjects _entity);
						}
					]),
					true
				];
			};

			_heli setVariable ["MAZ_AE_crashLandSmokeObjects",_smokeObjects,true];
		};

		MAZ_AE_fnc_heliCrashLanding = {
			params ["_heli"];
			private _handlerID = _heli addEventHandler ["HandleDamage", {
				params ["_heli", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit"];
				if(_hitPoint == "" || "glass" in (toLower _hitPoint) || "light" in (toLower _hitPoint)) exitWith {};
				if(_damage >= 1) then {
					private _time = _heli getVariable ["MAZ_AE_crashLandInvulnerableTime",time];
					if(_time > time) then {
						0.97;
					} else {
						_heli setVariable ["MAZ_AE_crashLandInvulnerableTime",time + 1.5,true];
						private _count = _heli getVariable ["MAZ_AE_crashLandCounter",0];
						if(_count == 0) then {
							comment "TODO : Make pilot survive?";
						};
						if(_count >= 2 && !isTouchingGround _heli) then {
							1;
						} else {
							private _hitPoints = getAllHitPointsDamage _heli;
							for "_i" from 0 to ((count (_hitPoints # 0)) - 1) do {
								private _hitPoint = _hitPoints select 0 select _i;
								private _damage = _hitPoints select 2 select _i;
								private _resetDamage = true;
								if("engine" in (toLower _hitPoint)) then {
									_heli setHitPointDamage [_hitPoint,1];
									_resetDamage = false;
								};
								if("hull" in (toLower _hitPoint)) then {
									_heli setHitPointDamage [_hitPoint,1];
									_resetDamage = false;
								};
								if("hrotor" in (toLower _hitPoint)) then {
									_heli setHitPointDamage [_hitPoint,1];
									_resetDamage = false;
								};

								if("aileron" in (toLower _hitPoint) || "elevator" in (toLower _hitPoint) || "rudder" in (toLower _hitPoint)) then {
									_heli setHitPointDamage [_hitPoint,0];
									_resetDamage = false;
								};

								if(_resetDamage) then {
									_heli setHitPointDamage [_hitPoint, 0.9];
								};
							};
							_heli setVariable ["MAZ_AE_crashLandCounter",_count + 1, true];
							if !(_heli getVariable ["MAZ_AE_crashLanded",false]) then {
								_heli setVariable ["MAZ_AE_crashLanded",true,true];
								[_heli] call MAZ_AE_fnc_heliCrashAddSmoke;
								[[_heli], {
									params ["_heli"];
									[_heli] spawn MAZ_AE_fnc_heliCrashWaitUntilRepaired;
								}] remoteExec ['spawn',2];
							};
							
							0.97;
						};
					};
				} else {
					_damage;
				};
			}];
			_heli setVariable ["MAZ_AE_crashLandHandler",_handlerID,true];
		};

		MAZ_AE_fnc_heliCrashWaitUntilRepaired = {
			params ["_heli"];
			waitUntil {_heli getVariable ["MAZ_AE_crashLanded",false]};
			waitUntil {uiSleep 0.1; damage _heli < 0.5 || damage _heli >= 1};
			_heli setVariable ["MAZ_AE_crashLanded",false,true];
			_heli setVariable ["MAZ_AE_crashLandCounter",0,true];

			private _smokeObjects = _heli getVariable ["MAZ_AE_crashLandSmokeObjects",[]];
			{
				deleteVehicle _x;
			}forEach _smokeObjects;

			_heli setVariable ["MAZ_AE_crashLandSmokeObjects",[],true];
		};

		MAZ_AE_fnc_disableControlOverG = {
			if(isNil "MAZ_DEH_AE_overG") then {
				MAZ_DEH_AE_overG = (findDisplay 46) displayAddEventHandler ["KeyDown",  {
					private _handled = false;  
					private _aircraftControls = [
						"HeliForward","HeliBack","AirBankLeft","AirBankRight","HeliFastForward","HeliUp","HeliDown","HeliThrottlePos","AirPlaneBrake",
						"HeliRudderLeft","HeliRudderRight","HeliLeft","HeliRight","vtolVectoring","vtolVectoringCancel","LandGear","LandGearUp","FlapsDown","FlapsUp",
						"HeliThrottleNeg","pushToTalk","chat","voiceOverNet","Eject","GetOut","defaultAction","fire","nextWeapon","lockTarget","launchCM","ActiveSensorsToggle",
						"showMap","Action","ActionContext"
					] apply {actionKeys _x select 0};
					if ((_this select 1) in _aircraftControls) then {  
						_handled = true  
					};  
					_handled  
				}];
			};
		};

		MAZ_AE_fnc_removeDisableControlOverG = {
			if(!isNil "MAZ_DEH_AE_overG") then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown",MAZ_DEH_AE_overG];
				MAZ_DEH_AE_overG = nil;
			};
		};

		MAZ_AE_fnc_toggleAircraftLaser = {
			private _veh = vehicle player;
			if !(_veh isKindOf "Plane") exitWith {};

		};

		if(isServer) then {
			waitUntil {!isNil "MAZ_EP_fnc_addFunctionToMainLoop"};
			["MAZ_AE_fnc_serverLoop"] call MAZ_EP_fnc_addFunctionToMainLoop;
		} else {
			[] spawn MAZ_AE_fnc_resetGForceEffectLoop;
			'MAZ_Key_ToggleLaser = ["Toggle Laser","Toggle your aircraft laser.",211,{call MAZ_AE_fnc_toggleAircraftLaser;}] call MAZ_fnc_newKeybind';
		};
	};

	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		[
			"Aircraft Enhancements", 
			"Various enhancements to aircraft. Thanks to [TW] Aaren for his Advance Aero Effects mod.",
			[
				"Brighter collision lights",
				"Camera shake when firing and taxiing",
				"Turbulence when flying low or nearby other aircraft",
				"Dust kick up when flying low over dirt and water",
				"G forces effect pilots, possibly causing GLOC",
				"Helicopter crash landing overhaul"
			]
		] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Aircraft Enhancements System has been loaded! Aircraft are cooler and more immersive! Credit to [TW] Aaren for his Advance Aero Effects mod.",
			"System Initialization Notification",
			12
		] spawn MAZ_EP_fnc_createNotification;
	};

	[] spawn MAZ_AE_fnc_aircraftEnhancementSystem;
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