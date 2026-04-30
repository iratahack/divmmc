  ORG $84D0

; Routine at 84D0
;
; Main entry point. Saves the caller's SP via self-modifying code at L84E9. If
; $BBE5 is non-zero the stack is reset to $7FFF (DivMMC cartridge mode). Calls
; init (L9DDB) then the main event loop (L9DC8).
main:
  LD (L84E9),SP
  LD A,($BBE5)
  OR A
  JR Z,main_0
  LD SP,$7FFF
main_0:
  PUSH IY
  CALL init
  OR A
  CALL Z,main_loop
  POP IY

; Data block at 84E8
;
; LD SP operand byte. Self-modified by L84D0 to save the original SP value on
; entry.
L84E8:
  DEFB $31

; Data block at 84E9
;
; Saved stack pointer written by the LD (L84E9),SP at L84D0.
L84E9:
  DEFB $00,$00

; Routine at 84EB
;
; Stub return — placeholder or unused entry point.
L84EB:
  RET

; Routine at 84EC
;
; Calculate the address of directory entry N in the $C200 buffer. Computes HL =
; (N*18) + $C200 and stores the result in $BF62. Each 18-byte entry contains: 1
; flag byte + 11 filename chars + 2 size bytes + 2 start-cluster bytes + 2
; attribute bytes.
;
;        HL Entry index N (0-based); treated as 0 when HL = 0
; Output: HL Pointer to entry; $BF62 also updated
get_entry_ptr:
  LD A,H
  OR L
  JR Z,get_entry_ptr_0
  ADD HL,HL
  LD B,H
  LD C,L
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,BC
get_entry_ptr_0:
  LD BC,$C200
  ADD HL,BC
  LD ($BF62),HL
  RET

; Routine at 84FF
;
; Fetch the display filename for the currently selected entry. Reads the entry
; index from $BBEF, calls L84EC to compute the entry address, then L8526 to
; format the 8.3 name into $BBF3.
get_current_name:
  LD HL,($BBEF)
  CALL get_entry_ptr
  INC HL
  CALL fmt_dosname
  RET

; Routine at 850A
;
; Get FAT cluster address for a directory entry. Reads the 2-byte start-cluster
; field at offset +$0C in the 18-byte entry. If zero, returns Fc=1. Otherwise
; returns HL = $E000 + cluster with Fc=0.
;
;        HL Pointer to directory entry (base of 18-byte structure)
; Output: HL FAT sector address ($E000 + cluster), Fc=1 if cluster is zero
get_cluster_addr:
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
; Return with carry set and HL pointing to the entry. Tail of L850A when
; cluster field is zero.
L851D:
  EX DE,HL
  INC HL
  SCF
  RET

; Routine at 8521
;
; Add FAT base address $E000 to HL.
;
;        HL Cluster number
; Output: HL FAT sector address ($E000 + cluster)
L8521:
  LD DE,$E000
  ADD HL,DE
  RET

; Routine at 8526
;
; Copy and format a DOS 8.3 filename from a directory entry into the display
; buffer at DE ($BBF3). Reads up to 8 printable characters from HL, stops at
; NUL or non-printable. Tracks character count in C.
;
; HL Source: pointer to 8.3 filename in directory entry
; DE Destination buffer ($BBF3 on entry)
; C Character count (0 on entry)
fmt_dosname:
  LD DE,$BBF3
  LD C,$00
; This entry point is used by the routine at L853F.
fmt_dosname_0:
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
;
; Self-modify byte: replaced at runtime with the opcode for LD L,$12 used in
; L853F to indicate the name overflows into an extension component.
L853E:
  DEFB $3E

; Routine at 853F
;
; Continuation of filename copy. Stores character B at (DE), advances DE.
L853F:
  LD L,$12
  INC DE
; This entry point is used by the routine at fmt_dosname.
L853F_0:
  LD A,B
  LD (DE),A
  INC DE
; This entry point is used by the routine at fmt_dosname.
L853F_1:
  INC HL
  INC C
  JR fmt_dosname_0

; Routine at 8549
;
; Null-terminate the display name: writes $00 to (DE).
L8549:
  XOR A
  LD (DE),A
  RET

; Routine at 854C
;
; Trim path display. Checks LA3D1 bit 2 (dir-cache flag); if set, scans the
; directory list at $BC00 counting NUL-terminated entries and clears $BF6D /
; $BF70.
L854C:
  LD A,(LA3E5)
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
; Find the last '/' path separator in the path buffer $BC00. Scans backward
; from position C; if none found, returns without updating $BF70.
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
; Copy the last path component (after the final '/') to $BF70 using LA0E0
; append-copy.
L857E:
  INC HL
  LD DE,$BF70
  CALL strend
  LD A,C
  LD ($BF6D),A
  RET

; Message at 858A
;
; Status message "Working..." shown during long directory loads.
L858A:
  DEFM "Working..."

; Data block at 8594
;
; Directory-load progress flag byte.
L8594:
  DEFB $00

; Routine at 8595
;
; Load or refresh the directory listing. A is a flag byte: bit 2 ($04) = reset
; scroll positions; bit 1 ($02) = update display; bit 3 ($08) = suppress
; "Working..." message; bit 4 ($10) = suppress display. Calls L94AC to try the
; cache, then navigates to the stored path and builds the entry list.
;
; A Flags: $04=reset scroll, $02=update display, $08=quiet, $10=no display
load_dir:
  LD E,A
  LD L,$01
  CALL uno_bank_out
  LD A,E
  AND $04
  JR Z,load_dir_0
  LD HL,$0000
  LD ($BBEB),HL
  LD ($BBED),HL
  LD ($BBEF),HL
load_dir_0:
  PUSH DE
  CALL load_cache
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
; Display-side continuation of L8595. Shows "Working..." if needed, loads via
; L9105, then triggers rendering.
L85BC:
  PUSH DE
  LD A,E
  AND $02
  JR Z,L85BC_2
  LD A,E
  AND $08
  JR NZ,L85BC_0
  LD HL,L858A
  CALL draw_header_text
L85BC_0:
  CALL load_directory
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
  CALL render_dir_list
; This entry point is used by the routine at load_dir.
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
; Self-modify byte: replaced at runtime with an opcode used by the L8642
; entry-scan loop.
L863F:
  DEFB $21

; Data block at 8640
;
; Self-modifying pointer: current directory entry pointer used by the L85BC
; scan loop.
L8640:
  DEFB $00,$00

; Routine at 8642
;
; Advance to the next entry in the directory scan started at L85BC. Increments
; the entry pointer by 18 bytes and decrements the remaining count; loops back
; while more entries remain.
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
  CALL in_visible_range_0
  AND A
  JR NZ,L8642_1
  LD HL,($BBEF)
  LD ($BBEB),HL
L8642_1:
  LD HL,$BC00
  CALL draw_header_text

; Data block at 8666
;
; Self-modify byte: replaced at runtime with LD A,n opcode.
L8666:
  DEFB $3E

; Data block at 8667
;
; Display flags byte written by L85BC. Bit 0=directory entered, bit 1=update
; display, bit 3=quiet, bit 4=preview update.
L8667:
  DEFB $00

; Routine at 8668
;
; Handle preview-panel update. If bit 4 of L8667 is set, draws the 31-character
; preview bar (L867E). Then calls L89F4 to refresh the status display.
L8668:
  AND $10
  JR Z,L8668_0
  LD BC,$001F
  LD HL,L867E
  CALL draw_string
L8668_0:
  CALL refresh_display
; This entry point is used by the routine at L85BC.
L8668_1:
  XOR A
  LD L,A
  CALL uno_bank_out
  RET

; Data block at 867E
;
; Self-modifying two-byte parameter for the preview-bar draw call at L8668.
L867E:
  DEFB $2A,$00

; Routine at 8680
;
; Navigate to a path component inside the cached directory list at $BC00. DE
; points to the next path segment (NUL-terminated). Scans all 18-byte entries
; in HL looking for a case-insensitive name match. On match, copies
; size/cluster fields to $BF66 and calls L9105. Advances DE past the next '/'
; on each recursive entry.
;
; HL Pointer to start of directory list ($BC00)
; DE Pointer to path component string (NUL-terminated)
nav_path:
  INC HL
  LD ($BFAA),HL
  EX DE,HL
  LD A,$01
  LD ($BF89),A
  LD L,A
  CALL uno_bank_out
; This entry point is used by the routine at L8702.
nav_path_0:
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
nav_path_1:
  PUSH BC
  LD A,(HL)
  AND $01
  JR Z,L86F4_0
  PUSH HL
  LD (L8700),DE
  INC HL
  CALL fmt_dosname
  LD DE,($BFAA)
  LD HL,$BBF3
nav_path_2:
  LD A,(HL)
  CP $41
  JR C,nav_path_3
  CP $5B
  JR NC,nav_path_3
  OR $20
nav_path_3:
  LD C,A
  LD A,(DE)
  CP $41
  JR C,nav_path_4
  CP $5B
  JR NC,nav_path_4
  OR $20
nav_path_4:
  CP C
  JR NZ,L86F4
  INC DE
  INC HL
  OR A
  JR NZ,nav_path_2
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
  CALL load_directory
  JR L86FF

; Routine at 86F4
;
; Skip to next entry in the L8680 navigation scan. Advances HL by 18 bytes,
; decrements entry count BC; loops back to L8680_1 if more remain.
L86F4:
  POP HL
; This entry point is used by the routine at nav_path.
L86F4_0:
  LD BC,$0012
  ADD HL,BC
  POP BC
  DEC BC
  LD A,B
  OR C
  JR NZ,nav_path_1

; Data block at 86FF
;
; Self-modify byte: replaced at runtime with LD DE,n opcode.
L86FF:
  DEFB $11

; Data block at 8700
;
; Self-modifying pointer: current path pointer used by L8680 scan.
L8700:
  DEFB $00,$00

; Routine at 8702
;
; Append '/' to the path string at DE, then copy the pointer to $BFAA and
; advance DE into the next path component.
L8702:
  LD A,$2F
  LD (DE),A
  LD H,D
  LD L,E
  INC HL
  LD ($BFAA),HL
; This entry point is used by the routine at nav_path.
L8702_0:
  INC DE
  JP nav_path_0

; Routine at 870F
;
; Clear path-navigation state flag ($BF89 = 0) and return. Called when the DE
; path string reaches its NUL terminator.
L870F:
  XOR A
  LD ($BF89),A
  LD L,A
  CALL uno_bank_out
  RET

; Message at 8718
;
; Path string "/bin/browse" — used when loading the browse config file.
L8718:
  DEFM "/bin/browse"

; Message at 8723
;
; Extension string ".cfg" — config file extension suffix.
L8723:
  DEFM ".cfg"

; Data block at 8727
;
; NUL terminator byte following L8723.
L8727:
  DEFB $00

; Message at 8728
;
; Path prefix "/bin/brows" — used for plugin path building.
L8728:
  DEFM "/bin/brows"

; Routine at 8732
;
; Load browse configuration. Opens "/bin/browse.cfg" from the system drive '$',
; reads settings into $A3CA. Then loads the current-directory list from
; "/bin/brows" with offset $0308 into $9867.
load_config:
  LD H,L
  LD L,$66
  LD L,(HL)
  LD (HL),H
  NOP
; This entry point is used by the routine at init.
load_config_0:
  LD HL,L8718
  LD BC,$0000
  LD DE,LA3DE
  CALL file_open_read
  LD HL,L8728
  LD BC,$0308
  LD DE,L9876
  CALL file_open_read
  CALL L982E
  RET

; Routine at 8754
;
; Initialize the browser and perform a full display refresh. Clears file
; cluster fields ($BF66/$BF68), calls L8595 with flags=$02 (update display),
; navigates the directory list from $BC00, and returns.
browser_init:
  LD HL,$0000
  LD ($BF66),HL
  LD ($BF68),HL
  LD A,$02
  CALL load_dir
  LD HL,$BC00
  CALL nav_path
  RET

; Routine at 8769
;
; Find the file extension pointer in the current filename ($BBF3). Scans for
; the last '.' character; saves its address in DE.
;
;        HL Pointer to start of filename ($BBF3)
; Output: DE Pointer to '.' separator, or zero if no extension found
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
; Handle file extension. Copies the 4-byte extension from DE to $BF7D, resets
; handler pointers at LA365/LA37C, then dispatches to the appropriate plugin
; via LA357 and LA20E.
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
  LD (LA379),A
  LD (LA390),A
  LD DE,LA36B
  INC HL
  PUSH HL
  CALL strend
  POP HL
  CALL LA222
  LD HL,$0000
  LD ($BF82),HL
; This entry point is used by the routines at L8808 and L8830.
L877C_0:
  LD HL,LA36B
  CALL load_and_run_plugin
  LD A,(LA3C3)
  LD B,A
  AND $08
  JP Z,L883B
  LD A,B
  AND $02
  JR Z,L877C_1
  LD A,$01
  LD (LA3C6),A
; This entry point is used by the routine at L8808.
L877C_1:
  LD A,(LA3C4)
  CP $03
  JR NZ,L87D0
  LD HL,$0000
  LD ($BBEF),HL
  LD A,$01
  LD (LA3C4),A
  JR L87D0_0

; Routine at 87D0
;
; Adjust initial cursor position based on plugin-mode byte at LA3B0. Mode $03
; resets $BBEF to 0; mode $04 moves to the last entry; mode $01 advances $BBEF
; by one (wrapping at total count).
L87D0:
  CP $04
  JR NZ,L87D0_0
  LD HL,($BBE9)
  LD ($BBEF),HL
  LD A,$02
  LD (LA3C4),A
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
; Move cursor backward one entry. Decrements $BBEF; if it reaches zero, jumps
; to L883B (plugin boundary check).
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
; After cursor move, check if the new entry matches the search filter at $BF7D.
; Re-renders if not at a matching entry; adjusts view via L8A94_0 otherwise.
L8808:
  CALL get_current_name
  LD DE,$BBF3
  LD HL,$BF7D
  CALL strstr
  JR C,L877C_1
  LD A,(LA3C6)
  OR A
  JR NZ,L877C_0
  LD HL,($BBEF)
  CALL in_visible_range_0
  AND A
  JR NZ,L8830
  LD HL,($BBEF)
  LD ($BBEB),HL
  CALL refresh_display
  JR L8830_0

; Routine at 8830
;
; Force scroll to keep cursor visible (calls L8A94_0 with $80), then re-reads
; the current entry filename via L84FF.
L8830:
  LD A,$80
  CALL nav_end_0
; This entry point is used by the routine at L8808.
L8830_0:
  CALL get_current_name
  JP L877C_0

; Routine at 883B
;
; Handle plugin boundary / cursor at position $BF82. Computes visible-window
; bounds for a 22-entry page and updates $BBEB/$BBED/$BBEF. On return, calls
; LA344 if LA3B2 (needs-reload flag) is set.
L883B:
  CALL LA233
  LD HL,($BF82)
  LD A,H
  OR L
  JR Z,L8861_2
  PUSH HL
  CALL in_visible_range_0
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
; Set first-visible index $BBEB = 0 and last-visible $BBED = computed page end.
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
  LD A,(LA3C6)
  OR A
  RET Z
  CALL LA358
  RET

; Routine at 8877
;
; Render the full directory listing. Takes IX=entry-render callback, DE=first
; entry address, HL=first entry index, BC=page size. Calls L8909 to compute the
; starting screen position, then iterates rendering up to 22 entries.
;
; IX Pointer to per-entry render routine (e.g. L8964)
; DE Pointer to first visible entry in buffer
; HL First visible entry index
; BC Number of entries to render
render_dir_list:
  LD (L88DA),IX
  EX DE,HL
  PUSH DE
  PUSH HL
  LD (L8905),BC
  CALL L8909
  LD (L88FF),HL
; This entry point is used by the routine at L88AC.
render_dir_list_0:
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
; Render loop body: draws one entry row using the IX callback, then advances
; pointers and loops back.
L88AC:
  LD DE,(L88FB)
  POP HL
  PUSH HL
  ADD HL,DE
; This entry point is used by the routine at render_dir_list.
L88AC_0:
  LD (L88FB),HL
  EX DE,HL
  LD HL,(L88FF)
  SBC HL,DE
  JR C,render_dir_list_0
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
;
; Self-modify byte ($CD = CALL opcode) for the self-modifying CALL in L88AC.
L88D9:
  DEFB $CD

; Data block at 88DA
;
; Self-modifying call target address used by L88AC render loop.
L88DA:
  DEFB $00,$00

; Routine at 88DC
;
; Continuation of directory-list render: copies pixel row from source to
; destination, moves to next entry, loops back via L88AC.
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
;
; Saved first visible entry address (used by L88AC render loop).
L88FD:
  DEFB $00,$00

