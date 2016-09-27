;
; cracker 2 - A ZX Spectrum Graphics Cracker Utility
;
; Copyright (C) 1988 Richard "Shred" Körber
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU Lesser General Public License as
; published by the Free Software Foundation, either version 3 of the
; License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;

ROM_SA_BYTES_2	equ	$04c6
ROM_LD_BYTES_3	equ	$0569

		include	"sna-header.asm"

;-------------------------------------------------------------------------------
; CRACKER entry point.
;
START::		ld	sp,stackend	; set stack
		di			; disable interrupts
		im	1
		call	cls		; clear screen
		call	wrcpyr		; write copyright note

prlop		ld	ix,23296	; reset pointer

;-------------------------------------------------------------------------------
; Main loop.
;
loop		call	wrttxt		; copy font to screen

		push	ix		; copy bitmap to screen
		pop	hl
		ld	de,$4800
		ld	bc,$800
		ldir

		ld	bc,$f7fe
		in	a,(c)
		rra
		jr	nc,prlop	; "1": reset pointer
		rra
		jp	nc,sto1		; "2": push to store 1
		rra
		jp	nc,rcl1		; "3": pop from store 1
		rra
		jp	nc,sto2		; "4": push to store 2
		rra
		jp	nc,rcl2		; "5": pop from store 2

		ld	bc,$effe
		in	a,(c)
		rra
		jp	nc,edit		; "0": edit

		ld	bc,$dffe
		in	a,(c)
		ld	de,768
		rra
		jr	nc,save		; "P": save 768 bytes
		ld	de,2048
		rra
		jr	nc,save		; "O": save 2048 bytes
		ld	de,6144
		rra
		jr	nc,save		; "I": save 6144 bytes
		ld	de,6912
		rra
		jr	nc,save		; "U": save 6912 bytes
		rra
		jp	nc,sopti	; "Y": set/save range

		ld	a,$f9		; read two rows simultaneously
		in	a,($fe)
		ld	de,1
		rra
		jr	nc,add		; "Q"/"A": move by 1 byte
		ld	de,8
		rra
		jr	nc,add		; "W"/"S": move by 8 bytes
		ld	de,256
		rra
		jr	nc,add		; "E"/"D": move by 256 bytes
		ld	de,1024
		rra
		jr	nc,add		; "R"/"F": move by 1024 bytes
		ld	de,2048
		rra
		jr	nc,add		; "T"/"G": move by 2048 bytes

		call	tstld		; test loading keys

next		push	ix		; next iteration
		pop	bc
		ld	a,7		; reset border to white
		out	($fe),a
		xor	a
		ld	h,b		; show current pointer address
		ld	l,c
		ld	iy,16544	; screen position
		jp	wrnum

save		push	ix		; save headerless to tape
		ld	a,$ff		; write data, no header
		call	ROM_SA_BYTES_2
		pop	ix
		jr	next

add		ld	a,$fd		; was it the lower row?
		in	a,($fe)
		or	$e0
		xor	$ff
		jr	nz,sub		; yes: then subtract
		add	ix,de		; add step rate to ix
		jp	next

sub		push	ix		; subtract step rate from ix
		pop	hl
		and	a
		sbc	hl,de
		push	hl
		pop	ix
		jp	next

;-------------------------------------------------------------------------------
; Set store 1 or 2.
;
sto1		ld	hl,m1		; address of store
		ld	iy,16480	; display position
		jr	sto
sto2		ld	hl,m2		; address of store
		ld	iy,16496	; display position
sto		ld	a,xl		; write ix to store
		ld	(hl),a
		inc	hl
		ld	a,xh
		ld	(hl),a
		push	ix		; print address
		pop	hl
		jp	wrnum

;-------------------------------------------------------------------------------
; Recall store 1 or 2.
;
rcl1		ld	hl,m1		; address of store
		jr	rcl
