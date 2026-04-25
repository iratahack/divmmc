# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains the **DivMMC BROWSE** project — a ZX Spectrum file browser utility for navigating FAT16/FAT32 filesystems on DivMMC or ZX-UNO hardware. The `browse/` subdirectory (current working directory) contains **reverse-engineered Z80 assembly disassemblies** of two compiled binaries, produced via SkoolKit tools.

There are two binaries:
- **`BROWSE`** — the esxDOS dot-command stub (~677 bytes), loads at `0x2000`. Parses the command-line argument and invokes the main payload.
- **`BROWSE.BIN`** — the main browser payload (~8KB), loads at `0x84D0`. Contains all UI and filesystem logic.

The parent directory (`/home/devel/git/divmmc/`) orchestrates building a full esxDOS HDF disk image and running it in the FUSE ZX Spectrum emulator.

## Build Commands

### Build binaries (this subdirectory)

```bash
make          # Assembles BROWSE.asm → BROWSE and BROWSE.BIN.asm → BROWSE.BIN
make clean    # Prints a warning (intentionally does not delete disassembly work)
```

The assembler invocations are:
```bash
z88dk-z80asm -b BROWSE.asm    -oBROWSE
z88dk-z80asm -b BROWSE.BIN.asm -oBROWSE.BIN
```

### Regenerate disassembly from binaries

The Makefile also contains targets to rebuild the SkoolKit intermediates from the source binaries in `../101/BIN/`:

```bash
make BROWSE.ctl         # sna2ctl.py -h -o 0x2000  ../101/BIN/BROWSE     > BROWSE.ctl
make BROWSE.BIN.ctl     # sna2ctl.py -h -o 0x84d0  ../101/BIN/BROWSE.BIN > BROWSE.BIN.ctl
make BROWSE.skool       # sna2skool.py -c BROWSE.ctl     -H -r -o 0x2000  ../101/BIN/BROWSE     > BROWSE.skool
make BROWSE.BIN.skool   # sna2skool.py -c BROWSE.BIN.ctl -H -r -o 0x84d0  ../101/BIN/BROWSE.BIN > BROWSE.BIN.skool
make BROWSE.asm         # skool2asm.py -c -H BROWSE.skool     > BROWSE.asm
make BROWSE.BIN.asm     # skool2asm.py -c -H BROWSE.BIN.skool > BROWSE.BIN.asm
```

### Build the full DivMMC disk image (parent directory)

```bash
cd /home/devel/git/divmmc
make          # Builds esxdos.hdf (if needed) + launches FUSE using esxdos.szx snapshot
make snap     # Interactive: guides through EEPROM flashing and snapshot creation
make clean    # Removes *.hdf, *.raw, esxdos/, 101/ directories
```

The full build: downloads `esxdos089.zip` and `BROWSE_latest.zip`, merges trees, creates a FAT16 image via `dd` + `mkfs.vfat` + `raw2hdf`, populates it with `hdfmonkey`, then launches FUSE using the pre-built `esxdos.szx` snapshot.

### Build dependencies

- `z88dk-z80asm` — Z80 assembler
- `fuse` — ZX Spectrum emulator
- `hdfmonkey` — FAT16 disk image manipulation
- `raw2hdf` — raw disk to HDF conversion
- SkoolKit: `sna2ctl.py`, `sna2skool.py`, `skool2asm.py` — for binary ↔ assembly round-tripping
- Standard tools: `wget`, `unzip`, `dd`, `mkfs.vfat`

## Architecture

### Key files in `browse/`

| File | Purpose |
|------|---------|
| `BROWSE.asm` | ~260-line Z80 assembly — dot-command stub (ORG $2000) |
| `BROWSE` | Compiled dot-command stub (~677 bytes) |
| `BROWSE.ctl` | SkoolKit control file for BROWSE stub |
| `BROWSE.skool` | SkoolKit intermediate for BROWSE stub |
| `BROWSE.BIN.asm` | ~5515-line Z80 assembly — main payload (ORG $84D0) |
| `BROWSE.BIN` | Compiled main payload (~8KB) |
| `BROWSE.BIN.ctl` | SkoolKit control file for BROWSE.BIN |
| `BROWSE.BIN.skool` | SkoolKit intermediate for BROWSE.BIN |
| `skoolkit.ini` | SkoolKit configuration (RST instruction handling) |

