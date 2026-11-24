// =====================================================================
// 80 mm 风扇 → 金刚网 → 原 75 mm 扁口弯管   纱窗换气夹座
// 参数单位 mm。part = indoor | outdoor | cover | assembly
//
// 纱网实测：丝径 0.6，孔距 ~2.1（照片估算，待核对），净开孔 ~1.5。
// 开孔太小、编织相位无法对齐，故不做穿孔凸点，改为两侧交错四棱台压网。
//
// 原 ref_flat_elbow.stl 实测：Ø74 圆口 + 喇叭法兰（外缘 Ø98，边缘一圈半圆缺口，
// 无螺钉孔）+ 90° 弯 + 扁口（外 65×25 / 内约 55×16），出口段约 98 长。
// 所以室外件改成"插套"接口，不再做成圆弯管。
// =====================================================================
/* [部件] */
part = "assembly";           // [indoor, outdoor, cover, assembly]
outdoor_kind = "flat_elbow";  // [flat_elbow, spigot]
$fn = 96;

/* [板与气流] */
plate_side   = 116;          // 板尺寸：方板边长 / 圆板直径 [100:1:140]
out_shape    = "round";      // 室外板外形 [round, square]（round 省 22% 料）
plate_t      = 5.5;          // 板厚
plate_fillet = 24;           // 方板四角圆角，0 = 直角 [0:1:40]
cover_fillet = 12;           // 盖板四角圆角 [0:1:30]
gap_half     = 1.0;          // 纱网平面到每侧板面
bore_d       = 74;           // 室内件过风孔
wall_th      = 5.9;          // 风扇腔壁厚（4.5 省约 12 cm³，别低于 4.2：盖板密封槽宽 2）
wall_inner   = 81.2;         // 风扇腔净空（80×80 扇 + 0.6/侧）
wall_h       = 26;           // 风扇腔高（扇厚 25 + 1）
cover_t      = 4;
cover_hose   = true;         // 盖板外侧加 75 烟管插嘴（室内接烟管）

/* [风扇] */
fan_pitch    = 72;           // 孔心距，务必实测（商品页 72/71 不一致）
fan_screw_d  = 5.0;          // 盖板过孔（Ø4.7 螺纹的通孔）
pilot_d      = 3.9;          // 板内自攻底孔（Ø4.7 自攻，底孔≈0.8×外径）
nut_free     = 1.5;          // 底孔距纱网面留料

/* [磁铁] */
mag_d        = 6.25;         // 6×2 磁铁 + 胶水间隙
mag_t        = 2.25;         // 单层槽深
mag_stack    = 1;            // 叠放层数 [1, 2]
mag_ring     = 51;           // 分布圆半径（8 个，避让风扇螺钉）
mag_ang0     = 22.5;         // 起始角，错开 45° 的螺钉位

/* [网面咬合] */
// 尖端世界坐标 = gap_half - grip_h，网面在 ±0.3，故咬入 = 0.3-(1.0-0.95)=0.25
grip_h       = 0.95;
grip_pitch   = 3.6;          // 阵列间距（≠ 2.1 孔距，避免整片对孔）
grip_r0      = 38;           // 环形带内径（>37，避开过风孔）
grip_r1      = 46;           // 环形带外径
grip_base    = 1.3;          // 棱台底对角
grip_tip     = 0.35;         // 棱台顶面对角（钝顶，不割网丝）
mag_boss     = 0.8;          // 磁铁凸台高（让磁铁贴近网面）

/* [室外接口] */
out_bore     = 70;           // 室外件过风孔（三种接口共用）



