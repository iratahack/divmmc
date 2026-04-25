BORDCR EQU $5C48
F_OPEN EQU $9A

  ORG $84D0

; Routine at 84D0
L84D0:
  LD ($84E9),SP
  LD A,($BBE5)
  OR A
  JR Z,L84D0_0
  LD SP,$7FFF
L84D0_0:
  PUSH IY
  CALL L9E39
  OR A
  CALL Z,L9E26
  POP IY
  LD SP,$0000
  RET

; Unused
L84EC:
  DEFS $0D

; Routine at 84F9
;
; Used by the routines at L850C, L8A1F, L8B5D, L8BC5, L8C53, L8CF7, L9498 and
; L960A.
L84F9:
  LD A,H
  OR L
  JR Z,L84F9_0
  ADD HL,HL
  LD B,H
  LD C,L
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,BC
L84F9_0:
  LD BC,$C200
  ADD HL,BC
  LD ($BF62),HL
  RET

; Routine at 850C
;
; Used by the routines at L8829, L8851, L8DE9, L8E21, L8E53, L8E93, L8EA8 and
; L9726.
L850C:
  LD HL,($BBEF)
  CALL L84F9
  INC HL
  CALL L8533
  RET

; Routine at 8517
;
; Used by the routines at L8985, L89E4 and L960A.
L8517:
  LD D,H
  LD E,L
  LD BC,$000C
  ADD HL,BC
  LD C,(HL)
  INC HL
  LD B,(HL)
  LD A,B
  OR C
  JR Z,L852A
  LD HL,$E000
  ADD HL,BC
  AND A
  RET

; Routine at 852A
;
; Used by the routine at L8517.
L852A:
  EX DE,HL
  INC HL
  SCF
  RET

; Routine at 852E
L852E:
  LD DE,$E000
  ADD HL,DE
  RET

; Routine at 8533
;
; Used by the routines at L850C, L868B and L89E4.
L8533:
  LD DE,$BBF3
  LD C,$00
L8533_0:
  LD A,C
  CP $0B
  JR NC,L8556
  LD A,(HL)
  AND A
; This entry point is used by the routine at L8EB3.
L8533_1:
  JR Z,L8556
  CP $21
  JR C,L8533_3
  LD B,A
  LD A,C
  CP $08
  JR NZ,L8533_2
  LD A,$2E
  LD (DE),A
  INC DE
L8533_2:
  LD A,B
  LD (DE),A
  INC DE
L8533_3:
  INC HL
  INC C
  JR L8533_0

; Routine at 8556
;
; Used by the routine at L8533.
L8556:
  XOR A
  LD (DE),A
  RET

; Routine at 8559
;
; Used by the routines at L8CF7 and L8E53.
L8559:
  LD A,($A416)
  AND $04
  RET Z
  LD HL,$BC00
  LD BC,$0000
L8559_0:
  LD A,(HL)
  AND A
  JR Z,L856D
  INC HL
  INC C
  JR L8559_0

; Routine at 856D
;
; Used by the routine at L8559.
L856D:
  XOR A
  LD ($BF6D),A
  LD (L84EC),A
  LD A,C
  CP $01
  RET Z
  RET C
  DEC C
  LD HL,$BC00
  ADD HL,BC
  LD (HL),$00
  DEC HL
  LD B,C
L856D_0:
  LD A,(HL)
  CP $2F
  JR Z,L858B
  DEC HL
  DJNZ L856D_0
  RET

; Routine at 858B
;
; Used by the routine at L856D.
L858B:
  INC HL
  LD DE,L84EC
  CALL LA13E
  LD A,C
  LD ($BF6D),A
  RET

; Message at 8597
L8597:
  DEFM "Working..."

; Data block at 85A1
L85A1:
  DEFB $00

; Routine at 85A2
;
; Used by the routines at L8763, L8CA4, L8CE5, L952E, L9751, L9E85, LA38A and
; LA397.
L85A2:
  LD E,A
  LD L,$01
  CALL LA1E2
  LD A,E
  AND $04
  JR Z,L85A2_0
  LD HL,$0000
  LD ($BBEB),HL
  LD ($BBED),HL
  LD ($BBEF),HL
L85A2_0:
  PUSH DE
  CALL $94FF
  POP DE
  LD A,L
  AND A
  JR Z,L85C9
  LD A,E
  OR $10
  LD E,A
  PUSH DE
  JR L85C9_2

; Routine at 85C9
;
; Used by the routine at L85A2.
L85C9:
  PUSH DE
  LD A,E
  AND $02
  JR Z,L85C9_2
  LD A,E
  AND $08
  JR NZ,L85C9_0
  LD HL,L8597
  CALL L8CD7
L85C9_0:
  CALL L914D
  LD DE,($BBE9)
  LD BC,$C200
  LD HL,($BF66)
  LD A,H
  OR L
  LD HL,($BF68)
  OR H
  OR L
  AND A
  JR Z,L85C9_1
  DEC DE
  LD HL,$0012
  ADD HL,BC
  LD B,H
  LD C,L
L85C9_1:
  EX DE,HL
  LD DE,$0012
  LD IX,L8985
  CALL L8898
; This entry point is used by the routine at L85A2.
L85C9_2:
  LD A,$2A
  LD HL,$BC00
  RST $08
  DEFB $A8
  POP DE
  LD A,E
  LD ($8674),A
  AND $01
  JR Z,L864C_4
  LD A,E
  AND $08
  JR NZ,L864C_1
  LD A,($BF6D)
  AND A
  JR Z,L864C_1
  LD BC,($BBE9)
  LD HL,$C200
; This entry point is used by the routine at L864C.
L85C9_3:
  PUSH BC
  LD A,(HL)
  AND $01
  JR Z,L864C_0
  LD DE,L84EC
  LD A,($BF6D)
  LD B,A
  LD ($864D),HL
  INC HL
L85C9_4:
  LD A,(HL)
  LD C,A
  LD A,(DE)
  CP C
  JR NZ,L864C
  INC HL
  INC DE
  DJNZ L85C9_4
  POP BC
  LD HL,($BBE9)
  OR A
  SBC HL,BC
  LD ($BBEF),HL
  JR L864C_1

; Routine at 864C
;
; Used by the routine at L85C9.
L864C:
  LD HL,$0000
; This entry point is used by the routine at L85C9.
L864C_0:
  LD BC,$0012
  ADD HL,BC
  POP BC
  DEC BC
  LD A,B
  OR C
  JR NZ,L85C9_3
; This entry point is used by the routine at L85C9.
L864C_1:
  LD HL,($BBEF)
  LD A,H
  OR L
  AND A
  JR Z,L864C_2
  CALL L894E_0
  AND A
  JR NZ,L864C_2
  LD HL,($BBEF)
  LD ($BBEB),HL
L864C_2:
  LD HL,$BC00
  CALL L8CD7
  LD A,$00
  AND $10
  JR Z,L864C_3
  LD BC,$001F
  LD HL,L868B
  CALL L9808
L864C_3:
  CALL L8A15
; This entry point is used by the routine at L85C9.
L864C_4:
  XOR A
  LD L,A
  CALL LA1E2
  RET

; Routine at 868B
L868B:
  LD HL,($2300)
  LD (L8725),HL
  EX DE,HL
  LD A,$01
  LD ($BF73),A
  LD L,A
  CALL LA1E2
; This entry point is used by the routine at L8701.
L868B_0:
  LD A,(DE)
  AND A
  JP Z,L871C
  CP $2F
  JR NZ,L8701_2
  XOR A
  LD (DE),A
  LD BC,($BBE9)
  LD HL,$C200
; This entry point is used by the routine at L8701.
L868B_1:
  PUSH BC
  LD A,(HL)
  AND $01
  JR Z,L8701_0
  PUSH HL
  LD ($870D),DE
  INC HL
  CALL L8533
  LD DE,(L8725)
  LD HL,$BBF3
L868B_2:
  LD A,(HL)
  CP $41
  JR C,L868B_3
  CP $5B
  JR NC,L868B_3
  OR $20
L868B_3:
  LD C,A
  LD A,(DE)
  CP $41
  JR C,L868B_4
  CP $5B
  JR NC,L868B_4
  OR $20
L868B_4:
  CP C
  JR NZ,L8701
  INC DE
  INC HL
  OR A
  JR NZ,L868B_2
  LD A,(DE)
  DEC DE
  LD ($870D),DE
  POP HL
  POP BC
  LD BC,$000E
  ADD HL,BC
  LD DE,$BF66
  LDI
  LDI
  LDI
  LDI
  AND A
  JR Z,L8701_1
  CALL L914D
  JR L8701_1

; Routine at 8701
;
; Used by the routine at L868B.
L8701:
  POP HL
; This entry point is used by the routine at L868B.
L8701_0:
  LD BC,$0012
  ADD HL,BC
  POP BC
  DEC BC
  LD A,B
  OR C
  JR NZ,L868B_1
; This entry point is used by the routine at L868B.
L8701_1:
  LD DE,$0000
  LD A,$2F
  LD (DE),A
  LD H,D
  LD L,E
  INC HL
  LD (L8725),HL
; This entry point is used by the routine at L868B.
L8701_2:
  INC DE
  JP L868B_0

; Routine at 871C
;
; Used by the routine at L868B.
L871C:
  XOR A
  LD ($BF73),A
  LD L,A
  CALL LA1E2
  RET

; Data block at 8725
L8725:
  DEFB $00,$00

; Message at 8727
L8727:
  DEFM "/bin/browse.cfg"

; Data block at 8736
L8736:
  DEFB $00

; Message at 8737
L8737:
  DEFM "/bin/brows"

; Routine at 8741
L8741:
  LD H,L
  LD L,$66
  LD L,(HL)
  LD (HL),H
  NOP
; This entry point is used by the routine at L9E39.
L8741_0:
  LD HL,L8727
  LD BC,$0000
  LD DE,$A40F
  CALL L941E
  LD HL,L8737
  LD BC,$0308
  LD DE,L98C3
  CALL L941E
  CALL L987B
  RET

; Routine at 8763
;
; Used by the routines at L8E21 and L9E85.
L8763:
  LD HL,$0000
  LD ($BF66),HL
  LD ($BF68),HL
  LD A,$02
  CALL L85A2
  LD HL,$BC00
  CALL $868D
  RET

; Unused
L8778:
  DEFS $07

; Routine at 877F
;
; Used by the routines at L8E21 and L8E8C.
L877F:
  LD HL,$BBF3
  LD DE,$0000
L877F_0:
  LD A,(HL)
  OR A
  JR Z,L8792
  CP $2E
  JR NZ,L877F_1
  LD D,H
  LD E,L
L877F_1:
  INC HL
  JR L877F_0

; Routine at 8792
;
; Used by the routine at L877F.
L8792:
  LD A,D
  OR E
  RET Z
  EX DE,HL
  LD DE,L8778
  LD BC,$0004
  PUSH HL
  LDIR
  POP HL
  XOR A
  LD ($A3AB),A
  LD (LA3C2),A
  LD DE,LA39D
  INC HL
  PUSH HL
  CALL LA13E
  POP HL
  LD DE,LA3C2
  PUSH DE
  CALL LA13E
  POP DE
  LD HL,$8732
  CALL LA13E
  LD HL,$0000
  LD ($877D),HL
; This entry point is used by the routines at L8829 and L8851.
L8792_0:
  LD HL,LA39D
  CALL LA272
  LD A,($A3F4)
  LD B,A
  AND $08
  JP Z,L885C
  LD A,B
  AND $02
  JR Z,L8792_1
  LD A,$01
  LD ($A3F7),A
; This entry point is used by the routine at L8829.
L8792_1:
  LD A,($A3F5)
  CP $03
  JR NZ,L87F1
  LD HL,$0000
  LD ($BBEF),HL
  LD A,$01
  LD ($A3F5),A
  JR L87F1_0

; Routine at 87F1
;
; Used by the routine at L8792.
L87F1:
  CP $04
  JR NZ,L87F1_0
  LD HL,($BBE9)
  LD ($BBEF),HL
  LD A,$02
  LD ($A3F5),A
; This entry point is used by the routine at L8792.
L87F1_0:
  CP $01
  JR NZ,L881C
  LD HL,($BBEF)
  LD D,H
  LD E,L
  INC HL
  LD ($BBEF),HL
  LD BC,($BBE9)
  OR A
  SBC HL,BC
  JR NZ,L8829
  EX DE,HL
  LD ($BBEF),HL
  JR L885C

; Routine at 881C
;
; Used by the routine at L87F1.
L881C:
  LD HL,($BBEF)
  DEC HL
  LD ($BBEF),HL
  LD A,H
  OR L
  JR NZ,L8829
  JR L885C

; Routine at 8829
;
; Used by the routines at L87F1 and L881C.
L8829:
  CALL L850C
  LD DE,$BBF3
  LD HL,L8778
  CALL LA151
  JR C,L8792_1
  LD A,($A3F7)
  OR A
  JR NZ,L8792_0
  LD HL,($BBEF)
  CALL L894E_0
  AND A
  JR NZ,L8851
  LD HL,($BBEF)
  LD ($BBEB),HL
  CALL L8A15
  JR L8851_0

; Routine at 8851
;
; Used by the routine at L8829.
L8851:
  LD A,$80
  CALL L8AB7_0
; This entry point is used by the routine at L8829.
L8851_0:
  CALL L850C
  JP L8792_0

; Routine at 885C
;
; Used by the routines at L8792, L87F1 and L881C.
L885C:
  CALL LA267
  LD HL,($877D)
  LD A,H
  OR L
  JR Z,L8882_2
  PUSH HL
  CALL L894E_0
  POP HL
  AND A
  JR NZ,L8882_1
  EX DE,HL
  LD HL,$BBE9
  LD BC,$0016
  OR A
  SBC HL,BC
  EX DE,HL
  JR C,L8882
  LD DE,$0015
  SBC HL,DE
  JR L8882_0

; Routine at 8882
;
; Used by the routine at L885C.
L8882:
  LD DE,$0000
  LD ($BBEB),DE
; This entry point is used by the routine at L885C.
L8882_0:
  LD ($BBED),HL
