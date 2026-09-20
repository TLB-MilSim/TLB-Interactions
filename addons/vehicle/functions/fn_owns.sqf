#include "..\script_component.hpp"
/*
 * Author: TLB
 * Whether this mod is the one in charge of vehicle picking and hotwiring.
 *
 * With TLB Keys loaded, the switch is the lockpicking setting "Pick vehicle
 * locks": on, this mod takes it over completely, board, difficulty, hotwiring
 * and ignition lock; off, TLB Keys keeps its own system and settings and nothing
 * here runs. Without TLB Keys there is nobody to hand it to, so only this mod's
 * own settings decide.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * This mod owns vehicles <BOOL>
 */

if (!tlbi_vehicle_enabled) exitWith { false };

if (!isNil "tlb_keys_core_fnc_pick"
    && {!(missionNamespace getVariable ["tlbi_lockpick_vehicles", true])}
) exitWith { false };

true
