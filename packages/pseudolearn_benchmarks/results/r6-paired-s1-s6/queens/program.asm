
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_28184/queens/program.o:	file format mach-o arm64

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
      20: b9401006     	ldr	w6, [x0, #0x10]
      24: 110004c7     	add	w7, w6, #0x1
      28: b9001007     	str	w7, [x0, #0x10]
      2c: aa0003f9     	mov	x25, x0
      30: eb02003f     	cmp	x1, x2
      34: aa0103ee     	mov	x14, x1
      38: 54001c80     	b.eq	0x3c8 <___pl_fn_0+0x3c8>
      3c: b24107e0     	mov	x0, #-0x7fffffffffffffff ; =-9223372036854775807
      40: eb00005f     	cmp	x2, x0
      44: 5400302b     	b.lt	0x648 <___pl_fn_0+0x648>
      48: d2800013     	mov	x19, #0x0               ; =0
      4c: aa1303e0     	mov	x0, x19
      50: aa0203f7     	mov	x23, x2
      54: d10006e1     	sub	x1, x23, #0x1
      58: eb01027f     	cmp	x19, x1
      5c: 9a9fc7e1     	cset	x1, le
      60: 72001c3f     	tst	w1, #0xff
      64: 540001a1     	b.ne	0x98 <___pl_fn_0+0x98>
      68: aa1903ec     	mov	x12, x25
      6c: b9401185     	ldr	w5, [x12, #0x10]
      70: 510004a5     	sub	w5, w5, #0x1
      74: b9001185     	str	w5, [x12, #0x10]
      78: 910203ff     	add	sp, sp, #0x80
      7c: a8c153f3     	ldp	x19, x20, [sp], #0x10
      80: a8c15bf5     	ldp	x21, x22, [sp], #0x10
      84: a8c163f7     	ldp	x23, x24, [sp], #0x10
      88: a8c16bf9     	ldp	x25, x26, [sp], #0x10
      8c: a8c173fb     	ldp	x27, x28, [sp], #0x10
      90: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      94: d65f03c0     	ret
      98: aa1903ec     	mov	x12, x25
      9c: f80783e0     	stur	x0, [sp, #0x78]
      a0: 34001aa3     	cbz	w3, 0x3f4 <___pl_fn_0+0x3f4>
      a4: f9400189     	ldr	x9, [x12]
      a8: aa0c03f9     	mov	x25, x12
      ac: 2a0303f5     	mov	w21, w3
      b0: aa0303fc     	mov	x28, x3
      b4: 8b150d2a     	add	x10, x9, x21, lsl #3
      b8: f940094b     	ldr	x11, [x10, #0x10]
      bc: eb0b027f     	cmp	x19, x11
      c0: 540019e2     	b.hs	0x3fc <___pl_fn_0+0x3fc>
      c4: 8b130d4c     	add	x12, x10, x19, lsl #3
      c8: 3940a18c     	ldrb	w12, [x12, #0x28]
      cc: 53001d8d     	uxtb	w13, w12
      d0: 710009bf     	cmp	w13, #0x2
      d4: 54001940     	b.eq	0x3fc <___pl_fn_0+0x3fc>
      d8: 72001d9f     	tst	w12, #0xff
      dc: 540000a1     	b.ne	0xf0 <___pl_fn_0+0xf0>
      e0: 52800001     	mov	w1, #0x0                ; =0
      e4: aa0e03f4     	mov	x20, x14
      e8: aa0403fb     	mov	x27, x4
      ec: 14000012     	b	0x134 <___pl_fn_0+0x134>
      f0: aa0e03f4     	mov	x20, x14
      f4: ab140260     	adds	x0, x19, x20
      f8: 9a9f77e1     	cset	x1, vs
      fc: 72001c3f     	tst	w1, #0xff
     100: 54002a01     	b.ne	0x640 <___pl_fn_0+0x640>
     104: 34001924     	cbz	w4, 0x428 <___pl_fn_0+0x428>
     108: 2a0403e1     	mov	w1, w4
     10c: aa0403fb     	mov	x27, x4
     110: 8b010d21     	add	x1, x9, x1, lsl #3
     114: f9400822     	ldr	x2, [x1, #0x10]
     118: eb02001f     	cmp	x0, x2
     11c: 54001882     	b.hs	0x42c <___pl_fn_0+0x42c>
     120: 8b000c21     	add	x1, x1, x0, lsl #3
     124: 3940a021     	ldrb	w1, [x1, #0x28]
     128: 53001c22     	uxtb	w2, w1
     12c: 7100085f     	cmp	w2, #0x2
     130: 540017e0     	b.eq	0x42c <___pl_fn_0+0x42c>
     134: 72001c3f     	tst	w1, #0xff
     138: 54000081     	b.ne	0x148 <___pl_fn_0+0x148>
     13c: 52800001     	mov	w1, #0x0                ; =0
     140: aa0503e2     	mov	x2, x5
     144: 1400001c     	b	0x1b4 <___pl_fn_0+0x1b4>
     148: eb140260     	subs	x0, x19, x20
     14c: 9a9f77e1     	cset	x1, vs
     150: 72001c3f     	tst	w1, #0xff
     154: 54002721     	b.ne	0x638 <___pl_fn_0+0x638>
     158: ab170000     	adds	x0, x0, x23
     15c: 9a9f77e1     	cset	x1, vs
     160: 72001c3f     	tst	w1, #0xff
     164: 54002661     	b.ne	0x630 <___pl_fn_0+0x630>
     168: b24107e1     	mov	x1, #-0x7fffffffffffffff ; =-9223372036854775807
     16c: eb01001f     	cmp	x0, x1
     170: 540025cb     	b.lt	0x628 <___pl_fn_0+0x628>
     174: 34001725     	cbz	w5, 0x458 <___pl_fn_0+0x458>
     178: aa1903e1     	mov	x1, x25
     17c: f9400021     	ldr	x1, [x1]
     180: 2a0503e2     	mov	w2, w5
     184: aa0503fa     	mov	x26, x5
     188: 8b020c21     	add	x1, x1, x2, lsl #3
     18c: f9400823     	ldr	x3, [x1, #0x10]
     190: d1000402     	sub	x2, x0, #0x1
     194: eb03005f     	cmp	x2, x3
     198: 54001622     	b.hs	0x45c <___pl_fn_0+0x45c>
     19c: 8b020c21     	add	x1, x1, x2, lsl #3
     1a0: 3940a021     	ldrb	w1, [x1, #0x28]
     1a4: 53001c22     	uxtb	w2, w1
     1a8: 7100085f     	cmp	w2, #0x2
     1ac: 54001580     	b.eq	0x45c <___pl_fn_0+0x45c>
     1b0: aa1a03e2     	mov	x2, x26
     1b4: 72001c3f     	tst	w1, #0xff
     1b8: 54000081     	b.ne	0x1c8 <___pl_fn_0+0x1c8>
     1bc: f84783e4     	ldur	x4, [sp, #0x78]
     1c0: aa0203fa     	mov	x26, x2
     1c4: 14000076     	b	0x39c <___pl_fn_0+0x39c>
     1c8: aa1c03e0     	mov	x0, x28
     1cc: 34001600     	cbz	w0, 0x48c <___pl_fn_0+0x48c>
     1d0: aa1903e0     	mov	x0, x25
     1d4: f9400007     	ldr	x7, [x0]
     1d8: 8b150ce8     	add	x8, x7, x21, lsl #3
     1dc: f9400909     	ldr	x9, [x8, #0x10]
     1e0: eb09027f     	cmp	x19, x9
     1e4: 54001542     	b.hs	0x48c <___pl_fn_0+0x48c>
     1e8: d2800000     	mov	x0, #0x0                ; =0
     1ec: 8b130d01     	add	x1, x8, x19, lsl #3
     1f0: f9001420     	str	x0, [x1, #0x28]
     1f4: ab140260     	adds	x0, x19, x20
     1f8: 9a9f77e1     	cset	x1, vs
     1fc: 72001c3f     	tst	w1, #0xff
     200: 54002101     	b.ne	0x620 <___pl_fn_0+0x620>
     204: aa1b03e1     	mov	x1, x27
     208: 340015c1     	cbz	w1, 0x4c0 <___pl_fn_0+0x4c0>
     20c: aa1b03e1     	mov	x1, x27
     210: 2a0103f6     	mov	w22, w1
     214: 8b160ce1     	add	x1, x7, x22, lsl #3
     218: f9400823     	ldr	x3, [x1, #0x10]
     21c: eb03001f     	cmp	x0, x3
     220: 54001502     	b.hs	0x4c0 <___pl_fn_0+0x4c0>
     224: d2800003     	mov	x3, #0x0                ; =0
     228: 8b000c20     	add	x0, x1, x0, lsl #3
     22c: f9001403     	str	x3, [x0, #0x28]
     230: eb140260     	subs	x0, x19, x20
     234: 9a9f77e1     	cset	x1, vs
     238: 72001c3f     	tst	w1, #0xff
     23c: 54001ee1     	b.ne	0x618 <___pl_fn_0+0x618>
     240: ab170000     	adds	x0, x0, x23
     244: 9a9f77e1     	cset	x1, vs
     248: 72001c3f     	tst	w1, #0xff
     24c: 54001e21     	b.ne	0x610 <___pl_fn_0+0x610>
     250: b24107e1     	mov	x1, #-0x7fffffffffffffff ; =-9223372036854775807
     254: eb01001f     	cmp	x0, x1
     258: 54001d8b     	b.lt	0x608 <___pl_fn_0+0x608>
     25c: 340014c2     	cbz	w2, 0x4f4 <___pl_fn_0+0x4f4>
     260: 2a0203f8     	mov	w24, w2
     264: 8b180ce1     	add	x1, x7, x24, lsl #3
     268: f9400824     	ldr	x4, [x1, #0x10]
     26c: d1000403     	sub	x3, x0, #0x1
     270: eb04007f     	cmp	x3, x4
     274: 54001402     	b.hs	0x4f4 <___pl_fn_0+0x4f4>
     278: aa0203fa     	mov	x26, x2
     27c: d2800000     	mov	x0, #0x0                ; =0
     280: 8b030c21     	add	x1, x1, x3, lsl #3
     284: f9001420     	str	x0, [x1, #0x28]
     288: b27ff7e0     	mov	x0, #0x7ffffffffffffffe ; =9223372036854775806
     28c: eb00029f     	cmp	x20, x0
     290: 54001b8c     	b.gt	0x600 <___pl_fn_0+0x600>
     294: aa1903e0     	mov	x0, x25
     298: b9401000     	ldr	w0, [x0, #0x10]
     29c: aa1903e1     	mov	x1, x25
     2a0: b9401421     	ldr	w1, [x1, #0x14]
     2a4: 6b01001f     	cmp	w0, w1
     2a8: 54001a82     	b.hs	0x5f8 <___pl_fn_0+0x5f8>
     2ac: 91000681     	add	x1, x20, #0x1
     2b0: aa1903e0     	mov	x0, x25
     2b4: aa1703e2     	mov	x2, x23
     2b8: aa1c03e3     	mov	x3, x28
     2bc: aa1b03e4     	mov	x4, x27
     2c0: aa1a03e5     	mov	x5, x26
     2c4: 94000000     	bl	0x2c4 <___pl_fn_0+0x2c4>
     2c8: aa1903e1     	mov	x1, x25
     2cc: b9402c21     	ldr	w1, [x1, #0x2c]
     2d0: 35001c61     	cbnz	w1, 0x65c <___pl_fn_0+0x65c>
     2d4: f84783e4     	ldur	x4, [sp, #0x78]
     2d8: ab000084     	adds	x4, x4, x0
     2dc: 9a9f77e0     	cset	x0, vs
     2e0: 72001c1f     	tst	w0, #0xff
     2e4: 54001861     	b.ne	0x5f0 <___pl_fn_0+0x5f0>
     2e8: aa1c03e2     	mov	x2, x28
     2ec: 340011e2     	cbz	w2, 0x528 <___pl_fn_0+0x528>
     2f0: aa1903e0     	mov	x0, x25
     2f4: f9400001     	ldr	x1, [x0]
     2f8: 8b150c22     	add	x2, x1, x21, lsl #3
     2fc: f9400840     	ldr	x0, [x2, #0x10]
     300: eb00027f     	cmp	x19, x0
     304: 54001122     	b.hs	0x528 <___pl_fn_0+0x528>
     308: d2800028     	mov	x8, #0x1                ; =1
     30c: 8b130c49     	add	x9, x2, x19, lsl #3
     310: f9001528     	str	x8, [x9, #0x28]
     314: ab140269     	adds	x9, x19, x20
     318: 9a9f77eb     	cset	x11, vs
     31c: 72001d7f     	tst	w11, #0xff
     320: 54001641     	b.ne	0x5e8 <___pl_fn_0+0x5e8>
     324: aa1b03e2     	mov	x2, x27
     328: 340011a2     	cbz	w2, 0x55c <___pl_fn_0+0x55c>
     32c: 8b160c2e     	add	x14, x1, x22, lsl #3
     330: f94009cf     	ldr	x15, [x14, #0x10]
     334: eb0f013f     	cmp	x9, x15
     338: 54001122     	b.hs	0x55c <___pl_fn_0+0x55c>
     33c: d2800020     	mov	x0, #0x1                ; =1
     340: 8b090dc2     	add	x2, x14, x9, lsl #3
     344: f9001440     	str	x0, [x2, #0x28]
     348: eb140262     	subs	x2, x19, x20
     34c: 9a9f77e0     	cset	x0, vs
     350: 72001c1f     	tst	w0, #0xff
     354: 54001461     	b.ne	0x5e0 <___pl_fn_0+0x5e0>
     358: ab170042     	adds	x2, x2, x23
     35c: 9a9f77e0     	cset	x0, vs
     360: 72001c1f     	tst	w0, #0xff
     364: 540013a1     	b.ne	0x5d8 <___pl_fn_0+0x5d8>
     368: b24107e0     	mov	x0, #-0x7fffffffffffffff ; =-9223372036854775807
     36c: eb00005f     	cmp	x2, x0
     370: 5400130b     	b.lt	0x5d0 <___pl_fn_0+0x5d0>
     374: aa1a03e3     	mov	x3, x26
     378: 340010c3     	cbz	w3, 0x590 <___pl_fn_0+0x590>
     37c: 8b180c21     	add	x1, x1, x24, lsl #3
     380: f9400820     	ldr	x0, [x1, #0x10]
     384: d1000443     	sub	x3, x2, #0x1
     388: eb00007f     	cmp	x3, x0
     38c: 54001022     	b.hs	0x590 <___pl_fn_0+0x590>
     390: d2800020     	mov	x0, #0x1                ; =1
     394: 8b030c21     	add	x1, x1, x3, lsl #3
     398: f9001420     	str	x0, [x1, #0x28]
     39c: b27ff7e0     	mov	x0, #0x7ffffffffffffffe ; =9223372036854775806
     3a0: eb00027f     	cmp	x19, x0
     3a4: 5400112c     	b.gt	0x5c8 <___pl_fn_0+0x5c8>
     3a8: 91000673     	add	x19, x19, #0x1
     3ac: aa1403ee     	mov	x14, x20
     3b0: aa1a03e5     	mov	x5, x26
     3b4: aa1c03e3     	mov	x3, x28
     3b8: aa1703e2     	mov	x2, x23
     3bc: aa0403e0     	mov	x0, x4
     3c0: aa1b03e4     	mov	x4, x27
     3c4: 17ffff23     	b	0x50 <___pl_fn_0+0x50>
     3c8: aa1903e0     	mov	x0, x25
     3cc: b9001006     	str	w6, [x0, #0x10]
     3d0: d2800020     	mov	x0, #0x1                ; =1
     3d4: 910203ff     	add	sp, sp, #0x80
     3d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     3dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     3e0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     3e4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     3e8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     3ec: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     3f0: d65f03c0     	ret
     3f4: aa0c03f9     	mov	x25, x12
     3f8: aa0303fc     	mov	x28, x3
     3fc: 910003e3     	mov	x3, sp
     400: f80003f3     	stur	x19, [sp]
     404: 52800041     	mov	w1, #0x2                ; =2
     408: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     40c: f9400084     	ldr	x4, [x4]
     410: aa1c03e2     	mov	x2, x28
     414: aa1903e0     	mov	x0, x25
     418: d63f0080     	blr	x4
     41c: 35001200     	cbnz	w0, 0x65c <___pl_fn_0+0x65c>
     420: 52800061     	mov	w1, #0x3                ; =3
     424: 1400008a     	b	0x64c <___pl_fn_0+0x64c>
     428: aa0403fb     	mov	x27, x4
     42c: 910023e3     	add	x3, sp, #0x8
     430: f80083e0     	stur	x0, [sp, #0x8]
     434: 528000a1     	mov	w1, #0x5                ; =5
     438: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     43c: f9400084     	ldr	x4, [x4]
     440: aa1b03e2     	mov	x2, x27
     444: aa1903e0     	mov	x0, x25
     448: d63f0080     	blr	x4
     44c: 35001080     	cbnz	w0, 0x65c <___pl_fn_0+0x65c>
     450: 528000c1     	mov	w1, #0x6                ; =6
     454: 1400007e     	b	0x64c <___pl_fn_0+0x64c>
     458: aa0503fa     	mov	x26, x5
     45c: d1000400     	sub	x0, x0, #0x1
     460: 910043e3     	add	x3, sp, #0x10
     464: f80103e0     	stur	x0, [sp, #0x10]
     468: 52800141     	mov	w1, #0xa                ; =10
     46c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     470: f9400084     	ldr	x4, [x4]
     474: aa1a03e2     	mov	x2, x26
     478: aa1903e0     	mov	x0, x25
     47c: d63f0080     	blr	x4
     480: 35000ee0     	cbnz	w0, 0x65c <___pl_fn_0+0x65c>
     484: 52800161     	mov	w1, #0xb                ; =11
     488: 14000071     	b	0x64c <___pl_fn_0+0x64c>
     48c: 910063e3     	add	x3, sp, #0x18
     490: f80183f3     	stur	x19, [sp, #0x18]
     494: d280000b     	mov	x11, #0x0               ; =0
     498: f80203eb     	stur	x11, [sp, #0x20]
     49c: 52800181     	mov	w1, #0xc                ; =12
     4a0: 9000000c     	adrp	x12, 0x0 <___pl_fn_0>
     4a4: f940018c     	ldr	x12, [x12]
     4a8: aa1c03e2     	mov	x2, x28
     4ac: aa1903e0     	mov	x0, x25
     4b0: d63f0180     	blr	x12
     4b4: 35000d40     	cbnz	w0, 0x65c <___pl_fn_0+0x65c>
     4b8: 528001a1     	mov	w1, #0xd                ; =13
     4bc: 14000064     	b	0x64c <___pl_fn_0+0x64c>
     4c0: 9100a3e3     	add	x3, sp, #0x28
     4c4: f80283e0     	stur	x0, [sp, #0x28]
     4c8: d2800000     	mov	x0, #0x0                ; =0
     4cc: f80303e0     	stur	x0, [sp, #0x30]
     4d0: 528001e1     	mov	w1, #0xf                ; =15
     4d4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     4d8: f9400084     	ldr	x4, [x4]
     4dc: aa1b03e2     	mov	x2, x27
     4e0: aa1903e0     	mov	x0, x25
     4e4: d63f0080     	blr	x4
     4e8: 35000ba0     	cbnz	w0, 0x65c <___pl_fn_0+0x65c>
     4ec: 52800201     	mov	w1, #0x10               ; =16
     4f0: 14000057     	b	0x64c <___pl_fn_0+0x64c>
     4f4: d1000400     	sub	x0, x0, #0x1
     4f8: 9100e3e3     	add	x3, sp, #0x38
     4fc: f80383e0     	stur	x0, [sp, #0x38]
     500: d2800000     	mov	x0, #0x0                ; =0
     504: f80403e0     	stur	x0, [sp, #0x40]
     508: 52800281     	mov	w1, #0x14               ; =20
     50c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     510: f9400084     	ldr	x4, [x4]
     514: aa1903e0     	mov	x0, x25
     518: d63f0080     	blr	x4
     51c: 35000a00     	cbnz	w0, 0x65c <___pl_fn_0+0x65c>
     520: 528002a1     	mov	w1, #0x15               ; =21
     524: 1400004a     	b	0x64c <___pl_fn_0+0x64c>
     528: 910123e3     	add	x3, sp, #0x48
     52c: f80483f3     	stur	x19, [sp, #0x48]
     530: d2800024     	mov	x4, #0x1                ; =1
     534: f80503e4     	stur	x4, [sp, #0x50]
     538: 52800321     	mov	w1, #0x19               ; =25
     53c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     540: f9400084     	ldr	x4, [x4]
     544: aa1c03e2     	mov	x2, x28
     548: aa1903e0     	mov	x0, x25
     54c: d63f0080     	blr	x4
     550: 35000860     	cbnz	w0, 0x65c <___pl_fn_0+0x65c>
     554: 52800341     	mov	w1, #0x1a               ; =26
     558: 1400003d     	b	0x64c <___pl_fn_0+0x64c>
     55c: 910163e3     	add	x3, sp, #0x58
     560: f80583e9     	stur	x9, [sp, #0x58]
     564: d2800020     	mov	x0, #0x1                ; =1
     568: f80603e0     	stur	x0, [sp, #0x60]
     56c: 52800381     	mov	w1, #0x1c               ; =28
     570: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     574: f9400084     	ldr	x4, [x4]
     578: aa1b03e2     	mov	x2, x27
     57c: aa1903e0     	mov	x0, x25
     580: d63f0080     	blr	x4
     584: 350006c0     	cbnz	w0, 0x65c <___pl_fn_0+0x65c>
     588: 528003a1     	mov	w1, #0x1d               ; =29
     58c: 14000030     	b	0x64c <___pl_fn_0+0x64c>
     590: d2800020     	mov	x0, #0x1                ; =1
     594: d1000441     	sub	x1, x2, #0x1
     598: 9101a3e3     	add	x3, sp, #0x68
     59c: f80683e1     	stur	x1, [sp, #0x68]
     5a0: f80703e0     	stur	x0, [sp, #0x70]
     5a4: 52800421     	mov	w1, #0x21               ; =33
     5a8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5ac: f9400084     	ldr	x4, [x4]
     5b0: aa1a03e2     	mov	x2, x26
     5b4: aa1903e0     	mov	x0, x25
     5b8: d63f0080     	blr	x4
     5bc: 35000500     	cbnz	w0, 0x65c <___pl_fn_0+0x65c>
     5c0: 52800441     	mov	w1, #0x22               ; =34
     5c4: 14000022     	b	0x64c <___pl_fn_0+0x64c>
     5c8: 52800461     	mov	w1, #0x23               ; =35
     5cc: 14000020     	b	0x64c <___pl_fn_0+0x64c>
     5d0: 52800401     	mov	w1, #0x20               ; =32
     5d4: 1400001e     	b	0x64c <___pl_fn_0+0x64c>
     5d8: 528003e1     	mov	w1, #0x1f               ; =31
     5dc: 1400001c     	b	0x64c <___pl_fn_0+0x64c>
     5e0: 528003c1     	mov	w1, #0x1e               ; =30
     5e4: 1400001a     	b	0x64c <___pl_fn_0+0x64c>
     5e8: 52800361     	mov	w1, #0x1b               ; =27
     5ec: 14000018     	b	0x64c <___pl_fn_0+0x64c>
     5f0: 52800301     	mov	w1, #0x18               ; =24
     5f4: 14000016     	b	0x64c <___pl_fn_0+0x64c>
     5f8: 528002e1     	mov	w1, #0x17               ; =23
     5fc: 14000014     	b	0x64c <___pl_fn_0+0x64c>
     600: 528002c1     	mov	w1, #0x16               ; =22
     604: 14000012     	b	0x64c <___pl_fn_0+0x64c>
     608: 52800261     	mov	w1, #0x13               ; =19
     60c: 14000010     	b	0x64c <___pl_fn_0+0x64c>
     610: 52800241     	mov	w1, #0x12               ; =18
     614: 1400000e     	b	0x64c <___pl_fn_0+0x64c>
     618: 52800221     	mov	w1, #0x11               ; =17
     61c: 1400000c     	b	0x64c <___pl_fn_0+0x64c>
     620: 528001c1     	mov	w1, #0xe                ; =14
     624: 1400000a     	b	0x64c <___pl_fn_0+0x64c>
     628: 52800121     	mov	w1, #0x9                ; =9
     62c: 14000008     	b	0x64c <___pl_fn_0+0x64c>
     630: 52800101     	mov	w1, #0x8                ; =8
     634: 14000006     	b	0x64c <___pl_fn_0+0x64c>
     638: 528000e1     	mov	w1, #0x7                ; =7
     63c: 14000004     	b	0x64c <___pl_fn_0+0x64c>
     640: 52800081     	mov	w1, #0x4                ; =4
     644: 14000002     	b	0x64c <___pl_fn_0+0x64c>
     648: 52800001     	mov	w1, #0x0                ; =0
     64c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     650: f9400042     	ldr	x2, [x2]
     654: aa1903e0     	mov	x0, x25
     658: d63f0040     	blr	x2
     65c: d2800000     	mov	x0, #0x0                ; =0
     660: 910203ff     	add	sp, sp, #0x80
     664: a8c153f3     	ldp	x19, x20, [sp], #0x10
     668: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     66c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     670: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     674: a8c173fb     	ldp	x27, x28, [sp], #0x10
     678: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     67c: d65f03c0     	ret

0000000000000680 <___pl_fn_1>:
     680: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     684: 910003fd     	mov	x29, sp
     688: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     68c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     690: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     694: d10143ff     	sub	sp, sp, #0x50
     698: b9401001     	ldr	w1, [x0, #0x10]
     69c: 11000421     	add	w1, w1, #0x1
     6a0: b9001001     	str	w1, [x0, #0x10]
     6a4: aa0003f5     	mov	x21, x0
     6a8: d2800200     	mov	x0, #0x10               ; =16
     6ac: 910003e3     	mov	x3, sp
     6b0: f80003e0     	stur	x0, [sp]
     6b4: 52800481     	mov	w1, #0x24               ; =36
     6b8: 52802042     	mov	w2, #0x102              ; =258
     6bc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     6c0: f9400084     	ldr	x4, [x4]
     6c4: aa1503e0     	mov	x0, x21
     6c8: d63f0080     	blr	x4
     6cc: 35001d20     	cbnz	w0, 0xa70 <___pl_fn_1+0x3f0>
     6d0: aa1503e0     	mov	x0, x21
     6d4: f9401803     	ldr	x3, [x0, #0x30]
     6d8: b9401813     	ldr	w19, [x0, #0x18]
     6dc: b9401c01     	ldr	w1, [x0, #0x1c]
     6e0: 11000660     	add	w0, w19, #0x1
     6e4: 6b01001f     	cmp	w0, w1
     6e8: 54001ba8     	b.hi	0xa5c <___pl_fn_1+0x3dc>
     6ec: aa1503e9     	mov	x9, x21
     6f0: f9401121     	ldr	x1, [x9, #0x20]
     6f4: 2a1303f4     	mov	w20, w19
     6f8: b8335823     	str	w3, [x1, w19, uxtw #2]
     6fc: aa1503ed     	mov	x13, x21
     700: aa0303f6     	mov	x22, x3
     704: b90019a0     	str	w0, [x13, #0x18]
     708: d2800200     	mov	x0, #0x10               ; =16
     70c: 910023e3     	add	x3, sp, #0x8
     710: f80083e0     	stur	x0, [sp, #0x8]
     714: 528004c1     	mov	w1, #0x26               ; =38
     718: 52802042     	mov	w2, #0x102              ; =258
     71c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     720: f9400084     	ldr	x4, [x4]
     724: aa1503e0     	mov	x0, x21
     728: d63f0080     	blr	x4
     72c: 35001a20     	cbnz	w0, 0xa70 <___pl_fn_1+0x3f0>
     730: aa1503e0     	mov	x0, x21
     734: f9401804     	ldr	x4, [x0, #0x30]
     738: b9001813     	str	w19, [x0, #0x18]
     73c: b9401c00     	ldr	w0, [x0, #0x1c]
     740: 11000a61     	add	w1, w19, #0x2
     744: 6b00003f     	cmp	w1, w0
     748: 54001868     	b.hi	0xa54 <___pl_fn_1+0x3d4>
     74c: aa1503e0     	mov	x0, x21
     750: f9401000     	ldr	x0, [x0, #0x20]
     754: 8b140801     	add	x1, x0, x20, lsl #2
     758: aa1603e3     	mov	x3, x22
     75c: b8335803     	str	w3, [x0, w19, uxtw #2]
     760: b9000424     	str	w4, [x1, #0x4]
     764: aa0403f7     	mov	x23, x4
     768: 11000a60     	add	w0, w19, #0x2
     76c: aa1503e1     	mov	x1, x21
     770: b9001820     	str	w0, [x1, #0x18]
     774: d2800201     	mov	x1, #0x10               ; =16
     778: 910043e3     	add	x3, sp, #0x10
     77c: f80103e1     	stur	x1, [sp, #0x10]
     780: 52800501     	mov	w1, #0x28               ; =40
     784: 52802042     	mov	w2, #0x102              ; =258
     788: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     78c: f9400084     	ldr	x4, [x4]
     790: aa1503e0     	mov	x0, x21
     794: d63f0080     	blr	x4
     798: 350016c0     	cbnz	w0, 0xa70 <___pl_fn_1+0x3f0>
     79c: aa1503e0     	mov	x0, x21
     7a0: f9401805     	ldr	x5, [x0, #0x30]
     7a4: b9001813     	str	w19, [x0, #0x18]
     7a8: b9401c06     	ldr	w6, [x0, #0x1c]
     7ac: 11000e67     	add	w7, w19, #0x3
     7b0: 6b0600ff     	cmp	w7, w6
     7b4: 540014c8     	b.hi	0xa4c <___pl_fn_1+0x3cc>
     7b8: aa1503e0     	mov	x0, x21
     7bc: f9401008     	ldr	x8, [x0, #0x20]
     7c0: 8b140907     	add	x7, x8, x20, lsl #2
     7c4: aa1603e3     	mov	x3, x22
     7c8: b8335903     	str	w3, [x8, w19, uxtw #2]
     7cc: aa1703e4     	mov	x4, x23
     7d0: b90004e4     	str	w4, [x7, #0x4]
     7d4: b90008e5     	str	w5, [x7, #0x8]
     7d8: aa0503f8     	mov	x24, x5
     7dc: 11000e6a     	add	w10, w19, #0x3
     7e0: b900180a     	str	w10, [x0, #0x18]
     7e4: 52800541     	mov	w1, #0x2a               ; =42
     7e8: 52800002     	mov	w2, #0x0                ; =0
     7ec: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     7f0: f940016b     	ldr	x11, [x11]
     7f4: d63f0160     	blr	x11
     7f8: 350013c0     	cbnz	w0, 0xa70 <___pl_fn_1+0x3f0>
     7fc: aa1503e0     	mov	x0, x21
     800: f9401802     	ldr	x2, [x0, #0x30]
     804: aa0203e6     	mov	x6, x2
     808: b9001813     	str	w19, [x0, #0x18]
     80c: d280000e     	mov	x14, #0x0               ; =0
     810: f1003ddf     	cmp	x14, #0xf
     814: 9a9fc7e0     	cset	x0, le
     818: 72001c1f     	tst	w0, #0xff
     81c: 54000681     	b.ne	0x8ec <___pl_fn_1+0x26c>
     820: aa1503e0     	mov	x0, x21
     824: b9401c00     	ldr	w0, [x0, #0x1c]
     828: 11000e61     	add	w1, w19, #0x3
     82c: 6b00003f     	cmp	w1, w0
     830: 54000b68     	b.hi	0x99c <___pl_fn_1+0x31c>
     834: aa1503e0     	mov	x0, x21
     838: f9401001     	ldr	x1, [x0, #0x20]
     83c: 8b140820     	add	x0, x1, x20, lsl #2
     840: aa1603e3     	mov	x3, x22
     844: b8335823     	str	w3, [x1, w19, uxtw #2]
     848: aa1703e4     	mov	x4, x23
     84c: b9000404     	str	w4, [x0, #0x4]
     850: aa1803e5     	mov	x5, x24
     854: b9000805     	str	w5, [x0, #0x8]
     858: 11000e60     	add	w0, w19, #0x3
     85c: aa1503e1     	mov	x1, x21
     860: b9001820     	str	w0, [x1, #0x18]
     864: aa1503e0     	mov	x0, x21
     868: b9401000     	ldr	w0, [x0, #0x10]
     86c: b9401421     	ldr	w1, [x1, #0x14]
     870: 6b01001f     	cmp	w0, w1
     874: 54000902     	b.hs	0x994 <___pl_fn_1+0x314>
     878: d2800001     	mov	x1, #0x0                ; =0
     87c: aa0603e2     	mov	x2, x6
     880: aa1603e3     	mov	x3, x22
     884: aa1703e4     	mov	x4, x23
     888: aa1503e0     	mov	x0, x21
     88c: 94000000     	bl	0x88c <___pl_fn_1+0x20c>
     890: aa0003e2     	mov	x2, x0
     894: aa1503e0     	mov	x0, x21
     898: b9402c00     	ldr	w0, [x0, #0x2c]
     89c: 35000ea0     	cbnz	w0, 0xa70 <___pl_fn_1+0x3f0>
     8a0: aa1503e0     	mov	x0, x21
     8a4: b9001813     	str	w19, [x0, #0x18]
     8a8: 528005c1     	mov	w1, #0x2e               ; =46
     8ac: 52802003     	mov	w3, #0x100              ; =256
     8b0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     8b4: f9400084     	ldr	x4, [x4]
     8b8: d63f0080     	blr	x4
     8bc: 35000da0     	cbnz	w0, 0xa70 <___pl_fn_1+0x3f0>
     8c0: aa1503e0     	mov	x0, x21
     8c4: b9401000     	ldr	w0, [x0, #0x10]
     8c8: 51000400     	sub	w0, w0, #0x1
     8cc: aa1503e1     	mov	x1, x21
     8d0: b9001020     	str	w0, [x1, #0x10]
     8d4: 910143ff     	add	sp, sp, #0x50
     8d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8e0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8e8: d65f03c0     	ret
     8ec: aa1603e3     	mov	x3, x22
     8f0: aa1803e5     	mov	x5, x24
     8f4: 34000583     	cbz	w3, 0x9a4 <___pl_fn_1+0x324>
     8f8: aa1503e0     	mov	x0, x21
     8fc: f9400000     	ldr	x0, [x0]
     900: aa1603e3     	mov	x3, x22
     904: 2a0303e1     	mov	w1, w3
     908: 8b010c01     	add	x1, x0, x1, lsl #3
     90c: f9400822     	ldr	x2, [x1, #0x10]
     910: eb0201df     	cmp	x14, x2
     914: 54000482     	b.hs	0x9a4 <___pl_fn_1+0x324>
     918: d2800022     	mov	x2, #0x1                ; =1
     91c: 8b0e0c21     	add	x1, x1, x14, lsl #3
     920: f9001422     	str	x2, [x1, #0x28]
     924: aa1703e4     	mov	x4, x23
     928: 34000584     	cbz	w4, 0x9d8 <___pl_fn_1+0x358>
     92c: aa1703e4     	mov	x4, x23
     930: 2a0403e1     	mov	w1, w4
     934: 8b010c01     	add	x1, x0, x1, lsl #3
     938: f9400822     	ldr	x2, [x1, #0x10]
     93c: eb0201df     	cmp	x14, x2
     940: 540004c2     	b.hs	0x9d8 <___pl_fn_1+0x358>
     944: d2800022     	mov	x2, #0x1                ; =1
     948: 8b0e0c21     	add	x1, x1, x14, lsl #3
     94c: f9001422     	str	x2, [x1, #0x28]
     950: 340005e5     	cbz	w5, 0xa0c <___pl_fn_1+0x38c>
     954: 2a0503e3     	mov	w3, w5
     958: aa0503f8     	mov	x24, x5
     95c: 8b030c03     	add	x3, x0, x3, lsl #3
     960: f9400864     	ldr	x4, [x3, #0x10]
     964: eb0401df     	cmp	x14, x4
     968: 54000542     	b.hs	0xa10 <___pl_fn_1+0x390>
     96c: aa1803e2     	mov	x2, x24
     970: d280002c     	mov	x12, #0x1               ; =1
     974: 8b0e0c6d     	add	x13, x3, x14, lsl #3
     978: f90015ac     	str	x12, [x13, #0x28]
     97c: b27ff7ef     	mov	x15, #0x7ffffffffffffffe ; =9223372036854775806
     980: eb0f01df     	cmp	x14, x15
     984: 5400060c     	b.gt	0xa44 <___pl_fn_1+0x3c4>
     988: 910005ce     	add	x14, x14, #0x1
     98c: aa0203f8     	mov	x24, x2
     990: 17ffffa0     	b	0x810 <___pl_fn_1+0x190>
     994: 528005a1     	mov	w1, #0x2d               ; =45
     998: 14000032     	b	0xa60 <___pl_fn_1+0x3e0>
     99c: 52800581     	mov	w1, #0x2c               ; =44
     9a0: 14000030     	b	0xa60 <___pl_fn_1+0x3e0>
     9a4: 910063e3     	add	x3, sp, #0x18
     9a8: f80183ee     	stur	x14, [sp, #0x18]
     9ac: d2800020     	mov	x0, #0x1                ; =1
     9b0: f80203e0     	stur	x0, [sp, #0x20]
     9b4: 528005e1     	mov	w1, #0x2f               ; =47
     9b8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     9bc: f9400084     	ldr	x4, [x4]
     9c0: aa1603e2     	mov	x2, x22
     9c4: aa1503e0     	mov	x0, x21
     9c8: d63f0080     	blr	x4
     9cc: 35000520     	cbnz	w0, 0xa70 <___pl_fn_1+0x3f0>
     9d0: 52800601     	mov	w1, #0x30               ; =48
     9d4: 14000023     	b	0xa60 <___pl_fn_1+0x3e0>
     9d8: 9100a3e3     	add	x3, sp, #0x28
     9dc: f80283ee     	stur	x14, [sp, #0x28]
     9e0: d2800020     	mov	x0, #0x1                ; =1
     9e4: f80303e0     	stur	x0, [sp, #0x30]
     9e8: 52800621     	mov	w1, #0x31               ; =49
     9ec: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     9f0: f9400084     	ldr	x4, [x4]
     9f4: aa1703e2     	mov	x2, x23
     9f8: aa1503e0     	mov	x0, x21
     9fc: d63f0080     	blr	x4
     a00: 35000380     	cbnz	w0, 0xa70 <___pl_fn_1+0x3f0>
     a04: 52800641     	mov	w1, #0x32               ; =50
     a08: 14000016     	b	0xa60 <___pl_fn_1+0x3e0>
     a0c: aa0503f8     	mov	x24, x5
     a10: 9100e3e3     	add	x3, sp, #0x38
     a14: f80383ee     	stur	x14, [sp, #0x38]
     a18: d2800027     	mov	x7, #0x1                ; =1
     a1c: f80403e7     	stur	x7, [sp, #0x40]
     a20: 52800661     	mov	w1, #0x33               ; =51
     a24: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     a28: f9400108     	ldr	x8, [x8]
     a2c: aa1803e2     	mov	x2, x24
     a30: aa1503e0     	mov	x0, x21
     a34: d63f0100     	blr	x8
     a38: 350001c0     	cbnz	w0, 0xa70 <___pl_fn_1+0x3f0>
     a3c: 52800681     	mov	w1, #0x34               ; =52
     a40: 14000008     	b	0xa60 <___pl_fn_1+0x3e0>
     a44: 528006a1     	mov	w1, #0x35               ; =53
     a48: 14000006     	b	0xa60 <___pl_fn_1+0x3e0>
     a4c: 52800521     	mov	w1, #0x29               ; =41
     a50: 14000004     	b	0xa60 <___pl_fn_1+0x3e0>
     a54: 528004e1     	mov	w1, #0x27               ; =39
     a58: 14000002     	b	0xa60 <___pl_fn_1+0x3e0>
     a5c: 528004a1     	mov	w1, #0x25               ; =37
     a60: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a64: f9400042     	ldr	x2, [x2]
     a68: aa1503e0     	mov	x0, x21
     a6c: d63f0040     	blr	x2
     a70: 910143ff     	add	sp, sp, #0x50
     a74: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a78: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a7c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a80: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a84: d65f03c0     	ret
