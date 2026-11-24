// ============================================================================
// Sony WH-1000XM4 Desk Clip Headphone Hanger (29.3mm Desk, PETG, Support-Free)
// ============================================================================
// Design highlights:
//   - Precision-tuned for a 29.3mm thick desk with elastic PETG pre-load clamp
//   - Tailored for Sony WH-1000XM4 (~33mm padded headband, 254g)
//   - 100% support-free when printed lying flat on its side (Z = 0..hanger_width)
//   - Continuous XY perimeters along both the C-clamp & hook for maximum strength
//   - Ergonomic convex-arched cradle (R=85mm) matching head curvature -> no dents
//   - Sleek tapered arms, 45-deg edge chamfers, corner reliefs & anti-slip ribs
// ============================================================================

/* [Desk & Clamp Parameters] */
desk_thickness      = 29.3;  // Exact measured desk thickness (mm)
clamp_preload       = 0.7;   // Total inward jaw closure at tips for firm PETG grip (mm)
clamp_back_clear    = 0.15;  // Slight clearance at spine so desk seats flush (mm)
top_arm_len         = 46.0;  // Top arm reach onto desk surface (mm)
bot_arm_len         = 44.0;  // Bottom arm reach under desk (mm)
top_arm_root_t      = 7.5;   // Top arm thickness at spine (mm)
top_arm_tip_t       = 4.5;   // Sleek tapered thickness at top tip (mm)
bot_arm_root_t      = 9.0;   // Stiffer bottom arm thickness at spine (mm)
bot_arm_tip_t       = 5.5;   // Tapered thickness at bottom tip (mm)
spine_t             = 9.5;   // Vertical spine thickness against desk edge (mm)

/* [Headphone Cradle Parameters (Sony WH-1000XM4)] */
hanger_width        = 34.0;  // Hanger width along desk edge / Z print height (mm)
cradle_flat_len     = 34.0;  // Flat/gentle cradle zone (plus back/front curves -> ~42mm)
cradle_drop         = 11.0;  // Cradle floor below desk bottom face (mm)
hook_arm_t          = 7.2;   // Hook arm structural thickness (mm)
back_fillet_r       = 11.0;  // Smooth tangent transition from spine to cradle (mm)
lip_height          = 12.0;  // Front retaining lip height above cradle floor (mm)
arch_radius         = 85.0;  // Convex arch radius along Z to match head curve (mm)

/* [Printability & Aesthetics] */
edge_chamfer        = 0.8;   // 45-deg edge chamfer on Z=0 and Z=width faces (mm)
corner_relief_r     = 1.3;   // Inner desk corner relief radius (mm)
grip_rib_r          = 0.4;   // Subtle rounded anti-slip grip ridge radius (mm)
$fn                 = 64;

// ============================================================================
// Helper: 2D corner rounding (preserves concave cutouts)
// ============================================================================
module fillet_2d(r) {
    offset(r = r) offset(r = -r) children();
}

// ============================================================================
// Helper: Safe 45-degree chamfered extrude for CONCAVE 2D shapes (no hull!)
// Uses fine 0.15mm stepped slices (< 0.2mm layer height) -> crisp 45-deg bevel
// ============================================================================
module chamfered_extrude(h, c = 1.2) {
    if (c <= 0) {
        linear_extrude(height = h) children();
    } else {
        steps = 8;
        dz = c / steps;
        // Bottom 45-deg chamfer
        for (i = [0 : steps - 1]) {
            z0 = i * dz;
            off = -c + (i + 0.5) * dz;
            translate([0, 0, z0])
                linear_extrude(height = dz + 0.005)
                offset(delta = off)
                children();
        }
        // Main center body
        translate([0, 0, c])
            linear_extrude(height = h - 2 * c)
            children();
        // Top 45-deg chamfer
        for (i = [0 : steps - 1]) {
            z0 = h - c + i * dz;
            off = -(i + 0.5) * dz;
            translate([0, 0, z0 - 0.005])
                linear_extrude(height = dz + 0.005)
                offset(delta = off)
                children();
        }
    }
}

// ============================================================================
// 2D Profile: C-Clamp Body (Desk occupies x <= 0, y in [0, desk_thickness])
// ============================================================================
module clamp_2d() {
    dt   = desk_thickness;
    pre  = clamp_preload / 2;
    clr  = clamp_back_clear / 2;
    lead = 2.0;  // Lead-in ramp flare at jaw mouth for easy mounting

