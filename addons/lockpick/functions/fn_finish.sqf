#include "..\script_component.hpp"
/*
 * Author: TLB
 * The lock is open. Runs the unlock that opened the board (tsp_breach's or our
 * own bis_disabled_Door_N write), then closes the board after a beat so the
 * final click and the turned plug are seen.
 *
 * Return Value:
 * None
 */

private _state = uiNamespace getVariable ["tlbi_lockpick_state", createHashMap];

if (count _state == 0 || {_state getOrDefault ["done", false]}) exitWith {};

_state set ["done", true];

// The technique stays on the door until it is picked, so the same lock does not
// re-roll on every attempt. It is open now, so clear it.
private _owner = _state getOrDefault ["owner", _state get "house"];
{
    _owner setVariable [format ["tlbi_lockpick_tech_%1_%2", _state get "door", _x], nil, true];
} forEach [TOOL_KIT, TOOL_CLIP];

(_state get "unlockArgs") call (_state get "unlock");

playSound "ACE_Sound_Click";
[localize "STR_tlbi_lockpick_status_open"] call tlbi_lockpick_fnc_setStatus;
[localize "STR_tlbi_lockpick_msg_open"] call ace_common_fnc_displayTextStructured;

[{
    (uiNamespace getVariable ["tlbi_lockpick_display", displayNull]) closeDisplay 1;
}, [], 0.7] call CBA_fnc_waitAndExecute;
