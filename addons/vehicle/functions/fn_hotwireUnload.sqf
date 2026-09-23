#include "..\script_component.hpp"
/*
 * Author: TLB
 * Board closed. The tick handler notices the display is gone and removes itself;
 * this only drops the board's own state.
 *
 * Nothing about the job is lost: the screws, the stripped wires, the readings and
 * the twist all live on the vehicle, so whoever opens the column next carries on
 * where this player stopped.
 *
 * Return Value:
 * None
 */

uiNamespace setVariable ["tlbi_vehicle_display", displayNull];
uiNamespace setVariable ["tlbi_vehicle_state", createHashMap];
