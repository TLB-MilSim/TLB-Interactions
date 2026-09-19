#include "..\script_component.hpp"
/*
 * Author: TLB
 * One door interaction, as its ACE condition or its statement.
 *
 *   open / close   the building's own UserActions, so the door moves (and a
 *                  locked vanilla door rattles) the way the building intends
 *   unlock / lock  by hand, only from inside and only with the door shut
 *   pickKit/Clip   a locked, shut door from outside, with the tool: the board
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: [house, door entry from fn_doors, action name] <ARRAY>
 * 2: Evaluate the condition (true) or run the statement (false) <BOOL>
 *
 * Return Value:
 * Condition result when checking <BOOL>, otherwise nothing
 */

params ["_unit", "_args", "_check"];
_args params ["_house", "_entry", "_name"];
_entry params ["_id", "_door", "", "_openCondition", "_openStatement", "_closeCondition", "_closeStatement"];

private _lockVar = format ["bis_disabled_Door_%1", _id];
private _locked = (_house getVariable [_lockVar, 0]) == 1;

private _closed = [_house, _entry] call tlbi_lockpick_fnc_isClosed;

private _tool = [TOOL_KIT, TOOL_CLIP] select (_name == "pickClip");

if (_check) exitWith {
    switch (_name) do {
        case "open": { _closed && {_openStatement != ""} };
        case "close": {
            if (_closeStatement != "") then {
                if (_closeCondition == "") then { !_closed } else { [_house, _closeCondition] call tlbi_lockpick_fnc_doorRun }
            } else {
                !_closed && {_openStatement != ""}
            }
        };
        case "unlock": { _locked && {_closed} && {[_unit, _house] call tlbi_lockpick_fnc_isInside} };
        case "lock": { !_locked && {_closed} && {[_unit, _house] call tlbi_lockpick_fnc_isInside} };
        case "pickKit";
        case "pickClip": {
            (missionNamespace getVariable ["tlbi_lockpick_enabled", true])
            && {_locked}
            && {_closed}
            && {isNull (uiNamespace getVariable ["tlbi_lockpick_display", displayNull])}
            && {([_unit, _tool] call tlbi_lockpick_fnc_hasTool) != ""}
            && {!([_unit, _house] call tlbi_lockpick_fnc_isInside)}
        };
        default { false };
    }
};

switch (_name) do {
    case "open": {
        if (_locked) then {
            [localize "STR_tlbi_lockpick_msg_locked"] call ace_common_fnc_displayTextStructured;
        };
        // Run it either way: a vanilla door checks its own lock and rattles.
        [_house, _openStatement] call tlbi_lockpick_fnc_doorRun;
    };
    case "close": {
        [_house, [_openStatement, _closeStatement] select (_closeStatement != "")] call tlbi_lockpick_fnc_doorRun;
    };
    case "unlock": {
        [_house, _door, _id] call tlbi_lockpick_fnc_unlock;
        playSound "ACE_Sound_Click";
        [localize "STR_tlbi_lockpick_msg_unlocked"] call ace_common_fnc_displayTextStructured;
    };
    case "lock": {
        _house setVariable [_lockVar, 1, true];
        _house setVariable [format ["bis_disabled_%1", _door], 1, true];
        playSound "ACE_Sound_Click";
        [localize "STR_tlbi_lockpick_msg_lockedByHand"] call ace_common_fnc_displayTextStructured;
    };
    case "pickKit";
    case "pickClip": {
        [
            _unit, _house, _door, _tool,
            [_unit, _tool] call tlbi_lockpick_fnc_hasTool,
            tlbi_lockpick_fnc_unlock,
            [_house, _door, _id]
        ] call tlbi_lockpick_fnc_start;
    };
};
