// =============================================================================
// Huawei 3.7" Color E-Ink Desktop Frame & iPod-Style Dock (V1)
// =============================================================================
// References:
//   - huawei_eink/reference/XZ.SLDPRT & exported STLs (standard, lanyard, 0.3mm acrylic)
//   - Original frame: 68.0 x 95.84 x 4.6 mm (101.6 mm w/ lanyard, +0.3 mm w/ acrylic)
//
// Customizations for this build:
//   1. Replaces magnetic pogo connector with 2x 4-pin 2.54mm straight female
//      headers (10.7 x 2.4 x 8.4 mm) on the bottom edge (opposite the PCB).
//   2. Asymmetric header placement (world X = -17 mm, +11 mm) prevents reverse
//      insertion into the dock.
//   3. Local internal relief accommodates the 1.5 mm protruding PCB + 8x 0.5 mm
//      OK wires while keeping total shell thickness ultra-slim (6.4 mm default).
//   4. Parametric options:
//        - enable_lanyard_hole = true   (default ON: +5.8 mm top bar w/ 15.2 x 3.2 mm badge slot)
//        - enable_acrylic      = false  (default OFF: adds +0.35 mm cavity depth for 0.3 mm acrylic)
//   5. Classic Apple iPod-style angled desktop dock (15 deg tilt) housing an
//      ESP32-C3 SuperMini / Mini Pro (22.5 x 18.0 mm) with rear USB-C cutout and
//      matching asymmetric 2x 4-pin male pin header glue-in slots.
//   6. All 4 printable parts are 100% support-free on Z = 0.
//
// Units: mm | Recommended material: PETG (0.4 mm nozzle, 0.20 mm layer height)
// =============================================================================

part = "assembly"; // "case_front" | "case_back" | "dock_body" | "dock_bottom" | "assembly" | "assembly_cutaway"

// -----------------------------------------------------------------------------
// User Parametric Toggles
// -----------------------------------------------------------------------------
enable_lanyard_hole = true;   // ON by default: adds badge lanyard slot at top (+Y)
enable_acrylic      = false;  // OFF by default: adds clearance for 0.3 mm acrylic sheet

$fn = 48;

// -----------------------------------------------------------------------------
// 1. E-Ink Panel & PCB Dimensions (measured by user + reference STLs)
// -----------------------------------------------------------------------------
screen_w        = 63.6;   // E-ink glass/module width (X)
screen_h        = 91.0;   // E-ink glass/module length (Y)
screen_t        = 1.2;    // E-ink module thickness
screen_r        = 4.0;    // E-ink corner radius
screen_clear    = 0.25;   // Per-side clearance for PETG

acrylic_t       = enable_acrylic ? 0.35 : 0.0; // 0.3 mm sheet + 0.05 mm margin

pcb_protrude    = 1.5;    // Green PCB protrudes ~1.5 mm on one side near top (+Y)
pcb_zone_h      = 34.0;   // Height of PCB zone from top edge of screen
pcb_clear       = 0.35;   // Extra clearance for PCB protrusion
// Note: In Photo 3 (front view, FPC at top), PCB protrudes on viewer's RIGHT (+X world).
// Because case_front is printed face-down and rotated [90, 0, 180] into world pose,
// viewer's RIGHT (+X world) corresponds to local -X in case_front!
pcb_local_side  = -1;     // -1 = local -X (becomes +X right in front view)

// Top FPC fold relief (centered at +Y top edge of screen pocket)
fpc_relief_w    = 22.0;   // Width of FPC bend clearance pocket
fpc_relief_d    = 1.4;    // Extra depth into top wall (+Y) for FPC fold radius

// Front viewing window (from XZ.SLDPRT active area: 57.8 x 81.6 mm)
// FPC + PCB is at +Y (top), so top bezel is wider and bottom bezel is thin.
win_w           = 57.8;
win_h           = 81.6;
win_r           = 3.5;
win_y_offset    = -3.1;   // Matches XZ.SLDPRT active area offset away from top FPC border

// Badge lanyard slot (measured from reference lanyard STL: +5.76 mm, 15.2 x 3.2 mm slot)
lanyard_ext     = enable_lanyard_hole ? 5.8 : 0.0;
lanyard_slot_w  = 15.2;
lanyard_slot_h  = 3.2;
lanyard_top_bar = 3.0;    // Solid material above lanyard slot

