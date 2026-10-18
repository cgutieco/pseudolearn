
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_69571/towers/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: f81f0ff7     	str	x23, [sp, #-0x10]!
       c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      10: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      14: d100c3ff     	sub	sp, sp, #0x30
      18: aa0203f5     	mov	x21, x2
      1c: aa0303f6     	mov	x22, x3
      20: b940100b     	ldr	w11, [x0, #0x10]
      24: 1100056b     	add	w11, w11, #0x1
      28: b900100b     	str	w11, [x0, #0x10]
      2c: f940240d     	ldr	x13, [x0, #0x48]
      30: 2a0103f4     	mov	w20, w1
      34: aa0103f7     	mov	x23, x1
      38: d100068e     	sub	x14, x20, #0x1
      3c: eb0d01df     	cmp	x14, x13
      40: 540008c2     	b.hs	0x158 <___pl_fn_0+0x158>
      44: f9402001     	ldr	x1, [x0, #0x40]
      48: aa0003ec     	mov	x12, x0
      4c: d2800502     	mov	x2, #0x28               ; =40
      50: d1000683     	sub	x3, x20, #0x1
      54: 9b027c60     	mul	x0, x3, x2
      58: 9b020462     	madd	x2, x3, x2, x1
      5c: f9400442     	ldr	x2, [x2, #0x8]
      60: b5000082     	cbnz	x2, 0x70 <___pl_fn_0+0x70>
      64: 1400003e     	b	0x15c <___pl_fn_0+0x15c>
      68: f9401a62     	ldr	x2, [x19, #0x30]
      6c: 14000003     	b	0x78 <___pl_fn_0+0x78>
      70: aa0c03f3     	mov	x19, x12
      74: f8606822     	ldr	x2, [x1, x0]
      78: 34000842     	cbz	w2, 0x180 <___pl_fn_0+0x180>
      7c: f9400260     	ldr	x0, [x19]
      80: 2a0203e1     	mov	w1, w2
      84: 8b010c00     	add	x0, x0, x1, lsl #3
      88: f9400801     	ldr	x1, [x0, #0x10]
      8c: eb0102bf     	cmp	x21, x1
      90: 54000782     	b.hs	0x180 <___pl_fn_0+0x180>
      94: 8b150c00     	add	x0, x0, x21, lsl #3
      98: b9402800     	ldr	w0, [x0, #0x28]
      9c: 35000060     	cbnz	w0, 0xa8 <___pl_fn_0+0xa8>
      a0: 14000038     	b	0x180 <___pl_fn_0+0x180>
      a4: f9401a60     	ldr	x0, [x19, #0x30]
      a8: 340007f6     	cbz	w22, 0x1a4 <___pl_fn_0+0x1a4>
      ac: f9400262     	ldr	x2, [x19]
      b0: 2a1603e1     	mov	w1, w22
      b4: 8b010c41     	add	x1, x2, x1, lsl #3
      b8: f8765842     	ldr	x2, [x2, w22, uxtw #3]
      bc: 2a0003e0     	mov	w0, w0
      c0: d360fc42     	lsr	x2, x2, #32
      c4: 92403c42     	and	x2, x2, #0xffff
      c8: 91000442     	add	x2, x2, #0x1
      cc: f8227820     	str	x0, [x1, x2, lsl #3]
      d0: f9402660     	ldr	x0, [x19, #0x48]
      d4: d1000681     	sub	x1, x20, #0x1
      d8: eb00003f     	cmp	x1, x0
      dc: 540007e2     	b.hs	0x1d8 <___pl_fn_0+0x1d8>
      e0: f9402260     	ldr	x0, [x19, #0x40]
      e4: d2800502     	mov	x2, #0x28               ; =40
      e8: d1000683     	sub	x3, x20, #0x1
      ec: 9b027c61     	mul	x1, x3, x2
      f0: 9b020062     	madd	x2, x3, x2, x0
      f4: f9400442     	ldr	x2, [x2, #0x8]
      f8: b5000082     	cbnz	x2, 0x108 <___pl_fn_0+0x108>
      fc: 14000037     	b	0x1d8 <___pl_fn_0+0x1d8>
     100: f9401a62     	ldr	x2, [x19, #0x30]
     104: 14000002     	b	0x10c <___pl_fn_0+0x10c>
     108: f8616802     	ldr	x2, [x0, x1]
     10c: 34000762     	cbz	w2, 0x1f8 <___pl_fn_0+0x1f8>
     110: f9400260     	ldr	x0, [x19]
     114: 2a0203e1     	mov	w1, w2
     118: 8b010c00     	add	x0, x0, x1, lsl #3
     11c: f9400801     	ldr	x1, [x0, #0x10]
     120: eb0102bf     	cmp	x21, x1
     124: 540006a2     	b.hs	0x1f8 <___pl_fn_0+0x1f8>
     128: 2a1603e1     	mov	w1, w22
     12c: 8b150c00     	add	x0, x0, x21, lsl #3
     130: f9001401     	str	x1, [x0, #0x28]
     134: b9401261     	ldr	w1, [x19, #0x10]
     138: 51000421     	sub	w1, w1, #0x1
     13c: b9001261     	str	w1, [x19, #0x10]
     140: 9100c3ff     	add	sp, sp, #0x30
     144: a8c153f3     	ldp	x19, x20, [sp], #0x10
     148: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     14c: f84107f7     	ldr	x23, [sp], #0x10
     150: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     154: d65f03c0     	ret
     158: aa0003ec     	mov	x12, x0
     15c: 52800001     	mov	w1, #0x0                ; =0
     160: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     164: f9400063     	ldr	x3, [x3]
     168: aa0c03f3     	mov	x19, x12
     16c: aa1303e0     	mov	x0, x19
     170: aa1703e2     	mov	x2, x23
     174: d63f0060     	blr	x3
     178: 34fff780     	cbz	w0, 0x68 <___pl_fn_0+0x68>
     17c: 14000029     	b	0x220 <___pl_fn_0+0x220>
     180: 910003e3     	mov	x3, sp
     184: f80003f5     	stur	x21, [sp]
     188: 52800021     	mov	w1, #0x1                ; =1
     18c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     190: f9400084     	ldr	x4, [x4]
     194: aa1303e0     	mov	x0, x19
     198: d63f0080     	blr	x4
     19c: 34fff840     	cbz	w0, 0xa4 <___pl_fn_0+0xa4>
     1a0: 14000020     	b	0x220 <___pl_fn_0+0x220>
     1a4: d2800021     	mov	x1, #0x1                ; =1
     1a8: 910023e3     	add	x3, sp, #0x8
     1ac: f80083e1     	stur	x1, [sp, #0x8]
     1b0: 2a0003e0     	mov	w0, w0
     1b4: f80103e0     	stur	x0, [sp, #0x10]
     1b8: 52800041     	mov	w1, #0x2                ; =2
     1bc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     1c0: f9400084     	ldr	x4, [x4]
     1c4: aa1303e0     	mov	x0, x19
     1c8: aa1603e2     	mov	x2, x22
     1cc: d63f0080     	blr	x4
     1d0: 34fff800     	cbz	w0, 0xd0 <___pl_fn_0+0xd0>
     1d4: 14000013     	b	0x220 <___pl_fn_0+0x220>
     1d8: 52800061     	mov	w1, #0x3                ; =3
     1dc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     1e0: f9400063     	ldr	x3, [x3]
     1e4: aa1703e2     	mov	x2, x23
     1e8: aa1303e0     	mov	x0, x19
     1ec: d63f0060     	blr	x3
     1f0: 34fff880     	cbz	w0, 0x100 <___pl_fn_0+0x100>
     1f4: 1400000b     	b	0x220 <___pl_fn_0+0x220>
     1f8: 910063e3     	add	x3, sp, #0x18
     1fc: f80183f5     	stur	x21, [sp, #0x18]
     200: 2a1603e0     	mov	w0, w22
     204: f80203e0     	stur	x0, [sp, #0x20]
     208: 52800081     	mov	w1, #0x4                ; =4
     20c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     210: f9400084     	ldr	x4, [x4]
     214: aa1303e0     	mov	x0, x19
     218: d63f0080     	blr	x4
     21c: 34fff8c0     	cbz	w0, 0x134 <___pl_fn_0+0x134>
     220: 9100c3ff     	add	sp, sp, #0x30
     224: a8c153f3     	ldp	x19, x20, [sp], #0x10
     228: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     22c: f84107f7     	ldr	x23, [sp], #0x10
     230: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     234: d65f03c0     	ret

0000000000000238 <___pl_fn_1>:
     238: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     23c: 910003fd     	mov	x29, sp
     240: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     244: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     248: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     24c: d10083ff     	sub	sp, sp, #0x20
     250: aa0203f4     	mov	x20, x2
     254: b9401002     	ldr	w2, [x0, #0x10]
     258: 11000442     	add	w2, w2, #0x1
     25c: b9001002     	str	w2, [x0, #0x10]
     260: f9402402     	ldr	x2, [x0, #0x48]
     264: 2a0103f3     	mov	w19, w1
     268: aa0103f7     	mov	x23, x1
     26c: d1000661     	sub	x1, x19, #0x1
     270: eb02003f     	cmp	x1, x2
     274: 54000b62     	b.hs	0x3e0 <___pl_fn_1+0x1a8>
     278: f9402001     	ldr	x1, [x0, #0x40]
     27c: aa0003f6     	mov	x22, x0
     280: d2800502     	mov	x2, #0x28               ; =40
     284: d1000663     	sub	x3, x19, #0x1
     288: 9b027c60     	mul	x0, x3, x2
     28c: 9b020462     	madd	x2, x3, x2, x1
     290: f9400442     	ldr	x2, [x2, #0x8]
     294: b50000a2     	cbnz	x2, 0x2a8 <___pl_fn_1+0x70>
     298: 14000053     	b	0x3e4 <___pl_fn_1+0x1ac>
     29c: aa1603e0     	mov	x0, x22
     2a0: f9401802     	ldr	x2, [x0, #0x30]
     2a4: 14000002     	b	0x2ac <___pl_fn_1+0x74>
     2a8: f8606822     	ldr	x2, [x1, x0]
     2ac: 34000ac2     	cbz	w2, 0x404 <___pl_fn_1+0x1cc>
     2b0: aa1603e0     	mov	x0, x22
     2b4: f9400000     	ldr	x0, [x0]
     2b8: 2a0203e1     	mov	w1, w2
     2bc: 8b010c00     	add	x0, x0, x1, lsl #3
     2c0: f9400801     	ldr	x1, [x0, #0x10]
     2c4: eb01029f     	cmp	x20, x1
     2c8: 540009e2     	b.hs	0x404 <___pl_fn_1+0x1cc>
     2cc: 8b140c00     	add	x0, x0, x20, lsl #3
     2d0: b9402800     	ldr	w0, [x0, #0x28]
     2d4: 35000080     	cbnz	w0, 0x2e4 <___pl_fn_1+0xac>
     2d8: 1400004b     	b	0x404 <___pl_fn_1+0x1cc>
     2dc: aa1603e0     	mov	x0, x22
     2e0: f9401800     	ldr	x0, [x0, #0x30]
     2e4: 34000e80     	cbz	w0, 0x4b4 <___pl_fn_1+0x27c>
     2e8: 34000a00     	cbz	w0, 0x428 <___pl_fn_1+0x1f0>
     2ec: aa1603ef     	mov	x15, x22
     2f0: f94001e2     	ldr	x2, [x15]
     2f4: 2a0003e1     	mov	w1, w0
     2f8: 8b010c41     	add	x1, x2, x1, lsl #3
     2fc: f8605842     	ldr	x2, [x2, w0, uxtw #3]
     300: aa0003f8     	mov	x24, x0
     304: d360fc40     	lsr	x0, x2, #32
     308: 92403c00     	and	x0, x0, #0xffff
     30c: 91000400     	add	x0, x0, #0x1
     310: d37df000     	lsl	x0, x0, #3
     314: b8606835     	ldr	w21, [x1, x0]
     318: 350000b5     	cbnz	w21, 0x32c <___pl_fn_1+0xf4>
     31c: 14000044     	b	0x42c <___pl_fn_1+0x1f4>
     320: aa1603e0     	mov	x0, x22
     324: f9401815     	ldr	x21, [x0, #0x30]
     328: 14000002     	b	0x330 <___pl_fn_1+0xf8>
     32c: aa1603e0     	mov	x0, x22
     330: aa1603e0     	mov	x0, x22
     334: f9402400     	ldr	x0, [x0, #0x48]
     338: d1000661     	sub	x1, x19, #0x1
     33c: eb00003f     	cmp	x1, x0
     340: 54000882     	b.hs	0x450 <___pl_fn_1+0x218>
     344: aa1603e0     	mov	x0, x22
     348: f9402000     	ldr	x0, [x0, #0x40]
     34c: d2800502     	mov	x2, #0x28               ; =40
     350: d1000663     	sub	x3, x19, #0x1
     354: 9b027c61     	mul	x1, x3, x2
     358: 9b020062     	madd	x2, x3, x2, x0
     35c: f9400442     	ldr	x2, [x2, #0x8]
     360: b50000a2     	cbnz	x2, 0x374 <___pl_fn_1+0x13c>
     364: 1400003b     	b	0x450 <___pl_fn_1+0x218>
     368: aa1603e0     	mov	x0, x22
     36c: f9401802     	ldr	x2, [x0, #0x30]
     370: 14000002     	b	0x378 <___pl_fn_1+0x140>
     374: f8616802     	ldr	x2, [x0, x1]
     378: 340007c2     	cbz	w2, 0x470 <___pl_fn_1+0x238>
     37c: aa1603e0     	mov	x0, x22
     380: f9400000     	ldr	x0, [x0]
     384: 2a0203e1     	mov	w1, w2
     388: 8b010c00     	add	x0, x0, x1, lsl #3
     38c: f9400801     	ldr	x1, [x0, #0x10]
     390: eb01029f     	cmp	x20, x1
     394: 54000083     	b.lo	0x3a4 <___pl_fn_1+0x16c>
     398: 14000036     	b	0x470 <___pl_fn_1+0x238>
     39c: aa1603e0     	mov	x0, x22
     3a0: 14000005     	b	0x3b4 <___pl_fn_1+0x17c>
     3a4: 2a1503e5     	mov	w5, w21
     3a8: 8b140c06     	add	x6, x0, x20, lsl #3
     3ac: f90014c5     	str	x5, [x6, #0x28]
     3b0: aa1603e0     	mov	x0, x22
     3b4: aa1603e0     	mov	x0, x22
     3b8: b9401007     	ldr	w7, [x0, #0x10]
     3bc: 510004e7     	sub	w7, w7, #0x1
     3c0: b9001007     	str	w7, [x0, #0x10]
     3c4: aa1803e0     	mov	x0, x24
     3c8: 910083ff     	add	sp, sp, #0x20
     3cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     3d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     3d4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     3d8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     3dc: d65f03c0     	ret
     3e0: aa0003f6     	mov	x22, x0
     3e4: 528000a1     	mov	w1, #0x5                ; =5
     3e8: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     3ec: f9400063     	ldr	x3, [x3]
     3f0: aa1603e0     	mov	x0, x22
     3f4: aa1703e2     	mov	x2, x23
     3f8: d63f0060     	blr	x3
     3fc: 34fff500     	cbz	w0, 0x29c <___pl_fn_1+0x64>
     400: 14000026     	b	0x498 <___pl_fn_1+0x260>
     404: 910003e3     	mov	x3, sp
     408: f80003f4     	stur	x20, [sp]
     40c: 528000c1     	mov	w1, #0x6                ; =6
     410: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     414: f9400084     	ldr	x4, [x4]
     418: aa1603e0     	mov	x0, x22
     41c: d63f0080     	blr	x4
     420: 34fff5e0     	cbz	w0, 0x2dc <___pl_fn_1+0xa4>
     424: 1400001d     	b	0x498 <___pl_fn_1+0x260>
     428: aa0003f8     	mov	x24, x0
     42c: 52800101     	mov	w1, #0x8                ; =8
     430: 52800023     	mov	w3, #0x1                ; =1
     434: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     438: f9400084     	ldr	x4, [x4]
     43c: aa1603e0     	mov	x0, x22
     440: aa1803e2     	mov	x2, x24
     444: d63f0080     	blr	x4
     448: 34fff6c0     	cbz	w0, 0x320 <___pl_fn_1+0xe8>
     44c: 14000013     	b	0x498 <___pl_fn_1+0x260>
     450: 52800121     	mov	w1, #0x9                ; =9
     454: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     458: f9400063     	ldr	x3, [x3]
     45c: aa1703e2     	mov	x2, x23
     460: aa1603e0     	mov	x0, x22
     464: d63f0060     	blr	x3
     468: 34fff800     	cbz	w0, 0x368 <___pl_fn_1+0x130>
     46c: 1400000b     	b	0x498 <___pl_fn_1+0x260>
     470: 910023e3     	add	x3, sp, #0x8
     474: f80083f4     	stur	x20, [sp, #0x8]
     478: 2a1503e0     	mov	w0, w21
     47c: f80103e0     	stur	x0, [sp, #0x10]
     480: 52800141     	mov	w1, #0xa                ; =10
     484: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     488: f9400084     	ldr	x4, [x4]
     48c: aa1603e0     	mov	x0, x22
     490: d63f0080     	blr	x4
     494: 34fff840     	cbz	w0, 0x39c <___pl_fn_1+0x164>
     498: 52800000     	mov	w0, #0x0                ; =0
     49c: 910083ff     	add	sp, sp, #0x20
     4a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     4a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     4a8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     4ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     4b0: d65f03c0     	ret
     4b4: 528000e1     	mov	w1, #0x7                ; =7
     4b8: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     4bc: f9400129     	ldr	x9, [x9]
     4c0: aa1603e0     	mov	x0, x22
     4c4: d63f0120     	blr	x9
     4c8: 52800000     	mov	w0, #0x0                ; =0
     4cc: 910083ff     	add	sp, sp, #0x20
     4d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     4d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     4d8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     4dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     4e0: d65f03c0     	ret

00000000000004e4 <___pl_fn_2>:
     4e4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     4e8: 910003fd     	mov	x29, sp
     4ec: f81f0ff7     	str	x23, [sp, #-0x10]!
     4f0: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     4f4: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     4f8: aa0403f5     	mov	x21, x4
     4fc: aa0303f6     	mov	x22, x3
     500: aa0103f7     	mov	x23, x1
     504: b9401001     	ldr	w1, [x0, #0x10]
     508: 11000423     	add	w3, w1, #0x1
     50c: b9001003     	str	w3, [x0, #0x10]
     510: b9401403     	ldr	w3, [x0, #0x14]
     514: aa0003f4     	mov	x20, x0
     518: 11000420     	add	w0, w1, #0x1
     51c: 6b03001f     	cmp	w0, w3
     520: 54000f22     	b.hs	0x704 <___pl_fn_2+0x220>
     524: aa1403e0     	mov	x0, x20
     528: aa1703e1     	mov	x1, x23
     52c: 94000000     	bl	0x52c <___pl_fn_2+0x48>
     530: aa1403e3     	mov	x3, x20
     534: b9402c61     	ldr	w1, [x3, #0x2c]
     538: 35000dc1     	cbnz	w1, 0x6f0 <___pl_fn_2+0x20c>
     53c: aa1403e7     	mov	x7, x20
     540: b94018f3     	ldr	w19, [x7, #0x18]
     544: aa1403e9     	mov	x9, x20
     548: b9401d22     	ldr	w2, [x9, #0x1c]
     54c: 11000661     	add	w1, w19, #0x1
     550: 6b02003f     	cmp	w1, w2
     554: 54000ba8     	b.hi	0x6c8 <___pl_fn_2+0x1e4>
     558: aa1403ee     	mov	x14, x20
     55c: f94011c2     	ldr	x2, [x14, #0x20]
     560: b8335840     	str	w0, [x2, w19, uxtw #2]
     564: aa0003e3     	mov	x3, x0
     568: aa1403e0     	mov	x0, x20
     56c: b9001801     	str	w1, [x0, #0x18]
     570: b9401000     	ldr	w0, [x0, #0x10]
     574: aa1403e1     	mov	x1, x20
     578: b9401421     	ldr	w1, [x1, #0x14]
     57c: 6b01001f     	cmp	w0, w1
     580: 54000902     	b.hs	0x6a0 <___pl_fn_2+0x1bc>
     584: aa1703e1     	mov	x1, x23
     588: aa1603e2     	mov	x2, x22
     58c: aa1403e0     	mov	x0, x20
     590: 94000000     	bl	0x590 <___pl_fn_2+0xac>
     594: aa1403e0     	mov	x0, x20
     598: b9402c03     	ldr	w3, [x0, #0x2c]
     59c: 35000aa3     	cbnz	w3, 0x6f0 <___pl_fn_2+0x20c>
     5a0: aa1403e0     	mov	x0, x20
     5a4: b9001813     	str	w19, [x0, #0x18]
     5a8: f9402407     	ldr	x7, [x0, #0x48]
     5ac: aa1503f3     	mov	x19, x21
     5b0: 2a1303e6     	mov	w6, w19
     5b4: d10004c8     	sub	x8, x6, #0x1
     5b8: eb07011f     	cmp	x8, x7
     5bc: 540004c2     	b.hs	0x654 <___pl_fn_2+0x170>
     5c0: aa1403e0     	mov	x0, x20
     5c4: f9402009     	ldr	x9, [x0, #0x40]
     5c8: d280050b     	mov	x11, #0x28              ; =40
     5cc: d10004cc     	sub	x12, x6, #0x1
     5d0: 9b0b7d8a     	mul	x10, x12, x11
     5d4: 9b0b258b     	madd	x11, x12, x11, x9
     5d8: f940056b     	ldr	x11, [x11, #0x8]
     5dc: b50000ab     	cbnz	x11, 0x5f0 <___pl_fn_2+0x10c>
     5e0: 1400001d     	b	0x654 <___pl_fn_2+0x170>
     5e4: aa1403e0     	mov	x0, x20
     5e8: f9401800     	ldr	x0, [x0, #0x30]
     5ec: 14000003     	b	0x5f8 <___pl_fn_2+0x114>
     5f0: aa1303f5     	mov	x21, x19
     5f4: f86a6920     	ldr	x0, [x9, x10]
     5f8: d280002f     	mov	x15, #0x1               ; =1
     5fc: ab0f0003     	adds	x3, x0, x15
     600: 9a9f77e0     	cset	x0, vs
     604: 72001c1f     	tst	w0, #0xff
     608: 54000381     	b.ne	0x678 <___pl_fn_2+0x194>
     60c: 52800201     	mov	w1, #0x10               ; =16
     610: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     614: f9400084     	ldr	x4, [x4]
     618: aa1503e2     	mov	x2, x21
     61c: aa1403e0     	mov	x0, x20
     620: d63f0080     	blr	x4
     624: 35000660     	cbnz	w0, 0x6f0 <___pl_fn_2+0x20c>
     628: aa1403e0     	mov	x0, x20
     62c: b9401000     	ldr	w0, [x0, #0x10]
     630: 51000400     	sub	w0, w0, #0x1
     634: aa1403e8     	mov	x8, x20
     638: b9001100     	str	w0, [x8, #0x10]
     63c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     640: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     644: f84107f7     	ldr	x23, [sp], #0x10
     648: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     64c: d65f03c0     	ret
     650: 14000028     	b	0x6f0 <___pl_fn_2+0x20c>
     654: 528001c1     	mov	w1, #0xe                ; =14
     658: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     65c: f940016b     	ldr	x11, [x11]
     660: aa1403e0     	mov	x0, x20
     664: aa1303e2     	mov	x2, x19
     668: d63f0160     	blr	x11
     66c: aa1303f5     	mov	x21, x19
     670: 34fffba0     	cbz	w0, 0x5e4 <___pl_fn_2+0x100>
     674: 1400001f     	b	0x6f0 <___pl_fn_2+0x20c>
     678: 528001e1     	mov	w1, #0xf                ; =15
     67c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     680: f9400042     	ldr	x2, [x2]
     684: aa1403e0     	mov	x0, x20
     688: d63f0040     	blr	x2
     68c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     690: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     694: f84107f7     	ldr	x23, [sp], #0x10
     698: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     69c: d65f03c0     	ret
     6a0: 528001a1     	mov	w1, #0xd                ; =13
     6a4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6a8: f9400042     	ldr	x2, [x2]
     6ac: aa1403e0     	mov	x0, x20
     6b0: d63f0040     	blr	x2
     6b4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6b8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6bc: f84107f7     	ldr	x23, [sp], #0x10
     6c0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6c4: d65f03c0     	ret
     6c8: 52800181     	mov	w1, #0xc                ; =12
     6cc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6d0: f9400042     	ldr	x2, [x2]
     6d4: aa1403e0     	mov	x0, x20
     6d8: d63f0040     	blr	x2
     6dc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6e0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6e4: f84107f7     	ldr	x23, [sp], #0x10
     6e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6ec: d65f03c0     	ret
     6f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6f4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6f8: f84107f7     	ldr	x23, [sp], #0x10
     6fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     700: d65f03c0     	ret
     704: 52800161     	mov	w1, #0xb                ; =11
     708: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     70c: f9400042     	ldr	x2, [x2]
     710: aa1403e0     	mov	x0, x20
     714: d63f0040     	blr	x2
     718: a8c153f3     	ldp	x19, x20, [sp], #0x10
     71c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     720: f84107f7     	ldr	x23, [sp], #0x10
     724: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     728: d65f03c0     	ret

000000000000072c <___pl_fn_3>:
     72c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     730: 910003fd     	mov	x29, sp
     734: f81f0ffa     	str	x26, [sp, #-0x10]!
     738: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     73c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     740: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     744: aa0003f4     	mov	x20, x0
     748: aa0503f6     	mov	x22, x5
     74c: aa0103fa     	mov	x26, x1
     750: b9401000     	ldr	w0, [x0, #0x10]
     754: 11000401     	add	w1, w0, #0x1
     758: aa1403e5     	mov	x5, x20
     75c: b90010a1     	str	w1, [x5, #0x10]
     760: f100045f     	cmp	x2, #0x1
     764: aa0203f7     	mov	x23, x2
     768: 540008c0     	b.eq	0x880 <___pl_fn_3+0x154>
     76c: d2800065     	mov	x5, #0x3                ; =3
     770: eb0300a2     	subs	x2, x5, x3
     774: aa0303f5     	mov	x21, x3
     778: 9a9f77e5     	cset	x5, vs
     77c: 72001cbf     	tst	w5, #0xff
     780: 540013e1     	b.ne	0x9fc <___pl_fn_3+0x2d0>
     784: eb040053     	subs	x19, x2, x4
     788: aa0403f8     	mov	x24, x4
     78c: 9a9f77e6     	cset	x6, vs
     790: 72001cdf     	tst	w6, #0xff
     794: 540011e1     	b.ne	0x9d0 <___pl_fn_3+0x2a4>
     798: d2800027     	mov	x7, #0x1                ; =1
     79c: aa1703e1     	mov	x1, x23
     7a0: eb070022     	subs	x2, x1, x7
     7a4: 9a9f77e8     	cset	x8, vs
     7a8: 72001d1f     	tst	w8, #0xff
     7ac: 54000fc1     	b.ne	0x9a4 <___pl_fn_3+0x278>
     7b0: aa1403e1     	mov	x1, x20
     7b4: b9401429     	ldr	w9, [x1, #0x14]
     7b8: 1100040a     	add	w10, w0, #0x1
     7bc: 6b09015f     	cmp	w10, w9
     7c0: 54000dc2     	b.hs	0x978 <___pl_fn_3+0x24c>
     7c4: aa1403e0     	mov	x0, x20
     7c8: aa1a03e1     	mov	x1, x26
     7cc: aa1503e3     	mov	x3, x21
     7d0: aa1303e4     	mov	x4, x19
     7d4: aa1603e5     	mov	x5, x22
     7d8: 94000000     	bl	0x7d8 <___pl_fn_3+0xac>
     7dc: aa1403e0     	mov	x0, x20
     7e0: b9402c0c     	ldr	w12, [x0, #0x2c]
     7e4: 3500122c     	cbnz	w12, 0xa28 <___pl_fn_3+0x2fc>
     7e8: aa1403e0     	mov	x0, x20
     7ec: b940100e     	ldr	w14, [x0, #0x10]
     7f0: b940140f     	ldr	w15, [x0, #0x14]
     7f4: 6b0f01df     	cmp	w14, w15
     7f8: 54000aa2     	b.hs	0x94c <___pl_fn_3+0x220>
     7fc: aa1503e2     	mov	x2, x21
     800: aa1403e0     	mov	x0, x20
     804: aa1a03e1     	mov	x1, x26
     808: aa1803e3     	mov	x3, x24
     80c: aa1603e4     	mov	x4, x22
     810: 94000000     	bl	0x810 <___pl_fn_3+0xe4>
     814: aa1403e0     	mov	x0, x20
     818: b9402c00     	ldr	w0, [x0, #0x2c]
     81c: 35001060     	cbnz	w0, 0xa28 <___pl_fn_3+0x2fc>
     820: d2800020     	mov	x0, #0x1                ; =1
     824: aa1703e2     	mov	x2, x23
     828: eb000042     	subs	x2, x2, x0
     82c: 9a9f77e0     	cset	x0, vs
     830: 72001c1f     	tst	w0, #0xff
     834: 54000761     	b.ne	0x920 <___pl_fn_3+0x1f4>
     838: aa1403e0     	mov	x0, x20
     83c: b9401000     	ldr	w0, [x0, #0x10]
     840: aa1403e1     	mov	x1, x20
     844: b9401421     	ldr	w1, [x1, #0x14]
     848: 6b01001f     	cmp	w0, w1
     84c: 54000542     	b.hs	0x8f4 <___pl_fn_3+0x1c8>
     850: aa1a03e1     	mov	x1, x26
     854: aa1803e4     	mov	x4, x24
     858: aa1603e5     	mov	x5, x22
     85c: aa1403e0     	mov	x0, x20
     860: aa1303e3     	mov	x3, x19
     864: 94000000     	bl	0x864 <___pl_fn_3+0x138>
     868: aa1403e0     	mov	x0, x20
     86c: b9402c00     	ldr	w0, [x0, #0x2c]
     870: 35000dc0     	cbnz	w0, 0xa28 <___pl_fn_3+0x2fc>
     874: 52800020     	mov	w0, #0x1                ; =1
     878: aa1403e1     	mov	x1, x20
     87c: 14000013     	b	0x8c8 <___pl_fn_3+0x19c>
     880: aa1403e1     	mov	x1, x20
     884: aa0303e2     	mov	x2, x3
     888: aa0403f8     	mov	x24, x4
     88c: b9401421     	ldr	w1, [x1, #0x14]
     890: 11000400     	add	w0, w0, #0x1
     894: 6b01001f     	cmp	w0, w1
     898: 54000d42     	b.hs	0xa40 <___pl_fn_3+0x314>
     89c: aa1a03e1     	mov	x1, x26
     8a0: aa1803e3     	mov	x3, x24
     8a4: aa1603e4     	mov	x4, x22
     8a8: aa1403e0     	mov	x0, x20
     8ac: 94000000     	bl	0x8ac <___pl_fn_3+0x180>
     8b0: aa1403e0     	mov	x0, x20
     8b4: b9402c00     	ldr	w0, [x0, #0x2c]
     8b8: 35000b80     	cbnz	w0, 0xa28 <___pl_fn_3+0x2fc>
     8bc: d2800013     	mov	x19, #0x0               ; =0
     8c0: 52800000     	mov	w0, #0x0                ; =0
     8c4: aa1403e1     	mov	x1, x20
     8c8: aa1403e1     	mov	x1, x20
     8cc: b9401020     	ldr	w0, [x1, #0x10]
     8d0: 51000400     	sub	w0, w0, #0x1
     8d4: b9001020     	str	w0, [x1, #0x10]
     8d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8e0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8e4: f84107fa     	ldr	x26, [sp], #0x10
     8e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8ec: d65f03c0     	ret
     8f0: 1400004e     	b	0xa28 <___pl_fn_3+0x2fc>
     8f4: 528002e1     	mov	w1, #0x17               ; =23
     8f8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     8fc: f9400042     	ldr	x2, [x2]
     900: aa1403e0     	mov	x0, x20
     904: d63f0040     	blr	x2
     908: a8c153f3     	ldp	x19, x20, [sp], #0x10
     90c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     910: a8c163f7     	ldp	x23, x24, [sp], #0x10
     914: f84107fa     	ldr	x26, [sp], #0x10
     918: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     91c: d65f03c0     	ret
     920: 528002c1     	mov	w1, #0x16               ; =22
     924: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     928: f9400042     	ldr	x2, [x2]
     92c: aa1403e0     	mov	x0, x20
     930: d63f0040     	blr	x2
     934: a8c153f3     	ldp	x19, x20, [sp], #0x10
     938: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     93c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     940: f84107fa     	ldr	x26, [sp], #0x10
     944: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     948: d65f03c0     	ret
     94c: 528002a1     	mov	w1, #0x15               ; =21
     950: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     954: f9400042     	ldr	x2, [x2]
     958: aa1403e0     	mov	x0, x20
     95c: d63f0040     	blr	x2
     960: a8c153f3     	ldp	x19, x20, [sp], #0x10
     964: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     968: a8c163f7     	ldp	x23, x24, [sp], #0x10
     96c: f84107fa     	ldr	x26, [sp], #0x10
     970: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     974: d65f03c0     	ret
     978: 52800281     	mov	w1, #0x14               ; =20
     97c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     980: f9400042     	ldr	x2, [x2]
     984: aa1403e0     	mov	x0, x20
     988: d63f0040     	blr	x2
     98c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     990: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     994: a8c163f7     	ldp	x23, x24, [sp], #0x10
     998: f84107fa     	ldr	x26, [sp], #0x10
     99c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9a0: d65f03c0     	ret
     9a4: 52800261     	mov	w1, #0x13               ; =19
     9a8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9ac: f9400042     	ldr	x2, [x2]
     9b0: aa1403e0     	mov	x0, x20
     9b4: d63f0040     	blr	x2
     9b8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9bc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9c0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9c4: f84107fa     	ldr	x26, [sp], #0x10
     9c8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9cc: d65f03c0     	ret
     9d0: 52800241     	mov	w1, #0x12               ; =18
     9d4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9d8: f9400042     	ldr	x2, [x2]
     9dc: aa1403e0     	mov	x0, x20
     9e0: d63f0040     	blr	x2
     9e4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9e8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9ec: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9f0: f84107fa     	ldr	x26, [sp], #0x10
     9f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9f8: d65f03c0     	ret
     9fc: 52800221     	mov	w1, #0x11               ; =17
     a00: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a04: f9400042     	ldr	x2, [x2]
     a08: aa1403e0     	mov	x0, x20
     a0c: d63f0040     	blr	x2
     a10: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a14: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a18: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a1c: f84107fa     	ldr	x26, [sp], #0x10
     a20: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a24: d65f03c0     	ret
     a28: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a2c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a30: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a34: f84107fa     	ldr	x26, [sp], #0x10
     a38: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a3c: d65f03c0     	ret
     a40: 52800301     	mov	w1, #0x18               ; =24
     a44: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a48: f9400042     	ldr	x2, [x2]
     a4c: aa1403e0     	mov	x0, x20
     a50: d63f0040     	blr	x2
     a54: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a58: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a5c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a60: f84107fa     	ldr	x26, [sp], #0x10
     a64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a68: d65f03c0     	ret

0000000000000a6c <___pl_fn_4>:
     a6c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     a70: 910003fd     	mov	x29, sp
     a74: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
     a78: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
     a7c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     a80: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     a84: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     a88: d10083ff     	sub	sp, sp, #0x20
     a8c: b9401001     	ldr	w1, [x0, #0x10]
     a90: 11000421     	add	w1, w1, #0x1
     a94: b9001001     	str	w1, [x0, #0x10]
     a98: aa0003f8     	mov	x24, x0
     a9c: 52800321     	mov	w1, #0x19               ; =25
     aa0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     aa4: f9400042     	ldr	x2, [x2]
     aa8: d63f0040     	blr	x2
     aac: 35003840     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     ab0: aa1803e0     	mov	x0, x24
     ab4: f9401802     	ldr	x2, [x0, #0x30]
     ab8: aa0203f9     	mov	x25, x2
     abc: d2800060     	mov	x0, #0x3                ; =3
     ac0: 910003e3     	mov	x3, sp
     ac4: f80003e0     	stur	x0, [sp]
     ac8: 52800341     	mov	w1, #0x1a               ; =26
     acc: 52802082     	mov	w2, #0x104              ; =260
     ad0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     ad4: f9400084     	ldr	x4, [x4]
     ad8: aa1803e0     	mov	x0, x24
     adc: d63f0080     	blr	x4
     ae0: 350036a0     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     ae4: aa1803e0     	mov	x0, x24
     ae8: f9401813     	ldr	x19, [x0, #0x30]
     aec: 52800361     	mov	w1, #0x1b               ; =27
     af0: 52800082     	mov	w2, #0x4                ; =4
     af4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     af8: f9400063     	ldr	x3, [x3]
     afc: d63f0060     	blr	x3
     b00: 350035a0     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     b04: aa1803e0     	mov	x0, x24
     b08: f9401814     	ldr	x20, [x0, #0x30]
     b0c: 52800381     	mov	w1, #0x1c               ; =28
     b10: 2a1303e3     	mov	w3, w19
     b14: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b18: f9400084     	ldr	x4, [x4]
     b1c: aa1403e2     	mov	x2, x20
     b20: d63f0080     	blr	x4
     b24: aa1403fb     	mov	x27, x20
     b28: 35003460     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     b2c: 528003a1     	mov	w1, #0x1d               ; =29
     b30: 52800002     	mov	w2, #0x0                ; =0
     b34: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b38: f9400063     	ldr	x3, [x3]
     b3c: aa1803e0     	mov	x0, x24
     b40: d63f0060     	blr	x3
     b44: 35003380     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     b48: aa1803e0     	mov	x0, x24
     b4c: f9401802     	ldr	x2, [x0, #0x30]
     b50: aa0203fa     	mov	x26, x2
     b54: 528003c1     	mov	w1, #0x1e               ; =30
     b58: 52800002     	mov	w2, #0x0                ; =0
     b5c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b60: f9400063     	ldr	x3, [x3]
     b64: d63f0060     	blr	x3
     b68: 35003260     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     b6c: aa1803e0     	mov	x0, x24
     b70: f9401802     	ldr	x2, [x0, #0x30]
     b74: f80183e2     	stur	x2, [sp, #0x18]
     b78: d2800013     	mov	x19, #0x0               ; =0
     b7c: 52800020     	mov	w0, #0x1                ; =1
     b80: f1000a7f     	cmp	x19, #0x2
     b84: 9a9fc7e0     	cset	x0, le
     b88: 72001c1f     	tst	w0, #0xff
     b8c: 54001221     	b.ne	0xdd0 <___pl_fn_4+0x364>
     b90: 52800035     	mov	w21, #0x1               ; =1
     b94: f84183f3     	ldur	x19, [sp, #0x18]
     b98: f100027f     	cmp	x19, #0x0
     b9c: 9a9fd7e6     	cset	x6, gt
     ba0: 72001cdf     	tst	w6, #0xff
     ba4: 54000901     	b.ne	0xcc4 <___pl_fn_4+0x258>
     ba8: 52800421     	mov	w1, #0x21               ; =33
     bac: d2800003     	mov	x3, #0x0                ; =0
     bb0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     bb4: f9400084     	ldr	x4, [x4]
     bb8: aa1803e0     	mov	x0, x24
     bbc: aa1a03e2     	mov	x2, x26
     bc0: d63f0080     	blr	x4
     bc4: 35002f80     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     bc8: aa1803e0     	mov	x0, x24
     bcc: b9401000     	ldr	w0, [x0, #0x10]
     bd0: aa1803e7     	mov	x7, x24
     bd4: b94014e1     	ldr	w1, [x7, #0x14]
     bd8: 6b01001f     	cmp	w0, w1
     bdc: 54001a42     	b.hs	0xf24 <___pl_fn_4+0x4b8>
     be0: d2800003     	mov	x3, #0x0                ; =0
     be4: d2800024     	mov	x4, #0x1                ; =1
     be8: aa1b03e1     	mov	x1, x27
     bec: f84183e2     	ldur	x2, [sp, #0x18]
     bf0: aa1803e0     	mov	x0, x24
     bf4: aa1a03e5     	mov	x5, x26
     bf8: 94000000     	bl	0xbf8 <___pl_fn_4+0x18c>
     bfc: aa1803e0     	mov	x0, x24
     c00: b9402c00     	ldr	w0, [x0, #0x2c]
     c04: 35002d80     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     c08: aa1803e0     	mov	x0, x24
     c0c: f9402400     	ldr	x0, [x0, #0x48]
     c10: aa1a03e2     	mov	x2, x26
     c14: 2a0203e1     	mov	w1, w2
     c18: d1000422     	sub	x2, x1, #0x1
     c1c: eb00005f     	cmp	x2, x0
     c20: 54001722     	b.hs	0xf04 <___pl_fn_4+0x498>
     c24: aa1803e0     	mov	x0, x24
     c28: f9402000     	ldr	x0, [x0, #0x40]
     c2c: d2800502     	mov	x2, #0x28               ; =40
     c30: d1000423     	sub	x3, x1, #0x1
     c34: 9b027c61     	mul	x1, x3, x2
     c38: 9b020062     	madd	x2, x3, x2, x0
     c3c: f9400442     	ldr	x2, [x2, #0x8]
     c40: b50000a2     	cbnz	x2, 0xc54 <___pl_fn_4+0x1e8>
     c44: 140000b0     	b	0xf04 <___pl_fn_4+0x498>
     c48: aa1803e0     	mov	x0, x24
     c4c: f9401802     	ldr	x2, [x0, #0x30]
     c50: 14000002     	b	0xc58 <___pl_fn_4+0x1ec>
     c54: f8616802     	ldr	x2, [x0, x1]
     c58: 52800481     	mov	w1, #0x24               ; =36
     c5c: 52802003     	mov	w3, #0x100              ; =256
     c60: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c64: f9400084     	ldr	x4, [x4]
     c68: aa1803e0     	mov	x0, x24
     c6c: d63f0080     	blr	x4
     c70: 35002a20     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     c74: 528004a1     	mov	w1, #0x25               ; =37
     c78: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     c7c: f9400063     	ldr	x3, [x3]
     c80: aa1903e2     	mov	x2, x25
     c84: aa1803e0     	mov	x0, x24
     c88: d63f0060     	blr	x3
     c8c: 35002940     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     c90: aa1803e0     	mov	x0, x24
     c94: b9401000     	ldr	w0, [x0, #0x10]
     c98: 51000400     	sub	w0, w0, #0x1
     c9c: aa1803e1     	mov	x1, x24
     ca0: b9001020     	str	w0, [x1, #0x10]
     ca4: 910083ff     	add	sp, sp, #0x20
     ca8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     cb0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     cb4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     cb8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     cbc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     cc0: d65f03c0     	ret
     cc4: 528004c1     	mov	w1, #0x26               ; =38
     cc8: 52800002     	mov	w2, #0x0                ; =0
     ccc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     cd0: f9400063     	ldr	x3, [x3]
     cd4: aa1803e0     	mov	x0, x24
     cd8: d63f0060     	blr	x3
     cdc: 350026c0     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     ce0: aa1803e0     	mov	x0, x24
     ce4: f9401817     	ldr	x23, [x0, #0x30]
     ce8: b9401814     	ldr	w20, [x0, #0x18]
     cec: b9401c00     	ldr	w0, [x0, #0x1c]
     cf0: 11000696     	add	w22, w20, #0x1
     cf4: 6b0002df     	cmp	w22, w0
     cf8: 54001b48     	b.hi	0x1060 <___pl_fn_4+0x5f4>
     cfc: aa1803e0     	mov	x0, x24
     d00: f9401000     	ldr	x0, [x0, #0x20]
     d04: b8345817     	str	w23, [x0, w20, uxtw #2]
     d08: aa1803e0     	mov	x0, x24
     d0c: b9001816     	str	w22, [x0, #0x18]
     d10: b9401000     	ldr	w0, [x0, #0x10]
     d14: aa1803e1     	mov	x1, x24
     d18: b9401421     	ldr	w1, [x1, #0x14]
     d1c: 6b01001f     	cmp	w0, w1
     d20: 54001862     	b.hs	0x102c <___pl_fn_4+0x5c0>
     d24: 72001ebf     	tst	w21, #0xff
     d28: 54001680     	b.eq	0xff8 <___pl_fn_4+0x58c>
     d2c: aa1803e0     	mov	x0, x24
     d30: aa1703e1     	mov	x1, x23
     d34: aa1303e2     	mov	x2, x19
     d38: 94000000     	bl	0xd38 <___pl_fn_4+0x2cc>
     d3c: aa1803e0     	mov	x0, x24
     d40: aa1703e3     	mov	x3, x23
     d44: b9402c00     	ldr	w0, [x0, #0x2c]
     d48: 35002360     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     d4c: aa1803e0     	mov	x0, x24
     d50: b9001814     	str	w20, [x0, #0x18]
     d54: b9401c00     	ldr	w0, [x0, #0x1c]
     d58: 6b0002df     	cmp	w22, w0
     d5c: 54001348     	b.hi	0xfc4 <___pl_fn_4+0x558>
     d60: aa1803e0     	mov	x0, x24
     d64: f9401000     	ldr	x0, [x0, #0x20]
     d68: b8345803     	str	w3, [x0, w20, uxtw #2]
     d6c: aa1803e0     	mov	x0, x24
     d70: b9001816     	str	w22, [x0, #0x18]
     d74: b9401000     	ldr	w0, [x0, #0x10]
     d78: aa1803e1     	mov	x1, x24
     d7c: b9401421     	ldr	w1, [x1, #0x14]
     d80: 6b01001f     	cmp	w0, w1
     d84: 54001062     	b.hs	0xf90 <___pl_fn_4+0x524>
     d88: d2800002     	mov	x2, #0x0                ; =0
     d8c: aa1b03fc     	mov	x28, x27
     d90: aa1803e0     	mov	x0, x24
     d94: aa1c03e1     	mov	x1, x28
     d98: 94000000     	bl	0xd98 <___pl_fn_4+0x32c>
     d9c: aa1803e0     	mov	x0, x24
     da0: b9402c00     	ldr	w0, [x0, #0x2c]
     da4: 35002080     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     da8: aa1803e0     	mov	x0, x24
     dac: b9001814     	str	w20, [x0, #0x18]
     db0: 92800000     	mov	x0, #-0x1               ; =-1
     db4: ab000273     	adds	x19, x19, x0
     db8: 9a9f77e1     	cset	x1, vs
     dbc: 72001c3f     	tst	w1, #0xff
     dc0: 54000ce1     	b.ne	0xf5c <___pl_fn_4+0x4f0>
     dc4: 52800035     	mov	w21, #0x1               ; =1
     dc8: aa1c03fb     	mov	x27, x28
     dcc: 17ffff73     	b	0xb98 <___pl_fn_4+0x12c>
     dd0: aa1b03fc     	mov	x28, x27
     dd4: d2800035     	mov	x21, #0x1               ; =1
     dd8: f84183f4     	ldur	x20, [sp, #0x18]
     ddc: ab150282     	adds	x2, x20, x21
     de0: aa0203fb     	mov	x27, x2
     de4: 9a9f77ea     	cset	x10, vs
     de8: 72001d5f     	tst	w10, #0xff
     dec: 54001ca1     	b.ne	0x1180 <___pl_fn_4+0x714>
     df0: 528005c1     	mov	w1, #0x2e               ; =46
     df4: 52800002     	mov	w2, #0x0                ; =0
     df8: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     dfc: f940016b     	ldr	x11, [x11]
     e00: aa1803e0     	mov	x0, x24
     e04: d63f0160     	blr	x11
     e08: 35001d60     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     e0c: aa1803e0     	mov	x0, x24
     e10: f9401816     	ldr	x22, [x0, #0x30]
     e14: b9401817     	ldr	w23, [x0, #0x18]
     e18: b9401c0e     	ldr	w14, [x0, #0x1c]
     e1c: 110006ed     	add	w13, w23, #0x1
     e20: 6b0e01bf     	cmp	w13, w14
     e24: 54001948     	b.hi	0x114c <___pl_fn_4+0x6e0>
     e28: aa1803e0     	mov	x0, x24
     e2c: f940100f     	ldr	x15, [x0, #0x20]
     e30: b83759f6     	str	w22, [x15, w23, uxtw #2]
     e34: b900180d     	str	w13, [x0, #0x18]
     e38: b9401000     	ldr	w0, [x0, #0x10]
     e3c: aa1803e1     	mov	x1, x24
     e40: b9401421     	ldr	w1, [x1, #0x14]
     e44: 6b01001f     	cmp	w0, w1
     e48: 54001682     	b.hs	0x1118 <___pl_fn_4+0x6ac>
     e4c: aa1b03e2     	mov	x2, x27
     e50: aa1803e0     	mov	x0, x24
     e54: aa1603e1     	mov	x1, x22
     e58: 94000000     	bl	0xe58 <___pl_fn_4+0x3ec>
     e5c: aa1803e0     	mov	x0, x24
     e60: b9402c00     	ldr	w0, [x0, #0x2c]
     e64: 35001a80     	cbnz	w0, 0x11b4 <___pl_fn_4+0x748>
     e68: aa1803e0     	mov	x0, x24
     e6c: b9001817     	str	w23, [x0, #0x18]
     e70: f9402400     	ldr	x0, [x0, #0x48]
     e74: 2a1c03e1     	mov	w1, w28
     e78: d1000422     	sub	x2, x1, #0x1
     e7c: eb00005f     	cmp	x2, x0
     e80: 540010c2     	b.hs	0x1098 <___pl_fn_4+0x62c>
     e84: aa1803e0     	mov	x0, x24
     e88: f9402000     	ldr	x0, [x0, #0x40]
     e8c: d2800502     	mov	x2, #0x28               ; =40
     e90: d1000423     	sub	x3, x1, #0x1
     e94: 9b027c61     	mul	x1, x3, x2
     e98: 9b020062     	madd	x2, x3, x2, x0
     e9c: f9400442     	ldr	x2, [x2, #0x8]
     ea0: b50000a2     	cbnz	x2, 0xeb4 <___pl_fn_4+0x448>
     ea4: 1400007d     	b	0x1098 <___pl_fn_4+0x62c>
     ea8: aa1803e0     	mov	x0, x24
     eac: f9401802     	ldr	x2, [x0, #0x30]
     eb0: 14000002     	b	0xeb8 <___pl_fn_4+0x44c>
     eb4: f8616802     	ldr	x2, [x0, x1]
     eb8: 34001002     	cbz	w2, 0x10b8 <___pl_fn_4+0x64c>
     ebc: aa1803e0     	mov	x0, x24
     ec0: f9400000     	ldr	x0, [x0]
     ec4: 2a0203e1     	mov	w1, w2
     ec8: 8b010c00     	add	x0, x0, x1, lsl #3
     ecc: f9400801     	ldr	x1, [x0, #0x10]
     ed0: eb01027f     	cmp	x19, x1
     ed4: 54000f22     	b.hs	0x10b8 <___pl_fn_4+0x64c>
     ed8: 2a1603e1     	mov	w1, w22
     edc: 8b130c00     	add	x0, x0, x19, lsl #3
     ee0: f9001401     	str	x1, [x0, #0x28]
     ee4: ab150273     	adds	x19, x19, x21
     ee8: 9a9f77e0     	cset	x0, vs
     eec: 72001c1f     	tst	w0, #0xff
     ef0: 54000fa1     	b.ne	0x10e4 <___pl_fn_4+0x678>
     ef4: 52800020     	mov	w0, #0x1                ; =1
     ef8: aa1c03fb     	mov	x27, x28
     efc: f80183f4     	stur	x20, [sp, #0x18]
     f00: 17ffff20     	b	0xb80 <___pl_fn_4+0x114>
     f04: 52800461     	mov	w1, #0x23               ; =35
     f08: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     f0c: f9400063     	ldr	x3, [x3]
     f10: aa1a03e2     	mov	x2, x26
     f14: aa1803e0     	mov	x0, x24
     f18: d63f0060     	blr	x3
     f1c: 34ffe960     	cbz	w0, 0xc48 <___pl_fn_4+0x1dc>
     f20: 140000a5     	b	0x11b4 <___pl_fn_4+0x748>
     f24: 52800441     	mov	w1, #0x22               ; =34
     f28: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     f2c: f9400042     	ldr	x2, [x2]
     f30: aa1803e0     	mov	x0, x24
     f34: d63f0040     	blr	x2
     f38: 910083ff     	add	sp, sp, #0x20
     f3c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f40: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     f44: a8c163f7     	ldp	x23, x24, [sp], #0x10
     f48: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     f4c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     f50: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f54: d65f03c0     	ret
     f58: 14000097     	b	0x11b4 <___pl_fn_4+0x748>
     f5c: 52800581     	mov	w1, #0x2c               ; =44
     f60: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     f64: f9400063     	ldr	x3, [x3]
     f68: aa1803e0     	mov	x0, x24
     f6c: d63f0060     	blr	x3
     f70: 910083ff     	add	sp, sp, #0x20
     f74: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f78: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     f7c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     f80: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     f84: a8c173fb     	ldp	x27, x28, [sp], #0x10
     f88: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f8c: d65f03c0     	ret
     f90: 52800561     	mov	w1, #0x2b               ; =43
     f94: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     f98: f9400084     	ldr	x4, [x4]
     f9c: aa1803e0     	mov	x0, x24
     fa0: d63f0080     	blr	x4
     fa4: 910083ff     	add	sp, sp, #0x20
     fa8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     fac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     fb0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     fb4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     fb8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     fbc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     fc0: d65f03c0     	ret
     fc4: 52800541     	mov	w1, #0x2a               ; =42
     fc8: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     fcc: f94000a5     	ldr	x5, [x5]
     fd0: aa1803e0     	mov	x0, x24
     fd4: d63f00a0     	blr	x5
     fd8: 910083ff     	add	sp, sp, #0x20
     fdc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     fe0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     fe4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     fe8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     fec: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ff0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ff4: d65f03c0     	ret
     ff8: 52800521     	mov	w1, #0x29               ; =41
     ffc: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
    1000: f94000c6     	ldr	x6, [x6]
    1004: aa1803e0     	mov	x0, x24
    1008: d63f00c0     	blr	x6
    100c: 910083ff     	add	sp, sp, #0x20
    1010: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1014: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1018: a8c163f7     	ldp	x23, x24, [sp], #0x10
    101c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1020: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1024: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1028: d65f03c0     	ret
    102c: 52800501     	mov	w1, #0x28               ; =40
    1030: 90000007     	adrp	x7, 0x1000 <___pl_fn_4+0x594>
    1034: f94000e7     	ldr	x7, [x7]
    1038: aa1803e0     	mov	x0, x24
    103c: d63f00e0     	blr	x7
    1040: 910083ff     	add	sp, sp, #0x20
    1044: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1048: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    104c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1050: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1054: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1058: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    105c: d65f03c0     	ret
    1060: 528004e1     	mov	w1, #0x27               ; =39
    1064: 90000008     	adrp	x8, 0x1000 <___pl_fn_4+0x594>
    1068: f9400108     	ldr	x8, [x8]
    106c: aa1803e0     	mov	x0, x24
    1070: d63f0100     	blr	x8
    1074: 910083ff     	add	sp, sp, #0x20
    1078: a8c153f3     	ldp	x19, x20, [sp], #0x10
    107c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1080: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1084: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1088: a8c173fb     	ldp	x27, x28, [sp], #0x10
    108c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1090: d65f03c0     	ret
    1094: 14000048     	b	0x11b4 <___pl_fn_4+0x748>
    1098: 52800621     	mov	w1, #0x31               ; =49
    109c: 90000003     	adrp	x3, 0x1000 <___pl_fn_4+0x594>
    10a0: f9400063     	ldr	x3, [x3]
    10a4: aa1803e0     	mov	x0, x24
    10a8: aa1c03e2     	mov	x2, x28
    10ac: d63f0060     	blr	x3
    10b0: 34ffefc0     	cbz	w0, 0xea8 <___pl_fn_4+0x43c>
    10b4: 14000040     	b	0x11b4 <___pl_fn_4+0x748>
    10b8: 910023e3     	add	x3, sp, #0x8
    10bc: f80083f3     	stur	x19, [sp, #0x8]
    10c0: 2a1603e0     	mov	w0, w22
    10c4: f80103e0     	stur	x0, [sp, #0x10]
    10c8: 52800641     	mov	w1, #0x32               ; =50
    10cc: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x594>
    10d0: f9400084     	ldr	x4, [x4]
    10d4: aa1803e0     	mov	x0, x24
    10d8: d63f0080     	blr	x4
    10dc: 34fff040     	cbz	w0, 0xee4 <___pl_fn_4+0x478>
    10e0: 14000035     	b	0x11b4 <___pl_fn_4+0x748>
    10e4: 52800661     	mov	w1, #0x33               ; =51
    10e8: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x594>
    10ec: f9400042     	ldr	x2, [x2]
    10f0: aa1803e0     	mov	x0, x24
    10f4: d63f0040     	blr	x2
    10f8: 910083ff     	add	sp, sp, #0x20
    10fc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1100: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1104: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1108: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    110c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1110: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1114: d65f03c0     	ret
    1118: 52800601     	mov	w1, #0x30               ; =48
    111c: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x594>
    1120: f9400042     	ldr	x2, [x2]
    1124: aa1803e0     	mov	x0, x24
    1128: d63f0040     	blr	x2
    112c: 910083ff     	add	sp, sp, #0x20
    1130: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1134: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1138: a8c163f7     	ldp	x23, x24, [sp], #0x10
    113c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1140: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1144: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1148: d65f03c0     	ret
    114c: 528005e1     	mov	w1, #0x2f               ; =47
    1150: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x594>
    1154: f9400042     	ldr	x2, [x2]
    1158: aa1803e0     	mov	x0, x24
    115c: d63f0040     	blr	x2
    1160: 910083ff     	add	sp, sp, #0x20
    1164: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1168: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    116c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1170: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1174: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1178: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    117c: d65f03c0     	ret
    1180: 528005a1     	mov	w1, #0x2d               ; =45
    1184: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x594>
    1188: f9400042     	ldr	x2, [x2]
    118c: aa1803e0     	mov	x0, x24
    1190: d63f0040     	blr	x2
    1194: 910083ff     	add	sp, sp, #0x20
    1198: a8c153f3     	ldp	x19, x20, [sp], #0x10
    119c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    11a0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    11a4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    11a8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    11ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11b0: d65f03c0     	ret
    11b4: 910083ff     	add	sp, sp, #0x20
    11b8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11bc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    11c0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    11c4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    11c8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    11cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11d0: d65f03c0     	ret

00000000000011d4 <___pl_fn_5>:
    11d4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    11d8: 910003fd     	mov	x29, sp
    11dc: f81f0ff3     	str	x19, [sp, #-0x10]!
    11e0: d10043ff     	sub	sp, sp, #0x10
    11e4: b9401003     	ldr	w3, [x0, #0x10]
    11e8: 11000463     	add	w3, w3, #0x1
    11ec: b9001003     	str	w3, [x0, #0x10]
    11f0: aa0003e5     	mov	x5, x0
    11f4: 34000321     	cbz	w1, 0x1258 <___pl_fn_5+0x84>
    11f8: aa0503f3     	mov	x19, x5
    11fc: aa0203e3     	mov	x3, x2
    1200: aa0103e2     	mov	x2, x1
    1204: f9400261     	ldr	x1, [x19]
    1208: 2a0203e0     	mov	w0, w2
    120c: 8b000c20     	add	x0, x1, x0, lsl #3
    1210: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    1214: d360fc21     	lsr	x1, x1, #32
    1218: 92403c22     	and	x2, x1, #0xffff
    121c: f100085f     	cmp	x2, #0x2
    1220: 54000080     	b.eq	0x1230 <___pl_fn_5+0x5c>
    1224: f9400802     	ldr	x2, [x0, #0x10]
    1228: 927ff842     	and	x2, x2, #0xfffffffffffffffe
    122c: f9000802     	str	x2, [x0, #0x10]
    1230: 92403c21     	and	x1, x1, #0xffff
    1234: aa0303e2     	mov	x2, x3
    1238: f8217802     	str	x2, [x0, x1, lsl #3]
    123c: b9401260     	ldr	w0, [x19, #0x10]
    1240: 51000400     	sub	w0, w0, #0x1
    1244: b9001260     	str	w0, [x19, #0x10]
    1248: 910043ff     	add	sp, sp, #0x10
    124c: f84107f3     	ldr	x19, [sp], #0x10
    1250: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1254: d65f03c0     	ret
    1258: aa0103e6     	mov	x6, x1
    125c: d2800000     	mov	x0, #0x0                ; =0
    1260: 910003e3     	mov	x3, sp
    1264: f80003e0     	stur	x0, [sp]
    1268: f80083e2     	stur	x2, [sp, #0x8]
    126c: 52800681     	mov	w1, #0x34               ; =52
    1270: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x594>
    1274: f9400084     	ldr	x4, [x4]
    1278: aa0603e2     	mov	x2, x6
    127c: aa0503f3     	mov	x19, x5
    1280: aa1303e0     	mov	x0, x19
    1284: d63f0080     	blr	x4
    1288: 34fffda0     	cbz	w0, 0x123c <___pl_fn_5+0x68>
    128c: 910043ff     	add	sp, sp, #0x10
    1290: f84107f3     	ldr	x19, [sp], #0x10
    1294: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1298: d65f03c0     	ret