; Data block at 88FF
;
; Saved first visible entry index (used by L88AC render loop).
L88FF:
  DEFB $00,$00

; Data block at 8901
;
; Scratch pointer 1 used by L8877 render loop.
L8901:
  DEFB $00,$00

; Data block at 8903
;
; Scratch pointer 2 used by L8877 render loop.
L8903:
  DEFB $00,$00

; Data block at 8905
;
; Saved page size (BC on entry to L8877).
L8905:
  DEFB $00,$00

; Data block at 8907
;
; Saved pointer used by L88DC scroll copy.
L8907:
  DEFB $00,$00

; Routine at 8909
;
; Compute a scaled screen address offset from two packed values.
; Multiplies/shifts parameters into a screen row offset for use in the render
; loop.
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
; Shift-and-add multiplication helper. Computes HL = (A * 16 + C) or variants
; via bit accumulation.
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
;
; Directory-entry marker string "<DIR" appended to entries that are
; subdirectories.
L8929:
  DEFM "<DIR"

; Routine at 892D
;
; Check if entry index DE is within the visible window [$BBEB..$BBED]. Returns
; A=1 if visible, A=0 if outside.
;
;        HL Entry index to test (also accepts call via L892D_0 with DE)
; Output: A 1 if entry is in visible window, 0 if not
in_visible_range:
  LD A,$00
; This entry point is used by the routines at L8642, L8808, L883B, L8AA5,
; L8AC8, L8B0D, L8B3A and L8BA2.
in_visible_range_0:
  EX DE,HL
  OR A
  LD HL,($BBEB)
  SBC HL,DE
  JR Z,in_visible_range_1
  JR NC,L8945
  OR A
  LD HL,($BBED)
  SBC HL,DE
  JR C,L8945
in_visible_range_1:
  LD A,$01
  RET

; Routine at 8945
;
; Return A=0 (not in visible range). Tail of L892D.
L8945:
  XOR A
  RET

; Routine at 8947
;
; Clear the full browser screen area. Clears all 22 character rows (rows 1–22)
; by calling L978F for each. Then fills the attribute row at $5820 with the
; LA3CD background colour.
clear_screen:
  LD B,$16
  LD C,$01
clear_screen_0:
  PUSH BC
  LD B,C
  CALL clear_char_row
  POP BC
  INC C
  DJNZ clear_screen_0
  LD A,(LA3E1)
  LD HL,$5820
  LD (HL),A
  LD DE,$5821
  LD BC,$02BF
  LDIR
  RET

; Routine at 8964
;
; Compare two directory entries for ordering/matching. Reads start-cluster from
; both entries via L850A; compares 8.3 filenames case-insensitively byte by
; byte. Returns HL=0 if equal, HL=$0001 if entry 1 < entry 2, HL=$FFFF if entry
; 1 > entry 2.
;
;        HL Pointer to first directory entry
;        DE Pointer to second directory entry
; Output: HL 0=equal, $0001=less-than, $FFFF=greater-than
L8964:
  LD A,(HL)
  LD B,A
  LD A,(DE)
  CP B
  JR NZ,L899B
  EX DE,HL
  PUSH DE
  CALL get_cluster_addr
  EX DE,HL
  POP HL
  PUSH DE
  CALL get_cluster_addr
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
; Return H = (A minus C) as comparison result.
L8998:
  SUB C
  LD H,A
  RET

; Routine at 899B
;
; Return HL=$FFFF (less-than result for entry type mismatch: dir vs file).
L899B:
  AND $01
  JR Z,L89A3
  LD HL,$FFFF
  RET

; Routine at 89A3
;
; Return HL=$0001 (greater-than result for entry type mismatch).
L89A3:
  LD HL,$0001
  RET

; Routine at 89A7
;
; Select and write the display attribute for screen row B. Bit 7 of C =
; selected/cursor row (uses LA3CF colour); bit 0 = directory (uses LA3CE
; colour); else normal colour from LA3CD. Calls L9726 to fill the 32-column
; attribute row.
;
; B Screen row number (1–22)
; C Attribute flags: bit 7 = cursor/selected, bit 0 = is directory
draw_row_attr:
  LD A,C
  AND $80
  JR Z,L89B1
  LD A,(LA3E3)
  JR L89BB_0

; Routine at 89B1
;
; Select attribute for a non-cursor row. Checks bit 0 for directory colour.
L89B1:
  LD A,C
  AND $01
  JR Z,L89BB
  LD A,(LA3E2)
  JR L89BB_0

; Routine at 89BB
;
; Fill attribute row B with colour C via L9726.
L89BB:
  LD A,(LA3E1)
; This entry point is used by the routines at draw_row_attr and L89B1.
L89BB_0:
  LD C,A
  CALL fill_attr_row
  RET

; Routine at 89C3
;
; Render a single directory entry at screen row B. Loads the entry address from
; $BF62, gets the filename via L850A/L8526, draws the name using L97B4, then
; appends the "<DIR" marker if entry flag bit 0 is set and LA3D1 bit 0 is set.
;
; B Screen row number (1–22)
; C Attribute flags (bit 7=selected, bit 0=directory)
render_entry:
  PUSH BC
  LD HL,($BF62)
  CALL get_cluster_addr
  JR NC,render_entry_0
  CALL fmt_dosname
  LD HL,$BBF3
render_entry_0:
  POP BC
  PUSH BC
  LD C,$00
  CALL draw_string
  POP BC
  LD A,C
  AND $01
  JR Z,L89EC_0
  LD A,(LA3E5)
  AND $01
  JR Z,L89EC_0
  PUSH BC
  LD HL,L8929

; Data block at 89EA
;
; Self-modify byte: source screen-row offset for L89EC row copy.
L89EA:
  DEFB $0E

; Data block at 89EB
;
; Self-modify byte: destination row offset for L89EC row copy. Also holds the
; pixel width of the "<DIR" string (set by L981F).
L89EB:
  DEFB $1C

; Routine at 89EC
;
; Copy one character row on screen (scrolling optimisation). Calls L97B4 via
; L89A7 to update the attribute.
L89EC:
  CALL draw_string
  POP BC
; This entry point is used by the routine at render_entry.
L89EC_0:
  CALL draw_row_attr
  RET

; Routine at 89F4
;
; Conditional display refresh. If $BBE6 (preview flag) is non-zero, calls L96D2
; (preview panel update); otherwise calls L89FE (full redraw).
refresh_display:
  LD A,($BBE6)
  AND A
  JR Z,render_all_entries
  CALL render_preview
  RET

; Routine at 89FE
;
; Full redraw of all visible directory entries. Iterates from $BBEB (first
; visible index) for up to 22 entries. For each: calls L89C3 to render,
; advances the entry pointer by 18 bytes, updates $BBED (last-visible index).
; Calls L9FB8 at the end to redraw the status bar.
render_all_entries:
  LD HL,($BF62)
  PUSH HL
  LD A,$01
  LD (L8A7F),A
  LD A,($BBE4)
  AND A
  JR Z,render_all_entries_0
  LD C,$00
  LD B,A
  CALL draw_row_attr
render_all_entries_0:
  CALL clear_screen
  OR A
  LD HL,($BBE9)
  LD D,H
  LD E,L
  LD BC,($BBEF)
  SBC HL,BC
  JR NZ,render_all_entries_1
  EX DE,HL
  DEC HL
  LD ($BBEF),HL
render_all_entries_1:
  LD HL,($BBEB)
  CALL get_entry_ptr
  LD BC,($BBEB)
render_all_entries_2:
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
  JR NZ,render_all_entries_3
  LD A,D
  LD ($BBE4),A
  LD A,E
  LD ($BBE8),A
  OR $80
render_all_entries_3:
  LD B,D
  LD C,A
  CALL render_entry
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
  JR render_all_entries_2

; Routine at 8A77
;
; Restore $BF62 to the saved value from before the render loop, then call L9FB8
; (status bar update).
L8A77:
  CALL update_status_bar
  POP HL
  LD ($BF62),HL
  RET

; Unused
L8A7F:
  DEFS $01

; Routine at 8A80
;
; Move cursor to the first entry (Home). Passes command $03 to L8A94_0.
nav_home:
  LD A,$03
  JR nav_end_0

; Routine at 8A84
;
; Page up. Passes command $04 to L8A94_0.
nav_pgup:
  LD A,$04
  JR nav_end_0

; Routine at 8A88
;
; Move cursor up one entry. Passes command $01 to L8A94_0.
nav_up:
  LD A,$01
  JR nav_end_0

; Routine at 8A8C
;
; Move cursor down one entry. Passes command $02 to L8A94_0.
nav_down:
  LD A,$02
  JR nav_end_0

; Routine at 8A90
;
; Page down. Passes command $05 to L8A94_0.
nav_pgdn:
  LD A,$05
  JR nav_end_0

; Routine at 8A94
;
; Move cursor to the last entry (End). Passes command $06 to L8A94_0. Entry
; point L8A94_0 dispatches on A: $01=cursor up, $02=cursor down, $03=home,
; $04=end, $05=page up, $06=page down, $80=force-scroll to keep cursor visible.
nav_end:
  LD A,$06
; This entry point is used by the routines at L8830, nav_home, nav_pgup,
; nav_up, nav_down and nav_pgdn.
nav_end_0:
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
; Handle home command ($03). Checks if first entry is already visible; if so
; just updates $BBEF, otherwise resets $BBEB/$BBED to show from the top.
L8AA5:
  CP $03
  JR NZ,L8AC8
  LD DE,$0000
  PUSH DE
  EX DE,HL
  CALL in_visible_range_0
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
; Handle end command ($04). Moves to the last entry (($BBE9)-1); adjusts
; $BBEB/$BBED so the last entry is visible.
L8AC8:
  CP $04
  JR NZ,L8AF4
  LD DE,($BBE9)
  DEC DE
; This entry point is used by the routine at L8AF4.
L8AC8_0:
  PUSH DE
  EX DE,HL
  CALL in_visible_range_0
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
; Handle page-down command ($06). Advances $BBEF by one page (22 entries),
; clamped to the last entry.
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
; Handle page-up command ($05). Moves $BBEF back one page (22 entries), clamped
; to 0.
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
  CALL in_visible_range_0
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
; Handle cursor-up command ($01). Decrements $BBEF; if the new entry would
; scroll off the top, decrements $BBEB and $BBED and scrolls the display up one
; row.
L8B3A:
  CP $01
  JR NZ,L8BA2
  LD A,D
  OR E
  JP Z,L8BA2_1
  DEC DE
  PUSH DE
  EX DE,HL
  CALL in_visible_range_0
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
  CALL draw_row_attr
  XOR A
  LD ($BBE4),A
  LD B,$15
  LD C,$16
L8B3A_1:
  PUSH BC
  LD A,B
  LD B,C
  LD C,A
  CALL copy_char_row
  POP BC
  DEC C
  DJNZ L8B3A_1
  LD B,$01
  CALL clear_char_row
  POP DE
  LD H,D
  LD L,E
  CALL get_entry_ptr
  PUSH DE
  LD A,(HL)
  LD B,$01
  LD C,A
  CALL render_entry
  POP DE
  JR L8BA2_1

; Routine at 8BA2
;
; Handle cursor-down command ($02). Increments $BBEF; if the new entry would
; scroll off the bottom, increments $BBEB and $BBED and scrolls the display
; down one row.
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
  CALL in_visible_range_0
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
  CALL draw_row_attr
  XOR A
  LD ($BBE4),A
  LD B,$15
  LD C,$01
L8BA2_0:
  PUSH BC
  LD B,C
  INC C
  CALL copy_char_row
  POP BC
  INC C
  DJNZ L8BA2_0
  LD B,$16
  CALL clear_char_row
  POP DE
  LD H,D
  LD L,E
  CALL get_entry_ptr
  PUSH DE
  LD A,(HL)
  LD B,$16
  LD C,A
  CALL render_entry
  POP DE
; This entry point is used by the routines at L8AA5, L8AC8, L8B0D and L8B3A.
L8BA2_1:
  LD C,$00
; This entry point is used by the routines at L8AA5, L8AC8 and L8B0D.
L8BA2_2:
  LD HL,($BBEF)
; This entry point is used by the routine at nav_end.
L8BA2_3:
  OR A
  SBC HL,DE
  RET Z
  LD ($BBEF),DE
  LD A,($BBE6)
  AND A
  JR Z,L8C16
  CALL render_preview
  RET

; Routine at 8C16
;
; After navigation, update the display attribute for the previously highlighted
; row, then call L89F4 (refresh) or L8C30 (redraw cursor row).
L8C16:
  LD A,($BBE4)
  AND A
  JR Z,L8C16_0
  PUSH BC
  PUSH DE
  LD B,A
  LD A,($BBE8)
  LD C,A
  CALL draw_row_attr
  POP DE
  POP BC
L8C16_0:
  LD A,C
  AND A
  JR Z,L8C35
  CALL refresh_display
  LD A,$04
  CALL update_status_bar_0
  RET

; Routine at 8C35
;
; Recompute cursor row position on screen ($BBE4 = selection - first_visible +
; 1) and render the new cursor row with L89C3.
L8C35:
  EX DE,HL
  LD DE,($BBEB)
  OR A
  SBC HL,DE
  INC L
  LD A,L
  LD ($BBE4),A
  LD D,A
  LD HL,($BBEF)
  CALL get_entry_ptr
  LD A,(HL)
  LD ($BBE8),A
  OR $80
  LD C,A
  LD A,D
  LD B,A
  CALL draw_row_attr
  LD A,$04
  CALL update_status_bar_0
  LD B,$03
  CALL wait_frames
  RET

; Routine at 8C60
;
; Draw the bottom two status lines (rows $15/$16) with background colour from
; LA3CA/LA3CF.
L8C60:
  PUSH HL
  LD B,$15
  CALL clear_char_row
  LD B,$16
  CALL clear_char_row
  LD B,$15
  LD A,(LA3DE)
  LD C,A
  CALL fill_attr_row
  LD B,$16
  LD A,(LA3E3)
  LD C,A
  CALL fill_attr_row
  POP HL
  LD BC,$1500
  CALL draw_string
  RET

; Routine at 8C85
;
; Conditional directory refresh. If L=0 and fewer than 20 entries, clears
; status area (L8C96); otherwise calls L8595 with flags=$03 (reset+update).
;
; L 0 = full-refresh check, non-zero = always call L8595
L8C85:
  LD A,L
  AND A
  JR NZ,L8C85_0
  LD B,$00
  LD C,$14
  LD HL,($BBE9)
  OR A
  SBC HL,BC
  JR C,L8C9B
L8C85_0:
  LD A,$03
  CALL load_dir
  RET

; Routine at 8C9B
;
; Clear the bottom two status rows ($15 and $16) with the background colour
; from LA3CD.
L8C9B:
  LD B,$15
  CALL clear_char_row
  LD B,$16
  CALL clear_char_row
  LD B,$15
  LD A,(LA3E1)
  LD C,A
  CALL fill_attr_row
  LD B,$16
  LD A,(LA3E1)
  LD C,A
  CALL fill_attr_row
  RET

; Routine at 8CB8
;
; Draw a NUL-terminated string in the header row (row 0). Clears row 0 first
; via L978F, then renders the string with L97B4.
;
; HL Pointer to NUL-terminated string to display in header row
draw_header_text:
  PUSH HL
  LD B,$00
  CALL clear_char_row
  POP HL
  LD BC,$0000
  CALL draw_string
  RET

; Routine at 8CC6
;
; Copy entry cluster/size fields then reload directory. Copies 4 bytes from
; HL+BC to $BF66, then calls L8595 with flags=$07 (full reload).
L8CC6:
  ADD HL,BC
  LD DE,$BF66
  LDI
  LDI
  LDI
  LDI
; This entry point is used by the routine at L8DF7.
L8CC6_0:
  LD A,$07
  CALL load_dir
  RET

; Routine at 8CD8
;
; Enter a directory or execute the currently selected file. Changes to
; directory "$BBF3" using esxDOS f_chdir ($A9). On success reloads the
; directory list; on error (carry) jumps to L8D05. For ".." entries (flag bit
; 0, name starts with '.'), calls L8CC1 to process parent-directory navigation.
enter_item:
  LD A,$2A
  LD HL,L8D15
  RST $08
  DEFB $A9
  JR C,L8D0F
  CALL L854C
  LD HL,$0000
  CALL get_entry_ptr
  LD A,(HL)
  AND $01
  RET Z
  INC HL
  LD A,(HL)
  CP $2E
  RET NZ
  LD BC,$000D
  CALL L8CC6
  LD A,L
  AND A
  JR NZ,L8D06
  LD A,$04
  CALL update_status_bar_0
  CALL wait_key
  RET

; Routine at 8D06
;
; After entering directory: reload from root ($BC00) using esxDOS f_chdir, then
; exit with colour-flash code $03.
L8D06:
  LD HL,$BC00
  RST $08
  DEFB $A9
  LD A,$03
  JR L8D0F_0

