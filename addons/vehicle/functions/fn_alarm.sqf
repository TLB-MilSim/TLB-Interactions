#include "..\script_component.hpp"
/*
 * Author: TLB
 * The alarm feed was shorted: the horn goes off where the vehicle is, for
 * everyone, which is the whole reason to find that wire before guessing.
 *
 * Raises tlbi_vehicle_alarmed [vehicle] on every machine, so a mission can send
 * a patrol instead of, or as well as, making a noise.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * None
 */

params ["_vehicle"];

if (isNull _vehicle) exitWith {};

["tlbi_vehicle_alarmed", [_vehicle]] call CBA_fnc_globalEvent;

["tlbi_vehicle_alarmSound", [_vehicle]] call CBA_fnc_globalEvent;