hose_od      = 74.4;         // 烟管接口外径：75 内径软管套在外
hose_len     = 30;           // 插入深度
hose_rib_d   = 76.0;         // 倒刺外径
hose_stop_d  = 86;           // 根部挡边（同时遮住接缝）
hose_stop_h  = 3;
// 一体扁口弯管（复刻原 ref_flat_elbow 的外形：圆口 → 90° 弯 → 扁口）
elbow_od     = 74.6;         // 入口外径（壁厚 2）
elbow_id     = 70.6;         // 入口内径（比板孔大 0.6，避免共面）
inlet_len    = 10;           // 入口直段（弯前伸出） [0:1:40]
bend_r       = 52;           // 弯曲半径 [30:1:90]
mouth_long   = 65.2;         // 扁口长边 [30:0.1:100]
mouth_thin   = 24.7;         // 扁口短边（壁厚按短边方向算） [10:0.1:45]
mouth_vert   = false;        // 长边水平 = false；竖直 = true [false, true]
mouth_len    = 90;           // 扁口直段长度 [20:1:200]
mouth_wall   = 3.4;          // 出口壁厚，预设：厚 4.4 / 适中 3.4 / 薄 2.6 [2.2:0.1:4.6]
bend_seg     = 24;           // 弯段分段数（越大内壁越顺，渲染越慢）

/* [系绳 / 绑丝] */
lug_r        = 62;           // 绳耳中心到轴心
lug_ang_in   = 180;          // 室内绑丝耳角度（安装后重力反方向；180 = -X） [0:15:345]
lug_ang_out  = 180;          // 室外防坠耳角度 [0:15:345]
lug_hole     = 4.2;
lug_boss     = 0.6;          // 绳耳纱网侧凸台（两面件相对，别顶在一起）
lug_boss_out = 2.0;          // 绳耳外侧凸台（孔壁 → 1.95 mm）
lug_d        = 12;

// ===================== 工具 =====================
module rsq(size, r, h) {           // 圆角方柱
    linear_extrude(height = h) offset(r = r) square([size - 2*r, size - 2*r], center = true);
}
module plate(z0, h) {              // 圆角方板
    translate([0, 0, z0]) rsq(plate_side, plate_fillet, h);
}
module lug(x, y, h) {              // 板边系绳耳（两侧凸台把 Ø4.2 孔的孔壁加厚）
    hull() {
        translate([x*0.94, y*0.94, 0]) cylinder(d = lug_d, h = h);
        translate([x, y, 0]) cylinder(d = lug_d, h = h);
    }
    translate([x, y, -lug_boss]) cylinder(d = lug_d, h = lug_boss + 0.01);
    translate([x, y, h]) cylinder(d = lug_d, h = lug_boss_out);
}
module grip_pins(phase) {          // 四棱台阵列，尖端朝 -Z（纱网侧）
    for (x = [-grip_r1 : grip_pitch : grip_r1])
        for (y = [-grip_r1 : grip_pitch : grip_r1]) {
            xx = x + phase;
            if (sqrt(xx*xx + y*y) > grip_r0 && sqrt(xx*xx + y*y) < grip_r1)
                translate([xx, y, -grip_h]) cylinder(h = grip_h, d1 = grip_tip, d2 = grip_base, $fn = 4);
        }
}
module mag_positions() {
    for (i = [0 : 7]) rotate([0, 0, mag_ang0 + 45*i]) translate([mag_ring, 0, 0]) children();
}
module cable_slot(h) {             // +X 方向径向出线槽（8 mm 宽），避开磁铁与风扇螺钉
    translate([35, -4, 0]) cube([38, 8, h]);
}
module mag_bosses() {              // 凸台，朝纱网侧伸出
    mag_positions() translate([0, 0, -mag_boss + 0.01])
        cylinder(d = mag_d + 2.2, h = mag_boss);
}
module mag_pockets() {             // 磁铁槽，开口在凸台端面，深 = 磁铁厚 + 0.25 胶
    mag_positions() translate([0, 0, -mag_boss - 0.05])
        cylinder(d = mag_d, h = 0.05 + mag_stack*mag_t);
}

