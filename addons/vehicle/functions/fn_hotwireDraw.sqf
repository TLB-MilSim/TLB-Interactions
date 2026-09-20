#include "..\script_component.hpp"
/*
 * Author: TLB
 * Renders what is under the steering column for the stage the job is at:
 *
 *   shroud   the plastic cover with its screws still in it
 *   wires    the ignition barrel, its loom, a tag per wire, copper where the
 *            sheath has been stripped, a gap where one has been cut, and the
 *            twist where two are joined
 *
 * Everything the player acts on gets an invisible hotspot over its texture, the
 * way the defusal board does it, and the whole board is redrawn whenever
 * something changes rather than animated: a screw coming out or a wire being
 * stripped is a step, not a movement.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 *
 * Return Value:
 * None
 */

params ["_display"];

private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];
if (count _state == 0) exitWith {};

private _vehicle = _state get "veh";
private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
if (count _harness <= HN_FRIED) exitWith {};

_harness params ["_wires", "_screws", "_stage", "", "", "_joined"];

// Whatever was drawn last time goes first.
{ ctrlDelete _x } forEach (_state getOrDefault ["parts", []]);
_state set ["parts", []];

private _parts = _state get "parts";
private _group = _display displayCtrl IDC_HW_BOARD;
(ctrlPosition _group) params ["", "", "_bw", "_bh"];

private _fnc_rect = {
    params ["_rx", "_ry", "_rw", "_rh"];
    [_rx * _bw, _ry * _bh, _rw * _bw, _rh * _bh]
};

private _fnc_picture = {
    params ["_texture", "_rx", "_ry", "_rw", "_rh", ["_tint", [1, 1, 1, 1]]];

    private _ctrl = _display ctrlCreate ["tlbi_RscPicture", -1, _group];
    _ctrl ctrlSetPosition ([_rx, _ry, _rw, _rh] call _fnc_rect);
    _ctrl ctrlSetText _texture;
    _ctrl ctrlSetTextColor _tint;
    _ctrl ctrlCommit 0;
    _parts pushBack _ctrl;
    _ctrl
};

private _fnc_fill = {
    params ["_rx", "_ry", "_rw", "_rh", "_colour"];

    private _ctrl = _display ctrlCreate ["tlbi_RscFill", -1, _group];
    _ctrl ctrlSetPosition ([_rx, _ry, _rw, _rh] call _fnc_rect);
    _ctrl ctrlSetBackgroundColor _colour;
    _ctrl ctrlCommit 0;
    _parts pushBack _ctrl;
    _ctrl
};

private _fnc_label = {
    params ["_text", "_rx", "_ry", "_rw", "_rh", ["_tint", [0.86, 0.88, 0.80, 1]]];

    private _ctrl = _display ctrlCreate ["tlbi_RscTextCenter", -1, _group];
    _ctrl ctrlSetPosition ([_rx, _ry, _rw, _rh] call _fnc_rect);
    _ctrl ctrlSetText _text;
    _ctrl ctrlSetTextColor _tint;
    _ctrl ctrlCommit 0;
    _parts pushBack _ctrl;
    _ctrl
};

private _fnc_hotspot = {
    params ["_rx", "_ry", "_rw", "_rh", "_action", "_index"];

    private _ctrl = _display ctrlCreate ["tlbi_RscHotspot", -1, _group];
    _ctrl ctrlSetPosition ([_rx, _ry, _rw, _rh] call _fnc_rect);
    _ctrl setVariable ["tlbi_action", _action];
    _ctrl setVariable ["tlbi_index", _index];
    _ctrl ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        [_ctrl getVariable ["tlbi_action", ""], _ctrl getVariable ["tlbi_index", -1]] call tlbi_vehicle_fnc_hotwireAction;
    }];
    _ctrl ctrlCommit 0;
    _parts pushBack _ctrl;
    _ctrl
};

// --- Under the dash ---------------------------------------------------------
[QPATHTOF(data\column_co.paa), 0, 0, 1, 1] call _fnc_picture;

