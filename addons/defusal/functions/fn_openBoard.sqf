#include "..\script_component.hpp"
/*
 * Author: TLB
 * Opens the board for an explosive. Classifies it, builds its state on first
 * contact - or reuses the state already on the object, so backing off and
 * coming back, or handing the job to a team mate, resumes the same device -
 * and wires up the shared chrome for that kind of device.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Explosive <OBJECT>
 *
 * Return Value:
 * Board opened <BOOL>
 */

params ["_unit", "_explosive"];

if (!isNull (uiNamespace getVariable ["tlbi_defusal_display", displayNull])) exitWith { false };
if (!alive _unit || {isNull _explosive}) exitWith { false };

private _kind = [_explosive] call tlbi_defusal_fnc_classify;

// Per-device options from an Explosive settings module, for this board.
private _where = getPos _explosive;
private _level = [_explosive, "Difficulty", tlbi_defusal_difficulty] call tlbi_defusal_fnc_explosiveValue;
private _autoClear = [_explosive, "AutoClear", -1] call tlbi_defusal_fnc_explosiveValue;
uiNamespace setVariable ["tlbi_defusal_level", _level];
uiNamespace setVariable ["tlbi_defusal_autoClearNow", [tlbi_defusal_autoClear, _autoClear == 1] select (_autoClear >= 0)];

private _variable = ["tlbi_defusal_puzzle", "tlbi_defusal_mine", "tlbi_defusal_trip"] select _kind;
private _state = _explosive getVariable [_variable, []];

// State left on a device by an older build has fewer fields; rebuild it rather
// than index past its end.
if (count _state <= ([PZ_TAPE, MN_AT, TR_SLIPS] select _kind)) then {
    _state = [_explosive, _unit] call ([
        tlbi_defusal_fnc_generatePuzzle,
        tlbi_defusal_fnc_mineGenerate,
        tlbi_defusal_fnc_tripGenerate
    ] select _kind);
};

[_unit, ["MedicOther", "PutDown"] select (stance _unit == "Prone")] call ace_common_fnc_doGesture;

// ACE API parity - mission makers hook this to know a defusal has begun.
["ace_explosives_defuseStart", [_explosive, _unit]] call CBA_fnc_globalEvent;

uiNamespace setVariable ["tlbi_defusal_unit", _unit];
uiNamespace setVariable ["tlbi_defusal_explosive", _explosive];
uiNamespace setVariable ["tlbi_defusal_kind", _kind];
uiNamespace setVariable ["tlbi_defusal_selected", -1];
uiNamespace setVariable ["tlbi_defusal_selectedFuze", -1];
uiNamespace setVariable ["tlbi_defusal_tool", TOOL_PROD];
uiNamespace setVariable ["tlbi_defusal_mode", METER_VOLTS];
uiNamespace setVariable ["tlbi_defusal_busy", false];
uiNamespace setVariable ["tlbi_defusal_pinning", false];
uiNamespace setVariable ["tlbi_defusal_holding", false];
uiNamespace setVariable ["tlbi_defusal_resolved", false];
uiNamespace setVariable ["tlbi_defusal_openedAt", diag_tickTime];
{
    uiNamespace setVariable [_x, []];
} forEach [
    "tlbi_defusal_cables", "tlbi_defusal_readouts", "tlbi_defusal_tags", "tlbi_defusal_dirtCtrls",
    "tlbi_defusal_tapeCtrls", "tlbi_defusal_hotspots", "tlbi_defusal_mineCells", "tlbi_defusal_tripTufts",
    "tlbi_defusal_tripFuzes", "tlbi_defusal_gauge"
];
uiNamespace setVariable ["tlbi_defusal_minePin", controlNull];

if (!createDialog "tlbi_RscDefusalBoard") exitWith {
    uiNamespace setVariable ["tlbi_defusal_display", displayNull];
    false
};

private _display = uiNamespace getVariable ["tlbi_defusal_display", displayNull];

if (isNull _display) exitWith { false };

[_display] call tlbi_defusal_fnc_drawBoard;

// Ammo classes rarely carry a display name; the magazine that places them does.
private _config = configOf _explosive;
private _name = getText (_config >> "displayName");
if (_name == "") then {
    _name = getText (configFile >> "CfgMagazines" >> getText (_config >> "defaultMagazine") >> "displayName");
};
if (_name == "") then { _name = typeOf _explosive };

(_display displayCtrl IDC_TITLE) ctrlSetText localize ([
    "STR_tlbi_defusal_board_title",
    "STR_tlbi_defusal_mine_title",
    "STR_tlbi_defusal_trip_title"
] select _kind);

(_display displayCtrl IDC_SUBTITLE) ctrlSetText ([
    format [localize "STR_tlbi_defusal_board_subtitle", _name, _state select PZ_COUNT],
    format [localize "STR_tlbi_defusal_mine_subtitle", _name],
    format [localize "STR_tlbi_defusal_trip_subtitle", _name]
] select _kind);

