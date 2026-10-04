#include "..\script_component.hpp"
/*
 * Author: TLB
 * Auto-clear (setting): starts the next piece of clearing work on its own, so
 * the player watches the device come out instead of clicking every clump.
 *
 *   IED       brushes the next soil clump, both passes
 *   mine      digs the next cell of the rim - never the plate - which exposes
 *             the fuze once all eight are out; prodding is not needed
 *   tripwire  parts the next tuft of grass lying over the wire
 *
 * Each step is an ordinary timed action at the Clearing speed. fn_refreshBoard
 * queues this after every refresh, and the action's own refresh queues the next
 * step, so it runs until the clearing stage is done. The tape, the meter, pins
 * and cuts stay with the player.
 *
 * Return Value:
 * None
 */

// Set per board by fn_openBoard: the setting, or an Explosive settings module.
if !(uiNamespace getVariable ["tlbi_defusal_autoClearNow", false]) exitWith {};
if (isNull (uiNamespace getVariable ["tlbi_defusal_display", displayNull])) exitWith {};
if (uiNamespace getVariable ["tlbi_defusal_busy", false]) exitWith {};
if (uiNamespace getVariable ["tlbi_defusal_resolved", false]) exitWith {};

// Hybrid mode FINISH waits for the board to be free; more clearing would keep it
// waiting.
if ((uiNamespace getVariable ["tlbi_defusal_display", displayNull]) getVariable ["tlbi_hybrid_pending", false]) exitWith {};

private _explosive = uiNamespace getVariable ["tlbi_defusal_explosive", objNull];

if (isNull _explosive) exitWith {};

switch (uiNamespace getVariable ["tlbi_defusal_kind", KIND_IED]) do {
    case KIND_IED: {
        private _puzzle = _explosive getVariable ["tlbi_defusal_puzzle", []];
        if (count _puzzle <= PZ_TAPE || {(_puzzle select PZ_STAGE) != STAGE_EXCAVATE}) exitWith {};

        private _index = (_puzzle select PZ_DIRT) findIf {(_x select DT_HP) > 0};
        if (_index != -1) then { [_index] call tlbi_defusal_fnc_brushDirt };
    };

    case KIND_MINE: {
        private _mine = _explosive getVariable ["tlbi_defusal_mine", []];
        if (count _mine <= MN_AT || {(_mine select MN_STAGE) != MSTAGE_LOCATE}) exitWith {};

        _mine params ["_cols", "", "_cx", "_cy", "_dug"];

        // The eight rim cells, clockwise from top left.
        private _rim = [[-1, -1], [0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0]] apply {
            (_cy + (_x select 1)) * _cols + _cx + (_x select 0)
        };

        private _next = _rim findIf {(_dug select _x) == 0};
        if (_next != -1) then {
            uiNamespace setVariable ["tlbi_defusal_tool", TOOL_DIG];
            [_rim select _next] call tlbi_defusal_fnc_mineCell;
        };
    };

    case KIND_TRIP: {
        private _trip = _explosive getVariable ["tlbi_defusal_trip", []];
        if (count _trip <= TR_SLIPS || {(_trip select TR_STAGE) != TSTAGE_TRACE}) exitWith {};

        private _index = (_trip select TR_TUFTS) findIf {(_x select TF_ONPATH) && {!(_x select TF_CLEARED)}};
        if (_index != -1) then { [_index] call tlbi_defusal_fnc_tripTuft };
    };
};
