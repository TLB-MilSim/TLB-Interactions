#include "..\script_component.hpp"
// TLB Interactions - Vehicles: hook into the vehicle lock actions and the
// ignition. Runs via CfgFunctions postInit.
//
// ACE's own Lockpick action is swapped for ours the same way the defusal action
// is: added first, so the engine compiles the class's config menu, then ACE's
// entry is removed. Ours lists one entry per tool the player carries and opens
// the lockpicking board. The swap runs per vehicle class as each one first turns
// up in the mission (fn_hookClass), because that is when ACE builds its menu
// from config.
//
// When this mod is not the one in charge, which is TLB Keys loaded with "Pick
// vehicle locks" off, the replacement falls back to ACE's own progress bar
// instead. That way the swap is harmless whatever the settings do later, and
// there is never a stretch with no way to pick a lock at all.

diag_log text "[TLB Interactions] vehicle postInit";

// --- Doing things where the vehicle is local -----------------------------------
["tlbi_vehicle_setLock", {
    params ["_vehicle", "_locked"];
    if (local _vehicle) then { _vehicle lock ([0, 2] select _locked) };
}] call CBA_fnc_addEventHandler;

["tlbi_vehicle_engineOn", {
    params ["_vehicle"];
    if (local _vehicle) then { _vehicle engineOn true };
}] call CBA_fnc_addEventHandler;

["tlbi_vehicle_notify", {
    params ["_text"];
    [_text] call ace_common_fnc_displayTextStructured;
}] call CBA_fnc_addEventHandler;

// The horn, heard by everyone near the vehicle. Vanilla's alarm is used when it
// is there, and a click is better than silence when it is not.
["tlbi_vehicle_alarmSound", {
    params ["_vehicle"];
    if (isNull _vehicle || {!hasInterface}) exitWith {};

    if (isClass (configFile >> "CfgSounds" >> "Alarm")) then {
        _vehicle say3D ["Alarm", 250];
    } else {
        playSound "ACE_Sound_Click_10db";
    };
}] call CBA_fnc_addEventHandler;

// --- The ignition lock, wherever the vehicle is local -------------------------
{
    [_x, "Engine", { _this call tlbi_vehicle_fnc_onEngine }, true, ["StaticWeapon"]] call CBA_fnc_addClassEventHandler;
} forEach ["LandVehicle", "Air", "Ship"];

if (!hasInterface) exitWith {};

// --- The menu ----------------------------------------------------------------
private _classes = ["Car", "Tank", "Motorcycle", "Helicopter", "Plane", "Ship_F"];

private _pick = [
    "TLBI_PickVehicle", localize "STR_tlbi_vehicle_action_pick", "\z\ace\addons\vehiclelock\ui\lockpick.paa",
    {},
    { [_player, _target] call tlbi_vehicle_fnc_canPick },
    { [_target, _player] call tlbi_vehicle_fnc_pickActions },
    [], [0, 0, 0], 4
] call ace_interact_menu_fnc_createAction;

// ACE's own picking, for when TLB Keys owns vehicles instead of this mod.
private _pickAce = [
    "TLBI_PickVehicleAce", localize "STR_ACE_VehicleLock_Action_Lockpick", "\z\ace\addons\vehiclelock\ui\lockpick.paa",
    { [_player, _target, "startLockpick"] call ace_vehiclelock_fnc_lockpick },
    {
        !(call tlbi_vehicle_fnc_picking)
        && {[_player, _target, "canLockpick"] call ace_vehiclelock_fnc_lockpick}
    },
    {}, [], [0, 0, 0], 4
] call ace_interact_menu_fnc_createAction;

private _hotwire = [
    "TLBI_Hotwire", localize "STR_tlbi_vehicle_action_hotwire", QPATHTOF(data\hotwire_ca.paa),
    { [_player, _target] call tlbi_vehicle_fnc_hotwireStart },
    { [_player, _target] call tlbi_vehicle_fnc_canHotwire },
    {}, [], [0, 0, 0], 4
] call ace_interact_menu_fnc_createAction;

tlbi_vehicle_actions = [_pick, _pickAce, _hotwire];

// ACE builds a class's menu the first time an object of it exists, so the swap
// runs then too, once per class. Retroactive, so vehicles already in the mission
// are covered.
{
    [_x, "InitPost", {
        [typeOf (_this select 0)] call tlbi_vehicle_fnc_hookClass;
    }, true, ["StaticWeapon"], true] call CBA_fnc_addClassEventHandler;
} forEach _classes;

diag_log text format ["[TLB Interactions] vehicle actions hooked on %1 base classes", count _classes];