// -----------------------------------------------------------------------------
// 2. 2x 4-Pin 2.54mm Straight Female / Male Header Parameters
// -----------------------------------------------------------------------------
hdr_f_len       = 10.7;   // Female header length (X)
hdr_f_w         = 2.4;    // Female header width/thickness (Z in shell)
hdr_f_depth     = 8.4;    // Female header plastic body depth (Y into shell)
hdr_fit_clear   = 0.25;   // Glue-in slip clearance

hdr_slot_len    = hdr_f_len + hdr_fit_clear;   // 10.95 mm
hdr_slot_w      = hdr_f_w   + hdr_fit_clear;   // 2.65 mm
hdr_pocket_d    = hdr_f_depth + 0.3;           // 8.7 mm

// Asymmetric WORLD X centers (viewed from front of dock) -> prevents reverse insertion!
// Mirroring -17 -> +17 (6 mm off from +11), +11 -> -11 (6 mm off from -17)
hdr_x1          = -17.0;
hdr_x2          = +11.0;

// Male header insulator slot in dock floor (standard 2.54mm 1x4 pin header)
hdr_m_slot_len  = 10.6;   // 10.16 mm plastic + clearance
hdr_m_slot_w    = 2.85;   // 2.54 mm plastic + clearance

// -----------------------------------------------------------------------------
// 3. E-Ink Shell Parameters (XZ.SLDPRT inspired, ultra-thin 6.4 mm default)
// -----------------------------------------------------------------------------
case_w          = 70.6;   // Outer width (leaves ~1.4 mm wall even at 1.85 mm PCB relief)
case_h_base     = 97.6;   // Base height without lanyard extension (allows top FPC bend relief)
case_h_total    = case_h_base + lanyard_ext;
case_r          = 5.5;    // Outer corner radius
case_chamfer    = 0.6;    // Front/back perimeter chamfer

front_face_t    = 0.8;    // Front bezel thickness (4 layers @ 0.2mm)
behind_screen_t = 3.2;    // Space behind e-ink for PCB + OK wires + 2.4mm headers
cavity_depth    = screen_t + acrylic_t + behind_screen_t; // 4.4 mm (4.75 mm w/ acrylic)
back_plate_t    = 1.2;    // Back cover plate thickness
case_t          = front_face_t + cavity_depth + back_plate_t; // 6.4 mm (6.75 mm w/ acrylic)

// Back cover nesting rabbet & glue-free PETG snap-fits
rim_wall        = 1.3;    // Outer rim thickness around back cover
back_clear      = 0.20;   // PETG fit clearance per side
back_w          = case_w - 2 * rim_wall - 2 * back_clear;
back_h          = case_h_base - 2 * rim_wall - 2 * back_clear;
back_r          = max(1.5, case_r - rim_wall - back_clear);

// Shell snap-fit clip parameters (6 clips: 4 on long sides + 2 on top edge, 45-deg support-free)
snap_w          = 7.0;    // Width of each snap tab
snap_t          = 1.0;    // Flex arm thickness (ideal for PETG)
snap_h          = 3.4;    // Arm height rising from back_plate_t
snap_barb       = 0.45;   // Outward 45-deg catch barb (flexes easily in PETG, leaves >=1.2 mm outer wall)
snap_inset      = 0.30;   // Inward inset from back_w/2 so outer wall stays >=1.2 mm (3 perimeters)
snap_side_ys    = [-26.0, 4.0];   // Long-side clip Y positions (clear of PCB & headers)
snap_top_xs     = [-20.0, 20.0];  // Top-edge clip X positions (clear of 22 mm FPC relief)

// Header Z center measured from shell FRONT face (Z=0) toward BACK face (Z=case_t)
// Sits flush against inside of back cover (Z = front_face_t + cavity_depth)
hdr_z_center    = front_face_t + cavity_depth - hdr_slot_w / 2; // 3.875 mm default

// -----------------------------------------------------------------------------
// 4. iPod-Style Angled Desktop Dock Parameters (Apple iPod Universal Dock look)
// -----------------------------------------------------------------------------
dock_w_bot      = 86.0;   // Base width (X)
dock_d_bot      = 62.0;   // Base depth (Y, front-to-back)
dock_w_top      = 84.0;   // Subtle near-vertical iPod Dock sides (1 mm draft/side)
dock_d_top      = 60.0;   // Subtle near-vertical sides
dock_h          = 17.2;   // Low-profile iPod dock height -> 100% of active screen exposed!
dock_r_bot      = 11.0;   // Classic Apple rounded corner radius
dock_r_top      = 10.5;   // Top corner radius

