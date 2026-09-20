#include "..\script_component.hpp"
/*
 * Author: TLB
 * Shows a message to one player, wherever they are. The ignition lock runs where
 * the vehicle is local, which is not always where its driver is.
 *
 * Arguments:
 * 0: Message <STRING>
 * 1: Unit <OBJECT> (default: the local player)
 *
 * Return Value:
 * None
 */

params ["_text", ["_unit", objNull]];

if (isNull _unit) then { _unit = ACE_player };
if (isNull _unit) exitWith {};

if (_unit == ACE_player) exitWith {
    [_text] call ace_common_fnc_displayTextStructured;
};

["tlbi_vehicle_notify", [_text], _unit] call CBA_fnc_targetEvent;
