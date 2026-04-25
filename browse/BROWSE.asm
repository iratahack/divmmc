BORDCR EQU $5C48
DIVMMC_PORT EQU $E3
BROWSE_BIN EQU $84D0
NMI_HOME EQU $FE00
NMI_BUF EQU $3200
NMI_LEN EQU $200
UPPER_RAM EQU $BBE2
QUIT_FLAG EQU $BBE6

  ORG $2000

; Parse command-line path argument
;
; Entry point for the BROWSE dot command. If HL is non-zero, copies the path
; argument (stopping at the first null, colon or CR) into startDir, then falls
; through to set the working directory. If HL is zero (no argument given),
; skips straight to doLaunch.
;
; I:HL Pointer to command-line argument string, or 0 if none
L2000:
  LD A,H
  OR L
  JR Z,doLaunch
  LD DE,startDir
L2000_0:
  LD A,(HL)
  AND A
  JR Z,L2017
  CP $3A
  JR Z,L2017
  CP $0D
  JR Z,L2017
  LDI
  JR L2000_0

; Set working directory and launch
;
; Null-terminates the path copied into startDir and calls f_chdir ($A9) to
; change to it. Then saves the current BORDCR value, backs up the NMI handler
; from NMI_HOME to NMI_BUF, copies the DivMMC page-save stub (L203F, $1B bytes)
; to NMI_HOME and jumps into it.
;
; I:DE End of path in startDir (left by L2000 after copying the argument)
L2017:
  XOR A
  LD (DE),A
  LD A,$2A
  LD HL,startDir
  RST $08
  DEFB $A9
; This entry point is used by the routine at L2000.
doLaunch:
  LD A,(BORDCR)
  LD (BORDCR_SAVE),A
  LD HL,NMI_HOME
  LD BC,NMI_LEN
  LD DE,NMI_BUF
  LDIR
  LD HL,L203F
  LD DE,NMI_HOME
  LD BC,$001B
  LDIR
  JP NMI_HOME

; Save upper RAM to DivMMC pages
;
; Preserves the memory region that BROWSE.BIN will overwrite by copying it into
; DivMMC pages $85..$88 (4 x 8 KB = 32 KB). HL advances through RAM ($84D0,
; $A4D0, $C4D0, $E4D0) while DE is reset to the DivMMC window at $2000 each
; iteration. Maps page $82 and jumps to L205A.
L203F:
  LD A,$85
  LD HL,BROWSE_BIN
savePage:
  OUT ($E3),A
  LD DE,L2000
  LD BC,L2000
  LDIR
  INC A
  CP $89
  JR NZ,savePage
  LD A,$82
  OUT ($E3),A
  JP L205A

; Load BROWSE.BIN and run browser
;
; Opens /bin/browse.bin on the system drive ($24), reads file metadata via
; f_fstat to obtain the binary length (bytes IX+7..8 of the stat buffer), loads
; the binary into BROWSE_BIN, then closes the file. Zeroes UPPER_RAM..$FFFF,
; saves SP into the tail of startDir, sets STACK_TOP and calls the browser. On
; return, restores the display file and attributes using system variable ATTR_P
; ($5C8D), then restores BORDCR and drives the border port. Sets im2Flag if
; QUIT_FLAG==$FF (clean quit from browser). Copies the RAM-restore stub (L20E5,
; $44 bytes) to NMI_HOME and jumps into it.
;
; I:A Drive specifier ($24 = system drive)
L205A:
  LD A,$24
  LD HL,browseName
  LD B,$01
  RST $08
  DEFB $9A
  RET C
  LD (fileHandle),A
; Read file metadata via f_fstat to obtain the file length (16-bit value in
; stat buffer at IX+7..8).
  LD HL,fileInfo
  RST $08
  DEFB $A1
  JR C,loadStub
  LD IX,fileInfo
  LD B,(IX+$08)
  LD C,(IX+$07)
  LD A,(fileHandle)
; Load BROWSE.BIN from the open file handle into memory at BROWSE_BIN.
  LD HL,BROWSE_BIN
  RST $08
  DEFB $9D
  JR C,loadStub
; Close the file and zero upper RAM ($BBE2..$FFFF) before calling the browser.
  LD A,(fileHandle)
  RST $08
  DEFB $9B
  XOR A
  LD (fileHandle),A
  LD HL,UPPER_RAM
  LD (HL),A
  LD DE,$BBE3
  LD BC,$441D
  LDIR
; Disable interrupts, park SP at STACK_TOP and call the browser entry point.
  DI
  LD (stackSave),SP
  LD SP,STACK_TOP
  CALL BROWSE_BIN
