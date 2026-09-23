#include "..\script_component.hpp"
/*
 * Author: TLB
 * One input event on the hotwire board, from a key or from the held plate.
 *
 *            plate 2 / Space        left / A        right / D
 *   wires    -                      previous wire   next wire
 *   crank    hold to crank          previous wire   next wire
 *   steering hold to force the lock  -              -
 *
 * Keys and the plate keep separate hold flags, so letting go of one never
 * cancels the other, exactly as on the lockpicking board.
 *
 * Arguments:
 * 0: Input - "hold", "left" or "right" <STRING>
 * 1: Pressed (true) or released (false) <BOOL>
 * 2: From the plate rather than a key <BOOL> (default: false)
 *
 * Return Value:
 * None
 */

params ["_input", "_down", ["_mouse", false]];

private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];

if (count _state == 0 || {_state getOrDefault ["done", false]}) exitWith {};

if (_input == "hold") exitWith {
    _state set [["hold_key", "hold_mouse"] select _mouse, _down];
};

if (!_down || {_state getOrDefault ["busy", false]}) exitWith {};

private _vehicle = _state get "veh";
private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
if (count _harness <= HN_FRIED) exitWith {};

private _n = count (_harness select HN_WIRES);
if (_n == 0 || {(_harness select HN_STAGE) == HW_SHROUD}) exitWith {};

private _step = [-1, 1] select (_input == "right");
_state set ["sel", (((_state getOrDefault ["sel", 0]) + _step) + _n) % _n];

[] call tlbi_vehicle_fnc_hotwireRefresh;
