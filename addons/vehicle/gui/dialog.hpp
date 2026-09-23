// The hotwire board: the same field-case chrome as the defusal and lockpicking
// boards, reusing the control styles defined by tlbi_defusal.
//
// Only the chrome lives here. The column, the shroud, its screws and the harness
// are created at runtime by fn_hotwireDraw.

class tlbi_RscText;
class tlbi_RscTextCenter;
class tlbi_RscTextRight;
class tlbi_RscFill;
class tlbi_RscPicture;
class tlbi_RscToolButton;
class tlbi_RscToolButtonDanger;
class RscControlsGroupNoScrollbars;

#define VX(V)  QUOTE((V) * safezoneW + safezoneX)
#define VY(V)  QUOTE((V) * safezoneH + safezoneY)
#define VW(V)  QUOTE((V) * safezoneW)
#define VH(V)  QUOTE((V) * safezoneH)

// Six tool plates across the same width the other boards use.
#define BTN_W  0.095
#define BTN_X(N) VX(0.195 + (N) * 0.103)

class tlbi_RscHotwireBoard {
    idd = IDD_TLBI_HOTWIRE;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "uiNamespace setVariable ['tlbi_vehicle_display', _this select 0]";
    onUnload = "_this call tlbi_vehicle_fnc_hotwireUnload";

    class controlsBackground {
        class Panel: tlbi_RscPicture {
            text = CHROME(panel_co.paa);
            x = VX(0.170); y = VY(0.178); w = VW(0.660); h = VH(0.644);
        };
        class BoardWell: tlbi_RscFill {
            colorBackground[] = {0.02, 0.02, 0.015, 0.85};
            x = VX(0.191); y = VY(0.281); w = VW(0.618); h = VH(0.363);
        };
        class Lcd: tlbi_RscPicture {
            text = CHROME(lcd_co.paa);
            x = VX(0.195); y = VY(0.651); w = VW(0.420); h = VH(0.044);
        };
        class Plate1: tlbi_RscPicture {
            text = CHROME(plate_co.paa);
            colorText[] = {0.60, 0.62, 0.54, 1};
            x = BTN_X(0); y = VY(0.742); w = VW(BTN_W); h = VH(0.052);
        };
        class Plate2: Plate1 { x = BTN_X(1); };
        class Plate3: Plate1 { x = BTN_X(2); };
        class Plate4: Plate1 { x = BTN_X(3); };
        class Plate5: Plate1 { x = BTN_X(4); };
        class PlateClose: Plate1 {
            colorText[] = {0.48, 0.50, 0.44, 1};
            x = BTN_X(5);
        };
    };

    class controls {
        class Title: tlbi_RscText {
            idc = IDC_HW_TITLE;
            font = "PuristaBold";
            sizeEx = "(0.042 * safezoneH)";
            colorText[] = {0.80, 0.66, 0.30, 1};
            shadow = 1;
            x = VX(0.195); y = VY(0.192); w = VW(0.610); h = VH(0.045);
        };
        class Subtitle: tlbi_RscText {
            idc = IDC_HW_SUBTITLE;
            sizeEx = "(0.026 * safezoneH)";
            colorText[] = {0.62, 0.60, 0.53, 1};
            shadow = 1;
            x = VX(0.195); y = VY(0.242); w = VW(0.610); h = VH(0.035);
        };
        // A controls group, so a wire pulled clear of the loom is clipped to the
        // board instead of running over the case.
        class Board: RscControlsGroupNoScrollbars {
            idc = IDC_HW_BOARD;
            x = VX(0.195); y = VY(0.285); w = VW(0.610); h = VH(0.355);
            class Controls {};
        };
        class Readout: tlbi_RscText {
            idc = IDC_HW_READOUT;
            font = "LCD14";
            sizeEx = "(0.030 * safezoneH)";
            colorText[] = {0.10, 0.12, 0.08, 1};
            x = VX(0.206); y = VY(0.652); w = VW(0.400); h = VH(0.042);
        };
        class Stage: tlbi_RscTextRight {
            idc = IDC_HW_STAGE;
            font = "PuristaMedium";
            colorText[] = {0.80, 0.66, 0.30, 1};
            shadow = 1;
            x = VX(0.625); y = VY(0.652); w = VW(0.180); h = VH(0.042);
        };
        class Status: tlbi_RscText {
            idc = IDC_HW_STATUS;
            sizeEx = "(0.026 * safezoneH)";
            colorText[] = {0.62, 0.60, 0.53, 1};
            shadow = 1;
            x = VX(0.195); y = VY(0.700); w = VW(0.610); h = VH(0.034);
        };
        // Progress over the LCD while a timed action runs, hidden otherwise.
        class ProgressFrame: tlbi_RscFill {
            idc = IDC_HW_PROG_FRAME;
            colorBackground[] = {0.05, 0.06, 0.04, 1};
            x = VX(0.206); y = VY(0.658); w = VW(0.400); h = VH(0.030);
            show = 0;
        };
        class ProgressBar: tlbi_RscFill {
            idc = IDC_HW_PROG_BAR;
            colorBackground[] = {0.42, 0.58, 0.26, 1};
            x = VX(0.208); y = VY(0.661); w = VW(0.001); h = VH(0.024);
            show = 0;
        };
        class ProgressText: tlbi_RscTextCenter {
            idc = IDC_HW_PROG_TEXT;
            sizeEx = "(0.024 * safezoneH)";
            colorText[] = {0.86, 0.88, 0.80, 1};
            x = VX(0.206); y = VY(0.658); w = VW(0.400); h = VH(0.030);
            show = 0;
        };
        class BtnA1: tlbi_RscToolButton {
            idc = IDC_HW_BTN_A1;
            x = BTN_X(0); y = VY(0.742); w = VW(BTN_W); h = VH(0.052);
        };
        class BtnA2: BtnA1 { idc = IDC_HW_BTN_A2; x = BTN_X(1); };
        class BtnA3: BtnA1 { idc = IDC_HW_BTN_A3; x = BTN_X(2); };
        class BtnA4: BtnA1 { idc = IDC_HW_BTN_A4; x = BTN_X(3); };
        class BtnA5: tlbi_RscToolButtonDanger {
            idc = IDC_HW_BTN_A5;
            x = BTN_X(4); y = VY(0.742); w = VW(BTN_W); h = VH(0.052);
        };
        class BtnClose: tlbi_RscToolButton {
            idc = IDC_HW_BTN_CLOSE;
            text = "$STR_tlbi_vehicle_btn_back";
            x = BTN_X(5); y = VY(0.742); w = VW(BTN_W); h = VH(0.052);
        };
    };
};
