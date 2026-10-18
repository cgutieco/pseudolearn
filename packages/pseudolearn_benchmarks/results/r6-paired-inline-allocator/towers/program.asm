
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_94328/towers/program.o:	file format mach-o arm64

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
      4c: d2800602     	mov	x2, #0x30               ; =48
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
      e4: d2800602     	mov	x2, #0x30               ; =48
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
     280: d2800602     	mov	x2, #0x30               ; =48
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
     34c: d2800602     	mov	x2, #0x30               ; =48
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
     4ec: a9bf73fa     	stp	x26, x28, [sp, #-0x10]!
     4f0: a9bf5ff5     	stp	x21, x23, [sp, #-0x10]!
     4f4: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     4f8: aa0403f7     	mov	x23, x4
     4fc: aa0303fa     	mov	x26, x3
     500: aa0103fc     	mov	x28, x1
     504: b9401001     	ldr	w1, [x0, #0x10]
     508: 11000423     	add	w3, w1, #0x1
     50c: b9001003     	str	w3, [x0, #0x10]
     510: b9401403     	ldr	w3, [x0, #0x14]
     514: aa0003f5     	mov	x21, x0
     518: 11000421     	add	w1, w1, #0x1
     51c: 6b03003f     	cmp	w1, w3
     520: 54001182     	b.hs	0x750 <___pl_fn_2+0x26c>
     524: aa1503e0     	mov	x0, x21
     528: aa1c03e1     	mov	x1, x28
     52c: 94000000     	bl	0x52c <___pl_fn_2+0x48>
     530: aa1503ec     	mov	x12, x21
     534: b9402d83     	ldr	w3, [x12, #0x2c]
     538: 35001023     	cbnz	w3, 0x73c <___pl_fn_2+0x258>
     53c: aa1503e1     	mov	x1, x21
     540: b9401833     	ldr	w19, [x1, #0x18]
     544: b9401c26     	ldr	w6, [x1, #0x1c]
     548: 11000665     	add	w5, w19, #0x1
     54c: 6b0600bf     	cmp	w5, w6
     550: 54000e28     	b.hi	0x714 <___pl_fn_2+0x230>
     554: aa1503e1     	mov	x1, x21
     558: f9401027     	ldr	x7, [x1, #0x20]
     55c: b83358e0     	str	w0, [x7, w19, uxtw #2]
     560: aa0003e3     	mov	x3, x0
     564: aa1503e0     	mov	x0, x21
     568: b9001805     	str	w5, [x0, #0x18]
     56c: b9401009     	ldr	w9, [x0, #0x10]
     570: b940140a     	ldr	w10, [x0, #0x14]
     574: 6b0a013f     	cmp	w9, w10
     578: 54000ba2     	b.hs	0x6ec <___pl_fn_2+0x208>
     57c: aa1c03e1     	mov	x1, x28
     580: aa1a03e2     	mov	x2, x26
     584: aa1503e0     	mov	x0, x21
     588: 94000000     	bl	0x588 <___pl_fn_2+0xa4>
     58c: aa1503e0     	mov	x0, x21
     590: b9402c0c     	ldr	w12, [x0, #0x2c]
     594: 35000d4c     	cbnz	w12, 0x73c <___pl_fn_2+0x258>
     598: aa1503e0     	mov	x0, x21
     59c: b9001813     	str	w19, [x0, #0x18]
     5a0: f940240f     	ldr	x15, [x0, #0x48]
     5a4: aa1703f4     	mov	x20, x23
     5a8: 2a1403f3     	mov	w19, w20
     5ac: d1000660     	sub	x0, x19, #0x1
     5b0: eb0f001f     	cmp	x0, x15
     5b4: 54000662     	b.hs	0x680 <___pl_fn_2+0x19c>
     5b8: aa1503e0     	mov	x0, x21
     5bc: f9402000     	ldr	x0, [x0, #0x40]
     5c0: d2800602     	mov	x2, #0x30               ; =48
     5c4: d1000663     	sub	x3, x19, #0x1
     5c8: 9b027c61     	mul	x1, x3, x2
     5cc: 9b020062     	madd	x2, x3, x2, x0
     5d0: f9400442     	ldr	x2, [x2, #0x8]
     5d4: b50000a2     	cbnz	x2, 0x5e8 <___pl_fn_2+0x104>
     5d8: 1400002a     	b	0x680 <___pl_fn_2+0x19c>
     5dc: aa1503e0     	mov	x0, x21
     5e0: f9401800     	ldr	x0, [x0, #0x30]
     5e4: 14000003     	b	0x5f0 <___pl_fn_2+0x10c>
     5e8: aa1403f7     	mov	x23, x20
     5ec: f8616800     	ldr	x0, [x0, x1]
     5f0: d2800021     	mov	x1, #0x1                ; =1
     5f4: ab010003     	adds	x3, x0, x1
     5f8: 9a9f77e0     	cset	x0, vs
     5fc: 72001c1f     	tst	w0, #0xff
     600: 54000621     	b.ne	0x6c4 <___pl_fn_2+0x1e0>
     604: aa1503e0     	mov	x0, x21
     608: f9402400     	ldr	x0, [x0, #0x48]
     60c: d1000661     	sub	x1, x19, #0x1
     610: eb00003f     	cmp	x1, x0
     614: 54000482     	b.hs	0x6a4 <___pl_fn_2+0x1c0>
     618: aa1503e0     	mov	x0, x21
     61c: f9402000     	ldr	x0, [x0, #0x40]
     620: d2800601     	mov	x1, #0x30               ; =48
     624: d1000664     	sub	x4, x19, #0x1
     628: 9b017c82     	mul	x2, x4, x1
     62c: 9b010081     	madd	x1, x4, x1, x0
     630: f9400824     	ldr	x4, [x1, #0x10]
     634: b5000084     	cbnz	x4, 0x644 <___pl_fn_2+0x160>
     638: 1400001b     	b	0x6a4 <___pl_fn_2+0x1c0>
     63c: aa1503e0     	mov	x0, x21
     640: 14000005     	b	0x654 <___pl_fn_2+0x170>
     644: f8226803     	str	x3, [x0, x2]
     648: d2800020     	mov	x0, #0x1                ; =1
     64c: f9000420     	str	x0, [x1, #0x8]
     650: aa1503e0     	mov	x0, x21
     654: aa1503e0     	mov	x0, x21
     658: b9401000     	ldr	w0, [x0, #0x10]
     65c: 51000400     	sub	w0, w0, #0x1
     660: aa1503e1     	mov	x1, x21
     664: b9001020     	str	w0, [x1, #0x10]
     668: a8c153f3     	ldp	x19, x20, [sp], #0x10
     66c: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     670: a8c173fa     	ldp	x26, x28, [sp], #0x10
     674: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     678: d65f03c0     	ret
     67c: 14000030     	b	0x73c <___pl_fn_2+0x258>
     680: 528001c1     	mov	w1, #0xe                ; =14
     684: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     688: f9400063     	ldr	x3, [x3]
     68c: aa1503e0     	mov	x0, x21
     690: aa1403e2     	mov	x2, x20
     694: d63f0060     	blr	x3
     698: aa1403f7     	mov	x23, x20
     69c: 34fffa00     	cbz	w0, 0x5dc <___pl_fn_2+0xf8>
     6a0: 14000027     	b	0x73c <___pl_fn_2+0x258>
     6a4: 52800201     	mov	w1, #0x10               ; =16
     6a8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     6ac: f9400084     	ldr	x4, [x4]
     6b0: aa1703e2     	mov	x2, x23
     6b4: aa1503e0     	mov	x0, x21
     6b8: d63f0080     	blr	x4
     6bc: 34fffc00     	cbz	w0, 0x63c <___pl_fn_2+0x158>
     6c0: 1400001f     	b	0x73c <___pl_fn_2+0x258>
     6c4: 528001e1     	mov	w1, #0xf                ; =15
     6c8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6cc: f9400042     	ldr	x2, [x2]
     6d0: aa1503e0     	mov	x0, x21
     6d4: d63f0040     	blr	x2
     6d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6dc: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     6e0: a8c173fa     	ldp	x26, x28, [sp], #0x10
     6e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6e8: d65f03c0     	ret
     6ec: 528001a1     	mov	w1, #0xd                ; =13
     6f0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6f4: f9400042     	ldr	x2, [x2]
     6f8: aa1503e0     	mov	x0, x21
     6fc: d63f0040     	blr	x2
     700: a8c153f3     	ldp	x19, x20, [sp], #0x10
     704: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     708: a8c173fa     	ldp	x26, x28, [sp], #0x10
     70c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     710: d65f03c0     	ret
     714: 52800181     	mov	w1, #0xc                ; =12
     718: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     71c: f9400042     	ldr	x2, [x2]
     720: aa1503e0     	mov	x0, x21
     724: d63f0040     	blr	x2
     728: a8c153f3     	ldp	x19, x20, [sp], #0x10
     72c: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     730: a8c173fa     	ldp	x26, x28, [sp], #0x10
     734: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     738: d65f03c0     	ret
     73c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     740: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     744: a8c173fa     	ldp	x26, x28, [sp], #0x10
     748: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     74c: d65f03c0     	ret
     750: 52800161     	mov	w1, #0xb                ; =11
     754: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     758: f9400042     	ldr	x2, [x2]
     75c: aa1503e0     	mov	x0, x21
     760: d63f0040     	blr	x2
     764: a8c153f3     	ldp	x19, x20, [sp], #0x10
     768: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     76c: a8c173fa     	ldp	x26, x28, [sp], #0x10
     770: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     774: d65f03c0     	ret

0000000000000778 <___pl_fn_3>:
     778: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     77c: 910003fd     	mov	x29, sp
     780: f81f0ffa     	str	x26, [sp, #-0x10]!
     784: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     788: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     78c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     790: aa0003f4     	mov	x20, x0
     794: aa0503f6     	mov	x22, x5
     798: aa0103fa     	mov	x26, x1
     79c: b9401000     	ldr	w0, [x0, #0x10]
     7a0: 11000401     	add	w1, w0, #0x1
     7a4: aa1403e5     	mov	x5, x20
     7a8: b90010a1     	str	w1, [x5, #0x10]
     7ac: f100045f     	cmp	x2, #0x1
     7b0: aa0203f7     	mov	x23, x2
     7b4: 540008c0     	b.eq	0x8cc <___pl_fn_3+0x154>
     7b8: d2800065     	mov	x5, #0x3                ; =3
     7bc: eb0300a2     	subs	x2, x5, x3
     7c0: aa0303f5     	mov	x21, x3
     7c4: 9a9f77e5     	cset	x5, vs
     7c8: 72001cbf     	tst	w5, #0xff
     7cc: 540013e1     	b.ne	0xa48 <___pl_fn_3+0x2d0>
     7d0: eb040053     	subs	x19, x2, x4
     7d4: aa0403f8     	mov	x24, x4
     7d8: 9a9f77e6     	cset	x6, vs
     7dc: 72001cdf     	tst	w6, #0xff
     7e0: 540011e1     	b.ne	0xa1c <___pl_fn_3+0x2a4>
     7e4: d2800027     	mov	x7, #0x1                ; =1
     7e8: aa1703e1     	mov	x1, x23
     7ec: eb070022     	subs	x2, x1, x7
     7f0: 9a9f77e8     	cset	x8, vs
     7f4: 72001d1f     	tst	w8, #0xff
     7f8: 54000fc1     	b.ne	0x9f0 <___pl_fn_3+0x278>
     7fc: aa1403e1     	mov	x1, x20
     800: b9401429     	ldr	w9, [x1, #0x14]
     804: 1100040a     	add	w10, w0, #0x1
     808: 6b09015f     	cmp	w10, w9
     80c: 54000dc2     	b.hs	0x9c4 <___pl_fn_3+0x24c>
     810: aa1403e0     	mov	x0, x20
     814: aa1a03e1     	mov	x1, x26
     818: aa1503e3     	mov	x3, x21
     81c: aa1303e4     	mov	x4, x19
     820: aa1603e5     	mov	x5, x22
     824: 94000000     	bl	0x824 <___pl_fn_3+0xac>
     828: aa1403e0     	mov	x0, x20
     82c: b9402c0c     	ldr	w12, [x0, #0x2c]
     830: 3500122c     	cbnz	w12, 0xa74 <___pl_fn_3+0x2fc>
     834: aa1403e0     	mov	x0, x20
     838: b940100e     	ldr	w14, [x0, #0x10]
     83c: b940140f     	ldr	w15, [x0, #0x14]
     840: 6b0f01df     	cmp	w14, w15
     844: 54000aa2     	b.hs	0x998 <___pl_fn_3+0x220>
     848: aa1503e2     	mov	x2, x21
     84c: aa1403e0     	mov	x0, x20
     850: aa1a03e1     	mov	x1, x26
     854: aa1803e3     	mov	x3, x24
     858: aa1603e4     	mov	x4, x22
     85c: 94000000     	bl	0x85c <___pl_fn_3+0xe4>
     860: aa1403e0     	mov	x0, x20
     864: b9402c00     	ldr	w0, [x0, #0x2c]
     868: 35001060     	cbnz	w0, 0xa74 <___pl_fn_3+0x2fc>
     86c: d2800020     	mov	x0, #0x1                ; =1
     870: aa1703e2     	mov	x2, x23
     874: eb000042     	subs	x2, x2, x0
     878: 9a9f77e0     	cset	x0, vs
     87c: 72001c1f     	tst	w0, #0xff
     880: 54000761     	b.ne	0x96c <___pl_fn_3+0x1f4>
     884: aa1403e0     	mov	x0, x20
     888: b9401000     	ldr	w0, [x0, #0x10]
     88c: aa1403e1     	mov	x1, x20
     890: b9401421     	ldr	w1, [x1, #0x14]
     894: 6b01001f     	cmp	w0, w1
     898: 54000542     	b.hs	0x940 <___pl_fn_3+0x1c8>
     89c: aa1a03e1     	mov	x1, x26
     8a0: aa1803e4     	mov	x4, x24
     8a4: aa1603e5     	mov	x5, x22
     8a8: aa1403e0     	mov	x0, x20
     8ac: aa1303e3     	mov	x3, x19
     8b0: 94000000     	bl	0x8b0 <___pl_fn_3+0x138>
     8b4: aa1403e0     	mov	x0, x20
     8b8: b9402c00     	ldr	w0, [x0, #0x2c]
     8bc: 35000dc0     	cbnz	w0, 0xa74 <___pl_fn_3+0x2fc>
     8c0: 52800020     	mov	w0, #0x1                ; =1
     8c4: aa1403e1     	mov	x1, x20
     8c8: 14000013     	b	0x914 <___pl_fn_3+0x19c>
     8cc: aa1403e1     	mov	x1, x20
     8d0: aa0303e2     	mov	x2, x3
     8d4: aa0403f8     	mov	x24, x4
     8d8: b9401421     	ldr	w1, [x1, #0x14]
     8dc: 11000400     	add	w0, w0, #0x1
     8e0: 6b01001f     	cmp	w0, w1
     8e4: 54000d42     	b.hs	0xa8c <___pl_fn_3+0x314>
     8e8: aa1a03e1     	mov	x1, x26
     8ec: aa1803e3     	mov	x3, x24
     8f0: aa1603e4     	mov	x4, x22
     8f4: aa1403e0     	mov	x0, x20
     8f8: 94000000     	bl	0x8f8 <___pl_fn_3+0x180>
     8fc: aa1403e0     	mov	x0, x20
     900: b9402c00     	ldr	w0, [x0, #0x2c]
     904: 35000b80     	cbnz	w0, 0xa74 <___pl_fn_3+0x2fc>
     908: d2800013     	mov	x19, #0x0               ; =0
     90c: 52800000     	mov	w0, #0x0                ; =0
     910: aa1403e1     	mov	x1, x20
     914: aa1403e1     	mov	x1, x20
     918: b9401020     	ldr	w0, [x1, #0x10]
     91c: 51000400     	sub	w0, w0, #0x1
     920: b9001020     	str	w0, [x1, #0x10]
     924: a8c153f3     	ldp	x19, x20, [sp], #0x10
     928: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     92c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     930: f84107fa     	ldr	x26, [sp], #0x10
     934: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     938: d65f03c0     	ret
     93c: 1400004e     	b	0xa74 <___pl_fn_3+0x2fc>
     940: 528002e1     	mov	w1, #0x17               ; =23
     944: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     948: f9400042     	ldr	x2, [x2]
     94c: aa1403e0     	mov	x0, x20
     950: d63f0040     	blr	x2
     954: a8c153f3     	ldp	x19, x20, [sp], #0x10
     958: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     95c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     960: f84107fa     	ldr	x26, [sp], #0x10
     964: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     968: d65f03c0     	ret
     96c: 528002c1     	mov	w1, #0x16               ; =22
     970: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     974: f9400042     	ldr	x2, [x2]
     978: aa1403e0     	mov	x0, x20
     97c: d63f0040     	blr	x2
     980: a8c153f3     	ldp	x19, x20, [sp], #0x10
     984: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     988: a8c163f7     	ldp	x23, x24, [sp], #0x10
     98c: f84107fa     	ldr	x26, [sp], #0x10
     990: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     994: d65f03c0     	ret
     998: 528002a1     	mov	w1, #0x15               ; =21
     99c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9a0: f9400042     	ldr	x2, [x2]
     9a4: aa1403e0     	mov	x0, x20
     9a8: d63f0040     	blr	x2
     9ac: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9b0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9b4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9b8: f84107fa     	ldr	x26, [sp], #0x10
     9bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9c0: d65f03c0     	ret
     9c4: 52800281     	mov	w1, #0x14               ; =20
     9c8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9cc: f9400042     	ldr	x2, [x2]
     9d0: aa1403e0     	mov	x0, x20
     9d4: d63f0040     	blr	x2
     9d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9e0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9e4: f84107fa     	ldr	x26, [sp], #0x10
     9e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9ec: d65f03c0     	ret
     9f0: 52800261     	mov	w1, #0x13               ; =19
     9f4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9f8: f9400042     	ldr	x2, [x2]
     9fc: aa1403e0     	mov	x0, x20
     a00: d63f0040     	blr	x2
     a04: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a08: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a0c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a10: f84107fa     	ldr	x26, [sp], #0x10
     a14: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a18: d65f03c0     	ret
     a1c: 52800241     	mov	w1, #0x12               ; =18
     a20: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a24: f9400042     	ldr	x2, [x2]
     a28: aa1403e0     	mov	x0, x20
     a2c: d63f0040     	blr	x2
     a30: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a34: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a38: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a3c: f84107fa     	ldr	x26, [sp], #0x10
     a40: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a44: d65f03c0     	ret
     a48: 52800221     	mov	w1, #0x11               ; =17
     a4c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a50: f9400042     	ldr	x2, [x2]
     a54: aa1403e0     	mov	x0, x20
     a58: d63f0040     	blr	x2
     a5c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a60: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a64: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a68: f84107fa     	ldr	x26, [sp], #0x10
     a6c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a70: d65f03c0     	ret
     a74: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a78: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a7c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a80: f84107fa     	ldr	x26, [sp], #0x10
     a84: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a88: d65f03c0     	ret
     a8c: 52800301     	mov	w1, #0x18               ; =24
     a90: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a94: f9400042     	ldr	x2, [x2]
     a98: aa1403e0     	mov	x0, x20
     a9c: d63f0040     	blr	x2
     aa0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     aa4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     aa8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     aac: f84107fa     	ldr	x26, [sp], #0x10
     ab0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ab4: d65f03c0     	ret

0000000000000ab8 <___pl_fn_4>:
     ab8: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     abc: 910003fd     	mov	x29, sp
     ac0: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
     ac4: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
     ac8: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     acc: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     ad0: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     ad4: d100c3ff     	sub	sp, sp, #0x30
     ad8: b9401001     	ldr	w1, [x0, #0x10]
     adc: 11000421     	add	w1, w1, #0x1
     ae0: b9001001     	str	w1, [x0, #0x10]
     ae4: aa0003fa     	mov	x26, x0
     ae8: 52800321     	mov	w1, #0x19               ; =25
     aec: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     af0: f9400042     	ldr	x2, [x2]
     af4: d63f0040     	blr	x2
     af8: 35004c60     	cbnz	w0, 0x1484 <___pl_fn_4+0x9cc>
     afc: aa1a03e0     	mov	x0, x26
     b00: f9401802     	ldr	x2, [x0, #0x30]
     b04: aa0203fb     	mov	x27, x2
     b08: d2800060     	mov	x0, #0x3                ; =3
     b0c: 910003e3     	mov	x3, sp
     b10: f80003e0     	stur	x0, [sp]
     b14: 52800341     	mov	w1, #0x1a               ; =26
     b18: 52802082     	mov	w2, #0x104              ; =260
     b1c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b20: f9400084     	ldr	x4, [x4]
     b24: aa1a03e0     	mov	x0, x26
     b28: d63f0080     	blr	x4
     b2c: 35004ac0     	cbnz	w0, 0x1484 <___pl_fn_4+0x9cc>
     b30: aa1a03e0     	mov	x0, x26
     b34: f9401813     	ldr	x19, [x0, #0x30]
     b38: 52800361     	mov	w1, #0x1b               ; =27
     b3c: 52800082     	mov	w2, #0x4                ; =4
     b40: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b44: f9400063     	ldr	x3, [x3]
     b48: d63f0060     	blr	x3
     b4c: 350049c0     	cbnz	w0, 0x1484 <___pl_fn_4+0x9cc>
     b50: aa1a03e0     	mov	x0, x26
     b54: f9401815     	ldr	x21, [x0, #0x30]
     b58: f9402403     	ldr	x3, [x0, #0x48]
     b5c: 2a1503f4     	mov	w20, w21
     b60: d1000684     	sub	x4, x20, #0x1
     b64: eb03009f     	cmp	x4, x3
     b68: 54002f42     	b.hs	0x1150 <___pl_fn_4+0x698>
     b6c: aa1a03e0     	mov	x0, x26
     b70: f9402006     	ldr	x6, [x0, #0x40]
     b74: d2800607     	mov	x7, #0x30               ; =48
     b78: d1000689     	sub	x9, x20, #0x1
     b7c: 9b077d28     	mul	x8, x9, x7
     b80: 9b071927     	madd	x7, x9, x7, x6
     b84: f94008e9     	ldr	x9, [x7, #0x10]
     b88: b4002e49     	cbz	x9, 0x1150 <___pl_fn_4+0x698>
     b8c: aa1503fc     	mov	x28, x21
     b90: 2a1303eb     	mov	w11, w19
     b94: f82868cb     	str	x11, [x6, x8]
     b98: 7100027f     	cmp	w19, #0x0
     b9c: 9a9f07ed     	cset	x13, ne
     ba0: f90004ed     	str	x13, [x7, #0x8]
     ba4: 528003a1     	mov	w1, #0x1d               ; =29
     ba8: 52800013     	mov	w19, #0x0               ; =0
     bac: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     bb0: f94001ef     	ldr	x15, [x15]
     bb4: aa1a03e0     	mov	x0, x26
     bb8: aa1303e2     	mov	x2, x19
     bbc: d63f01e0     	blr	x15
     bc0: 35004620     	cbnz	w0, 0x1484 <___pl_fn_4+0x9cc>
     bc4: aa1a03e0     	mov	x0, x26
     bc8: f9401802     	ldr	x2, [x0, #0x30]
     bcc: f80203e2     	stur	x2, [sp, #0x20]
     bd0: 528003c1     	mov	w1, #0x1e               ; =30
     bd4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     bd8: f9400063     	ldr	x3, [x3]
     bdc: aa1303e2     	mov	x2, x19
     be0: d63f0060     	blr	x3
     be4: 35004500     	cbnz	w0, 0x1484 <___pl_fn_4+0x9cc>
     be8: aa1a03e0     	mov	x0, x26
     bec: f9401802     	ldr	x2, [x0, #0x30]
     bf0: aa0203f9     	mov	x25, x2
     bf4: d2800015     	mov	x21, #0x0               ; =0
     bf8: 52800029     	mov	w9, #0x1                ; =1
     bfc: f1000abf     	cmp	x21, #0x2
     c00: 9a9fc7ee     	cset	x14, le
     c04: 72001ddf     	tst	w14, #0xff
     c08: 54001a01     	b.ne	0xf48 <___pl_fn_4+0x490>
     c0c: 52800035     	mov	w21, #0x1               ; =1
     c10: aa1903f6     	mov	x22, x25
     c14: f10002df     	cmp	x22, #0x0
     c18: 9a9fd7e0     	cset	x0, gt
     c1c: 72001c1f     	tst	w0, #0xff
     c20: 54000a41     	b.ne	0xd68 <___pl_fn_4+0x2b0>
     c24: aa1a03e0     	mov	x0, x26
     c28: f9402400     	ldr	x0, [x0, #0x48]
     c2c: f84203e2     	ldur	x2, [sp, #0x20]
     c30: 2a0203e1     	mov	w1, w2
     c34: d1000433     	sub	x19, x1, #0x1
     c38: eb00027f     	cmp	x19, x0
     c3c: 540029e2     	b.hs	0x1178 <___pl_fn_4+0x6c0>
     c40: aa1a03e0     	mov	x0, x26
     c44: f9402000     	ldr	x0, [x0, #0x40]
     c48: d2800601     	mov	x1, #0x30               ; =48
     c4c: 9b017e62     	mul	x2, x19, x1
     c50: 9b010261     	madd	x1, x19, x1, x0
     c54: f9400823     	ldr	x3, [x1, #0x10]
     c58: b5000083     	cbnz	x3, 0xc68 <___pl_fn_4+0x1b0>
     c5c: 14000147     	b	0x1178 <___pl_fn_4+0x6c0>
     c60: aa1a03e0     	mov	x0, x26
     c64: 14000006     	b	0xc7c <___pl_fn_4+0x1c4>
     c68: d2800003     	mov	x3, #0x0                ; =0
     c6c: f8226803     	str	x3, [x0, x2]
     c70: d2800020     	mov	x0, #0x1                ; =1
     c74: f9000420     	str	x0, [x1, #0x8]
     c78: aa1a03e0     	mov	x0, x26
     c7c: aa1a03e0     	mov	x0, x26
     c80: b9401000     	ldr	w0, [x0, #0x10]
     c84: aa1a03e1     	mov	x1, x26
     c88: b9401421     	ldr	w1, [x1, #0x14]
     c8c: 6b01001f     	cmp	w0, w1
     c90: 54002962     	b.hs	0x11bc <___pl_fn_4+0x704>
     c94: d2800003     	mov	x3, #0x0                ; =0
     c98: d2800024     	mov	x4, #0x1                ; =1
     c9c: aa1c03e1     	mov	x1, x28
     ca0: aa1903e2     	mov	x2, x25
     ca4: aa1a03e0     	mov	x0, x26
     ca8: f84203e5     	ldur	x5, [sp, #0x20]
     cac: 94000000     	bl	0xcac <___pl_fn_4+0x1f4>
     cb0: aa1a03e0     	mov	x0, x26
     cb4: b9402c00     	ldr	w0, [x0, #0x2c]
     cb8: 35003e60     	cbnz	w0, 0x1484 <___pl_fn_4+0x9cc>
     cbc: aa1a03e0     	mov	x0, x26
     cc0: f9402400     	ldr	x0, [x0, #0x48]
     cc4: eb00027f     	cmp	x19, x0
     cc8: 540026a2     	b.hs	0x119c <___pl_fn_4+0x6e4>
     ccc: aa1a03e0     	mov	x0, x26
     cd0: f9402000     	ldr	x0, [x0, #0x40]
     cd4: d2800602     	mov	x2, #0x30               ; =48
     cd8: 9b027e61     	mul	x1, x19, x2
     cdc: 9b020262     	madd	x2, x19, x2, x0
     ce0: f9400442     	ldr	x2, [x2, #0x8]
     ce4: b50000a2     	cbnz	x2, 0xcf8 <___pl_fn_4+0x240>
     ce8: 1400012d     	b	0x119c <___pl_fn_4+0x6e4>
     cec: aa1a03e0     	mov	x0, x26
     cf0: f9401802     	ldr	x2, [x0, #0x30]
     cf4: 14000002     	b	0xcfc <___pl_fn_4+0x244>
     cf8: f8616802     	ldr	x2, [x0, x1]
     cfc: 52800481     	mov	w1, #0x24               ; =36
     d00: 52802003     	mov	w3, #0x100              ; =256
     d04: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     d08: f9400084     	ldr	x4, [x4]
     d0c: aa1a03e0     	mov	x0, x26
     d10: d63f0080     	blr	x4
     d14: 35003b80     	cbnz	w0, 0x1484 <___pl_fn_4+0x9cc>
     d18: 528004a1     	mov	w1, #0x25               ; =37
     d1c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     d20: f9400063     	ldr	x3, [x3]
     d24: aa1b03e2     	mov	x2, x27
     d28: aa1a03e0     	mov	x0, x26
     d2c: d63f0060     	blr	x3
     d30: 35003aa0     	cbnz	w0, 0x1484 <___pl_fn_4+0x9cc>
     d34: aa1a03e0     	mov	x0, x26
     d38: b9401000     	ldr	w0, [x0, #0x10]
     d3c: 51000400     	sub	w0, w0, #0x1
     d40: aa1a03e1     	mov	x1, x26
     d44: b9001020     	str	w0, [x1, #0x10]
     d48: 9100c3ff     	add	sp, sp, #0x30
     d4c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d50: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d54: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d58: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d5c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     d60: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d64: d65f03c0     	ret
     d68: aa1a03e0     	mov	x0, x26
     d6c: f9403c02     	ldr	x2, [x0, #0x78]
     d70: 37202402     	tbnz	w2, #0x4, 0x11f0 <___pl_fn_4+0x738>
     d74: aa1a03e0     	mov	x0, x26
     d78: f9403804     	ldr	x4, [x0, #0x70]
     d7c: f100009f     	cmp	x4, #0x0
     d80: 5400238d     	b.le	0x11f0 <___pl_fn_4+0x738>
     d84: aa1a03e0     	mov	x0, x26
     d88: f9403407     	ldr	x7, [x0, #0x68]
     d8c: f1000cff     	cmp	x7, #0x3
     d90: 5400230b     	b.lt	0x11f0 <___pl_fn_4+0x738>
     d94: aa1a03e0     	mov	x0, x26
     d98: f9402814     	ldr	x20, [x0, #0x50]
     d9c: f9402c0a     	ldr	x10, [x0, #0x58]
     da0: 9100128b     	add	x11, x20, #0x4
     da4: eb0a017f     	cmp	x11, x10
     da8: 54002248     	b.hi	0x11f0 <___pl_fn_4+0x738>
     dac: aa1a03e0     	mov	x0, x26
     db0: f940440d     	ldr	x13, [x0, #0x88]
     db4: f940480e     	ldr	x14, [x0, #0x90]
     db8: eb0e01bf     	cmp	x13, x14
     dbc: 540000a3     	b.lo	0xdd0 <___pl_fn_4+0x318>
     dc0: 1400010c     	b	0x11f0 <___pl_fn_4+0x738>
     dc4: aa1a03e0     	mov	x0, x26
     dc8: f9401814     	ldr	x20, [x0, #0x30]
     dcc: 14000026     	b	0xe64 <___pl_fn_4+0x3ac>
     dd0: aa1a03e0     	mov	x0, x26
     dd4: f9403002     	ldr	x2, [x0, #0x60]
     dd8: f9400003     	ldr	x3, [x0]
     ddc: d2800065     	mov	x5, #0x3                ; =3
     de0: f2c00045     	movk	x5, #0x2, lsl #32
     de4: 2a1403e1     	mov	w1, w20
     de8: d2800060     	mov	x0, #0x3                ; =3
     dec: 8b010c64     	add	x4, x3, x1, lsl #3
     df0: f8345865     	str	x5, [x3, w20, uxtw #3]
     df4: 91000442     	add	x2, x2, #0x1
     df8: f9000482     	str	x2, [x4, #0x8]
     dfc: d2800003     	mov	x3, #0x0                ; =0
     e00: f9000883     	str	x3, [x4, #0x10]
     e04: f9000c83     	str	x3, [x4, #0x18]
     e08: aa1a03e3     	mov	x3, x26
     e0c: f9003062     	str	x2, [x3, #0x60]
     e10: 91001282     	add	x2, x20, #0x4
     e14: f9002862     	str	x2, [x3, #0x50]
     e18: aa1a03e2     	mov	x2, x26
     e1c: f9403442     	ldr	x2, [x2, #0x68]
     e20: d1000c42     	sub	x2, x2, #0x3
     e24: f9003462     	str	x2, [x3, #0x68]
     e28: aa1a03e2     	mov	x2, x26
     e2c: f9403842     	ldr	x2, [x2, #0x70]
     e30: d1000c42     	sub	x2, x2, #0x3
     e34: f9003862     	str	x2, [x3, #0x70]
     e38: aa1a03e2     	mov	x2, x26
     e3c: f9404042     	ldr	x2, [x2, #0x80]
     e40: b25e0021     	orr	x1, x1, #0x400000000
     e44: d37ceda3     	lsl	x3, x13, #4
     e48: 8b0d1044     	add	x4, x2, x13, lsl #4
     e4c: f8236841     	str	x1, [x2, x3]
     e50: f9000480     	str	x0, [x4, #0x8]
     e54: 910005a0     	add	x0, x13, #0x1
     e58: aa1a03e1     	mov	x1, x26
     e5c: f9004420     	str	x0, [x1, #0x88]
     e60: aa1a03e0     	mov	x0, x26
     e64: aa1a03e0     	mov	x0, x26
     e68: b9401817     	ldr	w23, [x0, #0x18]
     e6c: b9401c00     	ldr	w0, [x0, #0x1c]
     e70: 110006f8     	add	w24, w23, #0x1
     e74: 6b00031f     	cmp	w24, w0
     e78: 540024e8     	b.hi	0x1314 <___pl_fn_4+0x85c>
     e7c: aa1a03e0     	mov	x0, x26
     e80: f9401000     	ldr	x0, [x0, #0x20]
     e84: b8375814     	str	w20, [x0, w23, uxtw #2]
     e88: aa1a03e0     	mov	x0, x26
     e8c: b9001818     	str	w24, [x0, #0x18]
     e90: b9401000     	ldr	w0, [x0, #0x10]
     e94: aa1a03e1     	mov	x1, x26
     e98: b9401421     	ldr	w1, [x1, #0x14]
     e9c: 6b01001f     	cmp	w0, w1
     ea0: 54002202     	b.hs	0x12e0 <___pl_fn_4+0x828>
     ea4: 72001ebf     	tst	w21, #0xff
     ea8: 54002020     	b.eq	0x12ac <___pl_fn_4+0x7f4>
     eac: aa1a03e0     	mov	x0, x26
     eb0: aa1403e1     	mov	x1, x20
     eb4: aa1603e2     	mov	x2, x22
     eb8: 94000000     	bl	0xeb8 <___pl_fn_4+0x400>
     ebc: aa1a03e0     	mov	x0, x26
     ec0: aa1403e3     	mov	x3, x20
     ec4: b9402c00     	ldr	w0, [x0, #0x2c]
     ec8: 35002de0     	cbnz	w0, 0x1484 <___pl_fn_4+0x9cc>
     ecc: aa1a03e0     	mov	x0, x26
     ed0: b9001817     	str	w23, [x0, #0x18]
     ed4: b9401c00     	ldr	w0, [x0, #0x1c]
     ed8: 6b00031f     	cmp	w24, w0
     edc: 54001ce8     	b.hi	0x1278 <___pl_fn_4+0x7c0>
     ee0: aa1a03e0     	mov	x0, x26
     ee4: f9401000     	ldr	x0, [x0, #0x20]
     ee8: b8375803     	str	w3, [x0, w23, uxtw #2]
     eec: aa1a03e0     	mov	x0, x26
     ef0: b9001818     	str	w24, [x0, #0x18]
     ef4: b9401000     	ldr	w0, [x0, #0x10]
     ef8: aa1a03e1     	mov	x1, x26
     efc: b9401421     	ldr	w1, [x1, #0x14]
     f00: 6b01001f     	cmp	w0, w1
     f04: 54001a02     	b.hs	0x1244 <___pl_fn_4+0x78c>
     f08: d2800002     	mov	x2, #0x0                ; =0
     f0c: aa1a03e0     	mov	x0, x26
     f10: aa1c03e1     	mov	x1, x28
     f14: 94000000     	bl	0xf14 <___pl_fn_4+0x45c>
     f18: aa1a03e0     	mov	x0, x26
     f1c: b9402c00     	ldr	w0, [x0, #0x2c]
     f20: 35002b20     	cbnz	w0, 0x1484 <___pl_fn_4+0x9cc>
     f24: aa1a03e0     	mov	x0, x26
     f28: b9001817     	str	w23, [x0, #0x18]
     f2c: 92800000     	mov	x0, #-0x1               ; =-1
     f30: ab0002d6     	adds	x22, x22, x0
     f34: 9a9f77e0     	cset	x0, vs
     f38: 72001c1f     	tst	w0, #0xff
     f3c: 540016a1     	b.ne	0x1210 <___pl_fn_4+0x758>
     f40: 52800035     	mov	w21, #0x1               ; =1
     f44: 17ffff34     	b	0xc14 <___pl_fn_4+0x15c>
     f48: d2800037     	mov	x23, #0x1               ; =1
     f4c: aa1903f6     	mov	x22, x25
     f50: ab1702c2     	adds	x2, x22, x23
     f54: f80183e2     	stur	x2, [sp, #0x18]
     f58: 9a9f77e0     	cset	x0, vs
     f5c: 72001c1f     	tst	w0, #0xff
     f60: 54002781     	b.ne	0x1450 <___pl_fn_4+0x998>
     f64: aa1a03e0     	mov	x0, x26
     f68: f9403c01     	ldr	x1, [x0, #0x78]
     f6c: 37201ee1     	tbnz	w1, #0x4, 0x1348 <___pl_fn_4+0x890>
     f70: aa1a03e0     	mov	x0, x26
     f74: f9403803     	ldr	x3, [x0, #0x70]
     f78: f100007f     	cmp	x3, #0x0
     f7c: 54001e6d     	b.le	0x1348 <___pl_fn_4+0x890>
     f80: aa1a03e0     	mov	x0, x26
     f84: f9403406     	ldr	x6, [x0, #0x68]
     f88: f1000cdf     	cmp	x6, #0x3
     f8c: 54001deb     	b.lt	0x1348 <___pl_fn_4+0x890>
     f90: aa1a03e0     	mov	x0, x26
     f94: f9402818     	ldr	x24, [x0, #0x50]
     f98: f9402c09     	ldr	x9, [x0, #0x58]
     f9c: 9100130a     	add	x10, x24, #0x4
     fa0: eb09015f     	cmp	x10, x9
     fa4: 54001d28     	b.hi	0x1348 <___pl_fn_4+0x890>
     fa8: aa1a03e0     	mov	x0, x26
     fac: f940440c     	ldr	x12, [x0, #0x88]
     fb0: f940480d     	ldr	x13, [x0, #0x90]
     fb4: eb0d019f     	cmp	x12, x13
     fb8: 540000a3     	b.lo	0xfcc <___pl_fn_4+0x514>
     fbc: 140000e3     	b	0x1348 <___pl_fn_4+0x890>
     fc0: aa1a03e0     	mov	x0, x26
     fc4: f9401818     	ldr	x24, [x0, #0x30]
     fc8: 14000026     	b	0x1060 <___pl_fn_4+0x5a8>
     fcc: aa1a03e0     	mov	x0, x26
     fd0: f9403002     	ldr	x2, [x0, #0x60]
     fd4: f9400003     	ldr	x3, [x0]
     fd8: d2800065     	mov	x5, #0x3                ; =3
     fdc: f2c00045     	movk	x5, #0x2, lsl #32
     fe0: 2a1803e1     	mov	w1, w24
     fe4: d2800060     	mov	x0, #0x3                ; =3
     fe8: 8b010c64     	add	x4, x3, x1, lsl #3
     fec: f8385865     	str	x5, [x3, w24, uxtw #3]
     ff0: 91000442     	add	x2, x2, #0x1
     ff4: f9000482     	str	x2, [x4, #0x8]
     ff8: d2800003     	mov	x3, #0x0                ; =0
     ffc: f9000883     	str	x3, [x4, #0x10]
    1000: f9000c83     	str	x3, [x4, #0x18]
    1004: aa1a03e3     	mov	x3, x26
    1008: f9003062     	str	x2, [x3, #0x60]
    100c: 91001302     	add	x2, x24, #0x4
    1010: f9002862     	str	x2, [x3, #0x50]
    1014: aa1a03e2     	mov	x2, x26
    1018: f9403442     	ldr	x2, [x2, #0x68]
    101c: d1000c42     	sub	x2, x2, #0x3
    1020: f9003462     	str	x2, [x3, #0x68]
    1024: aa1a03e2     	mov	x2, x26
    1028: f9403842     	ldr	x2, [x2, #0x70]
    102c: d1000c42     	sub	x2, x2, #0x3
    1030: f9003862     	str	x2, [x3, #0x70]
    1034: aa1a03e2     	mov	x2, x26
    1038: f9404042     	ldr	x2, [x2, #0x80]
    103c: b25e0021     	orr	x1, x1, #0x400000000
    1040: d37ced83     	lsl	x3, x12, #4
    1044: 8b0c1044     	add	x4, x2, x12, lsl #4
    1048: f8236841     	str	x1, [x2, x3]
    104c: f9000480     	str	x0, [x4, #0x8]
    1050: 91000580     	add	x0, x12, #0x1
    1054: aa1a03e1     	mov	x1, x26
    1058: f9004420     	str	x0, [x1, #0x88]
    105c: aa1a03e0     	mov	x0, x26
    1060: aa1a03e0     	mov	x0, x26
    1064: b9401819     	ldr	w25, [x0, #0x18]
    1068: b9401c01     	ldr	w1, [x0, #0x1c]
    106c: 11000720     	add	w0, w25, #0x1
    1070: 6b01001f     	cmp	w0, w1
    1074: 54001d48     	b.hi	0x141c <___pl_fn_4+0x964>
    1078: aa1a03e1     	mov	x1, x26
    107c: f9401021     	ldr	x1, [x1, #0x20]
    1080: b8395838     	str	w24, [x1, w25, uxtw #2]
    1084: aa1a03e1     	mov	x1, x26
    1088: b9001820     	str	w0, [x1, #0x18]
    108c: aa1a03e0     	mov	x0, x26
    1090: b9401000     	ldr	w0, [x0, #0x10]
    1094: b9401421     	ldr	w1, [x1, #0x14]
    1098: 6b01001f     	cmp	w0, w1
    109c: 54001a62     	b.hs	0x13e8 <___pl_fn_4+0x930>
    10a0: f84183e2     	ldur	x2, [sp, #0x18]
    10a4: aa1a03e0     	mov	x0, x26
    10a8: aa1803e1     	mov	x1, x24
    10ac: 94000000     	bl	0x10ac <___pl_fn_4+0x5f4>
    10b0: aa1a03e0     	mov	x0, x26
    10b4: b9402c00     	ldr	w0, [x0, #0x2c]
    10b8: 35001e60     	cbnz	w0, 0x1484 <___pl_fn_4+0x9cc>
    10bc: aa1a03e0     	mov	x0, x26
    10c0: b9001819     	str	w25, [x0, #0x18]
    10c4: f9402400     	ldr	x0, [x0, #0x48]
    10c8: d1000681     	sub	x1, x20, #0x1
    10cc: eb00003f     	cmp	x1, x0
    10d0: 540014c2     	b.hs	0x1368 <___pl_fn_4+0x8b0>
    10d4: aa1a03e0     	mov	x0, x26
    10d8: f9402000     	ldr	x0, [x0, #0x40]
    10dc: d2800602     	mov	x2, #0x30               ; =48
    10e0: d1000683     	sub	x3, x20, #0x1
    10e4: 9b027c61     	mul	x1, x3, x2
    10e8: 9b020062     	madd	x2, x3, x2, x0
    10ec: f9400442     	ldr	x2, [x2, #0x8]
    10f0: b50000a2     	cbnz	x2, 0x1104 <___pl_fn_4+0x64c>
    10f4: 1400009d     	b	0x1368 <___pl_fn_4+0x8b0>
    10f8: aa1a03e0     	mov	x0, x26
    10fc: f9401802     	ldr	x2, [x0, #0x30]
    1100: 14000002     	b	0x1108 <___pl_fn_4+0x650>
    1104: f8616802     	ldr	x2, [x0, x1]
    1108: 34001402     	cbz	w2, 0x1388 <___pl_fn_4+0x8d0>
    110c: aa1a03e0     	mov	x0, x26
    1110: f9400000     	ldr	x0, [x0]
    1114: 2a0203e1     	mov	w1, w2
    1118: 8b010c00     	add	x0, x0, x1, lsl #3
    111c: f9400801     	ldr	x1, [x0, #0x10]
    1120: eb0102bf     	cmp	x21, x1
    1124: 54001322     	b.hs	0x1388 <___pl_fn_4+0x8d0>
    1128: 2a1803e1     	mov	w1, w24
    112c: 8b150c00     	add	x0, x0, x21, lsl #3
    1130: f9001401     	str	x1, [x0, #0x28]
    1134: ab1702b5     	adds	x21, x21, x23
    1138: 9a9f77e0     	cset	x0, vs
    113c: 72001c1f     	tst	w0, #0xff
    1140: 540013a1     	b.ne	0x13b4 <___pl_fn_4+0x8fc>
    1144: 52800029     	mov	w9, #0x1                ; =1
    1148: aa1603f9     	mov	x25, x22
    114c: 17fffeac     	b	0xbfc <___pl_fn_4+0x144>
    1150: 52800381     	mov	w1, #0x1c               ; =28
    1154: 2a1303e3     	mov	w3, w19
    1158: 90000008     	adrp	x8, 0x1000 <___pl_fn_4+0x548>
    115c: f9400108     	ldr	x8, [x8]
    1160: aa1a03e0     	mov	x0, x26
    1164: aa1503e2     	mov	x2, x21
    1168: d63f0100     	blr	x8
    116c: aa1503fc     	mov	x28, x21
    1170: 34ffd1a0     	cbz	w0, 0xba4 <___pl_fn_4+0xec>
    1174: 140000c4     	b	0x1484 <___pl_fn_4+0x9cc>
    1178: 52800421     	mov	w1, #0x21               ; =33
    117c: d2800003     	mov	x3, #0x0                ; =0
    1180: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x548>
    1184: f9400084     	ldr	x4, [x4]
    1188: aa1a03e0     	mov	x0, x26
    118c: f84203e2     	ldur	x2, [sp, #0x20]
    1190: d63f0080     	blr	x4
    1194: 34ffd660     	cbz	w0, 0xc60 <___pl_fn_4+0x1a8>
    1198: 140000bb     	b	0x1484 <___pl_fn_4+0x9cc>
    119c: 52800461     	mov	w1, #0x23               ; =35
    11a0: 90000003     	adrp	x3, 0x1000 <___pl_fn_4+0x548>
    11a4: f9400063     	ldr	x3, [x3]
    11a8: f84203e2     	ldur	x2, [sp, #0x20]
    11ac: aa1a03e0     	mov	x0, x26
    11b0: d63f0060     	blr	x3
    11b4: 34ffd9c0     	cbz	w0, 0xcec <___pl_fn_4+0x234>
    11b8: 140000b3     	b	0x1484 <___pl_fn_4+0x9cc>
    11bc: 52800441     	mov	w1, #0x22               ; =34
    11c0: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x548>
    11c4: f9400042     	ldr	x2, [x2]
    11c8: aa1a03e0     	mov	x0, x26
    11cc: d63f0040     	blr	x2
    11d0: 9100c3ff     	add	sp, sp, #0x30
    11d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    11dc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    11e0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    11e4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    11e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11ec: d65f03c0     	ret
    11f0: 528004c1     	mov	w1, #0x26               ; =38
    11f4: 90000003     	adrp	x3, 0x1000 <___pl_fn_4+0x548>
    11f8: f9400063     	ldr	x3, [x3]
    11fc: aa1a03e0     	mov	x0, x26
    1200: aa1303e2     	mov	x2, x19
    1204: d63f0060     	blr	x3
    1208: 34ffdde0     	cbz	w0, 0xdc4 <___pl_fn_4+0x30c>
    120c: 1400009e     	b	0x1484 <___pl_fn_4+0x9cc>
    1210: 52800581     	mov	w1, #0x2c               ; =44
    1214: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x548>
    1218: f9400042     	ldr	x2, [x2]
    121c: aa1a03e0     	mov	x0, x26
    1220: d63f0040     	blr	x2
    1224: 9100c3ff     	add	sp, sp, #0x30
    1228: a8c153f3     	ldp	x19, x20, [sp], #0x10
    122c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1230: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1234: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1238: a8c173fb     	ldp	x27, x28, [sp], #0x10
    123c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1240: d65f03c0     	ret
    1244: 52800561     	mov	w1, #0x2b               ; =43
    1248: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x548>
    124c: f9400042     	ldr	x2, [x2]
    1250: aa1a03e0     	mov	x0, x26
    1254: d63f0040     	blr	x2
    1258: 9100c3ff     	add	sp, sp, #0x30
    125c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1260: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1264: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1268: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    126c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1270: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1274: d65f03c0     	ret
    1278: 52800541     	mov	w1, #0x2a               ; =42
    127c: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x548>
    1280: f9400042     	ldr	x2, [x2]
    1284: aa1a03e0     	mov	x0, x26
    1288: d63f0040     	blr	x2
    128c: 9100c3ff     	add	sp, sp, #0x30
    1290: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1294: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1298: a8c163f7     	ldp	x23, x24, [sp], #0x10
    129c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    12a0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    12a4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12a8: d65f03c0     	ret
    12ac: 52800521     	mov	w1, #0x29               ; =41
    12b0: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x548>
    12b4: f9400042     	ldr	x2, [x2]
    12b8: aa1a03e0     	mov	x0, x26
    12bc: d63f0040     	blr	x2
    12c0: 9100c3ff     	add	sp, sp, #0x30
    12c4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    12c8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    12cc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    12d0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    12d4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    12d8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12dc: d65f03c0     	ret
    12e0: 52800501     	mov	w1, #0x28               ; =40
    12e4: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x548>
    12e8: f9400042     	ldr	x2, [x2]
    12ec: aa1a03e0     	mov	x0, x26
    12f0: d63f0040     	blr	x2
    12f4: 9100c3ff     	add	sp, sp, #0x30
    12f8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    12fc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1300: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1304: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1308: a8c173fb     	ldp	x27, x28, [sp], #0x10
    130c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1310: d65f03c0     	ret
    1314: 528004e1     	mov	w1, #0x27               ; =39
    1318: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x548>
    131c: f9400042     	ldr	x2, [x2]
    1320: aa1a03e0     	mov	x0, x26
    1324: d63f0040     	blr	x2
    1328: 9100c3ff     	add	sp, sp, #0x30
    132c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1330: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1334: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1338: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    133c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1340: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1344: d65f03c0     	ret
    1348: 528005c1     	mov	w1, #0x2e               ; =46
    134c: 9000000f     	adrp	x15, 0x1000 <___pl_fn_4+0x548>
    1350: f94001ef     	ldr	x15, [x15]
    1354: aa1a03e0     	mov	x0, x26
    1358: aa1303e2     	mov	x2, x19
    135c: d63f01e0     	blr	x15
    1360: 34ffe300     	cbz	w0, 0xfc0 <___pl_fn_4+0x508>
    1364: 14000048     	b	0x1484 <___pl_fn_4+0x9cc>
    1368: 52800621     	mov	w1, #0x31               ; =49
    136c: 90000003     	adrp	x3, 0x1000 <___pl_fn_4+0x548>
    1370: f9400063     	ldr	x3, [x3]
    1374: aa1a03e0     	mov	x0, x26
    1378: aa1c03e2     	mov	x2, x28
    137c: d63f0060     	blr	x3
    1380: 34ffebc0     	cbz	w0, 0x10f8 <___pl_fn_4+0x640>
    1384: 14000040     	b	0x1484 <___pl_fn_4+0x9cc>
    1388: 910023e3     	add	x3, sp, #0x8
    138c: f80083f5     	stur	x21, [sp, #0x8]
    1390: 2a1803e0     	mov	w0, w24
    1394: f80103e0     	stur	x0, [sp, #0x10]
    1398: 52800641     	mov	w1, #0x32               ; =50
    139c: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x548>
    13a0: f9400084     	ldr	x4, [x4]
    13a4: aa1a03e0     	mov	x0, x26
    13a8: d63f0080     	blr	x4
    13ac: 34ffec40     	cbz	w0, 0x1134 <___pl_fn_4+0x67c>
    13b0: 14000035     	b	0x1484 <___pl_fn_4+0x9cc>
    13b4: 52800661     	mov	w1, #0x33               ; =51
    13b8: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x548>
    13bc: f9400042     	ldr	x2, [x2]
    13c0: aa1a03e0     	mov	x0, x26
    13c4: d63f0040     	blr	x2
    13c8: 9100c3ff     	add	sp, sp, #0x30
    13cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    13d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    13d4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    13d8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    13dc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    13e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    13e4: d65f03c0     	ret
    13e8: 52800601     	mov	w1, #0x30               ; =48
    13ec: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x548>
    13f0: f9400042     	ldr	x2, [x2]
    13f4: aa1a03e0     	mov	x0, x26
    13f8: d63f0040     	blr	x2
    13fc: 9100c3ff     	add	sp, sp, #0x30
    1400: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1404: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1408: a8c163f7     	ldp	x23, x24, [sp], #0x10
    140c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1410: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1414: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1418: d65f03c0     	ret
    141c: 528005e1     	mov	w1, #0x2f               ; =47
    1420: 90000003     	adrp	x3, 0x1000 <___pl_fn_4+0x548>
    1424: f9400063     	ldr	x3, [x3]
    1428: aa1a03e0     	mov	x0, x26
    142c: d63f0060     	blr	x3
    1430: 9100c3ff     	add	sp, sp, #0x30
    1434: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1438: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    143c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1440: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1444: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1448: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    144c: d65f03c0     	ret
    1450: 528005a1     	mov	w1, #0x2d               ; =45
    1454: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x548>
    1458: f9400084     	ldr	x4, [x4]
    145c: aa1a03e0     	mov	x0, x26
    1460: d63f0080     	blr	x4
    1464: 9100c3ff     	add	sp, sp, #0x30
    1468: a8c153f3     	ldp	x19, x20, [sp], #0x10
    146c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1470: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1474: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1478: a8c173fb     	ldp	x27, x28, [sp], #0x10
    147c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1480: d65f03c0     	ret
    1484: 9100c3ff     	add	sp, sp, #0x30
    1488: a8c153f3     	ldp	x19, x20, [sp], #0x10
    148c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1490: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1494: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1498: a8c173fb     	ldp	x27, x28, [sp], #0x10
    149c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    14a0: d65f03c0     	ret

00000000000014a4 <___pl_fn_5>:
    14a4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    14a8: 910003fd     	mov	x29, sp
    14ac: f81f0ff3     	str	x19, [sp, #-0x10]!
    14b0: d10043ff     	sub	sp, sp, #0x10
    14b4: b9401003     	ldr	w3, [x0, #0x10]
    14b8: 11000463     	add	w3, w3, #0x1
    14bc: b9001003     	str	w3, [x0, #0x10]
    14c0: aa0003e5     	mov	x5, x0
    14c4: 34000321     	cbz	w1, 0x1528 <___pl_fn_5+0x84>
    14c8: aa0503f3     	mov	x19, x5
    14cc: aa0203e3     	mov	x3, x2
    14d0: aa0103e2     	mov	x2, x1
    14d4: f9400261     	ldr	x1, [x19]
    14d8: 2a0203e0     	mov	w0, w2
    14dc: 8b000c20     	add	x0, x1, x0, lsl #3
    14e0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    14e4: d360fc21     	lsr	x1, x1, #32
    14e8: 92403c22     	and	x2, x1, #0xffff
    14ec: f100085f     	cmp	x2, #0x2
    14f0: 54000080     	b.eq	0x1500 <___pl_fn_5+0x5c>
    14f4: f9400802     	ldr	x2, [x0, #0x10]
    14f8: 927ff842     	and	x2, x2, #0xfffffffffffffffe
    14fc: f9000802     	str	x2, [x0, #0x10]
    1500: 92403c21     	and	x1, x1, #0xffff
    1504: aa0303e2     	mov	x2, x3
    1508: f8217802     	str	x2, [x0, x1, lsl #3]
    150c: b9401260     	ldr	w0, [x19, #0x10]
    1510: 51000400     	sub	w0, w0, #0x1
    1514: b9001260     	str	w0, [x19, #0x10]
    1518: 910043ff     	add	sp, sp, #0x10
    151c: f84107f3     	ldr	x19, [sp], #0x10
    1520: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1524: d65f03c0     	ret
    1528: aa0103e6     	mov	x6, x1
    152c: d2800000     	mov	x0, #0x0                ; =0
    1530: 910003e3     	mov	x3, sp
    1534: f80003e0     	stur	x0, [sp]
    1538: f80083e2     	stur	x2, [sp, #0x8]
    153c: 52800681     	mov	w1, #0x34               ; =52
    1540: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x548>
    1544: f9400084     	ldr	x4, [x4]
    1548: aa0603e2     	mov	x2, x6
    154c: aa0503f3     	mov	x19, x5
    1550: aa1303e0     	mov	x0, x19
    1554: d63f0080     	blr	x4
    1558: 34fffda0     	cbz	w0, 0x150c <___pl_fn_5+0x68>
    155c: 910043ff     	add	sp, sp, #0x10
    1560: f84107f3     	ldr	x19, [sp], #0x10
    1564: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1568: d65f03c0     	ret