; This entry point is used by the routine at L885C.
L8882_1:
  LD ($BBEF),HL
; This entry point is used by the routine at L885C.
L8882_2:
  LD A,($A3F7)
  OR A
  RET Z
  CALL LA38A
  RET

; Routine at 8898
;
; Used by the routine at L85C9.
L8898:
  LD ($88FB),IX
  EX DE,HL
  PUSH DE
  PUSH HL
  LD ($8926),BC
  CALL L892A
  LD ($8920),HL
; This entry point is used by the routine at L88CD.
L8898_0:
  POP DE
  POP HL
  SRL H
  RR L
  LD A,H
  OR L
  RET Z
  PUSH HL
  PUSH DE
  CALL L892A
  LD ($8928),HL
  POP DE
  PUSH DE
  PUSH HL
  ADD HL,DE
  LD ($8922),HL
  LD DE,($8926)
  EX (SP),HL
  ADD HL,DE
  LD ($8924),HL
  POP HL
  JR L88CD_0

; Routine at 88CD
L88CD:
  LD DE,(L891C)
  POP HL
  PUSH HL
  ADD HL,DE
; This entry point is used by the routine at L8898.
L88CD_0:
  LD (L891C),HL
  EX DE,HL
  LD HL,($8920)
  SBC HL,DE
  JR C,L8898_0
  LD HL,($8922)
  EX DE,HL
L88CD_1:
  AND A
  SBC HL,DE
  LD ($891E),HL
  JP M,L88CD
  LD C,L
  LD B,H
  LD HL,($8924)
  ADD HL,BC
  EX DE,HL
  LD HL,($8926)
  ADD HL,BC
  PUSH HL
  PUSH BC
  PUSH DE
  CALL $0000
  LD A,H
  OR A
  LD A,L
  POP DE
  POP BC
  POP HL
  JP P,L88CD
  POP BC
  PUSH BC
  PUSH HL
L88CD_2:
  LD A,(DE)
  LDI
  DEC HL
  LD (HL),A
  INC HL
  JP PE,L88CD_2
  POP HL
  LD HL,($891E)
  LD DE,($8928)
  JR L88CD_1

; Unused
L891C:
  DEFS $0E

; Routine at 892A
;
; Used by the routine at L8898.
L892A:
  INC H
  DEC H
  JR Z,L8938_0
  INC D
  DEC D
  JR Z,L8938
  LD C,L
  LD A,H
  LD B,$10
  JR L8938_1

; Routine at 8938
;
; Used by the routine at L892A.
L8938:
  EX DE,HL
; This entry point is used by the routine at L892A.
L8938_0:
  LD A,L
  LD B,$08
; This entry point is used by the routine at L892A.
L8938_1:
  LD HL,$0000
L8938_2:
  ADD HL,HL
  RL C
  RLA
  JR NC,L8938_3
  ADD HL,DE
L8938_3:
  DJNZ L8938_2
  OR A
  RET

; Message at 894A
L894A:
  DEFM "<DIR"

; Routine at 894E
L894E:
  LD A,$00
; This entry point is used by the routines at L864C, L8829, L885C, L8AC8,
; L8AEB, L8B30, L8B5D and L8BC5.
L894E_0:
  EX DE,HL
  OR A
  LD HL,($BBEB)
  SBC HL,DE
  JR Z,L894E_1
  JR NC,L8966
  OR A
  LD HL,($BBED)
  SBC HL,DE
  JR C,L8966
L894E_1:
  LD A,$01
  RET

; Routine at 8966
;
; Used by the routine at L894E.
L8966:
  XOR A
  RET

; Routine at 8968
;
; Used by the routine at L8A1F.
L8968:
  LD B,$16
  LD C,$01
L8968_0:
  PUSH BC
  LD B,C
  CALL L97E3
  POP BC
  INC C
  DJNZ L8968_0
  LD A,(LA412)
  LD HL,$5820
  LD (HL),A
  LD DE,$5821
  LD BC,$02BF
  LDIR
  RET

; Routine at 8985
L8985:
  LD A,(HL)
  LD B,A
  LD A,(DE)
  CP B
  JR NZ,L89BC
  EX DE,HL
  PUSH DE
  CALL L8517
  EX DE,HL
  POP HL
  PUSH DE
  CALL L8517
  POP DE
L8985_0:
  LD A,(HL)
  CP $41
  JR C,L8985_1
  CP $5B
  JR NC,L8985_1
  OR $20
L8985_1:
  LD C,A
  LD A,(DE)
  CP $41
  JR C,L8985_2
  CP $5B
  JR NC,L8985_2
  OR $20
L8985_2:
  CP C
  JR NZ,L89B9
  INC DE
  INC HL
  OR A
  JR NZ,L8985_0
  LD L,A
  LD H,A
  RET

; Routine at 89B9
;
; Used by the routine at L8985.
L89B9:
  SUB C
  LD H,A
  RET

; Routine at 89BC
;
; Used by the routine at L8985.
L89BC:
  AND $01
  JR Z,L89C4
  LD HL,$FFFF
  RET

; Routine at 89C4
;
; Used by the routine at L89BC.
L89C4:
  LD HL,$0001
  RET

; Routine at 89C8
;
; Used by the routines at L89E4, L8A1F, L8B5D, L8BC5, L8C39 and L8C53.
L89C8:
  LD A,C
  AND $80
  JR Z,L89D2
  LD A,($A414)
  JR L89DC_0

; Routine at 89D2
;
; Used by the routine at L89C8.
L89D2:
  LD A,C
  AND $01
  JR Z,L89DC
  LD A,($A413)
  JR L89DC_0

; Routine at 89DC
;
; Used by the routine at L89D2.
L89DC:
  LD A,(LA412)
; This entry point is used by the routines at L89C8 and L89D2.
L89DC_0:
  LD C,A
  CALL L977A
  RET

; Routine at 89E4
;
; Used by the routines at L8A1F, L8B5D, L8BC5, L8DE9 and L9726.
L89E4:
  PUSH BC
  LD HL,($BF62)
  CALL L8517
  JR NC,L89E4_0
  CALL L8533
  LD HL,$BBF3
L89E4_0:
  POP BC
  PUSH BC
  LD C,$00
  CALL L9808
  POP BC
  LD A,C
  AND $01
  JR Z,L89E4_1
  LD A,($A416)
  AND $01
  JR Z,L89E4_1
  PUSH BC
  LD HL,L894A
  LD C,$1C
  CALL L9808
  POP BC
L89E4_1:
  CALL L89C8
  RET

; Routine at 8A15
;
; Used by the routines at L864C, L8829, L8C39 and L96E0.
L8A15:
  LD A,($BBE6)
  AND A
  JR Z,L8A1F
  CALL L9726
  RET

; Routine at 8A1F
;
; Used by the routine at L8A15.
L8A1F:
  LD HL,($BF62)
  PUSH HL
  LD A,$01
  LD (L8AA2),A
  LD A,($BBE4)
  AND A
  JR Z,L8A1F_0
  LD C,$00
  LD B,A
  CALL L89C8
L8A1F_0:
  CALL L8968
  OR A
  LD HL,($BBE9)
  LD D,H
  LD E,L
  LD BC,($BBEF)
  SBC HL,BC
  JR NZ,L8A1F_1
  EX DE,HL
  DEC HL
  LD ($BBEF),HL
L8A1F_1:
  LD HL,($BBEB)
  CALL L84F9
  LD BC,($BBEB)
L8A1F_2:
  EX DE,HL
  LD HL,($BBE9)
  OR A
  SBC HL,BC
  JR Z,L8A98
  EX DE,HL
  LD A,(L8AA2)
  LD D,A
  LD A,(HL)
  LD E,A
  PUSH HL
  PUSH BC
  LD HL,($BBEF)
  OR A
  SBC HL,BC
  JR NZ,L8A1F_3
  LD A,D
  LD ($BBE4),A
  LD A,E
  LD ($BBE8),A
  OR $80
L8A1F_3:
  LD B,D
  LD C,A
  CALL L89E4
  POP BC
  POP HL
  LD ($BBED),BC
  LD A,(L8AA2)
  INC A
  CP $17
  JR Z,L8A98
  LD (L8AA2),A
  LD DE,$0012
  ADD HL,DE
  LD ($BF62),HL
  INC BC
  JR L8A1F_2

; Routine at 8A98
;
; Used by the routine at L8A1F.
L8A98:
  LD L,$0F
  CALL LA017
  POP HL
  LD ($BF62),HL
  RET

; Unused
L8AA2:
  DEFS $01

; Routine at 8AA3
L8AA3:
  LD A,$03
  JR L8AB7_0

; Routine at 8AA7
L8AA7:
  LD A,$04
  JR L8AB7_0

; Routine at 8AAB
L8AAB:
  LD A,$01
  JR L8AB7_0

; Routine at 8AAF
L8AAF:
  LD A,$02
  JR L8AB7_0

; Routine at 8AB3
L8AB3:
  LD A,$05
  JR L8AB7_0

; Routine at 8AB7
L8AB7:
  LD A,$06
; This entry point is used by the routines at L8851, L8AA3, L8AA7, L8AAB, L8AAF
; and L8AB3.
L8AB7_0:
  LD HL,($BBEF)
  LD D,H
  LD E,L
  CP $80
  JR NZ,L8AC8
  INC HL
  LD C,$00
  JP L8BC5_3

; Routine at 8AC8
;
; Used by the routine at L8AB7.
L8AC8:
  CP $03
  JR NZ,L8AEB
  LD DE,$0000
  PUSH DE
  EX DE,HL
  CALL L894E_0
  POP DE
  AND A
  JP NZ,L8BC5_1
  LD HL,$0000
  LD ($BBEB),HL
  LD HL,$0016
  LD ($BBED),BC
  LD C,$FF
  JP L8BC5_2

; Routine at 8AEB
;
; Used by the routine at L8AC8.
L8AEB:
  CP $04
  JR NZ,L8B17
  LD DE,($BBE9)
  DEC DE
; This entry point is used by the routine at L8B17.
L8AEB_0:
  PUSH DE
  EX DE,HL
  CALL L894E_0
  POP DE
  AND A
  JP NZ,L8BC5_1
  LD H,D
  LD L,E
  LD BC,$0015
  OR A
  SBC HL,BC
  JR NC,L8AEB_1
  LD HL,$0000
L8AEB_1:
  LD ($BBEB),HL
  LD ($BBED),DE
  LD C,$FF
  JP L8BC5_2

; Routine at 8B17
;
; Used by the routine at L8AEB.
L8B17:
  CP $06
  JR NZ,L8B30
  EX DE,HL
  LD DE,$0016
  ADD HL,DE
  EX DE,HL
  LD HL,($BBE9)
  DEC HL
  LD B,H
  LD C,L
  OR A
  SBC HL,DE
  JR NC,L8B17_0
  LD D,B
  LD E,C
L8B17_0:
  JR L8AEB_0

; Routine at 8B30
;
; Used by the routine at L8B17.
L8B30:
  CP $05
  JR NZ,L8B5D
  EX DE,HL
  LD DE,$0016
  OR A
  SBC HL,DE
  EX DE,HL
  JR NC,L8B30_0
  LD DE,$0000
L8B30_0:
  PUSH DE
  EX DE,HL
  CALL L894E_0
  POP DE
  AND A
  JP NZ,L8BC5_1
  LD ($BBEB),DE
  LD H,D
  LD L,E
  LD BC,$0016
  ADD HL,BC
  LD ($BBED),HL
  LD C,$FF
  JP L8BC5_2

; Routine at 8B5D
;
; Used by the routine at L8B30.
L8B5D:
  CP $01
  JR NZ,L8BC5
  LD A,D
  OR E
  JP Z,L8BC5_1
  DEC DE
  PUSH DE
  EX DE,HL
  CALL L894E_0
  POP DE
  AND A
  JP NZ,L8BC5_1
  LD BC,($BBEB)
  DEC BC
  LD ($BBEB),BC
  LD HL,($BBED)
  PUSH HL
  OR A
  SBC HL,BC
  LD A,L
  POP HL
  CP $16
  JR C,L8B5D_0
  DEC HL
  LD ($BBED),HL
L8B5D_0:
  LD A,($BBE6)
  AND A
  JP NZ,L8BC5_1
  PUSH DE
  LD B,$01
  LD A,($BBE8)
  LD C,A
  CALL L89C8
  XOR A
  LD ($BBE4),A
  LD B,$15
  LD C,$16
L8B5D_1:
  PUSH BC
  LD A,B
  LD B,C
  LD C,A
  CALL L9792
  POP BC
  DEC C
  DJNZ L8B5D_1
  LD B,$01
  CALL L97E3
  POP DE
  LD H,D
  LD L,E
  CALL L84F9
  PUSH DE
  LD A,(HL)
  LD B,$01
  LD C,A
  CALL L89E4
  POP DE
  JR L8BC5_1

; Routine at 8BC5
;
; Used by the routine at L8B5D.
L8BC5:
  CP $02
  JR NZ,L8BC5_1
  LD HL,($BBE9)
  DEC HL
  OR A
  SBC HL,DE
  JR C,L8BC5_1
  JR Z,L8BC5_1
  INC DE
  PUSH DE
  EX DE,HL
  CALL L894E_0
  POP DE
  AND A
  JR NZ,L8BC5_1
  LD HL,($BBEB)
  INC HL
  LD ($BBEB),HL
  LD HL,($BBED)
  INC HL
  LD ($BBED),HL
  LD A,($BBE6)
  AND A
  JR NZ,L8BC5_1
  PUSH DE
  LD B,$16
  LD A,($BBE8)
  LD C,A
  CALL L89C8
  XOR A
  LD ($BBE4),A
  LD B,$15
  LD C,$01
L8BC5_0:
  PUSH BC
  LD B,C
  INC C
  CALL L9792
  POP BC
  INC C
  DJNZ L8BC5_0
  LD B,$16
  CALL L97E3
  POP DE
  LD H,D
  LD L,E
  CALL L84F9
  PUSH DE
  LD A,(HL)
  LD B,$16
  LD C,A
  CALL L89E4
  POP DE
