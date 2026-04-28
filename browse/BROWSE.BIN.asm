  ORG $84D0

; Routine at 84D0
L84D0:
  LD (L84E9),SP
  LD A,($BBE5)
  OR A
  JR Z,L84D0_0
  LD SP,$7FFF
L84D0_0:
  PUSH IY
  CALL L9DDB
  OR A
  CALL Z,L9DC8
  POP IY

; Data block at 84E8
L84E8:
  DEFB $31

; Data block at 84E9
L84E9:
  DEFB $00,$00

; Routine at 84EB
L84EB:
  RET

; Routine at 84EC
;
; Used by the routines at L84FF, L89FE, L8B3A, L8BA2, L8C30, L8CD3, L9445 and
; L95B7.
L84EC:
  LD A,H
  OR L
  JR Z,L84EC_0
  ADD HL,HL
  LD B,H
  LD C,L
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,BC
L84EC_0:
  LD BC,$C200
  ADD HL,BC
  LD ($BF62),HL
  RET

; Routine at 84FF
;
; Used by the routines at L8808, L8830, L8DB5, L8DED, L8E1F, L8E63, L8E78 and
; L96D2.
L84FF:
  LD HL,($BBEF)
  CALL L84EC
  INC HL
  CALL L8526
  RET

; Routine at 850A
;
; Used by the routines at L8964, L89C3 and L95B7.
L850A:
  LD D,H
  LD E,L
  LD BC,$000C
  ADD HL,BC
  LD C,(HL)
  INC HL
  LD B,(HL)
  LD A,B
  OR C
  JR Z,L851D
  LD HL,$E000
  ADD HL,BC
  AND A
  RET

; Routine at 851D
;
; Used by the routine at L850A.
L851D:
  EX DE,HL
  INC HL
  SCF
  RET

; Routine at 8521
L8521:
  LD DE,$E000
  ADD HL,DE
  RET

; Routine at 8526
;
; Used by the routines at L84FF, L8680 and L89C3.
L8526:
  LD DE,$BBF3
  LD C,$00
; This entry point is used by the routine at L853F.
L8526_0:
  LD A,C
  CP $0B
  JR NC,L8549
  LD A,(HL)
  AND A
  JR Z,L8549
  CP $21
  JR C,L853F_1
  LD B,A
  LD A,C
  CP $08
  JR NZ,L853F_0

; Data block at 853E
L853E:
  DEFB $3E

; Routine at 853F
L853F:
  LD L,$12
  INC DE
; This entry point is used by the routine at L8526.
L853F_0:
  LD A,B
  LD (DE),A
  INC DE
; This entry point is used by the routine at L8526.
L853F_1:
  INC HL
  INC C
  JR L8526_0

; Routine at 8549
;
; Used by the routine at L8526.
L8549:
  XOR A
  LD (DE),A
  RET

; Routine at 854C
;
; Used by the routines at L8CD3 and L8E1F.
L854C:
  LD A,(LA3D1)
  AND $04
  RET Z
  LD HL,$BC00
  LD BC,$0000
L854C_0:
  LD A,(HL)
  AND A
  JR Z,L8560
  INC HL
  INC C
  JR L854C_0

; Routine at 8560
;
; Used by the routine at L854C.
L8560:
  XOR A
  LD ($BF6D),A
  LD ($BF70),A
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
L8560_0:
  LD A,(HL)
  CP $2F
  JR Z,L857E
  DEC HL
  DJNZ L8560_0
  RET

; Routine at 857E
;
; Used by the routine at L8560.
L857E:
  INC HL
  LD DE,$BF70
  CALL LA0E0
  LD A,C
  LD ($BF6D),A
  RET

; Message at 858A
L858A:
  DEFM "Working..."

; Data block at 8594
L8594:
  DEFB $00

; Routine at 8595
;
; Used by the routines at L8754, L8C80, L8CC1, L94DB, L96FD, L9E26, LA344 and
; LA351.
L8595:
  LD E,A
  LD L,$01
  CALL LA184
  LD A,E
  AND $04
  JR Z,L8595_0
  LD HL,$0000
  LD ($BBEB),HL
  LD ($BBED),HL
  LD ($BBEF),HL
L8595_0:
  PUSH DE
  CALL L94AC
  POP DE
  LD A,L
  AND A
  JR Z,L85BC
  LD A,E
  OR $10
  LD E,A
  PUSH DE
  JR L85BC_2

; Routine at 85BC
;
; Used by the routine at L8595.
L85BC:
  PUSH DE
  LD A,E
  AND $02
  JR Z,L85BC_2
  LD A,E
  AND $08
  JR NZ,L85BC_0
  LD HL,L858A
  CALL L8CB3
L85BC_0:
  CALL L9105
  LD DE,($BBE9)
  LD BC,$C200
  LD HL,($BF66)
  LD A,H
  OR L
  LD HL,($BF68)
  OR H
  OR L
  AND A
  JR Z,L85BC_1
  DEC DE
  LD HL,$0012
  ADD HL,BC
  LD B,H
  LD C,L
L85BC_1:
  EX DE,HL
  LD DE,$0012
  LD IX,L8964
  CALL L8877
; This entry point is used by the routine at L8595.
L85BC_2:
  LD A,$2A
  LD HL,$BC00
  RST $08
  DEFB $A8
  POP DE
  LD A,E
  LD (L8667),A
  AND $01
  JR Z,L8668_1
  LD A,E
  AND $08
  JR NZ,L8642_0
  LD A,($BF6D)
  AND A
  JR Z,L8642_0
  LD BC,($BBE9)
  LD HL,$C200
; This entry point is used by the routine at L8642.
L85BC_3:
  PUSH BC
  LD A,(HL)
  AND $01
  JR Z,L8642
  LD DE,$BF70
  LD A,($BF6D)
  LD B,A
  LD (L8640),HL
  INC HL
L85BC_4:
  LD A,(HL)
  LD C,A
  LD A,(DE)
  CP C
  JR NZ,L863F
  INC HL
  INC DE
  DJNZ L85BC_4
  POP BC
  LD HL,($BBE9)
  OR A
  SBC HL,BC
  LD ($BBEF),HL
  JR L8642_0

; Data block at 863F
;
; Used by the routine at L85BC.
L863F:
  DEFB $21

; Data block at 8640
L8640:
  DEFB $00,$00

; Routine at 8642
;
; Used by the routine at L85BC.
L8642:
  LD BC,$0012
  ADD HL,BC
  POP BC
  DEC BC
  LD A,B
  OR C
  JR NZ,L85BC_3
; This entry point is used by the routine at L85BC.
L8642_0:
  LD HL,($BBEF)
  LD A,H
  OR L
  AND A
  JR Z,L8642_1
  CALL L892D_0
  AND A
  JR NZ,L8642_1
  LD HL,($BBEF)
  LD ($BBEB),HL
L8642_1:
  LD HL,$BC00
  CALL L8CB3

; Data block at 8666
L8666:
  DEFB $3E

; Data block at 8667
L8667:
  DEFB $00

; Routine at 8668
L8668:
  AND $10
  JR Z,L8668_0
  LD BC,$001F
  LD HL,L867E
  CALL L97B4
L8668_0:
  CALL L89F4
; This entry point is used by the routine at L85BC.
L8668_1:
  XOR A
  LD L,A
  CALL LA184
  RET

; Data block at 867E
L867E:
  DEFB $2A,$00

; Routine at 8680
;
; Used by the routine at L8754.
L8680:
  INC HL
  LD ($BFAA),HL
  EX DE,HL
  LD A,$01
  LD ($BF89),A
  LD L,A
  CALL LA184
; This entry point is used by the routine at L8702.
L8680_0:
  LD A,(DE)
  AND A
  JP Z,L870F
  CP $2F
  JR NZ,L8702_0
  XOR A
  LD (DE),A
  LD BC,($BBE9)
  LD HL,$C200
; This entry point is used by the routine at L86F4.
L8680_1:
  PUSH BC
  LD A,(HL)
  AND $01
  JR Z,L86F4_0
  PUSH HL
  LD (L8700),DE
  INC HL
  CALL L8526
  LD DE,($BFAA)
  LD HL,$BBF3
L8680_2:
  LD A,(HL)
  CP $41
  JR C,L8680_3
  CP $5B
  JR NC,L8680_3
  OR $20
L8680_3:
  LD C,A
  LD A,(DE)
  CP $41
  JR C,L8680_4
  CP $5B
  JR NC,L8680_4
  OR $20
L8680_4:
  CP C
  JR NZ,L86F4
  INC DE
  INC HL
  OR A
  JR NZ,L8680_2
  LD A,(DE)
  DEC DE
  LD (L8700),DE
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
  JR Z,L86FF
  CALL L9105
  JR L86FF

; Routine at 86F4
;
; Used by the routine at L8680.
L86F4:
  POP HL
; This entry point is used by the routine at L8680.
L86F4_0:
  LD BC,$0012
  ADD HL,BC
  POP BC
  DEC BC
  LD A,B
  OR C
  JR NZ,L8680_1

; Data block at 86FF
;
; Used by the routine at L8680.
L86FF:
  DEFB $11

; Data block at 8700
L8700:
  DEFB $00,$00

; Routine at 8702
L8702:
  LD A,$2F
  LD (DE),A
  LD H,D
  LD L,E
  INC HL
  LD ($BFAA),HL
; This entry point is used by the routine at L8680.
L8702_0:
  INC DE
  JP L8680_0

; Routine at 870F
;
; Used by the routine at L8680.
L870F:
  XOR A
  LD ($BF89),A
  LD L,A
  CALL LA184
  RET

; Message at 8718
L8718:
  DEFM "/bin/browse"

; Message at 8723
L8723:
  DEFM ".cfg"

; Data block at 8727
L8727:
  DEFB $00

; Message at 8728
L8728:
  DEFM "/bin/brows"

; Routine at 8732
L8732:
  LD H,L
  LD L,$66
  LD L,(HL)
  LD (HL),H
  NOP
; This entry point is used by the routine at L9DDB.
L8732_0:
  LD HL,L8718
  LD BC,$0000
  LD DE,LA3CA
  CALL L93CB
  LD HL,L8728
  LD BC,$0308
  LD DE,L9867
  CALL L93CB
  CALL L981F
  RET

; Routine at 8754
;
; Used by the routines at L8DED and L9E26.
L8754:
  LD HL,$0000
  LD ($BF66),HL
  LD ($BF68),HL
  LD A,$02
  CALL L8595
  LD HL,$BC00
  CALL L8680
  RET

; Routine at 8769
;
; Used by the routines at L8DED and L8E46.
L8769:
  LD HL,$BBF3
  LD DE,$0000
L8769_0:
  LD A,(HL)
  OR A
  JR Z,L877C
  CP $2E
  JR NZ,L8769_1
  LD D,H
  LD E,L
L8769_1:
  INC HL
  JR L8769_0

; Routine at 877C
;
; Used by the routine at L8769.
L877C:
  LD A,D
  OR E
  RET Z
  EX DE,HL
  LD DE,$BF7D
  LD BC,$0004
  PUSH HL
  LDIR
  POP HL
  XOR A
  LD (LA365),A
  LD (LA37C),A
  LD DE,LA357
  INC HL
  PUSH HL
  CALL LA0E0
  POP HL
  CALL LA20E
  LD HL,$0000
  LD ($BF82),HL
; This entry point is used by the routines at L8808 and L8830.
L877C_0:
  LD HL,LA357
  CALL LA22A
  LD A,(LA3AF)
  LD B,A
  AND $08
  JP Z,L883B
  LD A,B
  AND $02
  JR Z,L877C_1
  LD A,$01
  LD (LA3B2),A
; This entry point is used by the routine at L8808.
L877C_1:
  LD A,(LA3B0)
  CP $03
  JR NZ,L87D0
  LD HL,$0000
  LD ($BBEF),HL
  LD A,$01
  LD (LA3B0),A
  JR L87D0_0

; Routine at 87D0
;
; Used by the routine at L877C.
L87D0:
  CP $04
  JR NZ,L87D0_0
  LD HL,($BBE9)
  LD ($BBEF),HL
  LD A,$02
  LD (LA3B0),A
; This entry point is used by the routine at L877C.
L87D0_0:
  CP $01
  JR NZ,L87FB
  LD HL,($BBEF)
  LD D,H
  LD E,L
  INC HL
  LD ($BBEF),HL
  LD BC,($BBE9)
  OR A
  SBC HL,BC
  JR NZ,L8808
  EX DE,HL
  LD ($BBEF),HL
  JR L883B

; Routine at 87FB
;
; Used by the routine at L87D0.
L87FB:
  LD HL,($BBEF)
  DEC HL
  LD ($BBEF),HL
  LD A,H
  OR L
  JR NZ,L8808
  JR L883B

; Routine at 8808
;
; Used by the routines at L87D0 and L87FB.
L8808:
  CALL L84FF
  LD DE,$BBF3
  LD HL,$BF7D
  CALL LA0F3
  JR C,L877C_1
  LD A,(LA3B2)
  OR A
  JR NZ,L877C_0
  LD HL,($BBEF)
  CALL L892D_0
  AND A
  JR NZ,L8830
  LD HL,($BBEF)
  LD ($BBEB),HL
  CALL L89F4
  JR L8830_0

; Routine at 8830
;
; Used by the routine at L8808.
L8830:
  LD A,$80
  CALL L8A94_0
