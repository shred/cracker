		org	$5000
		ld	sp,$5800
		di	
		im	1
		call	cls
		call	wrcpyr
prlop		ld	ix,23296
loop		call	wrttxt
		push	ix
		pop	hl
		ld	de,$4800
		ld	bc,$800
		ldir	
		ld	bc,63486
		in	a,(c)
		rra	
		jr	nc,prlop
		rra	
		jp	nc,sto1
		rra	
		jp	nc,rcl1
		rra	
		jp	nc,sto2
		rra	
		jp	nc,rcl2
		ld	bc,61438
		in	a,(c)
		rra	
		jp	nc,edit
		ld	bc,57342
		in	a,(c)
		ld	de,768
		rra	
		jr	nc,save
		ld	de,2048
		rra	
		jr	nc,save
		ld	de,6144
		rra	
		jr	nc,save
		ld	de,6912
		rra	
		jr	nc,save
		rra	
		jp	nc,sopti
		ld	a,$f9
		in	a,($fe)
		ld	de,1
		rra	
		jr	nc,add
		ld	de,8
		rra	
		jr	nc,add
		ld	de,256
		rra	
		jr	nc,add
		ld	de,1024
		rra	
		jr	nc,add
		ld	de,2048
		rra	
		jr	nc,add
		call	tstld
next		push	ix
		pop	bc
		ld	a,7
		out	($fe),a
		xor	a
		ld	h,b
		ld	l,c
		ld	iy,16544
ptnmb		ld	e,"0"
		ld	bc,$d8f0
		jp	wr1
save		push	ix
		ld	a,$ff
		call	$4c6
		pop	ix
		jr	next
add		ld	a,$fd
		in	a,($fe)
		or	$e0
		xor	$ff
		jr	nz,sub
		add	ix,de
		jp	next
sub		push	ix
		pop	hl
		and	a
		sbc	hl,de
		push	hl
		pop	ix
		jp	next
wrttxt		push	ix
		pop	hl
		ld	de,$4000
		ld	b,8
wrttxt1		ld	c,96
		push	hl
		push	de
wrttxt2		ld	a,(hl)
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
		ld	hl,$4000
		ld	de,23040
		ld	a,8
mglp1		push	hl
		ld	c,4
mglp2		ld	b,8
mglp3		rr	(hl)
		jr	c,mglp4
		ex	de,hl
		ld	(hl),%01111111
		jr	mglp5
mglp4		ex	de,hl
		ld	(hl),%01000000
mglp5		ex	de,hl
		inc	de
		djnz	mglp3
		inc	hl
		dec	c
		jr	nz,mglp2
		pop	hl
		inc	h
		dec	a
		jr	nz,mglp1
		ret	
cls		ld	hl,$4000
		ld	de,$4001
		ld	bc,$fff
		ld	(hl),0
		ldir	
		ld	hl,$5800
		ld	de,$5801
		ld	bc,512
		ld	(hl),%00111000
		ldir	
		ld	bc,256
		ld	(hl),%00111111
		ldir	
		ret	
tstld		ld	a,$bf
		in	a,($fe)
		or	$e0
		xor	$ff
		ret	z
		ld	de,42240
		ld	a,$ff
		scf	
		inc	d
		ex	af,af'
		dec	d
		di	
		ld	a,$0e
		out	($fe),a
		in	a,($fe)
		rra	
		and	$20
		call	$569
		di	
		ret	
wr1		call	h192a
		ld	bc,$fc18
		call	h192a
		ld	bc,$ff9c
		call	h192a
		ld	bc,$fff6
		call	h192a
		ld	a,l
		call	prtnr
		jp	loop
h192a		xor	a
h192a_1		add	hl,bc
		inc	a
		jr	c,h192a_1
		sbc	hl,bc
		dec	a
		jr	z,spce
		jr	prtnr
spce		ld	a,"0"
		jr	prtchr
prtnr		add	$30
prtchr		push	hl
		ld	l,a
		ld	h,0
		ld	de,script-256
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,de
		push	iy
		pop	de
		ld	b,8
prtlp		ld	a,(hl)
		ld	(de),a
		inc	hl
		inc	d
		djnz	prtlp
		inc	iy
		pop	hl
		ret	
text		dm	"The CRACKER 2  "
		db	127
		dm	" 1988 ROM"'
wrcpyr		ld	iy,16576
		ld	hl,text
wrcpyr1		ld	a,(hl)
		bit	7,a
		jr	nz,wrcpyr2
		call	prtchr
		inc	hl
		jr	wrcpyr1
wrcpyr2		res	7,a
		call	prtchr
		ret	
