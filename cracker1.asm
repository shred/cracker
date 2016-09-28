;
; cracker 1 - A ZX Spectrum Text Cracker Utility
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

ROM_KEY_SCAN	equ	$028e
ROM_SA_BYTES_2	equ	$04c6
ROM_LD_BYTES_2	equ	$0562

KEY_CAPSSHIFT	EQU	$27
KEY_SYMSHIFT	EQU	$18


		include	"sna-header.asm"

;-------------------------------------------------------------------------------
; CRACKER entry point.
;
START::		ld	sp,stackend	; set stack
		di			; disable interrupts
		im	1
		call	cls		; clear screen
		call	wrcpyr		; write copyright note
		ld	ix,23296	; initialize pointer

;-------------------------------------------------------------------------------
; Main loop.
;
loop		call	wrttxt		; copy charset to screen
		push	ix
		pop	hl
		call	txtscr		; print text to screen

		ld	bc,$effe
		in	a,(c)
		rra
		jp	nc,edit		; "0": edit

		ld	bc,$f7fe
		in	a,(c)
		rra
		jr	c,nxt1
		ld	ix,23296	; "1": reset pointer
nxt1		rra
		jp	nc,psh1		; "2": push to store 1
		rra
		jp	nc,pop1		; "3": pop from store 1
		rra
		jp	nc,psh2		; "4": push to store 2
		rra
		jp	nc,pop2		; "5": pop from store 2

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
		ld	de,32
		rra
		jr	nc,add		; "E"/"D": move by 32 bytes
		ld	de,768
		rra
		jr	nc,add		; "R"/"F": move by 768 bytes
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
		call	wrnum
		jp	loop

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
; Push to store 1.
;
psh1		ld	hl,pm1		; address of store
		ld	iy,16480	; display position
psh		ld	a,xl		; write ix to store
		ld	(hl),a
		inc	hl
		ld	a,xh
		ld	(hl),a
		push	ix		; print address
		pop	hl
		jp	prtnr

;-------------------------------------------------------------------------------
; Push to store 2.
;
psh2		ld	hl,pm2		; address of store
		ld	iy,16496	; display position
		jr	psh

;-------------------------------------------------------------------------------
; Pop from store 1.
;
pop1		ld	hl,pm1		; address of store
pop		ld	a,(hl)		; set ix from store
		ld	xl,a
		inc	hl
		ld	a,(hl)
		ld	xh,a
		jp	next

;-------------------------------------------------------------------------------
; Pop from store 2.
;
pop2		ld	hl,pm2
		jr	pop

;-------------------------------------------------------------------------------
; Copy a charset.
;	-> ix: charset pointer
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
		ret

;-------------------------------------------------------------------------------
; Clear the screen.
;
cls		ld	hl,$4000	; delete upper two third
		ld	de,$4001	; excludes our bytecode
		ld	bc,$fff
		ld	(hl),0
		ldir
		ld	hl,$5800	; set colour to paper:7 ink:0
		ld	de,$5801
		ld	bc,512
		ld	(hl),%00111000
		ldir
		ld	bc,255		; hide bytecode by setting
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
		call	ROM_LD_BYTES_2	; invoke ROM
		di			; disable interrupt again
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
		jr	prtnr
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
		ld	b,a
		and	$80		; bit 7 set?
		jr	z,zero
		ld	a,$ff		; then set the invert mask
		jr	prtng
zero		xor	a		; otherwise clean it
prtng		push	af
		ld	a,b		; a: character code
		and	$7f		; remove invert bit
		ld	l,a		; compute character address
		ld	h,0
		ld	de,script
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,de		; hl: character address
		push	iy
		pop	de		; de: target address
		pop	af		; a: invert mask
		ld	c,a
		ld	b,8		; 8 character rows
prtlp		ld	a,(hl)		; get char
		xor	c		; inverse it if needed
		ld	(de),a		; write to screen
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
sopti		xor	a		; wait until all keys are released
		in	a,($fe)
		or	$e0
		xor	$ff
		jr	nz,sopti
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
; Print 256 characters from ptr to screen.
;
txtscr		ld	iy,$4800
		ld	de,256
txt1		ld	a,(hl)
		inc	hl
		push	de
		call	prtchr
		pop	de
		dec	de
		ld	a,d
		or	e
		jr	nz,txt1
		ret

;-------------------------------------------------------------------------------
; Edit a text.
;
edit		xor	a		; reset cursor position
		ld	(crd),a

edlp		;FIXME: crd needs a range check!
		call	clat		; clear cursor
		push	ix
		pop	hl

		call	txtscr		; write text at pointer

		ld	a,(crd)		; show cursor
		ld	e,a
		ld	d,0
		ld	hl,22784
		add	hl,de
		ld	a,%01000000	; flash 1
		or	(hl)
		ld	(hl),a

		call	getkey		; get a key
		cp	32		; printable character?
		jp	nc,edtxt
		cp	8		; cursor left?
		jr	nz,ed1
		ld	a,(crd)		; move cursor left
		dec	a
		ld	(crd),a
		jr	edlp
ed1		cp	9		; cursor right?
		jr	nz,ed2
		ld	a,(crd)		; move cursor right
		inc	a
		ld	(crd),a
		jr	edlp
