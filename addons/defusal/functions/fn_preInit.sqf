#include "..\script_component.hpp"
// TLB Interactions - Defusal: settings and static data. Runs via CfgFunctions
// preInit.

diag_log text "[TLB Interactions] preInit: registering settings";

// Hard defaults first, so the addon still behaves if CBA's settings layer is
// unavailable for any reason. addSetting overwrites each of these immediately
// below with the configured value.
tlbi_defusal_enabled = true;
tlbi_defusal_difficulty = 1;
tlbi_defusal_minWires = 3;
tlbi_defusal_maxWires = 5;
tlbi_defusal_excavation = true;
tlbi_defusal_autoClear = false;
tlbi_defusal_clearSpeed = 1;
tlbi_defusal_dirtTime = 0.6;
tlbi_defusal_tapeTime = 1.4;
tlbi_defusal_probeTime = 2.5;
tlbi_defusal_ohmsRisk = 0.25;
tlbi_defusal_cutTime = 2;
tlbi_defusal_failureMode = FAILURE_INSTANT;
tlbi_defusal_countdownTime = 4;
tlbi_defusal_timeLimit = 0;
tlbi_defusal_respectAceExplodeOnDefuse = false;
tlbi_defusal_classesIed = "";
tlbi_defusal_classesMine = "";
tlbi_defusal_classesTrip = "";
tlbi_defusal_prodTime = 1.2;
tlbi_defusal_digTime = 1.0;
tlbi_defusal_plateProdRisk = 0.5;
tlbi_defusal_pinTime = 4;
tlbi_defusal_pinSlips = 2;
tlbi_defusal_grassTime = 0.7;
tlbi_defusal_tensionTime = 2;
tlbi_defusal_branchChance = 0.3;
tlbi_defusal_tripIndoorGrass = true;
tlbi_hybrid_enabled = false;
tlbi_hybrid_timeScale = 1;
tlbi_hybrid_doorTime = 10;
tlbi_hybrid_hotwireTime = 30;

// Hybrid mode bars that are this mod's own, with no stock bar to borrow a time
// from, take longer the harder the lock: [civilian, military or service,
// reinforced or armoured].
tlbi_hybrid_classScale = [1, 1.5, 2];

// Difficulty presets. Every slider below stays the base value; the preset
// adjusts it where it is used (see DIFF_* in script_component.hpp):
//   [extra conductors, continuity risk x, plate prod risk x, pin band x,
//    extra pin slips, branch chance x]
tlbi_defusal_difficultyTable = [
    [-1, 0.4, 0.4, 1.35,  1, 0.5],  // Easy
    [ 0, 1.0, 1.0, 1.00,  0, 1.0],  // Normal
    [ 1, 1.5, 1.4, 0.85,  0, 1.5],  // Hard
    [ 2, 2.0, 1.8, 0.72, -1, 2.0]   // Expert
];

// Insulation colours. Dull PVC rather than primaries, with black and grey in
// the mix, because a real loom is mostly black and nothing about a device built
// in a shed is brightly coloured.
tlbi_defusal_palette = [
    [[0.66, 0.20, 0.17, 1], "STR_tlbi_defusal_colour_red"],
    [[0.17, 0.31, 0.56, 1], "STR_tlbi_defusal_colour_blue"],
    [[0.79, 0.65, 0.17, 1], "STR_tlbi_defusal_colour_yellow"],
    [[0.25, 0.48, 0.26, 1], "STR_tlbi_defusal_colour_green"],
    [[0.79, 0.77, 0.71, 1], "STR_tlbi_defusal_colour_white"],
    [[0.44, 0.29, 0.53, 1], "STR_tlbi_defusal_colour_violet"],
    [[0.74, 0.42, 0.14, 1], "STR_tlbi_defusal_colour_orange"],
    [[0.42, 0.29, 0.19, 1], "STR_tlbi_defusal_colour_brown"],
    [[0.13, 0.13, 0.12, 1], "STR_tlbi_defusal_colour_black"],
    [[0.38, 0.39, 0.36, 1], "STR_tlbi_defusal_colour_grey"]
];

#define SETTINGS_CATEGORY ["$STR_tlbi_settings_category", "$STR_tlbi_defusal_settings_sub"]

