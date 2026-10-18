
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_76447/queens/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
       c: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
      10: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      14: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      18: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      1c: d10203ff     	sub	sp, sp, #0x80
      20: aa0503fb     	mov	x27, x5
      24: aa0403fc     	mov	x28, x4
      28: f80783e3     	stur	x3, [sp, #0x78]
      2c: b9401003     	ldr	w3, [x0, #0x10]
      30: 11000464     	add	w4, w3, #0x1
      34: b9001004     	str	w4, [x0, #0x10]
      38: aa0003fa     	mov	x26, x0
      3c: eb02003f     	cmp	x1, x2
      40: aa0103f6     	mov	x22, x1
      44: 540029a0     	b.eq	0x578 <___pl_fn_0+0x578>
      48: d2800020     	mov	x0, #0x1                ; =1
      4c: eb000040     	subs	x0, x2, x0
      50: aa0203f7     	mov	x23, x2
      54: 9a9f77e1     	cset	x1, vs
      58: 72001c3f     	tst	w1, #0xff
      5c: 54005861     	b.ne	0xb68 <___pl_fn_0+0xb68>
      60: d2800001     	mov	x1, #0x0                ; =0
      64: ab010013     	adds	x19, x0, x1
      68: 9a9f77e0     	cset	x0, vs
      6c: 72001c1f     	tst	w0, #0xff
      70: 54005601     	b.ne	0xb30 <___pl_fn_0+0xb30>
      74: d2800020     	mov	x0, #0x1                ; =1
      78: d2800001     	mov	x1, #0x0                ; =0
      7c: ab010014     	adds	x20, x0, x1
      80: 9a9f77e0     	cset	x0, vs
      84: 72001c1f     	tst	w0, #0xff
      88: 54005381     	b.ne	0xaf8 <___pl_fn_0+0xaf8>
      8c: b40051b4     	cbz	x20, 0xac0 <___pl_fn_0+0xac0>
      90: d2800015     	mov	x21, #0x0               ; =0
      94: 52800021     	mov	w1, #0x1                ; =1
      98: aa1503e0     	mov	x0, x21
      9c: aa0103f8     	mov	x24, x1
      a0: f100029f     	cmp	x20, #0x0
      a4: 5400008a     	b.ge	0xb4 <___pl_fn_0+0xb4>
      a8: eb1302bf     	cmp	x21, x19
      ac: 9a9fb7e1     	cset	x1, ge
      b0: 14000003     	b	0xbc <___pl_fn_0+0xbc>
      b4: eb1302bf     	cmp	x21, x19
      b8: 9a9fc7e1     	cset	x1, le
      bc: 72001c3f     	tst	w1, #0xff
      c0: 540001a1     	b.ne	0xf4 <___pl_fn_0+0xf4>
      c4: aa1a03e1     	mov	x1, x26
      c8: b9401024     	ldr	w4, [x1, #0x10]
      cc: 51000484     	sub	w4, w4, #0x1
      d0: b9001024     	str	w4, [x1, #0x10]
      d4: 910203ff     	add	sp, sp, #0x80
      d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
      dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
      e0: a8c163f7     	ldp	x23, x24, [sp], #0x10
      e4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
      e8: a8c173fb     	ldp	x27, x28, [sp], #0x10
      ec: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      f0: d65f03c0     	ret
      f4: aa0003f9     	mov	x25, x0
      f8: 52800081     	mov	w1, #0x4                ; =4
      fc: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     100: f94000c6     	ldr	x6, [x6]
     104: aa1a03e0     	mov	x0, x26
     108: f84783e2     	ldur	x2, [sp, #0x78]
     10c: d63f00c0     	blr	x6
     110: 35004c60     	cbnz	w0, 0xa9c <___pl_fn_0+0xa9c>
     114: aa1a03e0     	mov	x0, x26
     118: f9401802     	ldr	x2, [x0, #0x30]
     11c: 34002462     	cbz	w2, 0x5a8 <___pl_fn_0+0x5a8>
     120: aa1a03e0     	mov	x0, x26
     124: f940000a     	ldr	x10, [x0]
     128: 2a0203eb     	mov	w11, w2
     12c: 8b0b0d4a     	add	x10, x10, x11, lsl #3
     130: f940094b     	ldr	x11, [x10, #0x10]
     134: eb0b02bf     	cmp	x21, x11
     138: 54002382     	b.hs	0x5a8 <___pl_fn_0+0x5a8>
     13c: 8b150d4d     	add	x13, x10, x21, lsl #3
     140: 3940a1a6     	ldrb	w6, [x13, #0x28]
     144: 53001ccd     	uxtb	w13, w6
     148: 710009bf     	cmp	w13, #0x2
     14c: 54000081     	b.ne	0x15c <___pl_fn_0+0x15c>
     150: 14000116     	b	0x5a8 <___pl_fn_0+0x5a8>
     154: aa1a03e0     	mov	x0, x26
     158: f9401806     	ldr	x6, [x0, #0x30]
     15c: 72001cdf     	tst	w6, #0xff
     160: 54000061     	b.ne	0x16c <___pl_fn_0+0x16c>
     164: 52800001     	mov	w1, #0x0                ; =0
     168: 1400001e     	b	0x1e0 <___pl_fn_0+0x1e0>
     16c: 528000c1     	mov	w1, #0x6                ; =6
     170: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     174: f9400063     	ldr	x3, [x3]
     178: aa1a03e0     	mov	x0, x26
     17c: aa1c03e2     	mov	x2, x28
     180: d63f0060     	blr	x3
     184: 350048c0     	cbnz	w0, 0xa9c <___pl_fn_0+0xa9c>
     188: aa1a03e0     	mov	x0, x26
     18c: f9401802     	ldr	x2, [x0, #0x30]
     190: ab1602a0     	adds	x0, x21, x22
     194: 9a9f77e1     	cset	x1, vs
     198: 72001c3f     	tst	w1, #0xff
     19c: 54004641     	b.ne	0xa64 <___pl_fn_0+0xa64>
     1a0: 34002162     	cbz	w2, 0x5cc <___pl_fn_0+0x5cc>
     1a4: aa1a03e1     	mov	x1, x26
     1a8: f9400021     	ldr	x1, [x1]
     1ac: 2a0203e3     	mov	w3, w2
     1b0: 8b030c21     	add	x1, x1, x3, lsl #3
     1b4: f9400823     	ldr	x3, [x1, #0x10]
     1b8: eb03001f     	cmp	x0, x3
     1bc: 54002082     	b.hs	0x5cc <___pl_fn_0+0x5cc>
     1c0: 8b000c21     	add	x1, x1, x0, lsl #3
     1c4: 3940a021     	ldrb	w1, [x1, #0x28]
     1c8: 53001c23     	uxtb	w3, w1
     1cc: 7100087f     	cmp	w3, #0x2
     1d0: 54000081     	b.ne	0x1e0 <___pl_fn_0+0x1e0>
     1d4: 140000fe     	b	0x5cc <___pl_fn_0+0x5cc>
     1d8: aa1a03e0     	mov	x0, x26
     1dc: f9401801     	ldr	x1, [x0, #0x30]
     1e0: 72001c3f     	tst	w1, #0xff
     1e4: 54000061     	b.ne	0x1f0 <___pl_fn_0+0x1f0>
     1e8: 52800004     	mov	w4, #0x0                ; =0
     1ec: 14000027     	b	0x288 <___pl_fn_0+0x288>
     1f0: 52800121     	mov	w1, #0x9                ; =9
     1f4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     1f8: f9400063     	ldr	x3, [x3]
     1fc: aa1a03e0     	mov	x0, x26
     200: aa1b03e2     	mov	x2, x27
     204: d63f0060     	blr	x3
     208: 350044a0     	cbnz	w0, 0xa9c <___pl_fn_0+0xa9c>
     20c: aa1a03e0     	mov	x0, x26
     210: f9401802     	ldr	x2, [x0, #0x30]
     214: eb1602a0     	subs	x0, x21, x22
     218: 9a9f77e1     	cset	x1, vs
     21c: 72001c3f     	tst	w1, #0xff
     220: 54004061     	b.ne	0xa2c <___pl_fn_0+0xa2c>
     224: ab170000     	adds	x0, x0, x23
     228: 9a9f77e1     	cset	x1, vs
     22c: 72001c3f     	tst	w1, #0xff
     230: 54003e21     	b.ne	0x9f4 <___pl_fn_0+0x9f4>
     234: d2800021     	mov	x1, #0x1                ; =1
     238: eb010000     	subs	x0, x0, x1
     23c: 9a9f77e1     	cset	x1, vs
     240: 72001c3f     	tst	w1, #0xff
     244: 54003bc1     	b.ne	0x9bc <___pl_fn_0+0x9bc>
     248: 34001d42     	cbz	w2, 0x5f0 <___pl_fn_0+0x5f0>
     24c: aa1a03e5     	mov	x5, x26
     250: f94000a1     	ldr	x1, [x5]
     254: 2a0203e3     	mov	w3, w2
     258: 8b030c21     	add	x1, x1, x3, lsl #3
     25c: f9400823     	ldr	x3, [x1, #0x10]
     260: eb03001f     	cmp	x0, x3
     264: 54001c62     	b.hs	0x5f0 <___pl_fn_0+0x5f0>
     268: 8b000c21     	add	x1, x1, x0, lsl #3
     26c: 3940a024     	ldrb	w4, [x1, #0x28]
     270: 53001c81     	uxtb	w1, w4
     274: 7100083f     	cmp	w1, #0x2
     278: 54000081     	b.ne	0x288 <___pl_fn_0+0x288>
     27c: 140000dd     	b	0x5f0 <___pl_fn_0+0x5f0>
     280: aa1a03e0     	mov	x0, x26
     284: f9401804     	ldr	x4, [x0, #0x30]
     288: 72001c9f     	tst	w4, #0xff
     28c: 54001680     	b.eq	0x55c <___pl_fn_0+0x55c>
     290: 528001c1     	mov	w1, #0xe                ; =14
     294: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     298: f94000e7     	ldr	x7, [x7]
     29c: aa1a03e0     	mov	x0, x26
     2a0: f84783e2     	ldur	x2, [sp, #0x78]
     2a4: d63f00e0     	blr	x7
     2a8: 35003fa0     	cbnz	w0, 0xa9c <___pl_fn_0+0xa9c>
     2ac: aa1a03e0     	mov	x0, x26
     2b0: f9401802     	ldr	x2, [x0, #0x30]
     2b4: 34001b02     	cbz	w2, 0x614 <___pl_fn_0+0x614>
     2b8: aa1a03e0     	mov	x0, x26
     2bc: f940000b     	ldr	x11, [x0]
     2c0: 2a0203ec     	mov	w12, w2
     2c4: 8b0c0d6b     	add	x11, x11, x12, lsl #3
     2c8: f940096c     	ldr	x12, [x11, #0x10]
     2cc: eb0c02bf     	cmp	x21, x12
     2d0: 54001a22     	b.hs	0x614 <___pl_fn_0+0x614>
     2d4: d2800000     	mov	x0, #0x0                ; =0
     2d8: 8b150d61     	add	x1, x11, x21, lsl #3
     2dc: f9001420     	str	x0, [x1, #0x28]
     2e0: 52800201     	mov	w1, #0x10               ; =16
     2e4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     2e8: f9400063     	ldr	x3, [x3]
     2ec: aa1a03e0     	mov	x0, x26
     2f0: aa1c03e2     	mov	x2, x28
     2f4: d63f0060     	blr	x3
     2f8: 35003d20     	cbnz	w0, 0xa9c <___pl_fn_0+0xa9c>
     2fc: aa1a03e0     	mov	x0, x26
     300: f9401802     	ldr	x2, [x0, #0x30]
     304: ab1602a0     	adds	x0, x21, x22
     308: 9a9f77e1     	cset	x1, vs
     30c: 72001c3f     	tst	w1, #0xff
     310: 540033a1     	b.ne	0x984 <___pl_fn_0+0x984>
     314: 34001962     	cbz	w2, 0x640 <___pl_fn_0+0x640>
     318: aa1a03ef     	mov	x15, x26
     31c: f94001e1     	ldr	x1, [x15]
     320: 2a0203e3     	mov	w3, w2
     324: 8b030c21     	add	x1, x1, x3, lsl #3
     328: f9400823     	ldr	x3, [x1, #0x10]
     32c: eb03001f     	cmp	x0, x3
     330: 54001882     	b.hs	0x640 <___pl_fn_0+0x640>
     334: d2800002     	mov	x2, #0x0                ; =0
     338: 8b000c20     	add	x0, x1, x0, lsl #3
     33c: f9001402     	str	x2, [x0, #0x28]
     340: 52800261     	mov	w1, #0x13               ; =19
     344: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     348: f9400063     	ldr	x3, [x3]
     34c: aa1a03e0     	mov	x0, x26
     350: aa1b03e2     	mov	x2, x27
     354: d63f0060     	blr	x3
     358: 35003a20     	cbnz	w0, 0xa9c <___pl_fn_0+0xa9c>
     35c: aa1a03e0     	mov	x0, x26
     360: f9401802     	ldr	x2, [x0, #0x30]
     364: eb1602a0     	subs	x0, x21, x22
     368: 9a9f77e1     	cset	x1, vs
     36c: 72001c3f     	tst	w1, #0xff
     370: 54002ee1     	b.ne	0x94c <___pl_fn_0+0x94c>
     374: ab170000     	adds	x0, x0, x23
     378: 9a9f77e1     	cset	x1, vs
     37c: 72001c3f     	tst	w1, #0xff
     380: 54002ca1     	b.ne	0x914 <___pl_fn_0+0x914>
     384: d2800021     	mov	x1, #0x1                ; =1
     388: eb010000     	subs	x0, x0, x1
     38c: 9a9f77e1     	cset	x1, vs
     390: 72001c3f     	tst	w1, #0xff
     394: 54002a41     	b.ne	0x8dc <___pl_fn_0+0x8dc>
     398: 340016a2     	cbz	w2, 0x66c <___pl_fn_0+0x66c>
     39c: aa1a03e1     	mov	x1, x26
     3a0: f9400021     	ldr	x1, [x1]
     3a4: 2a0203e3     	mov	w3, w2
     3a8: 8b030c21     	add	x1, x1, x3, lsl #3
     3ac: f9400823     	ldr	x3, [x1, #0x10]
     3b0: eb03001f     	cmp	x0, x3
     3b4: 540015c2     	b.hs	0x66c <___pl_fn_0+0x66c>
     3b8: d2800002     	mov	x2, #0x0                ; =0
     3bc: 8b000c20     	add	x0, x1, x0, lsl #3
     3c0: f9001402     	str	x2, [x0, #0x28]
     3c4: d2800020     	mov	x0, #0x1                ; =1
     3c8: ab0002c1     	adds	x1, x22, x0
     3cc: 9a9f77e0     	cset	x0, vs
     3d0: 72001c1f     	tst	w0, #0xff
     3d4: 54002681     	b.ne	0x8a4 <___pl_fn_0+0x8a4>
     3d8: aa1a03e0     	mov	x0, x26
     3dc: b9401000     	ldr	w0, [x0, #0x10]
     3e0: aa1a03e2     	mov	x2, x26
     3e4: b9401442     	ldr	w2, [x2, #0x14]
     3e8: 6b02001f     	cmp	w0, w2
     3ec: 54002402     	b.hs	0x86c <___pl_fn_0+0x86c>
     3f0: aa1a03e0     	mov	x0, x26
     3f4: aa1703e2     	mov	x2, x23
     3f8: f84783e3     	ldur	x3, [sp, #0x78]
     3fc: aa1c03e4     	mov	x4, x28
     400: aa1b03e5     	mov	x5, x27
     404: 94000000     	bl	0x404 <___pl_fn_0+0x404>
     408: aa1a03e1     	mov	x1, x26
     40c: b9402c21     	ldr	w1, [x1, #0x2c]
     410: 35003461     	cbnz	w1, 0xa9c <___pl_fn_0+0xa9c>
     414: ab000339     	adds	x25, x25, x0
     418: 9a9f77e1     	cset	x1, vs
     41c: 72001c3f     	tst	w1, #0xff
     420: 540020a1     	b.ne	0x834 <___pl_fn_0+0x834>
     424: 52800361     	mov	w1, #0x1b               ; =27
     428: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     42c: f9400063     	ldr	x3, [x3]
     430: aa1a03e0     	mov	x0, x26
     434: f84783e2     	ldur	x2, [sp, #0x78]
     438: d63f0060     	blr	x3
     43c: 35003300     	cbnz	w0, 0xa9c <___pl_fn_0+0xa9c>
     440: aa1a03e0     	mov	x0, x26
     444: f9401802     	ldr	x2, [x0, #0x30]
     448: 34001282     	cbz	w2, 0x698 <___pl_fn_0+0x698>
     44c: aa1a03e0     	mov	x0, x26
     450: f9400006     	ldr	x6, [x0]
     454: 2a0203e7     	mov	w7, w2
     458: 8b070cc6     	add	x6, x6, x7, lsl #3
     45c: f94008c7     	ldr	x7, [x6, #0x10]
     460: eb0702bf     	cmp	x21, x7
     464: 540011a2     	b.hs	0x698 <___pl_fn_0+0x698>
     468: d280002e     	mov	x14, #0x1               ; =1
     46c: 8b150ccf     	add	x15, x6, x21, lsl #3
     470: f90015ee     	str	x14, [x15, #0x28]
     474: 528003a1     	mov	w1, #0x1d               ; =29
     478: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     47c: f9400063     	ldr	x3, [x3]
     480: aa1a03e0     	mov	x0, x26
     484: aa1c03e2     	mov	x2, x28
     488: d63f0060     	blr	x3
     48c: 35003080     	cbnz	w0, 0xa9c <___pl_fn_0+0xa9c>
     490: aa1a03e0     	mov	x0, x26
     494: f9401802     	ldr	x2, [x0, #0x30]
     498: ab1602a0     	adds	x0, x21, x22
     49c: 9a9f77e1     	cset	x1, vs
     4a0: 72001c3f     	tst	w1, #0xff
     4a4: 54001ac1     	b.ne	0x7fc <___pl_fn_0+0x7fc>
     4a8: 340010e2     	cbz	w2, 0x6c4 <___pl_fn_0+0x6c4>
     4ac: aa1a03e1     	mov	x1, x26
     4b0: f9400021     	ldr	x1, [x1]
     4b4: 2a0203e3     	mov	w3, w2
     4b8: 8b030c21     	add	x1, x1, x3, lsl #3
     4bc: f9400823     	ldr	x3, [x1, #0x10]
     4c0: eb03001f     	cmp	x0, x3
     4c4: 54001002     	b.hs	0x6c4 <___pl_fn_0+0x6c4>
     4c8: d2800022     	mov	x2, #0x1                ; =1
     4cc: 8b000c20     	add	x0, x1, x0, lsl #3
     4d0: f9001402     	str	x2, [x0, #0x28]
     4d4: 52800401     	mov	w1, #0x20               ; =32
     4d8: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     4dc: f9400063     	ldr	x3, [x3]
     4e0: aa1a03e0     	mov	x0, x26
     4e4: aa1b03e2     	mov	x2, x27
     4e8: d63f0060     	blr	x3
     4ec: 35002d80     	cbnz	w0, 0xa9c <___pl_fn_0+0xa9c>
     4f0: aa1a03e0     	mov	x0, x26
     4f4: f9401802     	ldr	x2, [x0, #0x30]
     4f8: eb1602a0     	subs	x0, x21, x22
     4fc: 9a9f77e1     	cset	x1, vs
     500: 72001c3f     	tst	w1, #0xff
     504: 54001601     	b.ne	0x7c4 <___pl_fn_0+0x7c4>
     508: ab170000     	adds	x0, x0, x23
     50c: 9a9f77e1     	cset	x1, vs
     510: 72001c3f     	tst	w1, #0xff
     514: 540013c1     	b.ne	0x78c <___pl_fn_0+0x78c>
     518: d2800021     	mov	x1, #0x1                ; =1
     51c: eb010000     	subs	x0, x0, x1
     520: 9a9f77e1     	cset	x1, vs
     524: 72001c3f     	tst	w1, #0xff
     528: 54001161     	b.ne	0x754 <___pl_fn_0+0x754>
     52c: 34000e22     	cbz	w2, 0x6f0 <___pl_fn_0+0x6f0>
     530: aa1a03e1     	mov	x1, x26
     534: f9400021     	ldr	x1, [x1]
     538: 2a0203e3     	mov	w3, w2
     53c: 8b030c21     	add	x1, x1, x3, lsl #3
     540: f9400823     	ldr	x3, [x1, #0x10]
     544: eb03001f     	cmp	x0, x3
     548: 54000d42     	b.hs	0x6f0 <___pl_fn_0+0x6f0>
     54c: d2800022     	mov	x2, #0x1                ; =1
     550: 8b000c20     	add	x0, x1, x0, lsl #3
     554: f9001402     	str	x2, [x0, #0x28]
     558: 52800038     	mov	w24, #0x1               ; =1
     55c: ab1402b5     	adds	x21, x21, x20
     560: 9a9f77e0     	cset	x0, vs
     564: 72001c1f     	tst	w0, #0xff
     568: 54000da1     	b.ne	0x71c <___pl_fn_0+0x71c>
     56c: 52800021     	mov	w1, #0x1                ; =1
     570: aa1903e0     	mov	x0, x25
     574: 17fffecb     	b	0xa0 <___pl_fn_0+0xa0>
     578: aa1a03e0     	mov	x0, x26
     57c: b9001003     	str	w3, [x0, #0x10]
     580: d2800020     	mov	x0, #0x1                ; =1
     584: 910203ff     	add	sp, sp, #0x80
     588: a8c153f3     	ldp	x19, x20, [sp], #0x10
     58c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     590: a8c163f7     	ldp	x23, x24, [sp], #0x10
     594: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     598: a8c173fb     	ldp	x27, x28, [sp], #0x10
     59c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     5a0: d65f03c0     	ret
     5a4: 1400013e     	b	0xa9c <___pl_fn_0+0xa9c>
     5a8: 910003e3     	mov	x3, sp
     5ac: f80003f5     	stur	x21, [sp]
     5b0: 528000a1     	mov	w1, #0x5                ; =5
     5b4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5b8: f9400084     	ldr	x4, [x4]
     5bc: aa1a03e0     	mov	x0, x26
     5c0: d63f0080     	blr	x4
     5c4: 34ffdc80     	cbz	w0, 0x154 <___pl_fn_0+0x154>
     5c8: 14000135     	b	0xa9c <___pl_fn_0+0xa9c>
     5cc: 910023e3     	add	x3, sp, #0x8
     5d0: f80083e0     	stur	x0, [sp, #0x8]
     5d4: 52800101     	mov	w1, #0x8                ; =8
     5d8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5dc: f9400084     	ldr	x4, [x4]
     5e0: aa1a03e0     	mov	x0, x26
     5e4: d63f0080     	blr	x4
     5e8: 34ffdf80     	cbz	w0, 0x1d8 <___pl_fn_0+0x1d8>
     5ec: 1400012c     	b	0xa9c <___pl_fn_0+0xa9c>
     5f0: 910043e3     	add	x3, sp, #0x10
     5f4: f80103e0     	stur	x0, [sp, #0x10]
     5f8: 528001a1     	mov	w1, #0xd                ; =13
     5fc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     600: f9400084     	ldr	x4, [x4]
     604: aa1a03e0     	mov	x0, x26
     608: d63f0080     	blr	x4
     60c: 34ffe3a0     	cbz	w0, 0x280 <___pl_fn_0+0x280>
     610: 14000123     	b	0xa9c <___pl_fn_0+0xa9c>
     614: 910063e3     	add	x3, sp, #0x18
     618: f80183f5     	stur	x21, [sp, #0x18]
     61c: d280000f     	mov	x15, #0x0               ; =0
     620: f80203ef     	stur	x15, [sp, #0x20]
     624: 528001e1     	mov	w1, #0xf                ; =15
     628: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     62c: f9400084     	ldr	x4, [x4]
     630: aa1a03e0     	mov	x0, x26
     634: d63f0080     	blr	x4
     638: 34ffe540     	cbz	w0, 0x2e0 <___pl_fn_0+0x2e0>
     63c: 14000118     	b	0xa9c <___pl_fn_0+0xa9c>
     640: 9100a3e3     	add	x3, sp, #0x28
     644: f80283e0     	stur	x0, [sp, #0x28]
     648: d2800000     	mov	x0, #0x0                ; =0
     64c: f80303e0     	stur	x0, [sp, #0x30]
     650: 52800241     	mov	w1, #0x12               ; =18
     654: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     658: f9400084     	ldr	x4, [x4]
     65c: aa1a03e0     	mov	x0, x26
     660: d63f0080     	blr	x4
     664: 34ffe6e0     	cbz	w0, 0x340 <___pl_fn_0+0x340>
     668: 1400010d     	b	0xa9c <___pl_fn_0+0xa9c>
     66c: 9100e3e3     	add	x3, sp, #0x38
     670: f80383e0     	stur	x0, [sp, #0x38]
     674: d2800000     	mov	x0, #0x0                ; =0
     678: f80403e0     	stur	x0, [sp, #0x40]
     67c: 528002e1     	mov	w1, #0x17               ; =23
     680: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     684: f9400084     	ldr	x4, [x4]
     688: aa1a03e0     	mov	x0, x26
     68c: d63f0080     	blr	x4
     690: 34ffe9a0     	cbz	w0, 0x3c4 <___pl_fn_0+0x3c4>
     694: 14000102     	b	0xa9c <___pl_fn_0+0xa9c>
     698: 910123e3     	add	x3, sp, #0x48
     69c: f80483f5     	stur	x21, [sp, #0x48]
     6a0: d280002a     	mov	x10, #0x1               ; =1
     6a4: f80503ea     	stur	x10, [sp, #0x50]
     6a8: 52800381     	mov	w1, #0x1c               ; =28
     6ac: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     6b0: f940016b     	ldr	x11, [x11]
     6b4: aa1a03e0     	mov	x0, x26
     6b8: d63f0160     	blr	x11
     6bc: 34ffedc0     	cbz	w0, 0x474 <___pl_fn_0+0x474>
     6c0: 140000f7     	b	0xa9c <___pl_fn_0+0xa9c>
     6c4: 910163e3     	add	x3, sp, #0x58
     6c8: f80583e0     	stur	x0, [sp, #0x58]
     6cc: d2800020     	mov	x0, #0x1                ; =1
     6d0: f80603e0     	stur	x0, [sp, #0x60]
     6d4: 528003e1     	mov	w1, #0x1f               ; =31
     6d8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     6dc: f9400084     	ldr	x4, [x4]
     6e0: aa1a03e0     	mov	x0, x26
     6e4: d63f0080     	blr	x4
     6e8: 34ffef60     	cbz	w0, 0x4d4 <___pl_fn_0+0x4d4>
     6ec: 140000ec     	b	0xa9c <___pl_fn_0+0xa9c>
     6f0: 9101a3e3     	add	x3, sp, #0x68
     6f4: f80683e0     	stur	x0, [sp, #0x68]
     6f8: d2800020     	mov	x0, #0x1                ; =1
     6fc: f80703e0     	stur	x0, [sp, #0x70]
     700: 52800481     	mov	w1, #0x24               ; =36
     704: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     708: f9400084     	ldr	x4, [x4]
     70c: aa1a03e0     	mov	x0, x26
     710: d63f0080     	blr	x4
     714: 34fff220     	cbz	w0, 0x558 <___pl_fn_0+0x558>
     718: 140000e1     	b	0xa9c <___pl_fn_0+0xa9c>
     71c: 528004a1     	mov	w1, #0x25               ; =37
     720: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     724: f9400042     	ldr	x2, [x2]
     728: aa1a03e0     	mov	x0, x26
     72c: d63f0040     	blr	x2
     730: d2800000     	mov	x0, #0x0                ; =0
     734: 910203ff     	add	sp, sp, #0x80
     738: a8c153f3     	ldp	x19, x20, [sp], #0x10
     73c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     740: a8c163f7     	ldp	x23, x24, [sp], #0x10
     744: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     748: a8c173fb     	ldp	x27, x28, [sp], #0x10
     74c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     750: d65f03c0     	ret
     754: 52800461     	mov	w1, #0x23               ; =35
     758: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     75c: f9400042     	ldr	x2, [x2]
     760: aa1a03e0     	mov	x0, x26
     764: d63f0040     	blr	x2
     768: d2800000     	mov	x0, #0x0                ; =0
     76c: 910203ff     	add	sp, sp, #0x80
     770: a8c153f3     	ldp	x19, x20, [sp], #0x10
     774: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     778: a8c163f7     	ldp	x23, x24, [sp], #0x10
     77c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     780: a8c173fb     	ldp	x27, x28, [sp], #0x10
     784: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     788: d65f03c0     	ret
     78c: 52800441     	mov	w1, #0x22               ; =34
     790: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     794: f9400042     	ldr	x2, [x2]
     798: aa1a03e0     	mov	x0, x26
     79c: d63f0040     	blr	x2
     7a0: d2800000     	mov	x0, #0x0                ; =0
     7a4: 910203ff     	add	sp, sp, #0x80
     7a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7b0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7b4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7b8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     7bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7c0: d65f03c0     	ret
     7c4: 52800421     	mov	w1, #0x21               ; =33
     7c8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7cc: f9400042     	ldr	x2, [x2]
     7d0: aa1a03e0     	mov	x0, x26
     7d4: d63f0040     	blr	x2
     7d8: d2800000     	mov	x0, #0x0                ; =0
     7dc: 910203ff     	add	sp, sp, #0x80
     7e0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7e4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7e8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7ec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7f0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     7f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7f8: d65f03c0     	ret
     7fc: 528003c1     	mov	w1, #0x1e               ; =30
     800: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     804: f9400042     	ldr	x2, [x2]
     808: aa1a03e0     	mov	x0, x26
     80c: d63f0040     	blr	x2
     810: d2800000     	mov	x0, #0x0                ; =0
     814: 910203ff     	add	sp, sp, #0x80
     818: a8c153f3     	ldp	x19, x20, [sp], #0x10
     81c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     820: a8c163f7     	ldp	x23, x24, [sp], #0x10
     824: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     828: a8c173fb     	ldp	x27, x28, [sp], #0x10
     82c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     830: d65f03c0     	ret
     834: 52800341     	mov	w1, #0x1a               ; =26
     838: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     83c: f9400042     	ldr	x2, [x2]
     840: aa1a03e0     	mov	x0, x26
     844: d63f0040     	blr	x2
     848: d2800000     	mov	x0, #0x0                ; =0
     84c: 910203ff     	add	sp, sp, #0x80
     850: a8c153f3     	ldp	x19, x20, [sp], #0x10
     854: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     858: a8c163f7     	ldp	x23, x24, [sp], #0x10
     85c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     860: a8c173fb     	ldp	x27, x28, [sp], #0x10
     864: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     868: d65f03c0     	ret
     86c: 52800321     	mov	w1, #0x19               ; =25
     870: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     874: f9400042     	ldr	x2, [x2]
     878: aa1a03e0     	mov	x0, x26
     87c: d63f0040     	blr	x2
     880: d2800000     	mov	x0, #0x0                ; =0
     884: 910203ff     	add	sp, sp, #0x80
     888: a8c153f3     	ldp	x19, x20, [sp], #0x10
     88c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     890: a8c163f7     	ldp	x23, x24, [sp], #0x10
     894: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     898: a8c173fb     	ldp	x27, x28, [sp], #0x10
     89c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8a0: d65f03c0     	ret
     8a4: 52800301     	mov	w1, #0x18               ; =24
     8a8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     8ac: f9400042     	ldr	x2, [x2]
     8b0: aa1a03e0     	mov	x0, x26
     8b4: d63f0040     	blr	x2
     8b8: d2800000     	mov	x0, #0x0                ; =0
     8bc: 910203ff     	add	sp, sp, #0x80
     8c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8c4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8c8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8cc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8d0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     8d4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8d8: d65f03c0     	ret
     8dc: 528002c1     	mov	w1, #0x16               ; =22
     8e0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     8e4: f9400042     	ldr	x2, [x2]
     8e8: aa1a03e0     	mov	x0, x26
     8ec: d63f0040     	blr	x2
     8f0: d2800000     	mov	x0, #0x0                ; =0
     8f4: 910203ff     	add	sp, sp, #0x80
     8f8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8fc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     900: a8c163f7     	ldp	x23, x24, [sp], #0x10
     904: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     908: a8c173fb     	ldp	x27, x28, [sp], #0x10
     90c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     910: d65f03c0     	ret
     914: 528002a1     	mov	w1, #0x15               ; =21
     918: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     91c: f9400042     	ldr	x2, [x2]
     920: aa1a03e0     	mov	x0, x26
     924: d63f0040     	blr	x2
     928: d2800000     	mov	x0, #0x0                ; =0
     92c: 910203ff     	add	sp, sp, #0x80
     930: a8c153f3     	ldp	x19, x20, [sp], #0x10
     934: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     938: a8c163f7     	ldp	x23, x24, [sp], #0x10
     93c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     940: a8c173fb     	ldp	x27, x28, [sp], #0x10
     944: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     948: d65f03c0     	ret
     94c: 52800281     	mov	w1, #0x14               ; =20
     950: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     954: f9400063     	ldr	x3, [x3]
     958: aa1a03e0     	mov	x0, x26
     95c: d63f0060     	blr	x3
     960: d2800000     	mov	x0, #0x0                ; =0
     964: 910203ff     	add	sp, sp, #0x80
     968: a8c153f3     	ldp	x19, x20, [sp], #0x10
     96c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     970: a8c163f7     	ldp	x23, x24, [sp], #0x10
     974: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     978: a8c173fb     	ldp	x27, x28, [sp], #0x10
     97c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     980: d65f03c0     	ret
     984: 52800221     	mov	w1, #0x11               ; =17
     988: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     98c: f9400084     	ldr	x4, [x4]
     990: aa1a03e0     	mov	x0, x26
     994: d63f0080     	blr	x4
     998: d2800000     	mov	x0, #0x0                ; =0
     99c: 910203ff     	add	sp, sp, #0x80
     9a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9a8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9ac: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9b0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9b8: d65f03c0     	ret
     9bc: 52800181     	mov	w1, #0xc                ; =12
     9c0: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     9c4: f94000a5     	ldr	x5, [x5]
     9c8: aa1a03e0     	mov	x0, x26
     9cc: d63f00a0     	blr	x5
     9d0: d2800000     	mov	x0, #0x0                ; =0
     9d4: 910203ff     	add	sp, sp, #0x80
     9d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9e0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9e4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9e8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9ec: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9f0: d65f03c0     	ret
     9f4: 52800161     	mov	w1, #0xb                ; =11
     9f8: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     9fc: f94000c6     	ldr	x6, [x6]
     a00: aa1a03e0     	mov	x0, x26
     a04: d63f00c0     	blr	x6
     a08: d2800000     	mov	x0, #0x0                ; =0
     a0c: 910203ff     	add	sp, sp, #0x80
     a10: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a14: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a18: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a1c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a20: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a24: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a28: d65f03c0     	ret
     a2c: 52800141     	mov	w1, #0xa                ; =10
     a30: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     a34: f94000e7     	ldr	x7, [x7]
     a38: aa1a03e0     	mov	x0, x26
     a3c: d63f00e0     	blr	x7
     a40: d2800000     	mov	x0, #0x0                ; =0
     a44: 910203ff     	add	sp, sp, #0x80
     a48: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a4c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a50: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a54: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a58: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a5c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a60: d65f03c0     	ret
     a64: 528000e1     	mov	w1, #0x7                ; =7
     a68: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     a6c: f9400108     	ldr	x8, [x8]
     a70: aa1a03e0     	mov	x0, x26
     a74: d63f0100     	blr	x8
     a78: d2800000     	mov	x0, #0x0                ; =0
     a7c: 910203ff     	add	sp, sp, #0x80
     a80: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a84: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a88: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a8c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a90: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a94: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a98: d65f03c0     	ret
     a9c: d2800000     	mov	x0, #0x0                ; =0
     aa0: 910203ff     	add	sp, sp, #0x80
     aa4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     aa8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     aac: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ab0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     ab4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ab8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     abc: d65f03c0     	ret
     ac0: 52800061     	mov	w1, #0x3                ; =3
     ac4: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     ac8: f940014a     	ldr	x10, [x10]
     acc: aa1a03e0     	mov	x0, x26
     ad0: d63f0140     	blr	x10
     ad4: d2800000     	mov	x0, #0x0                ; =0
     ad8: 910203ff     	add	sp, sp, #0x80
     adc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ae0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ae4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ae8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     aec: a8c173fb     	ldp	x27, x28, [sp], #0x10
     af0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     af4: d65f03c0     	ret
     af8: 52800041     	mov	w1, #0x2                ; =2
     afc: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     b00: f940016b     	ldr	x11, [x11]
     b04: aa1a03e0     	mov	x0, x26
     b08: d63f0160     	blr	x11
     b0c: d2800000     	mov	x0, #0x0                ; =0
     b10: 910203ff     	add	sp, sp, #0x80
     b14: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b18: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b1c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b20: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b24: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b28: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b2c: d65f03c0     	ret
     b30: 52800021     	mov	w1, #0x1                ; =1
     b34: 9000000c     	adrp	x12, 0x0 <___pl_fn_0>
     b38: f940018c     	ldr	x12, [x12]
     b3c: aa1a03e0     	mov	x0, x26
     b40: d63f0180     	blr	x12
     b44: d2800000     	mov	x0, #0x0                ; =0
     b48: 910203ff     	add	sp, sp, #0x80
     b4c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b50: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b54: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b58: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b5c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b60: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b64: d65f03c0     	ret
     b68: 52800001     	mov	w1, #0x0                ; =0
     b6c: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     b70: f94001ad     	ldr	x13, [x13]
     b74: aa1a03e0     	mov	x0, x26
     b78: d63f01a0     	blr	x13
     b7c: d2800000     	mov	x0, #0x0                ; =0
     b80: 910203ff     	add	sp, sp, #0x80
     b84: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b88: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b8c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b90: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b94: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b98: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b9c: d65f03c0     	ret

0000000000000ba0 <___pl_fn_1>:
     ba0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     ba4: 910003fd     	mov	x29, sp
     ba8: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
     bac: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     bb0: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     bb4: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     bb8: d10143ff     	sub	sp, sp, #0x50
     bbc: b9401001     	ldr	w1, [x0, #0x10]
     bc0: 11000421     	add	w1, w1, #0x1
     bc4: b9001001     	str	w1, [x0, #0x10]
     bc8: aa0003f6     	mov	x22, x0
     bcc: d2800200     	mov	x0, #0x10               ; =16
     bd0: 910003e3     	mov	x3, sp
     bd4: f80003e0     	stur	x0, [sp]
     bd8: 528004c1     	mov	w1, #0x26               ; =38
     bdc: 52802042     	mov	w2, #0x102              ; =258
     be0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     be4: f9400084     	ldr	x4, [x4]
     be8: aa1603e0     	mov	x0, x22
     bec: d63f0080     	blr	x4
     bf0: 35002600     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     bf4: aa1603e0     	mov	x0, x22
     bf8: f9401818     	ldr	x24, [x0, #0x30]
     bfc: 528004e1     	mov	w1, #0x27               ; =39
     c00: 52800082     	mov	w2, #0x4                ; =4
     c04: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     c08: f9400063     	ldr	x3, [x3]
     c0c: d63f0060     	blr	x3
     c10: 35002500     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     c14: aa1603e0     	mov	x0, x22
     c18: f940181a     	ldr	x26, [x0, #0x30]
     c1c: 52800501     	mov	w1, #0x28               ; =40
     c20: 2a1803e3     	mov	w3, w24
     c24: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c28: f9400084     	ldr	x4, [x4]
     c2c: aa1a03e2     	mov	x2, x26
     c30: d63f0080     	blr	x4
     c34: aa1a03f7     	mov	x23, x26
     c38: 350023c0     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     c3c: d2800200     	mov	x0, #0x10               ; =16
     c40: 910023e3     	add	x3, sp, #0x8
     c44: f80083e0     	stur	x0, [sp, #0x8]
     c48: 52800521     	mov	w1, #0x29               ; =41
     c4c: 52802042     	mov	w2, #0x102              ; =258
     c50: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c54: f9400084     	ldr	x4, [x4]
     c58: aa1603e0     	mov	x0, x22
     c5c: d63f0080     	blr	x4
     c60: 35002280     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     c64: aa1603e0     	mov	x0, x22
     c68: f9401813     	ldr	x19, [x0, #0x30]
     c6c: 52800541     	mov	w1, #0x2a               ; =42
     c70: 52800082     	mov	w2, #0x4                ; =4
     c74: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     c78: f9400063     	ldr	x3, [x3]
     c7c: d63f0060     	blr	x3
     c80: 35002180     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     c84: aa1603e0     	mov	x0, x22
     c88: f9401814     	ldr	x20, [x0, #0x30]
     c8c: 52800561     	mov	w1, #0x2b               ; =43
     c90: 2a1303e3     	mov	w3, w19
     c94: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c98: f9400084     	ldr	x4, [x4]
     c9c: aa1403e2     	mov	x2, x20
     ca0: d63f0080     	blr	x4
     ca4: aa1403f8     	mov	x24, x20
     ca8: 35002040     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     cac: d2800200     	mov	x0, #0x10               ; =16
     cb0: 910043e3     	add	x3, sp, #0x10
     cb4: f80103e0     	stur	x0, [sp, #0x10]
     cb8: 52800581     	mov	w1, #0x2c               ; =44
     cbc: 52802042     	mov	w2, #0x102              ; =258
     cc0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     cc4: f9400084     	ldr	x4, [x4]
     cc8: aa1603e0     	mov	x0, x22
     ccc: d63f0080     	blr	x4
     cd0: 35001f00     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     cd4: aa1603e0     	mov	x0, x22
     cd8: f9401813     	ldr	x19, [x0, #0x30]
     cdc: 528005a1     	mov	w1, #0x2d               ; =45
     ce0: 52800082     	mov	w2, #0x4                ; =4
     ce4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     ce8: f9400063     	ldr	x3, [x3]
     cec: d63f0060     	blr	x3
     cf0: 35001e00     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     cf4: aa1603e0     	mov	x0, x22
     cf8: f9401814     	ldr	x20, [x0, #0x30]
     cfc: 528005c1     	mov	w1, #0x2e               ; =46
     d00: 2a1303e3     	mov	w3, w19
     d04: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     d08: f9400084     	ldr	x4, [x4]
     d0c: aa1403e2     	mov	x2, x20
     d10: d63f0080     	blr	x4
     d14: aa1403f9     	mov	x25, x20
     d18: 35001cc0     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     d1c: 528005e1     	mov	w1, #0x2f               ; =47
     d20: 52800002     	mov	w2, #0x0                ; =0
     d24: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     d28: f9400063     	ldr	x3, [x3]
     d2c: aa1603e0     	mov	x0, x22
     d30: d63f0060     	blr	x3
     d34: 35001be0     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     d38: aa1603e0     	mov	x0, x22
     d3c: f9401802     	ldr	x2, [x0, #0x30]
     d40: aa0203fa     	mov	x26, x2
     d44: d28001e0     	mov	x0, #0xf                ; =15
     d48: d2800001     	mov	x1, #0x0                ; =0
     d4c: ab010013     	adds	x19, x0, x1
     d50: 9a9f77e0     	cset	x0, vs
     d54: 72001c1f     	tst	w0, #0xff
     d58: 54001941     	b.ne	0x1080 <___pl_fn_1+0x4e0>
     d5c: d2800020     	mov	x0, #0x1                ; =1
     d60: d2800001     	mov	x1, #0x0                ; =0
     d64: ab010014     	adds	x20, x0, x1
     d68: 9a9f77e0     	cset	x0, vs
     d6c: 72001c1f     	tst	w0, #0xff
     d70: 54001701     	b.ne	0x1050 <___pl_fn_1+0x4b0>
     d74: b4001574     	cbz	x20, 0x1020 <___pl_fn_1+0x480>
     d78: d2800015     	mov	x21, #0x0               ; =0
     d7c: 52800020     	mov	w0, #0x1                ; =1
     d80: f100029f     	cmp	x20, #0x0
     d84: 5400008a     	b.ge	0xd94 <___pl_fn_1+0x1f4>
     d88: eb1302bf     	cmp	x21, x19
     d8c: 9a9fb7e0     	cset	x0, ge
     d90: 14000003     	b	0xd9c <___pl_fn_1+0x1fc>
     d94: eb1302bf     	cmp	x21, x19
     d98: 9a9fc7e0     	cset	x0, le
     d9c: 72001c1f     	tst	w0, #0xff
     da0: 54000481     	b.ne	0xe30 <___pl_fn_1+0x290>
     da4: aa1603e0     	mov	x0, x22
     da8: b9401000     	ldr	w0, [x0, #0x10]
     dac: aa1603ec     	mov	x12, x22
     db0: b9401581     	ldr	w1, [x12, #0x14]
     db4: 6b01001f     	cmp	w0, w1
     db8: 54000c02     	b.hs	0xf38 <___pl_fn_1+0x398>
     dbc: d2800001     	mov	x1, #0x0                ; =0
     dc0: aa1a03e2     	mov	x2, x26
     dc4: aa1703e3     	mov	x3, x23
     dc8: aa1803e4     	mov	x4, x24
     dcc: aa1903e5     	mov	x5, x25
     dd0: aa1603e0     	mov	x0, x22
     dd4: 94000000     	bl	0xdd4 <___pl_fn_1+0x234>
     dd8: aa0003e2     	mov	x2, x0
     ddc: aa1603e0     	mov	x0, x22
     de0: b9402c00     	ldr	w0, [x0, #0x2c]
     de4: 35001660     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     de8: 52800681     	mov	w1, #0x34               ; =52
     dec: 52802003     	mov	w3, #0x100              ; =256
     df0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     df4: f9400084     	ldr	x4, [x4]
     df8: aa1603e0     	mov	x0, x22
     dfc: d63f0080     	blr	x4
     e00: 35001580     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     e04: aa1603e0     	mov	x0, x22
     e08: b9401001     	ldr	w1, [x0, #0x10]
     e0c: 51000421     	sub	w1, w1, #0x1
     e10: b9001001     	str	w1, [x0, #0x10]
     e14: 910143ff     	add	sp, sp, #0x50
     e18: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e1c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e20: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e24: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e28: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e2c: d65f03c0     	ret
     e30: 528006a1     	mov	w1, #0x35               ; =53
     e34: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     e38: f9400084     	ldr	x4, [x4]
     e3c: aa1603e0     	mov	x0, x22
     e40: aa1703e2     	mov	x2, x23
     e44: d63f0080     	blr	x4
     e48: 35001340     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     e4c: aa1603e0     	mov	x0, x22
     e50: f9401802     	ldr	x2, [x0, #0x30]
     e54: 340008c2     	cbz	w2, 0xf6c <___pl_fn_1+0x3cc>
     e58: aa1603e0     	mov	x0, x22
     e5c: f9400008     	ldr	x8, [x0]
     e60: 2a0203e9     	mov	w9, w2
     e64: 8b090d08     	add	x8, x8, x9, lsl #3
     e68: f9400909     	ldr	x9, [x8, #0x10]
     e6c: eb0902bf     	cmp	x21, x9
     e70: 540007e2     	b.hs	0xf6c <___pl_fn_1+0x3cc>
     e74: d2800020     	mov	x0, #0x1                ; =1
     e78: 8b150d01     	add	x1, x8, x21, lsl #3
     e7c: f9001420     	str	x0, [x1, #0x28]
     e80: 528006e1     	mov	w1, #0x37               ; =55
     e84: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     e88: f9400063     	ldr	x3, [x3]
     e8c: aa1603e0     	mov	x0, x22
     e90: aa1803e2     	mov	x2, x24
     e94: d63f0060     	blr	x3
     e98: 350010c0     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     e9c: aa1603e0     	mov	x0, x22
     ea0: f9401802     	ldr	x2, [x0, #0x30]
     ea4: 340007a2     	cbz	w2, 0xf98 <___pl_fn_1+0x3f8>
     ea8: aa1603e0     	mov	x0, x22
     eac: f9400000     	ldr	x0, [x0]
     eb0: 2a0203e1     	mov	w1, w2
     eb4: 8b010c00     	add	x0, x0, x1, lsl #3
     eb8: f9400801     	ldr	x1, [x0, #0x10]
     ebc: eb0102bf     	cmp	x21, x1
     ec0: 540006c2     	b.hs	0xf98 <___pl_fn_1+0x3f8>
     ec4: d2800021     	mov	x1, #0x1                ; =1
     ec8: 8b150c00     	add	x0, x0, x21, lsl #3
     ecc: f9001401     	str	x1, [x0, #0x28]
     ed0: 52800721     	mov	w1, #0x39               ; =57
     ed4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     ed8: f9400063     	ldr	x3, [x3]
     edc: aa1603e0     	mov	x0, x22
     ee0: aa1903e2     	mov	x2, x25
     ee4: d63f0060     	blr	x3
     ee8: 35000e40     	cbnz	w0, 0x10b0 <___pl_fn_1+0x510>
     eec: aa1603e0     	mov	x0, x22
     ef0: f9401802     	ldr	x2, [x0, #0x30]
     ef4: 34000682     	cbz	w2, 0xfc4 <___pl_fn_1+0x424>
     ef8: aa1603e0     	mov	x0, x22
     efc: f9400000     	ldr	x0, [x0]
     f00: 2a0203e1     	mov	w1, w2
     f04: 8b010c00     	add	x0, x0, x1, lsl #3
     f08: f9400801     	ldr	x1, [x0, #0x10]
     f0c: eb0102bf     	cmp	x21, x1
     f10: 540005a2     	b.hs	0xfc4 <___pl_fn_1+0x424>
     f14: d2800021     	mov	x1, #0x1                ; =1
     f18: 8b150c00     	add	x0, x0, x21, lsl #3
     f1c: f9001401     	str	x1, [x0, #0x28]
     f20: ab1402b5     	adds	x21, x21, x20
     f24: 9a9f77e0     	cset	x0, vs
     f28: 72001c1f     	tst	w0, #0xff
     f2c: 54000621     	b.ne	0xff0 <___pl_fn_1+0x450>
     f30: 52800020     	mov	w0, #0x1                ; =1
     f34: 17ffff93     	b	0xd80 <___pl_fn_1+0x1e0>
     f38: 52800661     	mov	w1, #0x33               ; =51
     f3c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     f40: f9400063     	ldr	x3, [x3]
     f44: aa1603e0     	mov	x0, x22
     f48: d63f0060     	blr	x3
     f4c: 910143ff     	add	sp, sp, #0x50
     f50: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f54: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     f58: a8c163f7     	ldp	x23, x24, [sp], #0x10
     f5c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     f60: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f64: d65f03c0     	ret
     f68: 14000052     	b	0x10b0 <___pl_fn_1+0x510>
     f6c: 910063e3     	add	x3, sp, #0x18
     f70: f80183f5     	stur	x21, [sp, #0x18]
     f74: d280002c     	mov	x12, #0x1               ; =1
     f78: f80203ec     	stur	x12, [sp, #0x20]
     f7c: 528006c1     	mov	w1, #0x36               ; =54
     f80: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     f84: f94001ad     	ldr	x13, [x13]
     f88: aa1603e0     	mov	x0, x22
     f8c: d63f01a0     	blr	x13
     f90: 34fff780     	cbz	w0, 0xe80 <___pl_fn_1+0x2e0>
     f94: 14000047     	b	0x10b0 <___pl_fn_1+0x510>
     f98: 9100a3e3     	add	x3, sp, #0x28
     f9c: f80283f5     	stur	x21, [sp, #0x28]
     fa0: d2800020     	mov	x0, #0x1                ; =1
     fa4: f80303e0     	stur	x0, [sp, #0x30]
     fa8: 52800701     	mov	w1, #0x38               ; =56
     fac: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     fb0: f9400084     	ldr	x4, [x4]
     fb4: aa1603e0     	mov	x0, x22
     fb8: d63f0080     	blr	x4
     fbc: 34fff8a0     	cbz	w0, 0xed0 <___pl_fn_1+0x330>
     fc0: 1400003c     	b	0x10b0 <___pl_fn_1+0x510>
     fc4: 9100e3e3     	add	x3, sp, #0x38
     fc8: f80383f5     	stur	x21, [sp, #0x38]
     fcc: d2800020     	mov	x0, #0x1                ; =1
     fd0: f80403e0     	stur	x0, [sp, #0x40]
     fd4: 52800741     	mov	w1, #0x3a               ; =58
     fd8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     fdc: f9400084     	ldr	x4, [x4]
     fe0: aa1603e0     	mov	x0, x22
     fe4: d63f0080     	blr	x4
     fe8: 34fff9c0     	cbz	w0, 0xf20 <___pl_fn_1+0x380>
     fec: 14000031     	b	0x10b0 <___pl_fn_1+0x510>
     ff0: 52800761     	mov	w1, #0x3b               ; =59
     ff4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     ff8: f9400042     	ldr	x2, [x2]
     ffc: aa1603e0     	mov	x0, x22
    1000: d63f0040     	blr	x2
    1004: 910143ff     	add	sp, sp, #0x50
    1008: a8c153f3     	ldp	x19, x20, [sp], #0x10
    100c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1010: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1014: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1018: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    101c: d65f03c0     	ret
    1020: 52800641     	mov	w1, #0x32               ; =50
    1024: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0x460>
    1028: f9400042     	ldr	x2, [x2]
    102c: aa1603e0     	mov	x0, x22
    1030: d63f0040     	blr	x2
    1034: 910143ff     	add	sp, sp, #0x50
    1038: a8c153f3     	ldp	x19, x20, [sp], #0x10
    103c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1040: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1044: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1048: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    104c: d65f03c0     	ret
    1050: 52800621     	mov	w1, #0x31               ; =49
    1054: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0x460>
    1058: f9400042     	ldr	x2, [x2]
    105c: aa1603e0     	mov	x0, x22
    1060: d63f0040     	blr	x2
    1064: 910143ff     	add	sp, sp, #0x50
    1068: a8c153f3     	ldp	x19, x20, [sp], #0x10
    106c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1070: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1074: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1078: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    107c: d65f03c0     	ret
    1080: 52800601     	mov	w1, #0x30               ; =48
    1084: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0x460>
    1088: f9400042     	ldr	x2, [x2]
    108c: aa1603e0     	mov	x0, x22
    1090: d63f0040     	blr	x2
    1094: 910143ff     	add	sp, sp, #0x50
    1098: a8c153f3     	ldp	x19, x20, [sp], #0x10
    109c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    10a0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    10a4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    10a8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    10ac: d65f03c0     	ret
    10b0: 910143ff     	add	sp, sp, #0x50
    10b4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    10b8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    10bc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    10c0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    10c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    10c8: d65f03c0     	ret