; Routine at 8D0F
;
; Flash border then wait. Calls L9D78_0 to flash the border with an
; error/status colour.
L8D0F:
  LD A,$02
; This entry point is used by the routine at L8D06.
L8D0F_0:
  CALL L9D87_0
  RET

; Routine at 8D15
;
; Self-modifying entry stub: first byte is $2E ('.'), second byte is NOP.
; Continues to L8D0E (open INF plugin for current file).
L8D15:
  LD L,$2E
  NOP
L8D15_0:
  LD HL,L8F4D
  CALL L8E87
  RET

; Routine at 8D1F
;
; Open POK (memory patcher) plugin if $BBE5 (cartridge flag) is set. Passes
; extension "POK" to LA1F6.
L8D1F:
  LD A,($BBE5)
  OR A
  RET Z
  LD HL,L8F4A
  JR L8D38_0

; Routine at 8D29
;
; Open LOK (file locker) plugin. Passes extension "LOK" to LA1F6.
L8D29:
  LD HL,L8F5F
  JR L8D38_0

; Routine at 8D2E
;
; Open TPE (tape-player emulator) plugin. Passes extension "TPE" to LA1F6.
L8D2E:
  LD HL,L8F59
  JR L8D38_0

; Routine at 8D33
;
; Open HLP (help viewer) plugin. Passes extension "HLP" to LA1F6.
L8D33:
  LD HL,L8F41
  JR L8D38_0

; Routine at 8D38
;
; Open UNO extension plugin if LA1B1 (UNO/Next device flag) is set. Passes
; extension "UNO" to LA1F6.
L8D38:
  LD A,(LA1C5)
  AND A
  RET Z
  LD HL,L8F5C
; This entry point is used by the routines at L8D1F, L8D29, L8D2E, L8D33 and
; L8D44.
L8D38_0:
  CALL invoke_plugin
  RET

; Routine at 8D44
;
; Open SNA (snapshot manager) plugin if $BBE5 (cartridge flag) is set. Copies
; $BBF1 to LA3B6, passes extension "SNA".
L8D44:
  LD A,($BBE5)
  AND A
  RET Z
  LD HL,($BBF1)
  LD (LA3CA),HL
  LD HL,L8F50
  JR L8D38_0

; Routine at 8D54
;
; Open AXE plugin with mode byte = 0. Falls through to L8D4D_0.
L8D54:
  XOR A
  JR L8D57_0

; Routine at 8D57
;
; Open ASM/AXE plugin with mode byte = 1. Sets LA3B5=mode, LA3B6=$BBE2
; (joystick state). Calls L8E78 to dispatch.
L8D57:
  LD A,$01
; This entry point is used by the routine at L8D54.
L8D57_0:
  LD (LA3C9),A
  LD HL,$BBE2
  LD (LA3CA),HL
  LD HL,L8F6B
  CALL L8E87
  AND A
  RET Z
  LD A,$02
  CALL update_status_bar_0
  RET

; Routine at 8D70
;
; Open TAP (tape image) plugin without the $80 flag. Shares entry at L8D69_0.
L8D70:
  XOR A
  JR L8D73_0

; Routine at 8D73
;
; Open TAP plugin with the $80 flag set (streaming mode).
L8D73:
  LD A,$80
; This entry point is used by the routine at L8D70.
L8D73_0:
  OR $01
  JR L8D7C_1

; Routine at 8D79
;
; Open DOS plugin without the $80 flag. Shares entry at L8D72_0.
L8D79:
  XOR A
  JR L8D7C_0

; Routine at 8D7C
;
; Open DOS plugin with the $80 flag. Dispatches via L8E63 with extension "TAP".
L8D7C:
  LD A,$80
; This entry point is used by the routine at L8D79.
L8D7C_0:
  OR $00
; This entry point is used by the routine at L8D73.
L8D7C_1:
  LD HL,L8F53
  CALL exec_plugin
  RET

; Routine at 8D87
;
; Open DOS plugin mode $03. Dispatches via L8E63 with extension "DOS".
L8D87:
  LD A,$03
; This entry point is used by the routines at L8D90 and L8D94.
L8D87_0:
  LD HL,L8F56
  CALL exec_plugin
  RET

; Routine at 8D90
;
; Open DOS plugin mode $02.
L8D90:
  LD A,$02
  JR L8D87_0

; Routine at 8D94
;
; Open DOS plugin mode $01.
L8D94:
  LD A,$01
  JR L8D87_0

; Routine at 8D98
;
; Execute RST $18 (esxDOS ROM restart) then return. Used as a no-op reset
; bridge.
L8D98:
  RST $18
  NOP
  NOP
  RET

; Routine at 8D9C
;
; Increment the action counter at $BBE3 if $BBE5 (cartridge flag) is set. Used
; to trigger multi-step file operations.
L8D9C:
  LD HL,$BBE5
  LD A,(HL)
  OR A
  RET Z
  INC A
  LD (HL),A
; This entry point is used by the routine at L9D34.
L8D9C_0:
  LD HL,$BBE3
  INC (HL)
  RET

; Routine at 8DA9
;
; Open CLP (clipboard) plugin mode $02.
L8DA9:
  LD A,$02
  JR L8DB1_0

; Routine at 8DAD
;
; Open CLP plugin mode $01.
L8DAD:
  LD A,$01
  JR L8DB1_0

; Routine at 8DB1
;
; Open CLP plugin mode $03. Dispatches via L8E63 with extension "CLP".
L8DB1:
  LD A,$03
; This entry point is used by the routines at L8DA9 and L8DAD.
L8DB1_0:
  LD HL,L8F62
  CALL exec_plugin
  RET

; Routine at 8DBA
;
; Open HEX (hex viewer) plugin. Gets current filename via L84FF, clears screen
; row 0, renders the current entry, then dispatches via LA1F6 with extension
; "HEX".
L8DBA:
  LD HL,L8F44
  JR L8DBF_0

; Routine at 8DBF
;
; Open TXT (text viewer) plugin. Same flow as L8DB0 but with extension "TXT".
L8DBF:
  LD HL,L8F47
; This entry point is used by the routine at L8DBA.
L8DBF_0:
  PUSH HL
  CALL get_current_name
  LD B,$00
  CALL clear_char_row
  LD BC,$0000
  CALL render_entry
  LD A,(LA3DE)
  LD C,A
  LD B,$00
  CALL fill_attr_row
  POP HL
  CALL invoke_plugin
  RET

; Routine at 8DDF
;
; Toggle or open the SPD (speed/overclock) plugin. Only if $BBE5 is clear
; (non-cartridge mode); calls L8E78 with extension "SPD". On success, sets
; $BBE6=$FF and $BBE3=$01.
L8DDF:
  LD A,($BBE5)
  AND A
  RET NZ
  LD HL,L8F68
  CALL L8E87
  AND A
  RET Z
  LD A,$FF
  LD ($BBE6),A
  LD A,$01
  LD ($BBE3),A
  RET

; Routine at 8DF7
;
; Enter directory then do a full browser refresh. Calls L84FF to read the
; current name, dispatches to LA1F6 with extension "SPD". If LA3AF bit 0 is set
; afterward, calls L8754 (full reinit) and L8CC1_0 (reload).
L8DF7:
  XOR A
; This entry point is used by the routine at L9D47.
L8DF7_0:
  LD (LA3C9),A
  AND A
  JR NZ,L8DF7_1
  CALL get_current_name
L8DF7_1:
  LD HL,L8F65
  CALL invoke_plugin
  LD A,(LA3C3)
  LD B,A
  AND $01
  RET Z
  LD A,B
  PUSH AF
  CALL browser_init
  CALL L8CC6_0
  POP AF
  AND $40
  RET Z
  LD HL,LA399
  LD DE,$BBF3
  LD BC,$000D
  LDIR
  CALL L8769
  RET

; Routine at 8E29
;
; Execute or open the file at the current selection. If the entry flag bit 0 is
; set it is a directory: call f_chdir ($A9) and reload. Otherwise call L8769
; (find extension), then dispatch based on LA3AF plugin return code, or call
; L9CB9 (joystick check) to decide how to open.
exec_file:
  CALL get_current_name
  LD HL,($BF62)
  LD A,(HL)
  AND $01
  JR Z,L8E55
  LD HL,($BBEF)
  LD A,H
  OR L
  JR NZ,exec_file_0
  CALL L854C
exec_file_0:
  LD A,$2A
  LD HL,$BBF3
  RST $08
  DEFB $A9
  LD HL,($BF62)
  LD BC,$000E
  CALL L8CC6
  LD A,$04
  CALL update_status_bar_0
  JR L8E55_0

; Routine at 8E55
;
; Open-file handler. Saves bookmark, scans extension via L8769, checks LA3AF
; for plugin mode, then waits for input via L9CCF.
L8E55:
  CALL save_bookmark
  CALL L8769
  LD A,(LA3C3)
  OR A
  JR NZ,L8E55_0
  CALL read_joystick
  AND $01
  JR Z,L8E55_0
  LD HL,L8F6E
  CALL invoke_plugin
; This entry point is used by the routine at exec_file.
L8E55_0:
  CALL wait_key
  RET

; Routine at 8E72
;
; Dispatch to plugin. Stores mode byte A at LA3B5, reads current entry address
; into LA3B6, then calls LA1F6 with HL = 3-character extension string.
;
; A Plugin mode byte (stored in LA3B5)
; HL Pointer to 3-character file extension string
exec_plugin:
  LD (LA3C9),A
  PUSH HL
  CALL get_current_name
  LD HL,($BF62)
  LD (LA3CA),HL
; This entry point is used by the routine at L8E87.
exec_plugin_0:
  POP HL
  CALL invoke_plugin
  LD A,(LA3C3)
  RET

; Routine at 8E87
;
; Dispatch to plugin (simplified). Calls L84FF to read current filename, then
; enters L8E63_0.
;
; HL Pointer to 3-character extension string
L8E87:
  PUSH HL
  CALL get_current_name
  JR exec_plugin_0

; Data block at 8E8D
;
; Alphabet key dispatch table (A–Z). Each 2-byte entry is a routine address
; indexed by (key_ASCII - $41). $0000 = no action assigned to that letter key.
L8E8D:
  DEFW nav_pgup
  DEFW $0000
  DEFW L8D38
  DEFW L8D87
  DEFW L8D94
  DEFW search_toggle
  DEFW $0000
  DEFW L8D33
  DEFW L8D79
  DEFW $0000
  DEFW L8D1F
  DEFW L8DDF
  DEFW $0000
  DEFW L8D9C
  DEFW L8D70
  DEFW enter_item
  DEFW nav_home
  DEFW L8D15_0
  DEFW L8D44
  DEFW L8D2E
  DEFW L8D54
  DEFW L8DBA
  DEFW $0000
  DEFW L8D9C_0
  DEFW $0000
  DEFW update_cache

; Data block at 8EC1
;
; Special key code lookup table (24 bytes). Key codes checked by L8EF8 via
; CPIR: cursor keys remapped from LA3D3, plus function-key codes for plugins,
; navigation, search, and cache operations.
L8EC1:
  DEFB $01,$02,$04,$08,$80,$0C,$C0,$C1
  DEFB $C2,$3F,$85,$7B,$82,$3D,$3B,$22
  DEFB $3C,$3E,$5D,$2F,$60,$3A,$5F,$FF

; Data block at 8ED9
;
; Special key action routine pointer table (23 entries, 2 bytes each). Parallel
; to L8EB2: each word is the routine called when the corresponding key code is
; matched. $0000 = no action.
L8ED9:
  DEFW nav_up
  DEFW nav_down
  DEFW nav_pgdn
  DEFW nav_end
  DEFW exec_file
  DEFW enter_item
  DEFW enter_item
  DEFW nav_home
  DEFW nav_pgup
  DEFW L8DAD
  DEFW $0000
  DEFW L96FA_0
  DEFW L8D7C
  DEFW L8D29
  DEFW L8D73
  DEFW L8DB1
  DEFW L8D90
  DEFW L8DA9
  DEFW L8D57
  DEFW L8DBF
  DEFW L8D98
  DEFW L94E7
  DEFW L8DF7

; Routine at 8F07
;
; Key dispatch. Searches the incoming key code in the L8EB2 table (24 entries)
; using CPIR. If found, indexes L8ECA to get the action routine and calls it.
; If not found and key is an uppercase letter ($41–$5A), indexes the alphabet
; table L8E7E.
;
; A Key code byte from the keyboard scanner
key_dispatch:
  LD D,A
  LD HL,L8EC1
  LD BC,$0018
  CPIR
  LD A,B
  OR C
  LD A,D
  JR Z,L8F22
  OR A
  LD HL,$0017
  SBC HL,BC
  ADD HL,HL
  LD DE,L8ED9
  ADD HL,DE
  JR L8F22_0

; Routine at 8F22
;
; Letter-key handler. Maps keys A–Z ($41–$5A) to the L8E7E dispatch table and
; calls the corresponding routine if non-zero.
;
; A Key code ($41–$5A)
L8F22:
  CP $41
  RET C
  CP $5B
  RET NC
  SUB $41
  ADD A,A
  LD HL,L8E8D
  LD D,$00
  LD E,A
  ADD HL,DE
; This entry point is used by the routine at key_dispatch.
L8F22_0:
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  OR H
  RET Z
  CALL LA0D6
  LD B,$03
  CALL wait_frames
  RET

; Message at 8F41
;
; Plugin extension string "HLP" (help viewer plugin).
L8F41:
  DEFM "HLP"

; Message at 8F44
;
; Plugin extension string "HEX" (hex viewer plugin).
L8F44:
  DEFM "HEX"

; Message at 8F47
;
; Plugin extension string "TXT" (text viewer plugin).
L8F47:
  DEFM "TXT"

; Message at 8F4A
;
; Plugin extension string "POK" (memory patcher plugin).
L8F4A:
  DEFM "POK"

; Message at 8F4D
;
; Plugin extension string "INF" (file info viewer plugin).
L8F4D:
  DEFM "INF"

; Message at 8F50
;
; Plugin extension string "SNA" (snapshot manager plugin).
L8F50:
  DEFM "SNA"

; Message at 8F53
;
; Plugin extension string "TAP" (tape image player plugin).
L8F53:
  DEFM "TAP"

; Message at 8F56
;
; Plugin extension string "DOS" (DOS/filesystem utility plugin).
L8F56:
  DEFM "DOS"

; Message at 8F59
;
; Plugin extension string "TPE" (tape-player emulator plugin).
L8F59:
  DEFM "TPE"

; Message at 8F5C
;
; Plugin extension string "UNO" (UNO/Next device extension plugin).
L8F5C:
  DEFM "UNO"

; Message at 8F5F
;
; Plugin extension string "LOK" (file lock/unlock plugin).
L8F5F:
  DEFM "LOK"

; Message at 8F62
;
; Plugin extension string "CLP" (clipboard plugin).
L8F62:
  DEFM "CLP"

; Message at 8F65
;
; Plugin extension string "SPD" (speed/overclock plugin).
L8F65:
  DEFM "SPD"

; Message at 8F68
;
; Plugin extension string "E" (extended/generic plugin type).
L8F68:
  DEFM "E"

; Routine at 8F69
;
; AXE plugin parameter stub (2 bytes: mode byte + padding). Used by L8D4A.
L8F69:
  LD E,B
  LD D,H

; Routine at 8F6B
;
; AXE/ASM plugin parameter struct (3 bytes: mode + destination + count). Used
; by L8D4D as a mode + size structure.
L8F6B:
  LD B,H
  LD D,E
  LD C,E

; Routine at 8F6E
;
; Disk block read. Calls esxDOS disk_read ($81) with BC=sector count, HL=sector
; address (from HLDE), reading into $C000.
L8F6E:
  LD B,L
  LD E,B
  LD B,L
; This entry point is used by the routines at L8FD2, L90A2 and L91E3.
L8F6E_0:
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

; Routine at 8F82
;
; Detect filesystem and check drive status. Calls esxDOS disk_info ($84). If
; LA3D1 bit $20 is set, tries to open a cached config via L9535_0.
detect_fs:
  XOR A
  LD HL,$C000
  RST $08
  DEFB $84
  LD A,(LA3E5)
  AND $20
  JR Z,L8F9D
  CALL open_dir_0
  OR A
  JR NZ,L8F98
  LD A,$02
  RET

; Routine at 8F98
;
; Read colour-scheme index from LA3D0 and apply via L8F8E_0.
L8F98:
  LD A,(LA3E4)
  JR L8F9D_0

