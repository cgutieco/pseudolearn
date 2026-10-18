
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_69571/mandelbrot/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: b9401004     	ldr	w4, [x0, #0x10]
       c: 11000483     	add	w3, w4, #0x1
      10: b9001003     	str	w3, [x0, #0x10]
      14: aa0003e9     	mov	x9, x0
      18: d2800000     	mov	x0, #0x0                ; =0
      1c: d280002c     	mov	x12, #0x1               ; =1
      20: 5280002e     	mov	w14, #0x1               ; =1
      24: aa0e03e3     	mov	x3, x14
      28: aa0e03e8     	mov	x8, x14
      2c: aa0e03ea     	mov	x10, x14
      30: f100003f     	cmp	x1, #0x0
      34: 5400008c     	b.gt	0x44 <___pl_fn_0+0x44>
      38: f100005f     	cmp	x2, #0x0
      3c: 9a9fd7e5     	cset	x5, gt
      40: 14000002     	b	0x48 <___pl_fn_0+0x48>
      44: 52800025     	mov	w5, #0x1                ; =1
      48: 72001cbf     	tst	w5, #0xff
      4c: 540000a1     	b.ne	0x60 <___pl_fn_0+0x60>
      50: aa0903e1     	mov	x1, x9
      54: b9001024     	str	w4, [x1, #0x10]
      58: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      5c: d65f03c0     	ret
      60: d37ffc45     	lsr	x5, x2, #63
      64: 8b050045     	add	x5, x2, x5
      68: 927ff8a6     	and	x6, x5, #0xfffffffffffffffe
      6c: 8b060026     	add	x6, x1, x6
      70: d37ffc27     	lsr	x7, x1, #63
      74: 8b070021     	add	x1, x1, x7
      78: 927ff827     	and	x7, x1, #0xfffffffffffffffe
      7c: 8b070042     	add	x2, x2, x7
      80: eb0200df     	cmp	x6, x2
      84: 540000c0     	b.eq	0x9c <___pl_fn_0+0x9c>
      88: ab0c0000     	adds	x0, x0, x12
      8c: 9a9f77e2     	cset	x2, vs
      90: 72001c5f     	tst	w2, #0xff
      94: 540002c1     	b.ne	0xec <___pl_fn_0+0xec>
      98: 52800023     	mov	w3, #0x1                ; =1
      9c: d2800048     	mov	x8, #0x2                ; =2
      a0: 9b087d87     	mul	x7, x12, x8
      a4: 9b487d88     	smulh	x8, x12, x8
      a8: eb87fd1f     	cmp	x8, x7, asr #63
      ac: 54000101     	b.ne	0xcc <___pl_fn_0+0xcc>
      b0: 9341fc21     	asr	x1, x1, #1
      b4: 9341fca2     	asr	x2, x5, #1
      b8: 5280002e     	mov	w14, #0x1               ; =1
      bc: aa0e03e8     	mov	x8, x14
      c0: aa0e03ea     	mov	x10, x14
      c4: aa0703ec     	mov	x12, x7
      c8: 17ffffda     	b	0x30 <___pl_fn_0+0x30>
      cc: 528000e1     	mov	w1, #0x7                ; =7
      d0: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
      d4: f940014a     	ldr	x10, [x10]
      d8: aa0903e0     	mov	x0, x9
      dc: d63f0140     	blr	x10
      e0: d2800000     	mov	x0, #0x0                ; =0
      e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      e8: d65f03c0     	ret
      ec: aa0903e0     	mov	x0, x9
      f0: 52800041     	mov	w1, #0x2                ; =2
      f4: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
      f8: f940016b     	ldr	x11, [x11]
      fc: d63f0160     	blr	x11
     100: d2800000     	mov	x0, #0x0                ; =0
     104: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     108: d65f03c0     	ret

000000000000010c <___pl_fn_1>:
     10c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     110: 910003fd     	mov	x29, sp
     114: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
     118: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
     11c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     120: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     124: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     128: d102c3ff     	sub	sp, sp, #0xb0
     12c: b9401001     	ldr	w1, [x0, #0x10]
     130: 11000421     	add	w1, w1, #0x1
     134: b9001001     	str	w1, [x0, #0x10]
     138: f80003e0     	stur	x0, [sp]
     13c: 52800101     	mov	w1, #0x8                ; =8
     140: 52800002     	mov	w2, #0x0                ; =0
     144: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     148: f9400063     	ldr	x3, [x3]
     14c: f84003e0     	ldur	x0, [sp]
     150: d63f0060     	blr	x3
     154: 35006500     	cbnz	w0, 0xdf4 <___pl_fn_1+0xce8>
     158: f84003e0     	ldur	x0, [sp]
     15c: f9401813     	ldr	x19, [x0, #0x30]
     160: d2800002     	mov	x2, #0x0                ; =0
     164: d2efff00     	mov	x0, #0x7ff8000000000000 ; =9221120237041090560
     168: 9e670000     	fmov	d0, x0
     16c: 3c8703e0     	stur	q0, [sp, #0x70]
     170: 52800055     	mov	w21, #0x2               ; =2
     174: 52800034     	mov	w20, #0x1               ; =1
     178: 52800004     	mov	w4, #0x0                ; =0
     17c: aa0203e0     	mov	x0, x2
     180: aa1403e1     	mov	x1, x20
     184: aa1403e3     	mov	x3, x20
     188: aa1403e5     	mov	x5, x20
     18c: aa0203f6     	mov	x22, x2
     190: aa0203f7     	mov	x23, x2
     194: aa0203f8     	mov	x24, x2
     198: aa0203f9     	mov	x25, x2
     19c: aa0403fa     	mov	x26, x4
     1a0: aa0403fb     	mov	x27, x4
     1a4: f80203e2     	stur	x2, [sp, #0x20]
     1a8: 3cc703e1     	ldur	q1, [sp, #0x70]
     1ac: 3c8303e1     	stur	q1, [sp, #0x30]
     1b0: 3c8403e1     	stur	q1, [sp, #0x40]
     1b4: 3c8503e1     	stur	q1, [sp, #0x50]
     1b8: 3c8603e1     	stur	q1, [sp, #0x60]
     1bc: eb13031f     	cmp	x24, x19
     1c0: 540002ab     	b.lt	0x214 <___pl_fn_1+0x108>
     1c4: 52800121     	mov	w1, #0x9                ; =9
     1c8: 52802003     	mov	w3, #0x100              ; =256
     1cc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     1d0: f9400084     	ldr	x4, [x4]
     1d4: f84003e0     	ldur	x0, [sp]
     1d8: d63f0080     	blr	x4
     1dc: 350060c0     	cbnz	w0, 0xdf4 <___pl_fn_1+0xce8>
     1e0: f84003e0     	ldur	x0, [sp]
     1e4: b9401000     	ldr	w0, [x0, #0x10]
     1e8: 51000400     	sub	w0, w0, #0x1
     1ec: f84003e1     	ldur	x1, [sp]
     1f0: b9001020     	str	w0, [x1, #0x10]
     1f4: 9102c3ff     	add	sp, sp, #0xb0
     1f8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     1fc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     200: a8c163f7     	ldp	x23, x24, [sp], #0x10
     204: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     208: a8c173fb     	ldp	x27, x28, [sp], #0x10
     20c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     210: d65f03c0     	ret
     214: 1e601001     	fmov	d1, #2.00000000
     218: 9e620302     	scvtf	d2, x24
     21c: 1e620821     	fmul	d1, d1, d2
     220: 1e613822     	fsub	d2, d1, d1
     224: 0f000403     	movi.2s	v3, #0x0
     228: 1e632040     	fcmp	d2, d3
     22c: 54005ca1     	b.ne	0xdc0 <___pl_fn_1+0xcb4>
     230: 9e620263     	scvtf	d3, x19
     234: 0f000404     	movi.2s	v4, #0x0
     238: 1e642060     	fcmp	d3, d4
     23c: 3c8903e4     	stur	q4, [sp, #0x90]
     240: 54005a60     	b.eq	0xd8c <___pl_fn_1+0xc80>
     244: 1e631825     	fdiv	d5, d1, d3
     248: 3c8a03e3     	stur	q3, [sp, #0xa0]
     24c: 1e6538a6     	fsub	d6, d5, d5
     250: 0f000407     	movi.2s	v7, #0x0
     254: 1e6720c0     	fcmp	d6, d7
     258: 54005801     	b.ne	0xd58 <___pl_fn_1+0xc4c>
     25c: 1e6e1007     	fmov	d7, #1.00000000
     260: 1e6738a0     	fsub	d0, d5, d7
     264: 1e603807     	fsub	d7, d0, d0
     268: 0f000410     	movi.2s	v16, #0x0
     26c: 1e7020e0     	fcmp	d7, d16
     270: 540055a1     	b.ne	0xd24 <___pl_fn_1+0xc18>
     274: 1e602000     	fcmp	d0, d0
     278: 3c8103e0     	stur	q0, [sp, #0x10]
     27c: 540053a1     	b.ne	0xcf0 <___pl_fn_1+0xbe4>
     280: d2800017     	mov	x23, #0x0               ; =0
     284: 52800024     	mov	w4, #0x1                ; =1
     288: f80803e2     	stur	x2, [sp, #0x80]
     28c: eb1302ff     	cmp	x23, x19
     290: 5400014b     	b.lt	0x2b8 <___pl_fn_1+0x1ac>
     294: d280002e     	mov	x14, #0x1               ; =1
     298: ab0e0318     	adds	x24, x24, x14
     29c: 9a9f77ef     	cset	x15, vs
     2a0: 72001dff     	tst	w15, #0xff
     2a4: 54001c81     	b.ne	0x634 <___pl_fn_1+0x528>
     2a8: 52800021     	mov	w1, #0x1                ; =1
     2ac: f84803e2     	ldur	x2, [sp, #0x80]
     2b0: 3cc103e0     	ldur	q0, [sp, #0x10]
     2b4: 17ffffc2     	b	0x1bc <___pl_fn_1+0xb0>
     2b8: 0f000412     	movi.2s	v18, #0x0
     2bc: 1e722240     	fcmp	d18, d18
     2c0: 54004fe1     	b.ne	0xcbc <___pl_fn_1+0xbb0>
     2c4: 1e722240     	fcmp	d18, d18
     2c8: 54004e01     	b.ne	0xc88 <___pl_fn_1+0xb7c>
     2cc: 1e722240     	fcmp	d18, d18
     2d0: 54004c21     	b.ne	0xc54 <___pl_fn_1+0xb48>
     2d4: 9e6202f8     	scvtf	d24, x23
     2d8: 1e601019     	fmov	d25, #2.00000000
     2dc: 1e780b38     	fmul	d24, d25, d24
     2e0: 1e783b19     	fsub	d25, d24, d24
     2e4: 0f00041a     	movi.2s	v26, #0x0
     2e8: 1e7a2320     	fcmp	d25, d26
     2ec: 540049a1     	b.ne	0xc20 <___pl_fn_1+0xb14>
     2f0: 3cca03e3     	ldur	q3, [sp, #0xa0]
     2f4: 3cc903e4     	ldur	q4, [sp, #0x90]
     2f8: 1e642060     	fcmp	d3, d4
     2fc: 54004780     	b.eq	0xbec <___pl_fn_1+0xae0>
     300: 1e631b1c     	fdiv	d28, d24, d3
     304: 3c8a03e3     	stur	q3, [sp, #0xa0]
     308: 1e7c3b9d     	fsub	d29, d28, d28
     30c: 0f00041e     	movi.2s	v30, #0x0
     310: 1e7e23a0     	fcmp	d29, d30
     314: 54004521     	b.ne	0xbb8 <___pl_fn_1+0xaac>
     318: 1e6f101e     	fmov	d30, #1.50000000
     31c: 1e7e3b80     	fsub	d0, d28, d30
     320: 1e60381e     	fsub	d30, d0, d0
     324: 0f00041f     	movi.2s	v31, #0x0
     328: 1e7f23c0     	fcmp	d30, d31
     32c: 540042c1     	b.ne	0xb84 <___pl_fn_1+0xa78>
     330: 1e602000     	fcmp	d0, d0
     334: 3c8603e0     	stur	q0, [sp, #0x60]
     338: 540040c1     	b.ne	0xb50 <___pl_fn_1+0xa44>
     33c: d2800016     	mov	x22, #0x0               ; =0
     340: 0f000400     	movi.2s	v0, #0x0
     344: 3c8303e0     	stur	q0, [sp, #0x30]
     348: 52800035     	mov	w21, #0x1               ; =1
     34c: aa1603f9     	mov	x25, x22
     350: aa1503fa     	mov	x26, x21
     354: aa1503fb     	mov	x27, x21
     358: 3c8403e0     	stur	q0, [sp, #0x40]
     35c: 3c8503e0     	stur	q0, [sp, #0x50]
     360: 72001ebf     	tst	w21, #0xff
     364: 54000061     	b.ne	0x370 <___pl_fn_1+0x264>
     368: 52800001     	mov	w1, #0x0                ; =0
     36c: 14000003     	b	0x378 <___pl_fn_1+0x26c>
     370: f100cadf     	cmp	x22, #0x32
     374: 9a9fa7e1     	cset	x1, lt
     378: 72001c3f     	tst	w1, #0xff
     37c: 54000c61     	b.ne	0x508 <___pl_fn_1+0x3fc>
     380: d2800043     	mov	x3, #0x2                ; =2
     384: f84203e2     	ldur	x2, [sp, #0x20]
     388: 9b037c41     	mul	x1, x2, x3
     38c: 9b437c42     	smulh	x2, x2, x3
     390: eb81fc5f     	cmp	x2, x1, asr #63
     394: 54002721     	b.ne	0x878 <___pl_fn_1+0x76c>
     398: ab190022     	adds	x2, x1, x25
     39c: f80203e2     	stur	x2, [sp, #0x20]
     3a0: 9a9f77e1     	cset	x1, vs
     3a4: 72001c3f     	tst	w1, #0xff
     3a8: 540024e1     	b.ne	0x844 <___pl_fn_1+0x738>
     3ac: d280003c     	mov	x28, #0x1               ; =1
     3b0: ab1c0000     	adds	x0, x0, x28
     3b4: 9a9f77e1     	cset	x1, vs
     3b8: 72001c3f     	tst	w1, #0xff
     3bc: 540022a1     	b.ne	0x810 <___pl_fn_1+0x704>
     3c0: f100201f     	cmp	x0, #0x8
     3c4: 540006a0     	b.eq	0x498 <___pl_fn_1+0x38c>
     3c8: eb1c0261     	subs	x1, x19, x28
     3cc: 9a9f77e2     	cset	x2, vs
     3d0: 72001c5f     	tst	w2, #0xff
     3d4: 54001b41     	b.ne	0x73c <___pl_fn_1+0x630>
     3d8: eb0102ff     	cmp	x23, x1
     3dc: 540000a0     	b.eq	0x3f0 <___pl_fn_1+0x2e4>
     3e0: 52800023     	mov	w3, #0x1                ; =1
     3e4: f84803e1     	ldur	x1, [sp, #0x80]
     3e8: aa0303e5     	mov	x5, x3
     3ec: 14000040     	b	0x4ec <___pl_fn_1+0x3e0>
     3f0: d2800101     	mov	x1, #0x8                ; =8
     3f4: eb000023     	subs	x3, x1, x0
     3f8: 9a9f77e0     	cset	x0, vs
     3fc: 72001c1f     	tst	w0, #0xff
     400: 54001841     	b.ne	0x708 <___pl_fn_1+0x5fc>
     404: 528003c1     	mov	w1, #0x1e               ; =30
     408: d2800042     	mov	x2, #0x2                ; =2
     40c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     410: f9400084     	ldr	x4, [x4]
     414: f84003e0     	ldur	x0, [sp]
     418: d63f0080     	blr	x4
     41c: 35004ec0     	cbnz	w0, 0xdf4 <___pl_fn_1+0xce8>
     420: f84003e0     	ldur	x0, [sp]
     424: f9401800     	ldr	x0, [x0, #0x30]
     428: f84203e2     	ldur	x2, [sp, #0x20]
     42c: 9b007c42     	mul	x2, x2, x0
     430: f84203e1     	ldur	x1, [sp, #0x20]
     434: 9b407c20     	smulh	x0, x1, x0
     438: eb82fc1f     	cmp	x0, x2, asr #63
     43c: 540014c1     	b.ne	0x6d4 <___pl_fn_1+0x5c8>
     440: f84003e0     	ldur	x0, [sp]
     444: b9401000     	ldr	w0, [x0, #0x10]
     448: f84003e1     	ldur	x1, [sp]
     44c: b9401421     	ldr	w1, [x1, #0x14]
     450: 6b01001f     	cmp	w0, w1
     454: 54001262     	b.hs	0x6a0 <___pl_fn_1+0x594>
     458: 72001e9f     	tst	w20, #0xff
     45c: 54001080     	b.eq	0x66c <___pl_fn_1+0x560>
     460: f84803e1     	ldur	x1, [sp, #0x80]
     464: f84003e0     	ldur	x0, [sp]
     468: 94000000     	bl	0x468 <___pl_fn_1+0x35c>
     46c: f84003e1     	ldur	x1, [sp]
     470: b9402c23     	ldr	w3, [x1, #0x2c]
     474: 35004c03     	cbnz	w3, 0xdf4 <___pl_fn_1+0xce8>
     478: d2800002     	mov	x2, #0x0                ; =0
     47c: f80203e2     	stur	x2, [sp, #0x20]
     480: 52800034     	mov	w20, #0x1               ; =1
     484: aa1403e5     	mov	x5, x20
     488: aa1403e3     	mov	x3, x20
     48c: aa0003e1     	mov	x1, x0
     490: f84203e0     	ldur	x0, [sp, #0x20]
     494: 14000016     	b	0x4ec <___pl_fn_1+0x3e0>
     498: f84003e0     	ldur	x0, [sp]
     49c: f84803e1     	ldur	x1, [sp, #0x80]
     4a0: b940100c     	ldr	w12, [x0, #0x10]
     4a4: b940140d     	ldr	w13, [x0, #0x14]
     4a8: 6b0d019f     	cmp	w12, w13
     4ac: 54001982     	b.hs	0x7dc <___pl_fn_1+0x6d0>
     4b0: 72001e9f     	tst	w20, #0xff
     4b4: 540017a0     	b.eq	0x7a8 <___pl_fn_1+0x69c>
     4b8: f84203e2     	ldur	x2, [sp, #0x20]
     4bc: f84003e0     	ldur	x0, [sp]
     4c0: 94000000     	bl	0x4c0 <___pl_fn_1+0x3b4>
     4c4: f84003ee     	ldur	x14, [sp]
     4c8: b9402dc1     	ldr	w1, [x14, #0x2c]
     4cc: 35004941     	cbnz	w1, 0xdf4 <___pl_fn_1+0xce8>
     4d0: d2800002     	mov	x2, #0x0                ; =0
     4d4: f80203e2     	stur	x2, [sp, #0x20]
     4d8: 52800034     	mov	w20, #0x1               ; =1
     4dc: aa1403e5     	mov	x5, x20
     4e0: aa1403e3     	mov	x3, x20
     4e4: aa0003e1     	mov	x1, x0
     4e8: f84203e0     	ldur	x0, [sp, #0x20]
     4ec: ab1c02f7     	adds	x23, x23, x28
     4f0: 9a9f77e2     	cset	x2, vs
     4f4: 72001c5f     	tst	w2, #0xff
     4f8: 540013e1     	b.ne	0x774 <___pl_fn_1+0x668>
     4fc: 52800024     	mov	w4, #0x1                ; =1
     500: f80803e1     	stur	x1, [sp, #0x80]
     504: 17ffff62     	b	0x28c <___pl_fn_1+0x180>
     508: f84803e1     	ldur	x1, [sp, #0x80]
     50c: 3cc403e3     	ldur	q3, [sp, #0x40]
     510: 3cc503e4     	ldur	q4, [sp, #0x50]
     514: 1e64387c     	fsub	d28, d3, d4
     518: 1e7c3b9d     	fsub	d29, d28, d28
     51c: 0f00041e     	movi.2s	v30, #0x0
     520: 1e7e23a0     	fcmp	d29, d30
     524: 54002fc1     	b.ne	0xb1c <___pl_fn_1+0xa10>
     528: 3cc603e0     	ldur	q0, [sp, #0x60]
     52c: 1e602b99     	fadd	d25, d28, d0
     530: 1e793b3e     	fsub	d30, d25, d25
     534: 0f00041f     	movi.2s	v31, #0x0
     538: 1e7f23c0     	fcmp	d30, d31
     53c: 54002d61     	b.ne	0xae8 <___pl_fn_1+0x9dc>
     540: 1e792320     	fcmp	d25, d25
     544: 54002b81     	b.ne	0xab4 <___pl_fn_1+0x9a8>
     548: 1e601001     	fmov	d1, #2.00000000
     54c: 1e790822     	fmul	d2, d1, d25
     550: 1e623841     	fsub	d1, d2, d2
     554: 0f000403     	movi.2s	v3, #0x0
     558: 1e632020     	fcmp	d1, d3
     55c: 54002921     	b.ne	0xa80 <___pl_fn_1+0x974>
     560: 3cc303e1     	ldur	q1, [sp, #0x30]
     564: 1e610841     	fmul	d1, d2, d1
     568: 1e613822     	fsub	d2, d1, d1
     56c: 0f000403     	movi.2s	v3, #0x0
     570: 1e632040     	fcmp	d2, d3
     574: 540026c1     	b.ne	0xa4c <___pl_fn_1+0x940>
     578: 3cc103e2     	ldur	q2, [sp, #0x10]
     57c: 1e622821     	fadd	d1, d1, d2
     580: 1e613823     	fsub	d3, d1, d1
     584: 0f000404     	movi.2s	v4, #0x0
     588: 1e642060     	fcmp	d3, d4
     58c: 54002461     	b.ne	0xa18 <___pl_fn_1+0x90c>
     590: 1e612020     	fcmp	d1, d1
     594: 54002281     	b.ne	0x9e4 <___pl_fn_1+0x8d8>
     598: 1e790b23     	fmul	d3, d25, d25
     59c: 1e633864     	fsub	d4, d3, d3
     5a0: 0f000405     	movi.2s	v5, #0x0
     5a4: 1e652080     	fcmp	d4, d5
     5a8: 54002041     	b.ne	0x9b0 <___pl_fn_1+0x8a4>
     5ac: 1e632060     	fcmp	d3, d3
     5b0: 54001e61     	b.ne	0x97c <___pl_fn_1+0x870>
     5b4: 1e610824     	fmul	d4, d1, d1
     5b8: 1e643885     	fsub	d5, d4, d4
     5bc: 0f000406     	movi.2s	v6, #0x0
     5c0: 1e6620a0     	fcmp	d5, d6
     5c4: 54001c21     	b.ne	0x948 <___pl_fn_1+0x83c>
     5c8: 1e642080     	fcmp	d4, d4
     5cc: 54001a41     	b.ne	0x914 <___pl_fn_1+0x808>
     5d0: 1e642865     	fadd	d5, d3, d4
     5d4: 1e6538a6     	fsub	d6, d5, d5
     5d8: 0f000407     	movi.2s	v7, #0x0
     5dc: 1e6720c0     	fcmp	d6, d7
     5e0: 54001801     	b.ne	0x8e0 <___pl_fn_1+0x7d4>
     5e4: 1e621006     	fmov	d6, #4.00000000
     5e8: 1e6620a0     	fcmp	d5, d6
     5ec: 5400008d     	b.le	0x5fc <___pl_fn_1+0x4f0>
     5f0: d2800039     	mov	x25, #0x1               ; =1
     5f4: 52800015     	mov	w21, #0x0               ; =0
     5f8: 5280003a     	mov	w26, #0x1               ; =1
     5fc: d2800022     	mov	x2, #0x1                ; =1
     600: ab0202d6     	adds	x22, x22, x2
     604: 9a9f77e2     	cset	x2, vs
     608: 72001c5f     	tst	w2, #0xff
     60c: 54001501     	b.ne	0x8ac <___pl_fn_1+0x7a0>
     610: 5280003b     	mov	w27, #0x1               ; =1
     614: f80803e1     	stur	x1, [sp, #0x80]
     618: 3c8103e2     	stur	q2, [sp, #0x10]
     61c: 3c8303e1     	stur	q1, [sp, #0x30]
     620: 3c8403e3     	stur	q3, [sp, #0x40]
     624: 3c8503e4     	stur	q4, [sp, #0x50]
     628: 3c8603e0     	stur	q0, [sp, #0x60]
     62c: 3c8703f9     	stur	q25, [sp, #0x70]
     630: 17ffff4c     	b	0x360 <___pl_fn_1+0x254>
     634: 528001e1     	mov	w1, #0xf                ; =15
     638: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     63c: f9400042     	ldr	x2, [x2]
     640: f84003e0     	ldur	x0, [sp]
     644: d63f0040     	blr	x2
     648: 9102c3ff     	add	sp, sp, #0xb0
     64c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     650: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     654: a8c163f7     	ldp	x23, x24, [sp], #0x10
     658: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     65c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     660: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     664: d65f03c0     	ret
     668: 140001e3     	b	0xdf4 <___pl_fn_1+0xce8>
     66c: 52800421     	mov	w1, #0x21               ; =33
     670: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     674: f94000e7     	ldr	x7, [x7]
     678: f84003e0     	ldur	x0, [sp]
     67c: d63f00e0     	blr	x7
     680: 9102c3ff     	add	sp, sp, #0xb0
     684: a8c153f3     	ldp	x19, x20, [sp], #0x10
     688: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     68c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     690: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     694: a8c173fb     	ldp	x27, x28, [sp], #0x10
     698: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     69c: d65f03c0     	ret
     6a0: 52800401     	mov	w1, #0x20               ; =32
     6a4: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     6a8: f9400108     	ldr	x8, [x8]
     6ac: f84003e0     	ldur	x0, [sp]
     6b0: d63f0100     	blr	x8
     6b4: 9102c3ff     	add	sp, sp, #0xb0
     6b8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6bc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6c0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6c4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6c8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     6cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6d0: d65f03c0     	ret
     6d4: 528003e1     	mov	w1, #0x1f               ; =31
     6d8: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     6dc: f9400129     	ldr	x9, [x9]
     6e0: f84003e0     	ldur	x0, [sp]
     6e4: d63f0120     	blr	x9
     6e8: 9102c3ff     	add	sp, sp, #0xb0
     6ec: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6f0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6f4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6f8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6fc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     700: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     704: d65f03c0     	ret
     708: 528003a1     	mov	w1, #0x1d               ; =29
     70c: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     710: f940014a     	ldr	x10, [x10]
     714: f84003e0     	ldur	x0, [sp]
     718: d63f0140     	blr	x10
     71c: 9102c3ff     	add	sp, sp, #0xb0
     720: a8c153f3     	ldp	x19, x20, [sp], #0x10
     724: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     728: a8c163f7     	ldp	x23, x24, [sp], #0x10
     72c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     730: a8c173fb     	ldp	x27, x28, [sp], #0x10
     734: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     738: d65f03c0     	ret
     73c: 52800381     	mov	w1, #0x1c               ; =28
     740: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     744: f940016b     	ldr	x11, [x11]
     748: f84003e0     	ldur	x0, [sp]
     74c: d63f0160     	blr	x11
     750: 9102c3ff     	add	sp, sp, #0xb0
     754: a8c153f3     	ldp	x19, x20, [sp], #0x10
     758: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     75c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     760: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     764: a8c173fb     	ldp	x27, x28, [sp], #0x10
     768: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     76c: d65f03c0     	ret
     770: 140001a1     	b	0xdf4 <___pl_fn_1+0xce8>
     774: 52800481     	mov	w1, #0x24               ; =36
     778: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     77c: f9400042     	ldr	x2, [x2]
     780: f84003e0     	ldur	x0, [sp]
     784: d63f0040     	blr	x2
     788: 9102c3ff     	add	sp, sp, #0xb0
     78c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     790: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     794: a8c163f7     	ldp	x23, x24, [sp], #0x10
     798: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     79c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     7a0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7a4: d65f03c0     	ret
     7a8: 52800461     	mov	w1, #0x23               ; =35
     7ac: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7b0: f9400042     	ldr	x2, [x2]
     7b4: f84003e0     	ldur	x0, [sp]
     7b8: d63f0040     	blr	x2
     7bc: 9102c3ff     	add	sp, sp, #0xb0
     7c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7c4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7c8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7cc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7d0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     7d4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7d8: d65f03c0     	ret
     7dc: 52800441     	mov	w1, #0x22               ; =34
     7e0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7e4: f9400042     	ldr	x2, [x2]
     7e8: f84003e0     	ldur	x0, [sp]
     7ec: d63f0040     	blr	x2
     7f0: 9102c3ff     	add	sp, sp, #0xb0
     7f4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7f8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7fc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     800: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     804: a8c173fb     	ldp	x27, x28, [sp], #0x10
     808: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     80c: d65f03c0     	ret
     810: 52800361     	mov	w1, #0x1b               ; =27
     814: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     818: f9400042     	ldr	x2, [x2]
     81c: f84003e0     	ldur	x0, [sp]
     820: d63f0040     	blr	x2
     824: 9102c3ff     	add	sp, sp, #0xb0
     828: a8c153f3     	ldp	x19, x20, [sp], #0x10
     82c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     830: a8c163f7     	ldp	x23, x24, [sp], #0x10
     834: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     838: a8c173fb     	ldp	x27, x28, [sp], #0x10
     83c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     840: d65f03c0     	ret
     844: 52800341     	mov	w1, #0x1a               ; =26
     848: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     84c: f9400042     	ldr	x2, [x2]
     850: f84003e0     	ldur	x0, [sp]
     854: d63f0040     	blr	x2
     858: 9102c3ff     	add	sp, sp, #0xb0
     85c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     860: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     864: a8c163f7     	ldp	x23, x24, [sp], #0x10
     868: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     86c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     870: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     874: d65f03c0     	ret
     878: 52800321     	mov	w1, #0x19               ; =25
     87c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     880: f9400042     	ldr	x2, [x2]
     884: f84003e0     	ldur	x0, [sp]
     888: d63f0040     	blr	x2
     88c: 9102c3ff     	add	sp, sp, #0xb0
     890: a8c153f3     	ldp	x19, x20, [sp], #0x10
     894: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     898: a8c163f7     	ldp	x23, x24, [sp], #0x10
     89c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8a0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     8a4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8a8: d65f03c0     	ret
     8ac: 52800641     	mov	w1, #0x32               ; =50
     8b0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     8b4: f9400042     	ldr	x2, [x2]
     8b8: f84003e0     	ldur	x0, [sp]
     8bc: d63f0040     	blr	x2
     8c0: 9102c3ff     	add	sp, sp, #0xb0
     8c4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8c8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8cc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8d0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8d4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     8d8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8dc: d65f03c0     	ret
     8e0: 52800601     	mov	w1, #0x30               ; =48
     8e4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     8e8: f9400042     	ldr	x2, [x2]
     8ec: f84003e0     	ldur	x0, [sp]
     8f0: d63f0040     	blr	x2
     8f4: 9102c3ff     	add	sp, sp, #0xb0
     8f8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8fc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     900: a8c163f7     	ldp	x23, x24, [sp], #0x10
     904: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     908: a8c173fb     	ldp	x27, x28, [sp], #0x10
     90c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     910: d65f03c0     	ret
     914: 528005e1     	mov	w1, #0x2f               ; =47
     918: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     91c: f9400042     	ldr	x2, [x2]
     920: f84003e0     	ldur	x0, [sp]
     924: d63f0040     	blr	x2
     928: 9102c3ff     	add	sp, sp, #0xb0
     92c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     930: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     934: a8c163f7     	ldp	x23, x24, [sp], #0x10
     938: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     93c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     940: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     944: d65f03c0     	ret
     948: 528005c1     	mov	w1, #0x2e               ; =46
     94c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     950: f9400042     	ldr	x2, [x2]
     954: f84003e0     	ldur	x0, [sp]
     958: d63f0040     	blr	x2
     95c: 9102c3ff     	add	sp, sp, #0xb0
     960: a8c153f3     	ldp	x19, x20, [sp], #0x10
     964: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     968: a8c163f7     	ldp	x23, x24, [sp], #0x10
     96c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     970: a8c173fb     	ldp	x27, x28, [sp], #0x10
     974: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     978: d65f03c0     	ret
     97c: 528005a1     	mov	w1, #0x2d               ; =45
     980: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     984: f9400042     	ldr	x2, [x2]
     988: f84003e0     	ldur	x0, [sp]
     98c: d63f0040     	blr	x2
     990: 9102c3ff     	add	sp, sp, #0xb0
     994: a8c153f3     	ldp	x19, x20, [sp], #0x10
     998: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     99c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9a0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9a4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9a8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9ac: d65f03c0     	ret
     9b0: 52800581     	mov	w1, #0x2c               ; =44
     9b4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9b8: f9400042     	ldr	x2, [x2]
     9bc: f84003e0     	ldur	x0, [sp]
     9c0: d63f0040     	blr	x2
     9c4: 9102c3ff     	add	sp, sp, #0xb0
     9c8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9cc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9d0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9d4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9d8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9e0: d65f03c0     	ret
     9e4: 52800561     	mov	w1, #0x2b               ; =43
     9e8: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     9ec: f9400063     	ldr	x3, [x3]
     9f0: f84003e0     	ldur	x0, [sp]
     9f4: d63f0060     	blr	x3
     9f8: 9102c3ff     	add	sp, sp, #0xb0
     9fc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a00: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a04: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a08: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a0c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a10: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a14: d65f03c0     	ret
     a18: 52800541     	mov	w1, #0x2a               ; =42
     a1c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     a20: f9400084     	ldr	x4, [x4]
     a24: f84003e0     	ldur	x0, [sp]
     a28: d63f0080     	blr	x4
     a2c: 9102c3ff     	add	sp, sp, #0xb0
     a30: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a34: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a38: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a3c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a40: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a44: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a48: d65f03c0     	ret
     a4c: 52800521     	mov	w1, #0x29               ; =41
     a50: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     a54: f94000a5     	ldr	x5, [x5]
     a58: f84003e0     	ldur	x0, [sp]
     a5c: d63f00a0     	blr	x5
     a60: 9102c3ff     	add	sp, sp, #0xb0
     a64: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a68: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a6c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a70: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a74: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a78: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a7c: d65f03c0     	ret
     a80: 52800501     	mov	w1, #0x28               ; =40
     a84: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     a88: f94000c6     	ldr	x6, [x6]
     a8c: f84003e0     	ldur	x0, [sp]
     a90: d63f00c0     	blr	x6
     a94: 9102c3ff     	add	sp, sp, #0xb0
     a98: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a9c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     aa0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     aa4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     aa8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     aac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ab0: d65f03c0     	ret
     ab4: 528004e1     	mov	w1, #0x27               ; =39
     ab8: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     abc: f94000e7     	ldr	x7, [x7]
     ac0: f84003e0     	ldur	x0, [sp]
     ac4: d63f00e0     	blr	x7
     ac8: 9102c3ff     	add	sp, sp, #0xb0
     acc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ad0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ad4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ad8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     adc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ae0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ae4: d65f03c0     	ret
     ae8: 528004c1     	mov	w1, #0x26               ; =38
     aec: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     af0: f9400108     	ldr	x8, [x8]
     af4: f84003e0     	ldur	x0, [sp]
     af8: d63f0100     	blr	x8
     afc: 9102c3ff     	add	sp, sp, #0xb0
     b00: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b04: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b08: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b0c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b10: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b14: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b18: d65f03c0     	ret
     b1c: 528004a1     	mov	w1, #0x25               ; =37
     b20: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     b24: f9400129     	ldr	x9, [x9]
     b28: f84003e0     	ldur	x0, [sp]
     b2c: d63f0120     	blr	x9
     b30: 9102c3ff     	add	sp, sp, #0xb0
     b34: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b38: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b3c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b40: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b44: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b48: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b4c: d65f03c0     	ret
     b50: 528002e1     	mov	w1, #0x17               ; =23
     b54: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     b58: f940014a     	ldr	x10, [x10]
     b5c: f84003e0     	ldur	x0, [sp]
     b60: d63f0140     	blr	x10
     b64: 9102c3ff     	add	sp, sp, #0xb0
     b68: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b6c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b70: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b74: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b78: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b7c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b80: d65f03c0     	ret
     b84: 528002c1     	mov	w1, #0x16               ; =22
     b88: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     b8c: f940016b     	ldr	x11, [x11]
     b90: f84003e0     	ldur	x0, [sp]
     b94: d63f0160     	blr	x11
     b98: 9102c3ff     	add	sp, sp, #0xb0
     b9c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ba0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ba4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ba8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     bac: a8c173fb     	ldp	x27, x28, [sp], #0x10
     bb0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     bb4: d65f03c0     	ret
     bb8: 528002a1     	mov	w1, #0x15               ; =21
     bbc: 9000000c     	adrp	x12, 0x0 <___pl_fn_0>
     bc0: f940018c     	ldr	x12, [x12]
     bc4: f84003e0     	ldur	x0, [sp]
     bc8: d63f0180     	blr	x12
     bcc: 9102c3ff     	add	sp, sp, #0xb0
     bd0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     bd4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     bd8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     bdc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     be0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     be4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     be8: d65f03c0     	ret
     bec: 52800281     	mov	w1, #0x14               ; =20
     bf0: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     bf4: f94001ad     	ldr	x13, [x13]
     bf8: f84003e0     	ldur	x0, [sp]
     bfc: d63f01a0     	blr	x13
     c00: 9102c3ff     	add	sp, sp, #0xb0
     c04: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c08: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c0c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c10: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c14: a8c173fb     	ldp	x27, x28, [sp], #0x10
     c18: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c1c: d65f03c0     	ret
     c20: 52800261     	mov	w1, #0x13               ; =19
     c24: 9000000e     	adrp	x14, 0x0 <___pl_fn_0>
     c28: f94001ce     	ldr	x14, [x14]
     c2c: f84003e0     	ldur	x0, [sp]
     c30: d63f01c0     	blr	x14
     c34: 9102c3ff     	add	sp, sp, #0xb0
     c38: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c3c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c40: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c44: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c48: a8c173fb     	ldp	x27, x28, [sp], #0x10
     c4c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c50: d65f03c0     	ret
     c54: 52800241     	mov	w1, #0x12               ; =18
     c58: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     c5c: f94001ef     	ldr	x15, [x15]
     c60: f84003e0     	ldur	x0, [sp]
     c64: d63f01e0     	blr	x15
     c68: 9102c3ff     	add	sp, sp, #0xb0
     c6c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c70: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c74: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c78: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c7c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     c80: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c84: d65f03c0     	ret
     c88: 52800221     	mov	w1, #0x11               ; =17
     c8c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c90: f9400042     	ldr	x2, [x2]
     c94: f84003e0     	ldur	x0, [sp]
     c98: d63f0040     	blr	x2
     c9c: 9102c3ff     	add	sp, sp, #0xb0
     ca0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ca4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ca8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     cac: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     cb0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     cb4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     cb8: d65f03c0     	ret
     cbc: 52800201     	mov	w1, #0x10               ; =16
     cc0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     cc4: f9400042     	ldr	x2, [x2]
     cc8: f84003e0     	ldur	x0, [sp]
     ccc: d63f0040     	blr	x2
     cd0: 9102c3ff     	add	sp, sp, #0xb0
     cd4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cd8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     cdc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ce0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     ce4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ce8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     cec: d65f03c0     	ret
     cf0: 528001c1     	mov	w1, #0xe                ; =14
     cf4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     cf8: f9400042     	ldr	x2, [x2]
     cfc: f84003e0     	ldur	x0, [sp]
     d00: d63f0040     	blr	x2
     d04: 9102c3ff     	add	sp, sp, #0xb0
     d08: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d0c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d10: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d14: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d18: a8c173fb     	ldp	x27, x28, [sp], #0x10
     d1c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d20: d65f03c0     	ret
     d24: 528001a1     	mov	w1, #0xd                ; =13
     d28: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     d2c: f9400042     	ldr	x2, [x2]
     d30: f84003e0     	ldur	x0, [sp]
     d34: d63f0040     	blr	x2
     d38: 9102c3ff     	add	sp, sp, #0xb0
     d3c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d40: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d44: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d48: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d4c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     d50: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d54: d65f03c0     	ret
     d58: 52800181     	mov	w1, #0xc                ; =12
     d5c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     d60: f9400042     	ldr	x2, [x2]
     d64: f84003e0     	ldur	x0, [sp]
     d68: d63f0040     	blr	x2
     d6c: 9102c3ff     	add	sp, sp, #0xb0
     d70: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d74: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d78: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d7c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d80: a8c173fb     	ldp	x27, x28, [sp], #0x10
     d84: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d88: d65f03c0     	ret
     d8c: 52800161     	mov	w1, #0xb                ; =11
     d90: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     d94: f9400042     	ldr	x2, [x2]
     d98: f84003e0     	ldur	x0, [sp]
     d9c: d63f0040     	blr	x2
     da0: 9102c3ff     	add	sp, sp, #0xb0
     da4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     da8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     dac: a8c163f7     	ldp	x23, x24, [sp], #0x10
     db0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     db4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     db8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     dbc: d65f03c0     	ret
     dc0: 52800141     	mov	w1, #0xa                ; =10
     dc4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     dc8: f9400042     	ldr	x2, [x2]
     dcc: f84003e0     	ldur	x0, [sp]
     dd0: d63f0040     	blr	x2
     dd4: 9102c3ff     	add	sp, sp, #0xb0
     dd8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ddc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     de0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     de4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     de8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     dec: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     df0: d65f03c0     	ret
     df4: 9102c3ff     	add	sp, sp, #0xb0
     df8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     dfc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e00: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e04: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e08: a8c173fb     	ldp	x27, x28, [sp], #0x10
     e0c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e10: d65f03c0     	ret
