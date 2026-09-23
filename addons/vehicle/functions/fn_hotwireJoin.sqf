#include "..\script_component.hpp"
/*
 * Author: TLB
 * Twists the wire under the clip onto the selected one, and works out what that
 * does.
 *
 * The model is the electrics, not a puzzle rule: only a live feed can do
 * anything. Nothing happens when two dead wires are twisted together, however
 * wrong the pair is. Once the battery feed is in hand the stakes arrive:
 *
 *   battery + ignition       the dash comes alive, ready to crank
 *   battery + starter        it turns over and dies: no ignition, no run
 *   battery + alarm          the horn starts and the fuse goes
 *   battery + anything else  a short, and one of the fuses with it
 *
 * On armour the immobiliser cuts the ignition feed until it is found and cut, so
 * the dash stays dead however right the pair is.
 *
 * Return Value:
 * None
 */

private _state = uiNamespace getVariable ["tlbi_vehicle_state", createHashMap];
if (count _state == 0) exitWith {};

private _vehicle = _state get "veh";
private _harness = _vehicle getVariable ["tlbi_vehicle_harness", []];
if (count _harness <= HN_FRIED) exitWith {};

private _wires = _harness select HN_WIRES;
private _a = _state getOrDefault ["clip", -1];
private _b = _state getOrDefault ["sel", -1];

_state set ["clip", -1];

if (_a < 0 || {_b < 0} || {_a == _b} || {_a >= count _wires} || {_b >= count _wires}) exitWith {};

private _fnc_usable = {
    private _wire = _wires select _this;
    (_wire select WR_STRIPPED) && {!(_wire select WR_CUT)}
};

if (!(_a call _fnc_usable) || {!(_b call _fnc_usable)}) exitWith {
    [localize "STR_tlbi_vehicle_msg_sheathed"] call tlbi_vehicle_fnc_hotwireStatus;
};

private _roles = [(_wires select _a) select WR_ROLE, (_wires select _b) select WR_ROLE];

// Only a permanently live feed can make anything happen, or go wrong.
private _live = ROLE_BATTERY in _roles || {ROLE_ALARM in _roles};

if (!_live) exitWith {
    [localize "STR_tlbi_vehicle_msg_nothing"] call tlbi_vehicle_fnc_hotwireStatus;
};

if (ROLE_ALARM in _roles) exitWith {
    [_vehicle] call tlbi_vehicle_fnc_alarm;
    [localize "STR_tlbi_vehicle_msg_alarm", false] call tlbi_vehicle_fnc_short;
};

private _other = [_roles select 0, _roles select 1] select ((_roles select 0) == ROLE_BATTERY);

if (_other == ROLE_STARTER) exitWith {
    playSound "ACE_Sound_Click_10db";
    [localize "STR_tlbi_vehicle_msg_turnsOver"] call tlbi_vehicle_fnc_hotwireStatus;
};

if (_other != ROLE_IGNITION) exitWith {
    [localize "STR_tlbi_vehicle_msg_short", false] call tlbi_vehicle_fnc_short;
};

// An immobiliser still in one piece keeps the coil dead whatever is twisted on.
private _blocked = (_wires findIf {
    (_x select WR_ROLE) == ROLE_IMMOBILISER && {!(_x select WR_CUT)}
}) != -1;

if (_blocked) exitWith {
    [localize "STR_tlbi_vehicle_msg_immobiliser"] call tlbi_vehicle_fnc_hotwireStatus;
};

_harness set [HN_JOINED, [_a, _b]];

// The barrel is live, but the wheel is still locked on anything that has a
// steering lock worth shearing.
_harness set [HN_STAGE, [HW_CRANK, HW_STEERING] select (tlbi_vehicle_steering && {!(_harness select HN_STEER)})];
_vehicle setVariable ["tlbi_vehicle_harness", _harness, true];

playSound "ACE_Sound_Click";
[localize "STR_tlbi_vehicle_msg_dashLive"] call tlbi_vehicle_fnc_hotwireStatus;
