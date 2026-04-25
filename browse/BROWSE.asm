BORDCR EQU $5C48

  ORG $2000

; Routine at 2000
L2000:
  LD A,H
  OR L
  JR Z,L2017_0
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

; Routine at 2017
;
; Used by the routine at L2000.
L2017:
  XOR A
  LD (DE),A
  LD A,$2A
  LD HL,startDir
  RST $08
  DEFB $A9
; This entry point is used by the routine at L2000.
L2017_0:
  LD A,(BORDCR)
  LD (BORDCR_SAVE),A
  LD HL,$FE00
  LD BC,$0200
  LD DE,$3200
  LDIR
  LD HL,L203F
  LD DE,$FE00
  LD BC,$001B
  LDIR
  JP $FE00

; Routine at 203F
L203F:
  LD A,$85
  LD HL,$84D0
L203F_0:
  OUT ($E3),A
  LD DE,L2000
  LD BC,L2000
  LDIR
  INC A
  CP $89
  JR NZ,L203F_0
  LD A,$82
  OUT ($E3),A
  JP L205A

; Routine at 205A
;
; Used by the routine at L203F.
L205A:
  LD A,$24
  LD HL,browseName
  LD B,$01
  RST $08
  DEFB $9A
  RET C
  LD (fileHandle),A
  LD HL,fileInfo
  RST $08
  DEFB $A1
  JR C,L205A_0
  LD IX,fileInfo
  LD B,(IX+$08)
  LD C,(IX+$07)
  LD A,(fileHandle)
  LD HL,$84D0
  RST $08
  DEFB $9D
  JR C,L205A_0
  LD A,(fileHandle)
  RST $08
  DEFB $9B
  XOR A
  LD (fileHandle),A
  LD HL,$BBE2
  LD (HL),A
  LD DE,$BBE3
  LD BC,$441D
  LDIR
  DI
  LD ($2261),SP
  LD SP,$22A5
  CALL $84D0
  EI
  LD SP,($2261)
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
  LD A,(BORDCR_SAVE)
  LD (BORDCR),A
  SRL A
  SRL A
  SRL A
  OUT ($FE),A
  LD A,($BBE6)
  CP $FF
  JR NZ,L205A_0
  LD A,$01
  LD (L2128),A
L205A_0:
  LD HL,L20E5
  LD DE,$FE00
  LD BC,$0044
  LDIR
  JP $FE00

; Routine at 20E5
L20E5:
  LD ($FE3E),SP
  LD SP,$FF00
  LD A,$85
  LD DE,$84D0
; This entry point is used by the routine at L2105.
L20E5_0:
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
  JR L2105_0

; Routine at 2105
;
; Used by the routine at L20E5.
L2105:
  OUT ($E3),A
  LD HL,L2000
  LD BC,L2000
  LDIR
; This entry point is used by the routine at L20E5.
L2105_0:
  INC A
  CP $88
  JR NZ,L20E5_0
  OUT ($E3),A
  LD HL,L2000
  LD BC,$1E00
  LDIR
  LD A,$82
  OUT ($E3),A
  LD SP,$0000
  JP L2129

; Unused
L2128:
  DEFS $01

; Routine at 2129
;
; Used by the routine at L2105.
L2129:
  LD HL,$3200
  LD DE,$FE00
  LD BC,$0200
  LDIR
  LD A,(L2128)
  AND A
  JR Z,L2129_0
  IM 2
  EI
L2129_0:
  LD A,(fileHandle)
  AND A
  RET Z
  RST $08
  DEFB $9B
  RET
browseName:
  DEFM "/bin/browse.bin",$00

; Data block at 2155
fileHandle:
  DEFB $00

; Data block at 2156
BORDCR_SAVE:
  DEFB $00
fileInfo:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00

; Data block at 2162
L2162:
  DEFB $00

stackSave:
  DEFW $0000

startDir:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00

L2265:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00

