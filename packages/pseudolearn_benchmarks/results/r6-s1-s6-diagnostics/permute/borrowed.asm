
packages/pseudolearn_benchmarks/results/r6-s1-s6-diagnostics/permute/borrowed.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: f81f0ffc     	str	x28, [sp, #-0x10]!
       c: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
      10: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      14: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      18: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      1c: d10183ff     	sub	sp, sp, #0x60
      20: aa0103fc     	mov	x28, x1
      24: b940100c     	ldr	w12, [x0, #0x10]
      28: 1100058d     	add	w13, w12, #0x1
      2c: b900100d     	str	w13, [x0, #0x10]
      30: b50000a2     	cbnz	x2, 0x44 <___pl_fn_0+0x44>
      34: d280002c     	mov	x12, #0x1               ; =1
      38: aa0003f9     	mov	x25, x0
      3c: aa0c03fa     	mov	x26, x12
      40: 14000020     	b	0xc0 <___pl_fn_0+0xc0>
      44: b24107f3     	mov	x19, #-0x7fffffffffffffff ; =-9223372036854775807
      48: eb13005f     	cmp	x2, x19
      4c: aa0203f4     	mov	x20, x2
      50: 54002feb     	b.lt	0x64c <___pl_fn_0+0x64c>
      54: b9401401     	ldr	w1, [x0, #0x14]
      58: aa0003f9     	mov	x25, x0
      5c: 11000580     	add	w0, w12, #0x1
      60: 6b01001f     	cmp	w0, w1
      64: 54002f02     	b.hs	0x644 <___pl_fn_0+0x644>
      68: d2800036     	mov	x22, #0x1               ; =1
      6c: aa1403e0     	mov	x0, x20
      70: d1000402     	sub	x2, x0, #0x1
      74: aa1903e0     	mov	x0, x25
      78: aa1c03e1     	mov	x1, x28
      7c: 94000000     	bl	0x7c <___pl_fn_0+0x7c>
      80: aa1903e1     	mov	x1, x25
      84: b9402c21     	ldr	w1, [x1, #0x2c]
      88: 35002ee1     	cbnz	w1, 0x664 <___pl_fn_0+0x664>
      8c: b27ff7e1     	mov	x1, #0x7ffffffffffffffe ; =9223372036854775806
      90: eb01001f     	cmp	x0, x1
      94: 54002d4c     	b.gt	0x63c <___pl_fn_0+0x63c>
      98: eb13029f     	cmp	x20, x19
      9c: 54002ccb     	b.lt	0x634 <___pl_fn_0+0x634>
      a0: 9100040c     	add	x12, x0, #0x1
      a4: aa0c03fa     	mov	x26, x12
      a8: d1000695     	sub	x21, x20, #0x1
      ac: f10002bf     	cmp	x21, #0x0
      b0: 9a9fb7e0     	cset	x0, ge
      b4: 72001c1f     	tst	w0, #0xff
      b8: 54000201     	b.ne	0xf8 <___pl_fn_0+0xf8>
      bc: aa1903e0     	mov	x0, x25
      c0: aa1903e0     	mov	x0, x25
      c4: b9401000     	ldr	w0, [x0, #0x10]
      c8: 51000400     	sub	w0, w0, #0x1
      cc: aa1903e1     	mov	x1, x25
      d0: b9001020     	str	w0, [x1, #0x10]
      d4: aa1a03e0     	mov	x0, x26
      d8: 910183ff     	add	sp, sp, #0x60
      dc: a8c153f3     	ldp	x19, x20, [sp], #0x10
      e0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
      e4: a8c163f7     	ldp	x23, x24, [sp], #0x10
      e8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
      ec: f84107fc     	ldr	x28, [sp], #0x10
      f0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      f4: d65f03c0     	ret
      f8: eb13029f     	cmp	x20, x19
      fc: 5400298b     	b.lt	0x62c <___pl_fn_0+0x62c>
     100: aa1c03e1     	mov	x1, x28
     104: 34001c01     	cbz	w1, 0x484 <___pl_fn_0+0x484>
     108: aa1903e0     	mov	x0, x25
     10c: f9400001     	ldr	x1, [x0]
     110: aa1c03e0     	mov	x0, x28
     114: 2a0003f7     	mov	w23, w0
     118: 8b170c22     	add	x2, x1, x23, lsl #3
     11c: f9400843     	ldr	x3, [x2, #0x10]
     120: d1000680     	sub	x0, x20, #0x1
     124: eb03001f     	cmp	x0, x3
     128: 54001ae2     	b.hs	0x484 <___pl_fn_0+0x484>
     12c: d1000698     	sub	x24, x20, #0x1
     130: 8b180c40     	add	x0, x2, x24, lsl #3
     134: f9401400     	ldr	x0, [x0, #0x28]
     138: f9400c44     	ldr	x4, [x2, #0x18]
     13c: eb04007f     	cmp	x3, x4
     140: 54000140     	b.eq	0x168 <___pl_fn_0+0x168>
     144: f9401043     	ldr	x3, [x2, #0x20]
     148: d1000682     	sub	x2, x20, #0x1
     14c: d346fc44     	lsr	x4, x2, #6
     150: 8b040063     	add	x3, x3, x4
     154: f8637821     	ldr	x1, [x1, x3, lsl #3]
     158: 92401442     	and	x2, x2, #0x3f
     15c: 9ac222c2     	lsl	x2, x22, x2
     160: 8a020021     	and	x1, x1, x2
     164: b4001901     	cbz	x1, 0x484 <___pl_fn_0+0x484>
     168: aa1c03e2     	mov	x2, x28
     16c: 34001a42     	cbz	w2, 0x4b4 <___pl_fn_0+0x4b4>
     170: aa1903e1     	mov	x1, x25
     174: f9400022     	ldr	x2, [x1]
     178: 8b170c43     	add	x3, x2, x23, lsl #3
     17c: f9400864     	ldr	x4, [x3, #0x10]
     180: eb0402bf     	cmp	x21, x4
     184: 54001982     	b.hs	0x4b4 <___pl_fn_0+0x4b4>
     188: 8b150c61     	add	x1, x3, x21, lsl #3
     18c: f9401421     	ldr	x1, [x1, #0x28]
     190: f9400c65     	ldr	x5, [x3, #0x18]
     194: eb05009f     	cmp	x4, x5
     198: 54000120     	b.eq	0x1bc <___pl_fn_0+0x1bc>
     19c: f9401063     	ldr	x3, [x3, #0x20]
     1a0: d346fea4     	lsr	x4, x21, #6
     1a4: 8b040063     	add	x3, x3, x4
     1a8: f8637842     	ldr	x2, [x2, x3, lsl #3]
     1ac: 924016a3     	and	x3, x21, #0x3f
     1b0: 9ac322c3     	lsl	x3, x22, x3
     1b4: 8a030042     	and	x2, x2, x3
     1b8: b40017e2     	cbz	x2, 0x4b4 <___pl_fn_0+0x4b4>
     1bc: eb13029f     	cmp	x20, x19
     1c0: 5400232b     	b.lt	0x624 <___pl_fn_0+0x624>
     1c4: aa1c03e2     	mov	x2, x28
     1c8: 340018c2     	cbz	w2, 0x4e0 <___pl_fn_0+0x4e0>
     1cc: aa1903e2     	mov	x2, x25
     1d0: f940004f     	ldr	x15, [x2]
     1d4: 8b170ded     	add	x13, x15, x23, lsl #3
     1d8: f94009ae     	ldr	x14, [x13, #0x10]
     1dc: d1000682     	sub	x2, x20, #0x1
     1e0: eb0e005f     	cmp	x2, x14
     1e4: 540017e2     	b.hs	0x4e0 <___pl_fn_0+0x4e0>
     1e8: f9400da2     	ldr	x2, [x13, #0x18]
     1ec: eb0201df     	cmp	x14, x2
     1f0: 54000240     	b.eq	0x238 <___pl_fn_0+0x238>
     1f4: f94011a3     	ldr	x3, [x13, #0x20]
     1f8: d1000685     	sub	x5, x20, #0x1
     1fc: d346fca4     	lsr	x4, x5, #6
     200: 8b040063     	add	x3, x3, x4
     204: f86379e4     	ldr	x4, [x15, x3, lsl #3]
     208: 924014a5     	and	x5, x5, #0x3f
     20c: 9ac522c5     	lsl	x5, x22, x5
     210: 8a050086     	and	x6, x4, x5
     214: b5000126     	cbnz	x6, 0x238 <___pl_fn_0+0x238>
     218: aa050084     	orr	x4, x4, x5
     21c: f82379e4     	str	x4, [x15, x3, lsl #3]
     220: 91000442     	add	x2, x2, #0x1
     224: f9000da2     	str	x2, [x13, #0x18]
     228: eb0e005f     	cmp	x2, x14
     22c: 54000061     	b.ne	0x238 <___pl_fn_0+0x238>
     230: d2800002     	mov	x2, #0x0                ; =0
     234: f90011a2     	str	x2, [x13, #0x20]
     238: 8b180da2     	add	x2, x13, x24, lsl #3
     23c: f9001441     	str	x1, [x2, #0x28]
     240: aa1c03e2     	mov	x2, x28
     244: 34001682     	cbz	w2, 0x514 <___pl_fn_0+0x514>
     248: aa1903e2     	mov	x2, x25
     24c: f9400043     	ldr	x3, [x2]
     250: 8b170c61     	add	x1, x3, x23, lsl #3
     254: f9400822     	ldr	x2, [x1, #0x10]
     258: eb0202bf     	cmp	x21, x2
     25c: 540015c2     	b.hs	0x514 <___pl_fn_0+0x514>
     260: f9400c24     	ldr	x4, [x1, #0x18]
     264: eb04005f     	cmp	x2, x4
     268: 54000220     	b.eq	0x2ac <___pl_fn_0+0x2ac>
     26c: f9401025     	ldr	x5, [x1, #0x20]
     270: d346fea6     	lsr	x6, x21, #6
     274: 8b0600a5     	add	x5, x5, x6
     278: f8657866     	ldr	x6, [x3, x5, lsl #3]
     27c: 924016a7     	and	x7, x21, #0x3f
     280: 9ac722c7     	lsl	x7, x22, x7
     284: 8a0700c8     	and	x8, x6, x7
     288: b5000128     	cbnz	x8, 0x2ac <___pl_fn_0+0x2ac>
     28c: aa0700c6     	orr	x6, x6, x7
     290: f8257866     	str	x6, [x3, x5, lsl #3]
     294: 91000483     	add	x3, x4, #0x1
     298: f9000c23     	str	x3, [x1, #0x18]
     29c: eb02007f     	cmp	x3, x2
     2a0: 54000061     	b.ne	0x2ac <___pl_fn_0+0x2ac>
     2a4: d2800002     	mov	x2, #0x0                ; =0
     2a8: f9001022     	str	x2, [x1, #0x20]
     2ac: 8b150c21     	add	x1, x1, x21, lsl #3
     2b0: f9001420     	str	x0, [x1, #0x28]
     2b4: eb13029f     	cmp	x20, x19
     2b8: 54001b2b     	b.lt	0x61c <___pl_fn_0+0x61c>
     2bc: aa1903e0     	mov	x0, x25
     2c0: b9401000     	ldr	w0, [x0, #0x10]
     2c4: aa1903e1     	mov	x1, x25
     2c8: b9401421     	ldr	w1, [x1, #0x14]
     2cc: 6b01001f     	cmp	w0, w1
     2d0: 54001a22     	b.hs	0x614 <___pl_fn_0+0x614>
     2d4: d1000682     	sub	x2, x20, #0x1
     2d8: aa1903e0     	mov	x0, x25
     2dc: aa1c03e1     	mov	x1, x28
     2e0: 94000000     	bl	0x2e0 <___pl_fn_0+0x2e0>
     2e4: aa1903e1     	mov	x1, x25
     2e8: b9402c22     	ldr	w2, [x1, #0x2c]
     2ec: 35001bc2     	cbnz	w2, 0x664 <___pl_fn_0+0x664>
     2f0: aa1a03e7     	mov	x7, x26
     2f4: ab0000e7     	adds	x7, x7, x0
     2f8: 9a9f77e5     	cset	x5, vs
     2fc: 72001cbf     	tst	w5, #0xff
     300: 54001861     	b.ne	0x60c <___pl_fn_0+0x60c>
     304: eb13029f     	cmp	x20, x19
     308: 540017eb     	b.lt	0x604 <___pl_fn_0+0x604>
     30c: aa1c03e2     	mov	x2, x28
     310: 340011a2     	cbz	w2, 0x544 <___pl_fn_0+0x544>
     314: aa1903e0     	mov	x0, x25
     318: f940000b     	ldr	x11, [x0]
     31c: 8b170d6a     	add	x10, x11, x23, lsl #3
     320: f940094c     	ldr	x12, [x10, #0x10]
     324: d1000684     	sub	x4, x20, #0x1
     328: eb0c009f     	cmp	x4, x12
     32c: 540010c2     	b.hs	0x544 <___pl_fn_0+0x544>
     330: 8b180d4e     	add	x14, x10, x24, lsl #3
     334: f94015cd     	ldr	x13, [x14, #0x28]
     338: f9400d4f     	ldr	x15, [x10, #0x18]
     33c: eb0f019f     	cmp	x12, x15
     340: 54000140     	b.eq	0x368 <___pl_fn_0+0x368>
     344: f9401140     	ldr	x0, [x10, #0x20]
     348: d1000681     	sub	x1, x20, #0x1
     34c: d346fc23     	lsr	x3, x1, #6
     350: 8b030000     	add	x0, x0, x3
     354: f8607960     	ldr	x0, [x11, x0, lsl #3]
     358: 92401421     	and	x1, x1, #0x3f
     35c: 9ac122c1     	lsl	x1, x22, x1
     360: 8a010000     	and	x0, x0, x1
     364: b4000f00     	cbz	x0, 0x544 <___pl_fn_0+0x544>
     368: 34001042     	cbz	w2, 0x570 <___pl_fn_0+0x570>
     36c: eb0c02bf     	cmp	x21, x12
     370: 54001002     	b.hs	0x570 <___pl_fn_0+0x570>
     374: 8b150d41     	add	x1, x10, x21, lsl #3
     378: f9401425     	ldr	x5, [x1, #0x28]
     37c: eb0f019f     	cmp	x12, x15
     380: 54000120     	b.eq	0x3a4 <___pl_fn_0+0x3a4>
     384: f9401140     	ldr	x0, [x10, #0x20]
     388: d346fea3     	lsr	x3, x21, #6
     38c: 8b030000     	add	x0, x0, x3
     390: f8607960     	ldr	x0, [x11, x0, lsl #3]
     394: 924016a3     	and	x3, x21, #0x3f
     398: 9ac322c3     	lsl	x3, x22, x3
     39c: 8a030000     	and	x0, x0, x3
     3a0: b4000e80     	cbz	x0, 0x570 <___pl_fn_0+0x570>
     3a4: eb13029f     	cmp	x20, x19
     3a8: 540012ab     	b.lt	0x5fc <___pl_fn_0+0x5fc>
     3ac: 34000f62     	cbz	w2, 0x598 <___pl_fn_0+0x598>
     3b0: eb0c009f     	cmp	x4, x12
     3b4: 54000f22     	b.hs	0x598 <___pl_fn_0+0x598>
     3b8: eb0f019f     	cmp	x12, x15
     3bc: 54000240     	b.eq	0x404 <___pl_fn_0+0x404>
     3c0: f9401140     	ldr	x0, [x10, #0x20]
     3c4: d1000686     	sub	x6, x20, #0x1
     3c8: d346fcc3     	lsr	x3, x6, #6
     3cc: 8b030004     	add	x4, x0, x3
     3d0: f8647963     	ldr	x3, [x11, x4, lsl #3]
     3d4: 924014c0     	and	x0, x6, #0x3f
     3d8: 9ac022c0     	lsl	x0, x22, x0
     3dc: 8a000066     	and	x6, x3, x0
     3e0: b5000126     	cbnz	x6, 0x404 <___pl_fn_0+0x404>
     3e4: aa000060     	orr	x0, x3, x0
     3e8: f8247960     	str	x0, [x11, x4, lsl #3]
     3ec: 910005e0     	add	x0, x15, #0x1
     3f0: f9000d40     	str	x0, [x10, #0x18]
     3f4: eb0c001f     	cmp	x0, x12
     3f8: 54000061     	b.ne	0x404 <___pl_fn_0+0x404>
     3fc: d2800003     	mov	x3, #0x0                ; =0
     400: f9001143     	str	x3, [x10, #0x20]
     404: f90015c5     	str	x5, [x14, #0x28]
     408: 34000e02     	cbz	w2, 0x5c8 <___pl_fn_0+0x5c8>
     40c: f9400948     	ldr	x8, [x10, #0x10]
     410: eb0802bf     	cmp	x21, x8
     414: 54000da2     	b.hs	0x5c8 <___pl_fn_0+0x5c8>
     418: f9400d43     	ldr	x3, [x10, #0x18]
     41c: eb03011f     	cmp	x8, x3
     420: 54000220     	b.eq	0x464 <___pl_fn_0+0x464>
     424: f9401140     	ldr	x0, [x10, #0x20]
     428: d346fea4     	lsr	x4, x21, #6
     42c: 8b040004     	add	x4, x0, x4
     430: f8647965     	ldr	x5, [x11, x4, lsl #3]
     434: 924016a0     	and	x0, x21, #0x3f
     438: 9ac022c0     	lsl	x0, x22, x0
     43c: 8a0000a6     	and	x6, x5, x0
     440: b5000126     	cbnz	x6, 0x464 <___pl_fn_0+0x464>
     444: aa0000a0     	orr	x0, x5, x0
     448: f8247960     	str	x0, [x11, x4, lsl #3]
     44c: 91000460     	add	x0, x3, #0x1
     450: f9000d40     	str	x0, [x10, #0x18]
     454: eb08001f     	cmp	x0, x8
     458: 54000061     	b.ne	0x464 <___pl_fn_0+0x464>
     45c: d2800000     	mov	x0, #0x0                ; =0
     460: f9001140     	str	x0, [x10, #0x20]
     464: f900142d     	str	x13, [x1, #0x28]
     468: b24107e0     	mov	x0, #-0x7fffffffffffffff ; =-9223372036854775807
     46c: eb0002bf     	cmp	x21, x0
     470: 54000c2b     	b.lt	0x5f4 <___pl_fn_0+0x5f4>
     474: d10006b5     	sub	x21, x21, #0x1
     478: aa0703fa     	mov	x26, x7
     47c: aa0203fc     	mov	x28, x2
     480: 17ffff0b     	b	0xac <___pl_fn_0+0xac>
     484: d1000680     	sub	x0, x20, #0x1
     488: 910003e3     	mov	x3, sp
     48c: f80003e0     	stur	x0, [sp]
     490: 528000c1     	mov	w1, #0x6                ; =6
     494: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     498: f9400084     	ldr	x4, [x4]
     49c: aa1c03e2     	mov	x2, x28
     4a0: aa1903e0     	mov	x0, x25
     4a4: d63f0080     	blr	x4
     4a8: 35000de0     	cbnz	w0, 0x664 <___pl_fn_0+0x664>
     4ac: 528000e1     	mov	w1, #0x7                ; =7
     4b0: 14000069     	b	0x654 <___pl_fn_0+0x654>
     4b4: 910023e3     	add	x3, sp, #0x8
     4b8: f80083f5     	stur	x21, [sp, #0x8]
     4bc: 52800101     	mov	w1, #0x8                ; =8
     4c0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     4c4: f9400084     	ldr	x4, [x4]
     4c8: aa1c03e2     	mov	x2, x28
     4cc: aa1903e0     	mov	x0, x25
     4d0: d63f0080     	blr	x4
     4d4: 35000c80     	cbnz	w0, 0x664 <___pl_fn_0+0x664>
     4d8: 52800121     	mov	w1, #0x9                ; =9
     4dc: 1400005e     	b	0x654 <___pl_fn_0+0x654>
     4e0: d1000680     	sub	x0, x20, #0x1
     4e4: 910043e3     	add	x3, sp, #0x10
     4e8: f80103e0     	stur	x0, [sp, #0x10]
     4ec: f80183e1     	stur	x1, [sp, #0x18]
     4f0: 52800161     	mov	w1, #0xb                ; =11
     4f4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     4f8: f9400084     	ldr	x4, [x4]
     4fc: aa1c03e2     	mov	x2, x28
     500: aa1903e0     	mov	x0, x25
     504: d63f0080     	blr	x4
     508: 35000ae0     	cbnz	w0, 0x664 <___pl_fn_0+0x664>
     50c: 52800181     	mov	w1, #0xc                ; =12
     510: 14000051     	b	0x654 <___pl_fn_0+0x654>
     514: 910083e3     	add	x3, sp, #0x20
     518: f80203f5     	stur	x21, [sp, #0x20]
     51c: f80283e0     	stur	x0, [sp, #0x28]
     520: 528001a1     	mov	w1, #0xd                ; =13
     524: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     528: f9400084     	ldr	x4, [x4]
     52c: aa1c03e2     	mov	x2, x28
     530: aa1903e0     	mov	x0, x25
     534: d63f0080     	blr	x4
     538: 35000960     	cbnz	w0, 0x664 <___pl_fn_0+0x664>
     53c: 528001c1     	mov	w1, #0xe                ; =14
     540: 14000045     	b	0x654 <___pl_fn_0+0x654>
     544: d1000680     	sub	x0, x20, #0x1
     548: 9100c3e3     	add	x3, sp, #0x30
     54c: f80303e0     	stur	x0, [sp, #0x30]
     550: 52800261     	mov	w1, #0x13               ; =19
     554: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     558: f9400084     	ldr	x4, [x4]
     55c: aa1903e0     	mov	x0, x25
     560: d63f0080     	blr	x4
     564: 35000800     	cbnz	w0, 0x664 <___pl_fn_0+0x664>
     568: 52800281     	mov	w1, #0x14               ; =20
     56c: 1400003a     	b	0x654 <___pl_fn_0+0x654>
     570: 9100e3e3     	add	x3, sp, #0x38
     574: f80383f5     	stur	x21, [sp, #0x38]
     578: 528002a1     	mov	w1, #0x15               ; =21
     57c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     580: f9400084     	ldr	x4, [x4]
     584: aa1903e0     	mov	x0, x25
     588: d63f0080     	blr	x4
     58c: 350006c0     	cbnz	w0, 0x664 <___pl_fn_0+0x664>
     590: 528002c1     	mov	w1, #0x16               ; =22
     594: 14000030     	b	0x654 <___pl_fn_0+0x654>
     598: d1000680     	sub	x0, x20, #0x1
     59c: 910103e3     	add	x3, sp, #0x40
     5a0: f80403e0     	stur	x0, [sp, #0x40]
     5a4: f80483e5     	stur	x5, [sp, #0x48]
     5a8: 52800301     	mov	w1, #0x18               ; =24
     5ac: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5b0: f9400084     	ldr	x4, [x4]
     5b4: aa1903e0     	mov	x0, x25
     5b8: d63f0080     	blr	x4
     5bc: 35000540     	cbnz	w0, 0x664 <___pl_fn_0+0x664>
     5c0: 52800321     	mov	w1, #0x19               ; =25
     5c4: 14000024     	b	0x654 <___pl_fn_0+0x654>
     5c8: 910143e3     	add	x3, sp, #0x50
     5cc: f80503f5     	stur	x21, [sp, #0x50]
     5d0: f80583ed     	stur	x13, [sp, #0x58]
     5d4: 52800341     	mov	w1, #0x1a               ; =26
     5d8: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     5dc: f94001ad     	ldr	x13, [x13]
     5e0: aa1903e0     	mov	x0, x25
     5e4: d63f01a0     	blr	x13
     5e8: 350003e0     	cbnz	w0, 0x664 <___pl_fn_0+0x664>
     5ec: 52800361     	mov	w1, #0x1b               ; =27
     5f0: 14000019     	b	0x654 <___pl_fn_0+0x654>
     5f4: 52800381     	mov	w1, #0x1c               ; =28
     5f8: 14000017     	b	0x654 <___pl_fn_0+0x654>
     5fc: 528002e1     	mov	w1, #0x17               ; =23
     600: 14000015     	b	0x654 <___pl_fn_0+0x654>
     604: 52800241     	mov	w1, #0x12               ; =18
     608: 14000013     	b	0x654 <___pl_fn_0+0x654>
     60c: 52800221     	mov	w1, #0x11               ; =17
     610: 14000011     	b	0x654 <___pl_fn_0+0x654>
     614: 52800201     	mov	w1, #0x10               ; =16
     618: 1400000f     	b	0x654 <___pl_fn_0+0x654>
     61c: 528001e1     	mov	w1, #0xf                ; =15
     620: 1400000d     	b	0x654 <___pl_fn_0+0x654>
     624: 52800141     	mov	w1, #0xa                ; =10
     628: 1400000b     	b	0x654 <___pl_fn_0+0x654>
     62c: 528000a1     	mov	w1, #0x5                ; =5
     630: 14000009     	b	0x654 <___pl_fn_0+0x654>
     634: 52800061     	mov	w1, #0x3                ; =3
     638: 14000007     	b	0x654 <___pl_fn_0+0x654>
     63c: 52800041     	mov	w1, #0x2                ; =2
     640: 14000005     	b	0x654 <___pl_fn_0+0x654>
     644: 52800021     	mov	w1, #0x1                ; =1
     648: 14000003     	b	0x654 <___pl_fn_0+0x654>
     64c: aa0003f9     	mov	x25, x0
     650: 52800001     	mov	w1, #0x0                ; =0
     654: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     658: f9400042     	ldr	x2, [x2]
     65c: aa1903e0     	mov	x0, x25
     660: d63f0040     	blr	x2
     664: d2800000     	mov	x0, #0x0                ; =0
     668: 910183ff     	add	sp, sp, #0x60
     66c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     670: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     674: a8c163f7     	ldp	x23, x24, [sp], #0x10
     678: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     67c: f84107fc     	ldr	x28, [sp], #0x10
     680: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     684: d65f03c0     	ret

0000000000000688 <___pl_fn_1>:
     688: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     68c: 910003fd     	mov	x29, sp
     690: a9bf6ff5     	stp	x21, x27, [sp, #-0x10]!
     694: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     698: d10083ff     	sub	sp, sp, #0x20
     69c: b9401005     	ldr	w5, [x0, #0x10]
     6a0: 110004a5     	add	w5, w5, #0x1
     6a4: b9001005     	str	w5, [x0, #0x10]
     6a8: aa0003f5     	mov	x21, x0
     6ac: d2800147     	mov	x7, #0xa                ; =10
     6b0: 910003e3     	mov	x3, sp
     6b4: f80003e7     	stur	x7, [sp]
     6b8: 528003a1     	mov	w1, #0x1d               ; =29
     6bc: 52802002     	mov	w2, #0x100              ; =256
     6c0: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     6c4: f9400108     	ldr	x8, [x8]
     6c8: aa1503e0     	mov	x0, x21
     6cc: d63f0100     	blr	x8
     6d0: 350010a0     	cbnz	w0, 0x8e4 <___pl_fn_1+0x25c>
     6d4: aa1503e0     	mov	x0, x21
     6d8: f9401801     	ldr	x1, [x0, #0x30]
     6dc: b9401813     	ldr	w19, [x0, #0x18]
     6e0: b9401c0a     	ldr	w10, [x0, #0x1c]
     6e4: 11000674     	add	w20, w19, #0x1
     6e8: 6b0a029f     	cmp	w20, w10
     6ec: 54000f28     	b.hi	0x8d0 <___pl_fn_1+0x248>
     6f0: aa1503e0     	mov	x0, x21
     6f4: f940100c     	ldr	x12, [x0, #0x20]
     6f8: b8335981     	str	w1, [x12, w19, uxtw #2]
     6fc: aa0103fb     	mov	x27, x1
     700: b9001814     	str	w20, [x0, #0x18]
     704: 528003e1     	mov	w1, #0x1f               ; =31
     708: 52800002     	mov	w2, #0x0                ; =0
     70c: 9000000e     	adrp	x14, 0x0 <___pl_fn_0>
     710: f94001ce     	ldr	x14, [x14]
     714: d63f01c0     	blr	x14
     718: 35000e60     	cbnz	w0, 0x8e4 <___pl_fn_1+0x25c>
     71c: aa1503e0     	mov	x0, x21
     720: f9401802     	ldr	x2, [x0, #0x30]
     724: aa0203ea     	mov	x10, x2
     728: b9001813     	str	w19, [x0, #0x18]
     72c: d2800000     	mov	x0, #0x0                ; =0
     730: f100241f     	cmp	x0, #0x9
     734: 9a9fc7e1     	cset	x1, le
     738: 72001c3f     	tst	w1, #0xff
     73c: 54000521     	b.ne	0x7e0 <___pl_fn_1+0x158>
     740: aa1503e0     	mov	x0, x21
     744: b9401c00     	ldr	w0, [x0, #0x1c]
     748: 6b00029f     	cmp	w20, w0
     74c: 540009e8     	b.hi	0x888 <___pl_fn_1+0x200>
     750: aa1503e0     	mov	x0, x21
     754: f9401000     	ldr	x0, [x0, #0x20]
     758: aa1b03e1     	mov	x1, x27
     75c: b8335801     	str	w1, [x0, w19, uxtw #2]
     760: aa1503e0     	mov	x0, x21
     764: b9001814     	str	w20, [x0, #0x18]
     768: b9401000     	ldr	w0, [x0, #0x10]
     76c: aa1503e3     	mov	x3, x21
     770: b9401462     	ldr	w2, [x3, #0x14]
     774: 6b02001f     	cmp	w0, w2
     778: 54000842     	b.hs	0x880 <___pl_fn_1+0x1f8>
     77c: aa0a03e2     	mov	x2, x10
     780: aa1503e0     	mov	x0, x21
     784: 94000000     	bl	0x784 <___pl_fn_1+0xfc>
     788: aa0003e2     	mov	x2, x0
     78c: aa1503e0     	mov	x0, x21
     790: b9402c00     	ldr	w0, [x0, #0x2c]
     794: 35000a80     	cbnz	w0, 0x8e4 <___pl_fn_1+0x25c>
     798: aa1503e0     	mov	x0, x21
     79c: b9001813     	str	w19, [x0, #0x18]
     7a0: 52800461     	mov	w1, #0x23               ; =35
     7a4: 52802003     	mov	w3, #0x100              ; =256
     7a8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     7ac: f9400084     	ldr	x4, [x4]
     7b0: d63f0080     	blr	x4
     7b4: 35000980     	cbnz	w0, 0x8e4 <___pl_fn_1+0x25c>
     7b8: aa1503e0     	mov	x0, x21
     7bc: b9401000     	ldr	w0, [x0, #0x10]
     7c0: 51000400     	sub	w0, w0, #0x1
     7c4: aa1503e1     	mov	x1, x21
     7c8: b9001020     	str	w0, [x1, #0x10]
     7cc: 910083ff     	add	sp, sp, #0x20
     7d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7d4: a8c16ff5     	ldp	x21, x27, [sp], #0x10
     7d8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7dc: d65f03c0     	ret
     7e0: aa1b03e1     	mov	x1, x27
     7e4: 34000561     	cbz	w1, 0x890 <___pl_fn_1+0x208>
     7e8: aa1503e2     	mov	x2, x21
     7ec: f9400043     	ldr	x3, [x2]
     7f0: 2a0103e2     	mov	w2, w1
     7f4: aa0103fb     	mov	x27, x1
     7f8: 8b020c61     	add	x1, x3, x2, lsl #3
     7fc: f9400824     	ldr	x4, [x1, #0x10]
     800: eb04001f     	cmp	x0, x4
     804: 54000482     	b.hs	0x894 <___pl_fn_1+0x20c>
     808: aa1b03e2     	mov	x2, x27
     80c: f9400c25     	ldr	x5, [x1, #0x18]
     810: eb05009f     	cmp	x4, x5
     814: 54000240     	b.eq	0x85c <___pl_fn_1+0x1d4>
     818: f9401026     	ldr	x6, [x1, #0x20]
     81c: d346fc07     	lsr	x7, x0, #6
     820: 8b0700c6     	add	x6, x6, x7
     824: f8667867     	ldr	x7, [x3, x6, lsl #3]
     828: d2800028     	mov	x8, #0x1                ; =1
     82c: 92401409     	and	x9, x0, #0x3f
     830: 9ac92108     	lsl	x8, x8, x9
     834: 8a0800e9     	and	x9, x7, x8
     838: b5000129     	cbnz	x9, 0x85c <___pl_fn_1+0x1d4>
     83c: aa0800e7     	orr	x7, x7, x8
     840: f8267867     	str	x7, [x3, x6, lsl #3]
     844: 910004a3     	add	x3, x5, #0x1
     848: f9000c23     	str	x3, [x1, #0x18]
     84c: eb04007f     	cmp	x3, x4
     850: 54000061     	b.ne	0x85c <___pl_fn_1+0x1d4>
     854: d2800003     	mov	x3, #0x0                ; =0
     858: f9001023     	str	x3, [x1, #0x20]
     85c: d2800003     	mov	x3, #0x0                ; =0
     860: 8b000c21     	add	x1, x1, x0, lsl #3
     864: f9001423     	str	x3, [x1, #0x28]
     868: b27ff7e1     	mov	x1, #0x7ffffffffffffffe ; =9223372036854775806
     86c: eb01001f     	cmp	x0, x1
     870: 540002cc     	b.gt	0x8c8 <___pl_fn_1+0x240>
     874: 91000400     	add	x0, x0, #0x1
     878: aa0203fb     	mov	x27, x2
     87c: 17ffffad     	b	0x730 <___pl_fn_1+0xa8>
     880: 52800441     	mov	w1, #0x22               ; =34
     884: 14000014     	b	0x8d4 <___pl_fn_1+0x24c>
     888: 52800421     	mov	w1, #0x21               ; =33
     88c: 14000012     	b	0x8d4 <___pl_fn_1+0x24c>
     890: aa0103fb     	mov	x27, x1
     894: 910023e3     	add	x3, sp, #0x8
     898: f80083e0     	stur	x0, [sp, #0x8]
     89c: d2800000     	mov	x0, #0x0                ; =0
     8a0: f80103e0     	stur	x0, [sp, #0x10]
     8a4: 52800481     	mov	w1, #0x24               ; =36
     8a8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     8ac: f9400084     	ldr	x4, [x4]
     8b0: aa1b03e2     	mov	x2, x27
     8b4: aa1503e0     	mov	x0, x21
     8b8: d63f0080     	blr	x4
     8bc: 35000140     	cbnz	w0, 0x8e4 <___pl_fn_1+0x25c>
     8c0: 528004a1     	mov	w1, #0x25               ; =37
     8c4: 14000004     	b	0x8d4 <___pl_fn_1+0x24c>
     8c8: 528004c1     	mov	w1, #0x26               ; =38
     8cc: 14000002     	b	0x8d4 <___pl_fn_1+0x24c>
     8d0: 528003c1     	mov	w1, #0x1e               ; =30
     8d4: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     8d8: f94000c6     	ldr	x6, [x6]
     8dc: aa1503e0     	mov	x0, x21
     8e0: d63f00c0     	blr	x6
     8e4: 910083ff     	add	sp, sp, #0x20
     8e8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8ec: a8c16ff5     	ldp	x21, x27, [sp], #0x10
     8f0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8f4: d65f03c0     	ret
