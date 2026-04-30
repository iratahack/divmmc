@ $84D0 start
@ $84D0 org
@ $84D0 label=main
D $84D0 Main entry point. Saves the caller's SP via self-modifying code at L84E9. If $BBE5 is non-zero the stack is reset to $7FFF (DivMMC cartridge mode). Calls init (L9DDB) then the main event loop (L9DC8).
c $84D0
D $84E8 LD SP operand byte. Self-modified by L84D0 to save the original SP value on entry.
b $84E8
D $84E9 Saved stack pointer written by the LD (L84E9),SP at L84D0.
b $84E9
D $84EB Stub return — placeholder or unused entry point.
c $84EB
@ $84EC label=get_entry_ptr
D $84EC Calculate the address of directory entry N in the $C200 buffer. Computes HL = (N*18) + $C200 and stores the result in $BF62. Each 18-byte entry contains: 1 flag byte + 11 filename chars + 2 size bytes + 2 start-cluster bytes + 2 attribute bytes.
R $84EC HL Entry index N (0-based); treated as 0 when HL = 0
R $84EC Output: HL Pointer to entry; $BF62 also updated
c $84EC
@ $84FF label=get_current_name
D $84FF Fetch the display filename for the currently selected entry. Reads the entry index from $BBEF, calls L84EC to compute the entry address, then L8526 to format the 8.3 name into $BBF3.
c $84FF
@ $850A label=get_cluster_addr
D $850A Get FAT cluster address for a directory entry. Reads the 2-byte start-cluster field at offset +$0C in the 18-byte entry. If zero, returns Fc=1. Otherwise returns HL = $E000 + cluster with Fc=0.
R $850A HL Pointer to directory entry (base of 18-byte structure)
R $850A Output: HL FAT sector address ($E000 + cluster), Fc=1 if cluster is zero
c $850A
D $851D Return with carry set and HL pointing to the entry. Tail of L850A when cluster field is zero.
c $851D
D $8521 Add FAT base address $E000 to HL.
R $8521 HL Cluster number
R $8521 Output: HL FAT sector address ($E000 + cluster)
c $8521
@ $8526 label=fmt_dosname
D $8526 Copy and format a DOS 8.3 filename from a directory entry into the display buffer at DE ($BBF3). Reads up to 8 printable characters from HL, stops at NUL or non-printable. Tracks character count in C.
R $8526 HL Source: pointer to 8.3 filename in directory entry
R $8526 DE Destination buffer ($BBF3 on entry)
R $8526 C Character count (0 on entry)
c $8526
D $853E Self-modify byte: replaced at runtime with the opcode for LD L,$12 used in L853F to indicate the name overflows into an extension component.
b $853E
D $853F Continuation of filename copy. Stores character B at (DE), advances DE.
c $853F
D $8549 Null-terminate the display name: writes $00 to (DE).
c $8549
D $854C Trim path display. Checks LA3D1 bit 2 (dir-cache flag); if set, scans the directory list at $BC00 counting NUL-terminated entries and clears $BF6D / $BF70.
c $854C
D $8560 Find the last '/' path separator in the path buffer $BC00. Scans backward from position C; if none found, returns without updating $BF70.
c $8560
D $857E Copy the last path component (after the final '/') to $BF70 using LA0E0 append-copy.
c $857E
t $858A
D $858A Status message "Working..." shown during long directory loads.
b $8594
D $8594 Directory-load progress flag byte.
@ $8595 label=load_dir
D $8595 Load or refresh the directory listing. A is a flag byte: bit 2 ($04) = reset scroll positions; bit 1 ($02) = update display; bit 3 ($08) = suppress "Working..." message; bit 4 ($10) = suppress display. Calls L94AC to try the cache, then navigates to the stored path and builds the entry list.
R $8595 A Flags: $04=reset scroll, $02=update display, $08=quiet, $10=no display
c $8595
D $85BC Display-side continuation of L8595. Shows "Working..." if needed, loads via L9105, then triggers rendering.
c $85BC
D $863F Self-modify byte: replaced at runtime with an opcode used by the L8642 entry-scan loop.
b $863F
D $8640 Self-modifying pointer: current directory entry pointer used by the L85BC scan loop.
b $8640
D $8642 Advance to the next entry in the directory scan started at L85BC. Increments the entry pointer by 18 bytes and decrements the remaining count; loops back while more entries remain.
c $8642
D $8666 Self-modify byte: replaced at runtime with LD A,n opcode.
b $8666
D $8667 Display flags byte written by L85BC. Bit 0=directory entered, bit 1=update display, bit 3=quiet, bit 4=preview update.
b $8667
D $8668 Handle preview-panel update. If bit 4 of L8667 is set, draws the 31-character preview bar (L867E). Then calls L89F4 to refresh the status display.
c $8668
D $867E Self-modifying two-byte parameter for the preview-bar draw call at L8668.
b $867E
@ $8680 label=nav_path
D $8680 Navigate to a path component inside the cached directory list at $BC00. DE points to the next path segment (NUL-terminated). Scans all 18-byte entries in HL looking for a case-insensitive name match. On match, copies size/cluster fields to $BF66 and calls L9105. Advances DE past the next '/' on each recursive entry.
R $8680 HL Pointer to start of directory list ($BC00)
R $8680 DE Pointer to path component string (NUL-terminated)
c $8680
D $86F4 Skip to next entry in the L8680 navigation scan. Advances HL by 18 bytes, decrements entry count BC; loops back to L8680_1 if more remain.
c $86F4
D $86FF Self-modify byte: replaced at runtime with LD DE,n opcode.
b $86FF
D $8700 Self-modifying pointer: current path pointer used by L8680 scan.
b $8700
D $8702 Append '/' to the path string at DE, then copy the pointer to $BFAA and advance DE into the next path component.
c $8702
D $870F Clear path-navigation state flag ($BF89 = 0) and return. Called when the DE path string reaches its NUL terminator.
c $870F
t $8718
D $8718 Path string "/bin/browse" — used when loading the browse config file.
t $8723
D $8723 Extension string ".cfg" — config file extension suffix.
b $8727
D $8727 NUL terminator byte following L8723.
t $8728
D $8728 Path prefix "/bin/brows" — used for plugin path building.
@ $8732 label=load_config
D $8732 Load browse configuration. Opens "/bin/browse.cfg" from the system drive '$', reads settings into $A3CA. Then loads the current-directory list from "/bin/brows" with offset $0308 into $9867.
c $8732
@ $8754 label=browser_init
D $8754 Initialize the browser and perform a full display refresh. Clears file cluster fields ($BF66/$BF68), calls L8595 with flags=$02 (update display), navigates the directory list from $BC00, and returns.
c $8754
D $8769 Find the file extension pointer in the current filename ($BBF3). Scans for the last '.' character; saves its address in DE.
R $8769 HL Pointer to start of filename ($BBF3)
R $8769 Output: DE Pointer to '.' separator, or zero if no extension found
c $8769
D $877C Handle file extension. Copies the 4-byte extension from DE to $BF7D, resets handler pointers at LA365/LA37C, then dispatches to the appropriate plugin via LA357 and LA20E.
c $877C
D $87D0 Adjust initial cursor position based on plugin-mode byte at LA3B0. Mode $03 resets $BBEF to 0; mode $04 moves to the last entry; mode $01 advances $BBEF by one (wrapping at total count).
c $87D0
D $87FB Move cursor backward one entry. Decrements $BBEF; if it reaches zero, jumps to L883B (plugin boundary check).
c $87FB
D $8808 After cursor move, check if the new entry matches the search filter at $BF7D. Re-renders if not at a matching entry; adjusts view via L8A94_0 otherwise.
c $8808
D $8830 Force scroll to keep cursor visible (calls L8A94_0 with $80), then re-reads the current entry filename via L84FF.
c $8830
D $883B Handle plugin boundary / cursor at position $BF82. Computes visible-window bounds for a 22-entry page and updates $BBEB/$BBED/$BBEF. On return, calls LA344 if LA3B2 (needs-reload flag) is set.
c $883B
D $8861 Set first-visible index $BBEB = 0 and last-visible $BBED = computed page end.
c $8861
@ $8877 label=render_dir_list
D $8877 Render the full directory listing. Takes IX=entry-render callback, DE=first entry address, HL=first entry index, BC=page size. Calls L8909 to compute the starting screen position, then iterates rendering up to 22 entries.
R $8877 IX Pointer to per-entry render routine (e.g. L8964)
R $8877 DE Pointer to first visible entry in buffer
R $8877 HL First visible entry index
R $8877 BC Number of entries to render
c $8877
D $88AC Render loop body: draws one entry row using the IX callback, then advances pointers and loops back.
c $88AC
D $88DC Continuation of directory-list render: copies pixel row from source to destination, moves to next entry, loops back via L88AC.
c $88DC
D $88D9 Self-modify byte ($CD = CALL opcode) for the self-modifying CALL in L88AC.
b $88D9
D $88DA Self-modifying call target address used by L88AC render loop.
b $88DA
s $88FB
D $88FD Saved first visible entry address (used by L88AC render loop).
b $88FD
D $88FF Saved first visible entry index (used by L88AC render loop).
b $88FF
D $8901 Scratch pointer 1 used by L8877 render loop.
b $8901
D $8903 Scratch pointer 2 used by L8877 render loop.
b $8903
D $8905 Saved page size (BC on entry to L8877).
b $8905
D $8907 Saved pointer used by L88DC scroll copy.
b $8907
D $8909 Compute a scaled screen address offset from two packed values. Multiplies/shifts parameters into a screen row offset for use in the render loop.
c $8909
D $8917 Shift-and-add multiplication helper. Computes HL = (A * 16 + C) or variants via bit accumulation.
c $8917
t $8929
D $8929 Directory-entry marker string "<DIR" appended to entries that are subdirectories.
@ $892D label=in_visible_range
D $892D Check if entry index DE is within the visible window [$BBEB..$BBED]. Returns A=1 if visible, A=0 if outside.
R $892D HL Entry index to test (also accepts call via L892D_0 with DE)
R $892D Output: A 1 if entry is in visible window, 0 if not
c $892D
D $8945 Return A=0 (not in visible range). Tail of L892D.
c $8945
@ $8947 label=clear_screen
D $8947 Clear the full browser screen area. Clears all 22 character rows (rows 1–22) by calling L978F for each. Then fills the attribute row at $5820 with the LA3CD background colour.
c $8947
D $8964 Compare two directory entries for ordering/matching. Reads start-cluster from both entries via L850A; compares 8.3 filenames case-insensitively byte by byte. Returns HL=0 if equal, HL=$0001 if entry 1 < entry 2, HL=$FFFF if entry 1 > entry 2.
R $8964 HL Pointer to first directory entry
R $8964 DE Pointer to second directory entry
R $8964 Output: HL 0=equal, $0001=less-than, $FFFF=greater-than
c $8964
D $8998 Return H = (A minus C) as comparison result.
c $8998
D $899B Return HL=$FFFF (less-than result for entry type mismatch: dir vs file).
c $899B
D $89A3 Return HL=$0001 (greater-than result for entry type mismatch).
c $89A3
@ $89A7 label=draw_row_attr
D $89A7 Select and write the display attribute for screen row B. Bit 7 of C = selected/cursor row (uses LA3CF colour); bit 0 = directory (uses LA3CE colour); else normal colour from LA3CD. Calls L9726 to fill the 32-column attribute row.
R $89A7 B Screen row number (1–22)
R $89A7 C Attribute flags: bit 7 = cursor/selected, bit 0 = is directory
c $89A7
D $89B1 Select attribute for a non-cursor row. Checks bit 0 for directory colour.
c $89B1
D $89BB Fill attribute row B with colour C via L9726.
c $89BB
@ $89C3 label=render_entry
D $89C3 Render a single directory entry at screen row B. Loads the entry address from $BF62, gets the filename via L850A/L8526, draws the name using L97B4, then appends the "<DIR" marker if entry flag bit 0 is set and LA3D1 bit 0 is set.
R $89C3 B Screen row number (1–22)
R $89C3 C Attribute flags (bit 7=selected, bit 0=directory)
c $89C3
D $89EA Self-modify byte: source screen-row offset for L89EC row copy.
b $89EA
D $89EB Self-modify byte: destination row offset for L89EC row copy. Also holds the pixel width of the "<DIR" string (set by L981F).
b $89EB
D $89EC Copy one character row on screen (scrolling optimisation). Calls L97B4 via L89A7 to update the attribute.
c $89EC
@ $89F4 label=refresh_display
D $89F4 Conditional display refresh. If $BBE6 (preview flag) is non-zero, calls L96D2 (preview panel update); otherwise calls L89FE (full redraw).
c $89F4
@ $89FE label=render_all_entries
D $89FE Full redraw of all visible directory entries. Iterates from $BBEB (first visible index) for up to 22 entries. For each: calls L89C3 to render, advances the entry pointer by 18 bytes, updates $BBED (last-visible index). Calls L9FB8 at the end to redraw the status bar.
c $89FE
D $8A77 Restore $BF62 to the saved value from before the render loop, then call L9FB8 (status bar update).
c $8A77
s $8A7F
@ $8A80 label=nav_home
D $8A80 Move cursor to the first entry (Home). Passes command $03 to L8A94_0.
c $8A80
@ $8A84 label=nav_pgup
D $8A84 Page up. Passes command $04 to L8A94_0.
c $8A84
@ $8A88 label=nav_up
D $8A88 Move cursor up one entry. Passes command $01 to L8A94_0.
c $8A88
@ $8A8C label=nav_down
D $8A8C Move cursor down one entry. Passes command $02 to L8A94_0.
c $8A8C
@ $8A90 label=nav_pgdn
D $8A90 Page down. Passes command $05 to L8A94_0.
c $8A90
@ $8A94 label=nav_end
D $8A94 Move cursor to the last entry (End). Passes command $06 to L8A94_0. Entry point L8A94_0 dispatches on A: $01=cursor up, $02=cursor down, $03=home, $04=end, $05=page up, $06=page down, $80=force-scroll to keep cursor visible.
c $8A94
D $8AA5 Handle home command ($03). Checks if first entry is already visible; if so just updates $BBEF, otherwise resets $BBEB/$BBED to show from the top.
c $8AA5
D $8AC8 Handle end command ($04). Moves to the last entry (($BBE9)-1); adjusts $BBEB/$BBED so the last entry is visible.
c $8AC8
D $8AF4 Handle page-down command ($06). Advances $BBEF by one page (22 entries), clamped to the last entry.
c $8AF4
D $8B0D Handle page-up command ($05). Moves $BBEF back one page (22 entries), clamped to 0.
c $8B0D
D $8B3A Handle cursor-up command ($01). Decrements $BBEF; if the new entry would scroll off the top, decrements $BBEB and $BBED and scrolls the display up one row.
c $8B3A
D $8BA2 Handle cursor-down command ($02). Increments $BBEF; if the new entry would scroll off the bottom, increments $BBEB and $BBED and scrolls the display down one row.
c $8BA2
D $8C16 After navigation, update the display attribute for the previously highlighted row, then call L89F4 (refresh) or L8C30 (redraw cursor row).
c $8C16
D $8C35 Recompute cursor row position on screen ($BBE4 = selection - first_visible + 1) and render the new cursor row with L89C3.
c $8C35
D $8C60 Draw the bottom two status lines (rows $15/$16) with background colour from LA3CA/LA3CF.
c $8C60
D $8C85 Conditional directory refresh. If L=0 and fewer than 20 entries, clears status area (L8C96); otherwise calls L8595 with flags=$03 (reset+update).
R $8C85 L 0 = full-refresh check, non-zero = always call L8595
c $8C85
D $8C9B Clear the bottom two status rows ($15 and $16) with the background colour from LA3CD.
c $8C9B
@ $8CB8 label=draw_header_text
D $8CB8 Draw a NUL-terminated string in the header row (row 0). Clears row 0 first via L978F, then renders the string with L97B4.
R $8CB8 HL Pointer to NUL-terminated string to display in header row
c $8CB8
D $8CC6 Copy entry cluster/size fields then reload directory. Copies 4 bytes from HL+BC to $BF66, then calls L8595 with flags=$07 (full reload).
c $8CC6
@ $8CD8 label=enter_item
D $8CD8 Enter a directory or execute the currently selected file. Changes to directory "$BBF3" using esxDOS f_chdir ($A9). On success reloads the directory list; on error (carry) jumps to L8D05. For ".." entries (flag bit 0, name starts with '.'), calls L8CC1 to process parent-directory navigation.
c $8CD8
D $8D06 After entering directory: reload from root ($BC00) using esxDOS f_chdir, then exit with colour-flash code $03.
c $8D06
D $8D0F Flash border then wait. Calls L9D78_0 to flash the border with an error/status colour.
c $8D0F
D $8D15 Self-modifying entry stub: first byte is $2E ('.'), second byte is NOP. Continues to L8D0E (open INF plugin for current file).
c $8D15
D $8D1F Open POK (memory patcher) plugin if $BBE5 (cartridge flag) is set. Passes extension "POK" to LA1F6.
c $8D1F
D $8D29 Open LOK (file locker) plugin. Passes extension "LOK" to LA1F6.
c $8D29
D $8D2E Open TPE (tape-player emulator) plugin. Passes extension "TPE" to LA1F6.
c $8D2E
D $8D33 Open HLP (help viewer) plugin. Passes extension "HLP" to LA1F6.
c $8D33
D $8D38 Open UNO extension plugin if LA1B1 (UNO/Next device flag) is set. Passes extension "UNO" to LA1F6.
c $8D38
D $8D44 Open SNA (snapshot manager) plugin if $BBE5 (cartridge flag) is set. Copies $BBF1 to LA3B6, passes extension "SNA".
c $8D44
D $8D54 Open AXE plugin with mode byte = 0. Falls through to L8D4D_0.
c $8D54
D $8D57 Open ASM/AXE plugin with mode byte = 1. Sets LA3B5=mode, LA3B6=$BBE2 (joystick state). Calls L8E78 to dispatch.
c $8D57
D $8D70 Open TAP (tape image) plugin without the $80 flag. Shares entry at L8D69_0.
c $8D70
D $8D73 Open TAP plugin with the $80 flag set (streaming mode).
c $8D73
D $8D79 Open DOS plugin without the $80 flag. Shares entry at L8D72_0.
c $8D79
D $8D7C Open DOS plugin with the $80 flag. Dispatches via L8E63 with extension "TAP".
c $8D7C
D $8D87 Open DOS plugin mode $03. Dispatches via L8E63 with extension "DOS".
c $8D87
D $8D90 Open DOS plugin mode $02.
c $8D90
D $8D94 Open DOS plugin mode $01.
c $8D94
D $8D98 Execute RST $18 (esxDOS ROM restart) then return. Used as a no-op reset bridge.
c $8D98
D $8D9C Increment the action counter at $BBE3 if $BBE5 (cartridge flag) is set. Used to trigger multi-step file operations.
c $8D9C
D $8DA9 Open CLP (clipboard) plugin mode $02.
c $8DA9
D $8DAD Open CLP plugin mode $01.
c $8DAD
D $8DB1 Open CLP plugin mode $03. Dispatches via L8E63 with extension "CLP".
c $8DB1
D $8DBA Open HEX (hex viewer) plugin. Gets current filename via L84FF, clears screen row 0, renders the current entry, then dispatches via LA1F6 with extension "HEX".
c $8DBA
D $8DBF Open TXT (text viewer) plugin. Same flow as L8DB0 but with extension "TXT".
c $8DBF
D $8DDF Toggle or open the SPD (speed/overclock) plugin. Only if $BBE5 is clear (non-cartridge mode); calls L8E78 with extension "SPD". On success, sets $BBE6=$FF and $BBE3=$01.
c $8DDF
D $8DF7 Enter directory then do a full browser refresh. Calls L84FF to read the current name, dispatches to LA1F6 with extension "SPD". If LA3AF bit 0 is set afterward, calls L8754 (full reinit) and L8CC1_0 (reload).
c $8DF7
@ $8E29 label=exec_file
D $8E29 Execute or open the file at the current selection. If the entry flag bit 0 is set it is a directory: call f_chdir ($A9) and reload. Otherwise call L8769 (find extension), then dispatch based on LA3AF plugin return code, or call L9CB9 (joystick check) to decide how to open.
c $8E29
D $8E55 Open-file handler. Saves bookmark, scans extension via L8769, checks LA3AF for plugin mode, then waits for input via L9CCF.
c $8E55
@ $8E72 label=exec_plugin
D $8E72 Dispatch to plugin. Stores mode byte A at LA3B5, reads current entry address into LA3B6, then calls LA1F6 with HL = 3-character extension string.
R $8E72 A Plugin mode byte (stored in LA3B5)
R $8E72 HL Pointer to 3-character file extension string
c $8E72
D $8E87 Dispatch to plugin (simplified). Calls L84FF to read current filename, then enters L8E63_0.
R $8E87 HL Pointer to 3-character extension string
c $8E87
D $8E8D Alphabet key dispatch table (A–Z). Each 2-byte entry is a routine address indexed by (key_ASCII - $41). $0000 = no action assigned to that letter key.
w $8E8D
D $8EC1 Special key code lookup table (24 bytes). Key codes checked by L8EF8 via CPIR: cursor keys remapped from LA3D3, plus function-key codes for plugins, navigation, search, and cache operations.
b $8EC1
D $8ED9 Special key action routine pointer table (23 entries, 2 bytes each). Parallel to L8EB2: each word is the routine called when the corresponding key code is matched. $0000 = no action.
w $8ED9
@ $8F07 label=key_dispatch
D $8F07 Key dispatch. Searches the incoming key code in the L8EB2 table (24 entries) using CPIR. If found, indexes L8ECA to get the action routine and calls it. If not found and key is an uppercase letter ($41–$5A), indexes the alphabet table L8E7E.
R $8F07 A Key code byte from the keyboard scanner
c $8F07
D $8F22 Letter-key handler. Maps keys A–Z ($41–$5A) to the L8E7E dispatch table and calls the corresponding routine if non-zero.
R $8F22 A Key code ($41–$5A)
c $8F22
t $8F41
D $8F41 Plugin extension string "HLP" (help viewer plugin).
t $8F44
D $8F44 Plugin extension string "HEX" (hex viewer plugin).
t $8F47
D $8F47 Plugin extension string "TXT" (text viewer plugin).
t $8F4A
D $8F4A Plugin extension string "POK" (memory patcher plugin).
t $8F4D
D $8F4D Plugin extension string "INF" (file info viewer plugin).
t $8F50
D $8F50 Plugin extension string "SNA" (snapshot manager plugin).
t $8F53
D $8F53 Plugin extension string "TAP" (tape image player plugin).
t $8F56
D $8F56 Plugin extension string "DOS" (DOS/filesystem utility plugin).
t $8F59
D $8F59 Plugin extension string "TPE" (tape-player emulator plugin).
t $8F5C
D $8F5C Plugin extension string "UNO" (UNO/Next device extension plugin).
t $8F5F
D $8F5F Plugin extension string "LOK" (file lock/unlock plugin).
t $8F62
D $8F62 Plugin extension string "CLP" (clipboard plugin).
t $8F65
D $8F65 Plugin extension string "SPD" (speed/overclock plugin).
t $8F68
D $8F68 Plugin extension string "E" (extended/generic plugin type).
D $8F69 AXE plugin parameter stub (2 bytes: mode byte + padding). Used by L8D4A.
c $8F69
D $8F6B AXE/ASM plugin parameter struct (3 bytes: mode + destination + count). Used by L8D4D as a mode + size structure.
c $8F6B
D $8F6E Disk block read. Calls esxDOS disk_read ($81) with BC=sector count, HL=sector address (from HLDE), reading into $C000.
c $8F6E
@ $8F82 label=detect_fs
D $8F82 Detect filesystem and check drive status. Calls esxDOS disk_info ($84). If LA3D1 bit $20 is set, tries to open a cached config via L9535_0.
c $8F82
D $8F98 Read colour-scheme index from LA3D0 and apply via L8F8E_0.
c $8F98
D $8F9D Apply colour scheme. Reads LA3D0 (colour theme index) and updates the attribute bytes LA3CA–LA3CF and the border colour.
c $8F9D
D $8FD2 Load a directory page from disk. Calls L8F5F_0 (disk_read into $C000) then L8FE4 to parse the loaded FAT directory sector into the $C200 buffer.
c $8FD2
D $8FF3 Parse a FAT directory sector at $C000. Reads file size, cluster, and attributes from fixed offsets, handles multi-cluster files by computing 32-bit sector offsets via L9E66, and stores the result in the state variables at $BF8E–$BF9E.
c $8FF3
D $905E Set directory-load mode. Determines whether the cluster chain is FAT16 ($01) or FAT32 ($02) and sets $BF8E accordingly.
c $905E
D $909F Return A = 1 (success indicator from directory load setup).
c $909F
D $90A2 Compute the next sector number. Given current 32-bit file position in HL/DE, divides by sector size to get the next sector to load. Calls L9E9D for 32-bit division.
c $90A2
D $90FA Unpack a 4-byte FAT32 cluster entry from (HL). Returns HL=low word, DE=high word of cluster address.
c $90FA
D $9111 Return HL = BC (cluster address from parsed entry).
c $9111
@ $9114 label=load_directory
D $9114 Load the full directory from disk into the display buffer at $C200. Initialises $BBE9 (entry count) to 0, then iterates through all disk sectors calling L8F5F_0 (disk read) and L931B (entry processing) until all entries are processed or the buffer is full (max $01AA entries).
c $9114
D $91E3 Directory-load inner loop step. Advances to the next sector, increments $BF88 (sector counter), processes the sector via L931B.
c $91E3
D $921B Return L=0 (end-of-directory or buffer-full indicator).
c $921B
D $921E Extract and format a filename from a raw LFN (Long File Name) FAT directory entry at HL into the buffer at DE. Parses the multi-part LFN structure, handling sequence numbers and gap bytes. Returns character count in C.
c $921E
D $9256 Skip a LFN continuation entry at sequence position $0B (extra skip in the LFN chain).
c $9256
D $925E Handle end of LFN sequence. Writes NUL terminator if the entry has the $40 (last-in-sequence) flag; returns length in A.
c $925E
D $927B Build a formatted 18-byte display entry from a raw FAT short-name (8.3) directory entry. Copies the 11-byte name, 4-byte cluster, and 4-byte size into the display buffer at $BF6E.
c $927B
D $92BB Continuation of L926C; handles edge cases and terminates the formatted entry.
c $92BB
D $92CD Return the address of the current $BF6E entry slot.
c $92CD
D $92D4 Sort-insert a new 18-byte entry into the $C200 directory buffer in case-insensitive alphabetical order (directories first). Calls L8964 for comparison.
c $92D4
D $92EB Directory-insertion comparison flag byte.
b $92EB
D $92EC Secondary insertion flag byte.
b $92EC
D $92ED Insert a new entry into the sorted directory list at $C200. Computes the insert position by shifting existing entries down, then copies the new entry into place.
c $92ED
D $9315 Clear the FAT format work buffers. Zeros $BE00, the offset pointers in ($BF6E+$0C), and $BF87.
c $9315
@ $932A label=process_fat_entry
D $932A Process one 32-byte raw FAT directory entry at IX. Skips deleted ($E5), volume-label, and hidden entries. For valid entries: extracts the name via L920F (LFN) or short name, copies to $BF6E, calls L926C to build the 18-byte display record, then calls L92C5 to sort-insert it. Increments $BBE9 (entry count) and advances $BF6E by 18.
R $932A IX Pointer to 32-byte raw FAT directory entry (at $C000 + offset)
R $932A Output: A 1 if entry was added, 0 if end-of-directory
c $932A
D $93C5 Return A=0 (end-of-directory from L931B).
c $93C5
D $93C9 Retrieve fstat info for file handle H. Calls esxDOS f_fstat ($A1) into $BFB4; returns file size low word in BC.
R $93C9 H File handle
R $93C9 Output: BC File size (low 16 bits)
c $93C9
s $93D9
@ $93DA label=file_open_read
D $93DA Open a file on the system drive '$' with read mode ($01) and read data into a caller-supplied buffer. Calls esxDOS f_open ($9A), then L93E2 for the actual read.
R $93DA HL Pointer to NUL-terminated filename
R $93DA BC Read length
R $93DA DE Destination buffer pointer
c $93DA
D $93F1 Read data from an open file into a buffer. Calls esxDOS f_read ($9D). On error stores the error code in LA3D8 and returns HL=0.
c $93F1
s $9411
D $9412 Open a file on drive A with read mode and read data into a buffer. Uses esxDOS f_open ($9A) then L93E2.
c $9412
D $941C Close file handle A via esxDOS f_close ($9B). Returns L=1 on success.
c $941C
D $9423 Load and compare bookmark file. Opens "/tmp/browse.bmk" via esxDOS f_open ($9A), reads 512 bytes into $C000. Compares $BC00 content with loaded data to decide whether to restore the saved scroll position ($BBEF).
c $9423
D $9454 Read the saved selection index from the bookmark file into $BBEF, then compute the entry address via L84EC. Returns A=0 on read error.
c $9454
@ $946E label=save_bookmark
D $946E Save current browser state to the bookmark file. Writes $BC00 (directory list) and $BBEF (selection index) to "/tmp/browse.bmk" using esxDOS f_open/f_write ($9E).
c $946E
t $949A
D $949A Path string "/tmp/browse.bmk" — bookmark/cursor-position persistence file.
b $94A9
D $94A9 NUL terminator for L948B.
t $94AA
D $94AA Filename "cache.db" — directory entry count cache file.
b $94B2
D $94B2 NUL terminator for L949B.
t $94B3
D $94B3 Status string "Cached" — shown after writing the directory count to cache.
b $94B9
D $94B9 Self-modifying 2-byte parameter used by cache load/save routines.
@ $94BB label=load_cache
D $94BB Load directory entry count from cache. Opens "cache.db" on the current drive, reads the 2-byte entry count into $C1FE, and restores $BBE9 if a cached value exists. Clears LA3D8 on exit.
c $94BB
t $94DE
D $94DE Status string "Deleted" — shown after deleting the directory count cache.
D $94E5 Self-modifying entry stub for the cache delete operation. Executing from $94E5 reads as LD HL,$AF00; the $AF byte at $94E7 is also a secondary entry point (XOR A) used by the key dispatch table to clear A before falling through to L94DB_0.
b $94E5
b $94E7
c $94E8
@ $94EA label=update_cache
D $94EA Delete then re-build directory count cache. Shows "Working...", deletes "cache.db" via L9403, then if LA3D8 is clear reloads the directory (L8595 with flags=$0A). Shows "Cached" or "Deleted" status on completion.
c $94EA
@ $950B label=write_cache
D $950B Write the current directory entry count to "cache.db". Opens the file for write ($9A mode $0A), writes $BBE9 as a 2-byte value, closes. Shows "Cached" status or returns L=0 on error.
c $950B
D $9541 Return L=0 (write failure). Tail of L94FC error path.
c $9541
@ $9544 label=open_dir
D $9544 Open a directory on the current drive ($2A) using esxDOS f_opendir ($A3). On success reads file info via L93BA, stores drive letter at LA3D0. Returns A=1 on success, A=0 on failure.
c $9544
D $9562 Return A=0 (failed to open directory). Tail of L9535.
c $9562
@ $9564 label=name_matches
D $9564 Case-insensitive substring match. Compares the NUL-terminated filename at HL character by character against the search pattern at L9615. Returns HL=1 on match, HL=0 on no-match.
R $9564 HL Pointer to filename to search in
R $9564 Output: HL 1 if search string matches anywhere in filename, else 0
c $9564
D $958F Restart comparison from the beginning of the search pattern (called after a partial mismatch).
c $958F
D $9595 Return HL=0 (no match — reached end of filename without a full match).
c $9595
@ $9599 label=search_toggle
D $9599 Toggle the incremental search mode on/off. Flips the search-active flag at $BF6C. When turning search on, clears L9603 (pattern length) and L9615 (pattern buffer), shows the "Find:" prompt in the header, and enters the search input loop via L9CCF.
c $9599
D $95B9 Enter or exit search mode. Stores the new search state in $BF6C, draws the header (L960F prompt or $BC00 path), then waits for input via L9CCF.
c $95B9
@ $95C6 label=search_dir
D $95C6 Search the directory list for a filename matching the pattern at L9615. L=0 searches forward from the current $BBEF; L=1 searches from the start. Returns HL=count-remaining if found (non-zero = match at updated $BBEF), or HL=0 if no match.
R $95C6 L 0 = search from current position, 1 = search from beginning
R $95C6 Output: HL Count remaining at match position (non-zero), or 0 if not found
c $95C6
D $9605 Advance to the previous entry for backward search. Steps HL by 18 bytes, decrements DE (remaining count), continues the search loop.
c $9605
D $960E Return HL=0 (not found). Common return for L95B7 when the pattern was not matched.
c $960E
D $9612 Search pattern length counter (0–16). 0 = pattern is empty, no search active.
b $9612
t $9613
D $9613 Message "Not found!" — shown when L95B7 fails to match the search pattern.
b $961D
D $961D NUL terminator byte following L9604.
t $961E
D $961E Message "Find: " — header prompt while search mode is active.
b $9624
D $9624 NUL byte at the start of the search pattern buffer (at offset 0).
b $9625
D $9625 Search pattern buffer (16 bytes). NUL-terminated string currently being searched for.
@ $9634 label=search_key_handler
D $9634 Interactive search key handler. Backspace ($0C) removes the last character from the pattern and re-runs the search. Return ($0D or $80) opens the currently matched file (L963D). Other printable characters are added to the pattern.
R $9634 C Key code (Backspace=$0C, Return=$0D/$80, printable char otherwise)
c $9634
D $964C Handle Enter/Return in search mode. If a match was found ($BBEF non-zero), calls L8E1F (execute file). Clears search state on exit.
c $964C
D $9663 Handle Enter when no file is selected. Calls L8D05 (border flash / error feedback).
c $9663
D $9667 Handle 'F' key: find next match. Advances $BBEF by one, calls L95B7 forward then wrapping to find the next occurrence of the search pattern.
c $9667
D $968F Handle Space in search mode. If search is active (B non-zero), toggles search off via L958A_0. Otherwise falls through to L968D to add space to the pattern.
c $968F
@ $969C label=search_add_char
D $969C Add character C to the search pattern. Accepts printable ASCII ($20–$7F, capped at 16 chars). Appends to L9615 buffer and re-runs the search via L968D_1.
R $969C C ASCII character to append to the search pattern
c $969C
@ $96E1 label=render_preview
D $96E1 Render the file-info / preview panel. Gets current filename via L84FF, calls the preview renderer (LA1F6 with L96EB as the extension stub), then re-renders the selected entry in the right column.
c $96E1
D $96FA Preview-panel loader stub. Self-modifying bytes overwritten at runtime with the preview panel draw parameters; on return toggles $BBE6 (preview enable flag).
c $96FA
D $970C Hide preview panel and reload directory. Calls L9DA6 (clear screen + apply colour scheme), then L8595 with flags=$01 (reload only).
c $970C
@ $9715 label=clear_display
D $9715 Clear the Spectrum display. Fills pixel memory $4000–$57FF with 0x00, then fills attribute memory $5800–$5AFF with colour A.
R $9715 A Default attribute byte for the whole screen
c $9715
@ $972C label=set_border
D $972C Set the border colour and the BORDCR system variable. Outputs A to port $FE, rotates left 3, stores in $5C48 (BORDCR).
R $972C A Ink colour value (lower 3 bits used for border)
c $972C
@ $9735 label=fill_attr_row
D $9735 Fill a complete 32-column attribute row with colour byte C. Computes the attribute address from row B, writes C to all 32 bytes via LDIR.
R $9735 B Screen row (1–22)
R $9735 C Attribute byte
c $9735
@ $974D label=copy_char_row
D $974D Copy an 8×8 character cell on the pixel display. Maps source row B and destination row C to pixel addresses, copies all 8 scan lines (32 bytes each). Used by scroll-up/down optimisation.
R $974D B Source screen row
R $974D C Destination screen row
c $974D
D $977C Self-modify: source high address byte for L973E pixel copy loop.
b $977C
D $977D Self-modify: source column offset low byte.
b $977D
D $977E Self-modify: destination high address byte.
b $977E
D $977F Self-modify: destination column offset low byte.
b $977F
D $9780 Copy the attribute bytes for the scrolled row. Continuation of L973E after pixel copy.
c $9780
@ $979E label=clear_char_row
D $979E Clear (zero) all 8 pixel scan lines for screen row B.
R $979E B Screen row to clear (1–22)
c $979E
@ $97C3 label=draw_string
D $97C3 Render a NUL-terminated proportional string to the pixel display. Looks up each character in the L9867 font table (8 bytes per glyph), writes pixel rows to the screen starting at row B, column C.
R $97C3 HL Pointer to NUL-terminated string
R $97C3 B Screen row (1–22)
R $97C3 C Starting pixel column (0–based, aligned to character widths)
c $97C3
D $980C Pixel column blitter helper. Writes the current foreground/background mask byte to the display, then advances the column pointer. Called per pixel column within L97B4.
c $980C
D $9822 Advance column IX for the next character in the L97B4 render loop.
c $9822
D $982E Build the proportional character width table at $BF00. Reads the first byte of each glyph in L9867 (width in pixels) and stores it in $BF00. Also measures "<DIR" string via L984C and stores the pixel width in L89EB.
c $982E
@ $985B label=measure_string
D $985B Measure the total pixel width of a NUL-terminated string. Sums per-character widths from the $BF00 table (indexed by char-$20). Returns L=1 and B=total width on success, or L=0 on overflow.
R $985B HL Pointer to NUL-terminated string
R $985B Output: B Total pixel width, L=1 on success / L=0 on overflow
c $985B
D $9871 Return L=0 on carry (width overflow), L=1 on success.
c $9871
D $9876 Custom proportional 8×8 pixel font bitmap table. 97 characters covering ASCII $20–$7E plus special glyphs. Each glyph entry is 8 bytes: byte 0 = pixel width override (0 = use default of 6px). Used by L97B4 (render string) and L981F (build width table).
b $9876
t $98A7
D $98A7 Status bar template " P X" — the four status indicator positions (Preview, Locked, Speed, NMI).
b $98AB
D $98AB Font bitmap data continuation (special/icon characters for the status bar area).
t $98C0
D $98C0 Font table spacer "    " — separator between bitmap groups.
b $98C4
D $98C4 Font bitmap data (digits 0–9, punctuation, and letters A–S from the custom charset).
t $99C0
D $99C0 Font table spacer "    " — separator.
b $99C4
D $99C4 Font bitmap data continuation (letters T–Z and lowercase/special glyphs).
t $9A18
D $9A18 Font table spacer "     ".
b $9A1D
D $9A1D Font bitmap data (letters u–x continuation).
t $9A38
D $9A38 Font table inline marker "P  P" (proportional-width marker bytes within the bitmap data stream).
b $9A3C
D $9A3C Font bitmap data (letters x–z and special characters).
t $9A41
D $9A41 Font table marker "P   ".
b $9A45
D $9A45 Font bitmap data (brackets and punctuation characters).
t $9A6A
D $9A6A Font table marker "   ".
b $9A6D
D $9A6D Font bitmap data (lowercase letters a–o and symbols).
b $9B28
D $9B28 Font bitmap fragment (continuation of 'v' and 'w' glyphs).
t $9B2A
D $9B2A Font table inline marker "PP ".
b $9B2D
D $9B2D Font bitmap data (letter 'x' and continuation).
t $9B39
D $9B39 Font table inline marker "P P".
b $9B3C
D $9B3C Font bitmap data (letters y–z, braces, bar characters).
t $9B52
D $9B52 Font table marker "  8".
b $9B55
D $9B55 Font bitmap fragment.
t $9B57
D $9B57 Font table spacer "      ".
b $9B5D
D $9B5D Font bitmap data (custom/special characters, end of font table).
@ $9B86 label=wait_keys_up
D $9B86 Wait for all keyboard keys to be released. Loops reading port $FE until all row bits read $1F (no keys pressed).
c $9B86
@ $9B90 label=scan_keyboard
D $9B90 Scan the ZX Spectrum keyboard matrix (8 half-rows via port $FE). Detects which single key is pressed and returns an encoded key index. Returns HL=key code or HL=0/Fc on no key / multi-key.
R $9B90 Output: HL Encoded key code, or 0 / Fc if no valid single key
c $9B90
D $9BBC Decode a row/column key position into an ASCII or action key code. Uses L9B19 (row sizes) and the QWERTY layout tables at L9C19/L9C42/L9C69. Adjusts for Caps Shift and Symbol Shift modifiers.
c $9BBC
D $9BFD Return HL=0, Fc=1 (no key / debounce reject — multi-key pressed or key not in range).
c $9BFD
D $9C02 Return HL=0, Fc=0 (multi-key pressed with no valid decode).
c $9C02
D $9C08 Keyboard half-row size table. Maps each half-row index (0–4) to the number of keys in that row for the key-position calculation in L9BAD.
b $9C08
t $9C29
D $9C29 QWERTY unshifted character table for the lower 5 keyboard half-rows. "zxcvasdfgqwert1234509876poiuy".
b $9C46
D $9C46 Enter key code ($0D) — separator after the digit-row segment.
t $9C47
D $9C47 Unshifted key table part 2: "lkjh " (middle rows including Space).
b $9C4C
D $9C4C $FF segment separator.
t $9C4D
D $9C4D Unshifted key table part 3: "mnb".
b $9C50
D $9C50 $FF end-of-row separator.
t $9C51
D $9C51 Caps-shifted (uppercase) key table part 1: "ZXCVASDFGQWERT".
b $9C5F
D $9C5F Caps-shifted control codes: Delete, cursor-up, cursor-left, cursor-right, cursor-down, and modifier flags.
t $9C69
D $9C69 Caps-shifted key table part 2: "POIUY".
b $9C6E
D $9C6E Enter key code ($0D) separator.
t $9C6F
D $9C6F Caps-shifted key table part 3: "LKJH " (Space = Break).
b $9C74
D $9C74 $FF separator.
t $9C75
D $9C75 Caps-shifted key table part 4: "MNB".
b $9C78
D $9C78 Symbol-shifted key code table: ":", "`", "?", "/", "~", "|", "\", "{", "}", and extra modifier codes.
t $9C85
D $9C85 Symbol-shifted symbols part 2: "<>!".
b $9C88
D $9C88 Symbol-shifted symbols part 3: "@#$%_".
t $9C8D
D $9C8D Symbol-shifted symbols part 4: ")('&\";".
b $9C93
D $9C93 Symbol-shifted symbols part 5 (extended).
b $9C96
D $9C96 Control-key and special-key code table: Enter, cursor navigation codes, Delete, etc.
b $9CA4
D $9CA4 Extended keycode table for Caps+Symbol combinations: Paste, Select, Find, and similar editor actions.
b $9CB5
D $9CB5 Additional keycode table for combined modifier keys and special OS actions.
@ $9CC8 label=read_joystick
D $9CC8 Read Kempston joystick state. Checks port $FE row 0 (bit 0 = fire) and port $7F (bit 1 = direction active). Returns E = joystick flags.
R $9CC8 Output: E Joystick flags (bit 0 = fire pressed)
c $9CC8
@ $9CDE label=wait_key
D $9CDE Wait for a keypress with full debounce. Waits for all keys released (port $FE = $1F). Calls the input-dispatch routine at ($BFA7). Translates via L9B81 (keyboard scan). If search mode is active ($BF6C non-zero), routes to L9625 (search handler); otherwise routes to L9D25 (main key dispatch).
c $9CDE
D $9D34 Main key dispatch. Handles Backspace ($C4) and Space ($20) to toggle search mode. All other keys pass to L9D38.
c $9D34
D $9D47 Key range check. Keys $22/'@' are mapped to $22. Keys $21–$2A (directory/path characters) pass to L8DED_0. All other keys pass to L9D4F (extended key handler).
c $9D47
D $9D5E Route key to the key-handler dispatch table (L8EF8).
c $9D5E
D $9D62 Return A=0. Null input stub used when joystick is absent or disabled.
c $9D62
D $9D64 Read Kempston joystick with debounce. Reads port $1F twice; if readings agree, maps the 5-bit direction+fire pattern via L9D64. Returns A = encoded key code.
c $9D64
D $9D73 Map Kempston joystick bits to browser key codes. Indexes the L9D77 direction table using bits 0–4 of A, ORs in $C0 if fire is pressed.
c $9D73
D $9D87 Self-modifying entry stub overwritten at runtime with border-flash colour values. Continues to L9D78_0.
c $9D87
@ $9DB5 label=init_display_colors
D $9DB5 Initialise display colours and clear the screen. Reads the colour scheme from LA3CA–LA3CD; calls L9706 (clear display), L971D (set border), L9726 (fill attribute rows), and L9FB8 (draw status bar).
c $9DB5
@ $9DD7 label=main_loop
D $9DD7 Main browser event loop. Waits for keyboard or joystick input via L9CCF_1, then saves bookmark (L945F), handles plugin return (LA1C0), and processes device state (LA16B).
c $9DD7
@ $9DEA label=init
D $9DEA System initialisation. If A is non-zero: copies NMI handler from $3200 to $C000 and pages it to $3E00 via DivMMC port $E3. Then: detects UNO/Next (LA11F), loads settings (LA1CC), loads browse config (L8732_0), sets input handler at $BFA7, clears display, queries drive status (L9E46), and navigates to the startup directory (L8F73/L9E26).
R $9DEA A Non-zero = copy and install NMI handler before init; 0 = skip NMI install
c $9DEA
D $9E35 Browser startup. Calls L8754 (browser init), L9414 (restore bookmark), and L8595 for the initial directory listing. Returns the border colour to set.
c $9E35
D $9E53 Update status bar only (no directory reload). Calls L9FB8_0 with $04 and returns A=0.
c $9E53
D $9E5A Query drive information. Calls esxDOS m_dosversion ($88) and stores the returned HL to $BF64.
c $9E5A
@ $9E60 label=mul16
D $9E60 16-bit unsigned multiply. Computes 32-bit result DEHL = HL × BC using a shift-and-add loop.
R $9E60 HL Multiplicand
R $9E60 BC Multiplier
R $9E60 Output: DE:HL 32-bit product
c $9E60
@ $9E7A label=mul32
D $9E7A 32-bit unsigned multiply. Computes 64-bit result {HL,DE} × {HL',DE'} using a 32-bit shift-and-add loop. Used for large file offset calculations.
c $9E7A
@ $9EB1 label=div32
D $9EB1 32-bit unsigned divide. Computes HL / BC (with DE as upper word) using partial-division helpers L9EC0 and L9F34.
c $9EB1
D $9ECD Division tail: calls L9F34 and returns BC=0.
c $9ECD
D $9ED4 32-bit division partial step (inner loop unrolled 8 times, first half).
c $9ED4
D $9F48 32-bit division partial step (inner loop unrolled 8 times, second half).
c $9F48
@ $9FCC label=update_status_bar
D $9FCC Update the full status bar. Calls L9FB8_0 with $0F (all fields: version, position, icons, drive).
c $9FCC
@ $A00B label=render_status_fields
D $A00B Render the status bar fields. Updates the entry position counter (N/total), plugin/flag icons, and the optional 5-byte drive/speed indicator in the bottom status line area.
c $A00B
D $A08A Render the text string at HL on the status row ($17) using L97B4.
c $A08A
D $A090 Convert HL to a decimal digit string at (DE). Uses repeated subtraction to produce up to 3 digits (hundreds, tens, units). Used for "NNN/NNN" position display.
c $A090
t $A0A7
D $A0A7 Status bar spacer "    " (4 spaces) — blank field template.
b $A0AB
D $A0AB NUL terminator byte.
t $A0AC
D $A0AC Position field work string "000/" (overwritten in-place with the current entry number).
t $A0B0
D $A0B0 Position field work string "000" (overwritten with the total entry count).
b $A0B3
D $A0B3 Status bar display control flags ($81 = show version string + position counter).
t $A0B5
D $A0B5 Version string ".browse v1.02a2" — shown in the status bar when $BBE5 is clear.
b $A0C4
D $A0C4 NMI status byte: $20 = NMI active (shown as 'N' in status bar), $00 = inactive (shown as space).
t $A0C5
D $A0C5 NMI indicator string "NMI".
b $A0C8
D $A0C8 NUL terminator for L$A0B1.
b $A0C9
D $A0C9 Proportional font pixel-width step table (7 bytes: 1, 3, 7, 15, 31, 63, 127). Used by the string-width accumulator in L97B4.
b $A0D0
D $A0D0 $FF end-of-width-step-table marker.
b $A0D1
D $A0D1 Status bar attribute byte for the position-counter field.
b $A0D2
D $A0D2 Status bar attribute bytes for the flag icon area (3 bytes: flash/bright/colour for P, X, N icons).
b $A0D5
D $A0D5 Status bar attribute byte for the drive/mode indicator field.
D $A0D6 JP (HL) trampoline. Jumps to the address held in HL — used to call variable dispatch targets without an indirect CALL instruction.
c $A0D6
@ $A0D7 label=wait_frames
D $A0D7 Busy-wait loop. Enables interrupts, executes B HALT instructions (each ~20 ms at 50 Hz), then disables interrupts. Used for brief timed pauses.
R $A0D7 B Number of 50 Hz frames to wait
c $A0D7
@ $A0DD label=wait_any_key
D $A0DD Wait for any key to be pressed. Polls port $FE until all keys are released ($1F), then loops on HALT until a key is detected.
c $A0DD
@ $A0F4 label=strend
D $A0F4 Advance DE to the NUL terminator of a string. Returns DE pointing to the $00 byte.
R $A0F4 DE Pointer to NUL-terminated string
R $A0F4 Output: DE Pointer to the NUL byte
c $A0F4
@ $A0FB label=strappend
D $A0FB Append the NUL-terminated string at HL onto the end of the string at DE (DE points to the NUL from L$A0E0). Copies characters until NUL, writing count to C.
R $A0FB HL Source string pointer
R $A0FB DE Pointer to destination NUL (end of existing string)
R $A0FB Output: C Number of characters copied
c $A0FB
D $A106 No-op return stub.
c $A106
@ $A107 label=strstr
D $A107 Find the first occurrence of NUL-terminated pattern HL inside NUL-terminated string DE. Returns DE pointing to the match start, or Fc=1 if not found.
R $A107 HL Search pattern (NUL-terminated)
R $A107 DE String to search in (NUL-terminated)
R $A107 Output: DE Pointer to match start; Fc=1 if not found
c $A107
D $A119 Verify that a full match of the pattern occurs at the current DE position. Calls back to LA0F3_0 on mismatch to continue scanning.
c $A119
D $A12E Pop saved registers and return — match successfully confirmed. Tail of L$A105.
c $A12E
D $A131 Swap DE and HL and return. Used when the search pattern is empty (matches start of string).
c $A131
@ $A133 label=detect_uno
D $A133 Detect UNO/NextZXOS hardware. Outputs $FF to port $FC3B, reads $FD3B and counts valid ASCII responses. If 2 or more valid bytes are seen, sets LA1B1=1 (device present) and stores the firmware version in LA1B2.
c $A133
D $A156 Confirm UNO/Next presence. Stores LA1B1=1 and reads the device version byte into LA1B2. Called after LA11F counts enough valid responses.
c $A156
D $A17F Send pending UNO/Next command. If LA1B1 (device present) and LA1B2 (command byte) are both non-zero, outputs the command to port $FD3B.
c $A17F
@ $A198 label=uno_bank_out
D $A198 Switch DivMMC/UNO memory bank. If LA1B1 is zero (no device), returns immediately. If L=0, outputs $0B to port $FC3B and the saved bank byte from LA1B3 to $FD3B. If L non-zero, saves current bank state from $FD3B to LA1B3, then outputs $0B+$C0 to switch.
R $A198 L 0 = restore saved bank; non-zero = save current bank and switch
c $A198
D $A1B1 Save current UNO bank state: reads port $FD3B, stores in LA1B3, then switches to the new bank.
c $A1B1
b $A1C5
D $A1C5 UNO/Next device-present flag: 0 = not detected, 1 = device present.
b $A1C6
D $A1C6 UNO/Next firmware version byte (read during detection).
b $A1C7
D $A1C7 Saved UNO/Next bank register value (used by L$A184 to save/restore bank context).
D $A1C8 Write a DivMMC bank register pair. Outputs D to port $BF3B and E to port $FF3B.
R $A1C8 D High bank register value
R $A1C8 E Low bank register value
c $A1C8
D $A1D4 Restore DivMMC bank registers to the values saved at LA1E6. Called on return from plugin. If LA1E6 is zero, returns immediately.
c $A1D4
D $A1E0 Save current DivMMC bank registers from port $FF3B into LA1E6. Reads the port and stores; if non-zero, switches to bank $4000.
c $A1E0
D $A1F9 No-op return stub.
c $A1F9
b $A1FA
D $A1FA Saved DivMMC bank register value from before plugin call (restored by LA1C0).
t $A1FB
D $A1FB Error string "Err" — shown in the status bar when a plugin returns an error.
D $A1FE Self-modifying entry: bytes overwritten at runtime with LD L,A / LD (HL),D.
c $A1FE
b $A200
D $A200 Self-modifying 2-byte parameter: LD HL,n operand.
b $A202
D $A202 Plugin invocation mode byte ($50).
D $A203 Self-modifying entry: bytes overwritten at runtime with LD L,H / LD (HL),L / LD H,A / LD L,C / LD L,(HL).
c $A203
b $A208
D $A208 Self-modifying 2-byte parameter used by the plugin invocation stubs.
@ $A20A label=invoke_plugin
D $A20A Invoke an external plugin identified by a 3-character extension string in HL. Prepends '_' to the extension in LA365, appends the path "/bin/bplugins/", loads and runs the plugin binary from $8000 via L$A22A.
R $A20A HL Pointer to 3-character plugin extension string (e.g. "TXT", "HEX")
c $A20A
D $A222 Build the full config-plugin path. Appends the 4-byte extension from LA37C to the path at LA365, then appends ".cfg" from L8723.
c $A222
D $A233 Clear the 8-byte scroll-indicator buffer at $50F8–$50FF.
c $A233
@ $A23E label=load_and_run_plugin
D $A23E Load and execute the plugin binary. Banks in DivMMC page at $8C (port $E3), copies the current $8000 code to $2000 (save), loads the plugin from "/bin/bplugins/" + extension via L93CB, then calls $8000 with filename, config, and mode parameters. On return, restores $8000, re-banks, and processes the plugin return flags in LA3AF.
c $A23E
b $A27C
D $A27C Self-modify byte ($3E = LD A,n opcode) for bank-switch sequence in L$A22A.
b $A27D
D $A27D Self-modifying DivMMC bank page number loaded before calling the plugin at $8000.
@ $A27E label=call_plugin
D $A27E Execute the loaded plugin at $8000. Switches in the plugin page, opens the config file (LA36A), calls $8000 with filename/config/mode args, then restores the original page and processes the return code in LA3AF.
c $A27E
b $A2EA
D $A2EA Self-modify byte ($3E = LD A,n opcode) for bank restore sequence.
b $A2EB
D $A2EB Self-modifying DivMMC page number for restoring after plugin call.
@ $A2EC label=plugin_return
D $A2EC Process plugin return. Checks LA3AF flags: $80 = show error string; $10 = show info string (from LA385); $04 = reload directory; $02 and not $08 and LA3B2=0 = call LA344 (full display reinit).
c $A2EC
D $A352 Reload directory (L=0 flag to L8C80). Called after plugin modifies the directory.
c $A352
D $A358 Reinitialise the full display. Calls L9DA6 (clear screen + colours), L8595 with flags=$09 (full reload), and clears LA3B2 (needs-reload flag).
c $A358
D $A365 Partial directory reload. Calls L8595 with flags=$0A.
c $A365
t $A36B
D $A36B Plugin base path "/bin/bplugins/" — prefix used when loading plugin binaries.
t $A379
D $A379 Plugin extension work buffer "????" — overwritten in-place with '_' + 3-char extension by L$A1F6.
b $A37D
D $A37D NUL terminator for L$A365.
t $A37E
D $A37E Plugin config path "/bin/bplugins/cfg/" — used to load per-extension config files.
b $A390
D $A390 Full plugin config path buffer (9 bytes). Built by LA20E: L$A36A + extension + ".cfg" + NUL.
b $A399
D $A399 Plugin message / info string buffer (42 bytes). Filled by the plugin at $8000 when it returns flag $10 or $D0 in LA3AF.
b $A3C3
D $A3C3 Plugin return code byte. Written by the plugin at $8000 on return: $01 = files changed (reload); $02 = update display; $04 = reload dir; $08 = quiet; $10 = show info string; $40 = cursor moved; $80 = error string; $D0 = show result.
b $A3C4
D $A3C4 Plugin cursor-mode byte (lo = cursor advance code, hi = plugin-type).
b $A3C6
D $A3C6 Directory-needs-reload flag. Set by plugin return; cleared by LA344.
b $A3C7
D $A3C7 DivMMC memory bank page number for the plugin.
b $A3C8
D $A3C8 Cartridge/ROM mode byte at the time of the plugin call.
b $A3C9
D $A3C9 Plugin mode parameter (set by the dispatcher before calling LA1F6).
b $A3CA
D $A3CA Plugin parameter block pointer (4 bytes). Usually the address of the current 18-byte directory entry.
b $A3CE
D $A3CE Plugin config data buffer (16 bytes). Loaded from "/bin/bplugins/cfg/<ext>.cfg" before calling the plugin.
b $A3DE
D $A3DE Header row background attribute byte (default $78 = white on black).
b $A3DF
D $A3DF Status bar background attribute byte (default $47 = white on blue).
b $A3E0
D $A3E0 Border colour index (default $07 = white).
b $A3E1
D $A3E1 Normal directory entry text attribute (default $38 = black on white).
b $A3E2
D $A3E2 Directory/folder entry highlight attribute (default $39 = blue on white).
b $A3E3
D $A3E3 Selected/cursor row attribute (default $68 = black on green).
b $A3E4
D $A3E4 Current drive letter / colour theme index. Updated by L9535 (opendir) and L8F8E (colour scheme).
b $A3E5
D $A3E5 Feature flags byte 0: bit 6=$40 = proportional font enabled; bit 5=$20 = cache enabled; bit 4=$10 = bookmark persistence enabled; bit 1=$02 = joystick/Kempston enabled; bit 0=$01 = show "<DIR" markers. Byte 1: extended flags.
b $A3E7
D $A3E7 Special key remapping table (5 bytes). Cursor keys and Enter: $0B=cursor-up, $0A=cursor-down, $08=cursor-left, $09=cursor-right, $0D=Enter. Matched by L9CCF via CPIR and remapped to L8EB2 action codes.
b $A3EC
D $A3EC Last esxDOS error code from a failed file operation. Stored by L93CB/L93E2; cleared by L94AC.
i $A3ED
