#include "..\script_component.hpp"
/*
 * Author: TLB
 * Runs a timed action on the hotwire board: locks the plates, drives the
 * progress bar across the LCD and then fires the callback.
 *
 * Like the defusal board, the callback does not depend on the display still being
 * open. Once the pliers close on a wire the outcome is decided, so closing the
 * board is not a way out of a short.
 *
 * Arguments:
 * 0: Duration in seconds <NUMBER>
 * 1: Label <STRING>
 * 2: On finish <CODE>
 *
 * Return Value:
 * None
 */

params ["_duration", "_label", "_onFinish"];

private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];
if (count _state == 0) exitWith {};

_state set ["busy", true];

private _display = uiNamespace getVariable ["tlbi_vehicle_display", displayNull];
private _px = 0;
private _pw = 0;

if (!isNull _display) then {
    {
        (_display displayCtrl _x) ctrlEnable false
    } forEach [IDC_HW_BTN_A1, IDC_HW_BTN_A2, IDC_HW_BTN_A3, IDC_HW_BTN_A4, IDC_HW_BTN_A5];

    { (_display displayCtrl _x) ctrlShow true } forEach [IDC_HW_PROG_FRAME, IDC_HW_PROG_BAR, IDC_HW_PROG_TEXT];
    { (_display displayCtrl _x) ctrlShow false } forEach [IDC_HW_READOUT];

    (_display displayCtrl IDC_HW_PROG_TEXT) ctrlSetText _label;

    (ctrlPosition (_display displayCtrl IDC_HW_PROG_FRAME)) params ["_fx", "", "_fw"];
    _px = _fx;
    _pw = _fw;
};

[{
    params ["_args", "_pfhID"];
    _args params ["_start", "_duration", "_onFinish", "_px", "_pw"];

    private _display = uiNamespace getVariable ["tlbi_vehicle_display", displayNull];
    private _progress = ((diag_tickTime - _start) / _duration) min 1;

    if (!isNull _display) then {
        private _bar = _display displayCtrl IDC_HW_PROG_BAR;
        (ctrlPosition _bar) params ["", "_by", "", "_bh"];
        _bar ctrlSetPosition [_px + 3 * pixelW, _by, (_pw - 6 * pixelW) * _progress, _bh];
        _bar ctrlCommit 0;
    };

    if (_progress < 1) exitWith {};

    _pfhID call CBA_fnc_removePerFrameHandler;

    private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];
    if (count _state > 0) then { _state set ["busy", false] };

    if (!isNull _display) then {
        { (_display displayCtrl _x) ctrlShow false } forEach [IDC_HW_PROG_FRAME, IDC_HW_PROG_BAR, IDC_HW_PROG_TEXT];
        { (_display displayCtrl _x) ctrlShow true } forEach [IDC_HW_READOUT];
    };

    call _onFinish;

    // After the callback, so a stage change or a fresh reading is already on the
    // board when the plates come back.
    [] call tlbi_vehicle_fnc_hotwireRefresh;
}, 0, [diag_tickTime, _duration max 0.1, _onFinish, _px, _pw]] call CBA_fnc_addPerFrameHandler;
