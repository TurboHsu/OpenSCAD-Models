# AGENTS.md

本仓库用于管理自制 3D 打印 OpenSCAD 模型。AI Agent 在本仓库中新建或修改模型时，请遵循以下规范。

## 1. 环境与偏好配置

开始工作前，先了解仓库根目录的两个本机配置文件（均已被 `.gitignore` 忽略）：

- **`.env`**（模板 `.env.example`）：存放本机工具路径，如 `OPENSCAD_CLI`、`OPENSCAD_GUI`。
  - 渲染脚本会自动读取 `.env` 中的 `OPENSCAD_CLI`。
  - Windows 下命令行渲染必须使用 `openscad.com` 而非 `openscad.exe`，否则命令不会等待渲染完成且无控制台输出。
- **`LOCAL.md`**（模板 `LOCAL.md.example`）：记录用户的本机打印偏好、已校准耗材（如 PETG）、公差经验与设计习惯。建模前应优先阅读此文件。

## 2. 目录结构规范

```text
Models/
├── AGENTS.md                 # Agent 工作规范（本文件）
├── .env                      # 本机工具路径，如 OPENSCAD_CLI（gitignored）
├── .env.example              # .env 模板
├── LOCAL.md                  # 本机打印与设计偏好（gitignored）
├── LOCAL.md.example          # LOCAL.md 模板
├── scripts/
│   ├── render.py             # Python 渲染脚本（导出 STL 与预览 PNG）
│   └── render.ps1            # Windows PowerShell 渲染脚本（免 Python 依赖）
└── <model_name>/
    ├── <model_name>.scad     # 主 OpenSCAD 参数化源码
    ├── render.json           # 【必备】该模型的 STL 导出与预览图渲染配置
    ├── README.md             # （可选）尺寸说明、装配与切片建议
    ├── ref/                  # （可选）参考图纸/照片（受 git 跟踪）
    ├── stl/                  # 生成的 STL（gitignored）
    └── preview/              # 生成的预览 PNG（gitignored）
```

## 3. 模型渲染配置规范 (`<model_name>/render.json`)

**每个模型目录下都应维护一份 `render.json`**，声明该模型需要导出的所有打印件 STL 以及用于验收的多角度预览图 PNG，确保任何时候都可通过脚本一键复现全部产物。

### 字段说明

```json
{
  "scad": "my_model.scad",
  "stls": [
    {
      "output": "stl/body.stl",
      "defines": { "part": "body" }
    },
    {
      "output": "stl/lid.stl",
      "defines": { "part": "lid" }
    }
  ],
  "previews": [
    {
      "output": "preview/iso.png",
      "defines": { "part": "assembly" },
      "camera": "130,-95,115,10,8,17",
      "imgsize": "900,700"
    },
    {
      "output": "preview/side.png",
      "camera": "10,8,200,10,8,17",
      "projection": "ortho",
      "imgsize": "900,700"
    }
  ]
}
```

- `scad`（必填）：默认主 `.scad` 文件名（相对于当前模型目录）。
- `stls`（数组）：需要导出的 STL 列表。
  - `output`（必填）：输出路径，统一放在 `stl/<name>.stl`。
  - `scad`（可选）：覆盖顶层 `scad` 文件名。
  - `defines`（可选）：传递给 OpenSCAD 的 `-D key=value` 参数字典（字符串自动加引号，布尔/数值原样传递）。
- `previews`（数组）：需要渲染的预览图列表。
  - `output`（必填）：输出路径，统一放在 `preview/<name>.png`。
  - `camera`（可选）：OpenSCAD `--camera` 参数（如 `"eye_x,eye_y,eye_z,center_x,center_y,center_z"`）。
  - `projection`（可选）：`"ortho"` 或 `"perspective"`。
  - `imgsize`（可选）：分辨率，默认 `"900,700"`。
  - `defines` / `scad`（可选）：同上。

> 新建模型或新增部件/变体时，务必同步创建或更新对应目录的 `render.json`。

## 4. Git 跟踪与提交规范

