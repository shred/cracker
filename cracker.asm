		org	$5000
		ld	sp,$5800
		ld	a,2
		call	$1601
		di	
		im	1
		ld	ix,$8000
loop		call	wrttxt
		push	ix
		pop	hl
		ld	de,$4800
		ld	bc,$800
		ldir	
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
		ld	a,$f9
		in	a,($fe)
		ld	de,1
		rra	
		jr	nc,add
		ld	de,8
		jr	nc,add
		ld	de,256
		jr	nc,add
		ld	de,1024
		rra	
		jr	nc,add
		ld	de,2048
		rra	
		jr	nc,add
		ld	a,22
		rst	$10
		ld	a,5
		rst	$10
		xor	a
		rst	$10
		push	ix
		pop	bc
		ld	hl,loop
		push	hl
		push	de
		push	hl
		xor	a
		ld	h,b
		ld	l,c
		ld	e," "
		ld	bc,$d8f0
		call	$192a
		jp	$1a30
save		push	ix
		ld	a,$ff
		call	$4c6
		pop	ix
		jr	loop
add		ld	a,$fd
		in	a,($fe)
		or	$e0
		xor	$ff
		jr	nz,sub
		add	ix,de
		jp	loop
sub		push	ix
		pop	hl
		and	a
		sbc	hl,de
		push	hl
		pop	ix
		jp	loop
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