if (_stage == HW_SHROUD) exitWith {
    [QPATHTOF(data\shroud_ca.paa), 0.06, 0.10, 0.88, 0.78] call _fnc_picture;

    // Screws around the shroud, in a fixed ring so a half-finished job reads the
    // same for the next player.
    private _spots = [[0.13, 0.17], [0.85, 0.17], [0.13, 0.76], [0.85, 0.76], [0.49, 0.83], [0.49, 0.09]];

    for "_i" from 0 to _screws - 1 do {
        (_spots select _i) params ["_sx", "_sy"];
        [QPATHTOF(data\screw_ca.paa), _sx - 0.028, _sy - 0.045, 0.056, 0.090] call _fnc_picture;
        [_sx - 0.040, _sy - 0.060, 0.080, 0.120, "screw", _i] call _fnc_hotspot;
    };

    _state set ["parts", _parts];
};

// --- The barrel and its loom ------------------------------------------------
[QPATHTOF(data\barrel_ca.paa), 0.02, 0.26, 0.20, 0.48] call _fnc_picture;

private _n = count _wires;
private _rowH = 0.62 / _n;
private _top = 0.16;
private _sel = _state getOrDefault ["sel", 0];
private _clip = _state getOrDefault ["clip", -1];
private _stripX = 0.58;

private _fnc_rowY = { _top + (_this + 0.5) * _rowH };

{
    _x params ["_role", "_colour", "_stripped", "_cut", "_volts", "_cont"];

    private _y = _forEachIndex call _fnc_rowY;
    private _tint = (tlbi_defusal_palette select _colour) select 0;
    // The cable sprite has headroom baked in, so it is drawn taller than the
    // wire looks. Must match _padFactor in the defusal board's fn_drawBoard.
    private _h = (_rowH * 1.5) min 0.24;

    if (_forEachIndex == _sel) then {
        [0.20, _y - _rowH * 0.46, 0.78, _rowH * 0.92, [0.80, 0.66, 0.30, 0.12]] call _fnc_fill;
    };

    // A cut wire is two stubs with a gap where the pliers went through.
    if (_cut) then {
        [QSHARED(cable_dp0_a.paa), 0.19, _y - _h / 2, 0.30, _h, _tint] call _fnc_picture;
        [QSHARED(cable_dp0_b.paa), 0.60, _y - _h / 2, 0.26, _h, _tint] call _fnc_picture;
    } else {
        [QSHARED(cable_dp0_a.paa), 0.19, _y - _h / 2, 0.67, _h, _tint] call _fnc_picture;
    };

    if (_stripped && {!_cut}) then {
        [QPATHTOF(data\strip_ca.paa), _stripX - 0.024, _y - _h * 0.13, 0.048, _h * 0.26] call _fnc_picture;
    };

    // The tag: its number, brighter while the crocodile clip is on it.
    private _tagTint = [[0.62, 0.60, 0.53, 1], [0.86, 0.80, 0.42, 1]] select (_forEachIndex == _clip);
    [QSHARED(tag_ca.paa), 0.875, _y - _rowH * 0.36, 0.105, _rowH * 0.72, _tagTint] call _fnc_picture;
    [str (_forEachIndex + 1), 0.875, _y - _rowH * 0.34, 0.105, _rowH * 0.68, [0.12, 0.12, 0.10, 1]] call _fnc_label;

    [0.19, _y - _rowH * 0.46, 0.79, _rowH * 0.92, "select", _forEachIndex] call _fnc_hotspot;
} forEach _wires;

// --- The twist --------------------------------------------------------------
if (count _joined == 2) then {
    _joined params ["_a", "_b"];
    private _ya = _a call _fnc_rowY;
    private _yb = _b call _fnc_rowY;

    [_stripX - 0.006, (_ya min _yb), 0.012, abs (_ya - _yb), [0.72, 0.52, 0.22, 1]] call _fnc_fill;
};

_state set ["parts", _parts];
