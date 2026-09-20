#include "script_component.hpp"
#include "..\main\script_version.hpp"

#define VERSION_STR MAJOR.MINOR.PATCHLVL.BUILD
#define VERSION_AR MAJOR,MINOR,PATCHLVL,BUILD

class CfgPatches {
    class tlbi_vehicle {
        name = "TLB Interactions - Vehicles";
        author = "TLB";
        url = "";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.02;
        // tlbi_lockpick provides the lockpicking board this addon sends vehicle
        // locks to, and its tool handling; ace_vehiclelock the lock actions that
        // are swapped at postInit.
        requiredAddons[] = {"A3_Ui_F", "tlbi_main", "tlbi_defusal", "tlbi_lockpick", "cba_main", "ace_common", "ace_interact_menu", "ace_interaction", "ace_vehiclelock"};
        version = VERSION_STR;
        versionStr = QUOTE(VERSION_STR);
        versionAr[] = {VERSION_AR};
        skipWhenMissingDependencies = 1;
    };
};

class CfgFunctions {
    class tlbi_vehicle {
        tag = "tlbi_vehicle";

        class vehicle {
            file = "tlbi\addons\vehicle\functions";

            class preInit { preInit = 1; };
            class postInit { postInit = 1; };

            class hasAccess {};
            class alarm {};
            class canHotwire {};
            class canPick {};
            class harness {};
            class hasTool {};
            class hotwireAction {};
            class hotwireDraw {};
            class hotwireFinish {};
            class hotwireJoin {};
            class hotwirePress {};
            class hotwireReadout {};
            class hotwireRefresh {};
            class hotwireRun {};
            class hotwireStart {};
            class hotwireStatus {};
            class hotwireTick {};
            class hotwireUnload {};
            class hotwired {};
            class lockClass {};
            class notify {};
            class onEngine {};
            class owns {};
            class pick {};
            class picking {};
            class pickActions {};
            class pickTools {};
            class picked {};
            class short {};
            class vehicleName {};
        };
    };
};

#include "gui\dialog.hpp"
