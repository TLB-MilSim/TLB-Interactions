// TLB Interactions - Vehicles
// Shared constants for config and SQF. Macro-light for the same reason as the
// other addons: built without a P: drive.

#define PATHTOF(var1) \tlbi\addons\vehicle\var1
#define QPATHTOF(var1) QUOTE(PATHTOF(var1))
#define QUOTE(var1) #var1

// Chrome textures (panel, LCD, plates) and the wire sprites are shared with the
// defusal addon.
#define CHROME(var1) QUOTE(\tlbi\addons\defusal\data\var1)
#define SHARED(var1) \tlbi\addons\defusal\data\var1
#define QSHARED(var1) QUOTE(SHARED(var1))

// --- Hotwire board ----------------------------------------------------------
#define IDD_TLBI_HOTWIRE    716000
#define IDC_HW_TITLE        716001
#define IDC_HW_SUBTITLE     716002
#define IDC_HW_BOARD        716003
#define IDC_HW_READOUT      716004
#define IDC_HW_STAGE        716005
#define IDC_HW_STATUS       716006
#define IDC_HW_BTN_A1       716010
#define IDC_HW_BTN_A2       716011
#define IDC_HW_BTN_A3       716012
#define IDC_HW_BTN_A4       716013
#define IDC_HW_BTN_A5       716014
#define IDC_HW_BTN_CLOSE    716015
#define IDC_HW_PROG_FRAME   716020
#define IDC_HW_PROG_BAR     716021
#define IDC_HW_PROG_TEXT    716022

// --- Vehicle lock classes ---------------------------------------------------
// The same three classes the doors use: pins in the cylinder and how tight
// every window is, plus how many wires the harness has.
#define VEH_CIVIL           0
#define VEH_MILITARY        1
#define VEH_ARMOURED        2

// --- Hotwire stages ---------------------------------------------------------
#define HW_SHROUD           0   // unscrew the column shroud
#define HW_WIRES            1   // strip, test and join the harness
#define HW_STEERING         2   // shear the steering lock
#define HW_CRANK            3   // hold the starter wire on the live pair
#define HW_DONE             4

// --- Wire roles -------------------------------------------------------------
#define ROLE_BATTERY        0   // live at all times
#define ROLE_IGNITION       1   // continuity to the coil: joins to battery
#define ROLE_STARTER        2   // continuity to the solenoid: cranks
#define ROLE_DECOY          3   // lamps, radio, gauges
#define ROLE_ALARM          4   // joined or shorted, it sounds the horn
#define ROLE_IMMOBILISER    5   // armoured vehicles: cut it before joining

// --- Harness state indices (stored on the vehicle) --------------------------
#define HN_WIRES            0   // one entry per wire, indices below
#define HN_SCREWS           1   // screws still in the shroud
#define HN_STAGE            2
#define HN_SHORTS           3   // shorts survived so far
#define HN_STEER            4   // steering lock forced
#define HN_JOINED           5   // the joined pair [a, b], or []
#define HN_FRIED            6   // mission time the harness stops being fried

// One wire: role, insulation colour, sheath stripped, cut, and the two readings
// the meter has taken on it (-1 until tested).
#define WR_ROLE             0
#define WR_COLOUR           1
#define WR_STRIPPED         2
#define WR_CUT              3
#define WR_VOLTS            4
#define WR_CONT             5

// Continuity readings.
#define CONT_NONE           0
#define CONT_COIL           1
#define CONT_SOLENOID       2
#define CONT_LAMPS          3

// --- Tools ------------------------------------------------------------------
#define HWTOOL_NONE         0
#define HWTOOL_ANY          1   // a lock pick kit, a paperclip or a toolkit
#define HWTOOL_KIT          2   // a toolkit only

// --- Keys (DIK codes) -------------------------------------------------------
#define KEY_ESC             1
