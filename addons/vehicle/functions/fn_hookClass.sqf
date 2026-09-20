#include "..\script_component.hpp"
/*
 * Author: TLB
 * Puts our vehicle actions on one vehicle class, and takes ACE's Lockpick entry
 * off it. Runs once per class, the first time a vehicle of that type exists.
 *
 * It has to be per class rather than once on Car, Tank and the rest. ACE builds
 * a class's action menu from its config the first time an object of that class
 * turns up, and its Lockpick action is declared in that config, so removing it
 * from the base class only covers the classes that happen to have been built
 * already. Adding ours with ACE's inheritance flag would work, but then the add
 * and the remove would run at different times, and one of them would lose.
 *
 * Arguments:
 * 0: Vehicle class <STRING>
 *
 * Return Value:
 * None
 */

params ["_class"];

if (isNil "tlbi_vehicle_actions") exitWith {};

private _done = missionNamespace getVariable ["tlbi_vehicle_hooked", createHashMap];
if (_done getOrDefault [_class, false]) exitWith {};
_done set [_class, true];
missionNamespace setVariable ["tlbi_vehicle_hooked", _done];

tlbi_vehicle_actions params ["_pick", "_pickAce", "_hotwire"];

// Build the class's menus first: adding is what compiles them, and ACE's own
// entry has to exist before it can be taken out.
[_class, 0, ["ACE_MainActions"], _pick] call ace_interact_menu_fnc_addActionToClass;
[_class, 0, ["ACE_MainActions"], _pickAce] call ace_interact_menu_fnc_addActionToClass;
[_class, 1, [], _hotwire] call ace_interact_menu_fnc_addActionToClass;

[_class, 0, ["ACE_MainActions", "ACE_lockpickVehicle"]] call ace_interact_menu_fnc_removeActionFromClass;
[_class, 1, ["ACE_lockpickVehicle"]] call ace_interact_menu_fnc_removeActionFromClass;

diag_log text format ["[TLB Interactions] vehicle actions on %1", _class];