; Routine at 8F9D
;
; Apply colour scheme. Reads LA3D0 (colour theme index) and updates the
; attribute bytes LA3CA–LA3CF and the border colour.
L8F9D:
  LD A,(LA3E4)
  ADD A,A
  LD B,A
  ADD A,A
  ADD A,B
  LD DE,$C000
  LD H,$00
  LD L,A
  ADD HL,DE
  LD A,(HL)
; This entry point is used by the routine at L8F98.
L8F9D_0:
  LD ($BFA2),A
  LD B,$08
  LD HL,$C000
  LD DE,$0006
; This entry point is used by the routine at L8FD2.
L8F9D_1:
  LD A,(HL)
  OR A
  JR Z,L8FD2_3
  AND $78
  LD C,A
  AND $60
  JR Z,L8FD2_2
  LD A,C
  AND $18
  SRL A
  SRL A
  SRL A
  OR A
  JR NZ,L8FD2
  LD A,$01
  JR L8FD2_1

; Routine at 8FD2
;
; Load a directory page from disk. Calls L8F5F_0 (disk_read into $C000) then
; L8FE4 to parse the loaded FAT directory sector into the $C200 buffer.
L8FD2:
  PUSH BC
  LD B,A
L8FD2_0:
  ADD A,A
  DJNZ L8FD2_0
  POP BC
; This entry point is used by the routine at L8F9D.
L8FD2_1:
  LD C,A
  LD A,($BBE2)
  OR C
  LD ($BBE2),A
; This entry point is used by the routine at L8F9D.
L8FD2_2:
  ADD HL,DE
  DJNZ L8F9D_1
; This entry point is used by the routine at L8F9D.
L8FD2_3:
  LD HL,$0000
  LD DE,$0000
  CALL L8F6E_0
  LD A,L
  OR A
  JR Z,L8FF3
  LD A,$80
  RET

; Routine at 8FF3
;
; Parse a FAT directory sector at $C000. Reads file size, cluster, and
; attributes from fixed offsets, handles multi-cluster files by computing
; 32-bit sector offsets via L9E66, and stores the result in the state variables
; at $BF8E–$BF9E.
L8FF3:
  LD A,($C00D)
  LD ($BF8F),A
  LD DE,($C00B)
  LD ($BF92),DE
  LD DE,($C00E)
  LD ($BF94),DE
  LD A,($C012)
  CP $02
  JR NZ,L905E
  LD A,$01
  LD ($BF8E),A
  LD HL,($C010)
  LD DE,$0000
  EXX
  LD HL,($C016)
  LD DE,$0000
  CALL mul32
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
  CALL div32
  LD ($BF90),DE
  LD A,$00
  JR L909F_0

; Routine at 905E
;
; Set directory-load mode. Determines whether the cluster chain is FAT16 ($01)
; or FAT32 ($02) and sets $BF8E accordingly.
L905E:
  OR A
  JR NZ,L909F
  LD A,$02
  LD ($BF8E),A
  LD HL,$0000
  LD ($BF90),HL
  LD HL,($C010)
  LD DE,$0000
  EXX
  LD HL,($C024)
  LD DE,($C026)
  CALL mul32
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
  JR L909F_0

; Routine at 909F
;
; Return A = 1 (success indicator from directory load setup).
L909F:
  LD A,$01
; This entry point is used by the routines at L8FF3 and L905E.
L909F_0:
  RET

; Routine at 90A2
;
; Compute the next sector number. Given current 32-bit file position in HL/DE,
; divides by sector size to get the next sector to load. Calls L9E9D for 32-bit
; division.
L90A2:
  XOR A
  OR D
  OR E
  OR H
  OR L
  AND A
  JR NZ,L90A2_0
  LD HL,($BF9A)
  LD DE,($BF9C)
L90A2_0:
  LD B,$02
  LD A,($BF8E)
  CP $01
  JR NZ,L90A2_1
  DEC B
L90A2_1:
  SLA L
  RL H
  RL E
  RL D
  DJNZ L90A2_1
  EX DE,HL
  LD BC,($BF92)
  CALL div32
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
  CALL L8F6E_0
  POP HL
  LD BC,$C000
  ADD HL,BC
  LD A,($BF8E)
  CP $01
  JR NZ,L90FA
  LD DE,$0000
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  AND H
  INC A
  JR NZ,L90A2_2
  LD H,D
  LD L,E
L90A2_2:
  RET

; Routine at 90FA
;
; Unpack a 4-byte FAT32 cluster entry from (HL). Returns HL=low word, DE=high
; word of cluster address.
L90FA:
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
  JR NZ,L9111
  LD A,D
  SUB $0F
  JR NZ,L9111
  LD H,A
  LD L,A
  LD D,A
  LD E,A
  RET

; Routine at 9111
;
; Return HL = BC (cluster address from parsed entry).
L9111:
  LD L,C
  LD H,B
  RET

; Routine at 9114
;
; Load the full directory from disk into the display buffer at $C200.
; Initialises $BBE9 (entry count) to 0, then iterates through all disk sectors
; calling L8F5F_0 (disk read) and L931B (entry processing) until all entries
; are processed or the buffer is full (max $01AA entries).
load_directory:
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
; This entry point is used by the routine at L91E3.
load_directory_0:
  CP $10
  JP NZ,L91E3_1
  LD A,($BF8F)
  LD B,A
  LD A,($BF88)
  CP B
  JR NZ,load_directory_1
  LD HL,($BFA3)
  LD DE,($BFA5)
  CALL L90A2
  LD A,H
  OR L
  OR D
  OR E
  JP Z,L921B
  LD ($BFA3),HL
  LD ($BFA5),DE
  XOR A
  LD ($BF88),A
load_directory_1:
  OR A
  JR NZ,L91E3
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
  JR Z,L91E3_0
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
  CALL mul32
  LD BC,($BF9E)
  ADD HL,BC
  EX DE,HL
  LD BC,($BFA0)
  ADC HL,BC
  EX DE,HL
  LD ($BF9E),HL
  LD ($BFA0),DE
  JR L91E3_0

; Routine at 91E3
;
; Directory-load inner loop step. Advances to the next sector, increments $BF88
; (sector counter), processes the sector via L931B.
L91E3:
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
; This entry point is used by the routine at load_directory.
L91E3_0:
  CALL L8F6E_0
  LD HL,$BF88
  INC (HL)
  LD IX,$C000
  XOR A
  LD ($BF84),A
; This entry point is used by the routine at load_directory.
L91E3_1:
  CALL process_fat_entry
  OR A
  JR Z,L921B
  LD DE,$0020
  ADD IX,DE
  LD HL,$BF84
  INC (HL)
  LD A,(HL)
  JP load_directory_0

; Routine at 921B
;
; Return L=0 (end-of-directory or buffer-full indicator).
L921B:
  LD L,$00
  RET

; Routine at 921E
;
; Extract and format a filename from a raw LFN (Long File Name) FAT directory
; entry at HL into the buffer at DE. Parses the multi-part LFN structure,
; handling sequence numbers and gap bytes. Returns character count in C.
L921E:
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
; This entry point is used by the routines at L9256 and L925E.
L921E_0:
  LD B,A
  LD A,(HL)
  AND A
  JR Z,L925E_0
  CP $20
  JR C,L921E_1
  CP $7F
  JR C,L921E_2
L921E_1:
  LD A,$7E
L921E_2:
  LD (DE),A
  INC DE
  INC C
  INC HL
  INC HL
  LD A,B
  INC A
  CP $05
  JR NZ,L9256
  INC HL
  INC HL
  INC HL
  JR L921E_0

; Routine at 9256
;
; Skip a LFN continuation entry at sequence position $0B (extra skip in the LFN
; chain).
L9256:
  CP $0B
  JR NZ,L925E
  INC HL
  INC HL
  JR L921E_0

; Routine at 925E
;
; Handle end of LFN sequence. Writes NUL terminator if the entry has the $40
; (last-in-sequence) flag; returns length in A.
L925E:
  CP $0D
  JR NZ,L921E_0
; This entry point is used by the routine at L921E.
L925E_0:
  POP HL
  LD A,(HL)
  AND $40
  JR Z,L925E_1
  XOR A
  LD (DE),A
L925E_1:
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

; Routine at 927B
;
; Build a formatted 18-byte display entry from a raw FAT short-name (8.3)
; directory entry. Copies the 11-byte name, 4-byte cluster, and 4-byte size
; into the display buffer at $BF6E.
L927B:
  LD HL,$BE00
  LD A,(HL)
  AND A
  RET Z
  CALL measure_string
  LD A,C
  AND A
  RET Z
  LD (L92EC),A
  LD E,L
  LD HL,($BF8C)
  XOR A
  LD B,$0B
L927B_0:
  RRCA
  LD D,A
  LD A,(HL)
  ADD A,D
  INC HL
  DJNZ L927B_0
  LD L,A
  LD A,($BF61)
  CP L
  JP NZ,L9315_0
  LD A,E
  AND A
  JR NZ,L92D4_0
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
  JR Z,L92BB
  XOR A
  LD (DE),A
  JR L92D4_0

; Routine at 92BB
;
; Continuation of L926C; handles edge cases and terminates the formatted entry.
L92BB:
  LD HL,$BE00
  LD A,($BF87)
  LD L,A
  LD B,A
L92BB_0:
  LD A,(HL)
  CP $2E
  JR Z,L92CD
  DEC HL
  DJNZ L92BB_0
  JR L92D4

; Routine at 92CD
;
; Return the address of the current $BF6E entry slot.
L92CD:
  LD BC,$0005
  LDIR
  JR L92D4_0

; Routine at 92D4
;
; Sort-insert a new 18-byte entry into the $C200 directory buffer in
; case-insensitive alphabetical order (directories first). Calls L8964 for
; comparison.
L92D4:
  INC DE
  XOR A
  LD (DE),A
; This entry point is used by the routines at L927B and L92CD.
L92D4_0:
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

; Data block at 92EB
;
; Directory-insertion comparison flag byte.
L92EB:
  DEFB $3E

; Data block at 92EC
;
; Secondary insertion flag byte.
L92EC:
  DEFB $00

; Routine at 92ED
;
; Insert a new entry into the sorted directory list at $C200. Computes the
; insert position by shifting existing entries down, then copies the new entry
; into place.
L92ED:
  INC A
  LD B,$00
  LD C,A
  LD E,A
  ADD HL,BC
  LD ($BF85),HL
  LD BC,$2000
  OR A
  SBC HL,BC
  JR NC,L9315
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
  JR L9315_0

; Routine at 9315
;
; Clear the FAT format work buffers. Zeros $BE00, the offset pointers in
; ($BF6E+$0C), and $BF87.
L9315:
  LD HL,($BF6E)
  LD BC,$000C
  ADD HL,BC
  XOR A
  LD (HL),A
  INC HL
  LD (HL),A
; This entry point is used by the routines at L927B and L92ED.
L9315_0:
  LD HL,$BE00
  XOR A
  LD (HL),A
  LD HL,$BF87
  LD (HL),A
  RET

; Routine at 932A
;
; Process one 32-byte raw FAT directory entry at IX. Skips deleted ($E5),
; volume-label, and hidden entries. For valid entries: extracts the name via
; L920F (LFN) or short name, copies to $BF6E, calls L926C to build the 18-byte
; display record, then calls L92C5 to sort-insert it. Increments $BBE9 (entry
; count) and advances $BF6E by 18.
;
;        IX Pointer to 32-byte raw FAT directory entry (at $C000 + offset)
; Output: A 1 if entry was added, 0 if end-of-directory
process_fat_entry:
  PUSH IX
  LD ($BF8C),IX
  LD A,(IX+$00)
  LD H,A
  AND A
  JP Z,L93C5
  LD A,(IX+$0B)
  CP $0F
  JR NZ,process_fat_entry_0
  LD HL,($BF8C)
  CALL L921E
process_fat_entry_0:
  LD A,H
  CP $E5
  JR Z,process_fat_entry_4
  CP $2E
  JR NZ,process_fat_entry_1
  LD A,($BF84)
  AND A
  JR Z,process_fat_entry_4
process_fat_entry_1:
  LD A,(IX+$0B)
  LD B,A
  AND $08
  JR NZ,process_fat_entry_4
  LD A,($BF89)
  AND A
  JR Z,process_fat_entry_2
  LD A,B
  AND $10
  JR Z,process_fat_entry_4
process_fat_entry_2:
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
  JR Z,process_fat_entry_3
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
process_fat_entry_3:
  LD HL,($BF8C)
  LD DE,($BF6E)
  INC DE
  LD BC,$000B
  LDIR
  CALL L927B
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
  JR Z,L93C5
process_fat_entry_4:
  POP IX
  LD A,$01
  RET

; Routine at 93C5
;
; Return A=0 (end-of-directory from L931B).
L93C5:
  POP IX
  XOR A
  RET

; Routine at 93C9
;
; Retrieve fstat info for file handle H. Calls esxDOS f_fstat ($A1) into $BFB4;
; returns file size low word in BC.
;
;        H File handle
; Output: BC File size (low 16 bits)
L93C9:
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
L93D9:
  DEFS $01

; Routine at 93DA
;
; Open a file on the system drive '$' with read mode ($01) and read data into a
; caller-supplied buffer. Calls esxDOS f_open ($9A), then L93E2 for the actual
; read.
;
; HL Pointer to NUL-terminated filename
; BC Read length
; DE Destination buffer pointer
file_open_read:
  XOR A
  LD (L9411),A
  LD A,$24
; This entry point is used by the routine at load_cache.
file_open_read_0:
  PUSH DE
  PUSH BC
  LD B,$01
  RST $08
  DEFB $9A
  POP BC
  JR NC,L93F1
  POP DE
  LD (LA3EC),A
  LD HL,$0000
  RET

; Routine at 93F1
;
; Read data from an open file into a buffer. Calls esxDOS f_read ($9D). On
; error stores the error code in LA3D8 and returns HL=0.
L93F1:
  LD (L9411),A
  LD H,A
  LD A,C
  OR B
  CALL Z,L93C9
  POP HL
  LD A,(L9411)
  RST $08
  DEFB $9D
  JR NC,L93F1_0
  LD HL,$0000
  LD (LA3EC),A
L93F1_0:
  LD A,(L9411)
  RST $08
  DEFB $9B
  LD HL,$0001
  RET

; Unused
L9411:
  DEFS $01

; Routine at 9412
;
; Open a file on drive A with read mode and read data into a buffer. Uses
; esxDOS f_open ($9A) then L93E2.
L9412:
  LD A,$2A
  RST $08
  DEFB $AD
  JR C,L941C
  LD HL,$0001
  RET

; Routine at 941C
;
; Close file handle A via esxDOS f_close ($9B). Returns L=1 on success.
L941C:
  LD (LA3EC),A
  LD HL,$0000
  RET

; Routine at 9423
;
; Load and compare bookmark file. Opens "/tmp/browse.bmk" via esxDOS f_open
; ($9A), reads 512 bytes into $C000. Compares $BC00 content with loaded data to
; decide whether to restore the saved scroll position ($BBEF).
L9423:
  LD A,(LA3E5)
  AND $10
  RET Z
  LD A,$24
  LD B,$01
  LD HL,L949A
  RST $08
  DEFB $9A
  JR C,L9454_1
  LD (L93D9),A
  LD HL,$C000
  LD BC,$0200
  RST $08
  DEFB $9D
  JR C,L9454_1
  LD DE,$BC00
  LD HL,$C000
L9423_0:
  LD A,(DE)
  LD B,A
  LD C,(HL)
  OR C
  JR Z,L9454
  CP B
  JR NZ,L9454_0
  INC DE
  INC HL
  JR L9423_0

; Routine at 9454
;
; Read the saved selection index from the bookmark file into $BBEF, then
; compute the entry address via L84EC. Returns A=0 on read error.
L9454:
  LD A,(L93D9)
  LD HL,$BBEF
  LD BC,$0002
  RST $08
  DEFB $9D
  LD HL,($BBEF)
  CALL get_entry_ptr
; This entry point is used by the routine at L9423.
L9454_0:
  LD A,(L93D9)
  RST $08
  DEFB $9B
; This entry point is used by the routine at L9423.
L9454_1:
  XOR A
  RET C
  INC A
  RET

; Routine at 946E
;
; Save current browser state to the bookmark file. Writes $BC00 (directory
; list) and $BBEF (selection index) to "/tmp/browse.bmk" using esxDOS
; f_open/f_write ($9E).
save_bookmark:
  LD A,(LA3E5)
  AND $10
  RET Z
  LD A,$24
  LD HL,L949A
  LD B,$0A
  RST $08
  DEFB $9A
  RET C
  LD (L93D9),A
  LD HL,$BC00
  LD BC,$0200
  RST $08
  DEFB $9E
  LD A,(L93D9)
  LD HL,$BBEF
  LD BC,$0002
  RST $08
  DEFB $9E
  LD A,(L93D9)
  RST $08
  DEFB $9B
  RET

