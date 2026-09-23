# Vehicles: locks and hotwiring

[← Back to README](../README.md)

A locked vehicle is picked on the same board as a door, and getting in is only
half of it: a vehicle that was locked does not start without its key, so it has
to be hotwired from the driver's seat. Hotwiring is its own board, under the
steering column.

- [Picking a vehicle lock](#picking-a-vehicle-lock)
- [The ignition lock](#the-ignition-lock)
- [The hotwire board](#the-hotwire-board)
- [The loom](#the-loom)
- [Shorts, alarms and a finished harness](#shorts-alarms-and-a-finished-harness)
- [With TLB Keys loaded](#with-tlb-keys-loaded)
- [Quick reference](#quick-reference)

---

## Picking a vehicle lock

Walk up to a locked vehicle, open the ACE interaction menu and choose **Pick
lock**, then the tool to use. It is the same lock pick kit and paperclip the
doors use, and ACE's own Lockpick counts as a kit when that setting is on.

The board is the lockpicking board, with the same three techniques. The vehicle
decides how hard it is:

| Vehicle | Lock | Loom |
| --- | --- | --- |
| Civilian cars and trucks | Civilian | Four wires, colours you can read |
| Service vehicles | Military | Five wires and an alarm feed |
| Armour and aircraft | Reinforced | Six wires, unmarked, and an immobiliser |

A vehicle nobody can pick stays that way. Picking is only offered on a vehicle
that is **Locked**, never on one set to **Locked for players**: that state is the
mission holding a vehicle back from players rather than a lock without a key, so
it is not picked, not hotwired and not touched by the ignition lock. ACE's
`ace_vehiclelock_lockpickStrength` of -1, and a vehicle a mission or Zeus marked
as not pickable, are left alone the same way.

## The ignition lock

Picking the lock opens the doors. With *Ignition lock* on, which is the default,
that is all it does: the vehicle was locked, so it is not yours, and it will not
start. Get into the driver's seat and hotwire it.

Turn *Ignition lock* off and picking a lock is enough to drive away, and nothing
offers hotwiring at all.

A hotwired vehicle keeps running without a key until somebody with a key locks it
again.

## The hotwire board

In the driver's seat, open the ACE self-interaction menu and choose **Hotwire**.
You need something to work with: any lock pick kit, a paperclip or a toolkit by
default, and the setting can ask for a toolkit only, or for nothing at all.

<img src="images/hotwire.jpg" alt="The hotwire board: the ignition barrel, its loom, and each wire's meter readings" width="820">

The board runs in four stages.

**1. The shroud.** The plastic cover over the column is held on by three to five
screws. Click each one to take it out. With the last one gone the cover comes
off and the ignition barrel is in front of you.

**2. The loom.** Wires run from the barrel's connector out to the right, numbered
by their tags. Pick one with the left and right keys or by clicking it, then:

| Plate | Does |
| --- | --- |
| **Strip** | Takes the sheath off the selected wire, so it can be read or joined. |
| **Twist** | The same plate once a wire is bare: the first press puts the clip on, the second twists that wire onto the selected one. Press it on the clipped wire again to take the clip off. |
| **Volts** | Is this wire live? Only the battery feed is. |
| **Ohms** | Where does it go? The coil, the solenoid, the lamps, or nowhere. |
| **Cut** | Cuts the selected wire. |

**3. The steering lock.** Once the dash is live, hold the lift key to force the
steering lock until it shears. Let go and it takes back what it gained.

**4. The ignition.** Hold the lift key to crank. The engine turns over, and the
moment the readout says it catches, let go. Keep holding and the starter grinds
against a running engine, which costs you a cool-down.

<img src="images/hotwire-crank.jpg" alt="The battery feed twisted onto the ignition feed, and the engine catching" width="820">

## The loom

Three wires matter:

| Wire | Volts | Ohms |
| --- | --- | --- |
| Battery feed | 12 V | No path |
| Ignition feed | 0 V | Coil |
| Starter feed | 0 V | Solenoid |
| Decoys: lamps, radio, gauges | 0 V | Lamps |
| Alarm feed | 0 V | Lamps |
| Immobiliser | 0 V | No path |

Voltage finds the battery feed and nothing else. Continuity finds the coil and
the solenoid. An alarm feed reads exactly like a lamp feed, which is why guessing
on a service vehicle is expensive.

**Battery to ignition** brings the dash alive. **Battery to starter** turns the
engine over and it dies, because nothing is feeding the coil. On armour the
immobiliser cuts the coil feed until it is found and cut, so the dash stays dead
however right the pair is.

Cutting is not only for the immobiliser. Cutting the alarm feed before anything
is live means it can never sound. Cutting one of the three that matter finishes
the harness on the spot.

## Shorts, alarms and a finished harness

Only a live feed can go wrong. Twisting two dead wires together does nothing at
all, whatever the pair; twisting the battery feed onto the wrong wire blows a
fuse, and the loom is dead for a few seconds, which is long enough to be caught.

Shorting the alarm feed sounds the horn where the vehicle is, for everyone.

Past the allowed number of shorts, the harness is finished. It is replaced, which
takes five minutes by default, and the replacement has new wires in a new order,
so nothing that was learned about it still applies.

Everything else is kept on the vehicle: the screws that are out, the wires that
are stripped, the readings taken and the twist itself. Close the board, back out
of the seat, hand it to somebody else, and the job carries on where it stopped.

## With TLB Keys loaded

[TLB Keys](https://github.com/TLB-MilSim/TLB-Keys) has its own vehicle keys,
locks, picking and hotwiring. Only one of the two mods runs that system, and the
switch is *Pick vehicle locks* in the lockpicking settings:

| Setting | Who owns vehicle picking and hotwiring |
| --- | --- |
| On (default) | **TLB Interactions**: this board, these settings, this ignition lock. TLB Keys keeps the keys themselves. |
| Off | **TLB Keys**: its progress bar, its settings. Nothing here runs. |

Who holds a key is always TLB Keys' answer when it is loaded, and ACE's when it
is not. A key holder is never asked to pick or hotwire anything.

## Quick reference

| | |
| --- | --- |
| Pick a lock | Interaction menu on the vehicle → Pick lock |
| Hotwire | Self-interaction menu in the driver's seat → Hotwire |
| Choose a wire | Left and right keys, or click it |
| Crank, force the lock | Hold the lift key (Space by default) |
| Leave the board | Esc, or Back off |
| Battery feed | 12 V |
| Ignition feed | Continuity to the coil |
| Starter feed | Continuity to the solenoid |

Settings for all of it: [Vehicles](settings.md#vehicles).
