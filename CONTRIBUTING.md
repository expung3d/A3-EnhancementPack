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
//This if statement should exist so as to ensure the function isn't called if its undefined.
if(!isNil "MAZ_EP_fnc_addDiaryRecord") then {
	[
		"System Display Name", 
		"System Description"
	] call MAZ_EP_fnc_addDiaryRecord;
};
```