### Reverse-engineering workflow

The `browse/` directory is **not an original source tree** — it is a disassembly of the binaries distributed in `../101/BIN/`. The SkoolKit pipeline (same pattern for both binaries):

```
../101/BIN/BROWSE     → sna2ctl.py  → BROWSE.ctl
BROWSE.ctl            → sna2skool.py → BROWSE.skool
BROWSE.skool          → skool2asm.py → BROWSE.asm

../101/BIN/BROWSE.BIN → sna2ctl.py  → BROWSE.BIN.ctl
BROWSE.BIN.ctl        → sna2skool.py → BROWSE.BIN.skool
BROWSE.BIN.skool      → skool2asm.py → BROWSE.BIN.asm
```

SkoolKit flags used: `-h` (hex addresses in ctl), `-o <addr>` (origin), `-H` (hex values in skool), `-r` (register comments), `-c` (no clobber warnings in asm output).

### Z80 assembly conventions

- Direct ZX Spectrum memory-mapped I/O (ports, hardware registers)
- Extensive DivMMC 128K bank switching for folder/file caching
- NMI handler in `../101/SYS/NMI.SYS` for interrupt-driven UI (invoked without leaving the running program)
- Plugins in `../101/BIN/BPLUGINS/` are separately compiled binaries loaded at runtime for file-type handling (audio, graphics, snapshots, etc.)

### esxDOS API calls

All OS calls use `RST $08` followed by a `DEFB` function code. Full API reference: `/home/devel/git/esxdos/nextzxos_api.pdf`.

**Disk operations:**

| Code | Name | Description |
|------|------|-------------|
| `$80` | `disk_status` | Get disk status |
| `$81` | `disk_read` | Low-level disk block read |
| `$84` | `disk_info` | Get disk information |
| `$85` | `disk_eject` | Eject disk (also used as `disk_filemap` in NextZXOS streaming API) |
| `$86` | `disk_strmstart` | Start streaming read from card (IXDE=addr, BC=blocks) |
| `$87` | `disk_strmend` | End streaming operation |

**File operations:**

| Code | Name | Description |
|------|------|-------------|
| `$9A` | `f_open` | Open file (A=drive, IX=filename, B=mode, DE=header buf) |
| `$9B` | `f_close` | Close file (A=handle) |
| `$9C` | `f_sync` | Sync file to disk (A=handle) |
| `$9D` | `f_read` | Read bytes (A=handle, IX=buf, BC=count) |
| `$9E` | `f_write` | Write bytes (A=handle, IX=buf, BC=count) |
| `$9F` | `f_seek` | Seek (A=handle, BCDE=offset, IXL=mode) |
| `$A0` | `f_getpos` | Get current file position pointer (A=handle) |
| `$A1` | `f_fstat` | Get open file info into 11-byte buffer at IX |
| `$A3` | `f_opendir` | Open directory (A=drive, IX=path, B=mode) → A=handle |
| `$A4` | `f_readdir` | Read directory entry (A=handle, IX=buf) |
| `$A8` | `f_getcwd` | Get current working directory (IX=buf) |
| `$A9` | `f_chdir` | Change directory (IX=path) |
| `$AA` | `f_mkdir` | Make directory (IX=path) |
| `$AB` | `f_rmdir` | Remove directory (IX=path) |
| `$AC` | `f_stat` | Get unopen file info (IX=path, DE=11-byte buf) |
| `$AD` | `f_unlink` | Delete file (IX=path) |
| `$AF` | `f_chmod` | Change file attributes (IX=path, B=values, C=mask) |
| `$B0` | `f_rename` | Rename/move file (IX=src, DE=dst) |
| `$B1` | `f_getfree` | Get free space on drive |

**Miscellaneous:**

| Code | Name | Description |
|------|------|-------------|
| `$88` | `m_dosversion` | Get NextZXOS version/mode info |
| `$89` | `m_getsetdrv` | Get/set default drive |
| `$8B` | `m_tapein` | Tape input operations (sub-function in A) |
| `$8C` | `m_tapeout` | Tape output operations (sub-function in A) |
| `$8F` | `m_execcmd` | Execute a dot command (IX=commandline) |
| `$90` | `m_autoload` | Auto-load a file |
| `$92` | `m_drvapi` | Access installable driver API |
| `$93` | `m_geterr` | Get/generate error message |