// ===================== 室内件 =====================
module indoor() {
    difference() {
        union() {
            plate(0, plate_t);
            translate([0, 0, plate_t]) rsq(wall_inner + 2*wall_th, 5, wall_h);
            lug(lug_r*cos(lug_ang_in), lug_r*sin(lug_ang_in), plate_t);   // 绑丝耳
            mag_bosses();
            grip_pins(0);                             // 网面咬合棱台
        }
        // 过风孔
        translate([0, 0, -1]) cylinder(d = bore_d, h = plate_t + wall_h + 2);
        // 风扇腔（顶部装入，直角方腔）
        translate([0, 0, plate_t]) translate([-wall_inner/2, -wall_inner/2, 0])
            cube([wall_inner, wall_inner, wall_h + 1]);
        // 出线槽：从扇边穿出腔壁
        translate([0, 0, plate_t]) cable_slot(wall_h + 2);
        // 4 个 M4 自攻底孔（从腔底面向上）
        for (x = [-fan_pitch/2, fan_pitch/2], y = [-fan_pitch/2, fan_pitch/2])
            translate([x, y, nut_free]) cylinder(d = pilot_d, h = plate_t - nut_free + 0.1);
        // 磁铁槽 + 系绳孔
        mag_pockets();
        translate([lug_r*cos(lug_ang_in), lug_r*sin(lug_ang_in), -lug_boss - 0.5]) cylinder(d = lug_hole, h = plate_t + lug_boss + lug_boss_out + 1);
    }
}

// ===================== 室外件 =====================
// 板外形：out_shape = round（圆板，省料）或 square（方板）
module out_plate() {
    if (out_shape == "round") cylinder(d = plate_side, h = plate_t);
    else plate(0, plate_t);
}
// ---- 一体扁口弯管：圆口 → 90° 弯 → 竖直扁口 ----
function lerp(a, b, t) = a + (b - a) * t;
module rrect(w, h, r) {            // 圆角矩形；w=h 时为圆，r=min/2 时为药丸形
    offset(r = r) square([max(0.01, w - 2*r), max(0.01, h - 2*r)], center = true);
}
module elbow_sec(w, h, phi, ext) { // 弯段截面：φ=0 朝 +Z，φ=90 朝 +X
    z0 = plate_t + inlet_len;
    translate([bend_r*(1 - cos(phi)), 0, z0 + bend_r*sin(phi)])
        rotate([0, phi, 0]) linear_extrude(height = ext) rrect(w, h, min(w, h)/2);
}
module flat_elbow(d_in, w_end, h_end, extend) {
    z0 = plate_t + inlet_len;
    e0 = extend ? 2 : 0;
    // 入口直段
    translate([0, 0, plate_t - e0]) linear_extrude(height = inlet_len + e0)
        rrect(d_in, d_in, d_in/2);
    // 90° 弯（截面从圆渐变到扁口）
    for (i = [0 : bend_seg - 1]) {
        t0 = i / bend_seg; t1 = (i + 1) / bend_seg;
        hull() {
            elbow_sec(lerp(d_in, w_end, t0), lerp(d_in, h_end, t0), 90*t0, 0.8);
            elbow_sec(lerp(d_in, w_end, t1), lerp(d_in, h_end, t1), 90*t1, 0.8);
        }
    }
    // 出口直段
    translate([bend_r, 0, z0 + bend_r]) rotate([0, 90, 0])
        linear_extrude(height = mouth_len + e0) rrect(w_end, h_end, min(w_end, h_end)/2);
}
module elbow_duct() {
    // 出口截面：局部 x 在出口处是竖直方向，局部 y 是水平（平行于板）方向
    mw = mouth_vert ? mouth_long : mouth_thin;   // 竖直
    mh = mouth_vert ? mouth_thin : mouth_long;   // 水平
    difference() {
        union() {
            flat_elbow(elbow_od, mw, mh, false);
            // 根部加强圆角（板面 → 圆口）
            translate([0, 0, plate_t]) cylinder(d1 = elbow_od + 7, d2 = elbow_od, h = 3);
        }
        flat_elbow(elbow_id, mw - 2*mouth_wall, mh - 2*mouth_wall, true);
    }
}
// 75 mm 烟管接口：外径 74.4（75 内径软管套上），两道对称倒刺撑住，
// 根部 Ø86×3 挡边限制插入深度并遮住接缝，端部倒角便于套入。
module hose_cone() {               // 75 烟管插嘴（从 z=0 沿 +Z）
    cylinder(d = hose_od, h = hose_len);
    for (z = [8, 18]) {
        translate([0, 0, z]) cylinder(d1 = hose_od, d2 = hose_rib_d, h = 2);
        translate([0, 0, z + 2]) cylinder(d1 = hose_rib_d, d2 = hose_od, h = 2);
    }
    cylinder(d = hose_stop_d, h = hose_stop_h);
}
module hose_spigot() {
    translate([0, 0, plate_t]) hose_cone();
}
module outdoor() {
    difference() {
        union() {
            out_plate();
            lug(lug_r*cos(lug_ang_out), lug_r*sin(lug_ang_out), plate_t);  // 防坠耳
            mag_bosses();
            grip_pins(grip_pitch/2);                  // 与室内件错开半格
            if (outdoor_kind == "flat_elbow") elbow_duct();
            else                             hose_spigot();
        }
        translate([0, 0, -1]) cylinder(d = out_bore, h = plate_t + 2);
        if (outdoor_kind != "flat_elbow")
            translate([0, 0, plate_t - 0.01]) cylinder(d = out_bore, h = hose_len + 4);
        // 端部倒角
        if (outdoor_kind == "spigot")
            translate([0, 0, plate_t + hose_len - 1.5])
                cylinder(d1 = hose_od - 2.6, d2 = hose_od + 0.4, h = 1.6);
        mag_pockets();
        translate([lug_r*cos(lug_ang_out), lug_r*sin(lug_ang_out), -lug_boss - 0.5]) cylinder(d = lug_hole, h = plate_t + lug_boss + lug_boss_out + 1);
    }
}

