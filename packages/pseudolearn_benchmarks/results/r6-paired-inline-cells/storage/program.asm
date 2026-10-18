
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_69571/storage/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: f81f0ffb     	str	x27, [sp, #-0x10]!
       c: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
      10: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      14: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      18: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      1c: d10143ff     	sub	sp, sp, #0x50
      20: aa0203f9     	mov	x25, x2
      24: aa0303fa     	mov	x26, x3
      28: aa0103fb     	mov	x27, x1
      2c: b9401001     	ldr	w1, [x0, #0x10]
      30: 11000421     	add	w1, w1, #0x1
      34: b9001001     	str	w1, [x0, #0x10]
      38: f9402401     	ldr	x1, [x0, #0x48]
      3c: aa1a03e3     	mov	x3, x26
      40: 2a0303e2     	mov	w2, w3
      44: d1000443     	sub	x3, x2, #0x1
      48: eb01007f     	cmp	x3, x1
      4c: 540028c2     	b.hs	0x564 <___pl_fn_0+0x564>
      50: f9402001     	ldr	x1, [x0, #0x40]
      54: aa0003f6     	mov	x22, x0
      58: d2800503     	mov	x3, #0x28               ; =40
      5c: d1000442     	sub	x2, x2, #0x1
      60: 9b037c40     	mul	x0, x2, x3
      64: 9b030442     	madd	x2, x2, x3, x1
      68: f9400442     	ldr	x2, [x2, #0x8]
      6c: b50000a2     	cbnz	x2, 0x80 <___pl_fn_0+0x80>
      70: 1400013e     	b	0x568 <___pl_fn_0+0x568>
      74: aa1603e0     	mov	x0, x22
      78: f9401800     	ldr	x0, [x0, #0x30]
      7c: 14000002     	b	0x84 <___pl_fn_0+0x84>
      80: f8606820     	ldr	x0, [x1, x0]
      84: d2800021     	mov	x1, #0x1                ; =1
      88: ab010003     	adds	x3, x0, x1
      8c: 9a9f77e0     	cset	x0, vs
      90: 72001c1f     	tst	w0, #0xff
      94: 54004ec1     	b.ne	0xa6c <___pl_fn_0+0xa6c>
      98: 52800041     	mov	w1, #0x2                ; =2
      9c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      a0: f9400084     	ldr	x4, [x4]
      a4: aa1603e0     	mov	x0, x22
      a8: aa1a03e2     	mov	x2, x26
      ac: d63f0080     	blr	x4
      b0: 35004cc0     	cbnz	w0, 0xa48 <___pl_fn_0+0xa48>
      b4: aa1603e0     	mov	x0, x22
      b8: b9401814     	ldr	w20, [x0, #0x18]
      bc: b9401c02     	ldr	w2, [x0, #0x1c]
      c0: 11000681     	add	w1, w20, #0x1
      c4: 6b02003f     	cmp	w1, w2
      c8: 54004a48     	b.hi	0xa10 <___pl_fn_0+0xa10>
      cc: aa1603e0     	mov	x0, x22
      d0: f9401003     	ldr	x3, [x0, #0x20]
      d4: 2a1403f5     	mov	w21, w20
      d8: aa1903e2     	mov	x2, x25
      dc: b8345862     	str	w2, [x3, w20, uxtw #2]
      e0: b9001801     	str	w1, [x0, #0x18]
      e4: 52800081     	mov	w1, #0x4                ; =4
      e8: 52800022     	mov	w2, #0x1                ; =1
      ec: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
      f0: f94000a5     	ldr	x5, [x5]
      f4: d63f00a0     	blr	x5
      f8: 35004a80     	cbnz	w0, 0xa48 <___pl_fn_0+0xa48>
      fc: aa1603e0     	mov	x0, x22
     100: f9401800     	ldr	x0, [x0, #0x30]
     104: aa1603e1     	mov	x1, x22
     108: b9001834     	str	w20, [x1, #0x18]
     10c: 52800008     	mov	w8, #0x0                ; =0
     110: aa0803f8     	mov	x24, x8
     114: 34004620     	cbz	w0, 0x9d8 <___pl_fn_0+0x9d8>
     118: aa1b03f3     	mov	x19, x27
     11c: f100067f     	cmp	x19, #0x1
     120: 540018a0     	b.eq	0x434 <___pl_fn_0+0x434>
     124: d280002b     	mov	x11, #0x1               ; =1
     128: eb0b0261     	subs	x1, x19, x11
     12c: 9a9f77ec     	cset	x12, vs
     130: 72001d9f     	tst	w12, #0xff
     134: 54003c81     	b.ne	0x8c4 <___pl_fn_0+0x8c4>
     138: aa1603e2     	mov	x2, x22
     13c: b9401c4e     	ldr	w14, [x2, #0x1c]
     140: 11000a8d     	add	w13, w20, #0x2
     144: 6b0e01bf     	cmp	w13, w14
     148: 54003a28     	b.hi	0x88c <___pl_fn_0+0x88c>
     14c: aa1603e2     	mov	x2, x22
     150: f940104f     	ldr	x15, [x2, #0x20]
     154: 8b1509e2     	add	x2, x15, x21, lsl #2
     158: aa1903e3     	mov	x3, x25
     15c: b83459e3     	str	w3, [x15, w20, uxtw #2]
     160: b9000440     	str	w0, [x2, #0x4]
     164: aa0003f7     	mov	x23, x0
     168: aa1603e0     	mov	x0, x22
     16c: b900180d     	str	w13, [x0, #0x18]
     170: b9401000     	ldr	w0, [x0, #0x10]
     174: aa1603eb     	mov	x11, x22
     178: b9401562     	ldr	w2, [x11, #0x14]
     17c: 6b02001f     	cmp	w0, w2
     180: 540036a2     	b.hs	0x854 <___pl_fn_0+0x854>
     184: aa1603e0     	mov	x0, x22
     188: aa1903e2     	mov	x2, x25
     18c: aa1a03e3     	mov	x3, x26
     190: 94000000     	bl	0x190 <___pl_fn_0+0x190>
     194: aa1603e1     	mov	x1, x22
     198: b9402c21     	ldr	w1, [x1, #0x2c]
     19c: 35004561     	cbnz	w1, 0xa48 <___pl_fn_0+0xa48>
     1a0: aa1603e1     	mov	x1, x22
     1a4: b9001834     	str	w20, [x1, #0x18]
     1a8: aa1703ef     	mov	x15, x23
     1ac: 34001eef     	cbz	w15, 0x588 <___pl_fn_0+0x588>
     1b0: aa1603e1     	mov	x1, x22
     1b4: aa0f03f7     	mov	x23, x15
     1b8: f9400022     	ldr	x2, [x1]
     1bc: aa1703e1     	mov	x1, x23
     1c0: 2a0103e1     	mov	w1, w1
     1c4: 8b010c41     	add	x1, x2, x1, lsl #3
     1c8: aa1703e3     	mov	x3, x23
     1cc: f8635842     	ldr	x2, [x2, w3, uxtw #3]
     1d0: 2a0003e0     	mov	w0, w0
     1d4: d360fc42     	lsr	x2, x2, #32
     1d8: 92403c42     	and	x2, x2, #0xffff
     1dc: f8227820     	str	x0, [x1, x2, lsl #3]
     1e0: d2800020     	mov	x0, #0x1                ; =1
     1e4: eb000261     	subs	x1, x19, x0
     1e8: 9a9f77e0     	cset	x0, vs
     1ec: 72001c1f     	tst	w0, #0xff
     1f0: 54003161     	b.ne	0x81c <___pl_fn_0+0x81c>
     1f4: aa1603e0     	mov	x0, x22
     1f8: b9401814     	ldr	w20, [x0, #0x18]
     1fc: b9401c02     	ldr	w2, [x0, #0x1c]
     200: 11000a80     	add	w0, w20, #0x2
     204: 6b02001f     	cmp	w0, w2
     208: 54002ee8     	b.hi	0x7e4 <___pl_fn_0+0x7e4>
     20c: aa1603e2     	mov	x2, x22
     210: f9401042     	ldr	x2, [x2, #0x20]
     214: 2a1403e3     	mov	w3, w20
     218: 8b030843     	add	x3, x2, x3, lsl #2
     21c: aa1903e4     	mov	x4, x25
     220: b8345844     	str	w4, [x2, w20, uxtw #2]
     224: aa1703e2     	mov	x2, x23
     228: b9000462     	str	w2, [x3, #0x4]
     22c: aa1603e2     	mov	x2, x22
     230: b9001840     	str	w0, [x2, #0x18]
     234: aa1603e0     	mov	x0, x22
     238: b9401000     	ldr	w0, [x0, #0x10]
     23c: aa1603e3     	mov	x3, x22
     240: b9401462     	ldr	w2, [x3, #0x14]
     244: 6b02001f     	cmp	w0, w2
     248: 54002b22     	b.hs	0x7ac <___pl_fn_0+0x7ac>
     24c: aa1603e0     	mov	x0, x22
     250: aa1903e2     	mov	x2, x25
     254: aa1a03e3     	mov	x3, x26
     258: 94000000     	bl	0x258 <___pl_fn_0+0x258>
     25c: aa1603e8     	mov	x8, x22
     260: b9402d01     	ldr	w1, [x8, #0x2c]
     264: 35003f21     	cbnz	w1, 0xa48 <___pl_fn_0+0xa48>
     268: aa1603ec     	mov	x12, x22
     26c: b9001994     	str	w20, [x12, #0x18]
     270: aa1703e9     	mov	x9, x23
     274: 34001a69     	cbz	w9, 0x5c0 <___pl_fn_0+0x5c0>
     278: aa1603e1     	mov	x1, x22
     27c: f9400022     	ldr	x2, [x1]
     280: aa1703e1     	mov	x1, x23
     284: 2a0103e1     	mov	w1, w1
     288: 8b010c41     	add	x1, x2, x1, lsl #3
     28c: aa1703e3     	mov	x3, x23
     290: f8635842     	ldr	x2, [x2, w3, uxtw #3]
     294: 2a0003e0     	mov	w0, w0
     298: d360fc42     	lsr	x2, x2, #32
     29c: 92403c42     	and	x2, x2, #0xffff
     2a0: 91000442     	add	x2, x2, #0x1
     2a4: f8227820     	str	x0, [x1, x2, lsl #3]
     2a8: d2800020     	mov	x0, #0x1                ; =1
     2ac: eb000261     	subs	x1, x19, x0
     2b0: 9a9f77e0     	cset	x0, vs
     2b4: 72001c1f     	tst	w0, #0xff
     2b8: 540025e1     	b.ne	0x774 <___pl_fn_0+0x774>
     2bc: aa1603e0     	mov	x0, x22
     2c0: b9401814     	ldr	w20, [x0, #0x18]
     2c4: b9401c02     	ldr	w2, [x0, #0x1c]
     2c8: 11000a80     	add	w0, w20, #0x2
     2cc: 6b02001f     	cmp	w0, w2
     2d0: 54002368     	b.hi	0x73c <___pl_fn_0+0x73c>
     2d4: aa1603e2     	mov	x2, x22
     2d8: f9401042     	ldr	x2, [x2, #0x20]
     2dc: 2a1403e3     	mov	w3, w20
     2e0: 8b030843     	add	x3, x2, x3, lsl #2
     2e4: aa1903e5     	mov	x5, x25
     2e8: b8345845     	str	w5, [x2, w20, uxtw #2]
     2ec: aa1703e2     	mov	x2, x23
     2f0: b9000462     	str	w2, [x3, #0x4]
     2f4: aa1603e2     	mov	x2, x22
     2f8: b9001840     	str	w0, [x2, #0x18]
     2fc: aa1603e0     	mov	x0, x22
     300: b9401000     	ldr	w0, [x0, #0x10]
     304: b9401442     	ldr	w2, [x2, #0x14]
     308: 6b02001f     	cmp	w0, w2
     30c: 54001fc2     	b.hs	0x704 <___pl_fn_0+0x704>
     310: aa1603e0     	mov	x0, x22
     314: aa1903e2     	mov	x2, x25
     318: aa1a03e3     	mov	x3, x26
     31c: 94000000     	bl	0x31c <___pl_fn_0+0x31c>
     320: aa1603e1     	mov	x1, x22
     324: b9402c21     	ldr	w1, [x1, #0x2c]
     328: 35003901     	cbnz	w1, 0xa48 <___pl_fn_0+0xa48>
     32c: aa1603e5     	mov	x5, x22
     330: b90018b4     	str	w20, [x5, #0x18]
     334: aa1703e1     	mov	x1, x23
     338: 340015e1     	cbz	w1, 0x5f4 <___pl_fn_0+0x5f4>
     33c: aa1603e1     	mov	x1, x22
     340: f9400027     	ldr	x7, [x1]
     344: aa1703eb     	mov	x11, x23
     348: 2a0b03e6     	mov	w6, w11
     34c: 8b060ce6     	add	x6, x7, x6, lsl #3
     350: aa1703ee     	mov	x14, x23
     354: f86e58e8     	ldr	x8, [x7, w14, uxtw #3]
     358: 2a0003e7     	mov	w7, w0
     35c: d360fd08     	lsr	x8, x8, #32
     360: 92403d08     	and	x8, x8, #0xffff
     364: 91000908     	add	x8, x8, #0x2
     368: f82878c7     	str	x7, [x6, x8, lsl #3]
     36c: d2800028     	mov	x8, #0x1                ; =1
     370: eb080261     	subs	x1, x19, x8
     374: 9a9f77e9     	cset	x9, vs
     378: 72001d3f     	tst	w9, #0xff
     37c: 54001a81     	b.ne	0x6cc <___pl_fn_0+0x6cc>
     380: aa1603e0     	mov	x0, x22
     384: b9401813     	ldr	w19, [x0, #0x18]
     388: b9401c0b     	ldr	w11, [x0, #0x1c]
     38c: 11000a6a     	add	w10, w19, #0x2
     390: 6b0b015f     	cmp	w10, w11
     394: 54001808     	b.hi	0x694 <___pl_fn_0+0x694>
     398: aa1603e0     	mov	x0, x22
     39c: f940100c     	ldr	x12, [x0, #0x20]
     3a0: 2a1303ed     	mov	w13, w19
     3a4: 8b0d098d     	add	x13, x12, x13, lsl #2
     3a8: aa1903e2     	mov	x2, x25
     3ac: b8335982     	str	w2, [x12, w19, uxtw #2]
     3b0: aa1703e0     	mov	x0, x23
     3b4: b90005a0     	str	w0, [x13, #0x4]
     3b8: aa1603e0     	mov	x0, x22
     3bc: b900180a     	str	w10, [x0, #0x18]
     3c0: b940100f     	ldr	w15, [x0, #0x10]
     3c4: b9401400     	ldr	w0, [x0, #0x14]
     3c8: 6b0001ff     	cmp	w15, w0
     3cc: 54001482     	b.hs	0x65c <___pl_fn_0+0x65c>
     3d0: aa1903e2     	mov	x2, x25
     3d4: aa1a03e3     	mov	x3, x26
     3d8: aa1603e0     	mov	x0, x22
     3dc: 94000000     	bl	0x3dc <___pl_fn_0+0x3dc>
     3e0: aa1603e1     	mov	x1, x22
     3e4: b9402c21     	ldr	w1, [x1, #0x2c]
     3e8: 35003301     	cbnz	w1, 0xa48 <___pl_fn_0+0xa48>
     3ec: aa1603e1     	mov	x1, x22
     3f0: b9001833     	str	w19, [x1, #0x18]
     3f4: aa1703e1     	mov	x1, x23
     3f8: 34001181     	cbz	w1, 0x628 <___pl_fn_0+0x628>
     3fc: aa1603ec     	mov	x12, x22
     400: f9400182     	ldr	x2, [x12]
     404: aa1703e1     	mov	x1, x23
     408: 2a0103e1     	mov	w1, w1
     40c: 8b010c41     	add	x1, x2, x1, lsl #3
     410: aa1703e3     	mov	x3, x23
     414: f8635842     	ldr	x2, [x2, w3, uxtw #3]
     418: 2a0003e0     	mov	w0, w0
     41c: d360fc42     	lsr	x2, x2, #32
     420: 92403c42     	and	x2, x2, #0xffff
     424: 91000c42     	add	x2, x2, #0x3
     428: f8227820     	str	x0, [x1, x2, lsl #3]
     42c: aa1603e0     	mov	x0, x22
     430: 14000040     	b	0x530 <___pl_fn_0+0x530>
     434: aa0003f7     	mov	x23, x0
     438: aa1603e0     	mov	x0, x22
     43c: b9401c01     	ldr	w1, [x0, #0x1c]
     440: 11000a80     	add	w0, w20, #0x2
     444: 6b01001f     	cmp	w0, w1
     448: 54002ac8     	b.hi	0x9a0 <___pl_fn_0+0x9a0>
     44c: aa1603e1     	mov	x1, x22
     450: f9401021     	ldr	x1, [x1, #0x20]
     454: 8b150822     	add	x2, x1, x21, lsl #2
     458: aa1903e3     	mov	x3, x25
     45c: b8345823     	str	w3, [x1, w20, uxtw #2]
     460: aa1703e3     	mov	x3, x23
     464: b9000443     	str	w3, [x2, #0x4]
     468: aa1603e1     	mov	x1, x22
     46c: b9001820     	str	w0, [x1, #0x18]
     470: aa1603e0     	mov	x0, x22
     474: b9401000     	ldr	w0, [x0, #0x10]
     478: b9401421     	ldr	w1, [x1, #0x14]
     47c: 6b01001f     	cmp	w0, w1
     480: 54002742     	b.hs	0x968 <___pl_fn_0+0x968>
     484: aa1903e1     	mov	x1, x25
     488: aa1603e0     	mov	x0, x22
     48c: 94000000     	bl	0x48c <___pl_fn_0+0x48c>
     490: aa1603e1     	mov	x1, x22
     494: b9402c21     	ldr	w1, [x1, #0x2c]
     498: 35002d81     	cbnz	w1, 0xa48 <___pl_fn_0+0xa48>
     49c: aa1603e1     	mov	x1, x22
     4a0: b9001834     	str	w20, [x1, #0x18]
     4a4: d28ccce1     	mov	x1, #0x6667             ; =26215
     4a8: f2acccc1     	movk	x1, #0x6666, lsl #16
     4ac: f2ccccc1     	movk	x1, #0x6666, lsl #32
     4b0: f2ecccc1     	movk	x1, #0x6666, lsl #48
     4b4: 9b417c01     	smulh	x1, x0, x1
     4b8: 9342fc21     	asr	x1, x1, #2
     4bc: d37ffc22     	lsr	x2, x1, #63
     4c0: 8b020021     	add	x1, x1, x2
     4c4: d2800142     	mov	x2, #0xa                ; =10
     4c8: 9b028020     	msub	x0, x1, x2, x0
     4cc: d2800021     	mov	x1, #0x1                ; =1
     4d0: ab010000     	adds	x0, x0, x1
     4d4: 9a9f77e1     	cset	x1, vs
     4d8: 72001c3f     	tst	w1, #0xff
     4dc: 540022a1     	b.ne	0x930 <___pl_fn_0+0x930>
     4e0: aa1703e1     	mov	x1, x23
     4e4: 340020e1     	cbz	w1, 0x900 <___pl_fn_0+0x900>
     4e8: aa1603ea     	mov	x10, x22
     4ec: f9400142     	ldr	x2, [x10]
     4f0: aa1703e1     	mov	x1, x23
     4f4: 2a0103e1     	mov	w1, w1
     4f8: 8b010c41     	add	x1, x2, x1, lsl #3
     4fc: aa1703e3     	mov	x3, x23
     500: f8635842     	ldr	x2, [x2, w3, uxtw #3]
     504: d360fc42     	lsr	x2, x2, #32
     508: 92403c43     	and	x3, x2, #0xffff
     50c: f100087f     	cmp	x3, #0x2
     510: 54000080     	b.eq	0x520 <___pl_fn_0+0x520>
     514: f9400823     	ldr	x3, [x1, #0x10]
     518: 927bf863     	and	x3, x3, #0xffffffffffffffef
     51c: f9000823     	str	x3, [x1, #0x10]
     520: 92403c42     	and	x2, x2, #0xffff
     524: 91001042     	add	x2, x2, #0x4
     528: f8227820     	str	x0, [x1, x2, lsl #3]
     52c: aa1603e0     	mov	x0, x22
     530: aa1603e0     	mov	x0, x22
     534: b9401005     	ldr	w5, [x0, #0x10]
     538: 510004a5     	sub	w5, w5, #0x1
     53c: b9001005     	str	w5, [x0, #0x10]
     540: aa1703e0     	mov	x0, x23
     544: 910143ff     	add	sp, sp, #0x50
     548: a8c153f3     	ldp	x19, x20, [sp], #0x10
     54c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     550: a8c163f7     	ldp	x23, x24, [sp], #0x10
     554: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     558: f84107fb     	ldr	x27, [sp], #0x10
     55c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     560: d65f03c0     	ret
     564: aa0003f6     	mov	x22, x0
     568: 52800001     	mov	w1, #0x0                ; =0
     56c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     570: f9400063     	ldr	x3, [x3]
     574: aa1603e0     	mov	x0, x22
     578: aa1a03e2     	mov	x2, x26
     57c: d63f0060     	blr	x3
     580: 34ffd7a0     	cbz	w0, 0x74 <___pl_fn_0+0x74>
     584: 14000131     	b	0xa48 <___pl_fn_0+0xa48>
     588: aa0f03f7     	mov	x23, x15
     58c: d2800001     	mov	x1, #0x0                ; =0
     590: 910003e3     	mov	x3, sp
     594: f80003e1     	stur	x1, [sp]
     598: 2a0003e0     	mov	w0, w0
     59c: f80083e0     	stur	x0, [sp, #0x8]
     5a0: 52800121     	mov	w1, #0x9                ; =9
     5a4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5a8: f9400084     	ldr	x4, [x4]
     5ac: aa1603e0     	mov	x0, x22
     5b0: aa1703e2     	mov	x2, x23
     5b4: d63f0080     	blr	x4
     5b8: 34ffe140     	cbz	w0, 0x1e0 <___pl_fn_0+0x1e0>
     5bc: 14000123     	b	0xa48 <___pl_fn_0+0xa48>
     5c0: d2800021     	mov	x1, #0x1                ; =1
     5c4: 910043e3     	add	x3, sp, #0x10
     5c8: f80103e1     	stur	x1, [sp, #0x10]
     5cc: 2a0003e0     	mov	w0, w0
     5d0: f80183e0     	stur	x0, [sp, #0x18]
     5d4: 528001a1     	mov	w1, #0xd                ; =13
     5d8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5dc: f9400084     	ldr	x4, [x4]
     5e0: aa1603e0     	mov	x0, x22
     5e4: aa1703e2     	mov	x2, x23
     5e8: d63f0080     	blr	x4
     5ec: 34ffe5e0     	cbz	w0, 0x2a8 <___pl_fn_0+0x2a8>
     5f0: 14000116     	b	0xa48 <___pl_fn_0+0xa48>
     5f4: d2800041     	mov	x1, #0x2                ; =2
     5f8: 910083e3     	add	x3, sp, #0x20
     5fc: f80203e1     	stur	x1, [sp, #0x20]
     600: 2a0003e2     	mov	w2, w0
     604: f80283e2     	stur	x2, [sp, #0x28]
     608: 52800221     	mov	w1, #0x11               ; =17
     60c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     610: f9400084     	ldr	x4, [x4]
     614: aa1603e0     	mov	x0, x22
     618: aa1703e2     	mov	x2, x23
     61c: d63f0080     	blr	x4
     620: 34ffea60     	cbz	w0, 0x36c <___pl_fn_0+0x36c>
     624: 14000109     	b	0xa48 <___pl_fn_0+0xa48>
     628: d2800061     	mov	x1, #0x3                ; =3
     62c: 9100c3e3     	add	x3, sp, #0x30
     630: f80303e1     	stur	x1, [sp, #0x30]
     634: 2a0003e0     	mov	w0, w0
     638: f80383e0     	stur	x0, [sp, #0x38]
     63c: 528002a1     	mov	w1, #0x15               ; =21
     640: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     644: f9400084     	ldr	x4, [x4]
     648: aa1603e0     	mov	x0, x22
     64c: aa1703e2     	mov	x2, x23
     650: d63f0080     	blr	x4
     654: 34ffeec0     	cbz	w0, 0x42c <___pl_fn_0+0x42c>
     658: 140000fc     	b	0xa48 <___pl_fn_0+0xa48>
     65c: 52800281     	mov	w1, #0x14               ; =20
     660: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     664: f9400042     	ldr	x2, [x2]
     668: aa1603e0     	mov	x0, x22
     66c: d63f0040     	blr	x2
     670: aa1803e0     	mov	x0, x24
     674: 910143ff     	add	sp, sp, #0x50
     678: a8c153f3     	ldp	x19, x20, [sp], #0x10
     67c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     680: a8c163f7     	ldp	x23, x24, [sp], #0x10
     684: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     688: f84107fb     	ldr	x27, [sp], #0x10
     68c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     690: d65f03c0     	ret
     694: 52800261     	mov	w1, #0x13               ; =19
     698: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     69c: f9400042     	ldr	x2, [x2]
     6a0: aa1603e0     	mov	x0, x22
     6a4: d63f0040     	blr	x2
     6a8: aa1803e0     	mov	x0, x24
     6ac: 910143ff     	add	sp, sp, #0x50
     6b0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6b4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6b8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6bc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6c0: f84107fb     	ldr	x27, [sp], #0x10
     6c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6c8: d65f03c0     	ret
     6cc: 52800241     	mov	w1, #0x12               ; =18
     6d0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6d4: f9400042     	ldr	x2, [x2]
     6d8: aa1603e0     	mov	x0, x22
     6dc: d63f0040     	blr	x2
     6e0: aa1803e0     	mov	x0, x24
     6e4: 910143ff     	add	sp, sp, #0x50
     6e8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6ec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6f0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6f4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6f8: f84107fb     	ldr	x27, [sp], #0x10
     6fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     700: d65f03c0     	ret
     704: 52800201     	mov	w1, #0x10               ; =16
     708: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     70c: f9400042     	ldr	x2, [x2]
     710: aa1603e0     	mov	x0, x22
     714: d63f0040     	blr	x2
     718: aa1803e0     	mov	x0, x24
     71c: 910143ff     	add	sp, sp, #0x50
     720: a8c153f3     	ldp	x19, x20, [sp], #0x10
     724: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     728: a8c163f7     	ldp	x23, x24, [sp], #0x10
     72c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     730: f84107fb     	ldr	x27, [sp], #0x10
     734: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     738: d65f03c0     	ret
     73c: 528001e1     	mov	w1, #0xf                ; =15
     740: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     744: f9400042     	ldr	x2, [x2]
     748: aa1603e0     	mov	x0, x22
     74c: d63f0040     	blr	x2
     750: aa1803e0     	mov	x0, x24
     754: 910143ff     	add	sp, sp, #0x50
     758: a8c153f3     	ldp	x19, x20, [sp], #0x10
     75c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     760: a8c163f7     	ldp	x23, x24, [sp], #0x10
     764: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     768: f84107fb     	ldr	x27, [sp], #0x10
     76c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     770: d65f03c0     	ret
     774: 528001c1     	mov	w1, #0xe                ; =14
     778: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     77c: f9400042     	ldr	x2, [x2]
     780: aa1603e0     	mov	x0, x22
     784: d63f0040     	blr	x2
     788: aa1803e0     	mov	x0, x24
     78c: 910143ff     	add	sp, sp, #0x50
     790: a8c153f3     	ldp	x19, x20, [sp], #0x10
     794: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     798: a8c163f7     	ldp	x23, x24, [sp], #0x10
     79c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7a0: f84107fb     	ldr	x27, [sp], #0x10
     7a4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7a8: d65f03c0     	ret
     7ac: 52800181     	mov	w1, #0xc                ; =12
     7b0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7b4: f9400042     	ldr	x2, [x2]
     7b8: aa1603e0     	mov	x0, x22
     7bc: d63f0040     	blr	x2
     7c0: aa1803e0     	mov	x0, x24
     7c4: 910143ff     	add	sp, sp, #0x50
     7c8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7cc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7d0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7d4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7d8: f84107fb     	ldr	x27, [sp], #0x10
     7dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7e0: d65f03c0     	ret
     7e4: 52800161     	mov	w1, #0xb                ; =11
     7e8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7ec: f9400042     	ldr	x2, [x2]
     7f0: aa1603e0     	mov	x0, x22
     7f4: d63f0040     	blr	x2
     7f8: aa1803e0     	mov	x0, x24
     7fc: 910143ff     	add	sp, sp, #0x50
     800: a8c153f3     	ldp	x19, x20, [sp], #0x10
     804: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     808: a8c163f7     	ldp	x23, x24, [sp], #0x10
     80c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     810: f84107fb     	ldr	x27, [sp], #0x10
     814: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     818: d65f03c0     	ret
     81c: 52800141     	mov	w1, #0xa                ; =10
     820: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     824: f9400042     	ldr	x2, [x2]
     828: aa1603e0     	mov	x0, x22
     82c: d63f0040     	blr	x2
     830: aa1803e0     	mov	x0, x24
     834: 910143ff     	add	sp, sp, #0x50
     838: a8c153f3     	ldp	x19, x20, [sp], #0x10
     83c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     840: a8c163f7     	ldp	x23, x24, [sp], #0x10
     844: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     848: f84107fb     	ldr	x27, [sp], #0x10
     84c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     850: d65f03c0     	ret
     854: 52800101     	mov	w1, #0x8                ; =8
     858: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     85c: f9400042     	ldr	x2, [x2]
     860: aa1603e0     	mov	x0, x22
     864: d63f0040     	blr	x2
     868: aa1803e0     	mov	x0, x24
     86c: 910143ff     	add	sp, sp, #0x50
     870: a8c153f3     	ldp	x19, x20, [sp], #0x10
     874: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     878: a8c163f7     	ldp	x23, x24, [sp], #0x10
     87c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     880: f84107fb     	ldr	x27, [sp], #0x10
     884: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     888: d65f03c0     	ret
     88c: 528000e1     	mov	w1, #0x7                ; =7
     890: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     894: f9400042     	ldr	x2, [x2]
     898: aa1603e0     	mov	x0, x22
     89c: d63f0040     	blr	x2
     8a0: aa1803e0     	mov	x0, x24
     8a4: 910143ff     	add	sp, sp, #0x50
     8a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8b0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8b4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8b8: f84107fb     	ldr	x27, [sp], #0x10
     8bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8c0: d65f03c0     	ret
     8c4: 528000c1     	mov	w1, #0x6                ; =6
     8c8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     8cc: f9400042     	ldr	x2, [x2]
     8d0: aa1603e0     	mov	x0, x22
     8d4: d63f0040     	blr	x2
     8d8: aa1803e0     	mov	x0, x24
     8dc: 910143ff     	add	sp, sp, #0x50
     8e0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8e4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8e8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8ec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8f0: f84107fb     	ldr	x27, [sp], #0x10
     8f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8f8: d65f03c0     	ret
     8fc: 14000053     	b	0xa48 <___pl_fn_0+0xa48>
     900: d2800081     	mov	x1, #0x4                ; =4
     904: 910103e3     	add	x3, sp, #0x40
     908: f80403e1     	stur	x1, [sp, #0x40]
     90c: f80483e0     	stur	x0, [sp, #0x48]
     910: 52800341     	mov	w1, #0x1a               ; =26
     914: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     918: f9400084     	ldr	x4, [x4]
     91c: aa1603e0     	mov	x0, x22
     920: aa1703e2     	mov	x2, x23
     924: d63f0080     	blr	x4
     928: 34ffe020     	cbz	w0, 0x52c <___pl_fn_0+0x52c>
     92c: 14000047     	b	0xa48 <___pl_fn_0+0xa48>
     930: 52800321     	mov	w1, #0x19               ; =25
     934: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     938: f94000e7     	ldr	x7, [x7]
     93c: aa1603e0     	mov	x0, x22
     940: d63f00e0     	blr	x7
     944: aa1803e0     	mov	x0, x24
     948: 910143ff     	add	sp, sp, #0x50
     94c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     950: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     954: a8c163f7     	ldp	x23, x24, [sp], #0x10
     958: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     95c: f84107fb     	ldr	x27, [sp], #0x10
     960: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     964: d65f03c0     	ret
     968: 528002e1     	mov	w1, #0x17               ; =23
     96c: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     970: f9400108     	ldr	x8, [x8]
     974: aa1603e0     	mov	x0, x22
     978: d63f0100     	blr	x8
     97c: aa1803e0     	mov	x0, x24
     980: 910143ff     	add	sp, sp, #0x50
     984: a8c153f3     	ldp	x19, x20, [sp], #0x10
     988: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     98c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     990: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     994: f84107fb     	ldr	x27, [sp], #0x10
     998: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     99c: d65f03c0     	ret
     9a0: 528002c1     	mov	w1, #0x16               ; =22
     9a4: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     9a8: f9400129     	ldr	x9, [x9]
     9ac: aa1603e0     	mov	x0, x22
     9b0: d63f0120     	blr	x9
     9b4: aa1803e0     	mov	x0, x24
     9b8: 910143ff     	add	sp, sp, #0x50
     9bc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9c0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9c4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9c8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9cc: f84107fb     	ldr	x27, [sp], #0x10
     9d0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9d4: d65f03c0     	ret
     9d8: 528000a1     	mov	w1, #0x5                ; =5
     9dc: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     9e0: f940014a     	ldr	x10, [x10]
     9e4: aa1603e0     	mov	x0, x22
     9e8: d63f0140     	blr	x10
     9ec: aa1803e0     	mov	x0, x24
     9f0: 910143ff     	add	sp, sp, #0x50
     9f4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9f8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9fc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a00: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a04: f84107fb     	ldr	x27, [sp], #0x10
     a08: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a0c: d65f03c0     	ret
     a10: 52800061     	mov	w1, #0x3                ; =3
     a14: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     a18: f940016b     	ldr	x11, [x11]
     a1c: aa1603e0     	mov	x0, x22
     a20: d63f0160     	blr	x11
     a24: 52800000     	mov	w0, #0x0                ; =0
     a28: 910143ff     	add	sp, sp, #0x50
     a2c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a30: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a34: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a38: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a3c: f84107fb     	ldr	x27, [sp], #0x10
     a40: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a44: d65f03c0     	ret
     a48: 52800000     	mov	w0, #0x0                ; =0
     a4c: 910143ff     	add	sp, sp, #0x50
     a50: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a54: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a58: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a5c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a60: f84107fb     	ldr	x27, [sp], #0x10
     a64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a68: d65f03c0     	ret
     a6c: 52800021     	mov	w1, #0x1                ; =1
     a70: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     a74: f94001ad     	ldr	x13, [x13]
     a78: aa1603e0     	mov	x0, x22
     a7c: d63f01a0     	blr	x13
     a80: 52800000     	mov	w0, #0x0                ; =0
     a84: 910143ff     	add	sp, sp, #0x50
     a88: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a8c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a90: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a94: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a98: f84107fb     	ldr	x27, [sp], #0x10
     a9c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     aa0: d65f03c0     	ret

0000000000000aa4 <___pl_fn_1>:
     aa4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     aa8: 910003fd     	mov	x29, sp
     aac: a9bf6bf7     	stp	x23, x26, [sp, #-0x10]!
     ab0: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     ab4: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     ab8: d10043ff     	sub	sp, sp, #0x10
     abc: b9401001     	ldr	w1, [x0, #0x10]
     ac0: 11000421     	add	w1, w1, #0x1
     ac4: b9001001     	str	w1, [x0, #0x10]
     ac8: aa0003fa     	mov	x26, x0
     acc: 52800361     	mov	w1, #0x1b               ; =27
     ad0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     ad4: f9400042     	ldr	x2, [x2]
     ad8: d63f0040     	blr	x2
     adc: 350018a0     	cbnz	w0, 0xdf0 <___pl_fn_1+0x34c>
     ae0: aa1a03e0     	mov	x0, x26
     ae4: f9401802     	ldr	x2, [x0, #0x30]
     ae8: aa0203f4     	mov	x20, x2
     aec: 52800381     	mov	w1, #0x1c               ; =28
     af0: 52800002     	mov	w2, #0x0                ; =0
     af4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     af8: f9400063     	ldr	x3, [x3]
     afc: aa1a03e0     	mov	x0, x26
     b00: d63f0060     	blr	x3
     b04: 35001760     	cbnz	w0, 0xdf0 <___pl_fn_1+0x34c>
     b08: aa1a03e0     	mov	x0, x26
     b0c: f9401802     	ldr	x2, [x0, #0x30]
     b10: aa0203f5     	mov	x21, x2
     b14: 528003a1     	mov	w1, #0x1d               ; =29
     b18: 52800002     	mov	w2, #0x0                ; =0
     b1c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b20: f9400063     	ldr	x3, [x3]
     b24: d63f0060     	blr	x3
     b28: 35001640     	cbnz	w0, 0xdf0 <___pl_fn_1+0x34c>
     b2c: aa1a03e0     	mov	x0, x26
     b30: f9401801     	ldr	x1, [x0, #0x30]
     b34: aa0103f6     	mov	x22, x1
     b38: 528003c1     	mov	w1, #0x1e               ; =30
     b3c: 52800002     	mov	w2, #0x0                ; =0
     b40: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b44: f9400063     	ldr	x3, [x3]
     b48: d63f0060     	blr	x3
     b4c: 35001520     	cbnz	w0, 0xdf0 <___pl_fn_1+0x34c>
     b50: aa1a03e0     	mov	x0, x26
     b54: f9401802     	ldr	x2, [x0, #0x30]
     b58: 34001362     	cbz	w2, 0xdc4 <___pl_fn_1+0x320>
     b5c: 34000c62     	cbz	w2, 0xce8 <___pl_fn_1+0x244>
     b60: aa1a03e0     	mov	x0, x26
     b64: aa0203f7     	mov	x23, x2
     b68: f9400001     	ldr	x1, [x0]
     b6c: 2a0203e0     	mov	w0, w2
     b70: 8b000c20     	add	x0, x1, x0, lsl #3
     b74: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     b78: d360fc21     	lsr	x1, x1, #32
     b7c: 92403c22     	and	x2, x1, #0xffff
     b80: f100085f     	cmp	x2, #0x2
     b84: 54000080     	b.eq	0xb94 <___pl_fn_1+0xf0>
     b88: f9400802     	ldr	x2, [x0, #0x10]
     b8c: 927ff842     	and	x2, x2, #0xfffffffffffffffe
     b90: f9000802     	str	x2, [x0, #0x10]
     b94: 52848062     	mov	w2, #0x2403             ; =9219
     b98: 72a00022     	movk	w2, #0x1, lsl #16
     b9c: 92403c21     	and	x1, x1, #0xffff
     ba0: f8217802     	str	x2, [x0, x1, lsl #3]
     ba4: 52800421     	mov	w1, #0x21               ; =33
     ba8: d2800003     	mov	x3, #0x0                ; =0
     bac: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     bb0: f9400084     	ldr	x4, [x4]
     bb4: aa1a03e0     	mov	x0, x26
     bb8: aa1503e2     	mov	x2, x21
     bbc: d63f0080     	blr	x4
     bc0: 35001180     	cbnz	w0, 0xdf0 <___pl_fn_1+0x34c>
     bc4: aa1a03e0     	mov	x0, x26
     bc8: b9401813     	ldr	w19, [x0, #0x18]
     bcc: b9401c01     	ldr	w1, [x0, #0x1c]
     bd0: 11000660     	add	w0, w19, #0x1
     bd4: 6b01001f     	cmp	w0, w1
     bd8: 54000e08     	b.hi	0xd98 <___pl_fn_1+0x2f4>
     bdc: aa1a03e1     	mov	x1, x26
     be0: f9401021     	ldr	x1, [x1, #0x20]
     be4: aa1703e2     	mov	x2, x23
     be8: b8335822     	str	w2, [x1, w19, uxtw #2]
     bec: aa1a03e1     	mov	x1, x26
     bf0: b9001820     	str	w0, [x1, #0x18]
     bf4: aa1a03e0     	mov	x0, x26
     bf8: b9401000     	ldr	w0, [x0, #0x10]
     bfc: b9401421     	ldr	w1, [x1, #0x14]
     c00: 6b01001f     	cmp	w0, w1
     c04: 54000b42     	b.hs	0xd6c <___pl_fn_1+0x2c8>
     c08: aa1603e1     	mov	x1, x22
     c0c: aa1703e2     	mov	x2, x23
     c10: aa1a03e0     	mov	x0, x26
     c14: aa1503e3     	mov	x3, x21
     c18: 94000000     	bl	0xc18 <___pl_fn_1+0x174>
     c1c: aa1a03e1     	mov	x1, x26
     c20: b9402c21     	ldr	w1, [x1, #0x2c]
     c24: 35000e61     	cbnz	w1, 0xdf0 <___pl_fn_1+0x34c>
     c28: aa1a03e1     	mov	x1, x26
     c2c: b9001833     	str	w19, [x1, #0x18]
     c30: 34000880     	cbz	w0, 0xd40 <___pl_fn_1+0x29c>
     c34: aa1a03e0     	mov	x0, x26
     c38: f9402401     	ldr	x1, [x0, #0x48]
     c3c: aa1503e2     	mov	x2, x21
     c40: 2a0203e0     	mov	w0, w2
     c44: d1000402     	sub	x2, x0, #0x1
     c48: eb01005f     	cmp	x2, x1
     c4c: 540006a2     	b.hs	0xd20 <___pl_fn_1+0x27c>
     c50: aa1a03ea     	mov	x10, x26
     c54: f9402141     	ldr	x1, [x10, #0x40]
     c58: d2800503     	mov	x3, #0x28               ; =40
     c5c: d1000404     	sub	x4, x0, #0x1
     c60: 9b037c82     	mul	x2, x4, x3
     c64: 9b030483     	madd	x3, x4, x3, x1
     c68: f9400463     	ldr	x3, [x3, #0x8]
     c6c: b50000a3     	cbnz	x3, 0xc80 <___pl_fn_1+0x1dc>
     c70: 1400002c     	b	0xd20 <___pl_fn_1+0x27c>
     c74: aa1a03e0     	mov	x0, x26
     c78: f9401802     	ldr	x2, [x0, #0x30]
     c7c: 14000002     	b	0xc84 <___pl_fn_1+0x1e0>
     c80: f8626822     	ldr	x2, [x1, x2]
     c84: 528004c1     	mov	w1, #0x26               ; =38
     c88: 52802003     	mov	w3, #0x100              ; =256
     c8c: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     c90: f94000e7     	ldr	x7, [x7]
     c94: aa1a03e0     	mov	x0, x26
     c98: d63f00e0     	blr	x7
     c9c: 35000aa0     	cbnz	w0, 0xdf0 <___pl_fn_1+0x34c>
     ca0: 528004e1     	mov	w1, #0x27               ; =39
     ca4: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     ca8: f9400129     	ldr	x9, [x9]
     cac: aa1403e2     	mov	x2, x20
     cb0: aa1a03e0     	mov	x0, x26
     cb4: d63f0120     	blr	x9
     cb8: 350009c0     	cbnz	w0, 0xdf0 <___pl_fn_1+0x34c>
     cbc: aa1a03e0     	mov	x0, x26
     cc0: b940100b     	ldr	w11, [x0, #0x10]
     cc4: 5100056b     	sub	w11, w11, #0x1
     cc8: b900100b     	str	w11, [x0, #0x10]
     ccc: 910043ff     	add	sp, sp, #0x10
     cd0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cd4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     cd8: a8c16bf7     	ldp	x23, x26, [sp], #0x10
     cdc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ce0: d65f03c0     	ret
     ce4: 14000043     	b	0xdf0 <___pl_fn_1+0x34c>
     ce8: aa0203f7     	mov	x23, x2
     cec: d2800000     	mov	x0, #0x0                ; =0
     cf0: 910003e3     	mov	x3, sp
     cf4: f80003e0     	stur	x0, [sp]
     cf8: 52848060     	mov	w0, #0x2403             ; =9219
     cfc: 72a00020     	movk	w0, #0x1, lsl #16
     d00: f80083e0     	stur	x0, [sp, #0x8]
     d04: 52800401     	mov	w1, #0x20               ; =32
     d08: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     d0c: f9400084     	ldr	x4, [x4]
     d10: aa1a03e0     	mov	x0, x26
     d14: d63f0080     	blr	x4
     d18: 34fff460     	cbz	w0, 0xba4 <___pl_fn_1+0x100>
     d1c: 14000035     	b	0xdf0 <___pl_fn_1+0x34c>
     d20: 528004a1     	mov	w1, #0x25               ; =37
     d24: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     d28: f9400063     	ldr	x3, [x3]
     d2c: aa1503e2     	mov	x2, x21
     d30: aa1a03e0     	mov	x0, x26
     d34: d63f0060     	blr	x3
     d38: 34fff9e0     	cbz	w0, 0xc74 <___pl_fn_1+0x1d0>
     d3c: 1400002d     	b	0xdf0 <___pl_fn_1+0x34c>
     d40: 52800481     	mov	w1, #0x24               ; =36
     d44: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     d48: f94001ad     	ldr	x13, [x13]
     d4c: aa1a03e0     	mov	x0, x26
     d50: d63f01a0     	blr	x13
     d54: 910043ff     	add	sp, sp, #0x10
     d58: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d5c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d60: a8c16bf7     	ldp	x23, x26, [sp], #0x10
     d64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d68: d65f03c0     	ret
     d6c: 52800461     	mov	w1, #0x23               ; =35
     d70: 9000000e     	adrp	x14, 0x0 <___pl_fn_0>
     d74: f94001ce     	ldr	x14, [x14]
     d78: aa1a03e0     	mov	x0, x26
     d7c: d63f01c0     	blr	x14
     d80: 910043ff     	add	sp, sp, #0x10
     d84: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d88: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d8c: a8c16bf7     	ldp	x23, x26, [sp], #0x10
     d90: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d94: d65f03c0     	ret
     d98: 52800441     	mov	w1, #0x22               ; =34
     d9c: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     da0: f94001ef     	ldr	x15, [x15]
     da4: aa1a03e0     	mov	x0, x26
     da8: d63f01e0     	blr	x15
     dac: 910043ff     	add	sp, sp, #0x10
     db0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     db4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     db8: a8c16bf7     	ldp	x23, x26, [sp], #0x10
     dbc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     dc0: d65f03c0     	ret
     dc4: 528003e1     	mov	w1, #0x1f               ; =31
     dc8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     dcc: f9400042     	ldr	x2, [x2]
     dd0: aa1a03e0     	mov	x0, x26
     dd4: d63f0040     	blr	x2
     dd8: 910043ff     	add	sp, sp, #0x10
     ddc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     de0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     de4: a8c16bf7     	ldp	x23, x26, [sp], #0x10
     de8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     dec: d65f03c0     	ret
     df0: 910043ff     	add	sp, sp, #0x10
     df4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     df8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     dfc: a8c16bf7     	ldp	x23, x26, [sp], #0x10
     e00: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e04: d65f03c0     	ret

0000000000000e08 <___pl_fn_2>:
     e08: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     e0c: 910003fd     	mov	x29, sp
     e10: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     e14: d10043ff     	sub	sp, sp, #0x10
     e18: aa0103f3     	mov	x19, x1
     e1c: b940100a     	ldr	w10, [x0, #0x10]
     e20: 1100054a     	add	w10, w10, #0x1
     e24: b900100a     	str	w10, [x0, #0x10]
     e28: aa1303e1     	mov	x1, x19
     e2c: 34000961     	cbz	w1, 0xf58 <___pl_fn_2+0x150>
     e30: f940000f     	ldr	x15, [x0]
     e34: aa1303e1     	mov	x1, x19
     e38: aa0003f4     	mov	x20, x0
     e3c: 2a0103ee     	mov	w14, w1
     e40: 8b0e0dee     	add	x14, x15, x14, lsl #3
     e44: f86159ef     	ldr	x15, [x15, w1, uxtw #3]
     e48: d360fdef     	lsr	x15, x15, #32
     e4c: 92403de0     	and	x0, x15, #0xffff
     e50: f86079cf     	ldr	x15, [x14, x0, lsl #3]
     e54: f100081f     	cmp	x0, #0x2
     e58: 540000c0     	b.eq	0xe70 <___pl_fn_2+0x68>
     e5c: f94009c0     	ldr	x0, [x14, #0x10]
     e60: 370007e0     	tbnz	w0, #0x0, 0xf5c <___pl_fn_2+0x154>
     e64: 14000003     	b	0xe70 <___pl_fn_2+0x68>
     e68: aa1403e0     	mov	x0, x20
     e6c: f940180f     	ldr	x15, [x0, #0x30]
     e70: d280a3a1     	mov	x1, #0x51d              ; =1309
     e74: 9b017de0     	mul	x0, x15, x1
     e78: 9b417de1     	smulh	x1, x15, x1
     e7c: eb80fc3f     	cmp	x1, x0, asr #63
     e80: 54000d01     	b.ne	0x1020 <___pl_fn_2+0x218>
     e84: d286c321     	mov	x1, #0x3619             ; =13849
     e88: ab010000     	adds	x0, x0, x1
     e8c: 9a9f77e1     	cset	x1, vs
     e90: 72001c3f     	tst	w1, #0xff
     e94: 54000b21     	b.ne	0xff8 <___pl_fn_2+0x1f0>
     e98: 34000753     	cbz	w19, 0xf80 <___pl_fn_2+0x178>
     e9c: aa1403eb     	mov	x11, x20
     ea0: f9400162     	ldr	x2, [x11]
     ea4: 2a1303e1     	mov	w1, w19
     ea8: 8b010c41     	add	x1, x2, x1, lsl #3
     eac: f8735842     	ldr	x2, [x2, w19, uxtw #3]
     eb0: d360fc42     	lsr	x2, x2, #32
     eb4: 92403c43     	and	x3, x2, #0xffff
     eb8: f100087f     	cmp	x3, #0x2
     ebc: 54000080     	b.eq	0xecc <___pl_fn_2+0xc4>
     ec0: f9400823     	ldr	x3, [x1, #0x10]
     ec4: 927ff863     	and	x3, x3, #0xfffffffffffffffe
     ec8: f9000823     	str	x3, [x1, #0x10]
     ecc: 934ffc03     	asr	x3, x0, #15
     ed0: d370fc63     	lsr	x3, x3, #48
     ed4: 8b030003     	add	x3, x0, x3
     ed8: 9270bc63     	and	x3, x3, #0xffffffffffff0000
     edc: cb030000     	sub	x0, x0, x3
     ee0: 92403c42     	and	x2, x2, #0xffff
     ee4: f8227820     	str	x0, [x1, x2, lsl #3]
     ee8: 340006f3     	cbz	w19, 0xfc4 <___pl_fn_2+0x1bc>
     eec: aa1403e0     	mov	x0, x20
     ef0: f9400000     	ldr	x0, [x0]
     ef4: 2a1303e1     	mov	w1, w19
     ef8: 8b010c01     	add	x1, x0, x1, lsl #3
     efc: f8735800     	ldr	x0, [x0, w19, uxtw #3]
     f00: d360fc00     	lsr	x0, x0, #32
     f04: 92403c02     	and	x2, x0, #0xffff
     f08: f8627820     	ldr	x0, [x1, x2, lsl #3]
     f0c: f100085f     	cmp	x2, #0x2
     f10: 54000100     	b.eq	0xf30 <___pl_fn_2+0x128>
     f14: f9400821     	ldr	x1, [x1, #0x10]
     f18: 37000561     	tbnz	w1, #0x0, 0xfc4 <___pl_fn_2+0x1bc>
     f1c: 14000005     	b	0xf30 <___pl_fn_2+0x128>
     f20: aa1403e0     	mov	x0, x20
     f24: f9401800     	ldr	x0, [x0, #0x30]
     f28: aa1403e1     	mov	x1, x20
     f2c: 14000002     	b	0xf34 <___pl_fn_2+0x12c>
     f30: aa1403e1     	mov	x1, x20
     f34: aa1403e1     	mov	x1, x20
     f38: b9401021     	ldr	w1, [x1, #0x10]
     f3c: 51000421     	sub	w1, w1, #0x1
     f40: aa1403e2     	mov	x2, x20
     f44: b9001041     	str	w1, [x2, #0x10]
     f48: 910043ff     	add	sp, sp, #0x10
     f4c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f50: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f54: d65f03c0     	ret
     f58: aa0003f4     	mov	x20, x0
     f5c: 52800501     	mov	w1, #0x28               ; =40
     f60: 52800003     	mov	w3, #0x0                ; =0
     f64: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     f68: f9400084     	ldr	x4, [x4]
     f6c: aa1403e0     	mov	x0, x20
     f70: aa1303e2     	mov	x2, x19
     f74: d63f0080     	blr	x4
     f78: 34fff780     	cbz	w0, 0xe68 <___pl_fn_2+0x60>
     f7c: 1400001a     	b	0xfe4 <___pl_fn_2+0x1dc>
     f80: d2800001     	mov	x1, #0x0                ; =0
     f84: 910003e3     	mov	x3, sp
     f88: f80003e1     	stur	x1, [sp]
     f8c: 934ffc01     	asr	x1, x0, #15
     f90: d370fc21     	lsr	x1, x1, #48
     f94: 8b010001     	add	x1, x0, x1
     f98: 9270bc21     	and	x1, x1, #0xffffffffffff0000
     f9c: cb010000     	sub	x0, x0, x1
     fa0: f80083e0     	stur	x0, [sp, #0x8]
     fa4: 52800581     	mov	w1, #0x2c               ; =44
     fa8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     fac: f9400084     	ldr	x4, [x4]
     fb0: aa1403e0     	mov	x0, x20
     fb4: aa1303e2     	mov	x2, x19
     fb8: d63f0080     	blr	x4
     fbc: 34fff960     	cbz	w0, 0xee8 <___pl_fn_2+0xe0>
     fc0: 14000009     	b	0xfe4 <___pl_fn_2+0x1dc>
     fc4: 528005a1     	mov	w1, #0x2d               ; =45
     fc8: 52800003     	mov	w3, #0x0                ; =0
     fcc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     fd0: f9400084     	ldr	x4, [x4]
     fd4: aa1303e2     	mov	x2, x19
     fd8: aa1403e0     	mov	x0, x20
     fdc: d63f0080     	blr	x4
     fe0: 34fffa00     	cbz	w0, 0xf20 <___pl_fn_2+0x118>
     fe4: d2800000     	mov	x0, #0x0                ; =0
     fe8: 910043ff     	add	sp, sp, #0x10
     fec: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ff0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ff4: d65f03c0     	ret
     ff8: 52800541     	mov	w1, #0x2a               ; =42
     ffc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
    1000: f9400042     	ldr	x2, [x2]
    1004: aa1403e0     	mov	x0, x20
    1008: d63f0040     	blr	x2
    100c: d2800000     	mov	x0, #0x0                ; =0
    1010: 910043ff     	add	sp, sp, #0x10
    1014: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1018: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    101c: d65f03c0     	ret
    1020: 52800521     	mov	w1, #0x29               ; =41
    1024: 90000002     	adrp	x2, 0x1000 <___pl_fn_2+0x1f8>
    1028: f9400042     	ldr	x2, [x2]
    102c: aa1403e0     	mov	x0, x20
    1030: d63f0040     	blr	x2
    1034: d2800000     	mov	x0, #0x0                ; =0
    1038: 910043ff     	add	sp, sp, #0x10
    103c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1040: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1044: d65f03c0     	ret
