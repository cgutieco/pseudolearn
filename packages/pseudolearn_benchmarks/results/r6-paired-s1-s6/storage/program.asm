
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_28184/storage/program.o:	file format mach-o arm64

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
      20: aa0103f5     	mov	x21, x1
      24: aa0203fb     	mov	x27, x2
      28: aa0303fc     	mov	x28, x3
      2c: b9401009     	ldr	w9, [x0, #0x10]
      30: 11000529     	add	w9, w9, #0x1
      34: b9001009     	str	w9, [x0, #0x10]
      38: f940240b     	ldr	x11, [x0, #0x48]
      3c: aa1c03e3     	mov	x3, x28
      40: 2a0303f3     	mov	w19, w3
      44: d100066c     	sub	x12, x19, #0x1
      48: eb0b019f     	cmp	x12, x11
      4c: 540028c2     	b.hs	0x564 <___pl_fn_0+0x564>
      50: f940200e     	ldr	x14, [x0, #0x40]
      54: aa0003fa     	mov	x26, x0
      58: d2800600     	mov	x0, #0x30               ; =48
      5c: d1000661     	sub	x1, x19, #0x1
      60: 9b007c2f     	mul	x15, x1, x0
      64: 9b003820     	madd	x0, x1, x0, x14
      68: f9400400     	ldr	x0, [x0, #0x8]
      6c: b50000a0     	cbnz	x0, 0x80 <___pl_fn_0+0x80>
      70: 1400013e     	b	0x568 <___pl_fn_0+0x568>
      74: aa1a03e0     	mov	x0, x26
      78: f9401800     	ldr	x0, [x0, #0x30]
      7c: 14000002     	b	0x84 <___pl_fn_0+0x84>
      80: f86f69c0     	ldr	x0, [x14, x15]
      84: b27ff7e1     	mov	x1, #0x7ffffffffffffffe ; =9223372036854775806
      88: eb01001f     	cmp	x0, x1
      8c: 5400364c     	b.gt	0x754 <___pl_fn_0+0x754>
      90: aa1a03e1     	mov	x1, x26
      94: f9402421     	ldr	x1, [x1, #0x48]
      98: d1000662     	sub	x2, x19, #0x1
      9c: eb01005f     	cmp	x2, x1
      a0: 54002742     	b.hs	0x588 <___pl_fn_0+0x588>
      a4: aa1a03e1     	mov	x1, x26
      a8: f9402021     	ldr	x1, [x1, #0x40]
      ac: d2800603     	mov	x3, #0x30               ; =48
      b0: d1000664     	sub	x4, x19, #0x1
      b4: 9b037c82     	mul	x2, x4, x3
      b8: 9b030483     	madd	x3, x4, x3, x1
      bc: f9400864     	ldr	x4, [x3, #0x10]
      c0: b5000084     	cbnz	x4, 0xd0 <___pl_fn_0+0xd0>
      c4: 14000131     	b	0x588 <___pl_fn_0+0x588>
      c8: aa1a03e0     	mov	x0, x26
      cc: 14000006     	b	0xe4 <___pl_fn_0+0xe4>
      d0: d2800024     	mov	x4, #0x1                ; =1
      d4: 91000400     	add	x0, x0, #0x1
      d8: f8226820     	str	x0, [x1, x2]
      dc: f9000464     	str	x4, [x3, #0x8]
      e0: aa1a03e0     	mov	x0, x26
      e4: aa1a03e0     	mov	x0, x26
      e8: f9403c00     	ldr	x0, [x0, #0x78]
      ec: 37402600     	tbnz	w0, #0x8, 0x5ac <___pl_fn_0+0x5ac>
      f0: aa1a03e0     	mov	x0, x26
      f4: f9403800     	ldr	x0, [x0, #0x70]
      f8: f100001f     	cmp	x0, #0x0
      fc: 5400258d     	b.le	0x5ac <___pl_fn_0+0x5ac>
     100: aa1a03e0     	mov	x0, x26
     104: f9403400     	ldr	x0, [x0, #0x68]
     108: f100181f     	cmp	x0, #0x6
     10c: 5400250b     	b.lt	0x5ac <___pl_fn_0+0x5ac>
     110: aa1a03e0     	mov	x0, x26
     114: f9402800     	ldr	x0, [x0, #0x50]
     118: aa1a03e1     	mov	x1, x26
     11c: f9402c21     	ldr	x1, [x1, #0x58]
     120: 91002002     	add	x2, x0, #0x8
     124: eb01005f     	cmp	x2, x1
     128: 54002428     	b.hi	0x5ac <___pl_fn_0+0x5ac>
     12c: aa1a03e1     	mov	x1, x26
     130: f9404421     	ldr	x1, [x1, #0x88]
     134: aa1a03e2     	mov	x2, x26
     138: f9404842     	ldr	x2, [x2, #0x90]
     13c: eb02003f     	cmp	x1, x2
     140: 540000c3     	b.lo	0x158 <___pl_fn_0+0x158>
     144: 1400011a     	b	0x5ac <___pl_fn_0+0x5ac>
     148: aa1a03e0     	mov	x0, x26
     14c: f9401800     	ldr	x0, [x0, #0x30]
     150: aa0003e2     	mov	x2, x0
     154: 1400002e     	b	0x20c <___pl_fn_0+0x20c>
     158: aa1a03e2     	mov	x2, x26
     15c: f9403044     	ldr	x4, [x2, #0x60]
     160: f9400045     	ldr	x5, [x2]
     164: d2800086     	mov	x6, #0x4                ; =4
     168: f2c00066     	movk	x6, #0x3, lsl #32
     16c: 2a0003e2     	mov	w2, w0
     170: 8b020ca3     	add	x3, x5, x2, lsl #3
     174: f82058a6     	str	x6, [x5, w0, uxtw #3]
     178: 91000484     	add	x4, x4, #0x1
     17c: f9000464     	str	x4, [x3, #0x8]
     180: 92800005     	mov	x5, #-0x1               ; =-1
     184: f9000865     	str	x5, [x3, #0x10]
     188: d2800005     	mov	x5, #0x0                ; =0
     18c: f9000c65     	str	x5, [x3, #0x18]
     190: f9001065     	str	x5, [x3, #0x20]
     194: f9001465     	str	x5, [x3, #0x28]
     198: f9001865     	str	x5, [x3, #0x30]
     19c: f9001c65     	str	x5, [x3, #0x38]
     1a0: aa1a03e3     	mov	x3, x26
     1a4: f9003064     	str	x4, [x3, #0x60]
     1a8: 91002003     	add	x3, x0, #0x8
     1ac: aa1a03e5     	mov	x5, x26
     1b0: f90028a3     	str	x3, [x5, #0x50]
     1b4: aa1a03e7     	mov	x7, x26
     1b8: f94034e3     	ldr	x3, [x7, #0x68]
     1bc: d1001863     	sub	x3, x3, #0x6
     1c0: aa1a03ea     	mov	x10, x26
     1c4: f9003543     	str	x3, [x10, #0x68]
     1c8: aa1a03ec     	mov	x12, x26
     1cc: f9403983     	ldr	x3, [x12, #0x70]
     1d0: d1001863     	sub	x3, x3, #0x6
     1d4: aa1a03ef     	mov	x15, x26
     1d8: f90039e3     	str	x3, [x15, #0x70]
     1dc: aa1a03e3     	mov	x3, x26
     1e0: f9404063     	ldr	x3, [x3, #0x80]
     1e4: b25d0042     	orr	x2, x2, #0x800000000
     1e8: d37cec25     	lsl	x5, x1, #4
     1ec: 8b011064     	add	x4, x3, x1, lsl #4
     1f0: f8256862     	str	x2, [x3, x5]
     1f4: d28000c2     	mov	x2, #0x6                ; =6
     1f8: f9000482     	str	x2, [x4, #0x8]
     1fc: 91000421     	add	x1, x1, #0x1
     200: aa1a03e2     	mov	x2, x26
     204: f9004441     	str	x1, [x2, #0x88]
     208: aa0003e2     	mov	x2, x0
     20c: d2800039     	mov	x25, #0x1               ; =1
     210: aa1503f3     	mov	x19, x21
     214: f100067f     	cmp	x19, #0x1
     218: 540011a0     	b.eq	0x44c <___pl_fn_0+0x44c>
     21c: b24107f6     	mov	x22, #-0x7fffffffffffffff ; =-9223372036854775807
     220: eb16027f     	cmp	x19, x22
     224: 540026cb     	b.lt	0x6fc <___pl_fn_0+0x6fc>
     228: aa1a03e0     	mov	x0, x26
     22c: b9401814     	ldr	w20, [x0, #0x18]
     230: b9401c07     	ldr	w7, [x0, #0x1c]
     234: 11000695     	add	w21, w20, #0x1
     238: 6b0702bf     	cmp	w21, w7
     23c: 540025c8     	b.hi	0x6f4 <___pl_fn_0+0x6f4>
     240: aa1a03e0     	mov	x0, x26
     244: f9401009     	ldr	x9, [x0, #0x20]
     248: b8345922     	str	w2, [x9, w20, uxtw #2]
     24c: f80503e2     	stur	x2, [sp, #0x50]
     250: b9001815     	str	w21, [x0, #0x18]
     254: b940100b     	ldr	w11, [x0, #0x10]
     258: b940140c     	ldr	w12, [x0, #0x14]
     25c: 6b0c017f     	cmp	w11, w12
     260: 54002462     	b.hs	0x6ec <___pl_fn_0+0x6ec>
     264: d1000661     	sub	x1, x19, #0x1
     268: aa1a03e0     	mov	x0, x26
     26c: aa1b03e2     	mov	x2, x27
     270: aa1c03e3     	mov	x3, x28
     274: 94000000     	bl	0x274 <___pl_fn_0+0x274>
     278: aa1a03e1     	mov	x1, x26
     27c: b9402c2d     	ldr	w13, [x1, #0x2c]
     280: 3500274d     	cbnz	w13, 0x768 <___pl_fn_0+0x768>
     284: aa1a03e1     	mov	x1, x26
     288: b9001834     	str	w20, [x1, #0x18]
     28c: f84503e2     	ldur	x2, [sp, #0x50]
     290: 340019e2     	cbz	w2, 0x5cc <___pl_fn_0+0x5cc>
     294: aa1a03ec     	mov	x12, x26
     298: f9400181     	ldr	x1, [x12]
     29c: 2a0003e0     	mov	w0, w0
     2a0: f84503e2     	ldur	x2, [sp, #0x50]
     2a4: 2a0203f7     	mov	w23, w2
     2a8: d2800078     	mov	x24, #0x3               ; =3
     2ac: 8b170c21     	add	x1, x1, x23, lsl #3
     2b0: f9000c20     	str	x0, [x1, #0x18]
     2b4: eb16027f     	cmp	x19, x22
     2b8: 5400216b     	b.lt	0x6e4 <___pl_fn_0+0x6e4>
     2bc: aa1a03e0     	mov	x0, x26
     2c0: b9401c00     	ldr	w0, [x0, #0x1c]
     2c4: 6b0002bf     	cmp	w21, w0
     2c8: 540020a8     	b.hi	0x6dc <___pl_fn_0+0x6dc>
     2cc: aa1a03e0     	mov	x0, x26
     2d0: f9401000     	ldr	x0, [x0, #0x20]
     2d4: f84503e2     	ldur	x2, [sp, #0x50]
     2d8: b8345802     	str	w2, [x0, w20, uxtw #2]
     2dc: aa1a03e0     	mov	x0, x26
     2e0: b9001815     	str	w21, [x0, #0x18]
     2e4: b9401000     	ldr	w0, [x0, #0x10]
     2e8: aa1a03e1     	mov	x1, x26
     2ec: b9401421     	ldr	w1, [x1, #0x14]
     2f0: 6b01001f     	cmp	w0, w1
     2f4: 54001f02     	b.hs	0x6d4 <___pl_fn_0+0x6d4>
     2f8: d1000661     	sub	x1, x19, #0x1
     2fc: aa1a03e0     	mov	x0, x26
     300: aa1b03e2     	mov	x2, x27
     304: aa1c03e3     	mov	x3, x28
     308: 94000000     	bl	0x308 <___pl_fn_0+0x308>
     30c: aa1a03e1     	mov	x1, x26
     310: b9402c21     	ldr	w1, [x1, #0x2c]
     314: 350022a1     	cbnz	w1, 0x768 <___pl_fn_0+0x768>
     318: aa1a03e1     	mov	x1, x26
     31c: b9001834     	str	w20, [x1, #0x18]
     320: f84503e2     	ldur	x2, [sp, #0x50]
     324: 34001702     	cbz	w2, 0x604 <___pl_fn_0+0x604>
     328: aa1a03e1     	mov	x1, x26
     32c: f9400021     	ldr	x1, [x1]
     330: 2a0003e0     	mov	w0, w0
     334: 8b170c21     	add	x1, x1, x23, lsl #3
     338: f9001020     	str	x0, [x1, #0x20]
     33c: eb16027f     	cmp	x19, x22
     340: 54001c6b     	b.lt	0x6cc <___pl_fn_0+0x6cc>
     344: aa1a03e0     	mov	x0, x26
     348: b9401c00     	ldr	w0, [x0, #0x1c]
     34c: 6b0002bf     	cmp	w21, w0
     350: 54001ba8     	b.hi	0x6c4 <___pl_fn_0+0x6c4>
     354: aa1a03e0     	mov	x0, x26
     358: f9401000     	ldr	x0, [x0, #0x20]
     35c: f84503e2     	ldur	x2, [sp, #0x50]
     360: b8345802     	str	w2, [x0, w20, uxtw #2]
     364: aa1a03e0     	mov	x0, x26
     368: b9001815     	str	w21, [x0, #0x18]
     36c: b9401000     	ldr	w0, [x0, #0x10]
     370: aa1a03ee     	mov	x14, x26
     374: b94015c1     	ldr	w1, [x14, #0x14]
     378: 6b01001f     	cmp	w0, w1
     37c: 54001a02     	b.hs	0x6bc <___pl_fn_0+0x6bc>
     380: d1000661     	sub	x1, x19, #0x1
     384: aa1a03e0     	mov	x0, x26
     388: aa1b03e2     	mov	x2, x27
     38c: aa1c03e3     	mov	x3, x28
     390: 94000000     	bl	0x390 <___pl_fn_0+0x390>
     394: aa1a03e1     	mov	x1, x26
     398: b9402c21     	ldr	w1, [x1, #0x2c]
     39c: 35001e61     	cbnz	w1, 0x768 <___pl_fn_0+0x768>
     3a0: aa1a03e1     	mov	x1, x26
     3a4: b9001834     	str	w20, [x1, #0x18]
     3a8: f84503e2     	ldur	x2, [sp, #0x50]
     3ac: 34001462     	cbz	w2, 0x638 <___pl_fn_0+0x638>
     3b0: aa1a03e1     	mov	x1, x26
     3b4: f9400021     	ldr	x1, [x1]
     3b8: 2a0003e0     	mov	w0, w0
     3bc: 8b170c21     	add	x1, x1, x23, lsl #3
     3c0: f9001420     	str	x0, [x1, #0x28]
     3c4: eb16027f     	cmp	x19, x22
     3c8: 5400176b     	b.lt	0x6b4 <___pl_fn_0+0x6b4>
     3cc: aa1a03e0     	mov	x0, x26
     3d0: b9401c04     	ldr	w4, [x0, #0x1c]
     3d4: 6b0402bf     	cmp	w21, w4
     3d8: 540016a8     	b.hi	0x6ac <___pl_fn_0+0x6ac>
     3dc: aa1a03e0     	mov	x0, x26
     3e0: f9401006     	ldr	x6, [x0, #0x20]
     3e4: f84503e2     	ldur	x2, [sp, #0x50]
     3e8: b83458c2     	str	w2, [x6, w20, uxtw #2]
     3ec: b9001815     	str	w21, [x0, #0x18]
     3f0: b9401008     	ldr	w8, [x0, #0x10]
     3f4: b9401409     	ldr	w9, [x0, #0x14]
     3f8: 6b09011f     	cmp	w8, w9
     3fc: 54001542     	b.hs	0x6a4 <___pl_fn_0+0x6a4>
     400: d1000661     	sub	x1, x19, #0x1
     404: aa1b03e2     	mov	x2, x27
     408: aa1c03e3     	mov	x3, x28
     40c: aa1a03e0     	mov	x0, x26
     410: 94000000     	bl	0x410 <___pl_fn_0+0x410>
     414: aa1a03e2     	mov	x2, x26
     418: b9402c4a     	ldr	w10, [x2, #0x2c]
     41c: 35001a6a     	cbnz	w10, 0x768 <___pl_fn_0+0x768>
     420: aa1a03e6     	mov	x6, x26
     424: b90018d4     	str	w20, [x6, #0x18]
     428: f84503e2     	ldur	x2, [sp, #0x50]
     42c: 34001222     	cbz	w2, 0x670 <___pl_fn_0+0x670>
     430: aa1a03e1     	mov	x1, x26
     434: f9400021     	ldr	x1, [x1]
     438: 2a0003e0     	mov	w0, w0
     43c: 8b170c21     	add	x1, x1, x23, lsl #3
     440: f9001820     	str	x0, [x1, #0x30]
     444: aa1a03e0     	mov	x0, x26
     448: 14000039     	b	0x52c <___pl_fn_0+0x52c>
     44c: aa1a03e0     	mov	x0, x26
     450: f80503e2     	stur	x2, [sp, #0x50]
     454: b9401813     	ldr	w19, [x0, #0x18]
     458: b9401c01     	ldr	w1, [x0, #0x1c]
     45c: 11000660     	add	w0, w19, #0x1
     460: 6b01001f     	cmp	w0, w1
     464: 54001748     	b.hi	0x74c <___pl_fn_0+0x74c>
     468: aa1a03e1     	mov	x1, x26
     46c: f9401021     	ldr	x1, [x1, #0x20]
     470: f84503e2     	ldur	x2, [sp, #0x50]
     474: b8335822     	str	w2, [x1, w19, uxtw #2]
     478: aa1a03e1     	mov	x1, x26
     47c: b9001820     	str	w0, [x1, #0x18]
     480: aa1a03e0     	mov	x0, x26
     484: b9401000     	ldr	w0, [x0, #0x10]
     488: aa1a03e3     	mov	x3, x26
     48c: b9401461     	ldr	w1, [x3, #0x14]
     490: 6b01001f     	cmp	w0, w1
     494: 54001582     	b.hs	0x744 <___pl_fn_0+0x744>
     498: aa1b03e1     	mov	x1, x27
     49c: aa1a03e0     	mov	x0, x26
     4a0: 94000000     	bl	0x4a0 <___pl_fn_0+0x4a0>
     4a4: aa1a03e8     	mov	x8, x26
     4a8: b9402d01     	ldr	w1, [x8, #0x2c]
     4ac: 350015e1     	cbnz	w1, 0x768 <___pl_fn_0+0x768>
     4b0: aa1a03ec     	mov	x12, x26
     4b4: b9001993     	str	w19, [x12, #0x18]
     4b8: d28ccce1     	mov	x1, #0x6667             ; =26215
     4bc: f2acccc1     	movk	x1, #0x6666, lsl #16
     4c0: f2ccccc1     	movk	x1, #0x6666, lsl #32
     4c4: f2ecccc1     	movk	x1, #0x6666, lsl #48
     4c8: 9b417c01     	smulh	x1, x0, x1
     4cc: 9342fc21     	asr	x1, x1, #2
     4d0: d37ffc22     	lsr	x2, x1, #63
     4d4: 8b020021     	add	x1, x1, x2
     4d8: d2800142     	mov	x2, #0xa                ; =10
     4dc: 9b028020     	msub	x0, x1, x2, x0
     4e0: b27ff7e1     	mov	x1, #0x7ffffffffffffffe ; =9223372036854775806
     4e4: eb01001f     	cmp	x0, x1
     4e8: 540012ac     	b.gt	0x73c <___pl_fn_0+0x73c>
     4ec: f84503e2     	ldur	x2, [sp, #0x50]
     4f0: 340010a2     	cbz	w2, 0x704 <___pl_fn_0+0x704>
     4f4: aa1a03e1     	mov	x1, x26
     4f8: f9400021     	ldr	x1, [x1]
     4fc: f84503e2     	ldur	x2, [sp, #0x50]
     500: 2a0203e2     	mov	w2, w2
     504: 8b020c22     	add	x2, x1, x2, lsl #3
     508: f9400843     	ldr	x3, [x2, #0x10]
     50c: 927bf863     	and	x3, x3, #0xffffffffffffffef
     510: f9000843     	str	x3, [x2, #0x10]
     514: 91000400     	add	x0, x0, #0x1
     518: f84503e2     	ldur	x2, [sp, #0x50]
     51c: 2a0203e2     	mov	w2, w2
     520: 8b020c21     	add	x1, x1, x2, lsl #3
     524: f9001c20     	str	x0, [x1, #0x38]
     528: aa1a03e0     	mov	x0, x26
     52c: aa1a03e0     	mov	x0, x26
     530: b9401000     	ldr	w0, [x0, #0x10]
     534: 51000400     	sub	w0, w0, #0x1
     538: aa1a03e1     	mov	x1, x26
     53c: b9001020     	str	w0, [x1, #0x10]
     540: f84503e0     	ldur	x0, [sp, #0x50]
     544: 910183ff     	add	sp, sp, #0x60
     548: a8c153f3     	ldp	x19, x20, [sp], #0x10
     54c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     550: a8c163f7     	ldp	x23, x24, [sp], #0x10
     554: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     558: a8c173fb     	ldp	x27, x28, [sp], #0x10
     55c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     560: d65f03c0     	ret
     564: aa0003fa     	mov	x26, x0
     568: 52800001     	mov	w1, #0x0                ; =0
     56c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     570: f9400063     	ldr	x3, [x3]
     574: aa1a03e0     	mov	x0, x26
     578: aa1c03e2     	mov	x2, x28
     57c: d63f0060     	blr	x3
     580: 34ffd7a0     	cbz	w0, 0x74 <___pl_fn_0+0x74>
     584: 14000079     	b	0x768 <___pl_fn_0+0x768>
     588: 52800041     	mov	w1, #0x2                ; =2
     58c: 91000403     	add	x3, x0, #0x1
     590: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     594: f9400084     	ldr	x4, [x4]
     598: aa1a03e0     	mov	x0, x26
     59c: aa1c03e2     	mov	x2, x28
     5a0: d63f0080     	blr	x4
     5a4: 34ffd920     	cbz	w0, 0xc8 <___pl_fn_0+0xc8>
     5a8: 14000070     	b	0x768 <___pl_fn_0+0x768>
     5ac: 52800061     	mov	w1, #0x3                ; =3
     5b0: 52800022     	mov	w2, #0x1                ; =1
     5b4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     5b8: f9400063     	ldr	x3, [x3]
     5bc: aa1a03e0     	mov	x0, x26
     5c0: d63f0060     	blr	x3
     5c4: 34ffdc20     	cbz	w0, 0x148 <___pl_fn_0+0x148>
     5c8: 14000068     	b	0x768 <___pl_fn_0+0x768>
     5cc: d2800001     	mov	x1, #0x0                ; =0
     5d0: 910003e3     	mov	x3, sp
     5d4: f80003e1     	stur	x1, [sp]
     5d8: 2a0003e0     	mov	w0, w0
     5dc: f80083e0     	stur	x0, [sp, #0x8]
     5e0: 528000e1     	mov	w1, #0x7                ; =7
     5e4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     5e8: f9400084     	ldr	x4, [x4]
     5ec: f84503e2     	ldur	x2, [sp, #0x50]
     5f0: aa1a03e0     	mov	x0, x26
     5f4: d63f0080     	blr	x4
     5f8: 35000b80     	cbnz	w0, 0x768 <___pl_fn_0+0x768>
     5fc: 52800101     	mov	w1, #0x8                ; =8
     600: 14000056     	b	0x758 <___pl_fn_0+0x758>
     604: 910043e3     	add	x3, sp, #0x10
     608: f80103f9     	stur	x25, [sp, #0x10]
     60c: 2a0003e0     	mov	w0, w0
     610: f80183e0     	stur	x0, [sp, #0x18]
     614: 52800181     	mov	w1, #0xc                ; =12
     618: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     61c: f9400084     	ldr	x4, [x4]
     620: f84503e2     	ldur	x2, [sp, #0x50]
     624: aa1a03e0     	mov	x0, x26
     628: d63f0080     	blr	x4
     62c: 350009e0     	cbnz	w0, 0x768 <___pl_fn_0+0x768>
     630: 528001a1     	mov	w1, #0xd                ; =13
     634: 14000049     	b	0x758 <___pl_fn_0+0x758>
     638: d2800041     	mov	x1, #0x2                ; =2
     63c: 910083e3     	add	x3, sp, #0x20
     640: f80203e1     	stur	x1, [sp, #0x20]
     644: 2a0003e0     	mov	w0, w0
     648: f80283e0     	stur	x0, [sp, #0x28]
     64c: 52800221     	mov	w1, #0x11               ; =17
     650: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     654: f9400084     	ldr	x4, [x4]
     658: f84503e2     	ldur	x2, [sp, #0x50]
     65c: aa1a03e0     	mov	x0, x26
     660: d63f0080     	blr	x4
     664: 35000820     	cbnz	w0, 0x768 <___pl_fn_0+0x768>
     668: 52800241     	mov	w1, #0x12               ; =18
     66c: 1400003b     	b	0x758 <___pl_fn_0+0x758>
     670: 9100c3e3     	add	x3, sp, #0x30
     674: f80303f8     	stur	x24, [sp, #0x30]
     678: 2a0003ef     	mov	w15, w0
     67c: f80383ef     	stur	x15, [sp, #0x38]
     680: 528002c1     	mov	w1, #0x16               ; =22
     684: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     688: f9400084     	ldr	x4, [x4]
     68c: f84503e2     	ldur	x2, [sp, #0x50]
     690: aa1a03e0     	mov	x0, x26
     694: d63f0080     	blr	x4
     698: 35000680     	cbnz	w0, 0x768 <___pl_fn_0+0x768>
     69c: 528002e1     	mov	w1, #0x17               ; =23
     6a0: 1400002e     	b	0x758 <___pl_fn_0+0x758>
     6a4: 528002a1     	mov	w1, #0x15               ; =21
     6a8: 1400002c     	b	0x758 <___pl_fn_0+0x758>
     6ac: 52800281     	mov	w1, #0x14               ; =20
     6b0: 1400002a     	b	0x758 <___pl_fn_0+0x758>
     6b4: 52800261     	mov	w1, #0x13               ; =19
     6b8: 14000028     	b	0x758 <___pl_fn_0+0x758>
     6bc: 52800201     	mov	w1, #0x10               ; =16
     6c0: 14000026     	b	0x758 <___pl_fn_0+0x758>
     6c4: 528001e1     	mov	w1, #0xf                ; =15
     6c8: 14000024     	b	0x758 <___pl_fn_0+0x758>
     6cc: 528001c1     	mov	w1, #0xe                ; =14
     6d0: 14000022     	b	0x758 <___pl_fn_0+0x758>
     6d4: 52800161     	mov	w1, #0xb                ; =11
     6d8: 14000020     	b	0x758 <___pl_fn_0+0x758>
     6dc: 52800141     	mov	w1, #0xa                ; =10
     6e0: 1400001e     	b	0x758 <___pl_fn_0+0x758>
     6e4: 52800121     	mov	w1, #0x9                ; =9
     6e8: 1400001c     	b	0x758 <___pl_fn_0+0x758>
     6ec: 528000c1     	mov	w1, #0x6                ; =6
     6f0: 1400001a     	b	0x758 <___pl_fn_0+0x758>
     6f4: 528000a1     	mov	w1, #0x5                ; =5
     6f8: 14000018     	b	0x758 <___pl_fn_0+0x758>
     6fc: 52800081     	mov	w1, #0x4                ; =4
     700: 14000016     	b	0x758 <___pl_fn_0+0x758>
     704: d2800081     	mov	x1, #0x4                ; =4
     708: 910103e3     	add	x3, sp, #0x40
     70c: f80403e1     	stur	x1, [sp, #0x40]
     710: 91000400     	add	x0, x0, #0x1
     714: f80483e0     	stur	x0, [sp, #0x48]
     718: 52800381     	mov	w1, #0x1c               ; =28
     71c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     720: f9400084     	ldr	x4, [x4]
     724: f84503e2     	ldur	x2, [sp, #0x50]
     728: aa1a03e0     	mov	x0, x26
     72c: d63f0080     	blr	x4
     730: 350001c0     	cbnz	w0, 0x768 <___pl_fn_0+0x768>
     734: 528003a1     	mov	w1, #0x1d               ; =29
     738: 14000008     	b	0x758 <___pl_fn_0+0x758>
     73c: 52800361     	mov	w1, #0x1b               ; =27
     740: 14000006     	b	0x758 <___pl_fn_0+0x758>
     744: 52800321     	mov	w1, #0x19               ; =25
     748: 14000004     	b	0x758 <___pl_fn_0+0x758>
     74c: 52800301     	mov	w1, #0x18               ; =24
     750: 14000002     	b	0x758 <___pl_fn_0+0x758>
     754: 52800021     	mov	w1, #0x1                ; =1
     758: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     75c: f9400063     	ldr	x3, [x3]
     760: aa1a03e0     	mov	x0, x26
     764: d63f0060     	blr	x3
     768: 52800000     	mov	w0, #0x0                ; =0
     76c: 910183ff     	add	sp, sp, #0x60
     770: a8c153f3     	ldp	x19, x20, [sp], #0x10
     774: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     778: a8c163f7     	ldp	x23, x24, [sp], #0x10
     77c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
     780: a8c173fb     	ldp	x27, x28, [sp], #0x10
     784: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     788: d65f03c0     	ret

000000000000078c <___pl_fn_1>:
     78c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     790: 910003fd     	mov	x29, sp
     794: f81f0ff9     	str	x25, [sp, #-0x10]!
     798: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     79c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     7a0: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     7a4: d10043ff     	sub	sp, sp, #0x10
     7a8: b9401001     	ldr	w1, [x0, #0x10]
     7ac: 11000421     	add	w1, w1, #0x1
     7b0: b9001001     	str	w1, [x0, #0x10]
     7b4: aa0003f5     	mov	x21, x0
     7b8: 528003c1     	mov	w1, #0x1e               ; =30
     7bc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7c0: f9400042     	ldr	x2, [x2]
     7c4: d63f0040     	blr	x2
     7c8: 35001e20     	cbnz	w0, 0xb8c <___pl_fn_1+0x400>
     7cc: aa1503e0     	mov	x0, x21
     7d0: f9401802     	ldr	x2, [x0, #0x30]
     7d4: aa0203f6     	mov	x22, x2
     7d8: 528003e1     	mov	w1, #0x1f               ; =31
     7dc: 52800002     	mov	w2, #0x0                ; =0
     7e0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     7e4: f9400063     	ldr	x3, [x3]
     7e8: aa1503e0     	mov	x0, x21
     7ec: d63f0060     	blr	x3
     7f0: 35001ce0     	cbnz	w0, 0xb8c <___pl_fn_1+0x400>
     7f4: aa1503e0     	mov	x0, x21
     7f8: f9401802     	ldr	x2, [x0, #0x30]
     7fc: aa0203f7     	mov	x23, x2
     800: 52800401     	mov	w1, #0x20               ; =32
     804: 52800002     	mov	w2, #0x0                ; =0
     808: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     80c: f9400063     	ldr	x3, [x3]
     810: d63f0060     	blr	x3
     814: 35001bc0     	cbnz	w0, 0xb8c <___pl_fn_1+0x400>
     818: aa1503e0     	mov	x0, x21
     81c: f9401801     	ldr	x1, [x0, #0x30]
     820: aa0103f8     	mov	x24, x1
     824: f9403c01     	ldr	x1, [x0, #0x78]
     828: 37201521     	tbnz	w1, #0x4, 0xacc <___pl_fn_1+0x340>
     82c: aa1503e0     	mov	x0, x21
     830: f9403803     	ldr	x3, [x0, #0x70]
     834: f100007f     	cmp	x3, #0x0
     838: 540014ad     	b.le	0xacc <___pl_fn_1+0x340>
     83c: aa1503e0     	mov	x0, x21
     840: f9403406     	ldr	x6, [x0, #0x68]
     844: f10008df     	cmp	x6, #0x2
     848: 5400142b     	b.lt	0xacc <___pl_fn_1+0x340>
     84c: aa1503e0     	mov	x0, x21
     850: f9402802     	ldr	x2, [x0, #0x50]
     854: f9402c09     	ldr	x9, [x0, #0x58]
     858: 9100104a     	add	x10, x2, #0x4
     85c: eb09015f     	cmp	x10, x9
     860: 54001368     	b.hi	0xacc <___pl_fn_1+0x340>
     864: aa1503e0     	mov	x0, x21
     868: f940440c     	ldr	x12, [x0, #0x88]
     86c: f940480d     	ldr	x13, [x0, #0x90]
     870: eb0d019f     	cmp	x12, x13
     874: 540000a3     	b.lo	0x888 <___pl_fn_1+0xfc>
     878: 14000095     	b	0xacc <___pl_fn_1+0x340>
     87c: aa1503e0     	mov	x0, x21
     880: f9401802     	ldr	x2, [x0, #0x30]
     884: 14000026     	b	0x91c <___pl_fn_1+0x190>
     888: aa1503e0     	mov	x0, x21
     88c: f9403003     	ldr	x3, [x0, #0x60]
     890: f9400004     	ldr	x4, [x0]
     894: b20007e5     	mov	x5, #0x300000003        ; =12884901891
     898: 2a0203e0     	mov	w0, w2
     89c: 8b000c81     	add	x1, x4, x0, lsl #3
     8a0: f8225885     	str	x5, [x4, w2, uxtw #3]
     8a4: 91000463     	add	x3, x3, #0x1
     8a8: f9000423     	str	x3, [x1, #0x8]
     8ac: 92800004     	mov	x4, #-0x1               ; =-1
     8b0: f9000824     	str	x4, [x1, #0x10]
     8b4: d2800004     	mov	x4, #0x0                ; =0
     8b8: f9000c24     	str	x4, [x1, #0x18]
     8bc: aa1503ed     	mov	x13, x21
     8c0: f90031a3     	str	x3, [x13, #0x60]
     8c4: 91001041     	add	x1, x2, #0x4
     8c8: aa1503e3     	mov	x3, x21
     8cc: f9002861     	str	x1, [x3, #0x50]
     8d0: aa1503e1     	mov	x1, x21
     8d4: f9403421     	ldr	x1, [x1, #0x68]
     8d8: d1000821     	sub	x1, x1, #0x2
     8dc: f9003461     	str	x1, [x3, #0x68]
     8e0: aa1503e1     	mov	x1, x21
     8e4: f9403821     	ldr	x1, [x1, #0x70]
     8e8: d1000821     	sub	x1, x1, #0x2
     8ec: f9003861     	str	x1, [x3, #0x70]
     8f0: aa1503e1     	mov	x1, x21
     8f4: f9404021     	ldr	x1, [x1, #0x80]
     8f8: b25e0000     	orr	x0, x0, #0x400000000
     8fc: d37ced84     	lsl	x4, x12, #4
     900: 8b0c1023     	add	x3, x1, x12, lsl #4
     904: f8246820     	str	x0, [x1, x4]
     908: d2800040     	mov	x0, #0x2                ; =2
     90c: f9000460     	str	x0, [x3, #0x8]
     910: 91000580     	add	x0, x12, #0x1
     914: aa1503e1     	mov	x1, x21
     918: f9004420     	str	x0, [x1, #0x88]
     91c: 34000e82     	cbz	w2, 0xaec <___pl_fn_1+0x360>
     920: aa1503e0     	mov	x0, x21
     924: f9400000     	ldr	x0, [x0]
     928: 2a0203e1     	mov	w1, w2
     92c: 8b010c01     	add	x1, x0, x1, lsl #3
     930: f9400823     	ldr	x3, [x1, #0x10]
     934: 927ff863     	and	x3, x3, #0xfffffffffffffffe
     938: f9000823     	str	x3, [x1, #0x10]
     93c: 52848061     	mov	w1, #0x2403             ; =9219
     940: 72a00021     	movk	w1, #0x1, lsl #16
     944: 2a0203e3     	mov	w3, w2
     948: aa0203f9     	mov	x25, x2
     94c: 8b030c00     	add	x0, x0, x3, lsl #3
     950: f9000c01     	str	x1, [x0, #0x18]
     954: aa1503e0     	mov	x0, x21
     958: f9402400     	ldr	x0, [x0, #0x48]
     95c: aa1703e2     	mov	x2, x23
     960: 2a0203f3     	mov	w19, w2
     964: d1000661     	sub	x1, x19, #0x1
     968: eb00003f     	cmp	x1, x0
     96c: 54000dc2     	b.hs	0xb24 <___pl_fn_1+0x398>
     970: aa1503e0     	mov	x0, x21
     974: f9402000     	ldr	x0, [x0, #0x40]
     978: d2800601     	mov	x1, #0x30               ; =48
     97c: d1000663     	sub	x3, x19, #0x1
     980: 9b017c62     	mul	x2, x3, x1
     984: 9b010061     	madd	x1, x3, x1, x0
     988: f9400823     	ldr	x3, [x1, #0x10]
     98c: b5000083     	cbnz	x3, 0x99c <___pl_fn_1+0x210>
     990: 14000065     	b	0xb24 <___pl_fn_1+0x398>
     994: aa1503e0     	mov	x0, x21
     998: 14000006     	b	0x9b0 <___pl_fn_1+0x224>
     99c: d2800003     	mov	x3, #0x0                ; =0
     9a0: f8226803     	str	x3, [x0, x2]
     9a4: d2800020     	mov	x0, #0x1                ; =1
     9a8: f9000420     	str	x0, [x1, #0x8]
     9ac: aa1503e0     	mov	x0, x21
     9b0: aa1503e0     	mov	x0, x21
     9b4: b9401814     	ldr	w20, [x0, #0x18]
     9b8: b9401c01     	ldr	w1, [x0, #0x1c]
     9bc: 11000680     	add	w0, w20, #0x1
     9c0: 6b01001f     	cmp	w0, w1
     9c4: 54000da8     	b.hi	0xb78 <___pl_fn_1+0x3ec>
     9c8: aa1503e1     	mov	x1, x21
     9cc: f9401021     	ldr	x1, [x1, #0x20]
     9d0: aa1903e2     	mov	x2, x25
     9d4: b8345822     	str	w2, [x1, w20, uxtw #2]
     9d8: aa1503e1     	mov	x1, x21
     9dc: b9001820     	str	w0, [x1, #0x18]
     9e0: aa1503e0     	mov	x0, x21
     9e4: b9401000     	ldr	w0, [x0, #0x10]
     9e8: b9401421     	ldr	w1, [x1, #0x14]
     9ec: 6b01001f     	cmp	w0, w1
     9f0: 54000c02     	b.hs	0xb70 <___pl_fn_1+0x3e4>
     9f4: aa1803e1     	mov	x1, x24
     9f8: aa1503e0     	mov	x0, x21
     9fc: aa1703e3     	mov	x3, x23
     a00: 94000000     	bl	0xa00 <___pl_fn_1+0x274>
     a04: aa1503e1     	mov	x1, x21
     a08: b9402c21     	ldr	w1, [x1, #0x2c]
     a0c: 35000c01     	cbnz	w1, 0xb8c <___pl_fn_1+0x400>
     a10: aa1503e1     	mov	x1, x21
     a14: b9001834     	str	w20, [x1, #0x18]
     a18: 34000a80     	cbz	w0, 0xb68 <___pl_fn_1+0x3dc>
     a1c: aa1503e0     	mov	x0, x21
     a20: f9402400     	ldr	x0, [x0, #0x48]
     a24: d1000661     	sub	x1, x19, #0x1
     a28: eb00003f     	cmp	x1, x0
     a2c: 540008e2     	b.hs	0xb48 <___pl_fn_1+0x3bc>
     a30: aa1503e0     	mov	x0, x21
     a34: f9402003     	ldr	x3, [x0, #0x40]
     a38: d2800605     	mov	x5, #0x30               ; =48
     a3c: d1000666     	sub	x6, x19, #0x1
     a40: 9b057cc4     	mul	x4, x6, x5
     a44: 9b050cc5     	madd	x5, x6, x5, x3
     a48: f94004a5     	ldr	x5, [x5, #0x8]
     a4c: b50000a5     	cbnz	x5, 0xa60 <___pl_fn_1+0x2d4>
     a50: 1400003e     	b	0xb48 <___pl_fn_1+0x3bc>
     a54: aa1503e0     	mov	x0, x21
     a58: f9401802     	ldr	x2, [x0, #0x30]
     a5c: 14000002     	b	0xa64 <___pl_fn_1+0x2d8>
     a60: f8646862     	ldr	x2, [x3, x4]
     a64: 52800521     	mov	w1, #0x29               ; =41
     a68: 52802003     	mov	w3, #0x100              ; =256
     a6c: 90000009     	adrp	x9, 0x0 <___pl_fn_0>
     a70: f9400129     	ldr	x9, [x9]
     a74: aa1503e0     	mov	x0, x21
     a78: d63f0120     	blr	x9
     a7c: 35000880     	cbnz	w0, 0xb8c <___pl_fn_1+0x400>
     a80: 52800541     	mov	w1, #0x2a               ; =42
     a84: 9000000b     	adrp	x11, 0x0 <___pl_fn_0>
     a88: f940016b     	ldr	x11, [x11]
     a8c: aa1603e2     	mov	x2, x22
     a90: aa1503e0     	mov	x0, x21
     a94: d63f0160     	blr	x11
     a98: 350007a0     	cbnz	w0, 0xb8c <___pl_fn_1+0x400>
     a9c: aa1503e0     	mov	x0, x21
     aa0: b940100d     	ldr	w13, [x0, #0x10]
     aa4: 510005ad     	sub	w13, w13, #0x1
     aa8: b900100d     	str	w13, [x0, #0x10]
     aac: 910043ff     	add	sp, sp, #0x10
     ab0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     ab4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     ab8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     abc: f84107f9     	ldr	x25, [sp], #0x10
     ac0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ac4: d65f03c0     	ret
     ac8: 14000031     	b	0xb8c <___pl_fn_1+0x400>
     acc: 52800421     	mov	w1, #0x21               ; =33
     ad0: 52800002     	mov	w2, #0x0                ; =0
     ad4: 9000000f     	adrp	x15, 0x0 <___pl_fn_0>
     ad8: f94001ef     	ldr	x15, [x15]
     adc: aa1503e0     	mov	x0, x21
     ae0: d63f01e0     	blr	x15
     ae4: 34ffecc0     	cbz	w0, 0x87c <___pl_fn_1+0xf0>
     ae8: 14000029     	b	0xb8c <___pl_fn_1+0x400>
     aec: d2800000     	mov	x0, #0x0                ; =0
     af0: 910003e3     	mov	x3, sp
     af4: f80003e0     	stur	x0, [sp]
     af8: 52848060     	mov	w0, #0x2403             ; =9219
     afc: 72a00020     	movk	w0, #0x1, lsl #16
     b00: f80083e0     	stur	x0, [sp, #0x8]
     b04: 52800441     	mov	w1, #0x22               ; =34
     b08: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b0c: f9400084     	ldr	x4, [x4]
     b10: aa1503e0     	mov	x0, x21
     b14: d63f0080     	blr	x4
     b18: 350003a0     	cbnz	w0, 0xb8c <___pl_fn_1+0x400>
     b1c: 52800461     	mov	w1, #0x23               ; =35
     b20: 14000017     	b	0xb7c <___pl_fn_1+0x3f0>
     b24: 52800481     	mov	w1, #0x24               ; =36
     b28: d2800003     	mov	x3, #0x0                ; =0
     b2c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     b30: f9400084     	ldr	x4, [x4]
     b34: aa1503e0     	mov	x0, x21
     b38: aa1703e2     	mov	x2, x23
     b3c: d63f0080     	blr	x4
     b40: 34fff2a0     	cbz	w0, 0x994 <___pl_fn_1+0x208>
     b44: 14000012     	b	0xb8c <___pl_fn_1+0x400>
     b48: 52800501     	mov	w1, #0x28               ; =40
     b4c: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     b50: f94000a5     	ldr	x5, [x5]
     b54: aa1703e2     	mov	x2, x23
     b58: aa1503e0     	mov	x0, x21
     b5c: d63f00a0     	blr	x5
     b60: 34fff7a0     	cbz	w0, 0xa54 <___pl_fn_1+0x2c8>
     b64: 1400000a     	b	0xb8c <___pl_fn_1+0x400>
     b68: 528004e1     	mov	w1, #0x27               ; =39
     b6c: 14000004     	b	0xb7c <___pl_fn_1+0x3f0>
     b70: 528004c1     	mov	w1, #0x26               ; =38
     b74: 14000002     	b	0xb7c <___pl_fn_1+0x3f0>
     b78: 528004a1     	mov	w1, #0x25               ; =37
     b7c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     b80: f9400042     	ldr	x2, [x2]
     b84: aa1503e0     	mov	x0, x21
     b88: d63f0040     	blr	x2
     b8c: 910043ff     	add	sp, sp, #0x10
     b90: a8c153f3     	ldp	x19, x20, [sp], #0x10
     b94: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     b98: a8c163f7     	ldp	x23, x24, [sp], #0x10
     b9c: f84107f9     	ldr	x25, [sp], #0x10
     ba0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     ba4: d65f03c0     	ret

0000000000000ba8 <___pl_fn_2>:
     ba8: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     bac: 910003fd     	mov	x29, sp
     bb0: f81f0ff3     	str	x19, [sp, #-0x10]!
     bb4: d10043ff     	sub	sp, sp, #0x10
     bb8: b9401004     	ldr	w4, [x0, #0x10]
     bbc: 11000482     	add	w2, w4, #0x1
     bc0: b9001002     	str	w2, [x0, #0x10]
     bc4: 34000501     	cbz	w1, 0xc64 <___pl_fn_2+0xbc>
     bc8: f9400002     	ldr	x2, [x0]
     bcc: aa0003f3     	mov	x19, x0
     bd0: 2a0103e0     	mov	w0, w1
     bd4: aa0103e5     	mov	x5, x1
     bd8: 8b000c41     	add	x1, x2, x0, lsl #3
     bdc: f9400c20     	ldr	x0, [x1, #0x18]
     be0: f9400822     	ldr	x2, [x1, #0x10]
     be4: 37000442     	tbnz	w2, #0x0, 0xc6c <___pl_fn_2+0xc4>
     be8: aa0503e2     	mov	x2, x5
     bec: d280a3a5     	mov	x5, #0x51d              ; =1309
     bf0: 9b057c03     	mul	x3, x0, x5
     bf4: 9b457c05     	smulh	x5, x0, x5
     bf8: eb83fcbf     	cmp	x5, x3, asr #63
     bfc: 540008a1     	b.ne	0xd10 <___pl_fn_2+0x168>
     c00: 9286c325     	mov	x5, #-0x361a            ; =-13850
     c04: f2efffe5     	movk	x5, #0x7fff, lsl #48
     c08: eb05007f     	cmp	x3, x5
     c0c: 540007ec     	b.gt	0xd08 <___pl_fn_2+0x160>
     c10: 34000422     	cbz	w2, 0xc94 <___pl_fn_2+0xec>
     c14: f940082f     	ldr	x15, [x1, #0x10]
     c18: 927ff9ef     	and	x15, x15, #0xfffffffffffffffe
     c1c: f900082f     	str	x15, [x1, #0x10]
     c20: d286c320     	mov	x0, #0x3619             ; =13849
     c24: 8b000060     	add	x0, x3, x0
     c28: 934ffc03     	asr	x3, x0, #15
     c2c: d370fc63     	lsr	x3, x3, #48
     c30: 8b030003     	add	x3, x0, x3
     c34: 9270bc63     	and	x3, x3, #0xffffffffffff0000
     c38: cb030000     	sub	x0, x0, x3
     c3c: f9000c20     	str	x0, [x1, #0x18]
     c40: 34000522     	cbz	w2, 0xce4 <___pl_fn_2+0x13c>
     c44: f9400821     	ldr	x1, [x1, #0x10]
     c48: 370004e1     	tbnz	w1, #0x0, 0xce4 <___pl_fn_2+0x13c>
     c4c: aa1303e1     	mov	x1, x19
     c50: b9001024     	str	w4, [x1, #0x10]
     c54: 910043ff     	add	sp, sp, #0x10
     c58: f84107f3     	ldr	x19, [sp], #0x10
     c5c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c60: d65f03c0     	ret
     c64: aa0103e5     	mov	x5, x1
     c68: aa0003f3     	mov	x19, x0
     c6c: 52800561     	mov	w1, #0x2b               ; =43
     c70: 52800003     	mov	w3, #0x0                ; =0
     c74: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c78: f9400084     	ldr	x4, [x4]
     c7c: aa0503e2     	mov	x2, x5
     c80: aa1303e0     	mov	x0, x19
     c84: d63f0080     	blr	x4
     c88: 350004e0     	cbnz	w0, 0xd24 <___pl_fn_2+0x17c>
     c8c: 52800581     	mov	w1, #0x2c               ; =44
     c90: 14000021     	b	0xd14 <___pl_fn_2+0x16c>
     c94: d2800009     	mov	x9, #0x0                ; =0
     c98: 910003e8     	mov	x8, sp
     c9c: f80003e9     	stur	x9, [sp]
     ca0: d286c329     	mov	x9, #0x3619             ; =13849
     ca4: 8b090069     	add	x9, x3, x9
     ca8: 934ffd2a     	asr	x10, x9, #15
     cac: d370fd4a     	lsr	x10, x10, #48
     cb0: 8b0a012a     	add	x10, x9, x10
     cb4: 9270bd4a     	and	x10, x10, #0xffffffffffff0000
     cb8: cb0a0129     	sub	x9, x9, x10
     cbc: f80083e9     	stur	x9, [sp, #0x8]
     cc0: 52800601     	mov	w1, #0x30               ; =48
     cc4: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     cc8: f940014a     	ldr	x10, [x10]
     ccc: aa0803e3     	mov	x3, x8
     cd0: aa1303e0     	mov	x0, x19
     cd4: d63f0140     	blr	x10
     cd8: 35000260     	cbnz	w0, 0xd24 <___pl_fn_2+0x17c>
     cdc: 52800621     	mov	w1, #0x31               ; =49
     ce0: 1400000d     	b	0xd14 <___pl_fn_2+0x16c>
     ce4: 52800641     	mov	w1, #0x32               ; =50
     ce8: 52800003     	mov	w3, #0x0                ; =0
     cec: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     cf0: f9400084     	ldr	x4, [x4]
     cf4: aa1303e0     	mov	x0, x19
     cf8: d63f0080     	blr	x4
     cfc: 35000140     	cbnz	w0, 0xd24 <___pl_fn_2+0x17c>
     d00: 52800661     	mov	w1, #0x33               ; =51
     d04: 14000004     	b	0xd14 <___pl_fn_2+0x16c>
     d08: 528005c1     	mov	w1, #0x2e               ; =46
     d0c: 14000002     	b	0xd14 <___pl_fn_2+0x16c>
     d10: 528005a1     	mov	w1, #0x2d               ; =45
     d14: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     d18: f9400042     	ldr	x2, [x2]
     d1c: aa1303e0     	mov	x0, x19
     d20: d63f0040     	blr	x2
     d24: d2800000     	mov	x0, #0x0                ; =0
     d28: 910043ff     	add	sp, sp, #0x10
     d2c: f84107f3     	ldr	x19, [sp], #0x10
     d30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d34: d65f03c0     	ret
