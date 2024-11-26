
# Enhancement Pack Core Functions
The Enhancement Pack has many built in functions to help with mission or script making. These can be used if the Core is running, no other systems are required.

## MAZ_EP_fnc_systemMessage
Creates a `systemChat` message with a sound effect. 
```sqf
["My message", "My sound file"] call MAZ_EP_fnc_systemMessage;
//Shows "[ EP ] : My message"
//If no sound is passed, nothing will be played
```

## MAZ_EP_fnc_createNotification
Creates a smooth notification, a maximum of three can be shown at one time. 
```sqf
[
	"Notification text",
	"Notification title", //Notification title, default "System Notification"
	DURATION, //Duration in seconds, default 5
	"Sound file", //Played sound, default "" (none)
	"Image file" //Shown image in the title bar, default a radio icon
] call MAZ_EP_fnc_createNotification;
```

## MAZ_fnc_newKeybind
Creates a new keybind into the integrated keybind system. These keybinds can be rebound by users to another key or combination of keys. 

When creating a keybind, **ALWAYS** create a variable associated to it. Creating this variable has no downside, players will not notice 4 bytes of memory being taken up. Saving these keybind IDs will allow us to remove them later. 
```sqf
MAZ_Key_KeybindID = [
	"Keybind name", //The shown name in the keybind interface
	"Keybind description", //The description of what the keybind does
	DIK_CODE, //Some number referring to a key on the keyboard (https://community.bistudio.com/wiki/DIK_KeyCodes#DIK_Codes_for_QWERTY)
	{
		//The code executed on the button press
	},
	SHIFT, //Boolean, if shift must be held to use keybind
	CTRL, //Boolean, if ctrl must be held to use keybind
	ALT, //Boolean, if alt must be held to use keybind
	OVERRIDE, //Boolean, if the keybind should override any default actions
	ZEUS_KEYBIND //Boolean, if the keybind is for the Zeus
] call MAZ_fnc_newKeybind;
```

## MAZ_fnc_removeKeybind
Removes a created keybind from the integrated keybind system. Returns `true` if the keybind was successfully deleted.
```sqf
private _deleted = [MAZ_Key_KeybindID] call MAZ_fnc_removeKeybind;
if(_deleted) then {
	["Keybind deleted!"] call MAZ_EP_fnc_systemMessage;
};
```

## MAZ_EP_fnc_addDiaryRecord
Creates a new diary record in the Enhancement Pack section in the map screen. This is primarily used to supply players with information about the systems currently active. 
```sqf
//This should be done in a scheduled environment so you can waitUntil the variable is available.
[] spawn {
	waitUntil {!isNil "MAZ_EP_fnc_addDiaryRecord"};
	[
		"System Display Name", 
		"System Description",
		[
			"Feature list items",
			"Feature #2"
		]
	] call MAZ_EP_fnc_addDiaryRecord;
};
```

## MAZ_EP_fnc_createNewSetting
Creates a new setting in the Enhancement Pack Settings system that can be modified by Zeus. Settings can be changed by placing the Core composition down again and selecting OK. Settings that are changed will be synced to current and JIP players.
```sqf
[
	"Setting Name",
	"Setting Description\nShown as a tooltip in the settings menu.",
	"VariableNameThatIsChanged", //This variable will be changed when the setting is changed
	true, //Default value. Boolean or number
	"TYPE", //TOGGLE or SLIDER
	[params] //Only used for Slider: [minValue, maxValue]
] call MAZ_EP_fnc_createNewSetting;
```

## MAZ_EP_fnc_editSettings
Opens the Enhancement Pack Settings system's editing menu. You can change the settings in this menu.
```sqf
call MAZ_EP_fnc_editSettings;
```

## MAZ_EP_fnc_addFunctionToMainLoop
Adds the specified function to the Core main loop that executes every hundredth of a second.
```sqf
["MAZ_fnc_myFunctionVariableNameAsAString"] call MAZ_EP_fnc_addFunctionToMainLoop;
```

## MAZ_EP_fnc_removeFunctionToMainLoop
Removes the specified function to the Core main loop that executes every hundredth of a second.
```sqf
["MAZ_fnc_myFunctionVariableNameAsAString"] call MAZ_EP_fnc_removeFunctionToMainLoop;
```

## MAZ_EP_fnc_addToExecQueue (Legacy)
Adds a function to the function queue. Functions added to the queue will run in the order which they were added. Functions begin only after the function prior finishes.
*Note: This function has been replaced by MAZ_EP_QueueObject. It is only still supported for backwards compatibilty.*
```sqf
[
	[Parameters],
	{
		//Function to be executed
	}
] call MAZ_EP_fnc_addToExecQueue;
```

## MAZ_EP_QueueObject
A HashMapObject class definition that acts as a Queue data structure. Functions added to the queue will be ran in the order they are added. Functions begin only after the function prior finishes. Creating a `MAZ_EP_QueueObject` creates a Queue only until the queue is empty, once it is empty the Queue will delete itself. To override this function, pass `true` as a parameter to `MAZ_EP_QueueObject`'s constructor.
```sqf
//Create a temporary Queue. Once the functions are finished it will delete itself.
MAZ_EP_tempQueue = createHashMapObject [ MAZ_EP_QueueObject ];
MAZ_EP_tempQueue call [ "addToQueue", [ [ "FUNCTION PARAMS" ], { systemChat _this; } ] ];

//Create a permanent Queue. You can add functions to this queue at any point after its creation.
MAZ_EP_permQueue = createHashMapObject [ MAZ_EP_QueueObject, [ true ] ];
MAZ_EP_permQueue call [ "addToQueue", [ [ "FUNCTION PARAMS" ], { systemChat _this; } ] ]; //This runs
//Some time later...
MAZ_EP_permQueue call [ "addToQueue", [ [ "FUNCTION PARAMS 2" ], { systemChat _this; } ] ]; //This runs
```