[
    "tlbi_defusal_enabled", "CHECKBOX",
    ["$STR_tlbi_defusal_set_enabled", "$STR_tlbi_defusal_set_enabled_desc"],
    SETTINGS_CATEGORY, true, 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_difficulty", "LIST",
    ["$STR_tlbi_defusal_set_difficulty", "$STR_tlbi_defusal_set_difficulty_desc"],
    SETTINGS_CATEGORY,
    [
        [0, 1, 2, 3],
        ["$STR_tlbi_difficulty_easy", "$STR_tlbi_difficulty_normal", "$STR_tlbi_difficulty_hard", "$STR_tlbi_difficulty_expert"],
        1
    ], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_minWires", "SLIDER",
    ["$STR_tlbi_defusal_set_minWires", "$STR_tlbi_defusal_set_minWires_desc"],
    SETTINGS_CATEGORY, [3, 8, 3, 0], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_maxWires", "SLIDER",
    ["$STR_tlbi_defusal_set_maxWires", "$STR_tlbi_defusal_set_maxWires_desc"],
    SETTINGS_CATEGORY, [3, 8, 5, 0], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_excavation", "CHECKBOX",
    ["$STR_tlbi_defusal_set_excavation", "$STR_tlbi_defusal_set_excavation_desc"],
    SETTINGS_CATEGORY, true, 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_autoClear", "CHECKBOX",
    ["$STR_tlbi_defusal_set_autoClear", "$STR_tlbi_defusal_set_autoClear_desc"],
    SETTINGS_CATEGORY, false, 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_clearSpeed", "SLIDER",
    ["$STR_tlbi_defusal_set_clearSpeed", "$STR_tlbi_defusal_set_clearSpeed_desc"],
    SETTINGS_CATEGORY, [0.25, 5, 1, 2], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_dirtTime", "SLIDER",
    ["$STR_tlbi_defusal_set_dirtTime", "$STR_tlbi_defusal_set_dirtTime_desc"],
    SETTINGS_CATEGORY, [0.2, 5, 0.6, 1], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_tapeTime", "SLIDER",
    ["$STR_tlbi_defusal_set_tapeTime", "$STR_tlbi_defusal_set_tapeTime_desc"],
    SETTINGS_CATEGORY, [0.2, 8, 1.4, 1], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_probeTime", "SLIDER",
    ["$STR_tlbi_defusal_set_probeTime", "$STR_tlbi_defusal_set_probeTime_desc"],
    SETTINGS_CATEGORY, [0.5, 10, 2.5, 1], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_ohmsRisk", "SLIDER",
    ["$STR_tlbi_defusal_set_ohmsRisk", "$STR_tlbi_defusal_set_ohmsRisk_desc"],
    SETTINGS_CATEGORY, [0, 1, 0.25, 0, true], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_cutTime", "SLIDER",
    ["$STR_tlbi_defusal_set_cutTime", "$STR_tlbi_defusal_set_cutTime_desc"],
    SETTINGS_CATEGORY, [0.5, 15, 2, 1], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_failureMode", "LIST",
    ["$STR_tlbi_defusal_set_failure", "$STR_tlbi_defusal_set_failure_desc"],
    SETTINGS_CATEGORY,
    [
        [FAILURE_INSTANT, FAILURE_COUNTDOWN, FAILURE_ONESTRIKE],
        ["$STR_tlbi_defusal_failure_instant", "$STR_tlbi_defusal_failure_countdown", "$STR_tlbi_defusal_failure_onestrike"],
        0
    ], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_countdownTime", "SLIDER",
    ["$STR_tlbi_defusal_set_countdown", "$STR_tlbi_defusal_set_countdown_desc"],
    SETTINGS_CATEGORY, [1, 15, 4, 1], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_timeLimit", "SLIDER",
    ["$STR_tlbi_defusal_set_timeLimit", "$STR_tlbi_defusal_set_timeLimit_desc"],
    SETTINGS_CATEGORY, [0, 600, 0, 0], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_respectAceExplodeOnDefuse", "CHECKBOX",
    ["$STR_tlbi_defusal_set_aceExplode", "$STR_tlbi_defusal_set_aceExplode_desc"],
    SETTINGS_CATEGORY, false, 1
] call CBA_fnc_addSetting;

// --- Device types -----------------------------------------------------------
#define TYPES_CATEGORY ["$STR_tlbi_settings_category", "$STR_tlbi_defusal_settings_sub_types"]

[
    "tlbi_defusal_classesIed", "EDITBOX",
    ["$STR_tlbi_defusal_set_classesIed", "$STR_tlbi_defusal_set_classesIed_desc"],
    TYPES_CATEGORY, "", 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_classesMine", "EDITBOX",
    ["$STR_tlbi_defusal_set_classesMine", "$STR_tlbi_defusal_set_classesMine_desc"],
    TYPES_CATEGORY, "", 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_classesTrip", "EDITBOX",
    ["$STR_tlbi_defusal_set_classesTrip", "$STR_tlbi_defusal_set_classesTrip_desc"],
    TYPES_CATEGORY, "", 1
] call CBA_fnc_addSetting;

