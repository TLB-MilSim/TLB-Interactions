#include "..\script_component.hpp"
/*
 * Author: TLB
 * Whether a unit has this vehicle legitimately, which is the one question this
 * addon has to ask somebody else.
 *
 * Who holds a key is not ours to decide: with TLB Keys loaded its key system
 * answers, and without it ACE's vehicle keys do. Everything else about picking
 * and hotwiring is decided here.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 *
 * Return Value:
 * The unit may use this vehicle without breaking in <BOOL>
 */

params ["_unit", "_vehicle"];

if (isNull _unit || {isNull _vehicle}) exitWith { false };

if (!isNil "tlb_keys_core_fnc_getAccess") exitWith {
    ([_unit, _vehicle] call tlb_keys_core_fnc_getAccess) > 0
};

[_unit, _vehicle] call ace_vehiclelock_fnc_hasKeyForVehicle