rcl2		ld	hl,m2		; address of store
rcl		ld	a,(hl)		; set ix from store
		ld	xl,a
		inc	hl
		ld	a,(hl)
		ld	xh,a
		jp	next

;-------------------------------------------------------------------------------
; Render pointer position.
;	-> ix: pointer
;
wrttxt		push	ix
		pop	hl
		ld	de,$4000	; target bitmap address
		ld	b,8		; 8 rows
wrttxt1		ld	c,96		; 96 characters
		push	hl
		push	de
wrttxt2		ld	a,(hl)		; copy character row
		ld	(de),a
		push	bc
		ld	bc,8
		add	hl,bc
		pop	bc
		inc	de
		dec	c
		jr	nz,wrttxt2
		pop	de
		pop	hl
		inc	hl
		inc	d
		djnz	wrttxt1

		ld	hl,$4000	; use target bitmap address
		ld	de,23040	; target attribute address
		ld	a,8		; 8 rows
mglp1		push	hl
		ld	c,4		; show 4 characters
mglp2		ld	b,8		; 8 pixel per row
		ex	af,af'
		ld	a,(hl)		; get row
mglp3		rl	a		; test pixel
		jr	c,mglp4		; is set?
		ex	de,hl
		ld	(hl),%01111111	; attribute pixel: bright white
		jr	mglp5
mglp4		ex	de,hl
		ld	(hl),%01000000	; attribute pixel: pitch black
mglp5		ex	de,hl
		inc	de		; next attribute
		djnz	mglp3		; for all 8 pixels
		ex	af,af'
		inc	hl		; next character
		dec	c
		jr	nz,mglp2	; for all 4 characters
		pop	hl
		inc	h		; next row
		dec	a
		jr	nz,mglp1	; for all 8 rows
		ret

;-------------------------------------------------------------------------------
; Clear the screen.
;
cls		ld	hl,$4000	; delete upper third
		ld	de,$4001
		ld	bc,$fff
		ld	(hl),0
		ldir
		ld	hl,$5800	; set colour to paper:7 ink:0
		ld	de,$5801
		ld	bc,512
		ld	(hl),%00111000
		ldir
		ld	bc,256		; hide bytecode by setting
		ld	(hl),%00111111	; paper:7 ink:7
		ldir
		ret

;-------------------------------------------------------------------------------
; Load headerless data from tape if key is pressed.
;	-> ix: start ptr
;
tstld		ld	a,$bf		; any key of
		in	a,($fe)		; "H", "J", "K", "L", "Enter"?
		or	$e0
		xor	$ff
		ret	z		; no: return

		ld	de,42240	; de: maximum length
					;FIXME: de should be 65536-ix
		ld	a,$ff		; expect data, no header
		scf			; load mode
		inc	d		; prepare ROM call
		ex	af,af'
		dec	d
		di
		ld	a,$0e		; border is yellow (not white)
		out	($fe),a
		in	a,($fe)		; change header colors for fun
		rra
		and	$20
		call	ROM_LD_BYTES_3
		di
		ret

;-------------------------------------------------------------------------------
; Write a 5 digit number.
;	-> hl: number to print
;	-> iy: print target position
;
wrnum		ld	bc,-10000	; 5th digit
		call	h192a
		ld	bc,-1000	; 4th digit
		call	h192a
		ld	bc,-100		; 3rd digit
		call	h192a
		ld	bc,-10		; 2nd digit
		call	h192a
		ld	a,l		; 1st digit
		call	prtnr
		jp	loop
h192a		xor	a		; count here
h192a_1		add	hl,bc		; subtract constant
		inc	a		; increment
		jr	c,h192a_1	; until overflow
		sbc	hl,bc		; correct the error
		dec	a
		jr	z,spce		; if zero, print space
		jr	prtnr
spce		ld	a,"0"		; " " would avoid leading zeros
		jr	prtchr

;-------------------------------------------------------------------------------
; Print a number.
;	-> a: number (0..9)
;
prtnr		add	"0"
	; falls through...

