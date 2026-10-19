
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_28184/list/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: f81f0ff7     	str	x23, [sp, #-0x10]!
       c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      10: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      14: d10103ff     	sub	sp, sp, #0x40
      18: aa0103f3     	mov	x19, x1
      1c: b9401001     	ldr	w1, [x0, #0x10]
      20: 11000421     	add	w1, w1, #0x1
      24: b9001001     	str	w1, [x0, #0x10]
      28: f9403c01     	ldr	x1, [x0, #0x78]
      2c: 37301241     	tbnz	w1, #0x6, 0x274 <___pl_fn_0+0x274>
      30: f9403801     	ldr	x1, [x0, #0x70]
      34: f100003f     	cmp	x1, #0x0
      38: 5400122d     	b.le	0x27c <___pl_fn_0+0x27c>
      3c: f9403401     	ldr	x1, [x0, #0x68]
      40: f100103f     	cmp	x1, #0x4
      44: 5400120b     	b.lt	0x284 <___pl_fn_0+0x284>
      48: f9402802     	ldr	x2, [x0, #0x50]
      4c: f9402c01     	ldr	x1, [x0, #0x58]
      50: 91001843     	add	x3, x2, #0x6
      54: eb01007f     	cmp	x3, x1
      58: 540011a8     	b.hi	0x28c <___pl_fn_0+0x28c>
      5c: f9404401     	ldr	x1, [x0, #0x88]
      60: f9404803     	ldr	x3, [x0, #0x90]
      64: aa0003f6     	mov	x22, x0
      68: eb03003f     	cmp	x1, x3
      6c: 540000e3     	b.lo	0x88 <___pl_fn_0+0x88>
      70: 14000088     	b	0x290 <___pl_fn_0+0x290>
      74: aa1603e0     	mov	x0, x22
      78: f9401800     	ldr	x0, [x0, #0x30]
      7c: aa1303e1     	mov	x1, x19
      80: aa0003e2     	mov	x2, x0
      84: 1400002a     	b	0x12c <___pl_fn_0+0x12c>
      88: aa1603e0     	mov	x0, x22
      8c: f9403004     	ldr	x4, [x0, #0x60]
      90: f9400005     	ldr	x5, [x0]
      94: b20007e6     	mov	x6, #0x300000003        ; =12884901891
      98: 2a0203e0     	mov	w0, w2
      9c: 8b000ca3     	add	x3, x5, x0, lsl #3
      a0: f82258a6     	str	x6, [x5, w2, uxtw #3]
      a4: 91000484     	add	x4, x4, #0x1
      a8: f9000464     	str	x4, [x3, #0x8]
      ac: 92800005     	mov	x5, #-0x1               ; =-1
      b0: f9000865     	str	x5, [x3, #0x10]
      b4: d2800005     	mov	x5, #0x0                ; =0
      b8: f9000c65     	str	x5, [x3, #0x18]
      bc: f9001065     	str	x5, [x3, #0x20]
      c0: d2800045     	mov	x5, #0x2                ; =2
      c4: f9001465     	str	x5, [x3, #0x28]
      c8: aa1603e3     	mov	x3, x22
      cc: f9003064     	str	x4, [x3, #0x60]
      d0: 91001843     	add	x3, x2, #0x6
      d4: aa1603e4     	mov	x4, x22
      d8: f9002883     	str	x3, [x4, #0x50]
      dc: aa1603e3     	mov	x3, x22
      e0: f9403463     	ldr	x3, [x3, #0x68]
      e4: d1001063     	sub	x3, x3, #0x4
      e8: f9003483     	str	x3, [x4, #0x68]
      ec: aa1603e3     	mov	x3, x22
      f0: f9403863     	ldr	x3, [x3, #0x70]
      f4: d1001063     	sub	x3, x3, #0x4
      f8: f9003883     	str	x3, [x4, #0x70]
      fc: aa1603e3     	mov	x3, x22
     100: f9404063     	ldr	x3, [x3, #0x80]
     104: b25f0404     	orr	x4, x0, #0x600000000
     108: d2800085     	mov	x5, #0x4                ; =4
     10c: d37cec26     	lsl	x6, x1, #4
     110: 8b011067     	add	x7, x3, x1, lsl #4
     114: f8266864     	str	x4, [x3, x6]
     118: f90004e5     	str	x5, [x7, #0x8]
     11c: 91000423     	add	x3, x1, #0x1
     120: aa1603e0     	mov	x0, x22
     124: f9004403     	str	x3, [x0, #0x88]
     128: aa1303e1     	mov	x1, x19
     12c: b40007c1     	cbz	x1, 0x224 <___pl_fn_0+0x224>
     130: 34000c02     	cbz	w2, 0x2b0 <___pl_fn_0+0x2b0>
     134: aa1603e0     	mov	x0, x22
     138: f940000e     	ldr	x14, [x0]
     13c: d280000f     	mov	x15, #0x0               ; =0
     140: 2a0203f3     	mov	w19, w2
     144: 8b130dce     	add	x14, x14, x19, lsl #3
     148: f90015cf     	str	x15, [x14, #0x28]
     14c: 34000cc2     	cbz	w2, 0x2e4 <___pl_fn_0+0x2e4>
     150: f94009c0     	ldr	x0, [x14, #0x10]
     154: 927ff800     	and	x0, x0, #0xfffffffffffffffe
     158: f90009c0     	str	x0, [x14, #0x10]
     15c: f9000dc1     	str	x1, [x14, #0x18]
     160: b24107e0     	mov	x0, #-0x7fffffffffffffff ; =-9223372036854775807
     164: eb00003f     	cmp	x1, x0
     168: 54000f6b     	b.lt	0x354 <___pl_fn_0+0x354>
     16c: aa1603e0     	mov	x0, x22
     170: b9401814     	ldr	w20, [x0, #0x18]
     174: b9401c03     	ldr	w3, [x0, #0x1c]
     178: 11000680     	add	w0, w20, #0x1
     17c: 6b03001f     	cmp	w0, w3
     180: 54000e68     	b.hi	0x34c <___pl_fn_0+0x34c>
     184: aa1603e3     	mov	x3, x22
     188: f9401063     	ldr	x3, [x3, #0x20]
     18c: b8345862     	str	w2, [x3, w20, uxtw #2]
     190: aa0203f7     	mov	x23, x2
     194: aa1603e2     	mov	x2, x22
     198: b9001840     	str	w0, [x2, #0x18]
     19c: aa1603e0     	mov	x0, x22
     1a0: b9401000     	ldr	w0, [x0, #0x10]
     1a4: b9401442     	ldr	w2, [x2, #0x14]
     1a8: 6b02001f     	cmp	w0, w2
     1ac: 54000cc2     	b.hs	0x344 <___pl_fn_0+0x344>
     1b0: d2800035     	mov	x21, #0x1               ; =1
     1b4: d1000421     	sub	x1, x1, #0x1
     1b8: aa1603e0     	mov	x0, x22
     1bc: 94000000     	bl	0x1bc <___pl_fn_0+0x1bc>
     1c0: aa1603e1     	mov	x1, x22
     1c4: b9402c21     	ldr	w1, [x1, #0x2c]
     1c8: 35000ec1     	cbnz	w1, 0x3a0 <___pl_fn_0+0x3a0>
     1cc: aa1603e1     	mov	x1, x22
     1d0: b9001834     	str	w20, [x1, #0x18]
     1d4: aa1703e2     	mov	x2, x23
     1d8: 340009e2     	cbz	w2, 0x314 <___pl_fn_0+0x314>
     1dc: aa1603ee     	mov	x14, x22
     1e0: aa0203f7     	mov	x23, x2
     1e4: f94001c1     	ldr	x1, [x14]
     1e8: 2a0003e0     	mov	w0, w0
     1ec: 8b130c21     	add	x1, x1, x19, lsl #3
     1f0: f9001020     	str	x0, [x1, #0x20]
     1f4: aa1603e0     	mov	x0, x22
     1f8: b9401000     	ldr	w0, [x0, #0x10]
     1fc: 51000400     	sub	w0, w0, #0x1
     200: aa1603e1     	mov	x1, x22
     204: b9001020     	str	w0, [x1, #0x10]
     208: aa1703e0     	mov	x0, x23
     20c: 910103ff     	add	sp, sp, #0x40
     210: a8c153f3     	ldp	x19, x20, [sp], #0x10
     214: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     218: f84107f7     	ldr	x23, [sp], #0x10
     21c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     220: d65f03c0     	ret
     224: aa0203f7     	mov	x23, x2
     228: 340009a2     	cbz	w2, 0x35c <___pl_fn_0+0x35c>
     22c: aa1603e0     	mov	x0, x22
     230: f9400000     	ldr	x0, [x0]
     234: d2800021     	mov	x1, #0x1                ; =1
     238: aa1703e2     	mov	x2, x23
     23c: 2a0203e2     	mov	w2, w2
     240: 8b020c00     	add	x0, x0, x2, lsl #3
     244: f9001401     	str	x1, [x0, #0x28]
     248: aa1603e0     	mov	x0, x22
     24c: b9401001     	ldr	w1, [x0, #0x10]
     250: 51000421     	sub	w1, w1, #0x1
     254: b9001001     	str	w1, [x0, #0x10]
     258: aa1703e0     	mov	x0, x23
     25c: 910103ff     	add	sp, sp, #0x40
     260: a8c153f3     	ldp	x19, x20, [sp], #0x10
     264: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     268: f84107f7     	ldr	x23, [sp], #0x10
     26c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     270: d65f03c0     	ret
     274: aa0003f6     	mov	x22, x0
     278: 14000006     	b	0x290 <___pl_fn_0+0x290>
     27c: aa0003f6     	mov	x22, x0
     280: 14000004     	b	0x290 <___pl_fn_0+0x290>
     284: aa0003f6     	mov	x22, x0
     288: 14000002     	b	0x290 <___pl_fn_0+0x290>
     28c: aa0003f6     	mov	x22, x0
     290: 52800002     	mov	w2, #0x0                ; =0
     294: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     298: f9400063     	ldr	x3, [x3]
     29c: aa1603e0     	mov	x0, x22
     2a0: aa0203e1     	mov	x1, x2
     2a4: d63f0060     	blr	x3
     2a8: 34ffee60     	cbz	w0, 0x74 <___pl_fn_0+0x74>
     2ac: 1400003d     	b	0x3a0 <___pl_fn_0+0x3a0>
     2b0: d2800048     	mov	x8, #0x2                ; =2
     2b4: 910003e3     	mov	x3, sp
     2b8: f80003e8     	stur	x8, [sp]
     2bc: d2800009     	mov	x9, #0x0                ; =0
     2c0: f80083e9     	stur	x9, [sp, #0x8]
     2c4: 52800021     	mov	w1, #0x1                ; =1
     2c8: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     2cc: f940014a     	ldr	x10, [x10]
     2d0: aa1603e0     	mov	x0, x22
     2d4: d63f0140     	blr	x10
     2d8: 35000640     	cbnz	w0, 0x3a0 <___pl_fn_0+0x3a0>
     2dc: 52800041     	mov	w1, #0x2                ; =2
     2e0: 1400002c     	b	0x390 <___pl_fn_0+0x390>
     2e4: d2800000     	mov	x0, #0x0                ; =0
     2e8: 910043e3     	add	x3, sp, #0x10
     2ec: f80103e0     	stur	x0, [sp, #0x10]
     2f0: f80183e1     	stur	x1, [sp, #0x18]
     2f4: 52800061     	mov	w1, #0x3                ; =3
     2f8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     2fc: f9400084     	ldr	x4, [x4]
     300: aa1603e0     	mov	x0, x22
     304: d63f0080     	blr	x4
     308: 350004c0     	cbnz	w0, 0x3a0 <___pl_fn_0+0x3a0>
     30c: 52800081     	mov	w1, #0x4                ; =4
     310: 14000020     	b	0x390 <___pl_fn_0+0x390>
     314: 910083e3     	add	x3, sp, #0x20
     318: f80203f5     	stur	x21, [sp, #0x20]
     31c: 2a0003e0     	mov	w0, w0
     320: f80283e0     	stur	x0, [sp, #0x28]
     324: 52800101     	mov	w1, #0x8                ; =8
     328: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     32c: f9400084     	ldr	x4, [x4]
     330: aa1603e0     	mov	x0, x22
     334: d63f0080     	blr	x4
     338: 35000340     	cbnz	w0, 0x3a0 <___pl_fn_0+0x3a0>
     33c: 52800121     	mov	w1, #0x9                ; =9
     340: 14000014     	b	0x390 <___pl_fn_0+0x390>
     344: 528000e1     	mov	w1, #0x7                ; =7
     348: 14000012     	b	0x390 <___pl_fn_0+0x390>
     34c: 528000c1     	mov	w1, #0x6                ; =6
     350: 14000010     	b	0x390 <___pl_fn_0+0x390>
     354: 528000a1     	mov	w1, #0x5                ; =5
     358: 1400000e     	b	0x390 <___pl_fn_0+0x390>
     35c: d2800040     	mov	x0, #0x2                ; =2
     360: 9100c3e3     	add	x3, sp, #0x30
     364: f80303e0     	stur	x0, [sp, #0x30]
     368: d2800020     	mov	x0, #0x1                ; =1
     36c: f80383e0     	stur	x0, [sp, #0x38]
     370: 52800141     	mov	w1, #0xa                ; =10
     374: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     378: f9400084     	ldr	x4, [x4]
     37c: aa1703e2     	mov	x2, x23
     380: aa1603e0     	mov	x0, x22
     384: d63f0080     	blr	x4
     388: 350000c0     	cbnz	w0, 0x3a0 <___pl_fn_0+0x3a0>
     38c: 52800161     	mov	w1, #0xb                ; =11
     390: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     394: f9400042     	ldr	x2, [x2]
     398: aa1603e0     	mov	x0, x22
     39c: d63f0040     	blr	x2
     3a0: 52800000     	mov	w0, #0x0                ; =0
     3a4: 910103ff     	add	sp, sp, #0x40
     3a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     3ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     3b0: f84107f7     	ldr	x23, [sp], #0x10
     3b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     3b8: d65f03c0     	ret

00000000000003bc <___pl_fn_1>:
     3bc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     3c0: 910003fd     	mov	x29, sp
     3c4: f81f0ff3     	str	x19, [sp, #-0x10]!
     3c8: b9401005     	ldr	w5, [x0, #0x10]
     3cc: 110004a3     	add	w3, w5, #0x1
     3d0: b9001003     	str	w3, [x0, #0x10]
     3d4: aa0003f3     	mov	x19, x0
     3d8: 34000c21     	cbz	w1, 0x55c <___pl_fn_1+0x1a0>
     3dc: 34000bc2     	cbz	w2, 0x554 <___pl_fn_1+0x198>
     3e0: aa0203ea     	mov	x10, x2
     3e4: aa0a03e0     	mov	x0, x10
     3e8: aa0103e2     	mov	x2, x1
     3ec: 340005e0     	cbz	w0, 0x4a8 <___pl_fn_1+0xec>
     3f0: aa0003ea     	mov	x10, x0
     3f4: aa1303e0     	mov	x0, x19
     3f8: f9400003     	ldr	x3, [x0]
     3fc: aa0a03e6     	mov	x6, x10
     400: 2a0603e0     	mov	w0, w6
     404: 8b000c61     	add	x1, x3, x0, lsl #3
     408: 3940a024     	ldrb	w4, [x1, #0x28]
     40c: 53001c80     	uxtb	w0, w4
     410: 7100081f     	cmp	w0, #0x2
     414: 540004c0     	b.eq	0x4ac <___pl_fn_1+0xf0>
     418: 52000084     	eor	w4, w4, #0x1
     41c: 72001c9f     	tst	w4, #0xff
     420: 540000e1     	b.ne	0x43c <___pl_fn_1+0x80>
     424: aa1303e0     	mov	x0, x19
     428: b9001005     	str	w5, [x0, #0x10]
     42c: 52800000     	mov	w0, #0x0                ; =0
     430: f84107f3     	ldr	x19, [sp], #0x10
     434: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     438: d65f03c0     	ret
     43c: 340004c2     	cbz	w2, 0x4d4 <___pl_fn_1+0x118>
     440: 2a0203e7     	mov	w7, w2
     444: 8b070c67     	add	x7, x3, x7, lsl #3
     448: 3940a0e8     	ldrb	w8, [x7, #0x28]
     44c: 53001d09     	uxtb	w9, w8
     450: 7100093f     	cmp	w9, #0x2
     454: 54000400     	b.eq	0x4d4 <___pl_fn_1+0x118>
     458: 72001d1f     	tst	w8, #0xff
     45c: 540001a1     	b.ne	0x490 <___pl_fn_1+0xd4>
     460: 340004c2     	cbz	w2, 0x4f8 <___pl_fn_1+0x13c>
     464: b94020e3     	ldr	w3, [x7, #0x20]
     468: 34000483     	cbz	w3, 0x4f8 <___pl_fn_1+0x13c>
     46c: 34000703     	cbz	w3, 0x54c <___pl_fn_1+0x190>
     470: aa0a03e2     	mov	x2, x10
     474: 34000542     	cbz	w2, 0x51c <___pl_fn_1+0x160>
     478: b9402021     	ldr	w1, [x1, #0x20]
     47c: 34000501     	cbz	w1, 0x51c <___pl_fn_1+0x160>
     480: 34000621     	cbz	w1, 0x544 <___pl_fn_1+0x188>
     484: aa0103e0     	mov	x0, x1
     488: aa0303e2     	mov	x2, x3
     48c: 17ffffd8     	b	0x3ec <___pl_fn_1+0x30>
     490: aa1303e0     	mov	x0, x19
     494: b9001005     	str	w5, [x0, #0x10]
     498: 52800020     	mov	w0, #0x1                ; =1
     49c: f84107f3     	ldr	x19, [sp], #0x10
     4a0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     4a4: d65f03c0     	ret
     4a8: aa0003ea     	mov	x10, x0
     4ac: 528001c1     	mov	w1, #0xe                ; =14
     4b0: 52800043     	mov	w3, #0x2                ; =2
     4b4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     4b8: f9400084     	ldr	x4, [x4]
     4bc: aa0a03e2     	mov	x2, x10
     4c0: aa1303e0     	mov	x0, x19
     4c4: d63f0080     	blr	x4
     4c8: 35000540     	cbnz	w0, 0x570 <___pl_fn_1+0x1b4>
     4cc: 528001e1     	mov	w1, #0xf                ; =15
     4d0: 14000024     	b	0x560 <___pl_fn_1+0x1a4>
     4d4: 52800201     	mov	w1, #0x10               ; =16
     4d8: 52800043     	mov	w3, #0x2                ; =2
     4dc: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     4e0: f940014a     	ldr	x10, [x10]
     4e4: aa1303e0     	mov	x0, x19
     4e8: d63f0140     	blr	x10
     4ec: 35000420     	cbnz	w0, 0x570 <___pl_fn_1+0x1b4>
     4f0: 52800221     	mov	w1, #0x11               ; =17
     4f4: 1400001b     	b	0x560 <___pl_fn_1+0x1a4>
     4f8: 52800241     	mov	w1, #0x12               ; =18
     4fc: 52800023     	mov	w3, #0x1                ; =1
     500: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     504: f9400084     	ldr	x4, [x4]
     508: aa1303e0     	mov	x0, x19
     50c: d63f0080     	blr	x4
     510: 35000300     	cbnz	w0, 0x570 <___pl_fn_1+0x1b4>
     514: 52800261     	mov	w1, #0x13               ; =19
     518: 14000012     	b	0x560 <___pl_fn_1+0x1a4>
     51c: 528002a1     	mov	w1, #0x15               ; =21
     520: 52800023     	mov	w3, #0x1                ; =1
     524: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     528: f9400084     	ldr	x4, [x4]
     52c: aa0a03e2     	mov	x2, x10
     530: aa1303e0     	mov	x0, x19
     534: d63f0080     	blr	x4
     538: 350001c0     	cbnz	w0, 0x570 <___pl_fn_1+0x1b4>
     53c: 528002c1     	mov	w1, #0x16               ; =22
     540: 14000008     	b	0x560 <___pl_fn_1+0x1a4>
     544: 528002e1     	mov	w1, #0x17               ; =23
     548: 14000006     	b	0x560 <___pl_fn_1+0x1a4>
     54c: 52800281     	mov	w1, #0x14               ; =20
     550: 14000004     	b	0x560 <___pl_fn_1+0x1a4>
     554: 528001a1     	mov	w1, #0xd                ; =13
     558: 14000002     	b	0x560 <___pl_fn_1+0x1a4>
     55c: 52800181     	mov	w1, #0xc                ; =12
     560: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     564: f9400042     	ldr	x2, [x2]
     568: aa1303e0     	mov	x0, x19
     56c: d63f0040     	blr	x2
     570: 52800000     	mov	w0, #0x0                ; =0
     574: f84107f3     	ldr	x19, [sp], #0x10
     578: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     57c: d65f03c0     	ret

0000000000000580 <___pl_fn_2>:
     580: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     584: 910003fd     	mov	x29, sp
     588: a9bf73f9     	stp	x25, x28, [sp, #-0x10]!
     58c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     590: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     594: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     598: aa0303f5     	mov	x21, x3
     59c: aa0203f6     	mov	x22, x2
     5a0: aa0103f7     	mov	x23, x1
     5a4: b9401001     	ldr	w1, [x0, #0x10]
     5a8: 11000422     	add	w2, w1, #0x1
     5ac: b9001002     	str	w2, [x0, #0x10]
     5b0: b9401402     	ldr	w2, [x0, #0x14]
     5b4: aa0003fc     	mov	x28, x0
     5b8: 11000420     	add	w0, w1, #0x1
     5bc: 6b02001f     	cmp	w0, w2
     5c0: 54001b82     	b.hs	0x930 <___pl_fn_2+0x3b0>
     5c4: aa1c03e0     	mov	x0, x28
     5c8: aa1603e1     	mov	x1, x22
     5cc: aa1703e2     	mov	x2, x23
     5d0: 94000000     	bl	0x5d0 <___pl_fn_2+0x50>
     5d4: aa1c03e1     	mov	x1, x28
     5d8: b9402c21     	ldr	w1, [x1, #0x2c]
     5dc: 35001b41     	cbnz	w1, 0x944 <___pl_fn_2+0x3c4>
     5e0: 72001c1f     	tst	w0, #0xff
     5e4: 540001a1     	b.ne	0x618 <___pl_fn_2+0x98>
     5e8: aa1c03e0     	mov	x0, x28
     5ec: b9401000     	ldr	w0, [x0, #0x10]
     5f0: 51000400     	sub	w0, w0, #0x1
     5f4: aa1c03e1     	mov	x1, x28
     5f8: b9001020     	str	w0, [x1, #0x10]
     5fc: aa1503e0     	mov	x0, x21
     600: a8c153f3     	ldp	x19, x20, [sp], #0x10
     604: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     608: a8c163f7     	ldp	x23, x24, [sp], #0x10
     60c: a8c173f9     	ldp	x25, x28, [sp], #0x10
     610: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     614: d65f03c0     	ret
     618: aa1703e1     	mov	x1, x23
     61c: 340012e1     	cbz	w1, 0x878 <___pl_fn_2+0x2f8>
     620: aa1c03e0     	mov	x0, x28
     624: f9400000     	ldr	x0, [x0]
     628: aa1703e1     	mov	x1, x23
     62c: 2a0103e1     	mov	w1, w1
     630: 8b010c00     	add	x0, x0, x1, lsl #3
     634: b9402001     	ldr	w1, [x0, #0x20]
     638: 34001201     	cbz	w1, 0x878 <___pl_fn_2+0x2f8>
     63c: aa1c03e0     	mov	x0, x28
     640: b9401813     	ldr	w19, [x0, #0x18]
     644: b9401c02     	ldr	w2, [x0, #0x1c]
     648: 11000660     	add	w0, w19, #0x1
     64c: 6b02001f     	cmp	w0, w2
     650: 540016c8     	b.hi	0x928 <___pl_fn_2+0x3a8>
     654: aa1c03e2     	mov	x2, x28
     658: f9401042     	ldr	x2, [x2, #0x20]
     65c: 2a1303f4     	mov	w20, w19
     660: b8335841     	str	w1, [x2, w19, uxtw #2]
     664: aa1c03e2     	mov	x2, x28
     668: b9001840     	str	w0, [x2, #0x18]
     66c: aa1c03e0     	mov	x0, x28
     670: b9401000     	ldr	w0, [x0, #0x10]
     674: b9401442     	ldr	w2, [x2, #0x14]
     678: 6b02001f     	cmp	w0, w2
     67c: 54001522     	b.hs	0x920 <___pl_fn_2+0x3a0>
     680: aa1c03e0     	mov	x0, x28
     684: aa1603e2     	mov	x2, x22
     688: aa1503e3     	mov	x3, x21
     68c: 94000000     	bl	0x68c <___pl_fn_2+0x10c>
     690: aa1c03e1     	mov	x1, x28
     694: b9402c21     	ldr	w1, [x1, #0x2c]
     698: 35001561     	cbnz	w1, 0x944 <___pl_fn_2+0x3c4>
     69c: aa1c03e1     	mov	x1, x28
     6a0: b9001833     	str	w19, [x1, #0x18]
     6a4: aa1603e2     	mov	x2, x22
     6a8: 34000fc2     	cbz	w2, 0x8a0 <___pl_fn_2+0x320>
     6ac: aa1c03e1     	mov	x1, x28
     6b0: f9400021     	ldr	x1, [x1]
     6b4: aa1603e2     	mov	x2, x22
     6b8: 2a0203e2     	mov	w2, w2
     6bc: 8b020c21     	add	x1, x1, x2, lsl #3
     6c0: b9402021     	ldr	w1, [x1, #0x20]
     6c4: 34000ee1     	cbz	w1, 0x8a0 <___pl_fn_2+0x320>
     6c8: aa1c03e2     	mov	x2, x28
     6cc: b9401c42     	ldr	w2, [x2, #0x1c]
     6d0: 11000a63     	add	w3, w19, #0x2
     6d4: 6b02007f     	cmp	w3, w2
     6d8: 54001208     	b.hi	0x918 <___pl_fn_2+0x398>
     6dc: aa1c03e2     	mov	x2, x28
     6e0: f9401044     	ldr	x4, [x2, #0x20]
     6e4: 8b140885     	add	x5, x4, x20, lsl #2
     6e8: b8335880     	str	w0, [x4, w19, uxtw #2]
     6ec: aa0003f8     	mov	x24, x0
     6f0: b90004a1     	str	w1, [x5, #0x4]
     6f4: 11000a66     	add	w6, w19, #0x2
     6f8: aa1c03e0     	mov	x0, x28
     6fc: b9001806     	str	w6, [x0, #0x18]
     700: b9401007     	ldr	w7, [x0, #0x10]
     704: b9401408     	ldr	w8, [x0, #0x14]
     708: 6b0800ff     	cmp	w7, w8
     70c: 54001022     	b.hs	0x910 <___pl_fn_2+0x390>
     710: aa1c03e0     	mov	x0, x28
     714: aa1503e2     	mov	x2, x21
     718: aa1703e3     	mov	x3, x23
     71c: 94000000     	bl	0x71c <___pl_fn_2+0x19c>
     720: aa1c03eb     	mov	x11, x28
     724: b9402d69     	ldr	w9, [x11, #0x2c]
     728: 350010e9     	cbnz	w9, 0x944 <___pl_fn_2+0x3c4>
     72c: aa1c03ef     	mov	x15, x28
     730: b90019f3     	str	w19, [x15, #0x18]
     734: aa1503e1     	mov	x1, x21
     738: 34000c81     	cbz	w1, 0x8c8 <___pl_fn_2+0x348>
     73c: aa1c03e1     	mov	x1, x28
     740: f940002e     	ldr	x14, [x1]
     744: aa1503e1     	mov	x1, x21
     748: 2a0103ef     	mov	w15, w1
     74c: 8b0f0dce     	add	x14, x14, x15, lsl #3
     750: b94021c1     	ldr	w1, [x14, #0x20]
     754: 34000ba1     	cbz	w1, 0x8c8 <___pl_fn_2+0x348>
     758: aa1c03e2     	mov	x2, x28
     75c: b9401c42     	ldr	w2, [x2, #0x1c]
     760: 11000e63     	add	w3, w19, #0x3
     764: 6b02007f     	cmp	w3, w2
     768: 54000d08     	b.hi	0x908 <___pl_fn_2+0x388>
     76c: aa1c03e2     	mov	x2, x28
     770: f9401043     	ldr	x3, [x2, #0x20]
     774: 8b140862     	add	x2, x3, x20, lsl #2
     778: aa1803f5     	mov	x21, x24
     77c: b8335875     	str	w21, [x3, w19, uxtw #2]
     780: b9000440     	str	w0, [x2, #0x4]
     784: aa0003f9     	mov	x25, x0
     788: b9000841     	str	w1, [x2, #0x8]
     78c: 11000e60     	add	w0, w19, #0x3
     790: aa1c03e2     	mov	x2, x28
     794: b9001840     	str	w0, [x2, #0x18]
     798: aa1c03e0     	mov	x0, x28
     79c: b9401000     	ldr	w0, [x0, #0x10]
     7a0: b9401442     	ldr	w2, [x2, #0x14]
     7a4: 6b02001f     	cmp	w0, w2
     7a8: 54000ac2     	b.hs	0x900 <___pl_fn_2+0x380>
     7ac: aa1703e2     	mov	x2, x23
     7b0: aa1603e3     	mov	x3, x22
     7b4: aa1c03e0     	mov	x0, x28
     7b8: 94000000     	bl	0x7b8 <___pl_fn_2+0x238>
     7bc: aa1c03e1     	mov	x1, x28
     7c0: b9402c21     	ldr	w1, [x1, #0x2c]
     7c4: 35000c01     	cbnz	w1, 0x944 <___pl_fn_2+0x3c4>
     7c8: aa1c03e1     	mov	x1, x28
     7cc: b9001833     	str	w19, [x1, #0x18]
     7d0: b9401c21     	ldr	w1, [x1, #0x1c]
     7d4: 11000e62     	add	w2, w19, #0x3
     7d8: 6b01005f     	cmp	w2, w1
     7dc: 540008e8     	b.hi	0x8f8 <___pl_fn_2+0x378>
     7e0: aa1c03e5     	mov	x5, x28
     7e4: f94010a2     	ldr	x2, [x5, #0x20]
     7e8: 8b140841     	add	x1, x2, x20, lsl #2
     7ec: b8335855     	str	w21, [x2, w19, uxtw #2]
     7f0: aa1903e2     	mov	x2, x25
     7f4: aa1503f8     	mov	x24, x21
     7f8: b9000422     	str	w2, [x1, #0x4]
     7fc: b9000820     	str	w0, [x1, #0x8]
     800: aa0003e3     	mov	x3, x0
     804: 11000e60     	add	w0, w19, #0x3
     808: aa1c03ec     	mov	x12, x28
     80c: b9001980     	str	w0, [x12, #0x18]
     810: aa1c03e0     	mov	x0, x28
     814: b9401000     	ldr	w0, [x0, #0x10]
     818: aa1c03e1     	mov	x1, x28
     81c: b9401421     	ldr	w1, [x1, #0x14]
     820: 6b01001f     	cmp	w0, w1
     824: 54000662     	b.hs	0x8f0 <___pl_fn_2+0x370>
     828: aa1803e1     	mov	x1, x24
     82c: aa1903e2     	mov	x2, x25
     830: aa1c03e0     	mov	x0, x28
     834: 94000000     	bl	0x834 <___pl_fn_2+0x2b4>
     838: aa1c03e1     	mov	x1, x28
     83c: b9402c21     	ldr	w1, [x1, #0x2c]
     840: 35000821     	cbnz	w1, 0x944 <___pl_fn_2+0x3c4>
     844: aa1c03e1     	mov	x1, x28
     848: b9001833     	str	w19, [x1, #0x18]
     84c: b9401021     	ldr	w1, [x1, #0x10]
     850: 51000421     	sub	w1, w1, #0x1
     854: aa1c03e2     	mov	x2, x28
     858: b9001041     	str	w1, [x2, #0x10]
     85c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     860: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     864: a8c163f7     	ldp	x23, x24, [sp], #0x10
     868: a8c173f9     	ldp	x25, x28, [sp], #0x10
     86c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     870: d65f03c0     	ret
     874: 14000034     	b	0x944 <___pl_fn_2+0x3c4>
     878: 52800321     	mov	w1, #0x19               ; =25
     87c: 52800023     	mov	w3, #0x1                ; =1
     880: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     884: f9400084     	ldr	x4, [x4]
     888: aa1703e2     	mov	x2, x23
     88c: aa1c03e0     	mov	x0, x28
     890: d63f0080     	blr	x4
     894: 35000580     	cbnz	w0, 0x944 <___pl_fn_2+0x3c4>
     898: 52800341     	mov	w1, #0x1a               ; =26
     89c: 14000026     	b	0x934 <___pl_fn_2+0x3b4>
     8a0: 528003a1     	mov	w1, #0x1d               ; =29
     8a4: 52800023     	mov	w3, #0x1                ; =1
     8a8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     8ac: f9400084     	ldr	x4, [x4]
     8b0: aa1603e2     	mov	x2, x22
     8b4: aa1c03e0     	mov	x0, x28
     8b8: d63f0080     	blr	x4
     8bc: 35000440     	cbnz	w0, 0x944 <___pl_fn_2+0x3c4>
     8c0: 528003c1     	mov	w1, #0x1e               ; =30
     8c4: 1400001c     	b	0x934 <___pl_fn_2+0x3b4>
     8c8: 52800421     	mov	w1, #0x21               ; =33
     8cc: 52800023     	mov	w3, #0x1                ; =1
     8d0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     8d4: f9400084     	ldr	x4, [x4]
     8d8: aa1503e2     	mov	x2, x21
     8dc: aa1c03e0     	mov	x0, x28
     8e0: d63f0080     	blr	x4
     8e4: 35000300     	cbnz	w0, 0x944 <___pl_fn_2+0x3c4>
     8e8: 52800441     	mov	w1, #0x22               ; =34
     8ec: 14000012     	b	0x934 <___pl_fn_2+0x3b4>
     8f0: 528004c1     	mov	w1, #0x26               ; =38
     8f4: 14000010     	b	0x934 <___pl_fn_2+0x3b4>
     8f8: 528004a1     	mov	w1, #0x25               ; =37
     8fc: 1400000e     	b	0x934 <___pl_fn_2+0x3b4>
     900: 52800481     	mov	w1, #0x24               ; =36
     904: 1400000c     	b	0x934 <___pl_fn_2+0x3b4>
     908: 52800461     	mov	w1, #0x23               ; =35
     90c: 1400000a     	b	0x934 <___pl_fn_2+0x3b4>
     910: 52800401     	mov	w1, #0x20               ; =32
     914: 14000008     	b	0x934 <___pl_fn_2+0x3b4>
     918: 528003e1     	mov	w1, #0x1f               ; =31
     91c: 14000006     	b	0x934 <___pl_fn_2+0x3b4>
     920: 52800381     	mov	w1, #0x1c               ; =28
     924: 14000004     	b	0x934 <___pl_fn_2+0x3b4>
     928: 52800361     	mov	w1, #0x1b               ; =27
     92c: 14000002     	b	0x934 <___pl_fn_2+0x3b4>
     930: 52800301     	mov	w1, #0x18               ; =24
     934: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     938: f9400042     	ldr	x2, [x2]
     93c: aa1c03e0     	mov	x0, x28
     940: d63f0040     	blr	x2
     944: 52800000     	mov	w0, #0x0                ; =0
     948: a8c153f3     	ldp	x19, x20, [sp], #0x10
     94c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     950: a8c163f7     	ldp	x23, x24, [sp], #0x10
     954: a8c173f9     	ldp	x25, x28, [sp], #0x10
     958: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     95c: d65f03c0     	ret

0000000000000960 <___pl_fn_3>:
     960: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     964: 910003fd     	mov	x29, sp
     968: f81f0ff9     	str	x25, [sp, #-0x10]!
     96c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     970: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     974: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     978: b9401008     	ldr	w8, [x0, #0x10]
     97c: 11000508     	add	w8, w8, #0x1
     980: b9001008     	str	w8, [x0, #0x10]
     984: aa0003f8     	mov	x24, x0
     988: 528004e1     	mov	w1, #0x27               ; =39
     98c: 52800002     	mov	w2, #0x0                ; =0
     990: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     994: f940014a     	ldr	x10, [x10]
     998: aa1803e0     	mov	x0, x24
     99c: d63f0140     	blr	x10
     9a0: 35001520     	cbnz	w0, 0xc44 <___pl_fn_3+0x2e4>
     9a4: aa1803e0     	mov	x0, x24
     9a8: f9401815     	ldr	x21, [x0, #0x30]
     9ac: b940100c     	ldr	w12, [x0, #0x10]
     9b0: b940140d     	ldr	w13, [x0, #0x14]
     9b4: 6b0d019f     	cmp	w12, w13
     9b8: 540013c2     	b.hs	0xc30 <___pl_fn_3+0x2d0>
     9bc: aa1803e0     	mov	x0, x24
     9c0: aa1503e1     	mov	x1, x21
     9c4: 94000000     	bl	0x9c4 <___pl_fn_3+0x64>
     9c8: aa1803e1     	mov	x1, x24
     9cc: b9402c2e     	ldr	w14, [x1, #0x2c]
     9d0: 350013ae     	cbnz	w14, 0xc44 <___pl_fn_3+0x2e4>
     9d4: d28000a1     	mov	x1, #0x5                ; =5
     9d8: f2f00001     	movk	x1, #0x8000, lsl #48
     9dc: eb0102bf     	cmp	x21, x1
     9e0: 5400124b     	b.lt	0xc28 <___pl_fn_3+0x2c8>
     9e4: aa1803e1     	mov	x1, x24
     9e8: b9401833     	ldr	w19, [x1, #0x18]
     9ec: b9401c21     	ldr	w1, [x1, #0x1c]
     9f0: 11000674     	add	w20, w19, #0x1
     9f4: 6b01029f     	cmp	w20, w1
     9f8: 54001148     	b.hi	0xc20 <___pl_fn_3+0x2c0>
     9fc: aa1803e1     	mov	x1, x24
     a00: f9401021     	ldr	x1, [x1, #0x20]
     a04: 2a1303f6     	mov	w22, w19
     a08: b8335820     	str	w0, [x1, w19, uxtw #2]
     a0c: aa0003f7     	mov	x23, x0
     a10: aa1803e0     	mov	x0, x24
     a14: b9001814     	str	w20, [x0, #0x18]
     a18: b9401000     	ldr	w0, [x0, #0x10]
     a1c: aa1803e1     	mov	x1, x24
     a20: b9401421     	ldr	w1, [x1, #0x14]
     a24: 6b01001f     	cmp	w0, w1
     a28: 54000f82     	b.hs	0xc18 <___pl_fn_3+0x2b8>
     a2c: d10016a1     	sub	x1, x21, #0x5
     a30: aa1803e0     	mov	x0, x24
     a34: 94000000     	bl	0xa34 <___pl_fn_3+0xd4>
     a38: aa1803e1     	mov	x1, x24
     a3c: b9402c21     	ldr	w1, [x1, #0x2c]
     a40: 35001021     	cbnz	w1, 0xc44 <___pl_fn_3+0x2e4>
     a44: aa1803e1     	mov	x1, x24
     a48: b9001833     	str	w19, [x1, #0x18]
     a4c: d2800121     	mov	x1, #0x9                ; =9
     a50: f2f00001     	movk	x1, #0x8000, lsl #48
     a54: eb0102bf     	cmp	x21, x1
     a58: 54000dcb     	b.lt	0xc10 <___pl_fn_3+0x2b0>
     a5c: aa1803e7     	mov	x7, x24
     a60: b9401ce1     	ldr	w1, [x7, #0x1c]
     a64: 11000a62     	add	w2, w19, #0x2
     a68: 6b01005f     	cmp	w2, w1
     a6c: 54000ce8     	b.hi	0xc08 <___pl_fn_3+0x2a8>
     a70: aa1803ec     	mov	x12, x24
     a74: f9401181     	ldr	x1, [x12, #0x20]
     a78: 8b160822     	add	x2, x1, x22, lsl #2
     a7c: b8335837     	str	w23, [x1, w19, uxtw #2]
     a80: b9000440     	str	w0, [x2, #0x4]
     a84: aa0003f9     	mov	x25, x0
     a88: 11000a60     	add	w0, w19, #0x2
     a8c: aa1803e1     	mov	x1, x24
     a90: b9001820     	str	w0, [x1, #0x18]
     a94: aa1803e0     	mov	x0, x24
     a98: b9401000     	ldr	w0, [x0, #0x10]
     a9c: b9401421     	ldr	w1, [x1, #0x14]
     aa0: 6b01001f     	cmp	w0, w1
     aa4: 54000ae2     	b.hs	0xc00 <___pl_fn_3+0x2a0>
     aa8: d10026a1     	sub	x1, x21, #0x9
     aac: aa1803e0     	mov	x0, x24
     ab0: 94000000     	bl	0xab0 <___pl_fn_3+0x150>
     ab4: aa1803e1     	mov	x1, x24
     ab8: b9402c21     	ldr	w1, [x1, #0x2c]
     abc: 35000c41     	cbnz	w1, 0xc44 <___pl_fn_3+0x2e4>
     ac0: aa1803e1     	mov	x1, x24
     ac4: b9001833     	str	w19, [x1, #0x18]
     ac8: b9401c21     	ldr	w1, [x1, #0x1c]
     acc: 11000e62     	add	w2, w19, #0x3
     ad0: 6b01005f     	cmp	w2, w1
     ad4: 54000928     	b.hi	0xbf8 <___pl_fn_3+0x298>
     ad8: aa1803e1     	mov	x1, x24
     adc: f9401022     	ldr	x2, [x1, #0x20]
     ae0: 8b160841     	add	x1, x2, x22, lsl #2
     ae4: b8335857     	str	w23, [x2, w19, uxtw #2]
     ae8: aa1903e2     	mov	x2, x25
     aec: b9000422     	str	w2, [x1, #0x4]
     af0: b9000820     	str	w0, [x1, #0x8]
     af4: aa0003e3     	mov	x3, x0
     af8: 11000e60     	add	w0, w19, #0x3
     afc: aa1803e1     	mov	x1, x24
     b00: b9001820     	str	w0, [x1, #0x18]
     b04: aa1803e0     	mov	x0, x24
     b08: b9401000     	ldr	w0, [x0, #0x10]
     b0c: b9401421     	ldr	w1, [x1, #0x14]
     b10: 6b01001f     	cmp	w0, w1
     b14: 540006e2     	b.hs	0xbf0 <___pl_fn_3+0x290>
     b18: aa1703e1     	mov	x1, x23
     b1c: aa1903e2     	mov	x2, x25
     b20: aa1803e0     	mov	x0, x24
     b24: 94000000     	bl	0xb24 <___pl_fn_3+0x1c4>
     b28: aa1803e1     	mov	x1, x24
     b2c: b9402c21     	ldr	w1, [x1, #0x2c]
     b30: 350008a1     	cbnz	w1, 0xc44 <___pl_fn_3+0x2e4>
     b34: aa1803e1     	mov	x1, x24
     b38: b9001833     	str	w19, [x1, #0x18]
     b3c: b9401c21     	ldr	w1, [x1, #0x1c]
     b40: 6b01029f     	cmp	w20, w1
     b44: 54000528     	b.hi	0xbe8 <___pl_fn_3+0x288>
     b48: aa1803e2     	mov	x2, x24
     b4c: f9401041     	ldr	x1, [x2, #0x20]
     b50: b8335820     	str	w0, [x1, w19, uxtw #2]
     b54: aa0003e2     	mov	x2, x0
     b58: aa1803e0     	mov	x0, x24
     b5c: b9001814     	str	w20, [x0, #0x18]
     b60: b9401000     	ldr	w0, [x0, #0x10]
     b64: aa1803e9     	mov	x9, x24
     b68: b9401521     	ldr	w1, [x9, #0x14]
     b6c: 6b01001f     	cmp	w0, w1
     b70: 54000382     	b.hs	0xbe0 <___pl_fn_3+0x280>
     b74: aa0203e1     	mov	x1, x2
     b78: aa1803e0     	mov	x0, x24
     b7c: 94000000     	bl	0xb7c <___pl_fn_3+0x21c>
     b80: aa0003e2     	mov	x2, x0
     b84: aa1803e0     	mov	x0, x24
     b88: b9402c00     	ldr	w0, [x0, #0x2c]
     b8c: 350005c0     	cbnz	w0, 0xc44 <___pl_fn_3+0x2e4>
     b90: aa1803e0     	mov	x0, x24
     b94: b9001813     	str	w19, [x0, #0x18]
     b98: 52800661     	mov	w1, #0x33               ; =51
     b9c: 52802003     	mov	w3, #0x100              ; =256
     ba0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     ba4: f9400084     	ldr	x4, [x4]
     ba8: d63f0080     	blr	x4
     bac: 350004c0     	cbnz	w0, 0xc44 <___pl_fn_3+0x2e4>
     bb0: aa1803e0     	mov	x0, x24
     bb4: b9401000     	ldr	w0, [x0, #0x10]
     bb8: 51000400     	sub	w0, w0, #0x1
     bbc: aa1803e1     	mov	x1, x24
     bc0: b9001020     	str	w0, [x1, #0x10]
     bc4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     bc8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     bcc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     bd0: f84107f9     	ldr	x25, [sp], #0x10
     bd4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     bd8: d65f03c0     	ret
     bdc: 1400001a     	b	0xc44 <___pl_fn_3+0x2e4>
     be0: 52800641     	mov	w1, #0x32               ; =50
     be4: 14000014     	b	0xc34 <___pl_fn_3+0x2d4>
     be8: 52800621     	mov	w1, #0x31               ; =49
     bec: 14000012     	b	0xc34 <___pl_fn_3+0x2d4>
     bf0: 52800601     	mov	w1, #0x30               ; =48
     bf4: 14000010     	b	0xc34 <___pl_fn_3+0x2d4>
     bf8: 528005e1     	mov	w1, #0x2f               ; =47
     bfc: 1400000e     	b	0xc34 <___pl_fn_3+0x2d4>
     c00: 528005c1     	mov	w1, #0x2e               ; =46
     c04: 1400000c     	b	0xc34 <___pl_fn_3+0x2d4>
     c08: 528005a1     	mov	w1, #0x2d               ; =45
     c0c: 1400000a     	b	0xc34 <___pl_fn_3+0x2d4>
     c10: 52800581     	mov	w1, #0x2c               ; =44
     c14: 14000008     	b	0xc34 <___pl_fn_3+0x2d4>
     c18: 52800561     	mov	w1, #0x2b               ; =43
     c1c: 14000006     	b	0xc34 <___pl_fn_3+0x2d4>
     c20: 52800541     	mov	w1, #0x2a               ; =42
     c24: 14000004     	b	0xc34 <___pl_fn_3+0x2d4>
     c28: 52800521     	mov	w1, #0x29               ; =41
     c2c: 14000002     	b	0xc34 <___pl_fn_3+0x2d4>
     c30: 52800501     	mov	w1, #0x28               ; =40
     c34: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     c38: f940016b     	ldr	x11, [x11]
     c3c: aa1803e0     	mov	x0, x24
     c40: d63f0160     	blr	x11
     c44: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c48: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c4c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c50: f84107f9     	ldr	x25, [sp], #0x10
     c54: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c58: d65f03c0     	ret

0000000000000c5c <___pl_fn_4>:
     c5c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     c60: 910003fd     	mov	x29, sp
     c64: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     c68: b9401003     	ldr	w3, [x0, #0x10]
     c6c: 11000462     	add	w2, w3, #0x1
     c70: b9001002     	str	w2, [x0, #0x10]
     c74: 340006c1     	cbz	w1, 0xd4c <___pl_fn_4+0xf0>
     c78: f9400002     	ldr	x2, [x0]
     c7c: aa0003f4     	mov	x20, x0
     c80: 2a0103e0     	mov	w0, w1
     c84: aa0103e5     	mov	x5, x1
     c88: 8b000c41     	add	x1, x2, x0, lsl #3
     c8c: 3940a020     	ldrb	w0, [x1, #0x28]
     c90: 53001c02     	uxtb	w2, w0
     c94: 7100085f     	cmp	w2, #0x2
     c98: 540005e0     	b.eq	0xd54 <___pl_fn_4+0xf8>
     c9c: aa0503e2     	mov	x2, x5
     ca0: 72001c1f     	tst	w0, #0xff
     ca4: 54000481     	b.ne	0xd34 <___pl_fn_4+0xd8>
     ca8: 340006a2     	cbz	w2, 0xd7c <___pl_fn_4+0x120>
     cac: b9402021     	ldr	w1, [x1, #0x20]
     cb0: 34000661     	cbz	w1, 0xd7c <___pl_fn_4+0x120>
     cb4: aa1403e0     	mov	x0, x20
     cb8: b9401813     	ldr	w19, [x0, #0x18]
     cbc: b9401c03     	ldr	w3, [x0, #0x1c]
     cc0: 11000662     	add	w2, w19, #0x1
     cc4: 6b03005f     	cmp	w2, w3
     cc8: 54000748     	b.hi	0xdb0 <___pl_fn_4+0x154>
     ccc: aa1403e0     	mov	x0, x20
     cd0: f9401003     	ldr	x3, [x0, #0x20]
     cd4: b8335861     	str	w1, [x3, w19, uxtw #2]
     cd8: b9001802     	str	w2, [x0, #0x18]
     cdc: b9401005     	ldr	w5, [x0, #0x10]
     ce0: b9401406     	ldr	w6, [x0, #0x14]
     ce4: 6b0600bf     	cmp	w5, w6
     ce8: 54000602     	b.hs	0xda8 <___pl_fn_4+0x14c>
     cec: aa1403e0     	mov	x0, x20
     cf0: 94000000     	bl	0xcf0 <___pl_fn_4+0x94>
     cf4: aa1403e1     	mov	x1, x20
     cf8: b9402c27     	ldr	w7, [x1, #0x2c]
     cfc: 35000647     	cbnz	w7, 0xdc4 <___pl_fn_4+0x168>
     d00: aa1403e1     	mov	x1, x20
     d04: b9001833     	str	w19, [x1, #0x18]
     d08: b27ff7ea     	mov	x10, #0x7ffffffffffffffe ; =9223372036854775806
     d0c: eb0a001f     	cmp	x0, x10
     d10: 5400048c     	b.gt	0xda0 <___pl_fn_4+0x144>
     d14: aa1403e1     	mov	x1, x20
     d18: b940102c     	ldr	w12, [x1, #0x10]
     d1c: 5100058c     	sub	w12, w12, #0x1
     d20: b900102c     	str	w12, [x1, #0x10]
     d24: 91000400     	add	x0, x0, #0x1
     d28: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d2c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d30: d65f03c0     	ret
     d34: aa1403e0     	mov	x0, x20
     d38: b9001003     	str	w3, [x0, #0x10]
     d3c: d2800000     	mov	x0, #0x0                ; =0
     d40: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d44: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d48: d65f03c0     	ret
     d4c: aa0103e5     	mov	x5, x1
     d50: aa0003f4     	mov	x20, x0
     d54: 52800681     	mov	w1, #0x34               ; =52
     d58: 52800043     	mov	w3, #0x2                ; =2
     d5c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     d60: f9400084     	ldr	x4, [x4]
     d64: aa0503e2     	mov	x2, x5
     d68: aa1403e0     	mov	x0, x20
     d6c: d63f0080     	blr	x4
     d70: 350002a0     	cbnz	w0, 0xdc4 <___pl_fn_4+0x168>
     d74: 528006a1     	mov	w1, #0x35               ; =53
     d78: 1400000f     	b	0xdb4 <___pl_fn_4+0x158>
     d7c: 528006c1     	mov	w1, #0x36               ; =54
     d80: 52800023     	mov	w3, #0x1                ; =1
     d84: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     d88: f9400084     	ldr	x4, [x4]
     d8c: aa1403e0     	mov	x0, x20
     d90: d63f0080     	blr	x4
     d94: 35000180     	cbnz	w0, 0xdc4 <___pl_fn_4+0x168>
     d98: 528006e1     	mov	w1, #0x37               ; =55
     d9c: 14000006     	b	0xdb4 <___pl_fn_4+0x158>
     da0: 52800741     	mov	w1, #0x3a               ; =58
     da4: 14000004     	b	0xdb4 <___pl_fn_4+0x158>
     da8: 52800721     	mov	w1, #0x39               ; =57
     dac: 14000002     	b	0xdb4 <___pl_fn_4+0x158>
     db0: 52800701     	mov	w1, #0x38               ; =56
     db4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     db8: f9400042     	ldr	x2, [x2]
     dbc: aa1403e0     	mov	x0, x20
     dc0: d63f0040     	blr	x2
     dc4: d2800000     	mov	x0, #0x0                ; =0
     dc8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     dcc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     dd0: d65f03c0     	ret