dock_tilt       = 15.0;   // Backward viewing tilt angle (degrees)
well_clear_xy   = 0.35;   // Per-side slip clearance for smooth one-hand docking
well_w          = case_w + 2 * well_clear_xy;  // 71.3 mm
well_t          = case_t + 2 * well_clear_xy;  // 7.1 mm (auto-adjusts w/ acrylic!)
well_depth      = 5.0;    // Shallow cradle well (~4.3 mm front / ~6.0 mm back) -> full screen visible
well_floor_z    = 12.2;   // Height of well floor center above Z = 0
well_y_center   = -14.0;  // Forward-shifted like real Apple iPod Dock (sleek ~12 mm front lip, spacious rear deck!)
well_floor_t    = 2.6;    // Thickness of tilted floor holding the male pin headers

// ESP32-C3 Mini Pro dimensions (measured from user's board: 25.5 x 18.0 x 4.5 mm)
esp_len         = 25.5;   // Along Y (USB-C facing rear +Y)
esp_w           = 18.0;   // Along X
esp_clear       = 0.30;   // Fit clearance
esp_rail_h      = 2.6;    // Holding rail height on dock_bottom
esp_rail_t      = 1.6;    // Holding rail wall thickness

// Sleek rear USB-C port window (just exposes the 9.0 x 3.2 mm Type-C port cleanly!)
usbc_w          = 11.4;   // Compact rounded-rect port window width
usbc_h          = 5.0;    // Compact rounded-rect port window height
usbc_z_center   = 5.2;    // Center Z of ESP32 USB-C port (dock_bot_t 2.0 + PCB 1.6 + port 1.6)

// Dock bottom cover plate (with 4 glue-free PETG snap-fits)
dock_bot_t      = 2.0;    // Bottom plate thickness
dock_bot_inset  = 3.2;    // Perimeter wall around recessed bottom cover
dock_bot_clear  = 0.22;   // PETG fit clearance
dock_snap_ys    = [-12.0, 10.0]; // Left/right snap-fit positions on dock_bottom

// -----------------------------------------------------------------------------
// Helper Modules
// -----------------------------------------------------------------------------
module rrect2d(w, h, r) {
    r_clamped = min(r, min(w, h) / 2 - 0.01);
    offset(r = r_clamped)
        square([w - 2 * r_clamped, h - 2 * r_clamped], center = true);
}

// Stadium (pill) 2D slot for lanyard hole
module stadium2d(w, h) {
    r = min(w, h) / 2;
    offset(r = r)
        square([max(0.01, w - 2 * r), max(0.01, h - 2 * r)], center = true);
}

// Extruded rounded rectangle with optional bottom & top 45-deg chamfers
module rbox(w, h, t, r, ch_bot = 0, ch_top = 0) {
    if (ch_bot <= 0 && ch_top <= 0) {
        linear_extrude(height = t) rrect2d(w, h, r);
    } else {
        hull() {
            if (ch_bot > 0) {
                linear_extrude(height = 0.01)
                    rrect2d(w - 2 * ch_bot, h - 2 * ch_bot, max(0.5, r - ch_bot));
                translate([0, 0, ch_bot])
                    linear_extrude(height = 0.01) rrect2d(w, h, r);
            } else {
                linear_extrude(height = 0.01) rrect2d(w, h, r);
            }
            if (ch_top > 0) {
                translate([0, 0, t - ch_top])
                    linear_extrude(height = 0.01) rrect2d(w, h, r);
                translate([0, 0, t - 0.01])
                    linear_extrude(height = 0.01)
                        rrect2d(w - 2 * ch_top, h - 2 * ch_top, max(0.5, r - ch_top));
            } else {
                translate([0, 0, t - 0.01])
                    linear_extrude(height = 0.01) rrect2d(w, h, r);
            }
        }
    }
}

// Tapered iPod-style outer shell (hull of bottom & top rounded rects with top bevel)
module dock_outer_solid(inset = 0, z0 = 0, z1 = dock_h, top_bevel = 2.0, bot_chamfer = 0.8) {
    w0 = dock_w_bot - 2 * inset;
    d0 = dock_d_bot - 2 * inset;
    r0 = max(1.0, dock_r_bot - inset);
    w1 = dock_w_top - 2 * inset;
    d1 = dock_d_top - 2 * inset;
    r1 = max(1.0, dock_r_top - inset);

