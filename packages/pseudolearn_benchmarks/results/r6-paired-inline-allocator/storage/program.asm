
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_94328/storage/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
       c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      10: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      14: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      18: d10143ff     	sub	sp, sp, #0x50
      1c: aa0103f4     	mov	x20, x1
      20: aa0203f7     	mov	x23, x2
      24: aa0303f9     	mov	x25, x3
      28: b9401001     	ldr	w1, [x0, #0x10]
      2c: 11000421     	add	w1, w1, #0x1
      30: b9001001     	str	w1, [x0, #0x10]
      34: f9402401     	ldr	x1, [x0, #0x48]
      38: aa1903e3     	mov	x3, x25
      3c: 2a0303f3     	mov	w19, w3
      40: d1000662     	sub	x2, x19, #0x1
      44: eb01005f     	cmp	x2, x1
      48: 540033c2     	b.hs	0x6c0 <___pl_fn_0+0x6c0>
      4c: f9402001     	ldr	x1, [x0, #0x40]
      50: aa0003f6     	mov	x22, x0
      54: d2800602     	mov	x2, #0x30               ; =48
      58: d1000663     	sub	x3, x19, #0x1
      5c: 9b027c60     	mul	x0, x3, x2
      60: 9b020462     	madd	x2, x3, x2, x1
      64: f9400442     	ldr	x2, [x2, #0x8]
      68: b50000a2     	cbnz	x2, 0x7c <___pl_fn_0+0x7c>
      6c: 14000196     	b	0x6c4 <___pl_fn_0+0x6c4>
      70: aa1603e0     	mov	x0, x22
      74: f9401800     	ldr	x0, [x0, #0x30]
      78: 14000002     	b	0x80 <___pl_fn_0+0x80>
      7c: f8606820     	ldr	x0, [x1, x0]
      80: d2800021     	mov	x1, #0x1                ; =1
      84: ab010003     	adds	x3, x0, x1
      88: 9a9f77e0     	cset	x0, vs
      8c: 72001c1f     	tst	w0, #0xff
      90: 54005aa1     	b.ne	0xbe4 <___pl_fn_0+0xbe4>
      94: aa1603e0     	mov	x0, x22
      98: f9402400     	ldr	x0, [x0, #0x48]
      9c: d1000661     	sub	x1, x19, #0x1
      a0: eb00003f     	cmp	x1, x0
      a4: 54003202     	b.hs	0x6e4 <___pl_fn_0+0x6e4>
      a8: aa1603e0     	mov	x0, x22
      ac: f9402000     	ldr	x0, [x0, #0x40]
      b0: d2800601     	mov	x1, #0x30               ; =48
      b4: d1000664     	sub	x4, x19, #0x1
      b8: 9b017c82     	mul	x2, x4, x1
      bc: 9b010081     	madd	x1, x4, x1, x0
      c0: f9400824     	ldr	x4, [x1, #0x10]
      c4: b5000084     	cbnz	x4, 0xd4 <___pl_fn_0+0xd4>
      c8: 14000187     	b	0x6e4 <___pl_fn_0+0x6e4>
      cc: aa1603e0     	mov	x0, x22
      d0: 14000005     	b	0xe4 <___pl_fn_0+0xe4>
      d4: f8226803     	str	x3, [x0, x2]
      d8: d2800020     	mov	x0, #0x1                ; =1
      dc: f9000420     	str	x0, [x1, #0x8]
      e0: aa1603e0     	mov	x0, x22
      e4: aa1603e0     	mov	x0, x22
      e8: f9403c00     	ldr	x0, [x0, #0x78]
      ec: 374030c0     	tbnz	w0, #0x8, 0x704 <___pl_fn_0+0x704>
      f0: aa1603e0     	mov	x0, x22
      f4: f9403800     	ldr	x0, [x0, #0x70]
      f8: f100001f     	cmp	x0, #0x0
      fc: 5400308d     	b.le	0x70c <___pl_fn_0+0x70c>
     100: aa1603e0     	mov	x0, x22
     104: f9403401     	ldr	x1, [x0, #0x68]
     108: f100183f     	cmp	x1, #0x6
     10c: 5400304b     	b.lt	0x714 <___pl_fn_0+0x714>
     110: aa1603e0     	mov	x0, x22
     114: f9402800     	ldr	x0, [x0, #0x50]
     118: aa1603e1     	mov	x1, x22
     11c: f9402c24     	ldr	x4, [x1, #0x58]
     120: 91002005     	add	x5, x0, #0x8
     124: eb0400bf     	cmp	x5, x4
     128: 54002fa8     	b.hi	0x71c <___pl_fn_0+0x71c>
     12c: aa1603e1     	mov	x1, x22
     130: f9404427     	ldr	x7, [x1, #0x88]
     134: f9404828     	ldr	x8, [x1, #0x90]
     138: eb0800ff     	cmp	x7, x8
     13c: 54002f42     	b.hs	0x724 <___pl_fn_0+0x724>
     140: aa1603e1     	mov	x1, x22
     144: b940182a     	ldr	w10, [x1, #0x18]
     148: aa1603e2     	mov	x2, x22
     14c: b9401c4b     	ldr	w11, [x2, #0x1c]
     150: 1100054a     	add	w10, w10, #0x1
     154: 6b0b015f     	cmp	w10, w11
     158: 54000249     	b.ls	0x1a0 <___pl_fn_0+0x1a0>
     15c: 14000174     	b	0x72c <___pl_fn_0+0x72c>
     160: aa1603e0     	mov	x0, x22
     164: f940100f     	ldr	x15, [x0, #0x20]
     168: aa1703e2     	mov	x2, x23
     16c: b83359e2     	str	w2, [x15, w19, uxtw #2]
     170: b900180d     	str	w13, [x0, #0x18]
     174: 52800081     	mov	w1, #0x4                ; =4
     178: 52800022     	mov	w2, #0x1                ; =1
     17c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     180: f9400063     	ldr	x3, [x3]
     184: d63f0060     	blr	x3
     188: 35004d00     	cbnz	w0, 0xb28 <___pl_fn_0+0xb28>
     18c: aa1603e0     	mov	x0, x22
     190: f9401800     	ldr	x0, [x0, #0x30]
     194: aa1603e1     	mov	x1, x22
     198: b9001833     	str	w19, [x1, #0x18]
     19c: 1400002b     	b	0x248 <___pl_fn_0+0x248>
     1a0: aa1603e1     	mov	x1, x22
     1a4: f9403023     	ldr	x3, [x1, #0x60]
     1a8: f9400024     	ldr	x4, [x1]
     1ac: d2800085     	mov	x5, #0x4                ; =4
     1b0: f2c00065     	movk	x5, #0x3, lsl #32
     1b4: 2a0003e1     	mov	w1, w0
     1b8: 8b010c82     	add	x2, x4, x1, lsl #3
     1bc: f8205885     	str	x5, [x4, w0, uxtw #3]
     1c0: 91000463     	add	x3, x3, #0x1
     1c4: f9000443     	str	x3, [x2, #0x8]
     1c8: 92800004     	mov	x4, #-0x1               ; =-1
     1cc: f9000844     	str	x4, [x2, #0x10]
     1d0: d2800004     	mov	x4, #0x0                ; =0
     1d4: f9000c44     	str	x4, [x2, #0x18]
     1d8: f9001044     	str	x4, [x2, #0x20]
     1dc: f9001444     	str	x4, [x2, #0x28]
     1e0: f9001844     	str	x4, [x2, #0x30]
     1e4: f9001c44     	str	x4, [x2, #0x38]
     1e8: aa1603e2     	mov	x2, x22
     1ec: f9003043     	str	x3, [x2, #0x60]
     1f0: 91002002     	add	x2, x0, #0x8
     1f4: aa1603e3     	mov	x3, x22
     1f8: f9002862     	str	x2, [x3, #0x50]
     1fc: aa1603e2     	mov	x2, x22
     200: f9403442     	ldr	x2, [x2, #0x68]
     204: d1001842     	sub	x2, x2, #0x6
     208: f9003462     	str	x2, [x3, #0x68]
     20c: f9403862     	ldr	x2, [x3, #0x70]
     210: d1001842     	sub	x2, x2, #0x6
     214: aa1603e6     	mov	x6, x22
     218: f90038c2     	str	x2, [x6, #0x70]
     21c: aa1603e8     	mov	x8, x22
     220: f9404102     	ldr	x2, [x8, #0x80]
     224: b25d0021     	orr	x1, x1, #0x800000000
     228: d37cece4     	lsl	x4, x7, #4
     22c: 8b071043     	add	x3, x2, x7, lsl #4
     230: f8246841     	str	x1, [x2, x4]
     234: d28000c1     	mov	x1, #0x6                ; =6
     238: f9000461     	str	x1, [x3, #0x8]
     23c: 910004e1     	add	x1, x7, #0x1
     240: aa1603e2     	mov	x2, x22
     244: f9004441     	str	x1, [x2, #0x88]
     248: 52800001     	mov	w1, #0x0                ; =0
     24c: aa0103fa     	mov	x26, x1
     250: 34004b00     	cbz	w0, 0xbb0 <___pl_fn_0+0xbb0>
     254: aa1403f3     	mov	x19, x20
     258: f100067f     	cmp	x19, #0x1
     25c: 54001960     	b.eq	0x588 <___pl_fn_0+0x588>
     260: d2800021     	mov	x1, #0x1                ; =1
     264: eb010261     	subs	x1, x19, x1
     268: 9a9f77e2     	cset	x2, vs
     26c: 72001c5f     	tst	w2, #0xff
     270: 540040e1     	b.ne	0xa8c <___pl_fn_0+0xa8c>
     274: aa1603e2     	mov	x2, x22
     278: b9401855     	ldr	w21, [x2, #0x18]
     27c: b9401c42     	ldr	w2, [x2, #0x1c]
     280: 11000aa3     	add	w3, w21, #0x2
     284: 6b02007f     	cmp	w3, w2
     288: 54003e88     	b.hi	0xa58 <___pl_fn_0+0xa58>
     28c: aa1603e2     	mov	x2, x22
     290: f9401042     	ldr	x2, [x2, #0x20]
     294: 2a1503e3     	mov	w3, w21
     298: d2800054     	mov	x20, #0x2               ; =2
     29c: 8b030843     	add	x3, x2, x3, lsl #2
     2a0: aa1703e9     	mov	x9, x23
     2a4: b8355849     	str	w9, [x2, w21, uxtw #2]
     2a8: b9000460     	str	w0, [x3, #0x4]
     2ac: aa0003f8     	mov	x24, x0
     2b0: 11000aa0     	add	w0, w21, #0x2
     2b4: aa1603e2     	mov	x2, x22
     2b8: b9001840     	str	w0, [x2, #0x18]
     2bc: aa1603e0     	mov	x0, x22
     2c0: b9401000     	ldr	w0, [x0, #0x10]
     2c4: b9401442     	ldr	w2, [x2, #0x14]
     2c8: 6b02001f     	cmp	w0, w2
     2cc: 54003ac2     	b.hs	0xa24 <___pl_fn_0+0xa24>
     2d0: aa1603e0     	mov	x0, x22
     2d4: aa1703e2     	mov	x2, x23
     2d8: aa1903e3     	mov	x3, x25
     2dc: 94000000     	bl	0x2dc <___pl_fn_0+0x2dc>
     2e0: aa1603e1     	mov	x1, x22
     2e4: b9402c21     	ldr	w1, [x1, #0x2c]
     2e8: 35004201     	cbnz	w1, 0xb28 <___pl_fn_0+0xb28>
     2ec: aa1603e1     	mov	x1, x22
     2f0: b9001835     	str	w21, [x1, #0x18]
     2f4: aa1803e1     	mov	x1, x24
     2f8: 34002441     	cbz	w1, 0x780 <___pl_fn_0+0x780>
     2fc: aa1603e8     	mov	x8, x22
     300: aa0103f8     	mov	x24, x1
     304: f9400102     	ldr	x2, [x8]
     308: aa1803ef     	mov	x15, x24
     30c: 2a0f03e1     	mov	w1, w15
     310: 8b010c41     	add	x1, x2, x1, lsl #3
     314: aa1803e3     	mov	x3, x24
     318: f8635842     	ldr	x2, [x2, w3, uxtw #3]
     31c: 2a0003e0     	mov	w0, w0
     320: d360fc42     	lsr	x2, x2, #32
     324: 92403c42     	and	x2, x2, #0xffff
     328: f8227820     	str	x0, [x1, x2, lsl #3]
     32c: d2800020     	mov	x0, #0x1                ; =1
     330: eb000261     	subs	x1, x19, x0
     334: 9a9f77e0     	cset	x0, vs
     338: 72001c1f     	tst	w0, #0xff
     33c: 540035a1     	b.ne	0x9f0 <___pl_fn_0+0x9f0>
     340: aa1603e0     	mov	x0, x22
     344: b9401815     	ldr	w21, [x0, #0x18]
     348: b9401c00     	ldr	w0, [x0, #0x1c]
     34c: 11000aa2     	add	w2, w21, #0x2
     350: 6b00005f     	cmp	w2, w0
     354: 54003348     	b.hi	0x9bc <___pl_fn_0+0x9bc>
     358: aa1603e0     	mov	x0, x22
     35c: f9401002     	ldr	x2, [x0, #0x20]
     360: 2a1503e3     	mov	w3, w21
     364: 8b030843     	add	x3, x2, x3, lsl #2
     368: aa1703e0     	mov	x0, x23
     36c: b8355840     	str	w0, [x2, w21, uxtw #2]
     370: aa1803e0     	mov	x0, x24
     374: b9000460     	str	w0, [x3, #0x4]
     378: 11000aa4     	add	w4, w21, #0x2
     37c: aa1603e0     	mov	x0, x22
     380: b9001804     	str	w4, [x0, #0x18]
     384: b9401005     	ldr	w5, [x0, #0x10]
     388: b9401406     	ldr	w6, [x0, #0x14]
     38c: 6b0600bf     	cmp	w5, w6
     390: 54002fc2     	b.hs	0x988 <___pl_fn_0+0x988>
     394: aa1603e0     	mov	x0, x22
     398: aa1703e2     	mov	x2, x23
     39c: aa1903e3     	mov	x3, x25
     3a0: 94000000     	bl	0x3a0 <___pl_fn_0+0x3a0>
     3a4: aa1603e1     	mov	x1, x22
     3a8: b9402c27     	ldr	w7, [x1, #0x2c]
     3ac: 35003be7     	cbnz	w7, 0xb28 <___pl_fn_0+0xb28>
     3b0: aa1603e1     	mov	x1, x22
     3b4: b9001835     	str	w21, [x1, #0x18]
     3b8: aa1803e1     	mov	x1, x24
     3bc: 34001fe1     	cbz	w1, 0x7b8 <___pl_fn_0+0x7b8>
     3c0: aa1603e1     	mov	x1, x22
     3c4: f9400022     	ldr	x2, [x1]
     3c8: aa1803e3     	mov	x3, x24
     3cc: 2a0303e1     	mov	w1, w3
     3d0: 8b010c41     	add	x1, x2, x1, lsl #3
     3d4: aa1803e6     	mov	x6, x24
     3d8: f8665842     	ldr	x2, [x2, w6, uxtw #3]
     3dc: 2a0003e0     	mov	w0, w0
     3e0: d360fc42     	lsr	x2, x2, #32
     3e4: 92403c42     	and	x2, x2, #0xffff
     3e8: 91000442     	add	x2, x2, #0x1
     3ec: f8227820     	str	x0, [x1, x2, lsl #3]
     3f0: d2800020     	mov	x0, #0x1                ; =1
     3f4: eb000261     	subs	x1, x19, x0
     3f8: 9a9f77e0     	cset	x0, vs
     3fc: 72001c1f     	tst	w0, #0xff
     400: 54002aa1     	b.ne	0x954 <___pl_fn_0+0x954>
     404: aa1603e0     	mov	x0, x22
     408: b9401815     	ldr	w21, [x0, #0x18]
     40c: b9401c00     	ldr	w0, [x0, #0x1c]
     410: 11000aa2     	add	w2, w21, #0x2
     414: 6b00005f     	cmp	w2, w0
     418: 54002848     	b.hi	0x920 <___pl_fn_0+0x920>
     41c: aa1603e0     	mov	x0, x22
     420: f9401000     	ldr	x0, [x0, #0x20]
     424: 2a1503e2     	mov	w2, w21
     428: 8b020802     	add	x2, x0, x2, lsl #2
     42c: aa1703e3     	mov	x3, x23
     430: b8355803     	str	w3, [x0, w21, uxtw #2]
     434: aa1803e0     	mov	x0, x24
     438: b9000440     	str	w0, [x2, #0x4]
     43c: 11000aa0     	add	w0, w21, #0x2
     440: aa1603e2     	mov	x2, x22
     444: b9001840     	str	w0, [x2, #0x18]
     448: aa1603e0     	mov	x0, x22
     44c: b9401000     	ldr	w0, [x0, #0x10]
     450: b9401442     	ldr	w2, [x2, #0x14]
     454: 6b02001f     	cmp	w0, w2
     458: 540024a2     	b.hs	0x8ec <___pl_fn_0+0x8ec>
     45c: aa1603e0     	mov	x0, x22
     460: aa1703e2     	mov	x2, x23
     464: aa1903e3     	mov	x3, x25
     468: 94000000     	bl	0x468 <___pl_fn_0+0x468>
     46c: aa1603e1     	mov	x1, x22
     470: b9402c21     	ldr	w1, [x1, #0x2c]
     474: 350035a1     	cbnz	w1, 0xb28 <___pl_fn_0+0xb28>
     478: aa1603e1     	mov	x1, x22
     47c: b9001835     	str	w21, [x1, #0x18]
     480: aa1803e1     	mov	x1, x24
     484: 34001b41     	cbz	w1, 0x7ec <___pl_fn_0+0x7ec>
     488: aa1603e1     	mov	x1, x22
     48c: f9400022     	ldr	x2, [x1]
     490: aa1803e1     	mov	x1, x24
     494: 2a0103e1     	mov	w1, w1
     498: 8b010c41     	add	x1, x2, x1, lsl #3
     49c: aa1803e3     	mov	x3, x24
     4a0: f8635842     	ldr	x2, [x2, w3, uxtw #3]
     4a4: 2a0003e0     	mov	w0, w0
     4a8: d360fc42     	lsr	x2, x2, #32
     4ac: 92403c42     	and	x2, x2, #0xffff
     4b0: 91000842     	add	x2, x2, #0x2
     4b4: f8227820     	str	x0, [x1, x2, lsl #3]
     4b8: d2800020     	mov	x0, #0x1                ; =1
     4bc: eb000261     	subs	x1, x19, x0
     4c0: 9a9f77e0     	cset	x0, vs
     4c4: 72001c1f     	tst	w0, #0xff
     4c8: 54001f81     	b.ne	0x8b8 <___pl_fn_0+0x8b8>
     4cc: aa1603e0     	mov	x0, x22
     4d0: b9401813     	ldr	w19, [x0, #0x18]
     4d4: b9401c00     	ldr	w0, [x0, #0x1c]
     4d8: 11000a62     	add	w2, w19, #0x2
     4dc: 6b00005f     	cmp	w2, w0
     4e0: 54001d28     	b.hi	0x884 <___pl_fn_0+0x884>
     4e4: aa1603e0     	mov	x0, x22
     4e8: f9401000     	ldr	x0, [x0, #0x20]
     4ec: 2a1303e2     	mov	w2, w19
     4f0: 8b020802     	add	x2, x0, x2, lsl #2
     4f4: aa1703e3     	mov	x3, x23
     4f8: b8335803     	str	w3, [x0, w19, uxtw #2]
     4fc: aa1803e0     	mov	x0, x24
     500: b9000440     	str	w0, [x2, #0x4]
     504: 11000a60     	add	w0, w19, #0x2
     508: aa1603e2     	mov	x2, x22
     50c: b9001840     	str	w0, [x2, #0x18]
     510: aa1603e0     	mov	x0, x22
     514: b9401000     	ldr	w0, [x0, #0x10]
     518: b9401442     	ldr	w2, [x2, #0x14]
     51c: 6b02001f     	cmp	w0, w2
     520: 54001982     	b.hs	0x850 <___pl_fn_0+0x850>
     524: aa1703e2     	mov	x2, x23
     528: aa1903e3     	mov	x3, x25
     52c: aa1603e0     	mov	x0, x22
     530: 94000000     	bl	0x530 <___pl_fn_0+0x530>
     534: aa1603e1     	mov	x1, x22
     538: b9402c21     	ldr	w1, [x1, #0x2c]
     53c: 35002f61     	cbnz	w1, 0xb28 <___pl_fn_0+0xb28>
     540: aa1603e1     	mov	x1, x22
     544: b9001833     	str	w19, [x1, #0x18]
     548: aa1803e1     	mov	x1, x24
     54c: 34001681     	cbz	w1, 0x81c <___pl_fn_0+0x81c>
     550: aa1603e1     	mov	x1, x22
     554: f9400022     	ldr	x2, [x1]
     558: aa1803e1     	mov	x1, x24
     55c: 2a0103e1     	mov	w1, w1
     560: 8b010c41     	add	x1, x2, x1, lsl #3
     564: aa1803e3     	mov	x3, x24
     568: f8635842     	ldr	x2, [x2, w3, uxtw #3]
     56c: 2a0003e0     	mov	w0, w0
     570: d360fc42     	lsr	x2, x2, #32
     574: 92403c42     	and	x2, x2, #0xffff
     578: 91000c42     	add	x2, x2, #0x3
     57c: f8227820     	str	x0, [x1, x2, lsl #3]
     580: aa1603e0     	mov	x0, x22
     584: 14000042     	b	0x68c <___pl_fn_0+0x68c>
     588: aa0003f8     	mov	x24, x0
     58c: aa1603e0     	mov	x0, x22
     590: b9401813     	ldr	w19, [x0, #0x18]
     594: b9401c08     	ldr	w8, [x0, #0x1c]
     598: 11000a69     	add	w9, w19, #0x2
     59c: 6b08013f     	cmp	w9, w8
     5a0: 54002ee8     	b.hi	0xb7c <___pl_fn_0+0xb7c>
     5a4: aa1603e0     	mov	x0, x22
     5a8: f940100a     	ldr	x10, [x0, #0x20]
     5ac: 2a1303eb     	mov	w11, w19
     5b0: 8b0b094b     	add	x11, x10, x11, lsl #2
     5b4: aa1703e2     	mov	x2, x23
     5b8: b8335942     	str	w2, [x10, w19, uxtw #2]
     5bc: aa1803e0     	mov	x0, x24
     5c0: b9000560     	str	w0, [x11, #0x4]
     5c4: 11000a6c     	add	w12, w19, #0x2
     5c8: aa1603e0     	mov	x0, x22
     5cc: b900180c     	str	w12, [x0, #0x18]
     5d0: b940100d     	ldr	w13, [x0, #0x10]
     5d4: b940140e     	ldr	w14, [x0, #0x14]
     5d8: 6b0e01bf     	cmp	w13, w14
     5dc: 54002b62     	b.hs	0xb48 <___pl_fn_0+0xb48>
     5e0: aa1703e1     	mov	x1, x23
     5e4: aa1603e0     	mov	x0, x22
     5e8: 94000000     	bl	0x5e8 <___pl_fn_0+0x5e8>
     5ec: aa1603e1     	mov	x1, x22
     5f0: b9402c2f     	ldr	w15, [x1, #0x2c]
     5f4: 350029af     	cbnz	w15, 0xb28 <___pl_fn_0+0xb28>
     5f8: aa1603e1     	mov	x1, x22
     5fc: b9001833     	str	w19, [x1, #0x18]
     600: d28ccce1     	mov	x1, #0x6667             ; =26215
     604: f2acccc1     	movk	x1, #0x6666, lsl #16
     608: f2ccccc1     	movk	x1, #0x6666, lsl #32
     60c: f2ecccc1     	movk	x1, #0x6666, lsl #48
     610: 9b417c01     	smulh	x1, x0, x1
     614: 9342fc21     	asr	x1, x1, #2
     618: d37ffc22     	lsr	x2, x1, #63
     61c: 8b020021     	add	x1, x1, x2
     620: d2800142     	mov	x2, #0xa                ; =10
     624: 9b028020     	msub	x0, x1, x2, x0
     628: d2800021     	mov	x1, #0x1                ; =1
     62c: ab010000     	adds	x0, x0, x1
     630: 9a9f77e1     	cset	x1, vs
     634: 72001c3f     	tst	w1, #0xff
     638: 540025e1     	b.ne	0xaf4 <___pl_fn_0+0xaf4>
     63c: aa1803ef     	mov	x15, x24
     640: 3400242f     	cbz	w15, 0xac4 <___pl_fn_0+0xac4>
     644: aa1603e1     	mov	x1, x22
     648: f9400022     	ldr	x2, [x1]
     64c: aa1803e1     	mov	x1, x24
     650: 2a0103e1     	mov	w1, w1
     654: 8b010c41     	add	x1, x2, x1, lsl #3
     658: aa1803e3     	mov	x3, x24
     65c: f8635842     	ldr	x2, [x2, w3, uxtw #3]
     660: d360fc42     	lsr	x2, x2, #32
     664: 92403c43     	and	x3, x2, #0xffff
     668: f100087f     	cmp	x3, #0x2
     66c: 54000080     	b.eq	0x67c <___pl_fn_0+0x67c>
     670: f9400823     	ldr	x3, [x1, #0x10]
     674: 927bf863     	and	x3, x3, #0xffffffffffffffef
     678: f9000823     	str	x3, [x1, #0x10]
     67c: 92403c42     	and	x2, x2, #0xffff
     680: 91001042     	add	x2, x2, #0x4
     684: f8227820     	str	x0, [x1, x2, lsl #3]
     688: aa1603e0     	mov	x0, x22
     68c: aa1603e0     	mov	x0, x22
     690: b9401000     	ldr	w0, [x0, #0x10]
     694: 51000400     	sub	w0, w0, #0x1
     698: aa1603ec     	mov	x12, x22
     69c: b9001180     	str	w0, [x12, #0x10]
     6a0: aa1803e0     	mov	x0, x24
     6a4: 910143ff     	add	sp, sp, #0x50
     6a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     6ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     6b0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     6b4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     6b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     6bc: d65f03c0     	ret
     6c0: aa0003f6     	mov	x22, x0
     6c4: 52800001     	mov	w1, #0x0                ; =0
     6c8: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     6cc: f9400063     	ldr	x3, [x3]
     6d0: aa1603e0     	mov	x0, x22
     6d4: aa1903e2     	mov	x2, x25
     6d8: d63f0060     	blr	x3
     6dc: 34ffcca0     	cbz	w0, 0x70 <___pl_fn_0+0x70>
     6e0: 14000112     	b	0xb28 <___pl_fn_0+0xb28>
     6e4: 52800041     	mov	w1, #0x2                ; =2
     6e8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     6ec: f9400084     	ldr	x4, [x4]
     6f0: aa1603e0     	mov	x0, x22
     6f4: aa1903e2     	mov	x2, x25
     6f8: d63f0080     	blr	x4
     6fc: 34ffce80     	cbz	w0, 0xcc <___pl_fn_0+0xcc>
     700: 1400010a     	b	0xb28 <___pl_fn_0+0xb28>
     704: aa1603e0     	mov	x0, x22
     708: 1400000a     	b	0x730 <___pl_fn_0+0x730>
     70c: aa1603e0     	mov	x0, x22
     710: 14000008     	b	0x730 <___pl_fn_0+0x730>
     714: aa1603e0     	mov	x0, x22
     718: 14000006     	b	0x730 <___pl_fn_0+0x730>
     71c: aa1603e0     	mov	x0, x22
     720: 14000004     	b	0x730 <___pl_fn_0+0x730>
     724: aa1603e0     	mov	x0, x22
     728: 14000002     	b	0x730 <___pl_fn_0+0x730>
     72c: aa1603e0     	mov	x0, x22
     730: aa1603e0     	mov	x0, x22
     734: b9401813     	ldr	w19, [x0, #0x18]
     738: b9401c0e     	ldr	w14, [x0, #0x1c]
     73c: 1100066d     	add	w13, w19, #0x1
     740: 6b0e01bf     	cmp	w13, w14
     744: 54ffd0e9     	b.ls	0x160 <___pl_fn_0+0x160>
     748: 52800061     	mov	w1, #0x3                ; =3
     74c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     750: f9400042     	ldr	x2, [x2]
     754: aa1603e0     	mov	x0, x22
     758: d63f0040     	blr	x2
     75c: 52800000     	mov	w0, #0x0                ; =0
     760: 910143ff     	add	sp, sp, #0x50
     764: a8c153f3     	ldp	x19, x20, [sp], #0x10
     768: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     76c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     770: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     774: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     778: d65f03c0     	ret
     77c: 140000eb     	b	0xb28 <___pl_fn_0+0xb28>
     780: aa0103f8     	mov	x24, x1
     784: d2800001     	mov	x1, #0x0                ; =0
     788: 910003e3     	mov	x3, sp
     78c: f80003e1     	stur	x1, [sp]
     790: 2a0003e0     	mov	w0, w0
     794: f80083e0     	stur	x0, [sp, #0x8]
     798: 52800121     	mov	w1, #0x9                ; =9
     79c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     7a0: f9400084     	ldr	x4, [x4]
     7a4: aa1603e0     	mov	x0, x22
     7a8: aa1803e2     	mov	x2, x24
     7ac: d63f0080     	blr	x4
     7b0: 34ffdbe0     	cbz	w0, 0x32c <___pl_fn_0+0x32c>
     7b4: 140000dd     	b	0xb28 <___pl_fn_0+0xb28>
     7b8: d280002b     	mov	x11, #0x1               ; =1
     7bc: 910043e3     	add	x3, sp, #0x10
     7c0: f80103eb     	stur	x11, [sp, #0x10]
     7c4: 2a0003ec     	mov	w12, w0
     7c8: f80183ec     	stur	x12, [sp, #0x18]
     7cc: 528001a1     	mov	w1, #0xd                ; =13
     7d0: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     7d4: f94001ad     	ldr	x13, [x13]
     7d8: aa1603e0     	mov	x0, x22
     7dc: aa1803e2     	mov	x2, x24
     7e0: d63f01a0     	blr	x13
     7e4: 34ffe060     	cbz	w0, 0x3f0 <___pl_fn_0+0x3f0>
     7e8: 140000d0     	b	0xb28 <___pl_fn_0+0xb28>
     7ec: 910083e3     	add	x3, sp, #0x20
     7f0: f80203f4     	stur	x20, [sp, #0x20]
     7f4: 2a0003e0     	mov	w0, w0
     7f8: f80283e0     	stur	x0, [sp, #0x28]
     7fc: 52800221     	mov	w1, #0x11               ; =17
     800: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     804: f9400084     	ldr	x4, [x4]
     808: aa1603e0     	mov	x0, x22
     80c: aa1803e2     	mov	x2, x24
     810: d63f0080     	blr	x4
     814: 34ffe520     	cbz	w0, 0x4b8 <___pl_fn_0+0x4b8>
     818: 140000c4     	b	0xb28 <___pl_fn_0+0xb28>
     81c: d2800061     	mov	x1, #0x3                ; =3
     820: 9100c3e3     	add	x3, sp, #0x30
     824: f80303e1     	stur	x1, [sp, #0x30]
     828: 2a0003e0     	mov	w0, w0
     82c: f80383e0     	stur	x0, [sp, #0x38]
     830: 528002a1     	mov	w1, #0x15               ; =21
     834: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     838: f9400084     	ldr	x4, [x4]
     83c: aa1603e0     	mov	x0, x22
     840: aa1803e2     	mov	x2, x24
     844: d63f0080     	blr	x4
     848: 34ffe9c0     	cbz	w0, 0x580 <___pl_fn_0+0x580>
     84c: 140000b7     	b	0xb28 <___pl_fn_0+0xb28>
     850: 52800281     	mov	w1, #0x14               ; =20
     854: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     858: f9400042     	ldr	x2, [x2]
     85c: aa1603e0     	mov	x0, x22
     860: d63f0040     	blr	x2
     864: aa1a03e0     	mov	x0, x26
     868: 910143ff     	add	sp, sp, #0x50
     86c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     870: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     874: a8c163f7     	ldp	x23, x24, [sp], #0x10
     878: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     87c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     880: d65f03c0     	ret
     884: 52800261     	mov	w1, #0x13               ; =19
     888: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     88c: f9400042     	ldr	x2, [x2]
     890: aa1603e0     	mov	x0, x22
     894: d63f0040     	blr	x2
     898: aa1a03e0     	mov	x0, x26
     89c: 910143ff     	add	sp, sp, #0x50
     8a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8a8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8ac: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8b4: d65f03c0     	ret
     8b8: 52800241     	mov	w1, #0x12               ; =18
     8bc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     8c0: f9400042     	ldr	x2, [x2]
     8c4: aa1603e0     	mov	x0, x22
     8c8: d63f0040     	blr	x2
     8cc: aa1a03e0     	mov	x0, x26
     8d0: 910143ff     	add	sp, sp, #0x50
     8d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     8d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     8dc: a8c163f7     	ldp	x23, x24, [sp], #0x10
     8e0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     8e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8e8: d65f03c0     	ret
     8ec: 52800201     	mov	w1, #0x10               ; =16
     8f0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     8f4: f9400042     	ldr	x2, [x2]
     8f8: aa1603e0     	mov	x0, x22
     8fc: d63f0040     	blr	x2
     900: aa1a03e0     	mov	x0, x26
     904: 910143ff     	add	sp, sp, #0x50
     908: a8c153f3     	ldp	x19, x20, [sp], #0x10
     90c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     910: a8c163f7     	ldp	x23, x24, [sp], #0x10
     914: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     918: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     91c: d65f03c0     	ret
     920: 528001e1     	mov	w1, #0xf                ; =15
     924: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     928: f9400042     	ldr	x2, [x2]
     92c: aa1603e0     	mov	x0, x22
     930: d63f0040     	blr	x2
     934: aa1a03e0     	mov	x0, x26
     938: 910143ff     	add	sp, sp, #0x50
     93c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     940: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     944: a8c163f7     	ldp	x23, x24, [sp], #0x10
     948: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     94c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     950: d65f03c0     	ret
     954: 528001c1     	mov	w1, #0xe                ; =14
     958: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     95c: f9400042     	ldr	x2, [x2]
     960: aa1603e0     	mov	x0, x22
     964: d63f0040     	blr	x2
     968: aa1a03e0     	mov	x0, x26
     96c: 910143ff     	add	sp, sp, #0x50
     970: a8c153f3     	ldp	x19, x20, [sp], #0x10
     974: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     978: a8c163f7     	ldp	x23, x24, [sp], #0x10
     97c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     980: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     984: d65f03c0     	ret
     988: 52800181     	mov	w1, #0xc                ; =12
     98c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     990: f9400042     	ldr	x2, [x2]
     994: aa1603e0     	mov	x0, x22
     998: d63f0040     	blr	x2
     99c: aa1a03e0     	mov	x0, x26
     9a0: 910143ff     	add	sp, sp, #0x50
     9a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9a8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9ac: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9b0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9b8: d65f03c0     	ret
     9bc: 52800161     	mov	w1, #0xb                ; =11
     9c0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     9c4: f9400063     	ldr	x3, [x3]
     9c8: aa1603e0     	mov	x0, x22
     9cc: d63f0060     	blr	x3
     9d0: aa1a03e0     	mov	x0, x26
     9d4: 910143ff     	add	sp, sp, #0x50
     9d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     9dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     9e0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     9e4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     9e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     9ec: d65f03c0     	ret
     9f0: 52800141     	mov	w1, #0xa                ; =10
     9f4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     9f8: f9400084     	ldr	x4, [x4]
     9fc: aa1603e0     	mov	x0, x22
     a00: d63f0080     	blr	x4
     a04: aa1a03e0     	mov	x0, x26
     a08: 910143ff     	add	sp, sp, #0x50
     a0c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a10: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a14: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a18: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a1c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a20: d65f03c0     	ret
     a24: 52800101     	mov	w1, #0x8                ; =8
     a28: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     a2c: f94000a5     	ldr	x5, [x5]
     a30: aa1603e0     	mov	x0, x22
     a34: d63f00a0     	blr	x5
     a38: aa1a03e0     	mov	x0, x26
     a3c: 910143ff     	add	sp, sp, #0x50
     a40: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a44: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a48: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a4c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a50: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a54: d65f03c0     	ret
     a58: 528000e1     	mov	w1, #0x7                ; =7
     a5c: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     a60: f94000c6     	ldr	x6, [x6]
     a64: aa1603e0     	mov	x0, x22
     a68: d63f00c0     	blr	x6
     a6c: aa1a03e0     	mov	x0, x26
     a70: 910143ff     	add	sp, sp, #0x50
     a74: a8c153f3     	ldp	x19, x20, [sp], #0x10
     a78: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     a7c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     a80: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     a84: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     a88: d65f03c0     	ret
     a8c: 528000c1     	mov	w1, #0x6                ; =6
     a90: 90000007     	adrp	x7, 0x0 <___pl_fn_0>
     a94: f94000e7     	ldr	x7, [x7]
     a98: aa1603e0     	mov	x0, x22
     a9c: d63f00e0     	blr	x7
     aa0: aa1a03e0     	mov	x0, x26
     aa4: 910143ff     	add	sp, sp, #0x50
     aa8: a8c153f3     	ldp	x19, x20, [sp], #0x10
     aac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ab0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ab4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     ab8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     abc: d65f03c0     	ret
     ac0: 1400001a     	b	0xb28 <___pl_fn_0+0xb28>
     ac4: d2800081     	mov	x1, #0x4                ; =4
     ac8: 910103e3     	add	x3, sp, #0x40
     acc: f80403e1     	stur	x1, [sp, #0x40]
     ad0: f80483e0     	stur	x0, [sp, #0x48]
     ad4: 52800341     	mov	w1, #0x1a               ; =26
     ad8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     adc: f9400084     	ldr	x4, [x4]
     ae0: aa1603e0     	mov	x0, x22
     ae4: aa1803e2     	mov	x2, x24
     ae8: d63f0080     	blr	x4
     aec: 34ffdce0     	cbz	w0, 0x688 <___pl_fn_0+0x688>
     af0: 1400000e     	b	0xb28 <___pl_fn_0+0xb28>
     af4: 52800321     	mov	w1, #0x19               ; =25
     af8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     afc: f9400042     	ldr	x2, [x2]
     b00: aa1603e0     	mov	x0, x22
     b04: d63f0040     	blr	x2
     b08: aa1a03e0     	mov	x0, x26
     b0c: 910143ff     	add	sp, sp, #0x50
     b10: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b14: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b18: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b1c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b20: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b24: d65f03c0     	ret
     b28: 52800000     	mov	w0, #0x0                ; =0
     b2c: 910143ff     	add	sp, sp, #0x50
     b30: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b34: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b38: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b3c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b40: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b44: d65f03c0     	ret
     b48: 528002e1     	mov	w1, #0x17               ; =23
     b4c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b50: f9400042     	ldr	x2, [x2]
     b54: aa1603e0     	mov	x0, x22
     b58: d63f0040     	blr	x2
     b5c: aa1a03e0     	mov	x0, x26
     b60: 910143ff     	add	sp, sp, #0x50
     b64: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b68: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b6c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b70: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     b74: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     b78: d65f03c0     	ret
     b7c: 528002c1     	mov	w1, #0x16               ; =22
     b80: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b84: f9400042     	ldr	x2, [x2]
     b88: aa1603e0     	mov	x0, x22
     b8c: d63f0040     	blr	x2
     b90: aa1a03e0     	mov	x0, x26
     b94: 910143ff     	add	sp, sp, #0x50
     b98: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b9c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ba0: a8c163f7     	ldp	x23, x24, [sp], #0x10
     ba4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     ba8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     bac: d65f03c0     	ret
     bb0: 528000a1     	mov	w1, #0x5                ; =5
     bb4: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     bb8: f9400042     	ldr	x2, [x2]
     bbc: aa1603e0     	mov	x0, x22
     bc0: d63f0040     	blr	x2
     bc4: aa1a03e0     	mov	x0, x26
     bc8: 910143ff     	add	sp, sp, #0x50
     bcc: a8c153f3     	ldp	x19, x20, [sp], #0x10
     bd0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     bd4: a8c163f7     	ldp	x23, x24, [sp], #0x10
     bd8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     bdc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     be0: d65f03c0     	ret
     be4: 52800021     	mov	w1, #0x1                ; =1
     be8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     bec: f9400042     	ldr	x2, [x2]
     bf0: aa1603e0     	mov	x0, x22
     bf4: d63f0040     	blr	x2
     bf8: 52800000     	mov	w0, #0x0                ; =0
     bfc: 910143ff     	add	sp, sp, #0x50
     c00: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c04: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c08: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c0c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     c10: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c14: d65f03c0     	ret

0000000000000c18 <___pl_fn_1>:
     c18: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     c1c: 910003fd     	mov	x29, sp
     c20: f81f0ff9     	str	x25, [sp, #-0x10]!
     c24: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     c28: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     c2c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     c30: d10043ff     	sub	sp, sp, #0x10
     c34: b9401001     	ldr	w1, [x0, #0x10]
     c38: 11000421     	add	w1, w1, #0x1
     c3c: b9001001     	str	w1, [x0, #0x10]
     c40: aa0003f5     	mov	x21, x0
     c44: 52800361     	mov	w1, #0x1b               ; =27
     c48: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     c4c: f9400042     	ldr	x2, [x2]
     c50: d63f0040     	blr	x2
     c54: 350024a0     	cbnz	w0, 0x10e8 <___pl_fn_1+0x4d0>
     c58: aa1503e0     	mov	x0, x21
     c5c: f9401802     	ldr	x2, [x0, #0x30]
     c60: aa0203f6     	mov	x22, x2
     c64: 52800381     	mov	w1, #0x1c               ; =28
     c68: 52800002     	mov	w2, #0x0                ; =0
     c6c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c70: f9400084     	ldr	x4, [x4]
     c74: aa1503e0     	mov	x0, x21
     c78: d63f0080     	blr	x4
     c7c: 35002360     	cbnz	w0, 0x10e8 <___pl_fn_1+0x4d0>
     c80: aa1503e0     	mov	x0, x21
     c84: f9401802     	ldr	x2, [x0, #0x30]
     c88: aa0203f7     	mov	x23, x2
     c8c: 528003a1     	mov	w1, #0x1d               ; =29
     c90: 52800002     	mov	w2, #0x0                ; =0
     c94: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     c98: f94000c6     	ldr	x6, [x6]
     c9c: d63f00c0     	blr	x6
     ca0: 35002240     	cbnz	w0, 0x10e8 <___pl_fn_1+0x4d0>
     ca4: aa1503e0     	mov	x0, x21
     ca8: f9401801     	ldr	x1, [x0, #0x30]
     cac: aa0103f8     	mov	x24, x1
     cb0: f9403c08     	ldr	x8, [x0, #0x78]
     cb4: 372016c8     	tbnz	w8, #0x4, 0xf8c <___pl_fn_1+0x374>
     cb8: aa1503e0     	mov	x0, x21
     cbc: f940380a     	ldr	x10, [x0, #0x70]
     cc0: f100015f     	cmp	x10, #0x0
     cc4: 5400164d     	b.le	0xf8c <___pl_fn_1+0x374>
     cc8: aa1503e0     	mov	x0, x21
     ccc: f940340d     	ldr	x13, [x0, #0x68]
     cd0: f10009bf     	cmp	x13, #0x2
     cd4: 540015cb     	b.lt	0xf8c <___pl_fn_1+0x374>
     cd8: aa1503e0     	mov	x0, x21
     cdc: f9402802     	ldr	x2, [x0, #0x50]
     ce0: f9402c00     	ldr	x0, [x0, #0x58]
     ce4: 91001041     	add	x1, x2, #0x4
     ce8: eb00003f     	cmp	x1, x0
     cec: 54001508     	b.hi	0xf8c <___pl_fn_1+0x374>
     cf0: aa1503e0     	mov	x0, x21
     cf4: f9404400     	ldr	x0, [x0, #0x88]
     cf8: aa1503e1     	mov	x1, x21
     cfc: f9404821     	ldr	x1, [x1, #0x90]
     d00: eb01001f     	cmp	x0, x1
     d04: 540000a3     	b.lo	0xd18 <___pl_fn_1+0x100>
     d08: 140000a1     	b	0xf8c <___pl_fn_1+0x374>
     d0c: aa1503e0     	mov	x0, x21
     d10: f9401802     	ldr	x2, [x0, #0x30]
     d14: 14000027     	b	0xdb0 <___pl_fn_1+0x198>
     d18: aa1503e6     	mov	x6, x21
     d1c: f94030c4     	ldr	x4, [x6, #0x60]
     d20: aa1503e8     	mov	x8, x21
     d24: f9400105     	ldr	x5, [x8]
     d28: b20007e6     	mov	x6, #0x300000003        ; =12884901891
     d2c: 2a0203e1     	mov	w1, w2
     d30: 8b010ca3     	add	x3, x5, x1, lsl #3
     d34: f82258a6     	str	x6, [x5, w2, uxtw #3]
     d38: 91000484     	add	x4, x4, #0x1
     d3c: f9000464     	str	x4, [x3, #0x8]
     d40: 92800005     	mov	x5, #-0x1               ; =-1
     d44: f9000865     	str	x5, [x3, #0x10]
     d48: d2800005     	mov	x5, #0x0                ; =0
     d4c: f9000c65     	str	x5, [x3, #0x18]
     d50: aa1503e3     	mov	x3, x21
     d54: f9003064     	str	x4, [x3, #0x60]
     d58: 91001043     	add	x3, x2, #0x4
     d5c: aa1503e4     	mov	x4, x21
     d60: f9002883     	str	x3, [x4, #0x50]
     d64: aa1503e3     	mov	x3, x21
     d68: f9403463     	ldr	x3, [x3, #0x68]
     d6c: d1000863     	sub	x3, x3, #0x2
     d70: f9003483     	str	x3, [x4, #0x68]
     d74: aa1503e3     	mov	x3, x21
     d78: f9403863     	ldr	x3, [x3, #0x70]
     d7c: d1000863     	sub	x3, x3, #0x2
     d80: f9003883     	str	x3, [x4, #0x70]
     d84: aa1503e3     	mov	x3, x21
     d88: f9404063     	ldr	x3, [x3, #0x80]
     d8c: b25e0021     	orr	x1, x1, #0x400000000
     d90: d37cec05     	lsl	x5, x0, #4
     d94: 8b001064     	add	x4, x3, x0, lsl #4
     d98: f8256861     	str	x1, [x3, x5]
     d9c: d2800041     	mov	x1, #0x2                ; =2
     da0: f9000481     	str	x1, [x4, #0x8]
     da4: 91000400     	add	x0, x0, #0x1
     da8: aa1503e1     	mov	x1, x21
     dac: f9004420     	str	x0, [x1, #0x88]
     db0: 34001842     	cbz	w2, 0x10b8 <___pl_fn_1+0x4a0>
     db4: 35000082     	cbnz	w2, 0xdc4 <___pl_fn_1+0x1ac>
     db8: 1400007d     	b	0xfac <___pl_fn_1+0x394>
     dbc: aa1503e0     	mov	x0, x21
     dc0: 14000013     	b	0xe0c <___pl_fn_1+0x1f4>
     dc4: aa1503e0     	mov	x0, x21
     dc8: aa0203f9     	mov	x25, x2
     dcc: f9400001     	ldr	x1, [x0]
     dd0: 2a0203e0     	mov	w0, w2
     dd4: 8b000c20     	add	x0, x1, x0, lsl #3
     dd8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     ddc: d360fc21     	lsr	x1, x1, #32
     de0: 92403c22     	and	x2, x1, #0xffff
     de4: f100085f     	cmp	x2, #0x2
     de8: 54000080     	b.eq	0xdf8 <___pl_fn_1+0x1e0>
     dec: f9400802     	ldr	x2, [x0, #0x10]
     df0: 927ff842     	and	x2, x2, #0xfffffffffffffffe
     df4: f9000802     	str	x2, [x0, #0x10]
     df8: 52848062     	mov	w2, #0x2403             ; =9219
     dfc: 72a00022     	movk	w2, #0x1, lsl #16
     e00: 92403c21     	and	x1, x1, #0xffff
     e04: f8217802     	str	x2, [x0, x1, lsl #3]
     e08: aa1503e0     	mov	x0, x21
     e0c: aa1503e0     	mov	x0, x21
     e10: f9402400     	ldr	x0, [x0, #0x48]
     e14: aa1703e2     	mov	x2, x23
     e18: 2a0203f3     	mov	w19, w2
     e1c: d1000661     	sub	x1, x19, #0x1
     e20: eb00003f     	cmp	x1, x0
     e24: 54000e02     	b.hs	0xfe4 <___pl_fn_1+0x3cc>
     e28: aa1503e0     	mov	x0, x21
     e2c: f9402000     	ldr	x0, [x0, #0x40]
     e30: d2800601     	mov	x1, #0x30               ; =48
     e34: d1000663     	sub	x3, x19, #0x1
     e38: 9b017c62     	mul	x2, x3, x1
     e3c: 9b010061     	madd	x1, x3, x1, x0
     e40: f9400823     	ldr	x3, [x1, #0x10]
     e44: b5000083     	cbnz	x3, 0xe54 <___pl_fn_1+0x23c>
     e48: 14000067     	b	0xfe4 <___pl_fn_1+0x3cc>
     e4c: aa1503e0     	mov	x0, x21
     e50: 14000006     	b	0xe68 <___pl_fn_1+0x250>
     e54: d2800003     	mov	x3, #0x0                ; =0
     e58: f8226803     	str	x3, [x0, x2]
     e5c: d2800020     	mov	x0, #0x1                ; =1
     e60: f9000420     	str	x0, [x1, #0x8]
     e64: aa1503e0     	mov	x0, x21
     e68: aa1503e0     	mov	x0, x21
     e6c: b9401814     	ldr	w20, [x0, #0x18]
     e70: b9401c01     	ldr	w1, [x0, #0x1c]
     e74: 11000680     	add	w0, w20, #0x1
     e78: 6b01001f     	cmp	w0, w1
     e7c: 54001068     	b.hi	0x1088 <___pl_fn_1+0x470>
     e80: aa1503e1     	mov	x1, x21
     e84: f9401021     	ldr	x1, [x1, #0x20]
     e88: aa1903e2     	mov	x2, x25
     e8c: b8345822     	str	w2, [x1, w20, uxtw #2]
     e90: aa1503e1     	mov	x1, x21
     e94: b9001820     	str	w0, [x1, #0x18]
     e98: aa1503e0     	mov	x0, x21
     e9c: b9401003     	ldr	w3, [x0, #0x10]
     ea0: b9401404     	ldr	w4, [x0, #0x14]
     ea4: 6b04007f     	cmp	w3, w4
     ea8: 54000d82     	b.hs	0x1058 <___pl_fn_1+0x440>
     eac: aa1803e1     	mov	x1, x24
     eb0: aa1903e2     	mov	x2, x25
     eb4: aa1503e0     	mov	x0, x21
     eb8: aa1703e3     	mov	x3, x23
     ebc: 94000000     	bl	0xebc <___pl_fn_1+0x2a4>
     ec0: aa1503e1     	mov	x1, x21
     ec4: b9402c25     	ldr	w5, [x1, #0x2c]
     ec8: 35001105     	cbnz	w5, 0x10e8 <___pl_fn_1+0x4d0>
     ecc: aa1503e5     	mov	x5, x21
     ed0: b90018b4     	str	w20, [x5, #0x18]
     ed4: 34000aa0     	cbz	w0, 0x1028 <___pl_fn_1+0x410>
     ed8: aa1503e0     	mov	x0, x21
     edc: f9402409     	ldr	x9, [x0, #0x48]
     ee0: d100066a     	sub	x10, x19, #0x1
     ee4: eb09015f     	cmp	x10, x9
     ee8: 54000902     	b.hs	0x1008 <___pl_fn_1+0x3f0>
     eec: aa1503e0     	mov	x0, x21
     ef0: f940200c     	ldr	x12, [x0, #0x40]
     ef4: d280060e     	mov	x14, #0x30              ; =48
     ef8: d100066f     	sub	x15, x19, #0x1
     efc: 9b0e7ded     	mul	x13, x15, x14
     f00: 9b0e31ee     	madd	x14, x15, x14, x12
     f04: f94005ce     	ldr	x14, [x14, #0x8]
     f08: b50000ae     	cbnz	x14, 0xf1c <___pl_fn_1+0x304>
     f0c: 1400003f     	b	0x1008 <___pl_fn_1+0x3f0>
     f10: aa1503e0     	mov	x0, x21
     f14: f9401802     	ldr	x2, [x0, #0x30]
     f18: 14000002     	b	0xf20 <___pl_fn_1+0x308>
     f1c: f86d6982     	ldr	x2, [x12, x13]
     f20: 528004c1     	mov	w1, #0x26               ; =38
     f24: 52802003     	mov	w3, #0x100              ; =256
     f28: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     f2c: f9400084     	ldr	x4, [x4]
     f30: aa1503e0     	mov	x0, x21
     f34: d63f0080     	blr	x4
     f38: 35000d80     	cbnz	w0, 0x10e8 <___pl_fn_1+0x4d0>
     f3c: 528004e1     	mov	w1, #0x27               ; =39
     f40: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     f44: f9400063     	ldr	x3, [x3]
     f48: aa1603e2     	mov	x2, x22
     f4c: aa1503e0     	mov	x0, x21
     f50: d63f0060     	blr	x3
     f54: 35000ca0     	cbnz	w0, 0x10e8 <___pl_fn_1+0x4d0>
     f58: aa1503e0     	mov	x0, x21
     f5c: b9401000     	ldr	w0, [x0, #0x10]
     f60: 51000400     	sub	w0, w0, #0x1
     f64: aa1503e1     	mov	x1, x21
     f68: b9001020     	str	w0, [x1, #0x10]
     f6c: 910043ff     	add	sp, sp, #0x10
     f70: a8c153f3     	ldp	x19, x20, [sp], #0x10
     f74: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     f78: a8c163f7     	ldp	x23, x24, [sp], #0x10
     f7c: f84107f9     	ldr	x25, [sp], #0x10
     f80: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     f84: d65f03c0     	ret
     f88: 14000058     	b	0x10e8 <___pl_fn_1+0x4d0>
     f8c: 528003c1     	mov	w1, #0x1e               ; =30
     f90: 52800002     	mov	w2, #0x0                ; =0
     f94: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     f98: f9400063     	ldr	x3, [x3]
     f9c: aa1503e0     	mov	x0, x21
     fa0: d63f0060     	blr	x3
     fa4: 34ffeb40     	cbz	w0, 0xd0c <___pl_fn_1+0xf4>
     fa8: 14000050     	b	0x10e8 <___pl_fn_1+0x4d0>
     fac: aa0203f9     	mov	x25, x2
     fb0: d2800000     	mov	x0, #0x0                ; =0
     fb4: 910003e3     	mov	x3, sp
     fb8: f80003e0     	stur	x0, [sp]
     fbc: 52848060     	mov	w0, #0x2403             ; =9219
     fc0: 72a00020     	movk	w0, #0x1, lsl #16
     fc4: f80083e0     	stur	x0, [sp, #0x8]
     fc8: 52800401     	mov	w1, #0x20               ; =32
     fcc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     fd0: f9400084     	ldr	x4, [x4]
     fd4: aa1503e0     	mov	x0, x21
     fd8: d63f0080     	blr	x4
     fdc: 34ffef00     	cbz	w0, 0xdbc <___pl_fn_1+0x1a4>
     fe0: 14000042     	b	0x10e8 <___pl_fn_1+0x4d0>
     fe4: 52800421     	mov	w1, #0x21               ; =33
     fe8: d2800003     	mov	x3, #0x0                ; =0
     fec: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     ff0: f9400084     	ldr	x4, [x4]
     ff4: aa1503e0     	mov	x0, x21
     ff8: aa1703e2     	mov	x2, x23
     ffc: d63f0080     	blr	x4
    1000: 34fff260     	cbz	w0, 0xe4c <___pl_fn_1+0x234>
    1004: 14000039     	b	0x10e8 <___pl_fn_1+0x4d0>
    1008: 528004a1     	mov	w1, #0x25               ; =37
    100c: 9000000e     	adrp	x14, 0x1000 <___pl_fn_1+0x3e8>
    1010: f94001ce     	ldr	x14, [x14]
    1014: aa1703e2     	mov	x2, x23
    1018: aa1503e0     	mov	x0, x21
    101c: d63f01c0     	blr	x14
    1020: 34fff780     	cbz	w0, 0xf10 <___pl_fn_1+0x2f8>
    1024: 14000031     	b	0x10e8 <___pl_fn_1+0x4d0>
    1028: 52800481     	mov	w1, #0x24               ; =36
    102c: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0x3e8>
    1030: f9400042     	ldr	x2, [x2]
    1034: aa1503e0     	mov	x0, x21
    1038: d63f0040     	blr	x2
    103c: 910043ff     	add	sp, sp, #0x10
    1040: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1044: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1048: a8c163f7     	ldp	x23, x24, [sp], #0x10
    104c: f84107f9     	ldr	x25, [sp], #0x10
    1050: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1054: d65f03c0     	ret
    1058: 52800461     	mov	w1, #0x23               ; =35
    105c: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0x3e8>
    1060: f9400042     	ldr	x2, [x2]
    1064: aa1503e0     	mov	x0, x21
    1068: d63f0040     	blr	x2
    106c: 910043ff     	add	sp, sp, #0x10
    1070: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1074: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1078: a8c163f7     	ldp	x23, x24, [sp], #0x10
    107c: f84107f9     	ldr	x25, [sp], #0x10
    1080: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1084: d65f03c0     	ret
    1088: 52800441     	mov	w1, #0x22               ; =34
    108c: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0x3e8>
    1090: f9400042     	ldr	x2, [x2]
    1094: aa1503e0     	mov	x0, x21
    1098: d63f0040     	blr	x2
    109c: 910043ff     	add	sp, sp, #0x10
    10a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    10a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    10a8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    10ac: f84107f9     	ldr	x25, [sp], #0x10
    10b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    10b4: d65f03c0     	ret
    10b8: 528003e1     	mov	w1, #0x1f               ; =31
    10bc: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0x3e8>
    10c0: f9400042     	ldr	x2, [x2]
    10c4: aa1503e0     	mov	x0, x21
    10c8: d63f0040     	blr	x2
    10cc: 910043ff     	add	sp, sp, #0x10
    10d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    10d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    10d8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    10dc: f84107f9     	ldr	x25, [sp], #0x10
    10e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    10e4: d65f03c0     	ret
    10e8: 910043ff     	add	sp, sp, #0x10
    10ec: a8c153f3     	ldp	x19, x20, [sp], #0x10
    10f0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    10f4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    10f8: f84107f9     	ldr	x25, [sp], #0x10
    10fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1100: d65f03c0     	ret

0000000000001104 <___pl_fn_2>:
    1104: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    1108: 910003fd     	mov	x29, sp
    110c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    1110: d10043ff     	sub	sp, sp, #0x10
    1114: aa0103f3     	mov	x19, x1
    1118: b940100a     	ldr	w10, [x0, #0x10]
    111c: 1100054a     	add	w10, w10, #0x1
    1120: b900100a     	str	w10, [x0, #0x10]
    1124: aa1303e1     	mov	x1, x19
    1128: 34000961     	cbz	w1, 0x1254 <___pl_fn_2+0x150>
    112c: f940000f     	ldr	x15, [x0]
    1130: aa1303e1     	mov	x1, x19
    1134: aa0003f4     	mov	x20, x0
    1138: 2a0103ee     	mov	w14, w1
    113c: 8b0e0dee     	add	x14, x15, x14, lsl #3
    1140: f86159ef     	ldr	x15, [x15, w1, uxtw #3]
    1144: d360fdef     	lsr	x15, x15, #32
    1148: 92403de0     	and	x0, x15, #0xffff
    114c: f86079cf     	ldr	x15, [x14, x0, lsl #3]
    1150: f100081f     	cmp	x0, #0x2
    1154: 540000c0     	b.eq	0x116c <___pl_fn_2+0x68>
    1158: f94009c0     	ldr	x0, [x14, #0x10]
    115c: 370007e0     	tbnz	w0, #0x0, 0x1258 <___pl_fn_2+0x154>
    1160: 14000003     	b	0x116c <___pl_fn_2+0x68>
    1164: aa1403e0     	mov	x0, x20
    1168: f940180f     	ldr	x15, [x0, #0x30]
    116c: d280a3a1     	mov	x1, #0x51d              ; =1309
    1170: 9b017de0     	mul	x0, x15, x1
    1174: 9b417de1     	smulh	x1, x15, x1
    1178: eb80fc3f     	cmp	x1, x0, asr #63
    117c: 54000d01     	b.ne	0x131c <___pl_fn_2+0x218>
    1180: d286c321     	mov	x1, #0x3619             ; =13849
    1184: ab010000     	adds	x0, x0, x1
    1188: 9a9f77e1     	cset	x1, vs
    118c: 72001c3f     	tst	w1, #0xff
    1190: 54000b21     	b.ne	0x12f4 <___pl_fn_2+0x1f0>
    1194: 34000753     	cbz	w19, 0x127c <___pl_fn_2+0x178>
    1198: aa1403eb     	mov	x11, x20
    119c: f9400162     	ldr	x2, [x11]
    11a0: 2a1303e1     	mov	w1, w19
    11a4: 8b010c41     	add	x1, x2, x1, lsl #3
    11a8: f8735842     	ldr	x2, [x2, w19, uxtw #3]
    11ac: d360fc42     	lsr	x2, x2, #32
    11b0: 92403c43     	and	x3, x2, #0xffff
    11b4: f100087f     	cmp	x3, #0x2
    11b8: 54000080     	b.eq	0x11c8 <___pl_fn_2+0xc4>
    11bc: f9400823     	ldr	x3, [x1, #0x10]
    11c0: 927ff863     	and	x3, x3, #0xfffffffffffffffe
    11c4: f9000823     	str	x3, [x1, #0x10]
    11c8: 934ffc03     	asr	x3, x0, #15
    11cc: d370fc63     	lsr	x3, x3, #48
    11d0: 8b030003     	add	x3, x0, x3
    11d4: 9270bc63     	and	x3, x3, #0xffffffffffff0000
    11d8: cb030000     	sub	x0, x0, x3
    11dc: 92403c42     	and	x2, x2, #0xffff
    11e0: f8227820     	str	x0, [x1, x2, lsl #3]
    11e4: 340006f3     	cbz	w19, 0x12c0 <___pl_fn_2+0x1bc>
    11e8: aa1403e0     	mov	x0, x20
    11ec: f9400000     	ldr	x0, [x0]
    11f0: 2a1303e1     	mov	w1, w19
    11f4: 8b010c01     	add	x1, x0, x1, lsl #3
    11f8: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    11fc: d360fc00     	lsr	x0, x0, #32
    1200: 92403c02     	and	x2, x0, #0xffff
    1204: f8627820     	ldr	x0, [x1, x2, lsl #3]
    1208: f100085f     	cmp	x2, #0x2
    120c: 54000100     	b.eq	0x122c <___pl_fn_2+0x128>
    1210: f9400821     	ldr	x1, [x1, #0x10]
    1214: 37000561     	tbnz	w1, #0x0, 0x12c0 <___pl_fn_2+0x1bc>
    1218: 14000005     	b	0x122c <___pl_fn_2+0x128>
    121c: aa1403e0     	mov	x0, x20
    1220: f9401800     	ldr	x0, [x0, #0x30]
    1224: aa1403e1     	mov	x1, x20
    1228: 14000002     	b	0x1230 <___pl_fn_2+0x12c>
    122c: aa1403e1     	mov	x1, x20
    1230: aa1403e1     	mov	x1, x20
    1234: b9401021     	ldr	w1, [x1, #0x10]
    1238: 51000421     	sub	w1, w1, #0x1
    123c: aa1403e2     	mov	x2, x20
    1240: b9001041     	str	w1, [x2, #0x10]
    1244: 910043ff     	add	sp, sp, #0x10
    1248: a8c153f3     	ldp	x19, x20, [sp], #0x10
    124c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1250: d65f03c0     	ret
    1254: aa0003f4     	mov	x20, x0
    1258: 52800501     	mov	w1, #0x28               ; =40
    125c: 52800003     	mov	w3, #0x0                ; =0
    1260: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0x3e8>
    1264: f9400084     	ldr	x4, [x4]
    1268: aa1403e0     	mov	x0, x20
    126c: aa1303e2     	mov	x2, x19
    1270: d63f0080     	blr	x4
    1274: 34fff780     	cbz	w0, 0x1164 <___pl_fn_2+0x60>
    1278: 1400001a     	b	0x12e0 <___pl_fn_2+0x1dc>
    127c: d2800001     	mov	x1, #0x0                ; =0
    1280: 910003e3     	mov	x3, sp
    1284: f80003e1     	stur	x1, [sp]
    1288: 934ffc01     	asr	x1, x0, #15
    128c: d370fc21     	lsr	x1, x1, #48
    1290: 8b010001     	add	x1, x0, x1
    1294: 9270bc21     	and	x1, x1, #0xffffffffffff0000
    1298: cb010000     	sub	x0, x0, x1
    129c: f80083e0     	stur	x0, [sp, #0x8]
    12a0: 52800581     	mov	w1, #0x2c               ; =44
    12a4: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0x3e8>
    12a8: f9400084     	ldr	x4, [x4]
    12ac: aa1403e0     	mov	x0, x20
    12b0: aa1303e2     	mov	x2, x19
    12b4: d63f0080     	blr	x4
    12b8: 34fff960     	cbz	w0, 0x11e4 <___pl_fn_2+0xe0>
    12bc: 14000009     	b	0x12e0 <___pl_fn_2+0x1dc>
    12c0: 528005a1     	mov	w1, #0x2d               ; =45
    12c4: 52800003     	mov	w3, #0x0                ; =0
    12c8: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0x3e8>
    12cc: f9400084     	ldr	x4, [x4]
    12d0: aa1303e2     	mov	x2, x19
    12d4: aa1403e0     	mov	x0, x20
    12d8: d63f0080     	blr	x4
    12dc: 34fffa00     	cbz	w0, 0x121c <___pl_fn_2+0x118>
    12e0: d2800000     	mov	x0, #0x0                ; =0
    12e4: 910043ff     	add	sp, sp, #0x10
    12e8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    12ec: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    12f0: d65f03c0     	ret
    12f4: 52800541     	mov	w1, #0x2a               ; =42
    12f8: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0x3e8>
    12fc: f9400042     	ldr	x2, [x2]
    1300: aa1403e0     	mov	x0, x20
    1304: d63f0040     	blr	x2
    1308: d2800000     	mov	x0, #0x0                ; =0
    130c: 910043ff     	add	sp, sp, #0x10
    1310: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1314: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1318: d65f03c0     	ret
    131c: 52800521     	mov	w1, #0x29               ; =41
    1320: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0x3e8>
    1324: f9400042     	ldr	x2, [x2]
    1328: aa1403e0     	mov	x0, x20
    132c: d63f0040     	blr	x2
    1330: d2800000     	mov	x0, #0x0                ; =0
    1334: 910043ff     	add	sp, sp, #0x10
    1338: a8c153f3     	ldp	x19, x20, [sp], #0x10
    133c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1340: d65f03c0     	ret
