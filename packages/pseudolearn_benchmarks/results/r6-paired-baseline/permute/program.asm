
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_76447/permute/program.o:	file format mach-o arm64

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
      20: f80603e1     	stur	x1, [sp, #0x60]
      24: b9401001     	ldr	w1, [x0, #0x10]
      28: 11000423     	add	w3, w1, #0x1
      2c: b9001003     	str	w3, [x0, #0x10]
      30: b5000162     	cbnz	x2, 0x5c <___pl_fn_0+0x5c>
      34: d2800023     	mov	x3, #0x1                ; =1
      38: d2800014     	mov	x20, #0x0               ; =0
      3c: 52800021     	mov	w1, #0x1                ; =1
      40: 52800002     	mov	w2, #0x0                ; =0
      44: aa0003fc     	mov	x28, x0
      48: aa0303fb     	mov	x27, x3
      4c: aa1403fa     	mov	x26, x20
      50: aa0003e3     	mov	x3, x0
      54: aa0203e0     	mov	x0, x2
      58: 1400003b     	b	0x144 <___pl_fn_0+0x144>
      5c: d2800033     	mov	x19, #0x1               ; =1
      60: eb130043     	subs	x3, x2, x19
      64: aa0203f4     	mov	x20, x2
      68: 9a9f77e2     	cset	x2, vs
      6c: 72001c5f     	tst	w2, #0xff
      70: 540052c1     	b.ne	0xac8 <___pl_fn_0+0xac8>
      74: b9401402     	ldr	w2, [x0, #0x14]
      78: aa0003fc     	mov	x28, x0
      7c: 11000420     	add	w0, w1, #0x1
      80: 6b02001f     	cmp	w0, w2
      84: 54005062     	b.hs	0xa90 <___pl_fn_0+0xa90>
      88: aa0303e2     	mov	x2, x3
      8c: aa1c03e0     	mov	x0, x28
      90: f84603e1     	ldur	x1, [sp, #0x60]
      94: 94000000     	bl	0x94 <___pl_fn_0+0x94>
      98: aa1c03e1     	mov	x1, x28
      9c: b9402c21     	ldr	w1, [x1, #0x2c]
      a0: 35004e61     	cbnz	w1, 0xa6c <___pl_fn_0+0xa6c>
      a4: ab000263     	adds	x3, x19, x0
      a8: aa0303fb     	mov	x27, x3
      ac: 9a9f77e0     	cset	x0, vs
      b0: 72001c1f     	tst	w0, #0xff
      b4: 54004c01     	b.ne	0xa34 <___pl_fn_0+0xa34>
      b8: aa1403f5     	mov	x21, x20
      bc: eb1302b4     	subs	x20, x21, x19
      c0: 9a9f77e0     	cset	x0, vs
      c4: 72001c1f     	tst	w0, #0xff
      c8: 540049a1     	b.ne	0x9fc <___pl_fn_0+0x9fc>
      cc: d2800000     	mov	x0, #0x0                ; =0
      d0: ab000016     	adds	x22, x0, x0
      d4: 9a9f77e1     	cset	x1, vs
      d8: 72001c3f     	tst	w1, #0xff
      dc: 54004721     	b.ne	0x9c0 <___pl_fn_0+0x9c0>
      e0: eb130001     	subs	x1, x0, x19
      e4: 9a9f77e2     	cset	x2, vs
      e8: 72001c5f     	tst	w2, #0xff
      ec: 540044c1     	b.ne	0x984 <___pl_fn_0+0x984>
      f0: ab000037     	adds	x23, x1, x0
      f4: f80683e0     	stur	x0, [sp, #0x68]
      f8: 9a9f77e0     	cset	x0, vs
      fc: 72001c1f     	tst	w0, #0xff
     100: 54004261     	b.ne	0x94c <___pl_fn_0+0x94c>
     104: b4004097     	cbz	x23, 0x914 <___pl_fn_0+0x914>
     108: 52800038     	mov	w24, #0x1               ; =1
     10c: 52800000     	mov	w0, #0x0                ; =0
     110: aa1803e1     	mov	x1, x24
     114: aa1803e2     	mov	x2, x24
     118: f84683fa     	ldur	x26, [sp, #0x68]
     11c: f10002ff     	cmp	x23, #0x0
     120: 5400008a     	b.ge	0x130 <___pl_fn_0+0x130>
     124: eb16029f     	cmp	x20, x22
     128: 9a9fb7e3     	cset	x3, ge
     12c: 14000003     	b	0x138 <___pl_fn_0+0x138>
     130: eb16029f     	cmp	x20, x22
     134: 9a9fc7e3     	cset	x3, le
     138: 72001c7f     	tst	w3, #0xff
     13c: 54000201     	b.ne	0x17c <___pl_fn_0+0x17c>
     140: aa1c03e3     	mov	x3, x28
     144: aa1c03e3     	mov	x3, x28
     148: b9401060     	ldr	w0, [x3, #0x10]
     14c: 51000400     	sub	w0, w0, #0x1
     150: aa1c03e1     	mov	x1, x28
     154: b9001020     	str	w0, [x1, #0x10]
     158: aa1b03e0     	mov	x0, x27
     15c: 9101c3ff     	add	sp, sp, #0x70
     160: a8c153f3     	ldp	x19, x20, [sp], #0x10
     164: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     168: a8c163f7     	ldp	x23, x24, [sp], #0x10
     16c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     170: a8c173fb     	ldp	x27, x28, [sp], #0x10
     174: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     178: d65f03c0     	ret
     17c: 52800101     	mov	w1, #0x8                ; =8
     180: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     184: f9400063     	ldr	x3, [x3]
     188: aa1c03e0     	mov	x0, x28
     18c: f84603e2     	ldur	x2, [sp, #0x60]
     190: d63f0060     	blr	x3
     194: 350046c0     	cbnz	w0, 0xa6c <___pl_fn_0+0xa6c>
     198: aa1c03e0     	mov	x0, x28
     19c: f9401802     	ldr	x2, [x0, #0x30]
     1a0: eb1302a0     	subs	x0, x21, x19
     1a4: 9a9f77e1     	cset	x1, vs
     1a8: 72001c3f     	tst	w1, #0xff
     1ac: 54003981     	b.ne	0x8dc <___pl_fn_0+0x8dc>
     1b0: 340023a2     	cbz	w2, 0x624 <___pl_fn_0+0x624>
     1b4: aa1c03e1     	mov	x1, x28
     1b8: f9400021     	ldr	x1, [x1]
     1bc: 2a0203e3     	mov	w3, w2
     1c0: 8b030c21     	add	x1, x1, x3, lsl #3
     1c4: f9400823     	ldr	x3, [x1, #0x10]
     1c8: eb03001f     	cmp	x0, x3
     1cc: 540022c2     	b.hs	0x624 <___pl_fn_0+0x624>
     1d0: 8b000c24     	add	x4, x1, x0, lsl #3
     1d4: f9401499     	ldr	x25, [x4, #0x28]
     1d8: f9400c24     	ldr	x4, [x1, #0x18]
     1dc: eb04007f     	cmp	x3, x4
     1e0: 54000080     	b.eq	0x1f0 <___pl_fn_0+0x1f0>
     1e4: 14000110     	b	0x624 <___pl_fn_0+0x624>
     1e8: aa1c03e0     	mov	x0, x28
     1ec: f9401819     	ldr	x25, [x0, #0x30]
     1f0: 52800161     	mov	w1, #0xb                ; =11
     1f4: 9000000c     	adrp	x12, 0x0 <___pl_fn_0>
     1f8: f940018c     	ldr	x12, [x12]
     1fc: aa1c03e0     	mov	x0, x28
     200: f84603e2     	ldur	x2, [sp, #0x60]
     204: d63f0180     	blr	x12
     208: 35004320     	cbnz	w0, 0xa6c <___pl_fn_0+0xa6c>
     20c: aa1c03e0     	mov	x0, x28
     210: f9401802     	ldr	x2, [x0, #0x30]
     214: 340021a2     	cbz	w2, 0x648 <___pl_fn_0+0x648>
     218: aa1c03e0     	mov	x0, x28
     21c: f9400000     	ldr	x0, [x0]
     220: 2a0203e1     	mov	w1, w2
     224: 8b010c00     	add	x0, x0, x1, lsl #3
     228: f9400801     	ldr	x1, [x0, #0x10]
     22c: eb01029f     	cmp	x20, x1
     230: 540020c2     	b.hs	0x648 <___pl_fn_0+0x648>
     234: 8b140c03     	add	x3, x0, x20, lsl #3
     238: f940147a     	ldr	x26, [x3, #0x28]
     23c: f9400c00     	ldr	x0, [x0, #0x18]
     240: eb00003f     	cmp	x1, x0
     244: 54000080     	b.eq	0x254 <___pl_fn_0+0x254>
     248: 14000100     	b	0x648 <___pl_fn_0+0x648>
     24c: aa1c03e0     	mov	x0, x28
     250: f940181a     	ldr	x26, [x0, #0x30]
     254: 528001a1     	mov	w1, #0xd                ; =13
     258: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     25c: f9400063     	ldr	x3, [x3]
     260: aa1c03e0     	mov	x0, x28
     264: f84603e2     	ldur	x2, [sp, #0x60]
     268: d63f0060     	blr	x3
     26c: 35004000     	cbnz	w0, 0xa6c <___pl_fn_0+0xa6c>
     270: aa1c03e0     	mov	x0, x28
     274: f9401802     	ldr	x2, [x0, #0x30]
     278: eb1302a0     	subs	x0, x21, x19
     27c: 9a9f77e1     	cset	x1, vs
     280: 72001c3f     	tst	w1, #0xff
     284: 54003101     	b.ne	0x8a4 <___pl_fn_0+0x8a4>
     288: 34001f22     	cbz	w2, 0x66c <___pl_fn_0+0x66c>
     28c: aa1c03e1     	mov	x1, x28
     290: f9400023     	ldr	x3, [x1]
     294: 2a0203e1     	mov	w1, w2
     298: 8b010c61     	add	x1, x3, x1, lsl #3
     29c: f9400824     	ldr	x4, [x1, #0x10]
     2a0: eb04001f     	cmp	x0, x4
     2a4: 54001e42     	b.hs	0x66c <___pl_fn_0+0x66c>
     2a8: f9400c22     	ldr	x2, [x1, #0x18]
     2ac: eb02009f     	cmp	x4, x2
     2b0: 54000220     	b.eq	0x2f4 <___pl_fn_0+0x2f4>
     2b4: f9401025     	ldr	x5, [x1, #0x20]
     2b8: d346fc06     	lsr	x6, x0, #6
     2bc: 8b0600a5     	add	x5, x5, x6
     2c0: f8657866     	ldr	x6, [x3, x5, lsl #3]
     2c4: 92401407     	and	x7, x0, #0x3f
     2c8: 9ac72267     	lsl	x7, x19, x7
     2cc: 8a0700c8     	and	x8, x6, x7
     2d0: b5000128     	cbnz	x8, 0x2f4 <___pl_fn_0+0x2f4>
     2d4: aa0700c6     	orr	x6, x6, x7
     2d8: f8257866     	str	x6, [x3, x5, lsl #3]
     2dc: 91000442     	add	x2, x2, #0x1
     2e0: f9000c22     	str	x2, [x1, #0x18]
     2e4: eb04005f     	cmp	x2, x4
     2e8: 54000061     	b.ne	0x2f4 <___pl_fn_0+0x2f4>
     2ec: f84683e2     	ldur	x2, [sp, #0x68]
     2f0: f9001022     	str	x2, [x1, #0x20]
     2f4: 8b000c20     	add	x0, x1, x0, lsl #3
     2f8: f900141a     	str	x26, [x0, #0x28]
     2fc: 52800201     	mov	w1, #0x10               ; =16
     300: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     304: f9400063     	ldr	x3, [x3]
     308: aa1c03e0     	mov	x0, x28
     30c: f84603e2     	ldur	x2, [sp, #0x60]
     310: d63f0060     	blr	x3
     314: 35003ac0     	cbnz	w0, 0xa6c <___pl_fn_0+0xa6c>
     318: aa1c03e0     	mov	x0, x28
     31c: f9401802     	ldr	x2, [x0, #0x30]
     320: 34001ba2     	cbz	w2, 0x694 <___pl_fn_0+0x694>
     324: aa1c03e0     	mov	x0, x28
     328: f9400001     	ldr	x1, [x0]
     32c: 2a0203e0     	mov	w0, w2
     330: 8b000c20     	add	x0, x1, x0, lsl #3
     334: f9400803     	ldr	x3, [x0, #0x10]
     338: eb03029f     	cmp	x20, x3
     33c: 54001ac2     	b.hs	0x694 <___pl_fn_0+0x694>
     340: f9400c04     	ldr	x4, [x0, #0x18]
     344: eb04007f     	cmp	x3, x4
     348: 54000220     	b.eq	0x38c <___pl_fn_0+0x38c>
     34c: f9401007     	ldr	x7, [x0, #0x20]
     350: d346fe88     	lsr	x8, x20, #6
     354: 8b0800e7     	add	x7, x7, x8
     358: f8677828     	ldr	x8, [x1, x7, lsl #3]
     35c: 92401689     	and	x9, x20, #0x3f
     360: 9ac92269     	lsl	x9, x19, x9
     364: 8a09010a     	and	x10, x8, x9
     368: b500012a     	cbnz	x10, 0x38c <___pl_fn_0+0x38c>
     36c: aa090109     	orr	x9, x8, x9
     370: f8277829     	str	x9, [x1, x7, lsl #3]
     374: 9100048a     	add	x10, x4, #0x1
     378: f9000c0a     	str	x10, [x0, #0x18]
     37c: eb03015f     	cmp	x10, x3
     380: 54000061     	b.ne	0x38c <___pl_fn_0+0x38c>
     384: f84683e1     	ldur	x1, [sp, #0x68]
     388: f9001001     	str	x1, [x0, #0x20]
     38c: 8b140c00     	add	x0, x0, x20, lsl #3
     390: f9001419     	str	x25, [x0, #0x28]
     394: eb1302a2     	subs	x2, x21, x19
     398: 9a9f77e0     	cset	x0, vs
     39c: 72001c1f     	tst	w0, #0xff
     3a0: 54002661     	b.ne	0x86c <___pl_fn_0+0x86c>
     3a4: aa1c03e0     	mov	x0, x28
     3a8: b9401000     	ldr	w0, [x0, #0x10]
     3ac: aa1c03e1     	mov	x1, x28
     3b0: b9401421     	ldr	w1, [x1, #0x14]
     3b4: 6b01001f     	cmp	w0, w1
     3b8: 540023e2     	b.hs	0x834 <___pl_fn_0+0x834>
     3bc: aa1c03e0     	mov	x0, x28
     3c0: f84603e1     	ldur	x1, [sp, #0x60]
     3c4: 94000000     	bl	0x3c4 <___pl_fn_0+0x3c4>
     3c8: aa1c03e1     	mov	x1, x28
     3cc: b9402c21     	ldr	w1, [x1, #0x2c]
     3d0: 350034e1     	cbnz	w1, 0xa6c <___pl_fn_0+0xa6c>
     3d4: aa1b03f9     	mov	x25, x27
     3d8: ab000339     	adds	x25, x25, x0
     3dc: 9a9f77e0     	cset	x0, vs
     3e0: 72001c1f     	tst	w0, #0xff
     3e4: 540020c1     	b.ne	0x7fc <___pl_fn_0+0x7fc>
     3e8: 528002a1     	mov	w1, #0x15               ; =21
     3ec: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     3f0: f9400063     	ldr	x3, [x3]
     3f4: aa1c03e0     	mov	x0, x28
     3f8: f84603e2     	ldur	x2, [sp, #0x60]
     3fc: d63f0060     	blr	x3
     400: 35003360     	cbnz	w0, 0xa6c <___pl_fn_0+0xa6c>
     404: aa1c03e0     	mov	x0, x28
     408: f9401802     	ldr	x2, [x0, #0x30]
     40c: eb1302a0     	subs	x0, x21, x19
     410: 9a9f77e1     	cset	x1, vs
     414: 72001c3f     	tst	w1, #0xff
     418: 54001d61     	b.ne	0x7c4 <___pl_fn_0+0x7c4>
     41c: 34001502     	cbz	w2, 0x6bc <___pl_fn_0+0x6bc>
     420: aa1c03e1     	mov	x1, x28
     424: f9400021     	ldr	x1, [x1]
     428: 2a0203e3     	mov	w3, w2
     42c: 8b030c21     	add	x1, x1, x3, lsl #3
     430: f9400823     	ldr	x3, [x1, #0x10]
     434: eb03001f     	cmp	x0, x3
     438: 54001422     	b.hs	0x6bc <___pl_fn_0+0x6bc>
     43c: 8b000c24     	add	x4, x1, x0, lsl #3
     440: f940149a     	ldr	x26, [x4, #0x28]
     444: f9400c21     	ldr	x1, [x1, #0x18]
     448: eb01007f     	cmp	x3, x1
     44c: 54000080     	b.eq	0x45c <___pl_fn_0+0x45c>
     450: 1400009b     	b	0x6bc <___pl_fn_0+0x6bc>
     454: aa1c03e0     	mov	x0, x28
     458: f940181a     	ldr	x26, [x0, #0x30]
     45c: 52800301     	mov	w1, #0x18               ; =24
     460: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     464: f9400063     	ldr	x3, [x3]
     468: aa1c03e0     	mov	x0, x28
     46c: f84603e2     	ldur	x2, [sp, #0x60]
     470: d63f0060     	blr	x3
     474: 35002fc0     	cbnz	w0, 0xa6c <___pl_fn_0+0xa6c>
     478: aa1c03e0     	mov	x0, x28
     47c: f9401802     	ldr	x2, [x0, #0x30]
     480: 34001302     	cbz	w2, 0x6e0 <___pl_fn_0+0x6e0>
     484: aa1c03e0     	mov	x0, x28
     488: f9400000     	ldr	x0, [x0]
     48c: 2a0203e1     	mov	w1, w2
     490: 8b010c00     	add	x0, x0, x1, lsl #3
     494: f9400801     	ldr	x1, [x0, #0x10]
     498: eb01029f     	cmp	x20, x1
     49c: 54001222     	b.hs	0x6e0 <___pl_fn_0+0x6e0>
     4a0: 8b140c03     	add	x3, x0, x20, lsl #3
     4a4: f940147b     	ldr	x27, [x3, #0x28]
     4a8: f9400c00     	ldr	x0, [x0, #0x18]
     4ac: eb00003f     	cmp	x1, x0
     4b0: 54000080     	b.eq	0x4c0 <___pl_fn_0+0x4c0>
     4b4: 1400008b     	b	0x6e0 <___pl_fn_0+0x6e0>
     4b8: aa1c03e0     	mov	x0, x28
     4bc: f940181b     	ldr	x27, [x0, #0x30]
     4c0: 52800341     	mov	w1, #0x1a               ; =26
     4c4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     4c8: f9400063     	ldr	x3, [x3]
     4cc: aa1c03e0     	mov	x0, x28
     4d0: f84603e2     	ldur	x2, [sp, #0x60]
     4d4: d63f0060     	blr	x3
     4d8: 35002ca0     	cbnz	w0, 0xa6c <___pl_fn_0+0xa6c>
     4dc: aa1c03e0     	mov	x0, x28
     4e0: f9401802     	ldr	x2, [x0, #0x30]
     4e4: eb1302a0     	subs	x0, x21, x19
     4e8: 9a9f77e1     	cset	x1, vs
     4ec: 72001c3f     	tst	w1, #0xff
     4f0: 540014e1     	b.ne	0x78c <___pl_fn_0+0x78c>
     4f4: 34001082     	cbz	w2, 0x704 <___pl_fn_0+0x704>
     4f8: aa1c03e1     	mov	x1, x28
     4fc: f9400023     	ldr	x3, [x1]
     500: 2a0203e1     	mov	w1, w2
     504: 8b010c61     	add	x1, x3, x1, lsl #3
     508: f9400824     	ldr	x4, [x1, #0x10]
     50c: eb04001f     	cmp	x0, x4
     510: 54000fa2     	b.hs	0x704 <___pl_fn_0+0x704>
     514: f9400c29     	ldr	x9, [x1, #0x18]
     518: eb09009f     	cmp	x4, x9
     51c: 54000220     	b.eq	0x560 <___pl_fn_0+0x560>
     520: f940102c     	ldr	x12, [x1, #0x20]
     524: d346fc0d     	lsr	x13, x0, #6
     528: 8b0d018c     	add	x12, x12, x13
     52c: f86c786d     	ldr	x13, [x3, x12, lsl #3]
     530: 9240140e     	and	x14, x0, #0x3f
     534: 9ace226e     	lsl	x14, x19, x14
     538: 8a0e01af     	and	x15, x13, x14
     53c: b500012f     	cbnz	x15, 0x560 <___pl_fn_0+0x560>
     540: aa0e01ae     	orr	x14, x13, x14
     544: f82c786e     	str	x14, [x3, x12, lsl #3]
     548: 9100052f     	add	x15, x9, #0x1
     54c: f9000c2f     	str	x15, [x1, #0x18]
     550: eb0401ff     	cmp	x15, x4
     554: 54000061     	b.ne	0x560 <___pl_fn_0+0x560>
     558: f84683e2     	ldur	x2, [sp, #0x68]
     55c: f9001022     	str	x2, [x1, #0x20]
     560: 8b000c20     	add	x0, x1, x0, lsl #3
     564: f900141b     	str	x27, [x0, #0x28]
     568: 528003a1     	mov	w1, #0x1d               ; =29
     56c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     570: f9400063     	ldr	x3, [x3]
     574: aa1c03e0     	mov	x0, x28
     578: f84603e2     	ldur	x2, [sp, #0x60]
     57c: d63f0060     	blr	x3
     580: 35002760     	cbnz	w0, 0xa6c <___pl_fn_0+0xa6c>
     584: aa1c03e0     	mov	x0, x28
     588: f9401802     	ldr	x2, [x0, #0x30]
     58c: 34000d02     	cbz	w2, 0x72c <___pl_fn_0+0x72c>
     590: aa1c03e0     	mov	x0, x28
     594: f9400001     	ldr	x1, [x0]
     598: 2a0203e0     	mov	w0, w2
     59c: 8b000c20     	add	x0, x1, x0, lsl #3
     5a0: f9400803     	ldr	x3, [x0, #0x10]
     5a4: eb03029f     	cmp	x20, x3
     5a8: 54000c22     	b.hs	0x72c <___pl_fn_0+0x72c>
     5ac: f9400c02     	ldr	x2, [x0, #0x18]
     5b0: eb02007f     	cmp	x3, x2
     5b4: 54000220     	b.eq	0x5f8 <___pl_fn_0+0x5f8>
     5b8: f9401004     	ldr	x4, [x0, #0x20]
     5bc: d346fe85     	lsr	x5, x20, #6
     5c0: 8b050084     	add	x4, x4, x5
     5c4: f8647825     	ldr	x5, [x1, x4, lsl #3]
     5c8: 92401686     	and	x6, x20, #0x3f
     5cc: 9ac62266     	lsl	x6, x19, x6
     5d0: 8a0600a7     	and	x7, x5, x6
     5d4: b5000127     	cbnz	x7, 0x5f8 <___pl_fn_0+0x5f8>
     5d8: aa0600a5     	orr	x5, x5, x6
     5dc: f8247825     	str	x5, [x1, x4, lsl #3]
     5e0: 91000441     	add	x1, x2, #0x1
     5e4: f9000c01     	str	x1, [x0, #0x18]
     5e8: eb03003f     	cmp	x1, x3
     5ec: 54000061     	b.ne	0x5f8 <___pl_fn_0+0x5f8>
     5f0: f84683e1     	ldur	x1, [sp, #0x68]
     5f4: f9001001     	str	x1, [x0, #0x20]
     5f8: 8b140c00     	add	x0, x0, x20, lsl #3
     5fc: f900141a     	str	x26, [x0, #0x28]
     600: ab170294     	adds	x20, x20, x23
     604: 9a9f77e0     	cset	x0, vs
     608: 72001c1f     	tst	w0, #0xff
     60c: 54000a41     	b.ne	0x754 <___pl_fn_0+0x754>
     610: aa1803e0     	mov	x0, x24
     614: aa1803e1     	mov	x1, x24
     618: aa1803e2     	mov	x2, x24
     61c: aa1903fb     	mov	x27, x25
     620: 17fffebf     	b	0x11c <___pl_fn_0+0x11c>
     624: 910003e3     	mov	x3, sp
     628: f80003e0     	stur	x0, [sp]
     62c: 52800141     	mov	w1, #0xa                ; =10
     630: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     634: f9400108     	ldr	x8, [x8]
     638: aa1c03e0     	mov	x0, x28
     63c: d63f0100     	blr	x8
     640: 34ffdd40     	cbz	w0, 0x1e8 <___pl_fn_0+0x1e8>
     644: 1400010a     	b	0xa6c <___pl_fn_0+0xa6c>
     648: 910023e3     	add	x3, sp, #0x8
     64c: f80083f4     	stur	x20, [sp, #0x8]
     650: 52800181     	mov	w1, #0xc                ; =12
     654: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     658: f9400084     	ldr	x4, [x4]
     65c: aa1c03e0     	mov	x0, x28
     660: d63f0080     	blr	x4
     664: 34ffdf40     	cbz	w0, 0x24c <___pl_fn_0+0x24c>
     668: 14000101     	b	0xa6c <___pl_fn_0+0xa6c>
     66c: 910043e3     	add	x3, sp, #0x10
     670: f80103e0     	stur	x0, [sp, #0x10]
     674: f80183fa     	stur	x26, [sp, #0x18]
     678: 528001e1     	mov	w1, #0xf                ; =15
     67c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     680: f9400084     	ldr	x4, [x4]
     684: aa1c03e0     	mov	x0, x28
     688: d63f0080     	blr	x4
     68c: 34ffe380     	cbz	w0, 0x2fc <___pl_fn_0+0x2fc>
     690: 140000f7     	b	0xa6c <___pl_fn_0+0xa6c>
     694: 910083e3     	add	x3, sp, #0x20
     698: f80203f4     	stur	x20, [sp, #0x20]
     69c: f80283f9     	stur	x25, [sp, #0x28]
     6a0: 52800221     	mov	w1, #0x11               ; =17
     6a4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     6a8: f9400084     	ldr	x4, [x4]
     6ac: aa1c03e0     	mov	x0, x28
     6b0: d63f0080     	blr	x4
     6b4: 34ffe700     	cbz	w0, 0x394 <___pl_fn_0+0x394>
     6b8: 140000ed     	b	0xa6c <___pl_fn_0+0xa6c>
     6bc: 9100c3e3     	add	x3, sp, #0x30
     6c0: f80303e0     	stur	x0, [sp, #0x30]
     6c4: 528002e1     	mov	w1, #0x17               ; =23
     6c8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     6cc: f9400084     	ldr	x4, [x4]
     6d0: aa1c03e0     	mov	x0, x28
     6d4: d63f0080     	blr	x4
     6d8: 34ffebe0     	cbz	w0, 0x454 <___pl_fn_0+0x454>
     6dc: 140000e4     	b	0xa6c <___pl_fn_0+0xa6c>
     6e0: 9100e3e3     	add	x3, sp, #0x38
     6e4: f80383f4     	stur	x20, [sp, #0x38]
     6e8: 52800321     	mov	w1, #0x19               ; =25
     6ec: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     6f0: f9400084     	ldr	x4, [x4]
     6f4: aa1c03e0     	mov	x0, x28
     6f8: d63f0080     	blr	x4
     6fc: 34ffede0     	cbz	w0, 0x4b8 <___pl_fn_0+0x4b8>
     700: 140000db     	b	0xa6c <___pl_fn_0+0xa6c>
     704: 910103e3     	add	x3, sp, #0x40
     708: f80403e0     	stur	x0, [sp, #0x40]
     70c: f80483fb     	stur	x27, [sp, #0x48]
     710: 52800381     	mov	w1, #0x1c               ; =28
     714: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     718: f94000c6     	ldr	x6, [x6]
     71c: aa1c03e0     	mov	x0, x28
     720: d63f00c0     	blr	x6
     724: 34fff220     	cbz	w0, 0x568 <___pl_fn_0+0x568>
     728: 140000d1     	b	0xa6c <___pl_fn_0+0xa6c>
     72c: 910143e3     	add	x3, sp, #0x50
     730: f80503f4     	stur	x20, [sp, #0x50]
     734: f80583fa     	stur	x26, [sp, #0x58]
     738: 528003c1     	mov	w1, #0x1e               ; =30
     73c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     740: f9400084     	ldr	x4, [x4]
     744: aa1c03e0     	mov	x0, x28
     748: d63f0080     	blr	x4
     74c: 34fff5a0     	cbz	w0, 0x600 <___pl_fn_0+0x600>
     750: 140000c7     	b	0xa6c <___pl_fn_0+0xa6c>
     754: 528003e1     	mov	w1, #0x1f               ; =31
     758: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     75c: f9400042     	ldr	x2, [x2]
     760: aa1c03e0     	mov	x0, x28
     764: d63f0040     	blr	x2
     768: f84683e0     	ldur	x0, [sp, #0x68]
     76c: 9101c3ff     	add	sp, sp, #0x70
     770: a8c153f3     	ldp	x19, x20, [sp], #0x10
     774: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     778: a8c163f7     	ldp	x23, x24, [sp], #0x10
     77c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     780: a8c173fb     	ldp	x27, x28, [sp], #0x10
     784: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     788: d65f03c0     	ret
     78c: 52800361     	mov	w1, #0x1b               ; =27
     790: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     794: f9400042     	ldr	x2, [x2]
     798: aa1c03e0     	mov	x0, x28
     79c: d63f0040     	blr	x2
     7a0: f84683e0     	ldur	x0, [sp, #0x68]
     7a4: 9101c3ff     	add	sp, sp, #0x70
     7a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7b0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7b4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7b8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     7bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7c0: d65f03c0     	ret
     7c4: 528002c1     	mov	w1, #0x16               ; =22
     7c8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7cc: f9400042     	ldr	x2, [x2]
     7d0: aa1c03e0     	mov	x0, x28
     7d4: d63f0040     	blr	x2
     7d8: f84683e0     	ldur	x0, [sp, #0x68]
     7dc: 9101c3ff     	add	sp, sp, #0x70
     7e0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7e4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7e8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7ec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7f0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     7f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7f8: d65f03c0     	ret
     7fc: 52800281     	mov	w1, #0x14               ; =20
     800: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     804: f9400042     	ldr	x2, [x2]
     808: aa1c03e0     	mov	x0, x28
     80c: d63f0040     	blr	x2
     810: f84683e0     	ldur	x0, [sp, #0x68]
     814: 9101c3ff     	add	sp, sp, #0x70
     818: a8c153f3     	ldp	x19, x20, [sp], #0x10
     81c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     820: a8c163f7     	ldp	x23, x24, [sp], #0x10
     824: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     828: a8c173fb     	ldp	x27, x28, [sp], #0x10
     82c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     830: d65f03c0     	ret
     834: 52800261     	mov	w1, #0x13               ; =19
     838: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     83c: f9400042     	ldr	x2, [x2]
     840: aa1c03e0     	mov	x0, x28
     844: d63f0040     	blr	x2
     848: f84683e0     	ldur	x0, [sp, #0x68]
     84c: 9101c3ff     	add	sp, sp, #0x70
     850: a8c153f3     	ldp	x19, x20, [sp], #0x10
     854: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     858: a8c163f7     	ldp	x23, x24, [sp], #0x10
     85c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     860: a8c173fb     	ldp	x27, x28, [sp], #0x10
     864: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     868: d65f03c0     	ret
     86c: 52800241     	mov	w1, #0x12               ; =18
     870: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     874: f9400042     	ldr	x2, [x2]
     878: aa1c03e0     	mov	x0, x28
     87c: d63f0040     	blr	x2
     880: f84683e0     	ldur	x0, [sp, #0x68]
     884: 9101c3ff     	add	sp, sp, #0x70
     888: a8c153f3     	ldp	x19, x20, [sp], #0x10
     88c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     890: a8c163f7     	ldp	x23, x24, [sp], #0x10
     894: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     898: a8c173fb     	ldp	x27, x28, [sp], #0x10
     89c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8a0: d65f03c0     	ret
     8a4: 528001c1     	mov	w1, #0xe                ; =14
     8a8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     8ac: f9400042     	ldr	x2, [x2]
     8b0: aa1c03e0     	mov	x0, x28
     8b4: d63f0040     	blr	x2
     8b8: f84683e0     	ldur	x0, [sp, #0x68]
     8bc: 9101c3ff     	add	sp, sp, #0x70
     8c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8c4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8c8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8cc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8d0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     8d4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8d8: d65f03c0     	ret
     8dc: 52800121     	mov	w1, #0x9                ; =9
     8e0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     8e4: f9400042     	ldr	x2, [x2]
     8e8: aa1c03e0     	mov	x0, x28
     8ec: d63f0040     	blr	x2
     8f0: f84683e0     	ldur	x0, [sp, #0x68]
     8f4: 9101c3ff     	add	sp, sp, #0x70
     8f8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8fc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     900: a8c163f7     	ldp	x23, x24, [sp], #0x10
     904: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     908: a8c173fb     	ldp	x27, x28, [sp], #0x10
     90c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     910: d65f03c0     	ret
     914: 528000e1     	mov	w1, #0x7                ; =7
     918: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     91c: f9400042     	ldr	x2, [x2]
     920: aa1c03e0     	mov	x0, x28
     924: d63f0040     	blr	x2
     928: f84683e0     	ldur	x0, [sp, #0x68]
     92c: 9101c3ff     	add	sp, sp, #0x70
     930: a8c153f3     	ldp	x19, x20, [sp], #0x10
     934: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     938: a8c163f7     	ldp	x23, x24, [sp], #0x10
     93c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     940: a8c173fb     	ldp	x27, x28, [sp], #0x10
     944: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     948: d65f03c0     	ret
     94c: 528000c1     	mov	w1, #0x6                ; =6
     950: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     954: f9400042     	ldr	x2, [x2]
     958: aa1c03e0     	mov	x0, x28
     95c: d63f0040     	blr	x2
     960: f84683e0     	ldur	x0, [sp, #0x68]
     964: 9101c3ff     	add	sp, sp, #0x70
     968: a8c153f3     	ldp	x19, x20, [sp], #0x10
     96c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     970: a8c163f7     	ldp	x23, x24, [sp], #0x10
     974: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     978: a8c173fb     	ldp	x27, x28, [sp], #0x10
     97c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     980: d65f03c0     	ret
     984: f80683e0     	stur	x0, [sp, #0x68]
     988: 528000a1     	mov	w1, #0x5                ; =5
     98c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     990: f9400042     	ldr	x2, [x2]
     994: aa1c03e0     	mov	x0, x28
     998: d63f0040     	blr	x2
     99c: f84683e0     	ldur	x0, [sp, #0x68]
     9a0: 9101c3ff     	add	sp, sp, #0x70
     9a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9a8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9ac: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9b0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9b4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9bc: d65f03c0     	ret
     9c0: f80683e0     	stur	x0, [sp, #0x68]
     9c4: 52800081     	mov	w1, #0x4                ; =4
     9c8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9cc: f9400042     	ldr	x2, [x2]
     9d0: aa1c03e0     	mov	x0, x28
     9d4: d63f0040     	blr	x2
     9d8: f84683e0     	ldur	x0, [sp, #0x68]
     9dc: 9101c3ff     	add	sp, sp, #0x70
     9e0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9e4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9e8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9ec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9f0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9f8: d65f03c0     	ret
     9fc: 52800061     	mov	w1, #0x3                ; =3
     a00: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a04: f9400042     	ldr	x2, [x2]
     a08: aa1c03e0     	mov	x0, x28
     a0c: d63f0040     	blr	x2
     a10: d2800000     	mov	x0, #0x0                ; =0
     a14: 9101c3ff     	add	sp, sp, #0x70
     a18: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a1c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a20: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a24: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a28: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a2c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a30: d65f03c0     	ret
     a34: 52800041     	mov	w1, #0x2                ; =2
     a38: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     a3c: f9400042     	ldr	x2, [x2]
     a40: aa1c03e0     	mov	x0, x28
     a44: d63f0040     	blr	x2
     a48: d2800000     	mov	x0, #0x0                ; =0
     a4c: 9101c3ff     	add	sp, sp, #0x70
     a50: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a54: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a58: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a5c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a60: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a68: d65f03c0     	ret
     a6c: d2800000     	mov	x0, #0x0                ; =0
     a70: 9101c3ff     	add	sp, sp, #0x70
     a74: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a78: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a7c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a80: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a84: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a88: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a8c: d65f03c0     	ret
     a90: 52800021     	mov	w1, #0x1                ; =1
     a94: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     a98: f9400084     	ldr	x4, [x4]
     a9c: aa1c03e0     	mov	x0, x28
     aa0: d63f0080     	blr	x4
     aa4: d2800000     	mov	x0, #0x0                ; =0
     aa8: 9101c3ff     	add	sp, sp, #0x70
     aac: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ab0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ab4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ab8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     abc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     ac0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ac4: d65f03c0     	ret
     ac8: aa0003fc     	mov	x28, x0
     acc: 52800001     	mov	w1, #0x0                ; =0
     ad0: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     ad4: f94000a5     	ldr	x5, [x5]
     ad8: d63f00a0     	blr	x5
     adc: d2800000     	mov	x0, #0x0                ; =0
     ae0: 9101c3ff     	add	sp, sp, #0x70
     ae4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ae8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     aec: a8c163f7     	ldp	x23, x24, [sp], #0x10
     af0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     af4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     af8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     afc: d65f03c0     	ret

0000000000000b00 <___pl_fn_1>:
     b00: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     b04: 910003fd     	mov	x29, sp
     b08: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     b0c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     b10: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     b14: d10083ff     	sub	sp, sp, #0x20
     b18: b9401001     	ldr	w1, [x0, #0x10]
     b1c: 11000421     	add	w1, w1, #0x1
     b20: b9001001     	str	w1, [x0, #0x10]
     b24: aa0003f6     	mov	x22, x0
     b28: d2800140     	mov	x0, #0xa                ; =10
     b2c: 910003e3     	mov	x3, sp
     b30: f80003e0     	stur	x0, [sp]
     b34: 52800401     	mov	w1, #0x20               ; =32
     b38: 52802002     	mov	w2, #0x100              ; =256
     b3c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b40: f9400084     	ldr	x4, [x4]
     b44: aa1603e0     	mov	x0, x22
     b48: d63f0080     	blr	x4
     b4c: 350018c0     	cbnz	w0, 0xe64 <___pl_fn_1+0x364>
     b50: aa1603e0     	mov	x0, x22
     b54: f9401813     	ldr	x19, [x0, #0x30]
     b58: 52800421     	mov	w1, #0x21               ; =33
     b5c: 52800082     	mov	w2, #0x4                ; =4
     b60: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b64: f9400063     	ldr	x3, [x3]
     b68: d63f0060     	blr	x3
     b6c: 350017c0     	cbnz	w0, 0xe64 <___pl_fn_1+0x364>
     b70: aa1603e0     	mov	x0, x22
     b74: f9401814     	ldr	x20, [x0, #0x30]
     b78: 52800441     	mov	w1, #0x22               ; =34
     b7c: 2a1303e3     	mov	w3, w19
     b80: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b84: f9400084     	ldr	x4, [x4]
     b88: aa1403e2     	mov	x2, x20
     b8c: d63f0080     	blr	x4
     b90: aa1403f7     	mov	x23, x20
     b94: 35001680     	cbnz	w0, 0xe64 <___pl_fn_1+0x364>
     b98: 52800461     	mov	w1, #0x23               ; =35
     b9c: 52800002     	mov	w2, #0x0                ; =0
     ba0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     ba4: f9400063     	ldr	x3, [x3]
     ba8: aa1603e0     	mov	x0, x22
     bac: d63f0060     	blr	x3
     bb0: 350015a0     	cbnz	w0, 0xe64 <___pl_fn_1+0x364>
     bb4: aa1603e0     	mov	x0, x22
     bb8: f9401802     	ldr	x2, [x0, #0x30]
     bbc: aa0203f8     	mov	x24, x2
     bc0: d2800120     	mov	x0, #0x9                ; =9
     bc4: d2800001     	mov	x1, #0x0                ; =0
     bc8: ab010013     	adds	x19, x0, x1
     bcc: 9a9f77e0     	cset	x0, vs
     bd0: 72001c1f     	tst	w0, #0xff
     bd4: 54001321     	b.ne	0xe38 <___pl_fn_1+0x338>
     bd8: d2800020     	mov	x0, #0x1                ; =1
     bdc: d2800001     	mov	x1, #0x0                ; =0
     be0: ab010014     	adds	x20, x0, x1
     be4: 9a9f77e0     	cset	x0, vs
     be8: 72001c1f     	tst	w0, #0xff
     bec: 54001101     	b.ne	0xe0c <___pl_fn_1+0x30c>
     bf0: b4000f94     	cbz	x20, 0xde0 <___pl_fn_1+0x2e0>
     bf4: d2800015     	mov	x21, #0x0               ; =0
     bf8: 52800020     	mov	w0, #0x1                ; =1
     bfc: f100029f     	cmp	x20, #0x0
     c00: 5400008a     	b.ge	0xc10 <___pl_fn_1+0x110>
     c04: eb1302bf     	cmp	x21, x19
     c08: 9a9fb7e0     	cset	x0, ge
     c0c: 14000003     	b	0xc18 <___pl_fn_1+0x118>
     c10: eb1302bf     	cmp	x21, x19
     c14: 9a9fc7e0     	cset	x0, le
     c18: 72001c1f     	tst	w0, #0xff
     c1c: 54000421     	b.ne	0xca0 <___pl_fn_1+0x1a0>
     c20: aa1603e0     	mov	x0, x22
     c24: b9401000     	ldr	w0, [x0, #0x10]
     c28: aa1603e1     	mov	x1, x22
     c2c: b9401421     	ldr	w1, [x1, #0x14]
     c30: 6b01001f     	cmp	w0, w1
     c34: 54000922     	b.hs	0xd58 <___pl_fn_1+0x258>
     c38: aa1703e1     	mov	x1, x23
     c3c: aa1803e2     	mov	x2, x24
     c40: aa1603e0     	mov	x0, x22
     c44: 94000000     	bl	0xc44 <___pl_fn_1+0x144>
     c48: aa0003e2     	mov	x2, x0
     c4c: aa1603e0     	mov	x0, x22
     c50: b9402c00     	ldr	w0, [x0, #0x2c]
     c54: 35001080     	cbnz	w0, 0xe64 <___pl_fn_1+0x364>
     c58: 52800501     	mov	w1, #0x28               ; =40
     c5c: 52802003     	mov	w3, #0x100              ; =256
     c60: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c64: f9400084     	ldr	x4, [x4]
     c68: aa1603e0     	mov	x0, x22
     c6c: d63f0080     	blr	x4
     c70: 35000fa0     	cbnz	w0, 0xe64 <___pl_fn_1+0x364>
     c74: aa1603e0     	mov	x0, x22
     c78: b9401000     	ldr	w0, [x0, #0x10]
     c7c: 51000400     	sub	w0, w0, #0x1
     c80: aa1603e1     	mov	x1, x22
     c84: b9001020     	str	w0, [x1, #0x10]
     c88: 910083ff     	add	sp, sp, #0x20
     c8c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c90: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c94: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c98: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c9c: d65f03c0     	ret
     ca0: 52800521     	mov	w1, #0x29               ; =41
     ca4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     ca8: f9400063     	ldr	x3, [x3]
     cac: aa1603e0     	mov	x0, x22
     cb0: aa1703e2     	mov	x2, x23
     cb4: d63f0060     	blr	x3
     cb8: 35000d60     	cbnz	w0, 0xe64 <___pl_fn_1+0x364>
     cbc: aa1603e0     	mov	x0, x22
     cc0: f9401802     	ldr	x2, [x0, #0x30]
     cc4: 34000622     	cbz	w2, 0xd88 <___pl_fn_1+0x288>
     cc8: aa1603e0     	mov	x0, x22
     ccc: f9400007     	ldr	x7, [x0]
     cd0: 2a0203e6     	mov	w6, w2
     cd4: 8b060ce6     	add	x6, x7, x6, lsl #3
     cd8: f94008c8     	ldr	x8, [x6, #0x10]
     cdc: eb0802bf     	cmp	x21, x8
     ce0: 54000542     	b.hs	0xd88 <___pl_fn_1+0x288>
     ce4: f9400cce     	ldr	x14, [x6, #0x18]
     ce8: eb0e011f     	cmp	x8, x14
     cec: 54000240     	b.eq	0xd34 <___pl_fn_1+0x234>
     cf0: f94010c0     	ldr	x0, [x6, #0x20]
     cf4: d346fea1     	lsr	x1, x21, #6
     cf8: 8b010000     	add	x0, x0, x1
     cfc: f86078e1     	ldr	x1, [x7, x0, lsl #3]
     d00: 924016a2     	and	x2, x21, #0x3f
     d04: d2800023     	mov	x3, #0x1                ; =1
     d08: 9ac22062     	lsl	x2, x3, x2
     d0c: 8a020023     	and	x3, x1, x2
     d10: b5000123     	cbnz	x3, 0xd34 <___pl_fn_1+0x234>
     d14: aa020021     	orr	x1, x1, x2
     d18: f82078e1     	str	x1, [x7, x0, lsl #3]
     d1c: 910005c0     	add	x0, x14, #0x1
     d20: f9000cc0     	str	x0, [x6, #0x18]
     d24: eb08001f     	cmp	x0, x8
     d28: 54000061     	b.ne	0xd34 <___pl_fn_1+0x234>
     d2c: d2800000     	mov	x0, #0x0                ; =0
     d30: f90010c0     	str	x0, [x6, #0x20]
     d34: d2800000     	mov	x0, #0x0                ; =0
     d38: 8b150cc1     	add	x1, x6, x21, lsl #3
     d3c: f9001420     	str	x0, [x1, #0x28]
     d40: ab1402b5     	adds	x21, x21, x20
     d44: 9a9f77e0     	cset	x0, vs
     d48: 72001c1f     	tst	w0, #0xff
     d4c: 54000341     	b.ne	0xdb4 <___pl_fn_1+0x2b4>
     d50: 52800020     	mov	w0, #0x1                ; =1
     d54: 17ffffaa     	b	0xbfc <___pl_fn_1+0xfc>
     d58: 528004e1     	mov	w1, #0x27               ; =39
     d5c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     d60: f9400042     	ldr	x2, [x2]
     d64: aa1603e0     	mov	x0, x22
     d68: d63f0040     	blr	x2
     d6c: 910083ff     	add	sp, sp, #0x20
     d70: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d74: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d78: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d7c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d80: d65f03c0     	ret
     d84: 14000038     	b	0xe64 <___pl_fn_1+0x364>
     d88: 910023e3     	add	x3, sp, #0x8
     d8c: f80083f5     	stur	x21, [sp, #0x8]
     d90: d280000a     	mov	x10, #0x0               ; =0
     d94: f80103ea     	stur	x10, [sp, #0x10]
     d98: 52800541     	mov	w1, #0x2a               ; =42
     d9c: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     da0: f940016b     	ldr	x11, [x11]
     da4: aa1603e0     	mov	x0, x22
     da8: d63f0160     	blr	x11
     dac: 34fffca0     	cbz	w0, 0xd40 <___pl_fn_1+0x240>
     db0: 1400002d     	b	0xe64 <___pl_fn_1+0x364>
     db4: 52800561     	mov	w1, #0x2b               ; =43
     db8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     dbc: f9400042     	ldr	x2, [x2]
     dc0: aa1603e0     	mov	x0, x22
     dc4: d63f0040     	blr	x2
     dc8: 910083ff     	add	sp, sp, #0x20
     dcc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     dd0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     dd4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     dd8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ddc: d65f03c0     	ret
     de0: 528004c1     	mov	w1, #0x26               ; =38
     de4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     de8: f9400042     	ldr	x2, [x2]
     dec: aa1603e0     	mov	x0, x22
     df0: d63f0040     	blr	x2
     df4: 910083ff     	add	sp, sp, #0x20
     df8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     dfc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e00: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e04: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e08: d65f03c0     	ret
     e0c: 528004a1     	mov	w1, #0x25               ; =37
     e10: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e14: f9400042     	ldr	x2, [x2]
     e18: aa1603e0     	mov	x0, x22
     e1c: d63f0040     	blr	x2
     e20: 910083ff     	add	sp, sp, #0x20
     e24: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e28: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e2c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e34: d65f03c0     	ret
     e38: 52800481     	mov	w1, #0x24               ; =36
     e3c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e40: f9400042     	ldr	x2, [x2]
     e44: aa1603e0     	mov	x0, x22
     e48: d63f0040     	blr	x2
     e4c: 910083ff     	add	sp, sp, #0x20
     e50: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e54: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e58: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e5c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e60: d65f03c0     	ret
     e64: 910083ff     	add	sp, sp, #0x20
     e68: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e6c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e70: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e74: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e78: d65f03c0     	ret