    hull() {
        if (bot_chamfer > 0) {
            translate([0, 0, z0])
                linear_extrude(height = 0.01)
                    rrect2d(w0 - 2 * bot_chamfer, d0 - 2 * bot_chamfer, max(0.5, r0 - bot_chamfer));
            translate([0, 0, z0 + bot_chamfer])
                linear_extrude(height = 0.01) rrect2d(w0, d0, r0);
        } else {
            translate([0, 0, z0])
                linear_extrude(height = 0.01) rrect2d(w0, d0, r0);
        }
        if (top_bevel > 0) {
            translate([0, 0, z1 - top_bevel])
                linear_extrude(height = 0.01) rrect2d(w1, d1, r1);
            translate([0, 0, z1 - 0.01])
                linear_extrude(height = 0.01)
                    rrect2d(w1 - 2 * top_bevel, d1 - 2 * top_bevel, max(0.5, r1 - top_bevel));
        } else {
            translate([0, 0, z1 - 0.01])
                linear_extrude(height = 0.01) rrect2d(w1, d1, r1);
        }
    }
}

// Support-free 45-deg cantilever snap-fit clip (extends +Z from Z=0, barb protrudes +X)
module snap_clip_x(w, t, h, barb) {
    // 2D cross-section in XZ, extruded along Y (centered)
    rotate([90, 0, 0])
        linear_extrude(height = w, center = true)
            polygon([
                [0, 0],
                [t, 0],
                [t, h - 2 * barb - 0.3],
                [t + barb, h - barb - 0.3],
                [t + barb, h - barb],
                [t, h],
                [0, h]
            ]);
}

// Matching support-free snap-catch pocket (cuts into +X wall; 45-deg roof/floor)
// In case_front (printed face-down), clip enters from +Z toward -Z, so Z is inverted relative to clip!
module snap_pocket_x(w, depth, h_arm, barb, clear = 0.25) {
    // Centered in Y, X=0 is inner wall face, cuts into +X by (depth + clear)
    // Z=0 is the rabbet step where the clip base sits; clip tip reaches Z = -h_arm
    z_barb_mid = -(h_arm - barb - 0.15);
    pz_half = barb + 0.35;
    rotate([90, 0, 0])
        linear_extrude(height = w + 2 * clear, center = true)
            polygon([
                [-0.8, z_barb_mid - pz_half],
                [depth + clear, z_barb_mid - pz_half + (depth + clear) * 0.45],
                [depth + clear, z_barb_mid + pz_half - (depth + clear) * 0.45],
                [-0.8, z_barb_mid + pz_half]
            ]);
}

// =============================================================================
// PART 1: E-Ink Front Frame (case_front)
// Print orientation: Face-down on Z = 0 (100% support-free!)
// Note: Bottom edge is fixed at Y = -case_h_base/2; lanyard extends +Y top only.
// =============================================================================
module case_front() {
    pkt_w = screen_w + 2 * screen_clear;
    pkt_h = screen_h + 2 * screen_clear;
    rabbet_w = case_w - 2 * rim_wall;
    rabbet_h = case_h_base - 2 * rim_wall;
    rabbet_r = max(1.5, case_r - rim_wall);

    // Center of outer body shifts +lanyard_ext/2 so bottom edge stays at -case_h_base/2
    outer_y_shift = lanyard_ext / 2;
    rabbet_z = front_face_t + cavity_depth;