- **不提交**所有 3D 网格与专有 CAD 源文件（`*.stl`、`*.3mf`、`*.obj`、`*.SLDPRT`，含参考模型）以及生成的预览图（`*.png`、`*.jpg`），所有产物通过 `render.json` + 渲染脚本一键复现。
- **保留跟踪**参考图片/图纸：放入 `<model_name>/ref/` 目录的参考图（如尺寸图、实物照片）不会被 `.gitignore` 忽略。
- **不提交**本机配置文件 `.env` 与 `LOCAL.md`。
- **自动提交（重要）**：每次完成较大的建模/绘图操作并渲染验证通过后——例如**新建模型**、**按用户需求完成一轮版本迭代（如 V1 → V2、结构调整、尺寸大改）**——都应**自动执行 `git commit`**，记录清晰的提交说明（如 `feat(sony_xm4_desk_hanger): add v1 desk clip hanger`、`feat(xxx): v2 adjust clamp preload and lip height`），以便随时追溯与回滚。

## 5. OpenSCAD 设计与验证规范

1. **参数化**：所有关键尺寸、间隙、壁厚集中在 `.scad` 文件顶部，并附清晰注释（单位 `mm`）。
2. **面向打印（DFM）**：
   - 默认以推荐打印姿态建模（底面平贴 `Z = 0`），优先免支撑或极少支撑。
   - 受力件（如夹具、挂钩、卡扣）尽量使层纹沿主受力路径连续走向。
   - 兼顾省料、强度与外观（倒角/圆角消除应力集中与首层象脚）。
3. **必须渲染验证**：
   - 每次新建或修改 `.scad` 后，更新 `render.json` 并运行渲染脚本生成 STL 与预览图。
   - 检查 OpenSCAD 输出中 `Status: NoError` 且为合法流形（manifold）。
   - **务必查看生成的预览 PNG**（含关键装配剖面图），确认无几何穿插、布尔误切、悬空或方向错误后再交付。
4. **多件装配与交付打印前的深度复查清单（重要）**：
   不要只凭肉眼看外观预览就宣告可打印；涉及**多件卡扣/插接装配、内嵌电子件（PCB/排针/开发板/USB-C）或免支撑结构**时，交付前应通过脚本对导出的 STL 与装配体执行以下量化复查：
   - **布尔干涉检测（CSG Intersection Check）**：用 OpenSCAD `intersection()` 逐对检查所有装配配合件（如前壳 vs 后盖、底座 vs 底盖、插接本体 vs 底座插槽）以及内嵌硬件包络体（PCB、开发板、排针/插头探针），确认除刻意设计的卡扣过盈外**零实体重叠**（特别警惕不同平面圆角半径不匹配导致的拐角顶死，以及内壁定位筋与对侧壳壁碰撞）。
   - **通孔/插槽贯通性探针**：对排针孔、接口开口（如 Type-C 插头护套，而不仅是金属口尺寸）、走线过道用实体探针做 `intersection()`，确保全程畅通无内部加强筋或收口斜壁误遮挡。
   - **贴床、单连通体与流形拓扑**：检查每个 STL 的 `Z_min == 0.000`（无浮空）、贴床面积充足、连通壳体数 `shells == 1`（无悬浮碎块）、无非流形边。
   - **悬垂与桥接跨度扫描**：统计朝下（法向 `n_z < -sin(52°)` 且 `Z > 0.15 mm`）的面片面积与空间范围；若宣称免支撑，需确认无大跨度水平悬顶（PETG 建议桥接 `<= 20 mm`，或改用 45° 收口穹顶/倒置薄壳掏空）。
   - **最薄外壁与卡扣余量**：核对卡扣暗槽、避让槽处的剩余外壁厚度，确保 `>= 1.2 mm`（0.4 mm 喷嘴至少 3 圈壁厚），避免外壁透痕或掰断。
   - **参数化开关回归**：若模型包含布尔开关（如工牌孔、亚克力槽等），交付前需验证非默认组合同样能无报错编译且联动尺寸正确。
   - **增量修改红线**：若用户已明确表示某部件正在打印，后续迭代**严禁改动该部件及与其配合的基准接口尺寸**。

## 6. 渲染命令

Python（跨平台，零第三方依赖）：
```bash
python scripts/render.py <model_name>                # 按 render.json 导出 STL + 预览 PNG
python scripts/render.py <model_name> --stl-only     # 仅导出 STL
python scripts/render.py <model_name> --preview-only # 仅渲染预览图
python scripts/render.py --all                       # 渲染仓库内所有模型
```

Windows PowerShell（无需安装 Python）：
```powershell
.\scripts\render.ps1 <model_name>
.\scripts\render.ps1 <model_name> -StlOnly
.\scripts\render.ps1 <model_name> -PreviewOnly
.\scripts\render.ps1 -All
```
