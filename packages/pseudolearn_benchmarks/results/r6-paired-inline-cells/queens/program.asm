
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_69571/queens/program.o:	file format mach-o arm64

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
      e0: d2800509     	mov	x9, #0x28               ; =40
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
     17c: d2800503     	mov	x3, #0x28               ; =40
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
     22c: d2800503     	mov	x3, #0x28               ; =40
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
     2f4: d2800502     	mov	x2, #0x28               ; =40
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
     37c: d2800502     	mov	x2, #0x28               ; =40
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
     410: d280050c     	mov	x12, #0x28              ; =40
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
     518: d2800502     	mov	x2, #0x28               ; =40
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
     598: d2800505     	mov	x5, #0x28               ; =40
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
     624: d2800502     	mov	x2, #0x28               ; =40
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
     d80: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
     d84: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     d88: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     d8c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     d90: d10143ff     	sub	sp, sp, #0x50
     d94: b9401001     	ldr	w1, [x0, #0x10]
     d98: 11000421     	add	w1, w1, #0x1
     d9c: b9001001     	str	w1, [x0, #0x10]
     da0: aa0003f5     	mov	x21, x0
     da4: 52800481     	mov	w1, #0x24               ; =36
     da8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     dac: f9400042     	ldr	x2, [x2]
     db0: d63f0040     	blr	x2
     db4: 35002980     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     db8: aa1503e0     	mov	x0, x21
     dbc: f9401802     	ldr	x2, [x0, #0x30]
     dc0: aa0203f6     	mov	x22, x2
     dc4: d2800200     	mov	x0, #0x10               ; =16
     dc8: 910003e3     	mov	x3, sp
     dcc: f80003e0     	stur	x0, [sp]
     dd0: 528004a1     	mov	w1, #0x25               ; =37
     dd4: 52802042     	mov	w2, #0x102              ; =258
     dd8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     ddc: f9400084     	ldr	x4, [x4]
     de0: aa1503e0     	mov	x0, x21
     de4: d63f0080     	blr	x4
     de8: 350027e0     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     dec: aa1503e0     	mov	x0, x21
     df0: f9401813     	ldr	x19, [x0, #0x30]
     df4: 528004c1     	mov	w1, #0x26               ; =38
     df8: 52800082     	mov	w2, #0x4                ; =4
     dfc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     e00: f9400063     	ldr	x3, [x3]
     e04: d63f0060     	blr	x3
     e08: 350026e0     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     e0c: aa1503e0     	mov	x0, x21
     e10: f9401814     	ldr	x20, [x0, #0x30]
     e14: 528004e1     	mov	w1, #0x27               ; =39
     e18: 2a1303e3     	mov	w3, w19
     e1c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     e20: f9400084     	ldr	x4, [x4]
     e24: aa1403e2     	mov	x2, x20
     e28: d63f0080     	blr	x4
     e2c: aa1403f7     	mov	x23, x20
     e30: 350025a0     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     e34: d2800200     	mov	x0, #0x10               ; =16
     e38: 910023e3     	add	x3, sp, #0x8
     e3c: f80083e0     	stur	x0, [sp, #0x8]
     e40: 52800501     	mov	w1, #0x28               ; =40
     e44: 52802042     	mov	w2, #0x102              ; =258
     e48: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     e4c: f9400084     	ldr	x4, [x4]
     e50: aa1503e0     	mov	x0, x21
     e54: d63f0080     	blr	x4
     e58: 35002460     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     e5c: aa1503e0     	mov	x0, x21
     e60: f9401813     	ldr	x19, [x0, #0x30]
     e64: 52800521     	mov	w1, #0x29               ; =41
     e68: 52800082     	mov	w2, #0x4                ; =4
     e6c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     e70: f9400063     	ldr	x3, [x3]
     e74: d63f0060     	blr	x3
     e78: 35002360     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     e7c: aa1503e0     	mov	x0, x21
     e80: f9401814     	ldr	x20, [x0, #0x30]
     e84: 52800541     	mov	w1, #0x2a               ; =42
     e88: 2a1303e3     	mov	w3, w19
     e8c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     e90: f9400084     	ldr	x4, [x4]
     e94: aa1403e2     	mov	x2, x20
     e98: d63f0080     	blr	x4
     e9c: aa1403f8     	mov	x24, x20
     ea0: 35002220     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     ea4: d2800200     	mov	x0, #0x10               ; =16
     ea8: 910043e3     	add	x3, sp, #0x10
     eac: f80103e0     	stur	x0, [sp, #0x10]
     eb0: 52800561     	mov	w1, #0x2b               ; =43
     eb4: 52802042     	mov	w2, #0x102              ; =258
     eb8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     ebc: f9400084     	ldr	x4, [x4]
     ec0: aa1503e0     	mov	x0, x21
     ec4: d63f0080     	blr	x4
     ec8: 350020e0     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     ecc: aa1503e0     	mov	x0, x21
     ed0: f9401813     	ldr	x19, [x0, #0x30]
     ed4: 52800581     	mov	w1, #0x2c               ; =44
     ed8: 52800082     	mov	w2, #0x4                ; =4
     edc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     ee0: f9400063     	ldr	x3, [x3]
     ee4: d63f0060     	blr	x3
     ee8: 35001fe0     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     eec: aa1503e0     	mov	x0, x21
     ef0: f9401814     	ldr	x20, [x0, #0x30]
     ef4: 528005a1     	mov	w1, #0x2d               ; =45
     ef8: 2a1303e3     	mov	w3, w19
     efc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     f00: f9400084     	ldr	x4, [x4]
     f04: aa1403e2     	mov	x2, x20
     f08: d63f0080     	blr	x4
     f0c: 35001ec0     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     f10: 528005c1     	mov	w1, #0x2e               ; =46
     f14: 52800002     	mov	w2, #0x0                ; =0
     f18: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     f1c: f9400063     	ldr	x3, [x3]
     f20: aa1503e0     	mov	x0, x21
     f24: d63f0060     	blr	x3
     f28: 35001de0     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     f2c: aa1503e0     	mov	x0, x21
     f30: f9401802     	ldr	x2, [x0, #0x30]
     f34: aa0203f9     	mov	x25, x2
     f38: d280001a     	mov	x26, #0x0               ; =0
     f3c: 52800020     	mov	w0, #0x1                ; =1
     f40: f1003f5f     	cmp	x26, #0xf
     f44: 9a9fc7e0     	cset	x0, le
     f48: 72001c1f     	tst	w0, #0xff
     f4c: 54000561     	b.ne	0xff8 <___pl_fn_1+0x280>
     f50: aa1503e0     	mov	x0, x21
     f54: b940100b     	ldr	w11, [x0, #0x10]
     f58: b940140c     	ldr	w12, [x0, #0x14]
     f5c: 6b0c017f     	cmp	w11, w12
     f60: 54001202     	b.hs	0x11a0 <___pl_fn_1+0x428>
     f64: d2800001     	mov	x1, #0x0                ; =0
     f68: aa1903e2     	mov	x2, x25
     f6c: aa1703e3     	mov	x3, x23
     f70: aa1803e4     	mov	x4, x24
     f74: aa1403e5     	mov	x5, x20
     f78: aa1503e0     	mov	x0, x21
     f7c: 94000000     	bl	0xf7c <___pl_fn_1+0x204>
     f80: aa0003e2     	mov	x2, x0
     f84: aa1503e0     	mov	x0, x21
     f88: b9402c0d     	ldr	w13, [x0, #0x2c]
     f8c: 35001acd     	cbnz	w13, 0x12e4 <___pl_fn_1+0x56c>
     f90: 52800621     	mov	w1, #0x31               ; =49
     f94: 52802003     	mov	w3, #0x100              ; =256
     f98: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     f9c: f94001ef     	ldr	x15, [x15]
     fa0: aa1503e0     	mov	x0, x21
     fa4: d63f01e0     	blr	x15
     fa8: 350019e0     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     fac: 52800641     	mov	w1, #0x32               ; =50
     fb0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     fb4: f9400063     	ldr	x3, [x3]
     fb8: aa1603e2     	mov	x2, x22
     fbc: aa1503e0     	mov	x0, x21
     fc0: d63f0060     	blr	x3
     fc4: 35001900     	cbnz	w0, 0x12e4 <___pl_fn_1+0x56c>
     fc8: aa1503e0     	mov	x0, x21
     fcc: b9401000     	ldr	w0, [x0, #0x10]
     fd0: 51000400     	sub	w0, w0, #0x1
     fd4: aa1503e1     	mov	x1, x21
     fd8: b9001020     	str	w0, [x1, #0x10]
     fdc: 910143ff     	add	sp, sp, #0x50
     fe0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     fe4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     fe8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     fec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     ff0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ff4: d65f03c0     	ret
     ff8: aa1503e0     	mov	x0, x21
     ffc: f9402400     	ldr	x0, [x0, #0x48]
    1000: aa1703e3     	mov	x3, x23
    1004: 2a0303e1     	mov	w1, w3
    1008: d1000422     	sub	x2, x1, #0x1
    100c: eb00005f     	cmp	x2, x0
    1010: 54000e02     	b.hs	0x11d0 <___pl_fn_1+0x458>
    1014: aa1503e0     	mov	x0, x21
    1018: f9402000     	ldr	x0, [x0, #0x40]
    101c: d2800502     	mov	x2, #0x28               ; =40
    1020: d1000423     	sub	x3, x1, #0x1
    1024: 9b027c61     	mul	x1, x3, x2
    1028: 9b020062     	madd	x2, x3, x2, x0
    102c: f9400442     	ldr	x2, [x2, #0x8]
    1030: b50000a2     	cbnz	x2, 0x1044 <___pl_fn_1+0x2cc>
    1034: 14000067     	b	0x11d0 <___pl_fn_1+0x458>
    1038: aa1503e0     	mov	x0, x21
    103c: f9401802     	ldr	x2, [x0, #0x30]
    1040: 14000002     	b	0x1048 <___pl_fn_1+0x2d0>
    1044: f8616802     	ldr	x2, [x0, x1]
    1048: 34000d42     	cbz	w2, 0x11f0 <___pl_fn_1+0x478>
    104c: aa1503e0     	mov	x0, x21
    1050: f9400000     	ldr	x0, [x0]
    1054: 2a0203e1     	mov	w1, w2
    1058: 8b010c00     	add	x0, x0, x1, lsl #3
    105c: f9400801     	ldr	x1, [x0, #0x10]
    1060: eb01035f     	cmp	x26, x1
    1064: 54000083     	b.lo	0x1074 <___pl_fn_1+0x2fc>
    1068: 14000062     	b	0x11f0 <___pl_fn_1+0x478>
    106c: aa1503e0     	mov	x0, x21
    1070: 14000005     	b	0x1084 <___pl_fn_1+0x30c>
    1074: d2800021     	mov	x1, #0x1                ; =1
    1078: 8b1a0c00     	add	x0, x0, x26, lsl #3
    107c: f9001401     	str	x1, [x0, #0x28]
    1080: aa1503e0     	mov	x0, x21
    1084: aa1503e0     	mov	x0, x21
    1088: f9402401     	ldr	x1, [x0, #0x48]
    108c: aa1803f3     	mov	x19, x24
    1090: 2a1303e0     	mov	w0, w19
    1094: d1000400     	sub	x0, x0, #0x1
    1098: eb01001f     	cmp	x0, x1
    109c: 54000c02     	b.hs	0x121c <___pl_fn_1+0x4a4>
    10a0: aa1503e1     	mov	x1, x21
    10a4: f9402021     	ldr	x1, [x1, #0x40]
    10a8: d2800503     	mov	x3, #0x28               ; =40
    10ac: 9b037c02     	mul	x2, x0, x3
    10b0: 9b030400     	madd	x0, x0, x3, x1
    10b4: f9400400     	ldr	x0, [x0, #0x8]
    10b8: b50000a0     	cbnz	x0, 0x10cc <___pl_fn_1+0x354>
    10bc: 14000058     	b	0x121c <___pl_fn_1+0x4a4>
    10c0: aa1503e0     	mov	x0, x21
    10c4: f9401802     	ldr	x2, [x0, #0x30]
    10c8: 14000002     	b	0x10d0 <___pl_fn_1+0x358>
    10cc: f8626822     	ldr	x2, [x1, x2]
    10d0: 34000b62     	cbz	w2, 0x123c <___pl_fn_1+0x4c4>
    10d4: aa1503e0     	mov	x0, x21
    10d8: f9400000     	ldr	x0, [x0]
    10dc: 2a0203e1     	mov	w1, w2
    10e0: 8b010c00     	add	x0, x0, x1, lsl #3
    10e4: f9400801     	ldr	x1, [x0, #0x10]
    10e8: eb01035f     	cmp	x26, x1
    10ec: 54000083     	b.lo	0x10fc <___pl_fn_1+0x384>
    10f0: 14000053     	b	0x123c <___pl_fn_1+0x4c4>
    10f4: aa1503e0     	mov	x0, x21
    10f8: 14000005     	b	0x110c <___pl_fn_1+0x394>
    10fc: d2800021     	mov	x1, #0x1                ; =1
    1100: 8b1a0c00     	add	x0, x0, x26, lsl #3
    1104: f9001401     	str	x1, [x0, #0x28]
    1108: aa1503e0     	mov	x0, x21
    110c: aa1503e0     	mov	x0, x21
    1110: f9402402     	ldr	x2, [x0, #0x48]
    1114: 2a1403e1     	mov	w1, w20
    1118: d1000421     	sub	x1, x1, #0x1
    111c: eb02003f     	cmp	x1, x2
    1120: 54000a42     	b.hs	0x1268 <___pl_fn_1+0x4f0>
    1124: aa1503e0     	mov	x0, x21
    1128: f9402004     	ldr	x4, [x0, #0x40]
    112c: d2800506     	mov	x6, #0x28               ; =40
    1130: 9b067c25     	mul	x5, x1, x6
    1134: 9b061026     	madd	x6, x1, x6, x4
    1138: f94004c6     	ldr	x6, [x6, #0x8]
    113c: b50000a6     	cbnz	x6, 0x1150 <___pl_fn_1+0x3d8>
    1140: 1400004a     	b	0x1268 <___pl_fn_1+0x4f0>
    1144: aa1503e0     	mov	x0, x21
    1148: f9401802     	ldr	x2, [x0, #0x30]
    114c: 14000002     	b	0x1154 <___pl_fn_1+0x3dc>
    1150: f8656882     	ldr	x2, [x4, x5]
    1154: 340009a2     	cbz	w2, 0x1288 <___pl_fn_1+0x510>
    1158: aa1503e0     	mov	x0, x21
    115c: f940000c     	ldr	x12, [x0]
    1160: 2a0203ed     	mov	w13, w2
    1164: 8b0d0d8c     	add	x12, x12, x13, lsl #3
    1168: f940098d     	ldr	x13, [x12, #0x10]
    116c: eb0d035f     	cmp	x26, x13
    1170: 540008c2     	b.hs	0x1288 <___pl_fn_1+0x510>
    1174: d2800020     	mov	x0, #0x1                ; =1
    1178: 8b1a0d81     	add	x1, x12, x26, lsl #3
    117c: f9001420     	str	x0, [x1, #0x28]
    1180: d2800020     	mov	x0, #0x1                ; =1
    1184: ab00035a     	adds	x26, x26, x0
    1188: 9a9f77e0     	cset	x0, vs
    118c: 72001c1f     	tst	w0, #0xff
    1190: 54000921     	b.ne	0x12b4 <___pl_fn_1+0x53c>
    1194: 52800020     	mov	w0, #0x1                ; =1
    1198: aa1303f8     	mov	x24, x19
    119c: 17ffff69     	b	0xf40 <___pl_fn_1+0x1c8>
    11a0: 52800601     	mov	w1, #0x30               ; =48
    11a4: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0x288>
    11a8: f9400042     	ldr	x2, [x2]
    11ac: aa1503e0     	mov	x0, x21
    11b0: d63f0040     	blr	x2
    11b4: 910143ff     	add	sp, sp, #0x50
    11b8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11bc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    11c0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    11c4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    11c8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11cc: d65f03c0     	ret
    11d0: 52800661     	mov	w1, #0x33               ; =51
    11d4: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0x288>
    11d8: f9400063     	ldr	x3, [x3]
    11dc: aa1503e0     	mov	x0, x21
    11e0: aa1703e2     	mov	x2, x23
    11e4: d63f0060     	blr	x3
    11e8: 34fff280     	cbz	w0, 0x1038 <___pl_fn_1+0x2c0>
    11ec: 1400003e     	b	0x12e4 <___pl_fn_1+0x56c>
    11f0: 910063e3     	add	x3, sp, #0x18
    11f4: f80183fa     	stur	x26, [sp, #0x18]
    11f8: d2800020     	mov	x0, #0x1                ; =1
    11fc: f80203e0     	stur	x0, [sp, #0x20]
    1200: 52800681     	mov	w1, #0x34               ; =52
    1204: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0x288>
    1208: f9400084     	ldr	x4, [x4]
    120c: aa1503e0     	mov	x0, x21
    1210: d63f0080     	blr	x4
    1214: 34fff2c0     	cbz	w0, 0x106c <___pl_fn_1+0x2f4>
    1218: 14000033     	b	0x12e4 <___pl_fn_1+0x56c>
    121c: 528006a1     	mov	w1, #0x35               ; =53
    1220: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0x288>
    1224: f9400063     	ldr	x3, [x3]
    1228: aa1503e0     	mov	x0, x21
    122c: aa1303e2     	mov	x2, x19
    1230: d63f0060     	blr	x3
    1234: 34fff460     	cbz	w0, 0x10c0 <___pl_fn_1+0x348>
    1238: 1400002b     	b	0x12e4 <___pl_fn_1+0x56c>
    123c: 9100a3e3     	add	x3, sp, #0x28
    1240: f80283fa     	stur	x26, [sp, #0x28]
    1244: d2800020     	mov	x0, #0x1                ; =1
    1248: f80303e0     	stur	x0, [sp, #0x30]
    124c: 528006c1     	mov	w1, #0x36               ; =54
    1250: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0x288>
    1254: f9400084     	ldr	x4, [x4]
    1258: aa1503e0     	mov	x0, x21
    125c: d63f0080     	blr	x4
    1260: 34fff4a0     	cbz	w0, 0x10f4 <___pl_fn_1+0x37c>
    1264: 14000020     	b	0x12e4 <___pl_fn_1+0x56c>
    1268: 528006e1     	mov	w1, #0x37               ; =55
    126c: 90000006     	adrp	x6, 0x1000 <___pl_fn_1+0x288>
    1270: f94000c6     	ldr	x6, [x6]
    1274: aa1503e0     	mov	x0, x21
    1278: aa1403e2     	mov	x2, x20
    127c: d63f00c0     	blr	x6
    1280: 34fff620     	cbz	w0, 0x1144 <___pl_fn_1+0x3cc>
    1284: 14000018     	b	0x12e4 <___pl_fn_1+0x56c>
    1288: 9100e3e3     	add	x3, sp, #0x38
    128c: f80383fa     	stur	x26, [sp, #0x38]
    1290: d2800020     	mov	x0, #0x1                ; =1
    1294: f80403e0     	stur	x0, [sp, #0x40]
    1298: 52800701     	mov	w1, #0x38               ; =56
    129c: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0x288>
    12a0: f9400084     	ldr	x4, [x4]
    12a4: aa1503e0     	mov	x0, x21
    12a8: d63f0080     	blr	x4
    12ac: 34fff6a0     	cbz	w0, 0x1180 <___pl_fn_1+0x408>
    12b0: 1400000d     	b	0x12e4 <___pl_fn_1+0x56c>
    12b4: 52800721     	mov	w1, #0x39               ; =57
    12b8: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0x288>
    12bc: f9400042     	ldr	x2, [x2]
    12c0: aa1503e0     	mov	x0, x21
    12c4: d63f0040     	blr	x2
    12c8: 910143ff     	add	sp, sp, #0x50
    12cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    12d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    12d4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    12d8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    12dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12e0: d65f03c0     	ret
    12e4: 910143ff     	add	sp, sp, #0x50
    12e8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    12ec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    12f0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    12f4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    12f8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12fc: d65f03c0     	ret
