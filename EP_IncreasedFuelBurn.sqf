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

MAZ_EP_increaseFuelUse = true;
publicVariable 'MAZ_EP_increaseFuelUse';

MAZ_fuelConsumptionRateGround = 2;
publicVariable 'MAZ_fuelConsumptionRateGround';

MAZ_fuelConsumptionRateAir = 6;
publicVariable 'MAZ_fuelConsumptionRateAir';

private _value = (str {
	MAZ_increaseFuelConsumptionInit = {
		MAZ_increaseFuelConsumptionLoop = {
			private _veh = vehicle player;
			if(_veh != player && isEngineOn _veh && driver _veh == player) then {
				private _fuelCapacityMax = getNumber (configfile >> "CfgVehicles" >> typeOf _veh >> "fuelCapacity");
				private _fuelConsumptionRate = getNumber (configfile >> "CfgVehicles" >> typeOf _veh >> "fuelConsumptionRate");
				if(typeOf _veh isKindOf "Land") then {
					_veh setFuel ((fuel _veh) - (_fuelConsumptionRate/_fuelCapacityMax * MAZ_fuelConsumptionRateGround));
				};
				if(typeOf _veh isKindOf "Air") then {
					_veh setFuel ((fuel _veh) - (_fuelConsumptionRate/_fuelCapacityMax * MAZ_fuelConsumptionRateAir));
				};
			};
		};

		while {MAZ_EP_increaseFuelUse} do {
			[] spawn MAZ_increaseFuelConsumptionLoop;
			sleep 1;
		};
	};
	if(!isNil "MAZ_EP_fnc_addDiaryRecord") then {
		["Increased Fuel Burn", "Vehicles will use much more fuel than before. This creates a need for land and air vehicles to return to base and refuel between missions."] call MAZ_EP_fnc_addDiaryRecord;
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