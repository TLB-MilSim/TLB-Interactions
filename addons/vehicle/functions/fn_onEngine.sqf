#include "..\script_component.hpp"
/*
 * Author: TLB
 * Ignition lock: a player cannot start a vehicle that was broken into, or one
 * that is still locked, until it is hotwired. With TLB Keys loaded, a vehicle
 * with keys needs one of them or a hotwire, which is the same rule its own
 * ignition lock uses.
 *
 * Runs from the Engine event on every machine, and acts where the vehicle is
 * local. AI drivers are left to the mission.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Engine on <BOOL>
 *
 * Return Value:
 * None
 */

params ["_vehicle", "_engineOn"];

if (!_engineOn || {!local _vehicle}) exitWith {};
if (!call tlbi_vehicle_fnc_owns || {!tlbi_vehicle_ignitionLock}) exitWith {};
if ([_vehicle] call tlbi_vehicle_fnc_hotwired) exitWith {};

private _needs = (locked _vehicle) in [2, 3]
    || {_vehicle getVariable ["tlbi_vehicle_brokenInto", false]}
    || {(_vehicle getVariable ["tlb_keys_mode", -1]) != -1};

if (!_needs) exitWith {};

private _driver = currentPilot _vehicle;
if (isNull _driver) then { _driver = driver _vehicle };

if (isNull _driver || {!isPlayer _driver}) exitWith {};
if ([_driver, _vehicle] call tlbi_vehicle_fnc_hasAccess) exitWith {};

_vehicle engineOn false;

[
    format [localize "STR_tlbi_vehicle_msg_ignition", [_vehicle] call tlbi_vehicle_fnc_vehicleName],
    _driver
] call tlbi_vehicle_fnc_notify;