; This entry point is used by the routine at L8808.
L8830_0:
  CALL L84FF
  JP L877C_0

; Routine at 883B
;
; Used by the routines at L877C, L87D0 and L87FB.
L883B:
  CALL LA21F
  LD HL,($BF82)
  LD A,H
  OR L
  JR Z,L8861_2
  PUSH HL
  CALL L892D_0
  POP HL
  AND A
  JR NZ,L8861_1
  EX DE,HL
  LD HL,$BBE9
  LD BC,$0016
  OR A
  SBC HL,BC
  EX DE,HL
  JR C,L8861
  LD DE,$0015
  SBC HL,DE
  JR L8861_0

; Routine at 8861
;
; Used by the routine at L883B.
L8861:
  LD DE,$0000
  LD ($BBEB),DE
; This entry point is used by the routine at L883B.
L8861_0:
  LD ($BBED),HL
; This entry point is used by the routine at L883B.
L8861_1:
  LD ($BBEF),HL
; This entry point is used by the routine at L883B.
L8861_2:
  LD A,(LA3B2)
  OR A
  RET Z
  CALL LA344
  RET

; Routine at 8877
;
; Used by the routine at L85BC.
L8877:
  LD (L88DA),IX
  EX DE,HL
  PUSH DE
  PUSH HL
  LD (L8905),BC
  CALL L8909
  LD (L88FF),HL
; This entry point is used by the routine at L88AC.
L8877_0:
  POP DE
  POP HL
  SRL H
  RR L
  LD A,H
  OR L
  RET Z
  PUSH HL
  PUSH DE
  CALL L8909
  LD (L8907),HL
  POP DE
  PUSH DE
  PUSH HL
  ADD HL,DE
  LD (L8901),HL
  LD DE,(L8905)
  EX (SP),HL
  ADD HL,DE
  LD (L8903),HL
  POP HL
  JR L88AC_0

; Routine at 88AC
;
; Used by the routine at L88DC.
L88AC:
  LD DE,(L88FB)
  POP HL
  PUSH HL
  ADD HL,DE
; This entry point is used by the routine at L8877.
L88AC_0:
  LD (L88FB),HL
  EX DE,HL
  LD HL,(L88FF)
  SBC HL,DE
  JR C,L8877_0
  LD HL,(L8901)
  EX DE,HL
; This entry point is used by the routine at L88DC.
L88AC_1:
  AND A
  SBC HL,DE
  LD (L88FD),HL
  JP M,L88AC
  LD C,L
  LD B,H
  LD HL,(L8903)
  ADD HL,BC
  EX DE,HL
  LD HL,(L8905)
  ADD HL,BC
  PUSH HL
  PUSH BC
  PUSH DE

; Data block at 88D9
L88D9:
  DEFB $CD

; Data block at 88DA
L88DA:
  DEFB $00,$00

; Routine at 88DC
L88DC:
  LD A,H
  OR A
  LD A,L
  POP DE
  POP BC
  POP HL
  JP P,L88AC
  POP BC
  PUSH BC
  PUSH HL
L88DC_0:
  LD A,(DE)
  LDI
  DEC HL
  LD (HL),A
  INC HL
  JP PE,L88DC_0
  POP HL
  LD HL,(L88FD)
  LD DE,(L8907)
  JR L88AC_1

; Unused
L88FB:
  DEFS $02

; Data block at 88FD
L88FD:
  DEFB $00,$00

; Data block at 88FF
L88FF:
  DEFB $00,$00

; Data block at 8901
L8901:
  DEFB $00,$00

; Data block at 8903
L8903:
  DEFB $00,$00

; Data block at 8905
L8905:
  DEFB $00,$00

; Data block at 8907
L8907:
  DEFB $00,$00

; Routine at 8909
;
; Used by the routine at L8877.
L8909:
  INC H
  DEC H
  JR Z,L8917_0
  INC D
  DEC D
  JR Z,L8917
  LD C,L
  LD A,H
  LD B,$10
  JR L8917_1

; Routine at 8917
;
; Used by the routine at L8909.
L8917:
  EX DE,HL
; This entry point is used by the routine at L8909.
L8917_0:
  LD A,L
  LD B,$08
; This entry point is used by the routine at L8909.
L8917_1:
  LD HL,$0000
L8917_2:
  ADD HL,HL
  RL C
  RLA
  JR NC,L8917_3
  ADD HL,DE
L8917_3:
  DJNZ L8917_2
  OR A
  RET

; Message at 8929
L8929:
  DEFM "<DIR"

; Routine at 892D
L892D:
  LD A,$00
; This entry point is used by the routines at L8642, L8808, L883B, L8AA5,
; L8AC8, L8B0D, L8B3A and L8BA2.
L892D_0:
  EX DE,HL
  OR A
  LD HL,($BBEB)
  SBC HL,DE
  JR Z,L892D_1
  JR NC,L8945
  OR A
  LD HL,($BBED)
  SBC HL,DE
  JR C,L8945
L892D_1:
  LD A,$01
  RET

; Routine at 8945
;
; Used by the routine at L892D.
L8945:
  XOR A
  RET

; Routine at 8947
;
; Used by the routine at L89FE.
L8947:
  LD B,$16
  LD C,$01
L8947_0:
  PUSH BC
  LD B,C
  CALL L978F
  POP BC
  INC C
  DJNZ L8947_0
  LD A,(LA3CD)
  LD HL,$5820
  LD (HL),A
  LD DE,$5821
  LD BC,$02BF
  LDIR
  RET

; Routine at 8964
L8964:
  LD A,(HL)
  LD B,A
  LD A,(DE)
  CP B
  JR NZ,L899B
  EX DE,HL
  PUSH DE
  CALL L850A
  EX DE,HL
  POP HL
  PUSH DE
  CALL L850A
  POP DE
L8964_0:
  LD A,(HL)
  CP $41
  JR C,L8964_1
  CP $5B
  JR NC,L8964_1
  OR $20
L8964_1:
  LD C,A
  LD A,(DE)
  CP $41
  JR C,L8964_2
  CP $5B
  JR NC,L8964_2
  OR $20
L8964_2:
  CP C
  JR NZ,L8998
  INC DE
  INC HL
  OR A
  JR NZ,L8964_0
  LD L,A
  LD H,A
  RET

; Routine at 8998
;
; Used by the routine at L8964.
L8998:
  SUB C
  LD H,A
  RET

; Routine at 899B
;
; Used by the routine at L8964.
L899B:
  AND $01
  JR Z,L89A3
  LD HL,$FFFF
  RET

; Routine at 89A3
;
; Used by the routine at L899B.
L89A3:
  LD HL,$0001
  RET

; Routine at 89A7
;
; Used by the routines at L89EC, L89FE, L8B3A, L8BA2, L8C16 and L8C30.
L89A7:
  LD A,C
  AND $80
  JR Z,L89B1
  LD A,(LA3CF)
  JR L89BB_0

; Routine at 89B1
;
; Used by the routine at L89A7.
L89B1:
  LD A,C
  AND $01
  JR Z,L89BB
  LD A,(LA3CE)
  JR L89BB_0

; Routine at 89BB
;
; Used by the routine at L89B1.
L89BB:
  LD A,(LA3CD)
; This entry point is used by the routines at L89A7 and L89B1.
L89BB_0:
  LD C,A
  CALL L9726
  RET

; Routine at 89C3
;
; Used by the routines at L89FE, L8B3A, L8BA2, L8DB5 and L96D2.
L89C3:
  PUSH BC
  LD HL,($BF62)
  CALL L850A
  JR NC,L89C3_0
  CALL L8526
  LD HL,$BBF3
L89C3_0:
  POP BC
  PUSH BC
  LD C,$00
  CALL L97B4
  POP BC
  LD A,C
  AND $01
  JR Z,L89EC_0
  LD A,(LA3D1)
  AND $01
  JR Z,L89EC_0
  PUSH BC
  LD HL,L8929

; Data block at 89EA
L89EA:
  DEFB $0E

; Data block at 89EB
L89EB:
  DEFB $1C

; Routine at 89EC
L89EC:
  CALL L97B4
  POP BC
; This entry point is used by the routine at L89C3.
L89EC_0:
  CALL L89A7
  RET

; Routine at 89F4
;
; Used by the routines at L8668, L8808, L8C16 and L968D.
L89F4:
  LD A,($BBE6)
  AND A
  JR Z,L89FE
  CALL L96D2
  RET

; Routine at 89FE
;
; Used by the routine at L89F4.
L89FE:
  LD HL,($BF62)
  PUSH HL
  LD A,$01
  LD (L8A7F),A
  LD A,($BBE4)
  AND A
  JR Z,L89FE_0
  LD C,$00
  LD B,A
  CALL L89A7
L89FE_0:
  CALL L8947
  OR A
  LD HL,($BBE9)
  LD D,H
  LD E,L
  LD BC,($BBEF)
  SBC HL,BC
  JR NZ,L89FE_1
  EX DE,HL
  DEC HL
  LD ($BBEF),HL
L89FE_1:
  LD HL,($BBEB)
  CALL L84EC
  LD BC,($BBEB)
L89FE_2:
  EX DE,HL
  LD HL,($BBE9)
  OR A
  SBC HL,BC
  JR Z,L8A77
  EX DE,HL
  LD A,(L8A7F)
  LD D,A
  LD A,(HL)
  LD E,A
  PUSH HL
  PUSH BC
  LD HL,($BBEF)
  OR A
  SBC HL,BC
  JR NZ,L89FE_3
  LD A,D
  LD ($BBE4),A
  LD A,E
  LD ($BBE8),A
  OR $80
L89FE_3:
  LD B,D
  LD C,A
  CALL L89C3
  POP BC
  POP HL
  LD ($BBED),BC
  LD A,(L8A7F)
  INC A
  CP $17
  JR Z,L8A77
  LD (L8A7F),A
  LD DE,$0012
  ADD HL,DE
  LD ($BF62),HL
  INC BC
  JR L89FE_2

; Routine at 8A77
;
; Used by the routine at L89FE.
L8A77:
  CALL L9FB8
  POP HL
  LD ($BF62),HL
  RET

; Unused
L8A7F:
  DEFS $01

; Routine at 8A80
L8A80:
  LD A,$03
  JR L8A94_0

; Routine at 8A84
L8A84:
  LD A,$04
  JR L8A94_0

; Routine at 8A88
L8A88:
  LD A,$01
  JR L8A94_0

; Routine at 8A8C
L8A8C:
  LD A,$02
  JR L8A94_0

; Routine at 8A90
L8A90:
  LD A,$05
  JR L8A94_0

; Routine at 8A94
L8A94:
  LD A,$06
; This entry point is used by the routines at L8830, L8A80, L8A84, L8A88, L8A8C
; and L8A90.
L8A94_0:
  LD HL,($BBEF)
  LD D,H
  LD E,L
  CP $80
  JR NZ,L8AA5
  INC HL
  LD C,$00
  JP L8BA2_3

; Routine at 8AA5
;
; Used by the routine at L8A94.
L8AA5:
  CP $03
  JR NZ,L8AC8
  LD DE,$0000
  PUSH DE
  EX DE,HL
  CALL L892D_0
  POP DE
  AND A
  JP NZ,L8BA2_1
  LD HL,$0000
  LD ($BBEB),HL
  LD HL,$0016
  LD ($BBED),BC
  LD C,$FF
  JP L8BA2_2

; Routine at 8AC8
;
; Used by the routine at L8AA5.
L8AC8:
  CP $04
  JR NZ,L8AF4
  LD DE,($BBE9)
  DEC DE
; This entry point is used by the routine at L8AF4.
L8AC8_0:
  PUSH DE
  EX DE,HL
  CALL L892D_0
  POP DE
  AND A
  JP NZ,L8BA2_1
  LD H,D
  LD L,E
  LD BC,$0015
  OR A
  SBC HL,BC
  JR NC,L8AC8_1
  LD HL,$0000
L8AC8_1:
  LD ($BBEB),HL
  LD ($BBED),DE
  LD C,$FF
  JP L8BA2_2

; Routine at 8AF4
;
; Used by the routine at L8AC8.
L8AF4:
  CP $06
  JR NZ,L8B0D
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
  JR NC,L8AF4_0
  LD D,B
  LD E,C
L8AF4_0:
  JR L8AC8_0

; Routine at 8B0D
;
; Used by the routine at L8AF4.
L8B0D:
  CP $05
  JR NZ,L8B3A
  EX DE,HL
  LD DE,$0016
  OR A
  SBC HL,DE
  EX DE,HL
  JR NC,L8B0D_0
  LD DE,$0000
L8B0D_0:
  PUSH DE
  EX DE,HL
  CALL L892D_0
  POP DE
  AND A
  JP NZ,L8BA2_1
  LD ($BBEB),DE
  LD H,D
  LD L,E
  LD BC,$0016
  ADD HL,BC
  LD ($BBED),HL
  LD C,$FF
  JP L8BA2_2

; Routine at 8B3A
;
; Used by the routine at L8B0D.
L8B3A:
  CP $01
  JR NZ,L8BA2
  LD A,D
  OR E
  JP Z,L8BA2_1
  DEC DE
  PUSH DE
  EX DE,HL
  CALL L892D_0
  POP DE
  AND A
  JP NZ,L8BA2_1
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
  JR C,L8B3A_0
  DEC HL
  LD ($BBED),HL
