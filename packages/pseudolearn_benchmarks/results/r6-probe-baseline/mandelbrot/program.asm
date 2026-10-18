
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_diagnostic_14290/mandelbrot/program.o:	file format mach-o arm64

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
     154: 35006c20     	cbnz	w0, 0xed8 <___pl_fn_1+0xdcc>
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
     188: aa1403e6     	mov	x6, x20
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
     1dc: 350067e0     	cbnz	w0, 0xed8 <___pl_fn_1+0xdcc>
     1e0: f84003e0     	ldur	x0, [sp]
     1e4: b9401000     	ldr	w0, [x0, #0x10]
     1e8: 51000400     	sub	w0, w0, #0x1
     1ec: f84003e3     	ldur	x3, [sp]
     1f0: b9001060     	str	w0, [x3, #0x10]
     1f4: 9102c3ff     	add	sp, sp, #0xb0
     1f8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     1fc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     200: a8c163f7     	ldp	x23, x24, [sp], #0x10
     204: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     208: a8c173fb     	ldp	x27, x28, [sp], #0x10
     20c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     210: d65f03c0     	ret
     214: 1e601000     	fmov	d0, #2.00000000
     218: 9e620301     	scvtf	d1, x24
     21c: 1e610800     	fmul	d0, d0, d1
     220: 1e60c001     	fabs	d1, d0
     224: d2effe01     	mov	x1, #0x7ff0000000000000 ; =9218868437227405312
     228: 9e670022     	fmov	d2, x1
     22c: 1e622020     	fcmp	d1, d2
     230: 9a9f57e1     	cset	x1, mi
     234: 52000021     	eor	w1, w1, #0x1
     238: 72001c3f     	tst	w1, #0xff
     23c: 54006341     	b.ne	0xea4 <___pl_fn_1+0xd98>
     240: 9e620261     	scvtf	d1, x19
     244: 0f000402     	movi.2s	v2, #0x0
     248: 1e622020     	fcmp	d1, d2
     24c: 3c8903e2     	stur	q2, [sp, #0x90]
     250: 54006100     	b.eq	0xe70 <___pl_fn_1+0xd64>
     254: 1e611800     	fdiv	d0, d0, d1
     258: 3c8a03e1     	stur	q1, [sp, #0xa0]
     25c: 1e60c001     	fabs	d1, d0
     260: d2effe01     	mov	x1, #0x7ff0000000000000 ; =9218868437227405312
     264: 9e670022     	fmov	d2, x1
     268: 1e622020     	fcmp	d1, d2
     26c: 9a9f57e1     	cset	x1, mi
     270: 52000021     	eor	w1, w1, #0x1
     274: 72001c3f     	tst	w1, #0xff
     278: 54005e21     	b.ne	0xe3c <___pl_fn_1+0xd30>
     27c: 1e6e1001     	fmov	d1, #1.00000000
     280: 1e613800     	fsub	d0, d0, d1
     284: 1e60c001     	fabs	d1, d0
     288: d2effe01     	mov	x1, #0x7ff0000000000000 ; =9218868437227405312
     28c: 9e670022     	fmov	d2, x1
     290: 1e622020     	fcmp	d1, d2
     294: 9a9f57e1     	cset	x1, mi
     298: 52000021     	eor	w1, w1, #0x1
     29c: 72001c3f     	tst	w1, #0xff
     2a0: 54005b41     	b.ne	0xe08 <___pl_fn_1+0xcfc>
     2a4: 1e602000     	fcmp	d0, d0
     2a8: 3c8103e0     	stur	q0, [sp, #0x10]
     2ac: 54005941     	b.ne	0xdd4 <___pl_fn_1+0xcc8>
     2b0: d2800017     	mov	x23, #0x0               ; =0
     2b4: 52800024     	mov	w4, #0x1                ; =1
     2b8: f80803e2     	stur	x2, [sp, #0x80]
     2bc: eb1302ff     	cmp	x23, x19
     2c0: 5400014b     	b.lt	0x2e8 <___pl_fn_1+0x1dc>
     2c4: d2800021     	mov	x1, #0x1                ; =1
     2c8: ab010318     	adds	x24, x24, x1
     2cc: 9a9f77e1     	cset	x1, vs
     2d0: 72001c3f     	tst	w1, #0xff
     2d4: 54002221     	b.ne	0x718 <___pl_fn_1+0x60c>
     2d8: 52800021     	mov	w1, #0x1                ; =1
     2dc: f84803e2     	ldur	x2, [sp, #0x80]
     2e0: 3cc103e0     	ldur	q0, [sp, #0x10]
     2e4: 17ffffb6     	b	0x1bc <___pl_fn_1+0xb0>
     2e8: 0f000400     	movi.2s	v0, #0x0
     2ec: 1e602000     	fcmp	d0, d0
     2f0: 54005581     	b.ne	0xda0 <___pl_fn_1+0xc94>
     2f4: 1e602000     	fcmp	d0, d0
     2f8: 540053a1     	b.ne	0xd6c <___pl_fn_1+0xc60>
     2fc: 1e602000     	fcmp	d0, d0
     300: 540051c1     	b.ne	0xd38 <___pl_fn_1+0xc2c>
     304: 9e6202e6     	scvtf	d6, x23
     308: 1e601007     	fmov	d7, #2.00000000
     30c: 1e6608e6     	fmul	d6, d7, d6
     310: 1e60c0c7     	fabs	d7, d6
     314: d2effe05     	mov	x5, #0x7ff0000000000000 ; =9218868437227405312
     318: 9e6700b0     	fmov	d16, x5
     31c: 1e7020e0     	fcmp	d7, d16
     320: 9a9f57e7     	cset	x7, mi
     324: 520000e7     	eor	w7, w7, #0x1
     328: 72001cff     	tst	w7, #0xff
     32c: 54004ec1     	b.ne	0xd04 <___pl_fn_1+0xbf8>
     330: 3cca03e0     	ldur	q0, [sp, #0xa0]
     334: 3cc903e1     	ldur	q1, [sp, #0x90]
     338: 1e612000     	fcmp	d0, d1
     33c: 54004ca0     	b.eq	0xcd0 <___pl_fn_1+0xbc4>
     340: 1e6018d0     	fdiv	d16, d6, d0
     344: 3c8a03e0     	stur	q0, [sp, #0xa0]
     348: 1e60c211     	fabs	d17, d16
     34c: d2effe0a     	mov	x10, #0x7ff0000000000000 ; =9218868437227405312
     350: 9e670152     	fmov	d18, x10
     354: 1e722220     	fcmp	d17, d18
     358: 9a9f57ec     	cset	x12, mi
     35c: 5200018c     	eor	w12, w12, #0x1
     360: 72001d9f     	tst	w12, #0xff
     364: 540049c1     	b.ne	0xc9c <___pl_fn_1+0xb90>
     368: 1e6f1011     	fmov	d17, #1.50000000
     36c: 1e713a00     	fsub	d0, d16, d17
     370: 1e60c010     	fabs	d16, d0
     374: d2effe0d     	mov	x13, #0x7ff0000000000000 ; =9218868437227405312
     378: 9e6701b1     	fmov	d17, x13
     37c: 1e712200     	fcmp	d16, d17
     380: 9a9f57ef     	cset	x15, mi
     384: 520001ef     	eor	w15, w15, #0x1
     388: 72001dff     	tst	w15, #0xff
     38c: 540046e1     	b.ne	0xc68 <___pl_fn_1+0xb5c>
     390: 1e602000     	fcmp	d0, d0
     394: 3c8603e0     	stur	q0, [sp, #0x60]
     398: 540044e1     	b.ne	0xc34 <___pl_fn_1+0xb28>
     39c: d2800016     	mov	x22, #0x0               ; =0
     3a0: 0f000400     	movi.2s	v0, #0x0
     3a4: 3c8303e0     	stur	q0, [sp, #0x30]
     3a8: 52800035     	mov	w21, #0x1               ; =1
     3ac: aa1603f9     	mov	x25, x22
     3b0: aa1503fa     	mov	x26, x21
     3b4: aa1503fb     	mov	x27, x21
     3b8: 3c8403e0     	stur	q0, [sp, #0x40]
     3bc: 3c8503e0     	stur	q0, [sp, #0x50]
     3c0: 72001ebf     	tst	w21, #0xff
     3c4: 54000061     	b.ne	0x3d0 <___pl_fn_1+0x2c4>
     3c8: 52800001     	mov	w1, #0x0                ; =0
     3cc: 14000003     	b	0x3d8 <___pl_fn_1+0x2cc>
     3d0: f100cadf     	cmp	x22, #0x32
     3d4: 9a9fa7e1     	cset	x1, lt
     3d8: 72001c3f     	tst	w1, #0xff
     3dc: 54000c81     	b.ne	0x56c <___pl_fn_1+0x460>
     3e0: d2800043     	mov	x3, #0x2                ; =2
     3e4: f84203e2     	ldur	x2, [sp, #0x20]
     3e8: 9b037c41     	mul	x1, x2, x3
     3ec: 9b437c42     	smulh	x2, x2, x3
     3f0: eb81fc5f     	cmp	x2, x1, asr #63
     3f4: 54002b41     	b.ne	0x95c <___pl_fn_1+0x850>
     3f8: ab190022     	adds	x2, x1, x25
     3fc: f80203e2     	stur	x2, [sp, #0x20]
     400: 9a9f77e1     	cset	x1, vs
     404: 72001c3f     	tst	w1, #0xff
     408: 54002901     	b.ne	0x928 <___pl_fn_1+0x81c>
     40c: d280003c     	mov	x28, #0x1               ; =1
     410: ab1c0000     	adds	x0, x0, x28
     414: 9a9f77e1     	cset	x1, vs
     418: 72001c3f     	tst	w1, #0xff
     41c: 540026c1     	b.ne	0x8f4 <___pl_fn_1+0x7e8>
     420: f100201f     	cmp	x0, #0x8
     424: 540006a0     	b.eq	0x4f8 <___pl_fn_1+0x3ec>
     428: eb1c0261     	subs	x1, x19, x28
     42c: 9a9f77e2     	cset	x2, vs
     430: 72001c5f     	tst	w2, #0xff
     434: 54001f61     	b.ne	0x820 <___pl_fn_1+0x714>
     438: eb0102ff     	cmp	x23, x1
     43c: 540000a0     	b.eq	0x450 <___pl_fn_1+0x344>
     440: 52800023     	mov	w3, #0x1                ; =1
     444: f84803e1     	ldur	x1, [sp, #0x80]
     448: aa0303e6     	mov	x6, x3
     44c: 14000041     	b	0x550 <___pl_fn_1+0x444>
     450: d2800101     	mov	x1, #0x8                ; =8
     454: eb000023     	subs	x3, x1, x0
     458: 9a9f77e0     	cset	x0, vs
     45c: 72001c1f     	tst	w0, #0xff
     460: 54001c61     	b.ne	0x7ec <___pl_fn_1+0x6e0>
     464: 528003c1     	mov	w1, #0x1e               ; =30
     468: d2800042     	mov	x2, #0x2                ; =2
     46c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     470: f9400084     	ldr	x4, [x4]
     474: f84003e0     	ldur	x0, [sp]
     478: d63f0080     	blr	x4
     47c: 350052e0     	cbnz	w0, 0xed8 <___pl_fn_1+0xdcc>
     480: f84003e0     	ldur	x0, [sp]
     484: f9401800     	ldr	x0, [x0, #0x30]
     488: f84203e2     	ldur	x2, [sp, #0x20]
     48c: 9b007c42     	mul	x2, x2, x0
     490: f84203e1     	ldur	x1, [sp, #0x20]
     494: 9b407c20     	smulh	x0, x1, x0
     498: eb82fc1f     	cmp	x0, x2, asr #63
     49c: 540018e1     	b.ne	0x7b8 <___pl_fn_1+0x6ac>
     4a0: f84003e0     	ldur	x0, [sp]
     4a4: b9401000     	ldr	w0, [x0, #0x10]
     4a8: f84003e1     	ldur	x1, [sp]
     4ac: b9401421     	ldr	w1, [x1, #0x14]
     4b0: 6b01001f     	cmp	w0, w1
     4b4: 54001682     	b.hs	0x784 <___pl_fn_1+0x678>
     4b8: 72001e9f     	tst	w20, #0xff
     4bc: 540014a0     	b.eq	0x750 <___pl_fn_1+0x644>
     4c0: f84803e1     	ldur	x1, [sp, #0x80]
     4c4: f84003e0     	ldur	x0, [sp]
     4c8: 94000000     	bl	0x4c8 <___pl_fn_1+0x3bc>
     4cc: f84003e1     	ldur	x1, [sp]
     4d0: b9402c21     	ldr	w1, [x1, #0x2c]
     4d4: 35005021     	cbnz	w1, 0xed8 <___pl_fn_1+0xdcc>
     4d8: d2800002     	mov	x2, #0x0                ; =0
     4dc: f80203e2     	stur	x2, [sp, #0x20]
     4e0: 52800034     	mov	w20, #0x1               ; =1
     4e4: aa1403e6     	mov	x6, x20
     4e8: aa1403e3     	mov	x3, x20
     4ec: aa0003e1     	mov	x1, x0
     4f0: f84203e0     	ldur	x0, [sp, #0x20]
     4f4: 14000017     	b	0x550 <___pl_fn_1+0x444>
     4f8: f84003e0     	ldur	x0, [sp]
     4fc: f84803e1     	ldur	x1, [sp, #0x80]
     500: b9401000     	ldr	w0, [x0, #0x10]
     504: f84003ea     	ldur	x10, [sp]
     508: b9401542     	ldr	w2, [x10, #0x14]
     50c: 6b02001f     	cmp	w0, w2
     510: 54001d82     	b.hs	0x8c0 <___pl_fn_1+0x7b4>
     514: 72001e9f     	tst	w20, #0xff
     518: 54001ba0     	b.eq	0x88c <___pl_fn_1+0x780>
     51c: f84203e2     	ldur	x2, [sp, #0x20]
     520: f84003e0     	ldur	x0, [sp]
     524: 94000000     	bl	0x524 <___pl_fn_1+0x418>
     528: f84003e1     	ldur	x1, [sp]
     52c: b9402c21     	ldr	w1, [x1, #0x2c]
     530: 35004d41     	cbnz	w1, 0xed8 <___pl_fn_1+0xdcc>
     534: d2800002     	mov	x2, #0x0                ; =0
     538: f80203e2     	stur	x2, [sp, #0x20]
     53c: 52800034     	mov	w20, #0x1               ; =1
     540: aa1403e6     	mov	x6, x20
     544: aa1403e3     	mov	x3, x20
     548: aa0003e1     	mov	x1, x0
     54c: f84203e0     	ldur	x0, [sp, #0x20]
     550: ab1c02f7     	adds	x23, x23, x28
     554: 9a9f77e5     	cset	x5, vs
     558: 72001cbf     	tst	w5, #0xff
     55c: 540017e1     	b.ne	0x858 <___pl_fn_1+0x74c>
     560: 52800024     	mov	w4, #0x1                ; =1
     564: f80803e1     	stur	x1, [sp, #0x80]
     568: 17ffff55     	b	0x2bc <___pl_fn_1+0x1b0>
     56c: f84803e1     	ldur	x1, [sp, #0x80]
     570: 3cc403e2     	ldur	q2, [sp, #0x40]
     574: 3cc503e3     	ldur	q3, [sp, #0x50]
     578: 1e633850     	fsub	d16, d2, d3
     57c: 1e60c211     	fabs	d17, d16
     580: d2effe0c     	mov	x12, #0x7ff0000000000000 ; =9218868437227405312
     584: 9e670192     	fmov	d18, x12
     588: 1e722220     	fcmp	d17, d18
     58c: 9a9f57ee     	cset	x14, mi
     590: 520001ce     	eor	w14, w14, #0x1
     594: 72001ddf     	tst	w14, #0xff
     598: 54003341     	b.ne	0xc00 <___pl_fn_1+0xaf4>
     59c: 3cc603e0     	ldur	q0, [sp, #0x60]
     5a0: 1e602a01     	fadd	d1, d16, d0
     5a4: 1e60c030     	fabs	d16, d1
     5a8: d2effe0f     	mov	x15, #0x7ff0000000000000 ; =9218868437227405312
     5ac: 9e6701f1     	fmov	d17, x15
     5b0: 1e712200     	fcmp	d16, d17
     5b4: 9a9f57e2     	cset	x2, mi
     5b8: 52000042     	eor	w2, w2, #0x1
     5bc: 72001c5f     	tst	w2, #0xff
     5c0: 54003061     	b.ne	0xbcc <___pl_fn_1+0xac0>
     5c4: 1e612020     	fcmp	d1, d1
     5c8: 54002e81     	b.ne	0xb98 <___pl_fn_1+0xa8c>
     5cc: 1e601015     	fmov	d21, #2.00000000
     5d0: 1e610ab5     	fmul	d21, d21, d1
     5d4: 1e60c2b6     	fabs	d22, d21
     5d8: d2effe02     	mov	x2, #0x7ff0000000000000 ; =9218868437227405312
     5dc: 9e670057     	fmov	d23, x2
     5e0: 1e7722c0     	fcmp	d22, d23
     5e4: 9a9f57e2     	cset	x2, mi
     5e8: 52000042     	eor	w2, w2, #0x1
     5ec: 72001c5f     	tst	w2, #0xff
     5f0: 54002ba1     	b.ne	0xb64 <___pl_fn_1+0xa58>
     5f4: 3cc303f0     	ldur	q16, [sp, #0x30]
     5f8: 1e700ab8     	fmul	d24, d21, d16
     5fc: 1e60c319     	fabs	d25, d24
     600: d2effe02     	mov	x2, #0x7ff0000000000000 ; =9218868437227405312
     604: 9e67005a     	fmov	d26, x2
     608: 1e7a2320     	fcmp	d25, d26
     60c: 9a9f57e2     	cset	x2, mi
     610: 52000042     	eor	w2, w2, #0x1
     614: 72001c5f     	tst	w2, #0xff
     618: 540028c1     	b.ne	0xb30 <___pl_fn_1+0xa24>
     61c: 3cc103e7     	ldur	q7, [sp, #0x10]
     620: 1e672b10     	fadd	d16, d24, d7
     624: 1e60c21b     	fabs	d27, d16
     628: d2effe02     	mov	x2, #0x7ff0000000000000 ; =9218868437227405312
     62c: 9e67005c     	fmov	d28, x2
     630: 1e7c2360     	fcmp	d27, d28
     634: 9a9f57e2     	cset	x2, mi
     638: 52000042     	eor	w2, w2, #0x1
     63c: 72001c5f     	tst	w2, #0xff
     640: 540025e1     	b.ne	0xafc <___pl_fn_1+0x9f0>
     644: 1e702200     	fcmp	d16, d16
     648: 54002401     	b.ne	0xac8 <___pl_fn_1+0x9bc>
     64c: 1e610822     	fmul	d2, d1, d1
     650: 1e60c043     	fabs	d3, d2
     654: d2effe02     	mov	x2, #0x7ff0000000000000 ; =9218868437227405312
     658: 9e670044     	fmov	d4, x2
     65c: 1e642060     	fcmp	d3, d4
     660: 9a9f57e2     	cset	x2, mi
     664: 52000042     	eor	w2, w2, #0x1
     668: 72001c5f     	tst	w2, #0xff
     66c: 54002141     	b.ne	0xa94 <___pl_fn_1+0x988>
     670: 1e622040     	fcmp	d2, d2
     674: 54001f61     	b.ne	0xa60 <___pl_fn_1+0x954>
     678: 1e700a03     	fmul	d3, d16, d16
     67c: 1e60c064     	fabs	d4, d3
     680: d2effe02     	mov	x2, #0x7ff0000000000000 ; =9218868437227405312
     684: 9e670045     	fmov	d5, x2
     688: 1e652080     	fcmp	d4, d5
     68c: 9a9f57e2     	cset	x2, mi
     690: 52000042     	eor	w2, w2, #0x1
     694: 72001c5f     	tst	w2, #0xff
     698: 54001ca1     	b.ne	0xa2c <___pl_fn_1+0x920>
     69c: 1e632060     	fcmp	d3, d3
     6a0: 54001ac1     	b.ne	0x9f8 <___pl_fn_1+0x8ec>
     6a4: 1e632844     	fadd	d4, d2, d3
     6a8: 1e60c085     	fabs	d5, d4
     6ac: d2effe02     	mov	x2, #0x7ff0000000000000 ; =9218868437227405312
     6b0: 9e670046     	fmov	d6, x2
     6b4: 1e6620a0     	fcmp	d5, d6
     6b8: 9a9f57e2     	cset	x2, mi
     6bc: 52000042     	eor	w2, w2, #0x1
     6c0: 72001c5f     	tst	w2, #0xff
     6c4: 54001801     	b.ne	0x9c4 <___pl_fn_1+0x8b8>
     6c8: 1e621005     	fmov	d5, #4.00000000
     6cc: 1e652080     	fcmp	d4, d5
     6d0: 5400008d     	b.le	0x6e0 <___pl_fn_1+0x5d4>
     6d4: d2800039     	mov	x25, #0x1               ; =1
     6d8: 52800015     	mov	w21, #0x0               ; =0
     6dc: 5280003a     	mov	w26, #0x1               ; =1
     6e0: d2800022     	mov	x2, #0x1                ; =1
     6e4: ab0202d6     	adds	x22, x22, x2
     6e8: 9a9f77e2     	cset	x2, vs
     6ec: 72001c5f     	tst	w2, #0xff
     6f0: 54001501     	b.ne	0x990 <___pl_fn_1+0x884>
     6f4: 5280003b     	mov	w27, #0x1               ; =1
     6f8: f80803e1     	stur	x1, [sp, #0x80]
     6fc: 3c8103e7     	stur	q7, [sp, #0x10]
     700: 3c8303f0     	stur	q16, [sp, #0x30]
     704: 3c8403e2     	stur	q2, [sp, #0x40]
     708: 3c8503e3     	stur	q3, [sp, #0x50]
     70c: 3c8603e0     	stur	q0, [sp, #0x60]
     710: 3c8703e1     	stur	q1, [sp, #0x70]
     714: 17ffff2b     	b	0x3c0 <___pl_fn_1+0x2b4>
     718: 528001e1     	mov	w1, #0xf                ; =15
     71c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     720: f9400042     	ldr	x2, [x2]
     724: f84003e0     	ldur	x0, [sp]
     728: d63f0040     	blr	x2
     72c: 9102c3ff     	add	sp, sp, #0xb0
     730: a8c153f3     	ldp	x19, x20, [sp], #0x10
     734: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     738: a8c163f7     	ldp	x23, x24, [sp], #0x10
     73c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     740: a8c173fb     	ldp	x27, x28, [sp], #0x10
     744: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     748: d65f03c0     	ret
     74c: 140001e3     	b	0xed8 <___pl_fn_1+0xdcc>
     750: 52800421     	mov	w1, #0x21               ; =33
     754: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     758: f9400042     	ldr	x2, [x2]
     75c: f84003e0     	ldur	x0, [sp]
     760: d63f0040     	blr	x2
     764: 9102c3ff     	add	sp, sp, #0xb0
     768: a8c153f3     	ldp	x19, x20, [sp], #0x10
     76c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     770: a8c163f7     	ldp	x23, x24, [sp], #0x10
     774: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     778: a8c173fb     	ldp	x27, x28, [sp], #0x10
     77c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     780: d65f03c0     	ret
     784: 52800401     	mov	w1, #0x20               ; =32
     788: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     78c: f9400042     	ldr	x2, [x2]
     790: f84003e0     	ldur	x0, [sp]
     794: d63f0040     	blr	x2
     798: 9102c3ff     	add	sp, sp, #0xb0
     79c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7a4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7a8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7ac: a8c173fb     	ldp	x27, x28, [sp], #0x10
     7b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7b4: d65f03c0     	ret
     7b8: 528003e1     	mov	w1, #0x1f               ; =31
     7bc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7c0: f9400042     	ldr	x2, [x2]
     7c4: f84003e0     	ldur	x0, [sp]
     7c8: d63f0040     	blr	x2
     7cc: 9102c3ff     	add	sp, sp, #0xb0
     7d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7d8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7dc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7e0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     7e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7e8: d65f03c0     	ret
     7ec: 528003a1     	mov	w1, #0x1d               ; =29
     7f0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7f4: f9400042     	ldr	x2, [x2]
     7f8: f84003e0     	ldur	x0, [sp]
     7fc: d63f0040     	blr	x2
     800: 9102c3ff     	add	sp, sp, #0xb0
     804: a8c153f3     	ldp	x19, x20, [sp], #0x10
     808: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     80c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     810: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     814: a8c173fb     	ldp	x27, x28, [sp], #0x10
     818: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     81c: d65f03c0     	ret
     820: 52800381     	mov	w1, #0x1c               ; =28
     824: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     828: f9400042     	ldr	x2, [x2]
     82c: f84003e0     	ldur	x0, [sp]
     830: d63f0040     	blr	x2
     834: 9102c3ff     	add	sp, sp, #0xb0
     838: a8c153f3     	ldp	x19, x20, [sp], #0x10
     83c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     840: a8c163f7     	ldp	x23, x24, [sp], #0x10
     844: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     848: a8c173fb     	ldp	x27, x28, [sp], #0x10
     84c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     850: d65f03c0     	ret
     854: 140001a1     	b	0xed8 <___pl_fn_1+0xdcc>
     858: 52800481     	mov	w1, #0x24               ; =36
     85c: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     860: f94000e7     	ldr	x7, [x7]
     864: f84003e0     	ldur	x0, [sp]
     868: d63f00e0     	blr	x7
     86c: 9102c3ff     	add	sp, sp, #0xb0
     870: a8c153f3     	ldp	x19, x20, [sp], #0x10
     874: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     878: a8c163f7     	ldp	x23, x24, [sp], #0x10
     87c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     880: a8c173fb     	ldp	x27, x28, [sp], #0x10
     884: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     888: d65f03c0     	ret
     88c: 52800461     	mov	w1, #0x23               ; =35
     890: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     894: f9400108     	ldr	x8, [x8]
     898: f84003e0     	ldur	x0, [sp]
     89c: d63f0100     	blr	x8
     8a0: 9102c3ff     	add	sp, sp, #0xb0
     8a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8a8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8ac: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8b0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8b4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     8b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8bc: d65f03c0     	ret
     8c0: 52800441     	mov	w1, #0x22               ; =34
     8c4: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     8c8: f9400129     	ldr	x9, [x9]
     8cc: f84003e0     	ldur	x0, [sp]
     8d0: d63f0120     	blr	x9
     8d4: 9102c3ff     	add	sp, sp, #0xb0
     8d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8e0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8e4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8e8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     8ec: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8f0: d65f03c0     	ret
     8f4: 52800361     	mov	w1, #0x1b               ; =27
     8f8: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     8fc: f940014a     	ldr	x10, [x10]
     900: f84003e0     	ldur	x0, [sp]
     904: d63f0140     	blr	x10
     908: 9102c3ff     	add	sp, sp, #0xb0
     90c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     910: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     914: a8c163f7     	ldp	x23, x24, [sp], #0x10
     918: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     91c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     920: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     924: d65f03c0     	ret
     928: 52800341     	mov	w1, #0x1a               ; =26
     92c: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     930: f940016b     	ldr	x11, [x11]
     934: f84003e0     	ldur	x0, [sp]
     938: d63f0160     	blr	x11
     93c: 9102c3ff     	add	sp, sp, #0xb0
     940: a8c153f3     	ldp	x19, x20, [sp], #0x10
     944: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     948: a8c163f7     	ldp	x23, x24, [sp], #0x10
     94c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     950: a8c173fb     	ldp	x27, x28, [sp], #0x10
     954: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     958: d65f03c0     	ret
     95c: 52800321     	mov	w1, #0x19               ; =25
     960: 9000000c     	adrp	x12, 0x0 <___pl_fn_0>
     964: f940018c     	ldr	x12, [x12]
     968: f84003e0     	ldur	x0, [sp]
     96c: d63f0180     	blr	x12
     970: 9102c3ff     	add	sp, sp, #0xb0
     974: a8c153f3     	ldp	x19, x20, [sp], #0x10
     978: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     97c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     980: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     984: a8c173fb     	ldp	x27, x28, [sp], #0x10
     988: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     98c: d65f03c0     	ret
     990: 52800641     	mov	w1, #0x32               ; =50
     994: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     998: f9400042     	ldr	x2, [x2]
     99c: f84003e0     	ldur	x0, [sp]
     9a0: d63f0040     	blr	x2
     9a4: 9102c3ff     	add	sp, sp, #0xb0
     9a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9b0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9b4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9b8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9c0: d65f03c0     	ret
     9c4: 52800601     	mov	w1, #0x30               ; =48
     9c8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9cc: f9400042     	ldr	x2, [x2]
     9d0: f84003e0     	ldur	x0, [sp]
     9d4: d63f0040     	blr	x2
     9d8: 9102c3ff     	add	sp, sp, #0xb0
     9dc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9e0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9e4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9e8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9ec: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9f0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9f4: d65f03c0     	ret
     9f8: 528005e1     	mov	w1, #0x2f               ; =47
     9fc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a00: f9400042     	ldr	x2, [x2]
     a04: f84003e0     	ldur	x0, [sp]
     a08: d63f0040     	blr	x2
     a0c: 9102c3ff     	add	sp, sp, #0xb0
     a10: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a14: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a18: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a1c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a20: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a24: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a28: d65f03c0     	ret
     a2c: 528005c1     	mov	w1, #0x2e               ; =46
     a30: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a34: f9400042     	ldr	x2, [x2]
     a38: f84003e0     	ldur	x0, [sp]
     a3c: d63f0040     	blr	x2
     a40: 9102c3ff     	add	sp, sp, #0xb0
     a44: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a48: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a4c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a50: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a54: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a58: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a5c: d65f03c0     	ret
     a60: 528005a1     	mov	w1, #0x2d               ; =45
     a64: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a68: f9400042     	ldr	x2, [x2]
     a6c: f84003e0     	ldur	x0, [sp]
     a70: d63f0040     	blr	x2
     a74: 9102c3ff     	add	sp, sp, #0xb0
     a78: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a7c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a80: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a84: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a88: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a8c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a90: d65f03c0     	ret
     a94: 52800581     	mov	w1, #0x2c               ; =44
     a98: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a9c: f9400042     	ldr	x2, [x2]
     aa0: f84003e0     	ldur	x0, [sp]
     aa4: d63f0040     	blr	x2
     aa8: 9102c3ff     	add	sp, sp, #0xb0
     aac: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ab0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ab4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ab8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     abc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ac0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ac4: d65f03c0     	ret
     ac8: 52800561     	mov	w1, #0x2b               ; =43
     acc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     ad0: f9400042     	ldr	x2, [x2]
     ad4: f84003e0     	ldur	x0, [sp]
     ad8: d63f0040     	blr	x2
     adc: 9102c3ff     	add	sp, sp, #0xb0
     ae0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ae4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ae8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     aec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     af0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     af4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     af8: d65f03c0     	ret
     afc: 52800541     	mov	w1, #0x2a               ; =42
     b00: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b04: f9400042     	ldr	x2, [x2]
     b08: f84003e0     	ldur	x0, [sp]
     b0c: d63f0040     	blr	x2
     b10: 9102c3ff     	add	sp, sp, #0xb0
     b14: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b18: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b1c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b20: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b24: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b28: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b2c: d65f03c0     	ret
     b30: 52800521     	mov	w1, #0x29               ; =41
     b34: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b38: f9400042     	ldr	x2, [x2]
     b3c: f84003e0     	ldur	x0, [sp]
     b40: d63f0040     	blr	x2
     b44: 9102c3ff     	add	sp, sp, #0xb0
     b48: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b4c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b50: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b54: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b58: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b5c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b60: d65f03c0     	ret
     b64: 52800501     	mov	w1, #0x28               ; =40
     b68: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b6c: f9400042     	ldr	x2, [x2]
     b70: f84003e0     	ldur	x0, [sp]
     b74: d63f0040     	blr	x2
     b78: 9102c3ff     	add	sp, sp, #0xb0
     b7c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b80: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b84: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b88: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b8c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b90: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b94: d65f03c0     	ret
     b98: 528004e1     	mov	w1, #0x27               ; =39
     b9c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     ba0: f9400042     	ldr	x2, [x2]
     ba4: f84003e0     	ldur	x0, [sp]
     ba8: d63f0040     	blr	x2
     bac: 9102c3ff     	add	sp, sp, #0xb0
     bb0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     bb4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     bb8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     bbc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     bc0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     bc4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     bc8: d65f03c0     	ret
     bcc: 528004c1     	mov	w1, #0x26               ; =38
     bd0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     bd4: f9400042     	ldr	x2, [x2]
     bd8: f84003e0     	ldur	x0, [sp]
     bdc: d63f0040     	blr	x2
     be0: 9102c3ff     	add	sp, sp, #0xb0
     be4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     be8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     bec: a8c163f7     	ldp	x23, x24, [sp], #0x10
     bf0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     bf4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     bf8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     bfc: d65f03c0     	ret
     c00: 528004a1     	mov	w1, #0x25               ; =37
     c04: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c08: f9400042     	ldr	x2, [x2]
     c0c: f84003e0     	ldur	x0, [sp]
     c10: d63f0040     	blr	x2
     c14: 9102c3ff     	add	sp, sp, #0xb0
     c18: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c1c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c20: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c24: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c28: a8c173fb     	ldp	x27, x28, [sp], #0x10
     c2c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c30: d65f03c0     	ret
     c34: 528002e1     	mov	w1, #0x17               ; =23
     c38: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     c3c: f9400063     	ldr	x3, [x3]
     c40: f84003e0     	ldur	x0, [sp]
     c44: d63f0060     	blr	x3
     c48: 9102c3ff     	add	sp, sp, #0xb0
     c4c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c50: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c54: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c58: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c5c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     c60: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c64: d65f03c0     	ret
     c68: 528002c1     	mov	w1, #0x16               ; =22
     c6c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c70: f9400084     	ldr	x4, [x4]
     c74: f84003e0     	ldur	x0, [sp]
     c78: d63f0080     	blr	x4
     c7c: 9102c3ff     	add	sp, sp, #0xb0
     c80: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c84: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c88: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c8c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c90: a8c173fb     	ldp	x27, x28, [sp], #0x10
     c94: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c98: d65f03c0     	ret
     c9c: 528002a1     	mov	w1, #0x15               ; =21
     ca0: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     ca4: f94000a5     	ldr	x5, [x5]
     ca8: f84003e0     	ldur	x0, [sp]
     cac: d63f00a0     	blr	x5
     cb0: 9102c3ff     	add	sp, sp, #0xb0
     cb4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cb8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     cbc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     cc0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     cc4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     cc8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ccc: d65f03c0     	ret
     cd0: 52800281     	mov	w1, #0x14               ; =20
     cd4: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     cd8: f94000c6     	ldr	x6, [x6]
     cdc: f84003e0     	ldur	x0, [sp]
     ce0: d63f00c0     	blr	x6
     ce4: 9102c3ff     	add	sp, sp, #0xb0
     ce8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     cf0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     cf4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     cf8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     cfc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d00: d65f03c0     	ret
     d04: 52800261     	mov	w1, #0x13               ; =19
     d08: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     d0c: f94000e7     	ldr	x7, [x7]
     d10: f84003e0     	ldur	x0, [sp]
     d14: d63f00e0     	blr	x7
     d18: 9102c3ff     	add	sp, sp, #0xb0
     d1c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d20: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d24: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d28: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d2c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     d30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d34: d65f03c0     	ret
     d38: 52800241     	mov	w1, #0x12               ; =18
     d3c: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     d40: f9400108     	ldr	x8, [x8]
     d44: f84003e0     	ldur	x0, [sp]
     d48: d63f0100     	blr	x8
     d4c: 9102c3ff     	add	sp, sp, #0xb0
     d50: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d54: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d58: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d5c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d60: a8c173fb     	ldp	x27, x28, [sp], #0x10
     d64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d68: d65f03c0     	ret
     d6c: 52800221     	mov	w1, #0x11               ; =17
     d70: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     d74: f9400129     	ldr	x9, [x9]
     d78: f84003e0     	ldur	x0, [sp]
     d7c: d63f0120     	blr	x9
     d80: 9102c3ff     	add	sp, sp, #0xb0
     d84: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d88: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d8c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d90: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d94: a8c173fb     	ldp	x27, x28, [sp], #0x10
     d98: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d9c: d65f03c0     	ret
     da0: 52800201     	mov	w1, #0x10               ; =16
     da4: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     da8: f940014a     	ldr	x10, [x10]
     dac: f84003e0     	ldur	x0, [sp]
     db0: d63f0140     	blr	x10
     db4: 9102c3ff     	add	sp, sp, #0xb0
     db8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     dbc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     dc0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     dc4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     dc8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     dcc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     dd0: d65f03c0     	ret
     dd4: 528001c1     	mov	w1, #0xe                ; =14
     dd8: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     ddc: f940016b     	ldr	x11, [x11]
     de0: f84003e0     	ldur	x0, [sp]
     de4: d63f0160     	blr	x11
     de8: 9102c3ff     	add	sp, sp, #0xb0
     dec: a8c153f3     	ldp	x19, x20, [sp], #0x10
     df0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     df4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     df8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     dfc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     e00: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e04: d65f03c0     	ret
     e08: 528001a1     	mov	w1, #0xd                ; =13
     e0c: 9000000c     	adrp	x12, 0x0 <___pl_fn_0>
     e10: f940018c     	ldr	x12, [x12]
     e14: f84003e0     	ldur	x0, [sp]
     e18: d63f0180     	blr	x12
     e1c: 9102c3ff     	add	sp, sp, #0xb0
     e20: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e24: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e28: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e2c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e30: a8c173fb     	ldp	x27, x28, [sp], #0x10
     e34: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e38: d65f03c0     	ret
     e3c: 52800181     	mov	w1, #0xc                ; =12
     e40: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     e44: f94001ad     	ldr	x13, [x13]
     e48: f84003e0     	ldur	x0, [sp]
     e4c: d63f01a0     	blr	x13
     e50: 9102c3ff     	add	sp, sp, #0xb0
     e54: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e58: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e5c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e60: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e64: a8c173fb     	ldp	x27, x28, [sp], #0x10
     e68: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e6c: d65f03c0     	ret
     e70: 52800161     	mov	w1, #0xb                ; =11
     e74: 9000000e     	adrp	x14, 0x0 <___pl_fn_0>
     e78: f94001ce     	ldr	x14, [x14]
     e7c: f84003e0     	ldur	x0, [sp]
     e80: d63f01c0     	blr	x14
     e84: 9102c3ff     	add	sp, sp, #0xb0
     e88: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e8c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e90: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e94: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e98: a8c173fb     	ldp	x27, x28, [sp], #0x10
     e9c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ea0: d65f03c0     	ret
     ea4: 52800141     	mov	w1, #0xa                ; =10
     ea8: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     eac: f94001ef     	ldr	x15, [x15]
     eb0: f84003e0     	ldur	x0, [sp]
     eb4: d63f01e0     	blr	x15
     eb8: 9102c3ff     	add	sp, sp, #0xb0
     ebc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ec0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ec4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ec8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     ecc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ed0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ed4: d65f03c0     	ret
     ed8: 9102c3ff     	add	sp, sp, #0xb0
     edc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ee0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ee4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ee8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     eec: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ef0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ef4: d65f03c0     	ret
