
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_94328/sieve/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
       c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      10: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      14: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      18: d100c3ff     	sub	sp, sp, #0x30
      1c: b9401001     	ldr	w1, [x0, #0x10]
      20: 11000421     	add	w1, w1, #0x1
      24: b9001001     	str	w1, [x0, #0x10]
      28: aa0003fa     	mov	x26, x0
      2c: d2827120     	mov	x0, #0x1389             ; =5001
      30: 910003e3     	mov	x3, sp
      34: f80003e0     	stur	x0, [sp]
      38: 52800001     	mov	w1, #0x0                ; =0
      3c: 52802042     	mov	w2, #0x102              ; =258
      40: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      44: f9400084     	ldr	x4, [x4]
      48: aa1a03e0     	mov	x0, x26
      4c: d63f0080     	blr	x4
      50: 35001de0     	cbnz	w0, 0x40c <___pl_fn_0+0x40c>
      54: aa1a03e0     	mov	x0, x26
      58: f9401813     	ldr	x19, [x0, #0x30]
      5c: b9401815     	ldr	w21, [x0, #0x18]
      60: b9401c01     	ldr	w1, [x0, #0x1c]
      64: 110006a0     	add	w0, w21, #0x1
      68: 6b01001f     	cmp	w0, w1
      6c: 54001b88     	b.hi	0x3dc <___pl_fn_0+0x3dc>
      70: aa1a03e1     	mov	x1, x26
      74: f9401021     	ldr	x1, [x1, #0x20]
      78: b8355833     	str	w19, [x1, w21, uxtw #2]
      7c: aa1a03e1     	mov	x1, x26
      80: b9001820     	str	w0, [x1, #0x18]
      84: 52800041     	mov	w1, #0x2                ; =2
      88: 52800002     	mov	w2, #0x0                ; =0
      8c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
      90: f9400063     	ldr	x3, [x3]
      94: aa1a03e0     	mov	x0, x26
      98: d63f0060     	blr	x3
      9c: 35001b80     	cbnz	w0, 0x40c <___pl_fn_0+0x40c>
      a0: aa1a03e0     	mov	x0, x26
      a4: f9401814     	ldr	x20, [x0, #0x30]
      a8: b9001815     	str	w21, [x0, #0x18]
      ac: d2800015     	mov	x21, #0x0               ; =0
      b0: 52800020     	mov	w0, #0x1                ; =1
      b4: eb1402bf     	cmp	x21, x20
      b8: 9a9fc7e0     	cset	x0, le
      bc: 72001c1f     	tst	w0, #0xff
      c0: 54000ae1     	b.ne	0x21c <___pl_fn_0+0x21c>
      c4: d2800055     	mov	x21, #0x2               ; =2
      c8: d2800016     	mov	x22, #0x0               ; =0
      cc: 52800020     	mov	w0, #0x1                ; =1
      d0: 52800017     	mov	w23, #0x0               ; =0
      d4: aa1603e2     	mov	x2, x22
      d8: aa0003f9     	mov	x25, x0
      dc: eb1402bf     	cmp	x21, x20
      e0: 9a9fc7e0     	cset	x0, le
      e4: 72001c1f     	tst	w0, #0xff
      e8: 54000281     	b.ne	0x138 <___pl_fn_0+0x138>
      ec: 528000a1     	mov	w1, #0x5                ; =5
      f0: 52802003     	mov	w3, #0x100              ; =256
      f4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      f8: f9400084     	ldr	x4, [x4]
      fc: aa1a03e0     	mov	x0, x26
     100: d63f0080     	blr	x4
     104: 35001840     	cbnz	w0, 0x40c <___pl_fn_0+0x40c>
     108: aa1a03e0     	mov	x0, x26
     10c: b9401000     	ldr	w0, [x0, #0x10]
     110: 51000400     	sub	w0, w0, #0x1
     114: aa1a03e3     	mov	x3, x26
     118: b9001060     	str	w0, [x3, #0x10]
     11c: 9100c3ff     	add	sp, sp, #0x30
     120: a8c153f3     	ldp	x19, x20, [sp], #0x10
     124: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     128: a8c163f7     	ldp	x23, x24, [sp], #0x10
     12c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     130: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     134: d65f03c0     	ret
     138: aa0203f8     	mov	x24, x2
     13c: 34000953     	cbz	w19, 0x264 <___pl_fn_0+0x264>
     140: aa1a03e0     	mov	x0, x26
     144: f9400000     	ldr	x0, [x0]
     148: 2a1303e1     	mov	w1, w19
     14c: 8b010c00     	add	x0, x0, x1, lsl #3
     150: f9400801     	ldr	x1, [x0, #0x10]
     154: eb0102bf     	cmp	x21, x1
     158: 54000862     	b.hs	0x264 <___pl_fn_0+0x264>
     15c: 8b150c00     	add	x0, x0, x21, lsl #3
     160: 3940a000     	ldrb	w0, [x0, #0x28]
     164: 53001c01     	uxtb	w1, w0
     168: 7100083f     	cmp	w1, #0x2
     16c: 54000081     	b.ne	0x17c <___pl_fn_0+0x17c>
     170: 1400003d     	b	0x264 <___pl_fn_0+0x264>
     174: aa1a03e0     	mov	x0, x26
     178: f9401800     	ldr	x0, [x0, #0x30]
     17c: 72001c1f     	tst	w0, #0xff
     180: 540001c0     	b.eq	0x1b8 <___pl_fn_0+0x1b8>
     184: d2800020     	mov	x0, #0x1                ; =1
     188: ab000318     	adds	x24, x24, x0
     18c: 9a9f77e0     	cset	x0, vs
     190: 72001c1f     	tst	w0, #0xff
     194: 54000dc1     	b.ne	0x34c <___pl_fn_0+0x34c>
     198: ab1502b6     	adds	x22, x21, x21
     19c: 9a9f77e0     	cset	x0, vs
     1a0: 72001c1f     	tst	w0, #0xff
     1a4: 54000bc1     	b.ne	0x31c <___pl_fn_0+0x31c>
     1a8: 52800037     	mov	w23, #0x1               ; =1
     1ac: eb1402df     	cmp	x22, x20
     1b0: 5400014d     	b.le	0x1d8 <___pl_fn_0+0x1d8>
     1b4: 52800039     	mov	w25, #0x1               ; =1
     1b8: d2800020     	mov	x0, #0x1                ; =1
     1bc: ab0002b5     	adds	x21, x21, x0
     1c0: 9a9f77e0     	cset	x0, vs
     1c4: 72001c1f     	tst	w0, #0xff
     1c8: 54000621     	b.ne	0x28c <___pl_fn_0+0x28c>
     1cc: 52800020     	mov	w0, #0x1                ; =1
     1d0: aa1803e2     	mov	x2, x24
     1d4: 17ffffc2     	b	0xdc <___pl_fn_0+0xdc>
     1d8: 34000733     	cbz	w19, 0x2bc <___pl_fn_0+0x2bc>
     1dc: aa1a03e0     	mov	x0, x26
     1e0: f9400000     	ldr	x0, [x0]
     1e4: 2a1303e1     	mov	w1, w19
     1e8: 8b010c00     	add	x0, x0, x1, lsl #3
     1ec: f9400801     	ldr	x1, [x0, #0x10]
     1f0: eb0102df     	cmp	x22, x1
     1f4: 54000642     	b.hs	0x2bc <___pl_fn_0+0x2bc>
     1f8: d2800001     	mov	x1, #0x0                ; =0
     1fc: 8b160c00     	add	x0, x0, x22, lsl #3
     200: f9001401     	str	x1, [x0, #0x28]
     204: ab1502d6     	adds	x22, x22, x21
     208: 9a9f77e2     	cset	x2, vs
     20c: 72001c5f     	tst	w2, #0xff
     210: 540006e1     	b.ne	0x2ec <___pl_fn_0+0x2ec>
     214: 52800037     	mov	w23, #0x1               ; =1
     218: 17ffffe5     	b	0x1ac <___pl_fn_0+0x1ac>
     21c: 34000b13     	cbz	w19, 0x37c <___pl_fn_0+0x37c>
     220: aa1a03e0     	mov	x0, x26
     224: f9400009     	ldr	x9, [x0]
     228: 2a1303ea     	mov	w10, w19
     22c: 8b0a0d29     	add	x9, x9, x10, lsl #3
     230: f940092a     	ldr	x10, [x9, #0x10]
     234: eb0a02bf     	cmp	x21, x10
     238: 54000a22     	b.hs	0x37c <___pl_fn_0+0x37c>
     23c: d2800020     	mov	x0, #0x1                ; =1
     240: 8b150d21     	add	x1, x9, x21, lsl #3
     244: f9001420     	str	x0, [x1, #0x28]
     248: d2800020     	mov	x0, #0x1                ; =1
     24c: ab0002b5     	adds	x21, x21, x0
     250: 9a9f77e0     	cset	x0, vs
     254: 72001c1f     	tst	w0, #0xff
     258: 54000aa1     	b.ne	0x3ac <___pl_fn_0+0x3ac>
     25c: 52800020     	mov	w0, #0x1                ; =1
     260: 17ffff95     	b	0xb4 <___pl_fn_0+0xb4>
     264: 910023e3     	add	x3, sp, #0x8
     268: f80083f5     	stur	x21, [sp, #0x8]
     26c: 528000c1     	mov	w1, #0x6                ; =6
     270: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     274: f9400084     	ldr	x4, [x4]
     278: aa1a03e0     	mov	x0, x26
     27c: aa1303e2     	mov	x2, x19
     280: d63f0080     	blr	x4
     284: 34fff780     	cbz	w0, 0x174 <___pl_fn_0+0x174>
     288: 14000061     	b	0x40c <___pl_fn_0+0x40c>
     28c: 52800121     	mov	w1, #0x9                ; =9
     290: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     294: f9400042     	ldr	x2, [x2]
     298: aa1a03e0     	mov	x0, x26
     29c: d63f0040     	blr	x2
     2a0: 9100c3ff     	add	sp, sp, #0x30
     2a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     2a8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     2ac: a8c163f7     	ldp	x23, x24, [sp], #0x10
     2b0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     2b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     2b8: d65f03c0     	ret
     2bc: 910043e3     	add	x3, sp, #0x10
     2c0: f80103f6     	stur	x22, [sp, #0x10]
     2c4: d2800000     	mov	x0, #0x0                ; =0
     2c8: f80183e0     	stur	x0, [sp, #0x18]
     2cc: 52800141     	mov	w1, #0xa                ; =10
     2d0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     2d4: f9400084     	ldr	x4, [x4]
     2d8: aa1a03e0     	mov	x0, x26
     2dc: aa1303e2     	mov	x2, x19
     2e0: d63f0080     	blr	x4
     2e4: 34fff900     	cbz	w0, 0x204 <___pl_fn_0+0x204>
     2e8: 14000049     	b	0x40c <___pl_fn_0+0x40c>
     2ec: 52800161     	mov	w1, #0xb                ; =11
     2f0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     2f4: f9400084     	ldr	x4, [x4]
     2f8: aa1a03e0     	mov	x0, x26
     2fc: d63f0080     	blr	x4
     300: 9100c3ff     	add	sp, sp, #0x30
     304: a8c153f3     	ldp	x19, x20, [sp], #0x10
     308: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     30c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     310: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     314: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     318: d65f03c0     	ret
     31c: 52800101     	mov	w1, #0x8                ; =8
     320: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     324: f94000a5     	ldr	x5, [x5]
     328: aa1a03e0     	mov	x0, x26
     32c: d63f00a0     	blr	x5
     330: 9100c3ff     	add	sp, sp, #0x30
     334: a8c153f3     	ldp	x19, x20, [sp], #0x10
     338: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     33c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     340: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     344: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     348: d65f03c0     	ret
     34c: 528000e1     	mov	w1, #0x7                ; =7
     350: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     354: f94000c6     	ldr	x6, [x6]
     358: aa1a03e0     	mov	x0, x26
     35c: d63f00c0     	blr	x6
     360: 9100c3ff     	add	sp, sp, #0x30
     364: a8c153f3     	ldp	x19, x20, [sp], #0x10
     368: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     36c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     370: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     374: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     378: d65f03c0     	ret
     37c: 910083e3     	add	x3, sp, #0x20
     380: f80203f5     	stur	x21, [sp, #0x20]
     384: d280002d     	mov	x13, #0x1               ; =1
     388: f80283ed     	stur	x13, [sp, #0x28]
     38c: 52800181     	mov	w1, #0xc                ; =12
     390: 9000000e     	adrp	x14, 0x0 <___pl_fn_0>
     394: f94001ce     	ldr	x14, [x14]
     398: aa1a03e0     	mov	x0, x26
     39c: aa1303e2     	mov	x2, x19
     3a0: d63f01c0     	blr	x14
     3a4: 34fff520     	cbz	w0, 0x248 <___pl_fn_0+0x248>
     3a8: 14000019     	b	0x40c <___pl_fn_0+0x40c>
     3ac: 528001a1     	mov	w1, #0xd                ; =13
     3b0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     3b4: f9400042     	ldr	x2, [x2]
     3b8: aa1a03e0     	mov	x0, x26
     3bc: d63f0040     	blr	x2
     3c0: 9100c3ff     	add	sp, sp, #0x30
     3c4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     3c8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     3cc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     3d0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     3d4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     3d8: d65f03c0     	ret
     3dc: 52800021     	mov	w1, #0x1                ; =1
     3e0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     3e4: f9400042     	ldr	x2, [x2]
     3e8: aa1a03e0     	mov	x0, x26
     3ec: d63f0040     	blr	x2
     3f0: 9100c3ff     	add	sp, sp, #0x30
     3f4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     3f8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     3fc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     400: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     404: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     408: d65f03c0     	ret
     40c: 9100c3ff     	add	sp, sp, #0x30
     410: a8c153f3     	ldp	x19, x20, [sp], #0x10
     414: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     418: a8c163f7     	ldp	x23, x24, [sp], #0x10
     41c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     420: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     424: d65f03c0     	ret
