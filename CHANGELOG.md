# Changelog

[← Back to README](README.md)

## Unreleased

### Changed

- **Cheaper door lock scanning.** Random door locking used to search 100 m around
  every player every 2 seconds. It now rolls a building as the door menu opens,
  and the background pass runs every 3 seconds but only searches, within 50 m,
  after the player has moved 40 m or 30 seconds have passed, and never above
  sprinting speed. Which doors end up locked is unchanged. Thanks to
  [@RicGonzalezb](https://github.com/RicGonzalezb) for the change and the report.

### Fixed

- A door standing open is no longer given a lock, so it cannot end up open and
  locked at the same time.

## 1.1.0 (2026-09-17)

### Added

- **Eden modules.** *Explosive settings* and *Lock settings*, under **Systems (F5) →
  Modules → TLB Interactions**, configure every explosive or door inside their
  area. See [Modules](docs/modules.md).

  | The modules in Eden | Explosive settings in Eden |
  | --- | --- |
  | <img src="docs/images/eden-modules-tree.jpg" alt="TLB Interactions modules in the Eden asset browser" width="220"> | <img src="docs/images/eden-explosive-module.jpg" alt="Explosive settings module attributes in Eden" width="380"> |

- **Zeus modules and context menu** (needs Zeus Enhanced). The same options for
  one explosive or door in a live mission. Point at an explosive or door and open
  the context menu, or place the module on it. Zeus settings override the Eden
  modules.

  | Context menu | Dialog |
  | --- | --- |
  | <img src="docs/images/zeus-explosive-menu.jpg" alt="Explosive settings in the Zeus context menu" width="380"> | <img src="docs/images/zeus-explosive-dialog.jpg" alt="Zeus Explosive settings dialog" width="380"> |
  | <img src="docs/images/zeus-lock-menu.jpg" alt="Lock settings in the Zeus context menu" width="380"> | <img src="docs/images/zeus-lock-dialog.jpg" alt="Zeus Lock settings dialog" width="380"> |

- **Rebindable keys.** Seat pin and the lockpicking controls are in
  **Configure Addons → TLB Interactions**, and on-screen hints show the bound key.
  See [Keybinds](docs/settings.md#keybinds).
- **Setting:** *Grass on tripwires inside buildings* (on by default). Turn it off
  and tripwires under a roof have no grass and start traced.

### Changed

- The lockpicking board only uses the bound keys. W and the arrow keys no longer
  work as extra keys, so a rebind never collides with them.

## 1.0.0

- First release: hands-on defusal for IEDs, mines and tripwires, lockpicking with
  a lock pick kit or a paperclip, and the built-in door system for play without
  tsp_breach.
