#include "..\script_component.hpp"
/*
 * Author: TLB
 * One action on the hotwire board, from a tool plate or from clicking a part.
 *
 *   screw    unscrew one screw; with the last one out the shroud comes off
 *   select   pick a wire to work on
 *   strip    strip the sheath off the selected wire, then twist it onto the wire
 *            the clip is already on
 *   volts    is it live: only the battery feed is, until the ignition is joined
 *   cont     where does it go: the coil, the solenoid, the lamps, or nowhere
 *   cut      cut the selected wire
 *
 * The meter is what the job is really about. Voltage finds the battery feed and
 * nothing else; continuity finds the coil and the solenoid, and an alarm feed
 * reads exactly like a lamp feed, so a service vehicle punishes guessing.
 *
 * Arguments:
 * 0: Action <STRING>
 * 1: Index, for the parts that have one <NUMBER> (default: -1)
 *
 * Return Value:
 * None
 */

params ["_action", ["_index", -1]];

private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];
if (count _state == 0 || {_state getOrDefault ["done", false]} || {_state getOrDefault ["busy", false]}) exitWith {};

private _vehicle = _state get "veh";
private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
if (count _harness <= HN_FRIED) exitWith {};

_harness params ["_wires", "_screws", "_stage", "", "", "_joined"];

private _time = tlbi_vehicle_actionTime max 0.5;

// --- Selecting --------------------------------------------------------------
if (_action == "select") exitWith {
    if (_index < 0 || {_index >= count _wires}) exitWith {};
    _state set ["sel", _index];
    [] call tlbi_vehicle_fnc_hotwireRefresh;
};

// --- The shroud -------------------------------------------------------------
if (_action == "screw") exitWith {
    if (_stage != HW_SHROUD) exitWith {};

    [_time, localize "STR_tlbi_vehicle_act_unscrew", {
        private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];
        if (count _state == 0) exitWith {};

        private _vehicle = _state get "veh";
        private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
        if (count _harness <= HN_FRIED) exitWith {};

        _harness set [HN_SCREWS, ((_harness select HN_SCREWS) - 1) max 0];

        if ((_harness select HN_SCREWS) == 0) then {
            _harness set [HN_STAGE, HW_WIRES];
            [localize "STR_tlbi_vehicle_msg_shroudOff"] call tlbi_vehicle_fnc_hotwireStatus;
        };

        _vehicle setVariable ["tlbi_vehicle_harness", _harness, true];
        playSound "ACE_Sound_Click";
    }] call tlbi_vehicle_fnc_hotwireRun;
};

if (_stage != HW_WIRES) exitWith {};

private _sel = _state getOrDefault ["sel", 0];
if (_sel < 0 || {_sel >= count _wires}) exitWith {};

private _wire = _wires select _sel;
_wire params ["_role", "_colour", "_stripped", "_cut"];

// --- Stripping and twisting -------------------------------------------------
if (_action == "strip") exitWith {
    if (_cut) exitWith {};

    if (!_stripped) exitWith {
        [_time * 0.6, localize "STR_tlbi_vehicle_act_strip", {
            private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];
            if (count _state == 0) exitWith {};

            private _vehicle = _state get "veh";
            private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
            if (count _harness <= HN_FRIED) exitWith {};

            ((_harness select HN_WIRES) select (_state get "sel")) set [WR_STRIPPED, true];
            _vehicle setVariable ["tlbi_vehicle_harness", _harness, true];
        }] call tlbi_vehicle_fnc_hotwireRun;
    };

    // Bare copper: the clip goes on, or the two ends twist together.
    private _clip = _state getOrDefault ["clip", -1];

    if (_clip < 0) exitWith {
        _state set ["clip", _sel];
        [] call tlbi_vehicle_fnc_hotwireRefresh;
    };

    if (_clip == _sel) exitWith {
        _state set ["clip", -1];
        [] call tlbi_vehicle_fnc_hotwireRefresh;
    };

    if (CBA_missionTime < (_state getOrDefault ["deadUntil", 0])) exitWith {
        [localize "STR_tlbi_vehicle_msg_fuseDead"] call tlbi_vehicle_fnc_hotwireStatus;
    };

    [_time * 0.8, localize "STR_tlbi_vehicle_act_twist", {
        [] call tlbi_vehicle_fnc_hotwireJoin;
    }] call tlbi_vehicle_fnc_hotwireRun;
};