    difference() {
        // Outer body with front & back chamfers
        translate([0, outer_y_shift, 0])
            rbox(case_w, case_h_total, case_t, case_r, ch_bot = case_chamfer, ch_top = case_chamfer);

        // 1. Front viewing window cutout (through front face)
        translate([0, win_y_offset, -0.5])
            linear_extrude(height = front_face_t + 1.0)
                rrect2d(win_w, win_h, win_r);

        // Subtle inner chamfer on front bezel window
        translate([0, win_y_offset, -0.01])
            hull() {
                linear_extrude(height = 0.01) rrect2d(win_w + 0.6, win_h + 0.6, win_r + 0.3);
                translate([0, 0, 0.35])
                    linear_extrude(height = 0.01) rrect2d(win_w, win_h, win_r);
            }

        // 2. Main screen & wiring cavity (from front_face_t up to case_t + 1)
        translate([0, 0, front_face_t])
            linear_extrude(height = cavity_depth + back_plate_t + 1.0)
                rrect2d(pkt_w, pkt_h, screen_r + screen_clear);

        // 3. Local PCB protrusion relief near +Y (top) end
        // Starts behind e-ink glass (+ optional acrylic) so front bezel stays strong
        pcb_rel_w = pcb_protrude + pcb_clear + 2.0;
        pcb_rel_x = (pcb_local_side > 0)
            ? (pkt_w / 2 - 2.0)
            : (-pkt_w / 2 - pcb_protrude - pcb_clear);
        translate([pcb_rel_x, pkt_h / 2 - pcb_zone_h, front_face_t + screen_t + acrylic_t - 0.1])
            cube([pcb_rel_w, pcb_zone_h - 1.5, cavity_depth + back_plate_t + 1.0]);

        // 3b. Top FPC ribbon fold relief (centered at +Y top edge of screen pocket)
        translate([-fpc_relief_w / 2, pkt_h / 2 - 1.0, front_face_t + 0.5])
            cube([fpc_relief_w, fpc_relief_d + 1.0, cavity_depth + back_plate_t + 1.0]);

        // 4. Perimeter rabbet for case_back (always aligned to base frame!)
        translate([0, 0, rabbet_z])
            linear_extrude(height = back_plate_t + 1.0)
                rrect2d(rabbet_w, rabbet_h, rabbet_r);

        // 4b. Seamless hidden snap-fit clearance channels & catch pockets (4 side + 2 top)
        // Inset by snap_inset so outer wall stays >=1.2 mm (3 perimeters, invisible outside)
        for (sx = [-1, 1]) {
            for (sy = snap_side_ys) {
                translate([sx * (back_w / 2 - snap_inset - snap_t / 2), sy, rabbet_z - snap_h / 2 - 0.2])
                    cube([snap_t + 0.45, snap_w + 0.6, snap_h + 0.6], center = true);
                translate([sx * (back_w / 2 - snap_inset), sy, rabbet_z])
                    scale([sx, 1, 1])
                        snap_pocket_x(snap_w, snap_barb, snap_h, snap_barb, clear = 0.18);
            }
        }
        // Top-edge clips at X = ±20 mm (clear of central 22 mm FPC relief)
        for (tx = snap_top_xs) {
            translate([tx, back_h / 2 - snap_inset - snap_t / 2, rabbet_z - snap_h / 2 - 0.2])
                cube([snap_w + 0.6, snap_t + 0.45, snap_h + 0.6], center = true);
            translate([tx, back_h / 2 - snap_inset, rabbet_z])
                rotate([0, 0, 90])
                    snap_pocket_x(snap_w, snap_barb, snap_h, snap_barb, clear = 0.18);
        }

        // 5. Asymmetric 2x 4-pin female header slots on -Y bottom wall
        // Local X = -hdr_x1, -hdr_x2 so after rotate([90,0,180]) they align with world hdr_x1, hdr_x2!
        // Open up to Z = case_t + 1 -> ZERO overhang when printed face-down; case_back closes Z > 5.2!
        for (hx = [-hdr_x1, -hdr_x2]) {
            translate([hx - hdr_slot_len / 2, -case_h_base / 2 - 1.0, hdr_z_center - hdr_slot_w / 2])
                cube([hdr_slot_len, (case_h_base - pkt_h) / 2 + 2.0, case_t - (hdr_z_center - hdr_slot_w / 2) + 1.0]);
        }

        // 6. Optional badge lanyard slot at +Y top bar
        if (enable_lanyard_hole) {
            lanyard_y = case_h_base / 2 + lanyard_ext - lanyard_top_bar - lanyard_slot_h / 2;
            translate([0, lanyard_y, -0.5])
                linear_extrude(height = case_t + 1.0)
                    stadium2d(lanyard_slot_w, lanyard_slot_h);
        }
    }
}

// =============================================================================
// PART 2: E-Ink Back Cover (case_back)
// Print orientation: Back-face-down on Z = 0 (100% support-free!)
// Features:
//   - 6 integrated glue-free PETG cantilever snap-fit clips (4 side + 2 top)
//   - Integrated glue-in locating cradles for the 2x 4-pin female headers
// =============================================================================
module case_back() {
    // Assembled onto case_front via: translate([0, 0, case_t]) rotate([180, 0, 0])
    // Under rotate([180, 0, 0]): local (x, y, z) -> case_front (x, -y, case_t - z)
    // So in local coords of case_back:
    //   - Header edge (-Y in case_front) is at local +Y = +back_h/2
    //   - Top edge (+Y in case_front) is at local -Y = -back_h/2
    //   - Side clip Ys are -snap_side_ys!

    cradle_wall = 1.0;
    cradle_h    = hdr_slot_w; // 2.65 mm tall walls rising from Z = back_plate_t
    // Keep cradle walls strictly inside case_front's screen cavity (clear of case_front's bottom wall!)
    pkt_h_half   = (screen_h + 2 * screen_clear) / 2;       // 45.75 mm
    cradle_y_top = pkt_h_half - 0.35;                       // 45.40 mm (0.35 mm clear of bottom wall)
    cradle_y_bot = case_h_base / 2 - hdr_pocket_d;          // 48.8 - 8.7 = 40.1 mm
    cradle_y_len = cradle_y_top - cradle_y_bot;             // 5.3 mm cradling inside cavity

