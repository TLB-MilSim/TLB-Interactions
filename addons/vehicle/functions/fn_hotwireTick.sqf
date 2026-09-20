#include "..\script_component.hpp"
/*
 * Author: TLB
 * Per-frame logic for the hotwire board. One per-frame handler per board; it
 * removes itself when the board closes.
 *
 * CRANK     Hold the starter wire on the live pair. The engine turns over, and
 *           after a moment it catches: let go then and it runs. Keep holding and
 *           the starter grinds against a running engine, which costs a cool-down
 *           and a good deal of noise.
 *
 * STEERING  The barrel is live but the steering lock is not: hold the wheel over
 *           until the lock shears. The bar creeps rather than climbs, and lets go
 *           of whatever it gained when you do.
 *
 * Arguments:
 * 0: PFH arguments <ARRAY> (unused)
 * 1: PFH id <NUMBER>
 *
 * Return Value:
 * None
 */

params ["", "_pfhID"];

#define STEER_FORCE 2.5
#define CATCH_WINDOW 0.8
#define GRIND_COOL 3

private _display = uiNamespace getVariable ["tlbi_vehicle_display", displayNull];
private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];

if (isNull _display || {count _state == 0}) exitWith { _pfhID call CBA_fnc_removePerFrameHandler };

private _now = diag_tickTime;
private _dt = ((_now - (_state get "last")) min 0.1) max 0;
_state set ["last", _now];

private _unit = _state get "unit";
private _vehicle = _state get "veh";

if (!alive _unit || {!alive _vehicle} || {objectParent _unit != _vehicle}) exitWith {
    _pfhID call CBA_fnc_removePerFrameHandler;
    _display closeDisplay 2;
};

if (_state getOrDefault ["done", false] || {_state getOrDefault ["busy", false]}) exitWith {};

private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
if (count _harness <= HN_FRIED) exitWith {};

private _stage = _harness select HN_STAGE;
private _hold = (_state getOrDefault ["hold_key", false]) || {_state getOrDefault ["hold_mouse", false]};

// --- Cranking ---------------------------------------------------------------
if (_stage == HW_CRANK) exitWith {
    private _cool = _state getOrDefault ["coolUntil", 0];

    if (CBA_missionTime < _cool) exitWith {
        [format [localize "STR_tlbi_vehicle_read_cool", ceil (_cool - CBA_missionTime)]] call tlbi_vehicle_fnc_hotwireReadout;
    };

    private _crank = _state getOrDefault ["crank", 0];
    private _catchAt = _state getOrDefault ["catchAt", -1];
    private _needs = tlbi_vehicle_crankTime max 0.4;

    if (!_hold) exitWith {
        // Let go after it caught and it runs; let go early and it dies again.
        if (_catchAt >= 0) exitWith {
            _state set ["crank", 0];
            _state set ["catchAt", -1];
            [] call tlbi_vehicle_fnc_hotwireFinish;
        };

        if (_crank > 0) then {
            _state set ["crank", (_crank - _dt * 2) max 0];
            [localize "STR_tlbi_vehicle_read_idle"] call tlbi_vehicle_fnc_hotwireReadout;
        };
    };

    if (_catchAt >= 0) exitWith {
        if (_now - _catchAt > CATCH_WINDOW) exitWith {
            _state set ["crank", 0];
            _state set ["catchAt", -1];
            _state set ["coolUntil", CBA_missionTime + GRIND_COOL];

            playSound "ACE_Sound_Click_10db";
            [localize "STR_tlbi_vehicle_msg_grind"] call tlbi_vehicle_fnc_hotwireStatus;
        };

        [localize "STR_tlbi_vehicle_read_catch"] call tlbi_vehicle_fnc_hotwireReadout;
    };

    _crank = _crank + _dt;
    _state set ["crank", _crank];

    if (_crank >= _needs) then {
        _state set ["catchAt", _now];
        [localize "STR_tlbi_vehicle_read_catch"] call tlbi_vehicle_fnc_hotwireReadout;
    } else {
        [format [localize "STR_tlbi_vehicle_read_crank", round (100 * _crank / _needs)]] call tlbi_vehicle_fnc_hotwireReadout;
    };
};

// --- The steering lock ------------------------------------------------------
if (_stage == HW_STEERING) exitWith {
    private _strain = _state getOrDefault ["strain", 0];

    if (!_hold) exitWith {
        if (_strain > 0) then {
            _state set ["strain", (_strain - _dt * 1.5) max 0];
            [format [localize "STR_tlbi_vehicle_read_lock", round (100 * (_state get "strain") / STEER_FORCE)]] call tlbi_vehicle_fnc_hotwireReadout;
        };
    };

    // The wheel gives a little unevenly, so the bar is never quite steady.
    _strain = _strain + _dt * (0.75 + random 0.5);
    _state set ["strain", _strain];

    if (_strain < STEER_FORCE) exitWith {
        [format [localize "STR_tlbi_vehicle_read_lock", round (100 * _strain / STEER_FORCE)]] call tlbi_vehicle_fnc_hotwireReadout;
    };

    _harness set [HN_STEER, true];
    _harness set [HN_STAGE, HW_CRANK];
    _vehicle setVariable ["tlbi_vehicle_harness", _harness, true];
    _state set ["strain", 0];

    playSound "ACE_Sound_Click";
    [localize "STR_tlbi_vehicle_msg_sheared"] call tlbi_vehicle_fnc_hotwireStatus;
    [] call tlbi_vehicle_fnc_hotwireRefresh;
};
