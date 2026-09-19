#include "script_component.hpp"
#include "..\main\script_version.hpp"

#define VERSION_STR MAJOR.MINOR.PATCHLVL.BUILD
#define VERSION_AR MAJOR,MINOR,PATCHLVL,BUILD

class CfgPatches {
    class tlbi_lockpick {
        name = "TLB Interactions - Lockpicking";
        author = "TLB";
        url = "";
        units[] = {"tlbi_moduleLock"};
        weapons[] = {};
        requiredVersion = 2.02;
        // tlbi_defusal provides the shared control styles, chrome textures and
        // module helpers; A3_Ui_F the controls group the board is built in.
        requiredAddons[] = {"A3_Ui_F", "A3_Modules_F", "tlbi_main", "tlbi_defusal", "cba_main","ace_common", "ace_interact_menu", "ace_interaction"};
        version = VERSION_STR;
        versionStr = QUOTE(VERSION_STR);
        versionAr[] = {VERSION_AR};
        skipWhenMissingDependencies = 1;
    };
};

class CfgFunctions {
    class tlbi_lockpick {
        tag = "tlbi_lockpick";

        class lockpick {
            file = "tlbi\addons\lockpick\functions";

            class preInit { preInit = 1; };
            class postInit { postInit = 1; };

            class doorAction {};
            class doorClass {};
            class doorKey {};
            class doorHelpers {};
            class doorRun {};
            class doors {};
            class drawCutaway {};
            class drawFace {};
            class finish {};
            class hasTool {};
            class isClosed {};
            class isInside {};
            class lockTick {};
            class moduleLock {};
            class nearestDoor {};
            class roll {};
            class rollHouse {};
            class mistake {};
            class onUnload {};
            class press {};
            class refresh {};
            class setStatus {};
            class start {};
            class tick {};
            class tspPick {};
            class unlock {};
            class zeusLock {};
        };
    };
};

#define TLBI_USE_SETTINGS class UseSettings { name = "$STR_tlbi_module_useSettings"; value = -1; }
#define TLBI_LEVELS \
    TLBI_USE_SETTINGS; \
    class VeryEasy { name = "$STR_tlbi_lockpick_level_0"; value = 0; }; \
    class Easy { name = "$STR_tlbi_lockpick_level_1"; value = 1; }; \
    class Normal { name = "$STR_tlbi_lockpick_level_2"; value = 2; }; \
    class Hard { name = "$STR_tlbi_lockpick_level_3"; value = 3; }; \
    class Expert { name = "$STR_tlbi_lockpick_level_4"; value = 4; }

class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class AttributesBase {
            class Default;
            class Edit;
            class Combo;
            class Checkbox;
            class CheckboxNumber;
            class ModuleDescription;
            class Units;
        };
        class ModuleDescription {
            class AnyBrain;
        };
    };

    // Lock settings: every door whose handle is inside the module's area. The
    // lock state is applied at mission start (fn_moduleLock); the rest is read
    // when a lock is picked (fn_start).
    class tlbi_moduleLock: Module_F {
        scope = 2;
        scopeCurator = 0;
        displayName = "$STR_tlbi_lockpick_module_name";
        icon = "\tlbi\addons\main\data\logo_small_ca.paa";
        category = "tlbi_modules";
        function = "tlbi_lockpick_fnc_moduleLock";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        canSetArea = 1;
        canSetAreaShape = 1;
        canSetAreaHeight = 0;

        class AttributeValues {
            size3[] = {3, 3, -1};
            isRectangle = 0;
        };

        class Attributes: AttributesBase {
            class LockState: Combo {
                property = "tlbi_moduleLock_LockState";
                displayName = "$STR_tlbi_lockpick_module_lockState";
                tooltip = "$STR_tlbi_lockpick_module_lockState_tip";
                typeName = "NUMBER";
                defaultValue = "-1";
                class Values {
                    class Leave { name = "$STR_tlbi_lockpick_module_lockState_leave"; value = -1; };
                    class Locked { name = "$STR_tlbi_lockpick_module_lockState_locked"; value = 1; };
                    class Unlocked { name = "$STR_tlbi_lockpick_module_lockState_unlocked"; value = 0; };
                };
            };
            class Pickable: Combo {
                property = "tlbi_moduleLock_Pickable";
                displayName = "$STR_tlbi_lockpick_module_pickable";
                tooltip = "$STR_tlbi_lockpick_module_pickable_tip";
                typeName = "NUMBER";
                defaultValue = "-1";
                class Values {
                    class Yes { name = "$STR_tlbi_module_yes"; value = -1; };
                    class No { name = "$STR_tlbi_module_no"; value = 0; };
                };
            };
            class Technique: Combo {
                property = "tlbi_moduleLock_Technique";
                displayName = "$STR_tlbi_lockpick_module_technique";
                tooltip = "$STR_tlbi_lockpick_module_technique_tip";
                typeName = "NUMBER";
                defaultValue = "-1";
                class Values {
                    class Random { name = "$STR_tlbi_lockpick_module_technique_random"; value = -1; };
                    class Pins { name = "$STR_tlbi_lockpick_module_technique_pins"; value = 0; };
                    class Rake { name = "$STR_tlbi_lockpick_module_technique_rake"; value = 1; };
                    class Dial { name = "$STR_tlbi_lockpick_module_technique_dial"; value = 2; };
                };
            };
            class DoorClass: Combo {
                property = "tlbi_moduleLock_DoorClass";
                displayName = "$STR_tlbi_lockpick_module_doorClass";
                tooltip = "$STR_tlbi_lockpick_module_doorClass_tip";
                typeName = "NUMBER";
                defaultValue = "-1";
                class Values {
                    class Building { name = "$STR_tlbi_lockpick_module_doorClass_building"; value = -1; };
                    class Civilian { name = "$STR_tlbi_lockpick_door_civil"; value = 0; };
                    class Military { name = "$STR_tlbi_lockpick_door_military"; value = 1; };
                    class Reinforced { name = "$STR_tlbi_lockpick_door_reinforced"; value = 2; };
                };
            };
            class KitLevel: Combo {
                property = "tlbi_moduleLock_KitLevel";
                displayName = "$STR_tlbi_lockpick_set_levelKit";
                tooltip = "$STR_tlbi_lockpick_module_level_tip";
                typeName = "NUMBER";
                defaultValue = "-1";
                class Values {
                    TLBI_LEVELS;
                };
            };
            class ClipLevel: Combo {
                property = "tlbi_moduleLock_ClipLevel";
                displayName = "$STR_tlbi_lockpick_set_levelClip";
                tooltip = "$STR_tlbi_lockpick_module_level_tip";
                typeName = "NUMBER";
                defaultValue = "-1";
                class Values {
                    TLBI_LEVELS;
                };
            };
            class ModuleDescription: ModuleDescription {};
        };

        class ModuleDescription: ModuleDescription {
            description = "$STR_tlbi_lockpick_module_desc";
        };
    };
};

#include "gui\dialog.hpp"
