
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_58173/storage/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: f81f0ffa     	str	x26, [sp, #-0x10]!
       c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      10: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      14: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      18: d10143ff     	sub	sp, sp, #0x50
      1c: aa0103f3     	mov	x19, x1
      20: aa0203f8     	mov	x24, x2
      24: aa0303fa     	mov	x26, x3
      28: b9401001     	ldr	w1, [x0, #0x10]
      2c: 11000421     	add	w1, w1, #0x1
      30: b9001001     	str	w1, [x0, #0x10]
      34: aa0003f6     	mov	x22, x0
      38: 52800001     	mov	w1, #0x0                ; =0
      3c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
      40: f9400063     	ldr	x3, [x3]
      44: aa1603e0     	mov	x0, x22
      48: aa1a03e2     	mov	x2, x26
      4c: d63f0060     	blr	x3
      50: 35004c60     	cbnz	w0, 0x9dc <___pl_fn_0+0x9dc>
      54: aa1603e0     	mov	x0, x22
      58: f9401800     	ldr	x0, [x0, #0x30]
      5c: d2800021     	mov	x1, #0x1                ; =1
      60: ab010003     	adds	x3, x0, x1
      64: 9a9f77e0     	cset	x0, vs
      68: 72001c1f     	tst	w0, #0xff
      6c: 540049e1     	b.ne	0x9a8 <___pl_fn_0+0x9a8>
      70: 52800041     	mov	w1, #0x2                ; =2
      74: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      78: f9400084     	ldr	x4, [x4]
      7c: aa1603e0     	mov	x0, x22
      80: aa1a03e2     	mov	x2, x26
      84: d63f0080     	blr	x4
      88: 35004aa0     	cbnz	w0, 0x9dc <___pl_fn_0+0x9dc>
      8c: aa1603e0     	mov	x0, x22
      90: b9401814     	ldr	w20, [x0, #0x18]
      94: b9401c01     	ldr	w1, [x0, #0x1c]
      98: 11000680     	add	w0, w20, #0x1
      9c: 6b01001f     	cmp	w0, w1
      a0: 540046a8     	b.hi	0x974 <___pl_fn_0+0x974>
      a4: aa1603e1     	mov	x1, x22
      a8: f9401021     	ldr	x1, [x1, #0x20]
      ac: 2a1403f5     	mov	w21, w20
      b0: aa1803e2     	mov	x2, x24
      b4: b8345822     	str	w2, [x1, w20, uxtw #2]
      b8: aa1603e1     	mov	x1, x22
      bc: b9001820     	str	w0, [x1, #0x18]
      c0: 52800081     	mov	w1, #0x4                ; =4
      c4: 52800022     	mov	w2, #0x1                ; =1
      c8: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
      cc: f9400063     	ldr	x3, [x3]
      d0: aa1603e0     	mov	x0, x22
      d4: d63f0060     	blr	x3
      d8: 35004820     	cbnz	w0, 0x9dc <___pl_fn_0+0x9dc>
      dc: aa1603e0     	mov	x0, x22
      e0: f9401800     	ldr	x0, [x0, #0x30]
      e4: aa1603e1     	mov	x1, x22
      e8: b9001834     	str	w20, [x1, #0x18]
      ec: 340042a0     	cbz	w0, 0x940 <___pl_fn_0+0x940>
      f0: f100067f     	cmp	x19, #0x1
      f4: 54001840     	b.eq	0x3fc <___pl_fn_0+0x3fc>
      f8: d2800028     	mov	x8, #0x1                ; =1
      fc: eb080261     	subs	x1, x19, x8
     100: 9a9f77e9     	cset	x9, vs
     104: 72001d3f     	tst	w9, #0xff
     108: 540039a1     	b.ne	0x83c <___pl_fn_0+0x83c>
     10c: aa1603e2     	mov	x2, x22
     110: b9401c4b     	ldr	w11, [x2, #0x1c]
     114: 11000a8a     	add	w10, w20, #0x2
     118: 6b0b015f     	cmp	w10, w11
     11c: 54003768     	b.hi	0x808 <___pl_fn_0+0x808>
     120: aa1603e2     	mov	x2, x22
     124: f940104c     	ldr	x12, [x2, #0x20]
     128: 8b15098d     	add	x13, x12, x21, lsl #2
     12c: aa1803e2     	mov	x2, x24
     130: b8345982     	str	w2, [x12, w20, uxtw #2]
     134: b90005a0     	str	w0, [x13, #0x4]
     138: aa0003f7     	mov	x23, x0
     13c: aa1603e0     	mov	x0, x22
     140: b900180a     	str	w10, [x0, #0x18]
     144: b940100f     	ldr	w15, [x0, #0x10]
     148: b9401400     	ldr	w0, [x0, #0x14]
     14c: 6b0001ff     	cmp	w15, w0
     150: 54003422     	b.hs	0x7d4 <___pl_fn_0+0x7d4>
     154: aa1603e0     	mov	x0, x22
     158: aa1803e2     	mov	x2, x24
     15c: aa1a03e3     	mov	x3, x26
     160: 94000000     	bl	0x160 <___pl_fn_0+0x160>
     164: aa1603e2     	mov	x2, x22
     168: b9402c41     	ldr	w1, [x2, #0x2c]
     16c: 35004381     	cbnz	w1, 0x9dc <___pl_fn_0+0x9dc>
     170: aa1603e6     	mov	x6, x22
     174: b90018d4     	str	w20, [x6, #0x18]
     178: aa1703e1     	mov	x1, x23
     17c: 34001d81     	cbz	w1, 0x52c <___pl_fn_0+0x52c>
     180: aa0103f7     	mov	x23, x1
     184: aa1603e1     	mov	x1, x22
     188: f9400022     	ldr	x2, [x1]
     18c: aa1703e1     	mov	x1, x23
     190: 2a0103e1     	mov	w1, w1
     194: 8b010c41     	add	x1, x2, x1, lsl #3
     198: aa1703e3     	mov	x3, x23
     19c: f8635842     	ldr	x2, [x2, w3, uxtw #3]
     1a0: 2a0003e0     	mov	w0, w0
     1a4: d360fc42     	lsr	x2, x2, #32
     1a8: 92403c42     	and	x2, x2, #0xffff
     1ac: f8227820     	str	x0, [x1, x2, lsl #3]
     1b0: d2800020     	mov	x0, #0x1                ; =1
     1b4: eb000261     	subs	x1, x19, x0
     1b8: 9a9f77e0     	cset	x0, vs
     1bc: 72001c1f     	tst	w0, #0xff
     1c0: 54002f01     	b.ne	0x7a0 <___pl_fn_0+0x7a0>
     1c4: aa1603e0     	mov	x0, x22
     1c8: b9401814     	ldr	w20, [x0, #0x18]
     1cc: b9401c02     	ldr	w2, [x0, #0x1c]
     1d0: 11000a80     	add	w0, w20, #0x2
     1d4: 6b02001f     	cmp	w0, w2
     1d8: 54002ca8     	b.hi	0x76c <___pl_fn_0+0x76c>
     1dc: aa1603e2     	mov	x2, x22
     1e0: f9401042     	ldr	x2, [x2, #0x20]
     1e4: 2a1403e3     	mov	w3, w20
     1e8: 8b030843     	add	x3, x2, x3, lsl #2
     1ec: aa1803e4     	mov	x4, x24
     1f0: b8345844     	str	w4, [x2, w20, uxtw #2]
     1f4: aa1703e2     	mov	x2, x23
     1f8: b9000462     	str	w2, [x3, #0x4]
     1fc: aa1603e2     	mov	x2, x22
     200: b9001840     	str	w0, [x2, #0x18]
     204: aa1603e0     	mov	x0, x22
     208: b9401000     	ldr	w0, [x0, #0x10]
     20c: b9401442     	ldr	w2, [x2, #0x14]
     210: 6b02001f     	cmp	w0, w2
     214: 54002922     	b.hs	0x738 <___pl_fn_0+0x738>
     218: aa1603e0     	mov	x0, x22
     21c: aa1803e2     	mov	x2, x24
     220: aa1a03e3     	mov	x3, x26
     224: 94000000     	bl	0x224 <___pl_fn_0+0x224>
     228: aa1603e1     	mov	x1, x22
     22c: b9402c21     	ldr	w1, [x1, #0x2c]
     230: 35003d61     	cbnz	w1, 0x9dc <___pl_fn_0+0x9dc>
     234: aa1603e1     	mov	x1, x22
     238: b9001834     	str	w20, [x1, #0x18]
     23c: aa1703e1     	mov	x1, x23
     240: 34001921     	cbz	w1, 0x564 <___pl_fn_0+0x564>
     244: aa1603ec     	mov	x12, x22
     248: f9400182     	ldr	x2, [x12]
     24c: aa1703e4     	mov	x4, x23
     250: 2a0403e1     	mov	w1, w4
     254: 8b010c41     	add	x1, x2, x1, lsl #3
     258: aa1703e7     	mov	x7, x23
     25c: f8675842     	ldr	x2, [x2, w7, uxtw #3]
     260: 2a0003e0     	mov	w0, w0
     264: d360fc42     	lsr	x2, x2, #32
     268: 92403c42     	and	x2, x2, #0xffff
     26c: 91000442     	add	x2, x2, #0x1
     270: f8227820     	str	x0, [x1, x2, lsl #3]
     274: d2800020     	mov	x0, #0x1                ; =1
     278: eb000261     	subs	x1, x19, x0
     27c: 9a9f77e0     	cset	x0, vs
     280: 72001c1f     	tst	w0, #0xff
     284: 54002401     	b.ne	0x704 <___pl_fn_0+0x704>
     288: aa1603e0     	mov	x0, x22
     28c: b9401814     	ldr	w20, [x0, #0x18]
     290: b9401c02     	ldr	w2, [x0, #0x1c]
     294: 11000a80     	add	w0, w20, #0x2
     298: 6b02001f     	cmp	w0, w2
     29c: 540021a8     	b.hi	0x6d0 <___pl_fn_0+0x6d0>
     2a0: aa1603e2     	mov	x2, x22
     2a4: f9401042     	ldr	x2, [x2, #0x20]
     2a8: 2a1403e3     	mov	w3, w20
     2ac: 8b030843     	add	x3, x2, x3, lsl #2
     2b0: aa1803e4     	mov	x4, x24
     2b4: b8345844     	str	w4, [x2, w20, uxtw #2]
     2b8: aa1703e2     	mov	x2, x23
     2bc: b9000462     	str	w2, [x3, #0x4]
     2c0: aa1603e2     	mov	x2, x22
     2c4: b9001840     	str	w0, [x2, #0x18]
     2c8: aa1603e0     	mov	x0, x22
     2cc: b9401000     	ldr	w0, [x0, #0x10]
     2d0: b9401442     	ldr	w2, [x2, #0x14]
     2d4: 6b02001f     	cmp	w0, w2
     2d8: 54001e22     	b.hs	0x69c <___pl_fn_0+0x69c>
     2dc: aa1603e0     	mov	x0, x22
     2e0: aa1803e2     	mov	x2, x24
     2e4: aa1a03e3     	mov	x3, x26
     2e8: 94000000     	bl	0x2e8 <___pl_fn_0+0x2e8>
     2ec: aa1603e1     	mov	x1, x22
     2f0: b9402c21     	ldr	w1, [x1, #0x2c]
     2f4: 35003741     	cbnz	w1, 0x9dc <___pl_fn_0+0x9dc>
     2f8: aa1603e1     	mov	x1, x22
     2fc: b9001834     	str	w20, [x1, #0x18]
     300: aa1703e1     	mov	x1, x23
     304: 340014a1     	cbz	w1, 0x598 <___pl_fn_0+0x598>
     308: aa1603e5     	mov	x5, x22
     30c: f94000a4     	ldr	x4, [x5]
     310: aa1703e1     	mov	x1, x23
     314: 2a0103e3     	mov	w3, w1
     318: 8b030c83     	add	x3, x4, x3, lsl #3
     31c: f8615885     	ldr	x5, [x4, w1, uxtw #3]
     320: 2a0003e4     	mov	w4, w0
     324: d360fca5     	lsr	x5, x5, #32
     328: 92403ca5     	and	x5, x5, #0xffff
     32c: 910008a5     	add	x5, x5, #0x2
     330: f8257864     	str	x4, [x3, x5, lsl #3]
     334: d2800025     	mov	x5, #0x1                ; =1
     338: eb050261     	subs	x1, x19, x5
     33c: 9a9f77e6     	cset	x6, vs
     340: 72001cdf     	tst	w6, #0xff
     344: 54001921     	b.ne	0x668 <___pl_fn_0+0x668>
     348: aa1603e0     	mov	x0, x22
     34c: b9401813     	ldr	w19, [x0, #0x18]
     350: b9401c08     	ldr	w8, [x0, #0x1c]
     354: 11000a67     	add	w7, w19, #0x2
     358: 6b0800ff     	cmp	w7, w8
     35c: 540016c8     	b.hi	0x634 <___pl_fn_0+0x634>
     360: aa1603e0     	mov	x0, x22
     364: f9401009     	ldr	x9, [x0, #0x20]
     368: 2a1303ea     	mov	w10, w19
     36c: 8b0a092a     	add	x10, x9, x10, lsl #2
     370: aa1803e2     	mov	x2, x24
     374: b8335922     	str	w2, [x9, w19, uxtw #2]
     378: aa1703e0     	mov	x0, x23
     37c: b9000540     	str	w0, [x10, #0x4]
     380: aa1603e0     	mov	x0, x22
     384: b9001807     	str	w7, [x0, #0x18]
     388: b940100c     	ldr	w12, [x0, #0x10]
     38c: b940140d     	ldr	w13, [x0, #0x14]
     390: 6b0d019f     	cmp	w12, w13
     394: 54001362     	b.hs	0x600 <___pl_fn_0+0x600>
     398: aa1803e2     	mov	x2, x24
     39c: aa1a03e3     	mov	x3, x26
     3a0: aa1603e0     	mov	x0, x22
     3a4: 94000000     	bl	0x3a4 <___pl_fn_0+0x3a4>
     3a8: aa1603e1     	mov	x1, x22
     3ac: b9402c2e     	ldr	w14, [x1, #0x2c]
     3b0: 3500316e     	cbnz	w14, 0x9dc <___pl_fn_0+0x9dc>
     3b4: aa1603e1     	mov	x1, x22
     3b8: b9001833     	str	w19, [x1, #0x18]
     3bc: aa1703e1     	mov	x1, x23
     3c0: 34001061     	cbz	w1, 0x5cc <___pl_fn_0+0x5cc>
     3c4: aa1603e1     	mov	x1, x22
     3c8: f9400022     	ldr	x2, [x1]
     3cc: aa1703e1     	mov	x1, x23
     3d0: 2a0103e1     	mov	w1, w1
     3d4: 8b010c41     	add	x1, x2, x1, lsl #3
     3d8: aa1703e3     	mov	x3, x23
     3dc: f8635842     	ldr	x2, [x2, w3, uxtw #3]
     3e0: 2a0003e0     	mov	w0, w0
     3e4: d360fc42     	lsr	x2, x2, #32
     3e8: 92403c42     	and	x2, x2, #0xffff
     3ec: 91000c42     	add	x2, x2, #0x3
     3f0: f8227820     	str	x0, [x1, x2, lsl #3]
     3f4: aa1603e0     	mov	x0, x22
     3f8: 14000040     	b	0x4f8 <___pl_fn_0+0x4f8>
     3fc: aa0003f7     	mov	x23, x0
     400: aa1603e0     	mov	x0, x22
     404: b9401c01     	ldr	w1, [x0, #0x1c]
     408: 11000a80     	add	w0, w20, #0x2
     40c: 6b01001f     	cmp	w0, w1
     410: 540027e8     	b.hi	0x90c <___pl_fn_0+0x90c>
     414: aa1603e1     	mov	x1, x22
     418: f9401021     	ldr	x1, [x1, #0x20]
     41c: 8b150822     	add	x2, x1, x21, lsl #2
     420: aa1803ec     	mov	x12, x24
     424: b834582c     	str	w12, [x1, w20, uxtw #2]
     428: aa1703e1     	mov	x1, x23
     42c: b9000441     	str	w1, [x2, #0x4]
     430: aa1603e1     	mov	x1, x22
     434: b9001820     	str	w0, [x1, #0x18]
     438: aa1603e0     	mov	x0, x22
     43c: b9401000     	ldr	w0, [x0, #0x10]
     440: b9401421     	ldr	w1, [x1, #0x14]
     444: 6b01001f     	cmp	w0, w1
     448: 54002482     	b.hs	0x8d8 <___pl_fn_0+0x8d8>
     44c: aa1803e1     	mov	x1, x24
     450: aa1603e0     	mov	x0, x22
     454: 94000000     	bl	0x454 <___pl_fn_0+0x454>
     458: aa1603e1     	mov	x1, x22
     45c: b9402c21     	ldr	w1, [x1, #0x2c]
     460: 35002be1     	cbnz	w1, 0x9dc <___pl_fn_0+0x9dc>
     464: aa1603e1     	mov	x1, x22
     468: b9001834     	str	w20, [x1, #0x18]
     46c: d28ccce1     	mov	x1, #0x6667             ; =26215
     470: f2acccc1     	movk	x1, #0x6666, lsl #16
     474: f2ccccc1     	movk	x1, #0x6666, lsl #32
     478: f2ecccc1     	movk	x1, #0x6666, lsl #48
     47c: 9b417c01     	smulh	x1, x0, x1
     480: 9342fc21     	asr	x1, x1, #2
     484: d37ffc22     	lsr	x2, x1, #63
     488: 8b020021     	add	x1, x1, x2
     48c: d2800142     	mov	x2, #0xa                ; =10
     490: 9b028020     	msub	x0, x1, x2, x0
     494: d2800021     	mov	x1, #0x1                ; =1
     498: ab010000     	adds	x0, x0, x1
     49c: 9a9f77e1     	cset	x1, vs
     4a0: 72001c3f     	tst	w1, #0xff
     4a4: 54002001     	b.ne	0x8a4 <___pl_fn_0+0x8a4>
     4a8: aa1703e1     	mov	x1, x23
     4ac: 34001e41     	cbz	w1, 0x874 <___pl_fn_0+0x874>
     4b0: aa1603e8     	mov	x8, x22
     4b4: f9400102     	ldr	x2, [x8]
     4b8: aa1703e1     	mov	x1, x23
     4bc: 2a0103e1     	mov	w1, w1
     4c0: 8b010c41     	add	x1, x2, x1, lsl #3
     4c4: aa1703e3     	mov	x3, x23
     4c8: f8635842     	ldr	x2, [x2, w3, uxtw #3]
     4cc: d360fc42     	lsr	x2, x2, #32
     4d0: 92403c43     	and	x3, x2, #0xffff
     4d4: f100087f     	cmp	x3, #0x2
     4d8: 54000080     	b.eq	0x4e8 <___pl_fn_0+0x4e8>
     4dc: f9400823     	ldr	x3, [x1, #0x10]
     4e0: 927bf863     	and	x3, x3, #0xffffffffffffffef
     4e4: f9000823     	str	x3, [x1, #0x10]
     4e8: 92403c42     	and	x2, x2, #0xffff
     4ec: 91001042     	add	x2, x2, #0x4
     4f0: f8227820     	str	x0, [x1, x2, lsl #3]
     4f4: aa1603e0     	mov	x0, x22
     4f8: aa1603e0     	mov	x0, x22
     4fc: b9401002     	ldr	w2, [x0, #0x10]
     500: 51000442     	sub	w2, w2, #0x1
     504: b9001002     	str	w2, [x0, #0x10]
     508: aa1703e0     	mov	x0, x23
     50c: 910143ff     	add	sp, sp, #0x50
     510: a8c153f3     	ldp	x19, x20, [sp], #0x10
     514: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     518: a8c163f7     	ldp	x23, x24, [sp], #0x10
     51c: f84107fa     	ldr	x26, [sp], #0x10
     520: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     524: d65f03c0     	ret
     528: 1400012d     	b	0x9dc <___pl_fn_0+0x9dc>
     52c: aa0103f7     	mov	x23, x1
     530: d2800001     	mov	x1, #0x0                ; =0
     534: 910003e3     	mov	x3, sp
     538: f80003e1     	stur	x1, [sp]
     53c: 2a0003e0     	mov	w0, w0
     540: f80083e0     	stur	x0, [sp, #0x8]
     544: 52800121     	mov	w1, #0x9                ; =9
     548: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     54c: f9400084     	ldr	x4, [x4]
     550: aa1603e0     	mov	x0, x22
     554: aa1703e2     	mov	x2, x23
     558: d63f0080     	blr	x4
     55c: 34ffe2a0     	cbz	w0, 0x1b0 <___pl_fn_0+0x1b0>
     560: 1400011f     	b	0x9dc <___pl_fn_0+0x9dc>
     564: d2800021     	mov	x1, #0x1                ; =1
     568: 910043e3     	add	x3, sp, #0x10
     56c: f80103e1     	stur	x1, [sp, #0x10]
     570: 2a0003e0     	mov	w0, w0
     574: f80183e0     	stur	x0, [sp, #0x18]
     578: 528001a1     	mov	w1, #0xd                ; =13
     57c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     580: f9400084     	ldr	x4, [x4]
     584: aa1603e0     	mov	x0, x22
     588: aa1703e2     	mov	x2, x23
     58c: d63f0080     	blr	x4
     590: 34ffe720     	cbz	w0, 0x274 <___pl_fn_0+0x274>
     594: 14000112     	b	0x9dc <___pl_fn_0+0x9dc>
     598: d2800041     	mov	x1, #0x2                ; =2
     59c: 910083e3     	add	x3, sp, #0x20
     5a0: f80203e1     	stur	x1, [sp, #0x20]
     5a4: 2a0003e0     	mov	w0, w0
     5a8: f80283e0     	stur	x0, [sp, #0x28]
     5ac: 52800221     	mov	w1, #0x11               ; =17
     5b0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5b4: f9400084     	ldr	x4, [x4]
     5b8: aa1603e0     	mov	x0, x22
     5bc: aa1703e2     	mov	x2, x23
     5c0: d63f0080     	blr	x4
     5c4: 34ffeb80     	cbz	w0, 0x334 <___pl_fn_0+0x334>
     5c8: 14000105     	b	0x9dc <___pl_fn_0+0x9dc>
     5cc: d2800061     	mov	x1, #0x3                ; =3
     5d0: 9100c3e3     	add	x3, sp, #0x30
     5d4: f80303e1     	stur	x1, [sp, #0x30]
     5d8: 2a0003e0     	mov	w0, w0
     5dc: f80383e0     	stur	x0, [sp, #0x38]
     5e0: 528002a1     	mov	w1, #0x15               ; =21
     5e4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5e8: f9400084     	ldr	x4, [x4]
     5ec: aa1603e0     	mov	x0, x22
     5f0: aa1703e2     	mov	x2, x23
     5f4: d63f0080     	blr	x4
     5f8: 34ffefe0     	cbz	w0, 0x3f4 <___pl_fn_0+0x3f4>
     5fc: 140000f8     	b	0x9dc <___pl_fn_0+0x9dc>
     600: 52800281     	mov	w1, #0x14               ; =20
     604: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     608: f9400042     	ldr	x2, [x2]
     60c: aa1603e0     	mov	x0, x22
     610: d63f0040     	blr	x2
     614: 52800000     	mov	w0, #0x0                ; =0
     618: 910143ff     	add	sp, sp, #0x50
     61c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     620: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     624: a8c163f7     	ldp	x23, x24, [sp], #0x10
     628: f84107fa     	ldr	x26, [sp], #0x10
     62c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     630: d65f03c0     	ret
     634: 52800261     	mov	w1, #0x13               ; =19
     638: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     63c: f9400042     	ldr	x2, [x2]
     640: aa1603e0     	mov	x0, x22
     644: d63f0040     	blr	x2
     648: 52800000     	mov	w0, #0x0                ; =0
     64c: 910143ff     	add	sp, sp, #0x50
     650: a8c153f3     	ldp	x19, x20, [sp], #0x10
     654: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     658: a8c163f7     	ldp	x23, x24, [sp], #0x10
     65c: f84107fa     	ldr	x26, [sp], #0x10
     660: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     664: d65f03c0     	ret
     668: 52800241     	mov	w1, #0x12               ; =18
     66c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     670: f9400042     	ldr	x2, [x2]
     674: aa1603e0     	mov	x0, x22
     678: d63f0040     	blr	x2
     67c: 52800000     	mov	w0, #0x0                ; =0
     680: 910143ff     	add	sp, sp, #0x50
     684: a8c153f3     	ldp	x19, x20, [sp], #0x10
     688: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     68c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     690: f84107fa     	ldr	x26, [sp], #0x10
     694: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     698: d65f03c0     	ret
     69c: 52800201     	mov	w1, #0x10               ; =16
     6a0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6a4: f9400042     	ldr	x2, [x2]
     6a8: aa1603e0     	mov	x0, x22
     6ac: d63f0040     	blr	x2
     6b0: 52800000     	mov	w0, #0x0                ; =0
     6b4: 910143ff     	add	sp, sp, #0x50
     6b8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6bc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6c0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6c4: f84107fa     	ldr	x26, [sp], #0x10
     6c8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6cc: d65f03c0     	ret
     6d0: 528001e1     	mov	w1, #0xf                ; =15
     6d4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6d8: f9400042     	ldr	x2, [x2]
     6dc: aa1603e0     	mov	x0, x22
     6e0: d63f0040     	blr	x2
     6e4: 52800000     	mov	w0, #0x0                ; =0
     6e8: 910143ff     	add	sp, sp, #0x50
     6ec: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6f0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6f4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6f8: f84107fa     	ldr	x26, [sp], #0x10
     6fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     700: d65f03c0     	ret
     704: 528001c1     	mov	w1, #0xe                ; =14
     708: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     70c: f9400042     	ldr	x2, [x2]
     710: aa1603e0     	mov	x0, x22
     714: d63f0040     	blr	x2
     718: 52800000     	mov	w0, #0x0                ; =0
     71c: 910143ff     	add	sp, sp, #0x50
     720: a8c153f3     	ldp	x19, x20, [sp], #0x10
     724: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     728: a8c163f7     	ldp	x23, x24, [sp], #0x10
     72c: f84107fa     	ldr	x26, [sp], #0x10
     730: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     734: d65f03c0     	ret
     738: 52800181     	mov	w1, #0xc                ; =12
     73c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     740: f9400042     	ldr	x2, [x2]
     744: aa1603e0     	mov	x0, x22
     748: d63f0040     	blr	x2
     74c: 52800000     	mov	w0, #0x0                ; =0
     750: 910143ff     	add	sp, sp, #0x50
     754: a8c153f3     	ldp	x19, x20, [sp], #0x10
     758: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     75c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     760: f84107fa     	ldr	x26, [sp], #0x10
     764: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     768: d65f03c0     	ret
     76c: 52800161     	mov	w1, #0xb                ; =11
     770: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     774: f9400042     	ldr	x2, [x2]
     778: aa1603e0     	mov	x0, x22
     77c: d63f0040     	blr	x2
     780: 52800000     	mov	w0, #0x0                ; =0
     784: 910143ff     	add	sp, sp, #0x50
     788: a8c153f3     	ldp	x19, x20, [sp], #0x10
     78c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     790: a8c163f7     	ldp	x23, x24, [sp], #0x10
     794: f84107fa     	ldr	x26, [sp], #0x10
     798: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     79c: d65f03c0     	ret
     7a0: 52800141     	mov	w1, #0xa                ; =10
     7a4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7a8: f9400042     	ldr	x2, [x2]
     7ac: aa1603e0     	mov	x0, x22
     7b0: d63f0040     	blr	x2
     7b4: 52800000     	mov	w0, #0x0                ; =0
     7b8: 910143ff     	add	sp, sp, #0x50
     7bc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7c0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7c4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7c8: f84107fa     	ldr	x26, [sp], #0x10
     7cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7d0: d65f03c0     	ret
     7d4: 52800101     	mov	w1, #0x8                ; =8
     7d8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7dc: f9400042     	ldr	x2, [x2]
     7e0: aa1603e0     	mov	x0, x22
     7e4: d63f0040     	blr	x2
     7e8: 52800000     	mov	w0, #0x0                ; =0
     7ec: 910143ff     	add	sp, sp, #0x50
     7f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7f4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7f8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7fc: f84107fa     	ldr	x26, [sp], #0x10
     800: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     804: d65f03c0     	ret
     808: 528000e1     	mov	w1, #0x7                ; =7
     80c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     810: f9400042     	ldr	x2, [x2]
     814: aa1603e0     	mov	x0, x22
     818: d63f0040     	blr	x2
     81c: 52800000     	mov	w0, #0x0                ; =0
     820: 910143ff     	add	sp, sp, #0x50
     824: a8c153f3     	ldp	x19, x20, [sp], #0x10
     828: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     82c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     830: f84107fa     	ldr	x26, [sp], #0x10
     834: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     838: d65f03c0     	ret
     83c: 528000c1     	mov	w1, #0x6                ; =6
     840: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     844: f9400042     	ldr	x2, [x2]
     848: aa1603e0     	mov	x0, x22
     84c: d63f0040     	blr	x2
     850: 52800000     	mov	w0, #0x0                ; =0
     854: 910143ff     	add	sp, sp, #0x50
     858: a8c153f3     	ldp	x19, x20, [sp], #0x10
     85c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     860: a8c163f7     	ldp	x23, x24, [sp], #0x10
     864: f84107fa     	ldr	x26, [sp], #0x10
     868: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     86c: d65f03c0     	ret
     870: 1400005b     	b	0x9dc <___pl_fn_0+0x9dc>
     874: d2800081     	mov	x1, #0x4                ; =4
     878: 910103e3     	add	x3, sp, #0x40
     87c: f80403e1     	stur	x1, [sp, #0x40]
     880: f80483e0     	stur	x0, [sp, #0x48]
     884: 52800341     	mov	w1, #0x1a               ; =26
     888: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     88c: f9400084     	ldr	x4, [x4]
     890: aa1603e0     	mov	x0, x22
     894: aa1703e2     	mov	x2, x23
     898: d63f0080     	blr	x4
     89c: 34ffe2c0     	cbz	w0, 0x4f4 <___pl_fn_0+0x4f4>
     8a0: 1400004f     	b	0x9dc <___pl_fn_0+0x9dc>
     8a4: 52800321     	mov	w1, #0x19               ; =25
     8a8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     8ac: f9400084     	ldr	x4, [x4]
     8b0: aa1603e0     	mov	x0, x22
     8b4: d63f0080     	blr	x4
     8b8: 52800000     	mov	w0, #0x0                ; =0
     8bc: 910143ff     	add	sp, sp, #0x50
     8c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8c4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8c8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8cc: f84107fa     	ldr	x26, [sp], #0x10
     8d0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8d4: d65f03c0     	ret
     8d8: 528002e1     	mov	w1, #0x17               ; =23
     8dc: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     8e0: f94000a5     	ldr	x5, [x5]
     8e4: aa1603e0     	mov	x0, x22
     8e8: d63f00a0     	blr	x5
     8ec: 52800000     	mov	w0, #0x0                ; =0
     8f0: 910143ff     	add	sp, sp, #0x50
     8f4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8f8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8fc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     900: f84107fa     	ldr	x26, [sp], #0x10
     904: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     908: d65f03c0     	ret
     90c: 528002c1     	mov	w1, #0x16               ; =22
     910: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     914: f94000c6     	ldr	x6, [x6]
     918: aa1603e0     	mov	x0, x22
     91c: d63f00c0     	blr	x6
     920: 52800000     	mov	w0, #0x0                ; =0
     924: 910143ff     	add	sp, sp, #0x50
     928: a8c153f3     	ldp	x19, x20, [sp], #0x10
     92c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     930: a8c163f7     	ldp	x23, x24, [sp], #0x10
     934: f84107fa     	ldr	x26, [sp], #0x10
     938: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     93c: d65f03c0     	ret
     940: 528000a1     	mov	w1, #0x5                ; =5
     944: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     948: f94000e7     	ldr	x7, [x7]
     94c: aa1603e0     	mov	x0, x22
     950: d63f00e0     	blr	x7
     954: 52800000     	mov	w0, #0x0                ; =0
     958: 910143ff     	add	sp, sp, #0x50
     95c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     960: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     964: a8c163f7     	ldp	x23, x24, [sp], #0x10
     968: f84107fa     	ldr	x26, [sp], #0x10
     96c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     970: d65f03c0     	ret
     974: 52800061     	mov	w1, #0x3                ; =3
     978: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     97c: f9400108     	ldr	x8, [x8]
     980: aa1603e0     	mov	x0, x22
     984: d63f0100     	blr	x8
     988: 52800000     	mov	w0, #0x0                ; =0
     98c: 910143ff     	add	sp, sp, #0x50
     990: a8c153f3     	ldp	x19, x20, [sp], #0x10
     994: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     998: a8c163f7     	ldp	x23, x24, [sp], #0x10
     99c: f84107fa     	ldr	x26, [sp], #0x10
     9a0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9a4: d65f03c0     	ret
     9a8: 52800021     	mov	w1, #0x1                ; =1
     9ac: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     9b0: f9400129     	ldr	x9, [x9]
     9b4: aa1603e0     	mov	x0, x22
     9b8: d63f0120     	blr	x9
     9bc: 52800000     	mov	w0, #0x0                ; =0
     9c0: 910143ff     	add	sp, sp, #0x50
     9c4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9c8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9cc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9d0: f84107fa     	ldr	x26, [sp], #0x10
     9d4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9d8: d65f03c0     	ret
     9dc: 52800000     	mov	w0, #0x0                ; =0
     9e0: 910143ff     	add	sp, sp, #0x50
     9e4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9e8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9ec: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9f0: f84107fa     	ldr	x26, [sp], #0x10
     9f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9f8: d65f03c0     	ret

00000000000009fc <___pl_fn_1>:
     9fc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     a00: 910003fd     	mov	x29, sp
     a04: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     a08: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     a0c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     a10: d10043ff     	sub	sp, sp, #0x10
     a14: b940100e     	ldr	w14, [x0, #0x10]
     a18: 110005ce     	add	w14, w14, #0x1
     a1c: b900100e     	str	w14, [x0, #0x10]
     a20: aa0003f4     	mov	x20, x0
     a24: 52800361     	mov	w1, #0x1b               ; =27
     a28: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     a2c: f94001ef     	ldr	x15, [x15]
     a30: d63f01e0     	blr	x15
     a34: 35001640     	cbnz	w0, 0xcfc <___pl_fn_1+0x300>
     a38: aa1403e0     	mov	x0, x20
     a3c: f9401802     	ldr	x2, [x0, #0x30]
     a40: aa0203f5     	mov	x21, x2
     a44: 52800381     	mov	w1, #0x1c               ; =28
     a48: 52800002     	mov	w2, #0x0                ; =0
     a4c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     a50: f9400063     	ldr	x3, [x3]
     a54: aa1403e0     	mov	x0, x20
     a58: d63f0060     	blr	x3
     a5c: 35001500     	cbnz	w0, 0xcfc <___pl_fn_1+0x300>
     a60: aa1403e0     	mov	x0, x20
     a64: f9401802     	ldr	x2, [x0, #0x30]
     a68: aa0203f6     	mov	x22, x2
     a6c: 528003a1     	mov	w1, #0x1d               ; =29
     a70: 52800002     	mov	w2, #0x0                ; =0
     a74: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     a78: f9400063     	ldr	x3, [x3]
     a7c: d63f0060     	blr	x3
     a80: 350013e0     	cbnz	w0, 0xcfc <___pl_fn_1+0x300>
     a84: aa1403e0     	mov	x0, x20
     a88: f9401801     	ldr	x1, [x0, #0x30]
     a8c: aa0103f7     	mov	x23, x1
     a90: 528003c1     	mov	w1, #0x1e               ; =30
     a94: 52800002     	mov	w2, #0x0                ; =0
     a98: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     a9c: f9400063     	ldr	x3, [x3]
     aa0: d63f0060     	blr	x3
     aa4: 350012c0     	cbnz	w0, 0xcfc <___pl_fn_1+0x300>
     aa8: aa1403e0     	mov	x0, x20
     aac: f9401802     	ldr	x2, [x0, #0x30]
     ab0: 34001102     	cbz	w2, 0xcd0 <___pl_fn_1+0x2d4>
     ab4: 34000b02     	cbz	w2, 0xc14 <___pl_fn_1+0x218>
     ab8: aa1403e0     	mov	x0, x20
     abc: aa0203f8     	mov	x24, x2
     ac0: f9400001     	ldr	x1, [x0]
     ac4: 2a0203e0     	mov	w0, w2
     ac8: 8b000c20     	add	x0, x1, x0, lsl #3
     acc: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     ad0: d360fc21     	lsr	x1, x1, #32
     ad4: 92403c22     	and	x2, x1, #0xffff
     ad8: f100085f     	cmp	x2, #0x2
     adc: 54000080     	b.eq	0xaec <___pl_fn_1+0xf0>
     ae0: f9400802     	ldr	x2, [x0, #0x10]
     ae4: 927ff842     	and	x2, x2, #0xfffffffffffffffe
     ae8: f9000802     	str	x2, [x0, #0x10]
     aec: 52848062     	mov	w2, #0x2403             ; =9219
     af0: 72a00022     	movk	w2, #0x1, lsl #16
     af4: 92403c21     	and	x1, x1, #0xffff
     af8: f8217802     	str	x2, [x0, x1, lsl #3]
     afc: 52800421     	mov	w1, #0x21               ; =33
     b00: d2800003     	mov	x3, #0x0                ; =0
     b04: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b08: f9400084     	ldr	x4, [x4]
     b0c: aa1403e0     	mov	x0, x20
     b10: aa1603e2     	mov	x2, x22
     b14: d63f0080     	blr	x4
     b18: 35000f20     	cbnz	w0, 0xcfc <___pl_fn_1+0x300>
     b1c: aa1403e0     	mov	x0, x20
     b20: b9401813     	ldr	w19, [x0, #0x18]
     b24: b9401c01     	ldr	w1, [x0, #0x1c]
     b28: 11000660     	add	w0, w19, #0x1
     b2c: 6b01001f     	cmp	w0, w1
     b30: 54000ba8     	b.hi	0xca4 <___pl_fn_1+0x2a8>
     b34: aa1403e1     	mov	x1, x20
     b38: f9401021     	ldr	x1, [x1, #0x20]
     b3c: aa1803e2     	mov	x2, x24
     b40: b8335822     	str	w2, [x1, w19, uxtw #2]
     b44: aa1403e1     	mov	x1, x20
     b48: b9001820     	str	w0, [x1, #0x18]
     b4c: aa1403e0     	mov	x0, x20
     b50: b9401000     	ldr	w0, [x0, #0x10]
     b54: b9401421     	ldr	w1, [x1, #0x14]
     b58: 6b01001f     	cmp	w0, w1
     b5c: 540008e2     	b.hs	0xc78 <___pl_fn_1+0x27c>
     b60: aa1703e1     	mov	x1, x23
     b64: aa1803e2     	mov	x2, x24
     b68: aa1403e0     	mov	x0, x20
     b6c: aa1603e3     	mov	x3, x22
     b70: 94000000     	bl	0xb70 <___pl_fn_1+0x174>
     b74: aa1403e1     	mov	x1, x20
     b78: b9402c21     	ldr	w1, [x1, #0x2c]
     b7c: 35000c01     	cbnz	w1, 0xcfc <___pl_fn_1+0x300>
     b80: aa1403e1     	mov	x1, x20
     b84: b9001833     	str	w19, [x1, #0x18]
     b88: 34000620     	cbz	w0, 0xc4c <___pl_fn_1+0x250>
     b8c: 528004a1     	mov	w1, #0x25               ; =37
     b90: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b94: f9400063     	ldr	x3, [x3]
     b98: aa1603e2     	mov	x2, x22
     b9c: aa1403e0     	mov	x0, x20
     ba0: d63f0060     	blr	x3
     ba4: 35000ac0     	cbnz	w0, 0xcfc <___pl_fn_1+0x300>
     ba8: aa1403e0     	mov	x0, x20
     bac: f9401802     	ldr	x2, [x0, #0x30]
     bb0: 528004c1     	mov	w1, #0x26               ; =38
     bb4: 52802003     	mov	w3, #0x100              ; =256
     bb8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     bbc: f9400084     	ldr	x4, [x4]
     bc0: d63f0080     	blr	x4
     bc4: 350009c0     	cbnz	w0, 0xcfc <___pl_fn_1+0x300>
     bc8: 528004e1     	mov	w1, #0x27               ; =39
     bcc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     bd0: f9400063     	ldr	x3, [x3]
     bd4: aa1503e2     	mov	x2, x21
     bd8: aa1403e0     	mov	x0, x20
     bdc: d63f0060     	blr	x3
     be0: 350008e0     	cbnz	w0, 0xcfc <___pl_fn_1+0x300>
     be4: aa1403e0     	mov	x0, x20
     be8: b9401000     	ldr	w0, [x0, #0x10]
     bec: 51000400     	sub	w0, w0, #0x1
     bf0: aa1403ed     	mov	x13, x20
     bf4: b90011a0     	str	w0, [x13, #0x10]
     bf8: 910043ff     	add	sp, sp, #0x10
     bfc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c00: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c04: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c08: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c0c: d65f03c0     	ret
     c10: 1400003b     	b	0xcfc <___pl_fn_1+0x300>
     c14: aa0203f8     	mov	x24, x2
     c18: d2800000     	mov	x0, #0x0                ; =0
     c1c: 910003e3     	mov	x3, sp
     c20: f80003e0     	stur	x0, [sp]
     c24: 52848060     	mov	w0, #0x2403             ; =9219
     c28: 72a00020     	movk	w0, #0x1, lsl #16
     c2c: f80083e0     	stur	x0, [sp, #0x8]
     c30: 52800401     	mov	w1, #0x20               ; =32
     c34: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c38: f9400084     	ldr	x4, [x4]
     c3c: aa1403e0     	mov	x0, x20
     c40: d63f0080     	blr	x4
     c44: 34fff5c0     	cbz	w0, 0xafc <___pl_fn_1+0x100>
     c48: 1400002d     	b	0xcfc <___pl_fn_1+0x300>
     c4c: 52800481     	mov	w1, #0x24               ; =36
     c50: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c54: f9400042     	ldr	x2, [x2]
     c58: aa1403e0     	mov	x0, x20
     c5c: d63f0040     	blr	x2
     c60: 910043ff     	add	sp, sp, #0x10
     c64: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c68: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c6c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c70: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c74: d65f03c0     	ret
     c78: 52800461     	mov	w1, #0x23               ; =35
     c7c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c80: f9400042     	ldr	x2, [x2]
     c84: aa1403e0     	mov	x0, x20
     c88: d63f0040     	blr	x2
     c8c: 910043ff     	add	sp, sp, #0x10
     c90: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c94: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c98: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c9c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ca0: d65f03c0     	ret
     ca4: 52800441     	mov	w1, #0x22               ; =34
     ca8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     cac: f9400042     	ldr	x2, [x2]
     cb0: aa1403e0     	mov	x0, x20
     cb4: d63f0040     	blr	x2
     cb8: 910043ff     	add	sp, sp, #0x10
     cbc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cc0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     cc4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     cc8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ccc: d65f03c0     	ret
     cd0: 528003e1     	mov	w1, #0x1f               ; =31
     cd4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     cd8: f9400042     	ldr	x2, [x2]
     cdc: aa1403e0     	mov	x0, x20
     ce0: d63f0040     	blr	x2
     ce4: 910043ff     	add	sp, sp, #0x10
     ce8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     cf0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     cf4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     cf8: d65f03c0     	ret
     cfc: 910043ff     	add	sp, sp, #0x10
     d00: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d04: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d08: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d0c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d10: d65f03c0     	ret

0000000000000d14 <___pl_fn_2>:
     d14: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     d18: 910003fd     	mov	x29, sp
     d1c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     d20: d10043ff     	sub	sp, sp, #0x10
     d24: aa0103f3     	mov	x19, x1
     d28: b940100a     	ldr	w10, [x0, #0x10]
     d2c: 1100054a     	add	w10, w10, #0x1
     d30: b900100a     	str	w10, [x0, #0x10]
     d34: aa1303e1     	mov	x1, x19
     d38: 34000961     	cbz	w1, 0xe64 <___pl_fn_2+0x150>
     d3c: f940000f     	ldr	x15, [x0]
     d40: aa1303e1     	mov	x1, x19
     d44: aa0003f4     	mov	x20, x0
     d48: 2a0103ee     	mov	w14, w1
     d4c: 8b0e0dee     	add	x14, x15, x14, lsl #3
     d50: f86159ef     	ldr	x15, [x15, w1, uxtw #3]
     d54: d360fdef     	lsr	x15, x15, #32
     d58: 92403de0     	and	x0, x15, #0xffff
     d5c: f86079cf     	ldr	x15, [x14, x0, lsl #3]
     d60: f100081f     	cmp	x0, #0x2
     d64: 540000c0     	b.eq	0xd7c <___pl_fn_2+0x68>
     d68: f94009c0     	ldr	x0, [x14, #0x10]
     d6c: 370007e0     	tbnz	w0, #0x0, 0xe68 <___pl_fn_2+0x154>
     d70: 14000003     	b	0xd7c <___pl_fn_2+0x68>
     d74: aa1403e0     	mov	x0, x20
     d78: f940180f     	ldr	x15, [x0, #0x30]
     d7c: d280a3a1     	mov	x1, #0x51d              ; =1309
     d80: 9b017de0     	mul	x0, x15, x1
     d84: 9b417de1     	smulh	x1, x15, x1
     d88: eb80fc3f     	cmp	x1, x0, asr #63
     d8c: 54000d01     	b.ne	0xf2c <___pl_fn_2+0x218>
     d90: d286c321     	mov	x1, #0x3619             ; =13849
     d94: ab010000     	adds	x0, x0, x1
     d98: 9a9f77e1     	cset	x1, vs
     d9c: 72001c3f     	tst	w1, #0xff
     da0: 54000b21     	b.ne	0xf04 <___pl_fn_2+0x1f0>
     da4: 34000753     	cbz	w19, 0xe8c <___pl_fn_2+0x178>
     da8: aa1403eb     	mov	x11, x20
     dac: f9400162     	ldr	x2, [x11]
     db0: 2a1303e1     	mov	w1, w19
     db4: 8b010c41     	add	x1, x2, x1, lsl #3
     db8: f8735842     	ldr	x2, [x2, w19, uxtw #3]
     dbc: d360fc42     	lsr	x2, x2, #32
     dc0: 92403c43     	and	x3, x2, #0xffff
     dc4: f100087f     	cmp	x3, #0x2
     dc8: 54000080     	b.eq	0xdd8 <___pl_fn_2+0xc4>
     dcc: f9400823     	ldr	x3, [x1, #0x10]
     dd0: 927ff863     	and	x3, x3, #0xfffffffffffffffe
     dd4: f9000823     	str	x3, [x1, #0x10]
     dd8: 934ffc03     	asr	x3, x0, #15
     ddc: d370fc63     	lsr	x3, x3, #48
     de0: 8b030003     	add	x3, x0, x3
     de4: 9270bc63     	and	x3, x3, #0xffffffffffff0000
     de8: cb030000     	sub	x0, x0, x3
     dec: 92403c42     	and	x2, x2, #0xffff
     df0: f8227820     	str	x0, [x1, x2, lsl #3]
     df4: 340006f3     	cbz	w19, 0xed0 <___pl_fn_2+0x1bc>
     df8: aa1403e0     	mov	x0, x20
     dfc: f9400000     	ldr	x0, [x0]
     e00: 2a1303e1     	mov	w1, w19
     e04: 8b010c01     	add	x1, x0, x1, lsl #3
     e08: f8735800     	ldr	x0, [x0, w19, uxtw #3]
     e0c: d360fc00     	lsr	x0, x0, #32
     e10: 92403c02     	and	x2, x0, #0xffff
     e14: f8627820     	ldr	x0, [x1, x2, lsl #3]
     e18: f100085f     	cmp	x2, #0x2
     e1c: 54000100     	b.eq	0xe3c <___pl_fn_2+0x128>
     e20: f9400821     	ldr	x1, [x1, #0x10]
     e24: 37000561     	tbnz	w1, #0x0, 0xed0 <___pl_fn_2+0x1bc>
     e28: 14000005     	b	0xe3c <___pl_fn_2+0x128>
     e2c: aa1403e0     	mov	x0, x20
     e30: f9401800     	ldr	x0, [x0, #0x30]
     e34: aa1403e1     	mov	x1, x20
     e38: 14000002     	b	0xe40 <___pl_fn_2+0x12c>
     e3c: aa1403e1     	mov	x1, x20
     e40: aa1403e1     	mov	x1, x20
     e44: b9401021     	ldr	w1, [x1, #0x10]
     e48: 51000421     	sub	w1, w1, #0x1
     e4c: aa1403e2     	mov	x2, x20
     e50: b9001041     	str	w1, [x2, #0x10]
     e54: 910043ff     	add	sp, sp, #0x10
     e58: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e5c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e60: d65f03c0     	ret
     e64: aa0003f4     	mov	x20, x0
     e68: 52800501     	mov	w1, #0x28               ; =40
     e6c: 52800003     	mov	w3, #0x0                ; =0
     e70: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     e74: f9400084     	ldr	x4, [x4]
     e78: aa1403e0     	mov	x0, x20
     e7c: aa1303e2     	mov	x2, x19
     e80: d63f0080     	blr	x4
     e84: 34fff780     	cbz	w0, 0xd74 <___pl_fn_2+0x60>
     e88: 1400001a     	b	0xef0 <___pl_fn_2+0x1dc>
     e8c: d2800001     	mov	x1, #0x0                ; =0
     e90: 910003e3     	mov	x3, sp
     e94: f80003e1     	stur	x1, [sp]
     e98: 934ffc01     	asr	x1, x0, #15
     e9c: d370fc21     	lsr	x1, x1, #48
     ea0: 8b010001     	add	x1, x0, x1
     ea4: 9270bc21     	and	x1, x1, #0xffffffffffff0000
     ea8: cb010000     	sub	x0, x0, x1
     eac: f80083e0     	stur	x0, [sp, #0x8]
     eb0: 52800581     	mov	w1, #0x2c               ; =44
     eb4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     eb8: f9400084     	ldr	x4, [x4]
     ebc: aa1403e0     	mov	x0, x20
     ec0: aa1303e2     	mov	x2, x19
     ec4: d63f0080     	blr	x4
     ec8: 34fff960     	cbz	w0, 0xdf4 <___pl_fn_2+0xe0>
     ecc: 14000009     	b	0xef0 <___pl_fn_2+0x1dc>
     ed0: 528005a1     	mov	w1, #0x2d               ; =45
     ed4: 52800003     	mov	w3, #0x0                ; =0
     ed8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     edc: f9400084     	ldr	x4, [x4]
     ee0: aa1303e2     	mov	x2, x19
     ee4: aa1403e0     	mov	x0, x20
     ee8: d63f0080     	blr	x4
     eec: 34fffa00     	cbz	w0, 0xe2c <___pl_fn_2+0x118>
     ef0: d2800000     	mov	x0, #0x0                ; =0
     ef4: 910043ff     	add	sp, sp, #0x10
     ef8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     efc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f00: d65f03c0     	ret
     f04: 52800541     	mov	w1, #0x2a               ; =42
     f08: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     f0c: f9400042     	ldr	x2, [x2]
     f10: aa1403e0     	mov	x0, x20
     f14: d63f0040     	blr	x2
     f18: d2800000     	mov	x0, #0x0                ; =0
     f1c: 910043ff     	add	sp, sp, #0x10
     f20: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f24: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f28: d65f03c0     	ret
     f2c: 52800521     	mov	w1, #0x29               ; =41
     f30: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     f34: f9400042     	ldr	x2, [x2]
     f38: aa1403e0     	mov	x0, x20
     f3c: d63f0040     	blr	x2
     f40: d2800000     	mov	x0, #0x0                ; =0
     f44: 910043ff     	add	sp, sp, #0x10
     f48: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f4c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f50: d65f03c0     	ret