sopti		ld	a,(FLAG)
		and	a
		jr	nz,saveo
		ld	a,$ff
		ld	(FLAG),a
		ld	(start),ix
		ld	iy,16560
		ld	e,"0"
		ld	bc,$d8f0
		push	ix
		pop	hl
		jp	wr1
saveo		ld	iy,16560
		ld	h,6
saveo1		ld	a," "
		call	prtchr
		dec	h
		jr	nz,saveo1
		xor	a
		ld	(FLAG),a
		push	ix
		ld	hl,(start)
		push	hl
		pop	ix
		pop	de
		ex	de,hl
		and	a
		sbc	hl,de
		ex	de,hl
		ld	a,$ff
		call	$4c6
		jp	next
FLAG		db	0
start		dw	0
sto1		ld	hl,m1
		ld	iy,16480
		jr	sto
sto2		ld	hl,m2
		ld	iy,16496
sto		ld	a,xl
		ld	(hl),a
		inc	hl
		ld	a,xh
		ld	(hl),a
		push	ix
		pop	hl
		jp	ptnmb
rcl1		ld	hl,m1
		jr	rcl
rcl2		ld	hl,m2
rcl		ld	a,(hl)
		ld	xl,a
		inc	hl
		ld	a,(hl)
		ld	xh,a
		jp	next
edit		xor	a
		ld	(crd),a
edlp		call	wrttxt
		ld	a,(crd)
		ld	e,a
		ld	d,0
		ld	hl,23040
		add	hl,de
		ld	a,(hl)
		xor	%00001001
		ld	(hl),a
		ld	bc,57342
		in	a,(c)
		rra	
		jr	c,p1
		ex	af,af'
		ld	a,(crd)
		inc	a
		ld	(crd),a
		ex	af,af'
p1		rra	
		jr	c,p2
		ld	a,(crd)
		inc	a
		ld	(crd),a
p2		ld	bc,64510
		in	a,(c)
		rra	
		jr	c,p3
		ld	a,(crd)
		sub	32
		ld	(crd),a
p3		ld	bc,65022
		in	a,(c)
		rra	
		jr	c,p4
		ld	a,(crd)
		add	32
		ld	(crd),a
p4		ld	bc,65278
		in	a,(c)
		rra	
		jr	c,f1
		call	getwrk
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
edp		jr	edlp
f1		rra	
		jr	c,f2
		call	getwrk
		ld	hl,work
		ld	b,8
f1l1		ld	c,0
		ld	a,(hl)
		ld	d,8
f1l2		rra	
		rl	c
		dec	d
		jr	nz,f1l2
		inc	hl
		djnz	f1l1
		call	putwrk
		jr	edp
f2		rra	
		jr	c,f3
		call	getwrk
		ld	hl,work
		ld	de,stre
		ld	bc,8
		ldir	
		jr	edp
f3		rra	
		jr	c,f4
		ld	hl,stre
		ld	de,work
		ld	bc,8
		ldir	
		call	putwrk
ep		jr	edp
f4		rra	
		jr	c,f5
		ld	hl,stre
		ld	b,8
f4l1		ld	(hl),0
		inc	hl
		djnz	f4l1
		call	putwrk
f5		ld	bc,32766
		in	a,(c)
		rra	
		jp	nc,next
		rra	
		jr	c,f6
		call	getwrk
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
		call	getwrk
		call	getbit
		xor	(hl)
		ld	(hl),a
		call	putwrk
ed		jr	ep
f7		rra	
		jr	c,f8
		call	getwrk
		call	getbit
		or	(hl)
		ld	(hl),a
		call	putwrk
		jr	ed
f8		rra	
		jp	c,edlp
		call	getwrk
		ld	hl,work
		ld	b,8
f8l1		ld	a,(hl)
		cpl	
		ld	(hl),a
		inc	hl
		djnz	f8l1
		jr	ed
getwrk		call	getadr
		ld	de,work
		ld	bc,8
		ldir	
		ret	
getadr		push	ix
		pop	hl
		ld	a,(crd)
		and	%00011000
		ld	e,a
		ld	d,0
		add	hl,de
		ret	
putwrk		call	getadr
		ex	de,hl
		ld	hl,work
		ld	bc,8
		ldir	
		ret	
getbit		ld	a,(crd)
		ld	hl,work
		rlca	
		rlca	
		rlca	
		and	7
		ld	e,a
		ld	d,0
		add	hl,de
		ld	a,(crd)
		and	7
		ld	b,1
bitlp		and	a
		jr	z,retbit
		rlc	b
		dec	a
		jr	bitlp
retbit		ld	a,b
		ret	
work		ds	8
help		ds	8
stre		ds	8
m1		dw	0
m2		dw	0
crd		db	0
script		ds	768
