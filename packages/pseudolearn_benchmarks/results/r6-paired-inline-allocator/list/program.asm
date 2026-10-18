
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_94328/list/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: f81f0ff7     	str	x23, [sp, #-0x10]!
       c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      10: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      14: d10103ff     	sub	sp, sp, #0x40
      18: aa0103f3     	mov	x19, x1
      1c: b9401001     	ldr	w1, [x0, #0x10]
      20: 11000421     	add	w1, w1, #0x1
      24: b9001001     	str	w1, [x0, #0x10]
      28: f9403c01     	ldr	x1, [x0, #0x78]
      2c: 373017c1     	tbnz	w1, #0x6, 0x324 <___pl_fn_0+0x324>
      30: f9403801     	ldr	x1, [x0, #0x70]
      34: f100003f     	cmp	x1, #0x0
      38: 540017ad     	b.le	0x32c <___pl_fn_0+0x32c>
      3c: f9403402     	ldr	x2, [x0, #0x68]
      40: f100105f     	cmp	x2, #0x4
      44: 5400178b     	b.lt	0x334 <___pl_fn_0+0x334>
      48: f9402801     	ldr	x1, [x0, #0x50]
      4c: f9402c05     	ldr	x5, [x0, #0x58]
      50: 91001826     	add	x6, x1, #0x6
      54: eb0500df     	cmp	x6, x5
      58: 54001728     	b.hi	0x33c <___pl_fn_0+0x33c>
      5c: f9404408     	ldr	x8, [x0, #0x88]
      60: f9404809     	ldr	x9, [x0, #0x90]
      64: aa0003f5     	mov	x21, x0
      68: eb09011f     	cmp	x8, x9
      6c: 540000a3     	b.lo	0x80 <___pl_fn_0+0x80>
      70: 140000b4     	b	0x340 <___pl_fn_0+0x340>
      74: aa1503e0     	mov	x0, x21
      78: f9401801     	ldr	x1, [x0, #0x30]
      7c: 14000029     	b	0x120 <___pl_fn_0+0x120>
      80: aa1503e0     	mov	x0, x21
      84: f9403000     	ldr	x0, [x0, #0x60]
      88: aa1503e2     	mov	x2, x21
      8c: f9400042     	ldr	x2, [x2]
      90: b20007e3     	mov	x3, #0x300000003        ; =12884901891
      94: 2a0103ee     	mov	w14, w1
      98: 8b0e0c4f     	add	x15, x2, x14, lsl #3
      9c: f8215843     	str	x3, [x2, w1, uxtw #3]
      a0: 91000400     	add	x0, x0, #0x1
      a4: f90005e0     	str	x0, [x15, #0x8]
      a8: 92800002     	mov	x2, #-0x1               ; =-1
      ac: f90009e2     	str	x2, [x15, #0x10]
      b0: d2800002     	mov	x2, #0x0                ; =0
      b4: f9000de2     	str	x2, [x15, #0x18]
      b8: f90011e2     	str	x2, [x15, #0x20]
      bc: d2800042     	mov	x2, #0x2                ; =2
      c0: f90015e2     	str	x2, [x15, #0x28]
      c4: aa1503e2     	mov	x2, x21
      c8: f9003040     	str	x0, [x2, #0x60]
      cc: 91001820     	add	x0, x1, #0x6
      d0: f9002840     	str	x0, [x2, #0x50]
      d4: aa1503e0     	mov	x0, x21
      d8: f9403400     	ldr	x0, [x0, #0x68]
      dc: d1001000     	sub	x0, x0, #0x4
      e0: f9003440     	str	x0, [x2, #0x68]
      e4: aa1503e0     	mov	x0, x21
      e8: f9403800     	ldr	x0, [x0, #0x70]
      ec: d1001000     	sub	x0, x0, #0x4
      f0: f9003840     	str	x0, [x2, #0x70]
      f4: aa1503e0     	mov	x0, x21
      f8: f9404000     	ldr	x0, [x0, #0x80]
      fc: b25f05c2     	orr	x2, x14, #0x600000000
     100: d2800083     	mov	x3, #0x4                ; =4
     104: d37ced04     	lsl	x4, x8, #4
     108: 8b081005     	add	x5, x0, x8, lsl #4
     10c: f8246802     	str	x2, [x0, x4]
     110: f90004a3     	str	x3, [x5, #0x8]
     114: 91000500     	add	x0, x8, #0x1
     118: aa1503ed     	mov	x13, x21
     11c: f90045a0     	str	x0, [x13, #0x88]
     120: 52800000     	mov	w0, #0x0                ; =0
     124: aa0003f7     	mov	x23, x0
     128: 34001d61     	cbz	w1, 0x4d4 <___pl_fn_0+0x4d4>
     12c: b4000bf3     	cbz	x19, 0x2a8 <___pl_fn_0+0x2a8>
     130: 35000081     	cbnz	w1, 0x140 <___pl_fn_0+0x140>
     134: 1400008b     	b	0x360 <___pl_fn_0+0x360>
     138: aa1603e0     	mov	x0, x22
     13c: 1400000f     	b	0x178 <___pl_fn_0+0x178>
     140: aa1503e0     	mov	x0, x21
     144: aa0103f6     	mov	x22, x1
     148: f9400001     	ldr	x1, [x0]
     14c: aa1603e0     	mov	x0, x22
     150: 2a0003e0     	mov	w0, w0
     154: 8b000c20     	add	x0, x1, x0, lsl #3
     158: aa1603e2     	mov	x2, x22
     15c: f8625822     	ldr	x2, [x1, w2, uxtw #3]
     160: d2800001     	mov	x1, #0x0                ; =0
     164: d360fc42     	lsr	x2, x2, #32
     168: 92403c42     	and	x2, x2, #0xffff
     16c: 91000842     	add	x2, x2, #0x2
     170: f8227801     	str	x1, [x0, x2, lsl #3]
     174: aa1603e0     	mov	x0, x22
     178: aa1603e0     	mov	x0, x22
     17c: 340010e0     	cbz	w0, 0x398 <___pl_fn_0+0x398>
     180: aa1503e0     	mov	x0, x21
     184: f9400001     	ldr	x1, [x0]
     188: aa1603e0     	mov	x0, x22
     18c: 2a0003e0     	mov	w0, w0
     190: 8b000c20     	add	x0, x1, x0, lsl #3
     194: aa1603e2     	mov	x2, x22
     198: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     19c: d360fc21     	lsr	x1, x1, #32
     1a0: 92403c22     	and	x2, x1, #0xffff
     1a4: f100085f     	cmp	x2, #0x2
     1a8: 54000080     	b.eq	0x1b8 <___pl_fn_0+0x1b8>
     1ac: f9400802     	ldr	x2, [x0, #0x10]
     1b0: 927ff842     	and	x2, x2, #0xfffffffffffffffe
     1b4: f9000802     	str	x2, [x0, #0x10]
     1b8: 92403c21     	and	x1, x1, #0xffff
     1bc: f8217813     	str	x19, [x0, x1, lsl #3]
     1c0: d2800034     	mov	x20, #0x1               ; =1
     1c4: eb140261     	subs	x1, x19, x20
     1c8: 9a9f77e0     	cset	x0, vs
     1cc: 72001c1f     	tst	w0, #0xff
     1d0: 54001441     	b.ne	0x458 <___pl_fn_0+0x458>
     1d4: aa1503e0     	mov	x0, x21
     1d8: b9401813     	ldr	w19, [x0, #0x18]
     1dc: b9401c02     	ldr	w2, [x0, #0x1c]
     1e0: 11000660     	add	w0, w19, #0x1
     1e4: 6b02001f     	cmp	w0, w2
     1e8: 54001208     	b.hi	0x428 <___pl_fn_0+0x428>
     1ec: aa1503e2     	mov	x2, x21
     1f0: f9401042     	ldr	x2, [x2, #0x20]
     1f4: aa1603e3     	mov	x3, x22
     1f8: b8335843     	str	w3, [x2, w19, uxtw #2]
     1fc: aa1503e2     	mov	x2, x21
     200: b9001840     	str	w0, [x2, #0x18]
     204: aa1503e0     	mov	x0, x21
     208: b9401000     	ldr	w0, [x0, #0x10]
     20c: b9401442     	ldr	w2, [x2, #0x14]
     210: 6b02001f     	cmp	w0, w2
     214: 54000f22     	b.hs	0x3f8 <___pl_fn_0+0x3f8>
     218: aa1503e0     	mov	x0, x21
     21c: 94000000     	bl	0x21c <___pl_fn_0+0x21c>
     220: aa1503e1     	mov	x1, x21
     224: b9402c21     	ldr	w1, [x1, #0x2c]
     228: 35001481     	cbnz	w1, 0x4b8 <___pl_fn_0+0x4b8>
     22c: aa1503e1     	mov	x1, x21
     230: b9001833     	str	w19, [x1, #0x18]
     234: aa1603e1     	mov	x1, x22
     238: 35000081     	cbnz	w1, 0x248 <___pl_fn_0+0x248>
     23c: 14000063     	b	0x3c8 <___pl_fn_0+0x3c8>
     240: aa1503e0     	mov	x0, x21
     244: 1400000e     	b	0x27c <___pl_fn_0+0x27c>
     248: aa1503e1     	mov	x1, x21
     24c: f9400027     	ldr	x7, [x1]
     250: aa1603e8     	mov	x8, x22
     254: 2a0803e6     	mov	w6, w8
     258: 8b060ce6     	add	x6, x7, x6, lsl #3
     25c: aa1603ea     	mov	x10, x22
     260: f86a58e8     	ldr	x8, [x7, w10, uxtw #3]
     264: 2a0003e7     	mov	w7, w0
     268: d360fd08     	lsr	x8, x8, #32
     26c: 92403d08     	and	x8, x8, #0xffff
     270: 91000508     	add	x8, x8, #0x1
     274: f82878c7     	str	x7, [x6, x8, lsl #3]
     278: aa1503e0     	mov	x0, x21
     27c: aa1503e0     	mov	x0, x21
     280: b9401008     	ldr	w8, [x0, #0x10]
     284: 51000508     	sub	w8, w8, #0x1
     288: b9001008     	str	w8, [x0, #0x10]
     28c: aa1603e0     	mov	x0, x22
     290: 910103ff     	add	sp, sp, #0x40
     294: a8c153f3     	ldp	x19, x20, [sp], #0x10
     298: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     29c: f84107f7     	ldr	x23, [sp], #0x10
     2a0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     2a4: d65f03c0     	ret
     2a8: aa0103e0     	mov	x0, x1
     2ac: aa0103f6     	mov	x22, x1
     2b0: 35000080     	cbnz	w0, 0x2c0 <___pl_fn_0+0x2c0>
     2b4: 14000075     	b	0x488 <___pl_fn_0+0x488>
     2b8: aa1503e0     	mov	x0, x21
     2bc: 1400000e     	b	0x2f4 <___pl_fn_0+0x2f4>
     2c0: aa1503e0     	mov	x0, x21
     2c4: f9400001     	ldr	x1, [x0]
     2c8: aa1603e0     	mov	x0, x22
     2cc: 2a0003e0     	mov	w0, w0
     2d0: 8b000c20     	add	x0, x1, x0, lsl #3
     2d4: aa1603e2     	mov	x2, x22
     2d8: f8625822     	ldr	x2, [x1, w2, uxtw #3]
     2dc: d2800021     	mov	x1, #0x1                ; =1
     2e0: d360fc42     	lsr	x2, x2, #32
     2e4: 92403c42     	and	x2, x2, #0xffff
     2e8: 91000842     	add	x2, x2, #0x2
     2ec: f8227801     	str	x1, [x0, x2, lsl #3]
     2f0: aa1503e0     	mov	x0, x21
     2f4: aa1503e0     	mov	x0, x21
     2f8: b9401000     	ldr	w0, [x0, #0x10]
     2fc: 51000400     	sub	w0, w0, #0x1
     300: aa1503e1     	mov	x1, x21
     304: b9001020     	str	w0, [x1, #0x10]
     308: aa1603e0     	mov	x0, x22
     30c: 910103ff     	add	sp, sp, #0x40
     310: a8c153f3     	ldp	x19, x20, [sp], #0x10
     314: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     318: f84107f7     	ldr	x23, [sp], #0x10
     31c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     320: d65f03c0     	ret
     324: aa0003f5     	mov	x21, x0
     328: 14000006     	b	0x340 <___pl_fn_0+0x340>
     32c: aa0003f5     	mov	x21, x0
     330: 14000004     	b	0x340 <___pl_fn_0+0x340>
     334: aa0003f5     	mov	x21, x0
     338: 14000002     	b	0x340 <___pl_fn_0+0x340>
     33c: aa0003f5     	mov	x21, x0
     340: 52800002     	mov	w2, #0x0                ; =0
     344: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     348: f940016b     	ldr	x11, [x11]
     34c: aa1503e0     	mov	x0, x21
     350: aa0203e1     	mov	x1, x2
     354: d63f0160     	blr	x11
     358: 34ffe8e0     	cbz	w0, 0x74 <___pl_fn_0+0x74>
     35c: 14000057     	b	0x4b8 <___pl_fn_0+0x4b8>
     360: aa0103f6     	mov	x22, x1
     364: d2800040     	mov	x0, #0x2                ; =2
     368: 910003e3     	mov	x3, sp
     36c: f80003e0     	stur	x0, [sp]
     370: d2800000     	mov	x0, #0x0                ; =0
     374: f80083e0     	stur	x0, [sp, #0x8]
     378: 52800041     	mov	w1, #0x2                ; =2
     37c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     380: f9400084     	ldr	x4, [x4]
     384: aa1503e0     	mov	x0, x21
     388: aa1603e2     	mov	x2, x22
     38c: d63f0080     	blr	x4
     390: 34ffed40     	cbz	w0, 0x138 <___pl_fn_0+0x138>
     394: 14000049     	b	0x4b8 <___pl_fn_0+0x4b8>
     398: d2800000     	mov	x0, #0x0                ; =0
     39c: 910043e3     	add	x3, sp, #0x10
     3a0: f80103e0     	stur	x0, [sp, #0x10]
     3a4: f80183f3     	stur	x19, [sp, #0x18]
     3a8: 52800061     	mov	w1, #0x3                ; =3
     3ac: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     3b0: f9400084     	ldr	x4, [x4]
     3b4: aa1503e0     	mov	x0, x21
     3b8: aa1603e2     	mov	x2, x22
     3bc: d63f0080     	blr	x4
     3c0: 34fff000     	cbz	w0, 0x1c0 <___pl_fn_0+0x1c0>
     3c4: 1400003d     	b	0x4b8 <___pl_fn_0+0x4b8>
     3c8: 910083e3     	add	x3, sp, #0x20
     3cc: f80203f4     	stur	x20, [sp, #0x20]
     3d0: 2a0003e2     	mov	w2, w0
     3d4: f80283e2     	stur	x2, [sp, #0x28]
     3d8: 528000e1     	mov	w1, #0x7                ; =7
     3dc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     3e0: f9400084     	ldr	x4, [x4]
     3e4: aa1503e0     	mov	x0, x21
     3e8: aa1603e2     	mov	x2, x22
     3ec: d63f0080     	blr	x4
     3f0: 34fff280     	cbz	w0, 0x240 <___pl_fn_0+0x240>
     3f4: 14000031     	b	0x4b8 <___pl_fn_0+0x4b8>
     3f8: 528000c1     	mov	w1, #0x6                ; =6
     3fc: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     400: f940014a     	ldr	x10, [x10]
     404: aa1503e0     	mov	x0, x21
     408: d63f0140     	blr	x10
     40c: aa1703e0     	mov	x0, x23
     410: 910103ff     	add	sp, sp, #0x40
     414: a8c153f3     	ldp	x19, x20, [sp], #0x10
     418: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     41c: f84107f7     	ldr	x23, [sp], #0x10
     420: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     424: d65f03c0     	ret
     428: 528000a1     	mov	w1, #0x5                ; =5
     42c: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     430: f940016b     	ldr	x11, [x11]
     434: aa1503e0     	mov	x0, x21
     438: d63f0160     	blr	x11
     43c: aa1703e0     	mov	x0, x23
     440: 910103ff     	add	sp, sp, #0x40
     444: a8c153f3     	ldp	x19, x20, [sp], #0x10
     448: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     44c: f84107f7     	ldr	x23, [sp], #0x10
     450: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     454: d65f03c0     	ret
     458: 52800081     	mov	w1, #0x4                ; =4
     45c: 9000000c     	adrp	x12, 0x0 <___pl_fn_0>
     460: f940018c     	ldr	x12, [x12]
     464: aa1503e0     	mov	x0, x21
     468: d63f0180     	blr	x12
     46c: aa1703e0     	mov	x0, x23
     470: 910103ff     	add	sp, sp, #0x40
     474: a8c153f3     	ldp	x19, x20, [sp], #0x10
     478: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     47c: f84107f7     	ldr	x23, [sp], #0x10
     480: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     484: d65f03c0     	ret
     488: d280004e     	mov	x14, #0x2               ; =2
     48c: 9100c3e3     	add	x3, sp, #0x30
     490: f80303ee     	stur	x14, [sp, #0x30]
     494: d280002f     	mov	x15, #0x1               ; =1
     498: f80383ef     	stur	x15, [sp, #0x38]
     49c: 52800101     	mov	w1, #0x8                ; =8
     4a0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     4a4: f9400084     	ldr	x4, [x4]
     4a8: aa1503e0     	mov	x0, x21
     4ac: aa1603e2     	mov	x2, x22
     4b0: d63f0080     	blr	x4
     4b4: 34fff020     	cbz	w0, 0x2b8 <___pl_fn_0+0x2b8>
     4b8: 52800000     	mov	w0, #0x0                ; =0
     4bc: 910103ff     	add	sp, sp, #0x40
     4c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     4c4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     4c8: f84107f7     	ldr	x23, [sp], #0x10
     4cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     4d0: d65f03c0     	ret
     4d4: 52800021     	mov	w1, #0x1                ; =1
     4d8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     4dc: f9400042     	ldr	x2, [x2]
     4e0: aa1503e0     	mov	x0, x21
     4e4: d63f0040     	blr	x2
     4e8: aa1703e0     	mov	x0, x23
     4ec: 910103ff     	add	sp, sp, #0x40
     4f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     4f4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     4f8: f84107f7     	ldr	x23, [sp], #0x10
     4fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     500: d65f03c0     	ret

0000000000000504 <___pl_fn_1>:
     504: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     508: 910003fd     	mov	x29, sp
     50c: f81f0ff5     	str	x21, [sp, #-0x10]!
     510: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     514: b9401003     	ldr	w3, [x0, #0x10]
     518: 11000463     	add	w3, w3, #0x1
     51c: b9001003     	str	w3, [x0, #0x10]
     520: aa0003f3     	mov	x19, x0
     524: 34001701     	cbz	w1, 0x804 <___pl_fn_1+0x300>
     528: 340015a2     	cbz	w2, 0x7dc <___pl_fn_1+0x2d8>
     52c: aa0203f4     	mov	x20, x2
     530: aa0103f5     	mov	x21, x1
     534: 34000d82     	cbz	w2, 0x6e4 <___pl_fn_1+0x1e0>
     538: aa1303e0     	mov	x0, x19
     53c: f9400001     	ldr	x1, [x0]
     540: 2a0203e0     	mov	w0, w2
     544: 8b000c20     	add	x0, x1, x0, lsl #3
     548: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     54c: aa0203f4     	mov	x20, x2
     550: d360fc21     	lsr	x1, x1, #32
     554: 92403c21     	and	x1, x1, #0xffff
     558: 91000821     	add	x1, x1, #0x2
     55c: d37df021     	lsl	x1, x1, #3
     560: 38616800     	ldrb	w0, [x0, x1]
     564: 53001c01     	uxtb	w1, w0
     568: 7100083f     	cmp	w1, #0x2
     56c: 54000081     	b.ne	0x57c <___pl_fn_1+0x78>
     570: 1400005e     	b	0x6e8 <___pl_fn_1+0x1e4>
     574: aa1303e0     	mov	x0, x19
     578: f9401800     	ldr	x0, [x0, #0x30]
     57c: 52000000     	eor	w0, w0, #0x1
     580: 72001c1f     	tst	w0, #0xff
     584: 54000161     	b.ne	0x5b0 <___pl_fn_1+0xac>
     588: aa1303e0     	mov	x0, x19
     58c: b9401000     	ldr	w0, [x0, #0x10]
     590: 51000400     	sub	w0, w0, #0x1
     594: aa1303ee     	mov	x14, x19
     598: b90011c0     	str	w0, [x14, #0x10]
     59c: 52800000     	mov	w0, #0x0                ; =0
     5a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     5a4: f84107f5     	ldr	x21, [sp], #0x10
     5a8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     5ac: d65f03c0     	ret
     5b0: aa1503e2     	mov	x2, x21
     5b4: 34000ac2     	cbz	w2, 0x70c <___pl_fn_1+0x208>
     5b8: aa1303e0     	mov	x0, x19
     5bc: f9400001     	ldr	x1, [x0]
     5c0: 2a0203e0     	mov	w0, w2
     5c4: 8b000c20     	add	x0, x1, x0, lsl #3
     5c8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     5cc: aa0203f5     	mov	x21, x2
     5d0: d360fc21     	lsr	x1, x1, #32
     5d4: 92403c21     	and	x1, x1, #0xffff
     5d8: 91000821     	add	x1, x1, #0x2
     5dc: d37df021     	lsl	x1, x1, #3
     5e0: 38616800     	ldrb	w0, [x0, x1]
     5e4: 53001c01     	uxtb	w1, w0
     5e8: 7100083f     	cmp	w1, #0x2
     5ec: 54000081     	b.ne	0x5fc <___pl_fn_1+0xf8>
     5f0: 14000048     	b	0x710 <___pl_fn_1+0x20c>
     5f4: aa1303e0     	mov	x0, x19
     5f8: f9401800     	ldr	x0, [x0, #0x30]
     5fc: 72001c1f     	tst	w0, #0xff
     600: 540005e1     	b.ne	0x6bc <___pl_fn_1+0x1b8>
     604: aa1503e2     	mov	x2, x21
     608: 34000962     	cbz	w2, 0x734 <___pl_fn_1+0x230>
     60c: aa1303e0     	mov	x0, x19
     610: f9400001     	ldr	x1, [x0]
     614: aa1503e2     	mov	x2, x21
     618: 2a0203e0     	mov	w0, w2
     61c: 8b000c20     	add	x0, x1, x0, lsl #3
     620: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     624: d360fc21     	lsr	x1, x1, #32
     628: 92403c21     	and	x1, x1, #0xffff
     62c: 91000421     	add	x1, x1, #0x1
     630: d37df021     	lsl	x1, x1, #3
     634: b8616800     	ldr	w0, [x0, x1]
     638: 350000c0     	cbnz	w0, 0x650 <___pl_fn_1+0x14c>
     63c: 1400003e     	b	0x734 <___pl_fn_1+0x230>
     640: aa1303e0     	mov	x0, x19
     644: f9401802     	ldr	x2, [x0, #0x30]
     648: aa0203f5     	mov	x21, x2
     64c: 14000003     	b	0x658 <___pl_fn_1+0x154>
     650: aa0003e2     	mov	x2, x0
     654: aa0003f5     	mov	x21, x0
     658: 34000ae2     	cbz	w2, 0x7b4 <___pl_fn_1+0x2b0>
     65c: aa1403e2     	mov	x2, x20
     660: 340007c2     	cbz	w2, 0x758 <___pl_fn_1+0x254>
     664: aa1303e0     	mov	x0, x19
     668: f9400009     	ldr	x9, [x0]
     66c: aa1403e2     	mov	x2, x20
     670: 2a0203e8     	mov	w8, w2
     674: 8b080d28     	add	x8, x9, x8, lsl #3
     678: f8625929     	ldr	x9, [x9, w2, uxtw #3]
     67c: d360fd29     	lsr	x9, x9, #32
     680: 92403d29     	and	x9, x9, #0xffff
     684: 91000529     	add	x9, x9, #0x1
     688: d37df129     	lsl	x9, x9, #3
     68c: b8696908     	ldr	w8, [x8, x9]
     690: 350000c8     	cbnz	w8, 0x6a8 <___pl_fn_1+0x1a4>
     694: 14000031     	b	0x758 <___pl_fn_1+0x254>
     698: aa1303e0     	mov	x0, x19
     69c: f9401802     	ldr	x2, [x0, #0x30]
     6a0: aa0203f4     	mov	x20, x2
     6a4: 14000003     	b	0x6b0 <___pl_fn_1+0x1ac>
     6a8: aa0803e2     	mov	x2, x8
     6ac: aa0803f4     	mov	x20, x8
     6b0: 340006e2     	cbz	w2, 0x78c <___pl_fn_1+0x288>
     6b4: aa1403e2     	mov	x2, x20
     6b8: 17ffff9f     	b	0x534 <___pl_fn_1+0x30>
     6bc: aa1303e0     	mov	x0, x19
     6c0: b9401000     	ldr	w0, [x0, #0x10]
     6c4: 51000400     	sub	w0, w0, #0x1
     6c8: aa1303e1     	mov	x1, x19
     6cc: b9001020     	str	w0, [x1, #0x10]
     6d0: 52800020     	mov	w0, #0x1                ; =1
     6d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6d8: f84107f5     	ldr	x21, [sp], #0x10
     6dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6e0: d65f03c0     	ret
     6e4: aa0203f4     	mov	x20, x2
     6e8: 52800161     	mov	w1, #0xb                ; =11
     6ec: 52800043     	mov	w3, #0x2                ; =2
     6f0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     6f4: f9400084     	ldr	x4, [x4]
     6f8: aa1303e0     	mov	x0, x19
     6fc: aa1403e2     	mov	x2, x20
     700: d63f0080     	blr	x4
     704: 34fff380     	cbz	w0, 0x574 <___pl_fn_1+0x70>
     708: 1400001c     	b	0x778 <___pl_fn_1+0x274>
     70c: aa0203f5     	mov	x21, x2
     710: 52800181     	mov	w1, #0xc                ; =12
     714: 52800043     	mov	w3, #0x2                ; =2
     718: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     71c: f9400084     	ldr	x4, [x4]
     720: aa1303e0     	mov	x0, x19
     724: aa1503e2     	mov	x2, x21
     728: d63f0080     	blr	x4
     72c: 34fff640     	cbz	w0, 0x5f4 <___pl_fn_1+0xf0>
     730: 14000012     	b	0x778 <___pl_fn_1+0x274>
     734: 528001a1     	mov	w1, #0xd                ; =13
     738: 52800023     	mov	w3, #0x1                ; =1
     73c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     740: f9400084     	ldr	x4, [x4]
     744: aa1503e2     	mov	x2, x21
     748: aa1303e0     	mov	x0, x19
     74c: d63f0080     	blr	x4
     750: 34fff780     	cbz	w0, 0x640 <___pl_fn_1+0x13c>
     754: 14000009     	b	0x778 <___pl_fn_1+0x274>
     758: 528001e1     	mov	w1, #0xf                ; =15
     75c: 52800023     	mov	w3, #0x1                ; =1
     760: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     764: f940014a     	ldr	x10, [x10]
     768: aa1403e2     	mov	x2, x20
     76c: aa1303e0     	mov	x0, x19
     770: d63f0140     	blr	x10
     774: 34fff920     	cbz	w0, 0x698 <___pl_fn_1+0x194>
     778: 52800000     	mov	w0, #0x0                ; =0
     77c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     780: f84107f5     	ldr	x21, [sp], #0x10
     784: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     788: d65f03c0     	ret
     78c: 52800201     	mov	w1, #0x10               ; =16
     790: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     794: f9400042     	ldr	x2, [x2]
     798: aa1303e0     	mov	x0, x19
     79c: d63f0040     	blr	x2
     7a0: 52800000     	mov	w0, #0x0                ; =0
     7a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7a8: f84107f5     	ldr	x21, [sp], #0x10
     7ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7b0: d65f03c0     	ret
     7b4: 528001c1     	mov	w1, #0xe                ; =14
     7b8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7bc: f9400042     	ldr	x2, [x2]
     7c0: aa1303e0     	mov	x0, x19
     7c4: d63f0040     	blr	x2
     7c8: 52800000     	mov	w0, #0x0                ; =0
     7cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7d0: f84107f5     	ldr	x21, [sp], #0x10
     7d4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7d8: d65f03c0     	ret
     7dc: 52800141     	mov	w1, #0xa                ; =10
     7e0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7e4: f9400042     	ldr	x2, [x2]
     7e8: aa1303e0     	mov	x0, x19
     7ec: d63f0040     	blr	x2
     7f0: 52800000     	mov	w0, #0x0                ; =0
     7f4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7f8: f84107f5     	ldr	x21, [sp], #0x10
     7fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     800: d65f03c0     	ret
     804: 52800121     	mov	w1, #0x9                ; =9
     808: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     80c: f9400042     	ldr	x2, [x2]
     810: aa1303e0     	mov	x0, x19
     814: d63f0040     	blr	x2
     818: 52800000     	mov	w0, #0x0                ; =0
     81c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     820: f84107f5     	ldr	x21, [sp], #0x10
     824: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     828: d65f03c0     	ret

000000000000082c <___pl_fn_2>:
     82c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     830: 910003fd     	mov	x29, sp
     834: f81f0ffb     	str	x27, [sp, #-0x10]!
     838: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
     83c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     840: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     844: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     848: b9401004     	ldr	w4, [x0, #0x10]
     84c: 11000484     	add	w4, w4, #0x1
     850: b9001004     	str	w4, [x0, #0x10]
     854: b9401817     	ldr	w23, [x0, #0x18]
     858: b9401c04     	ldr	w4, [x0, #0x1c]
     85c: 11000ee5     	add	w5, w23, #0x3
     860: 6b0400bf     	cmp	w5, w4
     864: 54003108     	b.hi	0xe84 <___pl_fn_2+0x658>
     868: f9401004     	ldr	x4, [x0, #0x20]
     86c: 2a1703e5     	mov	w5, w23
     870: 8b050885     	add	x5, x4, x5, lsl #2
     874: b8375881     	str	w1, [x4, w23, uxtw #2]
     878: aa0103e4     	mov	x4, x1
     87c: b90004a2     	str	w2, [x5, #0x4]
     880: aa0203ef     	mov	x15, x2
     884: b90008a3     	str	w3, [x5, #0x8]
     888: aa0303f9     	mov	x25, x3
     88c: 11000ee1     	add	w1, w23, #0x3
     890: b9001801     	str	w1, [x0, #0x18]
     894: b9401001     	ldr	w1, [x0, #0x10]
     898: b9401402     	ldr	w2, [x0, #0x14]
     89c: aa0003f8     	mov	x24, x0
     8a0: 6b02003f     	cmp	w1, w2
     8a4: 54002d62     	b.hs	0xe50 <___pl_fn_2+0x624>
     8a8: aa0f03f3     	mov	x19, x15
     8ac: aa0403f4     	mov	x20, x4
     8b0: aa1803e0     	mov	x0, x24
     8b4: aa1303e1     	mov	x1, x19
     8b8: aa1403e2     	mov	x2, x20
     8bc: 94000000     	bl	0x8bc <___pl_fn_2+0x90>
     8c0: aa1803e1     	mov	x1, x24
     8c4: b9402c21     	ldr	w1, [x1, #0x2c]
     8c8: 35002b41     	cbnz	w1, 0xe30 <___pl_fn_2+0x604>
     8cc: aa1803e1     	mov	x1, x24
     8d0: b9001837     	str	w23, [x1, #0x18]
     8d4: 72001c1f     	tst	w0, #0xff
     8d8: 540001c1     	b.ne	0x910 <___pl_fn_2+0xe4>
     8dc: aa1803e0     	mov	x0, x24
     8e0: b9401000     	ldr	w0, [x0, #0x10]
     8e4: 51000400     	sub	w0, w0, #0x1
     8e8: aa1803e1     	mov	x1, x24
     8ec: b9001020     	str	w0, [x1, #0x10]
     8f0: aa1903e0     	mov	x0, x25
     8f4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8f8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8fc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     900: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     904: f84107fb     	ldr	x27, [sp], #0x10
     908: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     90c: d65f03c0     	ret
     910: 340018b4     	cbz	w20, 0xc24 <___pl_fn_2+0x3f8>
     914: aa1803e0     	mov	x0, x24
     918: f9400001     	ldr	x1, [x0]
     91c: 2a1403e0     	mov	w0, w20
     920: 8b000c20     	add	x0, x1, x0, lsl #3
     924: f8745821     	ldr	x1, [x1, w20, uxtw #3]
     928: d360fc21     	lsr	x1, x1, #32
     92c: 92403c21     	and	x1, x1, #0xffff
     930: 91000421     	add	x1, x1, #0x1
     934: d37df021     	lsl	x1, x1, #3
     938: b8616801     	ldr	w1, [x0, x1]
     93c: 350000a1     	cbnz	w1, 0x950 <___pl_fn_2+0x124>
     940: 140000b9     	b	0xc24 <___pl_fn_2+0x3f8>
     944: aa1803e0     	mov	x0, x24
     948: f9401801     	ldr	x1, [x0, #0x30]
     94c: 14000002     	b	0x954 <___pl_fn_2+0x128>
     950: aa1803e0     	mov	x0, x24
     954: aa1803e0     	mov	x0, x24
     958: b9401815     	ldr	w21, [x0, #0x18]
     95c: b9401c00     	ldr	w0, [x0, #0x1c]
     960: 110012a2     	add	w2, w21, #0x4
     964: 6b00005f     	cmp	w2, w0
     968: 540024a8     	b.hi	0xdfc <___pl_fn_2+0x5d0>
     96c: aa1803e0     	mov	x0, x24
     970: f9401002     	ldr	x2, [x0, #0x20]
     974: 2a1503e0     	mov	w0, w21
     978: 8b000840     	add	x0, x2, x0, lsl #2
     97c: b8355854     	str	w20, [x2, w21, uxtw #2]
     980: b9000413     	str	w19, [x0, #0x4]
     984: aa1903e2     	mov	x2, x25
     988: b9000802     	str	w2, [x0, #0x8]
     98c: b9000c01     	str	w1, [x0, #0xc]
     990: 110012a0     	add	w0, w21, #0x4
     994: aa1803e2     	mov	x2, x24
     998: b9001840     	str	w0, [x2, #0x18]
     99c: aa1803e0     	mov	x0, x24
     9a0: b9401000     	ldr	w0, [x0, #0x10]
     9a4: b9401442     	ldr	w2, [x2, #0x14]
     9a8: 6b02001f     	cmp	w0, w2
     9ac: 540020e2     	b.hs	0xdc8 <___pl_fn_2+0x59c>
     9b0: aa1803e0     	mov	x0, x24
     9b4: aa1303e2     	mov	x2, x19
     9b8: aa1903e3     	mov	x3, x25
     9bc: 94000000     	bl	0x9bc <___pl_fn_2+0x190>
     9c0: aa0003f7     	mov	x23, x0
     9c4: aa1803e0     	mov	x0, x24
     9c8: b9402c00     	ldr	w0, [x0, #0x2c]
     9cc: 35002320     	cbnz	w0, 0xe30 <___pl_fn_2+0x604>
     9d0: aa1803e0     	mov	x0, x24
     9d4: b9001815     	str	w21, [x0, #0x18]
     9d8: 34001393     	cbz	w19, 0xc48 <___pl_fn_2+0x41c>
     9dc: aa1803e0     	mov	x0, x24
     9e0: f9400001     	ldr	x1, [x0]
     9e4: 2a1303e0     	mov	w0, w19
     9e8: 8b000c20     	add	x0, x1, x0, lsl #3
     9ec: f8735821     	ldr	x1, [x1, w19, uxtw #3]
     9f0: d360fc21     	lsr	x1, x1, #32
     9f4: 92403c21     	and	x1, x1, #0xffff
     9f8: 91000421     	add	x1, x1, #0x1
     9fc: d37df021     	lsl	x1, x1, #3
     a00: b8616801     	ldr	w1, [x0, x1]
     a04: 350000a1     	cbnz	w1, 0xa18 <___pl_fn_2+0x1ec>
     a08: 14000090     	b	0xc48 <___pl_fn_2+0x41c>
     a0c: aa1803e0     	mov	x0, x24
     a10: f9401801     	ldr	x1, [x0, #0x30]
     a14: 14000002     	b	0xa1c <___pl_fn_2+0x1f0>
     a18: aa1803e0     	mov	x0, x24
     a1c: aa1803e0     	mov	x0, x24
     a20: b9401816     	ldr	w22, [x0, #0x18]
     a24: b9401c04     	ldr	w4, [x0, #0x1c]
     a28: 110016c5     	add	w5, w22, #0x5
     a2c: 6b0400bf     	cmp	w5, w4
     a30: 54001b28     	b.hi	0xd94 <___pl_fn_2+0x568>
     a34: aa1803e0     	mov	x0, x24
     a38: f9401007     	ldr	x7, [x0, #0x20]
     a3c: 2a1603e6     	mov	w6, w22
     a40: 8b0608e6     	add	x6, x7, x6, lsl #2
     a44: b83658f4     	str	w20, [x7, w22, uxtw #2]
     a48: b90004d3     	str	w19, [x6, #0x4]
     a4c: aa1903e0     	mov	x0, x25
     a50: b90008c0     	str	w0, [x6, #0x8]
     a54: aa1703f5     	mov	x21, x23
     a58: b9000cd5     	str	w21, [x6, #0xc]
     a5c: b90010c1     	str	w1, [x6, #0x10]
     a60: 110016cb     	add	w11, w22, #0x5
     a64: aa1803e0     	mov	x0, x24
     a68: b900180b     	str	w11, [x0, #0x18]
     a6c: b940100c     	ldr	w12, [x0, #0x10]
     a70: b940140d     	ldr	w13, [x0, #0x14]
     a74: 6b0d019f     	cmp	w12, w13
     a78: 54001742     	b.hs	0xd60 <___pl_fn_2+0x534>
     a7c: aa1803e0     	mov	x0, x24
     a80: aa1903e2     	mov	x2, x25
     a84: aa1403e3     	mov	x3, x20
     a88: 94000000     	bl	0xa88 <___pl_fn_2+0x25c>
     a8c: aa0003fa     	mov	x26, x0
     a90: aa1803e0     	mov	x0, x24
     a94: b9402c0e     	ldr	w14, [x0, #0x2c]
     a98: 35001cce     	cbnz	w14, 0xe30 <___pl_fn_2+0x604>
     a9c: aa1803e0     	mov	x0, x24
     aa0: b9001816     	str	w22, [x0, #0x18]
     aa4: aa1903e0     	mov	x0, x25
     aa8: 34000e20     	cbz	w0, 0xc6c <___pl_fn_2+0x440>
     aac: aa1803e0     	mov	x0, x24
     ab0: f9400001     	ldr	x1, [x0]
     ab4: aa1903e0     	mov	x0, x25
     ab8: 2a0003e0     	mov	w0, w0
     abc: 8b000c20     	add	x0, x1, x0, lsl #3
     ac0: aa1903e2     	mov	x2, x25
     ac4: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     ac8: d360fc21     	lsr	x1, x1, #32
     acc: 92403c21     	and	x1, x1, #0xffff
     ad0: 91000421     	add	x1, x1, #0x1
     ad4: d37df021     	lsl	x1, x1, #3
     ad8: b8616801     	ldr	w1, [x0, x1]
     adc: 350000a1     	cbnz	w1, 0xaf0 <___pl_fn_2+0x2c4>
     ae0: 14000063     	b	0xc6c <___pl_fn_2+0x440>
     ae4: aa1803e0     	mov	x0, x24
     ae8: f9401801     	ldr	x1, [x0, #0x30]
     aec: 14000002     	b	0xaf4 <___pl_fn_2+0x2c8>
     af0: aa1803e0     	mov	x0, x24
     af4: aa1803e0     	mov	x0, x24
     af8: b9401819     	ldr	w25, [x0, #0x18]
     afc: b9401c02     	ldr	w2, [x0, #0x1c]
     b00: 11001720     	add	w0, w25, #0x5
     b04: 6b02001f     	cmp	w0, w2
     b08: 54001128     	b.hi	0xd2c <___pl_fn_2+0x500>
     b0c: aa1803ef     	mov	x15, x24
     b10: f94011e3     	ldr	x3, [x15, #0x20]
     b14: 2a1903fb     	mov	w27, w25
     b18: 8b1b0862     	add	x2, x3, x27, lsl #2
     b1c: b8395874     	str	w20, [x3, w25, uxtw #2]
     b20: aa1403e4     	mov	x4, x20
     b24: b9000453     	str	w19, [x2, #0x4]
     b28: aa1303ef     	mov	x15, x19
     b2c: b9000855     	str	w21, [x2, #0x8]
     b30: aa1a03f3     	mov	x19, x26
     b34: b9000c53     	str	w19, [x2, #0xc]
     b38: b9001041     	str	w1, [x2, #0x10]
     b3c: aa1803e2     	mov	x2, x24
     b40: b9001840     	str	w0, [x2, #0x18]
     b44: aa1803e0     	mov	x0, x24
     b48: b9401000     	ldr	w0, [x0, #0x10]
     b4c: b9401442     	ldr	w2, [x2, #0x14]
     b50: 6b02001f     	cmp	w0, w2
     b54: 54000d22     	b.hs	0xcf8 <___pl_fn_2+0x4cc>
     b58: aa0403e2     	mov	x2, x4
     b5c: aa0f03e3     	mov	x3, x15
     b60: aa1803e0     	mov	x0, x24
     b64: 94000000     	bl	0xb64 <___pl_fn_2+0x338>
     b68: aa1803e1     	mov	x1, x24
     b6c: b9402c21     	ldr	w1, [x1, #0x2c]
     b70: 35001601     	cbnz	w1, 0xe30 <___pl_fn_2+0x604>
     b74: aa1803e1     	mov	x1, x24
     b78: b9001839     	str	w25, [x1, #0x18]
     b7c: b9401c22     	ldr	w2, [x1, #0x1c]
     b80: 11000f21     	add	w1, w25, #0x3
     b84: 6b02003f     	cmp	w1, w2
     b88: 540009e8     	b.hi	0xcc4 <___pl_fn_2+0x498>
     b8c: aa1803e2     	mov	x2, x24
     b90: f9401043     	ldr	x3, [x2, #0x20]
     b94: 8b1b0862     	add	x2, x3, x27, lsl #2
     b98: b8395875     	str	w21, [x3, w25, uxtw #2]
     b9c: aa1503f7     	mov	x23, x21
     ba0: b9000453     	str	w19, [x2, #0x4]
     ba4: aa1303fa     	mov	x26, x19
     ba8: b9000840     	str	w0, [x2, #0x8]
     bac: aa0003e3     	mov	x3, x0
     bb0: aa1803e0     	mov	x0, x24
     bb4: b9001801     	str	w1, [x0, #0x18]
     bb8: b9401000     	ldr	w0, [x0, #0x10]
     bbc: aa1803e1     	mov	x1, x24
     bc0: b9401421     	ldr	w1, [x1, #0x14]
     bc4: 6b01001f     	cmp	w0, w1
     bc8: 54000642     	b.hs	0xc90 <___pl_fn_2+0x464>
     bcc: aa1703e1     	mov	x1, x23
     bd0: aa1a03e2     	mov	x2, x26
     bd4: aa1803e0     	mov	x0, x24
     bd8: 94000000     	bl	0xbd8 <___pl_fn_2+0x3ac>
     bdc: aa1803e1     	mov	x1, x24
     be0: b9402c21     	ldr	w1, [x1, #0x2c]
     be4: 35001261     	cbnz	w1, 0xe30 <___pl_fn_2+0x604>
     be8: aa1803e1     	mov	x1, x24
     bec: b9001839     	str	w25, [x1, #0x18]
     bf0: aa1803e2     	mov	x2, x24
     bf4: b9401041     	ldr	w1, [x2, #0x10]
     bf8: 51000421     	sub	w1, w1, #0x1
     bfc: aa1803e5     	mov	x5, x24
     c00: b90010a1     	str	w1, [x5, #0x10]
     c04: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c08: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c0c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c10: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c14: f84107fb     	ldr	x27, [sp], #0x10
     c18: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c1c: d65f03c0     	ret
     c20: 14000084     	b	0xe30 <___pl_fn_2+0x604>
     c24: 52800261     	mov	w1, #0x13               ; =19
     c28: 52800023     	mov	w3, #0x1                ; =1
     c2c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c30: f9400084     	ldr	x4, [x4]
     c34: aa1803e0     	mov	x0, x24
     c38: aa1403e2     	mov	x2, x20
     c3c: d63f0080     	blr	x4
     c40: 34ffe820     	cbz	w0, 0x944 <___pl_fn_2+0x118>
     c44: 1400007b     	b	0xe30 <___pl_fn_2+0x604>
     c48: 528002c1     	mov	w1, #0x16               ; =22
     c4c: 52800023     	mov	w3, #0x1                ; =1
     c50: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c54: f9400084     	ldr	x4, [x4]
     c58: aa1803e0     	mov	x0, x24
     c5c: aa1303e2     	mov	x2, x19
     c60: d63f0080     	blr	x4
     c64: 34ffed40     	cbz	w0, 0xa0c <___pl_fn_2+0x1e0>
     c68: 14000072     	b	0xe30 <___pl_fn_2+0x604>
     c6c: 52800321     	mov	w1, #0x19               ; =25
     c70: 52800023     	mov	w3, #0x1                ; =1
     c74: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c78: f9400084     	ldr	x4, [x4]
     c7c: aa1903e2     	mov	x2, x25
     c80: aa1803e0     	mov	x0, x24
     c84: d63f0080     	blr	x4
     c88: 34fff2e0     	cbz	w0, 0xae4 <___pl_fn_2+0x2b8>
     c8c: 14000069     	b	0xe30 <___pl_fn_2+0x604>
     c90: 528003a1     	mov	w1, #0x1d               ; =29
     c94: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c98: f9400042     	ldr	x2, [x2]
     c9c: aa1803e0     	mov	x0, x24
     ca0: d63f0040     	blr	x2
     ca4: 52800000     	mov	w0, #0x0                ; =0
     ca8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     cb0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     cb4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     cb8: f84107fb     	ldr	x27, [sp], #0x10
     cbc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     cc0: d65f03c0     	ret
     cc4: 52800381     	mov	w1, #0x1c               ; =28
     cc8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     ccc: f9400042     	ldr	x2, [x2]
     cd0: aa1803e0     	mov	x0, x24
     cd4: d63f0040     	blr	x2
     cd8: 52800000     	mov	w0, #0x0                ; =0
     cdc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ce0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ce4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ce8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     cec: f84107fb     	ldr	x27, [sp], #0x10
     cf0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     cf4: d65f03c0     	ret
     cf8: 52800361     	mov	w1, #0x1b               ; =27
     cfc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     d00: f9400042     	ldr	x2, [x2]
     d04: aa1803e0     	mov	x0, x24
     d08: d63f0040     	blr	x2
     d0c: 52800000     	mov	w0, #0x0                ; =0
     d10: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d14: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d18: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d1c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d20: f84107fb     	ldr	x27, [sp], #0x10
     d24: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d28: d65f03c0     	ret
     d2c: 52800341     	mov	w1, #0x1a               ; =26
     d30: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     d34: f9400042     	ldr	x2, [x2]
     d38: aa1803e0     	mov	x0, x24
     d3c: d63f0040     	blr	x2
     d40: 52800000     	mov	w0, #0x0                ; =0
     d44: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d48: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d4c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d50: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d54: f84107fb     	ldr	x27, [sp], #0x10
     d58: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d5c: d65f03c0     	ret
     d60: 52800301     	mov	w1, #0x18               ; =24
     d64: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     d68: f9400042     	ldr	x2, [x2]
     d6c: aa1803e0     	mov	x0, x24
     d70: d63f0040     	blr	x2
     d74: 52800000     	mov	w0, #0x0                ; =0
     d78: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d7c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d80: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d84: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d88: f84107fb     	ldr	x27, [sp], #0x10
     d8c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d90: d65f03c0     	ret
     d94: 528002e1     	mov	w1, #0x17               ; =23
     d98: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     d9c: f9400042     	ldr	x2, [x2]
     da0: aa1803e0     	mov	x0, x24
     da4: d63f0040     	blr	x2
     da8: 52800000     	mov	w0, #0x0                ; =0
     dac: a8c153f3     	ldp	x19, x20, [sp], #0x10
     db0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     db4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     db8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     dbc: f84107fb     	ldr	x27, [sp], #0x10
     dc0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     dc4: d65f03c0     	ret
     dc8: 528002a1     	mov	w1, #0x15               ; =21
     dcc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     dd0: f9400042     	ldr	x2, [x2]
     dd4: aa1803e0     	mov	x0, x24
     dd8: d63f0040     	blr	x2
     ddc: 52800000     	mov	w0, #0x0                ; =0
     de0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     de4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     de8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     dec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     df0: f84107fb     	ldr	x27, [sp], #0x10
     df4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     df8: d65f03c0     	ret
     dfc: 52800281     	mov	w1, #0x14               ; =20
     e00: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e04: f9400042     	ldr	x2, [x2]
     e08: aa1803e0     	mov	x0, x24
     e0c: d63f0040     	blr	x2
     e10: 52800000     	mov	w0, #0x0                ; =0
     e14: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e18: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e1c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e20: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e24: f84107fb     	ldr	x27, [sp], #0x10
     e28: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e2c: d65f03c0     	ret
     e30: 52800000     	mov	w0, #0x0                ; =0
     e34: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e38: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e3c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e40: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e44: f84107fb     	ldr	x27, [sp], #0x10
     e48: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e4c: d65f03c0     	ret
     e50: 52800241     	mov	w1, #0x12               ; =18
     e54: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e58: f9400042     	ldr	x2, [x2]
     e5c: aa1803e0     	mov	x0, x24
     e60: d63f0040     	blr	x2
     e64: 52800000     	mov	w0, #0x0                ; =0
     e68: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e6c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e70: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e74: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     e78: f84107fb     	ldr	x27, [sp], #0x10
     e7c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e80: d65f03c0     	ret
     e84: aa0003f8     	mov	x24, x0
     e88: 52800221     	mov	w1, #0x11               ; =17
     e8c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e90: f9400042     	ldr	x2, [x2]
     e94: d63f0040     	blr	x2
     e98: 52800000     	mov	w0, #0x0                ; =0
     e9c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ea0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ea4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ea8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     eac: f84107fb     	ldr	x27, [sp], #0x10
     eb0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     eb4: d65f03c0     	ret

0000000000000eb8 <___pl_fn_3>:
     eb8: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     ebc: 910003fd     	mov	x29, sp
     ec0: f81f0ffc     	str	x28, [sp, #-0x10]!
     ec4: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     ec8: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     ecc: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     ed0: b9401001     	ldr	w1, [x0, #0x10]
     ed4: 11000421     	add	w1, w1, #0x1
     ed8: b9001001     	str	w1, [x0, #0x10]
     edc: aa0003fc     	mov	x28, x0
     ee0: 528003c1     	mov	w1, #0x1e               ; =30
     ee4: 52800002     	mov	w2, #0x0                ; =0
     ee8: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     eec: f9400063     	ldr	x3, [x3]
     ef0: aa1c03e0     	mov	x0, x28
     ef4: d63f0060     	blr	x3
     ef8: 35002160     	cbnz	w0, 0x1324 <___pl_fn_3+0x46c>
     efc: aa1c03e0     	mov	x0, x28
     f00: f9401816     	ldr	x22, [x0, #0x30]
     f04: b9401000     	ldr	w0, [x0, #0x10]
     f08: aa1c03e1     	mov	x1, x28
     f0c: b9401421     	ldr	w1, [x1, #0x14]
     f10: 6b01001f     	cmp	w0, w1
     f14: 54001f22     	b.hs	0x12f8 <___pl_fn_3+0x440>
     f18: aa1c03e0     	mov	x0, x28
     f1c: aa1603e1     	mov	x1, x22
     f20: 94000000     	bl	0xf20 <___pl_fn_3+0x68>
     f24: aa1c03e1     	mov	x1, x28
     f28: b9402c21     	ldr	w1, [x1, #0x2c]
     f2c: 35001fc1     	cbnz	w1, 0x1324 <___pl_fn_3+0x46c>
     f30: d28000a1     	mov	x1, #0x5                ; =5
     f34: eb0102c1     	subs	x1, x22, x1
     f38: 9a9f77e2     	cset	x2, vs
     f3c: 72001c5f     	tst	w2, #0xff
     f40: 54001c61     	b.ne	0x12cc <___pl_fn_3+0x414>
     f44: aa1c03e2     	mov	x2, x28
     f48: b9401853     	ldr	w19, [x2, #0x18]
     f4c: b9401c42     	ldr	w2, [x2, #0x1c]
     f50: 11000674     	add	w20, w19, #0x1
     f54: 6b02029f     	cmp	w20, w2
     f58: 54001a48     	b.hi	0x12a0 <___pl_fn_3+0x3e8>
     f5c: aa1c03e3     	mov	x3, x28
     f60: f9401062     	ldr	x2, [x3, #0x20]
     f64: 2a1303f5     	mov	w21, w19
     f68: b8335840     	str	w0, [x2, w19, uxtw #2]
     f6c: aa0003f7     	mov	x23, x0
     f70: aa1c03e0     	mov	x0, x28
     f74: b9001814     	str	w20, [x0, #0x18]
     f78: b9401000     	ldr	w0, [x0, #0x10]
     f7c: aa1c03eb     	mov	x11, x28
     f80: b9401562     	ldr	w2, [x11, #0x14]
     f84: 6b02001f     	cmp	w0, w2
     f88: 54001762     	b.hs	0x1274 <___pl_fn_3+0x3bc>
     f8c: aa1c03e0     	mov	x0, x28
     f90: 94000000     	bl	0xf90 <___pl_fn_3+0xd8>
     f94: aa1c03e1     	mov	x1, x28
     f98: b9402c21     	ldr	w1, [x1, #0x2c]
     f9c: 35001c41     	cbnz	w1, 0x1324 <___pl_fn_3+0x46c>
     fa0: aa1c03e1     	mov	x1, x28
     fa4: b9001833     	str	w19, [x1, #0x18]
     fa8: d2800121     	mov	x1, #0x9                ; =9
     fac: eb0102c1     	subs	x1, x22, x1
     fb0: 9a9f77e2     	cset	x2, vs
     fb4: 72001c5f     	tst	w2, #0xff
     fb8: 54001481     	b.ne	0x1248 <___pl_fn_3+0x390>
     fbc: aa1c03e2     	mov	x2, x28
     fc0: b9401c42     	ldr	w2, [x2, #0x1c]
     fc4: 11000a63     	add	w3, w19, #0x2
     fc8: 6b02007f     	cmp	w3, w2
     fcc: 54001288     	b.hi	0x121c <___pl_fn_3+0x364>
     fd0: aa1c03e2     	mov	x2, x28
     fd4: f9401042     	ldr	x2, [x2, #0x20]
     fd8: 8b150843     	add	x3, x2, x21, lsl #2
     fdc: aa1703f6     	mov	x22, x23
     fe0: b8335856     	str	w22, [x2, w19, uxtw #2]
     fe4: b9000460     	str	w0, [x3, #0x4]
     fe8: aa0003f8     	mov	x24, x0
     fec: 11000a60     	add	w0, w19, #0x2
     ff0: aa1c03e2     	mov	x2, x28
     ff4: b9001840     	str	w0, [x2, #0x18]
     ff8: aa1c03e0     	mov	x0, x28
     ffc: b9401000     	ldr	w0, [x0, #0x10]
    1000: b9401442     	ldr	w2, [x2, #0x14]
    1004: 6b02001f     	cmp	w0, w2
    1008: 54000f42     	b.hs	0x11f0 <___pl_fn_3+0x338>
    100c: aa1c03e0     	mov	x0, x28
    1010: 94000000     	bl	0x1010 <___pl_fn_3+0x158>
    1014: aa1c03e1     	mov	x1, x28
    1018: b9402c21     	ldr	w1, [x1, #0x2c]
    101c: 35001841     	cbnz	w1, 0x1324 <___pl_fn_3+0x46c>
    1020: aa1c03e1     	mov	x1, x28
    1024: b9001833     	str	w19, [x1, #0x18]
    1028: b9401c21     	ldr	w1, [x1, #0x1c]
    102c: 11000e62     	add	w2, w19, #0x3
    1030: 6b01005f     	cmp	w2, w1
    1034: 54000c88     	b.hi	0x11c4 <___pl_fn_3+0x30c>
    1038: aa1c03e1     	mov	x1, x28
    103c: f9401022     	ldr	x2, [x1, #0x20]
    1040: 8b150841     	add	x1, x2, x21, lsl #2
    1044: b8335856     	str	w22, [x2, w19, uxtw #2]
    1048: aa1803e2     	mov	x2, x24
    104c: aa1603f7     	mov	x23, x22
    1050: b9000422     	str	w2, [x1, #0x4]
    1054: b9000820     	str	w0, [x1, #0x8]
    1058: aa0003e3     	mov	x3, x0
    105c: 11000e60     	add	w0, w19, #0x3
    1060: aa1c03e2     	mov	x2, x28
    1064: b9001840     	str	w0, [x2, #0x18]
    1068: aa1c03e0     	mov	x0, x28
    106c: b9401001     	ldr	w1, [x0, #0x10]
    1070: b9401402     	ldr	w2, [x0, #0x14]
    1074: 6b02003f     	cmp	w1, w2
    1078: 54000902     	b.hs	0x1198 <___pl_fn_3+0x2e0>
    107c: aa1703e1     	mov	x1, x23
    1080: aa1803e2     	mov	x2, x24
    1084: aa1c03e0     	mov	x0, x28
    1088: 94000000     	bl	0x1088 <___pl_fn_3+0x1d0>
    108c: aa1c03eb     	mov	x11, x28
    1090: b9402d63     	ldr	w3, [x11, #0x2c]
    1094: 35001483     	cbnz	w3, 0x1324 <___pl_fn_3+0x46c>
    1098: aa1c03ef     	mov	x15, x28
    109c: b90019f3     	str	w19, [x15, #0x18]
    10a0: aa1c03e1     	mov	x1, x28
    10a4: b9401c26     	ldr	w6, [x1, #0x1c]
    10a8: 6b06029f     	cmp	w20, w6
    10ac: 54000608     	b.hi	0x116c <___pl_fn_3+0x2b4>
    10b0: aa1c03e1     	mov	x1, x28
    10b4: f9401028     	ldr	x8, [x1, #0x20]
    10b8: b8335900     	str	w0, [x8, w19, uxtw #2]
    10bc: aa0003e1     	mov	x1, x0
    10c0: aa1c03e0     	mov	x0, x28
    10c4: b9001814     	str	w20, [x0, #0x18]
    10c8: b940100a     	ldr	w10, [x0, #0x10]
    10cc: b940140b     	ldr	w11, [x0, #0x14]
    10d0: 6b0b015f     	cmp	w10, w11
    10d4: 54000362     	b.hs	0x1140 <___pl_fn_3+0x288>
    10d8: aa1c03e0     	mov	x0, x28
    10dc: 94000000     	bl	0x10dc <___pl_fn_3+0x224>
    10e0: aa0003e2     	mov	x2, x0
    10e4: aa1c03e0     	mov	x0, x28
    10e8: b9402c0c     	ldr	w12, [x0, #0x2c]
    10ec: 350011cc     	cbnz	w12, 0x1324 <___pl_fn_3+0x46c>
    10f0: aa1c03e0     	mov	x0, x28
    10f4: b9001813     	str	w19, [x0, #0x18]
    10f8: 52800541     	mov	w1, #0x2a               ; =42
    10fc: 52802003     	mov	w3, #0x100              ; =256
    1100: 9000000f     	adrp	x15, 0x1000 <___pl_fn_3+0x148>
    1104: f94001ef     	ldr	x15, [x15]
    1108: d63f01e0     	blr	x15
    110c: 350010c0     	cbnz	w0, 0x1324 <___pl_fn_3+0x46c>
    1110: aa1c03e0     	mov	x0, x28
    1114: b9401000     	ldr	w0, [x0, #0x10]
    1118: 51000400     	sub	w0, w0, #0x1
    111c: aa1c03e1     	mov	x1, x28
    1120: b9001020     	str	w0, [x1, #0x10]
    1124: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1128: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    112c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1130: f84107fc     	ldr	x28, [sp], #0x10
    1134: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1138: d65f03c0     	ret
    113c: 1400007a     	b	0x1324 <___pl_fn_3+0x46c>
    1140: 52800521     	mov	w1, #0x29               ; =41
    1144: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    1148: f9400042     	ldr	x2, [x2]
    114c: aa1c03e0     	mov	x0, x28
    1150: d63f0040     	blr	x2
    1154: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1158: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    115c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1160: f84107fc     	ldr	x28, [sp], #0x10
    1164: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1168: d65f03c0     	ret
    116c: 52800501     	mov	w1, #0x28               ; =40
    1170: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    1174: f9400042     	ldr	x2, [x2]
    1178: aa1c03e0     	mov	x0, x28
    117c: d63f0040     	blr	x2
    1180: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1184: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1188: a8c163f7     	ldp	x23, x24, [sp], #0x10
    118c: f84107fc     	ldr	x28, [sp], #0x10
    1190: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1194: d65f03c0     	ret
    1198: 528004e1     	mov	w1, #0x27               ; =39
    119c: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    11a0: f9400042     	ldr	x2, [x2]
    11a4: aa1c03e0     	mov	x0, x28
    11a8: d63f0040     	blr	x2
    11ac: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11b0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    11b4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    11b8: f84107fc     	ldr	x28, [sp], #0x10
    11bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11c0: d65f03c0     	ret
    11c4: 528004c1     	mov	w1, #0x26               ; =38
    11c8: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    11cc: f9400042     	ldr	x2, [x2]
    11d0: aa1c03e0     	mov	x0, x28
    11d4: d63f0040     	blr	x2
    11d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    11e0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    11e4: f84107fc     	ldr	x28, [sp], #0x10
    11e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11ec: d65f03c0     	ret
    11f0: 528004a1     	mov	w1, #0x25               ; =37
    11f4: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    11f8: f9400042     	ldr	x2, [x2]
    11fc: aa1c03e0     	mov	x0, x28
    1200: d63f0040     	blr	x2
    1204: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1208: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    120c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1210: f84107fc     	ldr	x28, [sp], #0x10
    1214: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1218: d65f03c0     	ret
    121c: 52800481     	mov	w1, #0x24               ; =36
    1220: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    1224: f9400042     	ldr	x2, [x2]
    1228: aa1c03e0     	mov	x0, x28
    122c: d63f0040     	blr	x2
    1230: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1234: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1238: a8c163f7     	ldp	x23, x24, [sp], #0x10
    123c: f84107fc     	ldr	x28, [sp], #0x10
    1240: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1244: d65f03c0     	ret
    1248: 52800461     	mov	w1, #0x23               ; =35
    124c: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    1250: f9400042     	ldr	x2, [x2]
    1254: aa1c03e0     	mov	x0, x28
    1258: d63f0040     	blr	x2
    125c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1260: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1264: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1268: f84107fc     	ldr	x28, [sp], #0x10
    126c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1270: d65f03c0     	ret
    1274: 52800441     	mov	w1, #0x22               ; =34
    1278: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    127c: f9400042     	ldr	x2, [x2]
    1280: aa1c03e0     	mov	x0, x28
    1284: d63f0040     	blr	x2
    1288: a8c153f3     	ldp	x19, x20, [sp], #0x10
    128c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1290: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1294: f84107fc     	ldr	x28, [sp], #0x10
    1298: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    129c: d65f03c0     	ret
    12a0: 52800421     	mov	w1, #0x21               ; =33
    12a4: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    12a8: f9400042     	ldr	x2, [x2]
    12ac: aa1c03e0     	mov	x0, x28
    12b0: d63f0040     	blr	x2
    12b4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    12b8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    12bc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    12c0: f84107fc     	ldr	x28, [sp], #0x10
    12c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12c8: d65f03c0     	ret
    12cc: 52800401     	mov	w1, #0x20               ; =32
    12d0: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    12d4: f9400042     	ldr	x2, [x2]
    12d8: aa1c03e0     	mov	x0, x28
    12dc: d63f0040     	blr	x2
    12e0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    12e4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    12e8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    12ec: f84107fc     	ldr	x28, [sp], #0x10
    12f0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12f4: d65f03c0     	ret
    12f8: 528003e1     	mov	w1, #0x1f               ; =31
    12fc: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    1300: f9400042     	ldr	x2, [x2]
    1304: aa1c03e0     	mov	x0, x28
    1308: d63f0040     	blr	x2
    130c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1310: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1314: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1318: f84107fc     	ldr	x28, [sp], #0x10
    131c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1320: d65f03c0     	ret
    1324: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1328: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    132c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1330: f84107fc     	ldr	x28, [sp], #0x10
    1334: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1338: d65f03c0     	ret

000000000000133c <___pl_fn_4>:
    133c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    1340: 910003fd     	mov	x29, sp
    1344: a9bf5ff3     	stp	x19, x23, [sp, #-0x10]!
    1348: aa0103f7     	mov	x23, x1
    134c: b9401001     	ldr	w1, [x0, #0x10]
    1350: 11000421     	add	w1, w1, #0x1
    1354: b9001001     	str	w1, [x0, #0x10]
    1358: aa1703e1     	mov	x1, x23
    135c: 34000aa1     	cbz	w1, 0x14b0 <___pl_fn_4+0x174>
    1360: f9400006     	ldr	x6, [x0]
    1364: aa1703e1     	mov	x1, x23
    1368: aa0003f3     	mov	x19, x0
    136c: 2a0103e5     	mov	w5, w1
    1370: 8b050cc5     	add	x5, x6, x5, lsl #3
    1374: f86158c6     	ldr	x6, [x6, w1, uxtw #3]
    1378: d360fcc6     	lsr	x6, x6, #32
    137c: 92403cc6     	and	x6, x6, #0xffff
    1380: 910008c6     	add	x6, x6, #0x2
    1384: d37df0c6     	lsl	x6, x6, #3
    1388: 386668a0     	ldrb	w0, [x5, x6]
    138c: 53001c05     	uxtb	w5, w0
    1390: 710008bf     	cmp	w5, #0x2
    1394: 54000081     	b.ne	0x13a4 <___pl_fn_4+0x68>
    1398: 14000047     	b	0x14b4 <___pl_fn_4+0x178>
    139c: aa1303e0     	mov	x0, x19
    13a0: f9401800     	ldr	x0, [x0, #0x30]
    13a4: 72001c1f     	tst	w0, #0xff
    13a8: 54000721     	b.ne	0x148c <___pl_fn_4+0x150>
    13ac: aa1703e1     	mov	x1, x23
    13b0: 34000941     	cbz	w1, 0x14d8 <___pl_fn_4+0x19c>
    13b4: aa1303e0     	mov	x0, x19
    13b8: f9400002     	ldr	x2, [x0]
    13bc: 2a0103e0     	mov	w0, w1
    13c0: 8b000c40     	add	x0, x2, x0, lsl #3
    13c4: f8615842     	ldr	x2, [x2, w1, uxtw #3]
    13c8: aa0103f7     	mov	x23, x1
    13cc: d360fc41     	lsr	x1, x2, #32
    13d0: 92403c21     	and	x1, x1, #0xffff
    13d4: 91000421     	add	x1, x1, #0x1
    13d8: d37df021     	lsl	x1, x1, #3
    13dc: b8616801     	ldr	w1, [x0, x1]
    13e0: 350000a1     	cbnz	w1, 0x13f4 <___pl_fn_4+0xb8>
    13e4: 1400003e     	b	0x14dc <___pl_fn_4+0x1a0>
    13e8: aa1303e0     	mov	x0, x19
    13ec: f9401801     	ldr	x1, [x0, #0x30]
    13f0: 14000002     	b	0x13f8 <___pl_fn_4+0xbc>
    13f4: aa1303e0     	mov	x0, x19
    13f8: aa1303e0     	mov	x0, x19
    13fc: b9401817     	ldr	w23, [x0, #0x18]
    1400: b9401c02     	ldr	w2, [x0, #0x1c]
    1404: 110006e0     	add	w0, w23, #0x1
    1408: 6b02001f     	cmp	w0, w2
    140c: 54000a68     	b.hi	0x1558 <___pl_fn_4+0x21c>
    1410: aa1303e5     	mov	x5, x19
    1414: f94010a2     	ldr	x2, [x5, #0x20]
    1418: b8375841     	str	w1, [x2, w23, uxtw #2]
    141c: aa1303e8     	mov	x8, x19
    1420: b9001900     	str	w0, [x8, #0x18]
    1424: aa1303e0     	mov	x0, x19
    1428: b9401000     	ldr	w0, [x0, #0x10]
    142c: aa1303ec     	mov	x12, x19
    1430: b9401582     	ldr	w2, [x12, #0x14]
    1434: 6b02001f     	cmp	w0, w2
    1438: 540007e2     	b.hs	0x1534 <___pl_fn_4+0x1f8>
    143c: aa1303e0     	mov	x0, x19
    1440: 94000000     	bl	0x1440 <___pl_fn_4+0x104>
    1444: aa1303e1     	mov	x1, x19
    1448: b9402c21     	ldr	w1, [x1, #0x2c]
    144c: 350006c1     	cbnz	w1, 0x1524 <___pl_fn_4+0x1e8>
    1450: aa1303e1     	mov	x1, x19
    1454: b9001837     	str	w23, [x1, #0x18]
    1458: d2800021     	mov	x1, #0x1                ; =1
    145c: ab000020     	adds	x0, x1, x0
    1460: 9a9f77e1     	cset	x1, vs
    1464: 72001c3f     	tst	w1, #0xff
    1468: 540004c1     	b.ne	0x1500 <___pl_fn_4+0x1c4>
    146c: aa1303e1     	mov	x1, x19
    1470: b9401021     	ldr	w1, [x1, #0x10]
    1474: 51000421     	sub	w1, w1, #0x1
    1478: aa1303e2     	mov	x2, x19
    147c: b9001041     	str	w1, [x2, #0x10]
    1480: a8c15ff3     	ldp	x19, x23, [sp], #0x10
    1484: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1488: d65f03c0     	ret
    148c: aa1303e0     	mov	x0, x19
    1490: b9401000     	ldr	w0, [x0, #0x10]
    1494: 51000400     	sub	w0, w0, #0x1
    1498: aa1303e1     	mov	x1, x19
    149c: b9001020     	str	w0, [x1, #0x10]
    14a0: d2800000     	mov	x0, #0x0                ; =0
    14a4: a8c15ff3     	ldp	x19, x23, [sp], #0x10
    14a8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    14ac: d65f03c0     	ret
    14b0: aa0003f3     	mov	x19, x0
    14b4: 52800561     	mov	w1, #0x2b               ; =43
    14b8: 52800043     	mov	w3, #0x2                ; =2
    14bc: 90000008     	adrp	x8, 0x1000 <___pl_fn_3+0x148>
    14c0: f9400108     	ldr	x8, [x8]
    14c4: aa1303e0     	mov	x0, x19
    14c8: aa1703e2     	mov	x2, x23
    14cc: d63f0100     	blr	x8
    14d0: 34fff660     	cbz	w0, 0x139c <___pl_fn_4+0x60>
    14d4: 14000014     	b	0x1524 <___pl_fn_4+0x1e8>
    14d8: aa0103f7     	mov	x23, x1
    14dc: 52800581     	mov	w1, #0x2c               ; =44
    14e0: 52800023     	mov	w3, #0x1                ; =1
    14e4: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x148>
    14e8: f9400084     	ldr	x4, [x4]
    14ec: aa1703e2     	mov	x2, x23
    14f0: aa1303e0     	mov	x0, x19
    14f4: d63f0080     	blr	x4
    14f8: 34fff780     	cbz	w0, 0x13e8 <___pl_fn_4+0xac>
    14fc: 1400000a     	b	0x1524 <___pl_fn_4+0x1e8>
    1500: 528005e1     	mov	w1, #0x2f               ; =47
    1504: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    1508: f9400042     	ldr	x2, [x2]
    150c: aa1303e0     	mov	x0, x19
    1510: d63f0040     	blr	x2
    1514: d2800000     	mov	x0, #0x0                ; =0
    1518: a8c15ff3     	ldp	x19, x23, [sp], #0x10
    151c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1520: d65f03c0     	ret
    1524: d2800000     	mov	x0, #0x0                ; =0
    1528: a8c15ff3     	ldp	x19, x23, [sp], #0x10
    152c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1530: d65f03c0     	ret
    1534: 528005c1     	mov	w1, #0x2e               ; =46
    1538: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    153c: f9400042     	ldr	x2, [x2]
    1540: aa1303e0     	mov	x0, x19
    1544: d63f0040     	blr	x2
    1548: d2800000     	mov	x0, #0x0                ; =0
    154c: a8c15ff3     	ldp	x19, x23, [sp], #0x10
    1550: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1554: d65f03c0     	ret
    1558: 528005a1     	mov	w1, #0x2d               ; =45
    155c: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x148>
    1560: f9400042     	ldr	x2, [x2]
    1564: aa1303e0     	mov	x0, x19
    1568: d63f0040     	blr	x2
    156c: d2800000     	mov	x0, #0x0                ; =0
    1570: a8c15ff3     	ldp	x19, x23, [sp], #0x10
    1574: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1578: d65f03c0     	ret