// --- The meter --------------------------------------------------------------
if (_action in ["volts", "cont"]) exitWith {
    if (!_stripped || {_cut}) exitWith {
        [localize "STR_tlbi_vehicle_msg_sheathed"] call tlbi_vehicle_fnc_hotwireStatus;
    };

    private _volts = _action == "volts";
    _state set ["meterVolts", _volts];

    [_time * 0.5, localize (["STR_tlbi_vehicle_act_cont", "STR_tlbi_vehicle_act_volts"] select _volts), {
        private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];
        if (count _state == 0) exitWith {};

        private _vehicle = _state get "veh";
        private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
        if (count _harness <= HN_FRIED) exitWith {};

        private _sel = _state get "sel";
        private _wire = (_harness select HN_WIRES) select _sel;
        private _role = _wire select WR_ROLE;
        private _volts = _state get "meterVolts";
        private _joined = _harness select HN_JOINED;
        private _text = "";

        if (_volts) then {
            // The battery feed is live; the ignition feed is live too once it is
            // joined to it.
            private _live = _role == ROLE_BATTERY
                || {_role == ROLE_IGNITION && {_sel in _joined}};

            _wire set [WR_VOLTS, [0, 12] select _live];
            _text = format [localize "STR_tlbi_vehicle_read_volts", _sel + 1, ["0.0", "12.4"] select _live];
        } else {
            private _cont = switch (_role) do {
                case ROLE_IGNITION: { CONT_COIL };
                case ROLE_STARTER: { CONT_SOLENOID };
                case ROLE_IMMOBILISER: { CONT_NONE };
                case ROLE_BATTERY: { CONT_NONE };
                default { CONT_LAMPS };
            };

            _wire set [WR_CONT, _cont];
            _text = format [
                localize "STR_tlbi_vehicle_read_cont",
                _sel + 1,
                localize ([
                    "STR_tlbi_vehicle_cont_none",
                    "STR_tlbi_vehicle_cont_coil",
                    "STR_tlbi_vehicle_cont_solenoid",
                    "STR_tlbi_vehicle_cont_lamps"
                ] select _cont)
            ];
        };

        _vehicle setVariable ["tlbi_vehicle_harness", _harness, true];
        [_text] call tlbi_vehicle_fnc_hotwireReadout;
    }] call tlbi_vehicle_fnc_hotwireRun;
};

// --- Cutting ----------------------------------------------------------------
if (_action == "cut") exitWith {
    if (_cut) exitWith {};

    [_time * 0.5, localize "STR_tlbi_vehicle_act_cut", {
        private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];
        if (count _state == 0) exitWith {};

        private _vehicle = _state get "veh";
        private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
        if (count _harness <= HN_FRIED) exitWith {};

        private _sel = _state get "sel";
        private _wire = (_harness select HN_WIRES) select _sel;
        _wire set [WR_CUT, true];

        // A cut wire is out of the loom, so anything it was part of falls apart.
        if (_sel in (_harness select HN_JOINED)) then {
            _harness set [HN_JOINED, []];
            _harness set [HN_STAGE, HW_WIRES];
        };

        if ((_state getOrDefault ["clip", -1]) == _sel) then { _state set ["clip", -1] };

        _vehicle setVariable ["tlbi_vehicle_harness", _harness, true];

        switch (_wire select WR_ROLE) do {
            // The whole point of finding the alarm feed first.
            case ROLE_ALARM: {
                [localize "STR_tlbi_vehicle_msg_cutAlarm"] call tlbi_vehicle_fnc_hotwireStatus;
            };
            case ROLE_IMMOBILISER: {
                [localize "STR_tlbi_vehicle_msg_cutImmobiliser"] call tlbi_vehicle_fnc_hotwireStatus;
            };
            case ROLE_DECOY: {
                [localize "STR_tlbi_vehicle_msg_cutDecoy"] call tlbi_vehicle_fnc_hotwireStatus;
            };
            // Cutting one of the three that matter ends the job on this harness.
            default {
                [localize "STR_tlbi_vehicle_msg_cutFeed", true] call tlbi_vehicle_fnc_short;
            };
        };
    }] call tlbi_vehicle_fnc_hotwireRun;
};