L8B3A_0:
  LD A,($BBE6)
  AND A
  JP NZ,L8BA2_1
  PUSH DE
  LD B,$01
  LD A,($BBE8)
  LD C,A
  CALL L89A7
  XOR A
  LD ($BBE4),A
  LD B,$15
  LD C,$16
L8B3A_1:
  PUSH BC
  LD A,B
  LD B,C
  LD C,A
  CALL L973E
  POP BC
  DEC C
  DJNZ L8B3A_1
  LD B,$01
  CALL L978F
  POP DE
  LD H,D
  LD L,E
  CALL L84EC
  PUSH DE
  LD A,(HL)
  LD B,$01
  LD C,A
  CALL L89C3
  POP DE
  JR L8BA2_1

; Routine at 8BA2
;
; Used by the routine at L8B3A.
L8BA2:
  CP $02
  JR NZ,L8BA2_1
  LD HL,($BBE9)
  DEC HL
  OR A
  SBC HL,DE
  JR C,L8BA2_1
  JR Z,L8BA2_1
  INC DE
  PUSH DE
  EX DE,HL
  CALL L892D_0
  POP DE
  AND A
  JR NZ,L8BA2_1
  LD HL,($BBEB)
  INC HL
  LD ($BBEB),HL
  LD HL,($BBED)
  INC HL
  LD ($BBED),HL
  LD A,($BBE6)
  AND A
  JR NZ,L8BA2_1
  PUSH DE
  LD B,$16
  LD A,($BBE8)
  LD C,A
  CALL L89A7
  XOR A
  LD ($BBE4),A
  LD B,$15
  LD C,$01
L8BA2_0:
  PUSH BC
  LD B,C
  INC C
  CALL L973E
  POP BC
  INC C
  DJNZ L8BA2_0
  LD B,$16
  CALL L978F
  POP DE
  LD H,D
  LD L,E
  CALL L84EC
  PUSH DE
  LD A,(HL)
  LD B,$16
  LD C,A
  CALL L89C3
  POP DE
; This entry point is used by the routines at L8AA5, L8AC8, L8B0D and L8B3A.
L8BA2_1:
  LD C,$00
; This entry point is used by the routines at L8AA5, L8AC8 and L8B0D.
L8BA2_2:
  LD HL,($BBEF)
; This entry point is used by the routine at L8A94.
L8BA2_3:
  OR A
  SBC HL,DE
  RET Z
  LD ($BBEF),DE
  LD A,($BBE6)
  AND A
  JR Z,L8C16
  CALL L96D2
  RET

; Routine at 8C16
;
; Used by the routine at L8BA2.
L8C16:
  LD A,($BBE4)
  AND A
  JR Z,L8C16_0
  PUSH BC
  PUSH DE
  LD B,A
  LD A,($BBE8)
  LD C,A
  CALL L89A7
  POP DE
  POP BC
L8C16_0:
  LD A,C
  AND A
  JR Z,L8C30
  CALL L89F4
  LD A,$04
  CALL L9FB8_0
  RET

; Routine at 8C30
;
; Used by the routine at L8C16.
L8C30:
  EX DE,HL
  LD DE,($BBEB)
  OR A
  SBC HL,DE
  INC L
  LD A,L
  LD ($BBE4),A
  LD D,A
  LD HL,($BBEF)
  CALL L84EC
  LD A,(HL)
  LD ($BBE8),A
  OR $80
  LD C,A
  LD A,D
  LD B,A
  CALL L89A7
  LD A,$04
  CALL L9FB8_0
  LD B,$03
  CALL LA0C3
  RET

; Routine at 8C5B
;
; Used by the routines at L94FC and LA2D8.
L8C5B:
  PUSH HL
  LD B,$15
  CALL L978F
  LD B,$16
  CALL L978F
  LD B,$15
  LD A,(LA3CA)
  LD C,A
  CALL L9726
  LD B,$16
  LD A,(LA3CF)
  LD C,A
  CALL L9726
  POP HL
  LD BC,$1500
  CALL L97B4
  RET

; Routine at 8C80
;
; Used by the routines at L94FC and LA33E.
L8C80:
  LD A,L
  AND A
  JR NZ,L8C80_0
  LD B,$00
  LD C,$14
  LD HL,($BBE9)
  OR A
  SBC HL,BC
  JR C,L8C96
L8C80_0:
  LD A,$03
  CALL L8595
  RET

; Routine at 8C96
;
; Used by the routine at L8C80.
L8C96:
  LD B,$15
  CALL L978F
  LD B,$16
  CALL L978F
  LD B,$15
  LD A,(LA3CD)
  LD C,A
  CALL L9726
  LD B,$16
  LD A,(LA3CD)
  LD C,A
  CALL L9726
  RET

; Routine at 8CB3
;
; Used by the routines at L85BC, L8642, L94DB, L95AA and L968D.
L8CB3:
  PUSH HL
  LD B,$00
  CALL L978F
  POP HL
  LD BC,$0000
  CALL L97B4
  RET

; Routine at 8CC1
;
; Used by the routines at L8CD3 and L8E1F.
L8CC1:
  ADD HL,BC
  LD DE,$BF66
  LDI
  LDI
  LDI
  LDI
; This entry point is used by the routine at L8DED.
L8CC1_0:
  LD A,$07
  CALL L8595
  RET

; Routine at 8CD3
L8CD3:
  LD A,$2A
  LD HL,L8D0B
  RST $08
  DEFB $A9
  JR C,L8D05
  CALL L854C
  LD HL,$0000
  CALL L84EC
  LD A,(HL)
  AND $01
  RET Z
  INC HL
  LD A,(HL)
  CP $2E
  RET NZ
  LD BC,$000D
  CALL L8CC1
  LD A,L
  AND A
  JR NZ,L8CFC
  LD A,$04
  CALL L9FB8_0
  CALL L9CCF
  RET

; Routine at 8CFC
;
; Used by the routine at L8CD3.
L8CFC:
  LD HL,$BC00
  RST $08
  DEFB $A9
  LD A,$03
  JR L8D05_0

; Routine at 8D05
;
; Used by the routines at L8CD3, L9654 and L968D.
L8D05:
  LD A,$02
; This entry point is used by the routine at L8CFC.
L8D05_0:
  CALL L9D78_0
  RET

; Routine at 8D0B
L8D0B:
  LD L,$2E
  NOP
  LD HL,L8F3E
  CALL L8E78
  RET

; Routine at 8D15
L8D15:
  LD A,($BBE5)
  OR A
  RET Z
  LD HL,L8F3B
  JR L8D2E_0

; Routine at 8D1F
L8D1F:
  LD HL,L8F50
  JR L8D2E_0

; Routine at 8D24
L8D24:
  LD HL,L8F4A
  JR L8D2E_0

; Routine at 8D29
L8D29:
  LD HL,L8F32
  JR L8D2E_0

; Routine at 8D2E
L8D2E:
  LD A,(LA1B1)
  AND A
  RET Z
  LD HL,L8F4D
; This entry point is used by the routines at L8D15, L8D1F, L8D24, L8D29 and
; L8D3A.
L8D2E_0:
  CALL LA1F6
  RET

; Routine at 8D3A
L8D3A:
  LD A,($BBE5)
  AND A
  RET Z
  LD HL,($BBF1)
  LD (LA3B6),HL
  LD HL,L8F41
  JR L8D2E_0

; Routine at 8D4A
L8D4A:
  XOR A
  JR L8D4D_0

; Routine at 8D4D
L8D4D:
  LD A,$01
; This entry point is used by the routine at L8D4A.
L8D4D_0:
  LD (LA3B5),A
  LD HL,$BBE2
  LD (LA3B6),HL
  LD HL,L8F5C
  CALL L8E78
  AND A
  RET Z
  LD A,$02
  CALL L9FB8_0
  RET

; Routine at 8D66
L8D66:
  XOR A
  JR L8D69_0

; Routine at 8D69
L8D69:
  LD A,$80
; This entry point is used by the routine at L8D66.
L8D69_0:
  OR $01
  JR L8D72_1

; Routine at 8D6F
L8D6F:
  XOR A
  JR L8D72_0

; Routine at 8D72
L8D72:
  LD A,$80
; This entry point is used by the routine at L8D6F.
L8D72_0:
  OR $00
; This entry point is used by the routine at L8D69.
L8D72_1:
  LD HL,L8F44
  CALL L8E63
  RET

; Routine at 8D7D
L8D7D:
  LD A,$03
; This entry point is used by the routines at L8D86 and L8D8A.
L8D7D_0:
  LD HL,L8F47
  CALL L8E63
  RET

; Routine at 8D86
L8D86:
  LD A,$02
  JR L8D7D_0

; Routine at 8D8A
L8D8A:
  LD A,$01
  JR L8D7D_0

; Routine at 8D8E
L8D8E:
  RST $18
  NOP
  NOP
  RET

; Routine at 8D92
L8D92:
  LD HL,$BBE5
  LD A,(HL)
  OR A
  RET Z
  INC A
  LD (HL),A
; This entry point is used by the routine at L9D25.
L8D92_0:
  LD HL,$BBE3
  INC (HL)
  RET

; Routine at 8D9F
L8D9F:
  LD A,$02
  JR L8DA7_0

; Routine at 8DA3
L8DA3:
  LD A,$01
  JR L8DA7_0

; Routine at 8DA7
L8DA7:
  LD A,$03
; This entry point is used by the routines at L8D9F and L8DA3.
L8DA7_0:
  LD HL,L8F53
  CALL L8E63
  RET

; Routine at 8DB0
L8DB0:
  LD HL,L8F35
  JR L8DB5_0

; Routine at 8DB5
L8DB5:
  LD HL,L8F38
; This entry point is used by the routine at L8DB0.
L8DB5_0:
  PUSH HL
  CALL L84FF
  LD B,$00
  CALL L978F
  LD BC,$0000
  CALL L89C3
  LD A,(LA3CA)
  LD C,A
  LD B,$00
  CALL L9726
  POP HL
  CALL LA1F6
  RET

; Routine at 8DD5
L8DD5:
  LD A,($BBE5)
  AND A
  RET NZ
  LD HL,L8F59
  CALL L8E78
  AND A
  RET Z
  LD A,$FF
  LD ($BBE6),A
  LD A,$01
  LD ($BBE3),A
  RET

; Routine at 8DED
L8DED:
  XOR A
; This entry point is used by the routine at L9D38.
L8DED_0:
  LD (LA3B5),A
  AND A
  JR NZ,L8DED_1
  CALL L84FF
L8DED_1:
  LD HL,L8F56
  CALL LA1F6
  LD A,(LA3AF)
  LD B,A
  AND $01
  RET Z
  LD A,B
  PUSH AF
  CALL L8754
  CALL L8CC1_0
  POP AF
  AND $40
  RET Z
  LD HL,LA385
  LD DE,$BBF3
  LD BC,$000D
  LDIR
  CALL L8769
  RET

; Routine at 8E1F
;
; Used by the routine at L963D.
L8E1F:
  CALL L84FF
  LD HL,($BF62)
  LD A,(HL)
  AND $01
  JR Z,L8E46
  LD HL,($BBEF)
  LD A,H
  OR L
  JR NZ,L8E1F_0
  CALL L854C
L8E1F_0:
  LD A,$2A
  LD HL,$BBF3
  RST $08
  DEFB $A9
  LD HL,($BF62)
  LD BC,$000E
  CALL L8CC1
  LD A,$04
  CALL L9FB8_0
  JR L8E46_0

; Routine at 8E46
;
; Used by the routine at L8E1F.
L8E46:
  CALL L945F
  CALL L8769
  LD A,(LA3AF)
  OR A
  JR NZ,L8E46_0
  CALL L9CB9
  AND $01
  JR Z,L8E46_0
  LD HL,L8F5F
  CALL LA1F6
; This entry point is used by the routine at L8E1F.
L8E46_0:
  CALL L9CCF
  RET

; Routine at 8E63
;
; Used by the routines at L8D72, L8D7D and L8DA7.
L8E63:
  LD (LA3B5),A
  PUSH HL
  CALL L84FF
  LD HL,($BF62)
  LD (LA3B6),HL
; This entry point is used by the routine at L8E78.
L8E63_0:
  POP HL
  CALL LA1F6
  LD A,(LA3AF)
  RET

; Routine at 8E78
;
; Used by the routines at L8D0B, L8D4D and L8DD5.
L8E78:
  PUSH HL
  CALL L84FF
  JR L8E63_0

; Routine at 8E7E
L8E7E:
  ADD A,H
  ADC A,D
  NOP
  NOP
  LD L,$8D
  LD A,L
  ADC A,L
  ADC A,D
  ADC A,L
  ADC A,D
  SUB L
  NOP
  NOP
  ADD HL,HL
  ADC A,L
  LD L,A
  ADC A,L
  NOP
  NOP
  DEC D
  ADC A,L
  PUSH DE
  ADC A,L
  NOP
  NOP
  SUB D
  ADC A,L
  LD H,(HL)
  ADC A,L
  OUT ($8C),A
  ADD A,B
  ADC A,D
  LD C,$8D
  LD A,($248D)
  ADC A,L
  LD C,D
  ADC A,L
  OR B
  ADC A,L
  NOP
  NOP
  SBC A,D
  ADC A,L
  NOP
  NOP
  IN A,($94)

; Data block at 8EB2
L8EB2:
  DEFB $01,$02,$04,$08,$80,$0C,$C0,$C1
  DEFB $C2,$3F,$85,$7B,$82,$3D,$3B,$22
  DEFB $3C,$3E,$5D,$2F,$60,$3A,$5F,$FF

