#include "..\script_component.hpp"
/*
 * Author: TLB
 * Opens the hotwire board for the vehicle the player is sitting in.
 *
 * Everything that has been done to the harness lives on the vehicle, so the work
 * survives closing the board, backing out of the seat and handing the job to
 * somebody else. Only the board's own state, which wire is selected and what the
 * player is holding, is local.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 *
 * Return Value:
 * Board opened <BOOL>
 */

params ["_unit", "_vehicle"];

if (!([_unit, _vehicle] call tlbi_vehicle_fnc_canHotwire)) exitWith { false };

private _harness = [_vehicle] call tlbi_vehicle_fnc_harness;

private _state = createHashMapFromArray [
    ["unit", _unit], ["veh", _vehicle],
    ["class", [_vehicle] call tlbi_vehicle_fnc_lockClass],
    ["sel", 0], ["clip", -1],
    ["busy", false], ["done", false],
    ["last", diag_tickTime], ["deadUntil", 0],
    ["crank", 0], ["catchAt", -1], ["strain", 0], ["wobble", 0],
    ["hold_key", false], ["hold_mouse", false],
    ["parts", []]
];

uiNamespace setVariable ["tlbi_vehicle_state", _state];

if (!createDialog "tlbi_RscHotwireBoard") exitWith {
    uiNamespace setVariable ["tlbi_vehicle_state", createHashMap];
    false
};

private _display = uiNamespace getVariable ["tlbi_vehicle_display", displayNull];
if (isNull _display) exitWith { false };

// Board buttons: the first four and the danger button are clicks, the middle one
// is held for cranking and for forcing the steering lock, exactly like the
// lockpicking board.
{
    _x params ["_idc", "_action"];

    private _button = _display displayCtrl _idc;
    _button setVariable ["tlbi_action", _action];
    _button ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        [_ctrl getVariable ["tlbi_action", ""]] call tlbi_vehicle_fnc_hotwireAction;
    }];
} forEach [
    [IDC_HW_BTN_A1, "strip"],
    [IDC_HW_BTN_A3, "volts"],
    [IDC_HW_BTN_A4, "cont"],
    [IDC_HW_BTN_A5, "cut"]
];

private _hold = _display displayCtrl IDC_HW_BTN_A2;
_hold ctrlAddEventHandler ["MouseButtonDown", { ["hold", true, true] call tlbi_vehicle_fnc_hotwirePress }];
_hold ctrlAddEventHandler ["MouseButtonUp", { ["hold", false, true] call tlbi_vehicle_fnc_hotwirePress }];
_hold ctrlAddEventHandler ["MouseExit", { ["hold", false, true] call tlbi_vehicle_fnc_hotwirePress }];

(_display displayCtrl IDC_HW_BTN_CLOSE) ctrlAddEventHandler ["ButtonClick", {
    (uiNamespace getVariable ["tlbi_vehicle_display", displayNull]) closeDisplay 2;
}];

// Keys are the lockpicking bindings: the same key holds on both boards, and left
// and right step through the wires.
private _fnc_key = {
    params ["_key", ["_shift", false], ["_ctrl", false], ["_alt", false], ["_anyModifiers", false]];
    private _found = "";
    {
        _x params ["_input", "_action"];
        if ([_action, _key, _shift, _ctrl, _alt, _anyModifiers] call tlbi_defusal_fnc_keyMatches) exitWith { _found = _input };
    } forEach [["hold", "tlbi_lockpick_hold"], ["left", "tlbi_lockpick_left"], ["right", "tlbi_lockpick_right"]];
    _found
};
uiNamespace setVariable ["tlbi_vehicle_keyMap", _fnc_key];

_display displayAddEventHandler ["KeyDown", {
    params ["", "_key", "_shift", "_ctrl", "_alt"];
    private _input = [_key, _shift, _ctrl, _alt] call (uiNamespace getVariable ["tlbi_vehicle_keyMap", {""}]);
    if (_input == "") exitWith { false };
    [_input, true] call tlbi_vehicle_fnc_hotwirePress;
    true
}];

_display displayAddEventHandler ["KeyUp", {
    params ["", "_key"];
    private _input = [_key, false, false, false, true] call (uiNamespace getVariable ["tlbi_vehicle_keyMap", {""}]);
    if (_input == "") exitWith { false };
    [_input, false] call tlbi_vehicle_fnc_hotwirePress;
    true
}];

[] call tlbi_vehicle_fnc_hotwireRefresh;

[{ _this call tlbi_vehicle_fnc_hotwireTick }, 0, []] call CBA_fnc_addPerFrameHandler;

true
