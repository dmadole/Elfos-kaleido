
;  Copyright 2022, David S. Madole <david@madole.net>
;
;  This program is free software: you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation, either version 3 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this program.  If not, see <https://www.gnu.org/licenses/>.


           ; Include kernal API entry points

include    include/bios.inc
include    include/kernel.inc


           ; VDP port assignments

#define    EXP_PORT  1
#define    VDP_GROUP 1

#define    VDPRAM 6
#define    VDPREG 7

#define    RDRAM 00h
#define    WRRAM 40h
#define    WRREG 80h


           ; table constants and locations

rows:      equ 48                      ; dimensions of the play field, these
cols:      equ 64                      ; match the 9918 multicolor mode

patterns:  equ 0000h                   ; locations of the display tables in
names:     equ 0800h                   ; the 9918 memory map
sprites:   equ 0b00h


           ; Executable program header

           org     2000h - 6
           dw      start
           dw      end-start
           dw      start

start:     org     2000h
           br      main


           ; Build information

           db      5+80h              ; month
           db      20                 ; day
           dw      2022               ; year
           dw      2                  ; build

           db      'See github.com/dmadole/Elfos-kaleido for more info',0


           ; Initialize 9918 registers to multicolor mode. We blank the display
           ; here as the first thing so initial configuration is ; hidden. The
           ; display will be re-enabled after the first generation is set into
           ; the 9918 memory so it displays all at once.

main:      sex     r3

#ifdef EXP_PORT
           out     EXP_PORT
           db      VDP_GROUP
#endif
           out     VDPREG
           db      088h                ; 16k=1, blank=0, m1=0, m2=1
           out     VDPREG
           db      WRREG + 1

           out     VDPREG
           db      0h                  ; m3=0, external=0
           out     VDPREG
           db      WRREG + 0

           out     VDPREG
           db      names >> 10         ; name table address
           out     VDPREG
           db      WRREG + 2

           out     VDPREG
           db      patterns >> 11      ; pattern attribute address
           out     VDPREG
           db      WRREG + 4

           out     VDPREG
           db      sprites >> 7        ; sprite attribute address
           out     VDPREG
           db      WRREG + 5

           out     VDPREG 
           db      0                   ; background color
           out     VDPREG
           db      WRREG + 7


           ; write empty sprite table

           out     VDPREG
           db      low sprites
           out     VDPREG
           db      WRRAM + high sprites

           out     VDPRAM
           db      208


           ; write name table

           ldi     1
           str     r2

           out     VDPREG
           db      low names
           out     VDPREG
           db      WRRAM + high names

           sex     r2

namecol:   ldi     4
           plo     re

namerow:   ldi     32
           plo     rd

namecell:  out     VDPRAM
           dec     r2

           ldn     r2
           adi     4
           str     r2

           dec     rd
           glo     rd
           lbnz    namecell

           ldn     r2
           smi     128
           str     r2

           dec     re
           glo     re
           lbnz    namerow

           ldn     r2
           adi     1
           str     r2

           smi     131
           lbz     clearpat

           adi     131-4
           lbnz    namecol

           ldi     128
           str     r2

           lbr     namecol


           ; clear pattern table

clearpat:  sex     r3

           out     VDPREG
           db      low patterns
           out     VDPREG
           db      WRRAM + high patterns

           ldi     low (2048+255)
           plo     r7
           ldi     high (2048+255)
           phi     r7

           sex     r2

           ldi     0
           str     r2

zero:      out     VDPRAM
           dec     r2

           dec     r7
           ghi     r7
           lbnz    zero

           sex     r3

           out     VDPREG
           db      0c8h                ; 16k=1, blank=1, m1=0, m2=1
           out     VDPREG
           db      WRREG + 1

           sex     r2

           ldi     0
           plo     r7
           plo     r8
           plo     r9
           plo     ra
           plo     rb
           plo     rc

           ldi     low A005D
           plo     rd
           ldi     high A005D
           phi     rd