; This entry point is used by the routines at L8AC8, L8AEB, L8B30 and L8B5D.
L8BC5_1:
  LD C,$00
; This entry point is used by the routines at L8AC8, L8AEB and L8B30.
L8BC5_2:
  LD HL,($BBEF)
; This entry point is used by the routine at L8AB7.
L8BC5_3:
  OR A
  SBC HL,DE
  RET Z
  LD ($BBEF),DE
  LD A,($BBE6)
  AND A
  JR Z,L8C39
  CALL L9726
  RET

; Routine at 8C39
;
; Used by the routine at L8BC5.
L8C39:
  LD A,($BBE4)
  AND A
  JR Z,L8C39_0
  PUSH BC
  PUSH DE
  LD B,A
  LD A,($BBE8)
  LD C,A
  CALL L89C8
  POP DE
  POP BC
L8C39_0:
  LD A,C
  AND A
  JR Z,L8C53
  CALL L8A15
  RET

; Routine at 8C53
;
; Used by the routine at L8C39.
L8C53:
  EX DE,HL
  LD DE,($BBEB)
  OR A
  SBC HL,DE
  INC L
  LD A,L
  LD ($BBE4),A
  LD D,A
  LD HL,($BBEF)
  CALL L84F9
  LD A,(HL)
  LD ($BBE8),A
  OR $80
  LD C,A
  LD A,D
  LD B,A
  CALL L89C8
  LD L,$04
  CALL LA017
  LD B,$03
  CALL LA118_0
  RET

; Routine at 8C7E
;
; Used by the routines at L954F and LA272.
L8C7E:
  PUSH HL
  LD B,$15
  CALL L97E3
  LD B,$16
  CALL L97E3
  LD B,$15
  LD A,($A40F)
  LD C,A
  CALL L977A
  LD B,$16
  LD A,($A414)
  LD C,A
  CALL L977A
  POP HL
  LD B,$15
  LD C,$00
  CALL L9808
  RET

; Routine at 8CA4
;
; Used by the routines at L954F and LA384.
L8CA4:
  LD A,L
  AND A
  JR NZ,L8CA4_0
  LD B,$00
  LD C,$14
  LD HL,($BBE9)
  OR A
  SBC HL,BC
  JR C,L8CBA
L8CA4_0:
  LD A,$03
  CALL L85A2
  RET

; Routine at 8CBA
;
; Used by the routine at L8CA4.
L8CBA:
  LD B,$15
  CALL L97E3
  LD B,$16
  CALL L97E3
  LD B,$15
  LD A,(LA412)
  LD C,A
  CALL L977A
  LD B,$16
  LD A,(LA412)
  LD C,A
  CALL L977A
  RET

; Routine at 8CD7
;
; Used by the routines at L85C9, L864C, L952E, L95FD and L96E0.
L8CD7:
  PUSH HL
  LD B,$00
  CALL L97E3
  POP HL
  LD BC,$0000
  CALL L9808
  RET

; Routine at 8CE5
;
; Used by the routines at L8CF7 and L8E53.
L8CE5:
  ADD HL,BC
  LD DE,$BF66
  LDI
  LDI
  LDI
  LDI
; This entry point is used by the routine at L8E21.
L8CE5_0:
  LD A,$07
  CALL L85A2
  RET

; Routine at 8CF7
L8CF7:
  LD A,$2A
  LD HL,L8D2F
  RST $08
  DEFB $A9
  JR C,L8D29
  CALL L8559
  LD HL,$0000
  CALL L84F9
  LD A,(HL)
  AND $01
  RET Z
  INC HL
  LD A,(HL)
  CP $2E
  RET NZ
  LD BC,$000D
  CALL L8CE5
  LD A,L
  AND A
  JR NZ,L8D20
  CALL L9D2B
  RET

; Routine at 8D20
;
; Used by the routine at L8CF7.
L8D20:
  LD HL,$BC00
  RST $08
  DEFB $A9
  LD A,$03
  JR L8D29_0

; Routine at 8D29
;
; Used by the routines at L8CF7, L96A7 and L96E0.
L8D29:
  LD A,$02
; This entry point is used by the routine at L8D20.
L8D29_0:
  CALL L9DD4_0
  RET

; Routine at 8D2F
L8D2F:
  LD L,$2E
  NOP
  LD HL,L8F76
  CALL L8EA8
  RET

; Routine at 8D39
L8D39:
  LD A,($BBE5)
  OR A
  RET Z
  LD HL,L8F72
  JR L8D52_0

; Routine at 8D43
L8D43:
  LD HL,L8F92
  JR L8D52_0

; Routine at 8D48
L8D48:
  LD HL,L8F8A
  JR L8D52_0

; Routine at 8D4D
L8D4D:
  LD HL,L8F66
  JR L8D52_0

; Routine at 8D52
L8D52:
  LD A,(LA20F)
  AND A
  RET Z
  LD HL,L8F8E
; This entry point is used by the routines at L8D39, L8D43, L8D48 and L8D4D.
L8D52_0:
  CALL $A254
  RET

; Routine at 8D5E
L8D5E:
  LD A,($BBE5)
  AND A
  RET Z
  LD HL,($BBF1)
  LD ($A3FB),HL
  LD HL,L8F7A
  CALL $A254
  RET

; Routine at 8D70
L8D70:
  XOR A
  JR L8D73_0

; Routine at 8D73
L8D73:
  LD A,$01
; This entry point is used by the routine at L8D70.
L8D73_0:
  LD ($A3FA),A
  LD HL,$BBE2
  LD ($A3FB),HL
  XOR A
  LD ($A3F4),A
  LD HL,$8FA2
  CALL L8EA8
  AND A
  RET Z
  LD L,$02
  CALL LA017
  RET

; Routine at 8D90
L8D90:
  XOR A
  JR L8D93_0

; Routine at 8D93
L8D93:
  LD A,$80
; This entry point is used by the routine at L8D90.
L8D93_0:
  OR $01
  JR L8D9C_1

; Routine at 8D99
L8D99:
  XOR A
  JR L8D9C_0

; Routine at 8D9C
L8D9C:
  LD A,$80
; This entry point is used by the routine at L8D99.
L8D9C_0:
  OR $00
; This entry point is used by the routine at L8D93.
L8D9C_1:
  LD HL,L8F82
  CALL L8E93
  RET

; Routine at 8DA7
L8DA7:
  LD A,$03
  LD HL,L8F86
  CALL L8E93
  RET

; Routine at 8DB0
L8DB0:
  LD A,$02
  LD HL,L8F86
  CALL L8E93
  RET

; Routine at 8DB9
L8DB9:
  RST $18
  NOP
  NOP
  RET

; Routine at 8DBD
L8DBD:
  LD HL,$BBE5
  LD A,(HL)
  OR A
  RET Z
  INC A
  LD (HL),A
; This entry point is used by the routine at L9D81.
L8DBD_0:
  LD HL,$BBE3
  INC (HL)
  RET

; Routine at 8DCA
L8DCA:
  LD A,$01
  LD HL,L8F86
  CALL L8E93
  RET

; Routine at 8DD3
L8DD3:
  LD A,$02
  JR L8DDB_0

; Routine at 8DD7
L8DD7:
  LD A,$01
  JR L8DDB_0

; Routine at 8DDB
L8DDB:
  LD A,$03
; This entry point is used by the routines at L8DD3 and L8DD7.
L8DDB_0:
  LD HL,L8F96
  CALL L8E93
  RET

; Routine at 8DE4
L8DE4:
  LD HL,L8F6A
  JR L8DE9_0

; Routine at 8DE9
L8DE9:
  LD HL,L8F6E
; This entry point is used by the routine at L8DE4.
L8DE9_0:
  PUSH HL
  CALL L850C
  LD B,$00
  CALL L97E3
  LD BC,$0000
  CALL L89E4
  LD A,($A40F)
  LD C,A
  LD B,$00
  CALL L977A
  POP HL
  CALL $A254
  RET

; Routine at 8E09
L8E09:
  LD A,($BBE5)
  AND A
  RET NZ
  LD HL,$8F9E
  CALL L8EA8
  AND A
  RET Z
  LD A,$FF
  LD ($BBE6),A
  LD A,$01
  LD ($BBE3),A
  RET

; Routine at 8E21
L8E21:
  XOR A
; This entry point is used by the routine at L9D94.
L8E21_0:
  LD ($A3FA),A
  AND A
  JR NZ,L8E21_1
  CALL L850C
L8E21_1:
  LD HL,$8F9A
  CALL $A254
  LD A,($A3F4)
  LD B,A
  AND $01
  RET Z
  LD A,B
  PUSH AF
  CALL L8763
  CALL L8CE5_0
  POP AF
  AND $40
  RET Z
  LD HL,$A3CA
  LD DE,$BBF3
  LD BC,$000D
  LDIR
  CALL L877F
  RET

; Routine at 8E53
;
; Used by the routine at L9690.
L8E53:
  CALL L850C
  LD HL,($BF62)
  LD A,(HL)
  AND $01
  JR Z,L8E7A
  LD HL,($BBEF)
  LD A,H
  OR L
  JR NZ,L8E53_0
  CALL L8559
L8E53_0:
  LD A,$2A
  LD HL,$BBF3
  RST $08
  DEFB $A9
  LD HL,($BF62)
  LD BC,$000E
  CALL L8CE5
  JR L8E8C_0

; Routine at 8E7A
;
; Used by the routine at L8E53.
L8E7A:
  CALL L94B2
  CALL $9D15
  AND $01
  JR Z,L8E8C
  LD HL,$8FA6
  CALL $A254
  JR L8E8C_0

; Routine at 8E8C
;
; Used by the routine at L8E7A.
L8E8C:
  CALL L877F
; This entry point is used by the routines at L8E53 and L8E7A.
L8E8C_0:
  CALL L9D2B
  RET

; Routine at 8E93
;
; Used by the routines at L8D9C, L8DA7, L8DB0, L8DCA and L8DDB.
L8E93:
  LD ($A3FA),A
  PUSH HL
  CALL L850C
  LD HL,($BF62)
  LD ($A3FB),HL
; This entry point is used by the routine at L8EA8.
L8E93_0:
  POP HL
  CALL $A254
  LD A,($A3F4)
  RET

; Routine at 8EA8
;
; Used by the routines at L8D2F, L8D73 and L8E09.
L8EA8:
  PUSH HL
  CALL L850C
  JR L8E93_0

; Data block at 8EAE
L8EAE:
  DEFB $A7,$8A,$00,$00,$52

; Routine at 8EB3
L8EB3:
  ADC A,L
  AND A
  ADC A,L
  JP Z,$DD8D
  SUB L
  NOP
  NOP
  LD C,L
  ADC A,L
  SBC A,C
  ADC A,L
  NOP
  NOP
  ADD HL,SP
  ADC A,L
  ADD HL,BC
  ADC A,(HL)
  NOP
  NOP
  CP L
  ADC A,L
  SUB B
  ADC A,L
  RST $30
  ADC A,H
  AND E
  ADC A,D
  LD ($5E8D),A
  ADC A,L
  LD C,B
  ADC A,L
  LD (HL),B
  ADC A,L
  CALL PO,$008D
  NOP
  PUSH BC
  ADC A,L
  NOP
  NOP
  LD L,$95
  LD BC,$0402
  EX AF,AF'
  ADD A,B
  INC C
  RET NZ
  POP BC
  JP NZ,L8533_1
  LD A,E
  ADD A,D
  DEC A
  DEC SP
  LD ($3E3C),HL
  LD E,L
  CPL
  LD H,B
  LD A,($FF5F)
  XOR E
  ADC A,D
  XOR A
  ADC A,D
  OR E
  ADC A,D
  OR A
  ADC A,D
  LD D,E
  ADC A,(HL)
  RST $30
  ADC A,H
  RST $30
  ADC A,H
  AND E
  ADC A,D
  AND A
  ADC A,D
  RST $10
  ADC A,L
  NOP
  NOP
  LD B,E
  SUB A
  SBC A,H
  ADC A,L
  LD B,E
  ADC A,L
  SUB E
  ADC A,L
  IN A,($8D)
  OR B
  ADC A,L
  OUT ($8D),A
  LD (HL),E
  ADC A,L
  JP (HL)

; Data block at 8F21
L8F21:
  DEFB $8D,$B9,$8D,$2B,$95,$21,$8E,$57
  DEFB $21,$E2,$8E

; Routine at 8F2C
L8F2C:
  LD BC,$0018
  CPIR
  LD A,B
  OR C
  LD A,D
  JR Z,L8F43
  OR A
  LD HL,$0017
  SBC HL,BC
  ADD HL,HL
  LD DE,$8EFA
  ADD HL,DE
  JR L8F43_0

; Routine at 8F43
;
; Used by the routine at L8F2C.
L8F43:
  CP $41
  RET C
  CP $5B
  RET NC
  SUB $41
  ADD A,A
  LD HL,L8EAE
  LD D,$00
  LD E,A
  ADD HL,DE
; This entry point is used by the routine at L8F2C.
L8F43_0:
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  OR H
  JR Z,L8F43_1
  CALL $A11E
  LD B,$03
  CALL LA118_0
  LD A,$01
L8F43_1:
  LD L,A
  RET

; Message at 8F66
L8F66:
  DEFM "HLP"

; Data block at 8F69
L8F69:
  DEFB $00

; Message at 8F6A
L8F6A:
  DEFM "HEX"

; Data block at 8F6D
L8F6D:
  DEFB $00

; Message at 8F6E
L8F6E:
  DEFM "TXT"

; Data block at 8F71
L8F71:
  DEFB $00

; Message at 8F72
L8F72:
  DEFM "POK"

; Data block at 8F75
L8F75:
  DEFB $00

; Message at 8F76
L8F76:
  DEFM "INF"

; Data block at 8F79
L8F79:
  DEFB $00

; Message at 8F7A
L8F7A:
  DEFM "SNA"

; Data block at 8F7D
L8F7D:
  DEFB $00

; Message at 8F7E
L8F7E:
  DEFM "DBG"

