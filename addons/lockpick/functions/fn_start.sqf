#include "..\script_component.hpp"
/*
 * Author: TLB
 * Opens the lockpicking board for one door.
 *
 * The technique is random, weighted by the tool: a lock pick kit favours
 * single-pin picking, a paperclip favours raking and feeling for the sweet
 * spot. Once rolled it is stored on the door for that tool, so backing off and
 * trying again cannot re-roll an easier lock. The door's class (civilian,
 * military, reinforced) sets pin count and how tight every window is.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: House <OBJECT>
 * 2: Door selection name <STRING>
 * 3: TOOL_KIT or TOOL_CLIP <NUMBER>
 * 4: Item class being used <STRING>
 * 5: Unlock code <CODE> - called with the arguments below on success
 * 6: Unlock arguments <ARRAY>
 * 7: Lock class, or -1 to read it from the building <NUMBER> (default: -1)
 * 8: Object the rolled lock belongs to <OBJECT> (default: the building)
 *
 * Return Value:
 * Board opened <BOOL>
 */

params ["_unit", "_house", "_door", "_tool", "_item", "_unlock", "_unlockArgs", ["_classOverride", -1], ["_owner", objNull]];

// A vehicle lock is picked on a stand-in building at the player's feet, so the
// class and the object that remembers the rolled technique are passed in.
if (isNull _owner) then { _owner = _house };

if (!isNull (uiNamespace getVariable ["tlbi_lockpick_display", displayNull])) exitWith { false };
if (!alive _unit || {isNull _house} || {_item == ""}) exitWith { false };

// A Lock settings module covering the door handle can override the lock.
private _doorPos = _house modelToWorld (_house selectionPosition _door);
if ((_house selectionPosition _door) isEqualTo [0, 0, 0]) then { _doorPos = getPos _unit };
// Zeus Lock settings on this door win, then the Eden module covering the handle.
// Stored order: Pickable, Technique, DoorClass, KitLevel, ClipLevel.
private _zeus = _house getVariable [[_door] call tlbi_lockpick_fnc_doorKey, []];
private _fnc_module = {
    params ["_name"];
    private _value = _zeus param [["Pickable", "Technique", "DoorClass", "KitLevel", "ClipLevel"] find _name, -1];
    if (_value isEqualType 0 && {_value >= 0}) exitWith { _value };
    ["tlbi_moduleLock", _doorPos, _name, -1] call tlbi_defusal_fnc_moduleValue
};

if ((["Pickable"] call _fnc_module) == 0) exitWith {
    [localize "STR_tlbi_lockpick_msg_unpickable"] call ace_common_fnc_displayTextStructured;
    false
};

private _classModule = ["DoorClass"] call _fnc_module;
private _class = [[_house, _door] call tlbi_lockpick_fnc_doorClass, _classOverride] select (_classOverride >= 0);
if (_classModule >= 0) then { _class = _classModule min DOOR_REINFORCED };

if (_class == DOOR_GLASS) exitWith {
    [localize "STR_tlbi_lockpick_msg_glass"] call ace_common_fnc_displayTextStructured;
    false
};

private _techVar = format ["tlbi_lockpick_tech_%1_%2", _door, _tool];
private _tech = _owner getVariable [_techVar, -1];

private _toolSuffix = ["Kit", "Clip"] select _tool;

if (_tech < 0) then {
    // How often each technique comes up with this tool, from its settings page.
    private _weights = ["pins", "rake", "dial"] apply {
        (missionNamespace getVariable [format ["tlbi_lockpick_%1Odds%2", _x, _toolSuffix], 1]) max 0
    };
    _weights params ["_wPins", "_wRake", "_wDial"];

    _tech = if (_wPins + _wRake + _wDial <= 0) then {
        TECH_PINS
    } else {
        selectRandomWeighted [TECH_PINS, _wPins, TECH_RAKE, _wRake, TECH_DIAL, _wDial]
    };
    _owner setVariable [_techVar, _tech, true];
};

private _techModule = ["Technique"] call _fnc_module;
if (_techModule >= 0) then { _tech = _techModule min TECH_DIAL };

