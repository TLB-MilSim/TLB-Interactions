#include "..\script_component.hpp"
/*
 * Author: TLB
 * Whether a door is shut, by the building's own open condition when it has one.
 *
 * Buildings without a condition fall back to the vanilla door sound source,
 * which reads 0 while the door is shut. An unknown source also reads 0, so a
 * building that names its doors differently counts as shut, the way it did
 * before this check existed.
 *
 * Arguments:
 * 0: House <OBJECT>
 * 1: Door entry from fn_doors <ARRAY>
 *
 * Return Value:
 * Door is shut <BOOL>
 */

params ["_house", "_entry"];
_entry params ["_id", "", "", "_openCondition"];

if (_openCondition == "") exitWith {
    (_house animationSourcePhase format ["Door_%1_sound_source", _id]) < 0.5
};

[_house, _openCondition] call tlbi_lockpick_fnc_doorRun