// --- Mines ------------------------------------------------------------------
#define MINES_CATEGORY ["$STR_tlbi_settings_category", "$STR_tlbi_defusal_settings_sub_mines"]

[
    "tlbi_defusal_prodTime", "SLIDER",
    ["$STR_tlbi_defusal_set_prodTime", "$STR_tlbi_defusal_set_prodTime_desc"],
    MINES_CATEGORY, [0.3, 5, 1.2, 1], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_digTime", "SLIDER",
    ["$STR_tlbi_defusal_set_digTime", "$STR_tlbi_defusal_set_digTime_desc"],
    MINES_CATEGORY, [0.3, 5, 1.0, 1], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_plateProdRisk", "SLIDER",
    ["$STR_tlbi_defusal_set_plateProdRisk", "$STR_tlbi_defusal_set_plateProdRisk_desc"],
    MINES_CATEGORY, [0, 1, 0.5, 0, true], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_pinTime", "SLIDER",
    ["$STR_tlbi_defusal_set_pinTime", "$STR_tlbi_defusal_set_pinTime_desc"],
    MINES_CATEGORY, [1, 15, 4, 1], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_pinSlips", "SLIDER",
    ["$STR_tlbi_defusal_set_pinSlips", "$STR_tlbi_defusal_set_pinSlips_desc"],
    MINES_CATEGORY, [0, 5, 2, 0], 1
] call CBA_fnc_addSetting;

// --- Tripwires --------------------------------------------------------------
#define TRIP_CATEGORY ["$STR_tlbi_settings_category", "$STR_tlbi_defusal_settings_sub_trip"]

[
    "tlbi_defusal_grassTime", "SLIDER",
    ["$STR_tlbi_defusal_set_grassTime", "$STR_tlbi_defusal_set_grassTime_desc"],
    TRIP_CATEGORY, [0.2, 5, 0.7, 1], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_tensionTime", "SLIDER",
    ["$STR_tlbi_defusal_set_tensionTime", "$STR_tlbi_defusal_set_tensionTime_desc"],
    TRIP_CATEGORY, [0.5, 8, 2, 1], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_branchChance", "SLIDER",
    ["$STR_tlbi_defusal_set_branchChance", "$STR_tlbi_defusal_set_branchChance_desc"],
    TRIP_CATEGORY, [0, 1, 0.3, 0, true], 1
] call CBA_fnc_addSetting;

[
    "tlbi_defusal_tripIndoorGrass", "CHECKBOX",
    ["$STR_tlbi_defusal_set_tripIndoorGrass", "$STR_tlbi_defusal_set_tripIndoorGrass_desc"],
    TRIP_CATEGORY, true, 1
] call CBA_fnc_addSetting;

// --- Hybrid mode ------------------------------------------------------------
// Every board reads these, not only defusal: this addon is the one the
// lockpicking and vehicle boards already build on (fn_hybridBar).
#define HYBRID_CATEGORY ["$STR_tlbi_settings_category", "$STR_tlbi_hybrid_settings_sub"]

[
    "tlbi_hybrid_enabled", "CHECKBOX",
    ["$STR_tlbi_hybrid_set_enabled", "$STR_tlbi_hybrid_set_enabled_desc"],
    HYBRID_CATEGORY, false, 1
] call CBA_fnc_addSetting;

[
    "tlbi_hybrid_timeScale", "SLIDER",
    ["$STR_tlbi_hybrid_set_timeScale", "$STR_tlbi_hybrid_set_timeScale_desc"],
    HYBRID_CATEGORY, [0.25, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    "tlbi_hybrid_doorTime", "SLIDER",
    ["$STR_tlbi_hybrid_set_doorTime", "$STR_tlbi_hybrid_set_doorTime_desc"],
    HYBRID_CATEGORY, [1, 120, 10, 0], 1
] call CBA_fnc_addSetting;

[
    "tlbi_hybrid_hotwireTime", "SLIDER",
    ["$STR_tlbi_hybrid_set_hotwireTime", "$STR_tlbi_hybrid_set_hotwireTime_desc"],
    HYBRID_CATEGORY, [5, 300, 30, 0], 1
] call CBA_fnc_addSetting;

diag_log text "[TLB Interactions] preInit: done";
