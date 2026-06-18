#!/usr/bin/env python3
"""Genera miniaturas JPEG ligeras (nombres ASCII) para la galería de Reportes."""
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

# id corto -> archivo fuente en www/mapas/
MANIFEST: dict[str, str] = {
    "aa": "MAPA_ACR_AA_page-0001.jpg",
    "anpch": "MAPA_ACR_ANPCH_page-0001.jpg",
    "ctt": "MAPA_ACR_CTT_page-0001.jpg",
    "mk": "MAPA_ACR_MK_page-0001.jpg",
    "boshumi": "25NOV17_Mapa_de_deforestación_en_ACR_BOSHUMI_y_su_ZI_A2.jpg",
    "ce": "25NOV17_Mapa_de_deforestación_en_ACR_CE_y_su_ZI_A2.jpg",
    "chq": "MAPA_CHOQUE_DEF_page-0001.jpg",
    "chu": "MAPA_CHUYAPI_ANEXO2_page-0001.jpg",
    "qk": "MAPA_QEROS_ANEXO3_page-0001.jpg",
}


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


def resolve_source(name: str) -> Path | None:
    direct = SRC / name
    if direct.exists():
        return direct
    stem = name.split(".")[0][:24]
    for candidate in SRC.glob("*.jpg"):
        if candidate.name == name or stem in candidate.name:
            return candidate
    return None


def main() -> None:
    if not SRC.is_dir():
        print(f"No existe {SRC}")
        sys.exit(1)
    total_before = total_after = 0
    for map_id, source_name in MANIFEST.items():
        src = resolve_source(source_name)
        if not src:
            print(f"  [omitido] {map_id}: no se encontró {source_name}")
            continue
        out = OUT / f"{map_id}.jpg"
        before, after = optimize(src, out)
        total_before += before
        total_after += after
        print(f"  {map_id}.jpg <- {src.name}: {before // 1024} KB -> {after // 1024} KB")
    print(f"Total: {total_before // 1024} KB -> {total_after // 1024} KB")


if __name__ == "__main__":
    main()
