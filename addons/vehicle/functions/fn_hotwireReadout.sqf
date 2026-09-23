#include "..\script_component.hpp"
/*
 * Author: TLB
 * Writes the meter's reading on the LCD.
 *
 * Arguments:
 * 0: Reading <STRING>
 *
 * Return Value:
 * None
 */

params ["_text"];

private _display = uiNamespace getVariable ["tlbi_vehicle_display", displayNull];

if (isNull _display) exitWith {};

(_display displayCtrl IDC_HW_READOUT) ctrlSetText _text;
