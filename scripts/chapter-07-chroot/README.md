# Chapter 7 Chroot Helper Scripts

This folder contains helper scripts for entering and safely leaving the Linux From Scratch chroot environment.

These scripts are based on:

```text
docs/chapter-07-entering-chroot-and-temporary-tools.md
```

They are intended to reduce repeated manual work and avoid mistakes when returning to the LFS build environment.

---

## Environment Context

For this project, there are three different environments:

```text
Zorin OS host     = used for writing documentation and managing GitHub
Debian VM         = used for the actual LFS build
LFS chroot        = entered from inside the Debian VM
```

The scripts in this folder must be executed from the Debian VM, not from Zorin OS.

---

## Scripts

### `enter-chroot.sh`

Purpose:

```text
Mount the required virtual kernel filesystems and enter the LFS chroot environment.
```

This script mounts the required virtual filesystems under `/mnt/lfs`:

```text
/mnt/lfs/dev
/mnt/lfs/dev/pts
/mnt/lfs/dev/shm
/mnt/lfs/proc
/mnt/lfs/sys
/mnt/lfs/run
```

Then it enters the LFS chroot environment using the official LFS chroot command structure.

Run from the Debian host:

```bash
cd ~/Projects/LFS-13.0-Systemd-Build-Notes
sudo ./scripts/chapter-07-chroot/enter-chroot.sh
```

Expected result:

```text
(lfs chroot) root:/#
```

or a similar chroot prompt.

---

### `exit-chroot-safe.sh`

Purpose:

```text
Safely unmount the virtual filesystems after exiting the LFS chroot environment.
```

This script should be used after manually exiting chroot.

First, exit from chroot:

```bash
exit
```

Then run the cleanup script from the Debian host:

```bash
cd ~/Projects/LFS-13.0-Systemd-Build-Notes
sudo ./scripts/chapter-07-chroot/exit-chroot-safe.sh
```

This script unmounts the virtual filesystems in a safe order:

```text
/mnt/lfs/dev/shm
/mnt/lfs/dev/pts
/mnt/lfs/dev
/mnt/lfs/run
/mnt/lfs/proc
/mnt/lfs/sys
```

It intentionally does not unmount `/mnt/lfs` itself.

This allows the LFS partition to remain available for file review or quick re-entry into chroot.

To fully unmount the LFS partition before shutting down, run:

```bash
sudo umount /mnt/lfs
```

Verify:

```bash
findmnt /mnt/lfs
```

If no output appears, `/mnt/lfs` is fully unmounted.

---

## Typical Workflow

### 1. Start Debian VM

The actual LFS build environment is inside the Debian VirtualBox VM.

Do not run these scripts from Zorin OS.

---

### 2. Verify that the LFS partition is mounted

Before entering chroot, verify:

```bash
findmnt /mnt/lfs
```

Expected result:

```text
/mnt/lfs is mounted
```

If `/mnt/lfs` is not mounted, mount the correct LFS partition first.

Example:

```bash
sudo mkdir -pv /mnt/lfs
sudo mount /dev/sdb2 /mnt/lfs
findmnt /mnt/lfs
```

Important:

```text
Do not assume /dev/sdb2 is always correct.
Verify the correct partition using lsblk before mounting.
```

Use:

```bash
lsblk
```

---

### 3. Enter chroot

From the Debian host:

```bash
cd ~/Projects/LFS-13.0-Systemd-Build-Notes
sudo ./scripts/chapter-07-chroot/enter-chroot.sh
```

After success, the prompt should show that the shell is inside the LFS chroot environment.

---

### 4. Work inside chroot

Continue the LFS build steps from the current package or chapter.

To verify the chroot context:

```bash
pwd
echo "$PATH"
whoami
```

Expected context:

```text
working directory: /
PATH includes: /usr/bin:/usr/sbin
user: root
```

---

### 5. Exit chroot

Inside chroot, run:

```bash
exit
```

After this command, the shell returns to the Debian host.

The prompt should no longer include:

```text
(lfs chroot)
```

---

### 6. Unmount virtual filesystems safely

Back on the Debian host, run:

```bash
sudo ./scripts/chapter-07-chroot/exit-chroot-safe.sh
```

Expected result:

```text
OK: virtual filesystems are unmounted
```

If the script shows that `/mnt/lfs` is still mounted, this is normal.

The script intentionally keeps `/mnt/lfs` mounted.

---

### 7. Optional full unmount before shutdown

If the work session is finished and the Debian VM will be shut down, unmount the LFS partition itself:

```bash
sudo umount /mnt/lfs
```

Verify:

```bash
findmnt /mnt/lfs
```

If no output appears, the LFS partition is fully unmounted.

Then shut down the Debian VM normally.

---

## Safety Notes

Run these scripts only from the Debian VM.

Do not run `enter-chroot.sh` while already inside chroot.

Do not run `exit-chroot-safe.sh` before exiting chroot.

Before mounting any partition manually, always verify the correct device name:

```bash
lsblk
```

Before running chroot-related commands, verify:

```bash
echo "$LFS"
findmnt /mnt/lfs
pwd
whoami
```

The expected LFS mount point is:

```text
/mnt/lfs
```

The expected execution context before running these scripts is:

```text
Debian host, outside chroot
```

---

## Notes

These scripts are helper tools.

They do not replace the official Linux From Scratch book.

They are based on the build state and environment used in this project.

