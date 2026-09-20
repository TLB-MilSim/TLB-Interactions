# Lockpicking & doors

[← Back to README](../README.md)

Locked doors are picked on a board, not a progress bar. This page covers the
tools, the three techniques, how doors are classified, and how doors work with
and without tsp_breach.

- [Tools](#tools)
- [Starting a pick](#starting-a-pick)
- [The board and controls](#the-board-and-controls)
- [Pin tumbler](#pin-tumbler)
- [Rake](#rake)
- [Sweet spot](#sweet-spot)
- [Mistakes, bends and snaps](#mistakes-bends-and-snaps)
- [Doors](#doors)
- [Doors with tsp_breach](#doors-with-tsp_breach)
- [Doors without tsp_breach](#doors-without-tsp_breach)
- [Quick reference](#quick-reference)

---

## Tools

| Item | Class name | Counts as | Where it comes from |
| --- | --- | --- | --- |
| Lock Pick Kit | `tsp_lockpick` | kit | tsp_breach (the standard kit) |
| Paperclip | `tsp_paperclip` | paperclip | tsp_breach (the standard paperclip) |
| Lock Pick Kit | `tlbi_lockpickKit` | kit | TLB Interactions' stand-in |
| Paperclip | `tlbi_paperclip` | paperclip | TLB Interactions' stand-in |
| Lockpick | `ACE_key_lockpick` | kit | ACE's vehicle lockpick, if *ACE lockpick counts as a kit* is on. Works from the built-in Door menu only, because tsp_breach's own actions accept only its items |

The stand-ins exist so the mod works without tsp_breach. When tsp_breach **is**
loaded they are hidden from the Arsenal, Zeus and the editor, so nobody sees two
paperclips. They still work, and saved loadouts that contain them keep
working.

**Kit or paperclip?**

| | Lock pick kit | Paperclip |
| --- | --- | --- |
| Default difficulty | Normal | Hard |
| In the hand | Steady, and a faint glint when the binding pin is in its window | Shakes. The pin or the pick wanders on its own |
| A mistake | Start again | Bends it; the third mistake snaps it |
| Usually draws | Pin tumbler (55%) | Rake or sweet spot (40% each) |
| Used up | Never | When it snaps |

## Starting a pick

- **With tsp_breach:** open the ACE interaction menu at the door and use its
  **Use Lockpick** or **Use Paperclip**.
- **Without tsp_breach:** open the ACE interaction menu at the door handle, open
  the **Door** menu and choose **Pick lock (lock pick kit)** or **Pick lock
  (paperclip)**. It only appears on a locked, closed door, from outside, when you
  carry the tool.

Glass doors can't be picked.

**The technique is rolled once per door, per tool,** and kept until the lock is
picked. Backing away and trying again gets you the same lock, not an easier one.
Switching from a paperclip to a kit rolls that tool's own technique.

## The board and controls

The board shows the lock (a cut-away of the cylinder for pin tumbler and rake,
the lock face in the door for sweet spot) with an LCD, a stage label naming the
technique, a hint line, three buttons and **Back away**.

| Control | Pin tumbler | Rake | Sweet spot |
| --- | --- | --- | --- |
| <kbd>A</kbd> / <kbd>←</kbd> or button 1 | previous pin | button 1 rakes | swing pick left (hold) |
| <kbd>D</kbd> / <kbd>→</kbd> or button 3 | next pin | - | swing pick right (hold) |
| <kbd>W</kbd> / <kbd>Space</kbd> or button 2 | lift (hold) | tension (hold) | turn (hold) |
| <kbd>R</kbd> | - | rake | - |
| <kbd>Esc</kbd> or **Back away** | close the board | | |

Buttons can be **held** exactly like the keys. The keys shown are the defaults;
rebind them under *Configure Addons* (see [Keybinds](settings.md#keybinds)). Walking more than 4 m away, dying
or getting into a vehicle closes the board. Progress on a lock is **not** kept
when the board closes. Once the tension wrench comes out, set pins fall back.

---

## Pin tumbler

<img src="images/lockpick-pins.jpg" alt="Pin tumbler cut-away with two pins set and the binding pin glinting" width="720">

The cut-away shows a row of pin stacks. Each stack is a spring, a silver driver
pin and a brass key pin; the lock turns when every split between driver and key
pin sits at the **shear line**: the line between the brass plug and the steel
housing.

1. **Find the binding pin.** Choose a pin with <kbd>A</kbd>/<kbd>D</kbd> and hold
   <kbd>W</kbd> to lift it. Pins bind **one at a time, in a hidden order**. A loose
   pin springs up quickly and can't be set. **The binding pin lifts slowly and
   stiffly**. That stiffness is how you find it.
2. **Let go at the shear line.** Release the binding pin while its split is inside
   the window at the shear line: it **clicks and stays set**, and the next pin
   starts binding. A kit shows a faint **glint** on the key pin while it is in the
   window (on Very easy and Easy, a paperclip does too).
3. **Don't overset.** Lift the binding pin *past* the window and **every set pin
   drops**. That is a mistake.

The LCD shows `PIN selected/total  SET set/total`.

## Rake

<img src="images/lockpick-rake.jpg" alt="Rake with the tension gauge" width="720">

The cut-away shows the rake in the keyway and a **tension gauge** top left: a
needle and a **green band** that slowly drifts along the track.

1. **Hold tension.** Hold <kbd>W</kbd> to build tension; let go and it eases off.
   Keep the needle **inside the green band**. The band moves, so you keep adjusting.
2. **Rake.** Press <kbd>R</kbd> (or button 1) to rake. A stroke takes about a
   third of a second.
   - **Needle in the band:** the stroke may set a random pin (32% with a kit at Normal).
   - **Needle above the band** (too much tension): the pins bind and can slip. At Normal that happens half the time, and counts as a mistake.
   - **Needle below the band** (too little): a set pin falls back.
3. When every pin is set, the plug turns.

The LCD shows `SET set/total  TENSION percent`.

## Sweet spot

<img src="images/lockpick-sweetspot.jpg" alt="Sweet spot lock face with the strain gauge" width="720">

The lock face in the door, with the pick in the keyway and a **strain gauge**
bottom right.

1. **Swing the pick** with <kbd>A</kbd>/<kbd>D</kbd> to feel for the hidden sweet spot.
2. **Turn** by holding <kbd>W</kbd>. The plug only turns **as far as the pick is
   close to the sweet spot**. Right on it, it turns all the way.
3. **Don't force it.** Holding the turn where the plug has stopped builds
   **strain**. Let go and strain eases. Too much strain and the plug springs back, which is a mistake.
4. Turned all the way, the lock opens.

The LCD shows `TURN degrees  STRAIN percent`.

---

## Mistakes, bends and snaps

A mistake (an overset pin, a slip from raking with too much tension, or forcing
the plug) **resets that lock's progress**.

- **Kit:** "Start again." Nothing else happens.
- **Paperclip:** it **bends**. By default it survives **2 bends**; the **third
  mistake snaps it**, it is removed from your inventory and the board closes.
  Bends are counted on you, not the clip.

On a reinforced door a paperclip averages close to three mistakes. Bring a kit,
or expect to leave the clip in the lock.

---

## Doors

Vehicle locks are picked the same way, on the same board. See
[Vehicles](vehicles.md) for those, and for hotwiring.

**Door classes** decide how hard a lock is:

| Door | Pins | Windows | Buildings (default lists) |
| --- | --- | --- | --- |
| Civilian | 4 | ×1 | Anything not listed below |
| Military | 5 | ×0.85 | `Land_Barracks_*`, `Land_i_Barracks_*`, `Land_u_Barracks_*`, `Land_Mil_*`, `Land_MilOffices_*`, `Land_GuardHouse_*`, `Land_ControlTower_*`, `Land_Army_hut*`, `Land_Budova4*` |
| Reinforced | 6 | ×0.72 | `Land_Cargo_*`, `Land_Medevac_*`, `Land_Ammostore*`, `Land_Garaz_*`, `Land_Bunker_*` |
| Glass | - | - | Any door whose name contains *glass*: can't be picked |

*Windows* scales everything that makes a technique forgiving: the shear-line
window, the tension band and the sweet spot. The difficulty level for the
technique and tool can add or remove pins on top (a lock always has 3 to 7). The
building lists are CBA settings; when tsp_breach is loaded its own military and
reinforced lists are used as well.

Locks use the vanilla variables `bis_disabled_Door_N` (1 = locked) on the
building, so doors locked by a mission, by Eden attributes or by another script
are pickable too, and a picked door is unlocked for everyone.

Mission makers can lock, unlock and configure specific doors with the
[Lock settings module](modules.md#lock-settings).

## Doors with tsp_breach

When [Breach - Rewrite](https://steamcommunity.com/sharedfiles/filedetails/?id=3283645995) (tsp_breach) is loaded it owns the doors:

- its ACE door actions (open, close, knock, lock, unlock, use lockpick / paperclip),
- its random locking of houses at mission start,
- its lists of military and reinforced buildings.

TLB Interactions only replaces what happens when you **pick**: *Use Lockpick* and
*Use Paperclip* open this board instead of a progress bar and a dice roll, and a
successful pick plays tsp_breach's unlock sound. This can be switched off with
*Take over tsp_breach picking*. None of TLB Interactions' own door system runs.

## Doors without tsp_breach

Without tsp_breach, TLB Interactions runs its own door system, so doors always
work. It switches itself off automatically whenever tsp_breach is loaded.

### The Door menu

Open the ACE interaction menu (not self-interaction) near a door. Every door
handle within reach shows a **Door** entry:

| Action | When it shows |
| --- | --- |
| **Open** | The door is closed. On a locked door it tells you *It's locked.* and the handle rattles. |
| **Close** | The door is open. |
| **Unlock** | The door is locked and closed, and you are **inside** the building. |
| **Lock** | The door is unlocked and closed, and you are **inside** the building. |
| **Pick lock (lock pick kit)** / **(paperclip)** | The door is locked and closed, you are **outside**, and you carry the tool. |

Open and Close run the building's own door actions from its config, so buildings
from any terrain or mod open and close exactly as their author made them. "Inside"
means the building's own roof is above your head.

### Random locking

At mission start the server picks a random seed. As you move around, each client
works out which doors of nearby buildings are locked from that seed, the
building and the door number, so **every player sees the same locked doors**
without the server sending anything. Only the doors players actually unlock, pick
or lock are sent over the network.

| Setting | Default |
| --- | --- |
| Buildings with locked doors | 25% of buildings have any locked doors |
| Locked doors in those buildings | 50% of their doors are locked |
| Never lock these buildings | empty |

Doors that already have a lock value (set by the mission, a script or a player) are never overwritten, and glass doors are never locked at random.

---

<sub>Board images are rendered from the mod's own textures and board layout. In game the board opens over the game view.</sub>

---

## Quick reference

- **Pin tumbler:** find the stiff pin, let go at the shear line. Never lift past it.
- **Rake:** needle in the green band first, then rake.
- **Sweet spot:** swing until the plug turns far. Never force it.
- **Paperclip:** snaps on its third mistake. A kit never does.
- **No tsp_breach?** Interaction menu at the door handle → **Door**.
