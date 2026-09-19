#include "..\script_component.hpp"
// TLB Interactions - Lockpicking: hook into door interaction. Runs via
// CfgFunctions postInit.
//
// Two ways doors work, never both at once:
//
//  - tsp_breach loaded: it owns the doors - its ACE door actions, its random
//    locking. Its "Use Lockpick" and "Use Paperclip" call the global
//    tsp_fnc_breach_pick by name when clicked; that is a plain global (defined at
//    CBA pre-init, not compileFinal), so replacing it here sends both to our
//    board. Nothing else of ours runs.
//
//  - tsp_breach not loaded: our own door system. ACE door actions (open, close,
//    lock, unlock, pick) built at each door when the interaction menu opens, and
//    doors locked around the player from a per-mission seed.

diag_log text "[TLB Interactions] lockpick postInit";

// Rebindable under Configure Addons. The board checks these bindings itself
// (tlbi_defusal_fnc_keyMatches), because a dialog does not pass key presses to CBA.
if (hasInterface) then {
    {
        _x params ["_action", "_title", "_dik"];
        [
            "TLB Interactions", _action,
            [localize _title, localize (_title + "_desc")],
            {false}, {false}, [_dik, [false, false, false]]
        ] call CBA_fnc_addKeybind;
    } forEach [
        ["tlbi_lockpick_left", "STR_tlbi_lockpick_key_left", 30],
        ["tlbi_lockpick_right", "STR_tlbi_lockpick_key_right", 32],
        ["tlbi_lockpick_hold", "STR_tlbi_lockpick_key_hold", 57],
        ["tlbi_lockpick_rake", "STR_tlbi_lockpick_key_rake", 19]
    ];

    // Zeus Lock settings module, when Zeus Enhanced is loaded. Works with and
    // without tsp_breach, so it is registered before the tsp_breach check.
    if (isClass (configFile >> "CfgPatches" >> "zen_custom_modules")) then {
        ["TLB Interactions", "STR_tlbi_lockpick_module_name", {_this call tlbi_lockpick_fnc_zeusLock}, "\tlbi\addons\main\data\logo_small_ca.paa"] call zen_custom_modules_fnc_register;
    };

    // Zeus context menu (Zeus Enhanced): "Lock settings" when the cursor is near a
    // door handle.
    if (isClass (configFile >> "CfgPatches" >> "zen_context_menu")) then {
        [[
            "tlbi_lockSettings", localize "STR_tlbi_lockpick_module_name", "\tlbi\addons\main\data\logo_small_ca.paa",
            {
                params ["_position"];
                [_position] call tlbi_lockpick_fnc_zeusLock;
            },
            {
                params ["_position"];
                !(([_position] call tlbi_lockpick_fnc_nearestDoor) isEqualTo [])
            }
        ] call zen_context_menu_fnc_createAction, [], 0] call zen_context_menu_fnc_addAction;
    };
};

tlbi_lockpick_tspLoaded = isClass (configFile >> "CfgPatches" >> "tsp_breach");

if (tlbi_lockpick_tspLoaded) exitWith {
    if (!isNil "tsp_fnc_breach_pick") then {
        if (isNil "tlbi_lockpick_tspOriginal") then {
            tlbi_lockpick_tspOriginal = tsp_fnc_breach_pick;
        };
        tsp_fnc_breach_pick = tlbi_lockpick_fnc_tspPick;
    };

    diag_log text format ["[TLB Interactions] tsp_breach loaded - using its doors; pick %1",
        ["NOT replaced", "replaced"] select (!isNil "tsp_fnc_breach_pick" && {tsp_fnc_breach_pick isEqualTo tlbi_lockpick_fnc_tspPick})];
};

diag_log text "[TLB Interactions] tsp_breach not loaded - using our own door interactions";

// One seed per mission, chosen by the server and broadcast once (JIP included).
if (isServer && {isNil "tlbi_lockpick_lockSeed"}) then {
    missionNamespace setVariable ["tlbi_lockpick_lockSeed", floor random 1000000, true];
};

if (!hasInterface) exitWith {};

["ace_interactMenuOpened", {
    params ["_menuType"];
    if (_menuType == 0) then { call tlbi_lockpick_fnc_doorHelpers };
}] call CBA_fnc_addEventHandler;

[{ call tlbi_lockpick_fnc_lockTick }, 3] call CBA_fnc_addPerFrameHandler;
