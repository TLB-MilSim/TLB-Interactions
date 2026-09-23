#include "..\script_component.hpp"
/*
 * Author: TLB
 * Whether this unit can start picking this vehicle's lock.
 *
 * The facts about the vehicle stay with whoever owns it: a vehicle TLB Keys or
 * a mission marked as not pickable, or one with ACE's lockpick strength set to
 * -1, is left alone however this mod is configured.
 *
 * Every way out writes its reason to the RPT, once per change, because an action
 * that hides itself looks exactly like an action that was never added.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 *
 * Return Value:
 * Can pick <BOOL>
 */

params ["_unit", "_vehicle"];

private _fnc_no = {
    if ((missionNamespace getVariable ["tlbi_vehicle_lastReason", ""]) != _this) then {
        missionNamespace setVariable ["tlbi_vehicle_lastReason", _this];
        diag_log text format ["[TLB Interactions] pick unavailable: %1", _this];
    };
    false
};

if (!(call tlbi_vehicle_fnc_picking)) exitWith {
    format [
        "this mod does not own picking (vehicles enabled %1, pick vehicle locks %2, lockpicking %3, TLB Keys loaded %4)",
        tlbi_vehicle_enabled,
        missionNamespace getVariable ["tlbi_lockpick_vehicles", true],
        missionNamespace getVariable ["tlbi_lockpick_enabled", true],
        !isNil "tlb_keys_core_fnc_pick"
    ] call _fnc_no
};

if (isNull _vehicle || {!alive _vehicle}) exitWith { "no vehicle" call _fnc_no };
// Lock state 3 is "locked for players": the mission is saying this vehicle is
// not for them, which is not a lock to be picked.
if ((locked _vehicle) == 3) exitWith { "locked for players by the mission" call _fnc_no };
if ((locked _vehicle) != 2) exitWith { format ["not locked (lock state %1)", locked _vehicle] call _fnc_no };

// Mission and Zeus intent, from whichever mod owns the vehicle.
if (!(_vehicle getVariable ["tlb_keys_pickable", true])) exitWith { "TLB Keys says not pickable" call _fnc_no };
if (!(_vehicle getVariable ["tlbi_vehicle_pickable", true])) exitWith { "marked not pickable" call _fnc_no };
if ((_vehicle getVariable ["ace_vehiclelock_lockpickStrength", 0]) < 0) exitWith { "lockpick strength is -1" call _fnc_no };

if (!isNull (uiNamespace getVariable ["tlbi_lockpick_display", displayNull])) exitWith { "a board is already open" call _fnc_no };
if (!isNull (uiNamespace getVariable ["tlbi_vehicle_display", displayNull])) exitWith { "a board is already open" call _fnc_no };

if (!isNull objectParent _unit) exitWith { "the player is in a vehicle" call _fnc_no };
if (speed _vehicle > 1) exitWith { "the vehicle is moving" call _fnc_no };

if (([_unit] call tlbi_vehicle_fnc_pickTools) isEqualTo []) exitWith {
    format ["no tool: carrying %1", _unit call ace_common_fnc_uniqueItems] call _fnc_no
};

if ([_unit, _vehicle] call tlbi_vehicle_fnc_hasAccess) exitWith { "the player holds a key for it" call _fnc_no };

missionNamespace setVariable ["tlbi_vehicle_lastReason", ""];

true
