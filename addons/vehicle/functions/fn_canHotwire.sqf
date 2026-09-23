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
 * Every way out writes its reason to the RPT, once per change, the same way
 * fn_canPick does.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 *
 * Return Value:
 * Can hotwire <BOOL>
 */

params ["_unit", "_vehicle"];

private _fnc_no = {
    if ((missionNamespace getVariable ["tlbi_vehicle_lastHotwireReason", ""]) != _this) then {
        missionNamespace setVariable ["tlbi_vehicle_lastHotwireReason", _this];
        diag_log text format ["[TLB Interactions] hotwire unavailable: %1", _this];
    };
    false
};

if (!(call tlbi_vehicle_fnc_owns)) exitWith { "this mod does not own vehicles" call _fnc_no };
if (!tlbi_vehicle_hotwire) exitWith { "hotwiring is off" call _fnc_no };
if (!tlbi_vehicle_ignitionLock) exitWith { "the ignition lock is off, so nothing needs hotwiring" call _fnc_no };

if (isNull _vehicle || {!alive _vehicle} || {objectParent _unit != _vehicle}) exitWith { "not in a vehicle" call _fnc_no };
if (driver _vehicle != _unit) exitWith { "not in the driver's seat" call _fnc_no };
if (!isNull (uiNamespace getVariable ["tlbi_vehicle_display", displayNull])) exitWith { "a board is already open" call _fnc_no };
if (!isNull (uiNamespace getVariable ["tlbi_lockpick_display", displayNull])) exitWith { "a board is already open" call _fnc_no };

if ([_vehicle] call tlbi_vehicle_fnc_hotwired) exitWith { "it is already hotwired" call _fnc_no };
if ([_unit, _vehicle] call tlbi_vehicle_fnc_hasAccess) exitWith { "the player holds a key for it" call _fnc_no };

// Armour and aircraft have an immobiliser rather than a key barrel. Whether one
// can be hotwired at all is a setting; a vehicle the mission marked is final.
if (!(_vehicle getVariable ["tlbi_vehicle_hotwirable", true])) exitWith { "marked as not hotwirable" call _fnc_no };
if (!tlbi_vehicle_armoured && {([_vehicle] call tlbi_vehicle_fnc_lockClass) == VEH_ARMOURED}) exitWith {
    "armour cannot be hotwired with the current setting" call _fnc_no
};

// A harness somebody shorted out too many times needs time to be worth trying
// again.
private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
if (count _harness > HN_FRIED && {CBA_missionTime < (_harness select HN_FRIED)}) exitWith {
    format ["the harness is being replaced, %1 s left", ceil ((_harness select HN_FRIED) - CBA_missionTime)] call _fnc_no
};

// Something to work with: a lock pick kit, a paperclip or a toolkit.
if (!([_unit] call tlbi_vehicle_fnc_hasTool)) exitWith {
    format ["no tool: carrying %1", _unit call ace_common_fnc_uniqueItems] call _fnc_no
};

// Lock state 3, "locked for players", is the mission keeping this vehicle away
// from players rather than a lock without a key, so it is left alone.
if ((locked _vehicle) == 3) exitWith { "locked for players by the mission" call _fnc_no };

private _needs = (locked _vehicle) == 2
    || {_vehicle getVariable ["tlbi_vehicle_brokenInto", false]}
    || {(_vehicle getVariable ["tlb_keys_mode", -1]) != -1};

if (!_needs) exitWith {
    format [
        "it starts without a key anyway (lock %1, broken into %2, TLB Keys mode %3)",
        locked _vehicle,
        _vehicle getVariable ["tlbi_vehicle_brokenInto", false],
        _vehicle getVariable ["tlb_keys_mode", -1]
    ] call _fnc_no
};

missionNamespace setVariable ["tlbi_vehicle_lastHotwireReason", ""];

true
