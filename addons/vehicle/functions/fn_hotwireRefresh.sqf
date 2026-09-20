#include "..\script_component.hpp"
/*
 * Author: TLB
 * Redraws the board and sets everything around it for the stage the job is at:
 * the subtitle, the stage name, which tool plates are live and what the hint line
 * says.
 *
 * The first plate does the hands-on work on the selected wire, and what that is
 * depends on the wire: a sheathed wire is stripped, a bare one is twisted onto
 * whatever the clip is already on.
 *
 * Return Value:
 * None
 */

private _display = uiNamespace getVariable ["tlbi_vehicle_display", displayNull];
private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];

if (isNull _display || {count _state == 0}) exitWith {};

private _vehicle = _state get "veh";
private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
if (count _harness <= HN_FRIED) exitWith {};

_harness params ["_wires", "_screws", "_stage", "_shorts", "_steer", "_joined"];

private _busy = _state getOrDefault ["busy", false];
private _sel = (_state getOrDefault ["sel", 0]) min ((count _wires) - 1);
private _clip = _state getOrDefault ["clip", -1];

(_display displayCtrl IDC_HW_TITLE) ctrlSetText localize "STR_tlbi_vehicle_hotwire_title";

(_display displayCtrl IDC_HW_SUBTITLE) ctrlSetText format [
    localize "STR_tlbi_vehicle_hotwire_subtitle",
    [_vehicle] call tlbi_vehicle_fnc_vehicleName,
    localize (["STR_tlbi_vehicle_class_civil", "STR_tlbi_vehicle_class_military", "STR_tlbi_vehicle_class_armoured"] select (_state get "class")),
    count _wires
];

(_display displayCtrl IDC_HW_STAGE) ctrlSetText localize ([
    "STR_tlbi_vehicle_stage_shroud",
    "STR_tlbi_vehicle_stage_wires",
    "STR_tlbi_vehicle_stage_steering",
    "STR_tlbi_vehicle_stage_crank",
    "STR_tlbi_vehicle_stage_running"
] select _stage);

// --- Tool plates ------------------------------------------------------------
private _selWire = if (count _wires > 0) then { _wires select _sel } else { [] };
private _stripped = count _selWire > WR_STRIPPED && {_selWire select WR_STRIPPED};
private _cut = count _selWire > WR_CUT && {_selWire select WR_CUT};

private _first = "";
private _hold = "";

switch (_stage) do {
    case HW_WIRES: {
        _first = localize ([
            "STR_tlbi_vehicle_btn_strip",
            "STR_tlbi_vehicle_btn_twist"
        ] select (_stripped && {!_cut}));
    };
    case HW_CRANK: { _hold = localize "STR_tlbi_vehicle_btn_crank" };
    case HW_STEERING: { _hold = localize "STR_tlbi_vehicle_btn_force" };
};

private _wireStage = _stage == HW_WIRES;

{
    _x params ["_idc", "_text", "_live"];
    private _button = _display displayCtrl _idc;
    _button ctrlSetText _text;
    _button ctrlEnable (_text != "" && {!_busy} && _live);
} forEach [
    [IDC_HW_BTN_A1, _first, _wireStage],
    [IDC_HW_BTN_A2, _hold, true],
    [IDC_HW_BTN_A3, [localize "STR_tlbi_vehicle_btn_volts", ""] select (!_wireStage), _stripped && {!_cut}],
    [IDC_HW_BTN_A4, [localize "STR_tlbi_vehicle_btn_cont", ""] select (!_wireStage), _stripped && {!_cut}],
    [IDC_HW_BTN_A5, [localize "STR_tlbi_vehicle_btn_cut", ""] select (!_wireStage), !_cut]
];

// --- The hint line ----------------------------------------------------------
private _keyHold = ["tlbi_lockpick_hold"] call tlbi_defusal_fnc_keyName;
private _keyLeft = ["tlbi_lockpick_left"] call tlbi_defusal_fnc_keyName;
private _keyRight = ["tlbi_lockpick_right"] call tlbi_defusal_fnc_keyName;

private _hint = switch (_stage) do {
    case HW_SHROUD: { format [localize "STR_tlbi_vehicle_help_shroud", _screws] };
    case HW_WIRES: {
        if (_clip >= 0) then {
            format [localize "STR_tlbi_vehicle_help_twist", _clip + 1]
        } else {
            format [localize "STR_tlbi_vehicle_help_wires", _keyLeft, _keyRight]
        }
    };
    case HW_CRANK: { format [localize "STR_tlbi_vehicle_help_crank", _keyHold] };
    case HW_STEERING: { format [localize "STR_tlbi_vehicle_help_steering", _keyHold] };
    default { localize "STR_tlbi_vehicle_help_running" };
};

[_hint] call tlbi_vehicle_fnc_hotwireStatus;

_state set ["sel", _sel];

[_display] call tlbi_vehicle_fnc_hotwireDraw;