; Data block at 8F81
L8F81:
  DEFB $00

; Message at 8F82
L8F82:
  DEFM "TAP"

; Data block at 8F85
L8F85:
  DEFB $00

; Message at 8F86
L8F86:
  DEFM "DOS"

; Data block at 8F89
L8F89:
  DEFB $00

; Message at 8F8A
L8F8A:
  DEFM "TPE"

; Data block at 8F8D
L8F8D:
  DEFB $00

; Message at 8F8E
L8F8E:
  DEFM "UNO"

; Data block at 8F91
L8F91:
  DEFB $00

; Message at 8F92
L8F92:
  DEFM "LOK"

; Data block at 8F95
L8F95:
  DEFB $00

; Message at 8F96
L8F96:
  DEFM "CLP"

; Data block at 8F99
L8F99:
  DEFB $00,$53,$50

; Routine at 8F9C
L8F9C:
  LD B,H
  NOP
  LD B,L
  LD E,B
  LD D,H
  NOP
  LD B,H
  LD D,E
  LD C,E
  NOP
  LD B,L
  LD E,B
  LD B,L
  NOP
; This entry point is used by the routines at L900B, L90DB and L921C.
L8F9C_0:
  EX DE,HL
  LD B,H
  LD C,L
  LD A,($BF8E)
  LD HL,$C000
  RST $08
  DEFB $81
  LD HL,$0000
  RET NC
  LD L,A
  RET

; Routine at 8FBB
;
; Used by the routine at L9E39.
L8FBB:
  XOR A
  LD HL,$C000
  RST $08
  DEFB $84
  LD A,($A416)
  AND $20
  JR Z,L8FD6
  CALL L9588_0
  OR A
  JR NZ,L8FD1
  LD A,$02
  RET

; Routine at 8FD1
;
; Used by the routine at L8FBB.
L8FD1:
  LD A,(LA415)
  JR L8FD6_0

; Routine at 8FD6
;
; Used by the routine at L8FBB.
L8FD6:
  LD A,(LA415)
  ADD A,A
  LD B,A
  ADD A,A
  ADD A,B
  LD DE,$C000
  LD H,$00
  LD L,A
  ADD HL,DE
  LD A,(HL)
; This entry point is used by the routine at L8FD1.
L8FD6_0:
  LD ($BF8E),A
  LD B,$08
  LD HL,$C000
  LD DE,$0006
; This entry point is used by the routine at L900B.
L8FD6_1:
  LD A,(HL)
  OR A
  JR Z,L900B_3
  AND $78
  LD C,A
  AND $60
  JR Z,L900B_2
  LD A,C
  AND $18
  SRL A
  SRL A
  SRL A
  OR A
  JR NZ,L900B
  LD A,$01
  JR L900B_1

; Routine at 900B
;
; Used by the routine at L8FD6.
L900B:
  PUSH BC
  LD B,A
L900B_0:
  ADD A,A
  DJNZ L900B_0
  POP BC
; This entry point is used by the routine at L8FD6.
L900B_1:
  LD C,A
  LD A,($BBE2)
  OR C
  LD ($BBE2),A
; This entry point is used by the routine at L8FD6.
L900B_2:
  ADD HL,DE
  DJNZ L8FD6_1
; This entry point is used by the routine at L8FD6.
L900B_3:
  LD HL,$0000
  LD DE,$0000
  CALL L8F9C_0
  LD A,L
  OR A
  JR Z,L902C
  LD A,$80
  RET

; Routine at 902C
;
; Used by the routine at L900B.
L902C:
  LD A,($C00D)
  LD ($BF79),A
  LD DE,($C00B)
  LD ($BF7C),DE
  LD DE,($C00E)
  LD ($BF7E),DE
  LD A,($C012)
  CP $02
  JR NZ,L9097
  LD A,$01
  LD ($BF78),A
  LD HL,($C010)
  LD DE,$0000
  EXX
  LD HL,($C016)
  LD DE,$0000
  CALL L9EC5
  LD BC,($C00E)
  XOR A
  ADD HL,BC
  ADC A,E
  LD E,A
  LD A,$00
  ADC A,D
  LD D,A
  LD ($BF82),HL
  LD ($BF84),DE
  LD HL,$0002
  LD ($BF86),HL
  LD L,$00
  LD ($BF88),HL
  LD HL,($C011)
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  EX DE,HL
  LD HL,$0000
  LD BC,($C00B)
  CALL L9EFC
  LD ($BF7A),DE
  LD A,$00
  JR L90D8_0

; Routine at 9097
;
; Used by the routine at L902C.
L9097:
  OR A
  JR NZ,L90D8
  LD A,$02
  LD ($BF78),A
  LD HL,$0000
  LD ($BF7A),HL
  LD HL,($C010)
  LD DE,$0000
  EXX
  LD HL,($C024)
  LD DE,($C026)
  CALL L9EC5
  LD BC,($C00E)
  XOR A
  ADD HL,BC
  ADC A,E
  LD E,A
  LD A,$00
  ADC A,D
  LD D,A
  LD ($BF82),HL
  LD ($BF84),DE
  LD HL,$C02C
  LD DE,$BF86
  LD BC,$0004
  LDIR
  LD A,$00
  JR L90D8_0

; Routine at 90D8
;
; Used by the routine at L9097.
L90D8:
  LD A,$01
; This entry point is used by the routines at L902C and L9097.
L90D8_0:
  RET

; Routine at 90DB
;
; Used by the routine at L914D.
L90DB:
  XOR A
  OR D
  OR E
  OR H
  OR L
  AND A
  JR NZ,L90DB_0
  LD HL,($BF86)
  LD DE,($BF88)
L90DB_0:
  LD B,$02
  LD A,($BF78)
  CP $01
  JR NZ,L90DB_1
  DEC B
L90DB_1:
  SLA L
  RL H
  RL E
  RL D
  DJNZ L90DB_1
  EX DE,HL
  LD BC,($BF7C)
  CALL L9EFC
  PUSH HL
  LD H,B
  LD L,C
  EX DE,HL
  LD BC,($BF7E)
  XOR A
  ADD HL,BC
  ADC A,E
  LD E,A
  LD A,$00
  ADC A,D
  LD D,A
  CALL L8F9C_0
  POP HL
  LD BC,$C000
  ADD HL,BC
  LD A,($BF78)
  CP $01
  JR NZ,L9133
  LD DE,$0000
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  AND H
  INC A
  JR NZ,L90DB_2
  LD H,D
  LD L,E
L90DB_2:
  RET

; Routine at 9133
;
; Used by the routine at L90DB.
L9133:
  LD C,(HL)
  INC HL
  LD B,(HL)
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  LD A,C
  AND B
  AND E
  INC A
  JR NZ,L914A
  LD A,D
  SUB $0F
  JR NZ,L914A
  LD H,A
  LD L,A
  LD D,A
  LD E,A
  RET

; Routine at 914A
;
; Used by the routine at L9133.
L914A:
  LD L,C
  LD H,B
  RET

; Routine at 914D
;
; Used by the routines at L85C9 and L868B.
L914D:
  LD IX,$C000
  XOR A
  LD ($BE00),A
  LD ($BF72),A
  LD HL,$E001
  LD ($BF74),HL
  LD HL,$0000
  LD ($BF8A),HL
  LD ($BF8C),HL
  LD ($BBE9),HL
  INC HL
  LD ($BF6F),HL
  LD HL,$C200
  LD ($BF80),HL
  LD A,$10
  LD ($BF6E),A
  LD HL,$BF66
  LD DE,$BF8F
  LDI
  LDI
  LDI
  LDI
; This entry point is used by the routine at L921C.
L914D_0:
  CP $10
  JP NZ,L921C_1
  LD A,($BF79)
  LD B,A
  LD A,($BF72)
  CP B
  JR NZ,L914D_1
  LD HL,($BF8F)
  LD DE,($BF91)
  CALL L90DB
  LD A,H
  OR L
  OR D
  OR E
  JP Z,L9254
  LD ($BF8F),HL
  LD ($BF91),DE
  XOR A
  LD ($BF72),A
L914D_1:
  OR A
  JR NZ,L921C
  LD HL,($BF82)
  LD DE,($BF84)
  LD ($BF8A),HL
  LD ($BF8C),DE
  LD BC,($BF8F)
  LD A,B
  OR C
  LD BC,($BF91)
  OR B
  OR C
  JR Z,L921C_0
  XOR A
  LD BC,($BF7A)
  ADD HL,BC
  ADC A,E
  LD E,A
  LD A,$00
  ADC A,D
  LD D,A
  LD ($BF8A),HL
  LD ($BF8C),DE
  XOR A
  LD HL,($BF8F)
  LD BC,($BF86)
  SBC HL,BC
  EX DE,HL
  LD HL,($BF91)
  LD BC,($BF88)
  SBC HL,BC
  EX DE,HL
  EXX
  LD H,$00
  LD A,($BF79)
  LD L,A
  LD DE,$0000
  CALL L9EC5
  LD BC,($BF8A)
  ADD HL,BC
  EX DE,HL
  LD BC,($BF8C)
  ADC HL,BC
  EX DE,HL
  LD ($BF8A),HL
  LD ($BF8C),DE
  JR L921C_0

; Routine at 921C
;
; Used by the routine at L914D.
L921C:
  LD HL,($BF8A)
  LD DE,($BF8C)
  XOR A
  INC HL
  ADC A,E
  LD E,A
  LD A,$00
  ADC A,D
  LD D,A
  LD ($BF8A),HL
  LD ($BF8C),DE
; This entry point is used by the routine at L914D.
L921C_0:
  CALL L8F9C_0
  LD HL,$BF72
  INC (HL)
  LD IX,$C000
  XOR A
  LD ($BF6E),A
; This entry point is used by the routine at L914D.
L921C_1:
  CALL L9363
  OR A
  JR Z,L9254
  LD DE,$0020
  ADD IX,DE
  LD HL,$BF6E
  INC (HL)
  LD A,(HL)
  JP L914D_0

; Routine at 9254
;
; Used by the routines at L914D and L921C.
L9254:
  LD L,$00
  RET

; Routine at 9257
;
; Used by the routine at L9363.
L9257:
  LD A,(HL)
  AND $0F
  DEC A
  LD B,A
  ADD A,A
  ADD A,A
  LD C,A
  ADD A,A
  ADD A,C
  ADD A,B
  LD BC,$BE00
  EX DE,HL
  LD H,$00
  LD L,A
  ADD HL,BC
  EX DE,HL
  PUSH HL
  XOR A
  LD C,$00
  INC HL
; This entry point is used by the routines at L928F and L9297.
L9257_0:
  LD B,A
  LD A,(HL)
  AND A
  JR Z,L9297_0
  CP $20
  JR C,L9257_1
  CP $7F
  JR C,L9257_2
L9257_1:
  LD A,$7E
L9257_2:
  LD (DE),A
  INC DE
  INC C
  INC HL
  INC HL
  LD A,B
  INC A
  CP $05
  JR NZ,L928F
  INC HL
  INC HL
  INC HL
  JR L9257_0

; Routine at 928F
;
; Used by the routine at L9257.
L928F:
  CP $0B
  JR NZ,L9297
  INC HL
  INC HL
  JR L9257_0

; Routine at 9297
;
; Used by the routine at L928F.
L9297:
  CP $0D
  JR NZ,L9257_0
; This entry point is used by the routine at L9257.
L9297_0:
  POP HL
  LD A,(HL)
  AND $40
  JR Z,L9297_1
  XOR A
  LD (DE),A
L9297_1:
  LD A,C
  EX DE,HL
  LD HL,$BF71
  ADD A,(HL)
  LD (HL),A
  EX DE,HL
  LD BC,$000D
  ADD HL,BC
  LD A,(HL)
  LD ($BF61),A
  RET

; Routine at 92B4
;
; Used by the routine at L9363.
L92B4:
  LD HL,$BE00
  LD A,(HL)
  AND A
  RET Z
  CALL L98A8
  LD A,C
  AND A
  RET Z
  LD ($9325),A
  LD E,L
  LD HL,($BF76)
  XOR A
  LD B,$0B
L92B4_0:
  RRCA
  LD D,A
  LD A,(HL)
  ADD A,D
  INC HL
  DJNZ L92B4_0
  LD L,A
  LD A,($BF61)
  CP L
  JP NZ,L934E_0
  LD A,E
  AND A
  JR NZ,L930D_0
  LD A,C
  LD DE,$BE00
  SUB $05
  LD E,A
  LD A,$80
  LD (DE),A
  INC DE
  LD HL,($BF80)
  LD A,(HL)
  AND $01
  JR Z,L92F4
  XOR A
  LD (DE),A
  JR L930D_0

; Routine at 92F4
;
; Used by the routine at L92B4.
L92F4:
  LD HL,$BE00
  LD A,($BF71)
  LD L,A
  LD B,A
L92F4_0:
  LD A,(HL)
  CP $2E
  JR Z,L9306
  DEC HL
  DJNZ L92F4_0
  JR L930D

; Routine at 9306
;
; Used by the routine at L92F4.
L9306:
  LD BC,$0005
  LDIR
  JR L930D_0

; Routine at 930D
;
; Used by the routine at L92F4.
L930D:
  INC DE
  XOR A
  LD (DE),A
; This entry point is used by the routines at L92B4 and L9306.
L930D_0:
  LD DE,$BF6F
  LD HL,($BF80)
  LD BC,$000C
  ADD HL,BC
  LD A,(DE)
  LD (HL),A
  LD C,A
  INC HL
  INC DE
  LD A,(DE)
  LD (HL),A
  DEC DE
  LD H,A
  LD L,C
  LD A,$00
  INC A
  LD B,$00
  LD C,A
  LD E,A
  ADD HL,BC
  LD ($BF6F),HL
  LD BC,$2000
  OR A
  SBC HL,BC
  JR NC,L934E
  LD B,$00
  LD C,E
  LD A,C
  LD DE,($BF74)
  LD HL,$BE00
  LDIR
  LD HL,($BF74)
  LD C,A
  ADD HL,BC
  LD ($BF74),HL
  JR L934E_0

