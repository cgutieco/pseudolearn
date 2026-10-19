
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_28184/bounce/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: b940100a     	ldr	w10, [x0, #0x10]
       c: 1100054b     	add	w11, w10, #0x1
      10: b900100b     	str	w11, [x0, #0x10]
      14: f100003f     	cmp	x1, #0x0
      18: aa0103eb     	mov	x11, x1
      1c: 540000ab     	b.lt	0x30 <___pl_fn_0+0x30>
      20: b900100a     	str	w10, [x0, #0x10]
      24: aa0b03e0     	mov	x0, x11
      28: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      2c: d65f03c0     	ret
      30: aa0003ed     	mov	x13, x0
      34: aa0b03e0     	mov	x0, x11
      38: b24107e1     	mov	x1, #-0x7fffffffffffffff ; =-9223372036854775807
      3c: eb01001f     	cmp	x0, x1
      40: 540000cb     	b.lt	0x58 <___pl_fn_0+0x58>
      44: aa0d03e1     	mov	x1, x13
      48: b900102a     	str	w10, [x1, #0x10]
      4c: cb0003e0     	neg	x0, x0
      50: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      54: d65f03c0     	ret
      58: 52800001     	mov	w1, #0x0                ; =0
      5c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
      60: f9400042     	ldr	x2, [x2]
      64: aa0d03e0     	mov	x0, x13
      68: d63f0040     	blr	x2
      6c: d2800000     	mov	x0, #0x0                ; =0
      70: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      74: d65f03c0     	ret

0000000000000078 <___pl_fn_1>:
      78: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
      7c: 910003fd     	mov	x29, sp
      80: f81f0ffa     	str	x26, [sp, #-0x10]!
      84: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      88: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      8c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      90: d100c3ff     	sub	sp, sp, #0x30
      94: b940100f     	ldr	w15, [x0, #0x10]
      98: 110005ef     	add	w15, w15, #0x1
      9c: b900100f     	str	w15, [x0, #0x10]
      a0: aa0003f7     	mov	x23, x0
      a4: d2800c80     	mov	x0, #0x64               ; =100
      a8: 910003e3     	mov	x3, sp
      ac: f80003e0     	stur	x0, [sp]
      b0: 52800021     	mov	w1, #0x1                ; =1
      b4: 52802082     	mov	w2, #0x104              ; =260
      b8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      bc: f9400084     	ldr	x4, [x4]
      c0: aa1703e0     	mov	x0, x23
      c4: d63f0080     	blr	x4
      c8: 35003920     	cbnz	w0, 0x7ec <___pl_fn_1+0x774>
      cc: aa1703e0     	mov	x0, x23
      d0: f9401802     	ldr	x2, [x0, #0x30]
      d4: b9401814     	ldr	w20, [x0, #0x18]
      d8: b9401c00     	ldr	w0, [x0, #0x1c]
      dc: 11000695     	add	w21, w20, #0x1
      e0: 6b0002bf     	cmp	w21, w0
      e4: 540037a8     	b.hi	0x7d8 <___pl_fn_1+0x760>
      e8: aa1703e0     	mov	x0, x23
      ec: f9401000     	ldr	x0, [x0, #0x20]
      f0: b8345802     	str	w2, [x0, w20, uxtw #2]
      f4: aa1703e0     	mov	x0, x23
      f8: aa0203f8     	mov	x24, x2
      fc: b9001815     	str	w21, [x0, #0x18]
     100: 52800061     	mov	w1, #0x3                ; =3
     104: 52800002     	mov	w2, #0x0                ; =0
     108: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     10c: f9400063     	ldr	x3, [x3]
     110: d63f0060     	blr	x3
     114: 350036c0     	cbnz	w0, 0x7ec <___pl_fn_1+0x774>
     118: aa1703e0     	mov	x0, x23
     11c: f940181a     	ldr	x26, [x0, #0x30]
     120: b9001814     	str	w20, [x0, #0x18]
     124: f9403c00     	ldr	x0, [x0, #0x78]
     128: 37202a40     	tbnz	w0, #0x4, 0x670 <___pl_fn_1+0x5f8>
     12c: aa1703e0     	mov	x0, x23
     130: f9403800     	ldr	x0, [x0, #0x70]
     134: f100001f     	cmp	x0, #0x0
     138: 54002a0d     	b.le	0x678 <___pl_fn_1+0x600>
     13c: aa1703e0     	mov	x0, x23
     140: f9403400     	ldr	x0, [x0, #0x68]
     144: f100081f     	cmp	x0, #0x2
     148: 540029cb     	b.lt	0x680 <___pl_fn_1+0x608>
     14c: aa1703e0     	mov	x0, x23
     150: f9402802     	ldr	x2, [x0, #0x50]
     154: f9402c00     	ldr	x0, [x0, #0x58]
     158: 91001041     	add	x1, x2, #0x4
     15c: eb00003f     	cmp	x1, x0
     160: 54002948     	b.hi	0x688 <___pl_fn_1+0x610>
     164: aa1703e0     	mov	x0, x23
     168: f9404400     	ldr	x0, [x0, #0x88]
     16c: aa1703e1     	mov	x1, x23
     170: f9404821     	ldr	x1, [x1, #0x90]
     174: eb01001f     	cmp	x0, x1
     178: 540028c2     	b.hs	0x690 <___pl_fn_1+0x618>
     17c: aa1703e1     	mov	x1, x23
     180: b9401c21     	ldr	w1, [x1, #0x1c]
     184: 6b0102bf     	cmp	w21, w1
     188: 54000249     	b.ls	0x1d0 <___pl_fn_1+0x158>
     18c: 14000143     	b	0x698 <___pl_fn_1+0x620>
     190: aa1703e0     	mov	x0, x23
     194: f9401000     	ldr	x0, [x0, #0x20]
     198: aa1803e2     	mov	x2, x24
     19c: b8345802     	str	w2, [x0, w20, uxtw #2]
     1a0: aa1703e0     	mov	x0, x23
     1a4: b9001815     	str	w21, [x0, #0x18]
     1a8: 528000a1     	mov	w1, #0x5                ; =5
     1ac: 52800002     	mov	w2, #0x0                ; =0
     1b0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     1b4: f9400063     	ldr	x3, [x3]
     1b8: d63f0060     	blr	x3
     1bc: 35003180     	cbnz	w0, 0x7ec <___pl_fn_1+0x774>
     1c0: aa1703e0     	mov	x0, x23
     1c4: f9401802     	ldr	x2, [x0, #0x30]
     1c8: b9001814     	str	w20, [x0, #0x18]
     1cc: 14000028     	b	0x26c <___pl_fn_1+0x1f4>
     1d0: aa1703e1     	mov	x1, x23
     1d4: f9403024     	ldr	x4, [x1, #0x60]
     1d8: f9400025     	ldr	x5, [x1]
     1dc: b20007e6     	mov	x6, #0x300000003        ; =12884901891
     1e0: 2a0203e1     	mov	w1, w2
     1e4: 8b010ca3     	add	x3, x5, x1, lsl #3
     1e8: f82258a6     	str	x6, [x5, w2, uxtw #3]
     1ec: 91000484     	add	x4, x4, #0x1
     1f0: f9000464     	str	x4, [x3, #0x8]
     1f4: 92800005     	mov	x5, #-0x1               ; =-1
     1f8: f9000865     	str	x5, [x3, #0x10]
     1fc: d2800005     	mov	x5, #0x0                ; =0
     200: f9000c65     	str	x5, [x3, #0x18]
     204: aa1703e3     	mov	x3, x23
     208: f9003064     	str	x4, [x3, #0x60]
     20c: 91001043     	add	x3, x2, #0x4
     210: aa1703e4     	mov	x4, x23
     214: f9002883     	str	x3, [x4, #0x50]
     218: aa1703e5     	mov	x5, x23
     21c: f94034a3     	ldr	x3, [x5, #0x68]
     220: d1000863     	sub	x3, x3, #0x2
     224: aa1703e8     	mov	x8, x23
     228: f9003503     	str	x3, [x8, #0x68]
     22c: aa1703ea     	mov	x10, x23
     230: f9403943     	ldr	x3, [x10, #0x70]
     234: d1000863     	sub	x3, x3, #0x2
     238: aa1703ed     	mov	x13, x23
     23c: f90039a3     	str	x3, [x13, #0x70]
     240: aa1703ef     	mov	x15, x23
     244: f94041e3     	ldr	x3, [x15, #0x80]
     248: b25e0021     	orr	x1, x1, #0x400000000
     24c: d37cec05     	lsl	x5, x0, #4
     250: 8b001064     	add	x4, x3, x0, lsl #4
     254: f8256861     	str	x1, [x3, x5]
     258: d2800041     	mov	x1, #0x2                ; =2
     25c: f9000481     	str	x1, [x4, #0x8]
     260: 91000400     	add	x0, x0, #0x1
     264: aa1703e1     	mov	x1, x23
     268: f9004420     	str	x0, [x1, #0x88]
     26c: 34002242     	cbz	w2, 0x6b4 <___pl_fn_1+0x63c>
     270: aa1703e0     	mov	x0, x23
     274: f9400009     	ldr	x9, [x0]
     278: 2a0203ea     	mov	w10, w2
     27c: 8b0a0d2a     	add	x10, x9, x10, lsl #3
     280: f940094b     	ldr	x11, [x10, #0x10]
     284: 927ff96b     	and	x11, x11, #0xfffffffffffffffe
     288: f900094b     	str	x11, [x10, #0x10]
     28c: 5284806c     	mov	w12, #0x2403            ; =9219
     290: 72a0002c     	movk	w12, #0x1, lsl #16
     294: 2a0203ed     	mov	w13, w2
     298: aa0203e4     	mov	x4, x2
     29c: 8b0d0d2d     	add	x13, x9, x13, lsl #3
     2a0: f9000dac     	str	x12, [x13, #0x18]
     2a4: d2800013     	mov	x19, #0x0               ; =0
     2a8: f1018e7f     	cmp	x19, #0x63
     2ac: 9a9fc7e0     	cset	x0, le
     2b0: 72001c1f     	tst	w0, #0xff
     2b4: 54000bc1     	b.ne	0x42c <___pl_fn_1+0x3b4>
     2b8: d2800036     	mov	x22, #0x1               ; =1
     2bc: d2800002     	mov	x2, #0x0                ; =0
     2c0: aa0203f5     	mov	x21, x2
     2c4: eb1a02df     	cmp	x22, x26
     2c8: 9a9fc7e0     	cset	x0, le
     2cc: 72001c1f     	tst	w0, #0xff
     2d0: 540002a1     	b.ne	0x324 <___pl_fn_1+0x2ac>
     2d4: 52800141     	mov	w1, #0xa                ; =10
     2d8: 52802003     	mov	w3, #0x100              ; =256
     2dc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     2e0: f9400084     	ldr	x4, [x4]
     2e4: aa1503e2     	mov	x2, x21
     2e8: aa1703e0     	mov	x0, x23
     2ec: d63f0080     	blr	x4
     2f0: 350027e0     	cbnz	w0, 0x7ec <___pl_fn_1+0x774>
     2f4: aa1703e0     	mov	x0, x23
     2f8: b9401000     	ldr	w0, [x0, #0x10]
     2fc: 51000400     	sub	w0, w0, #0x1
     300: aa1703e1     	mov	x1, x23
     304: b9001020     	str	w0, [x1, #0x10]
     308: 9100c3ff     	add	sp, sp, #0x30
     30c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     310: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     314: a8c163f7     	ldp	x23, x24, [sp], #0x10
     318: f84107fa     	ldr	x26, [sp], #0x10
     31c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     320: d65f03c0     	ret
     324: d2800013     	mov	x19, #0x0               ; =0
     328: f1018e7f     	cmp	x19, #0x63
     32c: 9a9fc7e0     	cset	x0, le
     330: 72001c1f     	tst	w0, #0xff
     334: 540000c1     	b.ne	0x34c <___pl_fn_1+0x2d4>
     338: b27ff7e0     	mov	x0, #0x7ffffffffffffffe ; =9223372036854775806
     33c: eb0002df     	cmp	x22, x0
     340: 54001d6c     	b.gt	0x6ec <___pl_fn_1+0x674>
     344: 910006d6     	add	x22, x22, #0x1
     348: 17ffffdf     	b	0x2c4 <___pl_fn_1+0x24c>
     34c: aa1803e2     	mov	x2, x24
     350: 34001d22     	cbz	w2, 0x6f4 <___pl_fn_1+0x67c>
     354: aa1703e0     	mov	x0, x23
     358: f9400000     	ldr	x0, [x0]
     35c: aa1803e2     	mov	x2, x24
     360: 2a0203e1     	mov	w1, w2
     364: 8b010c00     	add	x0, x0, x1, lsl #3
     368: f9400801     	ldr	x1, [x0, #0x10]
     36c: eb01027f     	cmp	x19, x1
     370: 54001c22     	b.hs	0x6f4 <___pl_fn_1+0x67c>
     374: 8b130c00     	add	x0, x0, x19, lsl #3
     378: b9402801     	ldr	w1, [x0, #0x28]
     37c: 34001bc1     	cbz	w1, 0x6f4 <___pl_fn_1+0x67c>
     380: aa1703e0     	mov	x0, x23
     384: b9401814     	ldr	w20, [x0, #0x18]
     388: b9401c00     	ldr	w0, [x0, #0x1c]
     38c: 11000a82     	add	w2, w20, #0x2
     390: 6b00005f     	cmp	w2, w0
     394: 54001d28     	b.hi	0x738 <___pl_fn_1+0x6c0>
     398: aa1703e0     	mov	x0, x23
     39c: f9401000     	ldr	x0, [x0, #0x20]
     3a0: 2a1403e2     	mov	w2, w20
     3a4: 8b020802     	add	x2, x0, x2, lsl #2
     3a8: aa1803e3     	mov	x3, x24
     3ac: b8345803     	str	w3, [x0, w20, uxtw #2]
     3b0: b9000441     	str	w1, [x2, #0x4]
     3b4: 11000a80     	add	w0, w20, #0x2
     3b8: aa1703e2     	mov	x2, x23
     3bc: b9001840     	str	w0, [x2, #0x18]
     3c0: aa1703e0     	mov	x0, x23
     3c4: b9401000     	ldr	w0, [x0, #0x10]
     3c8: b9401442     	ldr	w2, [x2, #0x14]
     3cc: 6b02001f     	cmp	w0, w2
     3d0: 54001b02     	b.hs	0x730 <___pl_fn_1+0x6b8>
     3d4: aa1703e0     	mov	x0, x23
     3d8: 94000000     	bl	0x3d8 <___pl_fn_1+0x360>
     3dc: aa1703e1     	mov	x1, x23
     3e0: b9402c21     	ldr	w1, [x1, #0x2c]
     3e4: 35002041     	cbnz	w1, 0x7ec <___pl_fn_1+0x774>
     3e8: aa1703e1     	mov	x1, x23
     3ec: b9001834     	str	w20, [x1, #0x18]
     3f0: 72001c1f     	tst	w0, #0xff
     3f4: 54000061     	b.ne	0x400 <___pl_fn_1+0x388>
     3f8: aa1503e2     	mov	x2, x21
     3fc: 14000006     	b	0x414 <___pl_fn_1+0x39c>
     400: b27ff7e6     	mov	x6, #0x7ffffffffffffffe ; =9223372036854775806
     404: aa1503e2     	mov	x2, x21
     408: eb06005f     	cmp	x2, x6
     40c: 540018ec     	b.gt	0x728 <___pl_fn_1+0x6b0>
     410: 91000442     	add	x2, x2, #0x1
     414: b27ff7e9     	mov	x9, #0x7ffffffffffffffe ; =9223372036854775806
     418: eb09027f     	cmp	x19, x9
     41c: 5400182c     	b.gt	0x720 <___pl_fn_1+0x6a8>
     420: 91000673     	add	x19, x19, #0x1
     424: aa0203f5     	mov	x21, x2
     428: 17ffffc0     	b	0x328 <___pl_fn_1+0x2b0>
     42c: aa1703e0     	mov	x0, x23
     430: f9403c00     	ldr	x0, [x0, #0x78]
     434: 37381860     	tbnz	w0, #0x7, 0x740 <___pl_fn_1+0x6c8>
     438: aa1703e0     	mov	x0, x23
     43c: f9403800     	ldr	x0, [x0, #0x70]
     440: f100001f     	cmp	x0, #0x0
     444: 5400182d     	b.le	0x748 <___pl_fn_1+0x6d0>
     448: aa1703e0     	mov	x0, x23
     44c: f9403400     	ldr	x0, [x0, #0x68]
     450: f100141f     	cmp	x0, #0x5
     454: 540017eb     	b.lt	0x750 <___pl_fn_1+0x6d8>
     458: aa1703e0     	mov	x0, x23
     45c: f9402801     	ldr	x1, [x0, #0x50]
     460: f9402c00     	ldr	x0, [x0, #0x58]
     464: 91001c22     	add	x2, x1, #0x7
     468: eb00005f     	cmp	x2, x0
     46c: 54001768     	b.hi	0x758 <___pl_fn_1+0x6e0>
     470: aa1703e0     	mov	x0, x23
     474: f9404400     	ldr	x0, [x0, #0x88]
     478: aa1703ee     	mov	x14, x23
     47c: f94049c2     	ldr	x2, [x14, #0x90]
     480: eb02001f     	cmp	x0, x2
     484: 540016e2     	b.hs	0x760 <___pl_fn_1+0x6e8>
     488: aa1703e2     	mov	x2, x23
     48c: b9401842     	ldr	w2, [x2, #0x18]
     490: aa1703e3     	mov	x3, x23
     494: b9401c63     	ldr	w3, [x3, #0x1c]
     498: 11000842     	add	w2, w2, #0x2
     49c: 6b03005f     	cmp	w2, w3
     4a0: 54000309     	b.ls	0x500 <___pl_fn_1+0x488>
     4a4: 140000b1     	b	0x768 <___pl_fn_1+0x6f0>
     4a8: aa1703e0     	mov	x0, x23
     4ac: f9401000     	ldr	x0, [x0, #0x20]
     4b0: 2a1503e1     	mov	w1, w21
     4b4: 8b010801     	add	x1, x0, x1, lsl #2
     4b8: aa1803e2     	mov	x2, x24
     4bc: b8355802     	str	w2, [x0, w21, uxtw #2]
     4c0: aa0403f4     	mov	x20, x4
     4c4: b9000434     	str	w20, [x1, #0x4]
     4c8: 11000aa0     	add	w0, w21, #0x2
     4cc: aa1703e1     	mov	x1, x23
     4d0: b9001820     	str	w0, [x1, #0x18]
     4d4: 52800281     	mov	w1, #0x14               ; =20
     4d8: 52800022     	mov	w2, #0x1                ; =1
     4dc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     4e0: f9400063     	ldr	x3, [x3]
     4e4: aa1703e0     	mov	x0, x23
     4e8: d63f0060     	blr	x3
     4ec: 35001800     	cbnz	w0, 0x7ec <___pl_fn_1+0x774>
     4f0: aa1703e0     	mov	x0, x23
     4f4: f9401801     	ldr	x1, [x0, #0x30]
     4f8: b9001815     	str	w21, [x0, #0x18]
     4fc: 1400002d     	b	0x5b0 <___pl_fn_1+0x538>
     500: aa1703e2     	mov	x2, x23
     504: aa0403f4     	mov	x20, x4
     508: f9403044     	ldr	x4, [x2, #0x60]
     50c: f9400045     	ldr	x5, [x2]
     510: d2800086     	mov	x6, #0x4                ; =4
     514: f2c00066     	movk	x6, #0x3, lsl #32
     518: 2a0103e2     	mov	w2, w1
     51c: 8b020ca3     	add	x3, x5, x2, lsl #3
     520: f82158a6     	str	x6, [x5, w1, uxtw #3]
     524: 91000484     	add	x4, x4, #0x1
     528: f9000464     	str	x4, [x3, #0x8]
     52c: 92800005     	mov	x5, #-0x1               ; =-1
     530: f9000865     	str	x5, [x3, #0x10]
     534: d2800005     	mov	x5, #0x0                ; =0
     538: f9000c65     	str	x5, [x3, #0x18]
     53c: f9001065     	str	x5, [x3, #0x20]
     540: f9001465     	str	x5, [x3, #0x28]
     544: f9001865     	str	x5, [x3, #0x30]
     548: aa1703eb     	mov	x11, x23
     54c: f9003164     	str	x4, [x11, #0x60]
     550: 91001c23     	add	x3, x1, #0x7
     554: aa1703ee     	mov	x14, x23
     558: f90029c3     	str	x3, [x14, #0x50]
     55c: aa1703e3     	mov	x3, x23
     560: f9403463     	ldr	x3, [x3, #0x68]
     564: d1001463     	sub	x3, x3, #0x5
     568: aa1703e4     	mov	x4, x23
     56c: f9003483     	str	x3, [x4, #0x68]
     570: aa1703e3     	mov	x3, x23
     574: f9403863     	ldr	x3, [x3, #0x70]
     578: d1001463     	sub	x3, x3, #0x5
     57c: f9003883     	str	x3, [x4, #0x70]
     580: aa1703e3     	mov	x3, x23
     584: f9404063     	ldr	x3, [x3, #0x80]
     588: b2600842     	orr	x2, x2, #0x700000000
     58c: d37cec05     	lsl	x5, x0, #4
     590: 8b001064     	add	x4, x3, x0, lsl #4
     594: f8256862     	str	x2, [x3, x5]
     598: d28000a2     	mov	x2, #0x5                ; =5
     59c: f9000482     	str	x2, [x4, #0x8]
     5a0: 91000400     	add	x0, x0, #0x1
     5a4: aa1703e2     	mov	x2, x23
     5a8: f9004440     	str	x0, [x2, #0x88]
     5ac: aa1703e0     	mov	x0, x23
     5b0: aa1703e0     	mov	x0, x23
     5b4: b9401815     	ldr	w21, [x0, #0x18]
     5b8: b9401c02     	ldr	w2, [x0, #0x1c]
     5bc: 11000ea0     	add	w0, w21, #0x3
     5c0: 6b02001f     	cmp	w0, w2
     5c4: 54001068     	b.hi	0x7d0 <___pl_fn_1+0x758>
     5c8: aa1703e2     	mov	x2, x23
     5cc: f9401042     	ldr	x2, [x2, #0x20]
     5d0: 2a1503e3     	mov	w3, w21
     5d4: 8b030843     	add	x3, x2, x3, lsl #2
     5d8: aa1803e4     	mov	x4, x24
     5dc: b8355844     	str	w4, [x2, w21, uxtw #2]
     5e0: b9000474     	str	w20, [x3, #0x4]
     5e4: b9000861     	str	w1, [x3, #0x8]
     5e8: aa1703e2     	mov	x2, x23
     5ec: b9001840     	str	w0, [x2, #0x18]
     5f0: aa1703e0     	mov	x0, x23
     5f4: b9401002     	ldr	w2, [x0, #0x10]
     5f8: b9401403     	ldr	w3, [x0, #0x14]
     5fc: 6b03005f     	cmp	w2, w3
     600: 54000e42     	b.hs	0x7c8 <___pl_fn_1+0x750>
     604: aa1703e0     	mov	x0, x23
     608: aa1403e2     	mov	x2, x20
     60c: 94000000     	bl	0x60c <___pl_fn_1+0x594>
     610: aa1703e1     	mov	x1, x23
     614: b9402c23     	ldr	w3, [x1, #0x2c]
     618: 35000ea3     	cbnz	w3, 0x7ec <___pl_fn_1+0x774>
     61c: aa1703e2     	mov	x2, x23
     620: b9001855     	str	w21, [x2, #0x18]
     624: aa1803e2     	mov	x2, x24
     628: 34000b22     	cbz	w2, 0x78c <___pl_fn_1+0x714>
     62c: aa1703e6     	mov	x6, x23
     630: f94000c8     	ldr	x8, [x6]
     634: aa1803e2     	mov	x2, x24
     638: 2a0203e9     	mov	w9, w2
     63c: 8b090d08     	add	x8, x8, x9, lsl #3
     640: f9400909     	ldr	x9, [x8, #0x10]
     644: eb09027f     	cmp	x19, x9
     648: 54000a22     	b.hs	0x78c <___pl_fn_1+0x714>
     64c: 2a0003e0     	mov	w0, w0
     650: 8b130d01     	add	x1, x8, x19, lsl #3
     654: f9001420     	str	x0, [x1, #0x28]
     658: b27ff7e0     	mov	x0, #0x7ffffffffffffffe ; =9223372036854775806
     65c: eb00027f     	cmp	x19, x0
     660: 54000b0c     	b.gt	0x7c0 <___pl_fn_1+0x748>
     664: 91000673     	add	x19, x19, #0x1
     668: aa1403e4     	mov	x4, x20
     66c: 17ffff0f     	b	0x2a8 <___pl_fn_1+0x230>
     670: aa1703e0     	mov	x0, x23
     674: 1400000a     	b	0x69c <___pl_fn_1+0x624>
     678: aa1703e0     	mov	x0, x23
     67c: 14000008     	b	0x69c <___pl_fn_1+0x624>
     680: aa1703e0     	mov	x0, x23
     684: 14000006     	b	0x69c <___pl_fn_1+0x624>
     688: aa1703e0     	mov	x0, x23
     68c: 14000004     	b	0x69c <___pl_fn_1+0x624>
     690: aa1703e0     	mov	x0, x23
     694: 14000002     	b	0x69c <___pl_fn_1+0x624>
     698: aa1703e0     	mov	x0, x23
     69c: aa1703e0     	mov	x0, x23
     6a0: b9401c00     	ldr	w0, [x0, #0x1c]
     6a4: 6b0002bf     	cmp	w21, w0
     6a8: 54ffd749     	b.ls	0x190 <___pl_fn_1+0x118>
     6ac: 52800081     	mov	w1, #0x4                ; =4
     6b0: 1400004b     	b	0x7dc <___pl_fn_1+0x764>
     6b4: d2800004     	mov	x4, #0x0                ; =0
     6b8: 910023e3     	add	x3, sp, #0x8
     6bc: f80083e4     	stur	x4, [sp, #0x8]
     6c0: 52848064     	mov	w4, #0x2403             ; =9219
     6c4: 72a00024     	movk	w4, #0x1, lsl #16
     6c8: f80103e4     	stur	x4, [sp, #0x10]
     6cc: 528000c1     	mov	w1, #0x6                ; =6
     6d0: 90000005     	adrp	x5, 0x0 <___pl_fn_0>
     6d4: f94000a5     	ldr	x5, [x5]
     6d8: aa1703e0     	mov	x0, x23
     6dc: d63f00a0     	blr	x5
     6e0: 35000860     	cbnz	w0, 0x7ec <___pl_fn_1+0x774>
     6e4: 528000e1     	mov	w1, #0x7                ; =7
     6e8: 1400003d     	b	0x7dc <___pl_fn_1+0x764>
     6ec: 52800181     	mov	w1, #0xc                ; =12
     6f0: 1400003b     	b	0x7dc <___pl_fn_1+0x764>
     6f4: 910063e3     	add	x3, sp, #0x18
     6f8: f80183f3     	stur	x19, [sp, #0x18]
     6fc: 528001a1     	mov	w1, #0xd                ; =13
     700: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     704: f9400084     	ldr	x4, [x4]
     708: aa1803e2     	mov	x2, x24
     70c: aa1703e0     	mov	x0, x23
     710: d63f0080     	blr	x4
     714: 350006c0     	cbnz	w0, 0x7ec <___pl_fn_1+0x774>
     718: 528001c1     	mov	w1, #0xe                ; =14
     71c: 14000030     	b	0x7dc <___pl_fn_1+0x764>
     720: 52800241     	mov	w1, #0x12               ; =18
     724: 1400002e     	b	0x7dc <___pl_fn_1+0x764>
     728: 52800221     	mov	w1, #0x11               ; =17
     72c: 1400002c     	b	0x7dc <___pl_fn_1+0x764>
     730: 52800201     	mov	w1, #0x10               ; =16
     734: 1400002a     	b	0x7dc <___pl_fn_1+0x764>
     738: 528001e1     	mov	w1, #0xf                ; =15
     73c: 14000028     	b	0x7dc <___pl_fn_1+0x764>
     740: aa1703e0     	mov	x0, x23
     744: 1400000a     	b	0x76c <___pl_fn_1+0x6f4>
     748: aa1703e0     	mov	x0, x23
     74c: 14000008     	b	0x76c <___pl_fn_1+0x6f4>
     750: aa1703e0     	mov	x0, x23
     754: 14000006     	b	0x76c <___pl_fn_1+0x6f4>
     758: aa1703e0     	mov	x0, x23
     75c: 14000004     	b	0x76c <___pl_fn_1+0x6f4>
     760: aa1703e0     	mov	x0, x23
     764: 14000002     	b	0x76c <___pl_fn_1+0x6f4>
     768: aa1703e0     	mov	x0, x23
     76c: aa1703e0     	mov	x0, x23
     770: b9401815     	ldr	w21, [x0, #0x18]
     774: b9401c00     	ldr	w0, [x0, #0x1c]
     778: 11000aa1     	add	w1, w21, #0x2
     77c: 6b00003f     	cmp	w1, w0
     780: 54ffe949     	b.ls	0x4a8 <___pl_fn_1+0x430>
     784: 52800261     	mov	w1, #0x13               ; =19
     788: 14000015     	b	0x7dc <___pl_fn_1+0x764>
     78c: 910083e3     	add	x3, sp, #0x20
     790: f80203f3     	stur	x19, [sp, #0x20]
     794: 2a0003ec     	mov	w12, w0
     798: f80283ec     	stur	x12, [sp, #0x28]
     79c: 528002e1     	mov	w1, #0x17               ; =23
     7a0: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     7a4: f94001ad     	ldr	x13, [x13]
     7a8: aa1803e2     	mov	x2, x24
     7ac: aa1703e0     	mov	x0, x23
     7b0: d63f01a0     	blr	x13
     7b4: 350001c0     	cbnz	w0, 0x7ec <___pl_fn_1+0x774>
     7b8: 52800301     	mov	w1, #0x18               ; =24
     7bc: 14000008     	b	0x7dc <___pl_fn_1+0x764>
     7c0: 52800321     	mov	w1, #0x19               ; =25
     7c4: 14000006     	b	0x7dc <___pl_fn_1+0x764>
     7c8: 528002c1     	mov	w1, #0x16               ; =22
     7cc: 14000004     	b	0x7dc <___pl_fn_1+0x764>
     7d0: 528002a1     	mov	w1, #0x15               ; =21
     7d4: 14000002     	b	0x7dc <___pl_fn_1+0x764>
     7d8: 52800041     	mov	w1, #0x2                ; =2
     7dc: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     7e0: f9400042     	ldr	x2, [x2]
     7e4: aa1703e0     	mov	x0, x23
     7e8: d63f0040     	blr	x2
     7ec: 9100c3ff     	add	sp, sp, #0x30
     7f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
     7f4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     7f8: a8c163f7     	ldp	x23, x24, [sp], #0x10
     7fc: f84107fa     	ldr	x26, [sp], #0x10
     800: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     804: d65f03c0     	ret

0000000000000808 <___pl_fn_2>:
     808: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     80c: 910003fd     	mov	x29, sp
     810: f81f0ff3     	str	x19, [sp, #-0x10]!
     814: d10043ff     	sub	sp, sp, #0x10
     818: b9401004     	ldr	w4, [x0, #0x10]
     81c: 11000482     	add	w2, w4, #0x1
     820: b9001002     	str	w2, [x0, #0x10]
     824: 34000501     	cbz	w1, 0x8c4 <___pl_fn_2+0xbc>
     828: f9400002     	ldr	x2, [x0]
     82c: aa0003f3     	mov	x19, x0
     830: 2a0103e0     	mov	w0, w1
     834: aa0103e5     	mov	x5, x1
     838: 8b000c41     	add	x1, x2, x0, lsl #3
     83c: f9400c20     	ldr	x0, [x1, #0x18]
     840: f9400822     	ldr	x2, [x1, #0x10]
     844: 37000442     	tbnz	w2, #0x0, 0x8cc <___pl_fn_2+0xc4>
     848: aa0503e2     	mov	x2, x5
     84c: d280a3a5     	mov	x5, #0x51d              ; =1309
     850: 9b057c03     	mul	x3, x0, x5
     854: 9b457c05     	smulh	x5, x0, x5
     858: eb83fcbf     	cmp	x5, x3, asr #63
     85c: 540008a1     	b.ne	0x970 <___pl_fn_2+0x168>
     860: 9286c325     	mov	x5, #-0x361a            ; =-13850
     864: f2efffe5     	movk	x5, #0x7fff, lsl #48
     868: eb05007f     	cmp	x3, x5
     86c: 540007ec     	b.gt	0x968 <___pl_fn_2+0x160>
     870: 34000422     	cbz	w2, 0x8f4 <___pl_fn_2+0xec>
     874: f940082f     	ldr	x15, [x1, #0x10]
     878: 927ff9ef     	and	x15, x15, #0xfffffffffffffffe
     87c: f900082f     	str	x15, [x1, #0x10]
     880: d286c320     	mov	x0, #0x3619             ; =13849
     884: 8b000060     	add	x0, x3, x0
     888: 934ffc03     	asr	x3, x0, #15
     88c: d370fc63     	lsr	x3, x3, #48
     890: 8b030003     	add	x3, x0, x3
     894: 9270bc63     	and	x3, x3, #0xffffffffffff0000
     898: cb030000     	sub	x0, x0, x3
     89c: f9000c20     	str	x0, [x1, #0x18]
     8a0: 34000522     	cbz	w2, 0x944 <___pl_fn_2+0x13c>
     8a4: f9400821     	ldr	x1, [x1, #0x10]
     8a8: 370004e1     	tbnz	w1, #0x0, 0x944 <___pl_fn_2+0x13c>
     8ac: aa1303e1     	mov	x1, x19
     8b0: b9001024     	str	w4, [x1, #0x10]
     8b4: 910043ff     	add	sp, sp, #0x10
     8b8: f84107f3     	ldr	x19, [sp], #0x10
     8bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     8c0: d65f03c0     	ret
     8c4: aa0103e5     	mov	x5, x1
     8c8: aa0003f3     	mov	x19, x0
     8cc: 52800341     	mov	w1, #0x1a               ; =26
     8d0: 52800003     	mov	w3, #0x0                ; =0
     8d4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     8d8: f9400084     	ldr	x4, [x4]
     8dc: aa0503e2     	mov	x2, x5
     8e0: aa1303e0     	mov	x0, x19
     8e4: d63f0080     	blr	x4
     8e8: 350004e0     	cbnz	w0, 0x984 <___pl_fn_2+0x17c>
     8ec: 52800361     	mov	w1, #0x1b               ; =27
     8f0: 14000021     	b	0x974 <___pl_fn_2+0x16c>
     8f4: d2800009     	mov	x9, #0x0                ; =0
     8f8: 910003e8     	mov	x8, sp
     8fc: f80003e9     	stur	x9, [sp]
     900: d286c329     	mov	x9, #0x3619             ; =13849
     904: 8b090069     	add	x9, x3, x9
     908: 934ffd2a     	asr	x10, x9, #15
     90c: d370fd4a     	lsr	x10, x10, #48
     910: 8b0a012a     	add	x10, x9, x10
     914: 9270bd4a     	and	x10, x10, #0xffffffffffff0000
     918: cb0a0129     	sub	x9, x9, x10
     91c: f80083e9     	stur	x9, [sp, #0x8]
     920: 528003e1     	mov	w1, #0x1f               ; =31
     924: 9000000a     	adrp	x10, 0x0 <___pl_fn_0>
     928: f940014a     	ldr	x10, [x10]
     92c: aa0803e3     	mov	x3, x8
     930: aa1303e0     	mov	x0, x19
     934: d63f0140     	blr	x10
     938: 35000260     	cbnz	w0, 0x984 <___pl_fn_2+0x17c>
     93c: 52800401     	mov	w1, #0x20               ; =32
     940: 1400000d     	b	0x974 <___pl_fn_2+0x16c>
     944: 52800421     	mov	w1, #0x21               ; =33
     948: 52800003     	mov	w3, #0x0                ; =0
     94c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     950: f9400084     	ldr	x4, [x4]
     954: aa1303e0     	mov	x0, x19
     958: d63f0080     	blr	x4
     95c: 35000140     	cbnz	w0, 0x984 <___pl_fn_2+0x17c>
     960: 52800441     	mov	w1, #0x22               ; =34
     964: 14000004     	b	0x974 <___pl_fn_2+0x16c>
     968: 528003a1     	mov	w1, #0x1d               ; =29
     96c: 14000002     	b	0x974 <___pl_fn_2+0x16c>
     970: 52800381     	mov	w1, #0x1c               ; =28
     974: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     978: f9400042     	ldr	x2, [x2]
     97c: aa1303e0     	mov	x0, x19
     980: d63f0040     	blr	x2
     984: d2800000     	mov	x0, #0x0                ; =0
     988: 910043ff     	add	sp, sp, #0x10
     98c: f84107f3     	ldr	x19, [sp], #0x10
     990: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     994: d65f03c0     	ret

0000000000000998 <___pl_fn_3>:
     998: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     99c: 910003fd     	mov	x29, sp
     9a0: f81f0ffc     	str	x28, [sp, #-0x10]!
     9a4: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
     9a8: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     9ac: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     9b0: d10103ff     	sub	sp, sp, #0x40
     9b4: aa0103f7     	mov	x23, x1
     9b8: aa0203f8     	mov	x24, x2
     9bc: b940100b     	ldr	w11, [x0, #0x10]
     9c0: 1100056c     	add	w12, w11, #0x1
     9c4: b900100c     	str	w12, [x0, #0x10]
     9c8: b940140d     	ldr	w13, [x0, #0x14]
     9cc: aa0003f6     	mov	x22, x0
     9d0: 1100056e     	add	w14, w11, #0x1
     9d4: 6b0d01df     	cmp	w14, w13
     9d8: 54001c02     	b.hs	0xd58 <___pl_fn_3+0x3c0>
     9dc: aa1603e0     	mov	x0, x22
     9e0: aa1803e1     	mov	x1, x24
     9e4: 94000000     	bl	0x9e4 <___pl_fn_3+0x4c>
     9e8: aa1603e1     	mov	x1, x22
     9ec: b9402c2f     	ldr	w15, [x1, #0x2c]
     9f0: 35001bef     	cbnz	w15, 0xd6c <___pl_fn_3+0x3d4>
     9f4: aa1703e1     	mov	x1, x23
     9f8: 34001141     	cbz	w1, 0xc20 <___pl_fn_3+0x288>
     9fc: aa1603e1     	mov	x1, x22
     a00: f9400021     	ldr	x1, [x1]
     a04: aa1703e2     	mov	x2, x23
     a08: 2a0203e2     	mov	w2, w2
     a0c: 8b020c22     	add	x2, x1, x2, lsl #3
     a10: f9400843     	ldr	x3, [x2, #0x10]
     a14: 927ff863     	and	x3, x3, #0xfffffffffffffffe
     a18: f9000843     	str	x3, [x2, #0x10]
     a1c: d29ef9f4     	mov	x20, #0xf7cf            ; =63439
     a20: f2bc6a74     	movk	x20, #0xe353, lsl #16
     a24: f2d374b4     	movk	x20, #0x9ba5, lsl #32
     a28: f2e41894     	movk	x20, #0x20c4, lsl #48
     a2c: 9b547c02     	smulh	x2, x0, x20
     a30: 9346fc42     	asr	x2, x2, #6
     a34: d37ffc43     	lsr	x3, x2, #63
     a38: 8b030042     	add	x2, x2, x3
     a3c: d2803e95     	mov	x21, #0x1f4             ; =500
     a40: 9b158040     	msub	x0, x2, x21, x0
     a44: aa1703e2     	mov	x2, x23
     a48: 2a0203fc     	mov	w28, w2
     a4c: d2800073     	mov	x19, #0x3               ; =3
     a50: 8b1c0c21     	add	x1, x1, x28, lsl #3
     a54: f9000c20     	str	x0, [x1, #0x18]
     a58: aa1603e0     	mov	x0, x22
     a5c: b9401000     	ldr	w0, [x0, #0x10]
     a60: aa1603ef     	mov	x15, x22
     a64: b94015e1     	ldr	w1, [x15, #0x14]
     a68: 6b01001f     	cmp	w0, w1
     a6c: 54001722     	b.hs	0xd50 <___pl_fn_3+0x3b8>
     a70: aa1603e0     	mov	x0, x22
     a74: aa1803e1     	mov	x1, x24
     a78: 94000000     	bl	0xa78 <___pl_fn_3+0xe0>
     a7c: aa1603e1     	mov	x1, x22
     a80: b9402c21     	ldr	w1, [x1, #0x2c]
     a84: 35001741     	cbnz	w1, 0xd6c <___pl_fn_3+0x3d4>
     a88: aa1703e2     	mov	x2, x23
     a8c: 34000f82     	cbz	w2, 0xc7c <___pl_fn_3+0x2e4>
     a90: aa1603e1     	mov	x1, x22
     a94: f9400021     	ldr	x1, [x1]
     a98: 8b1c0c22     	add	x2, x1, x28, lsl #3
     a9c: f9400843     	ldr	x3, [x2, #0x10]
     aa0: 927ef863     	and	x3, x3, #0xfffffffffffffffd
     aa4: f9000843     	str	x3, [x2, #0x10]
     aa8: 9b547c02     	smulh	x2, x0, x20
     aac: 9346fc42     	asr	x2, x2, #6
     ab0: d37ffc43     	lsr	x3, x2, #63
     ab4: 8b030042     	add	x2, x2, x3
     ab8: 9b158040     	msub	x0, x2, x21, x0
     abc: 8b1c0c21     	add	x1, x1, x28, lsl #3
     ac0: f9001020     	str	x0, [x1, #0x20]
     ac4: aa1603e0     	mov	x0, x22
     ac8: b9401000     	ldr	w0, [x0, #0x10]
     acc: aa1603e1     	mov	x1, x22
     ad0: b9401421     	ldr	w1, [x1, #0x14]
     ad4: 6b01001f     	cmp	w0, w1
     ad8: 54001382     	b.hs	0xd48 <___pl_fn_3+0x3b0>
     adc: aa1603e0     	mov	x0, x22
     ae0: aa1803e1     	mov	x1, x24
     ae4: 94000000     	bl	0xae4 <___pl_fn_3+0x14c>
     ae8: aa1603e3     	mov	x3, x22
     aec: b9402c61     	ldr	w1, [x3, #0x2c]
     af0: 350013e1     	cbnz	w1, 0xd6c <___pl_fn_3+0x3d4>
     af4: d28740e1     	mov	x1, #0x3a07             ; =14855
     af8: f2b40da1     	movk	x1, #0xa06d, lsl #16
     afc: f2c0da61     	movk	x1, #0x6d3, lsl #32
     b00: f2eda741     	movk	x1, #0x6d3a, lsl #48
     b04: 9b417c01     	smulh	x1, x0, x1
     b08: 9347fc21     	asr	x1, x1, #7
     b0c: d37ffc22     	lsr	x2, x1, #63
     b10: 8b020021     	add	x1, x1, x2
     b14: d2802582     	mov	x2, #0x12c              ; =300
     b18: 9b028020     	msub	x0, x1, x2, x0
     b1c: d28012c1     	mov	x1, #0x96               ; =150
     b20: f2f00001     	movk	x1, #0x8000, lsl #48
     b24: eb01001f     	cmp	x0, x1
     b28: 540010cb     	b.lt	0xd40 <___pl_fn_3+0x3a8>
     b2c: aa1703e2     	mov	x2, x23
     b30: 34000ca2     	cbz	w2, 0xcc4 <___pl_fn_3+0x32c>
     b34: aa1603e1     	mov	x1, x22
     b38: f9400021     	ldr	x1, [x1]
     b3c: 8b1c0c22     	add	x2, x1, x28, lsl #3
     b40: f9400843     	ldr	x3, [x2, #0x10]
     b44: 927df863     	and	x3, x3, #0xfffffffffffffffb
     b48: f9000843     	str	x3, [x2, #0x10]
     b4c: d1025802     	sub	x2, x0, #0x96
     b50: 8b1c0c21     	add	x1, x1, x28, lsl #3
     b54: f9001422     	str	x2, [x1, #0x28]
     b58: aa1603e0     	mov	x0, x22
     b5c: b9401003     	ldr	w3, [x0, #0x10]
     b60: b9401404     	ldr	w4, [x0, #0x14]
     b64: 6b04007f     	cmp	w3, w4
     b68: 54000e82     	b.hs	0xd38 <___pl_fn_3+0x3a0>
     b6c: aa1803e1     	mov	x1, x24
     b70: aa1603e0     	mov	x0, x22
     b74: 94000000     	bl	0xb74 <___pl_fn_3+0x1dc>
     b78: aa1603e1     	mov	x1, x22
     b7c: b9402c25     	ldr	w5, [x1, #0x2c]
     b80: 35000f65     	cbnz	w5, 0xd6c <___pl_fn_3+0x3d4>
     b84: d28740e8     	mov	x8, #0x3a07             ; =14855
     b88: f2b40da8     	movk	x8, #0xa06d, lsl #16
     b8c: f2c0da68     	movk	x8, #0x6d3, lsl #32
     b90: f2eda748     	movk	x8, #0x6d3a, lsl #48
     b94: 9b487c08     	smulh	x8, x0, x8
     b98: 9347fd08     	asr	x8, x8, #7
     b9c: d37ffd09     	lsr	x9, x8, #63
     ba0: 8b090108     	add	x8, x8, x9
     ba4: d2802589     	mov	x9, #0x12c              ; =300
     ba8: 9b098108     	msub	x8, x8, x9, x0
     bac: d28012c9     	mov	x9, #0x96               ; =150
     bb0: f2f00009     	movk	x9, #0x8000, lsl #48
     bb4: eb09011f     	cmp	x8, x9
     bb8: 54000bcb     	b.lt	0xd30 <___pl_fn_3+0x398>
     bbc: aa1703e2     	mov	x2, x23
     bc0: 340009e2     	cbz	w2, 0xcfc <___pl_fn_3+0x364>
     bc4: aa1603e0     	mov	x0, x22
     bc8: f9400000     	ldr	x0, [x0]
     bcc: 8b1c0c01     	add	x1, x0, x28, lsl #3
     bd0: f9400822     	ldr	x2, [x1, #0x10]
     bd4: 927cf842     	and	x2, x2, #0xfffffffffffffff7
     bd8: f9000822     	str	x2, [x1, #0x10]
     bdc: d1025901     	sub	x1, x8, #0x96
     be0: 8b1c0c00     	add	x0, x0, x28, lsl #3
     be4: f9001801     	str	x1, [x0, #0x30]
     be8: aa1603e0     	mov	x0, x22
     bec: b9401000     	ldr	w0, [x0, #0x10]
     bf0: 51000400     	sub	w0, w0, #0x1
     bf4: aa1603e1     	mov	x1, x22
     bf8: b9001020     	str	w0, [x1, #0x10]
     bfc: aa1703e0     	mov	x0, x23
     c00: 910103ff     	add	sp, sp, #0x40
     c04: a8c153f3     	ldp	x19, x20, [sp], #0x10
     c08: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     c0c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     c10: f84107fc     	ldr	x28, [sp], #0x10
     c14: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     c18: d65f03c0     	ret
     c1c: 14000054     	b	0xd6c <___pl_fn_3+0x3d4>
     c20: d2800001     	mov	x1, #0x0                ; =0
     c24: 910003e3     	mov	x3, sp
     c28: f80003e1     	stur	x1, [sp]
     c2c: d29ef9e1     	mov	x1, #0xf7cf             ; =63439
     c30: f2bc6a61     	movk	x1, #0xe353, lsl #16
     c34: f2d374a1     	movk	x1, #0x9ba5, lsl #32
     c38: f2e41881     	movk	x1, #0x20c4, lsl #48
     c3c: 9b417c01     	smulh	x1, x0, x1
     c40: 9346fc21     	asr	x1, x1, #6
     c44: d37ffc22     	lsr	x2, x1, #63
     c48: 8b020021     	add	x1, x1, x2
     c4c: d2803e82     	mov	x2, #0x1f4              ; =500
     c50: 9b028020     	msub	x0, x1, x2, x0
     c54: f80083e0     	stur	x0, [sp, #0x8]
     c58: 528004a1     	mov	w1, #0x25               ; =37
     c5c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     c60: f9400084     	ldr	x4, [x4]
     c64: aa1703e2     	mov	x2, x23
     c68: aa1603e0     	mov	x0, x22
     c6c: d63f0080     	blr	x4
     c70: 350007e0     	cbnz	w0, 0xd6c <___pl_fn_3+0x3d4>
     c74: 528004c1     	mov	w1, #0x26               ; =38
     c78: 14000039     	b	0xd5c <___pl_fn_3+0x3c4>
     c7c: d2800021     	mov	x1, #0x1                ; =1
     c80: 910043e3     	add	x3, sp, #0x10
     c84: f80103e1     	stur	x1, [sp, #0x10]
     c88: 9b547c01     	smulh	x1, x0, x20
     c8c: 9346fc21     	asr	x1, x1, #6
     c90: d37ffc22     	lsr	x2, x1, #63
     c94: 8b020021     	add	x1, x1, x2
     c98: 9b158020     	msub	x0, x1, x21, x0
     c9c: f80183e0     	stur	x0, [sp, #0x18]
     ca0: 52800521     	mov	w1, #0x29               ; =41
     ca4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     ca8: f9400084     	ldr	x4, [x4]
     cac: aa1703e2     	mov	x2, x23
     cb0: aa1603e0     	mov	x0, x22
     cb4: d63f0080     	blr	x4
     cb8: 350005a0     	cbnz	w0, 0xd6c <___pl_fn_3+0x3d4>
     cbc: 52800541     	mov	w1, #0x2a               ; =42
     cc0: 14000027     	b	0xd5c <___pl_fn_3+0x3c4>
     cc4: d2800041     	mov	x1, #0x2                ; =2
     cc8: 910083e3     	add	x3, sp, #0x20
     ccc: f80203e1     	stur	x1, [sp, #0x20]
     cd0: d1025800     	sub	x0, x0, #0x96
     cd4: f80283e0     	stur	x0, [sp, #0x28]
     cd8: 528005c1     	mov	w1, #0x2e               ; =46
     cdc: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     ce0: f9400084     	ldr	x4, [x4]
     ce4: aa1703e2     	mov	x2, x23
     ce8: aa1603e0     	mov	x0, x22
     cec: d63f0080     	blr	x4
     cf0: 350003e0     	cbnz	w0, 0xd6c <___pl_fn_3+0x3d4>
     cf4: 528005e1     	mov	w1, #0x2f               ; =47
     cf8: 14000019     	b	0xd5c <___pl_fn_3+0x3c4>
     cfc: 9100c3e3     	add	x3, sp, #0x30
     d00: f80303f3     	stur	x19, [sp, #0x30]
     d04: d102590c     	sub	x12, x8, #0x96
     d08: f80383ec     	stur	x12, [sp, #0x38]
     d0c: 52800661     	mov	w1, #0x33               ; =51
     d10: 9000000d     	adrp	x13, 0x0 <___pl_fn_0>
     d14: f94001ad     	ldr	x13, [x13]
     d18: aa1703e2     	mov	x2, x23
     d1c: aa1603e0     	mov	x0, x22
     d20: d63f01a0     	blr	x13
     d24: 35000240     	cbnz	w0, 0xd6c <___pl_fn_3+0x3d4>
     d28: 52800681     	mov	w1, #0x34               ; =52
     d2c: 1400000c     	b	0xd5c <___pl_fn_3+0x3c4>
     d30: 52800641     	mov	w1, #0x32               ; =50
     d34: 1400000a     	b	0xd5c <___pl_fn_3+0x3c4>
     d38: 52800601     	mov	w1, #0x30               ; =48
     d3c: 14000008     	b	0xd5c <___pl_fn_3+0x3c4>
     d40: 528005a1     	mov	w1, #0x2d               ; =45
     d44: 14000006     	b	0xd5c <___pl_fn_3+0x3c4>
     d48: 52800561     	mov	w1, #0x2b               ; =43
     d4c: 14000004     	b	0xd5c <___pl_fn_3+0x3c4>
     d50: 528004e1     	mov	w1, #0x27               ; =39
     d54: 14000002     	b	0xd5c <___pl_fn_3+0x3c4>
     d58: 52800461     	mov	w1, #0x23               ; =35
     d5c: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     d60: f9400042     	ldr	x2, [x2]
     d64: aa1603e0     	mov	x0, x22
     d68: d63f0040     	blr	x2
     d6c: 52800000     	mov	w0, #0x0                ; =0
     d70: 910103ff     	add	sp, sp, #0x40
     d74: a8c153f3     	ldp	x19, x20, [sp], #0x10
     d78: a8c15bf5     	ldp	x21, x22, [sp], #0x10
     d7c: a8c163f7     	ldp	x23, x24, [sp], #0x10
     d80: f84107fc     	ldr	x28, [sp], #0x10
     d84: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     d88: d65f03c0     	ret

0000000000000d8c <___pl_fn_4>:
     d8c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
     d90: 910003fd     	mov	x29, sp
     d94: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
     d98: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
     d9c: d10283ff     	sub	sp, sp, #0xa0
     da0: b9401005     	ldr	w5, [x0, #0x10]
     da4: 110004a6     	add	w6, w5, #0x1
     da8: b9001006     	str	w6, [x0, #0x10]
     dac: 340020a1     	cbz	w1, 0x11c0 <___pl_fn_4+0x434>
     db0: f9400009     	ldr	x9, [x0]
     db4: aa0003f5     	mov	x21, x0
     db8: 2a0103f3     	mov	w19, w1
     dbc: aa0103f6     	mov	x22, x1
     dc0: 8b130d29     	add	x9, x9, x19, lsl #3
     dc4: f9400d2a     	ldr	x10, [x9, #0x18]
     dc8: f940092b     	ldr	x11, [x9, #0x10]
     dcc: 37001feb     	tbnz	w11, #0x0, 0x11c8 <___pl_fn_4+0x43c>
     dd0: aa1603e2     	mov	x2, x22
     dd4: 340020e2     	cbz	w2, 0x11f0 <___pl_fn_4+0x464>
     dd8: f9401520     	ldr	x0, [x9, #0x28]
     ddc: f9400921     	ldr	x1, [x9, #0x10]
     de0: 37102081     	tbnz	w1, #0x2, 0x11f0 <___pl_fn_4+0x464>
     de4: ab000140     	adds	x0, x10, x0
     de8: 9a9f77e1     	cset	x1, vs
     dec: 72001c3f     	tst	w1, #0xff
     df0: 54003f21     	b.ne	0x15d4 <___pl_fn_4+0x848>
     df4: 34002102     	cbz	w2, 0x1214 <___pl_fn_4+0x488>
     df8: f9400921     	ldr	x1, [x9, #0x10]
     dfc: 927ff821     	and	x1, x1, #0xfffffffffffffffe
     e00: f9000921     	str	x1, [x9, #0x10]
     e04: f9000d20     	str	x0, [x9, #0x18]
     e08: 340021e2     	cbz	w2, 0x1244 <___pl_fn_4+0x4b8>
     e0c: f9401120     	ldr	x0, [x9, #0x20]
     e10: f9400921     	ldr	x1, [x9, #0x10]
     e14: 37082181     	tbnz	w1, #0x1, 0x1244 <___pl_fn_4+0x4b8>
     e18: 34002282     	cbz	w2, 0x1268 <___pl_fn_4+0x4dc>
     e1c: f9401921     	ldr	x1, [x9, #0x30]
     e20: f9400923     	ldr	x3, [x9, #0x10]
     e24: 37182223     	tbnz	w3, #0x3, 0x1268 <___pl_fn_4+0x4dc>
     e28: ab010000     	adds	x0, x0, x1
     e2c: 9a9f77e1     	cset	x1, vs
     e30: 72001c3f     	tst	w1, #0xff
     e34: 54003cc1     	b.ne	0x15cc <___pl_fn_4+0x840>
     e38: 340022a2     	cbz	w2, 0x128c <___pl_fn_4+0x500>
     e3c: f9400928     	ldr	x8, [x9, #0x10]
     e40: 927ef908     	and	x8, x8, #0xfffffffffffffffd
     e44: f9000928     	str	x8, [x9, #0x10]
     e48: f9001120     	str	x0, [x9, #0x20]
     e4c: 34002382     	cbz	w2, 0x12bc <___pl_fn_4+0x530>
     e50: f9400d2e     	ldr	x14, [x9, #0x18]
     e54: f940092f     	ldr	x15, [x9, #0x10]
     e58: 3700232f     	tbnz	w15, #0x0, 0x12bc <___pl_fn_4+0x530>
     e5c: f107d1df     	cmp	x14, #0x1f4
     e60: 5400008c     	b.gt	0xe70 <___pl_fn_4+0xe4>
     e64: 52800000     	mov	w0, #0x0                ; =0
     e68: aa0203f6     	mov	x22, x2
     e6c: 14000026     	b	0xf04 <___pl_fn_4+0x178>
     e70: 34002382     	cbz	w2, 0x12e0 <___pl_fn_4+0x554>
     e74: f9400920     	ldr	x0, [x9, #0x10]
     e78: 927ff800     	and	x0, x0, #0xfffffffffffffffe
     e7c: f9000920     	str	x0, [x9, #0x10]
     e80: d2803e80     	mov	x0, #0x1f4              ; =500
     e84: f9000d20     	str	x0, [x9, #0x18]
     e88: 34002462     	cbz	w2, 0x1314 <___pl_fn_4+0x588>
     e8c: f9401521     	ldr	x1, [x9, #0x28]
     e90: f9400920     	ldr	x0, [x9, #0x10]
     e94: 37102400     	tbnz	w0, #0x2, 0x1314 <___pl_fn_4+0x588>
     e98: aa0203f6     	mov	x22, x2
     e9c: aa1503e0     	mov	x0, x21
     ea0: b9401400     	ldr	w0, [x0, #0x14]
     ea4: 110004a2     	add	w2, w5, #0x1
     ea8: 6b00005f     	cmp	w2, w0
     eac: 540038c2     	b.hs	0x15c4 <___pl_fn_4+0x838>
     eb0: aa1503e0     	mov	x0, x21
     eb4: 94000000     	bl	0xeb4 <___pl_fn_4+0x128>
     eb8: aa1503e9     	mov	x9, x21
     ebc: b9402d21     	ldr	w1, [x9, #0x2c]
     ec0: 35003941     	cbnz	w1, 0x15e8 <___pl_fn_4+0x85c>
     ec4: b24107e1     	mov	x1, #-0x7fffffffffffffff ; =-9223372036854775807
     ec8: eb01001f     	cmp	x0, x1
     ecc: 5400378b     	b.lt	0x15bc <___pl_fn_4+0x830>
     ed0: aa1603e2     	mov	x2, x22
     ed4: 34002322     	cbz	w2, 0x1338 <___pl_fn_4+0x5ac>
     ed8: aa1503e1     	mov	x1, x21
     edc: f9400021     	ldr	x1, [x1]
     ee0: 8b130c22     	add	x2, x1, x19, lsl #3
     ee4: f9400843     	ldr	x3, [x2, #0x10]
     ee8: 927df863     	and	x3, x3, #0xfffffffffffffffb
     eec: f9000843     	str	x3, [x2, #0x10]
     ef0: cb0003e0     	neg	x0, x0
     ef4: 8b130c21     	add	x1, x1, x19, lsl #3
     ef8: f9001420     	str	x0, [x1, #0x28]
     efc: 52800020     	mov	w0, #0x1                ; =1
     f00: aa1603e2     	mov	x2, x22
     f04: aa1603e2     	mov	x2, x22
     f08: 34002342     	cbz	w2, 0x1370 <___pl_fn_4+0x5e4>
     f0c: aa1503e1     	mov	x1, x21
     f10: f9400025     	ldr	x5, [x1]
     f14: 8b130ca6     	add	x6, x5, x19, lsl #3
     f18: f9400cc5     	ldr	x5, [x6, #0x18]
     f1c: f94008c6     	ldr	x6, [x6, #0x10]
     f20: 37002286     	tbnz	w6, #0x0, 0x1370 <___pl_fn_4+0x5e4>
     f24: d2800014     	mov	x20, #0x0               ; =0
     f28: f10000bf     	cmp	x5, #0x0
     f2c: 5400006b     	b.lt	0xf38 <___pl_fn_4+0x1ac>
     f30: aa1603e2     	mov	x2, x22
     f34: 1400002a     	b	0xfdc <___pl_fn_4+0x250>
     f38: aa1603e2     	mov	x2, x22
     f3c: 340022e2     	cbz	w2, 0x1398 <___pl_fn_4+0x60c>
     f40: aa1503e0     	mov	x0, x21
     f44: f9400000     	ldr	x0, [x0]
     f48: 8b130c01     	add	x1, x0, x19, lsl #3
     f4c: f9400822     	ldr	x2, [x1, #0x10]
     f50: 927ff842     	and	x2, x2, #0xfffffffffffffffe
     f54: f9000822     	str	x2, [x1, #0x10]
     f58: 8b130c00     	add	x0, x0, x19, lsl #3
     f5c: f9000c14     	str	x20, [x0, #0x18]
     f60: aa1603e2     	mov	x2, x22
     f64: 34002322     	cbz	w2, 0x13c8 <___pl_fn_4+0x63c>
     f68: aa1503e0     	mov	x0, x21
     f6c: f9400000     	ldr	x0, [x0]
     f70: 8b130c00     	add	x0, x0, x19, lsl #3
     f74: f9401401     	ldr	x1, [x0, #0x28]
     f78: f9400800     	ldr	x0, [x0, #0x10]
     f7c: 37102260     	tbnz	w0, #0x2, 0x13c8 <___pl_fn_4+0x63c>
     f80: aa1503e0     	mov	x0, x21
     f84: b9401000     	ldr	w0, [x0, #0x10]
     f88: aa1503e2     	mov	x2, x21
     f8c: b9401442     	ldr	w2, [x2, #0x14]
     f90: 6b02001f     	cmp	w0, w2
     f94: 54003102     	b.hs	0x15b4 <___pl_fn_4+0x828>
     f98: aa1503e0     	mov	x0, x21
     f9c: 94000000     	bl	0xf9c <___pl_fn_4+0x210>
     fa0: aa1503e1     	mov	x1, x21
     fa4: b9402c21     	ldr	w1, [x1, #0x2c]
     fa8: 35003201     	cbnz	w1, 0x15e8 <___pl_fn_4+0x85c>
     fac: aa1603e2     	mov	x2, x22
     fb0: 34002202     	cbz	w2, 0x13f0 <___pl_fn_4+0x664>
     fb4: aa1503e9     	mov	x9, x21
     fb8: f9400121     	ldr	x1, [x9]
     fbc: 8b130c22     	add	x2, x1, x19, lsl #3
     fc0: f9400843     	ldr	x3, [x2, #0x10]
     fc4: 927df863     	and	x3, x3, #0xfffffffffffffffb
     fc8: f9000843     	str	x3, [x2, #0x10]
     fcc: 8b130c21     	add	x1, x1, x19, lsl #3
     fd0: f9001420     	str	x0, [x1, #0x28]
     fd4: 52800020     	mov	w0, #0x1                ; =1
     fd8: aa1603e2     	mov	x2, x22
     fdc: aa1603e2     	mov	x2, x22
     fe0: 34002222     	cbz	w2, 0x1424 <___pl_fn_4+0x698>
     fe4: aa1503e1     	mov	x1, x21
     fe8: f9400021     	ldr	x1, [x1]
     fec: 8b130c22     	add	x2, x1, x19, lsl #3
     ff0: f9401041     	ldr	x1, [x2, #0x20]
     ff4: f9400842     	ldr	x2, [x2, #0x10]
     ff8: 37082162     	tbnz	w2, #0x1, 0x1424 <___pl_fn_4+0x698>
     ffc: f107d03f     	cmp	x1, #0x1f4
    1000: 5400006c     	b.gt	0x100c <___pl_fn_4+0x280>
    1004: aa1603e2     	mov	x2, x22
    1008: 1400002f     	b	0x10c4 <___pl_fn_4+0x338>
    100c: aa1603e2     	mov	x2, x22
    1010: 340021e2     	cbz	w2, 0x144c <___pl_fn_4+0x6c0>
    1014: aa1503e0     	mov	x0, x21
    1018: f940000c     	ldr	x12, [x0]
    101c: 8b130d8d     	add	x13, x12, x19, lsl #3
    1020: f94009ae     	ldr	x14, [x13, #0x10]
    1024: 927ef9ce     	and	x14, x14, #0xfffffffffffffffd
    1028: f90009ae     	str	x14, [x13, #0x10]
    102c: d2803e8f     	mov	x15, #0x1f4             ; =500
    1030: 8b130d80     	add	x0, x12, x19, lsl #3
    1034: f900100f     	str	x15, [x0, #0x20]
    1038: aa1603e2     	mov	x2, x22
    103c: 34002242     	cbz	w2, 0x1484 <___pl_fn_4+0x6f8>
    1040: aa1503e0     	mov	x0, x21
    1044: f9400000     	ldr	x0, [x0]
    1048: 8b130c00     	add	x0, x0, x19, lsl #3
    104c: f9401801     	ldr	x1, [x0, #0x30]
    1050: f9400800     	ldr	x0, [x0, #0x10]
    1054: 37182180     	tbnz	w0, #0x3, 0x1484 <___pl_fn_4+0x6f8>
    1058: aa1503e0     	mov	x0, x21
    105c: b9401000     	ldr	w0, [x0, #0x10]
    1060: aa1503e2     	mov	x2, x21
    1064: b9401442     	ldr	w2, [x2, #0x14]
    1068: 6b02001f     	cmp	w0, w2
    106c: 54002a02     	b.hs	0x15ac <___pl_fn_4+0x820>
    1070: aa1503e0     	mov	x0, x21
    1074: 94000000     	bl	0x1074 <___pl_fn_4+0x2e8>
    1078: aa1503e1     	mov	x1, x21
    107c: b9402c21     	ldr	w1, [x1, #0x2c]
    1080: 35002b41     	cbnz	w1, 0x15e8 <___pl_fn_4+0x85c>
    1084: b24107e1     	mov	x1, #-0x7fffffffffffffff ; =-9223372036854775807
    1088: eb01001f     	cmp	x0, x1
    108c: 540028cb     	b.lt	0x15a4 <___pl_fn_4+0x818>
    1090: aa1603e2     	mov	x2, x22
    1094: 340020c2     	cbz	w2, 0x14ac <___pl_fn_4+0x720>
    1098: aa1503e1     	mov	x1, x21
    109c: f9400021     	ldr	x1, [x1]
    10a0: 8b130c22     	add	x2, x1, x19, lsl #3
    10a4: f9400843     	ldr	x3, [x2, #0x10]
    10a8: 927cf863     	and	x3, x3, #0xfffffffffffffff7
    10ac: f9000843     	str	x3, [x2, #0x10]
    10b0: cb0003e0     	neg	x0, x0
    10b4: 8b130c21     	add	x1, x1, x19, lsl #3
    10b8: f9001820     	str	x0, [x1, #0x30]
    10bc: 52800020     	mov	w0, #0x1                ; =1
    10c0: aa1603e2     	mov	x2, x22
    10c4: aa1603e2     	mov	x2, x22
    10c8: 340020e2     	cbz	w2, 0x14e4 <___pl_fn_4+0x758>
    10cc: aa1503e9     	mov	x9, x21
    10d0: f9400121     	ldr	x1, [x9]
    10d4: 8b130c22     	add	x2, x1, x19, lsl #3
    10d8: f9401041     	ldr	x1, [x2, #0x20]
    10dc: f9400842     	ldr	x2, [x2, #0x10]
    10e0: 37082022     	tbnz	w2, #0x1, 0x14e4 <___pl_fn_4+0x758>
    10e4: f100003f     	cmp	x1, #0x0
    10e8: 5400006b     	b.lt	0x10f4 <___pl_fn_4+0x368>
    10ec: aa1503e1     	mov	x1, x21
    10f0: 1400002a     	b	0x1198 <___pl_fn_4+0x40c>
    10f4: aa1603e2     	mov	x2, x22
    10f8: 340020a2     	cbz	w2, 0x150c <___pl_fn_4+0x780>
    10fc: aa1503e0     	mov	x0, x21
    1100: f9400003     	ldr	x3, [x0]
    1104: 8b130c64     	add	x4, x3, x19, lsl #3
    1108: f9400885     	ldr	x5, [x4, #0x10]
    110c: 927ef8a5     	and	x5, x5, #0xfffffffffffffffd
    1110: f9000885     	str	x5, [x4, #0x10]
    1114: 8b130c66     	add	x6, x3, x19, lsl #3
    1118: f90010d4     	str	x20, [x6, #0x20]
    111c: aa1603e2     	mov	x2, x22
    1120: 34002102     	cbz	w2, 0x1540 <___pl_fn_4+0x7b4>
    1124: aa1503e0     	mov	x0, x21
    1128: f940000a     	ldr	x10, [x0]
    112c: 8b130d4a     	add	x10, x10, x19, lsl #3
    1130: f9401941     	ldr	x1, [x10, #0x30]
    1134: f940094b     	ldr	x11, [x10, #0x10]
    1138: 3718204b     	tbnz	w11, #0x3, 0x1540 <___pl_fn_4+0x7b4>
    113c: aa1503e0     	mov	x0, x21
    1140: b9401000     	ldr	w0, [x0, #0x10]
    1144: aa1503ed     	mov	x13, x21
    1148: b94015a2     	ldr	w2, [x13, #0x14]
    114c: 6b02001f     	cmp	w0, w2
    1150: 54002262     	b.hs	0x159c <___pl_fn_4+0x810>
    1154: aa1503e0     	mov	x0, x21
    1158: 94000000     	bl	0x1158 <___pl_fn_4+0x3cc>
    115c: aa1503e1     	mov	x1, x21
    1160: b9402c21     	ldr	w1, [x1, #0x2c]
    1164: 35002421     	cbnz	w1, 0x15e8 <___pl_fn_4+0x85c>
    1168: aa1603e2     	mov	x2, x22
    116c: 34001fe2     	cbz	w2, 0x1568 <___pl_fn_4+0x7dc>
    1170: aa1503e1     	mov	x1, x21
    1174: f9400021     	ldr	x1, [x1]
    1178: 8b130c22     	add	x2, x1, x19, lsl #3
    117c: f9400843     	ldr	x3, [x2, #0x10]
    1180: 927cf863     	and	x3, x3, #0xfffffffffffffff7
    1184: f9000843     	str	x3, [x2, #0x10]
    1188: 8b130c21     	add	x1, x1, x19, lsl #3
    118c: f9001820     	str	x0, [x1, #0x30]
    1190: 52800020     	mov	w0, #0x1                ; =1
    1194: aa1503e1     	mov	x1, x21
    1198: aa1503e1     	mov	x1, x21
    119c: b9401021     	ldr	w1, [x1, #0x10]
    11a0: 51000421     	sub	w1, w1, #0x1
    11a4: aa1503e2     	mov	x2, x21
    11a8: b9001041     	str	w1, [x2, #0x10]
    11ac: 910283ff     	add	sp, sp, #0xa0
    11b0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    11b4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    11b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    11bc: d65f03c0     	ret
    11c0: aa0003f5     	mov	x21, x0
    11c4: aa0103f6     	mov	x22, x1
    11c8: 528006a1     	mov	w1, #0x35               ; =53
    11cc: 52800003     	mov	w3, #0x0                ; =0
    11d0: 9000000c     	adrp	x12, 0x1000 <___pl_fn_4+0x274>
    11d4: f940018c     	ldr	x12, [x12]
    11d8: aa1603e2     	mov	x2, x22
    11dc: aa1503e0     	mov	x0, x21
    11e0: d63f0180     	blr	x12
    11e4: 35002020     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    11e8: 528006c1     	mov	w1, #0x36               ; =54
    11ec: 140000fb     	b	0x15d8 <___pl_fn_4+0x84c>
    11f0: 528006e1     	mov	w1, #0x37               ; =55
    11f4: 52800043     	mov	w3, #0x2                ; =2
    11f8: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    11fc: f9400084     	ldr	x4, [x4]
    1200: aa1503e0     	mov	x0, x21
    1204: d63f0080     	blr	x4
    1208: 35001f00     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    120c: 52800701     	mov	w1, #0x38               ; =56
    1210: 140000f2     	b	0x15d8 <___pl_fn_4+0x84c>
    1214: d2800001     	mov	x1, #0x0                ; =0
    1218: 910003e3     	mov	x3, sp
    121c: f80003e1     	stur	x1, [sp]
    1220: f80083e0     	stur	x0, [sp, #0x8]
    1224: 52800741     	mov	w1, #0x3a               ; =58
    1228: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    122c: f9400084     	ldr	x4, [x4]
    1230: aa1503e0     	mov	x0, x21
    1234: d63f0080     	blr	x4
    1238: 35001d80     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    123c: 52800761     	mov	w1, #0x3b               ; =59
    1240: 140000e6     	b	0x15d8 <___pl_fn_4+0x84c>
    1244: 52800781     	mov	w1, #0x3c               ; =60
    1248: 52800023     	mov	w3, #0x1                ; =1
    124c: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    1250: f9400084     	ldr	x4, [x4]
    1254: aa1503e0     	mov	x0, x21
    1258: d63f0080     	blr	x4
    125c: 35001c60     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    1260: 528007a1     	mov	w1, #0x3d               ; =61
    1264: 140000dd     	b	0x15d8 <___pl_fn_4+0x84c>
    1268: 528007c1     	mov	w1, #0x3e               ; =62
    126c: 52800063     	mov	w3, #0x3                ; =3
    1270: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    1274: f9400084     	ldr	x4, [x4]
    1278: aa1503e0     	mov	x0, x21
    127c: d63f0080     	blr	x4
    1280: 35001b40     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    1284: 528007e1     	mov	w1, #0x3f               ; =63
    1288: 140000d4     	b	0x15d8 <___pl_fn_4+0x84c>
    128c: d2800021     	mov	x1, #0x1                ; =1
    1290: 910043e3     	add	x3, sp, #0x10
    1294: f80103e1     	stur	x1, [sp, #0x10]
    1298: f80183e0     	stur	x0, [sp, #0x18]
    129c: 52800821     	mov	w1, #0x41               ; =65
    12a0: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    12a4: f9400084     	ldr	x4, [x4]
    12a8: aa1503e0     	mov	x0, x21
    12ac: d63f0080     	blr	x4
    12b0: 350019c0     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    12b4: 52800841     	mov	w1, #0x42               ; =66
    12b8: 140000c8     	b	0x15d8 <___pl_fn_4+0x84c>
    12bc: 52800861     	mov	w1, #0x43               ; =67
    12c0: 52800003     	mov	w3, #0x0                ; =0
    12c4: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    12c8: f9400084     	ldr	x4, [x4]
    12cc: aa1503e0     	mov	x0, x21
    12d0: d63f0080     	blr	x4
    12d4: 350018a0     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    12d8: 52800881     	mov	w1, #0x44               ; =68
    12dc: 140000bf     	b	0x15d8 <___pl_fn_4+0x84c>
    12e0: d2800000     	mov	x0, #0x0                ; =0
    12e4: 910083e3     	add	x3, sp, #0x20
    12e8: f80203e0     	stur	x0, [sp, #0x20]
    12ec: d2803e80     	mov	x0, #0x1f4              ; =500
    12f0: f80283e0     	stur	x0, [sp, #0x28]
    12f4: 528008a1     	mov	w1, #0x45               ; =69
    12f8: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    12fc: f9400084     	ldr	x4, [x4]
    1300: aa1503e0     	mov	x0, x21
    1304: d63f0080     	blr	x4
    1308: 35001700     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    130c: 528008c1     	mov	w1, #0x46               ; =70
    1310: 140000b2     	b	0x15d8 <___pl_fn_4+0x84c>
    1314: 528008e1     	mov	w1, #0x47               ; =71
    1318: 52800043     	mov	w3, #0x2                ; =2
    131c: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    1320: f9400084     	ldr	x4, [x4]
    1324: aa1503e0     	mov	x0, x21
    1328: d63f0080     	blr	x4
    132c: 350015e0     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    1330: 52800901     	mov	w1, #0x48               ; =72
    1334: 140000a9     	b	0x15d8 <___pl_fn_4+0x84c>
    1338: d2800041     	mov	x1, #0x2                ; =2
    133c: 9100c3e3     	add	x3, sp, #0x30
    1340: f80303e1     	stur	x1, [sp, #0x30]
    1344: cb0003e0     	neg	x0, x0
    1348: f80383e0     	stur	x0, [sp, #0x38]
    134c: 52800961     	mov	w1, #0x4b               ; =75
    1350: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    1354: f9400084     	ldr	x4, [x4]
    1358: aa1603e2     	mov	x2, x22
    135c: aa1503e0     	mov	x0, x21
    1360: d63f0080     	blr	x4
    1364: 35001420     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    1368: 52800981     	mov	w1, #0x4c               ; =76
    136c: 1400009b     	b	0x15d8 <___pl_fn_4+0x84c>
    1370: 528009a1     	mov	w1, #0x4d               ; =77
    1374: 52800003     	mov	w3, #0x0                ; =0
    1378: 90000008     	adrp	x8, 0x1000 <___pl_fn_4+0x274>
    137c: f9400108     	ldr	x8, [x8]
    1380: aa1603e2     	mov	x2, x22
    1384: aa1503e0     	mov	x0, x21
    1388: d63f0100     	blr	x8
    138c: 350012e0     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    1390: 528009c1     	mov	w1, #0x4e               ; =78
    1394: 14000091     	b	0x15d8 <___pl_fn_4+0x84c>
    1398: 910103e3     	add	x3, sp, #0x40
    139c: f80403f4     	stur	x20, [sp, #0x40]
    13a0: f80483f4     	stur	x20, [sp, #0x48]
    13a4: 528009e1     	mov	w1, #0x4f               ; =79
    13a8: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    13ac: f9400084     	ldr	x4, [x4]
    13b0: aa1603e2     	mov	x2, x22
    13b4: aa1503e0     	mov	x0, x21
    13b8: d63f0080     	blr	x4
    13bc: 35001160     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    13c0: 52800a01     	mov	w1, #0x50               ; =80
    13c4: 14000085     	b	0x15d8 <___pl_fn_4+0x84c>
    13c8: 52800a21     	mov	w1, #0x51               ; =81
    13cc: 52800043     	mov	w3, #0x2                ; =2
    13d0: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    13d4: f9400084     	ldr	x4, [x4]
    13d8: aa1603e2     	mov	x2, x22
    13dc: aa1503e0     	mov	x0, x21
    13e0: d63f0080     	blr	x4
    13e4: 35001020     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    13e8: 52800a41     	mov	w1, #0x52               ; =82
    13ec: 1400007b     	b	0x15d8 <___pl_fn_4+0x84c>
    13f0: d2800041     	mov	x1, #0x2                ; =2
    13f4: 910143e3     	add	x3, sp, #0x50
    13f8: f80503e1     	stur	x1, [sp, #0x50]
    13fc: f80583e0     	stur	x0, [sp, #0x58]
    1400: 52800a81     	mov	w1, #0x54               ; =84
    1404: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    1408: f9400084     	ldr	x4, [x4]
    140c: aa1603e2     	mov	x2, x22
    1410: aa1503e0     	mov	x0, x21
    1414: d63f0080     	blr	x4
    1418: 35000e80     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    141c: 52800aa1     	mov	w1, #0x55               ; =85
    1420: 1400006e     	b	0x15d8 <___pl_fn_4+0x84c>
    1424: 52800ac1     	mov	w1, #0x56               ; =86
    1428: 52800023     	mov	w3, #0x1                ; =1
    142c: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    1430: f9400084     	ldr	x4, [x4]
    1434: aa1603e2     	mov	x2, x22
    1438: aa1503e0     	mov	x0, x21
    143c: d63f0080     	blr	x4
    1440: 35000d40     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    1444: 52800ae1     	mov	w1, #0x57               ; =87
    1448: 14000064     	b	0x15d8 <___pl_fn_4+0x84c>
    144c: d2800026     	mov	x6, #0x1                ; =1
    1450: 910183e3     	add	x3, sp, #0x60
    1454: f80603e6     	stur	x6, [sp, #0x60]
    1458: d2803e87     	mov	x7, #0x1f4              ; =500
    145c: f80683e7     	stur	x7, [sp, #0x68]
    1460: 52800b01     	mov	w1, #0x58               ; =88
    1464: 90000008     	adrp	x8, 0x1000 <___pl_fn_4+0x274>
    1468: f9400108     	ldr	x8, [x8]
    146c: aa1603e2     	mov	x2, x22
    1470: aa1503e0     	mov	x0, x21
    1474: d63f0100     	blr	x8
    1478: 35000b80     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    147c: 52800b21     	mov	w1, #0x59               ; =89
    1480: 14000056     	b	0x15d8 <___pl_fn_4+0x84c>
    1484: 52800b41     	mov	w1, #0x5a               ; =90
    1488: 52800063     	mov	w3, #0x3                ; =3
    148c: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    1490: f9400084     	ldr	x4, [x4]
    1494: aa1603e2     	mov	x2, x22
    1498: aa1503e0     	mov	x0, x21
    149c: d63f0080     	blr	x4
    14a0: 35000a40     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    14a4: 52800b61     	mov	w1, #0x5b               ; =91
    14a8: 1400004c     	b	0x15d8 <___pl_fn_4+0x84c>
    14ac: d2800061     	mov	x1, #0x3                ; =3
    14b0: 9101c3e3     	add	x3, sp, #0x70
    14b4: f80703e1     	stur	x1, [sp, #0x70]
    14b8: cb0003e0     	neg	x0, x0
    14bc: f80783e0     	stur	x0, [sp, #0x78]
    14c0: 52800bc1     	mov	w1, #0x5e               ; =94
    14c4: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    14c8: f9400084     	ldr	x4, [x4]
    14cc: aa1603e2     	mov	x2, x22
    14d0: aa1503e0     	mov	x0, x21
    14d4: d63f0080     	blr	x4
    14d8: 35000880     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    14dc: 52800be1     	mov	w1, #0x5f               ; =95
    14e0: 1400003e     	b	0x15d8 <___pl_fn_4+0x84c>
    14e4: 52800c01     	mov	w1, #0x60               ; =96
    14e8: 52800023     	mov	w3, #0x1                ; =1
    14ec: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    14f0: f9400084     	ldr	x4, [x4]
    14f4: aa1603e2     	mov	x2, x22
    14f8: aa1503e0     	mov	x0, x21
    14fc: d63f0080     	blr	x4
    1500: 35000740     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    1504: 52800c21     	mov	w1, #0x61               ; =97
    1508: 14000034     	b	0x15d8 <___pl_fn_4+0x84c>
    150c: d2800020     	mov	x0, #0x1                ; =1
    1510: 910203e3     	add	x3, sp, #0x80
    1514: f80803e0     	stur	x0, [sp, #0x80]
    1518: f80883f4     	stur	x20, [sp, #0x88]
    151c: 52800c41     	mov	w1, #0x62               ; =98
    1520: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    1524: f9400084     	ldr	x4, [x4]
    1528: aa1603e2     	mov	x2, x22
    152c: aa1503e0     	mov	x0, x21
    1530: d63f0080     	blr	x4
    1534: 350005a0     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    1538: 52800c61     	mov	w1, #0x63               ; =99
    153c: 14000027     	b	0x15d8 <___pl_fn_4+0x84c>
    1540: 52800c81     	mov	w1, #0x64               ; =100
    1544: 52800063     	mov	w3, #0x3                ; =3
    1548: 9000000d     	adrp	x13, 0x1000 <___pl_fn_4+0x274>
    154c: f94001ad     	ldr	x13, [x13]
    1550: aa1603e2     	mov	x2, x22
    1554: aa1503e0     	mov	x0, x21
    1558: d63f01a0     	blr	x13
    155c: 35000460     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    1560: 52800ca1     	mov	w1, #0x65               ; =101
    1564: 1400001d     	b	0x15d8 <___pl_fn_4+0x84c>
    1568: d2800061     	mov	x1, #0x3                ; =3
    156c: 910243e3     	add	x3, sp, #0x90
    1570: f80903e1     	stur	x1, [sp, #0x90]
    1574: f80983e0     	stur	x0, [sp, #0x98]
    1578: 52800ce1     	mov	w1, #0x67               ; =103
    157c: 90000004     	adrp	x4, 0x1000 <___pl_fn_4+0x274>
    1580: f9400084     	ldr	x4, [x4]
    1584: aa1603e2     	mov	x2, x22
    1588: aa1503e0     	mov	x0, x21
    158c: d63f0080     	blr	x4
    1590: 350002c0     	cbnz	w0, 0x15e8 <___pl_fn_4+0x85c>
    1594: 52800d01     	mov	w1, #0x68               ; =104
    1598: 14000010     	b	0x15d8 <___pl_fn_4+0x84c>
    159c: 52800cc1     	mov	w1, #0x66               ; =102
    15a0: 1400000e     	b	0x15d8 <___pl_fn_4+0x84c>
    15a4: 52800ba1     	mov	w1, #0x5d               ; =93
    15a8: 1400000c     	b	0x15d8 <___pl_fn_4+0x84c>
    15ac: 52800b81     	mov	w1, #0x5c               ; =92
    15b0: 1400000a     	b	0x15d8 <___pl_fn_4+0x84c>
    15b4: 52800a61     	mov	w1, #0x53               ; =83
    15b8: 14000008     	b	0x15d8 <___pl_fn_4+0x84c>
    15bc: 52800941     	mov	w1, #0x4a               ; =74
    15c0: 14000006     	b	0x15d8 <___pl_fn_4+0x84c>
    15c4: 52800921     	mov	w1, #0x49               ; =73
    15c8: 14000004     	b	0x15d8 <___pl_fn_4+0x84c>
    15cc: 52800801     	mov	w1, #0x40               ; =64
    15d0: 14000002     	b	0x15d8 <___pl_fn_4+0x84c>
    15d4: 52800721     	mov	w1, #0x39               ; =57
    15d8: 90000002     	adrp	x2, 0x1000 <___pl_fn_4+0x274>
    15dc: f9400042     	ldr	x2, [x2]
    15e0: aa1503e0     	mov	x0, x21
    15e4: d63f0040     	blr	x2
    15e8: 52800000     	mov	w0, #0x0                ; =0
    15ec: 910283ff     	add	sp, sp, #0xa0
    15f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    15f4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    15f8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    15fc: d65f03c0     	ret
