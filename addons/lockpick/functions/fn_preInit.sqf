#include "..\script_component.hpp"
// TLB Interactions - Lockpicking: settings and tuning. Runs via CfgFunctions
// preInit.

diag_log text "[TLB Interactions] lockpick preInit";

// --- Door classes -----------------------------------------------------------
// [civilian, military, reinforced]: pins in the cylinder, and a scale on every
// window (shear line, tension band, sweet spot).
tlbi_lockpick_classPins = [4, 5, 6];
tlbi_lockpick_classScale = [1, 0.85, 0.72];

// --- Difficulty levels ------------------------------------------------------
// One row per level: Very easy, Easy, Normal, Hard, Expert. Each technique has
// its own level for a kit and for a paperclip (settings below); the technique's
// fine-tuning sliders then scale the row. Shake only ever applies to a paperclip.
// Normal and Hard are the values previously tuned by offline simulation for a
// kit and a paperclip, which is why they are the defaults for those tools.

// Pin tumbler: [shear-line window, binding pin lift speed, paperclip shake,
//               extra pins, glint on the binding pin: 0 never / 1 kit / 2 both]
tlbi_lockpick_presetPins = [
    [0.50, 0.30, 0.35, -2, 2],
    [0.36, 0.42, 0.60, -1, 2],
    [0.24, 0.55, 0.70,  0, 1],
    [0.19, 0.55, 0.90,  0, 1],
    [0.14, 0.70, 1.30,  1, 0]
];

// Rake: [tension band width, band drift, chance a stroke sets a pin,
//        chance raking over the band slips, chance raking under it drops a pin,
//        tension build speed, extra pins]
tlbi_lockpick_presetRake = [
    [0.62, 0.08, 0.60, 0.10, 0.25, 0.8, -2],
    [0.42, 0.15, 0.45, 0.30, 0.50, 1.0, -1],
    [0.26, 0.25, 0.32, 0.50, 1.00, 1.2,  0],
    [0.23, 0.25, 0.24, 0.50, 1.00, 1.2,  0],
    [0.16, 0.35, 0.18, 0.70, 1.00, 1.4,  1]
];

// Sweet spot: [sweet spot width (degrees), strain tolerance (s), paperclip shake
//              (degrees/s), how far off the spot the plug still turns (degrees)]
tlbi_lockpick_presetDial = [
    [32, 3.0,  8, 100],
    [22, 2.2, 14,  80],
    [12, 1.4, 20,  60],
    [ 7, 0.9, 25,  60],
    [ 5, 0.7, 32,  45]
];

// Hard defaults, overwritten by addSetting below.
tlbi_lockpick_enabled = true;
tlbi_lockpick_takeOverTsp = true;
tlbi_lockpick_aceLockpick = true;
tlbi_lockpick_vehicles = true;
tlbi_lockpick_clipBends = 2;
tlbi_lockpick_classesMilitary = "";
tlbi_lockpick_classesReinforced = "";

#define LP_CATEGORY ["$STR_tlbi_settings_category", "$STR_tlbi_lockpick_settings_sub"]

[
    "tlbi_lockpick_enabled", "CHECKBOX",
    ["$STR_tlbi_lockpick_set_enabled", "$STR_tlbi_lockpick_set_enabled_desc"],
    LP_CATEGORY, true, 1
] call CBA_fnc_addSetting;

[
    "tlbi_lockpick_takeOverTsp", "CHECKBOX",
    ["$STR_tlbi_lockpick_set_takeOverTsp", "$STR_tlbi_lockpick_set_takeOverTsp_desc"],
    LP_CATEGORY, true, 1
] call CBA_fnc_addSetting;

[
    "tlbi_lockpick_aceLockpick", "CHECKBOX",
    ["$STR_tlbi_lockpick_set_aceLockpick", "$STR_tlbi_lockpick_set_aceLockpick_desc"],
    LP_CATEGORY, true, 1
] call CBA_fnc_addSetting;

// Read by TLB Keys: whether a locked vehicle is picked on this board, or left
// to its own progress bar. Harmless without that mod.
[
    "tlbi_lockpick_vehicles", "CHECKBOX",
    ["$STR_tlbi_lockpick_set_vehicles", "$STR_tlbi_lockpick_set_vehicles_desc"],
    LP_CATEGORY, true, 1
] call CBA_fnc_addSetting;

[
    "tlbi_lockpick_clipBends", "SLIDER",
    ["$STR_tlbi_lockpick_set_clipBends", "$STR_tlbi_lockpick_set_clipBends_desc"],
    LP_CATEGORY, [0, 6, 2, 0], 1
] call CBA_fnc_addSetting;

[
    "tlbi_lockpick_classesMilitary", "EDITBOX",
    ["$STR_tlbi_lockpick_set_classesMilitary", "$STR_tlbi_lockpick_set_classesMilitary_desc"],
    LP_CATEGORY,
    "Land_Barracks_*, Land_i_Barracks_*, Land_u_Barracks_*, Land_Mil_*, Land_MilOffices_*, Land_GuardHouse_*, Land_ControlTower_*, Land_Army_hut*, Land_Budova4*",
    1
] call CBA_fnc_addSetting;

