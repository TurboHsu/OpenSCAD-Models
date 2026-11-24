/* ============================================================
   USB-A 直通 DC 开关外壳  (USB-A 公 → USB-A 母, 无 PCB 直接焊线)
   紧凑版: 船型开关横置 (长边沿 Y), 外形 37.0 × 17.8 × 20.5 mm
   --------------------------------------------------------------
   打印件:   body  外壳主体 (装开关 / 两个 USB 口 / 卡扣窗口)
             lid   底盖    (卡扣 + 内部焊线舱)
   预览件:   连接器 / 开关 示意 (不打印, 仅装配预览用)

   设计要点 (PETG):
     - 卡扣：5.3 mm 竖立悬臂 + 50° 凸棱, 0.2 mm 咬合, 免支撑
     - 滑动/压配留 0.1~0.3 mm 正常余量 (材料收缩已校准)
     - 内部无锐利内角, 外壳壁 1.8 mm, 顶壁 3.4 mm
     - body 开口朝下打印, 内部顶面需切片软件支撑; lid 平放无支撑
   ============================================================ */

$fa = 2;
$fs = 0.4;

part = "body";        // body | lid | assembly | section

// ---------------- 外壳总体 ----------------
L        = 37.0;     // X 长度
W        = 17.8;     // Y 宽度
H        = 20.5;     // Z 高度
r_plan   = 3.0;      // 俯视圆角
wall     = 1.8;      // 侧壁厚度
tw       = 3.4;      // 顶壁厚度
lid_t    = 2.4;      // 底盖总厚度
front_wall = 1.8;    // 前端(公头)壁厚
back_wall  = 1.8;    // 后端(母口)壁厚
top_ch   = 0.6;      // 顶边倒角高度
top_inset= 0.5;      // 顶边倒角内缩
bot_inset= 0.4;      // 底边倒角内缩

z_floor = lid_t;          // 内部底面 2.4
z_ceil  = H - tw;         // 内部顶面 17.1

// ---------------- 元器件尺寸 (按采购图纸) ----------------
// USB-A 90° 直插焊板公头
m_shell_l = 12.05;  m_shell_w = 12.05;  m_shell_h = 4.5;
m_body_l  = 6.75;   m_body_w  = 12.8;   m_body_h  = 4.55;
m_pin_drop= 5.1;    m_pin_pitch= 2.0;   m_pin_w   = 0.8;  m_elbow = 1.9;

// USB-A 90° 直插焊板母座
f_shell_l= 14.1;    f_shell_w = 13.2;   f_shell_h = 6.8;
f_pin_drop= 3.8;    f_post_drop= 3.25;

// 白色船型开关 (KCD11 类) —— 长边沿 Y 横置
sw_bz_x  = 10.5;    sw_bz_y  = 15.0;    sw_bz_t  = 2.5;
sw_body_x= 8.5;     sw_body_y= 13.0;    sw_body_t= 11.0;
sw_pin_len = 5.0;
sw_tab_w = 3.6;     sw_tab_t = 0.5;     // 2 只引脚, 沿 Y 相距 5.0
sw_hole_x= 9.1;     sw_hole_y= 14.1;
sw_rec_x = 11.1;    sw_rec_y = 15.6;

z_usb = 10.4;             // USB 口轴线高度

// ---------------- 布局 ----------------
front_face  = -L/2;
back_face   =  L/2;
front_inner = front_face + front_wall;
back_inner  = back_face  - back_wall;
cav_d = L - front_wall - back_wall;     // 33.4
cav_w = W - 2*wall;                     // 14.2

m_shoulder = front_inner;                   // 公头塑料本体顶住前壁内表面
f_shoulder = back_inner;                    // 母座法兰顶住后壁内表面

m_shell_tip = m_shoulder - m_shell_l;       // 公头伸出端
m_body_rear = m_shoulder + m_body_l;        // -9.35
m_pin_rear = m_body_rear + m_elbow;         // -7.45

