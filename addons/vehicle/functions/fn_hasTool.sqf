#include "..\script_component.hpp"
/*
 * Author: TLB
 * Whether a unit is carrying something to hotwire with, by the "Hotwiring needs"
 * setting: nothing at all, any lock pick kit, paperclip or toolkit, or a toolkit
 * only.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Has what it takes <BOOL>
 */

params ["_unit"];

if (tlbi_vehicle_tools == HWTOOL_NONE) exitWith { true };

private _items = _unit call ace_common_fnc_uniqueItems;

if ("ToolKit" in _items) exitWith { true };
if (tlbi_vehicle_tools == HWTOOL_KIT) exitWith { false };

([_unit, TOOL_KIT] call tlbi_lockpick_fnc_hasTool) != ""
    || {([_unit, TOOL_CLIP] call tlbi_lockpick_fnc_hasTool) != ""}
    || {"tlb_keys_lockpick" in _items}
