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
if(missionNamespace getVariable ["MAZ_EP_BetterMortarsEnabled",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Better Mortars already running!";};

private _varName = "MAZ_System_EnhancementPack_BM";
private _myJIPCode = "MAZ_EPSystem_BM_JIP";

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["Better Mortars","Whether to enable the Better Mortars system.","MAZ_EP_BetterMortarsEnabled",true,"TOGGLE",[],"MAZ_BM"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_EP_fnc_mortarReBalanceCarrier = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_BM"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};
		MAZ_fnc_openMortarRangeCard = {
			disableSerialization;
			showChat true;
			with uiNamespace do {
				MAZ_rangeCard_BG = (findDisplay 46) ctrlCreate ["IGUIBack", 2200];
				MAZ_rangeCard_BG ctrlSetPosition [0.00499997 * safezoneW + safezoneX,0.126 * safezoneH + safezoneY,0.170156 * safezoneW,0.748 * safezoneH];
				MAZ_rangeCard_BG ctrlSetBackgroundColor [0,0,0,0.6];
				MAZ_rangeCard_BG ctrlCommit 0;

				MAZ_rangeCard_Title = (findDisplay 46) ctrlCreate ["RscStructuredText",1101];
				MAZ_rangeCard_Title ctrlSetStructuredText parseText "<t size='0.025'>&#160;</t><br/><t size='1.5' align='center'>Mortar Range Card</t>";
				MAZ_rangeCard_Title ctrlSetTextColor [1,1,1,1];
				MAZ_rangeCard_Title ctrlSetPosition [0.00499997 * safezoneW + safezoneX,0.126 * safezoneH + safezoneY,0.170156 * safezoneW,0.033 * safezoneH];
				MAZ_rangeCard_Title ctrlSetBackgroundColor [0.6,0,0,0.75];
				MAZ_rangeCard_Title ctrlCommit 0;

				MAZ_rangeCard_RangeText = (findDisplay 46) ctrlCreate ["RscStructuredText",1102];
				MAZ_rangeCard_RangeText ctrlSetStructuredText parseText "<t align='center'>Close:</t><br/><t align='left'>100m - 84.25</t><t align='right'>400m - 63.45</t><br/><t align='left'>200m - 78.25</t><t align='right'>500m - 45.00</t><br/><t align='left'>300m - 71.60</t><t align='center'><br/>Medium:</t><br/><t align='left'>150m - 87.88</t><t align='right'>800m - 78.25</t><br/><t align='left'>200m - 87.15</t><t align='right'>900m - 76.75</t><br/><t align='left'>300m - 85.70</t><t align='right'>1000m - 75.00</t><br/><t align='left'>400m - 84.25</t><t align='right'>1500m - 60.00</t><br/><t align='left'>500m - 82.80</t><t align='right'>1750m - 45.06</t><br/><t align='left'>600m - 81.15</t><t align='right'>2000m - 45.00</t><br/><t align='left'>700m - 79.75</t><br/><t align='center'>Far:</t><br/><t align='left'>1000m - 82.901</t><t align='right'>2600m - 70.191</t><br/><t align='left'>1100m - 82.174</t><t align='right'>2700m - 69.267</t><br/><t align='left'>1200m - 81.442</t><t align='right'>2800m - 68.315</t><br/><t align='left'>1300m - 80.704</t><t align='right'>2900m - 67.332</t><br/><t align='left'>1400m - 79.959</t><t align='right'>3000m - 66.314</t><br/><t align='left'>1500m - 79.207</t><t align='right'>3100m - 65.255</t><br/><t align='left'>1600m - 78.448</t><t align='right'>3200m - 64.255</t><br/><t align='left'>1700m - 77.679</t><t align='right'>3300m - 62.984</t><br/><t align='left'>1800m - 76.901</t><t align='right'>3400m - 61.751</t><br/><t align='left'>1900m - 76.113</t><t align='right'>3500m - 60.432</t><br/><t align='left'>2000m - 75.313</t><t align='right'>3600m - 59.002</t><br/><t align='left'>2100m - 74.500</t><t align='right'>3700m - 57.424</t><br/><t align='left'>2200m - 73.673</t><t align='right'>3800m - 55.629</t><br/><t align='left'>2300m - 72.830</t><t align='right'>3900m - 53.483</t><br/><t align='left'>2400m - 71.971</t><t align='right'>4000m - 50.593</t><br/><t align='left'>2500m - 71.092</t><br/><t align='center'>Press 1 or F to change ranging</t>";
				MAZ_rangeCard_RangeText ctrlSetTextColor [1,1,1,1];
				MAZ_rangeCard_RangeText ctrlSetPosition [0.0153118 * safezoneW + safezoneX,0.17 * safezoneH + safezoneY,0.149531 * safezoneW,0.690 * safezoneH];
				MAZ_rangeCard_RangeText ctrlSetBackgroundColor [0,0,0,0.7];
				MAZ_rangeCard_RangeText ctrlCommit 0;

				MAZ_rangeCard_ctrls = [MAZ_rangeCard_BG,MAZ_rangeCard_Title,MAZ_rangeCard_RangeText];
			};
			[uiNamespace getVariable "MAZ_rangeCard_RangeText"] call MAZ_fnc_rangeCardText;
		};

		MAZ_fnc_closeMortarRangeCard = {
			with uiNamespace do {
				{
					ctrlDelete _x;
				}forEach MAZ_rangeCard_ctrls;
			};
		};

		MAZ_fnc_rangeCardText = {
			params ["_ctrl"];
			private _text = "<t align='left'>Dist - Elev</t><t align='right'>Dist - Elev</t><br/><t align='center'>Close:</t><br/>";
			{
				if(_forEachIndex % 2 == 0) then {
					comment "Even";
					_text = _text + "<t align='left'>" + _x + "</t>";
				} else {
					_text = _text + "<t align='right'>" + _x + "</t><br/>";
				};
			}forEach [
				"100m - 84.25", 
				"400m - 63.45", 
				"200m - 78.25", 
				"500m - 45.00", 
				"300m - 71.60"
			];
			_text = _text + "<br/><t align='center'>Medium:</t><br/>";
			{
				if(_forEachIndex % 2 == 0) then {
					comment "Even";
					_text = _text + "<t align='left'>" + _x + "</t>";
				} else {
					_text = _text + "<t align='right'>" + _x + "</t><br/>";
				};
			}forEach [
				"150m - 87.88", 
				"800m - 78.25", 
				"200m - 87.15", 
				"900m - 76.75", 
				"300m - 85.70",
				"1,000m - 75.00",
				"400m - 84.25",
				"1,500m - 60.00",
				"500m - 82.80",
				"1,750m - 45.06",
				"600m - 81.15",
				"2,000m - 45.00",
				"700m - 79.75"
			];
			_text = _text + "<br/><t align='center'>Far:</t><br/>";
			{
				if(_forEachIndex % 2 == 0) then {
					comment "Even";
					_text = _text + "<t align='left'>" + _x + "</t>";
				} else {
					_text = _text + "<t align='right'>" + _x + "</t><br/>";
				};
			}forEach [
				"1,000m - 82.901",
				"2,600m - 70.191",
				"1,100m - 82.174",
				"2,700m - 69.267",
				"1,200m - 81.442",
				"2,800m - 68.315",
				"1,300m - 80.704",
				"2,900m - 67.332",
				"1,400m - 79.959",
				"3,000m - 66.314",
				"1,500m - 79.207",
				"3,100m - 65.255",
				"1,600m - 78.448",
				"3,200m - 64.255",
				"1,700m - 77.679",
				"3,300m - 62.984",
				"1,800m - 76.901",
				"3,400m - 61.751",
				"1,900m - 76.113",
				"3,500m - 60.432",
				"2,000m - 75.313",
				"3,600m - 59.002",
				"2,100m - 74.500",
				"3,700m - 57.424",
				"2,200m - 73.673",
				"3,800m - 55.629",
				"2,300m - 72.830",
				"3,900m - 53.483",
				"2,400m - 71.971",
				"4,000m - 50.593",
				"2,500m - 71.092"
			];
			_text = _text + "<br/><t align='center'>Press 1 or F to change ranging</t>";
			_ctrl ctrlSetStructuredText parseText _text;
		};

		MAZ_fnc_giveMortarEH = {
			waitUntil {uisleep 0.1;!isNull (findDisplay 46) && alive player};
			sleep 0.1;
			
			if(!isNil "MAZ_EH_GetInMan_MortarCard") then {
				player removeEventHandler ["GetInMan",MAZ_EH_GetInMan_MortarCard];
			};
			MAZ_EH_GetInMan_MortarCard = player addEventHandler ["GetInMan",{
				params ["_unit", "_role", "_vehicle", "_turret"];
				if(!MAZ_EP_BetterMortarsEnabled) exitWith {};
				if(typeOf _vehicle isKindOf "Mortar_01_base_F") then {
					call MAZ_fnc_openMortarRangeCard;
					enableEngineArtillery false;
				};
			}];

			if(!isNil "MAZ_EH_GetOutMan_MortarCard") then {
				player removeEventHandler ["GetOutMan",MAZ_EH_GetOutMan_MortarCard];
			};
			MAZ_EH_GetOutMan_MortarCard = player addEventHandler ["GetOutMan", {
				params ["_unit", "_role", "_vehicle", "_turret"];
				if(!MAZ_EP_BetterMortarsEnabled) exitWith {};
				if(typeOf _vehicle isKindOf "Mortar_01_base_F") then {
					call MAZ_fnc_closeMortarRangeCard;
					enableEngineArtillery true;
				};
			}];

			if(!isNil "MAZ_EH_FiredMan_MortarLoudness") then {
				player removeEventHandler ["FiredMan",MAZ_EH_FiredMan_MortarLoudness];
			};
			MAZ_EH_FiredMan_MortarLoudness = player addEventHandler ["FiredMan",{
                params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
				if(!MAZ_EP_BetterMortarsEnabled) exitWith {};
                if(typeOf _vehicle isKindOf "Mortar_01_base_F") then {
					private _isEarplugsIn = player getVariable ['isEarplugsIn',false];
					if(_isEarplugsIn) then {
						playSound3D ["A3\Missions_F_EPA\data\sounds\combat_deafness.wss",player, false, getPosASL player, 0.2, 1, 55, 0, true];
					} else {
						playSound "combat_deafness";
					};
				};
            }];

			if(!isNil "MAZ_EH_FiredNear_MortarLoudness") then {
				player removeEventHandler ["FiredNear",MAZ_EH_FiredNear_MortarLoudness];
			};
			comment "TODO : Make ear ringing not stack";
            MAZ_EH_FiredNear_MortarLoudness = player addEventHandler ["FiredNear", {
                params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
				if(!MAZ_EP_BetterMortarsEnabled) exitWith {};
				if(((typeOf (vehicle _firer)) isKindOf "Mortar_01_base_F") && _distance <= 15) then {
					private _isEarplugsIn = player getVariable ['isEarplugsIn',false];
					if(_isEarplugsIn) then {
						private _volume = (0.5*((15-_distance)/15));
						playSound3D ["A3\Missions_F_EPA\data\sounds\combat_deafness.wss",player, false, getPosASL player, _volume, 1, 55, 0, true];
					} else {
						playSound "combat_deafness";
					};
				};
            }];
		};
		[] spawn MAZ_fnc_giveMortarEH;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		[
			"Balanced Mortars", 
			"Mortars don't have artillery computers and require usage of a range card which makes fire inaccurate. In addition, when firing or near fired mortars your ears will ring. Ringing is reduced when using earplugs.",
			[
				"Mortar range cards replace the artillery computer",
				"Ears ring when earplugs aren't put in and mortars fire nearby"
			]
		] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Better Mortars System has been loaded! Mortars will now require a rangecard to be used accurately!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	[] spawn MAZ_EP_fnc_mortarReBalanceCarrier;
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