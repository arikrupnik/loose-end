// parameters.inc: base set of parametrs for Loose End series of
// gliders; derivative models can override these variables to achieve
// different configurations and sizes

// nominal motor size; most dimensions depend on this value
MOTOR_D = 24;
// other dimensions that need explicit vales
MMT_OD = 25.6;            // actual OD of motor mount
SPAR_D = 6;               // actual diameter of wing spar
FUSELAGE_THICKNESS = .14; // fuselage shape (implies 0 camber)
WING_AIRFOIL=0014;        // wing section
SHEET_THICKNESS = 1.6;    // 2D parts: fins, wing tangs
EXTRUSION_W = .45;        // extrusion width

// pitot tube
PITOT_TUBE_D = 4.2;       // pitot tube diameter
PITOT_TUBE_L = 35;        // part of pitot tube that can embed in solid fuselage

// derived dimensions: fuselage
FUSELAGE_W = MOTOR_D*3;  // print volume on MK3S: 250mm
FUSELAGE_L = MOTOR_D*20;
FUSELAGE_H = FUSELAGE_L*FUSELAGE_THICKNESS;
THRUST_PLATE_OFFSET = FUSELAGE_L*.18;  // how far forward motor thust plate is of trailing edge
// cockpit & hatch
COCKPIT_H=FUSELAGE_H*.6;
HATCH_F = FUSELAGE_L*.15;  // front
HATCH_L = FUSELAGE_L*.25;  // length
HATCH_W = FUSELAGE_W*.7;   // width

// derived dimensions: wing
WINGSPAN   = MOTOR_D*35;  // constraint: launcher outrigger span is 31"
ROOT_CHORD = MOTOR_D*10;
TIP_CHORD  = ROOT_CHORD*.5;
LE_SWEEP   = ROOT_CHORD-TIP_CHORD;  // straight trailing edge
PANEL_SPAN =(WINGSPAN-FUSELAGE_W)/2;
// wing spar center--close to tip LE
SPAR_C_ROOT = LE_SWEEP + TIP_CHORD*.1; // relative to root LE
SPAR_C      = FUSELAGE_L - ROOT_CHORD + SPAR_C_ROOT;  // relative to fuselage LE

// wing attachment points
WING_TANG_L  = 20;
WING_TANG_W  = 10;
WING_SCREW_D =  3;  // clearance hole
WING_SCREW_L = 12;  // thread length
WING_TANGS   = [for (p=[.1, .7]) ROOT_CHORD*p]; // wing attachment points, relative to root LE

// servo wire tunnels
SERVO_WIRE_TUNNEL_D = 12;
SERVO_WIRE_TUNNEL_EXIT = ROOT_CHORD*.5; // relative to root LE

// scribe lines
SCRIBE_LINE_W = .3;  // stroke width

// interference between parts
EPSILON = 0.01;
// smallest gap between parts that a slicer recognizes as separate geometries
CUT_WIDTH = 0.1;