; Routine at 934E
;
; Used by the routine at L930D.
L934E:
  LD HL,($BF80)
  LD BC,$000C
  ADD HL,BC
  XOR A
  LD (HL),A
  INC HL
  LD (HL),A
; This entry point is used by the routines at L92B4 and L930D.
L934E_0:
  LD HL,$BE00
  XOR A
  LD (HL),A
  LD HL,$BF71
  LD (HL),A
  RET

; Routine at 9363
;
; Used by the routine at L921C.
L9363:
  PUSH IX
  LD ($BF76),IX
  LD A,(IX+$00)
  LD H,A
  AND A
  JP Z,L93FE
  LD A,(IX+$0B)
  CP $0F
  JR NZ,L9363_0
  LD HL,($BF76)
  CALL L9257
L9363_0:
  LD A,H
  CP $E5
  JR Z,L9363_4
  CP $2E
  JR NZ,L9363_1
  LD A,($BF6E)
  AND A
  JR Z,L9363_4
L9363_1:
  LD A,(IX+$0B)
  LD B,A
  AND $08
  JR NZ,L9363_4
  LD A,($BF73)
  AND A
  JR Z,L9363_2
  LD A,B
  AND $10
  JR Z,L9363_4
L9363_2:
  LD C,B
  LD HL,($BF80)
  LD DE,$000C
  XOR A
  LD (HL),A
  ADD HL,DE
  LD (HL),A
  INC HL
  LD (HL),A
  LD A,C
  AND $10
  JR Z,L9363_3
  LD HL,($BF80)
  LD A,$01
  LD (HL),A
  LD DE,$000E
  ADD HL,DE
  LD A,(IX+$1A)
  LD (HL),A
  INC HL
  LD A,(IX+$1B)
  LD (HL),A
  INC HL
  LD A,(IX+$14)
  LD (HL),A
  INC HL
  LD A,(IX+$15)
  LD (HL),A
  INC HL
L9363_3:
  LD HL,($BF76)
  LD DE,($BF80)
  INC DE
  LD BC,$000B
  LDIR
  CALL L92B4
  LD HL,($BF80)
  LD BC,$0012
  ADD HL,BC
  LD ($BF80),HL
  LD HL,($BBE9)
  INC HL
  LD ($BBE9),HL
  LD BC,$01AA
  OR A
  SBC HL,BC
  JR Z,L93FE
L9363_4:
  POP IX
  LD A,$01
  RET

; Routine at 93FE
;
; Used by the routine at L9363.
L93FE:
  POP IX
  XOR A
  RET

; Routine at 9402
;
; Used by the routines at L9435 and L9588.
L9402:
  LD A,H
  LD HL,L9412
  PUSH HL
  RST $08
  DEFB $A1
  POP IX
  LD B,(IX+$08)
  LD C,(IX+$07)
  RET

; Unused
L9412:
  DEFS $0C

; Routine at 941E
;
; Used by the routines at L8741 and LA272.
L941E:
  XOR A
  LD (L9455),A
  LD A,$24
; This entry point is used by the routine at L94FD.
L941E_0:
  PUSH DE
  PUSH BC
  LD B,$01
  RST $08
  DEFB $9A
  POP BC
  JR NC,L9435
  POP DE
  LD ($A41D),A
  LD HL,$0000
  RET

; Routine at 9435
;
; Used by the routine at L941E.
L9435:
  LD (L9455),A
  LD H,A
  LD A,C
  OR B
  CALL Z,L9402
  POP HL
  LD A,(L9455)
  RST $08
  DEFB $9D
  JR NC,L9435_0
  LD HL,$0000
  LD ($A41D),A
L9435_0:
  LD A,(L9455)
  RST $08
  DEFB $9B
  LD HL,$0001
  RET

; Unused
L9455:
  DEFS $01

; Routine at 9456
;
; Used by the routine at L952E.
unlink:
  LD A,$2A
  RST $08
  DEFB $AD
  JR C,unlinkError
  LD HL,$0001
  RET

; Routine at 9460
;
; Used by the routine at unlink.
unlinkError:
  LD ($A41D),A
  LD HL,$0000
  RET

; Routine at 9467
;
; Used by the routine at L9E85.
L9467:
  LD A,($A416)
  AND $10
  RET Z
  LD A,$24
  LD B,$01
  LD HL,L94DE
  RST $08
  DEFB $9A
  JR C,L9498_1
  LD ($941D),A
  LD HL,$C000
  LD BC,$0200
  RST $08
  DEFB $9D
  JR C,L9498_1
  LD DE,$BC00
  LD HL,$C000
L9467_0:
  LD A,(DE)
  LD B,A
  LD C,(HL)
  OR C
  JR Z,L9498
  CP B
  JR NZ,L9498_0
  INC DE
  INC HL
  JR L9467_0

; Routine at 9498
;
; Used by the routine at L9467.
L9498:
  LD A,($941D)
  LD HL,$BBEF
  LD BC,$0002
  RST $08
  DEFB $9D
  LD HL,($BBEF)
  CALL L84F9
; This entry point is used by the routine at L9467.
L9498_0:
  LD A,($941D)
  RST $08
  DEFB $9B
; This entry point is used by the routine at L9467.
L9498_1:
  XOR A
  RET C
  INC A
  RET

; Routine at 94B2
;
; Used by the routines at L8E7A and L9E26.
L94B2:
  LD A,($A416)
  AND $10
  RET Z
  LD A,$24
  LD HL,L94DE
  LD B,$0A
  RST $08
  DEFB $9A
  RET C
  LD ($941D),A
  LD HL,$BC00
  LD BC,$0200
  RST $08
  DEFB $9E
  LD A,($941D)
  LD HL,$BBEF
  LD BC,$0002
  RST $08
  DEFB $9E
  LD A,($941D)
  RST $08
  DEFB $9B
  RET

; Message at 94DE
L94DE:
  DEFM "/tmp/browse.bmk"

; Data block at 94ED
L94ED:
  DEFB $00

; Message at 94EE
L94EE:
  DEFM "cache.db"

; Data block at 94F6
L94F6:
  DEFB $00

; Message at 94F7
L94F7:
  DEFM "Cached"

; Routine at 94FD
L94FD:
  LD HL,$2100
  XOR $94
  LD BC,$3E02
  LD DE,$C1FE
  XOR A
  LD (L9455),A
  LD A,$2A
  CALL L941E_0
  LD A,L
  AND A
  JR Z,L94FD_0
  LD DE,($C1FE)
  LD ($BBE9),DE
L94FD_0:
  XOR A
  LD ($A41D),A
  RET

; Message at 9522
L9522:
  DEFM "Deleted"

; Routine at 9529
L9529:
  LD HL,$AF00
  JR L952E_0

; Routine at 952E
L952E:
  LD HL,L8597
  CALL L8CD7
  LD A,$01
; This entry point is used by the routine at L9529.
L952E_0:
  PUSH AF
  LD HL,L94EE
  CALL unlink
  LD A,L
  AND A
  JR Z,L952E_1
  LD L,$0A
  CALL L85A2
L952E_1:
  POP AF
  AND A
  JR NZ,L954F
  LD HL,L9522
  JR L954F_0

; Routine at 954F
;
; Used by the routine at L952E.
L954F:
  LD HL,L94EE
  LD A,$2A
  LD B,$0A
  RST $08
  DEFB $9A
  JR C,L9585
  LD ($941D),A
  LD HL,($BBE9)
  LD ($C1FE),HL
  LD HL,$C1FE
  LD BC,$3E02
  RST $08
  DEFB $9E
  JR C,L9585
  LD A,($941D)
  RST $08
  DEFB $9B
  LD HL,L94F7
; This entry point is used by the routine at L952E.
L954F_0:
  CALL L8C7E
  LD L,$60
  CALL LA126
  LD L,$01
  CALL L8CA4
  LD L,$01
  RET

; Routine at 9585
;
; Used by the routine at L954F.
L9585:
  LD L,$00
  RET

; Routine at 9588
L9588:
  CPL
  NOP
; This entry point is used by the routine at L8FBB.
L9588_0:
  LD HL,L9588
  LD A,$2A
  LD B,$01
  RST $08
  DEFB $A3
  JR C,L95A6
  PUSH AF
  LD H,A
  CALL L9402
  LD A,($9413)
  LD (LA415),A
  POP AF
  RST $08
  DEFB $9B
  LD A,$01
  RET

; Routine at 95A6
;
; Used by the routine at L9588.
L95A6:
  XOR A
  RET

; Routine at 95A8
;
; Used by the routine at L960A.
L95A8:
  LD DE,L9668
; This entry point is used by the routine at L95D3.
L95A8_0:
  LD A,(HL)
  AND A
  JR Z,L95D9
  LD B,A
  LD A,(DE)
  CP $60
  JR C,L95A8_1
  CP $80
  JR NC,L95A8_1
  SUB $20
L95A8_1:
  LD C,A
  LD A,B
  CP $60
  JR C,L95A8_2
  CP $80
  JR NC,L95A8_2
  SUB $20
L95A8_2:
  CP C
  JR NZ,L95D3
  INC DE
  LD A,(DE)
  AND A
  JR NZ,L95D3_0
  LD HL,$0001
  RET

; Routine at 95D3
;
; Used by the routine at L95A8.
L95D3:
  LD DE,L9668
; This entry point is used by the routine at L95A8.
L95D3_0:
  INC HL
  JR L95A8_0

; Routine at 95D9
;
; Used by the routine at L95A8.
L95D9:
  LD HL,$0000
  RET

; Routine at 95DD
L95DD:
  LD HL,($BF6C)
  LD A,(HL)
  XOR $01
  LD (HL),A
; This entry point is used by the routines at L9690 and L96D3.
L95DD_0:
  AND A
  JR Z,L95FD
  XOR A
  LD (L9656),A
  LD HL,L9668
  LD (HL),A
  LD DE,$9669
  LD BC,$000F
  LDIR
  INC A
  LD HL,L9662
  JR L95FD_0

; Routine at 95FD
;
; Used by the routine at L95DD.
L95FD:
  LD HL,$BC00
; This entry point is used by the routine at L95DD.
L95FD_0:
  LD ($BF6C),A
  CALL L8CD7
  CALL L9D2B
  RET

; Routine at 960A
;
; Used by the routines at L96AB and L96E0.
L960A:
  LD A,L
  LD HL,$C200
  LD BC,$0000
  OR A
  JR NZ,L960A_0
  LD HL,($BBEF)
  PUSH HL
  CALL L84F9
  POP BC
L960A_0:
  EX DE,HL
  LD HL,($BBE9)
  SBC HL,BC
  EX DE,HL
; This entry point is used by the routine at L9649.
L960A_1:
  LD A,D
  OR E
  JR Z,L9652
  PUSH DE
  PUSH HL
  CALL L8517
  LD A,(L9656)
  CP $01
  JR NZ,L960A_2
  LD A,(HL)
  LD HL,$BF6A
  LD (HL),A
L960A_2:
  CALL L95A8
  LD A,L
  OR A
  JR Z,L9649
  POP HL
  POP DE
  OR A
  LD HL,($BBE9)
  SBC HL,DE
  JR L9652_0

; Routine at 9649
;
; Used by the routine at L960A.
L9649:
  POP HL
  POP DE
  LD BC,$0012
  ADD HL,BC
  DEC DE
  JR L960A_1

; Routine at 9652
;
; Used by the routine at L960A.
L9652:
  LD HL,$0000
; This entry point is used by the routine at L960A.
L9652_0:
  RET

; Data block at 9656
L9656:
  DEFB $00

; Message at 9657
L9657:
  DEFM "Not found!"

; Data block at 9661
L9661:
  DEFB $00

; Message at 9662
L9662:
  DEFM "Find: "

; Data block at 9668
L9668:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00

; Routine at 9678
;
; Used by the routine at L9D2B.
L9678:
  LD A,C
  CP $0C
  JR NZ,L9690
  LD HL,L9656
  LD A,(HL)
  AND A
  RET Z
  DEC A
  DEC (HL)
  LD B,$00
  LD C,A
  LD HL,L9668
  ADD HL,BC
  XOR A
  LD (HL),A
  JR L96E0_1

; Routine at 9690
;
; Used by the routine at L9678.
L9690:
  CP $80
  JR Z,L9690_0
  CP $0D
  JR NZ,L96AB
L9690_0:
  LD HL,($BBEF)
  LD A,H
  OR L
  JR Z,L96A7
  CALL L8E53
  XOR A
  CALL L95DD_0
  RET

; Routine at 96A7
;
; Used by the routine at L9690.
L96A7:
  CALL L8D29
  RET

; Routine at 96AB
;
; Used by the routine at L9690.
L96AB:
  CP $46
  JR NZ,L96D3
  OR A
  LD HL,($BBE9)
  LD DE,($BBEF)
  SBC HL,DE
  JR C,L96AB_0
  INC DE
  LD ($BBEF),DE
L96AB_0:
  LD L,$00
  CALL L960A
  LD A,H
  OR L
  JR NZ,L96E0_2
  LD L,$01
  CALL L960A
  LD A,H
  OR L
  JR NZ,L96E0_2
  RET

; Routine at 96D3
;
; Used by the routine at L96AB.
L96D3:
  CP $20
  JR NZ,L96E0
  LD A,B
  AND A
  JR Z,L96E0_0
  XOR A
  CALL L95DD_0
  RET

; Routine at 96E0
;
; Used by the routine at L96D3.
L96E0:
  CP $20
  RET C
  CP $80
  RET NC
; This entry point is used by the routine at L96D3.
L96E0_0:
  LD HL,L9656
  LD A,(HL)
  CP $10
  RET NC
  LD B,A
  LD A,C
  LD C,B
  LD B,$00
  LD DE,L9668
  EX DE,HL
  ADD HL,BC
  LD (HL),A
  EX DE,HL
  INC (HL)
; This entry point is used by the routine at L9678.
L96E0_1:
  LD HL,L9662
  CALL L8CD7
  CALL L960A
  LD A,H
  OR L
  JR NZ,L96E0_2
  LD A,(L9656)
  AND A
  JR Z,L96E0_2
  PUSH HL
  LD B,$00
  LD C,$17
  LD HL,L9657
  CALL L9808
  CALL L8D29
  POP HL
