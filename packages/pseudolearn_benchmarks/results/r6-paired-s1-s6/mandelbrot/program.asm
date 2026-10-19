
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_28184/mandelbrot/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: b9401003     	ldr	w3, [x0, #0x10]
       c: 11000464     	add	w4, w3, #0x1
      10: b9001004     	str	w4, [x0, #0x10]
      14: aa0003e7     	mov	x7, x0
      18: d2800000     	mov	x0, #0x0                ; =0
      1c: d280002c     	mov	x12, #0x1               ; =1
      20: f100003f     	cmp	x1, #0x0
      24: 5400008c     	b.gt	0x34 <___pl_fn_0+0x34>
      28: f100005f     	cmp	x2, #0x0
      2c: 9a9fd7e4     	cset	x4, gt
      30: 14000002     	b	0x38 <___pl_fn_0+0x38>
      34: 52800024     	mov	w4, #0x1                ; =1
      38: 72001c9f     	tst	w4, #0xff
      3c: 540000a1     	b.ne	0x50 <___pl_fn_0+0x50>
      40: aa0703e1     	mov	x1, x7
      44: b9001023     	str	w3, [x1, #0x10]
      48: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      4c: d65f03c0     	ret
      50: d37ffc44     	lsr	x4, x2, #63
      54: 8b040044     	add	x4, x2, x4
      58: 927ff885     	and	x5, x4, #0xfffffffffffffffe
      5c: 8b050025     	add	x5, x1, x5
      60: d37ffc26     	lsr	x6, x1, #63
      64: 8b060021     	add	x1, x1, x6
      68: 927ff826     	and	x6, x1, #0xfffffffffffffffe
      6c: 8b060042     	add	x2, x2, x6
      70: eb0200bf     	cmp	x5, x2
      74: 540000a0     	b.eq	0x88 <___pl_fn_0+0x88>
      78: ab0c0000     	adds	x0, x0, x12
      7c: 9a9f77e2     	cset	x2, vs
      80: 72001c5f     	tst	w2, #0xff
      84: 54000181     	b.ne	0xb4 <___pl_fn_0+0xb4>
      88: d2800042     	mov	x2, #0x2                ; =2
      8c: 9b027d85     	mul	x5, x12, x2
      90: 9b427d82     	smulh	x2, x12, x2
      94: eb85fc5f     	cmp	x2, x5, asr #63
      98: 540000a1     	b.ne	0xac <___pl_fn_0+0xac>
      9c: 9341fc21     	asr	x1, x1, #1
      a0: 9341fc82     	asr	x2, x4, #1
      a4: aa0503ec     	mov	x12, x5
      a8: 17ffffde     	b	0x20 <___pl_fn_0+0x20>
      ac: 528000e1     	mov	w1, #0x7                ; =7
      b0: 14000002     	b	0xb8 <___pl_fn_0+0xb8>
      b4: 52800041     	mov	w1, #0x2                ; =2
      b8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
      bc: f9400042     	ldr	x2, [x2]
      c0: aa0703e0     	mov	x0, x7
      c4: d63f0040     	blr	x2
      c8: d2800000     	mov	x0, #0x0                ; =0
      cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      d0: d65f03c0     	ret

00000000000000d4 <___pl_fn_1>:
      d4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
      d8: 910003fd     	mov	x29, sp
      dc: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
      e0: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      e4: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      e8: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      ec: d100c3ff     	sub	sp, sp, #0x30
      f0: b9401001     	ldr	w1, [x0, #0x10]
      f4: 11000421     	add	w1, w1, #0x1
      f8: b9001001     	str	w1, [x0, #0x10]
      fc: aa0003f8     	mov	x24, x0
     100: 52800101     	mov	w1, #0x8                ; =8
     104: 52800002     	mov	w2, #0x0                ; =0
     108: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     10c: f9400063     	ldr	x3, [x3]
     110: aa1803e0     	mov	x0, x24
     114: d63f0060     	blr	x3
     118: 350026a0     	cbnz	w0, 0x5ec <___pl_fn_1+0x518>
     11c: aa1803e0     	mov	x0, x24
     120: f9401813     	ldr	x19, [x0, #0x30]
     124: d2800002     	mov	x2, #0x0                ; =0
     128: 52800035     	mov	w21, #0x1               ; =1
     12c: aa0203e0     	mov	x0, x2
     130: aa0203f4     	mov	x20, x2
     134: aa0203f9     	mov	x25, x2
     138: eb13029f     	cmp	x20, x19
     13c: 5400028b     	b.lt	0x18c <___pl_fn_1+0xb8>
     140: 52800121     	mov	w1, #0x9                ; =9
     144: 52802003     	mov	w3, #0x100              ; =256
     148: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     14c: f9400084     	ldr	x4, [x4]
     150: aa1803e0     	mov	x0, x24
     154: d63f0080     	blr	x4
     158: 350024a0     	cbnz	w0, 0x5ec <___pl_fn_1+0x518>
     15c: aa1803e0     	mov	x0, x24
     160: b9401000     	ldr	w0, [x0, #0x10]
     164: 51000400     	sub	w0, w0, #0x1
     168: aa1803ee     	mov	x14, x24
     16c: b90011c0     	str	w0, [x14, #0x10]
     170: 9100c3ff     	add	sp, sp, #0x30
     174: a8c153f3     	ldp	x19, x20, [sp], #0x10
     178: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     17c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     180: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     184: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     188: d65f03c0     	ret
     18c: 1e601000     	fmov	d0, #2.00000000
     190: 9e620281     	scvtf	d1, x20
     194: 1e610800     	fmul	d0, d0, d1
     198: 1e603801     	fsub	d1, d0, d0
     19c: 0f000402     	movi.2s	v2, #0x0
     1a0: 1e622020     	fcmp	d1, d2
     1a4: 540021a1     	b.ne	0x5d8 <___pl_fn_1+0x504>
     1a8: 9e620261     	scvtf	d1, x19
     1ac: 0f000402     	movi.2s	v2, #0x0
     1b0: 1e622020     	fcmp	d1, d2
     1b4: 3c8103e2     	stur	q2, [sp, #0x10]
     1b8: 540020c0     	b.eq	0x5d0 <___pl_fn_1+0x4fc>
     1bc: 1e611800     	fdiv	d0, d0, d1
     1c0: 3c8203e1     	stur	q1, [sp, #0x20]
     1c4: 1e603801     	fsub	d1, d0, d0
     1c8: 0f000402     	movi.2s	v2, #0x0
     1cc: 1e622020     	fcmp	d1, d2
     1d0: 54001fc1     	b.ne	0x5c8 <___pl_fn_1+0x4f4>
     1d4: 1e6e1001     	fmov	d1, #1.00000000
     1d8: 1e613801     	fsub	d1, d0, d1
     1dc: 1e613822     	fsub	d2, d1, d1
     1e0: 3c8003e1     	stur	q1, [sp]
     1e4: 0f000401     	movi.2s	v1, #0x0
     1e8: 1e612040     	fcmp	d2, d1
     1ec: 54001ea1     	b.ne	0x5c0 <___pl_fn_1+0x4ec>
     1f0: d2800016     	mov	x22, #0x0               ; =0
     1f4: aa0203fa     	mov	x26, x2
     1f8: eb1302df     	cmp	x22, x19
     1fc: 540000eb     	b.lt	0x218 <___pl_fn_1+0x144>
     200: b27ff7e6     	mov	x6, #0x7ffffffffffffffe ; =9223372036854775806
     204: eb06029f     	cmp	x20, x6
     208: 5400178c     	b.gt	0x4f8 <___pl_fn_1+0x424>
     20c: 91000694     	add	x20, x20, #0x1
     210: aa1a03e2     	mov	x2, x26
     214: 17ffffc9     	b	0x138 <___pl_fn_1+0x64>
     218: 9e6202d0     	scvtf	d16, x22
     21c: 1e601011     	fmov	d17, #2.00000000
     220: 1e700a30     	fmul	d16, d17, d16
     224: 1e703a11     	fsub	d17, d16, d16
     228: 0f000412     	movi.2s	v18, #0x0
     22c: 1e722220     	fcmp	d17, d18
     230: 54001c41     	b.ne	0x5b8 <___pl_fn_1+0x4e4>
     234: 3cc203e0     	ldur	q0, [sp, #0x20]
     238: 3cc103e4     	ldur	q4, [sp, #0x10]
     23c: 1e642000     	fcmp	d0, d4
     240: 54001b80     	b.eq	0x5b0 <___pl_fn_1+0x4dc>
     244: 1e601a10     	fdiv	d16, d16, d0
     248: 3c8203e0     	stur	q0, [sp, #0x20]
     24c: 1e703a11     	fsub	d17, d16, d16
     250: 0f000412     	movi.2s	v18, #0x0
     254: 1e722220     	fcmp	d17, d18
     258: 54001a81     	b.ne	0x5a8 <___pl_fn_1+0x4d4>
     25c: 1e6f1011     	fmov	d17, #1.50000000
     260: 1e713a10     	fsub	d16, d16, d17
     264: 1e703a11     	fsub	d17, d16, d16
     268: 0f000412     	movi.2s	v18, #0x0
     26c: 1e722220     	fcmp	d17, d18
     270: 54001981     	b.ne	0x5a0 <___pl_fn_1+0x4cc>
     274: d2800003     	mov	x3, #0x0                ; =0
     278: 0f00041f     	movi.2s	v31, #0x0
     27c: 52800025     	mov	w5, #0x1                ; =1
     280: aa0303e4     	mov	x4, x3
     284: 4ebf1fe0     	mov.16b	v0, v31
     288: 4ebf1fe2     	mov.16b	v2, v31
     28c: 72001cbf     	tst	w5, #0xff
     290: 54000061     	b.ne	0x29c <___pl_fn_1+0x1c8>
     294: 52800001     	mov	w1, #0x0                ; =0
     298: 14000003     	b	0x2a4 <___pl_fn_1+0x1d0>
     29c: f100c87f     	cmp	x3, #0x32
     2a0: 9a9fa7e1     	cset	x1, lt
     2a4: 72001c3f     	tst	w1, #0xff
     2a8: 54000ba1     	b.ne	0x41c <___pl_fn_1+0x348>
     2ac: d2800043     	mov	x3, #0x2                ; =2
     2b0: aa1903e2     	mov	x2, x25
     2b4: 9b037c41     	mul	x1, x2, x3
     2b8: 9b437c42     	smulh	x2, x2, x3
     2bc: eb81fc5f     	cmp	x2, x1, asr #63
     2c0: 54001481     	b.ne	0x550 <___pl_fn_1+0x47c>
     2c4: ab040022     	adds	x2, x1, x4
     2c8: aa0203f9     	mov	x25, x2
     2cc: 9a9f77e1     	cset	x1, vs
     2d0: 72001c3f     	tst	w1, #0xff
     2d4: 540013a1     	b.ne	0x548 <___pl_fn_1+0x474>
     2d8: b27ff7f7     	mov	x23, #0x7ffffffffffffffe ; =9223372036854775806
     2dc: eb17001f     	cmp	x0, x23
     2e0: 5400130c     	b.gt	0x540 <___pl_fn_1+0x46c>
     2e4: f1001c1f     	cmp	x0, #0x7
     2e8: 54000680     	b.eq	0x3b8 <___pl_fn_1+0x2e4>
     2ec: b24107e1     	mov	x1, #-0x7fffffffffffffff ; =-9223372036854775807
     2f0: eb01027f     	cmp	x19, x1
     2f4: 5400116b     	b.lt	0x520 <___pl_fn_1+0x44c>
     2f8: d1000661     	sub	x1, x19, #0x1
     2fc: eb0102df     	cmp	x22, x1
     300: 54000080     	b.eq	0x310 <___pl_fn_1+0x23c>
     304: 91000400     	add	x0, x0, #0x1
     308: aa1a03e1     	mov	x1, x26
     30c: 1400003f     	b	0x408 <___pl_fn_1+0x334>
     310: 91000400     	add	x0, x0, #0x1
     314: d2800121     	mov	x1, #0x9                ; =9
     318: f2f00001     	movk	x1, #0x8000, lsl #48
     31c: eb01001f     	cmp	x0, x1
     320: 54000fcb     	b.lt	0x518 <___pl_fn_1+0x444>
     324: 52800301     	mov	w1, #0x18               ; =24
     328: d2800042     	mov	x2, #0x2                ; =2
     32c: d2800103     	mov	x3, #0x8                ; =8
     330: cb000063     	sub	x3, x3, x0
     334: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     338: f9400084     	ldr	x4, [x4]
     33c: aa1803e0     	mov	x0, x24
     340: d63f0080     	blr	x4
     344: 35001540     	cbnz	w0, 0x5ec <___pl_fn_1+0x518>
     348: aa1803e0     	mov	x0, x24
     34c: f9401800     	ldr	x0, [x0, #0x30]
     350: aa1903e2     	mov	x2, x25
     354: 9b007c42     	mul	x2, x2, x0
     358: aa1903e1     	mov	x1, x25
     35c: 9b407c20     	smulh	x0, x1, x0
     360: eb82fc1f     	cmp	x0, x2, asr #63
     364: 54000d61     	b.ne	0x510 <___pl_fn_1+0x43c>
     368: aa1803e0     	mov	x0, x24
     36c: b9401000     	ldr	w0, [x0, #0x10]
     370: aa1803e1     	mov	x1, x24
     374: b9401421     	ldr	w1, [x1, #0x14]
     378: 6b01001f     	cmp	w0, w1
     37c: 54000c62     	b.hs	0x508 <___pl_fn_1+0x434>
     380: 72001ebf     	tst	w21, #0xff
     384: 54000be0     	b.eq	0x500 <___pl_fn_1+0x42c>
     388: aa1a03e1     	mov	x1, x26
     38c: aa1803e0     	mov	x0, x24
     390: 94000000     	bl	0x390 <___pl_fn_1+0x2bc>
     394: aa1803e7     	mov	x7, x24
     398: b9402ce1     	ldr	w1, [x7, #0x2c]
     39c: 35001281     	cbnz	w1, 0x5ec <___pl_fn_1+0x518>
     3a0: d2800002     	mov	x2, #0x0                ; =0
     3a4: aa0203f9     	mov	x25, x2
     3a8: 52800035     	mov	w21, #0x1               ; =1
     3ac: aa0003e1     	mov	x1, x0
     3b0: aa1903e0     	mov	x0, x25
     3b4: 14000015     	b	0x408 <___pl_fn_1+0x334>
     3b8: aa1803e0     	mov	x0, x24
     3bc: aa1a03e1     	mov	x1, x26
     3c0: b9401000     	ldr	w0, [x0, #0x10]
     3c4: aa1803e2     	mov	x2, x24
     3c8: b9401442     	ldr	w2, [x2, #0x14]
     3cc: 6b02001f     	cmp	w0, w2
     3d0: 54000b42     	b.hs	0x538 <___pl_fn_1+0x464>
     3d4: 72001ebf     	tst	w21, #0xff
     3d8: 54000ac0     	b.eq	0x530 <___pl_fn_1+0x45c>
     3dc: aa1903e2     	mov	x2, x25
     3e0: aa1803e0     	mov	x0, x24
     3e4: 94000000     	bl	0x3e4 <___pl_fn_1+0x310>
     3e8: aa1803e1     	mov	x1, x24
     3ec: b9402c21     	ldr	w1, [x1, #0x2c]
     3f0: 35000fe1     	cbnz	w1, 0x5ec <___pl_fn_1+0x518>
     3f4: d2800002     	mov	x2, #0x0                ; =0
     3f8: aa0203f9     	mov	x25, x2
     3fc: 52800035     	mov	w21, #0x1               ; =1
     400: aa0003e1     	mov	x1, x0
     404: aa1903e0     	mov	x0, x25
     408: eb1702df     	cmp	x22, x23
     40c: 540008ec     	b.gt	0x528 <___pl_fn_1+0x454>
     410: 910006d6     	add	x22, x22, #0x1
     414: aa0103fa     	mov	x26, x1
     418: 17ffff78     	b	0x1f8 <___pl_fn_1+0x124>
     41c: aa1a03e1     	mov	x1, x26
     420: 1e623811     	fsub	d17, d0, d2
     424: 1e713a32     	fsub	d18, d17, d17
     428: 0f000413     	movi.2s	v19, #0x0
     42c: 1e732240     	fcmp	d18, d19
     430: 54000b41     	b.ne	0x598 <___pl_fn_1+0x4c4>
     434: 1e702a31     	fadd	d17, d17, d16
     438: 1e713a32     	fsub	d18, d17, d17
     43c: 0f000413     	movi.2s	v19, #0x0
     440: 1e732240     	fcmp	d18, d19
     444: 54000a61     	b.ne	0x590 <___pl_fn_1+0x4bc>
     448: 1e601012     	fmov	d18, #2.00000000
     44c: 1e710a52     	fmul	d18, d18, d17
     450: 1e723a53     	fsub	d19, d18, d18
     454: 0f000414     	movi.2s	v20, #0x0
     458: 1e742260     	fcmp	d19, d20
     45c: 54000961     	b.ne	0x588 <___pl_fn_1+0x4b4>
     460: 1e7f0a52     	fmul	d18, d18, d31
     464: 1e723a53     	fsub	d19, d18, d18
     468: 0f000414     	movi.2s	v20, #0x0
     46c: 1e742260     	fcmp	d19, d20
     470: 54000881     	b.ne	0x580 <___pl_fn_1+0x4ac>
     474: 3cc003e1     	ldur	q1, [sp]
     478: 1e612a5f     	fadd	d31, d18, d1
     47c: 1e7f3bf3     	fsub	d19, d31, d31
     480: 0f000414     	movi.2s	v20, #0x0
     484: 1e742260     	fcmp	d19, d20
     488: 54000781     	b.ne	0x578 <___pl_fn_1+0x4a4>
     48c: 1e710a20     	fmul	d0, d17, d17
     490: 1e603815     	fsub	d21, d0, d0
     494: 0f000416     	movi.2s	v22, #0x0
     498: 1e7622a0     	fcmp	d21, d22
     49c: 540006a1     	b.ne	0x570 <___pl_fn_1+0x49c>
     4a0: 1e7f0be2     	fmul	d2, d31, d31
     4a4: 1e623857     	fsub	d23, d2, d2
     4a8: 0f000418     	movi.2s	v24, #0x0
     4ac: 1e7822e0     	fcmp	d23, d24
     4b0: 540005c1     	b.ne	0x568 <___pl_fn_1+0x494>
     4b4: 1e622819     	fadd	d25, d0, d2
     4b8: 1e793b3a     	fsub	d26, d25, d25
     4bc: 0f00041b     	movi.2s	v27, #0x0
     4c0: 1e7b2340     	fcmp	d26, d27
     4c4: 540004e1     	b.ne	0x560 <___pl_fn_1+0x48c>
     4c8: 1e62101b     	fmov	d27, #4.00000000
     4cc: 1e7b2320     	fcmp	d25, d27
     4d0: 5400006d     	b.le	0x4dc <___pl_fn_1+0x408>
     4d4: d2800024     	mov	x4, #0x1                ; =1
     4d8: 52800005     	mov	w5, #0x0                ; =0
     4dc: b27ff7e2     	mov	x2, #0x7ffffffffffffffe ; =9223372036854775806
     4e0: eb02007f     	cmp	x3, x2
     4e4: 540003ac     	b.gt	0x558 <___pl_fn_1+0x484>
     4e8: 91000463     	add	x3, x3, #0x1
     4ec: aa0103fa     	mov	x26, x1
     4f0: 3c8003e1     	stur	q1, [sp]
     4f4: 17ffff66     	b	0x28c <___pl_fn_1+0x1b8>
     4f8: 528001c1     	mov	w1, #0xe                ; =14
     4fc: 14000038     	b	0x5dc <___pl_fn_1+0x508>
     500: 52800361     	mov	w1, #0x1b               ; =27
     504: 14000036     	b	0x5dc <___pl_fn_1+0x508>
     508: 52800341     	mov	w1, #0x1a               ; =26
     50c: 14000034     	b	0x5dc <___pl_fn_1+0x508>
     510: 52800321     	mov	w1, #0x19               ; =25
     514: 14000032     	b	0x5dc <___pl_fn_1+0x508>
     518: 528002e1     	mov	w1, #0x17               ; =23
     51c: 14000030     	b	0x5dc <___pl_fn_1+0x508>
     520: 528002c1     	mov	w1, #0x16               ; =22
     524: 1400002e     	b	0x5dc <___pl_fn_1+0x508>
     528: 528003c1     	mov	w1, #0x1e               ; =30
     52c: 1400002c     	b	0x5dc <___pl_fn_1+0x508>
     530: 528003a1     	mov	w1, #0x1d               ; =29
     534: 1400002a     	b	0x5dc <___pl_fn_1+0x508>
     538: 52800381     	mov	w1, #0x1c               ; =28
     53c: 14000028     	b	0x5dc <___pl_fn_1+0x508>
     540: 528002a1     	mov	w1, #0x15               ; =21
     544: 14000026     	b	0x5dc <___pl_fn_1+0x508>
     548: 52800281     	mov	w1, #0x14               ; =20
     54c: 14000024     	b	0x5dc <___pl_fn_1+0x508>
     550: 52800261     	mov	w1, #0x13               ; =19
     554: 14000022     	b	0x5dc <___pl_fn_1+0x508>
     558: 528004e1     	mov	w1, #0x27               ; =39
     55c: 14000020     	b	0x5dc <___pl_fn_1+0x508>
     560: 528004c1     	mov	w1, #0x26               ; =38
     564: 1400001e     	b	0x5dc <___pl_fn_1+0x508>
     568: 528004a1     	mov	w1, #0x25               ; =37
     56c: 1400001c     	b	0x5dc <___pl_fn_1+0x508>
     570: 52800481     	mov	w1, #0x24               ; =36
     574: 1400001a     	b	0x5dc <___pl_fn_1+0x508>
     578: 52800461     	mov	w1, #0x23               ; =35
     57c: 14000018     	b	0x5dc <___pl_fn_1+0x508>
     580: 52800441     	mov	w1, #0x22               ; =34
     584: 14000016     	b	0x5dc <___pl_fn_1+0x508>
     588: 52800421     	mov	w1, #0x21               ; =33
     58c: 14000014     	b	0x5dc <___pl_fn_1+0x508>
     590: 52800401     	mov	w1, #0x20               ; =32
     594: 14000012     	b	0x5dc <___pl_fn_1+0x508>
     598: 528003e1     	mov	w1, #0x1f               ; =31
     59c: 14000010     	b	0x5dc <___pl_fn_1+0x508>
     5a0: 52800241     	mov	w1, #0x12               ; =18
     5a4: 1400000e     	b	0x5dc <___pl_fn_1+0x508>
     5a8: 52800221     	mov	w1, #0x11               ; =17
     5ac: 1400000c     	b	0x5dc <___pl_fn_1+0x508>
     5b0: 52800201     	mov	w1, #0x10               ; =16
     5b4: 1400000a     	b	0x5dc <___pl_fn_1+0x508>
     5b8: 528001e1     	mov	w1, #0xf                ; =15
     5bc: 14000008     	b	0x5dc <___pl_fn_1+0x508>
     5c0: 528001a1     	mov	w1, #0xd                ; =13
     5c4: 14000006     	b	0x5dc <___pl_fn_1+0x508>
     5c8: 52800181     	mov	w1, #0xc                ; =12
     5cc: 14000004     	b	0x5dc <___pl_fn_1+0x508>
     5d0: 52800161     	mov	w1, #0xb                ; =11
     5d4: 14000002     	b	0x5dc <___pl_fn_1+0x508>
     5d8: 52800141     	mov	w1, #0xa                ; =10
     5dc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     5e0: f9400042     	ldr	x2, [x2]
     5e4: aa1803e0     	mov	x0, x24
     5e8: d63f0040     	blr	x2
     5ec: 9100c3ff     	add	sp, sp, #0x30
     5f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     5f4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     5f8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     5fc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     600: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     604: d65f03c0     	ret