;-------------------------------------------------------------------------------
; Print a character.
;	-> a: character, set bit 7 for inverse
;	-> iy: bitmap target ptr, advances after each char
;
prtchr		push	hl
		ld	l,a
		ld	h,0
		ld	de,script-256
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,de		; hl: character address
		push	iy
		pop	de		; de: target address
		ld	b,8		; 8 character rows
prtlp		ld	a,(hl)		; copy row
		ld	(de),a
		inc	hl		; next row
		inc	d
		djnz	prtlp
		inc	iy		; advance cursor
		pop	hl
		ret

;-------------------------------------------------------------------------------
; Print the copyright note to screen.
;
wrcpyr		ld	iy,16576
		ld	hl,text		; text to print
wrcpyr1		ld	a,(hl)		; get character
		bit	7,a		; bit 7: last char
		jr	nz,wrcpyr2
		call	prtchr		; print char
		inc	hl		; next char
		jr	wrcpyr1
wrcpyr2		res	7,a		; reset bit 7
		call	prtchr		; print final char
		ret

;-------------------------------------------------------------------------------
; Save a range.
;
sopti		call	wkey		; wait until all keys are released
		ld	a,(FLAG)	; flag set?
		and	a
		jr	nz,saveo	; this is the second call
		ld	a,$ff		; set flag
		ld	(FLAG),a
		ld	(start),ix	; remember start address
		ld	iy,16560	; and print it
		push	ix
		pop	hl
		jp	wrnum		; wait for second call

saveo		ld	iy,16560	; clear the start address
		ld	h,6
saveo1		ld	a," "
		call	prtchr
		dec	h
		jr	nz,saveo1

		xor	a		; clear the flag
		ld	(FLAG),a

		push	ix
		ld	hl,(start)
		push	hl
		pop	ix		; ix: old start address
		pop	de		; de: end address
		ex	de,hl
		and	a
		sbc	hl,de
		ex	de,hl		; de: size
		ld	a,$ff		; write data, no header
		call	ROM_SA_BYTES_2
		jp	next

;-------------------------------------------------------------------------------
; Edit characters.
;
edit		xor	a		; reset cursor position
		ld	(crd),a

edlp		ld	hl,26		; wait some time...
		ld	b,0
edwa2		djnz	edwa2
		dec	hl
		ld	a,h
		or	l
		jr	nz,edwa2

		call	wrttxt		; show character map

		ld	a,(crd)		; compute cursor position
		ld	e,a
		ld	d,0
		ld	hl,23040
		add	hl,de		; hl: attribute address of cursor

		ld	a,(hl)		; flash color of cursor
		xor	%00010010
		ld	(hl),a

		ld	bc,$dffe
		in	a,(c)
		rra
		jr	c,p1
		ex	af,af'		; "P": move cursor right
		ld	a,(crd)
		inc	a
		ld	(crd),a
		ex	af,af'
p1		rra
		jr	c,p2
		ld	a,(crd)		; "O": move cursor left
		dec	a
		ld	(crd),a

p2		ld	bc,$fbfe
		in	a,(c)
		rra
		jr	c,p3
		ld	a,(crd)		; "Q": move cursor up
		sub	32
		ld	(crd),a

p3		ld	bc,$fdfe
		in	a,(c)
		rra
		jr	c,p4
		ld	a,(crd)		; "A": move cursor down
		add	32
		ld	(crd),a

p4		ld	bc,$fefe
		in	a,(c)
		rra
		jr	c,f1
		call	getwrk		; CAPS SHIFT: X mirror character
		ld	hl,work
		ld	de,help+7
		ld	b,8
f0l1		ld	a,(hl)
		ld	(de),a
		inc	hl
		dec	de
		djnz	f0l1
		ld	hl,help
		ld	de,work
		ld	bc,8
		ldir
		call	putwrk
		call	wkey		; wait for key release
edp		jp	edlp

f1		rra
		jr	c,f2
		call	getwrk		; "Z": Y mirror character
		ld	hl,work
		ld	b,8
