
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_76447/towers/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: f81f0ffa     	str	x26, [sp, #-0x10]!
       c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      10: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      14: d100c3ff     	sub	sp, sp, #0x30
      18: aa0203f4     	mov	x20, x2
      1c: aa0303f5     	mov	x21, x3
      20: aa0103f6     	mov	x22, x1
      24: b9401001     	ldr	w1, [x0, #0x10]
      28: 11000421     	add	w1, w1, #0x1
      2c: b9001001     	str	w1, [x0, #0x10]
      30: 52800001     	mov	w1, #0x0                ; =0
      34: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
      38: f9400063     	ldr	x3, [x3]
      3c: aa0003f3     	mov	x19, x0
      40: aa1603e2     	mov	x2, x22
      44: d63f0060     	blr	x3
      48: 35000ae0     	cbnz	w0, 0x1a4 <___pl_fn_0+0x1a4>
      4c: f9401a62     	ldr	x2, [x19, #0x30]
      50: 340006a2     	cbz	w2, 0x124 <___pl_fn_0+0x124>
      54: f9400260     	ldr	x0, [x19]
      58: 2a0203e1     	mov	w1, w2
      5c: 8b010c00     	add	x0, x0, x1, lsl #3
      60: f9400801     	ldr	x1, [x0, #0x10]
      64: eb01029f     	cmp	x20, x1
      68: 540005e2     	b.hs	0x124 <___pl_fn_0+0x124>
      6c: 8b140c00     	add	x0, x0, x20, lsl #3
      70: b9402800     	ldr	w0, [x0, #0x28]
      74: 350000a0     	cbnz	w0, 0x88 <___pl_fn_0+0x88>
      78: 1400002b     	b	0x124 <___pl_fn_0+0x124>
      7c: f9401a60     	ldr	x0, [x19, #0x30]
      80: aa1503fa     	mov	x26, x21
      84: 14000002     	b	0x8c <___pl_fn_0+0x8c>
      88: aa1503fa     	mov	x26, x21
      8c: 340005fa     	cbz	w26, 0x148 <___pl_fn_0+0x148>
      90: f940026d     	ldr	x13, [x19]
      94: 2a1a03ec     	mov	w12, w26
      98: 8b0c0dac     	add	x12, x13, x12, lsl #3
      9c: f87a59ae     	ldr	x14, [x13, w26, uxtw #3]
      a0: 2a0003ed     	mov	w13, w0
      a4: d360fdce     	lsr	x14, x14, #32
      a8: 92403dce     	and	x14, x14, #0xffff
      ac: 910005ce     	add	x14, x14, #0x1
      b0: f82e798d     	str	x13, [x12, x14, lsl #3]
      b4: 52800061     	mov	w1, #0x3                ; =3
      b8: 9000000e     	adrp	x14, 0x0 <___pl_fn_0>
      bc: f94001ce     	ldr	x14, [x14]
      c0: aa1603e2     	mov	x2, x22
      c4: aa1303e0     	mov	x0, x19
      c8: d63f01c0     	blr	x14
      cc: 350006c0     	cbnz	w0, 0x1a4 <___pl_fn_0+0x1a4>
      d0: f9401a62     	ldr	x2, [x19, #0x30]
      d4: 34000542     	cbz	w2, 0x17c <___pl_fn_0+0x17c>
      d8: f9400260     	ldr	x0, [x19]
      dc: 2a0203e1     	mov	w1, w2
      e0: 8b010c00     	add	x0, x0, x1, lsl #3
      e4: f9400801     	ldr	x1, [x0, #0x10]
      e8: eb01029f     	cmp	x20, x1
      ec: 54000482     	b.hs	0x17c <___pl_fn_0+0x17c>
      f0: 2a1a03e1     	mov	w1, w26
      f4: 8b140c00     	add	x0, x0, x20, lsl #3
      f8: f9001401     	str	x1, [x0, #0x28]
      fc: b9401260     	ldr	w0, [x19, #0x10]
     100: 51000400     	sub	w0, w0, #0x1
     104: b9001260     	str	w0, [x19, #0x10]
     108: 9100c3ff     	add	sp, sp, #0x30
     10c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     110: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     114: f84107fa     	ldr	x26, [sp], #0x10
     118: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     11c: d65f03c0     	ret
     120: 14000021     	b	0x1a4 <___pl_fn_0+0x1a4>
     124: 910003e3     	mov	x3, sp
     128: f80003f4     	stur	x20, [sp]
     12c: 52800021     	mov	w1, #0x1                ; =1
     130: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     134: f9400084     	ldr	x4, [x4]
     138: aa1303e0     	mov	x0, x19
     13c: d63f0080     	blr	x4
     140: 34fff9e0     	cbz	w0, 0x7c <___pl_fn_0+0x7c>
     144: 14000018     	b	0x1a4 <___pl_fn_0+0x1a4>
     148: d2800027     	mov	x7, #0x1                ; =1
     14c: 910023e3     	add	x3, sp, #0x8
     150: f80083e7     	stur	x7, [sp, #0x8]
     154: 2a0003e8     	mov	w8, w0
     158: f80103e8     	stur	x8, [sp, #0x10]
     15c: 52800041     	mov	w1, #0x2                ; =2
     160: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     164: f9400129     	ldr	x9, [x9]
     168: aa1303e0     	mov	x0, x19
     16c: aa1a03e2     	mov	x2, x26
     170: d63f0120     	blr	x9
     174: 34fffa00     	cbz	w0, 0xb4 <___pl_fn_0+0xb4>
     178: 1400000b     	b	0x1a4 <___pl_fn_0+0x1a4>
     17c: 910063e3     	add	x3, sp, #0x18
     180: f80183f4     	stur	x20, [sp, #0x18]
     184: 2a1a03e0     	mov	w0, w26
     188: f80203e0     	stur	x0, [sp, #0x20]
     18c: 52800081     	mov	w1, #0x4                ; =4
     190: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     194: f9400084     	ldr	x4, [x4]
     198: aa1303e0     	mov	x0, x19
     19c: d63f0080     	blr	x4
     1a0: 34fffae0     	cbz	w0, 0xfc <___pl_fn_0+0xfc>
     1a4: 9100c3ff     	add	sp, sp, #0x30
     1a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     1ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     1b0: f84107fa     	ldr	x26, [sp], #0x10
     1b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     1b8: d65f03c0     	ret

00000000000001bc <___pl_fn_1>:
     1bc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     1c0: 910003fd     	mov	x29, sp
     1c4: f81f0ff9     	str	x25, [sp, #-0x10]!
     1c8: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     1cc: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     1d0: d10083ff     	sub	sp, sp, #0x20
     1d4: aa0203f3     	mov	x19, x2
     1d8: aa0103f6     	mov	x22, x1
     1dc: b9401001     	ldr	w1, [x0, #0x10]
     1e0: 11000421     	add	w1, w1, #0x1
     1e4: b9001001     	str	w1, [x0, #0x10]
     1e8: aa0003f4     	mov	x20, x0
     1ec: 528000a1     	mov	w1, #0x5                ; =5
     1f0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     1f4: f9400063     	ldr	x3, [x3]
     1f8: aa1403e0     	mov	x0, x20
     1fc: aa1603e2     	mov	x2, x22
     200: d63f0060     	blr	x3
     204: 35000e60     	cbnz	w0, 0x3d0 <___pl_fn_1+0x214>
     208: aa1403e0     	mov	x0, x20
     20c: f9401802     	ldr	x2, [x0, #0x30]
     210: 340008a2     	cbz	w2, 0x324 <___pl_fn_1+0x168>
     214: aa1403e0     	mov	x0, x20
     218: f9400001     	ldr	x1, [x0]
     21c: 2a0203e3     	mov	w3, w2
     220: 8b030c21     	add	x1, x1, x3, lsl #3
     224: f9400823     	ldr	x3, [x1, #0x10]
     228: aa1303f9     	mov	x25, x19
     22c: eb03033f     	cmp	x25, x3
     230: 540007c2     	b.hs	0x328 <___pl_fn_1+0x16c>
     234: 8b190c24     	add	x4, x1, x25, lsl #3
     238: b9402880     	ldr	w0, [x4, #0x28]
     23c: 35000080     	cbnz	w0, 0x24c <___pl_fn_1+0x90>
     240: 1400003a     	b	0x328 <___pl_fn_1+0x16c>
     244: aa1403e0     	mov	x0, x20
     248: f9401800     	ldr	x0, [x0, #0x30]
     24c: 34000aa0     	cbz	w0, 0x3a0 <___pl_fn_1+0x1e4>
     250: 340007e0     	cbz	w0, 0x34c <___pl_fn_1+0x190>
     254: aa1403e1     	mov	x1, x20
     258: f940002f     	ldr	x15, [x1]
     25c: 2a0003ee     	mov	w14, w0
     260: 8b0e0dee     	add	x14, x15, x14, lsl #3
     264: f86059ef     	ldr	x15, [x15, w0, uxtw #3]
     268: aa0003f5     	mov	x21, x0
     26c: d360fdef     	lsr	x15, x15, #32
     270: 92403def     	and	x15, x15, #0xffff
     274: 910005ef     	add	x15, x15, #0x1
     278: d37df1ef     	lsl	x15, x15, #3
     27c: b86f69d3     	ldr	w19, [x14, x15]
     280: 35000093     	cbnz	w19, 0x290 <___pl_fn_1+0xd4>
     284: 14000033     	b	0x350 <___pl_fn_1+0x194>
     288: aa1403e0     	mov	x0, x20
     28c: f9401813     	ldr	x19, [x0, #0x30]
     290: 52800121     	mov	w1, #0x9                ; =9
     294: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     298: f9400063     	ldr	x3, [x3]
     29c: aa1603e2     	mov	x2, x22
     2a0: aa1403e0     	mov	x0, x20
     2a4: d63f0060     	blr	x3
     2a8: 35000940     	cbnz	w0, 0x3d0 <___pl_fn_1+0x214>
     2ac: aa1403e0     	mov	x0, x20
     2b0: f9401802     	ldr	x2, [x0, #0x30]
     2b4: 34000602     	cbz	w2, 0x374 <___pl_fn_1+0x1b8>
     2b8: aa1403e0     	mov	x0, x20
     2bc: f9400000     	ldr	x0, [x0]
     2c0: 2a0203e1     	mov	w1, w2
     2c4: 8b010c00     	add	x0, x0, x1, lsl #3
     2c8: f9400801     	ldr	x1, [x0, #0x10]
     2cc: eb01033f     	cmp	x25, x1
     2d0: 54000083     	b.lo	0x2e0 <___pl_fn_1+0x124>
     2d4: 14000028     	b	0x374 <___pl_fn_1+0x1b8>
     2d8: aa1403e0     	mov	x0, x20
     2dc: 14000005     	b	0x2f0 <___pl_fn_1+0x134>
     2e0: 2a1303e1     	mov	w1, w19
     2e4: 8b190c00     	add	x0, x0, x25, lsl #3
     2e8: f9001401     	str	x1, [x0, #0x28]
     2ec: aa1403e0     	mov	x0, x20
     2f0: aa1403e0     	mov	x0, x20
     2f4: b9401000     	ldr	w0, [x0, #0x10]
     2f8: 51000400     	sub	w0, w0, #0x1
     2fc: aa1403e1     	mov	x1, x20
     300: b9001020     	str	w0, [x1, #0x10]
     304: aa1503e0     	mov	x0, x21
     308: 910083ff     	add	sp, sp, #0x20
     30c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     310: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     314: f84107f9     	ldr	x25, [sp], #0x10
     318: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     31c: d65f03c0     	ret
     320: 1400002c     	b	0x3d0 <___pl_fn_1+0x214>
     324: aa1303f9     	mov	x25, x19
     328: 910003e3     	mov	x3, sp
     32c: f80003f9     	stur	x25, [sp]
     330: 528000c1     	mov	w1, #0x6                ; =6
     334: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     338: f94000e7     	ldr	x7, [x7]
     33c: aa1403e0     	mov	x0, x20
     340: d63f00e0     	blr	x7
     344: 34fff800     	cbz	w0, 0x244 <___pl_fn_1+0x88>
     348: 14000022     	b	0x3d0 <___pl_fn_1+0x214>
     34c: aa0003f5     	mov	x21, x0
     350: 52800101     	mov	w1, #0x8                ; =8
     354: 52800023     	mov	w3, #0x1                ; =1
     358: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     35c: f9400084     	ldr	x4, [x4]
     360: aa1403e0     	mov	x0, x20
     364: aa1503e2     	mov	x2, x21
     368: d63f0080     	blr	x4
     36c: 34fff8e0     	cbz	w0, 0x288 <___pl_fn_1+0xcc>
     370: 14000018     	b	0x3d0 <___pl_fn_1+0x214>
     374: 910023e3     	add	x3, sp, #0x8
     378: f80083f9     	stur	x25, [sp, #0x8]
     37c: 2a1303e0     	mov	w0, w19
     380: f80103e0     	stur	x0, [sp, #0x10]
     384: 52800141     	mov	w1, #0xa                ; =10
     388: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     38c: f9400084     	ldr	x4, [x4]
     390: aa1403e0     	mov	x0, x20
     394: d63f0080     	blr	x4
     398: 34fffa00     	cbz	w0, 0x2d8 <___pl_fn_1+0x11c>
     39c: 1400000d     	b	0x3d0 <___pl_fn_1+0x214>
     3a0: 528000e1     	mov	w1, #0x7                ; =7
     3a4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     3a8: f9400042     	ldr	x2, [x2]
     3ac: aa1403e0     	mov	x0, x20
     3b0: d63f0040     	blr	x2
     3b4: 52800000     	mov	w0, #0x0                ; =0
     3b8: 910083ff     	add	sp, sp, #0x20
     3bc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     3c0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     3c4: f84107f9     	ldr	x25, [sp], #0x10
     3c8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     3cc: d65f03c0     	ret
     3d0: 52800000     	mov	w0, #0x0                ; =0
     3d4: 910083ff     	add	sp, sp, #0x20
     3d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     3dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     3e0: f84107f9     	ldr	x25, [sp], #0x10
     3e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     3e8: d65f03c0     	ret

00000000000003ec <___pl_fn_2>:
     3ec: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     3f0: 910003fd     	mov	x29, sp
     3f4: f81f0ff7     	str	x23, [sp, #-0x10]!
     3f8: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     3fc: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     400: aa0403f5     	mov	x21, x4
     404: aa0303f6     	mov	x22, x3
     408: aa0103f7     	mov	x23, x1
     40c: b9401001     	ldr	w1, [x0, #0x10]
     410: 11000423     	add	w3, w1, #0x1
     414: b9001003     	str	w3, [x0, #0x10]
     418: b9401403     	ldr	w3, [x0, #0x14]
     41c: aa0003f4     	mov	x20, x0
     420: 11000420     	add	w0, w1, #0x1
     424: 6b03001f     	cmp	w0, w3
     428: 54000c42     	b.hs	0x5b0 <___pl_fn_2+0x1c4>
     42c: aa1403e0     	mov	x0, x20
     430: aa1703e1     	mov	x1, x23
     434: 94000000     	bl	0x434 <___pl_fn_2+0x48>
     438: aa1403e1     	mov	x1, x20
     43c: b9402c21     	ldr	w1, [x1, #0x2c]
     440: 35000ae1     	cbnz	w1, 0x59c <___pl_fn_2+0x1b0>
     444: aa1403e1     	mov	x1, x20
     448: b9401833     	ldr	w19, [x1, #0x18]
     44c: b9401c22     	ldr	w2, [x1, #0x1c]
     450: 11000661     	add	w1, w19, #0x1
     454: 6b02003f     	cmp	w1, w2
     458: 540008e8     	b.hi	0x574 <___pl_fn_2+0x188>
     45c: aa1403e3     	mov	x3, x20
     460: f9401062     	ldr	x2, [x3, #0x20]
     464: b8335840     	str	w0, [x2, w19, uxtw #2]
     468: aa0003e3     	mov	x3, x0
     46c: aa1403e0     	mov	x0, x20
     470: b9001801     	str	w1, [x0, #0x18]
     474: b9401000     	ldr	w0, [x0, #0x10]
     478: aa1403ea     	mov	x10, x20
     47c: b9401541     	ldr	w1, [x10, #0x14]
     480: 6b01001f     	cmp	w0, w1
     484: 54000642     	b.hs	0x54c <___pl_fn_2+0x160>
     488: aa1703e1     	mov	x1, x23
     48c: aa1603e2     	mov	x2, x22
     490: aa1403e0     	mov	x0, x20
     494: 94000000     	bl	0x494 <___pl_fn_2+0xa8>
     498: aa1403e0     	mov	x0, x20
     49c: b9402c00     	ldr	w0, [x0, #0x2c]
     4a0: 350007e0     	cbnz	w0, 0x59c <___pl_fn_2+0x1b0>
     4a4: aa1403e0     	mov	x0, x20
     4a8: b9001813     	str	w19, [x0, #0x18]
     4ac: 528001c1     	mov	w1, #0xe                ; =14
     4b0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     4b4: f9400063     	ldr	x3, [x3]
     4b8: aa1503e2     	mov	x2, x21
     4bc: d63f0060     	blr	x3
     4c0: 350006e0     	cbnz	w0, 0x59c <___pl_fn_2+0x1b0>
     4c4: aa1403e0     	mov	x0, x20
     4c8: f9401800     	ldr	x0, [x0, #0x30]
     4cc: d2800021     	mov	x1, #0x1                ; =1
     4d0: ab010003     	adds	x3, x0, x1
     4d4: 9a9f77e0     	cset	x0, vs
     4d8: 72001c1f     	tst	w0, #0xff
     4dc: 54000241     	b.ne	0x524 <___pl_fn_2+0x138>
     4e0: 52800201     	mov	w1, #0x10               ; =16
     4e4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     4e8: f9400084     	ldr	x4, [x4]
     4ec: aa1503e2     	mov	x2, x21
     4f0: aa1403e0     	mov	x0, x20
     4f4: d63f0080     	blr	x4
     4f8: 35000520     	cbnz	w0, 0x59c <___pl_fn_2+0x1b0>
     4fc: aa1403e0     	mov	x0, x20
     500: b9401001     	ldr	w1, [x0, #0x10]
     504: 51000421     	sub	w1, w1, #0x1
     508: b9001001     	str	w1, [x0, #0x10]
     50c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     510: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     514: f84107f7     	ldr	x23, [sp], #0x10
     518: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     51c: d65f03c0     	ret
     520: 1400001f     	b	0x59c <___pl_fn_2+0x1b0>
     524: 528001e1     	mov	w1, #0xf                ; =15
     528: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     52c: f9400063     	ldr	x3, [x3]
     530: aa1403e0     	mov	x0, x20
     534: d63f0060     	blr	x3
     538: a8c153f3     	ldp	x19, x20, [sp], #0x10
     53c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     540: f84107f7     	ldr	x23, [sp], #0x10
     544: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     548: d65f03c0     	ret
     54c: 528001a1     	mov	w1, #0xd                ; =13
     550: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     554: f9400084     	ldr	x4, [x4]
     558: aa1403e0     	mov	x0, x20
     55c: d63f0080     	blr	x4
     560: a8c153f3     	ldp	x19, x20, [sp], #0x10
     564: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     568: f84107f7     	ldr	x23, [sp], #0x10
     56c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     570: d65f03c0     	ret
     574: 52800181     	mov	w1, #0xc                ; =12
     578: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     57c: f94000a5     	ldr	x5, [x5]
     580: aa1403e0     	mov	x0, x20
     584: d63f00a0     	blr	x5
     588: a8c153f3     	ldp	x19, x20, [sp], #0x10
     58c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     590: f84107f7     	ldr	x23, [sp], #0x10
     594: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     598: d65f03c0     	ret
     59c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     5a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     5a4: f84107f7     	ldr	x23, [sp], #0x10
     5a8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     5ac: d65f03c0     	ret
     5b0: 52800161     	mov	w1, #0xb                ; =11
     5b4: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     5b8: f94000e7     	ldr	x7, [x7]
     5bc: aa1403e0     	mov	x0, x20
     5c0: d63f00e0     	blr	x7
     5c4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     5c8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     5cc: f84107f7     	ldr	x23, [sp], #0x10
     5d0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     5d4: d65f03c0     	ret

00000000000005d8 <___pl_fn_3>:
     5d8: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     5dc: 910003fd     	mov	x29, sp
     5e0: f81f0ffa     	str	x26, [sp, #-0x10]!
     5e4: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     5e8: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     5ec: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     5f0: aa0003f4     	mov	x20, x0
     5f4: aa0503f6     	mov	x22, x5
     5f8: aa0103fa     	mov	x26, x1
     5fc: b9401000     	ldr	w0, [x0, #0x10]
     600: 11000401     	add	w1, w0, #0x1
     604: aa1403e5     	mov	x5, x20
     608: b90010a1     	str	w1, [x5, #0x10]
     60c: f100045f     	cmp	x2, #0x1
     610: aa0203f7     	mov	x23, x2
     614: 540008c0     	b.eq	0x72c <___pl_fn_3+0x154>
     618: d2800065     	mov	x5, #0x3                ; =3
     61c: eb0300a2     	subs	x2, x5, x3
     620: aa0303f5     	mov	x21, x3
     624: 9a9f77e5     	cset	x5, vs
     628: 72001cbf     	tst	w5, #0xff
     62c: 540013e1     	b.ne	0x8a8 <___pl_fn_3+0x2d0>
     630: eb040053     	subs	x19, x2, x4
     634: aa0403f8     	mov	x24, x4
     638: 9a9f77e6     	cset	x6, vs
     63c: 72001cdf     	tst	w6, #0xff
     640: 540011e1     	b.ne	0x87c <___pl_fn_3+0x2a4>
     644: d2800027     	mov	x7, #0x1                ; =1
     648: aa1703e1     	mov	x1, x23
     64c: eb070022     	subs	x2, x1, x7
     650: 9a9f77e8     	cset	x8, vs
     654: 72001d1f     	tst	w8, #0xff
     658: 54000fc1     	b.ne	0x850 <___pl_fn_3+0x278>
     65c: aa1403e1     	mov	x1, x20
     660: b9401429     	ldr	w9, [x1, #0x14]
     664: 1100040a     	add	w10, w0, #0x1
     668: 6b09015f     	cmp	w10, w9
     66c: 54000dc2     	b.hs	0x824 <___pl_fn_3+0x24c>
     670: aa1403e0     	mov	x0, x20
     674: aa1a03e1     	mov	x1, x26
     678: aa1503e3     	mov	x3, x21
     67c: aa1303e4     	mov	x4, x19
     680: aa1603e5     	mov	x5, x22
     684: 94000000     	bl	0x684 <___pl_fn_3+0xac>
     688: aa1403e0     	mov	x0, x20
     68c: b9402c0c     	ldr	w12, [x0, #0x2c]
     690: 3500122c     	cbnz	w12, 0x8d4 <___pl_fn_3+0x2fc>
     694: aa1403e0     	mov	x0, x20
     698: b940100e     	ldr	w14, [x0, #0x10]
     69c: b940140f     	ldr	w15, [x0, #0x14]
     6a0: 6b0f01df     	cmp	w14, w15
     6a4: 54000aa2     	b.hs	0x7f8 <___pl_fn_3+0x220>
     6a8: aa1503e2     	mov	x2, x21
     6ac: aa1403e0     	mov	x0, x20
     6b0: aa1a03e1     	mov	x1, x26
     6b4: aa1803e3     	mov	x3, x24
     6b8: aa1603e4     	mov	x4, x22
     6bc: 94000000     	bl	0x6bc <___pl_fn_3+0xe4>
     6c0: aa1403e0     	mov	x0, x20
     6c4: b9402c00     	ldr	w0, [x0, #0x2c]
     6c8: 35001060     	cbnz	w0, 0x8d4 <___pl_fn_3+0x2fc>
     6cc: d2800020     	mov	x0, #0x1                ; =1
     6d0: aa1703e2     	mov	x2, x23
     6d4: eb000042     	subs	x2, x2, x0
     6d8: 9a9f77e0     	cset	x0, vs
     6dc: 72001c1f     	tst	w0, #0xff
     6e0: 54000761     	b.ne	0x7cc <___pl_fn_3+0x1f4>
     6e4: aa1403e0     	mov	x0, x20
     6e8: b9401000     	ldr	w0, [x0, #0x10]
     6ec: aa1403e1     	mov	x1, x20
     6f0: b9401421     	ldr	w1, [x1, #0x14]
     6f4: 6b01001f     	cmp	w0, w1
     6f8: 54000542     	b.hs	0x7a0 <___pl_fn_3+0x1c8>
     6fc: aa1a03e1     	mov	x1, x26
     700: aa1803e4     	mov	x4, x24
     704: aa1603e5     	mov	x5, x22
     708: aa1403e0     	mov	x0, x20
     70c: aa1303e3     	mov	x3, x19
     710: 94000000     	bl	0x710 <___pl_fn_3+0x138>
     714: aa1403e0     	mov	x0, x20
     718: b9402c00     	ldr	w0, [x0, #0x2c]
     71c: 35000dc0     	cbnz	w0, 0x8d4 <___pl_fn_3+0x2fc>
     720: 52800020     	mov	w0, #0x1                ; =1
     724: aa1403e1     	mov	x1, x20
     728: 14000013     	b	0x774 <___pl_fn_3+0x19c>
     72c: aa1403e1     	mov	x1, x20
     730: aa0303e2     	mov	x2, x3
     734: aa0403f8     	mov	x24, x4
     738: b9401421     	ldr	w1, [x1, #0x14]
     73c: 11000400     	add	w0, w0, #0x1
     740: 6b01001f     	cmp	w0, w1
     744: 54000d42     	b.hs	0x8ec <___pl_fn_3+0x314>
     748: aa1a03e1     	mov	x1, x26
     74c: aa1803e3     	mov	x3, x24
     750: aa1603e4     	mov	x4, x22
     754: aa1403e0     	mov	x0, x20
     758: 94000000     	bl	0x758 <___pl_fn_3+0x180>
     75c: aa1403e0     	mov	x0, x20
     760: b9402c00     	ldr	w0, [x0, #0x2c]
     764: 35000b80     	cbnz	w0, 0x8d4 <___pl_fn_3+0x2fc>
     768: d2800013     	mov	x19, #0x0               ; =0
     76c: 52800000     	mov	w0, #0x0                ; =0
     770: aa1403e1     	mov	x1, x20
     774: aa1403e1     	mov	x1, x20
     778: b9401020     	ldr	w0, [x1, #0x10]
     77c: 51000400     	sub	w0, w0, #0x1
     780: b9001020     	str	w0, [x1, #0x10]
     784: a8c153f3     	ldp	x19, x20, [sp], #0x10
     788: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     78c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     790: f84107fa     	ldr	x26, [sp], #0x10
     794: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     798: d65f03c0     	ret
     79c: 1400004e     	b	0x8d4 <___pl_fn_3+0x2fc>
     7a0: 528002e1     	mov	w1, #0x17               ; =23
     7a4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7a8: f9400042     	ldr	x2, [x2]
     7ac: aa1403e0     	mov	x0, x20
     7b0: d63f0040     	blr	x2
     7b4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7b8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7bc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7c0: f84107fa     	ldr	x26, [sp], #0x10
     7c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7c8: d65f03c0     	ret
     7cc: 528002c1     	mov	w1, #0x16               ; =22
     7d0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7d4: f9400042     	ldr	x2, [x2]
     7d8: aa1403e0     	mov	x0, x20
     7dc: d63f0040     	blr	x2
     7e0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7e4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7e8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7ec: f84107fa     	ldr	x26, [sp], #0x10
     7f0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7f4: d65f03c0     	ret
     7f8: 528002a1     	mov	w1, #0x15               ; =21
     7fc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     800: f9400042     	ldr	x2, [x2]
     804: aa1403e0     	mov	x0, x20
     808: d63f0040     	blr	x2
     80c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     810: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     814: a8c163f7     	ldp	x23, x24, [sp], #0x10
     818: f84107fa     	ldr	x26, [sp], #0x10
     81c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     820: d65f03c0     	ret
     824: 52800281     	mov	w1, #0x14               ; =20
     828: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     82c: f9400042     	ldr	x2, [x2]
     830: aa1403e0     	mov	x0, x20
     834: d63f0040     	blr	x2
     838: a8c153f3     	ldp	x19, x20, [sp], #0x10
     83c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     840: a8c163f7     	ldp	x23, x24, [sp], #0x10
     844: f84107fa     	ldr	x26, [sp], #0x10
     848: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     84c: d65f03c0     	ret
     850: 52800261     	mov	w1, #0x13               ; =19
     854: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     858: f9400042     	ldr	x2, [x2]
     85c: aa1403e0     	mov	x0, x20
     860: d63f0040     	blr	x2
     864: a8c153f3     	ldp	x19, x20, [sp], #0x10
     868: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     86c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     870: f84107fa     	ldr	x26, [sp], #0x10
     874: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     878: d65f03c0     	ret
     87c: 52800241     	mov	w1, #0x12               ; =18
     880: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     884: f9400042     	ldr	x2, [x2]
     888: aa1403e0     	mov	x0, x20
     88c: d63f0040     	blr	x2
     890: a8c153f3     	ldp	x19, x20, [sp], #0x10
     894: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     898: a8c163f7     	ldp	x23, x24, [sp], #0x10
     89c: f84107fa     	ldr	x26, [sp], #0x10
     8a0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8a4: d65f03c0     	ret
     8a8: 52800221     	mov	w1, #0x11               ; =17
     8ac: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     8b0: f9400042     	ldr	x2, [x2]
     8b4: aa1403e0     	mov	x0, x20
     8b8: d63f0040     	blr	x2
     8bc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8c0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8c4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8c8: f84107fa     	ldr	x26, [sp], #0x10
     8cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8d0: d65f03c0     	ret
     8d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8dc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8e0: f84107fa     	ldr	x26, [sp], #0x10
     8e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8e8: d65f03c0     	ret
     8ec: 52800301     	mov	w1, #0x18               ; =24
     8f0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     8f4: f9400042     	ldr	x2, [x2]
     8f8: aa1403e0     	mov	x0, x20
     8fc: d63f0040     	blr	x2
     900: a8c153f3     	ldp	x19, x20, [sp], #0x10
     904: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     908: a8c163f7     	ldp	x23, x24, [sp], #0x10
     90c: f84107fa     	ldr	x26, [sp], #0x10
     910: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     914: d65f03c0     	ret

0000000000000918 <___pl_fn_4>:
     918: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     91c: 910003fd     	mov	x29, sp
     920: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
     924: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
     928: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     92c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     930: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     934: d10083ff     	sub	sp, sp, #0x20
     938: b9401001     	ldr	w1, [x0, #0x10]
     93c: 11000421     	add	w1, w1, #0x1
     940: b9001001     	str	w1, [x0, #0x10]
     944: aa0003fa     	mov	x26, x0
     948: d2800061     	mov	x1, #0x3                ; =3
     94c: 910003e3     	mov	x3, sp
     950: f80003e1     	stur	x1, [sp]
     954: 52800321     	mov	w1, #0x19               ; =25
     958: 52802082     	mov	w2, #0x104              ; =260
     95c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     960: f9400084     	ldr	x4, [x4]
     964: aa1a03e0     	mov	x0, x26
     968: d63f0080     	blr	x4
     96c: 350040c0     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     970: aa1a03e0     	mov	x0, x26
     974: f9401813     	ldr	x19, [x0, #0x30]
     978: 52800341     	mov	w1, #0x1a               ; =26
     97c: 52800082     	mov	w2, #0x4                ; =4
     980: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     984: f9400084     	ldr	x4, [x4]
     988: d63f0080     	blr	x4
     98c: 35003fc0     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     990: aa1a03e0     	mov	x0, x26
     994: f9401814     	ldr	x20, [x0, #0x30]
     998: 52800361     	mov	w1, #0x1b               ; =27
     99c: 2a1303e3     	mov	w3, w19
     9a0: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     9a4: f94000c6     	ldr	x6, [x6]
     9a8: aa1403e2     	mov	x2, x20
     9ac: d63f00c0     	blr	x6
     9b0: aa1403fb     	mov	x27, x20
     9b4: 35003e80     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     9b8: 52800381     	mov	w1, #0x1c               ; =28
     9bc: 52800002     	mov	w2, #0x0                ; =0
     9c0: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     9c4: f9400108     	ldr	x8, [x8]
     9c8: aa1a03e0     	mov	x0, x26
     9cc: d63f0100     	blr	x8
     9d0: 35003da0     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     9d4: aa1a03e0     	mov	x0, x26
     9d8: f9401802     	ldr	x2, [x0, #0x30]
     9dc: f80183e2     	stur	x2, [sp, #0x18]
     9e0: 528003a1     	mov	w1, #0x1d               ; =29
     9e4: 52800002     	mov	w2, #0x0                ; =0
     9e8: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     9ec: f940014a     	ldr	x10, [x10]
     9f0: d63f0140     	blr	x10
     9f4: 35003c80     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     9f8: aa1a03e0     	mov	x0, x26
     9fc: f9401802     	ldr	x2, [x0, #0x30]
     a00: aa0203f8     	mov	x24, x2
     a04: d280004c     	mov	x12, #0x2               ; =2
     a08: d280000d     	mov	x13, #0x0               ; =0
     a0c: ab0d0193     	adds	x19, x12, x13
     a10: 9a9f77ed     	cset	x13, vs
     a14: 72001dbf     	tst	w13, #0xff
     a18: 540039c1     	b.ne	0x1150 <___pl_fn_4+0x838>
     a1c: d280002e     	mov	x14, #0x1               ; =1
     a20: d280000f     	mov	x15, #0x0               ; =0
     a24: ab0f01d4     	adds	x20, x14, x15
     a28: 9a9f77ef     	cset	x15, vs
     a2c: 72001dff     	tst	w15, #0xff
     a30: 54003761     	b.ne	0x111c <___pl_fn_4+0x804>
     a34: b40035b4     	cbz	x20, 0x10e8 <___pl_fn_4+0x7d0>
     a38: d2800015     	mov	x21, #0x0               ; =0
     a3c: 52800020     	mov	w0, #0x1                ; =1
     a40: f100029f     	cmp	x20, #0x0
     a44: 5400008a     	b.ge	0xa54 <___pl_fn_4+0x13c>
     a48: eb1302bf     	cmp	x21, x19
     a4c: 9a9fb7e1     	cset	x1, ge
     a50: 14000003     	b	0xa5c <___pl_fn_4+0x144>
     a54: eb1302bf     	cmp	x21, x19
     a58: 9a9fc7e1     	cset	x1, le
     a5c: 72001c3f     	tst	w1, #0xff
     a60: 54001201     	b.ne	0xca0 <___pl_fn_4+0x388>
     a64: d2800020     	mov	x0, #0x1                ; =1
     a68: d2800001     	mov	x1, #0x0                ; =0
     a6c: ab010019     	adds	x25, x0, x1
     a70: 9a9f77e0     	cset	x0, vs
     a74: 72001c1f     	tst	w0, #0xff
     a78: 540029e1     	b.ne	0xfb4 <___pl_fn_4+0x69c>
     a7c: d2800000     	mov	x0, #0x0                ; =0
     a80: d2800021     	mov	x1, #0x1                ; =1
     a84: eb010000     	subs	x0, x0, x1
     a88: 9a9f77e1     	cset	x1, vs
     a8c: 72001c3f     	tst	w1, #0xff
     a90: 54002781     	b.ne	0xf80 <___pl_fn_4+0x668>
     a94: d2800001     	mov	x1, #0x0                ; =0
     a98: ab010013     	adds	x19, x0, x1
     a9c: 9a9f77e0     	cset	x0, vs
     aa0: 72001c1f     	tst	w0, #0xff
     aa4: 54002541     	b.ne	0xf4c <___pl_fn_4+0x634>
     aa8: b4002393     	cbz	x19, 0xf18 <___pl_fn_4+0x600>
     aac: 5280003c     	mov	w28, #0x1               ; =1
     ab0: aa1803f4     	mov	x20, x24
     ab4: f100027f     	cmp	x19, #0x0
     ab8: 5400008a     	b.ge	0xac8 <___pl_fn_4+0x1b0>
     abc: eb19029f     	cmp	x20, x25
     ac0: 9a9fb7e0     	cset	x0, ge
     ac4: 14000003     	b	0xad0 <___pl_fn_4+0x1b8>
     ac8: eb19029f     	cmp	x20, x25
     acc: 9a9fc7e0     	cset	x0, le
     ad0: 72001c1f     	tst	w0, #0xff
     ad4: 540006a1     	b.ne	0xba8 <___pl_fn_4+0x290>
     ad8: 528004a1     	mov	w1, #0x25               ; =37
     adc: d2800003     	mov	x3, #0x0                ; =0
     ae0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     ae4: f9400084     	ldr	x4, [x4]
     ae8: aa1a03e0     	mov	x0, x26
     aec: f84183e2     	ldur	x2, [sp, #0x18]
     af0: d63f0080     	blr	x4
     af4: 35003480     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     af8: aa1a03e0     	mov	x0, x26
     afc: b9401000     	ldr	w0, [x0, #0x10]
     b00: aa1a03e1     	mov	x1, x26
     b04: b9401421     	ldr	w1, [x1, #0x14]
     b08: 6b01001f     	cmp	w0, w1
     b0c: 540014e2     	b.hs	0xda8 <___pl_fn_4+0x490>
     b10: d2800003     	mov	x3, #0x0                ; =0
     b14: d2800024     	mov	x4, #0x1                ; =1
     b18: aa1b03e1     	mov	x1, x27
     b1c: aa1803e2     	mov	x2, x24
     b20: aa1a03e0     	mov	x0, x26
     b24: f84183e5     	ldur	x5, [sp, #0x18]
     b28: 94000000     	bl	0xb28 <___pl_fn_4+0x210>
     b2c: aa1a03e0     	mov	x0, x26
     b30: b9402c00     	ldr	w0, [x0, #0x2c]
     b34: 35003280     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     b38: 528004e1     	mov	w1, #0x27               ; =39
     b3c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b40: f9400063     	ldr	x3, [x3]
     b44: f84183e2     	ldur	x2, [sp, #0x18]
     b48: aa1a03e0     	mov	x0, x26
     b4c: d63f0060     	blr	x3
     b50: 350031a0     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     b54: aa1a03e0     	mov	x0, x26
     b58: f9401802     	ldr	x2, [x0, #0x30]
     b5c: 52800501     	mov	w1, #0x28               ; =40
     b60: 52802003     	mov	w3, #0x100              ; =256
     b64: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b68: f9400084     	ldr	x4, [x4]
     b6c: d63f0080     	blr	x4
     b70: 350030a0     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     b74: aa1a03e0     	mov	x0, x26
     b78: b9401000     	ldr	w0, [x0, #0x10]
     b7c: 51000400     	sub	w0, w0, #0x1
     b80: aa1a03ed     	mov	x13, x26
     b84: b90011a0     	str	w0, [x13, #0x10]
     b88: 910083ff     	add	sp, sp, #0x20
     b8c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b90: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b94: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b98: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b9c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ba0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ba4: d65f03c0     	ret
     ba8: 52800521     	mov	w1, #0x29               ; =41
     bac: 52800002     	mov	w2, #0x0                ; =0
     bb0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     bb4: f9400063     	ldr	x3, [x3]
     bb8: aa1a03e0     	mov	x0, x26
     bbc: d63f0060     	blr	x3
     bc0: 35002e20     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     bc4: aa1a03e0     	mov	x0, x26
     bc8: f9401817     	ldr	x23, [x0, #0x30]
     bcc: b9401815     	ldr	w21, [x0, #0x18]
     bd0: b9401c00     	ldr	w0, [x0, #0x1c]
     bd4: 110006b6     	add	w22, w21, #0x1
     bd8: 6b0002df     	cmp	w22, w0
     bdc: 54001848     	b.hi	0xee4 <___pl_fn_4+0x5cc>
     be0: aa1a03e0     	mov	x0, x26
     be4: f9401000     	ldr	x0, [x0, #0x20]
     be8: b8355817     	str	w23, [x0, w21, uxtw #2]
     bec: aa1a03e0     	mov	x0, x26
     bf0: b9001816     	str	w22, [x0, #0x18]
     bf4: b9401000     	ldr	w0, [x0, #0x10]
     bf8: aa1a03e1     	mov	x1, x26
     bfc: b9401421     	ldr	w1, [x1, #0x14]
     c00: 6b01001f     	cmp	w0, w1
     c04: 54001562     	b.hs	0xeb0 <___pl_fn_4+0x598>
     c08: 72001f9f     	tst	w28, #0xff
     c0c: 54001380     	b.eq	0xe7c <___pl_fn_4+0x564>
     c10: aa1a03e0     	mov	x0, x26
     c14: aa1703e1     	mov	x1, x23
     c18: aa1403e2     	mov	x2, x20
     c1c: 94000000     	bl	0xc1c <___pl_fn_4+0x304>
     c20: aa1a03e0     	mov	x0, x26
     c24: aa1703e3     	mov	x3, x23
     c28: b9402c04     	ldr	w4, [x0, #0x2c]
     c2c: 35002ac4     	cbnz	w4, 0x1184 <___pl_fn_4+0x86c>
     c30: aa1a03e0     	mov	x0, x26
     c34: b9001815     	str	w21, [x0, #0x18]
     c38: b9401c07     	ldr	w7, [x0, #0x1c]
     c3c: 6b0702df     	cmp	w22, w7
     c40: 54001048     	b.hi	0xe48 <___pl_fn_4+0x530>
     c44: aa1a03e0     	mov	x0, x26
     c48: f9401009     	ldr	x9, [x0, #0x20]
     c4c: b8355923     	str	w3, [x9, w21, uxtw #2]
     c50: b9001816     	str	w22, [x0, #0x18]
     c54: b940100b     	ldr	w11, [x0, #0x10]
     c58: b940140c     	ldr	w12, [x0, #0x14]
     c5c: 6b0c017f     	cmp	w11, w12
     c60: 54000da2     	b.hs	0xe14 <___pl_fn_4+0x4fc>
     c64: d2800002     	mov	x2, #0x0                ; =0
     c68: aa1a03e0     	mov	x0, x26
     c6c: aa1b03e1     	mov	x1, x27
     c70: 94000000     	bl	0xc70 <___pl_fn_4+0x358>
     c74: aa1a03e0     	mov	x0, x26
     c78: b9402c0e     	ldr	w14, [x0, #0x2c]
     c7c: 3500284e     	cbnz	w14, 0x1184 <___pl_fn_4+0x86c>
     c80: aa1a03e0     	mov	x0, x26
     c84: b9001815     	str	w21, [x0, #0x18]
     c88: ab130294     	adds	x20, x20, x19
     c8c: 9a9f77e0     	cset	x0, vs
     c90: 72001c1f     	tst	w0, #0xff
     c94: 54000a61     	b.ne	0xde0 <___pl_fn_4+0x4c8>
     c98: 5280003c     	mov	w28, #0x1               ; =1
     c9c: 17ffff86     	b	0xab4 <___pl_fn_4+0x19c>
     ca0: d2800020     	mov	x0, #0x1                ; =1
     ca4: aa1803f6     	mov	x22, x24
     ca8: ab0002c2     	adds	x2, x22, x0
     cac: aa0203f9     	mov	x25, x2
     cb0: 9a9f77e0     	cset	x0, vs
     cb4: 72001c1f     	tst	w0, #0xff
     cb8: 54001fe1     	b.ne	0x10b4 <___pl_fn_4+0x79c>
     cbc: 52800621     	mov	w1, #0x31               ; =49
     cc0: 52800002     	mov	w2, #0x0                ; =0
     cc4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     cc8: f9400063     	ldr	x3, [x3]
     ccc: aa1a03e0     	mov	x0, x26
     cd0: d63f0060     	blr	x3
     cd4: 35002580     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     cd8: aa1a03e0     	mov	x0, x26
     cdc: f9401817     	ldr	x23, [x0, #0x30]
     ce0: b9401818     	ldr	w24, [x0, #0x18]
     ce4: b9401c01     	ldr	w1, [x0, #0x1c]
     ce8: 11000700     	add	w0, w24, #0x1
     cec: 6b01001f     	cmp	w0, w1
     cf0: 54001c88     	b.hi	0x1080 <___pl_fn_4+0x768>
     cf4: aa1a03e1     	mov	x1, x26
     cf8: f9401021     	ldr	x1, [x1, #0x20]
     cfc: b8385837     	str	w23, [x1, w24, uxtw #2]
     d00: aa1a03e1     	mov	x1, x26
     d04: b9001820     	str	w0, [x1, #0x18]
     d08: aa1a03e0     	mov	x0, x26
     d0c: b9401000     	ldr	w0, [x0, #0x10]
     d10: b9401421     	ldr	w1, [x1, #0x14]
     d14: 6b01001f     	cmp	w0, w1
     d18: 540019a2     	b.hs	0x104c <___pl_fn_4+0x734>
     d1c: aa1903e2     	mov	x2, x25
     d20: aa1a03e0     	mov	x0, x26
     d24: aa1703e1     	mov	x1, x23
     d28: 94000000     	bl	0xd28 <___pl_fn_4+0x410>
     d2c: aa1a03e0     	mov	x0, x26
     d30: b9402c00     	ldr	w0, [x0, #0x2c]
     d34: 35002280     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     d38: aa1a03e0     	mov	x0, x26
     d3c: b9001818     	str	w24, [x0, #0x18]
     d40: 52800681     	mov	w1, #0x34               ; =52
     d44: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     d48: f9400063     	ldr	x3, [x3]
     d4c: aa1b03e2     	mov	x2, x27
     d50: d63f0060     	blr	x3
     d54: 35002180     	cbnz	w0, 0x1184 <___pl_fn_4+0x86c>
     d58: aa1a03e0     	mov	x0, x26
     d5c: f9401802     	ldr	x2, [x0, #0x30]
     d60: 34001462     	cbz	w2, 0xfec <___pl_fn_4+0x6d4>
     d64: aa1a03e0     	mov	x0, x26
     d68: f9400000     	ldr	x0, [x0]
     d6c: 2a0203e1     	mov	w1, w2
     d70: 8b010c00     	add	x0, x0, x1, lsl #3
     d74: f9400801     	ldr	x1, [x0, #0x10]
     d78: eb0102bf     	cmp	x21, x1
     d7c: 54001382     	b.hs	0xfec <___pl_fn_4+0x6d4>
     d80: 2a1703e1     	mov	w1, w23
     d84: 8b150c00     	add	x0, x0, x21, lsl #3
     d88: f9001401     	str	x1, [x0, #0x28]
     d8c: ab1402b5     	adds	x21, x21, x20
     d90: 9a9f77e0     	cset	x0, vs
     d94: 72001c1f     	tst	w0, #0xff
     d98: 54001401     	b.ne	0x1018 <___pl_fn_4+0x700>
     d9c: 52800020     	mov	w0, #0x1                ; =1
     da0: aa1603f8     	mov	x24, x22
     da4: 17ffff27     	b	0xa40 <___pl_fn_4+0x128>
     da8: 528004c1     	mov	w1, #0x26               ; =38
     dac: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     db0: f9400042     	ldr	x2, [x2]
     db4: aa1a03e0     	mov	x0, x26
     db8: d63f0040     	blr	x2
     dbc: 910083ff     	add	sp, sp, #0x20
     dc0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     dc4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     dc8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     dcc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     dd0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     dd4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     dd8: d65f03c0     	ret
     ddc: 140000ea     	b	0x1184 <___pl_fn_4+0x86c>
     de0: 528005e1     	mov	w1, #0x2f               ; =47
     de4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     de8: f9400042     	ldr	x2, [x2]
     dec: aa1a03e0     	mov	x0, x26
     df0: d63f0040     	blr	x2
     df4: 910083ff     	add	sp, sp, #0x20
     df8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     dfc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e00: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e04: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e08: a8c173fb     	ldp	x27, x28, [sp], #0x10
     e0c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e10: d65f03c0     	ret
     e14: 528005c1     	mov	w1, #0x2e               ; =46
     e18: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e1c: f9400042     	ldr	x2, [x2]
     e20: aa1a03e0     	mov	x0, x26
     e24: d63f0040     	blr	x2
     e28: 910083ff     	add	sp, sp, #0x20
     e2c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e30: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e34: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e38: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e3c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     e40: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e44: d65f03c0     	ret
     e48: 528005a1     	mov	w1, #0x2d               ; =45
     e4c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e50: f9400042     	ldr	x2, [x2]
     e54: aa1a03e0     	mov	x0, x26
     e58: d63f0040     	blr	x2
     e5c: 910083ff     	add	sp, sp, #0x20
     e60: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e64: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e68: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e6c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e70: a8c173fb     	ldp	x27, x28, [sp], #0x10
     e74: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e78: d65f03c0     	ret
     e7c: 52800581     	mov	w1, #0x2c               ; =44
     e80: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e84: f9400042     	ldr	x2, [x2]
     e88: aa1a03e0     	mov	x0, x26
     e8c: d63f0040     	blr	x2
     e90: 910083ff     	add	sp, sp, #0x20
     e94: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e98: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e9c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ea0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     ea4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ea8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     eac: d65f03c0     	ret
     eb0: 52800561     	mov	w1, #0x2b               ; =43
     eb4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     eb8: f9400042     	ldr	x2, [x2]
     ebc: aa1a03e0     	mov	x0, x26
     ec0: d63f0040     	blr	x2
     ec4: 910083ff     	add	sp, sp, #0x20
     ec8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ecc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ed0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ed4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     ed8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     edc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ee0: d65f03c0     	ret
     ee4: 52800541     	mov	w1, #0x2a               ; =42
     ee8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     eec: f9400042     	ldr	x2, [x2]
     ef0: aa1a03e0     	mov	x0, x26
     ef4: d63f0040     	blr	x2
     ef8: 910083ff     	add	sp, sp, #0x20
     efc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f00: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     f04: a8c163f7     	ldp	x23, x24, [sp], #0x10
     f08: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     f0c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     f10: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f14: d65f03c0     	ret
     f18: 52800481     	mov	w1, #0x24               ; =36
     f1c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     f20: f9400042     	ldr	x2, [x2]
     f24: aa1a03e0     	mov	x0, x26
     f28: d63f0040     	blr	x2
     f2c: 910083ff     	add	sp, sp, #0x20
     f30: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f34: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     f38: a8c163f7     	ldp	x23, x24, [sp], #0x10
     f3c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     f40: a8c173fb     	ldp	x27, x28, [sp], #0x10
     f44: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f48: d65f03c0     	ret
     f4c: 52800461     	mov	w1, #0x23               ; =35
     f50: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     f54: f9400042     	ldr	x2, [x2]
     f58: aa1a03e0     	mov	x0, x26
     f5c: d63f0040     	blr	x2
     f60: 910083ff     	add	sp, sp, #0x20
     f64: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f68: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     f6c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     f70: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     f74: a8c173fb     	ldp	x27, x28, [sp], #0x10
     f78: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f7c: d65f03c0     	ret
     f80: 52800441     	mov	w1, #0x22               ; =34
     f84: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     f88: f9400042     	ldr	x2, [x2]
     f8c: aa1a03e0     	mov	x0, x26
     f90: d63f0040     	blr	x2
     f94: 910083ff     	add	sp, sp, #0x20
     f98: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f9c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     fa0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     fa4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     fa8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     fac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     fb0: d65f03c0     	ret
     fb4: 52800421     	mov	w1, #0x21               ; =33
     fb8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     fbc: f9400042     	ldr	x2, [x2]
     fc0: aa1a03e0     	mov	x0, x26
     fc4: d63f0040     	blr	x2
     fc8: 910083ff     	add	sp, sp, #0x20
     fcc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     fd0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     fd4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     fd8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     fdc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     fe0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     fe4: d65f03c0     	ret
     fe8: 14000067     	b	0x1184 <___pl_fn_4+0x86c>
     fec: 910023e3     	add	x3, sp, #0x8
     ff0: f80083f5     	stur	x21, [sp, #0x8]
     ff4: 2a1703e0     	mov	w0, w23
     ff8: f80103e0     	stur	x0, [sp, #0x10]
     ffc: 528006a1     	mov	w1, #0x35               ; =53
    1000: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x6e8>
    1004: f9400084     	ldr	x4, [x4]
    1008: aa1a03e0     	mov	x0, x26
    100c: d63f0080     	blr	x4
    1010: 34ffebe0     	cbz	w0, 0xd8c <___pl_fn_4+0x474>
    1014: 1400005c     	b	0x1184 <___pl_fn_4+0x86c>
    1018: 528006c1     	mov	w1, #0x36               ; =54
    101c: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x6e8>
    1020: f9400042     	ldr	x2, [x2]
    1024: aa1a03e0     	mov	x0, x26
    1028: d63f0040     	blr	x2
    102c: 910083ff     	add	sp, sp, #0x20
    1030: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1034: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1038: a8c163f7     	ldp	x23, x24, [sp], #0x10
    103c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1040: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1044: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1048: d65f03c0     	ret
    104c: 52800661     	mov	w1, #0x33               ; =51
    1050: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x6e8>
    1054: f9400042     	ldr	x2, [x2]
    1058: aa1a03e0     	mov	x0, x26
    105c: d63f0040     	blr	x2
    1060: 910083ff     	add	sp, sp, #0x20
    1064: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1068: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    106c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1070: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1074: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1078: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    107c: d65f03c0     	ret
    1080: 52800641     	mov	w1, #0x32               ; =50
    1084: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x6e8>
    1088: f9400042     	ldr	x2, [x2]
    108c: aa1a03e0     	mov	x0, x26
    1090: d63f0040     	blr	x2
    1094: 910083ff     	add	sp, sp, #0x20
    1098: a8c153f3     	ldp	x19, x20, [sp], #0x10
    109c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    10a0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    10a4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    10a8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    10ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    10b0: d65f03c0     	ret
    10b4: 52800601     	mov	w1, #0x30               ; =48
    10b8: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x6e8>
    10bc: f9400042     	ldr	x2, [x2]
    10c0: aa1a03e0     	mov	x0, x26
    10c4: d63f0040     	blr	x2
    10c8: 910083ff     	add	sp, sp, #0x20
    10cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    10d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    10d4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    10d8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    10dc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    10e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    10e4: d65f03c0     	ret
    10e8: 52800401     	mov	w1, #0x20               ; =32
    10ec: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x6e8>
    10f0: f9400042     	ldr	x2, [x2]
    10f4: aa1a03e0     	mov	x0, x26
    10f8: d63f0040     	blr	x2
    10fc: 910083ff     	add	sp, sp, #0x20
    1100: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1104: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1108: a8c163f7     	ldp	x23, x24, [sp], #0x10
    110c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1110: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1114: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1118: d65f03c0     	ret
    111c: 528003e1     	mov	w1, #0x1f               ; =31
    1120: 90000003     	adrp	x3, 0x1000 <___pl_fn_4+0x6e8>
    1124: f9400063     	ldr	x3, [x3]
    1128: aa1a03e0     	mov	x0, x26
    112c: d63f0060     	blr	x3
    1130: 910083ff     	add	sp, sp, #0x20
    1134: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1138: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    113c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1140: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1144: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1148: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    114c: d65f03c0     	ret
    1150: 528003c1     	mov	w1, #0x1e               ; =30
    1154: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x6e8>
    1158: f9400084     	ldr	x4, [x4]
    115c: aa1a03e0     	mov	x0, x26
    1160: d63f0080     	blr	x4
    1164: 910083ff     	add	sp, sp, #0x20
    1168: a8c153f3     	ldp	x19, x20, [sp], #0x10
    116c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1170: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1174: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1178: a8c173fb     	ldp	x27, x28, [sp], #0x10
    117c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1180: d65f03c0     	ret
    1184: 910083ff     	add	sp, sp, #0x20
    1188: a8c153f3     	ldp	x19, x20, [sp], #0x10
    118c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1190: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1194: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1198: a8c173fb     	ldp	x27, x28, [sp], #0x10
    119c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11a0: d65f03c0     	ret

00000000000011a4 <___pl_fn_5>:
    11a4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    11a8: 910003fd     	mov	x29, sp
    11ac: f81f0ff3     	str	x19, [sp, #-0x10]!
    11b0: d10043ff     	sub	sp, sp, #0x10
    11b4: b9401003     	ldr	w3, [x0, #0x10]
    11b8: 11000463     	add	w3, w3, #0x1
    11bc: b9001003     	str	w3, [x0, #0x10]
    11c0: aa0003e5     	mov	x5, x0
    11c4: 34000321     	cbz	w1, 0x1228 <___pl_fn_5+0x84>
    11c8: aa0503f3     	mov	x19, x5
    11cc: aa0203e3     	mov	x3, x2
    11d0: aa0103e2     	mov	x2, x1
    11d4: f9400261     	ldr	x1, [x19]
    11d8: 2a0203e0     	mov	w0, w2
    11dc: 8b000c20     	add	x0, x1, x0, lsl #3
    11e0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    11e4: d360fc21     	lsr	x1, x1, #32
    11e8: 92403c22     	and	x2, x1, #0xffff
    11ec: f100085f     	cmp	x2, #0x2
    11f0: 54000080     	b.eq	0x1200 <___pl_fn_5+0x5c>
    11f4: f9400802     	ldr	x2, [x0, #0x10]
    11f8: 927ff842     	and	x2, x2, #0xfffffffffffffffe
    11fc: f9000802     	str	x2, [x0, #0x10]
    1200: 92403c21     	and	x1, x1, #0xffff
    1204: aa0303e2     	mov	x2, x3
    1208: f8217802     	str	x2, [x0, x1, lsl #3]
    120c: b9401260     	ldr	w0, [x19, #0x10]
    1210: 51000400     	sub	w0, w0, #0x1
    1214: b9001260     	str	w0, [x19, #0x10]
    1218: 910043ff     	add	sp, sp, #0x10
    121c: f84107f3     	ldr	x19, [sp], #0x10
    1220: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1224: d65f03c0     	ret
    1228: aa0103e6     	mov	x6, x1
    122c: d2800000     	mov	x0, #0x0                ; =0
    1230: 910003e3     	mov	x3, sp
    1234: f80003e0     	stur	x0, [sp]
    1238: f80083e2     	stur	x2, [sp, #0x8]
    123c: 528006e1     	mov	w1, #0x37               ; =55
    1240: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x6e8>
    1244: f9400084     	ldr	x4, [x4]
    1248: aa0603e2     	mov	x2, x6
    124c: aa0503f3     	mov	x19, x5
    1250: aa1303e0     	mov	x0, x19
    1254: d63f0080     	blr	x4
    1258: 34fffda0     	cbz	w0, 0x120c <___pl_fn_5+0x68>
    125c: 910043ff     	add	sp, sp, #0x10
    1260: f84107f3     	ldr	x19, [sp], #0x10
    1264: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1268: d65f03c0     	ret
