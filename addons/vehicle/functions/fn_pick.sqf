#include "..\script_component.hpp"
/*
 * Author: TLB
 * Sends a vehicle's lock to the lockpicking board.
 *
 * The board is built for doors: it reads the lock's position from a building's
 * selection and walks away when the player leaves it. A vehicle's centre can be
 * further off than that, so an invisible local helipad at the player's feet
 * stands in as the "building", and is deleted when the board closes. The lock
 * itself belongs to the vehicle, which is what the board is told to remember the
 * rolled technique on, so backing off and trying again cannot re-roll an easier
 * lock.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 * 2: TOOL_KIT or TOOL_CLIP <NUMBER>
 * 3: Item used <STRING>
 *
 * Return Value:
 * Board opened <BOOL>
 */

params ["_unit", "_vehicle", "_tool", "_item"];

if (!([_unit, _vehicle] call tlbi_vehicle_fnc_canPick)) exitWith { false };

private _helper = "Land_HelipadEmpty_F" createVehicleLocal [0, 0, 0];
_helper setPosASL getPosASL _unit;

private _opened = [
    _unit, _helper, "tlbi_vehicle_lock", _tool, _item,
    {
        params ["_vehicle", "_unit"];
        [_vehicle, _unit] call tlbi_vehicle_fnc_picked;
    },
    [_vehicle, _unit],
    [_vehicle] call tlbi_vehicle_fnc_lockClass,
    _vehicle
] call tlbi_lockpick_fnc_start;

if (!_opened) exitWith {
    deleteVehicle _helper;
    false
};

[
    { isNull (uiNamespace getVariable ["tlbi_lockpick_display", displayNull]) },
    { deleteVehicle _this },
    _helper
] call CBA_fnc_waitUntilAndExecute;

true
