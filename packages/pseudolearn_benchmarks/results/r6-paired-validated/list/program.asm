
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_12444/list/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: a9bf5ff5     	stp	x21, x23, [sp, #-0x10]!
       c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      10: d10103ff     	sub	sp, sp, #0x40
      14: aa0103f3     	mov	x19, x1
      18: b9401001     	ldr	w1, [x0, #0x10]
      1c: 11000421     	add	w1, w1, #0x1
      20: b9001001     	str	w1, [x0, #0x10]
      24: aa0003f4     	mov	x20, x0
      28: 52800002     	mov	w2, #0x0                ; =0
      2c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
      30: f9400063     	ldr	x3, [x3]
      34: aa1403e0     	mov	x0, x20
      38: aa0203e1     	mov	x1, x2
      3c: d63f0060     	blr	x3
      40: 35001c20     	cbnz	w0, 0x3c4 <___pl_fn_0+0x3c4>
      44: aa1403e0     	mov	x0, x20
      48: f9401800     	ldr	x0, [x0, #0x30]
      4c: 34001a60     	cbz	w0, 0x398 <___pl_fn_0+0x398>
      50: aa1303f7     	mov	x23, x19
      54: b4000bd7     	cbz	x23, 0x1cc <___pl_fn_0+0x1cc>
      58: 35000080     	cbnz	w0, 0x68 <___pl_fn_0+0x68>
      5c: 1400007a     	b	0x244 <___pl_fn_0+0x244>
      60: aa1503e0     	mov	x0, x21
      64: 1400000f     	b	0xa0 <___pl_fn_0+0xa0>
      68: aa0003f5     	mov	x21, x0
      6c: aa1403e0     	mov	x0, x20
      70: f9400001     	ldr	x1, [x0]
      74: aa1503e0     	mov	x0, x21
      78: 2a0003e0     	mov	w0, w0
      7c: 8b000c20     	add	x0, x1, x0, lsl #3
      80: aa1503e2     	mov	x2, x21
      84: f8625822     	ldr	x2, [x1, w2, uxtw #3]
      88: d2800001     	mov	x1, #0x0                ; =0
      8c: d360fc42     	lsr	x2, x2, #32
      90: 92403c42     	and	x2, x2, #0xffff
      94: 91000842     	add	x2, x2, #0x2
      98: f8227801     	str	x1, [x0, x2, lsl #3]
      9c: aa1503e0     	mov	x0, x21
      a0: aa1503e0     	mov	x0, x21
      a4: 34000ec0     	cbz	w0, 0x27c <___pl_fn_0+0x27c>
      a8: aa1403e0     	mov	x0, x20
      ac: f9400001     	ldr	x1, [x0]
      b0: aa1503e0     	mov	x0, x21
      b4: 2a0003e0     	mov	w0, w0
      b8: 8b000c20     	add	x0, x1, x0, lsl #3
      bc: aa1503e2     	mov	x2, x21
      c0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
      c4: d360fc21     	lsr	x1, x1, #32
      c8: 92403c22     	and	x2, x1, #0xffff
      cc: f100085f     	cmp	x2, #0x2
      d0: 54000080     	b.eq	0xe0 <___pl_fn_0+0xe0>
      d4: f9400802     	ldr	x2, [x0, #0x10]
      d8: 927ff842     	and	x2, x2, #0xfffffffffffffffe
      dc: f9000802     	str	x2, [x0, #0x10]
      e0: 92403c21     	and	x1, x1, #0xffff
      e4: f8217817     	str	x23, [x0, x1, lsl #3]
      e8: d2800020     	mov	x0, #0x1                ; =1
      ec: eb0002e1     	subs	x1, x23, x0
      f0: 9a9f77e0     	cset	x0, vs
      f4: 72001c1f     	tst	w0, #0xff
      f8: 54001201     	b.ne	0x338 <___pl_fn_0+0x338>
      fc: aa1403e0     	mov	x0, x20
     100: b9401813     	ldr	w19, [x0, #0x18]
     104: b9401c02     	ldr	w2, [x0, #0x1c]
     108: 11000660     	add	w0, w19, #0x1
     10c: 6b02001f     	cmp	w0, w2
     110: 54000fe8     	b.hi	0x30c <___pl_fn_0+0x30c>
     114: aa1403e2     	mov	x2, x20
     118: f9401042     	ldr	x2, [x2, #0x20]
     11c: aa1503ed     	mov	x13, x21
     120: b833584d     	str	w13, [x2, w19, uxtw #2]
     124: aa1403e2     	mov	x2, x20
     128: b9001840     	str	w0, [x2, #0x18]
     12c: aa1403e0     	mov	x0, x20
     130: b9401004     	ldr	w4, [x0, #0x10]
     134: b9401405     	ldr	w5, [x0, #0x14]
     138: 6b05009f     	cmp	w4, w5
     13c: 54000d22     	b.hs	0x2e0 <___pl_fn_0+0x2e0>
     140: aa1403e0     	mov	x0, x20
     144: 94000000     	bl	0x144 <___pl_fn_0+0x144>
     148: aa1403e1     	mov	x1, x20
     14c: b9402c26     	ldr	w6, [x1, #0x2c]
     150: 350013a6     	cbnz	w6, 0x3c4 <___pl_fn_0+0x3c4>
     154: aa1403e4     	mov	x4, x20
     158: b9001893     	str	w19, [x4, #0x18]
     15c: aa1503e1     	mov	x1, x21
     160: 35000081     	cbnz	w1, 0x170 <___pl_fn_0+0x170>
     164: 14000052     	b	0x2ac <___pl_fn_0+0x2ac>
     168: aa1403e0     	mov	x0, x20
     16c: 1400000d     	b	0x1a0 <___pl_fn_0+0x1a0>
     170: aa1403e1     	mov	x1, x20
     174: f9400021     	ldr	x1, [x1]
     178: aa1503e2     	mov	x2, x21
     17c: 2a0203ef     	mov	w15, w2
     180: 8b0f0c2f     	add	x15, x1, x15, lsl #3
     184: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     188: 2a0003e0     	mov	w0, w0
     18c: d360fc21     	lsr	x1, x1, #32
     190: 92403c21     	and	x1, x1, #0xffff
     194: 91000421     	add	x1, x1, #0x1
     198: f82179e0     	str	x0, [x15, x1, lsl #3]
     19c: aa1403e0     	mov	x0, x20
     1a0: aa1403e0     	mov	x0, x20
     1a4: b9401000     	ldr	w0, [x0, #0x10]
     1a8: 51000400     	sub	w0, w0, #0x1
     1ac: aa1403e1     	mov	x1, x20
     1b0: b9001020     	str	w0, [x1, #0x10]
     1b4: aa1503e0     	mov	x0, x21
     1b8: 910103ff     	add	sp, sp, #0x40
     1bc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     1c0: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     1c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     1c8: d65f03c0     	ret
     1cc: aa0003f5     	mov	x21, x0
     1d0: 35000080     	cbnz	w0, 0x1e0 <___pl_fn_0+0x1e0>
     1d4: 14000064     	b	0x364 <___pl_fn_0+0x364>
     1d8: aa1403e0     	mov	x0, x20
     1dc: 1400000e     	b	0x214 <___pl_fn_0+0x214>
     1e0: aa1403e0     	mov	x0, x20
     1e4: f9400001     	ldr	x1, [x0]
     1e8: aa1503e0     	mov	x0, x21
     1ec: 2a0003e0     	mov	w0, w0
     1f0: 8b000c20     	add	x0, x1, x0, lsl #3
     1f4: aa1503e2     	mov	x2, x21
     1f8: f8625822     	ldr	x2, [x1, w2, uxtw #3]
     1fc: d2800021     	mov	x1, #0x1                ; =1
     200: d360fc42     	lsr	x2, x2, #32
     204: 92403c42     	and	x2, x2, #0xffff
     208: 91000842     	add	x2, x2, #0x2
     20c: f8227801     	str	x1, [x0, x2, lsl #3]
     210: aa1403e0     	mov	x0, x20
     214: aa1403e0     	mov	x0, x20
     218: b9401000     	ldr	w0, [x0, #0x10]
     21c: 51000400     	sub	w0, w0, #0x1
     220: aa1403e1     	mov	x1, x20
     224: b9001020     	str	w0, [x1, #0x10]
     228: aa1503e0     	mov	x0, x21
     22c: 910103ff     	add	sp, sp, #0x40
     230: a8c153f3     	ldp	x19, x20, [sp], #0x10
     234: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     238: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     23c: d65f03c0     	ret
     240: 14000061     	b	0x3c4 <___pl_fn_0+0x3c4>
     244: aa0003f5     	mov	x21, x0
     248: d2800040     	mov	x0, #0x2                ; =2
     24c: 910003e3     	mov	x3, sp
     250: f80003e0     	stur	x0, [sp]
     254: d2800000     	mov	x0, #0x0                ; =0
     258: f80083e0     	stur	x0, [sp, #0x8]
     25c: 52800041     	mov	w1, #0x2                ; =2
     260: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     264: f9400084     	ldr	x4, [x4]
     268: aa1403e0     	mov	x0, x20
     26c: aa1503e2     	mov	x2, x21
     270: d63f0080     	blr	x4
     274: 34ffef60     	cbz	w0, 0x60 <___pl_fn_0+0x60>
     278: 14000053     	b	0x3c4 <___pl_fn_0+0x3c4>
     27c: d2800000     	mov	x0, #0x0                ; =0
     280: 910043e3     	add	x3, sp, #0x10
     284: f80103e0     	stur	x0, [sp, #0x10]
     288: f80183f7     	stur	x23, [sp, #0x18]
     28c: 52800061     	mov	w1, #0x3                ; =3
     290: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     294: f9400084     	ldr	x4, [x4]
     298: aa1403e0     	mov	x0, x20
     29c: aa1503e2     	mov	x2, x21
     2a0: d63f0080     	blr	x4
     2a4: 34fff220     	cbz	w0, 0xe8 <___pl_fn_0+0xe8>
     2a8: 14000047     	b	0x3c4 <___pl_fn_0+0x3c4>
     2ac: d280002a     	mov	x10, #0x1               ; =1
     2b0: 910083e3     	add	x3, sp, #0x20
     2b4: f80203ea     	stur	x10, [sp, #0x20]
     2b8: 2a0003eb     	mov	w11, w0
     2bc: f80283eb     	stur	x11, [sp, #0x28]
     2c0: 528000e1     	mov	w1, #0x7                ; =7
     2c4: 9000000c     	adrp	x12, 0x0 <___pl_fn_0>
     2c8: f940018c     	ldr	x12, [x12]
     2cc: aa1403e0     	mov	x0, x20
     2d0: aa1503e2     	mov	x2, x21
     2d4: d63f0180     	blr	x12
     2d8: 34fff480     	cbz	w0, 0x168 <___pl_fn_0+0x168>
     2dc: 1400003a     	b	0x3c4 <___pl_fn_0+0x3c4>
     2e0: 528000c1     	mov	w1, #0x6                ; =6
     2e4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     2e8: f9400042     	ldr	x2, [x2]
     2ec: aa1403e0     	mov	x0, x20
     2f0: d63f0040     	blr	x2
     2f4: 52800000     	mov	w0, #0x0                ; =0
     2f8: 910103ff     	add	sp, sp, #0x40
     2fc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     300: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     304: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     308: d65f03c0     	ret
     30c: 528000a1     	mov	w1, #0x5                ; =5
     310: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     314: f9400042     	ldr	x2, [x2]
     318: aa1403e0     	mov	x0, x20
     31c: d63f0040     	blr	x2
     320: 52800000     	mov	w0, #0x0                ; =0
     324: 910103ff     	add	sp, sp, #0x40
     328: a8c153f3     	ldp	x19, x20, [sp], #0x10
     32c: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     330: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     334: d65f03c0     	ret
     338: 52800081     	mov	w1, #0x4                ; =4
     33c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     340: f9400042     	ldr	x2, [x2]
     344: aa1403e0     	mov	x0, x20
     348: d63f0040     	blr	x2
     34c: 52800000     	mov	w0, #0x0                ; =0
     350: 910103ff     	add	sp, sp, #0x40
     354: a8c153f3     	ldp	x19, x20, [sp], #0x10
     358: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     35c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     360: d65f03c0     	ret
     364: d2800040     	mov	x0, #0x2                ; =2
     368: 9100c3e3     	add	x3, sp, #0x30
     36c: f80303e0     	stur	x0, [sp, #0x30]
     370: d2800020     	mov	x0, #0x1                ; =1
     374: f80383e0     	stur	x0, [sp, #0x38]
     378: 52800101     	mov	w1, #0x8                ; =8
     37c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     380: f9400084     	ldr	x4, [x4]
     384: aa1403e0     	mov	x0, x20
     388: aa1503e2     	mov	x2, x21
     38c: d63f0080     	blr	x4
     390: 34fff240     	cbz	w0, 0x1d8 <___pl_fn_0+0x1d8>
     394: 1400000c     	b	0x3c4 <___pl_fn_0+0x3c4>
     398: 52800021     	mov	w1, #0x1                ; =1
     39c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     3a0: f9400042     	ldr	x2, [x2]
     3a4: aa1403e0     	mov	x0, x20
     3a8: d63f0040     	blr	x2
     3ac: 52800000     	mov	w0, #0x0                ; =0
     3b0: 910103ff     	add	sp, sp, #0x40
     3b4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     3b8: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     3bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     3c0: d65f03c0     	ret
     3c4: 52800000     	mov	w0, #0x0                ; =0
     3c8: 910103ff     	add	sp, sp, #0x40
     3cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     3d0: a8c15ff5     	ldp	x21, x23, [sp], #0x10
     3d4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     3d8: d65f03c0     	ret

00000000000003dc <___pl_fn_1>:
     3dc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     3e0: 910003fd     	mov	x29, sp
     3e4: f81f0ff5     	str	x21, [sp, #-0x10]!
     3e8: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     3ec: b9401003     	ldr	w3, [x0, #0x10]
     3f0: 11000463     	add	w3, w3, #0x1
     3f4: b9001003     	str	w3, [x0, #0x10]
     3f8: aa0003f3     	mov	x19, x0
     3fc: 34001701     	cbz	w1, 0x6dc <___pl_fn_1+0x300>
     400: 340015a2     	cbz	w2, 0x6b4 <___pl_fn_1+0x2d8>
     404: aa0203f4     	mov	x20, x2
     408: aa0103f5     	mov	x21, x1
     40c: 34000d82     	cbz	w2, 0x5bc <___pl_fn_1+0x1e0>
     410: aa1303e0     	mov	x0, x19
     414: f9400001     	ldr	x1, [x0]
     418: 2a0203e0     	mov	w0, w2
     41c: 8b000c20     	add	x0, x1, x0, lsl #3
     420: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     424: aa0203f4     	mov	x20, x2
     428: d360fc21     	lsr	x1, x1, #32
     42c: 92403c21     	and	x1, x1, #0xffff
     430: 91000821     	add	x1, x1, #0x2
     434: d37df021     	lsl	x1, x1, #3
     438: 38616800     	ldrb	w0, [x0, x1]
     43c: 53001c01     	uxtb	w1, w0
     440: 7100083f     	cmp	w1, #0x2
     444: 54000081     	b.ne	0x454 <___pl_fn_1+0x78>
     448: 1400005e     	b	0x5c0 <___pl_fn_1+0x1e4>
     44c: aa1303e0     	mov	x0, x19
     450: f9401800     	ldr	x0, [x0, #0x30]
     454: 52000000     	eor	w0, w0, #0x1
     458: 72001c1f     	tst	w0, #0xff
     45c: 54000161     	b.ne	0x488 <___pl_fn_1+0xac>
     460: aa1303e0     	mov	x0, x19
     464: b9401000     	ldr	w0, [x0, #0x10]
     468: 51000400     	sub	w0, w0, #0x1
     46c: aa1303ee     	mov	x14, x19
     470: b90011c0     	str	w0, [x14, #0x10]
     474: 52800000     	mov	w0, #0x0                ; =0
     478: a8c153f3     	ldp	x19, x20, [sp], #0x10
     47c: f84107f5     	ldr	x21, [sp], #0x10
     480: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     484: d65f03c0     	ret
     488: aa1503e2     	mov	x2, x21
     48c: 34000ac2     	cbz	w2, 0x5e4 <___pl_fn_1+0x208>
     490: aa1303e0     	mov	x0, x19
     494: f9400001     	ldr	x1, [x0]
     498: 2a0203e0     	mov	w0, w2
     49c: 8b000c20     	add	x0, x1, x0, lsl #3
     4a0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     4a4: aa0203f5     	mov	x21, x2
     4a8: d360fc21     	lsr	x1, x1, #32
     4ac: 92403c21     	and	x1, x1, #0xffff
     4b0: 91000821     	add	x1, x1, #0x2
     4b4: d37df021     	lsl	x1, x1, #3
     4b8: 38616800     	ldrb	w0, [x0, x1]
     4bc: 53001c01     	uxtb	w1, w0
     4c0: 7100083f     	cmp	w1, #0x2
     4c4: 54000081     	b.ne	0x4d4 <___pl_fn_1+0xf8>
     4c8: 14000048     	b	0x5e8 <___pl_fn_1+0x20c>
     4cc: aa1303e0     	mov	x0, x19
     4d0: f9401800     	ldr	x0, [x0, #0x30]
     4d4: 72001c1f     	tst	w0, #0xff
     4d8: 540005e1     	b.ne	0x594 <___pl_fn_1+0x1b8>
     4dc: aa1503e2     	mov	x2, x21
     4e0: 34000962     	cbz	w2, 0x60c <___pl_fn_1+0x230>
     4e4: aa1303e0     	mov	x0, x19
     4e8: f9400001     	ldr	x1, [x0]
     4ec: aa1503e2     	mov	x2, x21
     4f0: 2a0203e0     	mov	w0, w2
     4f4: 8b000c20     	add	x0, x1, x0, lsl #3
     4f8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     4fc: d360fc21     	lsr	x1, x1, #32
     500: 92403c21     	and	x1, x1, #0xffff
     504: 91000421     	add	x1, x1, #0x1
     508: d37df021     	lsl	x1, x1, #3
     50c: b8616800     	ldr	w0, [x0, x1]
     510: 350000c0     	cbnz	w0, 0x528 <___pl_fn_1+0x14c>
     514: 1400003e     	b	0x60c <___pl_fn_1+0x230>
     518: aa1303e0     	mov	x0, x19
     51c: f9401802     	ldr	x2, [x0, #0x30]
     520: aa0203f5     	mov	x21, x2
     524: 14000003     	b	0x530 <___pl_fn_1+0x154>
     528: aa0003e2     	mov	x2, x0
     52c: aa0003f5     	mov	x21, x0
     530: 34000ae2     	cbz	w2, 0x68c <___pl_fn_1+0x2b0>
     534: aa1403e2     	mov	x2, x20
     538: 340007c2     	cbz	w2, 0x630 <___pl_fn_1+0x254>
     53c: aa1303e0     	mov	x0, x19
     540: f9400009     	ldr	x9, [x0]
     544: aa1403e2     	mov	x2, x20
     548: 2a0203e8     	mov	w8, w2
     54c: 8b080d28     	add	x8, x9, x8, lsl #3
     550: f8625929     	ldr	x9, [x9, w2, uxtw #3]
     554: d360fd29     	lsr	x9, x9, #32
     558: 92403d29     	and	x9, x9, #0xffff
     55c: 91000529     	add	x9, x9, #0x1
     560: d37df129     	lsl	x9, x9, #3
     564: b8696908     	ldr	w8, [x8, x9]
     568: 350000c8     	cbnz	w8, 0x580 <___pl_fn_1+0x1a4>
     56c: 14000031     	b	0x630 <___pl_fn_1+0x254>
     570: aa1303e0     	mov	x0, x19
     574: f9401802     	ldr	x2, [x0, #0x30]
     578: aa0203f4     	mov	x20, x2
     57c: 14000003     	b	0x588 <___pl_fn_1+0x1ac>
     580: aa0803e2     	mov	x2, x8
     584: aa0803f4     	mov	x20, x8
     588: 340006e2     	cbz	w2, 0x664 <___pl_fn_1+0x288>
     58c: aa1403e2     	mov	x2, x20
     590: 17ffff9f     	b	0x40c <___pl_fn_1+0x30>
     594: aa1303e0     	mov	x0, x19
     598: b9401000     	ldr	w0, [x0, #0x10]
     59c: 51000400     	sub	w0, w0, #0x1
     5a0: aa1303e1     	mov	x1, x19
     5a4: b9001020     	str	w0, [x1, #0x10]
     5a8: 52800020     	mov	w0, #0x1                ; =1
     5ac: a8c153f3     	ldp	x19, x20, [sp], #0x10
     5b0: f84107f5     	ldr	x21, [sp], #0x10
     5b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     5b8: d65f03c0     	ret
     5bc: aa0203f4     	mov	x20, x2
     5c0: 52800161     	mov	w1, #0xb                ; =11
     5c4: 52800043     	mov	w3, #0x2                ; =2
     5c8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5cc: f9400084     	ldr	x4, [x4]
     5d0: aa1303e0     	mov	x0, x19
     5d4: aa1403e2     	mov	x2, x20
     5d8: d63f0080     	blr	x4
     5dc: 34fff380     	cbz	w0, 0x44c <___pl_fn_1+0x70>
     5e0: 1400001c     	b	0x650 <___pl_fn_1+0x274>
     5e4: aa0203f5     	mov	x21, x2
     5e8: 52800181     	mov	w1, #0xc                ; =12
     5ec: 52800043     	mov	w3, #0x2                ; =2
     5f0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5f4: f9400084     	ldr	x4, [x4]
     5f8: aa1303e0     	mov	x0, x19
     5fc: aa1503e2     	mov	x2, x21
     600: d63f0080     	blr	x4
     604: 34fff640     	cbz	w0, 0x4cc <___pl_fn_1+0xf0>
     608: 14000012     	b	0x650 <___pl_fn_1+0x274>
     60c: 528001a1     	mov	w1, #0xd                ; =13
     610: 52800023     	mov	w3, #0x1                ; =1
     614: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     618: f9400084     	ldr	x4, [x4]
     61c: aa1503e2     	mov	x2, x21
     620: aa1303e0     	mov	x0, x19
     624: d63f0080     	blr	x4
     628: 34fff780     	cbz	w0, 0x518 <___pl_fn_1+0x13c>
     62c: 14000009     	b	0x650 <___pl_fn_1+0x274>
     630: 528001e1     	mov	w1, #0xf                ; =15
     634: 52800023     	mov	w3, #0x1                ; =1
     638: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     63c: f940014a     	ldr	x10, [x10]
     640: aa1403e2     	mov	x2, x20
     644: aa1303e0     	mov	x0, x19
     648: d63f0140     	blr	x10
     64c: 34fff920     	cbz	w0, 0x570 <___pl_fn_1+0x194>
     650: 52800000     	mov	w0, #0x0                ; =0
     654: a8c153f3     	ldp	x19, x20, [sp], #0x10
     658: f84107f5     	ldr	x21, [sp], #0x10
     65c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     660: d65f03c0     	ret
     664: 52800201     	mov	w1, #0x10               ; =16
     668: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     66c: f9400042     	ldr	x2, [x2]
     670: aa1303e0     	mov	x0, x19
     674: d63f0040     	blr	x2
     678: 52800000     	mov	w0, #0x0                ; =0
     67c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     680: f84107f5     	ldr	x21, [sp], #0x10
     684: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     688: d65f03c0     	ret
     68c: 528001c1     	mov	w1, #0xe                ; =14
     690: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     694: f9400042     	ldr	x2, [x2]
     698: aa1303e0     	mov	x0, x19
     69c: d63f0040     	blr	x2
     6a0: 52800000     	mov	w0, #0x0                ; =0
     6a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6a8: f84107f5     	ldr	x21, [sp], #0x10
     6ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6b0: d65f03c0     	ret
     6b4: 52800141     	mov	w1, #0xa                ; =10
     6b8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6bc: f9400042     	ldr	x2, [x2]
     6c0: aa1303e0     	mov	x0, x19
     6c4: d63f0040     	blr	x2
     6c8: 52800000     	mov	w0, #0x0                ; =0
     6cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6d0: f84107f5     	ldr	x21, [sp], #0x10
     6d4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6d8: d65f03c0     	ret
     6dc: 52800121     	mov	w1, #0x9                ; =9
     6e0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6e4: f9400042     	ldr	x2, [x2]
     6e8: aa1303e0     	mov	x0, x19
     6ec: d63f0040     	blr	x2
     6f0: 52800000     	mov	w0, #0x0                ; =0
     6f4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6f8: f84107f5     	ldr	x21, [sp], #0x10
     6fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     700: d65f03c0     	ret

0000000000000704 <___pl_fn_2>:
     704: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     708: 910003fd     	mov	x29, sp
     70c: f81f0ffb     	str	x27, [sp, #-0x10]!
     710: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
     714: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     718: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     71c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     720: b9401004     	ldr	w4, [x0, #0x10]
     724: 11000484     	add	w4, w4, #0x1
     728: b9001004     	str	w4, [x0, #0x10]
     72c: b9401817     	ldr	w23, [x0, #0x18]
     730: b9401c04     	ldr	w4, [x0, #0x1c]
     734: 11000ee5     	add	w5, w23, #0x3
     738: 6b0400bf     	cmp	w5, w4
     73c: 54003108     	b.hi	0xd5c <___pl_fn_2+0x658>
     740: f9401004     	ldr	x4, [x0, #0x20]
     744: 2a1703e5     	mov	w5, w23
     748: 8b050885     	add	x5, x4, x5, lsl #2
     74c: b8375881     	str	w1, [x4, w23, uxtw #2]
     750: aa0103e4     	mov	x4, x1
     754: b90004a2     	str	w2, [x5, #0x4]
     758: aa0203ef     	mov	x15, x2
     75c: b90008a3     	str	w3, [x5, #0x8]
     760: aa0303f9     	mov	x25, x3
     764: 11000ee1     	add	w1, w23, #0x3
     768: b9001801     	str	w1, [x0, #0x18]
     76c: b9401001     	ldr	w1, [x0, #0x10]
     770: b9401402     	ldr	w2, [x0, #0x14]
     774: aa0003f8     	mov	x24, x0
     778: 6b02003f     	cmp	w1, w2
     77c: 54002d62     	b.hs	0xd28 <___pl_fn_2+0x624>
     780: aa0f03f3     	mov	x19, x15
     784: aa0403f4     	mov	x20, x4
     788: aa1803e0     	mov	x0, x24
     78c: aa1303e1     	mov	x1, x19
     790: aa1403e2     	mov	x2, x20
     794: 94000000     	bl	0x794 <___pl_fn_2+0x90>
     798: aa1803e1     	mov	x1, x24
     79c: b9402c21     	ldr	w1, [x1, #0x2c]
     7a0: 35002b41     	cbnz	w1, 0xd08 <___pl_fn_2+0x604>
     7a4: aa1803e1     	mov	x1, x24
     7a8: b9001837     	str	w23, [x1, #0x18]
     7ac: 72001c1f     	tst	w0, #0xff
     7b0: 540001c1     	b.ne	0x7e8 <___pl_fn_2+0xe4>
     7b4: aa1803e0     	mov	x0, x24
     7b8: b9401000     	ldr	w0, [x0, #0x10]
     7bc: 51000400     	sub	w0, w0, #0x1
     7c0: aa1803e1     	mov	x1, x24
     7c4: b9001020     	str	w0, [x1, #0x10]
     7c8: aa1903e0     	mov	x0, x25
     7cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7d4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7d8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7dc: f84107fb     	ldr	x27, [sp], #0x10
     7e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7e4: d65f03c0     	ret
     7e8: 340018b4     	cbz	w20, 0xafc <___pl_fn_2+0x3f8>
     7ec: aa1803e0     	mov	x0, x24
     7f0: f9400001     	ldr	x1, [x0]
     7f4: 2a1403e0     	mov	w0, w20
     7f8: 8b000c20     	add	x0, x1, x0, lsl #3
     7fc: f8745821     	ldr	x1, [x1, w20, uxtw #3]
     800: d360fc21     	lsr	x1, x1, #32
     804: 92403c21     	and	x1, x1, #0xffff
     808: 91000421     	add	x1, x1, #0x1
     80c: d37df021     	lsl	x1, x1, #3
     810: b8616801     	ldr	w1, [x0, x1]
     814: 350000a1     	cbnz	w1, 0x828 <___pl_fn_2+0x124>
     818: 140000b9     	b	0xafc <___pl_fn_2+0x3f8>
     81c: aa1803e0     	mov	x0, x24
     820: f9401801     	ldr	x1, [x0, #0x30]
     824: 14000002     	b	0x82c <___pl_fn_2+0x128>
     828: aa1803e0     	mov	x0, x24
     82c: aa1803e0     	mov	x0, x24
     830: b9401815     	ldr	w21, [x0, #0x18]
     834: b9401c00     	ldr	w0, [x0, #0x1c]
     838: 110012a2     	add	w2, w21, #0x4
     83c: 6b00005f     	cmp	w2, w0
     840: 540024a8     	b.hi	0xcd4 <___pl_fn_2+0x5d0>
     844: aa1803e0     	mov	x0, x24
     848: f9401002     	ldr	x2, [x0, #0x20]
     84c: 2a1503e0     	mov	w0, w21
     850: 8b000840     	add	x0, x2, x0, lsl #2
     854: b8355854     	str	w20, [x2, w21, uxtw #2]
     858: b9000413     	str	w19, [x0, #0x4]
     85c: aa1903e2     	mov	x2, x25
     860: b9000802     	str	w2, [x0, #0x8]
     864: b9000c01     	str	w1, [x0, #0xc]
     868: 110012a0     	add	w0, w21, #0x4
     86c: aa1803e2     	mov	x2, x24
     870: b9001840     	str	w0, [x2, #0x18]
     874: aa1803e0     	mov	x0, x24
     878: b9401000     	ldr	w0, [x0, #0x10]
     87c: b9401442     	ldr	w2, [x2, #0x14]
     880: 6b02001f     	cmp	w0, w2
     884: 540020e2     	b.hs	0xca0 <___pl_fn_2+0x59c>
     888: aa1803e0     	mov	x0, x24
     88c: aa1303e2     	mov	x2, x19
     890: aa1903e3     	mov	x3, x25
     894: 94000000     	bl	0x894 <___pl_fn_2+0x190>
     898: aa0003f7     	mov	x23, x0
     89c: aa1803e0     	mov	x0, x24
     8a0: b9402c00     	ldr	w0, [x0, #0x2c]
     8a4: 35002320     	cbnz	w0, 0xd08 <___pl_fn_2+0x604>
     8a8: aa1803e0     	mov	x0, x24
     8ac: b9001815     	str	w21, [x0, #0x18]
     8b0: 34001393     	cbz	w19, 0xb20 <___pl_fn_2+0x41c>
     8b4: aa1803e0     	mov	x0, x24
     8b8: f9400001     	ldr	x1, [x0]
     8bc: 2a1303e0     	mov	w0, w19
     8c0: 8b000c20     	add	x0, x1, x0, lsl #3
     8c4: f8735821     	ldr	x1, [x1, w19, uxtw #3]
     8c8: d360fc21     	lsr	x1, x1, #32
     8cc: 92403c21     	and	x1, x1, #0xffff
     8d0: 91000421     	add	x1, x1, #0x1
     8d4: d37df021     	lsl	x1, x1, #3
     8d8: b8616801     	ldr	w1, [x0, x1]
     8dc: 350000a1     	cbnz	w1, 0x8f0 <___pl_fn_2+0x1ec>
     8e0: 14000090     	b	0xb20 <___pl_fn_2+0x41c>
     8e4: aa1803e0     	mov	x0, x24
     8e8: f9401801     	ldr	x1, [x0, #0x30]
     8ec: 14000002     	b	0x8f4 <___pl_fn_2+0x1f0>
     8f0: aa1803e0     	mov	x0, x24
     8f4: aa1803e0     	mov	x0, x24
     8f8: b9401816     	ldr	w22, [x0, #0x18]
     8fc: b9401c04     	ldr	w4, [x0, #0x1c]
     900: 110016c5     	add	w5, w22, #0x5
     904: 6b0400bf     	cmp	w5, w4
     908: 54001b28     	b.hi	0xc6c <___pl_fn_2+0x568>
     90c: aa1803e0     	mov	x0, x24
     910: f9401007     	ldr	x7, [x0, #0x20]
     914: 2a1603e6     	mov	w6, w22
     918: 8b0608e6     	add	x6, x7, x6, lsl #2
     91c: b83658f4     	str	w20, [x7, w22, uxtw #2]
     920: b90004d3     	str	w19, [x6, #0x4]
     924: aa1903e0     	mov	x0, x25
     928: b90008c0     	str	w0, [x6, #0x8]
     92c: aa1703f5     	mov	x21, x23
     930: b9000cd5     	str	w21, [x6, #0xc]
     934: b90010c1     	str	w1, [x6, #0x10]
     938: 110016cb     	add	w11, w22, #0x5
     93c: aa1803e0     	mov	x0, x24
     940: b900180b     	str	w11, [x0, #0x18]
     944: b940100c     	ldr	w12, [x0, #0x10]
     948: b940140d     	ldr	w13, [x0, #0x14]
     94c: 6b0d019f     	cmp	w12, w13
     950: 54001742     	b.hs	0xc38 <___pl_fn_2+0x534>
     954: aa1803e0     	mov	x0, x24
     958: aa1903e2     	mov	x2, x25
     95c: aa1403e3     	mov	x3, x20
     960: 94000000     	bl	0x960 <___pl_fn_2+0x25c>
     964: aa0003fa     	mov	x26, x0
     968: aa1803e0     	mov	x0, x24
     96c: b9402c0e     	ldr	w14, [x0, #0x2c]
     970: 35001cce     	cbnz	w14, 0xd08 <___pl_fn_2+0x604>
     974: aa1803e0     	mov	x0, x24
     978: b9001816     	str	w22, [x0, #0x18]
     97c: aa1903e0     	mov	x0, x25
     980: 34000e20     	cbz	w0, 0xb44 <___pl_fn_2+0x440>
     984: aa1803e0     	mov	x0, x24
     988: f9400001     	ldr	x1, [x0]
     98c: aa1903e0     	mov	x0, x25
     990: 2a0003e0     	mov	w0, w0
     994: 8b000c20     	add	x0, x1, x0, lsl #3
     998: aa1903e2     	mov	x2, x25
     99c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     9a0: d360fc21     	lsr	x1, x1, #32
     9a4: 92403c21     	and	x1, x1, #0xffff
     9a8: 91000421     	add	x1, x1, #0x1
     9ac: d37df021     	lsl	x1, x1, #3
     9b0: b8616801     	ldr	w1, [x0, x1]
     9b4: 350000a1     	cbnz	w1, 0x9c8 <___pl_fn_2+0x2c4>
     9b8: 14000063     	b	0xb44 <___pl_fn_2+0x440>
     9bc: aa1803e0     	mov	x0, x24
     9c0: f9401801     	ldr	x1, [x0, #0x30]
     9c4: 14000002     	b	0x9cc <___pl_fn_2+0x2c8>
     9c8: aa1803e0     	mov	x0, x24
     9cc: aa1803e0     	mov	x0, x24
     9d0: b9401819     	ldr	w25, [x0, #0x18]
     9d4: b9401c02     	ldr	w2, [x0, #0x1c]
     9d8: 11001720     	add	w0, w25, #0x5
     9dc: 6b02001f     	cmp	w0, w2
     9e0: 54001128     	b.hi	0xc04 <___pl_fn_2+0x500>
     9e4: aa1803ef     	mov	x15, x24
     9e8: f94011e3     	ldr	x3, [x15, #0x20]
     9ec: 2a1903fb     	mov	w27, w25
     9f0: 8b1b0862     	add	x2, x3, x27, lsl #2
     9f4: b8395874     	str	w20, [x3, w25, uxtw #2]
     9f8: aa1403e4     	mov	x4, x20
     9fc: b9000453     	str	w19, [x2, #0x4]
     a00: aa1303ef     	mov	x15, x19
     a04: b9000855     	str	w21, [x2, #0x8]
     a08: aa1a03f3     	mov	x19, x26
     a0c: b9000c53     	str	w19, [x2, #0xc]
     a10: b9001041     	str	w1, [x2, #0x10]
     a14: aa1803e2     	mov	x2, x24
     a18: b9001840     	str	w0, [x2, #0x18]
     a1c: aa1803e0     	mov	x0, x24
     a20: b9401000     	ldr	w0, [x0, #0x10]
     a24: b9401442     	ldr	w2, [x2, #0x14]
     a28: 6b02001f     	cmp	w0, w2
     a2c: 54000d22     	b.hs	0xbd0 <___pl_fn_2+0x4cc>
     a30: aa0403e2     	mov	x2, x4
     a34: aa0f03e3     	mov	x3, x15
     a38: aa1803e0     	mov	x0, x24
     a3c: 94000000     	bl	0xa3c <___pl_fn_2+0x338>
     a40: aa1803e1     	mov	x1, x24
     a44: b9402c21     	ldr	w1, [x1, #0x2c]
     a48: 35001601     	cbnz	w1, 0xd08 <___pl_fn_2+0x604>
     a4c: aa1803e1     	mov	x1, x24
     a50: b9001839     	str	w25, [x1, #0x18]
     a54: b9401c22     	ldr	w2, [x1, #0x1c]
     a58: 11000f21     	add	w1, w25, #0x3
     a5c: 6b02003f     	cmp	w1, w2
     a60: 540009e8     	b.hi	0xb9c <___pl_fn_2+0x498>
     a64: aa1803e2     	mov	x2, x24
     a68: f9401043     	ldr	x3, [x2, #0x20]
     a6c: 8b1b0862     	add	x2, x3, x27, lsl #2
     a70: b8395875     	str	w21, [x3, w25, uxtw #2]
     a74: aa1503f7     	mov	x23, x21
     a78: b9000453     	str	w19, [x2, #0x4]
     a7c: aa1303fa     	mov	x26, x19
     a80: b9000840     	str	w0, [x2, #0x8]
     a84: aa0003e3     	mov	x3, x0
     a88: aa1803e0     	mov	x0, x24
     a8c: b9001801     	str	w1, [x0, #0x18]
     a90: b9401000     	ldr	w0, [x0, #0x10]
     a94: aa1803e1     	mov	x1, x24
     a98: b9401421     	ldr	w1, [x1, #0x14]
     a9c: 6b01001f     	cmp	w0, w1
     aa0: 54000642     	b.hs	0xb68 <___pl_fn_2+0x464>
     aa4: aa1703e1     	mov	x1, x23
     aa8: aa1a03e2     	mov	x2, x26
     aac: aa1803e0     	mov	x0, x24
     ab0: 94000000     	bl	0xab0 <___pl_fn_2+0x3ac>
     ab4: aa1803e1     	mov	x1, x24
     ab8: b9402c21     	ldr	w1, [x1, #0x2c]
     abc: 35001261     	cbnz	w1, 0xd08 <___pl_fn_2+0x604>
     ac0: aa1803e1     	mov	x1, x24
     ac4: b9001839     	str	w25, [x1, #0x18]
     ac8: aa1803e2     	mov	x2, x24
     acc: b9401041     	ldr	w1, [x2, #0x10]
     ad0: 51000421     	sub	w1, w1, #0x1
     ad4: aa1803e5     	mov	x5, x24
     ad8: b90010a1     	str	w1, [x5, #0x10]
     adc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ae0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ae4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ae8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     aec: f84107fb     	ldr	x27, [sp], #0x10
     af0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     af4: d65f03c0     	ret
     af8: 14000084     	b	0xd08 <___pl_fn_2+0x604>
     afc: 52800261     	mov	w1, #0x13               ; =19
     b00: 52800023     	mov	w3, #0x1                ; =1
     b04: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b08: f9400084     	ldr	x4, [x4]
     b0c: aa1803e0     	mov	x0, x24
     b10: aa1403e2     	mov	x2, x20
     b14: d63f0080     	blr	x4
     b18: 34ffe820     	cbz	w0, 0x81c <___pl_fn_2+0x118>
     b1c: 1400007b     	b	0xd08 <___pl_fn_2+0x604>
     b20: 528002c1     	mov	w1, #0x16               ; =22
     b24: 52800023     	mov	w3, #0x1                ; =1
     b28: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b2c: f9400084     	ldr	x4, [x4]
     b30: aa1803e0     	mov	x0, x24
     b34: aa1303e2     	mov	x2, x19
     b38: d63f0080     	blr	x4
     b3c: 34ffed40     	cbz	w0, 0x8e4 <___pl_fn_2+0x1e0>
     b40: 14000072     	b	0xd08 <___pl_fn_2+0x604>
     b44: 52800321     	mov	w1, #0x19               ; =25
     b48: 52800023     	mov	w3, #0x1                ; =1
     b4c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b50: f9400084     	ldr	x4, [x4]
     b54: aa1903e2     	mov	x2, x25
     b58: aa1803e0     	mov	x0, x24
     b5c: d63f0080     	blr	x4
     b60: 34fff2e0     	cbz	w0, 0x9bc <___pl_fn_2+0x2b8>
     b64: 14000069     	b	0xd08 <___pl_fn_2+0x604>
     b68: 528003a1     	mov	w1, #0x1d               ; =29
     b6c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b70: f9400042     	ldr	x2, [x2]
     b74: aa1803e0     	mov	x0, x24
     b78: d63f0040     	blr	x2
     b7c: 52800000     	mov	w0, #0x0                ; =0
     b80: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b84: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b88: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b8c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b90: f84107fb     	ldr	x27, [sp], #0x10
     b94: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b98: d65f03c0     	ret
     b9c: 52800381     	mov	w1, #0x1c               ; =28
     ba0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     ba4: f9400042     	ldr	x2, [x2]
     ba8: aa1803e0     	mov	x0, x24
     bac: d63f0040     	blr	x2
     bb0: 52800000     	mov	w0, #0x0                ; =0
     bb4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     bb8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     bbc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     bc0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     bc4: f84107fb     	ldr	x27, [sp], #0x10
     bc8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     bcc: d65f03c0     	ret
     bd0: 52800361     	mov	w1, #0x1b               ; =27
     bd4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     bd8: f9400042     	ldr	x2, [x2]
     bdc: aa1803e0     	mov	x0, x24
     be0: d63f0040     	blr	x2
     be4: 52800000     	mov	w0, #0x0                ; =0
     be8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     bec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     bf0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     bf4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     bf8: f84107fb     	ldr	x27, [sp], #0x10
     bfc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c00: d65f03c0     	ret
     c04: 52800341     	mov	w1, #0x1a               ; =26
     c08: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c0c: f9400042     	ldr	x2, [x2]
     c10: aa1803e0     	mov	x0, x24
     c14: d63f0040     	blr	x2
     c18: 52800000     	mov	w0, #0x0                ; =0
     c1c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c20: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c24: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c28: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c2c: f84107fb     	ldr	x27, [sp], #0x10
     c30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c34: d65f03c0     	ret
     c38: 52800301     	mov	w1, #0x18               ; =24
     c3c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c40: f9400042     	ldr	x2, [x2]
     c44: aa1803e0     	mov	x0, x24
     c48: d63f0040     	blr	x2
     c4c: 52800000     	mov	w0, #0x0                ; =0
     c50: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c54: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c58: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c5c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c60: f84107fb     	ldr	x27, [sp], #0x10
     c64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c68: d65f03c0     	ret
     c6c: 528002e1     	mov	w1, #0x17               ; =23
     c70: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c74: f9400042     	ldr	x2, [x2]
     c78: aa1803e0     	mov	x0, x24
     c7c: d63f0040     	blr	x2
     c80: 52800000     	mov	w0, #0x0                ; =0
     c84: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c88: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c8c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c90: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c94: f84107fb     	ldr	x27, [sp], #0x10
     c98: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c9c: d65f03c0     	ret
     ca0: 528002a1     	mov	w1, #0x15               ; =21
     ca4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     ca8: f9400042     	ldr	x2, [x2]
     cac: aa1803e0     	mov	x0, x24
     cb0: d63f0040     	blr	x2
     cb4: 52800000     	mov	w0, #0x0                ; =0
     cb8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cbc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     cc0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     cc4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     cc8: f84107fb     	ldr	x27, [sp], #0x10
     ccc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     cd0: d65f03c0     	ret
     cd4: 52800281     	mov	w1, #0x14               ; =20
     cd8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     cdc: f9400042     	ldr	x2, [x2]
     ce0: aa1803e0     	mov	x0, x24
     ce4: d63f0040     	blr	x2
     ce8: 52800000     	mov	w0, #0x0                ; =0
     cec: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cf0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     cf4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     cf8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     cfc: f84107fb     	ldr	x27, [sp], #0x10
     d00: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d04: d65f03c0     	ret
     d08: 52800000     	mov	w0, #0x0                ; =0
     d0c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d10: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d14: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d18: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d1c: f84107fb     	ldr	x27, [sp], #0x10
     d20: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d24: d65f03c0     	ret
     d28: 52800241     	mov	w1, #0x12               ; =18
     d2c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     d30: f9400042     	ldr	x2, [x2]
     d34: aa1803e0     	mov	x0, x24
     d38: d63f0040     	blr	x2
     d3c: 52800000     	mov	w0, #0x0                ; =0
     d40: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d44: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d48: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d4c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d50: f84107fb     	ldr	x27, [sp], #0x10
     d54: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d58: d65f03c0     	ret
     d5c: aa0003f8     	mov	x24, x0
     d60: 52800221     	mov	w1, #0x11               ; =17
     d64: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     d68: f9400042     	ldr	x2, [x2]
     d6c: d63f0040     	blr	x2
     d70: 52800000     	mov	w0, #0x0                ; =0
     d74: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d78: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d7c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d80: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d84: f84107fb     	ldr	x27, [sp], #0x10
     d88: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d8c: d65f03c0     	ret

0000000000000d90 <___pl_fn_3>:
     d90: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     d94: 910003fd     	mov	x29, sp
     d98: f81f0ffc     	str	x28, [sp, #-0x10]!
     d9c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     da0: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     da4: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     da8: b9401001     	ldr	w1, [x0, #0x10]
     dac: 11000421     	add	w1, w1, #0x1
     db0: b9001001     	str	w1, [x0, #0x10]
     db4: aa0003fc     	mov	x28, x0
     db8: 528003c1     	mov	w1, #0x1e               ; =30
     dbc: 52800002     	mov	w2, #0x0                ; =0
     dc0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     dc4: f9400063     	ldr	x3, [x3]
     dc8: aa1c03e0     	mov	x0, x28
     dcc: d63f0060     	blr	x3
     dd0: 35002160     	cbnz	w0, 0x11fc <___pl_fn_3+0x46c>
     dd4: aa1c03e0     	mov	x0, x28
     dd8: f9401816     	ldr	x22, [x0, #0x30]
     ddc: b9401000     	ldr	w0, [x0, #0x10]
     de0: aa1c03e1     	mov	x1, x28
     de4: b9401421     	ldr	w1, [x1, #0x14]
     de8: 6b01001f     	cmp	w0, w1
     dec: 54001f22     	b.hs	0x11d0 <___pl_fn_3+0x440>
     df0: aa1c03e0     	mov	x0, x28
     df4: aa1603e1     	mov	x1, x22
     df8: 94000000     	bl	0xdf8 <___pl_fn_3+0x68>
     dfc: aa1c03e1     	mov	x1, x28
     e00: b9402c21     	ldr	w1, [x1, #0x2c]
     e04: 35001fc1     	cbnz	w1, 0x11fc <___pl_fn_3+0x46c>
     e08: d28000a1     	mov	x1, #0x5                ; =5
     e0c: eb0102c1     	subs	x1, x22, x1
     e10: 9a9f77e2     	cset	x2, vs
     e14: 72001c5f     	tst	w2, #0xff
     e18: 54001c61     	b.ne	0x11a4 <___pl_fn_3+0x414>
     e1c: aa1c03e2     	mov	x2, x28
     e20: b9401853     	ldr	w19, [x2, #0x18]
     e24: b9401c42     	ldr	w2, [x2, #0x1c]
     e28: 11000674     	add	w20, w19, #0x1
     e2c: 6b02029f     	cmp	w20, w2
     e30: 54001a48     	b.hi	0x1178 <___pl_fn_3+0x3e8>
     e34: aa1c03e3     	mov	x3, x28
     e38: f9401062     	ldr	x2, [x3, #0x20]
     e3c: 2a1303f5     	mov	w21, w19
     e40: b8335840     	str	w0, [x2, w19, uxtw #2]
     e44: aa0003f7     	mov	x23, x0
     e48: aa1c03e0     	mov	x0, x28
     e4c: b9001814     	str	w20, [x0, #0x18]
     e50: b9401000     	ldr	w0, [x0, #0x10]
     e54: aa1c03eb     	mov	x11, x28
     e58: b9401562     	ldr	w2, [x11, #0x14]
     e5c: 6b02001f     	cmp	w0, w2
     e60: 54001762     	b.hs	0x114c <___pl_fn_3+0x3bc>
     e64: aa1c03e0     	mov	x0, x28
     e68: 94000000     	bl	0xe68 <___pl_fn_3+0xd8>
     e6c: aa1c03e1     	mov	x1, x28
     e70: b9402c21     	ldr	w1, [x1, #0x2c]
     e74: 35001c41     	cbnz	w1, 0x11fc <___pl_fn_3+0x46c>
     e78: aa1c03e1     	mov	x1, x28
     e7c: b9001833     	str	w19, [x1, #0x18]
     e80: d2800121     	mov	x1, #0x9                ; =9
     e84: eb0102c1     	subs	x1, x22, x1
     e88: 9a9f77e2     	cset	x2, vs
     e8c: 72001c5f     	tst	w2, #0xff
     e90: 54001481     	b.ne	0x1120 <___pl_fn_3+0x390>
     e94: aa1c03e2     	mov	x2, x28
     e98: b9401c42     	ldr	w2, [x2, #0x1c]
     e9c: 11000a63     	add	w3, w19, #0x2
     ea0: 6b02007f     	cmp	w3, w2
     ea4: 54001288     	b.hi	0x10f4 <___pl_fn_3+0x364>
     ea8: aa1c03e2     	mov	x2, x28
     eac: f9401042     	ldr	x2, [x2, #0x20]
     eb0: 8b150843     	add	x3, x2, x21, lsl #2
     eb4: aa1703f6     	mov	x22, x23
     eb8: b8335856     	str	w22, [x2, w19, uxtw #2]
     ebc: b9000460     	str	w0, [x3, #0x4]
     ec0: aa0003f8     	mov	x24, x0
     ec4: 11000a60     	add	w0, w19, #0x2
     ec8: aa1c03e2     	mov	x2, x28
     ecc: b9001840     	str	w0, [x2, #0x18]
     ed0: aa1c03e0     	mov	x0, x28
     ed4: b9401000     	ldr	w0, [x0, #0x10]
     ed8: b9401442     	ldr	w2, [x2, #0x14]
     edc: 6b02001f     	cmp	w0, w2
     ee0: 54000f42     	b.hs	0x10c8 <___pl_fn_3+0x338>
     ee4: aa1c03e0     	mov	x0, x28
     ee8: 94000000     	bl	0xee8 <___pl_fn_3+0x158>
     eec: aa1c03e1     	mov	x1, x28
     ef0: b9402c21     	ldr	w1, [x1, #0x2c]
     ef4: 35001841     	cbnz	w1, 0x11fc <___pl_fn_3+0x46c>
     ef8: aa1c03e1     	mov	x1, x28
     efc: b9001833     	str	w19, [x1, #0x18]
     f00: b9401c21     	ldr	w1, [x1, #0x1c]
     f04: 11000e62     	add	w2, w19, #0x3
     f08: 6b01005f     	cmp	w2, w1
     f0c: 54000c88     	b.hi	0x109c <___pl_fn_3+0x30c>
     f10: aa1c03e1     	mov	x1, x28
     f14: f9401022     	ldr	x2, [x1, #0x20]
     f18: 8b150841     	add	x1, x2, x21, lsl #2
     f1c: b8335856     	str	w22, [x2, w19, uxtw #2]
     f20: aa1803e2     	mov	x2, x24
     f24: aa1603f7     	mov	x23, x22
     f28: b9000422     	str	w2, [x1, #0x4]
     f2c: b9000820     	str	w0, [x1, #0x8]
     f30: aa0003e3     	mov	x3, x0
     f34: 11000e60     	add	w0, w19, #0x3
     f38: aa1c03e2     	mov	x2, x28
     f3c: b9001840     	str	w0, [x2, #0x18]
     f40: aa1c03e0     	mov	x0, x28
     f44: b9401001     	ldr	w1, [x0, #0x10]
     f48: b9401402     	ldr	w2, [x0, #0x14]
     f4c: 6b02003f     	cmp	w1, w2
     f50: 54000902     	b.hs	0x1070 <___pl_fn_3+0x2e0>
     f54: aa1703e1     	mov	x1, x23
     f58: aa1803e2     	mov	x2, x24
     f5c: aa1c03e0     	mov	x0, x28
     f60: 94000000     	bl	0xf60 <___pl_fn_3+0x1d0>
     f64: aa1c03eb     	mov	x11, x28
     f68: b9402d63     	ldr	w3, [x11, #0x2c]
     f6c: 35001483     	cbnz	w3, 0x11fc <___pl_fn_3+0x46c>
     f70: aa1c03ef     	mov	x15, x28
     f74: b90019f3     	str	w19, [x15, #0x18]
     f78: aa1c03e1     	mov	x1, x28
     f7c: b9401c26     	ldr	w6, [x1, #0x1c]
     f80: 6b06029f     	cmp	w20, w6
     f84: 54000608     	b.hi	0x1044 <___pl_fn_3+0x2b4>
     f88: aa1c03e1     	mov	x1, x28
     f8c: f9401028     	ldr	x8, [x1, #0x20]
     f90: b8335900     	str	w0, [x8, w19, uxtw #2]
     f94: aa0003e1     	mov	x1, x0
     f98: aa1c03e0     	mov	x0, x28
     f9c: b9001814     	str	w20, [x0, #0x18]
     fa0: b940100a     	ldr	w10, [x0, #0x10]
     fa4: b940140b     	ldr	w11, [x0, #0x14]
     fa8: 6b0b015f     	cmp	w10, w11
     fac: 54000362     	b.hs	0x1018 <___pl_fn_3+0x288>
     fb0: aa1c03e0     	mov	x0, x28
     fb4: 94000000     	bl	0xfb4 <___pl_fn_3+0x224>
     fb8: aa0003e2     	mov	x2, x0
     fbc: aa1c03e0     	mov	x0, x28
     fc0: b9402c0c     	ldr	w12, [x0, #0x2c]
     fc4: 350011cc     	cbnz	w12, 0x11fc <___pl_fn_3+0x46c>
     fc8: aa1c03e0     	mov	x0, x28
     fcc: b9001813     	str	w19, [x0, #0x18]
     fd0: 52800541     	mov	w1, #0x2a               ; =42
     fd4: 52802003     	mov	w3, #0x100              ; =256
     fd8: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     fdc: f94001ef     	ldr	x15, [x15]
     fe0: d63f01e0     	blr	x15
     fe4: 350010c0     	cbnz	w0, 0x11fc <___pl_fn_3+0x46c>
     fe8: aa1c03e0     	mov	x0, x28
     fec: b9401000     	ldr	w0, [x0, #0x10]
     ff0: 51000400     	sub	w0, w0, #0x1
     ff4: aa1c03e1     	mov	x1, x28
     ff8: b9001020     	str	w0, [x1, #0x10]
     ffc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1000: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1004: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1008: f84107fc     	ldr	x28, [sp], #0x10
    100c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1010: d65f03c0     	ret
    1014: 1400007a     	b	0x11fc <___pl_fn_3+0x46c>
    1018: 52800521     	mov	w1, #0x29               ; =41
    101c: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    1020: f9400042     	ldr	x2, [x2]
    1024: aa1c03e0     	mov	x0, x28
    1028: d63f0040     	blr	x2
    102c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1030: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1034: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1038: f84107fc     	ldr	x28, [sp], #0x10
    103c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1040: d65f03c0     	ret
    1044: 52800501     	mov	w1, #0x28               ; =40
    1048: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    104c: f9400042     	ldr	x2, [x2]
    1050: aa1c03e0     	mov	x0, x28
    1054: d63f0040     	blr	x2
    1058: a8c153f3     	ldp	x19, x20, [sp], #0x10
    105c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1060: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1064: f84107fc     	ldr	x28, [sp], #0x10
    1068: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    106c: d65f03c0     	ret
    1070: 528004e1     	mov	w1, #0x27               ; =39
    1074: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    1078: f9400042     	ldr	x2, [x2]
    107c: aa1c03e0     	mov	x0, x28
    1080: d63f0040     	blr	x2
    1084: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1088: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    108c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1090: f84107fc     	ldr	x28, [sp], #0x10
    1094: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1098: d65f03c0     	ret
    109c: 528004c1     	mov	w1, #0x26               ; =38
    10a0: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    10a4: f9400042     	ldr	x2, [x2]
    10a8: aa1c03e0     	mov	x0, x28
    10ac: d63f0040     	blr	x2
    10b0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    10b4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    10b8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    10bc: f84107fc     	ldr	x28, [sp], #0x10
    10c0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    10c4: d65f03c0     	ret
    10c8: 528004a1     	mov	w1, #0x25               ; =37
    10cc: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    10d0: f9400042     	ldr	x2, [x2]
    10d4: aa1c03e0     	mov	x0, x28
    10d8: d63f0040     	blr	x2
    10dc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    10e0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    10e4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    10e8: f84107fc     	ldr	x28, [sp], #0x10
    10ec: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    10f0: d65f03c0     	ret
    10f4: 52800481     	mov	w1, #0x24               ; =36
    10f8: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    10fc: f9400042     	ldr	x2, [x2]
    1100: aa1c03e0     	mov	x0, x28
    1104: d63f0040     	blr	x2
    1108: a8c153f3     	ldp	x19, x20, [sp], #0x10
    110c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1110: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1114: f84107fc     	ldr	x28, [sp], #0x10
    1118: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    111c: d65f03c0     	ret
    1120: 52800461     	mov	w1, #0x23               ; =35
    1124: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    1128: f9400042     	ldr	x2, [x2]
    112c: aa1c03e0     	mov	x0, x28
    1130: d63f0040     	blr	x2
    1134: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1138: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    113c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1140: f84107fc     	ldr	x28, [sp], #0x10
    1144: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1148: d65f03c0     	ret
    114c: 52800441     	mov	w1, #0x22               ; =34
    1150: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    1154: f9400042     	ldr	x2, [x2]
    1158: aa1c03e0     	mov	x0, x28
    115c: d63f0040     	blr	x2
    1160: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1164: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1168: a8c163f7     	ldp	x23, x24, [sp], #0x10
    116c: f84107fc     	ldr	x28, [sp], #0x10
    1170: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1174: d65f03c0     	ret
    1178: 52800421     	mov	w1, #0x21               ; =33
    117c: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    1180: f9400042     	ldr	x2, [x2]
    1184: aa1c03e0     	mov	x0, x28
    1188: d63f0040     	blr	x2
    118c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1190: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1194: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1198: f84107fc     	ldr	x28, [sp], #0x10
    119c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11a0: d65f03c0     	ret
    11a4: 52800401     	mov	w1, #0x20               ; =32
    11a8: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    11ac: f9400042     	ldr	x2, [x2]
    11b0: aa1c03e0     	mov	x0, x28
    11b4: d63f0040     	blr	x2
    11b8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11bc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    11c0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    11c4: f84107fc     	ldr	x28, [sp], #0x10
    11c8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11cc: d65f03c0     	ret
    11d0: 528003e1     	mov	w1, #0x1f               ; =31
    11d4: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    11d8: f9400042     	ldr	x2, [x2]
    11dc: aa1c03e0     	mov	x0, x28
    11e0: d63f0040     	blr	x2
    11e4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11e8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    11ec: a8c163f7     	ldp	x23, x24, [sp], #0x10
    11f0: f84107fc     	ldr	x28, [sp], #0x10
    11f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11f8: d65f03c0     	ret
    11fc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1200: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1204: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1208: f84107fc     	ldr	x28, [sp], #0x10
    120c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1210: d65f03c0     	ret

0000000000001214 <___pl_fn_4>:
    1214: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    1218: 910003fd     	mov	x29, sp
    121c: a9bf5ff3     	stp	x19, x23, [sp, #-0x10]!
    1220: aa0103f7     	mov	x23, x1
    1224: b9401001     	ldr	w1, [x0, #0x10]
    1228: 11000421     	add	w1, w1, #0x1
    122c: b9001001     	str	w1, [x0, #0x10]
    1230: aa1703e1     	mov	x1, x23
    1234: 34000aa1     	cbz	w1, 0x1388 <___pl_fn_4+0x174>
    1238: f9400006     	ldr	x6, [x0]
    123c: aa1703e1     	mov	x1, x23
    1240: aa0003f3     	mov	x19, x0
    1244: 2a0103e5     	mov	w5, w1
    1248: 8b050cc5     	add	x5, x6, x5, lsl #3
    124c: f86158c6     	ldr	x6, [x6, w1, uxtw #3]
    1250: d360fcc6     	lsr	x6, x6, #32
    1254: 92403cc6     	and	x6, x6, #0xffff
    1258: 910008c6     	add	x6, x6, #0x2
    125c: d37df0c6     	lsl	x6, x6, #3
    1260: 386668a0     	ldrb	w0, [x5, x6]
    1264: 53001c05     	uxtb	w5, w0
    1268: 710008bf     	cmp	w5, #0x2
    126c: 54000081     	b.ne	0x127c <___pl_fn_4+0x68>
    1270: 14000047     	b	0x138c <___pl_fn_4+0x178>
    1274: aa1303e0     	mov	x0, x19
    1278: f9401800     	ldr	x0, [x0, #0x30]
    127c: 72001c1f     	tst	w0, #0xff
    1280: 54000721     	b.ne	0x1364 <___pl_fn_4+0x150>
    1284: aa1703e1     	mov	x1, x23
    1288: 34000941     	cbz	w1, 0x13b0 <___pl_fn_4+0x19c>
    128c: aa1303e0     	mov	x0, x19
    1290: f9400002     	ldr	x2, [x0]
    1294: 2a0103e0     	mov	w0, w1
    1298: 8b000c40     	add	x0, x2, x0, lsl #3
    129c: f8615842     	ldr	x2, [x2, w1, uxtw #3]
    12a0: aa0103f7     	mov	x23, x1
    12a4: d360fc41     	lsr	x1, x2, #32
    12a8: 92403c21     	and	x1, x1, #0xffff
    12ac: 91000421     	add	x1, x1, #0x1
    12b0: d37df021     	lsl	x1, x1, #3
    12b4: b8616801     	ldr	w1, [x0, x1]
    12b8: 350000a1     	cbnz	w1, 0x12cc <___pl_fn_4+0xb8>
    12bc: 1400003e     	b	0x13b4 <___pl_fn_4+0x1a0>
    12c0: aa1303e0     	mov	x0, x19
    12c4: f9401801     	ldr	x1, [x0, #0x30]
    12c8: 14000002     	b	0x12d0 <___pl_fn_4+0xbc>
    12cc: aa1303e0     	mov	x0, x19
    12d0: aa1303e0     	mov	x0, x19
    12d4: b9401817     	ldr	w23, [x0, #0x18]
    12d8: b9401c02     	ldr	w2, [x0, #0x1c]
    12dc: 110006e0     	add	w0, w23, #0x1
    12e0: 6b02001f     	cmp	w0, w2
    12e4: 54000a68     	b.hi	0x1430 <___pl_fn_4+0x21c>
    12e8: aa1303e5     	mov	x5, x19
    12ec: f94010a2     	ldr	x2, [x5, #0x20]
    12f0: b8375841     	str	w1, [x2, w23, uxtw #2]
    12f4: aa1303e8     	mov	x8, x19
    12f8: b9001900     	str	w0, [x8, #0x18]
    12fc: aa1303e0     	mov	x0, x19
    1300: b9401000     	ldr	w0, [x0, #0x10]
    1304: aa1303ec     	mov	x12, x19
    1308: b9401582     	ldr	w2, [x12, #0x14]
    130c: 6b02001f     	cmp	w0, w2
    1310: 540007e2     	b.hs	0x140c <___pl_fn_4+0x1f8>
    1314: aa1303e0     	mov	x0, x19
    1318: 94000000     	bl	0x1318 <___pl_fn_4+0x104>
    131c: aa1303e1     	mov	x1, x19
    1320: b9402c21     	ldr	w1, [x1, #0x2c]
    1324: 350006c1     	cbnz	w1, 0x13fc <___pl_fn_4+0x1e8>
    1328: aa1303e1     	mov	x1, x19
    132c: b9001837     	str	w23, [x1, #0x18]
    1330: d2800021     	mov	x1, #0x1                ; =1
    1334: ab000020     	adds	x0, x1, x0
    1338: 9a9f77e1     	cset	x1, vs
    133c: 72001c3f     	tst	w1, #0xff
    1340: 540004c1     	b.ne	0x13d8 <___pl_fn_4+0x1c4>
    1344: aa1303e1     	mov	x1, x19
    1348: b9401021     	ldr	w1, [x1, #0x10]
    134c: 51000421     	sub	w1, w1, #0x1
    1350: aa1303e2     	mov	x2, x19
    1354: b9001041     	str	w1, [x2, #0x10]
    1358: a8c15ff3     	ldp	x19, x23, [sp], #0x10
    135c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1360: d65f03c0     	ret
    1364: aa1303e0     	mov	x0, x19
    1368: b9401000     	ldr	w0, [x0, #0x10]
    136c: 51000400     	sub	w0, w0, #0x1
    1370: aa1303e1     	mov	x1, x19
    1374: b9001020     	str	w0, [x1, #0x10]
    1378: d2800000     	mov	x0, #0x0                ; =0
    137c: a8c15ff3     	ldp	x19, x23, [sp], #0x10
    1380: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1384: d65f03c0     	ret
    1388: aa0003f3     	mov	x19, x0
    138c: 52800561     	mov	w1, #0x2b               ; =43
    1390: 52800043     	mov	w3, #0x2                ; =2
    1394: 90000008     	adrp	x8, 0x1000 <___pl_fn_3+0x270>
    1398: f9400108     	ldr	x8, [x8]
    139c: aa1303e0     	mov	x0, x19
    13a0: aa1703e2     	mov	x2, x23
    13a4: d63f0100     	blr	x8
    13a8: 34fff660     	cbz	w0, 0x1274 <___pl_fn_4+0x60>
    13ac: 14000014     	b	0x13fc <___pl_fn_4+0x1e8>
    13b0: aa0103f7     	mov	x23, x1
    13b4: 52800581     	mov	w1, #0x2c               ; =44
    13b8: 52800023     	mov	w3, #0x1                ; =1
    13bc: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x270>
    13c0: f9400084     	ldr	x4, [x4]
    13c4: aa1703e2     	mov	x2, x23
    13c8: aa1303e0     	mov	x0, x19
    13cc: d63f0080     	blr	x4
    13d0: 34fff780     	cbz	w0, 0x12c0 <___pl_fn_4+0xac>
    13d4: 1400000a     	b	0x13fc <___pl_fn_4+0x1e8>
    13d8: 528005e1     	mov	w1, #0x2f               ; =47
    13dc: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    13e0: f9400042     	ldr	x2, [x2]
    13e4: aa1303e0     	mov	x0, x19
    13e8: d63f0040     	blr	x2
    13ec: d2800000     	mov	x0, #0x0                ; =0
    13f0: a8c15ff3     	ldp	x19, x23, [sp], #0x10
    13f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    13f8: d65f03c0     	ret
    13fc: d2800000     	mov	x0, #0x0                ; =0
    1400: a8c15ff3     	ldp	x19, x23, [sp], #0x10
    1404: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1408: d65f03c0     	ret
    140c: 528005c1     	mov	w1, #0x2e               ; =46
    1410: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    1414: f9400042     	ldr	x2, [x2]
    1418: aa1303e0     	mov	x0, x19
    141c: d63f0040     	blr	x2
    1420: d2800000     	mov	x0, #0x0                ; =0
    1424: a8c15ff3     	ldp	x19, x23, [sp], #0x10
    1428: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    142c: d65f03c0     	ret
    1430: 528005a1     	mov	w1, #0x2d               ; =45
    1434: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x270>
    1438: f9400042     	ldr	x2, [x2]
    143c: aa1303e0     	mov	x0, x19
    1440: d63f0040     	blr	x2
    1444: d2800000     	mov	x0, #0x0                ; =0
    1448: a8c15ff3     	ldp	x19, x23, [sp], #0x10
    144c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1450: d65f03c0     	ret