// The three action buttons mean different things per kind; fn_action routes them.
{
    _x params ["_idc", "_slot"];

    private _button = _display displayCtrl _idc;
    _button setVariable ["tlbi_slot", _slot];
    _button ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        [_ctrl getVariable ["tlbi_slot", 0]] call tlbi_defusal_fnc_action;
    }];

    // Seating a pin is held rather than clicked. Holding the button works as
    // well as holding Space; it only counts while a pin is actually going in.
    _button ctrlAddEventHandler ["MouseButtonDown", {
        if (uiNamespace getVariable ["tlbi_defusal_pinning", false]) then {
            uiNamespace setVariable ["tlbi_defusal_holding", true];
        };
    }];
    _button ctrlAddEventHandler ["MouseButtonUp", { uiNamespace setVariable ["tlbi_defusal_holding", false] }];
    _button ctrlAddEventHandler ["MouseExit", { uiNamespace setVariable ["tlbi_defusal_holding", false] }];
} forEach [[IDC_BTN_A1, 1], [IDC_BTN_A2, 2], [IDC_BTN_A3, 3]];

(_display displayCtrl IDC_BTN_CLOSE) ctrlAddEventHandler ["ButtonClick", {
    if (uiNamespace getVariable ["tlbi_defusal_busy", false]) exitWith {};
    (uiNamespace getVariable ["tlbi_defusal_display", displayNull]) closeDisplay 2;
}];

_display displayAddEventHandler ["KeyDown", {
    params ["", "_key", "_shift", "_ctrl", "_alt"];

    // The Seat pin keybind holds the pin in while one is being seated.
    if ((uiNamespace getVariable ["tlbi_defusal_pinning", false]) && {["tlbi_defusal_seatPin", _key, _shift, _ctrl, _alt] call tlbi_defusal_fnc_keyMatches}) exitWith {
        uiNamespace setVariable ["tlbi_defusal_holding", true];
        true
    };

    // Refuse to be interrupted once hands are on the device.
    _key == 1 && {uiNamespace getVariable ["tlbi_defusal_busy", false]}
}];

_display displayAddEventHandler ["KeyUp", {
    params ["", "_key"];

    if (["tlbi_defusal_seatPin", _key, false, false, false, true] call tlbi_defusal_fnc_keyMatches) exitWith {
        uiNamespace setVariable ["tlbi_defusal_holding", false];
        true
    };
    false
}];

{ (_display displayCtrl _x) ctrlShow false } forEach [IDC_PROGRESS_FRAME, IDC_PROGRESS_BAR, IDC_PROGRESS_TEXT];

[] call tlbi_defusal_fnc_refreshBoard;

// Hybrid mode: ACE's own defuse bar runs underneath, for as long as ACE would
// take - 5 s or the ammo's ace_explosives_defuseTime, half as long again for a
// non-specialist - and finishing on it ends the way ACE's bar ends.
if (tlbi_hybrid_enabled) then {
    private _time = [configOf _explosive >> "ace_explosives_defuseTime", "NUMBER", 5] call CBA_fnc_getConfigEntry;
    if (!(_unit call ace_common_fnc_isEOD) && {missionNamespace getVariable ["ace_explosives_punishNonSpecialists", true]}) then {
        _time = _time * 1.5;
    };

    [
        _display, _time, localize "STR_ACE_Explosives_DefusingExplosive",
        {
            // A cut, a reading or a prod under way resolves first. A pin being
            // seated is not committed - letting go is safe - so it never holds
            // the finish up.
            (uiNamespace getVariable ["tlbi_defusal_busy", false]) && {!(uiNamespace getVariable ["tlbi_defusal_pinning", false])}
        },
        {
            if (uiNamespace getVariable ["tlbi_defusal_resolved", false]) exitWith {};
            [
                uiNamespace getVariable ["tlbi_defusal_unit", objNull],
                uiNamespace getVariable ["tlbi_defusal_explosive", objNull],
                true
            ] call tlbi_defusal_fnc_succeed;
        }
    ] call tlbi_defusal_fnc_hybridBar;
};

// Watchdog: close the board if the player dies, is dragged away or the device
// stops existing, and drive the anti-tamper clock when one is configured.
[{
    params ["_args", "_pfhID"];
    _args params ["_unit", "_explosive", "_limit"];

    private _display = uiNamespace getVariable ["tlbi_defusal_display", displayNull];

    if (isNull _display) exitWith { _pfhID call CBA_fnc_removePerFrameHandler };

    if (!alive _unit || {isNull _explosive} || {_unit distance _explosive > 6} || {!isNull objectParent _unit}) exitWith {
        _pfhID call CBA_fnc_removePerFrameHandler;
        _display closeDisplay 2;
    };

    if (_limit <= 0) exitWith {};

    private _elapsed = (_explosive getVariable ["tlbi_defusal_elapsed", 0])
        + (diag_tickTime - (uiNamespace getVariable ["tlbi_defusal_openedAt", diag_tickTime]));
    private _remaining = _limit - _elapsed;

    (_display displayCtrl IDC_CLOCK) ctrlSetText format ["%1:%2",
        floor ((0 max _remaining) / 60),
        [floor ((0 max _remaining) % 60), 2] call CBA_fnc_formatNumber
    ];

    if (_remaining > 0) exitWith {};

    _pfhID call CBA_fnc_removePerFrameHandler;
    [_unit, _explosive, true] call tlbi_defusal_fnc_fail;
}, 0.1, [_unit, _explosive, tlbi_defusal_timeLimit]] call CBA_fnc_addPerFrameHandler;

true
