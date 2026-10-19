
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_28184/towers/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: f81f0ff3     	str	x19, [sp, #-0x10]!
       c: d100c3ff     	sub	sp, sp, #0x30
      10: b9401006     	ldr	w6, [x0, #0x10]
      14: 110004c4     	add	w4, w6, #0x1
      18: b9001004     	str	w4, [x0, #0x10]
      1c: 34000401     	cbz	w1, 0x9c <___pl_fn_0+0x9c>
      20: f9400005     	ldr	x5, [x0]
      24: aa0003f3     	mov	x19, x0
      28: 2a0103e0     	mov	w0, w1
      2c: aa0103e7     	mov	x7, x1
      30: 8b000ca1     	add	x1, x5, x0, lsl #3
      34: f9400820     	ldr	x0, [x1, #0x10]
      38: eb00005f     	cmp	x2, x0
      3c: 54000342     	b.hs	0xa4 <___pl_fn_0+0xa4>
      40: 8b020c24     	add	x4, x1, x2, lsl #3
      44: b9402880     	ldr	w0, [x4, #0x28]
      48: 340002e0     	cbz	w0, 0xa4 <___pl_fn_0+0xa4>
      4c: aa0203e8     	mov	x8, x2
      50: 34000403     	cbz	w3, 0xd0 <___pl_fn_0+0xd0>
      54: aa0303e2     	mov	x2, x3
      58: 2a0003e3     	mov	w3, w0
      5c: 2a0203e0     	mov	w0, w2
      60: 8b000ca2     	add	x2, x5, x0, lsl #3
      64: f9000c43     	str	x3, [x2, #0x18]
      68: aa0703e2     	mov	x2, x7
      6c: 340004e2     	cbz	w2, 0x108 <___pl_fn_0+0x108>
      70: f9400821     	ldr	x1, [x1, #0x10]
      74: aa0803e2     	mov	x2, x8
      78: eb01005f     	cmp	x2, x1
      7c: 54000482     	b.hs	0x10c <___pl_fn_0+0x10c>
      80: f9001480     	str	x0, [x4, #0x28]
      84: aa1303e0     	mov	x0, x19
      88: b9001006     	str	w6, [x0, #0x10]
      8c: 9100c3ff     	add	sp, sp, #0x30
      90: f84107f3     	ldr	x19, [sp], #0x10
      94: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      98: d65f03c0     	ret
      9c: aa0103e7     	mov	x7, x1
      a0: aa0003f3     	mov	x19, x0
      a4: 910003e3     	mov	x3, sp
      a8: f80003e2     	stur	x2, [sp]
      ac: 52800001     	mov	w1, #0x0                ; =0
      b0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      b4: f9400084     	ldr	x4, [x4]
      b8: aa0703e2     	mov	x2, x7
      bc: aa1303e0     	mov	x0, x19
      c0: d63f0080     	blr	x4
      c4: 35000420     	cbnz	w0, 0x148 <___pl_fn_0+0x148>
      c8: 52800021     	mov	w1, #0x1                ; =1
      cc: 1400001b     	b	0x138 <___pl_fn_0+0x138>
      d0: aa0303e2     	mov	x2, x3
      d4: d2800021     	mov	x1, #0x1                ; =1
      d8: 910023e3     	add	x3, sp, #0x8
      dc: f80083e1     	stur	x1, [sp, #0x8]
      e0: 2a0003e0     	mov	w0, w0
      e4: f80103e0     	stur	x0, [sp, #0x10]
      e8: 52800041     	mov	w1, #0x2                ; =2
      ec: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      f0: f9400084     	ldr	x4, [x4]
      f4: aa1303e0     	mov	x0, x19
      f8: d63f0080     	blr	x4
      fc: 35000260     	cbnz	w0, 0x148 <___pl_fn_0+0x148>
     100: 52800061     	mov	w1, #0x3                ; =3
     104: 1400000d     	b	0x138 <___pl_fn_0+0x138>
     108: aa0803e2     	mov	x2, x8
     10c: 910063e3     	add	x3, sp, #0x18
     110: f80183e2     	stur	x2, [sp, #0x18]
     114: f80203e0     	stur	x0, [sp, #0x20]
     118: 52800081     	mov	w1, #0x4                ; =4
     11c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     120: f9400084     	ldr	x4, [x4]
     124: aa0703e2     	mov	x2, x7
     128: aa1303e0     	mov	x0, x19
     12c: d63f0080     	blr	x4
     130: 350000c0     	cbnz	w0, 0x148 <___pl_fn_0+0x148>
     134: 528000a1     	mov	w1, #0x5                ; =5
     138: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     13c: f9400108     	ldr	x8, [x8]
     140: aa1303e0     	mov	x0, x19
     144: d63f0100     	blr	x8
     148: 9100c3ff     	add	sp, sp, #0x30
     14c: f84107f3     	ldr	x19, [sp], #0x10
     150: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     154: d65f03c0     	ret

0000000000000158 <___pl_fn_1>:
     158: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     15c: 910003fd     	mov	x29, sp
     160: f81f0ff3     	str	x19, [sp, #-0x10]!
     164: d10083ff     	sub	sp, sp, #0x20
     168: b9401006     	ldr	w6, [x0, #0x10]
     16c: 110004c3     	add	w3, w6, #0x1
     170: b9001003     	str	w3, [x0, #0x10]
     174: 34000421     	cbz	w1, 0x1f8 <___pl_fn_1+0xa0>
     178: f9400005     	ldr	x5, [x0]
     17c: aa0003f3     	mov	x19, x0
     180: 2a0103e0     	mov	w0, w1
     184: aa0103e7     	mov	x7, x1
     188: 8b000ca0     	add	x0, x5, x0, lsl #3
     18c: f9400801     	ldr	x1, [x0, #0x10]
     190: eb01005f     	cmp	x2, x1
     194: 540003a2     	b.hs	0x208 <___pl_fn_1+0xb0>
     198: 8b020c03     	add	x3, x0, x2, lsl #3
     19c: aa0203e4     	mov	x4, x2
     1a0: b9402862     	ldr	w2, [x3, #0x28]
     1a4: 34000342     	cbz	w2, 0x20c <___pl_fn_1+0xb4>
     1a8: 34000722     	cbz	w2, 0x28c <___pl_fn_1+0x134>
     1ac: 34000462     	cbz	w2, 0x238 <___pl_fn_1+0xe0>
     1b0: 2a0203e0     	mov	w0, w2
     1b4: 8b000ca0     	add	x0, x5, x0, lsl #3
     1b8: b9401805     	ldr	w5, [x0, #0x18]
     1bc: 340003e5     	cbz	w5, 0x238 <___pl_fn_1+0xe0>
     1c0: aa0203e8     	mov	x8, x2
     1c4: aa0703e2     	mov	x2, x7
     1c8: 340004a2     	cbz	w2, 0x25c <___pl_fn_1+0x104>
     1cc: eb01009f     	cmp	x4, x1
     1d0: 54000462     	b.hs	0x25c <___pl_fn_1+0x104>
     1d4: 2a0503e9     	mov	w9, w5
     1d8: f9001469     	str	x9, [x3, #0x28]
     1dc: aa1303e0     	mov	x0, x19
     1e0: b9001006     	str	w6, [x0, #0x10]
     1e4: aa0803e0     	mov	x0, x8
     1e8: 910083ff     	add	sp, sp, #0x20
     1ec: f84107f3     	ldr	x19, [sp], #0x10
     1f0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     1f4: d65f03c0     	ret
     1f8: aa0203e4     	mov	x4, x2
     1fc: aa0103e7     	mov	x7, x1
     200: aa0003f3     	mov	x19, x0
     204: 14000002     	b	0x20c <___pl_fn_1+0xb4>
     208: aa0203e4     	mov	x4, x2
     20c: 910003e3     	mov	x3, sp
     210: f80003e4     	stur	x4, [sp]
     214: 528000c1     	mov	w1, #0x6                ; =6
     218: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     21c: f9400084     	ldr	x4, [x4]
     220: aa0703e2     	mov	x2, x7
     224: aa1303e0     	mov	x0, x19
     228: d63f0080     	blr	x4
     22c: 350003a0     	cbnz	w0, 0x2a0 <___pl_fn_1+0x148>
     230: 528000e1     	mov	w1, #0x7                ; =7
     234: 14000017     	b	0x290 <___pl_fn_1+0x138>
     238: 52800121     	mov	w1, #0x9                ; =9
     23c: 52800023     	mov	w3, #0x1                ; =1
     240: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     244: f9400084     	ldr	x4, [x4]
     248: aa1303e0     	mov	x0, x19
     24c: d63f0080     	blr	x4
     250: 35000280     	cbnz	w0, 0x2a0 <___pl_fn_1+0x148>
     254: 52800141     	mov	w1, #0xa                ; =10
     258: 1400000e     	b	0x290 <___pl_fn_1+0x138>
     25c: 910023e3     	add	x3, sp, #0x8
     260: f80083e4     	stur	x4, [sp, #0x8]
     264: 2a0503e4     	mov	w4, w5
     268: f80103e4     	stur	x4, [sp, #0x10]
     26c: 52800161     	mov	w1, #0xb                ; =11
     270: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     274: f94000a5     	ldr	x5, [x5]
     278: aa1303e0     	mov	x0, x19
     27c: d63f00a0     	blr	x5
     280: 35000100     	cbnz	w0, 0x2a0 <___pl_fn_1+0x148>
     284: 52800181     	mov	w1, #0xc                ; =12
     288: 14000002     	b	0x290 <___pl_fn_1+0x138>
     28c: 52800101     	mov	w1, #0x8                ; =8
     290: 9000000e     	adrp	x14, 0x0 <___pl_fn_0>
     294: f94001ce     	ldr	x14, [x14]
     298: aa1303e0     	mov	x0, x19
     29c: d63f01c0     	blr	x14
     2a0: 52800000     	mov	w0, #0x0                ; =0
     2a4: 910083ff     	add	sp, sp, #0x20
     2a8: f84107f3     	ldr	x19, [sp], #0x10
     2ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     2b0: d65f03c0     	ret

00000000000002b4 <___pl_fn_2>:
     2b4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     2b8: 910003fd     	mov	x29, sp
     2bc: f81f0ff7     	str	x23, [sp, #-0x10]!
     2c0: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     2c4: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     2c8: aa0403f4     	mov	x20, x4
     2cc: aa0303f6     	mov	x22, x3
     2d0: aa0103f7     	mov	x23, x1
     2d4: b9401001     	ldr	w1, [x0, #0x10]
     2d8: 11000423     	add	w3, w1, #0x1
     2dc: b9001003     	str	w3, [x0, #0x10]
     2e0: b9401403     	ldr	w3, [x0, #0x14]
     2e4: aa0003f5     	mov	x21, x0
     2e8: 11000420     	add	w0, w1, #0x1
     2ec: 6b03001f     	cmp	w0, w3
     2f0: 54000da2     	b.hs	0x4a4 <___pl_fn_2+0x1f0>
     2f4: aa1503e0     	mov	x0, x21
     2f8: aa1703e1     	mov	x1, x23
     2fc: 94000000     	bl	0x2fc <___pl_fn_2+0x48>
     300: aa1503e7     	mov	x7, x21
     304: b9402ce1     	ldr	w1, [x7, #0x2c]
     308: 35000d81     	cbnz	w1, 0x4b8 <___pl_fn_2+0x204>
     30c: aa1503eb     	mov	x11, x21
     310: b9401973     	ldr	w19, [x11, #0x18]
     314: aa1503ed     	mov	x13, x21
     318: b9401da2     	ldr	w2, [x13, #0x1c]
     31c: 11000661     	add	w1, w19, #0x1
     320: 6b02003f     	cmp	w1, w2
     324: 54000bc8     	b.hi	0x49c <___pl_fn_2+0x1e8>
     328: aa1503e2     	mov	x2, x21
     32c: f9401042     	ldr	x2, [x2, #0x20]
     330: b8335840     	str	w0, [x2, w19, uxtw #2]
     334: aa0003e3     	mov	x3, x0
     338: aa1503e0     	mov	x0, x21
     33c: b9001801     	str	w1, [x0, #0x18]
     340: b9401004     	ldr	w4, [x0, #0x10]
     344: b9401405     	ldr	w5, [x0, #0x14]
     348: 6b05009f     	cmp	w4, w5
     34c: 54000a42     	b.hs	0x494 <___pl_fn_2+0x1e0>
     350: aa1703e1     	mov	x1, x23
     354: aa1603e2     	mov	x2, x22
     358: aa1503e0     	mov	x0, x21
     35c: 94000000     	bl	0x35c <___pl_fn_2+0xa8>
     360: aa1503e0     	mov	x0, x21
     364: b9402c07     	ldr	w7, [x0, #0x2c]
     368: 35000a87     	cbnz	w7, 0x4b8 <___pl_fn_2+0x204>
     36c: aa1503e0     	mov	x0, x21
     370: b9001813     	str	w19, [x0, #0x18]
     374: f940240a     	ldr	x10, [x0, #0x48]
     378: 2a1403f3     	mov	w19, w20
     37c: d100066b     	sub	x11, x19, #0x1
     380: eb0a017f     	cmp	x11, x10
     384: 54000622     	b.hs	0x448 <___pl_fn_2+0x194>
     388: aa1503e0     	mov	x0, x21
     38c: f940200d     	ldr	x13, [x0, #0x40]
     390: d280060f     	mov	x15, #0x30              ; =48
     394: d1000660     	sub	x0, x19, #0x1
     398: 9b0f7c0e     	mul	x14, x0, x15
     39c: 9b0f340f     	madd	x15, x0, x15, x13
     3a0: f94005ef     	ldr	x15, [x15, #0x8]
     3a4: b50000af     	cbnz	x15, 0x3b8 <___pl_fn_2+0x104>
     3a8: 14000028     	b	0x448 <___pl_fn_2+0x194>
     3ac: aa1503e0     	mov	x0, x21
     3b0: f9401800     	ldr	x0, [x0, #0x30]
     3b4: 14000002     	b	0x3bc <___pl_fn_2+0x108>
     3b8: f86e69a0     	ldr	x0, [x13, x14]
     3bc: b27ff7e1     	mov	x1, #0x7ffffffffffffffe ; =9223372036854775806
     3c0: eb01001f     	cmp	x0, x1
     3c4: 5400064c     	b.gt	0x48c <___pl_fn_2+0x1d8>
     3c8: aa1503e2     	mov	x2, x21
     3cc: f9402441     	ldr	x1, [x2, #0x48]
     3d0: d1000662     	sub	x2, x19, #0x1
     3d4: eb01005f     	cmp	x2, x1
     3d8: 54000482     	b.hs	0x468 <___pl_fn_2+0x1b4>
     3dc: aa1503e8     	mov	x8, x21
     3e0: f9402101     	ldr	x1, [x8, #0x40]
     3e4: d2800603     	mov	x3, #0x30               ; =48
     3e8: d1000664     	sub	x4, x19, #0x1
     3ec: 9b037c82     	mul	x2, x4, x3
     3f0: 9b030483     	madd	x3, x4, x3, x1
     3f4: f9400864     	ldr	x4, [x3, #0x10]
     3f8: b5000084     	cbnz	x4, 0x408 <___pl_fn_2+0x154>
     3fc: 1400001b     	b	0x468 <___pl_fn_2+0x1b4>
     400: aa1503e0     	mov	x0, x21
     404: 14000006     	b	0x41c <___pl_fn_2+0x168>
     408: d2800024     	mov	x4, #0x1                ; =1
     40c: 91000400     	add	x0, x0, #0x1
     410: f8226820     	str	x0, [x1, x2]
     414: f9000464     	str	x4, [x3, #0x8]
     418: aa1503e0     	mov	x0, x21
     41c: aa1503e0     	mov	x0, x21
     420: b9401000     	ldr	w0, [x0, #0x10]
     424: 51000400     	sub	w0, w0, #0x1
     428: aa1503e1     	mov	x1, x21
     42c: b9001020     	str	w0, [x1, #0x10]
     430: a8c153f3     	ldp	x19, x20, [sp], #0x10
     434: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     438: f84107f7     	ldr	x23, [sp], #0x10
     43c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     440: d65f03c0     	ret
     444: 1400001d     	b	0x4b8 <___pl_fn_2+0x204>
     448: 52800201     	mov	w1, #0x10               ; =16
     44c: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     450: f94001ef     	ldr	x15, [x15]
     454: aa1503e0     	mov	x0, x21
     458: aa1403e2     	mov	x2, x20
     45c: d63f01e0     	blr	x15
     460: 34fffa60     	cbz	w0, 0x3ac <___pl_fn_2+0xf8>
     464: 14000015     	b	0x4b8 <___pl_fn_2+0x204>
     468: 52800241     	mov	w1, #0x12               ; =18
     46c: 91000403     	add	x3, x0, #0x1
     470: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     474: f9400084     	ldr	x4, [x4]
     478: aa1403e2     	mov	x2, x20
     47c: aa1503e0     	mov	x0, x21
     480: d63f0080     	blr	x4
     484: 34fffbe0     	cbz	w0, 0x400 <___pl_fn_2+0x14c>
     488: 1400000c     	b	0x4b8 <___pl_fn_2+0x204>
     48c: 52800221     	mov	w1, #0x11               ; =17
     490: 14000006     	b	0x4a8 <___pl_fn_2+0x1f4>
     494: 528001e1     	mov	w1, #0xf                ; =15
     498: 14000004     	b	0x4a8 <___pl_fn_2+0x1f4>
     49c: 528001c1     	mov	w1, #0xe                ; =14
     4a0: 14000002     	b	0x4a8 <___pl_fn_2+0x1f4>
     4a4: 528001a1     	mov	w1, #0xd                ; =13
     4a8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     4ac: f9400042     	ldr	x2, [x2]
     4b0: aa1503e0     	mov	x0, x21
     4b4: d63f0040     	blr	x2
     4b8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     4bc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     4c0: f84107f7     	ldr	x23, [sp], #0x10
     4c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     4c8: d65f03c0     	ret

00000000000004cc <___pl_fn_3>:
     4cc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     4d0: 910003fd     	mov	x29, sp
     4d4: f81f0ffb     	str	x27, [sp, #-0x10]!
     4d8: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
     4dc: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     4e0: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     4e4: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     4e8: aa0003f4     	mov	x20, x0
     4ec: aa0503f5     	mov	x21, x5
     4f0: aa0103f7     	mov	x23, x1
     4f4: b9401000     	ldr	w0, [x0, #0x10]
     4f8: 11000401     	add	w1, w0, #0x1
     4fc: aa1403ed     	mov	x13, x20
     500: b90011a1     	str	w1, [x13, #0x10]
     504: f100045f     	cmp	x2, #0x1
     508: 540008e0     	b.eq	0x624 <___pl_fn_3+0x158>
     50c: d2800081     	mov	x1, #0x4                ; =4
     510: f2f00001     	movk	x1, #0x8000, lsl #48
     514: eb01007f     	cmp	x3, x1
     518: 54000d8b     	b.lt	0x6c8 <___pl_fn_3+0x1fc>
     51c: d2800061     	mov	x1, #0x3                ; =3
     520: cb030021     	sub	x1, x1, x3
     524: aa0303f8     	mov	x24, x3
     528: eb040023     	subs	x3, x1, x4
     52c: aa0403f6     	mov	x22, x4
     530: aa0303fa     	mov	x26, x3
     534: 9a9f77e1     	cset	x1, vs
     538: 72001c3f     	tst	w1, #0xff
     53c: 54000c21     	b.ne	0x6c0 <___pl_fn_3+0x1f4>
     540: b24107f3     	mov	x19, #-0x7fffffffffffffff ; =-9223372036854775807
     544: eb13005f     	cmp	x2, x19
     548: 54000b8b     	b.lt	0x6b8 <___pl_fn_3+0x1ec>
     54c: aa1403e1     	mov	x1, x20
     550: b9401421     	ldr	w1, [x1, #0x14]
     554: 11000400     	add	w0, w0, #0x1
     558: 6b01001f     	cmp	w0, w1
     55c: 54000aa2     	b.hs	0x6b0 <___pl_fn_3+0x1e4>
     560: d1000440     	sub	x0, x2, #0x1
     564: aa0203f9     	mov	x25, x2
     568: aa0003fb     	mov	x27, x0
     56c: aa1403e0     	mov	x0, x20
     570: aa1703e1     	mov	x1, x23
     574: aa1b03e2     	mov	x2, x27
     578: aa1803e3     	mov	x3, x24
     57c: aa1a03e4     	mov	x4, x26
     580: aa1503e5     	mov	x5, x21
     584: 94000000     	bl	0x584 <___pl_fn_3+0xb8>
     588: aa1403e0     	mov	x0, x20
     58c: b9402c00     	ldr	w0, [x0, #0x2c]
     590: 35000aa0     	cbnz	w0, 0x6e4 <___pl_fn_3+0x218>
     594: aa1403e0     	mov	x0, x20
     598: b9401000     	ldr	w0, [x0, #0x10]
     59c: aa1403ed     	mov	x13, x20
     5a0: b94015a1     	ldr	w1, [x13, #0x14]
     5a4: 6b01001f     	cmp	w0, w1
     5a8: 54000802     	b.hs	0x6a8 <___pl_fn_3+0x1dc>
     5ac: aa1803e2     	mov	x2, x24
     5b0: aa1403e0     	mov	x0, x20
     5b4: aa1703e1     	mov	x1, x23
     5b8: aa1603e3     	mov	x3, x22
     5bc: aa1503e4     	mov	x4, x21
     5c0: 94000000     	bl	0x5c0 <___pl_fn_3+0xf4>
     5c4: aa1403e0     	mov	x0, x20
     5c8: b9402c00     	ldr	w0, [x0, #0x2c]
     5cc: 350008c0     	cbnz	w0, 0x6e4 <___pl_fn_3+0x218>
     5d0: aa1903e2     	mov	x2, x25
     5d4: eb13005f     	cmp	x2, x19
     5d8: 5400064b     	b.lt	0x6a0 <___pl_fn_3+0x1d4>
     5dc: aa1403e0     	mov	x0, x20
     5e0: b9401000     	ldr	w0, [x0, #0x10]
     5e4: aa1403e1     	mov	x1, x20
     5e8: b9401421     	ldr	w1, [x1, #0x14]
     5ec: 6b01001f     	cmp	w0, w1
     5f0: 54000542     	b.hs	0x698 <___pl_fn_3+0x1cc>
     5f4: aa1703e1     	mov	x1, x23
     5f8: aa1b03e2     	mov	x2, x27
     5fc: aa1a03e3     	mov	x3, x26
     600: aa1603e4     	mov	x4, x22
     604: aa1503e5     	mov	x5, x21
     608: aa1403e0     	mov	x0, x20
     60c: 94000000     	bl	0x60c <___pl_fn_3+0x140>
     610: aa1403e0     	mov	x0, x20
     614: b9402c03     	ldr	w3, [x0, #0x2c]
     618: 35000663     	cbnz	w3, 0x6e4 <___pl_fn_3+0x218>
     61c: aa1403e0     	mov	x0, x20
     620: 14000011     	b	0x664 <___pl_fn_3+0x198>
     624: aa1403e1     	mov	x1, x20
     628: aa0303e2     	mov	x2, x3
     62c: aa0403f6     	mov	x22, x4
     630: b940142d     	ldr	w13, [x1, #0x14]
     634: 1100040e     	add	w14, w0, #0x1
     638: 6b0d01df     	cmp	w14, w13
     63c: 540004a2     	b.hs	0x6d0 <___pl_fn_3+0x204>
     640: aa1703e1     	mov	x1, x23
     644: aa1603e3     	mov	x3, x22
     648: aa1503e4     	mov	x4, x21
     64c: aa1403e0     	mov	x0, x20
     650: 94000000     	bl	0x650 <___pl_fn_3+0x184>
     654: aa1403e0     	mov	x0, x20
     658: b9402c00     	ldr	w0, [x0, #0x2c]
     65c: 35000440     	cbnz	w0, 0x6e4 <___pl_fn_3+0x218>
     660: aa1403e0     	mov	x0, x20
     664: aa1403e0     	mov	x0, x20
     668: b9401000     	ldr	w0, [x0, #0x10]
     66c: 51000400     	sub	w0, w0, #0x1
     670: aa1403e1     	mov	x1, x20
     674: b9001020     	str	w0, [x1, #0x10]
     678: a8c153f3     	ldp	x19, x20, [sp], #0x10
     67c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     680: a8c163f7     	ldp	x23, x24, [sp], #0x10
     684: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     688: f84107fb     	ldr	x27, [sp], #0x10
     68c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     690: d65f03c0     	ret
     694: 14000014     	b	0x6e4 <___pl_fn_3+0x218>
     698: 52800321     	mov	w1, #0x19               ; =25
     69c: 1400000e     	b	0x6d4 <___pl_fn_3+0x208>
     6a0: 52800301     	mov	w1, #0x18               ; =24
     6a4: 1400000c     	b	0x6d4 <___pl_fn_3+0x208>
     6a8: 528002e1     	mov	w1, #0x17               ; =23
     6ac: 1400000a     	b	0x6d4 <___pl_fn_3+0x208>
     6b0: 528002c1     	mov	w1, #0x16               ; =22
     6b4: 14000008     	b	0x6d4 <___pl_fn_3+0x208>
     6b8: 528002a1     	mov	w1, #0x15               ; =21
     6bc: 14000006     	b	0x6d4 <___pl_fn_3+0x208>
     6c0: 52800281     	mov	w1, #0x14               ; =20
     6c4: 14000004     	b	0x6d4 <___pl_fn_3+0x208>
     6c8: 52800261     	mov	w1, #0x13               ; =19
     6cc: 14000002     	b	0x6d4 <___pl_fn_3+0x208>
     6d0: 52800341     	mov	w1, #0x1a               ; =26
     6d4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6d8: f9400042     	ldr	x2, [x2]
     6dc: aa1403e0     	mov	x0, x20
     6e0: d63f0040     	blr	x2
     6e4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6e8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6ec: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6f0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6f4: f84107fb     	ldr	x27, [sp], #0x10
     6f8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6fc: d65f03c0     	ret

0000000000000700 <___pl_fn_4>:
     700: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     704: 910003fd     	mov	x29, sp
     708: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
     70c: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
     710: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     714: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     718: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     71c: d10083ff     	sub	sp, sp, #0x20
     720: b9401001     	ldr	w1, [x0, #0x10]
     724: 11000421     	add	w1, w1, #0x1
     728: b9001001     	str	w1, [x0, #0x10]
     72c: aa0003f8     	mov	x24, x0
     730: 52800361     	mov	w1, #0x1b               ; =27
     734: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     738: f9400042     	ldr	x2, [x2]
     73c: d63f0040     	blr	x2
     740: 35004340     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     744: aa1803e0     	mov	x0, x24
     748: f9401802     	ldr	x2, [x0, #0x30]
     74c: aa0203f9     	mov	x25, x2
     750: d2800060     	mov	x0, #0x3                ; =3
     754: 910003e3     	mov	x3, sp
     758: f80003e0     	stur	x0, [sp]
     75c: 52800381     	mov	w1, #0x1c               ; =28
     760: 52802082     	mov	w2, #0x104              ; =260
     764: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     768: f9400084     	ldr	x4, [x4]
     76c: aa1803e0     	mov	x0, x24
     770: d63f0080     	blr	x4
     774: 350041a0     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     778: aa1803e0     	mov	x0, x24
     77c: f9401801     	ldr	x1, [x0, #0x30]
     780: aa0103fb     	mov	x27, x1
     784: 528003a1     	mov	w1, #0x1d               ; =29
     788: 52800002     	mov	w2, #0x0                ; =0
     78c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     790: f9400063     	ldr	x3, [x3]
     794: d63f0060     	blr	x3
     798: 35004080     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     79c: aa1803e0     	mov	x0, x24
     7a0: f9401802     	ldr	x2, [x0, #0x30]
     7a4: aa0203fa     	mov	x26, x2
     7a8: b9401813     	ldr	w19, [x0, #0x18]
     7ac: b9401c01     	ldr	w1, [x0, #0x1c]
     7b0: 11000660     	add	w0, w19, #0x1
     7b4: 6b01001f     	cmp	w0, w1
     7b8: 54003ee8     	b.hi	0xf94 <___pl_fn_4+0x894>
     7bc: aa1803e1     	mov	x1, x24
     7c0: f9401021     	ldr	x1, [x1, #0x20]
     7c4: aa1b03e2     	mov	x2, x27
     7c8: b8335822     	str	w2, [x1, w19, uxtw #2]
     7cc: aa1803e1     	mov	x1, x24
     7d0: b9001820     	str	w0, [x1, #0x18]
     7d4: 528003e1     	mov	w1, #0x1f               ; =31
     7d8: 52800002     	mov	w2, #0x0                ; =0
     7dc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     7e0: f9400063     	ldr	x3, [x3]
     7e4: aa1803e0     	mov	x0, x24
     7e8: d63f0060     	blr	x3
     7ec: 35003de0     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     7f0: aa1803e0     	mov	x0, x24
     7f4: f9401802     	ldr	x2, [x0, #0x30]
     7f8: aa0203fc     	mov	x28, x2
     7fc: b9001813     	str	w19, [x0, #0x18]
     800: d2800013     	mov	x19, #0x0               ; =0
     804: f1000a7f     	cmp	x19, #0x2
     808: 9a9fc7e0     	cset	x0, le
     80c: 72001c1f     	tst	w0, #0xff
     810: 54001f81     	b.ne	0xc00 <___pl_fn_4+0x500>
     814: 52800034     	mov	w20, #0x1               ; =1
     818: aa1c03f3     	mov	x19, x28
     81c: f100027f     	cmp	x19, #0x0
     820: 9a9fd7e0     	cset	x0, gt
     824: 72001c1f     	tst	w0, #0xff
     828: 54000c21     	b.ne	0x9ac <___pl_fn_4+0x2ac>
     82c: aa1803e0     	mov	x0, x24
     830: f9402408     	ldr	x8, [x0, #0x48]
     834: aa1a03e2     	mov	x2, x26
     838: 2a0203f3     	mov	w19, w2
     83c: d1000669     	sub	x9, x19, #0x1
     840: eb08013f     	cmp	x9, x8
     844: 54002f02     	b.hs	0xe24 <___pl_fn_4+0x724>
     848: aa1803e0     	mov	x0, x24
     84c: f940200b     	ldr	x11, [x0, #0x40]
     850: d280060c     	mov	x12, #0x30              ; =48
     854: d100066e     	sub	x14, x19, #0x1
     858: 9b0c7dcd     	mul	x13, x14, x12
     85c: 9b0c2dcc     	madd	x12, x14, x12, x11
     860: f940098e     	ldr	x14, [x12, #0x10]
     864: b500008e     	cbnz	x14, 0x874 <___pl_fn_4+0x174>
     868: 1400016f     	b	0xe24 <___pl_fn_4+0x724>
     86c: aa1803e0     	mov	x0, x24
     870: 14000006     	b	0x888 <___pl_fn_4+0x188>
     874: d2800000     	mov	x0, #0x0                ; =0
     878: f82d6960     	str	x0, [x11, x13]
     87c: d2800020     	mov	x0, #0x1                ; =1
     880: f9000580     	str	x0, [x12, #0x8]
     884: aa1803e0     	mov	x0, x24
     888: aa1803e0     	mov	x0, x24
     88c: b9401814     	ldr	w20, [x0, #0x18]
     890: b9401c01     	ldr	w1, [x0, #0x1c]
     894: 11000680     	add	w0, w20, #0x1
     898: 6b01001f     	cmp	w0, w1
     89c: 54002ea8     	b.hi	0xe70 <___pl_fn_4+0x770>
     8a0: aa1803e1     	mov	x1, x24
     8a4: f9401021     	ldr	x1, [x1, #0x20]
     8a8: aa1b03e2     	mov	x2, x27
     8ac: b8345822     	str	w2, [x1, w20, uxtw #2]
     8b0: aa1803e1     	mov	x1, x24
     8b4: b9001820     	str	w0, [x1, #0x18]
     8b8: aa1803e0     	mov	x0, x24
     8bc: b9401000     	ldr	w0, [x0, #0x10]
     8c0: b9401421     	ldr	w1, [x1, #0x14]
     8c4: 6b01001f     	cmp	w0, w1
     8c8: 54002d02     	b.hs	0xe68 <___pl_fn_4+0x768>
     8cc: d2800003     	mov	x3, #0x0                ; =0
     8d0: d2800024     	mov	x4, #0x1                ; =1
     8d4: aa1b03e1     	mov	x1, x27
     8d8: aa1c03e2     	mov	x2, x28
     8dc: aa1803e0     	mov	x0, x24
     8e0: aa1a03e5     	mov	x5, x26
     8e4: 94000000     	bl	0x8e4 <___pl_fn_4+0x1e4>
     8e8: aa1803e0     	mov	x0, x24
     8ec: b9402c00     	ldr	w0, [x0, #0x2c]
     8f0: 350035c0     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     8f4: aa1803e0     	mov	x0, x24
     8f8: b9001814     	str	w20, [x0, #0x18]
     8fc: f9402400     	ldr	x0, [x0, #0x48]
     900: d1000661     	sub	x1, x19, #0x1
     904: eb00003f     	cmp	x1, x0
     908: 54002a02     	b.hs	0xe48 <___pl_fn_4+0x748>
     90c: aa1803e0     	mov	x0, x24
     910: f9402000     	ldr	x0, [x0, #0x40]
     914: d2800602     	mov	x2, #0x30               ; =48
     918: d1000663     	sub	x3, x19, #0x1
     91c: 9b027c61     	mul	x1, x3, x2
     920: 9b020062     	madd	x2, x3, x2, x0
     924: f9400442     	ldr	x2, [x2, #0x8]
     928: b50000a2     	cbnz	x2, 0x93c <___pl_fn_4+0x23c>
     92c: 14000147     	b	0xe48 <___pl_fn_4+0x748>
     930: aa1803e0     	mov	x0, x24
     934: f9401802     	ldr	x2, [x0, #0x30]
     938: 14000002     	b	0x940 <___pl_fn_4+0x240>
     93c: f8616802     	ldr	x2, [x0, x1]
     940: 528004c1     	mov	w1, #0x26               ; =38
     944: 52802003     	mov	w3, #0x100              ; =256
     948: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     94c: f9400084     	ldr	x4, [x4]
     950: aa1803e0     	mov	x0, x24
     954: d63f0080     	blr	x4
     958: 35003280     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     95c: 528004e1     	mov	w1, #0x27               ; =39
     960: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     964: f9400063     	ldr	x3, [x3]
     968: aa1903e2     	mov	x2, x25
     96c: aa1803e0     	mov	x0, x24
     970: d63f0060     	blr	x3
     974: 350031a0     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     978: aa1803e0     	mov	x0, x24
     97c: b9401000     	ldr	w0, [x0, #0x10]
     980: 51000400     	sub	w0, w0, #0x1
     984: aa1803e1     	mov	x1, x24
     988: b9001020     	str	w0, [x1, #0x10]
     98c: 910083ff     	add	sp, sp, #0x20
     990: a8c153f3     	ldp	x19, x20, [sp], #0x10
     994: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     998: a8c163f7     	ldp	x23, x24, [sp], #0x10
     99c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9a0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9a4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9a8: d65f03c0     	ret
     9ac: aa1803e0     	mov	x0, x24
     9b0: f9403c00     	ldr	x0, [x0, #0x78]
     9b4: 37202620     	tbnz	w0, #0x4, 0xe78 <___pl_fn_4+0x778>
     9b8: aa1803e0     	mov	x0, x24
     9bc: f9403800     	ldr	x0, [x0, #0x70]
     9c0: f100001f     	cmp	x0, #0x0
     9c4: 540025ed     	b.le	0xe80 <___pl_fn_4+0x780>
     9c8: aa1803e0     	mov	x0, x24
     9cc: f9403400     	ldr	x0, [x0, #0x68]
     9d0: f1000c1f     	cmp	x0, #0x3
     9d4: 540025ab     	b.lt	0xe88 <___pl_fn_4+0x788>
     9d8: aa1803e0     	mov	x0, x24
     9dc: f9402815     	ldr	x21, [x0, #0x50]
     9e0: f9402c00     	ldr	x0, [x0, #0x58]
     9e4: 910012a1     	add	x1, x21, #0x4
     9e8: eb00003f     	cmp	x1, x0
     9ec: 54002528     	b.hi	0xe90 <___pl_fn_4+0x790>
     9f0: aa1803e0     	mov	x0, x24
     9f4: f9404400     	ldr	x0, [x0, #0x88]
     9f8: aa1803e1     	mov	x1, x24
     9fc: f9404821     	ldr	x1, [x1, #0x90]
     a00: eb01001f     	cmp	x0, x1
     a04: 540024a2     	b.hs	0xe98 <___pl_fn_4+0x798>
     a08: aa1803e1     	mov	x1, x24
     a0c: b9401821     	ldr	w1, [x1, #0x18]
     a10: aa1803e2     	mov	x2, x24
     a14: b9401c42     	ldr	w2, [x2, #0x1c]
     a18: 11000421     	add	w1, w1, #0x1
     a1c: 6b02003f     	cmp	w1, w2
     a20: 54000269     	b.ls	0xa6c <___pl_fn_4+0x36c>
     a24: 1400011f     	b	0xea0 <___pl_fn_4+0x7a0>
     a28: aa1803e8     	mov	x8, x24
     a2c: f9401102     	ldr	x2, [x8, #0x20]
     a30: aa1b03e1     	mov	x1, x27
     a34: b8365841     	str	w1, [x2, w22, uxtw #2]
     a38: aa1803eb     	mov	x11, x24
     a3c: b9001960     	str	w0, [x11, #0x18]
     a40: 52800521     	mov	w1, #0x29               ; =41
     a44: 52800002     	mov	w2, #0x0                ; =0
     a48: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     a4c: f9400084     	ldr	x4, [x4]
     a50: aa1803e0     	mov	x0, x24
     a54: d63f0080     	blr	x4
     a58: 35002a80     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     a5c: aa1803e0     	mov	x0, x24
     a60: f9401815     	ldr	x21, [x0, #0x30]
     a64: b9001816     	str	w22, [x0, #0x18]
     a68: 14000024     	b	0xaf8 <___pl_fn_4+0x3f8>
     a6c: aa1803e1     	mov	x1, x24
     a70: f940302b     	ldr	x11, [x1, #0x60]
     a74: f940002c     	ldr	x12, [x1]
     a78: d280006e     	mov	x14, #0x3               ; =3
     a7c: f2c0004e     	movk	x14, #0x2, lsl #32
     a80: 2a1503ea     	mov	w10, w21
     a84: d2800069     	mov	x9, #0x3                ; =3
     a88: 8b0a0d8d     	add	x13, x12, x10, lsl #3
     a8c: f835598e     	str	x14, [x12, w21, uxtw #3]
     a90: 9100056b     	add	x11, x11, #0x1
     a94: f90005ab     	str	x11, [x13, #0x8]
     a98: d280000c     	mov	x12, #0x0               ; =0
     a9c: f90009ac     	str	x12, [x13, #0x10]
     aa0: f9000dac     	str	x12, [x13, #0x18]
     aa4: f900302b     	str	x11, [x1, #0x60]
     aa8: 910012ae     	add	x14, x21, #0x4
     aac: f900282e     	str	x14, [x1, #0x50]
     ab0: f940342f     	ldr	x15, [x1, #0x68]
     ab4: d1000def     	sub	x15, x15, #0x3
     ab8: f900342f     	str	x15, [x1, #0x68]
     abc: f9403821     	ldr	x1, [x1, #0x70]
     ac0: d1000c21     	sub	x1, x1, #0x3
     ac4: aa1803e2     	mov	x2, x24
     ac8: f9003841     	str	x1, [x2, #0x70]
     acc: aa1803e1     	mov	x1, x24
     ad0: f9404021     	ldr	x1, [x1, #0x80]
     ad4: b25e0142     	orr	x2, x10, #0x400000000
     ad8: d37cec03     	lsl	x3, x0, #4
     adc: 8b001024     	add	x4, x1, x0, lsl #4
     ae0: f8236822     	str	x2, [x1, x3]
     ae4: f9000489     	str	x9, [x4, #0x8]
     ae8: 91000400     	add	x0, x0, #0x1
     aec: aa1803e1     	mov	x1, x24
     af0: f9004420     	str	x0, [x1, #0x88]
     af4: aa1803e0     	mov	x0, x24
     af8: aa1803e0     	mov	x0, x24
     afc: b9401816     	ldr	w22, [x0, #0x18]
     b00: b9401c00     	ldr	w0, [x0, #0x1c]
     b04: 11000ac1     	add	w1, w22, #0x2
     b08: 6b00003f     	cmp	w1, w0
     b0c: 54001f08     	b.hi	0xeec <___pl_fn_4+0x7ec>
     b10: aa1803e0     	mov	x0, x24
     b14: f9401000     	ldr	x0, [x0, #0x20]
     b18: 2a1603f7     	mov	w23, w22
     b1c: 8b170801     	add	x1, x0, x23, lsl #2
     b20: aa1b03ed     	mov	x13, x27
     b24: b836580d     	str	w13, [x0, w22, uxtw #2]
     b28: b9000435     	str	w21, [x1, #0x4]
     b2c: 11000ac0     	add	w0, w22, #0x2
     b30: aa1803e1     	mov	x1, x24
     b34: b9001820     	str	w0, [x1, #0x18]
     b38: aa1803e0     	mov	x0, x24
     b3c: b9401000     	ldr	w0, [x0, #0x10]
     b40: b9401421     	ldr	w1, [x1, #0x14]
     b44: 6b01001f     	cmp	w0, w1
     b48: 54001ce2     	b.hs	0xee4 <___pl_fn_4+0x7e4>
     b4c: 72001e9f     	tst	w20, #0xff
     b50: 54001c60     	b.eq	0xedc <___pl_fn_4+0x7dc>
     b54: aa1803e0     	mov	x0, x24
     b58: aa1503e1     	mov	x1, x21
     b5c: aa1303e2     	mov	x2, x19
     b60: 94000000     	bl	0xb60 <___pl_fn_4+0x460>
     b64: aa1803e0     	mov	x0, x24
     b68: aa1503e3     	mov	x3, x21
     b6c: b9402c00     	ldr	w0, [x0, #0x2c]
     b70: 350021c0     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     b74: aa1803e0     	mov	x0, x24
     b78: b9001816     	str	w22, [x0, #0x18]
     b7c: b9401c00     	ldr	w0, [x0, #0x1c]
     b80: 11000ac1     	add	w1, w22, #0x2
     b84: 6b00003f     	cmp	w1, w0
     b88: 54001a68     	b.hi	0xed4 <___pl_fn_4+0x7d4>
     b8c: aa1803e0     	mov	x0, x24
     b90: f9401000     	ldr	x0, [x0, #0x20]
     b94: 8b170801     	add	x1, x0, x23, lsl #2
     b98: aa1b03e2     	mov	x2, x27
     b9c: b8365802     	str	w2, [x0, w22, uxtw #2]
     ba0: b9000423     	str	w3, [x1, #0x4]
     ba4: 11000ac0     	add	w0, w22, #0x2
     ba8: aa1803e1     	mov	x1, x24
     bac: b9001820     	str	w0, [x1, #0x18]
     bb0: aa1803e0     	mov	x0, x24
     bb4: b9401000     	ldr	w0, [x0, #0x10]
     bb8: b9401421     	ldr	w1, [x1, #0x14]
     bbc: 6b01001f     	cmp	w0, w1
     bc0: 54001862     	b.hs	0xecc <___pl_fn_4+0x7cc>
     bc4: d2800002     	mov	x2, #0x0                ; =0
     bc8: aa1803e0     	mov	x0, x24
     bcc: aa1b03e1     	mov	x1, x27
     bd0: 94000000     	bl	0xbd0 <___pl_fn_4+0x4d0>
     bd4: aa1803e0     	mov	x0, x24
     bd8: b9402c00     	ldr	w0, [x0, #0x2c]
     bdc: 35001e60     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     be0: aa1803e0     	mov	x0, x24
     be4: b9001816     	str	w22, [x0, #0x18]
     be8: b24107e0     	mov	x0, #-0x7fffffffffffffff ; =-9223372036854775807
     bec: eb00027f     	cmp	x19, x0
     bf0: 540016ab     	b.lt	0xec4 <___pl_fn_4+0x7c4>
     bf4: d1000673     	sub	x19, x19, #0x1
     bf8: 52800034     	mov	w20, #0x1               ; =1
     bfc: 17ffff08     	b	0x81c <___pl_fn_4+0x11c>
     c00: b27ff7e0     	mov	x0, #0x7ffffffffffffffe ; =9223372036854775806
     c04: aa1c03f4     	mov	x20, x28
     c08: eb00029f     	cmp	x20, x0
     c0c: 54001c0c     	b.gt	0xf8c <___pl_fn_4+0x88c>
     c10: aa1803e0     	mov	x0, x24
     c14: f9403c00     	ldr	x0, [x0, #0x78]
     c18: 372016e0     	tbnz	w0, #0x4, 0xef4 <___pl_fn_4+0x7f4>
     c1c: aa1803e0     	mov	x0, x24
     c20: f9403800     	ldr	x0, [x0, #0x70]
     c24: f100001f     	cmp	x0, #0x0
     c28: 540016ad     	b.le	0xefc <___pl_fn_4+0x7fc>
     c2c: aa1803e0     	mov	x0, x24
     c30: f9403400     	ldr	x0, [x0, #0x68]
     c34: f1000c1f     	cmp	x0, #0x3
     c38: 5400166b     	b.lt	0xf04 <___pl_fn_4+0x804>
     c3c: aa1803e0     	mov	x0, x24
     c40: f9402815     	ldr	x21, [x0, #0x50]
     c44: f9402c01     	ldr	x1, [x0, #0x58]
     c48: 910012a2     	add	x2, x21, #0x4
     c4c: eb01005f     	cmp	x2, x1
     c50: 540015e8     	b.hi	0xf0c <___pl_fn_4+0x80c>
     c54: aa1803e0     	mov	x0, x24
     c58: f9404404     	ldr	x4, [x0, #0x88]
     c5c: f9404805     	ldr	x5, [x0, #0x90]
     c60: eb05009f     	cmp	x4, x5
     c64: 54001582     	b.hs	0xf14 <___pl_fn_4+0x814>
     c68: aa1803e0     	mov	x0, x24
     c6c: b9401807     	ldr	w7, [x0, #0x18]
     c70: b9401c08     	ldr	w8, [x0, #0x1c]
     c74: 110004e7     	add	w7, w7, #0x1
     c78: 6b0800ff     	cmp	w7, w8
     c7c: 54000229     	b.ls	0xcc0 <___pl_fn_4+0x5c0>
     c80: 140000a7     	b	0xf1c <___pl_fn_4+0x81c>
     c84: aa1803e0     	mov	x0, x24
     c88: f940100c     	ldr	x12, [x0, #0x20]
     c8c: aa1b03e1     	mov	x1, x27
     c90: b8365981     	str	w1, [x12, w22, uxtw #2]
     c94: b900180a     	str	w10, [x0, #0x18]
     c98: 52800641     	mov	w1, #0x32               ; =50
     c9c: 52800002     	mov	w2, #0x0                ; =0
     ca0: 9000000e     	adrp	x14, 0x0 <___pl_fn_0>
     ca4: f94001ce     	ldr	x14, [x14]
     ca8: d63f01c0     	blr	x14
     cac: 350017e0     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     cb0: aa1803e0     	mov	x0, x24
     cb4: f9401815     	ldr	x21, [x0, #0x30]
     cb8: b9001816     	str	w22, [x0, #0x18]
     cbc: 14000026     	b	0xd54 <___pl_fn_4+0x654>
     cc0: aa1803e0     	mov	x0, x24
     cc4: f9403002     	ldr	x2, [x0, #0x60]
     cc8: f9400003     	ldr	x3, [x0]
     ccc: d2800066     	mov	x6, #0x3                ; =3
     cd0: f2c00046     	movk	x6, #0x2, lsl #32
     cd4: 2a1503e1     	mov	w1, w21
     cd8: d2800060     	mov	x0, #0x3                ; =3
     cdc: 8b010c65     	add	x5, x3, x1, lsl #3
     ce0: f8355866     	str	x6, [x3, w21, uxtw #3]
     ce4: 91000442     	add	x2, x2, #0x1
     ce8: f90004a2     	str	x2, [x5, #0x8]
     cec: d2800003     	mov	x3, #0x0                ; =0
     cf0: f90008a3     	str	x3, [x5, #0x10]
     cf4: f9000ca3     	str	x3, [x5, #0x18]
     cf8: aa1803e3     	mov	x3, x24
     cfc: f9003062     	str	x2, [x3, #0x60]
     d00: 910012a2     	add	x2, x21, #0x4
     d04: f9002862     	str	x2, [x3, #0x50]
     d08: aa1803e2     	mov	x2, x24
     d0c: f9403442     	ldr	x2, [x2, #0x68]
     d10: d1000c42     	sub	x2, x2, #0x3
     d14: f9003462     	str	x2, [x3, #0x68]
     d18: aa1803e2     	mov	x2, x24
     d1c: f9403842     	ldr	x2, [x2, #0x70]
     d20: d1000c42     	sub	x2, x2, #0x3
     d24: f9003862     	str	x2, [x3, #0x70]
     d28: aa1803e2     	mov	x2, x24
     d2c: f9404042     	ldr	x2, [x2, #0x80]
     d30: b25e0021     	orr	x1, x1, #0x400000000
     d34: d37cec83     	lsl	x3, x4, #4
     d38: 8b041045     	add	x5, x2, x4, lsl #4
     d3c: f8236841     	str	x1, [x2, x3]
     d40: f90004a0     	str	x0, [x5, #0x8]
     d44: 91000480     	add	x0, x4, #0x1
     d48: aa1803e1     	mov	x1, x24
     d4c: f9004420     	str	x0, [x1, #0x88]
     d50: aa1803e0     	mov	x0, x24
     d54: aa1803e0     	mov	x0, x24
     d58: b9401816     	ldr	w22, [x0, #0x18]
     d5c: b9401c00     	ldr	w0, [x0, #0x1c]
     d60: 11000ac1     	add	w1, w22, #0x2
     d64: 6b00003f     	cmp	w1, w0
     d68: 540010e8     	b.hi	0xf84 <___pl_fn_4+0x884>
     d6c: aa1803e0     	mov	x0, x24
     d70: f9401000     	ldr	x0, [x0, #0x20]
     d74: 2a1603e1     	mov	w1, w22
     d78: 8b010801     	add	x1, x0, x1, lsl #2
     d7c: aa1b03e2     	mov	x2, x27
     d80: b8365802     	str	w2, [x0, w22, uxtw #2]
     d84: b9000435     	str	w21, [x1, #0x4]
     d88: 11000ac0     	add	w0, w22, #0x2
     d8c: aa1803eb     	mov	x11, x24
     d90: b9001960     	str	w0, [x11, #0x18]
     d94: aa1803e0     	mov	x0, x24
     d98: b9401000     	ldr	w0, [x0, #0x10]
     d9c: aa1803ef     	mov	x15, x24
     da0: b94015e1     	ldr	w1, [x15, #0x14]
     da4: 6b01001f     	cmp	w0, w1
     da8: 54000ea2     	b.hs	0xf7c <___pl_fn_4+0x87c>
     dac: 91000682     	add	x2, x20, #0x1
     db0: aa1803e0     	mov	x0, x24
     db4: aa1503e1     	mov	x1, x21
     db8: 94000000     	bl	0xdb8 <___pl_fn_4+0x6b8>
     dbc: aa1803e0     	mov	x0, x24
     dc0: b9402c00     	ldr	w0, [x0, #0x2c]
     dc4: 35000f20     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     dc8: aa1803e0     	mov	x0, x24
     dcc: b9001816     	str	w22, [x0, #0x18]
     dd0: aa1b03e1     	mov	x1, x27
     dd4: 34000b61     	cbz	w1, 0xf40 <___pl_fn_4+0x840>
     dd8: aa1803e0     	mov	x0, x24
     ddc: f9400000     	ldr	x0, [x0]
     de0: aa1b03e1     	mov	x1, x27
     de4: 2a0103e1     	mov	w1, w1
     de8: 8b010c00     	add	x0, x0, x1, lsl #3
     dec: f9400801     	ldr	x1, [x0, #0x10]
     df0: eb01027f     	cmp	x19, x1
     df4: 54000a62     	b.hs	0xf40 <___pl_fn_4+0x840>
     df8: aa1b03e2     	mov	x2, x27
     dfc: 2a1503e1     	mov	w1, w21
     e00: 8b130c00     	add	x0, x0, x19, lsl #3
     e04: f9001401     	str	x1, [x0, #0x28]
     e08: b27ff7e0     	mov	x0, #0x7ffffffffffffffe ; =9223372036854775806
     e0c: eb00027f     	cmp	x19, x0
     e10: 54000b2c     	b.gt	0xf74 <___pl_fn_4+0x874>
     e14: 91000673     	add	x19, x19, #0x1
     e18: aa0203fb     	mov	x27, x2
     e1c: aa1403fc     	mov	x28, x20
     e20: 17fffe79     	b	0x804 <___pl_fn_4+0x104>
     e24: 52800441     	mov	w1, #0x22               ; =34
     e28: d2800003     	mov	x3, #0x0                ; =0
     e2c: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     e30: f94001ad     	ldr	x13, [x13]
     e34: aa1803e0     	mov	x0, x24
     e38: aa1a03e2     	mov	x2, x26
     e3c: d63f01a0     	blr	x13
     e40: 34ffd160     	cbz	w0, 0x86c <___pl_fn_4+0x16c>
     e44: 14000059     	b	0xfa8 <___pl_fn_4+0x8a8>
     e48: 528004a1     	mov	w1, #0x25               ; =37
     e4c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     e50: f9400063     	ldr	x3, [x3]
     e54: aa1a03e2     	mov	x2, x26
     e58: aa1803e0     	mov	x0, x24
     e5c: d63f0060     	blr	x3
     e60: 34ffd680     	cbz	w0, 0x930 <___pl_fn_4+0x230>
     e64: 14000051     	b	0xfa8 <___pl_fn_4+0x8a8>
     e68: 52800481     	mov	w1, #0x24               ; =36
     e6c: 1400004b     	b	0xf98 <___pl_fn_4+0x898>
     e70: 52800461     	mov	w1, #0x23               ; =35
     e74: 14000049     	b	0xf98 <___pl_fn_4+0x898>
     e78: aa1803e0     	mov	x0, x24
     e7c: 1400000a     	b	0xea4 <___pl_fn_4+0x7a4>
     e80: aa1803e0     	mov	x0, x24
     e84: 14000008     	b	0xea4 <___pl_fn_4+0x7a4>
     e88: aa1803e0     	mov	x0, x24
     e8c: 14000006     	b	0xea4 <___pl_fn_4+0x7a4>
     e90: aa1803e0     	mov	x0, x24
     e94: 14000004     	b	0xea4 <___pl_fn_4+0x7a4>
     e98: aa1803e0     	mov	x0, x24
     e9c: 14000002     	b	0xea4 <___pl_fn_4+0x7a4>
     ea0: aa1803e0     	mov	x0, x24
     ea4: aa1803e0     	mov	x0, x24
     ea8: b9401816     	ldr	w22, [x0, #0x18]
     eac: b9401c01     	ldr	w1, [x0, #0x1c]
     eb0: 110006c0     	add	w0, w22, #0x1
     eb4: 6b01001f     	cmp	w0, w1
     eb8: 54ffdb89     	b.ls	0xa28 <___pl_fn_4+0x328>
     ebc: 52800501     	mov	w1, #0x28               ; =40
     ec0: 14000036     	b	0xf98 <___pl_fn_4+0x898>
     ec4: 528005e1     	mov	w1, #0x2f               ; =47
     ec8: 14000034     	b	0xf98 <___pl_fn_4+0x898>
     ecc: 528005c1     	mov	w1, #0x2e               ; =46
     ed0: 14000032     	b	0xf98 <___pl_fn_4+0x898>
     ed4: 528005a1     	mov	w1, #0x2d               ; =45
     ed8: 14000030     	b	0xf98 <___pl_fn_4+0x898>
     edc: 52800581     	mov	w1, #0x2c               ; =44
     ee0: 1400002e     	b	0xf98 <___pl_fn_4+0x898>
     ee4: 52800561     	mov	w1, #0x2b               ; =43
     ee8: 1400002c     	b	0xf98 <___pl_fn_4+0x898>
     eec: 52800541     	mov	w1, #0x2a               ; =42
     ef0: 1400002a     	b	0xf98 <___pl_fn_4+0x898>
     ef4: aa1803e0     	mov	x0, x24
     ef8: 1400000a     	b	0xf20 <___pl_fn_4+0x820>
     efc: aa1803e0     	mov	x0, x24
     f00: 14000008     	b	0xf20 <___pl_fn_4+0x820>
     f04: aa1803e0     	mov	x0, x24
     f08: 14000006     	b	0xf20 <___pl_fn_4+0x820>
     f0c: aa1803e0     	mov	x0, x24
     f10: 14000004     	b	0xf20 <___pl_fn_4+0x820>
     f14: aa1803e0     	mov	x0, x24
     f18: 14000002     	b	0xf20 <___pl_fn_4+0x820>
     f1c: aa1803e0     	mov	x0, x24
     f20: aa1803e0     	mov	x0, x24
     f24: b9401816     	ldr	w22, [x0, #0x18]
     f28: b9401c0b     	ldr	w11, [x0, #0x1c]
     f2c: 110006ca     	add	w10, w22, #0x1
     f30: 6b0b015f     	cmp	w10, w11
     f34: 54ffea89     	b.ls	0xc84 <___pl_fn_4+0x584>
     f38: 52800621     	mov	w1, #0x31               ; =49
     f3c: 14000017     	b	0xf98 <___pl_fn_4+0x898>
     f40: 910023e3     	add	x3, sp, #0x8
     f44: f80083f3     	stur	x19, [sp, #0x8]
     f48: 2a1503e0     	mov	w0, w21
     f4c: f80103e0     	stur	x0, [sp, #0x10]
     f50: 528006a1     	mov	w1, #0x35               ; =53
     f54: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     f58: f9400084     	ldr	x4, [x4]
     f5c: aa1b03e2     	mov	x2, x27
     f60: aa1803e0     	mov	x0, x24
     f64: d63f0080     	blr	x4
     f68: 35000200     	cbnz	w0, 0xfa8 <___pl_fn_4+0x8a8>
     f6c: 528006c1     	mov	w1, #0x36               ; =54
     f70: 1400000a     	b	0xf98 <___pl_fn_4+0x898>
     f74: 528006e1     	mov	w1, #0x37               ; =55
     f78: 14000008     	b	0xf98 <___pl_fn_4+0x898>
     f7c: 52800681     	mov	w1, #0x34               ; =52
     f80: 14000006     	b	0xf98 <___pl_fn_4+0x898>
     f84: 52800661     	mov	w1, #0x33               ; =51
     f88: 14000004     	b	0xf98 <___pl_fn_4+0x898>
     f8c: 52800601     	mov	w1, #0x30               ; =48
     f90: 14000002     	b	0xf98 <___pl_fn_4+0x898>
     f94: 528003c1     	mov	w1, #0x1e               ; =30
     f98: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     f9c: f9400042     	ldr	x2, [x2]
     fa0: aa1803e0     	mov	x0, x24
     fa4: d63f0040     	blr	x2
     fa8: 910083ff     	add	sp, sp, #0x20
     fac: a8c153f3     	ldp	x19, x20, [sp], #0x10
     fb0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     fb4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     fb8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     fbc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     fc0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     fc4: d65f03c0     	ret

0000000000000fc8 <___pl_fn_5>:
     fc8: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     fcc: 910003fd     	mov	x29, sp
     fd0: f81f0ff3     	str	x19, [sp, #-0x10]!
     fd4: d10043ff     	sub	sp, sp, #0x10
     fd8: b9401003     	ldr	w3, [x0, #0x10]
     fdc: 11000464     	add	w4, w3, #0x1
     fe0: b9001004     	str	w4, [x0, #0x10]
     fe4: aa0003f3     	mov	x19, x0
     fe8: 340001c1     	cbz	w1, 0x1020 <___pl_fn_5+0x58>
     fec: aa0203e4     	mov	x4, x2
     ff0: aa0103e2     	mov	x2, x1
     ff4: aa1303e0     	mov	x0, x19
     ff8: f9400001     	ldr	x1, [x0]
     ffc: 2a0203e2     	mov	w2, w2
    1000: 8b020c21     	add	x1, x1, x2, lsl #3
    1004: aa0403e2     	mov	x2, x4
    1008: f9000822     	str	x2, [x1, #0x10]
    100c: b9001003     	str	w3, [x0, #0x10]
    1010: 910043ff     	add	sp, sp, #0x10
    1014: f84107f3     	ldr	x19, [sp], #0x10
    1018: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    101c: d65f03c0     	ret
    1020: aa0103e5     	mov	x5, x1
    1024: d2800000     	mov	x0, #0x0                ; =0
    1028: 910003e3     	mov	x3, sp
    102c: f80003e0     	stur	x0, [sp]
    1030: f80083e2     	stur	x2, [sp, #0x8]
    1034: 52800701     	mov	w1, #0x38               ; =56
    1038: 90000004     	adrp	x4, 0x1000 <___pl_fn_5+0x38>
    103c: f9400084     	ldr	x4, [x4]
    1040: aa0503e2     	mov	x2, x5
    1044: aa1303e0     	mov	x0, x19
    1048: d63f0080     	blr	x4
    104c: 350000c0     	cbnz	w0, 0x1064 <___pl_fn_5+0x9c>
    1050: 52800721     	mov	w1, #0x39               ; =57
    1054: 90000002     	adrp	x2, 0x1000 <___pl_fn_5+0x38>
    1058: f9400042     	ldr	x2, [x2]
    105c: aa1303e0     	mov	x0, x19
    1060: d63f0040     	blr	x2
    1064: 910043ff     	add	sp, sp, #0x10
    1068: f84107f3     	ldr	x19, [sp], #0x10
    106c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1070: d65f03c0     	ret
