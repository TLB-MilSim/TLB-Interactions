#include "..\script_component.hpp"
/*
 * Author: TLB
 * Whether this unit can hotwire the vehicle it is sitting in.
 *
 * Sitting in the driver's seat of something you cannot start is where hotwiring
 * belongs: the doors are already open, so there is no lock left to pick. A
 * vehicle qualifies when it has an ignition lock at all, which means someone
 * broke into it or it is still locked, or, with TLB Keys loaded, that it has
 * keys and none of them are yours.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 *
 * Return Value:
 * Can hotwire <BOOL>
 */

params ["_unit", "_vehicle"];

if (!(call tlbi_vehicle_fnc_owns)) exitWith { false };
if (!tlbi_vehicle_hotwire || {!tlbi_vehicle_ignitionLock}) exitWith { false };

if (isNull _vehicle || {!alive _vehicle} || {objectParent _unit != _vehicle}) exitWith { false };
if (driver _vehicle != _unit) exitWith { false };
if (!isNull (uiNamespace getVariable ["tlbi_vehicle_display", displayNull])) exitWith { false };
if (!isNull (uiNamespace getVariable ["tlbi_lockpick_display", displayNull])) exitWith { false };

if ([_vehicle] call tlbi_vehicle_fnc_hotwired) exitWith { false };
if ([_unit, _vehicle] call tlbi_vehicle_fnc_hasAccess) exitWith { false };

// Armour and aircraft have an immobiliser rather than a key barrel. Whether one
// can be hotwired at all is a setting; a vehicle the mission marked is final.
if (!(_vehicle getVariable ["tlbi_vehicle_hotwirable", true])) exitWith { false };
if (!tlbi_vehicle_armoured && {([_vehicle] call tlbi_vehicle_fnc_lockClass) == VEH_ARMOURED}) exitWith { false };

// A harness somebody shorted out too many times needs time to be worth trying
// again.
private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
if (count _harness > HN_FRIED && {CBA_missionTime < (_harness select HN_FRIED)}) exitWith { false };

// Something to work with: a lock pick kit, a paperclip or a toolkit.
if (!([_unit] call tlbi_vehicle_fnc_hasTool)) exitWith { false };

(locked _vehicle) in [2, 3]
    || {_vehicle getVariable ["tlbi_vehicle_brokenInto", false]}
    || {(_vehicle getVariable ["tlb_keys_mode", -1]) != -1}