sw_body_front = m_pin_rear + 1.0;           // -6.45
sw_body_rear = sw_body_front + sw_body_x;   //  2.05
sw_cx = (sw_body_front + sw_body_rear)/2;   // -2.2

f_rear = f_shoulder - f_shell_l;            //  3.0

sw_seat = H - sw_bz_t;                      // 18.0 开关面板台阶面
ledge_t = sw_seat - z_ceil;                 //  0.9 沉槽台阶厚度

// ============================================================
//  基础工具
// ============================================================
module rrect2d(w, h, r) {
  offset(r=r) square([w-2*r, h-2*r], center=true);
}

module rr_prism_z(w, h, r, z0, z1) {
  translate([0,0,z0]) linear_extrude(z1-z0) rrect2d(w,h,r);
}

// 沿 X 方向的棱柱: 截面在 YZ 平面, w=Y 宽, h=Z 高
module rr_prism_x(x0, x1, y, z, w, h, r) {
  translate([x0,y,z])
  multmatrix([[0,0,1,0],
             [1,0,0,0],
             [0,1,0,0],
             [0,0,0,1]])
  linear_extrude(x1-x0) rrect2d(w,h,r);
}

// 沿 X 方向的棱柱: 截面为任意 2D 多边形 (u=Y, v=Z)
module prism_x(x0, len, poly) {
  translate([x0,0,0])
  multmatrix([[0,0,1,0],
             [1,0,0,0],
             [0,1,0,0],
             [0,0,0,1]])
  linear_extrude(len) polygon(poly);
}

// ============================================================
//  外壳主体 body
// ============================================================
module outer_solid() {
  hull() {
    // 底边 45° 倒角
    translate([0,0,1.00])       linear_extrude(0.02) rrect2d(L-2*bot_inset, W-2*bot_inset, r_plan-bot_inset);
    translate([0,0,1.38])       linear_extrude(0.02) rrect2d(L, W, r_plan);
    // 顶边 45° 倒角
    translate([0,0,H-top_ch])   linear_extrude(0.02) rrect2d(L, W, r_plan);
    translate([0,0,H-0.02])     linear_extrude(0.02) rrect2d(L-2*top_inset, W-2*top_inset, r_plan-top_inset);
  }
}

module cavity() {
  // 从底面以下 0.1 起切, 避免与底面共面
  translate([0,0,z_floor-1.5]) linear_extrude(z_ceil-(z_floor-1.5)) rrect2d(cav_d, cav_w, r_plan-wall);
}

// 公头: 通孔 (本体直接顶住前壁内表面, 靠孔定位)
module male_cuts() {
  rr_prism_x(front_face-0.1, m_shoulder+0.1, 0, z_usb, 12.3, 4.7, 1.0);
}

// 母座: 通孔
module female_cuts() {
  rr_prism_x(f_shoulder-0.1, back_face+0.1, 0, z_usb, 12.6, 5.2, 1.1);
}

// 开关: 穿线孔 + 沉槽 (横置)
module switch_cuts() {
  translate([sw_cx,0,z_ceil])  linear_extrude(ledge_t+0.1)      rrect2d(sw_hole_x, sw_hole_y, 1.5);
  translate([sw_cx,0,sw_seat]) linear_extrude(H-sw_seat+0.1)   rrect2d(sw_rec_x,  sw_rec_y,  1.6);
}

// 卡扣窗口 (两侧各 2 处)
module window_cuts() {
  for (x = [-11, 9], s = [-1,1])
    translate([x, s*(cav_w+W)/4, 5.3]) cube([6.6, 2.0, 1.8], center=true);
}

module body() {
  difference() {
    outer_solid();
    cavity();
    male_cuts();
    female_cuts();
    switch_cuts();
    window_cuts();
  }
}

