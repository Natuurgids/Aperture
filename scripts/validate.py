"""Run the deterministic local validation sequence used by CI."""

from __future__ import annotations

import shutil
import subprocess
import sys
from collections.abc import Sequence


def _run(command: Sequence[str], *, required: bool = True) -> int:
    executable = command[0]
    if executable != sys.executable and shutil.which(executable) is None:
        message = f"validation tool is not installed: {executable}"
        if required:
            print(message, file=sys.stderr)
            return 127
        print(f"SKIP: {message}")
        return 0
    completed = subprocess.run(command, check=False)
    return completed.returncode


def main() -> int:
    commands = (
        ((sys.executable, "-m", "compileall", "-q", "src", "tests"), True),
        (("ruff", "check", "."), True),
        (("ruff", "format", "--check", "."), True),
        (("mypy",), True),
        (("lint-imports",), True),
        (("pytest",), True),
    )
    for command, required in commands:
        return_code = _run(command, required=required)
        if return_code != 0:
            return return_code
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
