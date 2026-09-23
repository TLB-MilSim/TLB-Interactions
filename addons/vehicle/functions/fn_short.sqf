#include "..\script_component.hpp"
/*
 * Author: TLB
 * Something went to earth: a wrong pair twisted together, the alarm feed
 * shorted, or one of the three wires that matter cut through.
 *
 * A short blows a fuse. Whatever was joined falls apart and the loom is dead for
 * a few seconds, which is long enough to be caught. Past the allowed number of
 * shorts, or straight away when the damage is fatal, the harness is finished: it
 * is replaced, which means new wires in a new order, and nobody can work on this
 * vehicle until the replacement is in.
 *
 * Arguments:
 * 0: Reason message <STRING>
 * 1: Fatal on its own <BOOL> (default: false)
 *
 * Return Value:
 * None
 */

params ["_reason", ["_fatal", false]];

private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];
if (count _state == 0) exitWith {};

private _vehicle = _state get "veh";
private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
if (count _harness <= HN_FRIED) exitWith {};

private _shorts = (_harness select HN_SHORTS) + 1;

_harness set [HN_SHORTS, _shorts];
_harness set [HN_JOINED, []];
if ((_harness select HN_STAGE) > HW_WIRES) then { _harness set [HN_STAGE, HW_WIRES] };

_state set ["clip", -1];

playSound "ACE_Sound_Click_10db";

if (_fatal || {_shorts > round tlbi_vehicle_shorts}) exitWith {
    _state set ["done", true];

    // A replacement harness: new wires, in a new order, and not before time.
    _vehicle setVariable ["tlbi_vehicle_harness", nil, true];
    private _fresh = [_vehicle] call tlbi_vehicle_fnc_harness;
    _fresh set [HN_FRIED, CBA_missionTime + (tlbi_vehicle_friedTime max 0)];
    _vehicle setVariable ["tlbi_vehicle_harness", _fresh, true];

    [format ["%1 %2", _reason, localize "STR_tlbi_vehicle_msg_fried"]] call ace_common_fnc_displayTextStructured;
    (uiNamespace getVariable ["tlbi_vehicle_display", displayNull]) closeDisplay 2;
};

_vehicle setVariable ["tlbi_vehicle_harness", _harness, true];
_state set ["deadUntil", CBA_missionTime + 6];

[format [
    "%1 %2",
    _reason,
    format [localize "STR_tlbi_vehicle_msg_fuse", _shorts, (round tlbi_vehicle_shorts) + 1]
]] call tlbi_vehicle_fnc_hotwireStatus;