// ===================== 盖板 =====================
module cover() {
    difference() {
        union() {
            rsq(100, cover_fillet, cover_t);
            if (cover_hose) translate([0, 0, cover_t]) hose_cone();
        }
        translate([0, 0, -1]) cylinder(d = cover_hose ? 70 : bore_d, h = cover_t + hose_len + 2);
        // 4 个 M4 沉头过孔
        for (x = [-fan_pitch/2, fan_pitch/2], y = [-fan_pitch/2, fan_pitch/2]) {
            translate([x, y, -1]) cylinder(d = fan_screw_d, h = cover_t + 2);
            translate([x, y, cover_t - 2.6]) cylinder(d = 9.4, h = 2.7);
        }
        // 密封条槽：外墙顶面 2 mm 泡棉条
        translate([0, 0, -0.1]) difference() {
            rsq(wall_inner + wall_th - 2, 4, 1.2);
            rsq(wall_inner + wall_th + 2, 4.5, 1.3);
        }
        // 密封条槽：扇框外圈 2 mm 泡棉条
        translate([0, 0, -0.1]) difference() {
            cylinder(d = 80, h = 1.2);
            cylinder(d = 76, h = 1.3);
        }
        // 出线槽（与室内件 +X 槽对齐）
        translate([38, -4.5, -1]) cube([36, 9, cover_t + hose_stop_h + 2]);
    }
}

// ===================== 装配视图 =====================
if (part == "indoor") indoor();
else if (part == "outdoor") outdoor();
else if (part == "cover") cover();
else {
    color("steelblue") translate([0, 0, gap_half]) indoor();
    color("orange")    translate([0, 0, -gap_half]) rotate([180, 0, 0]) outdoor();
    color("silver")    translate([0, 0, gap_half + plate_t + wall_h]) cover();
}