; Message at 949A
;
; Path string "/tmp/browse.bmk" — bookmark/cursor-position persistence file.
L949A:
  DEFM "/tmp/browse.bmk"

; Data block at 94A9
;
; NUL terminator for L948B.
L94A9:
  DEFB $00

; Message at 94AA
;
; Filename "cache.db" — directory entry count cache file.
L94AA:
  DEFM "cache.db"

; Data block at 94B2
;
; NUL terminator for L949B.
L94B2:
  DEFB $00

; Message at 94B3
;
; Status string "Cached" — shown after writing the directory count to cache.
L94B3:
  DEFM "Cached"

; Data block at 94B9
;
; Self-modifying 2-byte parameter used by cache load/save routines.
L94B9:
  DEFB $21,$00

; Routine at 94BB
;
; Load directory entry count from cache. Opens "cache.db" on the current drive,
; reads the 2-byte entry count into $C1FE, and restores $BBE9 if a cached value
; exists. Clears LA3D8 on exit.
load_cache:
  LD HL,L94AA
  LD BC,$3E02
  LD DE,$C1FE
  XOR A
  LD (L9411),A
  LD A,$2A
  CALL file_open_read_0
  LD A,L
  AND A
  JR Z,load_cache_0
  LD DE,($C1FE)
  LD ($BBE9),DE
load_cache_0:
  XOR A
  LD (LA3EC),A
  RET

; Message at 94DE
;
; Status string "Deleted" — shown after deleting the directory count cache.
L94DE:
  DEFM "Deleted"

; Data block at 94E5
;
; Self-modifying entry stub for the cache delete operation. Executing from
; $94E5 reads as LD HL,$AF00; the $AF byte at $94E7 is also a secondary entry
; point (XOR A) used by the key dispatch table to clear A before falling
; through to L94DB_0.
L94E5:
  DEFB $21,$00

; Data block at 94E7
L94E7:
  DEFB $AF

; Routine at 94E8
L94E8:
  JR update_cache_0

; Routine at 94EA
;
; Delete then re-build directory count cache. Shows "Working...", deletes
; "cache.db" via L9403, then if LA3D8 is clear reloads the directory (L8595
; with flags=$0A). Shows "Cached" or "Deleted" status on completion.
update_cache:
  LD HL,L858A
  CALL draw_header_text
  LD A,$01
; This entry point is used by the routine at L94E8.
update_cache_0:
  PUSH AF
  LD HL,L94AA
  CALL L9412
  LD A,L
  AND A
  JR Z,update_cache_1
  LD L,$0A
  CALL load_dir
update_cache_1:
  POP AF
  AND A
  JR NZ,write_cache
  LD HL,L94DE
  JR write_cache_0

; Routine at 950B
;
; Write the current directory entry count to "cache.db". Opens the file for
; write ($9A mode $0A), writes $BBE9 as a 2-byte value, closes. Shows "Cached"
; status or returns L=0 on error.
write_cache:
  LD HL,L94AA
  LD A,$2A
  LD B,$0A
  RST $08
  DEFB $9A
  JR C,L9541
  LD (L93D9),A
  LD HL,($BBE9)
  LD ($C1FE),HL
  LD HL,$C1FE
  LD BC,$3E02
  RST $08
  DEFB $9E
  JR C,L9541
  LD A,(L93D9)
  RST $08
  DEFB $9B
  LD HL,L94B3
; This entry point is used by the routine at update_cache.
write_cache_0:
  CALL L8C60
  LD B,$60
  CALL wait_any_key
  LD L,$01
  CALL L8C85
  LD L,$01
  RET

; Routine at 9541
;
; Return L=0 (write failure). Tail of L94FC error path.
L9541:
  LD L,$00
  RET

; Routine at 9544
;
; Open a directory on the current drive ($2A) using esxDOS f_opendir ($A3). On
; success reads file info via L93BA, stores drive letter at LA3D0. Returns A=1
; on success, A=0 on failure.
open_dir:
  CPL
  NOP
; This entry point is used by the routine at detect_fs.
open_dir_0:
  LD HL,open_dir
  LD A,$2A
  LD B,$01
  RST $08
  DEFB $A3
  JR C,L9562
  PUSH AF
  LD H,A
  CALL L93C9
  LD A,($BFB5)
  LD (LA3E4),A
  POP AF
  RST $08
  DEFB $9B
  LD A,$01
  RET

; Routine at 9562
;
; Return A=0 (failed to open directory). Tail of L9535.
L9562:
  XOR A
  RET

; Routine at 9564
;
; Case-insensitive substring match. Compares the NUL-terminated filename at HL
; character by character against the search pattern at L9615. Returns HL=1 on
; match, HL=0 on no-match.
;
;        HL Pointer to filename to search in
; Output: HL 1 if search string matches anywhere in filename, else 0
name_matches:
  LD DE,L9624
; This entry point is used by the routine at L958F.
name_matches_0:
  LD A,(HL)
  AND A
  JR Z,L9595
  LD B,A
  LD A,(DE)
  CP $60
  JR C,name_matches_1
  CP $80
  JR NC,name_matches_1
  SUB $20
name_matches_1:
  LD C,A
  LD A,B
  CP $60
  JR C,name_matches_2
  CP $80
  JR NC,name_matches_2
  SUB $20
name_matches_2:
  CP C
  JR NZ,L958F
  INC DE
  LD A,(DE)
  AND A
  JR NZ,L958F_0
  LD HL,$0001
  RET

; Routine at 958F
;
; Restart comparison from the beginning of the search pattern (called after a
; partial mismatch).
L958F:
  LD DE,L9624
; This entry point is used by the routine at name_matches.
L958F_0:
  INC HL
  JR name_matches_0

; Routine at 9595
;
; Return HL=0 (no match — reached end of filename without a full match).
L9595:
  LD HL,$0000
  RET

; Routine at 9599
;
; Toggle the incremental search mode on/off. Flips the search-active flag at
; $BF6C. When turning search on, clears L9603 (pattern length) and L9615
; (pattern buffer), shows the "Find:" prompt in the header, and enters the
; search input loop via L9CCF.
search_toggle:
  LD HL,($BF6C)
  LD A,(HL)
  XOR $01
  LD (HL),A
; This entry point is used by the routines at L964C and L968F.
search_toggle_0:
  AND A
  JR Z,L95B9
  XOR A
  LD (L9612),A
  LD HL,L9624
  LD (HL),A
  LD DE,L9625
  LD BC,$000F
  LDIR
  INC A
  LD HL,L961E
  JR L95B9_0

; Routine at 95B9
;
; Enter or exit search mode. Stores the new search state in $BF6C, draws the
; header (L960F prompt or $BC00 path), then waits for input via L9CCF.
L95B9:
  LD HL,$BC00
; This entry point is used by the routine at search_toggle.
L95B9_0:
  LD ($BF6C),A
  CALL draw_header_text
  CALL wait_key
  RET

; Routine at 95C6
;
; Search the directory list for a filename matching the pattern at L9615. L=0
; searches forward from the current $BBEF; L=1 searches from the start. Returns
; HL=count-remaining if found (non-zero = match at updated $BBEF), or HL=0 if
; no match.
;
;        L 0 = search from current position, 1 = search from beginning
; Output: HL Count remaining at match position (non-zero), or 0 if not found
search_dir:
  LD A,L
  LD HL,$C200
  LD BC,$0000
  OR A
  JR NZ,search_dir_0
  LD HL,($BBEF)
  PUSH HL
  CALL get_entry_ptr
  POP BC
search_dir_0:
  EX DE,HL
  LD HL,($BBE9)
  SBC HL,BC
  EX DE,HL
; This entry point is used by the routine at L9605.
search_dir_1:
  LD A,D
  OR E
  JR Z,L960E
  PUSH DE
  PUSH HL
  CALL get_cluster_addr
  LD A,(L9612)
  CP $01
  JR NZ,search_dir_2
  LD A,(HL)
  LD HL,$BF6A
  LD (HL),A
search_dir_2:
  CALL name_matches
  LD A,L
  OR A
  JR Z,L9605
  POP HL
  POP DE
  OR A
  LD HL,($BBE9)
  SBC HL,DE
  JR L960E_0

; Routine at 9605
;
; Advance to the previous entry for backward search. Steps HL by 18 bytes,
; decrements DE (remaining count), continues the search loop.
L9605:
  POP HL
  POP DE
  LD BC,$0012
  ADD HL,BC
  DEC DE
  JR search_dir_1

; Routine at 960E
;
; Return HL=0 (not found). Common return for L95B7 when the pattern was not
; matched.
L960E:
  LD HL,$0000
; This entry point is used by the routine at search_dir.
L960E_0:
  RET

; Data block at 9612
;
; Search pattern length counter (0–16). 0 = pattern is empty, no search active.
L9612:
  DEFB $00

; Message at 9613
;
; Message "Not found!" — shown when L95B7 fails to match the search pattern.
L9613:
  DEFM "Not found!"

; Data block at 961D
;
; NUL terminator byte following L9604.
L961D:
  DEFB $00

; Message at 961E
;
; Message "Find: " — header prompt while search mode is active.
L961E:
  DEFM "Find: "

; Data block at 9624
;
; NUL byte at the start of the search pattern buffer (at offset 0).
L9624:
  DEFB $00

; Data block at 9625
;
; Search pattern buffer (16 bytes). NUL-terminated string currently being
; searched for.
L9625:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00

; Routine at 9634
;
; Interactive search key handler. Backspace ($0C) removes the last character
; from the pattern and re-runs the search. Return ($0D or $80) opens the
; currently matched file (L963D). Other printable characters are added to the
; pattern.
;
; C Key code (Backspace=$0C, Return=$0D/$80, printable char otherwise)
search_key_handler:
  LD A,C
  CP $0C
  JR NZ,L964C
  LD HL,L9612
  LD A,(HL)
  AND A
  RET Z
  DEC A
  DEC (HL)
  LD B,$00
  LD C,A
  LD HL,L9624
  ADD HL,BC
  XOR A
  LD (HL),A
  JR search_add_char_1

; Routine at 964C
;
; Handle Enter/Return in search mode. If a match was found ($BBEF non-zero),
; calls L8E1F (execute file). Clears search state on exit.
L964C:
  CP $80
  JR Z,L964C_0
  CP $0D
  JR NZ,L9667
L964C_0:
  LD HL,($BBEF)
  LD A,H
  OR L
  JR Z,L9663
  CALL exec_file
  XOR A
  CALL search_toggle_0
  RET

; Routine at 9663
;
; Handle Enter when no file is selected. Calls L8D05 (border flash / error
; feedback).
L9663:
  CALL L8D0F
  RET

; Routine at 9667
;
; Handle 'F' key: find next match. Advances $BBEF by one, calls L95B7 forward
; then wrapping to find the next occurrence of the search pattern.
L9667:
  CP $46
  JR NZ,L968F
  OR A
  LD HL,($BBE9)
  LD DE,($BBEF)
  SBC HL,DE
  JR C,L9667_0
  INC DE
  LD ($BBEF),DE
L9667_0:
  LD L,$00
  CALL search_dir
  LD A,H
  OR L
  JR NZ,search_add_char_2
  LD L,$01
  CALL search_dir
  LD A,H
  OR L
  JR NZ,search_add_char_2
  RET

; Routine at 968F
;
; Handle Space in search mode. If search is active (B non-zero), toggles search
; off via L958A_0. Otherwise falls through to L968D to add space to the
; pattern.
L968F:
  CP $20
  JR NZ,search_add_char
  LD A,B
  AND A
  JR Z,search_add_char_0
  XOR A
  CALL search_toggle_0
  RET

; Routine at 969C
;
; Add character C to the search pattern. Accepts printable ASCII ($20–$7F,
; capped at 16 chars). Appends to L9615 buffer and re-runs the search via
; L968D_1.
;
; C ASCII character to append to the search pattern
search_add_char:
  CP $20
  RET C
  CP $80
  RET NC
; This entry point is used by the routine at L968F.
search_add_char_0:
  LD HL,L9612
  LD A,(HL)
  CP $10
  RET NC
  LD B,A
  LD A,C
  LD C,B
  LD B,$00
  LD DE,L9624
  EX DE,HL
  ADD HL,BC
  LD (HL),A
  EX DE,HL
  INC (HL)
; This entry point is used by the routine at search_key_handler.
search_add_char_1:
  LD HL,L961E
  CALL draw_header_text
  CALL search_dir
  LD A,H
  OR L
  JR NZ,search_add_char_2
  LD A,(L9612)
  AND A
  JR Z,search_add_char_2
  PUSH HL
  LD BC,$0017
  LD HL,L9613
  CALL draw_string
  CALL L8D0F
  POP HL
; This entry point is used by the routine at L9667.
search_add_char_2:
  LD ($BBEB),HL
  LD ($BBEF),HL
  CALL refresh_display
  RET

; Routine at 96E1
;
; Render the file-info / preview panel. Gets current filename via L84FF, calls
; the preview renderer (LA1F6 with L96EB as the extension stub), then
; re-renders the selected entry in the right column.
render_preview:
  CALL get_current_name
  LD HL,L96FA
  CALL invoke_plugin
  LD A,(LA3C3)
  CP $01
  RET Z
  LD A,($BF62)
  LD C,A
  LD B,$17
  CALL render_entry
  RET

; Routine at 96FA
;
; Preview-panel loader stub. Self-modifying bytes overwritten at runtime with
; the preview panel draw parameters; on return toggles $BBE6 (preview enable
; flag).
L96FA:
  LD B,(HL)
  LD D,L
  LD C,H
  NOP
L96FA_0:
  LD HL,$BBE6
  LD A,(HL)
  XOR $01
  LD (HL),A
  OR A
  JR Z,L970C
  CALL render_preview
  RET

; Routine at 970C
;
; Hide preview panel and reload directory. Calls L9DA6 (clear screen + apply
; colour scheme), then L8595 with flags=$01 (reload only).
L970C:
  CALL init_display_colors
  LD A,$01
  CALL load_dir
  RET

; Routine at 9715
;
; Clear the Spectrum display. Fills pixel memory $4000–$57FF with 0x00, then
; fills attribute memory $5800–$5AFF with colour A.
;
; A Default attribute byte for the whole screen
clear_display:
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

; Routine at 972C
;
; Set the border colour and the BORDCR system variable. Outputs A to port $FE,
; rotates left 3, stores in $5C48 (BORDCR).
;
; A Ink colour value (lower 3 bits used for border)
set_border:
  OUT ($FE),A
  RLCA
  RLCA
  RLCA
  LD ($5C48),A
  RET

; Routine at 9735
;
; Fill a complete 32-column attribute row with colour byte C. Computes the
; attribute address from row B, writes C to all 32 bytes via LDIR.
;
; B Screen row (1–22)
; C Attribute byte
fill_attr_row:
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

; Routine at 974D
;
; Copy an 8×8 character cell on the pixel display. Maps source row B and
; destination row C to pixel addresses, copies all 8 scan lines (32 bytes
; each). Used by scroll-up/down optimisation.
;
; B Source screen row
; C Destination screen row
copy_char_row:
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
  LD (L977D),A
  LD A,E
  LD (L977F),A
  LD A,$08
; This entry point is used by the routine at L9780.
copy_char_row_0:
  LD BC,$0020
  LDIR
  DEC HL
  DEC DE
  INC D
  INC H

; Data block at 977C
;
; Self-modify: source high address byte for L973E pixel copy loop.
L977C:
  DEFB $2E

; Data block at 977D
;
; Self-modify: source column offset low byte.
L977D:
  DEFB $00

; Data block at 977E
;
; Self-modify: destination high address byte.
L977E:
  DEFB $1E

; Data block at 977F
;
; Self-modify: destination column offset low byte.
L977F:
  DEFB $00

; Routine at 9780
;
; Copy the attribute bytes for the scrolled row. Continuation of L973E after
; pixel copy.
L9780:
  DEC A
  AND A
  JR NZ,copy_char_row_0
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

; Routine at 979E
;
; Clear (zero) all 8 pixel scan lines for screen row B.
;
; B Screen row to clear (1–22)
clear_char_row:
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
clear_char_row_0:
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
  DJNZ clear_char_row_0
  RET

; Routine at 97C3
;
; Render a NUL-terminated proportional string to the pixel display. Looks up
; each character in the L9867 font table (8 bytes per glyph), writes pixel rows
; to the screen starting at row B, column C.
;
; HL Pointer to NUL-terminated string
; B Screen row (1–22)
; C Starting pixel column (0–based, aligned to character widths)
draw_string:
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
; This entry point is used by the routine at L9822.
draw_string_0:
  LD A,(HL)
  AND A
  RET Z
  SUB $20
  PUSH HL
  LD BC,L9876
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
  JR Z,draw_string_1
  LD B,A
draw_string_1:
  LD A,IYh
  LD E,IXl