; Data block at 8ECA
L8ECA:
  DEFW L8A88,L8A8C,L8A90,L8A94,L8E1F,L8CD3,L8CD3,L8A80
  DEFW L8A84,L8DA3,$0000,L96EF,L8D72,L8D1F,L8D69,L8DA7
  DEFW L8D86,L8D9F,L8D4D,L8DB5,L8D8E,L94D8,L8DED

; Routine at 8EF8
;
; Used by the routine at L9D4F.
L8EF8:
  LD D,A
  LD HL,L8EB2
  LD BC,$0018
  CPIR
  LD A,B
  OR C
  LD A,D
  JR Z,L8F13
  OR A
  LD HL,$0017
  SBC HL,BC
  ADD HL,HL
  LD DE,L8ECA
  ADD HL,DE
  JR L8F13_0

; Routine at 8F13
;
; Used by the routine at L8EF8.
L8F13:
  CP $41
  RET C
  CP $5B
  RET NC
  SUB $41
  ADD A,A
  LD HL,L8E7E
  LD D,$00
  LD E,A
  ADD HL,DE
; This entry point is used by the routine at L8EF8.
L8F13_0:
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  OR H
  RET Z
  CALL LA0C2
  LD B,$03
  CALL LA0C3
  RET

; Message at 8F32
L8F32:
  DEFM "HLP"

; Message at 8F35
L8F35:
  DEFM "HEX"

; Message at 8F38
L8F38:
  DEFM "TXT"

; Message at 8F3B
L8F3B:
  DEFM "POK"

; Message at 8F3E
L8F3E:
  DEFM "INF"

; Message at 8F41
L8F41:
  DEFM "SNA"

; Message at 8F44
L8F44:
  DEFM "TAP"

; Message at 8F47
L8F47:
  DEFM "DOS"

; Message at 8F4A
L8F4A:
  DEFM "TPE"

; Message at 8F4D
L8F4D:
  DEFM "UNO"

; Message at 8F50
L8F50:
  DEFM "LOK"

; Message at 8F53
L8F53:
  DEFM "CLP"

; Message at 8F56
L8F56:
  DEFM "SPD"

; Message at 8F59
L8F59:
  DEFM "E"

; Routine at 8F5A
L8F5A:
  LD E,B
  LD D,H

; Routine at 8F5C
L8F5C:
  LD B,H
  LD D,E
  LD C,E

; Routine at 8F5F
L8F5F:
  LD B,L
  LD E,B
  LD B,L
; This entry point is used by the routines at L8FC3, L9093 and L91D4.
L8F5F_0:
  EX DE,HL
  LD B,H
  LD C,L
  LD A,($BFA2)
  LD HL,$C000
  RST $08
  DEFB $81
  LD HL,$0000
  RET NC
  LD L,A
  RET

; Routine at 8F73
;
; Used by the routine at L9DDB.
L8F73:
  XOR A
  LD HL,$C000
  RST $08
  DEFB $84
  LD A,(LA3D1)
  AND $20
  JR Z,L8F8E
  CALL L9535_0
  OR A
  JR NZ,L8F89
  LD A,$02
  RET

; Routine at 8F89
;
; Used by the routine at L8F73.
L8F89:
  LD A,(LA3D0)
  JR L8F8E_0

; Routine at 8F8E
;
; Used by the routine at L8F73.
L8F8E:
  LD A,(LA3D0)
  ADD A,A
  LD B,A
  ADD A,A
  ADD A,B
  LD DE,$C000
  LD H,$00
  LD L,A
  ADD HL,DE
  LD A,(HL)
; This entry point is used by the routine at L8F89.
L8F8E_0:
  LD ($BFA2),A
  LD B,$08
  LD HL,$C000
  LD DE,$0006
; This entry point is used by the routine at L8FC3.
L8F8E_1:
  LD A,(HL)
  OR A
  JR Z,L8FC3_3
  AND $78
  LD C,A
  AND $60
  JR Z,L8FC3_2
  LD A,C
  AND $18
  SRL A
  SRL A
  SRL A
  OR A
  JR NZ,L8FC3
  LD A,$01
  JR L8FC3_1

; Routine at 8FC3
;
; Used by the routine at L8F8E.
L8FC3:
  PUSH BC
  LD B,A
L8FC3_0:
  ADD A,A
  DJNZ L8FC3_0
  POP BC
; This entry point is used by the routine at L8F8E.
L8FC3_1:
  LD C,A
  LD A,($BBE2)
  OR C
  LD ($BBE2),A
; This entry point is used by the routine at L8F8E.
L8FC3_2:
  ADD HL,DE
  DJNZ L8F8E_1
; This entry point is used by the routine at L8F8E.
L8FC3_3:
  LD HL,$0000
  LD DE,$0000
  CALL L8F5F_0
  LD A,L
  OR A
  JR Z,L8FE4
  LD A,$80
  RET

; Routine at 8FE4
;
; Used by the routine at L8FC3.
L8FE4:
  LD A,($C00D)
  LD ($BF8F),A
  LD DE,($C00B)
  LD ($BF92),DE
  LD DE,($C00E)
  LD ($BF94),DE
  LD A,($C012)
  CP $02
  JR NZ,L904F
  LD A,$01
  LD ($BF8E),A
  LD HL,($C010)
  LD DE,$0000
  EXX
  LD HL,($C016)
  LD DE,$0000
  CALL L9E66
  LD BC,($C00E)
  XOR A
  ADD HL,BC
  ADC A,E
  LD E,A
  LD A,$00
  ADC A,D
  LD D,A
  LD ($BF96),HL
  LD ($BF98),DE
  LD HL,$0002
  LD ($BF9A),HL
  LD L,$00
  LD ($BF9C),HL
  LD HL,($C011)
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  EX DE,HL
  LD HL,$0000
  LD BC,($C00B)
  CALL L9E9D
  LD ($BF90),DE
  LD A,$00
  JR L9090_0

; Routine at 904F
;
; Used by the routine at L8FE4.
L904F:
  OR A
  JR NZ,L9090
  LD A,$02
  LD ($BF8E),A
  LD HL,$0000
  LD ($BF90),HL
  LD HL,($C010)
  LD DE,$0000
  EXX
  LD HL,($C024)
  LD DE,($C026)
  CALL L9E66
  LD BC,($C00E)
  XOR A
  ADD HL,BC
  ADC A,E
  LD E,A
  LD A,$00
  ADC A,D
  LD D,A
  LD ($BF96),HL
  LD ($BF98),DE
  LD HL,$C02C
  LD DE,$BF9A
  LD BC,$0004
  LDIR
  LD A,$00
  JR L9090_0

; Routine at 9090
;
; Used by the routine at L904F.
L9090:
  LD A,$01
; This entry point is used by the routines at L8FE4 and L904F.
L9090_0:
  RET

; Routine at 9093
;
; Used by the routine at L9105.
L9093:
  XOR A
  OR D
  OR E
  OR H
  OR L
  AND A
  JR NZ,L9093_0
  LD HL,($BF9A)
  LD DE,($BF9C)
L9093_0:
  LD B,$02
  LD A,($BF8E)
  CP $01
  JR NZ,L9093_1
  DEC B
L9093_1:
  SLA L
  RL H
  RL E
  RL D
  DJNZ L9093_1
  EX DE,HL
  LD BC,($BF92)
  CALL L9E9D
  PUSH HL
  LD H,B
  LD L,C
  EX DE,HL
  LD BC,($BF94)
  XOR A
  ADD HL,BC
  ADC A,E
  LD E,A
  LD A,$00
  ADC A,D
  LD D,A
  CALL L8F5F_0
  POP HL
  LD BC,$C000
  ADD HL,BC
  LD A,($BF8E)
  CP $01
  JR NZ,L90EB
  LD DE,$0000
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  AND H
  INC A
  JR NZ,L9093_2
  LD H,D
  LD L,E
L9093_2:
  RET

; Routine at 90EB
;
; Used by the routine at L9093.
L90EB:
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
  JR NZ,L9102
  LD A,D
  SUB $0F
  JR NZ,L9102
  LD H,A
  LD L,A
  LD D,A
  LD E,A
  RET

; Routine at 9102
;
; Used by the routine at L90EB.
L9102:
  LD L,C
  LD H,B
  RET

; Routine at 9105
;
; Used by the routines at L85BC and L8680.
L9105:
  LD IX,$C000
  XOR A
  LD ($BE00),A
  LD ($BF88),A
  LD HL,$E001
  LD ($BF8A),HL
  LD HL,$0000
  LD ($BF9E),HL
  LD ($BFA0),HL
  LD ($BBE9),HL
  INC HL
  LD ($BF85),HL
  LD HL,$C200
  LD ($BF6E),HL
  LD A,$10
  LD ($BF84),A
  LD HL,$BF66
  LD DE,$BFA3
  LDI
  LDI
  LDI
  LDI
; This entry point is used by the routine at L91D4.
L9105_0:
  CP $10
  JP NZ,L91D4_1
  LD A,($BF8F)
  LD B,A
  LD A,($BF88)
  CP B
  JR NZ,L9105_1
  LD HL,($BFA3)
  LD DE,($BFA5)
  CALL L9093
  LD A,H
  OR L
  OR D
  OR E
  JP Z,L920C
  LD ($BFA3),HL
  LD ($BFA5),DE
  XOR A
  LD ($BF88),A
L9105_1:
  OR A
  JR NZ,L91D4
  LD HL,($BF96)
  LD DE,($BF98)
  LD ($BF9E),HL
  LD ($BFA0),DE
  LD BC,($BFA3)
  LD A,B
  OR C
  LD BC,($BFA5)
  OR B
  OR C
  JR Z,L91D4_0
  XOR A
  LD BC,($BF90)
  ADD HL,BC
  ADC A,E
  LD E,A
  LD A,$00
  ADC A,D
  LD D,A
  LD ($BF9E),HL
  LD ($BFA0),DE
  XOR A
  LD HL,($BFA3)
  LD BC,($BF9A)
  SBC HL,BC
  EX DE,HL
  LD HL,($BFA5)
  LD BC,($BF9C)
  SBC HL,BC
  EX DE,HL
  EXX
  LD H,$00
  LD A,($BF8F)
  LD L,A
  LD DE,$0000
  CALL L9E66
  LD BC,($BF9E)
  ADD HL,BC
  EX DE,HL
  LD BC,($BFA0)
  ADC HL,BC
  EX DE,HL
  LD ($BF9E),HL
  LD ($BFA0),DE
  JR L91D4_0

; Routine at 91D4
;
; Used by the routine at L9105.
L91D4:
  LD HL,($BF9E)
  LD DE,($BFA0)
  XOR A
  INC HL
  ADC A,E
  LD E,A
  LD A,$00
  ADC A,D
  LD D,A
  LD ($BF9E),HL
  LD ($BFA0),DE
; This entry point is used by the routine at L9105.
L91D4_0:
  CALL L8F5F_0
  LD HL,$BF88
  INC (HL)
  LD IX,$C000
  XOR A
  LD ($BF84),A
; This entry point is used by the routine at L9105.
L91D4_1:
  CALL L931B
  OR A
  JR Z,L920C
  LD DE,$0020
  ADD IX,DE
  LD HL,$BF84
  INC (HL)
  LD A,(HL)
  JP L9105_0

; Routine at 920C
;
; Used by the routines at L9105 and L91D4.
L920C:
  LD L,$00
  RET

; Routine at 920F
;
; Used by the routine at L931B.
L920F:
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
; This entry point is used by the routines at L9247 and L924F.
L920F_0:
  LD B,A
  LD A,(HL)
  AND A
  JR Z,L924F_0
  CP $20
  JR C,L920F_1
  CP $7F
  JR C,L920F_2
L920F_1:
  LD A,$7E
L920F_2:
  LD (DE),A
  INC DE
  INC C
  INC HL
  INC HL
  LD A,B
  INC A
  CP $05
  JR NZ,L9247
  INC HL
  INC HL
  INC HL
  JR L920F_0

; Routine at 9247
;
; Used by the routine at L920F.
L9247:
  CP $0B
  JR NZ,L924F
  INC HL
  INC HL
  JR L920F_0

; Routine at 924F
;
; Used by the routine at L9247.
L924F:
  CP $0D
  JR NZ,L920F_0
; This entry point is used by the routine at L920F.
L924F_0:
  POP HL
  LD A,(HL)
  AND $40
  JR Z,L924F_1
  XOR A
  LD (DE),A
L924F_1:
  LD A,C
  EX DE,HL
  LD HL,$BF87
  ADD A,(HL)
  LD (HL),A
  EX DE,HL
  LD BC,$000D
  ADD HL,BC
  LD A,(HL)
  LD ($BF61),A
  RET

; Routine at 926C
;
; Used by the routine at L931B.
L926C:
  LD HL,$BE00
  LD A,(HL)
  AND A
  RET Z
  CALL L984C
  LD A,C
  AND A
  RET Z
  LD (L92DD),A
  LD E,L
  LD HL,($BF8C)
  XOR A
  LD B,$0B
L926C_0:
  RRCA
  LD D,A
  LD A,(HL)
  ADD A,D
  INC HL
  DJNZ L926C_0
  LD L,A
  LD A,($BF61)
  CP L
  JP NZ,L9306_0
  LD A,E
  AND A
  JR NZ,L92C5_0
  LD A,C
  LD DE,$BE00
  SUB $05
  LD E,A
  LD A,$80
  LD (DE),A
  INC DE
  LD HL,($BF6E)
  LD A,(HL)
  AND $01
  JR Z,L92AC
  XOR A
  LD (DE),A
  JR L92C5_0

