		org	$5000
		ld	sp,$5800
		di	
		im	1
		call	cls
		call	wrcpyr
		ld	ix,23296
loop		call	wrttxt
		push	ix
		pop	hl
		call	txtscr
		ld	bc,61438
		in	a,(c)
		rra	
		jp	nc,edit
		ld	bc,63486
		in	a,(c)
		rra	
		jr	c,nxt1
		ld	ix,23296
nxt1		rra	
		jp	nc,psh1
		rra	
		jp	nc,pop1
		rra	
		jp	nc,psh2
		rra	
		jp	nc,pop2
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
		ld	de,32
		rra	
		jr	nc,add
		ld	de,768
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
prtnmb		ld	e,"0"
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
		call	$562
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
		ld	b,a
		and	$80
		jr	z,zero
		ld	a,$ff
		jr	prtng
zero		xor	a
prtng		push	af
		ld	a,b
		and	$7f
		ld	l,a
		ld	h,0
		ld	de,script
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,de
		push	iy
		pop	de
		pop	af
		ld	c,a
		ld	b,8
prtlp		ld	a,(hl)
		xor	c
		ld	(de),a
		inc	hl
		inc	d
		djnz	prtlp
		inc	iy
		pop	hl
		ret	
text		dm	"The CRACKER 1   "
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
sopti		xor	a
		in	a,($fe)
		or	$e0
		xor	$ff
		jr	nz,sopti
		ld	a,(FLAG)
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
edit		xor	a
		ld	(crd),a
edlp		call	clat
		push	ix
		pop	hl
		call	txtscr
		ld	a,(crd)
		ld	e,a
		ld	d,0
		ld	hl,22784
		add	hl,de
		ld	a,64
		or	(hl)
		ld	(hl),a
		call	getkey
		cp	32
		jp	nc,edtxt
		cp	8
		jr	nz,ed1
		ld	a,(crd)
		dec	a
		ld	(crd),a
		jr	edlp
ed1		cp	9
		jr	nz,ed2
		ld	a,(crd)
		inc	a
		ld	(crd),a
		jr	edlp
ed2		cp	10
		jr	nz,ed3
		ld	a,(crd)
		add	32
		ld	(crd),a
		jr	edlp
ed3		cp	11
		jr	nz,ed4
		ld	a,(crd)
		sub	32
		ld	(crd),a
		jr	edlp
ed4		cp	13
		jr	nz,ed5
		call	clat
		jp	loop
ed5		cp	12
		jr	nz,ed6
		call	getcrd
		ld	a,(hl)
		xor	$80
		ld	(hl),a
		jr	edlp
ed6		cp	1
		jr	nz,ed7
		call	getcrd
		inc	(hl)
elp		jr	edlp
ed7		cp	2
		jr	nz,ed8
		call	getcrd
		ld	(hl),31
		jp	elp
ed8		cp	3
		jr	nz,ed9
		call	getcrd
		dec	(hl)
		jp	elp
ed9		cp	4
		jr	nz,ed10
		ld	de,32
		add	ix,de
		jp	elp
ed10		cp	5
		jp	nz,edlp
		ld	de,32
		and	a
		push	ix
		pop	hl
		sbc	hl,de
		push	hl
		pop	ix
		jp	elp
getcrd		push	ix
		pop	hl
		ld	a,(crd)
		ld	e,a
		ld	d,0
		add	hl,de
		ret	
edtxt		push	af
		call	getcrd
		ld	a,(hl)
		and	$80
		ld	b,a
		pop	af
		or	b
		ld	(hl),a
		ld	a,(crd)
		inc	a
		ld	(crd),a
		jp	elp
getkey		call	key?
		call	gky
		ld	a,d
		cp	39
		ld	hl,caps
		jr	z,decode
		ld	hl,symbl
		cp	24
		jr	z,decode
		ld	hl,norm
decode		ld	d,0
		add	hl,de
		ld	a,(hl)
		ret	
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
symbl		dm	"*↑[&%>}/"
		dm	",-]'$<{?"
		dm	".+"
		db	127
		db	"(","#",1,"\","£"
		db	" ","=",";",")","@",2,"|",":"
		dm	" "
		db	13,34
		db	"_","!",3,"~"," "
crd		dw	0
key?		call	$28e
		ld	a,e
		cp	255
		ret	z
		cp	$27
		ret	z
		cp	$18
		ret	z
		jr	key?
clat		ld	hl,$5900
		ld	de,$5901
		ld	bc,255
		ld	(hl),%00111000
		ldir	
		ret	
gky		call	$28e
		ld	a,e
		cp	255
		jr	z,gky
		cp	$27
		jr	z,gky
		cp	$18
		jr	z,gky
		ret	
psh1		ld	hl,pm1
		ld	iy,16480
psh		ld	a,xl
		ld	(hl),a
		inc	hl
		ld	a,xh
		ld	(hl),a
		push	ix
		pop	hl
		jp	prtnmb
psh2		ld	hl,pm2
		ld	iy,16496
		jr	psh
pop1		ld	hl,pm1
pop		ld	a,(hl)
		ld	xl,a
		inc	hl
		ld	a,(hl)
		ld	xh,a
		jp	next
pop2		ld	hl,pm2
		jr	pop
pm1		dw	0
pm2		dw	0
script		ds	1024