// The technique's difficulty level for this tool picks a preset row (fn_preInit),
// the technique's fine-tuning sliders scale it, and the door class tightens it.
private _key = ["pins", "rake", "dial"] select _tech;
private _level = round (missionNamespace getVariable [format ["tlbi_lockpick_%1%2", _key, _toolSuffix], [2, 3] select _tool]);
private _levelModule = [["KitLevel", "ClipLevel"] select _tool] call _fnc_module;
if (_levelModule >= 0) then { _level = _levelModule };
_level = (_level max 0) min 4;

private _scale = tlbi_lockpick_classScale select _class;
private _clip = [0, 1] select (_tool == TOOL_CLIP);
private _fnc_tune = {
    params ["_suffix", "_default"];
    missionNamespace getVariable [format ["tlbi_lockpick_%1%2", _key, _suffix], _default]
};

private _params = createHashMap;
private _extraPins = 0;

switch (_tech) do {
    case TECH_PINS: {
        (tlbi_lockpick_presetPins select _level) params ["_window", "_lift", "_shake", "_pins", "_glint"];
        _params set ["window", _window * _scale * (["Window", 1] call _fnc_tune)];
        _params set ["lift", _lift * (["Lift", 1] call _fnc_tune)];
        _params set ["shake", _shake * _clip * (["Shake", 1] call _fnc_tune)];
        _params set ["glint", _glint == 2 || {_glint == 1 && {_tool == TOOL_KIT}}];
        _extraPins = _pins + round (["Extra", 0] call _fnc_tune);
    };
    case TECH_RAKE: {
        (tlbi_lockpick_presetRake select _level) params ["_band", "_drift", "_chance", "_slip", "_drop", "_rise", "_pins"];
        private _speed = ["Tension", 1] call _fnc_tune;
        _params set ["band", (_band * _scale * (["Band", 1] call _fnc_tune)) min 0.9];
        _params set ["drift", _drift * (["Drift", 1] call _fnc_tune)];
        _params set ["chance", (_chance * (["Chance", 1] call _fnc_tune)) min 1];
        _params set ["slipChance", _slip];
        _params set ["dropChance", _drop];
        _params set ["rise", _rise * _speed];
        _params set ["fall", _speed];
        _extraPins = _pins;
    };
    default {
        (tlbi_lockpick_presetDial select _level) params ["_width", "_strain", "_shake", "_falloff"];
        _params set ["width", _width * _scale * (["Width", 1] call _fnc_tune)];
        _params set ["strainLimit", _strain * (["Strain", 1] call _fnc_tune)];
        _params set ["shake", _shake * _clip * (["Shake", 1] call _fnc_tune)];
        _params set ["falloff", _falloff];
    };
};

// Where the door is, for the walk-away check. Some buildings give no position
// for the door selection; fall back to where the player is standing.
private _pos = _house modelToWorldWorld (_house selectionPosition _door);
if (_pos vectorDistance (getPosASL _house) < 0.1) then { _pos = getPosASL _unit };

private _n = (((tlbi_lockpick_classPins select _class) + _extraPins) max 3) min 7;
private _keyLen = [];
private _heights = [];
private _set = [];
private _order = [];

for "_i" from 0 to _n - 1 do {
    _keyLen pushBack (0.14 + random 0.10);
    _heights pushBack 0;
    _set pushBack false;
    _order pushBack _i;
};

private _state = createHashMapFromArray [
    ["unit", _unit], ["house", _house], ["owner", _owner], ["door", _door], ["tool", _tool], ["item", _item],
    ["tech", _tech], ["class", _class], ["unlock", _unlock], ["unlockArgs", _unlockArgs], ["pos", _pos],
    ["n", _n], ["keyLen", _keyLen], ["h", _heights], ["set", _set], ["order", _order call BIS_fnc_arrayShuffle],
    ["sel", 0], ["pickX", CUT_PIN_X0], ["window", 0.24], ["lift", 0.55], ["glint", false],
    ["tension", 0], ["centre", 0.5], ["band", 0.26], ["drift", 0.25], ["chance", 0.32],
    ["slipChance", 0.5], ["dropChance", 1], ["rise", 1.2], ["fall", 1], ["nextStroke", 0], ["stroke", 0],
    ["angle", 0], ["sweet", -75 + random 150], ["width", 12], ["falloff", 60],
    ["turn", 0], ["strain", 0], ["strainLimit", 1.4], ["plugFrame", -1], ["pickFrame", -1],
    ["shake", 0],
    ["last", diag_tickTime], ["done", false], ["wasHolding", false],
    ["leftEdge", 0], ["rightEdge", 0], ["rakeEdge", 0]
];

