#include "..\script_component.hpp"
/*
 * Author: TLB
 * Puts the door interactions in the world when the ACE interaction menu opens,
 * used only when tsp_breach is not loaded.
 *
 * Doors are selections on a building, not objects, so ACE cannot hang actions
 * on them directly. Each door handle within reach gets an invisible local
 * ACE_LogicDummy with a "Door" menu. The previous set is removed first, so there
 * are only ever as many helpers as doors next to the player.
 *
 * The buildings found here are also rolled for locks (fn_rollHouse), which costs
 * nothing extra because they have already been looked up.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 */

{ deleteVehicle _x } forEach (missionNamespace getVariable ["tlbi_lockpick_helpers", []]);
tlbi_lockpick_helpers = [];

if !(missionNamespace getVariable ["tlbi_lockpick_doorActions", true]) exitWith {};

private _unit = ACE_player;
private _eye = eyePos _unit;

private _fnc_statement = {
    params ["", "_player", "_args"];
    [_player, _args, false] call tlbi_lockpick_fnc_doorAction;
};

private _fnc_condition = {
    params ["", "_player", "_args"];
    [_player, _args, true] call tlbi_lockpick_fnc_doorAction
};

private _children = [
    ["open", localize "STR_tlbi_lockpick_door_open", "\a3\ui_f\data\igui\cfg\actions\open_door_ca.paa"],
    ["close", localize "STR_tlbi_lockpick_door_close", ""],
    ["unlock", localize "STR_tlbi_lockpick_door_unlock", ""],
    ["lock", localize "STR_tlbi_lockpick_door_lock", ""],
    ["pickKit", localize "STR_tlbi_lockpick_action_kit", "\z\ace\addons\vehiclelock\ui\lockpick.paa"],
    ["pickClip", localize "STR_tlbi_lockpick_action_clip", "\z\ace\addons\vehiclelock\ui\lockpick.paa"]
];

{
    private _house = _x;

    // Decide this building's locks before its menu is built, so a door in reach
    // is always rolled even if the background pass has not covered it yet.
    [_house] call tlbi_lockpick_fnc_rollHouse;

    {
        private _entry = _x;
        _entry params ["_id", "_door", "_point"];

        private _relative = [0, 0, 0];
        if (_point != "") then { _relative = _house selectionPosition [_point, "Memory"] };
        if (_relative isEqualTo [0, 0, 0]) then { _relative = _house selectionPosition [_door, "Geometry", "AveragePoint"] };

        if !(_relative isEqualTo [0, 0, 0]) then {
            private _position = _house modelToWorldWorld _relative;

            if (_position vectorDistance _eye < 4) then {
                private _helper = "ACE_LogicDummy" createVehicleLocal [0, 0, 0];
                _helper setPosASL _position;
                tlbi_lockpick_helpers pushBack _helper;

                private _root = [
                    "TLBI_Door", localize "STR_tlbi_lockpick_door", "\a3\ui_f\data\igui\cfg\actions\open_door_ca.paa",
                    {}, {true}, {}, [], [0, 0, 0], 2.5
                ] call ace_interact_menu_fnc_createAction;
                [_helper, 0, [], _root] call ace_interact_menu_fnc_addActionToObject;

                {
                    _x params ["_name", "_label", "_icon"];

                    private _action = [
                        "TLBI_Door_" + _name, _label, _icon,
                        _fnc_statement, _fnc_condition, {}, [_house, _entry, _name]
                    ] call ace_interact_menu_fnc_createAction;

                    [_helper, 0, ["TLBI_Door"], _action] call ace_interact_menu_fnc_addActionToObject;
                } forEach _children;
            };
        };
    } forEach ([_house] call tlbi_lockpick_fnc_doors);
} forEach nearestObjects [_unit, ["House"], 25];
