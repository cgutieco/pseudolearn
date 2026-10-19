
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_28184/richards/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: b9401003     	ldr	w3, [x0, #0x10]
       c: 11000464     	add	w4, w3, #0x1
      10: b9001004     	str	w4, [x0, #0x10]
      14: aa0003e7     	mov	x7, x0
      18: d2800000     	mov	x0, #0x0                ; =0
      1c: d280002c     	mov	x12, #0x1               ; =1
      20: f100003f     	cmp	x1, #0x0
      24: 5400008c     	b.gt	0x34 <___pl_fn_0+0x34>
      28: f100005f     	cmp	x2, #0x0
      2c: 9a9fd7e4     	cset	x4, gt
      30: 14000002     	b	0x38 <___pl_fn_0+0x38>
      34: 52800024     	mov	w4, #0x1                ; =1
      38: 72001c9f     	tst	w4, #0xff
      3c: 540000a1     	b.ne	0x50 <___pl_fn_0+0x50>
      40: aa0703e1     	mov	x1, x7
      44: b9001023     	str	w3, [x1, #0x10]
      48: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      4c: d65f03c0     	ret
      50: d37ffc44     	lsr	x4, x2, #63
      54: 8b040044     	add	x4, x2, x4
      58: 927ff885     	and	x5, x4, #0xfffffffffffffffe
      5c: 8b050025     	add	x5, x1, x5
      60: d37ffc26     	lsr	x6, x1, #63
      64: 8b060021     	add	x1, x1, x6
      68: 927ff826     	and	x6, x1, #0xfffffffffffffffe
      6c: 8b060042     	add	x2, x2, x6
      70: eb0200bf     	cmp	x5, x2
      74: 540000a0     	b.eq	0x88 <___pl_fn_0+0x88>
      78: ab0c0000     	adds	x0, x0, x12
      7c: 9a9f77e2     	cset	x2, vs
      80: 72001c5f     	tst	w2, #0xff
      84: 54000181     	b.ne	0xb4 <___pl_fn_0+0xb4>
      88: d2800042     	mov	x2, #0x2                ; =2
      8c: 9b027d85     	mul	x5, x12, x2
      90: 9b427d82     	smulh	x2, x12, x2
      94: eb85fc5f     	cmp	x2, x5, asr #63
      98: 540000a1     	b.ne	0xac <___pl_fn_0+0xac>
      9c: 9341fc21     	asr	x1, x1, #1
      a0: 9341fc82     	asr	x2, x4, #1
      a4: aa0503ec     	mov	x12, x5
      a8: 17ffffde     	b	0x20 <___pl_fn_0+0x20>
      ac: 528000e1     	mov	w1, #0x7                ; =7
      b0: 14000002     	b	0xb8 <___pl_fn_0+0xb8>
      b4: 52800041     	mov	w1, #0x2                ; =2
      b8: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
      bc: f9400042     	ldr	x2, [x2]
      c0: aa0703e0     	mov	x0, x7
      c4: d63f0040     	blr	x2
      c8: d2800000     	mov	x0, #0x0                ; =0
      cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
      d0: d65f03c0     	ret

00000000000000d4 <___pl_fn_1>:
      d4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
      d8: 910003fd     	mov	x29, sp
      dc: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
      e0: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
      e4: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      e8: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      ec: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      f0: d10483ff     	sub	sp, sp, #0x120
      f4: b9401001     	ldr	w1, [x0, #0x10]
      f8: 11000421     	add	w1, w1, #0x1
      fc: b9001001     	str	w1, [x0, #0x10]
     100: aa0003fc     	mov	x28, x0
     104: 52800101     	mov	w1, #0x8                ; =8
     108: 52800002     	mov	w2, #0x0                ; =0
     10c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     110: f9400063     	ldr	x3, [x3]
     114: aa1c03e0     	mov	x0, x28
     118: d63f0060     	blr	x3
     11c: 35017f00     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
     120: aa1c03e0     	mov	x0, x28
     124: f9401817     	ldr	x23, [x0, #0x30]
     128: f9403c00     	ldr	x0, [x0, #0x78]
     12c: 37712c80     	tbnz	w0, #0xe, 0x26bc <___pl_fn_1+0x25e8>
     130: aa1c03e0     	mov	x0, x28
     134: f9403800     	ldr	x0, [x0, #0x70]
     138: f100001f     	cmp	x0, #0x0
     13c: 54012c0d     	b.le	0x26bc <___pl_fn_1+0x25e8>
     140: aa1c03e0     	mov	x0, x28
     144: f9403400     	ldr	x0, [x0, #0x68]
     148: f100301f     	cmp	x0, #0xc
     14c: 54012b8b     	b.lt	0x26bc <___pl_fn_1+0x25e8>
     150: aa1c03e0     	mov	x0, x28
     154: f9402802     	ldr	x2, [x0, #0x50]
     158: f9402c00     	ldr	x0, [x0, #0x58]
     15c: 91003841     	add	x1, x2, #0xe
     160: eb00003f     	cmp	x1, x0
     164: 54012ac8     	b.hi	0x26bc <___pl_fn_1+0x25e8>
     168: aa1c03e0     	mov	x0, x28
     16c: f9404400     	ldr	x0, [x0, #0x88]
     170: aa1c03e1     	mov	x1, x28
     174: f9404821     	ldr	x1, [x1, #0x90]
     178: eb01001f     	cmp	x0, x1
     17c: 540000a3     	b.lo	0x190 <___pl_fn_1+0xbc>
     180: 1400094f     	b	0x26bc <___pl_fn_1+0x25e8>
     184: aa1c03e0     	mov	x0, x28
     188: f9401802     	ldr	x2, [x0, #0x30]
     18c: 14000031     	b	0x250 <___pl_fn_1+0x17c>
     190: aa1c03e1     	mov	x1, x28
     194: f9403024     	ldr	x4, [x1, #0x60]
     198: f9400025     	ldr	x5, [x1]
     19c: d2800086     	mov	x6, #0x4                ; =4
     1a0: f2c00066     	movk	x6, #0x3, lsl #32
     1a4: 2a0203e1     	mov	w1, w2
     1a8: 8b010ca3     	add	x3, x5, x1, lsl #3
     1ac: f82258a6     	str	x6, [x5, w2, uxtw #3]
     1b0: 91000484     	add	x4, x4, #0x1
     1b4: f9000464     	str	x4, [x3, #0x8]
     1b8: 92800005     	mov	x5, #-0x1               ; =-1
     1bc: f9000865     	str	x5, [x3, #0x10]
     1c0: d2800005     	mov	x5, #0x0                ; =0
     1c4: f9000c65     	str	x5, [x3, #0x18]
     1c8: f9001065     	str	x5, [x3, #0x20]
     1cc: f9001465     	str	x5, [x3, #0x28]
     1d0: f9001865     	str	x5, [x3, #0x30]
     1d4: f9001c65     	str	x5, [x3, #0x38]
     1d8: f9002065     	str	x5, [x3, #0x40]
     1dc: f9002465     	str	x5, [x3, #0x48]
     1e0: f9002865     	str	x5, [x3, #0x50]
     1e4: f9002c65     	str	x5, [x3, #0x58]
     1e8: f9003065     	str	x5, [x3, #0x60]
     1ec: f9003465     	str	x5, [x3, #0x68]
     1f0: aa1c03e3     	mov	x3, x28
     1f4: f9003064     	str	x4, [x3, #0x60]
     1f8: 9100384e     	add	x14, x2, #0xe
     1fc: f900286e     	str	x14, [x3, #0x50]
     200: f940346f     	ldr	x15, [x3, #0x68]
     204: d10031ef     	sub	x15, x15, #0xc
     208: f900346f     	str	x15, [x3, #0x68]
     20c: aa1c03e4     	mov	x4, x28
     210: f9403883     	ldr	x3, [x4, #0x70]
     214: d1003063     	sub	x3, x3, #0xc
     218: aa1c03e7     	mov	x7, x28
     21c: f90038e3     	str	x3, [x7, #0x70]
     220: aa1c03e9     	mov	x9, x28
     224: f9404123     	ldr	x3, [x9, #0x80]
     228: b25f0821     	orr	x1, x1, #0xe00000000
     22c: d37cec05     	lsl	x5, x0, #4
     230: 8b001064     	add	x4, x3, x0, lsl #4
     234: f8256861     	str	x1, [x3, x5]
     238: d2800181     	mov	x1, #0xc                ; =12
     23c: f9000481     	str	x1, [x4, #0x8]
     240: 91000400     	add	x0, x0, #0x1
     244: aa1c03e1     	mov	x1, x28
     248: f9004420     	str	x0, [x1, #0x88]
     24c: aa1c03e0     	mov	x0, x28
     250: aa1c03e0     	mov	x0, x28
     254: f9403c00     	ldr	x0, [x0, #0x78]
     258: 37592420     	tbnz	w0, #0xb, 0x26dc <___pl_fn_1+0x2608>
     25c: aa1c03e0     	mov	x0, x28
     260: f9403800     	ldr	x0, [x0, #0x70]
     264: f100001f     	cmp	x0, #0x0
     268: 540123ed     	b.le	0x26e4 <___pl_fn_1+0x2610>
     26c: aa1c03e0     	mov	x0, x28
     270: f9403400     	ldr	x0, [x0, #0x68]
     274: f100241f     	cmp	x0, #0x9
     278: 540123ab     	b.lt	0x26ec <___pl_fn_1+0x2618>
     27c: aa1c03e0     	mov	x0, x28
     280: f9402800     	ldr	x0, [x0, #0x50]
     284: aa1c03e1     	mov	x1, x28
     288: f9402c21     	ldr	x1, [x1, #0x58]
     28c: 91002c03     	add	x3, x0, #0xb
     290: eb01007f     	cmp	x3, x1
     294: 54012308     	b.hi	0x26f4 <___pl_fn_1+0x2620>
     298: aa1c03e1     	mov	x1, x28
     29c: f9404421     	ldr	x1, [x1, #0x88]
     2a0: aa1c03e3     	mov	x3, x28
     2a4: f9404863     	ldr	x3, [x3, #0x90]
     2a8: eb03003f     	cmp	x1, x3
     2ac: 54012282     	b.hs	0x26fc <___pl_fn_1+0x2628>
     2b0: aa1c03e3     	mov	x3, x28
     2b4: b9401863     	ldr	w3, [x3, #0x18]
     2b8: aa1c03e4     	mov	x4, x28
     2bc: b9401c84     	ldr	w4, [x4, #0x1c]
     2c0: 11000463     	add	w3, w3, #0x1
     2c4: 6b04007f     	cmp	w3, w4
     2c8: 540002c9     	b.ls	0x320 <___pl_fn_1+0x24c>
     2cc: 1400090e     	b	0x2704 <___pl_fn_1+0x2630>
     2d0: aa1c03e3     	mov	x3, x28
     2d4: f9401061     	ldr	x1, [x3, #0x20]
     2d8: b8335822     	str	w2, [x1, w19, uxtw #2]
     2dc: aa1c03e5     	mov	x5, x28
     2e0: f90083e2     	str	x2, [sp, #0x100]
     2e4: b90018a0     	str	w0, [x5, #0x18]
     2e8: 52800161     	mov	w1, #0xb                ; =11
     2ec: 52800002     	mov	w2, #0x0                ; =0
     2f0: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     2f4: f9400063     	ldr	x3, [x3]
     2f8: aa1c03e0     	mov	x0, x28
     2fc: d63f0060     	blr	x3
     300: 35016fe0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
     304: aa1c03e0     	mov	x0, x28
     308: f9401800     	ldr	x0, [x0, #0x30]
     30c: aa1c03ef     	mov	x15, x28
     310: b90019f3     	str	w19, [x15, #0x18]
     314: aa0003e2     	mov	x2, x0
     318: aa0003f6     	mov	x22, x0
     31c: 14000031     	b	0x3e0 <___pl_fn_1+0x30c>
     320: f90083e2     	str	x2, [sp, #0x100]
     324: aa1c03e2     	mov	x2, x28
     328: f9403044     	ldr	x4, [x2, #0x60]
     32c: f9400045     	ldr	x5, [x2]
     330: b20007e6     	mov	x6, #0x300000003        ; =12884901891
     334: 2a0003e2     	mov	w2, w0
     338: 8b020ca3     	add	x3, x5, x2, lsl #3
     33c: f82058a6     	str	x6, [x5, w0, uxtw #3]
     340: 91000484     	add	x4, x4, #0x1
     344: f9000464     	str	x4, [x3, #0x8]
     348: 92800005     	mov	x5, #-0x1               ; =-1
     34c: f9000865     	str	x5, [x3, #0x10]
     350: d2800005     	mov	x5, #0x0                ; =0
     354: f9000c65     	str	x5, [x3, #0x18]
     358: f9001065     	str	x5, [x3, #0x20]
     35c: f9001465     	str	x5, [x3, #0x28]
     360: f9001865     	str	x5, [x3, #0x30]
     364: f9001c65     	str	x5, [x3, #0x38]
     368: f9002065     	str	x5, [x3, #0x40]
     36c: f9002465     	str	x5, [x3, #0x48]
     370: f9002865     	str	x5, [x3, #0x50]
     374: aa1c03e3     	mov	x3, x28
     378: f9003064     	str	x4, [x3, #0x60]
     37c: 91002c03     	add	x3, x0, #0xb
     380: aa1c03e4     	mov	x4, x28
     384: f9002883     	str	x3, [x4, #0x50]
     388: aa1c03e3     	mov	x3, x28
     38c: f9403463     	ldr	x3, [x3, #0x68]
     390: d1002463     	sub	x3, x3, #0x9
     394: f9003483     	str	x3, [x4, #0x68]
     398: aa1c03e3     	mov	x3, x28
     39c: f9403863     	ldr	x3, [x3, #0x70]
     3a0: d1002463     	sub	x3, x3, #0x9
     3a4: f9003883     	str	x3, [x4, #0x70]
     3a8: aa1c03e3     	mov	x3, x28
     3ac: f9404063     	ldr	x3, [x3, #0x80]
     3b0: d2c00164     	mov	x4, #0xb00000000        ; =47244640256
     3b4: aa040042     	orr	x2, x2, x4
     3b8: d37cec25     	lsl	x5, x1, #4
     3bc: 8b011064     	add	x4, x3, x1, lsl #4
     3c0: f8256862     	str	x2, [x3, x5]
     3c4: d2800122     	mov	x2, #0x9                ; =9
     3c8: f9000482     	str	x2, [x4, #0x8]
     3cc: 91000421     	add	x1, x1, #0x1
     3d0: aa1c03e3     	mov	x3, x28
     3d4: f9004461     	str	x1, [x3, #0x88]
     3d8: aa0003e2     	mov	x2, x0
     3dc: aa0003f6     	mov	x22, x0
     3e0: 34011a42     	cbz	w2, 0x2728 <___pl_fn_1+0x2654>
     3e4: aa1c03e0     	mov	x0, x28
     3e8: f940000a     	ldr	x10, [x0]
     3ec: aa1603e2     	mov	x2, x22
     3f0: 2a0203f4     	mov	w20, w2
     3f4: d2800063     	mov	x3, #0x3                ; =3
     3f8: f9008be3     	str	x3, [sp, #0x110]
     3fc: 8b140d4b     	add	x11, x10, x20, lsl #3
     400: f9000d74     	str	x20, [x11, #0x18]
     404: aa1c03e0     	mov	x0, x28
     408: f9403c0c     	ldr	x12, [x0, #0x78]
     40c: 37591aac     	tbnz	w12, #0xb, 0x2760 <___pl_fn_1+0x268c>
     410: aa1c03e0     	mov	x0, x28
     414: f940380e     	ldr	x14, [x0, #0x70]
     418: f10001df     	cmp	x14, #0x0
     41c: 54011a6d     	b.le	0x2768 <___pl_fn_1+0x2694>
     420: aa1c03e0     	mov	x0, x28
     424: f9403401     	ldr	x1, [x0, #0x68]
     428: d2800120     	mov	x0, #0x9                ; =9
     42c: f100243f     	cmp	x1, #0x9
     430: 54011a0b     	b.lt	0x2770 <___pl_fn_1+0x269c>
     434: aa1c03e1     	mov	x1, x28
     438: f9402833     	ldr	x19, [x1, #0x50]
     43c: f9402c21     	ldr	x1, [x1, #0x58]
     440: 91002e62     	add	x2, x19, #0xb
     444: eb01005f     	cmp	x2, x1
     448: 54011988     	b.hi	0x2778 <___pl_fn_1+0x26a4>
     44c: aa1c03e1     	mov	x1, x28
     450: f9404421     	ldr	x1, [x1, #0x88]
     454: aa1c03e2     	mov	x2, x28
     458: f9404842     	ldr	x2, [x2, #0x90]
     45c: eb02003f     	cmp	x1, x2
     460: 54011902     	b.hs	0x2780 <___pl_fn_1+0x26ac>
     464: aa1c03e2     	mov	x2, x28
     468: b9401842     	ldr	w2, [x2, #0x18]
     46c: aa1c03e3     	mov	x3, x28
     470: b9401c63     	ldr	w3, [x3, #0x1c]
     474: 11000842     	add	w2, w2, #0x2
     478: 6b03005f     	cmp	w2, w3
     47c: 54000309     	b.ls	0x4dc <___pl_fn_1+0x408>
     480: 140008c2     	b	0x2788 <___pl_fn_1+0x26b4>
     484: aa1c03e0     	mov	x0, x28
     488: f9401000     	ldr	x0, [x0, #0x20]
     48c: 2a1503e1     	mov	w1, w21
     490: 8b010801     	add	x1, x0, x1, lsl #2
     494: f94083e3     	ldr	x3, [sp, #0x100]
     498: b8355803     	str	w3, [x0, w21, uxtw #2]
     49c: aa1603e0     	mov	x0, x22
     4a0: b9000420     	str	w0, [x1, #0x4]
     4a4: 11000aa0     	add	w0, w21, #0x2
     4a8: aa1c03e1     	mov	x1, x28
     4ac: b9001820     	str	w0, [x1, #0x18]
     4b0: 528001e1     	mov	w1, #0xf                ; =15
     4b4: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     4b8: f9400063     	ldr	x3, [x3]
     4bc: aa1c03e0     	mov	x0, x28
     4c0: d63f0060     	blr	x3
     4c4: 350161c0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
     4c8: aa1c03e0     	mov	x0, x28
     4cc: f9401813     	ldr	x19, [x0, #0x30]
     4d0: b9001815     	str	w21, [x0, #0x18]
     4d4: f94083e2     	ldr	x2, [sp, #0x100]
     4d8: 1400002e     	b	0x590 <___pl_fn_1+0x4bc>
     4dc: aa1c03e2     	mov	x2, x28
     4e0: f9403044     	ldr	x4, [x2, #0x60]
     4e4: d28000a5     	mov	x5, #0x5                ; =5
     4e8: f2c00065     	movk	x5, #0x3, lsl #32
     4ec: 2a1303e2     	mov	w2, w19
     4f0: 8b020d43     	add	x3, x10, x2, lsl #3
     4f4: f8335945     	str	x5, [x10, w19, uxtw #3]
     4f8: 91000484     	add	x4, x4, #0x1
     4fc: f9000464     	str	x4, [x3, #0x8]
     500: 92800005     	mov	x5, #-0x1               ; =-1
     504: f9000865     	str	x5, [x3, #0x10]
     508: d2800005     	mov	x5, #0x0                ; =0
     50c: f9000c65     	str	x5, [x3, #0x18]
     510: f9001065     	str	x5, [x3, #0x20]
     514: f9001465     	str	x5, [x3, #0x28]
     518: f9001865     	str	x5, [x3, #0x30]
     51c: d2800046     	mov	x6, #0x2                ; =2
     520: f9001c66     	str	x6, [x3, #0x38]
     524: f9002066     	str	x6, [x3, #0x40]
     528: f9002466     	str	x6, [x3, #0x48]
     52c: f9002865     	str	x5, [x3, #0x50]
     530: aa1c03e3     	mov	x3, x28
     534: f9003064     	str	x4, [x3, #0x60]
     538: 91002e63     	add	x3, x19, #0xb
     53c: aa1c03e4     	mov	x4, x28
     540: f9002883     	str	x3, [x4, #0x50]
     544: aa1c03e3     	mov	x3, x28
     548: f9403463     	ldr	x3, [x3, #0x68]
     54c: d1002463     	sub	x3, x3, #0x9
     550: f9003483     	str	x3, [x4, #0x68]
     554: aa1c03e3     	mov	x3, x28
     558: f9403863     	ldr	x3, [x3, #0x70]
     55c: d1002463     	sub	x3, x3, #0x9
     560: f9003883     	str	x3, [x4, #0x70]
     564: f9404083     	ldr	x3, [x4, #0x80]
     568: d2c00164     	mov	x4, #0xb00000000        ; =47244640256
     56c: aa040042     	orr	x2, x2, x4
     570: d37cec24     	lsl	x4, x1, #4
     574: 8b011065     	add	x5, x3, x1, lsl #4
     578: f8246862     	str	x2, [x3, x4]
     57c: f90004a0     	str	x0, [x5, #0x8]
     580: 91000420     	add	x0, x1, #0x1
     584: aa1c03ed     	mov	x13, x28
     588: f90045a0     	str	x0, [x13, #0x88]
     58c: f94083e2     	ldr	x2, [sp, #0x100]
     590: 34011102     	cbz	w2, 0x27b0 <___pl_fn_1+0x26dc>
     594: aa1c03e0     	mov	x0, x28
     598: f9400002     	ldr	x2, [x0]
     59c: f94083e0     	ldr	x0, [sp, #0x100]
     5a0: 2a0003f5     	mov	w21, w0
     5a4: 8b150c42     	add	x2, x2, x21, lsl #3
     5a8: f9001454     	str	x20, [x2, #0x28]
     5ac: f94083e0     	ldr	x0, [sp, #0x100]
     5b0: 340111a0     	cbz	w0, 0x27e4 <___pl_fn_1+0x2710>
     5b4: 2a1303eb     	mov	w11, w19
     5b8: f900104b     	str	x11, [x2, #0x20]
     5bc: f94083e0     	ldr	x0, [sp, #0x100]
     5c0: 340112e0     	cbz	w0, 0x281c <___pl_fn_1+0x2748>
     5c4: f9000c4b     	str	x11, [x2, #0x18]
     5c8: f94083e0     	ldr	x0, [sp, #0x100]
     5cc: 34011420     	cbz	w0, 0x2850 <___pl_fn_1+0x277c>
     5d0: f9400840     	ldr	x0, [x2, #0x10]
     5d4: 9276f800     	and	x0, x0, #0xfffffffffffffdff
     5d8: f9000840     	str	x0, [x2, #0x10]
     5dc: d2800000     	mov	x0, #0x0                ; =0
     5e0: f9003040     	str	x0, [x2, #0x60]
     5e4: f94083e2     	ldr	x2, [sp, #0x100]
     5e8: 34011502     	cbz	w2, 0x2888 <___pl_fn_1+0x27b4>
     5ec: aa1c03e0     	mov	x0, x28
     5f0: f9400000     	ldr	x0, [x0]
     5f4: 8b150c01     	add	x1, x0, x21, lsl #3
     5f8: f9400822     	ldr	x2, [x1, #0x10]
     5fc: 9275f842     	and	x2, x2, #0xfffffffffffffbff
     600: f9000822     	str	x2, [x1, #0x10]
     604: d2800001     	mov	x1, #0x0                ; =0
     608: 8b150c00     	add	x0, x0, x21, lsl #3
     60c: f9003401     	str	x1, [x0, #0x68]
     610: aa1c03e0     	mov	x0, x28
     614: f9403c00     	ldr	x0, [x0, #0x78]
     618: 37691540     	tbnz	w0, #0xd, 0x28c0 <___pl_fn_1+0x27ec>
     61c: aa1c03e0     	mov	x0, x28
     620: f9403800     	ldr	x0, [x0, #0x70]
     624: f100001f     	cmp	x0, #0x0
     628: 5401150d     	b.le	0x28c8 <___pl_fn_1+0x27f4>
     62c: aa1c03e0     	mov	x0, x28
     630: f9403400     	ldr	x0, [x0, #0x68]
     634: d2800161     	mov	x1, #0xb                ; =11
     638: f1002c1f     	cmp	x0, #0xb
     63c: 540114ab     	b.lt	0x28d0 <___pl_fn_1+0x27fc>
     640: aa1c03e0     	mov	x0, x28
     644: f9402800     	ldr	x0, [x0, #0x50]
     648: aa1c03e6     	mov	x6, x28
     64c: f9402cc2     	ldr	x2, [x6, #0x58]
     650: 91003403     	add	x3, x0, #0xd
     654: eb02007f     	cmp	x3, x2
     658: 54011408     	b.hi	0x28d8 <___pl_fn_1+0x2804>
     65c: aa1c03ec     	mov	x12, x28
     660: f9404582     	ldr	x2, [x12, #0x88]
     664: aa1c03ee     	mov	x14, x28
     668: f94049c3     	ldr	x3, [x14, #0x90]
     66c: eb03005f     	cmp	x2, x3
     670: 54011382     	b.hs	0x28e0 <___pl_fn_1+0x280c>
     674: aa1c03e3     	mov	x3, x28
     678: b9401863     	ldr	w3, [x3, #0x18]
     67c: aa1c03e4     	mov	x4, x28
     680: b9401c84     	ldr	w4, [x4, #0x1c]
     684: 11000c63     	add	w3, w3, #0x3
     688: 6b04007f     	cmp	w3, w4
     68c: 54000309     	b.ls	0x6ec <___pl_fn_1+0x618>
     690: 14000896     	b	0x28e8 <___pl_fn_1+0x2814>
     694: aa1c03e0     	mov	x0, x28
     698: f9401002     	ldr	x2, [x0, #0x20]
     69c: 2a1803e3     	mov	w3, w24
     6a0: 8b030843     	add	x3, x2, x3, lsl #2
     6a4: f94083e0     	ldr	x0, [sp, #0x100]
     6a8: b8385840     	str	w0, [x2, w24, uxtw #2]
     6ac: b9000476     	str	w22, [x3, #0x4]
     6b0: b9000873     	str	w19, [x3, #0x8]
     6b4: 11000f05     	add	w5, w24, #0x3
     6b8: aa1c03e0     	mov	x0, x28
     6bc: b9001805     	str	w5, [x0, #0x18]
     6c0: 52800361     	mov	w1, #0x1b               ; =27
     6c4: 528000a2     	mov	w2, #0x5                ; =5
     6c8: 90000006     	adrp	x6, 0x0 <___pl_fn_0>
     6cc: f94000c6     	ldr	x6, [x6]
     6d0: d63f00c0     	blr	x6
     6d4: 35015140     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
     6d8: aa1c03e0     	mov	x0, x28
     6dc: f9401808     	ldr	x8, [x0, #0x30]
     6e0: b9001818     	str	w24, [x0, #0x18]
     6e4: aa0803e2     	mov	x2, x8
     6e8: 14000032     	b	0x7b0 <___pl_fn_1+0x6dc>
     6ec: aa1c03e3     	mov	x3, x28
     6f0: f940306d     	ldr	x13, [x3, #0x60]
     6f4: f940006e     	ldr	x14, [x3]
     6f8: d280010f     	mov	x15, #0x8               ; =8
     6fc: f2c0006f     	movk	x15, #0x3, lsl #32
     700: 2a0003eb     	mov	w11, w0
     704: 8b0b0dcc     	add	x12, x14, x11, lsl #3
     708: f82059cf     	str	x15, [x14, w0, uxtw #3]
     70c: 910005ad     	add	x13, x13, #0x1
     710: f900058d     	str	x13, [x12, #0x8]
     714: 9280000e     	mov	x14, #-0x1              ; =-1
     718: f900098e     	str	x14, [x12, #0x10]
     71c: d280000e     	mov	x14, #0x0               ; =0
     720: f9000d8e     	str	x14, [x12, #0x18]
     724: f900118e     	str	x14, [x12, #0x20]
     728: f900158e     	str	x14, [x12, #0x28]
     72c: f900198e     	str	x14, [x12, #0x30]
     730: d2800043     	mov	x3, #0x2                ; =2
     734: f9001d83     	str	x3, [x12, #0x38]
     738: f9002183     	str	x3, [x12, #0x40]
     73c: f9002583     	str	x3, [x12, #0x48]
     740: f900298e     	str	x14, [x12, #0x50]
     744: f9002d8e     	str	x14, [x12, #0x58]
     748: f900318e     	str	x14, [x12, #0x60]
     74c: aa1c03e3     	mov	x3, x28
     750: f900306d     	str	x13, [x3, #0x60]
     754: 91003403     	add	x3, x0, #0xd
     758: aa1c03e4     	mov	x4, x28
     75c: f9002883     	str	x3, [x4, #0x50]
     760: aa1c03e3     	mov	x3, x28
     764: f9403463     	ldr	x3, [x3, #0x68]
     768: d1002c63     	sub	x3, x3, #0xb
     76c: f9003483     	str	x3, [x4, #0x68]
     770: aa1c03e3     	mov	x3, x28
     774: f9403863     	ldr	x3, [x3, #0x70]
     778: d1002c63     	sub	x3, x3, #0xb
     77c: f9003883     	str	x3, [x4, #0x70]
     780: aa1c03e3     	mov	x3, x28
     784: f9404063     	ldr	x3, [x3, #0x80]
     788: d2c001a4     	mov	x4, #0xd00000000        ; =55834574848
     78c: aa040164     	orr	x4, x11, x4
     790: d37cec45     	lsl	x5, x2, #4
     794: 8b021066     	add	x6, x3, x2, lsl #4
     798: f8256864     	str	x4, [x3, x5]
     79c: f90004c1     	str	x1, [x6, #0x8]
     7a0: 91000441     	add	x1, x2, #0x1
     7a4: aa1c03e2     	mov	x2, x28
     7a8: f9004441     	str	x1, [x2, #0x88]
     7ac: aa0003e2     	mov	x2, x0
     7b0: 34010ae2     	cbz	w2, 0x290c <___pl_fn_1+0x2838>
     7b4: aa1c03e0     	mov	x0, x28
     7b8: f9400001     	ldr	x1, [x0]
     7bc: 2a0203e0     	mov	w0, w2
     7c0: 8b000c20     	add	x0, x1, x0, lsl #3
     7c4: f9400803     	ldr	x3, [x0, #0x10]
     7c8: 9277f863     	and	x3, x3, #0xfffffffffffffeff
     7cc: f9000803     	str	x3, [x0, #0x10]
     7d0: d2800024     	mov	x4, #0x1                ; =1
     7d4: 2a0203e0     	mov	w0, w2
     7d8: 8b000c21     	add	x1, x1, x0, lsl #3
     7dc: f9002c24     	str	x4, [x1, #0x58]
     7e0: 34010b02     	cbz	w2, 0x2940 <___pl_fn_1+0x286c>
     7e4: aa1c03e1     	mov	x1, x28
     7e8: f9400021     	ldr	x1, [x1]
     7ec: 8b000c23     	add	x3, x1, x0, lsl #3
     7f0: f9400865     	ldr	x5, [x3, #0x10]
     7f4: 9276f8a5     	and	x5, x5, #0xfffffffffffffdff
     7f8: f9000865     	str	x5, [x3, #0x10]
     7fc: 8b000c20     	add	x0, x1, x0, lsl #3
     800: f9003017     	str	x23, [x0, #0x60]
     804: aa1c03e0     	mov	x0, x28
     808: b9401818     	ldr	w24, [x0, #0x18]
     80c: b9401c00     	ldr	w0, [x0, #0x1c]
     810: 11001301     	add	w1, w24, #0x4
     814: 6b00003f     	cmp	w1, w0
     818: 54014688     	b.hi	0x30e8 <___pl_fn_1+0x3014>
     81c: aa1c03e0     	mov	x0, x28
     820: f9401000     	ldr	x0, [x0, #0x20]
     824: 2a1803f9     	mov	w25, w24
     828: d2800057     	mov	x23, #0x2               ; =2
     82c: 8b190801     	add	x1, x0, x25, lsl #2
     830: f94083e3     	ldr	x3, [sp, #0x100]
     834: b8385803     	str	w3, [x0, w24, uxtw #2]
     838: b9000436     	str	w22, [x1, #0x4]
     83c: b9000833     	str	w19, [x1, #0x8]
     840: b9000c22     	str	w2, [x1, #0xc]
     844: 11001300     	add	w0, w24, #0x4
     848: aa1c03e1     	mov	x1, x28
     84c: b9001820     	str	w0, [x1, #0x18]
     850: aa1c03e0     	mov	x0, x28
     854: b9401000     	ldr	w0, [x0, #0x10]
     858: b9401421     	ldr	w1, [x1, #0x14]
     85c: 6b01001f     	cmp	w0, w1
     860: 54014402     	b.hs	0x30e0 <___pl_fn_1+0x300c>
     864: 52800007     	mov	w7, #0x0                ; =0
     868: aa0203e1     	mov	x1, x2
     86c: aa1c03e0     	mov	x0, x28
     870: f94083e2     	ldr	x2, [sp, #0x100]
     874: aa1603e5     	mov	x5, x22
     878: aa0403e3     	mov	x3, x4
     87c: aa0703e6     	mov	x6, x7
     880: 94000000     	bl	0x880 <___pl_fn_1+0x7ac>
     884: aa1c03e0     	mov	x0, x28
     888: b9402c03     	ldr	w3, [x0, #0x2c]
     88c: 35014383     	cbnz	w3, 0x30fc <___pl_fn_1+0x3028>
     890: aa1c03e0     	mov	x0, x28
     894: b9001818     	str	w24, [x0, #0x18]
     898: f9403c06     	ldr	x6, [x0, #0x78]
     89c: 375906a6     	tbnz	w6, #0xb, 0x2970 <___pl_fn_1+0x289c>
     8a0: aa1c03e0     	mov	x0, x28
     8a4: f9403808     	ldr	x8, [x0, #0x70]
     8a8: f100011f     	cmp	x8, #0x0
     8ac: 5401066d     	b.le	0x2978 <___pl_fn_1+0x28a4>
     8b0: aa1c03e0     	mov	x0, x28
     8b4: f940340c     	ldr	x12, [x0, #0x68]
     8b8: d280012b     	mov	x11, #0x9               ; =9
     8bc: f100259f     	cmp	x12, #0x9
     8c0: 5401060b     	b.lt	0x2980 <___pl_fn_1+0x28ac>
     8c4: aa1c03e0     	mov	x0, x28
     8c8: f9402801     	ldr	x1, [x0, #0x50]
     8cc: f9402c0e     	ldr	x14, [x0, #0x58]
     8d0: 91002c2f     	add	x15, x1, #0xb
     8d4: eb0e01ff     	cmp	x15, x14
     8d8: 54010588     	b.hi	0x2988 <___pl_fn_1+0x28b4>
     8dc: aa1c03e0     	mov	x0, x28
     8e0: f9404400     	ldr	x0, [x0, #0x88]
     8e4: aa1c03e2     	mov	x2, x28
     8e8: f9404842     	ldr	x2, [x2, #0x90]
     8ec: eb02001f     	cmp	x0, x2
     8f0: 54010502     	b.hs	0x2990 <___pl_fn_1+0x28bc>
     8f4: aa1c03e2     	mov	x2, x28
     8f8: b9401c42     	ldr	w2, [x2, #0x1c]
     8fc: 11000f03     	add	w3, w24, #0x3
     900: 6b02007f     	cmp	w3, w2
     904: 540002c9     	b.ls	0x95c <___pl_fn_1+0x888>
     908: 14000824     	b	0x2998 <___pl_fn_1+0x28c4>
     90c: aa1c03e1     	mov	x1, x28
     910: f9401022     	ldr	x2, [x1, #0x20]
     914: 8b190841     	add	x1, x2, x25, lsl #2
     918: f94083e3     	ldr	x3, [sp, #0x100]
     91c: b8385843     	str	w3, [x2, w24, uxtw #2]
     920: b9000436     	str	w22, [x1, #0x4]
     924: b9000833     	str	w19, [x1, #0x8]
     928: aa1c03e1     	mov	x1, x28
     92c: b9001820     	str	w0, [x1, #0x18]
     930: 52800461     	mov	w1, #0x23               ; =35
     934: 52800002     	mov	w2, #0x0                ; =0
     938: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     93c: f9400063     	ldr	x3, [x3]
     940: aa1c03e0     	mov	x0, x28
     944: d63f0060     	blr	x3
     948: 35013da0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
     94c: aa1c03e0     	mov	x0, x28
     950: f9401801     	ldr	x1, [x0, #0x30]
     954: b9001818     	str	w24, [x0, #0x18]
     958: 1400002f     	b	0xa14 <___pl_fn_1+0x940>
     95c: aa1c03e4     	mov	x4, x28
     960: f9403084     	ldr	x4, [x4, #0x60]
     964: aa1c03e6     	mov	x6, x28
     968: f94000c5     	ldr	x5, [x6]
     96c: b20007e6     	mov	x6, #0x300000003        ; =12884901891
     970: 2a0103e2     	mov	w2, w1
     974: 8b020ca3     	add	x3, x5, x2, lsl #3
     978: f82158a6     	str	x6, [x5, w1, uxtw #3]
     97c: 91000484     	add	x4, x4, #0x1
     980: f9000464     	str	x4, [x3, #0x8]
     984: 92800005     	mov	x5, #-0x1               ; =-1
     988: f9000865     	str	x5, [x3, #0x10]
     98c: d2800005     	mov	x5, #0x0                ; =0
     990: f9000c65     	str	x5, [x3, #0x18]
     994: f9001065     	str	x5, [x3, #0x20]
     998: f9001465     	str	x5, [x3, #0x28]
     99c: f9001865     	str	x5, [x3, #0x30]
     9a0: f9001c65     	str	x5, [x3, #0x38]
     9a4: f9002065     	str	x5, [x3, #0x40]
     9a8: f9002465     	str	x5, [x3, #0x48]
     9ac: f9002865     	str	x5, [x3, #0x50]
     9b0: aa1c03e3     	mov	x3, x28
     9b4: f9003064     	str	x4, [x3, #0x60]
     9b8: 91002c23     	add	x3, x1, #0xb
     9bc: aa1c03e4     	mov	x4, x28
     9c0: f9002883     	str	x3, [x4, #0x50]
     9c4: aa1c03e3     	mov	x3, x28
     9c8: f9403463     	ldr	x3, [x3, #0x68]
     9cc: d1002463     	sub	x3, x3, #0x9
     9d0: f9003483     	str	x3, [x4, #0x68]
     9d4: aa1c03e3     	mov	x3, x28
     9d8: f9403863     	ldr	x3, [x3, #0x70]
     9dc: d1002463     	sub	x3, x3, #0x9
     9e0: f9003883     	str	x3, [x4, #0x70]
     9e4: aa1c03e3     	mov	x3, x28
     9e8: f9404063     	ldr	x3, [x3, #0x80]
     9ec: d2c00164     	mov	x4, #0xb00000000        ; =47244640256
     9f0: aa040042     	orr	x2, x2, x4
     9f4: d37cec04     	lsl	x4, x0, #4
     9f8: 8b001065     	add	x5, x3, x0, lsl #4
     9fc: f8246862     	str	x2, [x3, x4]
     a00: f90004ab     	str	x11, [x5, #0x8]
     a04: 91000400     	add	x0, x0, #0x1
     a08: aa1c03e2     	mov	x2, x28
     a0c: f9004440     	str	x0, [x2, #0x88]
     a10: aa1c03e0     	mov	x0, x28
     a14: aa1c03e0     	mov	x0, x28
     a18: b9401818     	ldr	w24, [x0, #0x18]
     a1c: b9401c00     	ldr	w0, [x0, #0x1c]
     a20: 11001319     	add	w25, w24, #0x4
     a24: 6b00033f     	cmp	w25, w0
     a28: 54013588     	b.hi	0x30d8 <___pl_fn_1+0x3004>
     a2c: aa1c03e0     	mov	x0, x28
     a30: f9401002     	ldr	x2, [x0, #0x20]
     a34: 2a1803fa     	mov	w26, w24
     a38: 8b1a0840     	add	x0, x2, x26, lsl #2
     a3c: f94083e3     	ldr	x3, [sp, #0x100]
     a40: b8385843     	str	w3, [x2, w24, uxtw #2]
     a44: b9000416     	str	w22, [x0, #0x4]
     a48: b9000813     	str	w19, [x0, #0x8]
     a4c: b9000c01     	str	w1, [x0, #0xc]
     a50: aa1c03e0     	mov	x0, x28
     a54: b9001819     	str	w25, [x0, #0x18]
     a58: b9401000     	ldr	w0, [x0, #0x10]
     a5c: aa1c03e8     	mov	x8, x28
     a60: b9401502     	ldr	w2, [x8, #0x14]
     a64: 6b02001f     	cmp	w0, w2
     a68: 54013342     	b.hs	0x30d0 <___pl_fn_1+0x2ffc>
     a6c: d2800003     	mov	x3, #0x0                ; =0
     a70: d2807d24     	mov	x4, #0x3e9              ; =1001
     a74: aa1c03e0     	mov	x0, x28
     a78: aa1603e2     	mov	x2, x22
     a7c: 94000000     	bl	0xa7c <___pl_fn_1+0x9a8>
     a80: aa1c03ef     	mov	x15, x28
     a84: b9402de1     	ldr	w1, [x15, #0x2c]
     a88: 350133a1     	cbnz	w1, 0x30fc <___pl_fn_1+0x3028>
     a8c: aa1c03e1     	mov	x1, x28
     a90: b9001838     	str	w24, [x1, #0x18]
     a94: 340131a0     	cbz	w0, 0x30c8 <___pl_fn_1+0x2ff4>
     a98: aa1c03e1     	mov	x1, x28
     a9c: f9403c23     	ldr	x3, [x1, #0x78]
     aa0: 3758f8c3     	tbnz	w3, #0xb, 0x29b8 <___pl_fn_1+0x28e4>
     aa4: aa1c03e1     	mov	x1, x28
     aa8: f9403825     	ldr	x5, [x1, #0x70]
     aac: f10000bf     	cmp	x5, #0x0
     ab0: 5400f88d     	b.le	0x29c0 <___pl_fn_1+0x28ec>
     ab4: aa1c03e1     	mov	x1, x28
     ab8: f9403429     	ldr	x9, [x1, #0x68]
     abc: d2800128     	mov	x8, #0x9                ; =9
     ac0: f100253f     	cmp	x9, #0x9
     ac4: 5400f82b     	b.lt	0x29c8 <___pl_fn_1+0x28f4>
     ac8: aa1c03e1     	mov	x1, x28
     acc: f9402821     	ldr	x1, [x1, #0x50]
     ad0: aa1c03e2     	mov	x2, x28
     ad4: f9402c4b     	ldr	x11, [x2, #0x58]
     ad8: 91002c2c     	add	x12, x1, #0xb
     adc: eb0b019f     	cmp	x12, x11
     ae0: 5400f788     	b.hi	0x29d0 <___pl_fn_1+0x28fc>
     ae4: aa1c03e2     	mov	x2, x28
     ae8: f940444e     	ldr	x14, [x2, #0x88]
     aec: f940484f     	ldr	x15, [x2, #0x90]
     af0: eb0f01df     	cmp	x14, x15
     af4: 5400f722     	b.hs	0x29d8 <___pl_fn_1+0x2904>
     af8: aa1c03e2     	mov	x2, x28
     afc: b9401c42     	ldr	w2, [x2, #0x1c]
     b00: 6b02033f     	cmp	w25, w2
     b04: 540002e9     	b.ls	0xb60 <___pl_fn_1+0xa8c>
     b08: 140007b6     	b	0x29e0 <___pl_fn_1+0x290c>
     b0c: aa1c03e1     	mov	x1, x28
     b10: f9401022     	ldr	x2, [x1, #0x20]
     b14: 8b1a0841     	add	x1, x2, x26, lsl #2
     b18: f94083e3     	ldr	x3, [sp, #0x100]
     b1c: b8385843     	str	w3, [x2, w24, uxtw #2]
     b20: b9000436     	str	w22, [x1, #0x4]
     b24: b9000833     	str	w19, [x1, #0x8]
     b28: b9000c20     	str	w0, [x1, #0xc]
     b2c: aa0003fa     	mov	x26, x0
     b30: aa1c03e0     	mov	x0, x28
     b34: b9001819     	str	w25, [x0, #0x18]
     b38: 52800501     	mov	w1, #0x28               ; =40
     b3c: 52800002     	mov	w2, #0x0                ; =0
     b40: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     b44: f9400063     	ldr	x3, [x3]
     b48: d63f0060     	blr	x3
     b4c: 35012d80     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
     b50: aa1c03e0     	mov	x0, x28
     b54: f9401801     	ldr	x1, [x0, #0x30]
     b58: b9001818     	str	w24, [x0, #0x18]
     b5c: 1400002f     	b	0xc18 <___pl_fn_1+0xb44>
     b60: aa0003fa     	mov	x26, x0
     b64: aa1c03e0     	mov	x0, x28
     b68: f9403003     	ldr	x3, [x0, #0x60]
     b6c: f9400004     	ldr	x4, [x0]
     b70: b20007e5     	mov	x5, #0x300000003        ; =12884901891
     b74: 2a0103e0     	mov	w0, w1
     b78: 8b000c82     	add	x2, x4, x0, lsl #3
     b7c: f8215885     	str	x5, [x4, w1, uxtw #3]
     b80: 91000463     	add	x3, x3, #0x1
     b84: f9000443     	str	x3, [x2, #0x8]
     b88: 92800004     	mov	x4, #-0x1               ; =-1
     b8c: f9000844     	str	x4, [x2, #0x10]
     b90: d2800004     	mov	x4, #0x0                ; =0
     b94: f9000c44     	str	x4, [x2, #0x18]
     b98: f9001044     	str	x4, [x2, #0x20]
     b9c: f9001444     	str	x4, [x2, #0x28]
     ba0: f9001844     	str	x4, [x2, #0x30]
     ba4: f9001c44     	str	x4, [x2, #0x38]
     ba8: f9002044     	str	x4, [x2, #0x40]
     bac: f9002444     	str	x4, [x2, #0x48]
     bb0: f9002844     	str	x4, [x2, #0x50]
     bb4: aa1c03e2     	mov	x2, x28
     bb8: f9003043     	str	x3, [x2, #0x60]
     bbc: 91002c22     	add	x2, x1, #0xb
     bc0: aa1c03e3     	mov	x3, x28
     bc4: f9002862     	str	x2, [x3, #0x50]
     bc8: aa1c03e2     	mov	x2, x28
     bcc: f9403442     	ldr	x2, [x2, #0x68]
     bd0: d1002442     	sub	x2, x2, #0x9
     bd4: f9003462     	str	x2, [x3, #0x68]
     bd8: aa1c03e2     	mov	x2, x28
     bdc: f9403842     	ldr	x2, [x2, #0x70]
     be0: d1002442     	sub	x2, x2, #0x9
     be4: f9003862     	str	x2, [x3, #0x70]
     be8: aa1c03e2     	mov	x2, x28
     bec: f9404042     	ldr	x2, [x2, #0x80]
     bf0: d2c00163     	mov	x3, #0xb00000000        ; =47244640256
     bf4: aa030000     	orr	x0, x0, x3
     bf8: d37cedc3     	lsl	x3, x14, #4
     bfc: 8b0e1044     	add	x4, x2, x14, lsl #4
     c00: f8236840     	str	x0, [x2, x3]
     c04: f9000488     	str	x8, [x4, #0x8]
     c08: 910005c0     	add	x0, x14, #0x1
     c0c: aa1c03e2     	mov	x2, x28
     c10: f9004440     	str	x0, [x2, #0x88]
     c14: aa1c03e0     	mov	x0, x28
     c18: aa1c03e0     	mov	x0, x28
     c1c: b9401818     	ldr	w24, [x0, #0x18]
     c20: b9401c00     	ldr	w0, [x0, #0x1c]
     c24: 528000a3     	mov	w3, #0x5                ; =5
     c28: f90087e3     	str	x3, [sp, #0x108]
     c2c: 11001702     	add	w2, w24, #0x5
     c30: 6b00005f     	cmp	w2, w0
     c34: 54012468     	b.hi	0x30c0 <___pl_fn_1+0x2fec>
     c38: aa1c03e0     	mov	x0, x28
     c3c: f9401002     	ldr	x2, [x0, #0x20]
     c40: 2a1803f9     	mov	w25, w24
     c44: 8b190840     	add	x0, x2, x25, lsl #2
     c48: f94083e3     	ldr	x3, [sp, #0x100]
     c4c: b8385843     	str	w3, [x2, w24, uxtw #2]
     c50: b9000416     	str	w22, [x0, #0x4]
     c54: b9000813     	str	w19, [x0, #0x8]
     c58: aa1a03e2     	mov	x2, x26
     c5c: b9000c02     	str	w2, [x0, #0xc]
     c60: b9001001     	str	w1, [x0, #0x10]
     c64: 11001700     	add	w0, w24, #0x5
     c68: aa1c03e2     	mov	x2, x28
     c6c: b9001840     	str	w0, [x2, #0x18]
     c70: aa1c03e0     	mov	x0, x28
     c74: b9401000     	ldr	w0, [x0, #0x10]
     c78: b9401442     	ldr	w2, [x2, #0x14]
     c7c: 6b02001f     	cmp	w0, w2
     c80: 540121c2     	b.hs	0x30b8 <___pl_fn_1+0x2fe4>
     c84: d2800003     	mov	x3, #0x0                ; =0
     c88: d2807d24     	mov	x4, #0x3e9              ; =1001
     c8c: aa1a03e2     	mov	x2, x26
     c90: aa1c03e0     	mov	x0, x28
     c94: 94000000     	bl	0xc94 <___pl_fn_1+0xbc0>
     c98: aa1c03e1     	mov	x1, x28
     c9c: b9402c21     	ldr	w1, [x1, #0x2c]
     ca0: 350122e1     	cbnz	w1, 0x30fc <___pl_fn_1+0x3028>
     ca4: aa1c03e1     	mov	x1, x28
     ca8: b9001838     	str	w24, [x1, #0x18]
     cac: 34012020     	cbz	w0, 0x30b0 <___pl_fn_1+0x2fdc>
     cb0: aa1c03e1     	mov	x1, x28
     cb4: f9403c22     	ldr	x2, [x1, #0x78]
     cb8: 3768ea22     	tbnz	w2, #0xd, 0x29fc <___pl_fn_1+0x2928>
     cbc: aa1c03e1     	mov	x1, x28
     cc0: f9403824     	ldr	x4, [x1, #0x70]
     cc4: f100009f     	cmp	x4, #0x0
     cc8: 5400e9ed     	b.le	0x2a04 <___pl_fn_1+0x2930>
     ccc: aa1c03e1     	mov	x1, x28
     cd0: f9403428     	ldr	x8, [x1, #0x68]
     cd4: d2800167     	mov	x7, #0xb                ; =11
     cd8: f1002d1f     	cmp	x8, #0xb
     cdc: 5400e98b     	b.lt	0x2a0c <___pl_fn_1+0x2938>
     ce0: aa1c03e1     	mov	x1, x28
     ce4: f940282a     	ldr	x10, [x1, #0x50]
     ce8: f9402c2b     	ldr	x11, [x1, #0x58]
     cec: 9100354c     	add	x12, x10, #0xd
     cf0: eb0b019f     	cmp	x12, x11
     cf4: 5400e908     	b.hi	0x2a14 <___pl_fn_1+0x2940>
     cf8: aa1c03e1     	mov	x1, x28
     cfc: f940442d     	ldr	x13, [x1, #0x88]
     d00: aa1c03e3     	mov	x3, x28
     d04: f940486e     	ldr	x14, [x3, #0x90]
     d08: eb0e01bf     	cmp	x13, x14
     d0c: 5400e882     	b.hs	0x2a1c <___pl_fn_1+0x2948>
     d10: aa1c03e8     	mov	x8, x28
     d14: b9401d01     	ldr	w1, [x8, #0x1c]
     d18: 11001302     	add	w2, w24, #0x4
     d1c: 6b01005f     	cmp	w2, w1
     d20: 54000329     	b.ls	0xd84 <___pl_fn_1+0xcb0>
     d24: 14000740     	b	0x2a24 <___pl_fn_1+0x2950>
     d28: aa1c03e2     	mov	x2, x28
     d2c: f9401043     	ldr	x3, [x2, #0x20]
     d30: 8b190862     	add	x2, x3, x25, lsl #2
     d34: f94083e4     	ldr	x4, [sp, #0x100]
     d38: b8385864     	str	w4, [x3, w24, uxtw #2]
     d3c: b9000456     	str	w22, [x2, #0x4]
     d40: b9000853     	str	w19, [x2, #0x8]
     d44: b9000c40     	str	w0, [x2, #0xc]
     d48: aa0003fa     	mov	x26, x0
     d4c: aa1c03e0     	mov	x0, x28
     d50: b9001801     	str	w1, [x0, #0x18]
     d54: 528005a1     	mov	w1, #0x2d               ; =45
     d58: 528000c2     	mov	w2, #0x6                ; =6
     d5c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     d60: f9400063     	ldr	x3, [x3]
     d64: d63f0060     	blr	x3
     d68: 35011ca0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
     d6c: aa1c03e0     	mov	x0, x28
     d70: f9401800     	ldr	x0, [x0, #0x30]
     d74: aa1c03e1     	mov	x1, x28
     d78: b9001838     	str	w24, [x1, #0x18]
     d7c: aa0003e2     	mov	x2, x0
     d80: 14000034     	b	0xe50 <___pl_fn_1+0xd7c>
     d84: aa0003fa     	mov	x26, x0
     d88: aa1c03e0     	mov	x0, x28
     d8c: f9403002     	ldr	x2, [x0, #0x60]
     d90: f9400003     	ldr	x3, [x0]
     d94: d2800124     	mov	x4, #0x9                ; =9
     d98: f2c00064     	movk	x4, #0x3, lsl #32
     d9c: 2a0a03e0     	mov	w0, w10
     da0: 8b000c61     	add	x1, x3, x0, lsl #3
     da4: f82a5864     	str	x4, [x3, w10, uxtw #3]
     da8: 91000442     	add	x2, x2, #0x1
     dac: f9000422     	str	x2, [x1, #0x8]
     db0: 92800003     	mov	x3, #-0x1               ; =-1
     db4: f9000823     	str	x3, [x1, #0x10]
     db8: d2800003     	mov	x3, #0x0                ; =0
     dbc: f9000c23     	str	x3, [x1, #0x18]
     dc0: f9001023     	str	x3, [x1, #0x20]
     dc4: f9001423     	str	x3, [x1, #0x28]
     dc8: f9001823     	str	x3, [x1, #0x30]
     dcc: f9001c37     	str	x23, [x1, #0x38]
     dd0: f9002037     	str	x23, [x1, #0x40]
     dd4: f9002437     	str	x23, [x1, #0x48]
     dd8: f9002823     	str	x3, [x1, #0x50]
     ddc: f9002c23     	str	x3, [x1, #0x58]
     de0: f9003023     	str	x3, [x1, #0x60]
     de4: aa1c03e3     	mov	x3, x28
     de8: f9003062     	str	x2, [x3, #0x60]
     dec: 91003541     	add	x1, x10, #0xd
     df0: aa1c03e5     	mov	x5, x28
     df4: f90028a1     	str	x1, [x5, #0x50]
     df8: aa1c03e8     	mov	x8, x28
     dfc: f9403501     	ldr	x1, [x8, #0x68]
     e00: d1002c21     	sub	x1, x1, #0xb
     e04: aa1c03eb     	mov	x11, x28
     e08: f9003561     	str	x1, [x11, #0x68]
     e0c: aa1c03ec     	mov	x12, x28
     e10: f9403981     	ldr	x1, [x12, #0x70]
     e14: d1002c21     	sub	x1, x1, #0xb
     e18: aa1c03ef     	mov	x15, x28
     e1c: f90039e1     	str	x1, [x15, #0x70]
     e20: aa1c03e1     	mov	x1, x28
     e24: f9404021     	ldr	x1, [x1, #0x80]
     e28: d2c001a2     	mov	x2, #0xd00000000        ; =55834574848
     e2c: aa020000     	orr	x0, x0, x2
     e30: d37ceda2     	lsl	x2, x13, #4
     e34: 8b0d1023     	add	x3, x1, x13, lsl #4
     e38: f8226820     	str	x0, [x1, x2]
     e3c: f9000467     	str	x7, [x3, #0x8]
     e40: 910005a0     	add	x0, x13, #0x1
     e44: aa1c03e1     	mov	x1, x28
     e48: f9004420     	str	x0, [x1, #0x88]
     e4c: aa0a03e2     	mov	x2, x10
     e50: 3400dfa2     	cbz	w2, 0x2a44 <___pl_fn_1+0x2970>
     e54: aa1c03e0     	mov	x0, x28
     e58: f9408be4     	ldr	x4, [sp, #0x110]
     e5c: f9400001     	ldr	x1, [x0]
     e60: 2a0203e0     	mov	w0, w2
     e64: 8b000c20     	add	x0, x1, x0, lsl #3
     e68: f9400803     	ldr	x3, [x0, #0x10]
     e6c: 9277f863     	and	x3, x3, #0xfffffffffffffeff
     e70: f9000803     	str	x3, [x0, #0x10]
     e74: 2a0203e0     	mov	w0, w2
     e78: 8b000c21     	add	x1, x1, x0, lsl #3
     e7c: f9002c24     	str	x4, [x1, #0x58]
     e80: f9008be4     	str	x4, [sp, #0x110]
     e84: 3400dfa2     	cbz	w2, 0x2a78 <___pl_fn_1+0x29a4>
     e88: aa1c03e6     	mov	x6, x28
     e8c: f94000c8     	ldr	x8, [x6]
     e90: 8b000d09     	add	x9, x8, x0, lsl #3
     e94: f940092a     	ldr	x10, [x9, #0x10]
     e98: 9276f94a     	and	x10, x10, #0xfffffffffffffdff
     e9c: f900092a     	str	x10, [x9, #0x10]
     ea0: d280000b     	mov	x11, #0x0               ; =0
     ea4: 8b000d0c     	add	x12, x8, x0, lsl #3
     ea8: f900318b     	str	x11, [x12, #0x60]
     eac: aa1c03e0     	mov	x0, x28
     eb0: b9401818     	ldr	w24, [x0, #0x18]
     eb4: b9401c0d     	ldr	w13, [x0, #0x1c]
     eb8: 1100170e     	add	w14, w24, #0x5
     ebc: 6b0d01df     	cmp	w14, w13
     ec0: 54010f48     	b.hi	0x30a8 <___pl_fn_1+0x2fd4>
     ec4: aa1c03e0     	mov	x0, x28
     ec8: f9401000     	ldr	x0, [x0, #0x20]
     ecc: 2a1803f9     	mov	w25, w24
     ed0: 8b19080f     	add	x15, x0, x25, lsl #2
     ed4: f94083e7     	ldr	x7, [sp, #0x100]
     ed8: b8385807     	str	w7, [x0, w24, uxtw #2]
     edc: b90005f6     	str	w22, [x15, #0x4]
     ee0: b90009f3     	str	w19, [x15, #0x8]
     ee4: aa1a03e0     	mov	x0, x26
     ee8: b9000de0     	str	w0, [x15, #0xc]
     eec: b90011e2     	str	w2, [x15, #0x10]
     ef0: 11001700     	add	w0, w24, #0x5
     ef4: aa1c03e1     	mov	x1, x28
     ef8: b9001820     	str	w0, [x1, #0x18]
     efc: aa1c03e0     	mov	x0, x28
     f00: b9401000     	ldr	w0, [x0, #0x10]
     f04: b9401421     	ldr	w1, [x1, #0x14]
     f08: 6b01001f     	cmp	w0, w1
     f0c: 54010ca2     	b.hs	0x30a0 <___pl_fn_1+0x2fcc>
     f10: d2807d04     	mov	x4, #0x3e8              ; =1000
     f14: 52800027     	mov	w7, #0x1                ; =1
     f18: aa0203e1     	mov	x1, x2
     f1c: aa1a03e5     	mov	x5, x26
     f20: aa1c03e0     	mov	x0, x28
     f24: f94083e2     	ldr	x2, [sp, #0x100]
     f28: aa1703e3     	mov	x3, x23
     f2c: aa0703e6     	mov	x6, x7
     f30: 94000000     	bl	0xf30 <___pl_fn_1+0xe5c>
     f34: aa1c03e0     	mov	x0, x28
     f38: b9402c00     	ldr	w0, [x0, #0x2c]
     f3c: 35010e00     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
     f40: aa1c03e0     	mov	x0, x28
     f44: b9001818     	str	w24, [x0, #0x18]
     f48: f9403c00     	ldr	x0, [x0, #0x78]
     f4c: 3758db00     	tbnz	w0, #0xb, 0x2aac <___pl_fn_1+0x29d8>
     f50: aa1c03e0     	mov	x0, x28
     f54: f9403800     	ldr	x0, [x0, #0x70]
     f58: f100001f     	cmp	x0, #0x0
     f5c: 5400dacd     	b.le	0x2ab4 <___pl_fn_1+0x29e0>
     f60: aa1c03e0     	mov	x0, x28
     f64: f9403401     	ldr	x1, [x0, #0x68]
     f68: d2800120     	mov	x0, #0x9                ; =9
     f6c: f100243f     	cmp	x1, #0x9
     f70: 5400da6b     	b.lt	0x2abc <___pl_fn_1+0x29e8>
     f74: aa1c03e4     	mov	x4, x28
     f78: f9402881     	ldr	x1, [x4, #0x50]
     f7c: aa1c03e6     	mov	x6, x28
     f80: f9402cc2     	ldr	x2, [x6, #0x58]
     f84: 91002c23     	add	x3, x1, #0xb
     f88: eb02007f     	cmp	x3, x2
     f8c: 5400d9c8     	b.hi	0x2ac4 <___pl_fn_1+0x29f0>
     f90: aa1c03ec     	mov	x12, x28
     f94: f9404582     	ldr	x2, [x12, #0x88]
     f98: aa1c03ee     	mov	x14, x28
     f9c: f94049c3     	ldr	x3, [x14, #0x90]
     fa0: eb03005f     	cmp	x2, x3
     fa4: 5400d942     	b.hs	0x2acc <___pl_fn_1+0x29f8>
     fa8: aa1c03e3     	mov	x3, x28
     fac: b9401c63     	ldr	w3, [x3, #0x1c]
     fb0: 11000f04     	add	w4, w24, #0x3
     fb4: 6b03009f     	cmp	w4, w3
     fb8: 540002c9     	b.ls	0x1010 <___pl_fn_1+0xf3c>
     fbc: 140006c6     	b	0x2ad4 <___pl_fn_1+0x2a00>
     fc0: aa1c03e1     	mov	x1, x28
     fc4: f9401022     	ldr	x2, [x1, #0x20]
     fc8: 8b190841     	add	x1, x2, x25, lsl #2
     fcc: f94083e3     	ldr	x3, [sp, #0x100]
     fd0: b8385843     	str	w3, [x2, w24, uxtw #2]
     fd4: b9000436     	str	w22, [x1, #0x4]
     fd8: b9000833     	str	w19, [x1, #0x8]
     fdc: aa1c03e1     	mov	x1, x28
     fe0: b9001820     	str	w0, [x1, #0x18]
     fe4: 528006a1     	mov	w1, #0x35               ; =53
     fe8: 52800002     	mov	w2, #0x0                ; =0
     fec: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     ff0: f9400063     	ldr	x3, [x3]
     ff4: aa1c03e0     	mov	x0, x28
     ff8: d63f0060     	blr	x3
     ffc: 35010800     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    1000: aa1c03e0     	mov	x0, x28
    1004: f9401801     	ldr	x1, [x0, #0x30]
    1008: b9001818     	str	w24, [x0, #0x18]
    100c: 1400002c     	b	0x10bc <___pl_fn_1+0xfe8>
    1010: aa1c03e3     	mov	x3, x28
    1014: f9403065     	ldr	x5, [x3, #0x60]
    1018: f9400066     	ldr	x6, [x3]
    101c: b20007e7     	mov	x7, #0x300000003        ; =12884901891
    1020: 2a0103e3     	mov	w3, w1
    1024: 8b030cc4     	add	x4, x6, x3, lsl #3
    1028: f82158c7     	str	x7, [x6, w1, uxtw #3]
    102c: 910004a5     	add	x5, x5, #0x1
    1030: f9000485     	str	x5, [x4, #0x8]
    1034: 92800006     	mov	x6, #-0x1               ; =-1
    1038: f9000886     	str	x6, [x4, #0x10]
    103c: d2800006     	mov	x6, #0x0                ; =0
    1040: f9000c86     	str	x6, [x4, #0x18]
    1044: f9001086     	str	x6, [x4, #0x20]
    1048: f9001486     	str	x6, [x4, #0x28]
    104c: f9001886     	str	x6, [x4, #0x30]
    1050: f9001c86     	str	x6, [x4, #0x38]
    1054: f9002086     	str	x6, [x4, #0x40]
    1058: f9002486     	str	x6, [x4, #0x48]
    105c: f9002886     	str	x6, [x4, #0x50]
    1060: aa1c03e9     	mov	x9, x28
    1064: f9003125     	str	x5, [x9, #0x60]
    1068: 91002c24     	add	x4, x1, #0xb
    106c: aa1c03ec     	mov	x12, x28
    1070: f9002984     	str	x4, [x12, #0x50]
    1074: aa1c03ee     	mov	x14, x28
    1078: f94035c5     	ldr	x5, [x14, #0x68]
    107c: d10024a5     	sub	x5, x5, #0x9
    1080: aa1c03e4     	mov	x4, x28
    1084: f9003485     	str	x5, [x4, #0x68]
    1088: f9403886     	ldr	x6, [x4, #0x70]
    108c: d10024c6     	sub	x6, x6, #0x9
    1090: f9003886     	str	x6, [x4, #0x70]
    1094: f9404087     	ldr	x7, [x4, #0x80]
    1098: d2c00168     	mov	x8, #0xb00000000        ; =47244640256
    109c: aa080068     	orr	x8, x3, x8
    10a0: d37cec49     	lsl	x9, x2, #4
    10a4: 8b0210ea     	add	x10, x7, x2, lsl #4
    10a8: f82968e8     	str	x8, [x7, x9]
    10ac: f9000540     	str	x0, [x10, #0x8]
    10b0: 91000449     	add	x9, x2, #0x1
    10b4: aa1c03e0     	mov	x0, x28
    10b8: f9004409     	str	x9, [x0, #0x88]
    10bc: aa1c03e0     	mov	x0, x28
    10c0: b9401818     	ldr	w24, [x0, #0x18]
    10c4: b9401c0b     	ldr	w11, [x0, #0x1c]
    10c8: 11001319     	add	w25, w24, #0x4
    10cc: 6b0b033f     	cmp	w25, w11
    10d0: 5400fe48     	b.hi	0x3098 <___pl_fn_1+0x2fc4>
    10d4: aa1c03e0     	mov	x0, x28
    10d8: f940100e     	ldr	x14, [x0, #0x20]
    10dc: 2a1803fa     	mov	w26, w24
    10e0: 8b1a09cd     	add	x13, x14, x26, lsl #2
    10e4: f94083e2     	ldr	x2, [sp, #0x100]
    10e8: b83859c2     	str	w2, [x14, w24, uxtw #2]
    10ec: b90005b6     	str	w22, [x13, #0x4]
    10f0: b90009b3     	str	w19, [x13, #0x8]
    10f4: b9000da1     	str	w1, [x13, #0xc]
    10f8: b9001819     	str	w25, [x0, #0x18]
    10fc: b9401000     	ldr	w0, [x0, #0x10]
    1100: aa1c03e2     	mov	x2, x28
    1104: b9401442     	ldr	w2, [x2, #0x14]
    1108: 6b02001f     	cmp	w0, w2
    110c: 5400fc22     	b.hs	0x3090 <___pl_fn_1+0x2fbc>
    1110: d28000a3     	mov	x3, #0x5                ; =5
    1114: d2807d04     	mov	x4, #0x3e8              ; =1000
    1118: aa1c03e0     	mov	x0, x28
    111c: aa1603e2     	mov	x2, x22
    1120: 94000000     	bl	0x1120 <___pl_fn_1+0x104c>
    1124: aa1c03e1     	mov	x1, x28
    1128: b9402c21     	ldr	w1, [x1, #0x2c]
    112c: 3500fe81     	cbnz	w1, 0x30fc <___pl_fn_1+0x3028>
    1130: aa1c03e3     	mov	x3, x28
    1134: b9001878     	str	w24, [x3, #0x18]
    1138: 3400fa80     	cbz	w0, 0x3088 <___pl_fn_1+0x2fb4>
    113c: aa1c03e6     	mov	x6, x28
    1140: f9403cc1     	ldr	x1, [x6, #0x78]
    1144: 3758cd81     	tbnz	w1, #0xb, 0x2af4 <___pl_fn_1+0x2a20>
    1148: aa1c03ea     	mov	x10, x28
    114c: f9403941     	ldr	x1, [x10, #0x70]
    1150: f100003f     	cmp	x1, #0x0
    1154: 5400cd4d     	b.le	0x2afc <___pl_fn_1+0x2a28>
    1158: aa1c03ef     	mov	x15, x28
    115c: f94035e1     	ldr	x1, [x15, #0x68]
    1160: d2800123     	mov	x3, #0x9                ; =9
    1164: f100243f     	cmp	x1, #0x9
    1168: 5400cceb     	b.lt	0x2b04 <___pl_fn_1+0x2a30>
    116c: aa1c03e1     	mov	x1, x28
    1170: f9402821     	ldr	x1, [x1, #0x50]
    1174: aa1c03e2     	mov	x2, x28
    1178: f9402c42     	ldr	x2, [x2, #0x58]
    117c: 91002c24     	add	x4, x1, #0xb
    1180: eb02009f     	cmp	x4, x2
    1184: 5400cc48     	b.hi	0x2b0c <___pl_fn_1+0x2a38>
    1188: aa1c03e2     	mov	x2, x28
    118c: f9404442     	ldr	x2, [x2, #0x88]
    1190: aa1c03e4     	mov	x4, x28
    1194: f9404884     	ldr	x4, [x4, #0x90]
    1198: eb04005f     	cmp	x2, x4
    119c: 5400cbc2     	b.hs	0x2b14 <___pl_fn_1+0x2a40>
    11a0: aa1c03e4     	mov	x4, x28
    11a4: b9401c84     	ldr	w4, [x4, #0x1c]
    11a8: 6b04033f     	cmp	w25, w4
    11ac: 540002e9     	b.ls	0x1208 <___pl_fn_1+0x1134>
    11b0: 1400065b     	b	0x2b1c <___pl_fn_1+0x2a48>
    11b4: aa1c03e1     	mov	x1, x28
    11b8: f9401022     	ldr	x2, [x1, #0x20]
    11bc: 8b1a0841     	add	x1, x2, x26, lsl #2
    11c0: f94083e3     	ldr	x3, [sp, #0x100]
    11c4: b8385843     	str	w3, [x2, w24, uxtw #2]
    11c8: b9000436     	str	w22, [x1, #0x4]
    11cc: b9000833     	str	w19, [x1, #0x8]
    11d0: b9000c20     	str	w0, [x1, #0xc]
    11d4: aa0003fa     	mov	x26, x0
    11d8: aa1c03e0     	mov	x0, x28
    11dc: b9001819     	str	w25, [x0, #0x18]
    11e0: 52800741     	mov	w1, #0x3a               ; =58
    11e4: 52800002     	mov	w2, #0x0                ; =0
    11e8: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xf2c>
    11ec: f9400063     	ldr	x3, [x3]
    11f0: d63f0060     	blr	x3
    11f4: 3500f840     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    11f8: aa1c03e0     	mov	x0, x28
    11fc: f9401801     	ldr	x1, [x0, #0x30]
    1200: b9001818     	str	w24, [x0, #0x18]
    1204: 1400002e     	b	0x12bc <___pl_fn_1+0x11e8>
    1208: aa0003fa     	mov	x26, x0
    120c: aa1c03e0     	mov	x0, x28
    1210: f9403005     	ldr	x5, [x0, #0x60]
    1214: f9400006     	ldr	x6, [x0]
    1218: b20007e7     	mov	x7, #0x300000003        ; =12884901891
    121c: 2a0103e0     	mov	w0, w1
    1220: 8b000cc4     	add	x4, x6, x0, lsl #3
    1224: f82158c7     	str	x7, [x6, w1, uxtw #3]
    1228: 910004a5     	add	x5, x5, #0x1
    122c: f9000485     	str	x5, [x4, #0x8]
    1230: 92800006     	mov	x6, #-0x1               ; =-1
    1234: f9000886     	str	x6, [x4, #0x10]
    1238: d2800006     	mov	x6, #0x0                ; =0
    123c: f9000c86     	str	x6, [x4, #0x18]
    1240: f9001086     	str	x6, [x4, #0x20]
    1244: f9001486     	str	x6, [x4, #0x28]
    1248: f9001886     	str	x6, [x4, #0x30]
    124c: f9001c86     	str	x6, [x4, #0x38]
    1250: f9002086     	str	x6, [x4, #0x40]
    1254: f9002486     	str	x6, [x4, #0x48]
    1258: f9002886     	str	x6, [x4, #0x50]
    125c: aa1c03e4     	mov	x4, x28
    1260: f9003085     	str	x5, [x4, #0x60]
    1264: 91002c24     	add	x4, x1, #0xb
    1268: aa1c03e5     	mov	x5, x28
    126c: f90028a4     	str	x4, [x5, #0x50]
    1270: aa1c03e4     	mov	x4, x28
    1274: f9403484     	ldr	x4, [x4, #0x68]
    1278: d1002484     	sub	x4, x4, #0x9
    127c: f90034a4     	str	x4, [x5, #0x68]
    1280: aa1c03e4     	mov	x4, x28
    1284: f9403884     	ldr	x4, [x4, #0x70]
    1288: d1002484     	sub	x4, x4, #0x9
    128c: f90038a4     	str	x4, [x5, #0x70]
    1290: aa1c03e4     	mov	x4, x28
    1294: f9404085     	ldr	x5, [x4, #0x80]
    1298: d2c00166     	mov	x6, #0xb00000000        ; =47244640256
    129c: aa060006     	orr	x6, x0, x6
    12a0: d37cec47     	lsl	x7, x2, #4
    12a4: 8b0210a8     	add	x8, x5, x2, lsl #4
    12a8: f82768a6     	str	x6, [x5, x7]
    12ac: f9000503     	str	x3, [x8, #0x8]
    12b0: 91000447     	add	x7, x2, #0x1
    12b4: aa1c03e0     	mov	x0, x28
    12b8: f9004407     	str	x7, [x0, #0x88]
    12bc: aa1c03e0     	mov	x0, x28
    12c0: b9401818     	ldr	w24, [x0, #0x18]
    12c4: b9401c09     	ldr	w9, [x0, #0x1c]
    12c8: 1100170a     	add	w10, w24, #0x5
    12cc: 6b09015f     	cmp	w10, w9
    12d0: 5400ed88     	b.hi	0x3080 <___pl_fn_1+0x2fac>
    12d4: aa1c03e0     	mov	x0, x28
    12d8: f940100c     	ldr	x12, [x0, #0x20]
    12dc: 2a1803f9     	mov	w25, w24
    12e0: 8b19098b     	add	x11, x12, x25, lsl #2
    12e4: f94083e2     	ldr	x2, [sp, #0x100]
    12e8: b8385982     	str	w2, [x12, w24, uxtw #2]
    12ec: b9000576     	str	w22, [x11, #0x4]
    12f0: b9000973     	str	w19, [x11, #0x8]
    12f4: aa1a03e0     	mov	x0, x26
    12f8: b9000d60     	str	w0, [x11, #0xc]
    12fc: b9001161     	str	w1, [x11, #0x10]
    1300: 11001700     	add	w0, w24, #0x5
    1304: aa1c03e6     	mov	x6, x28
    1308: b90018c0     	str	w0, [x6, #0x18]
    130c: aa1c03e0     	mov	x0, x28
    1310: b9401000     	ldr	w0, [x0, #0x10]
    1314: aa1c03ea     	mov	x10, x28
    1318: b9401542     	ldr	w2, [x10, #0x14]
    131c: 6b02001f     	cmp	w0, w2
    1320: 5400eac2     	b.hs	0x3078 <___pl_fn_1+0x2fa4>
    1324: d28000a3     	mov	x3, #0x5                ; =5
    1328: d2807d04     	mov	x4, #0x3e8              ; =1000
    132c: aa1a03e2     	mov	x2, x26
    1330: aa1c03e0     	mov	x0, x28
    1334: 94000000     	bl	0x1334 <___pl_fn_1+0x1260>
    1338: aa1c03e1     	mov	x1, x28
    133c: b9402c21     	ldr	w1, [x1, #0x2c]
    1340: 3500ede1     	cbnz	w1, 0x30fc <___pl_fn_1+0x3028>
    1344: aa1c03e1     	mov	x1, x28
    1348: b9001838     	str	w24, [x1, #0x18]
    134c: 3400e920     	cbz	w0, 0x3070 <___pl_fn_1+0x2f9c>
    1350: aa1c03e1     	mov	x1, x28
    1354: f9403c21     	ldr	x1, [x1, #0x78]
    1358: 3758bf01     	tbnz	w1, #0xb, 0x2b38 <___pl_fn_1+0x2a64>
    135c: aa1c03e1     	mov	x1, x28
    1360: f9403821     	ldr	x1, [x1, #0x70]
    1364: f100003f     	cmp	x1, #0x0
    1368: 5400becd     	b.le	0x2b40 <___pl_fn_1+0x2a6c>
    136c: aa1c03e1     	mov	x1, x28
    1370: f9403421     	ldr	x1, [x1, #0x68]
    1374: d2800122     	mov	x2, #0x9                ; =9
    1378: f100243f     	cmp	x1, #0x9
    137c: 5400be6b     	b.lt	0x2b48 <___pl_fn_1+0x2a74>
    1380: aa1c03e1     	mov	x1, x28
    1384: f9402821     	ldr	x1, [x1, #0x50]
    1388: aa1c03e3     	mov	x3, x28
    138c: f9402c63     	ldr	x3, [x3, #0x58]
    1390: 91002c24     	add	x4, x1, #0xb
    1394: eb03009f     	cmp	x4, x3
    1398: 5400bdc8     	b.hi	0x2b50 <___pl_fn_1+0x2a7c>
    139c: aa1c03e3     	mov	x3, x28
    13a0: f9404463     	ldr	x3, [x3, #0x88]
    13a4: aa1c03e4     	mov	x4, x28
    13a8: f9404884     	ldr	x4, [x4, #0x90]
    13ac: eb04007f     	cmp	x3, x4
    13b0: 5400bd42     	b.hs	0x2b58 <___pl_fn_1+0x2a84>
    13b4: aa1c03e4     	mov	x4, x28
    13b8: b9401c84     	ldr	w4, [x4, #0x1c]
    13bc: 11001305     	add	w5, w24, #0x4
    13c0: 6b0400bf     	cmp	w5, w4
    13c4: 540002e9     	b.ls	0x1420 <___pl_fn_1+0x134c>
    13c8: 140005e6     	b	0x2b60 <___pl_fn_1+0x2a8c>
    13cc: aa1c03e2     	mov	x2, x28
    13d0: f9401043     	ldr	x3, [x2, #0x20]
    13d4: 8b190862     	add	x2, x3, x25, lsl #2
    13d8: f94083e4     	ldr	x4, [sp, #0x100]
    13dc: b8385864     	str	w4, [x3, w24, uxtw #2]
    13e0: b9000456     	str	w22, [x2, #0x4]
    13e4: b9000853     	str	w19, [x2, #0x8]
    13e8: b9000c40     	str	w0, [x2, #0xc]
    13ec: aa0003fa     	mov	x26, x0
    13f0: aa1c03e0     	mov	x0, x28
    13f4: b9001801     	str	w1, [x0, #0x18]
    13f8: 528007e1     	mov	w1, #0x3f               ; =63
    13fc: 52800002     	mov	w2, #0x0                ; =0
    1400: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xf2c>
    1404: f9400063     	ldr	x3, [x3]
    1408: d63f0060     	blr	x3
    140c: 3500e780     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    1410: aa1c03e0     	mov	x0, x28
    1414: f9401801     	ldr	x1, [x0, #0x30]
    1418: b9001818     	str	w24, [x0, #0x18]
    141c: 1400002e     	b	0x14d4 <___pl_fn_1+0x1400>
    1420: aa0003fa     	mov	x26, x0
    1424: aa1c03e0     	mov	x0, x28
    1428: f9403005     	ldr	x5, [x0, #0x60]
    142c: f9400006     	ldr	x6, [x0]
    1430: b20007e7     	mov	x7, #0x300000003        ; =12884901891
    1434: 2a0103e0     	mov	w0, w1
    1438: 8b000cc4     	add	x4, x6, x0, lsl #3
    143c: f82158c7     	str	x7, [x6, w1, uxtw #3]
    1440: 910004a5     	add	x5, x5, #0x1
    1444: f9000485     	str	x5, [x4, #0x8]
    1448: 92800006     	mov	x6, #-0x1               ; =-1
    144c: f9000886     	str	x6, [x4, #0x10]
    1450: d2800006     	mov	x6, #0x0                ; =0
    1454: f9000c86     	str	x6, [x4, #0x18]
    1458: f9001086     	str	x6, [x4, #0x20]
    145c: f9001486     	str	x6, [x4, #0x28]
    1460: f9001886     	str	x6, [x4, #0x30]
    1464: f9001c86     	str	x6, [x4, #0x38]
    1468: f9002086     	str	x6, [x4, #0x40]
    146c: f9002486     	str	x6, [x4, #0x48]
    1470: f9002886     	str	x6, [x4, #0x50]
    1474: aa1c03e4     	mov	x4, x28
    1478: f9003085     	str	x5, [x4, #0x60]
    147c: 91002c24     	add	x4, x1, #0xb
    1480: aa1c03e5     	mov	x5, x28
    1484: f90028a4     	str	x4, [x5, #0x50]
    1488: aa1c03e4     	mov	x4, x28
    148c: f9403484     	ldr	x4, [x4, #0x68]
    1490: d1002484     	sub	x4, x4, #0x9
    1494: f90034a4     	str	x4, [x5, #0x68]
    1498: aa1c03e4     	mov	x4, x28
    149c: f9403884     	ldr	x4, [x4, #0x70]
    14a0: d1002484     	sub	x4, x4, #0x9
    14a4: f90038a4     	str	x4, [x5, #0x70]
    14a8: aa1c03e4     	mov	x4, x28
    14ac: f9404084     	ldr	x4, [x4, #0x80]
    14b0: d2c00165     	mov	x5, #0xb00000000        ; =47244640256
    14b4: aa050005     	orr	x5, x0, x5
    14b8: d37cec66     	lsl	x6, x3, #4
    14bc: 8b031087     	add	x7, x4, x3, lsl #4
    14c0: f8266885     	str	x5, [x4, x6]
    14c4: f90004e2     	str	x2, [x7, #0x8]
    14c8: 91000466     	add	x6, x3, #0x1
    14cc: aa1c03e0     	mov	x0, x28
    14d0: f9004406     	str	x6, [x0, #0x88]
    14d4: aa1c03e0     	mov	x0, x28
    14d8: b9401818     	ldr	w24, [x0, #0x18]
    14dc: b9401c08     	ldr	w8, [x0, #0x1c]
    14e0: 11001709     	add	w9, w24, #0x5
    14e4: 6b08013f     	cmp	w9, w8
    14e8: 5400dc08     	b.hi	0x3068 <___pl_fn_1+0x2f94>
    14ec: aa1c03e0     	mov	x0, x28
    14f0: f940100b     	ldr	x11, [x0, #0x20]
    14f4: 2a1803f9     	mov	w25, w24
    14f8: 8b19096a     	add	x10, x11, x25, lsl #2
    14fc: f94083e2     	ldr	x2, [sp, #0x100]
    1500: b8385962     	str	w2, [x11, w24, uxtw #2]
    1504: b9000556     	str	w22, [x10, #0x4]
    1508: b9000953     	str	w19, [x10, #0x8]
    150c: aa1a03e0     	mov	x0, x26
    1510: b9000d40     	str	w0, [x10, #0xc]
    1514: b9001141     	str	w1, [x10, #0x10]
    1518: 1100170f     	add	w15, w24, #0x5
    151c: aa1c03e0     	mov	x0, x28
    1520: b900180f     	str	w15, [x0, #0x18]
    1524: b9401000     	ldr	w0, [x0, #0x10]
    1528: aa1c03e2     	mov	x2, x28
    152c: b9401442     	ldr	w2, [x2, #0x14]
    1530: 6b02001f     	cmp	w0, w2
    1534: 5400d962     	b.hs	0x3060 <___pl_fn_1+0x2f8c>
    1538: d28000a3     	mov	x3, #0x5                ; =5
    153c: d2807d04     	mov	x4, #0x3e8              ; =1000
    1540: aa1a03e2     	mov	x2, x26
    1544: aa1c03e0     	mov	x0, x28
    1548: 94000000     	bl	0x1548 <___pl_fn_1+0x1474>
    154c: aa0003fa     	mov	x26, x0
    1550: aa1c03e0     	mov	x0, x28
    1554: b9402c00     	ldr	w0, [x0, #0x2c]
    1558: 3500dd20     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    155c: aa1c03e0     	mov	x0, x28
    1560: b9001818     	str	w24, [x0, #0x18]
    1564: aa1a03e0     	mov	x0, x26
    1568: 3400d780     	cbz	w0, 0x3058 <___pl_fn_1+0x2f84>
    156c: aa1c03e0     	mov	x0, x28
    1570: f9403c00     	ldr	x0, [x0, #0x78]
    1574: 3768b060     	tbnz	w0, #0xd, 0x2b80 <___pl_fn_1+0x2aac>
    1578: aa1c03e0     	mov	x0, x28
    157c: f9403800     	ldr	x0, [x0, #0x70]
    1580: f100001f     	cmp	x0, #0x0
    1584: 5400b02d     	b.le	0x2b88 <___pl_fn_1+0x2ab4>
    1588: aa1c03e0     	mov	x0, x28
    158c: f9403400     	ldr	x0, [x0, #0x68]
    1590: d2800161     	mov	x1, #0xb                ; =11
    1594: f1002c1f     	cmp	x0, #0xb
    1598: 5400afcb     	b.lt	0x2b90 <___pl_fn_1+0x2abc>
    159c: aa1c03e0     	mov	x0, x28
    15a0: f9402800     	ldr	x0, [x0, #0x50]
    15a4: aa1c03e2     	mov	x2, x28
    15a8: f9402c42     	ldr	x2, [x2, #0x58]
    15ac: 91003403     	add	x3, x0, #0xd
    15b0: eb02007f     	cmp	x3, x2
    15b4: 5400af28     	b.hi	0x2b98 <___pl_fn_1+0x2ac4>
    15b8: aa1c03e4     	mov	x4, x28
    15bc: f9404482     	ldr	x2, [x4, #0x88]
    15c0: aa1c03e6     	mov	x6, x28
    15c4: f94048c3     	ldr	x3, [x6, #0x90]
    15c8: eb03005f     	cmp	x2, x3
    15cc: 5400aea2     	b.hs	0x2ba0 <___pl_fn_1+0x2acc>
    15d0: aa1c03eb     	mov	x11, x28
    15d4: b9401d63     	ldr	w3, [x11, #0x1c]
    15d8: 11001304     	add	w4, w24, #0x4
    15dc: 6b03009f     	cmp	w4, w3
    15e0: 54000349     	b.ls	0x1648 <___pl_fn_1+0x1574>
    15e4: 14000571     	b	0x2ba8 <___pl_fn_1+0x2ad4>
    15e8: aa1c03e1     	mov	x1, x28
    15ec: f9401022     	ldr	x2, [x1, #0x20]
    15f0: 8b190841     	add	x1, x2, x25, lsl #2
    15f4: f94083e3     	ldr	x3, [sp, #0x100]
    15f8: b8385843     	str	w3, [x2, w24, uxtw #2]
    15fc: b9000436     	str	w22, [x1, #0x4]
    1600: b9000833     	str	w19, [x1, #0x8]
    1604: aa1a03e2     	mov	x2, x26
    1608: b9000c22     	str	w2, [x1, #0xc]
    160c: aa1c03e1     	mov	x1, x28
    1610: b9001820     	str	w0, [x1, #0x18]
    1614: 52800881     	mov	w1, #0x44               ; =68
    1618: 52800082     	mov	w2, #0x4                ; =4
    161c: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xf2c>
    1620: f9400063     	ldr	x3, [x3]
    1624: aa1c03e0     	mov	x0, x28
    1628: d63f0060     	blr	x3
    162c: 3500d680     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    1630: aa1c03e0     	mov	x0, x28
    1634: f9401800     	ldr	x0, [x0, #0x30]
    1638: aa1c03e1     	mov	x1, x28
    163c: b9001838     	str	w24, [x1, #0x18]
    1640: aa0003e2     	mov	x2, x0
    1644: 14000033     	b	0x1710 <___pl_fn_1+0x163c>
    1648: aa1c03e3     	mov	x3, x28
    164c: f9403065     	ldr	x5, [x3, #0x60]
    1650: f9400066     	ldr	x6, [x3]
    1654: d28000e7     	mov	x7, #0x7                ; =7
    1658: f2c00067     	movk	x7, #0x3, lsl #32
    165c: 2a0003e3     	mov	w3, w0
    1660: 8b030cc4     	add	x4, x6, x3, lsl #3
    1664: f82058c7     	str	x7, [x6, w0, uxtw #3]
    1668: 910004a5     	add	x5, x5, #0x1
    166c: f9000485     	str	x5, [x4, #0x8]
    1670: 92800006     	mov	x6, #-0x1               ; =-1
    1674: f9000886     	str	x6, [x4, #0x10]
    1678: d2800006     	mov	x6, #0x0                ; =0
    167c: f9000c86     	str	x6, [x4, #0x18]
    1680: f9001086     	str	x6, [x4, #0x20]
    1684: f9001486     	str	x6, [x4, #0x28]
    1688: f9001886     	str	x6, [x4, #0x30]
    168c: f9001c97     	str	x23, [x4, #0x38]
    1690: f9002097     	str	x23, [x4, #0x40]
    1694: f9002497     	str	x23, [x4, #0x48]
    1698: f9002886     	str	x6, [x4, #0x50]
    169c: f9002c86     	str	x6, [x4, #0x58]
    16a0: f9003086     	str	x6, [x4, #0x60]
    16a4: aa1c03e6     	mov	x6, x28
    16a8: f90030c5     	str	x5, [x6, #0x60]
    16ac: 91003404     	add	x4, x0, #0xd
    16b0: aa1c03e8     	mov	x8, x28
    16b4: f9002904     	str	x4, [x8, #0x50]
    16b8: aa1c03ea     	mov	x10, x28
    16bc: f9403544     	ldr	x4, [x10, #0x68]
    16c0: d1002c84     	sub	x4, x4, #0xb
    16c4: aa1c03ed     	mov	x13, x28
    16c8: f90035a4     	str	x4, [x13, #0x68]
    16cc: aa1c03ef     	mov	x15, x28
    16d0: f94039e4     	ldr	x4, [x15, #0x70]
    16d4: d1002c84     	sub	x4, x4, #0xb
    16d8: aa1c03e5     	mov	x5, x28
    16dc: f90038a4     	str	x4, [x5, #0x70]
    16e0: aa1c03e4     	mov	x4, x28
    16e4: f9404085     	ldr	x5, [x4, #0x80]
    16e8: d2c001a6     	mov	x6, #0xd00000000        ; =55834574848
    16ec: aa060066     	orr	x6, x3, x6
    16f0: d37cec47     	lsl	x7, x2, #4
    16f4: 8b0210a8     	add	x8, x5, x2, lsl #4
    16f8: f82768a6     	str	x6, [x5, x7]
    16fc: f9000501     	str	x1, [x8, #0x8]
    1700: 91000447     	add	x7, x2, #0x1
    1704: aa1c03e1     	mov	x1, x28
    1708: f9004427     	str	x7, [x1, #0x88]
    170c: aa0003e2     	mov	x2, x0
    1710: 3400a5c2     	cbz	w2, 0x2bc8 <___pl_fn_1+0x2af4>
    1714: aa1c03e0     	mov	x0, x28
    1718: f9400000     	ldr	x0, [x0]
    171c: 2a0203e1     	mov	w1, w2
    1720: 8b010c00     	add	x0, x0, x1, lsl #3
    1724: f9002c14     	str	x20, [x0, #0x58]
    1728: 3400a682     	cbz	w2, 0x2bf8 <___pl_fn_1+0x2b24>
    172c: f9003014     	str	x20, [x0, #0x60]
    1730: aa1c03e0     	mov	x0, x28
    1734: b940181b     	ldr	w27, [x0, #0x18]
    1738: b9401c00     	ldr	w0, [x0, #0x1c]
    173c: 11001761     	add	w1, w27, #0x5
    1740: 6b00003f     	cmp	w1, w0
    1744: 5400c868     	b.hi	0x3050 <___pl_fn_1+0x2f7c>
    1748: aa1c03e0     	mov	x0, x28
    174c: f9401001     	ldr	x1, [x0, #0x20]
    1750: 2a1b03f8     	mov	w24, w27
    1754: 8b180820     	add	x0, x1, x24, lsl #2
    1758: f94083e3     	ldr	x3, [sp, #0x100]
    175c: b83b5823     	str	w3, [x1, w27, uxtw #2]
    1760: b9000416     	str	w22, [x0, #0x4]
    1764: b9000813     	str	w19, [x0, #0x8]
    1768: aa1a03e1     	mov	x1, x26
    176c: b9000c01     	str	w1, [x0, #0xc]
    1770: b9001002     	str	w2, [x0, #0x10]
    1774: 11001760     	add	w0, w27, #0x5
    1778: aa1c03e1     	mov	x1, x28
    177c: b9001820     	str	w0, [x1, #0x18]
    1780: aa1c03e0     	mov	x0, x28
    1784: b9401000     	ldr	w0, [x0, #0x10]
    1788: b9401421     	ldr	w1, [x1, #0x14]
    178c: 6b01001f     	cmp	w0, w1
    1790: 5400c5c2     	b.hs	0x3048 <___pl_fn_1+0x2f74>
    1794: d280fa04     	mov	x4, #0x7d0              ; =2000
    1798: 52800027     	mov	w7, #0x1                ; =1
    179c: aa0203e1     	mov	x1, x2
    17a0: f9408be3     	ldr	x3, [sp, #0x110]
    17a4: aa1a03e5     	mov	x5, x26
    17a8: aa1c03e0     	mov	x0, x28
    17ac: f94083e2     	ldr	x2, [sp, #0x100]
    17b0: aa0703e6     	mov	x6, x7
    17b4: 94000000     	bl	0x17b4 <___pl_fn_1+0x16e0>
    17b8: aa1c03e0     	mov	x0, x28
    17bc: b9402c00     	ldr	w0, [x0, #0x2c]
    17c0: 3500c9e0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    17c4: aa1c03e0     	mov	x0, x28
    17c8: b900181b     	str	w27, [x0, #0x18]
    17cc: f9403c00     	ldr	x0, [x0, #0x78]
    17d0: 3758a2c0     	tbnz	w0, #0xb, 0x2c28 <___pl_fn_1+0x2b54>
    17d4: aa1c03e0     	mov	x0, x28
    17d8: f9403800     	ldr	x0, [x0, #0x70]
    17dc: f100001f     	cmp	x0, #0x0
    17e0: 5400a28d     	b.le	0x2c30 <___pl_fn_1+0x2b5c>
    17e4: aa1c03e0     	mov	x0, x28
    17e8: f9403401     	ldr	x1, [x0, #0x68]
    17ec: d2800120     	mov	x0, #0x9                ; =9
    17f0: f100243f     	cmp	x1, #0x9
    17f4: 5400a22b     	b.lt	0x2c38 <___pl_fn_1+0x2b64>
    17f8: aa1c03e1     	mov	x1, x28
    17fc: f9402821     	ldr	x1, [x1, #0x50]
    1800: aa1c03e2     	mov	x2, x28
    1804: f9402c42     	ldr	x2, [x2, #0x58]
    1808: 91002c23     	add	x3, x1, #0xb
    180c: eb02007f     	cmp	x3, x2
    1810: 5400a188     	b.hi	0x2c40 <___pl_fn_1+0x2b6c>
    1814: aa1c03e2     	mov	x2, x28
    1818: f9404442     	ldr	x2, [x2, #0x88]
    181c: aa1c03e3     	mov	x3, x28
    1820: f9404863     	ldr	x3, [x3, #0x90]
    1824: eb03005f     	cmp	x2, x3
    1828: 5400a102     	b.hs	0x2c48 <___pl_fn_1+0x2b74>
    182c: aa1c03e4     	mov	x4, x28
    1830: b9401c83     	ldr	w3, [x4, #0x1c]
    1834: 11000f64     	add	w4, w27, #0x3
    1838: 6b03009f     	cmp	w4, w3
    183c: 540002c9     	b.ls	0x1894 <___pl_fn_1+0x17c0>
    1840: 14000504     	b	0x2c50 <___pl_fn_1+0x2b7c>
    1844: aa1c03ef     	mov	x15, x28
    1848: f94011e2     	ldr	x2, [x15, #0x20]
    184c: 8b180841     	add	x1, x2, x24, lsl #2
    1850: f94083e3     	ldr	x3, [sp, #0x100]
    1854: b83b5843     	str	w3, [x2, w27, uxtw #2]
    1858: b9000436     	str	w22, [x1, #0x4]
    185c: b9000833     	str	w19, [x1, #0x8]
    1860: aa1c03e1     	mov	x1, x28
    1864: b9001820     	str	w0, [x1, #0x18]
    1868: 52800981     	mov	w1, #0x4c               ; =76
    186c: 52800002     	mov	w2, #0x0                ; =0
    1870: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xf2c>
    1874: f9400063     	ldr	x3, [x3]
    1878: aa1c03e0     	mov	x0, x28
    187c: d63f0060     	blr	x3
    1880: 3500c3e0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    1884: aa1c03e0     	mov	x0, x28
    1888: f9401801     	ldr	x1, [x0, #0x30]
    188c: b900181b     	str	w27, [x0, #0x18]
    1890: 1400002d     	b	0x1944 <___pl_fn_1+0x1870>
    1894: aa1c03e3     	mov	x3, x28
    1898: f9403068     	ldr	x8, [x3, #0x60]
    189c: f9400069     	ldr	x9, [x3]
    18a0: b20007ea     	mov	x10, #0x300000003       ; =12884901891
    18a4: 2a0103e6     	mov	w6, w1
    18a8: 8b060d27     	add	x7, x9, x6, lsl #3
    18ac: f821592a     	str	x10, [x9, w1, uxtw #3]
    18b0: 91000508     	add	x8, x8, #0x1
    18b4: f90004e8     	str	x8, [x7, #0x8]
    18b8: 92800009     	mov	x9, #-0x1               ; =-1
    18bc: f90008e9     	str	x9, [x7, #0x10]
    18c0: d2800009     	mov	x9, #0x0                ; =0
    18c4: f9000ce9     	str	x9, [x7, #0x18]
    18c8: f90010e9     	str	x9, [x7, #0x20]
    18cc: f90014e9     	str	x9, [x7, #0x28]
    18d0: f90018e9     	str	x9, [x7, #0x30]
    18d4: f9001ce9     	str	x9, [x7, #0x38]
    18d8: f90020e9     	str	x9, [x7, #0x40]
    18dc: f90024e9     	str	x9, [x7, #0x48]
    18e0: f90028e9     	str	x9, [x7, #0x50]
    18e4: f9003068     	str	x8, [x3, #0x60]
    18e8: 91002c23     	add	x3, x1, #0xb
    18ec: aa1c03e4     	mov	x4, x28
    18f0: f9002883     	str	x3, [x4, #0x50]
    18f4: aa1c03e3     	mov	x3, x28
    18f8: f9403463     	ldr	x3, [x3, #0x68]
    18fc: d1002463     	sub	x3, x3, #0x9
    1900: f9003483     	str	x3, [x4, #0x68]
    1904: f9403883     	ldr	x3, [x4, #0x70]
    1908: d1002463     	sub	x3, x3, #0x9
    190c: aa1c03e7     	mov	x7, x28
    1910: f90038e3     	str	x3, [x7, #0x70]
    1914: aa1c03e9     	mov	x9, x28
    1918: f9404123     	ldr	x3, [x9, #0x80]
    191c: d2c00164     	mov	x4, #0xb00000000        ; =47244640256
    1920: aa0400c4     	orr	x4, x6, x4
    1924: d37cec45     	lsl	x5, x2, #4
    1928: 8b021066     	add	x6, x3, x2, lsl #4
    192c: f8256864     	str	x4, [x3, x5]
    1930: f90004c0     	str	x0, [x6, #0x8]
    1934: 91000440     	add	x0, x2, #0x1
    1938: aa1c03e2     	mov	x2, x28
    193c: f9004440     	str	x0, [x2, #0x88]
    1940: aa1c03e0     	mov	x0, x28
    1944: aa1c03e0     	mov	x0, x28
    1948: b9401819     	ldr	w25, [x0, #0x18]
    194c: b9401c00     	ldr	w0, [x0, #0x1c]
    1950: 1100133a     	add	w26, w25, #0x4
    1954: 6b00035f     	cmp	w26, w0
    1958: 5400b748     	b.hi	0x3040 <___pl_fn_1+0x2f6c>
    195c: aa1c03e0     	mov	x0, x28
    1960: f9401002     	ldr	x2, [x0, #0x20]
    1964: 2a1903fb     	mov	w27, w25
    1968: 8b1b0840     	add	x0, x2, x27, lsl #2
    196c: f94083e3     	ldr	x3, [sp, #0x100]
    1970: b8395843     	str	w3, [x2, w25, uxtw #2]
    1974: b9000416     	str	w22, [x0, #0x4]
    1978: b9000813     	str	w19, [x0, #0x8]
    197c: b9000c01     	str	w1, [x0, #0xc]
    1980: aa1c03e0     	mov	x0, x28
    1984: b900181a     	str	w26, [x0, #0x18]
    1988: b9401000     	ldr	w0, [x0, #0x10]
    198c: aa1c03e2     	mov	x2, x28
    1990: b9401442     	ldr	w2, [x2, #0x14]
    1994: 6b02001f     	cmp	w0, w2
    1998: 5400b502     	b.hs	0x3038 <___pl_fn_1+0x2f64>
    199c: d28000c3     	mov	x3, #0x6                ; =6
    19a0: d2807d04     	mov	x4, #0x3e8              ; =1000
    19a4: aa1c03e0     	mov	x0, x28
    19a8: aa1603e2     	mov	x2, x22
    19ac: 94000000     	bl	0x19ac <___pl_fn_1+0x18d8>
    19b0: aa1c03e1     	mov	x1, x28
    19b4: b9402c21     	ldr	w1, [x1, #0x2c]
    19b8: 3500ba21     	cbnz	w1, 0x30fc <___pl_fn_1+0x3028>
    19bc: aa1c03e1     	mov	x1, x28
    19c0: b9001839     	str	w25, [x1, #0x18]
    19c4: 3400b360     	cbz	w0, 0x3030 <___pl_fn_1+0x2f5c>
    19c8: aa1c03e1     	mov	x1, x28
    19cc: f9403c21     	ldr	x1, [x1, #0x78]
    19d0: 37589501     	tbnz	w1, #0xb, 0x2c70 <___pl_fn_1+0x2b9c>
    19d4: aa1c03e1     	mov	x1, x28
    19d8: f9403821     	ldr	x1, [x1, #0x70]
    19dc: f100003f     	cmp	x1, #0x0
    19e0: 540094cd     	b.le	0x2c78 <___pl_fn_1+0x2ba4>
    19e4: aa1c03e1     	mov	x1, x28
    19e8: f9403421     	ldr	x1, [x1, #0x68]
    19ec: d2800123     	mov	x3, #0x9                ; =9
    19f0: f100243f     	cmp	x1, #0x9
    19f4: 5400946b     	b.lt	0x2c80 <___pl_fn_1+0x2bac>
    19f8: aa1c03e6     	mov	x6, x28
    19fc: f94028c1     	ldr	x1, [x6, #0x50]
    1a00: aa1c03e8     	mov	x8, x28
    1a04: f9402d02     	ldr	x2, [x8, #0x58]
    1a08: 91002c24     	add	x4, x1, #0xb
    1a0c: eb02009f     	cmp	x4, x2
    1a10: 540093c8     	b.hi	0x2c88 <___pl_fn_1+0x2bb4>
    1a14: aa1c03ee     	mov	x14, x28
    1a18: f94045c2     	ldr	x2, [x14, #0x88]
    1a1c: aa1c03e4     	mov	x4, x28
    1a20: f9404884     	ldr	x4, [x4, #0x90]
    1a24: eb04005f     	cmp	x2, x4
    1a28: 54009342     	b.hs	0x2c90 <___pl_fn_1+0x2bbc>
    1a2c: aa1c03e4     	mov	x4, x28
    1a30: b9401c84     	ldr	w4, [x4, #0x1c]
    1a34: 6b04035f     	cmp	w26, w4
    1a38: 540002e9     	b.ls	0x1a94 <___pl_fn_1+0x19c0>
    1a3c: 14000497     	b	0x2c98 <___pl_fn_1+0x2bc4>
    1a40: aa1c03e1     	mov	x1, x28
    1a44: f9401022     	ldr	x2, [x1, #0x20]
    1a48: 8b1b0841     	add	x1, x2, x27, lsl #2
    1a4c: f94083e3     	ldr	x3, [sp, #0x100]
    1a50: b8395843     	str	w3, [x2, w25, uxtw #2]
    1a54: b9000436     	str	w22, [x1, #0x4]
    1a58: b9000833     	str	w19, [x1, #0x8]
    1a5c: b9000c20     	str	w0, [x1, #0xc]
    1a60: aa0003fb     	mov	x27, x0
    1a64: aa1c03e0     	mov	x0, x28
    1a68: b900181a     	str	w26, [x0, #0x18]
    1a6c: 52800a21     	mov	w1, #0x51               ; =81
    1a70: 52800002     	mov	w2, #0x0                ; =0
    1a74: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xf2c>
    1a78: f9400063     	ldr	x3, [x3]
    1a7c: d63f0060     	blr	x3
    1a80: 3500b3e0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    1a84: aa1c03e0     	mov	x0, x28
    1a88: f9401801     	ldr	x1, [x0, #0x30]
    1a8c: b9001819     	str	w25, [x0, #0x18]
    1a90: 1400002f     	b	0x1b4c <___pl_fn_1+0x1a78>
    1a94: aa0003fb     	mov	x27, x0
    1a98: aa1c03e0     	mov	x0, x28
    1a9c: f9403006     	ldr	x6, [x0, #0x60]
    1aa0: f9400007     	ldr	x7, [x0]
    1aa4: b20007e8     	mov	x8, #0x300000003        ; =12884901891
    1aa8: 2a0103e4     	mov	w4, w1
    1aac: 8b040ce5     	add	x5, x7, x4, lsl #3
    1ab0: f82158e8     	str	x8, [x7, w1, uxtw #3]
    1ab4: 910004c6     	add	x6, x6, #0x1
    1ab8: f90004a6     	str	x6, [x5, #0x8]
    1abc: 92800007     	mov	x7, #-0x1               ; =-1
    1ac0: f90008a7     	str	x7, [x5, #0x10]
    1ac4: d2800007     	mov	x7, #0x0                ; =0
    1ac8: f9000ca7     	str	x7, [x5, #0x18]
    1acc: f90010a7     	str	x7, [x5, #0x20]
    1ad0: f90014a7     	str	x7, [x5, #0x28]
    1ad4: f90018a7     	str	x7, [x5, #0x30]
    1ad8: f9001ca7     	str	x7, [x5, #0x38]
    1adc: f90020a7     	str	x7, [x5, #0x40]
    1ae0: f90024a7     	str	x7, [x5, #0x48]
    1ae4: f90028a7     	str	x7, [x5, #0x50]
    1ae8: f9003006     	str	x6, [x0, #0x60]
    1aec: 91002c20     	add	x0, x1, #0xb
    1af0: aa1c03ed     	mov	x13, x28
    1af4: f90029a0     	str	x0, [x13, #0x50]
    1af8: aa1c03e0     	mov	x0, x28
    1afc: f9403400     	ldr	x0, [x0, #0x68]
    1b00: d1002400     	sub	x0, x0, #0x9
    1b04: aa1c03e5     	mov	x5, x28
    1b08: f90034a0     	str	x0, [x5, #0x68]
    1b0c: aa1c03e0     	mov	x0, x28
    1b10: f9403800     	ldr	x0, [x0, #0x70]
    1b14: d1002400     	sub	x0, x0, #0x9
    1b18: f90038a0     	str	x0, [x5, #0x70]
    1b1c: aa1c03e0     	mov	x0, x28
    1b20: f9404000     	ldr	x0, [x0, #0x80]
    1b24: d2c00165     	mov	x5, #0xb00000000        ; =47244640256
    1b28: aa050084     	orr	x4, x4, x5
    1b2c: d37cec45     	lsl	x5, x2, #4
    1b30: 8b021006     	add	x6, x0, x2, lsl #4
    1b34: f8256804     	str	x4, [x0, x5]
    1b38: f90004c3     	str	x3, [x6, #0x8]
    1b3c: 91000440     	add	x0, x2, #0x1
    1b40: aa1c03e2     	mov	x2, x28
    1b44: f9004440     	str	x0, [x2, #0x88]
    1b48: aa1c03e0     	mov	x0, x28
    1b4c: aa1c03e0     	mov	x0, x28
    1b50: b9401818     	ldr	w24, [x0, #0x18]
    1b54: b9401c00     	ldr	w0, [x0, #0x1c]
    1b58: 11001702     	add	w2, w24, #0x5
    1b5c: 6b00005f     	cmp	w2, w0
    1b60: 5400a648     	b.hi	0x3028 <___pl_fn_1+0x2f54>
    1b64: aa1c03e0     	mov	x0, x28
    1b68: f9401002     	ldr	x2, [x0, #0x20]
    1b6c: 2a1803f9     	mov	w25, w24
    1b70: 8b190840     	add	x0, x2, x25, lsl #2
    1b74: f94083e3     	ldr	x3, [sp, #0x100]
    1b78: b8385843     	str	w3, [x2, w24, uxtw #2]
    1b7c: b9000416     	str	w22, [x0, #0x4]
    1b80: b9000813     	str	w19, [x0, #0x8]
    1b84: aa1b03e2     	mov	x2, x27
    1b88: b9000c02     	str	w2, [x0, #0xc]
    1b8c: b9001001     	str	w1, [x0, #0x10]
    1b90: 11001700     	add	w0, w24, #0x5
    1b94: aa1c03e2     	mov	x2, x28
    1b98: b9001840     	str	w0, [x2, #0x18]
    1b9c: aa1c03e0     	mov	x0, x28
    1ba0: b9401000     	ldr	w0, [x0, #0x10]
    1ba4: b9401442     	ldr	w2, [x2, #0x14]
    1ba8: 6b02001f     	cmp	w0, w2
    1bac: 5400a3a2     	b.hs	0x3020 <___pl_fn_1+0x2f4c>
    1bb0: d28000c3     	mov	x3, #0x6                ; =6
    1bb4: d2807d04     	mov	x4, #0x3e8              ; =1000
    1bb8: aa1b03e2     	mov	x2, x27
    1bbc: aa1c03e0     	mov	x0, x28
    1bc0: 94000000     	bl	0x1bc0 <___pl_fn_1+0x1aec>
    1bc4: aa1c03e2     	mov	x2, x28
    1bc8: b9402c41     	ldr	w1, [x2, #0x2c]
    1bcc: 3500a981     	cbnz	w1, 0x30fc <___pl_fn_1+0x3028>
    1bd0: aa1c03e6     	mov	x6, x28
    1bd4: b90018d8     	str	w24, [x6, #0x18]
    1bd8: 3400a200     	cbz	w0, 0x3018 <___pl_fn_1+0x2f44>
    1bdc: aa1c03e9     	mov	x9, x28
    1be0: f9403d21     	ldr	x1, [x9, #0x78]
    1be4: 37588681     	tbnz	w1, #0xb, 0x2cb4 <___pl_fn_1+0x2be0>
    1be8: aa1c03ed     	mov	x13, x28
    1bec: f94039a1     	ldr	x1, [x13, #0x70]
    1bf0: f100003f     	cmp	x1, #0x0
    1bf4: 5400864d     	b.le	0x2cbc <___pl_fn_1+0x2be8>
    1bf8: aa1c03e1     	mov	x1, x28
    1bfc: f9403421     	ldr	x1, [x1, #0x68]
    1c00: d2800122     	mov	x2, #0x9                ; =9
    1c04: f100243f     	cmp	x1, #0x9
    1c08: 540085eb     	b.lt	0x2cc4 <___pl_fn_1+0x2bf0>
    1c0c: aa1c03e1     	mov	x1, x28
    1c10: f9402821     	ldr	x1, [x1, #0x50]
    1c14: aa1c03e3     	mov	x3, x28
    1c18: f9402c63     	ldr	x3, [x3, #0x58]
    1c1c: 91002c24     	add	x4, x1, #0xb
    1c20: eb03009f     	cmp	x4, x3
    1c24: 54008548     	b.hi	0x2ccc <___pl_fn_1+0x2bf8>
    1c28: aa1c03e3     	mov	x3, x28
    1c2c: f9404463     	ldr	x3, [x3, #0x88]
    1c30: aa1c03e4     	mov	x4, x28
    1c34: f9404884     	ldr	x4, [x4, #0x90]
    1c38: eb04007f     	cmp	x3, x4
    1c3c: 540084c2     	b.hs	0x2cd4 <___pl_fn_1+0x2c00>
    1c40: aa1c03e4     	mov	x4, x28
    1c44: b9401c84     	ldr	w4, [x4, #0x1c]
    1c48: 11001305     	add	w5, w24, #0x4
    1c4c: 6b0400bf     	cmp	w5, w4
    1c50: 540002e9     	b.ls	0x1cac <___pl_fn_1+0x1bd8>
    1c54: 14000422     	b	0x2cdc <___pl_fn_1+0x2c08>
    1c58: aa1c03e2     	mov	x2, x28
    1c5c: f9401043     	ldr	x3, [x2, #0x20]
    1c60: 8b190862     	add	x2, x3, x25, lsl #2
    1c64: f94083e4     	ldr	x4, [sp, #0x100]
    1c68: b8385864     	str	w4, [x3, w24, uxtw #2]
    1c6c: b9000456     	str	w22, [x2, #0x4]
    1c70: b9000853     	str	w19, [x2, #0x8]
    1c74: b9000c40     	str	w0, [x2, #0xc]
    1c78: aa0003fa     	mov	x26, x0
    1c7c: aa1c03e0     	mov	x0, x28
    1c80: b9001801     	str	w1, [x0, #0x18]
    1c84: 52800ac1     	mov	w1, #0x56               ; =86
    1c88: 52800002     	mov	w2, #0x0                ; =0
    1c8c: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xf2c>
    1c90: f9400063     	ldr	x3, [x3]
    1c94: d63f0060     	blr	x3
    1c98: 3500a320     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    1c9c: aa1c03e0     	mov	x0, x28
    1ca0: f9401801     	ldr	x1, [x0, #0x30]
    1ca4: b9001818     	str	w24, [x0, #0x18]
    1ca8: 1400002d     	b	0x1d5c <___pl_fn_1+0x1c88>
    1cac: aa0003fa     	mov	x26, x0
    1cb0: aa1c03e0     	mov	x0, x28
    1cb4: f9403006     	ldr	x6, [x0, #0x60]
    1cb8: f9400007     	ldr	x7, [x0]
    1cbc: b20007e8     	mov	x8, #0x300000003        ; =12884901891
    1cc0: 2a0103e4     	mov	w4, w1
    1cc4: 8b040ce5     	add	x5, x7, x4, lsl #3
    1cc8: f82158e8     	str	x8, [x7, w1, uxtw #3]
    1ccc: 910004c6     	add	x6, x6, #0x1
    1cd0: f90004a6     	str	x6, [x5, #0x8]
    1cd4: 92800007     	mov	x7, #-0x1               ; =-1
    1cd8: f90008a7     	str	x7, [x5, #0x10]
    1cdc: d2800007     	mov	x7, #0x0                ; =0
    1ce0: f9000ca7     	str	x7, [x5, #0x18]
    1ce4: f90010a7     	str	x7, [x5, #0x20]
    1ce8: f90014a7     	str	x7, [x5, #0x28]
    1cec: f90018a7     	str	x7, [x5, #0x30]
    1cf0: f9001ca7     	str	x7, [x5, #0x38]
    1cf4: f90020a7     	str	x7, [x5, #0x40]
    1cf8: f90024a7     	str	x7, [x5, #0x48]
    1cfc: f90028a7     	str	x7, [x5, #0x50]
    1d00: f9003006     	str	x6, [x0, #0x60]
    1d04: 91002c2f     	add	x15, x1, #0xb
    1d08: f900280f     	str	x15, [x0, #0x50]
    1d0c: f9403400     	ldr	x0, [x0, #0x68]
    1d10: d1002400     	sub	x0, x0, #0x9
    1d14: aa1c03e5     	mov	x5, x28
    1d18: f90034a0     	str	x0, [x5, #0x68]
    1d1c: aa1c03e0     	mov	x0, x28
    1d20: f9403800     	ldr	x0, [x0, #0x70]
    1d24: d1002400     	sub	x0, x0, #0x9
    1d28: f90038a0     	str	x0, [x5, #0x70]
    1d2c: aa1c03e0     	mov	x0, x28
    1d30: f9404000     	ldr	x0, [x0, #0x80]
    1d34: d2c00165     	mov	x5, #0xb00000000        ; =47244640256
    1d38: aa050084     	orr	x4, x4, x5
    1d3c: d37cec65     	lsl	x5, x3, #4
    1d40: 8b031006     	add	x6, x0, x3, lsl #4
    1d44: f8256804     	str	x4, [x0, x5]
    1d48: f90004c2     	str	x2, [x6, #0x8]
    1d4c: 91000460     	add	x0, x3, #0x1
    1d50: aa1c03e2     	mov	x2, x28
    1d54: f9004440     	str	x0, [x2, #0x88]
    1d58: aa1c03e0     	mov	x0, x28
    1d5c: aa1c03e0     	mov	x0, x28
    1d60: b9401818     	ldr	w24, [x0, #0x18]
    1d64: b9401c00     	ldr	w0, [x0, #0x1c]
    1d68: 11001702     	add	w2, w24, #0x5
    1d6c: 6b00005f     	cmp	w2, w0
    1d70: 54009508     	b.hi	0x3010 <___pl_fn_1+0x2f3c>
    1d74: aa1c03e0     	mov	x0, x28
    1d78: f9401002     	ldr	x2, [x0, #0x20]
    1d7c: 2a1803f9     	mov	w25, w24
    1d80: 8b190840     	add	x0, x2, x25, lsl #2
    1d84: f94083e3     	ldr	x3, [sp, #0x100]
    1d88: b8385843     	str	w3, [x2, w24, uxtw #2]
    1d8c: b9000416     	str	w22, [x0, #0x4]
    1d90: b9000813     	str	w19, [x0, #0x8]
    1d94: aa1a03ed     	mov	x13, x26
    1d98: b9000c0d     	str	w13, [x0, #0xc]
    1d9c: b9001001     	str	w1, [x0, #0x10]
    1da0: 11001700     	add	w0, w24, #0x5
    1da4: aa1c03eb     	mov	x11, x28
    1da8: b9001960     	str	w0, [x11, #0x18]
    1dac: aa1c03e0     	mov	x0, x28
    1db0: b9401000     	ldr	w0, [x0, #0x10]
    1db4: aa1c03ef     	mov	x15, x28
    1db8: b94015e2     	ldr	w2, [x15, #0x14]
    1dbc: 6b02001f     	cmp	w0, w2
    1dc0: 54009242     	b.hs	0x3008 <___pl_fn_1+0x2f34>
    1dc4: d28000c3     	mov	x3, #0x6                ; =6
    1dc8: d2807d04     	mov	x4, #0x3e8              ; =1000
    1dcc: aa1a03e2     	mov	x2, x26
    1dd0: aa1c03e0     	mov	x0, x28
    1dd4: 94000000     	bl	0x1dd4 <___pl_fn_1+0x1d00>
    1dd8: aa0003fa     	mov	x26, x0
    1ddc: aa1c03e0     	mov	x0, x28
    1de0: b9402c00     	ldr	w0, [x0, #0x2c]
    1de4: 350098c0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    1de8: aa1c03e0     	mov	x0, x28
    1dec: b9001818     	str	w24, [x0, #0x18]
    1df0: aa1a03e0     	mov	x0, x26
    1df4: 34009060     	cbz	w0, 0x3000 <___pl_fn_1+0x2f2c>
    1df8: aa1c03e0     	mov	x0, x28
    1dfc: f9403c00     	ldr	x0, [x0, #0x78]
    1e00: 376877e0     	tbnz	w0, #0xd, 0x2cfc <___pl_fn_1+0x2c28>
    1e04: aa1c03e0     	mov	x0, x28
    1e08: f9403800     	ldr	x0, [x0, #0x70]
    1e0c: f100001f     	cmp	x0, #0x0
    1e10: 540077ad     	b.le	0x2d04 <___pl_fn_1+0x2c30>
    1e14: aa1c03e0     	mov	x0, x28
    1e18: f9403400     	ldr	x0, [x0, #0x68]
    1e1c: d2800161     	mov	x1, #0xb                ; =11
    1e20: f1002c1f     	cmp	x0, #0xb
    1e24: 5400774b     	b.lt	0x2d0c <___pl_fn_1+0x2c38>
    1e28: aa1c03e0     	mov	x0, x28
    1e2c: f9402800     	ldr	x0, [x0, #0x50]
    1e30: aa1c03e2     	mov	x2, x28
    1e34: f9402c42     	ldr	x2, [x2, #0x58]
    1e38: 91003403     	add	x3, x0, #0xd
    1e3c: eb02007f     	cmp	x3, x2
    1e40: 540076a8     	b.hi	0x2d14 <___pl_fn_1+0x2c40>
    1e44: aa1c03e2     	mov	x2, x28
    1e48: f9404442     	ldr	x2, [x2, #0x88]
    1e4c: aa1c03e3     	mov	x3, x28
    1e50: f9404863     	ldr	x3, [x3, #0x90]
    1e54: eb03005f     	cmp	x2, x3
    1e58: 54007622     	b.hs	0x2d1c <___pl_fn_1+0x2c48>
    1e5c: aa1c03e3     	mov	x3, x28
    1e60: b9401c63     	ldr	w3, [x3, #0x1c]
    1e64: 11001304     	add	w4, w24, #0x4
    1e68: 6b03009f     	cmp	w4, w3
    1e6c: 54000349     	b.ls	0x1ed4 <___pl_fn_1+0x1e00>
    1e70: 140003ad     	b	0x2d24 <___pl_fn_1+0x2c50>
    1e74: aa1c03e7     	mov	x7, x28
    1e78: f94010e2     	ldr	x2, [x7, #0x20]
    1e7c: 8b190841     	add	x1, x2, x25, lsl #2
    1e80: f94083e3     	ldr	x3, [sp, #0x100]
    1e84: b8385843     	str	w3, [x2, w24, uxtw #2]
    1e88: b9000436     	str	w22, [x1, #0x4]
    1e8c: b9000833     	str	w19, [x1, #0x8]
    1e90: aa1a03e2     	mov	x2, x26
    1e94: b9000c22     	str	w2, [x1, #0xc]
    1e98: aa1c03ee     	mov	x14, x28
    1e9c: b90019c0     	str	w0, [x14, #0x18]
    1ea0: 52800b61     	mov	w1, #0x5b               ; =91
    1ea4: 52800082     	mov	w2, #0x4                ; =4
    1ea8: 90000003     	adrp	x3, 0x1000 <___pl_fn_1+0xf2c>
    1eac: f9400063     	ldr	x3, [x3]
    1eb0: aa1c03e0     	mov	x0, x28
    1eb4: d63f0060     	blr	x3
    1eb8: 35009220     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    1ebc: aa1c03e0     	mov	x0, x28
    1ec0: f9401800     	ldr	x0, [x0, #0x30]
    1ec4: aa1c03e1     	mov	x1, x28
    1ec8: b9001838     	str	w24, [x1, #0x18]
    1ecc: aa0003e2     	mov	x2, x0
    1ed0: 14000030     	b	0x1f90 <___pl_fn_1+0x1ebc>
    1ed4: aa1c03e3     	mov	x3, x28
    1ed8: f9403065     	ldr	x5, [x3, #0x60]
    1edc: f9400066     	ldr	x6, [x3]
    1ee0: d28000e7     	mov	x7, #0x7                ; =7
    1ee4: f2c00067     	movk	x7, #0x3, lsl #32
    1ee8: 2a0003e3     	mov	w3, w0
    1eec: 8b030cc4     	add	x4, x6, x3, lsl #3
    1ef0: f82058c7     	str	x7, [x6, w0, uxtw #3]
    1ef4: 910004a5     	add	x5, x5, #0x1
    1ef8: f9000485     	str	x5, [x4, #0x8]
    1efc: 92800006     	mov	x6, #-0x1               ; =-1
    1f00: f9000886     	str	x6, [x4, #0x10]
    1f04: d2800006     	mov	x6, #0x0                ; =0
    1f08: f9000c86     	str	x6, [x4, #0x18]
    1f0c: f9001086     	str	x6, [x4, #0x20]
    1f10: f9001486     	str	x6, [x4, #0x28]
    1f14: f9001886     	str	x6, [x4, #0x30]
    1f18: f9001c97     	str	x23, [x4, #0x38]
    1f1c: f9002097     	str	x23, [x4, #0x40]
    1f20: f9002497     	str	x23, [x4, #0x48]
    1f24: f9002886     	str	x6, [x4, #0x50]
    1f28: f9002c86     	str	x6, [x4, #0x58]
    1f2c: f9003086     	str	x6, [x4, #0x60]
    1f30: aa1c03e4     	mov	x4, x28
    1f34: f9003085     	str	x5, [x4, #0x60]
    1f38: 91003404     	add	x4, x0, #0xd
    1f3c: aa1c03e5     	mov	x5, x28
    1f40: f90028a4     	str	x4, [x5, #0x50]
    1f44: aa1c03e4     	mov	x4, x28
    1f48: f9403484     	ldr	x4, [x4, #0x68]
    1f4c: d1002c84     	sub	x4, x4, #0xb
    1f50: f90034a4     	str	x4, [x5, #0x68]
    1f54: aa1c03e4     	mov	x4, x28
    1f58: f9403884     	ldr	x4, [x4, #0x70]
    1f5c: d1002c84     	sub	x4, x4, #0xb
    1f60: f90038a4     	str	x4, [x5, #0x70]
    1f64: f94040a4     	ldr	x4, [x5, #0x80]
    1f68: d2c001a5     	mov	x5, #0xd00000000        ; =55834574848
    1f6c: aa050063     	orr	x3, x3, x5
    1f70: d37cec45     	lsl	x5, x2, #4
    1f74: 8b021086     	add	x6, x4, x2, lsl #4
    1f78: f8256883     	str	x3, [x4, x5]
    1f7c: f90004c1     	str	x1, [x6, #0x8]
    1f80: 91000441     	add	x1, x2, #0x1
    1f84: aa1c03ee     	mov	x14, x28
    1f88: f90045c1     	str	x1, [x14, #0x88]
    1f8c: aa0003e2     	mov	x2, x0
    1f90: 34006da2     	cbz	w2, 0x2d44 <___pl_fn_1+0x2c70>
    1f94: aa1c03e0     	mov	x0, x28
    1f98: f9400000     	ldr	x0, [x0]
    1f9c: 2a0203e1     	mov	w1, w2
    1fa0: 8b010c00     	add	x0, x0, x1, lsl #3
    1fa4: f9002c14     	str	x20, [x0, #0x58]
    1fa8: 34006e62     	cbz	w2, 0x2d74 <___pl_fn_1+0x2ca0>
    1fac: f9003014     	str	x20, [x0, #0x60]
    1fb0: aa1c03e0     	mov	x0, x28
    1fb4: b9401818     	ldr	w24, [x0, #0x18]
    1fb8: b9401c00     	ldr	w0, [x0, #0x1c]
    1fbc: 11001701     	add	w1, w24, #0x5
    1fc0: 6b00003f     	cmp	w1, w0
    1fc4: 540081a8     	b.hi	0x2ff8 <___pl_fn_1+0x2f24>
    1fc8: aa1c03e0     	mov	x0, x28
    1fcc: f9401001     	ldr	x1, [x0, #0x20]
    1fd0: 2a1803f9     	mov	w25, w24
    1fd4: 8b190820     	add	x0, x1, x25, lsl #2
    1fd8: f94083e3     	ldr	x3, [sp, #0x100]
    1fdc: b8385823     	str	w3, [x1, w24, uxtw #2]
    1fe0: b9000416     	str	w22, [x0, #0x4]
    1fe4: b9000813     	str	w19, [x0, #0x8]
    1fe8: aa1a03e1     	mov	x1, x26
    1fec: b9000c01     	str	w1, [x0, #0xc]
    1ff0: b9001002     	str	w2, [x0, #0x10]
    1ff4: 11001700     	add	w0, w24, #0x5
    1ff8: aa1c03e5     	mov	x5, x28
    1ffc: b90018a0     	str	w0, [x5, #0x18]
    2000: aa1c03e0     	mov	x0, x28
    2004: b9401000     	ldr	w0, [x0, #0x10]
    2008: aa1c03e9     	mov	x9, x28
    200c: b9401521     	ldr	w1, [x9, #0x14]
    2010: 6b01001f     	cmp	w0, w1
    2014: 54007ee2     	b.hs	0x2ff0 <___pl_fn_1+0x2f1c>
    2018: d2800083     	mov	x3, #0x4                ; =4
    201c: d2817704     	mov	x4, #0xbb8              ; =3000
    2020: 52800027     	mov	w7, #0x1                ; =1
    2024: aa0203e1     	mov	x1, x2
    2028: aa1a03e5     	mov	x5, x26
    202c: aa1c03e0     	mov	x0, x28
    2030: f94083e2     	ldr	x2, [sp, #0x100]
    2034: aa0703e6     	mov	x6, x7
    2038: 94000000     	bl	0x2038 <___pl_fn_1+0x1f64>
    203c: aa1c03e0     	mov	x0, x28
    2040: b9402c00     	ldr	w0, [x0, #0x2c]
    2044: 350085c0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2048: aa1c03e0     	mov	x0, x28
    204c: b9001818     	str	w24, [x0, #0x18]
    2050: f9403c00     	ldr	x0, [x0, #0x78]
    2054: 37606a80     	tbnz	w0, #0xc, 0x2da4 <___pl_fn_1+0x2cd0>
    2058: aa1c03e0     	mov	x0, x28
    205c: f9403800     	ldr	x0, [x0, #0x70]
    2060: f100001f     	cmp	x0, #0x0
    2064: 54006a4d     	b.le	0x2dac <___pl_fn_1+0x2cd8>
    2068: aa1c03e0     	mov	x0, x28
    206c: f9403400     	ldr	x0, [x0, #0x68]
    2070: d2800141     	mov	x1, #0xa                ; =10
    2074: f100281f     	cmp	x0, #0xa
    2078: 540069eb     	b.lt	0x2db4 <___pl_fn_1+0x2ce0>
    207c: aa1c03e0     	mov	x0, x28
    2080: f9402800     	ldr	x0, [x0, #0x50]
    2084: aa1c03e2     	mov	x2, x28
    2088: f9402c42     	ldr	x2, [x2, #0x58]
    208c: 91003003     	add	x3, x0, #0xc
    2090: eb02007f     	cmp	x3, x2
    2094: 54006948     	b.hi	0x2dbc <___pl_fn_1+0x2ce8>
    2098: aa1c03e2     	mov	x2, x28
    209c: f9404443     	ldr	x3, [x2, #0x88]
    20a0: f9404844     	ldr	x4, [x2, #0x90]
    20a4: eb04007f     	cmp	x3, x4
    20a8: 540068e2     	b.hs	0x2dc4 <___pl_fn_1+0x2cf0>
    20ac: aa1c03e2     	mov	x2, x28
    20b0: b9401c46     	ldr	w6, [x2, #0x1c]
    20b4: 11000f07     	add	w7, w24, #0x3
    20b8: 6b0600ff     	cmp	w7, w6
    20bc: 540002c9     	b.ls	0x2114 <___pl_fn_1+0x2040>
    20c0: 14000343     	b	0x2dcc <___pl_fn_1+0x2cf8>
    20c4: aa1c03e0     	mov	x0, x28
    20c8: f940100c     	ldr	x12, [x0, #0x20]
    20cc: 8b19098b     	add	x11, x12, x25, lsl #2
    20d0: f94083e0     	ldr	x0, [sp, #0x100]
    20d4: b8385980     	str	w0, [x12, w24, uxtw #2]
    20d8: b9000576     	str	w22, [x11, #0x4]
    20dc: b9000973     	str	w19, [x11, #0x8]
    20e0: aa1c03e0     	mov	x0, x28
    20e4: b9001809     	str	w9, [x0, #0x18]
    20e8: 52800c61     	mov	w1, #0x63               ; =99
    20ec: 9000000f     	adrp	x15, 0x2000 <___pl_fn_1+0x1f2c>
    20f0: f94001ef     	ldr	x15, [x15]
    20f4: d63f01e0     	blr	x15
    20f8: 35008020     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    20fc: aa1c03e0     	mov	x0, x28
    2100: f9401800     	ldr	x0, [x0, #0x30]
    2104: aa1c03e1     	mov	x1, x28
    2108: b9001838     	str	w24, [x1, #0x18]
    210c: aa0003e2     	mov	x2, x0
    2110: 1400002f     	b	0x21cc <___pl_fn_1+0x20f8>
    2114: aa1c03e2     	mov	x2, x28
    2118: f9403045     	ldr	x5, [x2, #0x60]
    211c: f9400046     	ldr	x6, [x2]
    2120: d28000c7     	mov	x7, #0x6                ; =6
    2124: f2c00067     	movk	x7, #0x3, lsl #32
    2128: 2a0003e2     	mov	w2, w0
    212c: 8b020cc4     	add	x4, x6, x2, lsl #3
    2130: f82058c7     	str	x7, [x6, w0, uxtw #3]
    2134: 910004a5     	add	x5, x5, #0x1
    2138: f9000485     	str	x5, [x4, #0x8]
    213c: 92800006     	mov	x6, #-0x1               ; =-1
    2140: f9000886     	str	x6, [x4, #0x10]
    2144: d2800006     	mov	x6, #0x0                ; =0
    2148: f9000c86     	str	x6, [x4, #0x18]
    214c: f9001086     	str	x6, [x4, #0x20]
    2150: f9001486     	str	x6, [x4, #0x28]
    2154: f9001886     	str	x6, [x4, #0x30]
    2158: f9001c97     	str	x23, [x4, #0x38]
    215c: f9002097     	str	x23, [x4, #0x40]
    2160: f9002497     	str	x23, [x4, #0x48]
    2164: f9002886     	str	x6, [x4, #0x50]
    2168: f9002c86     	str	x6, [x4, #0x58]
    216c: aa1c03e4     	mov	x4, x28
    2170: f9003085     	str	x5, [x4, #0x60]
    2174: 91003004     	add	x4, x0, #0xc
    2178: aa1c03e5     	mov	x5, x28
    217c: f90028a4     	str	x4, [x5, #0x50]
    2180: aa1c03e4     	mov	x4, x28
    2184: f9403484     	ldr	x4, [x4, #0x68]
    2188: d1002884     	sub	x4, x4, #0xa
    218c: f90034a4     	str	x4, [x5, #0x68]
    2190: aa1c03e4     	mov	x4, x28
    2194: f9403884     	ldr	x4, [x4, #0x70]
    2198: d1002884     	sub	x4, x4, #0xa
    219c: f90038a4     	str	x4, [x5, #0x70]
    21a0: aa1c03e4     	mov	x4, x28
    21a4: f9404084     	ldr	x4, [x4, #0x80]
    21a8: b25e0442     	orr	x2, x2, #0xc00000000
    21ac: d37cec65     	lsl	x5, x3, #4
    21b0: 8b031086     	add	x6, x4, x3, lsl #4
    21b4: f8256882     	str	x2, [x4, x5]
    21b8: f90004c1     	str	x1, [x6, #0x8]
    21bc: 91000461     	add	x1, x3, #0x1
    21c0: aa1c03e5     	mov	x5, x28
    21c4: f90044a1     	str	x1, [x5, #0x88]
    21c8: aa0003e2     	mov	x2, x0
    21cc: 34006122     	cbz	w2, 0x2df0 <___pl_fn_1+0x2d1c>
    21d0: aa1c03e0     	mov	x0, x28
    21d4: f9400000     	ldr	x0, [x0]
    21d8: 2a0203e1     	mov	w1, w2
    21dc: 8b010c00     	add	x0, x0, x1, lsl #3
    21e0: f9002c14     	str	x20, [x0, #0x58]
    21e4: aa1c03e0     	mov	x0, x28
    21e8: b9401818     	ldr	w24, [x0, #0x18]
    21ec: b9401c01     	ldr	w1, [x0, #0x1c]
    21f0: 11001300     	add	w0, w24, #0x4
    21f4: 6b01001f     	cmp	w0, w1
    21f8: 54006f88     	b.hi	0x2fe8 <___pl_fn_1+0x2f14>
    21fc: aa1c03e1     	mov	x1, x28
    2200: f9401023     	ldr	x3, [x1, #0x20]
    2204: 2a1803f9     	mov	w25, w24
    2208: 8b190861     	add	x1, x3, x25, lsl #2
    220c: f94083e4     	ldr	x4, [sp, #0x100]
    2210: b8385864     	str	w4, [x3, w24, uxtw #2]
    2214: b9000436     	str	w22, [x1, #0x4]
    2218: b9000833     	str	w19, [x1, #0x8]
    221c: b9000c22     	str	w2, [x1, #0xc]
    2220: aa1c03e1     	mov	x1, x28
    2224: b9001820     	str	w0, [x1, #0x18]
    2228: aa1c03e0     	mov	x0, x28
    222c: b9401000     	ldr	w0, [x0, #0x10]
    2230: b9401421     	ldr	w1, [x1, #0x14]
    2234: 6b01001f     	cmp	w0, w1
    2238: 54006d42     	b.hs	0x2fe0 <___pl_fn_1+0x2f0c>
    223c: d28000a3     	mov	x3, #0x5                ; =5
    2240: d281f404     	mov	x4, #0xfa0              ; =4000
    2244: 52800006     	mov	w6, #0x0                ; =0
    2248: 52800027     	mov	w7, #0x1                ; =1
    224c: aa0203e1     	mov	x1, x2
    2250: aa1c03e0     	mov	x0, x28
    2254: f94083e2     	ldr	x2, [sp, #0x100]
    2258: aa1603e5     	mov	x5, x22
    225c: 94000000     	bl	0x225c <___pl_fn_1+0x2188>
    2260: aa1c03e0     	mov	x0, x28
    2264: b9402c00     	ldr	w0, [x0, #0x2c]
    2268: 350074a0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    226c: aa1c03e0     	mov	x0, x28
    2270: b9001818     	str	w24, [x0, #0x18]
    2274: f9403c00     	ldr	x0, [x0, #0x78]
    2278: 37605d40     	tbnz	w0, #0xc, 0x2e20 <___pl_fn_1+0x2d4c>
    227c: aa1c03e0     	mov	x0, x28
    2280: f9403801     	ldr	x1, [x0, #0x70]
    2284: f100003f     	cmp	x1, #0x0
    2288: 54005d0d     	b.le	0x2e28 <___pl_fn_1+0x2d54>
    228c: aa1c03e0     	mov	x0, x28
    2290: f9403405     	ldr	x5, [x0, #0x68]
    2294: d2800144     	mov	x4, #0xa                ; =10
    2298: f10028bf     	cmp	x5, #0xa
    229c: 54005cab     	b.lt	0x2e30 <___pl_fn_1+0x2d5c>
    22a0: aa1c03e0     	mov	x0, x28
    22a4: f9402807     	ldr	x7, [x0, #0x50]
    22a8: f9402c08     	ldr	x8, [x0, #0x58]
    22ac: 910030e9     	add	x9, x7, #0xc
    22b0: eb08013f     	cmp	x9, x8
    22b4: 54005c28     	b.hi	0x2e38 <___pl_fn_1+0x2d64>
    22b8: aa1c03e0     	mov	x0, x28
    22bc: f940440a     	ldr	x10, [x0, #0x88]
    22c0: f940480b     	ldr	x11, [x0, #0x90]
    22c4: eb0b015f     	cmp	x10, x11
    22c8: 54005bc2     	b.hs	0x2e40 <___pl_fn_1+0x2d6c>
    22cc: aa1c03e0     	mov	x0, x28
    22d0: b9401c0d     	ldr	w13, [x0, #0x1c]
    22d4: 11000f0e     	add	w14, w24, #0x3
    22d8: 6b0d01df     	cmp	w14, w13
    22dc: 540002e9     	b.ls	0x2338 <___pl_fn_1+0x2264>
    22e0: 140002da     	b	0x2e48 <___pl_fn_1+0x2d74>
    22e4: aa1c03e1     	mov	x1, x28
    22e8: f9401023     	ldr	x3, [x1, #0x20]
    22ec: 8b190861     	add	x1, x3, x25, lsl #2
    22f0: f94083e4     	ldr	x4, [sp, #0x100]
    22f4: b8385864     	str	w4, [x3, w24, uxtw #2]
    22f8: b9000436     	str	w22, [x1, #0x4]
    22fc: b9000833     	str	w19, [x1, #0x8]
    2300: aa1c03e1     	mov	x1, x28
    2304: b9001820     	str	w0, [x1, #0x18]
    2308: 52800d21     	mov	w1, #0x69               ; =105
    230c: 90000003     	adrp	x3, 0x2000 <___pl_fn_1+0x1f2c>
    2310: f9400063     	ldr	x3, [x3]
    2314: aa1c03e0     	mov	x0, x28
    2318: d63f0060     	blr	x3
    231c: 35006f00     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2320: aa1c03e0     	mov	x0, x28
    2324: f9401800     	ldr	x0, [x0, #0x30]
    2328: aa1c03e1     	mov	x1, x28
    232c: b9001838     	str	w24, [x1, #0x18]
    2330: aa0003e2     	mov	x2, x0
    2334: 1400002f     	b	0x23f0 <___pl_fn_1+0x231c>
    2338: aa1c03e0     	mov	x0, x28
    233c: f9403002     	ldr	x2, [x0, #0x60]
    2340: f9400003     	ldr	x3, [x0]
    2344: d28000c5     	mov	x5, #0x6                ; =6
    2348: f2c00065     	movk	x5, #0x3, lsl #32
    234c: 2a0703e0     	mov	w0, w7
    2350: 8b000c61     	add	x1, x3, x0, lsl #3
    2354: f8275865     	str	x5, [x3, w7, uxtw #3]
    2358: 91000442     	add	x2, x2, #0x1
    235c: f9000422     	str	x2, [x1, #0x8]
    2360: 92800003     	mov	x3, #-0x1               ; =-1
    2364: f9000823     	str	x3, [x1, #0x10]
    2368: d2800003     	mov	x3, #0x0                ; =0
    236c: f9000c23     	str	x3, [x1, #0x18]
    2370: f9001023     	str	x3, [x1, #0x20]
    2374: f9001423     	str	x3, [x1, #0x28]
    2378: f9001823     	str	x3, [x1, #0x30]
    237c: f9001c37     	str	x23, [x1, #0x38]
    2380: f9002037     	str	x23, [x1, #0x40]
    2384: f9002437     	str	x23, [x1, #0x48]
    2388: f9002823     	str	x3, [x1, #0x50]
    238c: f9002c23     	str	x3, [x1, #0x58]
    2390: aa1c03e1     	mov	x1, x28
    2394: f9003022     	str	x2, [x1, #0x60]
    2398: 910030e1     	add	x1, x7, #0xc
    239c: aa1c03e2     	mov	x2, x28
    23a0: f9002841     	str	x1, [x2, #0x50]
    23a4: aa1c03e1     	mov	x1, x28
    23a8: f9403421     	ldr	x1, [x1, #0x68]
    23ac: d1002821     	sub	x1, x1, #0xa
    23b0: f9003441     	str	x1, [x2, #0x68]
    23b4: aa1c03e1     	mov	x1, x28
    23b8: f9403821     	ldr	x1, [x1, #0x70]
    23bc: d1002821     	sub	x1, x1, #0xa
    23c0: f9003841     	str	x1, [x2, #0x70]
    23c4: aa1c03e1     	mov	x1, x28
    23c8: f9404021     	ldr	x1, [x1, #0x80]
    23cc: b25e0400     	orr	x0, x0, #0xc00000000
    23d0: d37ced42     	lsl	x2, x10, #4
    23d4: 8b0a1023     	add	x3, x1, x10, lsl #4
    23d8: f8226820     	str	x0, [x1, x2]
    23dc: f9000464     	str	x4, [x3, #0x8]
    23e0: 91000540     	add	x0, x10, #0x1
    23e4: aa1c03e1     	mov	x1, x28
    23e8: f9004420     	str	x0, [x1, #0x88]
    23ec: aa0703e2     	mov	x2, x7
    23f0: 340053e2     	cbz	w2, 0x2e6c <___pl_fn_1+0x2d98>
    23f4: aa1c03e0     	mov	x0, x28
    23f8: f9400000     	ldr	x0, [x0]
    23fc: 2a0203e1     	mov	w1, w2
    2400: 8b010c00     	add	x0, x0, x1, lsl #3
    2404: f9002c14     	str	x20, [x0, #0x58]
    2408: aa1c03e0     	mov	x0, x28
    240c: b9401814     	ldr	w20, [x0, #0x18]
    2410: b9401c01     	ldr	w1, [x0, #0x1c]
    2414: 11001280     	add	w0, w20, #0x4
    2418: 6b01001f     	cmp	w0, w1
    241c: 54005de8     	b.hi	0x2fd8 <___pl_fn_1+0x2f04>
    2420: aa1c03e9     	mov	x9, x28
    2424: f9401123     	ldr	x3, [x9, #0x20]
    2428: 2a1403e1     	mov	w1, w20
    242c: 8b010861     	add	x1, x3, x1, lsl #2
    2430: f94083ec     	ldr	x12, [sp, #0x100]
    2434: b834586c     	str	w12, [x3, w20, uxtw #2]
    2438: b9000436     	str	w22, [x1, #0x4]
    243c: b9000833     	str	w19, [x1, #0x8]
    2440: b9000c22     	str	w2, [x1, #0xc]
    2444: aa1c03e1     	mov	x1, x28
    2448: b9001820     	str	w0, [x1, #0x18]
    244c: aa1c03e0     	mov	x0, x28
    2450: b9401000     	ldr	w0, [x0, #0x10]
    2454: b9401421     	ldr	w1, [x1, #0x14]
    2458: 6b01001f     	cmp	w0, w1
    245c: 54005ba2     	b.hs	0x2fd0 <___pl_fn_1+0x2efc>
    2460: d28000c3     	mov	x3, #0x6                ; =6
    2464: d2827104     	mov	x4, #0x1388             ; =5000
    2468: 52800006     	mov	w6, #0x0                ; =0
    246c: 52800027     	mov	w7, #0x1                ; =1
    2470: aa0203e1     	mov	x1, x2
    2474: aa1603e5     	mov	x5, x22
    2478: aa1c03e0     	mov	x0, x28
    247c: f94083e2     	ldr	x2, [sp, #0x100]
    2480: 94000000     	bl	0x2480 <___pl_fn_1+0x23ac>
    2484: aa1c03e0     	mov	x0, x28
    2488: b9402c03     	ldr	w3, [x0, #0x2c]
    248c: 35006383     	cbnz	w3, 0x30fc <___pl_fn_1+0x3028>
    2490: aa1c03e0     	mov	x0, x28
    2494: b9001814     	str	w20, [x0, #0x18]
    2498: f94083e2     	ldr	x2, [sp, #0x100]
    249c: 34005002     	cbz	w2, 0x2e9c <___pl_fn_1+0x2dc8>
    24a0: aa1c03e0     	mov	x0, x28
    24a4: f9400008     	ldr	x8, [x0]
    24a8: 8b150d08     	add	x8, x8, x21, lsl #3
    24ac: b9401908     	ldr	w8, [x8, #0x18]
    24b0: 34004f68     	cbz	w8, 0x2e9c <___pl_fn_1+0x2dc8>
    24b4: 340058a8     	cbz	w8, 0x2fc8 <___pl_fn_1+0x2ef4>
    24b8: aa0803e2     	mov	x2, x8
    24bc: 6b13005f     	cmp	w2, w19
    24c0: 540006c1     	b.ne	0x2598 <___pl_fn_1+0x24c4>
    24c4: f94083e2     	ldr	x2, [sp, #0x100]
    24c8: 34004fe2     	cbz	w2, 0x2ec4 <___pl_fn_1+0x2df0>
    24cc: aa1c03e0     	mov	x0, x28
    24d0: f9400000     	ldr	x0, [x0]
    24d4: 8b150c00     	add	x0, x0, x21, lsl #3
    24d8: f9403402     	ldr	x2, [x0, #0x68]
    24dc: f9400800     	ldr	x0, [x0, #0x10]
    24e0: 37504f20     	tbnz	w0, #0xa, 0x2ec4 <___pl_fn_1+0x2df0>
    24e4: f94083ec     	ldr	x12, [sp, #0x100]
    24e8: 3400502c     	cbz	w12, 0x2eec <___pl_fn_1+0x2e18>
    24ec: aa1c03e0     	mov	x0, x28
    24f0: f9400000     	ldr	x0, [x0]
    24f4: 8b150c00     	add	x0, x0, x21, lsl #3
    24f8: f9403001     	ldr	x1, [x0, #0x60]
    24fc: aa0103f3     	mov	x19, x1
    2500: f9400800     	ldr	x0, [x0, #0x10]
    2504: 37484f40     	tbnz	w0, #0x9, 0x2eec <___pl_fn_1+0x2e18>
    2508: 52800ea1     	mov	w1, #0x75               ; =117
    250c: 52800003     	mov	w3, #0x0                ; =0
    2510: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2514: f9400084     	ldr	x4, [x4]
    2518: aa1c03e0     	mov	x0, x28
    251c: d63f0080     	blr	x4
    2520: 35005ee0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2524: 52800ec1     	mov	w1, #0x76               ; =118
    2528: d2800402     	mov	x2, #0x20               ; =32
    252c: 52800063     	mov	w3, #0x3                ; =3
    2530: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2534: f9400084     	ldr	x4, [x4]
    2538: aa1c03e0     	mov	x0, x28
    253c: d63f0080     	blr	x4
    2540: 35005de0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2544: 52800ee1     	mov	w1, #0x77               ; =119
    2548: 52802003     	mov	w3, #0x100              ; =256
    254c: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2550: f9400084     	ldr	x4, [x4]
    2554: aa1303e2     	mov	x2, x19
    2558: aa1c03e0     	mov	x0, x28
    255c: d63f0080     	blr	x4
    2560: 35005ce0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2564: aa1c03e0     	mov	x0, x28
    2568: b9401000     	ldr	w0, [x0, #0x10]
    256c: 51000400     	sub	w0, w0, #0x1
    2570: aa1c03e1     	mov	x1, x28
    2574: b9001020     	str	w0, [x1, #0x10]
    2578: 910483ff     	add	sp, sp, #0x120
    257c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    2580: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    2584: a8c163f7     	ldp	x23, x24, [sp], #0x10
    2588: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    258c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    2590: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    2594: d65f03c0     	ret
    2598: 34004be2     	cbz	w2, 0x2f14 <___pl_fn_1+0x2e40>
    259c: aa1c03e0     	mov	x0, x28
    25a0: f9400001     	ldr	x1, [x0]
    25a4: 2a0203e0     	mov	w0, w2
    25a8: 8b000c21     	add	x1, x1, x0, lsl #3
    25ac: 39412023     	ldrb	w3, [x1, #0x48]
    25b0: 53001c64     	uxtb	w4, w3
    25b4: 7100089f     	cmp	w4, #0x2
    25b8: 54004ae0     	b.eq	0x2f14 <___pl_fn_1+0x2e40>
    25bc: 72001c7f     	tst	w3, #0xff
    25c0: 54000221     	b.ne	0x2604 <___pl_fn_1+0x2530>
    25c4: 34004ba2     	cbz	w2, 0x2f38 <___pl_fn_1+0x2e64>
    25c8: 3940e023     	ldrb	w3, [x1, #0x38]
    25cc: 53001c64     	uxtb	w4, w3
    25d0: 7100089f     	cmp	w4, #0x2
    25d4: 54004b20     	b.eq	0x2f38 <___pl_fn_1+0x2e64>
    25d8: 52000066     	eor	w6, w3, #0x1
    25dc: 72001cdf     	tst	w6, #0xff
    25e0: 54000061     	b.ne	0x25ec <___pl_fn_1+0x2518>
    25e4: 52800001     	mov	w1, #0x0                ; =0
    25e8: 14000008     	b	0x2608 <___pl_fn_1+0x2534>
    25ec: 34004b82     	cbz	w2, 0x2f5c <___pl_fn_1+0x2e88>
    25f0: 39410021     	ldrb	w1, [x1, #0x40]
    25f4: 53001c2b     	uxtb	w11, w1
    25f8: 7100097f     	cmp	w11, #0x2
    25fc: 54004b00     	b.eq	0x2f5c <___pl_fn_1+0x2e88>
    2600: 14000002     	b	0x2608 <___pl_fn_1+0x2534>
    2604: 52800021     	mov	w1, #0x1                ; =1
    2608: 72001c3f     	tst	w1, #0xff
    260c: 54000421     	b.ne	0x2690 <___pl_fn_1+0x25bc>
    2610: aa1c03e0     	mov	x0, x28
    2614: b9401818     	ldr	w24, [x0, #0x18]
    2618: b9401c00     	ldr	w0, [x0, #0x1c]
    261c: 11000f01     	add	w1, w24, #0x3
    2620: 6b00003f     	cmp	w1, w0
    2624: 54004b68     	b.hi	0x2f90 <___pl_fn_1+0x2ebc>
    2628: aa1c03e0     	mov	x0, x28
    262c: f9401000     	ldr	x0, [x0, #0x20]
    2630: 2a1803e1     	mov	w1, w24
    2634: 8b010801     	add	x1, x0, x1, lsl #2
    2638: f94083e4     	ldr	x4, [sp, #0x100]
    263c: b8385804     	str	w4, [x0, w24, uxtw #2]
    2640: b9000433     	str	w19, [x1, #0x4]
    2644: b9000822     	str	w2, [x1, #0x8]
    2648: 11000f00     	add	w0, w24, #0x3
    264c: aa1c03e1     	mov	x1, x28
    2650: b9001820     	str	w0, [x1, #0x18]
    2654: aa1c03e0     	mov	x0, x28
    2658: b9401000     	ldr	w0, [x0, #0x10]
    265c: b9401421     	ldr	w1, [x1, #0x14]
    2660: 6b01001f     	cmp	w0, w1
    2664: 54004922     	b.hs	0x2f88 <___pl_fn_1+0x2eb4>
    2668: aa0203e1     	mov	x1, x2
    266c: aa1c03e0     	mov	x0, x28
    2670: 94000000     	bl	0x2670 <___pl_fn_1+0x259c>
    2674: aa1c03e1     	mov	x1, x28
    2678: b9402c21     	ldr	w1, [x1, #0x2c]
    267c: 35005401     	cbnz	w1, 0x30fc <___pl_fn_1+0x3028>
    2680: aa1c03e1     	mov	x1, x28
    2684: b9001838     	str	w24, [x1, #0x18]
    2688: 340047c0     	cbz	w0, 0x2f80 <___pl_fn_1+0x2eac>
    268c: 1400000a     	b	0x26b4 <___pl_fn_1+0x25e0>
    2690: aa0203e1     	mov	x1, x2
    2694: 34004821     	cbz	w1, 0x2f98 <___pl_fn_1+0x2ec4>
    2698: aa0103e2     	mov	x2, x1
    269c: aa1c03e1     	mov	x1, x28
    26a0: f9400021     	ldr	x1, [x1]
    26a4: 8b000c20     	add	x0, x1, x0, lsl #3
    26a8: b9401800     	ldr	w0, [x0, #0x18]
    26ac: 34004780     	cbz	w0, 0x2f9c <___pl_fn_1+0x2ec8>
    26b0: 34004880     	cbz	w0, 0x2fc0 <___pl_fn_1+0x2eec>
    26b4: aa0003e2     	mov	x2, x0
    26b8: 17ffff81     	b	0x24bc <___pl_fn_1+0x23e8>
    26bc: 52800121     	mov	w1, #0x9                ; =9
    26c0: 52800022     	mov	w2, #0x1                ; =1
    26c4: 90000003     	adrp	x3, 0x2000 <___pl_fn_1+0x1f2c>
    26c8: f9400063     	ldr	x3, [x3]
    26cc: aa1c03e0     	mov	x0, x28
    26d0: d63f0060     	blr	x3
    26d4: 34fed580     	cbz	w0, 0x184 <___pl_fn_1+0xb0>
    26d8: 14000289     	b	0x30fc <___pl_fn_1+0x3028>
    26dc: aa1c03e0     	mov	x0, x28
    26e0: 1400000a     	b	0x2708 <___pl_fn_1+0x2634>
    26e4: aa1c03e0     	mov	x0, x28
    26e8: 14000008     	b	0x2708 <___pl_fn_1+0x2634>
    26ec: aa1c03e0     	mov	x0, x28
    26f0: 14000006     	b	0x2708 <___pl_fn_1+0x2634>
    26f4: aa1c03e0     	mov	x0, x28
    26f8: 14000004     	b	0x2708 <___pl_fn_1+0x2634>
    26fc: aa1c03e0     	mov	x0, x28
    2700: 14000002     	b	0x2708 <___pl_fn_1+0x2634>
    2704: aa1c03e0     	mov	x0, x28
    2708: aa1c03e0     	mov	x0, x28
    270c: b9401813     	ldr	w19, [x0, #0x18]
    2710: b9401c01     	ldr	w1, [x0, #0x1c]
    2714: 11000660     	add	w0, w19, #0x1
    2718: 6b01001f     	cmp	w0, w1
    271c: 54fedda9     	b.ls	0x2d0 <___pl_fn_1+0x1fc>
    2720: 52800141     	mov	w1, #0xa                ; =10
    2724: 14000272     	b	0x30ec <___pl_fn_1+0x3018>
    2728: d2800004     	mov	x4, #0x0                ; =0
    272c: 910003e3     	mov	x3, sp
    2730: f80003e4     	stur	x4, [sp]
    2734: aa1603e2     	mov	x2, x22
    2738: 2a0203e5     	mov	w5, w2
    273c: f80083e5     	stur	x5, [sp, #0x8]
    2740: 52800181     	mov	w1, #0xc                ; =12
    2744: 90000006     	adrp	x6, 0x2000 <___pl_fn_1+0x1f2c>
    2748: f94000c6     	ldr	x6, [x6]
    274c: aa1c03e0     	mov	x0, x28
    2750: d63f00c0     	blr	x6
    2754: 35004d40     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2758: 528001a1     	mov	w1, #0xd                ; =13
    275c: 14000264     	b	0x30ec <___pl_fn_1+0x3018>
    2760: aa1c03e0     	mov	x0, x28
    2764: 1400000a     	b	0x278c <___pl_fn_1+0x26b8>
    2768: aa1c03e0     	mov	x0, x28
    276c: 14000008     	b	0x278c <___pl_fn_1+0x26b8>
    2770: aa1c03e0     	mov	x0, x28
    2774: 14000006     	b	0x278c <___pl_fn_1+0x26b8>
    2778: aa1c03e0     	mov	x0, x28
    277c: 14000004     	b	0x278c <___pl_fn_1+0x26b8>
    2780: aa1c03e0     	mov	x0, x28
    2784: 14000002     	b	0x278c <___pl_fn_1+0x26b8>
    2788: aa1c03e0     	mov	x0, x28
    278c: aa1c03e0     	mov	x0, x28
    2790: b9401815     	ldr	w21, [x0, #0x18]
    2794: b9401c00     	ldr	w0, [x0, #0x1c]
    2798: 52800042     	mov	w2, #0x2                ; =2
    279c: 11000aa1     	add	w1, w21, #0x2
    27a0: 6b00003f     	cmp	w1, w0
    27a4: 54fee709     	b.ls	0x484 <___pl_fn_1+0x3b0>
    27a8: 528001c1     	mov	w1, #0xe                ; =14
    27ac: 14000250     	b	0x30ec <___pl_fn_1+0x3018>
    27b0: d2800040     	mov	x0, #0x2                ; =2
    27b4: 910043e3     	add	x3, sp, #0x10
    27b8: f80103e0     	stur	x0, [sp, #0x10]
    27bc: f80183f4     	stur	x20, [sp, #0x18]
    27c0: 52800201     	mov	w1, #0x10               ; =16
    27c4: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    27c8: f9400084     	ldr	x4, [x4]
    27cc: f94083e2     	ldr	x2, [sp, #0x100]
    27d0: aa1c03e0     	mov	x0, x28
    27d4: d63f0080     	blr	x4
    27d8: 35004920     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    27dc: 52800221     	mov	w1, #0x11               ; =17
    27e0: 14000243     	b	0x30ec <___pl_fn_1+0x3018>
    27e4: d2800025     	mov	x5, #0x1                ; =1
    27e8: 910083e3     	add	x3, sp, #0x20
    27ec: f80203e5     	stur	x5, [sp, #0x20]
    27f0: 2a1303e6     	mov	w6, w19
    27f4: f80283e6     	stur	x6, [sp, #0x28]
    27f8: 52800241     	mov	w1, #0x12               ; =18
    27fc: 90000007     	adrp	x7, 0x2000 <___pl_fn_1+0x1f2c>
    2800: f94000e7     	ldr	x7, [x7]
    2804: f94083e2     	ldr	x2, [sp, #0x100]
    2808: aa1c03e0     	mov	x0, x28
    280c: d63f00e0     	blr	x7
    2810: 35004760     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2814: 52800261     	mov	w1, #0x13               ; =19
    2818: 14000235     	b	0x30ec <___pl_fn_1+0x3018>
    281c: d280000e     	mov	x14, #0x0               ; =0
    2820: 9100c3e3     	add	x3, sp, #0x30
    2824: f80303ee     	stur	x14, [sp, #0x30]
    2828: f80383eb     	stur	x11, [sp, #0x38]
    282c: 52800281     	mov	w1, #0x14               ; =20
    2830: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2834: f9400084     	ldr	x4, [x4]
    2838: f94083e2     	ldr	x2, [sp, #0x100]
    283c: aa1c03e0     	mov	x0, x28
    2840: d63f0080     	blr	x4
    2844: 350045c0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2848: 528002a1     	mov	w1, #0x15               ; =21
    284c: 14000228     	b	0x30ec <___pl_fn_1+0x3018>
    2850: d2800120     	mov	x0, #0x9                ; =9
    2854: 910103e3     	add	x3, sp, #0x40
    2858: f80403e0     	stur	x0, [sp, #0x40]
    285c: d2800000     	mov	x0, #0x0                ; =0
    2860: f80483e0     	stur	x0, [sp, #0x48]
    2864: 528002c1     	mov	w1, #0x16               ; =22
    2868: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    286c: f9400084     	ldr	x4, [x4]
    2870: f94083e2     	ldr	x2, [sp, #0x100]
    2874: aa1c03e0     	mov	x0, x28
    2878: d63f0080     	blr	x4
    287c: 35004400     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2880: 528002e1     	mov	w1, #0x17               ; =23
    2884: 1400021a     	b	0x30ec <___pl_fn_1+0x3018>
    2888: d2800140     	mov	x0, #0xa                ; =10
    288c: 910143e3     	add	x3, sp, #0x50
    2890: f80503e0     	stur	x0, [sp, #0x50]
    2894: d2800000     	mov	x0, #0x0                ; =0
    2898: f80583e0     	stur	x0, [sp, #0x58]
    289c: 52800301     	mov	w1, #0x18               ; =24
    28a0: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    28a4: f9400084     	ldr	x4, [x4]
    28a8: f94083e2     	ldr	x2, [sp, #0x100]
    28ac: aa1c03e0     	mov	x0, x28
    28b0: d63f0080     	blr	x4
    28b4: 35004240     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    28b8: 52800321     	mov	w1, #0x19               ; =25
    28bc: 1400020c     	b	0x30ec <___pl_fn_1+0x3018>
    28c0: aa1c03e0     	mov	x0, x28
    28c4: 1400000a     	b	0x28ec <___pl_fn_1+0x2818>
    28c8: aa1c03e0     	mov	x0, x28
    28cc: 14000008     	b	0x28ec <___pl_fn_1+0x2818>
    28d0: aa1c03e0     	mov	x0, x28
    28d4: 14000006     	b	0x28ec <___pl_fn_1+0x2818>
    28d8: aa1c03e0     	mov	x0, x28
    28dc: 14000004     	b	0x28ec <___pl_fn_1+0x2818>
    28e0: aa1c03e0     	mov	x0, x28
    28e4: 14000002     	b	0x28ec <___pl_fn_1+0x2818>
    28e8: aa1c03e0     	mov	x0, x28
    28ec: aa1c03e0     	mov	x0, x28
    28f0: b9401818     	ldr	w24, [x0, #0x18]
    28f4: b9401c00     	ldr	w0, [x0, #0x1c]
    28f8: 11000f01     	add	w1, w24, #0x3
    28fc: 6b00003f     	cmp	w1, w0
    2900: 54feeca9     	b.ls	0x694 <___pl_fn_1+0x5c0>
    2904: 52800341     	mov	w1, #0x1a               ; =26
    2908: 140001f9     	b	0x30ec <___pl_fn_1+0x3018>
    290c: d2800100     	mov	x0, #0x8                ; =8
    2910: 910183e3     	add	x3, sp, #0x60
    2914: f80603e0     	stur	x0, [sp, #0x60]
    2918: d2800020     	mov	x0, #0x1                ; =1
    291c: f80683e0     	stur	x0, [sp, #0x68]
    2920: 52800381     	mov	w1, #0x1c               ; =28
    2924: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2928: f9400084     	ldr	x4, [x4]
    292c: aa1c03e0     	mov	x0, x28
    2930: d63f0080     	blr	x4
    2934: 35003e40     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2938: 528003a1     	mov	w1, #0x1d               ; =29
    293c: 140001ec     	b	0x30ec <___pl_fn_1+0x3018>
    2940: d2800120     	mov	x0, #0x9                ; =9
    2944: 9101c3e3     	add	x3, sp, #0x70
    2948: f80703e0     	stur	x0, [sp, #0x70]
    294c: f80783f7     	stur	x23, [sp, #0x78]
    2950: 528003c1     	mov	w1, #0x1e               ; =30
    2954: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2958: f9400084     	ldr	x4, [x4]
    295c: aa1c03e0     	mov	x0, x28
    2960: d63f0080     	blr	x4
    2964: 35003cc0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2968: 528003e1     	mov	w1, #0x1f               ; =31
    296c: 140001e0     	b	0x30ec <___pl_fn_1+0x3018>
    2970: aa1c03e0     	mov	x0, x28
    2974: 1400000a     	b	0x299c <___pl_fn_1+0x28c8>
    2978: aa1c03e0     	mov	x0, x28
    297c: 14000008     	b	0x299c <___pl_fn_1+0x28c8>
    2980: aa1c03e0     	mov	x0, x28
    2984: 14000006     	b	0x299c <___pl_fn_1+0x28c8>
    2988: aa1c03e0     	mov	x0, x28
    298c: 14000004     	b	0x299c <___pl_fn_1+0x28c8>
    2990: aa1c03e0     	mov	x0, x28
    2994: 14000002     	b	0x299c <___pl_fn_1+0x28c8>
    2998: aa1c03e0     	mov	x0, x28
    299c: aa1c03e0     	mov	x0, x28
    29a0: b9401c01     	ldr	w1, [x0, #0x1c]
    29a4: 11000f00     	add	w0, w24, #0x3
    29a8: 6b01001f     	cmp	w0, w1
    29ac: 54fefb09     	b.ls	0x90c <___pl_fn_1+0x838>
    29b0: 52800441     	mov	w1, #0x22               ; =34
    29b4: 140001ce     	b	0x30ec <___pl_fn_1+0x3018>
    29b8: aa1c03e1     	mov	x1, x28
    29bc: 1400000a     	b	0x29e4 <___pl_fn_1+0x2910>
    29c0: aa1c03e1     	mov	x1, x28
    29c4: 14000008     	b	0x29e4 <___pl_fn_1+0x2910>
    29c8: aa1c03e1     	mov	x1, x28
    29cc: 14000006     	b	0x29e4 <___pl_fn_1+0x2910>
    29d0: aa1c03e1     	mov	x1, x28
    29d4: 14000004     	b	0x29e4 <___pl_fn_1+0x2910>
    29d8: aa1c03e1     	mov	x1, x28
    29dc: 14000002     	b	0x29e4 <___pl_fn_1+0x2910>
    29e0: aa1c03e1     	mov	x1, x28
    29e4: aa1c03e1     	mov	x1, x28
    29e8: b9401c21     	ldr	w1, [x1, #0x1c]
    29ec: 6b01033f     	cmp	w25, w1
    29f0: 54ff08e9     	b.ls	0xb0c <___pl_fn_1+0xa38>
    29f4: 528004e1     	mov	w1, #0x27               ; =39
    29f8: 140001bd     	b	0x30ec <___pl_fn_1+0x3018>
    29fc: aa1c03ee     	mov	x14, x28
    2a00: 1400000a     	b	0x2a28 <___pl_fn_1+0x2954>
    2a04: aa1c03ee     	mov	x14, x28
    2a08: 14000008     	b	0x2a28 <___pl_fn_1+0x2954>
    2a0c: aa1c03ee     	mov	x14, x28
    2a10: 14000006     	b	0x2a28 <___pl_fn_1+0x2954>
    2a14: aa1c03ee     	mov	x14, x28
    2a18: 14000004     	b	0x2a28 <___pl_fn_1+0x2954>
    2a1c: aa1c03ee     	mov	x14, x28
    2a20: 14000002     	b	0x2a28 <___pl_fn_1+0x2954>
    2a24: aa1c03ee     	mov	x14, x28
    2a28: aa1c03ee     	mov	x14, x28
    2a2c: b9401dc2     	ldr	w2, [x14, #0x1c]
    2a30: 11001301     	add	w1, w24, #0x4
    2a34: 6b02003f     	cmp	w1, w2
    2a38: 54ff1789     	b.ls	0xd28 <___pl_fn_1+0xc54>
    2a3c: 52800581     	mov	w1, #0x2c               ; =44
    2a40: 140001ab     	b	0x30ec <___pl_fn_1+0x3018>
    2a44: d2800100     	mov	x0, #0x8                ; =8
    2a48: 910203e3     	add	x3, sp, #0x80
    2a4c: f80803e0     	stur	x0, [sp, #0x80]
    2a50: f9408be4     	ldr	x4, [sp, #0x110]
    2a54: f80883e4     	stur	x4, [sp, #0x88]
    2a58: 528005c1     	mov	w1, #0x2e               ; =46
    2a5c: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2a60: f9400084     	ldr	x4, [x4]
    2a64: aa1c03e0     	mov	x0, x28
    2a68: d63f0080     	blr	x4
    2a6c: 35003480     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2a70: 528005e1     	mov	w1, #0x2f               ; =47
    2a74: 1400019e     	b	0x30ec <___pl_fn_1+0x3018>
    2a78: d2800124     	mov	x4, #0x9                ; =9
    2a7c: 910243e3     	add	x3, sp, #0x90
    2a80: f80903e4     	stur	x4, [sp, #0x90]
    2a84: d2800004     	mov	x4, #0x0                ; =0
    2a88: f80983e4     	stur	x4, [sp, #0x98]
    2a8c: 52800601     	mov	w1, #0x30               ; =48
    2a90: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2a94: f9400084     	ldr	x4, [x4]
    2a98: aa1c03e0     	mov	x0, x28
    2a9c: d63f0080     	blr	x4
    2aa0: 350032e0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2aa4: 52800621     	mov	w1, #0x31               ; =49
    2aa8: 14000191     	b	0x30ec <___pl_fn_1+0x3018>
    2aac: aa1c03e0     	mov	x0, x28
    2ab0: 1400000a     	b	0x2ad8 <___pl_fn_1+0x2a04>
    2ab4: aa1c03e0     	mov	x0, x28
    2ab8: 14000008     	b	0x2ad8 <___pl_fn_1+0x2a04>
    2abc: aa1c03e0     	mov	x0, x28
    2ac0: 14000006     	b	0x2ad8 <___pl_fn_1+0x2a04>
    2ac4: aa1c03e0     	mov	x0, x28
    2ac8: 14000004     	b	0x2ad8 <___pl_fn_1+0x2a04>
    2acc: aa1c03e0     	mov	x0, x28
    2ad0: 14000002     	b	0x2ad8 <___pl_fn_1+0x2a04>
    2ad4: aa1c03e0     	mov	x0, x28
    2ad8: aa1c03e0     	mov	x0, x28
    2adc: b9401c01     	ldr	w1, [x0, #0x1c]
    2ae0: 11000f00     	add	w0, w24, #0x3
    2ae4: 6b01001f     	cmp	w0, w1
    2ae8: 54ff26c9     	b.ls	0xfc0 <___pl_fn_1+0xeec>
    2aec: 52800681     	mov	w1, #0x34               ; =52
    2af0: 1400017f     	b	0x30ec <___pl_fn_1+0x3018>
    2af4: aa1c03e1     	mov	x1, x28
    2af8: 1400000a     	b	0x2b20 <___pl_fn_1+0x2a4c>
    2afc: aa1c03e1     	mov	x1, x28
    2b00: 14000008     	b	0x2b20 <___pl_fn_1+0x2a4c>
    2b04: aa1c03e1     	mov	x1, x28
    2b08: 14000006     	b	0x2b20 <___pl_fn_1+0x2a4c>
    2b0c: aa1c03e1     	mov	x1, x28
    2b10: 14000004     	b	0x2b20 <___pl_fn_1+0x2a4c>
    2b14: aa1c03e1     	mov	x1, x28
    2b18: 14000002     	b	0x2b20 <___pl_fn_1+0x2a4c>
    2b1c: aa1c03e1     	mov	x1, x28
    2b20: aa1c03e1     	mov	x1, x28
    2b24: b9401c21     	ldr	w1, [x1, #0x1c]
    2b28: 6b01033f     	cmp	w25, w1
    2b2c: 54ff3449     	b.ls	0x11b4 <___pl_fn_1+0x10e0>
    2b30: 52800721     	mov	w1, #0x39               ; =57
    2b34: 1400016e     	b	0x30ec <___pl_fn_1+0x3018>
    2b38: aa1c03e1     	mov	x1, x28
    2b3c: 1400000a     	b	0x2b64 <___pl_fn_1+0x2a90>
    2b40: aa1c03e1     	mov	x1, x28
    2b44: 14000008     	b	0x2b64 <___pl_fn_1+0x2a90>
    2b48: aa1c03e1     	mov	x1, x28
    2b4c: 14000006     	b	0x2b64 <___pl_fn_1+0x2a90>
    2b50: aa1c03e1     	mov	x1, x28
    2b54: 14000004     	b	0x2b64 <___pl_fn_1+0x2a90>
    2b58: aa1c03e1     	mov	x1, x28
    2b5c: 14000002     	b	0x2b64 <___pl_fn_1+0x2a90>
    2b60: aa1c03e1     	mov	x1, x28
    2b64: aa1c03e1     	mov	x1, x28
    2b68: b9401c22     	ldr	w2, [x1, #0x1c]
    2b6c: 11001301     	add	w1, w24, #0x4
    2b70: 6b02003f     	cmp	w1, w2
    2b74: 54ff42c9     	b.ls	0x13cc <___pl_fn_1+0x12f8>
    2b78: 528007c1     	mov	w1, #0x3e               ; =62
    2b7c: 1400015c     	b	0x30ec <___pl_fn_1+0x3018>
    2b80: aa1c03e0     	mov	x0, x28
    2b84: 1400000a     	b	0x2bac <___pl_fn_1+0x2ad8>
    2b88: aa1c03e0     	mov	x0, x28
    2b8c: 14000008     	b	0x2bac <___pl_fn_1+0x2ad8>
    2b90: aa1c03e0     	mov	x0, x28
    2b94: 14000006     	b	0x2bac <___pl_fn_1+0x2ad8>
    2b98: aa1c03e0     	mov	x0, x28
    2b9c: 14000004     	b	0x2bac <___pl_fn_1+0x2ad8>
    2ba0: aa1c03e0     	mov	x0, x28
    2ba4: 14000002     	b	0x2bac <___pl_fn_1+0x2ad8>
    2ba8: aa1c03e0     	mov	x0, x28
    2bac: aa1c03e0     	mov	x0, x28
    2bb0: b9401c01     	ldr	w1, [x0, #0x1c]
    2bb4: 11001300     	add	w0, w24, #0x4
    2bb8: 6b01001f     	cmp	w0, w1
    2bbc: 54ff5169     	b.ls	0x15e8 <___pl_fn_1+0x1514>
    2bc0: 52800861     	mov	w1, #0x43               ; =67
    2bc4: 1400014a     	b	0x30ec <___pl_fn_1+0x3018>
    2bc8: d280010a     	mov	x10, #0x8               ; =8
    2bcc: 910283e3     	add	x3, sp, #0xa0
    2bd0: f80a03ea     	stur	x10, [sp, #0xa0]
    2bd4: f80a83f4     	stur	x20, [sp, #0xa8]
    2bd8: 528008a1     	mov	w1, #0x45               ; =69
    2bdc: 9000000c     	adrp	x12, 0x2000 <___pl_fn_1+0x1f2c>
    2be0: f940018c     	ldr	x12, [x12]
    2be4: aa1c03e0     	mov	x0, x28
    2be8: d63f0180     	blr	x12
    2bec: 35002880     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2bf0: 528008c1     	mov	w1, #0x46               ; =70
    2bf4: 1400013e     	b	0x30ec <___pl_fn_1+0x3018>
    2bf8: d2800120     	mov	x0, #0x9                ; =9
    2bfc: 9102c3e3     	add	x3, sp, #0xb0
    2c00: f80b03e0     	stur	x0, [sp, #0xb0]
    2c04: f80b83f4     	stur	x20, [sp, #0xb8]
    2c08: 528008e1     	mov	w1, #0x47               ; =71
    2c0c: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2c10: f9400084     	ldr	x4, [x4]
    2c14: aa1c03e0     	mov	x0, x28
    2c18: d63f0080     	blr	x4
    2c1c: 35002700     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2c20: 52800901     	mov	w1, #0x48               ; =72
    2c24: 14000132     	b	0x30ec <___pl_fn_1+0x3018>
    2c28: aa1c03e0     	mov	x0, x28
    2c2c: 1400000a     	b	0x2c54 <___pl_fn_1+0x2b80>
    2c30: aa1c03e0     	mov	x0, x28
    2c34: 14000008     	b	0x2c54 <___pl_fn_1+0x2b80>
    2c38: aa1c03e0     	mov	x0, x28
    2c3c: 14000006     	b	0x2c54 <___pl_fn_1+0x2b80>
    2c40: aa1c03e0     	mov	x0, x28
    2c44: 14000004     	b	0x2c54 <___pl_fn_1+0x2b80>
    2c48: aa1c03e0     	mov	x0, x28
    2c4c: 14000002     	b	0x2c54 <___pl_fn_1+0x2b80>
    2c50: aa1c03e0     	mov	x0, x28
    2c54: aa1c03e0     	mov	x0, x28
    2c58: b9401c01     	ldr	w1, [x0, #0x1c]
    2c5c: 11000f60     	add	w0, w27, #0x3
    2c60: 6b01001f     	cmp	w0, w1
    2c64: 54ff5f09     	b.ls	0x1844 <___pl_fn_1+0x1770>
    2c68: 52800961     	mov	w1, #0x4b               ; =75
    2c6c: 14000120     	b	0x30ec <___pl_fn_1+0x3018>
    2c70: aa1c03e1     	mov	x1, x28
    2c74: 1400000a     	b	0x2c9c <___pl_fn_1+0x2bc8>
    2c78: aa1c03e1     	mov	x1, x28
    2c7c: 14000008     	b	0x2c9c <___pl_fn_1+0x2bc8>
    2c80: aa1c03e1     	mov	x1, x28
    2c84: 14000006     	b	0x2c9c <___pl_fn_1+0x2bc8>
    2c88: aa1c03e1     	mov	x1, x28
    2c8c: 14000004     	b	0x2c9c <___pl_fn_1+0x2bc8>
    2c90: aa1c03e1     	mov	x1, x28
    2c94: 14000002     	b	0x2c9c <___pl_fn_1+0x2bc8>
    2c98: aa1c03e1     	mov	x1, x28
    2c9c: aa1c03e1     	mov	x1, x28
    2ca0: b9401c21     	ldr	w1, [x1, #0x1c]
    2ca4: 6b01035f     	cmp	w26, w1
    2ca8: 54ff6cc9     	b.ls	0x1a40 <___pl_fn_1+0x196c>
    2cac: 52800a01     	mov	w1, #0x50               ; =80
    2cb0: 1400010f     	b	0x30ec <___pl_fn_1+0x3018>
    2cb4: aa1c03e1     	mov	x1, x28
    2cb8: 1400000a     	b	0x2ce0 <___pl_fn_1+0x2c0c>
    2cbc: aa1c03e1     	mov	x1, x28
    2cc0: 14000008     	b	0x2ce0 <___pl_fn_1+0x2c0c>
    2cc4: aa1c03e1     	mov	x1, x28
    2cc8: 14000006     	b	0x2ce0 <___pl_fn_1+0x2c0c>
    2ccc: aa1c03e1     	mov	x1, x28
    2cd0: 14000004     	b	0x2ce0 <___pl_fn_1+0x2c0c>
    2cd4: aa1c03e1     	mov	x1, x28
    2cd8: 14000002     	b	0x2ce0 <___pl_fn_1+0x2c0c>
    2cdc: aa1c03e1     	mov	x1, x28
    2ce0: aa1c03e1     	mov	x1, x28
    2ce4: b9401c22     	ldr	w2, [x1, #0x1c]
    2ce8: 11001301     	add	w1, w24, #0x4
    2cec: 6b02003f     	cmp	w1, w2
    2cf0: 54ff7b49     	b.ls	0x1c58 <___pl_fn_1+0x1b84>
    2cf4: 52800aa1     	mov	w1, #0x55               ; =85
    2cf8: 140000fd     	b	0x30ec <___pl_fn_1+0x3018>
    2cfc: aa1c03e0     	mov	x0, x28
    2d00: 1400000a     	b	0x2d28 <___pl_fn_1+0x2c54>
    2d04: aa1c03e0     	mov	x0, x28
    2d08: 14000008     	b	0x2d28 <___pl_fn_1+0x2c54>
    2d0c: aa1c03e0     	mov	x0, x28
    2d10: 14000006     	b	0x2d28 <___pl_fn_1+0x2c54>
    2d14: aa1c03e0     	mov	x0, x28
    2d18: 14000004     	b	0x2d28 <___pl_fn_1+0x2c54>
    2d1c: aa1c03e0     	mov	x0, x28
    2d20: 14000002     	b	0x2d28 <___pl_fn_1+0x2c54>
    2d24: aa1c03e0     	mov	x0, x28
    2d28: aa1c03e0     	mov	x0, x28
    2d2c: b9401c01     	ldr	w1, [x0, #0x1c]
    2d30: 11001300     	add	w0, w24, #0x4
    2d34: 6b01001f     	cmp	w0, w1
    2d38: 54ff89e9     	b.ls	0x1e74 <___pl_fn_1+0x1da0>
    2d3c: 52800b41     	mov	w1, #0x5a               ; =90
    2d40: 140000eb     	b	0x30ec <___pl_fn_1+0x3018>
    2d44: d2800100     	mov	x0, #0x8                ; =8
    2d48: 910303e3     	add	x3, sp, #0xc0
    2d4c: f80c03e0     	stur	x0, [sp, #0xc0]
    2d50: f80c83f4     	stur	x20, [sp, #0xc8]
    2d54: 52800b81     	mov	w1, #0x5c               ; =92
    2d58: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2d5c: f9400084     	ldr	x4, [x4]
    2d60: aa1c03e0     	mov	x0, x28
    2d64: d63f0080     	blr	x4
    2d68: 35001ca0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2d6c: 52800ba1     	mov	w1, #0x5d               ; =93
    2d70: 140000df     	b	0x30ec <___pl_fn_1+0x3018>
    2d74: d2800120     	mov	x0, #0x9                ; =9
    2d78: 910343e3     	add	x3, sp, #0xd0
    2d7c: f80d03e0     	stur	x0, [sp, #0xd0]
    2d80: f80d83f4     	stur	x20, [sp, #0xd8]
    2d84: 52800bc1     	mov	w1, #0x5e               ; =94
    2d88: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2d8c: f9400084     	ldr	x4, [x4]
    2d90: aa1c03e0     	mov	x0, x28
    2d94: d63f0080     	blr	x4
    2d98: 35001b20     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2d9c: 52800be1     	mov	w1, #0x5f               ; =95
    2da0: 140000d3     	b	0x30ec <___pl_fn_1+0x3018>
    2da4: aa1c03e0     	mov	x0, x28
    2da8: 1400000a     	b	0x2dd0 <___pl_fn_1+0x2cfc>
    2dac: aa1c03e0     	mov	x0, x28
    2db0: 14000008     	b	0x2dd0 <___pl_fn_1+0x2cfc>
    2db4: aa1c03e0     	mov	x0, x28
    2db8: 14000006     	b	0x2dd0 <___pl_fn_1+0x2cfc>
    2dbc: aa1c03e0     	mov	x0, x28
    2dc0: 14000004     	b	0x2dd0 <___pl_fn_1+0x2cfc>
    2dc4: aa1c03e0     	mov	x0, x28
    2dc8: 14000002     	b	0x2dd0 <___pl_fn_1+0x2cfc>
    2dcc: aa1c03e0     	mov	x0, x28
    2dd0: aa1c03e0     	mov	x0, x28
    2dd4: b9401c0a     	ldr	w10, [x0, #0x1c]
    2dd8: 52800062     	mov	w2, #0x3                ; =3
    2ddc: 11000f09     	add	w9, w24, #0x3
    2de0: 6b0a013f     	cmp	w9, w10
    2de4: 54ff9709     	b.ls	0x20c4 <___pl_fn_1+0x1ff0>
    2de8: 52800c41     	mov	w1, #0x62               ; =98
    2dec: 140000c0     	b	0x30ec <___pl_fn_1+0x3018>
    2df0: d2800100     	mov	x0, #0x8                ; =8
    2df4: 910383e3     	add	x3, sp, #0xe0
    2df8: f80e03e0     	stur	x0, [sp, #0xe0]
    2dfc: f80e83f4     	stur	x20, [sp, #0xe8]
    2e00: 52800c81     	mov	w1, #0x64               ; =100
    2e04: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2e08: f9400084     	ldr	x4, [x4]
    2e0c: aa1c03e0     	mov	x0, x28
    2e10: d63f0080     	blr	x4
    2e14: 35001740     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2e18: 52800ca1     	mov	w1, #0x65               ; =101
    2e1c: 140000b4     	b	0x30ec <___pl_fn_1+0x3018>
    2e20: aa1c03e0     	mov	x0, x28
    2e24: 1400000a     	b	0x2e4c <___pl_fn_1+0x2d78>
    2e28: aa1c03e0     	mov	x0, x28
    2e2c: 14000008     	b	0x2e4c <___pl_fn_1+0x2d78>
    2e30: aa1c03e0     	mov	x0, x28
    2e34: 14000006     	b	0x2e4c <___pl_fn_1+0x2d78>
    2e38: aa1c03e0     	mov	x0, x28
    2e3c: 14000004     	b	0x2e4c <___pl_fn_1+0x2d78>
    2e40: aa1c03e0     	mov	x0, x28
    2e44: 14000002     	b	0x2e4c <___pl_fn_1+0x2d78>
    2e48: aa1c03e0     	mov	x0, x28
    2e4c: aa1c03e0     	mov	x0, x28
    2e50: b9401c01     	ldr	w1, [x0, #0x1c]
    2e54: 52800062     	mov	w2, #0x3                ; =3
    2e58: 11000f00     	add	w0, w24, #0x3
    2e5c: 6b01001f     	cmp	w0, w1
    2e60: 54ffa429     	b.ls	0x22e4 <___pl_fn_1+0x2210>
    2e64: 52800d01     	mov	w1, #0x68               ; =104
    2e68: 140000a1     	b	0x30ec <___pl_fn_1+0x3018>
    2e6c: d2800100     	mov	x0, #0x8                ; =8
    2e70: 9103c3e3     	add	x3, sp, #0xf0
    2e74: f80f03e0     	stur	x0, [sp, #0xf0]
    2e78: f80f83f4     	stur	x20, [sp, #0xf8]
    2e7c: 52800d41     	mov	w1, #0x6a               ; =106
    2e80: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2e84: f9400084     	ldr	x4, [x4]
    2e88: aa1c03e0     	mov	x0, x28
    2e8c: d63f0080     	blr	x4
    2e90: 35001360     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2e94: 52800d61     	mov	w1, #0x6b               ; =107
    2e98: 14000095     	b	0x30ec <___pl_fn_1+0x3018>
    2e9c: 52800dc1     	mov	w1, #0x6e               ; =110
    2ea0: 52800003     	mov	w3, #0x0                ; =0
    2ea4: 9000000a     	adrp	x10, 0x2000 <___pl_fn_1+0x1f2c>
    2ea8: f940014a     	ldr	x10, [x10]
    2eac: f94083e2     	ldr	x2, [sp, #0x100]
    2eb0: aa1c03e0     	mov	x0, x28
    2eb4: d63f0140     	blr	x10
    2eb8: 35001220     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2ebc: 52800de1     	mov	w1, #0x6f               ; =111
    2ec0: 1400008b     	b	0x30ec <___pl_fn_1+0x3018>
    2ec4: 52800e21     	mov	w1, #0x71               ; =113
    2ec8: 52800143     	mov	w3, #0xa                ; =10
    2ecc: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2ed0: f9400084     	ldr	x4, [x4]
    2ed4: f94083e2     	ldr	x2, [sp, #0x100]
    2ed8: aa1c03e0     	mov	x0, x28
    2edc: d63f0080     	blr	x4
    2ee0: 350010e0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2ee4: 52800e41     	mov	w1, #0x72               ; =114
    2ee8: 14000081     	b	0x30ec <___pl_fn_1+0x3018>
    2eec: 52800e61     	mov	w1, #0x73               ; =115
    2ef0: 52800123     	mov	w3, #0x9                ; =9
    2ef4: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2ef8: f9400084     	ldr	x4, [x4]
    2efc: f94083e2     	ldr	x2, [sp, #0x100]
    2f00: aa1c03e0     	mov	x0, x28
    2f04: d63f0080     	blr	x4
    2f08: 35000fa0     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2f0c: 52800e81     	mov	w1, #0x74               ; =116
    2f10: 14000077     	b	0x30ec <___pl_fn_1+0x3018>
    2f14: 52800f01     	mov	w1, #0x78               ; =120
    2f18: 528000c3     	mov	w3, #0x6                ; =6
    2f1c: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2f20: f9400084     	ldr	x4, [x4]
    2f24: aa1c03e0     	mov	x0, x28
    2f28: d63f0080     	blr	x4
    2f2c: 35000e80     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2f30: 52800f21     	mov	w1, #0x79               ; =121
    2f34: 1400006e     	b	0x30ec <___pl_fn_1+0x3018>
    2f38: 52800f41     	mov	w1, #0x7a               ; =122
    2f3c: 52800083     	mov	w3, #0x4                ; =4
    2f40: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2f44: f9400084     	ldr	x4, [x4]
    2f48: aa1c03e0     	mov	x0, x28
    2f4c: d63f0080     	blr	x4
    2f50: 35000d60     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2f54: 52800f61     	mov	w1, #0x7b               ; =123
    2f58: 14000065     	b	0x30ec <___pl_fn_1+0x3018>
    2f5c: 52800f81     	mov	w1, #0x7c               ; =124
    2f60: 9000000e     	adrp	x14, 0x2000 <___pl_fn_1+0x1f2c>
    2f64: f94001ce     	ldr	x14, [x14]
    2f68: f94087e3     	ldr	x3, [sp, #0x108]
    2f6c: aa1c03e0     	mov	x0, x28
    2f70: d63f01c0     	blr	x14
    2f74: 35000c40     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2f78: 52800fa1     	mov	w1, #0x7d               ; =125
    2f7c: 1400005c     	b	0x30ec <___pl_fn_1+0x3018>
    2f80: 52801001     	mov	w1, #0x80               ; =128
    2f84: 1400005a     	b	0x30ec <___pl_fn_1+0x3018>
    2f88: 52800fe1     	mov	w1, #0x7f               ; =127
    2f8c: 14000058     	b	0x30ec <___pl_fn_1+0x3018>
    2f90: 52800fc1     	mov	w1, #0x7e               ; =126
    2f94: 14000056     	b	0x30ec <___pl_fn_1+0x3018>
    2f98: aa0103e2     	mov	x2, x1
    2f9c: 52801021     	mov	w1, #0x81               ; =129
    2fa0: 52800003     	mov	w3, #0x0                ; =0
    2fa4: 90000004     	adrp	x4, 0x2000 <___pl_fn_1+0x1f2c>
    2fa8: f9400084     	ldr	x4, [x4]
    2fac: aa1c03e0     	mov	x0, x28
    2fb0: d63f0080     	blr	x4
    2fb4: 35000a40     	cbnz	w0, 0x30fc <___pl_fn_1+0x3028>
    2fb8: 52801041     	mov	w1, #0x82               ; =130
    2fbc: 1400004c     	b	0x30ec <___pl_fn_1+0x3018>
    2fc0: 52801061     	mov	w1, #0x83               ; =131
    2fc4: 1400004a     	b	0x30ec <___pl_fn_1+0x3018>
    2fc8: 52800e01     	mov	w1, #0x70               ; =112
    2fcc: 14000048     	b	0x30ec <___pl_fn_1+0x3018>
    2fd0: 52800da1     	mov	w1, #0x6d               ; =109
    2fd4: 14000046     	b	0x30ec <___pl_fn_1+0x3018>
    2fd8: 52800d81     	mov	w1, #0x6c               ; =108
    2fdc: 14000044     	b	0x30ec <___pl_fn_1+0x3018>
    2fe0: 52800ce1     	mov	w1, #0x67               ; =103
    2fe4: 14000042     	b	0x30ec <___pl_fn_1+0x3018>
    2fe8: 52800cc1     	mov	w1, #0x66               ; =102
    2fec: 14000040     	b	0x30ec <___pl_fn_1+0x3018>
    2ff0: 52800c21     	mov	w1, #0x61               ; =97
    2ff4: 1400003e     	b	0x30ec <___pl_fn_1+0x3018>
    2ff8: 52800c01     	mov	w1, #0x60               ; =96
    2ffc: 1400003c     	b	0x30ec <___pl_fn_1+0x3018>
    3000: 52800b21     	mov	w1, #0x59               ; =89
    3004: 1400003a     	b	0x30ec <___pl_fn_1+0x3018>
    3008: 52800b01     	mov	w1, #0x58               ; =88
    300c: 14000038     	b	0x30ec <___pl_fn_1+0x3018>
    3010: 52800ae1     	mov	w1, #0x57               ; =87
    3014: 14000036     	b	0x30ec <___pl_fn_1+0x3018>
    3018: 52800a81     	mov	w1, #0x54               ; =84
    301c: 14000034     	b	0x30ec <___pl_fn_1+0x3018>
    3020: 52800a61     	mov	w1, #0x53               ; =83
    3024: 14000032     	b	0x30ec <___pl_fn_1+0x3018>
    3028: 52800a41     	mov	w1, #0x52               ; =82
    302c: 14000030     	b	0x30ec <___pl_fn_1+0x3018>
    3030: 528009e1     	mov	w1, #0x4f               ; =79
    3034: 1400002e     	b	0x30ec <___pl_fn_1+0x3018>
    3038: 528009c1     	mov	w1, #0x4e               ; =78
    303c: 1400002c     	b	0x30ec <___pl_fn_1+0x3018>
    3040: 528009a1     	mov	w1, #0x4d               ; =77
    3044: 1400002a     	b	0x30ec <___pl_fn_1+0x3018>
    3048: 52800941     	mov	w1, #0x4a               ; =74
    304c: 14000028     	b	0x30ec <___pl_fn_1+0x3018>
    3050: 52800921     	mov	w1, #0x49               ; =73
    3054: 14000026     	b	0x30ec <___pl_fn_1+0x3018>
    3058: 52800841     	mov	w1, #0x42               ; =66
    305c: 14000024     	b	0x30ec <___pl_fn_1+0x3018>
    3060: 52800821     	mov	w1, #0x41               ; =65
    3064: 14000022     	b	0x30ec <___pl_fn_1+0x3018>
    3068: 52800801     	mov	w1, #0x40               ; =64
    306c: 14000020     	b	0x30ec <___pl_fn_1+0x3018>
    3070: 528007a1     	mov	w1, #0x3d               ; =61
    3074: 1400001e     	b	0x30ec <___pl_fn_1+0x3018>
    3078: 52800781     	mov	w1, #0x3c               ; =60
    307c: 1400001c     	b	0x30ec <___pl_fn_1+0x3018>
    3080: 52800761     	mov	w1, #0x3b               ; =59
    3084: 1400001a     	b	0x30ec <___pl_fn_1+0x3018>
    3088: 52800701     	mov	w1, #0x38               ; =56
    308c: 14000018     	b	0x30ec <___pl_fn_1+0x3018>
    3090: 528006e1     	mov	w1, #0x37               ; =55
    3094: 14000016     	b	0x30ec <___pl_fn_1+0x3018>
    3098: 528006c1     	mov	w1, #0x36               ; =54
    309c: 14000014     	b	0x30ec <___pl_fn_1+0x3018>
    30a0: 52800661     	mov	w1, #0x33               ; =51
    30a4: 14000012     	b	0x30ec <___pl_fn_1+0x3018>
    30a8: 52800641     	mov	w1, #0x32               ; =50
    30ac: 14000010     	b	0x30ec <___pl_fn_1+0x3018>
    30b0: 52800561     	mov	w1, #0x2b               ; =43
    30b4: 1400000e     	b	0x30ec <___pl_fn_1+0x3018>
    30b8: 52800541     	mov	w1, #0x2a               ; =42
    30bc: 1400000c     	b	0x30ec <___pl_fn_1+0x3018>
    30c0: 52800521     	mov	w1, #0x29               ; =41
    30c4: 1400000a     	b	0x30ec <___pl_fn_1+0x3018>
    30c8: 528004c1     	mov	w1, #0x26               ; =38
    30cc: 14000008     	b	0x30ec <___pl_fn_1+0x3018>
    30d0: 528004a1     	mov	w1, #0x25               ; =37
    30d4: 14000006     	b	0x30ec <___pl_fn_1+0x3018>
    30d8: 52800481     	mov	w1, #0x24               ; =36
    30dc: 14000004     	b	0x30ec <___pl_fn_1+0x3018>
    30e0: 52800421     	mov	w1, #0x21               ; =33
    30e4: 14000002     	b	0x30ec <___pl_fn_1+0x3018>
    30e8: 52800401     	mov	w1, #0x20               ; =32
    30ec: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2f2c>
    30f0: f9400042     	ldr	x2, [x2]
    30f4: aa1c03e0     	mov	x0, x28
    30f8: d63f0040     	blr	x2
    30fc: 910483ff     	add	sp, sp, #0x120
    3100: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3104: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3108: a8c163f7     	ldp	x23, x24, [sp], #0x10
    310c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3110: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3114: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3118: d65f03c0     	ret

000000000000311c <___pl_fn_2>:
    311c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    3120: 910003fd     	mov	x29, sp
    3124: f81f0ff3     	str	x19, [sp, #-0x10]!
    3128: d10203ff     	sub	sp, sp, #0x80
    312c: aa0303e6     	mov	x6, x3
    3130: b9401003     	ldr	w3, [x0, #0x10]
    3134: 11000465     	add	w5, w3, #0x1
    3138: b9001005     	str	w5, [x0, #0x10]
    313c: aa0003f3     	mov	x19, x0
    3140: 34000761     	cbz	w1, 0x322c <___pl_fn_2+0x110>
    3144: aa1303e0     	mov	x0, x19
    3148: aa0103e5     	mov	x5, x1
    314c: f9400000     	ldr	x0, [x0]
    3150: 2a0203e2     	mov	w2, w2
    3154: 2a0103e1     	mov	w1, w1
    3158: 8b010c01     	add	x1, x0, x1, lsl #3
    315c: f9000c22     	str	x2, [x1, #0x18]
    3160: aa0503e2     	mov	x2, x5
    3164: 34000822     	cbz	w2, 0x3268 <___pl_fn_2+0x14c>
    3168: aa0603e8     	mov	x8, x6
    316c: f9400820     	ldr	x0, [x1, #0x10]
    3170: 927ef800     	and	x0, x0, #0xfffffffffffffffd
    3174: f9000820     	str	x0, [x1, #0x10]
    3178: f9001028     	str	x8, [x1, #0x20]
    317c: aa0503e2     	mov	x2, x5
    3180: 34000902     	cbz	w2, 0x32a0 <___pl_fn_2+0x184>
    3184: f9400820     	ldr	x0, [x1, #0x10]
    3188: 927df800     	and	x0, x0, #0xfffffffffffffffb
    318c: f9000820     	str	x0, [x1, #0x10]
    3190: f9001424     	str	x4, [x1, #0x28]
    3194: aa0503e2     	mov	x2, x5
    3198: 340009e2     	cbz	w2, 0x32d4 <___pl_fn_2+0x1b8>
    319c: f9400820     	ldr	x0, [x1, #0x10]
    31a0: 927cf800     	and	x0, x0, #0xfffffffffffffff7
    31a4: f9000820     	str	x0, [x1, #0x10]
    31a8: d2800002     	mov	x2, #0x0                ; =0
    31ac: f9001822     	str	x2, [x1, #0x30]
    31b0: aa0503e0     	mov	x0, x5
    31b4: 34000ac0     	cbz	w0, 0x330c <___pl_fn_2+0x1f0>
    31b8: f9400829     	ldr	x9, [x1, #0x10]
    31bc: 927bf929     	and	x9, x9, #0xffffffffffffffef
    31c0: f9000829     	str	x9, [x1, #0x10]
    31c4: f9001c22     	str	x2, [x1, #0x38]
    31c8: aa0503e0     	mov	x0, x5
    31cc: 34000ba0     	cbz	w0, 0x3340 <___pl_fn_2+0x224>
    31d0: f9400820     	ldr	x0, [x1, #0x10]
    31d4: 927af800     	and	x0, x0, #0xffffffffffffffdf
    31d8: f9000820     	str	x0, [x1, #0x10]
    31dc: f9002022     	str	x2, [x1, #0x40]
    31e0: aa0503e0     	mov	x0, x5
    31e4: 34000c80     	cbz	w0, 0x3374 <___pl_fn_2+0x258>
    31e8: f9400820     	ldr	x0, [x1, #0x10]
    31ec: 9279f800     	and	x0, x0, #0xffffffffffffffbf
    31f0: f9000820     	str	x0, [x1, #0x10]
    31f4: f9002422     	str	x2, [x1, #0x48]
    31f8: aa0503e0     	mov	x0, x5
    31fc: 34000d60     	cbz	w0, 0x33a8 <___pl_fn_2+0x28c>
    3200: f9400820     	ldr	x0, [x1, #0x10]
    3204: 9278f800     	and	x0, x0, #0xffffffffffffff7f
    3208: f9000820     	str	x0, [x1, #0x10]
    320c: f9002822     	str	x2, [x1, #0x50]
    3210: aa1303e0     	mov	x0, x19
    3214: b9001003     	str	w3, [x0, #0x10]
    3218: aa0503e0     	mov	x0, x5
    321c: 910203ff     	add	sp, sp, #0x80
    3220: f84107f3     	ldr	x19, [sp], #0x10
    3224: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3228: d65f03c0     	ret
    322c: aa0103e5     	mov	x5, x1
    3230: d2800000     	mov	x0, #0x0                ; =0
    3234: 910003e3     	mov	x3, sp
    3238: f80003e0     	stur	x0, [sp]
    323c: 2a0203e0     	mov	w0, w2
    3240: f80083e0     	stur	x0, [sp, #0x8]
    3244: 52801081     	mov	w1, #0x84               ; =132
    3248: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    324c: f9400084     	ldr	x4, [x4]
    3250: aa0503e2     	mov	x2, x5
    3254: aa1303e0     	mov	x0, x19
    3258: d63f0080     	blr	x4
    325c: 35000c60     	cbnz	w0, 0x33e8 <___pl_fn_2+0x2cc>
    3260: 528010a1     	mov	w1, #0x85               ; =133
    3264: 1400005d     	b	0x33d8 <___pl_fn_2+0x2bc>
    3268: d2800020     	mov	x0, #0x1                ; =1
    326c: 910043e3     	add	x3, sp, #0x10
    3270: f80103e0     	stur	x0, [sp, #0x10]
    3274: aa0603e8     	mov	x8, x6
    3278: f80183e8     	stur	x8, [sp, #0x18]
    327c: 528010c1     	mov	w1, #0x86               ; =134
    3280: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3284: f9400084     	ldr	x4, [x4]
    3288: aa0503e2     	mov	x2, x5
    328c: aa1303e0     	mov	x0, x19
    3290: d63f0080     	blr	x4
    3294: 35000aa0     	cbnz	w0, 0x33e8 <___pl_fn_2+0x2cc>
    3298: 528010e1     	mov	w1, #0x87               ; =135
    329c: 1400004f     	b	0x33d8 <___pl_fn_2+0x2bc>
    32a0: d2800040     	mov	x0, #0x2                ; =2
    32a4: 910083e3     	add	x3, sp, #0x20
    32a8: f80203e0     	stur	x0, [sp, #0x20]
    32ac: f80283e4     	stur	x4, [sp, #0x28]
    32b0: 52801101     	mov	w1, #0x88               ; =136
    32b4: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    32b8: f9400084     	ldr	x4, [x4]
    32bc: aa0503e2     	mov	x2, x5
    32c0: aa1303e0     	mov	x0, x19
    32c4: d63f0080     	blr	x4
    32c8: 35000900     	cbnz	w0, 0x33e8 <___pl_fn_2+0x2cc>
    32cc: 52801121     	mov	w1, #0x89               ; =137
    32d0: 14000042     	b	0x33d8 <___pl_fn_2+0x2bc>
    32d4: d2800060     	mov	x0, #0x3                ; =3
    32d8: 9100c3e3     	add	x3, sp, #0x30
    32dc: f80303e0     	stur	x0, [sp, #0x30]
    32e0: d2800000     	mov	x0, #0x0                ; =0
    32e4: f80383e0     	stur	x0, [sp, #0x38]
    32e8: 52801141     	mov	w1, #0x8a               ; =138
    32ec: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    32f0: f9400084     	ldr	x4, [x4]
    32f4: aa0503e2     	mov	x2, x5
    32f8: aa1303e0     	mov	x0, x19
    32fc: d63f0080     	blr	x4
    3300: 35000740     	cbnz	w0, 0x33e8 <___pl_fn_2+0x2cc>
    3304: 52801161     	mov	w1, #0x8b               ; =139
    3308: 14000034     	b	0x33d8 <___pl_fn_2+0x2bc>
    330c: d2800084     	mov	x4, #0x4                ; =4
    3310: 910103e3     	add	x3, sp, #0x40
    3314: f80403e4     	stur	x4, [sp, #0x40]
    3318: f80483e2     	stur	x2, [sp, #0x48]
    331c: 52801181     	mov	w1, #0x8c               ; =140
    3320: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3324: f9400084     	ldr	x4, [x4]
    3328: aa0503e2     	mov	x2, x5
    332c: aa1303e0     	mov	x0, x19
    3330: d63f0080     	blr	x4
    3334: 350005a0     	cbnz	w0, 0x33e8 <___pl_fn_2+0x2cc>
    3338: 528011a1     	mov	w1, #0x8d               ; =141
    333c: 14000027     	b	0x33d8 <___pl_fn_2+0x2bc>
    3340: d28000ae     	mov	x14, #0x5               ; =5
    3344: 910143e3     	add	x3, sp, #0x50
    3348: f80503ee     	stur	x14, [sp, #0x50]
    334c: f80583e2     	stur	x2, [sp, #0x58]
    3350: 528011c1     	mov	w1, #0x8e               ; =142
    3354: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3358: f9400084     	ldr	x4, [x4]
    335c: aa0503e2     	mov	x2, x5
    3360: aa1303e0     	mov	x0, x19
    3364: d63f0080     	blr	x4
    3368: 35000400     	cbnz	w0, 0x33e8 <___pl_fn_2+0x2cc>
    336c: 528011e1     	mov	w1, #0x8f               ; =143
    3370: 1400001a     	b	0x33d8 <___pl_fn_2+0x2bc>
    3374: d28000c0     	mov	x0, #0x6                ; =6
    3378: 910183e3     	add	x3, sp, #0x60
    337c: f80603e0     	stur	x0, [sp, #0x60]
    3380: f80683e2     	stur	x2, [sp, #0x68]
    3384: 52801201     	mov	w1, #0x90               ; =144
    3388: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    338c: f9400084     	ldr	x4, [x4]
    3390: aa0503e2     	mov	x2, x5
    3394: aa1303e0     	mov	x0, x19
    3398: d63f0080     	blr	x4
    339c: 35000260     	cbnz	w0, 0x33e8 <___pl_fn_2+0x2cc>
    33a0: 52801221     	mov	w1, #0x91               ; =145
    33a4: 1400000d     	b	0x33d8 <___pl_fn_2+0x2bc>
    33a8: d28000e0     	mov	x0, #0x7                ; =7
    33ac: 9101c3e3     	add	x3, sp, #0x70
    33b0: f80703e0     	stur	x0, [sp, #0x70]
    33b4: f80783e2     	stur	x2, [sp, #0x78]
    33b8: 52801241     	mov	w1, #0x92               ; =146
    33bc: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    33c0: f9400084     	ldr	x4, [x4]
    33c4: aa0503e2     	mov	x2, x5
    33c8: aa1303e0     	mov	x0, x19
    33cc: d63f0080     	blr	x4
    33d0: 350000c0     	cbnz	w0, 0x33e8 <___pl_fn_2+0x2cc>
    33d4: 52801261     	mov	w1, #0x93               ; =147
    33d8: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2f2c>
    33dc: f9400042     	ldr	x2, [x2]
    33e0: aa1303e0     	mov	x0, x19
    33e4: d63f0040     	blr	x2
    33e8: 52800000     	mov	w0, #0x0                ; =0
    33ec: 910203ff     	add	sp, sp, #0x80
    33f0: f84107f3     	ldr	x19, [sp], #0x10
    33f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    33f8: d65f03c0     	ret

00000000000033fc <___pl_fn_3>:
    33fc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    3400: 910003fd     	mov	x29, sp
    3404: f81f0ff3     	str	x19, [sp, #-0x10]!
    3408: b9401003     	ldr	w3, [x0, #0x10]
    340c: 11000464     	add	w4, w3, #0x1
    3410: b9001004     	str	w4, [x0, #0x10]
    3414: b4000622     	cbz	x2, 0x34d8 <___pl_fn_3+0xdc>
    3418: f100045f     	cmp	x2, #0x1
    341c: 54000400     	b.eq	0x349c <___pl_fn_3+0xa0>
    3420: f100085f     	cmp	x2, #0x2
    3424: 540001e0     	b.eq	0x3460 <___pl_fn_3+0x64>
    3428: 34000761     	cbz	w1, 0x3514 <___pl_fn_3+0x118>
    342c: f9400002     	ldr	x2, [x0]
    3430: aa0003f3     	mov	x19, x0
    3434: 2a0103e0     	mov	w0, w1
    3438: aa0103e5     	mov	x5, x1
    343c: 8b000c41     	add	x1, x2, x0, lsl #3
    3440: f9402820     	ldr	x0, [x1, #0x50]
    3444: f9400821     	ldr	x1, [x1, #0x10]
    3448: 373806a1     	tbnz	w1, #0x7, 0x351c <___pl_fn_3+0x120>
    344c: aa1303e1     	mov	x1, x19
    3450: b9001023     	str	w3, [x1, #0x10]
    3454: f84107f3     	ldr	x19, [sp], #0x10
    3458: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    345c: d65f03c0     	ret
    3460: aa0103e2     	mov	x2, x1
    3464: aa0003f3     	mov	x19, x0
    3468: 340006e2     	cbz	w2, 0x3544 <___pl_fn_3+0x148>
    346c: aa1303e0     	mov	x0, x19
    3470: f9400009     	ldr	x9, [x0]
    3474: 2a0203ea     	mov	w10, w2
    3478: 8b0a0d29     	add	x9, x9, x10, lsl #3
    347c: f9402520     	ldr	x0, [x9, #0x48]
    3480: f940092a     	ldr	x10, [x9, #0x10]
    3484: 3730060a     	tbnz	w10, #0x6, 0x3544 <___pl_fn_3+0x148>
    3488: aa1303e1     	mov	x1, x19
    348c: b9001023     	str	w3, [x1, #0x10]
    3490: f84107f3     	ldr	x19, [sp], #0x10
    3494: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3498: d65f03c0     	ret
    349c: aa0103e2     	mov	x2, x1
    34a0: aa0003f3     	mov	x19, x0
    34a4: 34000622     	cbz	w2, 0x3568 <___pl_fn_3+0x16c>
    34a8: aa1303e0     	mov	x0, x19
    34ac: f9400000     	ldr	x0, [x0]
    34b0: 2a0203e1     	mov	w1, w2
    34b4: 8b010c01     	add	x1, x0, x1, lsl #3
    34b8: f9402020     	ldr	x0, [x1, #0x40]
    34bc: f9400821     	ldr	x1, [x1, #0x10]
    34c0: 37280541     	tbnz	w1, #0x5, 0x3568 <___pl_fn_3+0x16c>
    34c4: aa1303e8     	mov	x8, x19
    34c8: b9001103     	str	w3, [x8, #0x10]
    34cc: f84107f3     	ldr	x19, [sp], #0x10
    34d0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    34d4: d65f03c0     	ret
    34d8: aa0103e2     	mov	x2, x1
    34dc: aa0003f3     	mov	x19, x0
    34e0: 34000562     	cbz	w2, 0x358c <___pl_fn_3+0x190>
    34e4: aa1303e0     	mov	x0, x19
    34e8: f9400000     	ldr	x0, [x0]
    34ec: 2a0203e1     	mov	w1, w2
    34f0: 8b010c01     	add	x1, x0, x1, lsl #3
    34f4: f9401c20     	ldr	x0, [x1, #0x38]
    34f8: f9400821     	ldr	x1, [x1, #0x10]
    34fc: 37200481     	tbnz	w1, #0x4, 0x358c <___pl_fn_3+0x190>
    3500: aa1303e1     	mov	x1, x19
    3504: b9001023     	str	w3, [x1, #0x10]
    3508: f84107f3     	ldr	x19, [sp], #0x10
    350c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3510: d65f03c0     	ret
    3514: aa0103e5     	mov	x5, x1
    3518: aa0003f3     	mov	x19, x0
    351c: 52801281     	mov	w1, #0x94               ; =148
    3520: 528000e3     	mov	w3, #0x7                ; =7
    3524: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3528: f9400084     	ldr	x4, [x4]
    352c: aa0503e2     	mov	x2, x5
    3530: aa1303e0     	mov	x0, x19
    3534: d63f0080     	blr	x4
    3538: 35000420     	cbnz	w0, 0x35bc <___pl_fn_3+0x1c0>
    353c: 528012a1     	mov	w1, #0x95               ; =149
    3540: 1400001b     	b	0x35ac <___pl_fn_3+0x1b0>
    3544: 528012c1     	mov	w1, #0x96               ; =150
    3548: 528000c3     	mov	w3, #0x6                ; =6
    354c: 9000000c     	adrp	x12, 0x3000 <___pl_fn_1+0x2f2c>
    3550: f940018c     	ldr	x12, [x12]
    3554: aa1303e0     	mov	x0, x19
    3558: d63f0180     	blr	x12
    355c: 35000300     	cbnz	w0, 0x35bc <___pl_fn_3+0x1c0>
    3560: 528012e1     	mov	w1, #0x97               ; =151
    3564: 14000012     	b	0x35ac <___pl_fn_3+0x1b0>
    3568: 52801301     	mov	w1, #0x98               ; =152
    356c: 528000a3     	mov	w3, #0x5                ; =5
    3570: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3574: f9400084     	ldr	x4, [x4]
    3578: aa1303e0     	mov	x0, x19
    357c: d63f0080     	blr	x4
    3580: 350001e0     	cbnz	w0, 0x35bc <___pl_fn_3+0x1c0>
    3584: 52801321     	mov	w1, #0x99               ; =153
    3588: 14000009     	b	0x35ac <___pl_fn_3+0x1b0>
    358c: 52801341     	mov	w1, #0x9a               ; =154
    3590: 52800083     	mov	w3, #0x4                ; =4
    3594: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3598: f9400084     	ldr	x4, [x4]
    359c: aa1303e0     	mov	x0, x19
    35a0: d63f0080     	blr	x4
    35a4: 350000c0     	cbnz	w0, 0x35bc <___pl_fn_3+0x1c0>
    35a8: 52801361     	mov	w1, #0x9b               ; =155
    35ac: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2f2c>
    35b0: f9400042     	ldr	x2, [x2]
    35b4: aa1303e0     	mov	x0, x19
    35b8: d63f0040     	blr	x2
    35bc: d2800000     	mov	x0, #0x0                ; =0
    35c0: f84107f3     	ldr	x19, [sp], #0x10
    35c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    35c8: d65f03c0     	ret

00000000000035cc <___pl_fn_4>:
    35cc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    35d0: 910003fd     	mov	x29, sp
    35d4: f81f0ff3     	str	x19, [sp, #-0x10]!
    35d8: d10103ff     	sub	sp, sp, #0x40
    35dc: aa0303ea     	mov	x10, x3
    35e0: b9401003     	ldr	w3, [x0, #0x10]
    35e4: 11000464     	add	w4, w3, #0x1
    35e8: b9001004     	str	w4, [x0, #0x10]
    35ec: aa0003f3     	mov	x19, x0
    35f0: b4000642     	cbz	x2, 0x36b8 <___pl_fn_4+0xec>
    35f4: f100045f     	cmp	x2, #0x1
    35f8: 54000420     	b.eq	0x367c <___pl_fn_4+0xb0>
    35fc: f100085f     	cmp	x2, #0x2
    3600: 54000200     	b.eq	0x3640 <___pl_fn_4+0x74>
    3604: 34000821     	cbz	w1, 0x3708 <___pl_fn_4+0x13c>
    3608: aa1303e0     	mov	x0, x19
    360c: aa0103e2     	mov	x2, x1
    3610: aa0a03e4     	mov	x4, x10
    3614: f940000d     	ldr	x13, [x0]
    3618: 2a0203ee     	mov	w14, w2
    361c: 8b0e0dae     	add	x14, x13, x14, lsl #3
    3620: f94009cf     	ldr	x15, [x14, #0x10]
    3624: 9278f9ef     	and	x15, x15, #0xffffffffffffff7f
    3628: f90009cf     	str	x15, [x14, #0x10]
    362c: 2a0203e0     	mov	w0, w2
    3630: 8b000da0     	add	x0, x13, x0, lsl #3
    3634: f9002804     	str	x4, [x0, #0x50]
    3638: aa1303e0     	mov	x0, x19
    363c: 1400002d     	b	0x36f0 <___pl_fn_4+0x124>
    3640: aa0103e2     	mov	x2, x1
    3644: aa0a03e4     	mov	x4, x10
    3648: 340007e2     	cbz	w2, 0x3744 <___pl_fn_4+0x178>
    364c: aa1303e0     	mov	x0, x19
    3650: f9400001     	ldr	x1, [x0]
    3654: 2a0203e0     	mov	w0, w2
    3658: 8b000c20     	add	x0, x1, x0, lsl #3
    365c: f9400805     	ldr	x5, [x0, #0x10]
    3660: 9279f8a5     	and	x5, x5, #0xffffffffffffffbf
    3664: f9000805     	str	x5, [x0, #0x10]
    3668: 2a0203e0     	mov	w0, w2
    366c: 8b000c20     	add	x0, x1, x0, lsl #3
    3670: f9002404     	str	x4, [x0, #0x48]
    3674: aa1303e0     	mov	x0, x19
    3678: 1400001e     	b	0x36f0 <___pl_fn_4+0x124>
    367c: aa0103e2     	mov	x2, x1
    3680: aa0a03e4     	mov	x4, x10
    3684: 34000782     	cbz	w2, 0x3774 <___pl_fn_4+0x1a8>
    3688: aa1303e0     	mov	x0, x19
    368c: f9400001     	ldr	x1, [x0]
    3690: 2a0203e0     	mov	w0, w2
    3694: 8b000c20     	add	x0, x1, x0, lsl #3
    3698: f9400805     	ldr	x5, [x0, #0x10]
    369c: 927af8a5     	and	x5, x5, #0xffffffffffffffdf
    36a0: f9000805     	str	x5, [x0, #0x10]
    36a4: 2a0203e0     	mov	w0, w2
    36a8: 8b000c20     	add	x0, x1, x0, lsl #3
    36ac: f9002004     	str	x4, [x0, #0x40]
    36b0: aa1303e0     	mov	x0, x19
    36b4: 1400000f     	b	0x36f0 <___pl_fn_4+0x124>
    36b8: aa0103e2     	mov	x2, x1
    36bc: aa0a03e4     	mov	x4, x10
    36c0: 34000722     	cbz	w2, 0x37a4 <___pl_fn_4+0x1d8>
    36c4: aa1303e0     	mov	x0, x19
    36c8: f9400001     	ldr	x1, [x0]
    36cc: 2a0203e0     	mov	w0, w2
    36d0: 8b000c20     	add	x0, x1, x0, lsl #3
    36d4: f9400805     	ldr	x5, [x0, #0x10]
    36d8: 927bf8a5     	and	x5, x5, #0xffffffffffffffef
    36dc: f9000805     	str	x5, [x0, #0x10]
    36e0: 2a0203e0     	mov	w0, w2
    36e4: 8b000c20     	add	x0, x1, x0, lsl #3
    36e8: f9001c04     	str	x4, [x0, #0x38]
    36ec: aa1303e0     	mov	x0, x19
    36f0: aa1303e0     	mov	x0, x19
    36f4: b9001003     	str	w3, [x0, #0x10]
    36f8: 910103ff     	add	sp, sp, #0x40
    36fc: f84107f3     	ldr	x19, [sp], #0x10
    3700: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3704: d65f03c0     	ret
    3708: aa0103e8     	mov	x8, x1
    370c: d28000e7     	mov	x7, #0x7                ; =7
    3710: 910003e3     	mov	x3, sp
    3714: f80003e7     	stur	x7, [sp]
    3718: aa0a03e4     	mov	x4, x10
    371c: f80083e4     	stur	x4, [sp, #0x8]
    3720: 52801381     	mov	w1, #0x9c               ; =156
    3724: 90000009     	adrp	x9, 0x3000 <___pl_fn_1+0x2f2c>
    3728: f9400129     	ldr	x9, [x9]
    372c: aa0803e2     	mov	x2, x8
    3730: aa1303e0     	mov	x0, x19
    3734: d63f0120     	blr	x9
    3738: 35000540     	cbnz	w0, 0x37e0 <___pl_fn_4+0x214>
    373c: 528013a1     	mov	w1, #0x9d               ; =157
    3740: 14000024     	b	0x37d0 <___pl_fn_4+0x204>
    3744: d28000c0     	mov	x0, #0x6                ; =6
    3748: 910043e3     	add	x3, sp, #0x10
    374c: f80103e0     	stur	x0, [sp, #0x10]
    3750: f80183e4     	stur	x4, [sp, #0x18]
    3754: 528013c1     	mov	w1, #0x9e               ; =158
    3758: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    375c: f9400084     	ldr	x4, [x4]
    3760: aa1303e0     	mov	x0, x19
    3764: d63f0080     	blr	x4
    3768: 350003c0     	cbnz	w0, 0x37e0 <___pl_fn_4+0x214>
    376c: 528013e1     	mov	w1, #0x9f               ; =159
    3770: 14000018     	b	0x37d0 <___pl_fn_4+0x204>
    3774: d28000a0     	mov	x0, #0x5                ; =5
    3778: 910083e3     	add	x3, sp, #0x20
    377c: f80203e0     	stur	x0, [sp, #0x20]
    3780: f80283e4     	stur	x4, [sp, #0x28]
    3784: 52801401     	mov	w1, #0xa0               ; =160
    3788: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    378c: f9400084     	ldr	x4, [x4]
    3790: aa1303e0     	mov	x0, x19
    3794: d63f0080     	blr	x4
    3798: 35000240     	cbnz	w0, 0x37e0 <___pl_fn_4+0x214>
    379c: 52801421     	mov	w1, #0xa1               ; =161
    37a0: 1400000c     	b	0x37d0 <___pl_fn_4+0x204>
    37a4: d2800080     	mov	x0, #0x4                ; =4
    37a8: 9100c3e3     	add	x3, sp, #0x30
    37ac: f80303e0     	stur	x0, [sp, #0x30]
    37b0: f80383e4     	stur	x4, [sp, #0x38]
    37b4: 52801441     	mov	w1, #0xa2               ; =162
    37b8: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    37bc: f9400084     	ldr	x4, [x4]
    37c0: aa1303e0     	mov	x0, x19
    37c4: d63f0080     	blr	x4
    37c8: 350000c0     	cbnz	w0, 0x37e0 <___pl_fn_4+0x214>
    37cc: 52801461     	mov	w1, #0xa3               ; =163
    37d0: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2f2c>
    37d4: f9400042     	ldr	x2, [x2]
    37d8: aa1303e0     	mov	x0, x19
    37dc: d63f0040     	blr	x2
    37e0: 910103ff     	add	sp, sp, #0x40
    37e4: f84107f3     	ldr	x19, [sp], #0x10
    37e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    37ec: d65f03c0     	ret

00000000000037f0 <___pl_fn_5>:
    37f0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    37f4: 910003fd     	mov	x29, sp
    37f8: f81f0ff3     	str	x19, [sp, #-0x10]!
    37fc: d10083ff     	sub	sp, sp, #0x20
    3800: aa0303e4     	mov	x4, x3
    3804: aa0203e8     	mov	x8, x2
    3808: b9401003     	ldr	w3, [x0, #0x10]
    380c: 11000462     	add	w2, w3, #0x1
    3810: b9001002     	str	w2, [x0, #0x10]
    3814: aa0003f3     	mov	x19, x0
    3818: 340005a1     	cbz	w1, 0x38cc <___pl_fn_5+0xdc>
    381c: aa1303e0     	mov	x0, x19
    3820: aa0103e2     	mov	x2, x1
    3824: aa0403e7     	mov	x7, x4
    3828: f9400004     	ldr	x4, [x0]
    382c: 2a0703e0     	mov	w0, w7
    3830: 2a0203e1     	mov	w1, w2
    3834: aa0203e5     	mov	x5, x2
    3838: 8b010c82     	add	x2, x4, x1, lsl #3
    383c: f9000c40     	str	x0, [x2, #0x18]
    3840: aa0803e2     	mov	x2, x8
    3844: 6b07005f     	cmp	w2, w7
    3848: 54000340     	b.eq	0x38b0 <___pl_fn_5+0xc0>
    384c: 34000a02     	cbz	w2, 0x398c <___pl_fn_5+0x19c>
    3850: aa0203e8     	mov	x8, x2
    3854: 340005c2     	cbz	w2, 0x390c <___pl_fn_5+0x11c>
    3858: 2a0203e0     	mov	w0, w2
    385c: 8b000c86     	add	x6, x4, x0, lsl #3
    3860: b94018c5     	ldr	w5, [x6, #0x18]
    3864: 34000545     	cbz	w5, 0x390c <___pl_fn_5+0x11c>
    3868: 6b0700bf     	cmp	w5, w7
    386c: 54000141     	b.ne	0x3894 <___pl_fn_5+0xa4>
    3870: 34000602     	cbz	w2, 0x3930 <___pl_fn_5+0x140>
    3874: f9000cc1     	str	x1, [x6, #0x18]
    3878: aa1303e0     	mov	x0, x19
    387c: b9001003     	str	w3, [x0, #0x10]
    3880: aa0803e0     	mov	x0, x8
    3884: 910083ff     	add	sp, sp, #0x20
    3888: f84107f3     	ldr	x19, [sp], #0x10
    388c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3890: d65f03c0     	ret
    3894: aa0803e0     	mov	x0, x8
    3898: 34000642     	cbz	w2, 0x3960 <___pl_fn_5+0x170>
    389c: 34000625     	cbz	w5, 0x3960 <___pl_fn_5+0x170>
    38a0: 34000725     	cbz	w5, 0x3984 <___pl_fn_5+0x194>
    38a4: aa0503e2     	mov	x2, x5
    38a8: aa0003e8     	mov	x8, x0
    38ac: 17ffffea     	b	0x3854 <___pl_fn_5+0x64>
    38b0: aa1303e0     	mov	x0, x19
    38b4: b9001003     	str	w3, [x0, #0x10]
    38b8: aa0503e0     	mov	x0, x5
    38bc: 910083ff     	add	sp, sp, #0x20
    38c0: f84107f3     	ldr	x19, [sp], #0x10
    38c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    38c8: d65f03c0     	ret
    38cc: aa0103e5     	mov	x5, x1
    38d0: d2800000     	mov	x0, #0x0                ; =0
    38d4: 910003e3     	mov	x3, sp
    38d8: f80003e0     	stur	x0, [sp]
    38dc: aa0403e7     	mov	x7, x4
    38e0: 2a0703e0     	mov	w0, w7
    38e4: f80083e0     	stur	x0, [sp, #0x8]
    38e8: 52801481     	mov	w1, #0xa4               ; =164
    38ec: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    38f0: f9400084     	ldr	x4, [x4]
    38f4: aa0503e2     	mov	x2, x5
    38f8: aa1303e0     	mov	x0, x19
    38fc: d63f0080     	blr	x4
    3900: 35000500     	cbnz	w0, 0x39a0 <___pl_fn_5+0x1b0>
    3904: 528014a1     	mov	w1, #0xa5               ; =165
    3908: 14000022     	b	0x3990 <___pl_fn_5+0x1a0>
    390c: 528014e1     	mov	w1, #0xa7               ; =167
    3910: 52800003     	mov	w3, #0x0                ; =0
    3914: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3918: f9400084     	ldr	x4, [x4]
    391c: aa1303e0     	mov	x0, x19
    3920: d63f0080     	blr	x4
    3924: 350003e0     	cbnz	w0, 0x39a0 <___pl_fn_5+0x1b0>
    3928: 52801501     	mov	w1, #0xa8               ; =168
    392c: 14000019     	b	0x3990 <___pl_fn_5+0x1a0>
    3930: d2800008     	mov	x8, #0x0                ; =0
    3934: 910043e3     	add	x3, sp, #0x10
    3938: f80103e8     	stur	x8, [sp, #0x10]
    393c: f80183e1     	stur	x1, [sp, #0x18]
    3940: 52801521     	mov	w1, #0xa9               ; =169
    3944: 9000000a     	adrp	x10, 0x3000 <___pl_fn_1+0x2f2c>
    3948: f940014a     	ldr	x10, [x10]
    394c: aa1303e0     	mov	x0, x19
    3950: d63f0140     	blr	x10
    3954: 35000260     	cbnz	w0, 0x39a0 <___pl_fn_5+0x1b0>
    3958: 52801541     	mov	w1, #0xaa               ; =170
    395c: 1400000d     	b	0x3990 <___pl_fn_5+0x1a0>
    3960: 52801561     	mov	w1, #0xab               ; =171
    3964: 52800003     	mov	w3, #0x0                ; =0
    3968: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    396c: f9400084     	ldr	x4, [x4]
    3970: aa1303e0     	mov	x0, x19
    3974: d63f0080     	blr	x4
    3978: 35000140     	cbnz	w0, 0x39a0 <___pl_fn_5+0x1b0>
    397c: 52801581     	mov	w1, #0xac               ; =172
    3980: 14000004     	b	0x3990 <___pl_fn_5+0x1a0>
    3984: 528015a1     	mov	w1, #0xad               ; =173
    3988: 14000002     	b	0x3990 <___pl_fn_5+0x1a0>
    398c: 528014c1     	mov	w1, #0xa6               ; =166
    3990: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2f2c>
    3994: f9400042     	ldr	x2, [x2]
    3998: aa1303e0     	mov	x0, x19
    399c: d63f0040     	blr	x2
    39a0: 52800000     	mov	w0, #0x0                ; =0
    39a4: 910083ff     	add	sp, sp, #0x20
    39a8: f84107f3     	ldr	x19, [sp], #0x10
    39ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    39b0: d65f03c0     	ret

00000000000039b4 <___pl_fn_6>:
    39b4: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    39b8: 910003fd     	mov	x29, sp
    39bc: f81f0ff3     	str	x19, [sp, #-0x10]!
    39c0: d10183ff     	sub	sp, sp, #0x60
    39c4: aa0303e4     	mov	x4, x3
    39c8: b940100c     	ldr	w12, [x0, #0x10]
    39cc: 1100058d     	add	w13, w12, #0x1
    39d0: b900100d     	str	w13, [x0, #0x10]
    39d4: aa0003f3     	mov	x19, x0
    39d8: f100045f     	cmp	x2, #0x1
    39dc: 54000800     	b.eq	0x3adc <___pl_fn_6+0x128>
    39e0: f100085f     	cmp	x2, #0x2
    39e4: 54000660     	b.eq	0x3ab0 <___pl_fn_6+0xfc>
    39e8: f1000c5f     	cmp	x2, #0x3
    39ec: 540004c0     	b.eq	0x3a84 <___pl_fn_6+0xd0>
    39f0: f100105f     	cmp	x2, #0x4
    39f4: 54000320     	b.eq	0x3a58 <___pl_fn_6+0xa4>
    39f8: f100145f     	cmp	x2, #0x5
    39fc: 54000180     	b.eq	0x3a2c <___pl_fn_6+0x78>
    3a00: 340008e1     	cbz	w1, 0x3b1c <___pl_fn_6+0x168>
    3a04: aa0103e2     	mov	x2, x1
    3a08: aa1303e1     	mov	x1, x19
    3a0c: aa0403e0     	mov	x0, x4
    3a10: f9400021     	ldr	x1, [x1]
    3a14: 2a0003e0     	mov	w0, w0
    3a18: 2a0203e2     	mov	w2, w2
    3a1c: 8b020c21     	add	x1, x1, x2, lsl #3
    3a20: f9002c20     	str	x0, [x1, #0x58]
    3a24: aa1303e0     	mov	x0, x19
    3a28: 14000037     	b	0x3b04 <___pl_fn_6+0x150>
    3a2c: aa0403e0     	mov	x0, x4
    3a30: aa0103e2     	mov	x2, x1
    3a34: 34000922     	cbz	w2, 0x3b58 <___pl_fn_6+0x1a4>
    3a38: aa1303e4     	mov	x4, x19
    3a3c: f9400081     	ldr	x1, [x4]
    3a40: 2a0003e0     	mov	w0, w0
    3a44: 2a0203e2     	mov	w2, w2
    3a48: 8b020c21     	add	x1, x1, x2, lsl #3
    3a4c: f9002820     	str	x0, [x1, #0x50]
    3a50: aa1303e0     	mov	x0, x19
    3a54: 1400002c     	b	0x3b04 <___pl_fn_6+0x150>
    3a58: aa0403e0     	mov	x0, x4
    3a5c: aa0103e2     	mov	x2, x1
    3a60: 34000962     	cbz	w2, 0x3b8c <___pl_fn_6+0x1d8>
    3a64: aa1303e1     	mov	x1, x19
    3a68: f9400021     	ldr	x1, [x1]
    3a6c: 2a0003e0     	mov	w0, w0
    3a70: 2a0203e2     	mov	w2, w2
    3a74: 8b020c21     	add	x1, x1, x2, lsl #3
    3a78: f9002420     	str	x0, [x1, #0x48]
    3a7c: aa1303e0     	mov	x0, x19
    3a80: 14000021     	b	0x3b04 <___pl_fn_6+0x150>
    3a84: aa0403e0     	mov	x0, x4
    3a88: aa0103e2     	mov	x2, x1
    3a8c: 340009a2     	cbz	w2, 0x3bc0 <___pl_fn_6+0x20c>
    3a90: aa1303e1     	mov	x1, x19
    3a94: f9400021     	ldr	x1, [x1]
    3a98: 2a0003e0     	mov	w0, w0
    3a9c: 2a0203e2     	mov	w2, w2
    3aa0: 8b020c21     	add	x1, x1, x2, lsl #3
    3aa4: f9002020     	str	x0, [x1, #0x40]
    3aa8: aa1303e0     	mov	x0, x19
    3aac: 14000016     	b	0x3b04 <___pl_fn_6+0x150>
    3ab0: aa0403e0     	mov	x0, x4
    3ab4: aa0103e2     	mov	x2, x1
    3ab8: 340009e2     	cbz	w2, 0x3bf4 <___pl_fn_6+0x240>
    3abc: aa1303e7     	mov	x7, x19
    3ac0: f94000e9     	ldr	x9, [x7]
    3ac4: 2a0003ea     	mov	w10, w0
    3ac8: 2a0203eb     	mov	w11, w2
    3acc: 8b0b0d29     	add	x9, x9, x11, lsl #3
    3ad0: f9001d2a     	str	x10, [x9, #0x38]
    3ad4: aa1303e0     	mov	x0, x19
    3ad8: 1400000b     	b	0x3b04 <___pl_fn_6+0x150>
    3adc: aa0403e0     	mov	x0, x4
    3ae0: aa0103e2     	mov	x2, x1
    3ae4: 34000a22     	cbz	w2, 0x3c28 <___pl_fn_6+0x274>
    3ae8: aa1303e1     	mov	x1, x19
    3aec: f9400021     	ldr	x1, [x1]
    3af0: 2a0003e0     	mov	w0, w0
    3af4: 2a0203e2     	mov	w2, w2
    3af8: 8b020c21     	add	x1, x1, x2, lsl #3
    3afc: f9001820     	str	x0, [x1, #0x30]
    3b00: aa1303e0     	mov	x0, x19
    3b04: aa1303e0     	mov	x0, x19
    3b08: b900100c     	str	w12, [x0, #0x10]
    3b0c: 910183ff     	add	sp, sp, #0x60
    3b10: f84107f3     	ldr	x19, [sp], #0x10
    3b14: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3b18: d65f03c0     	ret
    3b1c: aa0103e2     	mov	x2, x1
    3b20: d2800100     	mov	x0, #0x8                ; =8
    3b24: 910003e3     	mov	x3, sp
    3b28: f80003e0     	stur	x0, [sp]
    3b2c: aa0403e0     	mov	x0, x4
    3b30: 2a0003e0     	mov	w0, w0
    3b34: f80083e0     	stur	x0, [sp, #0x8]
    3b38: 528015c1     	mov	w1, #0xae               ; =174
    3b3c: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3b40: f9400084     	ldr	x4, [x4]
    3b44: aa1303e0     	mov	x0, x19
    3b48: d63f0080     	blr	x4
    3b4c: 350008e0     	cbnz	w0, 0x3c68 <___pl_fn_6+0x2b4>
    3b50: 528015e1     	mov	w1, #0xaf               ; =175
    3b54: 14000041     	b	0x3c58 <___pl_fn_6+0x2a4>
    3b58: d28000e1     	mov	x1, #0x7                ; =7
    3b5c: 910043e3     	add	x3, sp, #0x10
    3b60: f80103e1     	stur	x1, [sp, #0x10]
    3b64: 2a0003e0     	mov	w0, w0
    3b68: f80183e0     	stur	x0, [sp, #0x18]
    3b6c: 52801601     	mov	w1, #0xb0               ; =176
    3b70: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3b74: f9400084     	ldr	x4, [x4]
    3b78: aa1303e0     	mov	x0, x19
    3b7c: d63f0080     	blr	x4
    3b80: 35000740     	cbnz	w0, 0x3c68 <___pl_fn_6+0x2b4>
    3b84: 52801621     	mov	w1, #0xb1               ; =177
    3b88: 14000034     	b	0x3c58 <___pl_fn_6+0x2a4>
    3b8c: d28000c1     	mov	x1, #0x6                ; =6
    3b90: 910083e3     	add	x3, sp, #0x20
    3b94: f80203e1     	stur	x1, [sp, #0x20]
    3b98: 2a0003e0     	mov	w0, w0
    3b9c: f80283e0     	stur	x0, [sp, #0x28]
    3ba0: 52801641     	mov	w1, #0xb2               ; =178
    3ba4: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3ba8: f9400084     	ldr	x4, [x4]
    3bac: aa1303e0     	mov	x0, x19
    3bb0: d63f0080     	blr	x4
    3bb4: 350005a0     	cbnz	w0, 0x3c68 <___pl_fn_6+0x2b4>
    3bb8: 52801661     	mov	w1, #0xb3               ; =179
    3bbc: 14000027     	b	0x3c58 <___pl_fn_6+0x2a4>
    3bc0: d28000a1     	mov	x1, #0x5                ; =5
    3bc4: 9100c3e3     	add	x3, sp, #0x30
    3bc8: f80303e1     	stur	x1, [sp, #0x30]
    3bcc: 2a0003e0     	mov	w0, w0
    3bd0: f80383e0     	stur	x0, [sp, #0x38]
    3bd4: 52801681     	mov	w1, #0xb4               ; =180
    3bd8: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3bdc: f9400084     	ldr	x4, [x4]
    3be0: aa1303e0     	mov	x0, x19
    3be4: d63f0080     	blr	x4
    3be8: 35000400     	cbnz	w0, 0x3c68 <___pl_fn_6+0x2b4>
    3bec: 528016a1     	mov	w1, #0xb5               ; =181
    3bf0: 1400001a     	b	0x3c58 <___pl_fn_6+0x2a4>
    3bf4: d2800084     	mov	x4, #0x4                ; =4
    3bf8: 910103e3     	add	x3, sp, #0x40
    3bfc: f80403e4     	stur	x4, [sp, #0x40]
    3c00: 2a0003e4     	mov	w4, w0
    3c04: f80483e4     	stur	x4, [sp, #0x48]
    3c08: 528016c1     	mov	w1, #0xb6               ; =182
    3c0c: 90000005     	adrp	x5, 0x3000 <___pl_fn_1+0x2f2c>
    3c10: f94000a5     	ldr	x5, [x5]
    3c14: aa1303e0     	mov	x0, x19
    3c18: d63f00a0     	blr	x5
    3c1c: 35000260     	cbnz	w0, 0x3c68 <___pl_fn_6+0x2b4>
    3c20: 528016e1     	mov	w1, #0xb7               ; =183
    3c24: 1400000d     	b	0x3c58 <___pl_fn_6+0x2a4>
    3c28: d280006d     	mov	x13, #0x3               ; =3
    3c2c: 910143e3     	add	x3, sp, #0x50
    3c30: f80503ed     	stur	x13, [sp, #0x50]
    3c34: 2a0003ee     	mov	w14, w0
    3c38: f80583ee     	stur	x14, [sp, #0x58]
    3c3c: 52801701     	mov	w1, #0xb8               ; =184
    3c40: 9000000f     	adrp	x15, 0x3000 <___pl_fn_1+0x2f2c>
    3c44: f94001ef     	ldr	x15, [x15]
    3c48: aa1303e0     	mov	x0, x19
    3c4c: d63f01e0     	blr	x15
    3c50: 350000c0     	cbnz	w0, 0x3c68 <___pl_fn_6+0x2b4>
    3c54: 52801721     	mov	w1, #0xb9               ; =185
    3c58: 90000002     	adrp	x2, 0x3000 <___pl_fn_1+0x2f2c>
    3c5c: f9400042     	ldr	x2, [x2]
    3c60: aa1303e0     	mov	x0, x19
    3c64: d63f0040     	blr	x2
    3c68: 910183ff     	add	sp, sp, #0x60
    3c6c: f84107f3     	ldr	x19, [sp], #0x10
    3c70: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3c74: d65f03c0     	ret

0000000000003c78 <___pl_fn_7>:
    3c78: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    3c7c: 910003fd     	mov	x29, sp
    3c80: f81f0ff3     	str	x19, [sp, #-0x10]!
    3c84: b9401003     	ldr	w3, [x0, #0x10]
    3c88: 11000464     	add	w4, w3, #0x1
    3c8c: b9001004     	str	w4, [x0, #0x10]
    3c90: f100045f     	cmp	x2, #0x1
    3c94: 540009c0     	b.eq	0x3dcc <___pl_fn_7+0x154>
    3c98: f100085f     	cmp	x2, #0x2
    3c9c: 540007c0     	b.eq	0x3d94 <___pl_fn_7+0x11c>
    3ca0: f1000c5f     	cmp	x2, #0x3
    3ca4: 540005c0     	b.eq	0x3d5c <___pl_fn_7+0xe4>
    3ca8: f100105f     	cmp	x2, #0x4
    3cac: 540003c0     	b.eq	0x3d24 <___pl_fn_7+0xac>
    3cb0: f100145f     	cmp	x2, #0x5
    3cb4: 540001c0     	b.eq	0x3cec <___pl_fn_7+0x74>
    3cb8: 34000a61     	cbz	w1, 0x3e04 <___pl_fn_7+0x18c>
    3cbc: f9400002     	ldr	x2, [x0]
    3cc0: aa0003f3     	mov	x19, x0
    3cc4: 2a0103e0     	mov	w0, w1
    3cc8: aa0103e5     	mov	x5, x1
    3ccc: 8b000c40     	add	x0, x2, x0, lsl #3
    3cd0: b9405800     	ldr	w0, [x0, #0x58]
    3cd4: 340009c0     	cbz	w0, 0x3e0c <___pl_fn_7+0x194>
    3cd8: aa1303e1     	mov	x1, x19
    3cdc: b9001023     	str	w3, [x1, #0x10]
    3ce0: f84107f3     	ldr	x19, [sp], #0x10
    3ce4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3ce8: d65f03c0     	ret
    3cec: aa0103e2     	mov	x2, x1
    3cf0: aa0003f3     	mov	x19, x0
    3cf4: 34000a02     	cbz	w2, 0x3e34 <___pl_fn_7+0x1bc>
    3cf8: aa1303e0     	mov	x0, x19
    3cfc: f9400000     	ldr	x0, [x0]
    3d00: 2a0203e1     	mov	w1, w2
    3d04: 8b010c00     	add	x0, x0, x1, lsl #3
    3d08: b9405000     	ldr	w0, [x0, #0x50]
    3d0c: 34000940     	cbz	w0, 0x3e34 <___pl_fn_7+0x1bc>
    3d10: aa1303e1     	mov	x1, x19
    3d14: b9001023     	str	w3, [x1, #0x10]
    3d18: f84107f3     	ldr	x19, [sp], #0x10
    3d1c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3d20: d65f03c0     	ret
    3d24: aa0103e2     	mov	x2, x1
    3d28: aa0003f3     	mov	x19, x0
    3d2c: 34000962     	cbz	w2, 0x3e58 <___pl_fn_7+0x1e0>
    3d30: aa1303e0     	mov	x0, x19
    3d34: f9400000     	ldr	x0, [x0]
    3d38: 2a0203e1     	mov	w1, w2
    3d3c: 8b010c00     	add	x0, x0, x1, lsl #3
    3d40: b9404800     	ldr	w0, [x0, #0x48]
    3d44: 340008a0     	cbz	w0, 0x3e58 <___pl_fn_7+0x1e0>
    3d48: aa1303e1     	mov	x1, x19
    3d4c: b9001023     	str	w3, [x1, #0x10]
    3d50: f84107f3     	ldr	x19, [sp], #0x10
    3d54: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3d58: d65f03c0     	ret
    3d5c: aa0103e2     	mov	x2, x1
    3d60: aa0003f3     	mov	x19, x0
    3d64: 340008c2     	cbz	w2, 0x3e7c <___pl_fn_7+0x204>
    3d68: aa1303e0     	mov	x0, x19
    3d6c: f9400000     	ldr	x0, [x0]
    3d70: 2a0203e1     	mov	w1, w2
    3d74: 8b010c00     	add	x0, x0, x1, lsl #3
    3d78: b9404000     	ldr	w0, [x0, #0x40]
    3d7c: 34000800     	cbz	w0, 0x3e7c <___pl_fn_7+0x204>
    3d80: aa1303e1     	mov	x1, x19
    3d84: b9001023     	str	w3, [x1, #0x10]
    3d88: f84107f3     	ldr	x19, [sp], #0x10
    3d8c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3d90: d65f03c0     	ret
    3d94: aa0103e2     	mov	x2, x1
    3d98: aa0003f3     	mov	x19, x0
    3d9c: 34000822     	cbz	w2, 0x3ea0 <___pl_fn_7+0x228>
    3da0: aa1303e0     	mov	x0, x19
    3da4: f9400000     	ldr	x0, [x0]
    3da8: 2a0203e1     	mov	w1, w2
    3dac: 8b010c00     	add	x0, x0, x1, lsl #3
    3db0: b9403800     	ldr	w0, [x0, #0x38]
    3db4: 34000760     	cbz	w0, 0x3ea0 <___pl_fn_7+0x228>
    3db8: aa1303e1     	mov	x1, x19
    3dbc: b9001023     	str	w3, [x1, #0x10]
    3dc0: f84107f3     	ldr	x19, [sp], #0x10
    3dc4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3dc8: d65f03c0     	ret
    3dcc: aa0103e2     	mov	x2, x1
    3dd0: aa0003f3     	mov	x19, x0
    3dd4: 34000782     	cbz	w2, 0x3ec4 <___pl_fn_7+0x24c>
    3dd8: aa1303e0     	mov	x0, x19
    3ddc: f9400008     	ldr	x8, [x0]
    3de0: 2a0203e9     	mov	w9, w2
    3de4: 8b090d08     	add	x8, x8, x9, lsl #3
    3de8: b9403100     	ldr	w0, [x8, #0x30]
    3dec: 340006c0     	cbz	w0, 0x3ec4 <___pl_fn_7+0x24c>
    3df0: aa1303e1     	mov	x1, x19
    3df4: b9001023     	str	w3, [x1, #0x10]
    3df8: f84107f3     	ldr	x19, [sp], #0x10
    3dfc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3e00: d65f03c0     	ret
    3e04: aa0103e5     	mov	x5, x1
    3e08: aa0003f3     	mov	x19, x0
    3e0c: 52801741     	mov	w1, #0xba               ; =186
    3e10: 52800103     	mov	w3, #0x8                ; =8
    3e14: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3e18: f9400084     	ldr	x4, [x4]
    3e1c: aa0503e2     	mov	x2, x5
    3e20: aa1303e0     	mov	x0, x19
    3e24: d63f0080     	blr	x4
    3e28: 35000660     	cbnz	w0, 0x3ef4 <___pl_fn_7+0x27c>
    3e2c: 52801761     	mov	w1, #0xbb               ; =187
    3e30: 1400002d     	b	0x3ee4 <___pl_fn_7+0x26c>
    3e34: 52801781     	mov	w1, #0xbc               ; =188
    3e38: 528000e3     	mov	w3, #0x7                ; =7
    3e3c: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3e40: f9400084     	ldr	x4, [x4]
    3e44: aa1303e0     	mov	x0, x19
    3e48: d63f0080     	blr	x4
    3e4c: 35000540     	cbnz	w0, 0x3ef4 <___pl_fn_7+0x27c>
    3e50: 528017a1     	mov	w1, #0xbd               ; =189
    3e54: 14000024     	b	0x3ee4 <___pl_fn_7+0x26c>
    3e58: 528017c1     	mov	w1, #0xbe               ; =190
    3e5c: 528000c3     	mov	w3, #0x6                ; =6
    3e60: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3e64: f9400084     	ldr	x4, [x4]
    3e68: aa1303e0     	mov	x0, x19
    3e6c: d63f0080     	blr	x4
    3e70: 35000420     	cbnz	w0, 0x3ef4 <___pl_fn_7+0x27c>
    3e74: 528017e1     	mov	w1, #0xbf               ; =191
    3e78: 1400001b     	b	0x3ee4 <___pl_fn_7+0x26c>
    3e7c: 52801801     	mov	w1, #0xc0               ; =192
    3e80: 528000a3     	mov	w3, #0x5                ; =5
    3e84: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3e88: f9400084     	ldr	x4, [x4]
    3e8c: aa1303e0     	mov	x0, x19
    3e90: d63f0080     	blr	x4
    3e94: 35000300     	cbnz	w0, 0x3ef4 <___pl_fn_7+0x27c>
    3e98: 52801821     	mov	w1, #0xc1               ; =193
    3e9c: 14000012     	b	0x3ee4 <___pl_fn_7+0x26c>
    3ea0: 52801841     	mov	w1, #0xc2               ; =194
    3ea4: 52800083     	mov	w3, #0x4                ; =4
    3ea8: 90000004     	adrp	x4, 0x3000 <___pl_fn_1+0x2f2c>
    3eac: f9400084     	ldr	x4, [x4]
    3eb0: aa1303e0     	mov	x0, x19
    3eb4: d63f0080     	blr	x4
    3eb8: 350001e0     	cbnz	w0, 0x3ef4 <___pl_fn_7+0x27c>
    3ebc: 52801861     	mov	w1, #0xc3               ; =195
    3ec0: 14000009     	b	0x3ee4 <___pl_fn_7+0x26c>
    3ec4: 52801881     	mov	w1, #0xc4               ; =196
    3ec8: 52800063     	mov	w3, #0x3                ; =3
    3ecc: 9000000a     	adrp	x10, 0x3000 <___pl_fn_1+0x2f2c>
    3ed0: f940014a     	ldr	x10, [x10]
    3ed4: aa1303e0     	mov	x0, x19
    3ed8: d63f0140     	blr	x10
    3edc: 350000c0     	cbnz	w0, 0x3ef4 <___pl_fn_7+0x27c>
    3ee0: 528018a1     	mov	w1, #0xc5               ; =197
    3ee4: 9000000e     	adrp	x14, 0x3000 <___pl_fn_1+0x2f2c>
    3ee8: f94001ce     	ldr	x14, [x14]
    3eec: aa1303e0     	mov	x0, x19
    3ef0: d63f01c0     	blr	x14
    3ef4: 52800000     	mov	w0, #0x0                ; =0
    3ef8: f84107f3     	ldr	x19, [sp], #0x10
    3efc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3f00: d65f03c0     	ret

0000000000003f04 <___pl_fn_8>:
    3f04: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    3f08: 910003fd     	mov	x29, sp
    3f0c: f81f0ff3     	str	x19, [sp, #-0x10]!
    3f10: d10243ff     	sub	sp, sp, #0x90
    3f14: aa0303eb     	mov	x11, x3
    3f18: b940100a     	ldr	w10, [x0, #0x10]
    3f1c: 11000543     	add	w3, w10, #0x1
    3f20: b9001003     	str	w3, [x0, #0x10]
    3f24: aa0003f3     	mov	x19, x0
    3f28: 34000861     	cbz	w1, 0x4034 <___pl_fn_8+0x130>
    3f2c: aa0203ec     	mov	x12, x2
    3f30: aa0103e2     	mov	x2, x1
    3f34: aa1303e0     	mov	x0, x19
    3f38: f9400008     	ldr	x8, [x0]
    3f3c: aa0c03e9     	mov	x9, x12
    3f40: 2a0903e9     	mov	w9, w9
    3f44: 2a0203e1     	mov	w1, w2
    3f48: 8b010d03     	add	x3, x8, x1, lsl #3
    3f4c: f9002869     	str	x9, [x3, #0x50]
    3f50: aa0c03ef     	mov	x15, x12
    3f54: 340008ef     	cbz	w15, 0x4070 <___pl_fn_8+0x16c>
    3f58: 8b090d08     	add	x8, x8, x9, lsl #3
    3f5c: b9401909     	ldr	w9, [x8, #0x18]
    3f60: 34000889     	cbz	w9, 0x4070 <___pl_fn_8+0x16c>
    3f64: 340009a2     	cbz	w2, 0x4098 <___pl_fn_8+0x194>
    3f68: 2a0903e0     	mov	w0, w9
    3f6c: f9000c60     	str	x0, [x3, #0x18]
    3f70: 34000ae2     	cbz	w2, 0x40cc <___pl_fn_8+0x1c8>
    3f74: aa0b03e9     	mov	x9, x11
    3f78: f940086b     	ldr	x11, [x3, #0x10]
    3f7c: 927ef96b     	and	x11, x11, #0xfffffffffffffffd
    3f80: f900086b     	str	x11, [x3, #0x10]
    3f84: f9001069     	str	x9, [x3, #0x20]
    3f88: aa0903eb     	mov	x11, x9
    3f8c: 34000ba2     	cbz	w2, 0x4100 <___pl_fn_8+0x1fc>
    3f90: f9400860     	ldr	x0, [x3, #0x10]
    3f94: 927df800     	and	x0, x0, #0xfffffffffffffffb
    3f98: f9000860     	str	x0, [x3, #0x10]
    3f9c: f9001464     	str	x4, [x3, #0x28]
    3fa0: 34000c82     	cbz	w2, 0x4130 <___pl_fn_8+0x22c>
    3fa4: 2a0503e0     	mov	w0, w5
    3fa8: f9001860     	str	x0, [x3, #0x30]
    3fac: 34000dc2     	cbz	w2, 0x4164 <___pl_fn_8+0x260>
    3fb0: 53001cc0     	uxtb	w0, w6
    3fb4: f9001c60     	str	x0, [x3, #0x38]
    3fb8: 34000f02     	cbz	w2, 0x4198 <___pl_fn_8+0x294>
    3fbc: 53001ce0     	uxtb	w0, w7
    3fc0: f9002060     	str	x0, [x3, #0x40]
    3fc4: 34001042     	cbz	w2, 0x41cc <___pl_fn_8+0x2c8>
    3fc8: aa0203e5     	mov	x5, x2
    3fcc: d2800002     	mov	x2, #0x0                ; =0
    3fd0: f9002462     	str	x2, [x3, #0x48]
    3fd4: aa0c03e0     	mov	x0, x12
    3fd8: 34001140     	cbz	w0, 0x4200 <___pl_fn_8+0x2fc>
    3fdc: f9000d01     	str	x1, [x8, #0x18]
    3fe0: aa1303e0     	mov	x0, x19
    3fe4: b9401407     	ldr	w7, [x0, #0x14]
    3fe8: 11000548     	add	w8, w10, #0x1
    3fec: 6b07011f     	cmp	w8, w7
    3ff0: 54001202     	b.hs	0x4230 <___pl_fn_8+0x32c>
    3ff4: aa0c03e1     	mov	x1, x12
    3ff8: aa0b03e2     	mov	x2, x11
    3ffc: aa0503e3     	mov	x3, x5
    4000: aa1303e0     	mov	x0, x19
    4004: 94000000     	bl	0x4004 <___pl_fn_8+0x100>
    4008: aa1303e0     	mov	x0, x19
    400c: b9402c0a     	ldr	w10, [x0, #0x2c]
    4010: 350011aa     	cbnz	w10, 0x4244 <___pl_fn_8+0x340>
    4014: aa1303e0     	mov	x0, x19
    4018: b940100c     	ldr	w12, [x0, #0x10]
    401c: 5100058c     	sub	w12, w12, #0x1
    4020: b900100c     	str	w12, [x0, #0x10]
    4024: 910243ff     	add	sp, sp, #0x90
    4028: f84107f3     	ldr	x19, [sp], #0x10
    402c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4030: d65f03c0     	ret
    4034: aa0103e5     	mov	x5, x1
    4038: d28000e0     	mov	x0, #0x7                ; =7
    403c: 910003e3     	mov	x3, sp
    4040: f80003e0     	stur	x0, [sp]
    4044: 2a0203e0     	mov	w0, w2
    4048: f80083e0     	stur	x0, [sp, #0x8]
    404c: 528018c1     	mov	w1, #0xc6               ; =198
    4050: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4054: f9400084     	ldr	x4, [x4]
    4058: aa0503e2     	mov	x2, x5
    405c: aa1303e0     	mov	x0, x19
    4060: d63f0080     	blr	x4
    4064: 35000f00     	cbnz	w0, 0x4244 <___pl_fn_8+0x340>
    4068: 528018e1     	mov	w1, #0xc7               ; =199
    406c: 14000072     	b	0x4234 <___pl_fn_8+0x330>
    4070: 52801901     	mov	w1, #0xc8               ; =200
    4074: 52800003     	mov	w3, #0x0                ; =0
    4078: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    407c: f9400084     	ldr	x4, [x4]
    4080: aa0c03e2     	mov	x2, x12
    4084: aa1303e0     	mov	x0, x19
    4088: d63f0080     	blr	x4
    408c: 35000dc0     	cbnz	w0, 0x4244 <___pl_fn_8+0x340>
    4090: 52801921     	mov	w1, #0xc9               ; =201
    4094: 14000068     	b	0x4234 <___pl_fn_8+0x330>
    4098: d2800000     	mov	x0, #0x0                ; =0
    409c: 910043e3     	add	x3, sp, #0x10
    40a0: f80103e0     	stur	x0, [sp, #0x10]
    40a4: 2a0903e0     	mov	w0, w9
    40a8: f80183e0     	stur	x0, [sp, #0x18]
    40ac: 52801941     	mov	w1, #0xca               ; =202
    40b0: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    40b4: f9400084     	ldr	x4, [x4]
    40b8: aa1303e0     	mov	x0, x19
    40bc: d63f0080     	blr	x4
    40c0: 35000c20     	cbnz	w0, 0x4244 <___pl_fn_8+0x340>
    40c4: 52801961     	mov	w1, #0xcb               ; =203
    40c8: 1400005b     	b	0x4234 <___pl_fn_8+0x330>
    40cc: d2800024     	mov	x4, #0x1                ; =1
    40d0: 910083e3     	add	x3, sp, #0x20
    40d4: f80203e4     	stur	x4, [sp, #0x20]
    40d8: aa0b03e9     	mov	x9, x11
    40dc: f80283e9     	stur	x9, [sp, #0x28]
    40e0: 52801981     	mov	w1, #0xcc               ; =204
    40e4: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    40e8: f9400084     	ldr	x4, [x4]
    40ec: aa1303e0     	mov	x0, x19
    40f0: d63f0080     	blr	x4
    40f4: 35000a80     	cbnz	w0, 0x4244 <___pl_fn_8+0x340>
    40f8: 528019a1     	mov	w1, #0xcd               ; =205
    40fc: 1400004e     	b	0x4234 <___pl_fn_8+0x330>
    4100: d280004e     	mov	x14, #0x2               ; =2
    4104: 9100c3e3     	add	x3, sp, #0x30
    4108: f80303ee     	stur	x14, [sp, #0x30]
    410c: f80383e4     	stur	x4, [sp, #0x38]
    4110: 528019c1     	mov	w1, #0xce               ; =206
    4114: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4118: f9400084     	ldr	x4, [x4]
    411c: aa1303e0     	mov	x0, x19
    4120: d63f0080     	blr	x4
    4124: 35000900     	cbnz	w0, 0x4244 <___pl_fn_8+0x340>
    4128: 528019e1     	mov	w1, #0xcf               ; =207
    412c: 14000042     	b	0x4234 <___pl_fn_8+0x330>
    4130: d2800060     	mov	x0, #0x3                ; =3
    4134: 910103e3     	add	x3, sp, #0x40
    4138: f80403e0     	stur	x0, [sp, #0x40]
    413c: 2a0503e0     	mov	w0, w5
    4140: f80483e0     	stur	x0, [sp, #0x48]
    4144: 52801a01     	mov	w1, #0xd0               ; =208
    4148: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    414c: f9400084     	ldr	x4, [x4]
    4150: aa1303e0     	mov	x0, x19
    4154: d63f0080     	blr	x4
    4158: 35000760     	cbnz	w0, 0x4244 <___pl_fn_8+0x340>
    415c: 52801a21     	mov	w1, #0xd1               ; =209
    4160: 14000035     	b	0x4234 <___pl_fn_8+0x330>
    4164: d2800080     	mov	x0, #0x4                ; =4
    4168: 910143e3     	add	x3, sp, #0x50
    416c: f80503e0     	stur	x0, [sp, #0x50]
    4170: 53001cc0     	uxtb	w0, w6
    4174: f80583e0     	stur	x0, [sp, #0x58]
    4178: 52801a41     	mov	w1, #0xd2               ; =210
    417c: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4180: f9400084     	ldr	x4, [x4]
    4184: aa1303e0     	mov	x0, x19
    4188: d63f0080     	blr	x4
    418c: 350005c0     	cbnz	w0, 0x4244 <___pl_fn_8+0x340>
    4190: 52801a61     	mov	w1, #0xd3               ; =211
    4194: 14000028     	b	0x4234 <___pl_fn_8+0x330>
    4198: d28000a0     	mov	x0, #0x5                ; =5
    419c: 910183e3     	add	x3, sp, #0x60
    41a0: f80603e0     	stur	x0, [sp, #0x60]
    41a4: 53001ce0     	uxtb	w0, w7
    41a8: f80683e0     	stur	x0, [sp, #0x68]
    41ac: 52801a81     	mov	w1, #0xd4               ; =212
    41b0: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    41b4: f9400084     	ldr	x4, [x4]
    41b8: aa1303e0     	mov	x0, x19
    41bc: d63f0080     	blr	x4
    41c0: 35000420     	cbnz	w0, 0x4244 <___pl_fn_8+0x340>
    41c4: 52801aa1     	mov	w1, #0xd5               ; =213
    41c8: 1400001b     	b	0x4234 <___pl_fn_8+0x330>
    41cc: d28000c0     	mov	x0, #0x6                ; =6
    41d0: 9101c3e3     	add	x3, sp, #0x70
    41d4: f80703e0     	stur	x0, [sp, #0x70]
    41d8: d2800000     	mov	x0, #0x0                ; =0
    41dc: f80783e0     	stur	x0, [sp, #0x78]
    41e0: 52801ac1     	mov	w1, #0xd6               ; =214
    41e4: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    41e8: f9400084     	ldr	x4, [x4]
    41ec: aa1303e0     	mov	x0, x19
    41f0: d63f0080     	blr	x4
    41f4: 35000280     	cbnz	w0, 0x4244 <___pl_fn_8+0x340>
    41f8: 52801ae1     	mov	w1, #0xd7               ; =215
    41fc: 1400000e     	b	0x4234 <___pl_fn_8+0x330>
    4200: 910203e3     	add	x3, sp, #0x80
    4204: f80803e2     	stur	x2, [sp, #0x80]
    4208: f80883e1     	stur	x1, [sp, #0x88]
    420c: 52801b01     	mov	w1, #0xd8               ; =216
    4210: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4214: f9400084     	ldr	x4, [x4]
    4218: aa0c03e2     	mov	x2, x12
    421c: aa1303e0     	mov	x0, x19
    4220: d63f0080     	blr	x4
    4224: 35000100     	cbnz	w0, 0x4244 <___pl_fn_8+0x340>
    4228: 52801b21     	mov	w1, #0xd9               ; =217
    422c: 14000002     	b	0x4234 <___pl_fn_8+0x330>
    4230: 52801b41     	mov	w1, #0xda               ; =218
    4234: 9000000f     	adrp	x15, 0x4000 <___pl_fn_8+0xfc>
    4238: f94001ef     	ldr	x15, [x15]
    423c: aa1303e0     	mov	x0, x19
    4240: d63f01e0     	blr	x15
    4244: 910243ff     	add	sp, sp, #0x90
    4248: f84107f3     	ldr	x19, [sp], #0x10
    424c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4250: d65f03c0     	ret

0000000000004254 <___pl_fn_9>:
    4254: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    4258: 910003fd     	mov	x29, sp
    425c: b9401004     	ldr	w4, [x0, #0x10]
    4260: 11000485     	add	w5, w4, #0x1
    4264: b9001005     	str	w5, [x0, #0x10]
    4268: b9001004     	str	w4, [x0, #0x10]
    426c: aa0103e0     	mov	x0, x1
    4270: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4274: d65f03c0     	ret

0000000000004278 <___pl_fn_10>:
    4278: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    427c: 910003fd     	mov	x29, sp
    4280: f81f0ff7     	str	x23, [sp, #-0x10]!
    4284: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    4288: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    428c: d100c3ff     	sub	sp, sp, #0x30
    4290: aa0203e7     	mov	x7, x2
    4294: aa0303f7     	mov	x23, x3
    4298: b9401006     	ldr	w6, [x0, #0x10]
    429c: 110004c2     	add	w2, w6, #0x1
    42a0: b9001002     	str	w2, [x0, #0x10]
    42a4: 34000e61     	cbz	w1, 0x4470 <___pl_fn_10+0x1f8>
    42a8: f9400005     	ldr	x5, [x0]
    42ac: aa0003f5     	mov	x21, x0
    42b0: 2a0103f3     	mov	w19, w1
    42b4: aa0103f6     	mov	x22, x1
    42b8: 8b130ca4     	add	x4, x5, x19, lsl #3
    42bc: b9403082     	ldr	w2, [x4, #0x30]
    42c0: 34000dc2     	cbz	w2, 0x4478 <___pl_fn_10+0x200>
    42c4: aa0203e8     	mov	x8, x2
    42c8: aa1603e2     	mov	x2, x22
    42cc: 34000ea2     	cbz	w2, 0x44a0 <___pl_fn_10+0x228>
    42d0: b9405082     	ldr	w2, [x4, #0x50]
    42d4: 34000e62     	cbz	w2, 0x44a0 <___pl_fn_10+0x228>
    42d8: 34000f82     	cbz	w2, 0x44c8 <___pl_fn_10+0x250>
    42dc: 2a0203e1     	mov	w1, w2
    42e0: 8b010ca1     	add	x1, x5, x1, lsl #3
    42e4: b9402823     	ldr	w3, [x1, #0x28]
    42e8: 34000f03     	cbz	w3, 0x44c8 <___pl_fn_10+0x250>
    42ec: aa0803ea     	mov	x10, x8
    42f0: 6b03015f     	cmp	w10, w3
    42f4: 54000620     	b.eq	0x43b8 <___pl_fn_10+0x140>
    42f8: aa1603e0     	mov	x0, x22
    42fc: 34000f80     	cbz	w0, 0x44ec <___pl_fn_10+0x274>
    4300: aa0803e0     	mov	x0, x8
    4304: 34000f40     	cbz	w0, 0x44ec <___pl_fn_10+0x274>
    4308: aa1603eb     	mov	x11, x22
    430c: 3400104b     	cbz	w11, 0x4514 <___pl_fn_10+0x29c>
    4310: 34001022     	cbz	w2, 0x4514 <___pl_fn_10+0x29c>
    4314: 34001142     	cbz	w2, 0x453c <___pl_fn_10+0x2c4>
    4318: 34001123     	cbz	w3, 0x453c <___pl_fn_10+0x2c4>
    431c: aa1503e0     	mov	x0, x21
    4320: b9401814     	ldr	w20, [x0, #0x18]
    4324: b9401c00     	ldr	w0, [x0, #0x1c]
    4328: 11000a81     	add	w1, w20, #0x2
    432c: 6b00003f     	cmp	w1, w0
    4330: 54001388     	b.hi	0x45a0 <___pl_fn_10+0x328>
    4334: aa1503e0     	mov	x0, x21
    4338: f9401000     	ldr	x0, [x0, #0x20]
    433c: 2a1403e1     	mov	w1, w20
    4340: 8b010801     	add	x1, x0, x1, lsl #2
    4344: aa0803e2     	mov	x2, x8
    4348: b8345802     	str	w2, [x0, w20, uxtw #2]
    434c: b9000423     	str	w3, [x1, #0x4]
    4350: 11000a80     	add	w0, w20, #0x2
    4354: aa1503e1     	mov	x1, x21
    4358: b9001820     	str	w0, [x1, #0x18]
    435c: aa1503e0     	mov	x0, x21
    4360: b9401000     	ldr	w0, [x0, #0x10]
    4364: b9401421     	ldr	w1, [x1, #0x14]
    4368: 6b01001f     	cmp	w0, w1
    436c: 54001162     	b.hs	0x4598 <___pl_fn_10+0x320>
    4370: aa0703e1     	mov	x1, x7
    4374: aa0803e2     	mov	x2, x8
    4378: aa1503e0     	mov	x0, x21
    437c: 94000000     	bl	0x437c <___pl_fn_10+0x104>
    4380: aa1503e1     	mov	x1, x21
    4384: b9402c21     	ldr	w1, [x1, #0x2c]
    4388: 35001781     	cbnz	w1, 0x4678 <___pl_fn_10+0x400>
    438c: aa1503e1     	mov	x1, x21
    4390: b9001834     	str	w20, [x1, #0x18]
    4394: aa1603e2     	mov	x2, x22
    4398: 34000e42     	cbz	w2, 0x4560 <___pl_fn_10+0x2e8>
    439c: aa1503e1     	mov	x1, x21
    43a0: f9400021     	ldr	x1, [x1]
    43a4: 2a0003e0     	mov	w0, w0
    43a8: 8b130c21     	add	x1, x1, x19, lsl #3
    43ac: f9001820     	str	x0, [x1, #0x30]
    43b0: aa1503e0     	mov	x0, x21
    43b4: 1400001a     	b	0x441c <___pl_fn_10+0x1a4>
    43b8: aa0703e1     	mov	x1, x7
    43bc: aa1603e2     	mov	x2, x22
    43c0: 34000f42     	cbz	w2, 0x45a8 <___pl_fn_10+0x330>
    43c4: 2a0103e3     	mov	w3, w1
    43c8: f9001883     	str	x3, [x4, #0x30]
    43cc: aa1603e2     	mov	x2, x22
    43d0: 34001082     	cbz	w2, 0x45e0 <___pl_fn_10+0x368>
    43d4: d280002c     	mov	x12, #0x1               ; =1
    43d8: f9001c8c     	str	x12, [x4, #0x38]
    43dc: aa1603e2     	mov	x2, x22
    43e0: 340011c2     	cbz	w2, 0x4618 <___pl_fn_10+0x3a0>
    43e4: f9401482     	ldr	x2, [x4, #0x28]
    43e8: f9400880     	ldr	x0, [x4, #0x10]
    43ec: 37101160     	tbnz	w0, #0x2, 0x4618 <___pl_fn_10+0x3a0>
    43f0: aa1703e3     	mov	x3, x23
    43f4: 34001263     	cbz	w3, 0x4640 <___pl_fn_10+0x3c8>
    43f8: 2a0303e0     	mov	w0, w3
    43fc: aa0303f7     	mov	x23, x3
    4400: 8b000ca1     	add	x1, x5, x0, lsl #3
    4404: f9401420     	ldr	x0, [x1, #0x28]
    4408: f9400821     	ldr	x1, [x1, #0x10]
    440c: 371011c1     	tbnz	w1, #0x2, 0x4644 <___pl_fn_10+0x3cc>
    4410: eb00005f     	cmp	x2, x0
    4414: 540001cc     	b.gt	0x444c <___pl_fn_10+0x1d4>
    4418: aa1503e0     	mov	x0, x21
    441c: aa1503e0     	mov	x0, x21
    4420: b9401000     	ldr	w0, [x0, #0x10]
    4424: 51000400     	sub	w0, w0, #0x1
    4428: aa1503e1     	mov	x1, x21
    442c: b9001020     	str	w0, [x1, #0x10]
    4430: aa1703e0     	mov	x0, x23
    4434: 9100c3ff     	add	sp, sp, #0x30
    4438: a8c153f3     	ldp	x19, x20, [sp], #0x10
    443c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4440: f84107f7     	ldr	x23, [sp], #0x10
    4444: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4448: d65f03c0     	ret
    444c: aa1503e0     	mov	x0, x21
    4450: b9001006     	str	w6, [x0, #0x10]
    4454: aa1603e0     	mov	x0, x22
    4458: 9100c3ff     	add	sp, sp, #0x30
    445c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4460: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4464: f84107f7     	ldr	x23, [sp], #0x10
    4468: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    446c: d65f03c0     	ret
    4470: aa0003f5     	mov	x21, x0
    4474: aa0103f6     	mov	x22, x1
    4478: 52801b61     	mov	w1, #0xdb               ; =219
    447c: 52800063     	mov	w3, #0x3                ; =3
    4480: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4484: f9400084     	ldr	x4, [x4]
    4488: aa1603e2     	mov	x2, x22
    448c: aa1503e0     	mov	x0, x21
    4490: d63f0080     	blr	x4
    4494: 35000f20     	cbnz	w0, 0x4678 <___pl_fn_10+0x400>
    4498: 52801b81     	mov	w1, #0xdc               ; =220
    449c: 14000073     	b	0x4668 <___pl_fn_10+0x3f0>
    44a0: 52801ba1     	mov	w1, #0xdd               ; =221
    44a4: 528000e3     	mov	w3, #0x7                ; =7
    44a8: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    44ac: f9400084     	ldr	x4, [x4]
    44b0: aa1603e2     	mov	x2, x22
    44b4: aa1503e0     	mov	x0, x21
    44b8: d63f0080     	blr	x4
    44bc: 35000de0     	cbnz	w0, 0x4678 <___pl_fn_10+0x400>
    44c0: 52801bc1     	mov	w1, #0xde               ; =222
    44c4: 14000069     	b	0x4668 <___pl_fn_10+0x3f0>
    44c8: 52801be1     	mov	w1, #0xdf               ; =223
    44cc: 52800043     	mov	w3, #0x2                ; =2
    44d0: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    44d4: f9400084     	ldr	x4, [x4]
    44d8: aa1503e0     	mov	x0, x21
    44dc: d63f0080     	blr	x4
    44e0: 35000cc0     	cbnz	w0, 0x4678 <___pl_fn_10+0x400>
    44e4: 52801c01     	mov	w1, #0xe0               ; =224
    44e8: 14000060     	b	0x4668 <___pl_fn_10+0x3f0>
    44ec: 52801c21     	mov	w1, #0xe1               ; =225
    44f0: 52800063     	mov	w3, #0x3                ; =3
    44f4: 9000000e     	adrp	x14, 0x4000 <___pl_fn_8+0xfc>
    44f8: f94001ce     	ldr	x14, [x14]
    44fc: aa1603e2     	mov	x2, x22
    4500: aa1503e0     	mov	x0, x21
    4504: d63f01c0     	blr	x14
    4508: 35000b80     	cbnz	w0, 0x4678 <___pl_fn_10+0x400>
    450c: 52801c41     	mov	w1, #0xe2               ; =226
    4510: 14000056     	b	0x4668 <___pl_fn_10+0x3f0>
    4514: 52801c61     	mov	w1, #0xe3               ; =227
    4518: 528000e3     	mov	w3, #0x7                ; =7
    451c: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4520: f9400084     	ldr	x4, [x4]
    4524: aa1603e2     	mov	x2, x22
    4528: aa1503e0     	mov	x0, x21
    452c: d63f0080     	blr	x4
    4530: 35000a40     	cbnz	w0, 0x4678 <___pl_fn_10+0x400>
    4534: 52801c81     	mov	w1, #0xe4               ; =228
    4538: 1400004c     	b	0x4668 <___pl_fn_10+0x3f0>
    453c: 52801ca1     	mov	w1, #0xe5               ; =229
    4540: 52800043     	mov	w3, #0x2                ; =2
    4544: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4548: f9400084     	ldr	x4, [x4]
    454c: aa1503e0     	mov	x0, x21
    4550: d63f0080     	blr	x4
    4554: 35000920     	cbnz	w0, 0x4678 <___pl_fn_10+0x400>
    4558: 52801cc1     	mov	w1, #0xe6               ; =230
    455c: 14000043     	b	0x4668 <___pl_fn_10+0x3f0>
    4560: d2800061     	mov	x1, #0x3                ; =3
    4564: 910003e3     	mov	x3, sp
    4568: f80003e1     	stur	x1, [sp]
    456c: 2a0003e0     	mov	w0, w0
    4570: f80083e0     	stur	x0, [sp, #0x8]
    4574: 52801d21     	mov	w1, #0xe9               ; =233
    4578: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    457c: f9400084     	ldr	x4, [x4]
    4580: aa1603e2     	mov	x2, x22
    4584: aa1503e0     	mov	x0, x21
    4588: d63f0080     	blr	x4
    458c: 35000760     	cbnz	w0, 0x4678 <___pl_fn_10+0x400>
    4590: 52801d41     	mov	w1, #0xea               ; =234
    4594: 14000035     	b	0x4668 <___pl_fn_10+0x3f0>
    4598: 52801d01     	mov	w1, #0xe8               ; =232
    459c: 14000033     	b	0x4668 <___pl_fn_10+0x3f0>
    45a0: 52801ce1     	mov	w1, #0xe7               ; =231
    45a4: 14000031     	b	0x4668 <___pl_fn_10+0x3f0>
    45a8: d2800060     	mov	x0, #0x3                ; =3
    45ac: 910043e3     	add	x3, sp, #0x10
    45b0: f80103e0     	stur	x0, [sp, #0x10]
    45b4: 2a0103e0     	mov	w0, w1
    45b8: f80183e0     	stur	x0, [sp, #0x18]
    45bc: 52801d61     	mov	w1, #0xeb               ; =235
    45c0: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    45c4: f9400084     	ldr	x4, [x4]
    45c8: aa1603e2     	mov	x2, x22
    45cc: aa1503e0     	mov	x0, x21
    45d0: d63f0080     	blr	x4
    45d4: 35000520     	cbnz	w0, 0x4678 <___pl_fn_10+0x400>
    45d8: 52801d81     	mov	w1, #0xec               ; =236
    45dc: 14000023     	b	0x4668 <___pl_fn_10+0x3f0>
    45e0: d2800086     	mov	x6, #0x4                ; =4
    45e4: 910083e3     	add	x3, sp, #0x20
    45e8: f80203e6     	stur	x6, [sp, #0x20]
    45ec: d2800027     	mov	x7, #0x1                ; =1
    45f0: f80283e7     	stur	x7, [sp, #0x28]
    45f4: 52801da1     	mov	w1, #0xed               ; =237
    45f8: 90000008     	adrp	x8, 0x4000 <___pl_fn_8+0xfc>
    45fc: f9400108     	ldr	x8, [x8]
    4600: aa1603e2     	mov	x2, x22
    4604: aa1503e0     	mov	x0, x21
    4608: d63f0100     	blr	x8
    460c: 35000360     	cbnz	w0, 0x4678 <___pl_fn_10+0x400>
    4610: 52801dc1     	mov	w1, #0xee               ; =238
    4614: 14000015     	b	0x4668 <___pl_fn_10+0x3f0>
    4618: 52801de1     	mov	w1, #0xef               ; =239
    461c: 52800043     	mov	w3, #0x2                ; =2
    4620: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4624: f9400084     	ldr	x4, [x4]
    4628: aa1603e2     	mov	x2, x22
    462c: aa1503e0     	mov	x0, x21
    4630: d63f0080     	blr	x4
    4634: 35000220     	cbnz	w0, 0x4678 <___pl_fn_10+0x400>
    4638: 52801e01     	mov	w1, #0xf0               ; =240
    463c: 1400000b     	b	0x4668 <___pl_fn_10+0x3f0>
    4640: aa0303f7     	mov	x23, x3
    4644: 52801e21     	mov	w1, #0xf1               ; =241
    4648: 52800043     	mov	w3, #0x2                ; =2
    464c: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4650: f9400084     	ldr	x4, [x4]
    4654: aa1703e2     	mov	x2, x23
    4658: aa1503e0     	mov	x0, x21
    465c: d63f0080     	blr	x4
    4660: 350000c0     	cbnz	w0, 0x4678 <___pl_fn_10+0x400>
    4664: 52801e41     	mov	w1, #0xf2               ; =242
    4668: 90000002     	adrp	x2, 0x4000 <___pl_fn_8+0xfc>
    466c: f9400042     	ldr	x2, [x2]
    4670: aa1503e0     	mov	x0, x21
    4674: d63f0040     	blr	x2
    4678: 52800000     	mov	w0, #0x0                ; =0
    467c: 9100c3ff     	add	sp, sp, #0x30
    4680: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4684: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4688: f84107f7     	ldr	x23, [sp], #0x10
    468c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4690: d65f03c0     	ret

0000000000004694 <___pl_fn_11>:
    4694: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    4698: 910003fd     	mov	x29, sp
    469c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    46a0: d10143ff     	sub	sp, sp, #0x50
    46a4: b9401002     	ldr	w2, [x0, #0x10]
    46a8: 11000442     	add	w2, w2, #0x1
    46ac: b9001002     	str	w2, [x0, #0x10]
    46b0: 34001b61     	cbz	w1, 0x4a1c <___pl_fn_11+0x388>
    46b4: f9400004     	ldr	x4, [x0]
    46b8: aa0003f4     	mov	x20, x0
    46bc: 2a0103e0     	mov	w0, w1
    46c0: aa0103e6     	mov	x6, x1
    46c4: 8b000c80     	add	x0, x4, x0, lsl #3
    46c8: 3940e001     	ldrb	w1, [x0, #0x38]
    46cc: 53001c22     	uxtb	w2, w1
    46d0: 7100085f     	cmp	w2, #0x2
    46d4: 54001a80     	b.eq	0x4a24 <___pl_fn_11+0x390>
    46d8: 72001c3f     	tst	w1, #0xff
    46dc: 54000061     	b.ne	0x46e8 <___pl_fn_11+0x54>
    46e0: 52800001     	mov	w1, #0x0                ; =0
    46e4: 14000007     	b	0x4700 <___pl_fn_11+0x6c>
    46e8: aa0603e2     	mov	x2, x6
    46ec: 34001b02     	cbz	w2, 0x4a4c <___pl_fn_11+0x3b8>
    46f0: 39410001     	ldrb	w1, [x0, #0x40]
    46f4: 53001c22     	uxtb	w2, w1
    46f8: 7100085f     	cmp	w2, #0x2
    46fc: 54001a80     	b.eq	0x4a4c <___pl_fn_11+0x3b8>
    4700: 72001c3f     	tst	w1, #0xff
    4704: 54000061     	b.ne	0x4710 <___pl_fn_11+0x7c>
    4708: 52800001     	mov	w1, #0x0                ; =0
    470c: 14000008     	b	0x472c <___pl_fn_11+0x98>
    4710: aa0603e2     	mov	x2, x6
    4714: 34001b02     	cbz	w2, 0x4a74 <___pl_fn_11+0x3e0>
    4718: 39412009     	ldrb	w9, [x0, #0x48]
    471c: 53001d2a     	uxtb	w10, w9
    4720: 7100095f     	cmp	w10, #0x2
    4724: 54001a80     	b.eq	0x4a74 <___pl_fn_11+0x3e0>
    4728: 52000121     	eor	w1, w9, #0x1
    472c: 72001c3f     	tst	w1, #0xff
    4730: 540001e1     	b.ne	0x476c <___pl_fn_11+0xd8>
    4734: aa0603e2     	mov	x2, x6
    4738: 34001b22     	cbz	w2, 0x4a9c <___pl_fn_11+0x408>
    473c: b9405002     	ldr	w2, [x0, #0x50]
    4740: 34001ae2     	cbz	w2, 0x4a9c <___pl_fn_11+0x408>
    4744: 34001c02     	cbz	w2, 0x4ac4 <___pl_fn_11+0x430>
    4748: 2a0203e0     	mov	w0, w2
    474c: 8b000c80     	add	x0, x4, x0, lsl #3
    4750: b9402800     	ldr	w0, [x0, #0x28]
    4754: 34001b80     	cbz	w0, 0x4ac4 <___pl_fn_11+0x430>
    4758: aa0003e7     	mov	x7, x0
    475c: aa0703e2     	mov	x2, x7
    4760: 34001c42     	cbz	w2, 0x4ae8 <___pl_fn_11+0x454>
    4764: aa1403e0     	mov	x0, x20
    4768: 14000036     	b	0x4840 <___pl_fn_11+0x1ac>
    476c: aa0603e2     	mov	x2, x6
    4770: 34001c02     	cbz	w2, 0x4af0 <___pl_fn_11+0x45c>
    4774: b9403002     	ldr	w2, [x0, #0x30]
    4778: aa0203e7     	mov	x7, x2
    477c: 34001ba2     	cbz	w2, 0x4af0 <___pl_fn_11+0x45c>
    4780: 52800003     	mov	w3, #0x0                ; =0
    4784: aa0703e2     	mov	x2, x7
    4788: 34002be2     	cbz	w2, 0x4d04 <___pl_fn_11+0x670>
    478c: aa0703e2     	mov	x2, x7
    4790: 34001c42     	cbz	w2, 0x4b18 <___pl_fn_11+0x484>
    4794: aa0703e2     	mov	x2, x7
    4798: 2a0203e1     	mov	w1, w2
    479c: 8b010c81     	add	x1, x4, x1, lsl #3
    47a0: b9401821     	ldr	w1, [x1, #0x18]
    47a4: 34001ba1     	cbz	w1, 0x4b18 <___pl_fn_11+0x484>
    47a8: aa0603e2     	mov	x2, x6
    47ac: 34001c82     	cbz	w2, 0x4b3c <___pl_fn_11+0x4a8>
    47b0: 2a0103e5     	mov	w5, w1
    47b4: f9001805     	str	x5, [x0, #0x30]
    47b8: aa0603e2     	mov	x2, x6
    47bc: 34001dc2     	cbz	w2, 0x4b74 <___pl_fn_11+0x4e0>
    47c0: b9403008     	ldr	w8, [x0, #0x30]
    47c4: 34001d88     	cbz	w8, 0x4b74 <___pl_fn_11+0x4e0>
    47c8: aa0603e2     	mov	x2, x6
    47cc: 34001e82     	cbz	w2, 0x4b9c <___pl_fn_11+0x508>
    47d0: b9405002     	ldr	w2, [x0, #0x50]
    47d4: 34001e42     	cbz	w2, 0x4b9c <___pl_fn_11+0x508>
    47d8: 34001f62     	cbz	w2, 0x4bc4 <___pl_fn_11+0x530>
    47dc: 2a0203e1     	mov	w1, w2
    47e0: 8b010c81     	add	x1, x4, x1, lsl #3
    47e4: b9402821     	ldr	w1, [x1, #0x28]
    47e8: 34001ee1     	cbz	w1, 0x4bc4 <___pl_fn_11+0x530>
    47ec: 6b01011f     	cmp	w8, w1
    47f0: 540000e0     	b.eq	0x480c <___pl_fn_11+0x178>
    47f4: aa0603e2     	mov	x2, x6
    47f8: 34001f82     	cbz	w2, 0x4be8 <___pl_fn_11+0x554>
    47fc: d2800021     	mov	x1, #0x1                ; =1
    4800: f9001c01     	str	x1, [x0, #0x38]
    4804: aa0603e2     	mov	x2, x6
    4808: 14000006     	b	0x4820 <___pl_fn_11+0x18c>
    480c: aa0603e2     	mov	x2, x6
    4810: 34002082     	cbz	w2, 0x4c20 <___pl_fn_11+0x58c>
    4814: d2800001     	mov	x1, #0x0                ; =0
    4818: f9001c01     	str	x1, [x0, #0x38]
    481c: aa0603e2     	mov	x2, x6
    4820: aa0603e2     	mov	x2, x6
    4824: 340021a2     	cbz	w2, 0x4c58 <___pl_fn_11+0x5c4>
    4828: d2800001     	mov	x1, #0x0                ; =0
    482c: f9002001     	str	x1, [x0, #0x40]
    4830: aa0603e2     	mov	x2, x6
    4834: 340022e2     	cbz	w2, 0x4c90 <___pl_fn_11+0x5fc>
    4838: f9002401     	str	x1, [x0, #0x48]
    483c: aa1403e0     	mov	x0, x20
    4840: aa1403e0     	mov	x0, x20
    4844: b9401813     	ldr	w19, [x0, #0x18]
    4848: b9401c0c     	ldr	w12, [x0, #0x1c]
    484c: 1100066b     	add	w11, w19, #0x1
    4850: 6b0c017f     	cmp	w11, w12
    4854: 54002548     	b.hi	0x4cfc <___pl_fn_11+0x668>
    4858: aa1403e0     	mov	x0, x20
    485c: f940100d     	ldr	x13, [x0, #0x20]
    4860: aa0703e2     	mov	x2, x7
    4864: b83359a2     	str	w2, [x13, w19, uxtw #2]
    4868: b900180b     	str	w11, [x0, #0x18]
    486c: aa0603e2     	mov	x2, x6
    4870: 34002422     	cbz	w2, 0x4cf4 <___pl_fn_11+0x660>
    4874: aa1403e0     	mov	x0, x20
    4878: f9400000     	ldr	x0, [x0]
    487c: aa0603e2     	mov	x2, x6
    4880: f8625800     	ldr	x0, [x0, w2, uxtw #3]
    4884: 51000c01     	sub	w1, w0, #0x3
    4888: 7100083f     	cmp	w1, #0x2
    488c: 54002303     	b.lo	0x4cec <___pl_fn_11+0x658>
    4890: 51001400     	sub	w0, w0, #0x5
    4894: 7100141f     	cmp	w0, #0x5
    4898: 540022a2     	b.hs	0x4cec <___pl_fn_11+0x658>
    489c: 9a8023e1     	csel	x1, xzr, x0, hs
    48a0: 10000082     	adr	x2, 0x48b0 <___pl_fn_11+0x21c>
    48a4: b8a15841     	ldrsw	x1, [x2, w1, uxtw #2]
    48a8: 8b010042     	add	x2, x2, x1
    48ac: d61f0040     	br	x2
    48b0: 00000108     	udf	#0x108
    48b4: 000000cc     	udf	#0xcc
    48b8: 00000090     	udf	#0x90
    48bc: 00000054     	udf	#0x54
    48c0: 00000018     	udf	#0x18
    48c4: 1400010a     	b	0x4cec <___pl_fn_11+0x658>
    48c8: aa1403e0     	mov	x0, x20
    48cc: b9401000     	ldr	w0, [x0, #0x10]
    48d0: aa1403e1     	mov	x1, x20
    48d4: b9401421     	ldr	w1, [x1, #0x14]
    48d8: 6b01001f     	cmp	w0, w1
    48dc: 54001f42     	b.hs	0x4cc4 <___pl_fn_11+0x630>
    48e0: aa0603e1     	mov	x1, x6
    48e4: aa0703e2     	mov	x2, x7
    48e8: aa1403e0     	mov	x0, x20
    48ec: 94000000     	bl	0x48ec <___pl_fn_11+0x258>
    48f0: aa1403e1     	mov	x1, x20
    48f4: b9402c21     	ldr	w1, [x1, #0x2c]
    48f8: 35002101     	cbnz	w1, 0x4d18 <___pl_fn_11+0x684>
    48fc: aa1403e1     	mov	x1, x20
    4900: 1400003c     	b	0x49f0 <___pl_fn_11+0x35c>
    4904: aa1403e0     	mov	x0, x20
    4908: aa0603e1     	mov	x1, x6
    490c: b9401000     	ldr	w0, [x0, #0x10]
    4910: aa1403e2     	mov	x2, x20
    4914: b9401442     	ldr	w2, [x2, #0x14]
    4918: 6b02001f     	cmp	w0, w2
    491c: 54001d82     	b.hs	0x4ccc <___pl_fn_11+0x638>
    4920: aa0703e2     	mov	x2, x7
    4924: aa1403e0     	mov	x0, x20
    4928: 94000000     	bl	0x4928 <___pl_fn_11+0x294>
    492c: aa1403e1     	mov	x1, x20
    4930: b9402c21     	ldr	w1, [x1, #0x2c]
    4934: 35001f21     	cbnz	w1, 0x4d18 <___pl_fn_11+0x684>
    4938: aa1403e1     	mov	x1, x20
    493c: 1400002d     	b	0x49f0 <___pl_fn_11+0x35c>
    4940: aa1403e0     	mov	x0, x20
    4944: aa0603e1     	mov	x1, x6
    4948: b9401000     	ldr	w0, [x0, #0x10]
    494c: aa1403e2     	mov	x2, x20
    4950: b9401442     	ldr	w2, [x2, #0x14]
    4954: 6b02001f     	cmp	w0, w2
    4958: 54001be2     	b.hs	0x4cd4 <___pl_fn_11+0x640>
    495c: aa0703e2     	mov	x2, x7
    4960: aa1403e0     	mov	x0, x20
    4964: 94000000     	bl	0x4964 <___pl_fn_11+0x2d0>
    4968: aa1403e2     	mov	x2, x20
    496c: b9402c41     	ldr	w1, [x2, #0x2c]
    4970: 35001d41     	cbnz	w1, 0x4d18 <___pl_fn_11+0x684>
    4974: aa1403e1     	mov	x1, x20
    4978: 1400001e     	b	0x49f0 <___pl_fn_11+0x35c>
    497c: aa1403e0     	mov	x0, x20
    4980: aa0603e1     	mov	x1, x6
    4984: b9401000     	ldr	w0, [x0, #0x10]
    4988: aa1403eb     	mov	x11, x20
    498c: b9401562     	ldr	w2, [x11, #0x14]
    4990: 6b02001f     	cmp	w0, w2
    4994: 54001a42     	b.hs	0x4cdc <___pl_fn_11+0x648>
    4998: aa0703e2     	mov	x2, x7
    499c: aa1403e0     	mov	x0, x20
    49a0: 94000000     	bl	0x49a0 <___pl_fn_11+0x30c>
    49a4: aa1403e1     	mov	x1, x20
    49a8: b9402c21     	ldr	w1, [x1, #0x2c]
    49ac: 35001b61     	cbnz	w1, 0x4d18 <___pl_fn_11+0x684>
    49b0: aa1403e1     	mov	x1, x20
    49b4: 1400000f     	b	0x49f0 <___pl_fn_11+0x35c>
    49b8: aa1403e0     	mov	x0, x20
    49bc: aa0603e1     	mov	x1, x6
    49c0: b9401000     	ldr	w0, [x0, #0x10]
    49c4: aa1403e2     	mov	x2, x20
    49c8: b9401442     	ldr	w2, [x2, #0x14]
    49cc: 6b02001f     	cmp	w0, w2
    49d0: 540018a2     	b.hs	0x4ce4 <___pl_fn_11+0x650>
    49d4: aa0703e2     	mov	x2, x7
    49d8: aa1403e0     	mov	x0, x20
    49dc: 94000000     	bl	0x49dc <___pl_fn_11+0x348>
    49e0: aa1403e1     	mov	x1, x20
    49e4: b9402c21     	ldr	w1, [x1, #0x2c]
    49e8: 35001981     	cbnz	w1, 0x4d18 <___pl_fn_11+0x684>
    49ec: aa1403e1     	mov	x1, x20
    49f0: aa1403e1     	mov	x1, x20
    49f4: b9001833     	str	w19, [x1, #0x18]
    49f8: b9401021     	ldr	w1, [x1, #0x10]
    49fc: 51000421     	sub	w1, w1, #0x1
    4a00: aa1403e2     	mov	x2, x20
    4a04: b9001041     	str	w1, [x2, #0x10]
    4a08: 910143ff     	add	sp, sp, #0x50
    4a0c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4a10: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4a14: d65f03c0     	ret
    4a18: 140000b5     	b	0x4cec <___pl_fn_11+0x658>
    4a1c: aa0103e6     	mov	x6, x1
    4a20: aa0003f4     	mov	x20, x0
    4a24: 52801e61     	mov	w1, #0xf3               ; =243
    4a28: 52800083     	mov	w3, #0x4                ; =4
    4a2c: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4a30: f9400084     	ldr	x4, [x4]
    4a34: aa0603e2     	mov	x2, x6
    4a38: aa1403e0     	mov	x0, x20
    4a3c: d63f0080     	blr	x4
    4a40: 350016c0     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4a44: 52801e81     	mov	w1, #0xf4               ; =244
    4a48: 140000b0     	b	0x4d08 <___pl_fn_11+0x674>
    4a4c: 52801ea1     	mov	w1, #0xf5               ; =245
    4a50: 528000a3     	mov	w3, #0x5                ; =5
    4a54: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4a58: f9400084     	ldr	x4, [x4]
    4a5c: aa0603e2     	mov	x2, x6
    4a60: aa1403e0     	mov	x0, x20
    4a64: d63f0080     	blr	x4
    4a68: 35001580     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4a6c: 52801ec1     	mov	w1, #0xf6               ; =246
    4a70: 140000a6     	b	0x4d08 <___pl_fn_11+0x674>
    4a74: 52801ee1     	mov	w1, #0xf7               ; =247
    4a78: 528000c3     	mov	w3, #0x6                ; =6
    4a7c: 9000000c     	adrp	x12, 0x4000 <___pl_fn_8+0xfc>
    4a80: f940018c     	ldr	x12, [x12]
    4a84: aa0603e2     	mov	x2, x6
    4a88: aa1403e0     	mov	x0, x20
    4a8c: d63f0180     	blr	x12
    4a90: 35001440     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4a94: 52801f01     	mov	w1, #0xf8               ; =248
    4a98: 1400009c     	b	0x4d08 <___pl_fn_11+0x674>
    4a9c: 52801f21     	mov	w1, #0xf9               ; =249
    4aa0: 528000e3     	mov	w3, #0x7                ; =7
    4aa4: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4aa8: f9400084     	ldr	x4, [x4]
    4aac: aa0603e2     	mov	x2, x6
    4ab0: aa1403e0     	mov	x0, x20
    4ab4: d63f0080     	blr	x4
    4ab8: 35001300     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4abc: 52801f41     	mov	w1, #0xfa               ; =250
    4ac0: 14000092     	b	0x4d08 <___pl_fn_11+0x674>
    4ac4: 52801f61     	mov	w1, #0xfb               ; =251
    4ac8: 52800043     	mov	w3, #0x2                ; =2
    4acc: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4ad0: f9400084     	ldr	x4, [x4]
    4ad4: aa1403e0     	mov	x0, x20
    4ad8: d63f0080     	blr	x4
    4adc: 350011e0     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4ae0: 52801f81     	mov	w1, #0xfc               ; =252
    4ae4: 14000089     	b	0x4d08 <___pl_fn_11+0x674>
    4ae8: 52801fa1     	mov	w1, #0xfd               ; =253
    4aec: 14000087     	b	0x4d08 <___pl_fn_11+0x674>
    4af0: 52801fc1     	mov	w1, #0xfe               ; =254
    4af4: 52800063     	mov	w3, #0x3                ; =3
    4af8: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4afc: f9400084     	ldr	x4, [x4]
    4b00: aa0603e2     	mov	x2, x6
    4b04: aa1403e0     	mov	x0, x20
    4b08: d63f0080     	blr	x4
    4b0c: 35001060     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4b10: 52801fe1     	mov	w1, #0xff               ; =255
    4b14: 1400007d     	b	0x4d08 <___pl_fn_11+0x674>
    4b18: 52802021     	mov	w1, #0x101              ; =257
    4b1c: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4b20: f9400084     	ldr	x4, [x4]
    4b24: aa0703e2     	mov	x2, x7
    4b28: aa1403e0     	mov	x0, x20
    4b2c: d63f0080     	blr	x4
    4b30: 35000f40     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4b34: 52802041     	mov	w1, #0x102              ; =258
    4b38: 14000074     	b	0x4d08 <___pl_fn_11+0x674>
    4b3c: d2800060     	mov	x0, #0x3                ; =3
    4b40: 910003e3     	mov	x3, sp
    4b44: f80003e0     	stur	x0, [sp]
    4b48: 2a0103e0     	mov	w0, w1
    4b4c: f80083e0     	stur	x0, [sp, #0x8]
    4b50: 52802061     	mov	w1, #0x103              ; =259
    4b54: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4b58: f9400084     	ldr	x4, [x4]
    4b5c: aa0603e2     	mov	x2, x6
    4b60: aa1403e0     	mov	x0, x20
    4b64: d63f0080     	blr	x4
    4b68: 35000d80     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4b6c: 52802081     	mov	w1, #0x104              ; =260
    4b70: 14000066     	b	0x4d08 <___pl_fn_11+0x674>
    4b74: 528020a1     	mov	w1, #0x105              ; =261
    4b78: 52800063     	mov	w3, #0x3                ; =3
    4b7c: 9000000a     	adrp	x10, 0x4000 <___pl_fn_8+0xfc>
    4b80: f940014a     	ldr	x10, [x10]
    4b84: aa0603e2     	mov	x2, x6
    4b88: aa1403e0     	mov	x0, x20
    4b8c: d63f0140     	blr	x10
    4b90: 35000c40     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4b94: 528020c1     	mov	w1, #0x106              ; =262
    4b98: 1400005c     	b	0x4d08 <___pl_fn_11+0x674>
    4b9c: 528020e1     	mov	w1, #0x107              ; =263
    4ba0: 528000e3     	mov	w3, #0x7                ; =7
    4ba4: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4ba8: f9400084     	ldr	x4, [x4]
    4bac: aa0603e2     	mov	x2, x6
    4bb0: aa1403e0     	mov	x0, x20
    4bb4: d63f0080     	blr	x4
    4bb8: 35000b00     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4bbc: 52802101     	mov	w1, #0x108              ; =264
    4bc0: 14000052     	b	0x4d08 <___pl_fn_11+0x674>
    4bc4: 52802121     	mov	w1, #0x109              ; =265
    4bc8: 52800043     	mov	w3, #0x2                ; =2
    4bcc: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4bd0: f9400084     	ldr	x4, [x4]
    4bd4: aa1403e0     	mov	x0, x20
    4bd8: d63f0080     	blr	x4
    4bdc: 350009e0     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4be0: 52802141     	mov	w1, #0x10a              ; =266
    4be4: 14000049     	b	0x4d08 <___pl_fn_11+0x674>
    4be8: d2800080     	mov	x0, #0x4                ; =4
    4bec: 910043e3     	add	x3, sp, #0x10
    4bf0: f80103e0     	stur	x0, [sp, #0x10]
    4bf4: d2800020     	mov	x0, #0x1                ; =1
    4bf8: f80183e0     	stur	x0, [sp, #0x18]
    4bfc: 52802161     	mov	w1, #0x10b              ; =267
    4c00: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4c04: f9400084     	ldr	x4, [x4]
    4c08: aa0603e2     	mov	x2, x6
    4c0c: aa1403e0     	mov	x0, x20
    4c10: d63f0080     	blr	x4
    4c14: 35000820     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4c18: 52802181     	mov	w1, #0x10c              ; =268
    4c1c: 1400003b     	b	0x4d08 <___pl_fn_11+0x674>
    4c20: d2800080     	mov	x0, #0x4                ; =4
    4c24: 910083e3     	add	x3, sp, #0x20
    4c28: f80203e0     	stur	x0, [sp, #0x20]
    4c2c: d2800000     	mov	x0, #0x0                ; =0
    4c30: f80283e0     	stur	x0, [sp, #0x28]
    4c34: 528021a1     	mov	w1, #0x10d              ; =269
    4c38: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4c3c: f9400084     	ldr	x4, [x4]
    4c40: aa0603e2     	mov	x2, x6
    4c44: aa1403e0     	mov	x0, x20
    4c48: d63f0080     	blr	x4
    4c4c: 35000660     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4c50: 528021c1     	mov	w1, #0x10e              ; =270
    4c54: 1400002d     	b	0x4d08 <___pl_fn_11+0x674>
    4c58: d28000a0     	mov	x0, #0x5                ; =5
    4c5c: 9100c3e3     	add	x3, sp, #0x30
    4c60: f80303e0     	stur	x0, [sp, #0x30]
    4c64: d2800000     	mov	x0, #0x0                ; =0
    4c68: f80383e0     	stur	x0, [sp, #0x38]
    4c6c: 528021e1     	mov	w1, #0x10f              ; =271
    4c70: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4c74: f9400084     	ldr	x4, [x4]
    4c78: aa0603e2     	mov	x2, x6
    4c7c: aa1403e0     	mov	x0, x20
    4c80: d63f0080     	blr	x4
    4c84: 350004a0     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4c88: 52802201     	mov	w1, #0x110              ; =272
    4c8c: 1400001f     	b	0x4d08 <___pl_fn_11+0x674>
    4c90: d28000c2     	mov	x2, #0x6                ; =6
    4c94: 910103e3     	add	x3, sp, #0x40
    4c98: f80403e2     	stur	x2, [sp, #0x40]
    4c9c: f80483e1     	stur	x1, [sp, #0x48]
    4ca0: 52802221     	mov	w1, #0x111              ; =273
    4ca4: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4ca8: f9400084     	ldr	x4, [x4]
    4cac: aa0603e2     	mov	x2, x6
    4cb0: aa1403e0     	mov	x0, x20
    4cb4: d63f0080     	blr	x4
    4cb8: 35000300     	cbnz	w0, 0x4d18 <___pl_fn_11+0x684>
    4cbc: 52802241     	mov	w1, #0x112              ; =274
    4cc0: 14000012     	b	0x4d08 <___pl_fn_11+0x674>
    4cc4: 52802341     	mov	w1, #0x11a              ; =282
    4cc8: 14000010     	b	0x4d08 <___pl_fn_11+0x674>
    4ccc: 52802321     	mov	w1, #0x119              ; =281
    4cd0: 1400000e     	b	0x4d08 <___pl_fn_11+0x674>
    4cd4: 52802301     	mov	w1, #0x118              ; =280
    4cd8: 1400000c     	b	0x4d08 <___pl_fn_11+0x674>
    4cdc: 528022e1     	mov	w1, #0x117              ; =279
    4ce0: 1400000a     	b	0x4d08 <___pl_fn_11+0x674>
    4ce4: 528022c1     	mov	w1, #0x116              ; =278
    4ce8: 14000008     	b	0x4d08 <___pl_fn_11+0x674>
    4cec: 528022a1     	mov	w1, #0x115              ; =277
    4cf0: 14000006     	b	0x4d08 <___pl_fn_11+0x674>
    4cf4: 52802281     	mov	w1, #0x114              ; =276
    4cf8: 14000004     	b	0x4d08 <___pl_fn_11+0x674>
    4cfc: 52802261     	mov	w1, #0x113              ; =275
    4d00: 14000002     	b	0x4d08 <___pl_fn_11+0x674>
    4d04: 52802001     	mov	w1, #0x100              ; =256
    4d08: 90000002     	adrp	x2, 0x4000 <___pl_fn_8+0xfc>
    4d0c: f9400042     	ldr	x2, [x2]
    4d10: aa1403e0     	mov	x0, x20
    4d14: d63f0040     	blr	x2
    4d18: 52800000     	mov	w0, #0x0                ; =0
    4d1c: 910143ff     	add	sp, sp, #0x50
    4d20: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4d24: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4d28: d65f03c0     	ret

0000000000004d2c <___pl_fn_12>:
    4d2c: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    4d30: 910003fd     	mov	x29, sp
    4d34: f81f0ff3     	str	x19, [sp, #-0x10]!
    4d38: d10043ff     	sub	sp, sp, #0x10
    4d3c: b9401003     	ldr	w3, [x0, #0x10]
    4d40: 11000462     	add	w2, w3, #0x1
    4d44: b9001002     	str	w2, [x0, #0x10]
    4d48: aa0003f3     	mov	x19, x0
    4d4c: 340001c1     	cbz	w1, 0x4d84 <___pl_fn_12+0x58>
    4d50: aa1303e0     	mov	x0, x19
    4d54: aa0103e2     	mov	x2, x1
    4d58: f9400001     	ldr	x1, [x0]
    4d5c: d2800024     	mov	x4, #0x1                ; =1
    4d60: 2a0203e5     	mov	w5, w2
    4d64: 8b050c21     	add	x1, x1, x5, lsl #3
    4d68: f9002024     	str	x4, [x1, #0x40]
    4d6c: b9001003     	str	w3, [x0, #0x10]
    4d70: aa0203e0     	mov	x0, x2
    4d74: 910043ff     	add	sp, sp, #0x10
    4d78: f84107f3     	ldr	x19, [sp], #0x10
    4d7c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4d80: d65f03c0     	ret
    4d84: aa0103e2     	mov	x2, x1
    4d88: d28000a0     	mov	x0, #0x5                ; =5
    4d8c: 910003e3     	mov	x3, sp
    4d90: f80003e0     	stur	x0, [sp]
    4d94: d2800020     	mov	x0, #0x1                ; =1
    4d98: f80083e0     	stur	x0, [sp, #0x8]
    4d9c: 52802361     	mov	w1, #0x11b              ; =283
    4da0: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4da4: f9400084     	ldr	x4, [x4]
    4da8: aa1303e0     	mov	x0, x19
    4dac: d63f0080     	blr	x4
    4db0: 350000c0     	cbnz	w0, 0x4dc8 <___pl_fn_12+0x9c>
    4db4: 52802381     	mov	w1, #0x11c              ; =284
    4db8: 90000002     	adrp	x2, 0x4000 <___pl_fn_8+0xfc>
    4dbc: f9400042     	ldr	x2, [x2]
    4dc0: aa1303e0     	mov	x0, x19
    4dc4: d63f0040     	blr	x2
    4dc8: 52800000     	mov	w0, #0x0                ; =0
    4dcc: 910043ff     	add	sp, sp, #0x10
    4dd0: f84107f3     	ldr	x19, [sp], #0x10
    4dd4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4dd8: d65f03c0     	ret

0000000000004ddc <___pl_fn_13>:
    4ddc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    4de0: 910003fd     	mov	x29, sp
    4de4: f81f0ff3     	str	x19, [sp, #-0x10]!
    4de8: d10083ff     	sub	sp, sp, #0x20
    4dec: b9401004     	ldr	w4, [x0, #0x10]
    4df0: 11000482     	add	w2, w4, #0x1
    4df4: b9001002     	str	w2, [x0, #0x10]
    4df8: 34000501     	cbz	w1, 0x4e98 <___pl_fn_13+0xbc>
    4dfc: f9400003     	ldr	x3, [x0]
    4e00: aa0003f3     	mov	x19, x0
    4e04: 2a0103e0     	mov	w0, w1
    4e08: aa0103e5     	mov	x5, x1
    4e0c: 8b000c61     	add	x1, x3, x0, lsl #3
    4e10: b9405022     	ldr	w2, [x1, #0x50]
    4e14: 34000462     	cbz	w2, 0x4ea0 <___pl_fn_13+0xc4>
    4e18: 34000582     	cbz	w2, 0x4ec8 <___pl_fn_13+0xec>
    4e1c: 2a0203e6     	mov	w6, w2
    4e20: 8b060c67     	add	x7, x3, x6, lsl #3
    4e24: f94030e6     	ldr	x6, [x7, #0x60]
    4e28: f94008e8     	ldr	x8, [x7, #0x10]
    4e2c: 374804e8     	tbnz	w8, #0x9, 0x4ec8 <___pl_fn_13+0xec>
    4e30: b27ff7ee     	mov	x14, #0x7ffffffffffffffe ; =9223372036854775806
    4e34: eb0e00df     	cmp	x6, x14
    4e38: 54000b6c     	b.gt	0x4fa4 <___pl_fn_13+0x1c8>
    4e3c: aa0503e0     	mov	x0, x5
    4e40: 34000560     	cbz	w0, 0x4eec <___pl_fn_13+0x110>
    4e44: 34000542     	cbz	w2, 0x4eec <___pl_fn_13+0x110>
    4e48: 34000662     	cbz	w2, 0x4f14 <___pl_fn_13+0x138>
    4e4c: f94008e0     	ldr	x0, [x7, #0x10]
    4e50: 9276f800     	and	x0, x0, #0xfffffffffffffdff
    4e54: f90008e0     	str	x0, [x7, #0x10]
    4e58: d2800022     	mov	x2, #0x1                ; =1
    4e5c: 910004c0     	add	x0, x6, #0x1
    4e60: f90030e0     	str	x0, [x7, #0x60]
    4e64: aa0503e0     	mov	x0, x5
    4e68: 34000700     	cbz	w0, 0x4f48 <___pl_fn_13+0x16c>
    4e6c: f9002422     	str	x2, [x1, #0x48]
    4e70: aa0503e2     	mov	x2, x5
    4e74: 34000842     	cbz	w2, 0x4f7c <___pl_fn_13+0x1a0>
    4e78: b9401820     	ldr	w0, [x1, #0x18]
    4e7c: 34000800     	cbz	w0, 0x4f7c <___pl_fn_13+0x1a0>
    4e80: aa1303e1     	mov	x1, x19
    4e84: b9001024     	str	w4, [x1, #0x10]
    4e88: 910083ff     	add	sp, sp, #0x20
    4e8c: f84107f3     	ldr	x19, [sp], #0x10
    4e90: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4e94: d65f03c0     	ret
    4e98: aa0103e5     	mov	x5, x1
    4e9c: aa0003f3     	mov	x19, x0
    4ea0: 528023a1     	mov	w1, #0x11d              ; =285
    4ea4: 528000e3     	mov	w3, #0x7                ; =7
    4ea8: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4eac: f9400084     	ldr	x4, [x4]
    4eb0: aa0503e2     	mov	x2, x5
    4eb4: aa1303e0     	mov	x0, x19
    4eb8: d63f0080     	blr	x4
    4ebc: 350007e0     	cbnz	w0, 0x4fb8 <___pl_fn_13+0x1dc>
    4ec0: 528023c1     	mov	w1, #0x11e              ; =286
    4ec4: 14000039     	b	0x4fa8 <___pl_fn_13+0x1cc>
    4ec8: 528023e1     	mov	w1, #0x11f              ; =287
    4ecc: 52800123     	mov	w3, #0x9                ; =9
    4ed0: 90000009     	adrp	x9, 0x4000 <___pl_fn_8+0xfc>
    4ed4: f9400129     	ldr	x9, [x9]
    4ed8: aa1303e0     	mov	x0, x19
    4edc: d63f0120     	blr	x9
    4ee0: 350006c0     	cbnz	w0, 0x4fb8 <___pl_fn_13+0x1dc>
    4ee4: 52802401     	mov	w1, #0x120              ; =288
    4ee8: 14000030     	b	0x4fa8 <___pl_fn_13+0x1cc>
    4eec: 52802441     	mov	w1, #0x122              ; =290
    4ef0: 528000e3     	mov	w3, #0x7                ; =7
    4ef4: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4ef8: f9400084     	ldr	x4, [x4]
    4efc: aa0503e2     	mov	x2, x5
    4f00: aa1303e0     	mov	x0, x19
    4f04: d63f0080     	blr	x4
    4f08: 35000580     	cbnz	w0, 0x4fb8 <___pl_fn_13+0x1dc>
    4f0c: 52802461     	mov	w1, #0x123              ; =291
    4f10: 14000026     	b	0x4fa8 <___pl_fn_13+0x1cc>
    4f14: d2800120     	mov	x0, #0x9                ; =9
    4f18: 910003e3     	mov	x3, sp
    4f1c: f80003e0     	stur	x0, [sp]
    4f20: 910004c0     	add	x0, x6, #0x1
    4f24: f80083e0     	stur	x0, [sp, #0x8]
    4f28: 52802481     	mov	w1, #0x124              ; =292
    4f2c: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4f30: f9400084     	ldr	x4, [x4]
    4f34: aa1303e0     	mov	x0, x19
    4f38: d63f0080     	blr	x4
    4f3c: 350003e0     	cbnz	w0, 0x4fb8 <___pl_fn_13+0x1dc>
    4f40: 528024a1     	mov	w1, #0x125              ; =293
    4f44: 14000019     	b	0x4fa8 <___pl_fn_13+0x1cc>
    4f48: d28000c0     	mov	x0, #0x6                ; =6
    4f4c: 910043e3     	add	x3, sp, #0x10
    4f50: f80103e0     	stur	x0, [sp, #0x10]
    4f54: f80183e2     	stur	x2, [sp, #0x18]
    4f58: 528024c1     	mov	w1, #0x126              ; =294
    4f5c: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4f60: f9400084     	ldr	x4, [x4]
    4f64: aa0503e2     	mov	x2, x5
    4f68: aa1303e0     	mov	x0, x19
    4f6c: d63f0080     	blr	x4
    4f70: 35000240     	cbnz	w0, 0x4fb8 <___pl_fn_13+0x1dc>
    4f74: 528024e1     	mov	w1, #0x127              ; =295
    4f78: 1400000c     	b	0x4fa8 <___pl_fn_13+0x1cc>
    4f7c: 52802501     	mov	w1, #0x128              ; =296
    4f80: 52800003     	mov	w3, #0x0                ; =0
    4f84: 90000004     	adrp	x4, 0x4000 <___pl_fn_8+0xfc>
    4f88: f9400084     	ldr	x4, [x4]
    4f8c: aa0503e2     	mov	x2, x5
    4f90: aa1303e0     	mov	x0, x19
    4f94: d63f0080     	blr	x4
    4f98: 35000100     	cbnz	w0, 0x4fb8 <___pl_fn_13+0x1dc>
    4f9c: 52802521     	mov	w1, #0x129              ; =297
    4fa0: 14000002     	b	0x4fa8 <___pl_fn_13+0x1cc>
    4fa4: 52802421     	mov	w1, #0x121              ; =289
    4fa8: 90000002     	adrp	x2, 0x4000 <___pl_fn_8+0xfc>
    4fac: f9400042     	ldr	x2, [x2]
    4fb0: aa1303e0     	mov	x0, x19
    4fb4: d63f0040     	blr	x2
    4fb8: 52800000     	mov	w0, #0x0                ; =0
    4fbc: 910083ff     	add	sp, sp, #0x20
    4fc0: f84107f3     	ldr	x19, [sp], #0x10
    4fc4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4fc8: d65f03c0     	ret

0000000000004fcc <___pl_fn_14>:
    4fcc: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    4fd0: 910003fd     	mov	x29, sp
    4fd4: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    4fd8: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    4fdc: d10043ff     	sub	sp, sp, #0x10
    4fe0: b9401003     	ldr	w3, [x0, #0x10]
    4fe4: 11000463     	add	w3, w3, #0x1
    4fe8: b9001003     	str	w3, [x0, #0x10]
    4fec: 34000921     	cbz	w1, 0x5110 <___pl_fn_14+0x144>
    4ff0: f9400003     	ldr	x3, [x0]
    4ff4: aa0003f5     	mov	x21, x0
    4ff8: 2a0103f3     	mov	w19, w1
    4ffc: aa0103f6     	mov	x22, x1
    5000: 8b130c60     	add	x0, x3, x19, lsl #3
    5004: b9405001     	ldr	w1, [x0, #0x50]
    5008: 34000881     	cbz	w1, 0x5118 <___pl_fn_14+0x14c>
    500c: aa1503e0     	mov	x0, x21
    5010: b9401814     	ldr	w20, [x0, #0x18]
    5014: b9401c08     	ldr	w8, [x0, #0x1c]
    5018: 11000687     	add	w7, w20, #0x1
    501c: 6b0800ff     	cmp	w7, w8
    5020: 54000dc8     	b.hi	0x51d8 <___pl_fn_14+0x20c>
    5024: aa1503e0     	mov	x0, x21
    5028: f9401009     	ldr	x9, [x0, #0x20]
    502c: b8345921     	str	w1, [x9, w20, uxtw #2]
    5030: b9001807     	str	w7, [x0, #0x18]
    5034: b940100b     	ldr	w11, [x0, #0x10]
    5038: b940140c     	ldr	w12, [x0, #0x14]
    503c: 6b0c017f     	cmp	w11, w12
    5040: 54000c82     	b.hs	0x51d0 <___pl_fn_14+0x204>
    5044: aa1503e0     	mov	x0, x21
    5048: 94000000     	bl	0x5048 <___pl_fn_14+0x7c>
    504c: aa1503e1     	mov	x1, x21
    5050: b9402c2d     	ldr	w13, [x1, #0x2c]
    5054: 35000ccd     	cbnz	w13, 0x51ec <___pl_fn_14+0x220>
    5058: aa1503e1     	mov	x1, x21
    505c: b9001834     	str	w20, [x1, #0x18]
    5060: 34000b40     	cbz	w0, 0x51c8 <___pl_fn_14+0x1fc>
    5064: 340006e0     	cbz	w0, 0x5140 <___pl_fn_14+0x174>
    5068: aa0003e2     	mov	x2, x0
    506c: aa1503e0     	mov	x0, x21
    5070: f9400000     	ldr	x0, [x0]
    5074: d2800001     	mov	x1, #0x0                ; =0
    5078: 2a0203e3     	mov	w3, w2
    507c: 8b030c03     	add	x3, x0, x3, lsl #3
    5080: f9002461     	str	x1, [x3, #0x48]
    5084: 340007c2     	cbz	w2, 0x517c <___pl_fn_14+0x1b0>
    5088: f9401461     	ldr	x1, [x3, #0x28]
    508c: f9400863     	ldr	x3, [x3, #0x10]
    5090: 37100763     	tbnz	w3, #0x2, 0x517c <___pl_fn_14+0x1b0>
    5094: aa0203e5     	mov	x5, x2
    5098: aa1603e2     	mov	x2, x22
    509c: 34000822     	cbz	w2, 0x51a0 <___pl_fn_14+0x1d4>
    50a0: 8b130c02     	add	x2, x0, x19, lsl #3
    50a4: f9401440     	ldr	x0, [x2, #0x28]
    50a8: f9400842     	ldr	x2, [x2, #0x10]
    50ac: 371007a2     	tbnz	w2, #0x2, 0x51a0 <___pl_fn_14+0x1d4>
    50b0: eb00003f     	cmp	x1, x0
    50b4: 5400018c     	b.gt	0x50e4 <___pl_fn_14+0x118>
    50b8: aa1503e0     	mov	x0, x21
    50bc: b9401000     	ldr	w0, [x0, #0x10]
    50c0: 51000400     	sub	w0, w0, #0x1
    50c4: aa1503e1     	mov	x1, x21
    50c8: b9001020     	str	w0, [x1, #0x10]
    50cc: aa1603e0     	mov	x0, x22
    50d0: 910043ff     	add	sp, sp, #0x10
    50d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    50d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    50dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    50e0: d65f03c0     	ret
    50e4: aa1503e0     	mov	x0, x21
    50e8: b9401000     	ldr	w0, [x0, #0x10]
    50ec: 51000400     	sub	w0, w0, #0x1
    50f0: aa1503e1     	mov	x1, x21
    50f4: b9001020     	str	w0, [x1, #0x10]
    50f8: aa0503e0     	mov	x0, x5
    50fc: 910043ff     	add	sp, sp, #0x10
    5100: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5104: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5108: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    510c: d65f03c0     	ret
    5110: aa0003f5     	mov	x21, x0
    5114: aa0103f6     	mov	x22, x1
    5118: 52802541     	mov	w1, #0x12a              ; =298
    511c: 528000e3     	mov	w3, #0x7                ; =7
    5120: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5124: f9400084     	ldr	x4, [x4]
    5128: aa1603e2     	mov	x2, x22
    512c: aa1503e0     	mov	x0, x21
    5130: d63f0080     	blr	x4
    5134: 350005c0     	cbnz	w0, 0x51ec <___pl_fn_14+0x220>
    5138: 52802561     	mov	w1, #0x12b              ; =299
    513c: 14000028     	b	0x51dc <___pl_fn_14+0x210>
    5140: aa0003e5     	mov	x5, x0
    5144: d28000c0     	mov	x0, #0x6                ; =6
    5148: 910003e3     	mov	x3, sp
    514c: f80003e0     	stur	x0, [sp]
    5150: d2800000     	mov	x0, #0x0                ; =0
    5154: f80083e0     	stur	x0, [sp, #0x8]
    5158: 528025e1     	mov	w1, #0x12f              ; =303
    515c: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5160: f9400084     	ldr	x4, [x4]
    5164: aa0503e2     	mov	x2, x5
    5168: aa1503e0     	mov	x0, x21
    516c: d63f0080     	blr	x4
    5170: 350003e0     	cbnz	w0, 0x51ec <___pl_fn_14+0x220>
    5174: 52802601     	mov	w1, #0x130              ; =304
    5178: 14000019     	b	0x51dc <___pl_fn_14+0x210>
    517c: 52802621     	mov	w1, #0x131              ; =305
    5180: 52800043     	mov	w3, #0x2                ; =2
    5184: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5188: f9400084     	ldr	x4, [x4]
    518c: aa1503e0     	mov	x0, x21
    5190: d63f0080     	blr	x4
    5194: 350002c0     	cbnz	w0, 0x51ec <___pl_fn_14+0x220>
    5198: 52802641     	mov	w1, #0x132              ; =306
    519c: 14000010     	b	0x51dc <___pl_fn_14+0x210>
    51a0: 52802661     	mov	w1, #0x133              ; =307
    51a4: 52800043     	mov	w3, #0x2                ; =2
    51a8: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    51ac: f9400084     	ldr	x4, [x4]
    51b0: aa1603e2     	mov	x2, x22
    51b4: aa1503e0     	mov	x0, x21
    51b8: d63f0080     	blr	x4
    51bc: 35000180     	cbnz	w0, 0x51ec <___pl_fn_14+0x220>
    51c0: 52802681     	mov	w1, #0x134              ; =308
    51c4: 14000006     	b	0x51dc <___pl_fn_14+0x210>
    51c8: 528025c1     	mov	w1, #0x12e              ; =302
    51cc: 14000004     	b	0x51dc <___pl_fn_14+0x210>
    51d0: 528025a1     	mov	w1, #0x12d              ; =301
    51d4: 14000002     	b	0x51dc <___pl_fn_14+0x210>
    51d8: 52802581     	mov	w1, #0x12c              ; =300
    51dc: 90000002     	adrp	x2, 0x5000 <___pl_fn_14+0x34>
    51e0: f9400042     	ldr	x2, [x2]
    51e4: aa1503e0     	mov	x0, x21
    51e8: d63f0040     	blr	x2
    51ec: 52800000     	mov	w0, #0x0                ; =0
    51f0: 910043ff     	add	sp, sp, #0x10
    51f4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    51f8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    51fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5200: d65f03c0     	ret

0000000000005204 <___pl_fn_15>:
    5204: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    5208: 910003fd     	mov	x29, sp
    520c: f81f0ff9     	str	x25, [sp, #-0x10]!
    5210: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
    5214: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    5218: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    521c: d100c3ff     	sub	sp, sp, #0x30
    5220: b9401003     	ldr	w3, [x0, #0x10]
    5224: 11000463     	add	w3, w3, #0x1
    5228: b9001003     	str	w3, [x0, #0x10]
    522c: 34000fc1     	cbz	w1, 0x5424 <___pl_fn_15+0x220>
    5230: f9400003     	ldr	x3, [x0]
    5234: aa0003f7     	mov	x23, x0
    5238: 2a0103f6     	mov	w22, w1
    523c: aa0103f8     	mov	x24, x1
    5240: 8b160c60     	add	x0, x3, x22, lsl #3
    5244: b9405001     	ldr	w1, [x0, #0x50]
    5248: 34000f21     	cbz	w1, 0x542c <___pl_fn_15+0x228>
    524c: 34001042     	cbz	w2, 0x5454 <___pl_fn_15+0x250>
    5250: 2a0203f5     	mov	w21, w2
    5254: 8b150c67     	add	x7, x3, x21, lsl #3
    5258: f94010e8     	ldr	x8, [x7, #0x20]
    525c: aa0803e3     	mov	x3, x8
    5260: f94008e8     	ldr	x8, [x7, #0x10]
    5264: 37080f88     	tbnz	w8, #0x1, 0x5454 <___pl_fn_15+0x250>
    5268: aa0203f9     	mov	x25, x2
    526c: aa1703e0     	mov	x0, x23
    5270: b9401813     	ldr	w19, [x0, #0x18]
    5274: b9401c0f     	ldr	w15, [x0, #0x1c]
    5278: 11000674     	add	w20, w19, #0x1
    527c: 6b0f029f     	cmp	w20, w15
    5280: 54001ce8     	b.hi	0x561c <___pl_fn_15+0x418>
    5284: aa1703e0     	mov	x0, x23
    5288: f9401000     	ldr	x0, [x0, #0x20]
    528c: b8335801     	str	w1, [x0, w19, uxtw #2]
    5290: aa1703e0     	mov	x0, x23
    5294: b9001814     	str	w20, [x0, #0x18]
    5298: b9401000     	ldr	w0, [x0, #0x10]
    529c: aa1703e2     	mov	x2, x23
    52a0: b9401442     	ldr	w2, [x2, #0x14]
    52a4: 6b02001f     	cmp	w0, w2
    52a8: 54001b62     	b.hs	0x5614 <___pl_fn_15+0x410>
    52ac: aa0303e2     	mov	x2, x3
    52b0: aa1703e0     	mov	x0, x23
    52b4: 94000000     	bl	0x52b4 <___pl_fn_15+0xb0>
    52b8: aa1703e1     	mov	x1, x23
    52bc: b9402c21     	ldr	w1, [x1, #0x2c]
    52c0: 35001b81     	cbnz	w1, 0x5630 <___pl_fn_15+0x42c>
    52c4: aa1703e1     	mov	x1, x23
    52c8: b9001833     	str	w19, [x1, #0x18]
    52cc: 34001a00     	cbz	w0, 0x560c <___pl_fn_15+0x408>
    52d0: aa1803e2     	mov	x2, x24
    52d4: 34000d22     	cbz	w2, 0x5478 <___pl_fn_15+0x274>
    52d8: aa1703e4     	mov	x4, x23
    52dc: f9400083     	ldr	x3, [x4]
    52e0: 8b160c61     	add	x1, x3, x22, lsl #3
    52e4: b9405022     	ldr	w2, [x1, #0x50]
    52e8: 34000c82     	cbz	w2, 0x5478 <___pl_fn_15+0x274>
    52ec: 34000da2     	cbz	w2, 0x54a0 <___pl_fn_15+0x29c>
    52f0: 2a0203e4     	mov	w4, w2
    52f4: 8b040c66     	add	x6, x3, x4, lsl #3
    52f8: f94034c5     	ldr	x5, [x6, #0x68]
    52fc: f94008c4     	ldr	x4, [x6, #0x10]
    5300: 37500d04     	tbnz	w4, #0xa, 0x54a0 <___pl_fn_15+0x29c>
    5304: b27ff7e4     	mov	x4, #0x7ffffffffffffffe ; =9223372036854775806
    5308: eb0400bf     	cmp	x5, x4
    530c: 540017cc     	b.gt	0x5604 <___pl_fn_15+0x400>
    5310: aa1803e4     	mov	x4, x24
    5314: 34000d84     	cbz	w4, 0x54c4 <___pl_fn_15+0x2c0>
    5318: 34000d62     	cbz	w2, 0x54c4 <___pl_fn_15+0x2c0>
    531c: 34000e82     	cbz	w2, 0x54ec <___pl_fn_15+0x2e8>
    5320: f94008c2     	ldr	x2, [x6, #0x10]
    5324: 9275f842     	and	x2, x2, #0xfffffffffffffbff
    5328: f90008c2     	str	x2, [x6, #0x10]
    532c: d2800024     	mov	x4, #0x1                ; =1
    5330: 910004a2     	add	x2, x5, #0x1
    5334: f90034c2     	str	x2, [x6, #0x68]
    5338: aa1803e2     	mov	x2, x24
    533c: 34000f22     	cbz	w2, 0x5520 <___pl_fn_15+0x31c>
    5340: b9405022     	ldr	w2, [x1, #0x50]
    5344: 34000ee2     	cbz	w2, 0x5520 <___pl_fn_15+0x31c>
    5348: 34001002     	cbz	w2, 0x5548 <___pl_fn_15+0x344>
    534c: 2a0203ef     	mov	w15, w2
    5350: 8b0f0c6f     	add	x15, x3, x15, lsl #3
    5354: b94029ef     	ldr	w15, [x15, #0x28]
    5358: 34000f8f     	cbz	w15, 0x5548 <___pl_fn_15+0x344>
    535c: aa1903e2     	mov	x2, x25
    5360: 34001062     	cbz	w2, 0x556c <___pl_fn_15+0x368>
    5364: 2a0f03e5     	mov	w5, w15
    5368: 8b150c63     	add	x3, x3, x21, lsl #3
    536c: f9000c65     	str	x5, [x3, #0x18]
    5370: aa1803e5     	mov	x5, x24
    5374: 34001165     	cbz	w5, 0x55a0 <___pl_fn_15+0x39c>
    5378: f9401025     	ldr	x5, [x1, #0x20]
    537c: f9400821     	ldr	x1, [x1, #0x10]
    5380: 37081101     	tbnz	w1, #0x1, 0x55a0 <___pl_fn_15+0x39c>
    5384: 34001222     	cbz	w2, 0x55c8 <___pl_fn_15+0x3c4>
    5388: f9400861     	ldr	x1, [x3, #0x10]
    538c: 927ef821     	and	x1, x1, #0xfffffffffffffffd
    5390: f9000861     	str	x1, [x3, #0x10]
    5394: f9001065     	str	x5, [x3, #0x20]
    5398: aa1703e1     	mov	x1, x23
    539c: b9401c21     	ldr	w1, [x1, #0x1c]
    53a0: 6b01029f     	cmp	w20, w1
    53a4: 540012c8     	b.hi	0x55fc <___pl_fn_15+0x3f8>
    53a8: aa1703e1     	mov	x1, x23
    53ac: f9401021     	ldr	x1, [x1, #0x20]
    53b0: b8335820     	str	w0, [x1, w19, uxtw #2]
    53b4: aa0003e3     	mov	x3, x0
    53b8: aa1703e0     	mov	x0, x23
    53bc: b9001814     	str	w20, [x0, #0x18]
    53c0: b9401000     	ldr	w0, [x0, #0x10]
    53c4: aa1703e1     	mov	x1, x23
    53c8: b9401421     	ldr	w1, [x1, #0x14]
    53cc: 6b01001f     	cmp	w0, w1
    53d0: 54001122     	b.hs	0x55f4 <___pl_fn_15+0x3f0>
    53d4: aa0303e1     	mov	x1, x3
    53d8: aa1803e3     	mov	x3, x24
    53dc: aa1703e0     	mov	x0, x23
    53e0: 94000000     	bl	0x53e0 <___pl_fn_15+0x1dc>
    53e4: aa1703e1     	mov	x1, x23
    53e8: b9402c21     	ldr	w1, [x1, #0x2c]
    53ec: 35001221     	cbnz	w1, 0x5630 <___pl_fn_15+0x42c>
    53f0: aa1703e1     	mov	x1, x23
    53f4: b9001833     	str	w19, [x1, #0x18]
    53f8: b9401021     	ldr	w1, [x1, #0x10]
    53fc: 51000421     	sub	w1, w1, #0x1
    5400: aa1703e2     	mov	x2, x23
    5404: b9001041     	str	w1, [x2, #0x10]
    5408: 9100c3ff     	add	sp, sp, #0x30
    540c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5410: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5414: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5418: f84107f9     	ldr	x25, [sp], #0x10
    541c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5420: d65f03c0     	ret
    5424: aa0003f7     	mov	x23, x0
    5428: aa0103f8     	mov	x24, x1
    542c: 528026a1     	mov	w1, #0x135              ; =309
    5430: 528000e3     	mov	w3, #0x7                ; =7
    5434: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5438: f9400084     	ldr	x4, [x4]
    543c: aa1803e2     	mov	x2, x24
    5440: aa1703e0     	mov	x0, x23
    5444: d63f0080     	blr	x4
    5448: 35000f40     	cbnz	w0, 0x5630 <___pl_fn_15+0x42c>
    544c: 528026c1     	mov	w1, #0x136              ; =310
    5450: 14000074     	b	0x5620 <___pl_fn_15+0x41c>
    5454: 528026e1     	mov	w1, #0x137              ; =311
    5458: 52800023     	mov	w3, #0x1                ; =1
    545c: 9000000a     	adrp	x10, 0x5000 <___pl_fn_14+0x34>
    5460: f940014a     	ldr	x10, [x10]
    5464: aa1703e0     	mov	x0, x23
    5468: d63f0140     	blr	x10
    546c: 35000e20     	cbnz	w0, 0x5630 <___pl_fn_15+0x42c>
    5470: 52802701     	mov	w1, #0x138              ; =312
    5474: 1400006b     	b	0x5620 <___pl_fn_15+0x41c>
    5478: 52802781     	mov	w1, #0x13c              ; =316
    547c: 528000e3     	mov	w3, #0x7                ; =7
    5480: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5484: f9400084     	ldr	x4, [x4]
    5488: aa1803e2     	mov	x2, x24
    548c: aa1703e0     	mov	x0, x23
    5490: d63f0080     	blr	x4
    5494: 35000ce0     	cbnz	w0, 0x5630 <___pl_fn_15+0x42c>
    5498: 528027a1     	mov	w1, #0x13d              ; =317
    549c: 14000061     	b	0x5620 <___pl_fn_15+0x41c>
    54a0: 528027c1     	mov	w1, #0x13e              ; =318
    54a4: 52800143     	mov	w3, #0xa                ; =10
    54a8: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    54ac: f9400084     	ldr	x4, [x4]
    54b0: aa1703e0     	mov	x0, x23
    54b4: d63f0080     	blr	x4
    54b8: 35000bc0     	cbnz	w0, 0x5630 <___pl_fn_15+0x42c>
    54bc: 528027e1     	mov	w1, #0x13f              ; =319
    54c0: 14000058     	b	0x5620 <___pl_fn_15+0x41c>
    54c4: 52802821     	mov	w1, #0x141              ; =321
    54c8: 528000e3     	mov	w3, #0x7                ; =7
    54cc: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    54d0: f9400084     	ldr	x4, [x4]
    54d4: aa1803e2     	mov	x2, x24
    54d8: aa1703e0     	mov	x0, x23
    54dc: d63f0080     	blr	x4
    54e0: 35000a80     	cbnz	w0, 0x5630 <___pl_fn_15+0x42c>
    54e4: 52802841     	mov	w1, #0x142              ; =322
    54e8: 1400004e     	b	0x5620 <___pl_fn_15+0x41c>
    54ec: d2800140     	mov	x0, #0xa                ; =10
    54f0: 910003e3     	mov	x3, sp
    54f4: f80003e0     	stur	x0, [sp]
    54f8: 910004a0     	add	x0, x5, #0x1
    54fc: f80083e0     	stur	x0, [sp, #0x8]
    5500: 52802861     	mov	w1, #0x143              ; =323
    5504: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5508: f9400084     	ldr	x4, [x4]
    550c: aa1703e0     	mov	x0, x23
    5510: d63f0080     	blr	x4
    5514: 350008e0     	cbnz	w0, 0x5630 <___pl_fn_15+0x42c>
    5518: 52802881     	mov	w1, #0x144              ; =324
    551c: 14000041     	b	0x5620 <___pl_fn_15+0x41c>
    5520: 528028a1     	mov	w1, #0x145              ; =325
    5524: 528000e3     	mov	w3, #0x7                ; =7
    5528: 90000008     	adrp	x8, 0x5000 <___pl_fn_14+0x34>
    552c: f9400108     	ldr	x8, [x8]
    5530: aa1803e2     	mov	x2, x24
    5534: aa1703e0     	mov	x0, x23
    5538: d63f0100     	blr	x8
    553c: 350007a0     	cbnz	w0, 0x5630 <___pl_fn_15+0x42c>
    5540: 528028c1     	mov	w1, #0x146              ; =326
    5544: 14000037     	b	0x5620 <___pl_fn_15+0x41c>
    5548: 528028e1     	mov	w1, #0x147              ; =327
    554c: 52800043     	mov	w3, #0x2                ; =2
    5550: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5554: f9400084     	ldr	x4, [x4]
    5558: aa1703e0     	mov	x0, x23
    555c: d63f0080     	blr	x4
    5560: 35000680     	cbnz	w0, 0x5630 <___pl_fn_15+0x42c>
    5564: 52802901     	mov	w1, #0x148              ; =328
    5568: 1400002e     	b	0x5620 <___pl_fn_15+0x41c>
    556c: d2800000     	mov	x0, #0x0                ; =0
    5570: 910043e3     	add	x3, sp, #0x10
    5574: f80103e0     	stur	x0, [sp, #0x10]
    5578: 2a0f03e0     	mov	w0, w15
    557c: f80183e0     	stur	x0, [sp, #0x18]
    5580: 52802921     	mov	w1, #0x149              ; =329
    5584: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5588: f9400084     	ldr	x4, [x4]
    558c: aa1703e0     	mov	x0, x23
    5590: d63f0080     	blr	x4
    5594: 350004e0     	cbnz	w0, 0x5630 <___pl_fn_15+0x42c>
    5598: 52802941     	mov	w1, #0x14a              ; =330
    559c: 14000021     	b	0x5620 <___pl_fn_15+0x41c>
    55a0: 52802961     	mov	w1, #0x14b              ; =331
    55a4: 52800023     	mov	w3, #0x1                ; =1
    55a8: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    55ac: f9400084     	ldr	x4, [x4]
    55b0: aa1803e2     	mov	x2, x24
    55b4: aa1703e0     	mov	x0, x23
    55b8: d63f0080     	blr	x4
    55bc: 350003a0     	cbnz	w0, 0x5630 <___pl_fn_15+0x42c>
    55c0: 52802981     	mov	w1, #0x14c              ; =332
    55c4: 14000017     	b	0x5620 <___pl_fn_15+0x41c>
    55c8: 910083e3     	add	x3, sp, #0x20
    55cc: f80203e4     	stur	x4, [sp, #0x20]
    55d0: f80283e5     	stur	x5, [sp, #0x28]
    55d4: 528029a1     	mov	w1, #0x14d              ; =333
    55d8: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    55dc: f9400084     	ldr	x4, [x4]
    55e0: aa1703e0     	mov	x0, x23
    55e4: d63f0080     	blr	x4
    55e8: 35000240     	cbnz	w0, 0x5630 <___pl_fn_15+0x42c>
    55ec: 528029c1     	mov	w1, #0x14e              ; =334
    55f0: 1400000c     	b	0x5620 <___pl_fn_15+0x41c>
    55f4: 52802a01     	mov	w1, #0x150              ; =336
    55f8: 1400000a     	b	0x5620 <___pl_fn_15+0x41c>
    55fc: 528029e1     	mov	w1, #0x14f              ; =335
    5600: 14000008     	b	0x5620 <___pl_fn_15+0x41c>
    5604: 52802801     	mov	w1, #0x140              ; =320
    5608: 14000006     	b	0x5620 <___pl_fn_15+0x41c>
    560c: 52802761     	mov	w1, #0x13b              ; =315
    5610: 14000004     	b	0x5620 <___pl_fn_15+0x41c>
    5614: 52802741     	mov	w1, #0x13a              ; =314
    5618: 14000002     	b	0x5620 <___pl_fn_15+0x41c>
    561c: 52802721     	mov	w1, #0x139              ; =313
    5620: 90000007     	adrp	x7, 0x5000 <___pl_fn_14+0x34>
    5624: f94000e7     	ldr	x7, [x7]
    5628: aa1703e0     	mov	x0, x23
    562c: d63f00e0     	blr	x7
    5630: 52800000     	mov	w0, #0x0                ; =0
    5634: 9100c3ff     	add	sp, sp, #0x30
    5638: a8c153f3     	ldp	x19, x20, [sp], #0x10
    563c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5640: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5644: f84107f9     	ldr	x25, [sp], #0x10
    5648: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    564c: d65f03c0     	ret

0000000000005650 <___pl_fn_16>:
    5650: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    5654: 910003fd     	mov	x29, sp
    5658: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    565c: d10083ff     	sub	sp, sp, #0x20
    5660: aa0203ed     	mov	x13, x2
    5664: b9401004     	ldr	w4, [x0, #0x10]
    5668: 11000482     	add	w2, w4, #0x1
    566c: b9001002     	str	w2, [x0, #0x10]
    5670: 34000e61     	cbz	w1, 0x583c <___pl_fn_16+0x1ec>
    5674: f9400003     	ldr	x3, [x0]
    5678: aa0003f4     	mov	x20, x0
    567c: 2a0103e0     	mov	w0, w1
    5680: aa0103e9     	mov	x9, x1
    5684: 8b000c61     	add	x1, x3, x0, lsl #3
    5688: b9405022     	ldr	w2, [x1, #0x50]
    568c: 34000dc2     	cbz	w2, 0x5844 <___pl_fn_16+0x1f4>
    5690: 34000ee2     	cbz	w2, 0x586c <___pl_fn_16+0x21c>
    5694: 2a0203e0     	mov	w0, w2
    5698: 8b000c60     	add	x0, x3, x0, lsl #3
    569c: b9402805     	ldr	w5, [x0, #0x28]
    56a0: 34000e65     	cbz	w5, 0x586c <___pl_fn_16+0x21c>
    56a4: aa0d03e0     	mov	x0, x13
    56a8: 6b05001f     	cmp	w0, w5
    56ac: 54000300     	b.eq	0x570c <___pl_fn_16+0xbc>
    56b0: aa0903e2     	mov	x2, x9
    56b4: 34000ee2     	cbz	w2, 0x5890 <___pl_fn_16+0x240>
    56b8: 2a0003e0     	mov	w0, w0
    56bc: f9002c20     	str	x0, [x1, #0x58]
    56c0: aa1403e0     	mov	x0, x20
    56c4: b9401401     	ldr	w1, [x0, #0x14]
    56c8: 11000482     	add	w2, w4, #0x1
    56cc: 6b01005f     	cmp	w2, w1
    56d0: 54000fc2     	b.hs	0x58c8 <___pl_fn_16+0x278>
    56d4: aa0903e1     	mov	x1, x9
    56d8: aa1403e0     	mov	x0, x20
    56dc: 94000000     	bl	0x56dc <___pl_fn_16+0x8c>
    56e0: aa1403e1     	mov	x1, x20
    56e4: b9402c23     	ldr	w3, [x1, #0x2c]
    56e8: 35001863     	cbnz	w3, 0x59f4 <___pl_fn_16+0x3a4>
    56ec: aa1403e1     	mov	x1, x20
    56f0: b9401025     	ldr	w5, [x1, #0x10]
    56f4: 510004a5     	sub	w5, w5, #0x1
    56f8: b9001025     	str	w5, [x1, #0x10]
    56fc: 910083ff     	add	sp, sp, #0x20
    5700: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5704: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5708: d65f03c0     	ret
    570c: aa0903e6     	mov	x6, x9
    5710: 34000e06     	cbz	w6, 0x58d0 <___pl_fn_16+0x280>
    5714: b940582a     	ldr	w10, [x1, #0x58]
    5718: aa0a03e0     	mov	x0, x10
    571c: 34000da0     	cbz	w0, 0x58d0 <___pl_fn_16+0x280>
    5720: aa0003ea     	mov	x10, x0
    5724: aa0a03e0     	mov	x0, x10
    5728: 340015c0     	cbz	w0, 0x59e0 <___pl_fn_16+0x390>
    572c: aa0903e0     	mov	x0, x9
    5730: 34000e40     	cbz	w0, 0x58f8 <___pl_fn_16+0x2a8>
    5734: 34000e22     	cbz	w2, 0x58f8 <___pl_fn_16+0x2a8>
    5738: 34000f42     	cbz	w2, 0x5920 <___pl_fn_16+0x2d0>
    573c: 34000f25     	cbz	w5, 0x5920 <___pl_fn_16+0x2d0>
    5740: aa0a03e3     	mov	x3, x10
    5744: 6b05007f     	cmp	w3, w5
    5748: 54000520     	b.eq	0x57ec <___pl_fn_16+0x19c>
    574c: aa0903e0     	mov	x0, x9
    5750: 34000fa0     	cbz	w0, 0x5944 <___pl_fn_16+0x2f4>
    5754: 34000f82     	cbz	w2, 0x5944 <___pl_fn_16+0x2f4>
    5758: 340010a2     	cbz	w2, 0x596c <___pl_fn_16+0x31c>
    575c: 34001085     	cbz	w5, 0x596c <___pl_fn_16+0x31c>
    5760: aa0903e2     	mov	x2, x9
    5764: 34001162     	cbz	w2, 0x5990 <___pl_fn_16+0x340>
    5768: 2a0503e2     	mov	w2, w5
    576c: f9002c22     	str	x2, [x1, #0x58]
    5770: aa1403e0     	mov	x0, x20
    5774: b9401813     	ldr	w19, [x0, #0x18]
    5778: b9401c04     	ldr	w4, [x0, #0x1c]
    577c: 11000663     	add	w3, w19, #0x1
    5780: 6b04007f     	cmp	w3, w4
    5784: 54001268     	b.hi	0x59d0 <___pl_fn_16+0x380>
    5788: aa1403e0     	mov	x0, x20
    578c: f9401005     	ldr	x5, [x0, #0x20]
    5790: aa0a03e2     	mov	x2, x10
    5794: b83358a2     	str	w2, [x5, w19, uxtw #2]
    5798: b9001803     	str	w3, [x0, #0x18]
    579c: b9401007     	ldr	w7, [x0, #0x10]
    57a0: b9401408     	ldr	w8, [x0, #0x14]
    57a4: 6b0800ff     	cmp	w7, w8
    57a8: 54001102     	b.hs	0x59c8 <___pl_fn_16+0x378>
    57ac: aa0903e1     	mov	x1, x9
    57b0: aa0a03e2     	mov	x2, x10
    57b4: aa1403e0     	mov	x0, x20
    57b8: 94000000     	bl	0x57b8 <___pl_fn_16+0x168>
    57bc: aa1403e1     	mov	x1, x20
    57c0: b9402c29     	ldr	w9, [x1, #0x2c]
    57c4: 35001189     	cbnz	w9, 0x59f4 <___pl_fn_16+0x3a4>
    57c8: aa1403e1     	mov	x1, x20
    57cc: b9001833     	str	w19, [x1, #0x18]
    57d0: b940102c     	ldr	w12, [x1, #0x10]
    57d4: 5100058c     	sub	w12, w12, #0x1
    57d8: b900102c     	str	w12, [x1, #0x10]
    57dc: 910083ff     	add	sp, sp, #0x20
    57e0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    57e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    57e8: d65f03c0     	ret
    57ec: aa1403e0     	mov	x0, x20
    57f0: b9401400     	ldr	w0, [x0, #0x14]
    57f4: 11000481     	add	w1, w4, #0x1
    57f8: 6b00003f     	cmp	w1, w0
    57fc: 54000ee2     	b.hs	0x59d8 <___pl_fn_16+0x388>
    5800: aa0903e1     	mov	x1, x9
    5804: aa1403e0     	mov	x0, x20
    5808: 94000000     	bl	0x5808 <___pl_fn_16+0x1b8>
    580c: aa1403e1     	mov	x1, x20
    5810: b9402c21     	ldr	w1, [x1, #0x2c]
    5814: 35000f01     	cbnz	w1, 0x59f4 <___pl_fn_16+0x3a4>
    5818: aa1403e1     	mov	x1, x20
    581c: b9401021     	ldr	w1, [x1, #0x10]
    5820: 51000421     	sub	w1, w1, #0x1
    5824: aa1403e2     	mov	x2, x20
    5828: b9001041     	str	w1, [x2, #0x10]
    582c: 910083ff     	add	sp, sp, #0x20
    5830: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5834: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5838: d65f03c0     	ret
    583c: aa0103e9     	mov	x9, x1
    5840: aa0003f4     	mov	x20, x0
    5844: 52802a21     	mov	w1, #0x151              ; =337
    5848: 528000e3     	mov	w3, #0x7                ; =7
    584c: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5850: f9400084     	ldr	x4, [x4]
    5854: aa0903e2     	mov	x2, x9
    5858: aa1403e0     	mov	x0, x20
    585c: d63f0080     	blr	x4
    5860: 35000ca0     	cbnz	w0, 0x59f4 <___pl_fn_16+0x3a4>
    5864: 52802a41     	mov	w1, #0x152              ; =338
    5868: 1400005f     	b	0x59e4 <___pl_fn_16+0x394>
    586c: 52802a61     	mov	w1, #0x153              ; =339
    5870: 52800043     	mov	w3, #0x2                ; =2
    5874: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5878: f9400084     	ldr	x4, [x4]
    587c: aa1403e0     	mov	x0, x20
    5880: d63f0080     	blr	x4
    5884: 35000b80     	cbnz	w0, 0x59f4 <___pl_fn_16+0x3a4>
    5888: 52802a81     	mov	w1, #0x154              ; =340
    588c: 14000056     	b	0x59e4 <___pl_fn_16+0x394>
    5890: d2800101     	mov	x1, #0x8                ; =8
    5894: 910003e3     	mov	x3, sp
    5898: f80003e1     	stur	x1, [sp]
    589c: 2a0003e0     	mov	w0, w0
    58a0: f80083e0     	stur	x0, [sp, #0x8]
    58a4: 52802aa1     	mov	w1, #0x155              ; =341
    58a8: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    58ac: f9400084     	ldr	x4, [x4]
    58b0: aa0903e2     	mov	x2, x9
    58b4: aa1403e0     	mov	x0, x20
    58b8: d63f0080     	blr	x4
    58bc: 350009c0     	cbnz	w0, 0x59f4 <___pl_fn_16+0x3a4>
    58c0: 52802ac1     	mov	w1, #0x156              ; =342
    58c4: 14000048     	b	0x59e4 <___pl_fn_16+0x394>
    58c8: 52802ae1     	mov	w1, #0x157              ; =343
    58cc: 14000046     	b	0x59e4 <___pl_fn_16+0x394>
    58d0: 52802b01     	mov	w1, #0x158              ; =344
    58d4: 52800103     	mov	w3, #0x8                ; =8
    58d8: 9000000c     	adrp	x12, 0x5000 <___pl_fn_14+0x34>
    58dc: f940018c     	ldr	x12, [x12]
    58e0: aa0903e2     	mov	x2, x9
    58e4: aa1403e0     	mov	x0, x20
    58e8: d63f0180     	blr	x12
    58ec: 35000840     	cbnz	w0, 0x59f4 <___pl_fn_16+0x3a4>
    58f0: 52802b21     	mov	w1, #0x159              ; =345
    58f4: 1400003c     	b	0x59e4 <___pl_fn_16+0x394>
    58f8: 52802b61     	mov	w1, #0x15b              ; =347
    58fc: 528000e3     	mov	w3, #0x7                ; =7
    5900: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5904: f9400084     	ldr	x4, [x4]
    5908: aa0903e2     	mov	x2, x9
    590c: aa1403e0     	mov	x0, x20
    5910: d63f0080     	blr	x4
    5914: 35000700     	cbnz	w0, 0x59f4 <___pl_fn_16+0x3a4>
    5918: 52802b81     	mov	w1, #0x15c              ; =348
    591c: 14000032     	b	0x59e4 <___pl_fn_16+0x394>
    5920: 52802ba1     	mov	w1, #0x15d              ; =349
    5924: 52800043     	mov	w3, #0x2                ; =2
    5928: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    592c: f9400084     	ldr	x4, [x4]
    5930: aa1403e0     	mov	x0, x20
    5934: d63f0080     	blr	x4
    5938: 350005e0     	cbnz	w0, 0x59f4 <___pl_fn_16+0x3a4>
    593c: 52802bc1     	mov	w1, #0x15e              ; =350
    5940: 14000029     	b	0x59e4 <___pl_fn_16+0x394>
    5944: 52802be1     	mov	w1, #0x15f              ; =351
    5948: 528000e3     	mov	w3, #0x7                ; =7
    594c: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5950: f9400084     	ldr	x4, [x4]
    5954: aa0903e2     	mov	x2, x9
    5958: aa1403e0     	mov	x0, x20
    595c: d63f0080     	blr	x4
    5960: 350004a0     	cbnz	w0, 0x59f4 <___pl_fn_16+0x3a4>
    5964: 52802c01     	mov	w1, #0x160              ; =352
    5968: 1400001f     	b	0x59e4 <___pl_fn_16+0x394>
    596c: 52802c21     	mov	w1, #0x161              ; =353
    5970: 52800043     	mov	w3, #0x2                ; =2
    5974: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    5978: f9400084     	ldr	x4, [x4]
    597c: aa1403e0     	mov	x0, x20
    5980: d63f0080     	blr	x4
    5984: 35000380     	cbnz	w0, 0x59f4 <___pl_fn_16+0x3a4>
    5988: 52802c41     	mov	w1, #0x162              ; =354
    598c: 14000016     	b	0x59e4 <___pl_fn_16+0x394>
    5990: d2800100     	mov	x0, #0x8                ; =8
    5994: 910043e3     	add	x3, sp, #0x10
    5998: f80103e0     	stur	x0, [sp, #0x10]
    599c: 2a0503e0     	mov	w0, w5
    59a0: f80183e0     	stur	x0, [sp, #0x18]
    59a4: 52802c61     	mov	w1, #0x163              ; =355
    59a8: 90000004     	adrp	x4, 0x5000 <___pl_fn_14+0x34>
    59ac: f9400084     	ldr	x4, [x4]
    59b0: aa0903e2     	mov	x2, x9
    59b4: aa1403e0     	mov	x0, x20
    59b8: d63f0080     	blr	x4
    59bc: 350001c0     	cbnz	w0, 0x59f4 <___pl_fn_16+0x3a4>
    59c0: 52802c81     	mov	w1, #0x164              ; =356
    59c4: 14000008     	b	0x59e4 <___pl_fn_16+0x394>
    59c8: 52802cc1     	mov	w1, #0x166              ; =358
    59cc: 14000006     	b	0x59e4 <___pl_fn_16+0x394>
    59d0: 52802ca1     	mov	w1, #0x165              ; =357
    59d4: 14000004     	b	0x59e4 <___pl_fn_16+0x394>
    59d8: 52802ce1     	mov	w1, #0x167              ; =359
    59dc: 14000002     	b	0x59e4 <___pl_fn_16+0x394>
    59e0: 52802b41     	mov	w1, #0x15a              ; =346
    59e4: 90000002     	adrp	x2, 0x5000 <___pl_fn_14+0x34>
    59e8: f9400042     	ldr	x2, [x2]
    59ec: aa1403e0     	mov	x0, x20
    59f0: d63f0040     	blr	x2
    59f4: 52800000     	mov	w0, #0x0                ; =0
    59f8: 910083ff     	add	sp, sp, #0x20
    59fc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5a00: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5a04: d65f03c0     	ret

0000000000005a08 <___pl_fn_17>:
    5a08: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    5a0c: 910003fd     	mov	x29, sp
    5a10: f81f0ffc     	str	x28, [sp, #-0x10]!
    5a14: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
    5a18: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
    5a1c: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    5a20: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    5a24: d10183ff     	sub	sp, sp, #0x60
    5a28: aa0203e5     	mov	x5, x2
    5a2c: b9401002     	ldr	w2, [x0, #0x10]
    5a30: 11000442     	add	w2, w2, #0x1
    5a34: b9001002     	str	w2, [x0, #0x10]
    5a38: 34002ec1     	cbz	w1, 0x6010 <___pl_fn_17+0x608>
    5a3c: f9400004     	ldr	x4, [x0]
    5a40: aa0003f9     	mov	x25, x0
    5a44: 2a0103fc     	mov	w28, w1
    5a48: aa0103fa     	mov	x26, x1
    5a4c: 8b1c0c80     	add	x0, x4, x28, lsl #3
    5a50: b9405002     	ldr	w2, [x0, #0x50]
    5a54: 34002e22     	cbz	w2, 0x6018 <___pl_fn_17+0x610>
    5a58: 34002f42     	cbz	w2, 0x6040 <___pl_fn_17+0x638>
    5a5c: 2a0203e1     	mov	w1, w2
    5a60: 8b010c81     	add	x1, x4, x1, lsl #3
    5a64: b9402823     	ldr	w3, [x1, #0x28]
    5a68: 34002ec3     	cbz	w3, 0x6040 <___pl_fn_17+0x638>
    5a6c: aa0203e6     	mov	x6, x2
    5a70: aa0503e2     	mov	x2, x5
    5a74: 6b03005f     	cmp	w2, w3
    5a78: 54000061     	b.ne	0x5a84 <___pl_fn_17+0x7c>
    5a7c: aa1a03e2     	mov	x2, x26
    5a80: 14000068     	b	0x5c20 <___pl_fn_17+0x218>
    5a84: 34002f02     	cbz	w2, 0x6064 <___pl_fn_17+0x65c>
    5a88: 2a0203e1     	mov	w1, w2
    5a8c: 8b010c84     	add	x4, x4, x1, lsl #3
    5a90: f9401481     	ldr	x1, [x4, #0x28]
    5a94: f9400884     	ldr	x4, [x4, #0x10]
    5a98: 37102e64     	tbnz	w4, #0x2, 0x6064 <___pl_fn_17+0x65c>
    5a9c: aa0203e5     	mov	x5, x2
    5aa0: f10fa43f     	cmp	x1, #0x3e9
    5aa4: 54000620     	b.eq	0x5b68 <___pl_fn_17+0x160>
    5aa8: aa1a03e2     	mov	x2, x26
    5aac: 34002ee2     	cbz	w2, 0x6088 <___pl_fn_17+0x680>
    5ab0: b9406002     	ldr	w2, [x0, #0x60]
    5ab4: 34002ea2     	cbz	w2, 0x6088 <___pl_fn_17+0x680>
    5ab8: aa0203ef     	mov	x15, x2
    5abc: aa1a03e2     	mov	x2, x26
    5ac0: 34002f82     	cbz	w2, 0x60b0 <___pl_fn_17+0x6a8>
    5ac4: aa0603e2     	mov	x2, x6
    5ac8: 34002f42     	cbz	w2, 0x60b0 <___pl_fn_17+0x6a8>
    5acc: 34003062     	cbz	w2, 0x60d8 <___pl_fn_17+0x6d0>
    5ad0: 34003043     	cbz	w3, 0x60d8 <___pl_fn_17+0x6d0>
    5ad4: aa1903e0     	mov	x0, x25
    5ad8: b9401817     	ldr	w23, [x0, #0x18]
    5adc: b9401c00     	ldr	w0, [x0, #0x1c]
    5ae0: 11000ae1     	add	w1, w23, #0x2
    5ae4: 6b00003f     	cmp	w1, w0
    5ae8: 540032a8     	b.hi	0x613c <___pl_fn_17+0x734>
    5aec: aa1903e0     	mov	x0, x25
    5af0: f9401000     	ldr	x0, [x0, #0x20]
    5af4: 2a1703e1     	mov	w1, w23
    5af8: 8b010801     	add	x1, x0, x1, lsl #2
    5afc: aa0f03e2     	mov	x2, x15
    5b00: b8375802     	str	w2, [x0, w23, uxtw #2]
    5b04: b9000423     	str	w3, [x1, #0x4]
    5b08: 11000ae0     	add	w0, w23, #0x2
    5b0c: aa1903e1     	mov	x1, x25
    5b10: b9001820     	str	w0, [x1, #0x18]
    5b14: aa1903e0     	mov	x0, x25
    5b18: b9401000     	ldr	w0, [x0, #0x10]
    5b1c: b9401421     	ldr	w1, [x1, #0x14]
    5b20: 6b01001f     	cmp	w0, w1
    5b24: 54003082     	b.hs	0x6134 <___pl_fn_17+0x72c>
    5b28: aa0503e1     	mov	x1, x5
    5b2c: aa1903e0     	mov	x0, x25
    5b30: 94000000     	bl	0x5b30 <___pl_fn_17+0x128>
    5b34: aa1903e1     	mov	x1, x25
    5b38: b9402c21     	ldr	w1, [x1, #0x2c]
    5b3c: 35004ac1     	cbnz	w1, 0x6494 <___pl_fn_17+0xa8c>
    5b40: aa1903e1     	mov	x1, x25
    5b44: b9001837     	str	w23, [x1, #0x18]
    5b48: aa1a03e2     	mov	x2, x26
    5b4c: 34002d82     	cbz	w2, 0x60fc <___pl_fn_17+0x6f4>
    5b50: aa1903e1     	mov	x1, x25
    5b54: f9400021     	ldr	x1, [x1]
    5b58: 2a0003e0     	mov	w0, w0
    5b5c: 8b1c0c21     	add	x1, x1, x28, lsl #3
    5b60: f9003020     	str	x0, [x1, #0x60]
    5b64: 1400002e     	b	0x5c1c <___pl_fn_17+0x214>
    5b68: aa0503e1     	mov	x1, x5
    5b6c: aa0603e2     	mov	x2, x6
    5b70: aa1a03e4     	mov	x4, x26
    5b74: 34002e84     	cbz	w4, 0x6144 <___pl_fn_17+0x73c>
    5b78: b9405800     	ldr	w0, [x0, #0x58]
    5b7c: 34002e40     	cbz	w0, 0x6144 <___pl_fn_17+0x73c>
    5b80: aa0003ed     	mov	x13, x0
    5b84: aa1a03ee     	mov	x14, x26
    5b88: 34002f2e     	cbz	w14, 0x616c <___pl_fn_17+0x764>
    5b8c: 34002f02     	cbz	w2, 0x616c <___pl_fn_17+0x764>
    5b90: 34003022     	cbz	w2, 0x6194 <___pl_fn_17+0x78c>
    5b94: 34003003     	cbz	w3, 0x6194 <___pl_fn_17+0x78c>
    5b98: aa1903e0     	mov	x0, x25
    5b9c: b9401813     	ldr	w19, [x0, #0x18]
    5ba0: b9401c09     	ldr	w9, [x0, #0x1c]
    5ba4: 11000a6a     	add	w10, w19, #0x2
    5ba8: 6b09015f     	cmp	w10, w9
    5bac: 540046a8     	b.hi	0x6480 <___pl_fn_17+0xa78>
    5bb0: aa1903e0     	mov	x0, x25
    5bb4: f940100b     	ldr	x11, [x0, #0x20]
    5bb8: 2a1303ec     	mov	w12, w19
    5bbc: 8b0c096c     	add	x12, x11, x12, lsl #2
    5bc0: aa0d03e2     	mov	x2, x13
    5bc4: b8335962     	str	w2, [x11, w19, uxtw #2]
    5bc8: b9000583     	str	w3, [x12, #0x4]
    5bcc: 11000a6d     	add	w13, w19, #0x2
    5bd0: b900180d     	str	w13, [x0, #0x18]
    5bd4: b940100e     	ldr	w14, [x0, #0x10]
    5bd8: b940140f     	ldr	w15, [x0, #0x14]
    5bdc: 6b0f01df     	cmp	w14, w15
    5be0: 540044c2     	b.hs	0x6478 <___pl_fn_17+0xa70>
    5be4: aa1903e0     	mov	x0, x25
    5be8: 94000000     	bl	0x5be8 <___pl_fn_17+0x1e0>
    5bec: aa1903e2     	mov	x2, x25
    5bf0: b9402c41     	ldr	w1, [x2, #0x2c]
    5bf4: 35004501     	cbnz	w1, 0x6494 <___pl_fn_17+0xa8c>
    5bf8: aa1903e6     	mov	x6, x25
    5bfc: b90018d3     	str	w19, [x6, #0x18]
    5c00: aa1a03e2     	mov	x2, x26
    5c04: 34002da2     	cbz	w2, 0x61b8 <___pl_fn_17+0x7b0>
    5c08: aa1903e1     	mov	x1, x25
    5c0c: f9400021     	ldr	x1, [x1]
    5c10: 2a0003e0     	mov	w0, w0
    5c14: 8b1c0c21     	add	x1, x1, x28, lsl #3
    5c18: f9002c20     	str	x0, [x1, #0x58]
    5c1c: aa1a03e2     	mov	x2, x26
    5c20: aa1a03e2     	mov	x2, x26
    5c24: 34002e62     	cbz	w2, 0x61f0 <___pl_fn_17+0x7e8>
    5c28: aa1903e0     	mov	x0, x25
    5c2c: f9400000     	ldr	x0, [x0]
    5c30: 8b1c0c01     	add	x1, x0, x28, lsl #3
    5c34: b9405822     	ldr	w2, [x1, #0x58]
    5c38: aa0203f7     	mov	x23, x2
    5c3c: 34002da2     	cbz	w2, 0x61f0 <___pl_fn_17+0x7e8>
    5c40: aa1703e2     	mov	x2, x23
    5c44: 34004162     	cbz	w2, 0x6470 <___pl_fn_17+0xa68>
    5c48: aa1a03e2     	mov	x2, x26
    5c4c: 34002e62     	cbz	w2, 0x6218 <___pl_fn_17+0x810>
    5c50: b9405022     	ldr	w2, [x1, #0x50]
    5c54: 34002e22     	cbz	w2, 0x6218 <___pl_fn_17+0x810>
    5c58: 34002f42     	cbz	w2, 0x6240 <___pl_fn_17+0x838>
    5c5c: 2a0203e1     	mov	w1, w2
    5c60: 8b010c01     	add	x1, x0, x1, lsl #3
    5c64: b9402821     	ldr	w1, [x1, #0x28]
    5c68: 34002ec1     	cbz	w1, 0x6240 <___pl_fn_17+0x838>
    5c6c: aa1703e2     	mov	x2, x23
    5c70: 6b01005f     	cmp	w2, w1
    5c74: 540019c0     	b.eq	0x5fac <___pl_fn_17+0x5a4>
    5c78: aa1703e2     	mov	x2, x23
    5c7c: 34002f42     	cbz	w2, 0x6264 <___pl_fn_17+0x85c>
    5c80: aa1703e2     	mov	x2, x23
    5c84: 2a0203f3     	mov	w19, w2
    5c88: 8b130c00     	add	x0, x0, x19, lsl #3
    5c8c: f9401814     	ldr	x20, [x0, #0x30]
    5c90: f9400801     	ldr	x1, [x0, #0x10]
    5c94: 37182e81     	tbnz	w1, #0x3, 0x6264 <___pl_fn_17+0x85c>
    5c98: f100129f     	cmp	x20, #0x4
    5c9c: 5400128a     	b.ge	0x5eec <___pl_fn_17+0x4e4>
    5ca0: aa1a03e2     	mov	x2, x26
    5ca4: 34002f42     	cbz	w2, 0x628c <___pl_fn_17+0x884>
    5ca8: aa1903e0     	mov	x0, x25
    5cac: f940000e     	ldr	x14, [x0]
    5cb0: 8b1c0dcd     	add	x13, x14, x28, lsl #3
    5cb4: b94061a2     	ldr	w2, [x13, #0x60]
    5cb8: aa0203f8     	mov	x24, x2
    5cbc: 34002e82     	cbz	w2, 0x628c <___pl_fn_17+0x884>
    5cc0: aa1803e2     	mov	x2, x24
    5cc4: 34003982     	cbz	w2, 0x63f4 <___pl_fn_17+0x9ec>
    5cc8: aa1a03e2     	mov	x2, x26
    5ccc: 34002f42     	cbz	w2, 0x62b4 <___pl_fn_17+0x8ac>
    5cd0: b94051a2     	ldr	w2, [x13, #0x50]
    5cd4: 34002f02     	cbz	w2, 0x62b4 <___pl_fn_17+0x8ac>
    5cd8: 34003022     	cbz	w2, 0x62dc <___pl_fn_17+0x8d4>
    5cdc: 2a0203e0     	mov	w0, w2
    5ce0: 8b000dc0     	add	x0, x14, x0, lsl #3
    5ce4: b9402800     	ldr	w0, [x0, #0x28]
    5ce8: 34002fa0     	cbz	w0, 0x62dc <___pl_fn_17+0x8d4>
    5cec: aa1803e2     	mov	x2, x24
    5cf0: 6b00005f     	cmp	w2, w0
    5cf4: 54000ca0     	b.eq	0x5e88 <___pl_fn_17+0x480>
    5cf8: aa1803e2     	mov	x2, x24
    5cfc: 34003022     	cbz	w2, 0x6300 <___pl_fn_17+0x8f8>
    5d00: aa1803e2     	mov	x2, x24
    5d04: 2a0203f6     	mov	w22, w2
    5d08: 8b160dc0     	add	x0, x14, x22, lsl #3
    5d0c: b9401800     	ldr	w0, [x0, #0x18]
    5d10: 34002f80     	cbz	w0, 0x6300 <___pl_fn_17+0x8f8>
    5d14: aa1a03e2     	mov	x2, x26
    5d18: 34003082     	cbz	w2, 0x6328 <___pl_fn_17+0x920>
    5d1c: 2a0003e0     	mov	w0, w0
    5d20: f90031a0     	str	x0, [x13, #0x60]
    5d24: aa1903e0     	mov	x0, x25
    5d28: b9401815     	ldr	w21, [x0, #0x18]
    5d2c: b9401c00     	ldr	w0, [x0, #0x1c]
    5d30: 11000aa1     	add	w1, w21, #0x2
    5d34: 6b00003f     	cmp	w1, w0
    5d38: 54003568     	b.hi	0x63e4 <___pl_fn_17+0x9dc>
    5d3c: aa1903e0     	mov	x0, x25
    5d40: f9401000     	ldr	x0, [x0, #0x20]
    5d44: 2a1503e1     	mov	w1, w21
    5d48: 8b010801     	add	x1, x0, x1, lsl #2
    5d4c: aa1703e2     	mov	x2, x23
    5d50: b8355802     	str	w2, [x0, w21, uxtw #2]
    5d54: aa1803e2     	mov	x2, x24
    5d58: b9000422     	str	w2, [x1, #0x4]
    5d5c: 11000aa1     	add	w1, w21, #0x2
    5d60: aa1903e0     	mov	x0, x25
    5d64: b9001801     	str	w1, [x0, #0x18]
    5d68: b9401002     	ldr	w2, [x0, #0x10]
    5d6c: b9401403     	ldr	w3, [x0, #0x14]
    5d70: 6b03005f     	cmp	w2, w3
    5d74: 54003342     	b.hs	0x63dc <___pl_fn_17+0x9d4>
    5d78: aa1903e0     	mov	x0, x25
    5d7c: aa1703e1     	mov	x1, x23
    5d80: aa1403e2     	mov	x2, x20
    5d84: 94000000     	bl	0x5d84 <___pl_fn_17+0x37c>
    5d88: aa1903e1     	mov	x1, x25
    5d8c: b9402c24     	ldr	w4, [x1, #0x2c]
    5d90: 35003824     	cbnz	w4, 0x6494 <___pl_fn_17+0xa8c>
    5d94: aa1903e1     	mov	x1, x25
    5d98: b9001835     	str	w21, [x1, #0x18]
    5d9c: aa1803e2     	mov	x2, x24
    5da0: 34002e02     	cbz	w2, 0x6360 <___pl_fn_17+0x958>
    5da4: aa1903e1     	mov	x1, x25
    5da8: aa0203f8     	mov	x24, x2
    5dac: f940002e     	ldr	x14, [x1]
    5db0: 8b160dcf     	add	x15, x14, x22, lsl #3
    5db4: f94009e1     	ldr	x1, [x15, #0x10]
    5db8: 927cf821     	and	x1, x1, #0xfffffffffffffff7
    5dbc: f90009e1     	str	x1, [x15, #0x10]
    5dc0: 8b160dc1     	add	x1, x14, x22, lsl #3
    5dc4: f9001820     	str	x0, [x1, #0x30]
    5dc8: b27ff7e0     	mov	x0, #0x7ffffffffffffffe ; =9223372036854775806
    5dcc: eb00029f     	cmp	x20, x0
    5dd0: 5400302c     	b.gt	0x63d4 <___pl_fn_17+0x9cc>
    5dd4: aa1703e2     	mov	x2, x23
    5dd8: 34002dc2     	cbz	w2, 0x6390 <___pl_fn_17+0x988>
    5ddc: 8b130dc0     	add	x0, x14, x19, lsl #3
    5de0: f9400801     	ldr	x1, [x0, #0x10]
    5de4: 927cf821     	and	x1, x1, #0xfffffffffffffff7
    5de8: f9000801     	str	x1, [x0, #0x10]
    5dec: 91000680     	add	x0, x20, #0x1
    5df0: 8b130dc1     	add	x1, x14, x19, lsl #3
    5df4: f9001820     	str	x0, [x1, #0x30]
    5df8: aa1903e0     	mov	x0, x25
    5dfc: b9401c01     	ldr	w1, [x0, #0x1c]
    5e00: 110006a0     	add	w0, w21, #0x1
    5e04: 6b01001f     	cmp	w0, w1
    5e08: 54002e28     	b.hi	0x63cc <___pl_fn_17+0x9c4>
    5e0c: aa1903e1     	mov	x1, x25
    5e10: f9401021     	ldr	x1, [x1, #0x20]
    5e14: aa1803e2     	mov	x2, x24
    5e18: b8355822     	str	w2, [x1, w21, uxtw #2]
    5e1c: aa1903e1     	mov	x1, x25
    5e20: b9001820     	str	w0, [x1, #0x18]
    5e24: aa1903e0     	mov	x0, x25
    5e28: b9401000     	ldr	w0, [x0, #0x10]
    5e2c: b9401421     	ldr	w1, [x1, #0x14]
    5e30: 6b01001f     	cmp	w0, w1
    5e34: 54002c82     	b.hs	0x63c4 <___pl_fn_17+0x9bc>
    5e38: aa1a03e1     	mov	x1, x26
    5e3c: aa1903e0     	mov	x0, x25
    5e40: 94000000     	bl	0x5e40 <___pl_fn_17+0x438>
    5e44: aa1903e1     	mov	x1, x25
    5e48: b9402c21     	ldr	w1, [x1, #0x2c]
    5e4c: 35003241     	cbnz	w1, 0x6494 <___pl_fn_17+0xa8c>
    5e50: aa1903e1     	mov	x1, x25
    5e54: b9001835     	str	w21, [x1, #0x18]
    5e58: b9401021     	ldr	w1, [x1, #0x10]
    5e5c: 51000421     	sub	w1, w1, #0x1
    5e60: aa1903e2     	mov	x2, x25
    5e64: b9001041     	str	w1, [x2, #0x10]
    5e68: 910183ff     	add	sp, sp, #0x60
    5e6c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5e70: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5e74: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5e78: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5e7c: f84107fc     	ldr	x28, [sp], #0x10
    5e80: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5e84: d65f03c0     	ret
    5e88: aa1903e0     	mov	x0, x25
    5e8c: b9401000     	ldr	w0, [x0, #0x10]
    5e90: aa1903e1     	mov	x1, x25
    5e94: b9401421     	ldr	w1, [x1, #0x14]
    5e98: 6b01001f     	cmp	w0, w1
    5e9c: 54002a82     	b.hs	0x63ec <___pl_fn_17+0x9e4>
    5ea0: aa1a03e1     	mov	x1, x26
    5ea4: aa1903e0     	mov	x0, x25
    5ea8: 94000000     	bl	0x5ea8 <___pl_fn_17+0x4a0>
    5eac: aa1903e5     	mov	x5, x25
    5eb0: b9402ca1     	ldr	w1, [x5, #0x2c]
    5eb4: 35002f01     	cbnz	w1, 0x6494 <___pl_fn_17+0xa8c>
    5eb8: aa1903e9     	mov	x9, x25
    5ebc: b9401121     	ldr	w1, [x9, #0x10]
    5ec0: 51000421     	sub	w1, w1, #0x1
    5ec4: aa1903ec     	mov	x12, x25
    5ec8: b9001181     	str	w1, [x12, #0x10]
    5ecc: 910183ff     	add	sp, sp, #0x60
    5ed0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5ed4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5ed8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5edc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5ee0: f84107fc     	ldr	x28, [sp], #0x10
    5ee4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5ee8: d65f03c0     	ret
    5eec: aa1703e2     	mov	x2, x23
    5ef0: 34002862     	cbz	w2, 0x63fc <___pl_fn_17+0x9f4>
    5ef4: aa1903e0     	mov	x0, x25
    5ef8: f9400000     	ldr	x0, [x0]
    5efc: 8b130c01     	add	x1, x0, x19, lsl #3
    5f00: b9401821     	ldr	w1, [x1, #0x18]
    5f04: 340027c1     	cbz	w1, 0x63fc <___pl_fn_17+0x9f4>
    5f08: aa1a03e3     	mov	x3, x26
    5f0c: 340028a3     	cbz	w3, 0x6420 <___pl_fn_17+0xa18>
    5f10: 2a0103ea     	mov	w10, w1
    5f14: 8b1c0c0b     	add	x11, x0, x28, lsl #3
    5f18: f9002d6a     	str	x10, [x11, #0x58]
    5f1c: aa1903e0     	mov	x0, x25
    5f20: b9401813     	ldr	w19, [x0, #0x18]
    5f24: b9401c0d     	ldr	w13, [x0, #0x1c]
    5f28: 1100066c     	add	w12, w19, #0x1
    5f2c: 6b0d019f     	cmp	w12, w13
    5f30: 54002988     	b.hi	0x6460 <___pl_fn_17+0xa58>
    5f34: aa1903e0     	mov	x0, x25
    5f38: f940100e     	ldr	x14, [x0, #0x20]
    5f3c: b83359c2     	str	w2, [x14, w19, uxtw #2]
    5f40: b900180c     	str	w12, [x0, #0x18]
    5f44: b9401000     	ldr	w0, [x0, #0x10]
    5f48: aa1903e6     	mov	x6, x25
    5f4c: b94014c1     	ldr	w1, [x6, #0x14]
    5f50: 6b01001f     	cmp	w0, w1
    5f54: 54002822     	b.hs	0x6458 <___pl_fn_17+0xa50>
    5f58: aa1a03e1     	mov	x1, x26
    5f5c: aa1903e0     	mov	x0, x25
    5f60: 94000000     	bl	0x5f60 <___pl_fn_17+0x558>
    5f64: aa1903eb     	mov	x11, x25
    5f68: b9402d61     	ldr	w1, [x11, #0x2c]
    5f6c: 35002941     	cbnz	w1, 0x6494 <___pl_fn_17+0xa8c>
    5f70: aa1903ef     	mov	x15, x25
    5f74: b90019f3     	str	w19, [x15, #0x18]
    5f78: aa1903e1     	mov	x1, x25
    5f7c: b9401021     	ldr	w1, [x1, #0x10]
    5f80: 51000421     	sub	w1, w1, #0x1
    5f84: aa1903e2     	mov	x2, x25
    5f88: b9001041     	str	w1, [x2, #0x10]
    5f8c: 910183ff     	add	sp, sp, #0x60
    5f90: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5f94: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5f98: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5f9c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5fa0: f84107fc     	ldr	x28, [sp], #0x10
    5fa4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5fa8: d65f03c0     	ret
    5fac: aa1903e0     	mov	x0, x25
    5fb0: b9401000     	ldr	w0, [x0, #0x10]
    5fb4: aa1903e1     	mov	x1, x25
    5fb8: b9401421     	ldr	w1, [x1, #0x14]
    5fbc: 6b01001f     	cmp	w0, w1
    5fc0: 54002542     	b.hs	0x6468 <___pl_fn_17+0xa60>
    5fc4: aa1a03e1     	mov	x1, x26
    5fc8: aa1903e0     	mov	x0, x25
    5fcc: 94000000     	bl	0x5fcc <___pl_fn_17+0x5c4>
    5fd0: aa1903e1     	mov	x1, x25
    5fd4: b9402c21     	ldr	w1, [x1, #0x2c]
    5fd8: 350025e1     	cbnz	w1, 0x6494 <___pl_fn_17+0xa8c>
    5fdc: aa1903e1     	mov	x1, x25
    5fe0: b9401021     	ldr	w1, [x1, #0x10]
    5fe4: 51000421     	sub	w1, w1, #0x1
    5fe8: aa1903e2     	mov	x2, x25
    5fec: b9001041     	str	w1, [x2, #0x10]
    5ff0: 910183ff     	add	sp, sp, #0x60
    5ff4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5ff8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5ffc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    6000: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    6004: f84107fc     	ldr	x28, [sp], #0x10
    6008: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    600c: d65f03c0     	ret
    6010: aa0003f9     	mov	x25, x0
    6014: aa0103fa     	mov	x26, x1
    6018: 52802d01     	mov	w1, #0x168              ; =360
    601c: 528000e3     	mov	w3, #0x7                ; =7
    6020: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6024: f9400084     	ldr	x4, [x4]
    6028: aa1a03e2     	mov	x2, x26
    602c: aa1903e0     	mov	x0, x25
    6030: d63f0080     	blr	x4
    6034: 35002300     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    6038: 52802d21     	mov	w1, #0x169              ; =361
    603c: 14000112     	b	0x6484 <___pl_fn_17+0xa7c>
    6040: 52802d41     	mov	w1, #0x16a              ; =362
    6044: 52800043     	mov	w3, #0x2                ; =2
    6048: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    604c: f9400084     	ldr	x4, [x4]
    6050: aa1903e0     	mov	x0, x25
    6054: d63f0080     	blr	x4
    6058: 350021e0     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    605c: 52802d61     	mov	w1, #0x16b              ; =363
    6060: 14000109     	b	0x6484 <___pl_fn_17+0xa7c>
    6064: 52802d81     	mov	w1, #0x16c              ; =364
    6068: 52800043     	mov	w3, #0x2                ; =2
    606c: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6070: f9400084     	ldr	x4, [x4]
    6074: aa1903e0     	mov	x0, x25
    6078: d63f0080     	blr	x4
    607c: 350020c0     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    6080: 52802da1     	mov	w1, #0x16d              ; =365
    6084: 14000100     	b	0x6484 <___pl_fn_17+0xa7c>
    6088: 52802dc1     	mov	w1, #0x16e              ; =366
    608c: 52800123     	mov	w3, #0x9                ; =9
    6090: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6094: f9400084     	ldr	x4, [x4]
    6098: aa1a03e2     	mov	x2, x26
    609c: aa1903e0     	mov	x0, x25
    60a0: d63f0080     	blr	x4
    60a4: 35001f80     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    60a8: 52802de1     	mov	w1, #0x16f              ; =367
    60ac: 140000f6     	b	0x6484 <___pl_fn_17+0xa7c>
    60b0: 52802e01     	mov	w1, #0x170              ; =368
    60b4: 528000e3     	mov	w3, #0x7                ; =7
    60b8: 90000009     	adrp	x9, 0x6000 <___pl_fn_17+0x5f8>
    60bc: f9400129     	ldr	x9, [x9]
    60c0: aa1a03e2     	mov	x2, x26
    60c4: aa1903e0     	mov	x0, x25
    60c8: d63f0120     	blr	x9
    60cc: 35001e40     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    60d0: 52802e21     	mov	w1, #0x171              ; =369
    60d4: 140000ec     	b	0x6484 <___pl_fn_17+0xa7c>
    60d8: 52802e41     	mov	w1, #0x172              ; =370
    60dc: 52800043     	mov	w3, #0x2                ; =2
    60e0: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    60e4: f9400084     	ldr	x4, [x4]
    60e8: aa1903e0     	mov	x0, x25
    60ec: d63f0080     	blr	x4
    60f0: 35001d20     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    60f4: 52802e61     	mov	w1, #0x173              ; =371
    60f8: 140000e3     	b	0x6484 <___pl_fn_17+0xa7c>
    60fc: d2800121     	mov	x1, #0x9                ; =9
    6100: 910003e3     	mov	x3, sp
    6104: f80003e1     	stur	x1, [sp]
    6108: 2a0003e0     	mov	w0, w0
    610c: f80083e0     	stur	x0, [sp, #0x8]
    6110: 52802ec1     	mov	w1, #0x176              ; =374
    6114: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6118: f9400084     	ldr	x4, [x4]
    611c: aa1a03e2     	mov	x2, x26
    6120: aa1903e0     	mov	x0, x25
    6124: d63f0080     	blr	x4
    6128: 35001b60     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    612c: 52802ee1     	mov	w1, #0x177              ; =375
    6130: 140000d5     	b	0x6484 <___pl_fn_17+0xa7c>
    6134: 52802ea1     	mov	w1, #0x175              ; =373
    6138: 140000d3     	b	0x6484 <___pl_fn_17+0xa7c>
    613c: 52802e81     	mov	w1, #0x174              ; =372
    6140: 140000d1     	b	0x6484 <___pl_fn_17+0xa7c>
    6144: 52802f01     	mov	w1, #0x178              ; =376
    6148: 52800103     	mov	w3, #0x8                ; =8
    614c: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6150: f9400084     	ldr	x4, [x4]
    6154: aa1a03e2     	mov	x2, x26
    6158: aa1903e0     	mov	x0, x25
    615c: d63f0080     	blr	x4
    6160: 350019a0     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    6164: 52802f21     	mov	w1, #0x179              ; =377
    6168: 140000c7     	b	0x6484 <___pl_fn_17+0xa7c>
    616c: 52802f41     	mov	w1, #0x17a              ; =378
    6170: 528000e3     	mov	w3, #0x7                ; =7
    6174: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6178: f9400084     	ldr	x4, [x4]
    617c: aa1a03e2     	mov	x2, x26
    6180: aa1903e0     	mov	x0, x25
    6184: d63f0080     	blr	x4
    6188: 35001860     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    618c: 52802f61     	mov	w1, #0x17b              ; =379
    6190: 140000bd     	b	0x6484 <___pl_fn_17+0xa7c>
    6194: 52802f81     	mov	w1, #0x17c              ; =380
    6198: 52800043     	mov	w3, #0x2                ; =2
    619c: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    61a0: f9400084     	ldr	x4, [x4]
    61a4: aa1903e0     	mov	x0, x25
    61a8: d63f0080     	blr	x4
    61ac: 35001740     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    61b0: 52802fa1     	mov	w1, #0x17d              ; =381
    61b4: 140000b4     	b	0x6484 <___pl_fn_17+0xa7c>
    61b8: d2800101     	mov	x1, #0x8                ; =8
    61bc: 910043e3     	add	x3, sp, #0x10
    61c0: f80103e1     	stur	x1, [sp, #0x10]
    61c4: 2a0003e0     	mov	w0, w0
    61c8: f80183e0     	stur	x0, [sp, #0x18]
    61cc: 52803001     	mov	w1, #0x180              ; =384
    61d0: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    61d4: f9400084     	ldr	x4, [x4]
    61d8: aa1a03e2     	mov	x2, x26
    61dc: aa1903e0     	mov	x0, x25
    61e0: d63f0080     	blr	x4
    61e4: 35001580     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    61e8: 52803021     	mov	w1, #0x181              ; =385
    61ec: 140000a6     	b	0x6484 <___pl_fn_17+0xa7c>
    61f0: 52803041     	mov	w1, #0x182              ; =386
    61f4: 52800103     	mov	w3, #0x8                ; =8
    61f8: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    61fc: f9400084     	ldr	x4, [x4]
    6200: aa1a03e2     	mov	x2, x26
    6204: aa1903e0     	mov	x0, x25
    6208: d63f0080     	blr	x4
    620c: 35001440     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    6210: 52803061     	mov	w1, #0x183              ; =387
    6214: 1400009c     	b	0x6484 <___pl_fn_17+0xa7c>
    6218: 528030a1     	mov	w1, #0x185              ; =389
    621c: 528000e3     	mov	w3, #0x7                ; =7
    6220: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6224: f9400084     	ldr	x4, [x4]
    6228: aa1a03e2     	mov	x2, x26
    622c: aa1903e0     	mov	x0, x25
    6230: d63f0080     	blr	x4
    6234: 35001300     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    6238: 528030c1     	mov	w1, #0x186              ; =390
    623c: 14000092     	b	0x6484 <___pl_fn_17+0xa7c>
    6240: 528030e1     	mov	w1, #0x187              ; =391
    6244: 52800043     	mov	w3, #0x2                ; =2
    6248: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    624c: f9400084     	ldr	x4, [x4]
    6250: aa1903e0     	mov	x0, x25
    6254: d63f0080     	blr	x4
    6258: 350011e0     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    625c: 52803101     	mov	w1, #0x188              ; =392
    6260: 14000089     	b	0x6484 <___pl_fn_17+0xa7c>
    6264: 52803121     	mov	w1, #0x189              ; =393
    6268: 52800063     	mov	w3, #0x3                ; =3
    626c: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6270: f9400084     	ldr	x4, [x4]
    6274: aa1703e2     	mov	x2, x23
    6278: aa1903e0     	mov	x0, x25
    627c: d63f0080     	blr	x4
    6280: 350010a0     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    6284: 52803141     	mov	w1, #0x18a              ; =394
    6288: 1400007f     	b	0x6484 <___pl_fn_17+0xa7c>
    628c: 52803161     	mov	w1, #0x18b              ; =395
    6290: 52800123     	mov	w3, #0x9                ; =9
    6294: 9000000f     	adrp	x15, 0x6000 <___pl_fn_17+0x5f8>
    6298: f94001ef     	ldr	x15, [x15]
    629c: aa1a03e2     	mov	x2, x26
    62a0: aa1903e0     	mov	x0, x25
    62a4: d63f01e0     	blr	x15
    62a8: 35000f60     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    62ac: 52803181     	mov	w1, #0x18c              ; =396
    62b0: 14000075     	b	0x6484 <___pl_fn_17+0xa7c>
    62b4: 528031c1     	mov	w1, #0x18e              ; =398
    62b8: 528000e3     	mov	w3, #0x7                ; =7
    62bc: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    62c0: f9400084     	ldr	x4, [x4]
    62c4: aa1a03e2     	mov	x2, x26
    62c8: aa1903e0     	mov	x0, x25
    62cc: d63f0080     	blr	x4
    62d0: 35000e20     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    62d4: 528031e1     	mov	w1, #0x18f              ; =399
    62d8: 1400006b     	b	0x6484 <___pl_fn_17+0xa7c>
    62dc: 52803201     	mov	w1, #0x190              ; =400
    62e0: 52800043     	mov	w3, #0x2                ; =2
    62e4: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    62e8: f9400084     	ldr	x4, [x4]
    62ec: aa1903e0     	mov	x0, x25
    62f0: d63f0080     	blr	x4
    62f4: 35000d00     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    62f8: 52803221     	mov	w1, #0x191              ; =401
    62fc: 14000062     	b	0x6484 <___pl_fn_17+0xa7c>
    6300: 52803241     	mov	w1, #0x192              ; =402
    6304: 52800003     	mov	w3, #0x0                ; =0
    6308: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    630c: f9400084     	ldr	x4, [x4]
    6310: aa1803e2     	mov	x2, x24
    6314: aa1903e0     	mov	x0, x25
    6318: d63f0080     	blr	x4
    631c: 35000bc0     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    6320: 52803261     	mov	w1, #0x193              ; =403
    6324: 14000058     	b	0x6484 <___pl_fn_17+0xa7c>
    6328: d2800121     	mov	x1, #0x9                ; =9
    632c: 910083e3     	add	x3, sp, #0x20
    6330: f80203e1     	stur	x1, [sp, #0x20]
    6334: 2a0003e0     	mov	w0, w0
    6338: f80283e0     	stur	x0, [sp, #0x28]
    633c: 52803281     	mov	w1, #0x194              ; =404
    6340: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6344: f9400084     	ldr	x4, [x4]
    6348: aa1a03e2     	mov	x2, x26
    634c: aa1903e0     	mov	x0, x25
    6350: d63f0080     	blr	x4
    6354: 35000a00     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    6358: 528032a1     	mov	w1, #0x195              ; =405
    635c: 1400004a     	b	0x6484 <___pl_fn_17+0xa7c>
    6360: d2800068     	mov	x8, #0x3                ; =3
    6364: 9100c3e3     	add	x3, sp, #0x30
    6368: f80303e8     	stur	x8, [sp, #0x30]
    636c: f80383e0     	stur	x0, [sp, #0x38]
    6370: 52803301     	mov	w1, #0x198              ; =408
    6374: 9000000a     	adrp	x10, 0x6000 <___pl_fn_17+0x5f8>
    6378: f940014a     	ldr	x10, [x10]
    637c: aa1903e0     	mov	x0, x25
    6380: d63f0140     	blr	x10
    6384: 35000880     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    6388: 52803321     	mov	w1, #0x199              ; =409
    638c: 1400003e     	b	0x6484 <___pl_fn_17+0xa7c>
    6390: d2800060     	mov	x0, #0x3                ; =3
    6394: 910103e3     	add	x3, sp, #0x40
    6398: f80403e0     	stur	x0, [sp, #0x40]
    639c: 91000680     	add	x0, x20, #0x1
    63a0: f80483e0     	stur	x0, [sp, #0x48]
    63a4: 52803361     	mov	w1, #0x19b              ; =411
    63a8: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    63ac: f9400084     	ldr	x4, [x4]
    63b0: aa1903e0     	mov	x0, x25
    63b4: d63f0080     	blr	x4
    63b8: 350006e0     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    63bc: 52803381     	mov	w1, #0x19c              ; =412
    63c0: 14000031     	b	0x6484 <___pl_fn_17+0xa7c>
    63c4: 528033c1     	mov	w1, #0x19e              ; =414
    63c8: 1400002f     	b	0x6484 <___pl_fn_17+0xa7c>
    63cc: 528033a1     	mov	w1, #0x19d              ; =413
    63d0: 1400002d     	b	0x6484 <___pl_fn_17+0xa7c>
    63d4: 52803341     	mov	w1, #0x19a              ; =410
    63d8: 1400002b     	b	0x6484 <___pl_fn_17+0xa7c>
    63dc: 528032e1     	mov	w1, #0x197              ; =407
    63e0: 14000029     	b	0x6484 <___pl_fn_17+0xa7c>
    63e4: 528032c1     	mov	w1, #0x196              ; =406
    63e8: 14000027     	b	0x6484 <___pl_fn_17+0xa7c>
    63ec: 528033e1     	mov	w1, #0x19f              ; =415
    63f0: 14000025     	b	0x6484 <___pl_fn_17+0xa7c>
    63f4: 528031a1     	mov	w1, #0x18d              ; =397
    63f8: 14000023     	b	0x6484 <___pl_fn_17+0xa7c>
    63fc: 52803401     	mov	w1, #0x1a0              ; =416
    6400: 52800003     	mov	w3, #0x0                ; =0
    6404: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6408: f9400084     	ldr	x4, [x4]
    640c: aa1903e0     	mov	x0, x25
    6410: d63f0080     	blr	x4
    6414: 35000400     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    6418: 52803421     	mov	w1, #0x1a1              ; =417
    641c: 1400001a     	b	0x6484 <___pl_fn_17+0xa7c>
    6420: d2800104     	mov	x4, #0x8                ; =8
    6424: 910143e3     	add	x3, sp, #0x50
    6428: f80503e4     	stur	x4, [sp, #0x50]
    642c: 2a0103e5     	mov	w5, w1
    6430: f80583e5     	stur	x5, [sp, #0x58]
    6434: 52803441     	mov	w1, #0x1a2              ; =418
    6438: 90000006     	adrp	x6, 0x6000 <___pl_fn_17+0x5f8>
    643c: f94000c6     	ldr	x6, [x6]
    6440: aa1a03e2     	mov	x2, x26
    6444: aa1903e0     	mov	x0, x25
    6448: d63f00c0     	blr	x6
    644c: 35000240     	cbnz	w0, 0x6494 <___pl_fn_17+0xa8c>
    6450: 52803461     	mov	w1, #0x1a3              ; =419
    6454: 1400000c     	b	0x6484 <___pl_fn_17+0xa7c>
    6458: 528034a1     	mov	w1, #0x1a5              ; =421
    645c: 1400000a     	b	0x6484 <___pl_fn_17+0xa7c>
    6460: 52803481     	mov	w1, #0x1a4              ; =420
    6464: 14000008     	b	0x6484 <___pl_fn_17+0xa7c>
    6468: 528034c1     	mov	w1, #0x1a6              ; =422
    646c: 14000006     	b	0x6484 <___pl_fn_17+0xa7c>
    6470: 52803081     	mov	w1, #0x184              ; =388
    6474: 14000004     	b	0x6484 <___pl_fn_17+0xa7c>
    6478: 52802fe1     	mov	w1, #0x17f              ; =383
    647c: 14000002     	b	0x6484 <___pl_fn_17+0xa7c>
    6480: 52802fc1     	mov	w1, #0x17e              ; =382
    6484: 90000002     	adrp	x2, 0x6000 <___pl_fn_17+0x5f8>
    6488: f9400042     	ldr	x2, [x2]
    648c: aa1903e0     	mov	x0, x25
    6490: d63f0040     	blr	x2
    6494: 52800000     	mov	w0, #0x0                ; =0
    6498: 910183ff     	add	sp, sp, #0x60
    649c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    64a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    64a4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    64a8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    64ac: f84107fc     	ldr	x28, [sp], #0x10
    64b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    64b4: d65f03c0     	ret

00000000000064b8 <___pl_fn_18>:
    64b8: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    64bc: 910003fd     	mov	x29, sp
    64c0: f81f0ff5     	str	x21, [sp, #-0x10]!
    64c4: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    64c8: d100c3ff     	sub	sp, sp, #0x30
    64cc: b9401004     	ldr	w4, [x0, #0x10]
    64d0: 11000482     	add	w2, w4, #0x1
    64d4: b9001002     	str	w2, [x0, #0x10]
    64d8: 34001101     	cbz	w1, 0x66f8 <___pl_fn_18+0x240>
    64dc: f9400002     	ldr	x2, [x0]
    64e0: aa0003f4     	mov	x20, x0
    64e4: 2a0103f3     	mov	w19, w1
    64e8: aa0103f5     	mov	x21, x1
    64ec: 8b130c41     	add	x1, x2, x19, lsl #3
    64f0: f9403022     	ldr	x2, [x1, #0x60]
    64f4: f9400820     	ldr	x0, [x1, #0x10]
    64f8: 37481040     	tbnz	w0, #0x9, 0x6700 <___pl_fn_18+0x248>
    64fc: b24107e0     	mov	x0, #-0x7fffffffffffffff ; =-9223372036854775807
    6500: eb00005f     	cmp	x2, x0
    6504: 54001c4b     	b.lt	0x688c <___pl_fn_18+0x3d4>
    6508: aa1503e0     	mov	x0, x21
    650c: 340010e0     	cbz	w0, 0x6728 <___pl_fn_18+0x270>
    6510: f9400825     	ldr	x5, [x1, #0x10]
    6514: 9276f8a5     	and	x5, x5, #0xfffffffffffffdff
    6518: f9000825     	str	x5, [x1, #0x10]
    651c: d1000447     	sub	x7, x2, #0x1
    6520: f9003027     	str	x7, [x1, #0x60]
    6524: aa1503e0     	mov	x0, x21
    6528: 340011c0     	cbz	w0, 0x6760 <___pl_fn_18+0x2a8>
    652c: f940082c     	ldr	x12, [x1, #0x10]
    6530: 3748118c     	tbnz	w12, #0x9, 0x6760 <___pl_fn_18+0x2a8>
    6534: f100045f     	cmp	x2, #0x1
    6538: 54000b60     	b.eq	0x66a4 <___pl_fn_18+0x1ec>
    653c: aa1503e2     	mov	x2, x21
    6540: 34001242     	cbz	w2, 0x6788 <___pl_fn_18+0x2d0>
    6544: f9402c23     	ldr	x3, [x1, #0x58]
    6548: f9400820     	ldr	x0, [x1, #0x10]
    654c: 374011e0     	tbnz	w0, #0x8, 0x6788 <___pl_fn_18+0x2d0>
    6550: d37ffc60     	lsr	x0, x3, #63
    6554: 8b000062     	add	x2, x3, x0
    6558: 927ff840     	and	x0, x2, #0xfffffffffffffffe
    655c: eb00007f     	cmp	x3, x0
    6560: 54000600     	b.eq	0x6620 <___pl_fn_18+0x168>
    6564: aa1503e0     	mov	x0, x21
    6568: 34001240     	cbz	w0, 0x67b0 <___pl_fn_18+0x2f8>
    656c: f9400820     	ldr	x0, [x1, #0x10]
    6570: 37401200     	tbnz	w0, #0x8, 0x67b0 <___pl_fn_18+0x2f8>
    6574: aa1403e0     	mov	x0, x20
    6578: b9401400     	ldr	w0, [x0, #0x14]
    657c: 11000481     	add	w1, w4, #0x1
    6580: 6b00003f     	cmp	w1, w0
    6584: 54001482     	b.hs	0x6814 <___pl_fn_18+0x35c>
    6588: 9341fc41     	asr	x1, x2, #1
    658c: d29a0102     	mov	x2, #0xd008             ; =53256
    6590: aa1403e0     	mov	x0, x20
    6594: 94000000     	bl	0x6594 <___pl_fn_18+0xdc>
    6598: aa1403e1     	mov	x1, x20
    659c: b9402c21     	ldr	w1, [x1, #0x2c]
    65a0: 35001801     	cbnz	w1, 0x68a0 <___pl_fn_18+0x3e8>
    65a4: aa1503e2     	mov	x2, x21
    65a8: 34001182     	cbz	w2, 0x67d8 <___pl_fn_18+0x320>
    65ac: aa1403e1     	mov	x1, x20
    65b0: f9400021     	ldr	x1, [x1]
    65b4: 8b130c22     	add	x2, x1, x19, lsl #3
    65b8: f9400843     	ldr	x3, [x2, #0x10]
    65bc: 9277f863     	and	x3, x3, #0xfffffffffffffeff
    65c0: f9000843     	str	x3, [x2, #0x10]
    65c4: 8b130c21     	add	x1, x1, x19, lsl #3
    65c8: f9002c20     	str	x0, [x1, #0x58]
    65cc: aa1403e0     	mov	x0, x20
    65d0: b9401001     	ldr	w1, [x0, #0x10]
    65d4: b9401402     	ldr	w2, [x0, #0x14]
    65d8: 6b02003f     	cmp	w1, w2
    65dc: 54001182     	b.hs	0x680c <___pl_fn_18+0x354>
    65e0: d28000c2     	mov	x2, #0x6                ; =6
    65e4: aa1503e1     	mov	x1, x21
    65e8: aa1403e0     	mov	x0, x20
    65ec: 94000000     	bl	0x65ec <___pl_fn_18+0x134>
    65f0: aa1403ef     	mov	x15, x20
    65f4: b9402de3     	ldr	w3, [x15, #0x2c]
    65f8: 35001543     	cbnz	w3, 0x68a0 <___pl_fn_18+0x3e8>
    65fc: aa1403e1     	mov	x1, x20
    6600: b9401025     	ldr	w5, [x1, #0x10]
    6604: 510004a5     	sub	w5, w5, #0x1
    6608: b9001025     	str	w5, [x1, #0x10]
    660c: 9100c3ff     	add	sp, sp, #0x30
    6610: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6614: f84107f5     	ldr	x21, [sp], #0x10
    6618: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    661c: d65f03c0     	ret
    6620: aa1503e0     	mov	x0, x21
    6624: 34000fc0     	cbz	w0, 0x681c <___pl_fn_18+0x364>
    6628: f940082c     	ldr	x12, [x1, #0x10]
    662c: 37400f8c     	tbnz	w12, #0x8, 0x681c <___pl_fn_18+0x364>
    6630: aa1503ea     	mov	x10, x21
    6634: 3400108a     	cbz	w10, 0x6844 <___pl_fn_18+0x38c>
    6638: f9400820     	ldr	x0, [x1, #0x10]
    663c: 9277f800     	and	x0, x0, #0xfffffffffffffeff
    6640: f9000820     	str	x0, [x1, #0x10]
    6644: 9341fc40     	asr	x0, x2, #1
    6648: f9002c20     	str	x0, [x1, #0x58]
    664c: aa1403e0     	mov	x0, x20
    6650: b9401400     	ldr	w0, [x0, #0x14]
    6654: 11000481     	add	w1, w4, #0x1
    6658: 6b00003f     	cmp	w1, w0
    665c: 54001102     	b.hs	0x687c <___pl_fn_18+0x3c4>
    6660: d28000a2     	mov	x2, #0x5                ; =5
    6664: aa1503e1     	mov	x1, x21
    6668: aa1403e0     	mov	x0, x20
    666c: 94000000     	bl	0x666c <___pl_fn_18+0x1b4>
    6670: aa1403ed     	mov	x13, x20
    6674: b9402da1     	ldr	w1, [x13, #0x2c]
    6678: 35001141     	cbnz	w1, 0x68a0 <___pl_fn_18+0x3e8>
    667c: aa1403e1     	mov	x1, x20
    6680: b9401021     	ldr	w1, [x1, #0x10]
    6684: 51000421     	sub	w1, w1, #0x1
    6688: aa1403e2     	mov	x2, x20
    668c: b9001041     	str	w1, [x2, #0x10]
    6690: 9100c3ff     	add	sp, sp, #0x30
    6694: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6698: f84107f5     	ldr	x21, [sp], #0x10
    669c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    66a0: d65f03c0     	ret
    66a4: aa1403e0     	mov	x0, x20
    66a8: b9401400     	ldr	w0, [x0, #0x14]
    66ac: 11000481     	add	w1, w4, #0x1
    66b0: 6b00003f     	cmp	w1, w0
    66b4: 54000e82     	b.hs	0x6884 <___pl_fn_18+0x3cc>
    66b8: aa1503e1     	mov	x1, x21
    66bc: aa1403e0     	mov	x0, x20
    66c0: 94000000     	bl	0x66c0 <___pl_fn_18+0x208>
    66c4: aa1403e1     	mov	x1, x20
    66c8: b9402c21     	ldr	w1, [x1, #0x2c]
    66cc: 35000ea1     	cbnz	w1, 0x68a0 <___pl_fn_18+0x3e8>
    66d0: aa1403e1     	mov	x1, x20
    66d4: b9401021     	ldr	w1, [x1, #0x10]
    66d8: 51000421     	sub	w1, w1, #0x1
    66dc: aa1403e2     	mov	x2, x20
    66e0: b9001041     	str	w1, [x2, #0x10]
    66e4: 9100c3ff     	add	sp, sp, #0x30
    66e8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    66ec: f84107f5     	ldr	x21, [sp], #0x10
    66f0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    66f4: d65f03c0     	ret
    66f8: aa0003f4     	mov	x20, x0
    66fc: aa0103f5     	mov	x21, x1
    6700: 528034e1     	mov	w1, #0x1a7              ; =423
    6704: 52800123     	mov	w3, #0x9                ; =9
    6708: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    670c: f9400084     	ldr	x4, [x4]
    6710: aa1503e2     	mov	x2, x21
    6714: aa1403e0     	mov	x0, x20
    6718: d63f0080     	blr	x4
    671c: 35000c20     	cbnz	w0, 0x68a0 <___pl_fn_18+0x3e8>
    6720: 52803501     	mov	w1, #0x1a8              ; =424
    6724: 1400005b     	b	0x6890 <___pl_fn_18+0x3d8>
    6728: d2800120     	mov	x0, #0x9                ; =9
    672c: 910003e3     	mov	x3, sp
    6730: f80003e0     	stur	x0, [sp]
    6734: d1000440     	sub	x0, x2, #0x1
    6738: f80083e0     	stur	x0, [sp, #0x8]
    673c: 52803541     	mov	w1, #0x1aa              ; =426
    6740: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6744: f9400084     	ldr	x4, [x4]
    6748: aa1503e2     	mov	x2, x21
    674c: aa1403e0     	mov	x0, x20
    6750: d63f0080     	blr	x4
    6754: 35000a60     	cbnz	w0, 0x68a0 <___pl_fn_18+0x3e8>
    6758: 52803561     	mov	w1, #0x1ab              ; =427
    675c: 1400004d     	b	0x6890 <___pl_fn_18+0x3d8>
    6760: 52803581     	mov	w1, #0x1ac              ; =428
    6764: 52800123     	mov	w3, #0x9                ; =9
    6768: 9000000e     	adrp	x14, 0x6000 <___pl_fn_17+0x5f8>
    676c: f94001ce     	ldr	x14, [x14]
    6770: aa1503e2     	mov	x2, x21
    6774: aa1403e0     	mov	x0, x20
    6778: d63f01c0     	blr	x14
    677c: 35000920     	cbnz	w0, 0x68a0 <___pl_fn_18+0x3e8>
    6780: 528035a1     	mov	w1, #0x1ad              ; =429
    6784: 14000043     	b	0x6890 <___pl_fn_18+0x3d8>
    6788: 528035c1     	mov	w1, #0x1ae              ; =430
    678c: 52800103     	mov	w3, #0x8                ; =8
    6790: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6794: f9400084     	ldr	x4, [x4]
    6798: aa1503e2     	mov	x2, x21
    679c: aa1403e0     	mov	x0, x20
    67a0: d63f0080     	blr	x4
    67a4: 350007e0     	cbnz	w0, 0x68a0 <___pl_fn_18+0x3e8>
    67a8: 528035e1     	mov	w1, #0x1af              ; =431
    67ac: 14000039     	b	0x6890 <___pl_fn_18+0x3d8>
    67b0: 52803621     	mov	w1, #0x1b1              ; =433
    67b4: 52800103     	mov	w3, #0x8                ; =8
    67b8: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    67bc: f9400084     	ldr	x4, [x4]
    67c0: aa1503e2     	mov	x2, x21
    67c4: aa1403e0     	mov	x0, x20
    67c8: d63f0080     	blr	x4
    67cc: 350006a0     	cbnz	w0, 0x68a0 <___pl_fn_18+0x3e8>
    67d0: 52803641     	mov	w1, #0x1b2              ; =434
    67d4: 1400002f     	b	0x6890 <___pl_fn_18+0x3d8>
    67d8: d2800101     	mov	x1, #0x8                ; =8
    67dc: 910043e3     	add	x3, sp, #0x10
    67e0: f80103e1     	stur	x1, [sp, #0x10]
    67e4: f80183e0     	stur	x0, [sp, #0x18]
    67e8: 528036c1     	mov	w1, #0x1b6              ; =438
    67ec: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    67f0: f9400084     	ldr	x4, [x4]
    67f4: aa1503e2     	mov	x2, x21
    67f8: aa1403e0     	mov	x0, x20
    67fc: d63f0080     	blr	x4
    6800: 35000500     	cbnz	w0, 0x68a0 <___pl_fn_18+0x3e8>
    6804: 528036e1     	mov	w1, #0x1b7              ; =439
    6808: 14000022     	b	0x6890 <___pl_fn_18+0x3d8>
    680c: 52803701     	mov	w1, #0x1b8              ; =440
    6810: 14000020     	b	0x6890 <___pl_fn_18+0x3d8>
    6814: 528036a1     	mov	w1, #0x1b5              ; =437
    6818: 1400001e     	b	0x6890 <___pl_fn_18+0x3d8>
    681c: 52803721     	mov	w1, #0x1b9              ; =441
    6820: 52800103     	mov	w3, #0x8                ; =8
    6824: 9000000e     	adrp	x14, 0x6000 <___pl_fn_17+0x5f8>
    6828: f94001ce     	ldr	x14, [x14]
    682c: aa1503e2     	mov	x2, x21
    6830: aa1403e0     	mov	x0, x20
    6834: d63f01c0     	blr	x14
    6838: 35000340     	cbnz	w0, 0x68a0 <___pl_fn_18+0x3e8>
    683c: 52803741     	mov	w1, #0x1ba              ; =442
    6840: 14000014     	b	0x6890 <___pl_fn_18+0x3d8>
    6844: d2800100     	mov	x0, #0x8                ; =8
    6848: 910083e3     	add	x3, sp, #0x20
    684c: f80203e0     	stur	x0, [sp, #0x20]
    6850: 9341fc40     	asr	x0, x2, #1
    6854: f80283e0     	stur	x0, [sp, #0x28]
    6858: 528037a1     	mov	w1, #0x1bd              ; =445
    685c: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6860: f9400084     	ldr	x4, [x4]
    6864: aa1503e2     	mov	x2, x21
    6868: aa1403e0     	mov	x0, x20
    686c: d63f0080     	blr	x4
    6870: 35000180     	cbnz	w0, 0x68a0 <___pl_fn_18+0x3e8>
    6874: 528037c1     	mov	w1, #0x1be              ; =446
    6878: 14000006     	b	0x6890 <___pl_fn_18+0x3d8>
    687c: 528037e1     	mov	w1, #0x1bf              ; =447
    6880: 14000004     	b	0x6890 <___pl_fn_18+0x3d8>
    6884: 52803801     	mov	w1, #0x1c0              ; =448
    6888: 14000002     	b	0x6890 <___pl_fn_18+0x3d8>
    688c: 52803521     	mov	w1, #0x1a9              ; =425
    6890: 90000002     	adrp	x2, 0x6000 <___pl_fn_17+0x5f8>
    6894: f9400042     	ldr	x2, [x2]
    6898: aa1403e0     	mov	x0, x20
    689c: d63f0040     	blr	x2
    68a0: 52800000     	mov	w0, #0x0                ; =0
    68a4: 9100c3ff     	add	sp, sp, #0x30
    68a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    68ac: f84107f5     	ldr	x21, [sp], #0x10
    68b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    68b4: d65f03c0     	ret

00000000000068b8 <___pl_fn_19>:
    68b8: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
    68bc: 910003fd     	mov	x29, sp
    68c0: f81f0ff7     	str	x23, [sp, #-0x10]!
    68c4: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
    68c8: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
    68cc: d10183ff     	sub	sp, sp, #0x60
    68d0: aa0203f7     	mov	x23, x2
    68d4: b9401003     	ldr	w3, [x0, #0x10]
    68d8: 11000462     	add	w2, w3, #0x1
    68dc: b9001002     	str	w2, [x0, #0x10]
    68e0: 340018e1     	cbz	w1, 0x6bfc <___pl_fn_19+0x344>
    68e4: f9400004     	ldr	x4, [x0]
    68e8: aa0003f5     	mov	x21, x0
    68ec: 2a0103f3     	mov	w19, w1
    68f0: aa0103f6     	mov	x22, x1
    68f4: 8b130c81     	add	x1, x4, x19, lsl #3
    68f8: b9405022     	ldr	w2, [x1, #0x50]
    68fc: 34001842     	cbz	w2, 0x6c04 <___pl_fn_19+0x34c>
    6900: 34001962     	cbz	w2, 0x6c2c <___pl_fn_19+0x374>
    6904: 2a0203e0     	mov	w0, w2
    6908: 8b000c80     	add	x0, x4, x0, lsl #3
    690c: b9402800     	ldr	w0, [x0, #0x28]
    6910: 340018e0     	cbz	w0, 0x6c2c <___pl_fn_19+0x374>
    6914: aa1703e2     	mov	x2, x23
    6918: 6b00005f     	cmp	w2, w0
    691c: 54001440     	b.eq	0x6ba4 <___pl_fn_19+0x2ec>
    6920: aa1603e2     	mov	x2, x22
    6924: 34001962     	cbz	w2, 0x6c50 <___pl_fn_19+0x398>
    6928: f9402c27     	ldr	x7, [x1, #0x58]
    692c: f9400828     	ldr	x8, [x1, #0x10]
    6930: 37401908     	tbnz	w8, #0x8, 0x6c50 <___pl_fn_19+0x398>
    6934: f1000cff     	cmp	x7, #0x3
    6938: 54000140     	b.eq	0x6960 <___pl_fn_19+0xa8>
    693c: aa1603e2     	mov	x2, x22
    6940: 340019c2     	cbz	w2, 0x6c78 <___pl_fn_19+0x3c0>
    6944: f9400820     	ldr	x0, [x1, #0x10]
    6948: 9277f800     	and	x0, x0, #0xfffffffffffffeff
    694c: f9000820     	str	x0, [x1, #0x10]
    6950: d2800060     	mov	x0, #0x3                ; =3
    6954: f9002c20     	str	x0, [x1, #0x58]
    6958: aa1603e2     	mov	x2, x22
    695c: 14000009     	b	0x6980 <___pl_fn_19+0xc8>
    6960: aa1603e2     	mov	x2, x22
    6964: 34001a62     	cbz	w2, 0x6cb0 <___pl_fn_19+0x3f8>
    6968: f9400820     	ldr	x0, [x1, #0x10]
    696c: 9277f800     	and	x0, x0, #0xfffffffffffffeff
    6970: f9000820     	str	x0, [x1, #0x10]
    6974: d2800080     	mov	x0, #0x4                ; =4
    6978: f9002c20     	str	x0, [x1, #0x58]
    697c: aa1603e2     	mov	x2, x22
    6980: aa1603e2     	mov	x2, x22
    6984: 34001b22     	cbz	w2, 0x6ce8 <___pl_fn_19+0x430>
    6988: f9402c22     	ldr	x2, [x1, #0x58]
    698c: f9400820     	ldr	x0, [x1, #0x10]
    6990: 37401ac0     	tbnz	w0, #0x8, 0x6ce8 <___pl_fn_19+0x430>
    6994: aa1703e0     	mov	x0, x23
    6998: 34001bc0     	cbz	w0, 0x6d10 <___pl_fn_19+0x458>
    699c: aa1703e0     	mov	x0, x23
    69a0: 2a0003e0     	mov	w0, w0
    69a4: 8b000c80     	add	x0, x4, x0, lsl #3
    69a8: f9400801     	ldr	x1, [x0, #0x10]
    69ac: 927ef821     	and	x1, x1, #0xfffffffffffffffd
    69b0: f9000801     	str	x1, [x0, #0x10]
    69b4: aa1703e0     	mov	x0, x23
    69b8: 2a0003e0     	mov	w0, w0
    69bc: 8b000c80     	add	x0, x4, x0, lsl #3
    69c0: f9001002     	str	x2, [x0, #0x20]
    69c4: aa1703e2     	mov	x2, x23
    69c8: 34001be2     	cbz	w2, 0x6d44 <___pl_fn_19+0x48c>
    69cc: f940080a     	ldr	x10, [x0, #0x10]
    69d0: 927cf94a     	and	x10, x10, #0xfffffffffffffff7
    69d4: f900080a     	str	x10, [x0, #0x10]
    69d8: d2800014     	mov	x20, #0x0               ; =0
    69dc: f9001814     	str	x20, [x0, #0x30]
    69e0: 52800020     	mov	w0, #0x1                ; =1
    69e4: f1000e9f     	cmp	x20, #0x3
    69e8: 9a9fc7e1     	cset	x1, le
    69ec: 72001c3f     	tst	w1, #0xff
    69f0: 54000321     	b.ne	0x6a54 <___pl_fn_19+0x19c>
    69f4: aa1503e0     	mov	x0, x21
    69f8: b9401000     	ldr	w0, [x0, #0x10]
    69fc: aa1503e1     	mov	x1, x21
    6a00: b9401421     	ldr	w1, [x1, #0x14]
    6a04: 6b01001f     	cmp	w0, w1
    6a08: 54001ba2     	b.hs	0x6d7c <___pl_fn_19+0x4c4>
    6a0c: aa1603e1     	mov	x1, x22
    6a10: aa1703e2     	mov	x2, x23
    6a14: aa1503e0     	mov	x0, x21
    6a18: 94000000     	bl	0x6a18 <___pl_fn_19+0x160>
    6a1c: aa1503e1     	mov	x1, x21
    6a20: b9402c21     	ldr	w1, [x1, #0x2c]
    6a24: 35002441     	cbnz	w1, 0x6eac <___pl_fn_19+0x5f4>
    6a28: aa1503e1     	mov	x1, x21
    6a2c: b9401021     	ldr	w1, [x1, #0x10]
    6a30: 51000421     	sub	w1, w1, #0x1
    6a34: aa1503e2     	mov	x2, x21
    6a38: b9001041     	str	w1, [x2, #0x10]
    6a3c: 910183ff     	add	sp, sp, #0x60
    6a40: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6a44: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6a48: f84107f7     	ldr	x23, [sp], #0x10
    6a4c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6a50: d65f03c0     	ret
    6a54: aa1603e2     	mov	x2, x22
    6a58: 34001962     	cbz	w2, 0x6d84 <___pl_fn_19+0x4cc>
    6a5c: aa1503e1     	mov	x1, x21
    6a60: f9400021     	ldr	x1, [x1]
    6a64: 8b130c21     	add	x1, x1, x19, lsl #3
    6a68: f9403022     	ldr	x2, [x1, #0x60]
    6a6c: f9400821     	ldr	x1, [x1, #0x10]
    6a70: 374818a1     	tbnz	w1, #0x9, 0x6d84 <___pl_fn_19+0x4cc>
    6a74: b27ff7e1     	mov	x1, #0x7ffffffffffffffe ; =9223372036854775806
    6a78: eb01005f     	cmp	x2, x1
    6a7c: 540020ac     	b.gt	0x6e90 <___pl_fn_19+0x5d8>
    6a80: aa1603e1     	mov	x1, x22
    6a84: 34001941     	cbz	w1, 0x6dac <___pl_fn_19+0x4f4>
    6a88: aa1503e1     	mov	x1, x21
    6a8c: f9400023     	ldr	x3, [x1]
    6a90: 8b130c61     	add	x1, x3, x19, lsl #3
    6a94: f9400824     	ldr	x4, [x1, #0x10]
    6a98: 9276f884     	and	x4, x4, #0xfffffffffffffdff
    6a9c: f9000824     	str	x4, [x1, #0x10]
    6aa0: d2800021     	mov	x1, #0x1                ; =1
    6aa4: 91000442     	add	x2, x2, #0x1
    6aa8: 8b130c63     	add	x3, x3, x19, lsl #3
    6aac: f9003062     	str	x2, [x3, #0x60]
    6ab0: aa1603e2     	mov	x2, x22
    6ab4: 34001982     	cbz	w2, 0x6de4 <___pl_fn_19+0x52c>
    6ab8: aa1503e2     	mov	x2, x21
    6abc: f9400042     	ldr	x2, [x2]
    6ac0: 8b130c43     	add	x3, x2, x19, lsl #3
    6ac4: f9403062     	ldr	x2, [x3, #0x60]
    6ac8: f9400863     	ldr	x3, [x3, #0x10]
    6acc: 374818c3     	tbnz	w3, #0x9, 0x6de4 <___pl_fn_19+0x52c>
    6ad0: f100685f     	cmp	x2, #0x1a
    6ad4: 5400006c     	b.gt	0x6ae0 <___pl_fn_19+0x228>
    6ad8: aa1603e2     	mov	x2, x22
    6adc: 1400000c     	b	0x6b0c <___pl_fn_19+0x254>
    6ae0: aa1603e2     	mov	x2, x22
    6ae4: 34001942     	cbz	w2, 0x6e0c <___pl_fn_19+0x554>
    6ae8: aa1503e2     	mov	x2, x21
    6aec: f9400049     	ldr	x9, [x2]
    6af0: 8b130d2a     	add	x10, x9, x19, lsl #3
    6af4: f940094b     	ldr	x11, [x10, #0x10]
    6af8: 9276f96b     	and	x11, x11, #0xfffffffffffffdff
    6afc: f900094b     	str	x11, [x10, #0x10]
    6b00: 8b130d2c     	add	x12, x9, x19, lsl #3
    6b04: f9003181     	str	x1, [x12, #0x60]
    6b08: aa1603e2     	mov	x2, x22
    6b0c: aa1603e2     	mov	x2, x22
    6b10: 34001982     	cbz	w2, 0x6e40 <___pl_fn_19+0x588>
    6b14: aa1503e1     	mov	x1, x21
    6b18: f9400021     	ldr	x1, [x1]
    6b1c: 8b130c22     	add	x2, x1, x19, lsl #3
    6b20: f9403041     	ldr	x1, [x2, #0x60]
    6b24: f9400842     	ldr	x2, [x2, #0x10]
    6b28: 374818c2     	tbnz	w2, #0x9, 0x6e40 <___pl_fn_19+0x588>
    6b2c: 92800822     	mov	x2, #-0x42              ; =-66
    6b30: f2efffe2     	movk	x2, #0x7fff, lsl #48
    6b34: eb02003f     	cmp	x1, x2
    6b38: 54001a8c     	b.gt	0x6e88 <___pl_fn_19+0x5d0>
    6b3c: 91010422     	add	x2, x1, #0x41
    6b40: b24107e3     	mov	x3, #-0x7fffffffffffffff ; =-9223372036854775807
    6b44: eb03005f     	cmp	x2, x3
    6b48: 540019cb     	b.lt	0x6e80 <___pl_fn_19+0x5c8>
    6b4c: aa1503e2     	mov	x2, x21
    6b50: b9401042     	ldr	w2, [x2, #0x10]
    6b54: aa1503e3     	mov	x3, x21
    6b58: b9401463     	ldr	w3, [x3, #0x14]
    6b5c: 6b03005f     	cmp	w2, w3
    6b60: 540018c2     	b.hs	0x6e78 <___pl_fn_19+0x5c0>
    6b64: 72001c1f     	tst	w0, #0xff
    6b68: 54001840     	b.eq	0x6e70 <___pl_fn_19+0x5b8>
    6b6c: 91010023     	add	x3, x1, #0x40
    6b70: aa1503e0     	mov	x0, x21
    6b74: aa1703e1     	mov	x1, x23
    6b78: aa1403e2     	mov	x2, x20
    6b7c: 94000000     	bl	0x6b7c <___pl_fn_19+0x2c4>
    6b80: aa1503e0     	mov	x0, x21
    6b84: b9402c00     	ldr	w0, [x0, #0x2c]
    6b88: 35001920     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6b8c: b27ff7e0     	mov	x0, #0x7ffffffffffffffe ; =9223372036854775806
    6b90: eb00029f     	cmp	x20, x0
    6b94: 540016ac     	b.gt	0x6e68 <___pl_fn_19+0x5b0>
    6b98: 91000694     	add	x20, x20, #0x1
    6b9c: 52800020     	mov	w0, #0x1                ; =1
    6ba0: 17ffff91     	b	0x69e4 <___pl_fn_19+0x12c>
    6ba4: aa1503e0     	mov	x0, x21
    6ba8: b9401400     	ldr	w0, [x0, #0x14]
    6bac: 11000461     	add	w1, w3, #0x1
    6bb0: 6b00003f     	cmp	w1, w0
    6bb4: 54001722     	b.hs	0x6e98 <___pl_fn_19+0x5e0>
    6bb8: aa1603e1     	mov	x1, x22
    6bbc: aa1503e0     	mov	x0, x21
    6bc0: 94000000     	bl	0x6bc0 <___pl_fn_19+0x308>
    6bc4: aa1503e1     	mov	x1, x21
    6bc8: b9402c21     	ldr	w1, [x1, #0x2c]
    6bcc: 35001701     	cbnz	w1, 0x6eac <___pl_fn_19+0x5f4>
    6bd0: aa1503e1     	mov	x1, x21
    6bd4: b9401021     	ldr	w1, [x1, #0x10]
    6bd8: 51000421     	sub	w1, w1, #0x1
    6bdc: aa1503e2     	mov	x2, x21
    6be0: b9001041     	str	w1, [x2, #0x10]
    6be4: 910183ff     	add	sp, sp, #0x60
    6be8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6bec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6bf0: f84107f7     	ldr	x23, [sp], #0x10
    6bf4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6bf8: d65f03c0     	ret
    6bfc: aa0003f5     	mov	x21, x0
    6c00: aa0103f6     	mov	x22, x1
    6c04: 52803821     	mov	w1, #0x1c1              ; =449
    6c08: 528000e3     	mov	w3, #0x7                ; =7
    6c0c: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6c10: f9400084     	ldr	x4, [x4]
    6c14: aa1603e2     	mov	x2, x22
    6c18: aa1503e0     	mov	x0, x21
    6c1c: d63f0080     	blr	x4
    6c20: 35001460     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6c24: 52803841     	mov	w1, #0x1c2              ; =450
    6c28: 1400009d     	b	0x6e9c <___pl_fn_19+0x5e4>
    6c2c: 52803861     	mov	w1, #0x1c3              ; =451
    6c30: 52800043     	mov	w3, #0x2                ; =2
    6c34: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6c38: f9400084     	ldr	x4, [x4]
    6c3c: aa1503e0     	mov	x0, x21
    6c40: d63f0080     	blr	x4
    6c44: 35001340     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6c48: 52803881     	mov	w1, #0x1c4              ; =452
    6c4c: 14000094     	b	0x6e9c <___pl_fn_19+0x5e4>
    6c50: 528038a1     	mov	w1, #0x1c5              ; =453
    6c54: 52800103     	mov	w3, #0x8                ; =8
    6c58: 9000000a     	adrp	x10, 0x6000 <___pl_fn_17+0x5f8>
    6c5c: f940014a     	ldr	x10, [x10]
    6c60: aa1603e2     	mov	x2, x22
    6c64: aa1503e0     	mov	x0, x21
    6c68: d63f0140     	blr	x10
    6c6c: 35001200     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6c70: 528038c1     	mov	w1, #0x1c6              ; =454
    6c74: 1400008a     	b	0x6e9c <___pl_fn_19+0x5e4>
    6c78: d2800100     	mov	x0, #0x8                ; =8
    6c7c: 910003e3     	mov	x3, sp
    6c80: f80003e0     	stur	x0, [sp]
    6c84: d2800060     	mov	x0, #0x3                ; =3
    6c88: f80083e0     	stur	x0, [sp, #0x8]
    6c8c: 528038e1     	mov	w1, #0x1c7              ; =455
    6c90: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6c94: f9400084     	ldr	x4, [x4]
    6c98: aa1603e2     	mov	x2, x22
    6c9c: aa1503e0     	mov	x0, x21
    6ca0: d63f0080     	blr	x4
    6ca4: 35001040     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6ca8: 52803901     	mov	w1, #0x1c8              ; =456
    6cac: 1400007c     	b	0x6e9c <___pl_fn_19+0x5e4>
    6cb0: d2800100     	mov	x0, #0x8                ; =8
    6cb4: 910043e3     	add	x3, sp, #0x10
    6cb8: f80103e0     	stur	x0, [sp, #0x10]
    6cbc: d2800080     	mov	x0, #0x4                ; =4
    6cc0: f80183e0     	stur	x0, [sp, #0x18]
    6cc4: 52803921     	mov	w1, #0x1c9              ; =457
    6cc8: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6ccc: f9400084     	ldr	x4, [x4]
    6cd0: aa1603e2     	mov	x2, x22
    6cd4: aa1503e0     	mov	x0, x21
    6cd8: d63f0080     	blr	x4
    6cdc: 35000e80     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6ce0: 52803941     	mov	w1, #0x1ca              ; =458
    6ce4: 1400006e     	b	0x6e9c <___pl_fn_19+0x5e4>
    6ce8: 52803961     	mov	w1, #0x1cb              ; =459
    6cec: 52800103     	mov	w3, #0x8                ; =8
    6cf0: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6cf4: f9400084     	ldr	x4, [x4]
    6cf8: aa1603e2     	mov	x2, x22
    6cfc: aa1503e0     	mov	x0, x21
    6d00: d63f0080     	blr	x4
    6d04: 35000d40     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6d08: 52803981     	mov	w1, #0x1cc              ; =460
    6d0c: 14000064     	b	0x6e9c <___pl_fn_19+0x5e4>
    6d10: d2800020     	mov	x0, #0x1                ; =1
    6d14: 910083e3     	add	x3, sp, #0x20
    6d18: f80203e0     	stur	x0, [sp, #0x20]
    6d1c: f80283e2     	stur	x2, [sp, #0x28]
    6d20: 528039a1     	mov	w1, #0x1cd              ; =461
    6d24: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6d28: f9400084     	ldr	x4, [x4]
    6d2c: aa1703e2     	mov	x2, x23
    6d30: aa1503e0     	mov	x0, x21
    6d34: d63f0080     	blr	x4
    6d38: 35000ba0     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6d3c: 528039c1     	mov	w1, #0x1ce              ; =462
    6d40: 14000057     	b	0x6e9c <___pl_fn_19+0x5e4>
    6d44: d2800064     	mov	x4, #0x3                ; =3
    6d48: 9100c3e3     	add	x3, sp, #0x30
    6d4c: f80303e4     	stur	x4, [sp, #0x30]
    6d50: d2800004     	mov	x4, #0x0                ; =0
    6d54: f80383e4     	stur	x4, [sp, #0x38]
    6d58: 528039e1     	mov	w1, #0x1cf              ; =463
    6d5c: 90000005     	adrp	x5, 0x6000 <___pl_fn_17+0x5f8>
    6d60: f94000a5     	ldr	x5, [x5]
    6d64: aa1703e2     	mov	x2, x23
    6d68: aa1503e0     	mov	x0, x21
    6d6c: d63f00a0     	blr	x5
    6d70: 350009e0     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6d74: 52803a01     	mov	w1, #0x1d0              ; =464
    6d78: 14000049     	b	0x6e9c <___pl_fn_19+0x5e4>
    6d7c: 52803a41     	mov	w1, #0x1d2              ; =466
    6d80: 14000047     	b	0x6e9c <___pl_fn_19+0x5e4>
    6d84: 52803a61     	mov	w1, #0x1d3              ; =467
    6d88: 52800123     	mov	w3, #0x9                ; =9
    6d8c: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6d90: f9400084     	ldr	x4, [x4]
    6d94: aa1603e2     	mov	x2, x22
    6d98: aa1503e0     	mov	x0, x21
    6d9c: d63f0080     	blr	x4
    6da0: 35000860     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6da4: 52803a81     	mov	w1, #0x1d4              ; =468
    6da8: 1400003d     	b	0x6e9c <___pl_fn_19+0x5e4>
    6dac: d2800120     	mov	x0, #0x9                ; =9
    6db0: 910103e3     	add	x3, sp, #0x40
    6db4: f80403e0     	stur	x0, [sp, #0x40]
    6db8: 91000440     	add	x0, x2, #0x1
    6dbc: f80483e0     	stur	x0, [sp, #0x48]
    6dc0: 52803ac1     	mov	w1, #0x1d6              ; =470
    6dc4: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6dc8: f9400084     	ldr	x4, [x4]
    6dcc: aa1603e2     	mov	x2, x22
    6dd0: aa1503e0     	mov	x0, x21
    6dd4: d63f0080     	blr	x4
    6dd8: 350006a0     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6ddc: 52803ae1     	mov	w1, #0x1d7              ; =471
    6de0: 1400002f     	b	0x6e9c <___pl_fn_19+0x5e4>
    6de4: 52803b01     	mov	w1, #0x1d8              ; =472
    6de8: 52800123     	mov	w3, #0x9                ; =9
    6dec: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6df0: f9400084     	ldr	x4, [x4]
    6df4: aa1603e2     	mov	x2, x22
    6df8: aa1503e0     	mov	x0, x21
    6dfc: d63f0080     	blr	x4
    6e00: 35000560     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6e04: 52803b21     	mov	w1, #0x1d9              ; =473
    6e08: 14000025     	b	0x6e9c <___pl_fn_19+0x5e4>
    6e0c: d2800124     	mov	x4, #0x9                ; =9
    6e10: 910143e3     	add	x3, sp, #0x50
    6e14: f80503e4     	stur	x4, [sp, #0x50]
    6e18: f80583e1     	stur	x1, [sp, #0x58]
    6e1c: 52803b41     	mov	w1, #0x1da              ; =474
    6e20: 90000005     	adrp	x5, 0x6000 <___pl_fn_17+0x5f8>
    6e24: f94000a5     	ldr	x5, [x5]
    6e28: aa1603e2     	mov	x2, x22
    6e2c: aa1503e0     	mov	x0, x21
    6e30: d63f00a0     	blr	x5
    6e34: 350003c0     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6e38: 52803b61     	mov	w1, #0x1db              ; =475
    6e3c: 14000018     	b	0x6e9c <___pl_fn_19+0x5e4>
    6e40: 52803b81     	mov	w1, #0x1dc              ; =476
    6e44: 52800123     	mov	w3, #0x9                ; =9
    6e48: 90000004     	adrp	x4, 0x6000 <___pl_fn_17+0x5f8>
    6e4c: f9400084     	ldr	x4, [x4]
    6e50: aa1603e2     	mov	x2, x22
    6e54: aa1503e0     	mov	x0, x21
    6e58: d63f0080     	blr	x4
    6e5c: 35000280     	cbnz	w0, 0x6eac <___pl_fn_19+0x5f4>
    6e60: 52803ba1     	mov	w1, #0x1dd              ; =477
    6e64: 1400000e     	b	0x6e9c <___pl_fn_19+0x5e4>
    6e68: 52803c41     	mov	w1, #0x1e2              ; =482
    6e6c: 1400000c     	b	0x6e9c <___pl_fn_19+0x5e4>
    6e70: 52803c21     	mov	w1, #0x1e1              ; =481
    6e74: 1400000a     	b	0x6e9c <___pl_fn_19+0x5e4>
    6e78: 52803c01     	mov	w1, #0x1e0              ; =480
    6e7c: 14000008     	b	0x6e9c <___pl_fn_19+0x5e4>
    6e80: 52803be1     	mov	w1, #0x1df              ; =479
    6e84: 14000006     	b	0x6e9c <___pl_fn_19+0x5e4>
    6e88: 52803bc1     	mov	w1, #0x1de              ; =478
    6e8c: 14000004     	b	0x6e9c <___pl_fn_19+0x5e4>
    6e90: 52803aa1     	mov	w1, #0x1d5              ; =469
    6e94: 14000002     	b	0x6e9c <___pl_fn_19+0x5e4>
    6e98: 52803c61     	mov	w1, #0x1e3              ; =483
    6e9c: 90000002     	adrp	x2, 0x6000 <___pl_fn_17+0x5f8>
    6ea0: f9400042     	ldr	x2, [x2]
    6ea4: aa1503e0     	mov	x0, x21
    6ea8: d63f0040     	blr	x2
    6eac: 52800000     	mov	w0, #0x0                ; =0
    6eb0: 910183ff     	add	sp, sp, #0x60
    6eb4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    6eb8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    6ebc: f84107f7     	ldr	x23, [sp], #0x10
    6ec0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    6ec4: d65f03c0     	ret
