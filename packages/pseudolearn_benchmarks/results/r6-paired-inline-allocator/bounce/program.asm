
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_94328/bounce/program.o:	file format mach-o arm64

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
      88: f81f0ffb     	str	x27, [sp, #-0x10]!
      8c: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
      90: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      94: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      98: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      9c: d100c3ff     	sub	sp, sp, #0x30
      a0: b9401001     	ldr	w1, [x0, #0x10]
      a4: 11000421     	add	w1, w1, #0x1
      a8: b9001001     	str	w1, [x0, #0x10]
      ac: aa0003fa     	mov	x26, x0
      b0: d2800c80     	mov	x0, #0x64               ; =100
      b4: 910003e3     	mov	x3, sp
      b8: f80003e0     	stur	x0, [sp]
      bc: 52800021     	mov	w1, #0x1                ; =1
      c0: 52802082     	mov	w2, #0x104              ; =260
      c4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      c8: f9400084     	ldr	x4, [x4]
      cc: aa1a03e0     	mov	x0, x26
      d0: d63f0080     	blr	x4
      d4: 35004960     	cbnz	w0, 0xa00 <___pl_fn_1+0x980>
      d8: aa1a03e0     	mov	x0, x26
      dc: f9401813     	ldr	x19, [x0, #0x30]
      e0: b9401816     	ldr	w22, [x0, #0x18]
      e4: b9401c00     	ldr	w0, [x0, #0x1c]
      e8: 110006d7     	add	w23, w22, #0x1
      ec: 6b0002ff     	cmp	w23, w0
      f0: 540046e8     	b.hi	0x9cc <___pl_fn_1+0x94c>
      f4: aa1a03e0     	mov	x0, x26
      f8: f9401000     	ldr	x0, [x0, #0x20]
      fc: b8365813     	str	w19, [x0, w22, uxtw #2]
     100: aa1a03e0     	mov	x0, x26
     104: b9001817     	str	w23, [x0, #0x18]
     108: 52800061     	mov	w1, #0x3                ; =3
     10c: 52800002     	mov	w2, #0x0                ; =0
     110: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     114: f9400063     	ldr	x3, [x3]
     118: d63f0060     	blr	x3
     11c: 35004720     	cbnz	w0, 0xa00 <___pl_fn_1+0x980>
     120: aa1a03e0     	mov	x0, x26
     124: f9401814     	ldr	x20, [x0, #0x30]
     128: b9001816     	str	w22, [x0, #0x18]
     12c: f9403c03     	ldr	x3, [x0, #0x78]
     130: 37202a63     	tbnz	w3, #0x4, 0x67c <___pl_fn_1+0x5fc>
     134: aa1a03e0     	mov	x0, x26
     138: f9403805     	ldr	x5, [x0, #0x70]
     13c: f10000bf     	cmp	x5, #0x0
     140: 54002a2d     	b.le	0x684 <___pl_fn_1+0x604>
     144: aa1a03e0     	mov	x0, x26
     148: f9403408     	ldr	x8, [x0, #0x68]
     14c: f100091f     	cmp	x8, #0x2
     150: 540029eb     	b.lt	0x68c <___pl_fn_1+0x60c>
     154: aa1a03e0     	mov	x0, x26
     158: f9402815     	ldr	x21, [x0, #0x50]
     15c: f9402c0b     	ldr	x11, [x0, #0x58]
     160: 910012ac     	add	x12, x21, #0x4
     164: eb0b019f     	cmp	x12, x11
     168: 54002968     	b.hi	0x694 <___pl_fn_1+0x614>
     16c: aa1a03e0     	mov	x0, x26
     170: f940440e     	ldr	x14, [x0, #0x88]
     174: f940480f     	ldr	x15, [x0, #0x90]
     178: eb0f01df     	cmp	x14, x15
     17c: 54002902     	b.hs	0x69c <___pl_fn_1+0x61c>
     180: aa1a03e0     	mov	x0, x26
     184: b9401c00     	ldr	w0, [x0, #0x1c]
     188: 6b0002ff     	cmp	w23, w0
     18c: 54000229     	b.ls	0x1d0 <___pl_fn_1+0x150>
     190: 14000145     	b	0x6a4 <___pl_fn_1+0x624>
     194: aa1a03e0     	mov	x0, x26
     198: f9401000     	ldr	x0, [x0, #0x20]
     19c: b8365813     	str	w19, [x0, w22, uxtw #2]
     1a0: aa1a03e0     	mov	x0, x26
     1a4: b9001817     	str	w23, [x0, #0x18]
     1a8: 528000a1     	mov	w1, #0x5                ; =5
     1ac: 52800002     	mov	w2, #0x0                ; =0
     1b0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     1b4: f9400063     	ldr	x3, [x3]
     1b8: d63f0060     	blr	x3
     1bc: 35004220     	cbnz	w0, 0xa00 <___pl_fn_1+0x980>
     1c0: aa1a03e0     	mov	x0, x26
     1c4: f9401815     	ldr	x21, [x0, #0x30]
     1c8: b9001816     	str	w22, [x0, #0x18]
     1cc: 14000026     	b	0x264 <___pl_fn_1+0x1e4>
     1d0: aa1a03e0     	mov	x0, x26
     1d4: f9403002     	ldr	x2, [x0, #0x60]
     1d8: f9400003     	ldr	x3, [x0]
     1dc: b20007e4     	mov	x4, #0x300000003        ; =12884901891
     1e0: 2a1503e0     	mov	w0, w21
     1e4: 8b000c61     	add	x1, x3, x0, lsl #3
     1e8: f8355864     	str	x4, [x3, w21, uxtw #3]
     1ec: 91000442     	add	x2, x2, #0x1
     1f0: f9000422     	str	x2, [x1, #0x8]
     1f4: 92800003     	mov	x3, #-0x1               ; =-1
     1f8: f9000823     	str	x3, [x1, #0x10]
     1fc: d2800003     	mov	x3, #0x0                ; =0
     200: f9000c23     	str	x3, [x1, #0x18]
     204: aa1a03e1     	mov	x1, x26
     208: f9003022     	str	x2, [x1, #0x60]
     20c: 910012a1     	add	x1, x21, #0x4
     210: aa1a03e2     	mov	x2, x26
     214: f9002841     	str	x1, [x2, #0x50]
     218: aa1a03e1     	mov	x1, x26
     21c: f9403421     	ldr	x1, [x1, #0x68]
     220: d1000821     	sub	x1, x1, #0x2
     224: f9003441     	str	x1, [x2, #0x68]
     228: aa1a03e1     	mov	x1, x26
     22c: f9403821     	ldr	x1, [x1, #0x70]
     230: d1000821     	sub	x1, x1, #0x2
     234: f9003841     	str	x1, [x2, #0x70]
     238: aa1a03e1     	mov	x1, x26
     23c: f9404021     	ldr	x1, [x1, #0x80]
     240: b25e0000     	orr	x0, x0, #0x400000000
     244: d37cedc3     	lsl	x3, x14, #4
     248: 8b0e1022     	add	x2, x1, x14, lsl #4
     24c: f8236820     	str	x0, [x1, x3]
     250: d2800040     	mov	x0, #0x2                ; =2
     254: f9000440     	str	x0, [x2, #0x8]
     258: 910005c0     	add	x0, x14, #0x1
     25c: aa1a03e3     	mov	x3, x26
     260: f9004460     	str	x0, [x3, #0x88]
     264: 340039b5     	cbz	w21, 0x998 <___pl_fn_1+0x918>
     268: 34002435     	cbz	w21, 0x6ec <___pl_fn_1+0x66c>
     26c: aa1a03e0     	mov	x0, x26
     270: f9400001     	ldr	x1, [x0]
     274: 2a1503e0     	mov	w0, w21
     278: 8b000c20     	add	x0, x1, x0, lsl #3
     27c: f8755821     	ldr	x1, [x1, w21, uxtw #3]
     280: d360fc21     	lsr	x1, x1, #32
     284: 92403c22     	and	x2, x1, #0xffff
     288: f100085f     	cmp	x2, #0x2
     28c: 54000080     	b.eq	0x29c <___pl_fn_1+0x21c>
     290: f9400802     	ldr	x2, [x0, #0x10]
     294: 927ff842     	and	x2, x2, #0xfffffffffffffffe
     298: f9000802     	str	x2, [x0, #0x10]
     29c: 52848062     	mov	w2, #0x2403             ; =9219
     2a0: 72a00022     	movk	w2, #0x1, lsl #16
     2a4: 92403c21     	and	x1, x1, #0xffff
     2a8: f8217802     	str	x2, [x0, x1, lsl #3]
     2ac: d2800016     	mov	x22, #0x0               ; =0
     2b0: 52800020     	mov	w0, #0x1                ; =1
     2b4: f1018edf     	cmp	x22, #0x63
     2b8: 9a9fc7e1     	cset	x1, le
     2bc: 72001c3f     	tst	w1, #0xff
     2c0: 54000d01     	b.ne	0x460 <___pl_fn_1+0x3e0>
     2c4: d2800035     	mov	x21, #0x1               ; =1
     2c8: d2800002     	mov	x2, #0x0                ; =0
     2cc: aa0203fb     	mov	x27, x2
     2d0: 52800021     	mov	w1, #0x1                ; =1
     2d4: aa1503f7     	mov	x23, x21
     2d8: aa0103f8     	mov	x24, x1
     2dc: eb1402ff     	cmp	x23, x20
     2e0: 9a9fc7e0     	cset	x0, le
     2e4: 72001c1f     	tst	w0, #0xff
     2e8: 540002a1     	b.ne	0x33c <___pl_fn_1+0x2bc>
     2ec: 52800141     	mov	w1, #0xa                ; =10
     2f0: 52802003     	mov	w3, #0x100              ; =256
     2f4: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     2f8: f94000c6     	ldr	x6, [x6]
     2fc: aa1b03e2     	mov	x2, x27
     300: aa1a03e0     	mov	x0, x26
     304: d63f00c0     	blr	x6
     308: 350037c0     	cbnz	w0, 0xa00 <___pl_fn_1+0x980>
     30c: aa1a03e0     	mov	x0, x26
     310: b9401008     	ldr	w8, [x0, #0x10]
     314: 51000508     	sub	w8, w8, #0x1
     318: b9001008     	str	w8, [x0, #0x10]
     31c: 9100c3ff     	add	sp, sp, #0x30
     320: a8c153f3     	ldp	x19, x20, [sp], #0x10
     324: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     328: a8c163f7     	ldp	x23, x24, [sp], #0x10
     32c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     330: f84107fb     	ldr	x27, [sp], #0x10
     334: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     338: d65f03c0     	ret
     33c: d2800016     	mov	x22, #0x0               ; =0
     340: 52800020     	mov	w0, #0x1                ; =1
     344: f1018edf     	cmp	x22, #0x63
     348: 9a9fc7e3     	cset	x3, le
     34c: 72001c7f     	tst	w3, #0xff
     350: 540000e1     	b.ne	0x36c <___pl_fn_1+0x2ec>
     354: ab1502f7     	adds	x23, x23, x21
     358: 9a9f77e1     	cset	x1, vs
     35c: 72001c3f     	tst	w1, #0xff
     360: 54001e21     	b.ne	0x724 <___pl_fn_1+0x6a4>
     364: 52800021     	mov	w1, #0x1                ; =1
     368: 17ffffdd     	b	0x2dc <___pl_fn_1+0x25c>
     36c: 34001f73     	cbz	w19, 0x758 <___pl_fn_1+0x6d8>
     370: aa1a03e0     	mov	x0, x26
     374: f9400000     	ldr	x0, [x0]
     378: 2a1303e1     	mov	w1, w19
     37c: 8b010c00     	add	x0, x0, x1, lsl #3
     380: f9400801     	ldr	x1, [x0, #0x10]
     384: eb0102df     	cmp	x22, x1
     388: 54001e82     	b.hs	0x758 <___pl_fn_1+0x6d8>
     38c: 8b160c00     	add	x0, x0, x22, lsl #3
     390: b9402801     	ldr	w1, [x0, #0x28]
     394: 350000a1     	cbnz	w1, 0x3a8 <___pl_fn_1+0x328>
     398: 140000f0     	b	0x758 <___pl_fn_1+0x6d8>
     39c: aa1a03e0     	mov	x0, x26
     3a0: f9401801     	ldr	x1, [x0, #0x30]
     3a4: 14000002     	b	0x3ac <___pl_fn_1+0x32c>
     3a8: aa1a03e0     	mov	x0, x26
     3ac: aa1a03e0     	mov	x0, x26
     3b0: b9401819     	ldr	w25, [x0, #0x18]
     3b4: b9401c00     	ldr	w0, [x0, #0x1c]
     3b8: 11000b22     	add	w2, w25, #0x2
     3bc: 6b00005f     	cmp	w2, w0
     3c0: 540022e8     	b.hi	0x81c <___pl_fn_1+0x79c>
     3c4: aa1a03e0     	mov	x0, x26
     3c8: f9401000     	ldr	x0, [x0, #0x20]
     3cc: 2a1903e2     	mov	w2, w25
     3d0: 8b020802     	add	x2, x0, x2, lsl #2
     3d4: b8395813     	str	w19, [x0, w25, uxtw #2]
     3d8: b9000441     	str	w1, [x2, #0x4]
     3dc: 11000b20     	add	w0, w25, #0x2
     3e0: aa1a03e6     	mov	x6, x26
     3e4: b90018c0     	str	w0, [x6, #0x18]
     3e8: aa1a03e0     	mov	x0, x26
     3ec: b9401000     	ldr	w0, [x0, #0x10]
     3f0: aa1a03ea     	mov	x10, x26
     3f4: b9401542     	ldr	w2, [x10, #0x14]
     3f8: 6b02001f     	cmp	w0, w2
     3fc: 54001f62     	b.hs	0x7e8 <___pl_fn_1+0x768>
     400: aa1a03e0     	mov	x0, x26
     404: 94000000     	bl	0x404 <___pl_fn_1+0x384>
     408: aa1a03ef     	mov	x15, x26
     40c: b9402de1     	ldr	w1, [x15, #0x2c]
     410: 35002f81     	cbnz	w1, 0xa00 <___pl_fn_1+0x980>
     414: aa1a03e1     	mov	x1, x26
     418: b9001839     	str	w25, [x1, #0x18]
     41c: 72001c1f     	tst	w0, #0xff
     420: 54000061     	b.ne	0x42c <___pl_fn_1+0x3ac>
     424: aa1b03e2     	mov	x2, x27
     428: 14000007     	b	0x444 <___pl_fn_1+0x3c4>
     42c: aa1b03e2     	mov	x2, x27
     430: ab150042     	adds	x2, x2, x21
     434: 9a9f77e0     	cset	x0, vs
     438: 72001c1f     	tst	w0, #0xff
     43c: 54001bc1     	b.ne	0x7b4 <___pl_fn_1+0x734>
     440: 52800038     	mov	w24, #0x1               ; =1
     444: ab1502d6     	adds	x22, x22, x21
     448: 9a9f77e0     	cset	x0, vs
     44c: 72001c1f     	tst	w0, #0xff
     450: 54001981     	b.ne	0x780 <___pl_fn_1+0x700>
     454: 52800020     	mov	w0, #0x1                ; =1
     458: aa0203fb     	mov	x27, x2
     45c: 17ffffba     	b	0x344 <___pl_fn_1+0x2c4>
     460: aa1a03e0     	mov	x0, x26
     464: f9403c00     	ldr	x0, [x0, #0x78]
     468: 37381f40     	tbnz	w0, #0x7, 0x850 <___pl_fn_1+0x7d0>
     46c: aa1a03e0     	mov	x0, x26
     470: f9403800     	ldr	x0, [x0, #0x70]
     474: f100001f     	cmp	x0, #0x0
     478: 54001f0d     	b.le	0x858 <___pl_fn_1+0x7d8>
     47c: aa1a03e0     	mov	x0, x26
     480: f9403400     	ldr	x0, [x0, #0x68]
     484: f100141f     	cmp	x0, #0x5
     488: 54001ecb     	b.lt	0x860 <___pl_fn_1+0x7e0>
     48c: aa1a03e0     	mov	x0, x26
     490: f9402801     	ldr	x1, [x0, #0x50]
     494: f9402c02     	ldr	x2, [x0, #0x58]
     498: 91001c23     	add	x3, x1, #0x7
     49c: eb02007f     	cmp	x3, x2
     4a0: 54001e48     	b.hi	0x868 <___pl_fn_1+0x7e8>
     4a4: aa1a03e0     	mov	x0, x26
     4a8: f9404404     	ldr	x4, [x0, #0x88]
     4ac: f9404805     	ldr	x5, [x0, #0x90]
     4b0: eb05009f     	cmp	x4, x5
     4b4: 54001de2     	b.hs	0x870 <___pl_fn_1+0x7f0>
     4b8: aa1a03e0     	mov	x0, x26
     4bc: b9401807     	ldr	w7, [x0, #0x18]
     4c0: b9401c08     	ldr	w8, [x0, #0x1c]
     4c4: 110008e7     	add	w7, w7, #0x2
     4c8: 6b0800ff     	cmp	w7, w8
     4cc: 54000289     	b.ls	0x51c <___pl_fn_1+0x49c>
     4d0: 140000ea     	b	0x878 <___pl_fn_1+0x7f8>
     4d4: aa1a03e0     	mov	x0, x26
     4d8: f940100c     	ldr	x12, [x0, #0x20]
     4dc: 2a1703ed     	mov	w13, w23
     4e0: 8b0d098d     	add	x13, x12, x13, lsl #2
     4e4: b8375993     	str	w19, [x12, w23, uxtw #2]
     4e8: b90005b5     	str	w21, [x13, #0x4]
     4ec: 11000aee     	add	w14, w23, #0x2
     4f0: b900180e     	str	w14, [x0, #0x18]
     4f4: 52800261     	mov	w1, #0x13               ; =19
     4f8: 52800022     	mov	w2, #0x1                ; =1
     4fc: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     500: f94001ef     	ldr	x15, [x15]
     504: d63f01e0     	blr	x15
     508: 350027c0     	cbnz	w0, 0xa00 <___pl_fn_1+0x980>
     50c: aa1a03e0     	mov	x0, x26
     510: f9401801     	ldr	x1, [x0, #0x30]
     514: b9001817     	str	w23, [x0, #0x18]
     518: 1400002b     	b	0x5c4 <___pl_fn_1+0x544>
     51c: aa1a03e0     	mov	x0, x26
     520: f9403003     	ldr	x3, [x0, #0x60]
     524: f9400005     	ldr	x5, [x0]
     528: d2800086     	mov	x6, #0x4                ; =4
     52c: f2c00066     	movk	x6, #0x3, lsl #32
     530: 2a0103e0     	mov	w0, w1
     534: 8b000ca2     	add	x2, x5, x0, lsl #3
     538: f82158a6     	str	x6, [x5, w1, uxtw #3]
     53c: 91000463     	add	x3, x3, #0x1
     540: f9000443     	str	x3, [x2, #0x8]
     544: 92800005     	mov	x5, #-0x1               ; =-1
     548: f9000845     	str	x5, [x2, #0x10]
     54c: d2800005     	mov	x5, #0x0                ; =0
     550: f9000c45     	str	x5, [x2, #0x18]
     554: f9001045     	str	x5, [x2, #0x20]
     558: f9001445     	str	x5, [x2, #0x28]
     55c: f9001845     	str	x5, [x2, #0x30]
     560: aa1a03e2     	mov	x2, x26
     564: f9003043     	str	x3, [x2, #0x60]
     568: 91001c22     	add	x2, x1, #0x7
     56c: aa1a03e3     	mov	x3, x26
     570: f9002862     	str	x2, [x3, #0x50]
     574: aa1a03e2     	mov	x2, x26
     578: f9403442     	ldr	x2, [x2, #0x68]
     57c: d1001442     	sub	x2, x2, #0x5
     580: f9003462     	str	x2, [x3, #0x68]
     584: aa1a03e2     	mov	x2, x26
     588: f9403842     	ldr	x2, [x2, #0x70]
     58c: d1001442     	sub	x2, x2, #0x5
     590: f9003862     	str	x2, [x3, #0x70]
     594: aa1a03e2     	mov	x2, x26
     598: f9404042     	ldr	x2, [x2, #0x80]
     59c: b2600800     	orr	x0, x0, #0x700000000
     5a0: d37cec85     	lsl	x5, x4, #4
     5a4: 8b041043     	add	x3, x2, x4, lsl #4
     5a8: f8256840     	str	x0, [x2, x5]
     5ac: d28000a0     	mov	x0, #0x5                ; =5
     5b0: f9000460     	str	x0, [x3, #0x8]
     5b4: 91000480     	add	x0, x4, #0x1
     5b8: aa1a03e2     	mov	x2, x26
     5bc: f9004440     	str	x0, [x2, #0x88]
     5c0: aa1a03e0     	mov	x0, x26
     5c4: aa1a03e0     	mov	x0, x26
     5c8: b9401817     	ldr	w23, [x0, #0x18]
     5cc: b9401c02     	ldr	w2, [x0, #0x1c]
     5d0: 11000ee0     	add	w0, w23, #0x3
     5d4: 6b02001f     	cmp	w0, w2
     5d8: 54001c68     	b.hi	0x964 <___pl_fn_1+0x8e4>
     5dc: aa1a03e2     	mov	x2, x26
     5e0: f9401042     	ldr	x2, [x2, #0x20]
     5e4: 2a1703e3     	mov	w3, w23
     5e8: 8b030843     	add	x3, x2, x3, lsl #2
     5ec: b8375853     	str	w19, [x2, w23, uxtw #2]
     5f0: b9000475     	str	w21, [x3, #0x4]
     5f4: b9000861     	str	w1, [x3, #0x8]
     5f8: aa1a03e2     	mov	x2, x26
     5fc: b9001840     	str	w0, [x2, #0x18]
     600: aa1a03e0     	mov	x0, x26
     604: b9401000     	ldr	w0, [x0, #0x10]
     608: b9401442     	ldr	w2, [x2, #0x14]
     60c: 6b02001f     	cmp	w0, w2
     610: 54001902     	b.hs	0x930 <___pl_fn_1+0x8b0>
     614: aa1a03e0     	mov	x0, x26
     618: aa1503e2     	mov	x2, x21
     61c: 94000000     	bl	0x61c <___pl_fn_1+0x59c>
     620: aa1a03e4     	mov	x4, x26
     624: b9402c81     	ldr	w1, [x4, #0x2c]
     628: 35001ec1     	cbnz	w1, 0xa00 <___pl_fn_1+0x980>
     62c: aa1a03e8     	mov	x8, x26
     630: b9001917     	str	w23, [x8, #0x18]
     634: 340014d3     	cbz	w19, 0x8cc <___pl_fn_1+0x84c>
     638: aa1a03ec     	mov	x12, x26
     63c: f9400181     	ldr	x1, [x12]
     640: 2a1303e2     	mov	w2, w19
     644: 8b020c21     	add	x1, x1, x2, lsl #3
     648: f9400822     	ldr	x2, [x1, #0x10]
     64c: eb0202df     	cmp	x22, x2
     650: 540013e2     	b.hs	0x8cc <___pl_fn_1+0x84c>
     654: 2a0003e0     	mov	w0, w0
     658: 8b160c21     	add	x1, x1, x22, lsl #3
     65c: f9001420     	str	x0, [x1, #0x28]
     660: d2800020     	mov	x0, #0x1                ; =1
     664: ab0002d6     	adds	x22, x22, x0
     668: 9a9f77e0     	cset	x0, vs
     66c: 72001c1f     	tst	w0, #0xff
     670: 54001461     	b.ne	0x8fc <___pl_fn_1+0x87c>
     674: 52800020     	mov	w0, #0x1                ; =1
     678: 17ffff0f     	b	0x2b4 <___pl_fn_1+0x234>
     67c: aa1a03e0     	mov	x0, x26
     680: 1400000a     	b	0x6a8 <___pl_fn_1+0x628>
     684: aa1a03e0     	mov	x0, x26
     688: 14000008     	b	0x6a8 <___pl_fn_1+0x628>
     68c: aa1a03e0     	mov	x0, x26
     690: 14000006     	b	0x6a8 <___pl_fn_1+0x628>
     694: aa1a03e0     	mov	x0, x26
     698: 14000004     	b	0x6a8 <___pl_fn_1+0x628>
     69c: aa1a03e0     	mov	x0, x26
     6a0: 14000002     	b	0x6a8 <___pl_fn_1+0x628>
     6a4: aa1a03e0     	mov	x0, x26
     6a8: aa1a03e0     	mov	x0, x26
     6ac: b9401c00     	ldr	w0, [x0, #0x1c]
     6b0: 6b0002ff     	cmp	w23, w0
     6b4: 54ffd709     	b.ls	0x194 <___pl_fn_1+0x114>
     6b8: 52800081     	mov	w1, #0x4                ; =4
     6bc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     6c0: f9400042     	ldr	x2, [x2]
     6c4: aa1a03e0     	mov	x0, x26
     6c8: d63f0040     	blr	x2
     6cc: 9100c3ff     	add	sp, sp, #0x30
     6d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6d8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6dc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6e0: f84107fb     	ldr	x27, [sp], #0x10
     6e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6e8: d65f03c0     	ret
     6ec: d2800000     	mov	x0, #0x0                ; =0
     6f0: 910023e3     	add	x3, sp, #0x8
     6f4: f80083e0     	stur	x0, [sp, #0x8]
     6f8: 52848060     	mov	w0, #0x2403             ; =9219
     6fc: 72a00020     	movk	w0, #0x1, lsl #16
     700: f80103e0     	stur	x0, [sp, #0x10]
     704: 528000e1     	mov	w1, #0x7                ; =7
     708: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     70c: f9400084     	ldr	x4, [x4]
     710: aa1a03e0     	mov	x0, x26
     714: aa1503e2     	mov	x2, x21
     718: d63f0080     	blr	x4
     71c: 34ffdc80     	cbz	w0, 0x2ac <___pl_fn_1+0x22c>
     720: 140000b8     	b	0xa00 <___pl_fn_1+0x980>
     724: 52800181     	mov	w1, #0xc                ; =12
     728: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     72c: f9400042     	ldr	x2, [x2]
     730: aa1a03e0     	mov	x0, x26
     734: d63f0040     	blr	x2
     738: 9100c3ff     	add	sp, sp, #0x30
     73c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     740: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     744: a8c163f7     	ldp	x23, x24, [sp], #0x10
     748: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     74c: f84107fb     	ldr	x27, [sp], #0x10
     750: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     754: d65f03c0     	ret
     758: 910063e3     	add	x3, sp, #0x18
     75c: f80183f6     	stur	x22, [sp, #0x18]
     760: 528001a1     	mov	w1, #0xd                ; =13
     764: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     768: f9400084     	ldr	x4, [x4]
     76c: aa1a03e0     	mov	x0, x26
     770: aa1303e2     	mov	x2, x19
     774: d63f0080     	blr	x4
     778: 34ffe120     	cbz	w0, 0x39c <___pl_fn_1+0x31c>
     77c: 140000a1     	b	0xa00 <___pl_fn_1+0x980>
     780: 52800221     	mov	w1, #0x11               ; =17
     784: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     788: f9400042     	ldr	x2, [x2]
     78c: aa1a03e0     	mov	x0, x26
     790: d63f0040     	blr	x2
     794: 9100c3ff     	add	sp, sp, #0x30
     798: a8c153f3     	ldp	x19, x20, [sp], #0x10
     79c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7a0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7a4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7a8: f84107fb     	ldr	x27, [sp], #0x10
     7ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7b0: d65f03c0     	ret
     7b4: 52800201     	mov	w1, #0x10               ; =16
     7b8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7bc: f9400042     	ldr	x2, [x2]
     7c0: aa1a03e0     	mov	x0, x26
     7c4: d63f0040     	blr	x2
     7c8: 9100c3ff     	add	sp, sp, #0x30
     7cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7d4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7d8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     7dc: f84107fb     	ldr	x27, [sp], #0x10
     7e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     7e4: d65f03c0     	ret
     7e8: 528001e1     	mov	w1, #0xf                ; =15
     7ec: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7f0: f9400042     	ldr	x2, [x2]
     7f4: aa1a03e0     	mov	x0, x26
     7f8: d63f0040     	blr	x2
     7fc: 9100c3ff     	add	sp, sp, #0x30
     800: a8c153f3     	ldp	x19, x20, [sp], #0x10
     804: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     808: a8c163f7     	ldp	x23, x24, [sp], #0x10
     80c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     810: f84107fb     	ldr	x27, [sp], #0x10
     814: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     818: d65f03c0     	ret
     81c: 528001c1     	mov	w1, #0xe                ; =14
     820: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     824: f9400042     	ldr	x2, [x2]
     828: aa1a03e0     	mov	x0, x26
     82c: d63f0040     	blr	x2
     830: 9100c3ff     	add	sp, sp, #0x30
     834: a8c153f3     	ldp	x19, x20, [sp], #0x10
     838: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     83c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     840: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     844: f84107fb     	ldr	x27, [sp], #0x10
     848: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     84c: d65f03c0     	ret
     850: aa1a03e0     	mov	x0, x26
     854: 1400000a     	b	0x87c <___pl_fn_1+0x7fc>
     858: aa1a03e0     	mov	x0, x26
     85c: 14000008     	b	0x87c <___pl_fn_1+0x7fc>
     860: aa1a03e0     	mov	x0, x26
     864: 14000006     	b	0x87c <___pl_fn_1+0x7fc>
     868: aa1a03e0     	mov	x0, x26
     86c: 14000004     	b	0x87c <___pl_fn_1+0x7fc>
     870: aa1a03e0     	mov	x0, x26
     874: 14000002     	b	0x87c <___pl_fn_1+0x7fc>
     878: aa1a03e0     	mov	x0, x26
     87c: aa1a03e0     	mov	x0, x26
     880: b9401817     	ldr	w23, [x0, #0x18]
     884: b9401c0a     	ldr	w10, [x0, #0x1c]
     888: 11000aeb     	add	w11, w23, #0x2
     88c: 6b0a017f     	cmp	w11, w10
     890: 54ffe229     	b.ls	0x4d4 <___pl_fn_1+0x454>
     894: 52800241     	mov	w1, #0x12               ; =18
     898: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     89c: f9400042     	ldr	x2, [x2]
     8a0: aa1a03e0     	mov	x0, x26
     8a4: d63f0040     	blr	x2
     8a8: 9100c3ff     	add	sp, sp, #0x30
     8ac: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8b0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8b4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8b8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8bc: f84107fb     	ldr	x27, [sp], #0x10
     8c0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8c4: d65f03c0     	ret
     8c8: 1400004e     	b	0xa00 <___pl_fn_1+0x980>
     8cc: 910083e3     	add	x3, sp, #0x20
     8d0: f80203f6     	stur	x22, [sp, #0x20]
     8d4: 2a0003e0     	mov	w0, w0
     8d8: f80283e0     	stur	x0, [sp, #0x28]
     8dc: 528002c1     	mov	w1, #0x16               ; =22
     8e0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     8e4: f9400084     	ldr	x4, [x4]
     8e8: aa1a03e0     	mov	x0, x26
     8ec: aa1303e2     	mov	x2, x19
     8f0: d63f0080     	blr	x4
     8f4: 34ffeb60     	cbz	w0, 0x660 <___pl_fn_1+0x5e0>
     8f8: 14000042     	b	0xa00 <___pl_fn_1+0x980>
     8fc: 528002e1     	mov	w1, #0x17               ; =23
     900: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     904: f9400042     	ldr	x2, [x2]
     908: aa1a03e0     	mov	x0, x26
     90c: d63f0040     	blr	x2
     910: 9100c3ff     	add	sp, sp, #0x30
     914: a8c153f3     	ldp	x19, x20, [sp], #0x10
     918: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     91c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     920: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     924: f84107fb     	ldr	x27, [sp], #0x10
     928: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     92c: d65f03c0     	ret
     930: 528002a1     	mov	w1, #0x15               ; =21
     934: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     938: f9400042     	ldr	x2, [x2]
     93c: aa1a03e0     	mov	x0, x26
     940: d63f0040     	blr	x2
     944: 9100c3ff     	add	sp, sp, #0x30
     948: a8c153f3     	ldp	x19, x20, [sp], #0x10
     94c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     950: a8c163f7     	ldp	x23, x24, [sp], #0x10
     954: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     958: f84107fb     	ldr	x27, [sp], #0x10
     95c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     960: d65f03c0     	ret
     964: 52800281     	mov	w1, #0x14               ; =20
     968: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     96c: f9400042     	ldr	x2, [x2]
     970: aa1a03e0     	mov	x0, x26
     974: d63f0040     	blr	x2
     978: 9100c3ff     	add	sp, sp, #0x30
     97c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     980: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     984: a8c163f7     	ldp	x23, x24, [sp], #0x10
     988: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     98c: f84107fb     	ldr	x27, [sp], #0x10
     990: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     994: d65f03c0     	ret
     998: 528000c1     	mov	w1, #0x6                ; =6
     99c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9a0: f9400042     	ldr	x2, [x2]
     9a4: aa1a03e0     	mov	x0, x26
     9a8: d63f0040     	blr	x2
     9ac: 9100c3ff     	add	sp, sp, #0x30
     9b0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9b4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9b8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9bc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9c0: f84107fb     	ldr	x27, [sp], #0x10
     9c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9c8: d65f03c0     	ret
     9cc: 52800041     	mov	w1, #0x2                ; =2
     9d0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     9d4: f9400042     	ldr	x2, [x2]
     9d8: aa1a03e0     	mov	x0, x26
     9dc: d63f0040     	blr	x2
     9e0: 9100c3ff     	add	sp, sp, #0x30
     9e4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9e8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9ec: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9f0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9f4: f84107fb     	ldr	x27, [sp], #0x10
     9f8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9fc: d65f03c0     	ret
     a00: 9100c3ff     	add	sp, sp, #0x30
     a04: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a08: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a0c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a10: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a14: f84107fb     	ldr	x27, [sp], #0x10
     a18: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a1c: d65f03c0     	ret

0000000000000a20 <___pl_fn_2>:
     a20: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     a24: 910003fd     	mov	x29, sp
     a28: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     a2c: d10043ff     	sub	sp, sp, #0x10
     a30: aa0103f3     	mov	x19, x1
     a34: b940100a     	ldr	w10, [x0, #0x10]
     a38: 1100054a     	add	w10, w10, #0x1
     a3c: b900100a     	str	w10, [x0, #0x10]
     a40: aa1303e1     	mov	x1, x19
     a44: 34000961     	cbz	w1, 0xb70 <___pl_fn_2+0x150>
     a48: f940000f     	ldr	x15, [x0]
     a4c: aa1303e1     	mov	x1, x19
     a50: aa0003f4     	mov	x20, x0
     a54: 2a0103ee     	mov	w14, w1
     a58: 8b0e0dee     	add	x14, x15, x14, lsl #3
     a5c: f86159ef     	ldr	x15, [x15, w1, uxtw #3]
     a60: d360fdef     	lsr	x15, x15, #32
     a64: 92403de0     	and	x0, x15, #0xffff
     a68: f86079cf     	ldr	x15, [x14, x0, lsl #3]
     a6c: f100081f     	cmp	x0, #0x2
     a70: 540000c0     	b.eq	0xa88 <___pl_fn_2+0x68>
     a74: f94009c0     	ldr	x0, [x14, #0x10]
     a78: 370007e0     	tbnz	w0, #0x0, 0xb74 <___pl_fn_2+0x154>
     a7c: 14000003     	b	0xa88 <___pl_fn_2+0x68>
     a80: aa1403e0     	mov	x0, x20
     a84: f940180f     	ldr	x15, [x0, #0x30]
     a88: d280a3a1     	mov	x1, #0x51d              ; =1309
     a8c: 9b017de0     	mul	x0, x15, x1
     a90: 9b417de1     	smulh	x1, x15, x1
     a94: eb80fc3f     	cmp	x1, x0, asr #63
     a98: 54000d01     	b.ne	0xc38 <___pl_fn_2+0x218>
     a9c: d286c321     	mov	x1, #0x3619             ; =13849
     aa0: ab010000     	adds	x0, x0, x1
     aa4: 9a9f77e1     	cset	x1, vs
     aa8: 72001c3f     	tst	w1, #0xff
     aac: 54000b21     	b.ne	0xc10 <___pl_fn_2+0x1f0>
     ab0: 34000753     	cbz	w19, 0xb98 <___pl_fn_2+0x178>
     ab4: aa1403eb     	mov	x11, x20
     ab8: f9400162     	ldr	x2, [x11]
     abc: 2a1303e1     	mov	w1, w19
     ac0: 8b010c41     	add	x1, x2, x1, lsl #3
     ac4: f8735842     	ldr	x2, [x2, w19, uxtw #3]
     ac8: d360fc42     	lsr	x2, x2, #32
     acc: 92403c43     	and	x3, x2, #0xffff
     ad0: f100087f     	cmp	x3, #0x2
     ad4: 54000080     	b.eq	0xae4 <___pl_fn_2+0xc4>
     ad8: f9400823     	ldr	x3, [x1, #0x10]
     adc: 927ff863     	and	x3, x3, #0xfffffffffffffffe
     ae0: f9000823     	str	x3, [x1, #0x10]
     ae4: 934ffc03     	asr	x3, x0, #15
     ae8: d370fc63     	lsr	x3, x3, #48
     aec: 8b030003     	add	x3, x0, x3
     af0: 9270bc63     	and	x3, x3, #0xffffffffffff0000
     af4: cb030000     	sub	x0, x0, x3
     af8: 92403c42     	and	x2, x2, #0xffff
     afc: f8227820     	str	x0, [x1, x2, lsl #3]
     b00: 340006f3     	cbz	w19, 0xbdc <___pl_fn_2+0x1bc>
     b04: aa1403e0     	mov	x0, x20
     b08: f9400000     	ldr	x0, [x0]
     b0c: 2a1303e1     	mov	w1, w19
     b10: 8b010c01     	add	x1, x0, x1, lsl #3
     b14: f8735800     	ldr	x0, [x0, w19, uxtw #3]
     b18: d360fc00     	lsr	x0, x0, #32
     b1c: 92403c02     	and	x2, x0, #0xffff
     b20: f8627820     	ldr	x0, [x1, x2, lsl #3]
     b24: f100085f     	cmp	x2, #0x2
     b28: 54000100     	b.eq	0xb48 <___pl_fn_2+0x128>
     b2c: f9400821     	ldr	x1, [x1, #0x10]
     b30: 37000561     	tbnz	w1, #0x0, 0xbdc <___pl_fn_2+0x1bc>
     b34: 14000005     	b	0xb48 <___pl_fn_2+0x128>
     b38: aa1403e0     	mov	x0, x20
     b3c: f9401800     	ldr	x0, [x0, #0x30]
     b40: aa1403e1     	mov	x1, x20
     b44: 14000002     	b	0xb4c <___pl_fn_2+0x12c>
     b48: aa1403e1     	mov	x1, x20
     b4c: aa1403e1     	mov	x1, x20
     b50: b9401021     	ldr	w1, [x1, #0x10]
     b54: 51000421     	sub	w1, w1, #0x1
     b58: aa1403e2     	mov	x2, x20
     b5c: b9001041     	str	w1, [x2, #0x10]
     b60: 910043ff     	add	sp, sp, #0x10
     b64: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b68: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b6c: d65f03c0     	ret
     b70: aa0003f4     	mov	x20, x0
     b74: 52800301     	mov	w1, #0x18               ; =24
     b78: 52800003     	mov	w3, #0x0                ; =0
     b7c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b80: f9400084     	ldr	x4, [x4]
     b84: aa1403e0     	mov	x0, x20
     b88: aa1303e2     	mov	x2, x19
     b8c: d63f0080     	blr	x4
     b90: 34fff780     	cbz	w0, 0xa80 <___pl_fn_2+0x60>
     b94: 1400001a     	b	0xbfc <___pl_fn_2+0x1dc>
     b98: d2800001     	mov	x1, #0x0                ; =0
     b9c: 910003e3     	mov	x3, sp
     ba0: f80003e1     	stur	x1, [sp]
     ba4: 934ffc01     	asr	x1, x0, #15
     ba8: d370fc21     	lsr	x1, x1, #48
     bac: 8b010001     	add	x1, x0, x1
     bb0: 9270bc21     	and	x1, x1, #0xffffffffffff0000
     bb4: cb010000     	sub	x0, x0, x1
     bb8: f80083e0     	stur	x0, [sp, #0x8]
     bbc: 52800381     	mov	w1, #0x1c               ; =28
     bc0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     bc4: f9400084     	ldr	x4, [x4]
     bc8: aa1403e0     	mov	x0, x20
     bcc: aa1303e2     	mov	x2, x19
     bd0: d63f0080     	blr	x4
     bd4: 34fff960     	cbz	w0, 0xb00 <___pl_fn_2+0xe0>
     bd8: 14000009     	b	0xbfc <___pl_fn_2+0x1dc>
     bdc: 528003a1     	mov	w1, #0x1d               ; =29
     be0: 52800003     	mov	w3, #0x0                ; =0
     be4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     be8: f9400084     	ldr	x4, [x4]
     bec: aa1303e2     	mov	x2, x19
     bf0: aa1403e0     	mov	x0, x20
     bf4: d63f0080     	blr	x4
     bf8: 34fffa00     	cbz	w0, 0xb38 <___pl_fn_2+0x118>
     bfc: d2800000     	mov	x0, #0x0                ; =0
     c00: 910043ff     	add	sp, sp, #0x10
     c04: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c08: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c0c: d65f03c0     	ret
     c10: 52800341     	mov	w1, #0x1a               ; =26
     c14: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c18: f9400042     	ldr	x2, [x2]
     c1c: aa1403e0     	mov	x0, x20
     c20: d63f0040     	blr	x2
     c24: d2800000     	mov	x0, #0x0                ; =0
     c28: 910043ff     	add	sp, sp, #0x10
     c2c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c34: d65f03c0     	ret
     c38: 52800321     	mov	w1, #0x19               ; =25
     c3c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c40: f9400042     	ldr	x2, [x2]
     c44: aa1403e0     	mov	x0, x20
     c48: d63f0040     	blr	x2
     c4c: d2800000     	mov	x0, #0x0                ; =0
     c50: 910043ff     	add	sp, sp, #0x10
     c54: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c58: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c5c: d65f03c0     	ret

0000000000000c60 <___pl_fn_3>:
     c60: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     c64: 910003fd     	mov	x29, sp
     c68: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
     c6c: a9bf6bf5     	stp	x21, x26, [sp, #-0x10]!
     c70: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     c74: d10103ff     	sub	sp, sp, #0x40
     c78: aa0203f4     	mov	x20, x2
     c7c: b9401002     	ldr	w2, [x0, #0x10]
     c80: 11000442     	add	w2, w2, #0x1
     c84: b9001002     	str	w2, [x0, #0x10]
     c88: b940181b     	ldr	w27, [x0, #0x18]
     c8c: b9401c02     	ldr	w2, [x0, #0x1c]
     c90: 11000b63     	add	w3, w27, #0x2
     c94: 6b02007f     	cmp	w3, w2
     c98: 540035c8     	b.hi	0x1350 <___pl_fn_3+0x6f0>
     c9c: f9401002     	ldr	x2, [x0, #0x20]
     ca0: 2a1b03e3     	mov	w3, w27
     ca4: 8b030843     	add	x3, x2, x3, lsl #2
     ca8: b83b5841     	str	w1, [x2, w27, uxtw #2]
     cac: aa1403e2     	mov	x2, x20
     cb0: aa0103fc     	mov	x28, x1
     cb4: b9000462     	str	w2, [x3, #0x4]
     cb8: 11000b61     	add	w1, w27, #0x2
     cbc: b9001801     	str	w1, [x0, #0x18]
     cc0: b9401001     	ldr	w1, [x0, #0x10]
     cc4: b9401402     	ldr	w2, [x0, #0x14]
     cc8: aa0003fa     	mov	x26, x0
     ccc: 6b02003f     	cmp	w1, w2
     cd0: 54003282     	b.hs	0x1320 <___pl_fn_3+0x6c0>
     cd4: aa1a03e0     	mov	x0, x26
     cd8: aa1403e1     	mov	x1, x20
     cdc: 94000000     	bl	0xcdc <___pl_fn_3+0x7c>
     ce0: aa1a03e1     	mov	x1, x26
     ce4: b9402c21     	ldr	w1, [x1, #0x2c]
     ce8: 350030e1     	cbnz	w1, 0x1304 <___pl_fn_3+0x6a4>
     cec: aa1a03e1     	mov	x1, x26
     cf0: b900183b     	str	w27, [x1, #0x18]
     cf4: aa1c03f3     	mov	x19, x28
     cf8: 35000093     	cbnz	w19, 0xd08 <___pl_fn_3+0xa8>
     cfc: 140000de     	b	0x1074 <___pl_fn_3+0x414>
     d00: aa1a03e0     	mov	x0, x26
     d04: 1400001a     	b	0xd6c <___pl_fn_3+0x10c>
     d08: aa1a03e1     	mov	x1, x26
     d0c: f9400022     	ldr	x2, [x1]
     d10: 2a1303e1     	mov	w1, w19
     d14: 8b010c41     	add	x1, x2, x1, lsl #3
     d18: f8735842     	ldr	x2, [x2, w19, uxtw #3]
     d1c: d360fc42     	lsr	x2, x2, #32
     d20: 92403c43     	and	x3, x2, #0xffff
     d24: f100087f     	cmp	x3, #0x2
     d28: 54000080     	b.eq	0xd38 <___pl_fn_3+0xd8>
     d2c: f9400823     	ldr	x3, [x1, #0x10]
     d30: 927ff863     	and	x3, x3, #0xfffffffffffffffe
     d34: f9000823     	str	x3, [x1, #0x10]
     d38: d29ef9e3     	mov	x3, #0xf7cf             ; =63439
     d3c: f2bc6a63     	movk	x3, #0xe353, lsl #16
     d40: f2d374a3     	movk	x3, #0x9ba5, lsl #32
     d44: f2e41883     	movk	x3, #0x20c4, lsl #48
     d48: 9b437c03     	smulh	x3, x0, x3
     d4c: 9346fc63     	asr	x3, x3, #6
     d50: d37ffc64     	lsr	x4, x3, #63
     d54: 8b040063     	add	x3, x3, x4
     d58: d2803e84     	mov	x4, #0x1f4              ; =500
     d5c: 9b048060     	msub	x0, x3, x4, x0
     d60: 92403c42     	and	x2, x2, #0xffff
     d64: f8227820     	str	x0, [x1, x2, lsl #3]
     d68: aa1a03e0     	mov	x0, x26
     d6c: aa1a03e0     	mov	x0, x26
     d70: b9401815     	ldr	w21, [x0, #0x18]
     d74: b9401c01     	ldr	w1, [x0, #0x1c]
     d78: 11000aa0     	add	w0, w21, #0x2
     d7c: 6b01001f     	cmp	w0, w1
     d80: 54002aa8     	b.hi	0x12d4 <___pl_fn_3+0x674>
     d84: aa1a03e1     	mov	x1, x26
     d88: f9401021     	ldr	x1, [x1, #0x20]
     d8c: 2a1503e2     	mov	w2, w21
     d90: 8b020822     	add	x2, x1, x2, lsl #2
     d94: b8355833     	str	w19, [x1, w21, uxtw #2]
     d98: b9000454     	str	w20, [x2, #0x4]
     d9c: aa1a03e1     	mov	x1, x26
     da0: b9001820     	str	w0, [x1, #0x18]
     da4: aa1a03e0     	mov	x0, x26
     da8: b9401000     	ldr	w0, [x0, #0x10]
     dac: b9401421     	ldr	w1, [x1, #0x14]
     db0: 6b01001f     	cmp	w0, w1
     db4: 54002782     	b.hs	0x12a4 <___pl_fn_3+0x644>
     db8: aa1a03e0     	mov	x0, x26
     dbc: aa1403e1     	mov	x1, x20
     dc0: 94000000     	bl	0xdc0 <___pl_fn_3+0x160>
     dc4: aa1a03e3     	mov	x3, x26
     dc8: b9402c61     	ldr	w1, [x3, #0x2c]
     dcc: 350029c1     	cbnz	w1, 0x1304 <___pl_fn_3+0x6a4>
     dd0: aa1a03e7     	mov	x7, x26
     dd4: b90018f5     	str	w21, [x7, #0x18]
     dd8: 35000093     	cbnz	w19, 0xde8 <___pl_fn_3+0x188>
     ddc: 140000bc     	b	0x10cc <___pl_fn_3+0x46c>
     de0: aa1a03e0     	mov	x0, x26
     de4: 1400001b     	b	0xe50 <___pl_fn_3+0x1f0>
     de8: aa1a03e1     	mov	x1, x26
     dec: f9400026     	ldr	x6, [x1]
     df0: 2a1303e5     	mov	w5, w19
     df4: 8b050cc5     	add	x5, x6, x5, lsl #3
     df8: f87358c6     	ldr	x6, [x6, w19, uxtw #3]
     dfc: d360fcc6     	lsr	x6, x6, #32
     e00: 92403cc7     	and	x7, x6, #0xffff
     e04: f10008ff     	cmp	x7, #0x2
     e08: 54000080     	b.eq	0xe18 <___pl_fn_3+0x1b8>
     e0c: f94008a8     	ldr	x8, [x5, #0x10]
     e10: 927ef908     	and	x8, x8, #0xfffffffffffffffd
     e14: f90008a8     	str	x8, [x5, #0x10]
     e18: d29ef9ea     	mov	x10, #0xf7cf            ; =63439
     e1c: f2bc6a6a     	movk	x10, #0xe353, lsl #16
     e20: f2d374aa     	movk	x10, #0x9ba5, lsl #32
     e24: f2e4188a     	movk	x10, #0x20c4, lsl #48
     e28: 9b4a7c0a     	smulh	x10, x0, x10
     e2c: 9346fd4a     	asr	x10, x10, #6
     e30: d37ffd4b     	lsr	x11, x10, #63
     e34: 8b0b014a     	add	x10, x10, x11
     e38: d2803e8b     	mov	x11, #0x1f4             ; =500
     e3c: 9b0b814a     	msub	x10, x10, x11, x0
     e40: 92403ccb     	and	x11, x6, #0xffff
     e44: 9100056b     	add	x11, x11, #0x1
     e48: f82b78aa     	str	x10, [x5, x11, lsl #3]
     e4c: aa1a03e0     	mov	x0, x26
     e50: aa1a03e0     	mov	x0, x26
     e54: b9401815     	ldr	w21, [x0, #0x18]
     e58: b9401c0d     	ldr	w13, [x0, #0x1c]
     e5c: 11000aac     	add	w12, w21, #0x2
     e60: 6b0d019f     	cmp	w12, w13
     e64: 54002088     	b.hi	0x1274 <___pl_fn_3+0x614>
     e68: aa1a03e0     	mov	x0, x26
     e6c: f940100e     	ldr	x14, [x0, #0x20]
     e70: 2a1503ef     	mov	w15, w21
     e74: 8b0f09cf     	add	x15, x14, x15, lsl #2
     e78: b83559d3     	str	w19, [x14, w21, uxtw #2]
     e7c: b90005f4     	str	w20, [x15, #0x4]
     e80: b900180c     	str	w12, [x0, #0x18]
     e84: b9401000     	ldr	w0, [x0, #0x10]
     e88: aa1a03ed     	mov	x13, x26
     e8c: b94015a1     	ldr	w1, [x13, #0x14]
     e90: 6b01001f     	cmp	w0, w1
     e94: 54001d82     	b.hs	0x1244 <___pl_fn_3+0x5e4>
     e98: aa1a03e0     	mov	x0, x26
     e9c: aa1403e1     	mov	x1, x20
     ea0: 94000000     	bl	0xea0 <___pl_fn_3+0x240>
     ea4: aa1a03e1     	mov	x1, x26
     ea8: b9402c21     	ldr	w1, [x1, #0x2c]
     eac: 350022c1     	cbnz	w1, 0x1304 <___pl_fn_3+0x6a4>
     eb0: aa1a03e1     	mov	x1, x26
     eb4: b9001835     	str	w21, [x1, #0x18]
     eb8: d28740e1     	mov	x1, #0x3a07             ; =14855
     ebc: f2b40da1     	movk	x1, #0xa06d, lsl #16
     ec0: f2c0da61     	movk	x1, #0x6d3, lsl #32
     ec4: f2eda741     	movk	x1, #0x6d3a, lsl #48
     ec8: 9b417c01     	smulh	x1, x0, x1
     ecc: 9347fc21     	asr	x1, x1, #7
     ed0: d37ffc22     	lsr	x2, x1, #63
     ed4: 8b020021     	add	x1, x1, x2
     ed8: d2802582     	mov	x2, #0x12c              ; =300
     edc: 9b028020     	msub	x0, x1, x2, x0
     ee0: d28012c1     	mov	x1, #0x96               ; =150
     ee4: eb010000     	subs	x0, x0, x1
     ee8: 9a9f77e1     	cset	x1, vs
     eec: 72001c3f     	tst	w1, #0xff
     ef0: 54001921     	b.ne	0x1214 <___pl_fn_3+0x5b4>
     ef4: 35000093     	cbnz	w19, 0xf04 <___pl_fn_3+0x2a4>
     ef8: 1400008b     	b	0x1124 <___pl_fn_3+0x4c4>
     efc: aa1a03e0     	mov	x0, x26
     f00: 14000011     	b	0xf44 <___pl_fn_3+0x2e4>
     f04: aa1a03e1     	mov	x1, x26
     f08: f9400022     	ldr	x2, [x1]
     f0c: 2a1303e1     	mov	w1, w19
     f10: 8b010c41     	add	x1, x2, x1, lsl #3
     f14: f8735842     	ldr	x2, [x2, w19, uxtw #3]
     f18: d360fc42     	lsr	x2, x2, #32
     f1c: 92403c43     	and	x3, x2, #0xffff
     f20: f100087f     	cmp	x3, #0x2
     f24: 54000080     	b.eq	0xf34 <___pl_fn_3+0x2d4>
     f28: f9400823     	ldr	x3, [x1, #0x10]
     f2c: 927df863     	and	x3, x3, #0xfffffffffffffffb
     f30: f9000823     	str	x3, [x1, #0x10]
     f34: 92403c42     	and	x2, x2, #0xffff
     f38: 91000842     	add	x2, x2, #0x2
     f3c: f8227820     	str	x0, [x1, x2, lsl #3]
     f40: aa1a03e0     	mov	x0, x26
     f44: aa1a03e0     	mov	x0, x26
     f48: b9401815     	ldr	w21, [x0, #0x18]
     f4c: b9401c01     	ldr	w1, [x0, #0x1c]
     f50: 11000aa0     	add	w0, w21, #0x2
     f54: 6b01001f     	cmp	w0, w1
     f58: 54001468     	b.hi	0x11e4 <___pl_fn_3+0x584>
     f5c: aa1a03ed     	mov	x13, x26
     f60: f94011a1     	ldr	x1, [x13, #0x20]
     f64: 2a1503e2     	mov	w2, w21
     f68: 8b020822     	add	x2, x1, x2, lsl #2
     f6c: b8355833     	str	w19, [x1, w21, uxtw #2]
     f70: b9000454     	str	w20, [x2, #0x4]
     f74: aa1a03e1     	mov	x1, x26
     f78: b9001820     	str	w0, [x1, #0x18]
     f7c: aa1a03e0     	mov	x0, x26
     f80: b9401000     	ldr	w0, [x0, #0x10]
     f84: b9401421     	ldr	w1, [x1, #0x14]
     f88: 6b01001f     	cmp	w0, w1
     f8c: 54001142     	b.hs	0x11b4 <___pl_fn_3+0x554>
     f90: aa1403e1     	mov	x1, x20
     f94: aa1a03e0     	mov	x0, x26
     f98: 94000000     	bl	0xf98 <___pl_fn_3+0x338>
     f9c: aa1a03e1     	mov	x1, x26
     fa0: b9402c21     	ldr	w1, [x1, #0x2c]
     fa4: 35001b01     	cbnz	w1, 0x1304 <___pl_fn_3+0x6a4>
     fa8: aa1a03e1     	mov	x1, x26
     fac: b9001835     	str	w21, [x1, #0x18]
     fb0: d28740e1     	mov	x1, #0x3a07             ; =14855
     fb4: f2b40da1     	movk	x1, #0xa06d, lsl #16
     fb8: f2c0da61     	movk	x1, #0x6d3, lsl #32
     fbc: f2eda741     	movk	x1, #0x6d3a, lsl #48
     fc0: 9b417c01     	smulh	x1, x0, x1
     fc4: 9347fc21     	asr	x1, x1, #7
     fc8: d37ffc22     	lsr	x2, x1, #63
     fcc: 8b020021     	add	x1, x1, x2
     fd0: d2802582     	mov	x2, #0x12c              ; =300
     fd4: 9b028020     	msub	x0, x1, x2, x0
     fd8: d28012c1     	mov	x1, #0x96               ; =150
     fdc: eb010000     	subs	x0, x0, x1
     fe0: 9a9f77e1     	cset	x1, vs
     fe4: 72001c3f     	tst	w1, #0xff
     fe8: 54000ce1     	b.ne	0x1184 <___pl_fn_3+0x524>
     fec: 350000b3     	cbnz	w19, 0x1000 <___pl_fn_3+0x3a0>
     ff0: 14000059     	b	0x1154 <___pl_fn_3+0x4f4>
     ff4: aa1a03e0     	mov	x0, x26
     ff8: aa1303fc     	mov	x28, x19
     ffc: 14000012     	b	0x1044 <___pl_fn_3+0x3e4>
    1000: aa1a03e1     	mov	x1, x26
    1004: f9400022     	ldr	x2, [x1]
    1008: 2a1303e1     	mov	w1, w19
    100c: 8b010c41     	add	x1, x2, x1, lsl #3
    1010: f8735842     	ldr	x2, [x2, w19, uxtw #3]
    1014: aa1303fc     	mov	x28, x19
    1018: d360fc42     	lsr	x2, x2, #32
    101c: 92403c43     	and	x3, x2, #0xffff
    1020: f100087f     	cmp	x3, #0x2
    1024: 54000080     	b.eq	0x1034 <___pl_fn_3+0x3d4>
    1028: f9400823     	ldr	x3, [x1, #0x10]
    102c: 927cf863     	and	x3, x3, #0xfffffffffffffff7
    1030: f9000823     	str	x3, [x1, #0x10]
    1034: 92403c42     	and	x2, x2, #0xffff
    1038: 91000c42     	add	x2, x2, #0x3
    103c: f8227820     	str	x0, [x1, x2, lsl #3]
    1040: aa1a03e0     	mov	x0, x26
    1044: aa1a03e0     	mov	x0, x26
    1048: b9401001     	ldr	w1, [x0, #0x10]
    104c: 51000421     	sub	w1, w1, #0x1
    1050: b9001001     	str	w1, [x0, #0x10]
    1054: aa1c03e0     	mov	x0, x28
    1058: 910103ff     	add	sp, sp, #0x40
    105c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1060: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1064: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1068: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    106c: d65f03c0     	ret
    1070: 140000a5     	b	0x1304 <___pl_fn_3+0x6a4>
    1074: d2800001     	mov	x1, #0x0                ; =0
    1078: 910003e3     	mov	x3, sp
    107c: f80003e1     	stur	x1, [sp]
    1080: d29ef9e1     	mov	x1, #0xf7cf             ; =63439
    1084: f2bc6a61     	movk	x1, #0xe353, lsl #16
    1088: f2d374a1     	movk	x1, #0x9ba5, lsl #32
    108c: f2e41881     	movk	x1, #0x20c4, lsl #48
    1090: 9b417c01     	smulh	x1, x0, x1
    1094: 9346fc21     	asr	x1, x1, #6
    1098: d37ffc22     	lsr	x2, x1, #63
    109c: 8b020021     	add	x1, x1, x2
    10a0: d2803e82     	mov	x2, #0x1f4              ; =500
    10a4: 9b028020     	msub	x0, x1, x2, x0
    10a8: f80083e0     	stur	x0, [sp, #0x8]
    10ac: 52800421     	mov	w1, #0x21               ; =33
    10b0: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    10b4: f9400084     	ldr	x4, [x4]
    10b8: aa1a03e0     	mov	x0, x26
    10bc: aa1303e2     	mov	x2, x19
    10c0: d63f0080     	blr	x4
    10c4: 34ffe1e0     	cbz	w0, 0xd00 <___pl_fn_3+0xa0>
    10c8: 1400008f     	b	0x1304 <___pl_fn_3+0x6a4>
    10cc: d2800021     	mov	x1, #0x1                ; =1
    10d0: 910043e3     	add	x3, sp, #0x10
    10d4: f80103e1     	stur	x1, [sp, #0x10]
    10d8: d29ef9e1     	mov	x1, #0xf7cf             ; =63439
    10dc: f2bc6a61     	movk	x1, #0xe353, lsl #16
    10e0: f2d374a1     	movk	x1, #0x9ba5, lsl #32
    10e4: f2e41881     	movk	x1, #0x20c4, lsl #48
    10e8: 9b417c01     	smulh	x1, x0, x1
    10ec: 9346fc21     	asr	x1, x1, #6
    10f0: d37ffc22     	lsr	x2, x1, #63
    10f4: 8b020021     	add	x1, x1, x2
    10f8: d2803e82     	mov	x2, #0x1f4              ; =500
    10fc: 9b028021     	msub	x1, x1, x2, x0
    1100: f80183e1     	stur	x1, [sp, #0x18]
    1104: 528004a1     	mov	w1, #0x25               ; =37
    1108: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    110c: f9400084     	ldr	x4, [x4]
    1110: aa1a03e0     	mov	x0, x26
    1114: aa1303e2     	mov	x2, x19
    1118: d63f0080     	blr	x4
    111c: 34ffe620     	cbz	w0, 0xde0 <___pl_fn_3+0x180>
    1120: 14000079     	b	0x1304 <___pl_fn_3+0x6a4>
    1124: d2800041     	mov	x1, #0x2                ; =2
    1128: 910083e3     	add	x3, sp, #0x20
    112c: f80203e1     	stur	x1, [sp, #0x20]
    1130: f80283e0     	stur	x0, [sp, #0x28]
    1134: 52800541     	mov	w1, #0x2a               ; =42
    1138: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    113c: f9400084     	ldr	x4, [x4]
    1140: aa1a03e0     	mov	x0, x26
    1144: aa1303e2     	mov	x2, x19
    1148: d63f0080     	blr	x4
    114c: 34ffed80     	cbz	w0, 0xefc <___pl_fn_3+0x29c>
    1150: 1400006d     	b	0x1304 <___pl_fn_3+0x6a4>
    1154: d2800061     	mov	x1, #0x3                ; =3
    1158: 9100c3e3     	add	x3, sp, #0x30
    115c: f80303e1     	stur	x1, [sp, #0x30]
    1160: f80383e0     	stur	x0, [sp, #0x38]
    1164: 528005e1     	mov	w1, #0x2f               ; =47
    1168: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    116c: f9400084     	ldr	x4, [x4]
    1170: aa1a03e0     	mov	x0, x26
    1174: aa1303e2     	mov	x2, x19
    1178: d63f0080     	blr	x4
    117c: 34fff3c0     	cbz	w0, 0xff4 <___pl_fn_3+0x394>
    1180: 14000061     	b	0x1304 <___pl_fn_3+0x6a4>
    1184: 528005c1     	mov	w1, #0x2e               ; =46
    1188: 90000003     	adrp	x3, 0x1000 <___pl_fn_3+0x3a0>
    118c: f9400063     	ldr	x3, [x3]
    1190: aa1a03e0     	mov	x0, x26
    1194: d63f0060     	blr	x3
    1198: 52800000     	mov	w0, #0x0                ; =0
    119c: 910103ff     	add	sp, sp, #0x40
    11a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11a4: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    11a8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    11ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11b0: d65f03c0     	ret
    11b4: 52800581     	mov	w1, #0x2c               ; =44
    11b8: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    11bc: f9400084     	ldr	x4, [x4]
    11c0: aa1a03e0     	mov	x0, x26
    11c4: d63f0080     	blr	x4
    11c8: 52800000     	mov	w0, #0x0                ; =0
    11cc: 910103ff     	add	sp, sp, #0x40
    11d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11d4: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    11d8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    11dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11e0: d65f03c0     	ret
    11e4: 52800561     	mov	w1, #0x2b               ; =43
    11e8: 90000005     	adrp	x5, 0x1000 <___pl_fn_3+0x3a0>
    11ec: f94000a5     	ldr	x5, [x5]
    11f0: aa1a03e0     	mov	x0, x26
    11f4: d63f00a0     	blr	x5
    11f8: 52800000     	mov	w0, #0x0                ; =0
    11fc: 910103ff     	add	sp, sp, #0x40
    1200: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1204: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1208: a8c173fb     	ldp	x27, x28, [sp], #0x10
    120c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1210: d65f03c0     	ret
    1214: 52800521     	mov	w1, #0x29               ; =41
    1218: 90000006     	adrp	x6, 0x1000 <___pl_fn_3+0x3a0>
    121c: f94000c6     	ldr	x6, [x6]
    1220: aa1a03e0     	mov	x0, x26
    1224: d63f00c0     	blr	x6
    1228: 52800000     	mov	w0, #0x0                ; =0
    122c: 910103ff     	add	sp, sp, #0x40
    1230: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1234: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1238: a8c173fb     	ldp	x27, x28, [sp], #0x10
    123c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1240: d65f03c0     	ret
    1244: 528004e1     	mov	w1, #0x27               ; =39
    1248: 90000007     	adrp	x7, 0x1000 <___pl_fn_3+0x3a0>
    124c: f94000e7     	ldr	x7, [x7]
    1250: aa1a03e0     	mov	x0, x26
    1254: d63f00e0     	blr	x7
    1258: 52800000     	mov	w0, #0x0                ; =0
    125c: 910103ff     	add	sp, sp, #0x40
    1260: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1264: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1268: a8c173fb     	ldp	x27, x28, [sp], #0x10
    126c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1270: d65f03c0     	ret
    1274: 528004c1     	mov	w1, #0x26               ; =38
    1278: 90000008     	adrp	x8, 0x1000 <___pl_fn_3+0x3a0>
    127c: f9400108     	ldr	x8, [x8]
    1280: aa1a03e0     	mov	x0, x26
    1284: d63f0100     	blr	x8
    1288: 52800000     	mov	w0, #0x0                ; =0
    128c: 910103ff     	add	sp, sp, #0x40
    1290: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1294: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1298: a8c173fb     	ldp	x27, x28, [sp], #0x10
    129c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12a0: d65f03c0     	ret
    12a4: 52800461     	mov	w1, #0x23               ; =35
    12a8: 90000009     	adrp	x9, 0x1000 <___pl_fn_3+0x3a0>
    12ac: f9400129     	ldr	x9, [x9]
    12b0: aa1a03e0     	mov	x0, x26
    12b4: d63f0120     	blr	x9
    12b8: 52800000     	mov	w0, #0x0                ; =0
    12bc: 910103ff     	add	sp, sp, #0x40
    12c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    12c4: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    12c8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    12cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12d0: d65f03c0     	ret
    12d4: 52800441     	mov	w1, #0x22               ; =34
    12d8: 9000000a     	adrp	x10, 0x1000 <___pl_fn_3+0x3a0>
    12dc: f940014a     	ldr	x10, [x10]
    12e0: aa1a03e0     	mov	x0, x26
    12e4: d63f0140     	blr	x10
    12e8: 52800000     	mov	w0, #0x0                ; =0
    12ec: 910103ff     	add	sp, sp, #0x40
    12f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    12f4: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    12f8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    12fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1300: d65f03c0     	ret
    1304: 52800000     	mov	w0, #0x0                ; =0
    1308: 910103ff     	add	sp, sp, #0x40
    130c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1310: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1314: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1318: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    131c: d65f03c0     	ret
    1320: 528003e1     	mov	w1, #0x1f               ; =31
    1324: 9000000c     	adrp	x12, 0x1000 <___pl_fn_3+0x3a0>
    1328: f940018c     	ldr	x12, [x12]
    132c: aa1a03e0     	mov	x0, x26
    1330: d63f0180     	blr	x12
    1334: 52800000     	mov	w0, #0x0                ; =0
    1338: 910103ff     	add	sp, sp, #0x40
    133c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1340: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1344: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1348: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    134c: d65f03c0     	ret
    1350: aa0003fa     	mov	x26, x0
    1354: 528003c1     	mov	w1, #0x1e               ; =30
    1358: 9000000d     	adrp	x13, 0x1000 <___pl_fn_3+0x3a0>
    135c: f94001ad     	ldr	x13, [x13]
    1360: d63f01a0     	blr	x13
    1364: 52800000     	mov	w0, #0x0                ; =0
    1368: 910103ff     	add	sp, sp, #0x40
    136c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1370: a8c16bf5     	ldp	x21, x26, [sp], #0x10
    1374: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1378: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    137c: d65f03c0     	ret

0000000000001380 <___pl_fn_4>:
    1380: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    1384: 910003fd     	mov	x29, sp
    1388: f81f0ff9     	str	x25, [sp, #-0x10]!
    138c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    1390: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    1394: d10283ff     	sub	sp, sp, #0xa0
    1398: aa0103f3     	mov	x19, x1
    139c: b9401001     	ldr	w1, [x0, #0x10]
    13a0: 11000421     	add	w1, w1, #0x1
    13a4: b9001001     	str	w1, [x0, #0x10]
    13a8: aa1303e1     	mov	x1, x19
    13ac: 340040c1     	cbz	w1, 0x1bc4 <___pl_fn_4+0x844>
    13b0: f9400001     	ldr	x1, [x0]
    13b4: aa0003f6     	mov	x22, x0
    13b8: aa1303e0     	mov	x0, x19
    13bc: 2a0003e0     	mov	w0, w0
    13c0: 8b000c20     	add	x0, x1, x0, lsl #3
    13c4: aa1303e2     	mov	x2, x19
    13c8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    13cc: d360fc21     	lsr	x1, x1, #32
    13d0: 92403c21     	and	x1, x1, #0xffff
    13d4: f8617814     	ldr	x20, [x0, x1, lsl #3]
    13d8: f100083f     	cmp	x1, #0x2
    13dc: 540000c0     	b.eq	0x13f4 <___pl_fn_4+0x74>
    13e0: f9400800     	ldr	x0, [x0, #0x10]
    13e4: 37003f20     	tbnz	w0, #0x0, 0x1bc8 <___pl_fn_4+0x848>
    13e8: 14000003     	b	0x13f4 <___pl_fn_4+0x74>
    13ec: aa1603e0     	mov	x0, x22
    13f0: f9401814     	ldr	x20, [x0, #0x30]
    13f4: 34003fd3     	cbz	w19, 0x1bec <___pl_fn_4+0x86c>
    13f8: aa1603e0     	mov	x0, x22
    13fc: f940000a     	ldr	x10, [x0]
    1400: 2a1303e9     	mov	w9, w19
    1404: 8b090d49     	add	x9, x10, x9, lsl #3
    1408: f873594a     	ldr	x10, [x10, w19, uxtw #3]
    140c: d360fd4a     	lsr	x10, x10, #32
    1410: 92403d4a     	and	x10, x10, #0xffff
    1414: 9100094b     	add	x11, x10, #0x2
    1418: f86b7920     	ldr	x0, [x9, x11, lsl #3]
    141c: f100095f     	cmp	x10, #0x2
    1420: 540000c0     	b.eq	0x1438 <___pl_fn_4+0xb8>
    1424: f940092c     	ldr	x12, [x9, #0x10]
    1428: 37103e2c     	tbnz	w12, #0x2, 0x1bec <___pl_fn_4+0x86c>
    142c: 14000003     	b	0x1438 <___pl_fn_4+0xb8>
    1430: aa1603e0     	mov	x0, x22
    1434: f9401800     	ldr	x0, [x0, #0x30]
    1438: ab000280     	adds	x0, x20, x0
    143c: 9a9f77e1     	cset	x1, vs
    1440: 72001c3f     	tst	w1, #0xff
    1444: 540069e1     	b.ne	0x2180 <___pl_fn_4+0xe00>
    1448: 34003e53     	cbz	w19, 0x1c10 <___pl_fn_4+0x890>
    144c: aa1603e7     	mov	x7, x22
    1450: f94000e2     	ldr	x2, [x7]
    1454: 2a1303e1     	mov	w1, w19
    1458: 8b010c41     	add	x1, x2, x1, lsl #3
    145c: f8735842     	ldr	x2, [x2, w19, uxtw #3]
    1460: d360fc42     	lsr	x2, x2, #32
    1464: 92403c43     	and	x3, x2, #0xffff
    1468: f100087f     	cmp	x3, #0x2
    146c: 54000080     	b.eq	0x147c <___pl_fn_4+0xfc>
    1470: f9400823     	ldr	x3, [x1, #0x10]
    1474: 927ff863     	and	x3, x3, #0xfffffffffffffffe
    1478: f9000823     	str	x3, [x1, #0x10]
    147c: 92403c42     	and	x2, x2, #0xffff
    1480: f8227820     	str	x0, [x1, x2, lsl #3]
    1484: 34003df3     	cbz	w19, 0x1c40 <___pl_fn_4+0x8c0>
    1488: aa1603e0     	mov	x0, x22
    148c: f9400001     	ldr	x1, [x0]
    1490: 2a1303e0     	mov	w0, w19
    1494: 8b000c20     	add	x0, x1, x0, lsl #3
    1498: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    149c: d360fc21     	lsr	x1, x1, #32
    14a0: 92403c21     	and	x1, x1, #0xffff
    14a4: 91000422     	add	x2, x1, #0x1
    14a8: f8627814     	ldr	x20, [x0, x2, lsl #3]
    14ac: f100083f     	cmp	x1, #0x2
    14b0: 540000c0     	b.eq	0x14c8 <___pl_fn_4+0x148>
    14b4: f9400800     	ldr	x0, [x0, #0x10]
    14b8: 37083c40     	tbnz	w0, #0x1, 0x1c40 <___pl_fn_4+0x8c0>
    14bc: 14000003     	b	0x14c8 <___pl_fn_4+0x148>
    14c0: aa1603e0     	mov	x0, x22
    14c4: f9401814     	ldr	x20, [x0, #0x30]
    14c8: 34003cf3     	cbz	w19, 0x1c64 <___pl_fn_4+0x8e4>
    14cc: aa1603e0     	mov	x0, x22
    14d0: f9400001     	ldr	x1, [x0]
    14d4: 2a1303e0     	mov	w0, w19
    14d8: 8b000c20     	add	x0, x1, x0, lsl #3
    14dc: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    14e0: d360fc21     	lsr	x1, x1, #32
    14e4: 92403c21     	and	x1, x1, #0xffff
    14e8: 91000c22     	add	x2, x1, #0x3
    14ec: f8627802     	ldr	x2, [x0, x2, lsl #3]
    14f0: f100083f     	cmp	x1, #0x2
    14f4: 540000c0     	b.eq	0x150c <___pl_fn_4+0x18c>
    14f8: f9400800     	ldr	x0, [x0, #0x10]
    14fc: 37183b40     	tbnz	w0, #0x3, 0x1c64 <___pl_fn_4+0x8e4>
    1500: 14000003     	b	0x150c <___pl_fn_4+0x18c>
    1504: aa1603e0     	mov	x0, x22
    1508: f9401802     	ldr	x2, [x0, #0x30]
    150c: ab020280     	adds	x0, x20, x2
    1510: 9a9f77e1     	cset	x1, vs
    1514: 72001c3f     	tst	w1, #0xff
    1518: 540061c1     	b.ne	0x2150 <___pl_fn_4+0xdd0>
    151c: 34003b73     	cbz	w19, 0x1c88 <___pl_fn_4+0x908>
    1520: aa1603e1     	mov	x1, x22
    1524: f9400024     	ldr	x4, [x1]
    1528: 2a1303e3     	mov	w3, w19
    152c: 8b030c83     	add	x3, x4, x3, lsl #3
    1530: f8735884     	ldr	x4, [x4, w19, uxtw #3]
    1534: d360fc84     	lsr	x4, x4, #32
    1538: 92403c85     	and	x5, x4, #0xffff
    153c: f10008bf     	cmp	x5, #0x2
    1540: 54000080     	b.eq	0x1550 <___pl_fn_4+0x1d0>
    1544: f9400866     	ldr	x6, [x3, #0x10]
    1548: 927ef8c6     	and	x6, x6, #0xfffffffffffffffd
    154c: f9000866     	str	x6, [x3, #0x10]
    1550: 92403c88     	and	x8, x4, #0xffff
    1554: 91000508     	add	x8, x8, #0x1
    1558: f8287860     	str	x0, [x3, x8, lsl #3]
    155c: 34003af3     	cbz	w19, 0x1cb8 <___pl_fn_4+0x938>
    1560: aa1603e0     	mov	x0, x22
    1564: f940000d     	ldr	x13, [x0]
    1568: 2a1303ec     	mov	w12, w19
    156c: 8b0c0dac     	add	x12, x13, x12, lsl #3
    1570: f87359ad     	ldr	x13, [x13, w19, uxtw #3]
    1574: d360fdad     	lsr	x13, x13, #32
    1578: 92403dad     	and	x13, x13, #0xffff
    157c: f86d7980     	ldr	x0, [x12, x13, lsl #3]
    1580: f10009bf     	cmp	x13, #0x2
    1584: 540000c0     	b.eq	0x159c <___pl_fn_4+0x21c>
    1588: f940098f     	ldr	x15, [x12, #0x10]
    158c: 3700396f     	tbnz	w15, #0x0, 0x1cb8 <___pl_fn_4+0x938>
    1590: 14000003     	b	0x159c <___pl_fn_4+0x21c>
    1594: aa1603e0     	mov	x0, x22
    1598: f9401800     	ldr	x0, [x0, #0x30]
    159c: f107d01f     	cmp	x0, #0x1f4
    15a0: 5400008c     	b.gt	0x15b0 <___pl_fn_4+0x230>
    15a4: 52800000     	mov	w0, #0x0                ; =0
    15a8: aa0003f4     	mov	x20, x0
    15ac: 14000053     	b	0x16f8 <___pl_fn_4+0x378>
    15b0: 34003973     	cbz	w19, 0x1cdc <___pl_fn_4+0x95c>
    15b4: aa1603e0     	mov	x0, x22
    15b8: f9400001     	ldr	x1, [x0]
    15bc: 2a1303e0     	mov	w0, w19
    15c0: 8b000c20     	add	x0, x1, x0, lsl #3
    15c4: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    15c8: d360fc21     	lsr	x1, x1, #32
    15cc: 92403c22     	and	x2, x1, #0xffff
    15d0: f100085f     	cmp	x2, #0x2
    15d4: 54000080     	b.eq	0x15e4 <___pl_fn_4+0x264>
    15d8: f9400802     	ldr	x2, [x0, #0x10]
    15dc: 927ff842     	and	x2, x2, #0xfffffffffffffffe
    15e0: f9000802     	str	x2, [x0, #0x10]
    15e4: d2803e82     	mov	x2, #0x1f4              ; =500
    15e8: 92403c21     	and	x1, x1, #0xffff
    15ec: f8217802     	str	x2, [x0, x1, lsl #3]
    15f0: 34003913     	cbz	w19, 0x1d10 <___pl_fn_4+0x990>
    15f4: aa1603e0     	mov	x0, x22
    15f8: f9400001     	ldr	x1, [x0]
    15fc: 2a1303e0     	mov	w0, w19
    1600: 8b000c20     	add	x0, x1, x0, lsl #3
    1604: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    1608: d360fc21     	lsr	x1, x1, #32
    160c: 92403c22     	and	x2, x1, #0xffff
    1610: 91000841     	add	x1, x2, #0x2
    1614: f8617801     	ldr	x1, [x0, x1, lsl #3]
    1618: f100085f     	cmp	x2, #0x2
    161c: 540000e0     	b.eq	0x1638 <___pl_fn_4+0x2b8>
    1620: f9400800     	ldr	x0, [x0, #0x10]
    1624: 37103760     	tbnz	w0, #0x2, 0x1d10 <___pl_fn_4+0x990>
    1628: 14000004     	b	0x1638 <___pl_fn_4+0x2b8>
    162c: aa1603e0     	mov	x0, x22
    1630: f9401801     	ldr	x1, [x0, #0x30]
    1634: 14000002     	b	0x163c <___pl_fn_4+0x2bc>
    1638: aa1603e0     	mov	x0, x22
    163c: aa1603e0     	mov	x0, x22
    1640: b9401815     	ldr	w21, [x0, #0x18]
    1644: b9401c02     	ldr	w2, [x0, #0x1c]
    1648: 110006a0     	add	w0, w21, #0x1
    164c: 6b02001f     	cmp	w0, w2
    1650: 54005688     	b.hi	0x2120 <___pl_fn_4+0xda0>
    1654: aa1603e2     	mov	x2, x22
    1658: f9401042     	ldr	x2, [x2, #0x20]
    165c: d2800054     	mov	x20, #0x2               ; =2
    1660: b8355853     	str	w19, [x2, w21, uxtw #2]
    1664: aa1603e2     	mov	x2, x22
    1668: b9001840     	str	w0, [x2, #0x18]
    166c: aa1603e0     	mov	x0, x22
    1670: b9401000     	ldr	w0, [x0, #0x10]
    1674: b9401442     	ldr	w2, [x2, #0x14]
    1678: 6b02001f     	cmp	w0, w2
    167c: 540053a2     	b.hs	0x20f0 <___pl_fn_4+0xd70>
    1680: aa1603e0     	mov	x0, x22
    1684: 94000000     	bl	0x1684 <___pl_fn_4+0x304>
    1688: aa1603e1     	mov	x1, x22
    168c: b9402c21     	ldr	w1, [x1, #0x2c]
    1690: 35005221     	cbnz	w1, 0x20d4 <___pl_fn_4+0xd54>
    1694: aa1603e1     	mov	x1, x22
    1698: b9001835     	str	w21, [x1, #0x18]
    169c: d2800001     	mov	x1, #0x0                ; =0
    16a0: eb000020     	subs	x0, x1, x0
    16a4: 9a9f77e1     	cset	x1, vs
    16a8: 72001c3f     	tst	w1, #0xff
    16ac: 54004fc1     	b.ne	0x20a4 <___pl_fn_4+0xd24>
    16b0: 34003433     	cbz	w19, 0x1d34 <___pl_fn_4+0x9b4>
    16b4: aa1603e1     	mov	x1, x22
    16b8: f9400025     	ldr	x5, [x1]
    16bc: 2a1303e4     	mov	w4, w19
    16c0: 8b040ca4     	add	x4, x5, x4, lsl #3
    16c4: f87358a5     	ldr	x5, [x5, w19, uxtw #3]
    16c8: d360fca5     	lsr	x5, x5, #32
    16cc: 92403ca6     	and	x6, x5, #0xffff
    16d0: f10008df     	cmp	x6, #0x2
    16d4: 54000080     	b.eq	0x16e4 <___pl_fn_4+0x364>
    16d8: f9400887     	ldr	x7, [x4, #0x10]
    16dc: 927df8e7     	and	x7, x7, #0xfffffffffffffffb
    16e0: f9000887     	str	x7, [x4, #0x10]
    16e4: 92403ca9     	and	x9, x5, #0xffff
    16e8: 91000929     	add	x9, x9, #0x2
    16ec: f8297880     	str	x0, [x4, x9, lsl #3]
    16f0: 52800020     	mov	w0, #0x1                ; =1
    16f4: aa0003f4     	mov	x20, x0
    16f8: 34003353     	cbz	w19, 0x1d60 <___pl_fn_4+0x9e0>
    16fc: aa1603e0     	mov	x0, x22
    1700: f9400000     	ldr	x0, [x0]
    1704: 2a1303ef     	mov	w15, w19
    1708: 8b0f0c0f     	add	x15, x0, x15, lsl #3
    170c: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    1710: d360fc00     	lsr	x0, x0, #32
    1714: 92403c00     	and	x0, x0, #0xffff
    1718: f86079eb     	ldr	x11, [x15, x0, lsl #3]
    171c: f100081f     	cmp	x0, #0x2
    1720: 540000c0     	b.eq	0x1738 <___pl_fn_4+0x3b8>
    1724: f94009e0     	ldr	x0, [x15, #0x10]
    1728: 370031c0     	tbnz	w0, #0x0, 0x1d60 <___pl_fn_4+0x9e0>
    172c: 14000003     	b	0x1738 <___pl_fn_4+0x3b8>
    1730: aa1603e0     	mov	x0, x22
    1734: f940180b     	ldr	x11, [x0, #0x30]
    1738: d2800019     	mov	x25, #0x0               ; =0
    173c: f100017f     	cmp	x11, #0x0
    1740: 540009aa     	b.ge	0x1874 <___pl_fn_4+0x4f4>
    1744: 34003213     	cbz	w19, 0x1d84 <___pl_fn_4+0xa04>
    1748: aa1603e0     	mov	x0, x22
    174c: f9400001     	ldr	x1, [x0]
    1750: 2a1303e0     	mov	w0, w19
    1754: 8b000c20     	add	x0, x1, x0, lsl #3
    1758: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    175c: d360fc21     	lsr	x1, x1, #32
    1760: 92403c22     	and	x2, x1, #0xffff
    1764: f100085f     	cmp	x2, #0x2
    1768: 54000080     	b.eq	0x1778 <___pl_fn_4+0x3f8>
    176c: f9400802     	ldr	x2, [x0, #0x10]
    1770: 927ff842     	and	x2, x2, #0xfffffffffffffffe
    1774: f9000802     	str	x2, [x0, #0x10]
    1778: 92403c21     	and	x1, x1, #0xffff
    177c: f8217819     	str	x25, [x0, x1, lsl #3]
    1780: 34003193     	cbz	w19, 0x1db0 <___pl_fn_4+0xa30>
    1784: aa1603e0     	mov	x0, x22
    1788: f9400001     	ldr	x1, [x0]
    178c: 2a1303e0     	mov	w0, w19
    1790: 8b000c20     	add	x0, x1, x0, lsl #3
    1794: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    1798: d360fc21     	lsr	x1, x1, #32
    179c: 92403c22     	and	x2, x1, #0xffff
    17a0: 91000841     	add	x1, x2, #0x2
    17a4: f8617801     	ldr	x1, [x0, x1, lsl #3]
    17a8: f100085f     	cmp	x2, #0x2
    17ac: 540000e0     	b.eq	0x17c8 <___pl_fn_4+0x448>
    17b0: f9400800     	ldr	x0, [x0, #0x10]
    17b4: 37102fe0     	tbnz	w0, #0x2, 0x1db0 <___pl_fn_4+0xa30>
    17b8: 14000004     	b	0x17c8 <___pl_fn_4+0x448>
    17bc: aa1603e0     	mov	x0, x22
    17c0: f9401801     	ldr	x1, [x0, #0x30]
    17c4: 14000002     	b	0x17cc <___pl_fn_4+0x44c>
    17c8: aa1603e0     	mov	x0, x22
    17cc: aa1603e0     	mov	x0, x22
    17d0: b9401814     	ldr	w20, [x0, #0x18]
    17d4: b9401c02     	ldr	w2, [x0, #0x1c]
    17d8: 11000680     	add	w0, w20, #0x1
    17dc: 6b02001f     	cmp	w0, w2
    17e0: 540044a8     	b.hi	0x2074 <___pl_fn_4+0xcf4>
    17e4: aa1603e2     	mov	x2, x22
    17e8: f9401042     	ldr	x2, [x2, #0x20]
    17ec: d2800055     	mov	x21, #0x2               ; =2
    17f0: b8345853     	str	w19, [x2, w20, uxtw #2]
    17f4: aa1603e2     	mov	x2, x22
    17f8: b9001840     	str	w0, [x2, #0x18]
    17fc: aa1603e0     	mov	x0, x22
    1800: b9401000     	ldr	w0, [x0, #0x10]
    1804: b9401442     	ldr	w2, [x2, #0x14]
    1808: 6b02001f     	cmp	w0, w2
    180c: 540041c2     	b.hs	0x2044 <___pl_fn_4+0xcc4>
    1810: aa1603e0     	mov	x0, x22
    1814: 94000000     	bl	0x1814 <___pl_fn_4+0x494>
    1818: aa1603e1     	mov	x1, x22
    181c: b9402c21     	ldr	w1, [x1, #0x2c]
    1820: 350045a1     	cbnz	w1, 0x20d4 <___pl_fn_4+0xd54>
    1824: aa1603e1     	mov	x1, x22
    1828: b9001834     	str	w20, [x1, #0x18]
    182c: 34002d53     	cbz	w19, 0x1dd4 <___pl_fn_4+0xa54>
    1830: aa1603e8     	mov	x8, x22
    1834: f9400106     	ldr	x6, [x8]
    1838: 2a1303e5     	mov	w5, w19
    183c: 8b050cc5     	add	x5, x6, x5, lsl #3
    1840: f87358c6     	ldr	x6, [x6, w19, uxtw #3]
    1844: d360fcc6     	lsr	x6, x6, #32
    1848: 92403cc7     	and	x7, x6, #0xffff
    184c: f10008ff     	cmp	x7, #0x2
    1850: 54000080     	b.eq	0x1860 <___pl_fn_4+0x4e0>
    1854: f94008a8     	ldr	x8, [x5, #0x10]
    1858: 927df908     	and	x8, x8, #0xfffffffffffffffb
    185c: f90008a8     	str	x8, [x5, #0x10]
    1860: 92403cca     	and	x10, x6, #0xffff
    1864: 9100094a     	add	x10, x10, #0x2
    1868: f82a78a0     	str	x0, [x5, x10, lsl #3]
    186c: 52800020     	mov	w0, #0x1                ; =1
    1870: aa0003f4     	mov	x20, x0
    1874: 34002c73     	cbz	w19, 0x1e00 <___pl_fn_4+0xa80>
    1878: aa1603e0     	mov	x0, x22
    187c: f9400000     	ldr	x0, [x0]
    1880: 2a1303e1     	mov	w1, w19
    1884: 8b010c01     	add	x1, x0, x1, lsl #3
    1888: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    188c: d360fc00     	lsr	x0, x0, #32
    1890: 92403c02     	and	x2, x0, #0xffff
    1894: 91000440     	add	x0, x2, #0x1
    1898: f8607820     	ldr	x0, [x1, x0, lsl #3]
    189c: f100085f     	cmp	x2, #0x2
    18a0: 540000c0     	b.eq	0x18b8 <___pl_fn_4+0x538>
    18a4: f9400821     	ldr	x1, [x1, #0x10]
    18a8: 37082ac1     	tbnz	w1, #0x1, 0x1e00 <___pl_fn_4+0xa80>
    18ac: 14000003     	b	0x18b8 <___pl_fn_4+0x538>
    18b0: aa1603e0     	mov	x0, x22
    18b4: f9401800     	ldr	x0, [x0, #0x30]
    18b8: f107d01f     	cmp	x0, #0x1f4
    18bc: 54000a6d     	b.le	0x1a08 <___pl_fn_4+0x688>
    18c0: 34002b33     	cbz	w19, 0x1e24 <___pl_fn_4+0xaa4>
    18c4: aa1603e0     	mov	x0, x22
    18c8: f9400001     	ldr	x1, [x0]
    18cc: 2a1303e0     	mov	w0, w19
    18d0: 8b000c20     	add	x0, x1, x0, lsl #3
    18d4: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    18d8: d360fc21     	lsr	x1, x1, #32
    18dc: 92403c22     	and	x2, x1, #0xffff
    18e0: f100085f     	cmp	x2, #0x2
    18e4: 54000080     	b.eq	0x18f4 <___pl_fn_4+0x574>
    18e8: f9400802     	ldr	x2, [x0, #0x10]
    18ec: 927ef842     	and	x2, x2, #0xfffffffffffffffd
    18f0: f9000802     	str	x2, [x0, #0x10]
    18f4: d2803e82     	mov	x2, #0x1f4              ; =500
    18f8: 92403c21     	and	x1, x1, #0xffff
    18fc: 91000421     	add	x1, x1, #0x1
    1900: f8217802     	str	x2, [x0, x1, lsl #3]
    1904: 34002ab3     	cbz	w19, 0x1e58 <___pl_fn_4+0xad8>
    1908: aa1603e0     	mov	x0, x22
    190c: f9400001     	ldr	x1, [x0]
    1910: 2a1303e0     	mov	w0, w19
    1914: 8b000c20     	add	x0, x1, x0, lsl #3
    1918: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    191c: d360fc21     	lsr	x1, x1, #32
    1920: 92403c22     	and	x2, x1, #0xffff
    1924: 91000c41     	add	x1, x2, #0x3
    1928: f8617801     	ldr	x1, [x0, x1, lsl #3]
    192c: f100085f     	cmp	x2, #0x2
    1930: 540000e0     	b.eq	0x194c <___pl_fn_4+0x5cc>
    1934: f9400800     	ldr	x0, [x0, #0x10]
    1938: 37182900     	tbnz	w0, #0x3, 0x1e58 <___pl_fn_4+0xad8>
    193c: 14000004     	b	0x194c <___pl_fn_4+0x5cc>
    1940: aa1603e0     	mov	x0, x22
    1944: f9401801     	ldr	x1, [x0, #0x30]
    1948: 14000002     	b	0x1950 <___pl_fn_4+0x5d0>
    194c: aa1603e0     	mov	x0, x22
    1950: aa1603e0     	mov	x0, x22
    1954: b9401814     	ldr	w20, [x0, #0x18]
    1958: b9401c02     	ldr	w2, [x0, #0x1c]
    195c: 11000680     	add	w0, w20, #0x1
    1960: 6b02001f     	cmp	w0, w2
    1964: 54003588     	b.hi	0x2014 <___pl_fn_4+0xc94>
    1968: aa1603e2     	mov	x2, x22
    196c: f9401042     	ldr	x2, [x2, #0x20]
    1970: b8345853     	str	w19, [x2, w20, uxtw #2]
    1974: aa1603e3     	mov	x3, x22
    1978: b9001860     	str	w0, [x3, #0x18]
    197c: aa1603e0     	mov	x0, x22
    1980: b9401000     	ldr	w0, [x0, #0x10]
    1984: aa1603e7     	mov	x7, x22
    1988: b94014e2     	ldr	w2, [x7, #0x14]
    198c: 6b02001f     	cmp	w0, w2
    1990: 540032a2     	b.hs	0x1fe4 <___pl_fn_4+0xc64>
    1994: aa1603e0     	mov	x0, x22
    1998: 94000000     	bl	0x1998 <___pl_fn_4+0x618>
    199c: aa1603ec     	mov	x12, x22
    19a0: b9402d81     	ldr	w1, [x12, #0x2c]
    19a4: 35003981     	cbnz	w1, 0x20d4 <___pl_fn_4+0xd54>
    19a8: aa1603e1     	mov	x1, x22
    19ac: b9001834     	str	w20, [x1, #0x18]
    19b0: eb000320     	subs	x0, x25, x0
    19b4: 9a9f77e1     	cset	x1, vs
    19b8: 72001c3f     	tst	w1, #0xff
    19bc: 54002fc1     	b.ne	0x1fb4 <___pl_fn_4+0xc34>
    19c0: 340025f3     	cbz	w19, 0x1e7c <___pl_fn_4+0xafc>
    19c4: aa1603e1     	mov	x1, x22
    19c8: f9400029     	ldr	x9, [x1]
    19cc: 2a1303e8     	mov	w8, w19
    19d0: 8b080d28     	add	x8, x9, x8, lsl #3
    19d4: f8735929     	ldr	x9, [x9, w19, uxtw #3]
    19d8: d360fd29     	lsr	x9, x9, #32
    19dc: 92403d2a     	and	x10, x9, #0xffff
    19e0: f100095f     	cmp	x10, #0x2
    19e4: 54000080     	b.eq	0x19f4 <___pl_fn_4+0x674>
    19e8: f940090b     	ldr	x11, [x8, #0x10]
    19ec: 927cf96b     	and	x11, x11, #0xfffffffffffffff7
    19f0: f900090b     	str	x11, [x8, #0x10]
    19f4: 92403d2d     	and	x13, x9, #0xffff
    19f8: 91000dad     	add	x13, x13, #0x3
    19fc: f82d7900     	str	x0, [x8, x13, lsl #3]
    1a00: 52800020     	mov	w0, #0x1                ; =1
    1a04: aa0003f4     	mov	x20, x0
    1a08: 34002533     	cbz	w19, 0x1eac <___pl_fn_4+0xb2c>
    1a0c: aa1603e0     	mov	x0, x22
    1a10: f9400000     	ldr	x0, [x0]
    1a14: 2a1303e1     	mov	w1, w19
    1a18: 8b010c01     	add	x1, x0, x1, lsl #3
    1a1c: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    1a20: d360fc00     	lsr	x0, x0, #32
    1a24: 92403c02     	and	x2, x0, #0xffff
    1a28: 91000440     	add	x0, x2, #0x1
    1a2c: f8607820     	ldr	x0, [x1, x0, lsl #3]
    1a30: f100085f     	cmp	x2, #0x2
    1a34: 540000c0     	b.eq	0x1a4c <___pl_fn_4+0x6cc>
    1a38: f9400821     	ldr	x1, [x1, #0x10]
    1a3c: 37082381     	tbnz	w1, #0x1, 0x1eac <___pl_fn_4+0xb2c>
    1a40: 14000003     	b	0x1a4c <___pl_fn_4+0x6cc>
    1a44: aa1603e0     	mov	x0, x22
    1a48: f9401800     	ldr	x0, [x0, #0x30]
    1a4c: f100001f     	cmp	x0, #0x0
    1a50: 5400006b     	b.lt	0x1a5c <___pl_fn_4+0x6dc>
    1a54: aa1603e0     	mov	x0, x22
    1a58: 1400004f     	b	0x1b94 <___pl_fn_4+0x814>
    1a5c: 340023b3     	cbz	w19, 0x1ed0 <___pl_fn_4+0xb50>
    1a60: aa1603e0     	mov	x0, x22
    1a64: f9400001     	ldr	x1, [x0]
    1a68: 2a1303e0     	mov	w0, w19
    1a6c: 8b000c20     	add	x0, x1, x0, lsl #3
    1a70: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    1a74: d360fc21     	lsr	x1, x1, #32
    1a78: 92403c22     	and	x2, x1, #0xffff
    1a7c: f100085f     	cmp	x2, #0x2
    1a80: 54000080     	b.eq	0x1a90 <___pl_fn_4+0x710>
    1a84: f9400802     	ldr	x2, [x0, #0x10]
    1a88: 927ef842     	and	x2, x2, #0xfffffffffffffffd
    1a8c: f9000802     	str	x2, [x0, #0x10]
    1a90: 92403c21     	and	x1, x1, #0xffff
    1a94: 91000421     	add	x1, x1, #0x1
    1a98: f8217819     	str	x25, [x0, x1, lsl #3]
    1a9c: 34002333     	cbz	w19, 0x1f00 <___pl_fn_4+0xb80>
    1aa0: aa1603e0     	mov	x0, x22
    1aa4: f9400001     	ldr	x1, [x0]
    1aa8: 2a1303e0     	mov	w0, w19
    1aac: 8b000c20     	add	x0, x1, x0, lsl #3
    1ab0: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    1ab4: d360fc21     	lsr	x1, x1, #32
    1ab8: 92403c22     	and	x2, x1, #0xffff
    1abc: 91000c41     	add	x1, x2, #0x3
    1ac0: f8617801     	ldr	x1, [x0, x1, lsl #3]
    1ac4: f100085f     	cmp	x2, #0x2
    1ac8: 540000e0     	b.eq	0x1ae4 <___pl_fn_4+0x764>
    1acc: f9400800     	ldr	x0, [x0, #0x10]
    1ad0: 37182180     	tbnz	w0, #0x3, 0x1f00 <___pl_fn_4+0xb80>
    1ad4: 14000004     	b	0x1ae4 <___pl_fn_4+0x764>
    1ad8: aa1603e0     	mov	x0, x22
    1adc: f9401801     	ldr	x1, [x0, #0x30]
    1ae0: 14000002     	b	0x1ae8 <___pl_fn_4+0x768>
    1ae4: aa1603e0     	mov	x0, x22
    1ae8: aa1603e0     	mov	x0, x22
    1aec: b9401814     	ldr	w20, [x0, #0x18]
    1af0: b9401c02     	ldr	w2, [x0, #0x1c]
    1af4: 11000680     	add	w0, w20, #0x1
    1af8: 6b02001f     	cmp	w0, w2
    1afc: 54002448     	b.hi	0x1f84 <___pl_fn_4+0xc04>
    1b00: aa1603e2     	mov	x2, x22
    1b04: f9401042     	ldr	x2, [x2, #0x20]
    1b08: b8345853     	str	w19, [x2, w20, uxtw #2]
    1b0c: aa1603e2     	mov	x2, x22
    1b10: b9001840     	str	w0, [x2, #0x18]
    1b14: aa1603e0     	mov	x0, x22
    1b18: b9401000     	ldr	w0, [x0, #0x10]
    1b1c: b9401442     	ldr	w2, [x2, #0x14]
    1b20: 6b02001f     	cmp	w0, w2
    1b24: 54002182     	b.hs	0x1f54 <___pl_fn_4+0xbd4>
    1b28: aa1603e0     	mov	x0, x22
    1b2c: 94000000     	bl	0x1b2c <___pl_fn_4+0x7ac>
    1b30: aa1603e1     	mov	x1, x22
    1b34: b9402c21     	ldr	w1, [x1, #0x2c]
    1b38: 35002ce1     	cbnz	w1, 0x20d4 <___pl_fn_4+0xd54>
    1b3c: aa1603e1     	mov	x1, x22
    1b40: b9001834     	str	w20, [x1, #0x18]
    1b44: 34001f13     	cbz	w19, 0x1f24 <___pl_fn_4+0xba4>
    1b48: aa1603e1     	mov	x1, x22
    1b4c: aa1303e2     	mov	x2, x19
    1b50: f940002a     	ldr	x10, [x1]
    1b54: 2a0203e9     	mov	w9, w2
    1b58: 8b090d49     	add	x9, x10, x9, lsl #3
    1b5c: f862594a     	ldr	x10, [x10, w2, uxtw #3]
    1b60: d360fd4a     	lsr	x10, x10, #32
    1b64: 92403d4b     	and	x11, x10, #0xffff
    1b68: f100097f     	cmp	x11, #0x2
    1b6c: 54000080     	b.eq	0x1b7c <___pl_fn_4+0x7fc>
    1b70: f940092c     	ldr	x12, [x9, #0x10]
    1b74: 927cf98c     	and	x12, x12, #0xfffffffffffffff7
    1b78: f900092c     	str	x12, [x9, #0x10]
    1b7c: 92403d4e     	and	x14, x10, #0xffff
    1b80: 91000dce     	add	x14, x14, #0x3
    1b84: f82e7920     	str	x0, [x9, x14, lsl #3]
    1b88: 52800020     	mov	w0, #0x1                ; =1
    1b8c: aa0003f4     	mov	x20, x0
    1b90: aa1603e0     	mov	x0, x22
    1b94: aa1603e0     	mov	x0, x22
    1b98: b9401000     	ldr	w0, [x0, #0x10]
    1b9c: 51000400     	sub	w0, w0, #0x1
    1ba0: aa1603ed     	mov	x13, x22
    1ba4: b90011a0     	str	w0, [x13, #0x10]
    1ba8: aa1403e0     	mov	x0, x20
    1bac: 910283ff     	add	sp, sp, #0xa0
    1bb0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1bb4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1bb8: f84107f9     	ldr	x25, [sp], #0x10
    1bbc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1bc0: d65f03c0     	ret
    1bc4: aa0003f6     	mov	x22, x0
    1bc8: 52800621     	mov	w1, #0x31               ; =49
    1bcc: 52800003     	mov	w3, #0x0                ; =0
    1bd0: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1bd4: f9400084     	ldr	x4, [x4]
    1bd8: aa1603e0     	mov	x0, x22
    1bdc: aa1303e2     	mov	x2, x19
    1be0: d63f0080     	blr	x4
    1be4: 34ffc040     	cbz	w0, 0x13ec <___pl_fn_4+0x6c>
    1be8: 1400013b     	b	0x20d4 <___pl_fn_4+0xd54>
    1bec: 52800641     	mov	w1, #0x32               ; =50
    1bf0: 52800043     	mov	w3, #0x2                ; =2
    1bf4: 9000000f     	adrp	x15, 0x1000 <___pl_fn_3+0x3a0>
    1bf8: f94001ef     	ldr	x15, [x15]
    1bfc: aa1603e0     	mov	x0, x22
    1c00: aa1303e2     	mov	x2, x19
    1c04: d63f01e0     	blr	x15
    1c08: 34ffc140     	cbz	w0, 0x1430 <___pl_fn_4+0xb0>
    1c0c: 14000132     	b	0x20d4 <___pl_fn_4+0xd54>
    1c10: d2800001     	mov	x1, #0x0                ; =0
    1c14: 910003e3     	mov	x3, sp
    1c18: f80003e1     	stur	x1, [sp]
    1c1c: f80083e0     	stur	x0, [sp, #0x8]
    1c20: 52800681     	mov	w1, #0x34               ; =52
    1c24: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1c28: f9400084     	ldr	x4, [x4]
    1c2c: aa1603e0     	mov	x0, x22
    1c30: aa1303e2     	mov	x2, x19
    1c34: d63f0080     	blr	x4
    1c38: 34ffc260     	cbz	w0, 0x1484 <___pl_fn_4+0x104>
    1c3c: 14000126     	b	0x20d4 <___pl_fn_4+0xd54>
    1c40: 528006a1     	mov	w1, #0x35               ; =53
    1c44: 52800023     	mov	w3, #0x1                ; =1
    1c48: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1c4c: f9400084     	ldr	x4, [x4]
    1c50: aa1603e0     	mov	x0, x22
    1c54: aa1303e2     	mov	x2, x19
    1c58: d63f0080     	blr	x4
    1c5c: 34ffc320     	cbz	w0, 0x14c0 <___pl_fn_4+0x140>
    1c60: 1400011d     	b	0x20d4 <___pl_fn_4+0xd54>
    1c64: 528006c1     	mov	w1, #0x36               ; =54
    1c68: 52800063     	mov	w3, #0x3                ; =3
    1c6c: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1c70: f9400084     	ldr	x4, [x4]
    1c74: aa1603e0     	mov	x0, x22
    1c78: aa1303e2     	mov	x2, x19
    1c7c: d63f0080     	blr	x4
    1c80: 34ffc420     	cbz	w0, 0x1504 <___pl_fn_4+0x184>
    1c84: 14000114     	b	0x20d4 <___pl_fn_4+0xd54>
    1c88: d2800021     	mov	x1, #0x1                ; =1
    1c8c: 910043e3     	add	x3, sp, #0x10
    1c90: f80103e1     	stur	x1, [sp, #0x10]
    1c94: f80183e0     	stur	x0, [sp, #0x18]
    1c98: 52800701     	mov	w1, #0x38               ; =56
    1c9c: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1ca0: f9400084     	ldr	x4, [x4]
    1ca4: aa1603e0     	mov	x0, x22
    1ca8: aa1303e2     	mov	x2, x19
    1cac: d63f0080     	blr	x4
    1cb0: 34ffc560     	cbz	w0, 0x155c <___pl_fn_4+0x1dc>
    1cb4: 14000108     	b	0x20d4 <___pl_fn_4+0xd54>
    1cb8: 52800721     	mov	w1, #0x39               ; =57
    1cbc: 52800003     	mov	w3, #0x0                ; =0
    1cc0: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1cc4: f9400084     	ldr	x4, [x4]
    1cc8: aa1603e0     	mov	x0, x22
    1ccc: aa1303e2     	mov	x2, x19
    1cd0: d63f0080     	blr	x4
    1cd4: 34ffc600     	cbz	w0, 0x1594 <___pl_fn_4+0x214>
    1cd8: 140000ff     	b	0x20d4 <___pl_fn_4+0xd54>
    1cdc: d2800000     	mov	x0, #0x0                ; =0
    1ce0: 910083e3     	add	x3, sp, #0x20
    1ce4: f80203e0     	stur	x0, [sp, #0x20]
    1ce8: d2803e80     	mov	x0, #0x1f4              ; =500
    1cec: f80283e0     	stur	x0, [sp, #0x28]
    1cf0: 52800741     	mov	w1, #0x3a               ; =58
    1cf4: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1cf8: f9400084     	ldr	x4, [x4]
    1cfc: aa1603e0     	mov	x0, x22
    1d00: aa1303e2     	mov	x2, x19
    1d04: d63f0080     	blr	x4
    1d08: 34ffc740     	cbz	w0, 0x15f0 <___pl_fn_4+0x270>
    1d0c: 140000f2     	b	0x20d4 <___pl_fn_4+0xd54>
    1d10: 52800761     	mov	w1, #0x3b               ; =59
    1d14: 52800043     	mov	w3, #0x2                ; =2
    1d18: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1d1c: f9400084     	ldr	x4, [x4]
    1d20: aa1603e0     	mov	x0, x22
    1d24: aa1303e2     	mov	x2, x19
    1d28: d63f0080     	blr	x4
    1d2c: 34ffc800     	cbz	w0, 0x162c <___pl_fn_4+0x2ac>
    1d30: 140000e9     	b	0x20d4 <___pl_fn_4+0xd54>
    1d34: 9100c3e3     	add	x3, sp, #0x30
    1d38: f80303f4     	stur	x20, [sp, #0x30]
    1d3c: f80383e0     	stur	x0, [sp, #0x38]
    1d40: 528007e1     	mov	w1, #0x3f               ; =63
    1d44: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1d48: f9400084     	ldr	x4, [x4]
    1d4c: aa1603e0     	mov	x0, x22
    1d50: aa1303e2     	mov	x2, x19
    1d54: d63f0080     	blr	x4
    1d58: 34ffccc0     	cbz	w0, 0x16f0 <___pl_fn_4+0x370>
    1d5c: 140000de     	b	0x20d4 <___pl_fn_4+0xd54>
    1d60: 52800821     	mov	w1, #0x41               ; =65
    1d64: 52800003     	mov	w3, #0x0                ; =0
    1d68: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1d6c: f9400084     	ldr	x4, [x4]
    1d70: aa1603e0     	mov	x0, x22
    1d74: aa1303e2     	mov	x2, x19
    1d78: d63f0080     	blr	x4
    1d7c: 34ffcda0     	cbz	w0, 0x1730 <___pl_fn_4+0x3b0>
    1d80: 140000d5     	b	0x20d4 <___pl_fn_4+0xd54>
    1d84: 910103e3     	add	x3, sp, #0x40
    1d88: f80403f9     	stur	x25, [sp, #0x40]
    1d8c: f80483f9     	stur	x25, [sp, #0x48]
    1d90: 52800841     	mov	w1, #0x42               ; =66
    1d94: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1d98: f9400084     	ldr	x4, [x4]
    1d9c: aa1603e0     	mov	x0, x22
    1da0: aa1303e2     	mov	x2, x19
    1da4: d63f0080     	blr	x4
    1da8: 34ffcec0     	cbz	w0, 0x1780 <___pl_fn_4+0x400>
    1dac: 140000ca     	b	0x20d4 <___pl_fn_4+0xd54>
    1db0: 52800861     	mov	w1, #0x43               ; =67
    1db4: 52800043     	mov	w3, #0x2                ; =2
    1db8: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1dbc: f9400084     	ldr	x4, [x4]
    1dc0: aa1603e0     	mov	x0, x22
    1dc4: aa1303e2     	mov	x2, x19
    1dc8: d63f0080     	blr	x4
    1dcc: 34ffcf80     	cbz	w0, 0x17bc <___pl_fn_4+0x43c>
    1dd0: 140000c1     	b	0x20d4 <___pl_fn_4+0xd54>
    1dd4: 910143e3     	add	x3, sp, #0x50
    1dd8: f80503f5     	stur	x21, [sp, #0x50]
    1ddc: f80583e0     	stur	x0, [sp, #0x58]
    1de0: 528008c1     	mov	w1, #0x46               ; =70
    1de4: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1de8: f9400084     	ldr	x4, [x4]
    1dec: aa1603e0     	mov	x0, x22
    1df0: aa1303e2     	mov	x2, x19
    1df4: d63f0080     	blr	x4
    1df8: 34ffd3a0     	cbz	w0, 0x186c <___pl_fn_4+0x4ec>
    1dfc: 140000b6     	b	0x20d4 <___pl_fn_4+0xd54>
    1e00: 52800901     	mov	w1, #0x48               ; =72
    1e04: 52800023     	mov	w3, #0x1                ; =1
    1e08: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1e0c: f9400084     	ldr	x4, [x4]
    1e10: aa1603e0     	mov	x0, x22
    1e14: aa1303e2     	mov	x2, x19
    1e18: d63f0080     	blr	x4
    1e1c: 34ffd4a0     	cbz	w0, 0x18b0 <___pl_fn_4+0x530>
    1e20: 140000ad     	b	0x20d4 <___pl_fn_4+0xd54>
    1e24: d2800020     	mov	x0, #0x1                ; =1
    1e28: 910183e3     	add	x3, sp, #0x60
    1e2c: f80603e0     	stur	x0, [sp, #0x60]
    1e30: d2803e80     	mov	x0, #0x1f4              ; =500
    1e34: f80683e0     	stur	x0, [sp, #0x68]
    1e38: 52800921     	mov	w1, #0x49               ; =73
    1e3c: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1e40: f9400084     	ldr	x4, [x4]
    1e44: aa1603e0     	mov	x0, x22
    1e48: aa1303e2     	mov	x2, x19
    1e4c: d63f0080     	blr	x4
    1e50: 34ffd5a0     	cbz	w0, 0x1904 <___pl_fn_4+0x584>
    1e54: 140000a0     	b	0x20d4 <___pl_fn_4+0xd54>
    1e58: 52800941     	mov	w1, #0x4a               ; =74
    1e5c: 52800063     	mov	w3, #0x3                ; =3
    1e60: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1e64: f9400084     	ldr	x4, [x4]
    1e68: aa1603e0     	mov	x0, x22
    1e6c: aa1303e2     	mov	x2, x19
    1e70: d63f0080     	blr	x4
    1e74: 34ffd660     	cbz	w0, 0x1940 <___pl_fn_4+0x5c0>
    1e78: 14000097     	b	0x20d4 <___pl_fn_4+0xd54>
    1e7c: d2800064     	mov	x4, #0x3                ; =3
    1e80: 9101c3e3     	add	x3, sp, #0x70
    1e84: f80703e4     	stur	x4, [sp, #0x70]
    1e88: f80783e0     	stur	x0, [sp, #0x78]
    1e8c: 528009c1     	mov	w1, #0x4e               ; =78
    1e90: 90000005     	adrp	x5, 0x1000 <___pl_fn_3+0x3a0>
    1e94: f94000a5     	ldr	x5, [x5]
    1e98: aa1603e0     	mov	x0, x22
    1e9c: aa1303e2     	mov	x2, x19
    1ea0: d63f00a0     	blr	x5
    1ea4: 34ffdae0     	cbz	w0, 0x1a00 <___pl_fn_4+0x680>
    1ea8: 1400008b     	b	0x20d4 <___pl_fn_4+0xd54>
    1eac: 52800a01     	mov	w1, #0x50               ; =80
    1eb0: 52800023     	mov	w3, #0x1                ; =1
    1eb4: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1eb8: f9400084     	ldr	x4, [x4]
    1ebc: aa1603e0     	mov	x0, x22
    1ec0: aa1303e2     	mov	x2, x19
    1ec4: d63f0080     	blr	x4
    1ec8: 34ffdbe0     	cbz	w0, 0x1a44 <___pl_fn_4+0x6c4>
    1ecc: 14000082     	b	0x20d4 <___pl_fn_4+0xd54>
    1ed0: d2800020     	mov	x0, #0x1                ; =1
    1ed4: 910203e3     	add	x3, sp, #0x80
    1ed8: f80803e0     	stur	x0, [sp, #0x80]
    1edc: f80883f9     	stur	x25, [sp, #0x88]
    1ee0: 52800a21     	mov	w1, #0x51               ; =81
    1ee4: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1ee8: f9400084     	ldr	x4, [x4]
    1eec: aa1603e0     	mov	x0, x22
    1ef0: aa1303e2     	mov	x2, x19
    1ef4: d63f0080     	blr	x4
    1ef8: 34ffdd20     	cbz	w0, 0x1a9c <___pl_fn_4+0x71c>
    1efc: 14000076     	b	0x20d4 <___pl_fn_4+0xd54>
    1f00: 52800a41     	mov	w1, #0x52               ; =82
    1f04: 52800063     	mov	w3, #0x3                ; =3
    1f08: 90000004     	adrp	x4, 0x1000 <___pl_fn_3+0x3a0>
    1f0c: f9400084     	ldr	x4, [x4]
    1f10: aa1603e0     	mov	x0, x22
    1f14: aa1303e2     	mov	x2, x19
    1f18: d63f0080     	blr	x4
    1f1c: 34ffdde0     	cbz	w0, 0x1ad8 <___pl_fn_4+0x758>
    1f20: 1400006d     	b	0x20d4 <___pl_fn_4+0xd54>
    1f24: d2800064     	mov	x4, #0x3                ; =3
    1f28: 910243e3     	add	x3, sp, #0x90
    1f2c: f80903e4     	stur	x4, [sp, #0x90]
    1f30: f80983e0     	stur	x0, [sp, #0x98]
    1f34: 52800aa1     	mov	w1, #0x55               ; =85
    1f38: 90000006     	adrp	x6, 0x1000 <___pl_fn_3+0x3a0>
    1f3c: f94000c6     	ldr	x6, [x6]
    1f40: aa1303e2     	mov	x2, x19
    1f44: aa1603e0     	mov	x0, x22
    1f48: d63f00c0     	blr	x6
    1f4c: 34ffe1e0     	cbz	w0, 0x1b88 <___pl_fn_4+0x808>
    1f50: 14000061     	b	0x20d4 <___pl_fn_4+0xd54>
    1f54: 52800a81     	mov	w1, #0x54               ; =84
    1f58: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x3a0>
    1f5c: f9400042     	ldr	x2, [x2]
    1f60: aa1603e0     	mov	x0, x22
    1f64: d63f0040     	blr	x2
    1f68: 52800000     	mov	w0, #0x0                ; =0
    1f6c: 910283ff     	add	sp, sp, #0xa0
    1f70: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1f74: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1f78: f84107f9     	ldr	x25, [sp], #0x10
    1f7c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1f80: d65f03c0     	ret
    1f84: 52800a61     	mov	w1, #0x53               ; =83
    1f88: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x3a0>
    1f8c: f9400042     	ldr	x2, [x2]
    1f90: aa1603e0     	mov	x0, x22
    1f94: d63f0040     	blr	x2
    1f98: 52800000     	mov	w0, #0x0                ; =0
    1f9c: 910283ff     	add	sp, sp, #0xa0
    1fa0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1fa4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1fa8: f84107f9     	ldr	x25, [sp], #0x10
    1fac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1fb0: d65f03c0     	ret
    1fb4: 528009a1     	mov	w1, #0x4d               ; =77
    1fb8: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x3a0>
    1fbc: f9400042     	ldr	x2, [x2]
    1fc0: aa1603e0     	mov	x0, x22
    1fc4: d63f0040     	blr	x2
    1fc8: 52800000     	mov	w0, #0x0                ; =0
    1fcc: 910283ff     	add	sp, sp, #0xa0
    1fd0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1fd4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1fd8: f84107f9     	ldr	x25, [sp], #0x10
    1fdc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1fe0: d65f03c0     	ret
    1fe4: 52800981     	mov	w1, #0x4c               ; =76
    1fe8: 90000002     	adrp	x2, 0x1000 <___pl_fn_3+0x3a0>
    1fec: f9400042     	ldr	x2, [x2]
    1ff0: aa1603e0     	mov	x0, x22
    1ff4: d63f0040     	blr	x2
    1ff8: 52800000     	mov	w0, #0x0                ; =0
    1ffc: 910283ff     	add	sp, sp, #0xa0
    2000: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2004: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2008: f84107f9     	ldr	x25, [sp], #0x10
    200c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2010: d65f03c0     	ret
    2014: 52800961     	mov	w1, #0x4b               ; =75
    2018: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc80>
    201c: f9400042     	ldr	x2, [x2]
    2020: aa1603e0     	mov	x0, x22
    2024: d63f0040     	blr	x2
    2028: 52800000     	mov	w0, #0x0                ; =0
    202c: 910283ff     	add	sp, sp, #0xa0
    2030: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2034: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2038: f84107f9     	ldr	x25, [sp], #0x10
    203c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2040: d65f03c0     	ret
    2044: 528008a1     	mov	w1, #0x45               ; =69
    2048: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc80>
    204c: f9400042     	ldr	x2, [x2]
    2050: aa1603e0     	mov	x0, x22
    2054: d63f0040     	blr	x2
    2058: 52800000     	mov	w0, #0x0                ; =0
    205c: 910283ff     	add	sp, sp, #0xa0
    2060: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2064: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2068: f84107f9     	ldr	x25, [sp], #0x10
    206c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2070: d65f03c0     	ret
    2074: 52800881     	mov	w1, #0x44               ; =68
    2078: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc80>
    207c: f9400042     	ldr	x2, [x2]
    2080: aa1603e0     	mov	x0, x22
    2084: d63f0040     	blr	x2
    2088: 52800000     	mov	w0, #0x0                ; =0
    208c: 910283ff     	add	sp, sp, #0xa0
    2090: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2094: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2098: f84107f9     	ldr	x25, [sp], #0x10
    209c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    20a0: d65f03c0     	ret
    20a4: 528007c1     	mov	w1, #0x3e               ; =62
    20a8: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc80>
    20ac: f9400042     	ldr	x2, [x2]
    20b0: aa1603e0     	mov	x0, x22
    20b4: d63f0040     	blr	x2
    20b8: 52800000     	mov	w0, #0x0                ; =0
    20bc: 910283ff     	add	sp, sp, #0xa0
    20c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    20c4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    20c8: f84107f9     	ldr	x25, [sp], #0x10
    20cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    20d0: d65f03c0     	ret
    20d4: 52800000     	mov	w0, #0x0                ; =0
    20d8: 910283ff     	add	sp, sp, #0xa0
    20dc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    20e0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    20e4: f84107f9     	ldr	x25, [sp], #0x10
    20e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    20ec: d65f03c0     	ret
    20f0: 528007a1     	mov	w1, #0x3d               ; =61
    20f4: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc80>
    20f8: f9400042     	ldr	x2, [x2]
    20fc: aa1603e0     	mov	x0, x22
    2100: d63f0040     	blr	x2
    2104: 52800000     	mov	w0, #0x0                ; =0
    2108: 910283ff     	add	sp, sp, #0xa0
    210c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2110: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2114: f84107f9     	ldr	x25, [sp], #0x10
    2118: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    211c: d65f03c0     	ret
    2120: 52800781     	mov	w1, #0x3c               ; =60
    2124: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc80>
    2128: f9400042     	ldr	x2, [x2]
    212c: aa1603e0     	mov	x0, x22
    2130: d63f0040     	blr	x2
    2134: 52800000     	mov	w0, #0x0                ; =0
    2138: 910283ff     	add	sp, sp, #0xa0
    213c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2140: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2144: f84107f9     	ldr	x25, [sp], #0x10
    2148: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    214c: d65f03c0     	ret
    2150: 528006e1     	mov	w1, #0x37               ; =55
    2154: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc80>
    2158: f9400042     	ldr	x2, [x2]
    215c: aa1603e0     	mov	x0, x22
    2160: d63f0040     	blr	x2
    2164: 52800000     	mov	w0, #0x0                ; =0
    2168: 910283ff     	add	sp, sp, #0xa0
    216c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2170: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2174: f84107f9     	ldr	x25, [sp], #0x10
    2178: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    217c: d65f03c0     	ret
    2180: 52800661     	mov	w1, #0x33               ; =51
    2184: 90000002     	adrp	x2, 0x2000 <___pl_fn_4+0xc80>
    2188: f9400042     	ldr	x2, [x2]
    218c: aa1603e0     	mov	x0, x22
    2190: d63f0040     	blr	x2
    2194: 52800000     	mov	w0, #0x0                ; =0
    2198: 910283ff     	add	sp, sp, #0xa0
    219c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    21a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    21a4: f84107f9     	ldr	x25, [sp], #0x10
    21a8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    21ac: d65f03c0     	ret
