@ $2000 start
@ $2000 equ=BORDCR=$5C48
@ $2000 equ=DIVMMC_PORT=$E3
@ $2000 equ=BROWSE_BIN=$84D0
@ $2000 equ=NMI_HOME=$FE00
@ $2000 equ=NMI_BUF=$3200
@ $2000 equ=NMI_LEN=$200
@ $2000 equ=UPPER_RAM=$BBE2
@ $2000 equ=QUIT_FLAG=$BBE6
@ $2000 org
c $2000 Parse command-line path argument
D $2000 Entry point for the BROWSE dot command. If HL is non-zero, copies the path argument (stopping at the first null, colon or CR) into startDir, then falls through to set the working directory. If HL is zero (no argument given), skips straight to doLaunch.
R $2000 I:HL Pointer to command-line argument string, or 0 if none
c $2017 Set working directory and launch
D $2017 Null-terminates the path copied into startDir and calls f_chdir ($A9) to change to it. Then saves the current BORDCR value, backs up the NMI handler from NMI_HOME to NMI_BUF, copies the DivMMC page-save stub (L203F, $1B bytes) to NMI_HOME and jumps into it.
R $2017 I:DE End of path in startDir (left by L2000 after copying the argument)
@ $2020 label=doLaunch
c $203F Save upper RAM to DivMMC pages
D $203F Preserves the memory region that BROWSE.BIN will overwrite by copying it into DivMMC pages $85..$88 (4 x 8 KB = 32 KB). HL advances through RAM ($84D0, $A4D0, $C4D0, $E4D0) while DE is reset to the DivMMC window at $2000 each iteration. Maps page $82 and jumps to L205A.
@ $2044 label=savePage
@ $2046 isub=LD DE,$2000
@ $2049 isub=LD BC,$2000
c $205A Load BROWSE.BIN and run browser
D $205A Opens /bin/browse.bin on the system drive ($24), reads file metadata via f_fstat to obtain the binary length (bytes IX+7..8 of the stat buffer), loads the binary into BROWSE_BIN, then closes the file. Zeroes UPPER_RAM..$FFFF, saves SP into the tail of startDir, sets STACK_TOP and calls the browser. On return, restores the display file and attributes using system variable ATTR_P ($5C8D), then restores BORDCR and drives the border port. Sets im2Flag if QUIT_FLAG==$FF (clean quit from browser). Copies the RAM-restore stub (L20E5, $44 bytes) to NMI_HOME and jumps into it.
R $205A I:A Drive specifier ($24 = system drive)
N $2067 Read file metadata via f_fstat to obtain the file length (16-bit value in stat buffer at IX+7..8).
N $207B Load BROWSE.BIN from the open file handle into memory at BROWSE_BIN.
N $2082 Close the file and zero upper RAM ($BBE2..$FFFF) before calling the browser.
N $2097 Disable interrupts, park SP at STACK_TOP and call the browser entry point.
@ $209C isub=LD SP,STACK_TOP
N $20A2 Browser returned; restore display-file ($4000..$57FF) and attributes ($5800..$5AFF) from system variable ATTR_P.
N $20BD Restore BORDCR from the saved value and drive the border port directly (bits 5..3 of BORDCR -> bits 2..0 of port $FE).
N $20CB Check the browser quit code. $FF means a clean exit; set im2Flag so IM 2 will be re-enabled on return.
N $20D7 Copy the RAM-restore stub to NMI_HOME and transfer control there.
@ $20D7 label=loadStub
c $20E5 Restore upper RAM from DivMMC pages
D $20E5 Counterpart to L203F. Saves the current SP, switches to a temporary stack and maps DivMMC pages $85..$88 in turn, copying each 8 KB page back to RAM starting at $84D0. Page $86 is handled specially: if flag ($FE43) is non-zero the destination pointer is advanced by 8 KB before copying (skipping a bank). The final page ($88) copies only $1E00 bytes to avoid overwriting the running stub near NMI_HOME. Maps page $82 and jumps to L2129.
@ $20F1 label=restorePageLoop
N $20F1 Page $86 only: if flag ($FE43) is non-zero, advance the destination pointer by 8 KB before copying, then skip the LDIR.
@ $20FD isub=LD BC,$2000
c $2105 Inner body of DivMMC page-copy loop
D $2105 Maps page A to the DivMMC window at $2000, copies $2000 bytes from the window to DE, increments A and loops back to restorePageLoop. After page $87 falls through to copy the final $1E00 bytes of page $88, maps page $82 and jumps to L2129.
@ $2107 isub=LD HL,$2000
@ $210A isub=LD BC,$2000
@ $2116 isub=LD HL,$2000
@ $210F label=nextPage
s $2128 IM 2 enable flag
@ $2128 label=im2Flag
N $2128 Flag byte: set to $01 if IM 2 should be re-enabled before returning to BASIC (written by L205A when QUIT_FLAG==$FF).
c $2129 Final cleanup and return
D $2129 Copies the NMI handler from NMI_BUF back to NMI_HOME. If im2Flag is non-zero, switches to IM 2 and enables interrupts. If fileHandle is non-zero, closes the open file handle via f_close ($9B). Returns to the caller.
@ $213D label=closeHandle
T $2145,16
@ $2145 label=browseName
b $2155 Open file handle
@ $2155 label=fileHandle
b $2156 Saved BORDCR and file stat buffer
@ $2156 label=BORDCR_SAVE
@ $2157 label=fileInfo
B $2157,11
b $2162 File stat padding byte
@ $2162 label=fileInfoPad
s $2163 Directory path buffer
@ $2163 label=startDir
w $2263 Saved stack pointer
@ $2263 label=stackSave
s $2265 Temporary stack buffer
@ $2265 label=STACK_END
N $2265 Bottom of the temporary stack. SP is initialised to STACK_TOP; each PUSH decrements SP toward STACK_END. The 64-byte region between STACK_END and STACK_TOP is the usable stack space.
> $22A5 STACK_TOP:
i $22A5
