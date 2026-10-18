
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_69571/permute/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
       c: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
      10: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      14: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      18: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      1c: d101c3ff     	sub	sp, sp, #0x70
      20: aa0103e4     	mov	x4, x1
      24: b9401001     	ldr	w1, [x0, #0x10]
      28: 11000423     	add	w3, w1, #0x1
      2c: b9001003     	str	w3, [x0, #0x10]
      30: b5000162     	cbnz	x2, 0x5c <___pl_fn_0+0x5c>
      34: d2800023     	mov	x3, #0x1                ; =1
      38: d2800015     	mov	x21, #0x0               ; =0
      3c: 52800021     	mov	w1, #0x1                ; =1
      40: 52800002     	mov	w2, #0x0                ; =0
      44: aa0003fc     	mov	x28, x0
      48: aa0303fb     	mov	x27, x3
      4c: aa1503fa     	mov	x26, x21
      50: aa0003ea     	mov	x10, x0
      54: aa0203e0     	mov	x0, x2
      58: 1400002a     	b	0x100 <___pl_fn_0+0x100>
      5c: d2800033     	mov	x19, #0x1               ; =1
      60: eb130043     	subs	x3, x2, x19
      64: aa0203f5     	mov	x21, x2
      68: 9a9f77e2     	cset	x2, vs
      6c: 72001c5f     	tst	w2, #0xff
      70: 54005ca1     	b.ne	0xc04 <___pl_fn_0+0xc04>
      74: b9401402     	ldr	w2, [x0, #0x14]
      78: aa0003fc     	mov	x28, x0
      7c: 11000420     	add	w0, w1, #0x1
      80: 6b02001f     	cmp	w0, w2
      84: 54005a42     	b.hs	0xbcc <___pl_fn_0+0xbcc>
      88: aa0303e2     	mov	x2, x3
      8c: aa0403f4     	mov	x20, x4
      90: aa1c03e0     	mov	x0, x28
      94: aa1403e1     	mov	x1, x20
      98: 94000000     	bl	0x98 <___pl_fn_0+0x98>
      9c: aa1c03e1     	mov	x1, x28
      a0: b9402c21     	ldr	w1, [x1, #0x2c]
      a4: 35005821     	cbnz	w1, 0xba8 <___pl_fn_0+0xba8>
      a8: ab000263     	adds	x3, x19, x0
      ac: aa0303fb     	mov	x27, x3
      b0: 9a9f77e0     	cset	x0, vs
      b4: 72001c1f     	tst	w0, #0xff
      b8: 540055c1     	b.ne	0xb70 <___pl_fn_0+0xb70>
      bc: aa1503f6     	mov	x22, x21
      c0: eb1302d5     	subs	x21, x22, x19
      c4: 9a9f77e0     	cset	x0, vs
      c8: 72001c1f     	tst	w0, #0xff
      cc: 54005361     	b.ne	0xb38 <___pl_fn_0+0xb38>
      d0: d2800000     	mov	x0, #0x0                ; =0
      d4: f80603e0     	stur	x0, [sp, #0x60]
      d8: 52800037     	mov	w23, #0x1               ; =1
      dc: 52800000     	mov	w0, #0x0                ; =0
      e0: aa1703e1     	mov	x1, x23
      e4: aa1703e2     	mov	x2, x23
      e8: f84603fa     	ldur	x26, [sp, #0x60]
      ec: f10002bf     	cmp	x21, #0x0
      f0: 9a9fb7e3     	cset	x3, ge
      f4: 72001c7f     	tst	w3, #0xff
      f8: 54000201     	b.ne	0x138 <___pl_fn_0+0x138>
      fc: aa1c03ea     	mov	x10, x28
     100: aa1c03ea     	mov	x10, x28
     104: b9401140     	ldr	w0, [x10, #0x10]
     108: 51000400     	sub	w0, w0, #0x1
     10c: aa1c03ed     	mov	x13, x28
     110: b90011a0     	str	w0, [x13, #0x10]
     114: aa1b03e0     	mov	x0, x27
     118: 9101c3ff     	add	sp, sp, #0x70
     11c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     120: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     124: a8c163f7     	ldp	x23, x24, [sp], #0x10
     128: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     12c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     130: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     134: d65f03c0     	ret
     138: aa1c03e0     	mov	x0, x28
     13c: f9402400     	ldr	x0, [x0, #0x48]
     140: 2a1403f8     	mov	w24, w20
     144: d1000701     	sub	x1, x24, #0x1
     148: eb00003f     	cmp	x1, x0
     14c: 54002fe2     	b.hs	0x748 <___pl_fn_0+0x748>
     150: aa1c03e0     	mov	x0, x28
     154: f9402000     	ldr	x0, [x0, #0x40]
     158: d2800502     	mov	x2, #0x28               ; =40
     15c: d1000703     	sub	x3, x24, #0x1
     160: 9b027c61     	mul	x1, x3, x2
     164: 9b020062     	madd	x2, x3, x2, x0
     168: f9400442     	ldr	x2, [x2, #0x8]
     16c: b50000a2     	cbnz	x2, 0x180 <___pl_fn_0+0x180>
     170: 14000176     	b	0x748 <___pl_fn_0+0x748>
     174: aa1c03e0     	mov	x0, x28
     178: f9401802     	ldr	x2, [x0, #0x30]
     17c: 14000002     	b	0x184 <___pl_fn_0+0x184>
     180: f8616802     	ldr	x2, [x0, x1]
     184: eb1302c0     	subs	x0, x22, x19
     188: 9a9f77e1     	cset	x1, vs
     18c: 72001c3f     	tst	w1, #0xff
     190: 54004b81     	b.ne	0xb00 <___pl_fn_0+0xb00>
     194: 34002ea2     	cbz	w2, 0x768 <___pl_fn_0+0x768>
     198: aa1c03e1     	mov	x1, x28
     19c: f9400021     	ldr	x1, [x1]
     1a0: 2a0203e3     	mov	w3, w2
     1a4: 8b030c21     	add	x1, x1, x3, lsl #3
     1a8: f9400823     	ldr	x3, [x1, #0x10]
     1ac: eb03001f     	cmp	x0, x3
     1b0: 54002dc2     	b.hs	0x768 <___pl_fn_0+0x768>
     1b4: 8b000c24     	add	x4, x1, x0, lsl #3
     1b8: f9401499     	ldr	x25, [x4, #0x28]
     1bc: f9400c24     	ldr	x4, [x1, #0x18]
     1c0: eb04007f     	cmp	x3, x4
     1c4: 540000a0     	b.eq	0x1d8 <___pl_fn_0+0x1d8>
     1c8: 14000168     	b	0x768 <___pl_fn_0+0x768>
     1cc: aa1c03e0     	mov	x0, x28
     1d0: f9401819     	ldr	x25, [x0, #0x30]
     1d4: 14000002     	b	0x1dc <___pl_fn_0+0x1dc>
     1d8: aa1c03e0     	mov	x0, x28
     1dc: aa1c03e0     	mov	x0, x28
     1e0: f940240a     	ldr	x10, [x0, #0x48]
     1e4: d100070b     	sub	x11, x24, #0x1
     1e8: eb0a017f     	cmp	x11, x10
     1ec: 54002d02     	b.hs	0x78c <___pl_fn_0+0x78c>
     1f0: aa1c03e0     	mov	x0, x28
     1f4: f940200d     	ldr	x13, [x0, #0x40]
     1f8: d280050f     	mov	x15, #0x28              ; =40
     1fc: d1000700     	sub	x0, x24, #0x1
     200: 9b0f7c0e     	mul	x14, x0, x15
     204: 9b0f340f     	madd	x15, x0, x15, x13
     208: f94005ef     	ldr	x15, [x15, #0x8]
     20c: b50000af     	cbnz	x15, 0x220 <___pl_fn_0+0x220>
     210: 1400015f     	b	0x78c <___pl_fn_0+0x78c>
     214: aa1c03e0     	mov	x0, x28
     218: f9401802     	ldr	x2, [x0, #0x30]
     21c: 14000002     	b	0x224 <___pl_fn_0+0x224>
     220: f86e69a2     	ldr	x2, [x13, x14]
     224: 34002c42     	cbz	w2, 0x7ac <___pl_fn_0+0x7ac>
     228: aa1c03e0     	mov	x0, x28
     22c: f9400000     	ldr	x0, [x0]
     230: 2a0203e1     	mov	w1, w2
     234: 8b010c00     	add	x0, x0, x1, lsl #3
     238: f9400801     	ldr	x1, [x0, #0x10]
     23c: eb0102bf     	cmp	x21, x1
     240: 54002b62     	b.hs	0x7ac <___pl_fn_0+0x7ac>
     244: 8b150c03     	add	x3, x0, x21, lsl #3
     248: f940147a     	ldr	x26, [x3, #0x28]
     24c: f9400c00     	ldr	x0, [x0, #0x18]
     250: eb00003f     	cmp	x1, x0
     254: 540000a0     	b.eq	0x268 <___pl_fn_0+0x268>
     258: 14000155     	b	0x7ac <___pl_fn_0+0x7ac>
     25c: aa1c03e0     	mov	x0, x28
     260: f940181a     	ldr	x26, [x0, #0x30]
     264: 14000002     	b	0x26c <___pl_fn_0+0x26c>
     268: aa1c03e0     	mov	x0, x28
     26c: aa1c03e0     	mov	x0, x28
     270: f9402400     	ldr	x0, [x0, #0x48]
     274: d1000701     	sub	x1, x24, #0x1
     278: eb00003f     	cmp	x1, x0
     27c: 54002aa2     	b.hs	0x7d0 <___pl_fn_0+0x7d0>
     280: aa1c03e0     	mov	x0, x28
     284: f9402000     	ldr	x0, [x0, #0x40]
     288: d2800502     	mov	x2, #0x28               ; =40
     28c: d1000703     	sub	x3, x24, #0x1
     290: 9b027c61     	mul	x1, x3, x2
     294: 9b020062     	madd	x2, x3, x2, x0
     298: f9400442     	ldr	x2, [x2, #0x8]
     29c: b50000a2     	cbnz	x2, 0x2b0 <___pl_fn_0+0x2b0>
     2a0: 1400014c     	b	0x7d0 <___pl_fn_0+0x7d0>
     2a4: aa1c03e0     	mov	x0, x28
     2a8: f9401802     	ldr	x2, [x0, #0x30]
     2ac: 14000002     	b	0x2b4 <___pl_fn_0+0x2b4>
     2b0: f8616802     	ldr	x2, [x0, x1]
     2b4: eb1302c0     	subs	x0, x22, x19
     2b8: 9a9f77e1     	cset	x1, vs
     2bc: 72001c3f     	tst	w1, #0xff
     2c0: 54004041     	b.ne	0xac8 <___pl_fn_0+0xac8>
     2c4: 34002962     	cbz	w2, 0x7f0 <___pl_fn_0+0x7f0>
     2c8: aa1c03e1     	mov	x1, x28
     2cc: f9400023     	ldr	x3, [x1]
     2d0: 2a0203e1     	mov	w1, w2
     2d4: 8b010c61     	add	x1, x3, x1, lsl #3
     2d8: f9400824     	ldr	x4, [x1, #0x10]
     2dc: eb04001f     	cmp	x0, x4
     2e0: 54000083     	b.lo	0x2f0 <___pl_fn_0+0x2f0>
     2e4: 14000143     	b	0x7f0 <___pl_fn_0+0x7f0>
     2e8: aa1c03e0     	mov	x0, x28
     2ec: 14000017     	b	0x348 <___pl_fn_0+0x348>
     2f0: f9400c22     	ldr	x2, [x1, #0x18]
     2f4: eb02009f     	cmp	x4, x2
     2f8: 54000220     	b.eq	0x33c <___pl_fn_0+0x33c>
     2fc: f9401025     	ldr	x5, [x1, #0x20]
     300: d346fc06     	lsr	x6, x0, #6
     304: 8b0600a5     	add	x5, x5, x6
     308: f8657866     	ldr	x6, [x3, x5, lsl #3]
     30c: 92401407     	and	x7, x0, #0x3f
     310: 9ac72267     	lsl	x7, x19, x7
     314: 8a0700c8     	and	x8, x6, x7
     318: b5000128     	cbnz	x8, 0x33c <___pl_fn_0+0x33c>
     31c: aa0700c6     	orr	x6, x6, x7
     320: f8257866     	str	x6, [x3, x5, lsl #3]
     324: 91000442     	add	x2, x2, #0x1
     328: f9000c22     	str	x2, [x1, #0x18]
     32c: eb04005f     	cmp	x2, x4
     330: 54000061     	b.ne	0x33c <___pl_fn_0+0x33c>
     334: f84603e2     	ldur	x2, [sp, #0x60]
     338: f9001022     	str	x2, [x1, #0x20]
     33c: 8b000c22     	add	x2, x1, x0, lsl #3
     340: f900145a     	str	x26, [x2, #0x28]
     344: aa1c03e0     	mov	x0, x28
     348: aa1c03e0     	mov	x0, x28
     34c: f9402404     	ldr	x4, [x0, #0x48]
     350: d1000705     	sub	x5, x24, #0x1
     354: eb0400bf     	cmp	x5, x4
     358: 54002602     	b.hs	0x818 <___pl_fn_0+0x818>
     35c: aa1c03e0     	mov	x0, x28
     360: f9402007     	ldr	x7, [x0, #0x40]
     364: d2800509     	mov	x9, #0x28               ; =40
     368: d100070a     	sub	x10, x24, #0x1
     36c: 9b097d48     	mul	x8, x10, x9
     370: 9b091d49     	madd	x9, x10, x9, x7
     374: f9400529     	ldr	x9, [x9, #0x8]
     378: b50000a9     	cbnz	x9, 0x38c <___pl_fn_0+0x38c>
     37c: 14000127     	b	0x818 <___pl_fn_0+0x818>
     380: aa1c03e0     	mov	x0, x28
     384: f9401802     	ldr	x2, [x0, #0x30]
     388: 14000002     	b	0x390 <___pl_fn_0+0x390>
     38c: f86868e2     	ldr	x2, [x7, x8]
     390: 34002542     	cbz	w2, 0x838 <___pl_fn_0+0x838>
     394: aa1c03e0     	mov	x0, x28
     398: f9400000     	ldr	x0, [x0]
     39c: 2a0203ef     	mov	w15, w2
     3a0: 8b0f0c0f     	add	x15, x0, x15, lsl #3
     3a4: f94009e1     	ldr	x1, [x15, #0x10]
     3a8: eb0102bf     	cmp	x21, x1
     3ac: 54002462     	b.hs	0x838 <___pl_fn_0+0x838>
     3b0: f9400de2     	ldr	x2, [x15, #0x18]
     3b4: eb02003f     	cmp	x1, x2
     3b8: 54000220     	b.eq	0x3fc <___pl_fn_0+0x3fc>
     3bc: f94011e3     	ldr	x3, [x15, #0x20]
     3c0: d346fea4     	lsr	x4, x21, #6
     3c4: 8b040063     	add	x3, x3, x4
     3c8: f8637804     	ldr	x4, [x0, x3, lsl #3]
     3cc: 924016a5     	and	x5, x21, #0x3f
     3d0: 9ac52265     	lsl	x5, x19, x5
     3d4: 8a050086     	and	x6, x4, x5
     3d8: b5000126     	cbnz	x6, 0x3fc <___pl_fn_0+0x3fc>
     3dc: aa050084     	orr	x4, x4, x5
     3e0: f8237804     	str	x4, [x0, x3, lsl #3]
     3e4: 91000440     	add	x0, x2, #0x1
     3e8: f9000de0     	str	x0, [x15, #0x18]
     3ec: eb01001f     	cmp	x0, x1
     3f0: 54000061     	b.ne	0x3fc <___pl_fn_0+0x3fc>
     3f4: f84603e0     	ldur	x0, [sp, #0x60]
     3f8: f90011e0     	str	x0, [x15, #0x20]
     3fc: 8b150de0     	add	x0, x15, x21, lsl #3
     400: f9001419     	str	x25, [x0, #0x28]
     404: eb1302c2     	subs	x2, x22, x19
     408: 9a9f77e0     	cset	x0, vs
     40c: 72001c1f     	tst	w0, #0xff
     410: 54003401     	b.ne	0xa90 <___pl_fn_0+0xa90>
     414: aa1c03e0     	mov	x0, x28
     418: b9401000     	ldr	w0, [x0, #0x10]
     41c: aa1c03e1     	mov	x1, x28
     420: b9401421     	ldr	w1, [x1, #0x14]
     424: 6b01001f     	cmp	w0, w1
     428: 54003182     	b.hs	0xa58 <___pl_fn_0+0xa58>
     42c: aa1c03e0     	mov	x0, x28
     430: aa1403e1     	mov	x1, x20
     434: 94000000     	bl	0x434 <___pl_fn_0+0x434>
     438: aa1c03e1     	mov	x1, x28
     43c: b9402c21     	ldr	w1, [x1, #0x2c]
     440: 35003b41     	cbnz	w1, 0xba8 <___pl_fn_0+0xba8>
     444: aa1b03f9     	mov	x25, x27
     448: ab000339     	adds	x25, x25, x0
     44c: 9a9f77e0     	cset	x0, vs
     450: 72001c1f     	tst	w0, #0xff
     454: 54002e61     	b.ne	0xa20 <___pl_fn_0+0xa20>
     458: aa1c03e0     	mov	x0, x28
     45c: f9402400     	ldr	x0, [x0, #0x48]
     460: d1000701     	sub	x1, x24, #0x1
     464: eb00003f     	cmp	x1, x0
     468: 54001fc2     	b.hs	0x860 <___pl_fn_0+0x860>
     46c: aa1c03e0     	mov	x0, x28
     470: f9402000     	ldr	x0, [x0, #0x40]
     474: d2800502     	mov	x2, #0x28               ; =40
     478: d1000703     	sub	x3, x24, #0x1
     47c: 9b027c61     	mul	x1, x3, x2
     480: 9b020062     	madd	x2, x3, x2, x0
     484: f9400442     	ldr	x2, [x2, #0x8]
     488: b50000a2     	cbnz	x2, 0x49c <___pl_fn_0+0x49c>
     48c: 140000f5     	b	0x860 <___pl_fn_0+0x860>
     490: aa1c03e0     	mov	x0, x28
     494: f9401802     	ldr	x2, [x0, #0x30]
     498: 14000002     	b	0x4a0 <___pl_fn_0+0x4a0>
     49c: f8616802     	ldr	x2, [x0, x1]
     4a0: eb1302c0     	subs	x0, x22, x19
     4a4: 9a9f77e1     	cset	x1, vs
     4a8: 72001c3f     	tst	w1, #0xff
     4ac: 540029e1     	b.ne	0x9e8 <___pl_fn_0+0x9e8>
     4b0: 34001e82     	cbz	w2, 0x880 <___pl_fn_0+0x880>
     4b4: aa1c03e3     	mov	x3, x28
     4b8: f9400061     	ldr	x1, [x3]
     4bc: 2a0203e3     	mov	w3, w2
     4c0: 8b030c21     	add	x1, x1, x3, lsl #3
     4c4: f9400823     	ldr	x3, [x1, #0x10]
     4c8: eb03001f     	cmp	x0, x3
     4cc: 54001da2     	b.hs	0x880 <___pl_fn_0+0x880>
     4d0: 8b000c24     	add	x4, x1, x0, lsl #3
     4d4: f940149a     	ldr	x26, [x4, #0x28]
     4d8: f9400c21     	ldr	x1, [x1, #0x18]
     4dc: eb01007f     	cmp	x3, x1
     4e0: 540000a0     	b.eq	0x4f4 <___pl_fn_0+0x4f4>
     4e4: 140000e7     	b	0x880 <___pl_fn_0+0x880>
     4e8: aa1c03e0     	mov	x0, x28
     4ec: f940181a     	ldr	x26, [x0, #0x30]
     4f0: 14000002     	b	0x4f8 <___pl_fn_0+0x4f8>
     4f4: aa1c03e0     	mov	x0, x28
     4f8: aa1c03e0     	mov	x0, x28
     4fc: f9402406     	ldr	x6, [x0, #0x48]
     500: d1000707     	sub	x7, x24, #0x1
     504: eb0600ff     	cmp	x7, x6
     508: 54001ce2     	b.hs	0x8a4 <___pl_fn_0+0x8a4>
     50c: aa1c03e0     	mov	x0, x28
     510: f9402009     	ldr	x9, [x0, #0x40]
     514: d280050b     	mov	x11, #0x28              ; =40
     518: d100070c     	sub	x12, x24, #0x1
     51c: 9b0b7d8a     	mul	x10, x12, x11
     520: 9b0b258b     	madd	x11, x12, x11, x9
     524: f940056b     	ldr	x11, [x11, #0x8]
     528: b50000ab     	cbnz	x11, 0x53c <___pl_fn_0+0x53c>
     52c: 140000de     	b	0x8a4 <___pl_fn_0+0x8a4>
     530: aa1c03e0     	mov	x0, x28
     534: f9401802     	ldr	x2, [x0, #0x30]
     538: 14000002     	b	0x540 <___pl_fn_0+0x540>
     53c: f86a6922     	ldr	x2, [x9, x10]
     540: 34001c22     	cbz	w2, 0x8c4 <___pl_fn_0+0x8c4>
     544: aa1c03e0     	mov	x0, x28
     548: f9400000     	ldr	x0, [x0]
     54c: 2a0203e1     	mov	w1, w2
     550: 8b010c00     	add	x0, x0, x1, lsl #3
     554: f9400801     	ldr	x1, [x0, #0x10]
     558: eb0102bf     	cmp	x21, x1
     55c: 54001b42     	b.hs	0x8c4 <___pl_fn_0+0x8c4>
     560: 8b150c03     	add	x3, x0, x21, lsl #3
     564: f940147b     	ldr	x27, [x3, #0x28]
     568: f9400c00     	ldr	x0, [x0, #0x18]
     56c: eb00003f     	cmp	x1, x0
     570: 540000a0     	b.eq	0x584 <___pl_fn_0+0x584>
     574: 140000d4     	b	0x8c4 <___pl_fn_0+0x8c4>
     578: aa1c03e0     	mov	x0, x28
     57c: f940181b     	ldr	x27, [x0, #0x30]
     580: 14000002     	b	0x588 <___pl_fn_0+0x588>
     584: aa1c03e0     	mov	x0, x28
     588: aa1c03e0     	mov	x0, x28
     58c: f9402400     	ldr	x0, [x0, #0x48]
     590: d1000701     	sub	x1, x24, #0x1
     594: eb00003f     	cmp	x1, x0
     598: 54001a82     	b.hs	0x8e8 <___pl_fn_0+0x8e8>
     59c: aa1c03e0     	mov	x0, x28
     5a0: f9402000     	ldr	x0, [x0, #0x40]
     5a4: d2800502     	mov	x2, #0x28               ; =40
     5a8: d1000703     	sub	x3, x24, #0x1
     5ac: 9b027c61     	mul	x1, x3, x2
     5b0: 9b020062     	madd	x2, x3, x2, x0
     5b4: f9400442     	ldr	x2, [x2, #0x8]
     5b8: b50000a2     	cbnz	x2, 0x5cc <___pl_fn_0+0x5cc>
     5bc: 140000cb     	b	0x8e8 <___pl_fn_0+0x8e8>
     5c0: aa1c03e0     	mov	x0, x28
     5c4: f9401802     	ldr	x2, [x0, #0x30]
     5c8: 14000002     	b	0x5d0 <___pl_fn_0+0x5d0>
     5cc: f8616802     	ldr	x2, [x0, x1]
     5d0: eb1302c0     	subs	x0, x22, x19
     5d4: 9a9f77e1     	cset	x1, vs
     5d8: 72001c3f     	tst	w1, #0xff
     5dc: 54001ea1     	b.ne	0x9b0 <___pl_fn_0+0x9b0>
     5e0: 34001942     	cbz	w2, 0x908 <___pl_fn_0+0x908>
     5e4: aa1c03e1     	mov	x1, x28
     5e8: f9400023     	ldr	x3, [x1]
     5ec: 2a0203e1     	mov	w1, w2
     5f0: 8b010c61     	add	x1, x3, x1, lsl #3
     5f4: f9400824     	ldr	x4, [x1, #0x10]
     5f8: eb04001f     	cmp	x0, x4
     5fc: 54000083     	b.lo	0x60c <___pl_fn_0+0x60c>
     600: 140000c2     	b	0x908 <___pl_fn_0+0x908>
     604: aa1c03e0     	mov	x0, x28
     608: 14000017     	b	0x664 <___pl_fn_0+0x664>
     60c: f9400c22     	ldr	x2, [x1, #0x18]
     610: eb02009f     	cmp	x4, x2
     614: 54000220     	b.eq	0x658 <___pl_fn_0+0x658>
     618: f9401025     	ldr	x5, [x1, #0x20]
     61c: d346fc06     	lsr	x6, x0, #6
     620: 8b0600a5     	add	x5, x5, x6
     624: f8657866     	ldr	x6, [x3, x5, lsl #3]
     628: 92401407     	and	x7, x0, #0x3f
     62c: 9ac72267     	lsl	x7, x19, x7
     630: 8a0700c8     	and	x8, x6, x7
     634: b5000128     	cbnz	x8, 0x658 <___pl_fn_0+0x658>
     638: aa0700c6     	orr	x6, x6, x7
     63c: f8257866     	str	x6, [x3, x5, lsl #3]
     640: 91000442     	add	x2, x2, #0x1
     644: f9000c22     	str	x2, [x1, #0x18]
     648: eb04005f     	cmp	x2, x4
     64c: 54000061     	b.ne	0x658 <___pl_fn_0+0x658>
     650: f84603e2     	ldur	x2, [sp, #0x60]
     654: f9001022     	str	x2, [x1, #0x20]
     658: 8b000c20     	add	x0, x1, x0, lsl #3
     65c: f900141b     	str	x27, [x0, #0x28]
     660: aa1c03e0     	mov	x0, x28
     664: aa1c03e0     	mov	x0, x28
     668: f9402400     	ldr	x0, [x0, #0x48]
     66c: d1000701     	sub	x1, x24, #0x1
     670: eb00003f     	cmp	x1, x0
     674: 540015e2     	b.hs	0x930 <___pl_fn_0+0x930>
     678: aa1c03e0     	mov	x0, x28
     67c: f9402003     	ldr	x3, [x0, #0x40]
     680: d2800505     	mov	x5, #0x28               ; =40
     684: d1000706     	sub	x6, x24, #0x1
     688: 9b057cc4     	mul	x4, x6, x5
     68c: 9b050cc5     	madd	x5, x6, x5, x3
     690: f94004a5     	ldr	x5, [x5, #0x8]
     694: b50000a5     	cbnz	x5, 0x6a8 <___pl_fn_0+0x6a8>
     698: 140000a6     	b	0x930 <___pl_fn_0+0x930>
     69c: aa1c03e0     	mov	x0, x28
     6a0: f9401802     	ldr	x2, [x0, #0x30]
     6a4: 14000002     	b	0x6ac <___pl_fn_0+0x6ac>
     6a8: f8646862     	ldr	x2, [x3, x4]
     6ac: 34001522     	cbz	w2, 0x950 <___pl_fn_0+0x950>
     6b0: aa1c03e0     	mov	x0, x28
     6b4: f940000c     	ldr	x12, [x0]
     6b8: 2a0203eb     	mov	w11, w2
     6bc: 8b0b0d8b     	add	x11, x12, x11, lsl #3
     6c0: f940096d     	ldr	x13, [x11, #0x10]
     6c4: eb0d02bf     	cmp	x21, x13
     6c8: 54001442     	b.hs	0x950 <___pl_fn_0+0x950>
     6cc: f9400d60     	ldr	x0, [x11, #0x18]
     6d0: eb0001bf     	cmp	x13, x0
     6d4: 54000220     	b.eq	0x718 <___pl_fn_0+0x718>
     6d8: f9401161     	ldr	x1, [x11, #0x20]
     6dc: d346fea2     	lsr	x2, x21, #6
     6e0: 8b020021     	add	x1, x1, x2
     6e4: f8617982     	ldr	x2, [x12, x1, lsl #3]
     6e8: 924016a3     	and	x3, x21, #0x3f
     6ec: 9ac32263     	lsl	x3, x19, x3
     6f0: 8a030044     	and	x4, x2, x3
     6f4: b5000124     	cbnz	x4, 0x718 <___pl_fn_0+0x718>
     6f8: aa030042     	orr	x2, x2, x3
     6fc: f8217982     	str	x2, [x12, x1, lsl #3]
     700: 91000400     	add	x0, x0, #0x1
     704: f9000d60     	str	x0, [x11, #0x18]
     708: eb0d001f     	cmp	x0, x13
     70c: 54000061     	b.ne	0x718 <___pl_fn_0+0x718>
     710: f84603e0     	ldur	x0, [sp, #0x60]
     714: f9001160     	str	x0, [x11, #0x20]
     718: 8b150d60     	add	x0, x11, x21, lsl #3
     71c: f900141a     	str	x26, [x0, #0x28]
     720: 92800000     	mov	x0, #-0x1               ; =-1
     724: ab0002b5     	adds	x21, x21, x0
     728: 9a9f77e0     	cset	x0, vs
     72c: 72001c1f     	tst	w0, #0xff
     730: 54001241     	b.ne	0x978 <___pl_fn_0+0x978>
     734: aa1703e0     	mov	x0, x23
     738: aa1703e1     	mov	x1, x23
     73c: aa1703e2     	mov	x2, x23
     740: aa1903fb     	mov	x27, x25
     744: 17fffe6a     	b	0xec <___pl_fn_0+0xec>
     748: 528000a1     	mov	w1, #0x5                ; =5
     74c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     750: f9400063     	ldr	x3, [x3]
     754: aa1c03e0     	mov	x0, x28
     758: aa1403e2     	mov	x2, x20
     75c: d63f0060     	blr	x3
     760: 34ffd0a0     	cbz	w0, 0x174 <___pl_fn_0+0x174>
     764: 14000111     	b	0xba8 <___pl_fn_0+0xba8>
     768: 910003e3     	mov	x3, sp
     76c: f80003e0     	stur	x0, [sp]
     770: 528000e1     	mov	w1, #0x7                ; =7
     774: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     778: f94000c6     	ldr	x6, [x6]
     77c: aa1c03e0     	mov	x0, x28
     780: d63f00c0     	blr	x6
     784: 34ffd240     	cbz	w0, 0x1cc <___pl_fn_0+0x1cc>
     788: 14000108     	b	0xba8 <___pl_fn_0+0xba8>
     78c: 52800101     	mov	w1, #0x8                ; =8
     790: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     794: f94001ef     	ldr	x15, [x15]
     798: aa1c03e0     	mov	x0, x28
     79c: aa1403e2     	mov	x2, x20
     7a0: d63f01e0     	blr	x15
     7a4: 34ffd380     	cbz	w0, 0x214 <___pl_fn_0+0x214>
     7a8: 14000100     	b	0xba8 <___pl_fn_0+0xba8>
     7ac: 910023e3     	add	x3, sp, #0x8
     7b0: f80083f5     	stur	x21, [sp, #0x8]
     7b4: 52800121     	mov	w1, #0x9                ; =9
     7b8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     7bc: f9400084     	ldr	x4, [x4]
     7c0: aa1c03e0     	mov	x0, x28
     7c4: d63f0080     	blr	x4
     7c8: 34ffd4a0     	cbz	w0, 0x25c <___pl_fn_0+0x25c>
     7cc: 140000f7     	b	0xba8 <___pl_fn_0+0xba8>
     7d0: 52800141     	mov	w1, #0xa                ; =10
     7d4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     7d8: f9400063     	ldr	x3, [x3]
     7dc: aa1c03e0     	mov	x0, x28
     7e0: aa1403e2     	mov	x2, x20
     7e4: d63f0060     	blr	x3
     7e8: 34ffd5e0     	cbz	w0, 0x2a4 <___pl_fn_0+0x2a4>
     7ec: 140000ef     	b	0xba8 <___pl_fn_0+0xba8>
     7f0: 910043e3     	add	x3, sp, #0x10
     7f4: f80103e0     	stur	x0, [sp, #0x10]
     7f8: f80183fa     	stur	x26, [sp, #0x18]
     7fc: 52800181     	mov	w1, #0xc                ; =12
     800: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     804: f9400084     	ldr	x4, [x4]
     808: aa1c03e0     	mov	x0, x28
     80c: d63f0080     	blr	x4
     810: 34ffd6c0     	cbz	w0, 0x2e8 <___pl_fn_0+0x2e8>
     814: 140000e5     	b	0xba8 <___pl_fn_0+0xba8>
     818: 528001a1     	mov	w1, #0xd                ; =13
     81c: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     820: f9400129     	ldr	x9, [x9]
     824: aa1c03e0     	mov	x0, x28
     828: aa1403e2     	mov	x2, x20
     82c: d63f0120     	blr	x9
     830: 34ffda80     	cbz	w0, 0x380 <___pl_fn_0+0x380>
     834: 140000dd     	b	0xba8 <___pl_fn_0+0xba8>
     838: 910083e3     	add	x3, sp, #0x20
     83c: f80203f5     	stur	x21, [sp, #0x20]
     840: f80283f9     	stur	x25, [sp, #0x28]
     844: 528001c1     	mov	w1, #0xe                ; =14
     848: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     84c: f9400084     	ldr	x4, [x4]
     850: aa1c03e0     	mov	x0, x28
     854: d63f0080     	blr	x4
     858: 34ffdd60     	cbz	w0, 0x404 <___pl_fn_0+0x404>
     85c: 140000d3     	b	0xba8 <___pl_fn_0+0xba8>
     860: 52800241     	mov	w1, #0x12               ; =18
     864: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     868: f9400063     	ldr	x3, [x3]
     86c: aa1c03e0     	mov	x0, x28
     870: aa1403e2     	mov	x2, x20
     874: d63f0060     	blr	x3
     878: 34ffe0c0     	cbz	w0, 0x490 <___pl_fn_0+0x490>
     87c: 140000cb     	b	0xba8 <___pl_fn_0+0xba8>
     880: 9100c3e3     	add	x3, sp, #0x30
     884: f80303e0     	stur	x0, [sp, #0x30]
     888: 52800281     	mov	w1, #0x14               ; =20
     88c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     890: f9400084     	ldr	x4, [x4]
     894: aa1c03e0     	mov	x0, x28
     898: d63f0080     	blr	x4
     89c: 34ffe260     	cbz	w0, 0x4e8 <___pl_fn_0+0x4e8>
     8a0: 140000c2     	b	0xba8 <___pl_fn_0+0xba8>
     8a4: 528002a1     	mov	w1, #0x15               ; =21
     8a8: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     8ac: f940016b     	ldr	x11, [x11]
     8b0: aa1c03e0     	mov	x0, x28
     8b4: aa1403e2     	mov	x2, x20
     8b8: d63f0160     	blr	x11
     8bc: 34ffe3a0     	cbz	w0, 0x530 <___pl_fn_0+0x530>
     8c0: 140000ba     	b	0xba8 <___pl_fn_0+0xba8>
     8c4: 9100e3e3     	add	x3, sp, #0x38
     8c8: f80383f5     	stur	x21, [sp, #0x38]
     8cc: 528002c1     	mov	w1, #0x16               ; =22
     8d0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     8d4: f9400084     	ldr	x4, [x4]
     8d8: aa1c03e0     	mov	x0, x28
     8dc: d63f0080     	blr	x4
     8e0: 34ffe4c0     	cbz	w0, 0x578 <___pl_fn_0+0x578>
     8e4: 140000b1     	b	0xba8 <___pl_fn_0+0xba8>
     8e8: 528002e1     	mov	w1, #0x17               ; =23
     8ec: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     8f0: f9400063     	ldr	x3, [x3]
     8f4: aa1c03e0     	mov	x0, x28
     8f8: aa1403e2     	mov	x2, x20
     8fc: d63f0060     	blr	x3
     900: 34ffe600     	cbz	w0, 0x5c0 <___pl_fn_0+0x5c0>
     904: 140000a9     	b	0xba8 <___pl_fn_0+0xba8>
     908: 910103e3     	add	x3, sp, #0x40
     90c: f80403e0     	stur	x0, [sp, #0x40]
     910: f80483fb     	stur	x27, [sp, #0x48]
     914: 52800321     	mov	w1, #0x19               ; =25
     918: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     91c: f9400084     	ldr	x4, [x4]
     920: aa1c03e0     	mov	x0, x28
     924: d63f0080     	blr	x4
     928: 34ffe6e0     	cbz	w0, 0x604 <___pl_fn_0+0x604>
     92c: 1400009f     	b	0xba8 <___pl_fn_0+0xba8>
     930: 52800341     	mov	w1, #0x1a               ; =26
     934: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     938: f94000a5     	ldr	x5, [x5]
     93c: aa1c03e0     	mov	x0, x28
     940: aa1403e2     	mov	x2, x20
     944: d63f00a0     	blr	x5
     948: 34ffeaa0     	cbz	w0, 0x69c <___pl_fn_0+0x69c>
     94c: 14000097     	b	0xba8 <___pl_fn_0+0xba8>
     950: 910143e3     	add	x3, sp, #0x50
     954: f80503f5     	stur	x21, [sp, #0x50]
     958: f80583fa     	stur	x26, [sp, #0x58]
     95c: 52800361     	mov	w1, #0x1b               ; =27
     960: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     964: f9400084     	ldr	x4, [x4]
     968: aa1c03e0     	mov	x0, x28
     96c: d63f0080     	blr	x4
     970: 34ffed80     	cbz	w0, 0x720 <___pl_fn_0+0x720>
     974: 1400008d     	b	0xba8 <___pl_fn_0+0xba8>
     978: 52800381     	mov	w1, #0x1c               ; =28
     97c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     980: f9400042     	ldr	x2, [x2]
     984: aa1c03e0     	mov	x0, x28
     988: d63f0040     	blr	x2
     98c: f84603e0     	ldur	x0, [sp, #0x60]
     990: 9101c3ff     	add	sp, sp, #0x70
     994: a8c153f3     	ldp	x19, x20, [sp], #0x10
     998: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     99c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9a0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9a4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9a8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9ac: d65f03c0     	ret
     9b0: 52800301     	mov	w1, #0x18               ; =24
     9b4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9b8: f9400042     	ldr	x2, [x2]
     9bc: aa1c03e0     	mov	x0, x28
     9c0: d63f0040     	blr	x2
     9c4: f84603e0     	ldur	x0, [sp, #0x60]
     9c8: 9101c3ff     	add	sp, sp, #0x70
     9cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9d4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9d8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9dc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9e4: d65f03c0     	ret
     9e8: 52800261     	mov	w1, #0x13               ; =19
     9ec: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9f0: f9400042     	ldr	x2, [x2]
     9f4: aa1c03e0     	mov	x0, x28
     9f8: d63f0040     	blr	x2
     9fc: f84603e0     	ldur	x0, [sp, #0x60]
     a00: 9101c3ff     	add	sp, sp, #0x70
     a04: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a08: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a0c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a10: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a14: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a18: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a1c: d65f03c0     	ret
     a20: 52800221     	mov	w1, #0x11               ; =17
     a24: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a28: f9400042     	ldr	x2, [x2]
     a2c: aa1c03e0     	mov	x0, x28
     a30: d63f0040     	blr	x2
     a34: f84603e0     	ldur	x0, [sp, #0x60]
     a38: 9101c3ff     	add	sp, sp, #0x70
     a3c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a40: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a44: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a48: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a4c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a50: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a54: d65f03c0     	ret
     a58: 52800201     	mov	w1, #0x10               ; =16
     a5c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a60: f9400042     	ldr	x2, [x2]
     a64: aa1c03e0     	mov	x0, x28
     a68: d63f0040     	blr	x2
     a6c: f84603e0     	ldur	x0, [sp, #0x60]
     a70: 9101c3ff     	add	sp, sp, #0x70
     a74: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a78: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a7c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a80: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a84: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a88: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a8c: d65f03c0     	ret
     a90: 528001e1     	mov	w1, #0xf                ; =15
     a94: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a98: f9400042     	ldr	x2, [x2]
     a9c: aa1c03e0     	mov	x0, x28
     aa0: d63f0040     	blr	x2
     aa4: f84603e0     	ldur	x0, [sp, #0x60]
     aa8: 9101c3ff     	add	sp, sp, #0x70
     aac: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ab0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ab4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ab8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     abc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ac0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ac4: d65f03c0     	ret
     ac8: 52800161     	mov	w1, #0xb                ; =11
     acc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     ad0: f9400042     	ldr	x2, [x2]
     ad4: aa1c03e0     	mov	x0, x28
     ad8: d63f0040     	blr	x2
     adc: f84603e0     	ldur	x0, [sp, #0x60]
     ae0: 9101c3ff     	add	sp, sp, #0x70
     ae4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ae8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     aec: a8c163f7     	ldp	x23, x24, [sp], #0x10
     af0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     af4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     af8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     afc: d65f03c0     	ret
     b00: 528000c1     	mov	w1, #0x6                ; =6
     b04: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b08: f9400042     	ldr	x2, [x2]
     b0c: aa1c03e0     	mov	x0, x28
     b10: d63f0040     	blr	x2
     b14: f84603e0     	ldur	x0, [sp, #0x60]
     b18: 9101c3ff     	add	sp, sp, #0x70
     b1c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b20: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b24: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b28: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b2c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b34: d65f03c0     	ret
     b38: 52800061     	mov	w1, #0x3                ; =3
     b3c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b40: f9400042     	ldr	x2, [x2]
     b44: aa1c03e0     	mov	x0, x28
     b48: d63f0040     	blr	x2
     b4c: d2800000     	mov	x0, #0x0                ; =0
     b50: 9101c3ff     	add	sp, sp, #0x70
     b54: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b58: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b5c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b60: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b64: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b68: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b6c: d65f03c0     	ret
     b70: 52800041     	mov	w1, #0x2                ; =2
     b74: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b78: f9400042     	ldr	x2, [x2]
     b7c: aa1c03e0     	mov	x0, x28
     b80: d63f0040     	blr	x2
     b84: d2800000     	mov	x0, #0x0                ; =0
     b88: 9101c3ff     	add	sp, sp, #0x70
     b8c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b90: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b94: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b98: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b9c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ba0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ba4: d65f03c0     	ret
     ba8: d2800000     	mov	x0, #0x0                ; =0
     bac: 9101c3ff     	add	sp, sp, #0x70
     bb0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     bb4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     bb8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     bbc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     bc0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     bc4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     bc8: d65f03c0     	ret
     bcc: 52800021     	mov	w1, #0x1                ; =1
     bd0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     bd4: f9400042     	ldr	x2, [x2]
     bd8: aa1c03e0     	mov	x0, x28
     bdc: d63f0040     	blr	x2
     be0: d2800000     	mov	x0, #0x0                ; =0
     be4: 9101c3ff     	add	sp, sp, #0x70
     be8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     bec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     bf0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     bf4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     bf8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     bfc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c00: d65f03c0     	ret
     c04: aa0003fc     	mov	x28, x0
     c08: 52800001     	mov	w1, #0x0                ; =0
     c0c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c10: f9400042     	ldr	x2, [x2]
     c14: d63f0040     	blr	x2
     c18: d2800000     	mov	x0, #0x0                ; =0
     c1c: 9101c3ff     	add	sp, sp, #0x70
     c20: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c24: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c28: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c2c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c30: a8c173fb     	ldp	x27, x28, [sp], #0x10
     c34: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c38: d65f03c0     	ret

0000000000000c3c <___pl_fn_1>:
     c3c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     c40: 910003fd     	mov	x29, sp
     c44: f81f0ff7     	str	x23, [sp, #-0x10]!
     c48: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     c4c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     c50: d10083ff     	sub	sp, sp, #0x20
     c54: b9401001     	ldr	w1, [x0, #0x10]
     c58: 11000421     	add	w1, w1, #0x1
     c5c: b9001001     	str	w1, [x0, #0x10]
     c60: aa0003f5     	mov	x21, x0
     c64: 528003a1     	mov	w1, #0x1d               ; =29
     c68: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c6c: f9400042     	ldr	x2, [x2]
     c70: d63f0040     	blr	x2
     c74: 35001720     	cbnz	w0, 0xf58 <___pl_fn_1+0x31c>
     c78: aa1503e0     	mov	x0, x21
     c7c: f9401802     	ldr	x2, [x0, #0x30]
     c80: aa0203f6     	mov	x22, x2
     c84: d2800140     	mov	x0, #0xa                ; =10
     c88: 910003e3     	mov	x3, sp
     c8c: f80003e0     	stur	x0, [sp]
     c90: 528003c1     	mov	w1, #0x1e               ; =30
     c94: 52802002     	mov	w2, #0x100              ; =256
     c98: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c9c: f9400084     	ldr	x4, [x4]
     ca0: aa1503e0     	mov	x0, x21
     ca4: d63f0080     	blr	x4
     ca8: 35001580     	cbnz	w0, 0xf58 <___pl_fn_1+0x31c>
     cac: aa1503e0     	mov	x0, x21
     cb0: f9401813     	ldr	x19, [x0, #0x30]
     cb4: 528003e1     	mov	w1, #0x1f               ; =31
     cb8: 52800082     	mov	w2, #0x4                ; =4
     cbc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     cc0: f9400063     	ldr	x3, [x3]
     cc4: d63f0060     	blr	x3
     cc8: 35001480     	cbnz	w0, 0xf58 <___pl_fn_1+0x31c>
     ccc: aa1503e0     	mov	x0, x21
     cd0: f9401814     	ldr	x20, [x0, #0x30]
     cd4: 52800401     	mov	w1, #0x20               ; =32
     cd8: 2a1303e3     	mov	w3, w19
     cdc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     ce0: f9400084     	ldr	x4, [x4]
     ce4: aa1403e2     	mov	x2, x20
     ce8: d63f0080     	blr	x4
     cec: 35001360     	cbnz	w0, 0xf58 <___pl_fn_1+0x31c>
     cf0: 52800421     	mov	w1, #0x21               ; =33
     cf4: 52800002     	mov	w2, #0x0                ; =0
     cf8: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     cfc: f9400063     	ldr	x3, [x3]
     d00: aa1503e0     	mov	x0, x21
     d04: d63f0060     	blr	x3
     d08: 35001280     	cbnz	w0, 0xf58 <___pl_fn_1+0x31c>
     d0c: aa1503e0     	mov	x0, x21
     d10: f9401802     	ldr	x2, [x0, #0x30]
     d14: aa0203f7     	mov	x23, x2
     d18: d2800013     	mov	x19, #0x0               ; =0
     d1c: 52800020     	mov	w0, #0x1                ; =1
     d20: f100267f     	cmp	x19, #0x9
     d24: 9a9fc7e0     	cset	x0, le
     d28: 72001c1f     	tst	w0, #0xff
     d2c: 54000501     	b.ne	0xdcc <___pl_fn_1+0x190>
     d30: aa1503e0     	mov	x0, x21
     d34: b9401000     	ldr	w0, [x0, #0x10]
     d38: aa1503e1     	mov	x1, x21
     d3c: b9401421     	ldr	w1, [x1, #0x14]
     d40: 6b01001f     	cmp	w0, w1
     d44: 54000b82     	b.hs	0xeb4 <___pl_fn_1+0x278>
     d48: aa1403e1     	mov	x1, x20
     d4c: aa1703e2     	mov	x2, x23
     d50: aa1503e0     	mov	x0, x21
     d54: 94000000     	bl	0xd54 <___pl_fn_1+0x118>
     d58: aa0003e2     	mov	x2, x0
     d5c: aa1503e0     	mov	x0, x21
     d60: b9402c00     	ldr	w0, [x0, #0x2c]
     d64: 35000fa0     	cbnz	w0, 0xf58 <___pl_fn_1+0x31c>
     d68: 52800481     	mov	w1, #0x24               ; =36
     d6c: 52802003     	mov	w3, #0x100              ; =256
     d70: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     d74: f9400084     	ldr	x4, [x4]
     d78: aa1503e0     	mov	x0, x21
     d7c: d63f0080     	blr	x4
     d80: 35000ec0     	cbnz	w0, 0xf58 <___pl_fn_1+0x31c>
     d84: 528004a1     	mov	w1, #0x25               ; =37
     d88: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     d8c: f9400063     	ldr	x3, [x3]
     d90: aa1603e2     	mov	x2, x22
     d94: aa1503e0     	mov	x0, x21
     d98: d63f0060     	blr	x3
     d9c: 35000de0     	cbnz	w0, 0xf58 <___pl_fn_1+0x31c>
     da0: aa1503e0     	mov	x0, x21
     da4: b9401000     	ldr	w0, [x0, #0x10]
     da8: 51000400     	sub	w0, w0, #0x1
     dac: aa1503e1     	mov	x1, x21
     db0: b9001020     	str	w0, [x1, #0x10]
     db4: 910083ff     	add	sp, sp, #0x20
     db8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     dbc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     dc0: f84107f7     	ldr	x23, [sp], #0x10
     dc4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     dc8: d65f03c0     	ret
     dcc: aa1503e0     	mov	x0, x21
     dd0: f9402401     	ldr	x1, [x0, #0x48]
     dd4: aa1403ed     	mov	x13, x20
     dd8: 2a0d03e0     	mov	w0, w13
     ddc: d1000402     	sub	x2, x0, #0x1
     de0: eb01005f     	cmp	x2, x1
     de4: 540007e2     	b.hs	0xee0 <___pl_fn_1+0x2a4>
     de8: aa1503e4     	mov	x4, x21
     dec: f9402083     	ldr	x3, [x4, #0x40]
     df0: d2800505     	mov	x5, #0x28               ; =40
     df4: d1000406     	sub	x6, x0, #0x1
     df8: 9b057cc4     	mul	x4, x6, x5
     dfc: 9b050cc5     	madd	x5, x6, x5, x3
     e00: f94004a5     	ldr	x5, [x5, #0x8]
     e04: b50000a5     	cbnz	x5, 0xe18 <___pl_fn_1+0x1dc>
     e08: 14000036     	b	0xee0 <___pl_fn_1+0x2a4>
     e0c: aa1503e0     	mov	x0, x21
     e10: f9401802     	ldr	x2, [x0, #0x30]
     e14: 14000002     	b	0xe1c <___pl_fn_1+0x1e0>
     e18: f8646862     	ldr	x2, [x3, x4]
     e1c: 34000722     	cbz	w2, 0xf00 <___pl_fn_1+0x2c4>
     e20: aa1503e0     	mov	x0, x21
     e24: f940000c     	ldr	x12, [x0]
     e28: 2a0203eb     	mov	w11, w2
     e2c: 8b0b0d8b     	add	x11, x12, x11, lsl #3
     e30: f940096d     	ldr	x13, [x11, #0x10]
     e34: eb0d027f     	cmp	x19, x13
     e38: 54000642     	b.hs	0xf00 <___pl_fn_1+0x2c4>
     e3c: f9400d60     	ldr	x0, [x11, #0x18]
     e40: eb0001bf     	cmp	x13, x0
     e44: 54000240     	b.eq	0xe8c <___pl_fn_1+0x250>
     e48: f9401161     	ldr	x1, [x11, #0x20]
     e4c: d346fe62     	lsr	x2, x19, #6
     e50: 8b020021     	add	x1, x1, x2
     e54: f8617982     	ldr	x2, [x12, x1, lsl #3]
     e58: d2800023     	mov	x3, #0x1                ; =1
     e5c: 92401664     	and	x4, x19, #0x3f
     e60: 9ac42063     	lsl	x3, x3, x4
     e64: 8a030044     	and	x4, x2, x3
     e68: b5000124     	cbnz	x4, 0xe8c <___pl_fn_1+0x250>
     e6c: aa030042     	orr	x2, x2, x3
     e70: f8217982     	str	x2, [x12, x1, lsl #3]
     e74: 91000400     	add	x0, x0, #0x1
     e78: f9000d60     	str	x0, [x11, #0x18]
     e7c: eb0d001f     	cmp	x0, x13
     e80: 54000061     	b.ne	0xe8c <___pl_fn_1+0x250>
     e84: d2800000     	mov	x0, #0x0                ; =0
     e88: f9001160     	str	x0, [x11, #0x20]
     e8c: d2800000     	mov	x0, #0x0                ; =0
     e90: 8b130d61     	add	x1, x11, x19, lsl #3
     e94: f9001420     	str	x0, [x1, #0x28]
     e98: d2800020     	mov	x0, #0x1                ; =1
     e9c: ab000273     	adds	x19, x19, x0
     ea0: 9a9f77e0     	cset	x0, vs
     ea4: 72001c1f     	tst	w0, #0xff
     ea8: 54000421     	b.ne	0xf2c <___pl_fn_1+0x2f0>
     eac: 52800020     	mov	w0, #0x1                ; =1
     eb0: 17ffff9c     	b	0xd20 <___pl_fn_1+0xe4>
     eb4: 52800461     	mov	w1, #0x23               ; =35
     eb8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     ebc: f9400042     	ldr	x2, [x2]
     ec0: aa1503e0     	mov	x0, x21
     ec4: d63f0040     	blr	x2
     ec8: 910083ff     	add	sp, sp, #0x20
     ecc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ed0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ed4: f84107f7     	ldr	x23, [sp], #0x10
     ed8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     edc: d65f03c0     	ret
     ee0: 528004c1     	mov	w1, #0x26               ; =38
     ee4: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     ee8: f94000a5     	ldr	x5, [x5]
     eec: aa1503e0     	mov	x0, x21
     ef0: aa1403e2     	mov	x2, x20
     ef4: d63f00a0     	blr	x5
     ef8: 34fff8a0     	cbz	w0, 0xe0c <___pl_fn_1+0x1d0>
     efc: 14000017     	b	0xf58 <___pl_fn_1+0x31c>
     f00: 910023e3     	add	x3, sp, #0x8
     f04: f80083f3     	stur	x19, [sp, #0x8]
     f08: d280000f     	mov	x15, #0x0               ; =0
     f0c: f80103ef     	stur	x15, [sp, #0x10]
     f10: 528004e1     	mov	w1, #0x27               ; =39
     f14: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     f18: f9400084     	ldr	x4, [x4]
     f1c: aa1503e0     	mov	x0, x21
     f20: d63f0080     	blr	x4
     f24: 34fffba0     	cbz	w0, 0xe98 <___pl_fn_1+0x25c>
     f28: 1400000c     	b	0xf58 <___pl_fn_1+0x31c>
     f2c: 52800501     	mov	w1, #0x28               ; =40
     f30: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     f34: f9400042     	ldr	x2, [x2]
     f38: aa1503e0     	mov	x0, x21
     f3c: d63f0040     	blr	x2
     f40: 910083ff     	add	sp, sp, #0x20
     f44: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f48: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     f4c: f84107f7     	ldr	x23, [sp], #0x10
     f50: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f54: d65f03c0     	ret
     f58: 910083ff     	add	sp, sp, #0x20
     f5c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f60: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     f64: f84107f7     	ldr	x23, [sp], #0x10
     f68: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f6c: d65f03c0     	ret
