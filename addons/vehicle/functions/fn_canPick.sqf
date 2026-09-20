#include "..\script_component.hpp"
/*
 * Author: TLB
 * Whether this unit can start picking this vehicle's lock.
 *
 * The facts about the vehicle stay with whoever owns it: a vehicle TLB Keys or
 * a mission marked as not pickable, or one with ACE's lockpick strength set to
 * -1, is left alone however this mod is configured.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 *
 * Return Value:
 * Can pick <BOOL>
 */

params ["_unit", "_vehicle"];

if (!(call tlbi_vehicle_fnc_picking)) exitWith { false };

if (isNull _vehicle || {!alive _vehicle}) exitWith { false };
if (!((locked _vehicle) in [2, 3])) exitWith { false };

// Mission and Zeus intent, from whichever mod owns the vehicle.
if (!(_vehicle getVariable ["tlb_keys_pickable", true])) exitWith { false };
if (!(_vehicle getVariable ["tlbi_vehicle_pickable", true])) exitWith { false };
if ((_vehicle getVariable ["ace_vehiclelock_lockpickStrength", 0]) < 0) exitWith { false };

if (!isNull (uiNamespace getVariable ["tlbi_lockpick_display", displayNull])) exitWith { false };
if (!isNull (uiNamespace getVariable ["tlbi_vehicle_display", displayNull])) exitWith { false };

if (!isNull objectParent _unit) exitWith { false };
if (speed _vehicle > 1) exitWith { false };

if (([_unit] call tlbi_vehicle_fnc_pickTools) isEqualTo []) exitWith { false };

!([_unit, _vehicle] call tlbi_vehicle_fnc_hasAccess)
