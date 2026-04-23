# divmmc

This repository contains assets and helper commands for preparing and running an esxDOS + DivMMC setup in the FUSE ZX Spectrum emulator.

## What is in this repository

- `Makefile`: automation for downloading esxDOS files, building a DivMMC hard disk image, running FUSE, and cleaning generated files.
- `esxdos.szx`: a saved FUSE snapshot used to boot/test the setup.

## What the Makefile does

The main flow is:

1. Download `esxdos089.zip` from esxdos.org.
2. Download `BROWSE_latest.zip` and merge `BIN`/`SYS` content into the esxDOS tree.
3. Create a FAT16 image (`esxdos.hdf`) with `hdfmonkey`.
4. Copy prepared files into the image.
5. Start FUSE with DivMMC enabled and the generated image attached.

## Requirements

Install these tools before using the Makefile:

- `fuse` (the ZX Spectrum emulator)
- `wget`
- `unzip`
- `hdfmonkey`

## Usage

Build image and run emulator:

```sh
make
```

Create snapshot guidance flow (for regenerating `esxdos.szx`):

```sh
make snap
```

Remove generated artifacts:

```sh
make clean
```

## Notes

- `make clean` removes generated files/folders such as `esxdos.hdf`, `esxdos/`, and `101/`.
- Network access is required because the build downloads external ZIP archives.
