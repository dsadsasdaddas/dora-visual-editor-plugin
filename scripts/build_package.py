#!/usr/bin/env python3
from __future__ import annotations
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
import zipfile
from pathlib import Path

VERSION = "0.1.1"
PACKAGE = "dora-visual-editor"
OWNER = "dsadsasdaddas"
REPO = "dora-visual-editor-plugin"
ROOT = Path(__file__).resolve().parents[1]


def copy_tree(dora_root: Path) -> None:
    src_root = dora_root / "Assets" / "Script" / "Tools"
    dst_root = ROOT / "src" / "Script" / "Tools"
    (dst_root / "SceneEditor").mkdir(parents=True, exist_ok=True)
    for name in ["SceneImGuiEditor.lua", "SceneImGuiEditor.ts"]:
        shutil.copy2(src_root / name, dst_root / name)
    for file in (src_root / "SceneEditor").glob("*"):
        if file.suffix in {".lua", ".ts"}:
            shutil.copy2(file, dst_root / "SceneEditor" / file.name)


def write_init(package_root: Path) -> None:
    (package_root / "init.lua").write_text(
        "-- Dora Visual Editor package entry.\n"
        "-- ResourceDownloader runs this file after extracting the package.\n"
        "return require(\"Script.Tools.SceneImGuiEditor\")\n",
        encoding="utf-8",
    )


def build_zip() -> tuple[Path, int, str]:
    package_root = ROOT / "dist" / PACKAGE
    if package_root.exists():
        shutil.rmtree(package_root)
    shutil.copytree(ROOT / "src", package_root)
    write_init(package_root)
    zip_path = ROOT / "dist" / f"{PACKAGE}-{VERSION}.zip"
    if zip_path.exists():
        zip_path.unlink()
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for file in sorted(package_root.rglob("*")):
            if file.is_file():
                zf.write(file, file.relative_to(package_root).as_posix())
    data = zip_path.read_bytes()
    return zip_path, len(data), hashlib.sha256(data).hexdigest()


def write_manifests(zip_path: Path, size: int, sha256: str) -> None:
    updated_at = int(time.time())
    download = f"https://github.com/{OWNER}/{REPO}/releases/download/v{VERSION}/{zip_path.name}"
    packages = [
        {
            "name": PACKAGE,
            "url": f"https://github.com/{OWNER}/{REPO}",
            "versions": [
                {
                    "file": zip_path.name,
                    "size": size,
                    "tag": f"v{VERSION}",
                    "commit": current_commit(),
                    "download": download,
                    "updatedAt": updated_at,
                    "sha256": sha256,
                }
            ],
        }
    ]
    repos = [
        {
            "name": PACKAGE,
            "title": {"zh": "Dora 2D 可视化编辑器", "en": "Dora 2D Visual Editor"},
            "desc": {
                "zh": "原生 ImGui 2D 场景编辑器：节点树、真实 Dora Viewport、资源导入、脚本入口。",
                "en": "Native ImGui 2D scene editor with node tree, real Dora viewport, asset import, and script entry.",
            },
            "categories": ["tool", "editor", "2d"],
            "exe": True,
        }
    ]
    (ROOT / "api" / "v1").mkdir(parents=True, exist_ok=True)
    (ROOT / "assets").mkdir(parents=True, exist_ok=True)
    (ROOT / "api" / "v1" / "package-list-version").write_text(
        json.dumps({"version": updated_at, "updatedAt": updated_at}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    (ROOT / "api" / "v1" / "packages").write_text(
        json.dumps(packages, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    (ROOT / "assets" / "repos.json").write_text(
        json.dumps(repos, ensure_ascii=False, indent=2), encoding="utf-8"
    )


def current_commit() -> str:
    try:
        return subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    except Exception:
        return ""


def ensure_banner() -> None:
    # tiny fallback file; replace with real jpg/png later if desired
    banner = ROOT / "assets" / PACKAGE / "banner.jpg"
    if not banner.exists():
        try:
            from PIL import Image, ImageDraw
            img = Image.new("RGB", (640, 360), (25, 28, 34))
            d = ImageDraw.Draw(img)
            d.rectangle((24, 24, 616, 336), outline=(255, 204, 51), width=4)
            d.text((52, 52), "Dora 2D Visual Editor", fill=(255, 204, 51))
            d.text((52, 96), "Native ImGui / Real Dora Viewport", fill=(210, 210, 210))
            img.save(banner, quality=90)
        except Exception:
            banner.write_bytes(b"\xff\xd8\xff\xd9")


def main() -> None:
    if len(sys.argv) < 2:
        print("usage: build_package.py /path/to/Dora-SSR", file=sys.stderr)
        raise SystemExit(2)
    dora_root = Path(sys.argv[1]).resolve()
    copy_tree(dora_root)
    ensure_banner()
    zip_path, size, sha256 = build_zip()
    write_manifests(zip_path, size, sha256)
    print(f"built {zip_path}")
    print(f"size={size}")
    print(f"sha256={sha256}")

if __name__ == "__main__":
    main()
