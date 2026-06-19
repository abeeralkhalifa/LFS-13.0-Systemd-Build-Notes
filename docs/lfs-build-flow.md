# LFS Build Roadmap

This document provides a structured overview of the Linux From Scratch 13.0-systemd build process.

Instead of using a large diagram, this roadmap breaks the build into clear stages. Each stage explains what is being prepared, why it matters, and how it connects to the next stage.

The official Linux From Scratch book remains the primary reference for exact commands, package versions, and build instructions.

---

## Build Overview

```text
Host Preparation
        ↓
Temporary Cross-Toolchain
        ↓
Temporary Tools
        ↓
Chroot Preparation
        ↓
Temporary Tools inside Chroot
        ↓
Temporary System Cleanup
        ↓
Final System Packages
        ↓
System Configuration
        ↓
Kernel and Boot Setup
        ↓
First Boot
```

---

## Stage 1: Host Preparation

**Purpose:**
Prepare the host system that will be used to build LFS.

**Main tasks:**

* Prepare the Debian host system inside VirtualBox.
* Check that the required host tools are available.
* Create and mount the LFS partition.
* Set the `LFS=/mnt/lfs` environment variable.
* Create the sources directory.
* Download the required packages and patches.

**Result:**
The host system is ready to start building the LFS temporary toolchain.

---

## Stage 2: Temporary Cross-Toolchain

**Purpose:**
Build the first isolated toolchain used to separate the new LFS system from the host system.

**Main components:**

* Binutils Pass 1
* GCC Pass 1
* Linux API Headers
* Glibc temporary build
* Libstdc++ temporary build

**Result:**
A basic cross-compilation environment is available for building the next temporary tools.

---

## Stage 3: Temporary Tools

**Purpose:**
Build temporary tools that are required before entering the chroot environment.

**Examples of packages:**

* M4
* Ncurses
* Bash
* Coreutils
* Diffutils
* File
* Findutils
* Gawk
* Grep
* Gzip
* Make
* Patch
* Sed
* Tar
* Xz
* Binutils Pass 2
* GCC Pass 2

**Result:**
The LFS filesystem contains enough temporary tools to prepare and enter the chroot environment.

---

## Stage 4: Chroot Preparation

**Purpose:**
Prepare the LFS filesystem so it can be used as an isolated root environment.

**Main tasks:**

* Change ownership of the LFS filesystem to `root`.
* Mount virtual filesystems such as `/dev`, `/proc`, `/sys`, and `/run`.
* Enter the chroot environment.
* Create the basic directory structure.
* Create `/etc/passwd` and `/etc/group`.
* Create initial log files.
* Create the `tester` user.

**Result:**
The build process moves from the host system into the LFS chroot environment.

---

## Stage 5: Temporary Tools inside Chroot

**Purpose:**
Build additional temporary tools from inside the chroot environment.

**Main packages:**

* Gettext
* Bison
* Perl
* Python
* Texinfo
* Util-linux

**Result:**
The chroot environment becomes ready for cleanup and final system package builds.

---

## Stage 6: Temporary System Cleanup

**Purpose:**
Remove temporary files and prepare the system for final package builds.

**Main tasks:**

* Remove temporary documentation files.
* Remove unnecessary `.la` files.
* Remove the `/tools` directory.
* Clean temporary build artifacts.

**Result:**
The system is ready to begin building the final LFS packages.

---

## Stage 7: Final System Packages

**Purpose:**
Build the real packages that will become part of the final LFS system.

**Examples of packages:**

* Man-pages
* Iana-Etc
* Glibc
* Zlib
* Bzip2
* Xz
* Zstd
* Readline
* Ncurses
* Attr
* Acl
* Libcap
* Libxcrypt
* Shadow
* GCC
* Binutils
* Coreutils
* Bash
* Systemd

**Result:**
The final user-space system is built.

---

## Stage 8: System Configuration

**Purpose:**
Configure the final LFS system so it can operate correctly after boot.

**Main tasks:**

* Configure networking.
* Configure locale settings.
* Configure console and keyboard settings.
* Configure the time zone.
* Configure systemd services.
* Create `/etc/fstab`.

**Result:**
The final system configuration is prepared.

---

## Stage 9: Kernel and Boot Setup

**Purpose:**
Prepare the system to boot independently.

**Main tasks:**

* Build the Linux kernel.
* Install kernel modules.
* Configure the bootloader.
* Perform final cleanup.
* Reboot into the completed LFS system.

**Result:**
The system is ready for the first boot.

---

## Current Progress

The current build progress is in **Chapter 8**, during the final system package build stage.

Completed major stages:

* Temporary cross-toolchain
* Temporary tools
* Chroot preparation
* Temporary tools inside chroot
* Temporary system cleanup

Current focus:

* Final system packages
