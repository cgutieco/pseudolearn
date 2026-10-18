
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_diagnostic_32669/permute/program.o:	file format mach-o arm64

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
     b08: f81f0ff9     	str	x25, [sp, #-0x10]!
     b0c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     b10: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     b14: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     b18: d10083ff     	sub	sp, sp, #0x20
     b1c: b9401001     	ldr	w1, [x0, #0x10]
     b20: 11000421     	add	w1, w1, #0x1
     b24: b9001001     	str	w1, [x0, #0x10]
     b28: aa0003f6     	mov	x22, x0
     b2c: 52800401     	mov	w1, #0x20               ; =32
     b30: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b34: f9400042     	ldr	x2, [x2]
     b38: d63f0040     	blr	x2
     b3c: 35001bc0     	cbnz	w0, 0xeb4 <___pl_fn_1+0x3b4>
     b40: aa1603e0     	mov	x0, x22
     b44: f9401802     	ldr	x2, [x0, #0x30]
     b48: aa0203f7     	mov	x23, x2
     b4c: d2800140     	mov	x0, #0xa                ; =10
     b50: 910003e3     	mov	x3, sp
     b54: f80003e0     	stur	x0, [sp]
     b58: 52800421     	mov	w1, #0x21               ; =33
     b5c: 52802002     	mov	w2, #0x100              ; =256
     b60: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b64: f9400084     	ldr	x4, [x4]
     b68: aa1603e0     	mov	x0, x22
     b6c: d63f0080     	blr	x4
     b70: 35001a20     	cbnz	w0, 0xeb4 <___pl_fn_1+0x3b4>
     b74: aa1603e0     	mov	x0, x22
     b78: f9401813     	ldr	x19, [x0, #0x30]
     b7c: 52800441     	mov	w1, #0x22               ; =34
     b80: 52800082     	mov	w2, #0x4                ; =4
     b84: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b88: f9400063     	ldr	x3, [x3]
     b8c: d63f0060     	blr	x3
     b90: 35001920     	cbnz	w0, 0xeb4 <___pl_fn_1+0x3b4>
     b94: aa1603e0     	mov	x0, x22
     b98: f9401814     	ldr	x20, [x0, #0x30]
     b9c: 52800461     	mov	w1, #0x23               ; =35
     ba0: 2a1303e3     	mov	w3, w19
     ba4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     ba8: f9400084     	ldr	x4, [x4]
     bac: aa1403e2     	mov	x2, x20
     bb0: d63f0080     	blr	x4
     bb4: aa1403f8     	mov	x24, x20
     bb8: 350017e0     	cbnz	w0, 0xeb4 <___pl_fn_1+0x3b4>
     bbc: 52800481     	mov	w1, #0x24               ; =36
     bc0: 52800002     	mov	w2, #0x0                ; =0
     bc4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     bc8: f9400063     	ldr	x3, [x3]
     bcc: aa1603e0     	mov	x0, x22
     bd0: d63f0060     	blr	x3
     bd4: 35001700     	cbnz	w0, 0xeb4 <___pl_fn_1+0x3b4>
     bd8: aa1603e0     	mov	x0, x22
     bdc: f9401802     	ldr	x2, [x0, #0x30]
     be0: aa0203f9     	mov	x25, x2
     be4: d2800120     	mov	x0, #0x9                ; =9
     be8: d2800001     	mov	x1, #0x0                ; =0
     bec: ab010013     	adds	x19, x0, x1
     bf0: 9a9f77e0     	cset	x0, vs
     bf4: 72001c1f     	tst	w0, #0xff
     bf8: 54001461     	b.ne	0xe84 <___pl_fn_1+0x384>
     bfc: d2800020     	mov	x0, #0x1                ; =1
     c00: d2800001     	mov	x1, #0x0                ; =0
     c04: ab010014     	adds	x20, x0, x1
     c08: 9a9f77e0     	cset	x0, vs
     c0c: 72001c1f     	tst	w0, #0xff
     c10: 54001221     	b.ne	0xe54 <___pl_fn_1+0x354>
     c14: b4001094     	cbz	x20, 0xe24 <___pl_fn_1+0x324>
     c18: d2800015     	mov	x21, #0x0               ; =0
     c1c: 52800020     	mov	w0, #0x1                ; =1
     c20: f100029f     	cmp	x20, #0x0
     c24: 5400008a     	b.ge	0xc34 <___pl_fn_1+0x134>
     c28: eb1302bf     	cmp	x21, x19
     c2c: 9a9fb7e0     	cset	x0, ge
     c30: 14000003     	b	0xc3c <___pl_fn_1+0x13c>
     c34: eb1302bf     	cmp	x21, x19
     c38: 9a9fc7e0     	cset	x0, le
     c3c: 72001c1f     	tst	w0, #0xff
     c40: 540004e1     	b.ne	0xcdc <___pl_fn_1+0x1dc>
     c44: aa1603e0     	mov	x0, x22
     c48: b9401002     	ldr	w2, [x0, #0x10]
     c4c: b9401403     	ldr	w3, [x0, #0x14]
     c50: 6b03005f     	cmp	w2, w3
     c54: 54000a02     	b.hs	0xd94 <___pl_fn_1+0x294>
     c58: aa1803e1     	mov	x1, x24
     c5c: aa1903e2     	mov	x2, x25
     c60: aa1603e0     	mov	x0, x22
     c64: 94000000     	bl	0xc64 <___pl_fn_1+0x164>
     c68: aa0003e2     	mov	x2, x0
     c6c: aa1603e0     	mov	x0, x22
     c70: b9402c04     	ldr	w4, [x0, #0x2c]
     c74: 35001204     	cbnz	w4, 0xeb4 <___pl_fn_1+0x3b4>
     c78: 52800521     	mov	w1, #0x29               ; =41
     c7c: 52802003     	mov	w3, #0x100              ; =256
     c80: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     c84: f94000c6     	ldr	x6, [x6]
     c88: aa1603e0     	mov	x0, x22
     c8c: d63f00c0     	blr	x6
     c90: 35001120     	cbnz	w0, 0xeb4 <___pl_fn_1+0x3b4>
     c94: 52800541     	mov	w1, #0x2a               ; =42
     c98: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     c9c: f9400108     	ldr	x8, [x8]
     ca0: aa1703e2     	mov	x2, x23
     ca4: aa1603e0     	mov	x0, x22
     ca8: d63f0100     	blr	x8
     cac: 35001040     	cbnz	w0, 0xeb4 <___pl_fn_1+0x3b4>
     cb0: aa1603e0     	mov	x0, x22
     cb4: b940100a     	ldr	w10, [x0, #0x10]
     cb8: 5100054a     	sub	w10, w10, #0x1
     cbc: b900100a     	str	w10, [x0, #0x10]
     cc0: 910083ff     	add	sp, sp, #0x20
     cc4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     cc8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ccc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     cd0: f84107f9     	ldr	x25, [sp], #0x10
     cd4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     cd8: d65f03c0     	ret
     cdc: 52800561     	mov	w1, #0x2b               ; =43
     ce0: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     ce4: f94001ad     	ldr	x13, [x13]
     ce8: aa1603e0     	mov	x0, x22
     cec: aa1803e2     	mov	x2, x24
     cf0: d63f01a0     	blr	x13
     cf4: 35000e00     	cbnz	w0, 0xeb4 <___pl_fn_1+0x3b4>
     cf8: aa1603e0     	mov	x0, x22
     cfc: f9401802     	ldr	x2, [x0, #0x30]
     d00: 34000642     	cbz	w2, 0xdc8 <___pl_fn_1+0x2c8>
     d04: aa1603e0     	mov	x0, x22
     d08: f9400001     	ldr	x1, [x0]
     d0c: 2a0203e0     	mov	w0, w2
     d10: 8b000c20     	add	x0, x1, x0, lsl #3
     d14: f9400803     	ldr	x3, [x0, #0x10]
     d18: eb0302bf     	cmp	x21, x3
     d1c: 54000562     	b.hs	0xdc8 <___pl_fn_1+0x2c8>
     d20: f9400c02     	ldr	x2, [x0, #0x18]
     d24: eb02007f     	cmp	x3, x2
     d28: 54000240     	b.eq	0xd70 <___pl_fn_1+0x270>
     d2c: f9401004     	ldr	x4, [x0, #0x20]
     d30: d346fea5     	lsr	x5, x21, #6
     d34: 8b050084     	add	x4, x4, x5
     d38: f8647825     	ldr	x5, [x1, x4, lsl #3]
     d3c: 924016a6     	and	x6, x21, #0x3f
     d40: d2800027     	mov	x7, #0x1                ; =1
     d44: 9ac620e6     	lsl	x6, x7, x6
     d48: 8a0600a7     	and	x7, x5, x6
     d4c: b5000127     	cbnz	x7, 0xd70 <___pl_fn_1+0x270>
     d50: aa0600a5     	orr	x5, x5, x6
     d54: f8247825     	str	x5, [x1, x4, lsl #3]
     d58: 91000441     	add	x1, x2, #0x1
     d5c: f9000c01     	str	x1, [x0, #0x18]
     d60: eb03003f     	cmp	x1, x3
     d64: 54000061     	b.ne	0xd70 <___pl_fn_1+0x270>
     d68: d2800001     	mov	x1, #0x0                ; =0
     d6c: f9001001     	str	x1, [x0, #0x20]
     d70: d2800001     	mov	x1, #0x0                ; =0
     d74: 8b150c00     	add	x0, x0, x21, lsl #3
     d78: f9001401     	str	x1, [x0, #0x28]
     d7c: ab1402b5     	adds	x21, x21, x20
     d80: 9a9f77e0     	cset	x0, vs
     d84: 72001c1f     	tst	w0, #0xff
     d88: 54000361     	b.ne	0xdf4 <___pl_fn_1+0x2f4>
     d8c: 52800020     	mov	w0, #0x1                ; =1
     d90: 17ffffa4     	b	0xc20 <___pl_fn_1+0x120>
     d94: 52800501     	mov	w1, #0x28               ; =40
     d98: 9000000c     	adrp	x12, 0x0 <___pl_fn_0>
     d9c: f940018c     	ldr	x12, [x12]
     da0: aa1603e0     	mov	x0, x22
     da4: d63f0180     	blr	x12
     da8: 910083ff     	add	sp, sp, #0x20
     dac: a8c153f3     	ldp	x19, x20, [sp], #0x10
     db0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     db4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     db8: f84107f9     	ldr	x25, [sp], #0x10
     dbc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     dc0: d65f03c0     	ret
     dc4: 1400003c     	b	0xeb4 <___pl_fn_1+0x3b4>
     dc8: 910023e3     	add	x3, sp, #0x8
     dcc: f80083f5     	stur	x21, [sp, #0x8]
     dd0: d2800000     	mov	x0, #0x0                ; =0
     dd4: f80103e0     	stur	x0, [sp, #0x10]
     dd8: 52800581     	mov	w1, #0x2c               ; =44
     ddc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     de0: f9400084     	ldr	x4, [x4]
     de4: aa1603e0     	mov	x0, x22
     de8: d63f0080     	blr	x4
     dec: 34fffc80     	cbz	w0, 0xd7c <___pl_fn_1+0x27c>
     df0: 14000031     	b	0xeb4 <___pl_fn_1+0x3b4>
     df4: 528005a1     	mov	w1, #0x2d               ; =45
     df8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     dfc: f9400042     	ldr	x2, [x2]
     e00: aa1603e0     	mov	x0, x22
     e04: d63f0040     	blr	x2
     e08: 910083ff     	add	sp, sp, #0x20
     e0c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e10: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e14: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e18: f84107f9     	ldr	x25, [sp], #0x10
     e1c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e20: d65f03c0     	ret
     e24: 528004e1     	mov	w1, #0x27               ; =39
     e28: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e2c: f9400042     	ldr	x2, [x2]
     e30: aa1603e0     	mov	x0, x22
     e34: d63f0040     	blr	x2
     e38: 910083ff     	add	sp, sp, #0x20
     e3c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e40: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e44: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e48: f84107f9     	ldr	x25, [sp], #0x10
     e4c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e50: d65f03c0     	ret
     e54: 528004c1     	mov	w1, #0x26               ; =38
     e58: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e5c: f9400042     	ldr	x2, [x2]
     e60: aa1603e0     	mov	x0, x22
     e64: d63f0040     	blr	x2
     e68: 910083ff     	add	sp, sp, #0x20
     e6c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     e70: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     e74: a8c163f7     	ldp	x23, x24, [sp], #0x10
     e78: f84107f9     	ldr	x25, [sp], #0x10
     e7c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     e80: d65f03c0     	ret
     e84: 528004a1     	mov	w1, #0x25               ; =37
     e88: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     e8c: f9400042     	ldr	x2, [x2]
     e90: aa1603e0     	mov	x0, x22
     e94: d63f0040     	blr	x2
     e98: 910083ff     	add	sp, sp, #0x20
     e9c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ea0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ea4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ea8: f84107f9     	ldr	x25, [sp], #0x10
     eac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     eb0: d65f03c0     	ret
     eb4: 910083ff     	add	sp, sp, #0x20
     eb8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ebc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ec0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ec4: f84107f9     	ldr	x25, [sp], #0x10
     ec8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ecc: d65f03c0     	ret