// ============================================================
//  底盖 lid
// ============================================================
lid_yo = (cav_w - 0.3)/2 - 0.05;   // 6.90 卡扣外侧基准 (内缩 0.05 避免共面)
lid_fl_l = L - 0.2;            // 36.8
lid_fl_w = W - 0.2;            // 17.6
lid_in_l = cav_d - 0.3;        // 33.1
lid_in_w = cav_w - 0.3;        // 13.9

module lid_base() {
  union() {
    // 外翻边 (底盘) 0 .. 1.0, 底部 45° 倒角
    hull() {
      translate([0,0,0.0])  linear_extrude(0.02) rrect2d(lid_fl_l-1.0, lid_fl_w-1.0, r_plan-0.6);
      translate([0,0,0.48]) linear_extrude(0.02) rrect2d(lid_fl_l,     lid_fl_w,     r_plan-0.1);
    }
    translate([0,0,0.5]) linear_extrude(0.5) rrect2d(lid_fl_l, lid_fl_w, r_plan-0.1);
    // 内侧部分 1.0 .. 2.4 (与翻边顶面拼接)
    translate([0,0,1.0]) linear_extrude(lid_t-1.0) rrect2d(lid_in_l, lid_in_w, r_plan-wall-0.3);
  }
}

// 单个竖立卡扣悬臂 (5.3 mm 长, 根部埋入翻边 0.1, 免支撑)
module hook_one(x, s) {
  translate([x, s*6.40, 3.55]) cube([6, 1.0, 5.3], center=true);   // z 0.9..6.2
  // 50° 凸棱: 下斜面 = 卡扣面 (过窗口下沿 7.1/4.4), 上斜面 = 导入面
  prism_x(x-2.9, 5.8, [
    [s*6.90, 4.160], [s*7.30, 4.637], [s*6.90, 5.114]
  ]);
}

// 悬臂周围的让位槽 (只切内台阶, 不切翻边; 让 5.2 mm 悬臂能自由回弹)
module hook_pockets() {
  for (x = [-11, 9], s = [-1,1])
    translate([x, s*6.14, 1.715]) cube([7.2, 1.68, 1.47], center=true);  // z 0.98..2.45
}

module hooks() {
  for (x = [-11, 9])
    for (s = [-1,1])
      hook_one(x, s);
}

// 开关引脚下方浅舱 (横置时引脚沿 Y 分布, 留足两种可能)
module switch_pin_pocket() {
  translate([sw_cx, 0, 1.4]) linear_extrude(1.1) rrect2d(11.0, 9.0, 1.0);
}

module lid() {
  union() {
    difference() {
      lid_base();
      hook_pockets();
      switch_pin_pocket();
    }
    hooks();
  }
}

// ============================================================
//  装配预览件 (不打印)
// ============================================================
module male_conn() {
  rr_prism_x(m_shell_tip, m_shoulder, 0, z_usb, m_shell_w, m_shell_h, 1.0);
  rr_prism_x(m_shoulder,  m_body_rear, 0, z_usb, m_body_w, m_body_h, 1.5);
  for (i = [0:3])
    translate([m_body_rear + m_elbow/2, (i-1.5)*m_pin_pitch, z_usb - m_body_h/2 - m_pin_drop/2])
      cube([m_elbow, m_pin_w, m_pin_drop], center=true);
}

module female_conn() {
  rr_prism_x(f_rear, f_shoulder, 0, z_usb, f_shell_w, f_shell_h, 1.5);
  for (i = [0:3])
    translate([f_rear + 1.4, (i-1.5)*m_pin_pitch, z_usb - f_shell_h/2 - f_pin_drop/2])
      cube([2.4, m_pin_w, f_pin_drop], center=true);
  for (y = [-3.5, 3.5])
    translate([f_rear + 1.4, y, z_usb - f_shell_h/2 - f_post_drop/2])
      sphere(r=1.25, $fn=24);
}

