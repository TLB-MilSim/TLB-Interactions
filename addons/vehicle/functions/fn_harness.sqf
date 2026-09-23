#include "..\script_component.hpp"
/*
 * Author: TLB
 * The ignition harness of one vehicle, built the first time anybody opens the
 * column and stored on the vehicle after that, so every player sees the same
 * wires and the work one player did is still done for the next.
 *
 * Every harness has the three wires that matter: the battery feed, which is live
 * all the time, the ignition feed, which runs to the coil, and the starter,
 * which runs to the solenoid. The rest are decoys. A service vehicle adds an
 * alarm feed that sounds the horn if it is shorted, and armour adds an
 * immobiliser that has to be cut first and an unmarked loom, where the colours
 * say nothing and the meter is the only way through.
 *
 * Colours repeat in pairs, as they do on a real harness.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * Harness state <ARRAY>
 */

params ["_vehicle"];

private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
if (count _harness > HN_FRIED) exitWith { _harness };

private _class = [_vehicle] call tlbi_vehicle_fnc_lockClass;
private _count = tlbi_vehicle_classWires select _class;
private _plain = tlbi_vehicle_classPlain select _class;

private _roles = [ROLE_BATTERY, ROLE_IGNITION, ROLE_STARTER];

if (_class == VEH_ARMOURED) then { _roles pushBack ROLE_IMMOBILISER };
if (_class > VEH_CIVIL && {tlbi_vehicle_alarm}) then { _roles pushBack ROLE_ALARM };

while {count _roles < _count} do { _roles pushBack ROLE_DECOY };

_roles = _roles call BIS_fnc_arrayShuffle;

// Colours: pairs of the same colour, drawn from the defusal loom's palette. An
// unmarked loom is one colour throughout.
private _colours = [];

if (_plain) then {
    for "_i" from 1 to _count do { _colours pushBack 8 };
} else {
    private _pairs = [];
    for "_i" from 0 to _count - 1 do { _pairs pushBack floor (_i / 2) };
    _pairs = _pairs call BIS_fnc_arrayShuffle;

    private _order = [];
    for "_i" from 0 to (count tlbi_defusal_palette) - 1 do { _order pushBack _i };
    _order = _order call BIS_fnc_arrayShuffle;

    { _colours pushBack (_order select _x) } forEach _pairs;
};

private _wires = [];

{
    // [role, colour, stripped, cut, volts reading, continuity reading]
    _wires pushBack [_x, _colours select _forEachIndex, false, false, -1, -1];
} forEach _roles;

_harness = [_wires, 3 + _class, HW_SHROUD, 0, false, [], 0];

_vehicle setVariable ["tlbi_vehicle_harness", _harness, true];

_harness