; This entry point is used by the routine at L9822.
draw_string_2:
  LD D,IXh
  LD C,A
  PUSH BC
  LD HL,$BFAC
  LD B,$08
; This entry point is used by the routine at L980C.
draw_string_3:
  SLA (HL)
  LD A,(DE)
  JR NC,L980C
  OR C
  JR L980C_0

; Routine at 980C
;
; Pixel column blitter helper. Writes the current foreground/background mask
; byte to the display, then advances the column pointer. Called per pixel
; column within L97B4.
L980C:
  OR C
  XOR C
; This entry point is used by the routine at draw_string.
L980C_0:
  LD (DE),A
  INC HL
  INC D
  DJNZ draw_string_3
  SRL C
  JR NZ,L9822_0
  LD C,$80
  INC E
  LD A,E
  AND $1F
  JR NZ,L9822
  POP BC
  POP HL
  RET

; Routine at 9822
;
; Advance column IX for the next character in the L97B4 render loop.
L9822:
  INC IXl
; This entry point is used by the routine at L980C.
L9822_0:
  LD A,C
  POP BC
  DJNZ draw_string_2
  LD IYh,A
  POP HL
  INC HL
  JR draw_string_0

; Routine at 982E
;
; Build the proportional character width table at $BF00. Reads the first byte
; of each glyph in L9867 (width in pixels) and stores it in $BF00. Also
; measures "<DIR" string via L984C and stores the pixel width in L89EB.
L982E:
  LD B,$61
  LD HL,L9876
  LD DE,$BF00
L982E_0:
  LD A,(HL)
  AND A
  JR NZ,L982E_1
  LD A,$06
L982E_1:
  LD (DE),A
  INC DE
  LD C,D
  LD A,E
  LD DE,$0008
  ADD HL,DE
  LD D,C
  LD E,A
  DJNZ L982E_0
  LD HL,L8929
  CALL measure_string
  LD A,$FF
  SUB B
  SRL A
  SRL A
  SRL A
  LD (L89EB),A
  RET

; Routine at 985B
;
; Measure the total pixel width of a NUL-terminated string. Sums per-character
; widths from the $BF00 table (indexed by char-$20). Returns L=1 and B=total
; width on success, or L=0 on overflow.
;
;        HL Pointer to NUL-terminated string
; Output: B Total pixel width, L=1 on success / L=0 on overflow
measure_string:
  LD B,$00
  LD C,$00
  LD D,$BF
measure_string_0:
  LD A,(HL)
  AND A
  JR Z,L9871
  SUB $20
  LD E,A
  LD A,(DE)
  ADD A,B
  JR C,L9871
  LD B,A
  INC HL
  INC C
  JR measure_string_0

; Routine at 9871
;
; Return L=0 on carry (width overflow), L=1 on success.
L9871:
  LD L,$00
  RET C
  INC L
  RET

; Data block at 9876
;
; Custom proportional 8×8 pixel font bitmap table. 97 characters covering ASCII
; $20–$7E plus special glyphs. Each glyph entry is 8 bytes: byte 0 = pixel
; width override (0 = use default of 6px). Used by L97B4 (render string) and
; L981F (build width table).
L9876:
  DEFB $04,$00,$00,$00,$00,$00,$00,$00
  DEFB $03,$80,$80,$80,$80,$00,$80,$00
  DEFB $05,$90,$90,$00,$00,$00,$00,$00
  DEFB $00,$50,$F8,$50,$50,$F8,$50,$00
  DEFB $00,$20,$F8,$A0,$F8,$28,$F8,$20
  DEFB $00,$00,$C8,$D0,$20,$58,$98,$00
  DEFB $00

; Message at 98A7
;
; Status bar template " P X" — the four status indicator positions (Preview,
; Locked, Speed, NMI).
L98A7:
  DEFM " P X"

; Data block at 98AB
;
; Font bitmap data continuation (special/icon characters for the status bar
; area).
L98AB:
  DEFB $90,$68,$00,$03,$40,$80,$00,$00
  DEFB $00,$00,$00,$04,$20,$40,$40,$40
  DEFB $40,$20,$00,$04,$40

; Message at 98C0
;
; Font table spacer "    " — separator between bitmap groups.
L98C0:
  DEFM "    "

; Data block at 98C4
;
; Font bitmap data (digits 0–9, punctuation, and letters A–S from the custom
; charset).
L98C4:
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

; Message at 99C0
;
; Font table spacer "    " — separator.
L99C0:
  DEFM "    "

; Data block at 99C4
;
; Font bitmap data continuation (letters T–Z and lowercase/special glyphs).
L99C4:
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

; Message at 9A18
;
; Font table spacer "     ".
L9A18:
  DEFM "     "

; Data block at 9A1D
;
; Font bitmap data (letters u–x continuation).
L9A1D:
  DEFB $00,$00,$88,$88,$88,$88,$88,$70
  DEFB $00,$00,$88,$88,$88,$88,$50,$20
  DEFB $00,$00,$88,$88,$88,$88,$A8,$50
  DEFB $00,$00,$88

; Message at 9A38
;
; Font table inline marker "P  P" (proportional-width marker bytes within the
; bitmap data stream).
L9A38:
  DEFM "P  P"

; Data block at 9A3C
;
; Font bitmap data (letters x–z and special characters).
L9A3C:
  DEFB $88,$00,$00,$88,$88

; Message at 9A41
;
; Font table marker "P   ".
L9A41:
  DEFM "P   "

; Data block at 9A45
;
; Font bitmap data (brackets and punctuation characters).
L9A45:
  DEFB $00,$00,$F8,$08,$10,$20,$40,$F8
  DEFB $00,$05,$70,$40,$40,$40,$40,$70
  DEFB $00,$00,$00,$80,$40,$20,$10,$08
  DEFB $00,$05,$70,$10,$10,$10,$10,$70
  DEFB $00,$00,$20,$70,$A8

; Message at 9A6A
;
; Font table marker "   ".
L9A6A:
  DEFM "   "

; Data block at 9A6D
;
; Font bitmap data (lowercase letters a–o and symbols).
L9A6D:
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

; Data block at 9B28
;
; Font bitmap fragment (continuation of 'v' and 'w' glyphs).
L9B28:
  DEFB $88,$88

; Message at 9B2A
;
; Font table inline marker "PP ".
L9B2A:
  DEFM "PP "

; Data block at 9B2D
;
; Font bitmap data (letter 'x' and continuation).
L9B2D:
  DEFB $00,$00,$00,$88,$A8,$A8,$A8,$50
  DEFB $00,$00,$00,$88

; Message at 9B39
;
; Font table inline marker "P P".
L9B39:
  DEFM "P P"

; Data block at 9B3C
;
; Font bitmap data (letters y–z, braces, bar characters).
L9B3C:
  DEFB $88,$00,$00,$00,$88,$88,$88,$78
  DEFB $08,$70,$00,$00,$F8,$10,$20,$40
  DEFB $F8,$00,$00,$38,$20,$60

; Message at 9B52
;
; Font table marker "  8".
L9B52:
  DEFM "  8"

; Data block at 9B55
;
; Font bitmap fragment.
L9B55:
  DEFB $00,$00

; Message at 9B57
;
; Font table spacer "      ".
L9B57:
  DEFM "      "

; Data block at 9B5D
;
; Font bitmap data (custom/special characters, end of font table).
L9B5D:
  DEFB $00,$00,$70,$10,$18,$10,$10,$70
  DEFB $00,$05,$50,$A0,$00,$00,$00,$00
  DEFB $00,$00,$70,$A8,$C8,$C8,$A8,$70
  DEFB $00,$00,$00,$00,$00,$00,$A8,$A8
  DEFB $00,$06,$00,$00,$00,$00,$00,$00
  DEFB $00

; Routine at 9B86
;
; Wait for all keyboard keys to be released. Loops reading port $FE until all
; row bits read $1F (no keys pressed).
wait_keys_up:
  XOR A
  IN A,($FE)
  AND $1F
  CP $1F
  RET NZ
  JR wait_keys_up

; Routine at 9B90
;
; Scan the ZX Spectrum keyboard matrix (8 half-rows via port $FE). Detects
; which single key is pressed and returns an encoded key index. Returns HL=key
; code or HL=0/Fc on no key / multi-key.
;
; Output: HL Encoded key code, or 0 / Fc if no valid single key
scan_keyboard:
  LD BC,$FEFE
  LD DE,$0500
  LD HL,$FFE0
  IN A,(C)
  OR $E1
  CP H
  JR NZ,L9BBC
  LD E,D
  LD B,$FD
scan_keyboard_0:
  IN A,(C)
  OR L
  CP H
  JR NZ,L9BBC
  LD A,E
  ADD A,D
  LD E,A
  RLC B
  JP M,scan_keyboard_0
  IN A,(C)
  OR $E2
  CP H
  LD C,A
  JR NZ,L9BBC_0
  JP L9C02

; Routine at 9BBC
;
; Decode a row/column key position into an ASCII or action key code. Uses L9B19
; (row sizes) and the QWERTY layout tables at L9C19/L9C42/L9C69. Adjusts for
; Caps Shift and Symbol Shift modifiers.
L9BBC:
  LD C,A
  LD A,B
  CPL
  OR $81
  IN A,($FE)
  OR L
  CP H
  JP NZ,L9BFD
  LD A,$7F
  IN A,($FE)
  OR $E2
  CP H
  JP NZ,L9BFD
; This entry point is used by the routine at scan_keyboard.
L9BBC_0:
  LD B,$00
  LD HL,L9B28
  ADD HL,BC
  LD A,(HL)
  CP D
  JP NC,L9BFD
  ADD A,E
  LD E,A
  LD HL,$9C28
  LD D,B
  ADD HL,DE
  LD A,$FE
  IN A,($FE)
  AND $01
  JR NZ,L9BBC_1
  LD E,$28
  ADD HL,DE
L9BBC_1:
  LD A,$7F
  IN A,($FE)
  AND $02
  JR NZ,L9BBC_2
  LD E,$50
  ADD HL,DE
L9BBC_2:
  LD L,(HL)
  LD H,B
  RET

; Routine at 9BFD
;
; Return HL=0, Fc=1 (no key / debounce reject — multi-key pressed or key not in
; range).
L9BFD:
  LD HL,$0000
  SCF
  RET

; Routine at 9C02
;
; Return HL=0, Fc=0 (multi-key pressed with no valid decode).
L9C02:
  LD HL,$0000
  SCF
  CCF
  RET

; Data block at 9C08
;
; Keyboard half-row size table. Maps each half-row index (0–4) to the number of
; keys in that row for the key-position calculation in L9BAD.
L9C08:
  DEFB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
  DEFB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$04
  DEFB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$03
  DEFB $FF,$FF,$FF,$02,$FF,$01,$00,$FF
  DEFB $FF

; Message at 9C29
;
; QWERTY unshifted character table for the lower 5 keyboard half-rows.
; "zxcvasdfgqwert1234509876poiuy".
L9C29:
  DEFM "zxcvasdfgqwert1234509876poiuy"

; Data block at 9C46
;
; Enter key code ($0D) — separator after the digit-row segment.
L9C46:
  DEFB $0D

; Message at 9C47
;
; Unshifted key table part 2: "lkjh " (middle rows including Space).
L9C47:
  DEFM "lkjh "

; Data block at 9C4C
;
; $FF segment separator.
L9C4C:
  DEFB $FF

; Message at 9C4D
;
; Unshifted key table part 3: "mnb".
L9C4D:
  DEFM "mnb"

; Data block at 9C50
;
; $FF end-of-row separator.
L9C50:
  DEFB $FF

; Message at 9C51
;
; Caps-shifted (uppercase) key table part 1: "ZXCVASDFGQWERT".
L9C51:
  DEFM "ZXCVASDFGQWERT"

; Data block at 9C5F
;
; Caps-shifted control codes: Delete, cursor-up, cursor-left, cursor-right,
; cursor-down, and modifier flags.
L9C5F:
  DEFB $07,$06,$80,$81,$08,$0C,$08,$09
  DEFB $0B,$0A

; Message at 9C69
;
; Caps-shifted key table part 2: "POIUY".
L9C69:
  DEFM "POIUY"

; Data block at 9C6E
;
; Enter key code ($0D) separator.
L9C6E:
  DEFB $0D

; Message at 9C6F
;
; Caps-shifted key table part 3: "LKJH " (Space = Break).
L9C6F:
  DEFM "LKJH "

; Data block at 9C74
;
; $FF separator.
L9C74:
  DEFB $FF

; Message at 9C75
;
; Caps-shifted key table part 4: "MNB".
L9C75:
  DEFM "MNB"

; Data block at 9C78
;
; Symbol-shifted key code table: ":", "`", "?", "/", "~", "|", "\", "{", "}",
; and extra modifier codes.
L9C78:
  DEFB $FF,$3A,$60,$3F,$2F,$7E,$7C,$5C
  DEFB $7B,$7D,$83,$84,$85

; Message at 9C85
;
; Symbol-shifted symbols part 2: "<>!".
L9C85:
  DEFM "<>!"

; Data block at 9C88
;
; Symbol-shifted symbols part 3: "@#$%_".
L9C88:
  DEFB $40,$23,$24,$25,$5F

; Message at 9C8D
;
; Symbol-shifted symbols part 4: ")('&\";".
L9C8D:
  DEFM ")('&\";"

; Data block at 9C93
;
; Symbol-shifted symbols part 5 (extended).
L9C93:
  DEFB $82,$5D,$5B

; Data block at 9C96
;
; Control-key and special-key code table: Enter, cursor navigation codes,
; Delete, etc.
L9C96:
  DEFB $0D,$3D,$2B,$2D,$5E,$20,$FF,$2E
  DEFB $2C,$2A,$FF,$1A,$18,$03

; Data block at 9CA4
;
; Extended keycode table for Caps+Symbol combinations: Paste, Select, Find, and
; similar editor actions.
L9CA4:
  DEFB $16,$01,$13,$04,$06,$07,$11,$17
  DEFB $05,$12,$14,$1B,$1C,$1D,$1E,$1F
  DEFB $7F

; Data block at 9CB5
;
; Additional keycode table for combined modifier keys and special OS actions.
L9CB5:
  DEFB $FF,$86,$60,$87,$10,$0F,$09,$15
  DEFB $19,$0D,$0C,$0B,$0A,$08,$20,$FF
  DEFB $0D,$0E,$02

; Routine at 9CC8
;
; Read Kempston joystick state. Checks port $FE row 0 (bit 0 = fire) and port
; $7F (bit 1 = direction active). Returns E = joystick flags.
;
; Output: E Joystick flags (bit 0 = fire pressed)
read_joystick:
  LD E,$00
  LD BC,$FEFE
  IN A,(C)
  RRA
  JR C,read_joystick_0
  INC E
read_joystick_0:
  LD B,$7F
  IN A,(C)
  RRA
  RRA
  LD A,E
  RET C
  OR $02
  RET

; Routine at 9CDE
;
; Wait for a keypress with full debounce. Waits for all keys released (port $FE
; = $1F). Calls the input-dispatch routine at ($BFA7). Translates via L9B81
; (keyboard scan). If search mode is active ($BF6C non-zero), routes to L9625
; (search handler); otherwise routes to L9D25 (main key dispatch).
wait_key:
  XOR A
  IN A,($FE)
  AND $1F
  CP $1F
  JR NZ,wait_key
  LD A,(LA3E5)
  AND $02
  RET Z
wait_key_0:
  XOR A
  IN A,($1F)
  RET Z
  JR NZ,wait_key_0
; This entry point is used by the routine at main_loop.
wait_key_1:
  LD HL,($BFA7)
  CALL LA0D6
  CP $FF
  JR Z,wait_key_2
  AND A
  JR NZ,wait_key_3
wait_key_2:
  CALL scan_keyboard
  LD A,L
  LD HL,LA3E7
  LD BC,$0005
  CPIR
  JR NZ,wait_key_3
  INC C
  LD A,$05
  SUB C
  LD HL,L8EC1
  LD D,$00
  LD E,A
  ADD HL,DE
  LD A,(HL)
wait_key_3:
  LD H,$00
  LD L,A
  CALL read_joystick
  LD ($BFA9),A
  LD B,A
  LD A,($BF6C)
  OR A
  JR Z,L9D34
  LD C,L
  CALL search_key_handler
; This entry point is used by the routine at L9D47.
wait_key_4:
  LD B,$03
  CALL wait_frames
  RET

; Routine at 9D34
;
; Main key dispatch. Handles Backspace ($C4) and Space ($20) to toggle search
; mode. All other keys pass to L9D38.
L9D34:
  LD A,L
  CP $C4
  JR Z,L9D34_0
  CP $20
  JR NZ,L9D47
  LD A,B
  AND $01
  LD A,L
  JR Z,L9D47
