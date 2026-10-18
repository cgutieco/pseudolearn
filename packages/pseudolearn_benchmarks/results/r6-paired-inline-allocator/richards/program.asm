
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_94328/richards/program.o:	file format mach-o arm64

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
     128: d10403ff     	sub	sp, sp, #0x100
     12c: b9401001     	ldr	w1, [x0, #0x10]
     130: 11000421     	add	w1, w1, #0x1
     134: b9001001     	str	w1, [x0, #0x10]
     138: aa0003f9     	mov	x25, x0
     13c: 52800101     	mov	w1, #0x8                ; =8
     140: 52800002     	mov	w2, #0x0                ; =0
     144: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     148: f9400063     	ldr	x3, [x3]
     14c: aa1903e0     	mov	x0, x25
     150: d63f0060     	blr	x3
     154: 3501ff60     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
     158: aa1903e0     	mov	x0, x25
     15c: f9401813     	ldr	x19, [x0, #0x30]
     160: f9403c00     	ldr	x0, [x0, #0x78]
     164: 37714dc0     	tbnz	w0, #0xe, 0x2b1c <___pl_fn_1+0x2a10>
     168: aa1903e0     	mov	x0, x25
     16c: f9403801     	ldr	x1, [x0, #0x70]
     170: f100003f     	cmp	x1, #0x0
     174: 54014d4d     	b.le	0x2b1c <___pl_fn_1+0x2a10>
     178: aa1903e0     	mov	x0, x25
     17c: f9403404     	ldr	x4, [x0, #0x68]
     180: f100309f     	cmp	x4, #0xc
     184: 54014ccb     	b.lt	0x2b1c <___pl_fn_1+0x2a10>
     188: aa1903e0     	mov	x0, x25
     18c: f9402802     	ldr	x2, [x0, #0x50]
     190: f9402c07     	ldr	x7, [x0, #0x58]
     194: 91003848     	add	x8, x2, #0xe
     198: eb07011f     	cmp	x8, x7
     19c: 54014c08     	b.hi	0x2b1c <___pl_fn_1+0x2a10>
     1a0: aa1903e0     	mov	x0, x25
     1a4: f940440a     	ldr	x10, [x0, #0x88]
     1a8: f940480b     	ldr	x11, [x0, #0x90]
     1ac: eb0b015f     	cmp	x10, x11
     1b0: 540000a3     	b.lo	0x1c4 <___pl_fn_1+0xb8>
     1b4: 14000a5a     	b	0x2b1c <___pl_fn_1+0x2a10>
     1b8: aa1903e0     	mov	x0, x25
     1bc: f9401802     	ldr	x2, [x0, #0x30]
     1c0: 14000032     	b	0x288 <___pl_fn_1+0x17c>
     1c4: aa1903e0     	mov	x0, x25
     1c8: f9403003     	ldr	x3, [x0, #0x60]
     1cc: f9400004     	ldr	x4, [x0]
     1d0: d2800085     	mov	x5, #0x4                ; =4
     1d4: f2c00065     	movk	x5, #0x3, lsl #32
     1d8: 2a0203e0     	mov	w0, w2
     1dc: 8b000c81     	add	x1, x4, x0, lsl #3
     1e0: f8225885     	str	x5, [x4, w2, uxtw #3]
     1e4: 91000463     	add	x3, x3, #0x1
     1e8: f9000423     	str	x3, [x1, #0x8]
     1ec: 92800004     	mov	x4, #-0x1               ; =-1
     1f0: f9000824     	str	x4, [x1, #0x10]
     1f4: d2800004     	mov	x4, #0x0                ; =0
     1f8: f9000c24     	str	x4, [x1, #0x18]
     1fc: f9001024     	str	x4, [x1, #0x20]
     200: f9001424     	str	x4, [x1, #0x28]
     204: f9001824     	str	x4, [x1, #0x30]
     208: f9001c24     	str	x4, [x1, #0x38]
     20c: f9002024     	str	x4, [x1, #0x40]
     210: f9002424     	str	x4, [x1, #0x48]
     214: f9002824     	str	x4, [x1, #0x50]
     218: f9002c24     	str	x4, [x1, #0x58]
     21c: f9003024     	str	x4, [x1, #0x60]
     220: f9003424     	str	x4, [x1, #0x68]
     224: aa1903eb     	mov	x11, x25
     228: f9003163     	str	x3, [x11, #0x60]
     22c: 91003841     	add	x1, x2, #0xe
     230: aa1903ee     	mov	x14, x25
     234: f90029c1     	str	x1, [x14, #0x50]
     238: aa1903e1     	mov	x1, x25
     23c: f9403421     	ldr	x1, [x1, #0x68]
     240: d1003021     	sub	x1, x1, #0xc
     244: aa1903e3     	mov	x3, x25
     248: f9003461     	str	x1, [x3, #0x68]
     24c: aa1903e1     	mov	x1, x25
     250: f9403821     	ldr	x1, [x1, #0x70]
     254: d1003021     	sub	x1, x1, #0xc
     258: f9003861     	str	x1, [x3, #0x70]
     25c: aa1903e1     	mov	x1, x25
     260: f9404021     	ldr	x1, [x1, #0x80]
     264: b25f0800     	orr	x0, x0, #0xe00000000
     268: d37ced44     	lsl	x4, x10, #4
     26c: 8b0a1023     	add	x3, x1, x10, lsl #4
     270: f8246820     	str	x0, [x1, x4]
     274: d2800180     	mov	x0, #0xc                ; =12
     278: f9000460     	str	x0, [x3, #0x8]
     27c: 91000540     	add	x0, x10, #0x1
     280: aa1903e1     	mov	x1, x25
     284: f9004420     	str	x0, [x1, #0x88]
     288: 3401f422     	cbz	w2, 0x410c <___pl_fn_1+0x4000>
     28c: aa1903e0     	mov	x0, x25
     290: f9403c00     	ldr	x0, [x0, #0x78]
     294: 37594540     	tbnz	w0, #0xb, 0x2b3c <___pl_fn_1+0x2a30>
     298: aa1903e0     	mov	x0, x25
     29c: f9403800     	ldr	x0, [x0, #0x70]
     2a0: f100001f     	cmp	x0, #0x0
     2a4: 5401450d     	b.le	0x2b44 <___pl_fn_1+0x2a38>
     2a8: aa1903e0     	mov	x0, x25
     2ac: f9403400     	ldr	x0, [x0, #0x68]
     2b0: f100241f     	cmp	x0, #0x9
     2b4: 540144cb     	b.lt	0x2b4c <___pl_fn_1+0x2a40>
     2b8: aa1903e0     	mov	x0, x25
     2bc: f9402814     	ldr	x20, [x0, #0x50]
     2c0: f9402c00     	ldr	x0, [x0, #0x58]
     2c4: 91002e81     	add	x1, x20, #0xb
     2c8: eb00003f     	cmp	x1, x0
     2cc: 54014448     	b.hi	0x2b54 <___pl_fn_1+0x2a48>
     2d0: aa1903e0     	mov	x0, x25
     2d4: f9404400     	ldr	x0, [x0, #0x88]
     2d8: aa1903e1     	mov	x1, x25
     2dc: f9404821     	ldr	x1, [x1, #0x90]
     2e0: eb01001f     	cmp	x0, x1
     2e4: 540143c2     	b.hs	0x2b5c <___pl_fn_1+0x2a50>
     2e8: aa1903e5     	mov	x5, x25
     2ec: b94018a1     	ldr	w1, [x5, #0x18]
     2f0: aa1903e7     	mov	x7, x25
     2f4: b9401ce3     	ldr	w3, [x7, #0x1c]
     2f8: 11000421     	add	w1, w1, #0x1
     2fc: 6b03003f     	cmp	w1, w3
     300: 54000269     	b.ls	0x34c <___pl_fn_1+0x240>
     304: 14000a18     	b	0x2b64 <___pl_fn_1+0x2a58>
     308: aa1903e1     	mov	x1, x25
     30c: f9401021     	ldr	x1, [x1, #0x20]
     310: b8355822     	str	w2, [x1, w21, uxtw #2]
     314: aa1903e1     	mov	x1, x25
     318: aa0203fb     	mov	x27, x2
     31c: b9001820     	str	w0, [x1, #0x18]
     320: 52800181     	mov	w1, #0xc                ; =12
     324: 52800002     	mov	w2, #0x0                ; =0
     328: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     32c: f9400063     	ldr	x3, [x3]
     330: aa1903e0     	mov	x0, x25
     334: d63f0060     	blr	x3
     338: 3501f040     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
     33c: aa1903e0     	mov	x0, x25
     340: f9401814     	ldr	x20, [x0, #0x30]
     344: b9001815     	str	w21, [x0, #0x18]
     348: 14000030     	b	0x408 <___pl_fn_1+0x2fc>
     34c: aa1903e1     	mov	x1, x25
     350: aa0203fb     	mov	x27, x2
     354: f9403024     	ldr	x4, [x1, #0x60]
     358: f9400025     	ldr	x5, [x1]
     35c: b20007e6     	mov	x6, #0x300000003        ; =12884901891
     360: 2a1403e2     	mov	w2, w20
     364: 8b020ca3     	add	x3, x5, x2, lsl #3
     368: f83458a6     	str	x6, [x5, w20, uxtw #3]
     36c: 91000484     	add	x4, x4, #0x1
     370: f9000464     	str	x4, [x3, #0x8]
     374: 92800005     	mov	x5, #-0x1               ; =-1
     378: f9000865     	str	x5, [x3, #0x10]
     37c: d2800005     	mov	x5, #0x0                ; =0
     380: f9000c65     	str	x5, [x3, #0x18]
     384: f9001065     	str	x5, [x3, #0x20]
     388: f9001465     	str	x5, [x3, #0x28]
     38c: f9001865     	str	x5, [x3, #0x30]
     390: f9001c65     	str	x5, [x3, #0x38]
     394: f9002065     	str	x5, [x3, #0x40]
     398: f9002465     	str	x5, [x3, #0x48]
     39c: f9002865     	str	x5, [x3, #0x50]
     3a0: f9003024     	str	x4, [x1, #0x60]
     3a4: 91002e8e     	add	x14, x20, #0xb
     3a8: aa1903e3     	mov	x3, x25
     3ac: f900286e     	str	x14, [x3, #0x50]
     3b0: aa1903e4     	mov	x4, x25
     3b4: f940348f     	ldr	x15, [x4, #0x68]
     3b8: d10025ef     	sub	x15, x15, #0x9
     3bc: aa1903e7     	mov	x7, x25
     3c0: f90034ef     	str	x15, [x7, #0x68]
     3c4: aa1903e9     	mov	x9, x25
     3c8: f9403921     	ldr	x1, [x9, #0x70]
     3cc: d1002421     	sub	x1, x1, #0x9
     3d0: aa1903ec     	mov	x12, x25
     3d4: f9003981     	str	x1, [x12, #0x70]
     3d8: aa1903ee     	mov	x14, x25
     3dc: f94041c1     	ldr	x1, [x14, #0x80]
     3e0: d2c00163     	mov	x3, #0xb00000000        ; =47244640256
     3e4: aa030042     	orr	x2, x2, x3
     3e8: d37cec04     	lsl	x4, x0, #4
     3ec: 8b001023     	add	x3, x1, x0, lsl #4
     3f0: f8246822     	str	x2, [x1, x4]
     3f4: d2800121     	mov	x1, #0x9                ; =9
     3f8: f9000461     	str	x1, [x3, #0x8]
     3fc: 91000400     	add	x0, x0, #0x1
     400: aa1903e1     	mov	x1, x25
     404: f9004420     	str	x0, [x1, #0x88]
     408: 3401e694     	cbz	w20, 0x40d8 <___pl_fn_1+0x3fcc>
     40c: 350000b4     	cbnz	w20, 0x420 <___pl_fn_1+0x314>
     410: 140009e9     	b	0x2bb4 <___pl_fn_1+0x2aa8>
     414: aa1903e0     	mov	x0, x25
     418: aa1c03e5     	mov	x5, x28
     41c: 1400000c     	b	0x44c <___pl_fn_1+0x340>
     420: aa1903e0     	mov	x0, x25
     424: aa1403fc     	mov	x28, x20
     428: f9400002     	ldr	x2, [x0]
     42c: aa1c03e5     	mov	x5, x28
     430: 2a0503e0     	mov	w0, w5
     434: 8b000c41     	add	x1, x2, x0, lsl #3
     438: f8655842     	ldr	x2, [x2, w5, uxtw #3]
     43c: d360fc42     	lsr	x2, x2, #32
     440: 92403c42     	and	x2, x2, #0xffff
     444: f8227820     	str	x0, [x1, x2, lsl #3]
     448: aa1903e0     	mov	x0, x25
     44c: aa1903e0     	mov	x0, x25
     450: f9403c00     	ldr	x0, [x0, #0x78]
     454: 37593cc0     	tbnz	w0, #0xb, 0x2bec <___pl_fn_1+0x2ae0>
     458: aa1903e0     	mov	x0, x25
     45c: f9403800     	ldr	x0, [x0, #0x70]
     460: f100001f     	cmp	x0, #0x0
     464: 54013c8d     	b.le	0x2bf4 <___pl_fn_1+0x2ae8>
     468: aa1903e0     	mov	x0, x25
     46c: f9403401     	ldr	x1, [x0, #0x68]
     470: d2800120     	mov	x0, #0x9                ; =9
     474: f100243f     	cmp	x1, #0x9
     478: 54013c2b     	b.lt	0x2bfc <___pl_fn_1+0x2af0>
     47c: aa1903e1     	mov	x1, x25
     480: f9402834     	ldr	x20, [x1, #0x50]
     484: aa1903e3     	mov	x3, x25
     488: f9402c61     	ldr	x1, [x3, #0x58]
     48c: 91002e82     	add	x2, x20, #0xb
     490: eb01005f     	cmp	x2, x1
     494: 54013b88     	b.hi	0x2c04 <___pl_fn_1+0x2af8>
     498: aa1903e9     	mov	x9, x25
     49c: f9404521     	ldr	x1, [x9, #0x88]
     4a0: aa1903eb     	mov	x11, x25
     4a4: f9404962     	ldr	x2, [x11, #0x90]
     4a8: eb02003f     	cmp	x1, x2
     4ac: 54013b02     	b.hs	0x2c0c <___pl_fn_1+0x2b00>
     4b0: aa1903e2     	mov	x2, x25
     4b4: b9401842     	ldr	w2, [x2, #0x18]
     4b8: aa1903e3     	mov	x3, x25
     4bc: b9401c63     	ldr	w3, [x3, #0x1c]
     4c0: 11000842     	add	w2, w2, #0x2
     4c4: 6b03005f     	cmp	w2, w3
     4c8: 540002e9     	b.ls	0x524 <___pl_fn_1+0x418>
     4cc: 140009d2     	b	0x2c14 <___pl_fn_1+0x2b08>
     4d0: aa1903e0     	mov	x0, x25
     4d4: f9401000     	ldr	x0, [x0, #0x20]
     4d8: 2a1503e1     	mov	w1, w21
     4dc: 8b010801     	add	x1, x0, x1, lsl #2
     4e0: aa1b03e3     	mov	x3, x27
     4e4: b8355803     	str	w3, [x0, w21, uxtw #2]
     4e8: b9000425     	str	w5, [x1, #0x4]
     4ec: aa0503fc     	mov	x28, x5
     4f0: 11000aa0     	add	w0, w21, #0x2
     4f4: aa1903e1     	mov	x1, x25
     4f8: b9001820     	str	w0, [x1, #0x18]
     4fc: 52800201     	mov	w1, #0x10               ; =16
     500: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     504: f9400063     	ldr	x3, [x3]
     508: aa1903e0     	mov	x0, x25
     50c: d63f0060     	blr	x3
     510: 3501e180     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
     514: aa1903e0     	mov	x0, x25
     518: f9401814     	ldr	x20, [x0, #0x30]
     51c: b9001815     	str	w21, [x0, #0x18]
     520: 1400002c     	b	0x5d0 <___pl_fn_1+0x4c4>
     524: aa1903e2     	mov	x2, x25
     528: aa0503fc     	mov	x28, x5
     52c: f9403044     	ldr	x4, [x2, #0x60]
     530: f9400045     	ldr	x5, [x2]
     534: d28000a6     	mov	x6, #0x5                ; =5
     538: f2c00066     	movk	x6, #0x3, lsl #32
     53c: 2a1403e2     	mov	w2, w20
     540: 8b020ca3     	add	x3, x5, x2, lsl #3
     544: f83458a6     	str	x6, [x5, w20, uxtw #3]
     548: 91000484     	add	x4, x4, #0x1
     54c: f9000464     	str	x4, [x3, #0x8]
     550: 92800005     	mov	x5, #-0x1               ; =-1
     554: f9000865     	str	x5, [x3, #0x10]
     558: d2800005     	mov	x5, #0x0                ; =0
     55c: f9000c65     	str	x5, [x3, #0x18]
     560: f9001065     	str	x5, [x3, #0x20]
     564: f9001465     	str	x5, [x3, #0x28]
     568: f9001865     	str	x5, [x3, #0x30]
     56c: d2800046     	mov	x6, #0x2                ; =2
     570: f9001c66     	str	x6, [x3, #0x38]
     574: f9002066     	str	x6, [x3, #0x40]
     578: f9002466     	str	x6, [x3, #0x48]
     57c: f9002865     	str	x5, [x3, #0x50]
     580: aa1903e3     	mov	x3, x25
     584: f9003064     	str	x4, [x3, #0x60]
     588: 91002e86     	add	x6, x20, #0xb
     58c: f9002866     	str	x6, [x3, #0x50]
     590: f9403467     	ldr	x7, [x3, #0x68]
     594: d10024e7     	sub	x7, x7, #0x9
     598: f9003467     	str	x7, [x3, #0x68]
     59c: f9403868     	ldr	x8, [x3, #0x70]
     5a0: d1002508     	sub	x8, x8, #0x9
     5a4: f9003868     	str	x8, [x3, #0x70]
     5a8: f9404069     	ldr	x9, [x3, #0x80]
     5ac: d2c0016a     	mov	x10, #0xb00000000       ; =47244640256
     5b0: aa0a004a     	orr	x10, x2, x10
     5b4: d37cec2b     	lsl	x11, x1, #4
     5b8: 8b01112c     	add	x12, x9, x1, lsl #4
     5bc: f82b692a     	str	x10, [x9, x11]
     5c0: f9000580     	str	x0, [x12, #0x8]
     5c4: 9100042b     	add	x11, x1, #0x1
     5c8: aa1903e0     	mov	x0, x25
     5cc: f900440b     	str	x11, [x0, #0x88]
     5d0: 3401d6b4     	cbz	w20, 0x40a4 <___pl_fn_1+0x3f98>
     5d4: aa1b03e2     	mov	x2, x27
     5d8: 35000082     	cbnz	w2, 0x5e8 <___pl_fn_1+0x4dc>
     5dc: 140009a3     	b	0x2c68 <___pl_fn_1+0x2b5c>
     5e0: aa1b03e2     	mov	x2, x27
     5e4: 1400000e     	b	0x61c <___pl_fn_1+0x510>
     5e8: aa1903e0     	mov	x0, x25
     5ec: f9400001     	ldr	x1, [x0]
     5f0: aa1b03e2     	mov	x2, x27
     5f4: 2a0203e0     	mov	w0, w2
     5f8: 8b000c20     	add	x0, x1, x0, lsl #3
     5fc: f8625822     	ldr	x2, [x1, w2, uxtw #3]
     600: aa1c03e5     	mov	x5, x28
     604: 2a0503e1     	mov	w1, w5
     608: d360fc42     	lsr	x2, x2, #32
     60c: 92403c42     	and	x2, x2, #0xffff
     610: 91000842     	add	x2, x2, #0x2
     614: f8227801     	str	x1, [x0, x2, lsl #3]
     618: aa1b03e2     	mov	x2, x27
     61c: aa1b03e2     	mov	x2, x27
     620: 35000082     	cbnz	w2, 0x630 <___pl_fn_1+0x524>
     624: 1400099f     	b	0x2ca0 <___pl_fn_1+0x2b94>
     628: aa1b03e2     	mov	x2, x27
     62c: 1400000d     	b	0x660 <___pl_fn_1+0x554>
     630: aa1903e0     	mov	x0, x25
     634: f9400001     	ldr	x1, [x0]
     638: aa1b03e2     	mov	x2, x27
     63c: 2a0203e0     	mov	w0, w2
     640: 8b000c20     	add	x0, x1, x0, lsl #3
     644: f8625822     	ldr	x2, [x1, w2, uxtw #3]
     648: 2a1403e1     	mov	w1, w20
     64c: d360fc42     	lsr	x2, x2, #32
     650: 92403c42     	and	x2, x2, #0xffff
     654: 91000442     	add	x2, x2, #0x1
     658: f8227801     	str	x1, [x0, x2, lsl #3]
     65c: aa1b03e2     	mov	x2, x27
     660: aa1b03e2     	mov	x2, x27
     664: 35000082     	cbnz	w2, 0x674 <___pl_fn_1+0x568>
     668: 1400099b     	b	0x2cd4 <___pl_fn_1+0x2bc8>
     66c: aa1b03e2     	mov	x2, x27
     670: 1400000c     	b	0x6a0 <___pl_fn_1+0x594>
     674: aa1903e0     	mov	x0, x25
     678: f9400001     	ldr	x1, [x0]
     67c: aa1b03e2     	mov	x2, x27
     680: 2a0203e0     	mov	w0, w2
     684: 8b000c20     	add	x0, x1, x0, lsl #3
     688: f8625822     	ldr	x2, [x1, w2, uxtw #3]
     68c: 2a1403e1     	mov	w1, w20
     690: d360fc42     	lsr	x2, x2, #32
     694: 92403c42     	and	x2, x2, #0xffff
     698: f8227801     	str	x1, [x0, x2, lsl #3]
     69c: aa1b03e2     	mov	x2, x27
     6a0: aa1b03e2     	mov	x2, x27
     6a4: 35000082     	cbnz	w2, 0x6b4 <___pl_fn_1+0x5a8>
     6a8: 14000998     	b	0x2d08 <___pl_fn_1+0x2bfc>
     6ac: aa1b03e2     	mov	x2, x27
     6b0: 14000013     	b	0x6fc <___pl_fn_1+0x5f0>
     6b4: aa1903e0     	mov	x0, x25
     6b8: f9400001     	ldr	x1, [x0]
     6bc: aa1b03e2     	mov	x2, x27
     6c0: 2a0203e0     	mov	w0, w2
     6c4: 8b000c20     	add	x0, x1, x0, lsl #3
     6c8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     6cc: d360fc21     	lsr	x1, x1, #32
     6d0: 92403c22     	and	x2, x1, #0xffff
     6d4: f100085f     	cmp	x2, #0x2
     6d8: 54000080     	b.eq	0x6e8 <___pl_fn_1+0x5dc>
     6dc: f9400802     	ldr	x2, [x0, #0x10]
     6e0: 9276f842     	and	x2, x2, #0xfffffffffffffdff
     6e4: f9000802     	str	x2, [x0, #0x10]
     6e8: d2800002     	mov	x2, #0x0                ; =0
     6ec: 92403c21     	and	x1, x1, #0xffff
     6f0: 91002421     	add	x1, x1, #0x9
     6f4: f8217802     	str	x2, [x0, x1, lsl #3]
     6f8: aa1b03e2     	mov	x2, x27
     6fc: aa1b03e2     	mov	x2, x27
     700: 35000082     	cbnz	w2, 0x710 <___pl_fn_1+0x604>
     704: 1400098e     	b	0x2d3c <___pl_fn_1+0x2c30>
     708: aa1903e0     	mov	x0, x25
     70c: 14000013     	b	0x758 <___pl_fn_1+0x64c>
     710: aa1903e0     	mov	x0, x25
     714: f9400001     	ldr	x1, [x0]
     718: aa1b03e2     	mov	x2, x27
     71c: 2a0203e0     	mov	w0, w2
     720: 8b000c20     	add	x0, x1, x0, lsl #3
     724: f8625821     	ldr	x1, [x1, w2, uxtw #3]
     728: d360fc21     	lsr	x1, x1, #32
     72c: 92403c22     	and	x2, x1, #0xffff
     730: f100085f     	cmp	x2, #0x2
     734: 54000080     	b.eq	0x744 <___pl_fn_1+0x638>
     738: f9400802     	ldr	x2, [x0, #0x10]
     73c: 9275f842     	and	x2, x2, #0xfffffffffffffbff
     740: f9000802     	str	x2, [x0, #0x10]
     744: d2800002     	mov	x2, #0x0                ; =0
     748: 92403c21     	and	x1, x1, #0xffff
     74c: 91002821     	add	x1, x1, #0xa
     750: f8217802     	str	x2, [x0, x1, lsl #3]
     754: aa1903e0     	mov	x0, x25
     758: aa1903e0     	mov	x0, x25
     75c: f9403c01     	ldr	x1, [x0, #0x78]
     760: 37693081     	tbnz	w1, #0xd, 0x2d70 <___pl_fn_1+0x2c64>
     764: aa1903e0     	mov	x0, x25
     768: f9403803     	ldr	x3, [x0, #0x70]
     76c: f100007f     	cmp	x3, #0x0
     770: 5401304d     	b.le	0x2d78 <___pl_fn_1+0x2c6c>
     774: aa1903e0     	mov	x0, x25
     778: f9403407     	ldr	x7, [x0, #0x68]
     77c: d2800166     	mov	x6, #0xb                ; =11
     780: f1002cff     	cmp	x7, #0xb
     784: 54012feb     	b.lt	0x2d80 <___pl_fn_1+0x2c74>
     788: aa1903e0     	mov	x0, x25
     78c: f9402815     	ldr	x21, [x0, #0x50]
     790: f9402c09     	ldr	x9, [x0, #0x58]
     794: 910036aa     	add	x10, x21, #0xd
     798: eb09015f     	cmp	x10, x9
     79c: 54012f68     	b.hi	0x2d88 <___pl_fn_1+0x2c7c>
     7a0: aa1903e0     	mov	x0, x25
     7a4: f940440c     	ldr	x12, [x0, #0x88]
     7a8: f940480d     	ldr	x13, [x0, #0x90]
     7ac: eb0d019f     	cmp	x12, x13
     7b0: 54012f02     	b.hs	0x2d90 <___pl_fn_1+0x2c84>
     7b4: aa1903e0     	mov	x0, x25
     7b8: b940180f     	ldr	w15, [x0, #0x18]
     7bc: b9401c00     	ldr	w0, [x0, #0x1c]
     7c0: 11000def     	add	w15, w15, #0x3
     7c4: 6b0001ff     	cmp	w15, w0
     7c8: 54000329     	b.ls	0x82c <___pl_fn_1+0x720>
     7cc: 14000973     	b	0x2d98 <___pl_fn_1+0x2c8c>
     7d0: aa1903e0     	mov	x0, x25
     7d4: f9401000     	ldr	x0, [x0, #0x20]
     7d8: 2a1603e1     	mov	w1, w22
     7dc: 8b010801     	add	x1, x0, x1, lsl #2
     7e0: aa1b03e2     	mov	x2, x27
     7e4: b8365802     	str	w2, [x0, w22, uxtw #2]
     7e8: aa1c03e5     	mov	x5, x28
     7ec: b9000425     	str	w5, [x1, #0x4]
     7f0: b9000834     	str	w20, [x1, #0x8]
     7f4: 11000ec0     	add	w0, w22, #0x3
     7f8: aa1903e1     	mov	x1, x25
     7fc: b9001820     	str	w0, [x1, #0x18]
     800: 52800301     	mov	w1, #0x18               ; =24
     804: 528000a2     	mov	w2, #0x5                ; =5
     808: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     80c: f9400063     	ldr	x3, [x3]
     810: aa1903e0     	mov	x0, x25
     814: d63f0060     	blr	x3
     818: 3501c940     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
     81c: aa1903e0     	mov	x0, x25
     820: f9401815     	ldr	x21, [x0, #0x30]
     824: b9001816     	str	w22, [x0, #0x18]
     828: 14000031     	b	0x8ec <___pl_fn_1+0x7e0>
     82c: aa1903e0     	mov	x0, x25
     830: f9403002     	ldr	x2, [x0, #0x60]
     834: f9400003     	ldr	x3, [x0]
     838: d2800104     	mov	x4, #0x8                ; =8
     83c: f2c00064     	movk	x4, #0x3, lsl #32
     840: 2a1503e0     	mov	w0, w21
     844: 8b000c61     	add	x1, x3, x0, lsl #3
     848: f8355864     	str	x4, [x3, w21, uxtw #3]
     84c: 91000442     	add	x2, x2, #0x1
     850: f9000422     	str	x2, [x1, #0x8]
     854: 92800003     	mov	x3, #-0x1               ; =-1
     858: f9000823     	str	x3, [x1, #0x10]
     85c: d2800003     	mov	x3, #0x0                ; =0
     860: f9000c23     	str	x3, [x1, #0x18]
     864: f9001023     	str	x3, [x1, #0x20]
     868: f9001423     	str	x3, [x1, #0x28]
     86c: f9001823     	str	x3, [x1, #0x30]
     870: d2800044     	mov	x4, #0x2                ; =2
     874: f9001c24     	str	x4, [x1, #0x38]
     878: f9002024     	str	x4, [x1, #0x40]
     87c: f9002424     	str	x4, [x1, #0x48]
     880: f9002823     	str	x3, [x1, #0x50]
     884: f9002c23     	str	x3, [x1, #0x58]
     888: f9003023     	str	x3, [x1, #0x60]
     88c: aa1903e1     	mov	x1, x25
     890: f9003022     	str	x2, [x1, #0x60]
     894: 910036a1     	add	x1, x21, #0xd
     898: aa1903e2     	mov	x2, x25
     89c: f9002841     	str	x1, [x2, #0x50]
     8a0: aa1903e1     	mov	x1, x25
     8a4: f9403421     	ldr	x1, [x1, #0x68]
     8a8: d1002c21     	sub	x1, x1, #0xb
     8ac: f9003441     	str	x1, [x2, #0x68]
     8b0: aa1903e1     	mov	x1, x25
     8b4: f9403821     	ldr	x1, [x1, #0x70]
     8b8: d1002c21     	sub	x1, x1, #0xb
     8bc: f9003841     	str	x1, [x2, #0x70]
     8c0: aa1903e1     	mov	x1, x25
     8c4: f9404021     	ldr	x1, [x1, #0x80]
     8c8: d2c001a2     	mov	x2, #0xd00000000        ; =55834574848
     8cc: aa020000     	orr	x0, x0, x2
     8d0: d37ced82     	lsl	x2, x12, #4
     8d4: 8b0c1023     	add	x3, x1, x12, lsl #4
     8d8: f8226820     	str	x0, [x1, x2]
     8dc: f9000466     	str	x6, [x3, #0x8]
     8e0: 91000580     	add	x0, x12, #0x1
     8e4: aa1903e1     	mov	x1, x25
     8e8: f9004420     	str	x0, [x1, #0x88]
     8ec: 3401bc35     	cbz	w21, 0x4070 <___pl_fn_1+0x3f64>
     8f0: 340127d5     	cbz	w21, 0x2de8 <___pl_fn_1+0x2cdc>
     8f4: aa1903e0     	mov	x0, x25
     8f8: f9400001     	ldr	x1, [x0]
     8fc: 2a1503e0     	mov	w0, w21
     900: 8b000c20     	add	x0, x1, x0, lsl #3
     904: f8755821     	ldr	x1, [x1, w21, uxtw #3]
     908: d360fc21     	lsr	x1, x1, #32
     90c: 92403c22     	and	x2, x1, #0xffff
     910: f100085f     	cmp	x2, #0x2
     914: 54000080     	b.eq	0x924 <___pl_fn_1+0x818>
     918: f9400802     	ldr	x2, [x0, #0x10]
     91c: 9277f842     	and	x2, x2, #0xfffffffffffffeff
     920: f9000802     	str	x2, [x0, #0x10]
     924: d2800022     	mov	x2, #0x1                ; =1
     928: 92403c21     	and	x1, x1, #0xffff
     92c: 91002021     	add	x1, x1, #0x8
     930: f8217802     	str	x2, [x0, x1, lsl #3]
     934: 350000b5     	cbnz	w21, 0x948 <___pl_fn_1+0x83c>
     938: 14000939     	b	0x2e1c <___pl_fn_1+0x2d10>
     93c: aa1903e0     	mov	x0, x25
     940: aa1503e1     	mov	x1, x21
     944: 14000012     	b	0x98c <___pl_fn_1+0x880>
     948: aa1903e0     	mov	x0, x25
     94c: f9400008     	ldr	x8, [x0]
     950: aa1503e1     	mov	x1, x21
     954: 2a0103e7     	mov	w7, w1
     958: 8b070d07     	add	x7, x8, x7, lsl #3
     95c: f8615908     	ldr	x8, [x8, w1, uxtw #3]
     960: d360fd08     	lsr	x8, x8, #32
     964: 92403d09     	and	x9, x8, #0xffff
     968: f100093f     	cmp	x9, #0x2
     96c: 54000080     	b.eq	0x97c <___pl_fn_1+0x870>
     970: f94008ea     	ldr	x10, [x7, #0x10]
     974: 9276f94a     	and	x10, x10, #0xfffffffffffffdff
     978: f90008ea     	str	x10, [x7, #0x10]
     97c: 92403d0c     	and	x12, x8, #0xffff
     980: 9100258c     	add	x12, x12, #0x9
     984: f82c78f3     	str	x19, [x7, x12, lsl #3]
     988: aa1903e0     	mov	x0, x25
     98c: aa1903e0     	mov	x0, x25
     990: b9401813     	ldr	w19, [x0, #0x18]
     994: b9401c0e     	ldr	w14, [x0, #0x1c]
     998: 1100126f     	add	w15, w19, #0x4
     99c: 6b0e01ff     	cmp	w15, w14
     9a0: 5401b4e8     	b.hi	0x403c <___pl_fn_1+0x3f30>
     9a4: aa1903e0     	mov	x0, x25
     9a8: f9401000     	ldr	x0, [x0, #0x20]
     9ac: 2a1303f6     	mov	w22, w19
     9b0: d2800055     	mov	x21, #0x2               ; =2
     9b4: 8b160802     	add	x2, x0, x22, lsl #2
     9b8: aa1b03ea     	mov	x10, x27
     9bc: b833580a     	str	w10, [x0, w19, uxtw #2]
     9c0: aa1c03e5     	mov	x5, x28
     9c4: b9000445     	str	w5, [x2, #0x4]
     9c8: b9000854     	str	w20, [x2, #0x8]
     9cc: b9000c41     	str	w1, [x2, #0xc]
     9d0: 11001260     	add	w0, w19, #0x4
     9d4: aa1903e2     	mov	x2, x25
     9d8: b9001840     	str	w0, [x2, #0x18]
     9dc: aa1903e0     	mov	x0, x25
     9e0: b9401000     	ldr	w0, [x0, #0x10]
     9e4: b9401442     	ldr	w2, [x2, #0x14]
     9e8: 6b02001f     	cmp	w0, w2
     9ec: 5401b0e2     	b.hs	0x4008 <___pl_fn_1+0x3efc>
     9f0: d2800024     	mov	x4, #0x1                ; =1
     9f4: 52800007     	mov	w7, #0x0                ; =0
     9f8: aa1903e0     	mov	x0, x25
     9fc: aa1b03e2     	mov	x2, x27
     a00: aa1c03e5     	mov	x5, x28
     a04: aa0403e3     	mov	x3, x4
     a08: aa0703e6     	mov	x6, x7
     a0c: 94000000     	bl	0xa0c <___pl_fn_1+0x900>
     a10: aa1903e0     	mov	x0, x25
     a14: b9402c00     	ldr	w0, [x0, #0x2c]
     a18: 3501b940     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
     a1c: aa1903e0     	mov	x0, x25
     a20: b9001813     	str	w19, [x0, #0x18]
     a24: f9403c00     	ldr	x0, [x0, #0x78]
     a28: 37592120     	tbnz	w0, #0xb, 0x2e4c <___pl_fn_1+0x2d40>
     a2c: aa1903e0     	mov	x0, x25
     a30: f9403800     	ldr	x0, [x0, #0x70]
     a34: f100001f     	cmp	x0, #0x0
     a38: 540120ed     	b.le	0x2e54 <___pl_fn_1+0x2d48>
     a3c: aa1903e0     	mov	x0, x25
     a40: f9403401     	ldr	x1, [x0, #0x68]
     a44: d2800120     	mov	x0, #0x9                ; =9
     a48: f100243f     	cmp	x1, #0x9
     a4c: 5401208b     	b.lt	0x2e5c <___pl_fn_1+0x2d50>
     a50: aa1903e1     	mov	x1, x25
     a54: f9402821     	ldr	x1, [x1, #0x50]
     a58: aa1903e2     	mov	x2, x25
     a5c: f9402c42     	ldr	x2, [x2, #0x58]
     a60: 91002c23     	add	x3, x1, #0xb
     a64: eb02007f     	cmp	x3, x2
     a68: 54011fe8     	b.hi	0x2e64 <___pl_fn_1+0x2d58>
     a6c: aa1903e2     	mov	x2, x25
     a70: f9404442     	ldr	x2, [x2, #0x88]
     a74: aa1903e3     	mov	x3, x25
     a78: f9404863     	ldr	x3, [x3, #0x90]
     a7c: eb03005f     	cmp	x2, x3
     a80: 54011f62     	b.hs	0x2e6c <___pl_fn_1+0x2d60>
     a84: aa1903e3     	mov	x3, x25
     a88: b9401c63     	ldr	w3, [x3, #0x1c]
     a8c: 11000e64     	add	w4, w19, #0x3
     a90: 6b03009f     	cmp	w4, w3
     a94: 540002e9     	b.ls	0xaf0 <___pl_fn_1+0x9e4>
     a98: 140008f7     	b	0x2e74 <___pl_fn_1+0x2d68>
     a9c: aa1903e1     	mov	x1, x25
     aa0: f9401022     	ldr	x2, [x1, #0x20]
     aa4: 8b160841     	add	x1, x2, x22, lsl #2
     aa8: aa1b03e3     	mov	x3, x27
     aac: b8335843     	str	w3, [x2, w19, uxtw #2]
     ab0: aa1c03e5     	mov	x5, x28
     ab4: b9000425     	str	w5, [x1, #0x4]
     ab8: b9000834     	str	w20, [x1, #0x8]
     abc: aa1903e1     	mov	x1, x25
     ac0: b9001820     	str	w0, [x1, #0x18]
     ac4: 528003e1     	mov	w1, #0x1f               ; =31
     ac8: 52800002     	mov	w2, #0x0                ; =0
     acc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     ad0: f9400063     	ldr	x3, [x3]
     ad4: aa1903e0     	mov	x0, x25
     ad8: d63f0060     	blr	x3
     adc: 3501b320     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
     ae0: aa1903e0     	mov	x0, x25
     ae4: f9401801     	ldr	x1, [x0, #0x30]
     ae8: b9001813     	str	w19, [x0, #0x18]
     aec: 1400002b     	b	0xb98 <___pl_fn_1+0xa8c>
     af0: aa1903e3     	mov	x3, x25
     af4: f9403065     	ldr	x5, [x3, #0x60]
     af8: f9400066     	ldr	x6, [x3]
     afc: b20007e7     	mov	x7, #0x300000003        ; =12884901891
     b00: 2a0103e3     	mov	w3, w1
     b04: 8b030cc4     	add	x4, x6, x3, lsl #3
     b08: f82158c7     	str	x7, [x6, w1, uxtw #3]
     b0c: 910004a5     	add	x5, x5, #0x1
     b10: f9000485     	str	x5, [x4, #0x8]
     b14: 92800006     	mov	x6, #-0x1               ; =-1
     b18: f9000886     	str	x6, [x4, #0x10]
     b1c: d2800006     	mov	x6, #0x0                ; =0
     b20: f9000c86     	str	x6, [x4, #0x18]
     b24: f9001086     	str	x6, [x4, #0x20]
     b28: f9001486     	str	x6, [x4, #0x28]
     b2c: f9001886     	str	x6, [x4, #0x30]
     b30: f9001c86     	str	x6, [x4, #0x38]
     b34: f9002086     	str	x6, [x4, #0x40]
     b38: f9002486     	str	x6, [x4, #0x48]
     b3c: f9002886     	str	x6, [x4, #0x50]
     b40: aa1903e4     	mov	x4, x25
     b44: f9003085     	str	x5, [x4, #0x60]
     b48: 91002c24     	add	x4, x1, #0xb
     b4c: aa1903e5     	mov	x5, x25
     b50: f90028a4     	str	x4, [x5, #0x50]
     b54: aa1903e4     	mov	x4, x25
     b58: f9403485     	ldr	x5, [x4, #0x68]
     b5c: d10024a5     	sub	x5, x5, #0x9
     b60: f9003485     	str	x5, [x4, #0x68]
     b64: f9403886     	ldr	x6, [x4, #0x70]
     b68: d10024c6     	sub	x6, x6, #0x9
     b6c: f9003886     	str	x6, [x4, #0x70]
     b70: f9404087     	ldr	x7, [x4, #0x80]
     b74: d2c00168     	mov	x8, #0xb00000000        ; =47244640256
     b78: aa080068     	orr	x8, x3, x8
     b7c: d37cec49     	lsl	x9, x2, #4
     b80: 8b0210ea     	add	x10, x7, x2, lsl #4
     b84: f82968e8     	str	x8, [x7, x9]
     b88: f9000540     	str	x0, [x10, #0x8]
     b8c: 91000449     	add	x9, x2, #0x1
     b90: aa1903e0     	mov	x0, x25
     b94: f9004409     	str	x9, [x0, #0x88]
     b98: aa1903e0     	mov	x0, x25
     b9c: b9401813     	ldr	w19, [x0, #0x18]
     ba0: b9401c0b     	ldr	w11, [x0, #0x1c]
     ba4: 11001276     	add	w22, w19, #0x4
     ba8: 6b0b02df     	cmp	w22, w11
     bac: 5401a148     	b.hi	0x3fd4 <___pl_fn_1+0x3ec8>
     bb0: aa1903e0     	mov	x0, x25
     bb4: f940100e     	ldr	x14, [x0, #0x20]
     bb8: 2a1303f7     	mov	w23, w19
     bbc: 8b1709cd     	add	x13, x14, x23, lsl #2
     bc0: aa1b03e2     	mov	x2, x27
     bc4: b83359c2     	str	w2, [x14, w19, uxtw #2]
     bc8: aa1c03e5     	mov	x5, x28
     bcc: b90005a5     	str	w5, [x13, #0x4]
     bd0: b90009b4     	str	w20, [x13, #0x8]
     bd4: b9000da1     	str	w1, [x13, #0xc]
     bd8: b9001816     	str	w22, [x0, #0x18]
     bdc: b9401000     	ldr	w0, [x0, #0x10]
     be0: aa1903e2     	mov	x2, x25
     be4: b9401442     	ldr	w2, [x2, #0x14]
     be8: 6b02001f     	cmp	w0, w2
     bec: 54019da2     	b.hs	0x3fa0 <___pl_fn_1+0x3e94>
     bf0: d2800003     	mov	x3, #0x0                ; =0
     bf4: d2807d24     	mov	x4, #0x3e9              ; =1001
     bf8: aa1903e0     	mov	x0, x25
     bfc: aa1c03e2     	mov	x2, x28
     c00: 94000000     	bl	0xc00 <___pl_fn_1+0xaf4>
     c04: aa1903e1     	mov	x1, x25
     c08: b9402c21     	ldr	w1, [x1, #0x2c]
     c0c: 3501a9a1     	cbnz	w1, 0x4140 <___pl_fn_1+0x4034>
     c10: aa1903e1     	mov	x1, x25
     c14: b9001833     	str	w19, [x1, #0x18]
     c18: 34019aa0     	cbz	w0, 0x3f6c <___pl_fn_1+0x3e60>
     c1c: aa1903e1     	mov	x1, x25
     c20: f9403c21     	ldr	x1, [x1, #0x78]
     c24: 37591501     	tbnz	w1, #0xb, 0x2ec4 <___pl_fn_1+0x2db8>
     c28: aa1903e1     	mov	x1, x25
     c2c: f9403821     	ldr	x1, [x1, #0x70]
     c30: f100003f     	cmp	x1, #0x0
     c34: 540114cd     	b.le	0x2ecc <___pl_fn_1+0x2dc0>
     c38: aa1903e1     	mov	x1, x25
     c3c: f9403421     	ldr	x1, [x1, #0x68]
     c40: d2800123     	mov	x3, #0x9                ; =9
     c44: f100243f     	cmp	x1, #0x9
     c48: 5401146b     	b.lt	0x2ed4 <___pl_fn_1+0x2dc8>
     c4c: aa1903e1     	mov	x1, x25
     c50: f9402821     	ldr	x1, [x1, #0x50]
     c54: aa1903e2     	mov	x2, x25
     c58: f9402c42     	ldr	x2, [x2, #0x58]
     c5c: 91002c24     	add	x4, x1, #0xb
     c60: eb02009f     	cmp	x4, x2
     c64: 540113c8     	b.hi	0x2edc <___pl_fn_1+0x2dd0>
     c68: aa1903e2     	mov	x2, x25
     c6c: f9404442     	ldr	x2, [x2, #0x88]
     c70: aa1903e4     	mov	x4, x25
     c74: f9404884     	ldr	x4, [x4, #0x90]
     c78: eb04005f     	cmp	x2, x4
     c7c: 54011342     	b.hs	0x2ee4 <___pl_fn_1+0x2dd8>
     c80: aa1903e4     	mov	x4, x25
     c84: b9401c84     	ldr	w4, [x4, #0x1c]
     c88: 6b0402df     	cmp	w22, w4
     c8c: 54000309     	b.ls	0xcec <___pl_fn_1+0xbe0>
     c90: 14000897     	b	0x2eec <___pl_fn_1+0x2de0>
     c94: aa1903ea     	mov	x10, x25
     c98: f9401142     	ldr	x2, [x10, #0x20]
     c9c: 8b170841     	add	x1, x2, x23, lsl #2
     ca0: aa1b03e3     	mov	x3, x27
     ca4: b8335843     	str	w3, [x2, w19, uxtw #2]
     ca8: aa1c03e5     	mov	x5, x28
     cac: b9000425     	str	w5, [x1, #0x4]
     cb0: b9000834     	str	w20, [x1, #0x8]
     cb4: b9000c20     	str	w0, [x1, #0xc]
     cb8: aa0003f8     	mov	x24, x0
     cbc: aa1903e0     	mov	x0, x25
     cc0: b9001816     	str	w22, [x0, #0x18]
     cc4: 52800481     	mov	w1, #0x24               ; =36
     cc8: 52800002     	mov	w2, #0x0                ; =0
     ccc: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     cd0: f9400063     	ldr	x3, [x3]
     cd4: d63f0060     	blr	x3
     cd8: 3501a340     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
     cdc: aa1903e0     	mov	x0, x25
     ce0: f9401801     	ldr	x1, [x0, #0x30]
     ce4: b9001813     	str	w19, [x0, #0x18]
     ce8: 1400002f     	b	0xda4 <___pl_fn_1+0xc98>
     cec: aa0003f8     	mov	x24, x0
     cf0: aa1903e0     	mov	x0, x25
     cf4: f9403005     	ldr	x5, [x0, #0x60]
     cf8: f9400006     	ldr	x6, [x0]
     cfc: b20007e7     	mov	x7, #0x300000003        ; =12884901891
     d00: 2a0103e0     	mov	w0, w1
     d04: 8b000cc4     	add	x4, x6, x0, lsl #3
     d08: f82158c7     	str	x7, [x6, w1, uxtw #3]
     d0c: 910004a5     	add	x5, x5, #0x1
     d10: f9000485     	str	x5, [x4, #0x8]
     d14: 92800006     	mov	x6, #-0x1               ; =-1
     d18: f9000886     	str	x6, [x4, #0x10]
     d1c: d2800006     	mov	x6, #0x0                ; =0
     d20: f9000c86     	str	x6, [x4, #0x18]
     d24: f9001086     	str	x6, [x4, #0x20]
     d28: f9001486     	str	x6, [x4, #0x28]
     d2c: f9001886     	str	x6, [x4, #0x30]
     d30: f9001c86     	str	x6, [x4, #0x38]
     d34: f9002086     	str	x6, [x4, #0x40]
     d38: f9002486     	str	x6, [x4, #0x48]
     d3c: f9002886     	str	x6, [x4, #0x50]
     d40: aa1903e4     	mov	x4, x25
     d44: f9003085     	str	x5, [x4, #0x60]
     d48: 91002c24     	add	x4, x1, #0xb
     d4c: aa1903e5     	mov	x5, x25
     d50: f90028a4     	str	x4, [x5, #0x50]
     d54: aa1903e4     	mov	x4, x25
     d58: f9403484     	ldr	x4, [x4, #0x68]
     d5c: d1002484     	sub	x4, x4, #0x9
     d60: f90034a4     	str	x4, [x5, #0x68]
     d64: aa1903e4     	mov	x4, x25
     d68: f9403884     	ldr	x4, [x4, #0x70]
     d6c: d1002484     	sub	x4, x4, #0x9
     d70: aa1903e6     	mov	x6, x25
     d74: f90038c4     	str	x4, [x6, #0x70]
     d78: aa1903e8     	mov	x8, x25
     d7c: f9404105     	ldr	x5, [x8, #0x80]
     d80: d2c00166     	mov	x6, #0xb00000000        ; =47244640256
     d84: aa060006     	orr	x6, x0, x6
     d88: d37cec47     	lsl	x7, x2, #4
     d8c: 8b0210a8     	add	x8, x5, x2, lsl #4
     d90: f82768a6     	str	x6, [x5, x7]
     d94: f9000503     	str	x3, [x8, #0x8]
     d98: 91000447     	add	x7, x2, #0x1
     d9c: aa1903e0     	mov	x0, x25
     da0: f9004407     	str	x7, [x0, #0x88]
     da4: aa1903e0     	mov	x0, x25
     da8: b9401816     	ldr	w22, [x0, #0x18]
     dac: b9401c09     	ldr	w9, [x0, #0x1c]
     db0: 528000b3     	mov	w19, #0x5               ; =5
     db4: 110016ca     	add	w10, w22, #0x5
     db8: 6b09015f     	cmp	w10, w9
     dbc: 54018be8     	b.hi	0x3f38 <___pl_fn_1+0x3e2c>
     dc0: aa1903e0     	mov	x0, x25
     dc4: f940100c     	ldr	x12, [x0, #0x20]
     dc8: 2a1603f7     	mov	w23, w22
     dcc: 8b17098b     	add	x11, x12, x23, lsl #2
     dd0: aa1b03e2     	mov	x2, x27
     dd4: b8365982     	str	w2, [x12, w22, uxtw #2]
     dd8: aa1c03e5     	mov	x5, x28
     ddc: b9000565     	str	w5, [x11, #0x4]
     de0: b9000974     	str	w20, [x11, #0x8]
     de4: aa1803e0     	mov	x0, x24
     de8: b9000d60     	str	w0, [x11, #0xc]
     dec: b9001161     	str	w1, [x11, #0x10]
     df0: 110016c0     	add	w0, w22, #0x5
     df4: aa1903e2     	mov	x2, x25
     df8: b9001840     	str	w0, [x2, #0x18]
     dfc: aa1903e0     	mov	x0, x25
     e00: b9401000     	ldr	w0, [x0, #0x10]
     e04: b9401442     	ldr	w2, [x2, #0x14]
     e08: 6b02001f     	cmp	w0, w2
     e0c: 540187c2     	b.hs	0x3f04 <___pl_fn_1+0x3df8>
     e10: d2800003     	mov	x3, #0x0                ; =0
     e14: d2807d24     	mov	x4, #0x3e9              ; =1001
     e18: aa1803e2     	mov	x2, x24
     e1c: aa1903e0     	mov	x0, x25
     e20: 94000000     	bl	0xe20 <___pl_fn_1+0xd14>
     e24: aa1903e1     	mov	x1, x25
     e28: b9402c21     	ldr	w1, [x1, #0x2c]
     e2c: 350198a1     	cbnz	w1, 0x4140 <___pl_fn_1+0x4034>
     e30: aa1903e1     	mov	x1, x25
     e34: b9001836     	str	w22, [x1, #0x18]
     e38: 340184c0     	cbz	w0, 0x3ed0 <___pl_fn_1+0x3dc4>
     e3c: aa1903e1     	mov	x1, x25
     e40: f9403c21     	ldr	x1, [x1, #0x78]
     e44: 376907a1     	tbnz	w1, #0xd, 0x2f38 <___pl_fn_1+0x2e2c>
     e48: aa1903e1     	mov	x1, x25
     e4c: f9403821     	ldr	x1, [x1, #0x70]
     e50: f100003f     	cmp	x1, #0x0
     e54: 5401076d     	b.le	0x2f40 <___pl_fn_1+0x2e34>
     e58: aa1903e2     	mov	x2, x25
     e5c: f9403441     	ldr	x1, [x2, #0x68]
     e60: d2800162     	mov	x2, #0xb                ; =11
     e64: f1002c3f     	cmp	x1, #0xb
     e68: 5401070b     	b.lt	0x2f48 <___pl_fn_1+0x2e3c>
     e6c: aa1903e8     	mov	x8, x25
     e70: f940291a     	ldr	x26, [x8, #0x50]
     e74: aa1903ea     	mov	x10, x25
     e78: f9402d41     	ldr	x1, [x10, #0x58]
     e7c: 91003743     	add	x3, x26, #0xd
     e80: eb01007f     	cmp	x3, x1
     e84: 54010668     	b.hi	0x2f50 <___pl_fn_1+0x2e44>
     e88: aa1903e1     	mov	x1, x25
     e8c: f9404421     	ldr	x1, [x1, #0x88]
     e90: aa1903e3     	mov	x3, x25
     e94: f9404863     	ldr	x3, [x3, #0x90]
     e98: eb03003f     	cmp	x1, x3
     e9c: 540105e2     	b.hs	0x2f58 <___pl_fn_1+0x2e4c>
     ea0: aa1903e3     	mov	x3, x25
     ea4: b9401c63     	ldr	w3, [x3, #0x1c]
     ea8: 110012c4     	add	w4, w22, #0x4
     eac: 6b03009f     	cmp	w4, w3
     eb0: 54000309     	b.ls	0xf10 <___pl_fn_1+0xe04>
     eb4: 1400082b     	b	0x2f60 <___pl_fn_1+0x2e54>
     eb8: aa1903e2     	mov	x2, x25
     ebc: f9401043     	ldr	x3, [x2, #0x20]
     ec0: 8b170862     	add	x2, x3, x23, lsl #2
     ec4: aa1b03e4     	mov	x4, x27
     ec8: b8365864     	str	w4, [x3, w22, uxtw #2]
     ecc: aa1c03e5     	mov	x5, x28
     ed0: b9000445     	str	w5, [x2, #0x4]
     ed4: b9000854     	str	w20, [x2, #0x8]
     ed8: b9000c40     	str	w0, [x2, #0xc]
     edc: aa0003f8     	mov	x24, x0
     ee0: aa1903e0     	mov	x0, x25
     ee4: b9001801     	str	w1, [x0, #0x18]
     ee8: 52800521     	mov	w1, #0x29               ; =41
     eec: 528000c2     	mov	w2, #0x6                ; =6
     ef0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     ef4: f9400063     	ldr	x3, [x3]
     ef8: d63f0060     	blr	x3
     efc: 35019220     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
     f00: aa1903e0     	mov	x0, x25
     f04: f940181a     	ldr	x26, [x0, #0x30]
     f08: b9001816     	str	w22, [x0, #0x18]
     f0c: 1400002f     	b	0xfc8 <___pl_fn_1+0xebc>
     f10: aa0003f8     	mov	x24, x0
     f14: aa1903e0     	mov	x0, x25
     f18: f9403004     	ldr	x4, [x0, #0x60]
     f1c: f9400005     	ldr	x5, [x0]
     f20: d2800126     	mov	x6, #0x9                ; =9
     f24: f2c00066     	movk	x6, #0x3, lsl #32
     f28: 2a1a03e0     	mov	w0, w26
     f2c: 8b000ca3     	add	x3, x5, x0, lsl #3
     f30: f83a58a6     	str	x6, [x5, w26, uxtw #3]
     f34: 91000484     	add	x4, x4, #0x1
     f38: f9000464     	str	x4, [x3, #0x8]
     f3c: 92800005     	mov	x5, #-0x1               ; =-1
     f40: f9000865     	str	x5, [x3, #0x10]
     f44: d2800005     	mov	x5, #0x0                ; =0
     f48: f9000c65     	str	x5, [x3, #0x18]
     f4c: f9001065     	str	x5, [x3, #0x20]
     f50: f9001465     	str	x5, [x3, #0x28]
     f54: f9001865     	str	x5, [x3, #0x30]
     f58: f9001c75     	str	x21, [x3, #0x38]
     f5c: f9002075     	str	x21, [x3, #0x40]
     f60: f9002475     	str	x21, [x3, #0x48]
     f64: f9002865     	str	x5, [x3, #0x50]
     f68: f9002c65     	str	x5, [x3, #0x58]
     f6c: f9003065     	str	x5, [x3, #0x60]
     f70: aa1903e3     	mov	x3, x25
     f74: f9003064     	str	x4, [x3, #0x60]
     f78: 91003743     	add	x3, x26, #0xd
     f7c: aa1903e4     	mov	x4, x25
     f80: f9002883     	str	x3, [x4, #0x50]
     f84: aa1903e3     	mov	x3, x25
     f88: f9403464     	ldr	x4, [x3, #0x68]
     f8c: d1002c84     	sub	x4, x4, #0xb
     f90: f9003464     	str	x4, [x3, #0x68]
     f94: f9403865     	ldr	x5, [x3, #0x70]
     f98: d1002ca5     	sub	x5, x5, #0xb
     f9c: f9003865     	str	x5, [x3, #0x70]
     fa0: f9404066     	ldr	x6, [x3, #0x80]
     fa4: d2c001a7     	mov	x7, #0xd00000000        ; =55834574848
     fa8: aa070007     	orr	x7, x0, x7
     fac: d37cec28     	lsl	x8, x1, #4
     fb0: 8b0110c9     	add	x9, x6, x1, lsl #4
     fb4: f82868c7     	str	x7, [x6, x8]
     fb8: f9000522     	str	x2, [x9, #0x8]
     fbc: 91000428     	add	x8, x1, #0x1
     fc0: aa1903e0     	mov	x0, x25
     fc4: f9004408     	str	x8, [x0, #0x88]
     fc8: 340176ba     	cbz	w26, 0x3e9c <___pl_fn_1+0x3d90>
     fcc: 3400ff1a     	cbz	w26, 0x2fac <___pl_fn_1+0x2ea0>
     fd0: aa1903e0     	mov	x0, x25
     fd4: aa1a03f6     	mov	x22, x26
     fd8: f9400002     	ldr	x2, [x0]
     fdc: 2a1603e1     	mov	w1, w22
     fe0: d2800060     	mov	x0, #0x3                ; =3
     fe4: 8b010c41     	add	x1, x2, x1, lsl #3
     fe8: f8765842     	ldr	x2, [x2, w22, uxtw #3]
     fec: d360fc42     	lsr	x2, x2, #32
     ff0: 92403c43     	and	x3, x2, #0xffff
     ff4: f100087f     	cmp	x3, #0x2
     ff8: 54000080     	b.eq	0x1008 <___pl_fn_1+0xefc>
     ffc: f9400823     	ldr	x3, [x1, #0x10]
    1000: 9277f863     	and	x3, x3, #0xfffffffffffffeff
    1004: f9000823     	str	x3, [x1, #0x10]
    1008: 92403c42     	and	x2, x2, #0xffff
    100c: 91002042     	add	x2, x2, #0x8
    1010: f8227820     	str	x0, [x1, x2, lsl #3]
    1014: 350000b6     	cbnz	w22, 0x1028 <___pl_fn_1+0xf1c>
    1018: 140007f3     	b	0x2fe4 <___pl_fn_1+0x2ed8>
    101c: aa1903e0     	mov	x0, x25
    1020: aa1603e1     	mov	x1, x22
    1024: 14000013     	b	0x1070 <___pl_fn_1+0xf64>
    1028: aa1903e0     	mov	x0, x25
    102c: f9400002     	ldr	x2, [x0]
    1030: aa1603e1     	mov	x1, x22
    1034: 2a0103e0     	mov	w0, w1
    1038: 8b000c40     	add	x0, x2, x0, lsl #3
    103c: f8615842     	ldr	x2, [x2, w1, uxtw #3]
    1040: d360fc42     	lsr	x2, x2, #32
    1044: 92403c43     	and	x3, x2, #0xffff
    1048: f100087f     	cmp	x3, #0x2
    104c: 54000080     	b.eq	0x105c <___pl_fn_1+0xf50>
    1050: f9400803     	ldr	x3, [x0, #0x10]
    1054: 9276f863     	and	x3, x3, #0xfffffffffffffdff
    1058: f9000803     	str	x3, [x0, #0x10]
    105c: d2800003     	mov	x3, #0x0                ; =0
    1060: 92403c42     	and	x2, x2, #0xffff
    1064: 91002442     	add	x2, x2, #0x9
    1068: f8227803     	str	x3, [x0, x2, lsl #3]
    106c: aa1903e0     	mov	x0, x25
    1070: aa1903e0     	mov	x0, x25
    1074: b9401816     	ldr	w22, [x0, #0x18]
    1078: b9401c00     	ldr	w0, [x0, #0x1c]
    107c: 110016c2     	add	w2, w22, #0x5
    1080: 6b00005f     	cmp	w2, w0
    1084: 54016f28     	b.hi	0x3e68 <___pl_fn_1+0x3d5c>
    1088: aa1903e0     	mov	x0, x25
    108c: f9401002     	ldr	x2, [x0, #0x20]
    1090: 2a1603f7     	mov	w23, w22
    1094: 8b170840     	add	x0, x2, x23, lsl #2
    1098: aa1b03e3     	mov	x3, x27
    109c: b8365843     	str	w3, [x2, w22, uxtw #2]
    10a0: aa1c03e5     	mov	x5, x28
    10a4: b9000405     	str	w5, [x0, #0x4]
    10a8: b9000814     	str	w20, [x0, #0x8]
    10ac: aa1803e4     	mov	x4, x24
    10b0: b9000c04     	str	w4, [x0, #0xc]
    10b4: b9001001     	str	w1, [x0, #0x10]
    10b8: 110016c0     	add	w0, w22, #0x5
    10bc: aa1903e2     	mov	x2, x25
    10c0: b9001840     	str	w0, [x2, #0x18]
    10c4: aa1903e0     	mov	x0, x25
    10c8: b9401000     	ldr	w0, [x0, #0x10]
    10cc: aa1903e5     	mov	x5, x25
    10d0: b94014a2     	ldr	w2, [x5, #0x14]
    10d4: 6b02001f     	cmp	w0, w2
    10d8: 54016ae2     	b.hs	0x3e34 <___pl_fn_1+0x3d28>
    10dc: d2807d04     	mov	x4, #0x3e8              ; =1000
    10e0: 52800027     	mov	w7, #0x1                ; =1
    10e4: aa1803e5     	mov	x5, x24
    10e8: aa1903e0     	mov	x0, x25
    10ec: aa1b03e2     	mov	x2, x27
    10f0: aa1503e3     	mov	x3, x21
    10f4: aa0703e6     	mov	x6, x7
    10f8: 94000000     	bl	0x10f8 <___pl_fn_1+0xfec>
    10fc: aa1903e0     	mov	x0, x25
    1100: b9402c00     	ldr	w0, [x0, #0x2c]
    1104: 350181e0     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    1108: aa1903e0     	mov	x0, x25
    110c: b9001816     	str	w22, [x0, #0x18]
    1110: f9403c00     	ldr	x0, [x0, #0x78]
    1114: 3758f820     	tbnz	w0, #0xb, 0x3018 <___pl_fn_1+0x2f0c>
    1118: aa1903e0     	mov	x0, x25
    111c: f9403800     	ldr	x0, [x0, #0x70]
    1120: f100001f     	cmp	x0, #0x0
    1124: 5400f7ed     	b.le	0x3020 <___pl_fn_1+0x2f14>
    1128: aa1903e0     	mov	x0, x25
    112c: f9403401     	ldr	x1, [x0, #0x68]
    1130: d2800120     	mov	x0, #0x9                ; =9
    1134: f100243f     	cmp	x1, #0x9
    1138: 5400f78b     	b.lt	0x3028 <___pl_fn_1+0x2f1c>
    113c: aa1903e1     	mov	x1, x25
    1140: f9402821     	ldr	x1, [x1, #0x50]
    1144: aa1903e2     	mov	x2, x25
    1148: f9402c42     	ldr	x2, [x2, #0x58]
    114c: 91002c23     	add	x3, x1, #0xb
    1150: eb02007f     	cmp	x3, x2
    1154: 5400f6e8     	b.hi	0x3030 <___pl_fn_1+0x2f24>
    1158: aa1903e2     	mov	x2, x25
    115c: f9404442     	ldr	x2, [x2, #0x88]
    1160: aa1903e3     	mov	x3, x25
    1164: f9404863     	ldr	x3, [x3, #0x90]
    1168: eb03005f     	cmp	x2, x3
    116c: 5400f662     	b.hs	0x3038 <___pl_fn_1+0x2f2c>
    1170: aa1903e3     	mov	x3, x25
    1174: b9401c63     	ldr	w3, [x3, #0x1c]
    1178: 11000ec4     	add	w4, w22, #0x3
    117c: 6b03009f     	cmp	w4, w3
    1180: 540002c9     	b.ls	0x11d8 <___pl_fn_1+0x10cc>
    1184: 140007af     	b	0x3040 <___pl_fn_1+0x2f34>
    1188: aa1903e0     	mov	x0, x25
    118c: f9401008     	ldr	x8, [x0, #0x20]
    1190: 8b170907     	add	x7, x8, x23, lsl #2
    1194: aa1b03e2     	mov	x2, x27
    1198: b8365902     	str	w2, [x8, w22, uxtw #2]
    119c: aa1c03e0     	mov	x0, x28
    11a0: b90004e0     	str	w0, [x7, #0x4]
    11a4: b90008f4     	str	w20, [x7, #0x8]
    11a8: aa1903e0     	mov	x0, x25
    11ac: b9001805     	str	w5, [x0, #0x18]
    11b0: 52800601     	mov	w1, #0x30               ; =48
    11b4: 52800002     	mov	w2, #0x0                ; =0
    11b8: 9000000b     	adrp	x11, 0x1000 <___pl_fn_1+0xef4>
    11bc: f940016b     	ldr	x11, [x11]
    11c0: d63f0160     	blr	x11
    11c4: 35017be0     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    11c8: aa1903e0     	mov	x0, x25
    11cc: f9401801     	ldr	x1, [x0, #0x30]
    11d0: b9001816     	str	w22, [x0, #0x18]
    11d4: 1400002e     	b	0x128c <___pl_fn_1+0x1180>
    11d8: aa1903e3     	mov	x3, x25
    11dc: f9403065     	ldr	x5, [x3, #0x60]
    11e0: f9400066     	ldr	x6, [x3]
    11e4: b20007e7     	mov	x7, #0x300000003        ; =12884901891
    11e8: 2a0103e3     	mov	w3, w1
    11ec: 8b030cc4     	add	x4, x6, x3, lsl #3
    11f0: f82158c7     	str	x7, [x6, w1, uxtw #3]
    11f4: 910004a5     	add	x5, x5, #0x1
    11f8: f9000485     	str	x5, [x4, #0x8]
    11fc: 92800006     	mov	x6, #-0x1               ; =-1
    1200: f9000886     	str	x6, [x4, #0x10]
    1204: d2800006     	mov	x6, #0x0                ; =0
    1208: f9000c86     	str	x6, [x4, #0x18]
    120c: f9001086     	str	x6, [x4, #0x20]
    1210: f9001486     	str	x6, [x4, #0x28]
    1214: f9001886     	str	x6, [x4, #0x30]
    1218: f9001c86     	str	x6, [x4, #0x38]
    121c: f9002086     	str	x6, [x4, #0x40]
    1220: f9002486     	str	x6, [x4, #0x48]
    1224: f9002886     	str	x6, [x4, #0x50]
    1228: aa1903e4     	mov	x4, x25
    122c: f9003085     	str	x5, [x4, #0x60]
    1230: 91002c24     	add	x4, x1, #0xb
    1234: aa1903e5     	mov	x5, x25
    1238: f90028a4     	str	x4, [x5, #0x50]
    123c: aa1903e4     	mov	x4, x25
    1240: f9403484     	ldr	x4, [x4, #0x68]
    1244: d1002484     	sub	x4, x4, #0x9
    1248: f90034a4     	str	x4, [x5, #0x68]
    124c: aa1903e4     	mov	x4, x25
    1250: f9403884     	ldr	x4, [x4, #0x70]
    1254: d1002484     	sub	x4, x4, #0x9
    1258: f90038a4     	str	x4, [x5, #0x70]
    125c: aa1903e4     	mov	x4, x25
    1260: f9404084     	ldr	x4, [x4, #0x80]
    1264: d2c00165     	mov	x5, #0xb00000000        ; =47244640256
    1268: aa050063     	orr	x3, x3, x5
    126c: d37cec45     	lsl	x5, x2, #4
    1270: 8b021086     	add	x6, x4, x2, lsl #4
    1274: f8256883     	str	x3, [x4, x5]
    1278: f90004c0     	str	x0, [x6, #0x8]
    127c: 91000440     	add	x0, x2, #0x1
    1280: aa1903e2     	mov	x2, x25
    1284: f9004440     	str	x0, [x2, #0x88]
    1288: aa1903e0     	mov	x0, x25
    128c: aa1903e0     	mov	x0, x25
    1290: b9401816     	ldr	w22, [x0, #0x18]
    1294: b9401c00     	ldr	w0, [x0, #0x1c]
    1298: 110012d7     	add	w23, w22, #0x4
    129c: 6b0002ff     	cmp	w23, w0
    12a0: 54015b08     	b.hi	0x3e00 <___pl_fn_1+0x3cf4>
    12a4: aa1903e0     	mov	x0, x25
    12a8: f9401002     	ldr	x2, [x0, #0x20]
    12ac: 2a1603f8     	mov	w24, w22
    12b0: 8b180840     	add	x0, x2, x24, lsl #2
    12b4: aa1b03e3     	mov	x3, x27
    12b8: b8365843     	str	w3, [x2, w22, uxtw #2]
    12bc: aa1c03e5     	mov	x5, x28
    12c0: b9000405     	str	w5, [x0, #0x4]
    12c4: b9000814     	str	w20, [x0, #0x8]
    12c8: b9000c01     	str	w1, [x0, #0xc]
    12cc: aa1903e0     	mov	x0, x25
    12d0: b9001817     	str	w23, [x0, #0x18]
    12d4: b9401000     	ldr	w0, [x0, #0x10]
    12d8: aa1903e2     	mov	x2, x25
    12dc: b9401442     	ldr	w2, [x2, #0x14]
    12e0: 6b02001f     	cmp	w0, w2
    12e4: 54015742     	b.hs	0x3dcc <___pl_fn_1+0x3cc0>
    12e8: d28000a3     	mov	x3, #0x5                ; =5
    12ec: d2807d04     	mov	x4, #0x3e8              ; =1000
    12f0: aa1903e0     	mov	x0, x25
    12f4: aa1c03e2     	mov	x2, x28
    12f8: 94000000     	bl	0x12f8 <___pl_fn_1+0x11ec>
    12fc: aa1903e1     	mov	x1, x25
    1300: b9402c21     	ldr	w1, [x1, #0x2c]
    1304: 350171e1     	cbnz	w1, 0x4140 <___pl_fn_1+0x4034>
    1308: aa1903e1     	mov	x1, x25
    130c: b9001836     	str	w22, [x1, #0x18]
    1310: 34015440     	cbz	w0, 0x3d98 <___pl_fn_1+0x3c8c>
    1314: aa1903e1     	mov	x1, x25
    1318: f9403c21     	ldr	x1, [x1, #0x78]
    131c: 3758eba1     	tbnz	w1, #0xb, 0x3090 <___pl_fn_1+0x2f84>
    1320: aa1903e1     	mov	x1, x25
    1324: f9403821     	ldr	x1, [x1, #0x70]
    1328: f100003f     	cmp	x1, #0x0
    132c: 5400eb6d     	b.le	0x3098 <___pl_fn_1+0x2f8c>
    1330: aa1903e1     	mov	x1, x25
    1334: f9403421     	ldr	x1, [x1, #0x68]
    1338: d2800123     	mov	x3, #0x9                ; =9
    133c: f100243f     	cmp	x1, #0x9
    1340: 5400eb0b     	b.lt	0x30a0 <___pl_fn_1+0x2f94>
    1344: aa1903e1     	mov	x1, x25
    1348: f9402821     	ldr	x1, [x1, #0x50]
    134c: aa1903e2     	mov	x2, x25
    1350: f9402c42     	ldr	x2, [x2, #0x58]
    1354: 91002c24     	add	x4, x1, #0xb
    1358: eb02009f     	cmp	x4, x2
    135c: 5400ea68     	b.hi	0x30a8 <___pl_fn_1+0x2f9c>
    1360: aa1903e2     	mov	x2, x25
    1364: f9404442     	ldr	x2, [x2, #0x88]
    1368: aa1903e4     	mov	x4, x25
    136c: f9404884     	ldr	x4, [x4, #0x90]
    1370: eb04005f     	cmp	x2, x4
    1374: 5400e9e2     	b.hs	0x30b0 <___pl_fn_1+0x2fa4>
    1378: aa1903e5     	mov	x5, x25
    137c: b9401ca4     	ldr	w4, [x5, #0x1c]
    1380: 6b0402ff     	cmp	w23, w4
    1384: 54000309     	b.ls	0x13e4 <___pl_fn_1+0x12d8>
    1388: 1400074c     	b	0x30b8 <___pl_fn_1+0x2fac>
    138c: aa1903ee     	mov	x14, x25
    1390: f94011c5     	ldr	x5, [x14, #0x20]
    1394: 8b1808a4     	add	x4, x5, x24, lsl #2
    1398: aa1b03e2     	mov	x2, x27
    139c: b83658a2     	str	w2, [x5, w22, uxtw #2]
    13a0: aa1c03e5     	mov	x5, x28
    13a4: b9000485     	str	w5, [x4, #0x4]
    13a8: b9000894     	str	w20, [x4, #0x8]
    13ac: b9000c80     	str	w0, [x4, #0xc]
    13b0: aa0003f8     	mov	x24, x0
    13b4: aa1903e0     	mov	x0, x25
    13b8: b9001817     	str	w23, [x0, #0x18]
    13bc: 528006a1     	mov	w1, #0x35               ; =53
    13c0: 52800002     	mov	w2, #0x0                ; =0
    13c4: 90000009     	adrp	x9, 0x1000 <___pl_fn_1+0xef4>
    13c8: f9400129     	ldr	x9, [x9]
    13cc: d63f0120     	blr	x9
    13d0: 35016b80     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    13d4: aa1903e0     	mov	x0, x25
    13d8: f9401801     	ldr	x1, [x0, #0x30]
    13dc: b9001816     	str	w22, [x0, #0x18]
    13e0: 14000031     	b	0x14a4 <___pl_fn_1+0x1398>
    13e4: aa0003f8     	mov	x24, x0
    13e8: aa1903e0     	mov	x0, x25
    13ec: f9403000     	ldr	x0, [x0, #0x60]
    13f0: aa1903e4     	mov	x4, x25
    13f4: f9400084     	ldr	x4, [x4]
    13f8: b20007e5     	mov	x5, #0x300000003        ; =12884901891
    13fc: 2a0103ee     	mov	w14, w1
    1400: 8b0e0c8f     	add	x15, x4, x14, lsl #3
    1404: f8215885     	str	x5, [x4, w1, uxtw #3]
    1408: 91000400     	add	x0, x0, #0x1
    140c: f90005e0     	str	x0, [x15, #0x8]
    1410: 92800004     	mov	x4, #-0x1               ; =-1
    1414: f90009e4     	str	x4, [x15, #0x10]
    1418: d2800004     	mov	x4, #0x0                ; =0
    141c: f9000de4     	str	x4, [x15, #0x18]
    1420: f90011e4     	str	x4, [x15, #0x20]
    1424: f90015e4     	str	x4, [x15, #0x28]
    1428: f90019e4     	str	x4, [x15, #0x30]
    142c: f9001de4     	str	x4, [x15, #0x38]
    1430: f90021e4     	str	x4, [x15, #0x40]
    1434: f90025e4     	str	x4, [x15, #0x48]
    1438: f90029e4     	str	x4, [x15, #0x50]
    143c: aa1903e4     	mov	x4, x25
    1440: f9003080     	str	x0, [x4, #0x60]
    1444: 91002c20     	add	x0, x1, #0xb
    1448: f9002880     	str	x0, [x4, #0x50]
    144c: aa1903e0     	mov	x0, x25
    1450: f9403400     	ldr	x0, [x0, #0x68]
    1454: d1002400     	sub	x0, x0, #0x9
    1458: aa1903e5     	mov	x5, x25
    145c: f90034a0     	str	x0, [x5, #0x68]
    1460: aa1903e0     	mov	x0, x25
    1464: f9403800     	ldr	x0, [x0, #0x70]
    1468: d1002400     	sub	x0, x0, #0x9
    146c: aa1903ea     	mov	x10, x25
    1470: f9003940     	str	x0, [x10, #0x70]
    1474: aa1903e0     	mov	x0, x25
    1478: f9404000     	ldr	x0, [x0, #0x80]
    147c: d2c00164     	mov	x4, #0xb00000000        ; =47244640256
    1480: aa0401c4     	orr	x4, x14, x4
    1484: d37cec45     	lsl	x5, x2, #4
    1488: 8b021006     	add	x6, x0, x2, lsl #4
    148c: f8256804     	str	x4, [x0, x5]
    1490: f90004c3     	str	x3, [x6, #0x8]
    1494: 91000440     	add	x0, x2, #0x1
    1498: aa1903e2     	mov	x2, x25
    149c: f9004440     	str	x0, [x2, #0x88]
    14a0: aa1903e0     	mov	x0, x25
    14a4: aa1903e0     	mov	x0, x25
    14a8: b9401816     	ldr	w22, [x0, #0x18]
    14ac: b9401c00     	ldr	w0, [x0, #0x1c]
    14b0: 110016c2     	add	w2, w22, #0x5
    14b4: 6b00005f     	cmp	w2, w0
    14b8: 54014568     	b.hi	0x3d64 <___pl_fn_1+0x3c58>
    14bc: aa1903e0     	mov	x0, x25
    14c0: f9401002     	ldr	x2, [x0, #0x20]
    14c4: 2a1603f7     	mov	w23, w22
    14c8: 8b170840     	add	x0, x2, x23, lsl #2
    14cc: aa1b03e3     	mov	x3, x27
    14d0: b8365843     	str	w3, [x2, w22, uxtw #2]
    14d4: aa1c03e5     	mov	x5, x28
    14d8: b9000405     	str	w5, [x0, #0x4]
    14dc: b9000814     	str	w20, [x0, #0x8]
    14e0: aa1803eb     	mov	x11, x24
    14e4: b9000c0b     	str	w11, [x0, #0xc]
    14e8: b9001001     	str	w1, [x0, #0x10]
    14ec: 110016c0     	add	w0, w22, #0x5
    14f0: aa1903e2     	mov	x2, x25
    14f4: b9001840     	str	w0, [x2, #0x18]
    14f8: aa1903e0     	mov	x0, x25
    14fc: b9401000     	ldr	w0, [x0, #0x10]
    1500: b9401442     	ldr	w2, [x2, #0x14]
    1504: 6b02001f     	cmp	w0, w2
    1508: 54014142     	b.hs	0x3d30 <___pl_fn_1+0x3c24>
    150c: d28000a3     	mov	x3, #0x5                ; =5
    1510: d2807d04     	mov	x4, #0x3e8              ; =1000
    1514: aa1803e2     	mov	x2, x24
    1518: aa1903e0     	mov	x0, x25
    151c: 94000000     	bl	0x151c <___pl_fn_1+0x1410>
    1520: aa1903e1     	mov	x1, x25
    1524: b9402c21     	ldr	w1, [x1, #0x2c]
    1528: 350160c1     	cbnz	w1, 0x4140 <___pl_fn_1+0x4034>
    152c: aa1903e1     	mov	x1, x25
    1530: b9001836     	str	w22, [x1, #0x18]
    1534: 34013e40     	cbz	w0, 0x3cfc <___pl_fn_1+0x3bf0>
    1538: aa1903e1     	mov	x1, x25
    153c: f9403c21     	ldr	x1, [x1, #0x78]
    1540: 3758de21     	tbnz	w1, #0xb, 0x3104 <___pl_fn_1+0x2ff8>
    1544: aa1903e1     	mov	x1, x25
    1548: f9403821     	ldr	x1, [x1, #0x70]
    154c: f100003f     	cmp	x1, #0x0
    1550: 5400dded     	b.le	0x310c <___pl_fn_1+0x3000>
    1554: aa1903e5     	mov	x5, x25
    1558: f94034a1     	ldr	x1, [x5, #0x68]
    155c: d2800122     	mov	x2, #0x9                ; =9
    1560: f100243f     	cmp	x1, #0x9
    1564: 5400dd8b     	b.lt	0x3114 <___pl_fn_1+0x3008>
    1568: aa1903eb     	mov	x11, x25
    156c: f9402961     	ldr	x1, [x11, #0x50]
    1570: aa1903ed     	mov	x13, x25
    1574: f9402da3     	ldr	x3, [x13, #0x58]
    1578: 91002c24     	add	x4, x1, #0xb
    157c: eb03009f     	cmp	x4, x3
    1580: 5400dce8     	b.hi	0x311c <___pl_fn_1+0x3010>
    1584: aa1903e3     	mov	x3, x25
    1588: f9404463     	ldr	x3, [x3, #0x88]
    158c: aa1903e4     	mov	x4, x25
    1590: f9404884     	ldr	x4, [x4, #0x90]
    1594: eb04007f     	cmp	x3, x4
    1598: 5400dc62     	b.hs	0x3124 <___pl_fn_1+0x3018>
    159c: aa1903e4     	mov	x4, x25
    15a0: b9401c84     	ldr	w4, [x4, #0x1c]
    15a4: 110012c5     	add	w5, w22, #0x4
    15a8: 6b0400bf     	cmp	w5, w4
    15ac: 54000309     	b.ls	0x160c <___pl_fn_1+0x1500>
    15b0: 140006df     	b	0x312c <___pl_fn_1+0x3020>
    15b4: aa1903e2     	mov	x2, x25
    15b8: f9401044     	ldr	x4, [x2, #0x20]
    15bc: 8b170883     	add	x3, x4, x23, lsl #2
    15c0: aa1b03e2     	mov	x2, x27
    15c4: b8365882     	str	w2, [x4, w22, uxtw #2]
    15c8: aa1c03e5     	mov	x5, x28
    15cc: b9000465     	str	w5, [x3, #0x4]
    15d0: b9000874     	str	w20, [x3, #0x8]
    15d4: b9000c60     	str	w0, [x3, #0xc]
    15d8: aa0003f7     	mov	x23, x0
    15dc: aa1903e0     	mov	x0, x25
    15e0: b9001801     	str	w1, [x0, #0x18]
    15e4: 52800741     	mov	w1, #0x3a               ; =58
    15e8: 52800002     	mov	w2, #0x0                ; =0
    15ec: 90000008     	adrp	x8, 0x1000 <___pl_fn_1+0xef4>
    15f0: f9400108     	ldr	x8, [x8]
    15f4: d63f0100     	blr	x8
    15f8: 35015a40     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    15fc: aa1903e0     	mov	x0, x25
    1600: f9401801     	ldr	x1, [x0, #0x30]
    1604: b9001816     	str	w22, [x0, #0x18]
    1608: 1400002f     	b	0x16c4 <___pl_fn_1+0x15b8>
    160c: aa0003f7     	mov	x23, x0
    1610: aa1903e0     	mov	x0, x25
    1614: f940300f     	ldr	x15, [x0, #0x60]
    1618: f9400000     	ldr	x0, [x0]
    161c: b20007e4     	mov	x4, #0x300000003        ; =12884901891
    1620: 2a0103ed     	mov	w13, w1
    1624: 8b0d0c0e     	add	x14, x0, x13, lsl #3
    1628: f8215804     	str	x4, [x0, w1, uxtw #3]
    162c: 910005ef     	add	x15, x15, #0x1
    1630: f90005cf     	str	x15, [x14, #0x8]
    1634: 92800000     	mov	x0, #-0x1               ; =-1
    1638: f90009c0     	str	x0, [x14, #0x10]
    163c: d2800000     	mov	x0, #0x0                ; =0
    1640: f9000dc0     	str	x0, [x14, #0x18]
    1644: f90011c0     	str	x0, [x14, #0x20]
    1648: f90015c0     	str	x0, [x14, #0x28]
    164c: f90019c0     	str	x0, [x14, #0x30]
    1650: f9001dc0     	str	x0, [x14, #0x38]
    1654: f90021c0     	str	x0, [x14, #0x40]
    1658: f90025c0     	str	x0, [x14, #0x48]
    165c: f90029c0     	str	x0, [x14, #0x50]
    1660: aa1903e0     	mov	x0, x25
    1664: f900300f     	str	x15, [x0, #0x60]
    1668: 91002c20     	add	x0, x1, #0xb
    166c: aa1903e4     	mov	x4, x25
    1670: f9002880     	str	x0, [x4, #0x50]
    1674: aa1903e0     	mov	x0, x25
    1678: f9403400     	ldr	x0, [x0, #0x68]
    167c: d1002400     	sub	x0, x0, #0x9
    1680: f9003480     	str	x0, [x4, #0x68]
    1684: aa1903e0     	mov	x0, x25
    1688: f9403800     	ldr	x0, [x0, #0x70]
    168c: d1002400     	sub	x0, x0, #0x9
    1690: f9003880     	str	x0, [x4, #0x70]
    1694: aa1903e0     	mov	x0, x25
    1698: f9404000     	ldr	x0, [x0, #0x80]
    169c: d2c00164     	mov	x4, #0xb00000000        ; =47244640256
    16a0: aa0401a4     	orr	x4, x13, x4
    16a4: d37cec65     	lsl	x5, x3, #4
    16a8: 8b031006     	add	x6, x0, x3, lsl #4
    16ac: f8256804     	str	x4, [x0, x5]
    16b0: f90004c2     	str	x2, [x6, #0x8]
    16b4: 91000460     	add	x0, x3, #0x1
    16b8: aa1903e2     	mov	x2, x25
    16bc: f9004440     	str	x0, [x2, #0x88]
    16c0: aa1903e0     	mov	x0, x25
    16c4: aa1903e0     	mov	x0, x25
    16c8: b9401816     	ldr	w22, [x0, #0x18]
    16cc: b9401c00     	ldr	w0, [x0, #0x1c]
    16d0: 110016c2     	add	w2, w22, #0x5
    16d4: 6b00005f     	cmp	w2, w0
    16d8: 54012f88     	b.hi	0x3cc8 <___pl_fn_1+0x3bbc>
    16dc: aa1903e0     	mov	x0, x25
    16e0: f9401002     	ldr	x2, [x0, #0x20]
    16e4: 2a1603f8     	mov	w24, w22
    16e8: 8b180840     	add	x0, x2, x24, lsl #2
    16ec: aa1b03e3     	mov	x3, x27
    16f0: b8365843     	str	w3, [x2, w22, uxtw #2]
    16f4: aa1c03e5     	mov	x5, x28
    16f8: b9000405     	str	w5, [x0, #0x4]
    16fc: b9000814     	str	w20, [x0, #0x8]
    1700: aa1703e2     	mov	x2, x23
    1704: b9000c02     	str	w2, [x0, #0xc]
    1708: b9001001     	str	w1, [x0, #0x10]
    170c: 110016c0     	add	w0, w22, #0x5
    1710: aa1903e2     	mov	x2, x25
    1714: b9001840     	str	w0, [x2, #0x18]
    1718: aa1903e0     	mov	x0, x25
    171c: b9401000     	ldr	w0, [x0, #0x10]
    1720: aa1903e5     	mov	x5, x25
    1724: b94014a2     	ldr	w2, [x5, #0x14]
    1728: 6b02001f     	cmp	w0, w2
    172c: 54012b42     	b.hs	0x3c94 <___pl_fn_1+0x3b88>
    1730: d28000a3     	mov	x3, #0x5                ; =5
    1734: d2807d04     	mov	x4, #0x3e8              ; =1000
    1738: aa1703e2     	mov	x2, x23
    173c: aa1903e0     	mov	x0, x25
    1740: 94000000     	bl	0x1740 <___pl_fn_1+0x1634>
    1744: aa1903ec     	mov	x12, x25
    1748: b9402d81     	ldr	w1, [x12, #0x2c]
    174c: 35014fa1     	cbnz	w1, 0x4140 <___pl_fn_1+0x4034>
    1750: aa1903e1     	mov	x1, x25
    1754: b9001836     	str	w22, [x1, #0x18]
    1758: 34012840     	cbz	w0, 0x3c60 <___pl_fn_1+0x3b54>
    175c: aa1903e1     	mov	x1, x25
    1760: f9403c21     	ldr	x1, [x1, #0x78]
    1764: 3768d0c1     	tbnz	w1, #0xd, 0x317c <___pl_fn_1+0x3070>
    1768: aa1903e1     	mov	x1, x25
    176c: f9403821     	ldr	x1, [x1, #0x70]
    1770: f100003f     	cmp	x1, #0x0
    1774: 5400d08d     	b.le	0x3184 <___pl_fn_1+0x3078>
    1778: aa1903e1     	mov	x1, x25
    177c: f9403421     	ldr	x1, [x1, #0x68]
    1780: d2800162     	mov	x2, #0xb                ; =11
    1784: f1002c3f     	cmp	x1, #0xb
    1788: 5400d02b     	b.lt	0x318c <___pl_fn_1+0x3080>
    178c: aa1903e1     	mov	x1, x25
    1790: f9402837     	ldr	x23, [x1, #0x50]
    1794: f9402c21     	ldr	x1, [x1, #0x58]
    1798: 910036e3     	add	x3, x23, #0xd
    179c: eb01007f     	cmp	x3, x1
    17a0: 5400cfa8     	b.hi	0x3194 <___pl_fn_1+0x3088>
    17a4: aa1903e1     	mov	x1, x25
    17a8: f9404421     	ldr	x1, [x1, #0x88]
    17ac: aa1903e3     	mov	x3, x25
    17b0: f9404863     	ldr	x3, [x3, #0x90]
    17b4: eb03003f     	cmp	x1, x3
    17b8: 5400cf22     	b.hs	0x319c <___pl_fn_1+0x3090>
    17bc: aa1903e3     	mov	x3, x25
    17c0: b9401c63     	ldr	w3, [x3, #0x1c]
    17c4: 110012c4     	add	w4, w22, #0x4
    17c8: 6b03009f     	cmp	w4, w3
    17cc: 54000309     	b.ls	0x182c <___pl_fn_1+0x1720>
    17d0: 14000675     	b	0x31a4 <___pl_fn_1+0x3098>
    17d4: aa1903e2     	mov	x2, x25
    17d8: f9401043     	ldr	x3, [x2, #0x20]
    17dc: 8b180862     	add	x2, x3, x24, lsl #2
    17e0: aa1b03eb     	mov	x11, x27
    17e4: b836586b     	str	w11, [x3, w22, uxtw #2]
    17e8: aa1c03e5     	mov	x5, x28
    17ec: b9000445     	str	w5, [x2, #0x4]
    17f0: b9000854     	str	w20, [x2, #0x8]
    17f4: b9000c40     	str	w0, [x2, #0xc]
    17f8: aa0003f8     	mov	x24, x0
    17fc: aa1903e0     	mov	x0, x25
    1800: b9001801     	str	w1, [x0, #0x18]
    1804: 528007e1     	mov	w1, #0x3f               ; =63
    1808: 52800082     	mov	w2, #0x4                ; =4
    180c: 90000007     	adrp	x7, 0x1000 <___pl_fn_1+0xef4>
    1810: f94000e7     	ldr	x7, [x7]
    1814: d63f00e0     	blr	x7
    1818: 35014940     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    181c: aa1903e0     	mov	x0, x25
    1820: f9401817     	ldr	x23, [x0, #0x30]
    1824: b9001816     	str	w22, [x0, #0x18]
    1828: 14000031     	b	0x18ec <___pl_fn_1+0x17e0>
    182c: aa0003f8     	mov	x24, x0
    1830: aa1903e0     	mov	x0, x25
    1834: f940300e     	ldr	x14, [x0, #0x60]
    1838: f940000f     	ldr	x15, [x0]
    183c: d28000e0     	mov	x0, #0x7                ; =7
    1840: f2c00060     	movk	x0, #0x3, lsl #32
    1844: 2a1703ec     	mov	w12, w23
    1848: 8b0c0ded     	add	x13, x15, x12, lsl #3
    184c: f83759e0     	str	x0, [x15, w23, uxtw #3]
    1850: 910005ce     	add	x14, x14, #0x1
    1854: f90005ae     	str	x14, [x13, #0x8]
    1858: 9280000f     	mov	x15, #-0x1              ; =-1
    185c: f90009af     	str	x15, [x13, #0x10]
    1860: d280000f     	mov	x15, #0x0               ; =0
    1864: f9000daf     	str	x15, [x13, #0x18]
    1868: f90011af     	str	x15, [x13, #0x20]
    186c: f90015af     	str	x15, [x13, #0x28]
    1870: f90019af     	str	x15, [x13, #0x30]
    1874: f9001db5     	str	x21, [x13, #0x38]
    1878: f90021b5     	str	x21, [x13, #0x40]
    187c: f90025b5     	str	x21, [x13, #0x48]
    1880: f90029af     	str	x15, [x13, #0x50]
    1884: f9002daf     	str	x15, [x13, #0x58]
    1888: f90031af     	str	x15, [x13, #0x60]
    188c: aa1903e0     	mov	x0, x25
    1890: f900300e     	str	x14, [x0, #0x60]
    1894: 910036e0     	add	x0, x23, #0xd
    1898: aa1903e3     	mov	x3, x25
    189c: f9002860     	str	x0, [x3, #0x50]
    18a0: aa1903e0     	mov	x0, x25
    18a4: f9403400     	ldr	x0, [x0, #0x68]
    18a8: d1002c00     	sub	x0, x0, #0xb
    18ac: f9003460     	str	x0, [x3, #0x68]
    18b0: aa1903e0     	mov	x0, x25
    18b4: f9403800     	ldr	x0, [x0, #0x70]
    18b8: d1002c00     	sub	x0, x0, #0xb
    18bc: f9003860     	str	x0, [x3, #0x70]
    18c0: aa1903e0     	mov	x0, x25
    18c4: f9404000     	ldr	x0, [x0, #0x80]
    18c8: d2c001a3     	mov	x3, #0xd00000000        ; =55834574848
    18cc: aa030183     	orr	x3, x12, x3
    18d0: d37cec24     	lsl	x4, x1, #4
    18d4: 8b011005     	add	x5, x0, x1, lsl #4
    18d8: f8246803     	str	x3, [x0, x4]
    18dc: f90004a2     	str	x2, [x5, #0x8]
    18e0: 91000420     	add	x0, x1, #0x1
    18e4: aa1903e7     	mov	x7, x25
    18e8: f90044e0     	str	x0, [x7, #0x88]
    18ec: 34011a17     	cbz	w23, 0x3c2c <___pl_fn_1+0x3b20>
    18f0: 3400c817     	cbz	w23, 0x31f0 <___pl_fn_1+0x30e4>
    18f4: aa1903e0     	mov	x0, x25
    18f8: aa1703f6     	mov	x22, x23
    18fc: f9400001     	ldr	x1, [x0]
    1900: 2a1603e0     	mov	w0, w22
    1904: 8b000c20     	add	x0, x1, x0, lsl #3
    1908: f8765822     	ldr	x2, [x1, w22, uxtw #3]
    190c: aa1c03e5     	mov	x5, x28
    1910: 2a0503e1     	mov	w1, w5
    1914: d360fc42     	lsr	x2, x2, #32
    1918: 92403c42     	and	x2, x2, #0xffff
    191c: 91002042     	add	x2, x2, #0x8
    1920: f8227801     	str	x1, [x0, x2, lsl #3]
    1924: 350000b6     	cbnz	w22, 0x1938 <___pl_fn_1+0x182c>
    1928: 14000641     	b	0x322c <___pl_fn_1+0x3120>
    192c: aa1903e0     	mov	x0, x25
    1930: aa1603e1     	mov	x1, x22
    1934: 1400000e     	b	0x196c <___pl_fn_1+0x1860>
    1938: aa1903e0     	mov	x0, x25
    193c: f9400002     	ldr	x2, [x0]
    1940: aa1603e1     	mov	x1, x22
    1944: 2a0103e0     	mov	w0, w1
    1948: 8b000c40     	add	x0, x2, x0, lsl #3
    194c: f8615843     	ldr	x3, [x2, w1, uxtw #3]
    1950: aa1c03e5     	mov	x5, x28
    1954: 2a0503e2     	mov	w2, w5
    1958: d360fc63     	lsr	x3, x3, #32
    195c: 92403c63     	and	x3, x3, #0xffff
    1960: 91002463     	add	x3, x3, #0x9
    1964: f8237802     	str	x2, [x0, x3, lsl #3]
    1968: aa1903e0     	mov	x0, x25
    196c: aa1903e0     	mov	x0, x25
    1970: b9401816     	ldr	w22, [x0, #0x18]
    1974: b9401c00     	ldr	w0, [x0, #0x1c]
    1978: 110016c2     	add	w2, w22, #0x5
    197c: 6b00005f     	cmp	w2, w0
    1980: 540113c8     	b.hi	0x3bf8 <___pl_fn_1+0x3aec>
    1984: aa1903e0     	mov	x0, x25
    1988: f9401002     	ldr	x2, [x0, #0x20]
    198c: 2a1603f7     	mov	w23, w22
    1990: 8b170840     	add	x0, x2, x23, lsl #2
    1994: aa1b03e3     	mov	x3, x27
    1998: b8365843     	str	w3, [x2, w22, uxtw #2]
    199c: aa1c03e5     	mov	x5, x28
    19a0: b9000405     	str	w5, [x0, #0x4]
    19a4: b9000814     	str	w20, [x0, #0x8]
    19a8: aa1803ef     	mov	x15, x24
    19ac: b9000c0f     	str	w15, [x0, #0xc]
    19b0: b9001001     	str	w1, [x0, #0x10]
    19b4: 110016c0     	add	w0, w22, #0x5
    19b8: aa1903eb     	mov	x11, x25
    19bc: b9001960     	str	w0, [x11, #0x18]
    19c0: aa1903e0     	mov	x0, x25
    19c4: b9401000     	ldr	w0, [x0, #0x10]
    19c8: aa1903ef     	mov	x15, x25
    19cc: b94015e2     	ldr	w2, [x15, #0x14]
    19d0: 6b02001f     	cmp	w0, w2
    19d4: 54010f82     	b.hs	0x3bc4 <___pl_fn_1+0x3ab8>
    19d8: d2800063     	mov	x3, #0x3                ; =3
    19dc: d280fa04     	mov	x4, #0x7d0              ; =2000
    19e0: 52800027     	mov	w7, #0x1                ; =1
    19e4: aa1803e5     	mov	x5, x24
    19e8: aa1903e0     	mov	x0, x25
    19ec: aa1b03e2     	mov	x2, x27
    19f0: aa0703e6     	mov	x6, x7
    19f4: 94000000     	bl	0x19f4 <___pl_fn_1+0x18e8>
    19f8: aa1903e0     	mov	x0, x25
    19fc: b9402c00     	ldr	w0, [x0, #0x2c]
    1a00: 35013a00     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    1a04: aa1903e0     	mov	x0, x25
    1a08: b9001816     	str	w22, [x0, #0x18]
    1a0c: f9403c01     	ldr	x1, [x0, #0x78]
    1a10: 3758c2a1     	tbnz	w1, #0xb, 0x3264 <___pl_fn_1+0x3158>
    1a14: aa1903e0     	mov	x0, x25
    1a18: f9403803     	ldr	x3, [x0, #0x70]
    1a1c: f100007f     	cmp	x3, #0x0
    1a20: 5400c26d     	b.le	0x326c <___pl_fn_1+0x3160>
    1a24: aa1903e0     	mov	x0, x25
    1a28: f9403407     	ldr	x7, [x0, #0x68]
    1a2c: d2800126     	mov	x6, #0x9                ; =9
    1a30: f10024ff     	cmp	x7, #0x9
    1a34: 5400c20b     	b.lt	0x3274 <___pl_fn_1+0x3168>
    1a38: aa1903e0     	mov	x0, x25
    1a3c: f9402801     	ldr	x1, [x0, #0x50]
    1a40: f9402c09     	ldr	x9, [x0, #0x58]
    1a44: 91002c2a     	add	x10, x1, #0xb
    1a48: eb09015f     	cmp	x10, x9
    1a4c: 5400c188     	b.hi	0x327c <___pl_fn_1+0x3170>
    1a50: aa1903e0     	mov	x0, x25
    1a54: f940440c     	ldr	x12, [x0, #0x88]
    1a58: f940480d     	ldr	x13, [x0, #0x90]
    1a5c: eb0d019f     	cmp	x12, x13
    1a60: 5400c122     	b.hs	0x3284 <___pl_fn_1+0x3178>
    1a64: aa1903e0     	mov	x0, x25
    1a68: b9401c0f     	ldr	w15, [x0, #0x1c]
    1a6c: 11000ec0     	add	w0, w22, #0x3
    1a70: 6b0f001f     	cmp	w0, w15
    1a74: 540002e9     	b.ls	0x1ad0 <___pl_fn_1+0x19c4>
    1a78: 14000605     	b	0x328c <___pl_fn_1+0x3180>
    1a7c: aa1903e7     	mov	x7, x25
    1a80: f94010e2     	ldr	x2, [x7, #0x20]
    1a84: 8b170841     	add	x1, x2, x23, lsl #2
    1a88: aa1b03e3     	mov	x3, x27
    1a8c: b8365843     	str	w3, [x2, w22, uxtw #2]
    1a90: aa1c03e5     	mov	x5, x28
    1a94: b9000425     	str	w5, [x1, #0x4]
    1a98: b9000834     	str	w20, [x1, #0x8]
    1a9c: aa1903ed     	mov	x13, x25
    1aa0: b90019a0     	str	w0, [x13, #0x18]
    1aa4: 528008c1     	mov	w1, #0x46               ; =70
    1aa8: 52800002     	mov	w2, #0x0                ; =0
    1aac: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xef4>
    1ab0: f9400063     	ldr	x3, [x3]
    1ab4: aa1903e0     	mov	x0, x25
    1ab8: d63f0060     	blr	x3
    1abc: 35013420     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    1ac0: aa1903e0     	mov	x0, x25
    1ac4: f9401801     	ldr	x1, [x0, #0x30]
    1ac8: b9001816     	str	w22, [x0, #0x18]
    1acc: 1400002e     	b	0x1b84 <___pl_fn_1+0x1a78>
    1ad0: aa1903e0     	mov	x0, x25
    1ad4: f9403003     	ldr	x3, [x0, #0x60]
    1ad8: f9400004     	ldr	x4, [x0]
    1adc: b20007e5     	mov	x5, #0x300000003        ; =12884901891
    1ae0: 2a0103e0     	mov	w0, w1
    1ae4: 8b000c82     	add	x2, x4, x0, lsl #3
    1ae8: f8215885     	str	x5, [x4, w1, uxtw #3]
    1aec: 91000463     	add	x3, x3, #0x1
    1af0: f9000443     	str	x3, [x2, #0x8]
    1af4: 92800004     	mov	x4, #-0x1               ; =-1
    1af8: f9000844     	str	x4, [x2, #0x10]
    1afc: d2800004     	mov	x4, #0x0                ; =0
    1b00: f9000c44     	str	x4, [x2, #0x18]
    1b04: f9001044     	str	x4, [x2, #0x20]
    1b08: f9001444     	str	x4, [x2, #0x28]
    1b0c: f9001844     	str	x4, [x2, #0x30]
    1b10: f9001c44     	str	x4, [x2, #0x38]
    1b14: f9002044     	str	x4, [x2, #0x40]
    1b18: f9002444     	str	x4, [x2, #0x48]
    1b1c: f9002844     	str	x4, [x2, #0x50]
    1b20: aa1903e2     	mov	x2, x25
    1b24: f9003043     	str	x3, [x2, #0x60]
    1b28: 91002c22     	add	x2, x1, #0xb
    1b2c: aa1903e3     	mov	x3, x25
    1b30: f9002862     	str	x2, [x3, #0x50]
    1b34: aa1903e2     	mov	x2, x25
    1b38: f9403442     	ldr	x2, [x2, #0x68]
    1b3c: d1002442     	sub	x2, x2, #0x9
    1b40: f9003462     	str	x2, [x3, #0x68]
    1b44: aa1903e2     	mov	x2, x25
    1b48: f9403842     	ldr	x2, [x2, #0x70]
    1b4c: d1002442     	sub	x2, x2, #0x9
    1b50: f9003862     	str	x2, [x3, #0x70]
    1b54: aa1903e4     	mov	x4, x25
    1b58: f9404082     	ldr	x2, [x4, #0x80]
    1b5c: d2c00163     	mov	x3, #0xb00000000        ; =47244640256
    1b60: aa030000     	orr	x0, x0, x3
    1b64: d37ced83     	lsl	x3, x12, #4
    1b68: 8b0c1044     	add	x4, x2, x12, lsl #4
    1b6c: f8236840     	str	x0, [x2, x3]
    1b70: f9000486     	str	x6, [x4, #0x8]
    1b74: 91000580     	add	x0, x12, #0x1
    1b78: aa1903ed     	mov	x13, x25
    1b7c: f90045a0     	str	x0, [x13, #0x88]
    1b80: aa1903e0     	mov	x0, x25
    1b84: aa1903e0     	mov	x0, x25
    1b88: b9401816     	ldr	w22, [x0, #0x18]
    1b8c: b9401c00     	ldr	w0, [x0, #0x1c]
    1b90: 110012d7     	add	w23, w22, #0x4
    1b94: 6b0002ff     	cmp	w23, w0
    1b98: 5400ffc8     	b.hi	0x3b90 <___pl_fn_1+0x3a84>
    1b9c: aa1903e0     	mov	x0, x25
    1ba0: f9401002     	ldr	x2, [x0, #0x20]
    1ba4: 2a1603f8     	mov	w24, w22
    1ba8: 8b180840     	add	x0, x2, x24, lsl #2
    1bac: aa1b03e3     	mov	x3, x27
    1bb0: b8365843     	str	w3, [x2, w22, uxtw #2]
    1bb4: aa1c03e5     	mov	x5, x28
    1bb8: b9000405     	str	w5, [x0, #0x4]
    1bbc: b9000814     	str	w20, [x0, #0x8]
    1bc0: b9000c01     	str	w1, [x0, #0xc]
    1bc4: aa1903e0     	mov	x0, x25
    1bc8: b9001817     	str	w23, [x0, #0x18]
    1bcc: b9401000     	ldr	w0, [x0, #0x10]
    1bd0: aa1903e2     	mov	x2, x25
    1bd4: b9401442     	ldr	w2, [x2, #0x14]
    1bd8: 6b02001f     	cmp	w0, w2
    1bdc: 5400fc02     	b.hs	0x3b5c <___pl_fn_1+0x3a50>
    1be0: d28000c3     	mov	x3, #0x6                ; =6
    1be4: d2807d04     	mov	x4, #0x3e8              ; =1000
    1be8: aa1903e0     	mov	x0, x25
    1bec: aa1c03e2     	mov	x2, x28
    1bf0: 94000000     	bl	0x1bf0 <___pl_fn_1+0x1ae4>
    1bf4: aa1903e1     	mov	x1, x25
    1bf8: b9402c21     	ldr	w1, [x1, #0x2c]
    1bfc: 35012a21     	cbnz	w1, 0x4140 <___pl_fn_1+0x4034>
    1c00: aa1903e1     	mov	x1, x25
    1c04: b9001836     	str	w22, [x1, #0x18]
    1c08: 3400f900     	cbz	w0, 0x3b28 <___pl_fn_1+0x3a1c>
    1c0c: aa1903e1     	mov	x1, x25
    1c10: f9403c21     	ldr	x1, [x1, #0x78]
    1c14: 3758b641     	tbnz	w1, #0xb, 0x32dc <___pl_fn_1+0x31d0>
    1c18: aa1903e1     	mov	x1, x25
    1c1c: f9403821     	ldr	x1, [x1, #0x70]
    1c20: f100003f     	cmp	x1, #0x0
    1c24: 5400b60d     	b.le	0x32e4 <___pl_fn_1+0x31d8>
    1c28: aa1903e1     	mov	x1, x25
    1c2c: f9403424     	ldr	x4, [x1, #0x68]
    1c30: d2800123     	mov	x3, #0x9                ; =9
    1c34: f100249f     	cmp	x4, #0x9
    1c38: 5400b5ab     	b.lt	0x32ec <___pl_fn_1+0x31e0>
    1c3c: aa1903e1     	mov	x1, x25
    1c40: f9402821     	ldr	x1, [x1, #0x50]
    1c44: aa1903e4     	mov	x4, x25
    1c48: f9402c86     	ldr	x6, [x4, #0x58]
    1c4c: 91002c27     	add	x7, x1, #0xb
    1c50: eb0600ff     	cmp	x7, x6
    1c54: 5400b508     	b.hi	0x32f4 <___pl_fn_1+0x31e8>
    1c58: aa1903e9     	mov	x9, x25
    1c5c: f9404529     	ldr	x9, [x9, #0x88]
    1c60: aa1903eb     	mov	x11, x25
    1c64: f940496a     	ldr	x10, [x11, #0x90]
    1c68: eb0a013f     	cmp	x9, x10
    1c6c: 5400b482     	b.hs	0x32fc <___pl_fn_1+0x31f0>
    1c70: aa1903e2     	mov	x2, x25
    1c74: b9401c4c     	ldr	w12, [x2, #0x1c]
    1c78: 6b0c02ff     	cmp	w23, w12
    1c7c: 54000309     	b.ls	0x1cdc <___pl_fn_1+0x1bd0>
    1c80: 140005a1     	b	0x3304 <___pl_fn_1+0x31f8>
    1c84: aa1903e1     	mov	x1, x25
    1c88: f9401022     	ldr	x2, [x1, #0x20]
    1c8c: 8b180841     	add	x1, x2, x24, lsl #2
    1c90: aa1b03e3     	mov	x3, x27
    1c94: b8365843     	str	w3, [x2, w22, uxtw #2]
    1c98: aa1c03e5     	mov	x5, x28
    1c9c: b9000425     	str	w5, [x1, #0x4]
    1ca0: b9000834     	str	w20, [x1, #0x8]
    1ca4: b9000c20     	str	w0, [x1, #0xc]
    1ca8: aa0003f8     	mov	x24, x0
    1cac: aa1903e0     	mov	x0, x25
    1cb0: b9001817     	str	w23, [x0, #0x18]
    1cb4: 52800961     	mov	w1, #0x4b               ; =75
    1cb8: 52800002     	mov	w2, #0x0                ; =0
    1cbc: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xef4>
    1cc0: f9400063     	ldr	x3, [x3]
    1cc4: d63f0060     	blr	x3
    1cc8: 350123c0     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    1ccc: aa1903e0     	mov	x0, x25
    1cd0: f9401801     	ldr	x1, [x0, #0x30]
    1cd4: b9001816     	str	w22, [x0, #0x18]
    1cd8: 14000030     	b	0x1d98 <___pl_fn_1+0x1c8c>
    1cdc: aa0003f8     	mov	x24, x0
    1ce0: aa1903e0     	mov	x0, x25
    1ce4: f9403004     	ldr	x4, [x0, #0x60]
    1ce8: f9400005     	ldr	x5, [x0]
    1cec: b20007e6     	mov	x6, #0x300000003        ; =12884901891
    1cf0: 2a0103e0     	mov	w0, w1
    1cf4: 8b000ca2     	add	x2, x5, x0, lsl #3
    1cf8: f82158a6     	str	x6, [x5, w1, uxtw #3]
    1cfc: 91000484     	add	x4, x4, #0x1
    1d00: f9000444     	str	x4, [x2, #0x8]
    1d04: 92800005     	mov	x5, #-0x1               ; =-1
    1d08: f9000845     	str	x5, [x2, #0x10]
    1d0c: d2800005     	mov	x5, #0x0                ; =0
    1d10: f9000c45     	str	x5, [x2, #0x18]
    1d14: f9001045     	str	x5, [x2, #0x20]
    1d18: f9001445     	str	x5, [x2, #0x28]
    1d1c: f9001845     	str	x5, [x2, #0x30]
    1d20: f9001c45     	str	x5, [x2, #0x38]
    1d24: f9002045     	str	x5, [x2, #0x40]
    1d28: f9002445     	str	x5, [x2, #0x48]
    1d2c: f9002845     	str	x5, [x2, #0x50]
    1d30: aa1903e8     	mov	x8, x25
    1d34: f9003104     	str	x4, [x8, #0x60]
    1d38: 91002c22     	add	x2, x1, #0xb
    1d3c: aa1903eb     	mov	x11, x25
    1d40: f9002962     	str	x2, [x11, #0x50]
    1d44: aa1903ed     	mov	x13, x25
    1d48: f94035a2     	ldr	x2, [x13, #0x68]
    1d4c: d1002442     	sub	x2, x2, #0x9
    1d50: aa1903e4     	mov	x4, x25
    1d54: f9003482     	str	x2, [x4, #0x68]
    1d58: aa1903e2     	mov	x2, x25
    1d5c: f9403842     	ldr	x2, [x2, #0x70]
    1d60: d1002442     	sub	x2, x2, #0x9
    1d64: f9003882     	str	x2, [x4, #0x70]
    1d68: aa1903e2     	mov	x2, x25
    1d6c: f9404042     	ldr	x2, [x2, #0x80]
    1d70: d2c00164     	mov	x4, #0xb00000000        ; =47244640256
    1d74: aa040000     	orr	x0, x0, x4
    1d78: d37ced24     	lsl	x4, x9, #4
    1d7c: 8b091045     	add	x5, x2, x9, lsl #4
    1d80: f8246840     	str	x0, [x2, x4]
    1d84: f90004a3     	str	x3, [x5, #0x8]
    1d88: 91000520     	add	x0, x9, #0x1
    1d8c: aa1903e2     	mov	x2, x25
    1d90: f9004440     	str	x0, [x2, #0x88]
    1d94: aa1903e0     	mov	x0, x25
    1d98: aa1903e0     	mov	x0, x25
    1d9c: b9401816     	ldr	w22, [x0, #0x18]
    1da0: b9401c00     	ldr	w0, [x0, #0x1c]
    1da4: 110016c2     	add	w2, w22, #0x5
    1da8: 6b00005f     	cmp	w2, w0
    1dac: 5400ea48     	b.hi	0x3af4 <___pl_fn_1+0x39e8>
    1db0: aa1903e0     	mov	x0, x25
    1db4: f9401002     	ldr	x2, [x0, #0x20]
    1db8: 2a1603f7     	mov	w23, w22
    1dbc: 8b170840     	add	x0, x2, x23, lsl #2
    1dc0: aa1b03e3     	mov	x3, x27
    1dc4: b8365843     	str	w3, [x2, w22, uxtw #2]
    1dc8: aa1c03e5     	mov	x5, x28
    1dcc: b9000405     	str	w5, [x0, #0x4]
    1dd0: b9000814     	str	w20, [x0, #0x8]
    1dd4: aa1803e2     	mov	x2, x24
    1dd8: b9000c02     	str	w2, [x0, #0xc]
    1ddc: b9001001     	str	w1, [x0, #0x10]
    1de0: 110016c0     	add	w0, w22, #0x5
    1de4: aa1903e2     	mov	x2, x25
    1de8: b9001840     	str	w0, [x2, #0x18]
    1dec: aa1903e0     	mov	x0, x25
    1df0: b9401000     	ldr	w0, [x0, #0x10]
    1df4: b9401442     	ldr	w2, [x2, #0x14]
    1df8: 6b02001f     	cmp	w0, w2
    1dfc: 5400e622     	b.hs	0x3ac0 <___pl_fn_1+0x39b4>
    1e00: d28000c3     	mov	x3, #0x6                ; =6
    1e04: d2807d04     	mov	x4, #0x3e8              ; =1000
    1e08: aa1803e2     	mov	x2, x24
    1e0c: aa1903e0     	mov	x0, x25
    1e10: 94000000     	bl	0x1e10 <___pl_fn_1+0x1d04>
    1e14: aa1903e1     	mov	x1, x25
    1e18: b9402c21     	ldr	w1, [x1, #0x2c]
    1e1c: 35011921     	cbnz	w1, 0x4140 <___pl_fn_1+0x4034>
    1e20: aa1903e4     	mov	x4, x25
    1e24: b9001896     	str	w22, [x4, #0x18]
    1e28: 3400e320     	cbz	w0, 0x3a8c <___pl_fn_1+0x3980>
    1e2c: aa1903e7     	mov	x7, x25
    1e30: f9403ce1     	ldr	x1, [x7, #0x78]
    1e34: 3758a8e1     	tbnz	w1, #0xb, 0x3350 <___pl_fn_1+0x3244>
    1e38: aa1903eb     	mov	x11, x25
    1e3c: f9403961     	ldr	x1, [x11, #0x70]
    1e40: f100003f     	cmp	x1, #0x0
    1e44: 5400a8ad     	b.le	0x3358 <___pl_fn_1+0x324c>
    1e48: aa1903e1     	mov	x1, x25
    1e4c: f9403423     	ldr	x3, [x1, #0x68]
    1e50: d2800122     	mov	x2, #0x9                ; =9
    1e54: f100247f     	cmp	x3, #0x9
    1e58: 5400a84b     	b.lt	0x3360 <___pl_fn_1+0x3254>
    1e5c: aa1903e1     	mov	x1, x25
    1e60: f9402821     	ldr	x1, [x1, #0x50]
    1e64: aa1903e3     	mov	x3, x25
    1e68: f9402c65     	ldr	x5, [x3, #0x58]
    1e6c: 91002c26     	add	x6, x1, #0xb
    1e70: eb0500df     	cmp	x6, x5
    1e74: 5400a7a8     	b.hi	0x3368 <___pl_fn_1+0x325c>
    1e78: aa1903e3     	mov	x3, x25
    1e7c: f9404468     	ldr	x8, [x3, #0x88]
    1e80: f9404869     	ldr	x9, [x3, #0x90]
    1e84: eb09011f     	cmp	x8, x9
    1e88: 5400a742     	b.hs	0x3370 <___pl_fn_1+0x3264>
    1e8c: aa1903e3     	mov	x3, x25
    1e90: b9401c6b     	ldr	w11, [x3, #0x1c]
    1e94: 110012cc     	add	w12, w22, #0x4
    1e98: 6b0b019f     	cmp	w12, w11
    1e9c: 54000309     	b.ls	0x1efc <___pl_fn_1+0x1df0>
    1ea0: 14000536     	b	0x3378 <___pl_fn_1+0x326c>
    1ea4: aa1903e1     	mov	x1, x25
    1ea8: f9401022     	ldr	x2, [x1, #0x20]
    1eac: 8b170841     	add	x1, x2, x23, lsl #2
    1eb0: aa1b03e3     	mov	x3, x27
    1eb4: b8365843     	str	w3, [x2, w22, uxtw #2]
    1eb8: aa1c03e5     	mov	x5, x28
    1ebc: b9000425     	str	w5, [x1, #0x4]
    1ec0: b9000834     	str	w20, [x1, #0x8]
    1ec4: b9000c20     	str	w0, [x1, #0xc]
    1ec8: aa0003f7     	mov	x23, x0
    1ecc: aa1903e0     	mov	x0, x25
    1ed0: b900180e     	str	w14, [x0, #0x18]
    1ed4: 52800a01     	mov	w1, #0x50               ; =80
    1ed8: 52800002     	mov	w2, #0x0                ; =0
    1edc: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xef4>
    1ee0: f9400063     	ldr	x3, [x3]
    1ee4: d63f0060     	blr	x3
    1ee8: 350112c0     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    1eec: aa1903e0     	mov	x0, x25
    1ef0: f9401801     	ldr	x1, [x0, #0x30]
    1ef4: b9001816     	str	w22, [x0, #0x18]
    1ef8: 1400002f     	b	0x1fb4 <___pl_fn_1+0x1ea8>
    1efc: aa0003f7     	mov	x23, x0
    1f00: aa1903e0     	mov	x0, x25
    1f04: f9403004     	ldr	x4, [x0, #0x60]
    1f08: f9400005     	ldr	x5, [x0]
    1f0c: b20007e6     	mov	x6, #0x300000003        ; =12884901891
    1f10: 2a0103e0     	mov	w0, w1
    1f14: 8b000ca3     	add	x3, x5, x0, lsl #3
    1f18: f82158a6     	str	x6, [x5, w1, uxtw #3]
    1f1c: 91000484     	add	x4, x4, #0x1
    1f20: f9000464     	str	x4, [x3, #0x8]
    1f24: 92800005     	mov	x5, #-0x1               ; =-1
    1f28: f9000865     	str	x5, [x3, #0x10]
    1f2c: d2800005     	mov	x5, #0x0                ; =0
    1f30: f9000c65     	str	x5, [x3, #0x18]
    1f34: f9001065     	str	x5, [x3, #0x20]
    1f38: f9001465     	str	x5, [x3, #0x28]
    1f3c: f9001865     	str	x5, [x3, #0x30]
    1f40: f9001c65     	str	x5, [x3, #0x38]
    1f44: f9002065     	str	x5, [x3, #0x40]
    1f48: f9002465     	str	x5, [x3, #0x48]
    1f4c: f9002865     	str	x5, [x3, #0x50]
    1f50: aa1903e3     	mov	x3, x25
    1f54: f9003064     	str	x4, [x3, #0x60]
    1f58: 91002c23     	add	x3, x1, #0xb
    1f5c: aa1903e4     	mov	x4, x25
    1f60: f9002883     	str	x3, [x4, #0x50]
    1f64: aa1903e3     	mov	x3, x25
    1f68: f9403463     	ldr	x3, [x3, #0x68]
    1f6c: d1002463     	sub	x3, x3, #0x9
    1f70: f9003483     	str	x3, [x4, #0x68]
    1f74: aa1903e3     	mov	x3, x25
    1f78: f9403863     	ldr	x3, [x3, #0x70]
    1f7c: d1002463     	sub	x3, x3, #0x9
    1f80: f9003883     	str	x3, [x4, #0x70]
    1f84: aa1903e3     	mov	x3, x25
    1f88: f9404063     	ldr	x3, [x3, #0x80]
    1f8c: d2c00164     	mov	x4, #0xb00000000        ; =47244640256
    1f90: aa040000     	orr	x0, x0, x4
    1f94: d37ced04     	lsl	x4, x8, #4
    1f98: 8b081065     	add	x5, x3, x8, lsl #4
    1f9c: f8246860     	str	x0, [x3, x4]
    1fa0: f90004a2     	str	x2, [x5, #0x8]
    1fa4: 91000500     	add	x0, x8, #0x1
    1fa8: aa1903e2     	mov	x2, x25
    1fac: f9004440     	str	x0, [x2, #0x88]
    1fb0: aa1903e0     	mov	x0, x25
    1fb4: aa1903e0     	mov	x0, x25
    1fb8: b9401816     	ldr	w22, [x0, #0x18]
    1fbc: b9401c00     	ldr	w0, [x0, #0x1c]
    1fc0: 110016c2     	add	w2, w22, #0x5
    1fc4: 6b00005f     	cmp	w2, w0
    1fc8: 5400d488     	b.hi	0x3a58 <___pl_fn_1+0x394c>
    1fcc: aa1903e0     	mov	x0, x25
    1fd0: f9401002     	ldr	x2, [x0, #0x20]
    1fd4: 2a1603f8     	mov	w24, w22
    1fd8: 8b180840     	add	x0, x2, x24, lsl #2
    1fdc: aa1b03e3     	mov	x3, x27
    1fe0: b8365843     	str	w3, [x2, w22, uxtw #2]
    1fe4: aa1c03e5     	mov	x5, x28
    1fe8: b9000405     	str	w5, [x0, #0x4]
    1fec: b9000814     	str	w20, [x0, #0x8]
    1ff0: aa1703e7     	mov	x7, x23
    1ff4: b9000c07     	str	w7, [x0, #0xc]
    1ff8: b9001001     	str	w1, [x0, #0x10]
    1ffc: 110016c0     	add	w0, w22, #0x5
    2000: aa1903ec     	mov	x12, x25
    2004: b9001980     	str	w0, [x12, #0x18]
    2008: aa1903e0     	mov	x0, x25
    200c: b9401000     	ldr	w0, [x0, #0x10]
    2010: aa1903e2     	mov	x2, x25
    2014: b9401442     	ldr	w2, [x2, #0x14]
    2018: 6b02001f     	cmp	w0, w2
    201c: 5400d042     	b.hs	0x3a24 <___pl_fn_1+0x3918>
    2020: d28000c3     	mov	x3, #0x6                ; =6
    2024: d2807d04     	mov	x4, #0x3e8              ; =1000
    2028: aa1703e2     	mov	x2, x23
    202c: aa1903e0     	mov	x0, x25
    2030: 94000000     	bl	0x2030 <___pl_fn_1+0x1f24>
    2034: aa1903e1     	mov	x1, x25
    2038: b9402c21     	ldr	w1, [x1, #0x2c]
    203c: 35010821     	cbnz	w1, 0x4140 <___pl_fn_1+0x4034>
    2040: aa1903e1     	mov	x1, x25
    2044: b9001836     	str	w22, [x1, #0x18]
    2048: 3400cd40     	cbz	w0, 0x39f0 <___pl_fn_1+0x38e4>
    204c: aa1903e1     	mov	x1, x25
    2050: f9403c21     	ldr	x1, [x1, #0x78]
    2054: 37689ba1     	tbnz	w1, #0xd, 0x33c8 <___pl_fn_1+0x32bc>
    2058: aa1903e1     	mov	x1, x25
    205c: f9403821     	ldr	x1, [x1, #0x70]
    2060: f100003f     	cmp	x1, #0x0
    2064: 54009b6d     	b.le	0x33d0 <___pl_fn_1+0x32c4>
    2068: aa1903e1     	mov	x1, x25
    206c: f9403422     	ldr	x2, [x1, #0x68]
    2070: d2800161     	mov	x1, #0xb                ; =11
    2074: f1002c5f     	cmp	x2, #0xb
    2078: 54009b0b     	b.lt	0x33d8 <___pl_fn_1+0x32cc>
    207c: aa1903e2     	mov	x2, x25
    2080: f9402857     	ldr	x23, [x2, #0x50]
    2084: f9402c44     	ldr	x4, [x2, #0x58]
    2088: 910036e5     	add	x5, x23, #0xd
    208c: eb0400bf     	cmp	x5, x4
    2090: 54009a88     	b.hi	0x33e0 <___pl_fn_1+0x32d4>
    2094: aa1903e2     	mov	x2, x25
    2098: f9404447     	ldr	x7, [x2, #0x88]
    209c: f9404848     	ldr	x8, [x2, #0x90]
    20a0: eb0800ff     	cmp	x7, x8
    20a4: 54009a22     	b.hs	0x33e8 <___pl_fn_1+0x32dc>
    20a8: aa1903e2     	mov	x2, x25
    20ac: b9401c4a     	ldr	w10, [x2, #0x1c]
    20b0: 110012cb     	add	w11, w22, #0x4
    20b4: 6b0a017f     	cmp	w11, w10
    20b8: 54000309     	b.ls	0x2118 <___pl_fn_1+0x200c>
    20bc: 140004cd     	b	0x33f0 <___pl_fn_1+0x32e4>
    20c0: aa1903e8     	mov	x8, x25
    20c4: f9401101     	ldr	x1, [x8, #0x20]
    20c8: 8b18082f     	add	x15, x1, x24, lsl #2
    20cc: aa1b03e2     	mov	x2, x27
    20d0: b8365822     	str	w2, [x1, w22, uxtw #2]
    20d4: aa1c03e5     	mov	x5, x28
    20d8: b90005e5     	str	w5, [x15, #0x4]
    20dc: b90009f4     	str	w20, [x15, #0x8]
    20e0: b9000de0     	str	w0, [x15, #0xc]
    20e4: aa0003fa     	mov	x26, x0
    20e8: aa1903e0     	mov	x0, x25
    20ec: b900180d     	str	w13, [x0, #0x18]
    20f0: 52800aa1     	mov	w1, #0x55               ; =85
    20f4: 52800082     	mov	w2, #0x4                ; =4
    20f8: 90000003     	adrp	x3, 0x2000 <___pl_fn_1+0x1ef4>
    20fc: f9400063     	ldr	x3, [x3]
    2100: d63f0060     	blr	x3
    2104: 350101e0     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    2108: aa1903e0     	mov	x0, x25
    210c: f9401817     	ldr	x23, [x0, #0x30]
    2110: b9001816     	str	w22, [x0, #0x18]
    2114: 14000032     	b	0x21dc <___pl_fn_1+0x20d0>
    2118: aa0003fa     	mov	x26, x0
    211c: aa1903e0     	mov	x0, x25
    2120: f9403003     	ldr	x3, [x0, #0x60]
    2124: f9400004     	ldr	x4, [x0]
    2128: d28000e5     	mov	x5, #0x7                ; =7
    212c: f2c00065     	movk	x5, #0x3, lsl #32
    2130: 2a1703e0     	mov	w0, w23
    2134: 8b000c82     	add	x2, x4, x0, lsl #3
    2138: f8375885     	str	x5, [x4, w23, uxtw #3]
    213c: 91000463     	add	x3, x3, #0x1
    2140: f9000443     	str	x3, [x2, #0x8]
    2144: 92800004     	mov	x4, #-0x1               ; =-1
    2148: f9000844     	str	x4, [x2, #0x10]
    214c: d2800004     	mov	x4, #0x0                ; =0
    2150: f9000c44     	str	x4, [x2, #0x18]
    2154: f9001044     	str	x4, [x2, #0x20]
    2158: f9001444     	str	x4, [x2, #0x28]
    215c: f9001844     	str	x4, [x2, #0x30]
    2160: f9001c55     	str	x21, [x2, #0x38]
    2164: f9002055     	str	x21, [x2, #0x40]
    2168: f9002455     	str	x21, [x2, #0x48]
    216c: f9002844     	str	x4, [x2, #0x50]
    2170: f9002c44     	str	x4, [x2, #0x58]
    2174: f9003044     	str	x4, [x2, #0x60]
    2178: aa1903e2     	mov	x2, x25
    217c: f9003043     	str	x3, [x2, #0x60]
    2180: 910036e2     	add	x2, x23, #0xd
    2184: aa1903e3     	mov	x3, x25
    2188: f9002862     	str	x2, [x3, #0x50]
    218c: aa1903e2     	mov	x2, x25
    2190: f9403442     	ldr	x2, [x2, #0x68]
    2194: d1002c42     	sub	x2, x2, #0xb
    2198: f9003462     	str	x2, [x3, #0x68]
    219c: aa1903e4     	mov	x4, x25
    21a0: f9403882     	ldr	x2, [x4, #0x70]
    21a4: d1002c42     	sub	x2, x2, #0xb
    21a8: aa1903e8     	mov	x8, x25
    21ac: f9003902     	str	x2, [x8, #0x70]
    21b0: aa1903e9     	mov	x9, x25
    21b4: f9404122     	ldr	x2, [x9, #0x80]
    21b8: d2c001a3     	mov	x3, #0xd00000000        ; =55834574848
    21bc: aa030000     	orr	x0, x0, x3
    21c0: d37cece3     	lsl	x3, x7, #4
    21c4: 8b071044     	add	x4, x2, x7, lsl #4
    21c8: f8236840     	str	x0, [x2, x3]
    21cc: f9000481     	str	x1, [x4, #0x8]
    21d0: 910004e0     	add	x0, x7, #0x1
    21d4: aa1903e1     	mov	x1, x25
    21d8: f9004420     	str	x0, [x1, #0x88]
    21dc: 3400bf17     	cbz	w23, 0x39bc <___pl_fn_1+0x38b0>
    21e0: 340092f7     	cbz	w23, 0x343c <___pl_fn_1+0x3330>
    21e4: aa1903e0     	mov	x0, x25
    21e8: aa1703f6     	mov	x22, x23
    21ec: f9400001     	ldr	x1, [x0]
    21f0: 2a1603e0     	mov	w0, w22
    21f4: 8b000c20     	add	x0, x1, x0, lsl #3
    21f8: f8765822     	ldr	x2, [x1, w22, uxtw #3]
    21fc: aa1c03e5     	mov	x5, x28
    2200: 2a0503e1     	mov	w1, w5
    2204: d360fc42     	lsr	x2, x2, #32
    2208: 92403c42     	and	x2, x2, #0xffff
    220c: 91002042     	add	x2, x2, #0x8
    2210: f8227801     	str	x1, [x0, x2, lsl #3]
    2214: 350000b6     	cbnz	w22, 0x2228 <___pl_fn_1+0x211c>
    2218: 14000498     	b	0x3478 <___pl_fn_1+0x336c>
    221c: aa1903e0     	mov	x0, x25
    2220: aa1603e1     	mov	x1, x22
    2224: 1400000e     	b	0x225c <___pl_fn_1+0x2150>
    2228: aa1903e0     	mov	x0, x25
    222c: f9400002     	ldr	x2, [x0]
    2230: aa1603e1     	mov	x1, x22
    2234: 2a0103e0     	mov	w0, w1
    2238: 8b000c40     	add	x0, x2, x0, lsl #3
    223c: f8615843     	ldr	x3, [x2, w1, uxtw #3]
    2240: aa1c03e5     	mov	x5, x28
    2244: 2a0503e2     	mov	w2, w5
    2248: d360fc63     	lsr	x3, x3, #32
    224c: 92403c63     	and	x3, x3, #0xffff
    2250: 91002463     	add	x3, x3, #0x9
    2254: f8237802     	str	x2, [x0, x3, lsl #3]
    2258: aa1903e0     	mov	x0, x25
    225c: aa1903e0     	mov	x0, x25
    2260: b9401816     	ldr	w22, [x0, #0x18]
    2264: b9401c00     	ldr	w0, [x0, #0x1c]
    2268: 110016c2     	add	w2, w22, #0x5
    226c: 6b00005f     	cmp	w2, w0
    2270: 5400b8c8     	b.hi	0x3988 <___pl_fn_1+0x387c>
    2274: aa1903e0     	mov	x0, x25
    2278: f9401003     	ldr	x3, [x0, #0x20]
    227c: 2a1603f8     	mov	w24, w22
    2280: 8b180862     	add	x2, x3, x24, lsl #2
    2284: aa1b03ed     	mov	x13, x27
    2288: b836586d     	str	w13, [x3, w22, uxtw #2]
    228c: aa1c03e5     	mov	x5, x28
    2290: b9000445     	str	w5, [x2, #0x4]
    2294: b9000854     	str	w20, [x2, #0x8]
    2298: aa1a03e0     	mov	x0, x26
    229c: b9000c40     	str	w0, [x2, #0xc]
    22a0: b9001041     	str	w1, [x2, #0x10]
    22a4: 110016c7     	add	w7, w22, #0x5
    22a8: aa1903e0     	mov	x0, x25
    22ac: b9001807     	str	w7, [x0, #0x18]
    22b0: b9401008     	ldr	w8, [x0, #0x10]
    22b4: b9401409     	ldr	w9, [x0, #0x14]
    22b8: 6b09011f     	cmp	w8, w9
    22bc: 5400b4c2     	b.hs	0x3954 <___pl_fn_1+0x3848>
    22c0: d2800083     	mov	x3, #0x4                ; =4
    22c4: d2817704     	mov	x4, #0xbb8              ; =3000
    22c8: 52800027     	mov	w7, #0x1                ; =1
    22cc: aa1a03e5     	mov	x5, x26
    22d0: aa1903e0     	mov	x0, x25
    22d4: aa1b03e2     	mov	x2, x27
    22d8: aa0703e6     	mov	x6, x7
    22dc: 94000000     	bl	0x22dc <___pl_fn_1+0x21d0>
    22e0: aa1903e0     	mov	x0, x25
    22e4: b9402c0b     	ldr	w11, [x0, #0x2c]
    22e8: 3500f2cb     	cbnz	w11, 0x4140 <___pl_fn_1+0x4034>
    22ec: aa1903e0     	mov	x0, x25
    22f0: b9001816     	str	w22, [x0, #0x18]
    22f4: f9403c0e     	ldr	x14, [x0, #0x78]
    22f8: 37608dce     	tbnz	w14, #0xc, 0x34b0 <___pl_fn_1+0x33a4>
    22fc: aa1903e0     	mov	x0, x25
    2300: f9403800     	ldr	x0, [x0, #0x70]
    2304: f100001f     	cmp	x0, #0x0
    2308: 54008d8d     	b.le	0x34b8 <___pl_fn_1+0x33ac>
    230c: aa1903e0     	mov	x0, x25
    2310: f9403401     	ldr	x1, [x0, #0x68]
    2314: d2800140     	mov	x0, #0xa                ; =10
    2318: f100283f     	cmp	x1, #0xa
    231c: 54008d2b     	b.lt	0x34c0 <___pl_fn_1+0x33b4>
    2320: aa1903e1     	mov	x1, x25
    2324: f9402837     	ldr	x23, [x1, #0x50]
    2328: f9402c21     	ldr	x1, [x1, #0x58]
    232c: 910032e2     	add	x2, x23, #0xc
    2330: eb01005f     	cmp	x2, x1
    2334: 54008ca8     	b.hi	0x34c8 <___pl_fn_1+0x33bc>
    2338: aa1903e1     	mov	x1, x25
    233c: f9404421     	ldr	x1, [x1, #0x88]
    2340: aa1903e2     	mov	x2, x25
    2344: f9404842     	ldr	x2, [x2, #0x90]
    2348: eb02003f     	cmp	x1, x2
    234c: 54008c22     	b.hs	0x34d0 <___pl_fn_1+0x33c4>
    2350: aa1903e7     	mov	x7, x25
    2354: b9401ce2     	ldr	w2, [x7, #0x1c]
    2358: 11000ec3     	add	w3, w22, #0x3
    235c: 6b02007f     	cmp	w3, w2
    2360: 540002c9     	b.ls	0x23b8 <___pl_fn_1+0x22ac>
    2364: 1400045d     	b	0x34d8 <___pl_fn_1+0x33cc>
    2368: aa1903e1     	mov	x1, x25
    236c: f9401023     	ldr	x3, [x1, #0x20]
    2370: 8b180861     	add	x1, x3, x24, lsl #2
    2374: aa1b03e5     	mov	x5, x27
    2378: b8365865     	str	w5, [x3, w22, uxtw #2]
    237c: aa1c03e5     	mov	x5, x28
    2380: b9000425     	str	w5, [x1, #0x4]
    2384: b9000834     	str	w20, [x1, #0x8]
    2388: aa1903e1     	mov	x1, x25
    238c: b9001820     	str	w0, [x1, #0x18]
    2390: 52800b81     	mov	w1, #0x5c               ; =92
    2394: 90000003     	adrp	x3, 0x2000 <___pl_fn_1+0x1ef4>
    2398: f9400063     	ldr	x3, [x3]
    239c: aa1903e0     	mov	x0, x25
    23a0: d63f0060     	blr	x3
    23a4: 3500ece0     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    23a8: aa1903e0     	mov	x0, x25
    23ac: f9401817     	ldr	x23, [x0, #0x30]
    23b0: b9001816     	str	w22, [x0, #0x18]
    23b4: 14000030     	b	0x2474 <___pl_fn_1+0x2368>
    23b8: aa1903e2     	mov	x2, x25
    23bc: f9403044     	ldr	x4, [x2, #0x60]
    23c0: f9400045     	ldr	x5, [x2]
    23c4: d28000c6     	mov	x6, #0x6                ; =6
    23c8: f2c00066     	movk	x6, #0x3, lsl #32
    23cc: 2a1703e2     	mov	w2, w23
    23d0: 8b020ca3     	add	x3, x5, x2, lsl #3
    23d4: f83758a6     	str	x6, [x5, w23, uxtw #3]
    23d8: 91000484     	add	x4, x4, #0x1
    23dc: f9000464     	str	x4, [x3, #0x8]
    23e0: 92800005     	mov	x5, #-0x1               ; =-1
    23e4: f9000865     	str	x5, [x3, #0x10]
    23e8: d2800005     	mov	x5, #0x0                ; =0
    23ec: f9000c65     	str	x5, [x3, #0x18]
    23f0: f9001065     	str	x5, [x3, #0x20]
    23f4: f9001465     	str	x5, [x3, #0x28]
    23f8: f9001865     	str	x5, [x3, #0x30]
    23fc: f9001c75     	str	x21, [x3, #0x38]
    2400: f9002075     	str	x21, [x3, #0x40]
    2404: f9002475     	str	x21, [x3, #0x48]
    2408: f9002865     	str	x5, [x3, #0x50]
    240c: f9002c65     	str	x5, [x3, #0x58]
    2410: aa1903e3     	mov	x3, x25
    2414: f9003064     	str	x4, [x3, #0x60]
    2418: 910032e3     	add	x3, x23, #0xc
    241c: aa1903e5     	mov	x5, x25
    2420: f90028a3     	str	x3, [x5, #0x50]
    2424: aa1903e7     	mov	x7, x25
    2428: f94034e3     	ldr	x3, [x7, #0x68]
    242c: d1002863     	sub	x3, x3, #0xa
    2430: aa1903ea     	mov	x10, x25
    2434: f9003543     	str	x3, [x10, #0x68]
    2438: aa1903ec     	mov	x12, x25
    243c: f9403983     	ldr	x3, [x12, #0x70]
    2440: d1002863     	sub	x3, x3, #0xa
    2444: aa1903ef     	mov	x15, x25
    2448: f90039e3     	str	x3, [x15, #0x70]
    244c: aa1903e3     	mov	x3, x25
    2450: f9404063     	ldr	x3, [x3, #0x80]
    2454: b25e0442     	orr	x2, x2, #0xc00000000
    2458: d37cec24     	lsl	x4, x1, #4
    245c: 8b011065     	add	x5, x3, x1, lsl #4
    2460: f8246862     	str	x2, [x3, x4]
    2464: f90004a0     	str	x0, [x5, #0x8]
    2468: 91000420     	add	x0, x1, #0x1
    246c: aa1903e1     	mov	x1, x25
    2470: f9004420     	str	x0, [x1, #0x88]
    2474: 3400a577     	cbz	w23, 0x3920 <___pl_fn_1+0x3814>
    2478: 35000097     	cbnz	w23, 0x2488 <___pl_fn_1+0x237c>
    247c: 1400042b     	b	0x3528 <___pl_fn_1+0x341c>
    2480: aa1903e0     	mov	x0, x25
    2484: 1400000d     	b	0x24b8 <___pl_fn_1+0x23ac>
    2488: aa1903e0     	mov	x0, x25
    248c: aa1703e1     	mov	x1, x23
    2490: f9400007     	ldr	x7, [x0]
    2494: 2a0103e6     	mov	w6, w1
    2498: 8b060ce6     	add	x6, x7, x6, lsl #3
    249c: f86158e8     	ldr	x8, [x7, w1, uxtw #3]
    24a0: aa1c03e5     	mov	x5, x28
    24a4: 2a0503e7     	mov	w7, w5
    24a8: d360fd08     	lsr	x8, x8, #32
    24ac: 92403d08     	and	x8, x8, #0xffff
    24b0: 91002108     	add	x8, x8, #0x8
    24b4: f82878c7     	str	x7, [x6, x8, lsl #3]
    24b8: aa1903e0     	mov	x0, x25
    24bc: b9401816     	ldr	w22, [x0, #0x18]
    24c0: b9401c09     	ldr	w9, [x0, #0x1c]
    24c4: 110012c8     	add	w8, w22, #0x4
    24c8: 6b09011f     	cmp	w8, w9
    24cc: 5400a108     	b.hi	0x38ec <___pl_fn_1+0x37e0>
    24d0: aa1903e0     	mov	x0, x25
    24d4: f940100b     	ldr	x11, [x0, #0x20]
    24d8: 2a1603f8     	mov	w24, w22
    24dc: 8b18096a     	add	x10, x11, x24, lsl #2
    24e0: aa1b03e2     	mov	x2, x27
    24e4: b8365962     	str	w2, [x11, w22, uxtw #2]
    24e8: aa1c03e5     	mov	x5, x28
    24ec: b9000545     	str	w5, [x10, #0x4]
    24f0: b9000954     	str	w20, [x10, #0x8]
    24f4: b9000d41     	str	w1, [x10, #0xc]
    24f8: b9001808     	str	w8, [x0, #0x18]
    24fc: b940100f     	ldr	w15, [x0, #0x10]
    2500: b9401400     	ldr	w0, [x0, #0x14]
    2504: 6b0001ff     	cmp	w15, w0
    2508: 54009d82     	b.hs	0x38b8 <___pl_fn_1+0x37ac>
    250c: d28000a3     	mov	x3, #0x5                ; =5
    2510: d281f404     	mov	x4, #0xfa0              ; =4000
    2514: 52800006     	mov	w6, #0x0                ; =0
    2518: 52800027     	mov	w7, #0x1                ; =1
    251c: aa1903e0     	mov	x0, x25
    2520: aa1b03e2     	mov	x2, x27
    2524: aa1c03e5     	mov	x5, x28
    2528: 94000000     	bl	0x2528 <___pl_fn_1+0x241c>
    252c: aa1903e0     	mov	x0, x25
    2530: b9402c00     	ldr	w0, [x0, #0x2c]
    2534: 3500e060     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    2538: aa1903e0     	mov	x0, x25
    253c: b9001816     	str	w22, [x0, #0x18]
    2540: f9403c00     	ldr	x0, [x0, #0x78]
    2544: 37608100     	tbnz	w0, #0xc, 0x3564 <___pl_fn_1+0x3458>
    2548: aa1903e0     	mov	x0, x25
    254c: f9403800     	ldr	x0, [x0, #0x70]
    2550: f100001f     	cmp	x0, #0x0
    2554: 540080cd     	b.le	0x356c <___pl_fn_1+0x3460>
    2558: aa1903e0     	mov	x0, x25
    255c: f9403401     	ldr	x1, [x0, #0x68]
    2560: d2800140     	mov	x0, #0xa                ; =10
    2564: f100283f     	cmp	x1, #0xa
    2568: 5400806b     	b.lt	0x3574 <___pl_fn_1+0x3468>
    256c: aa1903e1     	mov	x1, x25
    2570: f9402837     	ldr	x23, [x1, #0x50]
    2574: f9402c21     	ldr	x1, [x1, #0x58]
    2578: 910032e2     	add	x2, x23, #0xc
    257c: eb01005f     	cmp	x2, x1
    2580: 54007fe8     	b.hi	0x357c <___pl_fn_1+0x3470>
    2584: aa1903e1     	mov	x1, x25
    2588: f9404421     	ldr	x1, [x1, #0x88]
    258c: aa1903e2     	mov	x2, x25
    2590: f9404842     	ldr	x2, [x2, #0x90]
    2594: eb02003f     	cmp	x1, x2
    2598: 54007f62     	b.hs	0x3584 <___pl_fn_1+0x3478>
    259c: aa1903e2     	mov	x2, x25
    25a0: b9401c42     	ldr	w2, [x2, #0x1c]
    25a4: 11000ec3     	add	w3, w22, #0x3
    25a8: 6b02007f     	cmp	w3, w2
    25ac: 540002c9     	b.ls	0x2604 <___pl_fn_1+0x24f8>
    25b0: 140003f7     	b	0x358c <___pl_fn_1+0x3480>
    25b4: aa1903e3     	mov	x3, x25
    25b8: f9401063     	ldr	x3, [x3, #0x20]
    25bc: 8b180861     	add	x1, x3, x24, lsl #2
    25c0: aa1b03e4     	mov	x4, x27
    25c4: b8365864     	str	w4, [x3, w22, uxtw #2]
    25c8: aa1c03e5     	mov	x5, x28
    25cc: b9000425     	str	w5, [x1, #0x4]
    25d0: b9000834     	str	w20, [x1, #0x8]
    25d4: aa1903e8     	mov	x8, x25
    25d8: b9001900     	str	w0, [x8, #0x18]
    25dc: 52800c41     	mov	w1, #0x62               ; =98
    25e0: 90000003     	adrp	x3, 0x2000 <___pl_fn_1+0x1ef4>
    25e4: f9400063     	ldr	x3, [x3]
    25e8: aa1903e0     	mov	x0, x25
    25ec: d63f0060     	blr	x3
    25f0: 3500da80     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    25f4: aa1903e0     	mov	x0, x25
    25f8: f9401817     	ldr	x23, [x0, #0x30]
    25fc: b9001816     	str	w22, [x0, #0x18]
    2600: 1400002e     	b	0x26b8 <___pl_fn_1+0x25ac>
    2604: aa1903e2     	mov	x2, x25
    2608: f9403044     	ldr	x4, [x2, #0x60]
    260c: f9400045     	ldr	x5, [x2]
    2610: d28000c6     	mov	x6, #0x6                ; =6
    2614: f2c00066     	movk	x6, #0x3, lsl #32
    2618: 2a1703e2     	mov	w2, w23
    261c: 8b020ca3     	add	x3, x5, x2, lsl #3
    2620: f83758a6     	str	x6, [x5, w23, uxtw #3]
    2624: 91000484     	add	x4, x4, #0x1
    2628: f9000464     	str	x4, [x3, #0x8]
    262c: 92800005     	mov	x5, #-0x1               ; =-1
    2630: f9000865     	str	x5, [x3, #0x10]
    2634: d2800005     	mov	x5, #0x0                ; =0
    2638: f9000c65     	str	x5, [x3, #0x18]
    263c: f9001065     	str	x5, [x3, #0x20]
    2640: f9001465     	str	x5, [x3, #0x28]
    2644: f9001865     	str	x5, [x3, #0x30]
    2648: f9001c75     	str	x21, [x3, #0x38]
    264c: f9002075     	str	x21, [x3, #0x40]
    2650: f9002475     	str	x21, [x3, #0x48]
    2654: f9002865     	str	x5, [x3, #0x50]
    2658: f9002c65     	str	x5, [x3, #0x58]
    265c: aa1903e3     	mov	x3, x25
    2660: f9003064     	str	x4, [x3, #0x60]
    2664: 910032e3     	add	x3, x23, #0xc
    2668: aa1903e4     	mov	x4, x25
    266c: f9002883     	str	x3, [x4, #0x50]
    2670: aa1903e3     	mov	x3, x25
    2674: f9403463     	ldr	x3, [x3, #0x68]
    2678: d1002863     	sub	x3, x3, #0xa
    267c: f9003483     	str	x3, [x4, #0x68]
    2680: aa1903e3     	mov	x3, x25
    2684: f9403863     	ldr	x3, [x3, #0x70]
    2688: d1002863     	sub	x3, x3, #0xa
    268c: f9003883     	str	x3, [x4, #0x70]
    2690: aa1903e3     	mov	x3, x25
    2694: f9404063     	ldr	x3, [x3, #0x80]
    2698: b25e0442     	orr	x2, x2, #0xc00000000
    269c: d37cec24     	lsl	x4, x1, #4
    26a0: 8b011065     	add	x5, x3, x1, lsl #4
    26a4: f8246862     	str	x2, [x3, x4]
    26a8: f90004a0     	str	x0, [x5, #0x8]
    26ac: 91000424     	add	x4, x1, #0x1
    26b0: aa1903e0     	mov	x0, x25
    26b4: f9004404     	str	x4, [x0, #0x88]
    26b8: 34008e77     	cbz	w23, 0x3884 <___pl_fn_1+0x3778>
    26bc: 35000097     	cbnz	w23, 0x26cc <___pl_fn_1+0x25c0>
    26c0: 140003c7     	b	0x35dc <___pl_fn_1+0x34d0>
    26c4: aa1903e0     	mov	x0, x25
    26c8: 1400000d     	b	0x26fc <___pl_fn_1+0x25f0>
    26cc: aa1903e0     	mov	x0, x25
    26d0: aa1703e1     	mov	x1, x23
    26d4: f940000e     	ldr	x14, [x0]
    26d8: 2a0103ed     	mov	w13, w1
    26dc: 8b0d0dcd     	add	x13, x14, x13, lsl #3
    26e0: f86159cf     	ldr	x15, [x14, w1, uxtw #3]
    26e4: aa1c03e5     	mov	x5, x28
    26e8: 2a0503ee     	mov	w14, w5
    26ec: d360fdef     	lsr	x15, x15, #32
    26f0: 92403def     	and	x15, x15, #0xffff
    26f4: 910021ef     	add	x15, x15, #0x8
    26f8: f82f79ae     	str	x14, [x13, x15, lsl #3]
    26fc: aa1903e0     	mov	x0, x25
    2700: b9401815     	ldr	w21, [x0, #0x18]
    2704: b9401c00     	ldr	w0, [x0, #0x1c]
    2708: 110012af     	add	w15, w21, #0x4
    270c: 6b0001ff     	cmp	w15, w0
    2710: 54008a08     	b.hi	0x3850 <___pl_fn_1+0x3744>
    2714: aa1903e0     	mov	x0, x25
    2718: f9401002     	ldr	x2, [x0, #0x20]
    271c: 2a1503e0     	mov	w0, w21
    2720: 8b000840     	add	x0, x2, x0, lsl #2
    2724: aa1b03e3     	mov	x3, x27
    2728: b8355843     	str	w3, [x2, w21, uxtw #2]
    272c: aa1c03e5     	mov	x5, x28
    2730: b9000405     	str	w5, [x0, #0x4]
    2734: b9000814     	str	w20, [x0, #0x8]
    2738: b9000c01     	str	w1, [x0, #0xc]
    273c: aa1903e0     	mov	x0, x25
    2740: b900180f     	str	w15, [x0, #0x18]
    2744: b9401000     	ldr	w0, [x0, #0x10]
    2748: aa1903e2     	mov	x2, x25
    274c: b9401442     	ldr	w2, [x2, #0x14]
    2750: 6b02001f     	cmp	w0, w2
    2754: 54008642     	b.hs	0x381c <___pl_fn_1+0x3710>
    2758: d28000c3     	mov	x3, #0x6                ; =6
    275c: d2827104     	mov	x4, #0x1388             ; =5000
    2760: 52800006     	mov	w6, #0x0                ; =0
    2764: 52800027     	mov	w7, #0x1                ; =1
    2768: aa1c03e5     	mov	x5, x28
    276c: aa1903e0     	mov	x0, x25
    2770: aa1b03e2     	mov	x2, x27
    2774: 94000000     	bl	0x2774 <___pl_fn_1+0x2668>
    2778: aa1903e0     	mov	x0, x25
    277c: b9402c00     	ldr	w0, [x0, #0x2c]
    2780: 3500ce00     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    2784: aa1903e0     	mov	x0, x25
    2788: b9001815     	str	w21, [x0, #0x18]
    278c: aa1b03e2     	mov	x2, x27
    2790: 34007442     	cbz	w2, 0x3618 <___pl_fn_1+0x350c>
    2794: aa1903e0     	mov	x0, x25
    2798: f9400001     	ldr	x1, [x0]
    279c: aa1b03e2     	mov	x2, x27
    27a0: 2a0203e0     	mov	w0, w2
    27a4: 8b000c20     	add	x0, x1, x0, lsl #3
    27a8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    27ac: d360fc21     	lsr	x1, x1, #32
    27b0: 92403c21     	and	x1, x1, #0xffff
    27b4: d37df021     	lsl	x1, x1, #3
    27b8: b8616802     	ldr	w2, [x0, x1]
    27bc: 35000082     	cbnz	w2, 0x27cc <___pl_fn_1+0x26c0>
    27c0: 14000396     	b	0x3618 <___pl_fn_1+0x350c>
    27c4: aa1903e0     	mov	x0, x25
    27c8: f9401802     	ldr	x2, [x0, #0x30]
    27cc: 340080e2     	cbz	w2, 0x37e8 <___pl_fn_1+0x36dc>
    27d0: aa0203f5     	mov	x21, x2
    27d4: 6b1402bf     	cmp	w21, w20
    27d8: 54000ac1     	b.ne	0x2930 <___pl_fn_1+0x2824>
    27dc: aa1b03e2     	mov	x2, x27
    27e0: 340072e2     	cbz	w2, 0x363c <___pl_fn_1+0x3530>
    27e4: aa1903e0     	mov	x0, x25
    27e8: f9400001     	ldr	x1, [x0]
    27ec: aa1b03e2     	mov	x2, x27
    27f0: 2a0203e0     	mov	w0, w2
    27f4: 8b000c20     	add	x0, x1, x0, lsl #3
    27f8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    27fc: d360fc21     	lsr	x1, x1, #32
    2800: 92403c21     	and	x1, x1, #0xffff
    2804: 91002822     	add	x2, x1, #0xa
    2808: f8627802     	ldr	x2, [x0, x2, lsl #3]
    280c: f100083f     	cmp	x1, #0x2
    2810: 54000061     	b.ne	0x281c <___pl_fn_1+0x2710>
    2814: aa0203f3     	mov	x19, x2
    2818: 1400000a     	b	0x2840 <___pl_fn_1+0x2734>
    281c: f9400800     	ldr	x0, [x0, #0x10]
    2820: 375070e0     	tbnz	w0, #0xa, 0x363c <___pl_fn_1+0x3530>
    2824: aa0203f3     	mov	x19, x2
    2828: 14000006     	b	0x2840 <___pl_fn_1+0x2734>
    282c: aa1903e0     	mov	x0, x25
    2830: f9401802     	ldr	x2, [x0, #0x30]
    2834: aa0203f3     	mov	x19, x2
    2838: aa1b03e2     	mov	x2, x27
    283c: 14000002     	b	0x2844 <___pl_fn_1+0x2738>
    2840: aa1b03e2     	mov	x2, x27
    2844: aa1b03e2     	mov	x2, x27
    2848: 340070c2     	cbz	w2, 0x3660 <___pl_fn_1+0x3554>
    284c: aa1903e0     	mov	x0, x25
    2850: f9400001     	ldr	x1, [x0]
    2854: aa1b03e2     	mov	x2, x27
    2858: 2a0203e0     	mov	w0, w2
    285c: 8b000c20     	add	x0, x1, x0, lsl #3
    2860: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    2864: d360fc21     	lsr	x1, x1, #32
    2868: 92403c21     	and	x1, x1, #0xffff
    286c: 91002422     	add	x2, x1, #0x9
    2870: f8627802     	ldr	x2, [x0, x2, lsl #3]
    2874: f100083f     	cmp	x1, #0x2
    2878: 54000061     	b.ne	0x2884 <___pl_fn_1+0x2778>
    287c: aa0203f4     	mov	x20, x2
    2880: 14000008     	b	0x28a0 <___pl_fn_1+0x2794>
    2884: f9400800     	ldr	x0, [x0, #0x10]
    2888: 37486ec0     	tbnz	w0, #0x9, 0x3660 <___pl_fn_1+0x3554>
    288c: aa0203f4     	mov	x20, x2
    2890: 14000004     	b	0x28a0 <___pl_fn_1+0x2794>
    2894: aa1903e0     	mov	x0, x25
    2898: f9401802     	ldr	x2, [x0, #0x30]
    289c: aa0203f4     	mov	x20, x2
    28a0: 52800d61     	mov	w1, #0x6b               ; =107
    28a4: 52800003     	mov	w3, #0x0                ; =0
    28a8: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    28ac: f9400084     	ldr	x4, [x4]
    28b0: aa1303e2     	mov	x2, x19
    28b4: aa1903e0     	mov	x0, x25
    28b8: d63f0080     	blr	x4
    28bc: 3500c420     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    28c0: 52800d81     	mov	w1, #0x6c               ; =108
    28c4: d2800402     	mov	x2, #0x20               ; =32
    28c8: 52800063     	mov	w3, #0x3                ; =3
    28cc: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    28d0: f9400084     	ldr	x4, [x4]
    28d4: aa1903e0     	mov	x0, x25
    28d8: d63f0080     	blr	x4
    28dc: 3500c320     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    28e0: 52800da1     	mov	w1, #0x6d               ; =109
    28e4: 52802003     	mov	w3, #0x100              ; =256
    28e8: 90000005     	adrp	x5, 0x2000 <___pl_fn_1+0x1ef4>
    28ec: f94000a5     	ldr	x5, [x5]
    28f0: aa1403e2     	mov	x2, x20
    28f4: aa1903e0     	mov	x0, x25
    28f8: d63f00a0     	blr	x5
    28fc: 3500c220     	cbnz	w0, 0x4140 <___pl_fn_1+0x4034>
    2900: aa1903e0     	mov	x0, x25
    2904: b9401007     	ldr	w7, [x0, #0x10]
    2908: 510004e7     	sub	w7, w7, #0x1
    290c: b9001007     	str	w7, [x0, #0x10]
    2910: 910403ff     	add	sp, sp, #0x100
    2914: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2918: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    291c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2920: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2924: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2928: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    292c: d65f03c0     	ret
    2930: 34006ab5     	cbz	w21, 0x3684 <___pl_fn_1+0x3578>
    2934: aa1903e0     	mov	x0, x25
    2938: f940000c     	ldr	x12, [x0]
    293c: 2a1503eb     	mov	w11, w21
    2940: 8b0b0d8b     	add	x11, x12, x11, lsl #3
    2944: f875598c     	ldr	x12, [x12, w21, uxtw #3]
    2948: d360fd8c     	lsr	x12, x12, #32
    294c: 92403d8c     	and	x12, x12, #0xffff
    2950: 9100198c     	add	x12, x12, #0x6
    2954: d37df18c     	lsl	x12, x12, #3
    2958: 386c6960     	ldrb	w0, [x11, x12]
    295c: 53001c0b     	uxtb	w11, w0
    2960: 7100097f     	cmp	w11, #0x2
    2964: 540000a1     	b.ne	0x2978 <___pl_fn_1+0x286c>
    2968: 14000347     	b	0x3684 <___pl_fn_1+0x3578>
    296c: aa1903e0     	mov	x0, x25
    2970: f9401800     	ldr	x0, [x0, #0x30]
    2974: 14000002     	b	0x297c <___pl_fn_1+0x2870>
    2978: aa1503f6     	mov	x22, x21
    297c: 72001c1f     	tst	w0, #0xff
    2980: 540005e1     	b.ne	0x2a3c <___pl_fn_1+0x2930>
    2984: aa1603e1     	mov	x1, x22
    2988: 34006921     	cbz	w1, 0x36ac <___pl_fn_1+0x35a0>
    298c: aa1903e0     	mov	x0, x25
    2990: f9400001     	ldr	x1, [x0]
    2994: aa1603e0     	mov	x0, x22
    2998: 2a0003e0     	mov	w0, w0
    299c: 8b000c20     	add	x0, x1, x0, lsl #3
    29a0: aa1603e2     	mov	x2, x22
    29a4: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    29a8: d360fc21     	lsr	x1, x1, #32
    29ac: 92403c21     	and	x1, x1, #0xffff
    29b0: 91001021     	add	x1, x1, #0x4
    29b4: d37df021     	lsl	x1, x1, #3
    29b8: 38616808     	ldrb	w8, [x0, x1]
    29bc: 53001d00     	uxtb	w0, w8
    29c0: 7100081f     	cmp	w0, #0x2
    29c4: 54000081     	b.ne	0x29d4 <___pl_fn_1+0x28c8>
    29c8: 14000339     	b	0x36ac <___pl_fn_1+0x35a0>
    29cc: aa1903e0     	mov	x0, x25
    29d0: f9401808     	ldr	x8, [x0, #0x30]
    29d4: 52000100     	eor	w0, w8, #0x1
    29d8: 72001c1f     	tst	w0, #0xff
    29dc: 54000061     	b.ne	0x29e8 <___pl_fn_1+0x28dc>
    29e0: 52800000     	mov	w0, #0x0                ; =0
    29e4: 14000017     	b	0x2a40 <___pl_fn_1+0x2934>
    29e8: aa1603e1     	mov	x1, x22
    29ec: 34006721     	cbz	w1, 0x36d0 <___pl_fn_1+0x35c4>
    29f0: aa1903e0     	mov	x0, x25
    29f4: f9400001     	ldr	x1, [x0]
    29f8: aa1603e6     	mov	x6, x22
    29fc: 2a0603e0     	mov	w0, w6
    2a00: 8b000c20     	add	x0, x1, x0, lsl #3
    2a04: aa1603e9     	mov	x9, x22
    2a08: f8695821     	ldr	x1, [x1, w9, uxtw #3]
    2a0c: d360fc21     	lsr	x1, x1, #32
    2a10: 92403c21     	and	x1, x1, #0xffff
    2a14: 91001421     	add	x1, x1, #0x5
    2a18: d37df021     	lsl	x1, x1, #3
    2a1c: 38616800     	ldrb	w0, [x0, x1]
    2a20: 53001c01     	uxtb	w1, w0
    2a24: 7100083f     	cmp	w1, #0x2
    2a28: 540000c1     	b.ne	0x2a40 <___pl_fn_1+0x2934>
    2a2c: 14000329     	b	0x36d0 <___pl_fn_1+0x35c4>
    2a30: aa1903e0     	mov	x0, x25
    2a34: f9401800     	ldr	x0, [x0, #0x30]
    2a38: 14000002     	b	0x2a40 <___pl_fn_1+0x2934>
    2a3c: 52800020     	mov	w0, #0x1                ; =1
    2a40: 72001c1f     	tst	w0, #0xff
    2a44: 54000441     	b.ne	0x2acc <___pl_fn_1+0x29c0>
    2a48: aa1903e0     	mov	x0, x25
    2a4c: b9401815     	ldr	w21, [x0, #0x18]
    2a50: b9401c00     	ldr	w0, [x0, #0x1c]
    2a54: 11000ea1     	add	w1, w21, #0x3
    2a58: 6b00003f     	cmp	w1, w0
    2a5c: 54006808     	b.hi	0x375c <___pl_fn_1+0x3650>
    2a60: aa1903e0     	mov	x0, x25
    2a64: f9401000     	ldr	x0, [x0, #0x20]
    2a68: 2a1503e1     	mov	w1, w21
    2a6c: 8b010801     	add	x1, x0, x1, lsl #2
    2a70: aa1b03e2     	mov	x2, x27
    2a74: b8355802     	str	w2, [x0, w21, uxtw #2]
    2a78: b9000434     	str	w20, [x1, #0x4]
    2a7c: aa1603e0     	mov	x0, x22
    2a80: b9000820     	str	w0, [x1, #0x8]
    2a84: 11000ea0     	add	w0, w21, #0x3
    2a88: aa1903e1     	mov	x1, x25
    2a8c: b9001820     	str	w0, [x1, #0x18]
    2a90: aa1903e0     	mov	x0, x25
    2a94: b9401000     	ldr	w0, [x0, #0x10]
    2a98: b9401421     	ldr	w1, [x1, #0x14]
    2a9c: 6b01001f     	cmp	w0, w1
    2aa0: 54006442     	b.hs	0x3728 <___pl_fn_1+0x361c>
    2aa4: aa1603e1     	mov	x1, x22
    2aa8: aa1903e0     	mov	x0, x25
    2aac: 94000000     	bl	0x2aac <___pl_fn_1+0x29a0>
    2ab0: aa1903e1     	mov	x1, x25
    2ab4: b9402c21     	ldr	w1, [x1, #0x2c]
    2ab8: 3500b441     	cbnz	w1, 0x4140 <___pl_fn_1+0x4034>
    2abc: aa1903e1     	mov	x1, x25
    2ac0: b9001835     	str	w21, [x1, #0x18]
    2ac4: 34006180     	cbz	w0, 0x36f4 <___pl_fn_1+0x35e8>
    2ac8: 14000013     	b	0x2b14 <___pl_fn_1+0x2a08>
    2acc: aa1603e1     	mov	x1, x22
    2ad0: 34006601     	cbz	w1, 0x3790 <___pl_fn_1+0x3684>
    2ad4: aa1903e0     	mov	x0, x25
    2ad8: f9400002     	ldr	x2, [x0]
    2adc: aa1603e1     	mov	x1, x22
    2ae0: 2a0103e1     	mov	w1, w1
    2ae4: 8b010c41     	add	x1, x2, x1, lsl #3
    2ae8: aa1603e0     	mov	x0, x22
    2aec: f8605842     	ldr	x2, [x2, w0, uxtw #3]
    2af0: d360fc42     	lsr	x2, x2, #32
    2af4: 92403c42     	and	x2, x2, #0xffff
    2af8: d37df042     	lsl	x2, x2, #3
    2afc: b8626820     	ldr	w0, [x1, x2]
    2b00: 35000080     	cbnz	w0, 0x2b10 <___pl_fn_1+0x2a04>
    2b04: 14000323     	b	0x3790 <___pl_fn_1+0x3684>
    2b08: aa1903e0     	mov	x0, x25
    2b0c: f9401800     	ldr	x0, [x0, #0x30]
    2b10: 34006520     	cbz	w0, 0x37b4 <___pl_fn_1+0x36a8>
    2b14: aa0003f5     	mov	x21, x0
    2b18: 17ffff2f     	b	0x27d4 <___pl_fn_1+0x26c8>
    2b1c: 52800121     	mov	w1, #0x9                ; =9
    2b20: 52800022     	mov	w2, #0x1                ; =1
    2b24: 9000000d     	adrp	x13, 0x2000 <___pl_fn_1+0x1ef4>
    2b28: f94001ad     	ldr	x13, [x13]
    2b2c: aa1903e0     	mov	x0, x25
    2b30: d63f01a0     	blr	x13
    2b34: 34feb420     	cbz	w0, 0x1b8 <___pl_fn_1+0xac>
    2b38: 14000582     	b	0x4140 <___pl_fn_1+0x4034>
    2b3c: aa1903e0     	mov	x0, x25
    2b40: 1400000a     	b	0x2b68 <___pl_fn_1+0x2a5c>
    2b44: aa1903e0     	mov	x0, x25
    2b48: 14000008     	b	0x2b68 <___pl_fn_1+0x2a5c>
    2b4c: aa1903e0     	mov	x0, x25
    2b50: 14000006     	b	0x2b68 <___pl_fn_1+0x2a5c>
    2b54: aa1903e0     	mov	x0, x25
    2b58: 14000004     	b	0x2b68 <___pl_fn_1+0x2a5c>
    2b5c: aa1903e0     	mov	x0, x25
    2b60: 14000002     	b	0x2b68 <___pl_fn_1+0x2a5c>
    2b64: aa1903e0     	mov	x0, x25
    2b68: aa1903e0     	mov	x0, x25
    2b6c: b9401815     	ldr	w21, [x0, #0x18]
    2b70: b9401c01     	ldr	w1, [x0, #0x1c]
    2b74: 110006a0     	add	w0, w21, #0x1
    2b78: 6b01001f     	cmp	w0, w1
    2b7c: 54febc69     	b.ls	0x308 <___pl_fn_1+0x1fc>
    2b80: 52800161     	mov	w1, #0xb                ; =11
    2b84: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2b88: f9400042     	ldr	x2, [x2]
    2b8c: aa1903e0     	mov	x0, x25
    2b90: d63f0040     	blr	x2
    2b94: 910403ff     	add	sp, sp, #0x100
    2b98: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2b9c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2ba0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2ba4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2ba8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2bac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2bb0: d65f03c0     	ret
    2bb4: d2800000     	mov	x0, #0x0                ; =0
    2bb8: 910003e3     	mov	x3, sp
    2bbc: f80003e0     	stur	x0, [sp]
    2bc0: 2a1403e0     	mov	w0, w20
    2bc4: f80083e0     	stur	x0, [sp, #0x8]
    2bc8: 528001c1     	mov	w1, #0xe                ; =14
    2bcc: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2bd0: f9400084     	ldr	x4, [x4]
    2bd4: aa1903e0     	mov	x0, x25
    2bd8: aa1403e2     	mov	x2, x20
    2bdc: d63f0080     	blr	x4
    2be0: aa1403fc     	mov	x28, x20
    2be4: 34fec180     	cbz	w0, 0x414 <___pl_fn_1+0x308>
    2be8: 14000556     	b	0x4140 <___pl_fn_1+0x4034>
    2bec: aa1903e0     	mov	x0, x25
    2bf0: 1400000a     	b	0x2c18 <___pl_fn_1+0x2b0c>
    2bf4: aa1903e0     	mov	x0, x25
    2bf8: 14000008     	b	0x2c18 <___pl_fn_1+0x2b0c>
    2bfc: aa1903e0     	mov	x0, x25
    2c00: 14000006     	b	0x2c18 <___pl_fn_1+0x2b0c>
    2c04: aa1903e0     	mov	x0, x25
    2c08: 14000004     	b	0x2c18 <___pl_fn_1+0x2b0c>
    2c0c: aa1903e0     	mov	x0, x25
    2c10: 14000002     	b	0x2c18 <___pl_fn_1+0x2b0c>
    2c14: aa1903e0     	mov	x0, x25
    2c18: aa1903e0     	mov	x0, x25
    2c1c: b9401815     	ldr	w21, [x0, #0x18]
    2c20: b9401c00     	ldr	w0, [x0, #0x1c]
    2c24: 52800042     	mov	w2, #0x2                ; =2
    2c28: 11000aa1     	add	w1, w21, #0x2
    2c2c: 6b00003f     	cmp	w1, w0
    2c30: 54fec509     	b.ls	0x4d0 <___pl_fn_1+0x3c4>
    2c34: 528001e1     	mov	w1, #0xf                ; =15
    2c38: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2c3c: f9400042     	ldr	x2, [x2]
    2c40: aa1903e0     	mov	x0, x25
    2c44: d63f0040     	blr	x2
    2c48: 910403ff     	add	sp, sp, #0x100
    2c4c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2c50: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2c54: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2c58: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2c5c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2c60: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2c64: d65f03c0     	ret
    2c68: d280004f     	mov	x15, #0x2               ; =2
    2c6c: 910043e3     	add	x3, sp, #0x10
    2c70: f80103ef     	stur	x15, [sp, #0x10]
    2c74: aa1c03e5     	mov	x5, x28
    2c78: 2a0503e0     	mov	w0, w5
    2c7c: f80183e0     	stur	x0, [sp, #0x18]
    2c80: 52800241     	mov	w1, #0x12               ; =18
    2c84: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2c88: f9400084     	ldr	x4, [x4]
    2c8c: aa1903e0     	mov	x0, x25
    2c90: aa1b03e2     	mov	x2, x27
    2c94: d63f0080     	blr	x4
    2c98: 34feca40     	cbz	w0, 0x5e0 <___pl_fn_1+0x4d4>
    2c9c: 14000529     	b	0x4140 <___pl_fn_1+0x4034>
    2ca0: d2800020     	mov	x0, #0x1                ; =1
    2ca4: 910083e3     	add	x3, sp, #0x20
    2ca8: f80203e0     	stur	x0, [sp, #0x20]
    2cac: 2a1403e0     	mov	w0, w20
    2cb0: f80283e0     	stur	x0, [sp, #0x28]
    2cb4: 52800261     	mov	w1, #0x13               ; =19
    2cb8: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2cbc: f9400084     	ldr	x4, [x4]
    2cc0: aa1903e0     	mov	x0, x25
    2cc4: aa1b03e2     	mov	x2, x27
    2cc8: d63f0080     	blr	x4
    2ccc: 34fecae0     	cbz	w0, 0x628 <___pl_fn_1+0x51c>
    2cd0: 1400051c     	b	0x4140 <___pl_fn_1+0x4034>
    2cd4: d2800000     	mov	x0, #0x0                ; =0
    2cd8: 9100c3e3     	add	x3, sp, #0x30
    2cdc: f80303e0     	stur	x0, [sp, #0x30]
    2ce0: 2a1403e0     	mov	w0, w20
    2ce4: f80383e0     	stur	x0, [sp, #0x38]
    2ce8: 52800281     	mov	w1, #0x14               ; =20
    2cec: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2cf0: f9400084     	ldr	x4, [x4]
    2cf4: aa1903e0     	mov	x0, x25
    2cf8: aa1b03e2     	mov	x2, x27
    2cfc: d63f0080     	blr	x4
    2d00: 34fecb60     	cbz	w0, 0x66c <___pl_fn_1+0x560>
    2d04: 1400050f     	b	0x4140 <___pl_fn_1+0x4034>
    2d08: d2800120     	mov	x0, #0x9                ; =9
    2d0c: 910103e3     	add	x3, sp, #0x40
    2d10: f80403e0     	stur	x0, [sp, #0x40]
    2d14: d2800000     	mov	x0, #0x0                ; =0
    2d18: f80483e0     	stur	x0, [sp, #0x48]
    2d1c: 528002a1     	mov	w1, #0x15               ; =21
    2d20: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2d24: f9400084     	ldr	x4, [x4]
    2d28: aa1903e0     	mov	x0, x25
    2d2c: aa1b03e2     	mov	x2, x27
    2d30: d63f0080     	blr	x4
    2d34: 34fecbc0     	cbz	w0, 0x6ac <___pl_fn_1+0x5a0>
    2d38: 14000502     	b	0x4140 <___pl_fn_1+0x4034>
    2d3c: d2800140     	mov	x0, #0xa                ; =10
    2d40: 910143e3     	add	x3, sp, #0x50
    2d44: f80503e0     	stur	x0, [sp, #0x50]
    2d48: d2800000     	mov	x0, #0x0                ; =0
    2d4c: f80583e0     	stur	x0, [sp, #0x58]
    2d50: 528002c1     	mov	w1, #0x16               ; =22
    2d54: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2d58: f9400084     	ldr	x4, [x4]
    2d5c: aa1903e0     	mov	x0, x25
    2d60: aa1b03e2     	mov	x2, x27
    2d64: d63f0080     	blr	x4
    2d68: 34fecd00     	cbz	w0, 0x708 <___pl_fn_1+0x5fc>
    2d6c: 140004f5     	b	0x4140 <___pl_fn_1+0x4034>
    2d70: aa1903e0     	mov	x0, x25
    2d74: 1400000a     	b	0x2d9c <___pl_fn_1+0x2c90>
    2d78: aa1903e0     	mov	x0, x25
    2d7c: 14000008     	b	0x2d9c <___pl_fn_1+0x2c90>
    2d80: aa1903e0     	mov	x0, x25
    2d84: 14000006     	b	0x2d9c <___pl_fn_1+0x2c90>
    2d88: aa1903e0     	mov	x0, x25
    2d8c: 14000004     	b	0x2d9c <___pl_fn_1+0x2c90>
    2d90: aa1903e0     	mov	x0, x25
    2d94: 14000002     	b	0x2d9c <___pl_fn_1+0x2c90>
    2d98: aa1903e0     	mov	x0, x25
    2d9c: aa1903e0     	mov	x0, x25
    2da0: b9401816     	ldr	w22, [x0, #0x18]
    2da4: b9401c00     	ldr	w0, [x0, #0x1c]
    2da8: 11000ec1     	add	w1, w22, #0x3
    2dac: 6b00003f     	cmp	w1, w0
    2db0: 54fed109     	b.ls	0x7d0 <___pl_fn_1+0x6c4>
    2db4: 528002e1     	mov	w1, #0x17               ; =23
    2db8: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2dbc: f9400042     	ldr	x2, [x2]
    2dc0: aa1903e0     	mov	x0, x25
    2dc4: d63f0040     	blr	x2
    2dc8: 910403ff     	add	sp, sp, #0x100
    2dcc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2dd0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2dd4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2dd8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2ddc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2de0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2de4: d65f03c0     	ret
    2de8: d2800100     	mov	x0, #0x8                ; =8
    2dec: 910183e3     	add	x3, sp, #0x60
    2df0: f80603e0     	stur	x0, [sp, #0x60]
    2df4: d2800020     	mov	x0, #0x1                ; =1
    2df8: f80683e0     	stur	x0, [sp, #0x68]
    2dfc: 52800341     	mov	w1, #0x1a               ; =26
    2e00: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2e04: f9400084     	ldr	x4, [x4]
    2e08: aa1903e0     	mov	x0, x25
    2e0c: aa1503e2     	mov	x2, x21
    2e10: d63f0080     	blr	x4
    2e14: 34fed900     	cbz	w0, 0x934 <___pl_fn_1+0x828>
    2e18: 140004ca     	b	0x4140 <___pl_fn_1+0x4034>
    2e1c: d2800122     	mov	x2, #0x9                ; =9
    2e20: 9101c3e3     	add	x3, sp, #0x70
    2e24: f80703e2     	stur	x2, [sp, #0x70]
    2e28: f80783f3     	stur	x19, [sp, #0x78]
    2e2c: 52800361     	mov	w1, #0x1b               ; =27
    2e30: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    2e34: f9400084     	ldr	x4, [x4]
    2e38: aa1903e0     	mov	x0, x25
    2e3c: aa1503e2     	mov	x2, x21
    2e40: d63f0080     	blr	x4
    2e44: 34fed7c0     	cbz	w0, 0x93c <___pl_fn_1+0x830>
    2e48: 140004be     	b	0x4140 <___pl_fn_1+0x4034>
    2e4c: aa1903e0     	mov	x0, x25
    2e50: 1400000a     	b	0x2e78 <___pl_fn_1+0x2d6c>
    2e54: aa1903e0     	mov	x0, x25
    2e58: 14000008     	b	0x2e78 <___pl_fn_1+0x2d6c>
    2e5c: aa1903e0     	mov	x0, x25
    2e60: 14000006     	b	0x2e78 <___pl_fn_1+0x2d6c>
    2e64: aa1903e0     	mov	x0, x25
    2e68: 14000004     	b	0x2e78 <___pl_fn_1+0x2d6c>
    2e6c: aa1903e0     	mov	x0, x25
    2e70: 14000002     	b	0x2e78 <___pl_fn_1+0x2d6c>
    2e74: aa1903e0     	mov	x0, x25
    2e78: aa1903e0     	mov	x0, x25
    2e7c: b9401c01     	ldr	w1, [x0, #0x1c]
    2e80: 11000e60     	add	w0, w19, #0x3
    2e84: 6b01001f     	cmp	w0, w1
    2e88: 54fee0a9     	b.ls	0xa9c <___pl_fn_1+0x990>
    2e8c: 528003c1     	mov	w1, #0x1e               ; =30
    2e90: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2e94: f9400042     	ldr	x2, [x2]
    2e98: aa1903e0     	mov	x0, x25
    2e9c: d63f0040     	blr	x2
    2ea0: 910403ff     	add	sp, sp, #0x100
    2ea4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2ea8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2eac: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2eb0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2eb4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2eb8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2ebc: d65f03c0     	ret
    2ec0: 140004a0     	b	0x4140 <___pl_fn_1+0x4034>
    2ec4: aa1903e6     	mov	x6, x25
    2ec8: 1400000a     	b	0x2ef0 <___pl_fn_1+0x2de4>
    2ecc: aa1903e6     	mov	x6, x25
    2ed0: 14000008     	b	0x2ef0 <___pl_fn_1+0x2de4>
    2ed4: aa1903e6     	mov	x6, x25
    2ed8: 14000006     	b	0x2ef0 <___pl_fn_1+0x2de4>
    2edc: aa1903e6     	mov	x6, x25
    2ee0: 14000004     	b	0x2ef0 <___pl_fn_1+0x2de4>
    2ee4: aa1903e6     	mov	x6, x25
    2ee8: 14000002     	b	0x2ef0 <___pl_fn_1+0x2de4>
    2eec: aa1903e6     	mov	x6, x25
    2ef0: aa1903e6     	mov	x6, x25
    2ef4: b9401cc1     	ldr	w1, [x6, #0x1c]
    2ef8: 6b0102df     	cmp	w22, w1
    2efc: 54feecc9     	b.ls	0xc94 <___pl_fn_1+0xb88>
    2f00: 52800461     	mov	w1, #0x23               ; =35
    2f04: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2f08: f9400042     	ldr	x2, [x2]
    2f0c: aa1903e0     	mov	x0, x25
    2f10: d63f0040     	blr	x2
    2f14: 910403ff     	add	sp, sp, #0x100
    2f18: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2f1c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2f20: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2f24: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2f28: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2f2c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2f30: d65f03c0     	ret
    2f34: 14000483     	b	0x4140 <___pl_fn_1+0x4034>
    2f38: aa1903e1     	mov	x1, x25
    2f3c: 1400000a     	b	0x2f64 <___pl_fn_1+0x2e58>
    2f40: aa1903e1     	mov	x1, x25
    2f44: 14000008     	b	0x2f64 <___pl_fn_1+0x2e58>
    2f48: aa1903e1     	mov	x1, x25
    2f4c: 14000006     	b	0x2f64 <___pl_fn_1+0x2e58>
    2f50: aa1903e1     	mov	x1, x25
    2f54: 14000004     	b	0x2f64 <___pl_fn_1+0x2e58>
    2f58: aa1903e1     	mov	x1, x25
    2f5c: 14000002     	b	0x2f64 <___pl_fn_1+0x2e58>
    2f60: aa1903e1     	mov	x1, x25
    2f64: aa1903e1     	mov	x1, x25
    2f68: b9401c22     	ldr	w2, [x1, #0x1c]
    2f6c: 110012c1     	add	w1, w22, #0x4
    2f70: 6b02003f     	cmp	w1, w2
    2f74: 54fefa29     	b.ls	0xeb8 <___pl_fn_1+0xdac>
    2f78: 52800501     	mov	w1, #0x28               ; =40
    2f7c: 90000002     	adrp	x2, 0x2000 <___pl_fn_1+0x1ef4>
    2f80: f9400042     	ldr	x2, [x2]
    2f84: aa1903e0     	mov	x0, x25
    2f88: d63f0040     	blr	x2
    2f8c: 910403ff     	add	sp, sp, #0x100
    2f90: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2f94: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2f98: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2f9c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    2fa0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2fa4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2fa8: d65f03c0     	ret
    2fac: d280010c     	mov	x12, #0x8               ; =8
    2fb0: 910203e3     	add	x3, sp, #0x80
    2fb4: f80803ec     	stur	x12, [sp, #0x80]
    2fb8: d280006d     	mov	x13, #0x3               ; =3
    2fbc: f80883ed     	stur	x13, [sp, #0x88]
    2fc0: 52800561     	mov	w1, #0x2b               ; =43
    2fc4: 9000000e     	adrp	x14, 0x2000 <___pl_fn_1+0x1ef4>
    2fc8: f94001ce     	ldr	x14, [x14]
    2fcc: aa1903e0     	mov	x0, x25
    2fd0: aa1a03e2     	mov	x2, x26
    2fd4: d63f01c0     	blr	x14
    2fd8: aa1a03f6     	mov	x22, x26
    2fdc: 34ff01c0     	cbz	w0, 0x1014 <___pl_fn_1+0xf08>
    2fe0: 14000458     	b	0x4140 <___pl_fn_1+0x4034>
    2fe4: d2800120     	mov	x0, #0x9                ; =9
    2fe8: 910243e3     	add	x3, sp, #0x90
    2fec: f80903e0     	stur	x0, [sp, #0x90]
    2ff0: d2800000     	mov	x0, #0x0                ; =0
    2ff4: f80983e0     	stur	x0, [sp, #0x98]
    2ff8: 52800581     	mov	w1, #0x2c               ; =44
    2ffc: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1ef4>
    3000: f9400084     	ldr	x4, [x4]
    3004: aa1903e0     	mov	x0, x25
    3008: aa1603e2     	mov	x2, x22
    300c: d63f0080     	blr	x4
    3010: 34ff0060     	cbz	w0, 0x101c <___pl_fn_1+0xf10>
    3014: 1400044b     	b	0x4140 <___pl_fn_1+0x4034>
    3018: aa1903e0     	mov	x0, x25
    301c: 1400000a     	b	0x3044 <___pl_fn_1+0x2f38>
    3020: aa1903e0     	mov	x0, x25
    3024: 14000008     	b	0x3044 <___pl_fn_1+0x2f38>
    3028: aa1903e0     	mov	x0, x25
    302c: 14000006     	b	0x3044 <___pl_fn_1+0x2f38>
    3030: aa1903e0     	mov	x0, x25
    3034: 14000004     	b	0x3044 <___pl_fn_1+0x2f38>
    3038: aa1903e0     	mov	x0, x25
    303c: 14000002     	b	0x3044 <___pl_fn_1+0x2f38>
    3040: aa1903e0     	mov	x0, x25
    3044: aa1903e0     	mov	x0, x25
    3048: b9401c06     	ldr	w6, [x0, #0x1c]
    304c: 11000ec5     	add	w5, w22, #0x3
    3050: 6b0600bf     	cmp	w5, w6
    3054: 54ff09a9     	b.ls	0x1188 <___pl_fn_1+0x107c>
    3058: 528005e1     	mov	w1, #0x2f               ; =47
    305c: 9000000f     	adrp	x15, 0x3000 <___pl_fn_1+0x2ef4>
    3060: f94001ef     	ldr	x15, [x15]
    3064: aa1903e0     	mov	x0, x25
    3068: d63f01e0     	blr	x15
    306c: 910403ff     	add	sp, sp, #0x100
    3070: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3074: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3078: a8c163f7     	ldp	x23, x24, [sp], #0x10
    307c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3080: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3084: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3088: d65f03c0     	ret
    308c: 1400042d     	b	0x4140 <___pl_fn_1+0x4034>
    3090: aa1903ea     	mov	x10, x25
    3094: 1400000a     	b	0x30bc <___pl_fn_1+0x2fb0>
    3098: aa1903ea     	mov	x10, x25
    309c: 14000008     	b	0x30bc <___pl_fn_1+0x2fb0>
    30a0: aa1903ea     	mov	x10, x25
    30a4: 14000006     	b	0x30bc <___pl_fn_1+0x2fb0>
    30a8: aa1903ea     	mov	x10, x25
    30ac: 14000004     	b	0x30bc <___pl_fn_1+0x2fb0>
    30b0: aa1903ea     	mov	x10, x25
    30b4: 14000002     	b	0x30bc <___pl_fn_1+0x2fb0>
    30b8: aa1903ea     	mov	x10, x25
    30bc: aa1903ea     	mov	x10, x25
    30c0: b9401d42     	ldr	w2, [x10, #0x1c]
    30c4: 6b0202ff     	cmp	w23, w2
    30c8: 54ff1629     	b.ls	0x138c <___pl_fn_1+0x1280>
    30cc: 52800681     	mov	w1, #0x34               ; =52
    30d0: 9000000d     	adrp	x13, 0x3000 <___pl_fn_1+0x2ef4>
    30d4: f94001ad     	ldr	x13, [x13]
    30d8: aa1903e0     	mov	x0, x25
    30dc: d63f01a0     	blr	x13
    30e0: 910403ff     	add	sp, sp, #0x100
    30e4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    30e8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    30ec: a8c163f7     	ldp	x23, x24, [sp], #0x10
    30f0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    30f4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    30f8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    30fc: d65f03c0     	ret
    3100: 14000410     	b	0x4140 <___pl_fn_1+0x4034>
    3104: aa1903e1     	mov	x1, x25
    3108: 1400000a     	b	0x3130 <___pl_fn_1+0x3024>
    310c: aa1903e1     	mov	x1, x25
    3110: 14000008     	b	0x3130 <___pl_fn_1+0x3024>
    3114: aa1903e1     	mov	x1, x25
    3118: 14000006     	b	0x3130 <___pl_fn_1+0x3024>
    311c: aa1903e1     	mov	x1, x25
    3120: 14000004     	b	0x3130 <___pl_fn_1+0x3024>
    3124: aa1903e1     	mov	x1, x25
    3128: 14000002     	b	0x3130 <___pl_fn_1+0x3024>
    312c: aa1903e1     	mov	x1, x25
    3130: aa1903e1     	mov	x1, x25
    3134: b9401c22     	ldr	w2, [x1, #0x1c]
    3138: 110012c1     	add	w1, w22, #0x4
    313c: 6b02003f     	cmp	w1, w2
    3140: 54ff23a9     	b.ls	0x15b4 <___pl_fn_1+0x14a8>
    3144: 52800721     	mov	w1, #0x39               ; =57
    3148: 9000000c     	adrp	x12, 0x3000 <___pl_fn_1+0x2ef4>
    314c: f940018c     	ldr	x12, [x12]
    3150: aa1903e0     	mov	x0, x25
    3154: d63f0180     	blr	x12
    3158: 910403ff     	add	sp, sp, #0x100
    315c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3160: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3164: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3168: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    316c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3170: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3174: d65f03c0     	ret
    3178: 140003f2     	b	0x4140 <___pl_fn_1+0x4034>
    317c: aa1903e1     	mov	x1, x25
    3180: 1400000a     	b	0x31a8 <___pl_fn_1+0x309c>
    3184: aa1903e1     	mov	x1, x25
    3188: 14000008     	b	0x31a8 <___pl_fn_1+0x309c>
    318c: aa1903e1     	mov	x1, x25
    3190: 14000006     	b	0x31a8 <___pl_fn_1+0x309c>
    3194: aa1903e1     	mov	x1, x25
    3198: 14000004     	b	0x31a8 <___pl_fn_1+0x309c>
    319c: aa1903e1     	mov	x1, x25
    31a0: 14000002     	b	0x31a8 <___pl_fn_1+0x309c>
    31a4: aa1903e1     	mov	x1, x25
    31a8: aa1903e1     	mov	x1, x25
    31ac: b9401c22     	ldr	w2, [x1, #0x1c]
    31b0: 110012c1     	add	w1, w22, #0x4
    31b4: 6b02003f     	cmp	w1, w2
    31b8: 54ff30e9     	b.ls	0x17d4 <___pl_fn_1+0x16c8>
    31bc: 528007c1     	mov	w1, #0x3e               ; =62
    31c0: 9000000b     	adrp	x11, 0x3000 <___pl_fn_1+0x2ef4>
    31c4: f940016b     	ldr	x11, [x11]
    31c8: aa1903e0     	mov	x0, x25
    31cc: d63f0160     	blr	x11
    31d0: 910403ff     	add	sp, sp, #0x100
    31d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    31d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    31dc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    31e0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    31e4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    31e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    31ec: d65f03c0     	ret
    31f0: d2800100     	mov	x0, #0x8                ; =8
    31f4: 910283e3     	add	x3, sp, #0xa0
    31f8: f80a03e0     	stur	x0, [sp, #0xa0]
    31fc: aa1c03e5     	mov	x5, x28
    3200: 2a0503e0     	mov	w0, w5
    3204: f80a83e0     	stur	x0, [sp, #0xa8]
    3208: 52800821     	mov	w1, #0x41               ; =65
    320c: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2ef4>
    3210: f9400084     	ldr	x4, [x4]
    3214: aa1903e0     	mov	x0, x25
    3218: aa1703e2     	mov	x2, x23
    321c: d63f0080     	blr	x4
    3220: aa1703f6     	mov	x22, x23
    3224: 34ff3800     	cbz	w0, 0x1924 <___pl_fn_1+0x1818>
    3228: 140003c6     	b	0x4140 <___pl_fn_1+0x4034>
    322c: d2800120     	mov	x0, #0x9                ; =9
    3230: 9102c3e3     	add	x3, sp, #0xb0
    3234: f80b03e0     	stur	x0, [sp, #0xb0]
    3238: aa1c03e5     	mov	x5, x28
    323c: 2a0503e0     	mov	w0, w5
    3240: f80b83e0     	stur	x0, [sp, #0xb8]
    3244: 52800841     	mov	w1, #0x42               ; =66
    3248: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2ef4>
    324c: f9400084     	ldr	x4, [x4]
    3250: aa1903e0     	mov	x0, x25
    3254: aa1603e2     	mov	x2, x22
    3258: d63f0080     	blr	x4
    325c: 34ff3680     	cbz	w0, 0x192c <___pl_fn_1+0x1820>
    3260: 140003b8     	b	0x4140 <___pl_fn_1+0x4034>
    3264: aa1903e0     	mov	x0, x25
    3268: 1400000a     	b	0x3290 <___pl_fn_1+0x3184>
    326c: aa1903e0     	mov	x0, x25
    3270: 14000008     	b	0x3290 <___pl_fn_1+0x3184>
    3274: aa1903e0     	mov	x0, x25
    3278: 14000006     	b	0x3290 <___pl_fn_1+0x3184>
    327c: aa1903e0     	mov	x0, x25
    3280: 14000004     	b	0x3290 <___pl_fn_1+0x3184>
    3284: aa1903e0     	mov	x0, x25
    3288: 14000002     	b	0x3290 <___pl_fn_1+0x3184>
    328c: aa1903e0     	mov	x0, x25
    3290: aa1903e0     	mov	x0, x25
    3294: b9401c01     	ldr	w1, [x0, #0x1c]
    3298: 11000ec0     	add	w0, w22, #0x3
    329c: 6b01001f     	cmp	w0, w1
    32a0: 54ff3ee9     	b.ls	0x1a7c <___pl_fn_1+0x1970>
    32a4: 528008a1     	mov	w1, #0x45               ; =69
    32a8: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    32ac: f9400042     	ldr	x2, [x2]
    32b0: aa1903e0     	mov	x0, x25
    32b4: d63f0040     	blr	x2
    32b8: 910403ff     	add	sp, sp, #0x100
    32bc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    32c0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    32c4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    32c8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    32cc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    32d0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    32d4: d65f03c0     	ret
    32d8: 1400039a     	b	0x4140 <___pl_fn_1+0x4034>
    32dc: aa1903e1     	mov	x1, x25
    32e0: 1400000a     	b	0x3308 <___pl_fn_1+0x31fc>
    32e4: aa1903e1     	mov	x1, x25
    32e8: 14000008     	b	0x3308 <___pl_fn_1+0x31fc>
    32ec: aa1903e1     	mov	x1, x25
    32f0: 14000006     	b	0x3308 <___pl_fn_1+0x31fc>
    32f4: aa1903e1     	mov	x1, x25
    32f8: 14000004     	b	0x3308 <___pl_fn_1+0x31fc>
    32fc: aa1903e1     	mov	x1, x25
    3300: 14000002     	b	0x3308 <___pl_fn_1+0x31fc>
    3304: aa1903e1     	mov	x1, x25
    3308: aa1903e1     	mov	x1, x25
    330c: b9401c2f     	ldr	w15, [x1, #0x1c]
    3310: 6b0f02ff     	cmp	w23, w15
    3314: 54ff4b89     	b.ls	0x1c84 <___pl_fn_1+0x1b78>
    3318: 52800941     	mov	w1, #0x4a               ; =74
    331c: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3320: f9400042     	ldr	x2, [x2]
    3324: aa1903e0     	mov	x0, x25
    3328: d63f0040     	blr	x2
    332c: 910403ff     	add	sp, sp, #0x100
    3330: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3334: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3338: a8c163f7     	ldp	x23, x24, [sp], #0x10
    333c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3340: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3344: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3348: d65f03c0     	ret
    334c: 1400037d     	b	0x4140 <___pl_fn_1+0x4034>
    3350: aa1903e1     	mov	x1, x25
    3354: 1400000a     	b	0x337c <___pl_fn_1+0x3270>
    3358: aa1903e1     	mov	x1, x25
    335c: 14000008     	b	0x337c <___pl_fn_1+0x3270>
    3360: aa1903e1     	mov	x1, x25
    3364: 14000006     	b	0x337c <___pl_fn_1+0x3270>
    3368: aa1903e1     	mov	x1, x25
    336c: 14000004     	b	0x337c <___pl_fn_1+0x3270>
    3370: aa1903e1     	mov	x1, x25
    3374: 14000002     	b	0x337c <___pl_fn_1+0x3270>
    3378: aa1903e1     	mov	x1, x25
    337c: aa1903e1     	mov	x1, x25
    3380: b9401c2f     	ldr	w15, [x1, #0x1c]
    3384: 110012ce     	add	w14, w22, #0x4
    3388: 6b0f01df     	cmp	w14, w15
    338c: 54ff58c9     	b.ls	0x1ea4 <___pl_fn_1+0x1d98>
    3390: 528009e1     	mov	w1, #0x4f               ; =79
    3394: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3398: f9400042     	ldr	x2, [x2]
    339c: aa1903e0     	mov	x0, x25
    33a0: d63f0040     	blr	x2
    33a4: 910403ff     	add	sp, sp, #0x100
    33a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    33ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    33b0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    33b4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    33b8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    33bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    33c0: d65f03c0     	ret
    33c4: 1400035f     	b	0x4140 <___pl_fn_1+0x4034>
    33c8: aa1903e3     	mov	x3, x25
    33cc: 1400000a     	b	0x33f4 <___pl_fn_1+0x32e8>
    33d0: aa1903e3     	mov	x3, x25
    33d4: 14000008     	b	0x33f4 <___pl_fn_1+0x32e8>
    33d8: aa1903e3     	mov	x3, x25
    33dc: 14000006     	b	0x33f4 <___pl_fn_1+0x32e8>
    33e0: aa1903e3     	mov	x3, x25
    33e4: 14000004     	b	0x33f4 <___pl_fn_1+0x32e8>
    33e8: aa1903e3     	mov	x3, x25
    33ec: 14000002     	b	0x33f4 <___pl_fn_1+0x32e8>
    33f0: aa1903e3     	mov	x3, x25
    33f4: aa1903e3     	mov	x3, x25
    33f8: b9401c6e     	ldr	w14, [x3, #0x1c]
    33fc: 110012cd     	add	w13, w22, #0x4
    3400: 6b0e01bf     	cmp	w13, w14
    3404: 54ff65e9     	b.ls	0x20c0 <___pl_fn_1+0x1fb4>
    3408: 52800a81     	mov	w1, #0x54               ; =84
    340c: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3410: f9400042     	ldr	x2, [x2]
    3414: aa1903e0     	mov	x0, x25
    3418: d63f0040     	blr	x2
    341c: 910403ff     	add	sp, sp, #0x100
    3420: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3424: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3428: a8c163f7     	ldp	x23, x24, [sp], #0x10
    342c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3430: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3434: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3438: d65f03c0     	ret
    343c: d2800100     	mov	x0, #0x8                ; =8
    3440: 910303e3     	add	x3, sp, #0xc0
    3444: f80c03e0     	stur	x0, [sp, #0xc0]
    3448: aa1c03e5     	mov	x5, x28
    344c: 2a0503e0     	mov	w0, w5
    3450: f80c83e0     	stur	x0, [sp, #0xc8]
    3454: 52800ae1     	mov	w1, #0x57               ; =87
    3458: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2ef4>
    345c: f9400084     	ldr	x4, [x4]
    3460: aa1903e0     	mov	x0, x25
    3464: aa1703e2     	mov	x2, x23
    3468: d63f0080     	blr	x4
    346c: aa1703f6     	mov	x22, x23
    3470: 34ff6d20     	cbz	w0, 0x2214 <___pl_fn_1+0x2108>
    3474: 14000333     	b	0x4140 <___pl_fn_1+0x4034>
    3478: d2800120     	mov	x0, #0x9                ; =9
    347c: 910343e3     	add	x3, sp, #0xd0
    3480: f80d03e0     	stur	x0, [sp, #0xd0]
    3484: aa1c03e5     	mov	x5, x28
    3488: 2a0503e0     	mov	w0, w5
    348c: f80d83e0     	stur	x0, [sp, #0xd8]
    3490: 52800b01     	mov	w1, #0x58               ; =88
    3494: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2ef4>
    3498: f9400084     	ldr	x4, [x4]
    349c: aa1903e0     	mov	x0, x25
    34a0: aa1603e2     	mov	x2, x22
    34a4: d63f0080     	blr	x4
    34a8: 34ff6ba0     	cbz	w0, 0x221c <___pl_fn_1+0x2110>
    34ac: 14000325     	b	0x4140 <___pl_fn_1+0x4034>
    34b0: aa1903e0     	mov	x0, x25
    34b4: 1400000a     	b	0x34dc <___pl_fn_1+0x33d0>
    34b8: aa1903e0     	mov	x0, x25
    34bc: 14000008     	b	0x34dc <___pl_fn_1+0x33d0>
    34c0: aa1903e0     	mov	x0, x25
    34c4: 14000006     	b	0x34dc <___pl_fn_1+0x33d0>
    34c8: aa1903e0     	mov	x0, x25
    34cc: 14000004     	b	0x34dc <___pl_fn_1+0x33d0>
    34d0: aa1903e0     	mov	x0, x25
    34d4: 14000002     	b	0x34dc <___pl_fn_1+0x33d0>
    34d8: aa1903e0     	mov	x0, x25
    34dc: aa1903e0     	mov	x0, x25
    34e0: b9401c01     	ldr	w1, [x0, #0x1c]
    34e4: 52800062     	mov	w2, #0x3                ; =3
    34e8: 11000ec0     	add	w0, w22, #0x3
    34ec: 6b01001f     	cmp	w0, w1
    34f0: 54ff73c9     	b.ls	0x2368 <___pl_fn_1+0x225c>
    34f4: 52800b61     	mov	w1, #0x5b               ; =91
    34f8: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    34fc: f9400042     	ldr	x2, [x2]
    3500: aa1903e0     	mov	x0, x25
    3504: d63f0040     	blr	x2
    3508: 910403ff     	add	sp, sp, #0x100
    350c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3510: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3514: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3518: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    351c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3520: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3524: d65f03c0     	ret
    3528: d2800101     	mov	x1, #0x8                ; =8
    352c: 910383e3     	add	x3, sp, #0xe0
    3530: f80e03e1     	stur	x1, [sp, #0xe0]
    3534: aa1c03e5     	mov	x5, x28
    3538: 2a0503e2     	mov	w2, w5
    353c: f80e83e2     	stur	x2, [sp, #0xe8]
    3540: 52800bc1     	mov	w1, #0x5e               ; =94
    3544: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2ef4>
    3548: f9400084     	ldr	x4, [x4]
    354c: aa1903e0     	mov	x0, x25
    3550: aa1703e2     	mov	x2, x23
    3554: d63f0080     	blr	x4
    3558: aa1703e1     	mov	x1, x23
    355c: 34ff7920     	cbz	w0, 0x2480 <___pl_fn_1+0x2374>
    3560: 140002f8     	b	0x4140 <___pl_fn_1+0x4034>
    3564: aa1903e0     	mov	x0, x25
    3568: 1400000a     	b	0x3590 <___pl_fn_1+0x3484>
    356c: aa1903e0     	mov	x0, x25
    3570: 14000008     	b	0x3590 <___pl_fn_1+0x3484>
    3574: aa1903e0     	mov	x0, x25
    3578: 14000006     	b	0x3590 <___pl_fn_1+0x3484>
    357c: aa1903e0     	mov	x0, x25
    3580: 14000004     	b	0x3590 <___pl_fn_1+0x3484>
    3584: aa1903e0     	mov	x0, x25
    3588: 14000002     	b	0x3590 <___pl_fn_1+0x3484>
    358c: aa1903e0     	mov	x0, x25
    3590: aa1903e0     	mov	x0, x25
    3594: b9401c01     	ldr	w1, [x0, #0x1c]
    3598: 52800062     	mov	w2, #0x3                ; =3
    359c: 11000ec0     	add	w0, w22, #0x3
    35a0: 6b01001f     	cmp	w0, w1
    35a4: 54ff8089     	b.ls	0x25b4 <___pl_fn_1+0x24a8>
    35a8: 52800c21     	mov	w1, #0x61               ; =97
    35ac: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    35b0: f9400042     	ldr	x2, [x2]
    35b4: aa1903e0     	mov	x0, x25
    35b8: d63f0040     	blr	x2
    35bc: 910403ff     	add	sp, sp, #0x100
    35c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    35c4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    35c8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    35cc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    35d0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    35d4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    35d8: d65f03c0     	ret
    35dc: d2800108     	mov	x8, #0x8                ; =8
    35e0: 9103c3e3     	add	x3, sp, #0xf0
    35e4: f80f03e8     	stur	x8, [sp, #0xf0]
    35e8: aa1c03e5     	mov	x5, x28
    35ec: 2a0503e9     	mov	w9, w5
    35f0: f80f83e9     	stur	x9, [sp, #0xf8]
    35f4: 52800c81     	mov	w1, #0x64               ; =100
    35f8: 9000000a     	adrp	x10, 0x3000 <___pl_fn_1+0x2ef4>
    35fc: f940014a     	ldr	x10, [x10]
    3600: aa1903e0     	mov	x0, x25
    3604: aa1703e2     	mov	x2, x23
    3608: d63f0140     	blr	x10
    360c: aa1703e1     	mov	x1, x23
    3610: 34ff85a0     	cbz	w0, 0x26c4 <___pl_fn_1+0x25b8>
    3614: 140002cb     	b	0x4140 <___pl_fn_1+0x4034>
    3618: 52800ce1     	mov	w1, #0x67               ; =103
    361c: 52800003     	mov	w3, #0x0                ; =0
    3620: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2ef4>
    3624: f9400084     	ldr	x4, [x4]
    3628: aa1903e0     	mov	x0, x25
    362c: aa1b03e2     	mov	x2, x27
    3630: d63f0080     	blr	x4
    3634: 34ff8c80     	cbz	w0, 0x27c4 <___pl_fn_1+0x26b8>
    3638: 140002c2     	b	0x4140 <___pl_fn_1+0x4034>
    363c: 52800d21     	mov	w1, #0x69               ; =105
    3640: 52800143     	mov	w3, #0xa                ; =10
    3644: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2ef4>
    3648: f9400084     	ldr	x4, [x4]
    364c: aa1903e0     	mov	x0, x25
    3650: aa1b03e2     	mov	x2, x27
    3654: d63f0080     	blr	x4
    3658: 34ff8ea0     	cbz	w0, 0x282c <___pl_fn_1+0x2720>
    365c: 140002b9     	b	0x4140 <___pl_fn_1+0x4034>
    3660: 52800d41     	mov	w1, #0x6a               ; =106
    3664: 52800123     	mov	w3, #0x9                ; =9
    3668: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2ef4>
    366c: f9400084     	ldr	x4, [x4]
    3670: aa1b03e2     	mov	x2, x27
    3674: aa1903e0     	mov	x0, x25
    3678: d63f0080     	blr	x4
    367c: 34ff90c0     	cbz	w0, 0x2894 <___pl_fn_1+0x2788>
    3680: 140002b0     	b	0x4140 <___pl_fn_1+0x4034>
    3684: 52800dc1     	mov	w1, #0x6e               ; =110
    3688: 528000c3     	mov	w3, #0x6                ; =6
    368c: 9000000e     	adrp	x14, 0x3000 <___pl_fn_1+0x2ef4>
    3690: f94001ce     	ldr	x14, [x14]
    3694: aa1903e0     	mov	x0, x25
    3698: aa1503e2     	mov	x2, x21
    369c: d63f01c0     	blr	x14
    36a0: aa1503f6     	mov	x22, x21
    36a4: 34ff9640     	cbz	w0, 0x296c <___pl_fn_1+0x2860>
    36a8: 140002a6     	b	0x4140 <___pl_fn_1+0x4034>
    36ac: 52800de1     	mov	w1, #0x6f               ; =111
    36b0: 52800083     	mov	w3, #0x4                ; =4
    36b4: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2ef4>
    36b8: f9400084     	ldr	x4, [x4]
    36bc: aa1903e0     	mov	x0, x25
    36c0: aa1603e2     	mov	x2, x22
    36c4: d63f0080     	blr	x4
    36c8: 34ff9820     	cbz	w0, 0x29cc <___pl_fn_1+0x28c0>
    36cc: 1400029d     	b	0x4140 <___pl_fn_1+0x4034>
    36d0: 52800e01     	mov	w1, #0x70               ; =112
    36d4: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2ef4>
    36d8: f9400084     	ldr	x4, [x4]
    36dc: aa1903e0     	mov	x0, x25
    36e0: aa1603e2     	mov	x2, x22
    36e4: aa1303e3     	mov	x3, x19
    36e8: d63f0080     	blr	x4
    36ec: 34ff9a20     	cbz	w0, 0x2a30 <___pl_fn_1+0x2924>
    36f0: 14000294     	b	0x4140 <___pl_fn_1+0x4034>
    36f4: 52800e61     	mov	w1, #0x73               ; =115
    36f8: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    36fc: f9400042     	ldr	x2, [x2]
    3700: aa1903e0     	mov	x0, x25
    3704: d63f0040     	blr	x2
    3708: 910403ff     	add	sp, sp, #0x100
    370c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3710: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3714: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3718: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    371c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3720: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3724: d65f03c0     	ret
    3728: 52800e41     	mov	w1, #0x72               ; =114
    372c: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3730: f9400042     	ldr	x2, [x2]
    3734: aa1903e0     	mov	x0, x25
    3738: d63f0040     	blr	x2
    373c: 910403ff     	add	sp, sp, #0x100
    3740: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3744: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3748: a8c163f7     	ldp	x23, x24, [sp], #0x10
    374c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3750: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3754: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3758: d65f03c0     	ret
    375c: 52800e21     	mov	w1, #0x71               ; =113
    3760: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3764: f9400042     	ldr	x2, [x2]
    3768: aa1903e0     	mov	x0, x25
    376c: d63f0040     	blr	x2
    3770: 910403ff     	add	sp, sp, #0x100
    3774: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3778: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    377c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3780: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3784: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3788: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    378c: d65f03c0     	ret
    3790: 52800e81     	mov	w1, #0x74               ; =116
    3794: 52800003     	mov	w3, #0x0                ; =0
    3798: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2ef4>
    379c: f9400084     	ldr	x4, [x4]
    37a0: aa1603e2     	mov	x2, x22
    37a4: aa1903e0     	mov	x0, x25
    37a8: d63f0080     	blr	x4
    37ac: 34ff9ae0     	cbz	w0, 0x2b08 <___pl_fn_1+0x29fc>
    37b0: 14000264     	b	0x4140 <___pl_fn_1+0x4034>
    37b4: 52800ea1     	mov	w1, #0x75               ; =117
    37b8: 9000000a     	adrp	x10, 0x3000 <___pl_fn_1+0x2ef4>
    37bc: f940014a     	ldr	x10, [x10]
    37c0: aa1903e0     	mov	x0, x25
    37c4: d63f0140     	blr	x10
    37c8: 910403ff     	add	sp, sp, #0x100
    37cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    37d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    37d4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    37d8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    37dc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    37e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    37e4: d65f03c0     	ret
    37e8: 52800d01     	mov	w1, #0x68               ; =104
    37ec: 9000000b     	adrp	x11, 0x3000 <___pl_fn_1+0x2ef4>
    37f0: f940016b     	ldr	x11, [x11]
    37f4: aa1903e0     	mov	x0, x25
    37f8: d63f0160     	blr	x11
    37fc: 910403ff     	add	sp, sp, #0x100
    3800: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3804: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3808: a8c163f7     	ldp	x23, x24, [sp], #0x10
    380c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3810: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3814: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3818: d65f03c0     	ret
    381c: 52800cc1     	mov	w1, #0x66               ; =102
    3820: 9000000c     	adrp	x12, 0x3000 <___pl_fn_1+0x2ef4>
    3824: f940018c     	ldr	x12, [x12]
    3828: aa1903e0     	mov	x0, x25
    382c: d63f0180     	blr	x12
    3830: 910403ff     	add	sp, sp, #0x100
    3834: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3838: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    383c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3840: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3844: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3848: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    384c: d65f03c0     	ret
    3850: 52800ca1     	mov	w1, #0x65               ; =101
    3854: 9000000d     	adrp	x13, 0x3000 <___pl_fn_1+0x2ef4>
    3858: f94001ad     	ldr	x13, [x13]
    385c: aa1903e0     	mov	x0, x25
    3860: d63f01a0     	blr	x13
    3864: 910403ff     	add	sp, sp, #0x100
    3868: a8c153f3     	ldp	x19, x20, [sp], #0x10
    386c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3870: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3874: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3878: a8c173fb     	ldp	x27, x28, [sp], #0x10
    387c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3880: d65f03c0     	ret
    3884: 52800c61     	mov	w1, #0x63               ; =99
    3888: 9000000e     	adrp	x14, 0x3000 <___pl_fn_1+0x2ef4>
    388c: f94001ce     	ldr	x14, [x14]
    3890: aa1903e0     	mov	x0, x25
    3894: d63f01c0     	blr	x14
    3898: 910403ff     	add	sp, sp, #0x100
    389c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    38a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    38a4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    38a8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    38ac: a8c173fb     	ldp	x27, x28, [sp], #0x10
    38b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    38b4: d65f03c0     	ret
    38b8: 52800c01     	mov	w1, #0x60               ; =96
    38bc: 9000000f     	adrp	x15, 0x3000 <___pl_fn_1+0x2ef4>
    38c0: f94001ef     	ldr	x15, [x15]
    38c4: aa1903e0     	mov	x0, x25
    38c8: d63f01e0     	blr	x15
    38cc: 910403ff     	add	sp, sp, #0x100
    38d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    38d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    38d8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    38dc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    38e0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    38e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    38e8: d65f03c0     	ret
    38ec: 52800be1     	mov	w1, #0x5f               ; =95
    38f0: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    38f4: f9400042     	ldr	x2, [x2]
    38f8: aa1903e0     	mov	x0, x25
    38fc: d63f0040     	blr	x2
    3900: 910403ff     	add	sp, sp, #0x100
    3904: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3908: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    390c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3910: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3914: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3918: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    391c: d65f03c0     	ret
    3920: 52800ba1     	mov	w1, #0x5d               ; =93
    3924: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3928: f9400042     	ldr	x2, [x2]
    392c: aa1903e0     	mov	x0, x25
    3930: d63f0040     	blr	x2
    3934: 910403ff     	add	sp, sp, #0x100
    3938: a8c153f3     	ldp	x19, x20, [sp], #0x10
    393c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3940: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3944: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3948: a8c173fb     	ldp	x27, x28, [sp], #0x10
    394c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3950: d65f03c0     	ret
    3954: 52800b41     	mov	w1, #0x5a               ; =90
    3958: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    395c: f9400042     	ldr	x2, [x2]
    3960: aa1903e0     	mov	x0, x25
    3964: d63f0040     	blr	x2
    3968: 910403ff     	add	sp, sp, #0x100
    396c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3970: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3974: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3978: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    397c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3980: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3984: d65f03c0     	ret
    3988: 52800b21     	mov	w1, #0x59               ; =89
    398c: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3990: f9400042     	ldr	x2, [x2]
    3994: aa1903e0     	mov	x0, x25
    3998: d63f0040     	blr	x2
    399c: 910403ff     	add	sp, sp, #0x100
    39a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    39a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    39a8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    39ac: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    39b0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    39b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    39b8: d65f03c0     	ret
    39bc: 52800ac1     	mov	w1, #0x56               ; =86
    39c0: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    39c4: f9400042     	ldr	x2, [x2]
    39c8: aa1903e0     	mov	x0, x25
    39cc: d63f0040     	blr	x2
    39d0: 910403ff     	add	sp, sp, #0x100
    39d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    39d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    39dc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    39e0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    39e4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    39e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    39ec: d65f03c0     	ret
    39f0: 52800a61     	mov	w1, #0x53               ; =83
    39f4: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    39f8: f9400042     	ldr	x2, [x2]
    39fc: aa1903e0     	mov	x0, x25
    3a00: d63f0040     	blr	x2
    3a04: 910403ff     	add	sp, sp, #0x100
    3a08: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3a0c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3a10: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3a14: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3a18: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3a1c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3a20: d65f03c0     	ret
    3a24: 52800a41     	mov	w1, #0x52               ; =82
    3a28: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3a2c: f9400042     	ldr	x2, [x2]
    3a30: aa1903e0     	mov	x0, x25
    3a34: d63f0040     	blr	x2
    3a38: 910403ff     	add	sp, sp, #0x100
    3a3c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3a40: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3a44: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3a48: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3a4c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3a50: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3a54: d65f03c0     	ret
    3a58: 52800a21     	mov	w1, #0x51               ; =81
    3a5c: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3a60: f9400042     	ldr	x2, [x2]
    3a64: aa1903e0     	mov	x0, x25
    3a68: d63f0040     	blr	x2
    3a6c: 910403ff     	add	sp, sp, #0x100
    3a70: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3a74: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3a78: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3a7c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3a80: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3a84: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3a88: d65f03c0     	ret
    3a8c: 528009c1     	mov	w1, #0x4e               ; =78
    3a90: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3a94: f9400042     	ldr	x2, [x2]
    3a98: aa1903e0     	mov	x0, x25
    3a9c: d63f0040     	blr	x2
    3aa0: 910403ff     	add	sp, sp, #0x100
    3aa4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3aa8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3aac: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3ab0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3ab4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3ab8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3abc: d65f03c0     	ret
    3ac0: 528009a1     	mov	w1, #0x4d               ; =77
    3ac4: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3ac8: f9400042     	ldr	x2, [x2]
    3acc: aa1903e0     	mov	x0, x25
    3ad0: d63f0040     	blr	x2
    3ad4: 910403ff     	add	sp, sp, #0x100
    3ad8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3adc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3ae0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3ae4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3ae8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3aec: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3af0: d65f03c0     	ret
    3af4: 52800981     	mov	w1, #0x4c               ; =76
    3af8: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3afc: f9400042     	ldr	x2, [x2]
    3b00: aa1903e0     	mov	x0, x25
    3b04: d63f0040     	blr	x2
    3b08: 910403ff     	add	sp, sp, #0x100
    3b0c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3b10: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3b14: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3b18: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3b1c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3b20: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3b24: d65f03c0     	ret
    3b28: 52800921     	mov	w1, #0x49               ; =73
    3b2c: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3b30: f9400042     	ldr	x2, [x2]
    3b34: aa1903e0     	mov	x0, x25
    3b38: d63f0040     	blr	x2
    3b3c: 910403ff     	add	sp, sp, #0x100
    3b40: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3b44: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3b48: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3b4c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3b50: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3b54: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3b58: d65f03c0     	ret
    3b5c: 52800901     	mov	w1, #0x48               ; =72
    3b60: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3b64: f9400042     	ldr	x2, [x2]
    3b68: aa1903e0     	mov	x0, x25
    3b6c: d63f0040     	blr	x2
    3b70: 910403ff     	add	sp, sp, #0x100
    3b74: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3b78: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3b7c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3b80: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3b84: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3b88: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3b8c: d65f03c0     	ret
    3b90: 528008e1     	mov	w1, #0x47               ; =71
    3b94: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3b98: f9400042     	ldr	x2, [x2]
    3b9c: aa1903e0     	mov	x0, x25
    3ba0: d63f0040     	blr	x2
    3ba4: 910403ff     	add	sp, sp, #0x100
    3ba8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3bac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3bb0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3bb4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3bb8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3bbc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3bc0: d65f03c0     	ret
    3bc4: 52800881     	mov	w1, #0x44               ; =68
    3bc8: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3bcc: f9400042     	ldr	x2, [x2]
    3bd0: aa1903e0     	mov	x0, x25
    3bd4: d63f0040     	blr	x2
    3bd8: 910403ff     	add	sp, sp, #0x100
    3bdc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3be0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3be4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3be8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3bec: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3bf0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3bf4: d65f03c0     	ret
    3bf8: 52800861     	mov	w1, #0x43               ; =67
    3bfc: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3c00: f9400042     	ldr	x2, [x2]
    3c04: aa1903e0     	mov	x0, x25
    3c08: d63f0040     	blr	x2
    3c0c: 910403ff     	add	sp, sp, #0x100
    3c10: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3c14: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3c18: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3c1c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3c20: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3c24: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3c28: d65f03c0     	ret
    3c2c: 52800801     	mov	w1, #0x40               ; =64
    3c30: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3c34: f9400042     	ldr	x2, [x2]
    3c38: aa1903e0     	mov	x0, x25
    3c3c: d63f0040     	blr	x2
    3c40: 910403ff     	add	sp, sp, #0x100
    3c44: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3c48: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3c4c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3c50: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3c54: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3c58: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3c5c: d65f03c0     	ret
    3c60: 528007a1     	mov	w1, #0x3d               ; =61
    3c64: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3c68: f9400042     	ldr	x2, [x2]
    3c6c: aa1903e0     	mov	x0, x25
    3c70: d63f0040     	blr	x2
    3c74: 910403ff     	add	sp, sp, #0x100
    3c78: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3c7c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3c80: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3c84: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3c88: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3c8c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3c90: d65f03c0     	ret
    3c94: 52800781     	mov	w1, #0x3c               ; =60
    3c98: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3c9c: f9400042     	ldr	x2, [x2]
    3ca0: aa1903e0     	mov	x0, x25
    3ca4: d63f0040     	blr	x2
    3ca8: 910403ff     	add	sp, sp, #0x100
    3cac: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3cb0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3cb4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3cb8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3cbc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3cc0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3cc4: d65f03c0     	ret
    3cc8: 52800761     	mov	w1, #0x3b               ; =59
    3ccc: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3cd0: f9400042     	ldr	x2, [x2]
    3cd4: aa1903e0     	mov	x0, x25
    3cd8: d63f0040     	blr	x2
    3cdc: 910403ff     	add	sp, sp, #0x100
    3ce0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3ce4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3ce8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3cec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3cf0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3cf4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3cf8: d65f03c0     	ret
    3cfc: 52800701     	mov	w1, #0x38               ; =56
    3d00: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3d04: f9400042     	ldr	x2, [x2]
    3d08: aa1903e0     	mov	x0, x25
    3d0c: d63f0040     	blr	x2
    3d10: 910403ff     	add	sp, sp, #0x100
    3d14: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3d18: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3d1c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3d20: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3d24: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3d28: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3d2c: d65f03c0     	ret
    3d30: 528006e1     	mov	w1, #0x37               ; =55
    3d34: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3d38: f9400042     	ldr	x2, [x2]
    3d3c: aa1903e0     	mov	x0, x25
    3d40: d63f0040     	blr	x2
    3d44: 910403ff     	add	sp, sp, #0x100
    3d48: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3d4c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3d50: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3d54: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3d58: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3d5c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3d60: d65f03c0     	ret
    3d64: 528006c1     	mov	w1, #0x36               ; =54
    3d68: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3d6c: f9400042     	ldr	x2, [x2]
    3d70: aa1903e0     	mov	x0, x25
    3d74: d63f0040     	blr	x2
    3d78: 910403ff     	add	sp, sp, #0x100
    3d7c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3d80: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3d84: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3d88: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3d8c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3d90: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3d94: d65f03c0     	ret
    3d98: 52800661     	mov	w1, #0x33               ; =51
    3d9c: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3da0: f9400042     	ldr	x2, [x2]
    3da4: aa1903e0     	mov	x0, x25
    3da8: d63f0040     	blr	x2
    3dac: 910403ff     	add	sp, sp, #0x100
    3db0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3db4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3db8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3dbc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3dc0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3dc4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3dc8: d65f03c0     	ret
    3dcc: 52800641     	mov	w1, #0x32               ; =50
    3dd0: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3dd4: f9400042     	ldr	x2, [x2]
    3dd8: aa1903e0     	mov	x0, x25
    3ddc: d63f0040     	blr	x2
    3de0: 910403ff     	add	sp, sp, #0x100
    3de4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3de8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3dec: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3df0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3df4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3df8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3dfc: d65f03c0     	ret
    3e00: 52800621     	mov	w1, #0x31               ; =49
    3e04: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3e08: f9400042     	ldr	x2, [x2]
    3e0c: aa1903e0     	mov	x0, x25
    3e10: d63f0040     	blr	x2
    3e14: 910403ff     	add	sp, sp, #0x100
    3e18: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3e1c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3e20: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3e24: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3e28: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3e2c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3e30: d65f03c0     	ret
    3e34: 528005c1     	mov	w1, #0x2e               ; =46
    3e38: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3e3c: f9400042     	ldr	x2, [x2]
    3e40: aa1903e0     	mov	x0, x25
    3e44: d63f0040     	blr	x2
    3e48: 910403ff     	add	sp, sp, #0x100
    3e4c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3e50: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3e54: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3e58: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3e5c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3e60: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3e64: d65f03c0     	ret
    3e68: 528005a1     	mov	w1, #0x2d               ; =45
    3e6c: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3e70: f9400042     	ldr	x2, [x2]
    3e74: aa1903e0     	mov	x0, x25
    3e78: d63f0040     	blr	x2
    3e7c: 910403ff     	add	sp, sp, #0x100
    3e80: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3e84: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3e88: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3e8c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3e90: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3e94: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3e98: d65f03c0     	ret
    3e9c: 52800541     	mov	w1, #0x2a               ; =42
    3ea0: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3ea4: f9400042     	ldr	x2, [x2]
    3ea8: aa1903e0     	mov	x0, x25
    3eac: d63f0040     	blr	x2
    3eb0: 910403ff     	add	sp, sp, #0x100
    3eb4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3eb8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3ebc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3ec0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3ec4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3ec8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3ecc: d65f03c0     	ret
    3ed0: 528004e1     	mov	w1, #0x27               ; =39
    3ed4: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3ed8: f9400042     	ldr	x2, [x2]
    3edc: aa1903e0     	mov	x0, x25
    3ee0: d63f0040     	blr	x2
    3ee4: 910403ff     	add	sp, sp, #0x100
    3ee8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3eec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3ef0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3ef4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3ef8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3efc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3f00: d65f03c0     	ret
    3f04: 528004c1     	mov	w1, #0x26               ; =38
    3f08: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3f0c: f9400042     	ldr	x2, [x2]
    3f10: aa1903e0     	mov	x0, x25
    3f14: d63f0040     	blr	x2
    3f18: 910403ff     	add	sp, sp, #0x100
    3f1c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3f20: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3f24: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3f28: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3f2c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3f30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3f34: d65f03c0     	ret
    3f38: 528004a1     	mov	w1, #0x25               ; =37
    3f3c: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3f40: f9400042     	ldr	x2, [x2]
    3f44: aa1903e0     	mov	x0, x25
    3f48: d63f0040     	blr	x2
    3f4c: 910403ff     	add	sp, sp, #0x100
    3f50: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3f54: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3f58: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3f5c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3f60: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3f64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3f68: d65f03c0     	ret
    3f6c: 52800441     	mov	w1, #0x22               ; =34
    3f70: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3f74: f9400042     	ldr	x2, [x2]
    3f78: aa1903e0     	mov	x0, x25
    3f7c: d63f0040     	blr	x2
    3f80: 910403ff     	add	sp, sp, #0x100
    3f84: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3f88: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3f8c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3f90: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3f94: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3f98: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3f9c: d65f03c0     	ret
    3fa0: 52800421     	mov	w1, #0x21               ; =33
    3fa4: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3fa8: f9400042     	ldr	x2, [x2]
    3fac: aa1903e0     	mov	x0, x25
    3fb0: d63f0040     	blr	x2
    3fb4: 910403ff     	add	sp, sp, #0x100
    3fb8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3fbc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3fc0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3fc4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3fc8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3fcc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3fd0: d65f03c0     	ret
    3fd4: 52800401     	mov	w1, #0x20               ; =32
    3fd8: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2ef4>
    3fdc: f9400042     	ldr	x2, [x2]
    3fe0: aa1903e0     	mov	x0, x25
    3fe4: d63f0040     	blr	x2
    3fe8: 910403ff     	add	sp, sp, #0x100
    3fec: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3ff0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3ff4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3ff8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3ffc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4000: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4004: d65f03c0     	ret
    4008: 528003a1     	mov	w1, #0x1d               ; =29
    400c: 90000002     	adrp	x2, 0x4000 <___pl_fn_1+0x3ef4>
    4010: f9400042     	ldr	x2, [x2]
    4014: aa1903e0     	mov	x0, x25
    4018: d63f0040     	blr	x2
    401c: 910403ff     	add	sp, sp, #0x100
    4020: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4024: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4028: a8c163f7     	ldp	x23, x24, [sp], #0x10
    402c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4030: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4034: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4038: d65f03c0     	ret
    403c: 52800381     	mov	w1, #0x1c               ; =28
    4040: 90000002     	adrp	x2, 0x4000 <___pl_fn_1+0x3ef4>
    4044: f9400042     	ldr	x2, [x2]
    4048: aa1903e0     	mov	x0, x25
    404c: d63f0040     	blr	x2
    4050: 910403ff     	add	sp, sp, #0x100
    4054: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4058: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    405c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4060: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4064: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4068: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    406c: d65f03c0     	ret
    4070: 52800321     	mov	w1, #0x19               ; =25
    4074: 90000002     	adrp	x2, 0x4000 <___pl_fn_1+0x3ef4>
    4078: f9400042     	ldr	x2, [x2]
    407c: aa1903e0     	mov	x0, x25
    4080: d63f0040     	blr	x2
    4084: 910403ff     	add	sp, sp, #0x100
    4088: a8c153f3     	ldp	x19, x20, [sp], #0x10
    408c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4090: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4094: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4098: a8c173fb     	ldp	x27, x28, [sp], #0x10
    409c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    40a0: d65f03c0     	ret
    40a4: 52800221     	mov	w1, #0x11               ; =17
    40a8: 90000002     	adrp	x2, 0x4000 <___pl_fn_1+0x3ef4>
    40ac: f9400042     	ldr	x2, [x2]
    40b0: aa1903e0     	mov	x0, x25
    40b4: d63f0040     	blr	x2
    40b8: 910403ff     	add	sp, sp, #0x100
    40bc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    40c0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    40c4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    40c8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    40cc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    40d0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    40d4: d65f03c0     	ret
    40d8: 528001a1     	mov	w1, #0xd                ; =13
    40dc: 90000002     	adrp	x2, 0x4000 <___pl_fn_1+0x3ef4>
    40e0: f9400042     	ldr	x2, [x2]
    40e4: aa1903e0     	mov	x0, x25
    40e8: d63f0040     	blr	x2
    40ec: 910403ff     	add	sp, sp, #0x100
    40f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    40f4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    40f8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    40fc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4100: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4104: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4108: d65f03c0     	ret
    410c: 52800141     	mov	w1, #0xa                ; =10
    4110: 90000002     	adrp	x2, 0x4000 <___pl_fn_1+0x3ef4>
    4114: f9400042     	ldr	x2, [x2]
    4118: aa1903e0     	mov	x0, x25
    411c: d63f0040     	blr	x2
    4120: 910403ff     	add	sp, sp, #0x100
    4124: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4128: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    412c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4130: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4134: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4138: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    413c: d65f03c0     	ret
    4140: 910403ff     	add	sp, sp, #0x100
    4144: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4148: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    414c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4150: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4154: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4158: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    415c: d65f03c0     	ret

0000000000004160 <___pl_fn_2>:
    4160: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    4164: 910003fd     	mov	x29, sp
    4168: a9bf6ff5     	stp	x21, x27, [sp, #-0x10]!
    416c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    4170: d10203ff     	sub	sp, sp, #0x80
    4174: aa0103f3     	mov	x19, x1
    4178: aa0403f4     	mov	x20, x4
    417c: aa0303f5     	mov	x21, x3
    4180: b940100c     	ldr	w12, [x0, #0x10]
    4184: 1100058c     	add	w12, w12, #0x1
    4188: b900100c     	str	w12, [x0, #0x10]
    418c: aa0003e5     	mov	x5, x0
    4190: aa1303e1     	mov	x1, x19
    4194: 34001061     	cbz	w1, 0x43a0 <___pl_fn_2+0x240>
    4198: aa0503fb     	mov	x27, x5
    419c: f9400361     	ldr	x1, [x27]
    41a0: 2a1303e0     	mov	w0, w19
    41a4: 8b000c20     	add	x0, x1, x0, lsl #3
    41a8: f8735823     	ldr	x3, [x1, w19, uxtw #3]
    41ac: 2a0203e1     	mov	w1, w2
    41b0: d360fc62     	lsr	x2, x3, #32
    41b4: 92403c42     	and	x2, x2, #0xffff
    41b8: f8227801     	str	x1, [x0, x2, lsl #3]
    41bc: 340010f3     	cbz	w19, 0x43d8 <___pl_fn_2+0x278>
    41c0: aa1503e2     	mov	x2, x21
    41c4: f9400361     	ldr	x1, [x27]
    41c8: 2a1303e0     	mov	w0, w19
    41cc: 8b000c20     	add	x0, x1, x0, lsl #3
    41d0: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    41d4: d360fc21     	lsr	x1, x1, #32
    41d8: 92403c23     	and	x3, x1, #0xffff
    41dc: f100087f     	cmp	x3, #0x2
    41e0: 54000080     	b.eq	0x41f0 <___pl_fn_2+0x90>
    41e4: f9400803     	ldr	x3, [x0, #0x10]
    41e8: 927ef863     	and	x3, x3, #0xfffffffffffffffd
    41ec: f9000803     	str	x3, [x0, #0x10]
    41f0: 92403c21     	and	x1, x1, #0xffff
    41f4: 91000421     	add	x1, x1, #0x1
    41f8: f8217802     	str	x2, [x0, x1, lsl #3]
    41fc: 34001093     	cbz	w19, 0x440c <___pl_fn_2+0x2ac>
    4200: aa1403e4     	mov	x4, x20
    4204: f9400361     	ldr	x1, [x27]
    4208: 2a1303e0     	mov	w0, w19
    420c: 8b000c20     	add	x0, x1, x0, lsl #3
    4210: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    4214: d360fc21     	lsr	x1, x1, #32
    4218: 92403c22     	and	x2, x1, #0xffff
    421c: f100085f     	cmp	x2, #0x2
    4220: 54000080     	b.eq	0x4230 <___pl_fn_2+0xd0>
    4224: f9400802     	ldr	x2, [x0, #0x10]
    4228: 927df842     	and	x2, x2, #0xfffffffffffffffb
    422c: f9000802     	str	x2, [x0, #0x10]
    4230: 92403c21     	and	x1, x1, #0xffff
    4234: 91000821     	add	x1, x1, #0x2
    4238: f8217804     	str	x4, [x0, x1, lsl #3]
    423c: 34001033     	cbz	w19, 0x4440 <___pl_fn_2+0x2e0>
    4240: f9400361     	ldr	x1, [x27]
    4244: 2a1303e0     	mov	w0, w19
    4248: 8b000c20     	add	x0, x1, x0, lsl #3
    424c: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    4250: d360fc21     	lsr	x1, x1, #32
    4254: 92403c22     	and	x2, x1, #0xffff
    4258: f100085f     	cmp	x2, #0x2
    425c: 54000080     	b.eq	0x426c <___pl_fn_2+0x10c>
    4260: f9400802     	ldr	x2, [x0, #0x10]
    4264: 927cf842     	and	x2, x2, #0xfffffffffffffff7
    4268: f9000802     	str	x2, [x0, #0x10]
    426c: d2800002     	mov	x2, #0x0                ; =0
    4270: 92403c21     	and	x1, x1, #0xffff
    4274: 91000c21     	add	x1, x1, #0x3
    4278: f8217802     	str	x2, [x0, x1, lsl #3]
    427c: 34000fd3     	cbz	w19, 0x4474 <___pl_fn_2+0x314>
    4280: f9400365     	ldr	x5, [x27]
    4284: 2a1303e4     	mov	w4, w19
    4288: 8b040ca4     	add	x4, x5, x4, lsl #3
    428c: f87358a5     	ldr	x5, [x5, w19, uxtw #3]
    4290: d360fca5     	lsr	x5, x5, #32
    4294: 92403ca6     	and	x6, x5, #0xffff
    4298: f10008df     	cmp	x6, #0x2
    429c: 54000080     	b.eq	0x42ac <___pl_fn_2+0x14c>
    42a0: f9400887     	ldr	x7, [x4, #0x10]
    42a4: 927bf8e7     	and	x7, x7, #0xffffffffffffffef
    42a8: f9000887     	str	x7, [x4, #0x10]
    42ac: d2800009     	mov	x9, #0x0                ; =0
    42b0: 92403caa     	and	x10, x5, #0xffff
    42b4: 9100114a     	add	x10, x10, #0x4
    42b8: f82a7889     	str	x9, [x4, x10, lsl #3]
    42bc: 34000f73     	cbz	w19, 0x44a8 <___pl_fn_2+0x348>
    42c0: f9400361     	ldr	x1, [x27]
    42c4: 2a1303e0     	mov	w0, w19
    42c8: 8b000c20     	add	x0, x1, x0, lsl #3
    42cc: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    42d0: d360fc21     	lsr	x1, x1, #32
    42d4: 92403c22     	and	x2, x1, #0xffff
    42d8: f100085f     	cmp	x2, #0x2
    42dc: 54000080     	b.eq	0x42ec <___pl_fn_2+0x18c>
    42e0: f9400802     	ldr	x2, [x0, #0x10]
    42e4: 927af842     	and	x2, x2, #0xffffffffffffffdf
    42e8: f9000802     	str	x2, [x0, #0x10]
    42ec: d2800002     	mov	x2, #0x0                ; =0
    42f0: 92403c21     	and	x1, x1, #0xffff
    42f4: 91001421     	add	x1, x1, #0x5
    42f8: f8217802     	str	x2, [x0, x1, lsl #3]
    42fc: 34000f13     	cbz	w19, 0x44dc <___pl_fn_2+0x37c>
    4300: f9400361     	ldr	x1, [x27]
    4304: 2a1303e0     	mov	w0, w19
    4308: 8b000c20     	add	x0, x1, x0, lsl #3
    430c: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    4310: d360fc21     	lsr	x1, x1, #32
    4314: 92403c22     	and	x2, x1, #0xffff
    4318: f100085f     	cmp	x2, #0x2
    431c: 54000080     	b.eq	0x432c <___pl_fn_2+0x1cc>
    4320: f9400802     	ldr	x2, [x0, #0x10]
    4324: 9279f842     	and	x2, x2, #0xffffffffffffffbf
    4328: f9000802     	str	x2, [x0, #0x10]
    432c: d2800002     	mov	x2, #0x0                ; =0
    4330: 92403c21     	and	x1, x1, #0xffff
    4334: 91001821     	add	x1, x1, #0x6
    4338: f8217802     	str	x2, [x0, x1, lsl #3]
    433c: 34000eb3     	cbz	w19, 0x4510 <___pl_fn_2+0x3b0>
    4340: f9400361     	ldr	x1, [x27]
    4344: 2a1303e0     	mov	w0, w19
    4348: 8b000c20     	add	x0, x1, x0, lsl #3
    434c: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    4350: d360fc21     	lsr	x1, x1, #32
    4354: 92403c22     	and	x2, x1, #0xffff
    4358: f100085f     	cmp	x2, #0x2
    435c: 54000080     	b.eq	0x436c <___pl_fn_2+0x20c>
    4360: f9400802     	ldr	x2, [x0, #0x10]
    4364: 9278f842     	and	x2, x2, #0xffffffffffffff7f
    4368: f9000802     	str	x2, [x0, #0x10]
    436c: d2800002     	mov	x2, #0x0                ; =0
    4370: 92403c21     	and	x1, x1, #0xffff
    4374: 91001c21     	add	x1, x1, #0x7
    4378: f8217802     	str	x2, [x0, x1, lsl #3]
    437c: b9401360     	ldr	w0, [x27, #0x10]
    4380: 51000400     	sub	w0, w0, #0x1
    4384: b9001360     	str	w0, [x27, #0x10]
    4388: aa1303e0     	mov	x0, x19
    438c: 910203ff     	add	sp, sp, #0x80
    4390: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4394: a8c16ff5     	ldp	x21, x27, [sp], #0x10
    4398: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    439c: d65f03c0     	ret
    43a0: d280000f     	mov	x15, #0x0               ; =0
    43a4: 910003e3     	mov	x3, sp
    43a8: f80003ef     	stur	x15, [sp]
    43ac: 2a0203e0     	mov	w0, w2
    43b0: f80083e0     	stur	x0, [sp, #0x8]
    43b4: 52800ec1     	mov	w1, #0x76               ; =118
    43b8: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    43bc: f9400084     	ldr	x4, [x4]
    43c0: aa0503fb     	mov	x27, x5
    43c4: aa1b03e0     	mov	x0, x27
    43c8: aa1303e2     	mov	x2, x19
    43cc: d63f0080     	blr	x4
    43d0: 34ffef60     	cbz	w0, 0x41bc <___pl_fn_2+0x5c>
    43d4: 1400005b     	b	0x4540 <___pl_fn_2+0x3e0>
    43d8: d2800020     	mov	x0, #0x1                ; =1
    43dc: 910043e3     	add	x3, sp, #0x10
    43e0: f80103e0     	stur	x0, [sp, #0x10]
    43e4: aa1503e2     	mov	x2, x21
    43e8: f80183e2     	stur	x2, [sp, #0x18]
    43ec: 52800ee1     	mov	w1, #0x77               ; =119
    43f0: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    43f4: f9400084     	ldr	x4, [x4]
    43f8: aa1b03e0     	mov	x0, x27
    43fc: aa1303e2     	mov	x2, x19
    4400: d63f0080     	blr	x4
    4404: 34ffefc0     	cbz	w0, 0x41fc <___pl_fn_2+0x9c>
    4408: 1400004e     	b	0x4540 <___pl_fn_2+0x3e0>
    440c: d2800040     	mov	x0, #0x2                ; =2
    4410: 910083e3     	add	x3, sp, #0x20
    4414: f80203e0     	stur	x0, [sp, #0x20]
    4418: aa1403e4     	mov	x4, x20
    441c: f80283e4     	stur	x4, [sp, #0x28]
    4420: 52800f01     	mov	w1, #0x78               ; =120
    4424: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4428: f9400084     	ldr	x4, [x4]
    442c: aa1b03e0     	mov	x0, x27
    4430: aa1303e2     	mov	x2, x19
    4434: d63f0080     	blr	x4
    4438: 34fff020     	cbz	w0, 0x423c <___pl_fn_2+0xdc>
    443c: 14000041     	b	0x4540 <___pl_fn_2+0x3e0>
    4440: d2800060     	mov	x0, #0x3                ; =3
    4444: 9100c3e3     	add	x3, sp, #0x30
    4448: f80303e0     	stur	x0, [sp, #0x30]
    444c: d2800000     	mov	x0, #0x0                ; =0
    4450: f80383e0     	stur	x0, [sp, #0x38]
    4454: 52800f21     	mov	w1, #0x79               ; =121
    4458: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    445c: f9400084     	ldr	x4, [x4]
    4460: aa1b03e0     	mov	x0, x27
    4464: aa1303e2     	mov	x2, x19
    4468: d63f0080     	blr	x4
    446c: 34fff080     	cbz	w0, 0x427c <___pl_fn_2+0x11c>
    4470: 14000034     	b	0x4540 <___pl_fn_2+0x3e0>
    4474: d2800080     	mov	x0, #0x4                ; =4
    4478: 910103e3     	add	x3, sp, #0x40
    447c: f80403e0     	stur	x0, [sp, #0x40]
    4480: d2800000     	mov	x0, #0x0                ; =0
    4484: f80483e0     	stur	x0, [sp, #0x48]
    4488: 52800f41     	mov	w1, #0x7a               ; =122
    448c: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4490: f9400084     	ldr	x4, [x4]
    4494: aa1b03e0     	mov	x0, x27
    4498: aa1303e2     	mov	x2, x19
    449c: d63f0080     	blr	x4
    44a0: 34fff0e0     	cbz	w0, 0x42bc <___pl_fn_2+0x15c>
    44a4: 14000027     	b	0x4540 <___pl_fn_2+0x3e0>
    44a8: d28000ac     	mov	x12, #0x5               ; =5
    44ac: 910143e3     	add	x3, sp, #0x50
    44b0: f80503ec     	stur	x12, [sp, #0x50]
    44b4: d280000d     	mov	x13, #0x0               ; =0
    44b8: f80583ed     	stur	x13, [sp, #0x58]
    44bc: 52800f61     	mov	w1, #0x7b               ; =123
    44c0: 9000000e     	adrp	x14, 0x4000 <___pl_fn_1+0x3ef4>
    44c4: f94001ce     	ldr	x14, [x14]
    44c8: aa1b03e0     	mov	x0, x27
    44cc: aa1303e2     	mov	x2, x19
    44d0: d63f01c0     	blr	x14
    44d4: 34fff140     	cbz	w0, 0x42fc <___pl_fn_2+0x19c>
    44d8: 1400001a     	b	0x4540 <___pl_fn_2+0x3e0>
    44dc: d28000c0     	mov	x0, #0x6                ; =6
    44e0: 910183e3     	add	x3, sp, #0x60
    44e4: f80603e0     	stur	x0, [sp, #0x60]
    44e8: d2800000     	mov	x0, #0x0                ; =0
    44ec: f80683e0     	stur	x0, [sp, #0x68]
    44f0: 52800f81     	mov	w1, #0x7c               ; =124
    44f4: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    44f8: f9400084     	ldr	x4, [x4]
    44fc: aa1b03e0     	mov	x0, x27
    4500: aa1303e2     	mov	x2, x19
    4504: d63f0080     	blr	x4
    4508: 34fff1a0     	cbz	w0, 0x433c <___pl_fn_2+0x1dc>
    450c: 1400000d     	b	0x4540 <___pl_fn_2+0x3e0>
    4510: d28000e0     	mov	x0, #0x7                ; =7
    4514: 9101c3e3     	add	x3, sp, #0x70
    4518: f80703e0     	stur	x0, [sp, #0x70]
    451c: d2800000     	mov	x0, #0x0                ; =0
    4520: f80783e0     	stur	x0, [sp, #0x78]
    4524: 52800fa1     	mov	w1, #0x7d               ; =125
    4528: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    452c: f9400084     	ldr	x4, [x4]
    4530: aa1b03e0     	mov	x0, x27
    4534: aa1303e2     	mov	x2, x19
    4538: d63f0080     	blr	x4
    453c: 34fff200     	cbz	w0, 0x437c <___pl_fn_2+0x21c>
    4540: 52800000     	mov	w0, #0x0                ; =0
    4544: 910203ff     	add	sp, sp, #0x80
    4548: a8c153f3     	ldp	x19, x20, [sp], #0x10
    454c: a8c16ff5     	ldp	x21, x27, [sp], #0x10
    4550: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4554: d65f03c0     	ret

0000000000004558 <___pl_fn_3>:
    4558: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    455c: 910003fd     	mov	x29, sp
    4560: f81f0ff3     	str	x19, [sp, #-0x10]!
    4564: b940100b     	ldr	w11, [x0, #0x10]
    4568: 1100056b     	add	w11, w11, #0x1
    456c: b900100b     	str	w11, [x0, #0x10]
    4570: b40009a2     	cbz	x2, 0x46a4 <___pl_fn_3+0x14c>
    4574: f100045f     	cmp	x2, #0x1
    4578: 54000680     	b.eq	0x4648 <___pl_fn_3+0xf0>
    457c: f100085f     	cmp	x2, #0x2
    4580: 54000360     	b.eq	0x45ec <___pl_fn_3+0x94>
    4584: 34000be1     	cbz	w1, 0x4700 <___pl_fn_3+0x1a8>
    4588: f9400003     	ldr	x3, [x0]
    458c: aa0003ec     	mov	x12, x0
    4590: 2a0103e0     	mov	w0, w1
    4594: 8b000c62     	add	x2, x3, x0, lsl #3
    4598: f8615860     	ldr	x0, [x3, w1, uxtw #3]
    459c: aa0103ee     	mov	x14, x1
    45a0: d360fc00     	lsr	x0, x0, #32
    45a4: 92403c01     	and	x1, x0, #0xffff
    45a8: 91001c20     	add	x0, x1, #0x7
    45ac: f8607840     	ldr	x0, [x2, x0, lsl #3]
    45b0: f100083f     	cmp	x1, #0x2
    45b4: 54000061     	b.ne	0x45c0 <___pl_fn_3+0x68>
    45b8: aa0c03f3     	mov	x19, x12
    45bc: 14000006     	b	0x45d4 <___pl_fn_3+0x7c>
    45c0: f9400841     	ldr	x1, [x2, #0x10]
    45c4: 37380a21     	tbnz	w1, #0x7, 0x4708 <___pl_fn_3+0x1b0>
    45c8: aa0c03f3     	mov	x19, x12
    45cc: 14000002     	b	0x45d4 <___pl_fn_3+0x7c>
    45d0: f9401a60     	ldr	x0, [x19, #0x30]
    45d4: b9401261     	ldr	w1, [x19, #0x10]
    45d8: 51000421     	sub	w1, w1, #0x1
    45dc: b9001261     	str	w1, [x19, #0x10]
    45e0: f84107f3     	ldr	x19, [sp], #0x10
    45e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    45e8: d65f03c0     	ret
    45ec: aa0103e2     	mov	x2, x1
    45f0: aa0003f3     	mov	x19, x0
    45f4: 340009e2     	cbz	w2, 0x4730 <___pl_fn_3+0x1d8>
    45f8: f9400260     	ldr	x0, [x19]
    45fc: 2a0203e1     	mov	w1, w2
    4600: 8b010c01     	add	x1, x0, x1, lsl #3
    4604: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    4608: d360fc00     	lsr	x0, x0, #32
    460c: 92403c03     	and	x3, x0, #0xffff
    4610: 91001860     	add	x0, x3, #0x6
    4614: f8607820     	ldr	x0, [x1, x0, lsl #3]
    4618: f100087f     	cmp	x3, #0x2
    461c: 540000a0     	b.eq	0x4630 <___pl_fn_3+0xd8>
    4620: f9400821     	ldr	x1, [x1, #0x10]
    4624: 37300861     	tbnz	w1, #0x6, 0x4730 <___pl_fn_3+0x1d8>
    4628: 14000002     	b	0x4630 <___pl_fn_3+0xd8>
    462c: f9401a60     	ldr	x0, [x19, #0x30]
    4630: b9401261     	ldr	w1, [x19, #0x10]
    4634: 51000421     	sub	w1, w1, #0x1
    4638: b9001261     	str	w1, [x19, #0x10]
    463c: f84107f3     	ldr	x19, [sp], #0x10
    4640: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4644: d65f03c0     	ret
    4648: aa0103e2     	mov	x2, x1
    464c: aa0003f3     	mov	x19, x0
    4650: 34000802     	cbz	w2, 0x4750 <___pl_fn_3+0x1f8>
    4654: f9400260     	ldr	x0, [x19]
    4658: 2a0203e1     	mov	w1, w2
    465c: 8b010c01     	add	x1, x0, x1, lsl #3
    4660: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    4664: d360fc00     	lsr	x0, x0, #32
    4668: 92403c03     	and	x3, x0, #0xffff
    466c: 91001460     	add	x0, x3, #0x5
    4670: f8607820     	ldr	x0, [x1, x0, lsl #3]
    4674: f100087f     	cmp	x3, #0x2
    4678: 540000a0     	b.eq	0x468c <___pl_fn_3+0x134>
    467c: f9400821     	ldr	x1, [x1, #0x10]
    4680: 37280681     	tbnz	w1, #0x5, 0x4750 <___pl_fn_3+0x1f8>
    4684: 14000002     	b	0x468c <___pl_fn_3+0x134>
    4688: f9401a60     	ldr	x0, [x19, #0x30]
    468c: b9401261     	ldr	w1, [x19, #0x10]
    4690: 51000421     	sub	w1, w1, #0x1
    4694: b9001261     	str	w1, [x19, #0x10]
    4698: f84107f3     	ldr	x19, [sp], #0x10
    469c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    46a0: d65f03c0     	ret
    46a4: aa0103e2     	mov	x2, x1
    46a8: aa0003f3     	mov	x19, x0
    46ac: 34000622     	cbz	w2, 0x4770 <___pl_fn_3+0x218>
    46b0: f9400263     	ldr	x3, [x19]
    46b4: 2a0203e1     	mov	w1, w2
    46b8: 8b010c61     	add	x1, x3, x1, lsl #3
    46bc: f8625863     	ldr	x3, [x3, w2, uxtw #3]
    46c0: d360fc63     	lsr	x3, x3, #32
    46c4: 92403c63     	and	x3, x3, #0xffff
    46c8: 91001064     	add	x4, x3, #0x4
    46cc: f8647820     	ldr	x0, [x1, x4, lsl #3]
    46d0: f100087f     	cmp	x3, #0x2
    46d4: 540000a0     	b.eq	0x46e8 <___pl_fn_3+0x190>
    46d8: f9400824     	ldr	x4, [x1, #0x10]
    46dc: 372004a4     	tbnz	w4, #0x4, 0x4770 <___pl_fn_3+0x218>
    46e0: 14000002     	b	0x46e8 <___pl_fn_3+0x190>
    46e4: f9401a60     	ldr	x0, [x19, #0x30]
    46e8: b940126c     	ldr	w12, [x19, #0x10]
    46ec: 5100058c     	sub	w12, w12, #0x1
    46f0: b900126c     	str	w12, [x19, #0x10]
    46f4: f84107f3     	ldr	x19, [sp], #0x10
    46f8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    46fc: d65f03c0     	ret
    4700: aa0003ec     	mov	x12, x0
    4704: aa0103ee     	mov	x14, x1
    4708: 52800fc1     	mov	w1, #0x7e               ; =126
    470c: 528000e3     	mov	w3, #0x7                ; =7
    4710: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4714: f9400084     	ldr	x4, [x4]
    4718: aa0e03e2     	mov	x2, x14
    471c: aa0c03f3     	mov	x19, x12
    4720: aa1303e0     	mov	x0, x19
    4724: d63f0080     	blr	x4
    4728: 34fff540     	cbz	w0, 0x45d0 <___pl_fn_3+0x78>
    472c: 14000018     	b	0x478c <___pl_fn_3+0x234>
    4730: 52800fe1     	mov	w1, #0x7f               ; =127
    4734: 528000c3     	mov	w3, #0x6                ; =6
    4738: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    473c: f9400084     	ldr	x4, [x4]
    4740: aa1303e0     	mov	x0, x19
    4744: d63f0080     	blr	x4
    4748: 34fff720     	cbz	w0, 0x462c <___pl_fn_3+0xd4>
    474c: 14000010     	b	0x478c <___pl_fn_3+0x234>
    4750: 52801001     	mov	w1, #0x80               ; =128
    4754: 528000a3     	mov	w3, #0x5                ; =5
    4758: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    475c: f9400084     	ldr	x4, [x4]
    4760: aa1303e0     	mov	x0, x19
    4764: d63f0080     	blr	x4
    4768: 34fff900     	cbz	w0, 0x4688 <___pl_fn_3+0x130>
    476c: 14000008     	b	0x478c <___pl_fn_3+0x234>
    4770: 52801021     	mov	w1, #0x81               ; =129
    4774: 52800083     	mov	w3, #0x4                ; =4
    4778: 90000007     	adrp	x7, 0x4000 <___pl_fn_1+0x3ef4>
    477c: f94000e7     	ldr	x7, [x7]
    4780: aa1303e0     	mov	x0, x19
    4784: d63f00e0     	blr	x7
    4788: 34fffae0     	cbz	w0, 0x46e4 <___pl_fn_3+0x18c>
    478c: d2800000     	mov	x0, #0x0                ; =0
    4790: f84107f3     	ldr	x19, [sp], #0x10
    4794: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4798: d65f03c0     	ret

000000000000479c <___pl_fn_4>:
    479c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    47a0: 910003fd     	mov	x29, sp
    47a4: f81f0ff7     	str	x23, [sp, #-0x10]!
    47a8: d10103ff     	sub	sp, sp, #0x40
    47ac: aa0303ea     	mov	x10, x3
    47b0: b9401005     	ldr	w5, [x0, #0x10]
    47b4: 110004a5     	add	w5, w5, #0x1
    47b8: b9001005     	str	w5, [x0, #0x10]
    47bc: b40007c2     	cbz	x2, 0x48b4 <___pl_fn_4+0x118>
    47c0: f100045f     	cmp	x2, #0x1
    47c4: 54000520     	b.eq	0x4868 <___pl_fn_4+0xcc>
    47c8: f100085f     	cmp	x2, #0x2
    47cc: 54000280     	b.eq	0x481c <___pl_fn_4+0x80>
    47d0: 34000a41     	cbz	w1, 0x4918 <___pl_fn_4+0x17c>
    47d4: aa0103e2     	mov	x2, x1
    47d8: aa0a03e4     	mov	x4, x10
    47dc: aa0003f7     	mov	x23, x0
    47e0: f94002e1     	ldr	x1, [x23]
    47e4: 2a0203e0     	mov	w0, w2
    47e8: 8b000c20     	add	x0, x1, x0, lsl #3
    47ec: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    47f0: d360fc21     	lsr	x1, x1, #32
    47f4: 92403c22     	and	x2, x1, #0xffff
    47f8: f100085f     	cmp	x2, #0x2
    47fc: 54000080     	b.eq	0x480c <___pl_fn_4+0x70>
    4800: f9400802     	ldr	x2, [x0, #0x10]
    4804: 9278f842     	and	x2, x2, #0xffffffffffffff7f
    4808: f9000802     	str	x2, [x0, #0x10]
    480c: 92403c21     	and	x1, x1, #0xffff
    4810: 91001c21     	add	x1, x1, #0x7
    4814: f8217804     	str	x4, [x0, x1, lsl #3]
    4818: 14000039     	b	0x48fc <___pl_fn_4+0x160>
    481c: aa0103e2     	mov	x2, x1
    4820: aa0a03e4     	mov	x4, x10
    4824: aa0003f7     	mov	x23, x0
    4828: 34000942     	cbz	w2, 0x4950 <___pl_fn_4+0x1b4>
    482c: f94002e1     	ldr	x1, [x23]
    4830: 2a0203e0     	mov	w0, w2
    4834: 8b000c20     	add	x0, x1, x0, lsl #3
    4838: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    483c: d360fc21     	lsr	x1, x1, #32
    4840: 92403c22     	and	x2, x1, #0xffff
    4844: f100085f     	cmp	x2, #0x2
    4848: 54000080     	b.eq	0x4858 <___pl_fn_4+0xbc>
    484c: f9400802     	ldr	x2, [x0, #0x10]
    4850: 9279f842     	and	x2, x2, #0xffffffffffffffbf
    4854: f9000802     	str	x2, [x0, #0x10]
    4858: 92403c21     	and	x1, x1, #0xffff
    485c: 91001821     	add	x1, x1, #0x6
    4860: f8217804     	str	x4, [x0, x1, lsl #3]
    4864: 14000026     	b	0x48fc <___pl_fn_4+0x160>
    4868: aa0103e2     	mov	x2, x1
    486c: aa0a03e4     	mov	x4, x10
    4870: aa0003f7     	mov	x23, x0
    4874: 34000842     	cbz	w2, 0x497c <___pl_fn_4+0x1e0>
    4878: f94002e1     	ldr	x1, [x23]
    487c: 2a0203e0     	mov	w0, w2
    4880: 8b000c20     	add	x0, x1, x0, lsl #3
    4884: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    4888: d360fc21     	lsr	x1, x1, #32
    488c: 92403c22     	and	x2, x1, #0xffff
    4890: f100085f     	cmp	x2, #0x2
    4894: 54000080     	b.eq	0x48a4 <___pl_fn_4+0x108>
    4898: f9400802     	ldr	x2, [x0, #0x10]
    489c: 927af842     	and	x2, x2, #0xffffffffffffffdf
    48a0: f9000802     	str	x2, [x0, #0x10]
    48a4: 92403c21     	and	x1, x1, #0xffff
    48a8: 91001421     	add	x1, x1, #0x5
    48ac: f8217804     	str	x4, [x0, x1, lsl #3]
    48b0: 14000013     	b	0x48fc <___pl_fn_4+0x160>
    48b4: aa0103e2     	mov	x2, x1
    48b8: aa0a03e4     	mov	x4, x10
    48bc: aa0003f7     	mov	x23, x0
    48c0: 34000742     	cbz	w2, 0x49a8 <___pl_fn_4+0x20c>
    48c4: f94002e1     	ldr	x1, [x23]
    48c8: 2a0203e0     	mov	w0, w2
    48cc: 8b000c20     	add	x0, x1, x0, lsl #3
    48d0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    48d4: d360fc21     	lsr	x1, x1, #32
    48d8: 92403c22     	and	x2, x1, #0xffff
    48dc: f100085f     	cmp	x2, #0x2
    48e0: 54000080     	b.eq	0x48f0 <___pl_fn_4+0x154>
    48e4: f9400802     	ldr	x2, [x0, #0x10]
    48e8: 927bf842     	and	x2, x2, #0xffffffffffffffef
    48ec: f9000802     	str	x2, [x0, #0x10]
    48f0: 92403c25     	and	x5, x1, #0xffff
    48f4: 910010a5     	add	x5, x5, #0x4
    48f8: f8257804     	str	x4, [x0, x5, lsl #3]
    48fc: b94012e7     	ldr	w7, [x23, #0x10]
    4900: 510004e7     	sub	w7, w7, #0x1
    4904: b90012e7     	str	w7, [x23, #0x10]
    4908: 910103ff     	add	sp, sp, #0x40
    490c: f84107f7     	ldr	x23, [sp], #0x10
    4910: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4914: d65f03c0     	ret
    4918: aa0103e8     	mov	x8, x1
    491c: d28000ee     	mov	x14, #0x7               ; =7
    4920: 910003e3     	mov	x3, sp
    4924: f80003ee     	stur	x14, [sp]
    4928: aa0a03e4     	mov	x4, x10
    492c: f80083e4     	stur	x4, [sp, #0x8]
    4930: 52801041     	mov	w1, #0x82               ; =130
    4934: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4938: f9400084     	ldr	x4, [x4]
    493c: aa0803e2     	mov	x2, x8
    4940: aa0003f7     	mov	x23, x0
    4944: d63f0080     	blr	x4
    4948: 34fffda0     	cbz	w0, 0x48fc <___pl_fn_4+0x160>
    494c: 14000021     	b	0x49d0 <___pl_fn_4+0x234>
    4950: d28000c0     	mov	x0, #0x6                ; =6
    4954: 910043e3     	add	x3, sp, #0x10
    4958: f80103e0     	stur	x0, [sp, #0x10]
    495c: f80183e4     	stur	x4, [sp, #0x18]
    4960: 52801061     	mov	w1, #0x83               ; =131
    4964: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4968: f9400084     	ldr	x4, [x4]
    496c: aa1703e0     	mov	x0, x23
    4970: d63f0080     	blr	x4
    4974: 34fffc40     	cbz	w0, 0x48fc <___pl_fn_4+0x160>
    4978: 14000016     	b	0x49d0 <___pl_fn_4+0x234>
    497c: d28000a0     	mov	x0, #0x5                ; =5
    4980: 910083e3     	add	x3, sp, #0x20
    4984: f80203e0     	stur	x0, [sp, #0x20]
    4988: f80283e4     	stur	x4, [sp, #0x28]
    498c: 52801081     	mov	w1, #0x84               ; =132
    4990: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4994: f9400084     	ldr	x4, [x4]
    4998: aa1703e0     	mov	x0, x23
    499c: d63f0080     	blr	x4
    49a0: 34fffae0     	cbz	w0, 0x48fc <___pl_fn_4+0x160>
    49a4: 1400000b     	b	0x49d0 <___pl_fn_4+0x234>
    49a8: d2800080     	mov	x0, #0x4                ; =4
    49ac: 9100c3e3     	add	x3, sp, #0x30
    49b0: f80303e0     	stur	x0, [sp, #0x30]
    49b4: f80383e4     	stur	x4, [sp, #0x38]
    49b8: 528010a1     	mov	w1, #0x85               ; =133
    49bc: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    49c0: f9400084     	ldr	x4, [x4]
    49c4: aa1703e0     	mov	x0, x23
    49c8: d63f0080     	blr	x4
    49cc: 34fff980     	cbz	w0, 0x48fc <___pl_fn_4+0x160>
    49d0: 910103ff     	add	sp, sp, #0x40
    49d4: f84107f7     	ldr	x23, [sp], #0x10
    49d8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    49dc: d65f03c0     	ret

00000000000049e0 <___pl_fn_5>:
    49e0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    49e4: 910003fd     	mov	x29, sp
    49e8: f81f0ff7     	str	x23, [sp, #-0x10]!
    49ec: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    49f0: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    49f4: d10083ff     	sub	sp, sp, #0x20
    49f8: aa0303f3     	mov	x19, x3
    49fc: aa0103f4     	mov	x20, x1
    4a00: aa0203f6     	mov	x22, x2
    4a04: b940100b     	ldr	w11, [x0, #0x10]
    4a08: 1100056b     	add	w11, w11, #0x1
    4a0c: b900100b     	str	w11, [x0, #0x10]
    4a10: aa0003f5     	mov	x21, x0
    4a14: aa1403e1     	mov	x1, x20
    4a18: 35000081     	cbnz	w1, 0x4a28 <___pl_fn_5+0x48>
    4a1c: 1400005c     	b	0x4b8c <___pl_fn_5+0x1ac>
    4a20: aa1603e2     	mov	x2, x22
    4a24: 1400000b     	b	0x4a50 <___pl_fn_5+0x70>
    4a28: aa1503e0     	mov	x0, x21
    4a2c: f9400001     	ldr	x1, [x0]
    4a30: 2a1403e0     	mov	w0, w20
    4a34: 8b000c20     	add	x0, x1, x0, lsl #3
    4a38: f8745822     	ldr	x2, [x1, w20, uxtw #3]
    4a3c: 2a1303e1     	mov	w1, w19
    4a40: d360fc42     	lsr	x2, x2, #32
    4a44: 92403c42     	and	x2, x2, #0xffff
    4a48: f8227801     	str	x1, [x0, x2, lsl #3]
    4a4c: aa1603e2     	mov	x2, x22
    4a50: 6b13005f     	cmp	w2, w19
    4a54: 54000840     	b.eq	0x4b5c <___pl_fn_5+0x17c>
    4a58: 34001162     	cbz	w2, 0x4c84 <___pl_fn_5+0x2a4>
    4a5c: aa0203f6     	mov	x22, x2
    4a60: 34000b22     	cbz	w2, 0x4bc4 <___pl_fn_5+0x1e4>
    4a64: aa1503e0     	mov	x0, x21
    4a68: f9400001     	ldr	x1, [x0]
    4a6c: 2a0203e0     	mov	w0, w2
    4a70: 8b000c20     	add	x0, x1, x0, lsl #3
    4a74: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    4a78: aa0203f7     	mov	x23, x2
    4a7c: d360fc21     	lsr	x1, x1, #32
    4a80: 92403c21     	and	x1, x1, #0xffff
    4a84: d37df021     	lsl	x1, x1, #3
    4a88: b8616800     	ldr	w0, [x0, x1]
    4a8c: 35000080     	cbnz	w0, 0x4a9c <___pl_fn_5+0xbc>
    4a90: 1400004e     	b	0x4bc8 <___pl_fn_5+0x1e8>
    4a94: aa1503e0     	mov	x0, x21
    4a98: f9401800     	ldr	x0, [x0, #0x30]
    4a9c: 6b13001f     	cmp	w0, w19
    4aa0: 54000381     	b.ne	0x4b10 <___pl_fn_5+0x130>
    4aa4: aa1703e2     	mov	x2, x23
    4aa8: 35000082     	cbnz	w2, 0x4ab8 <___pl_fn_5+0xd8>
    4aac: 14000050     	b	0x4bec <___pl_fn_5+0x20c>
    4ab0: aa1503e0     	mov	x0, x21
    4ab4: 1400000b     	b	0x4ae0 <___pl_fn_5+0x100>
    4ab8: aa1503e0     	mov	x0, x21
    4abc: f9400001     	ldr	x1, [x0]
    4ac0: 2a0203e0     	mov	w0, w2
    4ac4: 8b000c20     	add	x0, x1, x0, lsl #3
    4ac8: f8625822     	ldr	x2, [x1, w2, uxtw #3]
    4acc: 2a1403e1     	mov	w1, w20
    4ad0: d360fc42     	lsr	x2, x2, #32
    4ad4: 92403c42     	and	x2, x2, #0xffff
    4ad8: f8227801     	str	x1, [x0, x2, lsl #3]
    4adc: aa1503e0     	mov	x0, x21
    4ae0: aa1503e0     	mov	x0, x21
    4ae4: b9401000     	ldr	w0, [x0, #0x10]
    4ae8: 51000400     	sub	w0, w0, #0x1
    4aec: aa1503e1     	mov	x1, x21
    4af0: b9001020     	str	w0, [x1, #0x10]
    4af4: aa1603e0     	mov	x0, x22
    4af8: 910083ff     	add	sp, sp, #0x20
    4afc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4b00: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4b04: f84107f7     	ldr	x23, [sp], #0x10
    4b08: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4b0c: d65f03c0     	ret
    4b10: aa1703e2     	mov	x2, x23
    4b14: 34000842     	cbz	w2, 0x4c1c <___pl_fn_5+0x23c>
    4b18: aa1503e0     	mov	x0, x21
    4b1c: f9400001     	ldr	x1, [x0]
    4b20: 2a0203e0     	mov	w0, w2
    4b24: 8b000c20     	add	x0, x1, x0, lsl #3
    4b28: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    4b2c: d360fc21     	lsr	x1, x1, #32
    4b30: 92403c21     	and	x1, x1, #0xffff
    4b34: d37df021     	lsl	x1, x1, #3
    4b38: b8616800     	ldr	w0, [x0, x1]
    4b3c: 350000a0     	cbnz	w0, 0x4b50 <___pl_fn_5+0x170>
    4b40: 14000037     	b	0x4c1c <___pl_fn_5+0x23c>
    4b44: aa1503e0     	mov	x0, x21
    4b48: f9401802     	ldr	x2, [x0, #0x30]
    4b4c: 14000002     	b	0x4b54 <___pl_fn_5+0x174>
    4b50: aa0003e2     	mov	x2, x0
    4b54: 34000802     	cbz	w2, 0x4c54 <___pl_fn_5+0x274>
    4b58: 17ffffc2     	b	0x4a60 <___pl_fn_5+0x80>
    4b5c: aa1503e0     	mov	x0, x21
    4b60: b9401000     	ldr	w0, [x0, #0x10]
    4b64: 51000400     	sub	w0, w0, #0x1
    4b68: aa1503e1     	mov	x1, x21
    4b6c: b9001020     	str	w0, [x1, #0x10]
    4b70: aa1403e0     	mov	x0, x20
    4b74: 910083ff     	add	sp, sp, #0x20
    4b78: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4b7c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4b80: f84107f7     	ldr	x23, [sp], #0x10
    4b84: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4b88: d65f03c0     	ret
    4b8c: d280000e     	mov	x14, #0x0               ; =0
    4b90: 910003e3     	mov	x3, sp
    4b94: f80003ee     	stur	x14, [sp]
    4b98: aa1303e0     	mov	x0, x19
    4b9c: 2a0003ef     	mov	w15, w0
    4ba0: f80083ef     	stur	x15, [sp, #0x8]
    4ba4: 528010c1     	mov	w1, #0x86               ; =134
    4ba8: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4bac: f9400084     	ldr	x4, [x4]
    4bb0: aa1503e0     	mov	x0, x21
    4bb4: aa1403e2     	mov	x2, x20
    4bb8: d63f0080     	blr	x4
    4bbc: 34fff320     	cbz	w0, 0x4a20 <___pl_fn_5+0x40>
    4bc0: 1400001e     	b	0x4c38 <___pl_fn_5+0x258>
    4bc4: aa0203f7     	mov	x23, x2
    4bc8: 52801101     	mov	w1, #0x88               ; =136
    4bcc: 52800003     	mov	w3, #0x0                ; =0
    4bd0: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4bd4: f9400084     	ldr	x4, [x4]
    4bd8: aa1503e0     	mov	x0, x21
    4bdc: aa1703e2     	mov	x2, x23
    4be0: d63f0080     	blr	x4
    4be4: 34fff580     	cbz	w0, 0x4a94 <___pl_fn_5+0xb4>
    4be8: 14000014     	b	0x4c38 <___pl_fn_5+0x258>
    4bec: d2800000     	mov	x0, #0x0                ; =0
    4bf0: 910043e3     	add	x3, sp, #0x10
    4bf4: f80103e0     	stur	x0, [sp, #0x10]
    4bf8: 2a1403e0     	mov	w0, w20
    4bfc: f80183e0     	stur	x0, [sp, #0x18]
    4c00: 52801121     	mov	w1, #0x89               ; =137
    4c04: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4c08: f9400084     	ldr	x4, [x4]
    4c0c: aa1503e0     	mov	x0, x21
    4c10: d63f0080     	blr	x4
    4c14: 34fff4e0     	cbz	w0, 0x4ab0 <___pl_fn_5+0xd0>
    4c18: 14000008     	b	0x4c38 <___pl_fn_5+0x258>
    4c1c: 52801141     	mov	w1, #0x8a               ; =138
    4c20: 52800003     	mov	w3, #0x0                ; =0
    4c24: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4c28: f9400084     	ldr	x4, [x4]
    4c2c: aa1503e0     	mov	x0, x21
    4c30: d63f0080     	blr	x4
    4c34: 34fff880     	cbz	w0, 0x4b44 <___pl_fn_5+0x164>
    4c38: 52800000     	mov	w0, #0x0                ; =0
    4c3c: 910083ff     	add	sp, sp, #0x20
    4c40: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4c44: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4c48: f84107f7     	ldr	x23, [sp], #0x10
    4c4c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4c50: d65f03c0     	ret
    4c54: 52801161     	mov	w1, #0x8b               ; =139
    4c58: 90000002     	adrp	x2, 0x4000 <___pl_fn_1+0x3ef4>
    4c5c: f9400042     	ldr	x2, [x2]
    4c60: aa1503e0     	mov	x0, x21
    4c64: d63f0040     	blr	x2
    4c68: 52800000     	mov	w0, #0x0                ; =0
    4c6c: 910083ff     	add	sp, sp, #0x20
    4c70: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4c74: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4c78: f84107f7     	ldr	x23, [sp], #0x10
    4c7c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4c80: d65f03c0     	ret
    4c84: 528010e1     	mov	w1, #0x87               ; =135
    4c88: 90000002     	adrp	x2, 0x4000 <___pl_fn_1+0x3ef4>
    4c8c: f9400042     	ldr	x2, [x2]
    4c90: aa1503e0     	mov	x0, x21
    4c94: d63f0040     	blr	x2
    4c98: 52800000     	mov	w0, #0x0                ; =0
    4c9c: 910083ff     	add	sp, sp, #0x20
    4ca0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4ca4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4ca8: f84107f7     	ldr	x23, [sp], #0x10
    4cac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4cb0: d65f03c0     	ret

0000000000004cb4 <___pl_fn_6>:
    4cb4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    4cb8: 910003fd     	mov	x29, sp
    4cbc: f81f0ff3     	str	x19, [sp, #-0x10]!
    4cc0: d10183ff     	sub	sp, sp, #0x60
    4cc4: aa0303e4     	mov	x4, x3
    4cc8: b9401003     	ldr	w3, [x0, #0x10]
    4ccc: 11000463     	add	w3, w3, #0x1
    4cd0: b9001003     	str	w3, [x0, #0x10]
    4cd4: aa0003e5     	mov	x5, x0
    4cd8: f100045f     	cmp	x2, #0x1
    4cdc: 540009e0     	b.eq	0x4e18 <___pl_fn_6+0x164>
    4ce0: f100085f     	cmp	x2, #0x2
    4ce4: 540007e0     	b.eq	0x4de0 <___pl_fn_6+0x12c>
    4ce8: f1000c5f     	cmp	x2, #0x3
    4cec: 540005e0     	b.eq	0x4da8 <___pl_fn_6+0xf4>
    4cf0: f100105f     	cmp	x2, #0x4
    4cf4: 540003e0     	b.eq	0x4d70 <___pl_fn_6+0xbc>
    4cf8: f100145f     	cmp	x2, #0x5
    4cfc: 540001e0     	b.eq	0x4d38 <___pl_fn_6+0x84>
    4d00: 34000b41     	cbz	w1, 0x4e68 <___pl_fn_6+0x1b4>
    4d04: aa0403e0     	mov	x0, x4
    4d08: aa0103e2     	mov	x2, x1
    4d0c: aa0503f3     	mov	x19, x5
    4d10: f9400263     	ldr	x3, [x19]
    4d14: 2a0203e1     	mov	w1, w2
    4d18: 8b010c61     	add	x1, x3, x1, lsl #3
    4d1c: f8625862     	ldr	x2, [x3, w2, uxtw #3]
    4d20: 2a0003e0     	mov	w0, w0
    4d24: d360fc42     	lsr	x2, x2, #32
    4d28: 92403c42     	and	x2, x2, #0xffff
    4d2c: 91002042     	add	x2, x2, #0x8
    4d30: f8227820     	str	x0, [x1, x2, lsl #3]
    4d34: 14000046     	b	0x4e4c <___pl_fn_6+0x198>
    4d38: aa0403e0     	mov	x0, x4
    4d3c: aa0103e2     	mov	x2, x1
    4d40: aa0503f3     	mov	x19, x5
    4d44: 34000b02     	cbz	w2, 0x4ea4 <___pl_fn_6+0x1f0>
    4d48: f9400263     	ldr	x3, [x19]
    4d4c: 2a0203e1     	mov	w1, w2
    4d50: 8b010c61     	add	x1, x3, x1, lsl #3
    4d54: f8625862     	ldr	x2, [x3, w2, uxtw #3]
    4d58: 2a0003e0     	mov	w0, w0
    4d5c: d360fc42     	lsr	x2, x2, #32
    4d60: 92403c42     	and	x2, x2, #0xffff
    4d64: 91001c42     	add	x2, x2, #0x7
    4d68: f8227820     	str	x0, [x1, x2, lsl #3]
    4d6c: 14000038     	b	0x4e4c <___pl_fn_6+0x198>
    4d70: aa0403e0     	mov	x0, x4
    4d74: aa0103e2     	mov	x2, x1
    4d78: aa0503f3     	mov	x19, x5
    4d7c: 34000ac2     	cbz	w2, 0x4ed4 <___pl_fn_6+0x220>
    4d80: f9400264     	ldr	x4, [x19]
    4d84: 2a0203e3     	mov	w3, w2
    4d88: 8b030c83     	add	x3, x4, x3, lsl #3
    4d8c: f8625885     	ldr	x5, [x4, w2, uxtw #3]
    4d90: 2a0003e4     	mov	w4, w0
    4d94: d360fca5     	lsr	x5, x5, #32
    4d98: 92403ca5     	and	x5, x5, #0xffff
    4d9c: 910018a5     	add	x5, x5, #0x6
    4da0: f8257864     	str	x4, [x3, x5, lsl #3]
    4da4: 1400002a     	b	0x4e4c <___pl_fn_6+0x198>
    4da8: aa0403e0     	mov	x0, x4
    4dac: aa0103e2     	mov	x2, x1
    4db0: aa0503f3     	mov	x19, x5
    4db4: 34000a82     	cbz	w2, 0x4f04 <___pl_fn_6+0x250>
    4db8: f940026d     	ldr	x13, [x19]
    4dbc: 2a0203ec     	mov	w12, w2
    4dc0: 8b0c0dac     	add	x12, x13, x12, lsl #3
    4dc4: f86259ae     	ldr	x14, [x13, w2, uxtw #3]
    4dc8: 2a0003ed     	mov	w13, w0
    4dcc: d360fdce     	lsr	x14, x14, #32
    4dd0: 92403dce     	and	x14, x14, #0xffff
    4dd4: 910015ce     	add	x14, x14, #0x5
    4dd8: f82e798d     	str	x13, [x12, x14, lsl #3]
    4ddc: 1400001c     	b	0x4e4c <___pl_fn_6+0x198>
    4de0: aa0403e0     	mov	x0, x4
    4de4: aa0103e2     	mov	x2, x1
    4de8: aa0503f3     	mov	x19, x5
    4dec: 34000a42     	cbz	w2, 0x4f34 <___pl_fn_6+0x280>
    4df0: f9400263     	ldr	x3, [x19]
    4df4: 2a0203e1     	mov	w1, w2
    4df8: 8b010c61     	add	x1, x3, x1, lsl #3
    4dfc: f8625862     	ldr	x2, [x3, w2, uxtw #3]
    4e00: 2a0003e0     	mov	w0, w0
    4e04: d360fc42     	lsr	x2, x2, #32
    4e08: 92403c42     	and	x2, x2, #0xffff
    4e0c: 91001042     	add	x2, x2, #0x4
    4e10: f8227820     	str	x0, [x1, x2, lsl #3]
    4e14: 1400000e     	b	0x4e4c <___pl_fn_6+0x198>
    4e18: aa0403e0     	mov	x0, x4
    4e1c: aa0103e2     	mov	x2, x1
    4e20: aa0503f3     	mov	x19, x5
    4e24: 34000a02     	cbz	w2, 0x4f64 <___pl_fn_6+0x2b0>
    4e28: f9400263     	ldr	x3, [x19]
    4e2c: 2a0203e1     	mov	w1, w2
    4e30: 8b010c61     	add	x1, x3, x1, lsl #3
    4e34: f8625862     	ldr	x2, [x3, w2, uxtw #3]
    4e38: 2a0003e0     	mov	w0, w0
    4e3c: d360fc42     	lsr	x2, x2, #32
    4e40: 92403c42     	and	x2, x2, #0xffff
    4e44: 91000c42     	add	x2, x2, #0x3
    4e48: f8227820     	str	x0, [x1, x2, lsl #3]
    4e4c: b9401260     	ldr	w0, [x19, #0x10]
    4e50: 51000400     	sub	w0, w0, #0x1
    4e54: b9001260     	str	w0, [x19, #0x10]
    4e58: 910183ff     	add	sp, sp, #0x60
    4e5c: f84107f3     	ldr	x19, [sp], #0x10
    4e60: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4e64: d65f03c0     	ret
    4e68: aa0103e2     	mov	x2, x1
    4e6c: d2800100     	mov	x0, #0x8                ; =8
    4e70: 910003e3     	mov	x3, sp
    4e74: f80003e0     	stur	x0, [sp]
    4e78: aa0403e0     	mov	x0, x4
    4e7c: 2a0003e0     	mov	w0, w0
    4e80: f80083e0     	stur	x0, [sp, #0x8]
    4e84: 52801181     	mov	w1, #0x8c               ; =140
    4e88: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4e8c: f9400084     	ldr	x4, [x4]
    4e90: aa0503f3     	mov	x19, x5
    4e94: aa1303e0     	mov	x0, x19
    4e98: d63f0080     	blr	x4
    4e9c: 34fffd80     	cbz	w0, 0x4e4c <___pl_fn_6+0x198>
    4ea0: 1400003c     	b	0x4f90 <___pl_fn_6+0x2dc>
    4ea4: d28000e1     	mov	x1, #0x7                ; =7
    4ea8: 910043e3     	add	x3, sp, #0x10
    4eac: f80103e1     	stur	x1, [sp, #0x10]
    4eb0: 2a0003e0     	mov	w0, w0
    4eb4: f80183e0     	stur	x0, [sp, #0x18]
    4eb8: 528011a1     	mov	w1, #0x8d               ; =141
    4ebc: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4ec0: f9400084     	ldr	x4, [x4]
    4ec4: aa1303e0     	mov	x0, x19
    4ec8: d63f0080     	blr	x4
    4ecc: 34fffc00     	cbz	w0, 0x4e4c <___pl_fn_6+0x198>
    4ed0: 14000030     	b	0x4f90 <___pl_fn_6+0x2dc>
    4ed4: d28000c1     	mov	x1, #0x6                ; =6
    4ed8: 910083e3     	add	x3, sp, #0x20
    4edc: f80203e1     	stur	x1, [sp, #0x20]
    4ee0: 2a0003e0     	mov	w0, w0
    4ee4: f80283e0     	stur	x0, [sp, #0x28]
    4ee8: 528011c1     	mov	w1, #0x8e               ; =142
    4eec: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4ef0: f9400084     	ldr	x4, [x4]
    4ef4: aa1303e0     	mov	x0, x19
    4ef8: d63f0080     	blr	x4
    4efc: 34fffa80     	cbz	w0, 0x4e4c <___pl_fn_6+0x198>
    4f00: 14000024     	b	0x4f90 <___pl_fn_6+0x2dc>
    4f04: d28000a7     	mov	x7, #0x5                ; =5
    4f08: 9100c3e3     	add	x3, sp, #0x30
    4f0c: f80303e7     	stur	x7, [sp, #0x30]
    4f10: 2a0003e8     	mov	w8, w0
    4f14: f80383e8     	stur	x8, [sp, #0x38]
    4f18: 528011e1     	mov	w1, #0x8f               ; =143
    4f1c: 90000009     	adrp	x9, 0x4000 <___pl_fn_1+0x3ef4>
    4f20: f9400129     	ldr	x9, [x9]
    4f24: aa1303e0     	mov	x0, x19
    4f28: d63f0120     	blr	x9
    4f2c: 34fff900     	cbz	w0, 0x4e4c <___pl_fn_6+0x198>
    4f30: 14000018     	b	0x4f90 <___pl_fn_6+0x2dc>
    4f34: d2800081     	mov	x1, #0x4                ; =4
    4f38: 910103e3     	add	x3, sp, #0x40
    4f3c: f80403e1     	stur	x1, [sp, #0x40]
    4f40: 2a0003e0     	mov	w0, w0
    4f44: f80483e0     	stur	x0, [sp, #0x48]
    4f48: 52801201     	mov	w1, #0x90               ; =144
    4f4c: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4f50: f9400084     	ldr	x4, [x4]
    4f54: aa1303e0     	mov	x0, x19
    4f58: d63f0080     	blr	x4
    4f5c: 34fff780     	cbz	w0, 0x4e4c <___pl_fn_6+0x198>
    4f60: 1400000c     	b	0x4f90 <___pl_fn_6+0x2dc>
    4f64: d2800061     	mov	x1, #0x3                ; =3
    4f68: 910143e3     	add	x3, sp, #0x50
    4f6c: f80503e1     	stur	x1, [sp, #0x50]
    4f70: 2a0003e0     	mov	w0, w0
    4f74: f80583e0     	stur	x0, [sp, #0x58]
    4f78: 52801221     	mov	w1, #0x91               ; =145
    4f7c: 90000004     	adrp	x4, 0x4000 <___pl_fn_1+0x3ef4>
    4f80: f9400084     	ldr	x4, [x4]
    4f84: aa1303e0     	mov	x0, x19
    4f88: d63f0080     	blr	x4
    4f8c: 34fff600     	cbz	w0, 0x4e4c <___pl_fn_6+0x198>
    4f90: 910183ff     	add	sp, sp, #0x60
    4f94: f84107f3     	ldr	x19, [sp], #0x10
    4f98: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4f9c: d65f03c0     	ret

0000000000004fa0 <___pl_fn_7>:
    4fa0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    4fa4: 910003fd     	mov	x29, sp
    4fa8: f81f0ff3     	str	x19, [sp, #-0x10]!
    4fac: b9401003     	ldr	w3, [x0, #0x10]
    4fb0: 11000463     	add	w3, w3, #0x1
    4fb4: b9001003     	str	w3, [x0, #0x10]
    4fb8: f100045f     	cmp	x2, #0x1
    4fbc: 54000e80     	b.eq	0x518c <___pl_fn_7+0x1ec>
    4fc0: f100085f     	cmp	x2, #0x2
    4fc4: 54000ba0     	b.eq	0x5138 <___pl_fn_7+0x198>
    4fc8: f1000c5f     	cmp	x2, #0x3
    4fcc: 540008c0     	b.eq	0x50e4 <___pl_fn_7+0x144>
    4fd0: f100105f     	cmp	x2, #0x4
    4fd4: 540005e0     	b.eq	0x5090 <___pl_fn_7+0xf0>
    4fd8: f100145f     	cmp	x2, #0x5
    4fdc: 54000300     	b.eq	0x503c <___pl_fn_7+0x9c>
    4fe0: 34001001     	cbz	w1, 0x51e0 <___pl_fn_7+0x240>
    4fe4: f9400002     	ldr	x2, [x0]
    4fe8: aa0003e5     	mov	x5, x0
    4fec: 2a0103e0     	mov	w0, w1
    4ff0: 8b000c40     	add	x0, x2, x0, lsl #3
    4ff4: f8615842     	ldr	x2, [x2, w1, uxtw #3]
    4ff8: aa0103e6     	mov	x6, x1
    4ffc: d360fc41     	lsr	x1, x2, #32
    5000: 92403c21     	and	x1, x1, #0xffff
    5004: 91002021     	add	x1, x1, #0x8
    5008: d37df021     	lsl	x1, x1, #3
    500c: b8616800     	ldr	w0, [x0, x1]
    5010: 35000080     	cbnz	w0, 0x5020 <___pl_fn_7+0x80>
    5014: 14000075     	b	0x51e8 <___pl_fn_7+0x248>
    5018: f9401a60     	ldr	x0, [x19, #0x30]
    501c: 14000002     	b	0x5024 <___pl_fn_7+0x84>
    5020: aa0503f3     	mov	x19, x5
    5024: b9401264     	ldr	w4, [x19, #0x10]
    5028: 51000484     	sub	w4, w4, #0x1
    502c: b9001264     	str	w4, [x19, #0x10]
    5030: f84107f3     	ldr	x19, [sp], #0x10
    5034: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5038: d65f03c0     	ret
    503c: aa0103e2     	mov	x2, x1
    5040: aa0003f3     	mov	x19, x0
    5044: 34000e62     	cbz	w2, 0x5210 <___pl_fn_7+0x270>
    5048: f9400269     	ldr	x9, [x19]
    504c: 2a0203e8     	mov	w8, w2
    5050: 8b080d28     	add	x8, x9, x8, lsl #3
    5054: f8625929     	ldr	x9, [x9, w2, uxtw #3]
    5058: d360fd29     	lsr	x9, x9, #32
    505c: 92403d29     	and	x9, x9, #0xffff
    5060: 91001d29     	add	x9, x9, #0x7
    5064: d37df129     	lsl	x9, x9, #3
    5068: b8696900     	ldr	w0, [x8, x9]
    506c: 35000060     	cbnz	w0, 0x5078 <___pl_fn_7+0xd8>
    5070: 14000068     	b	0x5210 <___pl_fn_7+0x270>
    5074: f9401a60     	ldr	x0, [x19, #0x30]
    5078: b940126e     	ldr	w14, [x19, #0x10]
    507c: 510005ce     	sub	w14, w14, #0x1
    5080: b900126e     	str	w14, [x19, #0x10]
    5084: f84107f3     	ldr	x19, [sp], #0x10
    5088: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    508c: d65f03c0     	ret
    5090: aa0103e2     	mov	x2, x1
    5094: aa0003f3     	mov	x19, x0
    5098: 34000cc2     	cbz	w2, 0x5230 <___pl_fn_7+0x290>
    509c: f9400261     	ldr	x1, [x19]
    50a0: 2a0203e0     	mov	w0, w2
    50a4: 8b000c20     	add	x0, x1, x0, lsl #3
    50a8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    50ac: d360fc21     	lsr	x1, x1, #32
    50b0: 92403c21     	and	x1, x1, #0xffff
    50b4: 91001821     	add	x1, x1, #0x6
    50b8: d37df021     	lsl	x1, x1, #3
    50bc: b8616800     	ldr	w0, [x0, x1]
    50c0: 35000060     	cbnz	w0, 0x50cc <___pl_fn_7+0x12c>
    50c4: 1400005b     	b	0x5230 <___pl_fn_7+0x290>
    50c8: f9401a60     	ldr	x0, [x19, #0x30]
    50cc: b9401261     	ldr	w1, [x19, #0x10]
    50d0: 51000421     	sub	w1, w1, #0x1
    50d4: b9001261     	str	w1, [x19, #0x10]
    50d8: f84107f3     	ldr	x19, [sp], #0x10
    50dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    50e0: d65f03c0     	ret
    50e4: aa0103e2     	mov	x2, x1
    50e8: aa0003f3     	mov	x19, x0
    50ec: 34000b22     	cbz	w2, 0x5250 <___pl_fn_7+0x2b0>
    50f0: f9400261     	ldr	x1, [x19]
    50f4: 2a0203e0     	mov	w0, w2
    50f8: 8b000c20     	add	x0, x1, x0, lsl #3
    50fc: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    5100: d360fc21     	lsr	x1, x1, #32
    5104: 92403c21     	and	x1, x1, #0xffff
    5108: 91001421     	add	x1, x1, #0x5
    510c: d37df021     	lsl	x1, x1, #3
    5110: b8616800     	ldr	w0, [x0, x1]
    5114: 35000060     	cbnz	w0, 0x5120 <___pl_fn_7+0x180>
    5118: 1400004e     	b	0x5250 <___pl_fn_7+0x2b0>
    511c: f9401a60     	ldr	x0, [x19, #0x30]
    5120: b9401261     	ldr	w1, [x19, #0x10]
    5124: 51000421     	sub	w1, w1, #0x1
    5128: b9001261     	str	w1, [x19, #0x10]
    512c: f84107f3     	ldr	x19, [sp], #0x10
    5130: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5134: d65f03c0     	ret
    5138: aa0103e2     	mov	x2, x1
    513c: aa0003f3     	mov	x19, x0
    5140: 34000982     	cbz	w2, 0x5270 <___pl_fn_7+0x2d0>
    5144: f9400261     	ldr	x1, [x19]
    5148: 2a0203e0     	mov	w0, w2
    514c: 8b000c20     	add	x0, x1, x0, lsl #3
    5150: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    5154: d360fc21     	lsr	x1, x1, #32
    5158: 92403c21     	and	x1, x1, #0xffff
    515c: 91001021     	add	x1, x1, #0x4
    5160: d37df021     	lsl	x1, x1, #3
    5164: b8616800     	ldr	w0, [x0, x1]
    5168: 35000060     	cbnz	w0, 0x5174 <___pl_fn_7+0x1d4>
    516c: 14000041     	b	0x5270 <___pl_fn_7+0x2d0>
    5170: f9401a60     	ldr	x0, [x19, #0x30]
    5174: b9401261     	ldr	w1, [x19, #0x10]
    5178: 51000421     	sub	w1, w1, #0x1
    517c: b9001261     	str	w1, [x19, #0x10]
    5180: f84107f3     	ldr	x19, [sp], #0x10
    5184: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5188: d65f03c0     	ret
    518c: aa0103e2     	mov	x2, x1
    5190: aa0003f3     	mov	x19, x0
    5194: 340007e2     	cbz	w2, 0x5290 <___pl_fn_7+0x2f0>
    5198: f9400261     	ldr	x1, [x19]
    519c: 2a0203e0     	mov	w0, w2
    51a0: 8b000c20     	add	x0, x1, x0, lsl #3
    51a4: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    51a8: d360fc21     	lsr	x1, x1, #32
    51ac: 92403c21     	and	x1, x1, #0xffff
    51b0: 91000c21     	add	x1, x1, #0x3
    51b4: d37df021     	lsl	x1, x1, #3
    51b8: b8616800     	ldr	w0, [x0, x1]
    51bc: 35000060     	cbnz	w0, 0x51c8 <___pl_fn_7+0x228>
    51c0: 14000034     	b	0x5290 <___pl_fn_7+0x2f0>
    51c4: f9401a60     	ldr	x0, [x19, #0x30]
    51c8: b9401261     	ldr	w1, [x19, #0x10]
    51cc: 51000421     	sub	w1, w1, #0x1
    51d0: b9001261     	str	w1, [x19, #0x10]
    51d4: f84107f3     	ldr	x19, [sp], #0x10
    51d8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    51dc: d65f03c0     	ret
    51e0: aa0003e5     	mov	x5, x0
    51e4: aa0103e6     	mov	x6, x1
    51e8: 52801241     	mov	w1, #0x92               ; =146
    51ec: 52800103     	mov	w3, #0x8                ; =8
    51f0: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    51f4: f9400084     	ldr	x4, [x4]
    51f8: aa0603e2     	mov	x2, x6
    51fc: aa0503f3     	mov	x19, x5
    5200: aa1303e0     	mov	x0, x19
    5204: d63f0080     	blr	x4
    5208: 34fff080     	cbz	w0, 0x5018 <___pl_fn_7+0x78>
    520c: 14000028     	b	0x52ac <___pl_fn_7+0x30c>
    5210: 52801261     	mov	w1, #0x93               ; =147
    5214: 528000e3     	mov	w3, #0x7                ; =7
    5218: 9000000a     	adrp	x10, 0x5000 <___pl_fn_7+0x60>
    521c: f940014a     	ldr	x10, [x10]
    5220: aa1303e0     	mov	x0, x19
    5224: d63f0140     	blr	x10
    5228: 34fff260     	cbz	w0, 0x5074 <___pl_fn_7+0xd4>
    522c: 14000020     	b	0x52ac <___pl_fn_7+0x30c>
    5230: 52801281     	mov	w1, #0x94               ; =148
    5234: 528000c3     	mov	w3, #0x6                ; =6
    5238: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    523c: f9400084     	ldr	x4, [x4]
    5240: aa1303e0     	mov	x0, x19
    5244: d63f0080     	blr	x4
    5248: 34fff400     	cbz	w0, 0x50c8 <___pl_fn_7+0x128>
    524c: 14000018     	b	0x52ac <___pl_fn_7+0x30c>
    5250: 528012a1     	mov	w1, #0x95               ; =149
    5254: 528000a3     	mov	w3, #0x5                ; =5
    5258: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    525c: f9400084     	ldr	x4, [x4]
    5260: aa1303e0     	mov	x0, x19
    5264: d63f0080     	blr	x4
    5268: 34fff5a0     	cbz	w0, 0x511c <___pl_fn_7+0x17c>
    526c: 14000010     	b	0x52ac <___pl_fn_7+0x30c>
    5270: 528012c1     	mov	w1, #0x96               ; =150
    5274: 52800083     	mov	w3, #0x4                ; =4
    5278: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    527c: f9400084     	ldr	x4, [x4]
    5280: aa1303e0     	mov	x0, x19
    5284: d63f0080     	blr	x4
    5288: 34fff740     	cbz	w0, 0x5170 <___pl_fn_7+0x1d0>
    528c: 14000008     	b	0x52ac <___pl_fn_7+0x30c>
    5290: 528012e1     	mov	w1, #0x97               ; =151
    5294: 52800063     	mov	w3, #0x3                ; =3
    5298: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    529c: f9400084     	ldr	x4, [x4]
    52a0: aa1303e0     	mov	x0, x19
    52a4: d63f0080     	blr	x4
    52a8: 34fff8e0     	cbz	w0, 0x51c4 <___pl_fn_7+0x224>
    52ac: 52800000     	mov	w0, #0x0                ; =0
    52b0: f84107f3     	ldr	x19, [sp], #0x10
    52b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    52b8: d65f03c0     	ret

00000000000052bc <___pl_fn_8>:
    52bc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    52c0: 910003fd     	mov	x29, sp
    52c4: f81f0ffb     	str	x27, [sp, #-0x10]!
    52c8: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
    52cc: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
    52d0: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    52d4: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    52d8: d10243ff     	sub	sp, sp, #0x90
    52dc: aa0103f3     	mov	x19, x1
    52e0: aa0303f7     	mov	x23, x3
    52e4: aa0703f8     	mov	x24, x7
    52e8: aa0603f9     	mov	x25, x6
    52ec: aa0503fa     	mov	x26, x5
    52f0: aa0403fb     	mov	x27, x4
    52f4: b9401001     	ldr	w1, [x0, #0x10]
    52f8: 11000421     	add	w1, w1, #0x1
    52fc: b9001001     	str	w1, [x0, #0x10]
    5300: aa0003f6     	mov	x22, x0
    5304: aa1303e1     	mov	x1, x19
    5308: 340015c1     	cbz	w1, 0x55c0 <___pl_fn_8+0x304>
    530c: aa1603e0     	mov	x0, x22
    5310: aa0203f4     	mov	x20, x2
    5314: f9400001     	ldr	x1, [x0]
    5318: 2a1303e0     	mov	w0, w19
    531c: 8b000c20     	add	x0, x1, x0, lsl #3
    5320: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    5324: 2a1403e1     	mov	w1, w20
    5328: d360fc42     	lsr	x2, x2, #32
    532c: 92403c42     	and	x2, x2, #0xffff
    5330: 91001c42     	add	x2, x2, #0x7
    5334: f8227801     	str	x1, [x0, x2, lsl #3]
    5338: 34001614     	cbz	w20, 0x55f8 <___pl_fn_8+0x33c>
    533c: aa1603e0     	mov	x0, x22
    5340: f9400001     	ldr	x1, [x0]
    5344: 2a1403e0     	mov	w0, w20
    5348: 8b000c20     	add	x0, x1, x0, lsl #3
    534c: f8745821     	ldr	x1, [x1, w20, uxtw #3]
    5350: d360fc21     	lsr	x1, x1, #32
    5354: 92403c21     	and	x1, x1, #0xffff
    5358: d37df021     	lsl	x1, x1, #3
    535c: b8616800     	ldr	w0, [x0, x1]
    5360: 35000080     	cbnz	w0, 0x5370 <___pl_fn_8+0xb4>
    5364: 140000a5     	b	0x55f8 <___pl_fn_8+0x33c>
    5368: aa1603e0     	mov	x0, x22
    536c: f9401800     	ldr	x0, [x0, #0x30]
    5370: 34001573     	cbz	w19, 0x561c <___pl_fn_8+0x360>
    5374: aa1603e1     	mov	x1, x22
    5378: f9400024     	ldr	x4, [x1]
    537c: 2a1303e3     	mov	w3, w19
    5380: 8b030c83     	add	x3, x4, x3, lsl #3
    5384: f8735885     	ldr	x5, [x4, w19, uxtw #3]
    5388: 2a0003e4     	mov	w4, w0
    538c: d360fca5     	lsr	x5, x5, #32
    5390: 92403ca5     	and	x5, x5, #0xffff
    5394: f8257864     	str	x4, [x3, x5, lsl #3]
    5398: 35000093     	cbnz	w19, 0x53a8 <___pl_fn_8+0xec>
    539c: 140000ad     	b	0x5650 <___pl_fn_8+0x394>
    53a0: aa1503f7     	mov	x23, x21
    53a4: 14000012     	b	0x53ec <___pl_fn_8+0x130>
    53a8: aa1603e0     	mov	x0, x22
    53ac: aa1703f5     	mov	x21, x23
    53b0: f940000c     	ldr	x12, [x0]
    53b4: 2a1303eb     	mov	w11, w19
    53b8: 8b0b0d8b     	add	x11, x12, x11, lsl #3
    53bc: f873598c     	ldr	x12, [x12, w19, uxtw #3]
    53c0: d360fd8c     	lsr	x12, x12, #32
    53c4: 92403d8d     	and	x13, x12, #0xffff
    53c8: f10009bf     	cmp	x13, #0x2
    53cc: 54000080     	b.eq	0x53dc <___pl_fn_8+0x120>
    53d0: f940096e     	ldr	x14, [x11, #0x10]
    53d4: 927ef9ce     	and	x14, x14, #0xfffffffffffffffd
    53d8: f900096e     	str	x14, [x11, #0x10]
    53dc: 92403d80     	and	x0, x12, #0xffff
    53e0: 91000400     	add	x0, x0, #0x1
    53e4: f8207975     	str	x21, [x11, x0, lsl #3]
    53e8: aa1503f7     	mov	x23, x21
    53ec: 340014d3     	cbz	w19, 0x5684 <___pl_fn_8+0x3c8>
    53f0: aa1603e0     	mov	x0, x22
    53f4: aa1b03e4     	mov	x4, x27
    53f8: f9400001     	ldr	x1, [x0]
    53fc: 2a1303e0     	mov	w0, w19
    5400: 8b000c20     	add	x0, x1, x0, lsl #3
    5404: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    5408: d360fc21     	lsr	x1, x1, #32
    540c: 92403c22     	and	x2, x1, #0xffff
    5410: f100085f     	cmp	x2, #0x2
    5414: 54000080     	b.eq	0x5424 <___pl_fn_8+0x168>
    5418: f9400802     	ldr	x2, [x0, #0x10]
    541c: 927df842     	and	x2, x2, #0xfffffffffffffffb
    5420: f9000802     	str	x2, [x0, #0x10]
    5424: 92403c21     	and	x1, x1, #0xffff
    5428: 91000821     	add	x1, x1, #0x2
    542c: f8217804     	str	x4, [x0, x1, lsl #3]
    5430: 34001453     	cbz	w19, 0x56b8 <___pl_fn_8+0x3fc>
    5434: aa1603e0     	mov	x0, x22
    5438: aa1a03e5     	mov	x5, x26
    543c: f9400001     	ldr	x1, [x0]
    5440: 2a1303e0     	mov	w0, w19
    5444: 8b000c20     	add	x0, x1, x0, lsl #3
    5448: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    544c: 2a0503e1     	mov	w1, w5
    5450: d360fc42     	lsr	x2, x2, #32
    5454: 92403c42     	and	x2, x2, #0xffff
    5458: 91000c42     	add	x2, x2, #0x3
    545c: f8227801     	str	x1, [x0, x2, lsl #3]
    5460: 34001493     	cbz	w19, 0x56f0 <___pl_fn_8+0x434>
    5464: aa1603e0     	mov	x0, x22
    5468: aa1903e6     	mov	x6, x25
    546c: f9400001     	ldr	x1, [x0]
    5470: 2a1303e0     	mov	w0, w19
    5474: 8b000c20     	add	x0, x1, x0, lsl #3
    5478: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    547c: 53001cc1     	uxtb	w1, w6
    5480: d360fc42     	lsr	x2, x2, #32
    5484: 92403c42     	and	x2, x2, #0xffff
    5488: 91001042     	add	x2, x2, #0x4
    548c: f8227801     	str	x1, [x0, x2, lsl #3]
    5490: 340014d3     	cbz	w19, 0x5728 <___pl_fn_8+0x46c>
    5494: aa1603e0     	mov	x0, x22
    5498: aa1803e7     	mov	x7, x24
    549c: f9400001     	ldr	x1, [x0]
    54a0: 2a1303e0     	mov	w0, w19
    54a4: 8b000c20     	add	x0, x1, x0, lsl #3
    54a8: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    54ac: 53001ce1     	uxtb	w1, w7
    54b0: d360fc42     	lsr	x2, x2, #32
    54b4: 92403c42     	and	x2, x2, #0xffff
    54b8: 91001442     	add	x2, x2, #0x5
    54bc: f8227801     	str	x1, [x0, x2, lsl #3]
    54c0: 34001513     	cbz	w19, 0x5760 <___pl_fn_8+0x4a4>
    54c4: aa1603e0     	mov	x0, x22
    54c8: f9400001     	ldr	x1, [x0]
    54cc: 2a1303e0     	mov	w0, w19
    54d0: 8b000c20     	add	x0, x1, x0, lsl #3
    54d4: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    54d8: d2800001     	mov	x1, #0x0                ; =0
    54dc: d360fc42     	lsr	x2, x2, #32
    54e0: 92403c42     	and	x2, x2, #0xffff
    54e4: 91001842     	add	x2, x2, #0x6
    54e8: f8227801     	str	x1, [x0, x2, lsl #3]
    54ec: 35000094     	cbnz	w20, 0x54fc <___pl_fn_8+0x240>
    54f0: 140000a9     	b	0x5794 <___pl_fn_8+0x4d8>
    54f4: aa1603e0     	mov	x0, x22
    54f8: 1400000a     	b	0x5520 <___pl_fn_8+0x264>
    54fc: aa1603e0     	mov	x0, x22
    5500: f9400007     	ldr	x7, [x0]
    5504: 2a1403e6     	mov	w6, w20
    5508: 8b060ce6     	add	x6, x7, x6, lsl #3
    550c: f87458e8     	ldr	x8, [x7, w20, uxtw #3]
    5510: 2a1303e7     	mov	w7, w19
    5514: d360fd08     	lsr	x8, x8, #32
    5518: 92403d08     	and	x8, x8, #0xffff
    551c: f82878c7     	str	x7, [x6, x8, lsl #3]
    5520: aa1603e0     	mov	x0, x22
    5524: b9401815     	ldr	w21, [x0, #0x18]
    5528: b9401c08     	ldr	w8, [x0, #0x1c]
    552c: 11000aa9     	add	w9, w21, #0x2
    5530: 6b08013f     	cmp	w9, w8
    5534: 54001728     	b.hi	0x5818 <___pl_fn_8+0x55c>
    5538: aa1603e0     	mov	x0, x22
    553c: f940100a     	ldr	x10, [x0, #0x20]
    5540: 2a1503eb     	mov	w11, w21
    5544: 8b0b094b     	add	x11, x10, x11, lsl #2
    5548: b8355953     	str	w19, [x10, w21, uxtw #2]
    554c: b9000574     	str	w20, [x11, #0x4]
    5550: 11000aac     	add	w12, w21, #0x2
    5554: b900180c     	str	w12, [x0, #0x18]
    5558: b940100d     	ldr	w13, [x0, #0x10]
    555c: b940140e     	ldr	w14, [x0, #0x14]
    5560: 6b0e01bf     	cmp	w13, w14
    5564: 54001402     	b.hs	0x57e4 <___pl_fn_8+0x528>
    5568: aa1403e1     	mov	x1, x20
    556c: aa1703e2     	mov	x2, x23
    5570: aa1303e3     	mov	x3, x19
    5574: aa1603e0     	mov	x0, x22
    5578: 94000000     	bl	0x5578 <___pl_fn_8+0x2bc>
    557c: aa1603e0     	mov	x0, x22
    5580: b9402c00     	ldr	w0, [x0, #0x2c]
    5584: 35001200     	cbnz	w0, 0x57c4 <___pl_fn_8+0x508>
    5588: aa1603e0     	mov	x0, x22
    558c: b9001815     	str	w21, [x0, #0x18]
    5590: b9401000     	ldr	w0, [x0, #0x10]
    5594: 51000400     	sub	w0, w0, #0x1
    5598: aa1603ed     	mov	x13, x22
    559c: b90011a0     	str	w0, [x13, #0x10]
    55a0: 910243ff     	add	sp, sp, #0x90
    55a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    55a8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    55ac: a8c163f7     	ldp	x23, x24, [sp], #0x10
    55b0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    55b4: f84107fb     	ldr	x27, [sp], #0x10
    55b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    55bc: d65f03c0     	ret
    55c0: d28000e0     	mov	x0, #0x7                ; =7
    55c4: 910003e3     	mov	x3, sp
    55c8: f80003e0     	stur	x0, [sp]
    55cc: 2a0203e0     	mov	w0, w2
    55d0: aa0203f4     	mov	x20, x2
    55d4: f80083e0     	stur	x0, [sp, #0x8]
    55d8: 52801301     	mov	w1, #0x98               ; =152
    55dc: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    55e0: f9400084     	ldr	x4, [x4]
    55e4: aa1603e0     	mov	x0, x22
    55e8: aa1303e2     	mov	x2, x19
    55ec: d63f0080     	blr	x4
    55f0: 34ffea40     	cbz	w0, 0x5338 <___pl_fn_8+0x7c>
    55f4: 14000074     	b	0x57c4 <___pl_fn_8+0x508>
    55f8: 52801321     	mov	w1, #0x99               ; =153
    55fc: 52800003     	mov	w3, #0x0                ; =0
    5600: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5604: f9400084     	ldr	x4, [x4]
    5608: aa1603e0     	mov	x0, x22
    560c: aa1403e2     	mov	x2, x20
    5610: d63f0080     	blr	x4
    5614: 34ffeaa0     	cbz	w0, 0x5368 <___pl_fn_8+0xac>
    5618: 1400006b     	b	0x57c4 <___pl_fn_8+0x508>
    561c: d2800001     	mov	x1, #0x0                ; =0
    5620: 910043e3     	add	x3, sp, #0x10
    5624: f80103e1     	stur	x1, [sp, #0x10]
    5628: 2a0003e0     	mov	w0, w0
    562c: f80183e0     	stur	x0, [sp, #0x18]
    5630: 52801341     	mov	w1, #0x9a               ; =154
    5634: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5638: f9400084     	ldr	x4, [x4]
    563c: aa1603e0     	mov	x0, x22
    5640: aa1303e2     	mov	x2, x19
    5644: d63f0080     	blr	x4
    5648: 34ffea80     	cbz	w0, 0x5398 <___pl_fn_8+0xdc>
    564c: 1400005e     	b	0x57c4 <___pl_fn_8+0x508>
    5650: d2800026     	mov	x6, #0x1                ; =1
    5654: 910083e3     	add	x3, sp, #0x20
    5658: f80203e6     	stur	x6, [sp, #0x20]
    565c: aa1703f5     	mov	x21, x23
    5660: f80283f5     	stur	x21, [sp, #0x28]
    5664: 52801361     	mov	w1, #0x9b               ; =155
    5668: 90000008     	adrp	x8, 0x5000 <___pl_fn_7+0x60>
    566c: f9400108     	ldr	x8, [x8]
    5670: aa1603e0     	mov	x0, x22
    5674: aa1303e2     	mov	x2, x19
    5678: d63f0100     	blr	x8
    567c: 34ffe920     	cbz	w0, 0x53a0 <___pl_fn_8+0xe4>
    5680: 14000051     	b	0x57c4 <___pl_fn_8+0x508>
    5684: d2800040     	mov	x0, #0x2                ; =2
    5688: 9100c3e3     	add	x3, sp, #0x30
    568c: f80303e0     	stur	x0, [sp, #0x30]
    5690: aa1b03e4     	mov	x4, x27
    5694: f80383e4     	stur	x4, [sp, #0x38]
    5698: 52801381     	mov	w1, #0x9c               ; =156
    569c: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    56a0: f9400084     	ldr	x4, [x4]
    56a4: aa1603e0     	mov	x0, x22
    56a8: aa1303e2     	mov	x2, x19
    56ac: d63f0080     	blr	x4
    56b0: 34ffec00     	cbz	w0, 0x5430 <___pl_fn_8+0x174>
    56b4: 14000044     	b	0x57c4 <___pl_fn_8+0x508>
    56b8: d2800060     	mov	x0, #0x3                ; =3
    56bc: 910103e3     	add	x3, sp, #0x40
    56c0: f80403e0     	stur	x0, [sp, #0x40]
    56c4: aa1a03e5     	mov	x5, x26
    56c8: 2a0503e0     	mov	w0, w5
    56cc: f80483e0     	stur	x0, [sp, #0x48]
    56d0: 528013a1     	mov	w1, #0x9d               ; =157
    56d4: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    56d8: f9400084     	ldr	x4, [x4]
    56dc: aa1603e0     	mov	x0, x22
    56e0: aa1303e2     	mov	x2, x19
    56e4: d63f0080     	blr	x4
    56e8: 34ffebc0     	cbz	w0, 0x5460 <___pl_fn_8+0x1a4>
    56ec: 14000036     	b	0x57c4 <___pl_fn_8+0x508>
    56f0: d2800080     	mov	x0, #0x4                ; =4
    56f4: 910143e3     	add	x3, sp, #0x50
    56f8: f80503e0     	stur	x0, [sp, #0x50]
    56fc: aa1903e6     	mov	x6, x25
    5700: 53001cc0     	uxtb	w0, w6
    5704: f80583e0     	stur	x0, [sp, #0x58]
    5708: 528013c1     	mov	w1, #0x9e               ; =158
    570c: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5710: f9400084     	ldr	x4, [x4]
    5714: aa1603e0     	mov	x0, x22
    5718: aa1303e2     	mov	x2, x19
    571c: d63f0080     	blr	x4
    5720: 34ffeb80     	cbz	w0, 0x5490 <___pl_fn_8+0x1d4>
    5724: 14000028     	b	0x57c4 <___pl_fn_8+0x508>
    5728: d28000a0     	mov	x0, #0x5                ; =5
    572c: 910183e3     	add	x3, sp, #0x60
    5730: f80603e0     	stur	x0, [sp, #0x60]
    5734: aa1803e7     	mov	x7, x24
    5738: 53001ce0     	uxtb	w0, w7
    573c: f80683e0     	stur	x0, [sp, #0x68]
    5740: 528013e1     	mov	w1, #0x9f               ; =159
    5744: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5748: f9400084     	ldr	x4, [x4]
    574c: aa1603e0     	mov	x0, x22
    5750: aa1303e2     	mov	x2, x19
    5754: d63f0080     	blr	x4
    5758: 34ffeb40     	cbz	w0, 0x54c0 <___pl_fn_8+0x204>
    575c: 1400001a     	b	0x57c4 <___pl_fn_8+0x508>
    5760: d28000c0     	mov	x0, #0x6                ; =6
    5764: 9101c3e3     	add	x3, sp, #0x70
    5768: f80703e0     	stur	x0, [sp, #0x70]
    576c: d2800000     	mov	x0, #0x0                ; =0
    5770: f80783e0     	stur	x0, [sp, #0x78]
    5774: 52801401     	mov	w1, #0xa0               ; =160
    5778: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    577c: f9400084     	ldr	x4, [x4]
    5780: aa1603e0     	mov	x0, x22
    5784: aa1303e2     	mov	x2, x19
    5788: d63f0080     	blr	x4
    578c: 34ffeb00     	cbz	w0, 0x54ec <___pl_fn_8+0x230>
    5790: 1400000d     	b	0x57c4 <___pl_fn_8+0x508>
    5794: d2800001     	mov	x1, #0x0                ; =0
    5798: 910203e3     	add	x3, sp, #0x80
    579c: f80803e1     	stur	x1, [sp, #0x80]
    57a0: 2a1303e2     	mov	w2, w19
    57a4: f80883e2     	stur	x2, [sp, #0x88]
    57a8: 52801421     	mov	w1, #0xa1               ; =161
    57ac: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    57b0: f9400084     	ldr	x4, [x4]
    57b4: aa1603e0     	mov	x0, x22
    57b8: aa1403e2     	mov	x2, x20
    57bc: d63f0080     	blr	x4
    57c0: 34ffe9a0     	cbz	w0, 0x54f4 <___pl_fn_8+0x238>
    57c4: 910243ff     	add	sp, sp, #0x90
    57c8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    57cc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    57d0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    57d4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    57d8: f84107fb     	ldr	x27, [sp], #0x10
    57dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    57e0: d65f03c0     	ret
    57e4: 52801461     	mov	w1, #0xa3               ; =163
    57e8: 90000002     	adrp	x2, 0x5000 <___pl_fn_7+0x60>
    57ec: f9400042     	ldr	x2, [x2]
    57f0: aa1603e0     	mov	x0, x22
    57f4: d63f0040     	blr	x2
    57f8: 910243ff     	add	sp, sp, #0x90
    57fc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5800: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5804: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5808: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    580c: f84107fb     	ldr	x27, [sp], #0x10
    5810: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5814: d65f03c0     	ret
    5818: 52801441     	mov	w1, #0xa2               ; =162
    581c: 90000002     	adrp	x2, 0x5000 <___pl_fn_7+0x60>
    5820: f9400042     	ldr	x2, [x2]
    5824: aa1603e0     	mov	x0, x22
    5828: d63f0040     	blr	x2
    582c: 910243ff     	add	sp, sp, #0x90
    5830: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5834: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5838: a8c163f7     	ldp	x23, x24, [sp], #0x10
    583c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5840: f84107fb     	ldr	x27, [sp], #0x10
    5844: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5848: d65f03c0     	ret

000000000000584c <___pl_fn_9>:
    584c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    5850: 910003fd     	mov	x29, sp
    5854: b9401004     	ldr	w4, [x0, #0x10]
    5858: 11000485     	add	w5, w4, #0x1
    585c: b9001005     	str	w5, [x0, #0x10]
    5860: b9001004     	str	w4, [x0, #0x10]
    5864: aa0103e0     	mov	x0, x1
    5868: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    586c: d65f03c0     	ret

0000000000005870 <___pl_fn_10>:
    5870: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    5874: 910003fd     	mov	x29, sp
    5878: f81f0ff9     	str	x25, [sp, #-0x10]!
    587c: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
    5880: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    5884: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    5888: d100c3ff     	sub	sp, sp, #0x30
    588c: aa0103f5     	mov	x21, x1
    5890: aa0303f7     	mov	x23, x3
    5894: aa0203f8     	mov	x24, x2
    5898: b9401003     	ldr	w3, [x0, #0x10]
    589c: 11000463     	add	w3, w3, #0x1
    58a0: b9001003     	str	w3, [x0, #0x10]
    58a4: aa1503e1     	mov	x1, x21
    58a8: 34001f81     	cbz	w1, 0x5c98 <___pl_fn_10+0x428>
    58ac: f9400008     	ldr	x8, [x0]
    58b0: aa1503e1     	mov	x1, x21
    58b4: aa0003f6     	mov	x22, x0
    58b8: 2a0103e7     	mov	w7, w1
    58bc: 8b070d07     	add	x7, x8, x7, lsl #3
    58c0: f8615908     	ldr	x8, [x8, w1, uxtw #3]
    58c4: d360fd08     	lsr	x8, x8, #32
    58c8: 92403d08     	and	x8, x8, #0xffff
    58cc: 91000d08     	add	x8, x8, #0x3
    58d0: d37df108     	lsl	x8, x8, #3
    58d4: b86868f4     	ldr	w20, [x7, x8]
    58d8: 350000d4     	cbnz	w20, 0x58f0 <___pl_fn_10+0x80>
    58dc: 140000f0     	b	0x5c9c <___pl_fn_10+0x42c>
    58e0: aa1603e0     	mov	x0, x22
    58e4: f9401814     	ldr	x20, [x0, #0x30]
    58e8: aa1503f3     	mov	x19, x21
    58ec: 14000002     	b	0x58f4 <___pl_fn_10+0x84>
    58f0: aa1503f3     	mov	x19, x21
    58f4: 34001e73     	cbz	w19, 0x5cc0 <___pl_fn_10+0x450>
    58f8: aa1603e0     	mov	x0, x22
    58fc: f9400000     	ldr	x0, [x0]
    5900: 2a1303ef     	mov	w15, w19
    5904: 8b0f0c0f     	add	x15, x0, x15, lsl #3
    5908: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    590c: d360fc00     	lsr	x0, x0, #32
    5910: 92403c00     	and	x0, x0, #0xffff
    5914: 91001c00     	add	x0, x0, #0x7
    5918: d37df000     	lsl	x0, x0, #3
    591c: b86069e2     	ldr	w2, [x15, x0]
    5920: 35000082     	cbnz	w2, 0x5930 <___pl_fn_10+0xc0>
    5924: 140000e7     	b	0x5cc0 <___pl_fn_10+0x450>
    5928: aa1603e0     	mov	x0, x22
    592c: f9401802     	ldr	x2, [x0, #0x30]
    5930: 34001da2     	cbz	w2, 0x5ce4 <___pl_fn_10+0x474>
    5934: aa1603e0     	mov	x0, x22
    5938: f9400001     	ldr	x1, [x0]
    593c: 2a0203e0     	mov	w0, w2
    5940: 8b000c20     	add	x0, x1, x0, lsl #3
    5944: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    5948: d360fc21     	lsr	x1, x1, #32
    594c: 92403c21     	and	x1, x1, #0xffff
    5950: 91000821     	add	x1, x1, #0x2
    5954: d37df021     	lsl	x1, x1, #3
    5958: b8616803     	ldr	w3, [x0, x1]
    595c: 35000083     	cbnz	w3, 0x596c <___pl_fn_10+0xfc>
    5960: 140000e1     	b	0x5ce4 <___pl_fn_10+0x474>
    5964: aa1603e0     	mov	x0, x22
    5968: f9401803     	ldr	x3, [x0, #0x30]
    596c: 6b03029f     	cmp	w20, w3
    5970: 54000c80     	b.eq	0x5b00 <___pl_fn_10+0x290>
    5974: 34001c93     	cbz	w19, 0x5d04 <___pl_fn_10+0x494>
    5978: aa1603e0     	mov	x0, x22
    597c: f9400001     	ldr	x1, [x0]
    5980: 2a1303e0     	mov	w0, w19
    5984: 8b000c20     	add	x0, x1, x0, lsl #3
    5988: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    598c: d360fc21     	lsr	x1, x1, #32
    5990: 92403c21     	and	x1, x1, #0xffff
    5994: 91000c21     	add	x1, x1, #0x3
    5998: d37df021     	lsl	x1, x1, #3
    599c: b8616802     	ldr	w2, [x0, x1]
    59a0: 350000c2     	cbnz	w2, 0x59b8 <___pl_fn_10+0x148>
    59a4: 140000d8     	b	0x5d04 <___pl_fn_10+0x494>
    59a8: aa1603e0     	mov	x0, x22
    59ac: f9401802     	ldr	x2, [x0, #0x30]
    59b0: aa0203f9     	mov	x25, x2
    59b4: 14000002     	b	0x59bc <___pl_fn_10+0x14c>
    59b8: aa0203f9     	mov	x25, x2
    59bc: 34001b73     	cbz	w19, 0x5d28 <___pl_fn_10+0x4b8>
    59c0: aa1603e0     	mov	x0, x22
    59c4: f9400001     	ldr	x1, [x0]
    59c8: 2a1303e0     	mov	w0, w19
    59cc: 8b000c20     	add	x0, x1, x0, lsl #3
    59d0: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    59d4: d360fc21     	lsr	x1, x1, #32
    59d8: 92403c21     	and	x1, x1, #0xffff
    59dc: 91001c21     	add	x1, x1, #0x7
    59e0: d37df021     	lsl	x1, x1, #3
    59e4: b8616802     	ldr	w2, [x0, x1]
    59e8: 35000082     	cbnz	w2, 0x59f8 <___pl_fn_10+0x188>
    59ec: 140000cf     	b	0x5d28 <___pl_fn_10+0x4b8>
    59f0: aa1603e0     	mov	x0, x22
    59f4: f9401802     	ldr	x2, [x0, #0x30]
    59f8: 34001aa2     	cbz	w2, 0x5d4c <___pl_fn_10+0x4dc>
    59fc: aa1603e0     	mov	x0, x22
    5a00: f9400001     	ldr	x1, [x0]
    5a04: 2a0203e0     	mov	w0, w2
    5a08: 8b000c20     	add	x0, x1, x0, lsl #3
    5a0c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    5a10: d360fc21     	lsr	x1, x1, #32
    5a14: 92403c21     	and	x1, x1, #0xffff
    5a18: 91000821     	add	x1, x1, #0x2
    5a1c: d37df021     	lsl	x1, x1, #3
    5a20: b8616803     	ldr	w3, [x0, x1]
    5a24: 350000a3     	cbnz	w3, 0x5a38 <___pl_fn_10+0x1c8>
    5a28: 140000c9     	b	0x5d4c <___pl_fn_10+0x4dc>
    5a2c: aa1603e0     	mov	x0, x22
    5a30: f9401803     	ldr	x3, [x0, #0x30]
    5a34: 14000002     	b	0x5a3c <___pl_fn_10+0x1cc>
    5a38: aa1603e0     	mov	x0, x22
    5a3c: aa1603e0     	mov	x0, x22
    5a40: b9401815     	ldr	w21, [x0, #0x18]
    5a44: b9401c00     	ldr	w0, [x0, #0x1c]
    5a48: 110016a1     	add	w1, w21, #0x5
    5a4c: 6b00003f     	cmp	w1, w0
    5a50: 54001c48     	b.hi	0x5dd8 <___pl_fn_10+0x568>
    5a54: aa1603e0     	mov	x0, x22
    5a58: f9401001     	ldr	x1, [x0, #0x20]
    5a5c: 2a1503e0     	mov	w0, w21
    5a60: 8b000820     	add	x0, x1, x0, lsl #2
    5a64: b8355833     	str	w19, [x1, w21, uxtw #2]
    5a68: aa1803e2     	mov	x2, x24
    5a6c: b9000402     	str	w2, [x0, #0x4]
    5a70: aa1703f4     	mov	x20, x23
    5a74: b9000814     	str	w20, [x0, #0x8]
    5a78: aa1903e2     	mov	x2, x25
    5a7c: b9000c02     	str	w2, [x0, #0xc]
    5a80: b9001003     	str	w3, [x0, #0x10]
    5a84: 110016a0     	add	w0, w21, #0x5
    5a88: aa1603e1     	mov	x1, x22
    5a8c: b9001820     	str	w0, [x1, #0x18]
    5a90: aa1603e0     	mov	x0, x22
    5a94: b9401000     	ldr	w0, [x0, #0x10]
    5a98: b9401421     	ldr	w1, [x1, #0x14]
    5a9c: 6b01001f     	cmp	w0, w1
    5aa0: 54001822     	b.hs	0x5da4 <___pl_fn_10+0x534>
    5aa4: aa1803e1     	mov	x1, x24
    5aa8: aa1603e0     	mov	x0, x22
    5aac: 94000000     	bl	0x5aac <___pl_fn_10+0x23c>
    5ab0: aa1603e1     	mov	x1, x22
    5ab4: b9402c22     	ldr	w2, [x1, #0x2c]
    5ab8: 35002022     	cbnz	w2, 0x5ebc <___pl_fn_10+0x64c>
    5abc: aa1603e2     	mov	x2, x22
    5ac0: b9001855     	str	w21, [x2, #0x18]
    5ac4: 34001553     	cbz	w19, 0x5d6c <___pl_fn_10+0x4fc>
    5ac8: aa1603e1     	mov	x1, x22
    5acc: aa1303f5     	mov	x21, x19
    5ad0: f940002c     	ldr	x12, [x1]
    5ad4: 2a1303eb     	mov	w11, w19
    5ad8: 8b0b0d8b     	add	x11, x12, x11, lsl #3
    5adc: f873598d     	ldr	x13, [x12, w19, uxtw #3]
    5ae0: 2a0003ec     	mov	w12, w0
    5ae4: d360fdad     	lsr	x13, x13, #32
    5ae8: 92403dad     	and	x13, x13, #0xffff
    5aec: 91000dad     	add	x13, x13, #0x3
    5af0: f82d796c     	str	x12, [x11, x13, lsl #3]
    5af4: aa1603e0     	mov	x0, x22
    5af8: aa1403f7     	mov	x23, x20
    5afc: 1400004d     	b	0x5c30 <___pl_fn_10+0x3c0>
    5b00: aa1803e1     	mov	x1, x24
    5b04: aa1703f4     	mov	x20, x23
    5b08: aa1303f5     	mov	x21, x19
    5b0c: 35000093     	cbnz	w19, 0x5b1c <___pl_fn_10+0x2ac>
    5b10: 140000bf     	b	0x5e0c <___pl_fn_10+0x59c>
    5b14: aa1503f3     	mov	x19, x21
    5b18: 1400000c     	b	0x5b48 <___pl_fn_10+0x2d8>
    5b1c: aa1603e0     	mov	x0, x22
    5b20: f9400002     	ldr	x2, [x0]
    5b24: aa1503f3     	mov	x19, x21
    5b28: 2a1303e0     	mov	w0, w19
    5b2c: 8b000c40     	add	x0, x2, x0, lsl #3
    5b30: f8735842     	ldr	x2, [x2, w19, uxtw #3]
    5b34: 2a0103e1     	mov	w1, w1
    5b38: d360fc42     	lsr	x2, x2, #32
    5b3c: 92403c42     	and	x2, x2, #0xffff
    5b40: 91000c42     	add	x2, x2, #0x3
    5b44: f8227801     	str	x1, [x0, x2, lsl #3]
    5b48: aa1503f3     	mov	x19, x21
    5b4c: 35000093     	cbnz	w19, 0x5b5c <___pl_fn_10+0x2ec>
    5b50: 140000bc     	b	0x5e40 <___pl_fn_10+0x5d0>
    5b54: aa1503f3     	mov	x19, x21
    5b58: 1400000c     	b	0x5b88 <___pl_fn_10+0x318>
    5b5c: aa1603e0     	mov	x0, x22
    5b60: f9400001     	ldr	x1, [x0]
    5b64: aa1503f3     	mov	x19, x21
    5b68: 2a1303e0     	mov	w0, w19
    5b6c: 8b000c20     	add	x0, x1, x0, lsl #3
    5b70: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    5b74: d2800021     	mov	x1, #0x1                ; =1
    5b78: d360fc42     	lsr	x2, x2, #32
    5b7c: 92403c42     	and	x2, x2, #0xffff
    5b80: 91001042     	add	x2, x2, #0x4
    5b84: f8227801     	str	x1, [x0, x2, lsl #3]
    5b88: aa1503f3     	mov	x19, x21
    5b8c: 34001753     	cbz	w19, 0x5e74 <___pl_fn_10+0x604>
    5b90: aa1603e0     	mov	x0, x22
    5b94: f9400001     	ldr	x1, [x0]
    5b98: aa1503f3     	mov	x19, x21
    5b9c: 2a1303e0     	mov	w0, w19
    5ba0: 8b000c20     	add	x0, x1, x0, lsl #3
    5ba4: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    5ba8: d360fc21     	lsr	x1, x1, #32
    5bac: 92403c21     	and	x1, x1, #0xffff
    5bb0: 91000822     	add	x2, x1, #0x2
    5bb4: f8627813     	ldr	x19, [x0, x2, lsl #3]
    5bb8: f100083f     	cmp	x1, #0x2
    5bbc: 540000c0     	b.eq	0x5bd4 <___pl_fn_10+0x364>
    5bc0: f9400800     	ldr	x0, [x0, #0x10]
    5bc4: 37101580     	tbnz	w0, #0x2, 0x5e74 <___pl_fn_10+0x604>
    5bc8: 14000003     	b	0x5bd4 <___pl_fn_10+0x364>
    5bcc: aa1603e0     	mov	x0, x22
    5bd0: f9401813     	ldr	x19, [x0, #0x30]
    5bd4: 34001634     	cbz	w20, 0x5e98 <___pl_fn_10+0x628>
    5bd8: aa1603e0     	mov	x0, x22
    5bdc: f9400000     	ldr	x0, [x0]
    5be0: 2a1403e1     	mov	w1, w20
    5be4: 8b010c01     	add	x1, x0, x1, lsl #3
    5be8: f8745800     	ldr	x0, [x0, w20, uxtw #3]
    5bec: d360fc00     	lsr	x0, x0, #32
    5bf0: 92403c02     	and	x2, x0, #0xffff
    5bf4: 91000840     	add	x0, x2, #0x2
    5bf8: f8607820     	ldr	x0, [x1, x0, lsl #3]
    5bfc: f100085f     	cmp	x2, #0x2
    5c00: 54000061     	b.ne	0x5c0c <___pl_fn_10+0x39c>
    5c04: aa1403f7     	mov	x23, x20
    5c08: 14000007     	b	0x5c24 <___pl_fn_10+0x3b4>
    5c0c: f9400821     	ldr	x1, [x1, #0x10]
    5c10: 37101441     	tbnz	w1, #0x2, 0x5e98 <___pl_fn_10+0x628>
    5c14: aa1403f7     	mov	x23, x20
    5c18: 14000003     	b	0x5c24 <___pl_fn_10+0x3b4>
    5c1c: aa1603e0     	mov	x0, x22
    5c20: f9401800     	ldr	x0, [x0, #0x30]
    5c24: eb00027f     	cmp	x19, x0
    5c28: 540001ec     	b.gt	0x5c64 <___pl_fn_10+0x3f4>
    5c2c: aa1603e0     	mov	x0, x22
    5c30: aa1603e0     	mov	x0, x22
    5c34: b9401000     	ldr	w0, [x0, #0x10]
    5c38: 51000400     	sub	w0, w0, #0x1
    5c3c: aa1603e1     	mov	x1, x22
    5c40: b9001020     	str	w0, [x1, #0x10]
    5c44: aa1703e0     	mov	x0, x23
    5c48: 9100c3ff     	add	sp, sp, #0x30
    5c4c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5c50: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5c54: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5c58: f84107f9     	ldr	x25, [sp], #0x10
    5c5c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5c60: d65f03c0     	ret
    5c64: aa1603e0     	mov	x0, x22
    5c68: b9401000     	ldr	w0, [x0, #0x10]
    5c6c: 51000400     	sub	w0, w0, #0x1
    5c70: aa1603e1     	mov	x1, x22
    5c74: b9001020     	str	w0, [x1, #0x10]
    5c78: aa1503e0     	mov	x0, x21
    5c7c: 9100c3ff     	add	sp, sp, #0x30
    5c80: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5c84: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5c88: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5c8c: f84107f9     	ldr	x25, [sp], #0x10
    5c90: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5c94: d65f03c0     	ret
    5c98: aa0003f6     	mov	x22, x0
    5c9c: 52801481     	mov	w1, #0xa4               ; =164
    5ca0: 52800063     	mov	w3, #0x3                ; =3
    5ca4: 90000009     	adrp	x9, 0x5000 <___pl_fn_7+0x60>
    5ca8: f9400129     	ldr	x9, [x9]
    5cac: aa1603e0     	mov	x0, x22
    5cb0: aa1503e2     	mov	x2, x21
    5cb4: d63f0120     	blr	x9
    5cb8: 34ffe140     	cbz	w0, 0x58e0 <___pl_fn_10+0x70>
    5cbc: 14000080     	b	0x5ebc <___pl_fn_10+0x64c>
    5cc0: 528014a1     	mov	w1, #0xa5               ; =165
    5cc4: 528000e3     	mov	w3, #0x7                ; =7
    5cc8: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5ccc: f9400084     	ldr	x4, [x4]
    5cd0: aa1603e0     	mov	x0, x22
    5cd4: aa1303e2     	mov	x2, x19
    5cd8: d63f0080     	blr	x4
    5cdc: 34ffe260     	cbz	w0, 0x5928 <___pl_fn_10+0xb8>
    5ce0: 14000077     	b	0x5ebc <___pl_fn_10+0x64c>
    5ce4: 528014c1     	mov	w1, #0xa6               ; =166
    5ce8: 52800043     	mov	w3, #0x2                ; =2
    5cec: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5cf0: f9400084     	ldr	x4, [x4]
    5cf4: aa1603e0     	mov	x0, x22
    5cf8: d63f0080     	blr	x4
    5cfc: 34ffe340     	cbz	w0, 0x5964 <___pl_fn_10+0xf4>
    5d00: 1400006f     	b	0x5ebc <___pl_fn_10+0x64c>
    5d04: 528014e1     	mov	w1, #0xa7               ; =167
    5d08: 52800063     	mov	w3, #0x3                ; =3
    5d0c: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5d10: f9400084     	ldr	x4, [x4]
    5d14: aa1603e0     	mov	x0, x22
    5d18: aa1303e2     	mov	x2, x19
    5d1c: d63f0080     	blr	x4
    5d20: 34ffe440     	cbz	w0, 0x59a8 <___pl_fn_10+0x138>
    5d24: 14000066     	b	0x5ebc <___pl_fn_10+0x64c>
    5d28: 52801501     	mov	w1, #0xa8               ; =168
    5d2c: 528000e3     	mov	w3, #0x7                ; =7
    5d30: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5d34: f9400084     	ldr	x4, [x4]
    5d38: aa1603e0     	mov	x0, x22
    5d3c: aa1303e2     	mov	x2, x19
    5d40: d63f0080     	blr	x4
    5d44: 34ffe560     	cbz	w0, 0x59f0 <___pl_fn_10+0x180>
    5d48: 1400005d     	b	0x5ebc <___pl_fn_10+0x64c>
    5d4c: 52801521     	mov	w1, #0xa9               ; =169
    5d50: 52800043     	mov	w3, #0x2                ; =2
    5d54: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5d58: f9400084     	ldr	x4, [x4]
    5d5c: aa1603e0     	mov	x0, x22
    5d60: d63f0080     	blr	x4
    5d64: 34ffe640     	cbz	w0, 0x5a2c <___pl_fn_10+0x1bc>
    5d68: 14000055     	b	0x5ebc <___pl_fn_10+0x64c>
    5d6c: aa1303f5     	mov	x21, x19
    5d70: d2800066     	mov	x6, #0x3                ; =3
    5d74: 910003e3     	mov	x3, sp
    5d78: f80003e6     	stur	x6, [sp]
    5d7c: 2a0003e7     	mov	w7, w0
    5d80: f80083e7     	stur	x7, [sp, #0x8]
    5d84: 52801581     	mov	w1, #0xac               ; =172
    5d88: 90000008     	adrp	x8, 0x5000 <___pl_fn_7+0x60>
    5d8c: f9400108     	ldr	x8, [x8]
    5d90: aa1503e2     	mov	x2, x21
    5d94: aa1603e0     	mov	x0, x22
    5d98: d63f0100     	blr	x8
    5d9c: 34ffeac0     	cbz	w0, 0x5af4 <___pl_fn_10+0x284>
    5da0: 14000047     	b	0x5ebc <___pl_fn_10+0x64c>
    5da4: 52801561     	mov	w1, #0xab               ; =171
    5da8: 9000000e     	adrp	x14, 0x5000 <___pl_fn_7+0x60>
    5dac: f94001ce     	ldr	x14, [x14]
    5db0: aa1603e0     	mov	x0, x22
    5db4: d63f01c0     	blr	x14
    5db8: 52800000     	mov	w0, #0x0                ; =0
    5dbc: 9100c3ff     	add	sp, sp, #0x30
    5dc0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5dc4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5dc8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5dcc: f84107f9     	ldr	x25, [sp], #0x10
    5dd0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5dd4: d65f03c0     	ret
    5dd8: 52801541     	mov	w1, #0xaa               ; =170
    5ddc: 9000000f     	adrp	x15, 0x5000 <___pl_fn_7+0x60>
    5de0: f94001ef     	ldr	x15, [x15]
    5de4: aa1603e0     	mov	x0, x22
    5de8: d63f01e0     	blr	x15
    5dec: 52800000     	mov	w0, #0x0                ; =0
    5df0: 9100c3ff     	add	sp, sp, #0x30
    5df4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5df8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5dfc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5e00: f84107f9     	ldr	x25, [sp], #0x10
    5e04: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5e08: d65f03c0     	ret
    5e0c: d2800060     	mov	x0, #0x3                ; =3
    5e10: 910043e3     	add	x3, sp, #0x10
    5e14: f80103e0     	stur	x0, [sp, #0x10]
    5e18: 2a0103e0     	mov	w0, w1
    5e1c: f80183e0     	stur	x0, [sp, #0x18]
    5e20: 528015a1     	mov	w1, #0xad               ; =173
    5e24: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5e28: f9400084     	ldr	x4, [x4]
    5e2c: aa1603e0     	mov	x0, x22
    5e30: aa1503e2     	mov	x2, x21
    5e34: d63f0080     	blr	x4
    5e38: 34ffe6e0     	cbz	w0, 0x5b14 <___pl_fn_10+0x2a4>
    5e3c: 14000020     	b	0x5ebc <___pl_fn_10+0x64c>
    5e40: d2800080     	mov	x0, #0x4                ; =4
    5e44: 910083e3     	add	x3, sp, #0x20
    5e48: f80203e0     	stur	x0, [sp, #0x20]
    5e4c: d2800020     	mov	x0, #0x1                ; =1
    5e50: f80283e0     	stur	x0, [sp, #0x28]
    5e54: 528015c1     	mov	w1, #0xae               ; =174
    5e58: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5e5c: f9400084     	ldr	x4, [x4]
    5e60: aa1603e0     	mov	x0, x22
    5e64: aa1503e2     	mov	x2, x21
    5e68: d63f0080     	blr	x4
    5e6c: 34ffe740     	cbz	w0, 0x5b54 <___pl_fn_10+0x2e4>
    5e70: 14000013     	b	0x5ebc <___pl_fn_10+0x64c>
    5e74: 528015e1     	mov	w1, #0xaf               ; =175
    5e78: 52800043     	mov	w3, #0x2                ; =2
    5e7c: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5e80: f9400084     	ldr	x4, [x4]
    5e84: aa1603e0     	mov	x0, x22
    5e88: aa1503e2     	mov	x2, x21
    5e8c: d63f0080     	blr	x4
    5e90: 34ffe9e0     	cbz	w0, 0x5bcc <___pl_fn_10+0x35c>
    5e94: 1400000a     	b	0x5ebc <___pl_fn_10+0x64c>
    5e98: 52801601     	mov	w1, #0xb0               ; =176
    5e9c: 52800043     	mov	w3, #0x2                ; =2
    5ea0: 90000004     	adrp	x4, 0x5000 <___pl_fn_7+0x60>
    5ea4: f9400084     	ldr	x4, [x4]
    5ea8: aa1603e0     	mov	x0, x22
    5eac: aa1403e2     	mov	x2, x20
    5eb0: d63f0080     	blr	x4
    5eb4: aa1403f7     	mov	x23, x20
    5eb8: 34ffeb20     	cbz	w0, 0x5c1c <___pl_fn_10+0x3ac>
    5ebc: 52800000     	mov	w0, #0x0                ; =0
    5ec0: 9100c3ff     	add	sp, sp, #0x30
    5ec4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5ec8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5ecc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5ed0: f84107f9     	ldr	x25, [sp], #0x10
    5ed4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5ed8: d65f03c0     	ret

0000000000005edc <___pl_fn_11>:
    5edc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    5ee0: 910003fd     	mov	x29, sp
    5ee4: f81f0ffa     	str	x26, [sp, #-0x10]!
    5ee8: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    5eec: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    5ef0: d10143ff     	sub	sp, sp, #0x50
    5ef4: aa0103f5     	mov	x21, x1
    5ef8: b9401001     	ldr	w1, [x0, #0x10]
    5efc: 11000421     	add	w1, w1, #0x1
    5f00: b9001001     	str	w1, [x0, #0x10]
    5f04: aa1503e1     	mov	x1, x21
    5f08: 34003181     	cbz	w1, 0x6538 <___pl_fn_11+0x65c>
    5f0c: f9400001     	ldr	x1, [x0]
    5f10: aa0003f4     	mov	x20, x0
    5f14: aa1503e0     	mov	x0, x21
    5f18: 2a0003e0     	mov	w0, w0
    5f1c: 8b000c20     	add	x0, x1, x0, lsl #3
    5f20: aa1503e2     	mov	x2, x21
    5f24: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    5f28: d360fc21     	lsr	x1, x1, #32
    5f2c: 92403c21     	and	x1, x1, #0xffff
    5f30: 91001021     	add	x1, x1, #0x4
    5f34: d37df021     	lsl	x1, x1, #3
    5f38: 38616800     	ldrb	w0, [x0, x1]
    5f3c: 53001c01     	uxtb	w1, w0
    5f40: 7100083f     	cmp	w1, #0x2
    5f44: 54000081     	b.ne	0x5f54 <___pl_fn_11+0x78>
    5f48: 1400017d     	b	0x653c <___pl_fn_11+0x660>
    5f4c: aa1403e0     	mov	x0, x20
    5f50: f9401800     	ldr	x0, [x0, #0x30]
    5f54: 72001c1f     	tst	w0, #0xff
    5f58: 54000061     	b.ne	0x5f64 <___pl_fn_11+0x88>
    5f5c: 52800000     	mov	w0, #0x0                ; =0
    5f60: 14000015     	b	0x5fb4 <___pl_fn_11+0xd8>
    5f64: aa1503f3     	mov	x19, x21
    5f68: 34002fd3     	cbz	w19, 0x6560 <___pl_fn_11+0x684>
    5f6c: aa1403e0     	mov	x0, x20
    5f70: f9400004     	ldr	x4, [x0]
    5f74: 2a1303e3     	mov	w3, w19
    5f78: 8b030c83     	add	x3, x4, x3, lsl #3
    5f7c: f8735884     	ldr	x4, [x4, w19, uxtw #3]
    5f80: d360fc84     	lsr	x4, x4, #32
    5f84: 92403c84     	and	x4, x4, #0xffff
    5f88: 91001484     	add	x4, x4, #0x5
    5f8c: d37df084     	lsl	x4, x4, #3
    5f90: 38646860     	ldrb	w0, [x3, x4]
    5f94: 53001c03     	uxtb	w3, w0
    5f98: 7100087f     	cmp	w3, #0x2
    5f9c: 540000a1     	b.ne	0x5fb0 <___pl_fn_11+0xd4>
    5fa0: 14000170     	b	0x6560 <___pl_fn_11+0x684>
    5fa4: aa1403e0     	mov	x0, x20
    5fa8: f9401800     	ldr	x0, [x0, #0x30]
    5fac: 14000002     	b	0x5fb4 <___pl_fn_11+0xd8>
    5fb0: aa1303f5     	mov	x21, x19
    5fb4: 72001c1f     	tst	w0, #0xff
    5fb8: 54000061     	b.ne	0x5fc4 <___pl_fn_11+0xe8>
    5fbc: 52800003     	mov	w3, #0x0                ; =0
    5fc0: 14000016     	b	0x6018 <___pl_fn_11+0x13c>
    5fc4: aa1503e1     	mov	x1, x21
    5fc8: 34002e01     	cbz	w1, 0x6588 <___pl_fn_11+0x6ac>
    5fcc: aa1403e0     	mov	x0, x20
    5fd0: f9400001     	ldr	x1, [x0]
    5fd4: aa1503e0     	mov	x0, x21
    5fd8: 2a0003e0     	mov	w0, w0
    5fdc: 8b000c20     	add	x0, x1, x0, lsl #3
    5fe0: aa1503e2     	mov	x2, x21
    5fe4: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    5fe8: d360fc21     	lsr	x1, x1, #32
    5fec: 92403c21     	and	x1, x1, #0xffff
    5ff0: 91001821     	add	x1, x1, #0x6
    5ff4: d37df021     	lsl	x1, x1, #3
    5ff8: 3861680e     	ldrb	w14, [x0, x1]
    5ffc: 53001dc0     	uxtb	w0, w14
    6000: 7100081f     	cmp	w0, #0x2
    6004: 54000081     	b.ne	0x6014 <___pl_fn_11+0x138>
    6008: 14000160     	b	0x6588 <___pl_fn_11+0x6ac>
    600c: aa1403e0     	mov	x0, x20
    6010: f940180e     	ldr	x14, [x0, #0x30]
    6014: 520001c3     	eor	w3, w14, #0x1
    6018: 72001c7f     	tst	w3, #0xff
    601c: 540004c1     	b.ne	0x60b4 <___pl_fn_11+0x1d8>
    6020: aa1503e1     	mov	x1, x21
    6024: 34002c41     	cbz	w1, 0x65ac <___pl_fn_11+0x6d0>
    6028: aa1403e0     	mov	x0, x20
    602c: f9400001     	ldr	x1, [x0]
    6030: aa1503e0     	mov	x0, x21
    6034: 2a0003e0     	mov	w0, w0
    6038: 8b000c20     	add	x0, x1, x0, lsl #3
    603c: aa1503e2     	mov	x2, x21
    6040: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6044: d360fc21     	lsr	x1, x1, #32
    6048: 92403c21     	and	x1, x1, #0xffff
    604c: 91001c21     	add	x1, x1, #0x7
    6050: d37df021     	lsl	x1, x1, #3
    6054: b8616802     	ldr	w2, [x0, x1]
    6058: 35000082     	cbnz	w2, 0x6068 <___pl_fn_11+0x18c>
    605c: 14000154     	b	0x65ac <___pl_fn_11+0x6d0>
    6060: aa1403e0     	mov	x0, x20
    6064: f9401802     	ldr	x2, [x0, #0x30]
    6068: 34002b42     	cbz	w2, 0x65d0 <___pl_fn_11+0x6f4>
    606c: aa1403e0     	mov	x0, x20
    6070: f9400001     	ldr	x1, [x0]
    6074: 2a0203e0     	mov	w0, w2
    6078: 8b000c20     	add	x0, x1, x0, lsl #3
    607c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6080: d360fc21     	lsr	x1, x1, #32
    6084: 92403c21     	and	x1, x1, #0xffff
    6088: 91000821     	add	x1, x1, #0x2
    608c: d37df021     	lsl	x1, x1, #3
    6090: b861680a     	ldr	w10, [x0, x1]
    6094: 3500008a     	cbnz	w10, 0x60a4 <___pl_fn_11+0x1c8>
    6098: 1400014e     	b	0x65d0 <___pl_fn_11+0x6f4>
    609c: aa1403e0     	mov	x0, x20
    60a0: f940180a     	ldr	x10, [x0, #0x30]
    60a4: 34002a6a     	cbz	w10, 0x65f0 <___pl_fn_11+0x714>
    60a8: aa1403e0     	mov	x0, x20
    60ac: aa0a03fa     	mov	x26, x10
    60b0: 140000ad     	b	0x6364 <___pl_fn_11+0x488>
    60b4: aa1503e1     	mov	x1, x21
    60b8: 34002b41     	cbz	w1, 0x6620 <___pl_fn_11+0x744>
    60bc: aa1403e0     	mov	x0, x20
    60c0: f9400001     	ldr	x1, [x0]
    60c4: aa1503ec     	mov	x12, x21
    60c8: 2a0c03e0     	mov	w0, w12
    60cc: 8b000c20     	add	x0, x1, x0, lsl #3
    60d0: aa1503ef     	mov	x15, x21
    60d4: f86f5821     	ldr	x1, [x1, w15, uxtw #3]
    60d8: d360fc21     	lsr	x1, x1, #32
    60dc: 92403c21     	and	x1, x1, #0xffff
    60e0: 91000c21     	add	x1, x1, #0x3
    60e4: d37df021     	lsl	x1, x1, #3
    60e8: b861680a     	ldr	w10, [x0, x1]
    60ec: 3500008a     	cbnz	w10, 0x60fc <___pl_fn_11+0x220>
    60f0: 1400014c     	b	0x6620 <___pl_fn_11+0x744>
    60f4: aa1403e0     	mov	x0, x20
    60f8: f940180a     	ldr	x10, [x0, #0x30]
    60fc: 52800003     	mov	w3, #0x0                ; =0
    6100: 340043ea     	cbz	w10, 0x697c <___pl_fn_11+0xaa0>
    6104: 34002a0a     	cbz	w10, 0x6644 <___pl_fn_11+0x768>
    6108: aa1403e0     	mov	x0, x20
    610c: f9400001     	ldr	x1, [x0]
    6110: 2a0a03e0     	mov	w0, w10
    6114: 8b000c20     	add	x0, x1, x0, lsl #3
    6118: f86a5821     	ldr	x1, [x1, w10, uxtw #3]
    611c: aa0a03fa     	mov	x26, x10
    6120: d360fc21     	lsr	x1, x1, #32
    6124: 92403c21     	and	x1, x1, #0xffff
    6128: d37df021     	lsl	x1, x1, #3
    612c: b8616800     	ldr	w0, [x0, x1]
    6130: 350000c0     	cbnz	w0, 0x6148 <___pl_fn_11+0x26c>
    6134: 14000145     	b	0x6648 <___pl_fn_11+0x76c>
    6138: aa1403e0     	mov	x0, x20
    613c: f9401800     	ldr	x0, [x0, #0x30]
    6140: aa1503e1     	mov	x1, x21
    6144: 14000002     	b	0x614c <___pl_fn_11+0x270>
    6148: aa1503e1     	mov	x1, x21
    614c: aa1503e1     	mov	x1, x21
    6150: 35000081     	cbnz	w1, 0x6160 <___pl_fn_11+0x284>
    6154: 14000145     	b	0x6668 <___pl_fn_11+0x78c>
    6158: aa1503e1     	mov	x1, x21
    615c: 1400000c     	b	0x618c <___pl_fn_11+0x2b0>
    6160: aa1403ec     	mov	x12, x20
    6164: f9400186     	ldr	x6, [x12]
    6168: aa1503e1     	mov	x1, x21
    616c: 2a0103e5     	mov	w5, w1
    6170: 8b050cc5     	add	x5, x6, x5, lsl #3
    6174: f86158c7     	ldr	x7, [x6, w1, uxtw #3]
    6178: 2a0003e6     	mov	w6, w0
    617c: d360fce7     	lsr	x7, x7, #32
    6180: 92403ce7     	and	x7, x7, #0xffff
    6184: 91000ce7     	add	x7, x7, #0x3
    6188: f82778a6     	str	x6, [x5, x7, lsl #3]
    618c: aa1503e1     	mov	x1, x21
    6190: 34002861     	cbz	w1, 0x669c <___pl_fn_11+0x7c0>
    6194: aa1403e0     	mov	x0, x20
    6198: f940000a     	ldr	x10, [x0]
    619c: aa1503e1     	mov	x1, x21
    61a0: 2a0103e9     	mov	w9, w1
    61a4: 8b090d49     	add	x9, x10, x9, lsl #3
    61a8: f861594a     	ldr	x10, [x10, w1, uxtw #3]
    61ac: d360fd4a     	lsr	x10, x10, #32
    61b0: 92403d4a     	and	x10, x10, #0xffff
    61b4: 91000d4a     	add	x10, x10, #0x3
    61b8: d37df14a     	lsl	x10, x10, #3
    61bc: b86a6933     	ldr	w19, [x9, x10]
    61c0: 350000d3     	cbnz	w19, 0x61d8 <___pl_fn_11+0x2fc>
    61c4: 14000136     	b	0x669c <___pl_fn_11+0x7c0>
    61c8: aa1403e0     	mov	x0, x20
    61cc: f9401813     	ldr	x19, [x0, #0x30]
    61d0: aa1503e1     	mov	x1, x21
    61d4: 14000002     	b	0x61dc <___pl_fn_11+0x300>
    61d8: aa1503e1     	mov	x1, x21
    61dc: aa1503e1     	mov	x1, x21
    61e0: 34002701     	cbz	w1, 0x66c0 <___pl_fn_11+0x7e4>
    61e4: aa1403e0     	mov	x0, x20
    61e8: f9400001     	ldr	x1, [x0]
    61ec: aa1503e0     	mov	x0, x21
    61f0: 2a0003e0     	mov	w0, w0
    61f4: 8b000c20     	add	x0, x1, x0, lsl #3
    61f8: aa1503e2     	mov	x2, x21
    61fc: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6200: d360fc21     	lsr	x1, x1, #32
    6204: 92403c21     	and	x1, x1, #0xffff
    6208: 91001c21     	add	x1, x1, #0x7
    620c: d37df021     	lsl	x1, x1, #3
    6210: b8616802     	ldr	w2, [x0, x1]
    6214: 35000082     	cbnz	w2, 0x6224 <___pl_fn_11+0x348>
    6218: 1400012a     	b	0x66c0 <___pl_fn_11+0x7e4>
    621c: aa1403e0     	mov	x0, x20
    6220: f9401802     	ldr	x2, [x0, #0x30]
    6224: 34002602     	cbz	w2, 0x66e4 <___pl_fn_11+0x808>
    6228: aa1403e0     	mov	x0, x20
    622c: f9400001     	ldr	x1, [x0]
    6230: 2a0203e0     	mov	w0, w2
    6234: 8b000c20     	add	x0, x1, x0, lsl #3
    6238: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    623c: d360fc21     	lsr	x1, x1, #32
    6240: 92403c21     	and	x1, x1, #0xffff
    6244: 91000821     	add	x1, x1, #0x2
    6248: d37df021     	lsl	x1, x1, #3
    624c: b8616800     	ldr	w0, [x0, x1]
    6250: 35000080     	cbnz	w0, 0x6260 <___pl_fn_11+0x384>
    6254: 14000124     	b	0x66e4 <___pl_fn_11+0x808>
    6258: aa1403e0     	mov	x0, x20
    625c: f9401800     	ldr	x0, [x0, #0x30]
    6260: 6b00027f     	cmp	w19, w0
    6264: 54000220     	b.eq	0x62a8 <___pl_fn_11+0x3cc>
    6268: aa1503e1     	mov	x1, x21
    626c: 340024c1     	cbz	w1, 0x6704 <___pl_fn_11+0x828>
    6270: aa1403e0     	mov	x0, x20
    6274: f9400001     	ldr	x1, [x0]
    6278: aa1503e0     	mov	x0, x21
    627c: 2a0003e0     	mov	w0, w0
    6280: 8b000c20     	add	x0, x1, x0, lsl #3
    6284: aa1503e2     	mov	x2, x21
    6288: f8625822     	ldr	x2, [x1, w2, uxtw #3]
    628c: d2800021     	mov	x1, #0x1                ; =1
    6290: d360fc42     	lsr	x2, x2, #32
    6294: 92403c42     	and	x2, x2, #0xffff
    6298: 91001042     	add	x2, x2, #0x4
    629c: f8227801     	str	x1, [x0, x2, lsl #3]
    62a0: aa1503e1     	mov	x1, x21
    62a4: 14000010     	b	0x62e4 <___pl_fn_11+0x408>
    62a8: aa1503e1     	mov	x1, x21
    62ac: 34002461     	cbz	w1, 0x6738 <___pl_fn_11+0x85c>
    62b0: aa1403e0     	mov	x0, x20
    62b4: f9400001     	ldr	x1, [x0]
    62b8: aa1503e5     	mov	x5, x21
    62bc: 2a0503e0     	mov	w0, w5
    62c0: 8b000c20     	add	x0, x1, x0, lsl #3
    62c4: aa1503e8     	mov	x8, x21
    62c8: f8685822     	ldr	x2, [x1, w8, uxtw #3]
    62cc: d2800001     	mov	x1, #0x0                ; =0
    62d0: d360fc42     	lsr	x2, x2, #32
    62d4: 92403c42     	and	x2, x2, #0xffff
    62d8: 91001042     	add	x2, x2, #0x4
    62dc: f8227801     	str	x1, [x0, x2, lsl #3]
    62e0: aa1503e1     	mov	x1, x21
    62e4: aa1503e1     	mov	x1, x21
    62e8: 35000081     	cbnz	w1, 0x62f8 <___pl_fn_11+0x41c>
    62ec: 14000120     	b	0x676c <___pl_fn_11+0x890>
    62f0: aa1503e1     	mov	x1, x21
    62f4: 1400000e     	b	0x632c <___pl_fn_11+0x450>
    62f8: aa1403e0     	mov	x0, x20
    62fc: f9400001     	ldr	x1, [x0]
    6300: aa1503e0     	mov	x0, x21
    6304: 2a0003e0     	mov	w0, w0
    6308: 8b000c20     	add	x0, x1, x0, lsl #3
    630c: aa1503e2     	mov	x2, x21
    6310: f8625822     	ldr	x2, [x1, w2, uxtw #3]
    6314: d2800001     	mov	x1, #0x0                ; =0
    6318: d360fc42     	lsr	x2, x2, #32
    631c: 92403c42     	and	x2, x2, #0xffff
    6320: 91001442     	add	x2, x2, #0x5
    6324: f8227801     	str	x1, [x0, x2, lsl #3]
    6328: aa1503e1     	mov	x1, x21
    632c: aa1503e1     	mov	x1, x21
    6330: 34002381     	cbz	w1, 0x67a0 <___pl_fn_11+0x8c4>
    6334: aa1403e0     	mov	x0, x20
    6338: f9400003     	ldr	x3, [x0]
    633c: aa1503e1     	mov	x1, x21
    6340: 2a0103e2     	mov	w2, w1
    6344: 8b020c62     	add	x2, x3, x2, lsl #3
    6348: f8615864     	ldr	x4, [x3, w1, uxtw #3]
    634c: d2800003     	mov	x3, #0x0                ; =0
    6350: d360fc84     	lsr	x4, x4, #32
    6354: 92403c84     	and	x4, x4, #0xffff
    6358: 91001884     	add	x4, x4, #0x6
    635c: f8247843     	str	x3, [x2, x4, lsl #3]
    6360: aa1403e0     	mov	x0, x20
    6364: aa1403e0     	mov	x0, x20
    6368: b9401813     	ldr	w19, [x0, #0x18]
    636c: b9401c05     	ldr	w5, [x0, #0x1c]
    6370: 11000a66     	add	w6, w19, #0x2
    6374: 6b0500df     	cmp	w6, w5
    6378: 54002ea8     	b.hi	0x694c <___pl_fn_11+0xa70>
    637c: aa1403e0     	mov	x0, x20
    6380: f9401007     	ldr	x7, [x0, #0x20]
    6384: 2a1303e8     	mov	w8, w19
    6388: 8b0808e8     	add	x8, x7, x8, lsl #2
    638c: aa1503e1     	mov	x1, x21
    6390: b83358e1     	str	w1, [x7, w19, uxtw #2]
    6394: aa1a03e2     	mov	x2, x26
    6398: b9000502     	str	w2, [x8, #0x4]
    639c: 11000a69     	add	w9, w19, #0x2
    63a0: b9001809     	str	w9, [x0, #0x18]
    63a4: 52800000     	mov	w0, #0x0                ; =0
    63a8: aa0003f6     	mov	x22, x0
    63ac: 34002b81     	cbz	w1, 0x691c <___pl_fn_11+0xa40>
    63b0: aa1403e0     	mov	x0, x20
    63b4: f940000b     	ldr	x11, [x0]
    63b8: aa1503e1     	mov	x1, x21
    63bc: f861596b     	ldr	x11, [x11, w1, uxtw #3]
    63c0: 51000d6c     	sub	w12, w11, #0x3
    63c4: 7100099f     	cmp	w12, #0x2
    63c8: 54002923     	b.lo	0x68ec <___pl_fn_11+0xa10>
    63cc: 5100156e     	sub	w14, w11, #0x5
    63d0: 710015df     	cmp	w14, #0x5
    63d4: 540028c2     	b.hs	0x68ec <___pl_fn_11+0xa10>
    63d8: 9a8e23e1     	csel	x1, xzr, x14, hs
    63dc: 1000008f     	adr	x15, 0x63ec <___pl_fn_11+0x510>
    63e0: b8a159e1     	ldrsw	x1, [x15, w1, uxtw #2]
    63e4: 8b0101ef     	add	x15, x15, x1
    63e8: d61f01e0     	br	x15
    63ec: 000000e8     	udf	#0xe8
    63f0: 000000b4     	udf	#0xb4
    63f4: 00000080     	udf	#0x80
    63f8: 0000004c     	udf	#0x4c
    63fc: 00000018     	udf	#0x18
    6400: 1400013b     	b	0x68ec <___pl_fn_11+0xa10>
    6404: aa1403e0     	mov	x0, x20
    6408: b9401001     	ldr	w1, [x0, #0x10]
    640c: b9401403     	ldr	w3, [x0, #0x14]
    6410: 6b03003f     	cmp	w1, w3
    6414: 54001e02     	b.hs	0x67d4 <___pl_fn_11+0x8f8>
    6418: aa1503e1     	mov	x1, x21
    641c: aa1403e0     	mov	x0, x20
    6420: 94000000     	bl	0x6420 <___pl_fn_11+0x544>
    6424: aa1403e1     	mov	x1, x20
    6428: b9402c21     	ldr	w1, [x1, #0x2c]
    642c: 350023a1     	cbnz	w1, 0x68a0 <___pl_fn_11+0x9c4>
    6430: aa1403e1     	mov	x1, x20
    6434: 14000034     	b	0x6504 <___pl_fn_11+0x628>
    6438: aa1403e0     	mov	x0, x20
    643c: b9401001     	ldr	w1, [x0, #0x10]
    6440: b9401403     	ldr	w3, [x0, #0x14]
    6444: 6b03003f     	cmp	w1, w3
    6448: 54001e02     	b.hs	0x6808 <___pl_fn_11+0x92c>
    644c: aa1503e1     	mov	x1, x21
    6450: aa1403e0     	mov	x0, x20
    6454: 94000000     	bl	0x6454 <___pl_fn_11+0x578>
    6458: aa1403e1     	mov	x1, x20
    645c: b9402c21     	ldr	w1, [x1, #0x2c]
    6460: 35002201     	cbnz	w1, 0x68a0 <___pl_fn_11+0x9c4>
    6464: aa1403e1     	mov	x1, x20
    6468: 14000027     	b	0x6504 <___pl_fn_11+0x628>
    646c: aa1403e0     	mov	x0, x20
    6470: b9401001     	ldr	w1, [x0, #0x10]
    6474: b9401403     	ldr	w3, [x0, #0x14]
    6478: 6b03003f     	cmp	w1, w3
    647c: 54001e02     	b.hs	0x683c <___pl_fn_11+0x960>
    6480: aa1503e1     	mov	x1, x21
    6484: aa1403e0     	mov	x0, x20
    6488: 94000000     	bl	0x6488 <___pl_fn_11+0x5ac>
    648c: aa1403eb     	mov	x11, x20
    6490: b9402d61     	ldr	w1, [x11, #0x2c]
    6494: 35002061     	cbnz	w1, 0x68a0 <___pl_fn_11+0x9c4>
    6498: aa1403e1     	mov	x1, x20
    649c: 1400001a     	b	0x6504 <___pl_fn_11+0x628>
    64a0: aa1403e0     	mov	x0, x20
    64a4: b9401001     	ldr	w1, [x0, #0x10]
    64a8: b9401400     	ldr	w0, [x0, #0x14]
    64ac: 6b00003f     	cmp	w1, w0
    64b0: 54001e02     	b.hs	0x6870 <___pl_fn_11+0x994>
    64b4: aa1503e1     	mov	x1, x21
    64b8: aa1403e0     	mov	x0, x20
    64bc: 94000000     	bl	0x64bc <___pl_fn_11+0x5e0>
    64c0: aa1403e1     	mov	x1, x20
    64c4: b9402c21     	ldr	w1, [x1, #0x2c]
    64c8: 35001ec1     	cbnz	w1, 0x68a0 <___pl_fn_11+0x9c4>
    64cc: aa1403e1     	mov	x1, x20
    64d0: 1400000d     	b	0x6504 <___pl_fn_11+0x628>
    64d4: aa1403e0     	mov	x0, x20
    64d8: b9401001     	ldr	w1, [x0, #0x10]
    64dc: b9401400     	ldr	w0, [x0, #0x14]
    64e0: 6b00003f     	cmp	w1, w0
    64e4: 54001ec2     	b.hs	0x68bc <___pl_fn_11+0x9e0>
    64e8: aa1503e1     	mov	x1, x21
    64ec: aa1403e0     	mov	x0, x20
    64f0: 94000000     	bl	0x64f0 <___pl_fn_11+0x614>
    64f4: aa1403e1     	mov	x1, x20
    64f8: b9402c21     	ldr	w1, [x1, #0x2c]
    64fc: 35001d21     	cbnz	w1, 0x68a0 <___pl_fn_11+0x9c4>
    6500: aa1403e1     	mov	x1, x20
    6504: aa1403e1     	mov	x1, x20
    6508: b9001833     	str	w19, [x1, #0x18]
    650c: b9401021     	ldr	w1, [x1, #0x10]
    6510: 51000421     	sub	w1, w1, #0x1
    6514: aa1403e2     	mov	x2, x20
    6518: b9001041     	str	w1, [x2, #0x10]
    651c: 910143ff     	add	sp, sp, #0x50
    6520: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6524: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6528: f84107fa     	ldr	x26, [sp], #0x10
    652c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6530: d65f03c0     	ret
    6534: 140000ee     	b	0x68ec <___pl_fn_11+0xa10>
    6538: aa0003f4     	mov	x20, x0
    653c: 52801621     	mov	w1, #0xb1               ; =177
    6540: 52800083     	mov	w3, #0x4                ; =4
    6544: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6548: f9400084     	ldr	x4, [x4]
    654c: aa1403e0     	mov	x0, x20
    6550: aa1503e2     	mov	x2, x21
    6554: d63f0080     	blr	x4
    6558: 34ffcfa0     	cbz	w0, 0x5f4c <___pl_fn_11+0x70>
    655c: 140000d1     	b	0x68a0 <___pl_fn_11+0x9c4>
    6560: 52801641     	mov	w1, #0xb2               ; =178
    6564: 528000a3     	mov	w3, #0x5                ; =5
    6568: 90000006     	adrp	x6, 0x6000 <___pl_fn_11+0x124>
    656c: f94000c6     	ldr	x6, [x6]
    6570: aa1403e0     	mov	x0, x20
    6574: aa1303e2     	mov	x2, x19
    6578: d63f00c0     	blr	x6
    657c: aa1303f5     	mov	x21, x19
    6580: 34ffd120     	cbz	w0, 0x5fa4 <___pl_fn_11+0xc8>
    6584: 140000c7     	b	0x68a0 <___pl_fn_11+0x9c4>
    6588: 52801661     	mov	w1, #0xb3               ; =179
    658c: 528000c3     	mov	w3, #0x6                ; =6
    6590: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6594: f9400084     	ldr	x4, [x4]
    6598: aa1403e0     	mov	x0, x20
    659c: aa1503e2     	mov	x2, x21
    65a0: d63f0080     	blr	x4
    65a4: 34ffd340     	cbz	w0, 0x600c <___pl_fn_11+0x130>
    65a8: 140000be     	b	0x68a0 <___pl_fn_11+0x9c4>
    65ac: 52801681     	mov	w1, #0xb4               ; =180
    65b0: 528000e3     	mov	w3, #0x7                ; =7
    65b4: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    65b8: f9400084     	ldr	x4, [x4]
    65bc: aa1403e0     	mov	x0, x20
    65c0: aa1503e2     	mov	x2, x21
    65c4: d63f0080     	blr	x4
    65c8: 34ffd4c0     	cbz	w0, 0x6060 <___pl_fn_11+0x184>
    65cc: 140000b5     	b	0x68a0 <___pl_fn_11+0x9c4>
    65d0: 528016a1     	mov	w1, #0xb5               ; =181
    65d4: 52800043     	mov	w3, #0x2                ; =2
    65d8: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    65dc: f9400084     	ldr	x4, [x4]
    65e0: aa1403e0     	mov	x0, x20
    65e4: d63f0080     	blr	x4
    65e8: 34ffd5a0     	cbz	w0, 0x609c <___pl_fn_11+0x1c0>
    65ec: 140000ad     	b	0x68a0 <___pl_fn_11+0x9c4>
    65f0: 528016c1     	mov	w1, #0xb6               ; =182
    65f4: 90000002     	adrp	x2, 0x6000 <___pl_fn_11+0x124>
    65f8: f9400042     	ldr	x2, [x2]
    65fc: aa1403e0     	mov	x0, x20
    6600: d63f0040     	blr	x2
    6604: 52800000     	mov	w0, #0x0                ; =0
    6608: 910143ff     	add	sp, sp, #0x50
    660c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6610: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6614: f84107fa     	ldr	x26, [sp], #0x10
    6618: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    661c: d65f03c0     	ret
    6620: 528016e1     	mov	w1, #0xb7               ; =183
    6624: 52800063     	mov	w3, #0x3                ; =3
    6628: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    662c: f9400084     	ldr	x4, [x4]
    6630: aa1403e0     	mov	x0, x20
    6634: aa1503e2     	mov	x2, x21
    6638: d63f0080     	blr	x4
    663c: 34ffd5c0     	cbz	w0, 0x60f4 <___pl_fn_11+0x218>
    6640: 14000098     	b	0x68a0 <___pl_fn_11+0x9c4>
    6644: aa0a03fa     	mov	x26, x10
    6648: 52801721     	mov	w1, #0xb9               ; =185
    664c: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6650: f9400084     	ldr	x4, [x4]
    6654: aa1403e0     	mov	x0, x20
    6658: aa1a03e2     	mov	x2, x26
    665c: d63f0080     	blr	x4
    6660: 34ffd6c0     	cbz	w0, 0x6138 <___pl_fn_11+0x25c>
    6664: 1400008f     	b	0x68a0 <___pl_fn_11+0x9c4>
    6668: d2800061     	mov	x1, #0x3                ; =3
    666c: 910003e3     	mov	x3, sp
    6670: f80003e1     	stur	x1, [sp]
    6674: 2a0003e1     	mov	w1, w0
    6678: f80083e1     	stur	x1, [sp, #0x8]
    667c: 52801741     	mov	w1, #0xba               ; =186
    6680: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6684: f9400084     	ldr	x4, [x4]
    6688: aa1403e0     	mov	x0, x20
    668c: aa1503e2     	mov	x2, x21
    6690: d63f0080     	blr	x4
    6694: 34ffd620     	cbz	w0, 0x6158 <___pl_fn_11+0x27c>
    6698: 14000082     	b	0x68a0 <___pl_fn_11+0x9c4>
    669c: 52801761     	mov	w1, #0xbb               ; =187
    66a0: 52800063     	mov	w3, #0x3                ; =3
    66a4: 9000000b     	adrp	x11, 0x6000 <___pl_fn_11+0x124>
    66a8: f940016b     	ldr	x11, [x11]
    66ac: aa1403e0     	mov	x0, x20
    66b0: aa1503e2     	mov	x2, x21
    66b4: d63f0160     	blr	x11
    66b8: 34ffd880     	cbz	w0, 0x61c8 <___pl_fn_11+0x2ec>
    66bc: 14000079     	b	0x68a0 <___pl_fn_11+0x9c4>
    66c0: 52801781     	mov	w1, #0xbc               ; =188
    66c4: 528000e3     	mov	w3, #0x7                ; =7
    66c8: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    66cc: f9400084     	ldr	x4, [x4]
    66d0: aa1403e0     	mov	x0, x20
    66d4: aa1503e2     	mov	x2, x21
    66d8: d63f0080     	blr	x4
    66dc: 34ffda00     	cbz	w0, 0x621c <___pl_fn_11+0x340>
    66e0: 14000070     	b	0x68a0 <___pl_fn_11+0x9c4>
    66e4: 528017a1     	mov	w1, #0xbd               ; =189
    66e8: 52800043     	mov	w3, #0x2                ; =2
    66ec: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    66f0: f9400084     	ldr	x4, [x4]
    66f4: aa1403e0     	mov	x0, x20
    66f8: d63f0080     	blr	x4
    66fc: 34ffdae0     	cbz	w0, 0x6258 <___pl_fn_11+0x37c>
    6700: 14000068     	b	0x68a0 <___pl_fn_11+0x9c4>
    6704: d2800080     	mov	x0, #0x4                ; =4
    6708: 910043e3     	add	x3, sp, #0x10
    670c: f80103e0     	stur	x0, [sp, #0x10]
    6710: d2800020     	mov	x0, #0x1                ; =1
    6714: f80183e0     	stur	x0, [sp, #0x18]
    6718: 528017c1     	mov	w1, #0xbe               ; =190
    671c: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6720: f9400084     	ldr	x4, [x4]
    6724: aa1403e0     	mov	x0, x20
    6728: aa1503e2     	mov	x2, x21
    672c: d63f0080     	blr	x4
    6730: 34ffdb80     	cbz	w0, 0x62a0 <___pl_fn_11+0x3c4>
    6734: 1400005b     	b	0x68a0 <___pl_fn_11+0x9c4>
    6738: d2800080     	mov	x0, #0x4                ; =4
    673c: 910083e3     	add	x3, sp, #0x20
    6740: f80203e0     	stur	x0, [sp, #0x20]
    6744: d2800000     	mov	x0, #0x0                ; =0
    6748: f80283e0     	stur	x0, [sp, #0x28]
    674c: 528017e1     	mov	w1, #0xbf               ; =191
    6750: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6754: f9400084     	ldr	x4, [x4]
    6758: aa1403e0     	mov	x0, x20
    675c: aa1503e2     	mov	x2, x21
    6760: d63f0080     	blr	x4
    6764: 34ffdbe0     	cbz	w0, 0x62e0 <___pl_fn_11+0x404>
    6768: 1400004e     	b	0x68a0 <___pl_fn_11+0x9c4>
    676c: d28000a0     	mov	x0, #0x5                ; =5
    6770: 9100c3e3     	add	x3, sp, #0x30
    6774: f80303e0     	stur	x0, [sp, #0x30]
    6778: d2800000     	mov	x0, #0x0                ; =0
    677c: f80383e0     	stur	x0, [sp, #0x38]
    6780: 52801801     	mov	w1, #0xc0               ; =192
    6784: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6788: f9400084     	ldr	x4, [x4]
    678c: aa1403e0     	mov	x0, x20
    6790: aa1503e2     	mov	x2, x21
    6794: d63f0080     	blr	x4
    6798: 34ffdac0     	cbz	w0, 0x62f0 <___pl_fn_11+0x414>
    679c: 14000041     	b	0x68a0 <___pl_fn_11+0x9c4>
    67a0: d28000c0     	mov	x0, #0x6                ; =6
    67a4: 910103e3     	add	x3, sp, #0x40
    67a8: f80403e0     	stur	x0, [sp, #0x40]
    67ac: d2800000     	mov	x0, #0x0                ; =0
    67b0: f80483e0     	stur	x0, [sp, #0x48]
    67b4: 52801821     	mov	w1, #0xc1               ; =193
    67b8: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    67bc: f9400084     	ldr	x4, [x4]
    67c0: aa1403e0     	mov	x0, x20
    67c4: aa1503e2     	mov	x2, x21
    67c8: d63f0080     	blr	x4
    67cc: 34ffdca0     	cbz	w0, 0x6360 <___pl_fn_11+0x484>
    67d0: 14000034     	b	0x68a0 <___pl_fn_11+0x9c4>
    67d4: 52801921     	mov	w1, #0xc9               ; =201
    67d8: 90000002     	adrp	x2, 0x6000 <___pl_fn_11+0x124>
    67dc: f9400042     	ldr	x2, [x2]
    67e0: aa1403e0     	mov	x0, x20
    67e4: d63f0040     	blr	x2
    67e8: aa1603e0     	mov	x0, x22
    67ec: 910143ff     	add	sp, sp, #0x50
    67f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    67f4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    67f8: f84107fa     	ldr	x26, [sp], #0x10
    67fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6800: d65f03c0     	ret
    6804: 14000027     	b	0x68a0 <___pl_fn_11+0x9c4>
    6808: 52801901     	mov	w1, #0xc8               ; =200
    680c: 90000002     	adrp	x2, 0x6000 <___pl_fn_11+0x124>
    6810: f9400042     	ldr	x2, [x2]
    6814: aa1403e0     	mov	x0, x20
    6818: d63f0040     	blr	x2
    681c: aa1603e0     	mov	x0, x22
    6820: 910143ff     	add	sp, sp, #0x50
    6824: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6828: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    682c: f84107fa     	ldr	x26, [sp], #0x10
    6830: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6834: d65f03c0     	ret
    6838: 1400001a     	b	0x68a0 <___pl_fn_11+0x9c4>
    683c: 528018e1     	mov	w1, #0xc7               ; =199
    6840: 90000002     	adrp	x2, 0x6000 <___pl_fn_11+0x124>
    6844: f9400042     	ldr	x2, [x2]
    6848: aa1403e0     	mov	x0, x20
    684c: d63f0040     	blr	x2
    6850: aa1603e0     	mov	x0, x22
    6854: 910143ff     	add	sp, sp, #0x50
    6858: a8c153f3     	ldp	x19, x20, [sp], #0x10
    685c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6860: f84107fa     	ldr	x26, [sp], #0x10
    6864: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6868: d65f03c0     	ret
    686c: 1400000d     	b	0x68a0 <___pl_fn_11+0x9c4>
    6870: 528018c1     	mov	w1, #0xc6               ; =198
    6874: 90000002     	adrp	x2, 0x6000 <___pl_fn_11+0x124>
    6878: f9400042     	ldr	x2, [x2]
    687c: aa1403e0     	mov	x0, x20
    6880: d63f0040     	blr	x2
    6884: aa1603e0     	mov	x0, x22
    6888: 910143ff     	add	sp, sp, #0x50
    688c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6890: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6894: f84107fa     	ldr	x26, [sp], #0x10
    6898: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    689c: d65f03c0     	ret
    68a0: 52800000     	mov	w0, #0x0                ; =0
    68a4: 910143ff     	add	sp, sp, #0x50
    68a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    68ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    68b0: f84107fa     	ldr	x26, [sp], #0x10
    68b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    68b8: d65f03c0     	ret
    68bc: 528018a1     	mov	w1, #0xc5               ; =197
    68c0: 90000002     	adrp	x2, 0x6000 <___pl_fn_11+0x124>
    68c4: f9400042     	ldr	x2, [x2]
    68c8: aa1403e0     	mov	x0, x20
    68cc: d63f0040     	blr	x2
    68d0: aa1603e0     	mov	x0, x22
    68d4: 910143ff     	add	sp, sp, #0x50
    68d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    68dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    68e0: f84107fa     	ldr	x26, [sp], #0x10
    68e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    68e8: d65f03c0     	ret
    68ec: 52801881     	mov	w1, #0xc4               ; =196
    68f0: 90000002     	adrp	x2, 0x6000 <___pl_fn_11+0x124>
    68f4: f9400042     	ldr	x2, [x2]
    68f8: aa1403e0     	mov	x0, x20
    68fc: d63f0040     	blr	x2
    6900: aa1603e0     	mov	x0, x22
    6904: 910143ff     	add	sp, sp, #0x50
    6908: a8c153f3     	ldp	x19, x20, [sp], #0x10
    690c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6910: f84107fa     	ldr	x26, [sp], #0x10
    6914: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6918: d65f03c0     	ret
    691c: 52801861     	mov	w1, #0xc3               ; =195
    6920: 90000002     	adrp	x2, 0x6000 <___pl_fn_11+0x124>
    6924: f9400042     	ldr	x2, [x2]
    6928: aa1403e0     	mov	x0, x20
    692c: d63f0040     	blr	x2
    6930: aa1603e0     	mov	x0, x22
    6934: 910143ff     	add	sp, sp, #0x50
    6938: a8c153f3     	ldp	x19, x20, [sp], #0x10
    693c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6940: f84107fa     	ldr	x26, [sp], #0x10
    6944: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6948: d65f03c0     	ret
    694c: 52801841     	mov	w1, #0xc2               ; =194
    6950: 90000002     	adrp	x2, 0x6000 <___pl_fn_11+0x124>
    6954: f9400042     	ldr	x2, [x2]
    6958: aa1403e0     	mov	x0, x20
    695c: d63f0040     	blr	x2
    6960: 52800000     	mov	w0, #0x0                ; =0
    6964: 910143ff     	add	sp, sp, #0x50
    6968: a8c153f3     	ldp	x19, x20, [sp], #0x10
    696c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6970: f84107fa     	ldr	x26, [sp], #0x10
    6974: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6978: d65f03c0     	ret
    697c: aa0303f3     	mov	x19, x3
    6980: 52801701     	mov	w1, #0xb8               ; =184
    6984: 90000002     	adrp	x2, 0x6000 <___pl_fn_11+0x124>
    6988: f9400042     	ldr	x2, [x2]
    698c: aa1403e0     	mov	x0, x20
    6990: d63f0040     	blr	x2
    6994: aa1303e0     	mov	x0, x19
    6998: 910143ff     	add	sp, sp, #0x50
    699c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    69a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    69a4: f84107fa     	ldr	x26, [sp], #0x10
    69a8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    69ac: d65f03c0     	ret

00000000000069b0 <___pl_fn_12>:
    69b0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    69b4: 910003fd     	mov	x29, sp
    69b8: a9bf5bf3     	stp	x19, x22, [sp, #-0x10]!
    69bc: d10043ff     	sub	sp, sp, #0x10
    69c0: aa0103f6     	mov	x22, x1
    69c4: b9401001     	ldr	w1, [x0, #0x10]
    69c8: 11000421     	add	w1, w1, #0x1
    69cc: b9001001     	str	w1, [x0, #0x10]
    69d0: aa0003e2     	mov	x2, x0
    69d4: aa1603e1     	mov	x1, x22
    69d8: 34000281     	cbz	w1, 0x6a28 <___pl_fn_12+0x78>
    69dc: aa0203f3     	mov	x19, x2
    69e0: f9400262     	ldr	x2, [x19]
    69e4: aa1603e1     	mov	x1, x22
    69e8: 2a0103e0     	mov	w0, w1
    69ec: 8b000c40     	add	x0, x2, x0, lsl #3
    69f0: f8615842     	ldr	x2, [x2, w1, uxtw #3]
    69f4: d2800021     	mov	x1, #0x1                ; =1
    69f8: d360fc42     	lsr	x2, x2, #32
    69fc: 92403c42     	and	x2, x2, #0xffff
    6a00: 91001442     	add	x2, x2, #0x5
    6a04: f8227801     	str	x1, [x0, x2, lsl #3]
    6a08: b9401260     	ldr	w0, [x19, #0x10]
    6a0c: 51000400     	sub	w0, w0, #0x1
    6a10: b9001260     	str	w0, [x19, #0x10]
    6a14: aa1603e0     	mov	x0, x22
    6a18: 910043ff     	add	sp, sp, #0x10
    6a1c: a8c15bf3     	ldp	x19, x22, [sp], #0x10
    6a20: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6a24: d65f03c0     	ret
    6a28: d28000a0     	mov	x0, #0x5                ; =5
    6a2c: 910003e3     	mov	x3, sp
    6a30: f80003e0     	stur	x0, [sp]
    6a34: d2800020     	mov	x0, #0x1                ; =1
    6a38: f80083e0     	stur	x0, [sp, #0x8]
    6a3c: 52801941     	mov	w1, #0xca               ; =202
    6a40: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6a44: f9400084     	ldr	x4, [x4]
    6a48: aa0203f3     	mov	x19, x2
    6a4c: aa1303e0     	mov	x0, x19
    6a50: aa1603e2     	mov	x2, x22
    6a54: d63f0080     	blr	x4
    6a58: 34fffd80     	cbz	w0, 0x6a08 <___pl_fn_12+0x58>
    6a5c: 52800000     	mov	w0, #0x0                ; =0
    6a60: 910043ff     	add	sp, sp, #0x10
    6a64: a8c15bf3     	ldp	x19, x22, [sp], #0x10
    6a68: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6a6c: d65f03c0     	ret

0000000000006a70 <___pl_fn_13>:
    6a70: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    6a74: 910003fd     	mov	x29, sp
    6a78: f81f0ff5     	str	x21, [sp, #-0x10]!
    6a7c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    6a80: d10083ff     	sub	sp, sp, #0x20
    6a84: aa0103f3     	mov	x19, x1
    6a88: b9401001     	ldr	w1, [x0, #0x10]
    6a8c: 11000421     	add	w1, w1, #0x1
    6a90: b9001001     	str	w1, [x0, #0x10]
    6a94: aa1303e1     	mov	x1, x19
    6a98: 34000d81     	cbz	w1, 0x6c48 <___pl_fn_13+0x1d8>
    6a9c: f9400001     	ldr	x1, [x0]
    6aa0: aa1303e4     	mov	x4, x19
    6aa4: aa0003f5     	mov	x21, x0
    6aa8: 2a0403e0     	mov	w0, w4
    6aac: 8b000c20     	add	x0, x1, x0, lsl #3
    6ab0: aa1303e7     	mov	x7, x19
    6ab4: f8675821     	ldr	x1, [x1, w7, uxtw #3]
    6ab8: d360fc21     	lsr	x1, x1, #32
    6abc: 92403c21     	and	x1, x1, #0xffff
    6ac0: 91001c21     	add	x1, x1, #0x7
    6ac4: d37df021     	lsl	x1, x1, #3
    6ac8: b8616802     	ldr	w2, [x0, x1]
    6acc: 35000082     	cbnz	w2, 0x6adc <___pl_fn_13+0x6c>
    6ad0: 1400005f     	b	0x6c4c <___pl_fn_13+0x1dc>
    6ad4: aa1503e0     	mov	x0, x21
    6ad8: f9401802     	ldr	x2, [x0, #0x30]
    6adc: 34000ca2     	cbz	w2, 0x6c70 <___pl_fn_13+0x200>
    6ae0: aa1503e0     	mov	x0, x21
    6ae4: f9400000     	ldr	x0, [x0]
    6ae8: 2a0203e1     	mov	w1, w2
    6aec: 8b010c01     	add	x1, x0, x1, lsl #3
    6af0: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    6af4: d360fc00     	lsr	x0, x0, #32
    6af8: 92403c03     	and	x3, x0, #0xffff
    6afc: 91002460     	add	x0, x3, #0x9
    6b00: f8607820     	ldr	x0, [x1, x0, lsl #3]
    6b04: f100087f     	cmp	x3, #0x2
    6b08: 540000c0     	b.eq	0x6b20 <___pl_fn_13+0xb0>
    6b0c: f9400821     	ldr	x1, [x1, #0x10]
    6b10: 37480b01     	tbnz	w1, #0x9, 0x6c70 <___pl_fn_13+0x200>
    6b14: 14000003     	b	0x6b20 <___pl_fn_13+0xb0>
    6b18: aa1503e0     	mov	x0, x21
    6b1c: f9401800     	ldr	x0, [x0, #0x30]
    6b20: d2800021     	mov	x1, #0x1                ; =1
    6b24: ab010014     	adds	x20, x0, x1
    6b28: 9a9f77e0     	cset	x0, vs
    6b2c: 72001c1f     	tst	w0, #0xff
    6b30: 540010e1     	b.ne	0x6d4c <___pl_fn_13+0x2dc>
    6b34: 34000af3     	cbz	w19, 0x6c90 <___pl_fn_13+0x220>
    6b38: aa1503e0     	mov	x0, x21
    6b3c: f9400003     	ldr	x3, [x0]
    6b40: 2a1303e2     	mov	w2, w19
    6b44: 8b020c62     	add	x2, x3, x2, lsl #3
    6b48: f8735863     	ldr	x3, [x3, w19, uxtw #3]
    6b4c: d360fc63     	lsr	x3, x3, #32
    6b50: 92403c63     	and	x3, x3, #0xffff
    6b54: 91001c63     	add	x3, x3, #0x7
    6b58: d37df063     	lsl	x3, x3, #3
    6b5c: b8636842     	ldr	w2, [x2, x3]
    6b60: 35000082     	cbnz	w2, 0x6b70 <___pl_fn_13+0x100>
    6b64: 1400004b     	b	0x6c90 <___pl_fn_13+0x220>
    6b68: aa1503e0     	mov	x0, x21
    6b6c: f9401802     	ldr	x2, [x0, #0x30]
    6b70: 34000a22     	cbz	w2, 0x6cb4 <___pl_fn_13+0x244>
    6b74: aa1503e0     	mov	x0, x21
    6b78: f940000f     	ldr	x15, [x0]
    6b7c: 2a0203ee     	mov	w14, w2
    6b80: 8b0e0dee     	add	x14, x15, x14, lsl #3
    6b84: f86259ef     	ldr	x15, [x15, w2, uxtw #3]
    6b88: d360fdef     	lsr	x15, x15, #32
    6b8c: 92403de0     	and	x0, x15, #0xffff
    6b90: f100081f     	cmp	x0, #0x2
    6b94: 54000080     	b.eq	0x6ba4 <___pl_fn_13+0x134>
    6b98: f94009c0     	ldr	x0, [x14, #0x10]
    6b9c: 9276f800     	and	x0, x0, #0xfffffffffffffdff
    6ba0: f90009c0     	str	x0, [x14, #0x10]
    6ba4: 92403de0     	and	x0, x15, #0xffff
    6ba8: 91002400     	add	x0, x0, #0x9
    6bac: f82079d4     	str	x20, [x14, x0, lsl #3]
    6bb0: 34000993     	cbz	w19, 0x6ce0 <___pl_fn_13+0x270>
    6bb4: aa1503e0     	mov	x0, x21
    6bb8: f9400001     	ldr	x1, [x0]
    6bbc: 2a1303e0     	mov	w0, w19
    6bc0: 8b000c20     	add	x0, x1, x0, lsl #3
    6bc4: f8735822     	ldr	x2, [x1, w19, uxtw #3]
    6bc8: d2800021     	mov	x1, #0x1                ; =1
    6bcc: d360fc42     	lsr	x2, x2, #32
    6bd0: 92403c42     	and	x2, x2, #0xffff
    6bd4: 91001842     	add	x2, x2, #0x6
    6bd8: f8227801     	str	x1, [x0, x2, lsl #3]
    6bdc: 340009d3     	cbz	w19, 0x6d14 <___pl_fn_13+0x2a4>
    6be0: aa1503e0     	mov	x0, x21
    6be4: f9400001     	ldr	x1, [x0]
    6be8: 2a1303e0     	mov	w0, w19
    6bec: 8b000c20     	add	x0, x1, x0, lsl #3
    6bf0: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    6bf4: d360fc21     	lsr	x1, x1, #32
    6bf8: 92403c21     	and	x1, x1, #0xffff
    6bfc: d37df021     	lsl	x1, x1, #3
    6c00: b8616800     	ldr	w0, [x0, x1]
    6c04: 350000c0     	cbnz	w0, 0x6c1c <___pl_fn_13+0x1ac>
    6c08: 14000043     	b	0x6d14 <___pl_fn_13+0x2a4>
    6c0c: aa1503e0     	mov	x0, x21
    6c10: f9401800     	ldr	x0, [x0, #0x30]
    6c14: aa1503e1     	mov	x1, x21
    6c18: 14000002     	b	0x6c20 <___pl_fn_13+0x1b0>
    6c1c: aa1503e1     	mov	x1, x21
    6c20: aa1503e1     	mov	x1, x21
    6c24: b9401021     	ldr	w1, [x1, #0x10]
    6c28: 51000421     	sub	w1, w1, #0x1
    6c2c: aa1503e2     	mov	x2, x21
    6c30: b9001041     	str	w1, [x2, #0x10]
    6c34: 910083ff     	add	sp, sp, #0x20
    6c38: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6c3c: f84107f5     	ldr	x21, [sp], #0x10
    6c40: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6c44: d65f03c0     	ret
    6c48: aa0003f5     	mov	x21, x0
    6c4c: 52801961     	mov	w1, #0xcb               ; =203
    6c50: 528000e3     	mov	w3, #0x7                ; =7
    6c54: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6c58: f9400084     	ldr	x4, [x4]
    6c5c: aa1503e0     	mov	x0, x21
    6c60: aa1303e2     	mov	x2, x19
    6c64: d63f0080     	blr	x4
    6c68: 34fff360     	cbz	w0, 0x6ad4 <___pl_fn_13+0x64>
    6c6c: 14000032     	b	0x6d34 <___pl_fn_13+0x2c4>
    6c70: 52801981     	mov	w1, #0xcc               ; =204
    6c74: 52800123     	mov	w3, #0x9                ; =9
    6c78: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6c7c: f9400084     	ldr	x4, [x4]
    6c80: aa1503e0     	mov	x0, x21
    6c84: d63f0080     	blr	x4
    6c88: 34fff480     	cbz	w0, 0x6b18 <___pl_fn_13+0xa8>
    6c8c: 1400002a     	b	0x6d34 <___pl_fn_13+0x2c4>
    6c90: 528019c1     	mov	w1, #0xce               ; =206
    6c94: 528000e3     	mov	w3, #0x7                ; =7
    6c98: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6c9c: f9400084     	ldr	x4, [x4]
    6ca0: aa1503e0     	mov	x0, x21
    6ca4: aa1303e2     	mov	x2, x19
    6ca8: d63f0080     	blr	x4
    6cac: 34fff5e0     	cbz	w0, 0x6b68 <___pl_fn_13+0xf8>
    6cb0: 14000021     	b	0x6d34 <___pl_fn_13+0x2c4>
    6cb4: d2800129     	mov	x9, #0x9                ; =9
    6cb8: 910003e3     	mov	x3, sp
    6cbc: f80003e9     	stur	x9, [sp]
    6cc0: f80083f4     	stur	x20, [sp, #0x8]
    6cc4: 528019e1     	mov	w1, #0xcf               ; =207
    6cc8: 9000000b     	adrp	x11, 0x6000 <___pl_fn_11+0x124>
    6ccc: f940016b     	ldr	x11, [x11]
    6cd0: aa1503e0     	mov	x0, x21
    6cd4: d63f0160     	blr	x11
    6cd8: 34fff6c0     	cbz	w0, 0x6bb0 <___pl_fn_13+0x140>
    6cdc: 14000016     	b	0x6d34 <___pl_fn_13+0x2c4>
    6ce0: d28000c0     	mov	x0, #0x6                ; =6
    6ce4: 910043e3     	add	x3, sp, #0x10
    6ce8: f80103e0     	stur	x0, [sp, #0x10]
    6cec: d2800020     	mov	x0, #0x1                ; =1
    6cf0: f80183e0     	stur	x0, [sp, #0x18]
    6cf4: 52801a01     	mov	w1, #0xd0               ; =208
    6cf8: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6cfc: f9400084     	ldr	x4, [x4]
    6d00: aa1503e0     	mov	x0, x21
    6d04: aa1303e2     	mov	x2, x19
    6d08: d63f0080     	blr	x4
    6d0c: 34fff680     	cbz	w0, 0x6bdc <___pl_fn_13+0x16c>
    6d10: 14000009     	b	0x6d34 <___pl_fn_13+0x2c4>
    6d14: 52801a21     	mov	w1, #0xd1               ; =209
    6d18: 52800003     	mov	w3, #0x0                ; =0
    6d1c: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6d20: f9400084     	ldr	x4, [x4]
    6d24: aa1303e2     	mov	x2, x19
    6d28: aa1503e0     	mov	x0, x21
    6d2c: d63f0080     	blr	x4
    6d30: 34fff6e0     	cbz	w0, 0x6c0c <___pl_fn_13+0x19c>
    6d34: 52800000     	mov	w0, #0x0                ; =0
    6d38: 910083ff     	add	sp, sp, #0x20
    6d3c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6d40: f84107f5     	ldr	x21, [sp], #0x10
    6d44: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6d48: d65f03c0     	ret
    6d4c: 528019a1     	mov	w1, #0xcd               ; =205
    6d50: 90000002     	adrp	x2, 0x6000 <___pl_fn_11+0x124>
    6d54: f9400042     	ldr	x2, [x2]
    6d58: aa1503e0     	mov	x0, x21
    6d5c: d63f0040     	blr	x2
    6d60: 52800000     	mov	w0, #0x0                ; =0
    6d64: 910083ff     	add	sp, sp, #0x20
    6d68: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6d6c: f84107f5     	ldr	x21, [sp], #0x10
    6d70: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6d74: d65f03c0     	ret

0000000000006d78 <___pl_fn_14>:
    6d78: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    6d7c: 910003fd     	mov	x29, sp
    6d80: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    6d84: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    6d88: d10043ff     	sub	sp, sp, #0x10
    6d8c: aa0103f3     	mov	x19, x1
    6d90: aa0203f5     	mov	x21, x2
    6d94: b9401001     	ldr	w1, [x0, #0x10]
    6d98: 11000421     	add	w1, w1, #0x1
    6d9c: b9001001     	str	w1, [x0, #0x10]
    6da0: aa1303e1     	mov	x1, x19
    6da4: 34001001     	cbz	w1, 0x6fa4 <___pl_fn_14+0x22c>
    6da8: f9400001     	ldr	x1, [x0]
    6dac: aa1303ee     	mov	x14, x19
    6db0: aa0003f6     	mov	x22, x0
    6db4: 2a0e03e0     	mov	w0, w14
    6db8: 8b000c20     	add	x0, x1, x0, lsl #3
    6dbc: aa1303e2     	mov	x2, x19
    6dc0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    6dc4: d360fc21     	lsr	x1, x1, #32
    6dc8: 92403c21     	and	x1, x1, #0xffff
    6dcc: 91001c21     	add	x1, x1, #0x7
    6dd0: d37df021     	lsl	x1, x1, #3
    6dd4: b8616801     	ldr	w1, [x0, x1]
    6dd8: 350000a1     	cbnz	w1, 0x6dec <___pl_fn_14+0x74>
    6ddc: 14000073     	b	0x6fa8 <___pl_fn_14+0x230>
    6de0: aa1603e0     	mov	x0, x22
    6de4: f9401801     	ldr	x1, [x0, #0x30]
    6de8: 14000002     	b	0x6df0 <___pl_fn_14+0x78>
    6dec: aa1603e0     	mov	x0, x22
    6df0: aa1603e0     	mov	x0, x22
    6df4: b9401814     	ldr	w20, [x0, #0x18]
    6df8: b9401c00     	ldr	w0, [x0, #0x1c]
    6dfc: 11000a82     	add	w2, w20, #0x2
    6e00: 6b00005f     	cmp	w2, w0
    6e04: 540015c8     	b.hi	0x70bc <___pl_fn_14+0x344>
    6e08: aa1603e0     	mov	x0, x22
    6e0c: f9401000     	ldr	x0, [x0, #0x20]
    6e10: 2a1403e2     	mov	w2, w20
    6e14: 8b020802     	add	x2, x0, x2, lsl #2
    6e18: b8345813     	str	w19, [x0, w20, uxtw #2]
    6e1c: b9000441     	str	w1, [x2, #0x4]
    6e20: 11000a80     	add	w0, w20, #0x2
    6e24: aa1603ee     	mov	x14, x22
    6e28: b90019c0     	str	w0, [x14, #0x18]
    6e2c: aa1603e0     	mov	x0, x22
    6e30: b9401000     	ldr	w0, [x0, #0x10]
    6e34: aa1603e2     	mov	x2, x22
    6e38: b9401442     	ldr	w2, [x2, #0x14]
    6e3c: 6b02001f     	cmp	w0, w2
    6e40: 54001282     	b.hs	0x7090 <___pl_fn_14+0x318>
    6e44: aa1503e2     	mov	x2, x21
    6e48: aa1603e0     	mov	x0, x22
    6e4c: 94000000     	bl	0x6e4c <___pl_fn_14+0xd4>
    6e50: aa1603e1     	mov	x1, x22
    6e54: b9402c21     	ldr	w1, [x1, #0x2c]
    6e58: 35001101     	cbnz	w1, 0x7078 <___pl_fn_14+0x300>
    6e5c: aa1603e1     	mov	x1, x22
    6e60: b9001834     	str	w20, [x1, #0x18]
    6e64: 34000f40     	cbz	w0, 0x704c <___pl_fn_14+0x2d4>
    6e68: 35000080     	cbnz	w0, 0x6e78 <___pl_fn_14+0x100>
    6e6c: 14000058     	b	0x6fcc <___pl_fn_14+0x254>
    6e70: aa1403e0     	mov	x0, x20
    6e74: 1400000f     	b	0x6eb0 <___pl_fn_14+0x138>
    6e78: aa0003f4     	mov	x20, x0
    6e7c: aa1603e0     	mov	x0, x22
    6e80: f9400001     	ldr	x1, [x0]
    6e84: aa1403e0     	mov	x0, x20
    6e88: 2a0003e0     	mov	w0, w0
    6e8c: 8b000c20     	add	x0, x1, x0, lsl #3
    6e90: aa1403e2     	mov	x2, x20
    6e94: f8625822     	ldr	x2, [x1, w2, uxtw #3]
    6e98: d2800001     	mov	x1, #0x0                ; =0
    6e9c: d360fc42     	lsr	x2, x2, #32
    6ea0: 92403c42     	and	x2, x2, #0xffff
    6ea4: 91001842     	add	x2, x2, #0x6
    6ea8: f8227801     	str	x1, [x0, x2, lsl #3]
    6eac: aa1403e0     	mov	x0, x20
    6eb0: aa1403e0     	mov	x0, x20
    6eb4: 34000a80     	cbz	w0, 0x7004 <___pl_fn_14+0x28c>
    6eb8: aa1603e0     	mov	x0, x22
    6ebc: f9400001     	ldr	x1, [x0]
    6ec0: aa1403e0     	mov	x0, x20
    6ec4: 2a0003e0     	mov	w0, w0
    6ec8: 8b000c20     	add	x0, x1, x0, lsl #3
    6ecc: aa1403ed     	mov	x13, x20
    6ed0: f86d5821     	ldr	x1, [x1, w13, uxtw #3]
    6ed4: d360fc21     	lsr	x1, x1, #32
    6ed8: 92403c21     	and	x1, x1, #0xffff
    6edc: 91000822     	add	x2, x1, #0x2
    6ee0: f8627815     	ldr	x21, [x0, x2, lsl #3]
    6ee4: f100083f     	cmp	x1, #0x2
    6ee8: 540000c0     	b.eq	0x6f00 <___pl_fn_14+0x188>
    6eec: f9400800     	ldr	x0, [x0, #0x10]
    6ef0: 371008a0     	tbnz	w0, #0x2, 0x7004 <___pl_fn_14+0x28c>
    6ef4: 14000003     	b	0x6f00 <___pl_fn_14+0x188>
    6ef8: aa1603e0     	mov	x0, x22
    6efc: f9401815     	ldr	x21, [x0, #0x30]
    6f00: 34000953     	cbz	w19, 0x7028 <___pl_fn_14+0x2b0>
    6f04: aa1603e0     	mov	x0, x22
    6f08: f940000a     	ldr	x10, [x0]
    6f0c: 2a1303e9     	mov	w9, w19
    6f10: 8b090d49     	add	x9, x10, x9, lsl #3
    6f14: f873594a     	ldr	x10, [x10, w19, uxtw #3]
    6f18: d360fd4a     	lsr	x10, x10, #32
    6f1c: 92403d4a     	and	x10, x10, #0xffff
    6f20: 9100094b     	add	x11, x10, #0x2
    6f24: f86b7920     	ldr	x0, [x9, x11, lsl #3]
    6f28: f100095f     	cmp	x10, #0x2
    6f2c: 540000c0     	b.eq	0x6f44 <___pl_fn_14+0x1cc>
    6f30: f940092c     	ldr	x12, [x9, #0x10]
    6f34: 371007ac     	tbnz	w12, #0x2, 0x7028 <___pl_fn_14+0x2b0>
    6f38: 14000003     	b	0x6f44 <___pl_fn_14+0x1cc>
    6f3c: aa1603e0     	mov	x0, x22
    6f40: f9401800     	ldr	x0, [x0, #0x30]
    6f44: eb0002bf     	cmp	x21, x0
    6f48: 5400018c     	b.gt	0x6f78 <___pl_fn_14+0x200>
    6f4c: aa1603e0     	mov	x0, x22
    6f50: b9401000     	ldr	w0, [x0, #0x10]
    6f54: 51000400     	sub	w0, w0, #0x1
    6f58: aa1603e1     	mov	x1, x22
    6f5c: b9001020     	str	w0, [x1, #0x10]
    6f60: aa1303e0     	mov	x0, x19
    6f64: 910043ff     	add	sp, sp, #0x10
    6f68: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6f6c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6f70: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6f74: d65f03c0     	ret
    6f78: aa1603e0     	mov	x0, x22
    6f7c: b9401000     	ldr	w0, [x0, #0x10]
    6f80: 51000400     	sub	w0, w0, #0x1
    6f84: aa1603e1     	mov	x1, x22
    6f88: b9001020     	str	w0, [x1, #0x10]
    6f8c: aa1403e0     	mov	x0, x20
    6f90: 910043ff     	add	sp, sp, #0x10
    6f94: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6f98: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6f9c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6fa0: d65f03c0     	ret
    6fa4: aa0003f6     	mov	x22, x0
    6fa8: 52801a41     	mov	w1, #0xd2               ; =210
    6fac: 528000e3     	mov	w3, #0x7                ; =7
    6fb0: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6fb4: f9400084     	ldr	x4, [x4]
    6fb8: aa1603e0     	mov	x0, x22
    6fbc: aa1303e2     	mov	x2, x19
    6fc0: d63f0080     	blr	x4
    6fc4: 34fff0e0     	cbz	w0, 0x6de0 <___pl_fn_14+0x68>
    6fc8: 1400002c     	b	0x7078 <___pl_fn_14+0x300>
    6fcc: aa0003f4     	mov	x20, x0
    6fd0: d28000c0     	mov	x0, #0x6                ; =6
    6fd4: 910003e3     	mov	x3, sp
    6fd8: f80003e0     	stur	x0, [sp]
    6fdc: d2800000     	mov	x0, #0x0                ; =0
    6fe0: f80083e0     	stur	x0, [sp, #0x8]
    6fe4: 52801ac1     	mov	w1, #0xd6               ; =214
    6fe8: 90000004     	adrp	x4, 0x6000 <___pl_fn_11+0x124>
    6fec: f9400084     	ldr	x4, [x4]
    6ff0: aa1603e0     	mov	x0, x22
    6ff4: aa1403e2     	mov	x2, x20
    6ff8: d63f0080     	blr	x4
    6ffc: 34fff3a0     	cbz	w0, 0x6e70 <___pl_fn_14+0xf8>
    7000: 1400001e     	b	0x7078 <___pl_fn_14+0x300>
    7004: 52801ae1     	mov	w1, #0xd7               ; =215
    7008: 52800043     	mov	w3, #0x2                ; =2
    700c: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    7010: f9400084     	ldr	x4, [x4]
    7014: aa1603e0     	mov	x0, x22
    7018: aa1403e2     	mov	x2, x20
    701c: d63f0080     	blr	x4
    7020: 34fff6c0     	cbz	w0, 0x6ef8 <___pl_fn_14+0x180>
    7024: 14000015     	b	0x7078 <___pl_fn_14+0x300>
    7028: 52801b01     	mov	w1, #0xd8               ; =216
    702c: 52800043     	mov	w3, #0x2                ; =2
    7030: 9000000f     	adrp	x15, 0x7000 <___pl_fn_14+0x288>
    7034: f94001ef     	ldr	x15, [x15]
    7038: aa1603e0     	mov	x0, x22
    703c: aa1303e2     	mov	x2, x19
    7040: d63f01e0     	blr	x15
    7044: 34fff7c0     	cbz	w0, 0x6f3c <___pl_fn_14+0x1c4>
    7048: 1400000c     	b	0x7078 <___pl_fn_14+0x300>
    704c: 52801aa1     	mov	w1, #0xd5               ; =213
    7050: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    7054: f9400042     	ldr	x2, [x2]
    7058: aa1603e0     	mov	x0, x22
    705c: d63f0040     	blr	x2
    7060: 52800000     	mov	w0, #0x0                ; =0
    7064: 910043ff     	add	sp, sp, #0x10
    7068: a8c153f3     	ldp	x19, x20, [sp], #0x10
    706c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7070: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7074: d65f03c0     	ret
    7078: 52800000     	mov	w0, #0x0                ; =0
    707c: 910043ff     	add	sp, sp, #0x10
    7080: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7084: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7088: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    708c: d65f03c0     	ret
    7090: 52801a81     	mov	w1, #0xd4               ; =212
    7094: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    7098: f9400042     	ldr	x2, [x2]
    709c: aa1603e0     	mov	x0, x22
    70a0: d63f0040     	blr	x2
    70a4: 52800000     	mov	w0, #0x0                ; =0
    70a8: 910043ff     	add	sp, sp, #0x10
    70ac: a8c153f3     	ldp	x19, x20, [sp], #0x10
    70b0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    70b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    70b8: d65f03c0     	ret
    70bc: 52801a61     	mov	w1, #0xd3               ; =211
    70c0: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    70c4: f9400042     	ldr	x2, [x2]
    70c8: aa1603e0     	mov	x0, x22
    70cc: d63f0040     	blr	x2
    70d0: 52800000     	mov	w0, #0x0                ; =0
    70d4: 910043ff     	add	sp, sp, #0x10
    70d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    70dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    70e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    70e4: d65f03c0     	ret

00000000000070e8 <___pl_fn_15>:
    70e8: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    70ec: 910003fd     	mov	x29, sp
    70f0: a9bf6ff7     	stp	x23, x27, [sp, #-0x10]!
    70f4: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    70f8: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    70fc: d100c3ff     	sub	sp, sp, #0x30
    7100: aa0103f3     	mov	x19, x1
    7104: aa0203f7     	mov	x23, x2
    7108: b9401001     	ldr	w1, [x0, #0x10]
    710c: 11000421     	add	w1, w1, #0x1
    7110: b9001001     	str	w1, [x0, #0x10]
    7114: aa1303e1     	mov	x1, x19
    7118: 34002221     	cbz	w1, 0x755c <___pl_fn_15+0x474>
    711c: f9400001     	ldr	x1, [x0]
    7120: aa0003f6     	mov	x22, x0
    7124: aa1303e0     	mov	x0, x19
    7128: 2a0003e0     	mov	w0, w0
    712c: 8b000c20     	add	x0, x1, x0, lsl #3
    7130: aa1303e2     	mov	x2, x19
    7134: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    7138: d360fc21     	lsr	x1, x1, #32
    713c: 92403c21     	and	x1, x1, #0xffff
    7140: 91001c21     	add	x1, x1, #0x7
    7144: d37df021     	lsl	x1, x1, #3
    7148: b8616801     	ldr	w1, [x0, x1]
    714c: 350000e1     	cbnz	w1, 0x7168 <___pl_fn_15+0x80>
    7150: 14000104     	b	0x7560 <___pl_fn_15+0x478>
    7154: aa1603e0     	mov	x0, x22
    7158: f9401801     	ldr	x1, [x0, #0x30]
    715c: aa0103f5     	mov	x21, x1
    7160: aa1703e2     	mov	x2, x23
    7164: 14000003     	b	0x7170 <___pl_fn_15+0x88>
    7168: aa0103f5     	mov	x21, x1
    716c: aa1703e2     	mov	x2, x23
    7170: 340020a2     	cbz	w2, 0x7584 <___pl_fn_15+0x49c>
    7174: aa1603e0     	mov	x0, x22
    7178: f9400001     	ldr	x1, [x0]
    717c: 2a0203e0     	mov	w0, w2
    7180: 8b000c20     	add	x0, x1, x0, lsl #3
    7184: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    7188: aa0203f7     	mov	x23, x2
    718c: d360fc21     	lsr	x1, x1, #32
    7190: 92403c21     	and	x1, x1, #0xffff
    7194: 91000422     	add	x2, x1, #0x1
    7198: f8627802     	ldr	x2, [x0, x2, lsl #3]
    719c: f100083f     	cmp	x1, #0x2
    71a0: 540000e0     	b.eq	0x71bc <___pl_fn_15+0xd4>
    71a4: f9400800     	ldr	x0, [x0, #0x10]
    71a8: 37081f00     	tbnz	w0, #0x1, 0x7588 <___pl_fn_15+0x4a0>
    71ac: 14000004     	b	0x71bc <___pl_fn_15+0xd4>
    71b0: aa1603e0     	mov	x0, x22
    71b4: f9401802     	ldr	x2, [x0, #0x30]
    71b8: 14000002     	b	0x71c0 <___pl_fn_15+0xd8>
    71bc: aa1603e0     	mov	x0, x22
    71c0: aa1603e0     	mov	x0, x22
    71c4: b9401814     	ldr	w20, [x0, #0x18]
    71c8: b9401c00     	ldr	w0, [x0, #0x1c]
    71cc: 11000e81     	add	w1, w20, #0x3
    71d0: 6b00003f     	cmp	w1, w0
    71d4: 54003208     	b.hi	0x7814 <___pl_fn_15+0x72c>
    71d8: aa1603e0     	mov	x0, x22
    71dc: f9401000     	ldr	x0, [x0, #0x20]
    71e0: 2a1403e1     	mov	w1, w20
    71e4: 8b010803     	add	x3, x0, x1, lsl #2
    71e8: b8345813     	str	w19, [x0, w20, uxtw #2]
    71ec: aa1703e0     	mov	x0, x23
    71f0: b9000460     	str	w0, [x3, #0x4]
    71f4: aa1503e1     	mov	x1, x21
    71f8: b9000861     	str	w1, [x3, #0x8]
    71fc: 11000e80     	add	w0, w20, #0x3
    7200: aa1603e3     	mov	x3, x22
    7204: b9001860     	str	w0, [x3, #0x18]
    7208: aa1603e0     	mov	x0, x22
    720c: b9401000     	ldr	w0, [x0, #0x10]
    7210: b9401463     	ldr	w3, [x3, #0x14]
    7214: 6b03001f     	cmp	w0, w3
    7218: 54002e62     	b.hs	0x77e4 <___pl_fn_15+0x6fc>
    721c: aa1603e0     	mov	x0, x22
    7220: 94000000     	bl	0x7220 <___pl_fn_15+0x138>
    7224: aa1603e1     	mov	x1, x22
    7228: b9402c21     	ldr	w1, [x1, #0x2c]
    722c: 35002ce1     	cbnz	w1, 0x77c8 <___pl_fn_15+0x6e0>
    7230: aa1603e1     	mov	x1, x22
    7234: b9001834     	str	w20, [x1, #0x18]
    7238: 34002b00     	cbz	w0, 0x7798 <___pl_fn_15+0x6b0>
    723c: aa0003fb     	mov	x27, x0
    7240: 34001b73     	cbz	w19, 0x75ac <___pl_fn_15+0x4c4>
    7244: aa1603e0     	mov	x0, x22
    7248: f9400003     	ldr	x3, [x0]
    724c: 2a1303e2     	mov	w2, w19
    7250: 8b020c62     	add	x2, x3, x2, lsl #3
    7254: f8735863     	ldr	x3, [x3, w19, uxtw #3]
    7258: d360fc63     	lsr	x3, x3, #32
    725c: 92403c63     	and	x3, x3, #0xffff
    7260: 91001c63     	add	x3, x3, #0x7
    7264: d37df063     	lsl	x3, x3, #3
    7268: b8636842     	ldr	w2, [x2, x3]
    726c: 35000082     	cbnz	w2, 0x727c <___pl_fn_15+0x194>
    7270: 140000cf     	b	0x75ac <___pl_fn_15+0x4c4>
    7274: aa1603e0     	mov	x0, x22
    7278: f9401802     	ldr	x2, [x0, #0x30]
    727c: 34001aa2     	cbz	w2, 0x75d0 <___pl_fn_15+0x4e8>
    7280: aa1603e0     	mov	x0, x22
    7284: f940000b     	ldr	x11, [x0]
    7288: 2a0203ea     	mov	w10, w2
    728c: 8b0a0d6a     	add	x10, x11, x10, lsl #3
    7290: f862596b     	ldr	x11, [x11, w2, uxtw #3]
    7294: d360fd6b     	lsr	x11, x11, #32
    7298: 92403d6b     	and	x11, x11, #0xffff
    729c: 9100296c     	add	x12, x11, #0xa
    72a0: f86c7940     	ldr	x0, [x10, x12, lsl #3]
    72a4: f100097f     	cmp	x11, #0x2
    72a8: 540000c0     	b.eq	0x72c0 <___pl_fn_15+0x1d8>
    72ac: f940094d     	ldr	x13, [x10, #0x10]
    72b0: 3750190d     	tbnz	w13, #0xa, 0x75d0 <___pl_fn_15+0x4e8>
    72b4: 14000003     	b	0x72c0 <___pl_fn_15+0x1d8>
    72b8: aa1603e0     	mov	x0, x22
    72bc: f9401800     	ldr	x0, [x0, #0x30]
    72c0: d2800034     	mov	x20, #0x1               ; =1
    72c4: ab140015     	adds	x21, x0, x20
    72c8: 9a9f77e0     	cset	x0, vs
    72cc: 72001c1f     	tst	w0, #0xff
    72d0: 540024c1     	b.ne	0x7768 <___pl_fn_15+0x680>
    72d4: 340018f3     	cbz	w19, 0x75f0 <___pl_fn_15+0x508>
    72d8: aa1603e0     	mov	x0, x22
    72dc: f9400001     	ldr	x1, [x0]
    72e0: 2a1303e0     	mov	w0, w19
    72e4: 8b000c20     	add	x0, x1, x0, lsl #3
    72e8: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    72ec: d360fc21     	lsr	x1, x1, #32
    72f0: 92403c21     	and	x1, x1, #0xffff
    72f4: 91001c21     	add	x1, x1, #0x7
    72f8: d37df021     	lsl	x1, x1, #3
    72fc: b8616802     	ldr	w2, [x0, x1]
    7300: 35000082     	cbnz	w2, 0x7310 <___pl_fn_15+0x228>
    7304: 140000bb     	b	0x75f0 <___pl_fn_15+0x508>
    7308: aa1603e0     	mov	x0, x22
    730c: f9401802     	ldr	x2, [x0, #0x30]
    7310: 34001822     	cbz	w2, 0x7614 <___pl_fn_15+0x52c>
    7314: aa1603e0     	mov	x0, x22
    7318: f9400001     	ldr	x1, [x0]
    731c: 2a0203e0     	mov	w0, w2
    7320: 8b000c20     	add	x0, x1, x0, lsl #3
    7324: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    7328: d360fc21     	lsr	x1, x1, #32
    732c: 92403c22     	and	x2, x1, #0xffff
    7330: f100085f     	cmp	x2, #0x2
    7334: 54000080     	b.eq	0x7344 <___pl_fn_15+0x25c>
    7338: f9400802     	ldr	x2, [x0, #0x10]
    733c: 9275f842     	and	x2, x2, #0xfffffffffffffbff
    7340: f9000802     	str	x2, [x0, #0x10]
    7344: 92403c21     	and	x1, x1, #0xffff
    7348: 91002821     	add	x1, x1, #0xa
    734c: f8217815     	str	x21, [x0, x1, lsl #3]
    7350: 34001793     	cbz	w19, 0x7640 <___pl_fn_15+0x558>
    7354: aa1603e0     	mov	x0, x22
    7358: f9400001     	ldr	x1, [x0]
    735c: 2a1303e0     	mov	w0, w19
    7360: 8b000c20     	add	x0, x1, x0, lsl #3
    7364: f8735821     	ldr	x1, [x1, w19, uxtw #3]
    7368: d360fc21     	lsr	x1, x1, #32
    736c: 92403c21     	and	x1, x1, #0xffff
    7370: 91001c21     	add	x1, x1, #0x7
    7374: d37df021     	lsl	x1, x1, #3
    7378: b8616802     	ldr	w2, [x0, x1]
    737c: 35000082     	cbnz	w2, 0x738c <___pl_fn_15+0x2a4>
    7380: 140000b0     	b	0x7640 <___pl_fn_15+0x558>
    7384: aa1603e0     	mov	x0, x22
    7388: f9401802     	ldr	x2, [x0, #0x30]
    738c: 340016c2     	cbz	w2, 0x7664 <___pl_fn_15+0x57c>
    7390: aa1603e0     	mov	x0, x22
    7394: f9400001     	ldr	x1, [x0]
    7398: 2a0203e0     	mov	w0, w2
    739c: 8b000c20     	add	x0, x1, x0, lsl #3
    73a0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    73a4: d360fc21     	lsr	x1, x1, #32
    73a8: 92403c21     	and	x1, x1, #0xffff
    73ac: 91000821     	add	x1, x1, #0x2
    73b0: d37df021     	lsl	x1, x1, #3
    73b4: b8616800     	ldr	w0, [x0, x1]
    73b8: 350000c0     	cbnz	w0, 0x73d0 <___pl_fn_15+0x2e8>
    73bc: 140000aa     	b	0x7664 <___pl_fn_15+0x57c>
    73c0: aa1603e0     	mov	x0, x22
    73c4: f9401800     	ldr	x0, [x0, #0x30]
    73c8: aa1703e2     	mov	x2, x23
    73cc: 14000002     	b	0x73d4 <___pl_fn_15+0x2ec>
    73d0: aa1703e2     	mov	x2, x23
    73d4: aa1703e2     	mov	x2, x23
    73d8: 34001562     	cbz	w2, 0x7684 <___pl_fn_15+0x59c>
    73dc: aa1603e1     	mov	x1, x22
    73e0: f9400023     	ldr	x3, [x1]
    73e4: aa1703e2     	mov	x2, x23
    73e8: 2a0203e2     	mov	w2, w2
    73ec: 8b020c62     	add	x2, x3, x2, lsl #3
    73f0: aa1703e6     	mov	x6, x23
    73f4: f8665864     	ldr	x4, [x3, w6, uxtw #3]
    73f8: 2a0003e3     	mov	w3, w0
    73fc: d360fc84     	lsr	x4, x4, #32
    7400: 92403c84     	and	x4, x4, #0xffff
    7404: f8247843     	str	x3, [x2, x4, lsl #3]
    7408: 34001593     	cbz	w19, 0x76b8 <___pl_fn_15+0x5d0>
    740c: aa1603e0     	mov	x0, x22
    7410: f9400007     	ldr	x7, [x0]
    7414: 2a1303e6     	mov	w6, w19
    7418: 8b060ce6     	add	x6, x7, x6, lsl #3
    741c: f87358e7     	ldr	x7, [x7, w19, uxtw #3]
    7420: d360fce7     	lsr	x7, x7, #32
    7424: 92403ce7     	and	x7, x7, #0xffff
    7428: 910004e8     	add	x8, x7, #0x1
    742c: f86878cb     	ldr	x11, [x6, x8, lsl #3]
    7430: f10008ff     	cmp	x7, #0x2
    7434: 54000100     	b.eq	0x7454 <___pl_fn_15+0x36c>
    7438: f94008c9     	ldr	x9, [x6, #0x10]
    743c: 370813e9     	tbnz	w9, #0x1, 0x76b8 <___pl_fn_15+0x5d0>
    7440: 14000005     	b	0x7454 <___pl_fn_15+0x36c>
    7444: aa1603e0     	mov	x0, x22
    7448: f940180b     	ldr	x11, [x0, #0x30]
    744c: aa1703e2     	mov	x2, x23
    7450: 14000002     	b	0x7458 <___pl_fn_15+0x370>
    7454: aa1703e2     	mov	x2, x23
    7458: aa1703e2     	mov	x2, x23
    745c: 35000082     	cbnz	w2, 0x746c <___pl_fn_15+0x384>
    7460: 1400009f     	b	0x76dc <___pl_fn_15+0x5f4>
    7464: aa1603e0     	mov	x0, x22
    7468: 14000012     	b	0x74b0 <___pl_fn_15+0x3c8>
    746c: aa1603e0     	mov	x0, x22
    7470: f9400001     	ldr	x1, [x0]
    7474: aa1703e2     	mov	x2, x23
    7478: 2a0203e0     	mov	w0, w2
    747c: 8b000c20     	add	x0, x1, x0, lsl #3
    7480: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    7484: d360fc21     	lsr	x1, x1, #32
    7488: 92403c22     	and	x2, x1, #0xffff
    748c: f100085f     	cmp	x2, #0x2
    7490: 54000080     	b.eq	0x74a0 <___pl_fn_15+0x3b8>
    7494: f9400802     	ldr	x2, [x0, #0x10]
    7498: 927ef842     	and	x2, x2, #0xfffffffffffffffd
    749c: f9000802     	str	x2, [x0, #0x10]
    74a0: 92403c21     	and	x1, x1, #0xffff
    74a4: 91000421     	add	x1, x1, #0x1
    74a8: f821780b     	str	x11, [x0, x1, lsl #3]
    74ac: aa1603e0     	mov	x0, x22
    74b0: aa1603e0     	mov	x0, x22
    74b4: b9401814     	ldr	w20, [x0, #0x18]
    74b8: b9401c01     	ldr	w1, [x0, #0x1c]
    74bc: 11000e80     	add	w0, w20, #0x3
    74c0: 6b01001f     	cmp	w0, w1
    74c4: 540013a8     	b.hi	0x7738 <___pl_fn_15+0x650>
    74c8: aa1603e1     	mov	x1, x22
    74cc: f9401021     	ldr	x1, [x1, #0x20]
    74d0: 2a1403e2     	mov	w2, w20
    74d4: 8b020822     	add	x2, x1, x2, lsl #2
    74d8: b8345833     	str	w19, [x1, w20, uxtw #2]
    74dc: aa1703ef     	mov	x15, x23
    74e0: b900044f     	str	w15, [x2, #0x4]
    74e4: aa1b03e1     	mov	x1, x27
    74e8: b9000841     	str	w1, [x2, #0x8]
    74ec: aa1603e1     	mov	x1, x22
    74f0: b9001820     	str	w0, [x1, #0x18]
    74f4: aa1603e0     	mov	x0, x22
    74f8: b9401000     	ldr	w0, [x0, #0x10]
    74fc: b9401421     	ldr	w1, [x1, #0x14]
    7500: 6b01001f     	cmp	w0, w1
    7504: 54001022     	b.hs	0x7708 <___pl_fn_15+0x620>
    7508: aa1b03e1     	mov	x1, x27
    750c: aa1703e2     	mov	x2, x23
    7510: aa1303e3     	mov	x3, x19
    7514: aa1603e0     	mov	x0, x22
    7518: 94000000     	bl	0x7518 <___pl_fn_15+0x430>
    751c: aa1603e4     	mov	x4, x22
    7520: b9402c81     	ldr	w1, [x4, #0x2c]
    7524: 35001521     	cbnz	w1, 0x77c8 <___pl_fn_15+0x6e0>
    7528: aa1603e8     	mov	x8, x22
    752c: b9001914     	str	w20, [x8, #0x18]
    7530: aa1603ea     	mov	x10, x22
    7534: b9401141     	ldr	w1, [x10, #0x10]
    7538: 51000421     	sub	w1, w1, #0x1
    753c: aa1603ed     	mov	x13, x22
    7540: b90011a1     	str	w1, [x13, #0x10]
    7544: 9100c3ff     	add	sp, sp, #0x30
    7548: a8c153f3     	ldp	x19, x20, [sp], #0x10
    754c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7550: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    7554: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7558: d65f03c0     	ret
    755c: aa0003f6     	mov	x22, x0
    7560: 52801b21     	mov	w1, #0xd9               ; =217
    7564: 528000e3     	mov	w3, #0x7                ; =7
    7568: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    756c: f9400084     	ldr	x4, [x4]
    7570: aa1603e0     	mov	x0, x22
    7574: aa1303e2     	mov	x2, x19
    7578: d63f0080     	blr	x4
    757c: 34ffdec0     	cbz	w0, 0x7154 <___pl_fn_15+0x6c>
    7580: 14000092     	b	0x77c8 <___pl_fn_15+0x6e0>
    7584: aa0203f7     	mov	x23, x2
    7588: 52801b41     	mov	w1, #0xda               ; =218
    758c: 52800023     	mov	w3, #0x1                ; =1
    7590: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    7594: f9400084     	ldr	x4, [x4]
    7598: aa1603e0     	mov	x0, x22
    759c: aa1703e2     	mov	x2, x23
    75a0: d63f0080     	blr	x4
    75a4: 34ffe060     	cbz	w0, 0x71b0 <___pl_fn_15+0xc8>
    75a8: 14000088     	b	0x77c8 <___pl_fn_15+0x6e0>
    75ac: 52801bc1     	mov	w1, #0xde               ; =222
    75b0: 528000e3     	mov	w3, #0x7                ; =7
    75b4: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    75b8: f9400084     	ldr	x4, [x4]
    75bc: aa1603e0     	mov	x0, x22
    75c0: aa1303e2     	mov	x2, x19
    75c4: d63f0080     	blr	x4
    75c8: 34ffe560     	cbz	w0, 0x7274 <___pl_fn_15+0x18c>
    75cc: 1400007f     	b	0x77c8 <___pl_fn_15+0x6e0>
    75d0: 52801be1     	mov	w1, #0xdf               ; =223
    75d4: 52800143     	mov	w3, #0xa                ; =10
    75d8: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    75dc: f9400084     	ldr	x4, [x4]
    75e0: aa1603e0     	mov	x0, x22
    75e4: d63f0080     	blr	x4
    75e8: 34ffe680     	cbz	w0, 0x72b8 <___pl_fn_15+0x1d0>
    75ec: 14000077     	b	0x77c8 <___pl_fn_15+0x6e0>
    75f0: 52801c21     	mov	w1, #0xe1               ; =225
    75f4: 528000e3     	mov	w3, #0x7                ; =7
    75f8: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    75fc: f9400084     	ldr	x4, [x4]
    7600: aa1603e0     	mov	x0, x22
    7604: aa1303e2     	mov	x2, x19
    7608: d63f0080     	blr	x4
    760c: 34ffe7e0     	cbz	w0, 0x7308 <___pl_fn_15+0x220>
    7610: 1400006e     	b	0x77c8 <___pl_fn_15+0x6e0>
    7614: d2800140     	mov	x0, #0xa                ; =10
    7618: 910003e3     	mov	x3, sp
    761c: f80003e0     	stur	x0, [sp]
    7620: f80083f5     	stur	x21, [sp, #0x8]
    7624: 52801c41     	mov	w1, #0xe2               ; =226
    7628: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    762c: f9400084     	ldr	x4, [x4]
    7630: aa1603e0     	mov	x0, x22
    7634: d63f0080     	blr	x4
    7638: 34ffe8c0     	cbz	w0, 0x7350 <___pl_fn_15+0x268>
    763c: 14000063     	b	0x77c8 <___pl_fn_15+0x6e0>
    7640: 52801c61     	mov	w1, #0xe3               ; =227
    7644: 528000e3     	mov	w3, #0x7                ; =7
    7648: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    764c: f9400084     	ldr	x4, [x4]
    7650: aa1603e0     	mov	x0, x22
    7654: aa1303e2     	mov	x2, x19
    7658: d63f0080     	blr	x4
    765c: 34ffe940     	cbz	w0, 0x7384 <___pl_fn_15+0x29c>
    7660: 1400005a     	b	0x77c8 <___pl_fn_15+0x6e0>
    7664: 52801c81     	mov	w1, #0xe4               ; =228
    7668: 52800043     	mov	w3, #0x2                ; =2
    766c: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    7670: f9400084     	ldr	x4, [x4]
    7674: aa1603e0     	mov	x0, x22
    7678: d63f0080     	blr	x4
    767c: 34ffea20     	cbz	w0, 0x73c0 <___pl_fn_15+0x2d8>
    7680: 14000052     	b	0x77c8 <___pl_fn_15+0x6e0>
    7684: d2800001     	mov	x1, #0x0                ; =0
    7688: 910043e3     	add	x3, sp, #0x10
    768c: f80103e1     	stur	x1, [sp, #0x10]
    7690: 2a0003e0     	mov	w0, w0
    7694: f80183e0     	stur	x0, [sp, #0x18]
    7698: 52801ca1     	mov	w1, #0xe5               ; =229
    769c: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    76a0: f9400084     	ldr	x4, [x4]
    76a4: aa1603e0     	mov	x0, x22
    76a8: aa1703e2     	mov	x2, x23
    76ac: d63f0080     	blr	x4
    76b0: 34ffeac0     	cbz	w0, 0x7408 <___pl_fn_15+0x320>
    76b4: 14000045     	b	0x77c8 <___pl_fn_15+0x6e0>
    76b8: 52801cc1     	mov	w1, #0xe6               ; =230
    76bc: 52800023     	mov	w3, #0x1                ; =1
    76c0: 9000000c     	adrp	x12, 0x7000 <___pl_fn_14+0x288>
    76c4: f940018c     	ldr	x12, [x12]
    76c8: aa1603e0     	mov	x0, x22
    76cc: aa1303e2     	mov	x2, x19
    76d0: d63f0180     	blr	x12
    76d4: 34ffeb80     	cbz	w0, 0x7444 <___pl_fn_15+0x35c>
    76d8: 1400003c     	b	0x77c8 <___pl_fn_15+0x6e0>
    76dc: 910083e3     	add	x3, sp, #0x20
    76e0: f80203f4     	stur	x20, [sp, #0x20]
    76e4: f80283eb     	stur	x11, [sp, #0x28]
    76e8: 52801ce1     	mov	w1, #0xe7               ; =231
    76ec: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    76f0: f9400084     	ldr	x4, [x4]
    76f4: aa1603e0     	mov	x0, x22
    76f8: aa1703e2     	mov	x2, x23
    76fc: d63f0080     	blr	x4
    7700: 34ffeb20     	cbz	w0, 0x7464 <___pl_fn_15+0x37c>
    7704: 14000031     	b	0x77c8 <___pl_fn_15+0x6e0>
    7708: 52801d21     	mov	w1, #0xe9               ; =233
    770c: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    7710: f9400042     	ldr	x2, [x2]
    7714: aa1603e0     	mov	x0, x22
    7718: d63f0040     	blr	x2
    771c: 52800000     	mov	w0, #0x0                ; =0
    7720: 9100c3ff     	add	sp, sp, #0x30
    7724: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7728: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    772c: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    7730: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7734: d65f03c0     	ret
    7738: 52801d01     	mov	w1, #0xe8               ; =232
    773c: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    7740: f9400042     	ldr	x2, [x2]
    7744: aa1603e0     	mov	x0, x22
    7748: d63f0040     	blr	x2
    774c: 52800000     	mov	w0, #0x0                ; =0
    7750: 9100c3ff     	add	sp, sp, #0x30
    7754: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7758: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    775c: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    7760: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7764: d65f03c0     	ret
    7768: 52801c01     	mov	w1, #0xe0               ; =224
    776c: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    7770: f9400042     	ldr	x2, [x2]
    7774: aa1603e0     	mov	x0, x22
    7778: d63f0040     	blr	x2
    777c: 52800000     	mov	w0, #0x0                ; =0
    7780: 9100c3ff     	add	sp, sp, #0x30
    7784: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7788: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    778c: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    7790: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7794: d65f03c0     	ret
    7798: 52801ba1     	mov	w1, #0xdd               ; =221
    779c: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    77a0: f9400042     	ldr	x2, [x2]
    77a4: aa1603e0     	mov	x0, x22
    77a8: d63f0040     	blr	x2
    77ac: 52800000     	mov	w0, #0x0                ; =0
    77b0: 9100c3ff     	add	sp, sp, #0x30
    77b4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    77b8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    77bc: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    77c0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    77c4: d65f03c0     	ret
    77c8: 52800000     	mov	w0, #0x0                ; =0
    77cc: 9100c3ff     	add	sp, sp, #0x30
    77d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    77d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    77d8: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    77dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    77e0: d65f03c0     	ret
    77e4: 52801b81     	mov	w1, #0xdc               ; =220
    77e8: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    77ec: f9400042     	ldr	x2, [x2]
    77f0: aa1603e0     	mov	x0, x22
    77f4: d63f0040     	blr	x2
    77f8: 52800000     	mov	w0, #0x0                ; =0
    77fc: 9100c3ff     	add	sp, sp, #0x30
    7800: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7804: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7808: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    780c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7810: d65f03c0     	ret
    7814: 52801b61     	mov	w1, #0xdb               ; =219
    7818: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    781c: f9400042     	ldr	x2, [x2]
    7820: aa1603e0     	mov	x0, x22
    7824: d63f0040     	blr	x2
    7828: 52800000     	mov	w0, #0x0                ; =0
    782c: 9100c3ff     	add	sp, sp, #0x30
    7830: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7834: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    7838: a8c16ff7     	ldp	x23, x27, [sp], #0x10
    783c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7840: d65f03c0     	ret

0000000000007844 <___pl_fn_16>:
    7844: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    7848: 910003fd     	mov	x29, sp
    784c: a9bf73f9     	stp	x25, x28, [sp, #-0x10]!
    7850: a9bf5ff5     	stp	x21, x23, [sp, #-0x10]!
    7854: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    7858: d10083ff     	sub	sp, sp, #0x20
    785c: aa0103f5     	mov	x21, x1
    7860: aa0203fc     	mov	x28, x2
    7864: b9401007     	ldr	w7, [x0, #0x10]
    7868: 110004e7     	add	w7, w7, #0x1
    786c: b9001007     	str	w7, [x0, #0x10]
    7870: aa1503e1     	mov	x1, x21
    7874: 340022e1     	cbz	w1, 0x7cd0 <___pl_fn_16+0x48c>
    7878: f940000c     	ldr	x12, [x0]
    787c: aa1503e1     	mov	x1, x21
    7880: aa0003f4     	mov	x20, x0
    7884: 2a0103eb     	mov	w11, w1
    7888: 8b0b0d8b     	add	x11, x12, x11, lsl #3
    788c: f861598c     	ldr	x12, [x12, w1, uxtw #3]
    7890: d360fd8c     	lsr	x12, x12, #32
    7894: 92403d8c     	and	x12, x12, #0xffff
    7898: 91001d8c     	add	x12, x12, #0x7
    789c: d37df18c     	lsl	x12, x12, #3
    78a0: b86c6962     	ldr	w2, [x11, x12]
    78a4: 35000082     	cbnz	w2, 0x78b4 <___pl_fn_16+0x70>
    78a8: 1400010b     	b	0x7cd4 <___pl_fn_16+0x490>
    78ac: aa1403e0     	mov	x0, x20
    78b0: f9401802     	ldr	x2, [x0, #0x30]
    78b4: 34002222     	cbz	w2, 0x7cf8 <___pl_fn_16+0x4b4>
    78b8: aa1403e0     	mov	x0, x20
    78bc: f9400001     	ldr	x1, [x0]
    78c0: 2a0203e0     	mov	w0, w2
    78c4: 8b000c20     	add	x0, x1, x0, lsl #3
    78c8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    78cc: d360fc21     	lsr	x1, x1, #32
    78d0: 92403c21     	and	x1, x1, #0xffff
    78d4: 91000821     	add	x1, x1, #0x2
    78d8: d37df021     	lsl	x1, x1, #3
    78dc: b8616800     	ldr	w0, [x0, x1]
    78e0: 350000c0     	cbnz	w0, 0x78f8 <___pl_fn_16+0xb4>
    78e4: 14000105     	b	0x7cf8 <___pl_fn_16+0x4b4>
    78e8: aa1403e0     	mov	x0, x20
    78ec: f9401800     	ldr	x0, [x0, #0x30]
    78f0: aa1c03e2     	mov	x2, x28
    78f4: 14000002     	b	0x78fc <___pl_fn_16+0xb8>
    78f8: aa1c03e2     	mov	x2, x28
    78fc: 6b00005f     	cmp	w2, w0
    7900: 540006e0     	b.eq	0x79dc <___pl_fn_16+0x198>
    7904: aa1503f3     	mov	x19, x21
    7908: 35000093     	cbnz	w19, 0x7918 <___pl_fn_16+0xd4>
    790c: 14000103     	b	0x7d18 <___pl_fn_16+0x4d4>
    7910: aa1403e0     	mov	x0, x20
    7914: 1400000f     	b	0x7950 <___pl_fn_16+0x10c>
    7918: aa1403e0     	mov	x0, x20
    791c: aa1303f5     	mov	x21, x19
    7920: f9400001     	ldr	x1, [x0]
    7924: aa1503e4     	mov	x4, x21
    7928: 2a0403e0     	mov	w0, w4
    792c: 8b000c20     	add	x0, x1, x0, lsl #3
    7930: aa1503e7     	mov	x7, x21
    7934: f8675823     	ldr	x3, [x1, w7, uxtw #3]
    7938: 2a0203e1     	mov	w1, w2
    793c: d360fc62     	lsr	x2, x3, #32
    7940: 92403c42     	and	x2, x2, #0xffff
    7944: 91002042     	add	x2, x2, #0x8
    7948: f8227801     	str	x1, [x0, x2, lsl #3]
    794c: aa1403e0     	mov	x0, x20
    7950: aa1403e0     	mov	x0, x20
    7954: b9401813     	ldr	w19, [x0, #0x18]
    7958: b9401c01     	ldr	w1, [x0, #0x1c]
    795c: 11000660     	add	w0, w19, #0x1
    7960: 6b01001f     	cmp	w0, w1
    7964: 540020e8     	b.hi	0x7d80 <___pl_fn_16+0x53c>
    7968: aa1403e1     	mov	x1, x20
    796c: f9401021     	ldr	x1, [x1, #0x20]
    7970: aa1503e2     	mov	x2, x21
    7974: b8335822     	str	w2, [x1, w19, uxtw #2]
    7978: aa1403e1     	mov	x1, x20
    797c: b9001820     	str	w0, [x1, #0x18]
    7980: aa1403e0     	mov	x0, x20
    7984: b9401000     	ldr	w0, [x0, #0x10]
    7988: b9401421     	ldr	w1, [x1, #0x14]
    798c: 6b01001f     	cmp	w0, w1
    7990: 54001e02     	b.hs	0x7d50 <___pl_fn_16+0x50c>
    7994: aa1503e1     	mov	x1, x21
    7998: aa1403e0     	mov	x0, x20
    799c: 94000000     	bl	0x799c <___pl_fn_16+0x158>
    79a0: aa1403e1     	mov	x1, x20
    79a4: b9402c21     	ldr	w1, [x1, #0x2c]
    79a8: 35002a41     	cbnz	w1, 0x7ef0 <___pl_fn_16+0x6ac>
    79ac: aa1403e1     	mov	x1, x20
    79b0: b9001833     	str	w19, [x1, #0x18]
    79b4: b9401021     	ldr	w1, [x1, #0x10]
    79b8: 51000421     	sub	w1, w1, #0x1
    79bc: aa1403e2     	mov	x2, x20
    79c0: b9001041     	str	w1, [x2, #0x10]
    79c4: 910083ff     	add	sp, sp, #0x20
    79c8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    79cc: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    79d0: a8c173f9     	ldp	x25, x28, [sp], #0x10
    79d4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    79d8: d65f03c0     	ret
    79dc: aa1503e1     	mov	x1, x21
    79e0: 34001e81     	cbz	w1, 0x7db0 <___pl_fn_16+0x56c>
    79e4: aa1403e0     	mov	x0, x20
    79e8: f9400001     	ldr	x1, [x0]
    79ec: aa1503e0     	mov	x0, x21
    79f0: 2a0003e0     	mov	w0, w0
    79f4: 8b000c20     	add	x0, x1, x0, lsl #3
    79f8: aa1503e2     	mov	x2, x21
    79fc: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    7a00: d360fc21     	lsr	x1, x1, #32
    7a04: 92403c21     	and	x1, x1, #0xffff
    7a08: 91002021     	add	x1, x1, #0x8
    7a0c: d37df021     	lsl	x1, x1, #3
    7a10: b8616802     	ldr	w2, [x0, x1]
    7a14: 35000082     	cbnz	w2, 0x7a24 <___pl_fn_16+0x1e0>
    7a18: 140000e6     	b	0x7db0 <___pl_fn_16+0x56c>
    7a1c: aa1403e0     	mov	x0, x20
    7a20: f9401802     	ldr	x2, [x0, #0x30]
    7a24: 52800000     	mov	w0, #0x0                ; =0
    7a28: aa0003f7     	mov	x23, x0
    7a2c: 34002a02     	cbz	w2, 0x7f6c <___pl_fn_16+0x728>
    7a30: aa1503e1     	mov	x1, x21
    7a34: aa0203f9     	mov	x25, x2
    7a38: 34001ce1     	cbz	w1, 0x7dd4 <___pl_fn_16+0x590>
    7a3c: aa1403e0     	mov	x0, x20
    7a40: f9400001     	ldr	x1, [x0]
    7a44: aa1503e0     	mov	x0, x21
    7a48: 2a0003e0     	mov	w0, w0
    7a4c: 8b000c20     	add	x0, x1, x0, lsl #3
    7a50: aa1503e2     	mov	x2, x21
    7a54: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    7a58: d360fc21     	lsr	x1, x1, #32
    7a5c: 92403c21     	and	x1, x1, #0xffff
    7a60: 91001c21     	add	x1, x1, #0x7
    7a64: d37df021     	lsl	x1, x1, #3
    7a68: b8616802     	ldr	w2, [x0, x1]
    7a6c: 35000082     	cbnz	w2, 0x7a7c <___pl_fn_16+0x238>
    7a70: 140000d9     	b	0x7dd4 <___pl_fn_16+0x590>
    7a74: aa1403e0     	mov	x0, x20
    7a78: f9401802     	ldr	x2, [x0, #0x30]
    7a7c: 34001be2     	cbz	w2, 0x7df8 <___pl_fn_16+0x5b4>
    7a80: aa1403e0     	mov	x0, x20
    7a84: f9400006     	ldr	x6, [x0]
    7a88: 2a0203e5     	mov	w5, w2
    7a8c: 8b050cc5     	add	x5, x6, x5, lsl #3
    7a90: f86258c6     	ldr	x6, [x6, w2, uxtw #3]
    7a94: d360fcc6     	lsr	x6, x6, #32
    7a98: 92403cc6     	and	x6, x6, #0xffff
    7a9c: 910008c6     	add	x6, x6, #0x2
    7aa0: d37df0c6     	lsl	x6, x6, #3
    7aa4: b86668a0     	ldr	w0, [x5, x6]
    7aa8: 350000c0     	cbnz	w0, 0x7ac0 <___pl_fn_16+0x27c>
    7aac: 140000d3     	b	0x7df8 <___pl_fn_16+0x5b4>
    7ab0: aa1403e0     	mov	x0, x20
    7ab4: f9401800     	ldr	x0, [x0, #0x30]
    7ab8: aa1903e2     	mov	x2, x25
    7abc: 14000002     	b	0x7ac4 <___pl_fn_16+0x280>
    7ac0: aa1903e2     	mov	x2, x25
    7ac4: 6b00005f     	cmp	w2, w0
    7ac8: aa0203f9     	mov	x25, x2
    7acc: 54000be0     	b.eq	0x7c48 <___pl_fn_16+0x404>
    7ad0: aa1503e1     	mov	x1, x21
    7ad4: 34001a21     	cbz	w1, 0x7e18 <___pl_fn_16+0x5d4>
    7ad8: aa1403e0     	mov	x0, x20
    7adc: f9400001     	ldr	x1, [x0]
    7ae0: aa1503e3     	mov	x3, x21
    7ae4: 2a0303e0     	mov	w0, w3
    7ae8: 8b000c20     	add	x0, x1, x0, lsl #3
    7aec: aa1503e6     	mov	x6, x21
    7af0: f8665821     	ldr	x1, [x1, w6, uxtw #3]
    7af4: d360fc21     	lsr	x1, x1, #32
    7af8: 92403c21     	and	x1, x1, #0xffff
    7afc: 91001c21     	add	x1, x1, #0x7
    7b00: d37df021     	lsl	x1, x1, #3
    7b04: b8616802     	ldr	w2, [x0, x1]
    7b08: 35000082     	cbnz	w2, 0x7b18 <___pl_fn_16+0x2d4>
    7b0c: 140000c3     	b	0x7e18 <___pl_fn_16+0x5d4>
    7b10: aa1403e0     	mov	x0, x20
    7b14: f9401802     	ldr	x2, [x0, #0x30]
    7b18: 34001922     	cbz	w2, 0x7e3c <___pl_fn_16+0x5f8>
    7b1c: aa1403e0     	mov	x0, x20
    7b20: f9400001     	ldr	x1, [x0]
    7b24: 2a0203e0     	mov	w0, w2
    7b28: 8b000c20     	add	x0, x1, x0, lsl #3
    7b2c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    7b30: d360fc21     	lsr	x1, x1, #32
    7b34: 92403c21     	and	x1, x1, #0xffff
    7b38: 91000821     	add	x1, x1, #0x2
    7b3c: d37df021     	lsl	x1, x1, #3
    7b40: b8616800     	ldr	w0, [x0, x1]
    7b44: 350000c0     	cbnz	w0, 0x7b5c <___pl_fn_16+0x318>
    7b48: 140000bd     	b	0x7e3c <___pl_fn_16+0x5f8>
    7b4c: aa1403e0     	mov	x0, x20
    7b50: f9401800     	ldr	x0, [x0, #0x30]
    7b54: aa1503e1     	mov	x1, x21
    7b58: 14000002     	b	0x7b60 <___pl_fn_16+0x31c>
    7b5c: aa1503e1     	mov	x1, x21
    7b60: aa1503e1     	mov	x1, x21
    7b64: 35000081     	cbnz	w1, 0x7b74 <___pl_fn_16+0x330>
    7b68: 140000bd     	b	0x7e5c <___pl_fn_16+0x618>
    7b6c: aa1403e0     	mov	x0, x20
    7b70: 1400000e     	b	0x7ba8 <___pl_fn_16+0x364>
    7b74: aa1403e1     	mov	x1, x20
    7b78: f9400022     	ldr	x2, [x1]
    7b7c: aa1503e1     	mov	x1, x21
    7b80: 2a0103e1     	mov	w1, w1
    7b84: 8b010c41     	add	x1, x2, x1, lsl #3
    7b88: aa1503e3     	mov	x3, x21
    7b8c: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    7b90: 2a0003e0     	mov	w0, w0
    7b94: d360fc42     	lsr	x2, x2, #32
    7b98: 92403c42     	and	x2, x2, #0xffff
    7b9c: 91002042     	add	x2, x2, #0x8
    7ba0: f8227820     	str	x0, [x1, x2, lsl #3]
    7ba4: aa1403e0     	mov	x0, x20
    7ba8: aa1403e0     	mov	x0, x20
    7bac: b9401813     	ldr	w19, [x0, #0x18]
    7bb0: b9401c00     	ldr	w0, [x0, #0x1c]
    7bb4: 11000a61     	add	w1, w19, #0x2
    7bb8: 6b00003f     	cmp	w1, w0
    7bbc: 54001828     	b.hi	0x7ec0 <___pl_fn_16+0x67c>
    7bc0: aa1403e0     	mov	x0, x20
    7bc4: f9401000     	ldr	x0, [x0, #0x20]
    7bc8: 2a1303e1     	mov	w1, w19
    7bcc: 8b010801     	add	x1, x0, x1, lsl #2
    7bd0: aa1503e2     	mov	x2, x21
    7bd4: b8335802     	str	w2, [x0, w19, uxtw #2]
    7bd8: aa1903e2     	mov	x2, x25
    7bdc: b9000422     	str	w2, [x1, #0x4]
    7be0: 11000a60     	add	w0, w19, #0x2
    7be4: aa1403e1     	mov	x1, x20
    7be8: b9001820     	str	w0, [x1, #0x18]
    7bec: aa1403e0     	mov	x0, x20
    7bf0: b9401000     	ldr	w0, [x0, #0x10]
    7bf4: b9401421     	ldr	w1, [x1, #0x14]
    7bf8: 6b01001f     	cmp	w0, w1
    7bfc: 540014a2     	b.hs	0x7e90 <___pl_fn_16+0x64c>
    7c00: aa1503e1     	mov	x1, x21
    7c04: aa1403e0     	mov	x0, x20
    7c08: 94000000     	bl	0x7c08 <___pl_fn_16+0x3c4>
    7c0c: aa1403e1     	mov	x1, x20
    7c10: b9402c21     	ldr	w1, [x1, #0x2c]
    7c14: 350016e1     	cbnz	w1, 0x7ef0 <___pl_fn_16+0x6ac>
    7c18: aa1403e1     	mov	x1, x20
    7c1c: b9001833     	str	w19, [x1, #0x18]
    7c20: b9401021     	ldr	w1, [x1, #0x10]
    7c24: 51000421     	sub	w1, w1, #0x1
    7c28: aa1403e2     	mov	x2, x20
    7c2c: b9001041     	str	w1, [x2, #0x10]
    7c30: 910083ff     	add	sp, sp, #0x20
    7c34: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7c38: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    7c3c: a8c173f9     	ldp	x25, x28, [sp], #0x10
    7c40: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7c44: d65f03c0     	ret
    7c48: aa1403e0     	mov	x0, x20
    7c4c: b9401813     	ldr	w19, [x0, #0x18]
    7c50: b9401c02     	ldr	w2, [x0, #0x1c]
    7c54: 11000661     	add	w1, w19, #0x1
    7c58: 6b02003f     	cmp	w1, w2
    7c5c: 54001708     	b.hi	0x7f3c <___pl_fn_16+0x6f8>
    7c60: aa1403e0     	mov	x0, x20
    7c64: f9401002     	ldr	x2, [x0, #0x20]
    7c68: aa1503e0     	mov	x0, x21
    7c6c: b8335840     	str	w0, [x2, w19, uxtw #2]
    7c70: aa1403e0     	mov	x0, x20
    7c74: b9001801     	str	w1, [x0, #0x18]
    7c78: b9401001     	ldr	w1, [x0, #0x10]
    7c7c: b9401402     	ldr	w2, [x0, #0x14]
    7c80: 6b02003f     	cmp	w1, w2
    7c84: 54001442     	b.hs	0x7f0c <___pl_fn_16+0x6c8>
    7c88: aa1503e1     	mov	x1, x21
    7c8c: aa1403e0     	mov	x0, x20
    7c90: 94000000     	bl	0x7c90 <___pl_fn_16+0x44c>
    7c94: aa1403e1     	mov	x1, x20
    7c98: b9402c21     	ldr	w1, [x1, #0x2c]
    7c9c: 350012a1     	cbnz	w1, 0x7ef0 <___pl_fn_16+0x6ac>
    7ca0: aa1403e1     	mov	x1, x20
    7ca4: b9001833     	str	w19, [x1, #0x18]
    7ca8: b9401021     	ldr	w1, [x1, #0x10]
    7cac: 51000421     	sub	w1, w1, #0x1
    7cb0: aa1403e2     	mov	x2, x20
    7cb4: b9001041     	str	w1, [x2, #0x10]
    7cb8: 910083ff     	add	sp, sp, #0x20
    7cbc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7cc0: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    7cc4: a8c173f9     	ldp	x25, x28, [sp], #0x10
    7cc8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7ccc: d65f03c0     	ret
    7cd0: aa0003f4     	mov	x20, x0
    7cd4: 52801d41     	mov	w1, #0xea               ; =234
    7cd8: 528000e3     	mov	w3, #0x7                ; =7
    7cdc: 9000000d     	adrp	x13, 0x7000 <___pl_fn_14+0x288>
    7ce0: f94001ad     	ldr	x13, [x13]
    7ce4: aa1403e0     	mov	x0, x20
    7ce8: aa1503e2     	mov	x2, x21
    7cec: d63f01a0     	blr	x13
    7cf0: 34ffdde0     	cbz	w0, 0x78ac <___pl_fn_16+0x68>
    7cf4: 1400007f     	b	0x7ef0 <___pl_fn_16+0x6ac>
    7cf8: 52801d61     	mov	w1, #0xeb               ; =235
    7cfc: 52800043     	mov	w3, #0x2                ; =2
    7d00: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    7d04: f9400084     	ldr	x4, [x4]
    7d08: aa1403e0     	mov	x0, x20
    7d0c: d63f0080     	blr	x4
    7d10: 34ffdec0     	cbz	w0, 0x78e8 <___pl_fn_16+0xa4>
    7d14: 14000077     	b	0x7ef0 <___pl_fn_16+0x6ac>
    7d18: d2800100     	mov	x0, #0x8                ; =8
    7d1c: 910003e3     	mov	x3, sp
    7d20: f80003e0     	stur	x0, [sp]
    7d24: 2a0203e0     	mov	w0, w2
    7d28: f80083e0     	stur	x0, [sp, #0x8]
    7d2c: 52801d81     	mov	w1, #0xec               ; =236
    7d30: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    7d34: f9400084     	ldr	x4, [x4]
    7d38: aa1403e0     	mov	x0, x20
    7d3c: aa1303e2     	mov	x2, x19
    7d40: d63f0080     	blr	x4
    7d44: aa1303f5     	mov	x21, x19
    7d48: 34ffde40     	cbz	w0, 0x7910 <___pl_fn_16+0xcc>
    7d4c: 14000069     	b	0x7ef0 <___pl_fn_16+0x6ac>
    7d50: 52801dc1     	mov	w1, #0xee               ; =238
    7d54: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    7d58: f9400042     	ldr	x2, [x2]
    7d5c: aa1403e0     	mov	x0, x20
    7d60: d63f0040     	blr	x2
    7d64: 52800000     	mov	w0, #0x0                ; =0
    7d68: 910083ff     	add	sp, sp, #0x20
    7d6c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7d70: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    7d74: a8c173f9     	ldp	x25, x28, [sp], #0x10
    7d78: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7d7c: d65f03c0     	ret
    7d80: 52801da1     	mov	w1, #0xed               ; =237
    7d84: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    7d88: f9400042     	ldr	x2, [x2]
    7d8c: aa1403e0     	mov	x0, x20
    7d90: d63f0040     	blr	x2
    7d94: 52800000     	mov	w0, #0x0                ; =0
    7d98: 910083ff     	add	sp, sp, #0x20
    7d9c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7da0: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    7da4: a8c173f9     	ldp	x25, x28, [sp], #0x10
    7da8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7dac: d65f03c0     	ret
    7db0: 52801de1     	mov	w1, #0xef               ; =239
    7db4: 52800103     	mov	w3, #0x8                ; =8
    7db8: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    7dbc: f9400084     	ldr	x4, [x4]
    7dc0: aa1403e0     	mov	x0, x20
    7dc4: aa1503e2     	mov	x2, x21
    7dc8: d63f0080     	blr	x4
    7dcc: 34ffe280     	cbz	w0, 0x7a1c <___pl_fn_16+0x1d8>
    7dd0: 14000048     	b	0x7ef0 <___pl_fn_16+0x6ac>
    7dd4: 52801e21     	mov	w1, #0xf1               ; =241
    7dd8: 528000e3     	mov	w3, #0x7                ; =7
    7ddc: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    7de0: f9400084     	ldr	x4, [x4]
    7de4: aa1403e0     	mov	x0, x20
    7de8: aa1503e2     	mov	x2, x21
    7dec: d63f0080     	blr	x4
    7df0: 34ffe420     	cbz	w0, 0x7a74 <___pl_fn_16+0x230>
    7df4: 1400003f     	b	0x7ef0 <___pl_fn_16+0x6ac>
    7df8: 52801e41     	mov	w1, #0xf2               ; =242
    7dfc: 52800043     	mov	w3, #0x2                ; =2
    7e00: 90000007     	adrp	x7, 0x7000 <___pl_fn_14+0x288>
    7e04: f94000e7     	ldr	x7, [x7]
    7e08: aa1403e0     	mov	x0, x20
    7e0c: d63f00e0     	blr	x7
    7e10: 34ffe500     	cbz	w0, 0x7ab0 <___pl_fn_16+0x26c>
    7e14: 14000037     	b	0x7ef0 <___pl_fn_16+0x6ac>
    7e18: 52801e61     	mov	w1, #0xf3               ; =243
    7e1c: 528000e3     	mov	w3, #0x7                ; =7
    7e20: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    7e24: f9400084     	ldr	x4, [x4]
    7e28: aa1403e0     	mov	x0, x20
    7e2c: aa1503e2     	mov	x2, x21
    7e30: d63f0080     	blr	x4
    7e34: 34ffe6e0     	cbz	w0, 0x7b10 <___pl_fn_16+0x2cc>
    7e38: 1400002e     	b	0x7ef0 <___pl_fn_16+0x6ac>
    7e3c: 52801e81     	mov	w1, #0xf4               ; =244
    7e40: 52800043     	mov	w3, #0x2                ; =2
    7e44: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    7e48: f9400084     	ldr	x4, [x4]
    7e4c: aa1403e0     	mov	x0, x20
    7e50: d63f0080     	blr	x4
    7e54: 34ffe7c0     	cbz	w0, 0x7b4c <___pl_fn_16+0x308>
    7e58: 14000026     	b	0x7ef0 <___pl_fn_16+0x6ac>
    7e5c: d2800101     	mov	x1, #0x8                ; =8
    7e60: 910043e3     	add	x3, sp, #0x10
    7e64: f80103e1     	stur	x1, [sp, #0x10]
    7e68: 2a0003e0     	mov	w0, w0
    7e6c: f80183e0     	stur	x0, [sp, #0x18]
    7e70: 52801ea1     	mov	w1, #0xf5               ; =245
    7e74: 90000004     	adrp	x4, 0x7000 <___pl_fn_14+0x288>
    7e78: f9400084     	ldr	x4, [x4]
    7e7c: aa1403e0     	mov	x0, x20
    7e80: aa1503e2     	mov	x2, x21
    7e84: d63f0080     	blr	x4
    7e88: 34ffe720     	cbz	w0, 0x7b6c <___pl_fn_16+0x328>
    7e8c: 14000019     	b	0x7ef0 <___pl_fn_16+0x6ac>
    7e90: 52801ee1     	mov	w1, #0xf7               ; =247
    7e94: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    7e98: f9400042     	ldr	x2, [x2]
    7e9c: aa1403e0     	mov	x0, x20
    7ea0: d63f0040     	blr	x2
    7ea4: aa1703e0     	mov	x0, x23
    7ea8: 910083ff     	add	sp, sp, #0x20
    7eac: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7eb0: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    7eb4: a8c173f9     	ldp	x25, x28, [sp], #0x10
    7eb8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7ebc: d65f03c0     	ret
    7ec0: 52801ec1     	mov	w1, #0xf6               ; =246
    7ec4: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    7ec8: f9400042     	ldr	x2, [x2]
    7ecc: aa1403e0     	mov	x0, x20
    7ed0: d63f0040     	blr	x2
    7ed4: aa1703e0     	mov	x0, x23
    7ed8: 910083ff     	add	sp, sp, #0x20
    7edc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7ee0: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    7ee4: a8c173f9     	ldp	x25, x28, [sp], #0x10
    7ee8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7eec: d65f03c0     	ret
    7ef0: 52800000     	mov	w0, #0x0                ; =0
    7ef4: 910083ff     	add	sp, sp, #0x20
    7ef8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7efc: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    7f00: a8c173f9     	ldp	x25, x28, [sp], #0x10
    7f04: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7f08: d65f03c0     	ret
    7f0c: 52801f21     	mov	w1, #0xf9               ; =249
    7f10: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    7f14: f9400042     	ldr	x2, [x2]
    7f18: aa1403e0     	mov	x0, x20
    7f1c: d63f0040     	blr	x2
    7f20: aa1703e0     	mov	x0, x23
    7f24: 910083ff     	add	sp, sp, #0x20
    7f28: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7f2c: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    7f30: a8c173f9     	ldp	x25, x28, [sp], #0x10
    7f34: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7f38: d65f03c0     	ret
    7f3c: 52801f01     	mov	w1, #0xf8               ; =248
    7f40: 90000002     	adrp	x2, 0x7000 <___pl_fn_14+0x288>
    7f44: f9400042     	ldr	x2, [x2]
    7f48: aa1403e0     	mov	x0, x20
    7f4c: d63f0040     	blr	x2
    7f50: aa1703e0     	mov	x0, x23
    7f54: 910083ff     	add	sp, sp, #0x20
    7f58: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7f5c: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    7f60: a8c173f9     	ldp	x25, x28, [sp], #0x10
    7f64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7f68: d65f03c0     	ret
    7f6c: 52801e01     	mov	w1, #0xf0               ; =240
    7f70: 90000003     	adrp	x3, 0x7000 <___pl_fn_14+0x288>
    7f74: f9400063     	ldr	x3, [x3]
    7f78: aa1403e0     	mov	x0, x20
    7f7c: d63f0060     	blr	x3
    7f80: aa1703e0     	mov	x0, x23
    7f84: 910083ff     	add	sp, sp, #0x20
    7f88: a8c153f3     	ldp	x19, x20, [sp], #0x10
    7f8c: a8c15ff5     	ldp	x21, x23, [sp], #0x10
    7f90: a8c173f9     	ldp	x25, x28, [sp], #0x10
    7f94: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    7f98: d65f03c0     	ret

0000000000007f9c <___pl_fn_17>:
    7f9c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    7fa0: 910003fd     	mov	x29, sp
    7fa4: f81f0ff9     	str	x25, [sp, #-0x10]!
    7fa8: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
    7fac: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    7fb0: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    7fb4: d10183ff     	sub	sp, sp, #0x60
    7fb8: aa0103f6     	mov	x22, x1
    7fbc: aa0203f7     	mov	x23, x2
    7fc0: b9401001     	ldr	w1, [x0, #0x10]
    7fc4: 11000421     	add	w1, w1, #0x1
    7fc8: b9001001     	str	w1, [x0, #0x10]
    7fcc: aa1603e1     	mov	x1, x22
    7fd0: 34005941     	cbz	w1, 0x8af8 <___pl_fn_17+0xb5c>
    7fd4: f9400001     	ldr	x1, [x0]
    7fd8: aa0003f5     	mov	x21, x0
    7fdc: aa1603e0     	mov	x0, x22
    7fe0: 2a0003e0     	mov	w0, w0
    7fe4: 8b000c20     	add	x0, x1, x0, lsl #3
    7fe8: aa1603e2     	mov	x2, x22
    7fec: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    7ff0: d360fc21     	lsr	x1, x1, #32
    7ff4: 92403c21     	and	x1, x1, #0xffff
    7ff8: 91001c21     	add	x1, x1, #0x7
    7ffc: d37df021     	lsl	x1, x1, #3
    8000: b8616802     	ldr	w2, [x0, x1]
    8004: 35000082     	cbnz	w2, 0x8014 <___pl_fn_17+0x78>
    8008: 140002bd     	b	0x8afc <___pl_fn_17+0xb60>
    800c: aa1503e0     	mov	x0, x21
    8010: f9401802     	ldr	x2, [x0, #0x30]
    8014: 34005862     	cbz	w2, 0x8b20 <___pl_fn_17+0xb84>
    8018: aa1503e0     	mov	x0, x21
    801c: f9400005     	ldr	x5, [x0]
    8020: 2a0203e4     	mov	w4, w2
    8024: 8b040ca4     	add	x4, x5, x4, lsl #3
    8028: f86258a5     	ldr	x5, [x5, w2, uxtw #3]
    802c: d360fca5     	lsr	x5, x5, #32
    8030: 92403ca5     	and	x5, x5, #0xffff
    8034: 910008a5     	add	x5, x5, #0x2
    8038: d37df0a5     	lsl	x5, x5, #3
    803c: b8656880     	ldr	w0, [x4, x5]
    8040: 350000c0     	cbnz	w0, 0x8058 <___pl_fn_17+0xbc>
    8044: 140002b7     	b	0x8b20 <___pl_fn_17+0xb84>
    8048: aa1503e0     	mov	x0, x21
    804c: f9401800     	ldr	x0, [x0, #0x30]
    8050: aa1703f3     	mov	x19, x23
    8054: 14000002     	b	0x805c <___pl_fn_17+0xc0>
    8058: aa1703f3     	mov	x19, x23
    805c: 6b00027f     	cmp	w19, w0
    8060: 54000061     	b.ne	0x806c <___pl_fn_17+0xd0>
    8064: aa1603e1     	mov	x1, x22
    8068: 140000e5     	b	0x83fc <___pl_fn_17+0x460>
    806c: 340056b3     	cbz	w19, 0x8b40 <___pl_fn_17+0xba4>
    8070: aa1503e0     	mov	x0, x21
    8074: f9400000     	ldr	x0, [x0]
    8078: 2a1303ef     	mov	w15, w19
    807c: 8b0f0c0f     	add	x15, x0, x15, lsl #3
    8080: f8735800     	ldr	x0, [x0, w19, uxtw #3]
    8084: d360fc00     	lsr	x0, x0, #32
    8088: 92403c00     	and	x0, x0, #0xffff
    808c: 91000801     	add	x1, x0, #0x2
    8090: f86179e3     	ldr	x3, [x15, x1, lsl #3]
    8094: f100081f     	cmp	x0, #0x2
    8098: 540000c0     	b.eq	0x80b0 <___pl_fn_17+0x114>
    809c: f94009e0     	ldr	x0, [x15, #0x10]
    80a0: 37105500     	tbnz	w0, #0x2, 0x8b40 <___pl_fn_17+0xba4>
    80a4: 14000003     	b	0x80b0 <___pl_fn_17+0x114>
    80a8: aa1503e0     	mov	x0, x21
    80ac: f9401803     	ldr	x3, [x0, #0x30]
    80b0: f10fa47f     	cmp	x3, #0x3e9
    80b4: 54000d00     	b.eq	0x8254 <___pl_fn_17+0x2b8>
    80b8: aa1603f4     	mov	x20, x22
    80bc: 34005554     	cbz	w20, 0x8b64 <___pl_fn_17+0xbc8>
    80c0: aa1503e0     	mov	x0, x21
    80c4: f9400001     	ldr	x1, [x0]
    80c8: 2a1403e0     	mov	w0, w20
    80cc: 8b000c20     	add	x0, x1, x0, lsl #3
    80d0: f8745821     	ldr	x1, [x1, w20, uxtw #3]
    80d4: d360fc21     	lsr	x1, x1, #32
    80d8: 92403c21     	and	x1, x1, #0xffff
    80dc: 91002421     	add	x1, x1, #0x9
    80e0: d37df021     	lsl	x1, x1, #3
    80e4: b8616802     	ldr	w2, [x0, x1]
    80e8: 350000e2     	cbnz	w2, 0x8104 <___pl_fn_17+0x168>
    80ec: 1400029e     	b	0x8b64 <___pl_fn_17+0xbc8>
    80f0: aa1503e0     	mov	x0, x21
    80f4: f9401802     	ldr	x2, [x0, #0x30]
    80f8: aa0203f7     	mov	x23, x2
    80fc: aa1603e1     	mov	x1, x22
    8100: 14000004     	b	0x8110 <___pl_fn_17+0x174>
    8104: aa1403f6     	mov	x22, x20
    8108: aa0203f7     	mov	x23, x2
    810c: aa1603e1     	mov	x1, x22
    8110: 340053e1     	cbz	w1, 0x8b8c <___pl_fn_17+0xbf0>
    8114: aa1503e0     	mov	x0, x21
    8118: f9400001     	ldr	x1, [x0]
    811c: aa1603e0     	mov	x0, x22
    8120: 2a0003e0     	mov	w0, w0
    8124: 8b000c20     	add	x0, x1, x0, lsl #3
    8128: aa1603e2     	mov	x2, x22
    812c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    8130: d360fc21     	lsr	x1, x1, #32
    8134: 92403c21     	and	x1, x1, #0xffff
    8138: 91001c21     	add	x1, x1, #0x7
    813c: d37df021     	lsl	x1, x1, #3
    8140: b8616802     	ldr	w2, [x0, x1]
    8144: 35000082     	cbnz	w2, 0x8154 <___pl_fn_17+0x1b8>
    8148: 14000291     	b	0x8b8c <___pl_fn_17+0xbf0>
    814c: aa1503e0     	mov	x0, x21
    8150: f9401802     	ldr	x2, [x0, #0x30]
    8154: 340052e2     	cbz	w2, 0x8bb0 <___pl_fn_17+0xc14>
    8158: aa1503e0     	mov	x0, x21
    815c: f9400001     	ldr	x1, [x0]
    8160: 2a0203e0     	mov	w0, w2
    8164: 8b000c20     	add	x0, x1, x0, lsl #3
    8168: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    816c: d360fc21     	lsr	x1, x1, #32
    8170: 92403c21     	and	x1, x1, #0xffff
    8174: 91000821     	add	x1, x1, #0x2
    8178: d37df021     	lsl	x1, x1, #3
    817c: b8616803     	ldr	w3, [x0, x1]
    8180: 350000a3     	cbnz	w3, 0x8194 <___pl_fn_17+0x1f8>
    8184: 1400028b     	b	0x8bb0 <___pl_fn_17+0xc14>
    8188: aa1503e0     	mov	x0, x21
    818c: f9401803     	ldr	x3, [x0, #0x30]
    8190: 14000002     	b	0x8198 <___pl_fn_17+0x1fc>
    8194: aa1503e0     	mov	x0, x21
    8198: aa1503e0     	mov	x0, x21
    819c: b9401814     	ldr	w20, [x0, #0x18]
    81a0: b9401c00     	ldr	w0, [x0, #0x1c]
    81a4: 11001281     	add	w1, w20, #0x4
    81a8: 6b00003f     	cmp	w1, w0
    81ac: 54005468     	b.hi	0x8c38 <___pl_fn_17+0xc9c>
    81b0: aa1503e0     	mov	x0, x21
    81b4: f9401001     	ldr	x1, [x0, #0x20]
    81b8: 2a1403e0     	mov	w0, w20
    81bc: 8b000820     	add	x0, x1, x0, lsl #2
    81c0: aa1603e2     	mov	x2, x22
    81c4: b8345822     	str	w2, [x1, w20, uxtw #2]
    81c8: b9000413     	str	w19, [x0, #0x4]
    81cc: aa1703e2     	mov	x2, x23
    81d0: aa1303f7     	mov	x23, x19
    81d4: b9000802     	str	w2, [x0, #0x8]
    81d8: b9000c03     	str	w3, [x0, #0xc]
    81dc: 11001280     	add	w0, w20, #0x4
    81e0: aa1503e1     	mov	x1, x21
    81e4: b9001820     	str	w0, [x1, #0x18]
    81e8: aa1503e0     	mov	x0, x21
    81ec: b9401000     	ldr	w0, [x0, #0x10]
    81f0: b9401421     	ldr	w1, [x1, #0x14]
    81f4: 6b01001f     	cmp	w0, w1
    81f8: 54005062     	b.hs	0x8c04 <___pl_fn_17+0xc68>
    81fc: aa1703e1     	mov	x1, x23
    8200: aa1503e0     	mov	x0, x21
    8204: 94000000     	bl	0x8204 <___pl_fn_17+0x268>
    8208: aa1503e1     	mov	x1, x21
    820c: b9402c21     	ldr	w1, [x1, #0x2c]
    8210: 35007d81     	cbnz	w1, 0x91c0 <___pl_fn_17+0x1224>
    8214: aa1503e1     	mov	x1, x21
    8218: b9001834     	str	w20, [x1, #0x18]
    821c: aa1603e1     	mov	x1, x22
    8220: 34004d81     	cbz	w1, 0x8bd0 <___pl_fn_17+0xc34>
    8224: aa1503e6     	mov	x6, x21
    8228: f94000c7     	ldr	x7, [x6]
    822c: aa1603e1     	mov	x1, x22
    8230: 2a0103e6     	mov	w6, w1
    8234: 8b060ce6     	add	x6, x7, x6, lsl #3
    8238: f86158e8     	ldr	x8, [x7, w1, uxtw #3]
    823c: 2a0003e7     	mov	w7, w0
    8240: d360fd08     	lsr	x8, x8, #32
    8244: 92403d08     	and	x8, x8, #0xffff
    8248: 91002508     	add	x8, x8, #0x9
    824c: f82878c7     	str	x7, [x6, x8, lsl #3]
    8250: 1400006a     	b	0x83f8 <___pl_fn_17+0x45c>
    8254: aa1603e1     	mov	x1, x22
    8258: aa1303f7     	mov	x23, x19
    825c: 34005081     	cbz	w1, 0x8c6c <___pl_fn_17+0xcd0>
    8260: aa1503e0     	mov	x0, x21
    8264: f940000e     	ldr	x14, [x0]
    8268: aa1603e1     	mov	x1, x22
    826c: 2a0103ed     	mov	w13, w1
    8270: 8b0d0dcd     	add	x13, x14, x13, lsl #3
    8274: f86159ce     	ldr	x14, [x14, w1, uxtw #3]
    8278: d360fdce     	lsr	x14, x14, #32
    827c: 92403dce     	and	x14, x14, #0xffff
    8280: 910021ce     	add	x14, x14, #0x8
    8284: d37df1ce     	lsl	x14, x14, #3
    8288: b86e69a2     	ldr	w2, [x13, x14]
    828c: 350000e2     	cbnz	w2, 0x82a8 <___pl_fn_17+0x30c>
    8290: 14000277     	b	0x8c6c <___pl_fn_17+0xcd0>
    8294: aa1503e0     	mov	x0, x21
    8298: f9401802     	ldr	x2, [x0, #0x30]
    829c: aa0203f4     	mov	x20, x2
    82a0: aa1603e1     	mov	x1, x22
    82a4: 14000003     	b	0x82b0 <___pl_fn_17+0x314>
    82a8: aa0203f4     	mov	x20, x2
    82ac: aa1603e1     	mov	x1, x22
    82b0: aa1603e1     	mov	x1, x22
    82b4: 34004ee1     	cbz	w1, 0x8c90 <___pl_fn_17+0xcf4>
    82b8: aa1503e0     	mov	x0, x21
    82bc: f9400001     	ldr	x1, [x0]
    82c0: aa1603e0     	mov	x0, x22
    82c4: 2a0003e0     	mov	w0, w0
    82c8: 8b000c20     	add	x0, x1, x0, lsl #3
    82cc: aa1603e2     	mov	x2, x22
    82d0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    82d4: d360fc21     	lsr	x1, x1, #32
    82d8: 92403c21     	and	x1, x1, #0xffff
    82dc: 91001c21     	add	x1, x1, #0x7
    82e0: d37df021     	lsl	x1, x1, #3
    82e4: b8616802     	ldr	w2, [x0, x1]
    82e8: 35000082     	cbnz	w2, 0x82f8 <___pl_fn_17+0x35c>
    82ec: 14000269     	b	0x8c90 <___pl_fn_17+0xcf4>
    82f0: aa1503e0     	mov	x0, x21
    82f4: f9401802     	ldr	x2, [x0, #0x30]
    82f8: 34004de2     	cbz	w2, 0x8cb4 <___pl_fn_17+0xd18>
    82fc: aa1503e0     	mov	x0, x21
    8300: f9400001     	ldr	x1, [x0]
    8304: 2a0203e0     	mov	w0, w2
    8308: 8b000c20     	add	x0, x1, x0, lsl #3
    830c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    8310: d360fc21     	lsr	x1, x1, #32
    8314: 92403c21     	and	x1, x1, #0xffff
    8318: 91000821     	add	x1, x1, #0x2
    831c: d37df021     	lsl	x1, x1, #3
    8320: b8616803     	ldr	w3, [x0, x1]
    8324: 350000a3     	cbnz	w3, 0x8338 <___pl_fn_17+0x39c>
    8328: 14000263     	b	0x8cb4 <___pl_fn_17+0xd18>
    832c: aa1503e0     	mov	x0, x21
    8330: f9401803     	ldr	x3, [x0, #0x30]
    8334: 14000002     	b	0x833c <___pl_fn_17+0x3a0>
    8338: aa1503e0     	mov	x0, x21
    833c: aa1503e0     	mov	x0, x21
    8340: b9401813     	ldr	w19, [x0, #0x18]
    8344: b9401c00     	ldr	w0, [x0, #0x1c]
    8348: 11001261     	add	w1, w19, #0x4
    834c: 6b00003f     	cmp	w1, w0
    8350: 54007628     	b.hi	0x9214 <___pl_fn_17+0x1278>
    8354: aa1503e0     	mov	x0, x21
    8358: f9401001     	ldr	x1, [x0, #0x20]
    835c: 2a1303e0     	mov	w0, w19
    8360: 8b000820     	add	x0, x1, x0, lsl #2
    8364: aa1603e2     	mov	x2, x22
    8368: b8335822     	str	w2, [x1, w19, uxtw #2]
    836c: aa1703e1     	mov	x1, x23
    8370: b9000401     	str	w1, [x0, #0x4]
    8374: aa1403e2     	mov	x2, x20
    8378: b9000802     	str	w2, [x0, #0x8]
    837c: b9000c03     	str	w3, [x0, #0xc]
    8380: 11001260     	add	w0, w19, #0x4
    8384: aa1503e1     	mov	x1, x21
    8388: b9001820     	str	w0, [x1, #0x18]
    838c: aa1503e0     	mov	x0, x21
    8390: b9401000     	ldr	w0, [x0, #0x10]
    8394: b9401421     	ldr	w1, [x1, #0x14]
    8398: 6b01001f     	cmp	w0, w1
    839c: 54007222     	b.hs	0x91e0 <___pl_fn_17+0x1244>
    83a0: aa1703e1     	mov	x1, x23
    83a4: aa1503e0     	mov	x0, x21
    83a8: 94000000     	bl	0x83a8 <___pl_fn_17+0x40c>
    83ac: aa1503e1     	mov	x1, x21
    83b0: b9402c21     	ldr	w1, [x1, #0x2c]
    83b4: 35007061     	cbnz	w1, 0x91c0 <___pl_fn_17+0x1224>
    83b8: aa1503e5     	mov	x5, x21
    83bc: b90018b3     	str	w19, [x5, #0x18]
    83c0: aa1603e1     	mov	x1, x22
    83c4: 34004881     	cbz	w1, 0x8cd4 <___pl_fn_17+0xd38>
    83c8: aa1503e1     	mov	x1, x21
    83cc: f9400022     	ldr	x2, [x1]
    83d0: aa1603e1     	mov	x1, x22
    83d4: 2a0103e1     	mov	w1, w1
    83d8: 8b010c41     	add	x1, x2, x1, lsl #3
    83dc: aa1603e3     	mov	x3, x22
    83e0: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    83e4: 2a0003e0     	mov	w0, w0
    83e8: d360fc42     	lsr	x2, x2, #32
    83ec: 92403c42     	and	x2, x2, #0xffff
    83f0: 91002042     	add	x2, x2, #0x8
    83f4: f8227820     	str	x0, [x1, x2, lsl #3]
    83f8: aa1603e1     	mov	x1, x22
    83fc: aa1603e1     	mov	x1, x22
    8400: 34004841     	cbz	w1, 0x8d08 <___pl_fn_17+0xd6c>
    8404: aa1503e0     	mov	x0, x21
    8408: f9400001     	ldr	x1, [x0]
    840c: aa1603ef     	mov	x15, x22
    8410: 2a0f03e0     	mov	w0, w15
    8414: 8b000c20     	add	x0, x1, x0, lsl #3
    8418: aa1603e2     	mov	x2, x22
    841c: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    8420: d360fc21     	lsr	x1, x1, #32
    8424: 92403c21     	and	x1, x1, #0xffff
    8428: 91002021     	add	x1, x1, #0x8
    842c: d37df021     	lsl	x1, x1, #3
    8430: b8616802     	ldr	w2, [x0, x1]
    8434: 35000082     	cbnz	w2, 0x8444 <___pl_fn_17+0x4a8>
    8438: 14000234     	b	0x8d08 <___pl_fn_17+0xd6c>
    843c: aa1503e0     	mov	x0, x21
    8440: f9401802     	ldr	x2, [x0, #0x30]
    8444: 52800000     	mov	w0, #0x0                ; =0
    8448: aa0003f7     	mov	x23, x0
    844c: 34006a02     	cbz	w2, 0x918c <___pl_fn_17+0x11f0>
    8450: aa1603e1     	mov	x1, x22
    8454: aa0203f8     	mov	x24, x2
    8458: 340046a1     	cbz	w1, 0x8d2c <___pl_fn_17+0xd90>
    845c: aa1503e0     	mov	x0, x21
    8460: f9400006     	ldr	x6, [x0]
    8464: aa1603e1     	mov	x1, x22
    8468: 2a0103e5     	mov	w5, w1
    846c: 8b050cc5     	add	x5, x6, x5, lsl #3
    8470: f86158c6     	ldr	x6, [x6, w1, uxtw #3]
    8474: d360fcc6     	lsr	x6, x6, #32
    8478: 92403cc6     	and	x6, x6, #0xffff
    847c: 91001cc6     	add	x6, x6, #0x7
    8480: d37df0c6     	lsl	x6, x6, #3
    8484: b86668a2     	ldr	w2, [x5, x6]
    8488: 35000082     	cbnz	w2, 0x8498 <___pl_fn_17+0x4fc>
    848c: 14000228     	b	0x8d2c <___pl_fn_17+0xd90>
    8490: aa1503e0     	mov	x0, x21
    8494: f9401802     	ldr	x2, [x0, #0x30]
    8498: 340045c2     	cbz	w2, 0x8d50 <___pl_fn_17+0xdb4>
    849c: aa1503e0     	mov	x0, x21
    84a0: f940000e     	ldr	x14, [x0]
    84a4: 2a0203ed     	mov	w13, w2
    84a8: 8b0d0dcd     	add	x13, x14, x13, lsl #3
    84ac: f86259ce     	ldr	x14, [x14, w2, uxtw #3]
    84b0: d360fdce     	lsr	x14, x14, #32
    84b4: 92403dce     	and	x14, x14, #0xffff
    84b8: 910009ce     	add	x14, x14, #0x2
    84bc: d37df1ce     	lsl	x14, x14, #3
    84c0: b86e69a7     	ldr	w7, [x13, x14]
    84c4: 350000c7     	cbnz	w7, 0x84dc <___pl_fn_17+0x540>
    84c8: 14000222     	b	0x8d50 <___pl_fn_17+0xdb4>
    84cc: aa1503e0     	mov	x0, x21
    84d0: f9401807     	ldr	x7, [x0, #0x30]
    84d4: aa1803e2     	mov	x2, x24
    84d8: 14000002     	b	0x84e0 <___pl_fn_17+0x544>
    84dc: aa1803e2     	mov	x2, x24
    84e0: 6b07005f     	cmp	w2, w7
    84e4: 54002c00     	b.eq	0x8a64 <___pl_fn_17+0xac8>
    84e8: 34004442     	cbz	w2, 0x8d70 <___pl_fn_17+0xdd4>
    84ec: aa1503e0     	mov	x0, x21
    84f0: f9400001     	ldr	x1, [x0]
    84f4: 2a0203e0     	mov	w0, w2
    84f8: 8b000c20     	add	x0, x1, x0, lsl #3
    84fc: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    8500: aa0203f8     	mov	x24, x2
    8504: d360fc21     	lsr	x1, x1, #32
    8508: 92403c21     	and	x1, x1, #0xffff
    850c: 91000c22     	add	x2, x1, #0x3
    8510: f8627813     	ldr	x19, [x0, x2, lsl #3]
    8514: f100083f     	cmp	x1, #0x2
    8518: 540000c0     	b.eq	0x8530 <___pl_fn_17+0x594>
    851c: f9400800     	ldr	x0, [x0, #0x10]
    8520: 371842a0     	tbnz	w0, #0x3, 0x8d74 <___pl_fn_17+0xdd8>
    8524: 14000003     	b	0x8530 <___pl_fn_17+0x594>
    8528: aa1503e0     	mov	x0, x21
    852c: f9401813     	ldr	x19, [x0, #0x30]
    8530: f100127f     	cmp	x19, #0x4
    8534: 54001f8a     	b.ge	0x8924 <___pl_fn_17+0x988>
    8538: aa1603e1     	mov	x1, x22
    853c: 340042e1     	cbz	w1, 0x8d98 <___pl_fn_17+0xdfc>
    8540: aa1503e0     	mov	x0, x21
    8544: f9400001     	ldr	x1, [x0]
    8548: aa1603e0     	mov	x0, x22
    854c: 2a0003e0     	mov	w0, w0
    8550: 8b000c20     	add	x0, x1, x0, lsl #3
    8554: aa1603e2     	mov	x2, x22
    8558: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    855c: d360fc21     	lsr	x1, x1, #32
    8560: 92403c21     	and	x1, x1, #0xffff
    8564: 91002421     	add	x1, x1, #0x9
    8568: d37df021     	lsl	x1, x1, #3
    856c: b8616802     	ldr	w2, [x0, x1]
    8570: 35000082     	cbnz	w2, 0x8580 <___pl_fn_17+0x5e4>
    8574: 14000209     	b	0x8d98 <___pl_fn_17+0xdfc>
    8578: aa1503e0     	mov	x0, x21
    857c: f9401802     	ldr	x2, [x0, #0x30]
    8580: 34005562     	cbz	w2, 0x902c <___pl_fn_17+0x1090>
    8584: aa1603e1     	mov	x1, x22
    8588: aa0203f9     	mov	x25, x2
    858c: 34004181     	cbz	w1, 0x8dbc <___pl_fn_17+0xe20>
    8590: aa1503e0     	mov	x0, x21
    8594: f9400001     	ldr	x1, [x0]
    8598: aa1603e0     	mov	x0, x22
    859c: 2a0003e0     	mov	w0, w0
    85a0: 8b000c20     	add	x0, x1, x0, lsl #3
    85a4: aa1603e2     	mov	x2, x22
    85a8: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    85ac: d360fc21     	lsr	x1, x1, #32
    85b0: 92403c21     	and	x1, x1, #0xffff
    85b4: 91001c21     	add	x1, x1, #0x7
    85b8: d37df021     	lsl	x1, x1, #3
    85bc: b8616802     	ldr	w2, [x0, x1]
    85c0: 35000082     	cbnz	w2, 0x85d0 <___pl_fn_17+0x634>
    85c4: 140001fe     	b	0x8dbc <___pl_fn_17+0xe20>
    85c8: aa1503e0     	mov	x0, x21
    85cc: f9401802     	ldr	x2, [x0, #0x30]
    85d0: 34004082     	cbz	w2, 0x8de0 <___pl_fn_17+0xe44>
    85d4: aa1503e0     	mov	x0, x21
    85d8: f9400001     	ldr	x1, [x0]
    85dc: 2a0203e0     	mov	w0, w2
    85e0: 8b000c20     	add	x0, x1, x0, lsl #3
    85e4: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    85e8: d360fc21     	lsr	x1, x1, #32
    85ec: 92403c21     	and	x1, x1, #0xffff
    85f0: 91000821     	add	x1, x1, #0x2
    85f4: d37df021     	lsl	x1, x1, #3
    85f8: b8616800     	ldr	w0, [x0, x1]
    85fc: 350000c0     	cbnz	w0, 0x8614 <___pl_fn_17+0x678>
    8600: 140001f8     	b	0x8de0 <___pl_fn_17+0xe44>
    8604: aa1503e0     	mov	x0, x21
    8608: f9401800     	ldr	x0, [x0, #0x30]
    860c: aa1903e2     	mov	x2, x25
    8610: 14000002     	b	0x8618 <___pl_fn_17+0x67c>
    8614: aa1903e2     	mov	x2, x25
    8618: 6b00005f     	cmp	w2, w0
    861c: 54001400     	b.eq	0x889c <___pl_fn_17+0x900>
    8620: 34003f02     	cbz	w2, 0x8e00 <___pl_fn_17+0xe64>
    8624: aa1503e0     	mov	x0, x21
    8628: f9400005     	ldr	x5, [x0]
    862c: 2a0203e4     	mov	w4, w2
    8630: 8b040ca4     	add	x4, x5, x4, lsl #3
    8634: f86258a5     	ldr	x5, [x5, w2, uxtw #3]
    8638: aa0203f9     	mov	x25, x2
    863c: d360fca5     	lsr	x5, x5, #32
    8640: 92403ca5     	and	x5, x5, #0xffff
    8644: d37df0a5     	lsl	x5, x5, #3
    8648: b8656889     	ldr	w9, [x4, x5]
    864c: 350000c9     	cbnz	w9, 0x8664 <___pl_fn_17+0x6c8>
    8650: 140001ed     	b	0x8e04 <___pl_fn_17+0xe68>
    8654: aa1503e0     	mov	x0, x21
    8658: f9401809     	ldr	x9, [x0, #0x30]
    865c: aa1603e1     	mov	x1, x22
    8660: 14000002     	b	0x8668 <___pl_fn_17+0x6cc>
    8664: aa1603e1     	mov	x1, x22
    8668: aa1603e1     	mov	x1, x22
    866c: 35000081     	cbnz	w1, 0x867c <___pl_fn_17+0x6e0>
    8670: 140001ee     	b	0x8e28 <___pl_fn_17+0xe8c>
    8674: aa1503e0     	mov	x0, x21
    8678: 1400000e     	b	0x86b0 <___pl_fn_17+0x714>
    867c: aa1503e0     	mov	x0, x21
    8680: f9400001     	ldr	x1, [x0]
    8684: aa1603e0     	mov	x0, x22
    8688: 2a0003e0     	mov	w0, w0
    868c: 8b000c20     	add	x0, x1, x0, lsl #3
    8690: aa1603e2     	mov	x2, x22
    8694: f8625822     	ldr	x2, [x1, w2, uxtw #3]
    8698: 2a0903e1     	mov	w1, w9
    869c: d360fc42     	lsr	x2, x2, #32
    86a0: 92403c42     	and	x2, x2, #0xffff
    86a4: 91002442     	add	x2, x2, #0x9
    86a8: f8227801     	str	x1, [x0, x2, lsl #3]
    86ac: aa1503e0     	mov	x0, x21
    86b0: aa1503e0     	mov	x0, x21
    86b4: b9401814     	ldr	w20, [x0, #0x18]
    86b8: b9401c00     	ldr	w0, [x0, #0x1c]
    86bc: 11000e81     	add	w1, w20, #0x3
    86c0: 6b00003f     	cmp	w1, w0
    86c4: 54004648     	b.hi	0x8f8c <___pl_fn_17+0xff0>
    86c8: aa1503e0     	mov	x0, x21
    86cc: f9401000     	ldr	x0, [x0, #0x20]
    86d0: 2a1403e1     	mov	w1, w20
    86d4: 8b010801     	add	x1, x0, x1, lsl #2
    86d8: aa1603e2     	mov	x2, x22
    86dc: b8345802     	str	w2, [x0, w20, uxtw #2]
    86e0: aa1803e2     	mov	x2, x24
    86e4: b9000422     	str	w2, [x1, #0x4]
    86e8: aa1903e2     	mov	x2, x25
    86ec: b9000822     	str	w2, [x1, #0x8]
    86f0: 11000e80     	add	w0, w20, #0x3
    86f4: aa1503e1     	mov	x1, x21
    86f8: b9001820     	str	w0, [x1, #0x18]
    86fc: aa1503e0     	mov	x0, x21
    8700: b9401000     	ldr	w0, [x0, #0x10]
    8704: b9401421     	ldr	w1, [x1, #0x14]
    8708: 6b01001f     	cmp	w0, w1
    870c: 54004262     	b.hs	0x8f58 <___pl_fn_17+0xfbc>
    8710: aa1503e0     	mov	x0, x21
    8714: aa1803e1     	mov	x1, x24
    8718: aa1303e2     	mov	x2, x19
    871c: 94000000     	bl	0x871c <___pl_fn_17+0x780>
    8720: aa1503e1     	mov	x1, x21
    8724: b9402c21     	ldr	w1, [x1, #0x2c]
    8728: 350054c1     	cbnz	w1, 0x91c0 <___pl_fn_17+0x1224>
    872c: aa1503e1     	mov	x1, x21
    8730: b9001834     	str	w20, [x1, #0x18]
    8734: aa1903e2     	mov	x2, x25
    8738: 34003922     	cbz	w2, 0x8e5c <___pl_fn_17+0xec0>
    873c: aa1503e1     	mov	x1, x21
    8740: f9400022     	ldr	x2, [x1]
    8744: aa1903e1     	mov	x1, x25
    8748: 2a0103e1     	mov	w1, w1
    874c: 8b010c41     	add	x1, x2, x1, lsl #3
    8750: aa1903e3     	mov	x3, x25
    8754: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    8758: d360fc42     	lsr	x2, x2, #32
    875c: 92403c43     	and	x3, x2, #0xffff
    8760: f100087f     	cmp	x3, #0x2
    8764: 54000080     	b.eq	0x8774 <___pl_fn_17+0x7d8>
    8768: f9400823     	ldr	x3, [x1, #0x10]
    876c: 927cf863     	and	x3, x3, #0xfffffffffffffff7
    8770: f9000823     	str	x3, [x1, #0x10]
    8774: 92403c42     	and	x2, x2, #0xffff
    8778: 91000c42     	add	x2, x2, #0x3
    877c: f8227820     	str	x0, [x1, x2, lsl #3]
    8780: d2800020     	mov	x0, #0x1                ; =1
    8784: ab000260     	adds	x0, x19, x0
    8788: 9a9f77e1     	cset	x1, vs
    878c: 72001c3f     	tst	w1, #0xff
    8790: 54003ca1     	b.ne	0x8f24 <___pl_fn_17+0xf88>
    8794: aa1803e2     	mov	x2, x24
    8798: 35000082     	cbnz	w2, 0x87a8 <___pl_fn_17+0x80c>
    879c: 140001bc     	b	0x8e8c <___pl_fn_17+0xef0>
    87a0: aa1503e0     	mov	x0, x21
    87a4: 14000013     	b	0x87f0 <___pl_fn_17+0x854>
    87a8: aa1503e1     	mov	x1, x21
    87ac: f9400022     	ldr	x2, [x1]
    87b0: aa1803ed     	mov	x13, x24
    87b4: 2a0d03e1     	mov	w1, w13
    87b8: 8b010c41     	add	x1, x2, x1, lsl #3
    87bc: aa1803e3     	mov	x3, x24
    87c0: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    87c4: d360fc42     	lsr	x2, x2, #32
    87c8: 92403c43     	and	x3, x2, #0xffff
    87cc: f100087f     	cmp	x3, #0x2
    87d0: 54000080     	b.eq	0x87e0 <___pl_fn_17+0x844>
    87d4: f9400823     	ldr	x3, [x1, #0x10]
    87d8: 927cf863     	and	x3, x3, #0xfffffffffffffff7
    87dc: f9000823     	str	x3, [x1, #0x10]
    87e0: 92403c42     	and	x2, x2, #0xffff
    87e4: 91000c42     	add	x2, x2, #0x3
    87e8: f8227820     	str	x0, [x1, x2, lsl #3]
    87ec: aa1503e0     	mov	x0, x21
    87f0: aa1503e0     	mov	x0, x21
    87f4: b9401813     	ldr	w19, [x0, #0x18]
    87f8: b9401c00     	ldr	w0, [x0, #0x1c]
    87fc: 11000a61     	add	w1, w19, #0x2
    8800: 6b00003f     	cmp	w1, w0
    8804: 54003768     	b.hi	0x8ef0 <___pl_fn_17+0xf54>
    8808: aa1503e0     	mov	x0, x21
    880c: f9401000     	ldr	x0, [x0, #0x20]
    8810: 2a1303e1     	mov	w1, w19
    8814: 8b010801     	add	x1, x0, x1, lsl #2
    8818: aa1603ef     	mov	x15, x22
    881c: b833580f     	str	w15, [x0, w19, uxtw #2]
    8820: aa1903e2     	mov	x2, x25
    8824: b9000422     	str	w2, [x1, #0x4]
    8828: 11000a60     	add	w0, w19, #0x2
    882c: aa1503e1     	mov	x1, x21
    8830: b9001820     	str	w0, [x1, #0x18]
    8834: aa1503e0     	mov	x0, x21
    8838: b9401000     	ldr	w0, [x0, #0x10]
    883c: b9401421     	ldr	w1, [x1, #0x14]
    8840: 6b01001f     	cmp	w0, w1
    8844: 540033c2     	b.hs	0x8ebc <___pl_fn_17+0xf20>
    8848: aa1603e1     	mov	x1, x22
    884c: aa1903e2     	mov	x2, x25
    8850: aa1503e0     	mov	x0, x21
    8854: 94000000     	bl	0x8854 <___pl_fn_17+0x8b8>
    8858: aa1503e1     	mov	x1, x21
    885c: b9402c21     	ldr	w1, [x1, #0x2c]
    8860: 35004b01     	cbnz	w1, 0x91c0 <___pl_fn_17+0x1224>
    8864: aa1503e3     	mov	x3, x21
    8868: b9001873     	str	w19, [x3, #0x18]
    886c: aa1503e5     	mov	x5, x21
    8870: b94010a4     	ldr	w4, [x5, #0x10]
    8874: 51000484     	sub	w4, w4, #0x1
    8878: aa1503e8     	mov	x8, x21
    887c: b9001104     	str	w4, [x8, #0x10]
    8880: 910183ff     	add	sp, sp, #0x60
    8884: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8888: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    888c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8890: f84107f9     	ldr	x25, [sp], #0x10
    8894: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8898: d65f03c0     	ret
    889c: aa1503e0     	mov	x0, x21
    88a0: b9401813     	ldr	w19, [x0, #0x18]
    88a4: b9401c0c     	ldr	w12, [x0, #0x1c]
    88a8: 1100066b     	add	w11, w19, #0x1
    88ac: 6b0c017f     	cmp	w11, w12
    88b0: 54003a48     	b.hi	0x8ff8 <___pl_fn_17+0x105c>
    88b4: aa1503e0     	mov	x0, x21
    88b8: f940100d     	ldr	x13, [x0, #0x20]
    88bc: aa1603e1     	mov	x1, x22
    88c0: b83359a1     	str	w1, [x13, w19, uxtw #2]
    88c4: b900180b     	str	w11, [x0, #0x18]
    88c8: b940100f     	ldr	w15, [x0, #0x10]
    88cc: b9401400     	ldr	w0, [x0, #0x14]
    88d0: 6b0001ff     	cmp	w15, w0
    88d4: 54003782     	b.hs	0x8fc4 <___pl_fn_17+0x1028>
    88d8: aa1603e1     	mov	x1, x22
    88dc: aa1503e0     	mov	x0, x21
    88e0: 94000000     	bl	0x88e0 <___pl_fn_17+0x944>
    88e4: aa1503e1     	mov	x1, x21
    88e8: b9402c21     	ldr	w1, [x1, #0x2c]
    88ec: 350046a1     	cbnz	w1, 0x91c0 <___pl_fn_17+0x1224>
    88f0: aa1503e1     	mov	x1, x21
    88f4: b9001833     	str	w19, [x1, #0x18]
    88f8: b9401021     	ldr	w1, [x1, #0x10]
    88fc: 51000421     	sub	w1, w1, #0x1
    8900: aa1503e2     	mov	x2, x21
    8904: b9001041     	str	w1, [x2, #0x10]
    8908: 910183ff     	add	sp, sp, #0x60
    890c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8910: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8914: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8918: f84107f9     	ldr	x25, [sp], #0x10
    891c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8920: d65f03c0     	ret
    8924: aa1803e2     	mov	x2, x24
    8928: 340039c2     	cbz	w2, 0x9060 <___pl_fn_17+0x10c4>
    892c: aa1503e0     	mov	x0, x21
    8930: f9400001     	ldr	x1, [x0]
    8934: aa1803e2     	mov	x2, x24
    8938: 2a0203e0     	mov	w0, w2
    893c: 8b000c20     	add	x0, x1, x0, lsl #3
    8940: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    8944: d360fc21     	lsr	x1, x1, #32
    8948: 92403c21     	and	x1, x1, #0xffff
    894c: d37df021     	lsl	x1, x1, #3
    8950: b8616800     	ldr	w0, [x0, x1]
    8954: 350000c0     	cbnz	w0, 0x896c <___pl_fn_17+0x9d0>
    8958: 140001c2     	b	0x9060 <___pl_fn_17+0x10c4>
    895c: aa1503e0     	mov	x0, x21
    8960: f9401800     	ldr	x0, [x0, #0x30]
    8964: aa1603e1     	mov	x1, x22
    8968: 14000002     	b	0x8970 <___pl_fn_17+0x9d4>
    896c: aa1603e1     	mov	x1, x22
    8970: aa1603e1     	mov	x1, x22
    8974: 35000081     	cbnz	w1, 0x8984 <___pl_fn_17+0x9e8>
    8978: 140001c3     	b	0x9084 <___pl_fn_17+0x10e8>
    897c: aa1503e0     	mov	x0, x21
    8980: 1400000e     	b	0x89b8 <___pl_fn_17+0xa1c>
    8984: aa1503e1     	mov	x1, x21
    8988: f9400022     	ldr	x2, [x1]
    898c: aa1603e1     	mov	x1, x22
    8990: 2a0103e1     	mov	w1, w1
    8994: 8b010c41     	add	x1, x2, x1, lsl #3
    8998: aa1603e3     	mov	x3, x22
    899c: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    89a0: 2a0003e0     	mov	w0, w0
    89a4: d360fc42     	lsr	x2, x2, #32
    89a8: 92403c42     	and	x2, x2, #0xffff
    89ac: 91002042     	add	x2, x2, #0x8
    89b0: f8227820     	str	x0, [x1, x2, lsl #3]
    89b4: aa1503e0     	mov	x0, x21
    89b8: aa1503e0     	mov	x0, x21
    89bc: b9401813     	ldr	w19, [x0, #0x18]
    89c0: b9401c00     	ldr	w0, [x0, #0x1c]
    89c4: 11000a61     	add	w1, w19, #0x2
    89c8: 6b00003f     	cmp	w1, w0
    89cc: 54003908     	b.hi	0x90ec <___pl_fn_17+0x1150>
    89d0: aa1503e0     	mov	x0, x21
    89d4: f9401000     	ldr	x0, [x0, #0x20]
    89d8: 2a1303e1     	mov	w1, w19
    89dc: 8b010801     	add	x1, x0, x1, lsl #2
    89e0: aa1603e2     	mov	x2, x22
    89e4: b8335802     	str	w2, [x0, w19, uxtw #2]
    89e8: aa1803e2     	mov	x2, x24
    89ec: b9000422     	str	w2, [x1, #0x4]
    89f0: 11000a60     	add	w0, w19, #0x2
    89f4: aa1503ef     	mov	x15, x21
    89f8: b90019e0     	str	w0, [x15, #0x18]
    89fc: aa1503e0     	mov	x0, x21
    8a00: b9401000     	ldr	w0, [x0, #0x10]
    8a04: aa1503e1     	mov	x1, x21
    8a08: b9401421     	ldr	w1, [x1, #0x14]
    8a0c: 6b01001f     	cmp	w0, w1
    8a10: 54003542     	b.hs	0x90b8 <___pl_fn_17+0x111c>
    8a14: aa1603e1     	mov	x1, x22
    8a18: aa1803e2     	mov	x2, x24
    8a1c: aa1503e0     	mov	x0, x21
    8a20: 94000000     	bl	0x8a20 <___pl_fn_17+0xa84>
    8a24: aa1503e1     	mov	x1, x21
    8a28: b9402c21     	ldr	w1, [x1, #0x2c]
    8a2c: 35003ca1     	cbnz	w1, 0x91c0 <___pl_fn_17+0x1224>
    8a30: aa1503e1     	mov	x1, x21
    8a34: b9001833     	str	w19, [x1, #0x18]
    8a38: b9401021     	ldr	w1, [x1, #0x10]
    8a3c: 51000421     	sub	w1, w1, #0x1
    8a40: aa1503e2     	mov	x2, x21
    8a44: b9001041     	str	w1, [x2, #0x10]
    8a48: 910183ff     	add	sp, sp, #0x60
    8a4c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8a50: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8a54: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8a58: f84107f9     	ldr	x25, [sp], #0x10
    8a5c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8a60: d65f03c0     	ret
    8a64: aa1503e0     	mov	x0, x21
    8a68: b9401813     	ldr	w19, [x0, #0x18]
    8a6c: b9401c01     	ldr	w1, [x0, #0x1c]
    8a70: 11000660     	add	w0, w19, #0x1
    8a74: 6b01001f     	cmp	w0, w1
    8a78: 54003708     	b.hi	0x9158 <___pl_fn_17+0x11bc>
    8a7c: aa1503e1     	mov	x1, x21
    8a80: f9401021     	ldr	x1, [x1, #0x20]
    8a84: aa1603e2     	mov	x2, x22
    8a88: b8335822     	str	w2, [x1, w19, uxtw #2]
    8a8c: aa1503e1     	mov	x1, x21
    8a90: b9001820     	str	w0, [x1, #0x18]
    8a94: aa1503e0     	mov	x0, x21
    8a98: b9401000     	ldr	w0, [x0, #0x10]
    8a9c: b9401421     	ldr	w1, [x1, #0x14]
    8aa0: 6b01001f     	cmp	w0, w1
    8aa4: 54003402     	b.hs	0x9124 <___pl_fn_17+0x1188>
    8aa8: aa1603e1     	mov	x1, x22
    8aac: aa1503e0     	mov	x0, x21
    8ab0: 94000000     	bl	0x8ab0 <___pl_fn_17+0xb14>
    8ab4: aa1503e2     	mov	x2, x21
    8ab8: b9402c41     	ldr	w1, [x2, #0x2c]
    8abc: 35003821     	cbnz	w1, 0x91c0 <___pl_fn_17+0x1224>
    8ac0: aa1503e6     	mov	x6, x21
    8ac4: b90018d3     	str	w19, [x6, #0x18]
    8ac8: aa1503e8     	mov	x8, x21
    8acc: b9401101     	ldr	w1, [x8, #0x10]
    8ad0: 51000421     	sub	w1, w1, #0x1
    8ad4: aa1503eb     	mov	x11, x21
    8ad8: b9001161     	str	w1, [x11, #0x10]
    8adc: 910183ff     	add	sp, sp, #0x60
    8ae0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8ae4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8ae8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8aec: f84107f9     	ldr	x25, [sp], #0x10
    8af0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8af4: d65f03c0     	ret
    8af8: aa0003f5     	mov	x21, x0
    8afc: 52801f41     	mov	w1, #0xfa               ; =250
    8b00: 528000e3     	mov	w3, #0x7                ; =7
    8b04: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8b08: f9400084     	ldr	x4, [x4]
    8b0c: aa1503e0     	mov	x0, x21
    8b10: aa1603e2     	mov	x2, x22
    8b14: d63f0080     	blr	x4
    8b18: 34ffa7a0     	cbz	w0, 0x800c <___pl_fn_17+0x70>
    8b1c: 140001a9     	b	0x91c0 <___pl_fn_17+0x1224>
    8b20: 52801f61     	mov	w1, #0xfb               ; =251
    8b24: 52800043     	mov	w3, #0x2                ; =2
    8b28: 90000006     	adrp	x6, 0x8000 <___pl_fn_17+0x64>
    8b2c: f94000c6     	ldr	x6, [x6]
    8b30: aa1503e0     	mov	x0, x21
    8b34: d63f00c0     	blr	x6
    8b38: 34ffa880     	cbz	w0, 0x8048 <___pl_fn_17+0xac>
    8b3c: 140001a1     	b	0x91c0 <___pl_fn_17+0x1224>
    8b40: 52801f81     	mov	w1, #0xfc               ; =252
    8b44: 52800043     	mov	w3, #0x2                ; =2
    8b48: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8b4c: f9400084     	ldr	x4, [x4]
    8b50: aa1503e0     	mov	x0, x21
    8b54: aa1303e2     	mov	x2, x19
    8b58: d63f0080     	blr	x4
    8b5c: 34ffaa60     	cbz	w0, 0x80a8 <___pl_fn_17+0x10c>
    8b60: 14000198     	b	0x91c0 <___pl_fn_17+0x1224>
    8b64: 52801fa1     	mov	w1, #0xfd               ; =253
    8b68: 52800123     	mov	w3, #0x9                ; =9
    8b6c: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8b70: f9400084     	ldr	x4, [x4]
    8b74: aa1503e0     	mov	x0, x21
    8b78: aa1403e2     	mov	x2, x20
    8b7c: d63f0080     	blr	x4
    8b80: aa1403f6     	mov	x22, x20
    8b84: 34ffab60     	cbz	w0, 0x80f0 <___pl_fn_17+0x154>
    8b88: 1400018e     	b	0x91c0 <___pl_fn_17+0x1224>
    8b8c: 52801fc1     	mov	w1, #0xfe               ; =254
    8b90: 528000e3     	mov	w3, #0x7                ; =7
    8b94: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8b98: f9400084     	ldr	x4, [x4]
    8b9c: aa1503e0     	mov	x0, x21
    8ba0: aa1603e2     	mov	x2, x22
    8ba4: d63f0080     	blr	x4
    8ba8: 34ffad20     	cbz	w0, 0x814c <___pl_fn_17+0x1b0>
    8bac: 14000185     	b	0x91c0 <___pl_fn_17+0x1224>
    8bb0: 52801fe1     	mov	w1, #0xff               ; =255
    8bb4: 52800043     	mov	w3, #0x2                ; =2
    8bb8: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8bbc: f9400084     	ldr	x4, [x4]
    8bc0: aa1503e0     	mov	x0, x21
    8bc4: d63f0080     	blr	x4
    8bc8: 34ffae00     	cbz	w0, 0x8188 <___pl_fn_17+0x1ec>
    8bcc: 1400017d     	b	0x91c0 <___pl_fn_17+0x1224>
    8bd0: d2800121     	mov	x1, #0x9                ; =9
    8bd4: 910003e3     	mov	x3, sp
    8bd8: f80003e1     	stur	x1, [sp]
    8bdc: 2a0003e2     	mov	w2, w0
    8be0: f80083e2     	stur	x2, [sp, #0x8]
    8be4: 52802041     	mov	w1, #0x102              ; =258
    8be8: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8bec: f9400084     	ldr	x4, [x4]
    8bf0: aa1503e0     	mov	x0, x21
    8bf4: aa1603e2     	mov	x2, x22
    8bf8: d63f0080     	blr	x4
    8bfc: 34ffbfe0     	cbz	w0, 0x83f8 <___pl_fn_17+0x45c>
    8c00: 14000170     	b	0x91c0 <___pl_fn_17+0x1224>
    8c04: 52802021     	mov	w1, #0x101              ; =257
    8c08: 90000009     	adrp	x9, 0x8000 <___pl_fn_17+0x64>
    8c0c: f9400129     	ldr	x9, [x9]
    8c10: aa1503e0     	mov	x0, x21
    8c14: d63f0120     	blr	x9
    8c18: 52800000     	mov	w0, #0x0                ; =0
    8c1c: 910183ff     	add	sp, sp, #0x60
    8c20: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8c24: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8c28: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8c2c: f84107f9     	ldr	x25, [sp], #0x10
    8c30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8c34: d65f03c0     	ret
    8c38: 52802001     	mov	w1, #0x100              ; =256
    8c3c: 9000000a     	adrp	x10, 0x8000 <___pl_fn_17+0x64>
    8c40: f940014a     	ldr	x10, [x10]
    8c44: aa1503e0     	mov	x0, x21
    8c48: d63f0140     	blr	x10
    8c4c: 52800000     	mov	w0, #0x0                ; =0
    8c50: 910183ff     	add	sp, sp, #0x60
    8c54: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8c58: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8c5c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8c60: f84107f9     	ldr	x25, [sp], #0x10
    8c64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8c68: d65f03c0     	ret
    8c6c: 52802061     	mov	w1, #0x103              ; =259
    8c70: 52800103     	mov	w3, #0x8                ; =8
    8c74: 9000000f     	adrp	x15, 0x8000 <___pl_fn_17+0x64>
    8c78: f94001ef     	ldr	x15, [x15]
    8c7c: aa1503e0     	mov	x0, x21
    8c80: aa1603e2     	mov	x2, x22
    8c84: d63f01e0     	blr	x15
    8c88: 34ffb060     	cbz	w0, 0x8294 <___pl_fn_17+0x2f8>
    8c8c: 1400014d     	b	0x91c0 <___pl_fn_17+0x1224>
    8c90: 52802081     	mov	w1, #0x104              ; =260
    8c94: 528000e3     	mov	w3, #0x7                ; =7
    8c98: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8c9c: f9400084     	ldr	x4, [x4]
    8ca0: aa1503e0     	mov	x0, x21
    8ca4: aa1603e2     	mov	x2, x22
    8ca8: d63f0080     	blr	x4
    8cac: 34ffb220     	cbz	w0, 0x82f0 <___pl_fn_17+0x354>
    8cb0: 14000144     	b	0x91c0 <___pl_fn_17+0x1224>
    8cb4: 528020a1     	mov	w1, #0x105              ; =261
    8cb8: 52800043     	mov	w3, #0x2                ; =2
    8cbc: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8cc0: f9400084     	ldr	x4, [x4]
    8cc4: aa1503e0     	mov	x0, x21
    8cc8: d63f0080     	blr	x4
    8ccc: 34ffb300     	cbz	w0, 0x832c <___pl_fn_17+0x390>
    8cd0: 1400013c     	b	0x91c0 <___pl_fn_17+0x1224>
    8cd4: d2800101     	mov	x1, #0x8                ; =8
    8cd8: 910043e3     	add	x3, sp, #0x10
    8cdc: f80103e1     	stur	x1, [sp, #0x10]
    8ce0: 2a0003e0     	mov	w0, w0
    8ce4: f80183e0     	stur	x0, [sp, #0x18]
    8ce8: 52802101     	mov	w1, #0x108              ; =264
    8cec: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8cf0: f9400084     	ldr	x4, [x4]
    8cf4: aa1503e0     	mov	x0, x21
    8cf8: aa1603e2     	mov	x2, x22
    8cfc: d63f0080     	blr	x4
    8d00: 34ffb7c0     	cbz	w0, 0x83f8 <___pl_fn_17+0x45c>
    8d04: 1400012f     	b	0x91c0 <___pl_fn_17+0x1224>
    8d08: 52802121     	mov	w1, #0x109              ; =265
    8d0c: 52800103     	mov	w3, #0x8                ; =8
    8d10: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8d14: f9400084     	ldr	x4, [x4]
    8d18: aa1503e0     	mov	x0, x21
    8d1c: aa1603e2     	mov	x2, x22
    8d20: d63f0080     	blr	x4
    8d24: 34ffb8c0     	cbz	w0, 0x843c <___pl_fn_17+0x4a0>
    8d28: 14000126     	b	0x91c0 <___pl_fn_17+0x1224>
    8d2c: 52802161     	mov	w1, #0x10b              ; =267
    8d30: 528000e3     	mov	w3, #0x7                ; =7
    8d34: 90000007     	adrp	x7, 0x8000 <___pl_fn_17+0x64>
    8d38: f94000e7     	ldr	x7, [x7]
    8d3c: aa1503e0     	mov	x0, x21
    8d40: aa1603e2     	mov	x2, x22
    8d44: d63f00e0     	blr	x7
    8d48: 34ffba40     	cbz	w0, 0x8490 <___pl_fn_17+0x4f4>
    8d4c: 1400011d     	b	0x91c0 <___pl_fn_17+0x1224>
    8d50: 52802181     	mov	w1, #0x10c              ; =268
    8d54: 52800043     	mov	w3, #0x2                ; =2
    8d58: 9000000f     	adrp	x15, 0x8000 <___pl_fn_17+0x64>
    8d5c: f94001ef     	ldr	x15, [x15]
    8d60: aa1503e0     	mov	x0, x21
    8d64: d63f01e0     	blr	x15
    8d68: 34ffbb20     	cbz	w0, 0x84cc <___pl_fn_17+0x530>
    8d6c: 14000115     	b	0x91c0 <___pl_fn_17+0x1224>
    8d70: aa0203f8     	mov	x24, x2
    8d74: 528021a1     	mov	w1, #0x10d              ; =269
    8d78: 52800063     	mov	w3, #0x3                ; =3
    8d7c: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8d80: f9400084     	ldr	x4, [x4]
    8d84: aa1503e0     	mov	x0, x21
    8d88: aa1803e2     	mov	x2, x24
    8d8c: d63f0080     	blr	x4
    8d90: 34ffbcc0     	cbz	w0, 0x8528 <___pl_fn_17+0x58c>
    8d94: 1400010b     	b	0x91c0 <___pl_fn_17+0x1224>
    8d98: 528021c1     	mov	w1, #0x10e              ; =270
    8d9c: 52800123     	mov	w3, #0x9                ; =9
    8da0: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8da4: f9400084     	ldr	x4, [x4]
    8da8: aa1503e0     	mov	x0, x21
    8dac: aa1603e2     	mov	x2, x22
    8db0: d63f0080     	blr	x4
    8db4: 34ffbe20     	cbz	w0, 0x8578 <___pl_fn_17+0x5dc>
    8db8: 14000102     	b	0x91c0 <___pl_fn_17+0x1224>
    8dbc: 52802201     	mov	w1, #0x110              ; =272
    8dc0: 528000e3     	mov	w3, #0x7                ; =7
    8dc4: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8dc8: f9400084     	ldr	x4, [x4]
    8dcc: aa1503e0     	mov	x0, x21
    8dd0: aa1603e2     	mov	x2, x22
    8dd4: d63f0080     	blr	x4
    8dd8: 34ffbf80     	cbz	w0, 0x85c8 <___pl_fn_17+0x62c>
    8ddc: 140000f9     	b	0x91c0 <___pl_fn_17+0x1224>
    8de0: 52802221     	mov	w1, #0x111              ; =273
    8de4: 52800043     	mov	w3, #0x2                ; =2
    8de8: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8dec: f9400084     	ldr	x4, [x4]
    8df0: aa1503e0     	mov	x0, x21
    8df4: d63f0080     	blr	x4
    8df8: 34ffc060     	cbz	w0, 0x8604 <___pl_fn_17+0x668>
    8dfc: 140000f1     	b	0x91c0 <___pl_fn_17+0x1224>
    8e00: aa0203f9     	mov	x25, x2
    8e04: 52802241     	mov	w1, #0x112              ; =274
    8e08: 90000006     	adrp	x6, 0x8000 <___pl_fn_17+0x64>
    8e0c: f94000c6     	ldr	x6, [x6]
    8e10: aa1503e0     	mov	x0, x21
    8e14: aa1903e2     	mov	x2, x25
    8e18: aa1703e3     	mov	x3, x23
    8e1c: d63f00c0     	blr	x6
    8e20: 34ffc1a0     	cbz	w0, 0x8654 <___pl_fn_17+0x6b8>
    8e24: 140000e7     	b	0x91c0 <___pl_fn_17+0x1224>
    8e28: d280012b     	mov	x11, #0x9               ; =9
    8e2c: 910083e3     	add	x3, sp, #0x20
    8e30: f80203eb     	stur	x11, [sp, #0x20]
    8e34: 2a0903ec     	mov	w12, w9
    8e38: f80283ec     	stur	x12, [sp, #0x28]
    8e3c: 52802261     	mov	w1, #0x113              ; =275
    8e40: 9000000d     	adrp	x13, 0x8000 <___pl_fn_17+0x64>
    8e44: f94001ad     	ldr	x13, [x13]
    8e48: aa1503e0     	mov	x0, x21
    8e4c: aa1603e2     	mov	x2, x22
    8e50: d63f01a0     	blr	x13
    8e54: 34ffc100     	cbz	w0, 0x8674 <___pl_fn_17+0x6d8>
    8e58: 140000da     	b	0x91c0 <___pl_fn_17+0x1224>
    8e5c: d2800061     	mov	x1, #0x3                ; =3
    8e60: 9100c3e3     	add	x3, sp, #0x30
    8e64: f80303e1     	stur	x1, [sp, #0x30]
    8e68: f80383e0     	stur	x0, [sp, #0x38]
    8e6c: 528022c1     	mov	w1, #0x116              ; =278
    8e70: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8e74: f9400084     	ldr	x4, [x4]
    8e78: aa1503e0     	mov	x0, x21
    8e7c: aa1903e2     	mov	x2, x25
    8e80: d63f0080     	blr	x4
    8e84: 34ffc7e0     	cbz	w0, 0x8780 <___pl_fn_17+0x7e4>
    8e88: 140000ce     	b	0x91c0 <___pl_fn_17+0x1224>
    8e8c: d2800061     	mov	x1, #0x3                ; =3
    8e90: 910103e3     	add	x3, sp, #0x40
    8e94: f80403e1     	stur	x1, [sp, #0x40]
    8e98: f80483e0     	stur	x0, [sp, #0x48]
    8e9c: 52802301     	mov	w1, #0x118              ; =280
    8ea0: 90000004     	adrp	x4, 0x8000 <___pl_fn_17+0x64>
    8ea4: f9400084     	ldr	x4, [x4]
    8ea8: aa1803e2     	mov	x2, x24
    8eac: aa1503e0     	mov	x0, x21
    8eb0: d63f0080     	blr	x4
    8eb4: 34ffc760     	cbz	w0, 0x87a0 <___pl_fn_17+0x804>
    8eb8: 140000c2     	b	0x91c0 <___pl_fn_17+0x1224>
    8ebc: 52802341     	mov	w1, #0x11a              ; =282
    8ec0: 90000006     	adrp	x6, 0x8000 <___pl_fn_17+0x64>
    8ec4: f94000c6     	ldr	x6, [x6]
    8ec8: aa1503e0     	mov	x0, x21
    8ecc: d63f00c0     	blr	x6
    8ed0: aa1703e0     	mov	x0, x23
    8ed4: 910183ff     	add	sp, sp, #0x60
    8ed8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8edc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8ee0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8ee4: f84107f9     	ldr	x25, [sp], #0x10
    8ee8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8eec: d65f03c0     	ret
    8ef0: 52802321     	mov	w1, #0x119              ; =281
    8ef4: 90000007     	adrp	x7, 0x8000 <___pl_fn_17+0x64>
    8ef8: f94000e7     	ldr	x7, [x7]
    8efc: aa1503e0     	mov	x0, x21
    8f00: d63f00e0     	blr	x7
    8f04: aa1703e0     	mov	x0, x23
    8f08: 910183ff     	add	sp, sp, #0x60
    8f0c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8f10: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8f14: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8f18: f84107f9     	ldr	x25, [sp], #0x10
    8f1c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8f20: d65f03c0     	ret
    8f24: 528022e1     	mov	w1, #0x117              ; =279
    8f28: 90000008     	adrp	x8, 0x8000 <___pl_fn_17+0x64>
    8f2c: f9400108     	ldr	x8, [x8]
    8f30: aa1503e0     	mov	x0, x21
    8f34: d63f0100     	blr	x8
    8f38: aa1703e0     	mov	x0, x23
    8f3c: 910183ff     	add	sp, sp, #0x60
    8f40: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8f44: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8f48: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8f4c: f84107f9     	ldr	x25, [sp], #0x10
    8f50: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8f54: d65f03c0     	ret
    8f58: 528022a1     	mov	w1, #0x115              ; =277
    8f5c: 90000009     	adrp	x9, 0x8000 <___pl_fn_17+0x64>
    8f60: f9400129     	ldr	x9, [x9]
    8f64: aa1503e0     	mov	x0, x21
    8f68: d63f0120     	blr	x9
    8f6c: aa1703e0     	mov	x0, x23
    8f70: 910183ff     	add	sp, sp, #0x60
    8f74: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8f78: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8f7c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8f80: f84107f9     	ldr	x25, [sp], #0x10
    8f84: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8f88: d65f03c0     	ret
    8f8c: 52802281     	mov	w1, #0x114              ; =276
    8f90: 9000000a     	adrp	x10, 0x8000 <___pl_fn_17+0x64>
    8f94: f940014a     	ldr	x10, [x10]
    8f98: aa1503e0     	mov	x0, x21
    8f9c: d63f0140     	blr	x10
    8fa0: aa1703e0     	mov	x0, x23
    8fa4: 910183ff     	add	sp, sp, #0x60
    8fa8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8fac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8fb0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8fb4: f84107f9     	ldr	x25, [sp], #0x10
    8fb8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8fbc: d65f03c0     	ret
    8fc0: 14000080     	b	0x91c0 <___pl_fn_17+0x1224>
    8fc4: 52802381     	mov	w1, #0x11c              ; =284
    8fc8: 90000002     	adrp	x2, 0x8000 <___pl_fn_17+0x64>
    8fcc: f9400042     	ldr	x2, [x2]
    8fd0: aa1503e0     	mov	x0, x21
    8fd4: d63f0040     	blr	x2
    8fd8: aa1703e0     	mov	x0, x23
    8fdc: 910183ff     	add	sp, sp, #0x60
    8fe0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    8fe4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    8fe8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    8fec: f84107f9     	ldr	x25, [sp], #0x10
    8ff0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    8ff4: d65f03c0     	ret
    8ff8: 52802361     	mov	w1, #0x11b              ; =283
    8ffc: 90000002     	adrp	x2, 0x8000 <___pl_fn_17+0x64>
    9000: f9400042     	ldr	x2, [x2]
    9004: aa1503e0     	mov	x0, x21
    9008: d63f0040     	blr	x2
    900c: aa1703e0     	mov	x0, x23
    9010: 910183ff     	add	sp, sp, #0x60
    9014: a8c153f3     	ldp	x19, x20, [sp], #0x10
    9018: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    901c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    9020: f84107f9     	ldr	x25, [sp], #0x10
    9024: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    9028: d65f03c0     	ret
    902c: 528021e1     	mov	w1, #0x10f              ; =271
    9030: 90000002     	adrp	x2, 0x9000 <___pl_fn_17+0x1064>
    9034: f9400042     	ldr	x2, [x2]
    9038: aa1503e0     	mov	x0, x21
    903c: d63f0040     	blr	x2
    9040: aa1703e0     	mov	x0, x23
    9044: 910183ff     	add	sp, sp, #0x60
    9048: a8c153f3     	ldp	x19, x20, [sp], #0x10
    904c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    9050: a8c163f7     	ldp	x23, x24, [sp], #0x10
    9054: f84107f9     	ldr	x25, [sp], #0x10
    9058: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    905c: d65f03c0     	ret
    9060: 528023a1     	mov	w1, #0x11d              ; =285
    9064: 90000004     	adrp	x4, 0x9000 <___pl_fn_17+0x1064>
    9068: f9400084     	ldr	x4, [x4]
    906c: aa1503e0     	mov	x0, x21
    9070: aa1803e2     	mov	x2, x24
    9074: aa1703e3     	mov	x3, x23
    9078: d63f0080     	blr	x4
    907c: 34ffc700     	cbz	w0, 0x895c <___pl_fn_17+0x9c0>
    9080: 14000050     	b	0x91c0 <___pl_fn_17+0x1224>
    9084: d2800101     	mov	x1, #0x8                ; =8
    9088: 910143e3     	add	x3, sp, #0x50
    908c: f80503e1     	stur	x1, [sp, #0x50]
    9090: 2a0003e0     	mov	w0, w0
    9094: f80583e0     	stur	x0, [sp, #0x58]
    9098: 528023c1     	mov	w1, #0x11e              ; =286
    909c: 90000004     	adrp	x4, 0x9000 <___pl_fn_17+0x1064>
    90a0: f9400084     	ldr	x4, [x4]
    90a4: aa1503e0     	mov	x0, x21
    90a8: aa1603e2     	mov	x2, x22
    90ac: d63f0080     	blr	x4
    90b0: 34ffc660     	cbz	w0, 0x897c <___pl_fn_17+0x9e0>
    90b4: 14000043     	b	0x91c0 <___pl_fn_17+0x1224>
    90b8: 52802401     	mov	w1, #0x120              ; =288
    90bc: 90000002     	adrp	x2, 0x9000 <___pl_fn_17+0x1064>
    90c0: f9400042     	ldr	x2, [x2]
    90c4: aa1503e0     	mov	x0, x21
    90c8: d63f0040     	blr	x2
    90cc: aa1703e0     	mov	x0, x23
    90d0: 910183ff     	add	sp, sp, #0x60
    90d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    90d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    90dc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    90e0: f84107f9     	ldr	x25, [sp], #0x10
    90e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    90e8: d65f03c0     	ret
    90ec: 528023e1     	mov	w1, #0x11f              ; =287
    90f0: 90000002     	adrp	x2, 0x9000 <___pl_fn_17+0x1064>
    90f4: f9400042     	ldr	x2, [x2]
    90f8: aa1503e0     	mov	x0, x21
    90fc: d63f0040     	blr	x2
    9100: aa1703e0     	mov	x0, x23
    9104: 910183ff     	add	sp, sp, #0x60
    9108: a8c153f3     	ldp	x19, x20, [sp], #0x10
    910c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    9110: a8c163f7     	ldp	x23, x24, [sp], #0x10
    9114: f84107f9     	ldr	x25, [sp], #0x10
    9118: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    911c: d65f03c0     	ret
    9120: 14000028     	b	0x91c0 <___pl_fn_17+0x1224>
    9124: 52802441     	mov	w1, #0x122              ; =290
    9128: 90000003     	adrp	x3, 0x9000 <___pl_fn_17+0x1064>
    912c: f9400063     	ldr	x3, [x3]
    9130: aa1503e0     	mov	x0, x21
    9134: d63f0060     	blr	x3
    9138: aa1703e0     	mov	x0, x23
    913c: 910183ff     	add	sp, sp, #0x60
    9140: a8c153f3     	ldp	x19, x20, [sp], #0x10
    9144: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    9148: a8c163f7     	ldp	x23, x24, [sp], #0x10
    914c: f84107f9     	ldr	x25, [sp], #0x10
    9150: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    9154: d65f03c0     	ret
    9158: 52802421     	mov	w1, #0x121              ; =289
    915c: 90000004     	adrp	x4, 0x9000 <___pl_fn_17+0x1064>
    9160: f9400084     	ldr	x4, [x4]
    9164: aa1503e0     	mov	x0, x21
    9168: d63f0080     	blr	x4
    916c: aa1703e0     	mov	x0, x23
    9170: 910183ff     	add	sp, sp, #0x60
    9174: a8c153f3     	ldp	x19, x20, [sp], #0x10
    9178: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    917c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    9180: f84107f9     	ldr	x25, [sp], #0x10
    9184: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    9188: d65f03c0     	ret
    918c: 52802141     	mov	w1, #0x10a              ; =266
    9190: 90000005     	adrp	x5, 0x9000 <___pl_fn_17+0x1064>
    9194: f94000a5     	ldr	x5, [x5]
    9198: aa1503e0     	mov	x0, x21
    919c: d63f00a0     	blr	x5
    91a0: aa1703e0     	mov	x0, x23
    91a4: 910183ff     	add	sp, sp, #0x60
    91a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    91ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    91b0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    91b4: f84107f9     	ldr	x25, [sp], #0x10
    91b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    91bc: d65f03c0     	ret
    91c0: 52800000     	mov	w0, #0x0                ; =0
    91c4: 910183ff     	add	sp, sp, #0x60
    91c8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    91cc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    91d0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    91d4: f84107f9     	ldr	x25, [sp], #0x10
    91d8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    91dc: d65f03c0     	ret
    91e0: 528020e1     	mov	w1, #0x107              ; =263
    91e4: 90000007     	adrp	x7, 0x9000 <___pl_fn_17+0x1064>
    91e8: f94000e7     	ldr	x7, [x7]
    91ec: aa1503e0     	mov	x0, x21
    91f0: d63f00e0     	blr	x7
    91f4: 52800000     	mov	w0, #0x0                ; =0
    91f8: 910183ff     	add	sp, sp, #0x60
    91fc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    9200: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    9204: a8c163f7     	ldp	x23, x24, [sp], #0x10
    9208: f84107f9     	ldr	x25, [sp], #0x10
    920c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    9210: d65f03c0     	ret
    9214: 528020c1     	mov	w1, #0x106              ; =262
    9218: 90000008     	adrp	x8, 0x9000 <___pl_fn_17+0x1064>
    921c: f9400108     	ldr	x8, [x8]
    9220: aa1503e0     	mov	x0, x21
    9224: d63f0100     	blr	x8
    9228: 52800000     	mov	w0, #0x0                ; =0
    922c: 910183ff     	add	sp, sp, #0x60
    9230: a8c153f3     	ldp	x19, x20, [sp], #0x10
    9234: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    9238: a8c163f7     	ldp	x23, x24, [sp], #0x10
    923c: f84107f9     	ldr	x25, [sp], #0x10
    9240: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    9244: d65f03c0     	ret

0000000000009248 <___pl_fn_18>:
    9248: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    924c: 910003fd     	mov	x29, sp
    9250: f81f0ffc     	str	x28, [sp, #-0x10]!
    9254: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    9258: d100c3ff     	sub	sp, sp, #0x30
    925c: aa0103fc     	mov	x28, x1
    9260: b9401001     	ldr	w1, [x0, #0x10]
    9264: 11000421     	add	w1, w1, #0x1
    9268: b9001001     	str	w1, [x0, #0x10]
    926c: aa1c03e1     	mov	x1, x28
    9270: 34002741     	cbz	w1, 0x9758 <___pl_fn_18+0x510>
    9274: f9400002     	ldr	x2, [x0]
    9278: aa1c03e1     	mov	x1, x28
    927c: aa0003f4     	mov	x20, x0
    9280: 2a0103e0     	mov	w0, w1
    9284: 8b000c41     	add	x1, x2, x0, lsl #3
    9288: aa1c03e7     	mov	x7, x28
    928c: f8675840     	ldr	x0, [x2, w7, uxtw #3]
    9290: d360fc00     	lsr	x0, x0, #32
    9294: 92403c02     	and	x2, x0, #0xffff
    9298: 91002440     	add	x0, x2, #0x9
    929c: f8607820     	ldr	x0, [x1, x0, lsl #3]
    92a0: f100085f     	cmp	x2, #0x2
    92a4: 540000c0     	b.eq	0x92bc <___pl_fn_18+0x74>
    92a8: f9400821     	ldr	x1, [x1, #0x10]
    92ac: 37482581     	tbnz	w1, #0x9, 0x975c <___pl_fn_18+0x514>
    92b0: 14000003     	b	0x92bc <___pl_fn_18+0x74>
    92b4: aa1403e0     	mov	x0, x20
    92b8: f9401800     	ldr	x0, [x0, #0x30]
    92bc: d2800021     	mov	x1, #0x1                ; =1
    92c0: eb010000     	subs	x0, x0, x1
    92c4: 9a9f77e1     	cset	x1, vs
    92c8: 72001c3f     	tst	w1, #0xff
    92cc: 54003ae1     	b.ne	0x9a28 <___pl_fn_18+0x7e0>
    92d0: aa1c03f3     	mov	x19, x28
    92d4: 35000093     	cbnz	w19, 0x92e4 <___pl_fn_18+0x9c>
    92d8: 1400012a     	b	0x9780 <___pl_fn_18+0x538>
    92dc: aa1c03e1     	mov	x1, x28
    92e0: 14000014     	b	0x9330 <___pl_fn_18+0xe8>
    92e4: aa1403e1     	mov	x1, x20
    92e8: aa1303fc     	mov	x28, x19
    92ec: f9400022     	ldr	x2, [x1]
    92f0: aa1c03e1     	mov	x1, x28
    92f4: 2a0103e1     	mov	w1, w1
    92f8: 8b010c41     	add	x1, x2, x1, lsl #3
    92fc: aa1c03e3     	mov	x3, x28
    9300: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    9304: d360fc42     	lsr	x2, x2, #32
    9308: 92403c43     	and	x3, x2, #0xffff
    930c: f100087f     	cmp	x3, #0x2
    9310: 54000080     	b.eq	0x9320 <___pl_fn_18+0xd8>
    9314: f9400823     	ldr	x3, [x1, #0x10]
    9318: 9276f863     	and	x3, x3, #0xfffffffffffffdff
    931c: f9000823     	str	x3, [x1, #0x10]
    9320: 92403c42     	and	x2, x2, #0xffff
    9324: 91002442     	add	x2, x2, #0x9
    9328: f8227820     	str	x0, [x1, x2, lsl #3]
    932c: aa1c03e1     	mov	x1, x28
    9330: aa1c03e1     	mov	x1, x28
    9334: 34002401     	cbz	w1, 0x97b4 <___pl_fn_18+0x56c>
    9338: aa1403e0     	mov	x0, x20
    933c: f9400001     	ldr	x1, [x0]
    9340: aa1c03e0     	mov	x0, x28
    9344: 2a0003e0     	mov	w0, w0
    9348: 8b000c20     	add	x0, x1, x0, lsl #3
    934c: aa1c03e2     	mov	x2, x28
    9350: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    9354: d360fc21     	lsr	x1, x1, #32
    9358: 92403c21     	and	x1, x1, #0xffff
    935c: 91002422     	add	x2, x1, #0x9
    9360: f862780d     	ldr	x13, [x0, x2, lsl #3]
    9364: f100083f     	cmp	x1, #0x2
    9368: 540000c0     	b.eq	0x9380 <___pl_fn_18+0x138>
    936c: f9400800     	ldr	x0, [x0, #0x10]
    9370: 37482220     	tbnz	w0, #0x9, 0x97b4 <___pl_fn_18+0x56c>
    9374: 14000003     	b	0x9380 <___pl_fn_18+0x138>
    9378: aa1403e0     	mov	x0, x20
    937c: f940180d     	ldr	x13, [x0, #0x30]
    9380: b4001a8d     	cbz	x13, 0x96d0 <___pl_fn_18+0x488>
    9384: aa1c03e1     	mov	x1, x28
    9388: 34002281     	cbz	w1, 0x97d8 <___pl_fn_18+0x590>
    938c: aa1403e0     	mov	x0, x20
    9390: f940000b     	ldr	x11, [x0]
    9394: aa1c03e1     	mov	x1, x28
    9398: 2a0103ea     	mov	w10, w1
    939c: 8b0a0d6a     	add	x10, x11, x10, lsl #3
    93a0: f861596b     	ldr	x11, [x11, w1, uxtw #3]
    93a4: d360fd6b     	lsr	x11, x11, #32
    93a8: 92403d6b     	and	x11, x11, #0xffff
    93ac: 9100216c     	add	x12, x11, #0x8
    93b0: f86c7940     	ldr	x0, [x10, x12, lsl #3]
    93b4: f100097f     	cmp	x11, #0x2
    93b8: 540000c0     	b.eq	0x93d0 <___pl_fn_18+0x188>
    93bc: f940094d     	ldr	x13, [x10, #0x10]
    93c0: 374020cd     	tbnz	w13, #0x8, 0x97d8 <___pl_fn_18+0x590>
    93c4: 14000003     	b	0x93d0 <___pl_fn_18+0x188>
    93c8: aa1403e0     	mov	x0, x20
    93cc: f9401800     	ldr	x0, [x0, #0x30]
    93d0: d37ffc01     	lsr	x1, x0, #63
    93d4: 8b010001     	add	x1, x0, x1
    93d8: 927ff821     	and	x1, x1, #0xfffffffffffffffe
    93dc: eb01001f     	cmp	x0, x1
    93e0: 54000d60     	b.eq	0x958c <___pl_fn_18+0x344>
    93e4: aa1c03e1     	mov	x1, x28
    93e8: 340020a1     	cbz	w1, 0x97fc <___pl_fn_18+0x5b4>
    93ec: aa1403e0     	mov	x0, x20
    93f0: f9400001     	ldr	x1, [x0]
    93f4: aa1c03e0     	mov	x0, x28
    93f8: 2a0003e0     	mov	w0, w0
    93fc: 8b000c20     	add	x0, x1, x0, lsl #3
    9400: aa1c03e2     	mov	x2, x28
    9404: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    9408: d360fc21     	lsr	x1, x1, #32
    940c: 92403c21     	and	x1, x1, #0xffff
    9410: 91002022     	add	x2, x1, #0x8
    9414: f862780d     	ldr	x13, [x0, x2, lsl #3]
    9418: f100083f     	cmp	x1, #0x2
    941c: 540000c0     	b.eq	0x9434 <___pl_fn_18+0x1ec>
    9420: f9400800     	ldr	x0, [x0, #0x10]
    9424: 37401ec0     	tbnz	w0, #0x8, 0x97fc <___pl_fn_18+0x5b4>
    9428: 14000003     	b	0x9434 <___pl_fn_18+0x1ec>
    942c: aa1403e0     	mov	x0, x20
    9430: f940180d     	ldr	x13, [x0, #0x30]
    9434: aa1403e0     	mov	x0, x20
    9438: b9401813     	ldr	w19, [x0, #0x18]
    943c: b9401c01     	ldr	w1, [x0, #0x1c]
    9440: 11000660     	add	w0, w19, #0x1
    9444: 6b01001f     	cmp	w0, w1
    9448: 54002468     	b.hi	0x98d4 <___pl_fn_18+0x68c>
    944c: aa1403ea     	mov	x10, x20
    9450: f9401141     	ldr	x1, [x10, #0x20]
    9454: aa1c03eb     	mov	x11, x28
    9458: b833582b     	str	w11, [x1, w19, uxtw #2]
    945c: aa1403ee     	mov	x14, x20
    9460: b90019c0     	str	w0, [x14, #0x18]
    9464: aa1403e0     	mov	x0, x20
    9468: b9401000     	ldr	w0, [x0, #0x10]
    946c: aa1403e1     	mov	x1, x20
    9470: b9401421     	ldr	w1, [x1, #0x14]
    9474: 6b01001f     	cmp	w0, w1
    9478: 54002182     	b.hs	0x98a8 <___pl_fn_18+0x660>
    947c: d37ffda0     	lsr	x0, x13, #63
    9480: 8b0001a0     	add	x0, x13, x0
    9484: 9341fc01     	asr	x1, x0, #1
    9488: d29a0102     	mov	x2, #0xd008             ; =53256
    948c: aa1403e0     	mov	x0, x20
    9490: 94000000     	bl	0x9490 <___pl_fn_18+0x248>
    9494: aa1403e1     	mov	x1, x20
    9498: b9402c21     	ldr	w1, [x1, #0x2c]
    949c: 350028e1     	cbnz	w1, 0x99b8 <___pl_fn_18+0x770>
    94a0: aa1403e1     	mov	x1, x20
    94a4: b9001833     	str	w19, [x1, #0x18]
    94a8: aa1c03e1     	mov	x1, x28
    94ac: 35000081     	cbnz	w1, 0x94bc <___pl_fn_18+0x274>
    94b0: 140000dc     	b	0x9820 <___pl_fn_18+0x5d8>
    94b4: aa1403e0     	mov	x0, x20
    94b8: 14000013     	b	0x9504 <___pl_fn_18+0x2bc>
    94bc: aa1403e1     	mov	x1, x20
    94c0: f9400022     	ldr	x2, [x1]
    94c4: aa1c03e1     	mov	x1, x28
    94c8: 2a0103e1     	mov	w1, w1
    94cc: 8b010c41     	add	x1, x2, x1, lsl #3
    94d0: aa1c03e3     	mov	x3, x28
    94d4: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    94d8: d360fc42     	lsr	x2, x2, #32
    94dc: 92403c43     	and	x3, x2, #0xffff
    94e0: f100087f     	cmp	x3, #0x2
    94e4: 54000080     	b.eq	0x94f4 <___pl_fn_18+0x2ac>
    94e8: f9400823     	ldr	x3, [x1, #0x10]
    94ec: 9277f863     	and	x3, x3, #0xfffffffffffffeff
    94f0: f9000823     	str	x3, [x1, #0x10]
    94f4: 92403c42     	and	x2, x2, #0xffff
    94f8: 91002042     	add	x2, x2, #0x8
    94fc: f8227820     	str	x0, [x1, x2, lsl #3]
    9500: aa1403e0     	mov	x0, x20
    9504: aa1403e0     	mov	x0, x20
    9508: b9401813     	ldr	w19, [x0, #0x18]
    950c: b9401c01     	ldr	w1, [x0, #0x1c]
    9510: 11000660     	add	w0, w19, #0x1
    9514: 6b01001f     	cmp	w0, w1
    9518: 54001b28     	b.hi	0x987c <___pl_fn_18+0x634>
    951c: aa1403e5     	mov	x5, x20
    9520: f94010a1     	ldr	x1, [x5, #0x20]
    9524: aa1c03e2     	mov	x2, x28
    9528: b8335822     	str	w2, [x1, w19, uxtw #2]
    952c: aa1403e8     	mov	x8, x20
    9530: b9001900     	str	w0, [x8, #0x18]
    9534: aa1403e0     	mov	x0, x20
    9538: b9401001     	ldr	w1, [x0, #0x10]
    953c: b9401402     	ldr	w2, [x0, #0x14]
    9540: 6b02003f     	cmp	w1, w2
    9544: 54001862     	b.hs	0x9850 <___pl_fn_18+0x608>
    9548: d28000c2     	mov	x2, #0x6                ; =6
    954c: aa1c03e1     	mov	x1, x28
    9550: aa1403e0     	mov	x0, x20
    9554: 94000000     	bl	0x9554 <___pl_fn_18+0x30c>
    9558: aa1403e1     	mov	x1, x20
    955c: b9402c23     	ldr	w3, [x1, #0x2c]
    9560: 350022c3     	cbnz	w3, 0x99b8 <___pl_fn_18+0x770>
    9564: aa1403e1     	mov	x1, x20
    9568: b9001833     	str	w19, [x1, #0x18]
    956c: b9401026     	ldr	w6, [x1, #0x10]
    9570: 510004c6     	sub	w6, w6, #0x1
    9574: b9001026     	str	w6, [x1, #0x10]
    9578: 9100c3ff     	add	sp, sp, #0x30
    957c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    9580: f84107fc     	ldr	x28, [sp], #0x10
    9584: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    9588: d65f03c0     	ret
    958c: aa1c03e1     	mov	x1, x28
    9590: 34001b81     	cbz	w1, 0x9900 <___pl_fn_18+0x6b8>
    9594: aa1403e0     	mov	x0, x20
    9598: f940000f     	ldr	x15, [x0]
    959c: aa1c03e1     	mov	x1, x28
    95a0: 2a0103ee     	mov	w14, w1
    95a4: 8b0e0dee     	add	x14, x15, x14, lsl #3
    95a8: f86159ef     	ldr	x15, [x15, w1, uxtw #3]
    95ac: d360fdef     	lsr	x15, x15, #32
    95b0: 92403def     	and	x15, x15, #0xffff
    95b4: 910021e0     	add	x0, x15, #0x8
    95b8: f86079c7     	ldr	x7, [x14, x0, lsl #3]
    95bc: f10009ff     	cmp	x15, #0x2
    95c0: 540000c0     	b.eq	0x95d8 <___pl_fn_18+0x390>
    95c4: f94009c0     	ldr	x0, [x14, #0x10]
    95c8: 374019c0     	tbnz	w0, #0x8, 0x9900 <___pl_fn_18+0x6b8>
    95cc: 14000003     	b	0x95d8 <___pl_fn_18+0x390>
    95d0: aa1403e0     	mov	x0, x20
    95d4: f9401807     	ldr	x7, [x0, #0x30]
    95d8: aa1c03e1     	mov	x1, x28
    95dc: 35000081     	cbnz	w1, 0x95ec <___pl_fn_18+0x3a4>
    95e0: 140000d1     	b	0x9924 <___pl_fn_18+0x6dc>
    95e4: aa1403e0     	mov	x0, x20
    95e8: 14000016     	b	0x9640 <___pl_fn_18+0x3f8>
    95ec: aa1403e0     	mov	x0, x20
    95f0: f9400001     	ldr	x1, [x0]
    95f4: aa1c03e0     	mov	x0, x28
    95f8: 2a0003e0     	mov	w0, w0
    95fc: 8b000c20     	add	x0, x1, x0, lsl #3
    9600: aa1c03e2     	mov	x2, x28
    9604: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    9608: d360fc21     	lsr	x1, x1, #32
    960c: 92403c22     	and	x2, x1, #0xffff
    9610: f100085f     	cmp	x2, #0x2
    9614: 54000080     	b.eq	0x9624 <___pl_fn_18+0x3dc>
    9618: f9400802     	ldr	x2, [x0, #0x10]
    961c: 9277f842     	and	x2, x2, #0xfffffffffffffeff
    9620: f9000802     	str	x2, [x0, #0x10]
    9624: d37ffce2     	lsr	x2, x7, #63
    9628: 8b0200e2     	add	x2, x7, x2
    962c: 9341fc42     	asr	x2, x2, #1
    9630: 92403c21     	and	x1, x1, #0xffff
    9634: 91002021     	add	x1, x1, #0x8
    9638: f8217802     	str	x2, [x0, x1, lsl #3]
    963c: aa1403e0     	mov	x0, x20
    9640: aa1403e0     	mov	x0, x20
    9644: b9401813     	ldr	w19, [x0, #0x18]
    9648: b9401c01     	ldr	w1, [x0, #0x1c]
    964c: 11000660     	add	w0, w19, #0x1
    9650: 6b01001f     	cmp	w0, w1
    9654: 540019c8     	b.hi	0x998c <___pl_fn_18+0x744>
    9658: aa1403e1     	mov	x1, x20
    965c: f9401021     	ldr	x1, [x1, #0x20]
    9660: aa1c03e2     	mov	x2, x28
    9664: b8335822     	str	w2, [x1, w19, uxtw #2]
    9668: aa1403e3     	mov	x3, x20
    966c: b9001860     	str	w0, [x3, #0x18]
    9670: aa1403e0     	mov	x0, x20
    9674: b9401000     	ldr	w0, [x0, #0x10]
    9678: aa1403e7     	mov	x7, x20
    967c: b94014e1     	ldr	w1, [x7, #0x14]
    9680: 6b01001f     	cmp	w0, w1
    9684: 540016e2     	b.hs	0x9960 <___pl_fn_18+0x718>
    9688: d28000a2     	mov	x2, #0x5                ; =5
    968c: aa1c03e1     	mov	x1, x28
    9690: aa1403e0     	mov	x0, x20
    9694: 94000000     	bl	0x9694 <___pl_fn_18+0x44c>
    9698: aa1403ed     	mov	x13, x20
    969c: b9402da1     	ldr	w1, [x13, #0x2c]
    96a0: 350018c1     	cbnz	w1, 0x99b8 <___pl_fn_18+0x770>
    96a4: aa1403e1     	mov	x1, x20
    96a8: b9001833     	str	w19, [x1, #0x18]
    96ac: b9401021     	ldr	w1, [x1, #0x10]
    96b0: 51000421     	sub	w1, w1, #0x1
    96b4: aa1403e2     	mov	x2, x20
    96b8: b9001041     	str	w1, [x2, #0x10]
    96bc: 9100c3ff     	add	sp, sp, #0x30
    96c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    96c4: f84107fc     	ldr	x28, [sp], #0x10
    96c8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    96cc: d65f03c0     	ret
    96d0: aa1403e0     	mov	x0, x20
    96d4: b9401813     	ldr	w19, [x0, #0x18]
    96d8: b9401c01     	ldr	w1, [x0, #0x1c]
    96dc: 11000660     	add	w0, w19, #0x1
    96e0: 6b01001f     	cmp	w0, w1
    96e4: 540018c8     	b.hi	0x99fc <___pl_fn_18+0x7b4>
    96e8: aa1403e1     	mov	x1, x20
    96ec: f9401021     	ldr	x1, [x1, #0x20]
    96f0: aa1c03e2     	mov	x2, x28
    96f4: b8335822     	str	w2, [x1, w19, uxtw #2]
    96f8: aa1403e1     	mov	x1, x20
    96fc: b9001820     	str	w0, [x1, #0x18]
    9700: aa1403e0     	mov	x0, x20
    9704: b9401000     	ldr	w0, [x0, #0x10]
    9708: b9401421     	ldr	w1, [x1, #0x14]
    970c: 6b01001f     	cmp	w0, w1
    9710: 54001602     	b.hs	0x99d0 <___pl_fn_18+0x788>
    9714: aa1c03e1     	mov	x1, x28
    9718: aa1403e0     	mov	x0, x20
    971c: 94000000     	bl	0x971c <___pl_fn_18+0x4d4>
    9720: aa1403e1     	mov	x1, x20
    9724: b9402c21     	ldr	w1, [x1, #0x2c]
    9728: 35001481     	cbnz	w1, 0x99b8 <___pl_fn_18+0x770>
    972c: aa1403e1     	mov	x1, x20
    9730: b9001833     	str	w19, [x1, #0x18]
    9734: b9401021     	ldr	w1, [x1, #0x10]
    9738: 51000421     	sub	w1, w1, #0x1
    973c: aa1403e2     	mov	x2, x20
    9740: b9001041     	str	w1, [x2, #0x10]
    9744: 9100c3ff     	add	sp, sp, #0x30
    9748: a8c153f3     	ldp	x19, x20, [sp], #0x10
    974c: f84107fc     	ldr	x28, [sp], #0x10
    9750: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    9754: d65f03c0     	ret
    9758: aa0003f4     	mov	x20, x0
    975c: 52802461     	mov	w1, #0x123              ; =291
    9760: 52800123     	mov	w3, #0x9                ; =9
    9764: 90000004     	adrp	x4, 0x9000 <___pl_fn_17+0x1064>
    9768: f9400084     	ldr	x4, [x4]
    976c: aa1403e0     	mov	x0, x20
    9770: aa1c03e2     	mov	x2, x28
    9774: d63f0080     	blr	x4
    9778: 34ffd9e0     	cbz	w0, 0x92b4 <___pl_fn_18+0x6c>
    977c: 1400008f     	b	0x99b8 <___pl_fn_18+0x770>
    9780: d2800121     	mov	x1, #0x9                ; =9
    9784: 910003e3     	mov	x3, sp
    9788: f80003e1     	stur	x1, [sp]
    978c: f80083e0     	stur	x0, [sp, #0x8]
    9790: 528024a1     	mov	w1, #0x125              ; =293
    9794: 90000004     	adrp	x4, 0x9000 <___pl_fn_17+0x1064>
    9798: f9400084     	ldr	x4, [x4]
    979c: aa1403e0     	mov	x0, x20
    97a0: aa1303e2     	mov	x2, x19
    97a4: d63f0080     	blr	x4
    97a8: aa1303fc     	mov	x28, x19
    97ac: 34ffd980     	cbz	w0, 0x92dc <___pl_fn_18+0x94>
    97b0: 14000082     	b	0x99b8 <___pl_fn_18+0x770>
    97b4: 528024c1     	mov	w1, #0x126              ; =294
    97b8: 52800123     	mov	w3, #0x9                ; =9
    97bc: 90000004     	adrp	x4, 0x9000 <___pl_fn_17+0x1064>
    97c0: f9400084     	ldr	x4, [x4]
    97c4: aa1403e0     	mov	x0, x20
    97c8: aa1c03e2     	mov	x2, x28
    97cc: d63f0080     	blr	x4
    97d0: 34ffdd40     	cbz	w0, 0x9378 <___pl_fn_18+0x130>
    97d4: 14000079     	b	0x99b8 <___pl_fn_18+0x770>
    97d8: 528024e1     	mov	w1, #0x127              ; =295
    97dc: 52800103     	mov	w3, #0x8                ; =8
    97e0: 90000004     	adrp	x4, 0x9000 <___pl_fn_17+0x1064>
    97e4: f9400084     	ldr	x4, [x4]
    97e8: aa1403e0     	mov	x0, x20
    97ec: aa1c03e2     	mov	x2, x28
    97f0: d63f0080     	blr	x4
    97f4: 34ffdea0     	cbz	w0, 0x93c8 <___pl_fn_18+0x180>
    97f8: 14000070     	b	0x99b8 <___pl_fn_18+0x770>
    97fc: 52802521     	mov	w1, #0x129              ; =297
    9800: 52800103     	mov	w3, #0x8                ; =8
    9804: 90000004     	adrp	x4, 0x9000 <___pl_fn_17+0x1064>
    9808: f9400084     	ldr	x4, [x4]
    980c: aa1403e0     	mov	x0, x20
    9810: aa1c03e2     	mov	x2, x28
    9814: d63f0080     	blr	x4
    9818: 34ffe0a0     	cbz	w0, 0x942c <___pl_fn_18+0x1e4>
    981c: 14000067     	b	0x99b8 <___pl_fn_18+0x770>
    9820: d2800101     	mov	x1, #0x8                ; =8
    9824: 910043e3     	add	x3, sp, #0x10
    9828: f80103e1     	stur	x1, [sp, #0x10]
    982c: f80183e0     	stur	x0, [sp, #0x18]
    9830: 528025c1     	mov	w1, #0x12e              ; =302
    9834: 90000004     	adrp	x4, 0x9000 <___pl_fn_17+0x1064>
    9838: f9400084     	ldr	x4, [x4]
    983c: aa1403e0     	mov	x0, x20
    9840: aa1c03e2     	mov	x2, x28
    9844: d63f0080     	blr	x4
    9848: 34ffe360     	cbz	w0, 0x94b4 <___pl_fn_18+0x26c>
    984c: 1400005b     	b	0x99b8 <___pl_fn_18+0x770>
    9850: 52802601     	mov	w1, #0x130              ; =304
    9854: 90000008     	adrp	x8, 0x9000 <___pl_fn_17+0x1064>
    9858: f9400108     	ldr	x8, [x8]
    985c: aa1403e0     	mov	x0, x20
    9860: d63f0100     	blr	x8
    9864: 52800000     	mov	w0, #0x0                ; =0
    9868: 9100c3ff     	add	sp, sp, #0x30
    986c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    9870: f84107fc     	ldr	x28, [sp], #0x10
    9874: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    9878: d65f03c0     	ret
    987c: 528025e1     	mov	w1, #0x12f              ; =303
    9880: 90000009     	adrp	x9, 0x9000 <___pl_fn_17+0x1064>
    9884: f9400129     	ldr	x9, [x9]
    9888: aa1403e0     	mov	x0, x20
    988c: d63f0120     	blr	x9
    9890: 52800000     	mov	w0, #0x0                ; =0
    9894: 9100c3ff     	add	sp, sp, #0x30
    9898: a8c153f3     	ldp	x19, x20, [sp], #0x10
    989c: f84107fc     	ldr	x28, [sp], #0x10
    98a0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    98a4: d65f03c0     	ret
    98a8: 528025a1     	mov	w1, #0x12d              ; =301
    98ac: 9000000a     	adrp	x10, 0x9000 <___pl_fn_17+0x1064>
    98b0: f940014a     	ldr	x10, [x10]
    98b4: aa1403e0     	mov	x0, x20
    98b8: d63f0140     	blr	x10
    98bc: 52800000     	mov	w0, #0x0                ; =0
    98c0: 9100c3ff     	add	sp, sp, #0x30
    98c4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    98c8: f84107fc     	ldr	x28, [sp], #0x10
    98cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    98d0: d65f03c0     	ret
    98d4: 52802581     	mov	w1, #0x12c              ; =300
    98d8: 9000000b     	adrp	x11, 0x9000 <___pl_fn_17+0x1064>
    98dc: f940016b     	ldr	x11, [x11]
    98e0: aa1403e0     	mov	x0, x20
    98e4: d63f0160     	blr	x11
    98e8: 52800000     	mov	w0, #0x0                ; =0
    98ec: 9100c3ff     	add	sp, sp, #0x30
    98f0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    98f4: f84107fc     	ldr	x28, [sp], #0x10
    98f8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    98fc: d65f03c0     	ret
    9900: 52802621     	mov	w1, #0x131              ; =305
    9904: 52800103     	mov	w3, #0x8                ; =8
    9908: 90000004     	adrp	x4, 0x9000 <___pl_fn_17+0x1064>
    990c: f9400084     	ldr	x4, [x4]
    9910: aa1403e0     	mov	x0, x20
    9914: aa1c03e2     	mov	x2, x28
    9918: d63f0080     	blr	x4
    991c: 34ffe5a0     	cbz	w0, 0x95d0 <___pl_fn_18+0x388>
    9920: 14000026     	b	0x99b8 <___pl_fn_18+0x770>
    9924: d2800100     	mov	x0, #0x8                ; =8
    9928: 910083e3     	add	x3, sp, #0x20
    992c: f80203e0     	stur	x0, [sp, #0x20]
    9930: d37ffce0     	lsr	x0, x7, #63
    9934: 8b0000e0     	add	x0, x7, x0
    9938: 9341fc00     	asr	x0, x0, #1
    993c: f80283e0     	stur	x0, [sp, #0x28]
    9940: 52802681     	mov	w1, #0x134              ; =308
    9944: 90000004     	adrp	x4, 0x9000 <___pl_fn_17+0x1064>
    9948: f9400084     	ldr	x4, [x4]
    994c: aa1403e0     	mov	x0, x20
    9950: aa1c03e2     	mov	x2, x28
    9954: d63f0080     	blr	x4
    9958: 34ffe460     	cbz	w0, 0x95e4 <___pl_fn_18+0x39c>
    995c: 14000017     	b	0x99b8 <___pl_fn_18+0x770>
    9960: 528026c1     	mov	w1, #0x136              ; =310
    9964: 90000002     	adrp	x2, 0x9000 <___pl_fn_17+0x1064>
    9968: f9400042     	ldr	x2, [x2]
    996c: aa1403e0     	mov	x0, x20
    9970: d63f0040     	blr	x2
    9974: 52800000     	mov	w0, #0x0                ; =0
    9978: 9100c3ff     	add	sp, sp, #0x30
    997c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    9980: f84107fc     	ldr	x28, [sp], #0x10
    9984: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    9988: d65f03c0     	ret
    998c: 528026a1     	mov	w1, #0x135              ; =309
    9990: 90000002     	adrp	x2, 0x9000 <___pl_fn_17+0x1064>
    9994: f9400042     	ldr	x2, [x2]
    9998: aa1403e0     	mov	x0, x20
    999c: d63f0040     	blr	x2
    99a0: 52800000     	mov	w0, #0x0                ; =0
    99a4: 9100c3ff     	add	sp, sp, #0x30
    99a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    99ac: f84107fc     	ldr	x28, [sp], #0x10
    99b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    99b4: d65f03c0     	ret
    99b8: 52800000     	mov	w0, #0x0                ; =0
    99bc: 9100c3ff     	add	sp, sp, #0x30
    99c0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    99c4: f84107fc     	ldr	x28, [sp], #0x10
    99c8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    99cc: d65f03c0     	ret
    99d0: 52802701     	mov	w1, #0x138              ; =312
    99d4: 90000002     	adrp	x2, 0x9000 <___pl_fn_17+0x1064>
    99d8: f9400042     	ldr	x2, [x2]
    99dc: aa1403e0     	mov	x0, x20
    99e0: d63f0040     	blr	x2
    99e4: 52800000     	mov	w0, #0x0                ; =0
    99e8: 9100c3ff     	add	sp, sp, #0x30
    99ec: a8c153f3     	ldp	x19, x20, [sp], #0x10
    99f0: f84107fc     	ldr	x28, [sp], #0x10
    99f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    99f8: d65f03c0     	ret
    99fc: 528026e1     	mov	w1, #0x137              ; =311
    9a00: 90000002     	adrp	x2, 0x9000 <___pl_fn_17+0x1064>
    9a04: f9400042     	ldr	x2, [x2]
    9a08: aa1403e0     	mov	x0, x20
    9a0c: d63f0040     	blr	x2
    9a10: 52800000     	mov	w0, #0x0                ; =0
    9a14: 9100c3ff     	add	sp, sp, #0x30
    9a18: a8c153f3     	ldp	x19, x20, [sp], #0x10
    9a1c: f84107fc     	ldr	x28, [sp], #0x10
    9a20: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    9a24: d65f03c0     	ret
    9a28: 52802481     	mov	w1, #0x124              ; =292
    9a2c: 90000003     	adrp	x3, 0x9000 <___pl_fn_17+0x1064>
    9a30: f9400063     	ldr	x3, [x3]
    9a34: aa1403e0     	mov	x0, x20
    9a38: d63f0060     	blr	x3
    9a3c: 52800000     	mov	w0, #0x0                ; =0
    9a40: 9100c3ff     	add	sp, sp, #0x30
    9a44: a8c153f3     	ldp	x19, x20, [sp], #0x10
    9a48: f84107fc     	ldr	x28, [sp], #0x10
    9a4c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    9a50: d65f03c0     	ret

0000000000009a54 <___pl_fn_19>:
    9a54: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    9a58: 910003fd     	mov	x29, sp
    9a5c: f81f0ff9     	str	x25, [sp, #-0x10]!
    9a60: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
    9a64: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    9a68: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    9a6c: d10183ff     	sub	sp, sp, #0x60
    9a70: aa0103f8     	mov	x24, x1
    9a74: aa0203f9     	mov	x25, x2
    9a78: b9401001     	ldr	w1, [x0, #0x10]
    9a7c: 11000421     	add	w1, w1, #0x1
    9a80: b9001001     	str	w1, [x0, #0x10]
    9a84: aa1803e1     	mov	x1, x24
    9a88: 34003381     	cbz	w1, 0xa0f8 <___pl_fn_19+0x6a4>
    9a8c: f9400001     	ldr	x1, [x0]
    9a90: aa0003f7     	mov	x23, x0
    9a94: aa1803e0     	mov	x0, x24
    9a98: 2a0003e0     	mov	w0, w0
    9a9c: 8b000c20     	add	x0, x1, x0, lsl #3
    9aa0: aa1803e2     	mov	x2, x24
    9aa4: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    9aa8: d360fc21     	lsr	x1, x1, #32
    9aac: 92403c21     	and	x1, x1, #0xffff
    9ab0: 91001c21     	add	x1, x1, #0x7
    9ab4: d37df021     	lsl	x1, x1, #3
    9ab8: b8616802     	ldr	w2, [x0, x1]
    9abc: 35000082     	cbnz	w2, 0x9acc <___pl_fn_19+0x78>
    9ac0: 1400018f     	b	0xa0fc <___pl_fn_19+0x6a8>
    9ac4: aa1703e0     	mov	x0, x23
    9ac8: f9401802     	ldr	x2, [x0, #0x30]
    9acc: 340032a2     	cbz	w2, 0xa120 <___pl_fn_19+0x6cc>
    9ad0: aa1703e0     	mov	x0, x23
    9ad4: f9400001     	ldr	x1, [x0]
    9ad8: 2a0203e0     	mov	w0, w2
    9adc: 8b000c20     	add	x0, x1, x0, lsl #3
    9ae0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    9ae4: d360fc21     	lsr	x1, x1, #32
    9ae8: 92403c21     	and	x1, x1, #0xffff
    9aec: 91000821     	add	x1, x1, #0x2
    9af0: d37df021     	lsl	x1, x1, #3
    9af4: b8616800     	ldr	w0, [x0, x1]
    9af8: 350000c0     	cbnz	w0, 0x9b10 <___pl_fn_19+0xbc>
    9afc: 14000189     	b	0xa120 <___pl_fn_19+0x6cc>
    9b00: aa1703e0     	mov	x0, x23
    9b04: f9401800     	ldr	x0, [x0, #0x30]
    9b08: aa1903e2     	mov	x2, x25
    9b0c: 14000002     	b	0x9b14 <___pl_fn_19+0xc0>
    9b10: aa1903e2     	mov	x2, x25
    9b14: 6b00005f     	cmp	w2, w0
    9b18: aa0203f9     	mov	x25, x2
    9b1c: 54002a80     	b.eq	0xa06c <___pl_fn_19+0x618>
    9b20: aa1803f3     	mov	x19, x24
    9b24: 340030f3     	cbz	w19, 0xa140 <___pl_fn_19+0x6ec>
    9b28: aa1703e0     	mov	x0, x23
    9b2c: f9400008     	ldr	x8, [x0]
    9b30: 2a1303e7     	mov	w7, w19
    9b34: 8b070d07     	add	x7, x8, x7, lsl #3
    9b38: f8735908     	ldr	x8, [x8, w19, uxtw #3]
    9b3c: d360fd08     	lsr	x8, x8, #32
    9b40: 92403d08     	and	x8, x8, #0xffff
    9b44: 91002109     	add	x9, x8, #0x8
    9b48: f86978e3     	ldr	x3, [x7, x9, lsl #3]
    9b4c: f100091f     	cmp	x8, #0x2
    9b50: 54000061     	b.ne	0x9b5c <___pl_fn_19+0x108>
    9b54: aa1303f8     	mov	x24, x19
    9b58: 14000007     	b	0x9b74 <___pl_fn_19+0x120>
    9b5c: f94008ea     	ldr	x10, [x7, #0x10]
    9b60: 37402f0a     	tbnz	w10, #0x8, 0xa140 <___pl_fn_19+0x6ec>
    9b64: aa1303f8     	mov	x24, x19
    9b68: 14000003     	b	0x9b74 <___pl_fn_19+0x120>
    9b6c: aa1703e0     	mov	x0, x23
    9b70: f9401803     	ldr	x3, [x0, #0x30]
    9b74: d2800073     	mov	x19, #0x3               ; =3
    9b78: f1000c7f     	cmp	x3, #0x3
    9b7c: 540002c0     	b.eq	0x9bd4 <___pl_fn_19+0x180>
    9b80: aa1803e1     	mov	x1, x24
    9b84: 34002f21     	cbz	w1, 0xa168 <___pl_fn_19+0x714>
    9b88: aa1703e0     	mov	x0, x23
    9b8c: f9400001     	ldr	x1, [x0]
    9b90: aa1803e0     	mov	x0, x24
    9b94: 2a0003e0     	mov	w0, w0
    9b98: 8b000c20     	add	x0, x1, x0, lsl #3
    9b9c: aa1803e2     	mov	x2, x24
    9ba0: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    9ba4: d360fc21     	lsr	x1, x1, #32
    9ba8: 92403c22     	and	x2, x1, #0xffff
    9bac: f100085f     	cmp	x2, #0x2
    9bb0: 54000080     	b.eq	0x9bc0 <___pl_fn_19+0x16c>
    9bb4: f9400802     	ldr	x2, [x0, #0x10]
    9bb8: 9277f842     	and	x2, x2, #0xfffffffffffffeff
    9bbc: f9000802     	str	x2, [x0, #0x10]
    9bc0: 92403c21     	and	x1, x1, #0xffff
    9bc4: 91002021     	add	x1, x1, #0x8
    9bc8: f8217813     	str	x19, [x0, x1, lsl #3]
    9bcc: aa1803e1     	mov	x1, x24
    9bd0: 14000016     	b	0x9c28 <___pl_fn_19+0x1d4>
    9bd4: aa1803e1     	mov	x1, x24
    9bd8: 34002e01     	cbz	w1, 0xa198 <___pl_fn_19+0x744>
    9bdc: aa1703e0     	mov	x0, x23
    9be0: f9400001     	ldr	x1, [x0]
    9be4: aa1803e0     	mov	x0, x24
    9be8: 2a0003e0     	mov	w0, w0
    9bec: 8b000c20     	add	x0, x1, x0, lsl #3
    9bf0: aa1803e2     	mov	x2, x24
    9bf4: f8625821     	ldr	x1, [x1, w2, uxtw #3]
    9bf8: d360fc21     	lsr	x1, x1, #32
    9bfc: 92403c22     	and	x2, x1, #0xffff
    9c00: f100085f     	cmp	x2, #0x2
    9c04: 54000080     	b.eq	0x9c14 <___pl_fn_19+0x1c0>
    9c08: f9400802     	ldr	x2, [x0, #0x10]
    9c0c: 9277f842     	and	x2, x2, #0xfffffffffffffeff
    9c10: f9000802     	str	x2, [x0, #0x10]
    9c14: d2800082     	mov	x2, #0x4                ; =4
    9c18: 92403c21     	and	x1, x1, #0xffff
    9c1c: 91002021     	add	x1, x1, #0x8
    9c20: f8217802     	str	x2, [x0, x1, lsl #3]
    9c24: aa1803e1     	mov	x1, x24
    9c28: aa1803e1     	mov	x1, x24
    9c2c: 34002d01     	cbz	w1, 0xa1cc <___pl_fn_19+0x778>
    9c30: aa1703e0     	mov	x0, x23
    9c34: f9400000     	ldr	x0, [x0]
    9c38: aa1803e1     	mov	x1, x24
    9c3c: 2a0103e1     	mov	w1, w1
    9c40: 8b010c01     	add	x1, x0, x1, lsl #3
    9c44: aa1803e2     	mov	x2, x24
    9c48: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    9c4c: d360fc00     	lsr	x0, x0, #32
    9c50: 92403c02     	and	x2, x0, #0xffff
    9c54: 91002040     	add	x0, x2, #0x8
    9c58: f8607820     	ldr	x0, [x1, x0, lsl #3]
    9c5c: f100085f     	cmp	x2, #0x2
    9c60: 54000100     	b.eq	0x9c80 <___pl_fn_19+0x22c>
    9c64: f9400821     	ldr	x1, [x1, #0x10]
    9c68: 37402b21     	tbnz	w1, #0x8, 0xa1cc <___pl_fn_19+0x778>
    9c6c: 14000005     	b	0x9c80 <___pl_fn_19+0x22c>
    9c70: aa1703e0     	mov	x0, x23
    9c74: f9401800     	ldr	x0, [x0, #0x30]
    9c78: aa1903e2     	mov	x2, x25
    9c7c: 14000002     	b	0x9c84 <___pl_fn_19+0x230>
    9c80: aa1903e2     	mov	x2, x25
    9c84: 35000082     	cbnz	w2, 0x9c94 <___pl_fn_19+0x240>
    9c88: 1400015a     	b	0xa1f0 <___pl_fn_19+0x79c>
    9c8c: aa1903e2     	mov	x2, x25
    9c90: 14000013     	b	0x9cdc <___pl_fn_19+0x288>
    9c94: aa1703e1     	mov	x1, x23
    9c98: f9400023     	ldr	x3, [x1]
    9c9c: aa1903e2     	mov	x2, x25
    9ca0: 2a0203e2     	mov	w2, w2
    9ca4: 8b020c62     	add	x2, x3, x2, lsl #3
    9ca8: aa1903eb     	mov	x11, x25
    9cac: f86b5863     	ldr	x3, [x3, w11, uxtw #3]
    9cb0: d360fc63     	lsr	x3, x3, #32
    9cb4: 92403c64     	and	x4, x3, #0xffff
    9cb8: f100089f     	cmp	x4, #0x2
    9cbc: 54000080     	b.eq	0x9ccc <___pl_fn_19+0x278>
    9cc0: f9400845     	ldr	x5, [x2, #0x10]
    9cc4: 927ef8a5     	and	x5, x5, #0xfffffffffffffffd
    9cc8: f9000845     	str	x5, [x2, #0x10]
    9ccc: 92403c67     	and	x7, x3, #0xffff
    9cd0: 910004e7     	add	x7, x7, #0x1
    9cd4: f8277840     	str	x0, [x2, x7, lsl #3]
    9cd8: aa1903e2     	mov	x2, x25
    9cdc: aa1903e2     	mov	x2, x25
    9ce0: 34002a02     	cbz	w2, 0xa220 <___pl_fn_19+0x7cc>
    9ce4: aa1703e0     	mov	x0, x23
    9ce8: f9400000     	ldr	x0, [x0]
    9cec: aa1903e2     	mov	x2, x25
    9cf0: 2a0203ef     	mov	w15, w2
    9cf4: 8b0f0c0f     	add	x15, x0, x15, lsl #3
    9cf8: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    9cfc: d360fc00     	lsr	x0, x0, #32
    9d00: 92403c01     	and	x1, x0, #0xffff
    9d04: f100083f     	cmp	x1, #0x2
    9d08: 54000080     	b.eq	0x9d18 <___pl_fn_19+0x2c4>
    9d0c: f94009e1     	ldr	x1, [x15, #0x10]
    9d10: 927cf821     	and	x1, x1, #0xfffffffffffffff7
    9d14: f90009e1     	str	x1, [x15, #0x10]
    9d18: d2800001     	mov	x1, #0x0                ; =0
    9d1c: 92403c00     	and	x0, x0, #0xffff
    9d20: 91000c00     	add	x0, x0, #0x3
    9d24: f82079e1     	str	x1, [x15, x0, lsl #3]
    9d28: d2800013     	mov	x19, #0x0               ; =0
    9d2c: 52800034     	mov	w20, #0x1               ; =1
    9d30: f1000e7f     	cmp	x19, #0x3
    9d34: 9a9fc7e0     	cset	x0, le
    9d38: 72001c1f     	tst	w0, #0xff
    9d3c: 54000581     	b.ne	0x9dec <___pl_fn_19+0x398>
    9d40: aa1703e0     	mov	x0, x23
    9d44: b9401813     	ldr	w19, [x0, #0x18]
    9d48: b9401c00     	ldr	w0, [x0, #0x1c]
    9d4c: 11000a61     	add	w1, w19, #0x2
    9d50: 6b00003f     	cmp	w1, w0
    9d54: 54002988     	b.hi	0xa284 <___pl_fn_19+0x830>
    9d58: aa1703e0     	mov	x0, x23
    9d5c: f9401000     	ldr	x0, [x0, #0x20]
    9d60: 2a1303e1     	mov	w1, w19
    9d64: 8b010801     	add	x1, x0, x1, lsl #2
    9d68: aa1803e2     	mov	x2, x24
    9d6c: b8335802     	str	w2, [x0, w19, uxtw #2]
    9d70: aa1903e2     	mov	x2, x25
    9d74: b9000422     	str	w2, [x1, #0x4]
    9d78: 11000a60     	add	w0, w19, #0x2
    9d7c: aa1703e1     	mov	x1, x23
    9d80: b9001820     	str	w0, [x1, #0x18]
    9d84: aa1703e0     	mov	x0, x23
    9d88: b9401000     	ldr	w0, [x0, #0x10]
    9d8c: b9401421     	ldr	w1, [x1, #0x14]
    9d90: 6b01001f     	cmp	w0, w1
    9d94: 540025e2     	b.hs	0xa250 <___pl_fn_19+0x7fc>
    9d98: aa1803e1     	mov	x1, x24
    9d9c: aa1903e2     	mov	x2, x25
    9da0: aa1703e0     	mov	x0, x23
    9da4: 94000000     	bl	0x9da4 <___pl_fn_19+0x350>
    9da8: aa1703e3     	mov	x3, x23
    9dac: b9402c61     	ldr	w1, [x3, #0x2c]
    9db0: 35003a01     	cbnz	w1, 0xa4f0 <___pl_fn_19+0xa9c>
    9db4: aa1703e7     	mov	x7, x23
    9db8: b90018f3     	str	w19, [x7, #0x18]
    9dbc: aa1703e9     	mov	x9, x23
    9dc0: b9401121     	ldr	w1, [x9, #0x10]
    9dc4: 51000421     	sub	w1, w1, #0x1
    9dc8: aa1703ec     	mov	x12, x23
    9dcc: b9001181     	str	w1, [x12, #0x10]
    9dd0: 910183ff     	add	sp, sp, #0x60
    9dd4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    9dd8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    9ddc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    9de0: f84107f9     	ldr	x25, [sp], #0x10
    9de4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    9de8: d65f03c0     	ret
    9dec: aa1803e1     	mov	x1, x24
    9df0: 34002641     	cbz	w1, 0xa2b8 <___pl_fn_19+0x864>
    9df4: aa1703e0     	mov	x0, x23
    9df8: f9400000     	ldr	x0, [x0]
    9dfc: aa1803e1     	mov	x1, x24
    9e00: 2a0103e1     	mov	w1, w1
    9e04: 8b010c01     	add	x1, x0, x1, lsl #3
    9e08: aa1803e2     	mov	x2, x24
    9e0c: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    9e10: d360fc00     	lsr	x0, x0, #32
    9e14: 92403c02     	and	x2, x0, #0xffff
    9e18: 91002440     	add	x0, x2, #0x9
    9e1c: f8607820     	ldr	x0, [x1, x0, lsl #3]
    9e20: f100085f     	cmp	x2, #0x2
    9e24: 540000c0     	b.eq	0x9e3c <___pl_fn_19+0x3e8>
    9e28: f9400821     	ldr	x1, [x1, #0x10]
    9e2c: 37482461     	tbnz	w1, #0x9, 0xa2b8 <___pl_fn_19+0x864>
    9e30: 14000003     	b	0x9e3c <___pl_fn_19+0x3e8>
    9e34: aa1703e0     	mov	x0, x23
    9e38: f9401800     	ldr	x0, [x0, #0x30]
    9e3c: d2800035     	mov	x21, #0x1               ; =1
    9e40: ab150000     	adds	x0, x0, x21
    9e44: 9a9f77e1     	cset	x1, vs
    9e48: 72001c3f     	tst	w1, #0xff
    9e4c: 54003381     	b.ne	0xa4bc <___pl_fn_19+0xa68>
    9e50: aa1803e1     	mov	x1, x24
    9e54: 35000081     	cbnz	w1, 0x9e64 <___pl_fn_19+0x410>
    9e58: 14000121     	b	0xa2dc <___pl_fn_19+0x888>
    9e5c: aa1803e1     	mov	x1, x24
    9e60: 14000013     	b	0x9eac <___pl_fn_19+0x458>
    9e64: aa1703e8     	mov	x8, x23
    9e68: f9400102     	ldr	x2, [x8]
    9e6c: aa1803e1     	mov	x1, x24
    9e70: 2a0103e1     	mov	w1, w1
    9e74: 8b010c41     	add	x1, x2, x1, lsl #3
    9e78: aa1803e3     	mov	x3, x24
    9e7c: f8635842     	ldr	x2, [x2, w3, uxtw #3]
    9e80: d360fc42     	lsr	x2, x2, #32
    9e84: 92403c43     	and	x3, x2, #0xffff
    9e88: f100087f     	cmp	x3, #0x2
    9e8c: 54000080     	b.eq	0x9e9c <___pl_fn_19+0x448>
    9e90: f9400823     	ldr	x3, [x1, #0x10]
    9e94: 9276f863     	and	x3, x3, #0xfffffffffffffdff
    9e98: f9000823     	str	x3, [x1, #0x10]
    9e9c: 92403c45     	and	x5, x2, #0xffff
    9ea0: 910024a5     	add	x5, x5, #0x9
    9ea4: f8257820     	str	x0, [x1, x5, lsl #3]
    9ea8: aa1803e1     	mov	x1, x24
    9eac: aa1803e1     	mov	x1, x24
    9eb0: 340022e1     	cbz	w1, 0xa30c <___pl_fn_19+0x8b8>
    9eb4: aa1703e0     	mov	x0, x23
    9eb8: f940000a     	ldr	x10, [x0]
    9ebc: aa1803e1     	mov	x1, x24
    9ec0: 2a0103e9     	mov	w9, w1
    9ec4: 8b090d49     	add	x9, x10, x9, lsl #3
    9ec8: f861594a     	ldr	x10, [x10, w1, uxtw #3]
    9ecc: d360fd4a     	lsr	x10, x10, #32
    9ed0: 92403d4a     	and	x10, x10, #0xffff
    9ed4: 9100254b     	add	x11, x10, #0x9
    9ed8: f86b7920     	ldr	x0, [x9, x11, lsl #3]
    9edc: f100095f     	cmp	x10, #0x2
    9ee0: 540000c0     	b.eq	0x9ef8 <___pl_fn_19+0x4a4>
    9ee4: f940092c     	ldr	x12, [x9, #0x10]
    9ee8: 3748212c     	tbnz	w12, #0x9, 0xa30c <___pl_fn_19+0x8b8>
    9eec: 14000003     	b	0x9ef8 <___pl_fn_19+0x4a4>
    9ef0: aa1703e0     	mov	x0, x23
    9ef4: f9401800     	ldr	x0, [x0, #0x30]
    9ef8: f100681f     	cmp	x0, #0x1a
    9efc: 5400006c     	b.gt	0x9f08 <___pl_fn_19+0x4b4>
    9f00: aa1803e1     	mov	x1, x24
    9f04: 14000015     	b	0x9f58 <___pl_fn_19+0x504>
    9f08: aa1803e1     	mov	x1, x24
    9f0c: 34002121     	cbz	w1, 0xa330 <___pl_fn_19+0x8dc>
    9f10: aa1703e0     	mov	x0, x23
    9f14: f9400001     	ldr	x1, [x0]
    9f18: aa1803e0     	mov	x0, x24
    9f1c: 2a0003e0     	mov	w0, w0
    9f20: 8b000c20     	add	x0, x1, x0, lsl #3
    9f24: aa1803e3     	mov	x3, x24
    9f28: f8635821     	ldr	x1, [x1, w3, uxtw #3]
    9f2c: d360fc21     	lsr	x1, x1, #32
    9f30: 92403c22     	and	x2, x1, #0xffff
    9f34: f100085f     	cmp	x2, #0x2
    9f38: 54000080     	b.eq	0x9f48 <___pl_fn_19+0x4f4>
    9f3c: f9400802     	ldr	x2, [x0, #0x10]
    9f40: 9276f842     	and	x2, x2, #0xfffffffffffffdff
    9f44: f9000802     	str	x2, [x0, #0x10]
    9f48: 92403c21     	and	x1, x1, #0xffff
    9f4c: 91002421     	add	x1, x1, #0x9
    9f50: f8217815     	str	x21, [x0, x1, lsl #3]
    9f54: aa1803e1     	mov	x1, x24
    9f58: aa1803e1     	mov	x1, x24
    9f5c: 34002021     	cbz	w1, 0xa360 <___pl_fn_19+0x90c>
    9f60: aa1703e0     	mov	x0, x23
    9f64: f9400000     	ldr	x0, [x0]
    9f68: aa1803e1     	mov	x1, x24
    9f6c: 2a0103e1     	mov	w1, w1
    9f70: 8b010c01     	add	x1, x0, x1, lsl #3
    9f74: aa1803e2     	mov	x2, x24
    9f78: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    9f7c: d360fc00     	lsr	x0, x0, #32
    9f80: 92403c02     	and	x2, x0, #0xffff
    9f84: 91002440     	add	x0, x2, #0x9
    9f88: f8607820     	ldr	x0, [x1, x0, lsl #3]
    9f8c: f100085f     	cmp	x2, #0x2
    9f90: 540000c0     	b.eq	0x9fa8 <___pl_fn_19+0x554>
    9f94: f9400821     	ldr	x1, [x1, #0x10]
    9f98: 37481e41     	tbnz	w1, #0x9, 0xa360 <___pl_fn_19+0x90c>
    9f9c: 14000003     	b	0x9fa8 <___pl_fn_19+0x554>
    9fa0: aa1703e0     	mov	x0, x23
    9fa4: f9401800     	ldr	x0, [x0, #0x30]
    9fa8: d2800821     	mov	x1, #0x41               ; =65
    9fac: ab000020     	adds	x0, x1, x0
    9fb0: 9a9f77e1     	cset	x1, vs
    9fb4: 72001c3f     	tst	w1, #0xff
    9fb8: 54002681     	b.ne	0xa488 <___pl_fn_19+0xa34>
    9fbc: eb150003     	subs	x3, x0, x21
    9fc0: 9a9f77e0     	cset	x0, vs
    9fc4: 72001c1f     	tst	w0, #0xff
    9fc8: 54002461     	b.ne	0xa454 <___pl_fn_19+0xa00>
    9fcc: aa1703e0     	mov	x0, x23
    9fd0: b9401816     	ldr	w22, [x0, #0x18]
    9fd4: b9401c00     	ldr	w0, [x0, #0x1c]
    9fd8: 11000ac1     	add	w1, w22, #0x2
    9fdc: 6b00003f     	cmp	w1, w0
    9fe0: 54002208     	b.hi	0xa420 <___pl_fn_19+0x9cc>
    9fe4: aa1703e0     	mov	x0, x23
    9fe8: f9401000     	ldr	x0, [x0, #0x20]
    9fec: 2a1603e1     	mov	w1, w22
    9ff0: 8b010801     	add	x1, x0, x1, lsl #2
    9ff4: aa1803e2     	mov	x2, x24
    9ff8: b8365802     	str	w2, [x0, w22, uxtw #2]
    9ffc: aa1903e2     	mov	x2, x25
    a000: b9000422     	str	w2, [x1, #0x4]
    a004: 11000ac0     	add	w0, w22, #0x2
    a008: aa1703ec     	mov	x12, x23
    a00c: b9001980     	str	w0, [x12, #0x18]
    a010: aa1703e0     	mov	x0, x23
    a014: b9401000     	ldr	w0, [x0, #0x10]
    a018: aa1703e1     	mov	x1, x23
    a01c: b9401421     	ldr	w1, [x1, #0x14]
    a020: 6b01001f     	cmp	w0, w1
    a024: 54001e42     	b.hs	0xa3ec <___pl_fn_19+0x998>
    a028: 72001e9f     	tst	w20, #0xff
    a02c: 54001c60     	b.eq	0xa3b8 <___pl_fn_19+0x964>
    a030: aa1703e0     	mov	x0, x23
    a034: aa1903e1     	mov	x1, x25
    a038: aa1303e2     	mov	x2, x19
    a03c: 94000000     	bl	0xa03c <___pl_fn_19+0x5e8>
    a040: aa1703e0     	mov	x0, x23
    a044: b9402c00     	ldr	w0, [x0, #0x2c]
    a048: 35002540     	cbnz	w0, 0xa4f0 <___pl_fn_19+0xa9c>
    a04c: aa1703e0     	mov	x0, x23
    a050: b9001816     	str	w22, [x0, #0x18]
    a054: ab150273     	adds	x19, x19, x21
    a058: 9a9f77e3     	cset	x3, vs
    a05c: 72001c7f     	tst	w3, #0xff
    a060: 54001921     	b.ne	0xa384 <___pl_fn_19+0x930>
    a064: 52800034     	mov	w20, #0x1               ; =1
    a068: 17ffff32     	b	0x9d30 <___pl_fn_19+0x2dc>
    a06c: aa1703e0     	mov	x0, x23
    a070: b9401813     	ldr	w19, [x0, #0x18]
    a074: b9401c0d     	ldr	w13, [x0, #0x1c]
    a078: 1100066c     	add	w12, w19, #0x1
    a07c: 6b0d019f     	cmp	w12, w13
    a080: 54002628     	b.hi	0xa544 <___pl_fn_19+0xaf0>
    a084: aa1703e0     	mov	x0, x23
    a088: f940100e     	ldr	x14, [x0, #0x20]
    a08c: aa1803e1     	mov	x1, x24
    a090: b83359c1     	str	w1, [x14, w19, uxtw #2]
    a094: b900180c     	str	w12, [x0, #0x18]
    a098: b9401000     	ldr	w0, [x0, #0x10]
    a09c: aa1703e1     	mov	x1, x23
    a0a0: b9401421     	ldr	w1, [x1, #0x14]
    a0a4: 6b01001f     	cmp	w0, w1
    a0a8: 54002342     	b.hs	0xa510 <___pl_fn_19+0xabc>
    a0ac: aa1803e1     	mov	x1, x24
    a0b0: aa1703e0     	mov	x0, x23
    a0b4: 94000000     	bl	0xa0b4 <___pl_fn_19+0x660>
    a0b8: aa1703e1     	mov	x1, x23
    a0bc: b9402c21     	ldr	w1, [x1, #0x2c]
    a0c0: 35002181     	cbnz	w1, 0xa4f0 <___pl_fn_19+0xa9c>
    a0c4: aa1703e1     	mov	x1, x23
    a0c8: b9001833     	str	w19, [x1, #0x18]
    a0cc: b9401021     	ldr	w1, [x1, #0x10]
    a0d0: 51000421     	sub	w1, w1, #0x1
    a0d4: aa1703e2     	mov	x2, x23
    a0d8: b9001041     	str	w1, [x2, #0x10]
    a0dc: 910183ff     	add	sp, sp, #0x60
    a0e0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a0e4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a0e8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a0ec: f84107f9     	ldr	x25, [sp], #0x10
    a0f0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a0f4: d65f03c0     	ret
    a0f8: aa0003f7     	mov	x23, x0
    a0fc: 52802721     	mov	w1, #0x139              ; =313
    a100: 528000e3     	mov	w3, #0x7                ; =7
    a104: 90000004     	adrp	x4, 0xa000 <___pl_fn_19+0x5ac>
    a108: f9400084     	ldr	x4, [x4]
    a10c: aa1703e0     	mov	x0, x23
    a110: aa1803e2     	mov	x2, x24
    a114: d63f0080     	blr	x4
    a118: 34ffcd60     	cbz	w0, 0x9ac4 <___pl_fn_19+0x70>
    a11c: 140000f5     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a120: 52802741     	mov	w1, #0x13a              ; =314
    a124: 52800043     	mov	w3, #0x2                ; =2
    a128: 90000004     	adrp	x4, 0xa000 <___pl_fn_19+0x5ac>
    a12c: f9400084     	ldr	x4, [x4]
    a130: aa1703e0     	mov	x0, x23
    a134: d63f0080     	blr	x4
    a138: 34ffce40     	cbz	w0, 0x9b00 <___pl_fn_19+0xac>
    a13c: 140000ed     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a140: 52802761     	mov	w1, #0x13b              ; =315
    a144: 52800103     	mov	w3, #0x8                ; =8
    a148: 9000000d     	adrp	x13, 0xa000 <___pl_fn_19+0x5ac>
    a14c: f94001ad     	ldr	x13, [x13]
    a150: aa1703e0     	mov	x0, x23
    a154: aa1303e2     	mov	x2, x19
    a158: d63f01a0     	blr	x13
    a15c: aa1303f8     	mov	x24, x19
    a160: 34ffd060     	cbz	w0, 0x9b6c <___pl_fn_19+0x118>
    a164: 140000e3     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a168: d2800100     	mov	x0, #0x8                ; =8
    a16c: 910003e3     	mov	x3, sp
    a170: f80003e0     	stur	x0, [sp]
    a174: f80083f3     	stur	x19, [sp, #0x8]
    a178: 52802781     	mov	w1, #0x13c              ; =316
    a17c: 90000004     	adrp	x4, 0xa000 <___pl_fn_19+0x5ac>
    a180: f9400084     	ldr	x4, [x4]
    a184: aa1703e0     	mov	x0, x23
    a188: aa1803e2     	mov	x2, x24
    a18c: d63f0080     	blr	x4
    a190: 34ffd1e0     	cbz	w0, 0x9bcc <___pl_fn_19+0x178>
    a194: 140000d7     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a198: d2800100     	mov	x0, #0x8                ; =8
    a19c: 910043e3     	add	x3, sp, #0x10
    a1a0: f80103e0     	stur	x0, [sp, #0x10]
    a1a4: d2800080     	mov	x0, #0x4                ; =4
    a1a8: f80183e0     	stur	x0, [sp, #0x18]
    a1ac: 528027a1     	mov	w1, #0x13d              ; =317
    a1b0: 90000004     	adrp	x4, 0xa000 <___pl_fn_19+0x5ac>
    a1b4: f9400084     	ldr	x4, [x4]
    a1b8: aa1703e0     	mov	x0, x23
    a1bc: aa1803e2     	mov	x2, x24
    a1c0: d63f0080     	blr	x4
    a1c4: 34ffd300     	cbz	w0, 0x9c24 <___pl_fn_19+0x1d0>
    a1c8: 140000ca     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a1cc: 528027c1     	mov	w1, #0x13e              ; =318
    a1d0: 52800103     	mov	w3, #0x8                ; =8
    a1d4: 90000004     	adrp	x4, 0xa000 <___pl_fn_19+0x5ac>
    a1d8: f9400084     	ldr	x4, [x4]
    a1dc: aa1703e0     	mov	x0, x23
    a1e0: aa1803e2     	mov	x2, x24
    a1e4: d63f0080     	blr	x4
    a1e8: 34ffd440     	cbz	w0, 0x9c70 <___pl_fn_19+0x21c>
    a1ec: 140000c1     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a1f0: d2800021     	mov	x1, #0x1                ; =1
    a1f4: 910083e3     	add	x3, sp, #0x20
    a1f8: f80203e1     	stur	x1, [sp, #0x20]
    a1fc: f80283e0     	stur	x0, [sp, #0x28]
    a200: 528027e1     	mov	w1, #0x13f              ; =319
    a204: 90000004     	adrp	x4, 0xa000 <___pl_fn_19+0x5ac>
    a208: f9400084     	ldr	x4, [x4]
    a20c: aa1703e0     	mov	x0, x23
    a210: aa1903e2     	mov	x2, x25
    a214: d63f0080     	blr	x4
    a218: 34ffd3a0     	cbz	w0, 0x9c8c <___pl_fn_19+0x238>
    a21c: 140000b5     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a220: 9100c3e3     	add	x3, sp, #0x30
    a224: f80303f3     	stur	x19, [sp, #0x30]
    a228: d280000b     	mov	x11, #0x0               ; =0
    a22c: f80383eb     	stur	x11, [sp, #0x38]
    a230: 52802801     	mov	w1, #0x140              ; =320
    a234: 9000000c     	adrp	x12, 0xa000 <___pl_fn_19+0x5ac>
    a238: f940018c     	ldr	x12, [x12]
    a23c: aa1703e0     	mov	x0, x23
    a240: aa1903e2     	mov	x2, x25
    a244: d63f0180     	blr	x12
    a248: 34ffd700     	cbz	w0, 0x9d28 <___pl_fn_19+0x2d4>
    a24c: 140000a9     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a250: 52802861     	mov	w1, #0x143              ; =323
    a254: 90000002     	adrp	x2, 0xa000 <___pl_fn_19+0x5ac>
    a258: f9400042     	ldr	x2, [x2]
    a25c: aa1703e0     	mov	x0, x23
    a260: d63f0040     	blr	x2
    a264: 52800000     	mov	w0, #0x0                ; =0
    a268: 910183ff     	add	sp, sp, #0x60
    a26c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a270: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a274: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a278: f84107f9     	ldr	x25, [sp], #0x10
    a27c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a280: d65f03c0     	ret
    a284: 52802841     	mov	w1, #0x142              ; =322
    a288: 90000002     	adrp	x2, 0xa000 <___pl_fn_19+0x5ac>
    a28c: f9400042     	ldr	x2, [x2]
    a290: aa1703e0     	mov	x0, x23
    a294: d63f0040     	blr	x2
    a298: 52800000     	mov	w0, #0x0                ; =0
    a29c: 910183ff     	add	sp, sp, #0x60
    a2a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a2a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a2a8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a2ac: f84107f9     	ldr	x25, [sp], #0x10
    a2b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a2b4: d65f03c0     	ret
    a2b8: 52802881     	mov	w1, #0x144              ; =324
    a2bc: 52800123     	mov	w3, #0x9                ; =9
    a2c0: 90000004     	adrp	x4, 0xa000 <___pl_fn_19+0x5ac>
    a2c4: f9400084     	ldr	x4, [x4]
    a2c8: aa1703e0     	mov	x0, x23
    a2cc: aa1803e2     	mov	x2, x24
    a2d0: d63f0080     	blr	x4
    a2d4: 34ffdb00     	cbz	w0, 0x9e34 <___pl_fn_19+0x3e0>
    a2d8: 14000086     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a2dc: d2800121     	mov	x1, #0x9                ; =9
    a2e0: 910103e3     	add	x3, sp, #0x40
    a2e4: f80403e1     	stur	x1, [sp, #0x40]
    a2e8: f80483e0     	stur	x0, [sp, #0x48]
    a2ec: 528028c1     	mov	w1, #0x146              ; =326
    a2f0: 90000004     	adrp	x4, 0xa000 <___pl_fn_19+0x5ac>
    a2f4: f9400084     	ldr	x4, [x4]
    a2f8: aa1703e0     	mov	x0, x23
    a2fc: aa1803e2     	mov	x2, x24
    a300: d63f0080     	blr	x4
    a304: 34ffdac0     	cbz	w0, 0x9e5c <___pl_fn_19+0x408>
    a308: 1400007a     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a30c: 528028e1     	mov	w1, #0x147              ; =327
    a310: 52800123     	mov	w3, #0x9                ; =9
    a314: 9000000f     	adrp	x15, 0xa000 <___pl_fn_19+0x5ac>
    a318: f94001ef     	ldr	x15, [x15]
    a31c: aa1703e0     	mov	x0, x23
    a320: aa1803e2     	mov	x2, x24
    a324: d63f01e0     	blr	x15
    a328: 34ffde40     	cbz	w0, 0x9ef0 <___pl_fn_19+0x49c>
    a32c: 14000071     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a330: d2800120     	mov	x0, #0x9                ; =9
    a334: 910143e3     	add	x3, sp, #0x50
    a338: f80503e0     	stur	x0, [sp, #0x50]
    a33c: f80583f5     	stur	x21, [sp, #0x58]
    a340: 52802901     	mov	w1, #0x148              ; =328
    a344: 90000004     	adrp	x4, 0xa000 <___pl_fn_19+0x5ac>
    a348: f9400084     	ldr	x4, [x4]
    a34c: aa1703e0     	mov	x0, x23
    a350: aa1803e2     	mov	x2, x24
    a354: d63f0080     	blr	x4
    a358: 34ffdfe0     	cbz	w0, 0x9f54 <___pl_fn_19+0x500>
    a35c: 14000065     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a360: 52802921     	mov	w1, #0x149              ; =329
    a364: 52800123     	mov	w3, #0x9                ; =9
    a368: 90000004     	adrp	x4, 0xa000 <___pl_fn_19+0x5ac>
    a36c: f9400084     	ldr	x4, [x4]
    a370: aa1703e0     	mov	x0, x23
    a374: aa1803e2     	mov	x2, x24
    a378: d63f0080     	blr	x4
    a37c: 34ffe120     	cbz	w0, 0x9fa0 <___pl_fn_19+0x54c>
    a380: 1400005c     	b	0xa4f0 <___pl_fn_19+0xa9c>
    a384: 528029e1     	mov	w1, #0x14f              ; =335
    a388: 90000005     	adrp	x5, 0xa000 <___pl_fn_19+0x5ac>
    a38c: f94000a5     	ldr	x5, [x5]
    a390: aa1703e0     	mov	x0, x23
    a394: d63f00a0     	blr	x5
    a398: 52800000     	mov	w0, #0x0                ; =0
    a39c: 910183ff     	add	sp, sp, #0x60
    a3a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a3a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a3a8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a3ac: f84107f9     	ldr	x25, [sp], #0x10
    a3b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a3b4: d65f03c0     	ret
    a3b8: 528029c1     	mov	w1, #0x14e              ; =334
    a3bc: 90000006     	adrp	x6, 0xa000 <___pl_fn_19+0x5ac>
    a3c0: f94000c6     	ldr	x6, [x6]
    a3c4: aa1703e0     	mov	x0, x23
    a3c8: d63f00c0     	blr	x6
    a3cc: 52800000     	mov	w0, #0x0                ; =0
    a3d0: 910183ff     	add	sp, sp, #0x60
    a3d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a3d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a3dc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a3e0: f84107f9     	ldr	x25, [sp], #0x10
    a3e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a3e8: d65f03c0     	ret
    a3ec: 528029a1     	mov	w1, #0x14d              ; =333
    a3f0: 90000007     	adrp	x7, 0xa000 <___pl_fn_19+0x5ac>
    a3f4: f94000e7     	ldr	x7, [x7]
    a3f8: aa1703e0     	mov	x0, x23
    a3fc: d63f00e0     	blr	x7
    a400: 52800000     	mov	w0, #0x0                ; =0
    a404: 910183ff     	add	sp, sp, #0x60
    a408: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a40c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a410: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a414: f84107f9     	ldr	x25, [sp], #0x10
    a418: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a41c: d65f03c0     	ret
    a420: 52802981     	mov	w1, #0x14c              ; =332
    a424: 90000008     	adrp	x8, 0xa000 <___pl_fn_19+0x5ac>
    a428: f9400108     	ldr	x8, [x8]
    a42c: aa1703e0     	mov	x0, x23
    a430: d63f0100     	blr	x8
    a434: 52800000     	mov	w0, #0x0                ; =0
    a438: 910183ff     	add	sp, sp, #0x60
    a43c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a440: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a444: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a448: f84107f9     	ldr	x25, [sp], #0x10
    a44c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a450: d65f03c0     	ret
    a454: 52802961     	mov	w1, #0x14b              ; =331
    a458: 90000009     	adrp	x9, 0xa000 <___pl_fn_19+0x5ac>
    a45c: f9400129     	ldr	x9, [x9]
    a460: aa1703e0     	mov	x0, x23
    a464: d63f0120     	blr	x9
    a468: 52800000     	mov	w0, #0x0                ; =0
    a46c: 910183ff     	add	sp, sp, #0x60
    a470: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a474: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a478: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a47c: f84107f9     	ldr	x25, [sp], #0x10
    a480: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a484: d65f03c0     	ret
    a488: 52802941     	mov	w1, #0x14a              ; =330
    a48c: 9000000a     	adrp	x10, 0xa000 <___pl_fn_19+0x5ac>
    a490: f940014a     	ldr	x10, [x10]
    a494: aa1703e0     	mov	x0, x23
    a498: d63f0140     	blr	x10
    a49c: 52800000     	mov	w0, #0x0                ; =0
    a4a0: 910183ff     	add	sp, sp, #0x60
    a4a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a4a8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a4ac: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a4b0: f84107f9     	ldr	x25, [sp], #0x10
    a4b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a4b8: d65f03c0     	ret
    a4bc: 528028a1     	mov	w1, #0x145              ; =325
    a4c0: 9000000b     	adrp	x11, 0xa000 <___pl_fn_19+0x5ac>
    a4c4: f940016b     	ldr	x11, [x11]
    a4c8: aa1703e0     	mov	x0, x23
    a4cc: d63f0160     	blr	x11
    a4d0: 52800000     	mov	w0, #0x0                ; =0
    a4d4: 910183ff     	add	sp, sp, #0x60
    a4d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a4dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a4e0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a4e4: f84107f9     	ldr	x25, [sp], #0x10
    a4e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a4ec: d65f03c0     	ret
    a4f0: 52800000     	mov	w0, #0x0                ; =0
    a4f4: 910183ff     	add	sp, sp, #0x60
    a4f8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a4fc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a500: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a504: f84107f9     	ldr	x25, [sp], #0x10
    a508: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a50c: d65f03c0     	ret
    a510: 52802a21     	mov	w1, #0x151              ; =337
    a514: 90000002     	adrp	x2, 0xa000 <___pl_fn_19+0x5ac>
    a518: f9400042     	ldr	x2, [x2]
    a51c: aa1703e0     	mov	x0, x23
    a520: d63f0040     	blr	x2
    a524: 52800000     	mov	w0, #0x0                ; =0
    a528: 910183ff     	add	sp, sp, #0x60
    a52c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a530: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a534: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a538: f84107f9     	ldr	x25, [sp], #0x10
    a53c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a540: d65f03c0     	ret
    a544: 52802a01     	mov	w1, #0x150              ; =336
    a548: 90000002     	adrp	x2, 0xa000 <___pl_fn_19+0x5ac>
    a54c: f9400042     	ldr	x2, [x2]
    a550: aa1703e0     	mov	x0, x23
    a554: d63f0040     	blr	x2
    a558: 52800000     	mov	w0, #0x0                ; =0
    a55c: 910183ff     	add	sp, sp, #0x60
    a560: a8c153f3     	ldp	x19, x20, [sp], #0x10
    a564: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    a568: a8c163f7     	ldp	x23, x24, [sp], #0x10
    a56c: f84107f9     	ldr	x25, [sp], #0x10
    a570: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    a574: d65f03c0     	ret
