#include "..\script_component.hpp"
/*
 * Author: TLB
 * Which lock class a vehicle has: the same three the doors use, so the
 * lockpicking board and the harness both know how hard this one should be.
 *
 *   civilian    cars and trucks nobody issued: four wires, marked colours
 *   military    a service vehicle: five wires and an alarm feed
 *   armoured    armour and aircraft: six wires, an unmarked loom and an
 *               immobiliser to cut first
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * VEH_CIVIL, VEH_MILITARY or VEH_ARMOURED <NUMBER>
 */

params ["_vehicle"];

private _cfg = configOf _vehicle;

if (_vehicle isKindOf "Tank"
    || {_vehicle isKindOf "Air"}
    || {getNumber (_cfg >> "armor") >= 150}
) exitWith { VEH_ARMOURED };

// side 3 is civilian; anything issued to a faction is a service vehicle.
if ((getNumber (_cfg >> "side")) == 3) exitWith { VEH_CIVIL };

VEH_MILITARY