L9D34_0:
  CALL L8D9C_0
  RET

; Routine at 9D47
;
; Key range check. Keys $22/'@' are mapped to $22. Keys $21–$2A (directory/path
; characters) pass to L8DED_0. All other keys pass to L9D4F (extended key
; handler).
L9D47:
  CP $22
  JR Z,L9D5E
  CP $40
  JR NZ,L9D47_0
  LD A,$22
L9D47_0:
  CP $21
  JR C,L9D5E
  CP $2B
  JR NC,L9D5E
  CALL L8DF7_0
  JR wait_key_4

; Routine at 9D5E
;
; Route key to the key-handler dispatch table (L8EF8).
L9D5E:
  CALL key_dispatch
  RET

; Routine at 9D62
;
; Return A=0. Null input stub used when joystick is absent or disabled.
L9D62:
  XOR A
  RET

; Routine at 9D64
;
; Read Kempston joystick with debounce. Reads port $1F twice; if readings
; agree, maps the 5-bit direction+fire pattern via L9D64. Returns A = encoded
; key code.
L9D64:
  IN A,($1F)
  CP $FF
  RET Z
  LD B,$00
  LD C,A
  IN A,($1F)
  CP C
  JR Z,L9D73
  XOR A
  RET

; Routine at 9D73
;
; Map Kempston joystick bits to browser key codes. Indexes the L9D77 direction
; table using bits 0–4 of A, ORs in $C0 if fire is pressed.
L9D73:
  AND $E0
  JR Z,L9D73_0
  LD B,$C0
L9D73_0:
  LD A,C
  AND $1F
  LD E,A
  LD D,$00
  LD HL,$9D86
  ADD HL,DE
  LD A,(HL)
  OR B
  RET
  NOP

; Routine at 9D87
;
; Self-modifying entry stub overwritten at runtime with border-flash colour
; values. Continues to L9D78_0.
L9D87:
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
; This entry point is used by the routine at L8D0F.
L9D87_0:
  CALL set_border
  LD B,$14
  CALL wait_frames
  LD A,(LA3E0)
  CALL set_border
  RET

; Routine at 9DB5
;
; Initialise display colours and clear the screen. Reads the colour scheme from
; LA3CA–LA3CD; calls L9706 (clear display), L971D (set border), L9726 (fill
; attribute rows), and L9FB8 (draw status bar).
init_display_colors:
  LD A,(LA3E1)
  CALL clear_display
  LD A,(LA3E0)
  CALL set_border
  LD A,(LA3DE)
  LD C,A
  LD B,$00
  CALL fill_attr_row
  LD A,(LA3DF)
  LD C,A
  LD B,$17
  CALL fill_attr_row
  CALL update_status_bar
  RET

; Routine at 9DD7
;
; Main browser event loop. Waits for keyboard or joystick input via L9CCF_1,
; then saves bookmark (L945F), handles plugin return (LA1C0), and processes
; device state (LA16B).
main_loop:
  CALL wait_key_1
  LD A,($BBE3)
  AND A
  JR Z,main_loop
  CALL save_bookmark
  CALL LA1D4
  CALL LA17F
  RET

; Routine at 9DEA
;
; System initialisation. If A is non-zero: copies NMI handler from $3200 to
; $C000 and pages it to $3E00 via DivMMC port $E3. Then: detects UNO/Next
; (LA11F), loads settings (LA1CC), loads browse config (L8732_0), sets input
; handler at $BFA7, clears display, queries drive status (L9E46), and navigates
; to the startup directory (L8F73/L9E26).
;
; A Non-zero = copy and install NMI handler before init; 0 = skip NMI install
init:
  OR A
  JR Z,init_0
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
init_0:
  CALL detect_uno
  CALL LA1E0
  CALL load_config_0
  LD HL,L9D62
  LD A,(LA3E5)
  AND $02
  JR Z,init_1
  LD HL,L9D64
init_1:
  LD ($BFA7),HL
  CALL init_display_colors
  CALL L9E5A
  XOR A
  LD (LA3EC),A
  CALL detect_fs
  OR A
  JR Z,L9E35
  JR L9E35_1

; Routine at 9E35
;
; Browser startup. Calls L8754 (browser init), L9414 (restore bookmark), and
; L8595 for the initial directory listing. Returns the border colour to set.
L9E35:
  CALL browser_init
  CALL L9423
  OR A
  LD A,$0B
  JR NZ,L9E35_0
  OR $04
L9E35_0:
  CALL load_dir
  LD A,(LA3EC)
  OR A
  JR Z,L9E53
  LD A,$03
; This entry point is used by the routine at init.
L9E35_1:
  LD B,A
  CALL set_border
  LD A,B
  RET

; Routine at 9E53
;
; Update status bar only (no directory reload). Calls L9FB8_0 with $04 and
; returns A=0.
L9E53:
  LD A,$04
  CALL update_status_bar_0
  XOR A
  RET

; Routine at 9E5A
;
; Query drive information. Calls esxDOS m_dosversion ($88) and stores the
; returned HL to $BF64.
L9E5A:
  RST $08
  DEFB $88
  LD ($BF64),HL
  RET

; Routine at 9E60
;
; 16-bit unsigned multiply. Computes 32-bit result DEHL = HL × BC using a
; shift-and-add loop.
;
;        HL Multiplicand
;        BC Multiplier
; Output: DE:HL 32-bit product
mul16:
  PUSH HL
  EXX
  POP DE
  LD B,H
  LD C,L
  LD A,$10
  LD HL,$0000
mul16_0:
  ADD HL,HL
  RL E
  RL D
  JR NC,mul16_1
  ADD HL,BC
  JR NC,mul16_1
  INC DE
mul16_1:
  DEC A
  JR NZ,mul16_0
  OR A
  RET

; Routine at 9E7A
;
; 32-bit unsigned multiply. Computes 64-bit result {HL,DE} × {HL',DE'} using a
; 32-bit shift-and-add loop. Used for large file offset calculations.
mul32:
  LD A,E
  OR D
  EXX
  OR E
  OR D
  JR Z,mul16
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
mul32_0:
  RRA
  RR C
  EXX
  RR B
  RR C
  JR NC,mul32_1
  ADD HL,DE
  EXX
  ADC HL,DE
  EXX
mul32_1:
  SLA E
  RL D
  EXX
  RL E
  RL D
  DJNZ mul32_0
  PUSH HL
  EXX
  POP DE
  OR A
  RET

; Routine at 9EB1
;
; 32-bit unsigned divide. Computes HL / BC (with DE as upper word) using
; partial-division helpers L9EC0 and L9F34.
div32:
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
  JR NC,L9ECD
  PUSH DE
  EX DE,HL
  LD HL,$0000
  CALL L9ED4
  EX DE,HL
  EX (SP),HL
  EX DE,HL
  CALL L9F48
  POP BC
  RET

; Routine at 9ECD
;
; Division tail: calls L9F34 and returns BC=0.
L9ECD:
  CALL L9F48
  LD BC,$0000
  RET

; Routine at 9ED4
;
; 32-bit division partial step (inner loop unrolled 8 times, first half).
L9ED4:
  CALL L9ED4_0
L9ED4_0:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9ED4_1
  ADD HL,BC
  INC DE
L9ED4_1:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9ED4_2
  ADD HL,BC
  INC DE
L9ED4_2:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9ED4_3
  ADD HL,BC
  INC DE
L9ED4_3:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9ED4_4
  ADD HL,BC
  INC DE
L9ED4_4:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9ED4_5
  ADD HL,BC
  INC DE
L9ED4_5:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9ED4_6
  ADD HL,BC
  INC DE
L9ED4_6:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9ED4_7
  ADD HL,BC
  INC DE
L9ED4_7:
  SLA E
  RL D
  ADC HL,HL
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9ED4_8
  ADD HL,BC
  INC DE
L9ED4_8:
  RET

; Routine at 9F48
;
; 32-bit division partial step (inner loop unrolled 8 times, second half).
L9F48:
  CALL L9F48_0
L9F48_0:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F48_1
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F48_2
L9F48_1:
  ADD HL,BC
  INC DE
L9F48_2:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F48_3
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F48_4
L9F48_3:
  ADD HL,BC
  INC DE
L9F48_4:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F48_5
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F48_6
L9F48_5:
  ADD HL,BC
  INC DE
L9F48_6:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F48_7
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F48_8
L9F48_7:
  ADD HL,BC
  INC DE
L9F48_8:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F48_9
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F48_10
L9F48_9:
  ADD HL,BC
  INC DE
L9F48_10:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F48_11
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F48_12
L9F48_11:
  ADD HL,BC
  INC DE
L9F48_12:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F48_13
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F48_14
L9F48_13:
  ADD HL,BC
  INC DE
L9F48_14:
  SLA E
  RL D
  ADC HL,HL
  JR C,L9F48_15
  LD A,L
  ADD A,C
  LD A,H
  ADC A,B
  JR NC,L9F48_16
L9F48_15:
  ADD HL,BC
  INC DE
L9F48_16:
  RET

; Routine at 9FCC
;
; Update the full status bar. Calls L9FB8_0 with $0F (all fields: version,
; position, icons, drive).
update_status_bar:
  LD A,$0F
; This entry point is used by the routines at L8C16, L8C35, enter_item, L8D57,
; exec_file and L9E53.
update_status_bar_0:
  LD IXl,A
  AND $08
  JR Z,update_status_bar_2
  LD A,($BBE5)
  AND A
  LD A,$20
  JR NZ,update_status_bar_1
  XOR A
update_status_bar_1:
  LD (LA0C4),A
  LD HL,LA0B5
  LD C,$00
  CALL LA08A
update_status_bar_2:
  LD A,IXl
  AND $04
  JR Z,render_status_fields
  LD DE,LA0AC
  LD HL,($BBEF)
  INC HL
  CALL LA090
  LD DE,LA0B0
  LD HL,($BBE9)
  CALL LA090
  LD HL,LA0AC
  LD C,$0F
  CALL LA08A
  JR render_status_fields_0

; Routine at A00B
;
; Render the status bar fields. Updates the entry position counter (N/total),
; plugin/flag icons, and the optional 5-byte drive/speed indicator in the
; bottom status line area.
render_status_fields:
  LD A,IXl
  AND $02
  JR Z,render_status_fields_3
; This entry point is used by the routine at update_status_bar.
render_status_fields_0:
  LD B,$04
  LD C,$01
  LD HL,LA0A7
  LD E,$30
render_status_fields_1:
  LD D,$2D
  LD A,($BBE2)
  AND C
  JR Z,render_status_fields_2
  LD D,E
render_status_fields_2:
  LD (HL),D
  INC HL
  SLA C
  INC E
  DJNZ render_status_fields_1
  LD HL,LA0A7
  LD C,$15
  CALL LA08A
render_status_fields_3:
  LD A,(LA3E5)
  AND $40
  RET Z
  LD B,$05
  LD DE,$50FA
render_status_fields_4:
  PUSH BC
  LD HL,LA0C9
  LD B,$08
  LD C,D
render_status_fields_5:
  LD A,(HL)
  LD (DE),A
  INC HL
  INC D
  DJNZ render_status_fields_5
  INC E
  LD D,C
  POP BC
  DJNZ render_status_fields_4
  LD A,(LA3DF)
  AND $F8
  LD C,A
  AND $40
  JR Z,render_status_fields_7
  LD B,$03
  LD HL,LA0D2
render_status_fields_6:
  LD A,(HL)
  OR $40
  LD (HL),A
  INC HL
  DJNZ render_status_fields_6
  LD A,C
render_status_fields_7:
  LD HL,LA0D1
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
  LD HL,LA0D5
  LD A,(HL)
  OR C
  LD (HL),A
  LD HL,LA0D1
  LD DE,$5AFA
  LD BC,$0005
  LDIR
  RET

; Routine at A08A
;
; Render the text string at HL on the status row ($17) using L97B4.
LA08A:
  LD B,$17
  CALL draw_string
  RET

; Routine at A090
;
; Convert HL to a decimal digit string at (DE). Uses repeated subtraction to
; produce up to 3 digits (hundreds, tens, units). Used for "NNN/NNN" position
; display.
LA090:
  LD BC,$FF9C
  CALL LA090_0
  LD C,$F6
  CALL LA090_0
  LD C,B
LA090_0:
  LD A,$2F
LA090_1:
  INC A
  ADD HL,BC
  JR C,LA090_1
  SBC HL,BC
  LD (DE),A
  INC DE
  RET

; Message at A0A7
;
; Status bar spacer "    " (4 spaces) — blank field template.
LA0A7:
  DEFM "    "

; Data block at A0AB
;
; NUL terminator byte.
LA0AB:
  DEFB $00

; Message at A0AC
;
; Position field work string "000/" (overwritten in-place with the current
; entry number).
LA0AC:
  DEFM "000/"

; Message at A0B0
;
; Position field work string "000" (overwritten with the total entry count).
LA0B0:
  DEFM "000"

; Data block at A0B3
;
; Status bar display control flags ($81 = show version string + position
; counter).
LA0B3:
  DEFB $81,$00

; Message at A0B5
;
; Version string ".browse v1.02a2" — shown in the status bar when $BBE5 is
; clear.
LA0B5:
  DEFM ".browse v1.02a2"

; Data block at A0C4
;
; NMI status byte: $20 = NMI active (shown as 'N' in status bar), $00 =
; inactive (shown as space).
LA0C4:
  DEFB $20

; Message at A0C5
;
; NMI indicator string "NMI".
LA0C5:
  DEFM "NMI"

; Data block at A0C8
;
; NUL terminator for L$A0B1.
LA0C8:
  DEFB $00

; Data block at A0C9
;
; Proportional font pixel-width step table (7 bytes: 1, 3, 7, 15, 31, 63, 127).
; Used by the string-width accumulator in L97B4.
LA0C9:
  DEFB $01,$03,$07,$0F,$1F,$3F,$7F

; Data block at A0D0
;
; $FF end-of-width-step-table marker.
LA0D0:
  DEFB $FF

; Data block at A0D1
;
; Status bar attribute byte for the position-counter field.
LA0D1:
  DEFB $02

; Data block at A0D2
;
; Status bar attribute bytes for the flag icon area (3 bytes:
; flash/bright/colour for P, X, N icons).
LA0D2:
  DEFB $16,$34,$25

; Data block at A0D5
;
; Status bar attribute byte for the drive/mode indicator field.
LA0D5:
  DEFB $28

; Routine at A0D6
;
; JP (HL) trampoline. Jumps to the address held in HL — used to call variable
; dispatch targets without an indirect CALL instruction.
LA0D6:
  JP (HL)

; Routine at A0D7
;
; Busy-wait loop. Enables interrupts, executes B HALT instructions (each ~20 ms
; at 50 Hz), then disables interrupts. Used for brief timed pauses.
;
; B Number of 50 Hz frames to wait
wait_frames:
  EI
wait_frames_0:
  HALT
  DJNZ wait_frames_0
  DI
  RET

; Routine at A0DD
;
; Wait for any key to be pressed. Polls port $FE until all keys are released
; ($1F), then loops on HALT until a key is detected.
wait_any_key:
  XOR A
  IN A,($FE)
  AND $1F
  CP $1F
  JR NZ,wait_any_key
  EI
wait_any_key_0:
  HALT
  XOR A
  IN A,($FE)
  CPL
  AND $1F
  JR NZ,wait_any_key_1
  DJNZ wait_any_key_0
wait_any_key_1:
  DI
  RET

; Routine at A0F4
;
; Advance DE to the NUL terminator of a string. Returns DE pointing to the $00
; byte.
;
;        DE Pointer to NUL-terminated string
; Output: DE Pointer to the NUL byte
strend:
  LD A,(DE)
  OR A
  JR Z,strappend
  INC DE
  JR strend

; Routine at A0FB
;
; Append the NUL-terminated string at HL onto the end of the string at DE (DE
; points to the NUL from L$A0E0). Copies characters until NUL, writing count to
; C.
;
;        HL Source string pointer
;        DE Pointer to destination NUL (end of existing string)
; Output: C Number of characters copied
strappend:
  LD C,$00
strappend_0:
  LD A,(HL)
  LD (DE),A
  AND A
  RET Z
  INC C
  INC HL
  INC DE
  JR strappend_0

; Routine at A106
;
; No-op return stub.
LA106:
  RET

; Routine at A107
;
; Find the first occurrence of NUL-terminated pattern HL inside NUL-terminated
; string DE. Returns DE pointing to the match start, or Fc=1 if not found.
;
;        HL Search pattern (NUL-terminated)
;        DE String to search in (NUL-terminated)
; Output: DE Pointer to match start; Fc=1 if not found
strstr:
  LD A,(HL)
  OR A
  JR Z,LA131
