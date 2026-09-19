#include "..\script_component.hpp"
/*
 * Author: TLB
 * Rolls the locks of one building, once. Called for the buildings near the
 * player by fn_lockTick, and for the buildings around the door menu by
 * fn_doorHelpers, so a door always has its lock decided before it can be used.
 *
 * The roll is deterministic: fn_roll hashes the mission seed, the building class
 * and position and the door number, so every client reaches the same locks
 * locally with no network traffic. A door that already has a lock value, from a
 * player, the mission or anything else, is never rolled over.
 *
 * Arguments:
 * 0: House <OBJECT>
 *
 * Return Value:
 * None
 */

params ["_house"];

if !(isNil {_house getVariable "tlbi_lockpick_rolled"}) exitWith {};
if !(missionNamespace getVariable ["tlbi_lockpick_doorActions", true]) exitWith {};

private _seed = missionNamespace getVariable "tlbi_lockpick_lockSeed";
if (isNil "_seed") exitWith {};

private _houseChance = missionNamespace getVariable ["tlbi_lockpick_lockHouses", 0.25];
private _doorChance = missionNamespace getVariable ["tlbi_lockpick_lockDoors", 0.5];

if (_houseChance <= 0 || {_doorChance <= 0}) exitWith {};

_house setVariable ["tlbi_lockpick_rolled", true];

private _type = toLower typeOf _house;

// Blacklist changes are rare compared to rolls, so the split list is cached and
// rebuilt only when the setting text changes.
private _raw = missionNamespace getVariable ["tlbi_lockpick_lockBlacklist", ""];
(missionNamespace getVariable ["tlbi_lockpick_blacklistCache", ["", []]]) params ["_cached", "_blacklist"];

if (_cached != _raw) then {
    _blacklist = (_raw splitString (", ;" + toString [9, 10, 13])) apply {toLower _x};
    missionNamespace setVariable ["tlbi_lockpick_blacklistCache", [_raw, _blacklist]];
};

private _listed = (_blacklist findIf {
    if ((_x select [count _x - 1]) == "*") then {
        (_type find (_x select [0, count _x - 1])) == 0
    } else {
        _x == _type
    }
}) != -1;

if (_listed) exitWith {};

private _doors = [_house] call tlbi_lockpick_fnc_doors;
if (_doors isEqualTo []) exitWith {};

private _where = (getPosWorld _house) apply {round _x};

if (([_seed, _type, _where] call tlbi_lockpick_fnc_roll) >= _houseChance) exitWith {};

{
    private _entry = _x;
    _entry params ["_id", "_door"];
    private _variable = format ["bis_disabled_Door_%1", _id];

    // The closed check is last: it only runs for doors that are about to be
    // locked, and it keeps a door someone already opened from ending up locked.
    if (isNil {_house getVariable _variable}
        && {(toLower _door find "glass") == -1}
        && {([_seed, _type, _where, _id] call tlbi_lockpick_fnc_roll) < _doorChance}
        && {[_house, _entry] call tlbi_lockpick_fnc_isClosed}
    ) then {
        _house setVariable [_variable, 1];
    };
} forEach _doors;