; Routine at 92AC
;
; Used by the routine at L926C.
L92AC:
  LD HL,$BE00
  LD A,($BF87)
  LD L,A
  LD B,A
L92AC_0:
  LD A,(HL)
  CP $2E
  JR Z,L92BE
  DEC HL
  DJNZ L92AC_0
  JR L92C5

; Routine at 92BE
;
; Used by the routine at L92AC.
L92BE:
  LD BC,$0005
  LDIR
  JR L92C5_0

; Routine at 92C5
;
; Used by the routine at L92AC.
L92C5:
  INC DE
  XOR A
  LD (DE),A
; This entry point is used by the routines at L926C and L92BE.
L92C5_0:
  LD DE,$BF85
  LD HL,($BF6E)
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

; Data block at 92DC
L92DC:
  DEFB $3E

; Data block at 92DD
L92DD:
  DEFB $00

; Routine at 92DE
L92DE:
  INC A
  LD B,$00
  LD C,A
  LD E,A
  ADD HL,BC
  LD ($BF85),HL
  LD BC,$2000
  OR A
  SBC HL,BC
  JR NC,L9306
  LD B,$00
  LD C,E
  LD A,C
  LD DE,($BF8A)
  LD HL,$BE00
  LDIR
  LD HL,($BF8A)
  LD C,A
  ADD HL,BC
  LD ($BF8A),HL
  JR L9306_0

; Routine at 9306
;
; Used by the routine at L92DE.
L9306:
  LD HL,($BF6E)
  LD BC,$000C
  ADD HL,BC
  XOR A
  LD (HL),A
  INC HL
  LD (HL),A
; This entry point is used by the routines at L926C and L92DE.
L9306_0:
  LD HL,$BE00
  XOR A
  LD (HL),A
  LD HL,$BF87
  LD (HL),A
  RET

; Routine at 931B
;
; Used by the routine at L91D4.
L931B:
  PUSH IX
  LD ($BF8C),IX
  LD A,(IX+$00)
  LD H,A
  AND A
  JP Z,L93B6
  LD A,(IX+$0B)
  CP $0F
  JR NZ,L931B_0
  LD HL,($BF8C)
  CALL L920F
L931B_0:
  LD A,H
  CP $E5
  JR Z,L931B_4
  CP $2E
  JR NZ,L931B_1
  LD A,($BF84)
  AND A
  JR Z,L931B_4
L931B_1:
  LD A,(IX+$0B)
  LD B,A
  AND $08
  JR NZ,L931B_4
  LD A,($BF89)
  AND A
  JR Z,L931B_2
  LD A,B
  AND $10
  JR Z,L931B_4
L931B_2:
  LD C,B
  LD HL,($BF6E)
  LD DE,$000C
  XOR A
  LD (HL),A
  ADD HL,DE
  LD (HL),A
  INC HL
  LD (HL),A
  LD A,C
  AND $10
  JR Z,L931B_3
  LD HL,($BF6E)
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
L931B_3:
  LD HL,($BF8C)
  LD DE,($BF6E)
  INC DE
  LD BC,$000B
  LDIR
  CALL L926C
  LD HL,($BF6E)
  LD BC,$0012
  ADD HL,BC
  LD ($BF6E),HL
  LD HL,($BBE9)
  INC HL
  LD ($BBE9),HL
  LD BC,$01AA
  OR A
  SBC HL,BC
  JR Z,L93B6
L931B_4:
  POP IX
  LD A,$01
  RET

; Routine at 93B6
;
; Used by the routine at L931B.
L93B6:
  POP IX
  XOR A
  RET

; Routine at 93BA
;
; Used by the routines at L93E2 and L9535.
L93BA:
  LD A,H
  LD HL,$BFB4
  PUSH HL
  RST $08
  DEFB $A1
  POP IX
  LD B,(IX+$08)
  LD C,(IX+$07)
  RET

; Unused
L93CA:
  DEFS $01

; Routine at 93CB
;
; Used by the routines at L8732 and LA26A.
L93CB:
  XOR A
  LD (L9402),A
  LD A,$24
; This entry point is used by the routine at L94AC.
L93CB_0:
  PUSH DE
  PUSH BC
  LD B,$01
  RST $08
  DEFB $9A
  POP BC
  JR NC,L93E2
  POP DE
  LD (LA3D8),A
  LD HL,$0000
  RET

; Routine at 93E2
;
; Used by the routine at L93CB.
L93E2:
  LD (L9402),A
  LD H,A
  LD A,C
  OR B
  CALL Z,L93BA
  POP HL
  LD A,(L9402)
  RST $08
  DEFB $9D
  JR NC,L93E2_0
  LD HL,$0000
  LD (LA3D8),A
L93E2_0:
  LD A,(L9402)
  RST $08
  DEFB $9B
  LD HL,$0001
  RET

; Unused
L9402:
  DEFS $01

; Routine at 9403
;
; Used by the routine at L94DB.
L9403:
  LD A,$2A
  RST $08
  DEFB $AD
  JR C,L940D
  LD HL,$0001
  RET

; Routine at 940D
;
; Used by the routine at L9403.
L940D:
  LD (LA3D8),A
  LD HL,$0000
  RET

; Routine at 9414
;
; Used by the routine at L9E26.
L9414:
  LD A,(LA3D1)
  AND $10
  RET Z
  LD A,$24
  LD B,$01
  LD HL,L948B
  RST $08
  DEFB $9A
  JR C,L9445_1
  LD (L93CA),A
  LD HL,$C000
  LD BC,$0200
  RST $08
  DEFB $9D
  JR C,L9445_1
  LD DE,$BC00
  LD HL,$C000
L9414_0:
  LD A,(DE)
  LD B,A
  LD C,(HL)
  OR C
  JR Z,L9445
  CP B
  JR NZ,L9445_0
  INC DE
  INC HL
  JR L9414_0

; Routine at 9445
;
; Used by the routine at L9414.
L9445:
  LD A,(L93CA)
  LD HL,$BBEF
  LD BC,$0002
  RST $08
  DEFB $9D
  LD HL,($BBEF)
  CALL L84EC
; This entry point is used by the routine at L9414.
L9445_0:
  LD A,(L93CA)
  RST $08
  DEFB $9B
; This entry point is used by the routine at L9414.
L9445_1:
  XOR A
  RET C
  INC A
  RET

; Routine at 945F
;
; Used by the routines at L8E46 and L9DC8.
L945F:
  LD A,(LA3D1)
  AND $10
  RET Z
  LD A,$24
  LD HL,L948B
  LD B,$0A
  RST $08
  DEFB $9A
  RET C
  LD (L93CA),A
  LD HL,$BC00
  LD BC,$0200
  RST $08
  DEFB $9E
  LD A,(L93CA)
  LD HL,$BBEF
  LD BC,$0002
  RST $08
  DEFB $9E
  LD A,(L93CA)
  RST $08
  DEFB $9B
  RET

; Message at 948B
L948B:
  DEFM "/tmp/browse.bmk"

; Data block at 949A
L949A:
  DEFB $00

; Message at 949B
L949B:
  DEFM "cache.db"

; Data block at 94A3
L94A3:
  DEFB $00

; Message at 94A4
L94A4:
  DEFM "Cached"

; Data block at 94AA
L94AA:
  DEFB $21,$00

; Routine at 94AC
;
; Used by the routine at L8595.
L94AC:
  LD HL,L949B
  LD BC,$3E02
  LD DE,$C1FE
  XOR A
  LD (L9402),A
  LD A,$2A
  CALL L93CB_0
  LD A,L
  AND A
  JR Z,L94AC_0
  LD DE,($C1FE)
  LD ($BBE9),DE
L94AC_0:
  XOR A
  LD (LA3D8),A
  RET

; Message at 94CF
L94CF:
  DEFM "Deleted"

; Routine at 94D6
L94D6:
  DEFB $21,$00
L94D8:
  DEFB $AF
  JR L94DB_0

; Routine at 94DB
L94DB:
  LD HL,L858A
  CALL L8CB3
  LD A,$01
; This entry point is used by the routine at L94D6.
L94DB_0:
  PUSH AF
  LD HL,L949B
  CALL L9403
  LD A,L
  AND A
  JR Z,L94DB_1
  LD L,$0A
  CALL L8595
L94DB_1:
  POP AF
  AND A
  JR NZ,L94FC
  LD HL,L94CF
  JR L94FC_0

; Routine at 94FC
;
; Used by the routine at L94DB.
L94FC:
  LD HL,L949B
  LD A,$2A
  LD B,$0A
  RST $08
  DEFB $9A
  JR C,L9532
  LD (L93CA),A
  LD HL,($BBE9)
  LD ($C1FE),HL
  LD HL,$C1FE
  LD BC,$3E02
  RST $08
  DEFB $9E
  JR C,L9532
  LD A,(L93CA)
  RST $08
  DEFB $9B
  LD HL,L94A4
; This entry point is used by the routine at L94DB.
L94FC_0:
  CALL L8C5B
  LD B,$60
  CALL LA0C9
  LD L,$01
  CALL L8C80
  LD L,$01
  RET

; Routine at 9532
;
; Used by the routine at L94FC.
L9532:
  LD L,$00
  RET

; Routine at 9535
L9535:
  CPL
  NOP
; This entry point is used by the routine at L8F73.
L9535_0:
  LD HL,L9535
  LD A,$2A
  LD B,$01
  RST $08
  DEFB $A3
  JR C,L9553
  PUSH AF
  LD H,A
  CALL L93BA
  LD A,($BFB5)
  LD (LA3D0),A
  POP AF
  RST $08
  DEFB $9B
  LD A,$01
  RET

; Routine at 9553
;
; Used by the routine at L9535.
L9553:
  XOR A
  RET

; Routine at 9555
;
; Used by the routine at L95B7.
L9555:
  LD DE,L9615
; This entry point is used by the routine at L9580.
L9555_0:
  LD A,(HL)
  AND A
  JR Z,L9586
  LD B,A
  LD A,(DE)
  CP $60
  JR C,L9555_1
  CP $80
  JR NC,L9555_1
  SUB $20
L9555_1:
  LD C,A
  LD A,B
  CP $60
  JR C,L9555_2
  CP $80
  JR NC,L9555_2
  SUB $20
L9555_2:
  CP C
  JR NZ,L9580
  INC DE
  LD A,(DE)
  AND A
  JR NZ,L9580_0
  LD HL,$0001
  RET

; Routine at 9580
;
; Used by the routine at L9555.
L9580:
  LD DE,L9615
; This entry point is used by the routine at L9555.
L9580_0:
  INC HL
  JR L9555_0

; Routine at 9586
;
; Used by the routine at L9555.
L9586:
  LD HL,$0000
  RET

; Routine at 958A
L958A:
  LD HL,($BF6C)
  LD A,(HL)
  XOR $01
  LD (HL),A
; This entry point is used by the routines at L963D and L9680.
L958A_0:
  AND A
  JR Z,L95AA
  XOR A
  LD (L9603),A
  LD HL,L9615
  LD (HL),A
  LD DE,L9616
  LD BC,$000F
  LDIR
  INC A
  LD HL,L960F
  JR L95AA_0

; Routine at 95AA
;
; Used by the routine at L958A.
L95AA:
  LD HL,$BC00
; This entry point is used by the routine at L958A.
L95AA_0:
  LD ($BF6C),A
  CALL L8CB3
  CALL L9CCF
  RET

; Routine at 95B7
;
; Used by the routines at L9658 and L968D.
L95B7:
  LD A,L
  LD HL,$C200
  LD BC,$0000
  OR A
  JR NZ,L95B7_0
  LD HL,($BBEF)
  PUSH HL
  CALL L84EC
  POP BC
L95B7_0:
  EX DE,HL
  LD HL,($BBE9)
  SBC HL,BC
  EX DE,HL
; This entry point is used by the routine at L95F6.
L95B7_1:
  LD A,D
  OR E
  JR Z,L95FF
  PUSH DE
  PUSH HL
  CALL L850A
  LD A,(L9603)
  CP $01
  JR NZ,L95B7_2
  LD A,(HL)
  LD HL,$BF6A
  LD (HL),A
L95B7_2:
  CALL L9555
  LD A,L
  OR A
  JR Z,L95F6
  POP HL
  POP DE
  OR A
  LD HL,($BBE9)
  SBC HL,DE
  JR L95FF_0

; Routine at 95F6
;
; Used by the routine at L95B7.
L95F6:
  POP HL
  POP DE
  LD BC,$0012
  ADD HL,BC
  DEC DE
  JR L95B7_1

; Routine at 95FF
;
; Used by the routine at L95B7.
L95FF:
  LD HL,$0000
; This entry point is used by the routine at L95B7.
L95FF_0:
  RET

; Data block at 9603
L9603:
  DEFB $00

; Message at 9604
L9604:
  DEFM "Not found!"

; Data block at 960E
L960E:
  DEFB $00

; Message at 960F
L960F:
  DEFM "Find: "

; Data block at 9615
L9615:
  DEFB $00

; Data block at 9616
L9616:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00

