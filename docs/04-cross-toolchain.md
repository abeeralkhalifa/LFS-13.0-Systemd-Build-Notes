# Stage 04 — Building the Cross-Toolchain

## Goal

Build the initial cross-toolchain required to compile a Linux From Scratch system independently from the Debian host environment.

The cross-toolchain creates a controlled path from:

```text
Debian host tools
↓
Temporary LFS toolchain
↓
Final LFS system
```

## Why a Cross-Toolchain Is Required

At the beginning of the project, the new LFS system does not yet contain:

* A compiler
* A linker
* Standard libraries
* Linux API headers
* Build utilities

The temporary cross-toolchain solves this dependency problem.

Instead of compiling the final system directly with Debian tools, LFS first builds a temporary compiler and related components targeted specifically at the future LFS system.

The target triplet used during this stage is:

```bash
echo $LFS_TGT
```

Expected result resembles:

```text
x86_64-lfs-linux-gnu
```

## Build Order

The cross-toolchain was built in this order:

```text
Binutils — Pass 1
↓
GCC — Pass 1
↓
Linux API Headers
↓
Glibc
↓
Libstdc++
```

This order is important because each component prepares a requirement for the next one.

---

## 1. Binutils — Pass 1

### Purpose

Binutils provides low-level binary tools, including:

* `ld` — linker
* `as` — assembler
* `objdump`
* `readelf`
* `ar`

The linker and assembler are essential before building the temporary GCC compiler.

### Build Directory

A separate build directory was used:

```bash
mkdir -v build
cd build
```

### Configuration Pattern

The package was configured for the LFS target:

```bash
../configure \
  --prefix=$LFS/tools \
  --with-sysroot=$LFS \
  --target=$LFS_TGT \
  --disable-nls \
  --enable-gprofng=no \
  --disable-werror \
  --enable-new-dtags \
  --enable-default-hash-style=gnu
```

### Build and Install

```bash
make
make install
```

### Result

Binutils Pass 1 completed successfully.

---

## 2. GCC — Pass 1

### Purpose

GCC provides the initial temporary compiler required to build later packages.

At this stage, GCC is not yet the final compiler of the LFS system. It is a bootstrap compiler targeted at:

```text
$LFS_TGT
```

### Required GCC Source Dependencies

The GCC source tree requires:

* GMP
* MPFR
* MPC

These archives were unpacked inside the GCC source directory and renamed:

```bash
mv -v mpfr-* mpfr
mv -v gmp-* gmp
mv -v mpc-* mpc
```

### Build Directory

```bash
mkdir -v build
cd build
```

### Configuration Pattern

The GCC Pass 1 configuration follows the official LFS 13.0 Systemd book.

Important options include:

```text
--target=$LFS_TGT
--prefix=$LFS/tools
--with-sysroot=$LFS
--without-headers
--with-newlib
--disable-shared
--disable-threads
--disable-libatomic
--disable-libgomp
--disable-libquadmath
--disable-libssp
--disable-libvtv
--disable-libstdcxx
--enable-languages=c,c++
```

### Build and Install

```bash
make
make install
```

### Result

GCC Pass 1 completed successfully.

---

## 3. Linux API Headers

### Purpose

The Linux API headers define the interface between:

```text
Linux kernel
↔
C library
↔
user-space programs
```

These are not the complete Linux kernel sources installed as a running kernel.

Only the exported API headers are prepared for later use by Glibc and user-space software.

### Preparation Pattern

```bash
make mrproper
make headers
```

### Install the Exported Headers

```bash
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr
```

### Result

Linux API Headers installed successfully.

---

## 4. Glibc

### Purpose

Glibc is the GNU C Library.

It provides essential system interfaces used by most Linux programs, such as:

* Memory allocation
* File operations
* Process handling
* Standard input and output
* System call wrappers

### Why Glibc Is Critical

Programs do not normally communicate with the kernel directly for every operation.

The relationship is approximately:

```text
Application
↓
Glibc
↓
Linux system calls
↓
Kernel
```

### Build Directory

```bash
mkdir -v build
cd build
```

### Configuration Pattern

The temporary Glibc build was configured according to the official LFS book.

Important settings include:

```text
--prefix=/usr
--host=$LFS_TGT
--build=$(../scripts/config.guess)
--enable-kernel=<minimum-kernel-version>
--with-headers=$LFS/usr/include
```

### Build and Install

```bash
make
make DESTDIR=$LFS install
```

### Validation

The temporary toolchain was checked to confirm that the compiled test program used the expected LFS interpreter.

Typical validation pattern:

```bash
echo 'int main(){}' | $LFS_TGT-gcc -xc -
readelf -l a.out | grep ld-linux
rm -v a.out
```

The output should point to the expected LFS dynamic linker path.

### Result

Temporary Glibc installed successfully.

---

## 5. Libstdc++

### Purpose

Libstdc++ provides the standard C++ library required by software written in C++.

It is built after Glibc because it depends on the C library and Linux API headers prepared earlier.

### Source

Libstdc++ is built from the GCC source tree.

### Build Directory

```bash
mkdir -v build
cd build
```

### Configuration Pattern

Important options include:

```text
--host=$LFS_TGT
--build=$(../config.guess)
--prefix=/usr
--disable-multilib
--disable-nls
--disable-libstdcxx-pch
--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/<gcc-version>
```

### Build and Install

```bash
make
make DESTDIR=$LFS install
```

### Result

Temporary Libstdc++ installed successfully.

---

## Completed Milestone

The first cross-toolchain stage was completed successfully:

* [x] Binutils — Pass 1
* [x] GCC — Pass 1
* [x] Linux API Headers
* [x] Glibc
* [x] Libstdc++

## Technical Understanding

This stage established the minimum compilation environment required to build the temporary user-space tools.

The build process moved gradually away from Debian host dependencies and toward an independent LFS environment.

## Important Reminder

This document records the practical build flow and the role of each package.

Before rebuilding, always copy the exact package-specific commands and version-dependent options from the official **LFS 13.0 Systemd** book.
