.PHONY: all

all: BROWSE.BIN BROWSE

clean:
	@echo "Are you sure you want to do this?"

BROWSE: BROWSE.asm
	z88dk-z80asm -b $< -o$@

BROWSE.BIN: BROWSE.BIN.asm
	z88dk-z80asm -b $< -o$@

BROWSE.ctl:
	sna2ctl.py -h -o 0x2000 ../101/BIN/BROWSE > $@

BROWSE.BIN.ctl:
	sna2ctl.py -h -o 0x84d0 ../BROWSE_TEST102-22/BIN/BROWSE.BIN > $@

BROWSE.skool: BROWSE.ctl
	sna2skool.py -c BROWSE.ctl -H -r -o 0x2000 ../101/BIN/BROWSE > $@

BROWSE.BIN.skool: BROWSE.BIN.ctl
	sna2skool.py -c BROWSE.BIN.ctl -H -r -o 0x84d0 ../BROWSE_TEST102-22/BIN/BROWSE.BIN > $@

%.asm: %.skool
	skool2asm.py -c -H $< > $@