[
    "tlbi_lockpick_classesReinforced", "EDITBOX",
    ["$STR_tlbi_lockpick_set_classesReinforced", "$STR_tlbi_lockpick_set_classesReinforced_desc"],
    LP_CATEGORY,
    "Land_Cargo_*, Land_Medevac_*, Land_Ammostore*, Land_Garaz_*, Land_Bunker_*",
    1
] call CBA_fnc_addSetting;

// --- Per technique ----------------------------------------------------------
// Each technique gets its own settings page: a difficulty level for the kit and
// one for the paperclip, how often each tool draws it, and fine-tuning sliders.
// Setting names are tlbi_lockpick_<technique><suffix>, e.g. tlbi_lockpick_rakeClip
// or tlbi_lockpick_rakeBand; fn_start reads them by those names.
//
//   [technique, kit odds, paperclip odds, [[suffix, [min, max, default, decimals]], ...]]
private _levelNames = [
    "$STR_tlbi_lockpick_level_0", "$STR_tlbi_lockpick_level_1", "$STR_tlbi_lockpick_level_2",
    "$STR_tlbi_lockpick_level_3", "$STR_tlbi_lockpick_level_4"
];

{
    _x params ["_key", "_oddsKit", "_oddsClip", "_tunes"];

    private _category = ["$STR_tlbi_settings_category", "$STR_tlbi_lockpick_settings_sub_" + _key];

    {
        _x params ["_suffix", "_level"];
        [
            format ["tlbi_lockpick_%1%2", _key, _suffix], "LIST",
            ["$STR_tlbi_lockpick_set_level" + _suffix, "$STR_tlbi_lockpick_set_level_desc"],
            _category, [[0, 1, 2, 3, 4], _levelNames, _level], 1
        ] call CBA_fnc_addSetting;
    } forEach [["Kit", 2], ["Clip", 3]];

    {
        _x params ["_suffix", "_odds"];
        [
            format ["tlbi_lockpick_%1Odds%2", _key, _suffix], "SLIDER",
            ["$STR_tlbi_lockpick_set_odds" + _suffix, "$STR_tlbi_lockpick_set_odds_desc"],
            _category, [0, 1, _odds, 2], 1
        ] call CBA_fnc_addSetting;
    } forEach [["Kit", _oddsKit], ["Clip", _oddsClip]];

    {
        _x params ["_suffix", "_range"];
        [
            format ["tlbi_lockpick_%1%2", _key, _suffix], "SLIDER",
            [format ["$STR_tlbi_lockpick_set_%1%2", _key, _suffix], format ["$STR_tlbi_lockpick_set_%1%2_desc", _key, _suffix]],
            _category, _range, 1
        ] call CBA_fnc_addSetting;
    } forEach _tunes;
} forEach [
    ["pins", 0.55, 0.20, [
        ["Window", [0.25, 3, 1, 2]],
        ["Lift", [0.25, 2, 1, 2]],
        ["Shake", [0, 3, 1, 2]],
        ["Extra", [-3, 3, 0, 0]]
    ]],
    ["rake", 0.30, 0.40, [
        ["Band", [0.25, 3, 1, 2]],
        ["Drift", [0, 3, 1, 2]],
        ["Chance", [0.25, 3, 1, 2]],
        ["Tension", [0.25, 2, 1, 2]]
    ]],
    ["dial", 0.15, 0.40, [
        ["Width", [0.25, 3, 1, 2]],
        ["Strain", [0.25, 3, 1, 2]],
        ["Shake", [0, 3, 1, 2]]
    ]]
];

// --- Doors without tsp_breach -----------------------------------------------
// Ignored while tsp_breach is loaded: it has its own door actions and locking.
#define DOORS_CATEGORY ["$STR_tlbi_settings_category", "$STR_tlbi_lockpick_settings_sub_doors"]

[
    "tlbi_lockpick_doorActions", "CHECKBOX",
    ["$STR_tlbi_lockpick_set_doorActions", "$STR_tlbi_lockpick_set_doorActions_desc"],
    DOORS_CATEGORY, true, 1
] call CBA_fnc_addSetting;

[
    "tlbi_lockpick_lockHouses", "SLIDER",
    ["$STR_tlbi_lockpick_set_lockHouses", "$STR_tlbi_lockpick_set_lockHouses_desc"],
    DOORS_CATEGORY, [0, 1, 0.25, 0, true], 1
] call CBA_fnc_addSetting;

[
    "tlbi_lockpick_lockDoors", "SLIDER",
    ["$STR_tlbi_lockpick_set_lockDoors", "$STR_tlbi_lockpick_set_lockDoors_desc"],
    DOORS_CATEGORY, [0, 1, 0.5, 0, true], 1
] call CBA_fnc_addSetting;

[
    "tlbi_lockpick_lockBlacklist", "EDITBOX",
    ["$STR_tlbi_lockpick_set_lockBlacklist", "$STR_tlbi_lockpick_set_lockBlacklist_desc"],
    DOORS_CATEGORY, "", 1
] call CBA_fnc_addSetting;
