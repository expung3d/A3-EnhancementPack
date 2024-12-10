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
if(missionNamespace getVariable ["MAZ_EP_increaseFuelUse",false]) exitWith {playSound "addItemFailed"; systemChat "[EP] - Increased Fuel Use already running!";};

private _varName = "MAZ_System_EnhancementPack_IFU";
private _myJIPCode = "MAZ_EPSystem_IFU_JIP";

[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addNewSetting"};
	["Increased Fuel Burn","Whether to enable the Increased Fuel Burn system.","MAZ_EP_increaseFuelUse",true,"TOGGLE",[],"MAZ_IFB"] call MAZ_EP_fnc_addNewSetting;
	["Wheeled Fuel Consumption Rate","The rate at which wheeled vehicles burn fuel.\nMultiply the normal burn rate by this value.","MAZ_fuelConsumptionRateWheeled",3,"SLIDER",[1,5],"MAZ_IFB"] call MAZ_EP_fnc_addNewSetting;
	["Tracked Fuel Consumption Rate","The rate at which tracked vehicles burn fuel.\nMultiply the normal burn rate by this value.","MAZ_fuelConsumptionRateTracked",2,"SLIDER",[1,5],"MAZ_IFB"] call MAZ_EP_fnc_addNewSetting;
	["Plane Fuel Consumption Rate","The rate at which planes burn fuel.\nMultiply the normal burn rate by this value.","MAZ_fuelConsumptionRatePlane",8,"SLIDER",[1,15],"MAZ_IFB"] call MAZ_EP_fnc_addNewSetting;
	["Heli Fuel Consumption Rate","The rate at which helicopters burn fuel.\nMultiply the normal burn rate by this value.","MAZ_fuelConsumptionRateHeli",6,"SLIDER",[1,15],"MAZ_IFB"] call MAZ_EP_fnc_addNewSetting;
};

private _value = (str {
	MAZ_increaseFuelConsumptionInit = {
		waitUntil {uiSleep 0.1;missionNamespace getVariable ["MAZ_EP_SettingsLoaded",false]};
		private _settings = ["MAZ_IFB"] call MAZ_EP_fnc_getSettingsFromSettingsGroup;
		waitUntil {uiSleep 0.1; [_settings] call MAZ_EP_fnc_isSettingsGroupInitiliazed;};
		MAZ_increaseFuelConsumptionLoop = {
			if(!MAZ_EP_increaseFuelUse) exitWith {};
			private _veh = vehicle player;
			if(_veh != player && isEngineOn _veh && driver _veh == player) then {
				private _type = typeOf _veh;
				private _fuelCapacityMax = getNumber (configfile >> "CfgVehicles" >> _type >> "fuelCapacity");
				private _fuelConsumptionRate = getNumber (configfile >> "CfgVehicles" >> _type >> "fuelConsumptionRate");
				if(_type isKindOf "LandVehicle") then {
					if(_type isKindOf "Tank") then {
						if(MAZ_fuelConsumptionRateTracked > 1) then {
							_veh setFuel ((fuel _veh) - (_fuelConsumptionRate/_fuelCapacityMax * (0.05 * MAZ_fuelConsumptionRateTracked)));
						};
					} else {
						if(MAZ_fuelConsumptionRateWheeled > 1) then {
							_veh setFuel ((fuel _veh) - (_fuelConsumptionRate/_fuelCapacityMax * (0.05 * MAZ_fuelConsumptionRateWheeled)));
						};
					};
				};
				if(_type isKindOf "Plane") then {
					if(MAZ_fuelConsumptionRatePlane > 1) then {
						_veh setFuel ((fuel _veh) - (_fuelConsumptionRate/_fuelCapacityMax * (0.10 * MAZ_fuelConsumptionRatePlane)));
					};
				};
				if(_type isKindOf "Helicopter") then {
					if(MAZ_fuelConsumptionRateHeli > 1) then {
						_veh setFuel ((fuel _veh) - (_fuelConsumptionRate/_fuelCapacityMax * (0.10 * MAZ_fuelConsumptionRateHeli)));
					};
				};
			};
		};

		while {MAZ_EP_CoreEnabled} do {
			[] spawn MAZ_increaseFuelConsumptionLoop;
			sleep 0.1;
		};
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_addDiaryRecord"};
		["Increased Fuel Burn", "Vehicles will use much more fuel than before. This creates a need for land and air vehicles to return to base and refuel between missions."] call MAZ_EP_fnc_addDiaryRecord;
	};
	[] spawn {
		waitUntil {uiSleep 0.1; !isNil "MAZ_EP_fnc_createNotification"};
		[
			"Increased Fuel Burn System has been loaded! In this economy?!",
			"System Initialization Notification"
		] spawn MAZ_EP_fnc_createNotification;
	};
	[] spawn MAZ_increaseFuelConsumptionInit;
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