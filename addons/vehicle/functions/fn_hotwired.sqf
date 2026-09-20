#include "..\script_component.hpp"
/*
 * Author: TLB
 * Reads or sets "this vehicle runs without its key".
 *
 * TLB Keys keeps the same fact in tlb_keys_hotwired and its own ignition lock
 * reads it, so both variables are written and either one counts. That way the
 * two mods can never disagree about a vehicle, whichever of them started it.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Set it, instead of reading it <BOOL> (optional)
 *
 * Return Value:
 * Vehicle runs without its key <BOOL>
 */

params ["_vehicle", "_set"];

if (isNull _vehicle) exitWith { false };

if (!isNil "_set") then {
    _vehicle setVariable ["tlbi_vehicle_hotwired", _set, true];
    _vehicle setVariable ["tlb_keys_hotwired", _set, true];
};

(_vehicle getVariable ["tlbi_vehicle_hotwired", false])
    || {_vehicle getVariable ["tlb_keys_hotwired", false]}
