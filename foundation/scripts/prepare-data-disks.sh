#!/usr/bin/env bash
set -euo pipefail

prepare_disk() {
  local device="$1"
  local label="$2"
  local mount_point="$3"

  for _ in {1..150}; do
    [[ -b "$device" ]] && break
    sleep 2
  done

  if [[ ! -b "$device" ]]; then
    echo "Data disk not found: $device" >&2
    exit 1
  fi

  local filesystem_type
  filesystem_type="$(blkid -o value -s TYPE "$device" || true)"

  if [[ -z "$filesystem_type" ]]; then
    mkfs.ext4 -L "$label" "$device"
  elif [[ "$filesystem_type" != "ext4" ]]; then
    echo "Refusing to mount $device: expected ext4, found $filesystem_type" >&2
    exit 1
  fi

  mkdir -p "$mount_point"

  if ! grep -q "^LABEL=${label}[[:space:]]" /etc/fstab; then
    printf 'LABEL=%s %s ext4 defaults,nofail,nodev,nosuid 0 2\n' "$label" "$mount_point" >> /etc/fstab
  fi

  mountpoint -q "$mount_point" || mount "$mount_point"
}

prepare_disk /dev/disk/azure/scsi1/lun0 pnstate /srv/polinetwork/state
prepare_disk /dev/disk/azure/scsi1/lun1 pnapplications /srv/polinetwork/applications
