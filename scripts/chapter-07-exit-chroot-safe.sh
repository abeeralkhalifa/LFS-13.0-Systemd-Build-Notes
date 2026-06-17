#!/usr/bin/env bash
set -euo pipefail

# This script is based on:
# docs/chapter-07-entering-chroot-and-temporary-tools.md
#
# Purpose:
# Safely unmount LFS virtual filesystems after exiting chroot.
#
# Run as root on the Debian host, not inside chroot.

echo "=== LFS Chapter 7: Safe Chroot Cleanup ==="

if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: This script must be run as root."
  echo "Use: sudo ./scripts/chapter-07-exit-chroot-safe.sh"
  exit 1
fi

export LFS="${LFS:-/mnt/lfs}"

echo
echo "[1] Environment check"
echo "LFS=$LFS"

if [[ "$LFS" != "/mnt/lfs" ]]; then
  echo "WARNING: LFS is not /mnt/lfs"
  read -rp "Continue anyway? Type YES: " confirm
  [[ "$confirm" == "YES" ]] || exit 1
fi

if [[ ! -d "$LFS" ]]; then
  echo "ERROR: $LFS does not exist."
  exit 1
fi

echo
echo "[2] Current LFS mounts"
findmnt | grep "$LFS" || {
  echo "No active mounts found under $LFS."
  exit 0
}

echo
echo "[3] Checking for processes using $LFS"

if command -v fuser >/dev/null 2>&1; then
  if fuser -vm "$LFS" >/tmp/lfs-fuser-output.txt 2>&1; then
    cat /tmp/lfs-fuser-output.txt
    echo
    echo "WARNING: Some processes may still be using $LFS."
    echo "Close terminals or processes inside chroot before unmounting."
    read -rp "Continue unmount attempt anyway? Type YES: " confirm
    [[ "$confirm" == "YES" ]] || exit 1
  else
    echo "OK: No obvious active process detected by fuser."
  fi
else
  echo "NOTE: fuser is not installed. Skipping process check."
fi

echo
echo "[4] Unmounting virtual filesystems in safe order"

unmount_if_mounted() {
  local target="$1"

  if findmnt "$target" >/dev/null 2>&1; then
    echo "Unmounting: $target"
    umount -v "$target"
  else
    echo "OK: not mounted: $target"
  fi
}

unmount_if_mounted "$LFS/dev/shm"
unmount_if_mounted "$LFS/dev/pts"
unmount_if_mounted "$LFS/dev"
unmount_if_mounted "$LFS/run"
unmount_if_mounted "$LFS/proc"
unmount_if_mounted "$LFS/sys"

echo
echo "[5] Final verification"

if findmnt | grep "$LFS"; then
  echo
  echo "WARNING: Some LFS mounts are still active."
  echo "Review the remaining mounts above before shutting down."
  exit 1
else
  echo "OK: All LFS virtual filesystems are unmounted."
fi

echo
echo "=== Cleanup completed ==="