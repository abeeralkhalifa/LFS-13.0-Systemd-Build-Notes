#!/usr/bin/env bash
set -euo pipefail

# This script is based on:
# docs/chapter-07-entering-chroot-and-temporary-tools.md
#
# Purpose:
# Mount required virtual filesystems and enter the LFS chroot environment.
#
# Run as root on the Debian host, not inside chroot.

echo "=== LFS Chapter 7: Enter Chroot ==="

if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: This script must be run as root."
  echo "Use: sudo ./scripts/chapter-07-enter-chroot.sh"
  exit 1
fi

export LFS="${LFS:-/mnt/lfs}"
umask 022

echo
echo "[1] Environment check"
echo "LFS=$LFS"
echo "umask=$(umask)"

if [[ "$LFS" != "/mnt/lfs" ]]; then
  echo "WARNING: LFS is not /mnt/lfs"
  read -rp "Continue anyway? Type YES: " confirm
  [[ "$confirm" == "YES" ]] || exit 1
fi

if [[ ! -d "$LFS" ]]; then
  echo "ERROR: $LFS does not exist."
  exit 1
fi

if ! findmnt "$LFS" >/dev/null 2>&1; then
  echo "ERROR: $LFS is not mounted."
  echo "Mount it first, then run this script again."
  exit 1
fi

echo
echo "[2] Creating mount points"
mkdir -pv "$LFS"/{dev,proc,sys,run}

echo
echo "[3] Mounting virtual kernel filesystems"

if ! findmnt "$LFS/dev" >/dev/null 2>&1; then
  mount -v --bind /dev "$LFS/dev"
else
  echo "OK: $LFS/dev is already mounted"
fi

if ! findmnt "$LFS/dev/pts" >/dev/null 2>&1; then
  mount -vt devpts devpts -o gid=5,mode=0620 "$LFS/dev/pts"
else
  echo "OK: $LFS/dev/pts is already mounted"
fi

if ! findmnt "$LFS/proc" >/dev/null 2>&1; then
  mount -vt proc proc "$LFS/proc"
else
  echo "OK: $LFS/proc is already mounted"
fi

if ! findmnt "$LFS/sys" >/dev/null 2>&1; then
  mount -vt sysfs sysfs "$LFS/sys"
else
  echo "OK: $LFS/sys is already mounted"
fi

if ! findmnt "$LFS/run" >/dev/null 2>&1; then
  mount -vt tmpfs tmpfs "$LFS/run"
else
  echo "OK: $LFS/run is already mounted"
fi

if [[ -h "$LFS/dev/shm" ]]; then
  install -v -d -m 1777 "$LFS$(realpath /dev/shm)"
else
  if ! findmnt "$LFS/dev/shm" >/dev/null 2>&1; then
    mount -vt tmpfs -o nosuid,nodev tmpfs "$LFS/dev/shm"
  else
    echo "OK: $LFS/dev/shm is already mounted"
  fi
fi

echo
echo "[4] Final mount verification"
findmnt | grep "$LFS" || true

echo
echo "[5] Entering chroot"

chroot "$LFS" /usr/bin/env -i \
  HOME=/root \
  TERM="${TERM:-xterm}" \
  PS1='(lfs chroot) \u:\w\$ ' \
  PATH=/usr/bin:/usr/sbin \
  MAKEFLAGS="-j$(nproc)" \
  TESTSUITEFLAGS="-j$(nproc)" \
  /bin/bash --login