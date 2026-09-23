# All settings

[← Back to README](../README.md)

Every setting is a CBA setting under **Options → Addon Options → TLB
Interactions**, and every one is **server-forced**: the server (or the mission)
decides, not individual players. Saved CBA settings override new defaults, so
check them after updating the mod. To change them for one part of a mission,
use the [modules](modules.md).

The *Variable* column is the CBA setting name, for `cba_settings.sqf` and mission
settings files.

- [Interactive Defusal](#interactive-defusal)
- [Interactive Defusal - Device types](#interactive-defusal---device-types)
- [Interactive Defusal - Mines](#interactive-defusal---mines)
- [Interactive Defusal - Tripwires](#interactive-defusal---tripwires)
- [Defusal difficulty](#defusal-difficulty)
- [Lockpicking](#lockpicking)
- [Lockpicking - Pin tumbler / Rake / Sweet spot](#lockpicking---pin-tumbler--rake--sweet-spot)
- [Lockpicking levels](#lockpicking-levels)
- [Lockpicking - Doors without tsp_breach](#lockpicking---doors-without-tsp_breach)
- [Vehicles](#vehicles)
- [Keybinds](#keybinds)
- [Example settings file](#example-settings-file)

---

## Interactive Defusal

| Setting | Variable | Default | Range | Effect |
| --- | --- | --- | --- | --- |
| Replace ACE defusal | `tlbi_defusal_enabled` | on | on / off | Replaces ACE's defusal progress bar with the hands-on procedure for every mine and explosive. Off falls back to stock ACE without unloading the mod. |
| Difficulty | `tlbi_defusal_difficulty` | Normal | Easy / Normal / Hard / Expert | Adjusts the settings below rather than replacing them. See [Defusal difficulty](#defusal-difficulty). |
| Minimum conductors | `tlbi_defusal_minWires` | 3 | 3 to 8 | Fewest conductors an IED can be built with. |
| Maximum conductors | `tlbi_defusal_maxWires` | 5 | 3 to 8 | Most conductors an IED can be built with. More conductors means more readings and more decoys. |
| Devices are buried | `tlbi_defusal_excavation` | on | on / off | IEDs start under soil that has to be brushed away. Off starts at the tape. |
| Auto-clear dirt and grass | `tlbi_defusal_autoClear` | off | on / off | The clearing work does itself while you watch: soil is brushed off an IED, a mine's rim is dug out (never the plate, no prodding needed), the grass over a tripwire is parted. Tape, meter, pins and cuts stay manual. |
| Clearing speed | `tlbi_defusal_clearSpeed` | 1 | 0.25 to 5 | Speed multiplier for brushing, prodding, digging, parting grass and cutting tape, by hand or automatic. 2 is twice as fast. The per-action times are the base values. |
| Brush time per pass (s) | `tlbi_defusal_dirtTime` | 0.6 | 0.2 to 5 | One brush of one soil clump. Every clump takes two. |
| Tape cut time (s) | `tlbi_defusal_tapeTime` | 1.4 | 0.2 to 8 | Cutting one strip of tape. |
| Time per reading (s) | `tlbi_defusal_probeTime` | 2.5 | 0.5 to 10 | How long the meter takes to settle. Readings are unlimited. |
| Continuity test on the firing line | `tlbi_defusal_ohmsRisk` | 25% | 0 to 100% | Chance that a continuity test on the firing line fires the detonator. 0% makes the meter safe. |
| Cut time (s) | `tlbi_defusal_cutTime` | 2 | 0.5 to 15 | How long a cut takes. The board can't be closed during it. |
| Wrong conductor | `tlbi_defusal_failureMode` | Detonate immediately | Detonate immediately (0) / Arm a short countdown (1) / One spare cut, then detonate (2) | What cutting the wrong conductor does. |
| Countdown length (s) | `tlbi_defusal_countdownTime` | 4 | 1 to 15 | The window to get clear when *Arm a short countdown* is selected. |
| Anti-tamper timer (s) | `tlbi_defusal_timeLimit` | 0 (off) | 0 to 600 | Seconds of hands-on time before a device fires by itself. Time is banked on the device. |
| Keep ACE explode-on-defuse | `tlbi_defusal_respectAceExplodeOnDefuse` | off | on / off | Also roll ACE's own explode-on-defuse chance after a correct cut. |

## Interactive Defusal - Device types

Force explosives onto a procedure. Each takes comma-separated **ammo** class
names; a parent class covers everything that inherits from it (for example
`MineBase`). The tripwire list is checked first, then mine, then IED. Anything
not listed is classified automatically. See
[How it works](how-it-works.md#classifying-a-device). Every explosive's class and
the decision are written to the RPT when its board opens:

```
[TLB Interactions] APERSTripMine_Wire_Ammo classified as tripwire (auto)
```

| Setting | Variable | Default | Effect |
| --- | --- | --- | --- |
| Always IED | `tlbi_defusal_classesIed` | empty | Ammo classes that always use the IED procedure. |
| Always mine | `tlbi_defusal_classesMine` | empty | Ammo classes that always use the mine procedure. |
| Always tripwire | `tlbi_defusal_classesTrip` | empty | Ammo classes that always use the tripwire procedure. |

## Interactive Defusal - Mines

| Setting | Variable | Default | Range | Effect |
| --- | --- | --- | --- | --- |
| Prod time (s) | `tlbi_defusal_prodTime` | 1.2 | 0.3 to 5 | One prod of one soil cell. |
| Dig time (s) | `tlbi_defusal_digTime` | 1.0 | 0.3 to 5 | Digging one soil cell out. |
| Prodding the pressure plate | `tlbi_defusal_plateProdRisk` | 50% | 0 to 100% | Chance a prod on the plate fires an AP mine. AT mines use 15% of this. |
| Pin push time (s) | `tlbi_defusal_pinTime` | 4 | 1 to 15 | Seconds of steady pushing to seat a safety pin, for mines and tripwire devices. |
| Pin slips allowed | `tlbi_defusal_pinSlips` | 2 | 0 to 5 | Slips allowed on one device; the next one fires it. |

## Interactive Defusal - Tripwires

| Setting | Variable | Default | Range | Effect |
| --- | --- | --- | --- | --- |
| Part grass time (s) | `tlbi_defusal_grassTime` | 0.7 | 0.2 to 5 | Parting one tuft of grass. |
| Tension check time (s) | `tlbi_defusal_tensionTime` | 2 | 0.5 to 8 | Feeling the wire for tension. |
| Branch to a second device | `tlbi_defusal_branchChance` | 30% | 0 to 100% | Chance a tripwire branches to a second firing device. |
| Grass on tripwires inside buildings | `tlbi_defusal_tripIndoorGrass` | on | on / off | Off: a tripwire under a roof has no grass and starts traced. An Explosive settings module overrides this in its area. |

## Defusal difficulty

*Difficulty* doesn't replace the sliders above; it adjusts them where they are
used:

| Adjusts | Easy | Normal | Hard | Expert |
| --- | --- | --- | --- | --- |
| IED conductors | −1 | ±0 | +1 | +2 (max 8) |
| Continuity test on the firing line | ×0.4 | ×1 | ×1.5 | ×2 |
| Prodding the pressure plate | ×0.4 | ×1 | ×1.4 | ×1.8 |
| Steady-hand band when pinning | ×1.35 | ×1 | ×0.85 | ×0.72 |
| Pin slips allowed | +1 | ±0 | ±0 | −1 |
| Branch to a second device | ×0.5 | ×1 | ×1.5 | ×2 |

---

## Lockpicking

| Setting | Variable | Default | Range | Effect |
| --- | --- | --- | --- | --- |
| Interactive lockpicking | `tlbi_lockpick_enabled` | on | on / off | Picking opens the lockpicking board. Off restores tsp_breach's own progress bar when it is loaded, and removes *Pick lock* from the built-in Door menu. |
| Take over tsp_breach picking | `tlbi_lockpick_takeOverTsp` | on | on / off | tsp_breach's *Use Lockpick* and *Use Paperclip* open this board. |
| ACE lockpick counts as a kit | `tlbi_lockpick_aceLockpick` | on | on / off | ACE's vehicle Lockpick picks doors as a lock pick kit, from the built-in Door menu. tsp_breach's own actions only accept its items. |
| Pick vehicle locks | `tlbi_lockpick_vehicles` | on | on / off | With [TLB Keys](https://github.com/TLB-MilSim/TLB-Keys) loaded, a locked vehicle whose keys the player does not have is picked on this board. Off: TLB Keys falls back to its own progress bar. Without TLB Keys it does nothing. |
| Paperclip bends allowed | `tlbi_lockpick_clipBends` | 2 | 0 to 6 | Mistakes a paperclip survives. The next one snaps it and removes it. |
| Military buildings | `tlbi_lockpick_classesMilitary` | `Land_Barracks_*, Land_i_Barracks_*, Land_u_Barracks_*, Land_Mil_*, Land_MilOffices_*, Land_GuardHouse_*, Land_ControlTower_*, Land_Army_hut*, Land_Budova4*` | text | Building classes with harder locks (5 pins, windows ×0.85). `*` at the end matches a prefix. tsp_breach's list is also used when loaded. |
| Reinforced buildings | `tlbi_lockpick_classesReinforced` | `Land_Cargo_*, Land_Medevac_*, Land_Ammostore*, Land_Garaz_*, Land_Bunker_*` | text | Building classes with the hardest locks (6 pins, windows ×0.72). Checked before military. |

## Lockpicking - Pin tumbler / Rake / Sweet spot

Each technique has its **own settings page** with the same four settings, plus
fine-tuning sliders for that technique. Variables are named
`tlbi_lockpick_<technique><setting>` where technique is `pins`, `rake` or `dial`.

**On every technique page:**

| Setting | Variable | Default | Range | Effect |
| --- | --- | --- | --- | --- |
| Difficulty with a lock pick kit | `tlbi_lockpick_pinsKit` / `rakeKit` / `dialKit` | Normal | Very easy (0) / Easy (1) / Normal (2) / Hard (3) / Expert (4) | Picks the preset row for this technique with a kit. See [Lockpicking levels](#lockpicking-levels). |
| Difficulty with a paperclip | `tlbi_lockpick_pinsClip` / `rakeClip` / `dialClip` | Hard | same | The same, with a paperclip. |
| How often with a lock pick kit | `tlbi_lockpick_pinsOddsKit` / `rakeOddsKit` / `dialOddsKit` | 0.55 / 0.30 / 0.15 | 0 to 1 | Relative weight of this technique when a kit is used, against the other two pages. 0 = never. |
| How often with a paperclip | `tlbi_lockpick_pinsOddsClip` / `rakeOddsClip` / `dialOddsClip` | 0.20 / 0.40 / 0.40 | 0 to 1 | The same, for a paperclip. If all three are 0 for a tool, it gets pin tumbler. |

**Pin tumbler sliders** multiply the chosen level:

| Setting | Variable | Default | Range | Effect |
| --- | --- | --- | --- | --- |
| Shear-line window | `tlbi_lockpick_pinsWindow` | ×1 | 0.25 to 3 | How far either side of the shear line the binding pin can be released and still set. Higher is easier. |
| Binding pin lift speed | `tlbi_lockpick_pinsLift` | ×1 | 0.25 to 2 | How fast the binding pin rises. Lower gives more time to let go. |
| Paperclip shake | `tlbi_lockpick_pinsShake` | ×1 | 0 to 3 | How much a paperclip wanders the pin. 0 is as steady as a kit. |
| Extra pins | `tlbi_lockpick_pinsExtra` | 0 | −3 to +3 | Pins added or removed on top of the level and door class. Always 3 to 7. |

**Rake sliders:**

| Setting | Variable | Default | Range | Effect |
| --- | --- | --- | --- | --- |
| Tension band width | `tlbi_lockpick_rakeBand` | ×1 | 0.25 to 3 | Width of the green band. Higher is easier; never more than 90% of the gauge. |
| Band drift | `tlbi_lockpick_rakeDrift` | ×1 | 0 to 3 | How fast the band wanders. 0 keeps it still. |
| Pin set chance | `tlbi_lockpick_rakeChance` | ×1 | 0.25 to 3 | Chance a stroke inside the band sets a pin. |
| Tension speed | `tlbi_lockpick_rakeTension` | ×1 | 0.25 to 2 | How fast tension builds and eases. Lower is easier to control. |

**Sweet spot sliders:**

| Setting | Variable | Default | Range | Effect |
| --- | --- | --- | --- | --- |
| Sweet spot width | `tlbi_lockpick_dialWidth` | ×1 | 0.25 to 3 | Width of the sweet spot. Higher is easier. |
| Strain tolerance | `tlbi_lockpick_dialStrain` | ×1 | 0.25 to 3 | How long the plug can be forced before it springs back. |
| Paperclip shake | `tlbi_lockpick_dialShake` | ×1 | 0 to 3 | How much a paperclip wanders the pick. 0 is as steady as a kit. |

## Lockpicking levels

The values behind each level. The sliders multiply these; military and
reinforced doors then scale the window, band and width by ×0.85 and ×0.72 and
add pins (civilian 4, military 5, reinforced 6). Shake only ever applies to a
paperclip.

| Pin tumbler | Very easy | Easy | Normal | Hard | Expert |
| --- | --- | --- | --- | --- | --- |
| Shear-line window | 0.50 | 0.36 | 0.24 | 0.19 | 0.14 |
| Binding pin lift speed | 0.30 | 0.42 | 0.55 | 0.55 | 0.70 |
| Paperclip shake | 0.35 | 0.60 | 0.70 | 0.90 | 1.30 |
| Pins | −2 | −1 | ±0 | ±0 | +1 |
| Glint on the binding pin | both tools | both tools | kit | kit | never |

| Rake | Very easy | Easy | Normal | Hard | Expert |
| --- | --- | --- | --- | --- | --- |
| Tension band | 62% | 42% | 26% | 23% | 16% |
| Band drift | 0.08 | 0.15 | 0.25 | 0.25 | 0.35 |
| Stroke in the band sets a pin | 60% | 45% | 32% | 24% | 18% |
| Stroke over the band slips | 10% | 30% | 50% | 50% | 70% |
| Stroke under the band drops a pin | 25% | 50% | 100% | 100% | 100% |
| Tension build speed | 0.8 | 1.0 | 1.2 | 1.2 | 1.4 |
| Pins | −2 | −1 | ±0 | ±0 | +1 |

| Sweet spot | Very easy | Easy | Normal | Hard | Expert |
| --- | --- | --- | --- | --- | --- |
| Sweet spot width | 32° | 22° | 12° | 7° | 5° |
| Strain tolerance | 3.0 s | 2.2 s | 1.4 s | 0.9 s | 0.7 s |
| Paperclip shake | 8°/s | 14°/s | 20°/s | 25°/s | 32°/s |
| Still turns this far off the spot | 100° | 80° | 60° | 60° | 45° |

## Lockpicking - Doors without tsp_breach

Only used when tsp_breach is **not** loaded. When it is, tsp_breach's own door
system and settings apply and these are ignored.

| Setting | Variable | Default | Range | Effect |
| --- | --- | --- | --- | --- |
| Door interactions | `tlbi_lockpick_doorActions` | on | on / off | The built-in Door menu (open, close, lock, unlock, pick) and random locking. |
| Buildings with locked doors | `tlbi_lockpick_lockHouses` | 25% | 0 to 100% | Chance a building has any locked doors. Every player sees the same doors locked. |
| Locked doors in those buildings | `tlbi_lockpick_lockDoors` | 50% | 0 to 100% | Chance each door of such a building is locked. Doors the mission already set are left alone. |
| Never lock these buildings | `tlbi_lockpick_lockBlacklist` | empty | text | Building classes never locked at random. `*` at the end matches a prefix. |

---

## Vehicles

Picking vehicle locks and hotwiring. With [TLB Keys](https://github.com/TLB-MilSim/TLB-Keys)
loaded, these only apply while *Pick vehicle locks* (under Lockpicking) is on:
that switch hands vehicles to this mod completely. Turn it off and TLB Keys
decides picking and hotwiring with its own settings instead. What one vehicle
allows is never overridden: a vehicle marked as not pickable, or with ACE's
`ace_vehiclelock_lockpickStrength` set to -1, is left alone either way.

| Setting | Variable | Default | Range | Effect |
| --- | --- | --- | --- | --- |
| Vehicle locks and hotwiring | `tlbi_vehicle_enabled` | on | on / off | The whole addon. Off leaves vehicles to ACE, or to TLB Keys when that is loaded. |
| Hotwiring | `tlbi_vehicle_hotwire` | on | on / off | A driver without the key can hotwire the vehicle they are sitting in, on the hotwire board. |
| Ignition lock | `tlbi_vehicle_ignitionLock` | on | on / off | A vehicle that was locked, or broken into, does not start until it is hotwired. Off: picking the lock is enough to drive away, and there is nothing to hotwire. |
| Steering lock | `tlbi_vehicle_steering` | on | on / off | The steering lock has to be forced before the engine is cranked. |
| Armour can be hotwired | `tlbi_vehicle_armoured` | on | on / off | Armour and aircraft can be hotwired, with an immobiliser to find and cut first. Off: they cannot be hotwired at all. |
| Alarm feed | `tlbi_vehicle_alarm` | on | on / off | Service and armoured looms carry an alarm feed. Short it and the horn sounds, and it reads exactly like a lamp feed on the meter. |
| Hotwiring needs | `tlbi_vehicle_tools` | Kit, paperclip or toolkit | Nothing / Kit, paperclip or toolkit / Toolkit | What the player has to be carrying to hotwire. |
| Shorts allowed | `tlbi_vehicle_shorts` | 2 | 0 to 5 | Shorts a harness survives. The next one finishes it, and cutting one of the three wires that matter finishes it on its own. |
| Replacement time (s) | `tlbi_vehicle_friedTime` | 300 | 0 to 900 | How long a finished harness takes to be replaced before anyone can try that vehicle again. The replacement has new wires in a new order. |
| Working time (s) | `tlbi_vehicle_actionTime` | 2.5 | 0.5 to 10 | How long one screw takes. Stripping, twisting, reading and cutting are fractions of it. |
| Cranking time (s) | `tlbi_vehicle_crankTime` | 1.6 | 0.4 to 5 | How long the engine turns over before it catches. |

Per vehicle, from a script or an Eden init line:

| Variable | Effect |
| --- | --- |
| `vehicle setVariable ["tlbi_vehicle_pickable", false, true]` | This lock cannot be picked. |
| `vehicle setVariable ["tlbi_vehicle_hotwirable", false, true]` | This vehicle cannot be hotwired. |
| `vehicle setVariable ["tlbi_vehicle_hotwired", true, true]` | It runs without its key, as though it had been hotwired. |

---

## Keybinds

Under **Options → Controls → Configure Addons → TLB Interactions**. Keybinds are
per player, not server settings. On-screen hints show the key you have bound.

| Action | Default | Used for |
| --- | --- | --- |
| Seat pin (hold) | Space | Pushing a safety pin into a mine or tripwire device |
| Lockpicking: previous pin / pick left | A | Choosing a pin, or swinging the pick left |
| Lockpicking: next pin / pick right | D | Choosing a pin, or swinging the pick right |
| Lockpicking: lift, tension or turn (hold) | Space | Lifting a pin, holding tension, turning the plug |
| Lockpicking: rake | R | A rake stroke |

The hotwire board uses the same keys: left and right pick a wire, and the lift key holds the starter and forces the steering lock.

<kbd>Esc</kbd> always closes a board, and the board buttons can be held instead of the keys.

---

## Example settings file

A `cba_settings.sqf` (or mission `cba_settings.sqf`) for a relaxed server: forgiving defusal with auto-clearing, easy raking with a kit, and paperclips on
Normal:

```sqf
force tlbi_defusal_difficulty = 0;          // Easy
force tlbi_defusal_autoClear = true;
force tlbi_defusal_clearSpeed = 2;
force tlbi_defusal_failureMode = 1;         // Arm a short countdown
force tlbi_defusal_countdownTime = 6;

force tlbi_lockpick_pinsKit = 1;            // Easy
force tlbi_lockpick_rakeKit = 0;            // Very easy
force tlbi_lockpick_dialKit = 1;            // Easy
force tlbi_lockpick_pinsClip = 2;           // Normal
force tlbi_lockpick_rakeClip = 2;
force tlbi_lockpick_dialClip = 2;
force tlbi_lockpick_rakeDrift = 0.5;        // a steadier tension band
force tlbi_lockpick_clipBends = 4;

force tlbi_lockpick_lockHouses = 0.15;
force tlbi_lockpick_lockBlacklist = "Land_Cargo_*";
```