// The technique's own values replace the neutral defaults above.
{ _state set [_x, _y] } forEach _params;

uiNamespace setVariable ["tlbi_lockpick_state", _state];

if (!createDialog "tlbi_RscLockpickBoard") exitWith {
    uiNamespace setVariable ["tlbi_lockpick_state", createHashMap];
    false
};

private _display = uiNamespace getVariable ["tlbi_lockpick_display", displayNull];

if (isNull _display) exitWith { false };

if (_tech == TECH_DIAL) then {
    [_display] call tlbi_lockpick_fnc_drawFace;
} else {
    [_display] call tlbi_lockpick_fnc_drawCutaway;
};

// Board buttons are held, not clicked: each one feeds fn_press on the way down
// and on the way up, exactly like its matching key.
{
    _x params ["_idc", "_input"];

    private _button = _display displayCtrl _idc;
    _button setVariable ["tlbi_input", _input];
    _button ctrlAddEventHandler ["MouseButtonDown", { params ["_c"]; [_c getVariable ["tlbi_input", ""], true, true] call tlbi_lockpick_fnc_press }];
    _button ctrlAddEventHandler ["MouseButtonUp", { params ["_c"]; [_c getVariable ["tlbi_input", ""], false, true] call tlbi_lockpick_fnc_press }];
    _button ctrlAddEventHandler ["MouseExit", { params ["_c"]; [_c getVariable ["tlbi_input", ""], false, true] call tlbi_lockpick_fnc_press }];
} forEach [
    [IDC_LP_BTN_A1, ["left", "rake"] select (_tech == TECH_RAKE)],
    [IDC_LP_BTN_A2, "hold"],
    [IDC_LP_BTN_A3, "right"]
];

(_display displayCtrl IDC_LP_BTN_CLOSE) ctrlAddEventHandler ["ButtonClick", {
    (uiNamespace getVariable ["tlbi_lockpick_display", displayNull]) closeDisplay 2;
}];

// Keys come from the lockpicking keybinds (Configure Addons).
private _fnc_key = {
    params ["_key", ["_shift", false], ["_ctrl", false], ["_alt", false], ["_anyModifiers", false]];
    private _found = "";
    {
        _x params ["_input", "_action"];
        if ([_action, _key, _shift, _ctrl, _alt, _anyModifiers] call tlbi_defusal_fnc_keyMatches) exitWith { _found = _input };
    } forEach [["hold", "tlbi_lockpick_hold"], ["left", "tlbi_lockpick_left"], ["right", "tlbi_lockpick_right"], ["rake", "tlbi_lockpick_rake"]];
    _found
};
uiNamespace setVariable ["tlbi_lockpick_keyMap", _fnc_key];

_display displayAddEventHandler ["KeyDown", {
    params ["", "_key", "_shift", "_ctrl", "_alt"];
    private _input = [_key, _shift, _ctrl, _alt] call (uiNamespace getVariable ["tlbi_lockpick_keyMap", {""}]);
    if (_input == "") exitWith { false };
    [_input, true] call tlbi_lockpick_fnc_press;
    true
}];

_display displayAddEventHandler ["KeyUp", {
    params ["", "_key"];
    private _input = [_key, false, false, false, true] call (uiNamespace getVariable ["tlbi_lockpick_keyMap", {""}]);
    if (_input == "") exitWith { false };
    [_input, false] call tlbi_lockpick_fnc_press;
    true
}];

[] call tlbi_lockpick_fnc_refresh;

[{ _this call tlbi_lockpick_fnc_tick }, 0, []] call CBA_fnc_addPerFrameHandler;

true