    difference() {
        union() {
            // Outer C-clamp silhouette with rounded corners
            fillet_2d(2.0)
            polygon(points = [
                // Top jaw inner face (lead-in -> tight clamp zone -> spine)
                [-top_arm_len, dt - pre + lead],
                [-top_arm_len + 5.0, dt - pre],
                [0, dt + clr],
                // Spine inner face against desk edge
                [0, -clr],
                // Bottom jaw inner face (spine -> tight clamp zone -> lead-in)
                [-bot_arm_len + 5.0, pre],
                [-bot_arm_len, pre - lead],
                // Bottom arm outer underside (tapered)
                [-bot_arm_len, -bot_arm_tip_t],
                [0, -bot_arm_root_t],
                // Spine outer face (blends smoothly into hook underside)
                [spine_t, -bot_arm_root_t - 2.2],
                [spine_t, dt + top_arm_root_t],
                // Top arm outer top face (sleek low-profile taper)
                [-top_arm_len, dt + top_arm_tip_t]
            ]);

            // Subtle rounded anti-slip grip pads near jaw tips
            for (gx = [-top_arm_len + 9.0, -top_arm_len + 17.0]) {
                y_pad = dt + clr - (clr + pre) * (-gx / (top_arm_len - 5.0));
                translate([gx, y_pad]) circle(r = grip_rib_r, $fn = 24);
            }
            for (gx = [-bot_arm_len + 9.0, -bot_arm_len + 17.0]) {
                y_pad = -clr + (clr + pre) * (-gx / (bot_arm_len - 5.0));
                translate([gx, y_pad]) circle(r = grip_rib_r, $fn = 24);
            }
        }

        // Corner relief notches so a sharp 90-deg desk edge seats completely flush
        translate([0.2, dt + clr - 0.1]) circle(r = corner_relief_r, $fn = 24);
        translate([0.2, -clr + 0.1])     circle(r = corner_relief_r, $fn = 24);
    }
}

// ============================================================================
// 2D Profile: Swept Headphone Cradle (Side view in XY, x >= 2.0)
// ============================================================================
module hook_2d() {
    y_floor   = -cradle_drop;
    y_bot     = y_floor - hook_arm_t;
    x_fillet  = spine_t + back_fillet_r;           // Cradle tangent start
    x_mid     = x_fillet + cradle_flat_len * 0.5;  // Cradle center
    x_end     = x_fillet + cradle_flat_len;        // Lip curve start
    x_lip_tip = x_end + 8.5;                       // Front retaining lip tip
    y_lip_tip = y_floor + lip_height;

    difference() {
        offset(r = -2.0) offset(r = 2.0)
        union() {
            // Smooth gusseted root connecting spine to cradle floor
            hull() {
                translate([spine_t - 3.5, y_floor + back_fillet_r + 1.5])
                    circle(r = 3.5);
                translate([spine_t - 3.5, -bot_arm_root_t + 1.0])
                    circle(r = 3.5);
                translate([x_fillet, y_bot + hook_arm_t / 2])
                    circle(d = hook_arm_t);
            }

            // Cradle bed with subtle 0.8mm concave dip to self-center the XM4 headband
            hull() {
                translate([x_fillet, y_bot + hook_arm_t / 2])
                    circle(d = hook_arm_t);
                translate([x_mid, y_bot + hook_arm_t / 2 - 0.8])
                    circle(d = hook_arm_t);
            }
            hull() {
                translate([x_mid, y_bot + hook_arm_t / 2 - 0.8])
                    circle(d = hook_arm_t);
                translate([x_end, y_bot + hook_arm_t / 2])
                    circle(d = hook_arm_t);
            }

            // Swept front retaining lip (smooth upward curve, rounded tip)
            hull() {
                translate([x_end, y_bot + hook_arm_t / 2])
                    circle(d = hook_arm_t);
                translate([x_lip_tip, y_lip_tip - 2.8])
                    circle(d = 5.6);
            }
        }

        // Exact tangent quarter-circle fillet between vertical spine (x=spine_t)
        // and cradle floor (y=y_floor) -> zero sharp corners!
        translate([x_fillet, y_floor + back_fillet_r])
            circle(r = back_fillet_r, $fn = 64);

        // Trim any excess above the fillet on the +x side of the spine
        translate([spine_t, y_floor + back_fillet_r])
            square([back_fillet_r + 5, 40]);
    }
}

// ============================================================================
// 3D Ergonomic Arched Hook (Convex along Z to match Sony XM4 headband arch)
// Max overhang along Z is ~11.5 degrees -> 100% support-free!
// ============================================================================
module arched_hook_3d() {
    y_floor  = -cradle_drop;
    y_center = y_floor - arch_radius;

    // Sweep angle wide enough to cover [0, hanger_width] cleanly
    sweep_half = asin((hanger_width / 2 + 3.0) / (arch_radius - 15.0));

    intersection() {
        // Clip cleanly to Z = [0, hanger_width] so bottom is 100% flat on build plate
        translate([-10, -100, 0])
            cube([200, 200, hanger_width]);

        // Rotate-extrude hook_2d around axis parallel to X at (y_center, width/2)
        // Mapping: (x, y) -> (r = y - y_center > 0, h = x)
        translate([0, y_center, hanger_width / 2])
            rotate([90, 0, 0])
            rotate([0, 90, 0])
            rotate([0, 0, -sweep_half])
            rotate_extrude(angle = 2 * sweep_half, convexity = 6, $fn = 128)
            mirror([0, 1, 0])
            rotate([0, 0, -90])
            translate([0, -y_center])
                hook_2d();
    }
}

// ============================================================================
// Final Assembly
// ============================================================================
module sony_xm4_desk_hanger() {
    union() {
        // C-clamp with 45-deg edge chamfers
        chamfered_extrude(hanger_width, edge_chamfer)
            clamp_2d();

        // Ergonomically arched headphone hook
        arched_hook_3d();
    }
}

sony_xm4_desk_hanger();
