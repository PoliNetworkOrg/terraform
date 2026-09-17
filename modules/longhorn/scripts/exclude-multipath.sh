#!/bin/sh
set -eu

# Runs in the host mount/network namespaces. The override is for fixture tests.
config="${LONGHORN_MULTIPATH_CONFIG:-/etc/multipath.conf}"
command -v multipath >/dev/null 2>&1 || exit 0
# Refuse to modify a configuration that already fails parsing.
multipath -t >/dev/null

if ! { [ -f "$config" ] && grep -F 'vendor "^IET$"' "$config" >/dev/null && grep -F 'product "^VIRTUAL-DISK$"' "$config" >/dev/null; }; then
  candidate=$(mktemp "${config}.longhorn.XXXXXX")
  trap 'rm -f "$candidate"' EXIT HUP INT TERM
  if [ -f "$config" ]; then
    cp -p "$config" "$candidate"
    [ -e "${config}.before-longhorn" ] || cp -p "$config" "${config}.before-longhorn"
  else
    chmod 644 "$candidate"
  fi
  cat >>"$candidate" <<'CONFIG'

# Longhorn iSCSI devices must not be claimed by device-mapper multipath.
blacklist {
    device {
        vendor "^IET$"
        product "^VIRTUAL-DISK$"
    }
}
CONFIG
  mv "$candidate" "$config"
  trap - EXIT HUP INT TERM
fi

# Reload configuration only. Never flush maps, detach disks or touch filesystems.
multipath -t >/dev/null
if pgrep -x multipathd >/dev/null; then
  multipathd reconfigure
fi
