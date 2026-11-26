# OpenSCAD-Models

自制参数化 3D 打印 OpenSCAD 模型仓库。所有模型均以源码 + `render.json` 形式管理，生成的 STL 与多角度预览图均可通过渲染脚本一键复现（仓库本身不提交二进制网格与生成预览图，仅保留源码与 `ref/` 参考图）。

---

## 模型列表

| 目录 | 说明 | 关键特性 | 文档 |
| :--- | :--- | :--- | :--- |
| [`huawei_eink/`](huawei_eink/) | 华为 3.7" 彩显墨水屏桌面摆件 + Apple iPod 风格底座 | 超薄 `6.4 mm` 6 卡扣免胶外壳、不对称 2×4pin 防反插、内置 `ESP32-C3 Mini Pro`、参数化工牌孔/亚克力槽 | [README](huawei_eink/README.md) |
| [`sony_xm4_desk_hanger/`](sony_xm4_desk_hanger/) | Sony WH-1000XM4 桌边夹持耳机挂架 | 适配 `29.3 mm` 桌面厚度、PETG 弹性预紧夹持、R85 弧形头梁托、100% 免支撑侧放打印 | [源码](sony_xm4_desk_hanger/sony_xm4_desk_hanger.scad) |
| [`usb_a_dc_switch/`](usb_a_dc_switch/) | USB-A 公→母 5V 船型开关直通外壳（无 PCB） | 紧凑横置 KCD11 开关（`37 × 17.8 × 20.5 mm`）、暗缝底盖、PETG 免支撑 | [README](usb_a_dc_switch/README.md) |
| [`screen_fan_mount/`](screen_fan_mount/) | 80mm 风扇 → 纱窗 → 75mm 弯管/烟管夹座 | 室内外磁吸/咬合夹座、支持一体 90° 扁口弯管或 75 烟管插嘴、圆板/方板多变体 | [README](screen_fan_mount/README.md) |

---

## 环境配置

1. 安装 [OpenSCAD](https://openscad.org/)（推荐 2026+ 版本，支持 Manifold 后端与 `--summary` JSON 统计）。
2. 复制模板文件配置本机路径与打印偏好（均为 `.gitignore` 忽略，不提交）：
   ```bash
   cp .env.example .env
   cp LOCAL.md.example LOCAL.md
   ```
   > Windows 下 `.env` 中的 `OPENSCAD_CLI` 需指向 `openscad.com`（同步控制台程序），而非 `openscad.exe`。

---

## 一键导出 STL 与预览图

每个模型目录下均有 `render.json` 声明全部导出目标，渲染脚本默认开启 OpenSCAD 严格检查（`--hardwarnings --check-parameters=true --check-parameter-ranges=true`）并输出流形与贴床（`Z_min`）几何摘要。

**Python（跨平台，零第三方依赖）：**

```bash
python scripts/render.py <model_name>                # 导出 STL + 预览 PNG
python scripts/render.py <model_name> --stl-only     # 仅导出 STL
python scripts/render.py <model_name> --preview-only # 仅渲染预览图
python scripts/render.py --all                       # 渲染仓库内所有模型
```

**Windows PowerShell（无需 Python）：**

```powershell
.\scripts\render.ps1 <model_name>
.\scripts\render.ps1 <model_name> -StlOnly
.\scripts\render.ps1 <model_name> -PreviewOnly
.\scripts\render.ps1 -All
```

---

## 仓库目录规范

```text
OpenSCAD-Models/
├── README.md                 # 仓库总览（本文件）
├── AGENTS.md                 # AI Agent 建模、DFM 复查与 OpenSCAD 严格校验规范
├── .env.example              # 本机 OpenSCAD 路径模板
├── LOCAL.md.example          # 本机耗材与公差偏好模板
├── scripts/
│   ├── render.py             # Python 一键渲染脚本
│   └── render.ps1            # PowerShell 一键渲染脚本
└── <model_name>/
    ├── <model_name>.scad     # 参数化 OpenSCAD 源码
    ├── render.json           # STL 与预览图渲染清单
    ├── README.md             # （可选）装配、接线与切片说明
    ├── ref/                  # （可选）实物照片/参考图纸（受 git 跟踪）
    ├── stl/                  # 导出的 STL（gitignored）
    └── preview/              # 生成的预览 PNG（gitignored）
```