    union() {
        // Main flat back plate (nests inside case_front's rabbet)
        difference() {
            rbox(back_w, back_h, back_plate_t, back_r, ch_bot = 0.4, ch_top = 0);

            // Subtle finger-nail pry notch at top edge (assembled +Y -> local -Y) for tool-free reopening
            translate([0, -back_h / 2 - 0.5, -0.1])
                linear_extrude(height = 0.7)
                    rrect2d(10.0, 2.4, 1.0);
        }

        // 4 long-side PETG snap-fit clips (inset by snap_inset for strong outer wall)
        for (sx = [-1, 1]) {
            for (sy = snap_side_ys) {
                translate([sx * (back_w / 2 - snap_inset - snap_t), -sy, back_plate_t - 0.01])
                    scale([sx, 1, 1])
                        snap_clip_x(snap_w, snap_t, snap_h, snap_barb);
            }
        }

        // 2 top-edge PETG snap-fit clips (assembled +Y -> local -Y, barb protrudes along -Y)
        for (tx = snap_top_xs) {
            translate([tx, -back_h / 2 + snap_inset + snap_t, back_plate_t - 0.01])
                rotate([0, 0, -90])
                    snap_clip_x(snap_w, snap_t, snap_h, snap_barb);
        }

        // Integrated glue-in locating cradles for the two 4-pin female headers (clear of front bottom wall)
        for (hx = [-hdr_x1, -hdr_x2]) {
            translate([hx - hdr_slot_len / 2 - cradle_wall, cradle_y_bot, back_plate_t - 0.01])
                cube([cradle_wall, cradle_y_len, cradle_h]);
            translate([hx + hdr_slot_len / 2, cradle_y_bot, back_plate_t - 0.01])
                cube([cradle_wall, cradle_y_len, cradle_h]);
        }

        // Gentle screen-perimeter retention ribs (pressed strictly on outer screen border)
        rib_h = behind_screen_t - 0.35; // 2.85 mm (leaves 0.35 mm cushion)
        for (sx = [-1, 1]) {
            translate([sx * (screen_w / 2 - 1.1) - 0.55, -4.0, back_plate_t - 0.01])
                cube([1.1, 24.0, rib_h]);
        }
    }
}

// =============================================================================
// PART 3: iPod-Style Angled Desktop Dock Body (dock_body)
// Print orientation: UPSIDE-DOWN on Z = 0 (top face on build plate for silky
// finish + lightweight hollow thin-walled shell; add minimal support only under
// the small inverted cradle well floor).
// =============================================================================
// Transform from upright dock world coordinates to tilted e-ink slab frame:
//   X = horizontal across screen (-35.3 .. +35.3, viewer's left-to-right)
//   Y = thickness of slab (front face at -case_t/2, back face at +case_t/2)
//   Z = upward along screen (bottom edge of slab at Z = 0)
module dock_slab_transform() {
    translate([0, well_y_center, well_floor_z])
        rotate([-dock_tilt, 0, 0])
            children();
}

// Upright geometry (used in assembly views and flipped for printing)
module dock_body_upright() {
    bot_lip_w = dock_w_bot - 2 * dock_bot_inset;
    bot_lip_d = dock_d_bot - 2 * dock_bot_inset;
    bot_lip_r = max(2.0, dock_r_bot - dock_bot_inset);

    // Header center along tilted Y (from front face -case_t/2 toward back +case_t/2)
    hdr_y_in_slab = -case_t / 2 + hdr_z_center; // +0.675 mm (behind center)

    dock_wall_t   = 3.8;            // Uniform hollow shell wall -> leaves ~0.8 mm perimeter stop ledge for dock_bottom
    dock_top_t    = 2.2;            // Solid top deck thickness
    well_boss_w   = well_w + 4.8;   // 2.4 mm reinforced cradle walls around well
    well_boss_t   = well_t + 4.8;