; This entry point is used by the routine at L96AB.
L96E0_2:
  LD ($BBEB),HL
  LD ($BBEF),HL
  CALL L8A15
  RET

; Routine at 9726
;
; Used by the routines at L8A15, L8BC5 and L973F.
L9726:
  CALL L850C
  LD HL,L973F
  CALL $A254
  LD A,($A3F4)
  CP $01
  RET Z
  LD A,($BF62)
  LD C,A
  LD B,$17
  CALL L89E4
  RET

; Routine at 973F
L973F:
  LD B,(HL)
  LD D,L
  LD C,H
  NOP
  LD HL,$BBE6
  LD A,(HL)
  XOR $01
  LD (HL),A
  OR A
  JR Z,L9751
  CALL L9726
  RET

; Routine at 9751
;
; Used by the routine at L973F.
L9751:
  CALL L9E02
  LD A,$01
  CALL L85A2
  RET

; Routine at 975A
;
; Used by the routine at L9E02.
L975A:
  LD HL,$4000
  LD (HL),L
  LD DE,$4001
  LD BC,$17FF
  LDIR
  INC HL
  LD (HL),A
  LD DE,$5801
  LD BC,$02FF
  LDIR
  RET

; Routine at 9771
;
; Used by the routines at L9DD4, L9E02 and L9E85.
setBorder:
  OUT ($FE),A
  RLCA
  RLCA
  RLCA
  LD (BORDCR),A
  RET

; Routine at 977A
;
; Used by the routines at L89DC, L8C7E, L8CBA, L8DE9 and L9E02.
L977A:
  LD A,B
  RRCA
  RRCA
  RRCA
  LD L,A
  AND $03
  OR $58
  LD H,A
  LD A,L
  AND $E0
  LD L,A
  LD (HL),C
  LD D,H
  LD E,L
  INC DE
  LD BC,$001F
  LDIR
  RET

; Routine at 9792
;
; Used by the routines at L8B5D and L8BC5.
L9792:
  LD A,B
  AND $07
  RRCA
  RRCA
  RRCA
  LD E,A
  LD A,B
  AND $18
  OR $40
  LD D,A
  LD A,C
  AND $07
  RRCA
  RRCA
  RRCA
  LD L,A
  LD A,C
  AND $18
  OR $40
  LD H,A
  PUSH HL
  PUSH DE
  LD A,L
  LD ($97C2),A
  LD A,E
  LD ($97C4),A
  LD A,$08
L9792_0:
  LD BC,$0020
  LDIR
  DEC HL
  DEC DE
  INC D
  INC H
  LD L,$00
  LD E,$00
  DEC A
  AND A
  JR NZ,L9792_0
  POP DE
  POP HL
  LD A,D
  RRA
  RRA
  RRA
  AND $03
  OR $58
  LD D,A
  LD A,H
  RRA
  RRA
  RRA
  AND $03
  OR $58
  LD H,A
  LD BC,$0020
  LDIR
  RET

; Routine at 97E3
;
; Used by the routines at L8968, L8B5D, L8BC5, L8C7E, L8CBA, L8CD7 and L8DE9.
L97E3:
  LD A,B
  AND $07
  RRCA
  RRCA
  RRCA
  LD L,A
  LD A,B
  AND $18
  OR $40
  LD H,A
  LD B,$08
L97E3_0:
  PUSH BC
  LD A,H
  LD (HL),$00
  LD D,H
  LD E,L
  INC E
  LD BC,$001F
  LDIR
  LD H,A
  INC H
  LD A,L
  SUB $1F
  LD L,A
  POP BC
  DJNZ L97E3_0
  RET

; Routine at 9808
;
; Used by the routines at L864C, L89E4, L8C7E, L8CD7, L96E0, LA0D4 and LA272.
L9808:
  LD A,$80
  LD IYh,A
  LD A,B
  AND $07
  RRCA
  RRCA
  RRCA
  ADD A,C
  LD IXl,A
  LD A,B
  AND $18
  OR $40
  LD IXh,A
; This entry point is used by the routine at L9867.
L9808_0:
  LD A,(HL)
  AND A
  RET Z
  SUB $20
  PUSH HL
  LD BC,L98C3
  LD H,$00
  LD L,A
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,BC
  LD DE,$9874
  LD A,(HL)
  INC HL
  LD BC,$0007
  LDIR
  LD B,$06
  AND A
  JR Z,L9808_1
  LD B,A
L9808_1:
  LD A,IYh
  LD E,IXl
; This entry point is used by the routine at L9867.
L9808_2:
  LD D,IXh
  LD C,A
  PUSH BC
  LD HL,L9873
  LD B,$08
; This entry point is used by the routine at L9851.
L9808_3:
  SLA (HL)
  LD A,(DE)
  JR NC,L9851
  OR C
  JR L9851_0

; Routine at 9851
;
; Used by the routine at L9808.
L9851:
  OR C
  XOR C
; This entry point is used by the routine at L9808.
L9851_0:
  LD (DE),A
  INC HL
  INC D
  DJNZ L9808_3
  SRL C
  JR NZ,L9867_0
  LD C,$80
  INC E
  LD A,E
  AND $1F
  JR NZ,L9867
  POP BC
  POP HL
  RET

; Routine at 9867
;
; Used by the routine at L9851.
L9867:
  INC IXl
; This entry point is used by the routine at L9851.
L9867_0:
  LD A,C
  POP BC
  DJNZ L9808_2
  LD IYh,A
  POP HL
  INC HL
  JR L9808_0

; Unused
L9873:
  DEFS $08

; Routine at 987B
;
; Used by the routine at L8741.
L987B:
  LD B,$61
  LD HL,L98C3
  LD DE,$BF00
L987B_0:
  LD A,(HL)
  AND A
  JR NZ,L987B_1
  LD A,$06
L987B_1:
  LD (DE),A
  INC DE
  LD C,D
  LD A,E
  LD DE,$0008
  ADD HL,DE
  LD D,C
  LD E,A
  DJNZ L987B_0
  LD HL,L894A
  CALL L98A8
  LD A,$FF
  SUB B
  SRL A
  SRL A
  SRL A
  LD ($8A0C),A
  RET

; Routine at 98A8
;
; Used by the routines at L92B4 and L987B.
L98A8:
  LD B,$00
  LD C,$00
  LD D,$BF
L98A8_0:
  LD A,(HL)
  AND A
  JR Z,L98BE
  SUB $20
  LD E,A
  LD A,(DE)
  ADD A,B
  JR C,L98BE
  LD B,A
  INC HL
  INC C
  JR L98A8_0

; Routine at 98BE
;
; Used by the routine at L98A8.
L98BE:
  LD L,$00
  RET C
  INC L
  RET

; Data block at 98C3
L98C3:
  DEFB $04,$00,$00,$00,$00,$00,$00,$00
  DEFB $03,$80,$80,$80,$80,$00,$80,$00
  DEFB $05,$90,$90,$00,$00,$00,$00,$00
  DEFB $00,$50,$F8,$50,$50,$F8,$50,$00
  DEFB $00,$20,$F8,$A0,$F8,$28,$F8,$20
  DEFB $00,$00,$C8,$D0,$20,$58,$98,$00
  DEFB $00

; Message at 98F4
L98F4:
  DEFM " P X"

; Data block at 98F8
L98F8:
  DEFB $90,$68,$00,$03,$40,$80,$00,$00
  DEFB $00,$00,$00,$04,$20,$40,$40,$40
  DEFB $40,$20,$00,$04,$40

; Message at 990D
L990D:
  DEFM "    "

; Data block at 9911
L9911:
  DEFB $40,$00,$00,$00,$20,$F8,$70,$F8
  DEFB $20,$00,$00,$00,$20,$20,$F8,$20
  DEFB $20,$00,$04,$00,$00,$00,$00,$20
  DEFB $20,$40,$05,$00,$00,$00,$F0,$00
  DEFB $00,$00,$04,$00,$00,$00,$00,$60
  DEFB $60,$00,$00,$00,$08,$10,$20,$40
  DEFB $80,$00,$00,$70,$88,$98,$A8,$C8
  DEFB $70,$00,$04,$40,$C0,$40,$40,$40
  DEFB $E0,$00,$00,$70,$88,$08,$70,$80
  DEFB $F8,$00,$00,$70,$88,$30,$08,$88
  DEFB $70,$00,$00,$10,$30,$50,$90,$F8
  DEFB $10,$00,$00,$F8,$80,$F0,$08,$88
  DEFB $70,$00,$00,$70,$80,$F0,$88,$88
  DEFB $70,$00,$00,$F8,$08,$10,$20,$40
  DEFB $40,$00,$00,$70,$88,$70,$88,$88
  DEFB $70,$00,$00,$70,$88,$88,$78,$08
  DEFB $70,$00,$00,$00,$00,$20,$00,$00
  DEFB $20,$00,$00,$00,$20,$00,$00,$20
  DEFB $20,$40,$00,$00,$10,$20,$40,$20
  DEFB $10,$00,$00,$00,$00,$78,$00,$78
  DEFB $00,$00,$00,$00,$40,$20,$10,$20
  DEFB $40,$00,$00,$70,$88,$10,$20,$00
  DEFB $20,$00,$00,$70,$A8,$98,$B8,$80
  DEFB $70,$00,$00,$70,$88,$88,$F8,$88
  DEFB $88,$00,$00,$F0,$88,$F0,$88,$88
  DEFB $F0,$00,$00,$70,$88,$80,$80,$88
  DEFB $70,$00,$00,$E0,$90,$88,$88,$90
  DEFB $E0,$00,$00,$F8,$80,$F0,$80,$80
  DEFB $F8,$00,$00,$F8,$80,$F0,$80,$80
  DEFB $80,$00,$00,$70,$88,$80,$98,$88
  DEFB $70,$00,$00,$88,$88,$F8,$88,$88
  DEFB $88,$00,$00,$F8

; Message at 9A0D
L9A0D:
  DEFM "    "

; Data block at 9A11
L9A11:
  DEFB $F8,$00,$00,$08,$08,$08,$88,$88
  DEFB $70,$00,$00,$90,$A0,$C0,$A0,$90
  DEFB $88,$00,$00,$80,$80,$80,$80,$80
  DEFB $F8,$00,$00,$88,$D8,$A8,$88,$88
  DEFB $88,$00,$00,$88,$C8,$A8,$98,$88
  DEFB $88,$00,$00,$70,$88,$88,$88,$88
  DEFB $70,$00,$00,$F0,$88,$88,$F0,$80
  DEFB $80,$00,$00,$70,$88,$88,$A8,$98
  DEFB $78,$00,$00,$F0,$88,$88,$F0,$88
  DEFB $88,$00,$00,$70,$80,$70,$08,$88
  DEFB $70,$00,$00,$F8

; Message at 9A65
L9A65:
  DEFM "     "

; Data block at 9A6A
L9A6A:
  DEFB $00,$00,$88,$88,$88,$88,$88,$70
  DEFB $00,$00,$88,$88,$88,$88,$50,$20
  DEFB $00,$00,$88,$88,$88,$88,$A8,$50
  DEFB $00,$00,$88

; Message at 9A85
L9A85:
  DEFM "P  P"

; Data block at 9A89
L9A89:
  DEFB $88,$00,$00,$88,$88

; Message at 9A8E
L9A8E:
  DEFM "P   "

; Data block at 9A92
L9A92:
  DEFB $00,$00,$F8,$08,$10,$20,$40,$F8
  DEFB $00,$05,$70,$40,$40,$40,$40,$70
  DEFB $00,$00,$00,$80,$40,$20,$10,$08
  DEFB $00,$05,$70,$10,$10,$10,$10,$70
  DEFB $00,$00,$20,$70,$A8

; Message at 9AB7
L9AB7:
  DEFM "   "

; Data block at 9ABA
L9ABA:
  DEFB $00,$05,$00,$00,$00,$00,$00,$00
  DEFB $F8,$00,$30,$48,$E0,$40,$40,$F8
  DEFB $00,$00,$00,$70,$08,$78,$88,$78
  DEFB $00,$00,$80,$80,$F0,$88,$88,$F0
  DEFB $00,$05,$00,$70,$80,$80,$80,$70
  DEFB $00,$00,$08,$08,$78,$88,$88,$78
  DEFB $00,$00,$00,$70,$88,$F0,$80,$78
  DEFB $00,$05,$30,$40,$F0,$40,$40,$40
  DEFB $00,$00,$00,$78,$88,$88,$78,$08
  DEFB $30,$00,$80,$80,$F0,$88,$88,$88
  DEFB $00,$04,$40,$00,$C0,$40,$40,$E0
  DEFB $00,$05,$10,$00,$10,$10,$10,$90
  DEFB $60,$05,$80,$A0,$C0,$C0,$A0,$90
  DEFB $00,$04,$80,$80,$80,$80,$80,$60
  DEFB $00,$00,$00,$D0,$A8,$A8,$A8,$A8
  DEFB $00,$00,$00,$F0,$88,$88,$88,$88
  DEFB $00,$00,$00,$70,$88,$88,$88,$70
  DEFB $00,$00,$00,$F0,$88,$88,$F0,$80
  DEFB $80,$00,$00,$70,$90,$90,$70,$10
  DEFB $18,$05,$00,$70,$80,$80,$80,$80
  DEFB $00,$00,$00,$70,$80,$70,$08,$F0
  DEFB $00,$05,$40,$E0,$40,$40,$40,$30
  DEFB $00,$00,$00,$88,$88,$88,$88,$70
  DEFB $00,$00,$00,$88,$88

; Message at 9B77
L9B77:
  DEFM "PP "

; Data block at 9B7A
L9B7A:
  DEFB $00,$00,$00,$88,$A8,$A8,$A8,$50
  DEFB $00,$00,$00,$88

; Message at 9B86
L9B86:
  DEFM "P P"

