.PHONY: all run clean

all: esxdos.hdf esxdos.szx
	fuse esxdos.szx --no-divide --divmmc --divmmc-write-protect --divmmc-file esxdos.hdf

clean:
	rm -f esxdos.hdf esxdos.raw
	rm -rf esxdos 101

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
	wget http://www.thefossilrecord.co.uk/wp-content/uploads/zx/BROWSE_latest.zip
	unzip -o BROWSE_latest.zip
	cp -r 101/BIN esxdos/
	cp 101/BIN/BROWSE esxdos/BIN/B
	cp -r 101/SYS esxdos/
	dd if=/dev/zero of=esxdos.raw bs=16M count=1
	mkfs.vfat -n FUSE -F16 --mbr=y esxdos.raw
	raw2hdf -v 1.1 esxdos.raw esxdos.hdf
#	hdfmonkey create --fat16 esxdos.hdf 16M FUSE
	hdfmonkey put esxdos.hdf esxdos/* /
	rm -f BROWSE_latest.zip
