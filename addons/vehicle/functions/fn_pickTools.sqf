#include "..\script_component.hpp"
/*
 * Author: TLB
 * What this unit could pick a vehicle lock with: the same tools the door menu
 * accepts, plus TLB Keys' own kit for anyone carrying one.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * [[TOOL_KIT or TOOL_CLIP, item class], ...] <ARRAY>
 */

params ["_unit"];

private _tools = [];

{
    private _tool = _x;
    private _item = [_unit, _tool] call tlbi_lockpick_fnc_hasTool;

    if (_item == "" && {_tool == TOOL_KIT} && {"tlb_keys_lockpick" in (_unit call ace_common_fnc_uniqueItems)}) then {
        _item = "tlb_keys_lockpick";
    };

    if (_item != "") then { _tools pushBack [_tool, _item] };
} forEach [TOOL_KIT, TOOL_CLIP];

_tools