; Data block at 9B89
L9B89:
  DEFB $88,$00,$00,$00,$88,$88,$88,$78
  DEFB $08,$70,$00,$00,$F8,$10,$20,$40
  DEFB $F8,$00,$00,$38,$20,$60

; Message at 9B9F
L9B9F:
  DEFM "  8"

; Data block at 9BA2
L9BA2:
  DEFB $00,$00

; Message at 9BA4
L9BA4:
  DEFM "      "

; Data block at 9BAA
L9BAA:
  DEFB $00,$00,$70,$10,$18,$10,$10,$70
  DEFB $00,$05,$50,$A0,$00,$00,$00,$00
  DEFB $00,$00,$70,$A8,$C8,$C8,$A8,$70
  DEFB $00,$00,$00,$00,$00,$00,$A8,$A8
  DEFB $00,$06,$00,$00,$00,$00,$00,$00
  DEFB $00

; Routine at 9BD3
;
; Used by the routine at LA272.
L9BD3:
  XOR A
  IN A,($FE)
  AND $1F
  CP $1F
  RET NZ
  JR L9BD3

; Routine at 9BDD
;
; Used by the routine at L9D2B.
L9BDD:
  LD BC,$FEFE
  LD DE,$0500
  LD HL,$FFE0
  IN A,(C)
  OR $E1
  CP H
  JR NZ,L9C09
  LD E,D
  LD B,$FD
L9BDD_0:
  IN A,(C)
  OR L
  CP H
  JR NZ,L9C09
  LD A,E
  ADD A,D
  LD E,A
  RLC B
  JP M,L9BDD_0
  IN A,(C)
  OR $E2
  CP H
  LD C,A
  JR NZ,L9C09_0
  JP L9C4F

; Routine at 9C09
;
; Used by the routine at L9BDD.
L9C09:
  LD C,A
  LD A,B
  CPL
  OR $81
  IN A,($FE)
  OR L
  CP H
  JP NZ,L9C4A
  LD A,$7F
  IN A,($FE)
  OR $E2
  CP H
  JP NZ,L9C4A
; This entry point is used by the routine at L9BDD.
L9C09_0:
  LD B,$00
  LD HL,$9B75
  ADD HL,BC
  LD A,(HL)
  CP D
  JP NC,L9C4A
  ADD A,E
  LD E,A
  LD HL,$9C75
  LD D,B
  ADD HL,DE
  LD A,$FE
  IN A,($FE)
  AND $01
  JR NZ,L9C09_1
  LD E,$28
  ADD HL,DE
L9C09_1:
  LD A,$7F
  IN A,($FE)
  AND $02
  JR NZ,L9C09_2
  LD E,$50
  ADD HL,DE
L9C09_2:
  LD L,(HL)
  LD H,B
  RET

; Routine at 9C4A
;
; Used by the routine at L9C09.
L9C4A:
  LD HL,$0000
  SCF
  RET

; Routine at 9C4F
;
; Used by the routine at L9BDD.
L9C4F:
  LD HL,$0000
  SCF
  CCF
  RET

; Data block at 9C55
L9C55:
  DEFB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
  DEFB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$04
  DEFB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$03
  DEFB $FF,$FF,$FF,$02,$FF,$01,$00,$FF
  DEFB $FF

; Message at 9C76
L9C76:
  DEFM "zxcvasdfgqwert1234509876poiuy"

; Data block at 9C93
L9C93:
  DEFB $0D

; Message at 9C94
L9C94:
  DEFM "lkjh "

; Data block at 9C99
L9C99:
  DEFB $FF

; Message at 9C9A
L9C9A:
  DEFM "mnb"

; Data block at 9C9D
L9C9D:
  DEFB $FF

; Message at 9C9E
L9C9E:
  DEFM "ZXCVASDFGQWERT"

; Data block at 9CAC
L9CAC:
  DEFB $07,$06,$80,$81,$08,$0C,$08,$09
  DEFB $0B,$0A

; Message at 9CB6
L9CB6:
  DEFM "POIUY"

; Data block at 9CBB
L9CBB:
  DEFB $0D

; Message at 9CBC
L9CBC:
  DEFM "LKJH "

; Data block at 9CC1
L9CC1:
  DEFB $FF

; Message at 9CC2
L9CC2:
  DEFM "MNB"

; Data block at 9CC5
L9CC5:
  DEFB $FF,$3A,$60,$3F,$2F,$7E,$7C,$5C
  DEFB $7B,$7D,$83,$84,$85

; Message at 9CD2
L9CD2:
  DEFM "<>!"

; Data block at 9CD5
L9CD5:
  DEFB $40,$23,$24,$25,$5F

; Message at 9CDA
L9CDA:
  DEFM ")('&\";"

; Data block at 9CE0
L9CE0:
  DEFB $82,$5D,$5B

; Data block at 9CE3
L9CE3:
  DEFB $0D,$3D,$2B,$2D,$5E,$20,$FF,$2E
  DEFB $2C,$2A,$FF,$1A,$18,$03

; Data block at 9CF1
L9CF1:
  DEFB $16,$01,$13,$04,$06,$07,$11,$17
  DEFB $05,$12,$14,$1B,$1C,$1D,$1E,$1F
  DEFB $7F

; Data block at 9D02
L9D02:
  DEFB $FF,$86,$60,$87,$10,$0F,$09,$15
  DEFB $19,$0D,$0C,$0B,$0A,$08,$20,$FF
  DEFB $0D,$0E,$02,$1E,$00,$01,$FE,$FE
  DEFB $ED,$78,$1F,$38,$01,$1C,$06,$7F
  DEFB $ED,$78,$1F,$1F,$7B,$D8,$F6,$02
  DEFB $C9

; Routine at 9D2B
;
; Used by the routines at L8CF7, L8E8C, L95FD and LA272.
L9D2B:
  XOR A
  IN A,($FE)
  AND $1F
  CP $1F
  JR NZ,L9D2B
  LD A,($A416)
  AND $02
  RET Z
L9D2B_0:
  XOR A
  IN A,($1F)
  RET Z
  JR NZ,L9D2B_0
; This entry point is used by the routine at L9E26.
L9D2B_1:
  LD HL,($BF93)
  CALL $A11E
  CP $FF
  JR Z,L9D2B_2
  AND A
  JR NZ,L9D2B_3
L9D2B_2:
  CALL L9BDD
  LD A,L
  LD HL,$A418
  LD BC,$0005
  CPIR
  JR NZ,L9D2B_3
  INC C
  LD A,$05
  SUB C
  LD HL,$8EE2
  LD D,$00
  LD E,A
  ADD HL,DE
  LD A,(HL)
L9D2B_3:
  LD H,$00
  LD L,A
  CALL $9D15
  LD ($BF95),A
  LD B,A
  LD A,($BF6C)
  OR A
  JR Z,L9D81
  LD C,L
  CALL L9678
; This entry point is used by the routine at L9D94.
L9D2B_4:
  LD B,$03
  CALL LA118_0
  RET

; Routine at 9D81
;
; Used by the routine at L9D2B.
L9D81:
  LD A,L
  CP $C4
  JR Z,L9D81_0
  CP $20
  JR NZ,L9D94
  LD A,B
  AND $01
  LD A,L
  JR Z,L9D94
L9D81_0:
  CALL L8DBD_0
  RET

; Routine at 9D94
;
; Used by the routine at L9D81.
L9D94:
  CP $22
  JR Z,L9DAB
  CP $40
  JR NZ,L9D94_0
  LD A,$22
L9D94_0:
  CP $21
  JR C,L9DAB
  CP $2B
  JR NC,L9DAB
  CALL L8E21_0
  JR L9D2B_4

; Routine at 9DAB
;
; Used by the routine at L9D94.
L9DAB:
  CALL $8F28
  RET

; Routine at 9DAF
L9DAF:
  XOR A
  RET

; Routine at 9DB1
L9DB1:
  IN A,($1F)
  CP $FF
  RET Z
  LD B,$00
  LD C,A
  IN A,($1F)
  CP C
  JR Z,L9DC0
  XOR A
  RET

; Routine at 9DC0
;
; Used by the routine at L9DB1.
L9DC0:
  AND $E0
  JR Z,L9DC0_0
  LD B,$C0
L9DC0_0:
  LD A,C
  AND $1F
  LD E,A
  LD D,$00
  LD HL,L9DD3
  ADD HL,DE
  LD A,(HL)
  OR B
  RET

; Unused
L9DD3:
  DEFS $01

; Routine at 9DD4
L9DD4:
  EX AF,AF'
  INC B
  INC C
  LD (BC),A
  LD A,(BC)
  LD B,$0E
  LD BC,$0509
  DEC C
  INC BC
  DEC BC
  RLCA
  RRCA
  ADD A,B
  ADC A,B
  ADD A,H
  ADC A,H
  ADD A,D
  ADC A,D
  ADD A,(HL)
  ADC A,(HL)
  ADD A,C
  ADC A,C
  ADD A,L
  ADC A,L
  ADD A,E
  ADC A,E
  ADD A,A
  ADC A,A
; This entry point is used by the routine at L8D29.
L9DD4_0:
  CALL setBorder
  LD B,$14
  CALL LA118_0
  LD A,($A411)
  CALL setBorder
  RET

; Routine at 9E02
;
; Used by the routines at L9751, L9E39 and LA38A.
L9E02:
  LD A,(LA412)
  CALL L975A
  LD A,($A411)
  CALL setBorder
  LD A,($A40F)
  LD C,A
  LD B,$00
  CALL L977A
  LD A,($A410)
  LD C,A
  LD B,$17
  CALL L977A
  LD L,$0F
  CALL LA017
  RET

; Routine at 9E26
;
; Used by the routine at L84D0.
L9E26:
  CALL L9D2B_1
  LD A,($BBE3)
  AND A
  JR Z,L9E26
  CALL L94B2
  CALL LA21E
  CALL LA1C9
  RET

; Routine at 9E39
;
; Used by the routine at L84D0.
L9E39:
  OR A
  JR Z,L9E39_0
  LD HL,$3200
  LD DE,$C000
  LD BC,$0200
  LDIR
  LD A,$8A
  OUT ($E3),A
  LD HL,$C000
  LD DE,$3E00
  LD BC,$0200
  LDIR
  LD A,$80
  OUT ($E3),A
L9E39_0:
  CALL LA17D
  CALL LA22A
  CALL L8741_0
  LD HL,L9DAF
  LD A,($A416)
  AND $02
  JR Z,L9E39_1
  LD HL,L9DB1
L9E39_1:
  LD ($BF93),HL
  CALL L9E02
  CALL L9EA5
  XOR A
  LD ($A41D),A
  CALL L8FBB
  OR A
  JR Z,L9E85
  JR L9E85_1

; Routine at 9E85
;
; Used by the routine at L9E39.
L9E85:
  CALL L8763
  CALL L9467
  OR A
  LD A,$0B
  JR NZ,L9E85_0
  OR $04
L9E85_0:
  CALL L85A2
  LD A,($A41D)
  OR A
  JR Z,L9EA3
  LD A,$03
; This entry point is used by the routine at L9E39.
L9E85_1:
  LD B,A
  CALL setBorder
  LD A,B
  RET

; Routine at 9EA3
;
; Used by the routine at L9E85.
L9EA3:
  XOR A
  RET

; Routine at 9EA5
;
; Used by the routine at L9E39.
L9EA5:
  RST $08
  DEFB $88
  LD ($BF64),HL
  RET

; Routine at 9EAB
;
; Used by the routine at L9EC5.
L9EAB:
  PUSH HL
  EXX
  POP DE
  LD B,H
  LD C,L
  LD A,$10
  LD HL,$0000
L9EAB_0:
  ADD HL,HL
  RL E
  RL D
  JR NC,L9EAB_1
  ADD HL,BC
  JR NC,L9EAB_1
  INC DE
L9EAB_1:
  DEC A
  JR NZ,L9EAB_0
  OR A
  RET

; Routine at 9EC5
;
; Used by the routines at L902C, L9097 and L914D.
L9EC5:
  LD A,E
  OR D
  EXX
  OR E
  OR D
  JR Z,L9EAB
  XOR A
  PUSH HL
  EXX
  LD C,L
  LD B,H
  POP HL
  PUSH DE
  EX DE,HL
  LD L,A
  LD H,A
  EXX
  POP BC
  LD L,A
  LD H,A
  LD A,B
  LD B,$20
L9EC5_0:
  RRA
  RR C
  EXX
  RR B
  RR C
  JR NC,L9EC5_1
  ADD HL,DE
  EXX
  ADC HL,DE
  EXX
L9EC5_1:
  SLA E
  RL D
  EXX
  RL E
  RL D
  DJNZ L9EC5_0
  PUSH HL
  EXX
  POP DE
  OR A
  RET

; Routine at 9EFC
;
; Used by the routines at L902C and L90DB.
L9EFC:
  DEC BC
  LD A,B
  CPL
  LD B,A
  LD A,C
  CPL
  LD C,A
  ADD A,L
  LD A,B
  ADC A,H
  JR NC,L9F18
  PUSH DE
  EX DE,HL
  LD HL,$0000
  CALL L9F1F
  EX DE,HL
  EX (SP),HL
  EX DE,HL
  CALL L9F93
  POP BC
  RET

; Routine at 9F18
;
; Used by the routine at L9EFC.
L9F18:
  CALL L9F93
  LD BC,$0000
  RET

; Routine at 9F1F
;
; Used by the routine at L9EFC.
L9F1F:
  CALL L9F1F_0
L9F1F_0:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F1F_1
  ADD HL,BC
  INC DE
L9F1F_1:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F1F_2
  ADD HL,BC
  INC DE
L9F1F_2:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F1F_3
  ADD HL,BC
  INC DE
L9F1F_3:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F1F_4
  ADD HL,BC
  INC DE
L9F1F_4:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F1F_5
  ADD HL,BC
  INC DE
L9F1F_5:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F1F_6
  ADD HL,BC
  INC DE
L9F1F_6:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F1F_7
  ADD HL,BC
  INC DE
L9F1F_7:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F1F_8
  ADD HL,BC
  INC DE
L9F1F_8:
  RET