**m_tapein sub-functions (A register):**
- `0` `TAPEIN_OPEN` — open tape input
- `1` `TAPEIN_CLOSE` — close tape input
- `2` `TAPEIN_INFO` — get tape block info
- `3` `TAPEIN_SETPOS` — set tape position
- `4` `TAPEIN_GETPOS` — get tape position
- `5` `TAPEIN_PAUSE` — pause tape

**m_tapeout sub-functions (A register):**
- `0` `TAPEOUT_OPEN` — open tape output
- `1` `TAPEOUT_CLOSE` — close tape output
- `2` `TAPEOUT_INFO` — get tape output info
- `3` `TAPEOUT_TRUNC` — truncate tape output

**f_open mode flags (B register):**
- `$01` `esx_mode_read` — read access
- `$02` `esx_mode_write` — write access
- `$40` `esx_mode_use_header` — read/write +3DOS header
- `$00` `esx_mode_open_exist` — open existing only
- `$08` `esx_mode_open_creat` — open existing or create
- `$04` `esx_mode_creat_noexist` — create new, error if exists
- `$0C` `esx_mode_creat_trunc` — create new, delete existing

**f_seek modes (IXL register):**
- `0` `SEEK_SET` — seek from start of file
- `1` `SEEK_FWD` — seek forward from current position
- `2` `SEEK_BWD` — seek backward from current position

**Drive specifiers (A register for f_open / m_getsetdrv):**
- `$24` (`$`) — system drive
- `$2A` (`*`) — current drive

On success: Fc=0. On failure: Fc=1, A=error code.

**Error codes:**

| Code | Description |
|------|-------------|
| 1 | OK |
| 2 | Nonsense in ESXDOS |
| 3 | Statement END error |
| 4 | Wrong file TYPE |
| 5 | No such FILE or DIR |
| 6 | I/O ERROR |
| 7 | Invalid FILENAME |
| 8 | Access DENIED |
| 9 | Drive FULL |
| 10 | Invalid I/O REQUEST |
| 11 | No such DRIVE |
| 12 | Too many OPEN FILES |
| 13 | Bad file DESCRIPTOR |
| 14 | No such DEVICE |
| 15 | File pointer OVERFLOW |
| 16 | Is a DIRECTORY |
| 17 | Not a DIRECTORY |
| 18 | File already EXISTS |
| 19 | Invalid PATH |
| 20 | No SYS |
| 21 | Path too LONG |
| 22 | No such COMMAND |
| 23 | File in USE |
| 24 | File is READ ONLY |
| 25 | Verify FAILED |
| 26 | Loading .KO FAILED |
| 27 | Directory NOT EMPTY |
| 28 | MAPRAM is ACTIVE |
| 29 | Drive is BUSY |
| 30 | Unknown FILESYSTEM |
| 31 | Device is BUSY |

### DivMMC memory constants

| Constant | Value | Description |
|----------|-------|-------------|
| `MMC_MEMORY_PORT` | `227` (`$E3`) | I/O port for DivMMC bank switching |
| `MMC_MEMORY_FIRST_PAGE` | `5` | First usable DivMMC RAM page |
| `MMC_MEMORY_LAST_PAGE` | `11` | Last usable DivMMC RAM page (pages 5–10 usable) |
| `MMC_MEMORY_PLUGIN_PAGE1` | `12` | First plugin page |
| `MMC_MEMORY_PLUGIN_PAGE2` | `13` | Second plugin page |
| `MMC_MEMORY_PLUGIN_PAGE3` | `14` | Third plugin page |
| `DIV_MMC_BANK_SIZE` | `8192` | Size of each DivMMC bank in bytes |
| `NMI_RAM_BUFFER` | `$3200` | NMI handler RAM buffer address |
| `NMI_RAM_BUFFER_SIZE` | `$200` | NMI handler RAM buffer size (512 bytes) |

### Distribution variants

- `../101/` — standard build with full 128KB MMC memory support
- `../101/No_MMC_Memory/` — stripped variant for hardware without extra MMC memory

## Running

On real hardware or in FUSE emulator via esxDOS dot-command:
```
.browse          # Open browser at current directory
.browse /path    # Open browser at specific path
```