; Routine at 9625
;
; Used by the routine at L9CCF.
L9625:
  LD A,C
  CP $0C
  JR NZ,L963D
  LD HL,L9603
  LD A,(HL)
  AND A
  RET Z
  DEC A
  DEC (HL)
  LD B,$00
  LD C,A
  LD HL,L9615
  ADD HL,BC
  XOR A
  LD (HL),A
  JR L968D_1

; Routine at 963D
;
; Used by the routine at L9625.
L963D:
  CP $80
  JR Z,L963D_0
  CP $0D
  JR NZ,L9658
L963D_0:
  LD HL,($BBEF)
  LD A,H
  OR L
  JR Z,L9654
  CALL L8E1F
  XOR A
  CALL L958A_0
  RET

; Routine at 9654
;
; Used by the routine at L963D.
L9654:
  CALL L8D05
  RET

; Routine at 9658
;
; Used by the routine at L963D.
L9658:
  CP $46
  JR NZ,L9680
  OR A
  LD HL,($BBE9)
  LD DE,($BBEF)
  SBC HL,DE
  JR C,L9658_0
  INC DE
  LD ($BBEF),DE
L9658_0:
  LD L,$00
  CALL L95B7
  LD A,H
  OR L
  JR NZ,L968D_2
  LD L,$01
  CALL L95B7
  LD A,H
  OR L
  JR NZ,L968D_2
  RET

; Routine at 9680
;
; Used by the routine at L9658.
L9680:
  CP $20
  JR NZ,L968D
  LD A,B
  AND A
  JR Z,L968D_0
  XOR A
  CALL L958A_0
  RET

; Routine at 968D
;
; Used by the routine at L9680.
L968D:
  CP $20
  RET C
  CP $80
  RET NC
; This entry point is used by the routine at L9680.
L968D_0:
  LD HL,L9603
  LD A,(HL)
  CP $10
  RET NC
  LD B,A
  LD A,C
  LD C,B
  LD B,$00
  LD DE,L9615
  EX DE,HL
  ADD HL,BC
  LD (HL),A
  EX DE,HL
  INC (HL)
; This entry point is used by the routine at L9625.
L968D_1:
  LD HL,L960F
  CALL L8CB3
  CALL L95B7
  LD A,H
  OR L
  JR NZ,L968D_2
  LD A,(L9603)
  AND A
  JR Z,L968D_2
  PUSH HL
  LD BC,$0017
  LD HL,L9604
  CALL L97B4
  CALL L8D05
  POP HL
; This entry point is used by the routine at L9658.
L968D_2:
  LD ($BBEB),HL
  LD ($BBEF),HL
  CALL L89F4
  RET

; Routine at 96D2
;
; Used by the routines at L89F4, L8BA2 and L96EB.
L96D2:
  CALL L84FF
  LD HL,L96EB
  CALL LA1F6
  LD A,(LA3AF)
  CP $01
  RET Z
  LD A,($BF62)
  LD C,A
  LD B,$17
  CALL L89C3
  RET

; Routine at 96EB
L96EB:
  LD B,(HL)
  LD D,L
  LD C,H
  NOP
L96EF:
  LD HL,$BBE6
  LD A,(HL)
  XOR $01
  LD (HL),A
  OR A
  JR Z,L96FD
  CALL L96D2
  RET

; Routine at 96FD
;
; Used by the routine at L96EB.
L96FD:
  CALL L9DA6
  LD A,$01
  CALL L8595
  RET

; Routine at 9706
;
; Used by the routine at L9DA6.
L9706:
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

; Routine at 971D
;
; Used by the routines at L9D78, L9DA6 and L9E26.
L971D:
  OUT ($FE),A
  RLCA
  RLCA
  RLCA
  LD ($5C48),A
  RET

; Routine at 9726
;
; Used by the routines at L89BB, L8C5B, L8C96, L8DB5 and L9DA6.
L9726:
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

; Routine at 973E
;
; Used by the routines at L8B3A and L8BA2.
L973E:
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
  LD (L976E),A
  LD A,E
  LD (L9770),A
  LD A,$08
; This entry point is used by the routine at L9771.
L973E_0:
  LD BC,$0020
  LDIR
  DEC HL
  DEC DE
  INC D
  INC H

; Data block at 976D
L976D:
  DEFB $2E

; Data block at 976E
L976E:
  DEFB $00

; Data block at 976F
L976F:
  DEFB $1E

; Data block at 9770
L9770:
  DEFB $00

; Routine at 9771
L9771:
  DEC A
  AND A
  JR NZ,L973E_0
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

; Routine at 978F
;
; Used by the routines at L8947, L8B3A, L8BA2, L8C5B, L8C96, L8CB3 and L8DB5.
L978F:
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
L978F_0:
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
  DJNZ L978F_0
  RET

; Routine at 97B4
;
; Used by the routines at L8668, L89C3, L89EC, L8C5B, L8CB3, L968D, LA076 and
; LA2D8.
L97B4:
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
; This entry point is used by the routine at L9813.
L97B4_0:
  LD A,(HL)
  AND A
  RET Z
  SUB $20
  PUSH HL
  LD BC,L9867
  LD H,$00
  LD L,A
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,BC
  LD DE,$BFAD
  LD A,(HL)
  INC HL
  LD BC,$0007
  LDIR
  LD B,$06
  AND A
  JR Z,L97B4_1
  LD B,A
L97B4_1:
  LD A,IYh
  LD E,IXl
; This entry point is used by the routine at L9813.
L97B4_2:
  LD D,IXh
  LD C,A
  PUSH BC
  LD HL,$BFAC
  LD B,$08
; This entry point is used by the routine at L97FD.
L97B4_3:
  SLA (HL)
  LD A,(DE)
  JR NC,L97FD
  OR C
  JR L97FD_0

; Routine at 97FD
;
; Used by the routine at L97B4.
L97FD:
  OR C
  XOR C
; This entry point is used by the routine at L97B4.
L97FD_0:
  LD (DE),A
  INC HL
  INC D
  DJNZ L97B4_3
  SRL C
  JR NZ,L9813_0
  LD C,$80
  INC E
  LD A,E
  AND $1F
  JR NZ,L9813
  POP BC
  POP HL
  RET

; Routine at 9813
;
; Used by the routine at L97FD.
L9813:
  INC IXl
; This entry point is used by the routine at L97FD.
L9813_0:
  LD A,C
  POP BC
  DJNZ L97B4_2
  LD IYh,A
  POP HL
  INC HL
  JR L97B4_0

; Routine at 981F
;
; Used by the routine at L8732.
L981F:
  LD B,$61
  LD HL,L9867
  LD DE,$BF00
L981F_0:
  LD A,(HL)
  AND A
  JR NZ,L981F_1
  LD A,$06
L981F_1:
  LD (DE),A
  INC DE
  LD C,D
  LD A,E
  LD DE,$0008
  ADD HL,DE
  LD D,C
  LD E,A
  DJNZ L981F_0
  LD HL,L8929
  CALL L984C
  LD A,$FF
  SUB B
  SRL A
  SRL A
  SRL A
  LD (L89EB),A
  RET

; Routine at 984C
;
; Used by the routines at L926C and L981F.
L984C:
  LD B,$00
  LD C,$00
  LD D,$BF
L984C_0:
  LD A,(HL)
  AND A
  JR Z,L9862
  SUB $20
  LD E,A
  LD A,(DE)
  ADD A,B
  JR C,L9862
  LD B,A
  INC HL
  INC C
  JR L984C_0

; Routine at 9862
;
; Used by the routine at L984C.
L9862:
  LD L,$00
  RET C
  INC L
  RET

; Data block at 9867
L9867:
  DEFB $04,$00,$00,$00,$00,$00,$00,$00
  DEFB $03,$80,$80,$80,$80,$00,$80,$00
  DEFB $05,$90,$90,$00,$00,$00,$00,$00
  DEFB $00,$50,$F8,$50,$50,$F8,$50,$00
  DEFB $00,$20,$F8,$A0,$F8,$28,$F8,$20
  DEFB $00,$00,$C8,$D0,$20,$58,$98,$00
  DEFB $00

; Message at 9898
L9898:
  DEFM " P X"

; Data block at 989C
L989C:
  DEFB $90,$68,$00,$03,$40,$80,$00,$00
  DEFB $00,$00,$00,$04,$20,$40,$40,$40
  DEFB $40,$20,$00,$04,$40

; Message at 98B1
L98B1:
  DEFM "    "

; Data block at 98B5
L98B5:
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

; Message at 99B1
L99B1:
  DEFM "    "

; Data block at 99B5
L99B5:
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

; Message at 9A09
L9A09:
  DEFM "     "

; Data block at 9A0E
L9A0E:
  DEFB $00,$00,$88,$88,$88,$88,$88,$70
  DEFB $00,$00,$88,$88,$88,$88,$50,$20
  DEFB $00,$00,$88,$88,$88,$88,$A8,$50
  DEFB $00,$00,$88

; Message at 9A29
L9A29:
  DEFM "P  P"

; Data block at 9A2D
L9A2D:
  DEFB $88,$00,$00,$88,$88

; Message at 9A32
L9A32:
  DEFM "P   "

; Data block at 9A36
L9A36:
  DEFB $00,$00,$F8,$08,$10,$20,$40,$F8
  DEFB $00,$05,$70,$40,$40,$40,$40,$70
  DEFB $00,$00,$00,$80,$40,$20,$10,$08
  DEFB $00,$05,$70,$10,$10,$10,$10,$70
  DEFB $00,$00,$20,$70,$A8

; Message at 9A5B
L9A5B:
  DEFM "   "

; Data block at 9A5E
L9A5E:
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
  DEFB $00,$00,$00

; Data block at 9B19
L9B19:
  DEFB $88,$88

; Message at 9B1B
L9B1B:
  DEFM "PP "

; Data block at 9B1E
L9B1E:
  DEFB $00,$00,$00,$88,$A8,$A8,$A8,$50
  DEFB $00,$00,$00,$88

; Message at 9B2A
L9B2A:
  DEFM "P P"

; Data block at 9B2D
L9B2D:
  DEFB $88,$00,$00,$00,$88,$88,$88,$78
  DEFB $08,$70,$00,$00,$F8,$10,$20,$40
  DEFB $F8,$00,$00,$38,$20,$60

; Message at 9B43
L9B43:
  DEFM "  8"

; Data block at 9B46
L9B46:
  DEFB $00,$00

; Message at 9B48
L9B48:
  DEFM "      "

; Data block at 9B4E
L9B4E:
  DEFB $00,$00,$70,$10,$18,$10,$10,$70
  DEFB $00,$05,$50,$A0,$00,$00,$00,$00
  DEFB $00,$00,$70,$A8,$C8,$C8,$A8,$70
  DEFB $00,$00,$00,$00,$00,$00,$A8,$A8
  DEFB $00,$06,$00,$00,$00,$00,$00,$00
  DEFB $00

; Routine at 9B77
;
; Used by the routine at LA2D8.
L9B77:
  XOR A
  IN A,($FE)
  AND $1F
  CP $1F
  RET NZ
  JR L9B77

; Routine at 9B81
;
; Used by the routine at L9CCF.
L9B81:
  LD BC,$FEFE
  LD DE,$0500
  LD HL,$FFE0
  IN A,(C)
  OR $E1
  CP H
  JR NZ,L9BAD
  LD E,D
  LD B,$FD
L9B81_0:
  IN A,(C)
  OR L
  CP H
  JR NZ,L9BAD
  LD A,E
  ADD A,D
  LD E,A
  RLC B
  JP M,L9B81_0
  IN A,(C)
  OR $E2
  CP H
  LD C,A
  JR NZ,L9BAD_0
  JP L9BF3

; Routine at 9BAD
;
; Used by the routine at L9B81.
L9BAD:
  LD C,A
  LD A,B
  CPL
  OR $81
  IN A,($FE)
  OR L
  CP H
  JP NZ,L9BEE
  LD A,$7F
  IN A,($FE)
  OR $E2
  CP H
  JP NZ,L9BEE
; This entry point is used by the routine at L9B81.
L9BAD_0:
  LD B,$00
  LD HL,L9B19
  ADD HL,BC
  LD A,(HL)
  CP D
  JP NC,L9BEE
  ADD A,E
  LD E,A
  LD HL,L9C19
  LD D,B
  ADD HL,DE
  LD A,$FE
  IN A,($FE)
  AND $01
  JR NZ,L9BAD_1
  LD E,$28
  ADD HL,DE
L9BAD_1:
  LD A,$7F
  IN A,($FE)
  AND $02
  JR NZ,L9BAD_2
  LD E,$50
  ADD HL,DE
L9BAD_2:
  LD L,(HL)
  LD H,B
  RET

; Routine at 9BEE
;
; Used by the routine at L9BAD.
L9BEE:
  LD HL,$0000
  SCF
  RET

; Routine at 9BF3
;
; Used by the routine at L9B81.
L9BF3:
  LD HL,$0000
  SCF
  CCF
  RET

; Data block at 9BF9
L9BF9:
  DEFB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
  DEFB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$04
  DEFB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$03
  DEFB $FF,$FF,$FF,$02,$FF,$01,$00,$FF

; Data block at 9C19
L9C19:
  DEFB $FF

; Message at 9C1A
L9C1A:
  DEFM "zxcvasdfgqwert1234509876poiuy"

; Data block at 9C37
L9C37:
  DEFB $0D

; Message at 9C38
L9C38:
  DEFM "lkjh "

; Data block at 9C3D
L9C3D:
  DEFB $FF

