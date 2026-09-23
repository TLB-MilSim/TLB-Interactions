#include "..\script_component.hpp"
/*
 * Author: TLB
 * It caught. The vehicle runs without its key from now on, until someone with a
 * key locks it again, which is how a picked lock behaves in TLB Keys as well.
 *
 * Raises tlbi_vehicle_hotwired [vehicle, unit] on every machine, and
 * tlb_keys_vehicleHotwired too when TLB Keys is loaded.
 *
 * Return Value:
 * None
 */

private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];

if (count _state == 0 || {_state getOrDefault ["done", false]}) exitWith {};

_state set ["done", true];

private _unit = _state get "unit";
private _vehicle = _state get "veh";

private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
if (count _harness > HN_FRIED) then {
    _harness set [HN_STAGE, HW_DONE];
    _vehicle setVariable ["tlbi_vehicle_harness", _harness, true];
};

[_vehicle, true] call tlbi_vehicle_fnc_hotwired;

if (local _vehicle) then {
    _vehicle engineOn true;
} else {
    ["tlbi_vehicle_engineOn", [_vehicle], _vehicle] call CBA_fnc_targetEvent;
};

["tlbi_vehicle_hotwired", [_vehicle, _unit]] call CBA_fnc_globalEvent;
if (!isNil "tlb_keys_core_fnc_hotwire") then {
    ["tlb_keys_vehicleHotwired", [_vehicle, _unit]] call CBA_fnc_globalEvent;
};

playSound "ACE_Sound_Click";
[localize "STR_tlbi_vehicle_msg_running"] call tlbi_vehicle_fnc_hotwireStatus;
[format [localize "STR_tlbi_vehicle_msg_hotwired", [_vehicle] call tlbi_vehicle_fnc_vehicleName]] call ace_common_fnc_displayTextStructured;

[{
    (uiNamespace getVariable ["tlbi_vehicle_display", displayNull]) closeDisplay 1;
}, [], 0.9] call CBA_fnc_waitAndExecute;
