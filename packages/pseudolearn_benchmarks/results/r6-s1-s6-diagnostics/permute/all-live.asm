
packages/pseudolearn_benchmarks/results/r6-s1-s6-diagnostics/permute/all-live.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
       c: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
      10: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      14: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      18: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      1c: d10183ff     	sub	sp, sp, #0x60
      20: aa0103fb     	mov	x27, x1
      24: b9401001     	ldr	w1, [x0, #0x10]
      28: 11000421     	add	w1, w1, #0x1
      2c: b9001001     	str	w1, [x0, #0x10]
      30: b50000a2     	cbnz	x2, 0x44 <___pl_fn_0+0x44>
      34: d280002c     	mov	x12, #0x1               ; =1
      38: aa0003f9     	mov	x25, x0
      3c: aa0c03fc     	mov	x28, x12
      40: 1400002b     	b	0xec <___pl_fn_0+0xec>
      44: b24107fa     	mov	x26, #-0x7fffffffffffffff ; =-9223372036854775807
      48: eb1a005f     	cmp	x2, x26
      4c: aa0203f3     	mov	x19, x2
      50: 5400338b     	b.lt	0x6c0 <___pl_fn_0+0x6c0>
      54: b940181c     	ldr	w28, [x0, #0x18]
      58: b9401c03     	ldr	w3, [x0, #0x1c]
      5c: 11000781     	add	w1, w28, #0x1
      60: 6b03003f     	cmp	w1, w3
      64: 54003288     	b.hi	0x6b4 <___pl_fn_0+0x6b4>
      68: f9401003     	ldr	x3, [x0, #0x20]
      6c: aa1b03ee     	mov	x14, x27
      70: b83c586e     	str	w14, [x3, w28, uxtw #2]
      74: b9001801     	str	w1, [x0, #0x18]
      78: b9401001     	ldr	w1, [x0, #0x10]
      7c: b9401403     	ldr	w3, [x0, #0x14]
      80: aa0003f9     	mov	x25, x0
      84: 6b03003f     	cmp	w1, w3
      88: 54003122     	b.hs	0x6ac <___pl_fn_0+0x6ac>
      8c: d2800035     	mov	x21, #0x1               ; =1
      90: aa1303e0     	mov	x0, x19
      94: d1000402     	sub	x2, x0, #0x1
      98: aa1903e0     	mov	x0, x25
      9c: aa1b03e1     	mov	x1, x27
      a0: 94000000     	bl	0xa0 <___pl_fn_0+0xa0>
      a4: aa1903e1     	mov	x1, x25
      a8: b9402c21     	ldr	w1, [x1, #0x2c]
      ac: 35003161     	cbnz	w1, 0x6d8 <___pl_fn_0+0x6d8>
      b0: aa1903e1     	mov	x1, x25
      b4: b900183c     	str	w28, [x1, #0x18]
      b8: b27ff7e1     	mov	x1, #0x7ffffffffffffffe ; =9223372036854775806
      bc: eb01001f     	cmp	x0, x1
      c0: 54002f2c     	b.gt	0x6a4 <___pl_fn_0+0x6a4>
      c4: eb1a027f     	cmp	x19, x26
      c8: 54002eab     	b.lt	0x69c <___pl_fn_0+0x69c>
      cc: 9100040c     	add	x12, x0, #0x1
      d0: aa0c03fc     	mov	x28, x12
      d4: d1000674     	sub	x20, x19, #0x1
      d8: f100029f     	cmp	x20, #0x0
      dc: 9a9fb7e0     	cset	x0, ge
      e0: 72001c1f     	tst	w0, #0xff
      e4: 54000201     	b.ne	0x124 <___pl_fn_0+0x124>
      e8: aa1903e0     	mov	x0, x25
      ec: aa1903e0     	mov	x0, x25
      f0: b9401000     	ldr	w0, [x0, #0x10]
      f4: 51000400     	sub	w0, w0, #0x1
      f8: aa1903ed     	mov	x13, x25
      fc: b90011a0     	str	w0, [x13, #0x10]
     100: aa1c03e0     	mov	x0, x28
     104: 910183ff     	add	sp, sp, #0x60
     108: a8c153f3     	ldp	x19, x20, [sp], #0x10
     10c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     110: a8c163f7     	ldp	x23, x24, [sp], #0x10
     114: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     118: a8c173fb     	ldp	x27, x28, [sp], #0x10
     11c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     120: d65f03c0     	ret
     124: eb1a027f     	cmp	x19, x26
     128: 54002b6b     	b.lt	0x694 <___pl_fn_0+0x694>
     12c: aa1b03e1     	mov	x1, x27
     130: 34001da1     	cbz	w1, 0x4e4 <___pl_fn_0+0x4e4>
     134: aa1903e0     	mov	x0, x25
     138: f9400001     	ldr	x1, [x0]
     13c: aa1b03e0     	mov	x0, x27
     140: 2a0003f6     	mov	w22, w0
     144: 8b160c22     	add	x2, x1, x22, lsl #3
     148: f9400843     	ldr	x3, [x2, #0x10]
     14c: d1000660     	sub	x0, x19, #0x1
     150: eb03001f     	cmp	x0, x3
     154: 54001c82     	b.hs	0x4e4 <___pl_fn_0+0x4e4>
     158: d1000677     	sub	x23, x19, #0x1
     15c: 8b170c40     	add	x0, x2, x23, lsl #3
     160: f9401400     	ldr	x0, [x0, #0x28]
     164: f9400c44     	ldr	x4, [x2, #0x18]
     168: eb04007f     	cmp	x3, x4
     16c: 54000140     	b.eq	0x194 <___pl_fn_0+0x194>
     170: f9401043     	ldr	x3, [x2, #0x20]
     174: d1000662     	sub	x2, x19, #0x1
     178: d346fc44     	lsr	x4, x2, #6
     17c: 8b040063     	add	x3, x3, x4
     180: f8637821     	ldr	x1, [x1, x3, lsl #3]
     184: 92401442     	and	x2, x2, #0x3f
     188: 9ac222a2     	lsl	x2, x21, x2
     18c: 8a020021     	and	x1, x1, x2
     190: b4001aa1     	cbz	x1, 0x4e4 <___pl_fn_0+0x4e4>
     194: aa1b03e2     	mov	x2, x27
     198: 34001be2     	cbz	w2, 0x514 <___pl_fn_0+0x514>
     19c: aa1903e1     	mov	x1, x25
     1a0: f9400029     	ldr	x9, [x1]
     1a4: 8b160d2a     	add	x10, x9, x22, lsl #3
     1a8: f940094b     	ldr	x11, [x10, #0x10]
     1ac: eb0b029f     	cmp	x20, x11
     1b0: 54001b22     	b.hs	0x514 <___pl_fn_0+0x514>
     1b4: 8b140d4c     	add	x12, x10, x20, lsl #3
     1b8: f940158c     	ldr	x12, [x12, #0x28]
     1bc: f9400d4d     	ldr	x13, [x10, #0x18]
     1c0: eb0d017f     	cmp	x11, x13
     1c4: 54000120     	b.eq	0x1e8 <___pl_fn_0+0x1e8>
     1c8: f940114f     	ldr	x15, [x10, #0x20]
     1cc: d346fe81     	lsr	x1, x20, #6
     1d0: 8b0101ef     	add	x15, x15, x1
     1d4: f86f792f     	ldr	x15, [x9, x15, lsl #3]
     1d8: 92401681     	and	x1, x20, #0x3f
     1dc: 9ac122a1     	lsl	x1, x21, x1
     1e0: 8a0101ef     	and	x15, x15, x1
     1e4: b400198f     	cbz	x15, 0x514 <___pl_fn_0+0x514>
     1e8: eb1a027f     	cmp	x19, x26
     1ec: 5400250b     	b.lt	0x68c <___pl_fn_0+0x68c>
     1f0: aa1b03e2     	mov	x2, x27
     1f4: 34001a62     	cbz	w2, 0x540 <___pl_fn_0+0x540>
     1f8: aa1903e1     	mov	x1, x25
     1fc: f9400023     	ldr	x3, [x1]
     200: 8b160c61     	add	x1, x3, x22, lsl #3
     204: f9400822     	ldr	x2, [x1, #0x10]
     208: d1000664     	sub	x4, x19, #0x1
     20c: eb02009f     	cmp	x4, x2
     210: 54001982     	b.hs	0x540 <___pl_fn_0+0x540>
     214: f9400c24     	ldr	x4, [x1, #0x18]
     218: eb04005f     	cmp	x2, x4
     21c: 54000240     	b.eq	0x264 <___pl_fn_0+0x264>
     220: f9401025     	ldr	x5, [x1, #0x20]
     224: d1000667     	sub	x7, x19, #0x1
     228: d346fce6     	lsr	x6, x7, #6
     22c: 8b0600a5     	add	x5, x5, x6
     230: f8657866     	ldr	x6, [x3, x5, lsl #3]
     234: 924014e7     	and	x7, x7, #0x3f
     238: 9ac722a7     	lsl	x7, x21, x7
     23c: 8a0700c8     	and	x8, x6, x7
     240: b5000128     	cbnz	x8, 0x264 <___pl_fn_0+0x264>
     244: aa0700c6     	orr	x6, x6, x7
     248: f8257866     	str	x6, [x3, x5, lsl #3]
     24c: 91000483     	add	x3, x4, #0x1
     250: f9000c23     	str	x3, [x1, #0x18]
     254: eb02007f     	cmp	x3, x2
     258: 54000061     	b.ne	0x264 <___pl_fn_0+0x264>
     25c: d2800002     	mov	x2, #0x0                ; =0
     260: f9001022     	str	x2, [x1, #0x20]
     264: 8b170c21     	add	x1, x1, x23, lsl #3
     268: f900142c     	str	x12, [x1, #0x28]
     26c: aa1b03e2     	mov	x2, x27
     270: 34001822     	cbz	w2, 0x574 <___pl_fn_0+0x574>
     274: aa1903e1     	mov	x1, x25
     278: f9400023     	ldr	x3, [x1]
     27c: 8b160c61     	add	x1, x3, x22, lsl #3
     280: f9400822     	ldr	x2, [x1, #0x10]
     284: eb02029f     	cmp	x20, x2
     288: 54001762     	b.hs	0x574 <___pl_fn_0+0x574>
     28c: f9400c24     	ldr	x4, [x1, #0x18]
     290: eb04005f     	cmp	x2, x4
     294: 54000220     	b.eq	0x2d8 <___pl_fn_0+0x2d8>
     298: f9401025     	ldr	x5, [x1, #0x20]
     29c: d346fe86     	lsr	x6, x20, #6
     2a0: 8b0600a5     	add	x5, x5, x6
     2a4: f8657866     	ldr	x6, [x3, x5, lsl #3]
     2a8: 92401687     	and	x7, x20, #0x3f
     2ac: 9ac722a7     	lsl	x7, x21, x7
     2b0: 8a0700c8     	and	x8, x6, x7
     2b4: b5000128     	cbnz	x8, 0x2d8 <___pl_fn_0+0x2d8>
     2b8: aa0700c6     	orr	x6, x6, x7
     2bc: f8257866     	str	x6, [x3, x5, lsl #3]
     2c0: 91000485     	add	x5, x4, #0x1
     2c4: f9000c25     	str	x5, [x1, #0x18]
     2c8: eb0200bf     	cmp	x5, x2
     2cc: 54000061     	b.ne	0x2d8 <___pl_fn_0+0x2d8>
     2d0: d2800009     	mov	x9, #0x0                ; =0
     2d4: f9001029     	str	x9, [x1, #0x20]
     2d8: 8b140c2b     	add	x11, x1, x20, lsl #3
     2dc: f9001560     	str	x0, [x11, #0x28]
     2e0: eb1a027f     	cmp	x19, x26
     2e4: 54001d0b     	b.lt	0x684 <___pl_fn_0+0x684>
     2e8: aa1903e0     	mov	x0, x25
     2ec: b9401818     	ldr	w24, [x0, #0x18]
     2f0: b9401c00     	ldr	w0, [x0, #0x1c]
     2f4: 1100070f     	add	w15, w24, #0x1
     2f8: 6b0001ff     	cmp	w15, w0
     2fc: 54001c08     	b.hi	0x67c <___pl_fn_0+0x67c>
     300: aa1903e0     	mov	x0, x25
     304: f9401000     	ldr	x0, [x0, #0x20]
     308: aa1b03e2     	mov	x2, x27
     30c: b8385802     	str	w2, [x0, w24, uxtw #2]
     310: aa1903e0     	mov	x0, x25
     314: b900180f     	str	w15, [x0, #0x18]
     318: b9401000     	ldr	w0, [x0, #0x10]
     31c: aa1903e1     	mov	x1, x25
     320: b9401421     	ldr	w1, [x1, #0x14]
     324: 6b01001f     	cmp	w0, w1
     328: 54001a62     	b.hs	0x674 <___pl_fn_0+0x674>
     32c: d1000662     	sub	x2, x19, #0x1
     330: aa1903e0     	mov	x0, x25
     334: aa1b03e1     	mov	x1, x27
     338: 94000000     	bl	0x338 <___pl_fn_0+0x338>
     33c: aa1903e1     	mov	x1, x25
     340: b9402c21     	ldr	w1, [x1, #0x2c]
     344: 35001ca1     	cbnz	w1, 0x6d8 <___pl_fn_0+0x6d8>
     348: aa1903e1     	mov	x1, x25
     34c: b9001838     	str	w24, [x1, #0x18]
     350: aa1c03eb     	mov	x11, x28
     354: ab00016b     	adds	x11, x11, x0
     358: 9a9f77e0     	cset	x0, vs
     35c: 72001c1f     	tst	w0, #0xff
     360: 54001861     	b.ne	0x66c <___pl_fn_0+0x66c>
     364: eb1a027f     	cmp	x19, x26
     368: 540017eb     	b.lt	0x664 <___pl_fn_0+0x664>
     36c: aa1b03e2     	mov	x2, x27
     370: 340011a2     	cbz	w2, 0x5a4 <___pl_fn_0+0x5a4>
     374: aa1903e0     	mov	x0, x25
     378: f9400004     	ldr	x4, [x0]
     37c: 8b160c83     	add	x3, x4, x22, lsl #3
     380: f9400867     	ldr	x7, [x3, #0x10]
     384: d100066a     	sub	x10, x19, #0x1
     388: eb07015f     	cmp	x10, x7
     38c: 540010c2     	b.hs	0x5a4 <___pl_fn_0+0x5a4>
     390: 8b170c66     	add	x6, x3, x23, lsl #3
     394: f94014c1     	ldr	x1, [x6, #0x28]
     398: f9400c68     	ldr	x8, [x3, #0x18]
     39c: eb0800ff     	cmp	x7, x8
     3a0: 54000140     	b.eq	0x3c8 <___pl_fn_0+0x3c8>
     3a4: f9401065     	ldr	x5, [x3, #0x20]
     3a8: d1000660     	sub	x0, x19, #0x1
     3ac: d346fc09     	lsr	x9, x0, #6
     3b0: 8b0900a5     	add	x5, x5, x9
     3b4: f8657885     	ldr	x5, [x4, x5, lsl #3]
     3b8: 92401400     	and	x0, x0, #0x3f
     3bc: 9ac022a0     	lsl	x0, x21, x0
     3c0: 8a0000a0     	and	x0, x5, x0
     3c4: b4000f00     	cbz	x0, 0x5a4 <___pl_fn_0+0x5a4>
     3c8: 34001042     	cbz	w2, 0x5d0 <___pl_fn_0+0x5d0>
     3cc: eb07029f     	cmp	x20, x7
     3d0: 54001002     	b.hs	0x5d0 <___pl_fn_0+0x5d0>
     3d4: 8b140c65     	add	x5, x3, x20, lsl #3
     3d8: f94014a9     	ldr	x9, [x5, #0x28]
     3dc: eb0800ff     	cmp	x7, x8
     3e0: 54000120     	b.eq	0x404 <___pl_fn_0+0x404>
     3e4: f9401060     	ldr	x0, [x3, #0x20]
     3e8: d346fe8c     	lsr	x12, x20, #6
     3ec: 8b0c0000     	add	x0, x0, x12
     3f0: f8607880     	ldr	x0, [x4, x0, lsl #3]
     3f4: 9240168c     	and	x12, x20, #0x3f
     3f8: 9acc22ac     	lsl	x12, x21, x12
     3fc: 8a0c0000     	and	x0, x0, x12
     400: b4000e80     	cbz	x0, 0x5d0 <___pl_fn_0+0x5d0>
     404: eb1a027f     	cmp	x19, x26
     408: 540012ab     	b.lt	0x65c <___pl_fn_0+0x65c>
     40c: 34000f62     	cbz	w2, 0x5f8 <___pl_fn_0+0x5f8>
     410: eb07015f     	cmp	x10, x7
     414: 54000f22     	b.hs	0x5f8 <___pl_fn_0+0x5f8>
     418: eb0800ff     	cmp	x7, x8
     41c: 54000240     	b.eq	0x464 <___pl_fn_0+0x464>
     420: f940106f     	ldr	x15, [x3, #0x20]
     424: d1000660     	sub	x0, x19, #0x1
     428: d346fc0a     	lsr	x10, x0, #6
     42c: 8b0a01ef     	add	x15, x15, x10
     430: f86f788a     	ldr	x10, [x4, x15, lsl #3]
     434: 92401400     	and	x0, x0, #0x3f
     438: 9ac022a0     	lsl	x0, x21, x0
     43c: 8a00014c     	and	x12, x10, x0
     440: b500012c     	cbnz	x12, 0x464 <___pl_fn_0+0x464>
     444: aa000140     	orr	x0, x10, x0
     448: f82f7880     	str	x0, [x4, x15, lsl #3]
     44c: 91000500     	add	x0, x8, #0x1
     450: f9000c60     	str	x0, [x3, #0x18]
     454: eb07001f     	cmp	x0, x7
     458: 54000061     	b.ne	0x464 <___pl_fn_0+0x464>
     45c: d2800000     	mov	x0, #0x0                ; =0
     460: f9001060     	str	x0, [x3, #0x20]
     464: f90014c9     	str	x9, [x6, #0x28]
     468: 34000e02     	cbz	w2, 0x628 <___pl_fn_0+0x628>
     46c: f9400866     	ldr	x6, [x3, #0x10]
     470: eb06029f     	cmp	x20, x6
     474: 54000da2     	b.hs	0x628 <___pl_fn_0+0x628>
     478: f9400c67     	ldr	x7, [x3, #0x18]
     47c: eb0700df     	cmp	x6, x7
     480: 54000220     	b.eq	0x4c4 <___pl_fn_0+0x4c4>
     484: f9401060     	ldr	x0, [x3, #0x20]
     488: d346fe88     	lsr	x8, x20, #6
     48c: 8b080008     	add	x8, x0, x8
     490: f8687889     	ldr	x9, [x4, x8, lsl #3]
     494: 92401680     	and	x0, x20, #0x3f
     498: 9ac022a0     	lsl	x0, x21, x0
     49c: 8a00012a     	and	x10, x9, x0
     4a0: b500012a     	cbnz	x10, 0x4c4 <___pl_fn_0+0x4c4>
     4a4: aa000120     	orr	x0, x9, x0
     4a8: f8287880     	str	x0, [x4, x8, lsl #3]
     4ac: 910004e0     	add	x0, x7, #0x1
     4b0: f9000c60     	str	x0, [x3, #0x18]
     4b4: eb06001f     	cmp	x0, x6
     4b8: 54000061     	b.ne	0x4c4 <___pl_fn_0+0x4c4>
     4bc: d2800000     	mov	x0, #0x0                ; =0
     4c0: f9001060     	str	x0, [x3, #0x20]
     4c4: f90014a1     	str	x1, [x5, #0x28]
     4c8: b24107e0     	mov	x0, #-0x7fffffffffffffff ; =-9223372036854775807
     4cc: eb00029f     	cmp	x20, x0
     4d0: 54000c2b     	b.lt	0x654 <___pl_fn_0+0x654>
     4d4: d1000694     	sub	x20, x20, #0x1
     4d8: aa0203fb     	mov	x27, x2
     4dc: aa0b03fc     	mov	x28, x11
     4e0: 17fffefe     	b	0xd8 <___pl_fn_0+0xd8>
     4e4: d1000661     	sub	x1, x19, #0x1
     4e8: 910003e3     	mov	x3, sp
     4ec: f80003e1     	stur	x1, [sp]
     4f0: 528000e1     	mov	w1, #0x7                ; =7
     4f4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     4f8: f9400084     	ldr	x4, [x4]
     4fc: aa1b03e2     	mov	x2, x27
     500: aa1903e0     	mov	x0, x25
     504: d63f0080     	blr	x4
     508: 35000e80     	cbnz	w0, 0x6d8 <___pl_fn_0+0x6d8>
     50c: 52800101     	mov	w1, #0x8                ; =8
     510: 1400006e     	b	0x6c8 <___pl_fn_0+0x6c8>
     514: 910023e3     	add	x3, sp, #0x8
     518: f80083f4     	stur	x20, [sp, #0x8]
     51c: 52800121     	mov	w1, #0x9                ; =9
     520: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     524: f9400084     	ldr	x4, [x4]
     528: aa1b03e2     	mov	x2, x27
     52c: aa1903e0     	mov	x0, x25
     530: d63f0080     	blr	x4
     534: 35000d20     	cbnz	w0, 0x6d8 <___pl_fn_0+0x6d8>
     538: 52800141     	mov	w1, #0xa                ; =10
     53c: 14000063     	b	0x6c8 <___pl_fn_0+0x6c8>
     540: d1000660     	sub	x0, x19, #0x1
     544: 910043e3     	add	x3, sp, #0x10
     548: f80103e0     	stur	x0, [sp, #0x10]
     54c: f80183ec     	stur	x12, [sp, #0x18]
     550: 52800181     	mov	w1, #0xc                ; =12
     554: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     558: f9400084     	ldr	x4, [x4]
     55c: aa1b03e2     	mov	x2, x27
     560: aa1903e0     	mov	x0, x25
     564: d63f0080     	blr	x4
     568: 35000b80     	cbnz	w0, 0x6d8 <___pl_fn_0+0x6d8>
     56c: 528001a1     	mov	w1, #0xd                ; =13
     570: 14000056     	b	0x6c8 <___pl_fn_0+0x6c8>
     574: 910083e3     	add	x3, sp, #0x20
     578: f80203f4     	stur	x20, [sp, #0x20]
     57c: f80283e0     	stur	x0, [sp, #0x28]
     580: 528001c1     	mov	w1, #0xe                ; =14
     584: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     588: f9400084     	ldr	x4, [x4]
     58c: aa1b03e2     	mov	x2, x27
     590: aa1903e0     	mov	x0, x25
     594: d63f0080     	blr	x4
     598: 35000a00     	cbnz	w0, 0x6d8 <___pl_fn_0+0x6d8>
     59c: 528001e1     	mov	w1, #0xf                ; =15
     5a0: 1400004a     	b	0x6c8 <___pl_fn_0+0x6c8>
     5a4: d1000660     	sub	x0, x19, #0x1
     5a8: 9100c3e3     	add	x3, sp, #0x30
     5ac: f80303e0     	stur	x0, [sp, #0x30]
     5b0: 528002a1     	mov	w1, #0x15               ; =21
     5b4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5b8: f9400084     	ldr	x4, [x4]
     5bc: aa1903e0     	mov	x0, x25
     5c0: d63f0080     	blr	x4
     5c4: 350008a0     	cbnz	w0, 0x6d8 <___pl_fn_0+0x6d8>
     5c8: 528002c1     	mov	w1, #0x16               ; =22
     5cc: 1400003f     	b	0x6c8 <___pl_fn_0+0x6c8>
     5d0: 9100e3e3     	add	x3, sp, #0x38
     5d4: f80383f4     	stur	x20, [sp, #0x38]
     5d8: 528002e1     	mov	w1, #0x17               ; =23
     5dc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5e0: f9400084     	ldr	x4, [x4]
     5e4: aa1903e0     	mov	x0, x25
     5e8: d63f0080     	blr	x4
     5ec: 35000760     	cbnz	w0, 0x6d8 <___pl_fn_0+0x6d8>
     5f0: 52800301     	mov	w1, #0x18               ; =24
     5f4: 14000035     	b	0x6c8 <___pl_fn_0+0x6c8>
     5f8: d1000666     	sub	x6, x19, #0x1
     5fc: 910103e3     	add	x3, sp, #0x40
     600: f80403e6     	stur	x6, [sp, #0x40]
     604: f80483e9     	stur	x9, [sp, #0x48]
     608: 52800341     	mov	w1, #0x1a               ; =26
     60c: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     610: f9400108     	ldr	x8, [x8]
     614: aa1903e0     	mov	x0, x25
     618: d63f0100     	blr	x8
     61c: 350005e0     	cbnz	w0, 0x6d8 <___pl_fn_0+0x6d8>
     620: 52800361     	mov	w1, #0x1b               ; =27
     624: 14000029     	b	0x6c8 <___pl_fn_0+0x6c8>
     628: 910143e3     	add	x3, sp, #0x50
     62c: f80503f4     	stur	x20, [sp, #0x50]
     630: f80583e1     	stur	x1, [sp, #0x58]
     634: 52800381     	mov	w1, #0x1c               ; =28
     638: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     63c: f9400084     	ldr	x4, [x4]
     640: aa1903e0     	mov	x0, x25
     644: d63f0080     	blr	x4
     648: 35000480     	cbnz	w0, 0x6d8 <___pl_fn_0+0x6d8>
     64c: 528003a1     	mov	w1, #0x1d               ; =29
     650: 1400001e     	b	0x6c8 <___pl_fn_0+0x6c8>
     654: 528003c1     	mov	w1, #0x1e               ; =30
     658: 1400001c     	b	0x6c8 <___pl_fn_0+0x6c8>
     65c: 52800321     	mov	w1, #0x19               ; =25
     660: 1400001a     	b	0x6c8 <___pl_fn_0+0x6c8>
     664: 52800281     	mov	w1, #0x14               ; =20
     668: 14000018     	b	0x6c8 <___pl_fn_0+0x6c8>
     66c: 52800261     	mov	w1, #0x13               ; =19
     670: 14000016     	b	0x6c8 <___pl_fn_0+0x6c8>
     674: 52800241     	mov	w1, #0x12               ; =18
     678: 14000014     	b	0x6c8 <___pl_fn_0+0x6c8>
     67c: 52800221     	mov	w1, #0x11               ; =17
     680: 14000012     	b	0x6c8 <___pl_fn_0+0x6c8>
     684: 52800201     	mov	w1, #0x10               ; =16
     688: 14000010     	b	0x6c8 <___pl_fn_0+0x6c8>
     68c: 52800161     	mov	w1, #0xb                ; =11
     690: 1400000e     	b	0x6c8 <___pl_fn_0+0x6c8>
     694: 528000c1     	mov	w1, #0x6                ; =6
     698: 1400000c     	b	0x6c8 <___pl_fn_0+0x6c8>
     69c: 52800081     	mov	w1, #0x4                ; =4
     6a0: 1400000a     	b	0x6c8 <___pl_fn_0+0x6c8>
     6a4: 52800061     	mov	w1, #0x3                ; =3
     6a8: 14000008     	b	0x6c8 <___pl_fn_0+0x6c8>
     6ac: 52800041     	mov	w1, #0x2                ; =2
     6b0: 14000006     	b	0x6c8 <___pl_fn_0+0x6c8>
     6b4: aa0003f9     	mov	x25, x0
     6b8: 52800021     	mov	w1, #0x1                ; =1
     6bc: 14000003     	b	0x6c8 <___pl_fn_0+0x6c8>
     6c0: aa0003f9     	mov	x25, x0
     6c4: 52800001     	mov	w1, #0x0                ; =0
     6c8: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     6cc: f94000a5     	ldr	x5, [x5]
     6d0: aa1903e0     	mov	x0, x25
     6d4: d63f00a0     	blr	x5
     6d8: d2800000     	mov	x0, #0x0                ; =0
     6dc: 910183ff     	add	sp, sp, #0x60
     6e0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6e4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6e8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6ec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6f0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     6f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6f8: d65f03c0     	ret

00000000000006fc <___pl_fn_1>:
     6fc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     700: 910003fd     	mov	x29, sp
     704: a9bf6ff5     	stp	x21, x27, [sp, #-0x10]!
     708: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     70c: d10083ff     	sub	sp, sp, #0x20
     710: b9401005     	ldr	w5, [x0, #0x10]
     714: 110004a5     	add	w5, w5, #0x1
     718: b9001005     	str	w5, [x0, #0x10]
     71c: aa0003f5     	mov	x21, x0
     720: d2800147     	mov	x7, #0xa                ; =10
     724: 910003e3     	mov	x3, sp
     728: f80003e7     	stur	x7, [sp]
     72c: 528003e1     	mov	w1, #0x1f               ; =31
     730: 52802002     	mov	w2, #0x100              ; =256
     734: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     738: f9400108     	ldr	x8, [x8]
     73c: aa1503e0     	mov	x0, x21
     740: d63f0100     	blr	x8
     744: 350010a0     	cbnz	w0, 0x958 <___pl_fn_1+0x25c>
     748: aa1503e0     	mov	x0, x21
     74c: f9401801     	ldr	x1, [x0, #0x30]
     750: b9401813     	ldr	w19, [x0, #0x18]
     754: b9401c0a     	ldr	w10, [x0, #0x1c]
     758: 11000674     	add	w20, w19, #0x1
     75c: 6b0a029f     	cmp	w20, w10
     760: 54000f28     	b.hi	0x944 <___pl_fn_1+0x248>
     764: aa1503e0     	mov	x0, x21
     768: f940100c     	ldr	x12, [x0, #0x20]
     76c: b8335981     	str	w1, [x12, w19, uxtw #2]
     770: aa0103fb     	mov	x27, x1
     774: b9001814     	str	w20, [x0, #0x18]
     778: 52800421     	mov	w1, #0x21               ; =33
     77c: 52800002     	mov	w2, #0x0                ; =0
     780: 9000000e     	adrp	x14, 0x0 <___pl_fn_0>
     784: f94001ce     	ldr	x14, [x14]
     788: d63f01c0     	blr	x14
     78c: 35000e60     	cbnz	w0, 0x958 <___pl_fn_1+0x25c>
     790: aa1503e0     	mov	x0, x21
     794: f9401802     	ldr	x2, [x0, #0x30]
     798: aa0203ea     	mov	x10, x2
     79c: b9001813     	str	w19, [x0, #0x18]
     7a0: d2800000     	mov	x0, #0x0                ; =0
     7a4: f100241f     	cmp	x0, #0x9
     7a8: 9a9fc7e1     	cset	x1, le
     7ac: 72001c3f     	tst	w1, #0xff
     7b0: 54000521     	b.ne	0x854 <___pl_fn_1+0x158>
     7b4: aa1503e0     	mov	x0, x21
     7b8: b9401c00     	ldr	w0, [x0, #0x1c]
     7bc: 6b00029f     	cmp	w20, w0
     7c0: 540009e8     	b.hi	0x8fc <___pl_fn_1+0x200>
     7c4: aa1503e0     	mov	x0, x21
     7c8: f9401000     	ldr	x0, [x0, #0x20]
     7cc: aa1b03e1     	mov	x1, x27
     7d0: b8335801     	str	w1, [x0, w19, uxtw #2]
     7d4: aa1503e0     	mov	x0, x21
     7d8: b9001814     	str	w20, [x0, #0x18]
     7dc: b9401000     	ldr	w0, [x0, #0x10]
     7e0: aa1503e3     	mov	x3, x21
     7e4: b9401462     	ldr	w2, [x3, #0x14]
     7e8: 6b02001f     	cmp	w0, w2
     7ec: 54000842     	b.hs	0x8f4 <___pl_fn_1+0x1f8>
     7f0: aa0a03e2     	mov	x2, x10
     7f4: aa1503e0     	mov	x0, x21
     7f8: 94000000     	bl	0x7f8 <___pl_fn_1+0xfc>
     7fc: aa0003e2     	mov	x2, x0
     800: aa1503e0     	mov	x0, x21
     804: b9402c00     	ldr	w0, [x0, #0x2c]
     808: 35000a80     	cbnz	w0, 0x958 <___pl_fn_1+0x25c>
     80c: aa1503e0     	mov	x0, x21
     810: b9001813     	str	w19, [x0, #0x18]
     814: 528004a1     	mov	w1, #0x25               ; =37
     818: 52802003     	mov	w3, #0x100              ; =256
     81c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     820: f9400084     	ldr	x4, [x4]
     824: d63f0080     	blr	x4
     828: 35000980     	cbnz	w0, 0x958 <___pl_fn_1+0x25c>
     82c: aa1503e0     	mov	x0, x21
     830: b9401000     	ldr	w0, [x0, #0x10]
     834: 51000400     	sub	w0, w0, #0x1
     838: aa1503e1     	mov	x1, x21
     83c: b9001020     	str	w0, [x1, #0x10]
     840: 910083ff     	add	sp, sp, #0x20
     844: a8c153f3     	ldp	x19, x20, [sp], #0x10
     848: a8c16ff5     	ldp	x21, x27, [sp], #0x10
     84c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     850: d65f03c0     	ret
     854: aa1b03e1     	mov	x1, x27
     858: 34000561     	cbz	w1, 0x904 <___pl_fn_1+0x208>
     85c: aa1503e2     	mov	x2, x21
     860: f9400043     	ldr	x3, [x2]
     864: 2a0103e2     	mov	w2, w1
     868: aa0103fb     	mov	x27, x1
     86c: 8b020c61     	add	x1, x3, x2, lsl #3
     870: f9400824     	ldr	x4, [x1, #0x10]
     874: eb04001f     	cmp	x0, x4
     878: 54000482     	b.hs	0x908 <___pl_fn_1+0x20c>
     87c: aa1b03e2     	mov	x2, x27
     880: f9400c25     	ldr	x5, [x1, #0x18]
     884: eb05009f     	cmp	x4, x5
     888: 54000240     	b.eq	0x8d0 <___pl_fn_1+0x1d4>
     88c: f9401026     	ldr	x6, [x1, #0x20]
     890: d346fc07     	lsr	x7, x0, #6
     894: 8b0700c6     	add	x6, x6, x7
     898: f8667867     	ldr	x7, [x3, x6, lsl #3]
     89c: d2800028     	mov	x8, #0x1                ; =1
     8a0: 92401409     	and	x9, x0, #0x3f
     8a4: 9ac92108     	lsl	x8, x8, x9
     8a8: 8a0800e9     	and	x9, x7, x8
     8ac: b5000129     	cbnz	x9, 0x8d0 <___pl_fn_1+0x1d4>
     8b0: aa0800e7     	orr	x7, x7, x8
     8b4: f8267867     	str	x7, [x3, x6, lsl #3]
     8b8: 910004a3     	add	x3, x5, #0x1
     8bc: f9000c23     	str	x3, [x1, #0x18]
     8c0: eb04007f     	cmp	x3, x4
     8c4: 54000061     	b.ne	0x8d0 <___pl_fn_1+0x1d4>
     8c8: d2800003     	mov	x3, #0x0                ; =0
     8cc: f9001023     	str	x3, [x1, #0x20]
     8d0: d2800003     	mov	x3, #0x0                ; =0
     8d4: 8b000c21     	add	x1, x1, x0, lsl #3
     8d8: f9001423     	str	x3, [x1, #0x28]
     8dc: b27ff7e1     	mov	x1, #0x7ffffffffffffffe ; =9223372036854775806
     8e0: eb01001f     	cmp	x0, x1
     8e4: 540002cc     	b.gt	0x93c <___pl_fn_1+0x240>
     8e8: 91000400     	add	x0, x0, #0x1
     8ec: aa0203fb     	mov	x27, x2
     8f0: 17ffffad     	b	0x7a4 <___pl_fn_1+0xa8>
     8f4: 52800481     	mov	w1, #0x24               ; =36
     8f8: 14000014     	b	0x948 <___pl_fn_1+0x24c>
     8fc: 52800461     	mov	w1, #0x23               ; =35
     900: 14000012     	b	0x948 <___pl_fn_1+0x24c>
     904: aa0103fb     	mov	x27, x1
     908: 910023e3     	add	x3, sp, #0x8
     90c: f80083e0     	stur	x0, [sp, #0x8]
     910: d2800000     	mov	x0, #0x0                ; =0
     914: f80103e0     	stur	x0, [sp, #0x10]
     918: 528004c1     	mov	w1, #0x26               ; =38
     91c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     920: f9400084     	ldr	x4, [x4]
     924: aa1b03e2     	mov	x2, x27
     928: aa1503e0     	mov	x0, x21
     92c: d63f0080     	blr	x4
     930: 35000140     	cbnz	w0, 0x958 <___pl_fn_1+0x25c>
     934: 528004e1     	mov	w1, #0x27               ; =39
     938: 14000004     	b	0x948 <___pl_fn_1+0x24c>
     93c: 52800501     	mov	w1, #0x28               ; =40
     940: 14000002     	b	0x948 <___pl_fn_1+0x24c>
     944: 52800401     	mov	w1, #0x20               ; =32
     948: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     94c: f94000c6     	ldr	x6, [x6]
     950: aa1503e0     	mov	x0, x21
     954: d63f00c0     	blr	x6
     958: 910083ff     	add	sp, sp, #0x20
     95c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     960: a8c16ff5     	ldp	x21, x27, [sp], #0x10
     964: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     968: d65f03c0     	ret
