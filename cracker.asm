		org	#
		ld	sp,$5c00
		jr	pgm
		ld	ix,$5c00
		ld	de,$a400
		ld	a,$ff
		scf	
		call	$556
pgm		ld	ix,$5c00
		di	
		ld	hl,$4000
		ld	de,$4001
		ld	bc,$17ff
		ld	(hl),0
		ldir	
		ld	hl,$4800
		ld	de,$4801
		ld	bc,767
		ld	(hl),%00111000
		ldir	
		ld	a,7
		out	($fe),a
pgm1		push	ix
		pop	hl
		ld	de,$4800
		ld	bc,$800
		ldir	
		push	ix
		pop	hl
		ld	a,8
		ld	de,$4000
pgm2		ld	bc,96
		push	de
		ldir	
		pop	de
		inc	d
		dec	a
		jr	nz,pgm2
		ld	bc,57342
		in	a,(c)
		ld	de,768
		rra	
		jr	c,save
		ld	de,2048
		rra	
		jr	c,save
		ld	de,6144
		rra	
		jr	c,save
		ld	de,6912
		rra	
		jr	c,save
		jr	pgm3
pgm4		jr	pgm1
save		ld	a,$ff 
		push	ix
		call	$4c6
		di	
		pop	ix
		jr	pgm1
pgm3		ld	a,$f9
		in	a,($fe)
		ld	de,1
		rra	
		jr	c,add
		ld	de,8
		rra	
		jr	c,add
		ld	de,256
		rra	
		jr	c,add
		ld	de,1024
		rra	
		jr	c,add
		ld	de,2048
		rra	
		jr	nc,pgm1
add		ld	a,$fb
		in	a,($fe)
		or	$e0
		xor	$ff
		jr	z,sub
		add	ix,de
		jr	pgm1
sub		and	a
		push	ix
		pop	hl
		sbc	hl,de
		push	hl
		pop	ix
		jr	pgm4
