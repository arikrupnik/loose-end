// loose_end_rj.scad: Loose End fuselage with RadJet wings and 24mm MMT

include <../loose_end.scad>

MOTOR_D = 24;
MMT_OD = 25.6;
MMT_ID = 23.7;
SPAR_D = 5.5;

WING_AIRFOIL = 0012;        // actual thickness of RJ wings
FUSELAGE_L = MOTOR_D * 18;  // shorter fuselage for CG
FUSELAGE_THICKNESS = .15;   // thicker section to maintain height with shorter fuselage

ROOT_CHORD = 203;
TIP_CHORD = 93;
LE_SWEEP = 62;
SPAR_C_ROOT = 63;
PANEL_SPAN = 315;

SERVO_WIRE_TUNNEL_EXIT = 45;

// I omit servo pockets--they already exist in the foam
SERVO_X = [];
SERVO_Y = [];
SERVO_TYPE = [];