; Routine at 9F93
;
; Used by the routines at L9EFC and L9F18.
L9F93:
  CALL L9F93_0
L9F93_0:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F93_1
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F93_2
L9F93_1:
  ADD HL,BC
  INC DE
L9F93_2:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F93_3
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F93_4
L9F93_3:
  ADD HL,BC
  INC DE
L9F93_4:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F93_5
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F93_6
L9F93_5:
  ADD HL,BC
  INC DE
L9F93_6:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F93_7
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F93_8
L9F93_7:
  ADD HL,BC
  INC DE
L9F93_8:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F93_9
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F93_10
L9F93_9:
  ADD HL,BC
  INC DE
L9F93_10:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F93_11
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F93_12
L9F93_11:
  ADD HL,BC
  INC DE
L9F93_12:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F93_13
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F93_14
L9F93_13:
  ADD HL,BC
  INC DE
L9F93_14:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F93_15
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F93_16
L9F93_15:
  ADD HL,BC
  INC DE
L9F93_16:
  RET

; Routine at A017
;
; Used by the routines at L8A98, L8C53, L8D73 and L9E02.
LA017:
  LD A,L
  LD IXl,A
  AND $08
  JR Z,LA017_1
  LD A,($BBE5)
  AND A
  LD A,$20
  JR NZ,LA017_0
  XOR A
LA017_0:
  LD ($A10C),A
  LD HL,LA0FF
  LD C,$00
  CALL LA0D4
LA017_1:
  LD A,IXl
  AND $04
  JR Z,LA055
  LD DE,LA0F6
  LD HL,($BBEF)
  INC HL
  CALL LA0DA
  LD DE,$A0FA
  LD HL,($BBE9)
  CALL LA0DA
  LD HL,LA0F6
  LD C,$0F
  CALL LA0D4
  JR LA055_0

; Routine at A055
;
; Used by the routine at LA017.
LA055:
  LD A,IXl
  AND $02
  JR Z,LA055_3
; This entry point is used by the routine at LA017.
LA055_0:
  LD B,$04
  LD C,$01
  LD HL,LA0F1
  LD E,$30
LA055_1:
  LD D,$2D
  LD A,($BBE2)
  AND C
  JR Z,LA055_2
  LD D,E
LA055_2:
  LD (HL),D
  INC HL
  SLA C
  INC E
  DJNZ LA055_1
  LD HL,LA0F1
  LD C,$15
  CALL LA0D4
LA055_3:
  LD A,($A416)
  AND $40
  RET Z
  LD B,$05
  LD DE,$50FA
LA055_4:
  PUSH BC
  LD HL,$A111
  LD B,$08
  LD C,D
LA055_5:
  LD A,(HL)
  LD (DE),A
  INC HL
  INC D
  DJNZ LA055_5
  INC E
  LD D,C
  POP BC
  DJNZ LA055_4
  LD A,($A410)
  AND $F8
  LD C,A
  AND $40
  JR Z,LA055_7
  LD B,$03
  LD HL,$A11A
LA055_6:
  LD A,(HL)
  OR $40
  LD (HL),A
  INC HL
  DJNZ LA055_6
  LD A,C
LA055_7:
  LD HL,$A119
  LD A,(HL)
  OR C
  LD (HL),A
  LD A,C
  AND $38
  RRA
  RRA
  RRA
  LD D,A
  LD A,C
  AND $C0
  OR D
  LD C,A
  LD HL,$A11D
  LD A,(HL)
  OR C
  LD (HL),A
  LD HL,$A119
  LD DE,$5AFA
  LD BC,$0005
  LDIR
  RET

; Routine at A0D4
;
; Used by the routines at LA017 and LA055.
LA0D4:
  LD B,$17
  CALL L9808
  RET

; Routine at A0DA
;
; Used by the routine at LA017.
LA0DA:
  LD BC,$FF9C
  CALL LA0DA_0
  LD C,$F6
  CALL LA0DA_0
  LD C,B
LA0DA_0:
  LD A,$2F
LA0DA_1:
  INC A
  ADD HL,BC
  JR C,LA0DA_1
  SBC HL,BC
  LD (DE),A
  INC DE
  RET

; Message at A0F1
LA0F1:
  DEFM "    "

; Data block at A0F5
LA0F5:
  DEFB $00

; Message at A0F6
LA0F6:
  DEFM "000/000"

; Data block at A0FD
LA0FD:
  DEFB $81,$00

; Message at A0FF
LA0FF:
  DEFM ".browse v1.01 NMI"

; Data block at A110
LA110:
  DEFB $00,$01,$03,$07,$0F,$1F,$3F,$7F

; Data block at A118
LA118:
  DEFB $FF,$02,$16,$34,$25,$28,$E9,$45
LA118_0:
  DEFB $FB,$76,$10,$FD,$F3,$C9

; Routine at A126
;
; Used by the routines at L954F and LA272.
LA126:
  LD B,L
LA126_0:
  XOR A
  IN A,($FE)
  AND $1F
  CP $1F
  JR NZ,LA126_0
  EI
LA126_1:
  HALT
  XOR A
  IN A,($FE)
  CPL
  AND $1F
  JR NZ,LA126_2
  DJNZ LA126_1
LA126_2:
  DI
  RET

; Routine at A13E
;
; Used by the routines at L858B and L8792.
LA13E:
  LD A,(DE)
  OR A
  JR Z,LA145
  INC DE
  JR LA13E

; Routine at A145
;
; Used by the routine at LA13E.
LA145:
  LD C,$00
LA145_0:
  LD A,(HL)
  LD (DE),A
  AND A
  RET Z
  INC C
  INC HL
  INC DE
  JR LA145_0

; Routine at A150
LA150:
  RET

; Routine at A151
;
; Used by the routine at L8829.
LA151:
  LD A,(HL)
  OR A
  JR Z,LA17B
; This entry point is used by the routine at LA163.
LA151_0:
  LD A,(DE)
  CP (HL)
  JR Z,LA163
  INC DE
  OR A
  JR NZ,LA151_0
; This entry point is used by the routine at LA163.
LA151_1:
  EX DE,HL
  LD HL,$0000
  SCF
  RET

; Routine at A163
;
; Used by the routine at LA151.
LA163:
  PUSH DE
  PUSH HL
  EX DE,HL
LA163_0:
  INC DE
  INC HL
  LD A,(DE)
  OR A
  JR Z,LA178
  CP (HL)
  JR Z,LA163_0
  LD A,(HL)
  POP HL
  POP DE
  INC DE
  OR A
  JR NZ,LA151_0
  JR LA151_1

; Routine at A178
;
; Used by the routine at LA163.
LA178:
  POP DE
  POP HL
  RET

; Routine at A17B
;
; Used by the routine at LA151.
LA17B:
  EX DE,HL
  RET

; Routine at A17D
;
; Used by the routine at L9E39.
LA17D:
  XOR A
  LD (LA20F),A
  LD ($A210),A
  LD BC,$FC3B
  LD A,$FF
  OUT (C),A
  LD L,$00
LA17D_0:
  LD BC,$FD3B
  IN A,(C)
  AND A
  JR Z,LA1A0
  CP $20
  JR C,LA1A0
  CP $80
  JR NC,LA1A0
  INC L
  JR LA17D_0

; Routine at A1A0
;
; Used by the routine at LA17D.
LA1A0:
  LD A,L
  CP $02
  RET C
  LD A,$01
  LD (LA20F),A
  LD BC,$FC3B
  LD A,$40
  OUT (C),A
  XOR A
  LD BC,$FD3B
  IN A,(C)
  LD ($A210),A
  AND A
  RET Z
  LD BC,$FC3B
  LD A,$40
  OUT (C),A
  XOR A
  LD BC,$FD3B
  OUT (C),A
  RET

; Routine at A1C9
;
; Used by the routine at L9E26.
LA1C9:
  LD A,(LA20F)
  AND A
  RET Z
  LD A,($A210)
  AND A
  RET Z
  LD D,A
  LD BC,$FC3B
  LD A,$40
  OUT (C),A
  LD A,D
  LD BC,$FD3B
  OUT (C),A
  RET

; Routine at A1E2
;
; Used by the routines at L85A2, L864C, L868B and L871C.
LA1E2:
  LD A,(LA20F)
  AND A
  RET Z
  LD BC,$FC3B
  LD A,L
  AND A
  JR NZ,LA1FB
  LD A,$0B
  OUT (C),A
  LD A,($A211)
  LD BC,$FD3B
  OUT (C),A
  RET

; Routine at A1FB
;
; Used by the routine at LA1E2.
LA1FB:
  LD A,$0B
  OUT (C),A
  LD BC,$FD3B
  IN A,(C)
  LD ($A211),A
  OR $C0
  LD BC,$FD3B
  OUT (C),A
  RET

; Unused
LA20F:
  DEFS $03

; Routine at A212
;
; Used by the routines at LA21E and LA22A.
LA212:
  LD BC,$BF3B
  OUT (C),D
  NOP
  LD BC,$FF3B
  OUT (C),E
  RET

; Routine at A21E
;
; Used by the routine at L9E26.
LA21E:
  LD A,(LA244)
  AND A
  RET Z
  LD DE,$4001
  CALL LA212
  RET

; Routine at A22A
;
; Used by the routine at L9E39.
LA22A:
  LD BC,$BF3B
  LD A,$40
  OUT (C),A
  NOP
  LD BC,$FF3B
  IN A,(C)
  LD (LA244),A
  AND A
  RET Z
  LD DE,$4000
  CALL LA212
  RET

; Routine at A243
LA243:
  RET

; Data block at A244
LA244:
  DEFB $00

; Message at A245
LA245:
  DEFM "Err"

; Routine at A248
LA248:
  LD L,A
  LD (HL),D
  LD HL,$5000
  LD L,H
  LD (HL),L
  LD H,A
  LD L,C
  LD L,(HL)
  LD A,($3E00)
  LD E,A
  LD DE,$A3AB
  LD (DE),A
  INC DE
  LD BC,$0003
  LDIR
  LD HL,LA39D
  CALL LA272
  RET

; Routine at A267
;
; Used by the routine at L885C.
LA267:
  LD DE,$50F8
  LD B,$08
  XOR A
LA267_0:
  LD (DE),A
  INC D
  DJNZ LA267_0
  RET

; Routine at A272
;
; Used by the routines at L8792 and LA248.
LA272:
  LD A,($5B5C)
  AND A
  JR NZ,LA272_0
  LD A,$10
LA272_0:
  LD ($A3F8),A
  LD A,($BBE5)
  LD ($A3F9),A
  AND A
  LD A,$02
  JR Z,LA272_1
  PUSH HL
  LD HL,($BBF1)
  LD BC,$001E
  ADD HL,BC
  LD A,(HL)
  LD ($A3F8),A
  POP HL
  XOR A
LA272_1:
  LD ($A2AD),A
  LD ($A31B),A
  PUSH HL
  LD A,$8C
  OUT ($E3),A
  LD HL,$8000
  LD DE,$2000
  LD BC,$2000
  LDIR
  LD A,$00
  ADD A,$80
  OUT ($E3),A
  POP HL
  LD DE,$8000
  LD BC,$0000
  CALL L941E
  XOR A
  OR L
  JR Z,LA272_4
  LD A,($8006)
  LD E,A
  AND $01
  JR Z,LA272_2
  LD HL,$A40F
  LD DE,$8008
  LD BC,$000E
  LDIR
LA272_2:
  LD HL,LA3B0
  LD DE,$A3FF
  LD BC,$0000
  CALL L941E
  LD DE,$A3FF
  LD A,H
  OR L
  JR NZ,LA272_3
  LD DE,$0000
LA272_3:
  LD HL,$BBF3
  LD BC,$A3F8
  CALL $8000
LA272_4:
  LD ($A3F4),A
  LD ($A3F5),BC
  AND $D0
  JR Z,LA272_5
  LD A,B
  OR C
  JR Z,LA272_5
  LD H,B
  LD L,C
  LD DE,$A3CA
  LD BC,$002A
  LDIR
LA272_5:
  LD A,$8C
  OUT ($E3),A
  LD HL,$2000
  LD DE,$8000
  LD BC,$2000
  LDIR
  LD A,$00
  ADD A,$80
  OUT ($E3),A
  LD A,($A3F4)
  AND $80
  JR Z,LA272_6
  LD HL,LA245
  CALL L8C7E
  LD HL,$A3CA
  LD B,$16
  LD C,$00
  CALL L9808
  CALL L9D2B
  CALL L9BD3
  CALL L9D2B
  CALL LA384
LA272_6:
  LD A,($A3F4)
  AND $10
  JR Z,LA272_7
  LD HL,$A24C
  CALL L8C7E
  LD HL,$A3CA
  LD B,$16
  LD C,$00
  CALL L9808
  LD L,$60
  CALL LA126
  CALL LA384
LA272_7:
  LD A,($A3F4)
  AND $04
  JR Z,LA272_8
  CALL LA397
LA272_8:
  LD A,($A3F4)
  AND $02
  JR Z,LA272_9
  LD A,($A3F4)
  AND $08
  JR NZ,LA272_9
  LD A,($A3F7)
  AND A
  JR NZ,LA272_9
  CALL LA38A
LA272_9:
  RET

; Routine at A384
;
; Used by the routine at LA272.
LA384:
  LD L,$00
  CALL L8CA4
  RET

; Routine at A38A
;
; Used by the routines at L8882 and LA272.
LA38A:
  CALL L9E02
  LD A,$09
  CALL L85A2
  XOR A
  LD ($A3F7),A
  RET

; Routine at A397
;
; Used by the routine at LA272.
LA397:
  LD A,$0A
  CALL L85A2
  RET

; Message at A39D
LA39D:
  DEFM "/bin/bplugins/????"

; Data block at A3AF
LA3AF:
  DEFB $00

; Message at A3B0
LA3B0:
  DEFM "/bin/bplugins/cfg/"

; Data block at A3C2
LA3C2:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$78,$47,$07

; Message at A412
LA412:
  DEFM "89h"

; Data block at A415
LA415:
  DEFB $01,$40,$00,$0B,$0A,$08,$09,$0D
  DEFB $00

