// loose_end_86.scad: Loose End fuselage with FreeWing 80mm F-86 wings and 29mm MMT

// TODO:
// decide hatch height

include <../loose_end.scad>

MOTOR_D = 38;
MMT_OD = 31;
MMT_ID = 29.1;
SPAR_D = 10.1;

WING_AIRFOIL = 2413;        // actual thickness of F-86 wing
FUSELAGE_L = 600;
FUSELAGE_THICKNESS = .15;   // thicker section to maintain height with shorter fuselage

FUSELAGE_W = 124;           // wider to accommodate potential retracts

ROOT_CHORD = 320;
TIP_CHORD = 157;
ELEVON_CHORD = .25;
LE_SWEEP = 16*25.4;
PANEL_SPAN = 21*25.4;
SPAR_C_ROOT = 180;

WING_TANGS = [65, 260];

SERVO_WIRE_TUNNEL_EXIT = 164;

// I omit servo pockets--they already exist in the foam
SERVO_X = [];
SERVO_Y = [];
SERVO_TYPE = [];


FUSELAGE_PARTITIONS = [HATCH_F-10,          // fwd of hatch
                       HATCH_F+HATCH_L+10,  // aft of hatch
                       SPAR_C-SPAR_D,       // fwd of carrythrough
                       SPAR_C+SPAR_D        // aft of carrythrough
                       ];
