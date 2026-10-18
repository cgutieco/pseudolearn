
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_94328/queens/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
       c: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
      10: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      14: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      18: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      1c: d10243ff     	sub	sp, sp, #0x90
      20: aa0403f5     	mov	x21, x4
      24: aa0503f3     	mov	x19, x5
      28: aa0303e5     	mov	x5, x3
      2c: b9401003     	ldr	w3, [x0, #0x10]
      30: 11000464     	add	w4, w3, #0x1
      34: b9001004     	str	w4, [x0, #0x10]
      38: f80783e0     	stur	x0, [sp, #0x78]
      3c: eb02003f     	cmp	x1, x2
      40: aa0103f6     	mov	x22, x1
      44: 540034a0     	b.eq	0x6d8 <___pl_fn_0+0x6d8>
      48: d2800020     	mov	x0, #0x1                ; =1
      4c: eb000054     	subs	x20, x2, x0
      50: aa0203f9     	mov	x25, x2
      54: f80883f4     	stur	x20, [sp, #0x88]
      58: 9a9f77e0     	cset	x0, vs
      5c: 72001c1f     	tst	w0, #0xff
      60: 54006701     	b.ne	0xd40 <___pl_fn_0+0xd40>
      64: d2800014     	mov	x20, #0x0               ; =0
      68: 52800020     	mov	w0, #0x1                ; =1
      6c: aa0003fb     	mov	x27, x0
      70: f80803f4     	stur	x20, [sp, #0x80]
      74: f84883e0     	ldur	x0, [sp, #0x88]
      78: eb00029f     	cmp	x20, x0
      7c: 9a9fc7e0     	cset	x0, le
      80: 72001c1f     	tst	w0, #0xff
      84: 540001c1     	b.ne	0xbc <___pl_fn_0+0xbc>
      88: f84783e0     	ldur	x0, [sp, #0x78]
      8c: b9401002     	ldr	w2, [x0, #0x10]
      90: 51000442     	sub	w2, w2, #0x1
      94: b9001002     	str	w2, [x0, #0x10]
      98: f84803e0     	ldur	x0, [sp, #0x80]
      9c: 910243ff     	add	sp, sp, #0x90
      a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
      a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
      a8: a8c163f7     	ldp	x23, x24, [sp], #0x10
      ac: a8c16bf9     	ldp	x25, x26, [sp], #0x10
      b0: a8c173fb     	ldp	x27, x28, [sp], #0x10
      b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      b8: d65f03c0     	ret
      bc: f84783e0     	ldur	x0, [sp, #0x78]
      c0: f9402404     	ldr	x4, [x0, #0x48]
      c4: aa0503f7     	mov	x23, x5
      c8: 2a1703fa     	mov	w26, w23
      cc: d1000745     	sub	x5, x26, #0x1
      d0: eb0400bf     	cmp	x5, x4
      d4: 54003182     	b.hs	0x704 <___pl_fn_0+0x704>
      d8: f9402007     	ldr	x7, [x0, #0x40]
      dc: f80783e0     	stur	x0, [sp, #0x78]
      e0: d2800609     	mov	x9, #0x30               ; =48
      e4: d100074a     	sub	x10, x26, #0x1
      e8: 9b097d48     	mul	x8, x10, x9
      ec: 9b091d49     	madd	x9, x10, x9, x7
      f0: f9400529     	ldr	x9, [x9, #0x8]
      f4: b50000a9     	cbnz	x9, 0x108 <___pl_fn_0+0x108>
      f8: 14000184     	b	0x708 <___pl_fn_0+0x708>
      fc: f84783e0     	ldur	x0, [sp, #0x78]
     100: f9401802     	ldr	x2, [x0, #0x30]
     104: 14000002     	b	0x10c <___pl_fn_0+0x10c>
     108: f86868e2     	ldr	x2, [x7, x8]
     10c: 340030e2     	cbz	w2, 0x728 <___pl_fn_0+0x728>
     110: f84783e0     	ldur	x0, [sp, #0x78]
     114: f940000f     	ldr	x15, [x0]
     118: 2a0203e0     	mov	w0, w2
     11c: 8b000def     	add	x15, x15, x0, lsl #3
     120: f94009e0     	ldr	x0, [x15, #0x10]
     124: eb00029f     	cmp	x20, x0
     128: 54003002     	b.hs	0x728 <___pl_fn_0+0x728>
     12c: 8b140de0     	add	x0, x15, x20, lsl #3
     130: 3940a009     	ldrb	w9, [x0, #0x28]
     134: 53001d20     	uxtb	w0, w9
     138: 7100081f     	cmp	w0, #0x2
     13c: 54000081     	b.ne	0x14c <___pl_fn_0+0x14c>
     140: 1400017a     	b	0x728 <___pl_fn_0+0x728>
     144: f84783e0     	ldur	x0, [sp, #0x78]
     148: f9401809     	ldr	x9, [x0, #0x30]
     14c: 72001d3f     	tst	w9, #0xff
     150: 54000061     	b.ne	0x15c <___pl_fn_0+0x15c>
     154: 52800001     	mov	w1, #0x0                ; =0
     158: 14000027     	b	0x1f4 <___pl_fn_0+0x1f4>
     15c: f84783e0     	ldur	x0, [sp, #0x78]
     160: f9402401     	ldr	x1, [x0, #0x48]
     164: 2a1503e0     	mov	w0, w21
     168: d1000400     	sub	x0, x0, #0x1
     16c: eb01001f     	cmp	x0, x1
     170: 54002ee2     	b.hs	0x74c <___pl_fn_0+0x74c>
     174: f84783e1     	ldur	x1, [sp, #0x78]
     178: f9402021     	ldr	x1, [x1, #0x40]
     17c: d2800603     	mov	x3, #0x30               ; =48
     180: 9b037c02     	mul	x2, x0, x3
     184: 9b030400     	madd	x0, x0, x3, x1
     188: f9400400     	ldr	x0, [x0, #0x8]
     18c: b50000a0     	cbnz	x0, 0x1a0 <___pl_fn_0+0x1a0>
     190: 1400016f     	b	0x74c <___pl_fn_0+0x74c>
     194: f84783e0     	ldur	x0, [sp, #0x78]
     198: f9401802     	ldr	x2, [x0, #0x30]
     19c: 14000002     	b	0x1a4 <___pl_fn_0+0x1a4>
     1a0: f8626822     	ldr	x2, [x1, x2]
     1a4: ab160280     	adds	x0, x20, x22
     1a8: 9a9f77e1     	cset	x1, vs
     1ac: 72001c3f     	tst	w1, #0xff
     1b0: 54005ac1     	b.ne	0xd08 <___pl_fn_0+0xd08>
     1b4: 34002dc2     	cbz	w2, 0x76c <___pl_fn_0+0x76c>
     1b8: f84783e1     	ldur	x1, [sp, #0x78]
     1bc: f9400021     	ldr	x1, [x1]
     1c0: 2a0203e3     	mov	w3, w2
     1c4: 8b030c21     	add	x1, x1, x3, lsl #3
     1c8: f9400823     	ldr	x3, [x1, #0x10]
     1cc: eb03001f     	cmp	x0, x3
     1d0: 54002ce2     	b.hs	0x76c <___pl_fn_0+0x76c>
     1d4: 8b000c21     	add	x1, x1, x0, lsl #3
     1d8: 3940a021     	ldrb	w1, [x1, #0x28]
     1dc: 53001c23     	uxtb	w3, w1
     1e0: 7100087f     	cmp	w3, #0x2
     1e4: 54000081     	b.ne	0x1f4 <___pl_fn_0+0x1f4>
     1e8: 14000161     	b	0x76c <___pl_fn_0+0x76c>
     1ec: f84783e0     	ldur	x0, [sp, #0x78]
     1f0: f9401801     	ldr	x1, [x0, #0x30]
     1f4: 72001c3f     	tst	w1, #0xff
     1f8: 54000081     	b.ne	0x208 <___pl_fn_0+0x208>
     1fc: 52800000     	mov	w0, #0x0                ; =0
     200: aa1303f8     	mov	x24, x19
     204: 14000031     	b	0x2c8 <___pl_fn_0+0x2c8>
     208: f84783e0     	ldur	x0, [sp, #0x78]
     20c: f9402401     	ldr	x1, [x0, #0x48]
     210: aa1303f8     	mov	x24, x19
     214: 2a1803e0     	mov	w0, w24
     218: d1000400     	sub	x0, x0, #0x1
     21c: eb01001f     	cmp	x0, x1
     220: 54002b82     	b.hs	0x790 <___pl_fn_0+0x790>
     224: f84783e1     	ldur	x1, [sp, #0x78]
     228: f9402021     	ldr	x1, [x1, #0x40]
     22c: d2800603     	mov	x3, #0x30               ; =48
     230: 9b037c02     	mul	x2, x0, x3
     234: 9b030400     	madd	x0, x0, x3, x1
     238: f9400400     	ldr	x0, [x0, #0x8]
     23c: b50000a0     	cbnz	x0, 0x250 <___pl_fn_0+0x250>
     240: 14000154     	b	0x790 <___pl_fn_0+0x790>
     244: f84783e0     	ldur	x0, [sp, #0x78]
     248: f9401802     	ldr	x2, [x0, #0x30]
     24c: 14000002     	b	0x254 <___pl_fn_0+0x254>
     250: f8626822     	ldr	x2, [x1, x2]
     254: eb160283     	subs	x3, x20, x22
     258: 9a9f77e4     	cset	x4, vs
     25c: 72001c9f     	tst	w4, #0xff
     260: 54005381     	b.ne	0xcd0 <___pl_fn_0+0xcd0>
     264: ab190064     	adds	x4, x3, x25
     268: 9a9f77e6     	cset	x6, vs
     26c: 72001cdf     	tst	w6, #0xff
     270: 54005141     	b.ne	0xc98 <___pl_fn_0+0xc98>
     274: d2800027     	mov	x7, #0x1                ; =1
     278: eb070086     	subs	x6, x4, x7
     27c: 9a9f77e8     	cset	x8, vs
     280: 72001d1f     	tst	w8, #0xff
     284: 54004ee1     	b.ne	0xc60 <___pl_fn_0+0xc60>
     288: 34002942     	cbz	w2, 0x7b0 <___pl_fn_0+0x7b0>
     28c: f84783e0     	ldur	x0, [sp, #0x78]
     290: f940000b     	ldr	x11, [x0]
     294: 2a0203ec     	mov	w12, w2
     298: 8b0c0d6b     	add	x11, x11, x12, lsl #3
     29c: f940096c     	ldr	x12, [x11, #0x10]
     2a0: eb0c00df     	cmp	x6, x12
     2a4: 54002862     	b.hs	0x7b0 <___pl_fn_0+0x7b0>
     2a8: 8b060d6e     	add	x14, x11, x6, lsl #3
     2ac: 3940a1c0     	ldrb	w0, [x14, #0x28]
     2b0: 53001c0e     	uxtb	w14, w0
     2b4: 710009df     	cmp	w14, #0x2
     2b8: 54000081     	b.ne	0x2c8 <___pl_fn_0+0x2c8>
     2bc: 1400013d     	b	0x7b0 <___pl_fn_0+0x7b0>
     2c0: f84783e0     	ldur	x0, [sp, #0x78]
     2c4: f9401800     	ldr	x0, [x0, #0x30]
     2c8: 72001c1f     	tst	w0, #0xff
     2cc: 54000061     	b.ne	0x2d8 <___pl_fn_0+0x2d8>
     2d0: f84803f3     	ldur	x19, [sp, #0x80]
     2d4: 140000f7     	b	0x6b0 <___pl_fn_0+0x6b0>
     2d8: f84783e0     	ldur	x0, [sp, #0x78]
     2dc: f9402400     	ldr	x0, [x0, #0x48]
     2e0: d1000741     	sub	x1, x26, #0x1
     2e4: eb00003f     	cmp	x1, x0
     2e8: 54002762     	b.hs	0x7d4 <___pl_fn_0+0x7d4>
     2ec: f84783e0     	ldur	x0, [sp, #0x78]
     2f0: f9402000     	ldr	x0, [x0, #0x40]
     2f4: d2800602     	mov	x2, #0x30               ; =48
     2f8: d1000743     	sub	x3, x26, #0x1
     2fc: 9b027c61     	mul	x1, x3, x2
     300: 9b020062     	madd	x2, x3, x2, x0
     304: f9400442     	ldr	x2, [x2, #0x8]
     308: b50000a2     	cbnz	x2, 0x31c <___pl_fn_0+0x31c>
     30c: 14000132     	b	0x7d4 <___pl_fn_0+0x7d4>
     310: f84783e0     	ldur	x0, [sp, #0x78]
     314: f9401802     	ldr	x2, [x0, #0x30]
     318: 14000002     	b	0x320 <___pl_fn_0+0x320>
     31c: f8616802     	ldr	x2, [x0, x1]
     320: 340026a2     	cbz	w2, 0x7f4 <___pl_fn_0+0x7f4>
     324: f84783e0     	ldur	x0, [sp, #0x78]
     328: f9400000     	ldr	x0, [x0]
     32c: 2a0203e1     	mov	w1, w2
     330: 8b010c00     	add	x0, x0, x1, lsl #3
     334: f9400801     	ldr	x1, [x0, #0x10]
     338: eb01029f     	cmp	x20, x1
     33c: 54000083     	b.lo	0x34c <___pl_fn_0+0x34c>
     340: 1400012d     	b	0x7f4 <___pl_fn_0+0x7f4>
     344: f84783e0     	ldur	x0, [sp, #0x78]
     348: 14000005     	b	0x35c <___pl_fn_0+0x35c>
     34c: d2800001     	mov	x1, #0x0                ; =0
     350: 8b140c00     	add	x0, x0, x20, lsl #3
     354: f9001401     	str	x1, [x0, #0x28]
     358: f84783e0     	ldur	x0, [sp, #0x78]
     35c: f84783e0     	ldur	x0, [sp, #0x78]
     360: f9402400     	ldr	x0, [x0, #0x48]
     364: 2a1503e1     	mov	w1, w21
     368: d100043b     	sub	x27, x1, #0x1
     36c: eb00037f     	cmp	x27, x0
     370: 54002582     	b.hs	0x820 <___pl_fn_0+0x820>
     374: f84783e0     	ldur	x0, [sp, #0x78]
     378: f9402000     	ldr	x0, [x0, #0x40]
     37c: d2800602     	mov	x2, #0x30               ; =48
     380: 9b027f61     	mul	x1, x27, x2
     384: 9b020362     	madd	x2, x27, x2, x0
     388: f9400442     	ldr	x2, [x2, #0x8]
     38c: b50000a2     	cbnz	x2, 0x3a0 <___pl_fn_0+0x3a0>
     390: 14000124     	b	0x820 <___pl_fn_0+0x820>
     394: f84783e0     	ldur	x0, [sp, #0x78]
     398: f9401802     	ldr	x2, [x0, #0x30]
     39c: 14000002     	b	0x3a4 <___pl_fn_0+0x3a4>
     3a0: f8616802     	ldr	x2, [x0, x1]
     3a4: ab160280     	adds	x0, x20, x22
     3a8: 9a9f77e1     	cset	x1, vs
     3ac: 72001c3f     	tst	w1, #0xff
     3b0: 540043c1     	b.ne	0xc28 <___pl_fn_0+0xc28>
     3b4: 34002462     	cbz	w2, 0x840 <___pl_fn_0+0x840>
     3b8: f84783e1     	ldur	x1, [sp, #0x78]
     3bc: f9400021     	ldr	x1, [x1]
     3c0: 2a0203e3     	mov	w3, w2
     3c4: 8b030c21     	add	x1, x1, x3, lsl #3
     3c8: f9400823     	ldr	x3, [x1, #0x10]
     3cc: eb03001f     	cmp	x0, x3
     3d0: 54000083     	b.lo	0x3e0 <___pl_fn_0+0x3e0>
     3d4: 1400011b     	b	0x840 <___pl_fn_0+0x840>
     3d8: f84783e0     	ldur	x0, [sp, #0x78]
     3dc: 14000005     	b	0x3f0 <___pl_fn_0+0x3f0>
     3e0: d2800005     	mov	x5, #0x0                ; =0
     3e4: 8b000c26     	add	x6, x1, x0, lsl #3
     3e8: f90014c5     	str	x5, [x6, #0x28]
     3ec: f84783e0     	ldur	x0, [sp, #0x78]
     3f0: f84783e0     	ldur	x0, [sp, #0x78]
     3f4: f9402407     	ldr	x7, [x0, #0x48]
     3f8: 2a1803e8     	mov	w8, w24
     3fc: d100051c     	sub	x28, x8, #0x1
     400: eb07039f     	cmp	x28, x7
     404: 54002342     	b.hs	0x86c <___pl_fn_0+0x86c>
     408: f84783e0     	ldur	x0, [sp, #0x78]
     40c: f940200a     	ldr	x10, [x0, #0x40]
     410: d280060c     	mov	x12, #0x30              ; =48
     414: 9b0c7f8b     	mul	x11, x28, x12
     418: 9b0c2b8c     	madd	x12, x28, x12, x10
     41c: f940058c     	ldr	x12, [x12, #0x8]
     420: b50000ac     	cbnz	x12, 0x434 <___pl_fn_0+0x434>
     424: 14000112     	b	0x86c <___pl_fn_0+0x86c>
     428: f84783e0     	ldur	x0, [sp, #0x78]
     42c: f9401802     	ldr	x2, [x0, #0x30]
     430: 14000002     	b	0x438 <___pl_fn_0+0x438>
     434: f86b6942     	ldr	x2, [x10, x11]
     438: eb16028f     	subs	x15, x20, x22
     43c: 9a9f77e0     	cset	x0, vs
     440: 72001c1f     	tst	w0, #0xff
     444: 54003d61     	b.ne	0xbf0 <___pl_fn_0+0xbf0>
     448: ab1901e0     	adds	x0, x15, x25
     44c: 9a9f77e1     	cset	x1, vs
     450: 72001c3f     	tst	w1, #0xff
     454: 54003b21     	b.ne	0xbb8 <___pl_fn_0+0xbb8>
     458: d2800021     	mov	x1, #0x1                ; =1
     45c: eb010000     	subs	x0, x0, x1
     460: 9a9f77e1     	cset	x1, vs
     464: 72001c3f     	tst	w1, #0xff
     468: 540038c1     	b.ne	0xb80 <___pl_fn_0+0xb80>
     46c: 34002102     	cbz	w2, 0x88c <___pl_fn_0+0x88c>
     470: f84783e1     	ldur	x1, [sp, #0x78]
     474: f9400021     	ldr	x1, [x1]
     478: 2a0203e3     	mov	w3, w2
     47c: 8b030c21     	add	x1, x1, x3, lsl #3
     480: f9400823     	ldr	x3, [x1, #0x10]
     484: eb03001f     	cmp	x0, x3
     488: 54002022     	b.hs	0x88c <___pl_fn_0+0x88c>
     48c: d2800002     	mov	x2, #0x0                ; =0
     490: 8b000c20     	add	x0, x1, x0, lsl #3
     494: f9001402     	str	x2, [x0, #0x28]
     498: d2800020     	mov	x0, #0x1                ; =1
     49c: ab0002c1     	adds	x1, x22, x0
     4a0: 9a9f77e0     	cset	x0, vs
     4a4: 72001c1f     	tst	w0, #0xff
     4a8: 54003501     	b.ne	0xb48 <___pl_fn_0+0xb48>
     4ac: f84783e0     	ldur	x0, [sp, #0x78]
     4b0: b9401000     	ldr	w0, [x0, #0x10]
     4b4: f84783e6     	ldur	x6, [sp, #0x78]
     4b8: b94014c2     	ldr	w2, [x6, #0x14]
     4bc: 6b02001f     	cmp	w0, w2
     4c0: 54003282     	b.hs	0xb10 <___pl_fn_0+0xb10>
     4c4: f84783e0     	ldur	x0, [sp, #0x78]
     4c8: aa1903e2     	mov	x2, x25
     4cc: aa1703e3     	mov	x3, x23
     4d0: aa1503e4     	mov	x4, x21
     4d4: aa1803e5     	mov	x5, x24
     4d8: 94000000     	bl	0x4d8 <___pl_fn_0+0x4d8>
     4dc: f84783eb     	ldur	x11, [sp, #0x78]
     4e0: b9402d61     	ldr	w1, [x11, #0x2c]
     4e4: 35003041     	cbnz	w1, 0xaec <___pl_fn_0+0xaec>
     4e8: f84803f3     	ldur	x19, [sp, #0x80]
     4ec: ab000273     	adds	x19, x19, x0
     4f0: 9a9f77e0     	cset	x0, vs
     4f4: 72001c1f     	tst	w0, #0xff
     4f8: 54002de1     	b.ne	0xab4 <___pl_fn_0+0xab4>
     4fc: f84783e0     	ldur	x0, [sp, #0x78]
     500: f9402400     	ldr	x0, [x0, #0x48]
     504: d1000741     	sub	x1, x26, #0x1
     508: eb00003f     	cmp	x1, x0
     50c: 54001d62     	b.hs	0x8b8 <___pl_fn_0+0x8b8>
     510: f84783e0     	ldur	x0, [sp, #0x78]
     514: f9402000     	ldr	x0, [x0, #0x40]
     518: d2800602     	mov	x2, #0x30               ; =48
     51c: d1000743     	sub	x3, x26, #0x1
     520: 9b027c61     	mul	x1, x3, x2
     524: 9b020062     	madd	x2, x3, x2, x0
     528: f9400442     	ldr	x2, [x2, #0x8]
     52c: b50000a2     	cbnz	x2, 0x540 <___pl_fn_0+0x540>
     530: 140000e2     	b	0x8b8 <___pl_fn_0+0x8b8>
     534: f84783e0     	ldur	x0, [sp, #0x78]
     538: f9401802     	ldr	x2, [x0, #0x30]
     53c: 14000002     	b	0x544 <___pl_fn_0+0x544>
     540: f8616802     	ldr	x2, [x0, x1]
     544: 34001ca2     	cbz	w2, 0x8d8 <___pl_fn_0+0x8d8>
     548: f84783e0     	ldur	x0, [sp, #0x78]
     54c: f9400000     	ldr	x0, [x0]
     550: 2a0203e1     	mov	w1, w2
     554: 8b010c00     	add	x0, x0, x1, lsl #3
     558: f9400801     	ldr	x1, [x0, #0x10]
     55c: eb01029f     	cmp	x20, x1
     560: 54000083     	b.lo	0x570 <___pl_fn_0+0x570>
     564: 140000dd     	b	0x8d8 <___pl_fn_0+0x8d8>
     568: f84783e0     	ldur	x0, [sp, #0x78]
     56c: 14000005     	b	0x580 <___pl_fn_0+0x580>
     570: d2800021     	mov	x1, #0x1                ; =1
     574: 8b140c00     	add	x0, x0, x20, lsl #3
     578: f9001401     	str	x1, [x0, #0x28]
     57c: f84783e0     	ldur	x0, [sp, #0x78]
     580: f84783e0     	ldur	x0, [sp, #0x78]
     584: f9402400     	ldr	x0, [x0, #0x48]
     588: eb00037f     	cmp	x27, x0
     58c: 54001bc2     	b.hs	0x904 <___pl_fn_0+0x904>
     590: f84783e0     	ldur	x0, [sp, #0x78]
     594: f9402003     	ldr	x3, [x0, #0x40]
     598: d2800605     	mov	x5, #0x30               ; =48
     59c: 9b057f64     	mul	x4, x27, x5
     5a0: 9b050f65     	madd	x5, x27, x5, x3
     5a4: f94004a5     	ldr	x5, [x5, #0x8]
     5a8: b50000a5     	cbnz	x5, 0x5bc <___pl_fn_0+0x5bc>
     5ac: 140000d6     	b	0x904 <___pl_fn_0+0x904>
     5b0: f84783e0     	ldur	x0, [sp, #0x78]
     5b4: f9401802     	ldr	x2, [x0, #0x30]
     5b8: 14000002     	b	0x5c0 <___pl_fn_0+0x5c0>
     5bc: f8646862     	ldr	x2, [x3, x4]
     5c0: ab160288     	adds	x8, x20, x22
     5c4: 9a9f77ea     	cset	x10, vs
     5c8: 72001d5f     	tst	w10, #0xff
     5cc: 54002581     	b.ne	0xa7c <___pl_fn_0+0xa7c>
     5d0: 34001aa2     	cbz	w2, 0x924 <___pl_fn_0+0x924>
     5d4: f84783e0     	ldur	x0, [sp, #0x78]
     5d8: f940000d     	ldr	x13, [x0]
     5dc: 2a0203ee     	mov	w14, w2
     5e0: 8b0e0dad     	add	x13, x13, x14, lsl #3
     5e4: f94009ae     	ldr	x14, [x13, #0x10]
     5e8: eb0e011f     	cmp	x8, x14
     5ec: 54000083     	b.lo	0x5fc <___pl_fn_0+0x5fc>
     5f0: 140000cd     	b	0x924 <___pl_fn_0+0x924>
     5f4: f84783e0     	ldur	x0, [sp, #0x78]
     5f8: 14000005     	b	0x60c <___pl_fn_0+0x60c>
     5fc: d2800020     	mov	x0, #0x1                ; =1
     600: 8b080da1     	add	x1, x13, x8, lsl #3
     604: f9001420     	str	x0, [x1, #0x28]
     608: f84783e0     	ldur	x0, [sp, #0x78]
     60c: f84783e0     	ldur	x0, [sp, #0x78]
     610: f9402400     	ldr	x0, [x0, #0x48]
     614: eb00039f     	cmp	x28, x0
     618: 540019c2     	b.hs	0x950 <___pl_fn_0+0x950>
     61c: f84783e0     	ldur	x0, [sp, #0x78]
     620: f9402000     	ldr	x0, [x0, #0x40]
     624: d2800602     	mov	x2, #0x30               ; =48
     628: 9b027f81     	mul	x1, x28, x2
     62c: 9b020382     	madd	x2, x28, x2, x0
     630: f9400442     	ldr	x2, [x2, #0x8]
     634: b50000a2     	cbnz	x2, 0x648 <___pl_fn_0+0x648>
     638: 140000c6     	b	0x950 <___pl_fn_0+0x950>
     63c: f84783e0     	ldur	x0, [sp, #0x78]
     640: f9401802     	ldr	x2, [x0, #0x30]
     644: 14000002     	b	0x64c <___pl_fn_0+0x64c>
     648: f8616802     	ldr	x2, [x0, x1]
     64c: eb160280     	subs	x0, x20, x22
     650: 9a9f77e1     	cset	x1, vs
     654: 72001c3f     	tst	w1, #0xff
     658: 54001f61     	b.ne	0xa44 <___pl_fn_0+0xa44>
     65c: ab190000     	adds	x0, x0, x25
     660: 9a9f77e1     	cset	x1, vs
     664: 72001c3f     	tst	w1, #0xff
     668: 54001d21     	b.ne	0xa0c <___pl_fn_0+0xa0c>
     66c: d2800021     	mov	x1, #0x1                ; =1
     670: eb010000     	subs	x0, x0, x1
     674: 9a9f77e1     	cset	x1, vs
     678: 72001c3f     	tst	w1, #0xff
     67c: 54001ac1     	b.ne	0x9d4 <___pl_fn_0+0x9d4>
     680: 34001782     	cbz	w2, 0x970 <___pl_fn_0+0x970>
     684: f84783e1     	ldur	x1, [sp, #0x78]
     688: f9400021     	ldr	x1, [x1]
     68c: 2a0203e3     	mov	w3, w2
     690: 8b030c21     	add	x1, x1, x3, lsl #3
     694: f9400823     	ldr	x3, [x1, #0x10]
     698: eb03001f     	cmp	x0, x3
     69c: 540016a2     	b.hs	0x970 <___pl_fn_0+0x970>
     6a0: d2800022     	mov	x2, #0x1                ; =1
     6a4: 8b000c20     	add	x0, x1, x0, lsl #3
     6a8: f9001402     	str	x2, [x0, #0x28]
     6ac: 5280003b     	mov	w27, #0x1               ; =1
     6b0: d2800020     	mov	x0, #0x1                ; =1
     6b4: ab000294     	adds	x20, x20, x0
     6b8: 9a9f77e0     	cset	x0, vs
     6bc: 72001c1f     	tst	w0, #0xff
     6c0: 540016e1     	b.ne	0x99c <___pl_fn_0+0x99c>
     6c4: 52800020     	mov	w0, #0x1                ; =1
     6c8: f80803f3     	stur	x19, [sp, #0x80]
     6cc: aa1803f3     	mov	x19, x24
     6d0: aa1703e5     	mov	x5, x23
     6d4: 17fffe68     	b	0x74 <___pl_fn_0+0x74>
     6d8: f84783e0     	ldur	x0, [sp, #0x78]
     6dc: b9001003     	str	w3, [x0, #0x10]
     6e0: d2800020     	mov	x0, #0x1                ; =1
     6e4: 910243ff     	add	sp, sp, #0x90
     6e8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6ec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6f0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6f4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6f8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     6fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     700: d65f03c0     	ret
     704: f80783e0     	stur	x0, [sp, #0x78]
     708: 52800041     	mov	w1, #0x2                ; =2
     70c: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     710: f9400129     	ldr	x9, [x9]
     714: f84783e0     	ldur	x0, [sp, #0x78]
     718: aa1703e2     	mov	x2, x23
     71c: d63f0120     	blr	x9
     720: 34ffcee0     	cbz	w0, 0xfc <___pl_fn_0+0xfc>
     724: 140000f2     	b	0xaec <___pl_fn_0+0xaec>
     728: 910003e3     	mov	x3, sp
     72c: f80003f4     	stur	x20, [sp]
     730: 52800061     	mov	w1, #0x3                ; =3
     734: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     738: f9400084     	ldr	x4, [x4]
     73c: f84783e0     	ldur	x0, [sp, #0x78]
     740: d63f0080     	blr	x4
     744: 34ffd000     	cbz	w0, 0x144 <___pl_fn_0+0x144>
     748: 140000e9     	b	0xaec <___pl_fn_0+0xaec>
     74c: 52800081     	mov	w1, #0x4                ; =4
     750: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     754: f9400063     	ldr	x3, [x3]
     758: f84783e0     	ldur	x0, [sp, #0x78]
     75c: aa1503e2     	mov	x2, x21
     760: d63f0060     	blr	x3
     764: 34ffd180     	cbz	w0, 0x194 <___pl_fn_0+0x194>
     768: 140000e1     	b	0xaec <___pl_fn_0+0xaec>
     76c: 910023e3     	add	x3, sp, #0x8
     770: f80083e0     	stur	x0, [sp, #0x8]
     774: 528000c1     	mov	w1, #0x6                ; =6
     778: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     77c: f9400084     	ldr	x4, [x4]
     780: f84783e0     	ldur	x0, [sp, #0x78]
     784: d63f0080     	blr	x4
     788: 34ffd320     	cbz	w0, 0x1ec <___pl_fn_0+0x1ec>
     78c: 140000d8     	b	0xaec <___pl_fn_0+0xaec>
     790: 528000e1     	mov	w1, #0x7                ; =7
     794: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     798: f9400063     	ldr	x3, [x3]
     79c: f84783e0     	ldur	x0, [sp, #0x78]
     7a0: aa1803e2     	mov	x2, x24
     7a4: d63f0060     	blr	x3
     7a8: 34ffd4e0     	cbz	w0, 0x244 <___pl_fn_0+0x244>
     7ac: 140000d0     	b	0xaec <___pl_fn_0+0xaec>
     7b0: 910043e3     	add	x3, sp, #0x10
     7b4: f80103e6     	stur	x6, [sp, #0x10]
     7b8: 52800161     	mov	w1, #0xb                ; =11
     7bc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     7c0: f9400084     	ldr	x4, [x4]
     7c4: f84783e0     	ldur	x0, [sp, #0x78]
     7c8: d63f0080     	blr	x4
     7cc: 34ffd7a0     	cbz	w0, 0x2c0 <___pl_fn_0+0x2c0>
     7d0: 140000c7     	b	0xaec <___pl_fn_0+0xaec>
     7d4: 52800181     	mov	w1, #0xc                ; =12
     7d8: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     7dc: f9400063     	ldr	x3, [x3]
     7e0: f84783e0     	ldur	x0, [sp, #0x78]
     7e4: aa1703e2     	mov	x2, x23
     7e8: d63f0060     	blr	x3
     7ec: 34ffd920     	cbz	w0, 0x310 <___pl_fn_0+0x310>
     7f0: 140000bf     	b	0xaec <___pl_fn_0+0xaec>
     7f4: 910063e3     	add	x3, sp, #0x18
     7f8: f80183f4     	stur	x20, [sp, #0x18]
     7fc: d2800000     	mov	x0, #0x0                ; =0
     800: f80203e0     	stur	x0, [sp, #0x20]
     804: 528001a1     	mov	w1, #0xd                ; =13
     808: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     80c: f9400084     	ldr	x4, [x4]
     810: f84783e0     	ldur	x0, [sp, #0x78]
     814: d63f0080     	blr	x4
     818: 34ffd960     	cbz	w0, 0x344 <___pl_fn_0+0x344>
     81c: 140000b4     	b	0xaec <___pl_fn_0+0xaec>
     820: 528001c1     	mov	w1, #0xe                ; =14
     824: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     828: f9400063     	ldr	x3, [x3]
     82c: f84783e0     	ldur	x0, [sp, #0x78]
     830: aa1503e2     	mov	x2, x21
     834: d63f0060     	blr	x3
     838: 34ffdae0     	cbz	w0, 0x394 <___pl_fn_0+0x394>
     83c: 140000ac     	b	0xaec <___pl_fn_0+0xaec>
     840: 9100a3e3     	add	x3, sp, #0x28
     844: f80283e0     	stur	x0, [sp, #0x28]
     848: d2800001     	mov	x1, #0x0                ; =0
     84c: f80303e1     	stur	x1, [sp, #0x30]
     850: 52800201     	mov	w1, #0x10               ; =16
     854: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     858: f9400084     	ldr	x4, [x4]
     85c: f84783e0     	ldur	x0, [sp, #0x78]
     860: d63f0080     	blr	x4
     864: 34ffdba0     	cbz	w0, 0x3d8 <___pl_fn_0+0x3d8>
     868: 140000a1     	b	0xaec <___pl_fn_0+0xaec>
     86c: 52800221     	mov	w1, #0x11               ; =17
     870: 9000000c     	adrp	x12, 0x0 <___pl_fn_0>
     874: f940018c     	ldr	x12, [x12]
     878: f84783e0     	ldur	x0, [sp, #0x78]
     87c: aa1803e2     	mov	x2, x24
     880: d63f0180     	blr	x12
     884: 34ffdd20     	cbz	w0, 0x428 <___pl_fn_0+0x428>
     888: 14000099     	b	0xaec <___pl_fn_0+0xaec>
     88c: 9100e3e3     	add	x3, sp, #0x38
     890: f80383e0     	stur	x0, [sp, #0x38]
     894: d2800000     	mov	x0, #0x0                ; =0
     898: f80403e0     	stur	x0, [sp, #0x40]
     89c: 528002a1     	mov	w1, #0x15               ; =21
     8a0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     8a4: f9400084     	ldr	x4, [x4]
     8a8: f84783e0     	ldur	x0, [sp, #0x78]
     8ac: d63f0080     	blr	x4
     8b0: 34ffdf40     	cbz	w0, 0x498 <___pl_fn_0+0x498>
     8b4: 1400008e     	b	0xaec <___pl_fn_0+0xaec>
     8b8: 52800321     	mov	w1, #0x19               ; =25
     8bc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     8c0: f9400063     	ldr	x3, [x3]
     8c4: f84783e0     	ldur	x0, [sp, #0x78]
     8c8: aa1703e2     	mov	x2, x23
     8cc: d63f0060     	blr	x3
     8d0: 34ffe320     	cbz	w0, 0x534 <___pl_fn_0+0x534>
     8d4: 14000086     	b	0xaec <___pl_fn_0+0xaec>
     8d8: 910123e3     	add	x3, sp, #0x48
     8dc: f80483f4     	stur	x20, [sp, #0x48]
     8e0: d2800020     	mov	x0, #0x1                ; =1
     8e4: f80503e0     	stur	x0, [sp, #0x50]
     8e8: 52800341     	mov	w1, #0x1a               ; =26
     8ec: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     8f0: f9400084     	ldr	x4, [x4]
     8f4: f84783e0     	ldur	x0, [sp, #0x78]
     8f8: d63f0080     	blr	x4
     8fc: 34ffe360     	cbz	w0, 0x568 <___pl_fn_0+0x568>
     900: 1400007b     	b	0xaec <___pl_fn_0+0xaec>
     904: 52800361     	mov	w1, #0x1b               ; =27
     908: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     90c: f94000a5     	ldr	x5, [x5]
     910: f84783e0     	ldur	x0, [sp, #0x78]
     914: aa1503e2     	mov	x2, x21
     918: d63f00a0     	blr	x5
     91c: 34ffe4a0     	cbz	w0, 0x5b0 <___pl_fn_0+0x5b0>
     920: 14000073     	b	0xaec <___pl_fn_0+0xaec>
     924: 910163e3     	add	x3, sp, #0x58
     928: f80583e8     	stur	x8, [sp, #0x58]
     92c: d2800020     	mov	x0, #0x1                ; =1
     930: f80603e0     	stur	x0, [sp, #0x60]
     934: 528003a1     	mov	w1, #0x1d               ; =29
     938: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     93c: f9400084     	ldr	x4, [x4]
     940: f84783e0     	ldur	x0, [sp, #0x78]
     944: d63f0080     	blr	x4
     948: 34ffe560     	cbz	w0, 0x5f4 <___pl_fn_0+0x5f4>
     94c: 14000068     	b	0xaec <___pl_fn_0+0xaec>
     950: 528003c1     	mov	w1, #0x1e               ; =30
     954: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     958: f9400063     	ldr	x3, [x3]
     95c: f84783e0     	ldur	x0, [sp, #0x78]
     960: aa1803e2     	mov	x2, x24
     964: d63f0060     	blr	x3
     968: 34ffe6a0     	cbz	w0, 0x63c <___pl_fn_0+0x63c>
     96c: 14000060     	b	0xaec <___pl_fn_0+0xaec>
     970: 9101a3e3     	add	x3, sp, #0x68
     974: f80683e0     	stur	x0, [sp, #0x68]
     978: d2800020     	mov	x0, #0x1                ; =1
     97c: f80703e0     	stur	x0, [sp, #0x70]
     980: 52800441     	mov	w1, #0x22               ; =34
     984: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     988: f9400084     	ldr	x4, [x4]
     98c: f84783e0     	ldur	x0, [sp, #0x78]
     990: d63f0080     	blr	x4
     994: 34ffe8c0     	cbz	w0, 0x6ac <___pl_fn_0+0x6ac>
     998: 14000055     	b	0xaec <___pl_fn_0+0xaec>
     99c: 52800461     	mov	w1, #0x23               ; =35
     9a0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9a4: f9400042     	ldr	x2, [x2]
     9a8: f84783e0     	ldur	x0, [sp, #0x78]
     9ac: d63f0040     	blr	x2
     9b0: d2800000     	mov	x0, #0x0                ; =0
     9b4: 910243ff     	add	sp, sp, #0x90
     9b8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9bc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9c0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9c4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9c8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9d0: d65f03c0     	ret
     9d4: 52800421     	mov	w1, #0x21               ; =33
     9d8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9dc: f9400042     	ldr	x2, [x2]
     9e0: f84783e0     	ldur	x0, [sp, #0x78]
     9e4: d63f0040     	blr	x2
     9e8: d2800000     	mov	x0, #0x0                ; =0
     9ec: 910243ff     	add	sp, sp, #0x90
     9f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9f4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9f8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9fc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a00: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a04: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a08: d65f03c0     	ret
     a0c: 52800401     	mov	w1, #0x20               ; =32
     a10: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a14: f9400042     	ldr	x2, [x2]
     a18: f84783e0     	ldur	x0, [sp, #0x78]
     a1c: d63f0040     	blr	x2
     a20: d2800000     	mov	x0, #0x0                ; =0
     a24: 910243ff     	add	sp, sp, #0x90
     a28: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a2c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a30: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a34: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a38: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a3c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a40: d65f03c0     	ret
     a44: 528003e1     	mov	w1, #0x1f               ; =31
     a48: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a4c: f9400042     	ldr	x2, [x2]
     a50: f84783e0     	ldur	x0, [sp, #0x78]
     a54: d63f0040     	blr	x2
     a58: d2800000     	mov	x0, #0x0                ; =0
     a5c: 910243ff     	add	sp, sp, #0x90
     a60: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a64: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a68: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a6c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a70: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a74: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a78: d65f03c0     	ret
     a7c: 52800381     	mov	w1, #0x1c               ; =28
     a80: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a84: f9400042     	ldr	x2, [x2]
     a88: f84783e0     	ldur	x0, [sp, #0x78]
     a8c: d63f0040     	blr	x2
     a90: d2800000     	mov	x0, #0x0                ; =0
     a94: 910243ff     	add	sp, sp, #0x90
     a98: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a9c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     aa0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     aa4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     aa8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     aac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ab0: d65f03c0     	ret
     ab4: 52800301     	mov	w1, #0x18               ; =24
     ab8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     abc: f9400042     	ldr	x2, [x2]
     ac0: f84783e0     	ldur	x0, [sp, #0x78]
     ac4: d63f0040     	blr	x2
     ac8: d2800000     	mov	x0, #0x0                ; =0
     acc: 910243ff     	add	sp, sp, #0x90
     ad0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ad4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ad8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     adc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     ae0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ae4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ae8: d65f03c0     	ret
     aec: d2800000     	mov	x0, #0x0                ; =0
     af0: 910243ff     	add	sp, sp, #0x90
     af4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     af8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     afc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b00: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b04: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b08: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b0c: d65f03c0     	ret
     b10: 528002e1     	mov	w1, #0x17               ; =23
     b14: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b18: f9400042     	ldr	x2, [x2]
     b1c: f84783e0     	ldur	x0, [sp, #0x78]
     b20: d63f0040     	blr	x2
     b24: d2800000     	mov	x0, #0x0                ; =0
     b28: 910243ff     	add	sp, sp, #0x90
     b2c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b30: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b34: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b38: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b3c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b40: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b44: d65f03c0     	ret
     b48: 528002c1     	mov	w1, #0x16               ; =22
     b4c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b50: f9400042     	ldr	x2, [x2]
     b54: f84783e0     	ldur	x0, [sp, #0x78]
     b58: d63f0040     	blr	x2
     b5c: d2800000     	mov	x0, #0x0                ; =0
     b60: 910243ff     	add	sp, sp, #0x90
     b64: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b68: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b6c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b70: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b74: a8c173fb     	ldp	x27, x28, [sp], #0x10
     b78: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b7c: d65f03c0     	ret
     b80: 52800281     	mov	w1, #0x14               ; =20
     b84: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b88: f9400042     	ldr	x2, [x2]
     b8c: f84783e0     	ldur	x0, [sp, #0x78]
     b90: d63f0040     	blr	x2
     b94: d2800000     	mov	x0, #0x0                ; =0
     b98: 910243ff     	add	sp, sp, #0x90
     b9c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ba0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ba4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ba8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     bac: a8c173fb     	ldp	x27, x28, [sp], #0x10
     bb0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     bb4: d65f03c0     	ret
     bb8: 52800261     	mov	w1, #0x13               ; =19
     bbc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     bc0: f9400042     	ldr	x2, [x2]
     bc4: f84783e0     	ldur	x0, [sp, #0x78]
     bc8: d63f0040     	blr	x2
     bcc: d2800000     	mov	x0, #0x0                ; =0
     bd0: 910243ff     	add	sp, sp, #0x90
     bd4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     bd8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     bdc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     be0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     be4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     be8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     bec: d65f03c0     	ret
     bf0: 52800241     	mov	w1, #0x12               ; =18
     bf4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     bf8: f9400042     	ldr	x2, [x2]
     bfc: f84783e0     	ldur	x0, [sp, #0x78]
     c00: d63f0040     	blr	x2
     c04: d2800000     	mov	x0, #0x0                ; =0
     c08: 910243ff     	add	sp, sp, #0x90
     c0c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c10: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c14: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c18: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c1c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     c20: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c24: d65f03c0     	ret
     c28: 528001e1     	mov	w1, #0xf                ; =15
     c2c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     c30: f9400063     	ldr	x3, [x3]
     c34: f84783e0     	ldur	x0, [sp, #0x78]
     c38: d63f0060     	blr	x3
     c3c: d2800000     	mov	x0, #0x0                ; =0
     c40: 910243ff     	add	sp, sp, #0x90
     c44: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c48: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c4c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c50: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c54: a8c173fb     	ldp	x27, x28, [sp], #0x10
     c58: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c5c: d65f03c0     	ret
     c60: 52800141     	mov	w1, #0xa                ; =10
     c64: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c68: f9400084     	ldr	x4, [x4]
     c6c: f84783e0     	ldur	x0, [sp, #0x78]
     c70: d63f0080     	blr	x4
     c74: d2800000     	mov	x0, #0x0                ; =0
     c78: 910243ff     	add	sp, sp, #0x90
     c7c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c80: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c84: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c88: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c8c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     c90: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c94: d65f03c0     	ret
     c98: 52800121     	mov	w1, #0x9                ; =9
     c9c: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     ca0: f94000a5     	ldr	x5, [x5]
     ca4: f84783e0     	ldur	x0, [sp, #0x78]
     ca8: d63f00a0     	blr	x5
     cac: d2800000     	mov	x0, #0x0                ; =0
     cb0: 910243ff     	add	sp, sp, #0x90
     cb4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cb8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     cbc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     cc0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     cc4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     cc8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ccc: d65f03c0     	ret
     cd0: 52800101     	mov	w1, #0x8                ; =8
     cd4: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     cd8: f94000c6     	ldr	x6, [x6]
     cdc: f84783e0     	ldur	x0, [sp, #0x78]
     ce0: d63f00c0     	blr	x6
     ce4: d2800000     	mov	x0, #0x0                ; =0
     ce8: 910243ff     	add	sp, sp, #0x90
     cec: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cf0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     cf4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     cf8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     cfc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     d00: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d04: d65f03c0     	ret
     d08: 528000a1     	mov	w1, #0x5                ; =5
     d0c: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     d10: f94000e7     	ldr	x7, [x7]
     d14: f84783e0     	ldur	x0, [sp, #0x78]
     d18: d63f00e0     	blr	x7
     d1c: d2800000     	mov	x0, #0x0                ; =0
     d20: 910243ff     	add	sp, sp, #0x90
     d24: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d28: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d2c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d30: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d34: a8c173fb     	ldp	x27, x28, [sp], #0x10
     d38: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d3c: d65f03c0     	ret
     d40: 52800001     	mov	w1, #0x0                ; =0
     d44: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     d48: f9400108     	ldr	x8, [x8]
     d4c: f84783e0     	ldur	x0, [sp, #0x78]
     d50: d63f0100     	blr	x8
     d54: d2800000     	mov	x0, #0x0                ; =0
     d58: 910243ff     	add	sp, sp, #0x90
     d5c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d60: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d64: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d68: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     d6c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     d70: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d74: d65f03c0     	ret

0000000000000d78 <___pl_fn_1>:
     d78: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     d7c: 910003fd     	mov	x29, sp
     d80: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
     d84: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
     d88: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     d8c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     d90: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     d94: d10143ff     	sub	sp, sp, #0x50
     d98: b9401003     	ldr	w3, [x0, #0x10]
     d9c: 11000463     	add	w3, w3, #0x1
     da0: b9001003     	str	w3, [x0, #0x10]
     da4: aa0003f9     	mov	x25, x0
     da8: 52800481     	mov	w1, #0x24               ; =36
     dac: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     db0: f9400084     	ldr	x4, [x4]
     db4: d63f0080     	blr	x4
     db8: 35003040     	cbnz	w0, 0x13c0 <___pl_fn_1+0x648>
     dbc: aa1903e0     	mov	x0, x25
     dc0: f9401802     	ldr	x2, [x0, #0x30]
     dc4: aa0203fa     	mov	x26, x2
     dc8: d2800207     	mov	x7, #0x10               ; =16
     dcc: 910003e3     	mov	x3, sp
     dd0: f80003e7     	stur	x7, [sp]
     dd4: 528004a1     	mov	w1, #0x25               ; =37
     dd8: 52802042     	mov	w2, #0x102              ; =258
     ddc: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     de0: f9400108     	ldr	x8, [x8]
     de4: aa1903e0     	mov	x0, x25
     de8: d63f0100     	blr	x8
     dec: 35002ea0     	cbnz	w0, 0x13c0 <___pl_fn_1+0x648>
     df0: aa1903e0     	mov	x0, x25
     df4: f9401814     	ldr	x20, [x0, #0x30]
     df8: 528004c1     	mov	w1, #0x26               ; =38
     dfc: 52800082     	mov	w2, #0x4                ; =4
     e00: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     e04: f940014a     	ldr	x10, [x10]
     e08: d63f0140     	blr	x10
     e0c: 35002da0     	cbnz	w0, 0x13c0 <___pl_fn_1+0x648>
     e10: aa1903e0     	mov	x0, x25
     e14: f9401815     	ldr	x21, [x0, #0x30]
     e18: f940240c     	ldr	x12, [x0, #0x48]
     e1c: 2a1503f3     	mov	w19, w21
     e20: d100066d     	sub	x13, x19, #0x1
     e24: eb0c01bf     	cmp	x13, x12
     e28: 54001ec2     	b.hs	0x1200 <___pl_fn_1+0x488>
     e2c: aa1903e0     	mov	x0, x25
     e30: f940200f     	ldr	x15, [x0, #0x40]
     e34: d2800600     	mov	x0, #0x30               ; =48
     e38: d1000662     	sub	x2, x19, #0x1
     e3c: 9b007c41     	mul	x1, x2, x0
     e40: 9b003c40     	madd	x0, x2, x0, x15
     e44: f9400802     	ldr	x2, [x0, #0x10]
     e48: b4001dc2     	cbz	x2, 0x1200 <___pl_fn_1+0x488>
     e4c: aa1503fc     	mov	x28, x21
     e50: 2a1403e2     	mov	w2, w20
     e54: f82169e2     	str	x2, [x15, x1]
     e58: 7100029f     	cmp	w20, #0x0
     e5c: 9a9f07e1     	cset	x1, ne
     e60: f9000401     	str	x1, [x0, #0x8]
     e64: d2800200     	mov	x0, #0x10               ; =16
     e68: 910023e3     	add	x3, sp, #0x8
     e6c: f80083e0     	stur	x0, [sp, #0x8]
     e70: 52800501     	mov	w1, #0x28               ; =40
     e74: 52802042     	mov	w2, #0x102              ; =258
     e78: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     e7c: f9400084     	ldr	x4, [x4]
     e80: aa1903e0     	mov	x0, x25
     e84: d63f0080     	blr	x4
     e88: 350029c0     	cbnz	w0, 0x13c0 <___pl_fn_1+0x648>
     e8c: aa1903e0     	mov	x0, x25
     e90: f940181b     	ldr	x27, [x0, #0x30]
     e94: 52800521     	mov	w1, #0x29               ; =41
     e98: 52800082     	mov	w2, #0x4                ; =4
     e9c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     ea0: f9400063     	ldr	x3, [x3]
     ea4: d63f0060     	blr	x3
     ea8: 350028c0     	cbnz	w0, 0x13c0 <___pl_fn_1+0x648>
     eac: aa1903e0     	mov	x0, x25
     eb0: f9401815     	ldr	x21, [x0, #0x30]
     eb4: f9402400     	ldr	x0, [x0, #0x48]
     eb8: 2a1503e1     	mov	w1, w21
     ebc: d1000434     	sub	x20, x1, #0x1
     ec0: eb00029f     	cmp	x20, x0
     ec4: 54001b22     	b.hs	0x1228 <___pl_fn_1+0x4b0>
     ec8: aa1903e0     	mov	x0, x25
     ecc: f9402000     	ldr	x0, [x0, #0x40]
     ed0: d2800601     	mov	x1, #0x30               ; =48
     ed4: 9b017e82     	mul	x2, x20, x1
     ed8: 9b010281     	madd	x1, x20, x1, x0
     edc: f9400823     	ldr	x3, [x1, #0x10]
     ee0: b4001a43     	cbz	x3, 0x1228 <___pl_fn_1+0x4b0>
     ee4: f80483f5     	stur	x21, [sp, #0x48]
     ee8: 2a1b03e3     	mov	w3, w27
     eec: f8226803     	str	x3, [x0, x2]
     ef0: 7100037f     	cmp	w27, #0x0
     ef4: 9a9f07e0     	cset	x0, ne
     ef8: f9000420     	str	x0, [x1, #0x8]
     efc: d2800200     	mov	x0, #0x10               ; =16
     f00: 910043e3     	add	x3, sp, #0x10
     f04: f80103e0     	stur	x0, [sp, #0x10]
     f08: 52800561     	mov	w1, #0x2b               ; =43
     f0c: 52802042     	mov	w2, #0x102              ; =258
     f10: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     f14: f9400084     	ldr	x4, [x4]
     f18: aa1903e0     	mov	x0, x25
     f1c: d63f0080     	blr	x4
     f20: 35002500     	cbnz	w0, 0x13c0 <___pl_fn_1+0x648>
     f24: aa1903e0     	mov	x0, x25
     f28: f9401816     	ldr	x22, [x0, #0x30]
     f2c: 52800581     	mov	w1, #0x2c               ; =44
     f30: 52800082     	mov	w2, #0x4                ; =4
     f34: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     f38: f9400063     	ldr	x3, [x3]
     f3c: d63f0060     	blr	x3
     f40: 35002400     	cbnz	w0, 0x13c0 <___pl_fn_1+0x648>
     f44: aa1903e0     	mov	x0, x25
     f48: f9401817     	ldr	x23, [x0, #0x30]
     f4c: f9402400     	ldr	x0, [x0, #0x48]
     f50: 2a1703e1     	mov	w1, w23
     f54: d1000435     	sub	x21, x1, #0x1
     f58: eb0002bf     	cmp	x21, x0
     f5c: 540017a2     	b.hs	0x1250 <___pl_fn_1+0x4d8>
     f60: aa1903e0     	mov	x0, x25
     f64: f9402000     	ldr	x0, [x0, #0x40]
     f68: d2800601     	mov	x1, #0x30               ; =48
     f6c: 9b017ea2     	mul	x2, x21, x1
     f70: 9b0102a1     	madd	x1, x21, x1, x0
     f74: f9400823     	ldr	x3, [x1, #0x10]
     f78: b40016c3     	cbz	x3, 0x1250 <___pl_fn_1+0x4d8>
     f7c: 2a1603e3     	mov	w3, w22
     f80: f8226803     	str	x3, [x0, x2]
     f84: 710002df     	cmp	w22, #0x0
     f88: 9a9f07e0     	cset	x0, ne
     f8c: f9000420     	str	x0, [x1, #0x8]
     f90: 528005c1     	mov	w1, #0x2e               ; =46
     f94: 52800002     	mov	w2, #0x0                ; =0
     f98: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     f9c: f9400063     	ldr	x3, [x3]
     fa0: aa1903e0     	mov	x0, x25
     fa4: d63f0060     	blr	x3
     fa8: 350020c0     	cbnz	w0, 0x13c0 <___pl_fn_1+0x648>
     fac: aa1903e0     	mov	x0, x25
     fb0: f9401802     	ldr	x2, [x0, #0x30]
     fb4: aa0203f6     	mov	x22, x2
     fb8: d2800018     	mov	x24, #0x0               ; =0
     fbc: 52800020     	mov	w0, #0x1                ; =1
     fc0: f1003f1f     	cmp	x24, #0xf
     fc4: 9a9fc7e0     	cset	x0, le
     fc8: 72001c1f     	tst	w0, #0xff
     fcc: 54000561     	b.ne	0x1078 <___pl_fn_1+0x300>
     fd0: aa1903e0     	mov	x0, x25
     fd4: b9401004     	ldr	w4, [x0, #0x10]
     fd8: b9401405     	ldr	w5, [x0, #0x14]
     fdc: 6b05009f     	cmp	w4, w5
     fe0: 540014a2     	b.hs	0x1274 <___pl_fn_1+0x4fc>
     fe4: d2800001     	mov	x1, #0x0                ; =0
     fe8: aa1603e2     	mov	x2, x22
     fec: aa1c03e3     	mov	x3, x28
     ff0: f84483e4     	ldur	x4, [sp, #0x48]
     ff4: aa1703e5     	mov	x5, x23
     ff8: aa1903e0     	mov	x0, x25
     ffc: 94000000     	bl	0xffc <___pl_fn_1+0x284>
    1000: aa0003e2     	mov	x2, x0
    1004: aa1903e0     	mov	x0, x25
    1008: b9402c06     	ldr	w6, [x0, #0x2c]
    100c: 35001da6     	cbnz	w6, 0x13c0 <___pl_fn_1+0x648>
    1010: 52800621     	mov	w1, #0x31               ; =49
    1014: 52802003     	mov	w3, #0x100              ; =256
    1018: 90000008     	adrp	x8, 0x1000 <___pl_fn_1+0x288>
    101c: f9400108     	ldr	x8, [x8]
    1020: aa1903e0     	mov	x0, x25
    1024: d63f0100     	blr	x8
    1028: 35001cc0     	cbnz	w0, 0x13c0 <___pl_fn_1+0x648>
    102c: 52800641     	mov	w1, #0x32               ; =50
    1030: 9000000a     	adrp	x10, 0x1000 <___pl_fn_1+0x288>
    1034: f940014a     	ldr	x10, [x10]
    1038: aa1a03e2     	mov	x2, x26
    103c: aa1903e0     	mov	x0, x25
    1040: d63f0140     	blr	x10
    1044: 35001be0     	cbnz	w0, 0x13c0 <___pl_fn_1+0x648>
    1048: aa1903e0     	mov	x0, x25
    104c: b940100c     	ldr	w12, [x0, #0x10]
    1050: 5100058c     	sub	w12, w12, #0x1
    1054: b900100c     	str	w12, [x0, #0x10]
    1058: 910143ff     	add	sp, sp, #0x50
    105c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1060: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1064: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1068: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    106c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1070: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1074: d65f03c0     	ret
    1078: aa1903e0     	mov	x0, x25
    107c: f940240f     	ldr	x15, [x0, #0x48]
    1080: d1000660     	sub	x0, x19, #0x1
    1084: eb0f001f     	cmp	x0, x15
    1088: 54001102     	b.hs	0x12a8 <___pl_fn_1+0x530>
    108c: aa1903e0     	mov	x0, x25
    1090: f9402000     	ldr	x0, [x0, #0x40]
    1094: d2800602     	mov	x2, #0x30               ; =48
    1098: d1000663     	sub	x3, x19, #0x1
    109c: 9b027c61     	mul	x1, x3, x2
    10a0: 9b020062     	madd	x2, x3, x2, x0
    10a4: f9400442     	ldr	x2, [x2, #0x8]
    10a8: b50000a2     	cbnz	x2, 0x10bc <___pl_fn_1+0x344>
    10ac: 1400007f     	b	0x12a8 <___pl_fn_1+0x530>
    10b0: aa1903e0     	mov	x0, x25
    10b4: f9401802     	ldr	x2, [x0, #0x30]
    10b8: 14000002     	b	0x10c0 <___pl_fn_1+0x348>
    10bc: f8616802     	ldr	x2, [x0, x1]
    10c0: 34001042     	cbz	w2, 0x12c8 <___pl_fn_1+0x550>
    10c4: aa1903e0     	mov	x0, x25
    10c8: f9400000     	ldr	x0, [x0]
    10cc: 2a0203e1     	mov	w1, w2
    10d0: 8b010c00     	add	x0, x0, x1, lsl #3
    10d4: f9400801     	ldr	x1, [x0, #0x10]
    10d8: eb01031f     	cmp	x24, x1
    10dc: 54000083     	b.lo	0x10ec <___pl_fn_1+0x374>
    10e0: 1400007a     	b	0x12c8 <___pl_fn_1+0x550>
    10e4: aa1903e0     	mov	x0, x25
    10e8: 14000005     	b	0x10fc <___pl_fn_1+0x384>
    10ec: d2800021     	mov	x1, #0x1                ; =1
    10f0: 8b180c00     	add	x0, x0, x24, lsl #3
    10f4: f9001401     	str	x1, [x0, #0x28]
    10f8: aa1903e0     	mov	x0, x25
    10fc: aa1903e0     	mov	x0, x25
    1100: f9402400     	ldr	x0, [x0, #0x48]
    1104: eb00029f     	cmp	x20, x0
    1108: 54000f62     	b.hs	0x12f4 <___pl_fn_1+0x57c>
    110c: aa1903e0     	mov	x0, x25
    1110: f9402000     	ldr	x0, [x0, #0x40]
    1114: d2800602     	mov	x2, #0x30               ; =48
    1118: 9b027e81     	mul	x1, x20, x2
    111c: 9b020282     	madd	x2, x20, x2, x0
    1120: f9400442     	ldr	x2, [x2, #0x8]
    1124: b50000a2     	cbnz	x2, 0x1138 <___pl_fn_1+0x3c0>
    1128: 14000073     	b	0x12f4 <___pl_fn_1+0x57c>
    112c: aa1903e0     	mov	x0, x25
    1130: f9401802     	ldr	x2, [x0, #0x30]
    1134: 14000002     	b	0x113c <___pl_fn_1+0x3c4>
    1138: f8616802     	ldr	x2, [x0, x1]
    113c: 34000ec2     	cbz	w2, 0x1314 <___pl_fn_1+0x59c>
    1140: aa1903e0     	mov	x0, x25
    1144: f9400000     	ldr	x0, [x0]
    1148: 2a0203e1     	mov	w1, w2
    114c: 8b010c00     	add	x0, x0, x1, lsl #3
    1150: f9400801     	ldr	x1, [x0, #0x10]
    1154: eb01031f     	cmp	x24, x1
    1158: 54000083     	b.lo	0x1168 <___pl_fn_1+0x3f0>
    115c: 1400006e     	b	0x1314 <___pl_fn_1+0x59c>
    1160: aa1903e0     	mov	x0, x25
    1164: 14000005     	b	0x1178 <___pl_fn_1+0x400>
    1168: d2800021     	mov	x1, #0x1                ; =1
    116c: 8b180c00     	add	x0, x0, x24, lsl #3
    1170: f9001401     	str	x1, [x0, #0x28]
    1174: aa1903e0     	mov	x0, x25
    1178: aa1903e0     	mov	x0, x25
    117c: f9402400     	ldr	x0, [x0, #0x48]
    1180: eb0002bf     	cmp	x21, x0
    1184: 54000de2     	b.hs	0x1340 <___pl_fn_1+0x5c8>
    1188: aa1903e0     	mov	x0, x25
    118c: f9402000     	ldr	x0, [x0, #0x40]
    1190: d2800602     	mov	x2, #0x30               ; =48
    1194: 9b027ea1     	mul	x1, x21, x2
    1198: 9b0202a2     	madd	x2, x21, x2, x0
    119c: f9400442     	ldr	x2, [x2, #0x8]
    11a0: b50000a2     	cbnz	x2, 0x11b4 <___pl_fn_1+0x43c>
    11a4: 14000067     	b	0x1340 <___pl_fn_1+0x5c8>
    11a8: aa1903e0     	mov	x0, x25
    11ac: f9401802     	ldr	x2, [x0, #0x30]
    11b0: 14000002     	b	0x11b8 <___pl_fn_1+0x440>
    11b4: f8616802     	ldr	x2, [x0, x1]
    11b8: 34000d42     	cbz	w2, 0x1360 <___pl_fn_1+0x5e8>
    11bc: aa1903e0     	mov	x0, x25
    11c0: f9400005     	ldr	x5, [x0]
    11c4: 2a0203e6     	mov	w6, w2
    11c8: 8b060ca5     	add	x5, x5, x6, lsl #3
    11cc: f94008a6     	ldr	x6, [x5, #0x10]
    11d0: eb06031f     	cmp	x24, x6
    11d4: 54000c62     	b.hs	0x1360 <___pl_fn_1+0x5e8>
    11d8: d280002d     	mov	x13, #0x1               ; =1
    11dc: 8b180cae     	add	x14, x5, x24, lsl #3
    11e0: f90015cd     	str	x13, [x14, #0x28]
    11e4: d280002f     	mov	x15, #0x1               ; =1
    11e8: ab0f0318     	adds	x24, x24, x15
    11ec: 9a9f77e0     	cset	x0, vs
    11f0: 72001c1f     	tst	w0, #0xff
    11f4: 54000cc1     	b.ne	0x138c <___pl_fn_1+0x614>
    11f8: 52800020     	mov	w0, #0x1                ; =1
    11fc: 17ffff71     	b	0xfc0 <___pl_fn_1+0x248>
    1200: 528004e1     	mov	w1, #0x27               ; =39
    1204: 2a1403e3     	mov	w3, w20
    1208: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0x288>
    120c: f9400084     	ldr	x4, [x4]
    1210: aa1903e0     	mov	x0, x25
    1214: aa1503e2     	mov	x2, x21
    1218: d63f0080     	blr	x4
    121c: aa1503fc     	mov	x28, x21
    1220: 34ffe220     	cbz	w0, 0xe64 <___pl_fn_1+0xec>
    1224: 14000067     	b	0x13c0 <___pl_fn_1+0x648>
    1228: 52800541     	mov	w1, #0x2a               ; =42
    122c: 2a1b03e3     	mov	w3, w27
    1230: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0x288>
    1234: f9400084     	ldr	x4, [x4]
    1238: aa1903e0     	mov	x0, x25
    123c: aa1503e2     	mov	x2, x21
    1240: d63f0080     	blr	x4
    1244: f80483f5     	stur	x21, [sp, #0x48]
    1248: 34ffe5a0     	cbz	w0, 0xefc <___pl_fn_1+0x184>
    124c: 1400005d     	b	0x13c0 <___pl_fn_1+0x648>
    1250: 528005a1     	mov	w1, #0x2d               ; =45
    1254: 2a1603e3     	mov	w3, w22
    1258: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0x288>
    125c: f9400084     	ldr	x4, [x4]
    1260: aa1903e0     	mov	x0, x25
    1264: aa1703e2     	mov	x2, x23
    1268: d63f0080     	blr	x4
    126c: 34ffe920     	cbz	w0, 0xf90 <___pl_fn_1+0x218>
    1270: 14000054     	b	0x13c0 <___pl_fn_1+0x648>
    1274: 52800601     	mov	w1, #0x30               ; =48
    1278: 9000000e     	adrp	x14, 0x1000 <___pl_fn_1+0x288>
    127c: f94001ce     	ldr	x14, [x14]
    1280: aa1903e0     	mov	x0, x25
    1284: d63f01c0     	blr	x14
    1288: 910143ff     	add	sp, sp, #0x50
    128c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1290: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1294: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1298: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    129c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    12a0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12a4: d65f03c0     	ret
    12a8: 52800661     	mov	w1, #0x33               ; =51
    12ac: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0x288>
    12b0: f9400063     	ldr	x3, [x3]
    12b4: aa1903e0     	mov	x0, x25
    12b8: aa1c03e2     	mov	x2, x28
    12bc: d63f0060     	blr	x3
    12c0: 34ffef80     	cbz	w0, 0x10b0 <___pl_fn_1+0x338>
    12c4: 1400003f     	b	0x13c0 <___pl_fn_1+0x648>
    12c8: 910063e3     	add	x3, sp, #0x18
    12cc: f80183f8     	stur	x24, [sp, #0x18]
    12d0: d2800020     	mov	x0, #0x1                ; =1
    12d4: f80203e0     	stur	x0, [sp, #0x20]
    12d8: 52800681     	mov	w1, #0x34               ; =52
    12dc: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0x288>
    12e0: f9400084     	ldr	x4, [x4]
    12e4: aa1903e0     	mov	x0, x25
    12e8: d63f0080     	blr	x4
    12ec: 34ffefc0     	cbz	w0, 0x10e4 <___pl_fn_1+0x36c>
    12f0: 14000034     	b	0x13c0 <___pl_fn_1+0x648>
    12f4: 528006a1     	mov	w1, #0x35               ; =53
    12f8: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0x288>
    12fc: f9400063     	ldr	x3, [x3]
    1300: aa1903e0     	mov	x0, x25
    1304: f84483e2     	ldur	x2, [sp, #0x48]
    1308: d63f0060     	blr	x3
    130c: 34fff100     	cbz	w0, 0x112c <___pl_fn_1+0x3b4>
    1310: 1400002c     	b	0x13c0 <___pl_fn_1+0x648>
    1314: 9100a3e3     	add	x3, sp, #0x28
    1318: f80283f8     	stur	x24, [sp, #0x28]
    131c: d2800020     	mov	x0, #0x1                ; =1
    1320: f80303e0     	stur	x0, [sp, #0x30]
    1324: 528006c1     	mov	w1, #0x36               ; =54
    1328: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0x288>
    132c: f9400084     	ldr	x4, [x4]
    1330: aa1903e0     	mov	x0, x25
    1334: d63f0080     	blr	x4
    1338: 34fff140     	cbz	w0, 0x1160 <___pl_fn_1+0x3e8>
    133c: 14000021     	b	0x13c0 <___pl_fn_1+0x648>
    1340: 528006e1     	mov	w1, #0x37               ; =55
    1344: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0x288>
    1348: f9400063     	ldr	x3, [x3]
    134c: aa1903e0     	mov	x0, x25
    1350: aa1703e2     	mov	x2, x23
    1354: d63f0060     	blr	x3
    1358: 34fff280     	cbz	w0, 0x11a8 <___pl_fn_1+0x430>
    135c: 14000019     	b	0x13c0 <___pl_fn_1+0x648>
    1360: 9100e3e3     	add	x3, sp, #0x38
    1364: f80383f8     	stur	x24, [sp, #0x38]
    1368: d2800029     	mov	x9, #0x1                ; =1
    136c: f80403e9     	stur	x9, [sp, #0x40]
    1370: 52800701     	mov	w1, #0x38               ; =56
    1374: 9000000a     	adrp	x10, 0x1000 <___pl_fn_1+0x288>
    1378: f940014a     	ldr	x10, [x10]
    137c: aa1903e0     	mov	x0, x25
    1380: d63f0140     	blr	x10
    1384: 34fff300     	cbz	w0, 0x11e4 <___pl_fn_1+0x46c>
    1388: 1400000e     	b	0x13c0 <___pl_fn_1+0x648>
    138c: 52800721     	mov	w1, #0x39               ; =57
    1390: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0x288>
    1394: f9400042     	ldr	x2, [x2]
    1398: aa1903e0     	mov	x0, x25
    139c: d63f0040     	blr	x2
    13a0: 910143ff     	add	sp, sp, #0x50
    13a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    13a8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    13ac: a8c163f7     	ldp	x23, x24, [sp], #0x10
    13b0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    13b4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    13b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    13bc: d65f03c0     	ret
    13c0: 910143ff     	add	sp, sp, #0x50
    13c4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    13c8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    13cc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    13d0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    13d4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    13d8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    13dc: d65f03c0     	ret
