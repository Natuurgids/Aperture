"""Verify a NatureAI Next source installation without modifying a library."""

from __future__ import annotations

import argparse
import importlib.metadata
import importlib.util
import json
import platform
import shutil
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Final

import natureai_next

_REQUIRED_PYTHON: Final = (3, 11)


@dataclass(frozen=True, slots=True)
class Check:
    name: str
    passed: bool
    detail: str


def _module_check(name: str, required: bool) -> Check:
    available = importlib.util.find_spec(name) is not None
    status = available or not required
    requirement = "required" if required else "optional"
    return Check(name, status, f"{requirement}; {'installed' if available else 'not installed'}")


def _distribution_check(name: str) -> Check:
    try:
        version = importlib.metadata.version(name)
    except importlib.metadata.PackageNotFoundError:
        return Check(name, False, "distribution not installed")
    return Check(name, True, version)



def _entry_point_path(name: str) -> str | None:
    executable_name = f"{name}.exe" if sys.platform == "win32" else name
    scripts_directory = Path(sys.executable).resolve().parent / ("Scripts" if sys.platform == "win32" else "bin")
    candidate = scripts_directory / executable_name
    if candidate.is_file():
        return str(candidate)
    return shutil.which(name)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--require-gui", action="store_true")
    parser.add_argument("--require-ai", action="store_true")
    args = parser.parse_args()

    checks = [
        Check("python", sys.version_info[:2] == _REQUIRED_PYTHON, sys.version.replace("\n", " ")),
        Check("natureai_next", bool(natureai_next.__version__), natureai_next.__version__),
        Check(
            "desktop_entry_point",
            _entry_point_path("natureai-next") is not None,
            str(_entry_point_path("natureai-next")),
        ),
        Check(
            "admin_entry_point",
            _entry_point_path("natureai-next-admin") is not None,
            str(_entry_point_path("natureai-next-admin")),
        ),
        Check(
            "resources_entry_point",
            _entry_point_path("natureai-next-resources") is not None,
            str(_entry_point_path("natureai-next-resources")),
        ),
        _distribution_check("Pillow"),
        _distribution_check("cryptography"),
        _module_check("PySide6", args.require_gui),
        _module_check("torch", args.require_ai),
        _module_check("torchvision", args.require_ai),
        _module_check("open_clip", args.require_ai),
        _module_check("hnswlib", args.require_ai),
    ]

    cuda: dict[str, object] = {"checked": False}
    if importlib.util.find_spec("torch") is not None:
        import torch

        cuda = {
            "checked": True,
            "torch_version": torch.__version__,
            "available": bool(torch.cuda.is_available()),
            "device": torch.cuda.get_device_name(0) if torch.cuda.is_available() else None,
        }

    report = {
        "application_version": natureai_next.__version__,
        "platform": platform.platform(),
        "python_executable": sys.executable,
        "checks": [asdict(check) for check in checks],
        "cuda": cuda,
    }
    print(json.dumps(report, indent=2, sort_keys=True))
    return 0 if all(check.passed for check in checks) else 2


if __name__ == "__main__":
    raise SystemExit(main())
