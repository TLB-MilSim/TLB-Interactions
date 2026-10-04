#include "..\script_component.hpp"
/*
 * Author: TLB
 * Hybrid mode: runs the progress bar a board replaces underneath the board.
 *
 * The bar is a strip under the case, on the same columns as the tool plates:
 * the stock bar's label and the time left across the first three, and a FINISH
 * plate under the fourth. The board stays fully playable. Finishing it by hand
 * closes it as usual and takes the strip with it; once the bar is full, FINISH
 * completes the job the way the stock bar would have.
 *
 * FINISH never cuts a committed action short. While the board reports itself
 * busy - a cut, a reading or a twist already under way - the press is held
 * until that action has resolved, so a wrong cut cannot be escaped by finishing
 * over it. If the action fires the device or burns out the harness, the board
 * closes and nothing is finished.
 *
 * Like the stock bar it only runs while the board is open: backing away cancels
 * it, and the next board starts it again from empty.
 *
 * Shared by every board, which is why it lives in this addon: the lockpicking
 * and vehicle addons already build on its control styles.
 *
 * Arguments:
 * 0: Board display <DISPLAY>
 * 1: Bar time in seconds, before the Bar time multiplier setting <NUMBER>
 * 2: Label <STRING>
 * 3: Busy check - true while an action on the board is still resolving <CODE>
 * 4: On finish <CODE>
 *
 * Return Value:
 * None
 */

params ["_display", "_duration", "_label", "_fnc_busy", "_onFinish"];

if (isNull _display) exitWith {};

_duration = (_duration * (tlbi_hybrid_timeScale max 0.05)) max 0.5;

private _fnc_create = {
    params ["_class", "_rx", "_ry", "_rw", "_rh"];

    private _ctrl = _display ctrlCreate [_class, -1];
    _ctrl ctrlSetPosition [_rx * safeZoneW + safeZoneX, _ry * safeZoneH + safeZoneY, _rw * safeZoneW, _rh * safeZoneH];
    _ctrl ctrlCommit 0;
    _ctrl
};

// Same look as the progress bar a timed action draws over the LCD, so it reads
// as the same kind of thing: a dark well, an amber fill, light text.
private _back = ["tlbi_RscFill", 0.170, 0.828, 0.660, 0.066] call _fnc_create;
_back ctrlSetBackgroundColor [0.09, 0.09, 0.07, 0.96];

private _frame = ["tlbi_RscFill", 0.195, 0.839, 0.451, 0.044] call _fnc_create;
_frame ctrlSetBackgroundColor [0.02, 0.02, 0.015, 0.92];

(ctrlPosition _frame) params ["_fx", "_fy", "_fw", "_fh"];

private _fill = _display ctrlCreate ["tlbi_RscFill", -1];
_fill ctrlSetBackgroundColor [0.62, 0.50, 0.20, 1];
_fill ctrlSetPosition [_fx + 3 * pixelW, _fy + 3 * pixelH, 0, _fh - 6 * pixelH];
_fill ctrlCommit 0;

private _text = ["tlbi_RscTextCenter", 0.195, 0.839, 0.451, 0.044] call _fnc_create;
_text ctrlSetFont "PuristaMedium";
_text ctrlSetFontHeight (0.026 * safeZoneH);
_text ctrlSetTextColor [0.94, 0.92, 0.84, 1];

private _plate = ["tlbi_RscPicture", 0.655, 0.839, 0.150, 0.044] call _fnc_create;
_plate ctrlSetText QPATHTOF(data\plate_co.paa);
_plate ctrlSetTextColor [0.48, 0.50, 0.44, 1];

private _button = ["tlbi_RscToolButton", 0.655, 0.839, 0.150, 0.044] call _fnc_create;
_button ctrlSetText localize "STR_tlbi_hybrid_btn_finish";
_button ctrlEnable false;

_display setVariable ["tlbi_hybrid_ready", false];
_display setVariable ["tlbi_hybrid_pending", false];

// The press only asks for the finish; the handler below carries it out once the
// board is free.
_button ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];

    private _display = ctrlParent _ctrl;
    if !(_display getVariable ["tlbi_hybrid_ready", false]) exitWith {};

    _display setVariable ["tlbi_hybrid_pending", true];
    _ctrl ctrlEnable false;
}];

[{
    params ["_args", "_pfhID"];
    _args params ["_display", "_start", "_duration", "_label", "_fnc_busy", "_onFinish", "_ctrls"];
    _ctrls params ["_fill", "_text", "_plate", "_button", "_fx", "_fw"];

    if (isNull _display) exitWith { _pfhID call CBA_fnc_removePerFrameHandler };

    // Game time, like ACE's own progress bar.
    private _progress = ((CBA_missionTime - _start) / _duration) min 1;

    (ctrlPosition _fill) params ["", "_by", "", "_bh"];
    _fill ctrlSetPosition [_fx + 3 * pixelW, _by, (_fw - 6 * pixelW) * _progress, _bh];
    _fill ctrlCommit 0;

    if (_display getVariable ["tlbi_hybrid_pending", false]) exitWith {
        if (call _fnc_busy) exitWith {
            _text ctrlSetText localize "STR_tlbi_hybrid_bar_pending";
        };

        _pfhID call CBA_fnc_removePerFrameHandler;
        call _onFinish;
    };

    if (_progress < 1) exitWith {
        private _left = ceil (_duration * (1 - _progress));
        _text ctrlSetText format ["%1  %2:%3", _label, floor (_left / 60), [_left % 60, 2] call CBA_fnc_formatNumber];
    };

    if (_display getVariable ["tlbi_hybrid_ready", false]) exitWith {};

    _display setVariable ["tlbi_hybrid_ready", true];
    _text ctrlSetText localize "STR_tlbi_hybrid_bar_ready";
    _plate ctrlSetTextColor [0.80, 0.66, 0.30, 1];
    _button ctrlEnable true;
}, 0, [
    _display, CBA_missionTime, _duration, _label, _fnc_busy, _onFinish,
    [_fill, _text, _plate, _button, _fx, _fw]
]] call CBA_fnc_addPerFrameHandler;
