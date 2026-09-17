#!/usr/bin/env python3
"""Exercise host edits only against temporary files and stubbed host commands."""
import os
from pathlib import Path
import subprocess
import tempfile

scripts = Path(__file__).resolve().parents[1] / "scripts"
with tempfile.TemporaryDirectory() as temporary:
    root = Path(temporary)
    binary = root / "bin"
    binary.mkdir()
    for name, body in {
        "multipath": '[ "$*" = "-t" ] || exit 90\n',
        "pgrep": '[ "$*" = "-x multipathd" ] || exit 91\n',
        "multipathd": '[ "$*" = "reconfigure" ] || exit 92\nprintf "reload\\n" >> "$TEST_RELOAD_LOG"\n',
    }.items():
        target = binary / name
        target.write_text("#!/bin/sh\nset -eu\n" + body)
        target.chmod(0o755)
    config = root / "multipath.conf"
    original = "defaults {\n    user_friendly_names yes\n}\n"
    config.write_text(original)
    env = {**os.environ, "PATH": str(binary) + os.pathsep + os.environ["PATH"],
           "LONGHORN_MULTIPATH_CONFIG": str(config), "TEST_RELOAD_LOG": str(root / "reloads")}
    subprocess.run([scripts / "exclude-multipath.sh"], env=env, check=True)
    first = config.read_text()
    subprocess.run([scripts / "exclude-multipath.sh"], env=env, check=True)
    assert config.read_text() == first
    assert first.startswith(original)
    assert first.count('vendor "^IET$"') == 1
    assert first.count('product "^VIRTUAL-DISK$"') == 1
    assert Path(str(config) + ".before-longhorn").read_text() == original
    assert (root / "reloads").read_text().splitlines() == ["reload", "reload"]
    (binary / "multipath").write_text("#!/bin/sh\nexit 1\n")
    config.write_text(original)
    result = subprocess.run([scripts / "exclude-multipath.sh"], env=env)
    assert result.returncode != 0 and config.read_text() == original

fixture = "---\nkind: ConfigMap\nmetadata:\n  name: longhorn-storageclass\ndata:\n  storageclass.yaml: |\n    parameters:\n      numberOfReplicas: \"1\"\n"
render = subprocess.run([scripts / "longhorn-postrender.sh"], input=fixture, text=True, capture_output=True, check=True)
assert 'backupTargetName: "azblob"' in render.stdout
for invalid in ["---\nkind: Secret\n", render.stdout, fixture + fixture]:
    assert subprocess.run([scripts / "longhorn-postrender.sh"], input=invalid, text=True, capture_output=True).returncode != 0
print("multipath preservation, idempotence and postrenderer failure checks passed")
