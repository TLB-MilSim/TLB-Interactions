# How it works

[← Back to README](../README.md)

A technical tour of TLB Interactions for developers and anyone curious about
what happens under the hood.

- [Addons](#addons)
- [Initialisation](#initialisation)
- [Replacing ACE's defusal](#replacing-aces-defusal)
- [Classifying a device](#classifying-a-device)
- [Device state and multiplayer](#device-state-and-multiplayer)
- [Generating devices](#generating-devices)
- [Timed actions and auto-clear](#timed-actions-and-auto-clear)
- [The steady hand](#the-steady-hand)
- [Success and failure](#success-and-failure)
- [Lockpicking](#lockpicking)
- [tsp_breach takeover](#tsp_breach-takeover)
- [The built-in door system](#the-built-in-door-system)
- [Stand-in items](#stand-in-items)
- [Drawing the boards](#drawing-the-boards)
- [Modules and keybinds](#modules-and-keybinds)
- [Logging](#logging)

---

## Addons

| PBO | Prefix | Contents |
| --- | --- | --- |
| `tlbi_main` | `tlbi\addons\main` | Mod identity, version, CBA versioning, the mod logo. |
| `tlbi_defusal` | `tlbi\addons\defusal` | The defusal replacement: IED, mine and tripwire procedures, the shared board dialog and control styles, defusal textures and settings. |
| `tlbi_lockpick` | `tlbi\addons\lockpick` | The lockpicking board and its three techniques, the tsp_breach takeover, the built-in door system and lockpicking settings. Reuses the defusal board's control styles and chrome textures. |
| `tlbi_lockpick_items` | `tlbi\addons\lockpick_items` | The stand-in Lock Pick Kit and Paperclip. Its config is shipped unbinarised on purpose (see [Stand-in items](#stand-in-items)). |

All functions are plain SQF files registered through `CfgFunctions`
(`tlbi_defusal_fnc_*`, `tlbi_lockpick_fnc_*`).

## Initialisation

Each addon registers its settings from a `CfgFunctions` **preInit** function and
does its hooking from a **postInit** function. These are used instead of CBA's
`Extended_PreInit_EventHandlers`: they are engine-native, need no hand-written
PBO path, and can't fail silently the way a mistyped `preprocessFileLineNumbers`
path does. Every init step writes a line to the RPT.

## Replacing ACE's defusal

The obvious approach, reassigning `ace_explosives_fnc_startDefuse`, does not
work. ACE compiles its functions with `compileFinal`, so the assignment is
rejected with `Attempt to override final function` in the RPT.

So the takeover happens at the **interaction** instead. ACE routes every
defusable explosive through two helper classes, `ACE_DefuseObject` and
`ACE_DefuseObject_Large`, which `ace_explosives_fnc_interactEH` attaches to nearby
explosives when the interact menu opens. At postInit the defusal addon swaps the
defuse action on both classes:

```sqf
[_class, 0, [], _action] call ace_interact_menu_fnc_addActionToClass;
[_class, 0, ["ACE_Defuse"]] call ace_interact_menu_fnc_removeActionFromClass;
```

Add comes before remove, because `addActionToClass` is what compiles the class's config
menu, and ACE's own entry has to exist before it can be removed. The replacement
copies ACE's display name, icon, condition and distances, so it is
indistinguishable in the menu. Its statement opens the board; for AI, non-local
units, or with *Replace ACE defusal* off, it calls ACE's original function
(kept in `tlbi_defusal_aceStartDefuse`).

Re-opening `ACE_DefuseObject` in `CfgVehicles` from another addon is **not**
an option: it drops inherited members and the engine throws
`No entry 'bin\config.bin/CfgVehicles/ACE_DefuseObject.side'` on mission load.

## Classifying a device

`fn_classify` decides the procedure for an explosive's ammo class:

1. **Always tripwire** list, then **Always mine**, then **Always IED**, matching class
   names or any parent class (`isKindOf`).
2. Otherwise, automatically, by how it fires:

| Rule | Procedure |
| --- | --- |
| Class name contains `IED` | IED |
| `mineTrigger` names a wire, or the class name contains `trip` | Tripwire |
| Inherits `MineBase` or `BoundingMineBase`, or has a range, pressure or tank trigger | Mine |
| Anything else (remote, timer, magnetic, IR, command) | IED |

Trigger **names** are matched rather than trigger inheritance: in vanilla
`CfgMineTriggers`, both the AT mine's `TankTriggerMagnetic` and the SLAM's
`IRTrigger` inherit from `WireTrigger`, which would otherwise put AT mines on the
tripwire board.

## Device state and multiplayer

A device's state is an array stored on the explosive object with a **public**
`setVariable`:

| Variable | Procedure | Holds |
| --- | --- | --- |
| `tlbi_defusal_puzzle` | IED | conductor count, per-conductor colour / supply / continuity / route, the firing line, stage, readings taken, strikes left, cut conductors, soil clumps, tape strips |
| `tlbi_defusal_mine` | Mine | grid size, plate position, dug and prodded cells, stones, stage, slips, anti-tank flag |
| `tlbi_defusal_trip` | Tripwire | wire position and side, taut or slack, devices (position, pinned), branch, tufts, stage, tension read, slips |
| `tlbi_defusal_elapsed` | all | banked hands-on seconds for the anti-tamper timer |

The state is built the first time anyone opens the device and is reused after
that, so every player sees the same device and progress survives backing off or
changing hands. The board itself (selection, the tool in hand, progress bars) is local UI state in `uiNamespace`.

A watchdog closes the board if the player dies, gets into a vehicle, moves more
than 6 m away or the device disappears, and drives the anti-tamper clock.

## Generating devices

**IED** (`fn_generatePuzzle`). Conductor count is random between the minimum and
maximum settings (adjusted by difficulty, max 8). Every device gets the firing line
(supply + continuity), one live bus tap (supply only) and one return path
(continuity only); the rest are random decoys. Colours repeat in pairs like a
real harness, and each conductor's route to the junction is randomised. Soil is a
jittered 6 × 2 grid of clumps with two brushes each; tape is one strip over the
cable tags and two across the loom.

**Mine** (`fn_mineGenerate`). An 11 × 4 grid; the plate is placed so its 3 × 3
block fits inside; five stones go elsewhere. The mine counts as anti-tank if its
trigger or class says so.

**Tripwire** (`fn_tripGenerate`). A wire at a random height from a stake on one
side to a device on the other, taut or slack at 50/50, with ten tufts along it.
A branch to a second device (chance from settings) gets three tufts of its own.
To stop the grass giving the layout away, a wire without a branch gets a decoy
diagonal of tufts where a branch could be, and ten more are scattered anywhere.

## Timed actions and auto-clear

Every timed action goes through `fn_runAction`: it locks every control, draws the
progress bar over the LCD, and when time is up refreshes the board and runs the
result. The result does **not** depend on the board still being open. Once a
cut is committed, it resolves.

Clearing actions (brush, prod, dig, part grass, cut tape) divide their time by
*Clearing speed*.

**Auto-clear.** When enabled, every board refresh queues `fn_autoClear` for the
next frame. It starts the next clearing step on its own: the next soil clump,
the next rim cell clockwise (with the dig tool, never the plate), or the next
tuft over the wire, each as a normal timed action. That action's own refresh queues
the step after it, so it runs until the clearing stage is done and then stops.
Only one call is ever queued.

## The steady hand

`fn_steadyPin` is shared by mines and tripwires. A needle position is a damped
random walk scaled by √dt, so it behaves the same at any frame rate. Holding
(Space or the button) pushes the pin in but increases the random acceleration
and weakens the spring back to centre; releasing settles it. If the needle leaves
the band (half-width 0.34, scaled by difficulty) while pushing, the pin slips:
−30% progress, needle reset and 0.8 s lockout. Past the slip limit the device
fires. The tuning (a median slip after 1.7 s of constant holding, a pin seated in
about 8 s by easing off at two-thirds of the band) came from offline simulation.

## Success and failure

**Success** (`fn_succeed`) clears the device's state and hands it back to ACE,
which removes the explosive and raises `ace_explosives_defuse` exactly as a stock
defusal would. With *Keep ACE explode-on-defuse* on, ACE's own explode chance is
rolled as well.

**Failure** (`fn_fail`) follows *Wrong conductor*: detonate, arm a countdown, or, with a spare cut left, mark the conductor as a dead end and play a tone. The
timer, the continuity test, plates, slips and taut wires always detonate.

---

## Lockpicking

`fn_start` opens the board for one door and tool.

1. **Door class** (`fn_doorClass`): glass if the door's name contains *glass*;
   otherwise reinforced or military if the building class matches our lists (or
   tsp_breach's), else civilian.
2. **Technique.** Rolled with `selectRandomWeighted` from the three *How often*
   settings for the tool, and stored on the building as
   `tlbi_lockpick_tech_<door>_<tool>` (public) until the lock is picked.
3. **Parameters.** The technique's difficulty level for the tool picks a preset
   row from `tlbi_lockpick_presetPins`, `presetRake` or `presetDial`; the
   technique's sliders multiply it; the door class scales windows and sets the pin
   count. Shake is zeroed for a kit.
4. A state hash map is put in `uiNamespace`, the dialog is created, the cut-away or
   face is drawn, and a per-frame handler runs `fn_tick`.

`fn_tick` runs one of three small simulations each frame:

- **Pins.** Pins bind in a shuffled order. Holding lifts the selected pin (slowly
  if it is the binding pin, quickly and capped if not) with paperclip shake
  added. Releasing the binding pin inside the window sets it; lifting it past the
  window is a mistake. A glint marks the binding pin in its window when the level
  allows.
- **Rake.** The band centre is a random walk; tension rises while held and falls
  when released. A rake stroke (0.35 s cooldown) inside the band sets a random
  unset pin with the level's chance; above the band it can slip (a mistake);
  below it can drop a set pin.
- **Sweet spot.** The pick angle moves with left/right plus shake. While turning,
  the plug turns up to a maximum that falls off with distance from the sweet spot;
  holding at that maximum builds strain, and too much is a mistake. Reaching 90°
  opens the lock.

`fn_mistake` resets progress; a kit just starts again, a paperclip adds a bend
(counted on the unit) and snaps past *Paperclip bends allowed*, removing the item.
`fn_finish` clears the stored technique and runs the unlock code the board was
opened with.

Keys and buttons feed `fn_press`, which keeps separate hold flags for keys and
mouse so releasing one never cancels the other; pin selection and rake strokes
count presses rather than held time.

## tsp_breach takeover

At postInit the lockpick addon checks `isClass (configFile >> "CfgPatches" >>
"tsp_breach")`.

When tsp_breach is loaded, its *Use Lockpick* / *Use Paperclip* actions call the
global `tsp_fnc_breach_pick` **by name** when clicked. That function is a plain
global defined at CBA pre-init, not `compileFinal`, so it is saved and replaced
with `tlbi_lockpick_fnc_tspPick`, which opens the board (or calls the original
when *Take over tsp_breach picking* is off). None of the built-in door system is
started.

The unlock is done by `fn_unlock`, which writes `bis_disabled_Door_N` and
`bis_disabled_<door>` itself and plays tsp_breach's unlock sound with
`playSound3D`. It deliberately does not call tsp_breach's own lock function,
which passes a position where current Arma requires an object and throws a script
error.

## The built-in door system

Without tsp_breach, postInit registers an `ace_interactMenuOpened` handler and a
2-second per-frame handler.

**Door discovery** (`fn_doors`). A building's doors are read from its
`UserActions` config. Every building that opens its doors from the action menu
declares them there. Actions whose class name contains *door* are grouped by the
number in the name (`OpenDoor_1`, `CloseDoor_1`), keeping each action's memory
point, condition and statement. Results are cached per building class.

**Door menu** (`fn_doorHelpers`, `fn_doorAction`). When the interaction menu
opens, the previous helpers are deleted and, for every door handle within 4 m of
the player's eyes, a local `ACE_LogicDummy` is created at the handle with a
**Door** menu. Open and Close run the building's own condition and statement
(`fn_doorRun`, with `this` set to the building and compiled code cached), so doors
move exactly as the building's author made them. Lock and Unlock require the
player to be inside: `fn_isInside` casts a ray straight up and checks it hits
this building. Pick lock requires a locked, closed door, the tool, and the player
outside.

**Random locking** (`fn_rollHouse`). The server stores one random seed per mission
(public, so JIP clients get it). A building is rolled once: `fn_roll` hashes
`[seed, class, rounded position]` into a number between 0 and 1 to decide whether
it has locks at all, then `[seed, class, position, door]` per door. Because the
roll is deterministic, every client arrives at the same locks locally with **no
network traffic**. A door that already has a lock value (from the mission or a
player's public change) is never rolled over, glass doors and doors standing open
are skipped, and blacklisted classes are ignored. Only player actions (unlock,
lock, pick) are broadcast.

Nothing in ACE or vanilla decides that a door is locked, it only reads the lock,
so the rolling has to happen before a door is used. It runs in two places:

- **As the door menu opens** (`fn_doorHelpers`). The buildings within 25 m are
  already looked up to place the helpers, so rolling them there costs nothing and
  guarantees that any door in reach has been decided.
- **In the background** (`fn_lockTick`, every 3 seconds). Needed because the lock
  variable is also read by the building's own vanilla actions and by ACE's door
  opening, which never touch our menu. The cost of a tick is the spatial query, so
  the query is skipped unless the player has moved 40 m since the last one or 30
  seconds have passed, and it is skipped entirely above sprinting speed, where no
  door is in reach. A standing player queries twice a minute, a walking player
  once every 40 m, within 50 m. The radius stays at least 10 m above the movement
  gate, so a player cannot stop inside a ring of buildings the last query missed,
  and the 30 second fallback picks up buildings created during the mission by Zeus
  or a script.

## Stand-in items

`tlbi_lockpick_items` defines `tlbi_lockpickKit` and `tlbi_paperclip`
(`CBA_MiscItem`). Their `scope` is chosen when the game loads the config:

```cpp
#if __has_include("\tsp_breach\functions.sqf")
    #define TLBI_ITEM_SCOPE 1   // tsp_breach present: hidden
#else
    #define TLBI_ITEM_SCOPE 2   // no tsp_breach: in the Arsenal
#endif
```

That check must run on the player's machine, so this one config is **never
binarised**: the release ships any `config.cpp` containing
`__has_include` as plain text. A binarised config would freeze whatever the build
machine had installed.

## Drawing the boards

Every visible part of a device or lock is a pre-rendered texture. Arma's dialog
UI can't draw them any other way: `ctrlSetAngle` has no effect on controls
created at runtime, so rotated pieces render as a staircase.

- Textures are generated with Pillow (`tools/gen_assets.py`,
  `tools/gen_lockpick_assets.py`, `tools/gen_item_icons.py`) and converted with
  Arma 3 Tools' ImageToPAA, which needs power-of-two sizes.
- Cables, tags and plates are greyscale with alpha and tinted at runtime with
  `ctrlSetTextColor`, so one set of cable sprites serves every insulation colour.
- Cable sprites are drawn per vertical travel with fixed headroom, so every cable
  keeps the same thickness however far it travels.
- Things that rotate in the sweet-spot view (the plug and the pick) are
  pre-rendered frames (5° and 6° steps) swapped with `ctrlSetText`.
- The lockpicking board is a controls group, so parts that extend past it (a
  pick's handle) are clipped to the board.
- Clickable parts are invisible buttons placed over the textures.

Sounds are referenced from ACE and tsp_breach rather than shipped.

## Modules and keybinds

**Modules.** `tlbi_moduleExplosive` and `tlbi_moduleLock` are Eden modules with an
area. `fn_moduleValue` finds every module of a class whose `objectArea` contains a
position, takes the smallest, and returns its option, or the caller's default when
the option is *Use settings*. Explosive options are read when a board opens (the
procedure in `fn_classify`, difficulty and auto-clear in `fn_openBoard`, burial,
grass and branch in the generators), so modules also cover explosives placed later.
Lock options are read in `fn_start`, except the lock state, which `fn_moduleLock`
applies on the server a few seconds into the mission.

The Zeus modules, and matching Zeus context menu entries, are registered with Zeus
Enhanced when it is loaded. They store
their options on the object itself (`tlbi_defusal_zeus_<option>` on an explosive,
`tlbi_lockpick_zeus_<door number>` on a building), and those win over any Eden
module: explosive options are read through `fn_explosiveValue`, lock options in
`fn_start`.

**Keybinds.** The keys are CBA keybinds, registered at postInit so they can be
rebound in Configure Addons. A dialog does not pass key presses on to CBA's
keybind handler, so the boards compare their own key events against the bindings
with `fn_keyMatches`, and `fn_keyName` puts the bound key into on-screen hints.

## Logging

Useful RPT lines:

```
[TLB Interactions] preInit: registering settings
[TLB Interactions] postInit: defusal override installed
[TLB Interactions] APERSTripMine_Wire_Ammo classified as tripwire (auto)
[TLB Interactions] lockpick postInit
[TLB Interactions] tsp_breach loaded - using its doors; pick replaced
[TLB Interactions] tsp_breach not loaded - using our own door interactions
```
