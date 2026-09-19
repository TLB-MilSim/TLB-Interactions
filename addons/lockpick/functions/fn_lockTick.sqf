#include "..\script_component.hpp"
/*
 * Author: TLB
 * Rolls the locks of the buildings around the player, when tsp_breach is not
 * loaded to do it. Runs every three seconds from fn_postInit.
 *
 * This is the safety net, not the only place locks are decided: fn_doorHelpers
 * rolls the buildings around the door menu as it opens. The pass is still needed
 * because the lock variable is read by the building's own vanilla actions and by
 * ACE's door opening as well, and neither goes through our menu.
 *
 * The cost of a tick is the spatial query, so the query is what gets skipped. A
 * standing player pays a speed check and a distance check, and queries twice a
 * minute; a walking player queries once every 40 m. Keep the scan radius at
 * least 10 m above the movement gate, or a player can stop inside a ring of
 * buildings the last scan never covered.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 */

if !(missionNamespace getVariable ["tlbi_lockpick_doorActions", true]) exitWith {};

if (isNil "tlbi_lockpick_lockSeed" || {isNull player}) exitWith {};

if ((missionNamespace getVariable ["tlbi_lockpick_lockHouses", 0.25]) <= 0
    || {(missionNamespace getVariable ["tlbi_lockpick_lockDoors", 0.5]) <= 0}
) exitWith {};

// Faster than a sprint means no door is in reach. The gate below queries on the
// first tick after slowing down, and the door menu rolls as it opens, so leaving
// a vehicle never leaves a client with unrolled doors next to it.
if (speed (vehicle player) > 25) exitWith {};

private _pos = getPosATL player;
private _now = diag_tickTime;
(missionNamespace getVariable ["tlbi_lockpick_lastScan", [[], -1e9]]) params ["_lastPos", "_lastTime"];

// Query when the player has left the area the last one covered, and every 30
// seconds regardless, so buildings created during the mission are picked up too.
if (_lastPos isNotEqualTo []
    && {_pos distance2D _lastPos < 40}
    && {_now - _lastTime < 30}
) exitWith {};

missionNamespace setVariable ["tlbi_lockpick_lastScan", [_pos, _now]];

{
    [_x] call tlbi_lockpick_fnc_rollHouse;
} forEach nearestObjects [player, ["House"], 50];