module switch_conn() {
  translate([sw_cx, 0, 0]) rr_prism_z(sw_body_x, sw_body_y, 1.5, sw_seat-sw_body_t, sw_seat);
  translate([sw_cx, 0, 0]) rr_prism_z(sw_bz_x,   sw_bz_y,   2.0, sw_seat, H);
  for (y = [-2.5, 2.5])
    translate([sw_cx - sw_tab_t/2, y - sw_tab_w/2, sw_seat-sw_body_t-sw_pin_len])
      cube([sw_tab_t, sw_tab_w, sw_pin_len]);
}

module assembly() {
  color([0.78,0.80,0.85,1]) body();
  color([0.70,0.72,0.78,1]) lid();
  color([0.90,0.25,0.25,0.40]) male_conn();
  color([0.25,0.60,0.90,0.40]) female_conn();
  color([0.25,0.85,0.55,0.40]) switch_conn();
}

// ============================================================
//  尺寸自检
// ============================================================
module checks() {
  echo(str("[check] case outer      = ", L, " x ", W, " x ", H));
  echo(str("[check] cavity          = ", cav_d, " x ", cav_w));
  echo(str("[check] male shell tip  = ", m_shell_tip, " (case face ", front_face, ")"));
  echo(str("[check] male pin tip z  = ", z_usb - m_body_h/2 - m_pin_drop, " (floor ", z_floor, ")"));
  echo(str("[check] female pin tip z= ", z_usb - f_shell_h/2 - f_pin_drop, " (floor ", z_floor, ")"));
  echo(str("[check] switch pin tip z= ", sw_seat - sw_body_t - sw_pin_len, " (floor ", z_floor, ", pocket 1.0)"));
  echo(str("[check] switch seat     = ", sw_seat, " ledge ", ledge_t));

  assert(m_shell_tip < front_face, "公头未能伸出外壳");
  assert(z_usb - m_body_h/2 - m_pin_drop > z_floor + 0.4, "公头引脚顶到底盖");
  assert(z_usb - f_shell_h/2 - f_pin_drop > z_floor + 0.4, "母座引脚顶到底盖");
  assert(sw_seat - sw_body_t - sw_pin_len > z_floor - 1.0, "开关引脚超出底盖可容纳范围");
  assert(ledge_t >= 0.6, "开关沉槽台阶太薄");
  assert(cav_w > sw_body_y + 0.3, "开关本体放不进内腔");
  assert(sw_body_rear + 0.8 <= f_rear, "开关与母座干涉");
  assert(sw_body_front > m_pin_rear + 0.6, "开关与公头引脚干涉");
  assert(f_shoulder < back_face, "母座定位槽超出后壁");
  assert(12.3 > m_shell_w + 0.15, "公头通孔过小");
  assert(12.3 < m_body_w, "公头通孔大于本体, 无法限位");
  assert(12.6 < f_shell_w, "母座通孔大于外壳, 无法限位");
  assert(12.6 > 12.05 + 0.4, "母座通孔比插头还小");
  assert(sw_hole_x > sw_body_x + 0.3, "开关过孔 X 向余量不足");
  assert(sw_hole_y > sw_body_y + 0.3, "开关过孔 Y 向余量不足");
  assert(sw_hole_y < sw_bz_y, "开关过孔大于面板, 开关会掉进去");
  assert(sw_rec_y < W - 2*top_inset - 0.8, "开关沉槽离外壳顶边太近");
  assert(sw_cx - sw_rec_x/2 > front_face + 1.0, "开关沉槽超出前端");
  assert(sw_cx + sw_rec_x/2 < back_face - 1.0, "开关沉槽超出后端");
}

// ============================================================
if (part == "body")      body();
if (part == "lid")       lid();
if (part == "assembly")  assembly();
if (part == "section")
  difference() {
    assembly();
    translate([-100, 0, -100]) cube([200, 100, 200]);   // 去掉 y>0, 从 +Y 看剖面
  }

checks();
