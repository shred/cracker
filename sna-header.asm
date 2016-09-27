;
; cracker - A ZX Spectrum Cracker Utility
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

#target sna
#charset zxspectrum

#code HEAD, 0, 27
                defb    $3f             ; i
                defw    0               ; hl'
                defw    0               ; de'
                defw    0               ; bc'
                defw    0               ; af'

                defw    0               ; hl
                defw    0               ; de
                defw    0               ; bc
                defw    0               ; iy
                defw    0               ; ix

                defb    0<<2            ; bit 2 = iff2 (iff1 before nmi) 0=di, 1=ei
                defb    0,0,0           ; r,f,a
                defw    stackend        ; sp
                defb    1               ; irpt mode
                defb    7               ; border color: 0=black ... 7=white


#code GFX_RAM, $4000, $1000

#code CRACKER, $5000, $07e0

#code STACK, $57e0, $0020
stackbot	ds 	0x1e
stackend	dw 	START

#code ATTR_RAM, $5800, $0300

#code SLOW_RAM, $5B00, $2500

#code FAST_RAM, $8000, $8000

#code CRACKER
