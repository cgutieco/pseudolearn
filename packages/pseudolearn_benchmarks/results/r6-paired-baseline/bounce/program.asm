
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_76447/bounce/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: b940100b     	ldr	w11, [x0, #0x10]
       c: 1100056c     	add	w12, w11, #0x1
      10: b900100c     	str	w12, [x0, #0x10]
      14: f100003f     	cmp	x1, #0x0
      18: aa0103ec     	mov	x12, x1
      1c: 540000ab     	b.lt	0x30 <___pl_fn_0+0x30>
      20: b900100b     	str	w11, [x0, #0x10]
      24: aa0c03e0     	mov	x0, x12
      28: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      2c: d65f03c0     	ret
      30: aa0003ee     	mov	x14, x0
      34: aa0c03e0     	mov	x0, x12
      38: d2800001     	mov	x1, #0x0                ; =0
      3c: eb000021     	subs	x1, x1, x0
      40: 9a9f77e0     	cset	x0, vs
      44: 72001c1f     	tst	w0, #0xff
      48: 540000c1     	b.ne	0x60 <___pl_fn_0+0x60>
      4c: aa0e03e0     	mov	x0, x14
      50: b900100b     	str	w11, [x0, #0x10]
      54: aa0103e0     	mov	x0, x1
      58: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      5c: d65f03c0     	ret
      60: aa0e03e0     	mov	x0, x14
      64: 52800001     	mov	w1, #0x0                ; =0
      68: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
      6c: f9400042     	ldr	x2, [x2]
      70: d63f0040     	blr	x2
      74: d2800000     	mov	x0, #0x0                ; =0
      78: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      7c: d65f03c0     	ret

0000000000000080 <___pl_fn_1>:
      80: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
      84: 910003fd     	mov	x29, sp
      88: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
      8c: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
      90: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      94: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      98: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      9c: d10103ff     	sub	sp, sp, #0x40
      a0: b9401001     	ldr	w1, [x0, #0x10]
      a4: 11000421     	add	w1, w1, #0x1
      a8: b9001001     	str	w1, [x0, #0x10]
      ac: f80303e0     	stur	x0, [sp, #0x30]
      b0: d2800c80     	mov	x0, #0x64               ; =100
      b4: 910003e3     	mov	x3, sp
      b8: f80003e0     	stur	x0, [sp]
      bc: 52800021     	mov	w1, #0x1                ; =1
      c0: 52802082     	mov	w2, #0x104              ; =260
      c4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      c8: f9400084     	ldr	x4, [x4]
      cc: f84303e0     	ldur	x0, [sp, #0x30]
      d0: d63f0080     	blr	x4
      d4: 350049c0     	cbnz	w0, 0xa0c <___pl_fn_1+0x98c>
      d8: f84303e0     	ldur	x0, [sp, #0x30]
      dc: f9401813     	ldr	x19, [x0, #0x30]
      e0: b9401814     	ldr	w20, [x0, #0x18]
      e4: b9401c00     	ldr	w0, [x0, #0x1c]
      e8: 11000695     	add	w21, w20, #0x1
      ec: 6b0002bf     	cmp	w21, w0
      f0: 54004748     	b.hi	0x9d8 <___pl_fn_1+0x958>
      f4: f84303e0     	ldur	x0, [sp, #0x30]
      f8: f9401000     	ldr	x0, [x0, #0x20]
      fc: b8345813     	str	w19, [x0, w20, uxtw #2]
     100: f84303e0     	ldur	x0, [sp, #0x30]
     104: b9001815     	str	w21, [x0, #0x18]
     108: 52800061     	mov	w1, #0x3                ; =3
     10c: 52800002     	mov	w2, #0x0                ; =0
     110: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     114: f9400063     	ldr	x3, [x3]
     118: d63f0060     	blr	x3
     11c: 35004780     	cbnz	w0, 0xa0c <___pl_fn_1+0x98c>
     120: f84303e0     	ldur	x0, [sp, #0x30]
     124: f9401816     	ldr	x22, [x0, #0x30]
     128: b9001814     	str	w20, [x0, #0x18]
     12c: b9401c00     	ldr	w0, [x0, #0x1c]
     130: 6b0002bf     	cmp	w21, w0
     134: 54004388     	b.hi	0x9a4 <___pl_fn_1+0x924>
     138: f84303e0     	ldur	x0, [sp, #0x30]
     13c: f9401000     	ldr	x0, [x0, #0x20]
     140: b8345813     	str	w19, [x0, w20, uxtw #2]
     144: f84303e0     	ldur	x0, [sp, #0x30]
     148: b9001815     	str	w21, [x0, #0x18]
     14c: 528000a1     	mov	w1, #0x5                ; =5
     150: 52800002     	mov	w2, #0x0                ; =0
     154: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     158: f9400063     	ldr	x3, [x3]
     15c: d63f0060     	blr	x3
     160: 35004560     	cbnz	w0, 0xa0c <___pl_fn_1+0x98c>
     164: f84303e0     	ldur	x0, [sp, #0x30]
     168: f9401817     	ldr	x23, [x0, #0x30]
     16c: b9001814     	str	w20, [x0, #0x18]
     170: 34004017     	cbz	w23, 0x970 <___pl_fn_1+0x8f0>
     174: 34001e17     	cbz	w23, 0x534 <___pl_fn_1+0x4b4>
     178: f84303e0     	ldur	x0, [sp, #0x30]
     17c: f9400001     	ldr	x1, [x0]
     180: 2a1703e0     	mov	w0, w23
     184: 8b000c20     	add	x0, x1, x0, lsl #3
     188: f8775821     	ldr	x1, [x1, w23, uxtw #3]
     18c: d360fc21     	lsr	x1, x1, #32
     190: 92403c22     	and	x2, x1, #0xffff
     194: f100085f     	cmp	x2, #0x2
     198: 54000080     	b.eq	0x1a8 <___pl_fn_1+0x128>
     19c: f9400802     	ldr	x2, [x0, #0x10]
     1a0: 927ff842     	and	x2, x2, #0xfffffffffffffffe
     1a4: f9000802     	str	x2, [x0, #0x10]
     1a8: 52848064     	mov	w4, #0x2403             ; =9219
     1ac: 72a00024     	movk	w4, #0x1, lsl #16
     1b0: 92403c25     	and	x5, x1, #0xffff
     1b4: f8257804     	str	x4, [x0, x5, lsl #3]
     1b8: d2800c66     	mov	x6, #0x63               ; =99
     1bc: d2800014     	mov	x20, #0x0               ; =0
     1c0: ab1400d8     	adds	x24, x6, x20
     1c4: 9a9f77e7     	cset	x7, vs
     1c8: 72001cff     	tst	w7, #0xff
     1cc: 54003b81     	b.ne	0x93c <___pl_fn_1+0x8bc>
     1d0: d2800028     	mov	x8, #0x1                ; =1
     1d4: ab140119     	adds	x25, x8, x20
     1d8: 9a9f77e9     	cset	x9, vs
     1dc: 72001d3f     	tst	w9, #0xff
     1e0: 54003941     	b.ne	0x908 <___pl_fn_1+0x888>
     1e4: b4003799     	cbz	x25, 0x8d4 <___pl_fn_1+0x854>
     1e8: 52800020     	mov	w0, #0x1                ; =1
     1ec: aa1403f5     	mov	x21, x20
     1f0: f100033f     	cmp	x25, #0x0
     1f4: 5400008a     	b.ge	0x204 <___pl_fn_1+0x184>
     1f8: eb1802bf     	cmp	x21, x24
     1fc: 9a9fb7e1     	cset	x1, ge
     200: 14000003     	b	0x20c <___pl_fn_1+0x18c>
     204: eb1802bf     	cmp	x21, x24
     208: 9a9fc7e1     	cset	x1, le
     20c: 72001c3f     	tst	w1, #0xff
     210: 540010a1     	b.ne	0x424 <___pl_fn_1+0x3a4>
     214: ab1402d6     	adds	x22, x22, x20
     218: 9a9f77e1     	cset	x1, vs
     21c: 72001c3f     	tst	w1, #0xff
     220: 54002be1     	b.ne	0x79c <___pl_fn_1+0x71c>
     224: d2800021     	mov	x1, #0x1                ; =1
     228: ab140037     	adds	x23, x1, x20
     22c: 9a9f77e1     	cset	x1, vs
     230: 72001c3f     	tst	w1, #0xff
     234: 540029a1     	b.ne	0x768 <___pl_fn_1+0x6e8>
     238: b40027f7     	cbz	x23, 0x734 <___pl_fn_1+0x6b4>
     23c: d2800038     	mov	x24, #0x1               ; =1
     240: 52800021     	mov	w1, #0x1                ; =1
     244: aa1403e2     	mov	x2, x20
     248: aa0103f9     	mov	x25, x1
     24c: f10002ff     	cmp	x23, #0x0
     250: 5400008a     	b.ge	0x260 <___pl_fn_1+0x1e0>
     254: eb16031f     	cmp	x24, x22
     258: 9a9fb7e1     	cset	x1, ge
     25c: 14000003     	b	0x268 <___pl_fn_1+0x1e8>
     260: eb16031f     	cmp	x24, x22
     264: 9a9fc7e1     	cset	x1, le
     268: 72001c3f     	tst	w1, #0xff
     26c: 540002a1     	b.ne	0x2c0 <___pl_fn_1+0x240>
     270: 528001c1     	mov	w1, #0xe                ; =14
     274: 52802003     	mov	w3, #0x100              ; =256
     278: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     27c: f9400084     	ldr	x4, [x4]
     280: f84303e0     	ldur	x0, [sp, #0x30]
     284: d63f0080     	blr	x4
     288: 35003c20     	cbnz	w0, 0xa0c <___pl_fn_1+0x98c>
     28c: f84303e0     	ldur	x0, [sp, #0x30]
     290: b9401000     	ldr	w0, [x0, #0x10]
     294: 51000400     	sub	w0, w0, #0x1
     298: f84303e1     	ldur	x1, [sp, #0x30]
     29c: b9001020     	str	w0, [x1, #0x10]
     2a0: 910103ff     	add	sp, sp, #0x40
     2a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     2a8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     2ac: a8c163f7     	ldp	x23, x24, [sp], #0x10
     2b0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     2b4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     2b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     2bc: d65f03c0     	ret
     2c0: f80383e2     	stur	x2, [sp, #0x38]
     2c4: d2800c60     	mov	x0, #0x63               ; =99
     2c8: ab14001a     	adds	x26, x0, x20
     2cc: 9a9f77e0     	cset	x0, vs
     2d0: 72001c1f     	tst	w0, #0xff
     2d4: 54002161     	b.ne	0x700 <___pl_fn_1+0x680>
     2d8: d2800020     	mov	x0, #0x1                ; =1
     2dc: ab14001b     	adds	x27, x0, x20
     2e0: 9a9f77e0     	cset	x0, vs
     2e4: 72001c1f     	tst	w0, #0xff
     2e8: 54001f21     	b.ne	0x6cc <___pl_fn_1+0x64c>
     2ec: b4001d7b     	cbz	x27, 0x698 <___pl_fn_1+0x618>
     2f0: 52800020     	mov	w0, #0x1                ; =1
     2f4: aa1403f5     	mov	x21, x20
     2f8: f100037f     	cmp	x27, #0x0
     2fc: 5400008a     	b.ge	0x30c <___pl_fn_1+0x28c>
     300: eb1a02bf     	cmp	x21, x26
     304: 9a9fb7e1     	cset	x1, ge
     308: 14000003     	b	0x314 <___pl_fn_1+0x294>
     30c: eb1a02bf     	cmp	x21, x26
     310: 9a9fc7e1     	cset	x1, le
     314: 72001c3f     	tst	w1, #0xff
     318: 54000101     	b.ne	0x338 <___pl_fn_1+0x2b8>
     31c: ab170318     	adds	x24, x24, x23
     320: 9a9f77e1     	cset	x1, vs
     324: 72001c3f     	tst	w1, #0xff
     328: 54001221     	b.ne	0x56c <___pl_fn_1+0x4ec>
     32c: 52800021     	mov	w1, #0x1                ; =1
     330: f84383e2     	ldur	x2, [sp, #0x38]
     334: 17ffffc6     	b	0x24c <___pl_fn_1+0x1cc>
     338: 34001353     	cbz	w19, 0x5a0 <___pl_fn_1+0x520>
     33c: f84303e0     	ldur	x0, [sp, #0x30]
     340: f9400000     	ldr	x0, [x0]
     344: 2a1303e1     	mov	w1, w19
     348: 8b010c00     	add	x0, x0, x1, lsl #3
     34c: f9400801     	ldr	x1, [x0, #0x10]
     350: eb0102bf     	cmp	x21, x1
     354: 54001262     	b.hs	0x5a0 <___pl_fn_1+0x520>
     358: 8b150c00     	add	x0, x0, x21, lsl #3
     35c: b9402801     	ldr	w1, [x0, #0x28]
     360: 350000a1     	cbnz	w1, 0x374 <___pl_fn_1+0x2f4>
     364: 1400008f     	b	0x5a0 <___pl_fn_1+0x520>
     368: f84303e0     	ldur	x0, [sp, #0x30]
     36c: f9401801     	ldr	x1, [x0, #0x30]
     370: 14000002     	b	0x378 <___pl_fn_1+0x2f8>
     374: f84303e0     	ldur	x0, [sp, #0x30]
     378: f84303e0     	ldur	x0, [sp, #0x30]
     37c: b940181c     	ldr	w28, [x0, #0x18]
     380: b9401c05     	ldr	w5, [x0, #0x1c]
     384: 11000b86     	add	w6, w28, #0x2
     388: 6b0500df     	cmp	w6, w5
     38c: 540016c8     	b.hi	0x664 <___pl_fn_1+0x5e4>
     390: f84303e0     	ldur	x0, [sp, #0x30]
     394: f9401007     	ldr	x7, [x0, #0x20]
     398: 2a1c03e8     	mov	w8, w28
     39c: 8b0808e8     	add	x8, x7, x8, lsl #2
     3a0: b83c58f3     	str	w19, [x7, w28, uxtw #2]
     3a4: b9000501     	str	w1, [x8, #0x4]
     3a8: 11000b89     	add	w9, w28, #0x2
     3ac: b9001809     	str	w9, [x0, #0x18]
     3b0: b940100a     	ldr	w10, [x0, #0x10]
     3b4: b940140b     	ldr	w11, [x0, #0x14]
     3b8: 6b0b015f     	cmp	w10, w11
     3bc: 540013a2     	b.hs	0x630 <___pl_fn_1+0x5b0>
     3c0: f84303e0     	ldur	x0, [sp, #0x30]
     3c4: 94000000     	bl	0x3c4 <___pl_fn_1+0x344>
     3c8: f84303e1     	ldur	x1, [sp, #0x30]
     3cc: b9402c2c     	ldr	w12, [x1, #0x2c]
     3d0: 350031ec     	cbnz	w12, 0xa0c <___pl_fn_1+0x98c>
     3d4: f84303e1     	ldur	x1, [sp, #0x30]
     3d8: b900183c     	str	w28, [x1, #0x18]
     3dc: 72001c1f     	tst	w0, #0xff
     3e0: 54000061     	b.ne	0x3ec <___pl_fn_1+0x36c>
     3e4: f84383e2     	ldur	x2, [sp, #0x38]
     3e8: 14000008     	b	0x408 <___pl_fn_1+0x388>
     3ec: d2800020     	mov	x0, #0x1                ; =1
     3f0: f84383e2     	ldur	x2, [sp, #0x38]
     3f4: ab000042     	adds	x2, x2, x0
     3f8: 9a9f77e0     	cset	x0, vs
     3fc: 72001c1f     	tst	w0, #0xff
     400: 54000fe1     	b.ne	0x5fc <___pl_fn_1+0x57c>
     404: 52800039     	mov	w25, #0x1               ; =1
     408: ab1b02b5     	adds	x21, x21, x27
     40c: 9a9f77e0     	cset	x0, vs
     410: 72001c1f     	tst	w0, #0xff
     414: 54000da1     	b.ne	0x5c8 <___pl_fn_1+0x548>
     418: 52800020     	mov	w0, #0x1                ; =1
     41c: f80383e2     	stur	x2, [sp, #0x38]
     420: 17ffffb6     	b	0x2f8 <___pl_fn_1+0x278>
     424: f84303e0     	ldur	x0, [sp, #0x30]
     428: b940181a     	ldr	w26, [x0, #0x18]
     42c: b9401c00     	ldr	w0, [x0, #0x1c]
     430: 11000b41     	add	w1, w26, #0x2
     434: 6b00003f     	cmp	w1, w0
     438: 54002348     	b.hi	0x8a0 <___pl_fn_1+0x820>
     43c: f84303e0     	ldur	x0, [sp, #0x30]
     440: f9401000     	ldr	x0, [x0, #0x20]
     444: 2a1a03fb     	mov	w27, w26
     448: 8b1b0801     	add	x1, x0, x27, lsl #2
     44c: b83a5813     	str	w19, [x0, w26, uxtw #2]
     450: b9000437     	str	w23, [x1, #0x4]
     454: 11000b40     	add	w0, w26, #0x2
     458: f84303e1     	ldur	x1, [sp, #0x30]
     45c: b9001820     	str	w0, [x1, #0x18]
     460: 52800321     	mov	w1, #0x19               ; =25
     464: 52800022     	mov	w2, #0x1                ; =1
     468: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     46c: f9400063     	ldr	x3, [x3]
     470: f84303e0     	ldur	x0, [sp, #0x30]
     474: d63f0060     	blr	x3
     478: 35002ca0     	cbnz	w0, 0xa0c <___pl_fn_1+0x98c>
     47c: f84303e0     	ldur	x0, [sp, #0x30]
     480: f9401801     	ldr	x1, [x0, #0x30]
     484: b900181a     	str	w26, [x0, #0x18]
     488: b9401c02     	ldr	w2, [x0, #0x1c]
     48c: 11000f40     	add	w0, w26, #0x3
     490: 6b02001f     	cmp	w0, w2
     494: 54001ec8     	b.hi	0x86c <___pl_fn_1+0x7ec>
     498: f84303e2     	ldur	x2, [sp, #0x30]
     49c: f9401043     	ldr	x3, [x2, #0x20]
     4a0: 8b1b0862     	add	x2, x3, x27, lsl #2
     4a4: b83a5873     	str	w19, [x3, w26, uxtw #2]
     4a8: b9000457     	str	w23, [x2, #0x4]
     4ac: b9000841     	str	w1, [x2, #0x8]
     4b0: f84303e2     	ldur	x2, [sp, #0x30]
     4b4: b9001840     	str	w0, [x2, #0x18]
     4b8: f84303e0     	ldur	x0, [sp, #0x30]
     4bc: b9401000     	ldr	w0, [x0, #0x10]
     4c0: f84303e5     	ldur	x5, [sp, #0x30]
     4c4: b94014a2     	ldr	w2, [x5, #0x14]
     4c8: 6b02001f     	cmp	w0, w2
     4cc: 54001b62     	b.hs	0x838 <___pl_fn_1+0x7b8>
     4d0: f84303e0     	ldur	x0, [sp, #0x30]
     4d4: aa1703e2     	mov	x2, x23
     4d8: 94000000     	bl	0x4d8 <___pl_fn_1+0x458>
     4dc: f84303ea     	ldur	x10, [sp, #0x30]
     4e0: b9402d41     	ldr	w1, [x10, #0x2c]
     4e4: 35002941     	cbnz	w1, 0xa0c <___pl_fn_1+0x98c>
     4e8: f84303ee     	ldur	x14, [sp, #0x30]
     4ec: b90019da     	str	w26, [x14, #0x18]
     4f0: 34001733     	cbz	w19, 0x7d4 <___pl_fn_1+0x754>
     4f4: f84303e1     	ldur	x1, [sp, #0x30]
     4f8: f9400021     	ldr	x1, [x1]
     4fc: 2a1303e2     	mov	w2, w19
     500: 8b020c21     	add	x1, x1, x2, lsl #3
     504: f9400822     	ldr	x2, [x1, #0x10]
     508: eb0202bf     	cmp	x21, x2
     50c: 54001642     	b.hs	0x7d4 <___pl_fn_1+0x754>
     510: 2a0003e0     	mov	w0, w0
     514: 8b150c21     	add	x1, x1, x21, lsl #3
     518: f9001420     	str	x0, [x1, #0x28]
     51c: ab1902b5     	adds	x21, x21, x25
     520: 9a9f77e3     	cset	x3, vs
     524: 72001c7f     	tst	w3, #0xff
     528: 540016e1     	b.ne	0x804 <___pl_fn_1+0x784>
     52c: 52800020     	mov	w0, #0x1                ; =1
     530: 17ffff30     	b	0x1f0 <___pl_fn_1+0x170>
     534: d2800000     	mov	x0, #0x0                ; =0
     538: 910023e3     	add	x3, sp, #0x8
     53c: f80083e0     	stur	x0, [sp, #0x8]
     540: 52848060     	mov	w0, #0x2403             ; =9219
     544: 72a00020     	movk	w0, #0x1, lsl #16
     548: f80103e0     	stur	x0, [sp, #0x10]
     54c: 528000e1     	mov	w1, #0x7                ; =7
     550: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     554: f9400084     	ldr	x4, [x4]
     558: f84303e0     	ldur	x0, [sp, #0x30]
     55c: aa1703e2     	mov	x2, x23
     560: d63f0080     	blr	x4
     564: 34ffe2a0     	cbz	w0, 0x1b8 <___pl_fn_1+0x138>
     568: 14000129     	b	0xa0c <___pl_fn_1+0x98c>
     56c: 52800241     	mov	w1, #0x12               ; =18
     570: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     574: f9400042     	ldr	x2, [x2]
     578: f84303e0     	ldur	x0, [sp, #0x30]
     57c: d63f0040     	blr	x2
     580: 910103ff     	add	sp, sp, #0x40
     584: a8c153f3     	ldp	x19, x20, [sp], #0x10
     588: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     58c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     590: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     594: a8c173fb     	ldp	x27, x28, [sp], #0x10
     598: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     59c: d65f03c0     	ret
     5a0: 910063e3     	add	x3, sp, #0x18
     5a4: f80183f5     	stur	x21, [sp, #0x18]
     5a8: 52800261     	mov	w1, #0x13               ; =19
     5ac: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5b0: f9400084     	ldr	x4, [x4]
     5b4: f84303e0     	ldur	x0, [sp, #0x30]
     5b8: aa1303e2     	mov	x2, x19
     5bc: d63f0080     	blr	x4
     5c0: 34ffed40     	cbz	w0, 0x368 <___pl_fn_1+0x2e8>
     5c4: 14000112     	b	0xa0c <___pl_fn_1+0x98c>
     5c8: 528002e1     	mov	w1, #0x17               ; =23
     5cc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     5d0: f9400042     	ldr	x2, [x2]
     5d4: f84303e0     	ldur	x0, [sp, #0x30]
     5d8: d63f0040     	blr	x2
     5dc: 910103ff     	add	sp, sp, #0x40
     5e0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     5e4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     5e8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     5ec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     5f0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     5f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     5f8: d65f03c0     	ret
     5fc: 528002c1     	mov	w1, #0x16               ; =22
     600: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     604: f9400042     	ldr	x2, [x2]
     608: f84303e0     	ldur	x0, [sp, #0x30]
     60c: d63f0040     	blr	x2
     610: 910103ff     	add	sp, sp, #0x40
     614: a8c153f3     	ldp	x19, x20, [sp], #0x10
     618: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     61c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     620: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     624: a8c173fb     	ldp	x27, x28, [sp], #0x10
     628: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     62c: d65f03c0     	ret
     630: 528002a1     	mov	w1, #0x15               ; =21
     634: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     638: f9400042     	ldr	x2, [x2]
     63c: f84303e0     	ldur	x0, [sp, #0x30]
     640: d63f0040     	blr	x2
     644: 910103ff     	add	sp, sp, #0x40
     648: a8c153f3     	ldp	x19, x20, [sp], #0x10
     64c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     650: a8c163f7     	ldp	x23, x24, [sp], #0x10
     654: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     658: a8c173fb     	ldp	x27, x28, [sp], #0x10
     65c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     660: d65f03c0     	ret
     664: 52800281     	mov	w1, #0x14               ; =20
     668: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     66c: f9400042     	ldr	x2, [x2]
     670: f84303e0     	ldur	x0, [sp, #0x30]
     674: d63f0040     	blr	x2
     678: 910103ff     	add	sp, sp, #0x40
     67c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     680: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     684: a8c163f7     	ldp	x23, x24, [sp], #0x10
     688: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     68c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     690: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     694: d65f03c0     	ret
     698: 52800221     	mov	w1, #0x11               ; =17
     69c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6a0: f9400042     	ldr	x2, [x2]
     6a4: f84303e0     	ldur	x0, [sp, #0x30]
     6a8: d63f0040     	blr	x2
     6ac: 910103ff     	add	sp, sp, #0x40
     6b0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6b4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6b8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6bc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6c0: a8c173fb     	ldp	x27, x28, [sp], #0x10
     6c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6c8: d65f03c0     	ret
     6cc: 52800201     	mov	w1, #0x10               ; =16
     6d0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6d4: f9400042     	ldr	x2, [x2]
     6d8: f84303e0     	ldur	x0, [sp, #0x30]
     6dc: d63f0040     	blr	x2
     6e0: 910103ff     	add	sp, sp, #0x40
     6e4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6e8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6ec: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6f0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6f4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     6f8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6fc: d65f03c0     	ret
     700: 528001e1     	mov	w1, #0xf                ; =15
     704: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     708: f9400042     	ldr	x2, [x2]
     70c: f84303e0     	ldur	x0, [sp, #0x30]
     710: d63f0040     	blr	x2
     714: 910103ff     	add	sp, sp, #0x40
     718: a8c153f3     	ldp	x19, x20, [sp], #0x10
     71c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     720: a8c163f7     	ldp	x23, x24, [sp], #0x10
     724: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     728: a8c173fb     	ldp	x27, x28, [sp], #0x10
     72c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     730: d65f03c0     	ret
     734: 528001a1     	mov	w1, #0xd                ; =13
     738: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     73c: f9400042     	ldr	x2, [x2]
     740: f84303e0     	ldur	x0, [sp, #0x30]
     744: d63f0040     	blr	x2
     748: 910103ff     	add	sp, sp, #0x40
     74c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     750: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     754: a8c163f7     	ldp	x23, x24, [sp], #0x10
     758: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     75c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     760: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     764: d65f03c0     	ret
     768: 52800181     	mov	w1, #0xc                ; =12
     76c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     770: f9400042     	ldr	x2, [x2]
     774: f84303e0     	ldur	x0, [sp, #0x30]
     778: d63f0040     	blr	x2
     77c: 910103ff     	add	sp, sp, #0x40
     780: a8c153f3     	ldp	x19, x20, [sp], #0x10
     784: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     788: a8c163f7     	ldp	x23, x24, [sp], #0x10
     78c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     790: a8c173fb     	ldp	x27, x28, [sp], #0x10
     794: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     798: d65f03c0     	ret
     79c: 52800161     	mov	w1, #0xb                ; =11
     7a0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7a4: f9400042     	ldr	x2, [x2]
     7a8: f84303e0     	ldur	x0, [sp, #0x30]
     7ac: d63f0040     	blr	x2
     7b0: 910103ff     	add	sp, sp, #0x40
     7b4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7b8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7bc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7c0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7c4: a8c173fb     	ldp	x27, x28, [sp], #0x10
     7c8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7cc: d65f03c0     	ret
     7d0: 1400008f     	b	0xa0c <___pl_fn_1+0x98c>
     7d4: 910083e3     	add	x3, sp, #0x20
     7d8: f80203f5     	stur	x21, [sp, #0x20]
     7dc: 2a0003e0     	mov	w0, w0
     7e0: f80283e0     	stur	x0, [sp, #0x28]
     7e4: 52800381     	mov	w1, #0x1c               ; =28
     7e8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     7ec: f9400084     	ldr	x4, [x4]
     7f0: f84303e0     	ldur	x0, [sp, #0x30]
     7f4: aa1303e2     	mov	x2, x19
     7f8: d63f0080     	blr	x4
     7fc: 34ffe900     	cbz	w0, 0x51c <___pl_fn_1+0x49c>
     800: 14000083     	b	0xa0c <___pl_fn_1+0x98c>
     804: 528003a1     	mov	w1, #0x1d               ; =29
     808: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     80c: f94000a5     	ldr	x5, [x5]
     810: f84303e0     	ldur	x0, [sp, #0x30]
     814: d63f00a0     	blr	x5
     818: 910103ff     	add	sp, sp, #0x40
     81c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     820: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     824: a8c163f7     	ldp	x23, x24, [sp], #0x10
     828: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     82c: a8c173fb     	ldp	x27, x28, [sp], #0x10
     830: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     834: d65f03c0     	ret
     838: 52800361     	mov	w1, #0x1b               ; =27
     83c: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     840: f94000c6     	ldr	x6, [x6]
     844: f84303e0     	ldur	x0, [sp, #0x30]
     848: d63f00c0     	blr	x6
     84c: 910103ff     	add	sp, sp, #0x40
     850: a8c153f3     	ldp	x19, x20, [sp], #0x10
     854: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     858: a8c163f7     	ldp	x23, x24, [sp], #0x10
     85c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     860: a8c173fb     	ldp	x27, x28, [sp], #0x10
     864: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     868: d65f03c0     	ret
     86c: 52800341     	mov	w1, #0x1a               ; =26
     870: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     874: f94000e7     	ldr	x7, [x7]
     878: f84303e0     	ldur	x0, [sp, #0x30]
     87c: d63f00e0     	blr	x7
     880: 910103ff     	add	sp, sp, #0x40
     884: a8c153f3     	ldp	x19, x20, [sp], #0x10
     888: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     88c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     890: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     894: a8c173fb     	ldp	x27, x28, [sp], #0x10
     898: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     89c: d65f03c0     	ret
     8a0: 52800301     	mov	w1, #0x18               ; =24
     8a4: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     8a8: f9400108     	ldr	x8, [x8]
     8ac: f84303e0     	ldur	x0, [sp, #0x30]
     8b0: d63f0100     	blr	x8
     8b4: 910103ff     	add	sp, sp, #0x40
     8b8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8bc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8c0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8c4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8c8: a8c173fb     	ldp	x27, x28, [sp], #0x10
     8cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8d0: d65f03c0     	ret
     8d4: 52800141     	mov	w1, #0xa                ; =10
     8d8: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     8dc: f9400129     	ldr	x9, [x9]
     8e0: f84303e0     	ldur	x0, [sp, #0x30]
     8e4: d63f0120     	blr	x9
     8e8: 910103ff     	add	sp, sp, #0x40
     8ec: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8f0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8f4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8f8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8fc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     900: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     904: d65f03c0     	ret
     908: 52800121     	mov	w1, #0x9                ; =9
     90c: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     910: f940014a     	ldr	x10, [x10]
     914: f84303e0     	ldur	x0, [sp, #0x30]
     918: d63f0140     	blr	x10
     91c: 910103ff     	add	sp, sp, #0x40
     920: a8c153f3     	ldp	x19, x20, [sp], #0x10
     924: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     928: a8c163f7     	ldp	x23, x24, [sp], #0x10
     92c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     930: a8c173fb     	ldp	x27, x28, [sp], #0x10
     934: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     938: d65f03c0     	ret
     93c: 52800101     	mov	w1, #0x8                ; =8
     940: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     944: f940016b     	ldr	x11, [x11]
     948: f84303e0     	ldur	x0, [sp, #0x30]
     94c: d63f0160     	blr	x11
     950: 910103ff     	add	sp, sp, #0x40
     954: a8c153f3     	ldp	x19, x20, [sp], #0x10
     958: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     95c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     960: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     964: a8c173fb     	ldp	x27, x28, [sp], #0x10
     968: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     96c: d65f03c0     	ret
     970: 528000c1     	mov	w1, #0x6                ; =6
     974: 9000000c     	adrp	x12, 0x0 <___pl_fn_0>
     978: f940018c     	ldr	x12, [x12]
     97c: f84303e0     	ldur	x0, [sp, #0x30]
     980: d63f0180     	blr	x12
     984: 910103ff     	add	sp, sp, #0x40
     988: a8c153f3     	ldp	x19, x20, [sp], #0x10
     98c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     990: a8c163f7     	ldp	x23, x24, [sp], #0x10
     994: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     998: a8c173fb     	ldp	x27, x28, [sp], #0x10
     99c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9a0: d65f03c0     	ret
     9a4: 52800081     	mov	w1, #0x4                ; =4
     9a8: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     9ac: f94001ad     	ldr	x13, [x13]
     9b0: f84303e0     	ldur	x0, [sp, #0x30]
     9b4: d63f01a0     	blr	x13
     9b8: 910103ff     	add	sp, sp, #0x40
     9bc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9c0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9c4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9c8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9cc: a8c173fb     	ldp	x27, x28, [sp], #0x10
     9d0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9d4: d65f03c0     	ret
     9d8: 52800041     	mov	w1, #0x2                ; =2
     9dc: 9000000e     	adrp	x14, 0x0 <___pl_fn_0>
     9e0: f94001ce     	ldr	x14, [x14]
     9e4: f84303e0     	ldur	x0, [sp, #0x30]
     9e8: d63f01c0     	blr	x14
     9ec: 910103ff     	add	sp, sp, #0x40
     9f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9f4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9f8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9fc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a00: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a04: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a08: d65f03c0     	ret
     a0c: 910103ff     	add	sp, sp, #0x40
     a10: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a14: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a18: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a1c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a20: a8c173fb     	ldp	x27, x28, [sp], #0x10
     a24: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a28: d65f03c0     	ret

0000000000000a2c <___pl_fn_2>:
     a2c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     a30: 910003fd     	mov	x29, sp
     a34: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     a38: d10043ff     	sub	sp, sp, #0x10
     a3c: aa0103f3     	mov	x19, x1
     a40: b940100a     	ldr	w10, [x0, #0x10]
     a44: 1100054a     	add	w10, w10, #0x1
     a48: b900100a     	str	w10, [x0, #0x10]
     a4c: aa1303e1     	mov	x1, x19
     a50: 34000961     	cbz	w1, 0xb7c <___pl_fn_2+0x150>
     a54: f940000f     	ldr	x15, [x0]
     a58: aa1303e1     	mov	x1, x19
     a5c: aa0003f4     	mov	x20, x0
     a60: 2a0103ee     	mov	w14, w1
     a64: 8b0e0dee     	add	x14, x15, x14, lsl #3
     a68: f86159ef     	ldr	x15, [x15, w1, uxtw #3]
     a6c: d360fdef     	lsr	x15, x15, #32
     a70: 92403de0     	and	x0, x15, #0xffff
     a74: f86079cf     	ldr	x15, [x14, x0, lsl #3]
     a78: f100081f     	cmp	x0, #0x2
     a7c: 540000c0     	b.eq	0xa94 <___pl_fn_2+0x68>
     a80: f94009c0     	ldr	x0, [x14, #0x10]
     a84: 370007e0     	tbnz	w0, #0x0, 0xb80 <___pl_fn_2+0x154>
     a88: 14000003     	b	0xa94 <___pl_fn_2+0x68>
     a8c: aa1403e0     	mov	x0, x20
     a90: f940180f     	ldr	x15, [x0, #0x30]
     a94: d280a3a1     	mov	x1, #0x51d              ; =1309
     a98: 9b017de0     	mul	x0, x15, x1
     a9c: 9b417de1     	smulh	x1, x15, x1
     aa0: eb80fc3f     	cmp	x1, x0, asr #63
     aa4: 54000d01     	b.ne	0xc44 <___pl_fn_2+0x218>
     aa8: d286c321     	mov	x1, #0x3619             ; =13849
     aac: ab010000     	adds	x0, x0, x1
     ab0: 9a9f77e1     	cset	x1, vs
     ab4: 72001c3f     	tst	w1, #0xff
     ab8: 54000b21     	b.ne	0xc1c <___pl_fn_2+0x1f0>
     abc: 34000753     	cbz	w19, 0xba4 <___pl_fn_2+0x178>
     ac0: aa1403eb     	mov	x11, x20
     ac4: f9400162     	ldr	x2, [x11]
     ac8: 2a1303e1     	mov	w1, w19
     acc: 8b010c41     	add	x1, x2, x1, lsl #3
     ad0: f8735842     	ldr	x2, [x2, w19, uxtw #3]
     ad4: d360fc42     	lsr	x2, x2, #32
     ad8: 92403c43     	and	x3, x2, #0xffff
     adc: f100087f     	cmp	x3, #0x2
     ae0: 54000080     	b.eq	0xaf0 <___pl_fn_2+0xc4>
     ae4: f9400823     	ldr	x3, [x1, #0x10]
     ae8: 927ff863     	and	x3, x3, #0xfffffffffffffffe
     aec: f9000823     	str	x3, [x1, #0x10]
     af0: 934ffc03     	asr	x3, x0, #15
     af4: d370fc63     	lsr	x3, x3, #48
     af8: 8b030003     	add	x3, x0, x3
     afc: 9270bc63     	and	x3, x3, #0xffffffffffff0000
     b00: cb030000     	sub	x0, x0, x3
     b04: 92403c42     	and	x2, x2, #0xffff
     b08: f8227820     	str	x0, [x1, x2, lsl #3]
     b0c: 340006f3     	cbz	w19, 0xbe8 <___pl_fn_2+0x1bc>
     b10: aa1403e0     	mov	x0, x20
     b14: f9400000     	ldr	x0, [x0]
     b18: 2a1303e1     	mov	w1, w19
     b1c: 8b010c01     	add	x1, x0, x1, lsl #3
     b20: f8735800     	ldr	x0, [x0, w19, uxtw #3]
     b24: d360fc00     	lsr	x0, x0, #32
     b28: 92403c02     	and	x2, x0, #0xffff
     b2c: f8627820     	ldr	x0, [x1, x2, lsl #3]
     b30: f100085f     	cmp	x2, #0x2
     b34: 54000100     	b.eq	0xb54 <___pl_fn_2+0x128>
     b38: f9400821     	ldr	x1, [x1, #0x10]
     b3c: 37000561     	tbnz	w1, #0x0, 0xbe8 <___pl_fn_2+0x1bc>
     b40: 14000005     	b	0xb54 <___pl_fn_2+0x128>
     b44: aa1403e0     	mov	x0, x20
     b48: f9401800     	ldr	x0, [x0, #0x30]
     b4c: aa1403e1     	mov	x1, x20
     b50: 14000002     	b	0xb58 <___pl_fn_2+0x12c>
     b54: aa1403e1     	mov	x1, x20
     b58: aa1403e1     	mov	x1, x20
     b5c: b9401021     	ldr	w1, [x1, #0x10]
     b60: 51000421     	sub	w1, w1, #0x1
     b64: aa1403e2     	mov	x2, x20
     b68: b9001041     	str	w1, [x2, #0x10]
     b6c: 910043ff     	add	sp, sp, #0x10
     b70: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b74: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b78: d65f03c0     	ret
     b7c: aa0003f4     	mov	x20, x0
     b80: 528003c1     	mov	w1, #0x1e               ; =30
     b84: 52800003     	mov	w3, #0x0                ; =0
     b88: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b8c: f9400084     	ldr	x4, [x4]
     b90: aa1403e0     	mov	x0, x20
     b94: aa1303e2     	mov	x2, x19
     b98: d63f0080     	blr	x4
     b9c: 34fff780     	cbz	w0, 0xa8c <___pl_fn_2+0x60>
     ba0: 1400001a     	b	0xc08 <___pl_fn_2+0x1dc>
     ba4: d2800001     	mov	x1, #0x0                ; =0
     ba8: 910003e3     	mov	x3, sp
     bac: f80003e1     	stur	x1, [sp]
     bb0: 934ffc01     	asr	x1, x0, #15
     bb4: d370fc21     	lsr	x1, x1, #48
     bb8: 8b010001     	add	x1, x0, x1
     bbc: 9270bc21     	and	x1, x1, #0xffffffffffff0000
     bc0: cb010000     	sub	x0, x0, x1
     bc4: f80083e0     	stur	x0, [sp, #0x8]
     bc8: 52800441     	mov	w1, #0x22               ; =34
     bcc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     bd0: f9400084     	ldr	x4, [x4]
     bd4: aa1403e0     	mov	x0, x20
     bd8: aa1303e2     	mov	x2, x19
     bdc: d63f0080     	blr	x4
     be0: 34fff960     	cbz	w0, 0xb0c <___pl_fn_2+0xe0>
     be4: 14000009     	b	0xc08 <___pl_fn_2+0x1dc>
     be8: 52800461     	mov	w1, #0x23               ; =35
     bec: 52800003     	mov	w3, #0x0                ; =0
     bf0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     bf4: f9400084     	ldr	x4, [x4]
     bf8: aa1303e2     	mov	x2, x19
     bfc: aa1403e0     	mov	x0, x20
     c00: d63f0080     	blr	x4
     c04: 34fffa00     	cbz	w0, 0xb44 <___pl_fn_2+0x118>
     c08: d2800000     	mov	x0, #0x0                ; =0
     c0c: 910043ff     	add	sp, sp, #0x10
     c10: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c14: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c18: d65f03c0     	ret
     c1c: 52800401     	mov	w1, #0x20               ; =32
     c20: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c24: f9400042     	ldr	x2, [x2]
     c28: aa1403e0     	mov	x0, x20
     c2c: d63f0040     	blr	x2
     c30: d2800000     	mov	x0, #0x0                ; =0
     c34: 910043ff     	add	sp, sp, #0x10
     c38: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c3c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c40: d65f03c0     	ret
     c44: 528003e1     	mov	w1, #0x1f               ; =31
     c48: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c4c: f9400042     	ldr	x2, [x2]
     c50: aa1403e0     	mov	x0, x20
     c54: d63f0040     	blr	x2
     c58: d2800000     	mov	x0, #0x0                ; =0
     c5c: 910043ff     	add	sp, sp, #0x10
     c60: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c68: d65f03c0     	ret

0000000000000c6c <___pl_fn_3>:
     c6c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     c70: 910003fd     	mov	x29, sp
     c74: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
     c78: a9bf6bf5     	stp	x21, x26, [sp, #-0x10]!
     c7c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     c80: d10103ff     	sub	sp, sp, #0x40
     c84: aa0203f4     	mov	x20, x2
     c88: b9401002     	ldr	w2, [x0, #0x10]
     c8c: 11000442     	add	w2, w2, #0x1
     c90: b9001002     	str	w2, [x0, #0x10]
     c94: b940181b     	ldr	w27, [x0, #0x18]
     c98: b9401c02     	ldr	w2, [x0, #0x1c]
     c9c: 11000b63     	add	w3, w27, #0x2
     ca0: 6b02007f     	cmp	w3, w2
     ca4: 540035c8     	b.hi	0x135c <___pl_fn_3+0x6f0>
     ca8: f9401002     	ldr	x2, [x0, #0x20]
     cac: 2a1b03e3     	mov	w3, w27
     cb0: 8b030843     	add	x3, x2, x3, lsl #2
     cb4: b83b5841     	str	w1, [x2, w27, uxtw #2]
     cb8: aa1403e2     	mov	x2, x20
     cbc: aa0103fc     	mov	x28, x1
     cc0: b9000462     	str	w2, [x3, #0x4]
     cc4: 11000b61     	add	w1, w27, #0x2
     cc8: b9001801     	str	w1, [x0, #0x18]
     ccc: b9401001     	ldr	w1, [x0, #0x10]
     cd0: b9401402     	ldr	w2, [x0, #0x14]
     cd4: aa0003fa     	mov	x26, x0
     cd8: 6b02003f     	cmp	w1, w2
     cdc: 54003282     	b.hs	0x132c <___pl_fn_3+0x6c0>
     ce0: aa1a03e0     	mov	x0, x26
     ce4: aa1403e1     	mov	x1, x20
     ce8: 94000000     	bl	0xce8 <___pl_fn_3+0x7c>
     cec: aa1a03e1     	mov	x1, x26
     cf0: b9402c21     	ldr	w1, [x1, #0x2c]
     cf4: 350030e1     	cbnz	w1, 0x1310 <___pl_fn_3+0x6a4>
     cf8: aa1a03e1     	mov	x1, x26
     cfc: b900183b     	str	w27, [x1, #0x18]
     d00: aa1c03f3     	mov	x19, x28
     d04: 35000093     	cbnz	w19, 0xd14 <___pl_fn_3+0xa8>
     d08: 140000de     	b	0x1080 <___pl_fn_3+0x414>
     d0c: aa1a03e0     	mov	x0, x26
     d10: 1400001a     	b	0xd78 <___pl_fn_3+0x10c>
     d14: aa1a03e1     	mov	x1, x26
     d18: f9400022     	ldr	x2, [x1]
     d1c: 2a1303e1     	mov	w1, w19
     d20: 8b010c41     	add	x1, x2, x1, lsl #3
     d24: f8735842     	ldr	x2, [x2, w19, uxtw #3]
     d28: d360fc42     	lsr	x2, x2, #32
     d2c: 92403c43     	and	x3, x2, #0xffff
     d30: f100087f     	cmp	x3, #0x2
     d34: 54000080     	b.eq	0xd44 <___pl_fn_3+0xd8>
     d38: f9400823     	ldr	x3, [x1, #0x10]
     d3c: 927ff863     	and	x3, x3, #0xfffffffffffffffe
     d40: f9000823     	str	x3, [x1, #0x10]
     d44: d29ef9e3     	mov	x3, #0xf7cf             ; =63439
     d48: f2bc6a63     	movk	x3, #0xe353, lsl #16
     d4c: f2d374a3     	movk	x3, #0x9ba5, lsl #32
     d50: f2e41883     	movk	x3, #0x20c4, lsl #48
     d54: 9b437c03     	smulh	x3, x0, x3
     d58: 9346fc63     	asr	x3, x3, #6
     d5c: d37ffc64     	lsr	x4, x3, #63
     d60: 8b040063     	add	x3, x3, x4
     d64: d2803e84     	mov	x4, #0x1f4              ; =500
     d68: 9b048060     	msub	x0, x3, x4, x0
     d6c: 92403c42     	and	x2, x2, #0xffff
     d70: f8227820     	str	x0, [x1, x2, lsl #3]
     d74: aa1a03e0     	mov	x0, x26
     d78: aa1a03e0     	mov	x0, x26
     d7c: b9401815     	ldr	w21, [x0, #0x18]
     d80: b9401c01     	ldr	w1, [x0, #0x1c]
     d84: 11000aa0     	add	w0, w21, #0x2
     d88: 6b01001f     	cmp	w0, w1
     d8c: 54002aa8     	b.hi	0x12e0 <___pl_fn_3+0x674>
     d90: aa1a03e1     	mov	x1, x26
     d94: f9401021     	ldr	x1, [x1, #0x20]
     d98: 2a1503e2     	mov	w2, w21
     d9c: 8b020822     	add	x2, x1, x2, lsl #2
     da0: b8355833     	str	w19, [x1, w21, uxtw #2]
     da4: b9000454     	str	w20, [x2, #0x4]
     da8: aa1a03e1     	mov	x1, x26
     dac: b9001820     	str	w0, [x1, #0x18]
     db0: aa1a03e0     	mov	x0, x26
     db4: b9401000     	ldr	w0, [x0, #0x10]
     db8: b9401421     	ldr	w1, [x1, #0x14]
     dbc: 6b01001f     	cmp	w0, w1
     dc0: 54002782     	b.hs	0x12b0 <___pl_fn_3+0x644>
     dc4: aa1a03e0     	mov	x0, x26
     dc8: aa1403e1     	mov	x1, x20
     dcc: 94000000     	bl	0xdcc <___pl_fn_3+0x160>
     dd0: aa1a03e3     	mov	x3, x26
     dd4: b9402c61     	ldr	w1, [x3, #0x2c]
     dd8: 350029c1     	cbnz	w1, 0x1310 <___pl_fn_3+0x6a4>
     ddc: aa1a03e7     	mov	x7, x26
     de0: b90018f5     	str	w21, [x7, #0x18]
     de4: 35000093     	cbnz	w19, 0xdf4 <___pl_fn_3+0x188>
     de8: 140000bc     	b	0x10d8 <___pl_fn_3+0x46c>
     dec: aa1a03e0     	mov	x0, x26
     df0: 1400001b     	b	0xe5c <___pl_fn_3+0x1f0>
     df4: aa1a03e1     	mov	x1, x26
     df8: f9400026     	ldr	x6, [x1]
     dfc: 2a1303e5     	mov	w5, w19
     e00: 8b050cc5     	add	x5, x6, x5, lsl #3
     e04: f87358c6     	ldr	x6, [x6, w19, uxtw #3]
     e08: d360fcc6     	lsr	x6, x6, #32
     e0c: 92403cc7     	and	x7, x6, #0xffff
     e10: f10008ff     	cmp	x7, #0x2
     e14: 54000080     	b.eq	0xe24 <___pl_fn_3+0x1b8>
     e18: f94008a8     	ldr	x8, [x5, #0x10]
     e1c: 927ef908     	and	x8, x8, #0xfffffffffffffffd
     e20: f90008a8     	str	x8, [x5, #0x10]
     e24: d29ef9ea     	mov	x10, #0xf7cf            ; =63439
     e28: f2bc6a6a     	movk	x10, #0xe353, lsl #16
     e2c: f2d374aa     	movk	x10, #0x9ba5, lsl #32
     e30: f2e4188a     	movk	x10, #0x20c4, lsl #48
     e34: 9b4a7c0a     	smulh	x10, x0, x10
     e38: 9346fd4a     	asr	x10, x10, #6
     e3c: d37ffd4b     	lsr	x11, x10, #63
     e40: 8b0b014a     	add	x10, x10, x11
     e44: d2803e8b     	mov	x11, #0x1f4             ; =500
     e48: 9b0b814a     	msub	x10, x10, x11, x0
     e4c: 92403ccb     	and	x11, x6, #0xffff
     e50: 9100056b     	add	x11, x11, #0x1
     e54: f82b78aa     	str	x10, [x5, x11, lsl #3]
     e58: aa1a03e0     	mov	x0, x26
     e5c: aa1a03e0     	mov	x0, x26
     e60: b9401815     	ldr	w21, [x0, #0x18]
     e64: b9401c0d     	ldr	w13, [x0, #0x1c]
     e68: 11000aac     	add	w12, w21, #0x2
     e6c: 6b0d019f     	cmp	w12, w13
     e70: 54002088     	b.hi	0x1280 <___pl_fn_3+0x614>
     e74: aa1a03e0     	mov	x0, x26
     e78: f940100e     	ldr	x14, [x0, #0x20]
     e7c: 2a1503ef     	mov	w15, w21
     e80: 8b0f09cf     	add	x15, x14, x15, lsl #2
     e84: b83559d3     	str	w19, [x14, w21, uxtw #2]
     e88: b90005f4     	str	w20, [x15, #0x4]
     e8c: b900180c     	str	w12, [x0, #0x18]
     e90: b9401000     	ldr	w0, [x0, #0x10]
     e94: aa1a03ed     	mov	x13, x26
     e98: b94015a1     	ldr	w1, [x13, #0x14]
     e9c: 6b01001f     	cmp	w0, w1
     ea0: 54001d82     	b.hs	0x1250 <___pl_fn_3+0x5e4>
     ea4: aa1a03e0     	mov	x0, x26
     ea8: aa1403e1     	mov	x1, x20
     eac: 94000000     	bl	0xeac <___pl_fn_3+0x240>
     eb0: aa1a03e1     	mov	x1, x26
     eb4: b9402c21     	ldr	w1, [x1, #0x2c]
     eb8: 350022c1     	cbnz	w1, 0x1310 <___pl_fn_3+0x6a4>
     ebc: aa1a03e1     	mov	x1, x26
     ec0: b9001835     	str	w21, [x1, #0x18]
     ec4: d28740e1     	mov	x1, #0x3a07             ; =14855
     ec8: f2b40da1     	movk	x1, #0xa06d, lsl #16
     ecc: f2c0da61     	movk	x1, #0x6d3, lsl #32
     ed0: f2eda741     	movk	x1, #0x6d3a, lsl #48
     ed4: 9b417c01     	smulh	x1, x0, x1
     ed8: 9347fc21     	asr	x1, x1, #7
     edc: d37ffc22     	lsr	x2, x1, #63
     ee0: 8b020021     	add	x1, x1, x2
     ee4: d2802582     	mov	x2, #0x12c              ; =300
     ee8: 9b028020     	msub	x0, x1, x2, x0
     eec: d28012c1     	mov	x1, #0x96               ; =150
     ef0: eb010000     	subs	x0, x0, x1
     ef4: 9a9f77e1     	cset	x1, vs
     ef8: 72001c3f     	tst	w1, #0xff
     efc: 54001921     	b.ne	0x1220 <___pl_fn_3+0x5b4>
     f00: 35000093     	cbnz	w19, 0xf10 <___pl_fn_3+0x2a4>
     f04: 1400008b     	b	0x1130 <___pl_fn_3+0x4c4>
     f08: aa1a03e0     	mov	x0, x26
     f0c: 14000011     	b	0xf50 <___pl_fn_3+0x2e4>
     f10: aa1a03e1     	mov	x1, x26
     f14: f9400022     	ldr	x2, [x1]
     f18: 2a1303e1     	mov	w1, w19
     f1c: 8b010c41     	add	x1, x2, x1, lsl #3
     f20: f8735842     	ldr	x2, [x2, w19, uxtw #3]
     f24: d360fc42     	lsr	x2, x2, #32
     f28: 92403c43     	and	x3, x2, #0xffff
     f2c: f100087f     	cmp	x3, #0x2
     f30: 54000080     	b.eq	0xf40 <___pl_fn_3+0x2d4>
     f34: f9400823     	ldr	x3, [x1, #0x10]
     f38: 927df863     	and	x3, x3, #0xfffffffffffffffb
     f3c: f9000823     	str	x3, [x1, #0x10]
     f40: 92403c42     	and	x2, x2, #0xffff
     f44: 91000842     	add	x2, x2, #0x2
     f48: f8227820     	str	x0, [x1, x2, lsl #3]
     f4c: aa1a03e0     	mov	x0, x26
     f50: aa1a03e0     	mov	x0, x26
     f54: b9401815     	ldr	w21, [x0, #0x18]
     f58: b9401c01     	ldr	w1, [x0, #0x1c]
     f5c: 11000aa0     	add	w0, w21, #0x2
     f60: 6b01001f     	cmp	w0, w1
     f64: 54001468     	b.hi	0x11f0 <___pl_fn_3+0x584>
     f68: aa1a03ed     	mov	x13, x26
     f6c: f94011a1     	ldr	x1, [x13, #0x20]
     f70: 2a1503e2     	mov	w2, w21
     f74: 8b020822     	add	x2, x1, x2, lsl #2
     f78: b8355833     	str	w19, [x1, w21, uxtw #2]
     f7c: b9000454     	str	w20, [x2, #0x4]
     f80: aa1a03e1     	mov	x1, x26
     f84: b9001820     	str	w0, [x1, #0x18]
     f88: aa1a03e0     	mov	x0, x26
     f8c: b9401000     	ldr	w0, [x0, #0x10]
     f90: b9401421     	ldr	w1, [x1, #0x14]
     f94: 6b01001f     	cmp	w0, w1
     f98: 54001142     	b.hs	0x11c0 <___pl_fn_3+0x554>
     f9c: aa1403e1     	mov	x1, x20
     fa0: aa1a03e0     	mov	x0, x26
     fa4: 94000000     	bl	0xfa4 <___pl_fn_3+0x338>
     fa8: aa1a03e1     	mov	x1, x26
     fac: b9402c21     	ldr	w1, [x1, #0x2c]
     fb0: 35001b01     	cbnz	w1, 0x1310 <___pl_fn_3+0x6a4>
     fb4: aa1a03e1     	mov	x1, x26
     fb8: b9001835     	str	w21, [x1, #0x18]
     fbc: d28740e1     	mov	x1, #0x3a07             ; =14855
     fc0: f2b40da1     	movk	x1, #0xa06d, lsl #16
     fc4: f2c0da61     	movk	x1, #0x6d3, lsl #32
     fc8: f2eda741     	movk	x1, #0x6d3a, lsl #48
     fcc: 9b417c01     	smulh	x1, x0, x1
     fd0: 9347fc21     	asr	x1, x1, #7
     fd4: d37ffc22     	lsr	x2, x1, #63
     fd8: 8b020021     	add	x1, x1, x2
     fdc: d2802582     	mov	x2, #0x12c              ; =300
     fe0: 9b028020     	msub	x0, x1, x2, x0
     fe4: d28012c1     	mov	x1, #0x96               ; =150
     fe8: eb010000     	subs	x0, x0, x1
     fec: 9a9f77e1     	cset	x1, vs
     ff0: 72001c3f     	tst	w1, #0xff
     ff4: 54000ce1     	b.ne	0x1190 <___pl_fn_3+0x524>
     ff8: 350000b3     	cbnz	w19, 0x100c <___pl_fn_3+0x3a0>
     ffc: 14000059     	b	0x1160 <___pl_fn_3+0x4f4>
    1000: aa1a03e0     	mov	x0, x26
    1004: aa1303fc     	mov	x28, x19
    1008: 14000012     	b	0x1050 <___pl_fn_3+0x3e4>
    100c: aa1a03e1     	mov	x1, x26
    1010: f9400022     	ldr	x2, [x1]
    1014: 2a1303e1     	mov	w1, w19
    1018: 8b010c41     	add	x1, x2, x1, lsl #3
    101c: f8735842     	ldr	x2, [x2, w19, uxtw #3]
    1020: aa1303fc     	mov	x28, x19
    1024: d360fc42     	lsr	x2, x2, #32
    1028: 92403c43     	and	x3, x2, #0xffff
    102c: f100087f     	cmp	x3, #0x2
    1030: 54000080     	b.eq	0x1040 <___pl_fn_3+0x3d4>
    1034: f9400823     	ldr	x3, [x1, #0x10]
    1038: 927cf863     	and	x3, x3, #0xfffffffffffffff7
    103c: f9000823     	str	x3, [x1, #0x10]
    1040: 92403c42     	and	x2, x2, #0xffff
    1044: 91000c42     	add	x2, x2, #0x3
    1048: f8227820     	str	x0, [x1, x2, lsl #3]
    104c: aa1a03e0     	mov	x0, x26
    1050: aa1a03e0     	mov	x0, x26
    1054: b9401001     	ldr	w1, [x0, #0x10]
    1058: 51000421     	sub	w1, w1, #0x1
    105c: b9001001     	str	w1, [x0, #0x10]
    1060: aa1c03e0     	mov	x0, x28
    1064: 910103ff     	add	sp, sp, #0x40
    1068: a8c153f3     	ldp	x19, x20, [sp], #0x10
    106c: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1070: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1074: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1078: d65f03c0     	ret
    107c: 140000a5     	b	0x1310 <___pl_fn_3+0x6a4>
    1080: d2800001     	mov	x1, #0x0                ; =0
    1084: 910003e3     	mov	x3, sp
    1088: f80003e1     	stur	x1, [sp]
    108c: d29ef9e1     	mov	x1, #0xf7cf             ; =63439
    1090: f2bc6a61     	movk	x1, #0xe353, lsl #16
    1094: f2d374a1     	movk	x1, #0x9ba5, lsl #32
    1098: f2e41881     	movk	x1, #0x20c4, lsl #48
    109c: 9b417c01     	smulh	x1, x0, x1
    10a0: 9346fc21     	asr	x1, x1, #6
    10a4: d37ffc22     	lsr	x2, x1, #63
    10a8: 8b020021     	add	x1, x1, x2
    10ac: d2803e82     	mov	x2, #0x1f4              ; =500
    10b0: 9b028020     	msub	x0, x1, x2, x0
    10b4: f80083e0     	stur	x0, [sp, #0x8]
    10b8: 528004e1     	mov	w1, #0x27               ; =39
    10bc: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    10c0: f9400084     	ldr	x4, [x4]
    10c4: aa1a03e0     	mov	x0, x26
    10c8: aa1303e2     	mov	x2, x19
    10cc: d63f0080     	blr	x4
    10d0: 34ffe1e0     	cbz	w0, 0xd0c <___pl_fn_3+0xa0>
    10d4: 1400008f     	b	0x1310 <___pl_fn_3+0x6a4>
    10d8: d2800021     	mov	x1, #0x1                ; =1
    10dc: 910043e3     	add	x3, sp, #0x10
    10e0: f80103e1     	stur	x1, [sp, #0x10]
    10e4: d29ef9e1     	mov	x1, #0xf7cf             ; =63439
    10e8: f2bc6a61     	movk	x1, #0xe353, lsl #16
    10ec: f2d374a1     	movk	x1, #0x9ba5, lsl #32
    10f0: f2e41881     	movk	x1, #0x20c4, lsl #48
    10f4: 9b417c01     	smulh	x1, x0, x1
    10f8: 9346fc21     	asr	x1, x1, #6
    10fc: d37ffc22     	lsr	x2, x1, #63
    1100: 8b020021     	add	x1, x1, x2
    1104: d2803e82     	mov	x2, #0x1f4              ; =500
    1108: 9b028021     	msub	x1, x1, x2, x0
    110c: f80183e1     	stur	x1, [sp, #0x18]
    1110: 52800561     	mov	w1, #0x2b               ; =43
    1114: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1118: f9400084     	ldr	x4, [x4]
    111c: aa1a03e0     	mov	x0, x26
    1120: aa1303e2     	mov	x2, x19
    1124: d63f0080     	blr	x4
    1128: 34ffe620     	cbz	w0, 0xdec <___pl_fn_3+0x180>
    112c: 14000079     	b	0x1310 <___pl_fn_3+0x6a4>
    1130: d2800041     	mov	x1, #0x2                ; =2
    1134: 910083e3     	add	x3, sp, #0x20
    1138: f80203e1     	stur	x1, [sp, #0x20]
    113c: f80283e0     	stur	x0, [sp, #0x28]
    1140: 52800601     	mov	w1, #0x30               ; =48
    1144: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1148: f9400084     	ldr	x4, [x4]
    114c: aa1a03e0     	mov	x0, x26
    1150: aa1303e2     	mov	x2, x19
    1154: d63f0080     	blr	x4
    1158: 34ffed80     	cbz	w0, 0xf08 <___pl_fn_3+0x29c>
    115c: 1400006d     	b	0x1310 <___pl_fn_3+0x6a4>
    1160: d2800061     	mov	x1, #0x3                ; =3
    1164: 9100c3e3     	add	x3, sp, #0x30
    1168: f80303e1     	stur	x1, [sp, #0x30]
    116c: f80383e0     	stur	x0, [sp, #0x38]
    1170: 528006a1     	mov	w1, #0x35               ; =53
    1174: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1178: f9400084     	ldr	x4, [x4]
    117c: aa1a03e0     	mov	x0, x26
    1180: aa1303e2     	mov	x2, x19
    1184: d63f0080     	blr	x4
    1188: 34fff3c0     	cbz	w0, 0x1000 <___pl_fn_3+0x394>
    118c: 14000061     	b	0x1310 <___pl_fn_3+0x6a4>
    1190: 52800681     	mov	w1, #0x34               ; =52
    1194: 90000003     	adrp	x3, 0x1000 <___pl_fn_3+0x394>
    1198: f9400063     	ldr	x3, [x3]
    119c: aa1a03e0     	mov	x0, x26
    11a0: d63f0060     	blr	x3
    11a4: 52800000     	mov	w0, #0x0                ; =0
    11a8: 910103ff     	add	sp, sp, #0x40
    11ac: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11b0: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    11b4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    11b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11bc: d65f03c0     	ret
    11c0: 52800641     	mov	w1, #0x32               ; =50
    11c4: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    11c8: f9400084     	ldr	x4, [x4]
    11cc: aa1a03e0     	mov	x0, x26
    11d0: d63f0080     	blr	x4
    11d4: 52800000     	mov	w0, #0x0                ; =0
    11d8: 910103ff     	add	sp, sp, #0x40
    11dc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11e0: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    11e4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    11e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11ec: d65f03c0     	ret
    11f0: 52800621     	mov	w1, #0x31               ; =49
    11f4: 90000005     	adrp	x5, 0x1000 <___pl_fn_3+0x394>
    11f8: f94000a5     	ldr	x5, [x5]
    11fc: aa1a03e0     	mov	x0, x26
    1200: d63f00a0     	blr	x5
    1204: 52800000     	mov	w0, #0x0                ; =0
    1208: 910103ff     	add	sp, sp, #0x40
    120c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1210: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1214: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1218: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    121c: d65f03c0     	ret
    1220: 528005e1     	mov	w1, #0x2f               ; =47
    1224: 90000006     	adrp	x6, 0x1000 <___pl_fn_3+0x394>
    1228: f94000c6     	ldr	x6, [x6]
    122c: aa1a03e0     	mov	x0, x26
    1230: d63f00c0     	blr	x6
    1234: 52800000     	mov	w0, #0x0                ; =0
    1238: 910103ff     	add	sp, sp, #0x40
    123c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1240: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1244: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1248: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    124c: d65f03c0     	ret
    1250: 528005a1     	mov	w1, #0x2d               ; =45
    1254: 90000007     	adrp	x7, 0x1000 <___pl_fn_3+0x394>
    1258: f94000e7     	ldr	x7, [x7]
    125c: aa1a03e0     	mov	x0, x26
    1260: d63f00e0     	blr	x7
    1264: 52800000     	mov	w0, #0x0                ; =0
    1268: 910103ff     	add	sp, sp, #0x40
    126c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1270: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1274: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1278: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    127c: d65f03c0     	ret
    1280: 52800581     	mov	w1, #0x2c               ; =44
    1284: 90000008     	adrp	x8, 0x1000 <___pl_fn_3+0x394>
    1288: f9400108     	ldr	x8, [x8]
    128c: aa1a03e0     	mov	x0, x26
    1290: d63f0100     	blr	x8
    1294: 52800000     	mov	w0, #0x0                ; =0
    1298: 910103ff     	add	sp, sp, #0x40
    129c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    12a0: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    12a4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    12a8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12ac: d65f03c0     	ret
    12b0: 52800521     	mov	w1, #0x29               ; =41
    12b4: 90000009     	adrp	x9, 0x1000 <___pl_fn_3+0x394>
    12b8: f9400129     	ldr	x9, [x9]
    12bc: aa1a03e0     	mov	x0, x26
    12c0: d63f0120     	blr	x9
    12c4: 52800000     	mov	w0, #0x0                ; =0
    12c8: 910103ff     	add	sp, sp, #0x40
    12cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    12d0: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    12d4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    12d8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12dc: d65f03c0     	ret
    12e0: 52800501     	mov	w1, #0x28               ; =40
    12e4: 9000000a     	adrp	x10, 0x1000 <___pl_fn_3+0x394>
    12e8: f940014a     	ldr	x10, [x10]
    12ec: aa1a03e0     	mov	x0, x26
    12f0: d63f0140     	blr	x10
    12f4: 52800000     	mov	w0, #0x0                ; =0
    12f8: 910103ff     	add	sp, sp, #0x40
    12fc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1300: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1304: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1308: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    130c: d65f03c0     	ret
    1310: 52800000     	mov	w0, #0x0                ; =0
    1314: 910103ff     	add	sp, sp, #0x40
    1318: a8c153f3     	ldp	x19, x20, [sp], #0x10
    131c: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1320: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1324: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1328: d65f03c0     	ret
    132c: 528004a1     	mov	w1, #0x25               ; =37
    1330: 9000000c     	adrp	x12, 0x1000 <___pl_fn_3+0x394>
    1334: f940018c     	ldr	x12, [x12]
    1338: aa1a03e0     	mov	x0, x26
    133c: d63f0180     	blr	x12
    1340: 52800000     	mov	w0, #0x0                ; =0
    1344: 910103ff     	add	sp, sp, #0x40
    1348: a8c153f3     	ldp	x19, x20, [sp], #0x10
    134c: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1350: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1354: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1358: d65f03c0     	ret
    135c: aa0003fa     	mov	x26, x0
    1360: 52800481     	mov	w1, #0x24               ; =36
    1364: 9000000d     	adrp	x13, 0x1000 <___pl_fn_3+0x394>
    1368: f94001ad     	ldr	x13, [x13]
    136c: d63f01a0     	blr	x13
    1370: 52800000     	mov	w0, #0x0                ; =0
    1374: 910103ff     	add	sp, sp, #0x40
    1378: a8c153f3     	ldp	x19, x20, [sp], #0x10
    137c: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1380: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1384: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1388: d65f03c0     	ret

000000000000138c <___pl_fn_4>:
    138c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    1390: 910003fd     	mov	x29, sp
    1394: f81f0ff9     	str	x25, [sp, #-0x10]!
    1398: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    139c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    13a0: d10283ff     	sub	sp, sp, #0xa0
    13a4: aa0103f3     	mov	x19, x1
    13a8: b9401001     	ldr	w1, [x0, #0x10]
    13ac: 11000421     	add	w1, w1, #0x1
    13b0: b9001001     	str	w1, [x0, #0x10]
    13b4: aa1303e1     	mov	x1, x19
    13b8: 340040c1     	cbz	w1, 0x1bd0 <___pl_fn_4+0x844>
    13bc: f9400001     	ldr	x1, [x0]
    13c0: aa0003f6     	mov	x22, x0
    13c4: aa1303e0     	mov	x0, x19
    13c8: 2a0003e0     	mov	w0, w0
    13cc: 8b000c20     	add	x0, x1, x0, lsl #3
    13d0: aa1303e2     	mov	x2, x19
    13d4: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    13d8: d360fc21     	lsr	x1, x1, #32
    13dc: 92403c21     	and	x1, x1, #0xffff
    13e0: f8617814     	ldr	x20, [x0, x1, lsl #3]
    13e4: f100083f     	cmp	x1, #0x2
    13e8: 540000c0     	b.eq	0x1400 <___pl_fn_4+0x74>
    13ec: f9400800     	ldr	x0, [x0, #0x10]
    13f0: 37003f20     	tbnz	w0, #0x0, 0x1bd4 <___pl_fn_4+0x848>
    13f4: 14000003     	b	0x1400 <___pl_fn_4+0x74>
    13f8: aa1603e0     	mov	x0, x22
    13fc: f9401814     	ldr	x20, [x0, #0x30]
    1400: 34003fd3     	cbz	w19, 0x1bf8 <___pl_fn_4+0x86c>
    1404: aa1603e0     	mov	x0, x22
    1408: f940000a     	ldr	x10, [x0]
    140c: 2a1303e9     	mov	w9, w19
    1410: 8b090d49     	add	x9, x10, x9, lsl #3
    1414: f873594a     	ldr	x10, [x10, w19, uxtw #3]
    1418: d360fd4a     	lsr	x10, x10, #32
    141c: 92403d4a     	and	x10, x10, #0xffff
    1420: 9100094b     	add	x11, x10, #0x2
    1424: f86b7920     	ldr	x0, [x9, x11, lsl #3]
    1428: f100095f     	cmp	x10, #0x2
    142c: 540000c0     	b.eq	0x1444 <___pl_fn_4+0xb8>
    1430: f940092c     	ldr	x12, [x9, #0x10]
    1434: 37103e2c     	tbnz	w12, #0x2, 0x1bf8 <___pl_fn_4+0x86c>
    1438: 14000003     	b	0x1444 <___pl_fn_4+0xb8>
    143c: aa1603e0     	mov	x0, x22
    1440: f9401800     	ldr	x0, [x0, #0x30]
    1444: ab000280     	adds	x0, x20, x0
    1448: 9a9f77e1     	cset	x1, vs
    144c: 72001c3f     	tst	w1, #0xff
    1450: 540069e1     	b.ne	0x218c <___pl_fn_4+0xe00>
    1454: 34003e53     	cbz	w19, 0x1c1c <___pl_fn_4+0x890>
    1458: aa1603e7     	mov	x7, x22
    145c: f94000e2     	ldr	x2, [x7]
    1460: 2a1303e1     	mov	w1, w19
    1464: 8b010c41     	add	x1, x2, x1, lsl #3
    1468: f8735842     	ldr	x2, [x2, w19, uxtw #3]
    146c: d360fc42     	lsr	x2, x2, #32
    1470: 92403c43     	and	x3, x2, #0xffff
    1474: f100087f     	cmp	x3, #0x2
    1478: 54000080     	b.eq	0x1488 <___pl_fn_4+0xfc>
    147c: f9400823     	ldr	x3, [x1, #0x10]
    1480: 927ff863     	and	x3, x3, #0xfffffffffffffffe
    1484: f9000823     	str	x3, [x1, #0x10]
    1488: 92403c42     	and	x2, x2, #0xffff
    148c: f8227820     	str	x0, [x1, x2, lsl #3]
    1490: 34003df3     	cbz	w19, 0x1c4c <___pl_fn_4+0x8c0>
    1494: aa1603e0     	mov	x0, x22
    1498: f9400001     	ldr	x1, [x0]
    149c: 2a1303e0     	mov	w0, w19
    14a0: 8b000c20     	add	x0, x1, x0, lsl #3
    14a4: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    14a8: d360fc21     	lsr	x1, x1, #32
    14ac: 92403c21     	and	x1, x1, #0xffff
    14b0: 91000422     	add	x2, x1, #0x1
    14b4: f8627814     	ldr	x20, [x0, x2, lsl #3]
    14b8: f100083f     	cmp	x1, #0x2
    14bc: 540000c0     	b.eq	0x14d4 <___pl_fn_4+0x148>
    14c0: f9400800     	ldr	x0, [x0, #0x10]
    14c4: 37083c40     	tbnz	w0, #0x1, 0x1c4c <___pl_fn_4+0x8c0>
    14c8: 14000003     	b	0x14d4 <___pl_fn_4+0x148>
    14cc: aa1603e0     	mov	x0, x22
    14d0: f9401814     	ldr	x20, [x0, #0x30]
    14d4: 34003cf3     	cbz	w19, 0x1c70 <___pl_fn_4+0x8e4>
    14d8: aa1603e0     	mov	x0, x22
    14dc: f9400001     	ldr	x1, [x0]
    14e0: 2a1303e0     	mov	w0, w19
    14e4: 8b000c20     	add	x0, x1, x0, lsl #3
    14e8: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    14ec: d360fc21     	lsr	x1, x1, #32
    14f0: 92403c21     	and	x1, x1, #0xffff
    14f4: 91000c22     	add	x2, x1, #0x3
    14f8: f8627802     	ldr	x2, [x0, x2, lsl #3]
    14fc: f100083f     	cmp	x1, #0x2
    1500: 540000c0     	b.eq	0x1518 <___pl_fn_4+0x18c>
    1504: f9400800     	ldr	x0, [x0, #0x10]
    1508: 37183b40     	tbnz	w0, #0x3, 0x1c70 <___pl_fn_4+0x8e4>
    150c: 14000003     	b	0x1518 <___pl_fn_4+0x18c>
    1510: aa1603e0     	mov	x0, x22
    1514: f9401802     	ldr	x2, [x0, #0x30]
    1518: ab020280     	adds	x0, x20, x2
    151c: 9a9f77e1     	cset	x1, vs
    1520: 72001c3f     	tst	w1, #0xff
    1524: 540061c1     	b.ne	0x215c <___pl_fn_4+0xdd0>
    1528: 34003b73     	cbz	w19, 0x1c94 <___pl_fn_4+0x908>
    152c: aa1603e1     	mov	x1, x22
    1530: f9400024     	ldr	x4, [x1]
    1534: 2a1303e3     	mov	w3, w19
    1538: 8b030c83     	add	x3, x4, x3, lsl #3
    153c: f8735884     	ldr	x4, [x4, w19, uxtw #3]
    1540: d360fc84     	lsr	x4, x4, #32
    1544: 92403c85     	and	x5, x4, #0xffff
    1548: f10008bf     	cmp	x5, #0x2
    154c: 54000080     	b.eq	0x155c <___pl_fn_4+0x1d0>
    1550: f9400866     	ldr	x6, [x3, #0x10]
    1554: 927ef8c6     	and	x6, x6, #0xfffffffffffffffd
    1558: f9000866     	str	x6, [x3, #0x10]
    155c: 92403c88     	and	x8, x4, #0xffff
    1560: 91000508     	add	x8, x8, #0x1
    1564: f8287860     	str	x0, [x3, x8, lsl #3]
    1568: 34003af3     	cbz	w19, 0x1cc4 <___pl_fn_4+0x938>
    156c: aa1603e0     	mov	x0, x22
    1570: f940000d     	ldr	x13, [x0]
    1574: 2a1303ec     	mov	w12, w19
    1578: 8b0c0dac     	add	x12, x13, x12, lsl #3
    157c: f87359ad     	ldr	x13, [x13, w19, uxtw #3]
    1580: d360fdad     	lsr	x13, x13, #32
    1584: 92403dad     	and	x13, x13, #0xffff
    1588: f86d7980     	ldr	x0, [x12, x13, lsl #3]
    158c: f10009bf     	cmp	x13, #0x2
    1590: 540000c0     	b.eq	0x15a8 <___pl_fn_4+0x21c>
    1594: f940098f     	ldr	x15, [x12, #0x10]
    1598: 3700396f     	tbnz	w15, #0x0, 0x1cc4 <___pl_fn_4+0x938>
    159c: 14000003     	b	0x15a8 <___pl_fn_4+0x21c>
    15a0: aa1603e0     	mov	x0, x22
    15a4: f9401800     	ldr	x0, [x0, #0x30]
    15a8: f107d01f     	cmp	x0, #0x1f4
    15ac: 5400008c     	b.gt	0x15bc <___pl_fn_4+0x230>
    15b0: 52800000     	mov	w0, #0x0                ; =0
    15b4: aa0003f4     	mov	x20, x0
    15b8: 14000053     	b	0x1704 <___pl_fn_4+0x378>
    15bc: 34003973     	cbz	w19, 0x1ce8 <___pl_fn_4+0x95c>
    15c0: aa1603e0     	mov	x0, x22
    15c4: f9400001     	ldr	x1, [x0]
    15c8: 2a1303e0     	mov	w0, w19
    15cc: 8b000c20     	add	x0, x1, x0, lsl #3
    15d0: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    15d4: d360fc21     	lsr	x1, x1, #32
    15d8: 92403c22     	and	x2, x1, #0xffff
    15dc: f100085f     	cmp	x2, #0x2
    15e0: 54000080     	b.eq	0x15f0 <___pl_fn_4+0x264>
    15e4: f9400802     	ldr	x2, [x0, #0x10]
    15e8: 927ff842     	and	x2, x2, #0xfffffffffffffffe
    15ec: f9000802     	str	x2, [x0, #0x10]
    15f0: d2803e82     	mov	x2, #0x1f4              ; =500
    15f4: 92403c21     	and	x1, x1, #0xffff
    15f8: f8217802     	str	x2, [x0, x1, lsl #3]
    15fc: 34003913     	cbz	w19, 0x1d1c <___pl_fn_4+0x990>
    1600: aa1603e0     	mov	x0, x22
    1604: f9400001     	ldr	x1, [x0]
    1608: 2a1303e0     	mov	w0, w19
    160c: 8b000c20     	add	x0, x1, x0, lsl #3
    1610: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    1614: d360fc21     	lsr	x1, x1, #32
    1618: 92403c22     	and	x2, x1, #0xffff
    161c: 91000841     	add	x1, x2, #0x2
    1620: f8617801     	ldr	x1, [x0, x1, lsl #3]
    1624: f100085f     	cmp	x2, #0x2
    1628: 540000e0     	b.eq	0x1644 <___pl_fn_4+0x2b8>
    162c: f9400800     	ldr	x0, [x0, #0x10]
    1630: 37103760     	tbnz	w0, #0x2, 0x1d1c <___pl_fn_4+0x990>
    1634: 14000004     	b	0x1644 <___pl_fn_4+0x2b8>
    1638: aa1603e0     	mov	x0, x22
    163c: f9401801     	ldr	x1, [x0, #0x30]
    1640: 14000002     	b	0x1648 <___pl_fn_4+0x2bc>
    1644: aa1603e0     	mov	x0, x22
    1648: aa1603e0     	mov	x0, x22
    164c: b9401815     	ldr	w21, [x0, #0x18]
    1650: b9401c02     	ldr	w2, [x0, #0x1c]
    1654: 110006a0     	add	w0, w21, #0x1
    1658: 6b02001f     	cmp	w0, w2
    165c: 54005688     	b.hi	0x212c <___pl_fn_4+0xda0>
    1660: aa1603e2     	mov	x2, x22
    1664: f9401042     	ldr	x2, [x2, #0x20]
    1668: d2800054     	mov	x20, #0x2               ; =2
    166c: b8355853     	str	w19, [x2, w21, uxtw #2]
    1670: aa1603e2     	mov	x2, x22
    1674: b9001840     	str	w0, [x2, #0x18]
    1678: aa1603e0     	mov	x0, x22
    167c: b9401000     	ldr	w0, [x0, #0x10]
    1680: b9401442     	ldr	w2, [x2, #0x14]
    1684: 6b02001f     	cmp	w0, w2
    1688: 540053a2     	b.hs	0x20fc <___pl_fn_4+0xd70>
    168c: aa1603e0     	mov	x0, x22
    1690: 94000000     	bl	0x1690 <___pl_fn_4+0x304>
    1694: aa1603e1     	mov	x1, x22
    1698: b9402c21     	ldr	w1, [x1, #0x2c]
    169c: 35005221     	cbnz	w1, 0x20e0 <___pl_fn_4+0xd54>
    16a0: aa1603e1     	mov	x1, x22
    16a4: b9001835     	str	w21, [x1, #0x18]
    16a8: d2800001     	mov	x1, #0x0                ; =0
    16ac: eb000020     	subs	x0, x1, x0
    16b0: 9a9f77e1     	cset	x1, vs
    16b4: 72001c3f     	tst	w1, #0xff
    16b8: 54004fc1     	b.ne	0x20b0 <___pl_fn_4+0xd24>
    16bc: 34003433     	cbz	w19, 0x1d40 <___pl_fn_4+0x9b4>
    16c0: aa1603e1     	mov	x1, x22
    16c4: f9400025     	ldr	x5, [x1]
    16c8: 2a1303e4     	mov	w4, w19
    16cc: 8b040ca4     	add	x4, x5, x4, lsl #3
    16d0: f87358a5     	ldr	x5, [x5, w19, uxtw #3]
    16d4: d360fca5     	lsr	x5, x5, #32
    16d8: 92403ca6     	and	x6, x5, #0xffff
    16dc: f10008df     	cmp	x6, #0x2
    16e0: 54000080     	b.eq	0x16f0 <___pl_fn_4+0x364>
    16e4: f9400887     	ldr	x7, [x4, #0x10]
    16e8: 927df8e7     	and	x7, x7, #0xfffffffffffffffb
    16ec: f9000887     	str	x7, [x4, #0x10]
    16f0: 92403ca9     	and	x9, x5, #0xffff
    16f4: 91000929     	add	x9, x9, #0x2
    16f8: f8297880     	str	x0, [x4, x9, lsl #3]
    16fc: 52800020     	mov	w0, #0x1                ; =1
    1700: aa0003f4     	mov	x20, x0
    1704: 34003353     	cbz	w19, 0x1d6c <___pl_fn_4+0x9e0>
    1708: aa1603e0     	mov	x0, x22
    170c: f9400000     	ldr	x0, [x0]
    1710: 2a1303ef     	mov	w15, w19
    1714: 8b0f0c0f     	add	x15, x0, x15, lsl #3
    1718: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    171c: d360fc00     	lsr	x0, x0, #32
    1720: 92403c00     	and	x0, x0, #0xffff
    1724: f86079eb     	ldr	x11, [x15, x0, lsl #3]
    1728: f100081f     	cmp	x0, #0x2
    172c: 540000c0     	b.eq	0x1744 <___pl_fn_4+0x3b8>
    1730: f94009e0     	ldr	x0, [x15, #0x10]
    1734: 370031c0     	tbnz	w0, #0x0, 0x1d6c <___pl_fn_4+0x9e0>
    1738: 14000003     	b	0x1744 <___pl_fn_4+0x3b8>
    173c: aa1603e0     	mov	x0, x22
    1740: f940180b     	ldr	x11, [x0, #0x30]
    1744: d2800019     	mov	x25, #0x0               ; =0
    1748: f100017f     	cmp	x11, #0x0
    174c: 540009aa     	b.ge	0x1880 <___pl_fn_4+0x4f4>
    1750: 34003213     	cbz	w19, 0x1d90 <___pl_fn_4+0xa04>
    1754: aa1603e0     	mov	x0, x22
    1758: f9400001     	ldr	x1, [x0]
    175c: 2a1303e0     	mov	w0, w19
    1760: 8b000c20     	add	x0, x1, x0, lsl #3
    1764: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    1768: d360fc21     	lsr	x1, x1, #32
    176c: 92403c22     	and	x2, x1, #0xffff
    1770: f100085f     	cmp	x2, #0x2
    1774: 54000080     	b.eq	0x1784 <___pl_fn_4+0x3f8>
    1778: f9400802     	ldr	x2, [x0, #0x10]
    177c: 927ff842     	and	x2, x2, #0xfffffffffffffffe
    1780: f9000802     	str	x2, [x0, #0x10]
    1784: 92403c21     	and	x1, x1, #0xffff
    1788: f8217819     	str	x25, [x0, x1, lsl #3]
    178c: 34003193     	cbz	w19, 0x1dbc <___pl_fn_4+0xa30>
    1790: aa1603e0     	mov	x0, x22
    1794: f9400001     	ldr	x1, [x0]
    1798: 2a1303e0     	mov	w0, w19
    179c: 8b000c20     	add	x0, x1, x0, lsl #3
    17a0: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    17a4: d360fc21     	lsr	x1, x1, #32
    17a8: 92403c22     	and	x2, x1, #0xffff
    17ac: 91000841     	add	x1, x2, #0x2
    17b0: f8617801     	ldr	x1, [x0, x1, lsl #3]
    17b4: f100085f     	cmp	x2, #0x2
    17b8: 540000e0     	b.eq	0x17d4 <___pl_fn_4+0x448>
    17bc: f9400800     	ldr	x0, [x0, #0x10]
    17c0: 37102fe0     	tbnz	w0, #0x2, 0x1dbc <___pl_fn_4+0xa30>
    17c4: 14000004     	b	0x17d4 <___pl_fn_4+0x448>
    17c8: aa1603e0     	mov	x0, x22
    17cc: f9401801     	ldr	x1, [x0, #0x30]
    17d0: 14000002     	b	0x17d8 <___pl_fn_4+0x44c>
    17d4: aa1603e0     	mov	x0, x22
    17d8: aa1603e0     	mov	x0, x22
    17dc: b9401814     	ldr	w20, [x0, #0x18]
    17e0: b9401c02     	ldr	w2, [x0, #0x1c]
    17e4: 11000680     	add	w0, w20, #0x1
    17e8: 6b02001f     	cmp	w0, w2
    17ec: 540044a8     	b.hi	0x2080 <___pl_fn_4+0xcf4>
    17f0: aa1603e2     	mov	x2, x22
    17f4: f9401042     	ldr	x2, [x2, #0x20]
    17f8: d2800055     	mov	x21, #0x2               ; =2
    17fc: b8345853     	str	w19, [x2, w20, uxtw #2]
    1800: aa1603e2     	mov	x2, x22
    1804: b9001840     	str	w0, [x2, #0x18]
    1808: aa1603e0     	mov	x0, x22
    180c: b9401000     	ldr	w0, [x0, #0x10]
    1810: b9401442     	ldr	w2, [x2, #0x14]
    1814: 6b02001f     	cmp	w0, w2
    1818: 540041c2     	b.hs	0x2050 <___pl_fn_4+0xcc4>
    181c: aa1603e0     	mov	x0, x22
    1820: 94000000     	bl	0x1820 <___pl_fn_4+0x494>
    1824: aa1603e1     	mov	x1, x22
    1828: b9402c21     	ldr	w1, [x1, #0x2c]
    182c: 350045a1     	cbnz	w1, 0x20e0 <___pl_fn_4+0xd54>
    1830: aa1603e1     	mov	x1, x22
    1834: b9001834     	str	w20, [x1, #0x18]
    1838: 34002d53     	cbz	w19, 0x1de0 <___pl_fn_4+0xa54>
    183c: aa1603e8     	mov	x8, x22
    1840: f9400106     	ldr	x6, [x8]
    1844: 2a1303e5     	mov	w5, w19
    1848: 8b050cc5     	add	x5, x6, x5, lsl #3
    184c: f87358c6     	ldr	x6, [x6, w19, uxtw #3]
    1850: d360fcc6     	lsr	x6, x6, #32
    1854: 92403cc7     	and	x7, x6, #0xffff
    1858: f10008ff     	cmp	x7, #0x2
    185c: 54000080     	b.eq	0x186c <___pl_fn_4+0x4e0>
    1860: f94008a8     	ldr	x8, [x5, #0x10]
    1864: 927df908     	and	x8, x8, #0xfffffffffffffffb
    1868: f90008a8     	str	x8, [x5, #0x10]
    186c: 92403cca     	and	x10, x6, #0xffff
    1870: 9100094a     	add	x10, x10, #0x2
    1874: f82a78a0     	str	x0, [x5, x10, lsl #3]
    1878: 52800020     	mov	w0, #0x1                ; =1
    187c: aa0003f4     	mov	x20, x0
    1880: 34002c73     	cbz	w19, 0x1e0c <___pl_fn_4+0xa80>
    1884: aa1603e0     	mov	x0, x22
    1888: f9400000     	ldr	x0, [x0]
    188c: 2a1303e1     	mov	w1, w19
    1890: 8b010c01     	add	x1, x0, x1, lsl #3
    1894: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    1898: d360fc00     	lsr	x0, x0, #32
    189c: 92403c02     	and	x2, x0, #0xffff
    18a0: 91000440     	add	x0, x2, #0x1
    18a4: f8607820     	ldr	x0, [x1, x0, lsl #3]
    18a8: f100085f     	cmp	x2, #0x2
    18ac: 540000c0     	b.eq	0x18c4 <___pl_fn_4+0x538>
    18b0: f9400821     	ldr	x1, [x1, #0x10]
    18b4: 37082ac1     	tbnz	w1, #0x1, 0x1e0c <___pl_fn_4+0xa80>
    18b8: 14000003     	b	0x18c4 <___pl_fn_4+0x538>
    18bc: aa1603e0     	mov	x0, x22
    18c0: f9401800     	ldr	x0, [x0, #0x30]
    18c4: f107d01f     	cmp	x0, #0x1f4
    18c8: 54000a6d     	b.le	0x1a14 <___pl_fn_4+0x688>
    18cc: 34002b33     	cbz	w19, 0x1e30 <___pl_fn_4+0xaa4>
    18d0: aa1603e0     	mov	x0, x22
    18d4: f9400001     	ldr	x1, [x0]
    18d8: 2a1303e0     	mov	w0, w19
    18dc: 8b000c20     	add	x0, x1, x0, lsl #3
    18e0: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    18e4: d360fc21     	lsr	x1, x1, #32
    18e8: 92403c22     	and	x2, x1, #0xffff
    18ec: f100085f     	cmp	x2, #0x2
    18f0: 54000080     	b.eq	0x1900 <___pl_fn_4+0x574>
    18f4: f9400802     	ldr	x2, [x0, #0x10]
    18f8: 927ef842     	and	x2, x2, #0xfffffffffffffffd
    18fc: f9000802     	str	x2, [x0, #0x10]
    1900: d2803e82     	mov	x2, #0x1f4              ; =500
    1904: 92403c21     	and	x1, x1, #0xffff
    1908: 91000421     	add	x1, x1, #0x1
    190c: f8217802     	str	x2, [x0, x1, lsl #3]
    1910: 34002ab3     	cbz	w19, 0x1e64 <___pl_fn_4+0xad8>
    1914: aa1603e0     	mov	x0, x22
    1918: f9400001     	ldr	x1, [x0]
    191c: 2a1303e0     	mov	w0, w19
    1920: 8b000c20     	add	x0, x1, x0, lsl #3
    1924: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    1928: d360fc21     	lsr	x1, x1, #32
    192c: 92403c22     	and	x2, x1, #0xffff
    1930: 91000c41     	add	x1, x2, #0x3
    1934: f8617801     	ldr	x1, [x0, x1, lsl #3]
    1938: f100085f     	cmp	x2, #0x2
    193c: 540000e0     	b.eq	0x1958 <___pl_fn_4+0x5cc>
    1940: f9400800     	ldr	x0, [x0, #0x10]
    1944: 37182900     	tbnz	w0, #0x3, 0x1e64 <___pl_fn_4+0xad8>
    1948: 14000004     	b	0x1958 <___pl_fn_4+0x5cc>
    194c: aa1603e0     	mov	x0, x22
    1950: f9401801     	ldr	x1, [x0, #0x30]
    1954: 14000002     	b	0x195c <___pl_fn_4+0x5d0>
    1958: aa1603e0     	mov	x0, x22
    195c: aa1603e0     	mov	x0, x22
    1960: b9401814     	ldr	w20, [x0, #0x18]
    1964: b9401c02     	ldr	w2, [x0, #0x1c]
    1968: 11000680     	add	w0, w20, #0x1
    196c: 6b02001f     	cmp	w0, w2
    1970: 54003588     	b.hi	0x2020 <___pl_fn_4+0xc94>
    1974: aa1603e2     	mov	x2, x22
    1978: f9401042     	ldr	x2, [x2, #0x20]
    197c: b8345853     	str	w19, [x2, w20, uxtw #2]
    1980: aa1603e3     	mov	x3, x22
    1984: b9001860     	str	w0, [x3, #0x18]
    1988: aa1603e0     	mov	x0, x22
    198c: b9401000     	ldr	w0, [x0, #0x10]
    1990: aa1603e7     	mov	x7, x22
    1994: b94014e2     	ldr	w2, [x7, #0x14]
    1998: 6b02001f     	cmp	w0, w2
    199c: 540032a2     	b.hs	0x1ff0 <___pl_fn_4+0xc64>
    19a0: aa1603e0     	mov	x0, x22
    19a4: 94000000     	bl	0x19a4 <___pl_fn_4+0x618>
    19a8: aa1603ec     	mov	x12, x22
    19ac: b9402d81     	ldr	w1, [x12, #0x2c]
    19b0: 35003981     	cbnz	w1, 0x20e0 <___pl_fn_4+0xd54>
    19b4: aa1603e1     	mov	x1, x22
    19b8: b9001834     	str	w20, [x1, #0x18]
    19bc: eb000320     	subs	x0, x25, x0
    19c0: 9a9f77e1     	cset	x1, vs
    19c4: 72001c3f     	tst	w1, #0xff
    19c8: 54002fc1     	b.ne	0x1fc0 <___pl_fn_4+0xc34>
    19cc: 340025f3     	cbz	w19, 0x1e88 <___pl_fn_4+0xafc>
    19d0: aa1603e1     	mov	x1, x22
    19d4: f9400029     	ldr	x9, [x1]
    19d8: 2a1303e8     	mov	w8, w19
    19dc: 8b080d28     	add	x8, x9, x8, lsl #3
    19e0: f8735929     	ldr	x9, [x9, w19, uxtw #3]
    19e4: d360fd29     	lsr	x9, x9, #32
    19e8: 92403d2a     	and	x10, x9, #0xffff
    19ec: f100095f     	cmp	x10, #0x2
    19f0: 54000080     	b.eq	0x1a00 <___pl_fn_4+0x674>
    19f4: f940090b     	ldr	x11, [x8, #0x10]
    19f8: 927cf96b     	and	x11, x11, #0xfffffffffffffff7
    19fc: f900090b     	str	x11, [x8, #0x10]
    1a00: 92403d2d     	and	x13, x9, #0xffff
    1a04: 91000dad     	add	x13, x13, #0x3
    1a08: f82d7900     	str	x0, [x8, x13, lsl #3]
    1a0c: 52800020     	mov	w0, #0x1                ; =1
    1a10: aa0003f4     	mov	x20, x0
    1a14: 34002533     	cbz	w19, 0x1eb8 <___pl_fn_4+0xb2c>
    1a18: aa1603e0     	mov	x0, x22
    1a1c: f9400000     	ldr	x0, [x0]
    1a20: 2a1303e1     	mov	w1, w19
    1a24: 8b010c01     	add	x1, x0, x1, lsl #3
    1a28: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    1a2c: d360fc00     	lsr	x0, x0, #32
    1a30: 92403c02     	and	x2, x0, #0xffff
    1a34: 91000440     	add	x0, x2, #0x1
    1a38: f8607820     	ldr	x0, [x1, x0, lsl #3]
    1a3c: f100085f     	cmp	x2, #0x2
    1a40: 540000c0     	b.eq	0x1a58 <___pl_fn_4+0x6cc>
    1a44: f9400821     	ldr	x1, [x1, #0x10]
    1a48: 37082381     	tbnz	w1, #0x1, 0x1eb8 <___pl_fn_4+0xb2c>
    1a4c: 14000003     	b	0x1a58 <___pl_fn_4+0x6cc>
    1a50: aa1603e0     	mov	x0, x22
    1a54: f9401800     	ldr	x0, [x0, #0x30]
    1a58: f100001f     	cmp	x0, #0x0
    1a5c: 5400006b     	b.lt	0x1a68 <___pl_fn_4+0x6dc>
    1a60: aa1603e0     	mov	x0, x22
    1a64: 1400004f     	b	0x1ba0 <___pl_fn_4+0x814>
    1a68: 340023b3     	cbz	w19, 0x1edc <___pl_fn_4+0xb50>
    1a6c: aa1603e0     	mov	x0, x22
    1a70: f9400001     	ldr	x1, [x0]
    1a74: 2a1303e0     	mov	w0, w19
    1a78: 8b000c20     	add	x0, x1, x0, lsl #3
    1a7c: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    1a80: d360fc21     	lsr	x1, x1, #32
    1a84: 92403c22     	and	x2, x1, #0xffff
    1a88: f100085f     	cmp	x2, #0x2
    1a8c: 54000080     	b.eq	0x1a9c <___pl_fn_4+0x710>
    1a90: f9400802     	ldr	x2, [x0, #0x10]
    1a94: 927ef842     	and	x2, x2, #0xfffffffffffffffd
    1a98: f9000802     	str	x2, [x0, #0x10]
    1a9c: 92403c21     	and	x1, x1, #0xffff
    1aa0: 91000421     	add	x1, x1, #0x1
    1aa4: f8217819     	str	x25, [x0, x1, lsl #3]
    1aa8: 34002333     	cbz	w19, 0x1f0c <___pl_fn_4+0xb80>
    1aac: aa1603e0     	mov	x0, x22
    1ab0: f9400001     	ldr	x1, [x0]
    1ab4: 2a1303e0     	mov	w0, w19
    1ab8: 8b000c20     	add	x0, x1, x0, lsl #3
    1abc: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    1ac0: d360fc21     	lsr	x1, x1, #32
    1ac4: 92403c22     	and	x2, x1, #0xffff
    1ac8: 91000c41     	add	x1, x2, #0x3
    1acc: f8617801     	ldr	x1, [x0, x1, lsl #3]
    1ad0: f100085f     	cmp	x2, #0x2
    1ad4: 540000e0     	b.eq	0x1af0 <___pl_fn_4+0x764>
    1ad8: f9400800     	ldr	x0, [x0, #0x10]
    1adc: 37182180     	tbnz	w0, #0x3, 0x1f0c <___pl_fn_4+0xb80>
    1ae0: 14000004     	b	0x1af0 <___pl_fn_4+0x764>
    1ae4: aa1603e0     	mov	x0, x22
    1ae8: f9401801     	ldr	x1, [x0, #0x30]
    1aec: 14000002     	b	0x1af4 <___pl_fn_4+0x768>
    1af0: aa1603e0     	mov	x0, x22
    1af4: aa1603e0     	mov	x0, x22
    1af8: b9401814     	ldr	w20, [x0, #0x18]
    1afc: b9401c02     	ldr	w2, [x0, #0x1c]
    1b00: 11000680     	add	w0, w20, #0x1
    1b04: 6b02001f     	cmp	w0, w2
    1b08: 54002448     	b.hi	0x1f90 <___pl_fn_4+0xc04>
    1b0c: aa1603e2     	mov	x2, x22
    1b10: f9401042     	ldr	x2, [x2, #0x20]
    1b14: b8345853     	str	w19, [x2, w20, uxtw #2]
    1b18: aa1603e2     	mov	x2, x22
    1b1c: b9001840     	str	w0, [x2, #0x18]
    1b20: aa1603e0     	mov	x0, x22
    1b24: b9401000     	ldr	w0, [x0, #0x10]
    1b28: b9401442     	ldr	w2, [x2, #0x14]
    1b2c: 6b02001f     	cmp	w0, w2
    1b30: 54002182     	b.hs	0x1f60 <___pl_fn_4+0xbd4>
    1b34: aa1603e0     	mov	x0, x22
    1b38: 94000000     	bl	0x1b38 <___pl_fn_4+0x7ac>
    1b3c: aa1603e1     	mov	x1, x22
    1b40: b9402c21     	ldr	w1, [x1, #0x2c]
    1b44: 35002ce1     	cbnz	w1, 0x20e0 <___pl_fn_4+0xd54>
    1b48: aa1603e1     	mov	x1, x22
    1b4c: b9001834     	str	w20, [x1, #0x18]
    1b50: 34001f13     	cbz	w19, 0x1f30 <___pl_fn_4+0xba4>
    1b54: aa1603e1     	mov	x1, x22
    1b58: aa1303e2     	mov	x2, x19
    1b5c: f940002a     	ldr	x10, [x1]
    1b60: 2a0203e9     	mov	w9, w2
    1b64: 8b090d49     	add	x9, x10, x9, lsl #3
    1b68: f862594a     	ldr	x10, [x10, w2, uxtw #3]
    1b6c: d360fd4a     	lsr	x10, x10, #32
    1b70: 92403d4b     	and	x11, x10, #0xffff
    1b74: f100097f     	cmp	x11, #0x2
    1b78: 54000080     	b.eq	0x1b88 <___pl_fn_4+0x7fc>
    1b7c: f940092c     	ldr	x12, [x9, #0x10]
    1b80: 927cf98c     	and	x12, x12, #0xfffffffffffffff7
    1b84: f900092c     	str	x12, [x9, #0x10]
    1b88: 92403d4e     	and	x14, x10, #0xffff
    1b8c: 91000dce     	add	x14, x14, #0x3
    1b90: f82e7920     	str	x0, [x9, x14, lsl #3]
    1b94: 52800020     	mov	w0, #0x1                ; =1
    1b98: aa0003f4     	mov	x20, x0
    1b9c: aa1603e0     	mov	x0, x22
    1ba0: aa1603e0     	mov	x0, x22
    1ba4: b9401000     	ldr	w0, [x0, #0x10]
    1ba8: 51000400     	sub	w0, w0, #0x1
    1bac: aa1603ed     	mov	x13, x22
    1bb0: b90011a0     	str	w0, [x13, #0x10]
    1bb4: aa1403e0     	mov	x0, x20
    1bb8: 910283ff     	add	sp, sp, #0xa0
    1bbc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1bc0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1bc4: f84107f9     	ldr	x25, [sp], #0x10
    1bc8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1bcc: d65f03c0     	ret
    1bd0: aa0003f6     	mov	x22, x0
    1bd4: 528006e1     	mov	w1, #0x37               ; =55
    1bd8: 52800003     	mov	w3, #0x0                ; =0
    1bdc: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1be0: f9400084     	ldr	x4, [x4]
    1be4: aa1603e0     	mov	x0, x22
    1be8: aa1303e2     	mov	x2, x19
    1bec: d63f0080     	blr	x4
    1bf0: 34ffc040     	cbz	w0, 0x13f8 <___pl_fn_4+0x6c>
    1bf4: 1400013b     	b	0x20e0 <___pl_fn_4+0xd54>
    1bf8: 52800701     	mov	w1, #0x38               ; =56
    1bfc: 52800043     	mov	w3, #0x2                ; =2
    1c00: 9000000f     	adrp	x15, 0x1000 <___pl_fn_3+0x394>
    1c04: f94001ef     	ldr	x15, [x15]
    1c08: aa1603e0     	mov	x0, x22
    1c0c: aa1303e2     	mov	x2, x19
    1c10: d63f01e0     	blr	x15
    1c14: 34ffc140     	cbz	w0, 0x143c <___pl_fn_4+0xb0>
    1c18: 14000132     	b	0x20e0 <___pl_fn_4+0xd54>
    1c1c: d2800001     	mov	x1, #0x0                ; =0
    1c20: 910003e3     	mov	x3, sp
    1c24: f80003e1     	stur	x1, [sp]
    1c28: f80083e0     	stur	x0, [sp, #0x8]
    1c2c: 52800741     	mov	w1, #0x3a               ; =58
    1c30: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1c34: f9400084     	ldr	x4, [x4]
    1c38: aa1603e0     	mov	x0, x22
    1c3c: aa1303e2     	mov	x2, x19
    1c40: d63f0080     	blr	x4
    1c44: 34ffc260     	cbz	w0, 0x1490 <___pl_fn_4+0x104>
    1c48: 14000126     	b	0x20e0 <___pl_fn_4+0xd54>
    1c4c: 52800761     	mov	w1, #0x3b               ; =59
    1c50: 52800023     	mov	w3, #0x1                ; =1
    1c54: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1c58: f9400084     	ldr	x4, [x4]
    1c5c: aa1603e0     	mov	x0, x22
    1c60: aa1303e2     	mov	x2, x19
    1c64: d63f0080     	blr	x4
    1c68: 34ffc320     	cbz	w0, 0x14cc <___pl_fn_4+0x140>
    1c6c: 1400011d     	b	0x20e0 <___pl_fn_4+0xd54>
    1c70: 52800781     	mov	w1, #0x3c               ; =60
    1c74: 52800063     	mov	w3, #0x3                ; =3
    1c78: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1c7c: f9400084     	ldr	x4, [x4]
    1c80: aa1603e0     	mov	x0, x22
    1c84: aa1303e2     	mov	x2, x19
    1c88: d63f0080     	blr	x4
    1c8c: 34ffc420     	cbz	w0, 0x1510 <___pl_fn_4+0x184>
    1c90: 14000114     	b	0x20e0 <___pl_fn_4+0xd54>
    1c94: d2800021     	mov	x1, #0x1                ; =1
    1c98: 910043e3     	add	x3, sp, #0x10
    1c9c: f80103e1     	stur	x1, [sp, #0x10]
    1ca0: f80183e0     	stur	x0, [sp, #0x18]
    1ca4: 528007c1     	mov	w1, #0x3e               ; =62
    1ca8: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1cac: f9400084     	ldr	x4, [x4]
    1cb0: aa1603e0     	mov	x0, x22
    1cb4: aa1303e2     	mov	x2, x19
    1cb8: d63f0080     	blr	x4
    1cbc: 34ffc560     	cbz	w0, 0x1568 <___pl_fn_4+0x1dc>
    1cc0: 14000108     	b	0x20e0 <___pl_fn_4+0xd54>
    1cc4: 528007e1     	mov	w1, #0x3f               ; =63
    1cc8: 52800003     	mov	w3, #0x0                ; =0
    1ccc: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1cd0: f9400084     	ldr	x4, [x4]
    1cd4: aa1603e0     	mov	x0, x22
    1cd8: aa1303e2     	mov	x2, x19
    1cdc: d63f0080     	blr	x4
    1ce0: 34ffc600     	cbz	w0, 0x15a0 <___pl_fn_4+0x214>
    1ce4: 140000ff     	b	0x20e0 <___pl_fn_4+0xd54>
    1ce8: d2800000     	mov	x0, #0x0                ; =0
    1cec: 910083e3     	add	x3, sp, #0x20
    1cf0: f80203e0     	stur	x0, [sp, #0x20]
    1cf4: d2803e80     	mov	x0, #0x1f4              ; =500
    1cf8: f80283e0     	stur	x0, [sp, #0x28]
    1cfc: 52800801     	mov	w1, #0x40               ; =64
    1d00: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1d04: f9400084     	ldr	x4, [x4]
    1d08: aa1603e0     	mov	x0, x22
    1d0c: aa1303e2     	mov	x2, x19
    1d10: d63f0080     	blr	x4
    1d14: 34ffc740     	cbz	w0, 0x15fc <___pl_fn_4+0x270>
    1d18: 140000f2     	b	0x20e0 <___pl_fn_4+0xd54>
    1d1c: 52800821     	mov	w1, #0x41               ; =65
    1d20: 52800043     	mov	w3, #0x2                ; =2
    1d24: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1d28: f9400084     	ldr	x4, [x4]
    1d2c: aa1603e0     	mov	x0, x22
    1d30: aa1303e2     	mov	x2, x19
    1d34: d63f0080     	blr	x4
    1d38: 34ffc800     	cbz	w0, 0x1638 <___pl_fn_4+0x2ac>
    1d3c: 140000e9     	b	0x20e0 <___pl_fn_4+0xd54>
    1d40: 9100c3e3     	add	x3, sp, #0x30
    1d44: f80303f4     	stur	x20, [sp, #0x30]
    1d48: f80383e0     	stur	x0, [sp, #0x38]
    1d4c: 528008a1     	mov	w1, #0x45               ; =69
    1d50: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1d54: f9400084     	ldr	x4, [x4]
    1d58: aa1603e0     	mov	x0, x22
    1d5c: aa1303e2     	mov	x2, x19
    1d60: d63f0080     	blr	x4
    1d64: 34ffccc0     	cbz	w0, 0x16fc <___pl_fn_4+0x370>
    1d68: 140000de     	b	0x20e0 <___pl_fn_4+0xd54>
    1d6c: 528008e1     	mov	w1, #0x47               ; =71
    1d70: 52800003     	mov	w3, #0x0                ; =0
    1d74: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1d78: f9400084     	ldr	x4, [x4]
    1d7c: aa1603e0     	mov	x0, x22
    1d80: aa1303e2     	mov	x2, x19
    1d84: d63f0080     	blr	x4
    1d88: 34ffcda0     	cbz	w0, 0x173c <___pl_fn_4+0x3b0>
    1d8c: 140000d5     	b	0x20e0 <___pl_fn_4+0xd54>
    1d90: 910103e3     	add	x3, sp, #0x40
    1d94: f80403f9     	stur	x25, [sp, #0x40]
    1d98: f80483f9     	stur	x25, [sp, #0x48]
    1d9c: 52800901     	mov	w1, #0x48               ; =72
    1da0: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1da4: f9400084     	ldr	x4, [x4]
    1da8: aa1603e0     	mov	x0, x22
    1dac: aa1303e2     	mov	x2, x19
    1db0: d63f0080     	blr	x4
    1db4: 34ffcec0     	cbz	w0, 0x178c <___pl_fn_4+0x400>
    1db8: 140000ca     	b	0x20e0 <___pl_fn_4+0xd54>
    1dbc: 52800921     	mov	w1, #0x49               ; =73
    1dc0: 52800043     	mov	w3, #0x2                ; =2
    1dc4: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1dc8: f9400084     	ldr	x4, [x4]
    1dcc: aa1603e0     	mov	x0, x22
    1dd0: aa1303e2     	mov	x2, x19
    1dd4: d63f0080     	blr	x4
    1dd8: 34ffcf80     	cbz	w0, 0x17c8 <___pl_fn_4+0x43c>
    1ddc: 140000c1     	b	0x20e0 <___pl_fn_4+0xd54>
    1de0: 910143e3     	add	x3, sp, #0x50
    1de4: f80503f5     	stur	x21, [sp, #0x50]
    1de8: f80583e0     	stur	x0, [sp, #0x58]
    1dec: 52800981     	mov	w1, #0x4c               ; =76
    1df0: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1df4: f9400084     	ldr	x4, [x4]
    1df8: aa1603e0     	mov	x0, x22
    1dfc: aa1303e2     	mov	x2, x19
    1e00: d63f0080     	blr	x4
    1e04: 34ffd3a0     	cbz	w0, 0x1878 <___pl_fn_4+0x4ec>
    1e08: 140000b6     	b	0x20e0 <___pl_fn_4+0xd54>
    1e0c: 528009c1     	mov	w1, #0x4e               ; =78
    1e10: 52800023     	mov	w3, #0x1                ; =1
    1e14: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1e18: f9400084     	ldr	x4, [x4]
    1e1c: aa1603e0     	mov	x0, x22
    1e20: aa1303e2     	mov	x2, x19
    1e24: d63f0080     	blr	x4
    1e28: 34ffd4a0     	cbz	w0, 0x18bc <___pl_fn_4+0x530>
    1e2c: 140000ad     	b	0x20e0 <___pl_fn_4+0xd54>
    1e30: d2800020     	mov	x0, #0x1                ; =1
    1e34: 910183e3     	add	x3, sp, #0x60
    1e38: f80603e0     	stur	x0, [sp, #0x60]
    1e3c: d2803e80     	mov	x0, #0x1f4              ; =500
    1e40: f80683e0     	stur	x0, [sp, #0x68]
    1e44: 528009e1     	mov	w1, #0x4f               ; =79
    1e48: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1e4c: f9400084     	ldr	x4, [x4]
    1e50: aa1603e0     	mov	x0, x22
    1e54: aa1303e2     	mov	x2, x19
    1e58: d63f0080     	blr	x4
    1e5c: 34ffd5a0     	cbz	w0, 0x1910 <___pl_fn_4+0x584>
    1e60: 140000a0     	b	0x20e0 <___pl_fn_4+0xd54>
    1e64: 52800a01     	mov	w1, #0x50               ; =80
    1e68: 52800063     	mov	w3, #0x3                ; =3
    1e6c: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1e70: f9400084     	ldr	x4, [x4]
    1e74: aa1603e0     	mov	x0, x22
    1e78: aa1303e2     	mov	x2, x19
    1e7c: d63f0080     	blr	x4
    1e80: 34ffd660     	cbz	w0, 0x194c <___pl_fn_4+0x5c0>
    1e84: 14000097     	b	0x20e0 <___pl_fn_4+0xd54>
    1e88: d2800064     	mov	x4, #0x3                ; =3
    1e8c: 9101c3e3     	add	x3, sp, #0x70
    1e90: f80703e4     	stur	x4, [sp, #0x70]
    1e94: f80783e0     	stur	x0, [sp, #0x78]
    1e98: 52800a81     	mov	w1, #0x54               ; =84
    1e9c: 90000005     	adrp	x5, 0x1000 <___pl_fn_3+0x394>
    1ea0: f94000a5     	ldr	x5, [x5]
    1ea4: aa1603e0     	mov	x0, x22
    1ea8: aa1303e2     	mov	x2, x19
    1eac: d63f00a0     	blr	x5
    1eb0: 34ffdae0     	cbz	w0, 0x1a0c <___pl_fn_4+0x680>
    1eb4: 1400008b     	b	0x20e0 <___pl_fn_4+0xd54>
    1eb8: 52800ac1     	mov	w1, #0x56               ; =86
    1ebc: 52800023     	mov	w3, #0x1                ; =1
    1ec0: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1ec4: f9400084     	ldr	x4, [x4]
    1ec8: aa1603e0     	mov	x0, x22
    1ecc: aa1303e2     	mov	x2, x19
    1ed0: d63f0080     	blr	x4
    1ed4: 34ffdbe0     	cbz	w0, 0x1a50 <___pl_fn_4+0x6c4>
    1ed8: 14000082     	b	0x20e0 <___pl_fn_4+0xd54>
    1edc: d2800020     	mov	x0, #0x1                ; =1
    1ee0: 910203e3     	add	x3, sp, #0x80
    1ee4: f80803e0     	stur	x0, [sp, #0x80]
    1ee8: f80883f9     	stur	x25, [sp, #0x88]
    1eec: 52800ae1     	mov	w1, #0x57               ; =87
    1ef0: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1ef4: f9400084     	ldr	x4, [x4]
    1ef8: aa1603e0     	mov	x0, x22
    1efc: aa1303e2     	mov	x2, x19
    1f00: d63f0080     	blr	x4
    1f04: 34ffdd20     	cbz	w0, 0x1aa8 <___pl_fn_4+0x71c>
    1f08: 14000076     	b	0x20e0 <___pl_fn_4+0xd54>
    1f0c: 52800b01     	mov	w1, #0x58               ; =88
    1f10: 52800063     	mov	w3, #0x3                ; =3
    1f14: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x394>
    1f18: f9400084     	ldr	x4, [x4]
    1f1c: aa1603e0     	mov	x0, x22
    1f20: aa1303e2     	mov	x2, x19
    1f24: d63f0080     	blr	x4
    1f28: 34ffdde0     	cbz	w0, 0x1ae4 <___pl_fn_4+0x758>
    1f2c: 1400006d     	b	0x20e0 <___pl_fn_4+0xd54>
    1f30: d2800064     	mov	x4, #0x3                ; =3
    1f34: 910243e3     	add	x3, sp, #0x90
    1f38: f80903e4     	stur	x4, [sp, #0x90]
    1f3c: f80983e0     	stur	x0, [sp, #0x98]
    1f40: 52800b61     	mov	w1, #0x5b               ; =91
    1f44: 90000006     	adrp	x6, 0x1000 <___pl_fn_3+0x394>
    1f48: f94000c6     	ldr	x6, [x6]
    1f4c: aa1303e2     	mov	x2, x19
    1f50: aa1603e0     	mov	x0, x22
    1f54: d63f00c0     	blr	x6
    1f58: 34ffe1e0     	cbz	w0, 0x1b94 <___pl_fn_4+0x808>
    1f5c: 14000061     	b	0x20e0 <___pl_fn_4+0xd54>
    1f60: 52800b41     	mov	w1, #0x5a               ; =90
    1f64: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x394>
    1f68: f9400042     	ldr	x2, [x2]
    1f6c: aa1603e0     	mov	x0, x22
    1f70: d63f0040     	blr	x2
    1f74: 52800000     	mov	w0, #0x0                ; =0
    1f78: 910283ff     	add	sp, sp, #0xa0
    1f7c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1f80: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1f84: f84107f9     	ldr	x25, [sp], #0x10
    1f88: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1f8c: d65f03c0     	ret
    1f90: 52800b21     	mov	w1, #0x59               ; =89
    1f94: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x394>
    1f98: f9400042     	ldr	x2, [x2]
    1f9c: aa1603e0     	mov	x0, x22
    1fa0: d63f0040     	blr	x2
    1fa4: 52800000     	mov	w0, #0x0                ; =0
    1fa8: 910283ff     	add	sp, sp, #0xa0
    1fac: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1fb0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1fb4: f84107f9     	ldr	x25, [sp], #0x10
    1fb8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1fbc: d65f03c0     	ret
    1fc0: 52800a61     	mov	w1, #0x53               ; =83
    1fc4: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x394>
    1fc8: f9400042     	ldr	x2, [x2]
    1fcc: aa1603e0     	mov	x0, x22
    1fd0: d63f0040     	blr	x2
    1fd4: 52800000     	mov	w0, #0x0                ; =0
    1fd8: 910283ff     	add	sp, sp, #0xa0
    1fdc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1fe0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1fe4: f84107f9     	ldr	x25, [sp], #0x10
    1fe8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1fec: d65f03c0     	ret
    1ff0: 52800a41     	mov	w1, #0x52               ; =82
    1ff4: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x394>
    1ff8: f9400042     	ldr	x2, [x2]
    1ffc: aa1603e0     	mov	x0, x22
    2000: d63f0040     	blr	x2
    2004: 52800000     	mov	w0, #0x0                ; =0
    2008: 910283ff     	add	sp, sp, #0xa0
    200c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2010: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2014: f84107f9     	ldr	x25, [sp], #0x10
    2018: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    201c: d65f03c0     	ret
    2020: 52800a21     	mov	w1, #0x51               ; =81
    2024: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc74>
    2028: f9400042     	ldr	x2, [x2]
    202c: aa1603e0     	mov	x0, x22
    2030: d63f0040     	blr	x2
    2034: 52800000     	mov	w0, #0x0                ; =0
    2038: 910283ff     	add	sp, sp, #0xa0
    203c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2040: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2044: f84107f9     	ldr	x25, [sp], #0x10
    2048: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    204c: d65f03c0     	ret
    2050: 52800961     	mov	w1, #0x4b               ; =75
    2054: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc74>
    2058: f9400042     	ldr	x2, [x2]
    205c: aa1603e0     	mov	x0, x22
    2060: d63f0040     	blr	x2
    2064: 52800000     	mov	w0, #0x0                ; =0
    2068: 910283ff     	add	sp, sp, #0xa0
    206c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2070: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2074: f84107f9     	ldr	x25, [sp], #0x10
    2078: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    207c: d65f03c0     	ret
    2080: 52800941     	mov	w1, #0x4a               ; =74
    2084: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc74>
    2088: f9400042     	ldr	x2, [x2]
    208c: aa1603e0     	mov	x0, x22
    2090: d63f0040     	blr	x2
    2094: 52800000     	mov	w0, #0x0                ; =0
    2098: 910283ff     	add	sp, sp, #0xa0
    209c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    20a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    20a4: f84107f9     	ldr	x25, [sp], #0x10
    20a8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    20ac: d65f03c0     	ret
    20b0: 52800881     	mov	w1, #0x44               ; =68
    20b4: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc74>
    20b8: f9400042     	ldr	x2, [x2]
    20bc: aa1603e0     	mov	x0, x22
    20c0: d63f0040     	blr	x2
    20c4: 52800000     	mov	w0, #0x0                ; =0
    20c8: 910283ff     	add	sp, sp, #0xa0
    20cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    20d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    20d4: f84107f9     	ldr	x25, [sp], #0x10
    20d8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    20dc: d65f03c0     	ret
    20e0: 52800000     	mov	w0, #0x0                ; =0
    20e4: 910283ff     	add	sp, sp, #0xa0
    20e8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    20ec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    20f0: f84107f9     	ldr	x25, [sp], #0x10
    20f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    20f8: d65f03c0     	ret
    20fc: 52800861     	mov	w1, #0x43               ; =67
    2100: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc74>
    2104: f9400042     	ldr	x2, [x2]
    2108: aa1603e0     	mov	x0, x22
    210c: d63f0040     	blr	x2
    2110: 52800000     	mov	w0, #0x0                ; =0
    2114: 910283ff     	add	sp, sp, #0xa0
    2118: a8c153f3     	ldp	x19, x20, [sp], #0x10
    211c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2120: f84107f9     	ldr	x25, [sp], #0x10
    2124: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2128: d65f03c0     	ret
    212c: 52800841     	mov	w1, #0x42               ; =66
    2130: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc74>
    2134: f9400042     	ldr	x2, [x2]
    2138: aa1603e0     	mov	x0, x22
    213c: d63f0040     	blr	x2
    2140: 52800000     	mov	w0, #0x0                ; =0
    2144: 910283ff     	add	sp, sp, #0xa0
    2148: a8c153f3     	ldp	x19, x20, [sp], #0x10
    214c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2150: f84107f9     	ldr	x25, [sp], #0x10
    2154: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2158: d65f03c0     	ret
    215c: 528007a1     	mov	w1, #0x3d               ; =61
    2160: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc74>
    2164: f9400042     	ldr	x2, [x2]
    2168: aa1603e0     	mov	x0, x22
    216c: d63f0040     	blr	x2
    2170: 52800000     	mov	w0, #0x0                ; =0
    2174: 910283ff     	add	sp, sp, #0xa0
    2178: a8c153f3     	ldp	x19, x20, [sp], #0x10
    217c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2180: f84107f9     	ldr	x25, [sp], #0x10
    2184: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2188: d65f03c0     	ret
    218c: 52800721     	mov	w1, #0x39               ; =57
    2190: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc74>
    2194: f9400042     	ldr	x2, [x2]
    2198: aa1603e0     	mov	x0, x22
    219c: d63f0040     	blr	x2
    21a0: 52800000     	mov	w0, #0x0                ; =0
    21a4: 910283ff     	add	sp, sp, #0xa0
    21a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    21ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    21b0: f84107f9     	ldr	x25, [sp], #0x10
    21b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    21b8: d65f03c0     	ret
