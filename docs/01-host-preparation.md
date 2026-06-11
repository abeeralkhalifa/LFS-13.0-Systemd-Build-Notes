# Stage 01 — Preparing the Host System

## Goal

Prepare a clean host environment capable of building Linux From Scratch 13.0 Systemd safely and reproducibly.

## Host Environment

* Host operating system: Debian
* Virtualization platform: VirtualBox
* LFS mount point: `/mnt/lfs`
* Dedicated build user: `lfs`
* Administrative account used for system-level preparation: `root`

## Initial Preparation

The host system was prepared before building any LFS packages.

### Update the Host System

```bash
sudo apt update
sudo apt upgrade -y
```

### Install Required Build Tools

The required development tools were installed on the Debian host before starting the build.

The exact package list should be checked against the official LFS 13.0 Systemd host-system requirements.

## Verify Host Requirements

The LFS version-check script was used to confirm that the required host tools were available and that their versions met the minimum requirements.

Example:

```bash
bash version-check.sh
```

## Set the LFS Environment Variable

The main LFS mount path was defined as:

```bash
export LFS=/mnt/lfs
```

Verify it:

```bash
echo $LFS
```

Expected output:

```text
/mnt/lfs
```

## Create and Mount the LFS Filesystem

The LFS filesystem was mounted at:

```text
/mnt/lfs
```

Verify the mount point:

```bash
mount | grep /mnt/lfs
```

## Create the Sources Directory

The source packages were stored in:

```text
/mnt/lfs/sources
```

Create the directory:

```bash
mkdir -v $LFS/sources
```

Apply the sticky bit:

```bash
chmod -v a+wt $LFS/sources
```

## Create the Tools Directory

The temporary toolchain was installed under:

```text
/mnt/lfs/tools
```

Create the directory:

```bash
mkdir -v $LFS/tools
```

Create the symbolic link:

```bash
ln -sv $LFS/tools /
```

## Create the LFS Build User

A dedicated user named `lfs` was created to isolate the temporary toolchain build from the host system.

```bash
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
passwd lfs
```

Grant ownership of the required directories:

```bash
chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
```

For a 64-bit system:

```bash
case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac
```

Then:

```bash
chown -v lfs $LFS/lib64
```

## Switch to the LFS User

```bash
su - lfs
```

## Configure the LFS User Environment

The `lfs` user environment was configured through `.bash_profile` and `.bashrc` according to the official LFS book.

The environment included:

* `LFS=/mnt/lfs`
* `LC_ALL=POSIX`
* `LFS_TGT=$(uname -m)-lfs-linux-gnu`
* A controlled `PATH`
* Parallel build configuration through `MAKEFLAGS`

## Validation

Before building the cross-toolchain, verify:

```bash
echo $LFS
echo $LFS_TGT
echo $PATH
```

Expected key result:

```text
/mnt/lfs
```

## Notes

This stage is foundational. Any mistake in the mount point, permissions, symbolic links, or `lfs` user environment can affect later toolchain builds.

Always compare commands against the official LFS 13.0 Systemd book before reuse.
