#include "..\script_component.hpp"
/*
 * Author: TLB
 * Whether this mod is the one that picks vehicle locks right now, which is what
 * the menu entry and ACE's own fall-back entry are switched on.
 *
 * Three ways it is not: the addon is off, the lockpicking board is off, or
 * "Pick vehicle locks" is off. The last one hands vehicles to TLB Keys when that
 * is loaded, and leaves ACE's own progress bar in place when it is not, so there
 * is never a stretch with no way to pick a vehicle lock at all.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * This mod picks vehicle locks <BOOL>
 */

if (!(call tlbi_vehicle_fnc_owns)) exitWith { false };

(missionNamespace getVariable ["tlbi_lockpick_vehicles", true])
    && {missionNamespace getVariable ["tlbi_lockpick_enabled", true]}