    difference() {
        union() {
            // 1. Hollow thin-walled iPod-style outer shell (crisp 0.8 mm top chamfer like real iPod Dock)
            difference() {
                dock_outer_solid(inset = 0, z0 = 0, z1 = dock_h, top_bevel = 0.8, bot_chamfer = 0.6);

                // Clean open hollow interior (2.2 mm top deck, huge wiring & ESP32 space)
                dock_outer_solid(inset = dock_wall_t, z0 = dock_bot_t - 0.1, z1 = dock_h - dock_top_t,
                                 top_bevel = 0.6, bot_chamfer = 0);
            }

            // 2. Internal reinforced cradle well boss hanging from top deck
            intersection() {
                dock_outer_solid(inset = 0.01, z0 = 0, z1 = dock_h, top_bevel = 0.8, bot_chamfer = 0.6);
                dock_slab_transform()
                    translate([0, 0, -well_floor_t])
                        linear_extrude(height = 25.0)
                            rrect2d(well_boss_w, well_boss_t, 2.4);
            }
        }

        // 3. Recessed lip at bottom for dock_bottom plate (Z = 0 .. dock_bot_t)
        translate([0, 0, -0.1])
            linear_extrude(height = dock_bot_t + 0.1)
                rrect2d(bot_lip_w, bot_lip_d, bot_lip_r);

        // 4. Tilted cradle well for the e-ink slab (15 deg backward tilt, r = 0.8 mm)
        dock_slab_transform() {
            linear_extrude(height = 40.0)
                rrect2d(well_w, well_t, 0.8);

            // Crisp lead-in flare at the top rim of the shallow well
            translate([0, 0, well_depth - 1.2])
                hull() {
                    linear_extrude(height = 0.1) rrect2d(well_w, well_t, 0.8);
                    translate([0, 0, 2.2])
                        linear_extrude(height = 0.1) rrect2d(well_w + 2.2, well_t + 2.2, 1.8);
                }

            // Asymmetric 2x 4-pin MALE pin header glue-in through-slots in cradle floor
            for (hx = [hdr_x1, hdr_x2]) {
                translate([hx - hdr_m_slot_len / 2, hdr_y_in_slab - hdr_m_slot_w / 2, -well_floor_t - 4.0])
                    cube([hdr_m_slot_len, hdr_m_slot_w, well_floor_t + 4.5]);
            }
        }

        // 5. Sleek enclosed Rear USB-C port window (+Y face, compact r=1.5 rounded rect -> neat & support-free!)
        translate([0, dock_d_bot / 2 - 5.0, usbc_z_center])
            rotate([-90, 0, 0])
                linear_extrude(height = 10.0)
                    rrect2d(usbc_w, usbc_h, 1.5);

        // 5b. Local rear ESP32-C3 board pocket so USB-C port sits flush against the rear wall
        translate([-(esp_w + 1.4) / 2, bot_lip_d / 2 - 6.0, dock_bot_t - 0.1])
            cube([esp_w + 1.4, 6.4, 5.4]);

        // 6. 4 internal snap-fit clearance channels & catch pockets for glue-free dock_bottom assembly
        for (sx = [-1, 1]) {
            for (sy = dock_snap_ys) {
                translate([sx * (bot_lip_w / 2 - dock_bot_clear - 0.6), sy, dock_bot_t + 2.3])
                    cube([1.6, 8.6, 4.8], center = true);
                translate([sx * (bot_lip_w / 2 - dock_bot_clear), sy, dock_bot_t + 3.4])
                    scale([sx, 1, 1])
                        rotate([90, 0, 0])
                            linear_extrude(height = 8.6, center = true)
                                polygon([
                                    [-0.6, -1.1],
                                    [0.85, -0.55],
                                    [0.85, 0.55],
                                    [-0.6, 1.1]
                                ]);
            }
        }
    }
}

// Printable dock_body: flipped upside-down with top face flat on Z = 0!
module dock_body() {
    translate([0, 0, dock_h])
        rotate([180, 0, 0])
            dock_body_upright();
}

// =============================================================================
// PART 4: Dock Bottom Plate with ESP32-C3 SuperMini Cradle & Snap-Fits (dock_bottom)
// Print orientation: Flat on Z = 0 (100% support-free!)
// =============================================================================
module dock_bottom() {
    plate_w = dock_w_bot - 2 * dock_bot_inset - 2 * dock_bot_clear;
    plate_d = dock_d_bot - 2 * dock_bot_inset - 2 * dock_bot_clear;
    plate_r = max(2.0, dock_r_bot - dock_bot_inset - dock_bot_clear);

    esp_pkt_w   = esp_w + 2 * esp_clear;     // 18.6 mm
    esp_pkt_len = esp_len + 2 * esp_clear;   // 23.1 mm
    // Seat ESP32-C3 right at the rear edge so USB-C port is flush for effortless cable plugging
    esp_y_rear  = plate_d / 2 + 0.2;
    esp_y_front = esp_y_rear - esp_pkt_len;

