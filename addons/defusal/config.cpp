#include "script_component.hpp"
#include "..\main\script_version.hpp"

#define VERSION_STR MAJOR.MINOR.PATCHLVL.BUILD
#define VERSION_AR MAJOR,MINOR,PATCHLVL,BUILD

class CfgPatches {
    class tlbi_defusal {
        name = "TLB Interactions - Interactive Defusal";
        author = "TLB";
        url = "";
        units[] = {"tlbi_moduleExplosive"};
        weapons[] = {};
        requiredVersion = 2.02;
        requiredAddons[] = {"tlbi_main", "cba_main", "ace_explosives", "ace_interact_menu", "A3_Modules_F"};
        version = VERSION_STR;
        versionStr = QUOTE(VERSION_STR);
        versionAr[] = {VERSION_AR};
        skipWhenMissingDependencies = 1;
    };
};

class CfgFunctions {
    class tlbi_defusal {
        tag = "tlbi_defusal";

        class defusal {
            file = "tlbi\addons\defusal\functions";

            // Init runs through CfgFunctions rather than CBA's
            // Extended_*_EventHandlers: it is engine-native, needs no
            // hand-written pbo path, and cannot fail silently the way a
            // preprocessFileLineNumbers on a mistyped path does.
            class preInit { preInit = 1; };
            class postInit { postInit = 1; };

            class action {};
            class autoClear {};
            class brushDirt {};
            class classify {};
            class cutTape {};
            class cutWire {};
            class drawBoard {};
            class explosiveValue {};
            class findExplosive {};
            class hybridBar {};
            class isIndoors {};
            class keyMatches {};
            class keyName {};
            class mineCell {};
            class mineDraw {};
            class mineGenerate {};
            class mineRefresh {};
            class mineTool {};
            class moduleExplosive {};
            class moduleValue {};
            class seatPin {};
            class steadyPin {};
            class tripCut {};
            class tripDraw {};
            class tripGenerate {};
            class tripRefresh {};
            class tripSelect {};
            class tripTension {};
            class tripTuft {};
            class zeusExplosive {};
            class fail {};
            class generatePuzzle {};
            class onBoardUnload {};
            class openBoard {};
            class probeWire {};
            class refreshBoard {};
            class runAction {};
            class selectWire {};
            class setStatus {};
            class startDefuse {};
            class succeed {};
        };
    };
};

// NOTE: do not patch ACE's ACE_DefuseObject / ACE_DefuseObject_Large in
// CfgVehicles to redirect the defuse statement. Re-opening those classes from a
// separate addon drops members they inherit (scope, side, ...) and the engine
// then throws "No entry ... .side" on any mission load. fn_postInit swaps the
// defuse interaction at runtime instead. The module below is our own class.

class CfgFactionClasses {
    class tlbi_modules {
        displayName = "$STR_tlbi_module_category";
        priority = 2;
        side = 7;
    };
};

#define TLBI_USE_SETTINGS class UseSettings { name = "$STR_tlbi_module_useSettings"; value = -1; }

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

    // Explosive settings: overrides for every explosive inside the module's area.
    // Read when a board opens (fn_moduleValue), so it also covers explosives
    // placed later in the mission.
    class tlbi_moduleExplosive: Module_F {
        scope = 2;
        scopeCurator = 0;
        displayName = "$STR_tlbi_defusal_module_name";
        icon = "\tlbi\addons\main\data\logo_small_ca.paa";
        category = "tlbi_modules";
        function = "tlbi_defusal_fnc_moduleExplosive";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        canSetArea = 1;
        canSetAreaShape = 1;
        canSetAreaHeight = 0;

        class AttributeValues {
            size3[] = {5, 5, -1};
            isRectangle = 0;
        };

        class Attributes: AttributesBase {
            class Procedure: Combo {
                property = "tlbi_moduleExplosive_Procedure";
                displayName = "$STR_tlbi_defusal_module_procedure";
                tooltip = "$STR_tlbi_defusal_module_procedure_tip";
                typeName = "NUMBER";
                defaultValue = "-1";
                class Values {
                    class Automatic { name = "$STR_tlbi_defusal_module_procedure_auto"; value = -1; };
                    class Ied { name = "$STR_tlbi_defusal_module_procedure_ied"; value = 0; };
                    class Mine { name = "$STR_tlbi_defusal_module_procedure_mine"; value = 1; };
                    class Trip { name = "$STR_tlbi_defusal_module_procedure_trip"; value = 2; };
                };
            };
            class Difficulty: Combo {
                property = "tlbi_moduleExplosive_Difficulty";
                displayName = "$STR_tlbi_defusal_set_difficulty";
                tooltip = "$STR_tlbi_defusal_module_difficulty_tip";
                typeName = "NUMBER";
                defaultValue = "-1";
                class Values {
                    TLBI_USE_SETTINGS;
                    class Easy { name = "$STR_tlbi_difficulty_easy"; value = 0; };
                    class Normal { name = "$STR_tlbi_difficulty_normal"; value = 1; };
                    class Hard { name = "$STR_tlbi_difficulty_hard"; value = 2; };
                    class Expert { name = "$STR_tlbi_difficulty_expert"; value = 3; };
                };
            };
            class Buried: Combo {
                property = "tlbi_moduleExplosive_Buried";
                displayName = "$STR_tlbi_defusal_module_buried";
                tooltip = "$STR_tlbi_defusal_module_buried_tip";
                typeName = "NUMBER";
                defaultValue = "-1";
                class Values {
                    TLBI_USE_SETTINGS;
                    class Yes { name = "$STR_tlbi_defusal_module_buried_yes"; value = 1; };
                    class No { name = "$STR_tlbi_defusal_module_buried_no"; value = 0; };
                };
            };
            class Grass: Combo {
                property = "tlbi_moduleExplosive_Grass";
                displayName = "$STR_tlbi_defusal_module_grass";
                tooltip = "$STR_tlbi_defusal_module_grass_tip";
                typeName = "NUMBER";
                defaultValue = "-1";
                class Values {
                    TLBI_USE_SETTINGS;
                    class Yes { name = "$STR_tlbi_defusal_module_grass_yes"; value = 1; };
                    class No { name = "$STR_tlbi_defusal_module_grass_no"; value = 0; };
                };
            };
            class Branch: Combo {
                property = "tlbi_moduleExplosive_Branch";
                displayName = "$STR_tlbi_defusal_module_branch";
                tooltip = "$STR_tlbi_defusal_module_branch_tip";
                typeName = "NUMBER";
                defaultValue = "-1";
                class Values {
                    TLBI_USE_SETTINGS;
                    class Always { name = "$STR_tlbi_defusal_module_branch_always"; value = 1; };
                    class Never { name = "$STR_tlbi_defusal_module_branch_never"; value = 0; };
                };
            };
            class AutoClear: Combo {
                property = "tlbi_moduleExplosive_AutoClear";
                displayName = "$STR_tlbi_defusal_set_autoClear";
                tooltip = "$STR_tlbi_defusal_module_autoClear_tip";
                typeName = "NUMBER";
                defaultValue = "-1";
                class Values {
                    TLBI_USE_SETTINGS;
                    class On { name = "$STR_tlbi_module_on"; value = 1; };
                    class Off { name = "$STR_tlbi_module_off"; value = 0; };
                };
            };
            class ModuleDescription: ModuleDescription {};
        };

        class ModuleDescription: ModuleDescription {
            description = "$STR_tlbi_defusal_module_desc";
        };
    };
};

#include "gui\defines.hpp"
#include "gui\dialog.hpp"
