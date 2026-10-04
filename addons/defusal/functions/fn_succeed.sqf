#include "..\script_component.hpp"
/*
 * Author: TLB
 * The firing line is cut. Clears the puzzle and hands the device back to ACE so
 * it is picked up, logged and broadcast exactly as a vanilla ACE defusal would
 * be - anything hooked into ace_explosives_defuse keeps working.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Explosive <OBJECT>
 * 2: Finished on the hybrid mode bar rather than the board <BOOL> (default: false)
 *
 * Return Value:
 * None
 */

params ["_unit", "_explosive", ["_stock", false]];

uiNamespace setVariable ["tlbi_defusal_resolved", true];

{
    _explosive setVariable [_x, nil, true];
} forEach ["tlbi_defusal_puzzle", "tlbi_defusal_mine", "tlbi_defusal_trip", "tlbi_defusal_elapsed"];

(uiNamespace getVariable ["tlbi_defusal_display", displayNull]) closeDisplay 1;

if (_stock || {tlbi_defusal_respectAceExplodeOnDefuse}) exitWith {
    // Let ACE roll its own explode-on-defuse chance, for groups that want the
    // stock risk on top of the minigame - and always when the job was finished
    // on the hybrid mode bar, which is ACE's bar and carries ACE's risk.
    [_unit, _explosive] call ace_explosives_fnc_defuseExplosive;
};

// Same work ACE's defuseExplosive does, minus the chance roll: the player
// earned this one by reading the board.
_unit action ["Deactivate", _unit, _explosive];

["ace_explosives_defuse", [_explosive, _unit]] call CBA_fnc_globalEvent;

[localize ([
    "STR_tlbi_defusal_msg_defused",
    "STR_tlbi_defusal_mine_msg_safe",
    "STR_tlbi_defusal_trip_msg_safe"
] select (uiNamespace getVariable ["tlbi_defusal_kind", KIND_IED]))] call ace_common_fnc_displayTextStructured;
