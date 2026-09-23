#include "..\script_component.hpp"
/*
 * Author: TLB
 * A vehicle's name for a message: whatever the mission called it, otherwise its
 * display name.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * Name <STRING>
 */

params ["_vehicle"];

if (isNull _vehicle) exitWith { "" };

private _name = _vehicle getVariable ["tlb_keys_name", ""];
if (_name != "") exitWith { _name };

getText (configOf _vehicle >> "displayName")