; Browser returned; restore display-file ($4000..$57FF) and attributes
; ($5800..$5AFF) from system variable ATTR_P.
  EI
  LD SP,(stackSave)
  XOR A
  LD HL,$4000
  LD (HL),A
  LD DE,$4001
  LD BC,$1800
  LDIR
  LD A,($5C8D)
  LD (HL),A
  LD BC,$02FF
  LDIR
; Restore BORDCR from the saved value and drive the border port directly (bits
; 5..3 of BORDCR -> bits 2..0 of port $FE).
  LD A,(BORDCR_SAVE)
  LD (BORDCR),A
  SRL A
  SRL A
  SRL A
  OUT ($FE),A
; Check the browser quit code. $FF means a clean exit; set im2Flag so IM 2 will
; be re-enabled on return.
  LD A,(QUIT_FLAG)
  CP $FF
  JR NZ,loadStub
  LD A,$01
  LD (im2Flag),A
; Copy the RAM-restore stub to NMI_HOME and transfer control there.
loadStub:
  LD HL,L20E5
  LD DE,NMI_HOME
  LD BC,$0044
  LDIR
  JP NMI_HOME

; Restore upper RAM from DivMMC pages
;
; Counterpart to L203F. Saves the current SP, switches to a temporary stack and
; maps DivMMC pages $85..$88 in turn, copying each 8 KB page back to RAM
; starting at $84D0. Page $86 is handled specially: if flag ($FE43) is non-zero
; the destination pointer is advanced by 8 KB before copying (skipping a bank).
; The final page ($88) copies only $1E00 bytes to avoid overwriting the running
; stub near NMI_HOME. Maps page $82 and jumps to L2129.
L20E5:
  LD ($FE3E),SP
  LD SP,$FF00
  LD A,$85
  LD DE,BROWSE_BIN
; Page $86 only: if flag ($FE43) is non-zero, advance the destination pointer
; by 8 KB before copying, then skip the LDIR.
restorePageLoop:
  CP $86
  JR NZ,L2105
  LD B,A
  LD A,($FE43)
  AND A
  LD A,B
  JR Z,L2105
  LD BC,L2000
  EX DE,HL
  ADD HL,BC
  EX DE,HL
  JR nextPage

; Inner body of DivMMC page-copy loop
;
; Maps page A to the DivMMC window at $2000, copies $2000 bytes from the window
; to DE, increments A and loops back to restorePageLoop. After page $87 falls
; through to copy the final $1E00 bytes of page $88, maps page $82 and jumps to
; L2129.
L2105:
  OUT ($E3),A
  LD HL,L2000
  LD BC,L2000
  LDIR
; This entry point is used by the routine at L20E5.
nextPage:
  INC A
  CP $88
  JR NZ,restorePageLoop
  OUT ($E3),A
  LD HL,L2000
  LD BC,$1E00
  LDIR
  LD A,$82
  OUT ($E3),A
  LD SP,$0000
  JP L2129

; IM 2 enable flag
;
; Flag byte: set to $01 if IM 2 should be re-enabled before returning to BASIC
; (written by L205A when QUIT_FLAG==$FF).
im2Flag:
  DEFS $01

; Final cleanup and return
;
; Copies the NMI handler from NMI_BUF back to NMI_HOME. If im2Flag is non-zero,
; switches to IM 2 and enables interrupts. If fileHandle is non-zero, closes
; the open file handle via f_close ($9B). Returns to the caller.
L2129:
  LD HL,NMI_BUF
  LD DE,NMI_HOME
  LD BC,NMI_LEN
  LDIR
  LD A,(im2Flag)
  AND A
  JR Z,closeHandle
  IM 2
  EI
closeHandle:
  LD A,(fileHandle)
  AND A
  RET Z
  RST $08
  DEFB $9B
  RET
browseName:
  DEFM "/bin/browse.bin",$00

; Open file handle
fileHandle:
  DEFB $00

; Saved BORDCR and file stat buffer
BORDCR_SAVE:
  DEFB $00
fileInfo:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00

; File stat padding byte
fileInfoPad:
  DEFB $00

; Directory path buffer
startDir:
  DEFS $0100

; Saved stack pointer
stackSave:
  DEFW $0000

; Temporary stack buffer
;
; Bottom of the temporary stack. SP is initialised to STACK_TOP; each PUSH
; decrements SP toward STACK_END. The 64-byte region between STACK_END and
; STACK_TOP is the usable stack space.
STACK_END:
  DEFS $40

STACK_TOP:

