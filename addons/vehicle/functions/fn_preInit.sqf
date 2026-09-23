#include "..\script_component.hpp"
// TLB Interactions - Vehicles: settings and tuning. Runs via CfgFunctions
// preInit.
//
// Whether vehicle locks are picked on the board at all is the lockpicking
// setting tlbi_lockpick_vehicles, because that is the switch TLB Keys reads to
// decide who owns vehicle picking. Everything here is about what happens once
// this mod is the one in charge.

diag_log text "[TLB Interactions] vehicle preInit";

// --- Vehicle classes --------------------------------------------------------
// [civilian, military, armoured]: wires in the ignition harness, and how many of
// them are decoys. An armoured loom is unmarked, so its colours say nothing and
// the meter is the only way through.
tlbi_vehicle_classWires = [4, 5, 6];
tlbi_vehicle_classPlain = [false, false, true];

// Hard defaults, overwritten by addSetting below.
tlbi_vehicle_enabled = true;
tlbi_vehicle_hotwire = true;
tlbi_vehicle_ignitionLock = true;
tlbi_vehicle_steering = true;
tlbi_vehicle_armoured = true;
tlbi_vehicle_alarm = true;
tlbi_vehicle_tools = HWTOOL_ANY;
tlbi_vehicle_shorts = 2;
tlbi_vehicle_friedTime = 300;
tlbi_vehicle_actionTime = 2.5;
tlbi_vehicle_crankTime = 1.6;

#define VEH_CATEGORY ["$STR_tlbi_settings_category", "$STR_tlbi_vehicle_settings_sub"]

[
    "tlbi_vehicle_enabled", "CHECKBOX",
    ["$STR_tlbi_vehicle_set_enabled", "$STR_tlbi_vehicle_set_enabled_desc"],
    VEH_CATEGORY, true, 1
] call CBA_fnc_addSetting;

[
    "tlbi_vehicle_hotwire", "CHECKBOX",
    ["$STR_tlbi_vehicle_set_hotwire", "$STR_tlbi_vehicle_set_hotwire_desc"],
    VEH_CATEGORY, true, 1
] call CBA_fnc_addSetting;

[
    "tlbi_vehicle_ignitionLock", "CHECKBOX",
    ["$STR_tlbi_vehicle_set_ignitionLock", "$STR_tlbi_vehicle_set_ignitionLock_desc"],
    VEH_CATEGORY, true, 1
] call CBA_fnc_addSetting;

[
    "tlbi_vehicle_steering", "CHECKBOX",
    ["$STR_tlbi_vehicle_set_steering", "$STR_tlbi_vehicle_set_steering_desc"],
    VEH_CATEGORY, true, 1
] call CBA_fnc_addSetting;

[
    "tlbi_vehicle_armoured", "CHECKBOX",
    ["$STR_tlbi_vehicle_set_armoured", "$STR_tlbi_vehicle_set_armoured_desc"],
    VEH_CATEGORY, true, 1
] call CBA_fnc_addSetting;

[
    "tlbi_vehicle_alarm", "CHECKBOX",
    ["$STR_tlbi_vehicle_set_alarm", "$STR_tlbi_vehicle_set_alarm_desc"],
    VEH_CATEGORY, true, 1
] call CBA_fnc_addSetting;

[
    "tlbi_vehicle_tools", "LIST",
    ["$STR_tlbi_vehicle_set_tools", "$STR_tlbi_vehicle_set_tools_desc"],
    VEH_CATEGORY,
    [
        [HWTOOL_NONE, HWTOOL_ANY, HWTOOL_KIT],
        ["$STR_tlbi_vehicle_tools_none", "$STR_tlbi_vehicle_tools_any", "$STR_tlbi_vehicle_tools_kit"],
        1
    ],
    1
] call CBA_fnc_addSetting;

[
    "tlbi_vehicle_shorts", "SLIDER",
    ["$STR_tlbi_vehicle_set_shorts", "$STR_tlbi_vehicle_set_shorts_desc"],
    VEH_CATEGORY, [0, 5, 2, 0], 1
] call CBA_fnc_addSetting;

[
    "tlbi_vehicle_friedTime", "SLIDER",
    ["$STR_tlbi_vehicle_set_friedTime", "$STR_tlbi_vehicle_set_friedTime_desc"],
    VEH_CATEGORY, [0, 900, 300, 0], 1
] call CBA_fnc_addSetting;

[
    "tlbi_vehicle_actionTime", "SLIDER",
    ["$STR_tlbi_vehicle_set_actionTime", "$STR_tlbi_vehicle_set_actionTime_desc"],
    VEH_CATEGORY, [0.5, 10, 2.5, 1], 1
] call CBA_fnc_addSetting;

[
    "tlbi_vehicle_crankTime", "SLIDER",
    ["$STR_tlbi_vehicle_set_crankTime", "$STR_tlbi_vehicle_set_crankTime_desc"],
    VEH_CATEGORY, [0.4, 5, 1.6, 1], 1
] call CBA_fnc_addSetting;
