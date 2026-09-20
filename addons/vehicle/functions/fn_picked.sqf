#include "..\script_component.hpp"
/*
 * Author: TLB
 * A vehicle lock was picked: unlock it, and mark that it was broken into.
 *
 * With the ignition lock on, opening the door is not the same as driving away:
 * the vehicle still has to be hotwired from the driver's seat. With it off,
 * picking the lock is enough, which is how TLB Keys behaves on its own.
 *
 * Raises tlbi_vehicle_picked [vehicle, unit] on every machine, and
 * tlb_keys_vehiclePicked as well when TLB Keys is loaded, so anything listening
 * to either mod keeps working.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Unit <OBJECT>
 *
 * Return Value:
 * None
 */

params ["_vehicle", "_unit"];

if (isNull _vehicle || {!alive _vehicle}) exitWith {};

// lock only takes effect where the vehicle is local.
if (local _vehicle) then {
    _vehicle lock 0;
} else {
    ["tlbi_vehicle_setLock", [_vehicle, false], _vehicle] call CBA_fnc_targetEvent;
};

_vehicle setVariable ["tlbi_vehicle_brokenInto", true, true];

if (!tlbi_vehicle_ignitionLock) then {
    [_vehicle, true] call tlbi_vehicle_fnc_hotwired;
};

["tlbi_vehicle_picked", [_vehicle, _unit]] call CBA_fnc_globalEvent;
if (!isNil "tlb_keys_core_fnc_picked") then {
    ["tlb_keys_vehiclePicked", [_vehicle, _unit]] call CBA_fnc_globalEvent;
};

playSound "ACE_Sound_Click";

private _message = [
    "STR_tlbi_vehicle_msg_picked",
    "STR_tlbi_vehicle_msg_pickedIgnition"
] select (tlbi_vehicle_ignitionLock && {tlbi_vehicle_hotwire});

[format [localize _message, [_vehicle] call tlbi_vehicle_fnc_vehicleName]] call ace_common_fnc_displayTextStructured;