    union() {
        // Flat base plate nesting into dock_body
        rbox(plate_w, plate_d, dock_bot_t, plate_r, ch_bot = 0.4, ch_top = 0);

        // 4 glue-free PETG cantilever snap-fit clips along left/right edges
        for (sx = [-1, 1]) {
            for (sy = dock_snap_ys) {
                translate([sx * (plate_w / 2 - 1.2), sy, dock_bot_t - 0.01])
                    scale([sx, 1, 1])
                        snap_clip_x(8.0, 1.2, 4.2, 0.65);
            }
        }

        // ESP32-C3 Mini Pro (25.5 x 18.0 mm) locating cradle
        esp_rail_y_end = (dock_d_bot - 2 * dock_bot_inset - 4.0) / 2 - 2.6;
        esp_rail_len   = esp_rail_y_end - esp_y_front;
        translate([0, 0, dock_bot_t - 0.05])
            linear_extrude(height = esp_rail_h + 0.05)
                difference() {
                    translate([-esp_pkt_w / 2 - esp_rail_t, esp_y_front - esp_rail_t])
                        square([esp_pkt_w + 2 * esp_rail_t, esp_rail_len + esp_rail_t]);
                    translate([-esp_pkt_w / 2, esp_y_front])
                        square([esp_pkt_w, esp_rail_len + 1.0]);
                }

        // Optional coin/washer counterweight rings flanking ESP32-C3 in rear half (2x 20.8 mm pockets)
        for (wx = [-23.5, 23.5]) {
            translate([wx, 9.0, dock_bot_t - 0.01])
                difference() {
                    cylinder(d = 23.0, h = 2.0);
                    translate([0, 0, -0.1]) cylinder(d = 20.8, h = 2.3);
                }
        }
    }
}

// =============================================================================
// Reference Ghosts (for Assembly Preview Only - NOT exported in STL parts)
// =============================================================================
module ghost_headers_and_esp() {
    hdr_y_in_slab = -case_t / 2 + hdr_z_center;

    // 2x 4-pin female headers (inside shell) + male headers (in dock)
    dock_slab_transform() {
        for (hx = [hdr_x1, hdr_x2]) {
            color([0.15, 0.15, 0.18])
                translate([hx - hdr_f_len / 2, hdr_y_in_slab - hdr_f_w / 2, 0.2])
                    cube([hdr_f_len, hdr_f_w, hdr_f_depth]);
            color([0.85, 0.72, 0.25])
                for (p = [-1.5, -0.5, 0.5, 1.5]) {
                    translate([hx + p * 2.54 - 0.32, hdr_y_in_slab - 0.32, -3.5])
                        cube([0.64, 0.64, 9.5]);
                }
        }
    }

    // ESP32-C3 SuperMini ghost on dock_bottom
    plate_d = dock_d_bot - 2 * dock_bot_inset - 2 * dock_bot_clear;
    esp_y_rear = plate_d / 2 + 0.2;
    color([0.12, 0.45, 0.22])
        translate([-esp_w / 2, esp_y_rear - esp_len, dock_bot_t + 0.2])
            cube([esp_w, esp_len, 1.6]);
    color([0.75, 0.75, 0.78])
        translate([-4.5, esp_y_rear - 5.5, dock_bot_t + 1.8])
            cube([9.0, 7.5, 3.2]); // USB-C metal shell
}

// =============================================================================
// Full Assembly (E-Ink Frame Docked into iPod-Style Dock)
// =============================================================================
module assembly_placed() {
    color([0.92, 0.93, 0.95]) dock_body_upright();
    color([0.78, 0.80, 0.84]) dock_bottom();
    ghost_headers_and_esp();

    dock_slab_transform() {
        translate([0, -case_t / 2, case_h_base / 2])
            rotate([90, 0, 180]) {
                color([0.22, 0.24, 0.28]) case_front();
                color([0.32, 0.35, 0.40])
                    translate([0, 0, case_t])
                        rotate([180, 0, 0])
                            case_back();
            }
    }
}

// -----------------------------------------------------------------------------
// Part Selector
// -----------------------------------------------------------------------------
if (part == "case_front") {
    case_front();
} else if (part == "case_back") {
    case_back();
} else if (part == "dock_body") {
    dock_body();
} else if (part == "dock_bottom") {
    dock_bottom();
} else if (part == "assembly") {
    assembly_placed();
} else if (part == "assembly_cutaway") {
    difference() {
        assembly_placed();
        // Cutaway right through the left asymmetric header (X = -17) to verify pin alignment!
        translate([-17.0, -60, -5]) cube([100, 140, 140]);
    }
}
