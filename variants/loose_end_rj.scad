// loose_end_rj.scad: Loose End fuselage with RadJet wings and 24mm MMT

include <../loose_end.scad>

MOTOR_D = 24;
MMT_OD = 25.6;
SPAR_D = 5.5;

FUSELAGE_THICKNESS = .15;
WING_AIRFOIL = 0012;
FUSELAGE_L = MOTOR_D * 16;
THRUST_PLATE_OFFSET = FUSELAGE_L*.21;

ROOT_CHORD = 203;
TIP_CHORD = 93;
LE_SWEEP = 62;
SPAR_C_ROOT = 63;
PANEL_SPAN = 315;

SERVO_WIRE_TUNNEL_EXIT = 45;