A000B:     glo     r7                  ; 000B  MOV  A,B
           shr                         ; 000C  RRC
           lsnf
           ori     80h
           shr                         ; 000D  RRC
           lsnf
           ori     80h
           str     r2                  ; 000E  ANA  D
           glo     r9
           and
           str     r2                  ; 000F  ADD  C
           glo     r8
           add
           plo     r8                  ; 0010  MOV  C,A

           shr                         ; 0011  RRC
           lsnf
           ori     80h
           shr                         ; 0012  RRC
           lsnf
           ori     80h
           str     r2                  ; 0013  ANA  D
           glo     r9
           and
           plo     rb                  ; 0014  MOV  L,A

           glo     r7                  ; 0015  MOV  A,B
           str     r2                  ; 0016  SUB  L
           glo     rb
           sd
           plo     r7                  ; 0017  MOV  B,A

           glo     r8
           smi     192
           lbdf    A004B

           glo     r7                  ; 0018  PUSH B 
           phi     r7
           glo     r8
           phi     r8

           ldi     0                   ; 001B  LXI  D,0
           phi     r9
           phi     ra

           glo     rc                  ; 001E  MOV  A,H
           ani     1fh                 ; 001F  ANI  01FH
           shr                         ; 0021  RAR
           lbdf    A002B               ; 0022  JC   002BH

           shr
           lsnf
           ori     8

           phi     ra                  ; 0025  MOV  E,A
           shl                         ; 0026  RLC
           shl                         ; 0027  RLC
           shl                         ; 0028  RLC
           shl                         ; 0029  RLC
           phi     r9                  ; 002A  MOV  D,A

A002B:     ldi     6                   ; 002B  MVI  H,08H
           phi     rc
           sep     rd                  ; 002D  CALL 005DH

           ghi     r7                  ; 0030  MOV  A,B
           xri     0ffh                ; 0031  CMA
           phi     r7                  ; 0032  MOV  B,A
           ldi     4                   ; 0033  MVI  H,06H
           phi     rc
           sep     rd                  ; 0035  CALL 005DH

           ghi     r8                  ; 0038  MOV  A,C
           xri     0ffh                ; 0039  CMA
           phi     r8                  ; 003A  MOV  C,A
           ldi     0                   ; 003B  MVI  H,02H
           phi     rc
           sep     rd                  ; 003D  CALL 005DH

           ghi     r7                  ; 0040  MOV  A,B
           xri     0ffh                ; 0041  CMA
           phi     r7                  ; 0042  MOV  B,A
           ldi     2                   ; 0043  MVI  H,04H
           phi     rc
           sep     rd                  ; 0045  CALL 005DH

A004B:     dec     ra                  ; 004B  DCR  E
           glo     ra
           lbnz    A000B               ; 004C  JNZ  000BH

           b4      exit

           inc     r7                  ; 004F  INR  B
           inc     r8                  ; 0050  INR  C
           ldi     3fh                 ; 0051  MVI  E,03FH
           plo     ra
           dec     rc                  ; 0053  DCR  H
           glo     rc
           lbnz    A000B               ; 0054  JNZ  0000BH

           inc     r9                  ; 0057  INR  D
           ldi     1fh                 ; 0058  MVI  H,01FH
           plo     rc
           lbr     A000B               ; 005A  JMP  000BH

exit:      sex     r3

           out     VDPREG
           db      088h                ; 16k=1, blank=0, m1=0, m2=1
           out     VDPREG
           db      WRREG + 1

wait:      b4      wait

#ifdef EXP_PORT
           out     EXP_PORT
           db      0
#endif
           sep     r5

A007A:     inp     VDPRAM
           ani     0fh                 ; 007A  ANI  0FH
           str     r2                  ; 007C  ADD  D
           ghi     r9
           add

A007D:     dec     r2                  ; 007D  MOV M,A
           stxd
           ghi     rc
           ori     WRRAM
           stxd
           ghi     rb
           str     r2
           out     VDPREG
           out     VDPREG
           out     VDPRAM

A005C:     sep     r3

A005D:     ghi     r7                  ; 0066  MOV  A,B
           ani     0f0h                ; 0067  ANI  0F0H
           shl                         ; 0069  RAL
           phi     rb                  ; 006F  MOV  L,A

           ghi     rc                  ;       ADC  H
           adci    0
           phi     rc
           dec     r2
           stxd

           ghi     r8                  ; 005D  MOV  A,C
           shr                         ; 005E  ANI  0F8H
           shr                         ; 0060  RAR
           shr                         ;       RAR
           str     r2                  ;       RAR
           ghi     rb
           add
           phi     rb                  ; 0061  MOV  L,A
           str     r2

           out     VDPREG
           out     VDPREG

           ghi     r7
           ani     8h
           lbz     A007A               ; 0072  JC   007AH

           inp     VDPRAM
           ani     0f0h                ; 0075  ANI  0F0H
           str     r2                  ; 0077  ADD  E
           ghi     ra
           add

           lbr     A007D


end:       ; That's all, folks!

