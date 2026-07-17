"""Validate an Aperture release tree before Windows deployment mutates the machine."""
from __future__ import annotations

import argparse
import hashlib
import json
import platform
import sys
import zipfile
from dataclasses import asdict, dataclass
from pathlib import Path


@dataclass(frozen=True, slots=True)
class Check:
    name: str
    passed: bool
    detail: str


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_release(root: Path) -> dict[str, object]:
    required = (
        "pyproject.toml",
        "RELEASE_NOTES.md",
        "RELEASE_MANIFEST.json",
        "scripts/install_windows.ps1",
        "scripts/uninstall_windows.ps1",
        "scripts/verify_install.py",
        "resources/aperture.ico",
    )
    checks = [Check(f"required:{name}", (root / name).is_file(), name) for name in required]
    version = "unknown"
    init_path = root / "src/natureai_next/__init__.py"
    if init_path.is_file():
        for line in init_path.read_text(encoding="utf-8").splitlines():
            if line.startswith("__version__"):
                version = line.split("=", 1)[1].strip().strip('"\'')
                break
    manifest_path = root / "RELEASE_MANIFEST.json"
    manifest_verified = False
    manifest_count = 0
    if manifest_path.is_file():
        try:
            data = json.loads(manifest_path.read_text(encoding="utf-8"))
            entries = data.get("files", data if isinstance(data, list) else [])
            failures: list[str] = []
            for entry in entries:
                relative = entry.get("path")
                if not relative:
                    continue
                path = root / relative
                manifest_count += 1
                if not path.is_file():
                    failures.append(f"missing:{relative}")
                elif entry.get("size") is not None and path.stat().st_size != int(entry["size"]):
                    failures.append(f"size:{relative}")
                elif entry.get("sha256") and _sha256(path) != entry["sha256"]:
                    failures.append(f"sha256:{relative}")
            manifest_verified = not failures and manifest_count > 0
            checks.append(Check("release_manifest", manifest_verified, ", ".join(failures[:10]) or f"{manifest_count} files"))
        except Exception as exc:  # deployment report must explain malformed input
            checks.append(Check("release_manifest", False, str(exc)))
    checks.append(Check("python_launcher", sys.version_info >= (3, 11), sys.version.replace("\n", " ")))
    return {
        "product": "Aperture",
        "engine": "NatureAI_Next",
        "version": version,
        "platform": platform.platform(),
        "release_root": str(root.resolve()),
        "checks": [asdict(check) for check in checks],
        "passed": all(check.passed for check in checks),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--release-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = validate_release(args.release_root)
    rendered = json.dumps(report, indent=2, sort_keys=True)
    print(rendered)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered + "\n", encoding="utf-8")
    return 0 if report["passed"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