; Message at 9C3E
L9C3E:
  DEFM "mnb"

; Data block at 9C41
L9C41:
  DEFB $FF

; Message at 9C42
L9C42:
  DEFM "ZXCVASDFGQWERT"

; Data block at 9C50
L9C50:
  DEFB $07,$06,$80,$81,$08,$0C,$08,$09
  DEFB $0B,$0A

; Message at 9C5A
L9C5A:
  DEFM "POIUY"

; Data block at 9C5F
L9C5F:
  DEFB $0D

; Message at 9C60
L9C60:
  DEFM "LKJH "

; Data block at 9C65
L9C65:
  DEFB $FF

; Message at 9C66
L9C66:
  DEFM "MNB"

; Data block at 9C69
L9C69:
  DEFB $FF,$3A,$60,$3F,$2F,$7E,$7C,$5C
  DEFB $7B,$7D,$83,$84,$85

; Message at 9C76
L9C76:
  DEFM "<>!"

; Data block at 9C79
L9C79:
  DEFB $40,$23,$24,$25,$5F

; Message at 9C7E
L9C7E:
  DEFM ")('&\";"

; Data block at 9C84
L9C84:
  DEFB $82,$5D,$5B

; Data block at 9C87
L9C87:
  DEFB $0D,$3D,$2B,$2D,$5E,$20,$FF,$2E
  DEFB $2C,$2A,$FF,$1A,$18,$03

; Data block at 9C95
L9C95:
  DEFB $16,$01,$13,$04,$06,$07,$11,$17
  DEFB $05,$12,$14,$1B,$1C,$1D,$1E,$1F
  DEFB $7F

; Data block at 9CA6
L9CA6:
  DEFB $FF,$86,$60,$87,$10,$0F,$09,$15
  DEFB $19,$0D,$0C,$0B,$0A,$08,$20,$FF
  DEFB $0D,$0E,$02

; Routine at 9CB9
;
; Used by the routines at L8E46 and L9CCF.
L9CB9:
  LD E,$00
  LD BC,$FEFE
  IN A,(C)
  RRA
  JR C,L9CB9_0
  INC E
L9CB9_0:
  LD B,$7F
  IN A,(C)
  RRA
  RRA
  LD A,E
  RET C
  OR $02
  RET

; Routine at 9CCF
;
; Used by the routines at L8CD3, L8E46, L95AA and LA2D8.
L9CCF:
  XOR A
  IN A,($FE)
  AND $1F
  CP $1F
  JR NZ,L9CCF
  LD A,(LA3D1)
  AND $02
  RET Z
L9CCF_0:
  XOR A
  IN A,($1F)
  RET Z
  JR NZ,L9CCF_0
; This entry point is used by the routine at L9DC8.
L9CCF_1:
  LD HL,($BFA7)
  CALL LA0C2
  CP $FF
  JR Z,L9CCF_2
  AND A
  JR NZ,L9CCF_3
L9CCF_2:
  CALL L9B81
  LD A,L
  LD HL,LA3D3
  LD BC,$0005
  CPIR
  JR NZ,L9CCF_3
  INC C
  LD A,$05
  SUB C
  LD HL,L8EB2
  LD D,$00
  LD E,A
  ADD HL,DE
  LD A,(HL)
L9CCF_3:
  LD H,$00
  LD L,A
  CALL L9CB9
  LD ($BFA9),A
  LD B,A
  LD A,($BF6C)
  OR A
  JR Z,L9D25
  LD C,L
  CALL L9625
; This entry point is used by the routine at L9D38.
L9CCF_4:
  LD B,$03
  CALL LA0C3
  RET

; Routine at 9D25
;
; Used by the routine at L9CCF.
L9D25:
  LD A,L
  CP $C4
  JR Z,L9D25_0
  CP $20
  JR NZ,L9D38
  LD A,B
  AND $01
  LD A,L
  JR Z,L9D38
L9D25_0:
  CALL L8D92_0
  RET

; Routine at 9D38
;
; Used by the routine at L9D25.
L9D38:
  CP $22
  JR Z,L9D4F
  CP $40
  JR NZ,L9D38_0
  LD A,$22
L9D38_0:
  CP $21
  JR C,L9D4F
  CP $2B
  JR NC,L9D4F
  CALL L8DED_0
  JR L9CCF_4

; Routine at 9D4F
;
; Used by the routine at L9D38.
L9D4F:
  CALL L8EF8
  RET

; Routine at 9D53
L9D53:
  XOR A
  RET

; Routine at 9D55
L9D55:
  IN A,($1F)
  CP $FF
  RET Z
  LD B,$00
  LD C,A
  IN A,($1F)
  CP C
  JR Z,L9D64
  XOR A
  RET

; Routine at 9D64
;
; Used by the routine at L9D55.
L9D64:
  AND $E0
  JR Z,L9D64_0
  LD B,$C0
L9D64_0:
  LD A,C
  AND $1F
  LD E,A
  LD D,$00
  LD HL,L9D77
  ADD HL,DE
  LD A,(HL)
  OR B
  RET

; Unused
L9D77:
  DEFS $01

; Routine at 9D78
L9D78:
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
; This entry point is used by the routine at L8D05.
L9D78_0:
  CALL L971D
  LD B,$14
  CALL LA0C3
  LD A,(LA3CC)
  CALL L971D
  RET

; Routine at 9DA6
;
; Used by the routines at L96FD, L9DDB and LA344.
L9DA6:
  LD A,(LA3CD)
  CALL L9706
  LD A,(LA3CC)
  CALL L971D
  LD A,(LA3CA)
  LD C,A
  LD B,$00
  CALL L9726
  LD A,(LA3CB)
  LD C,A
  LD B,$17
  CALL L9726
  CALL L9FB8
  RET

; Routine at 9DC8
;
; Used by the routine at L84D0.
L9DC8:
  CALL L9CCF_1
  LD A,($BBE3)
  AND A
  JR Z,L9DC8
  CALL L945F
  CALL LA1C0
  CALL LA16B
  RET

; Routine at 9DDB
;
; Used by the routine at L84D0.
L9DDB:
  OR A
  JR Z,L9DDB_0
  LD HL,$3200
  LD DE,$C000
  LD BC,$0200
  LDIR
  LD A,$0A
  OUT ($E3),A
  LD HL,$C000
  LD DE,$3E00
  LD BC,$0200
  LDIR
  XOR A
  OUT ($E3),A
L9DDB_0:
  CALL LA11F
  CALL LA1CC
  CALL L8732_0
  LD HL,L9D53
  LD A,(LA3D1)
  AND $02
  JR Z,L9DDB_1
  LD HL,L9D55
L9DDB_1:
  LD ($BFA7),HL
  CALL L9DA6
  CALL L9E46
  XOR A
  LD (LA3D8),A
  CALL L8F73
  OR A
  JR Z,L9E26
  JR L9E26_1

; Routine at 9E26
;
; Used by the routine at L9DDB.
L9E26:
  CALL L8754
  CALL L9414
  OR A
  LD A,$0B
  JR NZ,L9E26_0
  OR $04
L9E26_0:
  CALL L8595
  LD A,(LA3D8)
  OR A
  JR Z,L9E44
  LD A,$03
; This entry point is used by the routine at L9DDB.
L9E26_1:
  LD B,A
  CALL L971D
  LD A,B
  RET

; Routine at 9E44
;
; Used by the routine at L9E26.
L9E44:
  LD A,$04
  CALL L9FB8_0
  XOR A
  RET

; Routine at 9E46
;
; Used by the routine at L9DDB.
L9E46:
  RST $08
  DEFB $88
  LD ($BF64),HL
  RET

; Routine at 9E4C
;
; Used by the routine at L9E66.
L9E4C:
  PUSH HL
  EXX
  POP DE
  LD B,H
  LD C,L
  LD A,$10
  LD HL,$0000
L9E4C_0:
  ADD HL,HL
  RL E
  RL D
  JR NC,L9E4C_1
  ADD HL,BC
  JR NC,L9E4C_1
  INC DE
L9E4C_1:
  DEC A
  JR NZ,L9E4C_0
  OR A
  RET

; Routine at 9E66
;
; Used by the routines at L8FE4, L904F and L9105.
L9E66:
  LD A,E
  OR D
  EXX
  OR E
  OR D
  JR Z,L9E4C
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
L9E66_0:
  RRA
  RR C
  EXX
  RR B
  RR C
  JR NC,L9E66_1
  ADD HL,DE
  EXX
  ADC HL,DE
  EXX
L9E66_1:
  SLA E
  RL D
  EXX
  RL E
  RL D
  DJNZ L9E66_0
  PUSH HL
  EXX
  POP DE
  OR A
  RET

; Routine at 9E9D
;
; Used by the routines at L8FE4 and L9093.
L9E9D:
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
  JR NC,L9EB9
  PUSH DE
  EX DE,HL
  LD HL,$0000
  CALL L9EC0
  EX DE,HL
  EX (SP),HL
  EX DE,HL
  CALL L9F34
  POP BC
  RET

; Routine at 9EB9
;
; Used by the routine at L9E9D.
L9EB9:
  CALL L9F34
  LD BC,$0000
  RET

; Routine at 9EC0
;
; Used by the routine at L9E9D.
L9EC0:
  CALL L9EC0_0
L9EC0_0:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9EC0_1
  ADD HL,BC
  INC DE
L9EC0_1:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9EC0_2
  ADD HL,BC
  INC DE
L9EC0_2:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9EC0_3
  ADD HL,BC
  INC DE
L9EC0_3:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9EC0_4
  ADD HL,BC
  INC DE
L9EC0_4:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9EC0_5
  ADD HL,BC
  INC DE
L9EC0_5:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9EC0_6
  ADD HL,BC
  INC DE
L9EC0_6:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9EC0_7
  ADD HL,BC
  INC DE
L9EC0_7:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9EC0_8
  ADD HL,BC
  INC DE
L9EC0_8:
  RET

; Routine at 9F34
;
; Used by the routines at L9E9D and L9EB9.
L9F34:
  CALL L9F34_0
L9F34_0:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F34_1
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F34_2
L9F34_1:
  ADD HL,BC
  INC DE
L9F34_2:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F34_3
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F34_4
L9F34_3:
  ADD HL,BC
  INC DE
L9F34_4:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F34_5
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F34_6
L9F34_5:
  ADD HL,BC
  INC DE
L9F34_6:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F34_7
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F34_8
L9F34_7:
  ADD HL,BC
  INC DE
L9F34_8:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F34_9
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F34_10
L9F34_9:
  ADD HL,BC
  INC DE
L9F34_10:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F34_11
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F34_12
L9F34_11:
  ADD HL,BC
  INC DE
L9F34_12:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F34_13
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F34_14
L9F34_13:
  ADD HL,BC
  INC DE
L9F34_14:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F34_15
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F34_16
L9F34_15:
  ADD HL,BC
  INC DE
L9F34_16:
  RET

; Routine at 9FB8
;
; Used by the routines at L8A77 and L9DA6.
L9FB8:
  LD A,$0F
; This entry point is used by the routines at L8C30 and L8D4D.
L9FB8_0:
  LD IXl,A
  AND $08
  JR Z,L9FB8_2
  LD A,($BBE5)
  AND A
  LD A,$20
  JR NZ,L9FB8_1
  XOR A
L9FB8_1:
  LD (LA0B0),A
  LD HL,LA0A1
  LD C,$00
  CALL LA076
L9FB8_2:
  LD A,IXl
  AND $04
  JR Z,L9FF7
  LD DE,LA098
  LD HL,($BBEF)
  INC HL
  CALL LA07C
  LD DE,LA09C
  LD HL,($BBE9)
  CALL LA07C
  LD HL,LA098
  LD C,$0F
  CALL LA076
  JR L9FF7_0

; Routine at 9FF7
;
; Used by the routine at L9FB8.
L9FF7:
  LD A,IXl
  AND $02
  JR Z,L9FF7_3
; This entry point is used by the routine at L9FB8.
L9FF7_0:
  LD B,$04
  LD C,$01
  LD HL,LA093
  LD E,$30
L9FF7_1:
  LD D,$2D
  LD A,($BBE2)
  AND C
  JR Z,L9FF7_2
  LD D,E
L9FF7_2:
  LD (HL),D
  INC HL
  SLA C
  INC E
  DJNZ L9FF7_1
  LD HL,LA093
  LD C,$15
  CALL LA076
L9FF7_3:
  LD A,(LA3D1)
  AND $40
  RET Z
  LD B,$05
  LD DE,$50FA
L9FF7_4:
  PUSH BC
  LD HL,LA0B5
  LD B,$08
  LD C,D
L9FF7_5:
  LD A,(HL)
  LD (DE),A
  INC HL
  INC D
  DJNZ L9FF7_5
  INC E
  LD D,C
  POP BC
  DJNZ L9FF7_4
  LD A,(LA3CB)
  AND $F8
  LD C,A
  AND $40
  JR Z,L9FF7_7
  LD B,$03
  LD HL,LA0BE
L9FF7_6:
  LD A,(HL)
  OR $40
  LD (HL),A
  INC HL
  DJNZ L9FF7_6
  LD A,C
L9FF7_7:
  LD HL,LA0BD
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
  LD HL,LA0C1
  LD A,(HL)
  OR C
  LD (HL),A
  LD HL,LA0BD
  LD DE,$5AFA
  LD BC,$0005
  LDIR
  RET