; This entry point is used by the routine at LA119.
strstr_0:
  LD A,(DE)
  CP (HL)
  JR Z,LA119
  INC DE
  OR A
  JR NZ,strstr_0
; This entry point is used by the routine at LA119.
strstr_1:
  EX DE,HL
  LD HL,$0000
  SCF
  RET

; Routine at A119
;
; Verify that a full match of the pattern occurs at the current DE position.
; Calls back to LA0F3_0 on mismatch to continue scanning.
LA119:
  PUSH DE
  PUSH HL
  EX DE,HL
LA119_0:
  INC DE
  INC HL
  LD A,(DE)
  OR A
  JR Z,LA12E
  CP (HL)
  JR Z,LA119_0
  LD A,(HL)
  POP HL
  POP DE
  INC DE
  OR A
  JR NZ,strstr_0
  JR strstr_1

; Routine at A12E
;
; Pop saved registers and return — match successfully confirmed. Tail of
; L$A105.
LA12E:
  POP DE
  POP HL
  RET

; Routine at A131
;
; Swap DE and HL and return. Used when the search pattern is empty (matches
; start of string).
LA131:
  EX DE,HL
  RET

; Routine at A133
;
; Detect UNO/NextZXOS hardware. Outputs $FF to port $FC3B, reads $FD3B and
; counts valid ASCII responses. If 2 or more valid bytes are seen, sets LA1B1=1
; (device present) and stores the firmware version in LA1B2.
detect_uno:
  XOR A
  LD (LA1C5),A
  LD (LA1C6),A
  LD BC,$FC3B
  LD A,$FF
  OUT (C),A
  LD L,$00
detect_uno_0:
  LD BC,$FD3B
  IN A,(C)
  AND A
  JR Z,LA156
  CP $20
  JR C,LA156
  CP $80
  JR NC,LA156
  INC L
  JR detect_uno_0

; Routine at A156
;
; Confirm UNO/Next presence. Stores LA1B1=1 and reads the device version byte
; into LA1B2. Called after LA11F counts enough valid responses.
LA156:
  LD A,L
  CP $02
  RET C
  LD A,$01
  LD (LA1C5),A
  LD BC,$FC3B
  LD A,$40
  OUT (C),A
  XOR A
  LD BC,$FD3B
  IN A,(C)
  LD (LA1C6),A
  AND A
  RET Z
  LD BC,$FC3B
  LD A,$40
  OUT (C),A
  XOR A
  LD BC,$FD3B
  OUT (C),A
  RET

; Routine at A17F
;
; Send pending UNO/Next command. If LA1B1 (device present) and LA1B2 (command
; byte) are both non-zero, outputs the command to port $FD3B.
LA17F:
  LD A,(LA1C5)
  AND A
  RET Z
  LD A,(LA1C6)
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

; Routine at A198
;
; Switch DivMMC/UNO memory bank. If LA1B1 is zero (no device), returns
; immediately. If L=0, outputs $0B to port $FC3B and the saved bank byte from
; LA1B3 to $FD3B. If L non-zero, saves current bank state from $FD3B to LA1B3,
; then outputs $0B+$C0 to switch.
;
; L 0 = restore saved bank; non-zero = save current bank and switch
uno_bank_out:
  LD A,(LA1C5)
  AND A
  RET Z
  LD BC,$FC3B
  LD A,L
  AND A
  JR NZ,LA1B1
  LD A,$0B
  OUT (C),A
  LD A,(LA1C7)
  LD BC,$FD3B
  OUT (C),A
  RET

; Routine at A1B1
;
; Save current UNO bank state: reads port $FD3B, stores in LA1B3, then switches
; to the new bank.
LA1B1:
  LD A,$0B
  OUT (C),A
  LD BC,$FD3B
  IN A,(C)
  LD (LA1C7),A
  OR $C0
  LD BC,$FD3B
  OUT (C),A
  RET

; Data block at A1C5
;
; UNO/Next device-present flag: 0 = not detected, 1 = device present.
LA1C5:
  DEFB $00

; Data block at A1C6
;
; UNO/Next firmware version byte (read during detection).
LA1C6:
  DEFB $00

; Data block at A1C7
;
; Saved UNO/Next bank register value (used by L$A184 to save/restore bank
; context).
LA1C7:
  DEFB $00

; Routine at A1C8
;
; Write a DivMMC bank register pair. Outputs D to port $BF3B and E to port
; $FF3B.
;
; D High bank register value
; E Low bank register value
LA1C8:
  LD BC,$BF3B
  OUT (C),D
  NOP
  LD BC,$FF3B
  OUT (C),E
  RET

; Routine at A1D4
;
; Restore DivMMC bank registers to the values saved at LA1E6. Called on return
; from plugin. If LA1E6 is zero, returns immediately.
LA1D4:
  LD A,(LA1FA)
  AND A
  RET Z
  LD DE,$4001
  CALL LA1C8
  RET

; Routine at A1E0
;
; Save current DivMMC bank registers from port $FF3B into LA1E6. Reads the port
; and stores; if non-zero, switches to bank $4000.
LA1E0:
  LD BC,$BF3B
  LD A,$40
  OUT (C),A
  NOP
  LD BC,$FF3B
  IN A,(C)
  LD (LA1FA),A
  AND A
  RET Z
  LD DE,$4000
  CALL LA1C8
  RET

; Routine at A1F9
;
; No-op return stub.
LA1F9:
  RET

; Data block at A1FA
;
; Saved DivMMC bank register value from before plugin call (restored by LA1C0).
LA1FA:
  DEFB $00

; Message at A1FB
;
; Error string "Err" — shown in the status bar when a plugin returns an error.
LA1FB:
  DEFM "Err"

; Routine at A1FE
;
; Self-modifying entry: bytes overwritten at runtime with LD L,A / LD (HL),D.
LA1FE:
  LD L,A
  LD (HL),D

; Data block at A200
;
; Self-modifying 2-byte parameter: LD HL,n operand.
LA200:
  DEFB $21,$00

; Data block at A202
;
; Plugin invocation mode byte ($50).
LA202:
  DEFB $50

; Routine at A203
;
; Self-modifying entry: bytes overwritten at runtime with LD L,H / LD (HL),L /
; LD H,A / LD L,C / LD L,(HL).
LA203:
  LD L,H
  LD (HL),L
  LD H,A
  LD L,C
  LD L,(HL)

; Data block at A208
;
; Self-modifying 2-byte parameter used by the plugin invocation stubs.
LA208:
  DEFB $3A,$00

; Routine at A20A
;
; Invoke an external plugin identified by a 3-character extension string in HL.
; Prepends '_' to the extension in LA365, appends the path "/bin/bplugins/",
; loads and runs the plugin binary from $8000 via L$A22A.
;
; HL Pointer to 3-character plugin extension string (e.g. "TXT", "HEX")
invoke_plugin:
  LD A,$5F
  LD DE,LA379
  PUSH DE
  LD (DE),A
  INC DE
  LD BC,$0003
  LDIR
  POP HL
  CALL LA222
  LD HL,LA36B
  CALL load_and_run_plugin
  RET

; Routine at A222
;
; Build the full config-plugin path. Appends the 4-byte extension from LA37C to
; the path at LA365, then appends ".cfg" from L8723.
LA222:
  LD DE,LA390
  XOR A
  LD (DE),A
  PUSH DE
  CALL strend
  POP DE
  LD HL,L8723
  CALL strend
  RET

; Routine at A233
;
; Clear the 8-byte scroll-indicator buffer at $50F8–$50FF.
LA233:
  LD DE,$50F8
  LD B,$08
  XOR A
LA233_0:
  LD (DE),A
  INC D
  DJNZ LA233_0
  RET

; Routine at A23E
;
; Load and execute the plugin binary. Banks in DivMMC page at $8C (port $E3),
; copies the current $8000 code to $2000 (save), loads the plugin from
; "/bin/bplugins/" + extension via L93CB, then calls $8000 with filename,
; config, and mode parameters. On return, restores $8000, re-banks, and
; processes the plugin return flags in LA3AF.
load_and_run_plugin:
  XOR A
  LD (LA3C3),A
  LD A,($5B5C)
  AND A
  JR NZ,load_and_run_plugin_0
  LD A,$10
load_and_run_plugin_0:
  LD (LA3C7),A
  LD A,($BBE5)
  LD (LA3C8),A
  AND A
  LD A,$02
  JR Z,load_and_run_plugin_1
  PUSH HL
  LD HL,($BBF1)
  LD BC,$001E
  ADD HL,BC
  LD A,(HL)
  LD (LA3C7),A
  POP HL
  XOR A
load_and_run_plugin_1:
  LD (LA27D),A
  LD (LA2EB),A
  PUSH HL
  LD A,$8C
  OUT ($E3),A
  LD HL,$8000
  LD DE,$2000
  LD BC,$2000
  LDIR

; Data block at A27C
;
; Self-modify byte ($3E = LD A,n opcode) for bank-switch sequence in L$A22A.
LA27C:
  DEFB $3E

; Data block at A27D
;
; Self-modifying DivMMC bank page number loaded before calling the plugin at
; $8000.
LA27D:
  DEFB $00

; Routine at A27E
;
; Execute the loaded plugin at $8000. Switches in the plugin page, opens the
; config file (LA36A), calls $8000 with filename/config/mode args, then
; restores the original page and processes the return code in LA3AF.
call_plugin:
  ADD A,$80
  OUT ($E3),A
  POP HL
  LD DE,$8000
  LD BC,$0000
  CALL file_open_read
  XOR A
  OR L
  JR Z,call_plugin_2
  LD A,($8006)
  LD E,A
  AND $01
  JR Z,call_plugin_0
  LD HL,LA3DE
  LD DE,$8008
  LD BC,$000E
  LDIR
call_plugin_0:
  LD HL,LA37E
  LD DE,LA3CE
  LD BC,$0000
  CALL file_open_read
  LD DE,LA3CE
  LD A,H
  OR L
  JR NZ,call_plugin_1
  LD DE,$0000
call_plugin_1:
  LD HL,$BBF3
  LD BC,LA3C7
  CALL $8000
call_plugin_2:
  LD (LA3C3),A
  LD (LA3C4),BC
  AND $D0
  JR Z,call_plugin_3
  LD A,B
  OR C
  JR Z,call_plugin_3
  LD H,B
  LD L,C
  LD DE,LA399
  LD BC,$002A
  LDIR
call_plugin_3:
  LD A,$8C
  OUT ($E3),A
  LD HL,$2000
  LD DE,$8000
  LD BC,$2000
  LDIR

; Data block at A2EA
;
; Self-modify byte ($3E = LD A,n opcode) for bank restore sequence.
LA2EA:
  DEFB $3E

; Data block at A2EB
;
; Self-modifying DivMMC page number for restoring after plugin call.
LA2EB:
  DEFB $00

; Routine at A2EC
;
; Process plugin return. Checks LA3AF flags: $80 = show error string; $10 =
; show info string (from LA385); $04 = reload directory; $02 and not $08 and
; LA3B2=0 = call LA344 (full display reinit).
plugin_return:
  ADD A,$80
  OUT ($E3),A
  LD A,(LA3C3)
  AND $80
  JR Z,plugin_return_0
  LD HL,LA1FB
  CALL L8C60
  LD HL,LA399
  LD BC,$1600
  CALL draw_string
  CALL wait_key
  CALL wait_keys_up
  CALL wait_key
  CALL LA352
plugin_return_0:
  LD A,(LA3C3)
  AND $10
  JR Z,plugin_return_1
  LD HL,LA202
  CALL L8C60
  LD HL,LA399
  LD BC,$1600
  CALL draw_string
  LD B,$60
  CALL wait_any_key
  CALL LA352
plugin_return_1:
  LD A,(LA3C3)
  AND $04
  JR Z,plugin_return_2
  CALL LA365
plugin_return_2:
  LD A,(LA3C3)
  AND $02
  JR Z,plugin_return_3
  LD A,(LA3C3)
  AND $08
  JR NZ,plugin_return_3
  LD A,(LA3C6)
  AND A
  JR NZ,plugin_return_3
  CALL LA358
plugin_return_3:
  RET

; Routine at A352
;
; Reload directory (L=0 flag to L8C80). Called after plugin modifies the
; directory.
LA352:
  LD L,$00
  CALL L8C85
  RET

; Routine at A358
;
; Reinitialise the full display. Calls L9DA6 (clear screen + colours), L8595
; with flags=$09 (full reload), and clears LA3B2 (needs-reload flag).
LA358:
  CALL init_display_colors
  LD A,$09
  CALL load_dir
  XOR A
  LD (LA3C6),A
  RET

; Routine at A365
;
; Partial directory reload. Calls L8595 with flags=$0A.
LA365:
  LD A,$0A
  CALL load_dir
  RET

; Message at A36B
;
; Plugin base path "/bin/bplugins/" — prefix used when loading plugin binaries.
LA36B:
  DEFM "/bin/bplugins/"

; Message at A379
;
; Plugin extension work buffer "????" — overwritten in-place with '_' + 3-char
; extension by L$A1F6.
LA379:
  DEFM "????"

; Data block at A37D
;
; NUL terminator for L$A365.
LA37D:
  DEFB $00

; Message at A37E
;
; Plugin config path "/bin/bplugins/cfg/" — used to load per-extension config
; files.
LA37E:
  DEFM "/bin/bplugins/cfg/"

; Data block at A390
;
; Full plugin config path buffer (9 bytes). Built by LA20E: L$A36A + extension
; + ".cfg" + NUL.
LA390:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00

; Data block at A399
;
; Plugin message / info string buffer (42 bytes). Filled by the plugin at $8000
; when it returns flag $10 or $D0 in LA3AF.
LA399:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00

; Data block at A3C3
;
; Plugin return code byte. Written by the plugin at $8000 on return: $01 =
; files changed (reload); $02 = update display; $04 = reload dir; $08 = quiet;
; $10 = show info string; $40 = cursor moved; $80 = error string; $D0 = show
; result.
LA3C3:
  DEFB $00

; Data block at A3C4
;
; Plugin cursor-mode byte (lo = cursor advance code, hi = plugin-type).
LA3C4:
  DEFB $00,$00

; Data block at A3C6
;
; Directory-needs-reload flag. Set by plugin return; cleared by LA344.
LA3C6:
  DEFB $00

; Data block at A3C7
;
; DivMMC memory bank page number for the plugin.
LA3C7:
  DEFB $00

; Data block at A3C8
;
; Cartridge/ROM mode byte at the time of the plugin call.
LA3C8:
  DEFB $00

; Data block at A3C9
;
; Plugin mode parameter (set by the dispatcher before calling LA1F6).
LA3C9:
  DEFB $00

; Data block at A3CA
;
; Plugin parameter block pointer (4 bytes). Usually the address of the current
; 18-byte directory entry.
LA3CA:
  DEFB $00,$00,$00,$00

; Data block at A3CE
;
; Plugin config data buffer (16 bytes). Loaded from
; "/bin/bplugins/cfg/<ext>.cfg" before calling the plugin.
LA3CE:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00,$00,$00,$00

; Data block at A3DE
;
; Header row background attribute byte (default $78 = white on black).
LA3DE:
  DEFB $78

; Data block at A3DF
;
; Status bar background attribute byte (default $47 = white on blue).
LA3DF:
  DEFB $47

; Data block at A3E0
;
; Border colour index (default $07 = white).
LA3E0:
  DEFB $07

; Data block at A3E1
;
; Normal directory entry text attribute (default $38 = black on white).
LA3E1:
  DEFB $38

; Data block at A3E2
;
; Directory/folder entry highlight attribute (default $39 = blue on white).
LA3E2:
  DEFB $39

; Data block at A3E3
;
; Selected/cursor row attribute (default $68 = black on green).
LA3E3:
  DEFB $68

; Data block at A3E4
;
; Current drive letter / colour theme index. Updated by L9535 (opendir) and
; L8F8E (colour scheme).
LA3E4:
  DEFB $01

; Data block at A3E5
;
; Feature flags byte 0: bit 6=$40 = proportional font enabled; bit 5=$20 =
; cache enabled; bit 4=$10 = bookmark persistence enabled; bit 1=$02 =
; joystick/Kempston enabled; bit 0=$01 = show "<DIR" markers. Byte 1: extended
; flags.
LA3E5:
  DEFB $40,$00

; Data block at A3E7
;
; Special key remapping table (5 bytes). Cursor keys and Enter: $0B=cursor-up,
; $0A=cursor-down, $08=cursor-left, $09=cursor-right, $0D=Enter. Matched by
; L9CCF via CPIR and remapped to L8EB2 action codes.
LA3E7:
  DEFB $0B,$0A,$08,$09,$0D

; Data block at A3EC
;
; Last esxDOS error code from a failed file operation. Stored by L93CB/L93E2;
; cleared by L94AC.
LA3EC:
  DEFB $00

