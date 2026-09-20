#include "..\script_component.hpp"
/*
 * Author: TLB
 * The ways this unit can pick this vehicle's lock: one entry per tool it is
 * carrying, named after the item, exactly like the door menu.
 *
 * Built each time the interaction menu opens, so it only ever lists what the
 * player has on them right now.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Unit <OBJECT>
 *
 * Return Value:
 * ACE child actions <ARRAY>
 */

params ["_vehicle", "_unit"];

private _actions = [];

private _statement = {
    params ["_vehicle", "_unit", "_args"];
    _args params ["_tool", "_item"];
    [_unit, _vehicle, _tool, _item] call tlbi_vehicle_fnc_pick;
};

{
    _x params ["_tool", "_item"];

    _actions pushBack [
        [
            format ["TLBI_PickVehicle_%1", _tool],
            format [localize "STR_tlbi_vehicle_action_pickWith", getText (configFile >> "CfgWeapons" >> _item >> "displayName")],
            QPATHTOF(data\icon_pick_ca.paa),
            _statement, {true}, {}, [_tool, _item]
        ] call ace_interact_menu_fnc_createAction,
        [],
        _vehicle
    ];
} forEach ([_unit] call tlbi_vehicle_fnc_pickTools);

_actions
