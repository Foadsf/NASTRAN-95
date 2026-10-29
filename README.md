# NASTRAN-95 - Cross-Platform Modernized Fork

A modernized, portable, and cleanly compilable distribution of the historic **NASTRAN 95** (NASA Structural Analysis System) finite element analysis suite, featuring automated multi-platform CI/CD builds, pre-compiled monolithic binaries, and bug fixes for modern 64-bit compilers.

---

## Pre-Built Portable Binaries

Standalone, monolithic binary releases with statically linked runtimes and bundled runtime databases (`rf/` and `um/`) are automatically built and published on the [GitHub Releases](https://github.com/Foadsf/NASTRAN-95/releases) page for all major platforms:

| Platform | Architecture | Package | Executables Included |
| :--- | :--- | :--- | :--- |
| **Microsoft Windows** | `x86_64` (AMD64) | `nastran95-v*-windows-x86_64.zip` | `nastran.exe`, `nastplot.exe`, `nasthelp.exe`, `chkfil.exe`, `ff.exe` |
| **GNU/Linux** | `x86_64` (AMD64) | `nastran95-v*-linux-x86_64.tar.gz` | `nastran`, `nastplot`, `nasthelp`, `chkfil`, `ff` |
| **GNU/Linux** | `aarch64` (ARM64) | `nastran95-v*-linux-arm64.tar.gz` | `nastran`, `nastplot`, `nasthelp`, `chkfil`, `ff` |
| **Apple macOS** | `arm64` (Apple Silicon) | `nastran95-v*-macos-arm64.tar.gz` | `nastran`, `nastplot`, `nasthelp`, `chkfil`, `ff` |
| **Apple macOS** | `x86_64` (Intel) | `nastran95-v*-macos-x86_64.tar.gz` | `nastran`, `nastplot`, `nasthelp`, `chkfil`, `ff` |

Every release bundle is entirely self-contained:
* **`nastran`**: Primary finite element solver engine.
* **`nastplot`**: Plot file interpreter generating PostScript (`.ps`) and Tektronix output.
* **`nasthelp`**: Interactive command-line documentation search tool.
* **`chkfil` / `ff`**: File formatting and checking utilities.
* **`rf/`**: Rigid Format DMAP solution sequence database (Statics, Normal Modes, Transient, Heat Transfer, Buckling, Aeroelasticity).
* **`um/`**: NASTRAN User Manual text library for `nasthelp`.

---

## Key Modernizations & Fixes in this Fork

Modern compilers (such as GCC `gfortran` 10+) default to conventions that break legacy 1970s–1990s Fortran code. This fork addresses several critical historical assumptions:

1. **Static Memory Allocation (`-fno-automatic`)**:
   Legacy NASTRAN card parsers (`xrcard.f`, `rcard.f`, `rcard2.f`, `ifp1.f`) assume local variables retain their values between invocations without explicit `SAVE` statements. Compiling with `-fno-automatic` eliminates `USER FATAL MESSAGE 300 (INTEGER DATA OUT OF MACHINE RANGE)` and `USER FATAL MESSAGE 507`.
2. **Block Data Linking (`bd/semdbd.f`)**:
   Explicitly includes and links block data routines initializing common blocks (`/MSGX/`, `/XMDMSK/`, `/SYSTEM/`), preventing zero-pointer buffer referencing and `SIGSEGV` segmentation faults.
3. **GINO Disk Benchmark Calibration (`rf/NASINFO`)**:
   Pre-configures `TIM = 16` in `rf/NASINFO` to bypass the 20-second dynamic disk I/O calibration benchmark loop (`tmtsio.f`).
4. **LF Database Normalization**:
   Sanitizes all Rigid Format (`rf/*`) and User Manual (`um/*`) files to Unix `LF` line endings, preventing `CRLF` carriage returns (`\r`, ASCII 13) from polluting formatted Fortran card reads (`(20A4)`).
5. **Monolithic Static Build System (`scripts/build-release.sh`)**:
   A streamlined, dependency-free shell build system supporting multi-threaded compilation (`xargs -P`), automatic platform detection, and static runtime linking across Linux, macOS, and Windows MSYS2.

---

## Quickstart: Minimal Working Example (MWE)

### 1. Create Input Deck (`mwe.inp`)

The following minimal deck models a 1D elastic rod under axial tension ($L = 100\text{ in}$, $E = 10^7\text{ psi}$, $A = 1.0\text{ in}^2$, $P = 1000\text{ lbf}$), governed by the 1D elastostatic PDE $\frac{d}{dx}\left(EA \frac{du}{dx}\right) = 0$:

```nastran
NASTRAN TITLEOPT=-1
ID    MWE,BAR1D
APP   DISP
SOL   1
TIME  5
CEND
TITLE = 1D ELASTIC ROD PDE - AXIAL EXTENSION
SPC = 1
LOAD = 1
DISPLACEMENT = ALL
FORCE = ALL
STRESS = ALL
BEGIN BULK
GRID    1               0.0     0.0     0.0     123456
GRID    2               100.0   0.0     0.0     23456
CROD    1       1       1       2
PROD    1       1       1.0
MAT1    1       1.0+7           0.3
FORCE   1       2       0       1000.0  1.0     0.0     0.0
SPC     1       1       123456  0.0
ENDDATA
```

### 2. Run the Analysis

**On Windows:**
```cmd
nastran.exe < mwe.inp > mwe.out
```

**On Linux / macOS:**
```bash
./nastran < mwe.inp > mwe.out
```

### 3. Verify Output

The output file `mwe.out` confirms exact agreement with the closed-form analytical solution ($\delta = \frac{PL}{EA} = 0.01000\text{ in}$, $\sigma = \frac{P}{A} = 1000.0\text{ psi}$):

```text
                                             D I S P L A C E M E N T   V E C T O R
      POINT ID.   TYPE          T1             T2             T3             R1             R2             R3
             1      G      0.0            0.0            0.0            0.0            0.0            0.0
             2      G      1.000000E-02   0.0            0.0            0.0            0.0            0.0

                                      S T R E S S E S   I N   R O D   E L E M E N T S
      ELEMENT ID.       AXIAL FORCE          AXIAL STRESS        SAFETY MARGIN TENSION     SAFETY MARGIN COMPRESSION
                1       1.000000E+03         1.000000E+03        0.0                       0.0
```

---

## Plotting with `nastplot`

NASTRAN 95 includes the standalone plotting translator `nastplot`:

1. In your input deck, add `NASTRAN FILES=PLT2` on card 1 and configure a plot subcase in Case Control:
   ```nastran
   OUTPUT(PLOT)
   PLOTTER NASTPLT
   SET 1 = ALL
   FIND SCALE ORIGIN 1, SET 1
   PLOT DEFORMATION 0.0, SET 1
   ```
2. Run `nastplot` (or `nastplot.exe`):
   ```cmd
   nastplot
   ```
   - Enter `P` for PostScript output.
   - Enter the plot filename (e.g., `model.PLT2`).
   - The PostScript vector file (`.ps`) is generated in the current working directory.

---

## Building from Source

### Prerequisites
* **GNU Fortran (`gfortran`)** and **C compiler (`gcc`)**
* Shell environment: Bash (Linux / macOS / MSYS2 UCRT64 on Windows)

### Compilation

Clone the repository and run the unified build script:

```bash
git clone https://github.com/Foadsf/NASTRAN-95.git
cd NASTRAN-95
./scripts/build-release.sh
```

Compiled monolithic binaries and databases will be placed in `dist/bin/`:
```text
dist/bin/
├── chkfil
├── ff
├── nasthelp
├── nastplot
├── nastran
└── rf/
```

To run the automated smoke test suite:
```bash
./scripts/smoke-test.sh dist/bin
```

---

## Licensing

NASTRAN-95 is distributed under the [NASA Open Source Agreement (NOSA) Version 1.3](NASA%20Open%20Source%20Agreement-NASTRAN%2095.doc).
