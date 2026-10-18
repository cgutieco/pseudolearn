
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_58173/towers/program.o:	file format mach-o arm64

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
     934: d100c3ff     	sub	sp, sp, #0x30
     938: b9401006     	ldr	w6, [x0, #0x10]
     93c: 110004c6     	add	w6, w6, #0x1
     940: b9001006     	str	w6, [x0, #0x10]
     944: aa0003fa     	mov	x26, x0
     948: 52800321     	mov	w1, #0x19               ; =25
     94c: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     950: f94000e7     	ldr	x7, [x7]
     954: d63f00e0     	blr	x7
     958: 35004320     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     95c: aa1a03e0     	mov	x0, x26
     960: f9401802     	ldr	x2, [x0, #0x30]
     964: aa0203fb     	mov	x27, x2
     968: d280006a     	mov	x10, #0x3               ; =3
     96c: 910003e3     	mov	x3, sp
     970: f80003ea     	stur	x10, [sp]
     974: 52800341     	mov	w1, #0x1a               ; =26
     978: 52802082     	mov	w2, #0x104              ; =260
     97c: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     980: f940016b     	ldr	x11, [x11]
     984: aa1a03e0     	mov	x0, x26
     988: d63f0160     	blr	x11
     98c: 35004180     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     990: aa1a03e0     	mov	x0, x26
     994: f9401813     	ldr	x19, [x0, #0x30]
     998: 52800361     	mov	w1, #0x1b               ; =27
     99c: 52800082     	mov	w2, #0x4                ; =4
     9a0: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     9a4: f94001ad     	ldr	x13, [x13]
     9a8: d63f01a0     	blr	x13
     9ac: 35004080     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     9b0: aa1a03e0     	mov	x0, x26
     9b4: f9401814     	ldr	x20, [x0, #0x30]
     9b8: 52800381     	mov	w1, #0x1c               ; =28
     9bc: 2a1303e3     	mov	w3, w19
     9c0: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     9c4: f94001ef     	ldr	x15, [x15]
     9c8: aa1403e2     	mov	x2, x20
     9cc: d63f01e0     	blr	x15
     9d0: aa1403fc     	mov	x28, x20
     9d4: 35003f40     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     9d8: 528003a1     	mov	w1, #0x1d               ; =29
     9dc: 52800002     	mov	w2, #0x0                ; =0
     9e0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     9e4: f9400063     	ldr	x3, [x3]
     9e8: aa1a03e0     	mov	x0, x26
     9ec: d63f0060     	blr	x3
     9f0: 35003e60     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     9f4: aa1a03e0     	mov	x0, x26
     9f8: f9401802     	ldr	x2, [x0, #0x30]
     9fc: f80203e2     	stur	x2, [sp, #0x20]
     a00: 528003c1     	mov	w1, #0x1e               ; =30
     a04: 52800002     	mov	w2, #0x0                ; =0
     a08: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     a0c: f9400063     	ldr	x3, [x3]
     a10: d63f0060     	blr	x3
     a14: 35003d40     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     a18: aa1a03e0     	mov	x0, x26
     a1c: f9401802     	ldr	x2, [x0, #0x30]
     a20: f80183e2     	stur	x2, [sp, #0x18]
     a24: d2800040     	mov	x0, #0x2                ; =2
     a28: d2800001     	mov	x1, #0x0                ; =0
     a2c: ab010014     	adds	x20, x0, x1
     a30: 9a9f77e0     	cset	x0, vs
     a34: 72001c1f     	tst	w0, #0xff
     a38: 54003a81     	b.ne	0x1188 <___pl_fn_4+0x870>
     a3c: d2800020     	mov	x0, #0x1                ; =1
     a40: d2800001     	mov	x1, #0x0                ; =0
     a44: ab010016     	adds	x22, x0, x1
     a48: 9a9f77e0     	cset	x0, vs
     a4c: 72001c1f     	tst	w0, #0xff
     a50: 54003821     	b.ne	0x1154 <___pl_fn_4+0x83c>
     a54: b4003676     	cbz	x22, 0x1120 <___pl_fn_4+0x808>
     a58: d2800013     	mov	x19, #0x0               ; =0
     a5c: 52800021     	mov	w1, #0x1                ; =1
     a60: f10002df     	cmp	x22, #0x0
     a64: 5400008a     	b.ge	0xa74 <___pl_fn_4+0x15c>
     a68: eb14027f     	cmp	x19, x20
     a6c: 9a9fb7e7     	cset	x7, ge
     a70: 14000003     	b	0xa7c <___pl_fn_4+0x164>
     a74: eb14027f     	cmp	x19, x20
     a78: 9a9fc7e7     	cset	x7, le
     a7c: 72001cff     	tst	w7, #0xff
     a80: 540012c1     	b.ne	0xcd8 <___pl_fn_4+0x3c0>
     a84: d2800020     	mov	x0, #0x1                ; =1
     a88: d2800001     	mov	x1, #0x0                ; =0
     a8c: ab010013     	adds	x19, x0, x1
     a90: 9a9f77e0     	cset	x0, vs
     a94: 72001c1f     	tst	w0, #0xff
     a98: 54002aa1     	b.ne	0xfec <___pl_fn_4+0x6d4>
     a9c: d2800000     	mov	x0, #0x0                ; =0
     aa0: d2800021     	mov	x1, #0x1                ; =1
     aa4: eb010000     	subs	x0, x0, x1
     aa8: 9a9f77e1     	cset	x1, vs
     aac: 72001c3f     	tst	w1, #0xff
     ab0: 54002841     	b.ne	0xfb8 <___pl_fn_4+0x6a0>
     ab4: d2800001     	mov	x1, #0x0                ; =0
     ab8: ab010014     	adds	x20, x0, x1
     abc: 9a9f77e0     	cset	x0, vs
     ac0: 72001c1f     	tst	w0, #0xff
     ac4: 54002601     	b.ne	0xf84 <___pl_fn_4+0x66c>
     ac8: b4002454     	cbz	x20, 0xf50 <___pl_fn_4+0x638>
     acc: 52800037     	mov	w23, #0x1               ; =1
     ad0: f84183f5     	ldur	x21, [sp, #0x18]
     ad4: f100029f     	cmp	x20, #0x0
     ad8: 5400008a     	b.ge	0xae8 <___pl_fn_4+0x1d0>
     adc: eb1302bf     	cmp	x21, x19
     ae0: 9a9fb7e0     	cset	x0, ge
     ae4: 14000003     	b	0xaf0 <___pl_fn_4+0x1d8>
     ae8: eb1302bf     	cmp	x21, x19
     aec: 9a9fc7e0     	cset	x0, le
     af0: 72001c1f     	tst	w0, #0xff
     af4: 54000761     	b.ne	0xbe0 <___pl_fn_4+0x2c8>
     af8: 528004c1     	mov	w1, #0x26               ; =38
     afc: d2800003     	mov	x3, #0x0                ; =0
     b00: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b04: f9400084     	ldr	x4, [x4]
     b08: aa1a03e0     	mov	x0, x26
     b0c: f84203e2     	ldur	x2, [sp, #0x20]
     b10: d63f0080     	blr	x4
     b14: 35003540     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     b18: aa1a03e0     	mov	x0, x26
     b1c: b9401000     	ldr	w0, [x0, #0x10]
     b20: aa1a03e1     	mov	x1, x26
     b24: b9401421     	ldr	w1, [x1, #0x14]
     b28: 6b01001f     	cmp	w0, w1
     b2c: 540015a2     	b.hs	0xde0 <___pl_fn_4+0x4c8>
     b30: d2800003     	mov	x3, #0x0                ; =0
     b34: d2800024     	mov	x4, #0x1                ; =1
     b38: aa1c03e1     	mov	x1, x28
     b3c: f84183e2     	ldur	x2, [sp, #0x18]
     b40: aa1a03e0     	mov	x0, x26
     b44: f84203e5     	ldur	x5, [sp, #0x20]
     b48: 94000000     	bl	0xb48 <___pl_fn_4+0x230>
     b4c: aa1a03e0     	mov	x0, x26
     b50: b9402c00     	ldr	w0, [x0, #0x2c]
     b54: 35003340     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     b58: 52800501     	mov	w1, #0x28               ; =40
     b5c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b60: f9400063     	ldr	x3, [x3]
     b64: f84203e2     	ldur	x2, [sp, #0x20]
     b68: aa1a03e0     	mov	x0, x26
     b6c: d63f0060     	blr	x3
     b70: 35003260     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     b74: aa1a03e0     	mov	x0, x26
     b78: f9401802     	ldr	x2, [x0, #0x30]
     b7c: 52800521     	mov	w1, #0x29               ; =41
     b80: 52802003     	mov	w3, #0x100              ; =256
     b84: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b88: f9400084     	ldr	x4, [x4]
     b8c: d63f0080     	blr	x4
     b90: 35003160     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     b94: 52800541     	mov	w1, #0x2a               ; =42
     b98: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b9c: f9400063     	ldr	x3, [x3]
     ba0: aa1b03e2     	mov	x2, x27
     ba4: aa1a03e0     	mov	x0, x26
     ba8: d63f0060     	blr	x3
     bac: 35003080     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     bb0: aa1a03e0     	mov	x0, x26
     bb4: b9401001     	ldr	w1, [x0, #0x10]
     bb8: 51000421     	sub	w1, w1, #0x1
     bbc: b9001001     	str	w1, [x0, #0x10]
     bc0: 9100c3ff     	add	sp, sp, #0x30
     bc4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     bc8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     bcc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     bd0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     bd4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     bd8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     bdc: d65f03c0     	ret
     be0: 52800561     	mov	w1, #0x2b               ; =43
     be4: 52800002     	mov	w2, #0x0                ; =0
     be8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     bec: f9400084     	ldr	x4, [x4]
     bf0: aa1a03e0     	mov	x0, x26
     bf4: d63f0080     	blr	x4
     bf8: 35002e20     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     bfc: aa1a03e0     	mov	x0, x26
     c00: f9401819     	ldr	x25, [x0, #0x30]
     c04: b9401816     	ldr	w22, [x0, #0x18]
     c08: b9401c06     	ldr	w6, [x0, #0x1c]
     c0c: 110006d8     	add	w24, w22, #0x1
     c10: 6b06031f     	cmp	w24, w6
     c14: 54001848     	b.hi	0xf1c <___pl_fn_4+0x604>
     c18: aa1a03e0     	mov	x0, x26
     c1c: f9401008     	ldr	x8, [x0, #0x20]
     c20: b8365919     	str	w25, [x8, w22, uxtw #2]
     c24: b9001818     	str	w24, [x0, #0x18]
     c28: b940100a     	ldr	w10, [x0, #0x10]
     c2c: b940140b     	ldr	w11, [x0, #0x14]
     c30: 6b0b015f     	cmp	w10, w11
     c34: 540015a2     	b.hs	0xee8 <___pl_fn_4+0x5d0>
     c38: 72001eff     	tst	w23, #0xff
     c3c: 540013c0     	b.eq	0xeb4 <___pl_fn_4+0x59c>
     c40: aa1a03e0     	mov	x0, x26
     c44: aa1903e1     	mov	x1, x25
     c48: aa1503e2     	mov	x2, x21
     c4c: 94000000     	bl	0xc4c <___pl_fn_4+0x334>
     c50: aa1a03e0     	mov	x0, x26
     c54: aa1903e3     	mov	x3, x25
     c58: b9402c0f     	ldr	w15, [x0, #0x2c]
     c5c: 35002b0f     	cbnz	w15, 0x11bc <___pl_fn_4+0x8a4>
     c60: aa1a03e0     	mov	x0, x26
     c64: b9001816     	str	w22, [x0, #0x18]
     c68: b9401c00     	ldr	w0, [x0, #0x1c]
     c6c: 6b00031f     	cmp	w24, w0
     c70: 54001088     	b.hi	0xe80 <___pl_fn_4+0x568>
     c74: aa1a03e0     	mov	x0, x26
     c78: f9401000     	ldr	x0, [x0, #0x20]
     c7c: b8365803     	str	w3, [x0, w22, uxtw #2]
     c80: aa1a03e0     	mov	x0, x26
     c84: b9001818     	str	w24, [x0, #0x18]
     c88: b9401000     	ldr	w0, [x0, #0x10]
     c8c: aa1a03e1     	mov	x1, x26
     c90: b9401421     	ldr	w1, [x1, #0x14]
     c94: 6b01001f     	cmp	w0, w1
     c98: 54000da2     	b.hs	0xe4c <___pl_fn_4+0x534>
     c9c: d2800002     	mov	x2, #0x0                ; =0
     ca0: aa1a03e0     	mov	x0, x26
     ca4: aa1c03e1     	mov	x1, x28
     ca8: 94000000     	bl	0xca8 <___pl_fn_4+0x390>
     cac: aa1a03e0     	mov	x0, x26
     cb0: b9402c00     	ldr	w0, [x0, #0x2c]
     cb4: 35002840     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     cb8: aa1a03e0     	mov	x0, x26
     cbc: b9001816     	str	w22, [x0, #0x18]
     cc0: ab1402b5     	adds	x21, x21, x20
     cc4: 9a9f77e0     	cset	x0, vs
     cc8: 72001c1f     	tst	w0, #0xff
     ccc: 54000a61     	b.ne	0xe18 <___pl_fn_4+0x500>
     cd0: 52800037     	mov	w23, #0x1               ; =1
     cd4: 17ffff80     	b	0xad4 <___pl_fn_4+0x1bc>
     cd8: d2800020     	mov	x0, #0x1                ; =1
     cdc: f84183f5     	ldur	x21, [sp, #0x18]
     ce0: ab0002a2     	adds	x2, x21, x0
     ce4: aa0203f9     	mov	x25, x2
     ce8: 9a9f77e0     	cset	x0, vs
     cec: 72001c1f     	tst	w0, #0xff
     cf0: 54001fe1     	b.ne	0x10ec <___pl_fn_4+0x7d4>
     cf4: 52800661     	mov	w1, #0x33               ; =51
     cf8: 52800002     	mov	w2, #0x0                ; =0
     cfc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     d00: f9400063     	ldr	x3, [x3]
     d04: aa1a03e0     	mov	x0, x26
     d08: d63f0060     	blr	x3
     d0c: 35002580     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     d10: aa1a03e0     	mov	x0, x26
     d14: f9401817     	ldr	x23, [x0, #0x30]
     d18: b9401818     	ldr	w24, [x0, #0x18]
     d1c: b9401c01     	ldr	w1, [x0, #0x1c]
     d20: 11000700     	add	w0, w24, #0x1
     d24: 6b01001f     	cmp	w0, w1
     d28: 54001c88     	b.hi	0x10b8 <___pl_fn_4+0x7a0>
     d2c: aa1a03e1     	mov	x1, x26
     d30: f9401021     	ldr	x1, [x1, #0x20]
     d34: b8385837     	str	w23, [x1, w24, uxtw #2]
     d38: aa1a03e1     	mov	x1, x26
     d3c: b9001820     	str	w0, [x1, #0x18]
     d40: aa1a03e0     	mov	x0, x26
     d44: b9401000     	ldr	w0, [x0, #0x10]
     d48: b9401421     	ldr	w1, [x1, #0x14]
     d4c: 6b01001f     	cmp	w0, w1
     d50: 540019a2     	b.hs	0x1084 <___pl_fn_4+0x76c>
     d54: aa1903e2     	mov	x2, x25
     d58: aa1a03e0     	mov	x0, x26
     d5c: aa1703e1     	mov	x1, x23
     d60: 94000000     	bl	0xd60 <___pl_fn_4+0x448>
     d64: aa1a03e0     	mov	x0, x26
     d68: b9402c00     	ldr	w0, [x0, #0x2c]
     d6c: 35002280     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     d70: aa1a03e0     	mov	x0, x26
     d74: b9001818     	str	w24, [x0, #0x18]
     d78: 528006c1     	mov	w1, #0x36               ; =54
     d7c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     d80: f9400063     	ldr	x3, [x3]
     d84: aa1c03e2     	mov	x2, x28
     d88: d63f0060     	blr	x3
     d8c: 35002180     	cbnz	w0, 0x11bc <___pl_fn_4+0x8a4>
     d90: aa1a03e0     	mov	x0, x26
     d94: f9401802     	ldr	x2, [x0, #0x30]
     d98: 34001462     	cbz	w2, 0x1024 <___pl_fn_4+0x70c>
     d9c: aa1a03e0     	mov	x0, x26
     da0: f9400000     	ldr	x0, [x0]
     da4: 2a0203e1     	mov	w1, w2
     da8: 8b010c00     	add	x0, x0, x1, lsl #3
     dac: f9400801     	ldr	x1, [x0, #0x10]
     db0: eb01027f     	cmp	x19, x1
     db4: 54001382     	b.hs	0x1024 <___pl_fn_4+0x70c>
     db8: 2a1703e4     	mov	w4, w23
     dbc: 8b130c05     	add	x5, x0, x19, lsl #3
     dc0: f90014a4     	str	x4, [x5, #0x28]
     dc4: ab160273     	adds	x19, x19, x22
     dc8: 9a9f77e7     	cset	x7, vs
     dcc: 72001cff     	tst	w7, #0xff
     dd0: 54001401     	b.ne	0x1050 <___pl_fn_4+0x738>
     dd4: 52800021     	mov	w1, #0x1                ; =1
     dd8: f80183f5     	stur	x21, [sp, #0x18]
     ddc: 17ffff21     	b	0xa60 <___pl_fn_4+0x148>
     de0: 528004e1     	mov	w1, #0x27               ; =39
     de4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     de8: f9400063     	ldr	x3, [x3]
     dec: aa1a03e0     	mov	x0, x26
     df0: d63f0060     	blr	x3
     df4: 9100c3ff     	add	sp, sp, #0x30
     df8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     dfc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e00: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e04: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e08: a8c173fb     	ldp	x27, x28, [sp], #0x10
     e0c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e10: d65f03c0     	ret
     e14: 140000ea     	b	0x11bc <___pl_fn_4+0x8a4>
     e18: 52800621     	mov	w1, #0x31               ; =49
     e1c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e20: f9400042     	ldr	x2, [x2]
     e24: aa1a03e0     	mov	x0, x26
     e28: d63f0040     	blr	x2
     e2c: 9100c3ff     	add	sp, sp, #0x30
     e30: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e34: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e38: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e3c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e40: a8c173fb     	ldp	x27, x28, [sp], #0x10
     e44: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e48: d65f03c0     	ret
     e4c: 52800601     	mov	w1, #0x30               ; =48
     e50: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e54: f9400042     	ldr	x2, [x2]
     e58: aa1a03e0     	mov	x0, x26
     e5c: d63f0040     	blr	x2
     e60: 9100c3ff     	add	sp, sp, #0x30
     e64: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e68: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e6c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e70: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e74: a8c173fb     	ldp	x27, x28, [sp], #0x10
     e78: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e7c: d65f03c0     	ret
     e80: 528005e1     	mov	w1, #0x2f               ; =47
     e84: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e88: f9400042     	ldr	x2, [x2]
     e8c: aa1a03e0     	mov	x0, x26
     e90: d63f0040     	blr	x2
     e94: 9100c3ff     	add	sp, sp, #0x30
     e98: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e9c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ea0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ea4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     ea8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     eac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     eb0: d65f03c0     	ret
     eb4: 528005c1     	mov	w1, #0x2e               ; =46
     eb8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     ebc: f9400042     	ldr	x2, [x2]
     ec0: aa1a03e0     	mov	x0, x26
     ec4: d63f0040     	blr	x2
     ec8: 9100c3ff     	add	sp, sp, #0x30
     ecc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ed0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ed4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ed8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     edc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ee0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ee4: d65f03c0     	ret
     ee8: 528005a1     	mov	w1, #0x2d               ; =45
     eec: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     ef0: f9400042     	ldr	x2, [x2]
     ef4: aa1a03e0     	mov	x0, x26
     ef8: d63f0040     	blr	x2
     efc: 9100c3ff     	add	sp, sp, #0x30
     f00: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f04: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     f08: a8c163f7     	ldp	x23, x24, [sp], #0x10
     f0c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     f10: a8c173fb     	ldp	x27, x28, [sp], #0x10
     f14: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f18: d65f03c0     	ret
     f1c: 52800581     	mov	w1, #0x2c               ; =44
     f20: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     f24: f9400042     	ldr	x2, [x2]
     f28: aa1a03e0     	mov	x0, x26
     f2c: d63f0040     	blr	x2
     f30: 9100c3ff     	add	sp, sp, #0x30
     f34: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f38: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     f3c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     f40: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     f44: a8c173fb     	ldp	x27, x28, [sp], #0x10
     f48: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f4c: d65f03c0     	ret
     f50: 528004a1     	mov	w1, #0x25               ; =37
     f54: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     f58: f9400042     	ldr	x2, [x2]
     f5c: aa1a03e0     	mov	x0, x26
     f60: d63f0040     	blr	x2
     f64: 9100c3ff     	add	sp, sp, #0x30
     f68: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f6c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     f70: a8c163f7     	ldp	x23, x24, [sp], #0x10
     f74: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     f78: a8c173fb     	ldp	x27, x28, [sp], #0x10
     f7c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f80: d65f03c0     	ret
     f84: 52800481     	mov	w1, #0x24               ; =36
     f88: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     f8c: f9400042     	ldr	x2, [x2]
     f90: aa1a03e0     	mov	x0, x26
     f94: d63f0040     	blr	x2
     f98: 9100c3ff     	add	sp, sp, #0x30
     f9c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     fa0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     fa4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     fa8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     fac: a8c173fb     	ldp	x27, x28, [sp], #0x10
     fb0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     fb4: d65f03c0     	ret
     fb8: 52800461     	mov	w1, #0x23               ; =35
     fbc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     fc0: f9400042     	ldr	x2, [x2]
     fc4: aa1a03e0     	mov	x0, x26
     fc8: d63f0040     	blr	x2
     fcc: 9100c3ff     	add	sp, sp, #0x30
     fd0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     fd4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     fd8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     fdc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     fe0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     fe4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     fe8: d65f03c0     	ret
     fec: 52800441     	mov	w1, #0x22               ; =34
     ff0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     ff4: f9400042     	ldr	x2, [x2]
     ff8: aa1a03e0     	mov	x0, x26
     ffc: d63f0040     	blr	x2
    1000: 9100c3ff     	add	sp, sp, #0x30
    1004: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1008: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    100c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1010: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1014: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1018: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    101c: d65f03c0     	ret
    1020: 14000067     	b	0x11bc <___pl_fn_4+0x8a4>
    1024: 910023e3     	add	x3, sp, #0x8
    1028: f80083f3     	stur	x19, [sp, #0x8]
    102c: 2a1703e0     	mov	w0, w23
    1030: f80103e0     	stur	x0, [sp, #0x10]
    1034: 528006e1     	mov	w1, #0x37               ; =55
    1038: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x6e8>
    103c: f9400084     	ldr	x4, [x4]
    1040: aa1a03e0     	mov	x0, x26
    1044: d63f0080     	blr	x4
    1048: 34ffebe0     	cbz	w0, 0xdc4 <___pl_fn_4+0x4ac>
    104c: 1400005c     	b	0x11bc <___pl_fn_4+0x8a4>
    1050: 52800701     	mov	w1, #0x38               ; =56
    1054: 90000009     	adrp	x9, 0x1000 <___pl_fn_4+0x6e8>
    1058: f9400129     	ldr	x9, [x9]
    105c: aa1a03e0     	mov	x0, x26
    1060: d63f0120     	blr	x9
    1064: 9100c3ff     	add	sp, sp, #0x30
    1068: a8c153f3     	ldp	x19, x20, [sp], #0x10
    106c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1070: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1074: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1078: a8c173fb     	ldp	x27, x28, [sp], #0x10
    107c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1080: d65f03c0     	ret
    1084: 528006a1     	mov	w1, #0x35               ; =53
    1088: 9000000a     	adrp	x10, 0x1000 <___pl_fn_4+0x6e8>
    108c: f940014a     	ldr	x10, [x10]
    1090: aa1a03e0     	mov	x0, x26
    1094: d63f0140     	blr	x10
    1098: 9100c3ff     	add	sp, sp, #0x30
    109c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    10a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    10a4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    10a8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    10ac: a8c173fb     	ldp	x27, x28, [sp], #0x10
    10b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    10b4: d65f03c0     	ret
    10b8: 52800681     	mov	w1, #0x34               ; =52
    10bc: 9000000b     	adrp	x11, 0x1000 <___pl_fn_4+0x6e8>
    10c0: f940016b     	ldr	x11, [x11]
    10c4: aa1a03e0     	mov	x0, x26
    10c8: d63f0160     	blr	x11
    10cc: 9100c3ff     	add	sp, sp, #0x30
    10d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    10d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    10d8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    10dc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    10e0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    10e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    10e8: d65f03c0     	ret
    10ec: 52800641     	mov	w1, #0x32               ; =50
    10f0: 9000000c     	adrp	x12, 0x1000 <___pl_fn_4+0x6e8>
    10f4: f940018c     	ldr	x12, [x12]
    10f8: aa1a03e0     	mov	x0, x26
    10fc: d63f0180     	blr	x12
    1100: 9100c3ff     	add	sp, sp, #0x30
    1104: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1108: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    110c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1110: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1114: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1118: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    111c: d65f03c0     	ret
    1120: 52800421     	mov	w1, #0x21               ; =33
    1124: 9000000d     	adrp	x13, 0x1000 <___pl_fn_4+0x6e8>
    1128: f94001ad     	ldr	x13, [x13]
    112c: aa1a03e0     	mov	x0, x26
    1130: d63f01a0     	blr	x13
    1134: 9100c3ff     	add	sp, sp, #0x30
    1138: a8c153f3     	ldp	x19, x20, [sp], #0x10
    113c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1140: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1144: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1148: a8c173fb     	ldp	x27, x28, [sp], #0x10
    114c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1150: d65f03c0     	ret
    1154: 52800401     	mov	w1, #0x20               ; =32
    1158: 9000000e     	adrp	x14, 0x1000 <___pl_fn_4+0x6e8>
    115c: f94001ce     	ldr	x14, [x14]
    1160: aa1a03e0     	mov	x0, x26
    1164: d63f01c0     	blr	x14
    1168: 9100c3ff     	add	sp, sp, #0x30
    116c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1170: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1174: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1178: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    117c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1180: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1184: d65f03c0     	ret
    1188: 528003e1     	mov	w1, #0x1f               ; =31
    118c: 9000000f     	adrp	x15, 0x1000 <___pl_fn_4+0x6e8>
    1190: f94001ef     	ldr	x15, [x15]
    1194: aa1a03e0     	mov	x0, x26
    1198: d63f01e0     	blr	x15
    119c: 9100c3ff     	add	sp, sp, #0x30
    11a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    11a8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    11ac: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    11b0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    11b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11b8: d65f03c0     	ret
    11bc: 9100c3ff     	add	sp, sp, #0x30
    11c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11c4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    11c8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    11cc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    11d0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    11d4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11d8: d65f03c0     	ret

00000000000011dc <___pl_fn_5>:
    11dc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    11e0: 910003fd     	mov	x29, sp
    11e4: f81f0ff3     	str	x19, [sp, #-0x10]!
    11e8: d10043ff     	sub	sp, sp, #0x10
    11ec: b9401003     	ldr	w3, [x0, #0x10]
    11f0: 11000463     	add	w3, w3, #0x1
    11f4: b9001003     	str	w3, [x0, #0x10]
    11f8: aa0003e5     	mov	x5, x0
    11fc: 34000321     	cbz	w1, 0x1260 <___pl_fn_5+0x84>
    1200: aa0503f3     	mov	x19, x5
    1204: aa0203e3     	mov	x3, x2
    1208: aa0103e2     	mov	x2, x1
    120c: f9400261     	ldr	x1, [x19]
    1210: 2a0203e0     	mov	w0, w2
    1214: 8b000c20     	add	x0, x1, x0, lsl #3
    1218: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    121c: d360fc21     	lsr	x1, x1, #32
    1220: 92403c22     	and	x2, x1, #0xffff
    1224: f100085f     	cmp	x2, #0x2
    1228: 54000080     	b.eq	0x1238 <___pl_fn_5+0x5c>
    122c: f9400802     	ldr	x2, [x0, #0x10]
    1230: 927ff842     	and	x2, x2, #0xfffffffffffffffe
    1234: f9000802     	str	x2, [x0, #0x10]
    1238: 92403c21     	and	x1, x1, #0xffff
    123c: aa0303e2     	mov	x2, x3
    1240: f8217802     	str	x2, [x0, x1, lsl #3]
    1244: b9401260     	ldr	w0, [x19, #0x10]
    1248: 51000400     	sub	w0, w0, #0x1
    124c: b9001260     	str	w0, [x19, #0x10]
    1250: 910043ff     	add	sp, sp, #0x10
    1254: f84107f3     	ldr	x19, [sp], #0x10
    1258: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    125c: d65f03c0     	ret
    1260: aa0103e6     	mov	x6, x1
    1264: d2800000     	mov	x0, #0x0                ; =0
    1268: 910003e3     	mov	x3, sp
    126c: f80003e0     	stur	x0, [sp]
    1270: f80083e2     	stur	x2, [sp, #0x8]
    1274: 52800721     	mov	w1, #0x39               ; =57
    1278: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x6e8>
    127c: f9400084     	ldr	x4, [x4]
    1280: aa0603e2     	mov	x2, x6
    1284: aa0503f3     	mov	x19, x5
    1288: aa1303e0     	mov	x0, x19
    128c: d63f0080     	blr	x4
    1290: 34fffda0     	cbz	w0, 0x1244 <___pl_fn_5+0x68>
    1294: 910043ff     	add	sp, sp, #0x10
    1298: f84107f3     	ldr	x19, [sp], #0x10
    129c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12a0: d65f03c0     	ret