ed2		cp	10		; cursor down?
		jr	nz,ed3
		ld	a,(crd)		; move cursor down
		add	32
		ld	(crd),a
		jr	edlp
ed3		cp	11		; cursor up?
		jr	nz,ed4
		ld	a,(crd)		; move cursor up
		sub	32
		ld	(crd),a
		jr	edlp
ed4		cp	13		; ENTER?
		jr	nz,ed5
		call	clat		; leave editor
		jp	loop
ed5		cp	12		; DELETE?
		jr	nz,ed6
		call	getcrd		; get cursor address
		ld	a,(hl)		; invert character
		xor	$80
		ld	(hl),a
		jr	edlp
ed6		cp	1		; >= (SYM E)?
		jr	nz,ed7
		call	getcrd		; get cursor address
		inc	(hl)		; next character
elp		jr	edlp
ed7		cp	2		; <> (SYM W)?
		jr	nz,ed8
		call	getcrd		; get cursor address
		ld	(hl),31		; set last control character
		jp	elp
ed8		cp	3		; <= (SYM Q)?
		jr	nz,ed9
		call	getcrd		; get cursor address
		dec	(hl)		; previous character
		jp	elp
ed9		cp	4		; INV VIDEO (CAPS 4)?
		jr	nz,ed10
		ld	de,32		; advance to next row
		add	ix,de
		jp	elp
ed10		cp	5		; TRUE VIDEO (CAPS 5)?
		jp	nz,edlp
		ld	de,32		; go back to previous row
		and	a
		push	ix
		pop	hl
		sbc	hl,de
		push	hl
		pop	ix
		jp	elp

edtxt		push	af
		call	getcrd		; get address at cursor
		ld	a,(hl)		; keep inverse bit
		and	$80
		ld	b,a
		pop	af
		or	b		; set inverse bit at new char
		ld	(hl),a		; write character
		ld	a,(crd)		; advance cursor
		inc	a
		ld	(crd),a
		jp	elp

;-------------------------------------------------------------------------------
; Get address at cursor.
;	<- hl: cursor address
;
getcrd		push	ix
		pop	hl
		ld	a,(crd)		; add cursor to current pointer
		ld	e,a
		ld	d,0
		add	hl,de
		ret

;-------------------------------------------------------------------------------
; Wait for a keypress and return the decoded key.
;	<- a: decoded key
;
getkey		call	keyup		; wait for keys to be released
		call	gky		; get a keypress
		ld	a,d
		cp	KEY_CAPSSHIFT
		ld	hl,caps		; table for caps keys
		jr	z,decode
		ld	hl,symbl	; table for symbol keys
		cp	KEY_SYMSHIFT
		jr	z,decode
		ld	hl,norm		; table for normal keys
decode		ld	d,0
		add	hl,de
		ld	a,(hl)		; get key code
		ret

;-------------------------------------------------------------------------------
; Wait for all keys to be released, except of shift keys.
;
keyup		call	ROM_KEY_SCAN	; scan keyboard
		ld	a,e
		cp	255		; no key pressed?
		ret	z
		cp	KEY_CAPSSHIFT
		ret	z
		cp	KEY_SYMSHIFT
		ret	z
		jr	keyup		; continue waiting

;-------------------------------------------------------------------------------
; Wait for a keypress
;	<- d: shift code
;	<- e: key code
;
gky		call	ROM_KEY_SCAN	; scan keyboard
		ld	a,e
		cp	255		; no key? wait on...
		jr	z,gky
		cp	KEY_CAPSSHIFT	; caps shift? wait on...
		jr	z,gky
		cp	KEY_SYMSHIFT	; sym shift? wait on..
		jr	z,gky
		ret			; return key

;-------------------------------------------------------------------------------
; Make edit area readable.
;
clat		ld	hl,$5900
		ld	de,$5901
		ld	bc,255
		ld	(hl),%00111000		; paper:7, ink:0
		ldir
		ret


FLAG		db	0		; 0: set range, -1: save
start		dw	0		; start of save range
pm1		dw	0		; store 1
pm2		dw	0		; store 2
crd		dw	0		; editor cursor position

text		dm	"The CRACKER 1   "
		db	127			; 127 = (C)
		dm	" 1988 ROM"+$80

norm		dm	"bhy65tgv"
		dm	"nju74rfc"
		dm	"mki83edx"
		dm	" lo92wsz"
		dm	" "
		db	13
		dm	"p01qa "

caps		db	"B","H","Y",10,8,"T","G","V"
		db	"N","J","U",11,4,"R","F","C"
		db	"M","K","I",9,5,"E","D","X"
		dm	" LO92WSZ"
		dm	" "
		db	13
		db	"P",12,"1","Q","A"," "

symbl		dm	"*",94,"[&%>}/"		; 94 = ^
		dm	",-]'$<{?"
		dm	".+"
		db	127
		db	"(","#",1,"\","£"
		db	" ","=",";",")","@",2,"|",":"
		dm	" "
		db	13,34			; 34 = "
		db	"_","!",3,"~"," "

script		incbin	"charset/cracker1.chr"	; extended charset

#end
