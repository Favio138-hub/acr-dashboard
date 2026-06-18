#!/usr/bin/env python3
"""Genera miniaturas JPEG ligeras para la galería de Reportes."""
from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    import subprocess

    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow", "-q"])
    from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "www" / "mapas"
OUT = SRC / "thumbs"
MAX_WIDTH = 520
QUALITY = 80


def optimize(path: Path, out: Path) -> tuple[int, int]:
    img = Image.open(path)
    if img.mode in ("RGBA", "P"):
        img = img.convert("RGB")
    w, h = img.size
    if w > MAX_WIDTH:
        nh = int(h * (MAX_WIDTH / w))
        img = img.resize((MAX_WIDTH, nh), Image.Resampling.LANCZOS)
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out, "JPEG", quality=QUALITY, optimize=True, progressive=True)
    return path.stat().st_size, out.stat().st_size


def main() -> None:
    if not SRC.is_dir():
        print(f"No existe {SRC}")
        sys.exit(1)
    total_before = total_after = 0
    for jpg in sorted(SRC.glob("*.jpg")):
        out = OUT / jpg.name
        before, after = optimize(jpg, out)
        total_before += before
        total_after += after
        print(f"  {jpg.name}: {before // 1024} KB -> {after // 1024} KB")
    print(f"Total: {total_before // 1024} KB -> {total_after // 1024} KB ({len(list(OUT.glob('*.jpg')))} thumbs)")


if __name__ == "__main__":
    main()
