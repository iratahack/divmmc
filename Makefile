.PHONY: all run clean

#BWSR_DIR=101
BWSR_FILE=BROWSE_TEST102-3.zip
BWSR_LINK=http://www.thefossilrecord.co.uk/wp-content/uploads/zx/$(BWSR_FILE)
BWSR_DIR=BROWSE_TEST102-3

all: esxdos.hdf esxdos.szx
	fuse esxdos.szx --no-divide --divmmc --divmmc-write-protect --divmmc-file esxdos.hdf

clean:
	rm -f esxdos.hdf esxdos.raw
	rm -rf esxdos $(BWSR_DIR)

esxdos:
	wget http://www.esxdos.org/files/esxdos089.zip
	unzip -o esxdos089.zip -d esxdos
	rm -f esxdos089.zip

snap: esxdos.hdf
	@echo
	@echo "================================"
	@echo
	@echo "https://gist.github.com/mistificator/8e8ed63b95d1cea6a51e7e7c28eff4ed"
	@echo
	@echo "* Press a key to flash DivMMC EEPROM"
	@echo "* Write protect DivMMC in Options->Peripherals->Disk menu"
	@echo "* Run debugger in Machine->Debugger menu"
	@echo "* Enter command br 0 to set breakpoint at 0x0000 address, press Continue button"
	@echo "* Select Machine->Hard reset"
	@echo "* When debugger stops executing, select File->Save snapshot, and save as esxdos.szx"
	@echo
	@echo "================================"
	@echo
	fuse --no-divide --divmmc --no-divmmc-write-protect --divmmc-file esxdos.hdf esxdos/ESXMMC.TAP

esxdos.hdf: esxdos
	wget $(BWSR_LINK)
	unzip -o $(BWSR_FILE)
	cp -r $(BWSR_DIR)/BIN esxdos/
	cp $(BWSR_DIR)/BIN/BROWSE esxdos/BIN/B
	cp -r $(BWSR_DIR)/SYS esxdos/
#	dd if=/dev/zero of=esxdos.raw bs=16M count=1
#	mkfs.vfat -n FUSE -F16 --mbr=y esxdos.raw
#	raw2hdf -v 1.1 esxdos.raw esxdos.hdf
#	https://codeberg.org/chwe/hdfmonkey
	hdfmonkey create --fat32 esxdos.hdf 384M FUSE
	hdfmonkey put esxdos.hdf esxdos/* /
	rm -f $(BWSR_FILE)