; Routine at A076
;
; Used by the routines at L9FB8 and L9FF7.
LA076:
  LD B,$17
  CALL L97B4
  RET

; Routine at A07C
;
; Used by the routine at L9FB8.
LA07C:
  LD BC,$FF9C
  CALL LA07C_0
  LD C,$F6
  CALL LA07C_0
  LD C,B
LA07C_0:
  LD A,$2F
LA07C_1:
  INC A
  ADD HL,BC
  JR C,LA07C_1
  SBC HL,BC
  LD (DE),A
  INC DE
  RET

; Message at A093
LA093:
  DEFM "    "

; Data block at A097
LA097:
  DEFB $00

; Message at A098
LA098:
  DEFM "000/"

; Message at A09C
LA09C:
  DEFM "000"

; Data block at A09F
LA09F:
  DEFB $81,$00

; Message at A0A1
LA0A1:
  DEFM ".browse v1.02a2"

; Data block at A0B0
LA0B0:
  DEFB $20

; Message at A0B1
LA0B1:
  DEFM "NMI"

; Data block at A0B4
LA0B4:
  DEFB $00

; Data block at A0B5
LA0B5:
  DEFB $01,$03,$07,$0F,$1F,$3F,$7F

; Data block at A0BC
LA0BC:
  DEFB $FF

; Data block at A0BD
LA0BD:
  DEFB $02

; Data block at A0BE
LA0BE:
  DEFB $16,$34,$25

; Data block at A0C1
LA0C1:
  DEFB $28

; Routine at A0C2
;
; Used by the routines at L8F13 and L9CCF.
LA0C2:
  JP (HL)

; Routine at A0C3
;
; Used by the routines at L8C30, L8F13, L9CCF and L9D78.
LA0C3:
  EI
LA0C3_0:
  HALT
  DJNZ LA0C3_0
  DI
  RET

; Routine at A0C9
;
; Used by the routines at L94FC and LA2D8.
LA0C9:
  XOR A
  IN A,($FE)
  AND $1F
  CP $1F
  JR NZ,LA0C9
  EI
LA0C9_0:
  HALT
  XOR A
  IN A,($FE)
  CPL
  AND $1F
  JR NZ,LA0C9_1
  DJNZ LA0C9_0
LA0C9_1:
  DI
  RET

; Routine at A0E0
;
; Used by the routines at L857E, L877C and LA20E.
LA0E0:
  LD A,(DE)
  OR A
  JR Z,LA0E7
  INC DE
  JR LA0E0

; Routine at A0E7
;
; Used by the routine at LA0E0.
LA0E7:
  LD C,$00
LA0E7_0:
  LD A,(HL)
  LD (DE),A
  AND A
  RET Z
  INC C
  INC HL
  INC DE
  JR LA0E7_0

; Routine at A0F2
LA0F2:
  RET

; Routine at A0F3
;
; Used by the routine at L8808.
LA0F3:
  LD A,(HL)
  OR A
  JR Z,LA11D
; This entry point is used by the routine at LA105.
LA0F3_0:
  LD A,(DE)
  CP (HL)
  JR Z,LA105
  INC DE
  OR A
  JR NZ,LA0F3_0
; This entry point is used by the routine at LA105.
LA0F3_1:
  EX DE,HL
  LD HL,$0000
  SCF
  RET

; Routine at A105
;
; Used by the routine at LA0F3.
LA105:
  PUSH DE
  PUSH HL
  EX DE,HL
LA105_0:
  INC DE
  INC HL
  LD A,(DE)
  OR A
  JR Z,LA11A
  CP (HL)
  JR Z,LA105_0
  LD A,(HL)
  POP HL
  POP DE
  INC DE
  OR A
  JR NZ,LA0F3_0
  JR LA0F3_1

; Routine at A11A
;
; Used by the routine at LA105.
LA11A:
  POP DE
  POP HL
  RET

; Routine at A11D
;
; Used by the routine at LA0F3.
LA11D:
  EX DE,HL
  RET

; Routine at A11F
;
; Used by the routine at L9DDB.
LA11F:
  XOR A
  LD (LA1B1),A
  LD (LA1B2),A
  LD BC,$FC3B
  LD A,$FF
  OUT (C),A
  LD L,$00
LA11F_0:
  LD BC,$FD3B
  IN A,(C)
  AND A
  JR Z,LA142
  CP $20
  JR C,LA142
  CP $80
  JR NC,LA142
  INC L
  JR LA11F_0

; Routine at A142
;
; Used by the routine at LA11F.
LA142:
  LD A,L
  CP $02
  RET C
  LD A,$01
  LD (LA1B1),A
  LD BC,$FC3B
  LD A,$40
  OUT (C),A
  XOR A
  LD BC,$FD3B
  IN A,(C)
  LD (LA1B2),A
  AND A
  RET Z
  LD BC,$FC3B
  LD A,$40
  OUT (C),A
  XOR A
  LD BC,$FD3B
  OUT (C),A
  RET

; Routine at A16B
;
; Used by the routine at L9DC8.
LA16B:
  LD A,(LA1B1)
  AND A
  RET Z
  LD A,(LA1B2)
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

; Routine at A184
;
; Used by the routines at L8595, L8668, L8680 and L870F.
LA184:
  LD A,(LA1B1)
  AND A
  RET Z
  LD BC,$FC3B
  LD A,L
  AND A
  JR NZ,LA19D
  LD A,$0B
  OUT (C),A
  LD A,(LA1B3)
  LD BC,$FD3B
  OUT (C),A
  RET

; Routine at A19D
;
; Used by the routine at LA184.
LA19D:
  LD A,$0B
  OUT (C),A
  LD BC,$FD3B
  IN A,(C)
  LD (LA1B3),A
  OR $C0
  LD BC,$FD3B
  OUT (C),A
  RET

; Unused
LA1B1:
  DEFS $01

; Data block at A1B2
LA1B2:
  DEFB $00

; Data block at A1B3
LA1B3:
  DEFB $00

; Routine at A1B4
;
; Used by the routines at LA1C0 and LA1CC.
LA1B4:
  LD BC,$BF3B
  OUT (C),D
  NOP
  LD BC,$FF3B
  OUT (C),E
  RET

; Routine at A1C0
;
; Used by the routine at L9DC8.
LA1C0:
  LD A,(LA1E6)
  AND A
  RET Z
  LD DE,$4001
  CALL LA1B4
  RET

; Routine at A1CC
;
; Used by the routine at L9DDB.
LA1CC:
  LD BC,$BF3B
  LD A,$40
  OUT (C),A
  NOP
  LD BC,$FF3B
  IN A,(C)
  LD (LA1E6),A
  AND A
  RET Z
  LD DE,$4000
  CALL LA1B4
  RET

; Routine at A1E5
LA1E5:
  RET

; Data block at A1E6
LA1E6:
  DEFB $00

; Message at A1E7
LA1E7:
  DEFM "Err"

; Routine at A1EA
LA1EA:
  LD L,A
  LD (HL),D

; Data block at A1EC
LA1EC:
  DEFB $21,$00

; Data block at A1EE
LA1EE:
  DEFB $50

; Routine at A1EF
LA1EF:
  LD L,H
  LD (HL),L
  LD H,A
  LD L,C
  LD L,(HL)

; Data block at A1F4
LA1F4:
  DEFB $3A,$00

; Routine at A1F6
;
; Used by the routines at L8D2E, L8DB5, L8DED, L8E46, L8E63 and L96D2.
LA1F6:
  LD A,$5F
  LD DE,LA365
  PUSH DE
  LD (DE),A
  INC DE
  LD BC,$0003
  LDIR
  POP HL
  CALL LA20E
  LD HL,LA357
  CALL LA22A
  RET

; Routine at A20E
;
; Used by the routines at L877C and LA1F6.
LA20E:
  LD DE,LA37C
  XOR A
  LD (DE),A
  PUSH DE
  CALL LA0E0
  POP DE
  LD HL,L8723
  CALL LA0E0
  RET

; Routine at A21F
;
; Used by the routine at L883B.
LA21F:
  LD DE,$50F8
  LD B,$08
  XOR A
LA21F_0:
  LD (DE),A
  INC D
  DJNZ LA21F_0
  RET

; Routine at A22A
;
; Used by the routines at L877C and LA1F6.
LA22A:
  XOR A
  LD (LA3AF),A
  LD A,($5B5C)
  AND A
  JR NZ,LA22A_0
  LD A,$10
LA22A_0:
  LD (LA3B3),A
  LD A,($BBE5)
  LD (LA3B4),A
  AND A
  LD A,$02
  JR Z,LA22A_1
  PUSH HL
  LD HL,($BBF1)
  LD BC,$001E
  ADD HL,BC
  LD A,(HL)
  LD (LA3B3),A
  POP HL
  XOR A
LA22A_1:
  LD (LA269),A
  LD (LA2D7),A
  PUSH HL
  LD A,$8C
  OUT ($E3),A
  LD HL,$8000
  LD DE,$2000
  LD BC,$2000
  LDIR

; Data block at A268
LA268:
  DEFB $3E

; Data block at A269
LA269:
  DEFB $00

; Routine at A26A
LA26A:
  ADD A,$80
  OUT ($E3),A
  POP HL
  LD DE,$8000
  LD BC,$0000
  CALL L93CB
  XOR A
  OR L
  JR Z,LA26A_2
  LD A,($8006)
  LD E,A
  AND $01
  JR Z,LA26A_0
  LD HL,LA3CA
  LD DE,$8008
  LD BC,$000E
  LDIR
LA26A_0:
  LD HL,LA36A
  LD DE,LA3BA
  LD BC,$0000
  CALL L93CB
  LD DE,LA3BA
  LD A,H
  OR L
  JR NZ,LA26A_1
  LD DE,$0000
LA26A_1:
  LD HL,$BBF3
  LD BC,LA3B3
  CALL $8000
LA26A_2:
  LD (LA3AF),A
  LD (LA3B0),BC
  AND $D0
  JR Z,LA26A_3
  LD A,B
  OR C
  JR Z,LA26A_3
  LD H,B
  LD L,C
  LD DE,LA385
  LD BC,$002A
  LDIR
LA26A_3:
  LD A,$8C
  OUT ($E3),A
  LD HL,$2000
  LD DE,$8000
  LD BC,$2000
  LDIR

; Data block at A2D6
LA2D6:
  DEFB $3E

; Data block at A2D7
LA2D7:
  DEFB $00

; Routine at A2D8
LA2D8:
  ADD A,$80
  OUT ($E3),A
  LD A,(LA3AF)
  AND $80
  JR Z,LA2D8_0
  LD HL,LA1E7
  CALL L8C5B
  LD HL,LA385
  LD BC,$1600
  CALL L97B4
  CALL L9CCF
  CALL L9B77
  CALL L9CCF
  CALL LA33E
LA2D8_0:
  LD A,(LA3AF)
  AND $10
  JR Z,LA2D8_1
  LD HL,LA1EE
  CALL L8C5B
  LD HL,LA385
  LD BC,$1600
  CALL L97B4
  LD B,$60
  CALL LA0C9
  CALL LA33E
LA2D8_1:
  LD A,(LA3AF)
  AND $04
  JR Z,LA2D8_2
  CALL LA351
LA2D8_2:
  LD A,(LA3AF)
  AND $02
  JR Z,LA2D8_3
  LD A,(LA3AF)
  AND $08
  JR NZ,LA2D8_3
  LD A,(LA3B2)
  AND A
  JR NZ,LA2D8_3
  CALL LA344
LA2D8_3:
  RET

; Routine at A33E
;
; Used by the routine at LA2D8.
LA33E:
  LD L,$00
  CALL L8C80
  RET

; Routine at A344
;
; Used by the routines at L8861 and LA2D8.
LA344:
  CALL L9DA6
  LD A,$09
  CALL L8595
  XOR A
  LD (LA3B2),A
  RET

; Routine at A351
;
; Used by the routine at LA2D8.
LA351:
  LD A,$0A
  CALL L8595
  RET

; Message at A357
LA357:
  DEFM "/bin/bplugins/"

; Message at A365
LA365:
  DEFM "????"

; Data block at A369
LA369:
  DEFB $00

; Message at A36A
LA36A:
  DEFM "/bin/bplugins/cfg/"

; Data block at A37C
LA37C:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00

; Data block at A385
LA385:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00

; Data block at A3AF
LA3AF:
  DEFB $00

; Data block at A3B0
LA3B0:
  DEFB $00,$00

; Data block at A3B2
LA3B2:
  DEFB $00

; Data block at A3B3
LA3B3:
  DEFB $00

; Data block at A3B4
LA3B4:
  DEFB $00

; Data block at A3B5
LA3B5:
  DEFB $00

; Data block at A3B6
LA3B6:
  DEFB $00,$00,$00,$00

; Data block at A3BA
LA3BA:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00

; Data block at A3CA
LA3CA:
  DEFB $78

; Data block at A3CB
LA3CB:
  DEFB $47

; Data block at A3CC
LA3CC:
  DEFB $07

; Data block at A3CD
LA3CD:
  DEFB $38

; Data block at A3CE
LA3CE:
  DEFB $39

; Data block at A3CF
LA3CF:
  DEFB $68

; Data block at A3D0
LA3D0:
  DEFB $01

; Data block at A3D1
LA3D1:
  DEFB $40,$00

; Data block at A3D3
LA3D3:
  DEFB $0B,$0A,$08,$09,$0D

; Data block at A3D8
LA3D8:
  DEFB $00

