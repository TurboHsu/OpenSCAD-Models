#!/usr/bin/env python3
"""Render OpenSCAD models into STL files and PNG preview images.

Reads OpenSCAD CLI path from:
  1. --openscad CLI argument
  2. OPENSCAD_CLI / OPENSCAD environment variable
  3. Root .env (OPENSCAD_CLI=... or OPENSCAD=...)
  4. Common system paths / PATH

Reads per-model targets from <model_dir>/render.json (falls back to defaults if absent).

Usage:
  python scripts/render.py <model_dir>
  python scripts/render.py --all
  python scripts/render.py <model_dir> --stl-only
  python scripts/render.py <model_dir> --preview-only
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parent.parent

DEFAULT_PREVIEWS = [
    {
        "output": "preview/iso.png",
        "camera": "130,-95,115,0,0,0",
        "imgsize": "900,700",
    },
    {
        "output": "preview/side.png",
        "camera": "0,0,200,0,0,0",
        "projection": "ortho",
        "imgsize": "900,700",
    },
    {
        "output": "preview/front.png",
        "camera": "200,0,0,0,0,0",
        "projection": "ortho",
        "imgsize": "900,700",
    },
]


def load_dotenv(env_path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    if not env_path.is_file():
        return values
    for raw in env_path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, val = line.split("=", 1)
        values[key.strip()] = val.strip().strip('"').strip("'")
    return values


def find_openscad(explicit: str | None) -> str:
    candidates: list[str] = []
    if explicit:
        candidates.append(explicit)
    for env_key in ("OPENSCAD_CLI", "OPENSCAD"):
        if os.environ.get(env_key):
            candidates.append(os.environ[env_key])

    dotenv = load_dotenv(REPO_ROOT / ".env")
    for env_key in ("OPENSCAD_CLI", "OPENSCAD"):
        if dotenv.get(env_key):
            candidates.append(dotenv[env_key])

    candidates.extend(
        [
            r"C:\Program Files\OpenSCAD\openscad.com",
            r"C:\Program Files\OpenSCAD (Nightly)\openscad.com",
            "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD",
            "openscad",
        ]
    )

    for cand in candidates:
        if Path(cand).is_file():
            return str(Path(cand))
        resolved = shutil.which(cand)
        if resolved:
            return resolved

    raise FileNotFoundError(
        "OpenSCAD CLI not found. Set OPENSCAD_CLI in .env or pass --openscad."
    )


def format_define(key: str, val: Any) -> str:
    if isinstance(val, bool):
        return f"{key}={'true' if val else 'false'}"
    if isinstance(val, (int, float)):
        return f"{key}={val}"
    escaped = str(val).replace("\\", "\\\\").replace('"', '\\"')
    return f'{key}="{escaped}"'


STRICT_FLAGS = [
    "--hardwarnings",
    "--check-parameters=true",
    "--check-parameter-ranges=true",
]


def run_openscad(openscad: str, args: list[str], parse_summary: bool = False) -> None:
    cmd = [openscad, *args]
    print("  >", " ".join(f'"{c}"' if " " in c else c for c in cmd))
    result = subprocess.run(cmd, capture_output=True, text=True)
    json_line: str | None = None
    for stream in (result.stdout, result.stderr):
        if not stream.strip():
            continue
        for line in stream.strip().splitlines():
            if parse_summary and line.lstrip().startswith("{"):
                json_line = line
            elif any(k in line for k in ("Status:", "Facets:", "Vertices:", "WARNING", "ERROR", "ECHO:")):
                print("    ", line)
    if result.returncode != 0:
        if result.stderr.strip():
            print(result.stderr, file=sys.stderr)
        raise RuntimeError(f"OpenSCAD exited with code {result.returncode}")
    if parse_summary and json_line:
        try:
            data = json.loads(json_line)
            geom = data.get("geometry")
            if geom:
                bbox = geom.get("bounding_box", {})
                size = [round(v, 2) for v in bbox.get("size", [])]
                z_min = round(bbox.get("min", [0, 0, 0])[2], 3)
                print(
                    f"    Geometry: simple={geom.get('simple')} dims={geom.get('dimensions')} "
                    f"facets={geom.get('facets')} size={size} Z_min={z_min:.3f}"
                )
                if not geom.get("simple"):
                    raise RuntimeError("Non-simple / non-manifold geometry detected!")
        except json.JSONDecodeError:
            pass


def discover_models() -> list[Path]:
    models: list[Path] = []
    for entry in sorted(REPO_ROOT.iterdir()):
        if not entry.is_dir() or entry.name.startswith(".") or entry.name == "scripts":
            continue
        if list(entry.glob("*.scad")):
            models.append(entry)
    return models


def resolve_config(model_dir: Path) -> dict[str, Any]:
    manifest = model_dir / "render.json"
    if manifest.is_file():
        return json.loads(manifest.read_text(encoding="utf-8"))

    scad_files = sorted(model_dir.glob("*.scad"))
    if not scad_files:
        raise FileNotFoundError(f"No .scad files found in {model_dir}")

    preferred = model_dir / f"{model_dir.name}.scad"
    scad_file = preferred if preferred.is_file() else scad_files[0]
    return {
        "scad": scad_file.name,
        "stls": [{"output": f"stl/{scad_file.stem}.stl"}],
        "previews": DEFAULT_PREVIEWS,
    }


def render_model(
    openscad: str, model_dir: Path, do_stl: bool, do_preview: bool, strict: bool = True
) -> None:
    print(f"\n=== {model_dir.name} ===")
    cfg = resolve_config(model_dir)
    default_scad = model_dir / cfg["scad"]
    strict_args = list(STRICT_FLAGS) if strict else []

    if do_stl:
        for item in cfg.get("stls", []):
            scad_path = model_dir / item.get("scad", cfg["scad"])
            out_path = model_dir / item["output"]
            out_path.parent.mkdir(parents=True, exist_ok=True)
            args: list[str] = [*strict_args, "--summary=all", "--summary-file=-"]
            for k, v in item.get("defines", {}).items():
                args.extend(["-D", format_define(k, v)])
            args.extend(["-o", str(out_path), str(scad_path)])
            run_openscad(openscad, args, parse_summary=True)

    if do_preview:
        for item in cfg.get("previews", []):
            scad_path = model_dir / item.get("scad", default_scad.name)
            out_path = model_dir / item["output"]
            out_path.parent.mkdir(parents=True, exist_ok=True)
            args = [
                *strict_args,
                "--autocenter",
                "--viewall",
                f"--imgsize={item.get('imgsize', '900,700')}",
            ]
            if item.get("camera"):
                args.append(f"--camera={item['camera']}")
            if item.get("projection"):
                args.append(f"--projection={item['projection']}")
            for k, v in item.get("defines", {}).items():
                args.extend(["-D", format_define(k, v)])
            args.extend(["-o", str(out_path), str(scad_path)])
            run_openscad(openscad, args)


def main() -> int:
    parser = argparse.ArgumentParser(description="Render OpenSCAD STLs and PNG previews.")
    parser.add_argument("models", nargs="*", help="Model directory name(s) to render.")
    parser.add_argument("--all", action="store_true", help="Render all model directories.")
    parser.add_argument("--stl-only", action="store_true", help="Only export STL files.")
    parser.add_argument("--preview-only", action="store_true", help="Only render PNG previews.")
    parser.add_argument("--no-strict", action="store_true", help="Disable strict OpenSCAD warning/parameter checks.")
    parser.add_argument("--openscad", default=None, help="Explicit OpenSCAD CLI path.")
    args = parser.parse_args()

    if not args.all and not args.models:
        parser.error("Specify one or more model directories, or pass --all.")
    if args.stl_only and args.preview_only:
        parser.error("Cannot combine --stl-only and --preview-only.")

    openscad = find_openscad(args.openscad)
    print(f"Using OpenSCAD: {openscad}")

    targets = discover_models() if args.all else [REPO_ROOT / m for m in args.models]
    do_stl = not args.preview_only
    do_preview = not args.stl_only

    for target in targets:
        if not target.is_dir():
            print(f"Error: model directory not found: {target}", file=sys.stderr)
            return 1
        render_model(openscad, target, do_stl=do_stl, do_preview=do_preview, strict=not args.no_strict)

    print("\nDone.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
