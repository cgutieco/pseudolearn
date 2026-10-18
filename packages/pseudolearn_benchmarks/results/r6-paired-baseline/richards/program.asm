
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_76447/richards/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: b9401004     	ldr	w4, [x0, #0x10]
       c: 11000483     	add	w3, w4, #0x1
      10: b9001003     	str	w3, [x0, #0x10]
      14: aa0003e9     	mov	x9, x0
      18: d2800000     	mov	x0, #0x0                ; =0
      1c: d280002c     	mov	x12, #0x1               ; =1
      20: 5280002e     	mov	w14, #0x1               ; =1
      24: aa0e03e3     	mov	x3, x14
      28: aa0e03e8     	mov	x8, x14
      2c: aa0e03ea     	mov	x10, x14
      30: f100003f     	cmp	x1, #0x0
      34: 5400008c     	b.gt	0x44 <___pl_fn_0+0x44>
      38: f100005f     	cmp	x2, #0x0
      3c: 9a9fd7e5     	cset	x5, gt
      40: 14000002     	b	0x48 <___pl_fn_0+0x48>
      44: 52800025     	mov	w5, #0x1                ; =1
      48: 72001cbf     	tst	w5, #0xff
      4c: 540000a1     	b.ne	0x60 <___pl_fn_0+0x60>
      50: aa0903e1     	mov	x1, x9
      54: b9001024     	str	w4, [x1, #0x10]
      58: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      5c: d65f03c0     	ret
      60: d37ffc45     	lsr	x5, x2, #63
      64: 8b050045     	add	x5, x2, x5
      68: 927ff8a6     	and	x6, x5, #0xfffffffffffffffe
      6c: 8b060026     	add	x6, x1, x6
      70: d37ffc27     	lsr	x7, x1, #63
      74: 8b070021     	add	x1, x1, x7
      78: 927ff827     	and	x7, x1, #0xfffffffffffffffe
      7c: 8b070042     	add	x2, x2, x7
      80: eb0200df     	cmp	x6, x2
      84: 540000c0     	b.eq	0x9c <___pl_fn_0+0x9c>
      88: ab0c0000     	adds	x0, x0, x12
      8c: 9a9f77e2     	cset	x2, vs
      90: 72001c5f     	tst	w2, #0xff
      94: 540002c1     	b.ne	0xec <___pl_fn_0+0xec>
      98: 52800023     	mov	w3, #0x1                ; =1
      9c: d2800048     	mov	x8, #0x2                ; =2
      a0: 9b087d87     	mul	x7, x12, x8
      a4: 9b487d88     	smulh	x8, x12, x8
      a8: eb87fd1f     	cmp	x8, x7, asr #63
      ac: 54000101     	b.ne	0xcc <___pl_fn_0+0xcc>
      b0: 9341fc21     	asr	x1, x1, #1
      b4: 9341fca2     	asr	x2, x5, #1
      b8: 5280002e     	mov	w14, #0x1               ; =1
      bc: aa0e03e8     	mov	x8, x14
      c0: aa0e03ea     	mov	x10, x14
      c4: aa0703ec     	mov	x12, x7
      c8: 17ffffda     	b	0x30 <___pl_fn_0+0x30>
      cc: 528000e1     	mov	w1, #0x7                ; =7
      d0: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
      d4: f940014a     	ldr	x10, [x10]
      d8: aa0903e0     	mov	x0, x9
      dc: d63f0140     	blr	x10
      e0: d2800000     	mov	x0, #0x0                ; =0
      e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      e8: d65f03c0     	ret
      ec: aa0903e0     	mov	x0, x9
      f0: 52800041     	mov	w1, #0x2                ; =2
      f4: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
      f8: f940016b     	ldr	x11, [x11]
      fc: d63f0160     	blr	x11
     100: d2800000     	mov	x0, #0x0                ; =0
     104: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     108: d65f03c0     	ret

000000000000010c <___pl_fn_1>:
     10c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     110: 910003fd     	mov	x29, sp
     114: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
     118: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
     11c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     120: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     124: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     128: d10443ff     	sub	sp, sp, #0x110
     12c: b9401001     	ldr	w1, [x0, #0x10]
     130: 11000421     	add	w1, w1, #0x1
     134: b9001001     	str	w1, [x0, #0x10]
     138: aa0003fa     	mov	x26, x0
     13c: 52800101     	mov	w1, #0x8                ; =8
     140: 52800002     	mov	w2, #0x0                ; =0
     144: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     148: f9400063     	ldr	x3, [x3]
     14c: aa1a03e0     	mov	x0, x26
     150: d63f0060     	blr	x3
     154: 350140a0     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     158: aa1a03e0     	mov	x0, x26
     15c: f9401813     	ldr	x19, [x0, #0x30]
     160: 52800121     	mov	w1, #0x9                ; =9
     164: 52800022     	mov	w2, #0x1                ; =1
     168: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     16c: f9400063     	ldr	x3, [x3]
     170: d63f0060     	blr	x3
     174: 35013fa0     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     178: aa1a03e0     	mov	x0, x26
     17c: f9401802     	ldr	x2, [x0, #0x30]
     180: 34013da2     	cbz	w2, 0x2934 <___pl_fn_1+0x2828>
     184: aa1a03e0     	mov	x0, x26
     188: b9401814     	ldr	w20, [x0, #0x18]
     18c: b9401c06     	ldr	w6, [x0, #0x1c]
     190: 11000685     	add	w5, w20, #0x1
     194: 6b0600bf     	cmp	w5, w6
     198: 54013b48     	b.hi	0x2900 <___pl_fn_1+0x27f4>
     19c: aa1a03e0     	mov	x0, x26
     1a0: f9401007     	ldr	x7, [x0, #0x20]
     1a4: b83458e2     	str	w2, [x7, w20, uxtw #2]
     1a8: f90087e2     	str	x2, [sp, #0x108]
     1ac: b9001805     	str	w5, [x0, #0x18]
     1b0: 52800181     	mov	w1, #0xc                ; =12
     1b4: 52800002     	mov	w2, #0x0                ; =0
     1b8: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     1bc: f9400129     	ldr	x9, [x9]
     1c0: d63f0120     	blr	x9
     1c4: 35013d20     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     1c8: aa1a03e0     	mov	x0, x26
     1cc: f9401815     	ldr	x21, [x0, #0x30]
     1d0: b9001814     	str	w20, [x0, #0x18]
     1d4: 340137d5     	cbz	w21, 0x28cc <___pl_fn_1+0x27c0>
     1d8: 350000b5     	cbnz	w21, 0x1ec <___pl_fn_1+0xe0>
     1dc: 14000570     	b	0x179c <___pl_fn_1+0x1690>
     1e0: aa1a03e0     	mov	x0, x26
     1e4: f94083e5     	ldr	x5, [sp, #0x100]
     1e8: 1400000c     	b	0x218 <___pl_fn_1+0x10c>
     1ec: aa1a03e0     	mov	x0, x26
     1f0: f90083f5     	str	x21, [sp, #0x100]
     1f4: f9400002     	ldr	x2, [x0]
     1f8: f94083e5     	ldr	x5, [sp, #0x100]
     1fc: 2a0503e0     	mov	w0, w5
     200: 8b000c41     	add	x1, x2, x0, lsl #3
     204: f8655842     	ldr	x2, [x2, w5, uxtw #3]
     208: d360fc42     	lsr	x2, x2, #32
     20c: 92403c42     	and	x2, x2, #0xffff
     210: f8227820     	str	x0, [x1, x2, lsl #3]
     214: aa1a03e0     	mov	x0, x26
     218: aa1a03e0     	mov	x0, x26
     21c: b9401815     	ldr	w21, [x0, #0x18]
     220: b9401c00     	ldr	w0, [x0, #0x1c]
     224: 11000aa1     	add	w1, w21, #0x2
     228: 6b00003f     	cmp	w1, w0
     22c: 54013368     	b.hi	0x2898 <___pl_fn_1+0x278c>
     230: aa1a03e0     	mov	x0, x26
     234: f9401000     	ldr	x0, [x0, #0x20]
     238: 2a1503e1     	mov	w1, w21
     23c: 8b010801     	add	x1, x0, x1, lsl #2
     240: f94087e2     	ldr	x2, [sp, #0x108]
     244: b8355802     	str	w2, [x0, w21, uxtw #2]
     248: b9000425     	str	w5, [x1, #0x4]
     24c: f90083e5     	str	x5, [sp, #0x100]
     250: 11000aa0     	add	w0, w21, #0x2
     254: aa1a03e1     	mov	x1, x26
     258: b9001820     	str	w0, [x1, #0x18]
     25c: 52800201     	mov	w1, #0x10               ; =16
     260: 52800042     	mov	w2, #0x2                ; =2
     264: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     268: f9400063     	ldr	x3, [x3]
     26c: aa1a03e0     	mov	x0, x26
     270: d63f0060     	blr	x3
     274: 350137a0     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     278: aa1a03e0     	mov	x0, x26
     27c: f940181c     	ldr	x28, [x0, #0x30]
     280: b9001815     	str	w21, [x0, #0x18]
     284: 34012f1c     	cbz	w28, 0x2864 <___pl_fn_1+0x2758>
     288: f94087e2     	ldr	x2, [sp, #0x108]
     28c: 35000082     	cbnz	w2, 0x29c <___pl_fn_1+0x190>
     290: 14000551     	b	0x17d4 <___pl_fn_1+0x16c8>
     294: f94087e2     	ldr	x2, [sp, #0x108]
     298: 1400000e     	b	0x2d0 <___pl_fn_1+0x1c4>
     29c: aa1a03e0     	mov	x0, x26
     2a0: f9400001     	ldr	x1, [x0]
     2a4: f94087e2     	ldr	x2, [sp, #0x108]
     2a8: 2a0203e0     	mov	w0, w2
     2ac: 8b000c20     	add	x0, x1, x0, lsl #3
     2b0: f8625822     	ldr	x2, [x1, w2, uxtw #3]
     2b4: f94083e5     	ldr	x5, [sp, #0x100]
     2b8: 2a0503e1     	mov	w1, w5
     2bc: d360fc42     	lsr	x2, x2, #32
     2c0: 92403c42     	and	x2, x2, #0xffff
     2c4: 91000842     	add	x2, x2, #0x2
     2c8: f8227801     	str	x1, [x0, x2, lsl #3]
     2cc: f94087e2     	ldr	x2, [sp, #0x108]
     2d0: f94087e2     	ldr	x2, [sp, #0x108]
     2d4: 35000082     	cbnz	w2, 0x2e4 <___pl_fn_1+0x1d8>
     2d8: 1400054d     	b	0x180c <___pl_fn_1+0x1700>
     2dc: f94087e2     	ldr	x2, [sp, #0x108]
     2e0: 1400000d     	b	0x314 <___pl_fn_1+0x208>
     2e4: aa1a03e0     	mov	x0, x26
     2e8: f9400001     	ldr	x1, [x0]
     2ec: f94087e2     	ldr	x2, [sp, #0x108]
     2f0: 2a0203e0     	mov	w0, w2
     2f4: 8b000c20     	add	x0, x1, x0, lsl #3
     2f8: f8625822     	ldr	x2, [x1, w2, uxtw #3]
     2fc: 2a1c03e1     	mov	w1, w28
     300: d360fc42     	lsr	x2, x2, #32
     304: 92403c42     	and	x2, x2, #0xffff
     308: 91000442     	add	x2, x2, #0x1
     30c: f8227801     	str	x1, [x0, x2, lsl #3]
     310: f94087e2     	ldr	x2, [sp, #0x108]
     314: f94087e2     	ldr	x2, [sp, #0x108]
     318: 35000082     	cbnz	w2, 0x328 <___pl_fn_1+0x21c>
     31c: 14000549     	b	0x1840 <___pl_fn_1+0x1734>
     320: f94087e2     	ldr	x2, [sp, #0x108]
     324: 1400000c     	b	0x354 <___pl_fn_1+0x248>
     328: aa1a03e0     	mov	x0, x26
     32c: f9400001     	ldr	x1, [x0]
     330: f94087e2     	ldr	x2, [sp, #0x108]
     334: 2a0203e0     	mov	w0, w2
     338: 8b000c20     	add	x0, x1, x0, lsl #3
     33c: f8625822     	ldr	x2, [x1, w2, uxtw #3]
     340: 2a1c03e1     	mov	w1, w28
     344: d360fc42     	lsr	x2, x2, #32
     348: 92403c42     	and	x2, x2, #0xffff
     34c: f8227801     	str	x1, [x0, x2, lsl #3]
     350: f94087e2     	ldr	x2, [sp, #0x108]
     354: f94087e2     	ldr	x2, [sp, #0x108]
     358: 35000082     	cbnz	w2, 0x368 <___pl_fn_1+0x25c>
     35c: 14000546     	b	0x1874 <___pl_fn_1+0x1768>
     360: f94087e2     	ldr	x2, [sp, #0x108]
     364: 14000013     	b	0x3b0 <___pl_fn_1+0x2a4>
     368: aa1a03e0     	mov	x0, x26
     36c: f9400001     	ldr	x1, [x0]
     370: f94087e2     	ldr	x2, [sp, #0x108]
     374: 2a0203e0     	mov	w0, w2
     378: 8b000c20     	add	x0, x1, x0, lsl #3
     37c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     380: d360fc21     	lsr	x1, x1, #32
     384: 92403c22     	and	x2, x1, #0xffff
     388: f100085f     	cmp	x2, #0x2
     38c: 54000080     	b.eq	0x39c <___pl_fn_1+0x290>
     390: f9400802     	ldr	x2, [x0, #0x10]
     394: 9276f842     	and	x2, x2, #0xfffffffffffffdff
     398: f9000802     	str	x2, [x0, #0x10]
     39c: d2800002     	mov	x2, #0x0                ; =0
     3a0: 92403c23     	and	x3, x1, #0xffff
     3a4: 91002463     	add	x3, x3, #0x9
     3a8: f8237802     	str	x2, [x0, x3, lsl #3]
     3ac: f94087e2     	ldr	x2, [sp, #0x108]
     3b0: f94087e2     	ldr	x2, [sp, #0x108]
     3b4: 35000082     	cbnz	w2, 0x3c4 <___pl_fn_1+0x2b8>
     3b8: 1400053c     	b	0x18a8 <___pl_fn_1+0x179c>
     3bc: aa1a03e0     	mov	x0, x26
     3c0: 14000013     	b	0x40c <___pl_fn_1+0x300>
     3c4: aa1a03e0     	mov	x0, x26
     3c8: f940000b     	ldr	x11, [x0]
     3cc: f94087e2     	ldr	x2, [sp, #0x108]
     3d0: 2a0203ea     	mov	w10, w2
     3d4: 8b0a0d6a     	add	x10, x11, x10, lsl #3
     3d8: f862596b     	ldr	x11, [x11, w2, uxtw #3]
     3dc: d360fd6b     	lsr	x11, x11, #32
     3e0: 92403d6c     	and	x12, x11, #0xffff
     3e4: f100099f     	cmp	x12, #0x2
     3e8: 54000080     	b.eq	0x3f8 <___pl_fn_1+0x2ec>
     3ec: f940094d     	ldr	x13, [x10, #0x10]
     3f0: 9275f9ad     	and	x13, x13, #0xfffffffffffffbff
     3f4: f900094d     	str	x13, [x10, #0x10]
     3f8: d280000f     	mov	x15, #0x0               ; =0
     3fc: 92403d60     	and	x0, x11, #0xffff
     400: 91002800     	add	x0, x0, #0xa
     404: f820794f     	str	x15, [x10, x0, lsl #3]
     408: aa1a03e0     	mov	x0, x26
     40c: aa1a03e0     	mov	x0, x26
     410: b9401814     	ldr	w20, [x0, #0x18]
     414: b9401c00     	ldr	w0, [x0, #0x1c]
     418: 11000e81     	add	w1, w20, #0x3
     41c: 6b00003f     	cmp	w1, w0
     420: 54012088     	b.hi	0x2830 <___pl_fn_1+0x2724>
     424: aa1a03e0     	mov	x0, x26
     428: f9401000     	ldr	x0, [x0, #0x20]
     42c: 2a1403e1     	mov	w1, w20
     430: 8b010801     	add	x1, x0, x1, lsl #2
     434: f94087e2     	ldr	x2, [sp, #0x108]
     438: b8345802     	str	w2, [x0, w20, uxtw #2]
     43c: f94083e5     	ldr	x5, [sp, #0x100]
     440: b9000425     	str	w5, [x1, #0x4]
     444: b900083c     	str	w28, [x1, #0x8]
     448: 11000e80     	add	w0, w20, #0x3
     44c: aa1a03e1     	mov	x1, x26
     450: b9001820     	str	w0, [x1, #0x18]
     454: 52800301     	mov	w1, #0x18               ; =24
     458: 528000a2     	mov	w2, #0x5                ; =5
     45c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     460: f9400063     	ldr	x3, [x3]
     464: aa1a03e0     	mov	x0, x26
     468: d63f0060     	blr	x3
     46c: 350127e0     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     470: aa1a03e0     	mov	x0, x26
     474: f9401819     	ldr	x25, [x0, #0x30]
     478: b9001814     	str	w20, [x0, #0x18]
     47c: 34011c19     	cbz	w25, 0x27fc <___pl_fn_1+0x26f0>
     480: 35000099     	cbnz	w25, 0x490 <___pl_fn_1+0x384>
     484: 14000516     	b	0x18dc <___pl_fn_1+0x17d0>
     488: aa1903f4     	mov	x20, x25
     48c: 14000012     	b	0x4d4 <___pl_fn_1+0x3c8>
     490: aa1a03e0     	mov	x0, x26
     494: f9400001     	ldr	x1, [x0]
     498: aa1903f4     	mov	x20, x25
     49c: 2a1403e0     	mov	w0, w20
     4a0: 8b000c20     	add	x0, x1, x0, lsl #3
     4a4: f8745821     	ldr	x1, [x1, w20, uxtw #3]
     4a8: d360fc21     	lsr	x1, x1, #32
     4ac: 92403c22     	and	x2, x1, #0xffff
     4b0: f100085f     	cmp	x2, #0x2
     4b4: 54000080     	b.eq	0x4c4 <___pl_fn_1+0x3b8>
     4b8: f9400802     	ldr	x2, [x0, #0x10]
     4bc: 9277f842     	and	x2, x2, #0xfffffffffffffeff
     4c0: f9000802     	str	x2, [x0, #0x10]
     4c4: d2800022     	mov	x2, #0x1                ; =1
     4c8: 92403c21     	and	x1, x1, #0xffff
     4cc: 91002021     	add	x1, x1, #0x8
     4d0: f8217802     	str	x2, [x0, x1, lsl #3]
     4d4: 350000b4     	cbnz	w20, 0x4e8 <___pl_fn_1+0x3dc>
     4d8: 1400050e     	b	0x1910 <___pl_fn_1+0x1804>
     4dc: aa1a03e0     	mov	x0, x26
     4e0: aa1903e1     	mov	x1, x25
     4e4: 14000013     	b	0x530 <___pl_fn_1+0x424>
     4e8: aa1a03e0     	mov	x0, x26
     4ec: aa1403f9     	mov	x25, x20
     4f0: f9400002     	ldr	x2, [x0]
     4f4: aa1903e1     	mov	x1, x25
     4f8: 2a0103e0     	mov	w0, w1
     4fc: 8b000c40     	add	x0, x2, x0, lsl #3
     500: f8615842     	ldr	x2, [x2, w1, uxtw #3]
     504: d360fc42     	lsr	x2, x2, #32
     508: 92403c43     	and	x3, x2, #0xffff
     50c: f100087f     	cmp	x3, #0x2
     510: 54000080     	b.eq	0x520 <___pl_fn_1+0x414>
     514: f9400803     	ldr	x3, [x0, #0x10]
     518: 9276f863     	and	x3, x3, #0xfffffffffffffdff
     51c: f9000803     	str	x3, [x0, #0x10]
     520: 92403c42     	and	x2, x2, #0xffff
     524: 91002442     	add	x2, x2, #0x9
     528: f8227813     	str	x19, [x0, x2, lsl #3]
     52c: aa1a03e0     	mov	x0, x26
     530: aa1a03e0     	mov	x0, x26
     534: b9401813     	ldr	w19, [x0, #0x18]
     538: b9401c00     	ldr	w0, [x0, #0x1c]
     53c: 11001262     	add	w2, w19, #0x4
     540: 6b00005f     	cmp	w2, w0
     544: 54011428     	b.hi	0x27c8 <___pl_fn_1+0x26bc>
     548: aa1a03e0     	mov	x0, x26
     54c: f9401002     	ldr	x2, [x0, #0x20]
     550: 2a1303f4     	mov	w20, w19
     554: 8b140840     	add	x0, x2, x20, lsl #2
     558: f94087e3     	ldr	x3, [sp, #0x108]
     55c: b8335843     	str	w3, [x2, w19, uxtw #2]
     560: f94083e5     	ldr	x5, [sp, #0x100]
     564: b9000405     	str	w5, [x0, #0x4]
     568: b900081c     	str	w28, [x0, #0x8]
     56c: b9000c01     	str	w1, [x0, #0xc]
     570: 11001260     	add	w0, w19, #0x4
     574: aa1a03ed     	mov	x13, x26
     578: b90019a0     	str	w0, [x13, #0x18]
     57c: aa1a03e0     	mov	x0, x26
     580: b9401000     	ldr	w0, [x0, #0x10]
     584: aa1a03e2     	mov	x2, x26
     588: b9401442     	ldr	w2, [x2, #0x14]
     58c: 6b02001f     	cmp	w0, w2
     590: 54011022     	b.hs	0x2794 <___pl_fn_1+0x2688>
     594: d2800024     	mov	x4, #0x1                ; =1
     598: 52800007     	mov	w7, #0x0                ; =0
     59c: aa1a03e0     	mov	x0, x26
     5a0: f94087e2     	ldr	x2, [sp, #0x108]
     5a4: f94083e5     	ldr	x5, [sp, #0x100]
     5a8: aa0403e3     	mov	x3, x4
     5ac: aa0703e6     	mov	x6, x7
     5b0: 94000000     	bl	0x5b0 <___pl_fn_1+0x4a4>
     5b4: aa1a03e0     	mov	x0, x26
     5b8: b9402c00     	ldr	w0, [x0, #0x2c]
     5bc: 35011d60     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     5c0: aa1a03e0     	mov	x0, x26
     5c4: b9001813     	str	w19, [x0, #0x18]
     5c8: b9401c04     	ldr	w4, [x0, #0x1c]
     5cc: 11000e63     	add	w3, w19, #0x3
     5d0: 6b04007f     	cmp	w3, w4
     5d4: 54010c68     	b.hi	0x2760 <___pl_fn_1+0x2654>
     5d8: aa1a03e0     	mov	x0, x26
     5dc: f9401006     	ldr	x6, [x0, #0x20]
     5e0: 8b1408c5     	add	x5, x6, x20, lsl #2
     5e4: f94087e2     	ldr	x2, [sp, #0x108]
     5e8: b83358c2     	str	w2, [x6, w19, uxtw #2]
     5ec: f94083e0     	ldr	x0, [sp, #0x100]
     5f0: b90004a0     	str	w0, [x5, #0x4]
     5f4: b90008bc     	str	w28, [x5, #0x8]
     5f8: aa1a03e0     	mov	x0, x26
     5fc: b9001803     	str	w3, [x0, #0x18]
     600: 528003e1     	mov	w1, #0x1f               ; =31
     604: 52800002     	mov	w2, #0x0                ; =0
     608: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     60c: f9400129     	ldr	x9, [x9]
     610: d63f0120     	blr	x9
     614: 35011aa0     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     618: aa1a03e0     	mov	x0, x26
     61c: f9401801     	ldr	x1, [x0, #0x30]
     620: b9001813     	str	w19, [x0, #0x18]
     624: b9401c0c     	ldr	w12, [x0, #0x1c]
     628: 1100126d     	add	w13, w19, #0x4
     62c: 6b0c01bf     	cmp	w13, w12
     630: 540107e8     	b.hi	0x272c <___pl_fn_1+0x2620>
     634: aa1a03e0     	mov	x0, x26
     638: f940100f     	ldr	x15, [x0, #0x20]
     63c: 8b1409ee     	add	x14, x15, x20, lsl #2
     640: f94087e2     	ldr	x2, [sp, #0x108]
     644: b83359e2     	str	w2, [x15, w19, uxtw #2]
     648: f94083e5     	ldr	x5, [sp, #0x100]
     64c: b90005c5     	str	w5, [x14, #0x4]
     650: b90009dc     	str	w28, [x14, #0x8]
     654: b9000dc1     	str	w1, [x14, #0xc]
     658: 11001260     	add	w0, w19, #0x4
     65c: aa1a03e3     	mov	x3, x26
     660: b9001860     	str	w0, [x3, #0x18]
     664: aa1a03e0     	mov	x0, x26
     668: b9401000     	ldr	w0, [x0, #0x10]
     66c: aa1a03e7     	mov	x7, x26
     670: b94014e2     	ldr	w2, [x7, #0x14]
     674: 6b02001f     	cmp	w0, w2
     678: 54010402     	b.hs	0x26f8 <___pl_fn_1+0x25ec>
     67c: d2800015     	mov	x21, #0x0               ; =0
     680: d2807d24     	mov	x4, #0x3e9              ; =1001
     684: aa1a03e0     	mov	x0, x26
     688: f94083e2     	ldr	x2, [sp, #0x100]
     68c: aa1503e3     	mov	x3, x21
     690: 94000000     	bl	0x690 <___pl_fn_1+0x584>
     694: aa1a03ee     	mov	x14, x26
     698: b9402dc1     	ldr	w1, [x14, #0x2c]
     69c: 35011661     	cbnz	w1, 0x2968 <___pl_fn_1+0x285c>
     6a0: aa1a03e1     	mov	x1, x26
     6a4: b9001833     	str	w19, [x1, #0x18]
     6a8: 340100e0     	cbz	w0, 0x26c4 <___pl_fn_1+0x25b8>
     6ac: aa1a03e1     	mov	x1, x26
     6b0: b9401c21     	ldr	w1, [x1, #0x1c]
     6b4: 11001262     	add	w2, w19, #0x4
     6b8: 6b01005f     	cmp	w2, w1
     6bc: 5400fea8     	b.hi	0x2690 <___pl_fn_1+0x2584>
     6c0: aa1a03e1     	mov	x1, x26
     6c4: f9401022     	ldr	x2, [x1, #0x20]
     6c8: 8b140841     	add	x1, x2, x20, lsl #2
     6cc: f94087e3     	ldr	x3, [sp, #0x108]
     6d0: b8335843     	str	w3, [x2, w19, uxtw #2]
     6d4: f94083e5     	ldr	x5, [sp, #0x100]
     6d8: b9000425     	str	w5, [x1, #0x4]
     6dc: b900083c     	str	w28, [x1, #0x8]
     6e0: b9000c20     	str	w0, [x1, #0xc]
     6e4: aa0003f6     	mov	x22, x0
     6e8: 11001260     	add	w0, w19, #0x4
     6ec: aa1a03e1     	mov	x1, x26
     6f0: b9001820     	str	w0, [x1, #0x18]
     6f4: 52800481     	mov	w1, #0x24               ; =36
     6f8: 52800002     	mov	w2, #0x0                ; =0
     6fc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     700: f9400063     	ldr	x3, [x3]
     704: aa1a03e0     	mov	x0, x26
     708: d63f0060     	blr	x3
     70c: 350112e0     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     710: aa1a03e0     	mov	x0, x26
     714: f9401801     	ldr	x1, [x0, #0x30]
     718: b9001813     	str	w19, [x0, #0x18]
     71c: b9401c02     	ldr	w2, [x0, #0x1c]
     720: 11001660     	add	w0, w19, #0x5
     724: 6b02001f     	cmp	w0, w2
     728: 5400f9a8     	b.hi	0x265c <___pl_fn_1+0x2550>
     72c: aa1a03e2     	mov	x2, x26
     730: f9401043     	ldr	x3, [x2, #0x20]
     734: 8b140862     	add	x2, x3, x20, lsl #2
     738: f94087e4     	ldr	x4, [sp, #0x108]
     73c: b8335864     	str	w4, [x3, w19, uxtw #2]
     740: f94083e5     	ldr	x5, [sp, #0x100]
     744: b9000445     	str	w5, [x2, #0x4]
     748: b900085c     	str	w28, [x2, #0x8]
     74c: aa1603ea     	mov	x10, x22
     750: b9000c4a     	str	w10, [x2, #0xc]
     754: b9001041     	str	w1, [x2, #0x10]
     758: aa1a03e2     	mov	x2, x26
     75c: b9001840     	str	w0, [x2, #0x18]
     760: aa1a03e0     	mov	x0, x26
     764: b9401000     	ldr	w0, [x0, #0x10]
     768: b9401442     	ldr	w2, [x2, #0x14]
     76c: 6b02001f     	cmp	w0, w2
     770: 5400f5c2     	b.hs	0x2628 <___pl_fn_1+0x251c>
     774: d2807d24     	mov	x4, #0x3e9              ; =1001
     778: aa1603e2     	mov	x2, x22
     77c: aa1a03e0     	mov	x0, x26
     780: aa1503e3     	mov	x3, x21
     784: 94000000     	bl	0x784 <___pl_fn_1+0x678>
     788: aa1a03e6     	mov	x6, x26
     78c: b9402cc1     	ldr	w1, [x6, #0x2c]
     790: 35010ec1     	cbnz	w1, 0x2968 <___pl_fn_1+0x285c>
     794: aa1a03ea     	mov	x10, x26
     798: b9001953     	str	w19, [x10, #0x18]
     79c: 3400f2c0     	cbz	w0, 0x25f4 <___pl_fn_1+0x24e8>
     7a0: aa1a03ed     	mov	x13, x26
     7a4: b9401da1     	ldr	w1, [x13, #0x1c]
     7a8: 11001262     	add	w2, w19, #0x4
     7ac: 6b01005f     	cmp	w2, w1
     7b0: 5400f088     	b.hi	0x25c0 <___pl_fn_1+0x24b4>
     7b4: aa1a03e1     	mov	x1, x26
     7b8: f9401022     	ldr	x2, [x1, #0x20]
     7bc: 8b140841     	add	x1, x2, x20, lsl #2
     7c0: f94087e3     	ldr	x3, [sp, #0x108]
     7c4: b8335843     	str	w3, [x2, w19, uxtw #2]
     7c8: f94083e5     	ldr	x5, [sp, #0x100]
     7cc: b9000425     	str	w5, [x1, #0x4]
     7d0: b900083c     	str	w28, [x1, #0x8]
     7d4: b9000c20     	str	w0, [x1, #0xc]
     7d8: aa0003fb     	mov	x27, x0
     7dc: 11001260     	add	w0, w19, #0x4
     7e0: aa1a03e1     	mov	x1, x26
     7e4: b9001820     	str	w0, [x1, #0x18]
     7e8: 52800521     	mov	w1, #0x29               ; =41
     7ec: 528000c2     	mov	w2, #0x6                ; =6
     7f0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     7f4: f9400063     	ldr	x3, [x3]
     7f8: aa1a03e0     	mov	x0, x26
     7fc: d63f0060     	blr	x3
     800: 35010b40     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     804: aa1a03e0     	mov	x0, x26
     808: f9401814     	ldr	x20, [x0, #0x30]
     80c: b9001813     	str	w19, [x0, #0x18]
     810: 3400ebf4     	cbz	w20, 0x258c <___pl_fn_1+0x2480>
     814: 35000094     	cbnz	w20, 0x824 <___pl_fn_1+0x718>
     818: 1400044b     	b	0x1944 <___pl_fn_1+0x1838>
     81c: aa1403f3     	mov	x19, x20
     820: 14000012     	b	0x868 <___pl_fn_1+0x75c>
     824: aa1a03e0     	mov	x0, x26
     828: f9400005     	ldr	x5, [x0]
     82c: aa1403f3     	mov	x19, x20
     830: 2a1303e4     	mov	w4, w19
     834: d2800063     	mov	x3, #0x3                ; =3
     838: 8b040ca4     	add	x4, x5, x4, lsl #3
     83c: f87358a5     	ldr	x5, [x5, w19, uxtw #3]
     840: d360fca5     	lsr	x5, x5, #32
     844: 92403ca6     	and	x6, x5, #0xffff
     848: f10008df     	cmp	x6, #0x2
     84c: 54000080     	b.eq	0x85c <___pl_fn_1+0x750>
     850: f9400886     	ldr	x6, [x4, #0x10]
     854: 9277f8c6     	and	x6, x6, #0xfffffffffffffeff
     858: f9000886     	str	x6, [x4, #0x10]
     85c: 92403ca8     	and	x8, x5, #0xffff
     860: 91002108     	add	x8, x8, #0x8
     864: f8287883     	str	x3, [x4, x8, lsl #3]
     868: 350000b3     	cbnz	w19, 0x87c <___pl_fn_1+0x770>
     86c: 14000443     	b	0x1978 <___pl_fn_1+0x186c>
     870: aa1a03e0     	mov	x0, x26
     874: aa1403e1     	mov	x1, x20
     878: 14000013     	b	0x8c4 <___pl_fn_1+0x7b8>
     87c: aa1a03e0     	mov	x0, x26
     880: aa1303f4     	mov	x20, x19
     884: f9400002     	ldr	x2, [x0]
     888: aa1403e1     	mov	x1, x20
     88c: 2a0103e0     	mov	w0, w1
     890: 8b000c40     	add	x0, x2, x0, lsl #3
     894: f8615842     	ldr	x2, [x2, w1, uxtw #3]
     898: d360fc42     	lsr	x2, x2, #32
     89c: 92403c43     	and	x3, x2, #0xffff
     8a0: f100087f     	cmp	x3, #0x2
     8a4: 54000080     	b.eq	0x8b4 <___pl_fn_1+0x7a8>
     8a8: f9400803     	ldr	x3, [x0, #0x10]
     8ac: 9276f863     	and	x3, x3, #0xfffffffffffffdff
     8b0: f9000803     	str	x3, [x0, #0x10]
     8b4: 92403c42     	and	x2, x2, #0xffff
     8b8: 91002442     	add	x2, x2, #0x9
     8bc: f8227815     	str	x21, [x0, x2, lsl #3]
     8c0: aa1a03e0     	mov	x0, x26
     8c4: aa1a03e0     	mov	x0, x26
     8c8: b9401817     	ldr	w23, [x0, #0x18]
     8cc: b9401c00     	ldr	w0, [x0, #0x1c]
     8d0: 110016f8     	add	w24, w23, #0x5
     8d4: 6b00031f     	cmp	w24, w0
     8d8: 5400e408     	b.hi	0x2558 <___pl_fn_1+0x244c>
     8dc: aa1a03e0     	mov	x0, x26
     8e0: f9401002     	ldr	x2, [x0, #0x20]
     8e4: 2a1703f9     	mov	w25, w23
     8e8: 8b190840     	add	x0, x2, x25, lsl #2
     8ec: f94087e3     	ldr	x3, [sp, #0x108]
     8f0: b8375843     	str	w3, [x2, w23, uxtw #2]
     8f4: f94083e5     	ldr	x5, [sp, #0x100]
     8f8: b9000405     	str	w5, [x0, #0x4]
     8fc: b900081c     	str	w28, [x0, #0x8]
     900: aa1b03e5     	mov	x5, x27
     904: b9000c05     	str	w5, [x0, #0xc]
     908: b9001001     	str	w1, [x0, #0x10]
     90c: aa1a03e0     	mov	x0, x26
     910: b9001818     	str	w24, [x0, #0x18]
     914: b9401000     	ldr	w0, [x0, #0x10]
     918: aa1a03e2     	mov	x2, x26
     91c: b9401442     	ldr	w2, [x2, #0x14]
     920: 6b02001f     	cmp	w0, w2
     924: 5400e002     	b.hs	0x2524 <___pl_fn_1+0x2418>
     928: d2800043     	mov	x3, #0x2                ; =2
     92c: d2807d04     	mov	x4, #0x3e8              ; =1000
     930: 52800027     	mov	w7, #0x1                ; =1
     934: aa1b03e5     	mov	x5, x27
     938: aa1a03e0     	mov	x0, x26
     93c: f94087e2     	ldr	x2, [sp, #0x108]
     940: aa0703e6     	mov	x6, x7
     944: 94000000     	bl	0x944 <___pl_fn_1+0x838>
     948: aa1a03e0     	mov	x0, x26
     94c: b9402c00     	ldr	w0, [x0, #0x2c]
     950: 350100c0     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     954: aa1a03e0     	mov	x0, x26
     958: b9001817     	str	w23, [x0, #0x18]
     95c: b9401c01     	ldr	w1, [x0, #0x1c]
     960: 11000ee0     	add	w0, w23, #0x3
     964: 6b01001f     	cmp	w0, w1
     968: 5400dc48     	b.hi	0x24f0 <___pl_fn_1+0x23e4>
     96c: aa1a03ec     	mov	x12, x26
     970: f9401182     	ldr	x2, [x12, #0x20]
     974: 8b190841     	add	x1, x2, x25, lsl #2
     978: f94087e7     	ldr	x7, [sp, #0x108]
     97c: b8375847     	str	w7, [x2, w23, uxtw #2]
     980: f94083e5     	ldr	x5, [sp, #0x100]
     984: b9000425     	str	w5, [x1, #0x4]
     988: b900083c     	str	w28, [x1, #0x8]
     98c: aa1a03e1     	mov	x1, x26
     990: b9001820     	str	w0, [x1, #0x18]
     994: 52800601     	mov	w1, #0x30               ; =48
     998: 52800002     	mov	w2, #0x0                ; =0
     99c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     9a0: f9400063     	ldr	x3, [x3]
     9a4: aa1a03e0     	mov	x0, x26
     9a8: d63f0060     	blr	x3
     9ac: 3500fde0     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     9b0: aa1a03e0     	mov	x0, x26
     9b4: f9401801     	ldr	x1, [x0, #0x30]
     9b8: b9001817     	str	w23, [x0, #0x18]
     9bc: b9401c00     	ldr	w0, [x0, #0x1c]
     9c0: 110012f3     	add	w19, w23, #0x4
     9c4: 6b00027f     	cmp	w19, w0
     9c8: 5400d7a8     	b.hi	0x24bc <___pl_fn_1+0x23b0>
     9cc: aa1a03e0     	mov	x0, x26
     9d0: f9401002     	ldr	x2, [x0, #0x20]
     9d4: 8b190840     	add	x0, x2, x25, lsl #2
     9d8: f94087e3     	ldr	x3, [sp, #0x108]
     9dc: b8375843     	str	w3, [x2, w23, uxtw #2]
     9e0: f94083e5     	ldr	x5, [sp, #0x100]
     9e4: b9000405     	str	w5, [x0, #0x4]
     9e8: b900081c     	str	w28, [x0, #0x8]
     9ec: b9000c01     	str	w1, [x0, #0xc]
     9f0: aa1a03e0     	mov	x0, x26
     9f4: b9001813     	str	w19, [x0, #0x18]
     9f8: b9401000     	ldr	w0, [x0, #0x10]
     9fc: aa1a03e2     	mov	x2, x26
     a00: b9401442     	ldr	w2, [x2, #0x14]
     a04: 6b02001f     	cmp	w0, w2
     a08: 5400d402     	b.hs	0x2488 <___pl_fn_1+0x237c>
     a0c: d28000a3     	mov	x3, #0x5                ; =5
     a10: d2807d04     	mov	x4, #0x3e8              ; =1000
     a14: aa1a03e0     	mov	x0, x26
     a18: f94083e2     	ldr	x2, [sp, #0x100]
     a1c: 94000000     	bl	0xa1c <___pl_fn_1+0x910>
     a20: aa1a03e1     	mov	x1, x26
     a24: b9402c21     	ldr	w1, [x1, #0x2c]
     a28: 3500fa01     	cbnz	w1, 0x2968 <___pl_fn_1+0x285c>
     a2c: aa1a03e1     	mov	x1, x26
     a30: b9001837     	str	w23, [x1, #0x18]
     a34: 3400d100     	cbz	w0, 0x2454 <___pl_fn_1+0x2348>
     a38: aa1a03e1     	mov	x1, x26
     a3c: b9401c21     	ldr	w1, [x1, #0x1c]
     a40: 6b01027f     	cmp	w19, w1
     a44: 5400cee8     	b.hi	0x2420 <___pl_fn_1+0x2314>
     a48: aa1a03e1     	mov	x1, x26
     a4c: f9401022     	ldr	x2, [x1, #0x20]
     a50: 8b190841     	add	x1, x2, x25, lsl #2
     a54: f94087e3     	ldr	x3, [sp, #0x108]
     a58: b8375843     	str	w3, [x2, w23, uxtw #2]
     a5c: f94083e5     	ldr	x5, [sp, #0x100]
     a60: b9000425     	str	w5, [x1, #0x4]
     a64: b900083c     	str	w28, [x1, #0x8]
     a68: b9000c20     	str	w0, [x1, #0xc]
     a6c: aa0003f4     	mov	x20, x0
     a70: aa1a03e0     	mov	x0, x26
     a74: b9001813     	str	w19, [x0, #0x18]
     a78: 528006a1     	mov	w1, #0x35               ; =53
     a7c: 52800002     	mov	w2, #0x0                ; =0
     a80: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     a84: f9400063     	ldr	x3, [x3]
     a88: d63f0060     	blr	x3
     a8c: 3500f6e0     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     a90: aa1a03e0     	mov	x0, x26
     a94: f9401801     	ldr	x1, [x0, #0x30]
     a98: b9001817     	str	w23, [x0, #0x18]
     a9c: b9401c06     	ldr	w6, [x0, #0x1c]
     aa0: 6b06031f     	cmp	w24, w6
     aa4: 5400ca48     	b.hi	0x23ec <___pl_fn_1+0x22e0>
     aa8: aa1a03e0     	mov	x0, x26
     aac: f9401009     	ldr	x9, [x0, #0x20]
     ab0: 8b190928     	add	x8, x9, x25, lsl #2
     ab4: f94087e2     	ldr	x2, [sp, #0x108]
     ab8: b8375922     	str	w2, [x9, w23, uxtw #2]
     abc: f94083e5     	ldr	x5, [sp, #0x100]
     ac0: b9000505     	str	w5, [x8, #0x4]
     ac4: b900091c     	str	w28, [x8, #0x8]
     ac8: aa1403e0     	mov	x0, x20
     acc: b9000d00     	str	w0, [x8, #0xc]
     ad0: b9001101     	str	w1, [x8, #0x10]
     ad4: aa1a03e0     	mov	x0, x26
     ad8: b9001818     	str	w24, [x0, #0x18]
     adc: b940100e     	ldr	w14, [x0, #0x10]
     ae0: b940140f     	ldr	w15, [x0, #0x14]
     ae4: 6b0f01df     	cmp	w14, w15
     ae8: 5400c682     	b.hs	0x23b8 <___pl_fn_1+0x22ac>
     aec: d28000a3     	mov	x3, #0x5                ; =5
     af0: d2807d04     	mov	x4, #0x3e8              ; =1000
     af4: aa1403e2     	mov	x2, x20
     af8: aa1a03e0     	mov	x0, x26
     afc: 94000000     	bl	0xafc <___pl_fn_1+0x9f0>
     b00: aa1a03e1     	mov	x1, x26
     b04: b9402c21     	ldr	w1, [x1, #0x2c]
     b08: 3500f301     	cbnz	w1, 0x2968 <___pl_fn_1+0x285c>
     b0c: aa1a03e1     	mov	x1, x26
     b10: b9001837     	str	w23, [x1, #0x18]
     b14: 3400c380     	cbz	w0, 0x2384 <___pl_fn_1+0x2278>
     b18: aa1a03e1     	mov	x1, x26
     b1c: b9401c21     	ldr	w1, [x1, #0x1c]
     b20: 6b01027f     	cmp	w19, w1
     b24: 5400c168     	b.hi	0x2350 <___pl_fn_1+0x2244>
     b28: aa1a03e1     	mov	x1, x26
     b2c: f9401022     	ldr	x2, [x1, #0x20]
     b30: 8b190841     	add	x1, x2, x25, lsl #2
     b34: f94087e3     	ldr	x3, [sp, #0x108]
     b38: b8375843     	str	w3, [x2, w23, uxtw #2]
     b3c: f94083e5     	ldr	x5, [sp, #0x100]
     b40: b9000425     	str	w5, [x1, #0x4]
     b44: b900083c     	str	w28, [x1, #0x8]
     b48: b9000c20     	str	w0, [x1, #0xc]
     b4c: aa0003f4     	mov	x20, x0
     b50: aa1a03e0     	mov	x0, x26
     b54: b9001813     	str	w19, [x0, #0x18]
     b58: 52800741     	mov	w1, #0x3a               ; =58
     b5c: 52800002     	mov	w2, #0x0                ; =0
     b60: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b64: f9400063     	ldr	x3, [x3]
     b68: d63f0060     	blr	x3
     b6c: 3500efe0     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     b70: aa1a03e0     	mov	x0, x26
     b74: f9401801     	ldr	x1, [x0, #0x30]
     b78: b9001817     	str	w23, [x0, #0x18]
     b7c: b9401c00     	ldr	w0, [x0, #0x1c]
     b80: 6b00031f     	cmp	w24, w0
     b84: 5400bcc8     	b.hi	0x231c <___pl_fn_1+0x2210>
     b88: aa1a03e0     	mov	x0, x26
     b8c: f9401002     	ldr	x2, [x0, #0x20]
     b90: 8b190840     	add	x0, x2, x25, lsl #2
     b94: f94087e3     	ldr	x3, [sp, #0x108]
     b98: b8375843     	str	w3, [x2, w23, uxtw #2]
     b9c: f94083e5     	ldr	x5, [sp, #0x100]
     ba0: b9000405     	str	w5, [x0, #0x4]
     ba4: b900081c     	str	w28, [x0, #0x8]
     ba8: aa1403e2     	mov	x2, x20
     bac: b9000c02     	str	w2, [x0, #0xc]
     bb0: b9001001     	str	w1, [x0, #0x10]
     bb4: aa1a03e0     	mov	x0, x26
     bb8: b9001818     	str	w24, [x0, #0x18]
     bbc: b9401000     	ldr	w0, [x0, #0x10]
     bc0: aa1a03e2     	mov	x2, x26
     bc4: b9401442     	ldr	w2, [x2, #0x14]
     bc8: 6b02001f     	cmp	w0, w2
     bcc: 5400b8e2     	b.hs	0x22e8 <___pl_fn_1+0x21dc>
     bd0: d28000a3     	mov	x3, #0x5                ; =5
     bd4: d2807d04     	mov	x4, #0x3e8              ; =1000
     bd8: aa1403e2     	mov	x2, x20
     bdc: aa1a03e0     	mov	x0, x26
     be0: 94000000     	bl	0xbe0 <___pl_fn_1+0xad4>
     be4: aa1a03e1     	mov	x1, x26
     be8: b9402c21     	ldr	w1, [x1, #0x2c]
     bec: 3500ebe1     	cbnz	w1, 0x2968 <___pl_fn_1+0x285c>
     bf0: aa1a03e1     	mov	x1, x26
     bf4: b9001837     	str	w23, [x1, #0x18]
     bf8: 3400b5e0     	cbz	w0, 0x22b4 <___pl_fn_1+0x21a8>
     bfc: aa1a03e1     	mov	x1, x26
     c00: b9401c21     	ldr	w1, [x1, #0x1c]
     c04: 6b01027f     	cmp	w19, w1
     c08: 5400b3c8     	b.hi	0x2280 <___pl_fn_1+0x2174>
     c0c: aa1a03e1     	mov	x1, x26
     c10: f9401022     	ldr	x2, [x1, #0x20]
     c14: 8b190841     	add	x1, x2, x25, lsl #2
     c18: f94087e9     	ldr	x9, [sp, #0x108]
     c1c: b8375849     	str	w9, [x2, w23, uxtw #2]
     c20: f94083e5     	ldr	x5, [sp, #0x100]
     c24: b9000425     	str	w5, [x1, #0x4]
     c28: b900083c     	str	w28, [x1, #0x8]
     c2c: b9000c20     	str	w0, [x1, #0xc]
     c30: aa0003f6     	mov	x22, x0
     c34: aa1a03e0     	mov	x0, x26
     c38: b9001813     	str	w19, [x0, #0x18]
     c3c: 528007e1     	mov	w1, #0x3f               ; =63
     c40: 52800082     	mov	w2, #0x4                ; =4
     c44: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     c48: f9400063     	ldr	x3, [x3]
     c4c: d63f0060     	blr	x3
     c50: 3500e8c0     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     c54: aa1a03e0     	mov	x0, x26
     c58: f9401813     	ldr	x19, [x0, #0x30]
     c5c: b9001817     	str	w23, [x0, #0x18]
     c60: 3400af73     	cbz	w19, 0x224c <___pl_fn_1+0x2140>
     c64: 34006a53     	cbz	w19, 0x19ac <___pl_fn_1+0x18a0>
     c68: aa1a03e0     	mov	x0, x26
     c6c: f9400001     	ldr	x1, [x0]
     c70: 2a1303e0     	mov	w0, w19
     c74: 8b000c20     	add	x0, x1, x0, lsl #3
     c78: f8735822     	ldr	x2, [x1, w19, uxtw #3]
     c7c: f94083e5     	ldr	x5, [sp, #0x100]
     c80: 2a0503e1     	mov	w1, w5
     c84: d360fc42     	lsr	x2, x2, #32
     c88: 92403c42     	and	x2, x2, #0xffff
     c8c: 91002042     	add	x2, x2, #0x8
     c90: f8227801     	str	x1, [x0, x2, lsl #3]
     c94: 350000b3     	cbnz	w19, 0xca8 <___pl_fn_1+0xb9c>
     c98: 14000353     	b	0x19e4 <___pl_fn_1+0x18d8>
     c9c: aa1a03e0     	mov	x0, x26
     ca0: aa1303e1     	mov	x1, x19
     ca4: 1400000d     	b	0xcd8 <___pl_fn_1+0xbcc>
     ca8: aa1a03e0     	mov	x0, x26
     cac: f9400007     	ldr	x7, [x0]
     cb0: aa1303e1     	mov	x1, x19
     cb4: 2a0103e6     	mov	w6, w1
     cb8: 8b060ce6     	add	x6, x7, x6, lsl #3
     cbc: f86158e8     	ldr	x8, [x7, w1, uxtw #3]
     cc0: f94083e5     	ldr	x5, [sp, #0x100]
     cc4: 2a0503e7     	mov	w7, w5
     cc8: d360fd08     	lsr	x8, x8, #32
     ccc: 92403d08     	and	x8, x8, #0xffff
     cd0: 91002508     	add	x8, x8, #0x9
     cd4: f82878c7     	str	x7, [x6, x8, lsl #3]
     cd8: aa1a03e0     	mov	x0, x26
     cdc: b9401813     	ldr	w19, [x0, #0x18]
     ce0: b9401c08     	ldr	w8, [x0, #0x1c]
     ce4: 11001675     	add	w21, w19, #0x5
     ce8: 6b0802bf     	cmp	w21, w8
     cec: 5400a968     	b.hi	0x2218 <___pl_fn_1+0x210c>
     cf0: aa1a03e0     	mov	x0, x26
     cf4: f940100b     	ldr	x11, [x0, #0x20]
     cf8: 2a1303f4     	mov	w20, w19
     cfc: 8b14096a     	add	x10, x11, x20, lsl #2
     d00: f94087e2     	ldr	x2, [sp, #0x108]
     d04: b8335962     	str	w2, [x11, w19, uxtw #2]
     d08: f94083e5     	ldr	x5, [sp, #0x100]
     d0c: b9000545     	str	w5, [x10, #0x4]
     d10: b900095c     	str	w28, [x10, #0x8]
     d14: aa1603e0     	mov	x0, x22
     d18: b9000d40     	str	w0, [x10, #0xc]
     d1c: b9001141     	str	w1, [x10, #0x10]
     d20: aa1a03e0     	mov	x0, x26
     d24: b9001815     	str	w21, [x0, #0x18]
     d28: b9401000     	ldr	w0, [x0, #0x10]
     d2c: aa1a03e4     	mov	x4, x26
     d30: b9401482     	ldr	w2, [x4, #0x14]
     d34: 6b02001f     	cmp	w0, w2
     d38: 5400a562     	b.hs	0x21e4 <___pl_fn_1+0x20d8>
     d3c: d2800063     	mov	x3, #0x3                ; =3
     d40: d280fa04     	mov	x4, #0x7d0              ; =2000
     d44: 52800027     	mov	w7, #0x1                ; =1
     d48: aa1603e5     	mov	x5, x22
     d4c: aa1a03e0     	mov	x0, x26
     d50: f94087e2     	ldr	x2, [sp, #0x108]
     d54: aa0703e6     	mov	x6, x7
     d58: 94000000     	bl	0xd58 <___pl_fn_1+0xc4c>
     d5c: aa1a03e0     	mov	x0, x26
     d60: b9402c00     	ldr	w0, [x0, #0x2c]
     d64: 3500e020     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     d68: aa1a03e0     	mov	x0, x26
     d6c: b9001813     	str	w19, [x0, #0x18]
     d70: b9401c01     	ldr	w1, [x0, #0x1c]
     d74: 11000e60     	add	w0, w19, #0x3
     d78: 6b01001f     	cmp	w0, w1
     d7c: 5400a1a8     	b.hi	0x21b0 <___pl_fn_1+0x20a4>
     d80: aa1a03e1     	mov	x1, x26
     d84: f9401022     	ldr	x2, [x1, #0x20]
     d88: 8b140841     	add	x1, x2, x20, lsl #2
     d8c: f94087e3     	ldr	x3, [sp, #0x108]
     d90: b8335843     	str	w3, [x2, w19, uxtw #2]
     d94: f94083e5     	ldr	x5, [sp, #0x100]
     d98: b9000425     	str	w5, [x1, #0x4]
     d9c: b900083c     	str	w28, [x1, #0x8]
     da0: aa1a03e1     	mov	x1, x26
     da4: b9001820     	str	w0, [x1, #0x18]
     da8: 528008c1     	mov	w1, #0x46               ; =70
     dac: 52800002     	mov	w2, #0x0                ; =0
     db0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     db4: f9400063     	ldr	x3, [x3]
     db8: aa1a03e0     	mov	x0, x26
     dbc: d63f0060     	blr	x3
     dc0: 3500dd40     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     dc4: aa1a03e0     	mov	x0, x26
     dc8: f9401801     	ldr	x1, [x0, #0x30]
     dcc: b9001813     	str	w19, [x0, #0x18]
     dd0: b9401c00     	ldr	w0, [x0, #0x1c]
     dd4: 11001276     	add	w22, w19, #0x4
     dd8: 6b0002df     	cmp	w22, w0
     ddc: 54009d08     	b.hi	0x217c <___pl_fn_1+0x2070>
     de0: aa1a03e0     	mov	x0, x26
     de4: f9401002     	ldr	x2, [x0, #0x20]
     de8: 8b140840     	add	x0, x2, x20, lsl #2
     dec: f94087e3     	ldr	x3, [sp, #0x108]
     df0: b8335843     	str	w3, [x2, w19, uxtw #2]
     df4: f94083e5     	ldr	x5, [sp, #0x100]
     df8: b9000405     	str	w5, [x0, #0x4]
     dfc: b900081c     	str	w28, [x0, #0x8]
     e00: b9000c01     	str	w1, [x0, #0xc]
     e04: aa1a03e0     	mov	x0, x26
     e08: b9001816     	str	w22, [x0, #0x18]
     e0c: b9401000     	ldr	w0, [x0, #0x10]
     e10: aa1a03e2     	mov	x2, x26
     e14: b9401442     	ldr	w2, [x2, #0x14]
     e18: 6b02001f     	cmp	w0, w2
     e1c: 54009962     	b.hs	0x2148 <___pl_fn_1+0x203c>
     e20: d28000c3     	mov	x3, #0x6                ; =6
     e24: d2807d04     	mov	x4, #0x3e8              ; =1000
     e28: aa1a03e0     	mov	x0, x26
     e2c: f94083e2     	ldr	x2, [sp, #0x100]
     e30: 94000000     	bl	0xe30 <___pl_fn_1+0xd24>
     e34: aa1a03e1     	mov	x1, x26
     e38: b9402c21     	ldr	w1, [x1, #0x2c]
     e3c: 3500d961     	cbnz	w1, 0x2968 <___pl_fn_1+0x285c>
     e40: aa1a03e5     	mov	x5, x26
     e44: b90018b3     	str	w19, [x5, #0x18]
     e48: 34009660     	cbz	w0, 0x2114 <___pl_fn_1+0x2008>
     e4c: aa1a03e8     	mov	x8, x26
     e50: b9401d01     	ldr	w1, [x8, #0x1c]
     e54: 6b0102df     	cmp	w22, w1
     e58: 54009448     	b.hi	0x20e0 <___pl_fn_1+0x1fd4>
     e5c: aa1a03ec     	mov	x12, x26
     e60: f9401182     	ldr	x2, [x12, #0x20]
     e64: 8b140841     	add	x1, x2, x20, lsl #2
     e68: f94087e3     	ldr	x3, [sp, #0x108]
     e6c: b8335843     	str	w3, [x2, w19, uxtw #2]
     e70: f94083e5     	ldr	x5, [sp, #0x100]
     e74: b9000425     	str	w5, [x1, #0x4]
     e78: b900083c     	str	w28, [x1, #0x8]
     e7c: b9000c20     	str	w0, [x1, #0xc]
     e80: aa0003f7     	mov	x23, x0
     e84: aa1a03e0     	mov	x0, x26
     e88: b9001816     	str	w22, [x0, #0x18]
     e8c: 52800961     	mov	w1, #0x4b               ; =75
     e90: 52800002     	mov	w2, #0x0                ; =0
     e94: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     e98: f9400063     	ldr	x3, [x3]
     e9c: d63f0060     	blr	x3
     ea0: 3500d640     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     ea4: aa1a03e0     	mov	x0, x26
     ea8: f9401801     	ldr	x1, [x0, #0x30]
     eac: b9001813     	str	w19, [x0, #0x18]
     eb0: b9401c00     	ldr	w0, [x0, #0x1c]
     eb4: 6b0002bf     	cmp	w21, w0
     eb8: 54008fa8     	b.hi	0x20ac <___pl_fn_1+0x1fa0>
     ebc: aa1a03e0     	mov	x0, x26
     ec0: f9401002     	ldr	x2, [x0, #0x20]
     ec4: 8b140840     	add	x0, x2, x20, lsl #2
     ec8: f94087e3     	ldr	x3, [sp, #0x108]
     ecc: b8335843     	str	w3, [x2, w19, uxtw #2]
     ed0: f94083e5     	ldr	x5, [sp, #0x100]
     ed4: b9000405     	str	w5, [x0, #0x4]
     ed8: b900081c     	str	w28, [x0, #0x8]
     edc: aa1703e2     	mov	x2, x23
     ee0: b9000c02     	str	w2, [x0, #0xc]
     ee4: b9001001     	str	w1, [x0, #0x10]
     ee8: aa1a03e0     	mov	x0, x26
     eec: b9001815     	str	w21, [x0, #0x18]
     ef0: b9401000     	ldr	w0, [x0, #0x10]
     ef4: aa1a03e2     	mov	x2, x26
     ef8: b9401442     	ldr	w2, [x2, #0x14]
     efc: 6b02001f     	cmp	w0, w2
     f00: 54008bc2     	b.hs	0x2078 <___pl_fn_1+0x1f6c>
     f04: d28000c3     	mov	x3, #0x6                ; =6
     f08: d2807d04     	mov	x4, #0x3e8              ; =1000
     f0c: aa1703e2     	mov	x2, x23
     f10: aa1a03e0     	mov	x0, x26
     f14: 94000000     	bl	0xf14 <___pl_fn_1+0xe08>
     f18: aa1a03e1     	mov	x1, x26
     f1c: b9402c21     	ldr	w1, [x1, #0x2c]
     f20: 3500d241     	cbnz	w1, 0x2968 <___pl_fn_1+0x285c>
     f24: aa1a03e1     	mov	x1, x26
     f28: b9001833     	str	w19, [x1, #0x18]
     f2c: 340088c0     	cbz	w0, 0x2044 <___pl_fn_1+0x1f38>
     f30: aa1a03e1     	mov	x1, x26
     f34: b9401c25     	ldr	w5, [x1, #0x1c]
     f38: 6b0502df     	cmp	w22, w5
     f3c: 540086a8     	b.hi	0x2010 <___pl_fn_1+0x1f04>
     f40: aa1a03e2     	mov	x2, x26
     f44: f9401048     	ldr	x8, [x2, #0x20]
     f48: 8b140907     	add	x7, x8, x20, lsl #2
     f4c: f94087e2     	ldr	x2, [sp, #0x108]
     f50: b8335902     	str	w2, [x8, w19, uxtw #2]
     f54: f94083e5     	ldr	x5, [sp, #0x100]
     f58: b90004e5     	str	w5, [x7, #0x4]
     f5c: b90008fc     	str	w28, [x7, #0x8]
     f60: b9000ce0     	str	w0, [x7, #0xc]
     f64: aa0003f7     	mov	x23, x0
     f68: aa1a03e0     	mov	x0, x26
     f6c: b9001816     	str	w22, [x0, #0x18]
     f70: 52800a01     	mov	w1, #0x50               ; =80
     f74: 52800002     	mov	w2, #0x0                ; =0
     f78: 9000000c     	adrp	x12, 0x0 <___pl_fn_0>
     f7c: f940018c     	ldr	x12, [x12]
     f80: d63f0180     	blr	x12
     f84: 3500cf20     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
     f88: aa1a03e0     	mov	x0, x26
     f8c: f9401801     	ldr	x1, [x0, #0x30]
     f90: b9001813     	str	w19, [x0, #0x18]
     f94: b9401c0f     	ldr	w15, [x0, #0x1c]
     f98: 6b0f02bf     	cmp	w21, w15
     f9c: 54008208     	b.hi	0x1fdc <___pl_fn_1+0x1ed0>
     fa0: aa1a03e0     	mov	x0, x26
     fa4: f9401002     	ldr	x2, [x0, #0x20]
     fa8: 8b140840     	add	x0, x2, x20, lsl #2
     fac: f94087e3     	ldr	x3, [sp, #0x108]
     fb0: b8335843     	str	w3, [x2, w19, uxtw #2]
     fb4: f94083e5     	ldr	x5, [sp, #0x100]
     fb8: b9000405     	str	w5, [x0, #0x4]
     fbc: b900081c     	str	w28, [x0, #0x8]
     fc0: aa1703ec     	mov	x12, x23
     fc4: b9000c0c     	str	w12, [x0, #0xc]
     fc8: b9001001     	str	w1, [x0, #0x10]
     fcc: aa1a03e0     	mov	x0, x26
     fd0: b9001815     	str	w21, [x0, #0x18]
     fd4: b9401000     	ldr	w0, [x0, #0x10]
     fd8: aa1a03e2     	mov	x2, x26
     fdc: b9401442     	ldr	w2, [x2, #0x14]
     fe0: 6b02001f     	cmp	w0, w2
     fe4: 54007e22     	b.hs	0x1fa8 <___pl_fn_1+0x1e9c>
     fe8: d28000c3     	mov	x3, #0x6                ; =6
     fec: d2807d04     	mov	x4, #0x3e8              ; =1000
     ff0: aa1703e2     	mov	x2, x23
     ff4: aa1a03e0     	mov	x0, x26
     ff8: 94000000     	bl	0xff8 <___pl_fn_1+0xeec>
     ffc: aa1a03e1     	mov	x1, x26
    1000: b9402c21     	ldr	w1, [x1, #0x2c]
    1004: 3500cb21     	cbnz	w1, 0x2968 <___pl_fn_1+0x285c>
    1008: aa1a03e1     	mov	x1, x26
    100c: b9001833     	str	w19, [x1, #0x18]
    1010: 34007b20     	cbz	w0, 0x1f74 <___pl_fn_1+0x1e68>
    1014: aa1a03e1     	mov	x1, x26
    1018: b9401c21     	ldr	w1, [x1, #0x1c]
    101c: 6b0102df     	cmp	w22, w1
    1020: 54007908     	b.hi	0x1f40 <___pl_fn_1+0x1e34>
    1024: aa1a03e1     	mov	x1, x26
    1028: f9401022     	ldr	x2, [x1, #0x20]
    102c: 8b140841     	add	x1, x2, x20, lsl #2
    1030: f94087e3     	ldr	x3, [sp, #0x108]
    1034: b8335843     	str	w3, [x2, w19, uxtw #2]
    1038: f94083e5     	ldr	x5, [sp, #0x100]
    103c: b9000425     	str	w5, [x1, #0x4]
    1040: b900083c     	str	w28, [x1, #0x8]
    1044: b9000c20     	str	w0, [x1, #0xc]
    1048: aa0003f5     	mov	x21, x0
    104c: aa1a03e0     	mov	x0, x26
    1050: b9001816     	str	w22, [x0, #0x18]
    1054: 52800aa1     	mov	w1, #0x55               ; =85
    1058: 52800082     	mov	w2, #0x4                ; =4
    105c: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xef4>
    1060: f9400063     	ldr	x3, [x3]
    1064: d63f0060     	blr	x3
    1068: 3500c800     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
    106c: aa1a03e0     	mov	x0, x26
    1070: f9401814     	ldr	x20, [x0, #0x30]
    1074: b9001813     	str	w19, [x0, #0x18]
    1078: 340074b4     	cbz	w20, 0x1f0c <___pl_fn_1+0x1e00>
    107c: 35000094     	cbnz	w20, 0x108c <___pl_fn_1+0xf80>
    1080: 14000267     	b	0x1a1c <___pl_fn_1+0x1910>
    1084: aa1403f3     	mov	x19, x20
    1088: 1400000d     	b	0x10bc <___pl_fn_1+0xfb0>
    108c: aa1a03e0     	mov	x0, x26
    1090: f9400001     	ldr	x1, [x0]
    1094: aa1403f3     	mov	x19, x20
    1098: 2a1303e0     	mov	w0, w19
    109c: 8b000c20     	add	x0, x1, x0, lsl #3
    10a0: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    10a4: f94083e5     	ldr	x5, [sp, #0x100]
    10a8: 2a0503e1     	mov	w1, w5
    10ac: d360fc42     	lsr	x2, x2, #32
    10b0: 92403c42     	and	x2, x2, #0xffff
    10b4: 91002042     	add	x2, x2, #0x8
    10b8: f8227801     	str	x1, [x0, x2, lsl #3]
    10bc: 350000b3     	cbnz	w19, 0x10d0 <___pl_fn_1+0xfc4>
    10c0: 14000265     	b	0x1a54 <___pl_fn_1+0x1948>
    10c4: aa1a03e0     	mov	x0, x26
    10c8: aa1403e1     	mov	x1, x20
    10cc: 1400000f     	b	0x1108 <___pl_fn_1+0xffc>
    10d0: aa1a03e0     	mov	x0, x26
    10d4: aa1303f4     	mov	x20, x19
    10d8: f9400002     	ldr	x2, [x0]
    10dc: aa1403e1     	mov	x1, x20
    10e0: 2a0103e0     	mov	w0, w1
    10e4: 8b000c40     	add	x0, x2, x0, lsl #3
    10e8: f8615843     	ldr	x3, [x2, w1, uxtw #3]
    10ec: f94083e5     	ldr	x5, [sp, #0x100]
    10f0: 2a0503e2     	mov	w2, w5
    10f4: d360fc63     	lsr	x3, x3, #32
    10f8: 92403c63     	and	x3, x3, #0xffff
    10fc: 91002463     	add	x3, x3, #0x9
    1100: f8237802     	str	x2, [x0, x3, lsl #3]
    1104: aa1a03e0     	mov	x0, x26
    1108: aa1a03e0     	mov	x0, x26
    110c: b9401813     	ldr	w19, [x0, #0x18]
    1110: b9401c02     	ldr	w2, [x0, #0x1c]
    1114: 11001660     	add	w0, w19, #0x5
    1118: 6b02001f     	cmp	w0, w2
    111c: 54006de8     	b.hi	0x1ed8 <___pl_fn_1+0x1dcc>
    1120: aa1a03e2     	mov	x2, x26
    1124: f9401043     	ldr	x3, [x2, #0x20]
    1128: 2a1303f4     	mov	w20, w19
    112c: 8b140862     	add	x2, x3, x20, lsl #2
    1130: f94087e4     	ldr	x4, [sp, #0x108]
    1134: b8335864     	str	w4, [x3, w19, uxtw #2]
    1138: f94083e5     	ldr	x5, [sp, #0x100]
    113c: b9000445     	str	w5, [x2, #0x4]
    1140: b900085c     	str	w28, [x2, #0x8]
    1144: aa1503e9     	mov	x9, x21
    1148: b9000c49     	str	w9, [x2, #0xc]
    114c: b9001041     	str	w1, [x2, #0x10]
    1150: aa1a03eb     	mov	x11, x26
    1154: b9001960     	str	w0, [x11, #0x18]
    1158: aa1a03e0     	mov	x0, x26
    115c: b9401002     	ldr	w2, [x0, #0x10]
    1160: b9401403     	ldr	w3, [x0, #0x14]
    1164: 6b03005f     	cmp	w2, w3
    1168: 540069e2     	b.hs	0x1ea4 <___pl_fn_1+0x1d98>
    116c: d2800083     	mov	x3, #0x4                ; =4
    1170: d2817704     	mov	x4, #0xbb8              ; =3000
    1174: 52800027     	mov	w7, #0x1                ; =1
    1178: aa1503e5     	mov	x5, x21
    117c: aa1a03e0     	mov	x0, x26
    1180: f94087e2     	ldr	x2, [sp, #0x108]
    1184: aa0703e6     	mov	x6, x7
    1188: 94000000     	bl	0x1188 <___pl_fn_1+0x107c>
    118c: aa1a03e0     	mov	x0, x26
    1190: b9402c04     	ldr	w4, [x0, #0x2c]
    1194: 3500bea4     	cbnz	w4, 0x2968 <___pl_fn_1+0x285c>
    1198: aa1a03e0     	mov	x0, x26
    119c: b9001813     	str	w19, [x0, #0x18]
    11a0: b9401c08     	ldr	w8, [x0, #0x1c]
    11a4: 11000e67     	add	w7, w19, #0x3
    11a8: 6b0800ff     	cmp	w7, w8
    11ac: 54006628     	b.hi	0x1e70 <___pl_fn_1+0x1d64>
    11b0: aa1a03e0     	mov	x0, x26
    11b4: f940100a     	ldr	x10, [x0, #0x20]
    11b8: 8b140949     	add	x9, x10, x20, lsl #2
    11bc: f94087e2     	ldr	x2, [sp, #0x108]
    11c0: b8335942     	str	w2, [x10, w19, uxtw #2]
    11c4: f94083e5     	ldr	x5, [sp, #0x100]
    11c8: b9000525     	str	w5, [x9, #0x4]
    11cc: b900093c     	str	w28, [x9, #0x8]
    11d0: b9001807     	str	w7, [x0, #0x18]
    11d4: 52800b81     	mov	w1, #0x5c               ; =92
    11d8: 52800062     	mov	w2, #0x3                ; =3
    11dc: 9000000d     	adrp	x13, 0x1000 <___pl_fn_1+0xef4>
    11e0: f94001ad     	ldr	x13, [x13]
    11e4: d63f01a0     	blr	x13
    11e8: 3500bc00     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
    11ec: aa1a03e0     	mov	x0, x26
    11f0: f9401814     	ldr	x20, [x0, #0x30]
    11f4: b9001813     	str	w19, [x0, #0x18]
    11f8: 34006234     	cbz	w20, 0x1e3c <___pl_fn_1+0x1d30>
    11fc: 350000b4     	cbnz	w20, 0x1210 <___pl_fn_1+0x1104>
    1200: 14000224     	b	0x1a90 <___pl_fn_1+0x1984>
    1204: aa1a03e0     	mov	x0, x26
    1208: aa1403e1     	mov	x1, x20
    120c: 1400000e     	b	0x1244 <___pl_fn_1+0x1138>
    1210: aa1a03e0     	mov	x0, x26
    1214: f9400002     	ldr	x2, [x0]
    1218: aa1403e1     	mov	x1, x20
    121c: 2a0103e0     	mov	w0, w1
    1220: 8b000c40     	add	x0, x2, x0, lsl #3
    1224: f8615843     	ldr	x3, [x2, w1, uxtw #3]
    1228: f94083e5     	ldr	x5, [sp, #0x100]
    122c: 2a0503e2     	mov	w2, w5
    1230: d360fc63     	lsr	x3, x3, #32
    1234: 92403c63     	and	x3, x3, #0xffff
    1238: 91002063     	add	x3, x3, #0x8
    123c: f8237802     	str	x2, [x0, x3, lsl #3]
    1240: aa1a03e0     	mov	x0, x26
    1244: aa1a03e0     	mov	x0, x26
    1248: b9401819     	ldr	w25, [x0, #0x18]
    124c: b9401c02     	ldr	w2, [x0, #0x1c]
    1250: 11001320     	add	w0, w25, #0x4
    1254: 6b02001f     	cmp	w0, w2
    1258: 54005d88     	b.hi	0x1e08 <___pl_fn_1+0x1cfc>
    125c: aa1a03e2     	mov	x2, x26
    1260: f9401043     	ldr	x3, [x2, #0x20]
    1264: 2a1903fb     	mov	w27, w25
    1268: 8b1b0862     	add	x2, x3, x27, lsl #2
    126c: f94087e4     	ldr	x4, [sp, #0x108]
    1270: b8395864     	str	w4, [x3, w25, uxtw #2]
    1274: f94083e5     	ldr	x5, [sp, #0x100]
    1278: b9000445     	str	w5, [x2, #0x4]
    127c: b900085c     	str	w28, [x2, #0x8]
    1280: b9000c41     	str	w1, [x2, #0xc]
    1284: aa1a03e2     	mov	x2, x26
    1288: b9001840     	str	w0, [x2, #0x18]
    128c: aa1a03e0     	mov	x0, x26
    1290: b9401000     	ldr	w0, [x0, #0x10]
    1294: b9401442     	ldr	w2, [x2, #0x14]
    1298: 6b02001f     	cmp	w0, w2
    129c: 540059c2     	b.hs	0x1dd4 <___pl_fn_1+0x1cc8>
    12a0: d28000a3     	mov	x3, #0x5                ; =5
    12a4: d281f404     	mov	x4, #0xfa0              ; =4000
    12a8: 52800006     	mov	w6, #0x0                ; =0
    12ac: 52800027     	mov	w7, #0x1                ; =1
    12b0: aa1a03e0     	mov	x0, x26
    12b4: f94087e2     	ldr	x2, [sp, #0x108]
    12b8: f94083e5     	ldr	x5, [sp, #0x100]
    12bc: 94000000     	bl	0x12bc <___pl_fn_1+0x11b0>
    12c0: aa1a03e0     	mov	x0, x26
    12c4: b9402c00     	ldr	w0, [x0, #0x2c]
    12c8: 3500b500     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
    12cc: aa1a03e0     	mov	x0, x26
    12d0: b9001819     	str	w25, [x0, #0x18]
    12d4: b9401c01     	ldr	w1, [x0, #0x1c]
    12d8: 11000f20     	add	w0, w25, #0x3
    12dc: 6b01001f     	cmp	w0, w1
    12e0: 54005608     	b.hi	0x1da0 <___pl_fn_1+0x1c94>
    12e4: aa1a03e1     	mov	x1, x26
    12e8: f9401022     	ldr	x2, [x1, #0x20]
    12ec: 8b1b0841     	add	x1, x2, x27, lsl #2
    12f0: f94087ec     	ldr	x12, [sp, #0x108]
    12f4: b839584c     	str	w12, [x2, w25, uxtw #2]
    12f8: f94083e5     	ldr	x5, [sp, #0x100]
    12fc: b9000425     	str	w5, [x1, #0x4]
    1300: b900083c     	str	w28, [x1, #0x8]
    1304: aa1a03e1     	mov	x1, x26
    1308: b9001820     	str	w0, [x1, #0x18]
    130c: 52800c41     	mov	w1, #0x62               ; =98
    1310: 52800062     	mov	w2, #0x3                ; =3
    1314: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xef4>
    1318: f9400063     	ldr	x3, [x3]
    131c: aa1a03e0     	mov	x0, x26
    1320: d63f0060     	blr	x3
    1324: 3500b220     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
    1328: aa1a03e0     	mov	x0, x26
    132c: f9401813     	ldr	x19, [x0, #0x30]
    1330: b9001819     	str	w25, [x0, #0x18]
    1334: 340051d3     	cbz	w19, 0x1d6c <___pl_fn_1+0x1c60>
    1338: 350000b3     	cbnz	w19, 0x134c <___pl_fn_1+0x1240>
    133c: 140001e3     	b	0x1ac8 <___pl_fn_1+0x19bc>
    1340: aa1a03e0     	mov	x0, x26
    1344: aa1303e1     	mov	x1, x19
    1348: 1400000e     	b	0x1380 <___pl_fn_1+0x1274>
    134c: aa1a03e0     	mov	x0, x26
    1350: f9400002     	ldr	x2, [x0]
    1354: aa1303e1     	mov	x1, x19
    1358: 2a0103e0     	mov	w0, w1
    135c: 8b000c40     	add	x0, x2, x0, lsl #3
    1360: f8615843     	ldr	x3, [x2, w1, uxtw #3]
    1364: f94083e5     	ldr	x5, [sp, #0x100]
    1368: 2a0503e2     	mov	w2, w5
    136c: d360fc63     	lsr	x3, x3, #32
    1370: 92403c63     	and	x3, x3, #0xffff
    1374: 91002063     	add	x3, x3, #0x8
    1378: f8237802     	str	x2, [x0, x3, lsl #3]
    137c: aa1a03e0     	mov	x0, x26
    1380: aa1a03e0     	mov	x0, x26
    1384: b9401813     	ldr	w19, [x0, #0x18]
    1388: b9401c02     	ldr	w2, [x0, #0x1c]
    138c: 11001260     	add	w0, w19, #0x4
    1390: 6b02001f     	cmp	w0, w2
    1394: 54004d28     	b.hi	0x1d38 <___pl_fn_1+0x1c2c>
    1398: aa1a03e2     	mov	x2, x26
    139c: f9401043     	ldr	x3, [x2, #0x20]
    13a0: 2a1303e2     	mov	w2, w19
    13a4: 8b020862     	add	x2, x3, x2, lsl #2
    13a8: f94087e4     	ldr	x4, [sp, #0x108]
    13ac: b8335864     	str	w4, [x3, w19, uxtw #2]
    13b0: f94083e5     	ldr	x5, [sp, #0x100]
    13b4: b9000445     	str	w5, [x2, #0x4]
    13b8: b900085c     	str	w28, [x2, #0x8]
    13bc: b9000c41     	str	w1, [x2, #0xc]
    13c0: aa1a03e2     	mov	x2, x26
    13c4: b9001840     	str	w0, [x2, #0x18]
    13c8: aa1a03e0     	mov	x0, x26
    13cc: b9401000     	ldr	w0, [x0, #0x10]
    13d0: b9401442     	ldr	w2, [x2, #0x14]
    13d4: 6b02001f     	cmp	w0, w2
    13d8: 54004962     	b.hs	0x1d04 <___pl_fn_1+0x1bf8>
    13dc: d28000c3     	mov	x3, #0x6                ; =6
    13e0: d2827104     	mov	x4, #0x1388             ; =5000
    13e4: 52800006     	mov	w6, #0x0                ; =0
    13e8: 52800027     	mov	w7, #0x1                ; =1
    13ec: f94083e5     	ldr	x5, [sp, #0x100]
    13f0: aa1a03e0     	mov	x0, x26
    13f4: f94087e2     	ldr	x2, [sp, #0x108]
    13f8: 94000000     	bl	0x13f8 <___pl_fn_1+0x12ec>
    13fc: aa1a03e0     	mov	x0, x26
    1400: b9402c03     	ldr	w3, [x0, #0x2c]
    1404: 3500ab23     	cbnz	w3, 0x2968 <___pl_fn_1+0x285c>
    1408: aa1a03e0     	mov	x0, x26
    140c: b9001813     	str	w19, [x0, #0x18]
    1410: f94087e2     	ldr	x2, [sp, #0x108]
    1414: 34003762     	cbz	w2, 0x1b00 <___pl_fn_1+0x19f4>
    1418: aa1a03e0     	mov	x0, x26
    141c: f9400009     	ldr	x9, [x0]
    1420: f94087e2     	ldr	x2, [sp, #0x108]
    1424: 2a0203e8     	mov	w8, w2
    1428: 8b080d28     	add	x8, x9, x8, lsl #3
    142c: f8625929     	ldr	x9, [x9, w2, uxtw #3]
    1430: d360fd29     	lsr	x9, x9, #32
    1434: 92403d29     	and	x9, x9, #0xffff
    1438: d37df129     	lsl	x9, x9, #3
    143c: b8696900     	ldr	w0, [x8, x9]
    1440: 35000080     	cbnz	w0, 0x1450 <___pl_fn_1+0x1344>
    1444: 140001af     	b	0x1b00 <___pl_fn_1+0x19f4>
    1448: aa1a03e0     	mov	x0, x26
    144c: f9401800     	ldr	x0, [x0, #0x30]
    1450: 34004400     	cbz	w0, 0x1cd0 <___pl_fn_1+0x1bc4>
    1454: aa0003f3     	mov	x19, x0
    1458: 6b1c027f     	cmp	w19, w28
    145c: 54000ae1     	b.ne	0x15b8 <___pl_fn_1+0x14ac>
    1460: f94087e2     	ldr	x2, [sp, #0x108]
    1464: 34003602     	cbz	w2, 0x1b24 <___pl_fn_1+0x1a18>
    1468: aa1a03e0     	mov	x0, x26
    146c: f9400001     	ldr	x1, [x0]
    1470: f94087e2     	ldr	x2, [sp, #0x108]
    1474: 2a0203e0     	mov	w0, w2
    1478: 8b000c20     	add	x0, x1, x0, lsl #3
    147c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    1480: d360fc21     	lsr	x1, x1, #32
    1484: 92403c21     	and	x1, x1, #0xffff
    1488: 91002822     	add	x2, x1, #0xa
    148c: f8627802     	ldr	x2, [x0, x2, lsl #3]
    1490: f100083f     	cmp	x1, #0x2
    1494: 54000061     	b.ne	0x14a0 <___pl_fn_1+0x1394>
    1498: aa0203f3     	mov	x19, x2
    149c: 1400000a     	b	0x14c4 <___pl_fn_1+0x13b8>
    14a0: f9400800     	ldr	x0, [x0, #0x10]
    14a4: 37503400     	tbnz	w0, #0xa, 0x1b24 <___pl_fn_1+0x1a18>
    14a8: aa0203f3     	mov	x19, x2
    14ac: 14000006     	b	0x14c4 <___pl_fn_1+0x13b8>
    14b0: aa1a03e0     	mov	x0, x26
    14b4: f9401802     	ldr	x2, [x0, #0x30]
    14b8: aa0203f3     	mov	x19, x2
    14bc: f94087e2     	ldr	x2, [sp, #0x108]
    14c0: 14000002     	b	0x14c8 <___pl_fn_1+0x13bc>
    14c4: f94087e2     	ldr	x2, [sp, #0x108]
    14c8: f94087e2     	ldr	x2, [sp, #0x108]
    14cc: 340033e2     	cbz	w2, 0x1b48 <___pl_fn_1+0x1a3c>
    14d0: aa1a03e0     	mov	x0, x26
    14d4: f9400001     	ldr	x1, [x0]
    14d8: f94087e2     	ldr	x2, [sp, #0x108]
    14dc: 2a0203e0     	mov	w0, w2
    14e0: 8b000c20     	add	x0, x1, x0, lsl #3
    14e4: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    14e8: d360fc21     	lsr	x1, x1, #32
    14ec: 92403c21     	and	x1, x1, #0xffff
    14f0: 91002422     	add	x2, x1, #0x9
    14f4: f8627802     	ldr	x2, [x0, x2, lsl #3]
    14f8: f100083f     	cmp	x1, #0x2
    14fc: 54000061     	b.ne	0x1508 <___pl_fn_1+0x13fc>
    1500: aa0203f4     	mov	x20, x2
    1504: 14000008     	b	0x1524 <___pl_fn_1+0x1418>
    1508: f9400800     	ldr	x0, [x0, #0x10]
    150c: 374831e0     	tbnz	w0, #0x9, 0x1b48 <___pl_fn_1+0x1a3c>
    1510: aa0203f4     	mov	x20, x2
    1514: 14000004     	b	0x1524 <___pl_fn_1+0x1418>
    1518: aa1a03e0     	mov	x0, x26
    151c: f9401802     	ldr	x2, [x0, #0x30]
    1520: aa0203f4     	mov	x20, x2
    1524: 52800d61     	mov	w1, #0x6b               ; =107
    1528: 52800003     	mov	w3, #0x0                ; =0
    152c: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1530: f9400084     	ldr	x4, [x4]
    1534: aa1303e2     	mov	x2, x19
    1538: aa1a03e0     	mov	x0, x26
    153c: d63f0080     	blr	x4
    1540: 3500a140     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
    1544: 52800d81     	mov	w1, #0x6c               ; =108
    1548: d2800402     	mov	x2, #0x20               ; =32
    154c: 52800063     	mov	w3, #0x3                ; =3
    1550: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1554: f9400084     	ldr	x4, [x4]
    1558: aa1a03e0     	mov	x0, x26
    155c: d63f0080     	blr	x4
    1560: 3500a040     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
    1564: 52800da1     	mov	w1, #0x6d               ; =109
    1568: 52802003     	mov	w3, #0x100              ; =256
    156c: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1570: f9400084     	ldr	x4, [x4]
    1574: aa1403e2     	mov	x2, x20
    1578: aa1a03e0     	mov	x0, x26
    157c: d63f0080     	blr	x4
    1580: 35009f40     	cbnz	w0, 0x2968 <___pl_fn_1+0x285c>
    1584: aa1a03e0     	mov	x0, x26
    1588: b9401000     	ldr	w0, [x0, #0x10]
    158c: 51000400     	sub	w0, w0, #0x1
    1590: aa1a03e1     	mov	x1, x26
    1594: b9001020     	str	w0, [x1, #0x10]
    1598: 910443ff     	add	sp, sp, #0x110
    159c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    15a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    15a4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    15a8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    15ac: a8c173fb     	ldp	x27, x28, [sp], #0x10
    15b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    15b4: d65f03c0     	ret
    15b8: 34002db3     	cbz	w19, 0x1b6c <___pl_fn_1+0x1a60>
    15bc: aa1a03e0     	mov	x0, x26
    15c0: f9400001     	ldr	x1, [x0]
    15c4: 2a1303e0     	mov	w0, w19
    15c8: 8b000c20     	add	x0, x1, x0, lsl #3
    15cc: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    15d0: d360fc21     	lsr	x1, x1, #32
    15d4: 92403c21     	and	x1, x1, #0xffff
    15d8: 91001821     	add	x1, x1, #0x6
    15dc: d37df021     	lsl	x1, x1, #3
    15e0: 38616800     	ldrb	w0, [x0, x1]
    15e4: 53001c01     	uxtb	w1, w0
    15e8: 7100083f     	cmp	w1, #0x2
    15ec: 540000a1     	b.ne	0x1600 <___pl_fn_1+0x14f4>
    15f0: 1400015f     	b	0x1b6c <___pl_fn_1+0x1a60>
    15f4: aa1a03e0     	mov	x0, x26
    15f8: f9401800     	ldr	x0, [x0, #0x30]
    15fc: 14000002     	b	0x1604 <___pl_fn_1+0x14f8>
    1600: aa1303f6     	mov	x22, x19
    1604: 72001c1f     	tst	w0, #0xff
    1608: 540005c1     	b.ne	0x16c0 <___pl_fn_1+0x15b4>
    160c: aa1603e1     	mov	x1, x22
    1610: 34002c21     	cbz	w1, 0x1b94 <___pl_fn_1+0x1a88>
    1614: aa1a03e0     	mov	x0, x26
    1618: f9400001     	ldr	x1, [x0]
    161c: aa1603e0     	mov	x0, x22
    1620: 2a0003e0     	mov	w0, w0
    1624: 8b000c20     	add	x0, x1, x0, lsl #3
    1628: aa1603e2     	mov	x2, x22
    162c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    1630: d360fc21     	lsr	x1, x1, #32
    1634: 92403c21     	and	x1, x1, #0xffff
    1638: 91001021     	add	x1, x1, #0x4
    163c: d37df021     	lsl	x1, x1, #3
    1640: 38616801     	ldrb	w1, [x0, x1]
    1644: 53001c20     	uxtb	w0, w1
    1648: 7100081f     	cmp	w0, #0x2
    164c: 54000081     	b.ne	0x165c <___pl_fn_1+0x1550>
    1650: 14000151     	b	0x1b94 <___pl_fn_1+0x1a88>
    1654: aa1a03e0     	mov	x0, x26
    1658: f9401801     	ldr	x1, [x0, #0x30]
    165c: 52000027     	eor	w7, w1, #0x1
    1660: 72001cff     	tst	w7, #0xff
    1664: 54000061     	b.ne	0x1670 <___pl_fn_1+0x1564>
    1668: 52800000     	mov	w0, #0x0                ; =0
    166c: 14000016     	b	0x16c4 <___pl_fn_1+0x15b8>
    1670: aa1603e1     	mov	x1, x22
    1674: 34002a21     	cbz	w1, 0x1bb8 <___pl_fn_1+0x1aac>
    1678: aa1a03e0     	mov	x0, x26
    167c: f940000d     	ldr	x13, [x0]
    1680: aa1603e1     	mov	x1, x22
    1684: 2a0103ec     	mov	w12, w1
    1688: 8b0c0dac     	add	x12, x13, x12, lsl #3
    168c: f86159ad     	ldr	x13, [x13, w1, uxtw #3]
    1690: d360fdad     	lsr	x13, x13, #32
    1694: 92403dad     	and	x13, x13, #0xffff
    1698: 910015ad     	add	x13, x13, #0x5
    169c: d37df1ad     	lsl	x13, x13, #3
    16a0: 386d6980     	ldrb	w0, [x12, x13]
    16a4: 53001c0c     	uxtb	w12, w0
    16a8: 7100099f     	cmp	w12, #0x2
    16ac: 540000c1     	b.ne	0x16c4 <___pl_fn_1+0x15b8>
    16b0: 14000142     	b	0x1bb8 <___pl_fn_1+0x1aac>
    16b4: aa1a03e0     	mov	x0, x26
    16b8: f9401800     	ldr	x0, [x0, #0x30]
    16bc: 14000002     	b	0x16c4 <___pl_fn_1+0x15b8>
    16c0: 52800020     	mov	w0, #0x1                ; =1
    16c4: 72001c1f     	tst	w0, #0xff
    16c8: 54000421     	b.ne	0x174c <___pl_fn_1+0x1640>
    16cc: aa1a03e0     	mov	x0, x26
    16d0: b9401818     	ldr	w24, [x0, #0x18]
    16d4: b9401c01     	ldr	w1, [x0, #0x1c]
    16d8: 11000f00     	add	w0, w24, #0x3
    16dc: 6b01001f     	cmp	w0, w1
    16e0: 54002b28     	b.hi	0x1c44 <___pl_fn_1+0x1b38>
    16e4: aa1a03e1     	mov	x1, x26
    16e8: f9401021     	ldr	x1, [x1, #0x20]
    16ec: 2a1803e2     	mov	w2, w24
    16f0: 8b020822     	add	x2, x1, x2, lsl #2
    16f4: f94087e3     	ldr	x3, [sp, #0x108]
    16f8: b8385823     	str	w3, [x1, w24, uxtw #2]
    16fc: b900045c     	str	w28, [x2, #0x4]
    1700: aa1603e1     	mov	x1, x22
    1704: b9000841     	str	w1, [x2, #0x8]
    1708: aa1a03e1     	mov	x1, x26
    170c: b9001820     	str	w0, [x1, #0x18]
    1710: aa1a03e0     	mov	x0, x26
    1714: b9401000     	ldr	w0, [x0, #0x10]
    1718: b9401421     	ldr	w1, [x1, #0x14]
    171c: 6b01001f     	cmp	w0, w1
    1720: 54002782     	b.hs	0x1c10 <___pl_fn_1+0x1b04>
    1724: aa1603e1     	mov	x1, x22
    1728: aa1a03e0     	mov	x0, x26
    172c: 94000000     	bl	0x172c <___pl_fn_1+0x1620>
    1730: aa1a03e1     	mov	x1, x26
    1734: b9402c21     	ldr	w1, [x1, #0x2c]
    1738: 35009181     	cbnz	w1, 0x2968 <___pl_fn_1+0x285c>
    173c: aa1a03e1     	mov	x1, x26
    1740: b9001838     	str	w24, [x1, #0x18]
    1744: 340024c0     	cbz	w0, 0x1bdc <___pl_fn_1+0x1ad0>
    1748: 14000013     	b	0x1794 <___pl_fn_1+0x1688>
    174c: aa1603e1     	mov	x1, x22
    1750: 34002941     	cbz	w1, 0x1c78 <___pl_fn_1+0x1b6c>
    1754: aa1a03e0     	mov	x0, x26
    1758: f9400001     	ldr	x1, [x0]
    175c: aa1603e0     	mov	x0, x22
    1760: 2a0003e0     	mov	w0, w0
    1764: 8b000c20     	add	x0, x1, x0, lsl #3
    1768: aa1603e2     	mov	x2, x22
    176c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    1770: d360fc21     	lsr	x1, x1, #32
    1774: 92403c21     	and	x1, x1, #0xffff
    1778: d37df021     	lsl	x1, x1, #3
    177c: b8616800     	ldr	w0, [x0, x1]
    1780: 35000080     	cbnz	w0, 0x1790 <___pl_fn_1+0x1684>
    1784: 1400013d     	b	0x1c78 <___pl_fn_1+0x1b6c>
    1788: aa1a03e0     	mov	x0, x26
    178c: f9401800     	ldr	x0, [x0, #0x30]
    1790: 34002860     	cbz	w0, 0x1c9c <___pl_fn_1+0x1b90>
    1794: aa0003f3     	mov	x19, x0
    1798: 17ffff30     	b	0x1458 <___pl_fn_1+0x134c>
    179c: d280000e     	mov	x14, #0x0               ; =0
    17a0: 910003e3     	mov	x3, sp
    17a4: f80003ee     	stur	x14, [sp]
    17a8: 2a1503ef     	mov	w15, w21
    17ac: f80083ef     	stur	x15, [sp, #0x8]
    17b0: 528001c1     	mov	w1, #0xe                ; =14
    17b4: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    17b8: f9400084     	ldr	x4, [x4]
    17bc: aa1a03e0     	mov	x0, x26
    17c0: aa1503e2     	mov	x2, x21
    17c4: d63f0080     	blr	x4
    17c8: f90083f5     	str	x21, [sp, #0x100]
    17cc: 34ff50a0     	cbz	w0, 0x1e0 <___pl_fn_1+0xd4>
    17d0: 14000466     	b	0x2968 <___pl_fn_1+0x285c>
    17d4: d2800040     	mov	x0, #0x2                ; =2
    17d8: 910043e3     	add	x3, sp, #0x10
    17dc: f80103e0     	stur	x0, [sp, #0x10]
    17e0: f94083e5     	ldr	x5, [sp, #0x100]
    17e4: 2a0503e0     	mov	w0, w5
    17e8: f80183e0     	stur	x0, [sp, #0x18]
    17ec: 52800241     	mov	w1, #0x12               ; =18
    17f0: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    17f4: f9400084     	ldr	x4, [x4]
    17f8: aa1a03e0     	mov	x0, x26
    17fc: f94087e2     	ldr	x2, [sp, #0x108]
    1800: d63f0080     	blr	x4
    1804: 34ff5480     	cbz	w0, 0x294 <___pl_fn_1+0x188>
    1808: 14000458     	b	0x2968 <___pl_fn_1+0x285c>
    180c: d2800020     	mov	x0, #0x1                ; =1
    1810: 910083e3     	add	x3, sp, #0x20
    1814: f80203e0     	stur	x0, [sp, #0x20]
    1818: 2a1c03e0     	mov	w0, w28
    181c: f80283e0     	stur	x0, [sp, #0x28]
    1820: 52800261     	mov	w1, #0x13               ; =19
    1824: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1828: f9400084     	ldr	x4, [x4]
    182c: aa1a03e0     	mov	x0, x26
    1830: f94087e2     	ldr	x2, [sp, #0x108]
    1834: d63f0080     	blr	x4
    1838: 34ff5520     	cbz	w0, 0x2dc <___pl_fn_1+0x1d0>
    183c: 1400044b     	b	0x2968 <___pl_fn_1+0x285c>
    1840: d2800000     	mov	x0, #0x0                ; =0
    1844: 9100c3e3     	add	x3, sp, #0x30
    1848: f80303e0     	stur	x0, [sp, #0x30]
    184c: 2a1c03e0     	mov	w0, w28
    1850: f80383e0     	stur	x0, [sp, #0x38]
    1854: 52800281     	mov	w1, #0x14               ; =20
    1858: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    185c: f9400084     	ldr	x4, [x4]
    1860: aa1a03e0     	mov	x0, x26
    1864: f94087e2     	ldr	x2, [sp, #0x108]
    1868: d63f0080     	blr	x4
    186c: 34ff55a0     	cbz	w0, 0x320 <___pl_fn_1+0x214>
    1870: 1400043e     	b	0x2968 <___pl_fn_1+0x285c>
    1874: d2800120     	mov	x0, #0x9                ; =9
    1878: 910103e3     	add	x3, sp, #0x40
    187c: f80403e0     	stur	x0, [sp, #0x40]
    1880: d2800000     	mov	x0, #0x0                ; =0
    1884: f80483e0     	stur	x0, [sp, #0x48]
    1888: 528002a1     	mov	w1, #0x15               ; =21
    188c: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1890: f9400084     	ldr	x4, [x4]
    1894: aa1a03e0     	mov	x0, x26
    1898: f94087e2     	ldr	x2, [sp, #0x108]
    189c: d63f0080     	blr	x4
    18a0: 34ff5600     	cbz	w0, 0x360 <___pl_fn_1+0x254>
    18a4: 14000431     	b	0x2968 <___pl_fn_1+0x285c>
    18a8: d2800145     	mov	x5, #0xa                ; =10
    18ac: 910143e3     	add	x3, sp, #0x50
    18b0: f80503e5     	stur	x5, [sp, #0x50]
    18b4: d2800006     	mov	x6, #0x0                ; =0
    18b8: f80583e6     	stur	x6, [sp, #0x58]
    18bc: 528002c1     	mov	w1, #0x16               ; =22
    18c0: 90000007     	adrp	x7, 0x1000 <___pl_fn_1+0xef4>
    18c4: f94000e7     	ldr	x7, [x7]
    18c8: aa1a03e0     	mov	x0, x26
    18cc: f94087e2     	ldr	x2, [sp, #0x108]
    18d0: d63f00e0     	blr	x7
    18d4: 34ff5740     	cbz	w0, 0x3bc <___pl_fn_1+0x2b0>
    18d8: 14000424     	b	0x2968 <___pl_fn_1+0x285c>
    18dc: d2800100     	mov	x0, #0x8                ; =8
    18e0: 910183e3     	add	x3, sp, #0x60
    18e4: f80603e0     	stur	x0, [sp, #0x60]
    18e8: d2800020     	mov	x0, #0x1                ; =1
    18ec: f80683e0     	stur	x0, [sp, #0x68]
    18f0: 52800341     	mov	w1, #0x1a               ; =26
    18f4: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    18f8: f9400084     	ldr	x4, [x4]
    18fc: aa1a03e0     	mov	x0, x26
    1900: aa1903e2     	mov	x2, x25
    1904: d63f0080     	blr	x4
    1908: 34ff5c00     	cbz	w0, 0x488 <___pl_fn_1+0x37c>
    190c: 14000417     	b	0x2968 <___pl_fn_1+0x285c>
    1910: d2800120     	mov	x0, #0x9                ; =9
    1914: 9101c3e3     	add	x3, sp, #0x70
    1918: f80703e0     	stur	x0, [sp, #0x70]
    191c: f80783f3     	stur	x19, [sp, #0x78]
    1920: 52800361     	mov	w1, #0x1b               ; =27
    1924: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1928: f9400084     	ldr	x4, [x4]
    192c: aa1a03e0     	mov	x0, x26
    1930: aa1403e2     	mov	x2, x20
    1934: d63f0080     	blr	x4
    1938: aa1403f9     	mov	x25, x20
    193c: 34ff5d00     	cbz	w0, 0x4dc <___pl_fn_1+0x3d0>
    1940: 1400040a     	b	0x2968 <___pl_fn_1+0x285c>
    1944: d2800100     	mov	x0, #0x8                ; =8
    1948: 910203e3     	add	x3, sp, #0x80
    194c: f80803e0     	stur	x0, [sp, #0x80]
    1950: d2800060     	mov	x0, #0x3                ; =3
    1954: f80883e0     	stur	x0, [sp, #0x88]
    1958: 52800561     	mov	w1, #0x2b               ; =43
    195c: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1960: f9400084     	ldr	x4, [x4]
    1964: aa1a03e0     	mov	x0, x26
    1968: aa1403e2     	mov	x2, x20
    196c: d63f0080     	blr	x4
    1970: 34ff7560     	cbz	w0, 0x81c <___pl_fn_1+0x710>
    1974: 140003fd     	b	0x2968 <___pl_fn_1+0x285c>
    1978: d280012b     	mov	x11, #0x9               ; =9
    197c: 910243e3     	add	x3, sp, #0x90
    1980: f80903eb     	stur	x11, [sp, #0x90]
    1984: f80983f5     	stur	x21, [sp, #0x98]
    1988: 52800581     	mov	w1, #0x2c               ; =44
    198c: 9000000d     	adrp	x13, 0x1000 <___pl_fn_1+0xef4>
    1990: f94001ad     	ldr	x13, [x13]
    1994: aa1a03e0     	mov	x0, x26
    1998: aa1303e2     	mov	x2, x19
    199c: d63f01a0     	blr	x13
    19a0: aa1303f4     	mov	x20, x19
    19a4: 34ff7660     	cbz	w0, 0x870 <___pl_fn_1+0x764>
    19a8: 140003f0     	b	0x2968 <___pl_fn_1+0x285c>
    19ac: d2800100     	mov	x0, #0x8                ; =8
    19b0: 910283e3     	add	x3, sp, #0xa0
    19b4: f80a03e0     	stur	x0, [sp, #0xa0]
    19b8: f94083e5     	ldr	x5, [sp, #0x100]
    19bc: 2a0503e0     	mov	w0, w5
    19c0: f80a83e0     	stur	x0, [sp, #0xa8]
    19c4: 52800821     	mov	w1, #0x41               ; =65
    19c8: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    19cc: f9400084     	ldr	x4, [x4]
    19d0: aa1a03e0     	mov	x0, x26
    19d4: aa1303e2     	mov	x2, x19
    19d8: d63f0080     	blr	x4
    19dc: 34ff95c0     	cbz	w0, 0xc94 <___pl_fn_1+0xb88>
    19e0: 140003e2     	b	0x2968 <___pl_fn_1+0x285c>
    19e4: d2800121     	mov	x1, #0x9                ; =9
    19e8: 9102c3e3     	add	x3, sp, #0xb0
    19ec: f80b03e1     	stur	x1, [sp, #0xb0]
    19f0: f94083e5     	ldr	x5, [sp, #0x100]
    19f4: 2a0503e2     	mov	w2, w5
    19f8: f80b83e2     	stur	x2, [sp, #0xb8]
    19fc: 52800841     	mov	w1, #0x42               ; =66
    1a00: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1a04: f9400084     	ldr	x4, [x4]
    1a08: aa1a03e0     	mov	x0, x26
    1a0c: aa1303e2     	mov	x2, x19
    1a10: d63f0080     	blr	x4
    1a14: 34ff9440     	cbz	w0, 0xc9c <___pl_fn_1+0xb90>
    1a18: 140003d4     	b	0x2968 <___pl_fn_1+0x285c>
    1a1c: d2800100     	mov	x0, #0x8                ; =8
    1a20: 910303e3     	add	x3, sp, #0xc0
    1a24: f80c03e0     	stur	x0, [sp, #0xc0]
    1a28: f94083e5     	ldr	x5, [sp, #0x100]
    1a2c: 2a0503e0     	mov	w0, w5
    1a30: f80c83e0     	stur	x0, [sp, #0xc8]
    1a34: 52800ae1     	mov	w1, #0x57               ; =87
    1a38: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1a3c: f9400084     	ldr	x4, [x4]
    1a40: aa1a03e0     	mov	x0, x26
    1a44: aa1403e2     	mov	x2, x20
    1a48: d63f0080     	blr	x4
    1a4c: 34ffb1c0     	cbz	w0, 0x1084 <___pl_fn_1+0xf78>
    1a50: 140003c6     	b	0x2968 <___pl_fn_1+0x285c>
    1a54: d2800120     	mov	x0, #0x9                ; =9
    1a58: 910343e3     	add	x3, sp, #0xd0
    1a5c: f80d03e0     	stur	x0, [sp, #0xd0]
    1a60: f94083e5     	ldr	x5, [sp, #0x100]
    1a64: 2a0503e0     	mov	w0, w5
    1a68: f80d83e0     	stur	x0, [sp, #0xd8]
    1a6c: 52800b01     	mov	w1, #0x58               ; =88
    1a70: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1a74: f9400084     	ldr	x4, [x4]
    1a78: aa1a03e0     	mov	x0, x26
    1a7c: aa1303e2     	mov	x2, x19
    1a80: d63f0080     	blr	x4
    1a84: aa1303f4     	mov	x20, x19
    1a88: 34ffb1e0     	cbz	w0, 0x10c4 <___pl_fn_1+0xfb8>
    1a8c: 140003b7     	b	0x2968 <___pl_fn_1+0x285c>
    1a90: d2800100     	mov	x0, #0x8                ; =8
    1a94: 910383e3     	add	x3, sp, #0xe0
    1a98: f80e03e0     	stur	x0, [sp, #0xe0]
    1a9c: f94083e5     	ldr	x5, [sp, #0x100]
    1aa0: 2a0503e0     	mov	w0, w5
    1aa4: f80e83e0     	stur	x0, [sp, #0xe8]
    1aa8: 52800bc1     	mov	w1, #0x5e               ; =94
    1aac: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1ab0: f9400084     	ldr	x4, [x4]
    1ab4: aa1a03e0     	mov	x0, x26
    1ab8: aa1403e2     	mov	x2, x20
    1abc: d63f0080     	blr	x4
    1ac0: 34ffba20     	cbz	w0, 0x1204 <___pl_fn_1+0x10f8>
    1ac4: 140003a9     	b	0x2968 <___pl_fn_1+0x285c>
    1ac8: d2800100     	mov	x0, #0x8                ; =8
    1acc: 9103c3e3     	add	x3, sp, #0xf0
    1ad0: f80f03e0     	stur	x0, [sp, #0xf0]
    1ad4: f94083e5     	ldr	x5, [sp, #0x100]
    1ad8: 2a0503e0     	mov	w0, w5
    1adc: f80f83e0     	stur	x0, [sp, #0xf8]
    1ae0: 52800c81     	mov	w1, #0x64               ; =100
    1ae4: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1ae8: f9400084     	ldr	x4, [x4]
    1aec: aa1a03e0     	mov	x0, x26
    1af0: aa1303e2     	mov	x2, x19
    1af4: d63f0080     	blr	x4
    1af8: 34ffc240     	cbz	w0, 0x1340 <___pl_fn_1+0x1234>
    1afc: 1400039b     	b	0x2968 <___pl_fn_1+0x285c>
    1b00: 52800ce1     	mov	w1, #0x67               ; =103
    1b04: 52800003     	mov	w3, #0x0                ; =0
    1b08: 9000000a     	adrp	x10, 0x1000 <___pl_fn_1+0xef4>
    1b0c: f940014a     	ldr	x10, [x10]
    1b10: aa1a03e0     	mov	x0, x26
    1b14: f94087e2     	ldr	x2, [sp, #0x108]
    1b18: d63f0140     	blr	x10
    1b1c: 34ffc960     	cbz	w0, 0x1448 <___pl_fn_1+0x133c>
    1b20: 14000392     	b	0x2968 <___pl_fn_1+0x285c>
    1b24: 52800d21     	mov	w1, #0x69               ; =105
    1b28: 52800143     	mov	w3, #0xa                ; =10
    1b2c: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1b30: f9400084     	ldr	x4, [x4]
    1b34: aa1a03e0     	mov	x0, x26
    1b38: f94087e2     	ldr	x2, [sp, #0x108]
    1b3c: d63f0080     	blr	x4
    1b40: 34ffcb80     	cbz	w0, 0x14b0 <___pl_fn_1+0x13a4>
    1b44: 14000389     	b	0x2968 <___pl_fn_1+0x285c>
    1b48: 52800d41     	mov	w1, #0x6a               ; =106
    1b4c: 52800123     	mov	w3, #0x9                ; =9
    1b50: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1b54: f9400084     	ldr	x4, [x4]
    1b58: f94087e2     	ldr	x2, [sp, #0x108]
    1b5c: aa1a03e0     	mov	x0, x26
    1b60: d63f0080     	blr	x4
    1b64: 34ffcda0     	cbz	w0, 0x1518 <___pl_fn_1+0x140c>
    1b68: 14000380     	b	0x2968 <___pl_fn_1+0x285c>
    1b6c: 52800dc1     	mov	w1, #0x6e               ; =110
    1b70: 528000c3     	mov	w3, #0x6                ; =6
    1b74: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1b78: f9400084     	ldr	x4, [x4]
    1b7c: aa1a03e0     	mov	x0, x26
    1b80: aa1303e2     	mov	x2, x19
    1b84: d63f0080     	blr	x4
    1b88: aa1303f6     	mov	x22, x19
    1b8c: 34ffd340     	cbz	w0, 0x15f4 <___pl_fn_1+0x14e8>
    1b90: 14000376     	b	0x2968 <___pl_fn_1+0x285c>
    1b94: 52800de1     	mov	w1, #0x6f               ; =111
    1b98: 52800083     	mov	w3, #0x4                ; =4
    1b9c: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1ba0: f9400084     	ldr	x4, [x4]
    1ba4: aa1a03e0     	mov	x0, x26
    1ba8: aa1603e2     	mov	x2, x22
    1bac: d63f0080     	blr	x4
    1bb0: 34ffd520     	cbz	w0, 0x1654 <___pl_fn_1+0x1548>
    1bb4: 1400036d     	b	0x2968 <___pl_fn_1+0x285c>
    1bb8: 52800e01     	mov	w1, #0x70               ; =112
    1bbc: 528000a3     	mov	w3, #0x5                ; =5
    1bc0: 9000000f     	adrp	x15, 0x1000 <___pl_fn_1+0xef4>
    1bc4: f94001ef     	ldr	x15, [x15]
    1bc8: aa1a03e0     	mov	x0, x26
    1bcc: aa1603e2     	mov	x2, x22
    1bd0: d63f01e0     	blr	x15
    1bd4: 34ffd700     	cbz	w0, 0x16b4 <___pl_fn_1+0x15a8>
    1bd8: 14000364     	b	0x2968 <___pl_fn_1+0x285c>
    1bdc: 52800e61     	mov	w1, #0x73               ; =115
    1be0: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1be4: f9400042     	ldr	x2, [x2]
    1be8: aa1a03e0     	mov	x0, x26
    1bec: d63f0040     	blr	x2
    1bf0: 910443ff     	add	sp, sp, #0x110
    1bf4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1bf8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1bfc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1c00: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1c04: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1c08: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1c0c: d65f03c0     	ret
    1c10: 52800e41     	mov	w1, #0x72               ; =114
    1c14: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1c18: f9400042     	ldr	x2, [x2]
    1c1c: aa1a03e0     	mov	x0, x26
    1c20: d63f0040     	blr	x2
    1c24: 910443ff     	add	sp, sp, #0x110
    1c28: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1c2c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1c30: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1c34: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1c38: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1c3c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1c40: d65f03c0     	ret
    1c44: 52800e21     	mov	w1, #0x71               ; =113
    1c48: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1c4c: f9400042     	ldr	x2, [x2]
    1c50: aa1a03e0     	mov	x0, x26
    1c54: d63f0040     	blr	x2
    1c58: 910443ff     	add	sp, sp, #0x110
    1c5c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1c60: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1c64: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1c68: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1c6c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1c70: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1c74: d65f03c0     	ret
    1c78: 52800e81     	mov	w1, #0x74               ; =116
    1c7c: 52800003     	mov	w3, #0x0                ; =0
    1c80: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1c84: f9400084     	ldr	x4, [x4]
    1c88: aa1603e2     	mov	x2, x22
    1c8c: aa1a03e0     	mov	x0, x26
    1c90: d63f0080     	blr	x4
    1c94: 34ffd7a0     	cbz	w0, 0x1788 <___pl_fn_1+0x167c>
    1c98: 14000334     	b	0x2968 <___pl_fn_1+0x285c>
    1c9c: 52800ea1     	mov	w1, #0x75               ; =117
    1ca0: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1ca4: f9400042     	ldr	x2, [x2]
    1ca8: aa1a03e0     	mov	x0, x26
    1cac: d63f0040     	blr	x2
    1cb0: 910443ff     	add	sp, sp, #0x110
    1cb4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1cb8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1cbc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1cc0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1cc4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1cc8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1ccc: d65f03c0     	ret
    1cd0: 52800d01     	mov	w1, #0x68               ; =104
    1cd4: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1cd8: f9400042     	ldr	x2, [x2]
    1cdc: aa1a03e0     	mov	x0, x26
    1ce0: d63f0040     	blr	x2
    1ce4: 910443ff     	add	sp, sp, #0x110
    1ce8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1cec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1cf0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1cf4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1cf8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1cfc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1d00: d65f03c0     	ret
    1d04: 52800cc1     	mov	w1, #0x66               ; =102
    1d08: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1d0c: f9400042     	ldr	x2, [x2]
    1d10: aa1a03e0     	mov	x0, x26
    1d14: d63f0040     	blr	x2
    1d18: 910443ff     	add	sp, sp, #0x110
    1d1c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1d20: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1d24: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1d28: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1d2c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1d30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1d34: d65f03c0     	ret
    1d38: 52800ca1     	mov	w1, #0x65               ; =101
    1d3c: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1d40: f9400042     	ldr	x2, [x2]
    1d44: aa1a03e0     	mov	x0, x26
    1d48: d63f0040     	blr	x2
    1d4c: 910443ff     	add	sp, sp, #0x110
    1d50: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1d54: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1d58: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1d5c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1d60: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1d64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1d68: d65f03c0     	ret
    1d6c: 52800c61     	mov	w1, #0x63               ; =99
    1d70: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1d74: f9400042     	ldr	x2, [x2]
    1d78: aa1a03e0     	mov	x0, x26
    1d7c: d63f0040     	blr	x2
    1d80: 910443ff     	add	sp, sp, #0x110
    1d84: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1d88: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1d8c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1d90: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1d94: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1d98: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1d9c: d65f03c0     	ret
    1da0: 52800c21     	mov	w1, #0x61               ; =97
    1da4: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1da8: f9400042     	ldr	x2, [x2]
    1dac: aa1a03e0     	mov	x0, x26
    1db0: d63f0040     	blr	x2
    1db4: 910443ff     	add	sp, sp, #0x110
    1db8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1dbc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1dc0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1dc4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1dc8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1dcc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1dd0: d65f03c0     	ret
    1dd4: 52800c01     	mov	w1, #0x60               ; =96
    1dd8: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1ddc: f9400042     	ldr	x2, [x2]
    1de0: aa1a03e0     	mov	x0, x26
    1de4: d63f0040     	blr	x2
    1de8: 910443ff     	add	sp, sp, #0x110
    1dec: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1df0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1df4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1df8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1dfc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1e00: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1e04: d65f03c0     	ret
    1e08: 52800be1     	mov	w1, #0x5f               ; =95
    1e0c: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1e10: f9400042     	ldr	x2, [x2]
    1e14: aa1a03e0     	mov	x0, x26
    1e18: d63f0040     	blr	x2
    1e1c: 910443ff     	add	sp, sp, #0x110
    1e20: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1e24: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1e28: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1e2c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1e30: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1e34: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1e38: d65f03c0     	ret
    1e3c: 52800ba1     	mov	w1, #0x5d               ; =93
    1e40: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1e44: f9400042     	ldr	x2, [x2]
    1e48: aa1a03e0     	mov	x0, x26
    1e4c: d63f0040     	blr	x2
    1e50: 910443ff     	add	sp, sp, #0x110
    1e54: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1e58: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1e5c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1e60: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1e64: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1e68: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1e6c: d65f03c0     	ret
    1e70: 52800b61     	mov	w1, #0x5b               ; =91
    1e74: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1e78: f9400042     	ldr	x2, [x2]
    1e7c: aa1a03e0     	mov	x0, x26
    1e80: d63f0040     	blr	x2
    1e84: 910443ff     	add	sp, sp, #0x110
    1e88: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1e8c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1e90: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1e94: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1e98: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1e9c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1ea0: d65f03c0     	ret
    1ea4: 52800b41     	mov	w1, #0x5a               ; =90
    1ea8: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1eac: f9400042     	ldr	x2, [x2]
    1eb0: aa1a03e0     	mov	x0, x26
    1eb4: d63f0040     	blr	x2
    1eb8: 910443ff     	add	sp, sp, #0x110
    1ebc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1ec0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1ec4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1ec8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1ecc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1ed0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1ed4: d65f03c0     	ret
    1ed8: 52800b21     	mov	w1, #0x59               ; =89
    1edc: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1ee0: f9400042     	ldr	x2, [x2]
    1ee4: aa1a03e0     	mov	x0, x26
    1ee8: d63f0040     	blr	x2
    1eec: 910443ff     	add	sp, sp, #0x110
    1ef0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1ef4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1ef8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1efc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1f00: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1f04: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1f08: d65f03c0     	ret
    1f0c: 52800ac1     	mov	w1, #0x56               ; =86
    1f10: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1f14: f9400042     	ldr	x2, [x2]
    1f18: aa1a03e0     	mov	x0, x26
    1f1c: d63f0040     	blr	x2
    1f20: 910443ff     	add	sp, sp, #0x110
    1f24: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1f28: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1f2c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1f30: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1f34: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1f38: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1f3c: d65f03c0     	ret
    1f40: 52800a81     	mov	w1, #0x54               ; =84
    1f44: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1f48: f9400042     	ldr	x2, [x2]
    1f4c: aa1a03e0     	mov	x0, x26
    1f50: d63f0040     	blr	x2
    1f54: 910443ff     	add	sp, sp, #0x110
    1f58: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1f5c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1f60: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1f64: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1f68: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1f6c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1f70: d65f03c0     	ret
    1f74: 52800a61     	mov	w1, #0x53               ; =83
    1f78: 90000002     	adrp	x2, 0x1000 <___pl_fn_1+0xef4>
    1f7c: f9400042     	ldr	x2, [x2]
    1f80: aa1a03e0     	mov	x0, x26
    1f84: d63f0040     	blr	x2
    1f88: 910443ff     	add	sp, sp, #0x110
    1f8c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1f90: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1f94: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1f98: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1f9c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1fa0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1fa4: d65f03c0     	ret
    1fa8: 52800a41     	mov	w1, #0x52               ; =82
    1fac: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xef4>
    1fb0: f9400063     	ldr	x3, [x3]
    1fb4: aa1a03e0     	mov	x0, x26
    1fb8: d63f0060     	blr	x3
    1fbc: 910443ff     	add	sp, sp, #0x110
    1fc0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1fc4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1fc8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1fcc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1fd0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    1fd4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1fd8: d65f03c0     	ret
    1fdc: 52800a21     	mov	w1, #0x51               ; =81
    1fe0: 90000004     	adrp	x4, 0x1000 <___pl_fn_1+0xef4>
    1fe4: f9400084     	ldr	x4, [x4]
    1fe8: aa1a03e0     	mov	x0, x26
    1fec: d63f0080     	blr	x4
    1ff0: 910443ff     	add	sp, sp, #0x110
    1ff4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    1ff8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1ffc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2000: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2004: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2008: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    200c: d65f03c0     	ret
    2010: 528009e1     	mov	w1, #0x4f               ; =79
    2014: 90000005     	adrp	x5, 0x2000 <___pl_fn_1+0x1ef4>
    2018: f94000a5     	ldr	x5, [x5]
    201c: aa1a03e0     	mov	x0, x26
    2020: d63f00a0     	blr	x5
    2024: 910443ff     	add	sp, sp, #0x110
    2028: a8c153f3     	ldp	x19, x20, [sp], #0x10
    202c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2030: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2034: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2038: a8c173fb     	ldp	x27, x28, [sp], #0x10
    203c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2040: d65f03c0     	ret
    2044: 528009c1     	mov	w1, #0x4e               ; =78
    2048: 90000006     	adrp	x6, 0x2000 <___pl_fn_1+0x1ef4>
    204c: f94000c6     	ldr	x6, [x6]
    2050: aa1a03e0     	mov	x0, x26
    2054: d63f00c0     	blr	x6
    2058: 910443ff     	add	sp, sp, #0x110
    205c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2060: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2064: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2068: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    206c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2070: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2074: d65f03c0     	ret
    2078: 528009a1     	mov	w1, #0x4d               ; =77
    207c: 90000007     	adrp	x7, 0x2000 <___pl_fn_1+0x1ef4>
    2080: f94000e7     	ldr	x7, [x7]
    2084: aa1a03e0     	mov	x0, x26
    2088: d63f00e0     	blr	x7
    208c: 910443ff     	add	sp, sp, #0x110
    2090: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2094: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2098: a8c163f7     	ldp	x23, x24, [sp], #0x10
    209c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    20a0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    20a4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    20a8: d65f03c0     	ret
    20ac: 52800981     	mov	w1, #0x4c               ; =76
    20b0: 90000008     	adrp	x8, 0x2000 <___pl_fn_1+0x1ef4>
    20b4: f9400108     	ldr	x8, [x8]
    20b8: aa1a03e0     	mov	x0, x26
    20bc: d63f0100     	blr	x8
    20c0: 910443ff     	add	sp, sp, #0x110
    20c4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    20c8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    20cc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    20d0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    20d4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    20d8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    20dc: d65f03c0     	ret
    20e0: 52800941     	mov	w1, #0x4a               ; =74
    20e4: 90000009     	adrp	x9, 0x2000 <___pl_fn_1+0x1ef4>
    20e8: f9400129     	ldr	x9, [x9]
    20ec: aa1a03e0     	mov	x0, x26
    20f0: d63f0120     	blr	x9
    20f4: 910443ff     	add	sp, sp, #0x110
    20f8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    20fc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2100: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2104: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2108: a8c173fb     	ldp	x27, x28, [sp], #0x10
    210c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2110: d65f03c0     	ret
    2114: 52800921     	mov	w1, #0x49               ; =73
    2118: 9000000a     	adrp	x10, 0x2000 <___pl_fn_1+0x1ef4>
    211c: f940014a     	ldr	x10, [x10]
    2120: aa1a03e0     	mov	x0, x26
    2124: d63f0140     	blr	x10
    2128: 910443ff     	add	sp, sp, #0x110
    212c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2130: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2134: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2138: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    213c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2140: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2144: d65f03c0     	ret
    2148: 52800901     	mov	w1, #0x48               ; =72
    214c: 9000000b     	adrp	x11, 0x2000 <___pl_fn_1+0x1ef4>
    2150: f940016b     	ldr	x11, [x11]
    2154: aa1a03e0     	mov	x0, x26
    2158: d63f0160     	blr	x11
    215c: 910443ff     	add	sp, sp, #0x110
    2160: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2164: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2168: a8c163f7     	ldp	x23, x24, [sp], #0x10
    216c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2170: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2174: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2178: d65f03c0     	ret
    217c: 528008e1     	mov	w1, #0x47               ; =71
    2180: 9000000c     	adrp	x12, 0x2000 <___pl_fn_1+0x1ef4>
    2184: f940018c     	ldr	x12, [x12]
    2188: aa1a03e0     	mov	x0, x26
    218c: d63f0180     	blr	x12
    2190: 910443ff     	add	sp, sp, #0x110
    2194: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2198: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    219c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    21a0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    21a4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    21a8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    21ac: d65f03c0     	ret
    21b0: 528008a1     	mov	w1, #0x45               ; =69
    21b4: 9000000d     	adrp	x13, 0x2000 <___pl_fn_1+0x1ef4>
    21b8: f94001ad     	ldr	x13, [x13]
    21bc: aa1a03e0     	mov	x0, x26
    21c0: d63f01a0     	blr	x13
    21c4: 910443ff     	add	sp, sp, #0x110
    21c8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    21cc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    21d0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    21d4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    21d8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    21dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    21e0: d65f03c0     	ret
    21e4: 52800881     	mov	w1, #0x44               ; =68
    21e8: 9000000e     	adrp	x14, 0x2000 <___pl_fn_1+0x1ef4>
    21ec: f94001ce     	ldr	x14, [x14]
    21f0: aa1a03e0     	mov	x0, x26
    21f4: d63f01c0     	blr	x14
    21f8: 910443ff     	add	sp, sp, #0x110
    21fc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2200: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2204: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2208: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    220c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2210: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2214: d65f03c0     	ret
    2218: 52800861     	mov	w1, #0x43               ; =67
    221c: 9000000f     	adrp	x15, 0x2000 <___pl_fn_1+0x1ef4>
    2220: f94001ef     	ldr	x15, [x15]
    2224: aa1a03e0     	mov	x0, x26
    2228: d63f01e0     	blr	x15
    222c: 910443ff     	add	sp, sp, #0x110
    2230: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2234: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2238: a8c163f7     	ldp	x23, x24, [sp], #0x10
    223c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2240: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2244: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2248: d65f03c0     	ret
    224c: 52800801     	mov	w1, #0x40               ; =64
    2250: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2254: f9400042     	ldr	x2, [x2]
    2258: aa1a03e0     	mov	x0, x26
    225c: d63f0040     	blr	x2
    2260: 910443ff     	add	sp, sp, #0x110
    2264: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2268: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    226c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2270: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2274: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2278: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    227c: d65f03c0     	ret
    2280: 528007c1     	mov	w1, #0x3e               ; =62
    2284: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2288: f9400042     	ldr	x2, [x2]
    228c: aa1a03e0     	mov	x0, x26
    2290: d63f0040     	blr	x2
    2294: 910443ff     	add	sp, sp, #0x110
    2298: a8c153f3     	ldp	x19, x20, [sp], #0x10
    229c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    22a0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    22a4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    22a8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    22ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    22b0: d65f03c0     	ret
    22b4: 528007a1     	mov	w1, #0x3d               ; =61
    22b8: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    22bc: f9400042     	ldr	x2, [x2]
    22c0: aa1a03e0     	mov	x0, x26
    22c4: d63f0040     	blr	x2
    22c8: 910443ff     	add	sp, sp, #0x110
    22cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    22d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    22d4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    22d8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    22dc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    22e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    22e4: d65f03c0     	ret
    22e8: 52800781     	mov	w1, #0x3c               ; =60
    22ec: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    22f0: f9400042     	ldr	x2, [x2]
    22f4: aa1a03e0     	mov	x0, x26
    22f8: d63f0040     	blr	x2
    22fc: 910443ff     	add	sp, sp, #0x110
    2300: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2304: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2308: a8c163f7     	ldp	x23, x24, [sp], #0x10
    230c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2310: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2314: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2318: d65f03c0     	ret
    231c: 52800761     	mov	w1, #0x3b               ; =59
    2320: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2324: f9400042     	ldr	x2, [x2]
    2328: aa1a03e0     	mov	x0, x26
    232c: d63f0040     	blr	x2
    2330: 910443ff     	add	sp, sp, #0x110
    2334: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2338: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    233c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2340: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2344: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2348: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    234c: d65f03c0     	ret
    2350: 52800721     	mov	w1, #0x39               ; =57
    2354: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2358: f9400042     	ldr	x2, [x2]
    235c: aa1a03e0     	mov	x0, x26
    2360: d63f0040     	blr	x2
    2364: 910443ff     	add	sp, sp, #0x110
    2368: a8c153f3     	ldp	x19, x20, [sp], #0x10
    236c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2370: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2374: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2378: a8c173fb     	ldp	x27, x28, [sp], #0x10
    237c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2380: d65f03c0     	ret
    2384: 52800701     	mov	w1, #0x38               ; =56
    2388: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    238c: f9400042     	ldr	x2, [x2]
    2390: aa1a03e0     	mov	x0, x26
    2394: d63f0040     	blr	x2
    2398: 910443ff     	add	sp, sp, #0x110
    239c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    23a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    23a4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    23a8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    23ac: a8c173fb     	ldp	x27, x28, [sp], #0x10
    23b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    23b4: d65f03c0     	ret
    23b8: 528006e1     	mov	w1, #0x37               ; =55
    23bc: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    23c0: f9400042     	ldr	x2, [x2]
    23c4: aa1a03e0     	mov	x0, x26
    23c8: d63f0040     	blr	x2
    23cc: 910443ff     	add	sp, sp, #0x110
    23d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    23d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    23d8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    23dc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    23e0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    23e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    23e8: d65f03c0     	ret
    23ec: 528006c1     	mov	w1, #0x36               ; =54
    23f0: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    23f4: f9400042     	ldr	x2, [x2]
    23f8: aa1a03e0     	mov	x0, x26
    23fc: d63f0040     	blr	x2
    2400: 910443ff     	add	sp, sp, #0x110
    2404: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2408: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    240c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2410: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2414: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2418: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    241c: d65f03c0     	ret
    2420: 52800681     	mov	w1, #0x34               ; =52
    2424: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2428: f9400042     	ldr	x2, [x2]
    242c: aa1a03e0     	mov	x0, x26
    2430: d63f0040     	blr	x2
    2434: 910443ff     	add	sp, sp, #0x110
    2438: a8c153f3     	ldp	x19, x20, [sp], #0x10
    243c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2440: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2444: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2448: a8c173fb     	ldp	x27, x28, [sp], #0x10
    244c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2450: d65f03c0     	ret
    2454: 52800661     	mov	w1, #0x33               ; =51
    2458: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    245c: f9400042     	ldr	x2, [x2]
    2460: aa1a03e0     	mov	x0, x26
    2464: d63f0040     	blr	x2
    2468: 910443ff     	add	sp, sp, #0x110
    246c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2470: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2474: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2478: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    247c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2480: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2484: d65f03c0     	ret
    2488: 52800641     	mov	w1, #0x32               ; =50
    248c: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2490: f9400042     	ldr	x2, [x2]
    2494: aa1a03e0     	mov	x0, x26
    2498: d63f0040     	blr	x2
    249c: 910443ff     	add	sp, sp, #0x110
    24a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    24a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    24a8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    24ac: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    24b0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    24b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    24b8: d65f03c0     	ret
    24bc: 52800621     	mov	w1, #0x31               ; =49
    24c0: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    24c4: f9400042     	ldr	x2, [x2]
    24c8: aa1a03e0     	mov	x0, x26
    24cc: d63f0040     	blr	x2
    24d0: 910443ff     	add	sp, sp, #0x110
    24d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    24d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    24dc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    24e0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    24e4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    24e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    24ec: d65f03c0     	ret
    24f0: 528005e1     	mov	w1, #0x2f               ; =47
    24f4: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    24f8: f9400042     	ldr	x2, [x2]
    24fc: aa1a03e0     	mov	x0, x26
    2500: d63f0040     	blr	x2
    2504: 910443ff     	add	sp, sp, #0x110
    2508: a8c153f3     	ldp	x19, x20, [sp], #0x10
    250c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2510: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2514: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2518: a8c173fb     	ldp	x27, x28, [sp], #0x10
    251c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2520: d65f03c0     	ret
    2524: 528005c1     	mov	w1, #0x2e               ; =46
    2528: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    252c: f9400042     	ldr	x2, [x2]
    2530: aa1a03e0     	mov	x0, x26
    2534: d63f0040     	blr	x2
    2538: 910443ff     	add	sp, sp, #0x110
    253c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2540: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2544: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2548: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    254c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2550: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2554: d65f03c0     	ret
    2558: 528005a1     	mov	w1, #0x2d               ; =45
    255c: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2560: f9400042     	ldr	x2, [x2]
    2564: aa1a03e0     	mov	x0, x26
    2568: d63f0040     	blr	x2
    256c: 910443ff     	add	sp, sp, #0x110
    2570: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2574: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2578: a8c163f7     	ldp	x23, x24, [sp], #0x10
    257c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2580: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2584: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2588: d65f03c0     	ret
    258c: 52800541     	mov	w1, #0x2a               ; =42
    2590: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2594: f9400042     	ldr	x2, [x2]
    2598: aa1a03e0     	mov	x0, x26
    259c: d63f0040     	blr	x2
    25a0: 910443ff     	add	sp, sp, #0x110
    25a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    25a8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    25ac: a8c163f7     	ldp	x23, x24, [sp], #0x10
    25b0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    25b4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    25b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    25bc: d65f03c0     	ret
    25c0: 52800501     	mov	w1, #0x28               ; =40
    25c4: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    25c8: f9400042     	ldr	x2, [x2]
    25cc: aa1a03e0     	mov	x0, x26
    25d0: d63f0040     	blr	x2
    25d4: 910443ff     	add	sp, sp, #0x110
    25d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    25dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    25e0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    25e4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    25e8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    25ec: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    25f0: d65f03c0     	ret
    25f4: 528004e1     	mov	w1, #0x27               ; =39
    25f8: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    25fc: f9400042     	ldr	x2, [x2]
    2600: aa1a03e0     	mov	x0, x26
    2604: d63f0040     	blr	x2
    2608: 910443ff     	add	sp, sp, #0x110
    260c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2610: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2614: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2618: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    261c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2620: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2624: d65f03c0     	ret
    2628: 528004c1     	mov	w1, #0x26               ; =38
    262c: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2630: f9400042     	ldr	x2, [x2]
    2634: aa1a03e0     	mov	x0, x26
    2638: d63f0040     	blr	x2
    263c: 910443ff     	add	sp, sp, #0x110
    2640: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2644: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2648: a8c163f7     	ldp	x23, x24, [sp], #0x10
    264c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2650: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2654: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2658: d65f03c0     	ret
    265c: 528004a1     	mov	w1, #0x25               ; =37
    2660: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2664: f9400042     	ldr	x2, [x2]
    2668: aa1a03e0     	mov	x0, x26
    266c: d63f0040     	blr	x2
    2670: 910443ff     	add	sp, sp, #0x110
    2674: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2678: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    267c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2680: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2684: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2688: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    268c: d65f03c0     	ret
    2690: 52800461     	mov	w1, #0x23               ; =35
    2694: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2698: f9400042     	ldr	x2, [x2]
    269c: aa1a03e0     	mov	x0, x26
    26a0: d63f0040     	blr	x2
    26a4: 910443ff     	add	sp, sp, #0x110
    26a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    26ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    26b0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    26b4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    26b8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    26bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    26c0: d65f03c0     	ret
    26c4: 52800441     	mov	w1, #0x22               ; =34
    26c8: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    26cc: f9400042     	ldr	x2, [x2]
    26d0: aa1a03e0     	mov	x0, x26
    26d4: d63f0040     	blr	x2
    26d8: 910443ff     	add	sp, sp, #0x110
    26dc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    26e0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    26e4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    26e8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    26ec: a8c173fb     	ldp	x27, x28, [sp], #0x10
    26f0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    26f4: d65f03c0     	ret
    26f8: 52800421     	mov	w1, #0x21               ; =33
    26fc: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2700: f9400042     	ldr	x2, [x2]
    2704: aa1a03e0     	mov	x0, x26
    2708: d63f0040     	blr	x2
    270c: 910443ff     	add	sp, sp, #0x110
    2710: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2714: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2718: a8c163f7     	ldp	x23, x24, [sp], #0x10
    271c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2720: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2724: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2728: d65f03c0     	ret
    272c: 52800401     	mov	w1, #0x20               ; =32
    2730: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2734: f9400042     	ldr	x2, [x2]
    2738: aa1a03e0     	mov	x0, x26
    273c: d63f0040     	blr	x2
    2740: 910443ff     	add	sp, sp, #0x110
    2744: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2748: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    274c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2750: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2754: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2758: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    275c: d65f03c0     	ret
    2760: 528003c1     	mov	w1, #0x1e               ; =30
    2764: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2768: f9400042     	ldr	x2, [x2]
    276c: aa1a03e0     	mov	x0, x26
    2770: d63f0040     	blr	x2
    2774: 910443ff     	add	sp, sp, #0x110
    2778: a8c153f3     	ldp	x19, x20, [sp], #0x10
    277c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2780: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2784: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2788: a8c173fb     	ldp	x27, x28, [sp], #0x10
    278c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2790: d65f03c0     	ret
    2794: 528003a1     	mov	w1, #0x1d               ; =29
    2798: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    279c: f9400042     	ldr	x2, [x2]
    27a0: aa1a03e0     	mov	x0, x26
    27a4: d63f0040     	blr	x2
    27a8: 910443ff     	add	sp, sp, #0x110
    27ac: a8c153f3     	ldp	x19, x20, [sp], #0x10
    27b0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    27b4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    27b8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    27bc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    27c0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    27c4: d65f03c0     	ret
    27c8: 52800381     	mov	w1, #0x1c               ; =28
    27cc: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    27d0: f9400042     	ldr	x2, [x2]
    27d4: aa1a03e0     	mov	x0, x26
    27d8: d63f0040     	blr	x2
    27dc: 910443ff     	add	sp, sp, #0x110
    27e0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    27e4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    27e8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    27ec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    27f0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    27f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    27f8: d65f03c0     	ret
    27fc: 52800321     	mov	w1, #0x19               ; =25
    2800: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2804: f9400042     	ldr	x2, [x2]
    2808: aa1a03e0     	mov	x0, x26
    280c: d63f0040     	blr	x2
    2810: 910443ff     	add	sp, sp, #0x110
    2814: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2818: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    281c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2820: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2824: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2828: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    282c: d65f03c0     	ret
    2830: 528002e1     	mov	w1, #0x17               ; =23
    2834: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2838: f9400042     	ldr	x2, [x2]
    283c: aa1a03e0     	mov	x0, x26
    2840: d63f0040     	blr	x2
    2844: 910443ff     	add	sp, sp, #0x110
    2848: a8c153f3     	ldp	x19, x20, [sp], #0x10
    284c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2850: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2854: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2858: a8c173fb     	ldp	x27, x28, [sp], #0x10
    285c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2860: d65f03c0     	ret
    2864: 52800221     	mov	w1, #0x11               ; =17
    2868: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    286c: f9400042     	ldr	x2, [x2]
    2870: aa1a03e0     	mov	x0, x26
    2874: d63f0040     	blr	x2
    2878: 910443ff     	add	sp, sp, #0x110
    287c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2880: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2884: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2888: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    288c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2890: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2894: d65f03c0     	ret
    2898: 528001e1     	mov	w1, #0xf                ; =15
    289c: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    28a0: f9400042     	ldr	x2, [x2]
    28a4: aa1a03e0     	mov	x0, x26
    28a8: d63f0040     	blr	x2
    28ac: 910443ff     	add	sp, sp, #0x110
    28b0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    28b4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    28b8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    28bc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    28c0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    28c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    28c8: d65f03c0     	ret
    28cc: 528001a1     	mov	w1, #0xd                ; =13
    28d0: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    28d4: f9400042     	ldr	x2, [x2]
    28d8: aa1a03e0     	mov	x0, x26
    28dc: d63f0040     	blr	x2
    28e0: 910443ff     	add	sp, sp, #0x110
    28e4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    28e8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    28ec: a8c163f7     	ldp	x23, x24, [sp], #0x10
    28f0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    28f4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    28f8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    28fc: d65f03c0     	ret
    2900: 52800161     	mov	w1, #0xb                ; =11
    2904: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2908: f9400042     	ldr	x2, [x2]
    290c: aa1a03e0     	mov	x0, x26
    2910: d63f0040     	blr	x2
    2914: 910443ff     	add	sp, sp, #0x110
    2918: a8c153f3     	ldp	x19, x20, [sp], #0x10
    291c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2920: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2924: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2928: a8c173fb     	ldp	x27, x28, [sp], #0x10
    292c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2930: d65f03c0     	ret
    2934: 52800141     	mov	w1, #0xa                ; =10
    2938: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    293c: f9400042     	ldr	x2, [x2]
    2940: aa1a03e0     	mov	x0, x26
    2944: d63f0040     	blr	x2
    2948: 910443ff     	add	sp, sp, #0x110
    294c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2950: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2954: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2958: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    295c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2960: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2964: d65f03c0     	ret
    2968: 910443ff     	add	sp, sp, #0x110
    296c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2970: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2974: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2978: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    297c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2980: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2984: d65f03c0     	ret

0000000000002988 <___pl_fn_2>:
    2988: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    298c: 910003fd     	mov	x29, sp
    2990: a9bf6ff5     	stp	x21, x27, [sp, #-0x10]!
    2994: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    2998: d10203ff     	sub	sp, sp, #0x80
    299c: aa0103f3     	mov	x19, x1
    29a0: aa0403f4     	mov	x20, x4
    29a4: aa0303f5     	mov	x21, x3
    29a8: b940100c     	ldr	w12, [x0, #0x10]
    29ac: 1100058c     	add	w12, w12, #0x1
    29b0: b900100c     	str	w12, [x0, #0x10]
    29b4: aa0003e5     	mov	x5, x0
    29b8: aa1303e1     	mov	x1, x19
    29bc: 34001061     	cbz	w1, 0x2bc8 <___pl_fn_2+0x240>
    29c0: aa0503fb     	mov	x27, x5
    29c4: f9400361     	ldr	x1, [x27]
    29c8: 2a1303e0     	mov	w0, w19
    29cc: 8b000c20     	add	x0, x1, x0, lsl #3
    29d0: f8735823     	ldr	x3, [x1, w19, uxtw #3]
    29d4: 2a0203e1     	mov	w1, w2
    29d8: d360fc62     	lsr	x2, x3, #32
    29dc: 92403c42     	and	x2, x2, #0xffff
    29e0: f8227801     	str	x1, [x0, x2, lsl #3]
    29e4: 340010f3     	cbz	w19, 0x2c00 <___pl_fn_2+0x278>
    29e8: aa1503e2     	mov	x2, x21
    29ec: f9400361     	ldr	x1, [x27]
    29f0: 2a1303e0     	mov	w0, w19
    29f4: 8b000c20     	add	x0, x1, x0, lsl #3
    29f8: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    29fc: d360fc21     	lsr	x1, x1, #32
    2a00: 92403c23     	and	x3, x1, #0xffff
    2a04: f100087f     	cmp	x3, #0x2
    2a08: 54000080     	b.eq	0x2a18 <___pl_fn_2+0x90>
    2a0c: f9400803     	ldr	x3, [x0, #0x10]
    2a10: 927ef863     	and	x3, x3, #0xfffffffffffffffd
    2a14: f9000803     	str	x3, [x0, #0x10]
    2a18: 92403c21     	and	x1, x1, #0xffff
    2a1c: 91000421     	add	x1, x1, #0x1
    2a20: f8217802     	str	x2, [x0, x1, lsl #3]
    2a24: 34001093     	cbz	w19, 0x2c34 <___pl_fn_2+0x2ac>
    2a28: aa1403e4     	mov	x4, x20
    2a2c: f9400361     	ldr	x1, [x27]
    2a30: 2a1303e0     	mov	w0, w19
    2a34: 8b000c20     	add	x0, x1, x0, lsl #3
    2a38: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    2a3c: d360fc21     	lsr	x1, x1, #32
    2a40: 92403c22     	and	x2, x1, #0xffff
    2a44: f100085f     	cmp	x2, #0x2
    2a48: 54000080     	b.eq	0x2a58 <___pl_fn_2+0xd0>
    2a4c: f9400802     	ldr	x2, [x0, #0x10]
    2a50: 927df842     	and	x2, x2, #0xfffffffffffffffb
    2a54: f9000802     	str	x2, [x0, #0x10]
    2a58: 92403c21     	and	x1, x1, #0xffff
    2a5c: 91000821     	add	x1, x1, #0x2
    2a60: f8217804     	str	x4, [x0, x1, lsl #3]
    2a64: 34001033     	cbz	w19, 0x2c68 <___pl_fn_2+0x2e0>
    2a68: f9400361     	ldr	x1, [x27]
    2a6c: 2a1303e0     	mov	w0, w19
    2a70: 8b000c20     	add	x0, x1, x0, lsl #3
    2a74: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    2a78: d360fc21     	lsr	x1, x1, #32
    2a7c: 92403c22     	and	x2, x1, #0xffff
    2a80: f100085f     	cmp	x2, #0x2
    2a84: 54000080     	b.eq	0x2a94 <___pl_fn_2+0x10c>
    2a88: f9400802     	ldr	x2, [x0, #0x10]
    2a8c: 927cf842     	and	x2, x2, #0xfffffffffffffff7
    2a90: f9000802     	str	x2, [x0, #0x10]
    2a94: d2800002     	mov	x2, #0x0                ; =0
    2a98: 92403c21     	and	x1, x1, #0xffff
    2a9c: 91000c21     	add	x1, x1, #0x3
    2aa0: f8217802     	str	x2, [x0, x1, lsl #3]
    2aa4: 34000fd3     	cbz	w19, 0x2c9c <___pl_fn_2+0x314>
    2aa8: f9400365     	ldr	x5, [x27]
    2aac: 2a1303e4     	mov	w4, w19
    2ab0: 8b040ca4     	add	x4, x5, x4, lsl #3
    2ab4: f87358a5     	ldr	x5, [x5, w19, uxtw #3]
    2ab8: d360fca5     	lsr	x5, x5, #32
    2abc: 92403ca6     	and	x6, x5, #0xffff
    2ac0: f10008df     	cmp	x6, #0x2
    2ac4: 54000080     	b.eq	0x2ad4 <___pl_fn_2+0x14c>
    2ac8: f9400887     	ldr	x7, [x4, #0x10]
    2acc: 927bf8e7     	and	x7, x7, #0xffffffffffffffef
    2ad0: f9000887     	str	x7, [x4, #0x10]
    2ad4: d2800009     	mov	x9, #0x0                ; =0
    2ad8: 92403caa     	and	x10, x5, #0xffff
    2adc: 9100114a     	add	x10, x10, #0x4
    2ae0: f82a7889     	str	x9, [x4, x10, lsl #3]
    2ae4: 34000f73     	cbz	w19, 0x2cd0 <___pl_fn_2+0x348>
    2ae8: f9400361     	ldr	x1, [x27]
    2aec: 2a1303e0     	mov	w0, w19
    2af0: 8b000c20     	add	x0, x1, x0, lsl #3
    2af4: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    2af8: d360fc21     	lsr	x1, x1, #32
    2afc: 92403c22     	and	x2, x1, #0xffff
    2b00: f100085f     	cmp	x2, #0x2
    2b04: 54000080     	b.eq	0x2b14 <___pl_fn_2+0x18c>
    2b08: f9400802     	ldr	x2, [x0, #0x10]
    2b0c: 927af842     	and	x2, x2, #0xffffffffffffffdf
    2b10: f9000802     	str	x2, [x0, #0x10]
    2b14: d2800002     	mov	x2, #0x0                ; =0
    2b18: 92403c21     	and	x1, x1, #0xffff
    2b1c: 91001421     	add	x1, x1, #0x5
    2b20: f8217802     	str	x2, [x0, x1, lsl #3]
    2b24: 34000f13     	cbz	w19, 0x2d04 <___pl_fn_2+0x37c>
    2b28: f9400361     	ldr	x1, [x27]
    2b2c: 2a1303e0     	mov	w0, w19
    2b30: 8b000c20     	add	x0, x1, x0, lsl #3
    2b34: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    2b38: d360fc21     	lsr	x1, x1, #32
    2b3c: 92403c22     	and	x2, x1, #0xffff
    2b40: f100085f     	cmp	x2, #0x2
    2b44: 54000080     	b.eq	0x2b54 <___pl_fn_2+0x1cc>
    2b48: f9400802     	ldr	x2, [x0, #0x10]
    2b4c: 9279f842     	and	x2, x2, #0xffffffffffffffbf
    2b50: f9000802     	str	x2, [x0, #0x10]
    2b54: d2800002     	mov	x2, #0x0                ; =0
    2b58: 92403c21     	and	x1, x1, #0xffff
    2b5c: 91001821     	add	x1, x1, #0x6
    2b60: f8217802     	str	x2, [x0, x1, lsl #3]
    2b64: 34000eb3     	cbz	w19, 0x2d38 <___pl_fn_2+0x3b0>
    2b68: f9400361     	ldr	x1, [x27]
    2b6c: 2a1303e0     	mov	w0, w19
    2b70: 8b000c20     	add	x0, x1, x0, lsl #3
    2b74: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    2b78: d360fc21     	lsr	x1, x1, #32
    2b7c: 92403c22     	and	x2, x1, #0xffff
    2b80: f100085f     	cmp	x2, #0x2
    2b84: 54000080     	b.eq	0x2b94 <___pl_fn_2+0x20c>
    2b88: f9400802     	ldr	x2, [x0, #0x10]
    2b8c: 9278f842     	and	x2, x2, #0xffffffffffffff7f
    2b90: f9000802     	str	x2, [x0, #0x10]
    2b94: d2800002     	mov	x2, #0x0                ; =0
    2b98: 92403c21     	and	x1, x1, #0xffff
    2b9c: 91001c21     	add	x1, x1, #0x7
    2ba0: f8217802     	str	x2, [x0, x1, lsl #3]
    2ba4: b9401360     	ldr	w0, [x27, #0x10]
    2ba8: 51000400     	sub	w0, w0, #0x1
    2bac: b9001360     	str	w0, [x27, #0x10]
    2bb0: aa1303e0     	mov	x0, x19
    2bb4: 910203ff     	add	sp, sp, #0x80
    2bb8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2bbc: a8c16ff5     	ldp	x21, x27, [sp], #0x10
    2bc0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2bc4: d65f03c0     	ret
    2bc8: d280000f     	mov	x15, #0x0               ; =0
    2bcc: 910003e3     	mov	x3, sp
    2bd0: f80003ef     	stur	x15, [sp]
    2bd4: 2a0203e0     	mov	w0, w2
    2bd8: f80083e0     	stur	x0, [sp, #0x8]
    2bdc: 52800ec1     	mov	w1, #0x76               ; =118
    2be0: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2be4: f9400084     	ldr	x4, [x4]
    2be8: aa0503fb     	mov	x27, x5
    2bec: aa1b03e0     	mov	x0, x27
    2bf0: aa1303e2     	mov	x2, x19
    2bf4: d63f0080     	blr	x4
    2bf8: 34ffef60     	cbz	w0, 0x29e4 <___pl_fn_2+0x5c>
    2bfc: 1400005b     	b	0x2d68 <___pl_fn_2+0x3e0>
    2c00: d2800020     	mov	x0, #0x1                ; =1
    2c04: 910043e3     	add	x3, sp, #0x10
    2c08: f80103e0     	stur	x0, [sp, #0x10]
    2c0c: aa1503e2     	mov	x2, x21
    2c10: f80183e2     	stur	x2, [sp, #0x18]
    2c14: 52800ee1     	mov	w1, #0x77               ; =119
    2c18: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2c1c: f9400084     	ldr	x4, [x4]
    2c20: aa1b03e0     	mov	x0, x27
    2c24: aa1303e2     	mov	x2, x19
    2c28: d63f0080     	blr	x4
    2c2c: 34ffefc0     	cbz	w0, 0x2a24 <___pl_fn_2+0x9c>
    2c30: 1400004e     	b	0x2d68 <___pl_fn_2+0x3e0>
    2c34: d2800040     	mov	x0, #0x2                ; =2
    2c38: 910083e3     	add	x3, sp, #0x20
    2c3c: f80203e0     	stur	x0, [sp, #0x20]
    2c40: aa1403e4     	mov	x4, x20
    2c44: f80283e4     	stur	x4, [sp, #0x28]
    2c48: 52800f01     	mov	w1, #0x78               ; =120
    2c4c: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2c50: f9400084     	ldr	x4, [x4]
    2c54: aa1b03e0     	mov	x0, x27
    2c58: aa1303e2     	mov	x2, x19
    2c5c: d63f0080     	blr	x4
    2c60: 34fff020     	cbz	w0, 0x2a64 <___pl_fn_2+0xdc>
    2c64: 14000041     	b	0x2d68 <___pl_fn_2+0x3e0>
    2c68: d2800060     	mov	x0, #0x3                ; =3
    2c6c: 9100c3e3     	add	x3, sp, #0x30
    2c70: f80303e0     	stur	x0, [sp, #0x30]
    2c74: d2800000     	mov	x0, #0x0                ; =0
    2c78: f80383e0     	stur	x0, [sp, #0x38]
    2c7c: 52800f21     	mov	w1, #0x79               ; =121
    2c80: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2c84: f9400084     	ldr	x4, [x4]
    2c88: aa1b03e0     	mov	x0, x27
    2c8c: aa1303e2     	mov	x2, x19
    2c90: d63f0080     	blr	x4
    2c94: 34fff080     	cbz	w0, 0x2aa4 <___pl_fn_2+0x11c>
    2c98: 14000034     	b	0x2d68 <___pl_fn_2+0x3e0>
    2c9c: d2800080     	mov	x0, #0x4                ; =4
    2ca0: 910103e3     	add	x3, sp, #0x40
    2ca4: f80403e0     	stur	x0, [sp, #0x40]
    2ca8: d2800000     	mov	x0, #0x0                ; =0
    2cac: f80483e0     	stur	x0, [sp, #0x48]
    2cb0: 52800f41     	mov	w1, #0x7a               ; =122
    2cb4: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2cb8: f9400084     	ldr	x4, [x4]
    2cbc: aa1b03e0     	mov	x0, x27
    2cc0: aa1303e2     	mov	x2, x19
    2cc4: d63f0080     	blr	x4
    2cc8: 34fff0e0     	cbz	w0, 0x2ae4 <___pl_fn_2+0x15c>
    2ccc: 14000027     	b	0x2d68 <___pl_fn_2+0x3e0>
    2cd0: d28000ac     	mov	x12, #0x5               ; =5
    2cd4: 910143e3     	add	x3, sp, #0x50
    2cd8: f80503ec     	stur	x12, [sp, #0x50]
    2cdc: d280000d     	mov	x13, #0x0               ; =0
    2ce0: f80583ed     	stur	x13, [sp, #0x58]
    2ce4: 52800f61     	mov	w1, #0x7b               ; =123
    2ce8: 9000000e     	adrp	x14, 0x2000 <___pl_fn_1+0x1ef4>
    2cec: f94001ce     	ldr	x14, [x14]
    2cf0: aa1b03e0     	mov	x0, x27
    2cf4: aa1303e2     	mov	x2, x19
    2cf8: d63f01c0     	blr	x14
    2cfc: 34fff140     	cbz	w0, 0x2b24 <___pl_fn_2+0x19c>
    2d00: 1400001a     	b	0x2d68 <___pl_fn_2+0x3e0>
    2d04: d28000c0     	mov	x0, #0x6                ; =6
    2d08: 910183e3     	add	x3, sp, #0x60
    2d0c: f80603e0     	stur	x0, [sp, #0x60]
    2d10: d2800000     	mov	x0, #0x0                ; =0
    2d14: f80683e0     	stur	x0, [sp, #0x68]
    2d18: 52800f81     	mov	w1, #0x7c               ; =124
    2d1c: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2d20: f9400084     	ldr	x4, [x4]
    2d24: aa1b03e0     	mov	x0, x27
    2d28: aa1303e2     	mov	x2, x19
    2d2c: d63f0080     	blr	x4
    2d30: 34fff1a0     	cbz	w0, 0x2b64 <___pl_fn_2+0x1dc>
    2d34: 1400000d     	b	0x2d68 <___pl_fn_2+0x3e0>
    2d38: d28000e0     	mov	x0, #0x7                ; =7
    2d3c: 9101c3e3     	add	x3, sp, #0x70
    2d40: f80703e0     	stur	x0, [sp, #0x70]
    2d44: d2800000     	mov	x0, #0x0                ; =0
    2d48: f80783e0     	stur	x0, [sp, #0x78]
    2d4c: 52800fa1     	mov	w1, #0x7d               ; =125
    2d50: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2d54: f9400084     	ldr	x4, [x4]
    2d58: aa1b03e0     	mov	x0, x27
    2d5c: aa1303e2     	mov	x2, x19
    2d60: d63f0080     	blr	x4
    2d64: 34fff200     	cbz	w0, 0x2ba4 <___pl_fn_2+0x21c>
    2d68: 52800000     	mov	w0, #0x0                ; =0
    2d6c: 910203ff     	add	sp, sp, #0x80
    2d70: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2d74: a8c16ff5     	ldp	x21, x27, [sp], #0x10
    2d78: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2d7c: d65f03c0     	ret

0000000000002d80 <___pl_fn_3>:
    2d80: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    2d84: 910003fd     	mov	x29, sp
    2d88: f81f0ff3     	str	x19, [sp, #-0x10]!
    2d8c: b940100b     	ldr	w11, [x0, #0x10]
    2d90: 1100056b     	add	w11, w11, #0x1
    2d94: b900100b     	str	w11, [x0, #0x10]
    2d98: b40009a2     	cbz	x2, 0x2ecc <___pl_fn_3+0x14c>
    2d9c: f100045f     	cmp	x2, #0x1
    2da0: 54000680     	b.eq	0x2e70 <___pl_fn_3+0xf0>
    2da4: f100085f     	cmp	x2, #0x2
    2da8: 54000360     	b.eq	0x2e14 <___pl_fn_3+0x94>
    2dac: 34000be1     	cbz	w1, 0x2f28 <___pl_fn_3+0x1a8>
    2db0: f9400003     	ldr	x3, [x0]
    2db4: aa0003ec     	mov	x12, x0
    2db8: 2a0103e0     	mov	w0, w1
    2dbc: 8b000c62     	add	x2, x3, x0, lsl #3
    2dc0: f8615860     	ldr	x0, [x3, w1, uxtw #3]
    2dc4: aa0103ee     	mov	x14, x1
    2dc8: d360fc00     	lsr	x0, x0, #32
    2dcc: 92403c01     	and	x1, x0, #0xffff
    2dd0: 91001c20     	add	x0, x1, #0x7
    2dd4: f8607840     	ldr	x0, [x2, x0, lsl #3]
    2dd8: f100083f     	cmp	x1, #0x2
    2ddc: 54000061     	b.ne	0x2de8 <___pl_fn_3+0x68>
    2de0: aa0c03f3     	mov	x19, x12
    2de4: 14000006     	b	0x2dfc <___pl_fn_3+0x7c>
    2de8: f9400841     	ldr	x1, [x2, #0x10]
    2dec: 37380a21     	tbnz	w1, #0x7, 0x2f30 <___pl_fn_3+0x1b0>
    2df0: aa0c03f3     	mov	x19, x12
    2df4: 14000002     	b	0x2dfc <___pl_fn_3+0x7c>
    2df8: f9401a60     	ldr	x0, [x19, #0x30]
    2dfc: b9401261     	ldr	w1, [x19, #0x10]
    2e00: 51000421     	sub	w1, w1, #0x1
    2e04: b9001261     	str	w1, [x19, #0x10]
    2e08: f84107f3     	ldr	x19, [sp], #0x10
    2e0c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2e10: d65f03c0     	ret
    2e14: aa0103e2     	mov	x2, x1
    2e18: aa0003f3     	mov	x19, x0
    2e1c: 340009e2     	cbz	w2, 0x2f58 <___pl_fn_3+0x1d8>
    2e20: f9400260     	ldr	x0, [x19]
    2e24: 2a0203e1     	mov	w1, w2
    2e28: 8b010c01     	add	x1, x0, x1, lsl #3
    2e2c: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    2e30: d360fc00     	lsr	x0, x0, #32
    2e34: 92403c03     	and	x3, x0, #0xffff
    2e38: 91001860     	add	x0, x3, #0x6
    2e3c: f8607820     	ldr	x0, [x1, x0, lsl #3]
    2e40: f100087f     	cmp	x3, #0x2
    2e44: 540000a0     	b.eq	0x2e58 <___pl_fn_3+0xd8>
    2e48: f9400821     	ldr	x1, [x1, #0x10]
    2e4c: 37300861     	tbnz	w1, #0x6, 0x2f58 <___pl_fn_3+0x1d8>
    2e50: 14000002     	b	0x2e58 <___pl_fn_3+0xd8>
    2e54: f9401a60     	ldr	x0, [x19, #0x30]
    2e58: b9401261     	ldr	w1, [x19, #0x10]
    2e5c: 51000421     	sub	w1, w1, #0x1
    2e60: b9001261     	str	w1, [x19, #0x10]
    2e64: f84107f3     	ldr	x19, [sp], #0x10
    2e68: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2e6c: d65f03c0     	ret
    2e70: aa0103e2     	mov	x2, x1
    2e74: aa0003f3     	mov	x19, x0
    2e78: 34000802     	cbz	w2, 0x2f78 <___pl_fn_3+0x1f8>
    2e7c: f9400260     	ldr	x0, [x19]
    2e80: 2a0203e1     	mov	w1, w2
    2e84: 8b010c01     	add	x1, x0, x1, lsl #3
    2e88: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    2e8c: d360fc00     	lsr	x0, x0, #32
    2e90: 92403c03     	and	x3, x0, #0xffff
    2e94: 91001460     	add	x0, x3, #0x5
    2e98: f8607820     	ldr	x0, [x1, x0, lsl #3]
    2e9c: f100087f     	cmp	x3, #0x2
    2ea0: 540000a0     	b.eq	0x2eb4 <___pl_fn_3+0x134>
    2ea4: f9400821     	ldr	x1, [x1, #0x10]
    2ea8: 37280681     	tbnz	w1, #0x5, 0x2f78 <___pl_fn_3+0x1f8>
    2eac: 14000002     	b	0x2eb4 <___pl_fn_3+0x134>
    2eb0: f9401a60     	ldr	x0, [x19, #0x30]
    2eb4: b9401261     	ldr	w1, [x19, #0x10]
    2eb8: 51000421     	sub	w1, w1, #0x1
    2ebc: b9001261     	str	w1, [x19, #0x10]
    2ec0: f84107f3     	ldr	x19, [sp], #0x10
    2ec4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2ec8: d65f03c0     	ret
    2ecc: aa0103e2     	mov	x2, x1
    2ed0: aa0003f3     	mov	x19, x0
    2ed4: 34000622     	cbz	w2, 0x2f98 <___pl_fn_3+0x218>
    2ed8: f9400263     	ldr	x3, [x19]
    2edc: 2a0203e1     	mov	w1, w2
    2ee0: 8b010c61     	add	x1, x3, x1, lsl #3
    2ee4: f8625863     	ldr	x3, [x3, w2, uxtw #3]
    2ee8: d360fc63     	lsr	x3, x3, #32
    2eec: 92403c63     	and	x3, x3, #0xffff
    2ef0: 91001064     	add	x4, x3, #0x4
    2ef4: f8647820     	ldr	x0, [x1, x4, lsl #3]
    2ef8: f100087f     	cmp	x3, #0x2
    2efc: 540000a0     	b.eq	0x2f10 <___pl_fn_3+0x190>
    2f00: f9400824     	ldr	x4, [x1, #0x10]
    2f04: 372004a4     	tbnz	w4, #0x4, 0x2f98 <___pl_fn_3+0x218>
    2f08: 14000002     	b	0x2f10 <___pl_fn_3+0x190>
    2f0c: f9401a60     	ldr	x0, [x19, #0x30]
    2f10: b940126c     	ldr	w12, [x19, #0x10]
    2f14: 5100058c     	sub	w12, w12, #0x1
    2f18: b900126c     	str	w12, [x19, #0x10]
    2f1c: f84107f3     	ldr	x19, [sp], #0x10
    2f20: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2f24: d65f03c0     	ret
    2f28: aa0003ec     	mov	x12, x0
    2f2c: aa0103ee     	mov	x14, x1
    2f30: 52800fc1     	mov	w1, #0x7e               ; =126
    2f34: 528000e3     	mov	w3, #0x7                ; =7
    2f38: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2f3c: f9400084     	ldr	x4, [x4]
    2f40: aa0e03e2     	mov	x2, x14
    2f44: aa0c03f3     	mov	x19, x12
    2f48: aa1303e0     	mov	x0, x19
    2f4c: d63f0080     	blr	x4
    2f50: 34fff540     	cbz	w0, 0x2df8 <___pl_fn_3+0x78>
    2f54: 14000018     	b	0x2fb4 <___pl_fn_3+0x234>
    2f58: 52800fe1     	mov	w1, #0x7f               ; =127
    2f5c: 528000c3     	mov	w3, #0x6                ; =6
    2f60: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2f64: f9400084     	ldr	x4, [x4]
    2f68: aa1303e0     	mov	x0, x19
    2f6c: d63f0080     	blr	x4
    2f70: 34fff720     	cbz	w0, 0x2e54 <___pl_fn_3+0xd4>
    2f74: 14000010     	b	0x2fb4 <___pl_fn_3+0x234>
    2f78: 52801001     	mov	w1, #0x80               ; =128
    2f7c: 528000a3     	mov	w3, #0x5                ; =5
    2f80: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2f84: f9400084     	ldr	x4, [x4]
    2f88: aa1303e0     	mov	x0, x19
    2f8c: d63f0080     	blr	x4
    2f90: 34fff900     	cbz	w0, 0x2eb0 <___pl_fn_3+0x130>
    2f94: 14000008     	b	0x2fb4 <___pl_fn_3+0x234>
    2f98: 52801021     	mov	w1, #0x81               ; =129
    2f9c: 52800083     	mov	w3, #0x4                ; =4
    2fa0: 90000007     	adrp	x7, 0x2000 <___pl_fn_1+0x1ef4>
    2fa4: f94000e7     	ldr	x7, [x7]
    2fa8: aa1303e0     	mov	x0, x19
    2fac: d63f00e0     	blr	x7
    2fb0: 34fffae0     	cbz	w0, 0x2f0c <___pl_fn_3+0x18c>
    2fb4: d2800000     	mov	x0, #0x0                ; =0
    2fb8: f84107f3     	ldr	x19, [sp], #0x10
    2fbc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2fc0: d65f03c0     	ret

0000000000002fc4 <___pl_fn_4>:
    2fc4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    2fc8: 910003fd     	mov	x29, sp
    2fcc: f81f0ff7     	str	x23, [sp, #-0x10]!
    2fd0: d10103ff     	sub	sp, sp, #0x40
    2fd4: aa0303ea     	mov	x10, x3
    2fd8: b9401005     	ldr	w5, [x0, #0x10]
    2fdc: 110004a5     	add	w5, w5, #0x1
    2fe0: b9001005     	str	w5, [x0, #0x10]
    2fe4: b40007c2     	cbz	x2, 0x30dc <___pl_fn_4+0x118>
    2fe8: f100045f     	cmp	x2, #0x1
    2fec: 54000520     	b.eq	0x3090 <___pl_fn_4+0xcc>
    2ff0: f100085f     	cmp	x2, #0x2
    2ff4: 54000280     	b.eq	0x3044 <___pl_fn_4+0x80>
    2ff8: 34000a41     	cbz	w1, 0x3140 <___pl_fn_4+0x17c>
    2ffc: aa0103e2     	mov	x2, x1
    3000: aa0a03e4     	mov	x4, x10
    3004: aa0003f7     	mov	x23, x0
    3008: f94002e1     	ldr	x1, [x23]
    300c: 2a0203e0     	mov	w0, w2
    3010: 8b000c20     	add	x0, x1, x0, lsl #3
    3014: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    3018: d360fc21     	lsr	x1, x1, #32
    301c: 92403c22     	and	x2, x1, #0xffff
    3020: f100085f     	cmp	x2, #0x2
    3024: 54000080     	b.eq	0x3034 <___pl_fn_4+0x70>
    3028: f9400802     	ldr	x2, [x0, #0x10]
    302c: 9278f842     	and	x2, x2, #0xffffffffffffff7f
    3030: f9000802     	str	x2, [x0, #0x10]
    3034: 92403c21     	and	x1, x1, #0xffff
    3038: 91001c21     	add	x1, x1, #0x7
    303c: f8217804     	str	x4, [x0, x1, lsl #3]
    3040: 14000039     	b	0x3124 <___pl_fn_4+0x160>
    3044: aa0103e2     	mov	x2, x1
    3048: aa0a03e4     	mov	x4, x10
    304c: aa0003f7     	mov	x23, x0
    3050: 34000942     	cbz	w2, 0x3178 <___pl_fn_4+0x1b4>
    3054: f94002e1     	ldr	x1, [x23]
    3058: 2a0203e0     	mov	w0, w2
    305c: 8b000c20     	add	x0, x1, x0, lsl #3
    3060: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    3064: d360fc21     	lsr	x1, x1, #32
    3068: 92403c22     	and	x2, x1, #0xffff
    306c: f100085f     	cmp	x2, #0x2
    3070: 54000080     	b.eq	0x3080 <___pl_fn_4+0xbc>
    3074: f9400802     	ldr	x2, [x0, #0x10]
    3078: 9279f842     	and	x2, x2, #0xffffffffffffffbf
    307c: f9000802     	str	x2, [x0, #0x10]
    3080: 92403c21     	and	x1, x1, #0xffff
    3084: 91001821     	add	x1, x1, #0x6
    3088: f8217804     	str	x4, [x0, x1, lsl #3]
    308c: 14000026     	b	0x3124 <___pl_fn_4+0x160>
    3090: aa0103e2     	mov	x2, x1
    3094: aa0a03e4     	mov	x4, x10
    3098: aa0003f7     	mov	x23, x0
    309c: 34000842     	cbz	w2, 0x31a4 <___pl_fn_4+0x1e0>
    30a0: f94002e1     	ldr	x1, [x23]
    30a4: 2a0203e0     	mov	w0, w2
    30a8: 8b000c20     	add	x0, x1, x0, lsl #3
    30ac: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    30b0: d360fc21     	lsr	x1, x1, #32
    30b4: 92403c22     	and	x2, x1, #0xffff
    30b8: f100085f     	cmp	x2, #0x2
    30bc: 54000080     	b.eq	0x30cc <___pl_fn_4+0x108>
    30c0: f9400802     	ldr	x2, [x0, #0x10]
    30c4: 927af842     	and	x2, x2, #0xffffffffffffffdf
    30c8: f9000802     	str	x2, [x0, #0x10]
    30cc: 92403c21     	and	x1, x1, #0xffff
    30d0: 91001421     	add	x1, x1, #0x5
    30d4: f8217804     	str	x4, [x0, x1, lsl #3]
    30d8: 14000013     	b	0x3124 <___pl_fn_4+0x160>
    30dc: aa0103e2     	mov	x2, x1
    30e0: aa0a03e4     	mov	x4, x10
    30e4: aa0003f7     	mov	x23, x0
    30e8: 34000742     	cbz	w2, 0x31d0 <___pl_fn_4+0x20c>
    30ec: f94002e1     	ldr	x1, [x23]
    30f0: 2a0203e0     	mov	w0, w2
    30f4: 8b000c20     	add	x0, x1, x0, lsl #3
    30f8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    30fc: d360fc21     	lsr	x1, x1, #32
    3100: 92403c22     	and	x2, x1, #0xffff
    3104: f100085f     	cmp	x2, #0x2
    3108: 54000080     	b.eq	0x3118 <___pl_fn_4+0x154>
    310c: f9400802     	ldr	x2, [x0, #0x10]
    3110: 927bf842     	and	x2, x2, #0xffffffffffffffef
    3114: f9000802     	str	x2, [x0, #0x10]
    3118: 92403c25     	and	x5, x1, #0xffff
    311c: 910010a5     	add	x5, x5, #0x4
    3120: f8257804     	str	x4, [x0, x5, lsl #3]
    3124: b94012e7     	ldr	w7, [x23, #0x10]
    3128: 510004e7     	sub	w7, w7, #0x1
    312c: b90012e7     	str	w7, [x23, #0x10]
    3130: 910103ff     	add	sp, sp, #0x40
    3134: f84107f7     	ldr	x23, [sp], #0x10
    3138: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    313c: d65f03c0     	ret
    3140: aa0103e8     	mov	x8, x1
    3144: d28000ee     	mov	x14, #0x7               ; =7
    3148: 910003e3     	mov	x3, sp
    314c: f80003ee     	stur	x14, [sp]
    3150: aa0a03e4     	mov	x4, x10
    3154: f80083e4     	stur	x4, [sp, #0x8]
    3158: 52801041     	mov	w1, #0x82               ; =130
    315c: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3160: f9400084     	ldr	x4, [x4]
    3164: aa0803e2     	mov	x2, x8
    3168: aa0003f7     	mov	x23, x0
    316c: d63f0080     	blr	x4
    3170: 34fffda0     	cbz	w0, 0x3124 <___pl_fn_4+0x160>
    3174: 14000021     	b	0x31f8 <___pl_fn_4+0x234>
    3178: d28000c0     	mov	x0, #0x6                ; =6
    317c: 910043e3     	add	x3, sp, #0x10
    3180: f80103e0     	stur	x0, [sp, #0x10]
    3184: f80183e4     	stur	x4, [sp, #0x18]
    3188: 52801061     	mov	w1, #0x83               ; =131
    318c: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3190: f9400084     	ldr	x4, [x4]
    3194: aa1703e0     	mov	x0, x23
    3198: d63f0080     	blr	x4
    319c: 34fffc40     	cbz	w0, 0x3124 <___pl_fn_4+0x160>
    31a0: 14000016     	b	0x31f8 <___pl_fn_4+0x234>
    31a4: d28000a0     	mov	x0, #0x5                ; =5
    31a8: 910083e3     	add	x3, sp, #0x20
    31ac: f80203e0     	stur	x0, [sp, #0x20]
    31b0: f80283e4     	stur	x4, [sp, #0x28]
    31b4: 52801081     	mov	w1, #0x84               ; =132
    31b8: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    31bc: f9400084     	ldr	x4, [x4]
    31c0: aa1703e0     	mov	x0, x23
    31c4: d63f0080     	blr	x4
    31c8: 34fffae0     	cbz	w0, 0x3124 <___pl_fn_4+0x160>
    31cc: 1400000b     	b	0x31f8 <___pl_fn_4+0x234>
    31d0: d2800080     	mov	x0, #0x4                ; =4
    31d4: 9100c3e3     	add	x3, sp, #0x30
    31d8: f80303e0     	stur	x0, [sp, #0x30]
    31dc: f80383e4     	stur	x4, [sp, #0x38]
    31e0: 528010a1     	mov	w1, #0x85               ; =133
    31e4: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    31e8: f9400084     	ldr	x4, [x4]
    31ec: aa1703e0     	mov	x0, x23
    31f0: d63f0080     	blr	x4
    31f4: 34fff980     	cbz	w0, 0x3124 <___pl_fn_4+0x160>
    31f8: 910103ff     	add	sp, sp, #0x40
    31fc: f84107f7     	ldr	x23, [sp], #0x10
    3200: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3204: d65f03c0     	ret

0000000000003208 <___pl_fn_5>:
    3208: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    320c: 910003fd     	mov	x29, sp
    3210: f81f0ff7     	str	x23, [sp, #-0x10]!
    3214: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    3218: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    321c: d10083ff     	sub	sp, sp, #0x20
    3220: aa0303f3     	mov	x19, x3
    3224: aa0103f4     	mov	x20, x1
    3228: aa0203f6     	mov	x22, x2
    322c: b940100b     	ldr	w11, [x0, #0x10]
    3230: 1100056b     	add	w11, w11, #0x1
    3234: b900100b     	str	w11, [x0, #0x10]
    3238: aa0003f5     	mov	x21, x0
    323c: aa1403e1     	mov	x1, x20
    3240: 35000081     	cbnz	w1, 0x3250 <___pl_fn_5+0x48>
    3244: 1400005c     	b	0x33b4 <___pl_fn_5+0x1ac>
    3248: aa1603e2     	mov	x2, x22
    324c: 1400000b     	b	0x3278 <___pl_fn_5+0x70>
    3250: aa1503e0     	mov	x0, x21
    3254: f9400001     	ldr	x1, [x0]
    3258: 2a1403e0     	mov	w0, w20
    325c: 8b000c20     	add	x0, x1, x0, lsl #3
    3260: f8745822     	ldr	x2, [x1, w20, uxtw #3]
    3264: 2a1303e1     	mov	w1, w19
    3268: d360fc42     	lsr	x2, x2, #32
    326c: 92403c42     	and	x2, x2, #0xffff
    3270: f8227801     	str	x1, [x0, x2, lsl #3]
    3274: aa1603e2     	mov	x2, x22
    3278: 6b13005f     	cmp	w2, w19
    327c: 54000840     	b.eq	0x3384 <___pl_fn_5+0x17c>
    3280: 34001162     	cbz	w2, 0x34ac <___pl_fn_5+0x2a4>
    3284: aa0203f6     	mov	x22, x2
    3288: 34000b22     	cbz	w2, 0x33ec <___pl_fn_5+0x1e4>
    328c: aa1503e0     	mov	x0, x21
    3290: f9400001     	ldr	x1, [x0]
    3294: 2a0203e0     	mov	w0, w2
    3298: 8b000c20     	add	x0, x1, x0, lsl #3
    329c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    32a0: aa0203f7     	mov	x23, x2
    32a4: d360fc21     	lsr	x1, x1, #32
    32a8: 92403c21     	and	x1, x1, #0xffff
    32ac: d37df021     	lsl	x1, x1, #3
    32b0: b8616800     	ldr	w0, [x0, x1]
    32b4: 35000080     	cbnz	w0, 0x32c4 <___pl_fn_5+0xbc>
    32b8: 1400004e     	b	0x33f0 <___pl_fn_5+0x1e8>
    32bc: aa1503e0     	mov	x0, x21
    32c0: f9401800     	ldr	x0, [x0, #0x30]
    32c4: 6b13001f     	cmp	w0, w19
    32c8: 54000381     	b.ne	0x3338 <___pl_fn_5+0x130>
    32cc: aa1703e2     	mov	x2, x23
    32d0: 35000082     	cbnz	w2, 0x32e0 <___pl_fn_5+0xd8>
    32d4: 14000050     	b	0x3414 <___pl_fn_5+0x20c>
    32d8: aa1503e0     	mov	x0, x21
    32dc: 1400000b     	b	0x3308 <___pl_fn_5+0x100>
    32e0: aa1503e0     	mov	x0, x21
    32e4: f9400001     	ldr	x1, [x0]
    32e8: 2a0203e0     	mov	w0, w2
    32ec: 8b000c20     	add	x0, x1, x0, lsl #3
    32f0: f8625822     	ldr	x2, [x1, w2, uxtw #3]
    32f4: 2a1403e1     	mov	w1, w20
    32f8: d360fc42     	lsr	x2, x2, #32
    32fc: 92403c42     	and	x2, x2, #0xffff
    3300: f8227801     	str	x1, [x0, x2, lsl #3]
    3304: aa1503e0     	mov	x0, x21
    3308: aa1503e0     	mov	x0, x21
    330c: b9401000     	ldr	w0, [x0, #0x10]
    3310: 51000400     	sub	w0, w0, #0x1
    3314: aa1503e1     	mov	x1, x21
    3318: b9001020     	str	w0, [x1, #0x10]
    331c: aa1603e0     	mov	x0, x22
    3320: 910083ff     	add	sp, sp, #0x20
    3324: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3328: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    332c: f84107f7     	ldr	x23, [sp], #0x10
    3330: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3334: d65f03c0     	ret
    3338: aa1703e2     	mov	x2, x23
    333c: 34000842     	cbz	w2, 0x3444 <___pl_fn_5+0x23c>
    3340: aa1503e0     	mov	x0, x21
    3344: f9400001     	ldr	x1, [x0]
    3348: 2a0203e0     	mov	w0, w2
    334c: 8b000c20     	add	x0, x1, x0, lsl #3
    3350: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    3354: d360fc21     	lsr	x1, x1, #32
    3358: 92403c21     	and	x1, x1, #0xffff
    335c: d37df021     	lsl	x1, x1, #3
    3360: b8616800     	ldr	w0, [x0, x1]
    3364: 350000a0     	cbnz	w0, 0x3378 <___pl_fn_5+0x170>
    3368: 14000037     	b	0x3444 <___pl_fn_5+0x23c>
    336c: aa1503e0     	mov	x0, x21
    3370: f9401802     	ldr	x2, [x0, #0x30]
    3374: 14000002     	b	0x337c <___pl_fn_5+0x174>
    3378: aa0003e2     	mov	x2, x0
    337c: 34000802     	cbz	w2, 0x347c <___pl_fn_5+0x274>
    3380: 17ffffc2     	b	0x3288 <___pl_fn_5+0x80>
    3384: aa1503e0     	mov	x0, x21
    3388: b9401000     	ldr	w0, [x0, #0x10]
    338c: 51000400     	sub	w0, w0, #0x1
    3390: aa1503e1     	mov	x1, x21
    3394: b9001020     	str	w0, [x1, #0x10]
    3398: aa1403e0     	mov	x0, x20
    339c: 910083ff     	add	sp, sp, #0x20
    33a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    33a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    33a8: f84107f7     	ldr	x23, [sp], #0x10
    33ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    33b0: d65f03c0     	ret
    33b4: d280000e     	mov	x14, #0x0               ; =0
    33b8: 910003e3     	mov	x3, sp
    33bc: f80003ee     	stur	x14, [sp]
    33c0: aa1303e0     	mov	x0, x19
    33c4: 2a0003ef     	mov	w15, w0
    33c8: f80083ef     	stur	x15, [sp, #0x8]
    33cc: 528010c1     	mov	w1, #0x86               ; =134
    33d0: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    33d4: f9400084     	ldr	x4, [x4]
    33d8: aa1503e0     	mov	x0, x21
    33dc: aa1403e2     	mov	x2, x20
    33e0: d63f0080     	blr	x4
    33e4: 34fff320     	cbz	w0, 0x3248 <___pl_fn_5+0x40>
    33e8: 1400001e     	b	0x3460 <___pl_fn_5+0x258>
    33ec: aa0203f7     	mov	x23, x2
    33f0: 52801101     	mov	w1, #0x88               ; =136
    33f4: 52800003     	mov	w3, #0x0                ; =0
    33f8: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    33fc: f9400084     	ldr	x4, [x4]
    3400: aa1503e0     	mov	x0, x21
    3404: aa1703e2     	mov	x2, x23
    3408: d63f0080     	blr	x4
    340c: 34fff580     	cbz	w0, 0x32bc <___pl_fn_5+0xb4>
    3410: 14000014     	b	0x3460 <___pl_fn_5+0x258>
    3414: d2800000     	mov	x0, #0x0                ; =0
    3418: 910043e3     	add	x3, sp, #0x10
    341c: f80103e0     	stur	x0, [sp, #0x10]
    3420: 2a1403e0     	mov	w0, w20
    3424: f80183e0     	stur	x0, [sp, #0x18]
    3428: 52801121     	mov	w1, #0x89               ; =137
    342c: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3430: f9400084     	ldr	x4, [x4]
    3434: aa1503e0     	mov	x0, x21
    3438: d63f0080     	blr	x4
    343c: 34fff4e0     	cbz	w0, 0x32d8 <___pl_fn_5+0xd0>
    3440: 14000008     	b	0x3460 <___pl_fn_5+0x258>
    3444: 52801141     	mov	w1, #0x8a               ; =138
    3448: 52800003     	mov	w3, #0x0                ; =0
    344c: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3450: f9400084     	ldr	x4, [x4]
    3454: aa1503e0     	mov	x0, x21
    3458: d63f0080     	blr	x4
    345c: 34fff880     	cbz	w0, 0x336c <___pl_fn_5+0x164>
    3460: 52800000     	mov	w0, #0x0                ; =0
    3464: 910083ff     	add	sp, sp, #0x20
    3468: a8c153f3     	ldp	x19, x20, [sp], #0x10
    346c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3470: f84107f7     	ldr	x23, [sp], #0x10
    3474: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3478: d65f03c0     	ret
    347c: 52801161     	mov	w1, #0x8b               ; =139
    3480: 90000002     	adrp	x2, 0x3000 <___pl_fn_4+0x3c>
    3484: f9400042     	ldr	x2, [x2]
    3488: aa1503e0     	mov	x0, x21
    348c: d63f0040     	blr	x2
    3490: 52800000     	mov	w0, #0x0                ; =0
    3494: 910083ff     	add	sp, sp, #0x20
    3498: a8c153f3     	ldp	x19, x20, [sp], #0x10
    349c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    34a0: f84107f7     	ldr	x23, [sp], #0x10
    34a4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    34a8: d65f03c0     	ret
    34ac: 528010e1     	mov	w1, #0x87               ; =135
    34b0: 90000002     	adrp	x2, 0x3000 <___pl_fn_4+0x3c>
    34b4: f9400042     	ldr	x2, [x2]
    34b8: aa1503e0     	mov	x0, x21
    34bc: d63f0040     	blr	x2
    34c0: 52800000     	mov	w0, #0x0                ; =0
    34c4: 910083ff     	add	sp, sp, #0x20
    34c8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    34cc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    34d0: f84107f7     	ldr	x23, [sp], #0x10
    34d4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    34d8: d65f03c0     	ret

00000000000034dc <___pl_fn_6>:
    34dc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    34e0: 910003fd     	mov	x29, sp
    34e4: f81f0ff3     	str	x19, [sp, #-0x10]!
    34e8: d10183ff     	sub	sp, sp, #0x60
    34ec: aa0303e4     	mov	x4, x3
    34f0: b9401003     	ldr	w3, [x0, #0x10]
    34f4: 11000463     	add	w3, w3, #0x1
    34f8: b9001003     	str	w3, [x0, #0x10]
    34fc: aa0003e5     	mov	x5, x0
    3500: f100045f     	cmp	x2, #0x1
    3504: 540009e0     	b.eq	0x3640 <___pl_fn_6+0x164>
    3508: f100085f     	cmp	x2, #0x2
    350c: 540007e0     	b.eq	0x3608 <___pl_fn_6+0x12c>
    3510: f1000c5f     	cmp	x2, #0x3
    3514: 540005e0     	b.eq	0x35d0 <___pl_fn_6+0xf4>
    3518: f100105f     	cmp	x2, #0x4
    351c: 540003e0     	b.eq	0x3598 <___pl_fn_6+0xbc>
    3520: f100145f     	cmp	x2, #0x5
    3524: 540001e0     	b.eq	0x3560 <___pl_fn_6+0x84>
    3528: 34000b41     	cbz	w1, 0x3690 <___pl_fn_6+0x1b4>
    352c: aa0403e0     	mov	x0, x4
    3530: aa0103e2     	mov	x2, x1
    3534: aa0503f3     	mov	x19, x5
    3538: f9400263     	ldr	x3, [x19]
    353c: 2a0203e1     	mov	w1, w2
    3540: 8b010c61     	add	x1, x3, x1, lsl #3
    3544: f8625862     	ldr	x2, [x3, w2, uxtw #3]
    3548: 2a0003e0     	mov	w0, w0
    354c: d360fc42     	lsr	x2, x2, #32
    3550: 92403c42     	and	x2, x2, #0xffff
    3554: 91002042     	add	x2, x2, #0x8
    3558: f8227820     	str	x0, [x1, x2, lsl #3]
    355c: 14000046     	b	0x3674 <___pl_fn_6+0x198>
    3560: aa0403e0     	mov	x0, x4
    3564: aa0103e2     	mov	x2, x1
    3568: aa0503f3     	mov	x19, x5
    356c: 34000b02     	cbz	w2, 0x36cc <___pl_fn_6+0x1f0>
    3570: f9400263     	ldr	x3, [x19]
    3574: 2a0203e1     	mov	w1, w2
    3578: 8b010c61     	add	x1, x3, x1, lsl #3
    357c: f8625862     	ldr	x2, [x3, w2, uxtw #3]
    3580: 2a0003e0     	mov	w0, w0
    3584: d360fc42     	lsr	x2, x2, #32
    3588: 92403c42     	and	x2, x2, #0xffff
    358c: 91001c42     	add	x2, x2, #0x7
    3590: f8227820     	str	x0, [x1, x2, lsl #3]
    3594: 14000038     	b	0x3674 <___pl_fn_6+0x198>
    3598: aa0403e0     	mov	x0, x4
    359c: aa0103e2     	mov	x2, x1
    35a0: aa0503f3     	mov	x19, x5
    35a4: 34000ac2     	cbz	w2, 0x36fc <___pl_fn_6+0x220>
    35a8: f9400264     	ldr	x4, [x19]
    35ac: 2a0203e3     	mov	w3, w2
    35b0: 8b030c83     	add	x3, x4, x3, lsl #3
    35b4: f8625885     	ldr	x5, [x4, w2, uxtw #3]
    35b8: 2a0003e4     	mov	w4, w0
    35bc: d360fca5     	lsr	x5, x5, #32
    35c0: 92403ca5     	and	x5, x5, #0xffff
    35c4: 910018a5     	add	x5, x5, #0x6
    35c8: f8257864     	str	x4, [x3, x5, lsl #3]
    35cc: 1400002a     	b	0x3674 <___pl_fn_6+0x198>
    35d0: aa0403e0     	mov	x0, x4
    35d4: aa0103e2     	mov	x2, x1
    35d8: aa0503f3     	mov	x19, x5
    35dc: 34000a82     	cbz	w2, 0x372c <___pl_fn_6+0x250>
    35e0: f940026d     	ldr	x13, [x19]
    35e4: 2a0203ec     	mov	w12, w2
    35e8: 8b0c0dac     	add	x12, x13, x12, lsl #3
    35ec: f86259ae     	ldr	x14, [x13, w2, uxtw #3]
    35f0: 2a0003ed     	mov	w13, w0
    35f4: d360fdce     	lsr	x14, x14, #32
    35f8: 92403dce     	and	x14, x14, #0xffff
    35fc: 910015ce     	add	x14, x14, #0x5
    3600: f82e798d     	str	x13, [x12, x14, lsl #3]
    3604: 1400001c     	b	0x3674 <___pl_fn_6+0x198>
    3608: aa0403e0     	mov	x0, x4
    360c: aa0103e2     	mov	x2, x1
    3610: aa0503f3     	mov	x19, x5
    3614: 34000a42     	cbz	w2, 0x375c <___pl_fn_6+0x280>
    3618: f9400263     	ldr	x3, [x19]
    361c: 2a0203e1     	mov	w1, w2
    3620: 8b010c61     	add	x1, x3, x1, lsl #3
    3624: f8625862     	ldr	x2, [x3, w2, uxtw #3]
    3628: 2a0003e0     	mov	w0, w0
    362c: d360fc42     	lsr	x2, x2, #32
    3630: 92403c42     	and	x2, x2, #0xffff
    3634: 91001042     	add	x2, x2, #0x4
    3638: f8227820     	str	x0, [x1, x2, lsl #3]
    363c: 1400000e     	b	0x3674 <___pl_fn_6+0x198>
    3640: aa0403e0     	mov	x0, x4
    3644: aa0103e2     	mov	x2, x1
    3648: aa0503f3     	mov	x19, x5
    364c: 34000a02     	cbz	w2, 0x378c <___pl_fn_6+0x2b0>
    3650: f9400263     	ldr	x3, [x19]
    3654: 2a0203e1     	mov	w1, w2
    3658: 8b010c61     	add	x1, x3, x1, lsl #3
    365c: f8625862     	ldr	x2, [x3, w2, uxtw #3]
    3660: 2a0003e0     	mov	w0, w0
    3664: d360fc42     	lsr	x2, x2, #32
    3668: 92403c42     	and	x2, x2, #0xffff
    366c: 91000c42     	add	x2, x2, #0x3
    3670: f8227820     	str	x0, [x1, x2, lsl #3]
    3674: b9401260     	ldr	w0, [x19, #0x10]
    3678: 51000400     	sub	w0, w0, #0x1
    367c: b9001260     	str	w0, [x19, #0x10]
    3680: 910183ff     	add	sp, sp, #0x60
    3684: f84107f3     	ldr	x19, [sp], #0x10
    3688: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    368c: d65f03c0     	ret
    3690: aa0103e2     	mov	x2, x1
    3694: d2800100     	mov	x0, #0x8                ; =8
    3698: 910003e3     	mov	x3, sp
    369c: f80003e0     	stur	x0, [sp]
    36a0: aa0403e0     	mov	x0, x4
    36a4: 2a0003e0     	mov	w0, w0
    36a8: f80083e0     	stur	x0, [sp, #0x8]
    36ac: 52801181     	mov	w1, #0x8c               ; =140
    36b0: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    36b4: f9400084     	ldr	x4, [x4]
    36b8: aa0503f3     	mov	x19, x5
    36bc: aa1303e0     	mov	x0, x19
    36c0: d63f0080     	blr	x4
    36c4: 34fffd80     	cbz	w0, 0x3674 <___pl_fn_6+0x198>
    36c8: 1400003c     	b	0x37b8 <___pl_fn_6+0x2dc>
    36cc: d28000e1     	mov	x1, #0x7                ; =7
    36d0: 910043e3     	add	x3, sp, #0x10
    36d4: f80103e1     	stur	x1, [sp, #0x10]
    36d8: 2a0003e0     	mov	w0, w0
    36dc: f80183e0     	stur	x0, [sp, #0x18]
    36e0: 528011a1     	mov	w1, #0x8d               ; =141
    36e4: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    36e8: f9400084     	ldr	x4, [x4]
    36ec: aa1303e0     	mov	x0, x19
    36f0: d63f0080     	blr	x4
    36f4: 34fffc00     	cbz	w0, 0x3674 <___pl_fn_6+0x198>
    36f8: 14000030     	b	0x37b8 <___pl_fn_6+0x2dc>
    36fc: d28000c1     	mov	x1, #0x6                ; =6
    3700: 910083e3     	add	x3, sp, #0x20
    3704: f80203e1     	stur	x1, [sp, #0x20]
    3708: 2a0003e0     	mov	w0, w0
    370c: f80283e0     	stur	x0, [sp, #0x28]
    3710: 528011c1     	mov	w1, #0x8e               ; =142
    3714: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3718: f9400084     	ldr	x4, [x4]
    371c: aa1303e0     	mov	x0, x19
    3720: d63f0080     	blr	x4
    3724: 34fffa80     	cbz	w0, 0x3674 <___pl_fn_6+0x198>
    3728: 14000024     	b	0x37b8 <___pl_fn_6+0x2dc>
    372c: d28000a7     	mov	x7, #0x5                ; =5
    3730: 9100c3e3     	add	x3, sp, #0x30
    3734: f80303e7     	stur	x7, [sp, #0x30]
    3738: 2a0003e8     	mov	w8, w0
    373c: f80383e8     	stur	x8, [sp, #0x38]
    3740: 528011e1     	mov	w1, #0x8f               ; =143
    3744: 90000009     	adrp	x9, 0x3000 <___pl_fn_4+0x3c>
    3748: f9400129     	ldr	x9, [x9]
    374c: aa1303e0     	mov	x0, x19
    3750: d63f0120     	blr	x9
    3754: 34fff900     	cbz	w0, 0x3674 <___pl_fn_6+0x198>
    3758: 14000018     	b	0x37b8 <___pl_fn_6+0x2dc>
    375c: d2800081     	mov	x1, #0x4                ; =4
    3760: 910103e3     	add	x3, sp, #0x40
    3764: f80403e1     	stur	x1, [sp, #0x40]
    3768: 2a0003e0     	mov	w0, w0
    376c: f80483e0     	stur	x0, [sp, #0x48]
    3770: 52801201     	mov	w1, #0x90               ; =144
    3774: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3778: f9400084     	ldr	x4, [x4]
    377c: aa1303e0     	mov	x0, x19
    3780: d63f0080     	blr	x4
    3784: 34fff780     	cbz	w0, 0x3674 <___pl_fn_6+0x198>
    3788: 1400000c     	b	0x37b8 <___pl_fn_6+0x2dc>
    378c: d2800061     	mov	x1, #0x3                ; =3
    3790: 910143e3     	add	x3, sp, #0x50
    3794: f80503e1     	stur	x1, [sp, #0x50]
    3798: 2a0003e0     	mov	w0, w0
    379c: f80583e0     	stur	x0, [sp, #0x58]
    37a0: 52801221     	mov	w1, #0x91               ; =145
    37a4: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    37a8: f9400084     	ldr	x4, [x4]
    37ac: aa1303e0     	mov	x0, x19
    37b0: d63f0080     	blr	x4
    37b4: 34fff600     	cbz	w0, 0x3674 <___pl_fn_6+0x198>
    37b8: 910183ff     	add	sp, sp, #0x60
    37bc: f84107f3     	ldr	x19, [sp], #0x10
    37c0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    37c4: d65f03c0     	ret

00000000000037c8 <___pl_fn_7>:
    37c8: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    37cc: 910003fd     	mov	x29, sp
    37d0: f81f0ff3     	str	x19, [sp, #-0x10]!
    37d4: b9401003     	ldr	w3, [x0, #0x10]
    37d8: 11000463     	add	w3, w3, #0x1
    37dc: b9001003     	str	w3, [x0, #0x10]
    37e0: f100045f     	cmp	x2, #0x1
    37e4: 54000e80     	b.eq	0x39b4 <___pl_fn_7+0x1ec>
    37e8: f100085f     	cmp	x2, #0x2
    37ec: 54000ba0     	b.eq	0x3960 <___pl_fn_7+0x198>
    37f0: f1000c5f     	cmp	x2, #0x3
    37f4: 540008c0     	b.eq	0x390c <___pl_fn_7+0x144>
    37f8: f100105f     	cmp	x2, #0x4
    37fc: 540005e0     	b.eq	0x38b8 <___pl_fn_7+0xf0>
    3800: f100145f     	cmp	x2, #0x5
    3804: 54000300     	b.eq	0x3864 <___pl_fn_7+0x9c>
    3808: 34001001     	cbz	w1, 0x3a08 <___pl_fn_7+0x240>
    380c: f9400002     	ldr	x2, [x0]
    3810: aa0003e5     	mov	x5, x0
    3814: 2a0103e0     	mov	w0, w1
    3818: 8b000c40     	add	x0, x2, x0, lsl #3
    381c: f8615842     	ldr	x2, [x2, w1, uxtw #3]
    3820: aa0103e6     	mov	x6, x1
    3824: d360fc41     	lsr	x1, x2, #32
    3828: 92403c21     	and	x1, x1, #0xffff
    382c: 91002021     	add	x1, x1, #0x8
    3830: d37df021     	lsl	x1, x1, #3
    3834: b8616800     	ldr	w0, [x0, x1]
    3838: 35000080     	cbnz	w0, 0x3848 <___pl_fn_7+0x80>
    383c: 14000075     	b	0x3a10 <___pl_fn_7+0x248>
    3840: f9401a60     	ldr	x0, [x19, #0x30]
    3844: 14000002     	b	0x384c <___pl_fn_7+0x84>
    3848: aa0503f3     	mov	x19, x5
    384c: b9401264     	ldr	w4, [x19, #0x10]
    3850: 51000484     	sub	w4, w4, #0x1
    3854: b9001264     	str	w4, [x19, #0x10]
    3858: f84107f3     	ldr	x19, [sp], #0x10
    385c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3860: d65f03c0     	ret
    3864: aa0103e2     	mov	x2, x1
    3868: aa0003f3     	mov	x19, x0
    386c: 34000e62     	cbz	w2, 0x3a38 <___pl_fn_7+0x270>
    3870: f9400269     	ldr	x9, [x19]
    3874: 2a0203e8     	mov	w8, w2
    3878: 8b080d28     	add	x8, x9, x8, lsl #3
    387c: f8625929     	ldr	x9, [x9, w2, uxtw #3]
    3880: d360fd29     	lsr	x9, x9, #32
    3884: 92403d29     	and	x9, x9, #0xffff
    3888: 91001d29     	add	x9, x9, #0x7
    388c: d37df129     	lsl	x9, x9, #3
    3890: b8696900     	ldr	w0, [x8, x9]
    3894: 35000060     	cbnz	w0, 0x38a0 <___pl_fn_7+0xd8>
    3898: 14000068     	b	0x3a38 <___pl_fn_7+0x270>
    389c: f9401a60     	ldr	x0, [x19, #0x30]
    38a0: b940126e     	ldr	w14, [x19, #0x10]
    38a4: 510005ce     	sub	w14, w14, #0x1
    38a8: b900126e     	str	w14, [x19, #0x10]
    38ac: f84107f3     	ldr	x19, [sp], #0x10
    38b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    38b4: d65f03c0     	ret
    38b8: aa0103e2     	mov	x2, x1
    38bc: aa0003f3     	mov	x19, x0
    38c0: 34000cc2     	cbz	w2, 0x3a58 <___pl_fn_7+0x290>
    38c4: f9400261     	ldr	x1, [x19]
    38c8: 2a0203e0     	mov	w0, w2
    38cc: 8b000c20     	add	x0, x1, x0, lsl #3
    38d0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    38d4: d360fc21     	lsr	x1, x1, #32
    38d8: 92403c21     	and	x1, x1, #0xffff
    38dc: 91001821     	add	x1, x1, #0x6
    38e0: d37df021     	lsl	x1, x1, #3
    38e4: b8616800     	ldr	w0, [x0, x1]
    38e8: 35000060     	cbnz	w0, 0x38f4 <___pl_fn_7+0x12c>
    38ec: 1400005b     	b	0x3a58 <___pl_fn_7+0x290>
    38f0: f9401a60     	ldr	x0, [x19, #0x30]
    38f4: b9401261     	ldr	w1, [x19, #0x10]
    38f8: 51000421     	sub	w1, w1, #0x1
    38fc: b9001261     	str	w1, [x19, #0x10]
    3900: f84107f3     	ldr	x19, [sp], #0x10
    3904: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3908: d65f03c0     	ret
    390c: aa0103e2     	mov	x2, x1
    3910: aa0003f3     	mov	x19, x0
    3914: 34000b22     	cbz	w2, 0x3a78 <___pl_fn_7+0x2b0>
    3918: f9400261     	ldr	x1, [x19]
    391c: 2a0203e0     	mov	w0, w2
    3920: 8b000c20     	add	x0, x1, x0, lsl #3
    3924: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    3928: d360fc21     	lsr	x1, x1, #32
    392c: 92403c21     	and	x1, x1, #0xffff
    3930: 91001421     	add	x1, x1, #0x5
    3934: d37df021     	lsl	x1, x1, #3
    3938: b8616800     	ldr	w0, [x0, x1]
    393c: 35000060     	cbnz	w0, 0x3948 <___pl_fn_7+0x180>
    3940: 1400004e     	b	0x3a78 <___pl_fn_7+0x2b0>
    3944: f9401a60     	ldr	x0, [x19, #0x30]
    3948: b9401261     	ldr	w1, [x19, #0x10]
    394c: 51000421     	sub	w1, w1, #0x1
    3950: b9001261     	str	w1, [x19, #0x10]
    3954: f84107f3     	ldr	x19, [sp], #0x10
    3958: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    395c: d65f03c0     	ret
    3960: aa0103e2     	mov	x2, x1
    3964: aa0003f3     	mov	x19, x0
    3968: 34000982     	cbz	w2, 0x3a98 <___pl_fn_7+0x2d0>
    396c: f9400261     	ldr	x1, [x19]
    3970: 2a0203e0     	mov	w0, w2
    3974: 8b000c20     	add	x0, x1, x0, lsl #3
    3978: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    397c: d360fc21     	lsr	x1, x1, #32
    3980: 92403c21     	and	x1, x1, #0xffff
    3984: 91001021     	add	x1, x1, #0x4
    3988: d37df021     	lsl	x1, x1, #3
    398c: b8616800     	ldr	w0, [x0, x1]
    3990: 35000060     	cbnz	w0, 0x399c <___pl_fn_7+0x1d4>
    3994: 14000041     	b	0x3a98 <___pl_fn_7+0x2d0>
    3998: f9401a60     	ldr	x0, [x19, #0x30]
    399c: b9401261     	ldr	w1, [x19, #0x10]
    39a0: 51000421     	sub	w1, w1, #0x1
    39a4: b9001261     	str	w1, [x19, #0x10]
    39a8: f84107f3     	ldr	x19, [sp], #0x10
    39ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    39b0: d65f03c0     	ret
    39b4: aa0103e2     	mov	x2, x1
    39b8: aa0003f3     	mov	x19, x0
    39bc: 340007e2     	cbz	w2, 0x3ab8 <___pl_fn_7+0x2f0>
    39c0: f9400261     	ldr	x1, [x19]
    39c4: 2a0203e0     	mov	w0, w2
    39c8: 8b000c20     	add	x0, x1, x0, lsl #3
    39cc: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    39d0: d360fc21     	lsr	x1, x1, #32
    39d4: 92403c21     	and	x1, x1, #0xffff
    39d8: 91000c21     	add	x1, x1, #0x3
    39dc: d37df021     	lsl	x1, x1, #3
    39e0: b8616800     	ldr	w0, [x0, x1]
    39e4: 35000060     	cbnz	w0, 0x39f0 <___pl_fn_7+0x228>
    39e8: 14000034     	b	0x3ab8 <___pl_fn_7+0x2f0>
    39ec: f9401a60     	ldr	x0, [x19, #0x30]
    39f0: b9401261     	ldr	w1, [x19, #0x10]
    39f4: 51000421     	sub	w1, w1, #0x1
    39f8: b9001261     	str	w1, [x19, #0x10]
    39fc: f84107f3     	ldr	x19, [sp], #0x10
    3a00: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3a04: d65f03c0     	ret
    3a08: aa0003e5     	mov	x5, x0
    3a0c: aa0103e6     	mov	x6, x1
    3a10: 52801241     	mov	w1, #0x92               ; =146
    3a14: 52800103     	mov	w3, #0x8                ; =8
    3a18: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3a1c: f9400084     	ldr	x4, [x4]
    3a20: aa0603e2     	mov	x2, x6
    3a24: aa0503f3     	mov	x19, x5
    3a28: aa1303e0     	mov	x0, x19
    3a2c: d63f0080     	blr	x4
    3a30: 34fff080     	cbz	w0, 0x3840 <___pl_fn_7+0x78>
    3a34: 14000028     	b	0x3ad4 <___pl_fn_7+0x30c>
    3a38: 52801261     	mov	w1, #0x93               ; =147
    3a3c: 528000e3     	mov	w3, #0x7                ; =7
    3a40: 9000000a     	adrp	x10, 0x3000 <___pl_fn_4+0x3c>
    3a44: f940014a     	ldr	x10, [x10]
    3a48: aa1303e0     	mov	x0, x19
    3a4c: d63f0140     	blr	x10
    3a50: 34fff260     	cbz	w0, 0x389c <___pl_fn_7+0xd4>
    3a54: 14000020     	b	0x3ad4 <___pl_fn_7+0x30c>
    3a58: 52801281     	mov	w1, #0x94               ; =148
    3a5c: 528000c3     	mov	w3, #0x6                ; =6
    3a60: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3a64: f9400084     	ldr	x4, [x4]
    3a68: aa1303e0     	mov	x0, x19
    3a6c: d63f0080     	blr	x4
    3a70: 34fff400     	cbz	w0, 0x38f0 <___pl_fn_7+0x128>
    3a74: 14000018     	b	0x3ad4 <___pl_fn_7+0x30c>
    3a78: 528012a1     	mov	w1, #0x95               ; =149
    3a7c: 528000a3     	mov	w3, #0x5                ; =5
    3a80: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3a84: f9400084     	ldr	x4, [x4]
    3a88: aa1303e0     	mov	x0, x19
    3a8c: d63f0080     	blr	x4
    3a90: 34fff5a0     	cbz	w0, 0x3944 <___pl_fn_7+0x17c>
    3a94: 14000010     	b	0x3ad4 <___pl_fn_7+0x30c>
    3a98: 528012c1     	mov	w1, #0x96               ; =150
    3a9c: 52800083     	mov	w3, #0x4                ; =4
    3aa0: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3aa4: f9400084     	ldr	x4, [x4]
    3aa8: aa1303e0     	mov	x0, x19
    3aac: d63f0080     	blr	x4
    3ab0: 34fff740     	cbz	w0, 0x3998 <___pl_fn_7+0x1d0>
    3ab4: 14000008     	b	0x3ad4 <___pl_fn_7+0x30c>
    3ab8: 528012e1     	mov	w1, #0x97               ; =151
    3abc: 52800063     	mov	w3, #0x3                ; =3
    3ac0: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3ac4: f9400084     	ldr	x4, [x4]
    3ac8: aa1303e0     	mov	x0, x19
    3acc: d63f0080     	blr	x4
    3ad0: 34fff8e0     	cbz	w0, 0x39ec <___pl_fn_7+0x224>
    3ad4: 52800000     	mov	w0, #0x0                ; =0
    3ad8: f84107f3     	ldr	x19, [sp], #0x10
    3adc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3ae0: d65f03c0     	ret

0000000000003ae4 <___pl_fn_8>:
    3ae4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    3ae8: 910003fd     	mov	x29, sp
    3aec: f81f0ffb     	str	x27, [sp, #-0x10]!
    3af0: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
    3af4: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
    3af8: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    3afc: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    3b00: d10243ff     	sub	sp, sp, #0x90
    3b04: aa0103f3     	mov	x19, x1
    3b08: aa0303f7     	mov	x23, x3
    3b0c: aa0703f8     	mov	x24, x7
    3b10: aa0603f9     	mov	x25, x6
    3b14: aa0503fa     	mov	x26, x5
    3b18: aa0403fb     	mov	x27, x4
    3b1c: b9401001     	ldr	w1, [x0, #0x10]
    3b20: 11000421     	add	w1, w1, #0x1
    3b24: b9001001     	str	w1, [x0, #0x10]
    3b28: aa0003f6     	mov	x22, x0
    3b2c: aa1303e1     	mov	x1, x19
    3b30: 340015c1     	cbz	w1, 0x3de8 <___pl_fn_8+0x304>
    3b34: aa1603e0     	mov	x0, x22
    3b38: aa0203f4     	mov	x20, x2
    3b3c: f9400001     	ldr	x1, [x0]
    3b40: 2a1303e0     	mov	w0, w19
    3b44: 8b000c20     	add	x0, x1, x0, lsl #3
    3b48: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    3b4c: 2a1403e1     	mov	w1, w20
    3b50: d360fc42     	lsr	x2, x2, #32
    3b54: 92403c42     	and	x2, x2, #0xffff
    3b58: 91001c42     	add	x2, x2, #0x7
    3b5c: f8227801     	str	x1, [x0, x2, lsl #3]
    3b60: 34001614     	cbz	w20, 0x3e20 <___pl_fn_8+0x33c>
    3b64: aa1603e0     	mov	x0, x22
    3b68: f9400001     	ldr	x1, [x0]
    3b6c: 2a1403e0     	mov	w0, w20
    3b70: 8b000c20     	add	x0, x1, x0, lsl #3
    3b74: f8745821     	ldr	x1, [x1, w20, uxtw #3]
    3b78: d360fc21     	lsr	x1, x1, #32
    3b7c: 92403c21     	and	x1, x1, #0xffff
    3b80: d37df021     	lsl	x1, x1, #3
    3b84: b8616800     	ldr	w0, [x0, x1]
    3b88: 35000080     	cbnz	w0, 0x3b98 <___pl_fn_8+0xb4>
    3b8c: 140000a5     	b	0x3e20 <___pl_fn_8+0x33c>
    3b90: aa1603e0     	mov	x0, x22
    3b94: f9401800     	ldr	x0, [x0, #0x30]
    3b98: 34001573     	cbz	w19, 0x3e44 <___pl_fn_8+0x360>
    3b9c: aa1603e1     	mov	x1, x22
    3ba0: f9400024     	ldr	x4, [x1]
    3ba4: 2a1303e3     	mov	w3, w19
    3ba8: 8b030c83     	add	x3, x4, x3, lsl #3
    3bac: f8735885     	ldr	x5, [x4, w19, uxtw #3]
    3bb0: 2a0003e4     	mov	w4, w0
    3bb4: d360fca5     	lsr	x5, x5, #32
    3bb8: 92403ca5     	and	x5, x5, #0xffff
    3bbc: f8257864     	str	x4, [x3, x5, lsl #3]
    3bc0: 35000093     	cbnz	w19, 0x3bd0 <___pl_fn_8+0xec>
    3bc4: 140000ad     	b	0x3e78 <___pl_fn_8+0x394>
    3bc8: aa1503f7     	mov	x23, x21
    3bcc: 14000012     	b	0x3c14 <___pl_fn_8+0x130>
    3bd0: aa1603e0     	mov	x0, x22
    3bd4: aa1703f5     	mov	x21, x23
    3bd8: f940000c     	ldr	x12, [x0]
    3bdc: 2a1303eb     	mov	w11, w19
    3be0: 8b0b0d8b     	add	x11, x12, x11, lsl #3
    3be4: f873598c     	ldr	x12, [x12, w19, uxtw #3]
    3be8: d360fd8c     	lsr	x12, x12, #32
    3bec: 92403d8d     	and	x13, x12, #0xffff
    3bf0: f10009bf     	cmp	x13, #0x2
    3bf4: 54000080     	b.eq	0x3c04 <___pl_fn_8+0x120>
    3bf8: f940096e     	ldr	x14, [x11, #0x10]
    3bfc: 927ef9ce     	and	x14, x14, #0xfffffffffffffffd
    3c00: f900096e     	str	x14, [x11, #0x10]
    3c04: 92403d80     	and	x0, x12, #0xffff
    3c08: 91000400     	add	x0, x0, #0x1
    3c0c: f8207975     	str	x21, [x11, x0, lsl #3]
    3c10: aa1503f7     	mov	x23, x21
    3c14: 340014d3     	cbz	w19, 0x3eac <___pl_fn_8+0x3c8>
    3c18: aa1603e0     	mov	x0, x22
    3c1c: aa1b03e4     	mov	x4, x27
    3c20: f9400001     	ldr	x1, [x0]
    3c24: 2a1303e0     	mov	w0, w19
    3c28: 8b000c20     	add	x0, x1, x0, lsl #3
    3c2c: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    3c30: d360fc21     	lsr	x1, x1, #32
    3c34: 92403c22     	and	x2, x1, #0xffff
    3c38: f100085f     	cmp	x2, #0x2
    3c3c: 54000080     	b.eq	0x3c4c <___pl_fn_8+0x168>
    3c40: f9400802     	ldr	x2, [x0, #0x10]
    3c44: 927df842     	and	x2, x2, #0xfffffffffffffffb
    3c48: f9000802     	str	x2, [x0, #0x10]
    3c4c: 92403c21     	and	x1, x1, #0xffff
    3c50: 91000821     	add	x1, x1, #0x2
    3c54: f8217804     	str	x4, [x0, x1, lsl #3]
    3c58: 34001453     	cbz	w19, 0x3ee0 <___pl_fn_8+0x3fc>
    3c5c: aa1603e0     	mov	x0, x22
    3c60: aa1a03e5     	mov	x5, x26
    3c64: f9400001     	ldr	x1, [x0]
    3c68: 2a1303e0     	mov	w0, w19
    3c6c: 8b000c20     	add	x0, x1, x0, lsl #3
    3c70: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    3c74: 2a0503e1     	mov	w1, w5
    3c78: d360fc42     	lsr	x2, x2, #32
    3c7c: 92403c42     	and	x2, x2, #0xffff
    3c80: 91000c42     	add	x2, x2, #0x3
    3c84: f8227801     	str	x1, [x0, x2, lsl #3]
    3c88: 34001493     	cbz	w19, 0x3f18 <___pl_fn_8+0x434>
    3c8c: aa1603e0     	mov	x0, x22
    3c90: aa1903e6     	mov	x6, x25
    3c94: f9400001     	ldr	x1, [x0]
    3c98: 2a1303e0     	mov	w0, w19
    3c9c: 8b000c20     	add	x0, x1, x0, lsl #3
    3ca0: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    3ca4: 53001cc1     	uxtb	w1, w6
    3ca8: d360fc42     	lsr	x2, x2, #32
    3cac: 92403c42     	and	x2, x2, #0xffff
    3cb0: 91001042     	add	x2, x2, #0x4
    3cb4: f8227801     	str	x1, [x0, x2, lsl #3]
    3cb8: 340014d3     	cbz	w19, 0x3f50 <___pl_fn_8+0x46c>
    3cbc: aa1603e0     	mov	x0, x22
    3cc0: aa1803e7     	mov	x7, x24
    3cc4: f9400001     	ldr	x1, [x0]
    3cc8: 2a1303e0     	mov	w0, w19
    3ccc: 8b000c20     	add	x0, x1, x0, lsl #3
    3cd0: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    3cd4: 53001ce1     	uxtb	w1, w7
    3cd8: d360fc42     	lsr	x2, x2, #32
    3cdc: 92403c42     	and	x2, x2, #0xffff
    3ce0: 91001442     	add	x2, x2, #0x5
    3ce4: f8227801     	str	x1, [x0, x2, lsl #3]
    3ce8: 34001513     	cbz	w19, 0x3f88 <___pl_fn_8+0x4a4>
    3cec: aa1603e0     	mov	x0, x22
    3cf0: f9400001     	ldr	x1, [x0]
    3cf4: 2a1303e0     	mov	w0, w19
    3cf8: 8b000c20     	add	x0, x1, x0, lsl #3
    3cfc: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    3d00: d2800001     	mov	x1, #0x0                ; =0
    3d04: d360fc42     	lsr	x2, x2, #32
    3d08: 92403c42     	and	x2, x2, #0xffff
    3d0c: 91001842     	add	x2, x2, #0x6
    3d10: f8227801     	str	x1, [x0, x2, lsl #3]
    3d14: 35000094     	cbnz	w20, 0x3d24 <___pl_fn_8+0x240>
    3d18: 140000a9     	b	0x3fbc <___pl_fn_8+0x4d8>
    3d1c: aa1603e0     	mov	x0, x22
    3d20: 1400000a     	b	0x3d48 <___pl_fn_8+0x264>
    3d24: aa1603e0     	mov	x0, x22
    3d28: f9400007     	ldr	x7, [x0]
    3d2c: 2a1403e6     	mov	w6, w20
    3d30: 8b060ce6     	add	x6, x7, x6, lsl #3
    3d34: f87458e8     	ldr	x8, [x7, w20, uxtw #3]
    3d38: 2a1303e7     	mov	w7, w19
    3d3c: d360fd08     	lsr	x8, x8, #32
    3d40: 92403d08     	and	x8, x8, #0xffff
    3d44: f82878c7     	str	x7, [x6, x8, lsl #3]
    3d48: aa1603e0     	mov	x0, x22
    3d4c: b9401815     	ldr	w21, [x0, #0x18]
    3d50: b9401c08     	ldr	w8, [x0, #0x1c]
    3d54: 11000aa9     	add	w9, w21, #0x2
    3d58: 6b08013f     	cmp	w9, w8
    3d5c: 54001728     	b.hi	0x4040 <___pl_fn_8+0x55c>
    3d60: aa1603e0     	mov	x0, x22
    3d64: f940100a     	ldr	x10, [x0, #0x20]
    3d68: 2a1503eb     	mov	w11, w21
    3d6c: 8b0b094b     	add	x11, x10, x11, lsl #2
    3d70: b8355953     	str	w19, [x10, w21, uxtw #2]
    3d74: b9000574     	str	w20, [x11, #0x4]
    3d78: 11000aac     	add	w12, w21, #0x2
    3d7c: b900180c     	str	w12, [x0, #0x18]
    3d80: b940100d     	ldr	w13, [x0, #0x10]
    3d84: b940140e     	ldr	w14, [x0, #0x14]
    3d88: 6b0e01bf     	cmp	w13, w14
    3d8c: 54001402     	b.hs	0x400c <___pl_fn_8+0x528>
    3d90: aa1403e1     	mov	x1, x20
    3d94: aa1703e2     	mov	x2, x23
    3d98: aa1303e3     	mov	x3, x19
    3d9c: aa1603e0     	mov	x0, x22
    3da0: 94000000     	bl	0x3da0 <___pl_fn_8+0x2bc>
    3da4: aa1603e0     	mov	x0, x22
    3da8: b9402c00     	ldr	w0, [x0, #0x2c]
    3dac: 35001200     	cbnz	w0, 0x3fec <___pl_fn_8+0x508>
    3db0: aa1603e0     	mov	x0, x22
    3db4: b9001815     	str	w21, [x0, #0x18]
    3db8: b9401000     	ldr	w0, [x0, #0x10]
    3dbc: 51000400     	sub	w0, w0, #0x1
    3dc0: aa1603ed     	mov	x13, x22
    3dc4: b90011a0     	str	w0, [x13, #0x10]
    3dc8: 910243ff     	add	sp, sp, #0x90
    3dcc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3dd0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3dd4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3dd8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3ddc: f84107fb     	ldr	x27, [sp], #0x10
    3de0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3de4: d65f03c0     	ret
    3de8: d28000e0     	mov	x0, #0x7                ; =7
    3dec: 910003e3     	mov	x3, sp
    3df0: f80003e0     	stur	x0, [sp]
    3df4: 2a0203e0     	mov	w0, w2
    3df8: aa0203f4     	mov	x20, x2
    3dfc: f80083e0     	stur	x0, [sp, #0x8]
    3e00: 52801301     	mov	w1, #0x98               ; =152
    3e04: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3e08: f9400084     	ldr	x4, [x4]
    3e0c: aa1603e0     	mov	x0, x22
    3e10: aa1303e2     	mov	x2, x19
    3e14: d63f0080     	blr	x4
    3e18: 34ffea40     	cbz	w0, 0x3b60 <___pl_fn_8+0x7c>
    3e1c: 14000074     	b	0x3fec <___pl_fn_8+0x508>
    3e20: 52801321     	mov	w1, #0x99               ; =153
    3e24: 52800003     	mov	w3, #0x0                ; =0
    3e28: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3e2c: f9400084     	ldr	x4, [x4]
    3e30: aa1603e0     	mov	x0, x22
    3e34: aa1403e2     	mov	x2, x20
    3e38: d63f0080     	blr	x4
    3e3c: 34ffeaa0     	cbz	w0, 0x3b90 <___pl_fn_8+0xac>
    3e40: 1400006b     	b	0x3fec <___pl_fn_8+0x508>
    3e44: d2800001     	mov	x1, #0x0                ; =0
    3e48: 910043e3     	add	x3, sp, #0x10
    3e4c: f80103e1     	stur	x1, [sp, #0x10]
    3e50: 2a0003e0     	mov	w0, w0
    3e54: f80183e0     	stur	x0, [sp, #0x18]
    3e58: 52801341     	mov	w1, #0x9a               ; =154
    3e5c: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3e60: f9400084     	ldr	x4, [x4]
    3e64: aa1603e0     	mov	x0, x22
    3e68: aa1303e2     	mov	x2, x19
    3e6c: d63f0080     	blr	x4
    3e70: 34ffea80     	cbz	w0, 0x3bc0 <___pl_fn_8+0xdc>
    3e74: 1400005e     	b	0x3fec <___pl_fn_8+0x508>
    3e78: d2800026     	mov	x6, #0x1                ; =1
    3e7c: 910083e3     	add	x3, sp, #0x20
    3e80: f80203e6     	stur	x6, [sp, #0x20]
    3e84: aa1703f5     	mov	x21, x23
    3e88: f80283f5     	stur	x21, [sp, #0x28]
    3e8c: 52801361     	mov	w1, #0x9b               ; =155
    3e90: 90000008     	adrp	x8, 0x3000 <___pl_fn_4+0x3c>
    3e94: f9400108     	ldr	x8, [x8]
    3e98: aa1603e0     	mov	x0, x22
    3e9c: aa1303e2     	mov	x2, x19
    3ea0: d63f0100     	blr	x8
    3ea4: 34ffe920     	cbz	w0, 0x3bc8 <___pl_fn_8+0xe4>
    3ea8: 14000051     	b	0x3fec <___pl_fn_8+0x508>
    3eac: d2800040     	mov	x0, #0x2                ; =2
    3eb0: 9100c3e3     	add	x3, sp, #0x30
    3eb4: f80303e0     	stur	x0, [sp, #0x30]
    3eb8: aa1b03e4     	mov	x4, x27
    3ebc: f80383e4     	stur	x4, [sp, #0x38]
    3ec0: 52801381     	mov	w1, #0x9c               ; =156
    3ec4: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3ec8: f9400084     	ldr	x4, [x4]
    3ecc: aa1603e0     	mov	x0, x22
    3ed0: aa1303e2     	mov	x2, x19
    3ed4: d63f0080     	blr	x4
    3ed8: 34ffec00     	cbz	w0, 0x3c58 <___pl_fn_8+0x174>
    3edc: 14000044     	b	0x3fec <___pl_fn_8+0x508>
    3ee0: d2800060     	mov	x0, #0x3                ; =3
    3ee4: 910103e3     	add	x3, sp, #0x40
    3ee8: f80403e0     	stur	x0, [sp, #0x40]
    3eec: aa1a03e5     	mov	x5, x26
    3ef0: 2a0503e0     	mov	w0, w5
    3ef4: f80483e0     	stur	x0, [sp, #0x48]
    3ef8: 528013a1     	mov	w1, #0x9d               ; =157
    3efc: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3f00: f9400084     	ldr	x4, [x4]
    3f04: aa1603e0     	mov	x0, x22
    3f08: aa1303e2     	mov	x2, x19
    3f0c: d63f0080     	blr	x4
    3f10: 34ffebc0     	cbz	w0, 0x3c88 <___pl_fn_8+0x1a4>
    3f14: 14000036     	b	0x3fec <___pl_fn_8+0x508>
    3f18: d2800080     	mov	x0, #0x4                ; =4
    3f1c: 910143e3     	add	x3, sp, #0x50
    3f20: f80503e0     	stur	x0, [sp, #0x50]
    3f24: aa1903e6     	mov	x6, x25
    3f28: 53001cc0     	uxtb	w0, w6
    3f2c: f80583e0     	stur	x0, [sp, #0x58]
    3f30: 528013c1     	mov	w1, #0x9e               ; =158
    3f34: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3f38: f9400084     	ldr	x4, [x4]
    3f3c: aa1603e0     	mov	x0, x22
    3f40: aa1303e2     	mov	x2, x19
    3f44: d63f0080     	blr	x4
    3f48: 34ffeb80     	cbz	w0, 0x3cb8 <___pl_fn_8+0x1d4>
    3f4c: 14000028     	b	0x3fec <___pl_fn_8+0x508>
    3f50: d28000a0     	mov	x0, #0x5                ; =5
    3f54: 910183e3     	add	x3, sp, #0x60
    3f58: f80603e0     	stur	x0, [sp, #0x60]
    3f5c: aa1803e7     	mov	x7, x24
    3f60: 53001ce0     	uxtb	w0, w7
    3f64: f80683e0     	stur	x0, [sp, #0x68]
    3f68: 528013e1     	mov	w1, #0x9f               ; =159
    3f6c: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3f70: f9400084     	ldr	x4, [x4]
    3f74: aa1603e0     	mov	x0, x22
    3f78: aa1303e2     	mov	x2, x19
    3f7c: d63f0080     	blr	x4
    3f80: 34ffeb40     	cbz	w0, 0x3ce8 <___pl_fn_8+0x204>
    3f84: 1400001a     	b	0x3fec <___pl_fn_8+0x508>
    3f88: d28000c0     	mov	x0, #0x6                ; =6
    3f8c: 9101c3e3     	add	x3, sp, #0x70
    3f90: f80703e0     	stur	x0, [sp, #0x70]
    3f94: d2800000     	mov	x0, #0x0                ; =0
    3f98: f80783e0     	stur	x0, [sp, #0x78]
    3f9c: 52801401     	mov	w1, #0xa0               ; =160
    3fa0: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3fa4: f9400084     	ldr	x4, [x4]
    3fa8: aa1603e0     	mov	x0, x22
    3fac: aa1303e2     	mov	x2, x19
    3fb0: d63f0080     	blr	x4
    3fb4: 34ffeb00     	cbz	w0, 0x3d14 <___pl_fn_8+0x230>
    3fb8: 1400000d     	b	0x3fec <___pl_fn_8+0x508>
    3fbc: d2800001     	mov	x1, #0x0                ; =0
    3fc0: 910203e3     	add	x3, sp, #0x80
    3fc4: f80803e1     	stur	x1, [sp, #0x80]
    3fc8: 2a1303e2     	mov	w2, w19
    3fcc: f80883e2     	stur	x2, [sp, #0x88]
    3fd0: 52801421     	mov	w1, #0xa1               ; =161
    3fd4: 90000004     	adrp	x4, 0x3000 <___pl_fn_4+0x3c>
    3fd8: f9400084     	ldr	x4, [x4]
    3fdc: aa1603e0     	mov	x0, x22
    3fe0: aa1403e2     	mov	x2, x20
    3fe4: d63f0080     	blr	x4
    3fe8: 34ffe9a0     	cbz	w0, 0x3d1c <___pl_fn_8+0x238>
    3fec: 910243ff     	add	sp, sp, #0x90
    3ff0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3ff4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3ff8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3ffc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4000: f84107fb     	ldr	x27, [sp], #0x10
    4004: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4008: d65f03c0     	ret
    400c: 52801461     	mov	w1, #0xa3               ; =163
    4010: 90000002     	adrp	x2, 0x4000 <___pl_fn_8+0x51c>
    4014: f9400042     	ldr	x2, [x2]
    4018: aa1603e0     	mov	x0, x22
    401c: d63f0040     	blr	x2
    4020: 910243ff     	add	sp, sp, #0x90
    4024: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4028: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    402c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4030: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4034: f84107fb     	ldr	x27, [sp], #0x10
    4038: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    403c: d65f03c0     	ret
    4040: 52801441     	mov	w1, #0xa2               ; =162
    4044: 90000002     	adrp	x2, 0x4000 <___pl_fn_8+0x51c>
    4048: f9400042     	ldr	x2, [x2]
    404c: aa1603e0     	mov	x0, x22
    4050: d63f0040     	blr	x2
    4054: 910243ff     	add	sp, sp, #0x90
    4058: a8c153f3     	ldp	x19, x20, [sp], #0x10
    405c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4060: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4064: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4068: f84107fb     	ldr	x27, [sp], #0x10
    406c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4070: d65f03c0     	ret

0000000000004074 <___pl_fn_9>:
    4074: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    4078: 910003fd     	mov	x29, sp
    407c: b9401004     	ldr	w4, [x0, #0x10]
    4080: 11000485     	add	w5, w4, #0x1
    4084: b9001005     	str	w5, [x0, #0x10]
    4088: b9001004     	str	w4, [x0, #0x10]
    408c: aa0103e0     	mov	x0, x1
    4090: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4094: d65f03c0     	ret

0000000000004098 <___pl_fn_10>:
    4098: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    409c: 910003fd     	mov	x29, sp
    40a0: f81f0ff9     	str	x25, [sp, #-0x10]!
    40a4: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
    40a8: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    40ac: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    40b0: d100c3ff     	sub	sp, sp, #0x30
    40b4: aa0103f5     	mov	x21, x1
    40b8: aa0303f7     	mov	x23, x3
    40bc: aa0203f8     	mov	x24, x2
    40c0: b9401003     	ldr	w3, [x0, #0x10]
    40c4: 11000463     	add	w3, w3, #0x1
    40c8: b9001003     	str	w3, [x0, #0x10]
    40cc: aa1503e1     	mov	x1, x21
    40d0: 34001f81     	cbz	w1, 0x44c0 <___pl_fn_10+0x428>
    40d4: f9400008     	ldr	x8, [x0]
    40d8: aa1503e1     	mov	x1, x21
    40dc: aa0003f6     	mov	x22, x0
    40e0: 2a0103e7     	mov	w7, w1
    40e4: 8b070d07     	add	x7, x8, x7, lsl #3
    40e8: f8615908     	ldr	x8, [x8, w1, uxtw #3]
    40ec: d360fd08     	lsr	x8, x8, #32
    40f0: 92403d08     	and	x8, x8, #0xffff
    40f4: 91000d08     	add	x8, x8, #0x3
    40f8: d37df108     	lsl	x8, x8, #3
    40fc: b86868f4     	ldr	w20, [x7, x8]
    4100: 350000d4     	cbnz	w20, 0x4118 <___pl_fn_10+0x80>
    4104: 140000f0     	b	0x44c4 <___pl_fn_10+0x42c>
    4108: aa1603e0     	mov	x0, x22
    410c: f9401814     	ldr	x20, [x0, #0x30]
    4110: aa1503f3     	mov	x19, x21
    4114: 14000002     	b	0x411c <___pl_fn_10+0x84>
    4118: aa1503f3     	mov	x19, x21
    411c: 34001e73     	cbz	w19, 0x44e8 <___pl_fn_10+0x450>
    4120: aa1603e0     	mov	x0, x22
    4124: f9400000     	ldr	x0, [x0]
    4128: 2a1303ef     	mov	w15, w19
    412c: 8b0f0c0f     	add	x15, x0, x15, lsl #3
    4130: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    4134: d360fc00     	lsr	x0, x0, #32
    4138: 92403c00     	and	x0, x0, #0xffff
    413c: 91001c00     	add	x0, x0, #0x7
    4140: d37df000     	lsl	x0, x0, #3
    4144: b86069e2     	ldr	w2, [x15, x0]
    4148: 35000082     	cbnz	w2, 0x4158 <___pl_fn_10+0xc0>
    414c: 140000e7     	b	0x44e8 <___pl_fn_10+0x450>
    4150: aa1603e0     	mov	x0, x22
    4154: f9401802     	ldr	x2, [x0, #0x30]
    4158: 34001da2     	cbz	w2, 0x450c <___pl_fn_10+0x474>
    415c: aa1603e0     	mov	x0, x22
    4160: f9400001     	ldr	x1, [x0]
    4164: 2a0203e0     	mov	w0, w2
    4168: 8b000c20     	add	x0, x1, x0, lsl #3
    416c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    4170: d360fc21     	lsr	x1, x1, #32
    4174: 92403c21     	and	x1, x1, #0xffff
    4178: 91000821     	add	x1, x1, #0x2
    417c: d37df021     	lsl	x1, x1, #3
    4180: b8616803     	ldr	w3, [x0, x1]
    4184: 35000083     	cbnz	w3, 0x4194 <___pl_fn_10+0xfc>
    4188: 140000e1     	b	0x450c <___pl_fn_10+0x474>
    418c: aa1603e0     	mov	x0, x22
    4190: f9401803     	ldr	x3, [x0, #0x30]
    4194: 6b03029f     	cmp	w20, w3
    4198: 54000c80     	b.eq	0x4328 <___pl_fn_10+0x290>
    419c: 34001c93     	cbz	w19, 0x452c <___pl_fn_10+0x494>
    41a0: aa1603e0     	mov	x0, x22
    41a4: f9400001     	ldr	x1, [x0]
    41a8: 2a1303e0     	mov	w0, w19
    41ac: 8b000c20     	add	x0, x1, x0, lsl #3
    41b0: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    41b4: d360fc21     	lsr	x1, x1, #32
    41b8: 92403c21     	and	x1, x1, #0xffff
    41bc: 91000c21     	add	x1, x1, #0x3
    41c0: d37df021     	lsl	x1, x1, #3
    41c4: b8616802     	ldr	w2, [x0, x1]
    41c8: 350000c2     	cbnz	w2, 0x41e0 <___pl_fn_10+0x148>
    41cc: 140000d8     	b	0x452c <___pl_fn_10+0x494>
    41d0: aa1603e0     	mov	x0, x22
    41d4: f9401802     	ldr	x2, [x0, #0x30]
    41d8: aa0203f9     	mov	x25, x2
    41dc: 14000002     	b	0x41e4 <___pl_fn_10+0x14c>
    41e0: aa0203f9     	mov	x25, x2
    41e4: 34001b73     	cbz	w19, 0x4550 <___pl_fn_10+0x4b8>
    41e8: aa1603e0     	mov	x0, x22
    41ec: f9400001     	ldr	x1, [x0]
    41f0: 2a1303e0     	mov	w0, w19
    41f4: 8b000c20     	add	x0, x1, x0, lsl #3
    41f8: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    41fc: d360fc21     	lsr	x1, x1, #32
    4200: 92403c21     	and	x1, x1, #0xffff
    4204: 91001c21     	add	x1, x1, #0x7
    4208: d37df021     	lsl	x1, x1, #3
    420c: b8616802     	ldr	w2, [x0, x1]
    4210: 35000082     	cbnz	w2, 0x4220 <___pl_fn_10+0x188>
    4214: 140000cf     	b	0x4550 <___pl_fn_10+0x4b8>
    4218: aa1603e0     	mov	x0, x22
    421c: f9401802     	ldr	x2, [x0, #0x30]
    4220: 34001aa2     	cbz	w2, 0x4574 <___pl_fn_10+0x4dc>
    4224: aa1603e0     	mov	x0, x22
    4228: f9400001     	ldr	x1, [x0]
    422c: 2a0203e0     	mov	w0, w2
    4230: 8b000c20     	add	x0, x1, x0, lsl #3
    4234: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    4238: d360fc21     	lsr	x1, x1, #32
    423c: 92403c21     	and	x1, x1, #0xffff
    4240: 91000821     	add	x1, x1, #0x2
    4244: d37df021     	lsl	x1, x1, #3
    4248: b8616803     	ldr	w3, [x0, x1]
    424c: 350000a3     	cbnz	w3, 0x4260 <___pl_fn_10+0x1c8>
    4250: 140000c9     	b	0x4574 <___pl_fn_10+0x4dc>
    4254: aa1603e0     	mov	x0, x22
    4258: f9401803     	ldr	x3, [x0, #0x30]
    425c: 14000002     	b	0x4264 <___pl_fn_10+0x1cc>
    4260: aa1603e0     	mov	x0, x22
    4264: aa1603e0     	mov	x0, x22
    4268: b9401815     	ldr	w21, [x0, #0x18]
    426c: b9401c00     	ldr	w0, [x0, #0x1c]
    4270: 110016a1     	add	w1, w21, #0x5
    4274: 6b00003f     	cmp	w1, w0
    4278: 54001c48     	b.hi	0x4600 <___pl_fn_10+0x568>
    427c: aa1603e0     	mov	x0, x22
    4280: f9401001     	ldr	x1, [x0, #0x20]
    4284: 2a1503e0     	mov	w0, w21
    4288: 8b000820     	add	x0, x1, x0, lsl #2
    428c: b8355833     	str	w19, [x1, w21, uxtw #2]
    4290: aa1803e2     	mov	x2, x24
    4294: b9000402     	str	w2, [x0, #0x4]
    4298: aa1703f4     	mov	x20, x23
    429c: b9000814     	str	w20, [x0, #0x8]
    42a0: aa1903e2     	mov	x2, x25
    42a4: b9000c02     	str	w2, [x0, #0xc]
    42a8: b9001003     	str	w3, [x0, #0x10]
    42ac: 110016a0     	add	w0, w21, #0x5
    42b0: aa1603e1     	mov	x1, x22
    42b4: b9001820     	str	w0, [x1, #0x18]
    42b8: aa1603e0     	mov	x0, x22
    42bc: b9401000     	ldr	w0, [x0, #0x10]
    42c0: b9401421     	ldr	w1, [x1, #0x14]
    42c4: 6b01001f     	cmp	w0, w1
    42c8: 54001822     	b.hs	0x45cc <___pl_fn_10+0x534>
    42cc: aa1803e1     	mov	x1, x24
    42d0: aa1603e0     	mov	x0, x22
    42d4: 94000000     	bl	0x42d4 <___pl_fn_10+0x23c>
    42d8: aa1603e1     	mov	x1, x22
    42dc: b9402c22     	ldr	w2, [x1, #0x2c]
    42e0: 35002022     	cbnz	w2, 0x46e4 <___pl_fn_10+0x64c>
    42e4: aa1603e2     	mov	x2, x22
    42e8: b9001855     	str	w21, [x2, #0x18]
    42ec: 34001553     	cbz	w19, 0x4594 <___pl_fn_10+0x4fc>
    42f0: aa1603e1     	mov	x1, x22
    42f4: aa1303f5     	mov	x21, x19
    42f8: f940002c     	ldr	x12, [x1]
    42fc: 2a1303eb     	mov	w11, w19
    4300: 8b0b0d8b     	add	x11, x12, x11, lsl #3
    4304: f873598d     	ldr	x13, [x12, w19, uxtw #3]
    4308: 2a0003ec     	mov	w12, w0
    430c: d360fdad     	lsr	x13, x13, #32
    4310: 92403dad     	and	x13, x13, #0xffff
    4314: 91000dad     	add	x13, x13, #0x3
    4318: f82d796c     	str	x12, [x11, x13, lsl #3]
    431c: aa1603e0     	mov	x0, x22
    4320: aa1403f7     	mov	x23, x20
    4324: 1400004d     	b	0x4458 <___pl_fn_10+0x3c0>
    4328: aa1803e1     	mov	x1, x24
    432c: aa1703f4     	mov	x20, x23
    4330: aa1303f5     	mov	x21, x19
    4334: 35000093     	cbnz	w19, 0x4344 <___pl_fn_10+0x2ac>
    4338: 140000bf     	b	0x4634 <___pl_fn_10+0x59c>
    433c: aa1503f3     	mov	x19, x21
    4340: 1400000c     	b	0x4370 <___pl_fn_10+0x2d8>
    4344: aa1603e0     	mov	x0, x22
    4348: f9400002     	ldr	x2, [x0]
    434c: aa1503f3     	mov	x19, x21
    4350: 2a1303e0     	mov	w0, w19
    4354: 8b000c40     	add	x0, x2, x0, lsl #3
    4358: f8735842     	ldr	x2, [x2, w19, uxtw #3]
    435c: 2a0103e1     	mov	w1, w1
    4360: d360fc42     	lsr	x2, x2, #32
    4364: 92403c42     	and	x2, x2, #0xffff
    4368: 91000c42     	add	x2, x2, #0x3
    436c: f8227801     	str	x1, [x0, x2, lsl #3]
    4370: aa1503f3     	mov	x19, x21
    4374: 35000093     	cbnz	w19, 0x4384 <___pl_fn_10+0x2ec>
    4378: 140000bc     	b	0x4668 <___pl_fn_10+0x5d0>
    437c: aa1503f3     	mov	x19, x21
    4380: 1400000c     	b	0x43b0 <___pl_fn_10+0x318>
    4384: aa1603e0     	mov	x0, x22
    4388: f9400001     	ldr	x1, [x0]
    438c: aa1503f3     	mov	x19, x21
    4390: 2a1303e0     	mov	w0, w19
    4394: 8b000c20     	add	x0, x1, x0, lsl #3
    4398: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    439c: d2800021     	mov	x1, #0x1                ; =1
    43a0: d360fc42     	lsr	x2, x2, #32
    43a4: 92403c42     	and	x2, x2, #0xffff
    43a8: 91001042     	add	x2, x2, #0x4
    43ac: f8227801     	str	x1, [x0, x2, lsl #3]
    43b0: aa1503f3     	mov	x19, x21
    43b4: 34001753     	cbz	w19, 0x469c <___pl_fn_10+0x604>
    43b8: aa1603e0     	mov	x0, x22
    43bc: f9400001     	ldr	x1, [x0]
    43c0: aa1503f3     	mov	x19, x21
    43c4: 2a1303e0     	mov	w0, w19
    43c8: 8b000c20     	add	x0, x1, x0, lsl #3
    43cc: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    43d0: d360fc21     	lsr	x1, x1, #32
    43d4: 92403c21     	and	x1, x1, #0xffff
    43d8: 91000822     	add	x2, x1, #0x2
    43dc: f8627813     	ldr	x19, [x0, x2, lsl #3]
    43e0: f100083f     	cmp	x1, #0x2
    43e4: 540000c0     	b.eq	0x43fc <___pl_fn_10+0x364>
    43e8: f9400800     	ldr	x0, [x0, #0x10]
    43ec: 37101580     	tbnz	w0, #0x2, 0x469c <___pl_fn_10+0x604>
    43f0: 14000003     	b	0x43fc <___pl_fn_10+0x364>
    43f4: aa1603e0     	mov	x0, x22
    43f8: f9401813     	ldr	x19, [x0, #0x30]
    43fc: 34001634     	cbz	w20, 0x46c0 <___pl_fn_10+0x628>
    4400: aa1603e0     	mov	x0, x22
    4404: f9400000     	ldr	x0, [x0]
    4408: 2a1403e1     	mov	w1, w20
    440c: 8b010c01     	add	x1, x0, x1, lsl #3
    4410: f8745800     	ldr	x0, [x0, w20, uxtw #3]
    4414: d360fc00     	lsr	x0, x0, #32
    4418: 92403c02     	and	x2, x0, #0xffff
    441c: 91000840     	add	x0, x2, #0x2
    4420: f8607820     	ldr	x0, [x1, x0, lsl #3]
    4424: f100085f     	cmp	x2, #0x2
    4428: 54000061     	b.ne	0x4434 <___pl_fn_10+0x39c>
    442c: aa1403f7     	mov	x23, x20
    4430: 14000007     	b	0x444c <___pl_fn_10+0x3b4>
    4434: f9400821     	ldr	x1, [x1, #0x10]
    4438: 37101441     	tbnz	w1, #0x2, 0x46c0 <___pl_fn_10+0x628>
    443c: aa1403f7     	mov	x23, x20
    4440: 14000003     	b	0x444c <___pl_fn_10+0x3b4>
    4444: aa1603e0     	mov	x0, x22
    4448: f9401800     	ldr	x0, [x0, #0x30]
    444c: eb00027f     	cmp	x19, x0
    4450: 540001ec     	b.gt	0x448c <___pl_fn_10+0x3f4>
    4454: aa1603e0     	mov	x0, x22
    4458: aa1603e0     	mov	x0, x22
    445c: b9401000     	ldr	w0, [x0, #0x10]
    4460: 51000400     	sub	w0, w0, #0x1
    4464: aa1603e1     	mov	x1, x22
    4468: b9001020     	str	w0, [x1, #0x10]
    446c: aa1703e0     	mov	x0, x23
    4470: 9100c3ff     	add	sp, sp, #0x30
    4474: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4478: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    447c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4480: f84107f9     	ldr	x25, [sp], #0x10
    4484: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4488: d65f03c0     	ret
    448c: aa1603e0     	mov	x0, x22
    4490: b9401000     	ldr	w0, [x0, #0x10]
    4494: 51000400     	sub	w0, w0, #0x1
    4498: aa1603e1     	mov	x1, x22
    449c: b9001020     	str	w0, [x1, #0x10]
    44a0: aa1503e0     	mov	x0, x21
    44a4: 9100c3ff     	add	sp, sp, #0x30
    44a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    44ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    44b0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    44b4: f84107f9     	ldr	x25, [sp], #0x10
    44b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    44bc: d65f03c0     	ret
    44c0: aa0003f6     	mov	x22, x0
    44c4: 52801481     	mov	w1, #0xa4               ; =164
    44c8: 52800063     	mov	w3, #0x3                ; =3
    44cc: 90000009     	adrp	x9, 0x4000 <___pl_fn_8+0x51c>
    44d0: f9400129     	ldr	x9, [x9]
    44d4: aa1603e0     	mov	x0, x22
    44d8: aa1503e2     	mov	x2, x21
    44dc: d63f0120     	blr	x9
    44e0: 34ffe140     	cbz	w0, 0x4108 <___pl_fn_10+0x70>
    44e4: 14000080     	b	0x46e4 <___pl_fn_10+0x64c>
    44e8: 528014a1     	mov	w1, #0xa5               ; =165
    44ec: 528000e3     	mov	w3, #0x7                ; =7
    44f0: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    44f4: f9400084     	ldr	x4, [x4]
    44f8: aa1603e0     	mov	x0, x22
    44fc: aa1303e2     	mov	x2, x19
    4500: d63f0080     	blr	x4
    4504: 34ffe260     	cbz	w0, 0x4150 <___pl_fn_10+0xb8>
    4508: 14000077     	b	0x46e4 <___pl_fn_10+0x64c>
    450c: 528014c1     	mov	w1, #0xa6               ; =166
    4510: 52800043     	mov	w3, #0x2                ; =2
    4514: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4518: f9400084     	ldr	x4, [x4]
    451c: aa1603e0     	mov	x0, x22
    4520: d63f0080     	blr	x4
    4524: 34ffe340     	cbz	w0, 0x418c <___pl_fn_10+0xf4>
    4528: 1400006f     	b	0x46e4 <___pl_fn_10+0x64c>
    452c: 528014e1     	mov	w1, #0xa7               ; =167
    4530: 52800063     	mov	w3, #0x3                ; =3
    4534: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4538: f9400084     	ldr	x4, [x4]
    453c: aa1603e0     	mov	x0, x22
    4540: aa1303e2     	mov	x2, x19
    4544: d63f0080     	blr	x4
    4548: 34ffe440     	cbz	w0, 0x41d0 <___pl_fn_10+0x138>
    454c: 14000066     	b	0x46e4 <___pl_fn_10+0x64c>
    4550: 52801501     	mov	w1, #0xa8               ; =168
    4554: 528000e3     	mov	w3, #0x7                ; =7
    4558: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    455c: f9400084     	ldr	x4, [x4]
    4560: aa1603e0     	mov	x0, x22
    4564: aa1303e2     	mov	x2, x19
    4568: d63f0080     	blr	x4
    456c: 34ffe560     	cbz	w0, 0x4218 <___pl_fn_10+0x180>
    4570: 1400005d     	b	0x46e4 <___pl_fn_10+0x64c>
    4574: 52801521     	mov	w1, #0xa9               ; =169
    4578: 52800043     	mov	w3, #0x2                ; =2
    457c: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4580: f9400084     	ldr	x4, [x4]
    4584: aa1603e0     	mov	x0, x22
    4588: d63f0080     	blr	x4
    458c: 34ffe640     	cbz	w0, 0x4254 <___pl_fn_10+0x1bc>
    4590: 14000055     	b	0x46e4 <___pl_fn_10+0x64c>
    4594: aa1303f5     	mov	x21, x19
    4598: d2800066     	mov	x6, #0x3                ; =3
    459c: 910003e3     	mov	x3, sp
    45a0: f80003e6     	stur	x6, [sp]
    45a4: 2a0003e7     	mov	w7, w0
    45a8: f80083e7     	stur	x7, [sp, #0x8]
    45ac: 52801581     	mov	w1, #0xac               ; =172
    45b0: 90000008     	adrp	x8, 0x4000 <___pl_fn_8+0x51c>
    45b4: f9400108     	ldr	x8, [x8]
    45b8: aa1503e2     	mov	x2, x21
    45bc: aa1603e0     	mov	x0, x22
    45c0: d63f0100     	blr	x8
    45c4: 34ffeac0     	cbz	w0, 0x431c <___pl_fn_10+0x284>
    45c8: 14000047     	b	0x46e4 <___pl_fn_10+0x64c>
    45cc: 52801561     	mov	w1, #0xab               ; =171
    45d0: 9000000e     	adrp	x14, 0x4000 <___pl_fn_8+0x51c>
    45d4: f94001ce     	ldr	x14, [x14]
    45d8: aa1603e0     	mov	x0, x22
    45dc: d63f01c0     	blr	x14
    45e0: 52800000     	mov	w0, #0x0                ; =0
    45e4: 9100c3ff     	add	sp, sp, #0x30
    45e8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    45ec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    45f0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    45f4: f84107f9     	ldr	x25, [sp], #0x10
    45f8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    45fc: d65f03c0     	ret
    4600: 52801541     	mov	w1, #0xaa               ; =170
    4604: 9000000f     	adrp	x15, 0x4000 <___pl_fn_8+0x51c>
    4608: f94001ef     	ldr	x15, [x15]
    460c: aa1603e0     	mov	x0, x22
    4610: d63f01e0     	blr	x15
    4614: 52800000     	mov	w0, #0x0                ; =0
    4618: 9100c3ff     	add	sp, sp, #0x30
    461c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4620: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4624: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4628: f84107f9     	ldr	x25, [sp], #0x10
    462c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4630: d65f03c0     	ret
    4634: d2800060     	mov	x0, #0x3                ; =3
    4638: 910043e3     	add	x3, sp, #0x10
    463c: f80103e0     	stur	x0, [sp, #0x10]
    4640: 2a0103e0     	mov	w0, w1
    4644: f80183e0     	stur	x0, [sp, #0x18]
    4648: 528015a1     	mov	w1, #0xad               ; =173
    464c: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4650: f9400084     	ldr	x4, [x4]
    4654: aa1603e0     	mov	x0, x22
    4658: aa1503e2     	mov	x2, x21
    465c: d63f0080     	blr	x4
    4660: 34ffe6e0     	cbz	w0, 0x433c <___pl_fn_10+0x2a4>
    4664: 14000020     	b	0x46e4 <___pl_fn_10+0x64c>
    4668: d2800080     	mov	x0, #0x4                ; =4
    466c: 910083e3     	add	x3, sp, #0x20
    4670: f80203e0     	stur	x0, [sp, #0x20]
    4674: d2800020     	mov	x0, #0x1                ; =1
    4678: f80283e0     	stur	x0, [sp, #0x28]
    467c: 528015c1     	mov	w1, #0xae               ; =174
    4680: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4684: f9400084     	ldr	x4, [x4]
    4688: aa1603e0     	mov	x0, x22
    468c: aa1503e2     	mov	x2, x21
    4690: d63f0080     	blr	x4
    4694: 34ffe740     	cbz	w0, 0x437c <___pl_fn_10+0x2e4>
    4698: 14000013     	b	0x46e4 <___pl_fn_10+0x64c>
    469c: 528015e1     	mov	w1, #0xaf               ; =175
    46a0: 52800043     	mov	w3, #0x2                ; =2
    46a4: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    46a8: f9400084     	ldr	x4, [x4]
    46ac: aa1603e0     	mov	x0, x22
    46b0: aa1503e2     	mov	x2, x21
    46b4: d63f0080     	blr	x4
    46b8: 34ffe9e0     	cbz	w0, 0x43f4 <___pl_fn_10+0x35c>
    46bc: 1400000a     	b	0x46e4 <___pl_fn_10+0x64c>
    46c0: 52801601     	mov	w1, #0xb0               ; =176
    46c4: 52800043     	mov	w3, #0x2                ; =2
    46c8: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    46cc: f9400084     	ldr	x4, [x4]
    46d0: aa1603e0     	mov	x0, x22
    46d4: aa1403e2     	mov	x2, x20
    46d8: d63f0080     	blr	x4
    46dc: aa1403f7     	mov	x23, x20
    46e0: 34ffeb20     	cbz	w0, 0x4444 <___pl_fn_10+0x3ac>
    46e4: 52800000     	mov	w0, #0x0                ; =0
    46e8: 9100c3ff     	add	sp, sp, #0x30
    46ec: a8c153f3     	ldp	x19, x20, [sp], #0x10
    46f0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    46f4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    46f8: f84107f9     	ldr	x25, [sp], #0x10
    46fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4700: d65f03c0     	ret

0000000000004704 <___pl_fn_11>:
    4704: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    4708: 910003fd     	mov	x29, sp
    470c: f81f0ffa     	str	x26, [sp, #-0x10]!
    4710: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    4714: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    4718: d10143ff     	sub	sp, sp, #0x50
    471c: aa0103f5     	mov	x21, x1
    4720: b9401001     	ldr	w1, [x0, #0x10]
    4724: 11000421     	add	w1, w1, #0x1
    4728: b9001001     	str	w1, [x0, #0x10]
    472c: aa1503e1     	mov	x1, x21
    4730: 34003181     	cbz	w1, 0x4d60 <___pl_fn_11+0x65c>
    4734: f9400001     	ldr	x1, [x0]
    4738: aa0003f4     	mov	x20, x0
    473c: aa1503e0     	mov	x0, x21
    4740: 2a0003e0     	mov	w0, w0
    4744: 8b000c20     	add	x0, x1, x0, lsl #3
    4748: aa1503e2     	mov	x2, x21
    474c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    4750: d360fc21     	lsr	x1, x1, #32
    4754: 92403c21     	and	x1, x1, #0xffff
    4758: 91001021     	add	x1, x1, #0x4
    475c: d37df021     	lsl	x1, x1, #3
    4760: 38616800     	ldrb	w0, [x0, x1]
    4764: 53001c01     	uxtb	w1, w0
    4768: 7100083f     	cmp	w1, #0x2
    476c: 54000081     	b.ne	0x477c <___pl_fn_11+0x78>
    4770: 1400017d     	b	0x4d64 <___pl_fn_11+0x660>
    4774: aa1403e0     	mov	x0, x20
    4778: f9401800     	ldr	x0, [x0, #0x30]
    477c: 72001c1f     	tst	w0, #0xff
    4780: 54000061     	b.ne	0x478c <___pl_fn_11+0x88>
    4784: 52800000     	mov	w0, #0x0                ; =0
    4788: 14000015     	b	0x47dc <___pl_fn_11+0xd8>
    478c: aa1503f3     	mov	x19, x21
    4790: 34002fd3     	cbz	w19, 0x4d88 <___pl_fn_11+0x684>
    4794: aa1403e0     	mov	x0, x20
    4798: f9400004     	ldr	x4, [x0]
    479c: 2a1303e3     	mov	w3, w19
    47a0: 8b030c83     	add	x3, x4, x3, lsl #3
    47a4: f8735884     	ldr	x4, [x4, w19, uxtw #3]
    47a8: d360fc84     	lsr	x4, x4, #32
    47ac: 92403c84     	and	x4, x4, #0xffff
    47b0: 91001484     	add	x4, x4, #0x5
    47b4: d37df084     	lsl	x4, x4, #3
    47b8: 38646860     	ldrb	w0, [x3, x4]
    47bc: 53001c03     	uxtb	w3, w0
    47c0: 7100087f     	cmp	w3, #0x2
    47c4: 540000a1     	b.ne	0x47d8 <___pl_fn_11+0xd4>
    47c8: 14000170     	b	0x4d88 <___pl_fn_11+0x684>
    47cc: aa1403e0     	mov	x0, x20
    47d0: f9401800     	ldr	x0, [x0, #0x30]
    47d4: 14000002     	b	0x47dc <___pl_fn_11+0xd8>
    47d8: aa1303f5     	mov	x21, x19
    47dc: 72001c1f     	tst	w0, #0xff
    47e0: 54000061     	b.ne	0x47ec <___pl_fn_11+0xe8>
    47e4: 52800003     	mov	w3, #0x0                ; =0
    47e8: 14000016     	b	0x4840 <___pl_fn_11+0x13c>
    47ec: aa1503e1     	mov	x1, x21
    47f0: 34002e01     	cbz	w1, 0x4db0 <___pl_fn_11+0x6ac>
    47f4: aa1403e0     	mov	x0, x20
    47f8: f9400001     	ldr	x1, [x0]
    47fc: aa1503e0     	mov	x0, x21
    4800: 2a0003e0     	mov	w0, w0
    4804: 8b000c20     	add	x0, x1, x0, lsl #3
    4808: aa1503e2     	mov	x2, x21
    480c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    4810: d360fc21     	lsr	x1, x1, #32
    4814: 92403c21     	and	x1, x1, #0xffff
    4818: 91001821     	add	x1, x1, #0x6
    481c: d37df021     	lsl	x1, x1, #3
    4820: 3861680e     	ldrb	w14, [x0, x1]
    4824: 53001dc0     	uxtb	w0, w14
    4828: 7100081f     	cmp	w0, #0x2
    482c: 54000081     	b.ne	0x483c <___pl_fn_11+0x138>
    4830: 14000160     	b	0x4db0 <___pl_fn_11+0x6ac>
    4834: aa1403e0     	mov	x0, x20
    4838: f940180e     	ldr	x14, [x0, #0x30]
    483c: 520001c3     	eor	w3, w14, #0x1
    4840: 72001c7f     	tst	w3, #0xff
    4844: 540004c1     	b.ne	0x48dc <___pl_fn_11+0x1d8>
    4848: aa1503e1     	mov	x1, x21
    484c: 34002c41     	cbz	w1, 0x4dd4 <___pl_fn_11+0x6d0>
    4850: aa1403e0     	mov	x0, x20
    4854: f9400001     	ldr	x1, [x0]
    4858: aa1503e0     	mov	x0, x21
    485c: 2a0003e0     	mov	w0, w0
    4860: 8b000c20     	add	x0, x1, x0, lsl #3
    4864: aa1503e2     	mov	x2, x21
    4868: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    486c: d360fc21     	lsr	x1, x1, #32
    4870: 92403c21     	and	x1, x1, #0xffff
    4874: 91001c21     	add	x1, x1, #0x7
    4878: d37df021     	lsl	x1, x1, #3
    487c: b8616802     	ldr	w2, [x0, x1]
    4880: 35000082     	cbnz	w2, 0x4890 <___pl_fn_11+0x18c>
    4884: 14000154     	b	0x4dd4 <___pl_fn_11+0x6d0>
    4888: aa1403e0     	mov	x0, x20
    488c: f9401802     	ldr	x2, [x0, #0x30]
    4890: 34002b42     	cbz	w2, 0x4df8 <___pl_fn_11+0x6f4>
    4894: aa1403e0     	mov	x0, x20
    4898: f9400001     	ldr	x1, [x0]
    489c: 2a0203e0     	mov	w0, w2
    48a0: 8b000c20     	add	x0, x1, x0, lsl #3
    48a4: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    48a8: d360fc21     	lsr	x1, x1, #32
    48ac: 92403c21     	and	x1, x1, #0xffff
    48b0: 91000821     	add	x1, x1, #0x2
    48b4: d37df021     	lsl	x1, x1, #3
    48b8: b861680a     	ldr	w10, [x0, x1]
    48bc: 3500008a     	cbnz	w10, 0x48cc <___pl_fn_11+0x1c8>
    48c0: 1400014e     	b	0x4df8 <___pl_fn_11+0x6f4>
    48c4: aa1403e0     	mov	x0, x20
    48c8: f940180a     	ldr	x10, [x0, #0x30]
    48cc: 34002a6a     	cbz	w10, 0x4e18 <___pl_fn_11+0x714>
    48d0: aa1403e0     	mov	x0, x20
    48d4: aa0a03fa     	mov	x26, x10
    48d8: 140000ad     	b	0x4b8c <___pl_fn_11+0x488>
    48dc: aa1503e1     	mov	x1, x21
    48e0: 34002b41     	cbz	w1, 0x4e48 <___pl_fn_11+0x744>
    48e4: aa1403e0     	mov	x0, x20
    48e8: f9400001     	ldr	x1, [x0]
    48ec: aa1503ec     	mov	x12, x21
    48f0: 2a0c03e0     	mov	w0, w12
    48f4: 8b000c20     	add	x0, x1, x0, lsl #3
    48f8: aa1503ef     	mov	x15, x21
    48fc: f86f5821     	ldr	x1, [x1, w15, uxtw #3]
    4900: d360fc21     	lsr	x1, x1, #32
    4904: 92403c21     	and	x1, x1, #0xffff
    4908: 91000c21     	add	x1, x1, #0x3
    490c: d37df021     	lsl	x1, x1, #3
    4910: b861680a     	ldr	w10, [x0, x1]
    4914: 3500008a     	cbnz	w10, 0x4924 <___pl_fn_11+0x220>
    4918: 1400014c     	b	0x4e48 <___pl_fn_11+0x744>
    491c: aa1403e0     	mov	x0, x20
    4920: f940180a     	ldr	x10, [x0, #0x30]
    4924: 52800003     	mov	w3, #0x0                ; =0
    4928: 340043ea     	cbz	w10, 0x51a4 <___pl_fn_11+0xaa0>
    492c: 34002a0a     	cbz	w10, 0x4e6c <___pl_fn_11+0x768>
    4930: aa1403e0     	mov	x0, x20
    4934: f9400001     	ldr	x1, [x0]
    4938: 2a0a03e0     	mov	w0, w10
    493c: 8b000c20     	add	x0, x1, x0, lsl #3
    4940: f86a5821     	ldr	x1, [x1, w10, uxtw #3]
    4944: aa0a03fa     	mov	x26, x10
    4948: d360fc21     	lsr	x1, x1, #32
    494c: 92403c21     	and	x1, x1, #0xffff
    4950: d37df021     	lsl	x1, x1, #3
    4954: b8616800     	ldr	w0, [x0, x1]
    4958: 350000c0     	cbnz	w0, 0x4970 <___pl_fn_11+0x26c>
    495c: 14000145     	b	0x4e70 <___pl_fn_11+0x76c>
    4960: aa1403e0     	mov	x0, x20
    4964: f9401800     	ldr	x0, [x0, #0x30]
    4968: aa1503e1     	mov	x1, x21
    496c: 14000002     	b	0x4974 <___pl_fn_11+0x270>
    4970: aa1503e1     	mov	x1, x21
    4974: aa1503e1     	mov	x1, x21
    4978: 35000081     	cbnz	w1, 0x4988 <___pl_fn_11+0x284>
    497c: 14000145     	b	0x4e90 <___pl_fn_11+0x78c>
    4980: aa1503e1     	mov	x1, x21
    4984: 1400000c     	b	0x49b4 <___pl_fn_11+0x2b0>
    4988: aa1403ec     	mov	x12, x20
    498c: f9400186     	ldr	x6, [x12]
    4990: aa1503e1     	mov	x1, x21
    4994: 2a0103e5     	mov	w5, w1
    4998: 8b050cc5     	add	x5, x6, x5, lsl #3
    499c: f86158c7     	ldr	x7, [x6, w1, uxtw #3]
    49a0: 2a0003e6     	mov	w6, w0
    49a4: d360fce7     	lsr	x7, x7, #32
    49a8: 92403ce7     	and	x7, x7, #0xffff
    49ac: 91000ce7     	add	x7, x7, #0x3
    49b0: f82778a6     	str	x6, [x5, x7, lsl #3]
    49b4: aa1503e1     	mov	x1, x21
    49b8: 34002861     	cbz	w1, 0x4ec4 <___pl_fn_11+0x7c0>
    49bc: aa1403e0     	mov	x0, x20
    49c0: f940000a     	ldr	x10, [x0]
    49c4: aa1503e1     	mov	x1, x21
    49c8: 2a0103e9     	mov	w9, w1
    49cc: 8b090d49     	add	x9, x10, x9, lsl #3
    49d0: f861594a     	ldr	x10, [x10, w1, uxtw #3]
    49d4: d360fd4a     	lsr	x10, x10, #32
    49d8: 92403d4a     	and	x10, x10, #0xffff
    49dc: 91000d4a     	add	x10, x10, #0x3
    49e0: d37df14a     	lsl	x10, x10, #3
    49e4: b86a6933     	ldr	w19, [x9, x10]
    49e8: 350000d3     	cbnz	w19, 0x4a00 <___pl_fn_11+0x2fc>
    49ec: 14000136     	b	0x4ec4 <___pl_fn_11+0x7c0>
    49f0: aa1403e0     	mov	x0, x20
    49f4: f9401813     	ldr	x19, [x0, #0x30]
    49f8: aa1503e1     	mov	x1, x21
    49fc: 14000002     	b	0x4a04 <___pl_fn_11+0x300>
    4a00: aa1503e1     	mov	x1, x21
    4a04: aa1503e1     	mov	x1, x21
    4a08: 34002701     	cbz	w1, 0x4ee8 <___pl_fn_11+0x7e4>
    4a0c: aa1403e0     	mov	x0, x20
    4a10: f9400001     	ldr	x1, [x0]
    4a14: aa1503e0     	mov	x0, x21
    4a18: 2a0003e0     	mov	w0, w0
    4a1c: 8b000c20     	add	x0, x1, x0, lsl #3
    4a20: aa1503e2     	mov	x2, x21
    4a24: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    4a28: d360fc21     	lsr	x1, x1, #32
    4a2c: 92403c21     	and	x1, x1, #0xffff
    4a30: 91001c21     	add	x1, x1, #0x7
    4a34: d37df021     	lsl	x1, x1, #3
    4a38: b8616802     	ldr	w2, [x0, x1]
    4a3c: 35000082     	cbnz	w2, 0x4a4c <___pl_fn_11+0x348>
    4a40: 1400012a     	b	0x4ee8 <___pl_fn_11+0x7e4>
    4a44: aa1403e0     	mov	x0, x20
    4a48: f9401802     	ldr	x2, [x0, #0x30]
    4a4c: 34002602     	cbz	w2, 0x4f0c <___pl_fn_11+0x808>
    4a50: aa1403e0     	mov	x0, x20
    4a54: f9400001     	ldr	x1, [x0]
    4a58: 2a0203e0     	mov	w0, w2
    4a5c: 8b000c20     	add	x0, x1, x0, lsl #3
    4a60: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    4a64: d360fc21     	lsr	x1, x1, #32
    4a68: 92403c21     	and	x1, x1, #0xffff
    4a6c: 91000821     	add	x1, x1, #0x2
    4a70: d37df021     	lsl	x1, x1, #3
    4a74: b8616800     	ldr	w0, [x0, x1]
    4a78: 35000080     	cbnz	w0, 0x4a88 <___pl_fn_11+0x384>
    4a7c: 14000124     	b	0x4f0c <___pl_fn_11+0x808>
    4a80: aa1403e0     	mov	x0, x20
    4a84: f9401800     	ldr	x0, [x0, #0x30]
    4a88: 6b00027f     	cmp	w19, w0
    4a8c: 54000220     	b.eq	0x4ad0 <___pl_fn_11+0x3cc>
    4a90: aa1503e1     	mov	x1, x21
    4a94: 340024c1     	cbz	w1, 0x4f2c <___pl_fn_11+0x828>
    4a98: aa1403e0     	mov	x0, x20
    4a9c: f9400001     	ldr	x1, [x0]
    4aa0: aa1503e0     	mov	x0, x21
    4aa4: 2a0003e0     	mov	w0, w0
    4aa8: 8b000c20     	add	x0, x1, x0, lsl #3
    4aac: aa1503e2     	mov	x2, x21
    4ab0: f8625822     	ldr	x2, [x1, w2, uxtw #3]
    4ab4: d2800021     	mov	x1, #0x1                ; =1
    4ab8: d360fc42     	lsr	x2, x2, #32
    4abc: 92403c42     	and	x2, x2, #0xffff
    4ac0: 91001042     	add	x2, x2, #0x4
    4ac4: f8227801     	str	x1, [x0, x2, lsl #3]
    4ac8: aa1503e1     	mov	x1, x21
    4acc: 14000010     	b	0x4b0c <___pl_fn_11+0x408>
    4ad0: aa1503e1     	mov	x1, x21
    4ad4: 34002461     	cbz	w1, 0x4f60 <___pl_fn_11+0x85c>
    4ad8: aa1403e0     	mov	x0, x20
    4adc: f9400001     	ldr	x1, [x0]
    4ae0: aa1503e5     	mov	x5, x21
    4ae4: 2a0503e0     	mov	w0, w5
    4ae8: 8b000c20     	add	x0, x1, x0, lsl #3
    4aec: aa1503e8     	mov	x8, x21
    4af0: f8685822     	ldr	x2, [x1, w8, uxtw #3]
    4af4: d2800001     	mov	x1, #0x0                ; =0
    4af8: d360fc42     	lsr	x2, x2, #32
    4afc: 92403c42     	and	x2, x2, #0xffff
    4b00: 91001042     	add	x2, x2, #0x4
    4b04: f8227801     	str	x1, [x0, x2, lsl #3]
    4b08: aa1503e1     	mov	x1, x21
    4b0c: aa1503e1     	mov	x1, x21
    4b10: 35000081     	cbnz	w1, 0x4b20 <___pl_fn_11+0x41c>
    4b14: 14000120     	b	0x4f94 <___pl_fn_11+0x890>
    4b18: aa1503e1     	mov	x1, x21
    4b1c: 1400000e     	b	0x4b54 <___pl_fn_11+0x450>
    4b20: aa1403e0     	mov	x0, x20
    4b24: f9400001     	ldr	x1, [x0]
    4b28: aa1503e0     	mov	x0, x21
    4b2c: 2a0003e0     	mov	w0, w0
    4b30: 8b000c20     	add	x0, x1, x0, lsl #3
    4b34: aa1503e2     	mov	x2, x21
    4b38: f8625822     	ldr	x2, [x1, w2, uxtw #3]
    4b3c: d2800001     	mov	x1, #0x0                ; =0
    4b40: d360fc42     	lsr	x2, x2, #32
    4b44: 92403c42     	and	x2, x2, #0xffff
    4b48: 91001442     	add	x2, x2, #0x5
    4b4c: f8227801     	str	x1, [x0, x2, lsl #3]
    4b50: aa1503e1     	mov	x1, x21
    4b54: aa1503e1     	mov	x1, x21
    4b58: 34002381     	cbz	w1, 0x4fc8 <___pl_fn_11+0x8c4>
    4b5c: aa1403e0     	mov	x0, x20
    4b60: f9400003     	ldr	x3, [x0]
    4b64: aa1503e1     	mov	x1, x21
    4b68: 2a0103e2     	mov	w2, w1
    4b6c: 8b020c62     	add	x2, x3, x2, lsl #3
    4b70: f8615864     	ldr	x4, [x3, w1, uxtw #3]
    4b74: d2800003     	mov	x3, #0x0                ; =0
    4b78: d360fc84     	lsr	x4, x4, #32
    4b7c: 92403c84     	and	x4, x4, #0xffff
    4b80: 91001884     	add	x4, x4, #0x6
    4b84: f8247843     	str	x3, [x2, x4, lsl #3]
    4b88: aa1403e0     	mov	x0, x20
    4b8c: aa1403e0     	mov	x0, x20
    4b90: b9401813     	ldr	w19, [x0, #0x18]
    4b94: b9401c05     	ldr	w5, [x0, #0x1c]
    4b98: 11000a66     	add	w6, w19, #0x2
    4b9c: 6b0500df     	cmp	w6, w5
    4ba0: 54002ea8     	b.hi	0x5174 <___pl_fn_11+0xa70>
    4ba4: aa1403e0     	mov	x0, x20
    4ba8: f9401007     	ldr	x7, [x0, #0x20]
    4bac: 2a1303e8     	mov	w8, w19
    4bb0: 8b0808e8     	add	x8, x7, x8, lsl #2
    4bb4: aa1503e1     	mov	x1, x21
    4bb8: b83358e1     	str	w1, [x7, w19, uxtw #2]
    4bbc: aa1a03e2     	mov	x2, x26
    4bc0: b9000502     	str	w2, [x8, #0x4]
    4bc4: 11000a69     	add	w9, w19, #0x2
    4bc8: b9001809     	str	w9, [x0, #0x18]
    4bcc: 52800000     	mov	w0, #0x0                ; =0
    4bd0: aa0003f6     	mov	x22, x0
    4bd4: 34002b81     	cbz	w1, 0x5144 <___pl_fn_11+0xa40>
    4bd8: aa1403e0     	mov	x0, x20
    4bdc: f940000b     	ldr	x11, [x0]
    4be0: aa1503e1     	mov	x1, x21
    4be4: f861596b     	ldr	x11, [x11, w1, uxtw #3]
    4be8: 51000d6c     	sub	w12, w11, #0x3
    4bec: 7100099f     	cmp	w12, #0x2
    4bf0: 54002923     	b.lo	0x5114 <___pl_fn_11+0xa10>
    4bf4: 5100156e     	sub	w14, w11, #0x5
    4bf8: 710015df     	cmp	w14, #0x5
    4bfc: 540028c2     	b.hs	0x5114 <___pl_fn_11+0xa10>
    4c00: 9a8e23e1     	csel	x1, xzr, x14, hs
    4c04: 1000008f     	adr	x15, 0x4c14 <___pl_fn_11+0x510>
    4c08: b8a159e1     	ldrsw	x1, [x15, w1, uxtw #2]
    4c0c: 8b0101ef     	add	x15, x15, x1
    4c10: d61f01e0     	br	x15
    4c14: 000000e8     	udf	#0xe8
    4c18: 000000b4     	udf	#0xb4
    4c1c: 00000080     	udf	#0x80
    4c20: 0000004c     	udf	#0x4c
    4c24: 00000018     	udf	#0x18
    4c28: 1400013b     	b	0x5114 <___pl_fn_11+0xa10>
    4c2c: aa1403e0     	mov	x0, x20
    4c30: b9401001     	ldr	w1, [x0, #0x10]
    4c34: b9401403     	ldr	w3, [x0, #0x14]
    4c38: 6b03003f     	cmp	w1, w3
    4c3c: 54001e02     	b.hs	0x4ffc <___pl_fn_11+0x8f8>
    4c40: aa1503e1     	mov	x1, x21
    4c44: aa1403e0     	mov	x0, x20
    4c48: 94000000     	bl	0x4c48 <___pl_fn_11+0x544>
    4c4c: aa1403e1     	mov	x1, x20
    4c50: b9402c21     	ldr	w1, [x1, #0x2c]
    4c54: 350023a1     	cbnz	w1, 0x50c8 <___pl_fn_11+0x9c4>
    4c58: aa1403e1     	mov	x1, x20
    4c5c: 14000034     	b	0x4d2c <___pl_fn_11+0x628>
    4c60: aa1403e0     	mov	x0, x20
    4c64: b9401001     	ldr	w1, [x0, #0x10]
    4c68: b9401403     	ldr	w3, [x0, #0x14]
    4c6c: 6b03003f     	cmp	w1, w3
    4c70: 54001e02     	b.hs	0x5030 <___pl_fn_11+0x92c>
    4c74: aa1503e1     	mov	x1, x21
    4c78: aa1403e0     	mov	x0, x20
    4c7c: 94000000     	bl	0x4c7c <___pl_fn_11+0x578>
    4c80: aa1403e1     	mov	x1, x20
    4c84: b9402c21     	ldr	w1, [x1, #0x2c]
    4c88: 35002201     	cbnz	w1, 0x50c8 <___pl_fn_11+0x9c4>
    4c8c: aa1403e1     	mov	x1, x20
    4c90: 14000027     	b	0x4d2c <___pl_fn_11+0x628>
    4c94: aa1403e0     	mov	x0, x20
    4c98: b9401001     	ldr	w1, [x0, #0x10]
    4c9c: b9401403     	ldr	w3, [x0, #0x14]
    4ca0: 6b03003f     	cmp	w1, w3
    4ca4: 54001e02     	b.hs	0x5064 <___pl_fn_11+0x960>
    4ca8: aa1503e1     	mov	x1, x21
    4cac: aa1403e0     	mov	x0, x20
    4cb0: 94000000     	bl	0x4cb0 <___pl_fn_11+0x5ac>
    4cb4: aa1403eb     	mov	x11, x20
    4cb8: b9402d61     	ldr	w1, [x11, #0x2c]
    4cbc: 35002061     	cbnz	w1, 0x50c8 <___pl_fn_11+0x9c4>
    4cc0: aa1403e1     	mov	x1, x20
    4cc4: 1400001a     	b	0x4d2c <___pl_fn_11+0x628>
    4cc8: aa1403e0     	mov	x0, x20
    4ccc: b9401001     	ldr	w1, [x0, #0x10]
    4cd0: b9401400     	ldr	w0, [x0, #0x14]
    4cd4: 6b00003f     	cmp	w1, w0
    4cd8: 54001e02     	b.hs	0x5098 <___pl_fn_11+0x994>
    4cdc: aa1503e1     	mov	x1, x21
    4ce0: aa1403e0     	mov	x0, x20
    4ce4: 94000000     	bl	0x4ce4 <___pl_fn_11+0x5e0>
    4ce8: aa1403e1     	mov	x1, x20
    4cec: b9402c21     	ldr	w1, [x1, #0x2c]
    4cf0: 35001ec1     	cbnz	w1, 0x50c8 <___pl_fn_11+0x9c4>
    4cf4: aa1403e1     	mov	x1, x20
    4cf8: 1400000d     	b	0x4d2c <___pl_fn_11+0x628>
    4cfc: aa1403e0     	mov	x0, x20
    4d00: b9401001     	ldr	w1, [x0, #0x10]
    4d04: b9401400     	ldr	w0, [x0, #0x14]
    4d08: 6b00003f     	cmp	w1, w0
    4d0c: 54001ec2     	b.hs	0x50e4 <___pl_fn_11+0x9e0>
    4d10: aa1503e1     	mov	x1, x21
    4d14: aa1403e0     	mov	x0, x20
    4d18: 94000000     	bl	0x4d18 <___pl_fn_11+0x614>
    4d1c: aa1403e1     	mov	x1, x20
    4d20: b9402c21     	ldr	w1, [x1, #0x2c]
    4d24: 35001d21     	cbnz	w1, 0x50c8 <___pl_fn_11+0x9c4>
    4d28: aa1403e1     	mov	x1, x20
    4d2c: aa1403e1     	mov	x1, x20
    4d30: b9001833     	str	w19, [x1, #0x18]
    4d34: b9401021     	ldr	w1, [x1, #0x10]
    4d38: 51000421     	sub	w1, w1, #0x1
    4d3c: aa1403e2     	mov	x2, x20
    4d40: b9001041     	str	w1, [x2, #0x10]
    4d44: 910143ff     	add	sp, sp, #0x50
    4d48: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4d4c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4d50: f84107fa     	ldr	x26, [sp], #0x10
    4d54: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4d58: d65f03c0     	ret
    4d5c: 140000ee     	b	0x5114 <___pl_fn_11+0xa10>
    4d60: aa0003f4     	mov	x20, x0
    4d64: 52801621     	mov	w1, #0xb1               ; =177
    4d68: 52800083     	mov	w3, #0x4                ; =4
    4d6c: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4d70: f9400084     	ldr	x4, [x4]
    4d74: aa1403e0     	mov	x0, x20
    4d78: aa1503e2     	mov	x2, x21
    4d7c: d63f0080     	blr	x4
    4d80: 34ffcfa0     	cbz	w0, 0x4774 <___pl_fn_11+0x70>
    4d84: 140000d1     	b	0x50c8 <___pl_fn_11+0x9c4>
    4d88: 52801641     	mov	w1, #0xb2               ; =178
    4d8c: 528000a3     	mov	w3, #0x5                ; =5
    4d90: 90000006     	adrp	x6, 0x4000 <___pl_fn_8+0x51c>
    4d94: f94000c6     	ldr	x6, [x6]
    4d98: aa1403e0     	mov	x0, x20
    4d9c: aa1303e2     	mov	x2, x19
    4da0: d63f00c0     	blr	x6
    4da4: aa1303f5     	mov	x21, x19
    4da8: 34ffd120     	cbz	w0, 0x47cc <___pl_fn_11+0xc8>
    4dac: 140000c7     	b	0x50c8 <___pl_fn_11+0x9c4>
    4db0: 52801661     	mov	w1, #0xb3               ; =179
    4db4: 528000c3     	mov	w3, #0x6                ; =6
    4db8: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4dbc: f9400084     	ldr	x4, [x4]
    4dc0: aa1403e0     	mov	x0, x20
    4dc4: aa1503e2     	mov	x2, x21
    4dc8: d63f0080     	blr	x4
    4dcc: 34ffd340     	cbz	w0, 0x4834 <___pl_fn_11+0x130>
    4dd0: 140000be     	b	0x50c8 <___pl_fn_11+0x9c4>
    4dd4: 52801681     	mov	w1, #0xb4               ; =180
    4dd8: 528000e3     	mov	w3, #0x7                ; =7
    4ddc: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4de0: f9400084     	ldr	x4, [x4]
    4de4: aa1403e0     	mov	x0, x20
    4de8: aa1503e2     	mov	x2, x21
    4dec: d63f0080     	blr	x4
    4df0: 34ffd4c0     	cbz	w0, 0x4888 <___pl_fn_11+0x184>
    4df4: 140000b5     	b	0x50c8 <___pl_fn_11+0x9c4>
    4df8: 528016a1     	mov	w1, #0xb5               ; =181
    4dfc: 52800043     	mov	w3, #0x2                ; =2
    4e00: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4e04: f9400084     	ldr	x4, [x4]
    4e08: aa1403e0     	mov	x0, x20
    4e0c: d63f0080     	blr	x4
    4e10: 34ffd5a0     	cbz	w0, 0x48c4 <___pl_fn_11+0x1c0>
    4e14: 140000ad     	b	0x50c8 <___pl_fn_11+0x9c4>
    4e18: 528016c1     	mov	w1, #0xb6               ; =182
    4e1c: 90000002     	adrp	x2, 0x4000 <___pl_fn_8+0x51c>
    4e20: f9400042     	ldr	x2, [x2]
    4e24: aa1403e0     	mov	x0, x20
    4e28: d63f0040     	blr	x2
    4e2c: 52800000     	mov	w0, #0x0                ; =0
    4e30: 910143ff     	add	sp, sp, #0x50
    4e34: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4e38: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4e3c: f84107fa     	ldr	x26, [sp], #0x10
    4e40: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4e44: d65f03c0     	ret
    4e48: 528016e1     	mov	w1, #0xb7               ; =183
    4e4c: 52800063     	mov	w3, #0x3                ; =3
    4e50: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4e54: f9400084     	ldr	x4, [x4]
    4e58: aa1403e0     	mov	x0, x20
    4e5c: aa1503e2     	mov	x2, x21
    4e60: d63f0080     	blr	x4
    4e64: 34ffd5c0     	cbz	w0, 0x491c <___pl_fn_11+0x218>
    4e68: 14000098     	b	0x50c8 <___pl_fn_11+0x9c4>
    4e6c: aa0a03fa     	mov	x26, x10
    4e70: 52801721     	mov	w1, #0xb9               ; =185
    4e74: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4e78: f9400084     	ldr	x4, [x4]
    4e7c: aa1403e0     	mov	x0, x20
    4e80: aa1a03e2     	mov	x2, x26
    4e84: d63f0080     	blr	x4
    4e88: 34ffd6c0     	cbz	w0, 0x4960 <___pl_fn_11+0x25c>
    4e8c: 1400008f     	b	0x50c8 <___pl_fn_11+0x9c4>
    4e90: d2800061     	mov	x1, #0x3                ; =3
    4e94: 910003e3     	mov	x3, sp
    4e98: f80003e1     	stur	x1, [sp]
    4e9c: 2a0003e1     	mov	w1, w0
    4ea0: f80083e1     	stur	x1, [sp, #0x8]
    4ea4: 52801741     	mov	w1, #0xba               ; =186
    4ea8: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4eac: f9400084     	ldr	x4, [x4]
    4eb0: aa1403e0     	mov	x0, x20
    4eb4: aa1503e2     	mov	x2, x21
    4eb8: d63f0080     	blr	x4
    4ebc: 34ffd620     	cbz	w0, 0x4980 <___pl_fn_11+0x27c>
    4ec0: 14000082     	b	0x50c8 <___pl_fn_11+0x9c4>
    4ec4: 52801761     	mov	w1, #0xbb               ; =187
    4ec8: 52800063     	mov	w3, #0x3                ; =3
    4ecc: 9000000b     	adrp	x11, 0x4000 <___pl_fn_8+0x51c>
    4ed0: f940016b     	ldr	x11, [x11]
    4ed4: aa1403e0     	mov	x0, x20
    4ed8: aa1503e2     	mov	x2, x21
    4edc: d63f0160     	blr	x11
    4ee0: 34ffd880     	cbz	w0, 0x49f0 <___pl_fn_11+0x2ec>
    4ee4: 14000079     	b	0x50c8 <___pl_fn_11+0x9c4>
    4ee8: 52801781     	mov	w1, #0xbc               ; =188
    4eec: 528000e3     	mov	w3, #0x7                ; =7
    4ef0: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4ef4: f9400084     	ldr	x4, [x4]
    4ef8: aa1403e0     	mov	x0, x20
    4efc: aa1503e2     	mov	x2, x21
    4f00: d63f0080     	blr	x4
    4f04: 34ffda00     	cbz	w0, 0x4a44 <___pl_fn_11+0x340>
    4f08: 14000070     	b	0x50c8 <___pl_fn_11+0x9c4>
    4f0c: 528017a1     	mov	w1, #0xbd               ; =189
    4f10: 52800043     	mov	w3, #0x2                ; =2
    4f14: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4f18: f9400084     	ldr	x4, [x4]
    4f1c: aa1403e0     	mov	x0, x20
    4f20: d63f0080     	blr	x4
    4f24: 34ffdae0     	cbz	w0, 0x4a80 <___pl_fn_11+0x37c>
    4f28: 14000068     	b	0x50c8 <___pl_fn_11+0x9c4>
    4f2c: d2800080     	mov	x0, #0x4                ; =4
    4f30: 910043e3     	add	x3, sp, #0x10
    4f34: f80103e0     	stur	x0, [sp, #0x10]
    4f38: d2800020     	mov	x0, #0x1                ; =1
    4f3c: f80183e0     	stur	x0, [sp, #0x18]
    4f40: 528017c1     	mov	w1, #0xbe               ; =190
    4f44: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4f48: f9400084     	ldr	x4, [x4]
    4f4c: aa1403e0     	mov	x0, x20
    4f50: aa1503e2     	mov	x2, x21
    4f54: d63f0080     	blr	x4
    4f58: 34ffdb80     	cbz	w0, 0x4ac8 <___pl_fn_11+0x3c4>
    4f5c: 1400005b     	b	0x50c8 <___pl_fn_11+0x9c4>
    4f60: d2800080     	mov	x0, #0x4                ; =4
    4f64: 910083e3     	add	x3, sp, #0x20
    4f68: f80203e0     	stur	x0, [sp, #0x20]
    4f6c: d2800000     	mov	x0, #0x0                ; =0
    4f70: f80283e0     	stur	x0, [sp, #0x28]
    4f74: 528017e1     	mov	w1, #0xbf               ; =191
    4f78: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4f7c: f9400084     	ldr	x4, [x4]
    4f80: aa1403e0     	mov	x0, x20
    4f84: aa1503e2     	mov	x2, x21
    4f88: d63f0080     	blr	x4
    4f8c: 34ffdbe0     	cbz	w0, 0x4b08 <___pl_fn_11+0x404>
    4f90: 1400004e     	b	0x50c8 <___pl_fn_11+0x9c4>
    4f94: d28000a0     	mov	x0, #0x5                ; =5
    4f98: 9100c3e3     	add	x3, sp, #0x30
    4f9c: f80303e0     	stur	x0, [sp, #0x30]
    4fa0: d2800000     	mov	x0, #0x0                ; =0
    4fa4: f80383e0     	stur	x0, [sp, #0x38]
    4fa8: 52801801     	mov	w1, #0xc0               ; =192
    4fac: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4fb0: f9400084     	ldr	x4, [x4]
    4fb4: aa1403e0     	mov	x0, x20
    4fb8: aa1503e2     	mov	x2, x21
    4fbc: d63f0080     	blr	x4
    4fc0: 34ffdac0     	cbz	w0, 0x4b18 <___pl_fn_11+0x414>
    4fc4: 14000041     	b	0x50c8 <___pl_fn_11+0x9c4>
    4fc8: d28000c0     	mov	x0, #0x6                ; =6
    4fcc: 910103e3     	add	x3, sp, #0x40
    4fd0: f80403e0     	stur	x0, [sp, #0x40]
    4fd4: d2800000     	mov	x0, #0x0                ; =0
    4fd8: f80483e0     	stur	x0, [sp, #0x48]
    4fdc: 52801821     	mov	w1, #0xc1               ; =193
    4fe0: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0x51c>
    4fe4: f9400084     	ldr	x4, [x4]
    4fe8: aa1403e0     	mov	x0, x20
    4fec: aa1503e2     	mov	x2, x21
    4ff0: d63f0080     	blr	x4
    4ff4: 34ffdca0     	cbz	w0, 0x4b88 <___pl_fn_11+0x484>
    4ff8: 14000034     	b	0x50c8 <___pl_fn_11+0x9c4>
    4ffc: 52801921     	mov	w1, #0xc9               ; =201
    5000: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    5004: f9400042     	ldr	x2, [x2]
    5008: aa1403e0     	mov	x0, x20
    500c: d63f0040     	blr	x2
    5010: aa1603e0     	mov	x0, x22
    5014: 910143ff     	add	sp, sp, #0x50
    5018: a8c153f3     	ldp	x19, x20, [sp], #0x10
    501c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5020: f84107fa     	ldr	x26, [sp], #0x10
    5024: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5028: d65f03c0     	ret
    502c: 14000027     	b	0x50c8 <___pl_fn_11+0x9c4>
    5030: 52801901     	mov	w1, #0xc8               ; =200
    5034: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    5038: f9400042     	ldr	x2, [x2]
    503c: aa1403e0     	mov	x0, x20
    5040: d63f0040     	blr	x2
    5044: aa1603e0     	mov	x0, x22
    5048: 910143ff     	add	sp, sp, #0x50
    504c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5050: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5054: f84107fa     	ldr	x26, [sp], #0x10
    5058: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    505c: d65f03c0     	ret
    5060: 1400001a     	b	0x50c8 <___pl_fn_11+0x9c4>
    5064: 528018e1     	mov	w1, #0xc7               ; =199
    5068: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    506c: f9400042     	ldr	x2, [x2]
    5070: aa1403e0     	mov	x0, x20
    5074: d63f0040     	blr	x2
    5078: aa1603e0     	mov	x0, x22
    507c: 910143ff     	add	sp, sp, #0x50
    5080: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5084: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5088: f84107fa     	ldr	x26, [sp], #0x10
    508c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5090: d65f03c0     	ret
    5094: 1400000d     	b	0x50c8 <___pl_fn_11+0x9c4>
    5098: 528018c1     	mov	w1, #0xc6               ; =198
    509c: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    50a0: f9400042     	ldr	x2, [x2]
    50a4: aa1403e0     	mov	x0, x20
    50a8: d63f0040     	blr	x2
    50ac: aa1603e0     	mov	x0, x22
    50b0: 910143ff     	add	sp, sp, #0x50
    50b4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    50b8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    50bc: f84107fa     	ldr	x26, [sp], #0x10
    50c0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    50c4: d65f03c0     	ret
    50c8: 52800000     	mov	w0, #0x0                ; =0
    50cc: 910143ff     	add	sp, sp, #0x50
    50d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    50d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    50d8: f84107fa     	ldr	x26, [sp], #0x10
    50dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    50e0: d65f03c0     	ret
    50e4: 528018a1     	mov	w1, #0xc5               ; =197
    50e8: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    50ec: f9400042     	ldr	x2, [x2]
    50f0: aa1403e0     	mov	x0, x20
    50f4: d63f0040     	blr	x2
    50f8: aa1603e0     	mov	x0, x22
    50fc: 910143ff     	add	sp, sp, #0x50
    5100: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5104: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5108: f84107fa     	ldr	x26, [sp], #0x10
    510c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5110: d65f03c0     	ret
    5114: 52801881     	mov	w1, #0xc4               ; =196
    5118: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    511c: f9400042     	ldr	x2, [x2]
    5120: aa1403e0     	mov	x0, x20
    5124: d63f0040     	blr	x2
    5128: aa1603e0     	mov	x0, x22
    512c: 910143ff     	add	sp, sp, #0x50
    5130: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5134: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5138: f84107fa     	ldr	x26, [sp], #0x10
    513c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5140: d65f03c0     	ret
    5144: 52801861     	mov	w1, #0xc3               ; =195
    5148: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    514c: f9400042     	ldr	x2, [x2]
    5150: aa1403e0     	mov	x0, x20
    5154: d63f0040     	blr	x2
    5158: aa1603e0     	mov	x0, x22
    515c: 910143ff     	add	sp, sp, #0x50
    5160: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5164: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5168: f84107fa     	ldr	x26, [sp], #0x10
    516c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5170: d65f03c0     	ret
    5174: 52801841     	mov	w1, #0xc2               ; =194
    5178: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    517c: f9400042     	ldr	x2, [x2]
    5180: aa1403e0     	mov	x0, x20
    5184: d63f0040     	blr	x2
    5188: 52800000     	mov	w0, #0x0                ; =0
    518c: 910143ff     	add	sp, sp, #0x50
    5190: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5194: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5198: f84107fa     	ldr	x26, [sp], #0x10
    519c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    51a0: d65f03c0     	ret
    51a4: aa0303f3     	mov	x19, x3
    51a8: 52801701     	mov	w1, #0xb8               ; =184
    51ac: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    51b0: f9400042     	ldr	x2, [x2]
    51b4: aa1403e0     	mov	x0, x20
    51b8: d63f0040     	blr	x2
    51bc: aa1303e0     	mov	x0, x19
    51c0: 910143ff     	add	sp, sp, #0x50
    51c4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    51c8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    51cc: f84107fa     	ldr	x26, [sp], #0x10
    51d0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    51d4: d65f03c0     	ret

00000000000051d8 <___pl_fn_12>:
    51d8: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    51dc: 910003fd     	mov	x29, sp
    51e0: a9bf5bf3     	stp	x19, x22, [sp, #-0x10]!
    51e4: d10043ff     	sub	sp, sp, #0x10
    51e8: aa0103f6     	mov	x22, x1
    51ec: b9401001     	ldr	w1, [x0, #0x10]
    51f0: 11000421     	add	w1, w1, #0x1
    51f4: b9001001     	str	w1, [x0, #0x10]
    51f8: aa0003e2     	mov	x2, x0
    51fc: aa1603e1     	mov	x1, x22
    5200: 34000281     	cbz	w1, 0x5250 <___pl_fn_12+0x78>
    5204: aa0203f3     	mov	x19, x2
    5208: f9400262     	ldr	x2, [x19]
    520c: aa1603e1     	mov	x1, x22
    5210: 2a0103e0     	mov	w0, w1
    5214: 8b000c40     	add	x0, x2, x0, lsl #3
    5218: f8615842     	ldr	x2, [x2, w1, uxtw #3]
    521c: d2800021     	mov	x1, #0x1                ; =1
    5220: d360fc42     	lsr	x2, x2, #32
    5224: 92403c42     	and	x2, x2, #0xffff
    5228: 91001442     	add	x2, x2, #0x5
    522c: f8227801     	str	x1, [x0, x2, lsl #3]
    5230: b9401260     	ldr	w0, [x19, #0x10]
    5234: 51000400     	sub	w0, w0, #0x1
    5238: b9001260     	str	w0, [x19, #0x10]
    523c: aa1603e0     	mov	x0, x22
    5240: 910043ff     	add	sp, sp, #0x10
    5244: a8c15bf3     	ldp	x19, x22, [sp], #0x10
    5248: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    524c: d65f03c0     	ret
    5250: d28000a0     	mov	x0, #0x5                ; =5
    5254: 910003e3     	mov	x3, sp
    5258: f80003e0     	stur	x0, [sp]
    525c: d2800020     	mov	x0, #0x1                ; =1
    5260: f80083e0     	stur	x0, [sp, #0x8]
    5264: 52801941     	mov	w1, #0xca               ; =202
    5268: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    526c: f9400084     	ldr	x4, [x4]
    5270: aa0203f3     	mov	x19, x2
    5274: aa1303e0     	mov	x0, x19
    5278: aa1603e2     	mov	x2, x22
    527c: d63f0080     	blr	x4
    5280: 34fffd80     	cbz	w0, 0x5230 <___pl_fn_12+0x58>
    5284: 52800000     	mov	w0, #0x0                ; =0
    5288: 910043ff     	add	sp, sp, #0x10
    528c: a8c15bf3     	ldp	x19, x22, [sp], #0x10
    5290: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5294: d65f03c0     	ret

0000000000005298 <___pl_fn_13>:
    5298: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    529c: 910003fd     	mov	x29, sp
    52a0: f81f0ff5     	str	x21, [sp, #-0x10]!
    52a4: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    52a8: d10083ff     	sub	sp, sp, #0x20
    52ac: aa0103f3     	mov	x19, x1
    52b0: b9401001     	ldr	w1, [x0, #0x10]
    52b4: 11000421     	add	w1, w1, #0x1
    52b8: b9001001     	str	w1, [x0, #0x10]
    52bc: aa1303e1     	mov	x1, x19
    52c0: 34000d81     	cbz	w1, 0x5470 <___pl_fn_13+0x1d8>
    52c4: f9400001     	ldr	x1, [x0]
    52c8: aa1303e4     	mov	x4, x19
    52cc: aa0003f5     	mov	x21, x0
    52d0: 2a0403e0     	mov	w0, w4
    52d4: 8b000c20     	add	x0, x1, x0, lsl #3
    52d8: aa1303e7     	mov	x7, x19
    52dc: f8675821     	ldr	x1, [x1, w7, uxtw #3]
    52e0: d360fc21     	lsr	x1, x1, #32
    52e4: 92403c21     	and	x1, x1, #0xffff
    52e8: 91001c21     	add	x1, x1, #0x7
    52ec: d37df021     	lsl	x1, x1, #3
    52f0: b8616802     	ldr	w2, [x0, x1]
    52f4: 35000082     	cbnz	w2, 0x5304 <___pl_fn_13+0x6c>
    52f8: 1400005f     	b	0x5474 <___pl_fn_13+0x1dc>
    52fc: aa1503e0     	mov	x0, x21
    5300: f9401802     	ldr	x2, [x0, #0x30]
    5304: 34000ca2     	cbz	w2, 0x5498 <___pl_fn_13+0x200>
    5308: aa1503e0     	mov	x0, x21
    530c: f9400000     	ldr	x0, [x0]
    5310: 2a0203e1     	mov	w1, w2
    5314: 8b010c01     	add	x1, x0, x1, lsl #3
    5318: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    531c: d360fc00     	lsr	x0, x0, #32
    5320: 92403c03     	and	x3, x0, #0xffff
    5324: 91002460     	add	x0, x3, #0x9
    5328: f8607820     	ldr	x0, [x1, x0, lsl #3]
    532c: f100087f     	cmp	x3, #0x2
    5330: 540000c0     	b.eq	0x5348 <___pl_fn_13+0xb0>
    5334: f9400821     	ldr	x1, [x1, #0x10]
    5338: 37480b01     	tbnz	w1, #0x9, 0x5498 <___pl_fn_13+0x200>
    533c: 14000003     	b	0x5348 <___pl_fn_13+0xb0>
    5340: aa1503e0     	mov	x0, x21
    5344: f9401800     	ldr	x0, [x0, #0x30]
    5348: d2800021     	mov	x1, #0x1                ; =1
    534c: ab010014     	adds	x20, x0, x1
    5350: 9a9f77e0     	cset	x0, vs
    5354: 72001c1f     	tst	w0, #0xff
    5358: 540010e1     	b.ne	0x5574 <___pl_fn_13+0x2dc>
    535c: 34000af3     	cbz	w19, 0x54b8 <___pl_fn_13+0x220>
    5360: aa1503e0     	mov	x0, x21
    5364: f9400003     	ldr	x3, [x0]
    5368: 2a1303e2     	mov	w2, w19
    536c: 8b020c62     	add	x2, x3, x2, lsl #3
    5370: f8735863     	ldr	x3, [x3, w19, uxtw #3]
    5374: d360fc63     	lsr	x3, x3, #32
    5378: 92403c63     	and	x3, x3, #0xffff
    537c: 91001c63     	add	x3, x3, #0x7
    5380: d37df063     	lsl	x3, x3, #3
    5384: b8636842     	ldr	w2, [x2, x3]
    5388: 35000082     	cbnz	w2, 0x5398 <___pl_fn_13+0x100>
    538c: 1400004b     	b	0x54b8 <___pl_fn_13+0x220>
    5390: aa1503e0     	mov	x0, x21
    5394: f9401802     	ldr	x2, [x0, #0x30]
    5398: 34000a22     	cbz	w2, 0x54dc <___pl_fn_13+0x244>
    539c: aa1503e0     	mov	x0, x21
    53a0: f940000f     	ldr	x15, [x0]
    53a4: 2a0203ee     	mov	w14, w2
    53a8: 8b0e0dee     	add	x14, x15, x14, lsl #3
    53ac: f86259ef     	ldr	x15, [x15, w2, uxtw #3]
    53b0: d360fdef     	lsr	x15, x15, #32
    53b4: 92403de0     	and	x0, x15, #0xffff
    53b8: f100081f     	cmp	x0, #0x2
    53bc: 54000080     	b.eq	0x53cc <___pl_fn_13+0x134>
    53c0: f94009c0     	ldr	x0, [x14, #0x10]
    53c4: 9276f800     	and	x0, x0, #0xfffffffffffffdff
    53c8: f90009c0     	str	x0, [x14, #0x10]
    53cc: 92403de0     	and	x0, x15, #0xffff
    53d0: 91002400     	add	x0, x0, #0x9
    53d4: f82079d4     	str	x20, [x14, x0, lsl #3]
    53d8: 34000993     	cbz	w19, 0x5508 <___pl_fn_13+0x270>
    53dc: aa1503e0     	mov	x0, x21
    53e0: f9400001     	ldr	x1, [x0]
    53e4: 2a1303e0     	mov	w0, w19
    53e8: 8b000c20     	add	x0, x1, x0, lsl #3
    53ec: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    53f0: d2800021     	mov	x1, #0x1                ; =1
    53f4: d360fc42     	lsr	x2, x2, #32
    53f8: 92403c42     	and	x2, x2, #0xffff
    53fc: 91001842     	add	x2, x2, #0x6
    5400: f8227801     	str	x1, [x0, x2, lsl #3]
    5404: 340009d3     	cbz	w19, 0x553c <___pl_fn_13+0x2a4>
    5408: aa1503e0     	mov	x0, x21
    540c: f9400001     	ldr	x1, [x0]
    5410: 2a1303e0     	mov	w0, w19
    5414: 8b000c20     	add	x0, x1, x0, lsl #3
    5418: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    541c: d360fc21     	lsr	x1, x1, #32
    5420: 92403c21     	and	x1, x1, #0xffff
    5424: d37df021     	lsl	x1, x1, #3
    5428: b8616800     	ldr	w0, [x0, x1]
    542c: 350000c0     	cbnz	w0, 0x5444 <___pl_fn_13+0x1ac>
    5430: 14000043     	b	0x553c <___pl_fn_13+0x2a4>
    5434: aa1503e0     	mov	x0, x21
    5438: f9401800     	ldr	x0, [x0, #0x30]
    543c: aa1503e1     	mov	x1, x21
    5440: 14000002     	b	0x5448 <___pl_fn_13+0x1b0>
    5444: aa1503e1     	mov	x1, x21
    5448: aa1503e1     	mov	x1, x21
    544c: b9401021     	ldr	w1, [x1, #0x10]
    5450: 51000421     	sub	w1, w1, #0x1
    5454: aa1503e2     	mov	x2, x21
    5458: b9001041     	str	w1, [x2, #0x10]
    545c: 910083ff     	add	sp, sp, #0x20
    5460: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5464: f84107f5     	ldr	x21, [sp], #0x10
    5468: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    546c: d65f03c0     	ret
    5470: aa0003f5     	mov	x21, x0
    5474: 52801961     	mov	w1, #0xcb               ; =203
    5478: 528000e3     	mov	w3, #0x7                ; =7
    547c: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5480: f9400084     	ldr	x4, [x4]
    5484: aa1503e0     	mov	x0, x21
    5488: aa1303e2     	mov	x2, x19
    548c: d63f0080     	blr	x4
    5490: 34fff360     	cbz	w0, 0x52fc <___pl_fn_13+0x64>
    5494: 14000032     	b	0x555c <___pl_fn_13+0x2c4>
    5498: 52801981     	mov	w1, #0xcc               ; =204
    549c: 52800123     	mov	w3, #0x9                ; =9
    54a0: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    54a4: f9400084     	ldr	x4, [x4]
    54a8: aa1503e0     	mov	x0, x21
    54ac: d63f0080     	blr	x4
    54b0: 34fff480     	cbz	w0, 0x5340 <___pl_fn_13+0xa8>
    54b4: 1400002a     	b	0x555c <___pl_fn_13+0x2c4>
    54b8: 528019c1     	mov	w1, #0xce               ; =206
    54bc: 528000e3     	mov	w3, #0x7                ; =7
    54c0: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    54c4: f9400084     	ldr	x4, [x4]
    54c8: aa1503e0     	mov	x0, x21
    54cc: aa1303e2     	mov	x2, x19
    54d0: d63f0080     	blr	x4
    54d4: 34fff5e0     	cbz	w0, 0x5390 <___pl_fn_13+0xf8>
    54d8: 14000021     	b	0x555c <___pl_fn_13+0x2c4>
    54dc: d2800129     	mov	x9, #0x9                ; =9
    54e0: 910003e3     	mov	x3, sp
    54e4: f80003e9     	stur	x9, [sp]
    54e8: f80083f4     	stur	x20, [sp, #0x8]
    54ec: 528019e1     	mov	w1, #0xcf               ; =207
    54f0: 9000000b     	adrp	x11, 0x5000 <___pl_fn_11+0x8fc>
    54f4: f940016b     	ldr	x11, [x11]
    54f8: aa1503e0     	mov	x0, x21
    54fc: d63f0160     	blr	x11
    5500: 34fff6c0     	cbz	w0, 0x53d8 <___pl_fn_13+0x140>
    5504: 14000016     	b	0x555c <___pl_fn_13+0x2c4>
    5508: d28000c0     	mov	x0, #0x6                ; =6
    550c: 910043e3     	add	x3, sp, #0x10
    5510: f80103e0     	stur	x0, [sp, #0x10]
    5514: d2800020     	mov	x0, #0x1                ; =1
    5518: f80183e0     	stur	x0, [sp, #0x18]
    551c: 52801a01     	mov	w1, #0xd0               ; =208
    5520: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5524: f9400084     	ldr	x4, [x4]
    5528: aa1503e0     	mov	x0, x21
    552c: aa1303e2     	mov	x2, x19
    5530: d63f0080     	blr	x4
    5534: 34fff680     	cbz	w0, 0x5404 <___pl_fn_13+0x16c>
    5538: 14000009     	b	0x555c <___pl_fn_13+0x2c4>
    553c: 52801a21     	mov	w1, #0xd1               ; =209
    5540: 52800003     	mov	w3, #0x0                ; =0
    5544: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5548: f9400084     	ldr	x4, [x4]
    554c: aa1303e2     	mov	x2, x19
    5550: aa1503e0     	mov	x0, x21
    5554: d63f0080     	blr	x4
    5558: 34fff6e0     	cbz	w0, 0x5434 <___pl_fn_13+0x19c>
    555c: 52800000     	mov	w0, #0x0                ; =0
    5560: 910083ff     	add	sp, sp, #0x20
    5564: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5568: f84107f5     	ldr	x21, [sp], #0x10
    556c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5570: d65f03c0     	ret
    5574: 528019a1     	mov	w1, #0xcd               ; =205
    5578: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    557c: f9400042     	ldr	x2, [x2]
    5580: aa1503e0     	mov	x0, x21
    5584: d63f0040     	blr	x2
    5588: 52800000     	mov	w0, #0x0                ; =0
    558c: 910083ff     	add	sp, sp, #0x20
    5590: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5594: f84107f5     	ldr	x21, [sp], #0x10
    5598: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    559c: d65f03c0     	ret

00000000000055a0 <___pl_fn_14>:
    55a0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    55a4: 910003fd     	mov	x29, sp
    55a8: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    55ac: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    55b0: d10043ff     	sub	sp, sp, #0x10
    55b4: aa0103f3     	mov	x19, x1
    55b8: aa0203f5     	mov	x21, x2
    55bc: b9401001     	ldr	w1, [x0, #0x10]
    55c0: 11000421     	add	w1, w1, #0x1
    55c4: b9001001     	str	w1, [x0, #0x10]
    55c8: aa1303e1     	mov	x1, x19
    55cc: 34001001     	cbz	w1, 0x57cc <___pl_fn_14+0x22c>
    55d0: f9400001     	ldr	x1, [x0]
    55d4: aa1303ee     	mov	x14, x19
    55d8: aa0003f6     	mov	x22, x0
    55dc: 2a0e03e0     	mov	w0, w14
    55e0: 8b000c20     	add	x0, x1, x0, lsl #3
    55e4: aa1303e2     	mov	x2, x19
    55e8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    55ec: d360fc21     	lsr	x1, x1, #32
    55f0: 92403c21     	and	x1, x1, #0xffff
    55f4: 91001c21     	add	x1, x1, #0x7
    55f8: d37df021     	lsl	x1, x1, #3
    55fc: b8616801     	ldr	w1, [x0, x1]
    5600: 350000a1     	cbnz	w1, 0x5614 <___pl_fn_14+0x74>
    5604: 14000073     	b	0x57d0 <___pl_fn_14+0x230>
    5608: aa1603e0     	mov	x0, x22
    560c: f9401801     	ldr	x1, [x0, #0x30]
    5610: 14000002     	b	0x5618 <___pl_fn_14+0x78>
    5614: aa1603e0     	mov	x0, x22
    5618: aa1603e0     	mov	x0, x22
    561c: b9401814     	ldr	w20, [x0, #0x18]
    5620: b9401c00     	ldr	w0, [x0, #0x1c]
    5624: 11000a82     	add	w2, w20, #0x2
    5628: 6b00005f     	cmp	w2, w0
    562c: 540015c8     	b.hi	0x58e4 <___pl_fn_14+0x344>
    5630: aa1603e0     	mov	x0, x22
    5634: f9401000     	ldr	x0, [x0, #0x20]
    5638: 2a1403e2     	mov	w2, w20
    563c: 8b020802     	add	x2, x0, x2, lsl #2
    5640: b8345813     	str	w19, [x0, w20, uxtw #2]
    5644: b9000441     	str	w1, [x2, #0x4]
    5648: 11000a80     	add	w0, w20, #0x2
    564c: aa1603ee     	mov	x14, x22
    5650: b90019c0     	str	w0, [x14, #0x18]
    5654: aa1603e0     	mov	x0, x22
    5658: b9401000     	ldr	w0, [x0, #0x10]
    565c: aa1603e2     	mov	x2, x22
    5660: b9401442     	ldr	w2, [x2, #0x14]
    5664: 6b02001f     	cmp	w0, w2
    5668: 54001282     	b.hs	0x58b8 <___pl_fn_14+0x318>
    566c: aa1503e2     	mov	x2, x21
    5670: aa1603e0     	mov	x0, x22
    5674: 94000000     	bl	0x5674 <___pl_fn_14+0xd4>
    5678: aa1603e1     	mov	x1, x22
    567c: b9402c21     	ldr	w1, [x1, #0x2c]
    5680: 35001101     	cbnz	w1, 0x58a0 <___pl_fn_14+0x300>
    5684: aa1603e1     	mov	x1, x22
    5688: b9001834     	str	w20, [x1, #0x18]
    568c: 34000f40     	cbz	w0, 0x5874 <___pl_fn_14+0x2d4>
    5690: 35000080     	cbnz	w0, 0x56a0 <___pl_fn_14+0x100>
    5694: 14000058     	b	0x57f4 <___pl_fn_14+0x254>
    5698: aa1403e0     	mov	x0, x20
    569c: 1400000f     	b	0x56d8 <___pl_fn_14+0x138>
    56a0: aa0003f4     	mov	x20, x0
    56a4: aa1603e0     	mov	x0, x22
    56a8: f9400001     	ldr	x1, [x0]
    56ac: aa1403e0     	mov	x0, x20
    56b0: 2a0003e0     	mov	w0, w0
    56b4: 8b000c20     	add	x0, x1, x0, lsl #3
    56b8: aa1403e2     	mov	x2, x20
    56bc: f8625822     	ldr	x2, [x1, w2, uxtw #3]
    56c0: d2800001     	mov	x1, #0x0                ; =0
    56c4: d360fc42     	lsr	x2, x2, #32
    56c8: 92403c42     	and	x2, x2, #0xffff
    56cc: 91001842     	add	x2, x2, #0x6
    56d0: f8227801     	str	x1, [x0, x2, lsl #3]
    56d4: aa1403e0     	mov	x0, x20
    56d8: aa1403e0     	mov	x0, x20
    56dc: 34000a80     	cbz	w0, 0x582c <___pl_fn_14+0x28c>
    56e0: aa1603e0     	mov	x0, x22
    56e4: f9400001     	ldr	x1, [x0]
    56e8: aa1403e0     	mov	x0, x20
    56ec: 2a0003e0     	mov	w0, w0
    56f0: 8b000c20     	add	x0, x1, x0, lsl #3
    56f4: aa1403ed     	mov	x13, x20
    56f8: f86d5821     	ldr	x1, [x1, w13, uxtw #3]
    56fc: d360fc21     	lsr	x1, x1, #32
    5700: 92403c21     	and	x1, x1, #0xffff
    5704: 91000822     	add	x2, x1, #0x2
    5708: f8627815     	ldr	x21, [x0, x2, lsl #3]
    570c: f100083f     	cmp	x1, #0x2
    5710: 540000c0     	b.eq	0x5728 <___pl_fn_14+0x188>
    5714: f9400800     	ldr	x0, [x0, #0x10]
    5718: 371008a0     	tbnz	w0, #0x2, 0x582c <___pl_fn_14+0x28c>
    571c: 14000003     	b	0x5728 <___pl_fn_14+0x188>
    5720: aa1603e0     	mov	x0, x22
    5724: f9401815     	ldr	x21, [x0, #0x30]
    5728: 34000953     	cbz	w19, 0x5850 <___pl_fn_14+0x2b0>
    572c: aa1603e0     	mov	x0, x22
    5730: f940000a     	ldr	x10, [x0]
    5734: 2a1303e9     	mov	w9, w19
    5738: 8b090d49     	add	x9, x10, x9, lsl #3
    573c: f873594a     	ldr	x10, [x10, w19, uxtw #3]
    5740: d360fd4a     	lsr	x10, x10, #32
    5744: 92403d4a     	and	x10, x10, #0xffff
    5748: 9100094b     	add	x11, x10, #0x2
    574c: f86b7920     	ldr	x0, [x9, x11, lsl #3]
    5750: f100095f     	cmp	x10, #0x2
    5754: 540000c0     	b.eq	0x576c <___pl_fn_14+0x1cc>
    5758: f940092c     	ldr	x12, [x9, #0x10]
    575c: 371007ac     	tbnz	w12, #0x2, 0x5850 <___pl_fn_14+0x2b0>
    5760: 14000003     	b	0x576c <___pl_fn_14+0x1cc>
    5764: aa1603e0     	mov	x0, x22
    5768: f9401800     	ldr	x0, [x0, #0x30]
    576c: eb0002bf     	cmp	x21, x0
    5770: 5400018c     	b.gt	0x57a0 <___pl_fn_14+0x200>
    5774: aa1603e0     	mov	x0, x22
    5778: b9401000     	ldr	w0, [x0, #0x10]
    577c: 51000400     	sub	w0, w0, #0x1
    5780: aa1603e1     	mov	x1, x22
    5784: b9001020     	str	w0, [x1, #0x10]
    5788: aa1303e0     	mov	x0, x19
    578c: 910043ff     	add	sp, sp, #0x10
    5790: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5794: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5798: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    579c: d65f03c0     	ret
    57a0: aa1603e0     	mov	x0, x22
    57a4: b9401000     	ldr	w0, [x0, #0x10]
    57a8: 51000400     	sub	w0, w0, #0x1
    57ac: aa1603e1     	mov	x1, x22
    57b0: b9001020     	str	w0, [x1, #0x10]
    57b4: aa1403e0     	mov	x0, x20
    57b8: 910043ff     	add	sp, sp, #0x10
    57bc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    57c0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    57c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    57c8: d65f03c0     	ret
    57cc: aa0003f6     	mov	x22, x0
    57d0: 52801a41     	mov	w1, #0xd2               ; =210
    57d4: 528000e3     	mov	w3, #0x7                ; =7
    57d8: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    57dc: f9400084     	ldr	x4, [x4]
    57e0: aa1603e0     	mov	x0, x22
    57e4: aa1303e2     	mov	x2, x19
    57e8: d63f0080     	blr	x4
    57ec: 34fff0e0     	cbz	w0, 0x5608 <___pl_fn_14+0x68>
    57f0: 1400002c     	b	0x58a0 <___pl_fn_14+0x300>
    57f4: aa0003f4     	mov	x20, x0
    57f8: d28000c0     	mov	x0, #0x6                ; =6
    57fc: 910003e3     	mov	x3, sp
    5800: f80003e0     	stur	x0, [sp]
    5804: d2800000     	mov	x0, #0x0                ; =0
    5808: f80083e0     	stur	x0, [sp, #0x8]
    580c: 52801ac1     	mov	w1, #0xd6               ; =214
    5810: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5814: f9400084     	ldr	x4, [x4]
    5818: aa1603e0     	mov	x0, x22
    581c: aa1403e2     	mov	x2, x20
    5820: d63f0080     	blr	x4
    5824: 34fff3a0     	cbz	w0, 0x5698 <___pl_fn_14+0xf8>
    5828: 1400001e     	b	0x58a0 <___pl_fn_14+0x300>
    582c: 52801ae1     	mov	w1, #0xd7               ; =215
    5830: 52800043     	mov	w3, #0x2                ; =2
    5834: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5838: f9400084     	ldr	x4, [x4]
    583c: aa1603e0     	mov	x0, x22
    5840: aa1403e2     	mov	x2, x20
    5844: d63f0080     	blr	x4
    5848: 34fff6c0     	cbz	w0, 0x5720 <___pl_fn_14+0x180>
    584c: 14000015     	b	0x58a0 <___pl_fn_14+0x300>
    5850: 52801b01     	mov	w1, #0xd8               ; =216
    5854: 52800043     	mov	w3, #0x2                ; =2
    5858: 9000000f     	adrp	x15, 0x5000 <___pl_fn_11+0x8fc>
    585c: f94001ef     	ldr	x15, [x15]
    5860: aa1603e0     	mov	x0, x22
    5864: aa1303e2     	mov	x2, x19
    5868: d63f01e0     	blr	x15
    586c: 34fff7c0     	cbz	w0, 0x5764 <___pl_fn_14+0x1c4>
    5870: 1400000c     	b	0x58a0 <___pl_fn_14+0x300>
    5874: 52801aa1     	mov	w1, #0xd5               ; =213
    5878: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    587c: f9400042     	ldr	x2, [x2]
    5880: aa1603e0     	mov	x0, x22
    5884: d63f0040     	blr	x2
    5888: 52800000     	mov	w0, #0x0                ; =0
    588c: 910043ff     	add	sp, sp, #0x10
    5890: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5894: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5898: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    589c: d65f03c0     	ret
    58a0: 52800000     	mov	w0, #0x0                ; =0
    58a4: 910043ff     	add	sp, sp, #0x10
    58a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    58ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    58b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    58b4: d65f03c0     	ret
    58b8: 52801a81     	mov	w1, #0xd4               ; =212
    58bc: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    58c0: f9400042     	ldr	x2, [x2]
    58c4: aa1603e0     	mov	x0, x22
    58c8: d63f0040     	blr	x2
    58cc: 52800000     	mov	w0, #0x0                ; =0
    58d0: 910043ff     	add	sp, sp, #0x10
    58d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    58d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    58dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    58e0: d65f03c0     	ret
    58e4: 52801a61     	mov	w1, #0xd3               ; =211
    58e8: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    58ec: f9400042     	ldr	x2, [x2]
    58f0: aa1603e0     	mov	x0, x22
    58f4: d63f0040     	blr	x2
    58f8: 52800000     	mov	w0, #0x0                ; =0
    58fc: 910043ff     	add	sp, sp, #0x10
    5900: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5904: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5908: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    590c: d65f03c0     	ret

0000000000005910 <___pl_fn_15>:
    5910: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    5914: 910003fd     	mov	x29, sp
    5918: a9bf6ff7     	stp	x23, x27, [sp, #-0x10]!
    591c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    5920: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    5924: d100c3ff     	sub	sp, sp, #0x30
    5928: aa0103f3     	mov	x19, x1
    592c: aa0203f7     	mov	x23, x2
    5930: b9401001     	ldr	w1, [x0, #0x10]
    5934: 11000421     	add	w1, w1, #0x1
    5938: b9001001     	str	w1, [x0, #0x10]
    593c: aa1303e1     	mov	x1, x19
    5940: 34002221     	cbz	w1, 0x5d84 <___pl_fn_15+0x474>
    5944: f9400001     	ldr	x1, [x0]
    5948: aa0003f6     	mov	x22, x0
    594c: aa1303e0     	mov	x0, x19
    5950: 2a0003e0     	mov	w0, w0
    5954: 8b000c20     	add	x0, x1, x0, lsl #3
    5958: aa1303e2     	mov	x2, x19
    595c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    5960: d360fc21     	lsr	x1, x1, #32
    5964: 92403c21     	and	x1, x1, #0xffff
    5968: 91001c21     	add	x1, x1, #0x7
    596c: d37df021     	lsl	x1, x1, #3
    5970: b8616801     	ldr	w1, [x0, x1]
    5974: 350000e1     	cbnz	w1, 0x5990 <___pl_fn_15+0x80>
    5978: 14000104     	b	0x5d88 <___pl_fn_15+0x478>
    597c: aa1603e0     	mov	x0, x22
    5980: f9401801     	ldr	x1, [x0, #0x30]
    5984: aa0103f5     	mov	x21, x1
    5988: aa1703e2     	mov	x2, x23
    598c: 14000003     	b	0x5998 <___pl_fn_15+0x88>
    5990: aa0103f5     	mov	x21, x1
    5994: aa1703e2     	mov	x2, x23
    5998: 340020a2     	cbz	w2, 0x5dac <___pl_fn_15+0x49c>
    599c: aa1603e0     	mov	x0, x22
    59a0: f9400001     	ldr	x1, [x0]
    59a4: 2a0203e0     	mov	w0, w2
    59a8: 8b000c20     	add	x0, x1, x0, lsl #3
    59ac: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    59b0: aa0203f7     	mov	x23, x2
    59b4: d360fc21     	lsr	x1, x1, #32
    59b8: 92403c21     	and	x1, x1, #0xffff
    59bc: 91000422     	add	x2, x1, #0x1
    59c0: f8627802     	ldr	x2, [x0, x2, lsl #3]
    59c4: f100083f     	cmp	x1, #0x2
    59c8: 540000e0     	b.eq	0x59e4 <___pl_fn_15+0xd4>
    59cc: f9400800     	ldr	x0, [x0, #0x10]
    59d0: 37081f00     	tbnz	w0, #0x1, 0x5db0 <___pl_fn_15+0x4a0>
    59d4: 14000004     	b	0x59e4 <___pl_fn_15+0xd4>
    59d8: aa1603e0     	mov	x0, x22
    59dc: f9401802     	ldr	x2, [x0, #0x30]
    59e0: 14000002     	b	0x59e8 <___pl_fn_15+0xd8>
    59e4: aa1603e0     	mov	x0, x22
    59e8: aa1603e0     	mov	x0, x22
    59ec: b9401814     	ldr	w20, [x0, #0x18]
    59f0: b9401c00     	ldr	w0, [x0, #0x1c]
    59f4: 11000e81     	add	w1, w20, #0x3
    59f8: 6b00003f     	cmp	w1, w0
    59fc: 54003208     	b.hi	0x603c <___pl_fn_15+0x72c>
    5a00: aa1603e0     	mov	x0, x22
    5a04: f9401000     	ldr	x0, [x0, #0x20]
    5a08: 2a1403e1     	mov	w1, w20
    5a0c: 8b010803     	add	x3, x0, x1, lsl #2
    5a10: b8345813     	str	w19, [x0, w20, uxtw #2]
    5a14: aa1703e0     	mov	x0, x23
    5a18: b9000460     	str	w0, [x3, #0x4]
    5a1c: aa1503e1     	mov	x1, x21
    5a20: b9000861     	str	w1, [x3, #0x8]
    5a24: 11000e80     	add	w0, w20, #0x3
    5a28: aa1603e3     	mov	x3, x22
    5a2c: b9001860     	str	w0, [x3, #0x18]
    5a30: aa1603e0     	mov	x0, x22
    5a34: b9401000     	ldr	w0, [x0, #0x10]
    5a38: b9401463     	ldr	w3, [x3, #0x14]
    5a3c: 6b03001f     	cmp	w0, w3
    5a40: 54002e62     	b.hs	0x600c <___pl_fn_15+0x6fc>
    5a44: aa1603e0     	mov	x0, x22
    5a48: 94000000     	bl	0x5a48 <___pl_fn_15+0x138>
    5a4c: aa1603e1     	mov	x1, x22
    5a50: b9402c21     	ldr	w1, [x1, #0x2c]
    5a54: 35002ce1     	cbnz	w1, 0x5ff0 <___pl_fn_15+0x6e0>
    5a58: aa1603e1     	mov	x1, x22
    5a5c: b9001834     	str	w20, [x1, #0x18]
    5a60: 34002b00     	cbz	w0, 0x5fc0 <___pl_fn_15+0x6b0>
    5a64: aa0003fb     	mov	x27, x0
    5a68: 34001b73     	cbz	w19, 0x5dd4 <___pl_fn_15+0x4c4>
    5a6c: aa1603e0     	mov	x0, x22
    5a70: f9400003     	ldr	x3, [x0]
    5a74: 2a1303e2     	mov	w2, w19
    5a78: 8b020c62     	add	x2, x3, x2, lsl #3
    5a7c: f8735863     	ldr	x3, [x3, w19, uxtw #3]
    5a80: d360fc63     	lsr	x3, x3, #32
    5a84: 92403c63     	and	x3, x3, #0xffff
    5a88: 91001c63     	add	x3, x3, #0x7
    5a8c: d37df063     	lsl	x3, x3, #3
    5a90: b8636842     	ldr	w2, [x2, x3]
    5a94: 35000082     	cbnz	w2, 0x5aa4 <___pl_fn_15+0x194>
    5a98: 140000cf     	b	0x5dd4 <___pl_fn_15+0x4c4>
    5a9c: aa1603e0     	mov	x0, x22
    5aa0: f9401802     	ldr	x2, [x0, #0x30]
    5aa4: 34001aa2     	cbz	w2, 0x5df8 <___pl_fn_15+0x4e8>
    5aa8: aa1603e0     	mov	x0, x22
    5aac: f940000b     	ldr	x11, [x0]
    5ab0: 2a0203ea     	mov	w10, w2
    5ab4: 8b0a0d6a     	add	x10, x11, x10, lsl #3
    5ab8: f862596b     	ldr	x11, [x11, w2, uxtw #3]
    5abc: d360fd6b     	lsr	x11, x11, #32
    5ac0: 92403d6b     	and	x11, x11, #0xffff
    5ac4: 9100296c     	add	x12, x11, #0xa
    5ac8: f86c7940     	ldr	x0, [x10, x12, lsl #3]
    5acc: f100097f     	cmp	x11, #0x2
    5ad0: 540000c0     	b.eq	0x5ae8 <___pl_fn_15+0x1d8>
    5ad4: f940094d     	ldr	x13, [x10, #0x10]
    5ad8: 3750190d     	tbnz	w13, #0xa, 0x5df8 <___pl_fn_15+0x4e8>
    5adc: 14000003     	b	0x5ae8 <___pl_fn_15+0x1d8>
    5ae0: aa1603e0     	mov	x0, x22
    5ae4: f9401800     	ldr	x0, [x0, #0x30]
    5ae8: d2800034     	mov	x20, #0x1               ; =1
    5aec: ab140015     	adds	x21, x0, x20
    5af0: 9a9f77e0     	cset	x0, vs
    5af4: 72001c1f     	tst	w0, #0xff
    5af8: 540024c1     	b.ne	0x5f90 <___pl_fn_15+0x680>
    5afc: 340018f3     	cbz	w19, 0x5e18 <___pl_fn_15+0x508>
    5b00: aa1603e0     	mov	x0, x22
    5b04: f9400001     	ldr	x1, [x0]
    5b08: 2a1303e0     	mov	w0, w19
    5b0c: 8b000c20     	add	x0, x1, x0, lsl #3
    5b10: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    5b14: d360fc21     	lsr	x1, x1, #32
    5b18: 92403c21     	and	x1, x1, #0xffff
    5b1c: 91001c21     	add	x1, x1, #0x7
    5b20: d37df021     	lsl	x1, x1, #3
    5b24: b8616802     	ldr	w2, [x0, x1]
    5b28: 35000082     	cbnz	w2, 0x5b38 <___pl_fn_15+0x228>
    5b2c: 140000bb     	b	0x5e18 <___pl_fn_15+0x508>
    5b30: aa1603e0     	mov	x0, x22
    5b34: f9401802     	ldr	x2, [x0, #0x30]
    5b38: 34001822     	cbz	w2, 0x5e3c <___pl_fn_15+0x52c>
    5b3c: aa1603e0     	mov	x0, x22
    5b40: f9400001     	ldr	x1, [x0]
    5b44: 2a0203e0     	mov	w0, w2
    5b48: 8b000c20     	add	x0, x1, x0, lsl #3
    5b4c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    5b50: d360fc21     	lsr	x1, x1, #32
    5b54: 92403c22     	and	x2, x1, #0xffff
    5b58: f100085f     	cmp	x2, #0x2
    5b5c: 54000080     	b.eq	0x5b6c <___pl_fn_15+0x25c>
    5b60: f9400802     	ldr	x2, [x0, #0x10]
    5b64: 9275f842     	and	x2, x2, #0xfffffffffffffbff
    5b68: f9000802     	str	x2, [x0, #0x10]
    5b6c: 92403c21     	and	x1, x1, #0xffff
    5b70: 91002821     	add	x1, x1, #0xa
    5b74: f8217815     	str	x21, [x0, x1, lsl #3]
    5b78: 34001793     	cbz	w19, 0x5e68 <___pl_fn_15+0x558>
    5b7c: aa1603e0     	mov	x0, x22
    5b80: f9400001     	ldr	x1, [x0]
    5b84: 2a1303e0     	mov	w0, w19
    5b88: 8b000c20     	add	x0, x1, x0, lsl #3
    5b8c: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    5b90: d360fc21     	lsr	x1, x1, #32
    5b94: 92403c21     	and	x1, x1, #0xffff
    5b98: 91001c21     	add	x1, x1, #0x7
    5b9c: d37df021     	lsl	x1, x1, #3
    5ba0: b8616802     	ldr	w2, [x0, x1]
    5ba4: 35000082     	cbnz	w2, 0x5bb4 <___pl_fn_15+0x2a4>
    5ba8: 140000b0     	b	0x5e68 <___pl_fn_15+0x558>
    5bac: aa1603e0     	mov	x0, x22
    5bb0: f9401802     	ldr	x2, [x0, #0x30]
    5bb4: 340016c2     	cbz	w2, 0x5e8c <___pl_fn_15+0x57c>
    5bb8: aa1603e0     	mov	x0, x22
    5bbc: f9400001     	ldr	x1, [x0]
    5bc0: 2a0203e0     	mov	w0, w2
    5bc4: 8b000c20     	add	x0, x1, x0, lsl #3
    5bc8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    5bcc: d360fc21     	lsr	x1, x1, #32
    5bd0: 92403c21     	and	x1, x1, #0xffff
    5bd4: 91000821     	add	x1, x1, #0x2
    5bd8: d37df021     	lsl	x1, x1, #3
    5bdc: b8616800     	ldr	w0, [x0, x1]
    5be0: 350000c0     	cbnz	w0, 0x5bf8 <___pl_fn_15+0x2e8>
    5be4: 140000aa     	b	0x5e8c <___pl_fn_15+0x57c>
    5be8: aa1603e0     	mov	x0, x22
    5bec: f9401800     	ldr	x0, [x0, #0x30]
    5bf0: aa1703e2     	mov	x2, x23
    5bf4: 14000002     	b	0x5bfc <___pl_fn_15+0x2ec>
    5bf8: aa1703e2     	mov	x2, x23
    5bfc: aa1703e2     	mov	x2, x23
    5c00: 34001562     	cbz	w2, 0x5eac <___pl_fn_15+0x59c>
    5c04: aa1603e1     	mov	x1, x22
    5c08: f9400023     	ldr	x3, [x1]
    5c0c: aa1703e2     	mov	x2, x23
    5c10: 2a0203e2     	mov	w2, w2
    5c14: 8b020c62     	add	x2, x3, x2, lsl #3
    5c18: aa1703e6     	mov	x6, x23
    5c1c: f8665864     	ldr	x4, [x3, w6, uxtw #3]
    5c20: 2a0003e3     	mov	w3, w0
    5c24: d360fc84     	lsr	x4, x4, #32
    5c28: 92403c84     	and	x4, x4, #0xffff
    5c2c: f8247843     	str	x3, [x2, x4, lsl #3]
    5c30: 34001593     	cbz	w19, 0x5ee0 <___pl_fn_15+0x5d0>
    5c34: aa1603e0     	mov	x0, x22
    5c38: f9400007     	ldr	x7, [x0]
    5c3c: 2a1303e6     	mov	w6, w19
    5c40: 8b060ce6     	add	x6, x7, x6, lsl #3
    5c44: f87358e7     	ldr	x7, [x7, w19, uxtw #3]
    5c48: d360fce7     	lsr	x7, x7, #32
    5c4c: 92403ce7     	and	x7, x7, #0xffff
    5c50: 910004e8     	add	x8, x7, #0x1
    5c54: f86878cb     	ldr	x11, [x6, x8, lsl #3]
    5c58: f10008ff     	cmp	x7, #0x2
    5c5c: 54000100     	b.eq	0x5c7c <___pl_fn_15+0x36c>
    5c60: f94008c9     	ldr	x9, [x6, #0x10]
    5c64: 370813e9     	tbnz	w9, #0x1, 0x5ee0 <___pl_fn_15+0x5d0>
    5c68: 14000005     	b	0x5c7c <___pl_fn_15+0x36c>
    5c6c: aa1603e0     	mov	x0, x22
    5c70: f940180b     	ldr	x11, [x0, #0x30]
    5c74: aa1703e2     	mov	x2, x23
    5c78: 14000002     	b	0x5c80 <___pl_fn_15+0x370>
    5c7c: aa1703e2     	mov	x2, x23
    5c80: aa1703e2     	mov	x2, x23
    5c84: 35000082     	cbnz	w2, 0x5c94 <___pl_fn_15+0x384>
    5c88: 1400009f     	b	0x5f04 <___pl_fn_15+0x5f4>
    5c8c: aa1603e0     	mov	x0, x22
    5c90: 14000012     	b	0x5cd8 <___pl_fn_15+0x3c8>
    5c94: aa1603e0     	mov	x0, x22
    5c98: f9400001     	ldr	x1, [x0]
    5c9c: aa1703e2     	mov	x2, x23
    5ca0: 2a0203e0     	mov	w0, w2
    5ca4: 8b000c20     	add	x0, x1, x0, lsl #3
    5ca8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    5cac: d360fc21     	lsr	x1, x1, #32
    5cb0: 92403c22     	and	x2, x1, #0xffff
    5cb4: f100085f     	cmp	x2, #0x2
    5cb8: 54000080     	b.eq	0x5cc8 <___pl_fn_15+0x3b8>
    5cbc: f9400802     	ldr	x2, [x0, #0x10]
    5cc0: 927ef842     	and	x2, x2, #0xfffffffffffffffd
    5cc4: f9000802     	str	x2, [x0, #0x10]
    5cc8: 92403c21     	and	x1, x1, #0xffff
    5ccc: 91000421     	add	x1, x1, #0x1
    5cd0: f821780b     	str	x11, [x0, x1, lsl #3]
    5cd4: aa1603e0     	mov	x0, x22
    5cd8: aa1603e0     	mov	x0, x22
    5cdc: b9401814     	ldr	w20, [x0, #0x18]
    5ce0: b9401c01     	ldr	w1, [x0, #0x1c]
    5ce4: 11000e80     	add	w0, w20, #0x3
    5ce8: 6b01001f     	cmp	w0, w1
    5cec: 540013a8     	b.hi	0x5f60 <___pl_fn_15+0x650>
    5cf0: aa1603e1     	mov	x1, x22
    5cf4: f9401021     	ldr	x1, [x1, #0x20]
    5cf8: 2a1403e2     	mov	w2, w20
    5cfc: 8b020822     	add	x2, x1, x2, lsl #2
    5d00: b8345833     	str	w19, [x1, w20, uxtw #2]
    5d04: aa1703ef     	mov	x15, x23
    5d08: b900044f     	str	w15, [x2, #0x4]
    5d0c: aa1b03e1     	mov	x1, x27
    5d10: b9000841     	str	w1, [x2, #0x8]
    5d14: aa1603e1     	mov	x1, x22
    5d18: b9001820     	str	w0, [x1, #0x18]
    5d1c: aa1603e0     	mov	x0, x22
    5d20: b9401000     	ldr	w0, [x0, #0x10]
    5d24: b9401421     	ldr	w1, [x1, #0x14]
    5d28: 6b01001f     	cmp	w0, w1
    5d2c: 54001022     	b.hs	0x5f30 <___pl_fn_15+0x620>
    5d30: aa1b03e1     	mov	x1, x27
    5d34: aa1703e2     	mov	x2, x23
    5d38: aa1303e3     	mov	x3, x19
    5d3c: aa1603e0     	mov	x0, x22
    5d40: 94000000     	bl	0x5d40 <___pl_fn_15+0x430>
    5d44: aa1603e4     	mov	x4, x22
    5d48: b9402c81     	ldr	w1, [x4, #0x2c]
    5d4c: 35001521     	cbnz	w1, 0x5ff0 <___pl_fn_15+0x6e0>
    5d50: aa1603e8     	mov	x8, x22
    5d54: b9001914     	str	w20, [x8, #0x18]
    5d58: aa1603ea     	mov	x10, x22
    5d5c: b9401141     	ldr	w1, [x10, #0x10]
    5d60: 51000421     	sub	w1, w1, #0x1
    5d64: aa1603ed     	mov	x13, x22
    5d68: b90011a1     	str	w1, [x13, #0x10]
    5d6c: 9100c3ff     	add	sp, sp, #0x30
    5d70: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5d74: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5d78: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    5d7c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5d80: d65f03c0     	ret
    5d84: aa0003f6     	mov	x22, x0
    5d88: 52801b21     	mov	w1, #0xd9               ; =217
    5d8c: 528000e3     	mov	w3, #0x7                ; =7
    5d90: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5d94: f9400084     	ldr	x4, [x4]
    5d98: aa1603e0     	mov	x0, x22
    5d9c: aa1303e2     	mov	x2, x19
    5da0: d63f0080     	blr	x4
    5da4: 34ffdec0     	cbz	w0, 0x597c <___pl_fn_15+0x6c>
    5da8: 14000092     	b	0x5ff0 <___pl_fn_15+0x6e0>
    5dac: aa0203f7     	mov	x23, x2
    5db0: 52801b41     	mov	w1, #0xda               ; =218
    5db4: 52800023     	mov	w3, #0x1                ; =1
    5db8: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5dbc: f9400084     	ldr	x4, [x4]
    5dc0: aa1603e0     	mov	x0, x22
    5dc4: aa1703e2     	mov	x2, x23
    5dc8: d63f0080     	blr	x4
    5dcc: 34ffe060     	cbz	w0, 0x59d8 <___pl_fn_15+0xc8>
    5dd0: 14000088     	b	0x5ff0 <___pl_fn_15+0x6e0>
    5dd4: 52801bc1     	mov	w1, #0xde               ; =222
    5dd8: 528000e3     	mov	w3, #0x7                ; =7
    5ddc: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5de0: f9400084     	ldr	x4, [x4]
    5de4: aa1603e0     	mov	x0, x22
    5de8: aa1303e2     	mov	x2, x19
    5dec: d63f0080     	blr	x4
    5df0: 34ffe560     	cbz	w0, 0x5a9c <___pl_fn_15+0x18c>
    5df4: 1400007f     	b	0x5ff0 <___pl_fn_15+0x6e0>
    5df8: 52801be1     	mov	w1, #0xdf               ; =223
    5dfc: 52800143     	mov	w3, #0xa                ; =10
    5e00: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5e04: f9400084     	ldr	x4, [x4]
    5e08: aa1603e0     	mov	x0, x22
    5e0c: d63f0080     	blr	x4
    5e10: 34ffe680     	cbz	w0, 0x5ae0 <___pl_fn_15+0x1d0>
    5e14: 14000077     	b	0x5ff0 <___pl_fn_15+0x6e0>
    5e18: 52801c21     	mov	w1, #0xe1               ; =225
    5e1c: 528000e3     	mov	w3, #0x7                ; =7
    5e20: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5e24: f9400084     	ldr	x4, [x4]
    5e28: aa1603e0     	mov	x0, x22
    5e2c: aa1303e2     	mov	x2, x19
    5e30: d63f0080     	blr	x4
    5e34: 34ffe7e0     	cbz	w0, 0x5b30 <___pl_fn_15+0x220>
    5e38: 1400006e     	b	0x5ff0 <___pl_fn_15+0x6e0>
    5e3c: d2800140     	mov	x0, #0xa                ; =10
    5e40: 910003e3     	mov	x3, sp
    5e44: f80003e0     	stur	x0, [sp]
    5e48: f80083f5     	stur	x21, [sp, #0x8]
    5e4c: 52801c41     	mov	w1, #0xe2               ; =226
    5e50: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5e54: f9400084     	ldr	x4, [x4]
    5e58: aa1603e0     	mov	x0, x22
    5e5c: d63f0080     	blr	x4
    5e60: 34ffe8c0     	cbz	w0, 0x5b78 <___pl_fn_15+0x268>
    5e64: 14000063     	b	0x5ff0 <___pl_fn_15+0x6e0>
    5e68: 52801c61     	mov	w1, #0xe3               ; =227
    5e6c: 528000e3     	mov	w3, #0x7                ; =7
    5e70: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5e74: f9400084     	ldr	x4, [x4]
    5e78: aa1603e0     	mov	x0, x22
    5e7c: aa1303e2     	mov	x2, x19
    5e80: d63f0080     	blr	x4
    5e84: 34ffe940     	cbz	w0, 0x5bac <___pl_fn_15+0x29c>
    5e88: 1400005a     	b	0x5ff0 <___pl_fn_15+0x6e0>
    5e8c: 52801c81     	mov	w1, #0xe4               ; =228
    5e90: 52800043     	mov	w3, #0x2                ; =2
    5e94: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5e98: f9400084     	ldr	x4, [x4]
    5e9c: aa1603e0     	mov	x0, x22
    5ea0: d63f0080     	blr	x4
    5ea4: 34ffea20     	cbz	w0, 0x5be8 <___pl_fn_15+0x2d8>
    5ea8: 14000052     	b	0x5ff0 <___pl_fn_15+0x6e0>
    5eac: d2800001     	mov	x1, #0x0                ; =0
    5eb0: 910043e3     	add	x3, sp, #0x10
    5eb4: f80103e1     	stur	x1, [sp, #0x10]
    5eb8: 2a0003e0     	mov	w0, w0
    5ebc: f80183e0     	stur	x0, [sp, #0x18]
    5ec0: 52801ca1     	mov	w1, #0xe5               ; =229
    5ec4: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5ec8: f9400084     	ldr	x4, [x4]
    5ecc: aa1603e0     	mov	x0, x22
    5ed0: aa1703e2     	mov	x2, x23
    5ed4: d63f0080     	blr	x4
    5ed8: 34ffeac0     	cbz	w0, 0x5c30 <___pl_fn_15+0x320>
    5edc: 14000045     	b	0x5ff0 <___pl_fn_15+0x6e0>
    5ee0: 52801cc1     	mov	w1, #0xe6               ; =230
    5ee4: 52800023     	mov	w3, #0x1                ; =1
    5ee8: 9000000c     	adrp	x12, 0x5000 <___pl_fn_11+0x8fc>
    5eec: f940018c     	ldr	x12, [x12]
    5ef0: aa1603e0     	mov	x0, x22
    5ef4: aa1303e2     	mov	x2, x19
    5ef8: d63f0180     	blr	x12
    5efc: 34ffeb80     	cbz	w0, 0x5c6c <___pl_fn_15+0x35c>
    5f00: 1400003c     	b	0x5ff0 <___pl_fn_15+0x6e0>
    5f04: 910083e3     	add	x3, sp, #0x20
    5f08: f80203f4     	stur	x20, [sp, #0x20]
    5f0c: f80283eb     	stur	x11, [sp, #0x28]
    5f10: 52801ce1     	mov	w1, #0xe7               ; =231
    5f14: 90000004     	adrp	x4, 0x5000 <___pl_fn_11+0x8fc>
    5f18: f9400084     	ldr	x4, [x4]
    5f1c: aa1603e0     	mov	x0, x22
    5f20: aa1703e2     	mov	x2, x23
    5f24: d63f0080     	blr	x4
    5f28: 34ffeb20     	cbz	w0, 0x5c8c <___pl_fn_15+0x37c>
    5f2c: 14000031     	b	0x5ff0 <___pl_fn_15+0x6e0>
    5f30: 52801d21     	mov	w1, #0xe9               ; =233
    5f34: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    5f38: f9400042     	ldr	x2, [x2]
    5f3c: aa1603e0     	mov	x0, x22
    5f40: d63f0040     	blr	x2
    5f44: 52800000     	mov	w0, #0x0                ; =0
    5f48: 9100c3ff     	add	sp, sp, #0x30
    5f4c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5f50: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5f54: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    5f58: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5f5c: d65f03c0     	ret
    5f60: 52801d01     	mov	w1, #0xe8               ; =232
    5f64: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    5f68: f9400042     	ldr	x2, [x2]
    5f6c: aa1603e0     	mov	x0, x22
    5f70: d63f0040     	blr	x2
    5f74: 52800000     	mov	w0, #0x0                ; =0
    5f78: 9100c3ff     	add	sp, sp, #0x30
    5f7c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5f80: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5f84: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    5f88: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5f8c: d65f03c0     	ret
    5f90: 52801c01     	mov	w1, #0xe0               ; =224
    5f94: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    5f98: f9400042     	ldr	x2, [x2]
    5f9c: aa1603e0     	mov	x0, x22
    5fa0: d63f0040     	blr	x2
    5fa4: 52800000     	mov	w0, #0x0                ; =0
    5fa8: 9100c3ff     	add	sp, sp, #0x30
    5fac: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5fb0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5fb4: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    5fb8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5fbc: d65f03c0     	ret
    5fc0: 52801ba1     	mov	w1, #0xdd               ; =221
    5fc4: 90000002     	adrp	x2, 0x5000 <___pl_fn_11+0x8fc>
    5fc8: f9400042     	ldr	x2, [x2]
    5fcc: aa1603e0     	mov	x0, x22
    5fd0: d63f0040     	blr	x2
    5fd4: 52800000     	mov	w0, #0x0                ; =0
    5fd8: 9100c3ff     	add	sp, sp, #0x30
    5fdc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5fe0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5fe4: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    5fe8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5fec: d65f03c0     	ret
    5ff0: 52800000     	mov	w0, #0x0                ; =0
    5ff4: 9100c3ff     	add	sp, sp, #0x30
    5ff8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5ffc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6000: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    6004: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6008: d65f03c0     	ret
    600c: 52801b81     	mov	w1, #0xdc               ; =220
    6010: 90000002     	adrp	x2, 0x6000 <___pl_fn_15+0x6f0>
    6014: f9400042     	ldr	x2, [x2]
    6018: aa1603e0     	mov	x0, x22
    601c: d63f0040     	blr	x2
    6020: 52800000     	mov	w0, #0x0                ; =0
    6024: 9100c3ff     	add	sp, sp, #0x30
    6028: a8c153f3     	ldp	x19, x20, [sp], #0x10
    602c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6030: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    6034: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6038: d65f03c0     	ret
    603c: 52801b61     	mov	w1, #0xdb               ; =219
    6040: 90000002     	adrp	x2, 0x6000 <___pl_fn_15+0x6f0>
    6044: f9400042     	ldr	x2, [x2]
    6048: aa1603e0     	mov	x0, x22
    604c: d63f0040     	blr	x2
    6050: 52800000     	mov	w0, #0x0                ; =0
    6054: 9100c3ff     	add	sp, sp, #0x30
    6058: a8c153f3     	ldp	x19, x20, [sp], #0x10
    605c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6060: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    6064: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6068: d65f03c0     	ret

000000000000606c <___pl_fn_16>:
    606c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    6070: 910003fd     	mov	x29, sp
    6074: a9bf73f9     	stp	x25, x28, [sp, #-0x10]!
    6078: a9bf5ff5     	stp	x21, x23, [sp, #-0x10]!
    607c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    6080: d10083ff     	sub	sp, sp, #0x20
    6084: aa0103f5     	mov	x21, x1
    6088: aa0203fc     	mov	x28, x2
    608c: b9401007     	ldr	w7, [x0, #0x10]
    6090: 110004e7     	add	w7, w7, #0x1
    6094: b9001007     	str	w7, [x0, #0x10]
    6098: aa1503e1     	mov	x1, x21
    609c: 340022e1     	cbz	w1, 0x64f8 <___pl_fn_16+0x48c>
    60a0: f940000c     	ldr	x12, [x0]
    60a4: aa1503e1     	mov	x1, x21
    60a8: aa0003f4     	mov	x20, x0
    60ac: 2a0103eb     	mov	w11, w1
    60b0: 8b0b0d8b     	add	x11, x12, x11, lsl #3
    60b4: f861598c     	ldr	x12, [x12, w1, uxtw #3]
    60b8: d360fd8c     	lsr	x12, x12, #32
    60bc: 92403d8c     	and	x12, x12, #0xffff
    60c0: 91001d8c     	add	x12, x12, #0x7
    60c4: d37df18c     	lsl	x12, x12, #3
    60c8: b86c6962     	ldr	w2, [x11, x12]
    60cc: 35000082     	cbnz	w2, 0x60dc <___pl_fn_16+0x70>
    60d0: 1400010b     	b	0x64fc <___pl_fn_16+0x490>
    60d4: aa1403e0     	mov	x0, x20
    60d8: f9401802     	ldr	x2, [x0, #0x30]
    60dc: 34002222     	cbz	w2, 0x6520 <___pl_fn_16+0x4b4>
    60e0: aa1403e0     	mov	x0, x20
    60e4: f9400001     	ldr	x1, [x0]
    60e8: 2a0203e0     	mov	w0, w2
    60ec: 8b000c20     	add	x0, x1, x0, lsl #3
    60f0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    60f4: d360fc21     	lsr	x1, x1, #32
    60f8: 92403c21     	and	x1, x1, #0xffff
    60fc: 91000821     	add	x1, x1, #0x2
    6100: d37df021     	lsl	x1, x1, #3
    6104: b8616800     	ldr	w0, [x0, x1]
    6108: 350000c0     	cbnz	w0, 0x6120 <___pl_fn_16+0xb4>
    610c: 14000105     	b	0x6520 <___pl_fn_16+0x4b4>
    6110: aa1403e0     	mov	x0, x20
    6114: f9401800     	ldr	x0, [x0, #0x30]
    6118: aa1c03e2     	mov	x2, x28
    611c: 14000002     	b	0x6124 <___pl_fn_16+0xb8>
    6120: aa1c03e2     	mov	x2, x28
    6124: 6b00005f     	cmp	w2, w0
    6128: 540006e0     	b.eq	0x6204 <___pl_fn_16+0x198>
    612c: aa1503f3     	mov	x19, x21
    6130: 35000093     	cbnz	w19, 0x6140 <___pl_fn_16+0xd4>
    6134: 14000103     	b	0x6540 <___pl_fn_16+0x4d4>
    6138: aa1403e0     	mov	x0, x20
    613c: 1400000f     	b	0x6178 <___pl_fn_16+0x10c>
    6140: aa1403e0     	mov	x0, x20
    6144: aa1303f5     	mov	x21, x19
    6148: f9400001     	ldr	x1, [x0]
    614c: aa1503e4     	mov	x4, x21
    6150: 2a0403e0     	mov	w0, w4
    6154: 8b000c20     	add	x0, x1, x0, lsl #3
    6158: aa1503e7     	mov	x7, x21
    615c: f8675823     	ldr	x3, [x1, w7, uxtw #3]
    6160: 2a0203e1     	mov	w1, w2
    6164: d360fc62     	lsr	x2, x3, #32
    6168: 92403c42     	and	x2, x2, #0xffff
    616c: 91002042     	add	x2, x2, #0x8
    6170: f8227801     	str	x1, [x0, x2, lsl #3]
    6174: aa1403e0     	mov	x0, x20
    6178: aa1403e0     	mov	x0, x20
    617c: b9401813     	ldr	w19, [x0, #0x18]
    6180: b9401c01     	ldr	w1, [x0, #0x1c]
    6184: 11000660     	add	w0, w19, #0x1
    6188: 6b01001f     	cmp	w0, w1
    618c: 540020e8     	b.hi	0x65a8 <___pl_fn_16+0x53c>
    6190: aa1403e1     	mov	x1, x20
    6194: f9401021     	ldr	x1, [x1, #0x20]
    6198: aa1503e2     	mov	x2, x21
    619c: b8335822     	str	w2, [x1, w19, uxtw #2]
    61a0: aa1403e1     	mov	x1, x20
    61a4: b9001820     	str	w0, [x1, #0x18]
    61a8: aa1403e0     	mov	x0, x20
    61ac: b9401000     	ldr	w0, [x0, #0x10]
    61b0: b9401421     	ldr	w1, [x1, #0x14]
    61b4: 6b01001f     	cmp	w0, w1
    61b8: 54001e02     	b.hs	0x6578 <___pl_fn_16+0x50c>
    61bc: aa1503e1     	mov	x1, x21
    61c0: aa1403e0     	mov	x0, x20
    61c4: 94000000     	bl	0x61c4 <___pl_fn_16+0x158>
    61c8: aa1403e1     	mov	x1, x20
    61cc: b9402c21     	ldr	w1, [x1, #0x2c]
    61d0: 35002a41     	cbnz	w1, 0x6718 <___pl_fn_16+0x6ac>
    61d4: aa1403e1     	mov	x1, x20
    61d8: b9001833     	str	w19, [x1, #0x18]
    61dc: b9401021     	ldr	w1, [x1, #0x10]
    61e0: 51000421     	sub	w1, w1, #0x1
    61e4: aa1403e2     	mov	x2, x20
    61e8: b9001041     	str	w1, [x2, #0x10]
    61ec: 910083ff     	add	sp, sp, #0x20
    61f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    61f4: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    61f8: a8c173f9     	ldp	x25, x28, [sp], #0x10
    61fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6200: d65f03c0     	ret
    6204: aa1503e1     	mov	x1, x21
    6208: 34001e81     	cbz	w1, 0x65d8 <___pl_fn_16+0x56c>
    620c: aa1403e0     	mov	x0, x20
    6210: f9400001     	ldr	x1, [x0]
    6214: aa1503e0     	mov	x0, x21
    6218: 2a0003e0     	mov	w0, w0
    621c: 8b000c20     	add	x0, x1, x0, lsl #3
    6220: aa1503e2     	mov	x2, x21
    6224: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6228: d360fc21     	lsr	x1, x1, #32
    622c: 92403c21     	and	x1, x1, #0xffff
    6230: 91002021     	add	x1, x1, #0x8
    6234: d37df021     	lsl	x1, x1, #3
    6238: b8616802     	ldr	w2, [x0, x1]
    623c: 35000082     	cbnz	w2, 0x624c <___pl_fn_16+0x1e0>
    6240: 140000e6     	b	0x65d8 <___pl_fn_16+0x56c>
    6244: aa1403e0     	mov	x0, x20
    6248: f9401802     	ldr	x2, [x0, #0x30]
    624c: 52800000     	mov	w0, #0x0                ; =0
    6250: aa0003f7     	mov	x23, x0
    6254: 34002a02     	cbz	w2, 0x6794 <___pl_fn_16+0x728>
    6258: aa1503e1     	mov	x1, x21
    625c: aa0203f9     	mov	x25, x2
    6260: 34001ce1     	cbz	w1, 0x65fc <___pl_fn_16+0x590>
    6264: aa1403e0     	mov	x0, x20
    6268: f9400001     	ldr	x1, [x0]
    626c: aa1503e0     	mov	x0, x21
    6270: 2a0003e0     	mov	w0, w0
    6274: 8b000c20     	add	x0, x1, x0, lsl #3
    6278: aa1503e2     	mov	x2, x21
    627c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6280: d360fc21     	lsr	x1, x1, #32
    6284: 92403c21     	and	x1, x1, #0xffff
    6288: 91001c21     	add	x1, x1, #0x7
    628c: d37df021     	lsl	x1, x1, #3
    6290: b8616802     	ldr	w2, [x0, x1]
    6294: 35000082     	cbnz	w2, 0x62a4 <___pl_fn_16+0x238>
    6298: 140000d9     	b	0x65fc <___pl_fn_16+0x590>
    629c: aa1403e0     	mov	x0, x20
    62a0: f9401802     	ldr	x2, [x0, #0x30]
    62a4: 34001be2     	cbz	w2, 0x6620 <___pl_fn_16+0x5b4>
    62a8: aa1403e0     	mov	x0, x20
    62ac: f9400006     	ldr	x6, [x0]
    62b0: 2a0203e5     	mov	w5, w2
    62b4: 8b050cc5     	add	x5, x6, x5, lsl #3
    62b8: f86258c6     	ldr	x6, [x6, w2, uxtw #3]
    62bc: d360fcc6     	lsr	x6, x6, #32
    62c0: 92403cc6     	and	x6, x6, #0xffff
    62c4: 910008c6     	add	x6, x6, #0x2
    62c8: d37df0c6     	lsl	x6, x6, #3
    62cc: b86668a0     	ldr	w0, [x5, x6]
    62d0: 350000c0     	cbnz	w0, 0x62e8 <___pl_fn_16+0x27c>
    62d4: 140000d3     	b	0x6620 <___pl_fn_16+0x5b4>
    62d8: aa1403e0     	mov	x0, x20
    62dc: f9401800     	ldr	x0, [x0, #0x30]
    62e0: aa1903e2     	mov	x2, x25
    62e4: 14000002     	b	0x62ec <___pl_fn_16+0x280>
    62e8: aa1903e2     	mov	x2, x25
    62ec: 6b00005f     	cmp	w2, w0
    62f0: aa0203f9     	mov	x25, x2
    62f4: 54000be0     	b.eq	0x6470 <___pl_fn_16+0x404>
    62f8: aa1503e1     	mov	x1, x21
    62fc: 34001a21     	cbz	w1, 0x6640 <___pl_fn_16+0x5d4>
    6300: aa1403e0     	mov	x0, x20
    6304: f9400001     	ldr	x1, [x0]
    6308: aa1503e3     	mov	x3, x21
    630c: 2a0303e0     	mov	w0, w3
    6310: 8b000c20     	add	x0, x1, x0, lsl #3
    6314: aa1503e6     	mov	x6, x21
    6318: f8665821     	ldr	x1, [x1, w6, uxtw #3]
    631c: d360fc21     	lsr	x1, x1, #32
    6320: 92403c21     	and	x1, x1, #0xffff
    6324: 91001c21     	add	x1, x1, #0x7
    6328: d37df021     	lsl	x1, x1, #3
    632c: b8616802     	ldr	w2, [x0, x1]
    6330: 35000082     	cbnz	w2, 0x6340 <___pl_fn_16+0x2d4>
    6334: 140000c3     	b	0x6640 <___pl_fn_16+0x5d4>
    6338: aa1403e0     	mov	x0, x20
    633c: f9401802     	ldr	x2, [x0, #0x30]
    6340: 34001922     	cbz	w2, 0x6664 <___pl_fn_16+0x5f8>
    6344: aa1403e0     	mov	x0, x20
    6348: f9400001     	ldr	x1, [x0]
    634c: 2a0203e0     	mov	w0, w2
    6350: 8b000c20     	add	x0, x1, x0, lsl #3
    6354: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6358: d360fc21     	lsr	x1, x1, #32
    635c: 92403c21     	and	x1, x1, #0xffff
    6360: 91000821     	add	x1, x1, #0x2
    6364: d37df021     	lsl	x1, x1, #3
    6368: b8616800     	ldr	w0, [x0, x1]
    636c: 350000c0     	cbnz	w0, 0x6384 <___pl_fn_16+0x318>
    6370: 140000bd     	b	0x6664 <___pl_fn_16+0x5f8>
    6374: aa1403e0     	mov	x0, x20
    6378: f9401800     	ldr	x0, [x0, #0x30]
    637c: aa1503e1     	mov	x1, x21
    6380: 14000002     	b	0x6388 <___pl_fn_16+0x31c>
    6384: aa1503e1     	mov	x1, x21
    6388: aa1503e1     	mov	x1, x21
    638c: 35000081     	cbnz	w1, 0x639c <___pl_fn_16+0x330>
    6390: 140000bd     	b	0x6684 <___pl_fn_16+0x618>
    6394: aa1403e0     	mov	x0, x20
    6398: 1400000e     	b	0x63d0 <___pl_fn_16+0x364>
    639c: aa1403e1     	mov	x1, x20
    63a0: f9400022     	ldr	x2, [x1]
    63a4: aa1503e1     	mov	x1, x21
    63a8: 2a0103e1     	mov	w1, w1
    63ac: 8b010c41     	add	x1, x2, x1, lsl #3
    63b0: aa1503e3     	mov	x3, x21
    63b4: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    63b8: 2a0003e0     	mov	w0, w0
    63bc: d360fc42     	lsr	x2, x2, #32
    63c0: 92403c42     	and	x2, x2, #0xffff
    63c4: 91002042     	add	x2, x2, #0x8
    63c8: f8227820     	str	x0, [x1, x2, lsl #3]
    63cc: aa1403e0     	mov	x0, x20
    63d0: aa1403e0     	mov	x0, x20
    63d4: b9401813     	ldr	w19, [x0, #0x18]
    63d8: b9401c00     	ldr	w0, [x0, #0x1c]
    63dc: 11000a61     	add	w1, w19, #0x2
    63e0: 6b00003f     	cmp	w1, w0
    63e4: 54001828     	b.hi	0x66e8 <___pl_fn_16+0x67c>
    63e8: aa1403e0     	mov	x0, x20
    63ec: f9401000     	ldr	x0, [x0, #0x20]
    63f0: 2a1303e1     	mov	w1, w19
    63f4: 8b010801     	add	x1, x0, x1, lsl #2
    63f8: aa1503e2     	mov	x2, x21
    63fc: b8335802     	str	w2, [x0, w19, uxtw #2]
    6400: aa1903e2     	mov	x2, x25
    6404: b9000422     	str	w2, [x1, #0x4]
    6408: 11000a60     	add	w0, w19, #0x2
    640c: aa1403e1     	mov	x1, x20
    6410: b9001820     	str	w0, [x1, #0x18]
    6414: aa1403e0     	mov	x0, x20
    6418: b9401000     	ldr	w0, [x0, #0x10]
    641c: b9401421     	ldr	w1, [x1, #0x14]
    6420: 6b01001f     	cmp	w0, w1
    6424: 540014a2     	b.hs	0x66b8 <___pl_fn_16+0x64c>
    6428: aa1503e1     	mov	x1, x21
    642c: aa1403e0     	mov	x0, x20
    6430: 94000000     	bl	0x6430 <___pl_fn_16+0x3c4>
    6434: aa1403e1     	mov	x1, x20
    6438: b9402c21     	ldr	w1, [x1, #0x2c]
    643c: 350016e1     	cbnz	w1, 0x6718 <___pl_fn_16+0x6ac>
    6440: aa1403e1     	mov	x1, x20
    6444: b9001833     	str	w19, [x1, #0x18]
    6448: b9401021     	ldr	w1, [x1, #0x10]
    644c: 51000421     	sub	w1, w1, #0x1
    6450: aa1403e2     	mov	x2, x20
    6454: b9001041     	str	w1, [x2, #0x10]
    6458: 910083ff     	add	sp, sp, #0x20
    645c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6460: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    6464: a8c173f9     	ldp	x25, x28, [sp], #0x10
    6468: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    646c: d65f03c0     	ret
    6470: aa1403e0     	mov	x0, x20
    6474: b9401813     	ldr	w19, [x0, #0x18]
    6478: b9401c02     	ldr	w2, [x0, #0x1c]
    647c: 11000661     	add	w1, w19, #0x1
    6480: 6b02003f     	cmp	w1, w2
    6484: 54001708     	b.hi	0x6764 <___pl_fn_16+0x6f8>
    6488: aa1403e0     	mov	x0, x20
    648c: f9401002     	ldr	x2, [x0, #0x20]
    6490: aa1503e0     	mov	x0, x21
    6494: b8335840     	str	w0, [x2, w19, uxtw #2]
    6498: aa1403e0     	mov	x0, x20
    649c: b9001801     	str	w1, [x0, #0x18]
    64a0: b9401001     	ldr	w1, [x0, #0x10]
    64a4: b9401402     	ldr	w2, [x0, #0x14]
    64a8: 6b02003f     	cmp	w1, w2
    64ac: 54001442     	b.hs	0x6734 <___pl_fn_16+0x6c8>
    64b0: aa1503e1     	mov	x1, x21
    64b4: aa1403e0     	mov	x0, x20
    64b8: 94000000     	bl	0x64b8 <___pl_fn_16+0x44c>
    64bc: aa1403e1     	mov	x1, x20
    64c0: b9402c21     	ldr	w1, [x1, #0x2c]
    64c4: 350012a1     	cbnz	w1, 0x6718 <___pl_fn_16+0x6ac>
    64c8: aa1403e1     	mov	x1, x20
    64cc: b9001833     	str	w19, [x1, #0x18]
    64d0: b9401021     	ldr	w1, [x1, #0x10]
    64d4: 51000421     	sub	w1, w1, #0x1
    64d8: aa1403e2     	mov	x2, x20
    64dc: b9001041     	str	w1, [x2, #0x10]
    64e0: 910083ff     	add	sp, sp, #0x20
    64e4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    64e8: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    64ec: a8c173f9     	ldp	x25, x28, [sp], #0x10
    64f0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    64f4: d65f03c0     	ret
    64f8: aa0003f4     	mov	x20, x0
    64fc: 52801d41     	mov	w1, #0xea               ; =234
    6500: 528000e3     	mov	w3, #0x7                ; =7
    6504: 9000000d     	adrp	x13, 0x6000 <___pl_fn_15+0x6f0>
    6508: f94001ad     	ldr	x13, [x13]
    650c: aa1403e0     	mov	x0, x20
    6510: aa1503e2     	mov	x2, x21
    6514: d63f01a0     	blr	x13
    6518: 34ffdde0     	cbz	w0, 0x60d4 <___pl_fn_16+0x68>
    651c: 1400007f     	b	0x6718 <___pl_fn_16+0x6ac>
    6520: 52801d61     	mov	w1, #0xeb               ; =235
    6524: 52800043     	mov	w3, #0x2                ; =2
    6528: 90000004     	adrp	x4, 0x6000 <___pl_fn_15+0x6f0>
    652c: f9400084     	ldr	x4, [x4]
    6530: aa1403e0     	mov	x0, x20
    6534: d63f0080     	blr	x4
    6538: 34ffdec0     	cbz	w0, 0x6110 <___pl_fn_16+0xa4>
    653c: 14000077     	b	0x6718 <___pl_fn_16+0x6ac>
    6540: d2800100     	mov	x0, #0x8                ; =8
    6544: 910003e3     	mov	x3, sp
    6548: f80003e0     	stur	x0, [sp]
    654c: 2a0203e0     	mov	w0, w2
    6550: f80083e0     	stur	x0, [sp, #0x8]
    6554: 52801d81     	mov	w1, #0xec               ; =236
    6558: 90000004     	adrp	x4, 0x6000 <___pl_fn_15+0x6f0>
    655c: f9400084     	ldr	x4, [x4]
    6560: aa1403e0     	mov	x0, x20
    6564: aa1303e2     	mov	x2, x19
    6568: d63f0080     	blr	x4
    656c: aa1303f5     	mov	x21, x19
    6570: 34ffde40     	cbz	w0, 0x6138 <___pl_fn_16+0xcc>
    6574: 14000069     	b	0x6718 <___pl_fn_16+0x6ac>
    6578: 52801dc1     	mov	w1, #0xee               ; =238
    657c: 90000002     	adrp	x2, 0x6000 <___pl_fn_15+0x6f0>
    6580: f9400042     	ldr	x2, [x2]
    6584: aa1403e0     	mov	x0, x20
    6588: d63f0040     	blr	x2
    658c: 52800000     	mov	w0, #0x0                ; =0
    6590: 910083ff     	add	sp, sp, #0x20
    6594: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6598: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    659c: a8c173f9     	ldp	x25, x28, [sp], #0x10
    65a0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    65a4: d65f03c0     	ret
    65a8: 52801da1     	mov	w1, #0xed               ; =237
    65ac: 90000002     	adrp	x2, 0x6000 <___pl_fn_15+0x6f0>
    65b0: f9400042     	ldr	x2, [x2]
    65b4: aa1403e0     	mov	x0, x20
    65b8: d63f0040     	blr	x2
    65bc: 52800000     	mov	w0, #0x0                ; =0
    65c0: 910083ff     	add	sp, sp, #0x20
    65c4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    65c8: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    65cc: a8c173f9     	ldp	x25, x28, [sp], #0x10
    65d0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    65d4: d65f03c0     	ret
    65d8: 52801de1     	mov	w1, #0xef               ; =239
    65dc: 52800103     	mov	w3, #0x8                ; =8
    65e0: 90000004     	adrp	x4, 0x6000 <___pl_fn_15+0x6f0>
    65e4: f9400084     	ldr	x4, [x4]
    65e8: aa1403e0     	mov	x0, x20
    65ec: aa1503e2     	mov	x2, x21
    65f0: d63f0080     	blr	x4
    65f4: 34ffe280     	cbz	w0, 0x6244 <___pl_fn_16+0x1d8>
    65f8: 14000048     	b	0x6718 <___pl_fn_16+0x6ac>
    65fc: 52801e21     	mov	w1, #0xf1               ; =241
    6600: 528000e3     	mov	w3, #0x7                ; =7
    6604: 90000004     	adrp	x4, 0x6000 <___pl_fn_15+0x6f0>
    6608: f9400084     	ldr	x4, [x4]
    660c: aa1403e0     	mov	x0, x20
    6610: aa1503e2     	mov	x2, x21
    6614: d63f0080     	blr	x4
    6618: 34ffe420     	cbz	w0, 0x629c <___pl_fn_16+0x230>
    661c: 1400003f     	b	0x6718 <___pl_fn_16+0x6ac>
    6620: 52801e41     	mov	w1, #0xf2               ; =242
    6624: 52800043     	mov	w3, #0x2                ; =2
    6628: 90000007     	adrp	x7, 0x6000 <___pl_fn_15+0x6f0>
    662c: f94000e7     	ldr	x7, [x7]
    6630: aa1403e0     	mov	x0, x20
    6634: d63f00e0     	blr	x7
    6638: 34ffe500     	cbz	w0, 0x62d8 <___pl_fn_16+0x26c>
    663c: 14000037     	b	0x6718 <___pl_fn_16+0x6ac>
    6640: 52801e61     	mov	w1, #0xf3               ; =243
    6644: 528000e3     	mov	w3, #0x7                ; =7
    6648: 90000004     	adrp	x4, 0x6000 <___pl_fn_15+0x6f0>
    664c: f9400084     	ldr	x4, [x4]
    6650: aa1403e0     	mov	x0, x20
    6654: aa1503e2     	mov	x2, x21
    6658: d63f0080     	blr	x4
    665c: 34ffe6e0     	cbz	w0, 0x6338 <___pl_fn_16+0x2cc>
    6660: 1400002e     	b	0x6718 <___pl_fn_16+0x6ac>
    6664: 52801e81     	mov	w1, #0xf4               ; =244
    6668: 52800043     	mov	w3, #0x2                ; =2
    666c: 90000004     	adrp	x4, 0x6000 <___pl_fn_15+0x6f0>
    6670: f9400084     	ldr	x4, [x4]
    6674: aa1403e0     	mov	x0, x20
    6678: d63f0080     	blr	x4
    667c: 34ffe7c0     	cbz	w0, 0x6374 <___pl_fn_16+0x308>
    6680: 14000026     	b	0x6718 <___pl_fn_16+0x6ac>
    6684: d2800101     	mov	x1, #0x8                ; =8
    6688: 910043e3     	add	x3, sp, #0x10
    668c: f80103e1     	stur	x1, [sp, #0x10]
    6690: 2a0003e0     	mov	w0, w0
    6694: f80183e0     	stur	x0, [sp, #0x18]
    6698: 52801ea1     	mov	w1, #0xf5               ; =245
    669c: 90000004     	adrp	x4, 0x6000 <___pl_fn_15+0x6f0>
    66a0: f9400084     	ldr	x4, [x4]
    66a4: aa1403e0     	mov	x0, x20
    66a8: aa1503e2     	mov	x2, x21
    66ac: d63f0080     	blr	x4
    66b0: 34ffe720     	cbz	w0, 0x6394 <___pl_fn_16+0x328>
    66b4: 14000019     	b	0x6718 <___pl_fn_16+0x6ac>
    66b8: 52801ee1     	mov	w1, #0xf7               ; =247
    66bc: 90000002     	adrp	x2, 0x6000 <___pl_fn_15+0x6f0>
    66c0: f9400042     	ldr	x2, [x2]
    66c4: aa1403e0     	mov	x0, x20
    66c8: d63f0040     	blr	x2
    66cc: aa1703e0     	mov	x0, x23
    66d0: 910083ff     	add	sp, sp, #0x20
    66d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    66d8: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    66dc: a8c173f9     	ldp	x25, x28, [sp], #0x10
    66e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    66e4: d65f03c0     	ret
    66e8: 52801ec1     	mov	w1, #0xf6               ; =246
    66ec: 90000002     	adrp	x2, 0x6000 <___pl_fn_15+0x6f0>
    66f0: f9400042     	ldr	x2, [x2]
    66f4: aa1403e0     	mov	x0, x20
    66f8: d63f0040     	blr	x2
    66fc: aa1703e0     	mov	x0, x23
    6700: 910083ff     	add	sp, sp, #0x20
    6704: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6708: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    670c: a8c173f9     	ldp	x25, x28, [sp], #0x10
    6710: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6714: d65f03c0     	ret
    6718: 52800000     	mov	w0, #0x0                ; =0
    671c: 910083ff     	add	sp, sp, #0x20
    6720: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6724: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    6728: a8c173f9     	ldp	x25, x28, [sp], #0x10
    672c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6730: d65f03c0     	ret
    6734: 52801f21     	mov	w1, #0xf9               ; =249
    6738: 90000002     	adrp	x2, 0x6000 <___pl_fn_15+0x6f0>
    673c: f9400042     	ldr	x2, [x2]
    6740: aa1403e0     	mov	x0, x20
    6744: d63f0040     	blr	x2
    6748: aa1703e0     	mov	x0, x23
    674c: 910083ff     	add	sp, sp, #0x20
    6750: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6754: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    6758: a8c173f9     	ldp	x25, x28, [sp], #0x10
    675c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6760: d65f03c0     	ret
    6764: 52801f01     	mov	w1, #0xf8               ; =248
    6768: 90000002     	adrp	x2, 0x6000 <___pl_fn_15+0x6f0>
    676c: f9400042     	ldr	x2, [x2]
    6770: aa1403e0     	mov	x0, x20
    6774: d63f0040     	blr	x2
    6778: aa1703e0     	mov	x0, x23
    677c: 910083ff     	add	sp, sp, #0x20
    6780: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6784: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    6788: a8c173f9     	ldp	x25, x28, [sp], #0x10
    678c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6790: d65f03c0     	ret
    6794: 52801e01     	mov	w1, #0xf0               ; =240
    6798: 90000003     	adrp	x3, 0x6000 <___pl_fn_15+0x6f0>
    679c: f9400063     	ldr	x3, [x3]
    67a0: aa1403e0     	mov	x0, x20
    67a4: d63f0060     	blr	x3
    67a8: aa1703e0     	mov	x0, x23
    67ac: 910083ff     	add	sp, sp, #0x20
    67b0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    67b4: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    67b8: a8c173f9     	ldp	x25, x28, [sp], #0x10
    67bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    67c0: d65f03c0     	ret

00000000000067c4 <___pl_fn_17>:
    67c4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    67c8: 910003fd     	mov	x29, sp
    67cc: f81f0ff9     	str	x25, [sp, #-0x10]!
    67d0: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
    67d4: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    67d8: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    67dc: d10183ff     	sub	sp, sp, #0x60
    67e0: aa0103f6     	mov	x22, x1
    67e4: aa0203f7     	mov	x23, x2
    67e8: b9401001     	ldr	w1, [x0, #0x10]
    67ec: 11000421     	add	w1, w1, #0x1
    67f0: b9001001     	str	w1, [x0, #0x10]
    67f4: aa1603e1     	mov	x1, x22
    67f8: 34005941     	cbz	w1, 0x7320 <___pl_fn_17+0xb5c>
    67fc: f9400001     	ldr	x1, [x0]
    6800: aa0003f5     	mov	x21, x0
    6804: aa1603e0     	mov	x0, x22
    6808: 2a0003e0     	mov	w0, w0
    680c: 8b000c20     	add	x0, x1, x0, lsl #3
    6810: aa1603e2     	mov	x2, x22
    6814: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6818: d360fc21     	lsr	x1, x1, #32
    681c: 92403c21     	and	x1, x1, #0xffff
    6820: 91001c21     	add	x1, x1, #0x7
    6824: d37df021     	lsl	x1, x1, #3
    6828: b8616802     	ldr	w2, [x0, x1]
    682c: 35000082     	cbnz	w2, 0x683c <___pl_fn_17+0x78>
    6830: 140002bd     	b	0x7324 <___pl_fn_17+0xb60>
    6834: aa1503e0     	mov	x0, x21
    6838: f9401802     	ldr	x2, [x0, #0x30]
    683c: 34005862     	cbz	w2, 0x7348 <___pl_fn_17+0xb84>
    6840: aa1503e0     	mov	x0, x21
    6844: f9400005     	ldr	x5, [x0]
    6848: 2a0203e4     	mov	w4, w2
    684c: 8b040ca4     	add	x4, x5, x4, lsl #3
    6850: f86258a5     	ldr	x5, [x5, w2, uxtw #3]
    6854: d360fca5     	lsr	x5, x5, #32
    6858: 92403ca5     	and	x5, x5, #0xffff
    685c: 910008a5     	add	x5, x5, #0x2
    6860: d37df0a5     	lsl	x5, x5, #3
    6864: b8656880     	ldr	w0, [x4, x5]
    6868: 350000c0     	cbnz	w0, 0x6880 <___pl_fn_17+0xbc>
    686c: 140002b7     	b	0x7348 <___pl_fn_17+0xb84>
    6870: aa1503e0     	mov	x0, x21
    6874: f9401800     	ldr	x0, [x0, #0x30]
    6878: aa1703f3     	mov	x19, x23
    687c: 14000002     	b	0x6884 <___pl_fn_17+0xc0>
    6880: aa1703f3     	mov	x19, x23
    6884: 6b00027f     	cmp	w19, w0
    6888: 54000061     	b.ne	0x6894 <___pl_fn_17+0xd0>
    688c: aa1603e1     	mov	x1, x22
    6890: 140000e5     	b	0x6c24 <___pl_fn_17+0x460>
    6894: 340056b3     	cbz	w19, 0x7368 <___pl_fn_17+0xba4>
    6898: aa1503e0     	mov	x0, x21
    689c: f9400000     	ldr	x0, [x0]
    68a0: 2a1303ef     	mov	w15, w19
    68a4: 8b0f0c0f     	add	x15, x0, x15, lsl #3
    68a8: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    68ac: d360fc00     	lsr	x0, x0, #32
    68b0: 92403c00     	and	x0, x0, #0xffff
    68b4: 91000801     	add	x1, x0, #0x2
    68b8: f86179e3     	ldr	x3, [x15, x1, lsl #3]
    68bc: f100081f     	cmp	x0, #0x2
    68c0: 540000c0     	b.eq	0x68d8 <___pl_fn_17+0x114>
    68c4: f94009e0     	ldr	x0, [x15, #0x10]
    68c8: 37105500     	tbnz	w0, #0x2, 0x7368 <___pl_fn_17+0xba4>
    68cc: 14000003     	b	0x68d8 <___pl_fn_17+0x114>
    68d0: aa1503e0     	mov	x0, x21
    68d4: f9401803     	ldr	x3, [x0, #0x30]
    68d8: f10fa47f     	cmp	x3, #0x3e9
    68dc: 54000d00     	b.eq	0x6a7c <___pl_fn_17+0x2b8>
    68e0: aa1603f4     	mov	x20, x22
    68e4: 34005554     	cbz	w20, 0x738c <___pl_fn_17+0xbc8>
    68e8: aa1503e0     	mov	x0, x21
    68ec: f9400001     	ldr	x1, [x0]
    68f0: 2a1403e0     	mov	w0, w20
    68f4: 8b000c20     	add	x0, x1, x0, lsl #3
    68f8: f8745821     	ldr	x1, [x1, w20, uxtw #3]
    68fc: d360fc21     	lsr	x1, x1, #32
    6900: 92403c21     	and	x1, x1, #0xffff
    6904: 91002421     	add	x1, x1, #0x9
    6908: d37df021     	lsl	x1, x1, #3
    690c: b8616802     	ldr	w2, [x0, x1]
    6910: 350000e2     	cbnz	w2, 0x692c <___pl_fn_17+0x168>
    6914: 1400029e     	b	0x738c <___pl_fn_17+0xbc8>
    6918: aa1503e0     	mov	x0, x21
    691c: f9401802     	ldr	x2, [x0, #0x30]
    6920: aa0203f7     	mov	x23, x2
    6924: aa1603e1     	mov	x1, x22
    6928: 14000004     	b	0x6938 <___pl_fn_17+0x174>
    692c: aa1403f6     	mov	x22, x20
    6930: aa0203f7     	mov	x23, x2
    6934: aa1603e1     	mov	x1, x22
    6938: 340053e1     	cbz	w1, 0x73b4 <___pl_fn_17+0xbf0>
    693c: aa1503e0     	mov	x0, x21
    6940: f9400001     	ldr	x1, [x0]
    6944: aa1603e0     	mov	x0, x22
    6948: 2a0003e0     	mov	w0, w0
    694c: 8b000c20     	add	x0, x1, x0, lsl #3
    6950: aa1603e2     	mov	x2, x22
    6954: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6958: d360fc21     	lsr	x1, x1, #32
    695c: 92403c21     	and	x1, x1, #0xffff
    6960: 91001c21     	add	x1, x1, #0x7
    6964: d37df021     	lsl	x1, x1, #3
    6968: b8616802     	ldr	w2, [x0, x1]
    696c: 35000082     	cbnz	w2, 0x697c <___pl_fn_17+0x1b8>
    6970: 14000291     	b	0x73b4 <___pl_fn_17+0xbf0>
    6974: aa1503e0     	mov	x0, x21
    6978: f9401802     	ldr	x2, [x0, #0x30]
    697c: 340052e2     	cbz	w2, 0x73d8 <___pl_fn_17+0xc14>
    6980: aa1503e0     	mov	x0, x21
    6984: f9400001     	ldr	x1, [x0]
    6988: 2a0203e0     	mov	w0, w2
    698c: 8b000c20     	add	x0, x1, x0, lsl #3
    6990: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6994: d360fc21     	lsr	x1, x1, #32
    6998: 92403c21     	and	x1, x1, #0xffff
    699c: 91000821     	add	x1, x1, #0x2
    69a0: d37df021     	lsl	x1, x1, #3
    69a4: b8616803     	ldr	w3, [x0, x1]
    69a8: 350000a3     	cbnz	w3, 0x69bc <___pl_fn_17+0x1f8>
    69ac: 1400028b     	b	0x73d8 <___pl_fn_17+0xc14>
    69b0: aa1503e0     	mov	x0, x21
    69b4: f9401803     	ldr	x3, [x0, #0x30]
    69b8: 14000002     	b	0x69c0 <___pl_fn_17+0x1fc>
    69bc: aa1503e0     	mov	x0, x21
    69c0: aa1503e0     	mov	x0, x21
    69c4: b9401814     	ldr	w20, [x0, #0x18]
    69c8: b9401c00     	ldr	w0, [x0, #0x1c]
    69cc: 11001281     	add	w1, w20, #0x4
    69d0: 6b00003f     	cmp	w1, w0
    69d4: 54005468     	b.hi	0x7460 <___pl_fn_17+0xc9c>
    69d8: aa1503e0     	mov	x0, x21
    69dc: f9401001     	ldr	x1, [x0, #0x20]
    69e0: 2a1403e0     	mov	w0, w20
    69e4: 8b000820     	add	x0, x1, x0, lsl #2
    69e8: aa1603e2     	mov	x2, x22
    69ec: b8345822     	str	w2, [x1, w20, uxtw #2]
    69f0: b9000413     	str	w19, [x0, #0x4]
    69f4: aa1703e2     	mov	x2, x23
    69f8: aa1303f7     	mov	x23, x19
    69fc: b9000802     	str	w2, [x0, #0x8]
    6a00: b9000c03     	str	w3, [x0, #0xc]
    6a04: 11001280     	add	w0, w20, #0x4
    6a08: aa1503e1     	mov	x1, x21
    6a0c: b9001820     	str	w0, [x1, #0x18]
    6a10: aa1503e0     	mov	x0, x21
    6a14: b9401000     	ldr	w0, [x0, #0x10]
    6a18: b9401421     	ldr	w1, [x1, #0x14]
    6a1c: 6b01001f     	cmp	w0, w1
    6a20: 54005062     	b.hs	0x742c <___pl_fn_17+0xc68>
    6a24: aa1703e1     	mov	x1, x23
    6a28: aa1503e0     	mov	x0, x21
    6a2c: 94000000     	bl	0x6a2c <___pl_fn_17+0x268>
    6a30: aa1503e1     	mov	x1, x21
    6a34: b9402c21     	ldr	w1, [x1, #0x2c]
    6a38: 35007d81     	cbnz	w1, 0x79e8 <___pl_fn_17+0x1224>
    6a3c: aa1503e1     	mov	x1, x21
    6a40: b9001834     	str	w20, [x1, #0x18]
    6a44: aa1603e1     	mov	x1, x22
    6a48: 34004d81     	cbz	w1, 0x73f8 <___pl_fn_17+0xc34>
    6a4c: aa1503e6     	mov	x6, x21
    6a50: f94000c7     	ldr	x7, [x6]
    6a54: aa1603e1     	mov	x1, x22
    6a58: 2a0103e6     	mov	w6, w1
    6a5c: 8b060ce6     	add	x6, x7, x6, lsl #3
    6a60: f86158e8     	ldr	x8, [x7, w1, uxtw #3]
    6a64: 2a0003e7     	mov	w7, w0
    6a68: d360fd08     	lsr	x8, x8, #32
    6a6c: 92403d08     	and	x8, x8, #0xffff
    6a70: 91002508     	add	x8, x8, #0x9
    6a74: f82878c7     	str	x7, [x6, x8, lsl #3]
    6a78: 1400006a     	b	0x6c20 <___pl_fn_17+0x45c>
    6a7c: aa1603e1     	mov	x1, x22
    6a80: aa1303f7     	mov	x23, x19
    6a84: 34005081     	cbz	w1, 0x7494 <___pl_fn_17+0xcd0>
    6a88: aa1503e0     	mov	x0, x21
    6a8c: f940000e     	ldr	x14, [x0]
    6a90: aa1603e1     	mov	x1, x22
    6a94: 2a0103ed     	mov	w13, w1
    6a98: 8b0d0dcd     	add	x13, x14, x13, lsl #3
    6a9c: f86159ce     	ldr	x14, [x14, w1, uxtw #3]
    6aa0: d360fdce     	lsr	x14, x14, #32
    6aa4: 92403dce     	and	x14, x14, #0xffff
    6aa8: 910021ce     	add	x14, x14, #0x8
    6aac: d37df1ce     	lsl	x14, x14, #3
    6ab0: b86e69a2     	ldr	w2, [x13, x14]
    6ab4: 350000e2     	cbnz	w2, 0x6ad0 <___pl_fn_17+0x30c>
    6ab8: 14000277     	b	0x7494 <___pl_fn_17+0xcd0>
    6abc: aa1503e0     	mov	x0, x21
    6ac0: f9401802     	ldr	x2, [x0, #0x30]
    6ac4: aa0203f4     	mov	x20, x2
    6ac8: aa1603e1     	mov	x1, x22
    6acc: 14000003     	b	0x6ad8 <___pl_fn_17+0x314>
    6ad0: aa0203f4     	mov	x20, x2
    6ad4: aa1603e1     	mov	x1, x22
    6ad8: aa1603e1     	mov	x1, x22
    6adc: 34004ee1     	cbz	w1, 0x74b8 <___pl_fn_17+0xcf4>
    6ae0: aa1503e0     	mov	x0, x21
    6ae4: f9400001     	ldr	x1, [x0]
    6ae8: aa1603e0     	mov	x0, x22
    6aec: 2a0003e0     	mov	w0, w0
    6af0: 8b000c20     	add	x0, x1, x0, lsl #3
    6af4: aa1603e2     	mov	x2, x22
    6af8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6afc: d360fc21     	lsr	x1, x1, #32
    6b00: 92403c21     	and	x1, x1, #0xffff
    6b04: 91001c21     	add	x1, x1, #0x7
    6b08: d37df021     	lsl	x1, x1, #3
    6b0c: b8616802     	ldr	w2, [x0, x1]
    6b10: 35000082     	cbnz	w2, 0x6b20 <___pl_fn_17+0x35c>
    6b14: 14000269     	b	0x74b8 <___pl_fn_17+0xcf4>
    6b18: aa1503e0     	mov	x0, x21
    6b1c: f9401802     	ldr	x2, [x0, #0x30]
    6b20: 34004de2     	cbz	w2, 0x74dc <___pl_fn_17+0xd18>
    6b24: aa1503e0     	mov	x0, x21
    6b28: f9400001     	ldr	x1, [x0]
    6b2c: 2a0203e0     	mov	w0, w2
    6b30: 8b000c20     	add	x0, x1, x0, lsl #3
    6b34: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6b38: d360fc21     	lsr	x1, x1, #32
    6b3c: 92403c21     	and	x1, x1, #0xffff
    6b40: 91000821     	add	x1, x1, #0x2
    6b44: d37df021     	lsl	x1, x1, #3
    6b48: b8616803     	ldr	w3, [x0, x1]
    6b4c: 350000a3     	cbnz	w3, 0x6b60 <___pl_fn_17+0x39c>
    6b50: 14000263     	b	0x74dc <___pl_fn_17+0xd18>
    6b54: aa1503e0     	mov	x0, x21
    6b58: f9401803     	ldr	x3, [x0, #0x30]
    6b5c: 14000002     	b	0x6b64 <___pl_fn_17+0x3a0>
    6b60: aa1503e0     	mov	x0, x21
    6b64: aa1503e0     	mov	x0, x21
    6b68: b9401813     	ldr	w19, [x0, #0x18]
    6b6c: b9401c00     	ldr	w0, [x0, #0x1c]
    6b70: 11001261     	add	w1, w19, #0x4
    6b74: 6b00003f     	cmp	w1, w0
    6b78: 54007628     	b.hi	0x7a3c <___pl_fn_17+0x1278>
    6b7c: aa1503e0     	mov	x0, x21
    6b80: f9401001     	ldr	x1, [x0, #0x20]
    6b84: 2a1303e0     	mov	w0, w19
    6b88: 8b000820     	add	x0, x1, x0, lsl #2
    6b8c: aa1603e2     	mov	x2, x22
    6b90: b8335822     	str	w2, [x1, w19, uxtw #2]
    6b94: aa1703e1     	mov	x1, x23
    6b98: b9000401     	str	w1, [x0, #0x4]
    6b9c: aa1403e2     	mov	x2, x20
    6ba0: b9000802     	str	w2, [x0, #0x8]
    6ba4: b9000c03     	str	w3, [x0, #0xc]
    6ba8: 11001260     	add	w0, w19, #0x4
    6bac: aa1503e1     	mov	x1, x21
    6bb0: b9001820     	str	w0, [x1, #0x18]
    6bb4: aa1503e0     	mov	x0, x21
    6bb8: b9401000     	ldr	w0, [x0, #0x10]
    6bbc: b9401421     	ldr	w1, [x1, #0x14]
    6bc0: 6b01001f     	cmp	w0, w1
    6bc4: 54007222     	b.hs	0x7a08 <___pl_fn_17+0x1244>
    6bc8: aa1703e1     	mov	x1, x23
    6bcc: aa1503e0     	mov	x0, x21
    6bd0: 94000000     	bl	0x6bd0 <___pl_fn_17+0x40c>
    6bd4: aa1503e1     	mov	x1, x21
    6bd8: b9402c21     	ldr	w1, [x1, #0x2c]
    6bdc: 35007061     	cbnz	w1, 0x79e8 <___pl_fn_17+0x1224>
    6be0: aa1503e5     	mov	x5, x21
    6be4: b90018b3     	str	w19, [x5, #0x18]
    6be8: aa1603e1     	mov	x1, x22
    6bec: 34004881     	cbz	w1, 0x74fc <___pl_fn_17+0xd38>
    6bf0: aa1503e1     	mov	x1, x21
    6bf4: f9400022     	ldr	x2, [x1]
    6bf8: aa1603e1     	mov	x1, x22
    6bfc: 2a0103e1     	mov	w1, w1
    6c00: 8b010c41     	add	x1, x2, x1, lsl #3
    6c04: aa1603e3     	mov	x3, x22
    6c08: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    6c0c: 2a0003e0     	mov	w0, w0
    6c10: d360fc42     	lsr	x2, x2, #32
    6c14: 92403c42     	and	x2, x2, #0xffff
    6c18: 91002042     	add	x2, x2, #0x8
    6c1c: f8227820     	str	x0, [x1, x2, lsl #3]
    6c20: aa1603e1     	mov	x1, x22
    6c24: aa1603e1     	mov	x1, x22
    6c28: 34004841     	cbz	w1, 0x7530 <___pl_fn_17+0xd6c>
    6c2c: aa1503e0     	mov	x0, x21
    6c30: f9400001     	ldr	x1, [x0]
    6c34: aa1603ef     	mov	x15, x22
    6c38: 2a0f03e0     	mov	w0, w15
    6c3c: 8b000c20     	add	x0, x1, x0, lsl #3
    6c40: aa1603e2     	mov	x2, x22
    6c44: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6c48: d360fc21     	lsr	x1, x1, #32
    6c4c: 92403c21     	and	x1, x1, #0xffff
    6c50: 91002021     	add	x1, x1, #0x8
    6c54: d37df021     	lsl	x1, x1, #3
    6c58: b8616802     	ldr	w2, [x0, x1]
    6c5c: 35000082     	cbnz	w2, 0x6c6c <___pl_fn_17+0x4a8>
    6c60: 14000234     	b	0x7530 <___pl_fn_17+0xd6c>
    6c64: aa1503e0     	mov	x0, x21
    6c68: f9401802     	ldr	x2, [x0, #0x30]
    6c6c: 52800000     	mov	w0, #0x0                ; =0
    6c70: aa0003f7     	mov	x23, x0
    6c74: 34006a02     	cbz	w2, 0x79b4 <___pl_fn_17+0x11f0>
    6c78: aa1603e1     	mov	x1, x22
    6c7c: aa0203f8     	mov	x24, x2
    6c80: 340046a1     	cbz	w1, 0x7554 <___pl_fn_17+0xd90>
    6c84: aa1503e0     	mov	x0, x21
    6c88: f9400006     	ldr	x6, [x0]
    6c8c: aa1603e1     	mov	x1, x22
    6c90: 2a0103e5     	mov	w5, w1
    6c94: 8b050cc5     	add	x5, x6, x5, lsl #3
    6c98: f86158c6     	ldr	x6, [x6, w1, uxtw #3]
    6c9c: d360fcc6     	lsr	x6, x6, #32
    6ca0: 92403cc6     	and	x6, x6, #0xffff
    6ca4: 91001cc6     	add	x6, x6, #0x7
    6ca8: d37df0c6     	lsl	x6, x6, #3
    6cac: b86668a2     	ldr	w2, [x5, x6]
    6cb0: 35000082     	cbnz	w2, 0x6cc0 <___pl_fn_17+0x4fc>
    6cb4: 14000228     	b	0x7554 <___pl_fn_17+0xd90>
    6cb8: aa1503e0     	mov	x0, x21
    6cbc: f9401802     	ldr	x2, [x0, #0x30]
    6cc0: 340045c2     	cbz	w2, 0x7578 <___pl_fn_17+0xdb4>
    6cc4: aa1503e0     	mov	x0, x21
    6cc8: f940000e     	ldr	x14, [x0]
    6ccc: 2a0203ed     	mov	w13, w2
    6cd0: 8b0d0dcd     	add	x13, x14, x13, lsl #3
    6cd4: f86259ce     	ldr	x14, [x14, w2, uxtw #3]
    6cd8: d360fdce     	lsr	x14, x14, #32
    6cdc: 92403dce     	and	x14, x14, #0xffff
    6ce0: 910009ce     	add	x14, x14, #0x2
    6ce4: d37df1ce     	lsl	x14, x14, #3
    6ce8: b86e69a7     	ldr	w7, [x13, x14]
    6cec: 350000c7     	cbnz	w7, 0x6d04 <___pl_fn_17+0x540>
    6cf0: 14000222     	b	0x7578 <___pl_fn_17+0xdb4>
    6cf4: aa1503e0     	mov	x0, x21
    6cf8: f9401807     	ldr	x7, [x0, #0x30]
    6cfc: aa1803e2     	mov	x2, x24
    6d00: 14000002     	b	0x6d08 <___pl_fn_17+0x544>
    6d04: aa1803e2     	mov	x2, x24
    6d08: 6b07005f     	cmp	w2, w7
    6d0c: 54002c00     	b.eq	0x728c <___pl_fn_17+0xac8>
    6d10: 34004442     	cbz	w2, 0x7598 <___pl_fn_17+0xdd4>
    6d14: aa1503e0     	mov	x0, x21
    6d18: f9400001     	ldr	x1, [x0]
    6d1c: 2a0203e0     	mov	w0, w2
    6d20: 8b000c20     	add	x0, x1, x0, lsl #3
    6d24: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6d28: aa0203f8     	mov	x24, x2
    6d2c: d360fc21     	lsr	x1, x1, #32
    6d30: 92403c21     	and	x1, x1, #0xffff
    6d34: 91000c22     	add	x2, x1, #0x3
    6d38: f8627813     	ldr	x19, [x0, x2, lsl #3]
    6d3c: f100083f     	cmp	x1, #0x2
    6d40: 540000c0     	b.eq	0x6d58 <___pl_fn_17+0x594>
    6d44: f9400800     	ldr	x0, [x0, #0x10]
    6d48: 371842a0     	tbnz	w0, #0x3, 0x759c <___pl_fn_17+0xdd8>
    6d4c: 14000003     	b	0x6d58 <___pl_fn_17+0x594>
    6d50: aa1503e0     	mov	x0, x21
    6d54: f9401813     	ldr	x19, [x0, #0x30]
    6d58: f100127f     	cmp	x19, #0x4
    6d5c: 54001f8a     	b.ge	0x714c <___pl_fn_17+0x988>
    6d60: aa1603e1     	mov	x1, x22
    6d64: 340042e1     	cbz	w1, 0x75c0 <___pl_fn_17+0xdfc>
    6d68: aa1503e0     	mov	x0, x21
    6d6c: f9400001     	ldr	x1, [x0]
    6d70: aa1603e0     	mov	x0, x22
    6d74: 2a0003e0     	mov	w0, w0
    6d78: 8b000c20     	add	x0, x1, x0, lsl #3
    6d7c: aa1603e2     	mov	x2, x22
    6d80: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6d84: d360fc21     	lsr	x1, x1, #32
    6d88: 92403c21     	and	x1, x1, #0xffff
    6d8c: 91002421     	add	x1, x1, #0x9
    6d90: d37df021     	lsl	x1, x1, #3
    6d94: b8616802     	ldr	w2, [x0, x1]
    6d98: 35000082     	cbnz	w2, 0x6da8 <___pl_fn_17+0x5e4>
    6d9c: 14000209     	b	0x75c0 <___pl_fn_17+0xdfc>
    6da0: aa1503e0     	mov	x0, x21
    6da4: f9401802     	ldr	x2, [x0, #0x30]
    6da8: 34005562     	cbz	w2, 0x7854 <___pl_fn_17+0x1090>
    6dac: aa1603e1     	mov	x1, x22
    6db0: aa0203f9     	mov	x25, x2
    6db4: 34004181     	cbz	w1, 0x75e4 <___pl_fn_17+0xe20>
    6db8: aa1503e0     	mov	x0, x21
    6dbc: f9400001     	ldr	x1, [x0]
    6dc0: aa1603e0     	mov	x0, x22
    6dc4: 2a0003e0     	mov	w0, w0
    6dc8: 8b000c20     	add	x0, x1, x0, lsl #3
    6dcc: aa1603e2     	mov	x2, x22
    6dd0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6dd4: d360fc21     	lsr	x1, x1, #32
    6dd8: 92403c21     	and	x1, x1, #0xffff
    6ddc: 91001c21     	add	x1, x1, #0x7
    6de0: d37df021     	lsl	x1, x1, #3
    6de4: b8616802     	ldr	w2, [x0, x1]
    6de8: 35000082     	cbnz	w2, 0x6df8 <___pl_fn_17+0x634>
    6dec: 140001fe     	b	0x75e4 <___pl_fn_17+0xe20>
    6df0: aa1503e0     	mov	x0, x21
    6df4: f9401802     	ldr	x2, [x0, #0x30]
    6df8: 34004082     	cbz	w2, 0x7608 <___pl_fn_17+0xe44>
    6dfc: aa1503e0     	mov	x0, x21
    6e00: f9400001     	ldr	x1, [x0]
    6e04: 2a0203e0     	mov	w0, w2
    6e08: 8b000c20     	add	x0, x1, x0, lsl #3
    6e0c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6e10: d360fc21     	lsr	x1, x1, #32
    6e14: 92403c21     	and	x1, x1, #0xffff
    6e18: 91000821     	add	x1, x1, #0x2
    6e1c: d37df021     	lsl	x1, x1, #3
    6e20: b8616800     	ldr	w0, [x0, x1]
    6e24: 350000c0     	cbnz	w0, 0x6e3c <___pl_fn_17+0x678>
    6e28: 140001f8     	b	0x7608 <___pl_fn_17+0xe44>
    6e2c: aa1503e0     	mov	x0, x21
    6e30: f9401800     	ldr	x0, [x0, #0x30]
    6e34: aa1903e2     	mov	x2, x25
    6e38: 14000002     	b	0x6e40 <___pl_fn_17+0x67c>
    6e3c: aa1903e2     	mov	x2, x25
    6e40: 6b00005f     	cmp	w2, w0
    6e44: 54001400     	b.eq	0x70c4 <___pl_fn_17+0x900>
    6e48: 34003f02     	cbz	w2, 0x7628 <___pl_fn_17+0xe64>
    6e4c: aa1503e0     	mov	x0, x21
    6e50: f9400005     	ldr	x5, [x0]
    6e54: 2a0203e4     	mov	w4, w2
    6e58: 8b040ca4     	add	x4, x5, x4, lsl #3
    6e5c: f86258a5     	ldr	x5, [x5, w2, uxtw #3]
    6e60: aa0203f9     	mov	x25, x2
    6e64: d360fca5     	lsr	x5, x5, #32
    6e68: 92403ca5     	and	x5, x5, #0xffff
    6e6c: d37df0a5     	lsl	x5, x5, #3
    6e70: b8656889     	ldr	w9, [x4, x5]
    6e74: 350000c9     	cbnz	w9, 0x6e8c <___pl_fn_17+0x6c8>
    6e78: 140001ed     	b	0x762c <___pl_fn_17+0xe68>
    6e7c: aa1503e0     	mov	x0, x21
    6e80: f9401809     	ldr	x9, [x0, #0x30]
    6e84: aa1603e1     	mov	x1, x22
    6e88: 14000002     	b	0x6e90 <___pl_fn_17+0x6cc>
    6e8c: aa1603e1     	mov	x1, x22
    6e90: aa1603e1     	mov	x1, x22
    6e94: 35000081     	cbnz	w1, 0x6ea4 <___pl_fn_17+0x6e0>
    6e98: 140001ee     	b	0x7650 <___pl_fn_17+0xe8c>
    6e9c: aa1503e0     	mov	x0, x21
    6ea0: 1400000e     	b	0x6ed8 <___pl_fn_17+0x714>
    6ea4: aa1503e0     	mov	x0, x21
    6ea8: f9400001     	ldr	x1, [x0]
    6eac: aa1603e0     	mov	x0, x22
    6eb0: 2a0003e0     	mov	w0, w0
    6eb4: 8b000c20     	add	x0, x1, x0, lsl #3
    6eb8: aa1603e2     	mov	x2, x22
    6ebc: f8625822     	ldr	x2, [x1, w2, uxtw #3]
    6ec0: 2a0903e1     	mov	w1, w9
    6ec4: d360fc42     	lsr	x2, x2, #32
    6ec8: 92403c42     	and	x2, x2, #0xffff
    6ecc: 91002442     	add	x2, x2, #0x9
    6ed0: f8227801     	str	x1, [x0, x2, lsl #3]
    6ed4: aa1503e0     	mov	x0, x21
    6ed8: aa1503e0     	mov	x0, x21
    6edc: b9401814     	ldr	w20, [x0, #0x18]
    6ee0: b9401c00     	ldr	w0, [x0, #0x1c]
    6ee4: 11000e81     	add	w1, w20, #0x3
    6ee8: 6b00003f     	cmp	w1, w0
    6eec: 54004648     	b.hi	0x77b4 <___pl_fn_17+0xff0>
    6ef0: aa1503e0     	mov	x0, x21
    6ef4: f9401000     	ldr	x0, [x0, #0x20]
    6ef8: 2a1403e1     	mov	w1, w20
    6efc: 8b010801     	add	x1, x0, x1, lsl #2
    6f00: aa1603e2     	mov	x2, x22
    6f04: b8345802     	str	w2, [x0, w20, uxtw #2]
    6f08: aa1803e2     	mov	x2, x24
    6f0c: b9000422     	str	w2, [x1, #0x4]
    6f10: aa1903e2     	mov	x2, x25
    6f14: b9000822     	str	w2, [x1, #0x8]
    6f18: 11000e80     	add	w0, w20, #0x3
    6f1c: aa1503e1     	mov	x1, x21
    6f20: b9001820     	str	w0, [x1, #0x18]
    6f24: aa1503e0     	mov	x0, x21
    6f28: b9401000     	ldr	w0, [x0, #0x10]
    6f2c: b9401421     	ldr	w1, [x1, #0x14]
    6f30: 6b01001f     	cmp	w0, w1
    6f34: 54004262     	b.hs	0x7780 <___pl_fn_17+0xfbc>
    6f38: aa1503e0     	mov	x0, x21
    6f3c: aa1803e1     	mov	x1, x24
    6f40: aa1303e2     	mov	x2, x19
    6f44: 94000000     	bl	0x6f44 <___pl_fn_17+0x780>
    6f48: aa1503e1     	mov	x1, x21
    6f4c: b9402c21     	ldr	w1, [x1, #0x2c]
    6f50: 350054c1     	cbnz	w1, 0x79e8 <___pl_fn_17+0x1224>
    6f54: aa1503e1     	mov	x1, x21
    6f58: b9001834     	str	w20, [x1, #0x18]
    6f5c: aa1903e2     	mov	x2, x25
    6f60: 34003922     	cbz	w2, 0x7684 <___pl_fn_17+0xec0>
    6f64: aa1503e1     	mov	x1, x21
    6f68: f9400022     	ldr	x2, [x1]
    6f6c: aa1903e1     	mov	x1, x25
    6f70: 2a0103e1     	mov	w1, w1
    6f74: 8b010c41     	add	x1, x2, x1, lsl #3
    6f78: aa1903e3     	mov	x3, x25
    6f7c: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    6f80: d360fc42     	lsr	x2, x2, #32
    6f84: 92403c43     	and	x3, x2, #0xffff
    6f88: f100087f     	cmp	x3, #0x2
    6f8c: 54000080     	b.eq	0x6f9c <___pl_fn_17+0x7d8>
    6f90: f9400823     	ldr	x3, [x1, #0x10]
    6f94: 927cf863     	and	x3, x3, #0xfffffffffffffff7
    6f98: f9000823     	str	x3, [x1, #0x10]
    6f9c: 92403c42     	and	x2, x2, #0xffff
    6fa0: 91000c42     	add	x2, x2, #0x3
    6fa4: f8227820     	str	x0, [x1, x2, lsl #3]
    6fa8: d2800020     	mov	x0, #0x1                ; =1
    6fac: ab000260     	adds	x0, x19, x0
    6fb0: 9a9f77e1     	cset	x1, vs
    6fb4: 72001c3f     	tst	w1, #0xff
    6fb8: 54003ca1     	b.ne	0x774c <___pl_fn_17+0xf88>
    6fbc: aa1803e2     	mov	x2, x24
    6fc0: 35000082     	cbnz	w2, 0x6fd0 <___pl_fn_17+0x80c>
    6fc4: 140001bc     	b	0x76b4 <___pl_fn_17+0xef0>
    6fc8: aa1503e0     	mov	x0, x21
    6fcc: 14000013     	b	0x7018 <___pl_fn_17+0x854>
    6fd0: aa1503e1     	mov	x1, x21
    6fd4: f9400022     	ldr	x2, [x1]
    6fd8: aa1803ed     	mov	x13, x24
    6fdc: 2a0d03e1     	mov	w1, w13
    6fe0: 8b010c41     	add	x1, x2, x1, lsl #3
    6fe4: aa1803e3     	mov	x3, x24
    6fe8: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    6fec: d360fc42     	lsr	x2, x2, #32
    6ff0: 92403c43     	and	x3, x2, #0xffff
    6ff4: f100087f     	cmp	x3, #0x2
    6ff8: 54000080     	b.eq	0x7008 <___pl_fn_17+0x844>
    6ffc: f9400823     	ldr	x3, [x1, #0x10]
    7000: 927cf863     	and	x3, x3, #0xfffffffffffffff7
    7004: f9000823     	str	x3, [x1, #0x10]
    7008: 92403c42     	and	x2, x2, #0xffff
    700c: 91000c42     	add	x2, x2, #0x3
    7010: f8227820     	str	x0, [x1, x2, lsl #3]
    7014: aa1503e0     	mov	x0, x21
    7018: aa1503e0     	mov	x0, x21
    701c: b9401813     	ldr	w19, [x0, #0x18]
    7020: b9401c00     	ldr	w0, [x0, #0x1c]
    7024: 11000a61     	add	w1, w19, #0x2
    7028: 6b00003f     	cmp	w1, w0
    702c: 54003768     	b.hi	0x7718 <___pl_fn_17+0xf54>
    7030: aa1503e0     	mov	x0, x21
    7034: f9401000     	ldr	x0, [x0, #0x20]
    7038: 2a1303e1     	mov	w1, w19
    703c: 8b010801     	add	x1, x0, x1, lsl #2
    7040: aa1603ef     	mov	x15, x22
    7044: b833580f     	str	w15, [x0, w19, uxtw #2]
    7048: aa1903e2     	mov	x2, x25
    704c: b9000422     	str	w2, [x1, #0x4]
    7050: 11000a60     	add	w0, w19, #0x2
    7054: aa1503e1     	mov	x1, x21
    7058: b9001820     	str	w0, [x1, #0x18]
    705c: aa1503e0     	mov	x0, x21
    7060: b9401000     	ldr	w0, [x0, #0x10]
    7064: b9401421     	ldr	w1, [x1, #0x14]
    7068: 6b01001f     	cmp	w0, w1
    706c: 540033c2     	b.hs	0x76e4 <___pl_fn_17+0xf20>
    7070: aa1603e1     	mov	x1, x22
    7074: aa1903e2     	mov	x2, x25
    7078: aa1503e0     	mov	x0, x21
    707c: 94000000     	bl	0x707c <___pl_fn_17+0x8b8>
    7080: aa1503e1     	mov	x1, x21
    7084: b9402c21     	ldr	w1, [x1, #0x2c]
    7088: 35004b01     	cbnz	w1, 0x79e8 <___pl_fn_17+0x1224>
    708c: aa1503e3     	mov	x3, x21
    7090: b9001873     	str	w19, [x3, #0x18]
    7094: aa1503e5     	mov	x5, x21
    7098: b94010a4     	ldr	w4, [x5, #0x10]
    709c: 51000484     	sub	w4, w4, #0x1
    70a0: aa1503e8     	mov	x8, x21
    70a4: b9001104     	str	w4, [x8, #0x10]
    70a8: 910183ff     	add	sp, sp, #0x60
    70ac: a8c153f3     	ldp	x19, x20, [sp], #0x10
    70b0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    70b4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    70b8: f84107f9     	ldr	x25, [sp], #0x10
    70bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    70c0: d65f03c0     	ret
    70c4: aa1503e0     	mov	x0, x21
    70c8: b9401813     	ldr	w19, [x0, #0x18]
    70cc: b9401c0c     	ldr	w12, [x0, #0x1c]
    70d0: 1100066b     	add	w11, w19, #0x1
    70d4: 6b0c017f     	cmp	w11, w12
    70d8: 54003a48     	b.hi	0x7820 <___pl_fn_17+0x105c>
    70dc: aa1503e0     	mov	x0, x21
    70e0: f940100d     	ldr	x13, [x0, #0x20]
    70e4: aa1603e1     	mov	x1, x22
    70e8: b83359a1     	str	w1, [x13, w19, uxtw #2]
    70ec: b900180b     	str	w11, [x0, #0x18]
    70f0: b940100f     	ldr	w15, [x0, #0x10]
    70f4: b9401400     	ldr	w0, [x0, #0x14]
    70f8: 6b0001ff     	cmp	w15, w0
    70fc: 54003782     	b.hs	0x77ec <___pl_fn_17+0x1028>
    7100: aa1603e1     	mov	x1, x22
    7104: aa1503e0     	mov	x0, x21
    7108: 94000000     	bl	0x7108 <___pl_fn_17+0x944>
    710c: aa1503e1     	mov	x1, x21
    7110: b9402c21     	ldr	w1, [x1, #0x2c]
    7114: 350046a1     	cbnz	w1, 0x79e8 <___pl_fn_17+0x1224>
    7118: aa1503e1     	mov	x1, x21
    711c: b9001833     	str	w19, [x1, #0x18]
    7120: b9401021     	ldr	w1, [x1, #0x10]
    7124: 51000421     	sub	w1, w1, #0x1
    7128: aa1503e2     	mov	x2, x21
    712c: b9001041     	str	w1, [x2, #0x10]
    7130: 910183ff     	add	sp, sp, #0x60
    7134: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7138: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    713c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7140: f84107f9     	ldr	x25, [sp], #0x10
    7144: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7148: d65f03c0     	ret
    714c: aa1803e2     	mov	x2, x24
    7150: 340039c2     	cbz	w2, 0x7888 <___pl_fn_17+0x10c4>
    7154: aa1503e0     	mov	x0, x21
    7158: f9400001     	ldr	x1, [x0]
    715c: aa1803e2     	mov	x2, x24
    7160: 2a0203e0     	mov	w0, w2
    7164: 8b000c20     	add	x0, x1, x0, lsl #3
    7168: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    716c: d360fc21     	lsr	x1, x1, #32
    7170: 92403c21     	and	x1, x1, #0xffff
    7174: d37df021     	lsl	x1, x1, #3
    7178: b8616800     	ldr	w0, [x0, x1]
    717c: 350000c0     	cbnz	w0, 0x7194 <___pl_fn_17+0x9d0>
    7180: 140001c2     	b	0x7888 <___pl_fn_17+0x10c4>
    7184: aa1503e0     	mov	x0, x21
    7188: f9401800     	ldr	x0, [x0, #0x30]
    718c: aa1603e1     	mov	x1, x22
    7190: 14000002     	b	0x7198 <___pl_fn_17+0x9d4>
    7194: aa1603e1     	mov	x1, x22
    7198: aa1603e1     	mov	x1, x22
    719c: 35000081     	cbnz	w1, 0x71ac <___pl_fn_17+0x9e8>
    71a0: 140001c3     	b	0x78ac <___pl_fn_17+0x10e8>
    71a4: aa1503e0     	mov	x0, x21
    71a8: 1400000e     	b	0x71e0 <___pl_fn_17+0xa1c>
    71ac: aa1503e1     	mov	x1, x21
    71b0: f9400022     	ldr	x2, [x1]
    71b4: aa1603e1     	mov	x1, x22
    71b8: 2a0103e1     	mov	w1, w1
    71bc: 8b010c41     	add	x1, x2, x1, lsl #3
    71c0: aa1603e3     	mov	x3, x22
    71c4: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    71c8: 2a0003e0     	mov	w0, w0
    71cc: d360fc42     	lsr	x2, x2, #32
    71d0: 92403c42     	and	x2, x2, #0xffff
    71d4: 91002042     	add	x2, x2, #0x8
    71d8: f8227820     	str	x0, [x1, x2, lsl #3]
    71dc: aa1503e0     	mov	x0, x21
    71e0: aa1503e0     	mov	x0, x21
    71e4: b9401813     	ldr	w19, [x0, #0x18]
    71e8: b9401c00     	ldr	w0, [x0, #0x1c]
    71ec: 11000a61     	add	w1, w19, #0x2
    71f0: 6b00003f     	cmp	w1, w0
    71f4: 54003908     	b.hi	0x7914 <___pl_fn_17+0x1150>
    71f8: aa1503e0     	mov	x0, x21
    71fc: f9401000     	ldr	x0, [x0, #0x20]
    7200: 2a1303e1     	mov	w1, w19
    7204: 8b010801     	add	x1, x0, x1, lsl #2
    7208: aa1603e2     	mov	x2, x22
    720c: b8335802     	str	w2, [x0, w19, uxtw #2]
    7210: aa1803e2     	mov	x2, x24
    7214: b9000422     	str	w2, [x1, #0x4]
    7218: 11000a60     	add	w0, w19, #0x2
    721c: aa1503ef     	mov	x15, x21
    7220: b90019e0     	str	w0, [x15, #0x18]
    7224: aa1503e0     	mov	x0, x21
    7228: b9401000     	ldr	w0, [x0, #0x10]
    722c: aa1503e1     	mov	x1, x21
    7230: b9401421     	ldr	w1, [x1, #0x14]
    7234: 6b01001f     	cmp	w0, w1
    7238: 54003542     	b.hs	0x78e0 <___pl_fn_17+0x111c>
    723c: aa1603e1     	mov	x1, x22
    7240: aa1803e2     	mov	x2, x24
    7244: aa1503e0     	mov	x0, x21
    7248: 94000000     	bl	0x7248 <___pl_fn_17+0xa84>
    724c: aa1503e1     	mov	x1, x21
    7250: b9402c21     	ldr	w1, [x1, #0x2c]
    7254: 35003ca1     	cbnz	w1, 0x79e8 <___pl_fn_17+0x1224>
    7258: aa1503e1     	mov	x1, x21
    725c: b9001833     	str	w19, [x1, #0x18]
    7260: b9401021     	ldr	w1, [x1, #0x10]
    7264: 51000421     	sub	w1, w1, #0x1
    7268: aa1503e2     	mov	x2, x21
    726c: b9001041     	str	w1, [x2, #0x10]
    7270: 910183ff     	add	sp, sp, #0x60
    7274: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7278: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    727c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7280: f84107f9     	ldr	x25, [sp], #0x10
    7284: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7288: d65f03c0     	ret
    728c: aa1503e0     	mov	x0, x21
    7290: b9401813     	ldr	w19, [x0, #0x18]
    7294: b9401c01     	ldr	w1, [x0, #0x1c]
    7298: 11000660     	add	w0, w19, #0x1
    729c: 6b01001f     	cmp	w0, w1
    72a0: 54003708     	b.hi	0x7980 <___pl_fn_17+0x11bc>
    72a4: aa1503e1     	mov	x1, x21
    72a8: f9401021     	ldr	x1, [x1, #0x20]
    72ac: aa1603e2     	mov	x2, x22
    72b0: b8335822     	str	w2, [x1, w19, uxtw #2]
    72b4: aa1503e1     	mov	x1, x21
    72b8: b9001820     	str	w0, [x1, #0x18]
    72bc: aa1503e0     	mov	x0, x21
    72c0: b9401000     	ldr	w0, [x0, #0x10]
    72c4: b9401421     	ldr	w1, [x1, #0x14]
    72c8: 6b01001f     	cmp	w0, w1
    72cc: 54003402     	b.hs	0x794c <___pl_fn_17+0x1188>
    72d0: aa1603e1     	mov	x1, x22
    72d4: aa1503e0     	mov	x0, x21
    72d8: 94000000     	bl	0x72d8 <___pl_fn_17+0xb14>
    72dc: aa1503e2     	mov	x2, x21
    72e0: b9402c41     	ldr	w1, [x2, #0x2c]
    72e4: 35003821     	cbnz	w1, 0x79e8 <___pl_fn_17+0x1224>
    72e8: aa1503e6     	mov	x6, x21
    72ec: b90018d3     	str	w19, [x6, #0x18]
    72f0: aa1503e8     	mov	x8, x21
    72f4: b9401101     	ldr	w1, [x8, #0x10]
    72f8: 51000421     	sub	w1, w1, #0x1
    72fc: aa1503eb     	mov	x11, x21
    7300: b9001161     	str	w1, [x11, #0x10]
    7304: 910183ff     	add	sp, sp, #0x60
    7308: a8c153f3     	ldp	x19, x20, [sp], #0x10
    730c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7310: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7314: f84107f9     	ldr	x25, [sp], #0x10
    7318: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    731c: d65f03c0     	ret
    7320: aa0003f5     	mov	x21, x0
    7324: 52801f41     	mov	w1, #0xfa               ; =250
    7328: 528000e3     	mov	w3, #0x7                ; =7
    732c: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    7330: f9400084     	ldr	x4, [x4]
    7334: aa1503e0     	mov	x0, x21
    7338: aa1603e2     	mov	x2, x22
    733c: d63f0080     	blr	x4
    7340: 34ffa7a0     	cbz	w0, 0x6834 <___pl_fn_17+0x70>
    7344: 140001a9     	b	0x79e8 <___pl_fn_17+0x1224>
    7348: 52801f61     	mov	w1, #0xfb               ; =251
    734c: 52800043     	mov	w3, #0x2                ; =2
    7350: 90000006     	adrp	x6, 0x7000 <___pl_fn_17+0x83c>
    7354: f94000c6     	ldr	x6, [x6]
    7358: aa1503e0     	mov	x0, x21
    735c: d63f00c0     	blr	x6
    7360: 34ffa880     	cbz	w0, 0x6870 <___pl_fn_17+0xac>
    7364: 140001a1     	b	0x79e8 <___pl_fn_17+0x1224>
    7368: 52801f81     	mov	w1, #0xfc               ; =252
    736c: 52800043     	mov	w3, #0x2                ; =2
    7370: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    7374: f9400084     	ldr	x4, [x4]
    7378: aa1503e0     	mov	x0, x21
    737c: aa1303e2     	mov	x2, x19
    7380: d63f0080     	blr	x4
    7384: 34ffaa60     	cbz	w0, 0x68d0 <___pl_fn_17+0x10c>
    7388: 14000198     	b	0x79e8 <___pl_fn_17+0x1224>
    738c: 52801fa1     	mov	w1, #0xfd               ; =253
    7390: 52800123     	mov	w3, #0x9                ; =9
    7394: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    7398: f9400084     	ldr	x4, [x4]
    739c: aa1503e0     	mov	x0, x21
    73a0: aa1403e2     	mov	x2, x20
    73a4: d63f0080     	blr	x4
    73a8: aa1403f6     	mov	x22, x20
    73ac: 34ffab60     	cbz	w0, 0x6918 <___pl_fn_17+0x154>
    73b0: 1400018e     	b	0x79e8 <___pl_fn_17+0x1224>
    73b4: 52801fc1     	mov	w1, #0xfe               ; =254
    73b8: 528000e3     	mov	w3, #0x7                ; =7
    73bc: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    73c0: f9400084     	ldr	x4, [x4]
    73c4: aa1503e0     	mov	x0, x21
    73c8: aa1603e2     	mov	x2, x22
    73cc: d63f0080     	blr	x4
    73d0: 34ffad20     	cbz	w0, 0x6974 <___pl_fn_17+0x1b0>
    73d4: 14000185     	b	0x79e8 <___pl_fn_17+0x1224>
    73d8: 52801fe1     	mov	w1, #0xff               ; =255
    73dc: 52800043     	mov	w3, #0x2                ; =2
    73e0: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    73e4: f9400084     	ldr	x4, [x4]
    73e8: aa1503e0     	mov	x0, x21
    73ec: d63f0080     	blr	x4
    73f0: 34ffae00     	cbz	w0, 0x69b0 <___pl_fn_17+0x1ec>
    73f4: 1400017d     	b	0x79e8 <___pl_fn_17+0x1224>
    73f8: d2800121     	mov	x1, #0x9                ; =9
    73fc: 910003e3     	mov	x3, sp
    7400: f80003e1     	stur	x1, [sp]
    7404: 2a0003e2     	mov	w2, w0
    7408: f80083e2     	stur	x2, [sp, #0x8]
    740c: 52802041     	mov	w1, #0x102              ; =258
    7410: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    7414: f9400084     	ldr	x4, [x4]
    7418: aa1503e0     	mov	x0, x21
    741c: aa1603e2     	mov	x2, x22
    7420: d63f0080     	blr	x4
    7424: 34ffbfe0     	cbz	w0, 0x6c20 <___pl_fn_17+0x45c>
    7428: 14000170     	b	0x79e8 <___pl_fn_17+0x1224>
    742c: 52802021     	mov	w1, #0x101              ; =257
    7430: 90000009     	adrp	x9, 0x7000 <___pl_fn_17+0x83c>
    7434: f9400129     	ldr	x9, [x9]
    7438: aa1503e0     	mov	x0, x21
    743c: d63f0120     	blr	x9
    7440: 52800000     	mov	w0, #0x0                ; =0
    7444: 910183ff     	add	sp, sp, #0x60
    7448: a8c153f3     	ldp	x19, x20, [sp], #0x10
    744c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7450: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7454: f84107f9     	ldr	x25, [sp], #0x10
    7458: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    745c: d65f03c0     	ret
    7460: 52802001     	mov	w1, #0x100              ; =256
    7464: 9000000a     	adrp	x10, 0x7000 <___pl_fn_17+0x83c>
    7468: f940014a     	ldr	x10, [x10]
    746c: aa1503e0     	mov	x0, x21
    7470: d63f0140     	blr	x10
    7474: 52800000     	mov	w0, #0x0                ; =0
    7478: 910183ff     	add	sp, sp, #0x60
    747c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7480: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7484: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7488: f84107f9     	ldr	x25, [sp], #0x10
    748c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7490: d65f03c0     	ret
    7494: 52802061     	mov	w1, #0x103              ; =259
    7498: 52800103     	mov	w3, #0x8                ; =8
    749c: 9000000f     	adrp	x15, 0x7000 <___pl_fn_17+0x83c>
    74a0: f94001ef     	ldr	x15, [x15]
    74a4: aa1503e0     	mov	x0, x21
    74a8: aa1603e2     	mov	x2, x22
    74ac: d63f01e0     	blr	x15
    74b0: 34ffb060     	cbz	w0, 0x6abc <___pl_fn_17+0x2f8>
    74b4: 1400014d     	b	0x79e8 <___pl_fn_17+0x1224>
    74b8: 52802081     	mov	w1, #0x104              ; =260
    74bc: 528000e3     	mov	w3, #0x7                ; =7
    74c0: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    74c4: f9400084     	ldr	x4, [x4]
    74c8: aa1503e0     	mov	x0, x21
    74cc: aa1603e2     	mov	x2, x22
    74d0: d63f0080     	blr	x4
    74d4: 34ffb220     	cbz	w0, 0x6b18 <___pl_fn_17+0x354>
    74d8: 14000144     	b	0x79e8 <___pl_fn_17+0x1224>
    74dc: 528020a1     	mov	w1, #0x105              ; =261
    74e0: 52800043     	mov	w3, #0x2                ; =2
    74e4: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    74e8: f9400084     	ldr	x4, [x4]
    74ec: aa1503e0     	mov	x0, x21
    74f0: d63f0080     	blr	x4
    74f4: 34ffb300     	cbz	w0, 0x6b54 <___pl_fn_17+0x390>
    74f8: 1400013c     	b	0x79e8 <___pl_fn_17+0x1224>
    74fc: d2800101     	mov	x1, #0x8                ; =8
    7500: 910043e3     	add	x3, sp, #0x10
    7504: f80103e1     	stur	x1, [sp, #0x10]
    7508: 2a0003e0     	mov	w0, w0
    750c: f80183e0     	stur	x0, [sp, #0x18]
    7510: 52802101     	mov	w1, #0x108              ; =264
    7514: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    7518: f9400084     	ldr	x4, [x4]
    751c: aa1503e0     	mov	x0, x21
    7520: aa1603e2     	mov	x2, x22
    7524: d63f0080     	blr	x4
    7528: 34ffb7c0     	cbz	w0, 0x6c20 <___pl_fn_17+0x45c>
    752c: 1400012f     	b	0x79e8 <___pl_fn_17+0x1224>
    7530: 52802121     	mov	w1, #0x109              ; =265
    7534: 52800103     	mov	w3, #0x8                ; =8
    7538: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    753c: f9400084     	ldr	x4, [x4]
    7540: aa1503e0     	mov	x0, x21
    7544: aa1603e2     	mov	x2, x22
    7548: d63f0080     	blr	x4
    754c: 34ffb8c0     	cbz	w0, 0x6c64 <___pl_fn_17+0x4a0>
    7550: 14000126     	b	0x79e8 <___pl_fn_17+0x1224>
    7554: 52802161     	mov	w1, #0x10b              ; =267
    7558: 528000e3     	mov	w3, #0x7                ; =7
    755c: 90000007     	adrp	x7, 0x7000 <___pl_fn_17+0x83c>
    7560: f94000e7     	ldr	x7, [x7]
    7564: aa1503e0     	mov	x0, x21
    7568: aa1603e2     	mov	x2, x22
    756c: d63f00e0     	blr	x7
    7570: 34ffba40     	cbz	w0, 0x6cb8 <___pl_fn_17+0x4f4>
    7574: 1400011d     	b	0x79e8 <___pl_fn_17+0x1224>
    7578: 52802181     	mov	w1, #0x10c              ; =268
    757c: 52800043     	mov	w3, #0x2                ; =2
    7580: 9000000f     	adrp	x15, 0x7000 <___pl_fn_17+0x83c>
    7584: f94001ef     	ldr	x15, [x15]
    7588: aa1503e0     	mov	x0, x21
    758c: d63f01e0     	blr	x15
    7590: 34ffbb20     	cbz	w0, 0x6cf4 <___pl_fn_17+0x530>
    7594: 14000115     	b	0x79e8 <___pl_fn_17+0x1224>
    7598: aa0203f8     	mov	x24, x2
    759c: 528021a1     	mov	w1, #0x10d              ; =269
    75a0: 52800063     	mov	w3, #0x3                ; =3
    75a4: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    75a8: f9400084     	ldr	x4, [x4]
    75ac: aa1503e0     	mov	x0, x21
    75b0: aa1803e2     	mov	x2, x24
    75b4: d63f0080     	blr	x4
    75b8: 34ffbcc0     	cbz	w0, 0x6d50 <___pl_fn_17+0x58c>
    75bc: 1400010b     	b	0x79e8 <___pl_fn_17+0x1224>
    75c0: 528021c1     	mov	w1, #0x10e              ; =270
    75c4: 52800123     	mov	w3, #0x9                ; =9
    75c8: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    75cc: f9400084     	ldr	x4, [x4]
    75d0: aa1503e0     	mov	x0, x21
    75d4: aa1603e2     	mov	x2, x22
    75d8: d63f0080     	blr	x4
    75dc: 34ffbe20     	cbz	w0, 0x6da0 <___pl_fn_17+0x5dc>
    75e0: 14000102     	b	0x79e8 <___pl_fn_17+0x1224>
    75e4: 52802201     	mov	w1, #0x110              ; =272
    75e8: 528000e3     	mov	w3, #0x7                ; =7
    75ec: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    75f0: f9400084     	ldr	x4, [x4]
    75f4: aa1503e0     	mov	x0, x21
    75f8: aa1603e2     	mov	x2, x22
    75fc: d63f0080     	blr	x4
    7600: 34ffbf80     	cbz	w0, 0x6df0 <___pl_fn_17+0x62c>
    7604: 140000f9     	b	0x79e8 <___pl_fn_17+0x1224>
    7608: 52802221     	mov	w1, #0x111              ; =273
    760c: 52800043     	mov	w3, #0x2                ; =2
    7610: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    7614: f9400084     	ldr	x4, [x4]
    7618: aa1503e0     	mov	x0, x21
    761c: d63f0080     	blr	x4
    7620: 34ffc060     	cbz	w0, 0x6e2c <___pl_fn_17+0x668>
    7624: 140000f1     	b	0x79e8 <___pl_fn_17+0x1224>
    7628: aa0203f9     	mov	x25, x2
    762c: 52802241     	mov	w1, #0x112              ; =274
    7630: 90000006     	adrp	x6, 0x7000 <___pl_fn_17+0x83c>
    7634: f94000c6     	ldr	x6, [x6]
    7638: aa1503e0     	mov	x0, x21
    763c: aa1903e2     	mov	x2, x25
    7640: aa1703e3     	mov	x3, x23
    7644: d63f00c0     	blr	x6
    7648: 34ffc1a0     	cbz	w0, 0x6e7c <___pl_fn_17+0x6b8>
    764c: 140000e7     	b	0x79e8 <___pl_fn_17+0x1224>
    7650: d280012b     	mov	x11, #0x9               ; =9
    7654: 910083e3     	add	x3, sp, #0x20
    7658: f80203eb     	stur	x11, [sp, #0x20]
    765c: 2a0903ec     	mov	w12, w9
    7660: f80283ec     	stur	x12, [sp, #0x28]
    7664: 52802261     	mov	w1, #0x113              ; =275
    7668: 9000000d     	adrp	x13, 0x7000 <___pl_fn_17+0x83c>
    766c: f94001ad     	ldr	x13, [x13]
    7670: aa1503e0     	mov	x0, x21
    7674: aa1603e2     	mov	x2, x22
    7678: d63f01a0     	blr	x13
    767c: 34ffc100     	cbz	w0, 0x6e9c <___pl_fn_17+0x6d8>
    7680: 140000da     	b	0x79e8 <___pl_fn_17+0x1224>
    7684: d2800061     	mov	x1, #0x3                ; =3
    7688: 9100c3e3     	add	x3, sp, #0x30
    768c: f80303e1     	stur	x1, [sp, #0x30]
    7690: f80383e0     	stur	x0, [sp, #0x38]
    7694: 528022c1     	mov	w1, #0x116              ; =278
    7698: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    769c: f9400084     	ldr	x4, [x4]
    76a0: aa1503e0     	mov	x0, x21
    76a4: aa1903e2     	mov	x2, x25
    76a8: d63f0080     	blr	x4
    76ac: 34ffc7e0     	cbz	w0, 0x6fa8 <___pl_fn_17+0x7e4>
    76b0: 140000ce     	b	0x79e8 <___pl_fn_17+0x1224>
    76b4: d2800061     	mov	x1, #0x3                ; =3
    76b8: 910103e3     	add	x3, sp, #0x40
    76bc: f80403e1     	stur	x1, [sp, #0x40]
    76c0: f80483e0     	stur	x0, [sp, #0x48]
    76c4: 52802301     	mov	w1, #0x118              ; =280
    76c8: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    76cc: f9400084     	ldr	x4, [x4]
    76d0: aa1803e2     	mov	x2, x24
    76d4: aa1503e0     	mov	x0, x21
    76d8: d63f0080     	blr	x4
    76dc: 34ffc760     	cbz	w0, 0x6fc8 <___pl_fn_17+0x804>
    76e0: 140000c2     	b	0x79e8 <___pl_fn_17+0x1224>
    76e4: 52802341     	mov	w1, #0x11a              ; =282
    76e8: 90000006     	adrp	x6, 0x7000 <___pl_fn_17+0x83c>
    76ec: f94000c6     	ldr	x6, [x6]
    76f0: aa1503e0     	mov	x0, x21
    76f4: d63f00c0     	blr	x6
    76f8: aa1703e0     	mov	x0, x23
    76fc: 910183ff     	add	sp, sp, #0x60
    7700: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7704: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7708: a8c163f7     	ldp	x23, x24, [sp], #0x10
    770c: f84107f9     	ldr	x25, [sp], #0x10
    7710: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7714: d65f03c0     	ret
    7718: 52802321     	mov	w1, #0x119              ; =281
    771c: 90000007     	adrp	x7, 0x7000 <___pl_fn_17+0x83c>
    7720: f94000e7     	ldr	x7, [x7]
    7724: aa1503e0     	mov	x0, x21
    7728: d63f00e0     	blr	x7
    772c: aa1703e0     	mov	x0, x23
    7730: 910183ff     	add	sp, sp, #0x60
    7734: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7738: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    773c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7740: f84107f9     	ldr	x25, [sp], #0x10
    7744: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7748: d65f03c0     	ret
    774c: 528022e1     	mov	w1, #0x117              ; =279
    7750: 90000008     	adrp	x8, 0x7000 <___pl_fn_17+0x83c>
    7754: f9400108     	ldr	x8, [x8]
    7758: aa1503e0     	mov	x0, x21
    775c: d63f0100     	blr	x8
    7760: aa1703e0     	mov	x0, x23
    7764: 910183ff     	add	sp, sp, #0x60
    7768: a8c153f3     	ldp	x19, x20, [sp], #0x10
    776c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7770: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7774: f84107f9     	ldr	x25, [sp], #0x10
    7778: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    777c: d65f03c0     	ret
    7780: 528022a1     	mov	w1, #0x115              ; =277
    7784: 90000009     	adrp	x9, 0x7000 <___pl_fn_17+0x83c>
    7788: f9400129     	ldr	x9, [x9]
    778c: aa1503e0     	mov	x0, x21
    7790: d63f0120     	blr	x9
    7794: aa1703e0     	mov	x0, x23
    7798: 910183ff     	add	sp, sp, #0x60
    779c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    77a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    77a4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    77a8: f84107f9     	ldr	x25, [sp], #0x10
    77ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    77b0: d65f03c0     	ret
    77b4: 52802281     	mov	w1, #0x114              ; =276
    77b8: 9000000a     	adrp	x10, 0x7000 <___pl_fn_17+0x83c>
    77bc: f940014a     	ldr	x10, [x10]
    77c0: aa1503e0     	mov	x0, x21
    77c4: d63f0140     	blr	x10
    77c8: aa1703e0     	mov	x0, x23
    77cc: 910183ff     	add	sp, sp, #0x60
    77d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    77d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    77d8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    77dc: f84107f9     	ldr	x25, [sp], #0x10
    77e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    77e4: d65f03c0     	ret
    77e8: 14000080     	b	0x79e8 <___pl_fn_17+0x1224>
    77ec: 52802381     	mov	w1, #0x11c              ; =284
    77f0: 90000002     	adrp	x2, 0x7000 <___pl_fn_17+0x83c>
    77f4: f9400042     	ldr	x2, [x2]
    77f8: aa1503e0     	mov	x0, x21
    77fc: d63f0040     	blr	x2
    7800: aa1703e0     	mov	x0, x23
    7804: 910183ff     	add	sp, sp, #0x60
    7808: a8c153f3     	ldp	x19, x20, [sp], #0x10
    780c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7810: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7814: f84107f9     	ldr	x25, [sp], #0x10
    7818: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    781c: d65f03c0     	ret
    7820: 52802361     	mov	w1, #0x11b              ; =283
    7824: 90000002     	adrp	x2, 0x7000 <___pl_fn_17+0x83c>
    7828: f9400042     	ldr	x2, [x2]
    782c: aa1503e0     	mov	x0, x21
    7830: d63f0040     	blr	x2
    7834: aa1703e0     	mov	x0, x23
    7838: 910183ff     	add	sp, sp, #0x60
    783c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7840: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7844: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7848: f84107f9     	ldr	x25, [sp], #0x10
    784c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7850: d65f03c0     	ret
    7854: 528021e1     	mov	w1, #0x10f              ; =271
    7858: 90000002     	adrp	x2, 0x7000 <___pl_fn_17+0x83c>
    785c: f9400042     	ldr	x2, [x2]
    7860: aa1503e0     	mov	x0, x21
    7864: d63f0040     	blr	x2
    7868: aa1703e0     	mov	x0, x23
    786c: 910183ff     	add	sp, sp, #0x60
    7870: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7874: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7878: a8c163f7     	ldp	x23, x24, [sp], #0x10
    787c: f84107f9     	ldr	x25, [sp], #0x10
    7880: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7884: d65f03c0     	ret
    7888: 528023a1     	mov	w1, #0x11d              ; =285
    788c: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    7890: f9400084     	ldr	x4, [x4]
    7894: aa1503e0     	mov	x0, x21
    7898: aa1803e2     	mov	x2, x24
    789c: aa1703e3     	mov	x3, x23
    78a0: d63f0080     	blr	x4
    78a4: 34ffc700     	cbz	w0, 0x7184 <___pl_fn_17+0x9c0>
    78a8: 14000050     	b	0x79e8 <___pl_fn_17+0x1224>
    78ac: d2800101     	mov	x1, #0x8                ; =8
    78b0: 910143e3     	add	x3, sp, #0x50
    78b4: f80503e1     	stur	x1, [sp, #0x50]
    78b8: 2a0003e0     	mov	w0, w0
    78bc: f80583e0     	stur	x0, [sp, #0x58]
    78c0: 528023c1     	mov	w1, #0x11e              ; =286
    78c4: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    78c8: f9400084     	ldr	x4, [x4]
    78cc: aa1503e0     	mov	x0, x21
    78d0: aa1603e2     	mov	x2, x22
    78d4: d63f0080     	blr	x4
    78d8: 34ffc660     	cbz	w0, 0x71a4 <___pl_fn_17+0x9e0>
    78dc: 14000043     	b	0x79e8 <___pl_fn_17+0x1224>
    78e0: 52802401     	mov	w1, #0x120              ; =288
    78e4: 90000002     	adrp	x2, 0x7000 <___pl_fn_17+0x83c>
    78e8: f9400042     	ldr	x2, [x2]
    78ec: aa1503e0     	mov	x0, x21
    78f0: d63f0040     	blr	x2
    78f4: aa1703e0     	mov	x0, x23
    78f8: 910183ff     	add	sp, sp, #0x60
    78fc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7900: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7904: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7908: f84107f9     	ldr	x25, [sp], #0x10
    790c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7910: d65f03c0     	ret
    7914: 528023e1     	mov	w1, #0x11f              ; =287
    7918: 90000002     	adrp	x2, 0x7000 <___pl_fn_17+0x83c>
    791c: f9400042     	ldr	x2, [x2]
    7920: aa1503e0     	mov	x0, x21
    7924: d63f0040     	blr	x2
    7928: aa1703e0     	mov	x0, x23
    792c: 910183ff     	add	sp, sp, #0x60
    7930: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7934: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7938: a8c163f7     	ldp	x23, x24, [sp], #0x10
    793c: f84107f9     	ldr	x25, [sp], #0x10
    7940: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7944: d65f03c0     	ret
    7948: 14000028     	b	0x79e8 <___pl_fn_17+0x1224>
    794c: 52802441     	mov	w1, #0x122              ; =290
    7950: 90000003     	adrp	x3, 0x7000 <___pl_fn_17+0x83c>
    7954: f9400063     	ldr	x3, [x3]
    7958: aa1503e0     	mov	x0, x21
    795c: d63f0060     	blr	x3
    7960: aa1703e0     	mov	x0, x23
    7964: 910183ff     	add	sp, sp, #0x60
    7968: a8c153f3     	ldp	x19, x20, [sp], #0x10
    796c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7970: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7974: f84107f9     	ldr	x25, [sp], #0x10
    7978: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    797c: d65f03c0     	ret
    7980: 52802421     	mov	w1, #0x121              ; =289
    7984: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    7988: f9400084     	ldr	x4, [x4]
    798c: aa1503e0     	mov	x0, x21
    7990: d63f0080     	blr	x4
    7994: aa1703e0     	mov	x0, x23
    7998: 910183ff     	add	sp, sp, #0x60
    799c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    79a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    79a4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    79a8: f84107f9     	ldr	x25, [sp], #0x10
    79ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    79b0: d65f03c0     	ret
    79b4: 52802141     	mov	w1, #0x10a              ; =266
    79b8: 90000005     	adrp	x5, 0x7000 <___pl_fn_17+0x83c>
    79bc: f94000a5     	ldr	x5, [x5]
    79c0: aa1503e0     	mov	x0, x21
    79c4: d63f00a0     	blr	x5
    79c8: aa1703e0     	mov	x0, x23
    79cc: 910183ff     	add	sp, sp, #0x60
    79d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    79d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    79d8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    79dc: f84107f9     	ldr	x25, [sp], #0x10
    79e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    79e4: d65f03c0     	ret
    79e8: 52800000     	mov	w0, #0x0                ; =0
    79ec: 910183ff     	add	sp, sp, #0x60
    79f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    79f4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    79f8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    79fc: f84107f9     	ldr	x25, [sp], #0x10
    7a00: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7a04: d65f03c0     	ret
    7a08: 528020e1     	mov	w1, #0x107              ; =263
    7a0c: 90000007     	adrp	x7, 0x7000 <___pl_fn_17+0x83c>
    7a10: f94000e7     	ldr	x7, [x7]
    7a14: aa1503e0     	mov	x0, x21
    7a18: d63f00e0     	blr	x7
    7a1c: 52800000     	mov	w0, #0x0                ; =0
    7a20: 910183ff     	add	sp, sp, #0x60
    7a24: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7a28: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7a2c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7a30: f84107f9     	ldr	x25, [sp], #0x10
    7a34: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7a38: d65f03c0     	ret
    7a3c: 528020c1     	mov	w1, #0x106              ; =262
    7a40: 90000008     	adrp	x8, 0x7000 <___pl_fn_17+0x83c>
    7a44: f9400108     	ldr	x8, [x8]
    7a48: aa1503e0     	mov	x0, x21
    7a4c: d63f0100     	blr	x8
    7a50: 52800000     	mov	w0, #0x0                ; =0
    7a54: 910183ff     	add	sp, sp, #0x60
    7a58: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7a5c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7a60: a8c163f7     	ldp	x23, x24, [sp], #0x10
    7a64: f84107f9     	ldr	x25, [sp], #0x10
    7a68: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7a6c: d65f03c0     	ret

0000000000007a70 <___pl_fn_18>:
    7a70: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    7a74: 910003fd     	mov	x29, sp
    7a78: f81f0ffc     	str	x28, [sp, #-0x10]!
    7a7c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    7a80: d100c3ff     	sub	sp, sp, #0x30
    7a84: aa0103fc     	mov	x28, x1
    7a88: b9401001     	ldr	w1, [x0, #0x10]
    7a8c: 11000421     	add	w1, w1, #0x1
    7a90: b9001001     	str	w1, [x0, #0x10]
    7a94: aa1c03e1     	mov	x1, x28
    7a98: 34002741     	cbz	w1, 0x7f80 <___pl_fn_18+0x510>
    7a9c: f9400002     	ldr	x2, [x0]
    7aa0: aa1c03e1     	mov	x1, x28
    7aa4: aa0003f4     	mov	x20, x0
    7aa8: 2a0103e0     	mov	w0, w1
    7aac: 8b000c41     	add	x1, x2, x0, lsl #3
    7ab0: aa1c03e7     	mov	x7, x28
    7ab4: f8675840     	ldr	x0, [x2, w7, uxtw #3]
    7ab8: d360fc00     	lsr	x0, x0, #32
    7abc: 92403c02     	and	x2, x0, #0xffff
    7ac0: 91002440     	add	x0, x2, #0x9
    7ac4: f8607820     	ldr	x0, [x1, x0, lsl #3]
    7ac8: f100085f     	cmp	x2, #0x2
    7acc: 540000c0     	b.eq	0x7ae4 <___pl_fn_18+0x74>
    7ad0: f9400821     	ldr	x1, [x1, #0x10]
    7ad4: 37482581     	tbnz	w1, #0x9, 0x7f84 <___pl_fn_18+0x514>
    7ad8: 14000003     	b	0x7ae4 <___pl_fn_18+0x74>
    7adc: aa1403e0     	mov	x0, x20
    7ae0: f9401800     	ldr	x0, [x0, #0x30]
    7ae4: d2800021     	mov	x1, #0x1                ; =1
    7ae8: eb010000     	subs	x0, x0, x1
    7aec: 9a9f77e1     	cset	x1, vs
    7af0: 72001c3f     	tst	w1, #0xff
    7af4: 54003ae1     	b.ne	0x8250 <___pl_fn_18+0x7e0>
    7af8: aa1c03f3     	mov	x19, x28
    7afc: 35000093     	cbnz	w19, 0x7b0c <___pl_fn_18+0x9c>
    7b00: 1400012a     	b	0x7fa8 <___pl_fn_18+0x538>
    7b04: aa1c03e1     	mov	x1, x28
    7b08: 14000014     	b	0x7b58 <___pl_fn_18+0xe8>
    7b0c: aa1403e1     	mov	x1, x20
    7b10: aa1303fc     	mov	x28, x19
    7b14: f9400022     	ldr	x2, [x1]
    7b18: aa1c03e1     	mov	x1, x28
    7b1c: 2a0103e1     	mov	w1, w1
    7b20: 8b010c41     	add	x1, x2, x1, lsl #3
    7b24: aa1c03e3     	mov	x3, x28
    7b28: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    7b2c: d360fc42     	lsr	x2, x2, #32
    7b30: 92403c43     	and	x3, x2, #0xffff
    7b34: f100087f     	cmp	x3, #0x2
    7b38: 54000080     	b.eq	0x7b48 <___pl_fn_18+0xd8>
    7b3c: f9400823     	ldr	x3, [x1, #0x10]
    7b40: 9276f863     	and	x3, x3, #0xfffffffffffffdff
    7b44: f9000823     	str	x3, [x1, #0x10]
    7b48: 92403c42     	and	x2, x2, #0xffff
    7b4c: 91002442     	add	x2, x2, #0x9
    7b50: f8227820     	str	x0, [x1, x2, lsl #3]
    7b54: aa1c03e1     	mov	x1, x28
    7b58: aa1c03e1     	mov	x1, x28
    7b5c: 34002401     	cbz	w1, 0x7fdc <___pl_fn_18+0x56c>
    7b60: aa1403e0     	mov	x0, x20
    7b64: f9400001     	ldr	x1, [x0]
    7b68: aa1c03e0     	mov	x0, x28
    7b6c: 2a0003e0     	mov	w0, w0
    7b70: 8b000c20     	add	x0, x1, x0, lsl #3
    7b74: aa1c03e2     	mov	x2, x28
    7b78: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    7b7c: d360fc21     	lsr	x1, x1, #32
    7b80: 92403c21     	and	x1, x1, #0xffff
    7b84: 91002422     	add	x2, x1, #0x9
    7b88: f862780d     	ldr	x13, [x0, x2, lsl #3]
    7b8c: f100083f     	cmp	x1, #0x2
    7b90: 540000c0     	b.eq	0x7ba8 <___pl_fn_18+0x138>
    7b94: f9400800     	ldr	x0, [x0, #0x10]
    7b98: 37482220     	tbnz	w0, #0x9, 0x7fdc <___pl_fn_18+0x56c>
    7b9c: 14000003     	b	0x7ba8 <___pl_fn_18+0x138>
    7ba0: aa1403e0     	mov	x0, x20
    7ba4: f940180d     	ldr	x13, [x0, #0x30]
    7ba8: b4001a8d     	cbz	x13, 0x7ef8 <___pl_fn_18+0x488>
    7bac: aa1c03e1     	mov	x1, x28
    7bb0: 34002281     	cbz	w1, 0x8000 <___pl_fn_18+0x590>
    7bb4: aa1403e0     	mov	x0, x20
    7bb8: f940000b     	ldr	x11, [x0]
    7bbc: aa1c03e1     	mov	x1, x28
    7bc0: 2a0103ea     	mov	w10, w1
    7bc4: 8b0a0d6a     	add	x10, x11, x10, lsl #3
    7bc8: f861596b     	ldr	x11, [x11, w1, uxtw #3]
    7bcc: d360fd6b     	lsr	x11, x11, #32
    7bd0: 92403d6b     	and	x11, x11, #0xffff
    7bd4: 9100216c     	add	x12, x11, #0x8
    7bd8: f86c7940     	ldr	x0, [x10, x12, lsl #3]
    7bdc: f100097f     	cmp	x11, #0x2
    7be0: 540000c0     	b.eq	0x7bf8 <___pl_fn_18+0x188>
    7be4: f940094d     	ldr	x13, [x10, #0x10]
    7be8: 374020cd     	tbnz	w13, #0x8, 0x8000 <___pl_fn_18+0x590>
    7bec: 14000003     	b	0x7bf8 <___pl_fn_18+0x188>
    7bf0: aa1403e0     	mov	x0, x20
    7bf4: f9401800     	ldr	x0, [x0, #0x30]
    7bf8: d37ffc01     	lsr	x1, x0, #63
    7bfc: 8b010001     	add	x1, x0, x1
    7c00: 927ff821     	and	x1, x1, #0xfffffffffffffffe
    7c04: eb01001f     	cmp	x0, x1
    7c08: 54000d60     	b.eq	0x7db4 <___pl_fn_18+0x344>
    7c0c: aa1c03e1     	mov	x1, x28
    7c10: 340020a1     	cbz	w1, 0x8024 <___pl_fn_18+0x5b4>
    7c14: aa1403e0     	mov	x0, x20
    7c18: f9400001     	ldr	x1, [x0]
    7c1c: aa1c03e0     	mov	x0, x28
    7c20: 2a0003e0     	mov	w0, w0
    7c24: 8b000c20     	add	x0, x1, x0, lsl #3
    7c28: aa1c03e2     	mov	x2, x28
    7c2c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    7c30: d360fc21     	lsr	x1, x1, #32
    7c34: 92403c21     	and	x1, x1, #0xffff
    7c38: 91002022     	add	x2, x1, #0x8
    7c3c: f862780d     	ldr	x13, [x0, x2, lsl #3]
    7c40: f100083f     	cmp	x1, #0x2
    7c44: 540000c0     	b.eq	0x7c5c <___pl_fn_18+0x1ec>
    7c48: f9400800     	ldr	x0, [x0, #0x10]
    7c4c: 37401ec0     	tbnz	w0, #0x8, 0x8024 <___pl_fn_18+0x5b4>
    7c50: 14000003     	b	0x7c5c <___pl_fn_18+0x1ec>
    7c54: aa1403e0     	mov	x0, x20
    7c58: f940180d     	ldr	x13, [x0, #0x30]
    7c5c: aa1403e0     	mov	x0, x20
    7c60: b9401813     	ldr	w19, [x0, #0x18]
    7c64: b9401c01     	ldr	w1, [x0, #0x1c]
    7c68: 11000660     	add	w0, w19, #0x1
    7c6c: 6b01001f     	cmp	w0, w1
    7c70: 54002468     	b.hi	0x80fc <___pl_fn_18+0x68c>
    7c74: aa1403ea     	mov	x10, x20
    7c78: f9401141     	ldr	x1, [x10, #0x20]
    7c7c: aa1c03eb     	mov	x11, x28
    7c80: b833582b     	str	w11, [x1, w19, uxtw #2]
    7c84: aa1403ee     	mov	x14, x20
    7c88: b90019c0     	str	w0, [x14, #0x18]
    7c8c: aa1403e0     	mov	x0, x20
    7c90: b9401000     	ldr	w0, [x0, #0x10]
    7c94: aa1403e1     	mov	x1, x20
    7c98: b9401421     	ldr	w1, [x1, #0x14]
    7c9c: 6b01001f     	cmp	w0, w1
    7ca0: 54002182     	b.hs	0x80d0 <___pl_fn_18+0x660>
    7ca4: d37ffda0     	lsr	x0, x13, #63
    7ca8: 8b0001a0     	add	x0, x13, x0
    7cac: 9341fc01     	asr	x1, x0, #1
    7cb0: d29a0102     	mov	x2, #0xd008             ; =53256
    7cb4: aa1403e0     	mov	x0, x20
    7cb8: 94000000     	bl	0x7cb8 <___pl_fn_18+0x248>
    7cbc: aa1403e1     	mov	x1, x20
    7cc0: b9402c21     	ldr	w1, [x1, #0x2c]
    7cc4: 350028e1     	cbnz	w1, 0x81e0 <___pl_fn_18+0x770>
    7cc8: aa1403e1     	mov	x1, x20
    7ccc: b9001833     	str	w19, [x1, #0x18]
    7cd0: aa1c03e1     	mov	x1, x28
    7cd4: 35000081     	cbnz	w1, 0x7ce4 <___pl_fn_18+0x274>
    7cd8: 140000dc     	b	0x8048 <___pl_fn_18+0x5d8>
    7cdc: aa1403e0     	mov	x0, x20
    7ce0: 14000013     	b	0x7d2c <___pl_fn_18+0x2bc>
    7ce4: aa1403e1     	mov	x1, x20
    7ce8: f9400022     	ldr	x2, [x1]
    7cec: aa1c03e1     	mov	x1, x28
    7cf0: 2a0103e1     	mov	w1, w1
    7cf4: 8b010c41     	add	x1, x2, x1, lsl #3
    7cf8: aa1c03e3     	mov	x3, x28
    7cfc: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    7d00: d360fc42     	lsr	x2, x2, #32
    7d04: 92403c43     	and	x3, x2, #0xffff
    7d08: f100087f     	cmp	x3, #0x2
    7d0c: 54000080     	b.eq	0x7d1c <___pl_fn_18+0x2ac>
    7d10: f9400823     	ldr	x3, [x1, #0x10]
    7d14: 9277f863     	and	x3, x3, #0xfffffffffffffeff
    7d18: f9000823     	str	x3, [x1, #0x10]
    7d1c: 92403c42     	and	x2, x2, #0xffff
    7d20: 91002042     	add	x2, x2, #0x8
    7d24: f8227820     	str	x0, [x1, x2, lsl #3]
    7d28: aa1403e0     	mov	x0, x20
    7d2c: aa1403e0     	mov	x0, x20
    7d30: b9401813     	ldr	w19, [x0, #0x18]
    7d34: b9401c01     	ldr	w1, [x0, #0x1c]
    7d38: 11000660     	add	w0, w19, #0x1
    7d3c: 6b01001f     	cmp	w0, w1
    7d40: 54001b28     	b.hi	0x80a4 <___pl_fn_18+0x634>
    7d44: aa1403e5     	mov	x5, x20
    7d48: f94010a1     	ldr	x1, [x5, #0x20]
    7d4c: aa1c03e2     	mov	x2, x28
    7d50: b8335822     	str	w2, [x1, w19, uxtw #2]
    7d54: aa1403e8     	mov	x8, x20
    7d58: b9001900     	str	w0, [x8, #0x18]
    7d5c: aa1403e0     	mov	x0, x20
    7d60: b9401001     	ldr	w1, [x0, #0x10]
    7d64: b9401402     	ldr	w2, [x0, #0x14]
    7d68: 6b02003f     	cmp	w1, w2
    7d6c: 54001862     	b.hs	0x8078 <___pl_fn_18+0x608>
    7d70: d28000c2     	mov	x2, #0x6                ; =6
    7d74: aa1c03e1     	mov	x1, x28
    7d78: aa1403e0     	mov	x0, x20
    7d7c: 94000000     	bl	0x7d7c <___pl_fn_18+0x30c>
    7d80: aa1403e1     	mov	x1, x20
    7d84: b9402c23     	ldr	w3, [x1, #0x2c]
    7d88: 350022c3     	cbnz	w3, 0x81e0 <___pl_fn_18+0x770>
    7d8c: aa1403e1     	mov	x1, x20
    7d90: b9001833     	str	w19, [x1, #0x18]
    7d94: b9401026     	ldr	w6, [x1, #0x10]
    7d98: 510004c6     	sub	w6, w6, #0x1
    7d9c: b9001026     	str	w6, [x1, #0x10]
    7da0: 9100c3ff     	add	sp, sp, #0x30
    7da4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7da8: f84107fc     	ldr	x28, [sp], #0x10
    7dac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7db0: d65f03c0     	ret
    7db4: aa1c03e1     	mov	x1, x28
    7db8: 34001b81     	cbz	w1, 0x8128 <___pl_fn_18+0x6b8>
    7dbc: aa1403e0     	mov	x0, x20
    7dc0: f940000f     	ldr	x15, [x0]
    7dc4: aa1c03e1     	mov	x1, x28
    7dc8: 2a0103ee     	mov	w14, w1
    7dcc: 8b0e0dee     	add	x14, x15, x14, lsl #3
    7dd0: f86159ef     	ldr	x15, [x15, w1, uxtw #3]
    7dd4: d360fdef     	lsr	x15, x15, #32
    7dd8: 92403def     	and	x15, x15, #0xffff
    7ddc: 910021e0     	add	x0, x15, #0x8
    7de0: f86079c7     	ldr	x7, [x14, x0, lsl #3]
    7de4: f10009ff     	cmp	x15, #0x2
    7de8: 540000c0     	b.eq	0x7e00 <___pl_fn_18+0x390>
    7dec: f94009c0     	ldr	x0, [x14, #0x10]
    7df0: 374019c0     	tbnz	w0, #0x8, 0x8128 <___pl_fn_18+0x6b8>
    7df4: 14000003     	b	0x7e00 <___pl_fn_18+0x390>
    7df8: aa1403e0     	mov	x0, x20
    7dfc: f9401807     	ldr	x7, [x0, #0x30]
    7e00: aa1c03e1     	mov	x1, x28
    7e04: 35000081     	cbnz	w1, 0x7e14 <___pl_fn_18+0x3a4>
    7e08: 140000d1     	b	0x814c <___pl_fn_18+0x6dc>
    7e0c: aa1403e0     	mov	x0, x20
    7e10: 14000016     	b	0x7e68 <___pl_fn_18+0x3f8>
    7e14: aa1403e0     	mov	x0, x20
    7e18: f9400001     	ldr	x1, [x0]
    7e1c: aa1c03e0     	mov	x0, x28
    7e20: 2a0003e0     	mov	w0, w0
    7e24: 8b000c20     	add	x0, x1, x0, lsl #3
    7e28: aa1c03e2     	mov	x2, x28
    7e2c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    7e30: d360fc21     	lsr	x1, x1, #32
    7e34: 92403c22     	and	x2, x1, #0xffff
    7e38: f100085f     	cmp	x2, #0x2
    7e3c: 54000080     	b.eq	0x7e4c <___pl_fn_18+0x3dc>
    7e40: f9400802     	ldr	x2, [x0, #0x10]
    7e44: 9277f842     	and	x2, x2, #0xfffffffffffffeff
    7e48: f9000802     	str	x2, [x0, #0x10]
    7e4c: d37ffce2     	lsr	x2, x7, #63
    7e50: 8b0200e2     	add	x2, x7, x2
    7e54: 9341fc42     	asr	x2, x2, #1
    7e58: 92403c21     	and	x1, x1, #0xffff
    7e5c: 91002021     	add	x1, x1, #0x8
    7e60: f8217802     	str	x2, [x0, x1, lsl #3]
    7e64: aa1403e0     	mov	x0, x20
    7e68: aa1403e0     	mov	x0, x20
    7e6c: b9401813     	ldr	w19, [x0, #0x18]
    7e70: b9401c01     	ldr	w1, [x0, #0x1c]
    7e74: 11000660     	add	w0, w19, #0x1
    7e78: 6b01001f     	cmp	w0, w1
    7e7c: 540019c8     	b.hi	0x81b4 <___pl_fn_18+0x744>
    7e80: aa1403e1     	mov	x1, x20
    7e84: f9401021     	ldr	x1, [x1, #0x20]
    7e88: aa1c03e2     	mov	x2, x28
    7e8c: b8335822     	str	w2, [x1, w19, uxtw #2]
    7e90: aa1403e3     	mov	x3, x20
    7e94: b9001860     	str	w0, [x3, #0x18]
    7e98: aa1403e0     	mov	x0, x20
    7e9c: b9401000     	ldr	w0, [x0, #0x10]
    7ea0: aa1403e7     	mov	x7, x20
    7ea4: b94014e1     	ldr	w1, [x7, #0x14]
    7ea8: 6b01001f     	cmp	w0, w1
    7eac: 540016e2     	b.hs	0x8188 <___pl_fn_18+0x718>
    7eb0: d28000a2     	mov	x2, #0x5                ; =5
    7eb4: aa1c03e1     	mov	x1, x28
    7eb8: aa1403e0     	mov	x0, x20
    7ebc: 94000000     	bl	0x7ebc <___pl_fn_18+0x44c>
    7ec0: aa1403ed     	mov	x13, x20
    7ec4: b9402da1     	ldr	w1, [x13, #0x2c]
    7ec8: 350018c1     	cbnz	w1, 0x81e0 <___pl_fn_18+0x770>
    7ecc: aa1403e1     	mov	x1, x20
    7ed0: b9001833     	str	w19, [x1, #0x18]
    7ed4: b9401021     	ldr	w1, [x1, #0x10]
    7ed8: 51000421     	sub	w1, w1, #0x1
    7edc: aa1403e2     	mov	x2, x20
    7ee0: b9001041     	str	w1, [x2, #0x10]
    7ee4: 9100c3ff     	add	sp, sp, #0x30
    7ee8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7eec: f84107fc     	ldr	x28, [sp], #0x10
    7ef0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7ef4: d65f03c0     	ret
    7ef8: aa1403e0     	mov	x0, x20
    7efc: b9401813     	ldr	w19, [x0, #0x18]
    7f00: b9401c01     	ldr	w1, [x0, #0x1c]
    7f04: 11000660     	add	w0, w19, #0x1
    7f08: 6b01001f     	cmp	w0, w1
    7f0c: 540018c8     	b.hi	0x8224 <___pl_fn_18+0x7b4>
    7f10: aa1403e1     	mov	x1, x20
    7f14: f9401021     	ldr	x1, [x1, #0x20]
    7f18: aa1c03e2     	mov	x2, x28
    7f1c: b8335822     	str	w2, [x1, w19, uxtw #2]
    7f20: aa1403e1     	mov	x1, x20
    7f24: b9001820     	str	w0, [x1, #0x18]
    7f28: aa1403e0     	mov	x0, x20
    7f2c: b9401000     	ldr	w0, [x0, #0x10]
    7f30: b9401421     	ldr	w1, [x1, #0x14]
    7f34: 6b01001f     	cmp	w0, w1
    7f38: 54001602     	b.hs	0x81f8 <___pl_fn_18+0x788>
    7f3c: aa1c03e1     	mov	x1, x28
    7f40: aa1403e0     	mov	x0, x20
    7f44: 94000000     	bl	0x7f44 <___pl_fn_18+0x4d4>
    7f48: aa1403e1     	mov	x1, x20
    7f4c: b9402c21     	ldr	w1, [x1, #0x2c]
    7f50: 35001481     	cbnz	w1, 0x81e0 <___pl_fn_18+0x770>
    7f54: aa1403e1     	mov	x1, x20
    7f58: b9001833     	str	w19, [x1, #0x18]
    7f5c: b9401021     	ldr	w1, [x1, #0x10]
    7f60: 51000421     	sub	w1, w1, #0x1
    7f64: aa1403e2     	mov	x2, x20
    7f68: b9001041     	str	w1, [x2, #0x10]
    7f6c: 9100c3ff     	add	sp, sp, #0x30
    7f70: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7f74: f84107fc     	ldr	x28, [sp], #0x10
    7f78: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7f7c: d65f03c0     	ret
    7f80: aa0003f4     	mov	x20, x0
    7f84: 52802461     	mov	w1, #0x123              ; =291
    7f88: 52800123     	mov	w3, #0x9                ; =9
    7f8c: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    7f90: f9400084     	ldr	x4, [x4]
    7f94: aa1403e0     	mov	x0, x20
    7f98: aa1c03e2     	mov	x2, x28
    7f9c: d63f0080     	blr	x4
    7fa0: 34ffd9e0     	cbz	w0, 0x7adc <___pl_fn_18+0x6c>
    7fa4: 1400008f     	b	0x81e0 <___pl_fn_18+0x770>
    7fa8: d2800121     	mov	x1, #0x9                ; =9
    7fac: 910003e3     	mov	x3, sp
    7fb0: f80003e1     	stur	x1, [sp]
    7fb4: f80083e0     	stur	x0, [sp, #0x8]
    7fb8: 528024a1     	mov	w1, #0x125              ; =293
    7fbc: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    7fc0: f9400084     	ldr	x4, [x4]
    7fc4: aa1403e0     	mov	x0, x20
    7fc8: aa1303e2     	mov	x2, x19
    7fcc: d63f0080     	blr	x4
    7fd0: aa1303fc     	mov	x28, x19
    7fd4: 34ffd980     	cbz	w0, 0x7b04 <___pl_fn_18+0x94>
    7fd8: 14000082     	b	0x81e0 <___pl_fn_18+0x770>
    7fdc: 528024c1     	mov	w1, #0x126              ; =294
    7fe0: 52800123     	mov	w3, #0x9                ; =9
    7fe4: 90000004     	adrp	x4, 0x7000 <___pl_fn_17+0x83c>
    7fe8: f9400084     	ldr	x4, [x4]
    7fec: aa1403e0     	mov	x0, x20
    7ff0: aa1c03e2     	mov	x2, x28
    7ff4: d63f0080     	blr	x4
    7ff8: 34ffdd40     	cbz	w0, 0x7ba0 <___pl_fn_18+0x130>
    7ffc: 14000079     	b	0x81e0 <___pl_fn_18+0x770>
    8000: 528024e1     	mov	w1, #0x127              ; =295
    8004: 52800103     	mov	w3, #0x8                ; =8
    8008: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    800c: f9400084     	ldr	x4, [x4]
    8010: aa1403e0     	mov	x0, x20
    8014: aa1c03e2     	mov	x2, x28
    8018: d63f0080     	blr	x4
    801c: 34ffdea0     	cbz	w0, 0x7bf0 <___pl_fn_18+0x180>
    8020: 14000070     	b	0x81e0 <___pl_fn_18+0x770>
    8024: 52802521     	mov	w1, #0x129              ; =297
    8028: 52800103     	mov	w3, #0x8                ; =8
    802c: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    8030: f9400084     	ldr	x4, [x4]
    8034: aa1403e0     	mov	x0, x20
    8038: aa1c03e2     	mov	x2, x28
    803c: d63f0080     	blr	x4
    8040: 34ffe0a0     	cbz	w0, 0x7c54 <___pl_fn_18+0x1e4>
    8044: 14000067     	b	0x81e0 <___pl_fn_18+0x770>
    8048: d2800101     	mov	x1, #0x8                ; =8
    804c: 910043e3     	add	x3, sp, #0x10
    8050: f80103e1     	stur	x1, [sp, #0x10]
    8054: f80183e0     	stur	x0, [sp, #0x18]
    8058: 528025c1     	mov	w1, #0x12e              ; =302
    805c: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    8060: f9400084     	ldr	x4, [x4]
    8064: aa1403e0     	mov	x0, x20
    8068: aa1c03e2     	mov	x2, x28
    806c: d63f0080     	blr	x4
    8070: 34ffe360     	cbz	w0, 0x7cdc <___pl_fn_18+0x26c>
    8074: 1400005b     	b	0x81e0 <___pl_fn_18+0x770>
    8078: 52802601     	mov	w1, #0x130              ; =304
    807c: 90000008     	adrp	x8, 0x8000 <___pl_fn_18+0x590>
    8080: f9400108     	ldr	x8, [x8]
    8084: aa1403e0     	mov	x0, x20
    8088: d63f0100     	blr	x8
    808c: 52800000     	mov	w0, #0x0                ; =0
    8090: 9100c3ff     	add	sp, sp, #0x30
    8094: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8098: f84107fc     	ldr	x28, [sp], #0x10
    809c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    80a0: d65f03c0     	ret
    80a4: 528025e1     	mov	w1, #0x12f              ; =303
    80a8: 90000009     	adrp	x9, 0x8000 <___pl_fn_18+0x590>
    80ac: f9400129     	ldr	x9, [x9]
    80b0: aa1403e0     	mov	x0, x20
    80b4: d63f0120     	blr	x9
    80b8: 52800000     	mov	w0, #0x0                ; =0
    80bc: 9100c3ff     	add	sp, sp, #0x30
    80c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    80c4: f84107fc     	ldr	x28, [sp], #0x10
    80c8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    80cc: d65f03c0     	ret
    80d0: 528025a1     	mov	w1, #0x12d              ; =301
    80d4: 9000000a     	adrp	x10, 0x8000 <___pl_fn_18+0x590>
    80d8: f940014a     	ldr	x10, [x10]
    80dc: aa1403e0     	mov	x0, x20
    80e0: d63f0140     	blr	x10
    80e4: 52800000     	mov	w0, #0x0                ; =0
    80e8: 9100c3ff     	add	sp, sp, #0x30
    80ec: a8c153f3     	ldp	x19, x20, [sp], #0x10
    80f0: f84107fc     	ldr	x28, [sp], #0x10
    80f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    80f8: d65f03c0     	ret
    80fc: 52802581     	mov	w1, #0x12c              ; =300
    8100: 9000000b     	adrp	x11, 0x8000 <___pl_fn_18+0x590>
    8104: f940016b     	ldr	x11, [x11]
    8108: aa1403e0     	mov	x0, x20
    810c: d63f0160     	blr	x11
    8110: 52800000     	mov	w0, #0x0                ; =0
    8114: 9100c3ff     	add	sp, sp, #0x30
    8118: a8c153f3     	ldp	x19, x20, [sp], #0x10
    811c: f84107fc     	ldr	x28, [sp], #0x10
    8120: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8124: d65f03c0     	ret
    8128: 52802621     	mov	w1, #0x131              ; =305
    812c: 52800103     	mov	w3, #0x8                ; =8
    8130: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    8134: f9400084     	ldr	x4, [x4]
    8138: aa1403e0     	mov	x0, x20
    813c: aa1c03e2     	mov	x2, x28
    8140: d63f0080     	blr	x4
    8144: 34ffe5a0     	cbz	w0, 0x7df8 <___pl_fn_18+0x388>
    8148: 14000026     	b	0x81e0 <___pl_fn_18+0x770>
    814c: d2800100     	mov	x0, #0x8                ; =8
    8150: 910083e3     	add	x3, sp, #0x20
    8154: f80203e0     	stur	x0, [sp, #0x20]
    8158: d37ffce0     	lsr	x0, x7, #63
    815c: 8b0000e0     	add	x0, x7, x0
    8160: 9341fc00     	asr	x0, x0, #1
    8164: f80283e0     	stur	x0, [sp, #0x28]
    8168: 52802681     	mov	w1, #0x134              ; =308
    816c: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    8170: f9400084     	ldr	x4, [x4]
    8174: aa1403e0     	mov	x0, x20
    8178: aa1c03e2     	mov	x2, x28
    817c: d63f0080     	blr	x4
    8180: 34ffe460     	cbz	w0, 0x7e0c <___pl_fn_18+0x39c>
    8184: 14000017     	b	0x81e0 <___pl_fn_18+0x770>
    8188: 528026c1     	mov	w1, #0x136              ; =310
    818c: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8190: f9400042     	ldr	x2, [x2]
    8194: aa1403e0     	mov	x0, x20
    8198: d63f0040     	blr	x2
    819c: 52800000     	mov	w0, #0x0                ; =0
    81a0: 9100c3ff     	add	sp, sp, #0x30
    81a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    81a8: f84107fc     	ldr	x28, [sp], #0x10
    81ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    81b0: d65f03c0     	ret
    81b4: 528026a1     	mov	w1, #0x135              ; =309
    81b8: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    81bc: f9400042     	ldr	x2, [x2]
    81c0: aa1403e0     	mov	x0, x20
    81c4: d63f0040     	blr	x2
    81c8: 52800000     	mov	w0, #0x0                ; =0
    81cc: 9100c3ff     	add	sp, sp, #0x30
    81d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    81d4: f84107fc     	ldr	x28, [sp], #0x10
    81d8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    81dc: d65f03c0     	ret
    81e0: 52800000     	mov	w0, #0x0                ; =0
    81e4: 9100c3ff     	add	sp, sp, #0x30
    81e8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    81ec: f84107fc     	ldr	x28, [sp], #0x10
    81f0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    81f4: d65f03c0     	ret
    81f8: 52802701     	mov	w1, #0x138              ; =312
    81fc: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8200: f9400042     	ldr	x2, [x2]
    8204: aa1403e0     	mov	x0, x20
    8208: d63f0040     	blr	x2
    820c: 52800000     	mov	w0, #0x0                ; =0
    8210: 9100c3ff     	add	sp, sp, #0x30
    8214: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8218: f84107fc     	ldr	x28, [sp], #0x10
    821c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8220: d65f03c0     	ret
    8224: 528026e1     	mov	w1, #0x137              ; =311
    8228: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    822c: f9400042     	ldr	x2, [x2]
    8230: aa1403e0     	mov	x0, x20
    8234: d63f0040     	blr	x2
    8238: 52800000     	mov	w0, #0x0                ; =0
    823c: 9100c3ff     	add	sp, sp, #0x30
    8240: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8244: f84107fc     	ldr	x28, [sp], #0x10
    8248: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    824c: d65f03c0     	ret
    8250: 52802481     	mov	w1, #0x124              ; =292
    8254: 90000003     	adrp	x3, 0x8000 <___pl_fn_18+0x590>
    8258: f9400063     	ldr	x3, [x3]
    825c: aa1403e0     	mov	x0, x20
    8260: d63f0060     	blr	x3
    8264: 52800000     	mov	w0, #0x0                ; =0
    8268: 9100c3ff     	add	sp, sp, #0x30
    826c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8270: f84107fc     	ldr	x28, [sp], #0x10
    8274: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8278: d65f03c0     	ret

000000000000827c <___pl_fn_19>:
    827c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    8280: 910003fd     	mov	x29, sp
    8284: f81f0ffb     	str	x27, [sp, #-0x10]!
    8288: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
    828c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
    8290: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    8294: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    8298: d10183ff     	sub	sp, sp, #0x60
    829c: aa0103fa     	mov	x26, x1
    82a0: aa0203fb     	mov	x27, x2
    82a4: b9401001     	ldr	w1, [x0, #0x10]
    82a8: 11000421     	add	w1, w1, #0x1
    82ac: b9001001     	str	w1, [x0, #0x10]
    82b0: aa1a03e1     	mov	x1, x26
    82b4: 34003541     	cbz	w1, 0x895c <___pl_fn_19+0x6e0>
    82b8: f9400006     	ldr	x6, [x0]
    82bc: aa1a03e1     	mov	x1, x26
    82c0: aa0003f9     	mov	x25, x0
    82c4: 2a0103e5     	mov	w5, w1
    82c8: 8b050cc5     	add	x5, x6, x5, lsl #3
    82cc: f86158c6     	ldr	x6, [x6, w1, uxtw #3]
    82d0: d360fcc6     	lsr	x6, x6, #32
    82d4: 92403cc6     	and	x6, x6, #0xffff
    82d8: 91001cc6     	add	x6, x6, #0x7
    82dc: d37df0c6     	lsl	x6, x6, #3
    82e0: b86668a2     	ldr	w2, [x5, x6]
    82e4: 35000082     	cbnz	w2, 0x82f4 <___pl_fn_19+0x78>
    82e8: 1400019e     	b	0x8960 <___pl_fn_19+0x6e4>
    82ec: aa1903e0     	mov	x0, x25
    82f0: f9401802     	ldr	x2, [x0, #0x30]
    82f4: 34003482     	cbz	w2, 0x8984 <___pl_fn_19+0x708>
    82f8: aa1903e0     	mov	x0, x25
    82fc: f940000e     	ldr	x14, [x0]
    8300: 2a0203ed     	mov	w13, w2
    8304: 8b0d0dcd     	add	x13, x14, x13, lsl #3
    8308: f86259ce     	ldr	x14, [x14, w2, uxtw #3]
    830c: d360fdce     	lsr	x14, x14, #32
    8310: 92403dce     	and	x14, x14, #0xffff
    8314: 910009ce     	add	x14, x14, #0x2
    8318: d37df1ce     	lsl	x14, x14, #3
    831c: b86e69a0     	ldr	w0, [x13, x14]
    8320: 350000c0     	cbnz	w0, 0x8338 <___pl_fn_19+0xbc>
    8324: 14000198     	b	0x8984 <___pl_fn_19+0x708>
    8328: aa1903e0     	mov	x0, x25
    832c: f9401800     	ldr	x0, [x0, #0x30]
    8330: aa1b03e2     	mov	x2, x27
    8334: 14000002     	b	0x833c <___pl_fn_19+0xc0>
    8338: aa1b03e2     	mov	x2, x27
    833c: 6b00005f     	cmp	w2, w0
    8340: aa0203fb     	mov	x27, x2
    8344: 54002c00     	b.eq	0x88c4 <___pl_fn_19+0x648>
    8348: aa1a03f3     	mov	x19, x26
    834c: 340032d3     	cbz	w19, 0x89a4 <___pl_fn_19+0x728>
    8350: aa1903e0     	mov	x0, x25
    8354: f9400001     	ldr	x1, [x0]
    8358: 2a1303e0     	mov	w0, w19
    835c: 8b000c20     	add	x0, x1, x0, lsl #3
    8360: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    8364: d360fc21     	lsr	x1, x1, #32
    8368: 92403c21     	and	x1, x1, #0xffff
    836c: 91002022     	add	x2, x1, #0x8
    8370: f8627803     	ldr	x3, [x0, x2, lsl #3]
    8374: f100083f     	cmp	x1, #0x2
    8378: 54000061     	b.ne	0x8384 <___pl_fn_19+0x108>
    837c: aa1303fa     	mov	x26, x19
    8380: 14000007     	b	0x839c <___pl_fn_19+0x120>
    8384: f9400800     	ldr	x0, [x0, #0x10]
    8388: 374030e0     	tbnz	w0, #0x8, 0x89a4 <___pl_fn_19+0x728>
    838c: aa1303fa     	mov	x26, x19
    8390: 14000003     	b	0x839c <___pl_fn_19+0x120>
    8394: aa1903e0     	mov	x0, x25
    8398: f9401803     	ldr	x3, [x0, #0x30]
    839c: d2800074     	mov	x20, #0x3               ; =3
    83a0: f1000c7f     	cmp	x3, #0x3
    83a4: 540002c0     	b.eq	0x83fc <___pl_fn_19+0x180>
    83a8: aa1a03e1     	mov	x1, x26
    83ac: 34003101     	cbz	w1, 0x89cc <___pl_fn_19+0x750>
    83b0: aa1903e0     	mov	x0, x25
    83b4: f9400001     	ldr	x1, [x0]
    83b8: aa1a03e0     	mov	x0, x26
    83bc: 2a0003e0     	mov	w0, w0
    83c0: 8b000c20     	add	x0, x1, x0, lsl #3
    83c4: aa1a03e2     	mov	x2, x26
    83c8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    83cc: d360fc21     	lsr	x1, x1, #32
    83d0: 92403c22     	and	x2, x1, #0xffff
    83d4: f100085f     	cmp	x2, #0x2
    83d8: 54000080     	b.eq	0x83e8 <___pl_fn_19+0x16c>
    83dc: f9400802     	ldr	x2, [x0, #0x10]
    83e0: 9277f842     	and	x2, x2, #0xfffffffffffffeff
    83e4: f9000802     	str	x2, [x0, #0x10]
    83e8: 92403c21     	and	x1, x1, #0xffff
    83ec: 91002021     	add	x1, x1, #0x8
    83f0: f8217814     	str	x20, [x0, x1, lsl #3]
    83f4: aa1a03e1     	mov	x1, x26
    83f8: 14000016     	b	0x8450 <___pl_fn_19+0x1d4>
    83fc: aa1a03e1     	mov	x1, x26
    8400: 34002fe1     	cbz	w1, 0x89fc <___pl_fn_19+0x780>
    8404: aa1903e0     	mov	x0, x25
    8408: f9400001     	ldr	x1, [x0]
    840c: aa1a03e9     	mov	x9, x26
    8410: 2a0903e0     	mov	w0, w9
    8414: 8b000c20     	add	x0, x1, x0, lsl #3
    8418: aa1a03ec     	mov	x12, x26
    841c: f86c5821     	ldr	x1, [x1, w12, uxtw #3]
    8420: d360fc21     	lsr	x1, x1, #32
    8424: 92403c22     	and	x2, x1, #0xffff
    8428: f100085f     	cmp	x2, #0x2
    842c: 54000080     	b.eq	0x843c <___pl_fn_19+0x1c0>
    8430: f9400802     	ldr	x2, [x0, #0x10]
    8434: 9277f842     	and	x2, x2, #0xfffffffffffffeff
    8438: f9000802     	str	x2, [x0, #0x10]
    843c: d2800082     	mov	x2, #0x4                ; =4
    8440: 92403c21     	and	x1, x1, #0xffff
    8444: 91002021     	add	x1, x1, #0x8
    8448: f8217802     	str	x2, [x0, x1, lsl #3]
    844c: aa1a03e1     	mov	x1, x26
    8450: aa1a03e1     	mov	x1, x26
    8454: 34002ee1     	cbz	w1, 0x8a30 <___pl_fn_19+0x7b4>
    8458: aa1903e0     	mov	x0, x25
    845c: f9400004     	ldr	x4, [x0]
    8460: aa1a03e1     	mov	x1, x26
    8464: 2a0103e3     	mov	w3, w1
    8468: 8b030c83     	add	x3, x4, x3, lsl #3
    846c: f8615884     	ldr	x4, [x4, w1, uxtw #3]
    8470: d360fc84     	lsr	x4, x4, #32
    8474: 92403c84     	and	x4, x4, #0xffff
    8478: 91002085     	add	x5, x4, #0x8
    847c: f8657860     	ldr	x0, [x3, x5, lsl #3]
    8480: f100089f     	cmp	x4, #0x2
    8484: 54000100     	b.eq	0x84a4 <___pl_fn_19+0x228>
    8488: f9400866     	ldr	x6, [x3, #0x10]
    848c: 37402d26     	tbnz	w6, #0x8, 0x8a30 <___pl_fn_19+0x7b4>
    8490: 14000005     	b	0x84a4 <___pl_fn_19+0x228>
    8494: aa1903e0     	mov	x0, x25
    8498: f9401800     	ldr	x0, [x0, #0x30]
    849c: aa1b03e2     	mov	x2, x27
    84a0: 14000002     	b	0x84a8 <___pl_fn_19+0x22c>
    84a4: aa1b03e2     	mov	x2, x27
    84a8: 35000082     	cbnz	w2, 0x84b8 <___pl_fn_19+0x23c>
    84ac: 1400016a     	b	0x8a54 <___pl_fn_19+0x7d8>
    84b0: aa1b03e2     	mov	x2, x27
    84b4: 14000013     	b	0x8500 <___pl_fn_19+0x284>
    84b8: aa1903e2     	mov	x2, x25
    84bc: f9400042     	ldr	x2, [x2]
    84c0: aa1b03e1     	mov	x1, x27
    84c4: 2a0103e1     	mov	w1, w1
    84c8: 8b010c41     	add	x1, x2, x1, lsl #3
    84cc: aa1b03e3     	mov	x3, x27
    84d0: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    84d4: d360fc42     	lsr	x2, x2, #32
    84d8: 92403c43     	and	x3, x2, #0xffff
    84dc: f100087f     	cmp	x3, #0x2
    84e0: 54000080     	b.eq	0x84f0 <___pl_fn_19+0x274>
    84e4: f9400823     	ldr	x3, [x1, #0x10]
    84e8: 927ef863     	and	x3, x3, #0xfffffffffffffffd
    84ec: f9000823     	str	x3, [x1, #0x10]
    84f0: 92403c42     	and	x2, x2, #0xffff
    84f4: 91000442     	add	x2, x2, #0x1
    84f8: f8227820     	str	x0, [x1, x2, lsl #3]
    84fc: aa1b03e2     	mov	x2, x27
    8500: aa1b03e2     	mov	x2, x27
    8504: 34002c02     	cbz	w2, 0x8a84 <___pl_fn_19+0x808>
    8508: aa1903e0     	mov	x0, x25
    850c: f9400001     	ldr	x1, [x0]
    8510: aa1b03e2     	mov	x2, x27
    8514: 2a0203e0     	mov	w0, w2
    8518: 8b000c20     	add	x0, x1, x0, lsl #3
    851c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    8520: d360fc21     	lsr	x1, x1, #32
    8524: 92403c22     	and	x2, x1, #0xffff
    8528: f100085f     	cmp	x2, #0x2
    852c: 54000080     	b.eq	0x853c <___pl_fn_19+0x2c0>
    8530: f9400802     	ldr	x2, [x0, #0x10]
    8534: 927cf842     	and	x2, x2, #0xfffffffffffffff7
    8538: f9000802     	str	x2, [x0, #0x10]
    853c: d2800002     	mov	x2, #0x0                ; =0
    8540: 92403c21     	and	x1, x1, #0xffff
    8544: 91000c21     	add	x1, x1, #0x3
    8548: f8217802     	str	x2, [x0, x1, lsl #3]
    854c: d2800013     	mov	x19, #0x0               ; =0
    8550: ab130294     	adds	x20, x20, x19
    8554: 9a9f77e0     	cset	x0, vs
    8558: 72001c1f     	tst	w0, #0xff
    855c: 54004461     	b.ne	0x8de8 <___pl_fn_19+0xb6c>
    8560: d2800035     	mov	x21, #0x1               ; =1
    8564: ab1302b6     	adds	x22, x21, x19
    8568: 9a9f77e0     	cset	x0, vs
    856c: 72001c1f     	tst	w0, #0xff
    8570: 54004201     	b.ne	0x8db0 <___pl_fn_19+0xb34>
    8574: b4004036     	cbz	x22, 0x8d78 <___pl_fn_19+0xafc>
    8578: 52800037     	mov	w23, #0x1               ; =1
    857c: f10002df     	cmp	x22, #0x0
    8580: 5400008a     	b.ge	0x8590 <___pl_fn_19+0x314>
    8584: eb14027f     	cmp	x19, x20
    8588: 9a9fb7e0     	cset	x0, ge
    858c: 14000003     	b	0x8598 <___pl_fn_19+0x31c>
    8590: eb14027f     	cmp	x19, x20
    8594: 9a9fc7e0     	cset	x0, le
    8598: 72001c1f     	tst	w0, #0xff
    859c: 54000581     	b.ne	0x864c <___pl_fn_19+0x3d0>
    85a0: aa1903e0     	mov	x0, x25
    85a4: b9401813     	ldr	w19, [x0, #0x18]
    85a8: b9401c00     	ldr	w0, [x0, #0x1c]
    85ac: 11000a61     	add	w1, w19, #0x2
    85b0: 6b00003f     	cmp	w1, w0
    85b4: 540029c8     	b.hi	0x8aec <___pl_fn_19+0x870>
    85b8: aa1903e0     	mov	x0, x25
    85bc: f9401000     	ldr	x0, [x0, #0x20]
    85c0: 2a1303e1     	mov	w1, w19
    85c4: 8b010801     	add	x1, x0, x1, lsl #2
    85c8: aa1a03e2     	mov	x2, x26
    85cc: b8335802     	str	w2, [x0, w19, uxtw #2]
    85d0: aa1b03e2     	mov	x2, x27
    85d4: b9000422     	str	w2, [x1, #0x4]
    85d8: 11000a60     	add	w0, w19, #0x2
    85dc: aa1903e1     	mov	x1, x25
    85e0: b9001820     	str	w0, [x1, #0x18]
    85e4: aa1903e0     	mov	x0, x25
    85e8: b9401000     	ldr	w0, [x0, #0x10]
    85ec: b9401421     	ldr	w1, [x1, #0x14]
    85f0: 6b01001f     	cmp	w0, w1
    85f4: 54002602     	b.hs	0x8ab4 <___pl_fn_19+0x838>
    85f8: aa1a03e1     	mov	x1, x26
    85fc: aa1b03e2     	mov	x2, x27
    8600: aa1903e0     	mov	x0, x25
    8604: 94000000     	bl	0x8604 <___pl_fn_19+0x388>
    8608: aa1903e1     	mov	x1, x25
    860c: b9402c21     	ldr	w1, [x1, #0x2c]
    8610: 35004081     	cbnz	w1, 0x8e20 <___pl_fn_19+0xba4>
    8614: aa1903e1     	mov	x1, x25
    8618: b9001833     	str	w19, [x1, #0x18]
    861c: b9401021     	ldr	w1, [x1, #0x10]
    8620: 51000421     	sub	w1, w1, #0x1
    8624: aa1903e2     	mov	x2, x25
    8628: b9001041     	str	w1, [x2, #0x10]
    862c: 910183ff     	add	sp, sp, #0x60
    8630: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8634: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8638: a8c163f7     	ldp	x23, x24, [sp], #0x10
    863c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8640: f84107fb     	ldr	x27, [sp], #0x10
    8644: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8648: d65f03c0     	ret
    864c: aa1a03e1     	mov	x1, x26
    8650: 340026a1     	cbz	w1, 0x8b24 <___pl_fn_19+0x8a8>
    8654: aa1903e0     	mov	x0, x25
    8658: f9400007     	ldr	x7, [x0]
    865c: aa1a03e1     	mov	x1, x26
    8660: 2a0103e6     	mov	w6, w1
    8664: 8b060ce6     	add	x6, x7, x6, lsl #3
    8668: f86158e7     	ldr	x7, [x7, w1, uxtw #3]
    866c: d360fce7     	lsr	x7, x7, #32
    8670: 92403ce7     	and	x7, x7, #0xffff
    8674: 910024e8     	add	x8, x7, #0x9
    8678: f86878c0     	ldr	x0, [x6, x8, lsl #3]
    867c: f10008ff     	cmp	x7, #0x2
    8680: 540000c0     	b.eq	0x8698 <___pl_fn_19+0x41c>
    8684: f94008c9     	ldr	x9, [x6, #0x10]
    8688: 374824e9     	tbnz	w9, #0x9, 0x8b24 <___pl_fn_19+0x8a8>
    868c: 14000003     	b	0x8698 <___pl_fn_19+0x41c>
    8690: aa1903e0     	mov	x0, x25
    8694: f9401800     	ldr	x0, [x0, #0x30]
    8698: ab15000f     	adds	x15, x0, x21
    869c: 9a9f77e0     	cset	x0, vs
    86a0: 72001c1f     	tst	w0, #0xff
    86a4: 540034e1     	b.ne	0x8d40 <___pl_fn_19+0xac4>
    86a8: aa1a03e1     	mov	x1, x26
    86ac: 35000081     	cbnz	w1, 0x86bc <___pl_fn_19+0x440>
    86b0: 14000126     	b	0x8b48 <___pl_fn_19+0x8cc>
    86b4: aa1a03e1     	mov	x1, x26
    86b8: 14000013     	b	0x8704 <___pl_fn_19+0x488>
    86bc: aa1903e0     	mov	x0, x25
    86c0: f9400001     	ldr	x1, [x0]
    86c4: aa1a03e0     	mov	x0, x26
    86c8: 2a0003e0     	mov	w0, w0
    86cc: 8b000c20     	add	x0, x1, x0, lsl #3
    86d0: aa1a03e2     	mov	x2, x26
    86d4: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    86d8: d360fc21     	lsr	x1, x1, #32
    86dc: 92403c22     	and	x2, x1, #0xffff
    86e0: f100085f     	cmp	x2, #0x2
    86e4: 54000080     	b.eq	0x86f4 <___pl_fn_19+0x478>
    86e8: f9400802     	ldr	x2, [x0, #0x10]
    86ec: 9276f842     	and	x2, x2, #0xfffffffffffffdff
    86f0: f9000802     	str	x2, [x0, #0x10]
    86f4: 92403c21     	and	x1, x1, #0xffff
    86f8: 91002421     	add	x1, x1, #0x9
    86fc: f821780f     	str	x15, [x0, x1, lsl #3]
    8700: aa1a03e1     	mov	x1, x26
    8704: aa1a03e1     	mov	x1, x26
    8708: 34002381     	cbz	w1, 0x8b78 <___pl_fn_19+0x8fc>
    870c: aa1903e0     	mov	x0, x25
    8710: f9400000     	ldr	x0, [x0]
    8714: aa1a03e1     	mov	x1, x26
    8718: 2a0103e1     	mov	w1, w1
    871c: 8b010c01     	add	x1, x0, x1, lsl #3
    8720: aa1a03e2     	mov	x2, x26
    8724: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    8728: d360fc00     	lsr	x0, x0, #32
    872c: 92403c02     	and	x2, x0, #0xffff
    8730: 91002440     	add	x0, x2, #0x9
    8734: f8607820     	ldr	x0, [x1, x0, lsl #3]
    8738: f100085f     	cmp	x2, #0x2
    873c: 540000c0     	b.eq	0x8754 <___pl_fn_19+0x4d8>
    8740: f9400821     	ldr	x1, [x1, #0x10]
    8744: 374821a1     	tbnz	w1, #0x9, 0x8b78 <___pl_fn_19+0x8fc>
    8748: 14000003     	b	0x8754 <___pl_fn_19+0x4d8>
    874c: aa1903e0     	mov	x0, x25
    8750: f9401800     	ldr	x0, [x0, #0x30]
    8754: f100681f     	cmp	x0, #0x1a
    8758: 5400006c     	b.gt	0x8764 <___pl_fn_19+0x4e8>
    875c: aa1a03e1     	mov	x1, x26
    8760: 14000015     	b	0x87b4 <___pl_fn_19+0x538>
    8764: aa1a03e1     	mov	x1, x26
    8768: 340021a1     	cbz	w1, 0x8b9c <___pl_fn_19+0x920>
    876c: aa1903e0     	mov	x0, x25
    8770: f9400001     	ldr	x1, [x0]
    8774: aa1a03e0     	mov	x0, x26
    8778: 2a0003e0     	mov	w0, w0
    877c: 8b000c20     	add	x0, x1, x0, lsl #3
    8780: aa1a03e2     	mov	x2, x26
    8784: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    8788: d360fc21     	lsr	x1, x1, #32
    878c: 92403c22     	and	x2, x1, #0xffff
    8790: f100085f     	cmp	x2, #0x2
    8794: 54000080     	b.eq	0x87a4 <___pl_fn_19+0x528>
    8798: f9400802     	ldr	x2, [x0, #0x10]
    879c: 9276f842     	and	x2, x2, #0xfffffffffffffdff
    87a0: f9000802     	str	x2, [x0, #0x10]
    87a4: 92403c21     	and	x1, x1, #0xffff
    87a8: 91002421     	add	x1, x1, #0x9
    87ac: f8217815     	str	x21, [x0, x1, lsl #3]
    87b0: aa1a03e1     	mov	x1, x26
    87b4: aa1a03e1     	mov	x1, x26
    87b8: 340020a1     	cbz	w1, 0x8bcc <___pl_fn_19+0x950>
    87bc: aa1903e0     	mov	x0, x25
    87c0: f9400000     	ldr	x0, [x0]
    87c4: aa1a03e1     	mov	x1, x26
    87c8: 2a0103e1     	mov	w1, w1
    87cc: 8b010c01     	add	x1, x0, x1, lsl #3
    87d0: aa1a03e2     	mov	x2, x26
    87d4: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    87d8: d360fc00     	lsr	x0, x0, #32
    87dc: 92403c02     	and	x2, x0, #0xffff
    87e0: 91002440     	add	x0, x2, #0x9
    87e4: f8607820     	ldr	x0, [x1, x0, lsl #3]
    87e8: f100085f     	cmp	x2, #0x2
    87ec: 540000c0     	b.eq	0x8804 <___pl_fn_19+0x588>
    87f0: f9400822     	ldr	x2, [x1, #0x10]
    87f4: 37481ec2     	tbnz	w2, #0x9, 0x8bcc <___pl_fn_19+0x950>
    87f8: 14000003     	b	0x8804 <___pl_fn_19+0x588>
    87fc: aa1903e0     	mov	x0, x25
    8800: f9401800     	ldr	x0, [x0, #0x30]
    8804: d2800829     	mov	x9, #0x41               ; =65
    8808: ab000128     	adds	x8, x9, x0
    880c: 9a9f77ea     	cset	x10, vs
    8810: 72001d5f     	tst	w10, #0xff
    8814: 540027a1     	b.ne	0x8d08 <___pl_fn_19+0xa8c>
    8818: eb150103     	subs	x3, x8, x21
    881c: 9a9f77ec     	cset	x12, vs
    8820: 72001d9f     	tst	w12, #0xff
    8824: 54002561     	b.ne	0x8cd0 <___pl_fn_19+0xa54>
    8828: aa1903e0     	mov	x0, x25
    882c: b9401818     	ldr	w24, [x0, #0x18]
    8830: b9401c0d     	ldr	w13, [x0, #0x1c]
    8834: 11000b0e     	add	w14, w24, #0x2
    8838: 6b0d01df     	cmp	w14, w13
    883c: 540022e8     	b.hi	0x8c98 <___pl_fn_19+0xa1c>
    8840: aa1903e0     	mov	x0, x25
    8844: f940100f     	ldr	x15, [x0, #0x20]
    8848: 2a1803e0     	mov	w0, w24
    884c: 8b0009e0     	add	x0, x15, x0, lsl #2
    8850: aa1a03e1     	mov	x1, x26
    8854: b83859e1     	str	w1, [x15, w24, uxtw #2]
    8858: aa1b03e2     	mov	x2, x27
    885c: b9000402     	str	w2, [x0, #0x4]
    8860: 11000b00     	add	w0, w24, #0x2
    8864: aa1903e1     	mov	x1, x25
    8868: b9001820     	str	w0, [x1, #0x18]
    886c: aa1903e0     	mov	x0, x25
    8870: b9401000     	ldr	w0, [x0, #0x10]
    8874: b9401421     	ldr	w1, [x1, #0x14]
    8878: 6b01001f     	cmp	w0, w1
    887c: 54001f22     	b.hs	0x8c60 <___pl_fn_19+0x9e4>
    8880: 72001eff     	tst	w23, #0xff
    8884: 54001d20     	b.eq	0x8c28 <___pl_fn_19+0x9ac>
    8888: aa1903e0     	mov	x0, x25
    888c: aa1b03e1     	mov	x1, x27
    8890: aa1303e2     	mov	x2, x19
    8894: 94000000     	bl	0x8894 <___pl_fn_19+0x618>
    8898: aa1903e0     	mov	x0, x25
    889c: b9402c00     	ldr	w0, [x0, #0x2c]
    88a0: 35002c00     	cbnz	w0, 0x8e20 <___pl_fn_19+0xba4>
    88a4: aa1903e0     	mov	x0, x25
    88a8: b9001818     	str	w24, [x0, #0x18]
    88ac: ab160273     	adds	x19, x19, x22
    88b0: 9a9f77e0     	cset	x0, vs
    88b4: 72001c1f     	tst	w0, #0xff
    88b8: 540019c1     	b.ne	0x8bf0 <___pl_fn_19+0x974>
    88bc: 52800037     	mov	w23, #0x1               ; =1
    88c0: 17ffff2f     	b	0x857c <___pl_fn_19+0x300>
    88c4: aa1903e0     	mov	x0, x25
    88c8: b9401813     	ldr	w19, [x0, #0x18]
    88cc: b9401c01     	ldr	w1, [x0, #0x1c]
    88d0: 11000660     	add	w0, w19, #0x1
    88d4: 6b01001f     	cmp	w0, w1
    88d8: 54002d28     	b.hi	0x8e7c <___pl_fn_19+0xc00>
    88dc: aa1903e5     	mov	x5, x25
    88e0: f94010a1     	ldr	x1, [x5, #0x20]
    88e4: aa1a03e2     	mov	x2, x26
    88e8: b8335822     	str	w2, [x1, w19, uxtw #2]
    88ec: aa1903e8     	mov	x8, x25
    88f0: b9001900     	str	w0, [x8, #0x18]
    88f4: aa1903e0     	mov	x0, x25
    88f8: b9401000     	ldr	w0, [x0, #0x10]
    88fc: aa1903ec     	mov	x12, x25
    8900: b9401581     	ldr	w1, [x12, #0x14]
    8904: 6b01001f     	cmp	w0, w1
    8908: 540029e2     	b.hs	0x8e44 <___pl_fn_19+0xbc8>
    890c: aa1a03e1     	mov	x1, x26
    8910: aa1903e0     	mov	x0, x25
    8914: 94000000     	bl	0x8914 <___pl_fn_19+0x698>
    8918: aa1903e1     	mov	x1, x25
    891c: b9402c21     	ldr	w1, [x1, #0x2c]
    8920: 35002801     	cbnz	w1, 0x8e20 <___pl_fn_19+0xba4>
    8924: aa1903e1     	mov	x1, x25
    8928: b9001833     	str	w19, [x1, #0x18]
    892c: b9401021     	ldr	w1, [x1, #0x10]
    8930: 51000421     	sub	w1, w1, #0x1
    8934: aa1903e2     	mov	x2, x25
    8938: b9001041     	str	w1, [x2, #0x10]
    893c: 910183ff     	add	sp, sp, #0x60
    8940: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8944: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8948: a8c163f7     	ldp	x23, x24, [sp], #0x10
    894c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8950: f84107fb     	ldr	x27, [sp], #0x10
    8954: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8958: d65f03c0     	ret
    895c: aa0003f9     	mov	x25, x0
    8960: 52802721     	mov	w1, #0x139              ; =313
    8964: 528000e3     	mov	w3, #0x7                ; =7
    8968: 90000007     	adrp	x7, 0x8000 <___pl_fn_18+0x590>
    896c: f94000e7     	ldr	x7, [x7]
    8970: aa1903e0     	mov	x0, x25
    8974: aa1a03e2     	mov	x2, x26
    8978: d63f00e0     	blr	x7
    897c: 34ffcb80     	cbz	w0, 0x82ec <___pl_fn_19+0x70>
    8980: 14000128     	b	0x8e20 <___pl_fn_19+0xba4>
    8984: 52802741     	mov	w1, #0x13a              ; =314
    8988: 52800043     	mov	w3, #0x2                ; =2
    898c: 9000000f     	adrp	x15, 0x8000 <___pl_fn_18+0x590>
    8990: f94001ef     	ldr	x15, [x15]
    8994: aa1903e0     	mov	x0, x25
    8998: d63f01e0     	blr	x15
    899c: 34ffcc60     	cbz	w0, 0x8328 <___pl_fn_19+0xac>
    89a0: 14000120     	b	0x8e20 <___pl_fn_19+0xba4>
    89a4: 52802761     	mov	w1, #0x13b              ; =315
    89a8: 52800103     	mov	w3, #0x8                ; =8
    89ac: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    89b0: f9400084     	ldr	x4, [x4]
    89b4: aa1903e0     	mov	x0, x25
    89b8: aa1303e2     	mov	x2, x19
    89bc: d63f0080     	blr	x4
    89c0: aa1303fa     	mov	x26, x19
    89c4: 34ffce80     	cbz	w0, 0x8394 <___pl_fn_19+0x118>
    89c8: 14000116     	b	0x8e20 <___pl_fn_19+0xba4>
    89cc: d2800100     	mov	x0, #0x8                ; =8
    89d0: 910003e3     	mov	x3, sp
    89d4: f80003e0     	stur	x0, [sp]
    89d8: f80083f4     	stur	x20, [sp, #0x8]
    89dc: 52802781     	mov	w1, #0x13c              ; =316
    89e0: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    89e4: f9400084     	ldr	x4, [x4]
    89e8: aa1903e0     	mov	x0, x25
    89ec: aa1a03e2     	mov	x2, x26
    89f0: d63f0080     	blr	x4
    89f4: 34ffd000     	cbz	w0, 0x83f4 <___pl_fn_19+0x178>
    89f8: 1400010a     	b	0x8e20 <___pl_fn_19+0xba4>
    89fc: d2800100     	mov	x0, #0x8                ; =8
    8a00: 910043e3     	add	x3, sp, #0x10
    8a04: f80103e0     	stur	x0, [sp, #0x10]
    8a08: d2800080     	mov	x0, #0x4                ; =4
    8a0c: f80183e0     	stur	x0, [sp, #0x18]
    8a10: 528027a1     	mov	w1, #0x13d              ; =317
    8a14: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    8a18: f9400084     	ldr	x4, [x4]
    8a1c: aa1903e0     	mov	x0, x25
    8a20: aa1a03e2     	mov	x2, x26
    8a24: d63f0080     	blr	x4
    8a28: 34ffd120     	cbz	w0, 0x844c <___pl_fn_19+0x1d0>
    8a2c: 140000fd     	b	0x8e20 <___pl_fn_19+0xba4>
    8a30: 528027c1     	mov	w1, #0x13e              ; =318
    8a34: 52800103     	mov	w3, #0x8                ; =8
    8a38: 90000009     	adrp	x9, 0x8000 <___pl_fn_18+0x590>
    8a3c: f9400129     	ldr	x9, [x9]
    8a40: aa1903e0     	mov	x0, x25
    8a44: aa1a03e2     	mov	x2, x26
    8a48: d63f0120     	blr	x9
    8a4c: 34ffd240     	cbz	w0, 0x8494 <___pl_fn_19+0x218>
    8a50: 140000f4     	b	0x8e20 <___pl_fn_19+0xba4>
    8a54: d280002e     	mov	x14, #0x1               ; =1
    8a58: 910083e3     	add	x3, sp, #0x20
    8a5c: f80203ee     	stur	x14, [sp, #0x20]
    8a60: f80283e0     	stur	x0, [sp, #0x28]
    8a64: 528027e1     	mov	w1, #0x13f              ; =319
    8a68: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    8a6c: f9400084     	ldr	x4, [x4]
    8a70: aa1903e0     	mov	x0, x25
    8a74: aa1b03e2     	mov	x2, x27
    8a78: d63f0080     	blr	x4
    8a7c: 34ffd1a0     	cbz	w0, 0x84b0 <___pl_fn_19+0x234>
    8a80: 140000e8     	b	0x8e20 <___pl_fn_19+0xba4>
    8a84: 9100c3e3     	add	x3, sp, #0x30
    8a88: f80303f4     	stur	x20, [sp, #0x30]
    8a8c: d2800000     	mov	x0, #0x0                ; =0
    8a90: f80383e0     	stur	x0, [sp, #0x38]
    8a94: 52802801     	mov	w1, #0x140              ; =320
    8a98: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    8a9c: f9400084     	ldr	x4, [x4]
    8aa0: aa1903e0     	mov	x0, x25
    8aa4: aa1b03e2     	mov	x2, x27
    8aa8: d63f0080     	blr	x4
    8aac: 34ffd500     	cbz	w0, 0x854c <___pl_fn_19+0x2d0>
    8ab0: 140000dc     	b	0x8e20 <___pl_fn_19+0xba4>
    8ab4: 528028a1     	mov	w1, #0x145              ; =325
    8ab8: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8abc: f9400042     	ldr	x2, [x2]
    8ac0: aa1903e0     	mov	x0, x25
    8ac4: d63f0040     	blr	x2
    8ac8: 52800000     	mov	w0, #0x0                ; =0
    8acc: 910183ff     	add	sp, sp, #0x60
    8ad0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8ad4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8ad8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8adc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8ae0: f84107fb     	ldr	x27, [sp], #0x10
    8ae4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8ae8: d65f03c0     	ret
    8aec: 52802881     	mov	w1, #0x144              ; =324
    8af0: 90000003     	adrp	x3, 0x8000 <___pl_fn_18+0x590>
    8af4: f9400063     	ldr	x3, [x3]
    8af8: aa1903e0     	mov	x0, x25
    8afc: d63f0060     	blr	x3
    8b00: 52800000     	mov	w0, #0x0                ; =0
    8b04: 910183ff     	add	sp, sp, #0x60
    8b08: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8b0c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8b10: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8b14: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8b18: f84107fb     	ldr	x27, [sp], #0x10
    8b1c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8b20: d65f03c0     	ret
    8b24: 528028c1     	mov	w1, #0x146              ; =326
    8b28: 52800123     	mov	w3, #0x9                ; =9
    8b2c: 9000000c     	adrp	x12, 0x8000 <___pl_fn_18+0x590>
    8b30: f940018c     	ldr	x12, [x12]
    8b34: aa1903e0     	mov	x0, x25
    8b38: aa1a03e2     	mov	x2, x26
    8b3c: d63f0180     	blr	x12
    8b40: 34ffda80     	cbz	w0, 0x8690 <___pl_fn_19+0x414>
    8b44: 140000b7     	b	0x8e20 <___pl_fn_19+0xba4>
    8b48: d2800120     	mov	x0, #0x9                ; =9
    8b4c: 910103e3     	add	x3, sp, #0x40
    8b50: f80403e0     	stur	x0, [sp, #0x40]
    8b54: f80483ef     	stur	x15, [sp, #0x48]
    8b58: 52802901     	mov	w1, #0x148              ; =328
    8b5c: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    8b60: f9400084     	ldr	x4, [x4]
    8b64: aa1903e0     	mov	x0, x25
    8b68: aa1a03e2     	mov	x2, x26
    8b6c: d63f0080     	blr	x4
    8b70: 34ffda20     	cbz	w0, 0x86b4 <___pl_fn_19+0x438>
    8b74: 140000ab     	b	0x8e20 <___pl_fn_19+0xba4>
    8b78: 52802921     	mov	w1, #0x149              ; =329
    8b7c: 52800123     	mov	w3, #0x9                ; =9
    8b80: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    8b84: f9400084     	ldr	x4, [x4]
    8b88: aa1903e0     	mov	x0, x25
    8b8c: aa1a03e2     	mov	x2, x26
    8b90: d63f0080     	blr	x4
    8b94: 34ffddc0     	cbz	w0, 0x874c <___pl_fn_19+0x4d0>
    8b98: 140000a2     	b	0x8e20 <___pl_fn_19+0xba4>
    8b9c: d2800120     	mov	x0, #0x9                ; =9
    8ba0: 910143e3     	add	x3, sp, #0x50
    8ba4: f80503e0     	stur	x0, [sp, #0x50]
    8ba8: f80583f5     	stur	x21, [sp, #0x58]
    8bac: 52802941     	mov	w1, #0x14a              ; =330
    8bb0: 90000004     	adrp	x4, 0x8000 <___pl_fn_18+0x590>
    8bb4: f9400084     	ldr	x4, [x4]
    8bb8: aa1903e0     	mov	x0, x25
    8bbc: aa1a03e2     	mov	x2, x26
    8bc0: d63f0080     	blr	x4
    8bc4: 34ffdf60     	cbz	w0, 0x87b0 <___pl_fn_19+0x534>
    8bc8: 14000096     	b	0x8e20 <___pl_fn_19+0xba4>
    8bcc: 52802961     	mov	w1, #0x14b              ; =331
    8bd0: 52800123     	mov	w3, #0x9                ; =9
    8bd4: 90000005     	adrp	x5, 0x8000 <___pl_fn_18+0x590>
    8bd8: f94000a5     	ldr	x5, [x5]
    8bdc: aa1903e0     	mov	x0, x25
    8be0: aa1a03e2     	mov	x2, x26
    8be4: d63f00a0     	blr	x5
    8be8: 34ffe0a0     	cbz	w0, 0x87fc <___pl_fn_19+0x580>
    8bec: 1400008d     	b	0x8e20 <___pl_fn_19+0xba4>
    8bf0: 52802a21     	mov	w1, #0x151              ; =337
    8bf4: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8bf8: f9400042     	ldr	x2, [x2]
    8bfc: aa1903e0     	mov	x0, x25
    8c00: d63f0040     	blr	x2
    8c04: 52800000     	mov	w0, #0x0                ; =0
    8c08: 910183ff     	add	sp, sp, #0x60
    8c0c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8c10: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8c14: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8c18: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8c1c: f84107fb     	ldr	x27, [sp], #0x10
    8c20: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8c24: d65f03c0     	ret
    8c28: 52802a01     	mov	w1, #0x150              ; =336
    8c2c: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8c30: f9400042     	ldr	x2, [x2]
    8c34: aa1903e0     	mov	x0, x25
    8c38: d63f0040     	blr	x2
    8c3c: 52800000     	mov	w0, #0x0                ; =0
    8c40: 910183ff     	add	sp, sp, #0x60
    8c44: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8c48: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8c4c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8c50: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8c54: f84107fb     	ldr	x27, [sp], #0x10
    8c58: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8c5c: d65f03c0     	ret
    8c60: 528029e1     	mov	w1, #0x14f              ; =335
    8c64: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8c68: f9400042     	ldr	x2, [x2]
    8c6c: aa1903e0     	mov	x0, x25
    8c70: d63f0040     	blr	x2
    8c74: 52800000     	mov	w0, #0x0                ; =0
    8c78: 910183ff     	add	sp, sp, #0x60
    8c7c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8c80: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8c84: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8c88: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8c8c: f84107fb     	ldr	x27, [sp], #0x10
    8c90: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8c94: d65f03c0     	ret
    8c98: 528029c1     	mov	w1, #0x14e              ; =334
    8c9c: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8ca0: f9400042     	ldr	x2, [x2]
    8ca4: aa1903e0     	mov	x0, x25
    8ca8: d63f0040     	blr	x2
    8cac: 52800000     	mov	w0, #0x0                ; =0
    8cb0: 910183ff     	add	sp, sp, #0x60
    8cb4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8cb8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8cbc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8cc0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8cc4: f84107fb     	ldr	x27, [sp], #0x10
    8cc8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8ccc: d65f03c0     	ret
    8cd0: 528029a1     	mov	w1, #0x14d              ; =333
    8cd4: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8cd8: f9400042     	ldr	x2, [x2]
    8cdc: aa1903e0     	mov	x0, x25
    8ce0: d63f0040     	blr	x2
    8ce4: 52800000     	mov	w0, #0x0                ; =0
    8ce8: 910183ff     	add	sp, sp, #0x60
    8cec: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8cf0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8cf4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8cf8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8cfc: f84107fb     	ldr	x27, [sp], #0x10
    8d00: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8d04: d65f03c0     	ret
    8d08: 52802981     	mov	w1, #0x14c              ; =332
    8d0c: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8d10: f9400042     	ldr	x2, [x2]
    8d14: aa1903e0     	mov	x0, x25
    8d18: d63f0040     	blr	x2
    8d1c: 52800000     	mov	w0, #0x0                ; =0
    8d20: 910183ff     	add	sp, sp, #0x60
    8d24: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8d28: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8d2c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8d30: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8d34: f84107fb     	ldr	x27, [sp], #0x10
    8d38: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8d3c: d65f03c0     	ret
    8d40: 528028e1     	mov	w1, #0x147              ; =327
    8d44: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8d48: f9400042     	ldr	x2, [x2]
    8d4c: aa1903e0     	mov	x0, x25
    8d50: d63f0040     	blr	x2
    8d54: 52800000     	mov	w0, #0x0                ; =0
    8d58: 910183ff     	add	sp, sp, #0x60
    8d5c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8d60: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8d64: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8d68: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8d6c: f84107fb     	ldr	x27, [sp], #0x10
    8d70: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8d74: d65f03c0     	ret
    8d78: 52802861     	mov	w1, #0x143              ; =323
    8d7c: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8d80: f9400042     	ldr	x2, [x2]
    8d84: aa1903e0     	mov	x0, x25
    8d88: d63f0040     	blr	x2
    8d8c: 52800000     	mov	w0, #0x0                ; =0
    8d90: 910183ff     	add	sp, sp, #0x60
    8d94: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8d98: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8d9c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8da0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8da4: f84107fb     	ldr	x27, [sp], #0x10
    8da8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8dac: d65f03c0     	ret
    8db0: 52802841     	mov	w1, #0x142              ; =322
    8db4: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8db8: f9400042     	ldr	x2, [x2]
    8dbc: aa1903e0     	mov	x0, x25
    8dc0: d63f0040     	blr	x2
    8dc4: 52800000     	mov	w0, #0x0                ; =0
    8dc8: 910183ff     	add	sp, sp, #0x60
    8dcc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8dd0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8dd4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8dd8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8ddc: f84107fb     	ldr	x27, [sp], #0x10
    8de0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8de4: d65f03c0     	ret
    8de8: 52802821     	mov	w1, #0x141              ; =321
    8dec: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8df0: f9400042     	ldr	x2, [x2]
    8df4: aa1903e0     	mov	x0, x25
    8df8: d63f0040     	blr	x2
    8dfc: 52800000     	mov	w0, #0x0                ; =0
    8e00: 910183ff     	add	sp, sp, #0x60
    8e04: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8e08: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8e0c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8e10: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8e14: f84107fb     	ldr	x27, [sp], #0x10
    8e18: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8e1c: d65f03c0     	ret
    8e20: 52800000     	mov	w0, #0x0                ; =0
    8e24: 910183ff     	add	sp, sp, #0x60
    8e28: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8e2c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8e30: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8e34: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8e38: f84107fb     	ldr	x27, [sp], #0x10
    8e3c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8e40: d65f03c0     	ret
    8e44: 52802a61     	mov	w1, #0x153              ; =339
    8e48: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8e4c: f9400042     	ldr	x2, [x2]
    8e50: aa1903e0     	mov	x0, x25
    8e54: d63f0040     	blr	x2
    8e58: 52800000     	mov	w0, #0x0                ; =0
    8e5c: 910183ff     	add	sp, sp, #0x60
    8e60: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8e64: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8e68: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8e6c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8e70: f84107fb     	ldr	x27, [sp], #0x10
    8e74: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8e78: d65f03c0     	ret
    8e7c: 52802a41     	mov	w1, #0x152              ; =338
    8e80: 90000002     	adrp	x2, 0x8000 <___pl_fn_18+0x590>
    8e84: f9400042     	ldr	x2, [x2]
    8e88: aa1903e0     	mov	x0, x25
    8e8c: d63f0040     	blr	x2
    8e90: 52800000     	mov	w0, #0x0                ; =0
    8e94: 910183ff     	add	sp, sp, #0x60
    8e98: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8e9c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8ea0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8ea4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    8ea8: f84107fb     	ldr	x27, [sp], #0x10
    8eac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8eb0: d65f03c0     	ret