f1l1		ld	c,0
		ld	a,(hl)
		ld	d,8
f1l2		rra
		rl	c
		dec	d
		jr	nz,f1l2
		ld	(hl),c
		inc	hl
		djnz	f1l1
		call	putwrk
		call	wkey		; wait for key release
		jr	edp

f2		rra
		jr	c,f3
		call	getwrk		; "X": copy to clipboard
		ld	hl,work
		ld	de,stre
		ld	bc,8
		ldir
		jr	edp

f3		rra
		jr	c,f4
		ld	hl,stre		; "C": paste from clipboard
		ld	de,work
		ld	bc,8
		ldir
		call	putwrk
ep		jr	edp

f4		rra
		jr	c,f5
		ld	hl,work		; "V": clear character
		ld	b,8
f4l1		ld	(hl),0
		inc	hl
		djnz	f4l1
		call	putwrk

f5		ld	bc,$7ffe
		in	a,(c)
		rra
		jp	nc,next		; SPACE: Leave editor

		rra
		jr	c,f6
		call	getwrk		; SYMBOL SHIFT: Reset pixel
		call	getbit
		cpl
		ld	b,a
		ld	a,(hl)
		and	b
		ld	(hl),a
		call	putwrk
		jr	ep

f6		rra
		jr	c,f7
		call	getwrk		; "M": Invert pixel
		call	getbit
		xor	(hl)
		ld	(hl),a
		call	putwrk
		call	wkey		; wait for key release
ed		jr	ep

f7		rra
		jr	c,f8
		call	getwrk		; "N": Set pixel
		call	getbit
		or	(hl)
		ld	(hl),a
		call	putwrk
		jr	ed

f8		rra
		jp	c,edlp
		call	getwrk		; "B": Invert character
		ld	hl,work
		ld	b,8
f8l1		ld	a,(hl)
		cpl
		ld	(hl),a
		inc	hl
		djnz	f8l1
		call	putwrk
		call	wkey		; wait for key release
		jr	ed

;-------------------------------------------------------------------------------
; Get address of character at cursor.
;	<- hl: cursor address
;
getadr		push	ix
		pop	hl
		ld	a,(crd)
		and	%00011000
		ld	e,a
		ld	d,0
		add	hl,de
		ret

;-------------------------------------------------------------------------------
; Copy character to working area.
;
getwrk		call	getadr
		ld	de,work
		ld	bc,8
		ldir
		ret

;-------------------------------------------------------------------------------
; Copy character back from working area.
;
putwrk		call	getadr
		ex	de,hl
		ld	hl,work
		ld	bc,8
		ldir
		ret

;-------------------------------------------------------------------------------
; Get address of pixel at cursor.
;	<- hl: cursor byte address in working area.
;	<- a: bit mask
;
getbit		ld	a,(crd)
		ld	hl,work
		rlca
		rlca
		rlca
		and	7
		ld	e,a
		ld	d,0
		add	hl,de		; hl: address in working area
		ld	a,(crd)
		and	7
		ld	b,$80		; bit mask
bitlp		and	a
		jr	z,retbit
		rrc	b		; rotate bit
		dec	a		; for number of bits
		jr	bitlp
retbit		ld	a,b
		ret

;-------------------------------------------------------------------------------
; Wait until all keys are released.
;
wkey		xor	a
		in	a,($fe)
		or	$e0
		xor	$ff
		jr	nz,wkey
		ret


FLAG		db	0		; 0: set range, -1: save
start		dw	0		; start of save range
m1		dw	0		; store 1
m2		dw	0		; store 2
crd		db	0		; editor cursor position
work		ds	8		; editor: working area
help		ds	8		; editor: temporary help area
stre		ds	8		; editor: clipboard

text		dm	"The CRACKER 2  "
		db	127			; 127 = (C)
		dm	" 1988 ROM"+$80

script		incbin	"charset/cracker2.chr"

#end
