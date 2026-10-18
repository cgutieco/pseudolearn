
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_69571/bounce/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: b940100b     	ldr	w11, [x0, #0x10]
       c: 1100056c     	add	w12, w11, #0x1
      10: b900100c     	str	w12, [x0, #0x10]
      14: f100003f     	cmp	x1, #0x0
      18: aa0103ec     	mov	x12, x1
      1c: 540000ab     	b.lt	0x30 <___pl_fn_0+0x30>
      20: b900100b     	str	w11, [x0, #0x10]
      24: aa0c03e0     	mov	x0, x12
      28: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      2c: d65f03c0     	ret
      30: aa0003ee     	mov	x14, x0
      34: aa0c03e0     	mov	x0, x12
      38: d2800001     	mov	x1, #0x0                ; =0
      3c: eb000021     	subs	x1, x1, x0
      40: 9a9f77e0     	cset	x0, vs
      44: 72001c1f     	tst	w0, #0xff
      48: 540000c1     	b.ne	0x60 <___pl_fn_0+0x60>
      4c: aa0e03e0     	mov	x0, x14
      50: b900100b     	str	w11, [x0, #0x10]
      54: aa0103e0     	mov	x0, x1
      58: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      5c: d65f03c0     	ret
      60: aa0e03e0     	mov	x0, x14
      64: 52800001     	mov	w1, #0x0                ; =0
      68: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
      6c: f9400042     	ldr	x2, [x2]
      70: d63f0040     	blr	x2
      74: d2800000     	mov	x0, #0x0                ; =0
      78: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      7c: d65f03c0     	ret

0000000000000080 <___pl_fn_1>:
      80: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
      84: 910003fd     	mov	x29, sp
      88: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
      8c: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
      90: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      94: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      98: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      9c: d100c3ff     	sub	sp, sp, #0x30
      a0: b9401001     	ldr	w1, [x0, #0x10]
      a4: 11000421     	add	w1, w1, #0x1
      a8: b9001001     	str	w1, [x0, #0x10]
      ac: aa0003f9     	mov	x25, x0
      b0: d2800c80     	mov	x0, #0x64               ; =100
      b4: 910003e3     	mov	x3, sp
      b8: f80003e0     	stur	x0, [sp]
      bc: 52800021     	mov	w1, #0x1                ; =1
      c0: 52802082     	mov	w2, #0x104              ; =260
      c4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      c8: f9400084     	ldr	x4, [x4]
      cc: aa1903e0     	mov	x0, x25
      d0: d63f0080     	blr	x4
      d4: 35003580     	cbnz	w0, 0x784 <___pl_fn_1+0x704>
      d8: aa1903e0     	mov	x0, x25
      dc: f9401813     	ldr	x19, [x0, #0x30]
      e0: b9401816     	ldr	w22, [x0, #0x18]
      e4: b9401c00     	ldr	w0, [x0, #0x1c]
      e8: 110006d5     	add	w21, w22, #0x1
      ec: 6b0002bf     	cmp	w21, w0
      f0: 54003308     	b.hi	0x750 <___pl_fn_1+0x6d0>
      f4: aa1903e0     	mov	x0, x25
      f8: f9401000     	ldr	x0, [x0, #0x20]
      fc: b8365813     	str	w19, [x0, w22, uxtw #2]
     100: aa1903e0     	mov	x0, x25
     104: b9001815     	str	w21, [x0, #0x18]
     108: 52800061     	mov	w1, #0x3                ; =3
     10c: 52800002     	mov	w2, #0x0                ; =0
     110: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     114: f9400063     	ldr	x3, [x3]
     118: d63f0060     	blr	x3
     11c: 35003340     	cbnz	w0, 0x784 <___pl_fn_1+0x704>
     120: aa1903e0     	mov	x0, x25
     124: f9401814     	ldr	x20, [x0, #0x30]
     128: b9001816     	str	w22, [x0, #0x18]
     12c: b9401c04     	ldr	w4, [x0, #0x1c]
     130: 6b0402bf     	cmp	w21, w4
     134: 54002f48     	b.hi	0x71c <___pl_fn_1+0x69c>
     138: aa1903e0     	mov	x0, x25
     13c: f9401006     	ldr	x6, [x0, #0x20]
     140: b83658d3     	str	w19, [x6, w22, uxtw #2]
     144: b9001815     	str	w21, [x0, #0x18]
     148: 528000a1     	mov	w1, #0x5                ; =5
     14c: 52800002     	mov	w2, #0x0                ; =0
     150: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     154: f9400108     	ldr	x8, [x8]
     158: d63f0100     	blr	x8
     15c: 35003140     	cbnz	w0, 0x784 <___pl_fn_1+0x704>
     160: aa1903e0     	mov	x0, x25
     164: f9401815     	ldr	x21, [x0, #0x30]
     168: b9001816     	str	w22, [x0, #0x18]
     16c: 34002bf5     	cbz	w21, 0x6e8 <___pl_fn_1+0x668>
     170: 34001895     	cbz	w21, 0x480 <___pl_fn_1+0x400>
     174: aa1903e0     	mov	x0, x25
     178: f9400001     	ldr	x1, [x0]
     17c: 2a1503e0     	mov	w0, w21
     180: 8b000c20     	add	x0, x1, x0, lsl #3
     184: f8755821     	ldr	x1, [x1, w21, uxtw #3]
     188: d360fc21     	lsr	x1, x1, #32
     18c: 92403c22     	and	x2, x1, #0xffff
     190: f100085f     	cmp	x2, #0x2
     194: 54000080     	b.eq	0x1a4 <___pl_fn_1+0x124>
     198: f9400802     	ldr	x2, [x0, #0x10]
     19c: 927ff842     	and	x2, x2, #0xfffffffffffffffe
     1a0: f9000802     	str	x2, [x0, #0x10]
     1a4: 52848062     	mov	w2, #0x2403             ; =9219
     1a8: 72a00022     	movk	w2, #0x1, lsl #16
     1ac: 92403c21     	and	x1, x1, #0xffff
     1b0: f8217802     	str	x2, [x0, x1, lsl #3]
     1b4: d280001a     	mov	x26, #0x0               ; =0
     1b8: 52800020     	mov	w0, #0x1                ; =1
     1bc: aa1a03f7     	mov	x23, x26
     1c0: f1018eff     	cmp	x23, #0x63
     1c4: 9a9fc7e1     	cset	x1, le
     1c8: 72001c3f     	tst	w1, #0xff
     1cc: 54000d01     	b.ne	0x36c <___pl_fn_1+0x2ec>
     1d0: d2800035     	mov	x21, #0x1               ; =1
     1d4: 52800021     	mov	w1, #0x1                ; =1
     1d8: aa1a03e2     	mov	x2, x26
     1dc: aa0103f6     	mov	x22, x1
     1e0: eb1402bf     	cmp	x21, x20
     1e4: 9a9fc7e0     	cset	x0, le
     1e8: 72001c1f     	tst	w0, #0xff
     1ec: 540002a1     	b.ne	0x240 <___pl_fn_1+0x1c0>
     1f0: 52800141     	mov	w1, #0xa                ; =10
     1f4: 52802003     	mov	w3, #0x100              ; =256
     1f8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     1fc: f9400084     	ldr	x4, [x4]
     200: aa1903e0     	mov	x0, x25
     204: d63f0080     	blr	x4
     208: 35002be0     	cbnz	w0, 0x784 <___pl_fn_1+0x704>
     20c: aa1903e0     	mov	x0, x25
     210: b9401000     	ldr	w0, [x0, #0x10]
     214: 51000400     	sub	w0, w0, #0x1
     218: aa1903e1     	mov	x1, x25
     21c: b9001020     	str	w0, [x1, #0x10]
     220: 9100c3ff     	add	sp, sp, #0x30
     224: a8c153f3     	ldp	x19, x20, [sp], #0x10
     228: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     22c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     230: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     234: a8c173fb     	ldp	x27, x28, [sp], #0x10
     238: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     23c: d65f03c0     	ret
     240: aa0203fb     	mov	x27, x2
     244: 52800020     	mov	w0, #0x1                ; =1
     248: aa1a03f7     	mov	x23, x26
     24c: f1018eff     	cmp	x23, #0x63
     250: 9a9fc7e1     	cset	x1, le
     254: 72001c3f     	tst	w1, #0xff
     258: 54000121     	b.ne	0x27c <___pl_fn_1+0x1fc>
     25c: d2800021     	mov	x1, #0x1                ; =1
     260: ab0102b5     	adds	x21, x21, x1
     264: 9a9f77e1     	cset	x1, vs
     268: 72001c3f     	tst	w1, #0xff
     26c: 54001261     	b.ne	0x4b8 <___pl_fn_1+0x438>
     270: 52800021     	mov	w1, #0x1                ; =1
     274: aa1b03e2     	mov	x2, x27
     278: 17ffffda     	b	0x1e0 <___pl_fn_1+0x160>
     27c: 34001393     	cbz	w19, 0x4ec <___pl_fn_1+0x46c>
     280: aa1903e0     	mov	x0, x25
     284: f9400000     	ldr	x0, [x0]
     288: 2a1303e1     	mov	w1, w19
     28c: 8b010c00     	add	x0, x0, x1, lsl #3
     290: f9400801     	ldr	x1, [x0, #0x10]
     294: eb0102ff     	cmp	x23, x1
     298: 540012a2     	b.hs	0x4ec <___pl_fn_1+0x46c>
     29c: 8b170c00     	add	x0, x0, x23, lsl #3
     2a0: b9402801     	ldr	w1, [x0, #0x28]
     2a4: 350000a1     	cbnz	w1, 0x2b8 <___pl_fn_1+0x238>
     2a8: 14000091     	b	0x4ec <___pl_fn_1+0x46c>
     2ac: aa1903e0     	mov	x0, x25
     2b0: f9401801     	ldr	x1, [x0, #0x30]
     2b4: 14000002     	b	0x2bc <___pl_fn_1+0x23c>
     2b8: aa1903e0     	mov	x0, x25
     2bc: aa1903e0     	mov	x0, x25
     2c0: b9401818     	ldr	w24, [x0, #0x18]
     2c4: b9401c03     	ldr	w3, [x0, #0x1c]
     2c8: 11000b04     	add	w4, w24, #0x2
     2cc: 6b03009f     	cmp	w4, w3
     2d0: 54001708     	b.hi	0x5b0 <___pl_fn_1+0x530>
     2d4: aa1903e0     	mov	x0, x25
     2d8: f9401005     	ldr	x5, [x0, #0x20]
     2dc: 2a1803e6     	mov	w6, w24
     2e0: 8b0608a6     	add	x6, x5, x6, lsl #2
     2e4: b83858b3     	str	w19, [x5, w24, uxtw #2]
     2e8: b90004c1     	str	w1, [x6, #0x4]
     2ec: 11000b07     	add	w7, w24, #0x2
     2f0: b9001807     	str	w7, [x0, #0x18]
     2f4: b9401008     	ldr	w8, [x0, #0x10]
     2f8: b9401409     	ldr	w9, [x0, #0x14]
     2fc: 6b09011f     	cmp	w8, w9
     300: 540013e2     	b.hs	0x57c <___pl_fn_1+0x4fc>
     304: aa1903e0     	mov	x0, x25
     308: 94000000     	bl	0x308 <___pl_fn_1+0x288>
     30c: aa1903e1     	mov	x1, x25
     310: b9402c2a     	ldr	w10, [x1, #0x2c]
     314: 3500238a     	cbnz	w10, 0x784 <___pl_fn_1+0x704>
     318: aa1903e1     	mov	x1, x25
     31c: b9001838     	str	w24, [x1, #0x18]
     320: 72001c1f     	tst	w0, #0xff
     324: 54000061     	b.ne	0x330 <___pl_fn_1+0x2b0>
     328: aa1b03e2     	mov	x2, x27
     32c: 14000008     	b	0x34c <___pl_fn_1+0x2cc>
     330: d2800020     	mov	x0, #0x1                ; =1
     334: aa1b03e2     	mov	x2, x27
     338: ab000042     	adds	x2, x2, x0
     33c: 9a9f77e0     	cset	x0, vs
     340: 72001c1f     	tst	w0, #0xff
     344: 54001021     	b.ne	0x548 <___pl_fn_1+0x4c8>
     348: 52800036     	mov	w22, #0x1               ; =1
     34c: d2800020     	mov	x0, #0x1                ; =1
     350: ab0002f7     	adds	x23, x23, x0
     354: 9a9f77e0     	cset	x0, vs
     358: 72001c1f     	tst	w0, #0xff
     35c: 54000dc1     	b.ne	0x514 <___pl_fn_1+0x494>
     360: 52800020     	mov	w0, #0x1                ; =1
     364: aa0203fb     	mov	x27, x2
     368: 17ffffb9     	b	0x24c <___pl_fn_1+0x1cc>
     36c: aa1903e0     	mov	x0, x25
     370: b940181b     	ldr	w27, [x0, #0x18]
     374: b9401c00     	ldr	w0, [x0, #0x1c]
     378: 11000b61     	add	w1, w27, #0x2
     37c: 6b00003f     	cmp	w1, w0
     380: 540019a8     	b.hi	0x6b4 <___pl_fn_1+0x634>
     384: aa1903e0     	mov	x0, x25
     388: f9401000     	ldr	x0, [x0, #0x20]
     38c: 2a1b03fc     	mov	w28, w27
     390: 8b1c0801     	add	x1, x0, x28, lsl #2
     394: b83b5813     	str	w19, [x0, w27, uxtw #2]
     398: b9000435     	str	w21, [x1, #0x4]
     39c: 11000b60     	add	w0, w27, #0x2
     3a0: aa1903e1     	mov	x1, x25
     3a4: b9001820     	str	w0, [x1, #0x18]
     3a8: 52800261     	mov	w1, #0x13               ; =19
     3ac: 52800022     	mov	w2, #0x1                ; =1
     3b0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     3b4: f9400063     	ldr	x3, [x3]
     3b8: aa1903e0     	mov	x0, x25
     3bc: d63f0060     	blr	x3
     3c0: 35001e20     	cbnz	w0, 0x784 <___pl_fn_1+0x704>
     3c4: aa1903e0     	mov	x0, x25
     3c8: f9401801     	ldr	x1, [x0, #0x30]
     3cc: b900181b     	str	w27, [x0, #0x18]
     3d0: b9401c02     	ldr	w2, [x0, #0x1c]
     3d4: 11000f60     	add	w0, w27, #0x3
     3d8: 6b02001f     	cmp	w0, w2
     3dc: 54001528     	b.hi	0x680 <___pl_fn_1+0x600>
     3e0: aa1903e8     	mov	x8, x25
     3e4: f9401103     	ldr	x3, [x8, #0x20]
     3e8: 8b1c0862     	add	x2, x3, x28, lsl #2
     3ec: b83b5873     	str	w19, [x3, w27, uxtw #2]
     3f0: b9000455     	str	w21, [x2, #0x4]
     3f4: b9000841     	str	w1, [x2, #0x8]
     3f8: aa1903ee     	mov	x14, x25
     3fc: b90019c0     	str	w0, [x14, #0x18]
     400: aa1903e0     	mov	x0, x25
     404: b9401000     	ldr	w0, [x0, #0x10]
     408: aa1903e2     	mov	x2, x25
     40c: b9401442     	ldr	w2, [x2, #0x14]
     410: 6b02001f     	cmp	w0, w2
     414: 540011c2     	b.hs	0x64c <___pl_fn_1+0x5cc>
     418: aa1903e0     	mov	x0, x25
     41c: aa1503e2     	mov	x2, x21
     420: 94000000     	bl	0x420 <___pl_fn_1+0x3a0>
     424: aa1903e1     	mov	x1, x25
     428: b9402c21     	ldr	w1, [x1, #0x2c]
     42c: 35001ac1     	cbnz	w1, 0x784 <___pl_fn_1+0x704>
     430: aa1903e1     	mov	x1, x25
     434: b900183b     	str	w27, [x1, #0x18]
     438: 34000d93     	cbz	w19, 0x5e8 <___pl_fn_1+0x568>
     43c: aa1903e1     	mov	x1, x25
     440: f9400021     	ldr	x1, [x1]
     444: 2a1303e2     	mov	w2, w19
     448: 8b020c21     	add	x1, x1, x2, lsl #3
     44c: f9400822     	ldr	x2, [x1, #0x10]
     450: eb0202ff     	cmp	x23, x2
     454: 54000ca2     	b.hs	0x5e8 <___pl_fn_1+0x568>
     458: 2a0003e0     	mov	w0, w0
     45c: 8b170c21     	add	x1, x1, x23, lsl #3
     460: f9001420     	str	x0, [x1, #0x28]
     464: d2800020     	mov	x0, #0x1                ; =1
     468: ab0002f7     	adds	x23, x23, x0
     46c: 9a9f77e0     	cset	x0, vs
     470: 72001c1f     	tst	w0, #0xff
     474: 54000d21     	b.ne	0x618 <___pl_fn_1+0x598>
     478: 52800020     	mov	w0, #0x1                ; =1
     47c: 17ffff51     	b	0x1c0 <___pl_fn_1+0x140>
     480: d280000d     	mov	x13, #0x0               ; =0
     484: 910023e3     	add	x3, sp, #0x8
     488: f80083ed     	stur	x13, [sp, #0x8]
     48c: 5284806e     	mov	w14, #0x2403            ; =9219
     490: 72a0002e     	movk	w14, #0x1, lsl #16
     494: f80103ee     	stur	x14, [sp, #0x10]
     498: 528000e1     	mov	w1, #0x7                ; =7
     49c: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     4a0: f94001ef     	ldr	x15, [x15]
     4a4: aa1903e0     	mov	x0, x25
     4a8: aa1503e2     	mov	x2, x21
     4ac: d63f01e0     	blr	x15
     4b0: 34ffe820     	cbz	w0, 0x1b4 <___pl_fn_1+0x134>
     4b4: 140000b4     	b	0x784 <___pl_fn_1+0x704>
     4b8: 52800181     	mov	w1, #0xc                ; =12
     4bc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     4c0: f9400042     	ldr	x2, [x2]
     4c4: aa1903e0     	mov	x0, x25
     4c8: d63f0040     	blr	x2
     4cc: 9100c3ff     	add	sp, sp, #0x30
     4d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     4d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     4d8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     4dc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     4e0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     4e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     4e8: d65f03c0     	ret
     4ec: 910063e3     	add	x3, sp, #0x18
     4f0: f80183f7     	stur	x23, [sp, #0x18]
     4f4: 528001a1     	mov	w1, #0xd                ; =13
     4f8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     4fc: f9400084     	ldr	x4, [x4]
     500: aa1903e0     	mov	x0, x25
     504: aa1303e2     	mov	x2, x19
     508: d63f0080     	blr	x4
     50c: 34ffed00     	cbz	w0, 0x2ac <___pl_fn_1+0x22c>
     510: 1400009d     	b	0x784 <___pl_fn_1+0x704>
     514: 52800221     	mov	w1, #0x11               ; =17
     518: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     51c: f9400042     	ldr	x2, [x2]
     520: aa1903e0     	mov	x0, x25
     524: d63f0040     	blr	x2
     528: 9100c3ff     	add	sp, sp, #0x30
     52c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     530: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     534: a8c163f7     	ldp	x23, x24, [sp], #0x10
     538: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     53c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     540: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     544: d65f03c0     	ret
     548: 52800201     	mov	w1, #0x10               ; =16
     54c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     550: f9400042     	ldr	x2, [x2]
     554: aa1903e0     	mov	x0, x25
     558: d63f0040     	blr	x2
     55c: 9100c3ff     	add	sp, sp, #0x30
     560: a8c153f3     	ldp	x19, x20, [sp], #0x10
     564: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     568: a8c163f7     	ldp	x23, x24, [sp], #0x10
     56c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     570: a8c173fb     	ldp	x27, x28, [sp], #0x10
     574: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     578: d65f03c0     	ret
     57c: 528001e1     	mov	w1, #0xf                ; =15
     580: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     584: f9400042     	ldr	x2, [x2]
     588: aa1903e0     	mov	x0, x25
     58c: d63f0040     	blr	x2
     590: 9100c3ff     	add	sp, sp, #0x30
     594: a8c153f3     	ldp	x19, x20, [sp], #0x10
     598: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     59c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     5a0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     5a4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     5a8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     5ac: d65f03c0     	ret
     5b0: 528001c1     	mov	w1, #0xe                ; =14
     5b4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     5b8: f9400042     	ldr	x2, [x2]
     5bc: aa1903e0     	mov	x0, x25
     5c0: d63f0040     	blr	x2
     5c4: 9100c3ff     	add	sp, sp, #0x30
     5c8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     5cc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     5d0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     5d4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     5d8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     5dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     5e0: d65f03c0     	ret
     5e4: 14000068     	b	0x784 <___pl_fn_1+0x704>
     5e8: 910083e3     	add	x3, sp, #0x20
     5ec: f80203f7     	stur	x23, [sp, #0x20]
     5f0: 2a0003e0     	mov	w0, w0
     5f4: f80283e0     	stur	x0, [sp, #0x28]
     5f8: 528002c1     	mov	w1, #0x16               ; =22
     5fc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     600: f9400084     	ldr	x4, [x4]
     604: aa1903e0     	mov	x0, x25
     608: aa1303e2     	mov	x2, x19
     60c: d63f0080     	blr	x4
     610: 34fff2a0     	cbz	w0, 0x464 <___pl_fn_1+0x3e4>
     614: 1400005c     	b	0x784 <___pl_fn_1+0x704>
     618: 528002e1     	mov	w1, #0x17               ; =23
     61c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     620: f9400042     	ldr	x2, [x2]
     624: aa1903e0     	mov	x0, x25
     628: d63f0040     	blr	x2
     62c: 9100c3ff     	add	sp, sp, #0x30
     630: a8c153f3     	ldp	x19, x20, [sp], #0x10
     634: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     638: a8c163f7     	ldp	x23, x24, [sp], #0x10
     63c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     640: a8c173fb     	ldp	x27, x28, [sp], #0x10
     644: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     648: d65f03c0     	ret
     64c: 528002a1     	mov	w1, #0x15               ; =21
     650: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     654: f9400042     	ldr	x2, [x2]
     658: aa1903e0     	mov	x0, x25
     65c: d63f0040     	blr	x2
     660: 9100c3ff     	add	sp, sp, #0x30
     664: a8c153f3     	ldp	x19, x20, [sp], #0x10
     668: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     66c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     670: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     674: a8c173fb     	ldp	x27, x28, [sp], #0x10
     678: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     67c: d65f03c0     	ret
     680: 52800281     	mov	w1, #0x14               ; =20
     684: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     688: f9400042     	ldr	x2, [x2]
     68c: aa1903e0     	mov	x0, x25
     690: d63f0040     	blr	x2
     694: 9100c3ff     	add	sp, sp, #0x30
     698: a8c153f3     	ldp	x19, x20, [sp], #0x10
     69c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6a0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6a4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6a8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     6ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6b0: d65f03c0     	ret
     6b4: 52800241     	mov	w1, #0x12               ; =18
     6b8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6bc: f9400042     	ldr	x2, [x2]
     6c0: aa1903e0     	mov	x0, x25
     6c4: d63f0040     	blr	x2
     6c8: 9100c3ff     	add	sp, sp, #0x30
     6cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6d4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6d8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6dc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     6e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6e4: d65f03c0     	ret
     6e8: 528000c1     	mov	w1, #0x6                ; =6
     6ec: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6f0: f9400042     	ldr	x2, [x2]
     6f4: aa1903e0     	mov	x0, x25
     6f8: d63f0040     	blr	x2
     6fc: 9100c3ff     	add	sp, sp, #0x30
     700: a8c153f3     	ldp	x19, x20, [sp], #0x10
     704: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     708: a8c163f7     	ldp	x23, x24, [sp], #0x10
     70c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     710: a8c173fb     	ldp	x27, x28, [sp], #0x10
     714: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     718: d65f03c0     	ret
     71c: 52800081     	mov	w1, #0x4                ; =4
     720: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     724: f9400042     	ldr	x2, [x2]
     728: aa1903e0     	mov	x0, x25
     72c: d63f0040     	blr	x2
     730: 9100c3ff     	add	sp, sp, #0x30
     734: a8c153f3     	ldp	x19, x20, [sp], #0x10
     738: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     73c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     740: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     744: a8c173fb     	ldp	x27, x28, [sp], #0x10
     748: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     74c: d65f03c0     	ret
     750: 52800041     	mov	w1, #0x2                ; =2
     754: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     758: f9400063     	ldr	x3, [x3]
     75c: aa1903e0     	mov	x0, x25
     760: d63f0060     	blr	x3
     764: 9100c3ff     	add	sp, sp, #0x30
     768: a8c153f3     	ldp	x19, x20, [sp], #0x10
     76c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     770: a8c163f7     	ldp	x23, x24, [sp], #0x10
     774: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     778: a8c173fb     	ldp	x27, x28, [sp], #0x10
     77c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     780: d65f03c0     	ret
     784: 9100c3ff     	add	sp, sp, #0x30
     788: a8c153f3     	ldp	x19, x20, [sp], #0x10
     78c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     790: a8c163f7     	ldp	x23, x24, [sp], #0x10
     794: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     798: a8c173fb     	ldp	x27, x28, [sp], #0x10
     79c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7a0: d65f03c0     	ret

00000000000007a4 <___pl_fn_2>:
     7a4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     7a8: 910003fd     	mov	x29, sp
     7ac: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     7b0: d10043ff     	sub	sp, sp, #0x10
     7b4: aa0103f3     	mov	x19, x1
     7b8: b940100a     	ldr	w10, [x0, #0x10]
     7bc: 1100054a     	add	w10, w10, #0x1
     7c0: b900100a     	str	w10, [x0, #0x10]
     7c4: aa1303e1     	mov	x1, x19
     7c8: 34000961     	cbz	w1, 0x8f4 <___pl_fn_2+0x150>
     7cc: f940000f     	ldr	x15, [x0]
     7d0: aa1303e1     	mov	x1, x19
     7d4: aa0003f4     	mov	x20, x0
     7d8: 2a0103ee     	mov	w14, w1
     7dc: 8b0e0dee     	add	x14, x15, x14, lsl #3
     7e0: f86159ef     	ldr	x15, [x15, w1, uxtw #3]
     7e4: d360fdef     	lsr	x15, x15, #32
     7e8: 92403de0     	and	x0, x15, #0xffff
     7ec: f86079cf     	ldr	x15, [x14, x0, lsl #3]
     7f0: f100081f     	cmp	x0, #0x2
     7f4: 540000c0     	b.eq	0x80c <___pl_fn_2+0x68>
     7f8: f94009c0     	ldr	x0, [x14, #0x10]
     7fc: 370007e0     	tbnz	w0, #0x0, 0x8f8 <___pl_fn_2+0x154>
     800: 14000003     	b	0x80c <___pl_fn_2+0x68>
     804: aa1403e0     	mov	x0, x20
     808: f940180f     	ldr	x15, [x0, #0x30]
     80c: d280a3a1     	mov	x1, #0x51d              ; =1309
     810: 9b017de0     	mul	x0, x15, x1
     814: 9b417de1     	smulh	x1, x15, x1
     818: eb80fc3f     	cmp	x1, x0, asr #63
     81c: 54000d01     	b.ne	0x9bc <___pl_fn_2+0x218>
     820: d286c321     	mov	x1, #0x3619             ; =13849
     824: ab010000     	adds	x0, x0, x1
     828: 9a9f77e1     	cset	x1, vs
     82c: 72001c3f     	tst	w1, #0xff
     830: 54000b21     	b.ne	0x994 <___pl_fn_2+0x1f0>
     834: 34000753     	cbz	w19, 0x91c <___pl_fn_2+0x178>
     838: aa1403eb     	mov	x11, x20
     83c: f9400162     	ldr	x2, [x11]
     840: 2a1303e1     	mov	w1, w19
     844: 8b010c41     	add	x1, x2, x1, lsl #3
     848: f8735842     	ldr	x2, [x2, w19, uxtw #3]
     84c: d360fc42     	lsr	x2, x2, #32
     850: 92403c43     	and	x3, x2, #0xffff
     854: f100087f     	cmp	x3, #0x2
     858: 54000080     	b.eq	0x868 <___pl_fn_2+0xc4>
     85c: f9400823     	ldr	x3, [x1, #0x10]
     860: 927ff863     	and	x3, x3, #0xfffffffffffffffe
     864: f9000823     	str	x3, [x1, #0x10]
     868: 934ffc03     	asr	x3, x0, #15
     86c: d370fc63     	lsr	x3, x3, #48
     870: 8b030003     	add	x3, x0, x3
     874: 9270bc63     	and	x3, x3, #0xffffffffffff0000
     878: cb030000     	sub	x0, x0, x3
     87c: 92403c42     	and	x2, x2, #0xffff
     880: f8227820     	str	x0, [x1, x2, lsl #3]
     884: 340006f3     	cbz	w19, 0x960 <___pl_fn_2+0x1bc>
     888: aa1403e0     	mov	x0, x20
     88c: f9400000     	ldr	x0, [x0]
     890: 2a1303e1     	mov	w1, w19
     894: 8b010c01     	add	x1, x0, x1, lsl #3
     898: f8735800     	ldr	x0, [x0, w19, uxtw #3]
     89c: d360fc00     	lsr	x0, x0, #32
     8a0: 92403c02     	and	x2, x0, #0xffff
     8a4: f8627820     	ldr	x0, [x1, x2, lsl #3]
     8a8: f100085f     	cmp	x2, #0x2
     8ac: 54000100     	b.eq	0x8cc <___pl_fn_2+0x128>
     8b0: f9400821     	ldr	x1, [x1, #0x10]
     8b4: 37000561     	tbnz	w1, #0x0, 0x960 <___pl_fn_2+0x1bc>
     8b8: 14000005     	b	0x8cc <___pl_fn_2+0x128>
     8bc: aa1403e0     	mov	x0, x20
     8c0: f9401800     	ldr	x0, [x0, #0x30]
     8c4: aa1403e1     	mov	x1, x20
     8c8: 14000002     	b	0x8d0 <___pl_fn_2+0x12c>
     8cc: aa1403e1     	mov	x1, x20
     8d0: aa1403e1     	mov	x1, x20
     8d4: b9401021     	ldr	w1, [x1, #0x10]
     8d8: 51000421     	sub	w1, w1, #0x1
     8dc: aa1403e2     	mov	x2, x20
     8e0: b9001041     	str	w1, [x2, #0x10]
     8e4: 910043ff     	add	sp, sp, #0x10
     8e8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8ec: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8f0: d65f03c0     	ret
     8f4: aa0003f4     	mov	x20, x0
     8f8: 52800301     	mov	w1, #0x18               ; =24
     8fc: 52800003     	mov	w3, #0x0                ; =0
     900: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     904: f9400084     	ldr	x4, [x4]
     908: aa1403e0     	mov	x0, x20
     90c: aa1303e2     	mov	x2, x19
     910: d63f0080     	blr	x4
     914: 34fff780     	cbz	w0, 0x804 <___pl_fn_2+0x60>
     918: 1400001a     	b	0x980 <___pl_fn_2+0x1dc>
     91c: d2800001     	mov	x1, #0x0                ; =0
     920: 910003e3     	mov	x3, sp
     924: f80003e1     	stur	x1, [sp]
     928: 934ffc01     	asr	x1, x0, #15
     92c: d370fc21     	lsr	x1, x1, #48
     930: 8b010001     	add	x1, x0, x1
     934: 9270bc21     	and	x1, x1, #0xffffffffffff0000
     938: cb010000     	sub	x0, x0, x1
     93c: f80083e0     	stur	x0, [sp, #0x8]
     940: 52800381     	mov	w1, #0x1c               ; =28
     944: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     948: f9400084     	ldr	x4, [x4]
     94c: aa1403e0     	mov	x0, x20
     950: aa1303e2     	mov	x2, x19
     954: d63f0080     	blr	x4
     958: 34fff960     	cbz	w0, 0x884 <___pl_fn_2+0xe0>
     95c: 14000009     	b	0x980 <___pl_fn_2+0x1dc>
     960: 528003a1     	mov	w1, #0x1d               ; =29
     964: 52800003     	mov	w3, #0x0                ; =0
     968: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     96c: f9400084     	ldr	x4, [x4]
     970: aa1303e2     	mov	x2, x19
     974: aa1403e0     	mov	x0, x20
     978: d63f0080     	blr	x4
     97c: 34fffa00     	cbz	w0, 0x8bc <___pl_fn_2+0x118>
     980: d2800000     	mov	x0, #0x0                ; =0
     984: 910043ff     	add	sp, sp, #0x10
     988: a8c153f3     	ldp	x19, x20, [sp], #0x10
     98c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     990: d65f03c0     	ret
     994: 52800341     	mov	w1, #0x1a               ; =26
     998: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     99c: f9400042     	ldr	x2, [x2]
     9a0: aa1403e0     	mov	x0, x20
     9a4: d63f0040     	blr	x2
     9a8: d2800000     	mov	x0, #0x0                ; =0
     9ac: 910043ff     	add	sp, sp, #0x10
     9b0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9b8: d65f03c0     	ret
     9bc: 52800321     	mov	w1, #0x19               ; =25
     9c0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9c4: f9400042     	ldr	x2, [x2]
     9c8: aa1403e0     	mov	x0, x20
     9cc: d63f0040     	blr	x2
     9d0: d2800000     	mov	x0, #0x0                ; =0
     9d4: 910043ff     	add	sp, sp, #0x10
     9d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9e0: d65f03c0     	ret

00000000000009e4 <___pl_fn_3>:
     9e4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     9e8: 910003fd     	mov	x29, sp
     9ec: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
     9f0: a9bf6bf5     	stp	x21, x26, [sp, #-0x10]!
     9f4: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     9f8: d10103ff     	sub	sp, sp, #0x40
     9fc: aa0203f4     	mov	x20, x2
     a00: b9401002     	ldr	w2, [x0, #0x10]
     a04: 11000442     	add	w2, w2, #0x1
     a08: b9001002     	str	w2, [x0, #0x10]
     a0c: b940181b     	ldr	w27, [x0, #0x18]
     a10: b9401c02     	ldr	w2, [x0, #0x1c]
     a14: 11000b63     	add	w3, w27, #0x2
     a18: 6b02007f     	cmp	w3, w2
     a1c: 540035c8     	b.hi	0x10d4 <___pl_fn_3+0x6f0>
     a20: f9401002     	ldr	x2, [x0, #0x20]
     a24: 2a1b03e3     	mov	w3, w27
     a28: 8b030843     	add	x3, x2, x3, lsl #2
     a2c: b83b5841     	str	w1, [x2, w27, uxtw #2]
     a30: aa1403e2     	mov	x2, x20
     a34: aa0103fc     	mov	x28, x1
     a38: b9000462     	str	w2, [x3, #0x4]
     a3c: 11000b61     	add	w1, w27, #0x2
     a40: b9001801     	str	w1, [x0, #0x18]
     a44: b9401001     	ldr	w1, [x0, #0x10]
     a48: b9401402     	ldr	w2, [x0, #0x14]
     a4c: aa0003fa     	mov	x26, x0
     a50: 6b02003f     	cmp	w1, w2
     a54: 54003282     	b.hs	0x10a4 <___pl_fn_3+0x6c0>
     a58: aa1a03e0     	mov	x0, x26
     a5c: aa1403e1     	mov	x1, x20
     a60: 94000000     	bl	0xa60 <___pl_fn_3+0x7c>
     a64: aa1a03e1     	mov	x1, x26
     a68: b9402c21     	ldr	w1, [x1, #0x2c]
     a6c: 350030e1     	cbnz	w1, 0x1088 <___pl_fn_3+0x6a4>
     a70: aa1a03e1     	mov	x1, x26
     a74: b900183b     	str	w27, [x1, #0x18]
     a78: aa1c03f3     	mov	x19, x28
     a7c: 35000093     	cbnz	w19, 0xa8c <___pl_fn_3+0xa8>
     a80: 140000de     	b	0xdf8 <___pl_fn_3+0x414>
     a84: aa1a03e0     	mov	x0, x26
     a88: 1400001a     	b	0xaf0 <___pl_fn_3+0x10c>
     a8c: aa1a03e1     	mov	x1, x26
     a90: f9400022     	ldr	x2, [x1]
     a94: 2a1303e1     	mov	w1, w19
     a98: 8b010c41     	add	x1, x2, x1, lsl #3
     a9c: f8735842     	ldr	x2, [x2, w19, uxtw #3]
     aa0: d360fc42     	lsr	x2, x2, #32
     aa4: 92403c43     	and	x3, x2, #0xffff
     aa8: f100087f     	cmp	x3, #0x2
     aac: 54000080     	b.eq	0xabc <___pl_fn_3+0xd8>
     ab0: f9400823     	ldr	x3, [x1, #0x10]
     ab4: 927ff863     	and	x3, x3, #0xfffffffffffffffe
     ab8: f9000823     	str	x3, [x1, #0x10]
     abc: d29ef9e3     	mov	x3, #0xf7cf             ; =63439
     ac0: f2bc6a63     	movk	x3, #0xe353, lsl #16
     ac4: f2d374a3     	movk	x3, #0x9ba5, lsl #32
     ac8: f2e41883     	movk	x3, #0x20c4, lsl #48
     acc: 9b437c03     	smulh	x3, x0, x3
     ad0: 9346fc63     	asr	x3, x3, #6
     ad4: d37ffc64     	lsr	x4, x3, #63
     ad8: 8b040063     	add	x3, x3, x4
     adc: d2803e84     	mov	x4, #0x1f4              ; =500
     ae0: 9b048060     	msub	x0, x3, x4, x0
     ae4: 92403c42     	and	x2, x2, #0xffff
     ae8: f8227820     	str	x0, [x1, x2, lsl #3]
     aec: aa1a03e0     	mov	x0, x26
     af0: aa1a03e0     	mov	x0, x26
     af4: b9401815     	ldr	w21, [x0, #0x18]
     af8: b9401c01     	ldr	w1, [x0, #0x1c]
     afc: 11000aa0     	add	w0, w21, #0x2
     b00: 6b01001f     	cmp	w0, w1
     b04: 54002aa8     	b.hi	0x1058 <___pl_fn_3+0x674>
     b08: aa1a03e1     	mov	x1, x26
     b0c: f9401021     	ldr	x1, [x1, #0x20]
     b10: 2a1503e2     	mov	w2, w21
     b14: 8b020822     	add	x2, x1, x2, lsl #2
     b18: b8355833     	str	w19, [x1, w21, uxtw #2]
     b1c: b9000454     	str	w20, [x2, #0x4]
     b20: aa1a03e1     	mov	x1, x26
     b24: b9001820     	str	w0, [x1, #0x18]
     b28: aa1a03e0     	mov	x0, x26
     b2c: b9401000     	ldr	w0, [x0, #0x10]
     b30: b9401421     	ldr	w1, [x1, #0x14]
     b34: 6b01001f     	cmp	w0, w1
     b38: 54002782     	b.hs	0x1028 <___pl_fn_3+0x644>
     b3c: aa1a03e0     	mov	x0, x26
     b40: aa1403e1     	mov	x1, x20
     b44: 94000000     	bl	0xb44 <___pl_fn_3+0x160>
     b48: aa1a03e3     	mov	x3, x26
     b4c: b9402c61     	ldr	w1, [x3, #0x2c]
     b50: 350029c1     	cbnz	w1, 0x1088 <___pl_fn_3+0x6a4>
     b54: aa1a03e7     	mov	x7, x26
     b58: b90018f5     	str	w21, [x7, #0x18]
     b5c: 35000093     	cbnz	w19, 0xb6c <___pl_fn_3+0x188>
     b60: 140000bc     	b	0xe50 <___pl_fn_3+0x46c>
     b64: aa1a03e0     	mov	x0, x26
     b68: 1400001b     	b	0xbd4 <___pl_fn_3+0x1f0>
     b6c: aa1a03e1     	mov	x1, x26
     b70: f9400026     	ldr	x6, [x1]
     b74: 2a1303e5     	mov	w5, w19
     b78: 8b050cc5     	add	x5, x6, x5, lsl #3
     b7c: f87358c6     	ldr	x6, [x6, w19, uxtw #3]
     b80: d360fcc6     	lsr	x6, x6, #32
     b84: 92403cc7     	and	x7, x6, #0xffff
     b88: f10008ff     	cmp	x7, #0x2
     b8c: 54000080     	b.eq	0xb9c <___pl_fn_3+0x1b8>
     b90: f94008a8     	ldr	x8, [x5, #0x10]
     b94: 927ef908     	and	x8, x8, #0xfffffffffffffffd
     b98: f90008a8     	str	x8, [x5, #0x10]
     b9c: d29ef9ea     	mov	x10, #0xf7cf            ; =63439
     ba0: f2bc6a6a     	movk	x10, #0xe353, lsl #16
     ba4: f2d374aa     	movk	x10, #0x9ba5, lsl #32
     ba8: f2e4188a     	movk	x10, #0x20c4, lsl #48
     bac: 9b4a7c0a     	smulh	x10, x0, x10
     bb0: 9346fd4a     	asr	x10, x10, #6
     bb4: d37ffd4b     	lsr	x11, x10, #63
     bb8: 8b0b014a     	add	x10, x10, x11
     bbc: d2803e8b     	mov	x11, #0x1f4             ; =500
     bc0: 9b0b814a     	msub	x10, x10, x11, x0
     bc4: 92403ccb     	and	x11, x6, #0xffff
     bc8: 9100056b     	add	x11, x11, #0x1
     bcc: f82b78aa     	str	x10, [x5, x11, lsl #3]
     bd0: aa1a03e0     	mov	x0, x26
     bd4: aa1a03e0     	mov	x0, x26
     bd8: b9401815     	ldr	w21, [x0, #0x18]
     bdc: b9401c0d     	ldr	w13, [x0, #0x1c]
     be0: 11000aac     	add	w12, w21, #0x2
     be4: 6b0d019f     	cmp	w12, w13
     be8: 54002088     	b.hi	0xff8 <___pl_fn_3+0x614>
     bec: aa1a03e0     	mov	x0, x26
     bf0: f940100e     	ldr	x14, [x0, #0x20]
     bf4: 2a1503ef     	mov	w15, w21
     bf8: 8b0f09cf     	add	x15, x14, x15, lsl #2
     bfc: b83559d3     	str	w19, [x14, w21, uxtw #2]
     c00: b90005f4     	str	w20, [x15, #0x4]
     c04: b900180c     	str	w12, [x0, #0x18]
     c08: b9401000     	ldr	w0, [x0, #0x10]
     c0c: aa1a03ed     	mov	x13, x26
     c10: b94015a1     	ldr	w1, [x13, #0x14]
     c14: 6b01001f     	cmp	w0, w1
     c18: 54001d82     	b.hs	0xfc8 <___pl_fn_3+0x5e4>
     c1c: aa1a03e0     	mov	x0, x26
     c20: aa1403e1     	mov	x1, x20
     c24: 94000000     	bl	0xc24 <___pl_fn_3+0x240>
     c28: aa1a03e1     	mov	x1, x26
     c2c: b9402c21     	ldr	w1, [x1, #0x2c]
     c30: 350022c1     	cbnz	w1, 0x1088 <___pl_fn_3+0x6a4>
     c34: aa1a03e1     	mov	x1, x26
     c38: b9001835     	str	w21, [x1, #0x18]
     c3c: d28740e1     	mov	x1, #0x3a07             ; =14855
     c40: f2b40da1     	movk	x1, #0xa06d, lsl #16
     c44: f2c0da61     	movk	x1, #0x6d3, lsl #32
     c48: f2eda741     	movk	x1, #0x6d3a, lsl #48
     c4c: 9b417c01     	smulh	x1, x0, x1
     c50: 9347fc21     	asr	x1, x1, #7
     c54: d37ffc22     	lsr	x2, x1, #63
     c58: 8b020021     	add	x1, x1, x2
     c5c: d2802582     	mov	x2, #0x12c              ; =300
     c60: 9b028020     	msub	x0, x1, x2, x0
     c64: d28012c1     	mov	x1, #0x96               ; =150
     c68: eb010000     	subs	x0, x0, x1
     c6c: 9a9f77e1     	cset	x1, vs
     c70: 72001c3f     	tst	w1, #0xff
     c74: 54001921     	b.ne	0xf98 <___pl_fn_3+0x5b4>
     c78: 35000093     	cbnz	w19, 0xc88 <___pl_fn_3+0x2a4>
     c7c: 1400008b     	b	0xea8 <___pl_fn_3+0x4c4>
     c80: aa1a03e0     	mov	x0, x26
     c84: 14000011     	b	0xcc8 <___pl_fn_3+0x2e4>
     c88: aa1a03e1     	mov	x1, x26
     c8c: f9400022     	ldr	x2, [x1]
     c90: 2a1303e1     	mov	w1, w19
     c94: 8b010c41     	add	x1, x2, x1, lsl #3
     c98: f8735842     	ldr	x2, [x2, w19, uxtw #3]
     c9c: d360fc42     	lsr	x2, x2, #32
     ca0: 92403c43     	and	x3, x2, #0xffff
     ca4: f100087f     	cmp	x3, #0x2
     ca8: 54000080     	b.eq	0xcb8 <___pl_fn_3+0x2d4>
     cac: f9400823     	ldr	x3, [x1, #0x10]
     cb0: 927df863     	and	x3, x3, #0xfffffffffffffffb
     cb4: f9000823     	str	x3, [x1, #0x10]
     cb8: 92403c42     	and	x2, x2, #0xffff
     cbc: 91000842     	add	x2, x2, #0x2
     cc0: f8227820     	str	x0, [x1, x2, lsl #3]
     cc4: aa1a03e0     	mov	x0, x26
     cc8: aa1a03e0     	mov	x0, x26
     ccc: b9401815     	ldr	w21, [x0, #0x18]
     cd0: b9401c01     	ldr	w1, [x0, #0x1c]
     cd4: 11000aa0     	add	w0, w21, #0x2
     cd8: 6b01001f     	cmp	w0, w1
     cdc: 54001468     	b.hi	0xf68 <___pl_fn_3+0x584>
     ce0: aa1a03ed     	mov	x13, x26
     ce4: f94011a1     	ldr	x1, [x13, #0x20]
     ce8: 2a1503e2     	mov	w2, w21
     cec: 8b020822     	add	x2, x1, x2, lsl #2
     cf0: b8355833     	str	w19, [x1, w21, uxtw #2]
     cf4: b9000454     	str	w20, [x2, #0x4]
     cf8: aa1a03e1     	mov	x1, x26
     cfc: b9001820     	str	w0, [x1, #0x18]
     d00: aa1a03e0     	mov	x0, x26
     d04: b9401000     	ldr	w0, [x0, #0x10]
     d08: b9401421     	ldr	w1, [x1, #0x14]
     d0c: 6b01001f     	cmp	w0, w1
     d10: 54001142     	b.hs	0xf38 <___pl_fn_3+0x554>
     d14: aa1403e1     	mov	x1, x20
     d18: aa1a03e0     	mov	x0, x26
     d1c: 94000000     	bl	0xd1c <___pl_fn_3+0x338>
     d20: aa1a03e1     	mov	x1, x26
     d24: b9402c21     	ldr	w1, [x1, #0x2c]
     d28: 35001b01     	cbnz	w1, 0x1088 <___pl_fn_3+0x6a4>
     d2c: aa1a03e1     	mov	x1, x26
     d30: b9001835     	str	w21, [x1, #0x18]
     d34: d28740e1     	mov	x1, #0x3a07             ; =14855
     d38: f2b40da1     	movk	x1, #0xa06d, lsl #16
     d3c: f2c0da61     	movk	x1, #0x6d3, lsl #32
     d40: f2eda741     	movk	x1, #0x6d3a, lsl #48
     d44: 9b417c01     	smulh	x1, x0, x1
     d48: 9347fc21     	asr	x1, x1, #7
     d4c: d37ffc22     	lsr	x2, x1, #63
     d50: 8b020021     	add	x1, x1, x2
     d54: d2802582     	mov	x2, #0x12c              ; =300
     d58: 9b028020     	msub	x0, x1, x2, x0
     d5c: d28012c1     	mov	x1, #0x96               ; =150
     d60: eb010000     	subs	x0, x0, x1
     d64: 9a9f77e1     	cset	x1, vs
     d68: 72001c3f     	tst	w1, #0xff
     d6c: 54000ce1     	b.ne	0xf08 <___pl_fn_3+0x524>
     d70: 350000b3     	cbnz	w19, 0xd84 <___pl_fn_3+0x3a0>
     d74: 14000059     	b	0xed8 <___pl_fn_3+0x4f4>
     d78: aa1a03e0     	mov	x0, x26
     d7c: aa1303fc     	mov	x28, x19
     d80: 14000012     	b	0xdc8 <___pl_fn_3+0x3e4>
     d84: aa1a03e1     	mov	x1, x26
     d88: f9400022     	ldr	x2, [x1]
     d8c: 2a1303e1     	mov	w1, w19
     d90: 8b010c41     	add	x1, x2, x1, lsl #3
     d94: f8735842     	ldr	x2, [x2, w19, uxtw #3]
     d98: aa1303fc     	mov	x28, x19
     d9c: d360fc42     	lsr	x2, x2, #32
     da0: 92403c43     	and	x3, x2, #0xffff
     da4: f100087f     	cmp	x3, #0x2
     da8: 54000080     	b.eq	0xdb8 <___pl_fn_3+0x3d4>
     dac: f9400823     	ldr	x3, [x1, #0x10]
     db0: 927cf863     	and	x3, x3, #0xfffffffffffffff7
     db4: f9000823     	str	x3, [x1, #0x10]
     db8: 92403c42     	and	x2, x2, #0xffff
     dbc: 91000c42     	add	x2, x2, #0x3
     dc0: f8227820     	str	x0, [x1, x2, lsl #3]
     dc4: aa1a03e0     	mov	x0, x26
     dc8: aa1a03e0     	mov	x0, x26
     dcc: b9401001     	ldr	w1, [x0, #0x10]
     dd0: 51000421     	sub	w1, w1, #0x1
     dd4: b9001001     	str	w1, [x0, #0x10]
     dd8: aa1c03e0     	mov	x0, x28
     ddc: 910103ff     	add	sp, sp, #0x40
     de0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     de4: a8c16bf5     	ldp	x21, x26, [sp], #0x10
     de8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     dec: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     df0: d65f03c0     	ret
     df4: 140000a5     	b	0x1088 <___pl_fn_3+0x6a4>
     df8: d2800001     	mov	x1, #0x0                ; =0
     dfc: 910003e3     	mov	x3, sp
     e00: f80003e1     	stur	x1, [sp]
     e04: d29ef9e1     	mov	x1, #0xf7cf             ; =63439
     e08: f2bc6a61     	movk	x1, #0xe353, lsl #16
     e0c: f2d374a1     	movk	x1, #0x9ba5, lsl #32
     e10: f2e41881     	movk	x1, #0x20c4, lsl #48
     e14: 9b417c01     	smulh	x1, x0, x1
     e18: 9346fc21     	asr	x1, x1, #6
     e1c: d37ffc22     	lsr	x2, x1, #63
     e20: 8b020021     	add	x1, x1, x2
     e24: d2803e82     	mov	x2, #0x1f4              ; =500
     e28: 9b028020     	msub	x0, x1, x2, x0
     e2c: f80083e0     	stur	x0, [sp, #0x8]
     e30: 52800421     	mov	w1, #0x21               ; =33
     e34: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     e38: f9400084     	ldr	x4, [x4]
     e3c: aa1a03e0     	mov	x0, x26
     e40: aa1303e2     	mov	x2, x19
     e44: d63f0080     	blr	x4
     e48: 34ffe1e0     	cbz	w0, 0xa84 <___pl_fn_3+0xa0>
     e4c: 1400008f     	b	0x1088 <___pl_fn_3+0x6a4>
     e50: d2800021     	mov	x1, #0x1                ; =1
     e54: 910043e3     	add	x3, sp, #0x10
     e58: f80103e1     	stur	x1, [sp, #0x10]
     e5c: d29ef9e1     	mov	x1, #0xf7cf             ; =63439
     e60: f2bc6a61     	movk	x1, #0xe353, lsl #16
     e64: f2d374a1     	movk	x1, #0x9ba5, lsl #32
     e68: f2e41881     	movk	x1, #0x20c4, lsl #48
     e6c: 9b417c01     	smulh	x1, x0, x1
     e70: 9346fc21     	asr	x1, x1, #6
     e74: d37ffc22     	lsr	x2, x1, #63
     e78: 8b020021     	add	x1, x1, x2
     e7c: d2803e82     	mov	x2, #0x1f4              ; =500
     e80: 9b028021     	msub	x1, x1, x2, x0
     e84: f80183e1     	stur	x1, [sp, #0x18]
     e88: 528004a1     	mov	w1, #0x25               ; =37
     e8c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     e90: f9400084     	ldr	x4, [x4]
     e94: aa1a03e0     	mov	x0, x26
     e98: aa1303e2     	mov	x2, x19
     e9c: d63f0080     	blr	x4
     ea0: 34ffe620     	cbz	w0, 0xb64 <___pl_fn_3+0x180>
     ea4: 14000079     	b	0x1088 <___pl_fn_3+0x6a4>
     ea8: d2800041     	mov	x1, #0x2                ; =2
     eac: 910083e3     	add	x3, sp, #0x20
     eb0: f80203e1     	stur	x1, [sp, #0x20]
     eb4: f80283e0     	stur	x0, [sp, #0x28]
     eb8: 52800541     	mov	w1, #0x2a               ; =42
     ebc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     ec0: f9400084     	ldr	x4, [x4]
     ec4: aa1a03e0     	mov	x0, x26
     ec8: aa1303e2     	mov	x2, x19
     ecc: d63f0080     	blr	x4
     ed0: 34ffed80     	cbz	w0, 0xc80 <___pl_fn_3+0x29c>
     ed4: 1400006d     	b	0x1088 <___pl_fn_3+0x6a4>
     ed8: d2800061     	mov	x1, #0x3                ; =3
     edc: 9100c3e3     	add	x3, sp, #0x30
     ee0: f80303e1     	stur	x1, [sp, #0x30]
     ee4: f80383e0     	stur	x0, [sp, #0x38]
     ee8: 528005e1     	mov	w1, #0x2f               ; =47
     eec: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     ef0: f9400084     	ldr	x4, [x4]
     ef4: aa1a03e0     	mov	x0, x26
     ef8: aa1303e2     	mov	x2, x19
     efc: d63f0080     	blr	x4
     f00: 34fff3c0     	cbz	w0, 0xd78 <___pl_fn_3+0x394>
     f04: 14000061     	b	0x1088 <___pl_fn_3+0x6a4>
     f08: 528005c1     	mov	w1, #0x2e               ; =46
     f0c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     f10: f9400063     	ldr	x3, [x3]
     f14: aa1a03e0     	mov	x0, x26
     f18: d63f0060     	blr	x3
     f1c: 52800000     	mov	w0, #0x0                ; =0
     f20: 910103ff     	add	sp, sp, #0x40
     f24: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f28: a8c16bf5     	ldp	x21, x26, [sp], #0x10
     f2c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     f30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f34: d65f03c0     	ret
     f38: 52800581     	mov	w1, #0x2c               ; =44
     f3c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     f40: f9400084     	ldr	x4, [x4]
     f44: aa1a03e0     	mov	x0, x26
     f48: d63f0080     	blr	x4
     f4c: 52800000     	mov	w0, #0x0                ; =0
     f50: 910103ff     	add	sp, sp, #0x40
     f54: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f58: a8c16bf5     	ldp	x21, x26, [sp], #0x10
     f5c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     f60: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f64: d65f03c0     	ret
     f68: 52800561     	mov	w1, #0x2b               ; =43
     f6c: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     f70: f94000a5     	ldr	x5, [x5]
     f74: aa1a03e0     	mov	x0, x26
     f78: d63f00a0     	blr	x5
     f7c: 52800000     	mov	w0, #0x0                ; =0
     f80: 910103ff     	add	sp, sp, #0x40
     f84: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f88: a8c16bf5     	ldp	x21, x26, [sp], #0x10
     f8c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     f90: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f94: d65f03c0     	ret
     f98: 52800521     	mov	w1, #0x29               ; =41
     f9c: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     fa0: f94000c6     	ldr	x6, [x6]
     fa4: aa1a03e0     	mov	x0, x26
     fa8: d63f00c0     	blr	x6
     fac: 52800000     	mov	w0, #0x0                ; =0
     fb0: 910103ff     	add	sp, sp, #0x40
     fb4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     fb8: a8c16bf5     	ldp	x21, x26, [sp], #0x10
     fbc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     fc0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     fc4: d65f03c0     	ret
     fc8: 528004e1     	mov	w1, #0x27               ; =39
     fcc: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     fd0: f94000e7     	ldr	x7, [x7]
     fd4: aa1a03e0     	mov	x0, x26
     fd8: d63f00e0     	blr	x7
     fdc: 52800000     	mov	w0, #0x0                ; =0
     fe0: 910103ff     	add	sp, sp, #0x40
     fe4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     fe8: a8c16bf5     	ldp	x21, x26, [sp], #0x10
     fec: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ff0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ff4: d65f03c0     	ret
     ff8: 528004c1     	mov	w1, #0x26               ; =38
     ffc: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
    1000: f9400108     	ldr	x8, [x8]
    1004: aa1a03e0     	mov	x0, x26
    1008: d63f0100     	blr	x8
    100c: 52800000     	mov	w0, #0x0                ; =0
    1010: 910103ff     	add	sp, sp, #0x40
    1014: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1018: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    101c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1020: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1024: d65f03c0     	ret
    1028: 52800461     	mov	w1, #0x23               ; =35
    102c: 90000009     	adrp	x9, 0x1000 <___pl_fn_3+0x61c>
    1030: f9400129     	ldr	x9, [x9]
    1034: aa1a03e0     	mov	x0, x26
    1038: d63f0120     	blr	x9
    103c: 52800000     	mov	w0, #0x0                ; =0
    1040: 910103ff     	add	sp, sp, #0x40
    1044: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1048: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    104c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1050: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1054: d65f03c0     	ret
    1058: 52800441     	mov	w1, #0x22               ; =34
    105c: 9000000a     	adrp	x10, 0x1000 <___pl_fn_3+0x61c>
    1060: f940014a     	ldr	x10, [x10]
    1064: aa1a03e0     	mov	x0, x26
    1068: d63f0140     	blr	x10
    106c: 52800000     	mov	w0, #0x0                ; =0
    1070: 910103ff     	add	sp, sp, #0x40
    1074: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1078: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    107c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1080: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1084: d65f03c0     	ret
    1088: 52800000     	mov	w0, #0x0                ; =0
    108c: 910103ff     	add	sp, sp, #0x40
    1090: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1094: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1098: a8c173fb     	ldp	x27, x28, [sp], #0x10
    109c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    10a0: d65f03c0     	ret
    10a4: 528003e1     	mov	w1, #0x1f               ; =31
    10a8: 9000000c     	adrp	x12, 0x1000 <___pl_fn_3+0x61c>
    10ac: f940018c     	ldr	x12, [x12]
    10b0: aa1a03e0     	mov	x0, x26
    10b4: d63f0180     	blr	x12
    10b8: 52800000     	mov	w0, #0x0                ; =0
    10bc: 910103ff     	add	sp, sp, #0x40
    10c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    10c4: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    10c8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    10cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    10d0: d65f03c0     	ret
    10d4: aa0003fa     	mov	x26, x0
    10d8: 528003c1     	mov	w1, #0x1e               ; =30
    10dc: 9000000d     	adrp	x13, 0x1000 <___pl_fn_3+0x61c>
    10e0: f94001ad     	ldr	x13, [x13]
    10e4: d63f01a0     	blr	x13
    10e8: 52800000     	mov	w0, #0x0                ; =0
    10ec: 910103ff     	add	sp, sp, #0x40
    10f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    10f4: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    10f8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    10fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1100: d65f03c0     	ret

0000000000001104 <___pl_fn_4>:
    1104: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    1108: 910003fd     	mov	x29, sp
    110c: f81f0ff9     	str	x25, [sp, #-0x10]!
    1110: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    1114: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    1118: d10283ff     	sub	sp, sp, #0xa0
    111c: aa0103f3     	mov	x19, x1
    1120: b9401001     	ldr	w1, [x0, #0x10]
    1124: 11000421     	add	w1, w1, #0x1
    1128: b9001001     	str	w1, [x0, #0x10]
    112c: aa1303e1     	mov	x1, x19
    1130: 340040c1     	cbz	w1, 0x1948 <___pl_fn_4+0x844>
    1134: f9400001     	ldr	x1, [x0]
    1138: aa0003f6     	mov	x22, x0
    113c: aa1303e0     	mov	x0, x19
    1140: 2a0003e0     	mov	w0, w0
    1144: 8b000c20     	add	x0, x1, x0, lsl #3
    1148: aa1303e2     	mov	x2, x19
    114c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    1150: d360fc21     	lsr	x1, x1, #32
    1154: 92403c21     	and	x1, x1, #0xffff
    1158: f8617814     	ldr	x20, [x0, x1, lsl #3]
    115c: f100083f     	cmp	x1, #0x2
    1160: 540000c0     	b.eq	0x1178 <___pl_fn_4+0x74>
    1164: f9400800     	ldr	x0, [x0, #0x10]
    1168: 37003f20     	tbnz	w0, #0x0, 0x194c <___pl_fn_4+0x848>
    116c: 14000003     	b	0x1178 <___pl_fn_4+0x74>
    1170: aa1603e0     	mov	x0, x22
    1174: f9401814     	ldr	x20, [x0, #0x30]
    1178: 34003fd3     	cbz	w19, 0x1970 <___pl_fn_4+0x86c>
    117c: aa1603e0     	mov	x0, x22
    1180: f940000a     	ldr	x10, [x0]
    1184: 2a1303e9     	mov	w9, w19
    1188: 8b090d49     	add	x9, x10, x9, lsl #3
    118c: f873594a     	ldr	x10, [x10, w19, uxtw #3]
    1190: d360fd4a     	lsr	x10, x10, #32
    1194: 92403d4a     	and	x10, x10, #0xffff
    1198: 9100094b     	add	x11, x10, #0x2
    119c: f86b7920     	ldr	x0, [x9, x11, lsl #3]
    11a0: f100095f     	cmp	x10, #0x2
    11a4: 540000c0     	b.eq	0x11bc <___pl_fn_4+0xb8>
    11a8: f940092c     	ldr	x12, [x9, #0x10]
    11ac: 37103e2c     	tbnz	w12, #0x2, 0x1970 <___pl_fn_4+0x86c>
    11b0: 14000003     	b	0x11bc <___pl_fn_4+0xb8>
    11b4: aa1603e0     	mov	x0, x22
    11b8: f9401800     	ldr	x0, [x0, #0x30]
    11bc: ab000280     	adds	x0, x20, x0
    11c0: 9a9f77e1     	cset	x1, vs
    11c4: 72001c3f     	tst	w1, #0xff
    11c8: 540069e1     	b.ne	0x1f04 <___pl_fn_4+0xe00>
    11cc: 34003e53     	cbz	w19, 0x1994 <___pl_fn_4+0x890>
    11d0: aa1603e7     	mov	x7, x22
    11d4: f94000e2     	ldr	x2, [x7]
    11d8: 2a1303e1     	mov	w1, w19
    11dc: 8b010c41     	add	x1, x2, x1, lsl #3
    11e0: f8735842     	ldr	x2, [x2, w19, uxtw #3]
    11e4: d360fc42     	lsr	x2, x2, #32
    11e8: 92403c43     	and	x3, x2, #0xffff
    11ec: f100087f     	cmp	x3, #0x2
    11f0: 54000080     	b.eq	0x1200 <___pl_fn_4+0xfc>
    11f4: f9400823     	ldr	x3, [x1, #0x10]
    11f8: 927ff863     	and	x3, x3, #0xfffffffffffffffe
    11fc: f9000823     	str	x3, [x1, #0x10]
    1200: 92403c42     	and	x2, x2, #0xffff
    1204: f8227820     	str	x0, [x1, x2, lsl #3]
    1208: 34003df3     	cbz	w19, 0x19c4 <___pl_fn_4+0x8c0>
    120c: aa1603e0     	mov	x0, x22
    1210: f9400001     	ldr	x1, [x0]
    1214: 2a1303e0     	mov	w0, w19
    1218: 8b000c20     	add	x0, x1, x0, lsl #3
    121c: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    1220: d360fc21     	lsr	x1, x1, #32
    1224: 92403c21     	and	x1, x1, #0xffff
    1228: 91000422     	add	x2, x1, #0x1
    122c: f8627814     	ldr	x20, [x0, x2, lsl #3]
    1230: f100083f     	cmp	x1, #0x2
    1234: 540000c0     	b.eq	0x124c <___pl_fn_4+0x148>
    1238: f9400800     	ldr	x0, [x0, #0x10]
    123c: 37083c40     	tbnz	w0, #0x1, 0x19c4 <___pl_fn_4+0x8c0>
    1240: 14000003     	b	0x124c <___pl_fn_4+0x148>
    1244: aa1603e0     	mov	x0, x22
    1248: f9401814     	ldr	x20, [x0, #0x30]
    124c: 34003cf3     	cbz	w19, 0x19e8 <___pl_fn_4+0x8e4>
    1250: aa1603e0     	mov	x0, x22
    1254: f9400001     	ldr	x1, [x0]
    1258: 2a1303e0     	mov	w0, w19
    125c: 8b000c20     	add	x0, x1, x0, lsl #3
    1260: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    1264: d360fc21     	lsr	x1, x1, #32
    1268: 92403c21     	and	x1, x1, #0xffff
    126c: 91000c22     	add	x2, x1, #0x3
    1270: f8627802     	ldr	x2, [x0, x2, lsl #3]
    1274: f100083f     	cmp	x1, #0x2
    1278: 540000c0     	b.eq	0x1290 <___pl_fn_4+0x18c>
    127c: f9400800     	ldr	x0, [x0, #0x10]
    1280: 37183b40     	tbnz	w0, #0x3, 0x19e8 <___pl_fn_4+0x8e4>
    1284: 14000003     	b	0x1290 <___pl_fn_4+0x18c>
    1288: aa1603e0     	mov	x0, x22
    128c: f9401802     	ldr	x2, [x0, #0x30]
    1290: ab020280     	adds	x0, x20, x2
    1294: 9a9f77e1     	cset	x1, vs
    1298: 72001c3f     	tst	w1, #0xff
    129c: 540061c1     	b.ne	0x1ed4 <___pl_fn_4+0xdd0>
    12a0: 34003b73     	cbz	w19, 0x1a0c <___pl_fn_4+0x908>
    12a4: aa1603e1     	mov	x1, x22
    12a8: f9400024     	ldr	x4, [x1]
    12ac: 2a1303e3     	mov	w3, w19
    12b0: 8b030c83     	add	x3, x4, x3, lsl #3
    12b4: f8735884     	ldr	x4, [x4, w19, uxtw #3]
    12b8: d360fc84     	lsr	x4, x4, #32
    12bc: 92403c85     	and	x5, x4, #0xffff
    12c0: f10008bf     	cmp	x5, #0x2
    12c4: 54000080     	b.eq	0x12d4 <___pl_fn_4+0x1d0>
    12c8: f9400866     	ldr	x6, [x3, #0x10]
    12cc: 927ef8c6     	and	x6, x6, #0xfffffffffffffffd
    12d0: f9000866     	str	x6, [x3, #0x10]
    12d4: 92403c88     	and	x8, x4, #0xffff
    12d8: 91000508     	add	x8, x8, #0x1
    12dc: f8287860     	str	x0, [x3, x8, lsl #3]
    12e0: 34003af3     	cbz	w19, 0x1a3c <___pl_fn_4+0x938>
    12e4: aa1603e0     	mov	x0, x22
    12e8: f940000d     	ldr	x13, [x0]
    12ec: 2a1303ec     	mov	w12, w19
    12f0: 8b0c0dac     	add	x12, x13, x12, lsl #3
    12f4: f87359ad     	ldr	x13, [x13, w19, uxtw #3]
    12f8: d360fdad     	lsr	x13, x13, #32
    12fc: 92403dad     	and	x13, x13, #0xffff
    1300: f86d7980     	ldr	x0, [x12, x13, lsl #3]
    1304: f10009bf     	cmp	x13, #0x2
    1308: 540000c0     	b.eq	0x1320 <___pl_fn_4+0x21c>
    130c: f940098f     	ldr	x15, [x12, #0x10]
    1310: 3700396f     	tbnz	w15, #0x0, 0x1a3c <___pl_fn_4+0x938>
    1314: 14000003     	b	0x1320 <___pl_fn_4+0x21c>
    1318: aa1603e0     	mov	x0, x22
    131c: f9401800     	ldr	x0, [x0, #0x30]
    1320: f107d01f     	cmp	x0, #0x1f4
    1324: 5400008c     	b.gt	0x1334 <___pl_fn_4+0x230>
    1328: 52800000     	mov	w0, #0x0                ; =0
    132c: aa0003f4     	mov	x20, x0
    1330: 14000053     	b	0x147c <___pl_fn_4+0x378>
    1334: 34003973     	cbz	w19, 0x1a60 <___pl_fn_4+0x95c>
    1338: aa1603e0     	mov	x0, x22
    133c: f9400001     	ldr	x1, [x0]
    1340: 2a1303e0     	mov	w0, w19
    1344: 8b000c20     	add	x0, x1, x0, lsl #3
    1348: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    134c: d360fc21     	lsr	x1, x1, #32
    1350: 92403c22     	and	x2, x1, #0xffff
    1354: f100085f     	cmp	x2, #0x2
    1358: 54000080     	b.eq	0x1368 <___pl_fn_4+0x264>
    135c: f9400802     	ldr	x2, [x0, #0x10]
    1360: 927ff842     	and	x2, x2, #0xfffffffffffffffe
    1364: f9000802     	str	x2, [x0, #0x10]
    1368: d2803e82     	mov	x2, #0x1f4              ; =500
    136c: 92403c21     	and	x1, x1, #0xffff
    1370: f8217802     	str	x2, [x0, x1, lsl #3]
    1374: 34003913     	cbz	w19, 0x1a94 <___pl_fn_4+0x990>
    1378: aa1603e0     	mov	x0, x22
    137c: f9400001     	ldr	x1, [x0]
    1380: 2a1303e0     	mov	w0, w19
    1384: 8b000c20     	add	x0, x1, x0, lsl #3
    1388: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    138c: d360fc21     	lsr	x1, x1, #32
    1390: 92403c22     	and	x2, x1, #0xffff
    1394: 91000841     	add	x1, x2, #0x2
    1398: f8617801     	ldr	x1, [x0, x1, lsl #3]
    139c: f100085f     	cmp	x2, #0x2
    13a0: 540000e0     	b.eq	0x13bc <___pl_fn_4+0x2b8>
    13a4: f9400800     	ldr	x0, [x0, #0x10]
    13a8: 37103760     	tbnz	w0, #0x2, 0x1a94 <___pl_fn_4+0x990>
    13ac: 14000004     	b	0x13bc <___pl_fn_4+0x2b8>
    13b0: aa1603e0     	mov	x0, x22
    13b4: f9401801     	ldr	x1, [x0, #0x30]
    13b8: 14000002     	b	0x13c0 <___pl_fn_4+0x2bc>
    13bc: aa1603e0     	mov	x0, x22
    13c0: aa1603e0     	mov	x0, x22
    13c4: b9401815     	ldr	w21, [x0, #0x18]
    13c8: b9401c02     	ldr	w2, [x0, #0x1c]
    13cc: 110006a0     	add	w0, w21, #0x1
    13d0: 6b02001f     	cmp	w0, w2
    13d4: 54005688     	b.hi	0x1ea4 <___pl_fn_4+0xda0>
    13d8: aa1603e2     	mov	x2, x22
    13dc: f9401042     	ldr	x2, [x2, #0x20]
    13e0: d2800054     	mov	x20, #0x2               ; =2
    13e4: b8355853     	str	w19, [x2, w21, uxtw #2]
    13e8: aa1603e2     	mov	x2, x22
    13ec: b9001840     	str	w0, [x2, #0x18]
    13f0: aa1603e0     	mov	x0, x22
    13f4: b9401000     	ldr	w0, [x0, #0x10]
    13f8: b9401442     	ldr	w2, [x2, #0x14]
    13fc: 6b02001f     	cmp	w0, w2
    1400: 540053a2     	b.hs	0x1e74 <___pl_fn_4+0xd70>
    1404: aa1603e0     	mov	x0, x22
    1408: 94000000     	bl	0x1408 <___pl_fn_4+0x304>
    140c: aa1603e1     	mov	x1, x22
    1410: b9402c21     	ldr	w1, [x1, #0x2c]
    1414: 35005221     	cbnz	w1, 0x1e58 <___pl_fn_4+0xd54>
    1418: aa1603e1     	mov	x1, x22
    141c: b9001835     	str	w21, [x1, #0x18]
    1420: d2800001     	mov	x1, #0x0                ; =0
    1424: eb000020     	subs	x0, x1, x0
    1428: 9a9f77e1     	cset	x1, vs
    142c: 72001c3f     	tst	w1, #0xff
    1430: 54004fc1     	b.ne	0x1e28 <___pl_fn_4+0xd24>
    1434: 34003433     	cbz	w19, 0x1ab8 <___pl_fn_4+0x9b4>
    1438: aa1603e1     	mov	x1, x22
    143c: f9400025     	ldr	x5, [x1]
    1440: 2a1303e4     	mov	w4, w19
    1444: 8b040ca4     	add	x4, x5, x4, lsl #3
    1448: f87358a5     	ldr	x5, [x5, w19, uxtw #3]
    144c: d360fca5     	lsr	x5, x5, #32
    1450: 92403ca6     	and	x6, x5, #0xffff
    1454: f10008df     	cmp	x6, #0x2
    1458: 54000080     	b.eq	0x1468 <___pl_fn_4+0x364>
    145c: f9400887     	ldr	x7, [x4, #0x10]
    1460: 927df8e7     	and	x7, x7, #0xfffffffffffffffb
    1464: f9000887     	str	x7, [x4, #0x10]
    1468: 92403ca9     	and	x9, x5, #0xffff
    146c: 91000929     	add	x9, x9, #0x2
    1470: f8297880     	str	x0, [x4, x9, lsl #3]
    1474: 52800020     	mov	w0, #0x1                ; =1
    1478: aa0003f4     	mov	x20, x0
    147c: 34003353     	cbz	w19, 0x1ae4 <___pl_fn_4+0x9e0>
    1480: aa1603e0     	mov	x0, x22
    1484: f9400000     	ldr	x0, [x0]
    1488: 2a1303ef     	mov	w15, w19
    148c: 8b0f0c0f     	add	x15, x0, x15, lsl #3
    1490: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    1494: d360fc00     	lsr	x0, x0, #32
    1498: 92403c00     	and	x0, x0, #0xffff
    149c: f86079eb     	ldr	x11, [x15, x0, lsl #3]
    14a0: f100081f     	cmp	x0, #0x2
    14a4: 540000c0     	b.eq	0x14bc <___pl_fn_4+0x3b8>
    14a8: f94009e0     	ldr	x0, [x15, #0x10]
    14ac: 370031c0     	tbnz	w0, #0x0, 0x1ae4 <___pl_fn_4+0x9e0>
    14b0: 14000003     	b	0x14bc <___pl_fn_4+0x3b8>
    14b4: aa1603e0     	mov	x0, x22
    14b8: f940180b     	ldr	x11, [x0, #0x30]
    14bc: d2800019     	mov	x25, #0x0               ; =0
    14c0: f100017f     	cmp	x11, #0x0
    14c4: 540009aa     	b.ge	0x15f8 <___pl_fn_4+0x4f4>
    14c8: 34003213     	cbz	w19, 0x1b08 <___pl_fn_4+0xa04>
    14cc: aa1603e0     	mov	x0, x22
    14d0: f9400001     	ldr	x1, [x0]
    14d4: 2a1303e0     	mov	w0, w19
    14d8: 8b000c20     	add	x0, x1, x0, lsl #3
    14dc: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    14e0: d360fc21     	lsr	x1, x1, #32
    14e4: 92403c22     	and	x2, x1, #0xffff
    14e8: f100085f     	cmp	x2, #0x2
    14ec: 54000080     	b.eq	0x14fc <___pl_fn_4+0x3f8>
    14f0: f9400802     	ldr	x2, [x0, #0x10]
    14f4: 927ff842     	and	x2, x2, #0xfffffffffffffffe
    14f8: f9000802     	str	x2, [x0, #0x10]
    14fc: 92403c21     	and	x1, x1, #0xffff
    1500: f8217819     	str	x25, [x0, x1, lsl #3]
    1504: 34003193     	cbz	w19, 0x1b34 <___pl_fn_4+0xa30>
    1508: aa1603e0     	mov	x0, x22
    150c: f9400001     	ldr	x1, [x0]
    1510: 2a1303e0     	mov	w0, w19
    1514: 8b000c20     	add	x0, x1, x0, lsl #3
    1518: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    151c: d360fc21     	lsr	x1, x1, #32
    1520: 92403c22     	and	x2, x1, #0xffff
    1524: 91000841     	add	x1, x2, #0x2
    1528: f8617801     	ldr	x1, [x0, x1, lsl #3]
    152c: f100085f     	cmp	x2, #0x2
    1530: 540000e0     	b.eq	0x154c <___pl_fn_4+0x448>
    1534: f9400800     	ldr	x0, [x0, #0x10]
    1538: 37102fe0     	tbnz	w0, #0x2, 0x1b34 <___pl_fn_4+0xa30>
    153c: 14000004     	b	0x154c <___pl_fn_4+0x448>
    1540: aa1603e0     	mov	x0, x22
    1544: f9401801     	ldr	x1, [x0, #0x30]
    1548: 14000002     	b	0x1550 <___pl_fn_4+0x44c>
    154c: aa1603e0     	mov	x0, x22
    1550: aa1603e0     	mov	x0, x22
    1554: b9401814     	ldr	w20, [x0, #0x18]
    1558: b9401c02     	ldr	w2, [x0, #0x1c]
    155c: 11000680     	add	w0, w20, #0x1
    1560: 6b02001f     	cmp	w0, w2
    1564: 540044a8     	b.hi	0x1df8 <___pl_fn_4+0xcf4>
    1568: aa1603e2     	mov	x2, x22
    156c: f9401042     	ldr	x2, [x2, #0x20]
    1570: d2800055     	mov	x21, #0x2               ; =2
    1574: b8345853     	str	w19, [x2, w20, uxtw #2]
    1578: aa1603e2     	mov	x2, x22
    157c: b9001840     	str	w0, [x2, #0x18]
    1580: aa1603e0     	mov	x0, x22
    1584: b9401000     	ldr	w0, [x0, #0x10]
    1588: b9401442     	ldr	w2, [x2, #0x14]
    158c: 6b02001f     	cmp	w0, w2
    1590: 540041c2     	b.hs	0x1dc8 <___pl_fn_4+0xcc4>
    1594: aa1603e0     	mov	x0, x22
    1598: 94000000     	bl	0x1598 <___pl_fn_4+0x494>
    159c: aa1603e1     	mov	x1, x22
    15a0: b9402c21     	ldr	w1, [x1, #0x2c]
    15a4: 350045a1     	cbnz	w1, 0x1e58 <___pl_fn_4+0xd54>
    15a8: aa1603e1     	mov	x1, x22
    15ac: b9001834     	str	w20, [x1, #0x18]
    15b0: 34002d53     	cbz	w19, 0x1b58 <___pl_fn_4+0xa54>
    15b4: aa1603e8     	mov	x8, x22
    15b8: f9400106     	ldr	x6, [x8]
    15bc: 2a1303e5     	mov	w5, w19
    15c0: 8b050cc5     	add	x5, x6, x5, lsl #3
    15c4: f87358c6     	ldr	x6, [x6, w19, uxtw #3]
    15c8: d360fcc6     	lsr	x6, x6, #32
    15cc: 92403cc7     	and	x7, x6, #0xffff
    15d0: f10008ff     	cmp	x7, #0x2
    15d4: 54000080     	b.eq	0x15e4 <___pl_fn_4+0x4e0>
    15d8: f94008a8     	ldr	x8, [x5, #0x10]
    15dc: 927df908     	and	x8, x8, #0xfffffffffffffffb
    15e0: f90008a8     	str	x8, [x5, #0x10]
    15e4: 92403cca     	and	x10, x6, #0xffff
    15e8: 9100094a     	add	x10, x10, #0x2
    15ec: f82a78a0     	str	x0, [x5, x10, lsl #3]
    15f0: 52800020     	mov	w0, #0x1                ; =1
    15f4: aa0003f4     	mov	x20, x0
    15f8: 34002c73     	cbz	w19, 0x1b84 <___pl_fn_4+0xa80>
    15fc: aa1603e0     	mov	x0, x22
    1600: f9400000     	ldr	x0, [x0]
    1604: 2a1303e1     	mov	w1, w19
    1608: 8b010c01     	add	x1, x0, x1, lsl #3
    160c: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    1610: d360fc00     	lsr	x0, x0, #32
    1614: 92403c02     	and	x2, x0, #0xffff
    1618: 91000440     	add	x0, x2, #0x1
    161c: f8607820     	ldr	x0, [x1, x0, lsl #3]
    1620: f100085f     	cmp	x2, #0x2
    1624: 540000c0     	b.eq	0x163c <___pl_fn_4+0x538>
    1628: f9400821     	ldr	x1, [x1, #0x10]
    162c: 37082ac1     	tbnz	w1, #0x1, 0x1b84 <___pl_fn_4+0xa80>
    1630: 14000003     	b	0x163c <___pl_fn_4+0x538>
    1634: aa1603e0     	mov	x0, x22
    1638: f9401800     	ldr	x0, [x0, #0x30]
    163c: f107d01f     	cmp	x0, #0x1f4
    1640: 54000a6d     	b.le	0x178c <___pl_fn_4+0x688>
    1644: 34002b33     	cbz	w19, 0x1ba8 <___pl_fn_4+0xaa4>
    1648: aa1603e0     	mov	x0, x22
    164c: f9400001     	ldr	x1, [x0]
    1650: 2a1303e0     	mov	w0, w19
    1654: 8b000c20     	add	x0, x1, x0, lsl #3
    1658: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    165c: d360fc21     	lsr	x1, x1, #32
    1660: 92403c22     	and	x2, x1, #0xffff
    1664: f100085f     	cmp	x2, #0x2
    1668: 54000080     	b.eq	0x1678 <___pl_fn_4+0x574>
    166c: f9400802     	ldr	x2, [x0, #0x10]
    1670: 927ef842     	and	x2, x2, #0xfffffffffffffffd
    1674: f9000802     	str	x2, [x0, #0x10]
    1678: d2803e82     	mov	x2, #0x1f4              ; =500
    167c: 92403c21     	and	x1, x1, #0xffff
    1680: 91000421     	add	x1, x1, #0x1
    1684: f8217802     	str	x2, [x0, x1, lsl #3]
    1688: 34002ab3     	cbz	w19, 0x1bdc <___pl_fn_4+0xad8>
    168c: aa1603e0     	mov	x0, x22
    1690: f9400001     	ldr	x1, [x0]
    1694: 2a1303e0     	mov	w0, w19
    1698: 8b000c20     	add	x0, x1, x0, lsl #3
    169c: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    16a0: d360fc21     	lsr	x1, x1, #32
    16a4: 92403c22     	and	x2, x1, #0xffff
    16a8: 91000c41     	add	x1, x2, #0x3
    16ac: f8617801     	ldr	x1, [x0, x1, lsl #3]
    16b0: f100085f     	cmp	x2, #0x2
    16b4: 540000e0     	b.eq	0x16d0 <___pl_fn_4+0x5cc>
    16b8: f9400800     	ldr	x0, [x0, #0x10]
    16bc: 37182900     	tbnz	w0, #0x3, 0x1bdc <___pl_fn_4+0xad8>
    16c0: 14000004     	b	0x16d0 <___pl_fn_4+0x5cc>
    16c4: aa1603e0     	mov	x0, x22
    16c8: f9401801     	ldr	x1, [x0, #0x30]
    16cc: 14000002     	b	0x16d4 <___pl_fn_4+0x5d0>
    16d0: aa1603e0     	mov	x0, x22
    16d4: aa1603e0     	mov	x0, x22
    16d8: b9401814     	ldr	w20, [x0, #0x18]
    16dc: b9401c02     	ldr	w2, [x0, #0x1c]
    16e0: 11000680     	add	w0, w20, #0x1
    16e4: 6b02001f     	cmp	w0, w2
    16e8: 54003588     	b.hi	0x1d98 <___pl_fn_4+0xc94>
    16ec: aa1603e2     	mov	x2, x22
    16f0: f9401042     	ldr	x2, [x2, #0x20]
    16f4: b8345853     	str	w19, [x2, w20, uxtw #2]
    16f8: aa1603e3     	mov	x3, x22
    16fc: b9001860     	str	w0, [x3, #0x18]
    1700: aa1603e0     	mov	x0, x22
    1704: b9401000     	ldr	w0, [x0, #0x10]
    1708: aa1603e7     	mov	x7, x22
    170c: b94014e2     	ldr	w2, [x7, #0x14]
    1710: 6b02001f     	cmp	w0, w2
    1714: 540032a2     	b.hs	0x1d68 <___pl_fn_4+0xc64>
    1718: aa1603e0     	mov	x0, x22
    171c: 94000000     	bl	0x171c <___pl_fn_4+0x618>
    1720: aa1603ec     	mov	x12, x22
    1724: b9402d81     	ldr	w1, [x12, #0x2c]
    1728: 35003981     	cbnz	w1, 0x1e58 <___pl_fn_4+0xd54>
    172c: aa1603e1     	mov	x1, x22
    1730: b9001834     	str	w20, [x1, #0x18]
    1734: eb000320     	subs	x0, x25, x0
    1738: 9a9f77e1     	cset	x1, vs
    173c: 72001c3f     	tst	w1, #0xff
    1740: 54002fc1     	b.ne	0x1d38 <___pl_fn_4+0xc34>
    1744: 340025f3     	cbz	w19, 0x1c00 <___pl_fn_4+0xafc>
    1748: aa1603e1     	mov	x1, x22
    174c: f9400029     	ldr	x9, [x1]
    1750: 2a1303e8     	mov	w8, w19
    1754: 8b080d28     	add	x8, x9, x8, lsl #3
    1758: f8735929     	ldr	x9, [x9, w19, uxtw #3]
    175c: d360fd29     	lsr	x9, x9, #32
    1760: 92403d2a     	and	x10, x9, #0xffff
    1764: f100095f     	cmp	x10, #0x2
    1768: 54000080     	b.eq	0x1778 <___pl_fn_4+0x674>
    176c: f940090b     	ldr	x11, [x8, #0x10]
    1770: 927cf96b     	and	x11, x11, #0xfffffffffffffff7
    1774: f900090b     	str	x11, [x8, #0x10]
    1778: 92403d2d     	and	x13, x9, #0xffff
    177c: 91000dad     	add	x13, x13, #0x3
    1780: f82d7900     	str	x0, [x8, x13, lsl #3]
    1784: 52800020     	mov	w0, #0x1                ; =1
    1788: aa0003f4     	mov	x20, x0
    178c: 34002533     	cbz	w19, 0x1c30 <___pl_fn_4+0xb2c>
    1790: aa1603e0     	mov	x0, x22
    1794: f9400000     	ldr	x0, [x0]
    1798: 2a1303e1     	mov	w1, w19
    179c: 8b010c01     	add	x1, x0, x1, lsl #3
    17a0: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    17a4: d360fc00     	lsr	x0, x0, #32
    17a8: 92403c02     	and	x2, x0, #0xffff
    17ac: 91000440     	add	x0, x2, #0x1
    17b0: f8607820     	ldr	x0, [x1, x0, lsl #3]
    17b4: f100085f     	cmp	x2, #0x2
    17b8: 540000c0     	b.eq	0x17d0 <___pl_fn_4+0x6cc>
    17bc: f9400821     	ldr	x1, [x1, #0x10]
    17c0: 37082381     	tbnz	w1, #0x1, 0x1c30 <___pl_fn_4+0xb2c>
    17c4: 14000003     	b	0x17d0 <___pl_fn_4+0x6cc>
    17c8: aa1603e0     	mov	x0, x22
    17cc: f9401800     	ldr	x0, [x0, #0x30]
    17d0: f100001f     	cmp	x0, #0x0
    17d4: 5400006b     	b.lt	0x17e0 <___pl_fn_4+0x6dc>
    17d8: aa1603e0     	mov	x0, x22
    17dc: 1400004f     	b	0x1918 <___pl_fn_4+0x814>
    17e0: 340023b3     	cbz	w19, 0x1c54 <___pl_fn_4+0xb50>
    17e4: aa1603e0     	mov	x0, x22
    17e8: f9400001     	ldr	x1, [x0]
    17ec: 2a1303e0     	mov	w0, w19
    17f0: 8b000c20     	add	x0, x1, x0, lsl #3
    17f4: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    17f8: d360fc21     	lsr	x1, x1, #32
    17fc: 92403c22     	and	x2, x1, #0xffff
    1800: f100085f     	cmp	x2, #0x2
    1804: 54000080     	b.eq	0x1814 <___pl_fn_4+0x710>
    1808: f9400802     	ldr	x2, [x0, #0x10]
    180c: 927ef842     	and	x2, x2, #0xfffffffffffffffd
    1810: f9000802     	str	x2, [x0, #0x10]
    1814: 92403c21     	and	x1, x1, #0xffff
    1818: 91000421     	add	x1, x1, #0x1
    181c: f8217819     	str	x25, [x0, x1, lsl #3]
    1820: 34002333     	cbz	w19, 0x1c84 <___pl_fn_4+0xb80>
    1824: aa1603e0     	mov	x0, x22
    1828: f9400001     	ldr	x1, [x0]
    182c: 2a1303e0     	mov	w0, w19
    1830: 8b000c20     	add	x0, x1, x0, lsl #3
    1834: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    1838: d360fc21     	lsr	x1, x1, #32
    183c: 92403c22     	and	x2, x1, #0xffff
    1840: 91000c41     	add	x1, x2, #0x3
    1844: f8617801     	ldr	x1, [x0, x1, lsl #3]
    1848: f100085f     	cmp	x2, #0x2
    184c: 540000e0     	b.eq	0x1868 <___pl_fn_4+0x764>
    1850: f9400800     	ldr	x0, [x0, #0x10]
    1854: 37182180     	tbnz	w0, #0x3, 0x1c84 <___pl_fn_4+0xb80>
    1858: 14000004     	b	0x1868 <___pl_fn_4+0x764>
    185c: aa1603e0     	mov	x0, x22
    1860: f9401801     	ldr	x1, [x0, #0x30]
    1864: 14000002     	b	0x186c <___pl_fn_4+0x768>
    1868: aa1603e0     	mov	x0, x22
    186c: aa1603e0     	mov	x0, x22
    1870: b9401814     	ldr	w20, [x0, #0x18]
    1874: b9401c02     	ldr	w2, [x0, #0x1c]
    1878: 11000680     	add	w0, w20, #0x1
    187c: 6b02001f     	cmp	w0, w2
    1880: 54002448     	b.hi	0x1d08 <___pl_fn_4+0xc04>
    1884: aa1603e2     	mov	x2, x22
    1888: f9401042     	ldr	x2, [x2, #0x20]
    188c: b8345853     	str	w19, [x2, w20, uxtw #2]
    1890: aa1603e2     	mov	x2, x22
    1894: b9001840     	str	w0, [x2, #0x18]
    1898: aa1603e0     	mov	x0, x22
    189c: b9401000     	ldr	w0, [x0, #0x10]
    18a0: b9401442     	ldr	w2, [x2, #0x14]
    18a4: 6b02001f     	cmp	w0, w2
    18a8: 54002182     	b.hs	0x1cd8 <___pl_fn_4+0xbd4>
    18ac: aa1603e0     	mov	x0, x22
    18b0: 94000000     	bl	0x18b0 <___pl_fn_4+0x7ac>
    18b4: aa1603e1     	mov	x1, x22
    18b8: b9402c21     	ldr	w1, [x1, #0x2c]
    18bc: 35002ce1     	cbnz	w1, 0x1e58 <___pl_fn_4+0xd54>
    18c0: aa1603e1     	mov	x1, x22
    18c4: b9001834     	str	w20, [x1, #0x18]
    18c8: 34001f13     	cbz	w19, 0x1ca8 <___pl_fn_4+0xba4>
    18cc: aa1603e1     	mov	x1, x22
    18d0: aa1303e2     	mov	x2, x19
    18d4: f940002a     	ldr	x10, [x1]
    18d8: 2a0203e9     	mov	w9, w2
    18dc: 8b090d49     	add	x9, x10, x9, lsl #3
    18e0: f862594a     	ldr	x10, [x10, w2, uxtw #3]
    18e4: d360fd4a     	lsr	x10, x10, #32
    18e8: 92403d4b     	and	x11, x10, #0xffff
    18ec: f100097f     	cmp	x11, #0x2
    18f0: 54000080     	b.eq	0x1900 <___pl_fn_4+0x7fc>
    18f4: f940092c     	ldr	x12, [x9, #0x10]
    18f8: 927cf98c     	and	x12, x12, #0xfffffffffffffff7
    18fc: f900092c     	str	x12, [x9, #0x10]
    1900: 92403d4e     	and	x14, x10, #0xffff
    1904: 91000dce     	add	x14, x14, #0x3
    1908: f82e7920     	str	x0, [x9, x14, lsl #3]
    190c: 52800020     	mov	w0, #0x1                ; =1
    1910: aa0003f4     	mov	x20, x0
    1914: aa1603e0     	mov	x0, x22
    1918: aa1603e0     	mov	x0, x22
    191c: b9401000     	ldr	w0, [x0, #0x10]
    1920: 51000400     	sub	w0, w0, #0x1
    1924: aa1603ed     	mov	x13, x22
    1928: b90011a0     	str	w0, [x13, #0x10]
    192c: aa1403e0     	mov	x0, x20
    1930: 910283ff     	add	sp, sp, #0xa0
    1934: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1938: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    193c: f84107f9     	ldr	x25, [sp], #0x10
    1940: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1944: d65f03c0     	ret
    1948: aa0003f6     	mov	x22, x0
    194c: 52800621     	mov	w1, #0x31               ; =49
    1950: 52800003     	mov	w3, #0x0                ; =0
    1954: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1958: f9400084     	ldr	x4, [x4]
    195c: aa1603e0     	mov	x0, x22
    1960: aa1303e2     	mov	x2, x19
    1964: d63f0080     	blr	x4
    1968: 34ffc040     	cbz	w0, 0x1170 <___pl_fn_4+0x6c>
    196c: 1400013b     	b	0x1e58 <___pl_fn_4+0xd54>
    1970: 52800641     	mov	w1, #0x32               ; =50
    1974: 52800043     	mov	w3, #0x2                ; =2
    1978: 9000000f     	adrp	x15, 0x1000 <___pl_fn_3+0x61c>
    197c: f94001ef     	ldr	x15, [x15]
    1980: aa1603e0     	mov	x0, x22
    1984: aa1303e2     	mov	x2, x19
    1988: d63f01e0     	blr	x15
    198c: 34ffc140     	cbz	w0, 0x11b4 <___pl_fn_4+0xb0>
    1990: 14000132     	b	0x1e58 <___pl_fn_4+0xd54>
    1994: d2800001     	mov	x1, #0x0                ; =0
    1998: 910003e3     	mov	x3, sp
    199c: f80003e1     	stur	x1, [sp]
    19a0: f80083e0     	stur	x0, [sp, #0x8]
    19a4: 52800681     	mov	w1, #0x34               ; =52
    19a8: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    19ac: f9400084     	ldr	x4, [x4]
    19b0: aa1603e0     	mov	x0, x22
    19b4: aa1303e2     	mov	x2, x19
    19b8: d63f0080     	blr	x4
    19bc: 34ffc260     	cbz	w0, 0x1208 <___pl_fn_4+0x104>
    19c0: 14000126     	b	0x1e58 <___pl_fn_4+0xd54>
    19c4: 528006a1     	mov	w1, #0x35               ; =53
    19c8: 52800023     	mov	w3, #0x1                ; =1
    19cc: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    19d0: f9400084     	ldr	x4, [x4]
    19d4: aa1603e0     	mov	x0, x22
    19d8: aa1303e2     	mov	x2, x19
    19dc: d63f0080     	blr	x4
    19e0: 34ffc320     	cbz	w0, 0x1244 <___pl_fn_4+0x140>
    19e4: 1400011d     	b	0x1e58 <___pl_fn_4+0xd54>
    19e8: 528006c1     	mov	w1, #0x36               ; =54
    19ec: 52800063     	mov	w3, #0x3                ; =3
    19f0: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    19f4: f9400084     	ldr	x4, [x4]
    19f8: aa1603e0     	mov	x0, x22
    19fc: aa1303e2     	mov	x2, x19
    1a00: d63f0080     	blr	x4
    1a04: 34ffc420     	cbz	w0, 0x1288 <___pl_fn_4+0x184>
    1a08: 14000114     	b	0x1e58 <___pl_fn_4+0xd54>
    1a0c: d2800021     	mov	x1, #0x1                ; =1
    1a10: 910043e3     	add	x3, sp, #0x10
    1a14: f80103e1     	stur	x1, [sp, #0x10]
    1a18: f80183e0     	stur	x0, [sp, #0x18]
    1a1c: 52800701     	mov	w1, #0x38               ; =56
    1a20: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1a24: f9400084     	ldr	x4, [x4]
    1a28: aa1603e0     	mov	x0, x22
    1a2c: aa1303e2     	mov	x2, x19
    1a30: d63f0080     	blr	x4
    1a34: 34ffc560     	cbz	w0, 0x12e0 <___pl_fn_4+0x1dc>
    1a38: 14000108     	b	0x1e58 <___pl_fn_4+0xd54>
    1a3c: 52800721     	mov	w1, #0x39               ; =57
    1a40: 52800003     	mov	w3, #0x0                ; =0
    1a44: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1a48: f9400084     	ldr	x4, [x4]
    1a4c: aa1603e0     	mov	x0, x22
    1a50: aa1303e2     	mov	x2, x19
    1a54: d63f0080     	blr	x4
    1a58: 34ffc600     	cbz	w0, 0x1318 <___pl_fn_4+0x214>
    1a5c: 140000ff     	b	0x1e58 <___pl_fn_4+0xd54>
    1a60: d2800000     	mov	x0, #0x0                ; =0
    1a64: 910083e3     	add	x3, sp, #0x20
    1a68: f80203e0     	stur	x0, [sp, #0x20]
    1a6c: d2803e80     	mov	x0, #0x1f4              ; =500
    1a70: f80283e0     	stur	x0, [sp, #0x28]
    1a74: 52800741     	mov	w1, #0x3a               ; =58
    1a78: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1a7c: f9400084     	ldr	x4, [x4]
    1a80: aa1603e0     	mov	x0, x22
    1a84: aa1303e2     	mov	x2, x19
    1a88: d63f0080     	blr	x4
    1a8c: 34ffc740     	cbz	w0, 0x1374 <___pl_fn_4+0x270>
    1a90: 140000f2     	b	0x1e58 <___pl_fn_4+0xd54>
    1a94: 52800761     	mov	w1, #0x3b               ; =59
    1a98: 52800043     	mov	w3, #0x2                ; =2
    1a9c: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1aa0: f9400084     	ldr	x4, [x4]
    1aa4: aa1603e0     	mov	x0, x22
    1aa8: aa1303e2     	mov	x2, x19
    1aac: d63f0080     	blr	x4
    1ab0: 34ffc800     	cbz	w0, 0x13b0 <___pl_fn_4+0x2ac>
    1ab4: 140000e9     	b	0x1e58 <___pl_fn_4+0xd54>
    1ab8: 9100c3e3     	add	x3, sp, #0x30
    1abc: f80303f4     	stur	x20, [sp, #0x30]
    1ac0: f80383e0     	stur	x0, [sp, #0x38]
    1ac4: 528007e1     	mov	w1, #0x3f               ; =63
    1ac8: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1acc: f9400084     	ldr	x4, [x4]
    1ad0: aa1603e0     	mov	x0, x22
    1ad4: aa1303e2     	mov	x2, x19
    1ad8: d63f0080     	blr	x4
    1adc: 34ffccc0     	cbz	w0, 0x1474 <___pl_fn_4+0x370>
    1ae0: 140000de     	b	0x1e58 <___pl_fn_4+0xd54>
    1ae4: 52800821     	mov	w1, #0x41               ; =65
    1ae8: 52800003     	mov	w3, #0x0                ; =0
    1aec: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1af0: f9400084     	ldr	x4, [x4]
    1af4: aa1603e0     	mov	x0, x22
    1af8: aa1303e2     	mov	x2, x19
    1afc: d63f0080     	blr	x4
    1b00: 34ffcda0     	cbz	w0, 0x14b4 <___pl_fn_4+0x3b0>
    1b04: 140000d5     	b	0x1e58 <___pl_fn_4+0xd54>
    1b08: 910103e3     	add	x3, sp, #0x40
    1b0c: f80403f9     	stur	x25, [sp, #0x40]
    1b10: f80483f9     	stur	x25, [sp, #0x48]
    1b14: 52800841     	mov	w1, #0x42               ; =66
    1b18: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1b1c: f9400084     	ldr	x4, [x4]
    1b20: aa1603e0     	mov	x0, x22
    1b24: aa1303e2     	mov	x2, x19
    1b28: d63f0080     	blr	x4
    1b2c: 34ffcec0     	cbz	w0, 0x1504 <___pl_fn_4+0x400>
    1b30: 140000ca     	b	0x1e58 <___pl_fn_4+0xd54>
    1b34: 52800861     	mov	w1, #0x43               ; =67
    1b38: 52800043     	mov	w3, #0x2                ; =2
    1b3c: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1b40: f9400084     	ldr	x4, [x4]
    1b44: aa1603e0     	mov	x0, x22
    1b48: aa1303e2     	mov	x2, x19
    1b4c: d63f0080     	blr	x4
    1b50: 34ffcf80     	cbz	w0, 0x1540 <___pl_fn_4+0x43c>
    1b54: 140000c1     	b	0x1e58 <___pl_fn_4+0xd54>
    1b58: 910143e3     	add	x3, sp, #0x50
    1b5c: f80503f5     	stur	x21, [sp, #0x50]
    1b60: f80583e0     	stur	x0, [sp, #0x58]
    1b64: 528008c1     	mov	w1, #0x46               ; =70
    1b68: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1b6c: f9400084     	ldr	x4, [x4]
    1b70: aa1603e0     	mov	x0, x22
    1b74: aa1303e2     	mov	x2, x19
    1b78: d63f0080     	blr	x4
    1b7c: 34ffd3a0     	cbz	w0, 0x15f0 <___pl_fn_4+0x4ec>
    1b80: 140000b6     	b	0x1e58 <___pl_fn_4+0xd54>
    1b84: 52800901     	mov	w1, #0x48               ; =72
    1b88: 52800023     	mov	w3, #0x1                ; =1
    1b8c: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1b90: f9400084     	ldr	x4, [x4]
    1b94: aa1603e0     	mov	x0, x22
    1b98: aa1303e2     	mov	x2, x19
    1b9c: d63f0080     	blr	x4
    1ba0: 34ffd4a0     	cbz	w0, 0x1634 <___pl_fn_4+0x530>
    1ba4: 140000ad     	b	0x1e58 <___pl_fn_4+0xd54>
    1ba8: d2800020     	mov	x0, #0x1                ; =1
    1bac: 910183e3     	add	x3, sp, #0x60
    1bb0: f80603e0     	stur	x0, [sp, #0x60]
    1bb4: d2803e80     	mov	x0, #0x1f4              ; =500
    1bb8: f80683e0     	stur	x0, [sp, #0x68]
    1bbc: 52800921     	mov	w1, #0x49               ; =73
    1bc0: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1bc4: f9400084     	ldr	x4, [x4]
    1bc8: aa1603e0     	mov	x0, x22
    1bcc: aa1303e2     	mov	x2, x19
    1bd0: d63f0080     	blr	x4
    1bd4: 34ffd5a0     	cbz	w0, 0x1688 <___pl_fn_4+0x584>
    1bd8: 140000a0     	b	0x1e58 <___pl_fn_4+0xd54>
    1bdc: 52800941     	mov	w1, #0x4a               ; =74
    1be0: 52800063     	mov	w3, #0x3                ; =3
    1be4: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1be8: f9400084     	ldr	x4, [x4]
    1bec: aa1603e0     	mov	x0, x22
    1bf0: aa1303e2     	mov	x2, x19
    1bf4: d63f0080     	blr	x4
    1bf8: 34ffd660     	cbz	w0, 0x16c4 <___pl_fn_4+0x5c0>
    1bfc: 14000097     	b	0x1e58 <___pl_fn_4+0xd54>
    1c00: d2800064     	mov	x4, #0x3                ; =3
    1c04: 9101c3e3     	add	x3, sp, #0x70
    1c08: f80703e4     	stur	x4, [sp, #0x70]
    1c0c: f80783e0     	stur	x0, [sp, #0x78]
    1c10: 528009c1     	mov	w1, #0x4e               ; =78
    1c14: 90000005     	adrp	x5, 0x1000 <___pl_fn_3+0x61c>
    1c18: f94000a5     	ldr	x5, [x5]
    1c1c: aa1603e0     	mov	x0, x22
    1c20: aa1303e2     	mov	x2, x19
    1c24: d63f00a0     	blr	x5
    1c28: 34ffdae0     	cbz	w0, 0x1784 <___pl_fn_4+0x680>
    1c2c: 1400008b     	b	0x1e58 <___pl_fn_4+0xd54>
    1c30: 52800a01     	mov	w1, #0x50               ; =80
    1c34: 52800023     	mov	w3, #0x1                ; =1
    1c38: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1c3c: f9400084     	ldr	x4, [x4]
    1c40: aa1603e0     	mov	x0, x22
    1c44: aa1303e2     	mov	x2, x19
    1c48: d63f0080     	blr	x4
    1c4c: 34ffdbe0     	cbz	w0, 0x17c8 <___pl_fn_4+0x6c4>
    1c50: 14000082     	b	0x1e58 <___pl_fn_4+0xd54>
    1c54: d2800020     	mov	x0, #0x1                ; =1
    1c58: 910203e3     	add	x3, sp, #0x80
    1c5c: f80803e0     	stur	x0, [sp, #0x80]
    1c60: f80883f9     	stur	x25, [sp, #0x88]
    1c64: 52800a21     	mov	w1, #0x51               ; =81
    1c68: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1c6c: f9400084     	ldr	x4, [x4]
    1c70: aa1603e0     	mov	x0, x22
    1c74: aa1303e2     	mov	x2, x19
    1c78: d63f0080     	blr	x4
    1c7c: 34ffdd20     	cbz	w0, 0x1820 <___pl_fn_4+0x71c>
    1c80: 14000076     	b	0x1e58 <___pl_fn_4+0xd54>
    1c84: 52800a41     	mov	w1, #0x52               ; =82
    1c88: 52800063     	mov	w3, #0x3                ; =3
    1c8c: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x61c>
    1c90: f9400084     	ldr	x4, [x4]
    1c94: aa1603e0     	mov	x0, x22
    1c98: aa1303e2     	mov	x2, x19
    1c9c: d63f0080     	blr	x4
    1ca0: 34ffdde0     	cbz	w0, 0x185c <___pl_fn_4+0x758>
    1ca4: 1400006d     	b	0x1e58 <___pl_fn_4+0xd54>
    1ca8: d2800064     	mov	x4, #0x3                ; =3
    1cac: 910243e3     	add	x3, sp, #0x90
    1cb0: f80903e4     	stur	x4, [sp, #0x90]
    1cb4: f80983e0     	stur	x0, [sp, #0x98]
    1cb8: 52800aa1     	mov	w1, #0x55               ; =85
    1cbc: 90000006     	adrp	x6, 0x1000 <___pl_fn_3+0x61c>
    1cc0: f94000c6     	ldr	x6, [x6]
    1cc4: aa1303e2     	mov	x2, x19
    1cc8: aa1603e0     	mov	x0, x22
    1ccc: d63f00c0     	blr	x6
    1cd0: 34ffe1e0     	cbz	w0, 0x190c <___pl_fn_4+0x808>
    1cd4: 14000061     	b	0x1e58 <___pl_fn_4+0xd54>
    1cd8: 52800a81     	mov	w1, #0x54               ; =84
    1cdc: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x61c>
    1ce0: f9400042     	ldr	x2, [x2]
    1ce4: aa1603e0     	mov	x0, x22
    1ce8: d63f0040     	blr	x2
    1cec: 52800000     	mov	w0, #0x0                ; =0
    1cf0: 910283ff     	add	sp, sp, #0xa0
    1cf4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1cf8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1cfc: f84107f9     	ldr	x25, [sp], #0x10
    1d00: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1d04: d65f03c0     	ret
    1d08: 52800a61     	mov	w1, #0x53               ; =83
    1d0c: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x61c>
    1d10: f9400042     	ldr	x2, [x2]
    1d14: aa1603e0     	mov	x0, x22
    1d18: d63f0040     	blr	x2
    1d1c: 52800000     	mov	w0, #0x0                ; =0
    1d20: 910283ff     	add	sp, sp, #0xa0
    1d24: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1d28: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1d2c: f84107f9     	ldr	x25, [sp], #0x10
    1d30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1d34: d65f03c0     	ret
    1d38: 528009a1     	mov	w1, #0x4d               ; =77
    1d3c: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x61c>
    1d40: f9400042     	ldr	x2, [x2]
    1d44: aa1603e0     	mov	x0, x22
    1d48: d63f0040     	blr	x2
    1d4c: 52800000     	mov	w0, #0x0                ; =0
    1d50: 910283ff     	add	sp, sp, #0xa0
    1d54: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1d58: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1d5c: f84107f9     	ldr	x25, [sp], #0x10
    1d60: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1d64: d65f03c0     	ret
    1d68: 52800981     	mov	w1, #0x4c               ; =76
    1d6c: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x61c>
    1d70: f9400042     	ldr	x2, [x2]
    1d74: aa1603e0     	mov	x0, x22
    1d78: d63f0040     	blr	x2
    1d7c: 52800000     	mov	w0, #0x0                ; =0
    1d80: 910283ff     	add	sp, sp, #0xa0
    1d84: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1d88: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1d8c: f84107f9     	ldr	x25, [sp], #0x10
    1d90: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1d94: d65f03c0     	ret
    1d98: 52800961     	mov	w1, #0x4b               ; =75
    1d9c: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x61c>
    1da0: f9400042     	ldr	x2, [x2]
    1da4: aa1603e0     	mov	x0, x22
    1da8: d63f0040     	blr	x2
    1dac: 52800000     	mov	w0, #0x0                ; =0
    1db0: 910283ff     	add	sp, sp, #0xa0
    1db4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1db8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1dbc: f84107f9     	ldr	x25, [sp], #0x10
    1dc0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1dc4: d65f03c0     	ret
    1dc8: 528008a1     	mov	w1, #0x45               ; =69
    1dcc: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x61c>
    1dd0: f9400042     	ldr	x2, [x2]
    1dd4: aa1603e0     	mov	x0, x22
    1dd8: d63f0040     	blr	x2
    1ddc: 52800000     	mov	w0, #0x0                ; =0
    1de0: 910283ff     	add	sp, sp, #0xa0
    1de4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1de8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1dec: f84107f9     	ldr	x25, [sp], #0x10
    1df0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1df4: d65f03c0     	ret
    1df8: 52800881     	mov	w1, #0x44               ; =68
    1dfc: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x61c>
    1e00: f9400042     	ldr	x2, [x2]
    1e04: aa1603e0     	mov	x0, x22
    1e08: d63f0040     	blr	x2
    1e0c: 52800000     	mov	w0, #0x0                ; =0
    1e10: 910283ff     	add	sp, sp, #0xa0
    1e14: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1e18: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1e1c: f84107f9     	ldr	x25, [sp], #0x10
    1e20: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1e24: d65f03c0     	ret
    1e28: 528007c1     	mov	w1, #0x3e               ; =62
    1e2c: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x61c>
    1e30: f9400042     	ldr	x2, [x2]
    1e34: aa1603e0     	mov	x0, x22
    1e38: d63f0040     	blr	x2
    1e3c: 52800000     	mov	w0, #0x0                ; =0
    1e40: 910283ff     	add	sp, sp, #0xa0
    1e44: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1e48: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1e4c: f84107f9     	ldr	x25, [sp], #0x10
    1e50: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1e54: d65f03c0     	ret
    1e58: 52800000     	mov	w0, #0x0                ; =0
    1e5c: 910283ff     	add	sp, sp, #0xa0
    1e60: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1e64: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1e68: f84107f9     	ldr	x25, [sp], #0x10
    1e6c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1e70: d65f03c0     	ret
    1e74: 528007a1     	mov	w1, #0x3d               ; =61
    1e78: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x61c>
    1e7c: f9400042     	ldr	x2, [x2]
    1e80: aa1603e0     	mov	x0, x22
    1e84: d63f0040     	blr	x2
    1e88: 52800000     	mov	w0, #0x0                ; =0
    1e8c: 910283ff     	add	sp, sp, #0xa0
    1e90: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1e94: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1e98: f84107f9     	ldr	x25, [sp], #0x10
    1e9c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1ea0: d65f03c0     	ret
    1ea4: 52800781     	mov	w1, #0x3c               ; =60
    1ea8: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x61c>
    1eac: f9400042     	ldr	x2, [x2]
    1eb0: aa1603e0     	mov	x0, x22
    1eb4: d63f0040     	blr	x2
    1eb8: 52800000     	mov	w0, #0x0                ; =0
    1ebc: 910283ff     	add	sp, sp, #0xa0
    1ec0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1ec4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1ec8: f84107f9     	ldr	x25, [sp], #0x10
    1ecc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1ed0: d65f03c0     	ret
    1ed4: 528006e1     	mov	w1, #0x37               ; =55
    1ed8: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x61c>
    1edc: f9400042     	ldr	x2, [x2]
    1ee0: aa1603e0     	mov	x0, x22
    1ee4: d63f0040     	blr	x2
    1ee8: 52800000     	mov	w0, #0x0                ; =0
    1eec: 910283ff     	add	sp, sp, #0xa0
    1ef0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1ef4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1ef8: f84107f9     	ldr	x25, [sp], #0x10
    1efc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1f00: d65f03c0     	ret
    1f04: 52800661     	mov	w1, #0x33               ; =51
    1f08: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x61c>
    1f0c: f9400042     	ldr	x2, [x2]
    1f10: aa1603e0     	mov	x0, x22
    1f14: d63f0040     	blr	x2
    1f18: 52800000     	mov	w0, #0x0                ; =0
    1f1c: 910283ff     	add	sp, sp, #0xa0
    1f20: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1f24: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1f28: f84107f9     	ldr	x25, [sp], #0x10
    1f2c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1f30: d65f03c0     	ret
