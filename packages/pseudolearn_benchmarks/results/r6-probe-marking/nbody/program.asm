
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_diagnostic_56786/nbody/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: a9bf73fb     	stp	x27, x28, [sp, #-0x10]!
       c: a9bf6bf9     	stp	x25, x26, [sp, #-0x10]!
      10: a9bf63f7     	stp	x23, x24, [sp, #-0x10]!
      14: a9bf5bf5     	stp	x21, x22, [sp, #-0x10]!
      18: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      1c: d11783ff     	sub	sp, sp, #0x5e0
      20: b9401001     	ldr	w1, [x0, #0x10]
      24: 11000421     	add	w1, w1, #0x1
      28: b9001001     	str	w1, [x0, #0x10]
      2c: f9024be0     	str	x0, [sp, #0x490]
      30: d28000a0     	mov	x0, #0x5                ; =5
      34: 910003e3     	mov	x3, sp
      38: f80003e0     	stur	x0, [sp]
      3c: 52800001     	mov	w1, #0x0                ; =0
      40: 52802022     	mov	w2, #0x101              ; =257
      44: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      48: f9400084     	ldr	x4, [x4]
      4c: f9424be0     	ldr	x0, [sp, #0x490]
      50: d63f0080     	blr	x4
      54: 3502ea60     	cbnz	w0, 0x5da0 <___pl_fn_0+0x5da0>
      58: f9424be0     	ldr	x0, [sp, #0x490]
      5c: f9401800     	ldr	x0, [x0, #0x30]
      60: f9424be1     	ldr	x1, [sp, #0x490]
      64: b9401833     	ldr	w19, [x1, #0x18]
      68: b9401c22     	ldr	w2, [x1, #0x1c]
      6c: 11000661     	add	w1, w19, #0x1
      70: 6b02003f     	cmp	w1, w2
      74: 5402e7c8     	b.hi	0x5d6c <___pl_fn_0+0x5d6c>
      78: f9424be2     	ldr	x2, [sp, #0x490]
      7c: f9401042     	ldr	x2, [x2, #0x20]
      80: 2a1303f4     	mov	w20, w19
      84: b8335840     	str	w0, [x2, w19, uxtw #2]
      88: f902efe0     	str	x0, [sp, #0x5d8]
      8c: f9424be0     	ldr	x0, [sp, #0x490]
      90: b9001801     	str	w1, [x0, #0x18]
      94: d28000a0     	mov	x0, #0x5                ; =5
      98: 910023e3     	add	x3, sp, #0x8
      9c: f80083e0     	stur	x0, [sp, #0x8]
      a0: 52800041     	mov	w1, #0x2                ; =2
      a4: 52802022     	mov	w2, #0x101              ; =257
      a8: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      ac: f9400084     	ldr	x4, [x4]
      b0: f9424be0     	ldr	x0, [sp, #0x490]
      b4: d63f0080     	blr	x4
      b8: 3502e740     	cbnz	w0, 0x5da0 <___pl_fn_0+0x5da0>
      bc: f9424be0     	ldr	x0, [sp, #0x490]
      c0: f9401800     	ldr	x0, [x0, #0x30]
      c4: f9424beb     	ldr	x11, [sp, #0x490]
      c8: b9001973     	str	w19, [x11, #0x18]
      cc: f9424bed     	ldr	x13, [sp, #0x490]
      d0: b9401da2     	ldr	w2, [x13, #0x1c]
      d4: 11000a61     	add	w1, w19, #0x2
      d8: 6b02003f     	cmp	w1, w2
      dc: 5402e2e8     	b.hi	0x5d38 <___pl_fn_0+0x5d38>
      e0: f9424be2     	ldr	x2, [sp, #0x490]
      e4: f9401042     	ldr	x2, [x2, #0x20]
      e8: 8b140843     	add	x3, x2, x20, lsl #2
      ec: f942efe4     	ldr	x4, [sp, #0x5d8]
      f0: b8335844     	str	w4, [x2, w19, uxtw #2]
      f4: b9000460     	str	w0, [x3, #0x4]
      f8: aa0003f6     	mov	x22, x0
      fc: f9424be0     	ldr	x0, [sp, #0x490]
     100: b9001801     	str	w1, [x0, #0x18]
     104: d28000a0     	mov	x0, #0x5                ; =5
     108: 910043e3     	add	x3, sp, #0x10
     10c: f80103e0     	stur	x0, [sp, #0x10]
     110: 52800081     	mov	w1, #0x4                ; =4
     114: 52802022     	mov	w2, #0x101              ; =257
     118: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     11c: f9400084     	ldr	x4, [x4]
     120: f9424be0     	ldr	x0, [sp, #0x490]
     124: d63f0080     	blr	x4
     128: 3502e3c0     	cbnz	w0, 0x5da0 <___pl_fn_0+0x5da0>
     12c: f9424be0     	ldr	x0, [sp, #0x490]
     130: f9401815     	ldr	x21, [x0, #0x30]
     134: b9001813     	str	w19, [x0, #0x18]
     138: b9401c00     	ldr	w0, [x0, #0x1c]
     13c: 11000e61     	add	w1, w19, #0x3
     140: 6b00003f     	cmp	w1, w0
     144: 5402de08     	b.hi	0x5d04 <___pl_fn_0+0x5d04>
     148: f9424be0     	ldr	x0, [sp, #0x490]
     14c: f9401001     	ldr	x1, [x0, #0x20]
     150: 8b140820     	add	x0, x1, x20, lsl #2
     154: f942efe2     	ldr	x2, [sp, #0x5d8]
     158: b8335822     	str	w2, [x1, w19, uxtw #2]
     15c: aa1603e1     	mov	x1, x22
     160: b9000401     	str	w1, [x0, #0x4]
     164: b9000815     	str	w21, [x0, #0x8]
     168: 11000e60     	add	w0, w19, #0x3
     16c: f9424be1     	ldr	x1, [sp, #0x490]
     170: b9001820     	str	w0, [x1, #0x18]
     174: d28000a0     	mov	x0, #0x5                ; =5
     178: 910063e3     	add	x3, sp, #0x18
     17c: f80183e0     	stur	x0, [sp, #0x18]
     180: 528000c1     	mov	w1, #0x6                ; =6
     184: 52802022     	mov	w2, #0x101              ; =257
     188: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     18c: f9400084     	ldr	x4, [x4]
     190: f9424be0     	ldr	x0, [sp, #0x490]
     194: d63f0080     	blr	x4
     198: 3502e040     	cbnz	w0, 0x5da0 <___pl_fn_0+0x5da0>
     19c: f9424be0     	ldr	x0, [sp, #0x490]
     1a0: f9401800     	ldr	x0, [x0, #0x30]
     1a4: f9424be1     	ldr	x1, [sp, #0x490]
     1a8: b9001833     	str	w19, [x1, #0x18]
     1ac: f9424be2     	ldr	x2, [sp, #0x490]
     1b0: b9401c42     	ldr	w2, [x2, #0x1c]
     1b4: 11001261     	add	w1, w19, #0x4
     1b8: 6b02003f     	cmp	w1, w2
     1bc: 5402d8a8     	b.hi	0x5cd0 <___pl_fn_0+0x5cd0>
     1c0: f9424be7     	ldr	x7, [sp, #0x490]
     1c4: f94010e3     	ldr	x3, [x7, #0x20]
     1c8: 8b140862     	add	x2, x3, x20, lsl #2
     1cc: f942efe4     	ldr	x4, [sp, #0x5d8]
     1d0: b8335864     	str	w4, [x3, w19, uxtw #2]
     1d4: aa1603f8     	mov	x24, x22
     1d8: b9000458     	str	w24, [x2, #0x4]
     1dc: b9000855     	str	w21, [x2, #0x8]
     1e0: b9000c40     	str	w0, [x2, #0xc]
     1e4: f902ebe0     	str	x0, [sp, #0x5d0]
     1e8: f9424be0     	ldr	x0, [sp, #0x490]
     1ec: b9001801     	str	w1, [x0, #0x18]
     1f0: d28000a7     	mov	x7, #0x5                ; =5
     1f4: 910083e3     	add	x3, sp, #0x20
     1f8: f80203e7     	stur	x7, [sp, #0x20]
     1fc: 52800101     	mov	w1, #0x8                ; =8
     200: 52802022     	mov	w2, #0x101              ; =257
     204: 90000008     	adrp	x8, 0x0 <___pl_fn_0>
     208: f9400108     	ldr	x8, [x8]
     20c: d63f0100     	blr	x8
     210: 3502dc80     	cbnz	w0, 0x5da0 <___pl_fn_0+0x5da0>
     214: f9424be0     	ldr	x0, [sp, #0x490]
     218: f940180a     	ldr	x10, [x0, #0x30]
     21c: b9001813     	str	w19, [x0, #0x18]
     220: b9401c0b     	ldr	w11, [x0, #0x1c]
     224: 1100166c     	add	w12, w19, #0x5
     228: 6b0b019f     	cmp	w12, w11
     22c: 5402d388     	b.hi	0x5c9c <___pl_fn_0+0x5c9c>
     230: f9424be0     	ldr	x0, [sp, #0x490]
     234: f940100e     	ldr	x14, [x0, #0x20]
     238: 8b1409cd     	add	x13, x14, x20, lsl #2
     23c: f942efe0     	ldr	x0, [sp, #0x5d8]
     240: b83359c0     	str	w0, [x14, w19, uxtw #2]
     244: b90005b8     	str	w24, [x13, #0x4]
     248: b90009b5     	str	w21, [x13, #0x8]
     24c: f942ebe0     	ldr	x0, [sp, #0x5d0]
     250: b9000da0     	str	w0, [x13, #0xc]
     254: b90011aa     	str	w10, [x13, #0x10]
     258: f902e7ea     	str	x10, [sp, #0x5c8]
     25c: 11001660     	add	w0, w19, #0x5
     260: f9424be1     	ldr	x1, [sp, #0x490]
     264: b9001820     	str	w0, [x1, #0x18]
     268: d28000a0     	mov	x0, #0x5                ; =5
     26c: 9100a3e3     	add	x3, sp, #0x28
     270: f80283e0     	stur	x0, [sp, #0x28]
     274: 52800141     	mov	w1, #0xa                ; =10
     278: 52802022     	mov	w2, #0x101              ; =257
     27c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     280: f9400084     	ldr	x4, [x4]
     284: f9424be0     	ldr	x0, [sp, #0x490]
     288: d63f0080     	blr	x4
     28c: 3502d8a0     	cbnz	w0, 0x5da0 <___pl_fn_0+0x5da0>
     290: f9424be0     	ldr	x0, [sp, #0x490]
     294: f9401800     	ldr	x0, [x0, #0x30]
     298: f9424be1     	ldr	x1, [sp, #0x490]
     29c: b9001833     	str	w19, [x1, #0x18]
     2a0: b9401c22     	ldr	w2, [x1, #0x1c]
     2a4: 11001a61     	add	w1, w19, #0x6
     2a8: 6b02003f     	cmp	w1, w2
     2ac: 5402cde8     	b.hi	0x5c68 <___pl_fn_0+0x5c68>
     2b0: f9424be2     	ldr	x2, [sp, #0x490]
     2b4: f9401043     	ldr	x3, [x2, #0x20]
     2b8: 8b140862     	add	x2, x3, x20, lsl #2
     2bc: f942efe4     	ldr	x4, [sp, #0x5d8]
     2c0: b8335864     	str	w4, [x3, w19, uxtw #2]
     2c4: b9000458     	str	w24, [x2, #0x4]
     2c8: b9000855     	str	w21, [x2, #0x8]
     2cc: f942ebe3     	ldr	x3, [sp, #0x5d0]
     2d0: b9000c43     	str	w3, [x2, #0xc]
     2d4: f942e7ea     	ldr	x10, [sp, #0x5c8]
     2d8: b900104a     	str	w10, [x2, #0x10]
     2dc: b9001440     	str	w0, [x2, #0x14]
     2e0: f902e3e0     	str	x0, [sp, #0x5c0]
     2e4: f9424be0     	ldr	x0, [sp, #0x490]
     2e8: b9001801     	str	w1, [x0, #0x18]
     2ec: d28000a0     	mov	x0, #0x5                ; =5
     2f0: 9100c3e3     	add	x3, sp, #0x30
     2f4: f80303e0     	stur	x0, [sp, #0x30]
     2f8: 52800181     	mov	w1, #0xc                ; =12
     2fc: 52802022     	mov	w2, #0x101              ; =257
     300: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     304: f9400084     	ldr	x4, [x4]
     308: f9424be0     	ldr	x0, [sp, #0x490]
     30c: d63f0080     	blr	x4
     310: 3502d480     	cbnz	w0, 0x5da0 <___pl_fn_0+0x5da0>
     314: f9424be0     	ldr	x0, [sp, #0x490]
     318: f9401819     	ldr	x25, [x0, #0x30]
     31c: b9001813     	str	w19, [x0, #0x18]
     320: b9401c00     	ldr	w0, [x0, #0x1c]
     324: 11001e61     	add	w1, w19, #0x7
     328: 6b00003f     	cmp	w1, w0
     32c: 5402c848     	b.hi	0x5c34 <___pl_fn_0+0x5c34>
     330: f9424be0     	ldr	x0, [sp, #0x490]
     334: f9401001     	ldr	x1, [x0, #0x20]
     338: 8b140820     	add	x0, x1, x20, lsl #2
     33c: f942efe5     	ldr	x5, [sp, #0x5d8]
     340: b8335825     	str	w5, [x1, w19, uxtw #2]
     344: b9000418     	str	w24, [x0, #0x4]
     348: b9000815     	str	w21, [x0, #0x8]
     34c: f942ebe1     	ldr	x1, [sp, #0x5d0]
     350: b9000c01     	str	w1, [x0, #0xc]
     354: f942e7e1     	ldr	x1, [sp, #0x5c8]
     358: b9001001     	str	w1, [x0, #0x10]
     35c: f942e3e1     	ldr	x1, [sp, #0x5c0]
     360: b9001401     	str	w1, [x0, #0x14]
     364: b9001819     	str	w25, [x0, #0x18]
     368: 11001e60     	add	w0, w19, #0x7
     36c: f9424be1     	ldr	x1, [sp, #0x490]
     370: b9001820     	str	w0, [x1, #0x18]
     374: 528001c1     	mov	w1, #0xe                ; =14
     378: 52800002     	mov	w2, #0x0                ; =0
     37c: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
     380: f9400063     	ldr	x3, [x3]
     384: f9424be0     	ldr	x0, [sp, #0x490]
     388: d63f0060     	blr	x3
     38c: 3502d0a0     	cbnz	w0, 0x5da0 <___pl_fn_0+0x5da0>
     390: f9424be0     	ldr	x0, [sp, #0x490]
     394: f940181a     	ldr	x26, [x0, #0x30]
     398: b9001813     	str	w19, [x0, #0x18]
     39c: 5c02d120     	ldr	d0, 0x5dc0 <___pl_fn_0+0x5dc0>
     3a0: 1e602000     	fcmp	d0, d0
     3a4: 5402c2e1     	b.ne	0x5c00 <___pl_fn_0+0x5c00>
     3a8: 5c02d100     	ldr	d0, 0x5dc8 <___pl_fn_0+0x5dc8>
     3ac: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     3b0: 9e670001     	fmov	d1, x0
     3b4: 1e612000     	fcmp	d0, d1
     3b8: 9a9f57e0     	cset	x0, mi
     3bc: 52000000     	eor	w0, w0, #0x1
     3c0: 72001c1f     	tst	w0, #0xff
     3c4: 5402c041     	b.ne	0x5bcc <___pl_fn_0+0x5bcc>
     3c8: 5c02d040     	ldr	d0, 0x5dd0 <___pl_fn_0+0x5dd0>
     3cc: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     3d0: 9e670001     	fmov	d1, x0
     3d4: 1e612000     	fcmp	d0, d1
     3d8: 9a9f57e0     	cset	x0, mi
     3dc: 52000000     	eor	w0, w0, #0x1
     3e0: 72001c1f     	tst	w0, #0xff
     3e4: 5402bda1     	b.ne	0x5b98 <___pl_fn_0+0x5b98>
     3e8: 5c02cf40     	ldr	d0, 0x5dd0 <___pl_fn_0+0x5dd0>
     3ec: 1e602000     	fcmp	d0, d0
     3f0: 5402bba1     	b.ne	0x5b64 <___pl_fn_0+0x5b64>
     3f4: 5c02cf20     	ldr	d0, 0x5dd8 <___pl_fn_0+0x5dd8>
     3f8: 1e602000     	fcmp	d0, d0
     3fc: 5402b9a1     	b.ne	0x5b30 <___pl_fn_0+0x5b30>
     400: f942efe0     	ldr	x0, [sp, #0x5d8]
     404: 34015140     	cbz	w0, 0x2e2c <___pl_fn_0+0x2e2c>
     408: f9424be0     	ldr	x0, [sp, #0x490]
     40c: f9400000     	ldr	x0, [x0]
     410: f942efe1     	ldr	x1, [sp, #0x5d8]
     414: 2a0103e1     	mov	w1, w1
     418: 8b010c00     	add	x0, x0, x1, lsl #3
     41c: f9400801     	ldr	x1, [x0, #0x10]
     420: b4015061     	cbz	x1, 0x2e2c <___pl_fn_0+0x2e2c>
     424: 0f000407     	movi.2s	v7, #0x0
     428: 4e083ce7     	mov.d	x7, v7[0]
     42c: f9001407     	str	x7, [x0, #0x28]
     430: 340151b8     	cbz	w24, 0x2e64 <___pl_fn_0+0x2e64>
     434: f9424be0     	ldr	x0, [sp, #0x490]
     438: f940000b     	ldr	x11, [x0]
     43c: 2a1803ec     	mov	w12, w24
     440: 8b0c0d6b     	add	x11, x11, x12, lsl #3
     444: f940096c     	ldr	x12, [x11, #0x10]
     448: b40150ec     	cbz	x12, 0x2e64 <___pl_fn_0+0x2e64>
     44c: 0f000412     	movi.2s	v18, #0x0
     450: 4e083e40     	mov.d	x0, v18[0]
     454: f9001560     	str	x0, [x11, #0x28]
     458: 34015235     	cbz	w21, 0x2e9c <___pl_fn_0+0x2e9c>
     45c: f9424be0     	ldr	x0, [sp, #0x490]
     460: f9400000     	ldr	x0, [x0]
     464: 2a1503e1     	mov	w1, w21
     468: 8b010c00     	add	x0, x0, x1, lsl #3
     46c: f9400801     	ldr	x1, [x0, #0x10]
     470: b5000081     	cbnz	x1, 0x480 <___pl_fn_0+0x480>
     474: 14000a8a     	b	0x2e9c <___pl_fn_0+0x2e9c>
     478: f942ebe0     	ldr	x0, [sp, #0x5d0]
     47c: 14000005     	b	0x490 <___pl_fn_0+0x490>
     480: 0f00041d     	movi.2s	v29, #0x0
     484: 4e083fa1     	mov.d	x1, v29[0]
     488: f9001401     	str	x1, [x0, #0x28]
     48c: f942ebe0     	ldr	x0, [sp, #0x5d0]
     490: f942ebe0     	ldr	x0, [sp, #0x5d0]
     494: 34015200     	cbz	w0, 0x2ed4 <___pl_fn_0+0x2ed4>
     498: f9424be0     	ldr	x0, [sp, #0x490]
     49c: f9400000     	ldr	x0, [x0]
     4a0: f942ebeb     	ldr	x11, [sp, #0x5d0]
     4a4: 2a0b03e1     	mov	w1, w11
     4a8: 8b010c00     	add	x0, x0, x1, lsl #3
     4ac: f9400801     	ldr	x1, [x0, #0x10]
     4b0: b5000081     	cbnz	x1, 0x4c0 <___pl_fn_0+0x4c0>
     4b4: 14000a88     	b	0x2ed4 <___pl_fn_0+0x2ed4>
     4b8: f942e7e0     	ldr	x0, [sp, #0x5c8]
     4bc: 14000005     	b	0x4d0 <___pl_fn_0+0x4d0>
     4c0: 0f000400     	movi.2s	v0, #0x0
     4c4: 4e083c01     	mov.d	x1, v0[0]
     4c8: f9001401     	str	x1, [x0, #0x28]
     4cc: f942e7e0     	ldr	x0, [sp, #0x5c8]
     4d0: f942e7e0     	ldr	x0, [sp, #0x5c8]
     4d4: 340151c0     	cbz	w0, 0x2f0c <___pl_fn_0+0x2f0c>
     4d8: f9424be0     	ldr	x0, [sp, #0x490]
     4dc: f9400000     	ldr	x0, [x0]
     4e0: f942e7e8     	ldr	x8, [sp, #0x5c8]
     4e4: 2a0803e1     	mov	w1, w8
     4e8: 8b010c00     	add	x0, x0, x1, lsl #3
     4ec: f9400801     	ldr	x1, [x0, #0x10]
     4f0: b5000081     	cbnz	x1, 0x500 <___pl_fn_0+0x500>
     4f4: 14000a86     	b	0x2f0c <___pl_fn_0+0x2f0c>
     4f8: f942e3e0     	ldr	x0, [sp, #0x5c0]
     4fc: 14000005     	b	0x510 <___pl_fn_0+0x510>
     500: 0f000400     	movi.2s	v0, #0x0
     504: 4e083c01     	mov.d	x1, v0[0]
     508: f9001401     	str	x1, [x0, #0x28]
     50c: f942e3e0     	ldr	x0, [sp, #0x5c0]
     510: 340151a0     	cbz	w0, 0x2f44 <___pl_fn_0+0x2f44>
     514: f9424be0     	ldr	x0, [sp, #0x490]
     518: f9400000     	ldr	x0, [x0]
     51c: f942e3e1     	ldr	x1, [sp, #0x5c0]
     520: 2a0103e1     	mov	w1, w1
     524: 8b010c00     	add	x0, x0, x1, lsl #3
     528: f9400801     	ldr	x1, [x0, #0x10]
     52c: b40150c1     	cbz	x1, 0x2f44 <___pl_fn_0+0x2f44>
     530: 0f000400     	movi.2s	v0, #0x0
     534: 4e083c01     	mov.d	x1, v0[0]
     538: f9001401     	str	x1, [x0, #0x28]
     53c: 34015219     	cbz	w25, 0x2f7c <___pl_fn_0+0x2f7c>
     540: f9424be0     	ldr	x0, [sp, #0x490]
     544: f9400003     	ldr	x3, [x0]
     548: 2a1903e4     	mov	w4, w25
     54c: 8b040c63     	add	x3, x3, x4, lsl #3
     550: f9400864     	ldr	x4, [x3, #0x10]
     554: b5000084     	cbnz	x4, 0x564 <___pl_fn_0+0x564>
     558: 14000a89     	b	0x2f7c <___pl_fn_0+0x2f7c>
     55c: f942efe0     	ldr	x0, [sp, #0x5d8]
     560: 14000005     	b	0x574 <___pl_fn_0+0x574>
     564: 5c02c370     	ldr	d16, 0x5dd0 <___pl_fn_0+0x5dd0>
     568: 4e083e0a     	mov.d	x10, v16[0]
     56c: f900146a     	str	x10, [x3, #0x28]
     570: f942efe0     	ldr	x0, [sp, #0x5d8]
     574: f942efe0     	ldr	x0, [sp, #0x5d8]
     578: 340151e0     	cbz	w0, 0x2fb4 <___pl_fn_0+0x2fb4>
     57c: f9424be0     	ldr	x0, [sp, #0x490]
     580: f940000e     	ldr	x14, [x0]
     584: f942efe0     	ldr	x0, [sp, #0x5d8]
     588: 2a0003ef     	mov	w15, w0
     58c: 8b0f0dce     	add	x14, x14, x15, lsl #3
     590: f94009cf     	ldr	x15, [x14, #0x10]
     594: f10005ff     	cmp	x15, #0x1
     598: 540150e9     	b.ls	0x2fb4 <___pl_fn_0+0x2fb4>
     59c: 5c02c236     	ldr	d22, 0x5de0 <___pl_fn_0+0x5de0>
     5a0: 4e083ec0     	mov.d	x0, v22[0]
     5a4: f90019c0     	str	x0, [x14, #0x30]
     5a8: 34015238     	cbz	w24, 0x2fec <___pl_fn_0+0x2fec>
     5ac: f9424be0     	ldr	x0, [sp, #0x490]
     5b0: f9400000     	ldr	x0, [x0]
     5b4: 2a1803e1     	mov	w1, w24
     5b8: 8b010c00     	add	x0, x0, x1, lsl #3
     5bc: f9400801     	ldr	x1, [x0, #0x10]
     5c0: f100043f     	cmp	x1, #0x1
     5c4: 54015149     	b.ls	0x2fec <___pl_fn_0+0x2fec>
     5c8: 5c02c100     	ldr	d0, 0x5de8 <___pl_fn_0+0x5de8>
     5cc: 4e083c01     	mov.d	x1, v0[0]
     5d0: f9001801     	str	x1, [x0, #0x30]
     5d4: 34015295     	cbz	w21, 0x3024 <___pl_fn_0+0x3024>
     5d8: f9424be0     	ldr	x0, [sp, #0x490]
     5dc: f9400000     	ldr	x0, [x0]
     5e0: 2a1503e1     	mov	w1, w21
     5e4: 8b010c00     	add	x0, x0, x1, lsl #3
     5e8: f9400801     	ldr	x1, [x0, #0x10]
     5ec: f100043f     	cmp	x1, #0x1
     5f0: 540151a9     	b.ls	0x3024 <___pl_fn_0+0x3024>
     5f4: 5c02bfe0     	ldr	d0, 0x5df0 <___pl_fn_0+0x5df0>
     5f8: 4e083c01     	mov.d	x1, v0[0]
     5fc: f9001801     	str	x1, [x0, #0x30]
     600: 5c02bfc0     	ldr	d0, 0x5df8 <___pl_fn_0+0x5df8>
     604: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     608: 9e670001     	fmov	d1, x0
     60c: 1e612000     	fcmp	d0, d1
     610: 9a9f57e0     	cset	x0, mi
     614: 52000000     	eor	w0, w0, #0x1
     618: 72001c1f     	tst	w0, #0xff
     61c: 5402a701     	b.ne	0x5afc <___pl_fn_0+0x5afc>
     620: f942ebe0     	ldr	x0, [sp, #0x5d0]
     624: 340151c0     	cbz	w0, 0x305c <___pl_fn_0+0x305c>
     628: f9424be0     	ldr	x0, [sp, #0x490]
     62c: f9400000     	ldr	x0, [x0]
     630: f942ebe3     	ldr	x3, [sp, #0x5d0]
     634: 2a0303e1     	mov	w1, w3
     638: 8b010c00     	add	x0, x0, x1, lsl #3
     63c: f9400801     	ldr	x1, [x0, #0x10]
     640: f100043f     	cmp	x1, #0x1
     644: 540150c9     	b.ls	0x305c <___pl_fn_0+0x305c>
     648: 5c02bd80     	ldr	d0, 0x5df8 <___pl_fn_0+0x5df8>
     64c: 4e083c01     	mov.d	x1, v0[0]
     650: f9001801     	str	x1, [x0, #0x30]
     654: 5c02bd60     	ldr	d0, 0x5e00 <___pl_fn_0+0x5e00>
     658: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     65c: 9e670001     	fmov	d1, x0
     660: 1e612000     	fcmp	d0, d1
     664: 9a9f57e1     	cset	x1, mi
     668: 52000021     	eor	w1, w1, #0x1
     66c: 72001c3f     	tst	w1, #0xff
     670: 5402a2c1     	b.ne	0x5ac8 <___pl_fn_0+0x5ac8>
     674: f942e7e0     	ldr	x0, [sp, #0x5c8]
     678: 340150e0     	cbz	w0, 0x3094 <___pl_fn_0+0x3094>
     67c: f9424be0     	ldr	x0, [sp, #0x490]
     680: f9400005     	ldr	x5, [x0]
     684: f942e7e0     	ldr	x0, [sp, #0x5c8]
     688: 2a0003e6     	mov	w6, w0
     68c: 8b060ca5     	add	x5, x5, x6, lsl #3
     690: f94008a6     	ldr	x6, [x5, #0x10]
     694: f10004df     	cmp	x6, #0x1
     698: 54014fe9     	b.ls	0x3094 <___pl_fn_0+0x3094>
     69c: 5c02bb30     	ldr	d16, 0x5e00 <___pl_fn_0+0x5e00>
     6a0: 4e083e0d     	mov.d	x13, v16[0]
     6a4: f90018ad     	str	x13, [x5, #0x30]
     6a8: 5c02bb10     	ldr	d16, 0x5e08 <___pl_fn_0+0x5e08>
     6ac: d2effe0e     	mov	x14, #0x7ff0000000000000 ; =9218868437227405312
     6b0: 9e6701d1     	fmov	d17, x14
     6b4: 1e712200     	fcmp	d16, d17
     6b8: 9a9f57e0     	cset	x0, mi
     6bc: 52000000     	eor	w0, w0, #0x1
     6c0: 72001c1f     	tst	w0, #0xff
     6c4: 54029e81     	b.ne	0x5a94 <___pl_fn_0+0x5a94>
     6c8: f942e3e0     	ldr	x0, [sp, #0x5c0]
     6cc: 34015000     	cbz	w0, 0x30cc <___pl_fn_0+0x30cc>
     6d0: f9424be0     	ldr	x0, [sp, #0x490]
     6d4: f9400000     	ldr	x0, [x0]
     6d8: f942e3ea     	ldr	x10, [sp, #0x5c0]
     6dc: 2a0a03e1     	mov	w1, w10
     6e0: 8b010c00     	add	x0, x0, x1, lsl #3
     6e4: f9400801     	ldr	x1, [x0, #0x10]
     6e8: f100043f     	cmp	x1, #0x1
     6ec: 54014f09     	b.ls	0x30cc <___pl_fn_0+0x30cc>
     6f0: 5c02b91c     	ldr	d28, 0x5e10 <___pl_fn_0+0x5e10>
     6f4: 4e083f81     	mov.d	x1, v28[0]
     6f8: f9001801     	str	x1, [x0, #0x30]
     6fc: 5c02b8fe     	ldr	d30, 0x5e18 <___pl_fn_0+0x5e18>
     700: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     704: 9e67001f     	fmov	d31, x0
     708: 1e7f23c0     	fcmp	d30, d31
     70c: 9a9f57e0     	cset	x0, mi
     710: 52000000     	eor	w0, w0, #0x1
     714: 72001c1f     	tst	w0, #0xff
     718: 54029a41     	b.ne	0x5a60 <___pl_fn_0+0x5a60>
     71c: 34014f59     	cbz	w25, 0x3104 <___pl_fn_0+0x3104>
     720: f9424be0     	ldr	x0, [sp, #0x490]
     724: f9400000     	ldr	x0, [x0]
     728: 2a1903e1     	mov	w1, w25
     72c: 8b010c00     	add	x0, x0, x1, lsl #3
     730: f9400801     	ldr	x1, [x0, #0x10]
     734: f100043f     	cmp	x1, #0x1
     738: 54000088     	b.hi	0x748 <___pl_fn_0+0x748>
     73c: 14000a72     	b	0x3104 <___pl_fn_0+0x3104>
     740: f942efe0     	ldr	x0, [sp, #0x5d8]
     744: 14000005     	b	0x758 <___pl_fn_0+0x758>
     748: 5c02b680     	ldr	d0, 0x5e18 <___pl_fn_0+0x5e18>
     74c: 4e083c01     	mov.d	x1, v0[0]
     750: f9001801     	str	x1, [x0, #0x30]
     754: f942efe0     	ldr	x0, [sp, #0x5d8]
     758: f942efe0     	ldr	x0, [sp, #0x5d8]
     75c: 34014f00     	cbz	w0, 0x313c <___pl_fn_0+0x313c>
     760: f9424be0     	ldr	x0, [sp, #0x490]
     764: f9400000     	ldr	x0, [x0]
     768: f942efe1     	ldr	x1, [sp, #0x5d8]
     76c: 2a0103e1     	mov	w1, w1
     770: 8b010c00     	add	x0, x0, x1, lsl #3
     774: f9400801     	ldr	x1, [x0, #0x10]
     778: f100083f     	cmp	x1, #0x2
     77c: 54014e09     	b.ls	0x313c <___pl_fn_0+0x313c>
     780: 5c02b500     	ldr	d0, 0x5e20 <___pl_fn_0+0x5e20>
     784: 4e083c01     	mov.d	x1, v0[0]
     788: f9001c01     	str	x1, [x0, #0x38]
     78c: 34014f58     	cbz	w24, 0x3174 <___pl_fn_0+0x3174>
     790: f9424be0     	ldr	x0, [sp, #0x490]
     794: f9400000     	ldr	x0, [x0]
     798: 2a1803e1     	mov	w1, w24
     79c: 8b010c00     	add	x0, x0, x1, lsl #3
     7a0: f9400801     	ldr	x1, [x0, #0x10]
     7a4: f100083f     	cmp	x1, #0x2
     7a8: 54014e69     	b.ls	0x3174 <___pl_fn_0+0x3174>
     7ac: 5c02b3e4     	ldr	d4, 0x5e28 <___pl_fn_0+0x5e28>
     7b0: 4e083c84     	mov.d	x4, v4[0]
     7b4: f9001c04     	str	x4, [x0, #0x38]
     7b8: 34014fb5     	cbz	w21, 0x31ac <___pl_fn_0+0x31ac>
     7bc: f9424be0     	ldr	x0, [sp, #0x490]
     7c0: f9400008     	ldr	x8, [x0]
     7c4: 2a1503e9     	mov	w9, w21
     7c8: 8b090d08     	add	x8, x8, x9, lsl #3
     7cc: f9400909     	ldr	x9, [x8, #0x10]
     7d0: f100093f     	cmp	x9, #0x2
     7d4: 54014ec9     	b.ls	0x31ac <___pl_fn_0+0x31ac>
     7d8: 5c02b2d0     	ldr	d16, 0x5e30 <___pl_fn_0+0x5e30>
     7dc: 4e083e00     	mov.d	x0, v16[0]
     7e0: f9001d00     	str	x0, [x8, #0x38]
     7e4: 5c02b2b2     	ldr	d18, 0x5e38 <___pl_fn_0+0x5e38>
     7e8: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     7ec: 9e670013     	fmov	d19, x0
     7f0: 1e732240     	fcmp	d18, d19
     7f4: 9a9f57e0     	cset	x0, mi
     7f8: 52000000     	eor	w0, w0, #0x1
     7fc: 72001c1f     	tst	w0, #0xff
     800: 54029161     	b.ne	0x5a2c <___pl_fn_0+0x5a2c>
     804: f942ebe0     	ldr	x0, [sp, #0x5d0]
     808: 34014ee0     	cbz	w0, 0x31e4 <___pl_fn_0+0x31e4>
     80c: f9424be0     	ldr	x0, [sp, #0x490]
     810: f9400000     	ldr	x0, [x0]
     814: f942ebe1     	ldr	x1, [sp, #0x5d0]
     818: 2a0103e1     	mov	w1, w1
     81c: 8b010c00     	add	x0, x0, x1, lsl #3
     820: f9400801     	ldr	x1, [x0, #0x10]
     824: f100083f     	cmp	x1, #0x2
     828: 54014de9     	b.ls	0x31e4 <___pl_fn_0+0x31e4>
     82c: 5c02b0bf     	ldr	d31, 0x5e40 <___pl_fn_0+0x5e40>
     830: 4e083fe1     	mov.d	x1, v31[0]
     834: f9001c01     	str	x1, [x0, #0x38]
     838: 5c02b080     	ldr	d0, 0x5e48 <___pl_fn_0+0x5e48>
     83c: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     840: 9e670001     	fmov	d1, x0
     844: 1e612000     	fcmp	d0, d1
     848: 9a9f57e0     	cset	x0, mi
     84c: 52000000     	eor	w0, w0, #0x1
     850: 72001c1f     	tst	w0, #0xff
     854: 54028d21     	b.ne	0x59f8 <___pl_fn_0+0x59f8>
     858: f942e7e0     	ldr	x0, [sp, #0x5c8]
     85c: 34014e00     	cbz	w0, 0x321c <___pl_fn_0+0x321c>
     860: f9424be0     	ldr	x0, [sp, #0x490]
     864: f9400000     	ldr	x0, [x0]
     868: f942e7e1     	ldr	x1, [sp, #0x5c8]
     86c: 2a0103e1     	mov	w1, w1
     870: 8b010c00     	add	x0, x0, x1, lsl #3
     874: f9400801     	ldr	x1, [x0, #0x10]
     878: f100083f     	cmp	x1, #0x2
     87c: 54014d09     	b.ls	0x321c <___pl_fn_0+0x321c>
     880: 5c02ae40     	ldr	d0, 0x5e48 <___pl_fn_0+0x5e48>
     884: 4e083c01     	mov.d	x1, v0[0]
     888: f9001c01     	str	x1, [x0, #0x38]
     88c: 5c02ae20     	ldr	d0, 0x5e50 <___pl_fn_0+0x5e50>
     890: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     894: 9e670001     	fmov	d1, x0
     898: 1e612000     	fcmp	d0, d1
     89c: 9a9f57e0     	cset	x0, mi
     8a0: 52000000     	eor	w0, w0, #0x1
     8a4: 72001c1f     	tst	w0, #0xff
     8a8: 540288e1     	b.ne	0x59c4 <___pl_fn_0+0x59c4>
     8ac: f942e3e0     	ldr	x0, [sp, #0x5c0]
     8b0: 34014d20     	cbz	w0, 0x3254 <___pl_fn_0+0x3254>
     8b4: f9424be0     	ldr	x0, [sp, #0x490]
     8b8: f9400000     	ldr	x0, [x0]
     8bc: f942e3e1     	ldr	x1, [sp, #0x5c0]
     8c0: 2a0103e1     	mov	w1, w1
     8c4: 8b010c00     	add	x0, x0, x1, lsl #3
     8c8: f9400801     	ldr	x1, [x0, #0x10]
     8cc: f100083f     	cmp	x1, #0x2
     8d0: 54014c29     	b.ls	0x3254 <___pl_fn_0+0x3254>
     8d4: 5c02abe0     	ldr	d0, 0x5e50 <___pl_fn_0+0x5e50>
     8d8: 4e083c01     	mov.d	x1, v0[0]
     8dc: f9001c01     	str	x1, [x0, #0x38]
     8e0: 5c02abc0     	ldr	d0, 0x5e58 <___pl_fn_0+0x5e58>
     8e4: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     8e8: 9e670001     	fmov	d1, x0
     8ec: 1e612000     	fcmp	d0, d1
     8f0: 9a9f57e1     	cset	x1, mi
     8f4: 52000021     	eor	w1, w1, #0x1
     8f8: 72001c3f     	tst	w1, #0xff
     8fc: 540284a1     	b.ne	0x5990 <___pl_fn_0+0x5990>
     900: 34014c79     	cbz	w25, 0x328c <___pl_fn_0+0x328c>
     904: f9424be0     	ldr	x0, [sp, #0x490]
     908: f9400005     	ldr	x5, [x0]
     90c: 2a1903e6     	mov	w6, w25
     910: 8b060ca5     	add	x5, x5, x6, lsl #3
     914: f94008a6     	ldr	x6, [x5, #0x10]
     918: f10008df     	cmp	x6, #0x2
     91c: 54000088     	b.hi	0x92c <___pl_fn_0+0x92c>
     920: 14000a5b     	b	0x328c <___pl_fn_0+0x328c>
     924: f942efe0     	ldr	x0, [sp, #0x5d8]
     928: 14000005     	b	0x93c <___pl_fn_0+0x93c>
     92c: 5c02a970     	ldr	d16, 0x5e58 <___pl_fn_0+0x5e58>
     930: 4e083e0d     	mov.d	x13, v16[0]
     934: f9001cad     	str	x13, [x5, #0x38]
     938: f942efe0     	ldr	x0, [sp, #0x5d8]
     93c: f942efe0     	ldr	x0, [sp, #0x5d8]
     940: 34014c20     	cbz	w0, 0x32c4 <___pl_fn_0+0x32c4>
     944: f9424be0     	ldr	x0, [sp, #0x490]
     948: f9400000     	ldr	x0, [x0]
     94c: f942efea     	ldr	x10, [sp, #0x5d8]
     950: 2a0a03e1     	mov	w1, w10
     954: 8b010c00     	add	x0, x0, x1, lsl #3
     958: f9400801     	ldr	x1, [x0, #0x10]
     95c: f1000c3f     	cmp	x1, #0x3
     960: 54014b29     	b.ls	0x32c4 <___pl_fn_0+0x32c4>
     964: 5c02a7f9     	ldr	d25, 0x5e60 <___pl_fn_0+0x5e60>
     968: 4e083f21     	mov.d	x1, v25[0]
     96c: f9002001     	str	x1, [x0, #0x40]
     970: 34014c78     	cbz	w24, 0x32fc <___pl_fn_0+0x32fc>
     974: f9424be0     	ldr	x0, [sp, #0x490]
     978: f9400000     	ldr	x0, [x0]
     97c: 2a1803e1     	mov	w1, w24
     980: 8b010c00     	add	x0, x0, x1, lsl #3
     984: f9400801     	ldr	x1, [x0, #0x10]
     988: f1000c3f     	cmp	x1, #0x3
     98c: 54014b89     	b.ls	0x32fc <___pl_fn_0+0x32fc>
     990: 5c02a6c0     	ldr	d0, 0x5e68 <___pl_fn_0+0x5e68>
     994: 4e083c01     	mov.d	x1, v0[0]
     998: f9002001     	str	x1, [x0, #0x40]
     99c: 34014cd5     	cbz	w21, 0x3334 <___pl_fn_0+0x3334>
     9a0: f9424be0     	ldr	x0, [sp, #0x490]
     9a4: f9400000     	ldr	x0, [x0]
     9a8: 2a1503e1     	mov	w1, w21
     9ac: 8b010c00     	add	x0, x0, x1, lsl #3
     9b0: f9400801     	ldr	x1, [x0, #0x10]
     9b4: f1000c3f     	cmp	x1, #0x3
     9b8: 54014be9     	b.ls	0x3334 <___pl_fn_0+0x3334>
     9bc: 5c02a5a0     	ldr	d0, 0x5e70 <___pl_fn_0+0x5e70>
     9c0: 4e083c01     	mov.d	x1, v0[0]
     9c4: f9002001     	str	x1, [x0, #0x40]
     9c8: 5c02a580     	ldr	d0, 0x5e78 <___pl_fn_0+0x5e78>
     9cc: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     9d0: 9e670001     	fmov	d1, x0
     9d4: 1e612000     	fcmp	d0, d1
     9d8: 9a9f57e0     	cset	x0, mi
     9dc: 52000000     	eor	w0, w0, #0x1
     9e0: 72001c1f     	tst	w0, #0xff
     9e4: 54027bc1     	b.ne	0x595c <___pl_fn_0+0x595c>
     9e8: f942ebe0     	ldr	x0, [sp, #0x5d0]
     9ec: 34014c00     	cbz	w0, 0x336c <___pl_fn_0+0x336c>
     9f0: f9424be0     	ldr	x0, [sp, #0x490]
     9f4: f9400000     	ldr	x0, [x0]
     9f8: f942ebe1     	ldr	x1, [sp, #0x5d0]
     9fc: 2a0103e1     	mov	w1, w1
     a00: 8b010c00     	add	x0, x0, x1, lsl #3
     a04: f9400801     	ldr	x1, [x0, #0x10]
     a08: f1000c3f     	cmp	x1, #0x3
     a0c: 54014b09     	b.ls	0x336c <___pl_fn_0+0x336c>
     a10: 5c02a341     	ldr	d1, 0x5e78 <___pl_fn_0+0x5e78>
     a14: 4e083c21     	mov.d	x1, v1[0]
     a18: f9002001     	str	x1, [x0, #0x40]
     a1c: 5c02a323     	ldr	d3, 0x5e80 <___pl_fn_0+0x5e80>
     a20: d2effe02     	mov	x2, #0x7ff0000000000000 ; =9218868437227405312
     a24: 9e670044     	fmov	d4, x2
     a28: 1e642060     	fcmp	d3, d4
     a2c: 9a9f57e4     	cset	x4, mi
     a30: 52000084     	eor	w4, w4, #0x1
     a34: 72001c9f     	tst	w4, #0xff
     a38: 54027781     	b.ne	0x5928 <___pl_fn_0+0x5928>
     a3c: f942e7e0     	ldr	x0, [sp, #0x5c8]
     a40: 34014b20     	cbz	w0, 0x33a4 <___pl_fn_0+0x33a4>
     a44: f9424be0     	ldr	x0, [sp, #0x490]
     a48: f9400008     	ldr	x8, [x0]
     a4c: f942e7e0     	ldr	x0, [sp, #0x5c8]
     a50: 2a0003e9     	mov	w9, w0
     a54: 8b090d08     	add	x8, x8, x9, lsl #3
     a58: f9400909     	ldr	x9, [x8, #0x10]
     a5c: f1000d3f     	cmp	x9, #0x3
     a60: 54014a29     	b.ls	0x33a4 <___pl_fn_0+0x33a4>
     a64: 5c02a0f0     	ldr	d16, 0x5e80 <___pl_fn_0+0x5e80>
     a68: 4e083e00     	mov.d	x0, v16[0]
     a6c: f9002100     	str	x0, [x8, #0x40]
     a70: 5c02a0d2     	ldr	d18, 0x5e88 <___pl_fn_0+0x5e88>
     a74: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     a78: 9e670013     	fmov	d19, x0
     a7c: 1e732240     	fcmp	d18, d19
     a80: 9a9f57e0     	cset	x0, mi
     a84: 52000000     	eor	w0, w0, #0x1
     a88: 72001c1f     	tst	w0, #0xff
     a8c: 54027341     	b.ne	0x58f4 <___pl_fn_0+0x58f4>
     a90: f942e3e0     	ldr	x0, [sp, #0x5c0]
     a94: 34014a40     	cbz	w0, 0x33dc <___pl_fn_0+0x33dc>
     a98: f9424be0     	ldr	x0, [sp, #0x490]
     a9c: f9400000     	ldr	x0, [x0]
     aa0: f942e3e1     	ldr	x1, [sp, #0x5c0]
     aa4: 2a0103e1     	mov	w1, w1
     aa8: 8b010c00     	add	x0, x0, x1, lsl #3
     aac: f9400801     	ldr	x1, [x0, #0x10]
     ab0: f1000c3f     	cmp	x1, #0x3
     ab4: 54014949     	b.ls	0x33dc <___pl_fn_0+0x33dc>
     ab8: 5c029edf     	ldr	d31, 0x5e90 <___pl_fn_0+0x5e90>
     abc: 4e083fe1     	mov.d	x1, v31[0]
     ac0: f9002001     	str	x1, [x0, #0x40]
     ac4: 5c029ea0     	ldr	d0, 0x5e98 <___pl_fn_0+0x5e98>
     ac8: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     acc: 9e670001     	fmov	d1, x0
     ad0: 1e612000     	fcmp	d0, d1
     ad4: 9a9f57e0     	cset	x0, mi
     ad8: 52000000     	eor	w0, w0, #0x1
     adc: 72001c1f     	tst	w0, #0xff
     ae0: 54026f01     	b.ne	0x58c0 <___pl_fn_0+0x58c0>
     ae4: 34014999     	cbz	w25, 0x3414 <___pl_fn_0+0x3414>
     ae8: f9424be0     	ldr	x0, [sp, #0x490]
     aec: f9400000     	ldr	x0, [x0]
     af0: 2a1903e1     	mov	w1, w25
     af4: 8b010c00     	add	x0, x0, x1, lsl #3
     af8: f9400801     	ldr	x1, [x0, #0x10]
     afc: f1000c3f     	cmp	x1, #0x3
     b00: 54000088     	b.hi	0xb10 <___pl_fn_0+0xb10>
     b04: 14000a44     	b	0x3414 <___pl_fn_0+0x3414>
     b08: f942efe0     	ldr	x0, [sp, #0x5d8]
     b0c: 14000005     	b	0xb20 <___pl_fn_0+0xb20>
     b10: 5c029c40     	ldr	d0, 0x5e98 <___pl_fn_0+0x5e98>
     b14: 4e083c01     	mov.d	x1, v0[0]
     b18: f9002001     	str	x1, [x0, #0x40]
     b1c: f942efe0     	ldr	x0, [sp, #0x5d8]
     b20: f942efe0     	ldr	x0, [sp, #0x5d8]
     b24: 34014940     	cbz	w0, 0x344c <___pl_fn_0+0x344c>
     b28: f9424be0     	ldr	x0, [sp, #0x490]
     b2c: f9400000     	ldr	x0, [x0]
     b30: f942efe1     	ldr	x1, [sp, #0x5d8]
     b34: 2a0103e1     	mov	w1, w1
     b38: 8b010c00     	add	x0, x0, x1, lsl #3
     b3c: f9400801     	ldr	x1, [x0, #0x10]
     b40: f100103f     	cmp	x1, #0x4
     b44: 54014849     	b.ls	0x344c <___pl_fn_0+0x344c>
     b48: 5c029ac0     	ldr	d0, 0x5ea0 <___pl_fn_0+0x5ea0>
     b4c: 4e083c01     	mov.d	x1, v0[0]
     b50: f9002401     	str	x1, [x0, #0x48]
     b54: 34014998     	cbz	w24, 0x3484 <___pl_fn_0+0x3484>
     b58: f9424be0     	ldr	x0, [sp, #0x490]
     b5c: f9400000     	ldr	x0, [x0]
     b60: 2a1803e1     	mov	w1, w24
     b64: 8b010c00     	add	x0, x0, x1, lsl #3
     b68: f9400801     	ldr	x1, [x0, #0x10]
     b6c: f100103f     	cmp	x1, #0x4
     b70: 540148a9     	b.ls	0x3484 <___pl_fn_0+0x3484>
     b74: 5c0299a7     	ldr	d7, 0x5ea8 <___pl_fn_0+0x5ea8>
     b78: 4e083ce7     	mov.d	x7, v7[0]
     b7c: f9002407     	str	x7, [x0, #0x48]
     b80: 340149f5     	cbz	w21, 0x34bc <___pl_fn_0+0x34bc>
     b84: f9424be0     	ldr	x0, [sp, #0x490]
     b88: f940000b     	ldr	x11, [x0]
     b8c: 2a1503ec     	mov	w12, w21
     b90: 8b0c0d6b     	add	x11, x11, x12, lsl #3
     b94: f940096c     	ldr	x12, [x11, #0x10]
     b98: f100119f     	cmp	x12, #0x4
     b9c: 54014909     	b.ls	0x34bc <___pl_fn_0+0x34bc>
     ba0: 5c029893     	ldr	d19, 0x5eb0 <___pl_fn_0+0x5eb0>
     ba4: 4e083e60     	mov.d	x0, v19[0]
     ba8: f9002560     	str	x0, [x11, #0x48]
     bac: 5c029875     	ldr	d21, 0x5eb8 <___pl_fn_0+0x5eb8>
     bb0: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     bb4: 9e670016     	fmov	d22, x0
     bb8: 1e7622a0     	fcmp	d21, d22
     bbc: 9a9f57e0     	cset	x0, mi
     bc0: 52000000     	eor	w0, w0, #0x1
     bc4: 72001c1f     	tst	w0, #0xff
     bc8: 54026621     	b.ne	0x588c <___pl_fn_0+0x588c>
     bcc: f942ebe0     	ldr	x0, [sp, #0x5d0]
     bd0: 34014920     	cbz	w0, 0x34f4 <___pl_fn_0+0x34f4>
     bd4: f9424be0     	ldr	x0, [sp, #0x490]
     bd8: f9400000     	ldr	x0, [x0]
     bdc: f942ebe1     	ldr	x1, [sp, #0x5d0]
     be0: 2a0103e1     	mov	w1, w1
     be4: 8b010c00     	add	x0, x0, x1, lsl #3
     be8: f9400801     	ldr	x1, [x0, #0x10]
     bec: f100103f     	cmp	x1, #0x4
     bf0: 54014829     	b.ls	0x34f4 <___pl_fn_0+0x34f4>
     bf4: 5c029620     	ldr	d0, 0x5eb8 <___pl_fn_0+0x5eb8>
     bf8: 4e083c01     	mov.d	x1, v0[0]
     bfc: f9002401     	str	x1, [x0, #0x48]
     c00: 5c029600     	ldr	d0, 0x5ec0 <___pl_fn_0+0x5ec0>
     c04: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     c08: 9e670001     	fmov	d1, x0
     c0c: 1e612000     	fcmp	d0, d1
     c10: 9a9f57e0     	cset	x0, mi
     c14: 52000000     	eor	w0, w0, #0x1
     c18: 72001c1f     	tst	w0, #0xff
     c1c: 540261e1     	b.ne	0x5858 <___pl_fn_0+0x5858>
     c20: f942e7e0     	ldr	x0, [sp, #0x5c8]
     c24: 34014840     	cbz	w0, 0x352c <___pl_fn_0+0x352c>
     c28: f9424be0     	ldr	x0, [sp, #0x490]
     c2c: f9400000     	ldr	x0, [x0]
     c30: f942e7e6     	ldr	x6, [sp, #0x5c8]
     c34: 2a0603e1     	mov	w1, w6
     c38: 8b010c00     	add	x0, x0, x1, lsl #3
     c3c: f9400801     	ldr	x1, [x0, #0x10]
     c40: f100103f     	cmp	x1, #0x4
     c44: 54014749     	b.ls	0x352c <___pl_fn_0+0x352c>
     c48: 5c0293c0     	ldr	d0, 0x5ec0 <___pl_fn_0+0x5ec0>
     c4c: 4e083c01     	mov.d	x1, v0[0]
     c50: f9002401     	str	x1, [x0, #0x48]
     c54: 5c0293a0     	ldr	d0, 0x5ec8 <___pl_fn_0+0x5ec8>
     c58: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     c5c: 9e670001     	fmov	d1, x0
     c60: 1e612000     	fcmp	d0, d1
     c64: 9a9f57e0     	cset	x0, mi
     c68: 52000000     	eor	w0, w0, #0x1
     c6c: 72001c1f     	tst	w0, #0xff
     c70: 54025da1     	b.ne	0x5824 <___pl_fn_0+0x5824>
     c74: f942e3e0     	ldr	x0, [sp, #0x5c0]
     c78: 34014760     	cbz	w0, 0x3564 <___pl_fn_0+0x3564>
     c7c: f9424be0     	ldr	x0, [sp, #0x490]
     c80: f9400000     	ldr	x0, [x0]
     c84: f942e3e7     	ldr	x7, [sp, #0x5c0]
     c88: 2a0703e1     	mov	w1, w7
     c8c: 8b010c00     	add	x0, x0, x1, lsl #3
     c90: f9400801     	ldr	x1, [x0, #0x10]
     c94: f100103f     	cmp	x1, #0x4
     c98: 54014669     	b.ls	0x3564 <___pl_fn_0+0x3564>
     c9c: 5c0291a1     	ldr	d1, 0x5ed0 <___pl_fn_0+0x5ed0>
     ca0: 4e083c21     	mov.d	x1, v1[0]
     ca4: f9002401     	str	x1, [x0, #0x48]
     ca8: 5c029183     	ldr	d3, 0x5ed8 <___pl_fn_0+0x5ed8>
     cac: d2effe02     	mov	x2, #0x7ff0000000000000 ; =9218868437227405312
     cb0: 9e670044     	fmov	d4, x2
     cb4: 1e642060     	fcmp	d3, d4
     cb8: 9a9f57e4     	cset	x4, mi
     cbc: 52000084     	eor	w4, w4, #0x1
     cc0: 72001c9f     	tst	w4, #0xff
     cc4: 54025961     	b.ne	0x57f0 <___pl_fn_0+0x57f0>
     cc8: 340146b9     	cbz	w25, 0x359c <___pl_fn_0+0x359c>
     ccc: f9424be0     	ldr	x0, [sp, #0x490]
     cd0: f9400008     	ldr	x8, [x0]
     cd4: 2a1903e9     	mov	w9, w25
     cd8: 8b090d08     	add	x8, x8, x9, lsl #3
     cdc: f9400909     	ldr	x9, [x8, #0x10]
     ce0: f100113f     	cmp	x9, #0x4
     ce4: 540145c9     	b.ls	0x359c <___pl_fn_0+0x359c>
     ce8: 5c028f90     	ldr	d16, 0x5ed8 <___pl_fn_0+0x5ed8>
     cec: 4e083e00     	mov.d	x0, v16[0]
     cf0: f9002500     	str	x0, [x8, #0x48]
     cf4: 0f000412     	movi.2s	v18, #0x0
     cf8: 1e722240     	fcmp	d18, d18
     cfc: 54025601     	b.ne	0x57bc <___pl_fn_0+0x57bc>
     d00: 1e722240     	fcmp	d18, d18
     d04: 54025421     	b.ne	0x5788 <___pl_fn_0+0x5788>
     d08: 1e722240     	fcmp	d18, d18
     d0c: 3d816ff2     	str	q18, [sp, #0x5b0]
     d10: 54025221     	b.ne	0x5754 <___pl_fn_0+0x5754>
     d14: d280009c     	mov	x28, #0x4               ; =4
     d18: d2800016     	mov	x22, #0x0               ; =0
     d1c: ab160397     	adds	x23, x28, x22
     d20: f902cff6     	str	x22, [sp, #0x598]
     d24: f902d3fc     	str	x28, [sp, #0x5a0]
     d28: 9a9f77e0     	cset	x0, vs
     d2c: 72001c1f     	tst	w0, #0xff
     d30: 54024f81     	b.ne	0x5720 <___pl_fn_0+0x5720>
     d34: d280003b     	mov	x27, #0x1               ; =1
     d38: aa1b03e0     	mov	x0, x27
     d3c: f942cff6     	ldr	x22, [sp, #0x598]
     d40: ab16001b     	adds	x27, x0, x22
     d44: f902cbe0     	str	x0, [sp, #0x590]
     d48: 9a9f77e0     	cset	x0, vs
     d4c: 72001c1f     	tst	w0, #0xff
     d50: 54024ce1     	b.ne	0x56ec <___pl_fn_0+0x56ec>
     d54: b4024b3b     	cbz	x27, 0x56b8 <___pl_fn_0+0x56b8>
     d58: 52800034     	mov	w20, #0x1               ; =1
     d5c: f942cffc     	ldr	x28, [sp, #0x598]
     d60: 3dc16ff0     	ldr	q16, [sp, #0x5b0]
     d64: 3dc16fe0     	ldr	q0, [sp, #0x5b0]
     d68: 3d812fe0     	str	q0, [sp, #0x4b0]
     d6c: 3d8133e0     	str	q0, [sp, #0x4c0]
     d70: f100037f     	cmp	x27, #0x0
     d74: 5400008a     	b.ge	0xd84 <___pl_fn_0+0xd84>
     d78: eb17039f     	cmp	x28, x23
     d7c: 9a9fb7e0     	cset	x0, ge
     d80: 14000003     	b	0xd8c <___pl_fn_0+0xd8c>
     d84: eb17039f     	cmp	x28, x23
     d88: 9a9fc7e0     	cset	x0, le
     d8c: 72001c1f     	tst	w0, #0xff
     d90: 5400ec61     	b.ne	0x2b1c <___pl_fn_0+0x2b1c>
     d94: 5c0281e0     	ldr	d0, 0x5dd0 <___pl_fn_0+0x5dd0>
     d98: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
     d9c: 1e722000     	fcmp	d0, d18
     da0: 3d815fe0     	str	q0, [sp, #0x570]
     da4: 54022f40     	b.eq	0x538c <___pl_fn_0+0x538c>
     da8: 5c028140     	ldr	d0, 0x5dd0 <___pl_fn_0+0x5dd0>
     dac: 1e601a00     	fdiv	d0, d16, d0
     db0: 1e60c001     	fabs	d1, d0
     db4: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     db8: 9e670002     	fmov	d2, x0
     dbc: 1e622020     	fcmp	d1, d2
     dc0: 9a9f57e0     	cset	x0, mi
     dc4: 52000000     	eor	w0, w0, #0x1
     dc8: 72001c1f     	tst	w0, #0xff
     dcc: 54022c61     	b.ne	0x5358 <___pl_fn_0+0x5358>
     dd0: 1e603a40     	fsub	d0, d18, d0
     dd4: 3d816ff2     	str	q18, [sp, #0x5b0]
     dd8: 1e60c001     	fabs	d1, d0
     ddc: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     de0: 9e670002     	fmov	d2, x0
     de4: 1e622020     	fcmp	d1, d2
     de8: 9a9f57e0     	cset	x0, mi
     dec: 52000000     	eor	w0, w0, #0x1
     df0: 72001c1f     	tst	w0, #0xff
     df4: 54022981     	b.ne	0x5324 <___pl_fn_0+0x5324>
     df8: f942ebe0     	ldr	x0, [sp, #0x5d0]
     dfc: 34013ec0     	cbz	w0, 0x35d4 <___pl_fn_0+0x35d4>
     e00: f9424be0     	ldr	x0, [sp, #0x490]
     e04: f9400000     	ldr	x0, [x0]
     e08: f942ebe1     	ldr	x1, [sp, #0x5d0]
     e0c: 2a0103e1     	mov	w1, w1
     e10: 8b010c00     	add	x0, x0, x1, lsl #3
     e14: f9400801     	ldr	x1, [x0, #0x10]
     e18: b50000a1     	cbnz	x1, 0xe2c <___pl_fn_0+0xe2c>
     e1c: 140009ee     	b	0x35d4 <___pl_fn_0+0x35d4>
     e20: 3dc15fe0     	ldr	q0, [sp, #0x570]
     e24: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
     e28: 14000005     	b	0xe3c <___pl_fn_0+0xe3c>
     e2c: 4e083c01     	mov.d	x1, v0[0]
     e30: f9001401     	str	x1, [x0, #0x28]
     e34: 3dc15fe0     	ldr	q0, [sp, #0x570]
     e38: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
     e3c: 1e722000     	fcmp	d0, d18
     e40: 3d815fe0     	str	q0, [sp, #0x570]
     e44: 54022560     	b.eq	0x52f0 <___pl_fn_0+0x52f0>
     e48: 5c027c40     	ldr	d0, 0x5dd0 <___pl_fn_0+0x5dd0>
     e4c: 3dc12ff1     	ldr	q17, [sp, #0x4b0]
     e50: 1e601a20     	fdiv	d0, d17, d0
     e54: 1e60c001     	fabs	d1, d0
     e58: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     e5c: 9e670002     	fmov	d2, x0
     e60: 1e622020     	fcmp	d1, d2
     e64: 9a9f57e0     	cset	x0, mi
     e68: 52000000     	eor	w0, w0, #0x1
     e6c: 72001c1f     	tst	w0, #0xff
     e70: 54022261     	b.ne	0x52bc <___pl_fn_0+0x52bc>
     e74: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
     e78: 1e603a40     	fsub	d0, d18, d0
     e7c: 1e60c001     	fabs	d1, d0
     e80: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     e84: 9e670002     	fmov	d2, x0
     e88: 1e622020     	fcmp	d1, d2
     e8c: 9a9f57e0     	cset	x0, mi
     e90: 52000000     	eor	w0, w0, #0x1
     e94: 72001c1f     	tst	w0, #0xff
     e98: 54021f81     	b.ne	0x5288 <___pl_fn_0+0x5288>
     e9c: f942e7e0     	ldr	x0, [sp, #0x5c8]
     ea0: 34013b40     	cbz	w0, 0x3608 <___pl_fn_0+0x3608>
     ea4: f9424be0     	ldr	x0, [sp, #0x490]
     ea8: f9400004     	ldr	x4, [x0]
     eac: f942e7e0     	ldr	x0, [sp, #0x5c8]
     eb0: 2a0003e5     	mov	w5, w0
     eb4: 8b050c84     	add	x4, x4, x5, lsl #3
     eb8: f9400885     	ldr	x5, [x4, #0x10]
     ebc: b50000a5     	cbnz	x5, 0xed0 <___pl_fn_0+0xed0>
     ec0: 140009d2     	b	0x3608 <___pl_fn_0+0x3608>
     ec4: 3dc15fe0     	ldr	q0, [sp, #0x570]
     ec8: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
     ecc: 14000005     	b	0xee0 <___pl_fn_0+0xee0>
     ed0: 4e083c0b     	mov.d	x11, v0[0]
     ed4: f900148b     	str	x11, [x4, #0x28]
     ed8: 3dc15fe0     	ldr	q0, [sp, #0x570]
     edc: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
     ee0: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
     ee4: 1e722000     	fcmp	d0, d18
     ee8: 54021b60     	b.eq	0x5254 <___pl_fn_0+0x5254>
     eec: 5c027730     	ldr	d16, 0x5dd0 <___pl_fn_0+0x5dd0>
     ef0: 3dc133f2     	ldr	q18, [sp, #0x4c0]
     ef4: 1e701a50     	fdiv	d16, d18, d16
     ef8: 1e60c211     	fabs	d17, d16
     efc: d2effe0e     	mov	x14, #0x7ff0000000000000 ; =9218868437227405312
     f00: 9e6701d2     	fmov	d18, x14
     f04: 1e722220     	fcmp	d17, d18
     f08: 9a9f57e0     	cset	x0, mi
     f0c: 52000000     	eor	w0, w0, #0x1
     f10: 72001c1f     	tst	w0, #0xff
     f14: 54021861     	b.ne	0x5220 <___pl_fn_0+0x5220>
     f18: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
     f1c: 1e703a52     	fsub	d18, d18, d16
     f20: 1e60c253     	fabs	d19, d18
     f24: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
     f28: 9e670014     	fmov	d20, x0
     f2c: 1e742260     	fcmp	d19, d20
     f30: 9a9f57e0     	cset	x0, mi
     f34: 52000000     	eor	w0, w0, #0x1
     f38: 72001c1f     	tst	w0, #0xff
     f3c: 54021581     	b.ne	0x51ec <___pl_fn_0+0x51ec>
     f40: f942e3e0     	ldr	x0, [sp, #0x5c0]
     f44: 340137c0     	cbz	w0, 0x363c <___pl_fn_0+0x363c>
     f48: f9424be0     	ldr	x0, [sp, #0x490]
     f4c: f9400000     	ldr	x0, [x0]
     f50: f942e3ef     	ldr	x15, [sp, #0x5c0]
     f54: 2a0f03e1     	mov	w1, w15
     f58: 8b010c00     	add	x0, x0, x1, lsl #3
     f5c: f9400801     	ldr	x1, [x0, #0x10]
     f60: b5000081     	cbnz	x1, 0xf70 <___pl_fn_0+0xf70>
     f64: 140009b6     	b	0x363c <___pl_fn_0+0x363c>
     f68: f942cff6     	ldr	x22, [sp, #0x598]
     f6c: 14000004     	b	0xf7c <___pl_fn_0+0xf7c>
     f70: 4e083e41     	mov.d	x1, v18[0]
     f74: f9001401     	str	x1, [x0, #0x28]
     f78: f942cff6     	ldr	x22, [sp, #0x598]
     f7c: f942cff6     	ldr	x22, [sp, #0x598]
     f80: ab160340     	adds	x0, x26, x22
     f84: f902c7e0     	str	x0, [sp, #0x588]
     f88: 9a9f77e0     	cset	x0, vs
     f8c: 72001c1f     	tst	w0, #0xff
     f90: 54021141     	b.ne	0x51b8 <___pl_fn_0+0x51b8>
     f94: f942cff6     	ldr	x22, [sp, #0x598]
     f98: f942cbfb     	ldr	x27, [sp, #0x590]
     f9c: ab160376     	adds	x22, x27, x22
     fa0: f902c3f6     	str	x22, [sp, #0x580]
     fa4: 9a9f77e0     	cset	x0, vs
     fa8: 72001c1f     	tst	w0, #0xff
     fac: 54020ec1     	b.ne	0x5184 <___pl_fn_0+0x5184>
     fb0: f942c3f6     	ldr	x22, [sp, #0x580]
     fb4: b4020cf6     	cbz	x22, 0x5150 <___pl_fn_0+0x5150>
     fb8: f902c3f6     	str	x22, [sp, #0x580]
     fbc: d2efff00     	mov	x0, #0x7ff8000000000000 ; =9221120237041090560
     fc0: 9e670000     	fmov	d0, x0
     fc4: 3d813fe0     	str	q0, [sp, #0x4f0]
     fc8: 52800020     	mov	w0, #0x1                ; =1
     fcc: 52800016     	mov	w22, #0x0               ; =0
     fd0: f942c3e1     	ldr	x1, [sp, #0x580]
     fd4: f942cffa     	ldr	x26, [sp, #0x598]
     fd8: f942cbfb     	ldr	x27, [sp, #0x590]
     fdc: 3d8143e0     	str	q0, [sp, #0x500]
     fe0: 3d8147e0     	str	q0, [sp, #0x510]
     fe4: 3d814be0     	str	q0, [sp, #0x520]
     fe8: 3d814fe0     	str	q0, [sp, #0x530]
     fec: 3d8153e0     	str	q0, [sp, #0x540]
     ff0: f100003f     	cmp	x1, #0x0
     ff4: 540000aa     	b.ge	0x1008 <___pl_fn_0+0x1008>
     ff8: f942c7fc     	ldr	x28, [sp, #0x588]
     ffc: eb1c037f     	cmp	x27, x28
    1000: 9a9fb7e0     	cset	x0, ge
    1004: 14000004     	b	0x1014 <___pl_fn_0+0x1014>
    1008: f942c7fc     	ldr	x28, [sp, #0x588]
    100c: eb1c037f     	cmp	x27, x28
    1010: 9a9fc7e0     	cset	x0, le
    1014: 72001c1f     	tst	w0, #0xff
    1018: 54004ec1     	b.ne	0x19f0 <___pl_fn_0+0x19f0>
    101c: 3dc16fe0     	ldr	q0, [sp, #0x5b0]
    1020: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
    1024: 1e602240     	fcmp	d18, d0
    1028: 54018121     	b.ne	0x404c <___pl_fn_0+0x404c>
    102c: f942cfe0     	ldr	x0, [sp, #0x598]
    1030: f942d3fc     	ldr	x28, [sp, #0x5a0]
    1034: ab000380     	adds	x0, x28, x0
    1038: aa0003f4     	mov	x20, x0
    103c: 9a9f77e0     	cset	x0, vs
    1040: 72001c1f     	tst	w0, #0xff
    1044: 54017ea1     	b.ne	0x4018 <___pl_fn_0+0x4018>
    1048: f942cfe0     	ldr	x0, [sp, #0x598]
    104c: f942cbfb     	ldr	x27, [sp, #0x590]
    1050: ab00037c     	adds	x28, x27, x0
    1054: 9a9f77e0     	cset	x0, vs
    1058: 72001c1f     	tst	w0, #0xff
    105c: 54017c41     	b.ne	0x3fe4 <___pl_fn_0+0x3fe4>
    1060: b4017a9c     	cbz	x28, 0x3fb0 <___pl_fn_0+0x3fb0>
    1064: 52800020     	mov	w0, #0x1                ; =1
    1068: f942cffb     	ldr	x27, [sp, #0x598]
    106c: 3dc16ff8     	ldr	q24, [sp, #0x5b0]
    1070: f100039f     	cmp	x28, #0x0
    1074: 540000aa     	b.ge	0x1088 <___pl_fn_0+0x1088>
    1078: aa1403e0     	mov	x0, x20
    107c: eb00037f     	cmp	x27, x0
    1080: 9a9fb7e1     	cset	x1, ge
    1084: 14000004     	b	0x1094 <___pl_fn_0+0x1094>
    1088: aa1403e0     	mov	x0, x20
    108c: eb00037f     	cmp	x27, x0
    1090: 9a9fc7e1     	cset	x1, le
    1094: 72001c3f     	tst	w1, #0xff
    1098: 540004e1     	b.ne	0x1134 <___pl_fn_0+0x1134>
    109c: 5c027220     	ldr	d0, 0x5ee0 <___pl_fn_0+0x5ee0>
    10a0: 1e600b00     	fmul	d0, d24, d0
    10a4: 1e60c001     	fabs	d1, d0
    10a8: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    10ac: 9e670002     	fmov	d2, x0
    10b0: 1e622020     	fcmp	d1, d2
    10b4: 9a9f57e0     	cset	x0, mi
    10b8: 52000000     	eor	w0, w0, #0x1
    10bc: 72001c1f     	tst	w0, #0xff
    10c0: 54012d81     	b.ne	0x3670 <___pl_fn_0+0x3670>
    10c4: 52800c21     	mov	w1, #0x61               ; =97
    10c8: 528000a2     	mov	w2, #0x5                ; =5
    10cc: 4e083c03     	mov.d	x3, v0[0]
    10d0: 90000004     	adrp	x4, 0x1000 <___pl_fn_0+0x1000>
    10d4: f9400084     	ldr	x4, [x4]
    10d8: f9424be0     	ldr	x0, [sp, #0x490]
    10dc: d63f0080     	blr	x4
    10e0: 35026600     	cbnz	w0, 0x5da0 <___pl_fn_0+0x5da0>
    10e4: f9424be0     	ldr	x0, [sp, #0x490]
    10e8: f9401802     	ldr	x2, [x0, #0x30]
    10ec: 52800c41     	mov	w1, #0x62               ; =98
    10f0: 52802003     	mov	w3, #0x100              ; =256
    10f4: 90000004     	adrp	x4, 0x1000 <___pl_fn_0+0x1000>
    10f8: f9400084     	ldr	x4, [x4]
    10fc: d63f0080     	blr	x4
    1100: 35026500     	cbnz	w0, 0x5da0 <___pl_fn_0+0x5da0>
    1104: f9424be0     	ldr	x0, [sp, #0x490]
    1108: b9401006     	ldr	w6, [x0, #0x10]
    110c: 510004c6     	sub	w6, w6, #0x1
    1110: b9001006     	str	w6, [x0, #0x10]
    1114: 911783ff     	add	sp, sp, #0x5e0
    1118: a8c153f3     	ldp	x19, x20, [sp], #0x10
    111c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    1120: a8c163f7     	ldp	x23, x24, [sp], #0x10
    1124: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    1128: a8c173fb     	ldp	x27, x28, [sp], #0x10
    112c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    1130: d65f03c0     	ret
    1134: 3d8137f8     	str	q24, [sp, #0x4d0]
    1138: 34012b79     	cbz	w25, 0x36a4 <___pl_fn_0+0x36a4>
    113c: f9424be0     	ldr	x0, [sp, #0x490]
    1140: f940000b     	ldr	x11, [x0]
    1144: 2a1903ec     	mov	w12, w25
    1148: 8b0c0d6b     	add	x11, x11, x12, lsl #3
    114c: f940096c     	ldr	x12, [x11, #0x10]
    1150: eb0c037f     	cmp	x27, x12
    1154: 54012a82     	b.hs	0x36a4 <___pl_fn_0+0x36a4>
    1158: 8b1b0d6e     	add	x14, x11, x27, lsl #3
    115c: fd4015d3     	ldr	d19, [x14, #0x28]
    1160: 1e732260     	fcmp	d19, d19
    1164: 540000a7     	b.vc	0x1178 <___pl_fn_0+0x1178>
    1168: 1400094f     	b	0x36a4 <___pl_fn_0+0x36a4>
    116c: f9424be0     	ldr	x0, [sp, #0x490]
    1170: f9401800     	ldr	x0, [x0, #0x30]
    1174: 9e670013     	fmov	d19, x0
    1178: 1e6c1016     	fmov	d22, #0.50000000
    117c: 1e730ad7     	fmul	d23, d22, d19
    1180: 1e60c2f6     	fabs	d22, d23
    1184: 3d815ff7     	str	q23, [sp, #0x570]
    1188: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    118c: 9e670017     	fmov	d23, x0
    1190: 1e7722c0     	fcmp	d22, d23
    1194: 9a9f57e0     	cset	x0, mi
    1198: 52000000     	eor	w0, w0, #0x1
    119c: 72001c1f     	tst	w0, #0xff
    11a0: 54016ee1     	b.ne	0x3f7c <___pl_fn_0+0x3f7c>
    11a4: f942ebe0     	ldr	x0, [sp, #0x5d0]
    11a8: 34012920     	cbz	w0, 0x36cc <___pl_fn_0+0x36cc>
    11ac: f9424be0     	ldr	x0, [sp, #0x490]
    11b0: f9400000     	ldr	x0, [x0]
    11b4: f942ebe1     	ldr	x1, [sp, #0x5d0]
    11b8: 2a0103e1     	mov	w1, w1
    11bc: 8b010c00     	add	x0, x0, x1, lsl #3
    11c0: f9400801     	ldr	x1, [x0, #0x10]
    11c4: eb01037f     	cmp	x27, x1
    11c8: 54012822     	b.hs	0x36cc <___pl_fn_0+0x36cc>
    11cc: 8b1b0c00     	add	x0, x0, x27, lsl #3
    11d0: fd401400     	ldr	d0, [x0, #0x28]
    11d4: 1e602000     	fcmp	d0, d0
    11d8: 54000107     	b.vc	0x11f8 <___pl_fn_0+0x11f8>
    11dc: 1400093c     	b	0x36cc <___pl_fn_0+0x36cc>
    11e0: f9424be0     	ldr	x0, [sp, #0x490]
    11e4: f9401800     	ldr	x0, [x0, #0x30]
    11e8: 9e670000     	fmov	d0, x0
    11ec: 3d813be0     	str	q0, [sp, #0x4e0]
    11f0: f942ebe0     	ldr	x0, [sp, #0x5d0]
    11f4: 14000003     	b	0x1200 <___pl_fn_0+0x1200>
    11f8: 3d813be0     	str	q0, [sp, #0x4e0]
    11fc: f942ebe0     	ldr	x0, [sp, #0x5d0]
    1200: f942ebe0     	ldr	x0, [sp, #0x5d0]
    1204: 34012780     	cbz	w0, 0x36f4 <___pl_fn_0+0x36f4>
    1208: f9424be0     	ldr	x0, [sp, #0x490]
    120c: f9400000     	ldr	x0, [x0]
    1210: f942ebe1     	ldr	x1, [sp, #0x5d0]
    1214: 2a0103e1     	mov	w1, w1
    1218: 8b010c00     	add	x0, x0, x1, lsl #3
    121c: f9400801     	ldr	x1, [x0, #0x10]
    1220: eb01037f     	cmp	x27, x1
    1224: 54012682     	b.hs	0x36f4 <___pl_fn_0+0x36f4>
    1228: 8b1b0c00     	add	x0, x0, x27, lsl #3
    122c: fd401412     	ldr	d18, [x0, #0x28]
    1230: 1e722240     	fcmp	d18, d18
    1234: 540000e7     	b.vc	0x1250 <___pl_fn_0+0x1250>
    1238: 1400092f     	b	0x36f4 <___pl_fn_0+0x36f4>
    123c: f9424be0     	ldr	x0, [sp, #0x490]
    1240: f9401800     	ldr	x0, [x0, #0x30]
    1244: 9e670012     	fmov	d18, x0
    1248: 3dc13be0     	ldr	q0, [sp, #0x4e0]
    124c: 14000002     	b	0x1254 <___pl_fn_0+0x1254>
    1250: 3dc13be0     	ldr	q0, [sp, #0x4e0]
    1254: 1e720801     	fmul	d1, d0, d18
    1258: 1e60c020     	fabs	d0, d1
    125c: 3d815be1     	str	q1, [sp, #0x560]
    1260: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1264: 9e670001     	fmov	d1, x0
    1268: 1e612000     	fcmp	d0, d1
    126c: 9a9f57e0     	cset	x0, mi
    1270: 52000000     	eor	w0, w0, #0x1
    1274: 72001c1f     	tst	w0, #0xff
    1278: 54016681     	b.ne	0x3f48 <___pl_fn_0+0x3f48>
    127c: f942e7e0     	ldr	x0, [sp, #0x5c8]
    1280: 340124e0     	cbz	w0, 0x371c <___pl_fn_0+0x371c>
    1284: f9424be0     	ldr	x0, [sp, #0x490]
    1288: f9400000     	ldr	x0, [x0]
    128c: f942e7e1     	ldr	x1, [sp, #0x5c8]
    1290: 2a0103e1     	mov	w1, w1
    1294: 8b010c00     	add	x0, x0, x1, lsl #3
    1298: f9400801     	ldr	x1, [x0, #0x10]
    129c: eb01037f     	cmp	x27, x1
    12a0: 540123e2     	b.hs	0x371c <___pl_fn_0+0x371c>
    12a4: 8b1b0c00     	add	x0, x0, x27, lsl #3
    12a8: fd401400     	ldr	d0, [x0, #0x28]
    12ac: 1e602000     	fcmp	d0, d0
    12b0: 54000107     	b.vc	0x12d0 <___pl_fn_0+0x12d0>
    12b4: 1400091a     	b	0x371c <___pl_fn_0+0x371c>
    12b8: f9424be0     	ldr	x0, [sp, #0x490]
    12bc: f9401802     	ldr	x2, [x0, #0x30]
    12c0: 9e670040     	fmov	d0, x2
    12c4: 3d813be0     	str	q0, [sp, #0x4e0]
    12c8: f942e7e0     	ldr	x0, [sp, #0x5c8]
    12cc: 14000003     	b	0x12d8 <___pl_fn_0+0x12d8>
    12d0: 3d813be0     	str	q0, [sp, #0x4e0]
    12d4: f942e7e0     	ldr	x0, [sp, #0x5c8]
    12d8: f942e7e0     	ldr	x0, [sp, #0x5c8]
    12dc: 34012340     	cbz	w0, 0x3744 <___pl_fn_0+0x3744>
    12e0: f9424be0     	ldr	x0, [sp, #0x490]
    12e4: f9400006     	ldr	x6, [x0]
    12e8: f942e7e0     	ldr	x0, [sp, #0x5c8]
    12ec: 2a0003e7     	mov	w7, w0
    12f0: 8b070cc6     	add	x6, x6, x7, lsl #3
    12f4: f94008c7     	ldr	x7, [x6, #0x10]
    12f8: eb07037f     	cmp	x27, x7
    12fc: 54012242     	b.hs	0x3744 <___pl_fn_0+0x3744>
    1300: 8b1b0cc9     	add	x9, x6, x27, lsl #3
    1304: fd401530     	ldr	d16, [x9, #0x28]
    1308: 1e702200     	fcmp	d16, d16
    130c: 540000e7     	b.vc	0x1328 <___pl_fn_0+0x1328>
    1310: 1400090d     	b	0x3744 <___pl_fn_0+0x3744>
    1314: f9424be0     	ldr	x0, [sp, #0x490]
    1318: f940180f     	ldr	x15, [x0, #0x30]
    131c: 9e6701f0     	fmov	d16, x15
    1320: 3dc13be0     	ldr	q0, [sp, #0x4e0]
    1324: 14000002     	b	0x132c <___pl_fn_0+0x132c>
    1328: 3dc13be0     	ldr	q0, [sp, #0x4e0]
    132c: 1e700811     	fmul	d17, d0, d16
    1330: 1e60c232     	fabs	d18, d17
    1334: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1338: 9e670013     	fmov	d19, x0
    133c: 1e732240     	fcmp	d18, d19
    1340: 9a9f57e0     	cset	x0, mi
    1344: 52000000     	eor	w0, w0, #0x1
    1348: 72001c1f     	tst	w0, #0xff
    134c: 54015e41     	b.ne	0x3f14 <___pl_fn_0+0x3f14>
    1350: 3dc15be0     	ldr	q0, [sp, #0x560]
    1354: 1e712815     	fadd	d21, d0, d17
    1358: 1e60c2b4     	fabs	d20, d21
    135c: 3d815bf5     	str	q21, [sp, #0x560]
    1360: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1364: 9e670015     	fmov	d21, x0
    1368: 1e752280     	fcmp	d20, d21
    136c: 9a9f57e0     	cset	x0, mi
    1370: 52000000     	eor	w0, w0, #0x1
    1374: 72001c1f     	tst	w0, #0xff
    1378: 54015b41     	b.ne	0x3ee0 <___pl_fn_0+0x3ee0>
    137c: f942e3e0     	ldr	x0, [sp, #0x5c0]
    1380: 34011f60     	cbz	w0, 0x376c <___pl_fn_0+0x376c>
    1384: f9424be0     	ldr	x0, [sp, #0x490]
    1388: f9400000     	ldr	x0, [x0]
    138c: f942e3e1     	ldr	x1, [sp, #0x5c0]
    1390: 2a0103e1     	mov	w1, w1
    1394: 8b010c00     	add	x0, x0, x1, lsl #3
    1398: f9400801     	ldr	x1, [x0, #0x10]
    139c: eb01037f     	cmp	x27, x1
    13a0: 54011e62     	b.hs	0x376c <___pl_fn_0+0x376c>
    13a4: 8b1b0c00     	add	x0, x0, x27, lsl #3
    13a8: fd401400     	ldr	d0, [x0, #0x28]
    13ac: 1e602000     	fcmp	d0, d0
    13b0: 54000107     	b.vc	0x13d0 <___pl_fn_0+0x13d0>
    13b4: 140008ee     	b	0x376c <___pl_fn_0+0x376c>
    13b8: f9424be0     	ldr	x0, [sp, #0x490]
    13bc: f9401800     	ldr	x0, [x0, #0x30]
    13c0: 9e670000     	fmov	d0, x0
    13c4: 3d813be0     	str	q0, [sp, #0x4e0]
    13c8: f942e3e0     	ldr	x0, [sp, #0x5c0]
    13cc: 14000003     	b	0x13d8 <___pl_fn_0+0x13d8>
    13d0: 3d813be0     	str	q0, [sp, #0x4e0]
    13d4: f942e3e0     	ldr	x0, [sp, #0x5c0]
    13d8: f942e3e0     	ldr	x0, [sp, #0x5c0]
    13dc: 34011dc0     	cbz	w0, 0x3794 <___pl_fn_0+0x3794>
    13e0: f9424be0     	ldr	x0, [sp, #0x490]
    13e4: f9400000     	ldr	x0, [x0]
    13e8: f942e3e1     	ldr	x1, [sp, #0x5c0]
    13ec: 2a0103e1     	mov	w1, w1
    13f0: 8b010c00     	add	x0, x0, x1, lsl #3
    13f4: f9400801     	ldr	x1, [x0, #0x10]
    13f8: eb01037f     	cmp	x27, x1
    13fc: 54011cc2     	b.hs	0x3794 <___pl_fn_0+0x3794>
    1400: 8b1b0c00     	add	x0, x0, x27, lsl #3
    1404: fd401417     	ldr	d23, [x0, #0x28]
    1408: 1e7722e0     	fcmp	d23, d23
    140c: 540000e7     	b.vc	0x1428 <___pl_fn_0+0x1428>
    1410: 140008e1     	b	0x3794 <___pl_fn_0+0x3794>
    1414: f9424be0     	ldr	x0, [sp, #0x490]
    1418: f9401800     	ldr	x0, [x0, #0x30]
    141c: 9e670017     	fmov	d23, x0
    1420: 3dc13be0     	ldr	q0, [sp, #0x4e0]
    1424: 14000002     	b	0x142c <___pl_fn_0+0x142c>
    1428: 3dc13be0     	ldr	q0, [sp, #0x4e0]
    142c: 1e770800     	fmul	d0, d0, d23
    1430: 1e60c001     	fabs	d1, d0
    1434: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1438: 9e670002     	fmov	d2, x0
    143c: 1e622020     	fcmp	d1, d2
    1440: 9a9f57e0     	cset	x0, mi
    1444: 52000000     	eor	w0, w0, #0x1
    1448: 72001c1f     	tst	w0, #0xff
    144c: 54015301     	b.ne	0x3eac <___pl_fn_0+0x3eac>
    1450: 3dc15bf4     	ldr	q20, [sp, #0x560]
    1454: 1e602a80     	fadd	d0, d20, d0
    1458: 1e60c001     	fabs	d1, d0
    145c: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1460: 9e670002     	fmov	d2, x0
    1464: 1e622020     	fcmp	d1, d2
    1468: 9a9f57e0     	cset	x0, mi
    146c: 52000000     	eor	w0, w0, #0x1
    1470: 72001c1f     	tst	w0, #0xff
    1474: 54015021     	b.ne	0x3e78 <___pl_fn_0+0x3e78>
    1478: 3dc15ff6     	ldr	q22, [sp, #0x570]
    147c: 1e600ac0     	fmul	d0, d22, d0
    1480: 1e60c001     	fabs	d1, d0
    1484: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1488: 9e670002     	fmov	d2, x0
    148c: 1e622020     	fcmp	d1, d2
    1490: 9a9f57e0     	cset	x0, mi
    1494: 52000000     	eor	w0, w0, #0x1
    1498: 72001c1f     	tst	w0, #0xff
    149c: 54014d41     	b.ne	0x3e44 <___pl_fn_0+0x3e44>
    14a0: 3dc137f8     	ldr	q24, [sp, #0x4d0]
    14a4: 1e602b18     	fadd	d24, d24, d0
    14a8: 1e60c300     	fabs	d0, d24
    14ac: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    14b0: 9e670001     	fmov	d1, x0
    14b4: 1e612000     	fcmp	d0, d1
    14b8: 9a9f57e0     	cset	x0, mi
    14bc: 52000000     	eor	w0, w0, #0x1
    14c0: 72001c1f     	tst	w0, #0xff
    14c4: 54014a61     	b.ne	0x3e10 <___pl_fn_0+0x3e10>
    14c8: 1e782300     	fcmp	d24, d24
    14cc: 3d8137f8     	str	q24, [sp, #0x4d0]
    14d0: 54014861     	b.ne	0x3ddc <___pl_fn_0+0x3ddc>
    14d4: f942cbe7     	ldr	x7, [sp, #0x590]
    14d8: ab07037a     	adds	x26, x27, x7
    14dc: 9a9f77e1     	cset	x1, vs
    14e0: 72001c3f     	tst	w1, #0xff
    14e4: 54014621     	b.ne	0x3da8 <___pl_fn_0+0x3da8>
    14e8: f942d3e0     	ldr	x0, [sp, #0x5a0]
    14ec: f942cff6     	ldr	x22, [sp, #0x598]
    14f0: ab160017     	adds	x23, x0, x22
    14f4: 9a9f77e3     	cset	x3, vs
    14f8: 72001c7f     	tst	w3, #0xff
    14fc: 540143c1     	b.ne	0x3d74 <___pl_fn_0+0x3d74>
    1500: f942cbe0     	ldr	x0, [sp, #0x590]
    1504: f942cff6     	ldr	x22, [sp, #0x598]
    1508: ab160013     	adds	x19, x0, x22
    150c: 9a9f77e5     	cset	x5, vs
    1510: 72001cbf     	tst	w5, #0xff
    1514: 54014161     	b.ne	0x3d40 <___pl_fn_0+0x3d40>
    1518: b4013fb3     	cbz	x19, 0x3d0c <___pl_fn_0+0x3d0c>
    151c: 52800036     	mov	w22, #0x1               ; =1
    1520: f100027f     	cmp	x19, #0x0
    1524: 5400008a     	b.ge	0x1534 <___pl_fn_0+0x1534>
    1528: eb17035f     	cmp	x26, x23
    152c: 9a9fb7e0     	cset	x0, ge
    1530: 14000003     	b	0x153c <___pl_fn_0+0x153c>
    1534: eb17035f     	cmp	x26, x23
    1538: 9a9fc7e0     	cset	x0, le
    153c: 72001c1f     	tst	w0, #0xff
    1540: 54000101     	b.ne	0x1560 <___pl_fn_0+0x1560>
    1544: ab1c037b     	adds	x27, x27, x28
    1548: 9a9f77e0     	cset	x0, vs
    154c: 72001c1f     	tst	w0, #0xff
    1550: 54011361     	b.ne	0x37bc <___pl_fn_0+0x37bc>
    1554: 52800020     	mov	w0, #0x1                ; =1
    1558: 3dc137f8     	ldr	q24, [sp, #0x4d0]
    155c: 17fffec5     	b	0x1070 <___pl_fn_0+0x1070>
    1560: f942efe0     	ldr	x0, [sp, #0x5d8]
    1564: 34011460     	cbz	w0, 0x37f0 <___pl_fn_0+0x37f0>
    1568: f9424be0     	ldr	x0, [sp, #0x490]
    156c: f9400000     	ldr	x0, [x0]
    1570: f942efe5     	ldr	x5, [sp, #0x5d8]
    1574: 2a0503e1     	mov	w1, w5
    1578: 8b010c00     	add	x0, x0, x1, lsl #3
    157c: f9400801     	ldr	x1, [x0, #0x10]
    1580: eb01037f     	cmp	x27, x1
    1584: 54011362     	b.hs	0x37f0 <___pl_fn_0+0x37f0>
    1588: 8b1b0c00     	add	x0, x0, x27, lsl #3
    158c: fd401404     	ldr	d4, [x0, #0x28]
    1590: 1e642080     	fcmp	d4, d4
    1594: 54000107     	b.vc	0x15b4 <___pl_fn_0+0x15b4>
    1598: 14000896     	b	0x37f0 <___pl_fn_0+0x37f0>
    159c: f9424be0     	ldr	x0, [sp, #0x490]
    15a0: f9401800     	ldr	x0, [x0, #0x30]
    15a4: 9e670004     	fmov	d4, x0
    15a8: 3d813be4     	str	q4, [sp, #0x4e0]
    15ac: f942efe0     	ldr	x0, [sp, #0x5d8]
    15b0: 14000003     	b	0x15bc <___pl_fn_0+0x15bc>
    15b4: 3d813be4     	str	q4, [sp, #0x4e0]
    15b8: f942efe0     	ldr	x0, [sp, #0x5d8]
    15bc: f942efe0     	ldr	x0, [sp, #0x5d8]
    15c0: 340112c0     	cbz	w0, 0x3818 <___pl_fn_0+0x3818>
    15c4: f9424be0     	ldr	x0, [sp, #0x490]
    15c8: f9400000     	ldr	x0, [x0]
    15cc: f942efe1     	ldr	x1, [sp, #0x5d8]
    15d0: 2a0103e1     	mov	w1, w1
    15d4: 8b010c00     	add	x0, x0, x1, lsl #3
    15d8: f9400801     	ldr	x1, [x0, #0x10]
    15dc: eb01035f     	cmp	x26, x1
    15e0: 540111c2     	b.hs	0x3818 <___pl_fn_0+0x3818>
    15e4: 8b1a0c00     	add	x0, x0, x26, lsl #3
    15e8: fd40141e     	ldr	d30, [x0, #0x28]
    15ec: 1e7e23c0     	fcmp	d30, d30
    15f0: 540000e7     	b.vc	0x160c <___pl_fn_0+0x160c>
    15f4: 14000889     	b	0x3818 <___pl_fn_0+0x3818>
    15f8: f9424be0     	ldr	x0, [sp, #0x490]
    15fc: f9401800     	ldr	x0, [x0, #0x30]
    1600: 9e67001e     	fmov	d30, x0
    1604: 3dc13be4     	ldr	q4, [sp, #0x4e0]
    1608: 14000002     	b	0x1610 <___pl_fn_0+0x1610>
    160c: 3dc13be4     	ldr	q4, [sp, #0x4e0]
    1610: 1e7e3880     	fsub	d0, d4, d30
    1614: 1e60c001     	fabs	d1, d0
    1618: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    161c: 9e670002     	fmov	d2, x0
    1620: 1e622020     	fcmp	d1, d2
    1624: 9a9f57e0     	cset	x0, mi
    1628: 52000000     	eor	w0, w0, #0x1
    162c: 72001c1f     	tst	w0, #0xff
    1630: 54013541     	b.ne	0x3cd8 <___pl_fn_0+0x3cd8>
    1634: 1e602000     	fcmp	d0, d0
    1638: 3d813fe0     	str	q0, [sp, #0x4f0]
    163c: 54013341     	b.ne	0x3ca4 <___pl_fn_0+0x3ca4>
    1640: 34011018     	cbz	w24, 0x3840 <___pl_fn_0+0x3840>
    1644: f9424be0     	ldr	x0, [sp, #0x490]
    1648: f9400000     	ldr	x0, [x0]
    164c: 2a1803e1     	mov	w1, w24
    1650: 8b010c00     	add	x0, x0, x1, lsl #3
    1654: f9400801     	ldr	x1, [x0, #0x10]
    1658: eb01037f     	cmp	x27, x1
    165c: 54010f22     	b.hs	0x3840 <___pl_fn_0+0x3840>
    1660: 8b1b0c00     	add	x0, x0, x27, lsl #3
    1664: fd401404     	ldr	d4, [x0, #0x28]
    1668: 1e642080     	fcmp	d4, d4
    166c: 540000e7     	b.vc	0x1688 <___pl_fn_0+0x1688>
    1670: 14000874     	b	0x3840 <___pl_fn_0+0x3840>
    1674: f9424be0     	ldr	x0, [sp, #0x490]
    1678: f9401800     	ldr	x0, [x0, #0x30]
    167c: 9e670004     	fmov	d4, x0
    1680: 3d813be4     	str	q4, [sp, #0x4e0]
    1684: 14000002     	b	0x168c <___pl_fn_0+0x168c>
    1688: 3d813be4     	str	q4, [sp, #0x4e0]
    168c: 34010ef8     	cbz	w24, 0x3868 <___pl_fn_0+0x3868>
    1690: f9424be0     	ldr	x0, [sp, #0x490]
    1694: f9400003     	ldr	x3, [x0]
    1698: 2a1803e4     	mov	w4, w24
    169c: 8b040c63     	add	x3, x3, x4, lsl #3
    16a0: f9400864     	ldr	x4, [x3, #0x10]
    16a4: eb04035f     	cmp	x26, x4
    16a8: 54010e02     	b.hs	0x3868 <___pl_fn_0+0x3868>
    16ac: 8b1a0c66     	add	x6, x3, x26, lsl #3
    16b0: fd4014de     	ldr	d30, [x6, #0x28]
    16b4: 1e7e23c0     	fcmp	d30, d30
    16b8: 540000e7     	b.vc	0x16d4 <___pl_fn_0+0x16d4>
    16bc: 1400086b     	b	0x3868 <___pl_fn_0+0x3868>
    16c0: f9424be0     	ldr	x0, [sp, #0x490]
    16c4: f940180c     	ldr	x12, [x0, #0x30]
    16c8: 9e67019e     	fmov	d30, x12
    16cc: 3dc13be4     	ldr	q4, [sp, #0x4e0]
    16d0: 14000002     	b	0x16d8 <___pl_fn_0+0x16d8>
    16d4: 3dc13be4     	ldr	q4, [sp, #0x4e0]
    16d8: 1e7e3880     	fsub	d0, d4, d30
    16dc: 1e60c010     	fabs	d16, d0
    16e0: d2effe0d     	mov	x13, #0x7ff0000000000000 ; =9218868437227405312
    16e4: 9e6701b1     	fmov	d17, x13
    16e8: 1e712200     	fcmp	d16, d17
    16ec: 9a9f57ef     	cset	x15, mi
    16f0: 520001ef     	eor	w15, w15, #0x1
    16f4: 72001dff     	tst	w15, #0xff
    16f8: 54012bc1     	b.ne	0x3c70 <___pl_fn_0+0x3c70>
    16fc: 1e602000     	fcmp	d0, d0
    1700: 3d8143e0     	str	q0, [sp, #0x500]
    1704: 540129c1     	b.ne	0x3c3c <___pl_fn_0+0x3c3c>
    1708: 34010c55     	cbz	w21, 0x3890 <___pl_fn_0+0x3890>
    170c: f9424be0     	ldr	x0, [sp, #0x490]
    1710: f9400000     	ldr	x0, [x0]
    1714: 2a1503e1     	mov	w1, w21
    1718: 8b010c00     	add	x0, x0, x1, lsl #3
    171c: f9400801     	ldr	x1, [x0, #0x10]
    1720: eb01037f     	cmp	x27, x1
    1724: 54010b62     	b.hs	0x3890 <___pl_fn_0+0x3890>
    1728: 8b1b0c00     	add	x0, x0, x27, lsl #3
    172c: fd401404     	ldr	d4, [x0, #0x28]
    1730: 1e642080     	fcmp	d4, d4
    1734: 540000e7     	b.vc	0x1750 <___pl_fn_0+0x1750>
    1738: 14000856     	b	0x3890 <___pl_fn_0+0x3890>
    173c: f9424be0     	ldr	x0, [sp, #0x490]
    1740: f9401800     	ldr	x0, [x0, #0x30]
    1744: 9e670004     	fmov	d4, x0
    1748: 3d813be4     	str	q4, [sp, #0x4e0]
    174c: 14000002     	b	0x1754 <___pl_fn_0+0x1754>
    1750: 3d813be4     	str	q4, [sp, #0x4e0]
    1754: 34010b35     	cbz	w21, 0x38b8 <___pl_fn_0+0x38b8>
    1758: f9424be0     	ldr	x0, [sp, #0x490]
    175c: f9400000     	ldr	x0, [x0]
    1760: 2a1503e1     	mov	w1, w21
    1764: 8b010c00     	add	x0, x0, x1, lsl #3
    1768: f9400801     	ldr	x1, [x0, #0x10]
    176c: eb01035f     	cmp	x26, x1
    1770: 54010a42     	b.hs	0x38b8 <___pl_fn_0+0x38b8>
    1774: 8b1a0c00     	add	x0, x0, x26, lsl #3
    1778: fd40141e     	ldr	d30, [x0, #0x28]
    177c: 1e7e23c0     	fcmp	d30, d30
    1780: 540000e7     	b.vc	0x179c <___pl_fn_0+0x179c>
    1784: 1400084d     	b	0x38b8 <___pl_fn_0+0x38b8>
    1788: f9424be0     	ldr	x0, [sp, #0x490]
    178c: f9401800     	ldr	x0, [x0, #0x30]
    1790: 9e67001e     	fmov	d30, x0
    1794: 3dc13be4     	ldr	q4, [sp, #0x4e0]
    1798: 14000002     	b	0x17a0 <___pl_fn_0+0x17a0>
    179c: 3dc13be4     	ldr	q4, [sp, #0x4e0]
    17a0: 1e7e3880     	fsub	d0, d4, d30
    17a4: 1e60c001     	fabs	d1, d0
    17a8: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    17ac: 9e670002     	fmov	d2, x0
    17b0: 1e622020     	fcmp	d1, d2
    17b4: 9a9f57e0     	cset	x0, mi
    17b8: 52000000     	eor	w0, w0, #0x1
    17bc: 72001c1f     	tst	w0, #0xff
    17c0: 54012241     	b.ne	0x3c08 <___pl_fn_0+0x3c08>
    17c4: 1e602000     	fcmp	d0, d0
    17c8: 54012061     	b.ne	0x3bd4 <___pl_fn_0+0x3bd4>
    17cc: 3dc13ff3     	ldr	q19, [sp, #0x4f0]
    17d0: 3dc13ff4     	ldr	q20, [sp, #0x4f0]
    17d4: 1e730a81     	fmul	d1, d20, d19
    17d8: 1e60c022     	fabs	d2, d1
    17dc: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    17e0: 9e670003     	fmov	d3, x0
    17e4: 1e632040     	fcmp	d2, d3
    17e8: 9a9f57e0     	cset	x0, mi
    17ec: 52000000     	eor	w0, w0, #0x1
    17f0: 72001c1f     	tst	w0, #0xff
    17f4: 54011d61     	b.ne	0x3ba0 <___pl_fn_0+0x3ba0>
    17f8: 3dc143e2     	ldr	q2, [sp, #0x500]
    17fc: 3dc143e3     	ldr	q3, [sp, #0x500]
    1800: 1e630842     	fmul	d2, d2, d3
    1804: 1e60c043     	fabs	d3, d2
    1808: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    180c: 9e670004     	fmov	d4, x0
    1810: 1e642060     	fcmp	d3, d4
    1814: 9a9f57e0     	cset	x0, mi
    1818: 52000000     	eor	w0, w0, #0x1
    181c: 72001c1f     	tst	w0, #0xff
    1820: 54011a61     	b.ne	0x3b6c <___pl_fn_0+0x3b6c>
    1824: 1e622821     	fadd	d1, d1, d2
    1828: 1e60c022     	fabs	d2, d1
    182c: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1830: 9e670003     	fmov	d3, x0
    1834: 1e632040     	fcmp	d2, d3
    1838: 9a9f57e0     	cset	x0, mi
    183c: 52000000     	eor	w0, w0, #0x1
    1840: 72001c1f     	tst	w0, #0xff
    1844: 540117a1     	b.ne	0x3b38 <___pl_fn_0+0x3b38>
    1848: 1e600802     	fmul	d2, d0, d0
    184c: 3d8147e0     	str	q0, [sp, #0x510]
    1850: 1e60c040     	fabs	d0, d2
    1854: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1858: 9e670003     	fmov	d3, x0
    185c: 1e632000     	fcmp	d0, d3
    1860: 9a9f57e0     	cset	x0, mi
    1864: 52000000     	eor	w0, w0, #0x1
    1868: 72001c1f     	tst	w0, #0xff
    186c: 540114c1     	b.ne	0x3b04 <___pl_fn_0+0x3b04>
    1870: 1e622820     	fadd	d0, d1, d2
    1874: 1e60c001     	fabs	d1, d0
    1878: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    187c: 9e670002     	fmov	d2, x0
    1880: 1e622020     	fcmp	d1, d2
    1884: 9a9f57e0     	cset	x0, mi
    1888: 52000000     	eor	w0, w0, #0x1
    188c: 72001c1f     	tst	w0, #0xff
    1890: 54011201     	b.ne	0x3ad0 <___pl_fn_0+0x3ad0>
    1894: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
    1898: 1e722000     	fcmp	d0, d18
    189c: 54011004     	b.mi	0x3a9c <___pl_fn_0+0x3a9c>
    18a0: 1e61c000     	fsqrt	d0, d0
    18a4: 1e602000     	fcmp	d0, d0
    18a8: 3d814fe0     	str	q0, [sp, #0x530]
    18ac: 54010de1     	b.ne	0x3a68 <___pl_fn_0+0x3a68>
    18b0: 34010199     	cbz	w25, 0x38e0 <___pl_fn_0+0x38e0>
    18b4: f9424be0     	ldr	x0, [sp, #0x490]
    18b8: f9400008     	ldr	x8, [x0]
    18bc: 2a1903e9     	mov	w9, w25
    18c0: 8b090d08     	add	x8, x8, x9, lsl #3
    18c4: f9400909     	ldr	x9, [x8, #0x10]
    18c8: eb09037f     	cmp	x27, x9
    18cc: 540100a2     	b.hs	0x38e0 <___pl_fn_0+0x38e0>
    18d0: 8b1b0d0b     	add	x11, x8, x27, lsl #3
    18d4: fd401560     	ldr	d0, [x11, #0x28]
    18d8: 1e602000     	fcmp	d0, d0
    18dc: 540000e7     	b.vc	0x18f8 <___pl_fn_0+0x18f8>
    18e0: 14000800     	b	0x38e0 <___pl_fn_0+0x38e0>
    18e4: f9424be0     	ldr	x0, [sp, #0x490]
    18e8: f9401800     	ldr	x0, [x0, #0x30]
    18ec: 9e670000     	fmov	d0, x0
    18f0: 3d813be0     	str	q0, [sp, #0x4e0]
    18f4: 14000002     	b	0x18fc <___pl_fn_0+0x18fc>
    18f8: 3d813be0     	str	q0, [sp, #0x4e0]
    18fc: 34010079     	cbz	w25, 0x3908 <___pl_fn_0+0x3908>
    1900: f9424be0     	ldr	x0, [sp, #0x490]
    1904: f9400000     	ldr	x0, [x0]
    1908: 2a1903e1     	mov	w1, w25
    190c: 8b010c00     	add	x0, x0, x1, lsl #3
    1910: f9400801     	ldr	x1, [x0, #0x10]
    1914: eb01035f     	cmp	x26, x1
    1918: 5400ff82     	b.hs	0x3908 <___pl_fn_0+0x3908>
    191c: 8b1a0c00     	add	x0, x0, x26, lsl #3
    1920: fd401411     	ldr	d17, [x0, #0x28]
    1924: 1e712220     	fcmp	d17, d17
    1928: 540000e7     	b.vc	0x1944 <___pl_fn_0+0x1944>
    192c: 140007f7     	b	0x3908 <___pl_fn_0+0x3908>
    1930: f9424be0     	ldr	x0, [sp, #0x490]
    1934: f9401800     	ldr	x0, [x0, #0x30]
    1938: 9e670011     	fmov	d17, x0
    193c: 3dc13be0     	ldr	q0, [sp, #0x4e0]
    1940: 14000002     	b	0x1948 <___pl_fn_0+0x1948>
    1944: 3dc13be0     	ldr	q0, [sp, #0x4e0]
    1948: 1e710800     	fmul	d0, d0, d17
    194c: 1e60c001     	fabs	d1, d0
    1950: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1954: 9e670002     	fmov	d2, x0
    1958: 1e622020     	fcmp	d1, d2
    195c: 9a9f57e0     	cset	x0, mi
    1960: 52000000     	eor	w0, w0, #0x1
    1964: 72001c1f     	tst	w0, #0xff
    1968: 54010661     	b.ne	0x3a34 <___pl_fn_0+0x3a34>
    196c: 3dc14fe1     	ldr	q1, [sp, #0x530]
    1970: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
    1974: 1e722020     	fcmp	d1, d18
    1978: 54010440     	b.eq	0x3a00 <___pl_fn_0+0x3a00>
    197c: 3dc14fe1     	ldr	q1, [sp, #0x530]
    1980: 1e611800     	fdiv	d0, d0, d1
    1984: 1e60c001     	fabs	d1, d0
    1988: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    198c: 9e670002     	fmov	d2, x0
    1990: 1e622020     	fcmp	d1, d2
    1994: 9a9f57e0     	cset	x0, mi
    1998: 52000000     	eor	w0, w0, #0x1
    199c: 72001c1f     	tst	w0, #0xff
    19a0: 54010161     	b.ne	0x39cc <___pl_fn_0+0x39cc>
    19a4: 3dc137f8     	ldr	q24, [sp, #0x4d0]
    19a8: 1e603b18     	fsub	d24, d24, d0
    19ac: 1e60c300     	fabs	d0, d24
    19b0: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    19b4: 9e670001     	fmov	d1, x0
    19b8: 1e612000     	fcmp	d0, d1
    19bc: 9a9f57e0     	cset	x0, mi
    19c0: 52000000     	eor	w0, w0, #0x1
    19c4: 72001c1f     	tst	w0, #0xff
    19c8: 5400fe81     	b.ne	0x3998 <___pl_fn_0+0x3998>
    19cc: 1e782300     	fcmp	d24, d24
    19d0: 5400fca1     	b.ne	0x3964 <___pl_fn_0+0x3964>
    19d4: ab13035a     	adds	x26, x26, x19
    19d8: 9a9f77e0     	cset	x0, vs
    19dc: 72001c1f     	tst	w0, #0xff
    19e0: 5400fa81     	b.ne	0x3930 <___pl_fn_0+0x3930>
    19e4: 52800036     	mov	w22, #0x1               ; =1
    19e8: 3d8137f8     	str	q24, [sp, #0x4d0]
    19ec: 17fffecd     	b	0x1520 <___pl_fn_0+0x1520>
    19f0: f942cfe0     	ldr	x0, [sp, #0x598]
    19f4: f942d3e1     	ldr	x1, [sp, #0x5a0]
    19f8: ab000021     	adds	x1, x1, x0
    19fc: 9a9f77e0     	cset	x0, vs
    1a00: 72001c1f     	tst	w0, #0xff
    1a04: 5401b8c1     	b.ne	0x511c <___pl_fn_0+0x511c>
    1a08: f942cfe0     	ldr	x0, [sp, #0x598]
    1a0c: f942cbe8     	ldr	x8, [sp, #0x590]
    1a10: ab000100     	adds	x0, x8, x0
    1a14: 9a9f77e2     	cset	x2, vs
    1a18: 72001c5f     	tst	w2, #0xff
    1a1c: 5401b661     	b.ne	0x50e8 <___pl_fn_0+0x50e8>
    1a20: b401b4a0     	cbz	x0, 0x50b4 <___pl_fn_0+0x50b4>
    1a24: 52800022     	mov	w2, #0x1                ; =1
    1a28: f942cffc     	ldr	x28, [sp, #0x598]
    1a2c: f100001f     	cmp	x0, #0x0
    1a30: 540000aa     	b.ge	0x1a44 <___pl_fn_0+0x1a44>
    1a34: eb01039f     	cmp	x28, x1
    1a38: 9a9fb7e2     	cset	x2, ge
    1a3c: aa0103f3     	mov	x19, x1
    1a40: 14000004     	b	0x1a50 <___pl_fn_0+0x1a50>
    1a44: eb01039f     	cmp	x28, x1
    1a48: aa0103f3     	mov	x19, x1
    1a4c: 9a9fc7e2     	cset	x2, le
    1a50: 72001c5f     	tst	w2, #0xff
    1a54: 54001fa1     	b.ne	0x1e48 <___pl_fn_0+0x1e48>
    1a58: f942cfe0     	ldr	x0, [sp, #0x598]
    1a5c: f942d3e1     	ldr	x1, [sp, #0x5a0]
    1a60: ab000033     	adds	x19, x1, x0
    1a64: 9a9f77e0     	cset	x0, vs
    1a68: 72001c1f     	tst	w0, #0xff
    1a6c: 54014ce1     	b.ne	0x4408 <___pl_fn_0+0x4408>
    1a70: f942cfe0     	ldr	x0, [sp, #0x598]
    1a74: f942cbe1     	ldr	x1, [sp, #0x590]
    1a78: ab000037     	adds	x23, x1, x0
    1a7c: 9a9f77e0     	cset	x0, vs
    1a80: 72001c1f     	tst	w0, #0xff
    1a84: 54014a81     	b.ne	0x43d4 <___pl_fn_0+0x43d4>
    1a88: b40148d7     	cbz	x23, 0x43a0 <___pl_fn_0+0x43a0>
    1a8c: 52800034     	mov	w20, #0x1               ; =1
    1a90: f942cffc     	ldr	x28, [sp, #0x598]
    1a94: f10002ff     	cmp	x23, #0x0
    1a98: 5400008a     	b.ge	0x1aa8 <___pl_fn_0+0x1aa8>
    1a9c: eb13039f     	cmp	x28, x19
    1aa0: 9a9fb7ea     	cset	x10, ge
    1aa4: 14000003     	b	0x1ab0 <___pl_fn_0+0x1ab0>
    1aa8: eb13039f     	cmp	x28, x19
    1aac: 9a9fc7ea     	cset	x10, le
    1ab0: 72001d5f     	tst	w10, #0xff
    1ab4: 54000121     	b.ne	0x1ad8 <___pl_fn_0+0x1ad8>
    1ab8: f942c3e0     	ldr	x0, [sp, #0x580]
    1abc: ab00037b     	adds	x27, x27, x0
    1ac0: 9a9f77e0     	cset	x0, vs
    1ac4: 72001c1f     	tst	w0, #0xff
    1ac8: 54012dc1     	b.ne	0x4080 <___pl_fn_0+0x4080>
    1acc: 52800020     	mov	w0, #0x1                ; =1
    1ad0: f942c3e1     	ldr	x1, [sp, #0x580]
    1ad4: 17fffd47     	b	0xff0 <___pl_fn_0+0xff0>
    1ad8: f942efe0     	ldr	x0, [sp, #0x5d8]
    1adc: 34012ec0     	cbz	w0, 0x40b4 <___pl_fn_0+0x40b4>
    1ae0: f9424be0     	ldr	x0, [sp, #0x490]
    1ae4: f9400000     	ldr	x0, [x0]
    1ae8: f942efe1     	ldr	x1, [sp, #0x5d8]
    1aec: 2a0103e1     	mov	w1, w1
    1af0: 8b010c00     	add	x0, x0, x1, lsl #3
    1af4: f9400801     	ldr	x1, [x0, #0x10]
    1af8: eb01039f     	cmp	x28, x1
    1afc: 54012dc2     	b.hs	0x40b4 <___pl_fn_0+0x40b4>
    1b00: 8b1c0c00     	add	x0, x0, x28, lsl #3
    1b04: fd401400     	ldr	d0, [x0, #0x28]
    1b08: 1e602000     	fcmp	d0, d0
    1b0c: 54000107     	b.vc	0x1b2c <___pl_fn_0+0x1b2c>
    1b10: 14000969     	b	0x40b4 <___pl_fn_0+0x40b4>
    1b14: f9424be0     	ldr	x0, [sp, #0x490]
    1b18: f9401801     	ldr	x1, [x0, #0x30]
    1b1c: 9e670020     	fmov	d0, x1
    1b20: 3d813be0     	str	q0, [sp, #0x4e0]
    1b24: f942ebe0     	ldr	x0, [sp, #0x5d0]
    1b28: 14000003     	b	0x1b34 <___pl_fn_0+0x1b34>
    1b2c: 3d813be0     	str	q0, [sp, #0x4e0]
    1b30: f942ebe0     	ldr	x0, [sp, #0x5d0]
    1b34: f942ebe0     	ldr	x0, [sp, #0x5d0]
    1b38: 34012d20     	cbz	w0, 0x40dc <___pl_fn_0+0x40dc>
    1b3c: f9424be0     	ldr	x0, [sp, #0x490]
    1b40: f9400005     	ldr	x5, [x0]
    1b44: f942ebe0     	ldr	x0, [sp, #0x5d0]
    1b48: 2a0003e6     	mov	w6, w0
    1b4c: 8b060ca5     	add	x5, x5, x6, lsl #3
    1b50: f94008a6     	ldr	x6, [x5, #0x10]
    1b54: eb06039f     	cmp	x28, x6
    1b58: 54012c22     	b.hs	0x40dc <___pl_fn_0+0x40dc>
    1b5c: 8b1c0ca8     	add	x8, x5, x28, lsl #3
    1b60: fd401501     	ldr	d1, [x8, #0x28]
    1b64: 1e612020     	fcmp	d1, d1
    1b68: 540000a7     	b.vc	0x1b7c <___pl_fn_0+0x1b7c>
    1b6c: 1400095c     	b	0x40dc <___pl_fn_0+0x40dc>
    1b70: f9424be0     	ldr	x0, [sp, #0x490]
    1b74: f940180e     	ldr	x14, [x0, #0x30]
    1b78: 9e6701c1     	fmov	d1, x14
    1b7c: 5c021b70     	ldr	d16, 0x5ee8 <___pl_fn_0+0x5ee8>
    1b80: 1e610a10     	fmul	d16, d16, d1
    1b84: 1e60c211     	fabs	d17, d16
    1b88: d2effe0f     	mov	x15, #0x7ff0000000000000 ; =9218868437227405312
    1b8c: 9e6701f2     	fmov	d18, x15
    1b90: 1e722220     	fcmp	d17, d18
    1b94: 9a9f57e0     	cset	x0, mi
    1b98: 52000000     	eor	w0, w0, #0x1
    1b9c: 72001c1f     	tst	w0, #0xff
    1ba0: 54013e61     	b.ne	0x436c <___pl_fn_0+0x436c>
    1ba4: 3dc13be0     	ldr	q0, [sp, #0x4e0]
    1ba8: 1e702813     	fadd	d19, d0, d16
    1bac: 1e60c274     	fabs	d20, d19
    1bb0: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1bb4: 9e670015     	fmov	d21, x0
    1bb8: 1e752280     	fcmp	d20, d21
    1bbc: 9a9f57e0     	cset	x0, mi
    1bc0: 52000000     	eor	w0, w0, #0x1
    1bc4: 72001c1f     	tst	w0, #0xff
    1bc8: 54013b81     	b.ne	0x4338 <___pl_fn_0+0x4338>
    1bcc: f942efe0     	ldr	x0, [sp, #0x5d8]
    1bd0: 340129a0     	cbz	w0, 0x4104 <___pl_fn_0+0x4104>
    1bd4: f9424be0     	ldr	x0, [sp, #0x490]
    1bd8: f9400000     	ldr	x0, [x0]
    1bdc: f942efe1     	ldr	x1, [sp, #0x5d8]
    1be0: 2a0103e1     	mov	w1, w1
    1be4: 8b010c00     	add	x0, x0, x1, lsl #3
    1be8: f9400801     	ldr	x1, [x0, #0x10]
    1bec: eb01039f     	cmp	x28, x1
    1bf0: 540128a2     	b.hs	0x4104 <___pl_fn_0+0x4104>
    1bf4: 4e083e61     	mov.d	x1, v19[0]
    1bf8: 8b1c0c00     	add	x0, x0, x28, lsl #3
    1bfc: f9001401     	str	x1, [x0, #0x28]
    1c00: 340129b8     	cbz	w24, 0x4134 <___pl_fn_0+0x4134>
    1c04: f9424be0     	ldr	x0, [sp, #0x490]
    1c08: f9400000     	ldr	x0, [x0]
    1c0c: 2a1803e1     	mov	w1, w24
    1c10: 8b010c00     	add	x0, x0, x1, lsl #3
    1c14: f9400801     	ldr	x1, [x0, #0x10]
    1c18: eb01039f     	cmp	x28, x1
    1c1c: 540128c2     	b.hs	0x4134 <___pl_fn_0+0x4134>
    1c20: 8b1c0c00     	add	x0, x0, x28, lsl #3
    1c24: fd401406     	ldr	d6, [x0, #0x28]
    1c28: 1e6620c0     	fcmp	d6, d6
    1c2c: 54000107     	b.vc	0x1c4c <___pl_fn_0+0x1c4c>
    1c30: 14000941     	b	0x4134 <___pl_fn_0+0x4134>
    1c34: f9424be0     	ldr	x0, [sp, #0x490]
    1c38: f9401800     	ldr	x0, [x0, #0x30]
    1c3c: 9e670006     	fmov	d6, x0
    1c40: 3d813be6     	str	q6, [sp, #0x4e0]
    1c44: f942e7e0     	ldr	x0, [sp, #0x5c8]
    1c48: 14000003     	b	0x1c54 <___pl_fn_0+0x1c54>
    1c4c: 3d813be6     	str	q6, [sp, #0x4e0]
    1c50: f942e7e0     	ldr	x0, [sp, #0x5c8]
    1c54: f942e7e0     	ldr	x0, [sp, #0x5c8]
    1c58: 34012820     	cbz	w0, 0x415c <___pl_fn_0+0x415c>
    1c5c: f9424be0     	ldr	x0, [sp, #0x490]
    1c60: f9400000     	ldr	x0, [x0]
    1c64: f942e7e1     	ldr	x1, [sp, #0x5c8]
    1c68: 2a0103e1     	mov	w1, w1
    1c6c: 8b010c00     	add	x0, x0, x1, lsl #3
    1c70: f9400801     	ldr	x1, [x0, #0x10]
    1c74: eb01039f     	cmp	x28, x1
    1c78: 54012722     	b.hs	0x415c <___pl_fn_0+0x415c>
    1c7c: 8b1c0c00     	add	x0, x0, x28, lsl #3
    1c80: fd401400     	ldr	d0, [x0, #0x28]
    1c84: 1e602000     	fcmp	d0, d0
    1c88: 540000a7     	b.vc	0x1c9c <___pl_fn_0+0x1c9c>
    1c8c: 14000934     	b	0x415c <___pl_fn_0+0x415c>
    1c90: f9424be0     	ldr	x0, [sp, #0x490]
    1c94: f9401800     	ldr	x0, [x0, #0x30]
    1c98: 9e670000     	fmov	d0, x0
    1c9c: 5c021261     	ldr	d1, 0x5ee8 <___pl_fn_0+0x5ee8>
    1ca0: 1e600820     	fmul	d0, d1, d0
    1ca4: 1e60c001     	fabs	d1, d0
    1ca8: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1cac: 9e670002     	fmov	d2, x0
    1cb0: 1e622020     	fcmp	d1, d2
    1cb4: 9a9f57e0     	cset	x0, mi
    1cb8: 52000000     	eor	w0, w0, #0x1
    1cbc: 72001c1f     	tst	w0, #0xff
    1cc0: 54013221     	b.ne	0x4304 <___pl_fn_0+0x4304>
    1cc4: 3dc13be6     	ldr	q6, [sp, #0x4e0]
    1cc8: 1e6028c0     	fadd	d0, d6, d0
    1ccc: 1e60c001     	fabs	d1, d0
    1cd0: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1cd4: 9e670002     	fmov	d2, x0
    1cd8: 1e622020     	fcmp	d1, d2
    1cdc: 9a9f57e1     	cset	x1, mi
    1ce0: 52000021     	eor	w1, w1, #0x1
    1ce4: 72001c3f     	tst	w1, #0xff
    1ce8: 54012f41     	b.ne	0x42d0 <___pl_fn_0+0x42d0>
    1cec: 340124d8     	cbz	w24, 0x4184 <___pl_fn_0+0x4184>
    1cf0: f9424be0     	ldr	x0, [sp, #0x490]
    1cf4: f9400005     	ldr	x5, [x0]
    1cf8: 2a1803e6     	mov	w6, w24
    1cfc: 8b060ca5     	add	x5, x5, x6, lsl #3
    1d00: f94008a6     	ldr	x6, [x5, #0x10]
    1d04: eb06039f     	cmp	x28, x6
    1d08: 540123e2     	b.hs	0x4184 <___pl_fn_0+0x4184>
    1d0c: 4e083c0d     	mov.d	x13, v0[0]
    1d10: 8b1c0cae     	add	x14, x5, x28, lsl #3
    1d14: f90015cd     	str	x13, [x14, #0x28]
    1d18: 340124f5     	cbz	w21, 0x41b4 <___pl_fn_0+0x41b4>
    1d1c: f9424be0     	ldr	x0, [sp, #0x490]
    1d20: f9400000     	ldr	x0, [x0]
    1d24: 2a1503e1     	mov	w1, w21
    1d28: 8b010c00     	add	x0, x0, x1, lsl #3
    1d2c: f9400801     	ldr	x1, [x0, #0x10]
    1d30: eb01039f     	cmp	x28, x1
    1d34: 54012402     	b.hs	0x41b4 <___pl_fn_0+0x41b4>
    1d38: 8b1c0c00     	add	x0, x0, x28, lsl #3
    1d3c: fd401400     	ldr	d0, [x0, #0x28]
    1d40: 1e602000     	fcmp	d0, d0
    1d44: 54000107     	b.vc	0x1d64 <___pl_fn_0+0x1d64>
    1d48: 1400091b     	b	0x41b4 <___pl_fn_0+0x41b4>
    1d4c: f9424be0     	ldr	x0, [sp, #0x490]
    1d50: f9401800     	ldr	x0, [x0, #0x30]
    1d54: 9e670000     	fmov	d0, x0
    1d58: 3d813be0     	str	q0, [sp, #0x4e0]
    1d5c: f942e3e0     	ldr	x0, [sp, #0x5c0]
    1d60: 14000003     	b	0x1d6c <___pl_fn_0+0x1d6c>
    1d64: 3d813be0     	str	q0, [sp, #0x4e0]
    1d68: f942e3e0     	ldr	x0, [sp, #0x5c0]
    1d6c: f942e3e0     	ldr	x0, [sp, #0x5c0]
    1d70: 34012360     	cbz	w0, 0x41dc <___pl_fn_0+0x41dc>
    1d74: f9424be0     	ldr	x0, [sp, #0x490]
    1d78: f9400000     	ldr	x0, [x0]
    1d7c: f942e3e1     	ldr	x1, [sp, #0x5c0]
    1d80: 2a0103e1     	mov	w1, w1
    1d84: 8b010c00     	add	x0, x0, x1, lsl #3
    1d88: f9400801     	ldr	x1, [x0, #0x10]
    1d8c: eb01039f     	cmp	x28, x1
    1d90: 54012262     	b.hs	0x41dc <___pl_fn_0+0x41dc>
    1d94: 8b1c0c00     	add	x0, x0, x28, lsl #3
    1d98: fd401400     	ldr	d0, [x0, #0x28]
    1d9c: 1e602000     	fcmp	d0, d0
    1da0: 540000a7     	b.vc	0x1db4 <___pl_fn_0+0x1db4>
    1da4: 1400090e     	b	0x41dc <___pl_fn_0+0x41dc>
    1da8: f9424be0     	ldr	x0, [sp, #0x490]
    1dac: f9401800     	ldr	x0, [x0, #0x30]
    1db0: 9e670000     	fmov	d0, x0
    1db4: 5c0209a1     	ldr	d1, 0x5ee8 <___pl_fn_0+0x5ee8>
    1db8: 1e600820     	fmul	d0, d1, d0
    1dbc: 1e60c001     	fabs	d1, d0
    1dc0: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1dc4: 9e670002     	fmov	d2, x0
    1dc8: 1e622020     	fcmp	d1, d2
    1dcc: 9a9f57e0     	cset	x0, mi
    1dd0: 52000000     	eor	w0, w0, #0x1
    1dd4: 72001c1f     	tst	w0, #0xff
    1dd8: 54012621     	b.ne	0x429c <___pl_fn_0+0x429c>
    1ddc: 3dc13be1     	ldr	q1, [sp, #0x4e0]
    1de0: 1e602820     	fadd	d0, d1, d0
    1de4: 1e60c001     	fabs	d1, d0
    1de8: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1dec: 9e670002     	fmov	d2, x0
    1df0: 1e622020     	fcmp	d1, d2
    1df4: 9a9f57e0     	cset	x0, mi
    1df8: 52000000     	eor	w0, w0, #0x1
    1dfc: 72001c1f     	tst	w0, #0xff
    1e00: 54012341     	b.ne	0x4268 <___pl_fn_0+0x4268>
    1e04: 34012015     	cbz	w21, 0x4204 <___pl_fn_0+0x4204>
    1e08: f9424be0     	ldr	x0, [sp, #0x490]
    1e0c: f9400000     	ldr	x0, [x0]
    1e10: 2a1503e1     	mov	w1, w21
    1e14: 8b010c00     	add	x0, x0, x1, lsl #3
    1e18: f9400801     	ldr	x1, [x0, #0x10]
    1e1c: eb01039f     	cmp	x28, x1
    1e20: 54011f22     	b.hs	0x4204 <___pl_fn_0+0x4204>
    1e24: 4e083c01     	mov.d	x1, v0[0]
    1e28: 8b1c0c00     	add	x0, x0, x28, lsl #3
    1e2c: f9001401     	str	x1, [x0, #0x28]
    1e30: ab17039c     	adds	x28, x28, x23
    1e34: 9a9f77e0     	cset	x0, vs
    1e38: 72001c1f     	tst	w0, #0xff
    1e3c: 54011fc1     	b.ne	0x4234 <___pl_fn_0+0x4234>
    1e40: 52800034     	mov	w20, #0x1               ; =1
    1e44: 17ffff14     	b	0x1a94 <___pl_fn_0+0x1a94>
    1e48: f942cbe2     	ldr	x2, [sp, #0x590]
    1e4c: ab02039a     	adds	x26, x28, x2
    1e50: 9a9f77ea     	cset	x10, vs
    1e54: 72001d5f     	tst	w10, #0xff
    1e58: 54019141     	b.ne	0x5080 <___pl_fn_0+0x5080>
    1e5c: f942d3e1     	ldr	x1, [sp, #0x5a0]
    1e60: f942cff6     	ldr	x22, [sp, #0x598]
    1e64: ab16002a     	adds	x10, x1, x22
    1e68: 9a9f77ec     	cset	x12, vs
    1e6c: 72001d9f     	tst	w12, #0xff
    1e70: 54018ee1     	b.ne	0x504c <___pl_fn_0+0x504c>
    1e74: f942cbeb     	ldr	x11, [sp, #0x590]
    1e78: f942cff6     	ldr	x22, [sp, #0x598]
    1e7c: ab16016c     	adds	x12, x11, x22
    1e80: 9a9f77ee     	cset	x14, vs
    1e84: 72001ddf     	tst	w14, #0xff
    1e88: 54018c81     	b.ne	0x5018 <___pl_fn_0+0x5018>
    1e8c: b4018acc     	cbz	x12, 0x4fe4 <___pl_fn_0+0x4fe4>
    1e90: 52800036     	mov	w22, #0x1               ; =1
    1e94: f100019f     	cmp	x12, #0x0
    1e98: f902abec     	str	x12, [sp, #0x550]
    1e9c: 540000aa     	b.ge	0x1eb0 <___pl_fn_0+0x1eb0>
    1ea0: eb0a035f     	cmp	x26, x10
    1ea4: 9a9fb7e4     	cset	x4, ge
    1ea8: aa0a03f7     	mov	x23, x10
    1eac: 14000004     	b	0x1ebc <___pl_fn_0+0x1ebc>
    1eb0: eb0a035f     	cmp	x26, x10
    1eb4: aa0a03f7     	mov	x23, x10
    1eb8: 9a9fc7e4     	cset	x4, le
    1ebc: 72001c9f     	tst	w4, #0xff
    1ec0: 54000141     	b.ne	0x1ee8 <___pl_fn_0+0x1ee8>
    1ec4: ab00039c     	adds	x28, x28, x0
    1ec8: aa0003f4     	mov	x20, x0
    1ecc: 9a9f77e0     	cset	x0, vs
    1ed0: 72001c1f     	tst	w0, #0xff
    1ed4: 54012b41     	b.ne	0x443c <___pl_fn_0+0x443c>
    1ed8: 52800022     	mov	w2, #0x1                ; =1
    1edc: aa1403e0     	mov	x0, x20
    1ee0: aa1303e1     	mov	x1, x19
    1ee4: 17fffed2     	b	0x1a2c <___pl_fn_0+0x1a2c>
    1ee8: aa0003f4     	mov	x20, x0
    1eec: f942efe0     	ldr	x0, [sp, #0x5d8]
    1ef0: 34012c00     	cbz	w0, 0x4470 <___pl_fn_0+0x4470>
    1ef4: f9424be0     	ldr	x0, [sp, #0x490]
    1ef8: f9400000     	ldr	x0, [x0]
    1efc: f942efe4     	ldr	x4, [sp, #0x5d8]
    1f00: 2a0403e1     	mov	w1, w4
    1f04: 8b010c00     	add	x0, x0, x1, lsl #3
    1f08: f9400801     	ldr	x1, [x0, #0x10]
    1f0c: eb01039f     	cmp	x28, x1
    1f10: 54012b02     	b.hs	0x4470 <___pl_fn_0+0x4470>
    1f14: 8b1c0c00     	add	x0, x0, x28, lsl #3
    1f18: fd401400     	ldr	d0, [x0, #0x28]
    1f1c: 1e602000     	fcmp	d0, d0
    1f20: 54000107     	b.vc	0x1f40 <___pl_fn_0+0x1f40>
    1f24: 14000953     	b	0x4470 <___pl_fn_0+0x4470>
    1f28: f9424be0     	ldr	x0, [sp, #0x490]
    1f2c: f9401800     	ldr	x0, [x0, #0x30]
    1f30: 9e670000     	fmov	d0, x0
    1f34: 3d8137e0     	str	q0, [sp, #0x4d0]
    1f38: f942efe0     	ldr	x0, [sp, #0x5d8]
    1f3c: 14000003     	b	0x1f48 <___pl_fn_0+0x1f48>
    1f40: 3d8137e0     	str	q0, [sp, #0x4d0]
    1f44: f942efe0     	ldr	x0, [sp, #0x5d8]
    1f48: f942efe0     	ldr	x0, [sp, #0x5d8]
    1f4c: 34012a60     	cbz	w0, 0x4498 <___pl_fn_0+0x4498>
    1f50: f9424be0     	ldr	x0, [sp, #0x490]
    1f54: f9400000     	ldr	x0, [x0]
    1f58: f942efe1     	ldr	x1, [sp, #0x5d8]
    1f5c: 2a0103e1     	mov	w1, w1
    1f60: 8b010c00     	add	x0, x0, x1, lsl #3
    1f64: f9400801     	ldr	x1, [x0, #0x10]
    1f68: eb01035f     	cmp	x26, x1
    1f6c: 54012962     	b.hs	0x4498 <___pl_fn_0+0x4498>
    1f70: 8b1a0c00     	add	x0, x0, x26, lsl #3
    1f74: fd401400     	ldr	d0, [x0, #0x28]
    1f78: 1e602000     	fcmp	d0, d0
    1f7c: 540000e7     	b.vc	0x1f98 <___pl_fn_0+0x1f98>
    1f80: 14000946     	b	0x4498 <___pl_fn_0+0x4498>
    1f84: f9424be0     	ldr	x0, [sp, #0x490]
    1f88: f9401800     	ldr	x0, [x0, #0x30]
    1f8c: 9e670000     	fmov	d0, x0
    1f90: 3dc137e1     	ldr	q1, [sp, #0x4d0]
    1f94: 14000002     	b	0x1f9c <___pl_fn_0+0x1f9c>
    1f98: 3dc137e1     	ldr	q1, [sp, #0x4d0]
    1f9c: 1e603820     	fsub	d0, d1, d0
    1fa0: 3d813fe0     	str	q0, [sp, #0x4f0]
    1fa4: 1e60c000     	fabs	d0, d0
    1fa8: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    1fac: 9e670001     	fmov	d1, x0
    1fb0: 1e612000     	fcmp	d0, d1
    1fb4: 9a9f57e0     	cset	x0, mi
    1fb8: 52000000     	eor	w0, w0, #0x1
    1fbc: 72001c1f     	tst	w0, #0xff
    1fc0: 54017f81     	b.ne	0x4fb0 <___pl_fn_0+0x4fb0>
    1fc4: 3dc13fe0     	ldr	q0, [sp, #0x4f0]
    1fc8: 3dc13ff0     	ldr	q16, [sp, #0x4f0]
    1fcc: 1e702000     	fcmp	d0, d16
    1fd0: 54017d61     	b.ne	0x4f7c <___pl_fn_0+0x4f7c>
    1fd4: 34012778     	cbz	w24, 0x44c0 <___pl_fn_0+0x44c0>
    1fd8: f9424be0     	ldr	x0, [sp, #0x490]
    1fdc: f9400000     	ldr	x0, [x0]
    1fe0: 2a1803e1     	mov	w1, w24
    1fe4: 8b010c00     	add	x0, x0, x1, lsl #3
    1fe8: f9400801     	ldr	x1, [x0, #0x10]
    1fec: eb01039f     	cmp	x28, x1
    1ff0: 54012682     	b.hs	0x44c0 <___pl_fn_0+0x44c0>
    1ff4: 8b1c0c02     	add	x2, x0, x28, lsl #3
    1ff8: fd401440     	ldr	d0, [x2, #0x28]
    1ffc: 1e602000     	fcmp	d0, d0
    2000: 540000e7     	b.vc	0x201c <___pl_fn_0+0x201c>
    2004: 1400092f     	b	0x44c0 <___pl_fn_0+0x44c0>
    2008: f9424be0     	ldr	x0, [sp, #0x490]
    200c: f9401808     	ldr	x8, [x0, #0x30]
    2010: 9e670100     	fmov	d0, x8
    2014: 3d8137e0     	str	q0, [sp, #0x4d0]
    2018: 14000002     	b	0x2020 <___pl_fn_0+0x2020>
    201c: 3d8137e0     	str	q0, [sp, #0x4d0]
    2020: 34012658     	cbz	w24, 0x44e8 <___pl_fn_0+0x44e8>
    2024: f9424be0     	ldr	x0, [sp, #0x490]
    2028: f940000c     	ldr	x12, [x0]
    202c: 2a1803ed     	mov	w13, w24
    2030: 8b0d0d8c     	add	x12, x12, x13, lsl #3
    2034: f940098d     	ldr	x13, [x12, #0x10]
    2038: eb0d035f     	cmp	x26, x13
    203c: 54012562     	b.hs	0x44e8 <___pl_fn_0+0x44e8>
    2040: 8b1a0d8f     	add	x15, x12, x26, lsl #3
    2044: fd4015e0     	ldr	d0, [x15, #0x28]
    2048: 1e602000     	fcmp	d0, d0
    204c: 540000e7     	b.vc	0x2068 <___pl_fn_0+0x2068>
    2050: 14000926     	b	0x44e8 <___pl_fn_0+0x44e8>
    2054: f9424be0     	ldr	x0, [sp, #0x490]
    2058: f9401800     	ldr	x0, [x0, #0x30]
    205c: 9e670000     	fmov	d0, x0
    2060: 3dc137fc     	ldr	q28, [sp, #0x4d0]
    2064: 14000002     	b	0x206c <___pl_fn_0+0x206c>
    2068: 3dc137fc     	ldr	q28, [sp, #0x4d0]
    206c: 1e603b80     	fsub	d0, d28, d0
    2070: 3d8143e0     	str	q0, [sp, #0x500]
    2074: 1e60c017     	fabs	d23, d0
    2078: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    207c: 9e670018     	fmov	d24, x0
    2080: 1e7822e0     	fcmp	d23, d24
    2084: 9a9f57e0     	cset	x0, mi
    2088: 52000000     	eor	w0, w0, #0x1
    208c: 72001c1f     	tst	w0, #0xff
    2090: 540175c1     	b.ne	0x4f48 <___pl_fn_0+0x4f48>
    2094: 3dc143e0     	ldr	q0, [sp, #0x500]
    2098: 3dc143e1     	ldr	q1, [sp, #0x500]
    209c: 1e612000     	fcmp	d0, d1
    20a0: 540173a1     	b.ne	0x4f14 <___pl_fn_0+0x4f14>
    20a4: 34012375     	cbz	w21, 0x4510 <___pl_fn_0+0x4510>
    20a8: f9424be0     	ldr	x0, [sp, #0x490]
    20ac: f9400000     	ldr	x0, [x0]
    20b0: 2a1503e1     	mov	w1, w21
    20b4: 8b010c00     	add	x0, x0, x1, lsl #3
    20b8: f9400801     	ldr	x1, [x0, #0x10]
    20bc: eb01039f     	cmp	x28, x1
    20c0: 54012282     	b.hs	0x4510 <___pl_fn_0+0x4510>
    20c4: 8b1c0c00     	add	x0, x0, x28, lsl #3
    20c8: fd401400     	ldr	d0, [x0, #0x28]
    20cc: 1e602000     	fcmp	d0, d0
    20d0: 540000e7     	b.vc	0x20ec <___pl_fn_0+0x20ec>
    20d4: 1400090f     	b	0x4510 <___pl_fn_0+0x4510>
    20d8: f9424be0     	ldr	x0, [sp, #0x490]
    20dc: f9401800     	ldr	x0, [x0, #0x30]
    20e0: 9e670000     	fmov	d0, x0
    20e4: 3d8137e0     	str	q0, [sp, #0x4d0]
    20e8: 14000002     	b	0x20f0 <___pl_fn_0+0x20f0>
    20ec: 3d8137e0     	str	q0, [sp, #0x4d0]
    20f0: 34012255     	cbz	w21, 0x4538 <___pl_fn_0+0x4538>
    20f4: f9424be0     	ldr	x0, [sp, #0x490]
    20f8: f9400000     	ldr	x0, [x0]
    20fc: 2a1503e1     	mov	w1, w21
    2100: 8b010c00     	add	x0, x0, x1, lsl #3
    2104: f9400801     	ldr	x1, [x0, #0x10]
    2108: eb01035f     	cmp	x26, x1
    210c: 54012162     	b.hs	0x4538 <___pl_fn_0+0x4538>
    2110: 8b1a0c00     	add	x0, x0, x26, lsl #3
    2114: fd401400     	ldr	d0, [x0, #0x28]
    2118: 1e602000     	fcmp	d0, d0
    211c: 540000e7     	b.vc	0x2138 <___pl_fn_0+0x2138>
    2120: 14000906     	b	0x4538 <___pl_fn_0+0x4538>
    2124: f9424be0     	ldr	x0, [sp, #0x490]
    2128: f9401800     	ldr	x0, [x0, #0x30]
    212c: 9e670000     	fmov	d0, x0
    2130: 3dc137f8     	ldr	q24, [sp, #0x4d0]
    2134: 14000002     	b	0x213c <___pl_fn_0+0x213c>
    2138: 3dc137f8     	ldr	q24, [sp, #0x4d0]
    213c: 1e603b00     	fsub	d0, d24, d0
    2140: 3d8147e0     	str	q0, [sp, #0x510]
    2144: 1e60c000     	fabs	d0, d0
    2148: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    214c: 9e670001     	fmov	d1, x0
    2150: 1e612000     	fcmp	d0, d1
    2154: 9a9f57e0     	cset	x0, mi
    2158: 52000000     	eor	w0, w0, #0x1
    215c: 72001c1f     	tst	w0, #0xff
    2160: 54016c01     	b.ne	0x4ee0 <___pl_fn_0+0x4ee0>
    2164: 3dc147e0     	ldr	q0, [sp, #0x510]
    2168: 3dc147fa     	ldr	q26, [sp, #0x510]
    216c: 1e7a2000     	fcmp	d0, d26
    2170: 540169e1     	b.ne	0x4eac <___pl_fn_0+0x4eac>
    2174: 3dc13fe0     	ldr	q0, [sp, #0x4f0]
    2178: 3dc13ff0     	ldr	q16, [sp, #0x4f0]
    217c: 1e700800     	fmul	d0, d0, d16
    2180: 1e60c001     	fabs	d1, d0
    2184: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2188: 9e670002     	fmov	d2, x0
    218c: 1e622020     	fcmp	d1, d2
    2190: 9a9f57e0     	cset	x0, mi
    2194: 52000000     	eor	w0, w0, #0x1
    2198: 72001c1f     	tst	w0, #0xff
    219c: 540166e1     	b.ne	0x4e78 <___pl_fn_0+0x4e78>
    21a0: 3dc143e1     	ldr	q1, [sp, #0x500]
    21a4: 3dc143e2     	ldr	q2, [sp, #0x500]
    21a8: 1e620821     	fmul	d1, d1, d2
    21ac: 1e60c022     	fabs	d2, d1
    21b0: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    21b4: 9e670003     	fmov	d3, x0
    21b8: 1e632040     	fcmp	d2, d3
    21bc: 9a9f57e0     	cset	x0, mi
    21c0: 52000000     	eor	w0, w0, #0x1
    21c4: 72001c1f     	tst	w0, #0xff
    21c8: 540163e1     	b.ne	0x4e44 <___pl_fn_0+0x4e44>
    21cc: 1e612802     	fadd	d2, d0, d1
    21d0: 1e60c043     	fabs	d3, d2
    21d4: d2effe01     	mov	x1, #0x7ff0000000000000 ; =9218868437227405312
    21d8: 9e670024     	fmov	d4, x1
    21dc: 1e642060     	fcmp	d3, d4
    21e0: 9a9f57e3     	cset	x3, mi
    21e4: 52000063     	eor	w3, w3, #0x1
    21e8: 72001c7f     	tst	w3, #0xff
    21ec: 54016121     	b.ne	0x4e10 <___pl_fn_0+0x4e10>
    21f0: 3dc147e0     	ldr	q0, [sp, #0x510]
    21f4: 3dc147e1     	ldr	q1, [sp, #0x510]
    21f8: 1e610805     	fmul	d5, d0, d1
    21fc: 1e60c0a6     	fabs	d6, d5
    2200: d2effe04     	mov	x4, #0x7ff0000000000000 ; =9218868437227405312
    2204: 9e670087     	fmov	d7, x4
    2208: 1e6720c0     	fcmp	d6, d7
    220c: 9a9f57e6     	cset	x6, mi
    2210: 520000c6     	eor	w6, w6, #0x1
    2214: 72001cdf     	tst	w6, #0xff
    2218: 54015e21     	b.ne	0x4ddc <___pl_fn_0+0x4ddc>
    221c: 1e652840     	fadd	d0, d2, d5
    2220: 1e60c010     	fabs	d16, d0
    2224: d2effe07     	mov	x7, #0x7ff0000000000000 ; =9218868437227405312
    2228: 9e6700f1     	fmov	d17, x7
    222c: 1e712200     	fcmp	d16, d17
    2230: 9a9f57e9     	cset	x9, mi
    2234: 52000129     	eor	w9, w9, #0x1
    2238: 72001d3f     	tst	w9, #0xff
    223c: 54015b61     	b.ne	0x4da8 <___pl_fn_0+0x4da8>
    2240: 1e602000     	fcmp	d0, d0
    2244: 54015981     	b.ne	0x4d74 <___pl_fn_0+0x4d74>
    2248: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
    224c: 1e722000     	fcmp	d0, d18
    2250: 54015784     	b.mi	0x4d40 <___pl_fn_0+0x4d40>
    2254: 1e61c001     	fsqrt	d1, d0
    2258: 4ea11c22     	mov.16b	v2, v1
    225c: 3d814fe1     	str	q1, [sp, #0x530]
    2260: 1e622020     	fcmp	d1, d2
    2264: 54015541     	b.ne	0x4d0c <___pl_fn_0+0x4d0c>
    2268: 3dc14fe1     	ldr	q1, [sp, #0x530]
    226c: 1e610811     	fmul	d17, d0, d1
    2270: 3d814be0     	str	q0, [sp, #0x520]
    2274: 1e60c232     	fabs	d18, d17
    2278: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    227c: 9e670013     	fmov	d19, x0
    2280: 1e732240     	fcmp	d18, d19
    2284: 9a9f57e0     	cset	x0, mi
    2288: 52000000     	eor	w0, w0, #0x1
    228c: 72001c1f     	tst	w0, #0xff
    2290: 54015241     	b.ne	0x4cd8 <___pl_fn_0+0x4cd8>
    2294: 3dc16ff2     	ldr	q18, [sp, #0x5b0]
    2298: 1e722220     	fcmp	d17, d18
    229c: 54015040     	b.eq	0x4ca4 <___pl_fn_0+0x4ca4>
    22a0: 5c01e256     	ldr	d22, 0x5ee8 <___pl_fn_0+0x5ee8>
    22a4: 1e711ac0     	fdiv	d0, d22, d17
    22a8: 1e60c016     	fabs	d22, d0
    22ac: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    22b0: 9e670017     	fmov	d23, x0
    22b4: 1e7722c0     	fcmp	d22, d23
    22b8: 9a9f57e0     	cset	x0, mi
    22bc: 52000000     	eor	w0, w0, #0x1
    22c0: 72001c1f     	tst	w0, #0xff
    22c4: 54014d61     	b.ne	0x4c70 <___pl_fn_0+0x4c70>
    22c8: 1e602000     	fcmp	d0, d0
    22cc: 3d8153e0     	str	q0, [sp, #0x540]
    22d0: 54014b61     	b.ne	0x4c3c <___pl_fn_0+0x4c3c>
    22d4: f942ebe0     	ldr	x0, [sp, #0x5d0]
    22d8: 34011440     	cbz	w0, 0x4560 <___pl_fn_0+0x4560>
    22dc: f9424be0     	ldr	x0, [sp, #0x490]
    22e0: f9400000     	ldr	x0, [x0]
    22e4: f942ebe1     	ldr	x1, [sp, #0x5d0]
    22e8: 2a0103e1     	mov	w1, w1
    22ec: 8b010c00     	add	x0, x0, x1, lsl #3
    22f0: f9400801     	ldr	x1, [x0, #0x10]
    22f4: eb01039f     	cmp	x28, x1
    22f8: 54011342     	b.hs	0x4560 <___pl_fn_0+0x4560>
    22fc: 8b1c0c00     	add	x0, x0, x28, lsl #3
    2300: fd401400     	ldr	d0, [x0, #0x28]
    2304: 1e602000     	fcmp	d0, d0
    2308: 540000e7     	b.vc	0x2324 <___pl_fn_0+0x2324>
    230c: 14000895     	b	0x4560 <___pl_fn_0+0x4560>
    2310: f9424be0     	ldr	x0, [sp, #0x490]
    2314: f9401800     	ldr	x0, [x0, #0x30]
    2318: 9e670000     	fmov	d0, x0
    231c: 3d8137e0     	str	q0, [sp, #0x4d0]
    2320: 14000002     	b	0x2328 <___pl_fn_0+0x2328>
    2324: 3d8137e0     	str	q0, [sp, #0x4d0]
    2328: 34011319     	cbz	w25, 0x4588 <___pl_fn_0+0x4588>
    232c: f9424be0     	ldr	x0, [sp, #0x490]
    2330: f9400000     	ldr	x0, [x0]
    2334: 2a1903e1     	mov	w1, w25
    2338: 8b010c00     	add	x0, x0, x1, lsl #3
    233c: f9400801     	ldr	x1, [x0, #0x10]
    2340: eb01035f     	cmp	x26, x1
    2344: 54011222     	b.hs	0x4588 <___pl_fn_0+0x4588>
    2348: 8b1a0c00     	add	x0, x0, x26, lsl #3
    234c: fd401407     	ldr	d7, [x0, #0x28]
    2350: 1e6720e0     	fcmp	d7, d7
    2354: 540000e7     	b.vc	0x2370 <___pl_fn_0+0x2370>
    2358: 1400088c     	b	0x4588 <___pl_fn_0+0x4588>
    235c: f9424be0     	ldr	x0, [sp, #0x490]
    2360: f9401800     	ldr	x0, [x0, #0x30]
    2364: 9e670007     	fmov	d7, x0
    2368: 3dc13fe0     	ldr	q0, [sp, #0x4f0]
    236c: 14000002     	b	0x2374 <___pl_fn_0+0x2374>
    2370: 3dc13fe0     	ldr	q0, [sp, #0x4f0]
    2374: 3dc13fe0     	ldr	q0, [sp, #0x4f0]
    2378: 1e670800     	fmul	d0, d0, d7
    237c: 1e60c001     	fabs	d1, d0
    2380: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2384: 9e670002     	fmov	d2, x0
    2388: 1e622020     	fcmp	d1, d2
    238c: 9a9f57e0     	cset	x0, mi
    2390: 52000000     	eor	w0, w0, #0x1
    2394: 72001c1f     	tst	w0, #0xff
    2398: 54014381     	b.ne	0x4c08 <___pl_fn_0+0x4c08>
    239c: 3dc153e1     	ldr	q1, [sp, #0x540]
    23a0: 1e610800     	fmul	d0, d0, d1
    23a4: 1e60c001     	fabs	d1, d0
    23a8: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    23ac: 9e670002     	fmov	d2, x0
    23b0: 1e622020     	fcmp	d1, d2
    23b4: 9a9f57e0     	cset	x0, mi
    23b8: 52000000     	eor	w0, w0, #0x1
    23bc: 72001c1f     	tst	w0, #0xff
    23c0: 540140a1     	b.ne	0x4bd4 <___pl_fn_0+0x4bd4>
    23c4: 3dc137e1     	ldr	q1, [sp, #0x4d0]
    23c8: 1e603820     	fsub	d0, d1, d0
    23cc: 1e60c001     	fabs	d1, d0
    23d0: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    23d4: 9e670002     	fmov	d2, x0
    23d8: 1e622020     	fcmp	d1, d2
    23dc: 9a9f57e0     	cset	x0, mi
    23e0: 52000000     	eor	w0, w0, #0x1
    23e4: 72001c1f     	tst	w0, #0xff
    23e8: 54013dc1     	b.ne	0x4ba0 <___pl_fn_0+0x4ba0>
    23ec: f942ebe0     	ldr	x0, [sp, #0x5d0]
    23f0: 34010e00     	cbz	w0, 0x45b0 <___pl_fn_0+0x45b0>
    23f4: f9424be0     	ldr	x0, [sp, #0x490]
    23f8: f9400001     	ldr	x1, [x0]
    23fc: f942ebe0     	ldr	x0, [sp, #0x5d0]
    2400: 2a0003e2     	mov	w2, w0
    2404: 8b020c21     	add	x1, x1, x2, lsl #3
    2408: f9400822     	ldr	x2, [x1, #0x10]
    240c: eb02039f     	cmp	x28, x2
    2410: 54000083     	b.lo	0x2420 <___pl_fn_0+0x2420>
    2414: 14000867     	b	0x45b0 <___pl_fn_0+0x45b0>
    2418: f942e7e0     	ldr	x0, [sp, #0x5c8]
    241c: 14000005     	b	0x2430 <___pl_fn_0+0x2430>
    2420: 4e083c09     	mov.d	x9, v0[0]
    2424: 8b1c0c2a     	add	x10, x1, x28, lsl #3
    2428: f9001549     	str	x9, [x10, #0x28]
    242c: f942e7e0     	ldr	x0, [sp, #0x5c8]
    2430: f942e7e0     	ldr	x0, [sp, #0x5c8]
    2434: 34010d60     	cbz	w0, 0x45e0 <___pl_fn_0+0x45e0>
    2438: f9424be0     	ldr	x0, [sp, #0x490]
    243c: f940000d     	ldr	x13, [x0]
    2440: f942e7e0     	ldr	x0, [sp, #0x5c8]
    2444: 2a0003ee     	mov	w14, w0
    2448: 8b0e0dad     	add	x13, x13, x14, lsl #3
    244c: f94009ae     	ldr	x14, [x13, #0x10]
    2450: eb0e039f     	cmp	x28, x14
    2454: 54010c62     	b.hs	0x45e0 <___pl_fn_0+0x45e0>
    2458: 8b1c0da0     	add	x0, x13, x28, lsl #3
    245c: fd401414     	ldr	d20, [x0, #0x28]
    2460: 1e742280     	fcmp	d20, d20
    2464: 540000e7     	b.vc	0x2480 <___pl_fn_0+0x2480>
    2468: 1400085e     	b	0x45e0 <___pl_fn_0+0x45e0>
    246c: f9424be0     	ldr	x0, [sp, #0x490]
    2470: f9401800     	ldr	x0, [x0, #0x30]
    2474: 9e670014     	fmov	d20, x0
    2478: 3d8137f4     	str	q20, [sp, #0x4d0]
    247c: 14000002     	b	0x2484 <___pl_fn_0+0x2484>
    2480: 3d8137f4     	str	q20, [sp, #0x4d0]
    2484: 34010c39     	cbz	w25, 0x4608 <___pl_fn_0+0x4608>
    2488: f9424be0     	ldr	x0, [sp, #0x490]
    248c: f9400000     	ldr	x0, [x0]
    2490: 2a1903e1     	mov	w1, w25
    2494: 8b010c00     	add	x0, x0, x1, lsl #3
    2498: f9400801     	ldr	x1, [x0, #0x10]
    249c: eb01035f     	cmp	x26, x1
    24a0: 54010b42     	b.hs	0x4608 <___pl_fn_0+0x4608>
    24a4: 8b1a0c00     	add	x0, x0, x26, lsl #3
    24a8: fd401400     	ldr	d0, [x0, #0x28]
    24ac: 1e602000     	fcmp	d0, d0
    24b0: 540000e7     	b.vc	0x24cc <___pl_fn_0+0x24cc>
    24b4: 14000855     	b	0x4608 <___pl_fn_0+0x4608>
    24b8: f9424be0     	ldr	x0, [sp, #0x490]
    24bc: f9401800     	ldr	x0, [x0, #0x30]
    24c0: 9e670000     	fmov	d0, x0
    24c4: 3dc143f0     	ldr	q16, [sp, #0x500]
    24c8: 14000002     	b	0x24d0 <___pl_fn_0+0x24d0>
    24cc: 3dc143f0     	ldr	q16, [sp, #0x500]
    24d0: 3dc143f0     	ldr	q16, [sp, #0x500]
    24d4: 1e600a00     	fmul	d0, d16, d0
    24d8: 1e60c001     	fabs	d1, d0
    24dc: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    24e0: 9e670002     	fmov	d2, x0
    24e4: 1e622020     	fcmp	d1, d2
    24e8: 9a9f57e0     	cset	x0, mi
    24ec: 52000000     	eor	w0, w0, #0x1
    24f0: 72001c1f     	tst	w0, #0xff
    24f4: 540133c1     	b.ne	0x4b6c <___pl_fn_0+0x4b6c>
    24f8: 3dc153f8     	ldr	q24, [sp, #0x540]
    24fc: 1e780800     	fmul	d0, d0, d24
    2500: 1e60c001     	fabs	d1, d0
    2504: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2508: 9e670002     	fmov	d2, x0
    250c: 1e622020     	fcmp	d1, d2
    2510: 9a9f57e0     	cset	x0, mi
    2514: 52000000     	eor	w0, w0, #0x1
    2518: 72001c1f     	tst	w0, #0xff
    251c: 540130e1     	b.ne	0x4b38 <___pl_fn_0+0x4b38>
    2520: 3dc137f4     	ldr	q20, [sp, #0x4d0]
    2524: 1e603a80     	fsub	d0, d20, d0
    2528: 1e60c001     	fabs	d1, d0
    252c: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2530: 9e670002     	fmov	d2, x0
    2534: 1e622020     	fcmp	d1, d2
    2538: 9a9f57e0     	cset	x0, mi
    253c: 52000000     	eor	w0, w0, #0x1
    2540: 72001c1f     	tst	w0, #0xff
    2544: 54012e01     	b.ne	0x4b04 <___pl_fn_0+0x4b04>
    2548: f942e7e0     	ldr	x0, [sp, #0x5c8]
    254c: 34010720     	cbz	w0, 0x4630 <___pl_fn_0+0x4630>
    2550: f9424be0     	ldr	x0, [sp, #0x490]
    2554: f9400000     	ldr	x0, [x0]
    2558: f942e7e1     	ldr	x1, [sp, #0x5c8]
    255c: 2a0103e1     	mov	w1, w1
    2560: 8b010c00     	add	x0, x0, x1, lsl #3
    2564: f9400801     	ldr	x1, [x0, #0x10]
    2568: eb01039f     	cmp	x28, x1
    256c: 54000083     	b.lo	0x257c <___pl_fn_0+0x257c>
    2570: 14000830     	b	0x4630 <___pl_fn_0+0x4630>
    2574: f942e3e0     	ldr	x0, [sp, #0x5c0]
    2578: 14000005     	b	0x258c <___pl_fn_0+0x258c>
    257c: 4e083c01     	mov.d	x1, v0[0]
    2580: 8b1c0c00     	add	x0, x0, x28, lsl #3
    2584: f9001401     	str	x1, [x0, #0x28]
    2588: f942e3e0     	ldr	x0, [sp, #0x5c0]
    258c: f942e3e0     	ldr	x0, [sp, #0x5c0]
    2590: 34010680     	cbz	w0, 0x4660 <___pl_fn_0+0x4660>
    2594: f9424be0     	ldr	x0, [sp, #0x490]
    2598: f9400000     	ldr	x0, [x0]
    259c: f942e3e1     	ldr	x1, [sp, #0x5c0]
    25a0: 2a0103e1     	mov	w1, w1
    25a4: 8b010c00     	add	x0, x0, x1, lsl #3
    25a8: f9400801     	ldr	x1, [x0, #0x10]
    25ac: eb01039f     	cmp	x28, x1
    25b0: 54010582     	b.hs	0x4660 <___pl_fn_0+0x4660>
    25b4: 8b1c0c00     	add	x0, x0, x28, lsl #3
    25b8: fd401400     	ldr	d0, [x0, #0x28]
    25bc: 1e602000     	fcmp	d0, d0
    25c0: 540000e7     	b.vc	0x25dc <___pl_fn_0+0x25dc>
    25c4: 14000827     	b	0x4660 <___pl_fn_0+0x4660>
    25c8: f9424be0     	ldr	x0, [sp, #0x490]
    25cc: f9401806     	ldr	x6, [x0, #0x30]
    25d0: 9e6700c0     	fmov	d0, x6
    25d4: 3d8137e0     	str	q0, [sp, #0x4d0]
    25d8: 14000002     	b	0x25e0 <___pl_fn_0+0x25e0>
    25dc: 3d8137e0     	str	q0, [sp, #0x4d0]
    25e0: 34010559     	cbz	w25, 0x4688 <___pl_fn_0+0x4688>
    25e4: f9424be0     	ldr	x0, [sp, #0x490]
    25e8: f940000a     	ldr	x10, [x0]
    25ec: 2a1903eb     	mov	w11, w25
    25f0: 8b0b0d4a     	add	x10, x10, x11, lsl #3
    25f4: f940094b     	ldr	x11, [x10, #0x10]
    25f8: eb0b035f     	cmp	x26, x11
    25fc: 54010462     	b.hs	0x4688 <___pl_fn_0+0x4688>
    2600: 8b1a0d4d     	add	x13, x10, x26, lsl #3
    2604: fd4015b6     	ldr	d22, [x13, #0x28]
    2608: 1e7622c0     	fcmp	d22, d22
    260c: 540000e7     	b.vc	0x2628 <___pl_fn_0+0x2628>
    2610: 1400081e     	b	0x4688 <___pl_fn_0+0x4688>
    2614: f9424be0     	ldr	x0, [sp, #0x490]
    2618: f9401800     	ldr	x0, [x0, #0x30]
    261c: 9e670016     	fmov	d22, x0
    2620: 3dc147e0     	ldr	q0, [sp, #0x510]
    2624: 14000002     	b	0x262c <___pl_fn_0+0x262c>
    2628: 3dc147e0     	ldr	q0, [sp, #0x510]
    262c: 3dc147e0     	ldr	q0, [sp, #0x510]
    2630: 1e760815     	fmul	d21, d0, d22
    2634: 1e60c2b6     	fabs	d22, d21
    2638: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    263c: 9e670017     	fmov	d23, x0
    2640: 1e7722c0     	fcmp	d22, d23
    2644: 9a9f57e0     	cset	x0, mi
    2648: 52000000     	eor	w0, w0, #0x1
    264c: 72001c1f     	tst	w0, #0xff
    2650: 54012401     	b.ne	0x4ad0 <___pl_fn_0+0x4ad0>
    2654: 3dc153e0     	ldr	q0, [sp, #0x540]
    2658: 1e600ab8     	fmul	d24, d21, d0
    265c: 1e60c319     	fabs	d25, d24
    2660: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2664: 9e67001a     	fmov	d26, x0
    2668: 1e7a2320     	fcmp	d25, d26
    266c: 9a9f57e0     	cset	x0, mi
    2670: 52000000     	eor	w0, w0, #0x1
    2674: 72001c1f     	tst	w0, #0xff
    2678: 54012121     	b.ne	0x4a9c <___pl_fn_0+0x4a9c>
    267c: 3dc137e0     	ldr	q0, [sp, #0x4d0]
    2680: 1e78381b     	fsub	d27, d0, d24
    2684: 1e60c37c     	fabs	d28, d27
    2688: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    268c: 9e67001d     	fmov	d29, x0
    2690: 1e7d2380     	fcmp	d28, d29
    2694: 9a9f57e0     	cset	x0, mi
    2698: 52000000     	eor	w0, w0, #0x1
    269c: 72001c1f     	tst	w0, #0xff
    26a0: 54011e41     	b.ne	0x4a68 <___pl_fn_0+0x4a68>
    26a4: f942e3e0     	ldr	x0, [sp, #0x5c0]
    26a8: 34010040     	cbz	w0, 0x46b0 <___pl_fn_0+0x46b0>
    26ac: f9424be0     	ldr	x0, [sp, #0x490]
    26b0: f9400000     	ldr	x0, [x0]
    26b4: f942e3e1     	ldr	x1, [sp, #0x5c0]
    26b8: 2a0103e1     	mov	w1, w1
    26bc: 8b010c00     	add	x0, x0, x1, lsl #3
    26c0: f9400801     	ldr	x1, [x0, #0x10]
    26c4: eb01039f     	cmp	x28, x1
    26c8: 54000083     	b.lo	0x26d8 <___pl_fn_0+0x26d8>
    26cc: 140007f9     	b	0x46b0 <___pl_fn_0+0x46b0>
    26d0: f942ebe0     	ldr	x0, [sp, #0x5d0]
    26d4: 14000005     	b	0x26e8 <___pl_fn_0+0x26e8>
    26d8: 4e083f61     	mov.d	x1, v27[0]
    26dc: 8b1c0c00     	add	x0, x0, x28, lsl #3
    26e0: f9001401     	str	x1, [x0, #0x28]
    26e4: f942ebe0     	ldr	x0, [sp, #0x5d0]
    26e8: f942ebe0     	ldr	x0, [sp, #0x5d0]
    26ec: 3400ffa0     	cbz	w0, 0x46e0 <___pl_fn_0+0x46e0>
    26f0: f9424be0     	ldr	x0, [sp, #0x490]
    26f4: f9400000     	ldr	x0, [x0]
    26f8: f942ebec     	ldr	x12, [sp, #0x5d0]
    26fc: 2a0c03e1     	mov	w1, w12
    2700: 8b010c00     	add	x0, x0, x1, lsl #3
    2704: f9400801     	ldr	x1, [x0, #0x10]
    2708: eb01035f     	cmp	x26, x1
    270c: 5400fea2     	b.hs	0x46e0 <___pl_fn_0+0x46e0>
    2710: 8b1a0c00     	add	x0, x0, x26, lsl #3
    2714: fd401400     	ldr	d0, [x0, #0x28]
    2718: 1e602000     	fcmp	d0, d0
    271c: 540000e7     	b.vc	0x2738 <___pl_fn_0+0x2738>
    2720: 140007f0     	b	0x46e0 <___pl_fn_0+0x46e0>
    2724: f9424be0     	ldr	x0, [sp, #0x490]
    2728: f9401800     	ldr	x0, [x0, #0x30]
    272c: 9e670000     	fmov	d0, x0
    2730: 3d8137e0     	str	q0, [sp, #0x4d0]
    2734: 14000002     	b	0x273c <___pl_fn_0+0x273c>
    2738: 3d8137e0     	str	q0, [sp, #0x4d0]
    273c: 3400fe79     	cbz	w25, 0x4708 <___pl_fn_0+0x4708>
    2740: f9424be0     	ldr	x0, [sp, #0x490]
    2744: f9400000     	ldr	x0, [x0]
    2748: 2a1903e1     	mov	w1, w25
    274c: 8b010c00     	add	x0, x0, x1, lsl #3
    2750: f9400801     	ldr	x1, [x0, #0x10]
    2754: eb01039f     	cmp	x28, x1
    2758: 5400fd82     	b.hs	0x4708 <___pl_fn_0+0x4708>
    275c: 8b1c0c00     	add	x0, x0, x28, lsl #3
    2760: fd401400     	ldr	d0, [x0, #0x28]
    2764: 1e602000     	fcmp	d0, d0
    2768: 540000e7     	b.vc	0x2784 <___pl_fn_0+0x2784>
    276c: 140007e7     	b	0x4708 <___pl_fn_0+0x4708>
    2770: f9424be0     	ldr	x0, [sp, #0x490]
    2774: f9401803     	ldr	x3, [x0, #0x30]
    2778: 9e670060     	fmov	d0, x3
    277c: 3dc13fe3     	ldr	q3, [sp, #0x4f0]
    2780: 14000002     	b	0x2788 <___pl_fn_0+0x2788>
    2784: 3dc13fe3     	ldr	q3, [sp, #0x4f0]
    2788: 3dc13fe3     	ldr	q3, [sp, #0x4f0]
    278c: 1e600865     	fmul	d5, d3, d0
    2790: 1e60c0a6     	fabs	d6, d5
    2794: d2effe04     	mov	x4, #0x7ff0000000000000 ; =9218868437227405312
    2798: 9e670087     	fmov	d7, x4
    279c: 1e6720c0     	fcmp	d6, d7
    27a0: 9a9f57e6     	cset	x6, mi
    27a4: 520000c6     	eor	w6, w6, #0x1
    27a8: 72001cdf     	tst	w6, #0xff
    27ac: 54011441     	b.ne	0x4a34 <___pl_fn_0+0x4a34>
    27b0: 3dc153e0     	ldr	q0, [sp, #0x540]
    27b4: 1e6008b0     	fmul	d16, d5, d0
    27b8: 1e60c211     	fabs	d17, d16
    27bc: d2effe07     	mov	x7, #0x7ff0000000000000 ; =9218868437227405312
    27c0: 9e6700f2     	fmov	d18, x7
    27c4: 1e722220     	fcmp	d17, d18
    27c8: 9a9f57e9     	cset	x9, mi
    27cc: 52000129     	eor	w9, w9, #0x1
    27d0: 72001d3f     	tst	w9, #0xff
    27d4: 54011161     	b.ne	0x4a00 <___pl_fn_0+0x4a00>
    27d8: 3dc137e0     	ldr	q0, [sp, #0x4d0]
    27dc: 1e702810     	fadd	d16, d0, d16
    27e0: 1e60c211     	fabs	d17, d16
    27e4: d2effe0a     	mov	x10, #0x7ff0000000000000 ; =9218868437227405312
    27e8: 9e670152     	fmov	d18, x10
    27ec: 1e722220     	fcmp	d17, d18
    27f0: 9a9f57ec     	cset	x12, mi
    27f4: 5200018c     	eor	w12, w12, #0x1
    27f8: 72001d9f     	tst	w12, #0xff
    27fc: 54010e81     	b.ne	0x49cc <___pl_fn_0+0x49cc>
    2800: f942ebe0     	ldr	x0, [sp, #0x5d0]
    2804: 3400f960     	cbz	w0, 0x4730 <___pl_fn_0+0x4730>
    2808: f9424be0     	ldr	x0, [sp, #0x490]
    280c: f9400000     	ldr	x0, [x0]
    2810: f942ebe1     	ldr	x1, [sp, #0x5d0]
    2814: 2a0103e1     	mov	w1, w1
    2818: 8b010c00     	add	x0, x0, x1, lsl #3
    281c: f9400801     	ldr	x1, [x0, #0x10]
    2820: eb01035f     	cmp	x26, x1
    2824: 54000083     	b.lo	0x2834 <___pl_fn_0+0x2834>
    2828: 140007c2     	b	0x4730 <___pl_fn_0+0x4730>
    282c: f942e7e0     	ldr	x0, [sp, #0x5c8]
    2830: 14000005     	b	0x2844 <___pl_fn_0+0x2844>
    2834: 4e083e01     	mov.d	x1, v16[0]
    2838: 8b1a0c00     	add	x0, x0, x26, lsl #3
    283c: f9001401     	str	x1, [x0, #0x28]
    2840: f942e7e0     	ldr	x0, [sp, #0x5c8]
    2844: f942e7e0     	ldr	x0, [sp, #0x5c8]
    2848: 3400f8c0     	cbz	w0, 0x4760 <___pl_fn_0+0x4760>
    284c: f9424be0     	ldr	x0, [sp, #0x490]
    2850: f9400000     	ldr	x0, [x0]
    2854: f942e7e1     	ldr	x1, [sp, #0x5c8]
    2858: 2a0103e1     	mov	w1, w1
    285c: 8b010c00     	add	x0, x0, x1, lsl #3
    2860: f9400801     	ldr	x1, [x0, #0x10]
    2864: eb01035f     	cmp	x26, x1
    2868: 5400f7c2     	b.hs	0x4760 <___pl_fn_0+0x4760>
    286c: 8b1a0c00     	add	x0, x0, x26, lsl #3
    2870: fd401410     	ldr	d16, [x0, #0x28]
    2874: 1e702200     	fcmp	d16, d16
    2878: 540000e7     	b.vc	0x2894 <___pl_fn_0+0x2894>
    287c: 140007b9     	b	0x4760 <___pl_fn_0+0x4760>
    2880: f9424be0     	ldr	x0, [sp, #0x490]
    2884: f9401800     	ldr	x0, [x0, #0x30]
    2888: 9e670010     	fmov	d16, x0
    288c: 3d8137f0     	str	q16, [sp, #0x4d0]
    2890: 14000002     	b	0x2898 <___pl_fn_0+0x2898>
    2894: 3d8137f0     	str	q16, [sp, #0x4d0]
    2898: 3400f799     	cbz	w25, 0x4788 <___pl_fn_0+0x4788>
    289c: f9424be0     	ldr	x0, [sp, #0x490]
    28a0: f9400000     	ldr	x0, [x0]
    28a4: 2a1903e1     	mov	w1, w25
    28a8: 8b010c00     	add	x0, x0, x1, lsl #3
    28ac: f9400801     	ldr	x1, [x0, #0x10]
    28b0: eb01039f     	cmp	x28, x1
    28b4: 5400f6a2     	b.hs	0x4788 <___pl_fn_0+0x4788>
    28b8: 8b1c0c00     	add	x0, x0, x28, lsl #3
    28bc: fd401400     	ldr	d0, [x0, #0x28]
    28c0: 1e602000     	fcmp	d0, d0
    28c4: 540000e7     	b.vc	0x28e0 <___pl_fn_0+0x28e0>
    28c8: 140007b0     	b	0x4788 <___pl_fn_0+0x4788>
    28cc: f9424be0     	ldr	x0, [sp, #0x490]
    28d0: f9401800     	ldr	x0, [x0, #0x30]
    28d4: 9e670000     	fmov	d0, x0
    28d8: 3dc143e1     	ldr	q1, [sp, #0x500]
    28dc: 14000002     	b	0x28e4 <___pl_fn_0+0x28e4>
    28e0: 3dc143e1     	ldr	q1, [sp, #0x500]
    28e4: 3dc143e1     	ldr	q1, [sp, #0x500]
    28e8: 1e600820     	fmul	d0, d1, d0
    28ec: 1e60c001     	fabs	d1, d0
    28f0: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    28f4: 9e670002     	fmov	d2, x0
    28f8: 1e622020     	fcmp	d1, d2
    28fc: 9a9f57e0     	cset	x0, mi
    2900: 52000000     	eor	w0, w0, #0x1
    2904: 72001c1f     	tst	w0, #0xff
    2908: 54010481     	b.ne	0x4998 <___pl_fn_0+0x4998>
    290c: 3dc153f0     	ldr	q16, [sp, #0x540]
    2910: 1e700800     	fmul	d0, d0, d16
    2914: 1e60c001     	fabs	d1, d0
    2918: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    291c: 9e670002     	fmov	d2, x0
    2920: 1e622020     	fcmp	d1, d2
    2924: 9a9f57e0     	cset	x0, mi
    2928: 52000000     	eor	w0, w0, #0x1
    292c: 72001c1f     	tst	w0, #0xff
    2930: 540101a1     	b.ne	0x4964 <___pl_fn_0+0x4964>
    2934: 3dc137f0     	ldr	q16, [sp, #0x4d0]
    2938: 1e602a00     	fadd	d0, d16, d0
    293c: 1e60c001     	fabs	d1, d0
    2940: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2944: 9e670002     	fmov	d2, x0
    2948: 1e622020     	fcmp	d1, d2
    294c: 9a9f57e0     	cset	x0, mi
    2950: 52000000     	eor	w0, w0, #0x1
    2954: 72001c1f     	tst	w0, #0xff
    2958: 5400fec1     	b.ne	0x4930 <___pl_fn_0+0x4930>
    295c: f942e7e0     	ldr	x0, [sp, #0x5c8]
    2960: 3400f280     	cbz	w0, 0x47b0 <___pl_fn_0+0x47b0>
    2964: f9424be0     	ldr	x0, [sp, #0x490]
    2968: f9400000     	ldr	x0, [x0]
    296c: f942e7e1     	ldr	x1, [sp, #0x5c8]
    2970: 2a0103e1     	mov	w1, w1
    2974: 8b010c00     	add	x0, x0, x1, lsl #3
    2978: f9400801     	ldr	x1, [x0, #0x10]
    297c: eb01035f     	cmp	x26, x1
    2980: 54000083     	b.lo	0x2990 <___pl_fn_0+0x2990>
    2984: 1400078b     	b	0x47b0 <___pl_fn_0+0x47b0>
    2988: f942e3e0     	ldr	x0, [sp, #0x5c0]
    298c: 14000005     	b	0x29a0 <___pl_fn_0+0x29a0>
    2990: 4e083c08     	mov.d	x8, v0[0]
    2994: 8b1a0c09     	add	x9, x0, x26, lsl #3
    2998: f9001528     	str	x8, [x9, #0x28]
    299c: f942e3e0     	ldr	x0, [sp, #0x5c0]
    29a0: f942e3e0     	ldr	x0, [sp, #0x5c0]
    29a4: 3400f1e0     	cbz	w0, 0x47e0 <___pl_fn_0+0x47e0>
    29a8: f9424be0     	ldr	x0, [sp, #0x490]
    29ac: f940000c     	ldr	x12, [x0]
    29b0: f942e3e0     	ldr	x0, [sp, #0x5c0]
    29b4: 2a0003ed     	mov	w13, w0
    29b8: 8b0d0d8c     	add	x12, x12, x13, lsl #3
    29bc: f940098d     	ldr	x13, [x12, #0x10]
    29c0: eb0d035f     	cmp	x26, x13
    29c4: 5400f0e2     	b.hs	0x47e0 <___pl_fn_0+0x47e0>
    29c8: 8b1a0d8f     	add	x15, x12, x26, lsl #3
    29cc: fd4015e0     	ldr	d0, [x15, #0x28]
    29d0: 1e602000     	fcmp	d0, d0
    29d4: 540000e7     	b.vc	0x29f0 <___pl_fn_0+0x29f0>
    29d8: 14000782     	b	0x47e0 <___pl_fn_0+0x47e0>
    29dc: f9424be0     	ldr	x0, [sp, #0x490]
    29e0: f9401800     	ldr	x0, [x0, #0x30]
    29e4: 9e670000     	fmov	d0, x0
    29e8: 3d8137e0     	str	q0, [sp, #0x4d0]
    29ec: 14000002     	b	0x29f4 <___pl_fn_0+0x29f4>
    29f0: 3d8137e0     	str	q0, [sp, #0x4d0]
    29f4: 3400f0b9     	cbz	w25, 0x4808 <___pl_fn_0+0x4808>
    29f8: f9424be0     	ldr	x0, [sp, #0x490]
    29fc: f9400000     	ldr	x0, [x0]
    2a00: 2a1903e1     	mov	w1, w25
    2a04: 8b010c00     	add	x0, x0, x1, lsl #3
    2a08: f9400801     	ldr	x1, [x0, #0x10]
    2a0c: eb01039f     	cmp	x28, x1
    2a10: 5400efc2     	b.hs	0x4808 <___pl_fn_0+0x4808>
    2a14: 8b1c0c00     	add	x0, x0, x28, lsl #3
    2a18: fd401410     	ldr	d16, [x0, #0x28]
    2a1c: 1e702200     	fcmp	d16, d16
    2a20: 540000e7     	b.vc	0x2a3c <___pl_fn_0+0x2a3c>
    2a24: 14000779     	b	0x4808 <___pl_fn_0+0x4808>
    2a28: f9424be0     	ldr	x0, [sp, #0x490]
    2a2c: f9401800     	ldr	x0, [x0, #0x30]
    2a30: 9e670010     	fmov	d16, x0
    2a34: 3dc147e0     	ldr	q0, [sp, #0x510]
    2a38: 14000002     	b	0x2a40 <___pl_fn_0+0x2a40>
    2a3c: 3dc147e0     	ldr	q0, [sp, #0x510]
    2a40: 3dc147e0     	ldr	q0, [sp, #0x510]
    2a44: 1e700800     	fmul	d0, d0, d16
    2a48: 1e60c001     	fabs	d1, d0
    2a4c: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2a50: 9e670002     	fmov	d2, x0
    2a54: 1e622020     	fcmp	d1, d2
    2a58: 9a9f57e0     	cset	x0, mi
    2a5c: 52000000     	eor	w0, w0, #0x1
    2a60: 72001c1f     	tst	w0, #0xff
    2a64: 5400f4c1     	b.ne	0x48fc <___pl_fn_0+0x48fc>
    2a68: 3dc153e1     	ldr	q1, [sp, #0x540]
    2a6c: 1e610800     	fmul	d0, d0, d1
    2a70: 1e60c001     	fabs	d1, d0
    2a74: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2a78: 9e670002     	fmov	d2, x0
    2a7c: 1e622020     	fcmp	d1, d2
    2a80: 9a9f57e0     	cset	x0, mi
    2a84: 52000000     	eor	w0, w0, #0x1
    2a88: 72001c1f     	tst	w0, #0xff
    2a8c: 5400f1e1     	b.ne	0x48c8 <___pl_fn_0+0x48c8>
    2a90: 3dc137f7     	ldr	q23, [sp, #0x4d0]
    2a94: 1e602ae0     	fadd	d0, d23, d0
    2a98: 1e60c001     	fabs	d1, d0
    2a9c: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2aa0: 9e670002     	fmov	d2, x0
    2aa4: 1e622020     	fcmp	d1, d2
    2aa8: 9a9f57e0     	cset	x0, mi
    2aac: 52000000     	eor	w0, w0, #0x1
    2ab0: 72001c1f     	tst	w0, #0xff
    2ab4: 5400ef01     	b.ne	0x4894 <___pl_fn_0+0x4894>
    2ab8: f942e3e0     	ldr	x0, [sp, #0x5c0]
    2abc: 3400eba0     	cbz	w0, 0x4830 <___pl_fn_0+0x4830>
    2ac0: f9424be0     	ldr	x0, [sp, #0x490]
    2ac4: f9400000     	ldr	x0, [x0]
    2ac8: f942e3e1     	ldr	x1, [sp, #0x5c0]
    2acc: 2a0103e1     	mov	w1, w1
    2ad0: 8b010c00     	add	x0, x0, x1, lsl #3
    2ad4: f9400801     	ldr	x1, [x0, #0x10]
    2ad8: eb01035f     	cmp	x26, x1
    2adc: 54000083     	b.lo	0x2aec <___pl_fn_0+0x2aec>
    2ae0: 14000754     	b	0x4830 <___pl_fn_0+0x4830>
    2ae4: f942abec     	ldr	x12, [sp, #0x550]
    2ae8: 14000005     	b	0x2afc <___pl_fn_0+0x2afc>
    2aec: 4e083c01     	mov.d	x1, v0[0]
    2af0: 8b1a0c00     	add	x0, x0, x26, lsl #3
    2af4: f9001401     	str	x1, [x0, #0x28]
    2af8: f942abec     	ldr	x12, [sp, #0x550]
    2afc: ab0c035a     	adds	x26, x26, x12
    2b00: 9a9f77e0     	cset	x0, vs
    2b04: 72001c1f     	tst	w0, #0xff
    2b08: 5400eac1     	b.ne	0x4860 <___pl_fn_0+0x4860>
    2b0c: 52800036     	mov	w22, #0x1               ; =1
    2b10: aa1403e0     	mov	x0, x20
    2b14: aa1703ea     	mov	x10, x23
    2b18: 17fffcdf     	b	0x1e94 <___pl_fn_0+0x1e94>
    2b1c: f942ebe0     	ldr	x0, [sp, #0x5d0]
    2b20: 3d812bf0     	str	q16, [sp, #0x4a0]
    2b24: 340144e0     	cbz	w0, 0x53c0 <___pl_fn_0+0x53c0>
    2b28: f9424be0     	ldr	x0, [sp, #0x490]
    2b2c: f9400000     	ldr	x0, [x0]
    2b30: f942ebe1     	ldr	x1, [sp, #0x5d0]
    2b34: 2a0103e1     	mov	w1, w1
    2b38: 8b010c00     	add	x0, x0, x1, lsl #3
    2b3c: f9400801     	ldr	x1, [x0, #0x10]
    2b40: eb01039f     	cmp	x28, x1
    2b44: 540143e2     	b.hs	0x53c0 <___pl_fn_0+0x53c0>
    2b48: 8b1c0c00     	add	x0, x0, x28, lsl #3
    2b4c: fd401404     	ldr	d4, [x0, #0x28]
    2b50: 1e642080     	fcmp	d4, d4
    2b54: 540000e7     	b.vc	0x2b70 <___pl_fn_0+0x2b70>
    2b58: 14000a1a     	b	0x53c0 <___pl_fn_0+0x53c0>
    2b5c: f9424be0     	ldr	x0, [sp, #0x490]
    2b60: f9401801     	ldr	x1, [x0, #0x30]
    2b64: 9e670024     	fmov	d4, x1
    2b68: 3d8137e4     	str	q4, [sp, #0x4d0]
    2b6c: 14000002     	b	0x2b74 <___pl_fn_0+0x2b74>
    2b70: 3d8137e4     	str	q4, [sp, #0x4d0]
    2b74: 340143b9     	cbz	w25, 0x53e8 <___pl_fn_0+0x53e8>
    2b78: f9424be0     	ldr	x0, [sp, #0x490]
    2b7c: f9400005     	ldr	x5, [x0]
    2b80: 2a1903e6     	mov	w6, w25
    2b84: 8b060ca5     	add	x5, x5, x6, lsl #3
    2b88: f94008a6     	ldr	x6, [x5, #0x10]
    2b8c: eb06039f     	cmp	x28, x6
    2b90: 540142c2     	b.hs	0x53e8 <___pl_fn_0+0x53e8>
    2b94: 8b1c0ca8     	add	x8, x5, x28, lsl #3
    2b98: fd40151e     	ldr	d30, [x8, #0x28]
    2b9c: 1e7e23c0     	fcmp	d30, d30
    2ba0: 540000e7     	b.vc	0x2bbc <___pl_fn_0+0x2bbc>
    2ba4: 14000a11     	b	0x53e8 <___pl_fn_0+0x53e8>
    2ba8: f9424be0     	ldr	x0, [sp, #0x490]
    2bac: f940180e     	ldr	x14, [x0, #0x30]
    2bb0: 9e6701de     	fmov	d30, x14
    2bb4: 3dc137e4     	ldr	q4, [sp, #0x4d0]
    2bb8: 14000002     	b	0x2bc0 <___pl_fn_0+0x2bc0>
    2bbc: 3dc137e4     	ldr	q4, [sp, #0x4d0]
    2bc0: 1e7e0891     	fmul	d17, d4, d30
    2bc4: 1e60c230     	fabs	d16, d17
    2bc8: d2effe0f     	mov	x15, #0x7ff0000000000000 ; =9218868437227405312
    2bcc: 9e6701f2     	fmov	d18, x15
    2bd0: 1e722200     	fcmp	d16, d18
    2bd4: 9a9f57e0     	cset	x0, mi
    2bd8: 52000000     	eor	w0, w0, #0x1
    2bdc: 72001c1f     	tst	w0, #0xff
    2be0: 54015521     	b.ne	0x5684 <___pl_fn_0+0x5684>
    2be4: 3dc12bf0     	ldr	q16, [sp, #0x4a0]
    2be8: 1e712a10     	fadd	d16, d16, d17
    2bec: 1e60c213     	fabs	d19, d16
    2bf0: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2bf4: 9e670014     	fmov	d20, x0
    2bf8: 1e742260     	fcmp	d19, d20
    2bfc: 9a9f57e0     	cset	x0, mi
    2c00: 52000000     	eor	w0, w0, #0x1
    2c04: 72001c1f     	tst	w0, #0xff
    2c08: 54015241     	b.ne	0x5650 <___pl_fn_0+0x5650>
    2c0c: 1e702200     	fcmp	d16, d16
    2c10: 3d812bf0     	str	q16, [sp, #0x4a0]
    2c14: 54015041     	b.ne	0x561c <___pl_fn_0+0x561c>
    2c18: f942e7e0     	ldr	x0, [sp, #0x5c8]
    2c1c: 34013fa0     	cbz	w0, 0x5410 <___pl_fn_0+0x5410>
    2c20: f9424be0     	ldr	x0, [sp, #0x490]
    2c24: f9400000     	ldr	x0, [x0]
    2c28: f942e7e1     	ldr	x1, [sp, #0x5c8]
    2c2c: 2a0103e1     	mov	w1, w1
    2c30: 8b010c00     	add	x0, x0, x1, lsl #3
    2c34: f9400801     	ldr	x1, [x0, #0x10]
    2c38: eb01039f     	cmp	x28, x1
    2c3c: 54013ea2     	b.hs	0x5410 <___pl_fn_0+0x5410>
    2c40: 8b1c0c00     	add	x0, x0, x28, lsl #3
    2c44: fd401410     	ldr	d16, [x0, #0x28]
    2c48: 1e702200     	fcmp	d16, d16
    2c4c: 540000e7     	b.vc	0x2c68 <___pl_fn_0+0x2c68>
    2c50: 140009f0     	b	0x5410 <___pl_fn_0+0x5410>
    2c54: f9424be0     	ldr	x0, [sp, #0x490]
    2c58: f9401800     	ldr	x0, [x0, #0x30]
    2c5c: 9e670010     	fmov	d16, x0
    2c60: 3d8137f0     	str	q16, [sp, #0x4d0]
    2c64: 14000002     	b	0x2c6c <___pl_fn_0+0x2c6c>
    2c68: 3d8137f0     	str	q16, [sp, #0x4d0]
    2c6c: 34013e79     	cbz	w25, 0x5438 <___pl_fn_0+0x5438>
    2c70: f9424be0     	ldr	x0, [sp, #0x490]
    2c74: f9400000     	ldr	x0, [x0]
    2c78: 2a1903e1     	mov	w1, w25
    2c7c: 8b010c00     	add	x0, x0, x1, lsl #3
    2c80: f9400801     	ldr	x1, [x0, #0x10]
    2c84: eb01039f     	cmp	x28, x1
    2c88: 54013d82     	b.hs	0x5438 <___pl_fn_0+0x5438>
    2c8c: 8b1c0c00     	add	x0, x0, x28, lsl #3
    2c90: fd401400     	ldr	d0, [x0, #0x28]
    2c94: 1e602000     	fcmp	d0, d0
    2c98: 540000e7     	b.vc	0x2cb4 <___pl_fn_0+0x2cb4>
    2c9c: 140009e7     	b	0x5438 <___pl_fn_0+0x5438>
    2ca0: f9424be0     	ldr	x0, [sp, #0x490]
    2ca4: f9401800     	ldr	x0, [x0, #0x30]
    2ca8: 9e670000     	fmov	d0, x0
    2cac: 3dc137f0     	ldr	q16, [sp, #0x4d0]
    2cb0: 14000002     	b	0x2cb8 <___pl_fn_0+0x2cb8>
    2cb4: 3dc137f0     	ldr	q16, [sp, #0x4d0]
    2cb8: 1e600a00     	fmul	d0, d16, d0
    2cbc: 1e60c001     	fabs	d1, d0
    2cc0: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2cc4: 9e670002     	fmov	d2, x0
    2cc8: 1e622020     	fcmp	d1, d2
    2ccc: 9a9f57e0     	cset	x0, mi
    2cd0: 52000000     	eor	w0, w0, #0x1
    2cd4: 72001c1f     	tst	w0, #0xff
    2cd8: 54014881     	b.ne	0x55e8 <___pl_fn_0+0x55e8>
    2cdc: 3dc12ff1     	ldr	q17, [sp, #0x4b0]
    2ce0: 1e602a31     	fadd	d17, d17, d0
    2ce4: 3d812ff1     	str	q17, [sp, #0x4b0]
    2ce8: 1e60c220     	fabs	d0, d17
    2cec: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2cf0: 9e670001     	fmov	d1, x0
    2cf4: 1e612000     	fcmp	d0, d1
    2cf8: 9a9f57e0     	cset	x0, mi
    2cfc: 52000000     	eor	w0, w0, #0x1
    2d00: 72001c1f     	tst	w0, #0xff
    2d04: 54014581     	b.ne	0x55b4 <___pl_fn_0+0x55b4>
    2d08: 3dc12fe0     	ldr	q0, [sp, #0x4b0]
    2d0c: 3dc12ff1     	ldr	q17, [sp, #0x4b0]
    2d10: 1e602220     	fcmp	d17, d0
    2d14: 54014361     	b.ne	0x5580 <___pl_fn_0+0x5580>
    2d18: f942e3e0     	ldr	x0, [sp, #0x5c0]
    2d1c: 34013a20     	cbz	w0, 0x5460 <___pl_fn_0+0x5460>
    2d20: f9424be0     	ldr	x0, [sp, #0x490]
    2d24: f9400000     	ldr	x0, [x0]
    2d28: f942e3e1     	ldr	x1, [sp, #0x5c0]
    2d2c: 2a0103e1     	mov	w1, w1
    2d30: 8b010c00     	add	x0, x0, x1, lsl #3
    2d34: f9400801     	ldr	x1, [x0, #0x10]
    2d38: eb01039f     	cmp	x28, x1
    2d3c: 54013922     	b.hs	0x5460 <___pl_fn_0+0x5460>
    2d40: 8b1c0c00     	add	x0, x0, x28, lsl #3
    2d44: fd401416     	ldr	d22, [x0, #0x28]
    2d48: 1e7622c0     	fcmp	d22, d22
    2d4c: 540000e7     	b.vc	0x2d68 <___pl_fn_0+0x2d68>
    2d50: 140009c4     	b	0x5460 <___pl_fn_0+0x5460>
    2d54: f9424be0     	ldr	x0, [sp, #0x490]
    2d58: f9401806     	ldr	x6, [x0, #0x30]
    2d5c: 9e6700d6     	fmov	d22, x6
    2d60: 3d8137f6     	str	q22, [sp, #0x4d0]
    2d64: 14000002     	b	0x2d6c <___pl_fn_0+0x2d6c>
    2d68: 3d8137f6     	str	q22, [sp, #0x4d0]
    2d6c: 340138f9     	cbz	w25, 0x5488 <___pl_fn_0+0x5488>
    2d70: f9424be0     	ldr	x0, [sp, #0x490]
    2d74: f940000a     	ldr	x10, [x0]
    2d78: 2a1903eb     	mov	w11, w25
    2d7c: 8b0b0d4a     	add	x10, x10, x11, lsl #3
    2d80: f940094b     	ldr	x11, [x10, #0x10]
    2d84: eb0b039f     	cmp	x28, x11
    2d88: 54013802     	b.hs	0x5488 <___pl_fn_0+0x5488>
    2d8c: 8b1c0d4d     	add	x13, x10, x28, lsl #3
    2d90: fd4015a0     	ldr	d0, [x13, #0x28]
    2d94: 1e602000     	fcmp	d0, d0
    2d98: 540000e7     	b.vc	0x2db4 <___pl_fn_0+0x2db4>
    2d9c: 140009bb     	b	0x5488 <___pl_fn_0+0x5488>
    2da0: f9424be0     	ldr	x0, [sp, #0x490]
    2da4: f9401800     	ldr	x0, [x0, #0x30]
    2da8: 9e670000     	fmov	d0, x0
    2dac: 3dc137f6     	ldr	q22, [sp, #0x4d0]
    2db0: 14000002     	b	0x2db8 <___pl_fn_0+0x2db8>
    2db4: 3dc137f6     	ldr	q22, [sp, #0x4d0]
    2db8: 1e600ad5     	fmul	d21, d22, d0
    2dbc: 1e60c2b6     	fabs	d22, d21
    2dc0: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2dc4: 9e670017     	fmov	d23, x0
    2dc8: 1e7722c0     	fcmp	d22, d23
    2dcc: 9a9f57e0     	cset	x0, mi
    2dd0: 52000000     	eor	w0, w0, #0x1
    2dd4: 72001c1f     	tst	w0, #0xff
    2dd8: 54013ba1     	b.ne	0x554c <___pl_fn_0+0x554c>
    2ddc: 3dc133f2     	ldr	q18, [sp, #0x4c0]
    2de0: 1e752a52     	fadd	d18, d18, d21
    2de4: 1e60c258     	fabs	d24, d18
    2de8: d2effe00     	mov	x0, #0x7ff0000000000000 ; =9218868437227405312
    2dec: 9e670019     	fmov	d25, x0
    2df0: 1e792300     	fcmp	d24, d25
    2df4: 9a9f57e0     	cset	x0, mi
    2df8: 52000000     	eor	w0, w0, #0x1
    2dfc: 72001c1f     	tst	w0, #0xff
    2e00: 540138c1     	b.ne	0x5518 <___pl_fn_0+0x5518>
    2e04: 1e722240     	fcmp	d18, d18
    2e08: 540136e1     	b.ne	0x54e4 <___pl_fn_0+0x54e4>
    2e0c: ab1b039c     	adds	x28, x28, x27
    2e10: 9a9f77e0     	cset	x0, vs
    2e14: 72001c1f     	tst	w0, #0xff
    2e18: 540134c1     	b.ne	0x54b0 <___pl_fn_0+0x54b0>
    2e1c: 52800034     	mov	w20, #0x1               ; =1
    2e20: 3dc12bf0     	ldr	q16, [sp, #0x4a0]
    2e24: 3d8133f2     	str	q18, [sp, #0x4c0]
    2e28: 17fff7d2     	b	0xd70 <___pl_fn_0+0xd70>
    2e2c: d2800002     	mov	x2, #0x0                ; =0
    2e30: 9100e3e3     	add	x3, sp, #0x38
    2e34: f80383e2     	stur	x2, [sp, #0x38]
    2e38: 0f000403     	movi.2s	v3, #0x0
    2e3c: 4e083c64     	mov.d	x4, v3[0]
    2e40: f80403e4     	stur	x4, [sp, #0x40]
    2e44: 52800281     	mov	w1, #0x14               ; =20
    2e48: 90000004     	adrp	x4, 0x2000 <___pl_fn_0+0x2000>
    2e4c: f9400084     	ldr	x4, [x4]
    2e50: f9424be0     	ldr	x0, [sp, #0x490]
    2e54: f942efe2     	ldr	x2, [sp, #0x5d8]
    2e58: d63f0080     	blr	x4
    2e5c: 34feaea0     	cbz	w0, 0x430 <___pl_fn_0+0x430>
    2e60: 14000bd0     	b	0x5da0 <___pl_fn_0+0x5da0>
    2e64: d280000d     	mov	x13, #0x0               ; =0
    2e68: 910123e3     	add	x3, sp, #0x48
    2e6c: f80483ed     	stur	x13, [sp, #0x48]
    2e70: 0f000410     	movi.2s	v16, #0x0
    2e74: 4e083e0e     	mov.d	x14, v16[0]
    2e78: f80503ee     	stur	x14, [sp, #0x50]
    2e7c: 528002a1     	mov	w1, #0x15               ; =21
    2e80: 9000000f     	adrp	x15, 0x2000 <___pl_fn_0+0x2000>
    2e84: f94001ef     	ldr	x15, [x15]
    2e88: f9424be0     	ldr	x0, [sp, #0x490]
    2e8c: aa1803e2     	mov	x2, x24
    2e90: d63f01e0     	blr	x15
    2e94: 34feae20     	cbz	w0, 0x458 <___pl_fn_0+0x458>
    2e98: 14000bc2     	b	0x5da0 <___pl_fn_0+0x5da0>
    2e9c: d2800000     	mov	x0, #0x0                ; =0
    2ea0: 910163e3     	add	x3, sp, #0x58
    2ea4: f80583e0     	stur	x0, [sp, #0x58]
    2ea8: 0f000419     	movi.2s	v25, #0x0
    2eac: 4e083f20     	mov.d	x0, v25[0]
    2eb0: f80603e0     	stur	x0, [sp, #0x60]
    2eb4: 528002c1     	mov	w1, #0x16               ; =22
    2eb8: 90000004     	adrp	x4, 0x2000 <___pl_fn_0+0x2000>
    2ebc: f9400084     	ldr	x4, [x4]
    2ec0: f9424be0     	ldr	x0, [sp, #0x490]
    2ec4: aa1503e2     	mov	x2, x21
    2ec8: d63f0080     	blr	x4
    2ecc: 34fead60     	cbz	w0, 0x478 <___pl_fn_0+0x478>
    2ed0: 14000bb4     	b	0x5da0 <___pl_fn_0+0x5da0>
    2ed4: d2800000     	mov	x0, #0x0                ; =0
    2ed8: 9101a3e3     	add	x3, sp, #0x68
    2edc: f80683e0     	stur	x0, [sp, #0x68]
    2ee0: 0f000400     	movi.2s	v0, #0x0
    2ee4: 4e083c00     	mov.d	x0, v0[0]
    2ee8: f80703e0     	stur	x0, [sp, #0x70]
    2eec: 528002e1     	mov	w1, #0x17               ; =23
    2ef0: 90000004     	adrp	x4, 0x2000 <___pl_fn_0+0x2000>
    2ef4: f9400084     	ldr	x4, [x4]
    2ef8: f9424be0     	ldr	x0, [sp, #0x490]
    2efc: f942ebe2     	ldr	x2, [sp, #0x5d0]
    2f00: d63f0080     	blr	x4
    2f04: 34feada0     	cbz	w0, 0x4b8 <___pl_fn_0+0x4b8>
    2f08: 14000ba6     	b	0x5da0 <___pl_fn_0+0x5da0>
    2f0c: d2800000     	mov	x0, #0x0                ; =0
    2f10: 9101e3e3     	add	x3, sp, #0x78
    2f14: f80783e0     	stur	x0, [sp, #0x78]
    2f18: 0f000400     	movi.2s	v0, #0x0
    2f1c: 4e083c00     	mov.d	x0, v0[0]
    2f20: f80803e0     	stur	x0, [sp, #0x80]
    2f24: 52800301     	mov	w1, #0x18               ; =24
    2f28: 90000004     	adrp	x4, 0x2000 <___pl_fn_0+0x2000>
    2f2c: f9400084     	ldr	x4, [x4]
    2f30: f9424be0     	ldr	x0, [sp, #0x490]
    2f34: f942e7e2     	ldr	x2, [sp, #0x5c8]
    2f38: d63f0080     	blr	x4
    2f3c: 34feade0     	cbz	w0, 0x4f8 <___pl_fn_0+0x4f8>
    2f40: 14000b98     	b	0x5da0 <___pl_fn_0+0x5da0>
    2f44: d2800000     	mov	x0, #0x0                ; =0
    2f48: 910223e3     	add	x3, sp, #0x88
    2f4c: f80883e0     	stur	x0, [sp, #0x88]
    2f50: 0f000400     	movi.2s	v0, #0x0
    2f54: 4e083c00     	mov.d	x0, v0[0]
    2f58: f80903e0     	stur	x0, [sp, #0x90]
    2f5c: 52800321     	mov	w1, #0x19               ; =25
    2f60: 90000004     	adrp	x4, 0x2000 <___pl_fn_0+0x2000>
    2f64: f9400084     	ldr	x4, [x4]
    2f68: f9424be0     	ldr	x0, [sp, #0x490]
    2f6c: f942e3e2     	ldr	x2, [sp, #0x5c0]
    2f70: d63f0080     	blr	x4
    2f74: 34feae40     	cbz	w0, 0x53c <___pl_fn_0+0x53c>
    2f78: 14000b8a     	b	0x5da0 <___pl_fn_0+0x5da0>
    2f7c: d2800005     	mov	x5, #0x0                ; =0
    2f80: 910263e3     	add	x3, sp, #0x98
    2f84: f80983e5     	stur	x5, [sp, #0x98]
    2f88: 5c017246     	ldr	d6, 0x5dd0 <___pl_fn_0+0x5dd0>
    2f8c: 4e083cc6     	mov.d	x6, v6[0]
    2f90: f80a03e6     	stur	x6, [sp, #0xa0]
    2f94: 52800341     	mov	w1, #0x1a               ; =26
    2f98: 90000007     	adrp	x7, 0x2000 <___pl_fn_0+0x2000>
    2f9c: f94000e7     	ldr	x7, [x7]
    2fa0: f9424be0     	ldr	x0, [sp, #0x490]
    2fa4: aa1903e2     	mov	x2, x25
    2fa8: d63f00e0     	blr	x7
    2fac: 34fead80     	cbz	w0, 0x55c <___pl_fn_0+0x55c>
    2fb0: 14000b7c     	b	0x5da0 <___pl_fn_0+0x5da0>
    2fb4: d2800020     	mov	x0, #0x1                ; =1
    2fb8: 9102a3e3     	add	x3, sp, #0xa8
    2fbc: f80a83e0     	stur	x0, [sp, #0xa8]
    2fc0: 5c017112     	ldr	d18, 0x5de0 <___pl_fn_0+0x5de0>
    2fc4: 4e083e40     	mov.d	x0, v18[0]
    2fc8: f80b03e0     	stur	x0, [sp, #0xb0]
    2fcc: 52800361     	mov	w1, #0x1b               ; =27
    2fd0: 90000004     	adrp	x4, 0x2000 <___pl_fn_0+0x2000>
    2fd4: f9400084     	ldr	x4, [x4]
    2fd8: f9424be0     	ldr	x0, [sp, #0x490]
    2fdc: f942efe2     	ldr	x2, [sp, #0x5d8]
    2fe0: d63f0080     	blr	x4
    2fe4: 34feae20     	cbz	w0, 0x5a8 <___pl_fn_0+0x5a8>
    2fe8: 14000b6e     	b	0x5da0 <___pl_fn_0+0x5da0>
    2fec: d2800020     	mov	x0, #0x1                ; =1
    2ff0: 9102e3e3     	add	x3, sp, #0xb8
    2ff4: f80b83e0     	stur	x0, [sp, #0xb8]
    2ff8: 5c016f9e     	ldr	d30, 0x5de8 <___pl_fn_0+0x5de8>
    2ffc: 4e083fc0     	mov.d	x0, v30[0]
    3000: f80c03e0     	stur	x0, [sp, #0xc0]
    3004: 52800381     	mov	w1, #0x1c               ; =28
    3008: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    300c: f9400084     	ldr	x4, [x4]
    3010: f9424be0     	ldr	x0, [sp, #0x490]
    3014: aa1803e2     	mov	x2, x24
    3018: d63f0080     	blr	x4
    301c: 34feadc0     	cbz	w0, 0x5d4 <___pl_fn_0+0x5d4>
    3020: 14000b60     	b	0x5da0 <___pl_fn_0+0x5da0>
    3024: d2800020     	mov	x0, #0x1                ; =1
    3028: 910323e3     	add	x3, sp, #0xc8
    302c: f80c83e0     	stur	x0, [sp, #0xc8]
    3030: 5c016e00     	ldr	d0, 0x5df0 <___pl_fn_0+0x5df0>
    3034: 4e083c00     	mov.d	x0, v0[0]
    3038: f80d03e0     	stur	x0, [sp, #0xd0]
    303c: 528003a1     	mov	w1, #0x1d               ; =29
    3040: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3044: f9400084     	ldr	x4, [x4]
    3048: f9424be0     	ldr	x0, [sp, #0x490]
    304c: aa1503e2     	mov	x2, x21
    3050: d63f0080     	blr	x4
    3054: 34fead60     	cbz	w0, 0x600 <___pl_fn_0+0x600>
    3058: 14000b52     	b	0x5da0 <___pl_fn_0+0x5da0>
    305c: d2800020     	mov	x0, #0x1                ; =1
    3060: 910363e3     	add	x3, sp, #0xd8
    3064: f80d83e0     	stur	x0, [sp, #0xd8]
    3068: 5c016c80     	ldr	d0, 0x5df8 <___pl_fn_0+0x5df8>
    306c: 4e083c00     	mov.d	x0, v0[0]
    3070: f80e03e0     	stur	x0, [sp, #0xe0]
    3074: 528003e1     	mov	w1, #0x1f               ; =31
    3078: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    307c: f9400084     	ldr	x4, [x4]
    3080: f9424be0     	ldr	x0, [sp, #0x490]
    3084: f942ebe2     	ldr	x2, [sp, #0x5d0]
    3088: d63f0080     	blr	x4
    308c: 34feae40     	cbz	w0, 0x654 <___pl_fn_0+0x654>
    3090: 14000b44     	b	0x5da0 <___pl_fn_0+0x5da0>
    3094: d2800028     	mov	x8, #0x1                ; =1
    3098: 9103a3e3     	add	x3, sp, #0xe8
    309c: f80e83e8     	stur	x8, [sp, #0xe8]
    30a0: 5c016b10     	ldr	d16, 0x5e00 <___pl_fn_0+0x5e00>
    30a4: 4e083e09     	mov.d	x9, v16[0]
    30a8: f80f03e9     	stur	x9, [sp, #0xf0]
    30ac: 52800421     	mov	w1, #0x21               ; =33
    30b0: 9000000a     	adrp	x10, 0x3000 <___pl_fn_0+0x3000>
    30b4: f940014a     	ldr	x10, [x10]
    30b8: f9424be0     	ldr	x0, [sp, #0x490]
    30bc: f942e7e2     	ldr	x2, [sp, #0x5c8]
    30c0: d63f0140     	blr	x10
    30c4: 34feaf20     	cbz	w0, 0x6a8 <___pl_fn_0+0x6a8>
    30c8: 14000b36     	b	0x5da0 <___pl_fn_0+0x5da0>
    30cc: d2800020     	mov	x0, #0x1                ; =1
    30d0: 9103e3e3     	add	x3, sp, #0xf8
    30d4: f80f83e0     	stur	x0, [sp, #0xf8]
    30d8: 5c0169d8     	ldr	d24, 0x5e10 <___pl_fn_0+0x5e10>
    30dc: 4e083f00     	mov.d	x0, v24[0]
    30e0: f90083e0     	str	x0, [sp, #0x100]
    30e4: 52800461     	mov	w1, #0x23               ; =35
    30e8: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    30ec: f9400084     	ldr	x4, [x4]
    30f0: f9424be0     	ldr	x0, [sp, #0x490]
    30f4: f942e3e2     	ldr	x2, [sp, #0x5c0]
    30f8: d63f0080     	blr	x4
    30fc: 34feb000     	cbz	w0, 0x6fc <___pl_fn_0+0x6fc>
    3100: 14000b28     	b	0x5da0 <___pl_fn_0+0x5da0>
    3104: d2800020     	mov	x0, #0x1                ; =1
    3108: 910423e3     	add	x3, sp, #0x108
    310c: f90087e0     	str	x0, [sp, #0x108]
    3110: 5c016840     	ldr	d0, 0x5e18 <___pl_fn_0+0x5e18>
    3114: 4e083c00     	mov.d	x0, v0[0]
    3118: f9008be0     	str	x0, [sp, #0x110]
    311c: 528004a1     	mov	w1, #0x25               ; =37
    3120: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3124: f9400084     	ldr	x4, [x4]
    3128: f9424be0     	ldr	x0, [sp, #0x490]
    312c: aa1903e2     	mov	x2, x25
    3130: d63f0080     	blr	x4
    3134: 34feb060     	cbz	w0, 0x740 <___pl_fn_0+0x740>
    3138: 14000b1a     	b	0x5da0 <___pl_fn_0+0x5da0>
    313c: d2800040     	mov	x0, #0x2                ; =2
    3140: 910463e3     	add	x3, sp, #0x118
    3144: f9008fe0     	str	x0, [sp, #0x118]
    3148: 5c0166c0     	ldr	d0, 0x5e20 <___pl_fn_0+0x5e20>
    314c: 4e083c00     	mov.d	x0, v0[0]
    3150: f90093e0     	str	x0, [sp, #0x120]
    3154: 528004c1     	mov	w1, #0x26               ; =38
    3158: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    315c: f9400084     	ldr	x4, [x4]
    3160: f9424be0     	ldr	x0, [sp, #0x490]
    3164: f942efe2     	ldr	x2, [sp, #0x5d8]
    3168: d63f0080     	blr	x4
    316c: 34feb100     	cbz	w0, 0x78c <___pl_fn_0+0x78c>
    3170: 14000b0c     	b	0x5da0 <___pl_fn_0+0x5da0>
    3174: d2800040     	mov	x0, #0x2                ; =2
    3178: 9104a3e3     	add	x3, sp, #0x128
    317c: f90097e0     	str	x0, [sp, #0x128]
    3180: 5c016540     	ldr	d0, 0x5e28 <___pl_fn_0+0x5e28>
    3184: 4e083c00     	mov.d	x0, v0[0]
    3188: f9009be0     	str	x0, [sp, #0x130]
    318c: 528004e1     	mov	w1, #0x27               ; =39
    3190: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3194: f9400084     	ldr	x4, [x4]
    3198: f9424be0     	ldr	x0, [sp, #0x490]
    319c: aa1803e2     	mov	x2, x24
    31a0: d63f0080     	blr	x4
    31a4: 34feb0a0     	cbz	w0, 0x7b8 <___pl_fn_0+0x7b8>
    31a8: 14000afe     	b	0x5da0 <___pl_fn_0+0x5da0>
    31ac: d280004b     	mov	x11, #0x2               ; =2
    31b0: 9104e3e3     	add	x3, sp, #0x138
    31b4: f9009feb     	str	x11, [sp, #0x138]
    31b8: 5c0163d0     	ldr	d16, 0x5e30 <___pl_fn_0+0x5e30>
    31bc: 4e083e0c     	mov.d	x12, v16[0]
    31c0: f900a3ec     	str	x12, [sp, #0x140]
    31c4: 52800501     	mov	w1, #0x28               ; =40
    31c8: 9000000d     	adrp	x13, 0x3000 <___pl_fn_0+0x3000>
    31cc: f94001ad     	ldr	x13, [x13]
    31d0: f9424be0     	ldr	x0, [sp, #0x490]
    31d4: aa1503e2     	mov	x2, x21
    31d8: d63f01a0     	blr	x13
    31dc: 34feb040     	cbz	w0, 0x7e4 <___pl_fn_0+0x7e4>
    31e0: 14000af0     	b	0x5da0 <___pl_fn_0+0x5da0>
    31e4: d2800040     	mov	x0, #0x2                ; =2
    31e8: 910523e3     	add	x3, sp, #0x148
    31ec: f900a7e0     	str	x0, [sp, #0x148]
    31f0: 5c01629b     	ldr	d27, 0x5e40 <___pl_fn_0+0x5e40>
    31f4: 4e083f60     	mov.d	x0, v27[0]
    31f8: f900abe0     	str	x0, [sp, #0x150]
    31fc: 52800541     	mov	w1, #0x2a               ; =42
    3200: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3204: f9400084     	ldr	x4, [x4]
    3208: f9424be0     	ldr	x0, [sp, #0x490]
    320c: f942ebe2     	ldr	x2, [sp, #0x5d0]
    3210: d63f0080     	blr	x4
    3214: 34feb120     	cbz	w0, 0x838 <___pl_fn_0+0x838>
    3218: 14000ae2     	b	0x5da0 <___pl_fn_0+0x5da0>
    321c: d2800040     	mov	x0, #0x2                ; =2
    3220: 910563e3     	add	x3, sp, #0x158
    3224: f900afe0     	str	x0, [sp, #0x158]
    3228: 5c016100     	ldr	d0, 0x5e48 <___pl_fn_0+0x5e48>
    322c: 4e083c00     	mov.d	x0, v0[0]
    3230: f900b3e0     	str	x0, [sp, #0x160]
    3234: 52800581     	mov	w1, #0x2c               ; =44
    3238: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    323c: f9400084     	ldr	x4, [x4]
    3240: f9424be0     	ldr	x0, [sp, #0x490]
    3244: f942e7e2     	ldr	x2, [sp, #0x5c8]
    3248: d63f0080     	blr	x4
    324c: 34feb200     	cbz	w0, 0x88c <___pl_fn_0+0x88c>
    3250: 14000ad4     	b	0x5da0 <___pl_fn_0+0x5da0>
    3254: d2800040     	mov	x0, #0x2                ; =2
    3258: 9105a3e3     	add	x3, sp, #0x168
    325c: f900b7e0     	str	x0, [sp, #0x168]
    3260: 5c015f80     	ldr	d0, 0x5e50 <___pl_fn_0+0x5e50>
    3264: 4e083c00     	mov.d	x0, v0[0]
    3268: f900bbe0     	str	x0, [sp, #0x170]
    326c: 528005c1     	mov	w1, #0x2e               ; =46
    3270: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3274: f9400084     	ldr	x4, [x4]
    3278: f9424be0     	ldr	x0, [sp, #0x490]
    327c: f942e3e2     	ldr	x2, [sp, #0x5c0]
    3280: d63f0080     	blr	x4
    3284: 34feb2e0     	cbz	w0, 0x8e0 <___pl_fn_0+0x8e0>
    3288: 14000ac6     	b	0x5da0 <___pl_fn_0+0x5da0>
    328c: d2800048     	mov	x8, #0x2                ; =2
    3290: 9105e3e3     	add	x3, sp, #0x178
    3294: f900bfe8     	str	x8, [sp, #0x178]
    3298: 5c015e10     	ldr	d16, 0x5e58 <___pl_fn_0+0x5e58>
    329c: 4e083e09     	mov.d	x9, v16[0]
    32a0: f900c3e9     	str	x9, [sp, #0x180]
    32a4: 52800601     	mov	w1, #0x30               ; =48
    32a8: 9000000a     	adrp	x10, 0x3000 <___pl_fn_0+0x3000>
    32ac: f940014a     	ldr	x10, [x10]
    32b0: f9424be0     	ldr	x0, [sp, #0x490]
    32b4: aa1903e2     	mov	x2, x25
    32b8: d63f0140     	blr	x10
    32bc: 34feb340     	cbz	w0, 0x924 <___pl_fn_0+0x924>
    32c0: 14000ab8     	b	0x5da0 <___pl_fn_0+0x5da0>
    32c4: d2800060     	mov	x0, #0x3                ; =3
    32c8: 910623e3     	add	x3, sp, #0x188
    32cc: f900c7e0     	str	x0, [sp, #0x188]
    32d0: 5c015c95     	ldr	d21, 0x5e60 <___pl_fn_0+0x5e60>
    32d4: 4e083ea0     	mov.d	x0, v21[0]
    32d8: f900cbe0     	str	x0, [sp, #0x190]
    32dc: 52800621     	mov	w1, #0x31               ; =49
    32e0: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    32e4: f9400084     	ldr	x4, [x4]
    32e8: f9424be0     	ldr	x0, [sp, #0x490]
    32ec: f942efe2     	ldr	x2, [sp, #0x5d8]
    32f0: d63f0080     	blr	x4
    32f4: 34feb3e0     	cbz	w0, 0x970 <___pl_fn_0+0x970>
    32f8: 14000aaa     	b	0x5da0 <___pl_fn_0+0x5da0>
    32fc: d2800060     	mov	x0, #0x3                ; =3
    3300: 910663e3     	add	x3, sp, #0x198
    3304: f900cfe0     	str	x0, [sp, #0x198]
    3308: 5c015b00     	ldr	d0, 0x5e68 <___pl_fn_0+0x5e68>
    330c: 4e083c00     	mov.d	x0, v0[0]
    3310: f900d3e0     	str	x0, [sp, #0x1a0]
    3314: 52800641     	mov	w1, #0x32               ; =50
    3318: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    331c: f9400084     	ldr	x4, [x4]
    3320: f9424be0     	ldr	x0, [sp, #0x490]
    3324: aa1803e2     	mov	x2, x24
    3328: d63f0080     	blr	x4
    332c: 34feb380     	cbz	w0, 0x99c <___pl_fn_0+0x99c>
    3330: 14000a9c     	b	0x5da0 <___pl_fn_0+0x5da0>
    3334: d2800060     	mov	x0, #0x3                ; =3
    3338: 9106a3e3     	add	x3, sp, #0x1a8
    333c: f900d7e0     	str	x0, [sp, #0x1a8]
    3340: 5c015980     	ldr	d0, 0x5e70 <___pl_fn_0+0x5e70>
    3344: 4e083c00     	mov.d	x0, v0[0]
    3348: f900dbe0     	str	x0, [sp, #0x1b0]
    334c: 52800661     	mov	w1, #0x33               ; =51
    3350: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3354: f9400084     	ldr	x4, [x4]
    3358: f9424be0     	ldr	x0, [sp, #0x490]
    335c: aa1503e2     	mov	x2, x21
    3360: d63f0080     	blr	x4
    3364: 34feb320     	cbz	w0, 0x9c8 <___pl_fn_0+0x9c8>
    3368: 14000a8e     	b	0x5da0 <___pl_fn_0+0x5da0>
    336c: d2800060     	mov	x0, #0x3                ; =3
    3370: 9106e3e3     	add	x3, sp, #0x1b8
    3374: f900dfe0     	str	x0, [sp, #0x1b8]
    3378: 5c015800     	ldr	d0, 0x5e78 <___pl_fn_0+0x5e78>
    337c: 4e083c00     	mov.d	x0, v0[0]
    3380: f900e3e0     	str	x0, [sp, #0x1c0]
    3384: 528006a1     	mov	w1, #0x35               ; =53
    3388: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    338c: f9400084     	ldr	x4, [x4]
    3390: f9424be0     	ldr	x0, [sp, #0x490]
    3394: f942ebe2     	ldr	x2, [sp, #0x5d0]
    3398: d63f0080     	blr	x4
    339c: 34feb400     	cbz	w0, 0xa1c <___pl_fn_0+0xa1c>
    33a0: 14000a80     	b	0x5da0 <___pl_fn_0+0x5da0>
    33a4: d280006b     	mov	x11, #0x3               ; =3
    33a8: 910723e3     	add	x3, sp, #0x1c8
    33ac: f900e7eb     	str	x11, [sp, #0x1c8]
    33b0: 5c015690     	ldr	d16, 0x5e80 <___pl_fn_0+0x5e80>
    33b4: 4e083e0c     	mov.d	x12, v16[0]
    33b8: f900ebec     	str	x12, [sp, #0x1d0]
    33bc: 528006e1     	mov	w1, #0x37               ; =55
    33c0: 9000000d     	adrp	x13, 0x3000 <___pl_fn_0+0x3000>
    33c4: f94001ad     	ldr	x13, [x13]
    33c8: f9424be0     	ldr	x0, [sp, #0x490]
    33cc: f942e7e2     	ldr	x2, [sp, #0x5c8]
    33d0: d63f01a0     	blr	x13
    33d4: 34feb4e0     	cbz	w0, 0xa70 <___pl_fn_0+0xa70>
    33d8: 14000a72     	b	0x5da0 <___pl_fn_0+0x5da0>
    33dc: d2800060     	mov	x0, #0x3                ; =3
    33e0: 910763e3     	add	x3, sp, #0x1d8
    33e4: f900efe0     	str	x0, [sp, #0x1d8]
    33e8: 5c01555b     	ldr	d27, 0x5e90 <___pl_fn_0+0x5e90>
    33ec: 4e083f60     	mov.d	x0, v27[0]
    33f0: f900f3e0     	str	x0, [sp, #0x1e0]
    33f4: 52800721     	mov	w1, #0x39               ; =57
    33f8: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    33fc: f9400084     	ldr	x4, [x4]
    3400: f9424be0     	ldr	x0, [sp, #0x490]
    3404: f942e3e2     	ldr	x2, [sp, #0x5c0]
    3408: d63f0080     	blr	x4
    340c: 34feb5c0     	cbz	w0, 0xac4 <___pl_fn_0+0xac4>
    3410: 14000a64     	b	0x5da0 <___pl_fn_0+0x5da0>
    3414: d2800060     	mov	x0, #0x3                ; =3
    3418: 9107a3e3     	add	x3, sp, #0x1e8
    341c: f900f7e0     	str	x0, [sp, #0x1e8]
    3420: 5c0153c0     	ldr	d0, 0x5e98 <___pl_fn_0+0x5e98>
    3424: 4e083c00     	mov.d	x0, v0[0]
    3428: f900fbe0     	str	x0, [sp, #0x1f0]
    342c: 52800761     	mov	w1, #0x3b               ; =59
    3430: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3434: f9400084     	ldr	x4, [x4]
    3438: f9424be0     	ldr	x0, [sp, #0x490]
    343c: aa1903e2     	mov	x2, x25
    3440: d63f0080     	blr	x4
    3444: 34feb620     	cbz	w0, 0xb08 <___pl_fn_0+0xb08>
    3448: 14000a56     	b	0x5da0 <___pl_fn_0+0x5da0>
    344c: d2800080     	mov	x0, #0x4                ; =4
    3450: 9107e3e3     	add	x3, sp, #0x1f8
    3454: f900ffe0     	str	x0, [sp, #0x1f8]
    3458: 5c015240     	ldr	d0, 0x5ea0 <___pl_fn_0+0x5ea0>
    345c: 4e083c00     	mov.d	x0, v0[0]
    3460: f90103e0     	str	x0, [sp, #0x200]
    3464: 52800781     	mov	w1, #0x3c               ; =60
    3468: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    346c: f9400084     	ldr	x4, [x4]
    3470: f9424be0     	ldr	x0, [sp, #0x490]
    3474: f942efe2     	ldr	x2, [sp, #0x5d8]
    3478: d63f0080     	blr	x4
    347c: 34feb6c0     	cbz	w0, 0xb54 <___pl_fn_0+0xb54>
    3480: 14000a48     	b	0x5da0 <___pl_fn_0+0x5da0>
    3484: d2800082     	mov	x2, #0x4                ; =4
    3488: 910823e3     	add	x3, sp, #0x208
    348c: f90107e2     	str	x2, [sp, #0x208]
    3490: 5c0150c3     	ldr	d3, 0x5ea8 <___pl_fn_0+0x5ea8>
    3494: 4e083c64     	mov.d	x4, v3[0]
    3498: f9010be4     	str	x4, [sp, #0x210]
    349c: 528007a1     	mov	w1, #0x3d               ; =61
    34a0: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    34a4: f9400084     	ldr	x4, [x4]
    34a8: f9424be0     	ldr	x0, [sp, #0x490]
    34ac: aa1803e2     	mov	x2, x24
    34b0: d63f0080     	blr	x4
    34b4: 34feb660     	cbz	w0, 0xb80 <___pl_fn_0+0xb80>
    34b8: 14000a3a     	b	0x5da0 <___pl_fn_0+0x5da0>
    34bc: d280008e     	mov	x14, #0x4               ; =4
    34c0: 910863e3     	add	x3, sp, #0x218
    34c4: f9010fee     	str	x14, [sp, #0x218]
    34c8: 5c014f50     	ldr	d16, 0x5eb0 <___pl_fn_0+0x5eb0>
    34cc: 4e083e0f     	mov.d	x15, v16[0]
    34d0: f90113ef     	str	x15, [sp, #0x220]
    34d4: 528007c1     	mov	w1, #0x3e               ; =62
    34d8: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    34dc: f9400084     	ldr	x4, [x4]
    34e0: f9424be0     	ldr	x0, [sp, #0x490]
    34e4: aa1503e2     	mov	x2, x21
    34e8: d63f0080     	blr	x4
    34ec: 34feb600     	cbz	w0, 0xbac <___pl_fn_0+0xbac>
    34f0: 14000a2c     	b	0x5da0 <___pl_fn_0+0x5da0>
    34f4: d2800080     	mov	x0, #0x4                ; =4
    34f8: 9108a3e3     	add	x3, sp, #0x228
    34fc: f90117e0     	str	x0, [sp, #0x228]
    3500: 5c014dde     	ldr	d30, 0x5eb8 <___pl_fn_0+0x5eb8>
    3504: 4e083fc0     	mov.d	x0, v30[0]
    3508: f9011be0     	str	x0, [sp, #0x230]
    350c: 52800801     	mov	w1, #0x40               ; =64
    3510: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3514: f9400084     	ldr	x4, [x4]
    3518: f9424be0     	ldr	x0, [sp, #0x490]
    351c: f942ebe2     	ldr	x2, [sp, #0x5d0]
    3520: d63f0080     	blr	x4
    3524: 34feb6e0     	cbz	w0, 0xc00 <___pl_fn_0+0xc00>
    3528: 14000a1e     	b	0x5da0 <___pl_fn_0+0x5da0>
    352c: d2800080     	mov	x0, #0x4                ; =4
    3530: 9108e3e3     	add	x3, sp, #0x238
    3534: f9011fe0     	str	x0, [sp, #0x238]
    3538: 5c014c40     	ldr	d0, 0x5ec0 <___pl_fn_0+0x5ec0>
    353c: 4e083c00     	mov.d	x0, v0[0]
    3540: f90123e0     	str	x0, [sp, #0x240]
    3544: 52800841     	mov	w1, #0x42               ; =66
    3548: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    354c: f9400084     	ldr	x4, [x4]
    3550: f9424be0     	ldr	x0, [sp, #0x490]
    3554: f942e7e2     	ldr	x2, [sp, #0x5c8]
    3558: d63f0080     	blr	x4
    355c: 34feb7c0     	cbz	w0, 0xc54 <___pl_fn_0+0xc54>
    3560: 14000a10     	b	0x5da0 <___pl_fn_0+0x5da0>
    3564: d2800080     	mov	x0, #0x4                ; =4
    3568: 910923e3     	add	x3, sp, #0x248
    356c: f90127e0     	str	x0, [sp, #0x248]
    3570: 5c014b00     	ldr	d0, 0x5ed0 <___pl_fn_0+0x5ed0>
    3574: 4e083c00     	mov.d	x0, v0[0]
    3578: f9012be0     	str	x0, [sp, #0x250]
    357c: 52800881     	mov	w1, #0x44               ; =68
    3580: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3584: f9400084     	ldr	x4, [x4]
    3588: f9424be0     	ldr	x0, [sp, #0x490]
    358c: f942e3e2     	ldr	x2, [sp, #0x5c0]
    3590: d63f0080     	blr	x4
    3594: 34feb8a0     	cbz	w0, 0xca8 <___pl_fn_0+0xca8>
    3598: 14000a02     	b	0x5da0 <___pl_fn_0+0x5da0>
    359c: d280008b     	mov	x11, #0x4               ; =4
    35a0: 910963e3     	add	x3, sp, #0x258
    35a4: f9012feb     	str	x11, [sp, #0x258]
    35a8: 5c014990     	ldr	d16, 0x5ed8 <___pl_fn_0+0x5ed8>
    35ac: 4e083e0c     	mov.d	x12, v16[0]
    35b0: f90133ec     	str	x12, [sp, #0x260]
    35b4: 528008c1     	mov	w1, #0x46               ; =70
    35b8: 9000000d     	adrp	x13, 0x3000 <___pl_fn_0+0x3000>
    35bc: f94001ad     	ldr	x13, [x13]
    35c0: f9424be0     	ldr	x0, [sp, #0x490]
    35c4: aa1903e2     	mov	x2, x25
    35c8: d63f01a0     	blr	x13
    35cc: 34feb940     	cbz	w0, 0xcf4 <___pl_fn_0+0xcf4>
    35d0: 140009f4     	b	0x5da0 <___pl_fn_0+0x5da0>
    35d4: 9109a3e3     	add	x3, sp, #0x268
    35d8: f942cff6     	ldr	x22, [sp, #0x598]
    35dc: f90137f6     	str	x22, [sp, #0x268]
    35e0: 4e083c00     	mov.d	x0, v0[0]
    35e4: f9013be0     	str	x0, [sp, #0x270]
    35e8: 52800a01     	mov	w1, #0x50               ; =80
    35ec: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    35f0: f9400084     	ldr	x4, [x4]
    35f4: f9424be0     	ldr	x0, [sp, #0x490]
    35f8: f942ebe2     	ldr	x2, [sp, #0x5d0]
    35fc: d63f0080     	blr	x4
    3600: 34fec100     	cbz	w0, 0xe20 <___pl_fn_0+0xe20>
    3604: 140009e7     	b	0x5da0 <___pl_fn_0+0x5da0>
    3608: 9109e3e3     	add	x3, sp, #0x278
    360c: f942cff6     	ldr	x22, [sp, #0x598]
    3610: f9013ff6     	str	x22, [sp, #0x278]
    3614: 4e083c07     	mov.d	x7, v0[0]
    3618: f90143e7     	str	x7, [sp, #0x280]
    361c: 52800a81     	mov	w1, #0x54               ; =84
    3620: 90000008     	adrp	x8, 0x3000 <___pl_fn_0+0x3000>
    3624: f9400108     	ldr	x8, [x8]
    3628: f9424be0     	ldr	x0, [sp, #0x490]
    362c: f942e7e2     	ldr	x2, [sp, #0x5c8]
    3630: d63f0100     	blr	x8
    3634: 34fec480     	cbz	w0, 0xec4 <___pl_fn_0+0xec4>
    3638: 140009da     	b	0x5da0 <___pl_fn_0+0x5da0>
    363c: 910a23e3     	add	x3, sp, #0x288
    3640: f942cff6     	ldr	x22, [sp, #0x598]
    3644: f90147f6     	str	x22, [sp, #0x288]
    3648: 4e083e40     	mov.d	x0, v18[0]
    364c: f9014be0     	str	x0, [sp, #0x290]
    3650: 52800b01     	mov	w1, #0x58               ; =88
    3654: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3658: f9400084     	ldr	x4, [x4]
    365c: f9424be0     	ldr	x0, [sp, #0x490]
    3660: f942e3e2     	ldr	x2, [sp, #0x5c0]
    3664: d63f0080     	blr	x4
    3668: 34fec800     	cbz	w0, 0xf68 <___pl_fn_0+0xf68>
    366c: 140009cd     	b	0x5da0 <___pl_fn_0+0x5da0>
    3670: 52800c01     	mov	w1, #0x60               ; =96
    3674: 90000008     	adrp	x8, 0x3000 <___pl_fn_0+0x3000>
    3678: f9400108     	ldr	x8, [x8]
    367c: f9424be0     	ldr	x0, [sp, #0x490]
    3680: d63f0100     	blr	x8
    3684: 911783ff     	add	sp, sp, #0x5e0
    3688: a8c153f3     	ldp	x19, x20, [sp], #0x10
    368c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3690: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3694: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3698: a8c173fb     	ldp	x27, x28, [sp], #0x10
    369c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    36a0: d65f03c0     	ret
    36a4: 910a63e3     	add	x3, sp, #0x298
    36a8: f9014ffb     	str	x27, [sp, #0x298]
    36ac: 52800c61     	mov	w1, #0x63               ; =99
    36b0: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    36b4: f9400084     	ldr	x4, [x4]
    36b8: f9424be0     	ldr	x0, [sp, #0x490]
    36bc: aa1903e2     	mov	x2, x25
    36c0: d63f0080     	blr	x4
    36c4: 34fed540     	cbz	w0, 0x116c <___pl_fn_0+0x116c>
    36c8: 140009b6     	b	0x5da0 <___pl_fn_0+0x5da0>
    36cc: 910a83e3     	add	x3, sp, #0x2a0
    36d0: f90153fb     	str	x27, [sp, #0x2a0]
    36d4: 52800ca1     	mov	w1, #0x65               ; =101
    36d8: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    36dc: f9400084     	ldr	x4, [x4]
    36e0: f9424be0     	ldr	x0, [sp, #0x490]
    36e4: f942ebe2     	ldr	x2, [sp, #0x5d0]
    36e8: d63f0080     	blr	x4
    36ec: 34fed7a0     	cbz	w0, 0x11e0 <___pl_fn_0+0x11e0>
    36f0: 140009ac     	b	0x5da0 <___pl_fn_0+0x5da0>
    36f4: 910aa3e3     	add	x3, sp, #0x2a8
    36f8: f90157fb     	str	x27, [sp, #0x2a8]
    36fc: 52800cc1     	mov	w1, #0x66               ; =102
    3700: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3704: f9400084     	ldr	x4, [x4]
    3708: f9424be0     	ldr	x0, [sp, #0x490]
    370c: f942ebe2     	ldr	x2, [sp, #0x5d0]
    3710: d63f0080     	blr	x4
    3714: 34fed940     	cbz	w0, 0x123c <___pl_fn_0+0x123c>
    3718: 140009a2     	b	0x5da0 <___pl_fn_0+0x5da0>
    371c: 910ac3e3     	add	x3, sp, #0x2b0
    3720: f9015bfb     	str	x27, [sp, #0x2b0]
    3724: 52800d01     	mov	w1, #0x68               ; =104
    3728: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    372c: f9400084     	ldr	x4, [x4]
    3730: f9424be0     	ldr	x0, [sp, #0x490]
    3734: f942e7e2     	ldr	x2, [sp, #0x5c8]
    3738: d63f0080     	blr	x4
    373c: 34fedbe0     	cbz	w0, 0x12b8 <___pl_fn_0+0x12b8>
    3740: 14000998     	b	0x5da0 <___pl_fn_0+0x5da0>
    3744: 910ae3e3     	add	x3, sp, #0x2b8
    3748: f9015ffb     	str	x27, [sp, #0x2b8]
    374c: 52800d21     	mov	w1, #0x69               ; =105
    3750: 9000000d     	adrp	x13, 0x3000 <___pl_fn_0+0x3000>
    3754: f94001ad     	ldr	x13, [x13]
    3758: f9424be0     	ldr	x0, [sp, #0x490]
    375c: f942e7e2     	ldr	x2, [sp, #0x5c8]
    3760: d63f01a0     	blr	x13
    3764: 34fedd80     	cbz	w0, 0x1314 <___pl_fn_0+0x1314>
    3768: 1400098e     	b	0x5da0 <___pl_fn_0+0x5da0>
    376c: 910b03e3     	add	x3, sp, #0x2c0
    3770: f90163fb     	str	x27, [sp, #0x2c0]
    3774: 52800d81     	mov	w1, #0x6c               ; =108
    3778: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    377c: f9400084     	ldr	x4, [x4]
    3780: f9424be0     	ldr	x0, [sp, #0x490]
    3784: f942e3e2     	ldr	x2, [sp, #0x5c0]
    3788: d63f0080     	blr	x4
    378c: 34fee160     	cbz	w0, 0x13b8 <___pl_fn_0+0x13b8>
    3790: 14000984     	b	0x5da0 <___pl_fn_0+0x5da0>
    3794: 910b23e3     	add	x3, sp, #0x2c8
    3798: f90167fb     	str	x27, [sp, #0x2c8]
    379c: 52800da1     	mov	w1, #0x6d               ; =109
    37a0: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    37a4: f9400084     	ldr	x4, [x4]
    37a8: f9424be0     	ldr	x0, [sp, #0x490]
    37ac: f942e3e2     	ldr	x2, [sp, #0x5c0]
    37b0: d63f0080     	blr	x4
    37b4: 34fee300     	cbz	w0, 0x1414 <___pl_fn_0+0x1414>
    37b8: 1400097a     	b	0x5da0 <___pl_fn_0+0x5da0>
    37bc: 52800ee1     	mov	w1, #0x77               ; =119
    37c0: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    37c4: f9400042     	ldr	x2, [x2]
    37c8: f9424be0     	ldr	x0, [sp, #0x490]
    37cc: d63f0040     	blr	x2
    37d0: 911783ff     	add	sp, sp, #0x5e0
    37d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    37d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    37dc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    37e0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    37e4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    37e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    37ec: d65f03c0     	ret
    37f0: 910b43e3     	add	x3, sp, #0x2d0
    37f4: f9016bfb     	str	x27, [sp, #0x2d0]
    37f8: 52800f01     	mov	w1, #0x78               ; =120
    37fc: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3800: f9400084     	ldr	x4, [x4]
    3804: f9424be0     	ldr	x0, [sp, #0x490]
    3808: f942efe2     	ldr	x2, [sp, #0x5d8]
    380c: d63f0080     	blr	x4
    3810: 34feec60     	cbz	w0, 0x159c <___pl_fn_0+0x159c>
    3814: 14000963     	b	0x5da0 <___pl_fn_0+0x5da0>
    3818: 910b63e3     	add	x3, sp, #0x2d8
    381c: f9016ffa     	str	x26, [sp, #0x2d8]
    3820: 52800f21     	mov	w1, #0x79               ; =121
    3824: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3828: f9400084     	ldr	x4, [x4]
    382c: f9424be0     	ldr	x0, [sp, #0x490]
    3830: f942efe2     	ldr	x2, [sp, #0x5d8]
    3834: d63f0080     	blr	x4
    3838: 34feee00     	cbz	w0, 0x15f8 <___pl_fn_0+0x15f8>
    383c: 14000959     	b	0x5da0 <___pl_fn_0+0x5da0>
    3840: 910b83e3     	add	x3, sp, #0x2e0
    3844: f90173fb     	str	x27, [sp, #0x2e0]
    3848: 52800f81     	mov	w1, #0x7c               ; =124
    384c: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3850: f9400084     	ldr	x4, [x4]
    3854: f9424be0     	ldr	x0, [sp, #0x490]
    3858: aa1803e2     	mov	x2, x24
    385c: d63f0080     	blr	x4
    3860: 34fef0a0     	cbz	w0, 0x1674 <___pl_fn_0+0x1674>
    3864: 1400094f     	b	0x5da0 <___pl_fn_0+0x5da0>
    3868: 910ba3e3     	add	x3, sp, #0x2e8
    386c: f90177fa     	str	x26, [sp, #0x2e8]
    3870: 52800fa1     	mov	w1, #0x7d               ; =125
    3874: 9000000a     	adrp	x10, 0x3000 <___pl_fn_0+0x3000>
    3878: f940014a     	ldr	x10, [x10]
    387c: f9424be0     	ldr	x0, [sp, #0x490]
    3880: aa1803e2     	mov	x2, x24
    3884: d63f0140     	blr	x10
    3888: 34fef1c0     	cbz	w0, 0x16c0 <___pl_fn_0+0x16c0>
    388c: 14000945     	b	0x5da0 <___pl_fn_0+0x5da0>
    3890: 910bc3e3     	add	x3, sp, #0x2f0
    3894: f9017bfb     	str	x27, [sp, #0x2f0]
    3898: 52801001     	mov	w1, #0x80               ; =128
    389c: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    38a0: f9400084     	ldr	x4, [x4]
    38a4: f9424be0     	ldr	x0, [sp, #0x490]
    38a8: aa1503e2     	mov	x2, x21
    38ac: d63f0080     	blr	x4
    38b0: 34fef460     	cbz	w0, 0x173c <___pl_fn_0+0x173c>
    38b4: 1400093b     	b	0x5da0 <___pl_fn_0+0x5da0>
    38b8: 910be3e3     	add	x3, sp, #0x2f8
    38bc: f9017ffa     	str	x26, [sp, #0x2f8]
    38c0: 52801021     	mov	w1, #0x81               ; =129
    38c4: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    38c8: f9400084     	ldr	x4, [x4]
    38cc: f9424be0     	ldr	x0, [sp, #0x490]
    38d0: aa1503e2     	mov	x2, x21
    38d4: d63f0080     	blr	x4
    38d8: 34fef580     	cbz	w0, 0x1788 <___pl_fn_0+0x1788>
    38dc: 14000931     	b	0x5da0 <___pl_fn_0+0x5da0>
    38e0: 910c03e3     	add	x3, sp, #0x300
    38e4: f90183fb     	str	x27, [sp, #0x300]
    38e8: 52801161     	mov	w1, #0x8b               ; =139
    38ec: 9000000f     	adrp	x15, 0x3000 <___pl_fn_0+0x3000>
    38f0: f94001ef     	ldr	x15, [x15]
    38f4: f9424be0     	ldr	x0, [sp, #0x490]
    38f8: aa1903e2     	mov	x2, x25
    38fc: d63f01e0     	blr	x15
    3900: 34feff20     	cbz	w0, 0x18e4 <___pl_fn_0+0x18e4>
    3904: 14000927     	b	0x5da0 <___pl_fn_0+0x5da0>
    3908: 910c23e3     	add	x3, sp, #0x308
    390c: f90187fa     	str	x26, [sp, #0x308]
    3910: 52801181     	mov	w1, #0x8c               ; =140
    3914: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3918: f9400084     	ldr	x4, [x4]
    391c: f9424be0     	ldr	x0, [sp, #0x490]
    3920: aa1903e2     	mov	x2, x25
    3924: d63f0080     	blr	x4
    3928: 34ff0040     	cbz	w0, 0x1930 <___pl_fn_0+0x1930>
    392c: 1400091d     	b	0x5da0 <___pl_fn_0+0x5da0>
    3930: 52801241     	mov	w1, #0x92               ; =146
    3934: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3938: f9400042     	ldr	x2, [x2]
    393c: f9424be0     	ldr	x0, [sp, #0x490]
    3940: d63f0040     	blr	x2
    3944: 911783ff     	add	sp, sp, #0x5e0
    3948: a8c153f3     	ldp	x19, x20, [sp], #0x10
    394c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3950: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3954: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3958: a8c173fb     	ldp	x27, x28, [sp], #0x10
    395c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3960: d65f03c0     	ret
    3964: 52801221     	mov	w1, #0x91               ; =145
    3968: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    396c: f9400042     	ldr	x2, [x2]
    3970: f9424be0     	ldr	x0, [sp, #0x490]
    3974: d63f0040     	blr	x2
    3978: 911783ff     	add	sp, sp, #0x5e0
    397c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3980: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3984: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3988: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    398c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3990: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3994: d65f03c0     	ret
    3998: 52801201     	mov	w1, #0x90               ; =144
    399c: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    39a0: f9400042     	ldr	x2, [x2]
    39a4: f9424be0     	ldr	x0, [sp, #0x490]
    39a8: d63f0040     	blr	x2
    39ac: 911783ff     	add	sp, sp, #0x5e0
    39b0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    39b4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    39b8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    39bc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    39c0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    39c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    39c8: d65f03c0     	ret
    39cc: 528011e1     	mov	w1, #0x8f               ; =143
    39d0: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    39d4: f9400042     	ldr	x2, [x2]
    39d8: f9424be0     	ldr	x0, [sp, #0x490]
    39dc: d63f0040     	blr	x2
    39e0: 911783ff     	add	sp, sp, #0x5e0
    39e4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    39e8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    39ec: a8c163f7     	ldp	x23, x24, [sp], #0x10
    39f0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    39f4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    39f8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    39fc: d65f03c0     	ret
    3a00: 528011c1     	mov	w1, #0x8e               ; =142
    3a04: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3a08: f9400042     	ldr	x2, [x2]
    3a0c: f9424be0     	ldr	x0, [sp, #0x490]
    3a10: d63f0040     	blr	x2
    3a14: 911783ff     	add	sp, sp, #0x5e0
    3a18: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3a1c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3a20: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3a24: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3a28: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3a2c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3a30: d65f03c0     	ret
    3a34: 528011a1     	mov	w1, #0x8d               ; =141
    3a38: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3a3c: f9400042     	ldr	x2, [x2]
    3a40: f9424be0     	ldr	x0, [sp, #0x490]
    3a44: d63f0040     	blr	x2
    3a48: 911783ff     	add	sp, sp, #0x5e0
    3a4c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3a50: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3a54: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3a58: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3a5c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3a60: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3a64: d65f03c0     	ret
    3a68: 52801141     	mov	w1, #0x8a               ; =138
    3a6c: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3a70: f9400042     	ldr	x2, [x2]
    3a74: f9424be0     	ldr	x0, [sp, #0x490]
    3a78: d63f0040     	blr	x2
    3a7c: 911783ff     	add	sp, sp, #0x5e0
    3a80: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3a84: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3a88: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3a8c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3a90: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3a94: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3a98: d65f03c0     	ret
    3a9c: 52801121     	mov	w1, #0x89               ; =137
    3aa0: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3aa4: f9400042     	ldr	x2, [x2]
    3aa8: f9424be0     	ldr	x0, [sp, #0x490]
    3aac: d63f0040     	blr	x2
    3ab0: 911783ff     	add	sp, sp, #0x5e0
    3ab4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3ab8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3abc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3ac0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3ac4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3ac8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3acc: d65f03c0     	ret
    3ad0: 52801101     	mov	w1, #0x88               ; =136
    3ad4: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3ad8: f9400042     	ldr	x2, [x2]
    3adc: f9424be0     	ldr	x0, [sp, #0x490]
    3ae0: d63f0040     	blr	x2
    3ae4: 911783ff     	add	sp, sp, #0x5e0
    3ae8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3aec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3af0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3af4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3af8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3afc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3b00: d65f03c0     	ret
    3b04: 528010e1     	mov	w1, #0x87               ; =135
    3b08: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3b0c: f9400042     	ldr	x2, [x2]
    3b10: f9424be0     	ldr	x0, [sp, #0x490]
    3b14: d63f0040     	blr	x2
    3b18: 911783ff     	add	sp, sp, #0x5e0
    3b1c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3b20: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3b24: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3b28: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3b2c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3b30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3b34: d65f03c0     	ret
    3b38: 528010c1     	mov	w1, #0x86               ; =134
    3b3c: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3b40: f9400042     	ldr	x2, [x2]
    3b44: f9424be0     	ldr	x0, [sp, #0x490]
    3b48: d63f0040     	blr	x2
    3b4c: 911783ff     	add	sp, sp, #0x5e0
    3b50: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3b54: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3b58: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3b5c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3b60: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3b64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3b68: d65f03c0     	ret
    3b6c: 528010a1     	mov	w1, #0x85               ; =133
    3b70: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3b74: f9400042     	ldr	x2, [x2]
    3b78: f9424be0     	ldr	x0, [sp, #0x490]
    3b7c: d63f0040     	blr	x2
    3b80: 911783ff     	add	sp, sp, #0x5e0
    3b84: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3b88: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3b8c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3b90: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3b94: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3b98: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3b9c: d65f03c0     	ret
    3ba0: 52801081     	mov	w1, #0x84               ; =132
    3ba4: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3ba8: f9400042     	ldr	x2, [x2]
    3bac: f9424be0     	ldr	x0, [sp, #0x490]
    3bb0: d63f0040     	blr	x2
    3bb4: 911783ff     	add	sp, sp, #0x5e0
    3bb8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3bbc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3bc0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3bc4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3bc8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3bcc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3bd0: d65f03c0     	ret
    3bd4: 52801061     	mov	w1, #0x83               ; =131
    3bd8: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3bdc: f9400042     	ldr	x2, [x2]
    3be0: f9424be0     	ldr	x0, [sp, #0x490]
    3be4: d63f0040     	blr	x2
    3be8: 911783ff     	add	sp, sp, #0x5e0
    3bec: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3bf0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3bf4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3bf8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3bfc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3c00: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3c04: d65f03c0     	ret
    3c08: 52801041     	mov	w1, #0x82               ; =130
    3c0c: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3c10: f9400042     	ldr	x2, [x2]
    3c14: f9424be0     	ldr	x0, [sp, #0x490]
    3c18: d63f0040     	blr	x2
    3c1c: 911783ff     	add	sp, sp, #0x5e0
    3c20: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3c24: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3c28: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3c2c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3c30: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3c34: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3c38: d65f03c0     	ret
    3c3c: 52800fe1     	mov	w1, #0x7f               ; =127
    3c40: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3c44: f9400042     	ldr	x2, [x2]
    3c48: f9424be0     	ldr	x0, [sp, #0x490]
    3c4c: d63f0040     	blr	x2
    3c50: 911783ff     	add	sp, sp, #0x5e0
    3c54: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3c58: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3c5c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3c60: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3c64: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3c68: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3c6c: d65f03c0     	ret
    3c70: 52800fc1     	mov	w1, #0x7e               ; =126
    3c74: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3c78: f9400042     	ldr	x2, [x2]
    3c7c: f9424be0     	ldr	x0, [sp, #0x490]
    3c80: d63f0040     	blr	x2
    3c84: 911783ff     	add	sp, sp, #0x5e0
    3c88: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3c8c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3c90: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3c94: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3c98: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3c9c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3ca0: d65f03c0     	ret
    3ca4: 52800f61     	mov	w1, #0x7b               ; =123
    3ca8: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3cac: f9400042     	ldr	x2, [x2]
    3cb0: f9424be0     	ldr	x0, [sp, #0x490]
    3cb4: d63f0040     	blr	x2
    3cb8: 911783ff     	add	sp, sp, #0x5e0
    3cbc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3cc0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3cc4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3cc8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3ccc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3cd0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3cd4: d65f03c0     	ret
    3cd8: 52800f41     	mov	w1, #0x7a               ; =122
    3cdc: 90000003     	adrp	x3, 0x3000 <___pl_fn_0+0x3000>
    3ce0: f9400063     	ldr	x3, [x3]
    3ce4: f9424be0     	ldr	x0, [sp, #0x490]
    3ce8: d63f0060     	blr	x3
    3cec: 911783ff     	add	sp, sp, #0x5e0
    3cf0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3cf4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3cf8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3cfc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3d00: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3d04: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3d08: d65f03c0     	ret
    3d0c: 52800ec1     	mov	w1, #0x76               ; =118
    3d10: 90000004     	adrp	x4, 0x3000 <___pl_fn_0+0x3000>
    3d14: f9400084     	ldr	x4, [x4]
    3d18: f9424be0     	ldr	x0, [sp, #0x490]
    3d1c: d63f0080     	blr	x4
    3d20: 911783ff     	add	sp, sp, #0x5e0
    3d24: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3d28: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3d2c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3d30: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3d34: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3d38: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3d3c: d65f03c0     	ret
    3d40: 52800ea1     	mov	w1, #0x75               ; =117
    3d44: 90000005     	adrp	x5, 0x3000 <___pl_fn_0+0x3000>
    3d48: f94000a5     	ldr	x5, [x5]
    3d4c: f9424be0     	ldr	x0, [sp, #0x490]
    3d50: d63f00a0     	blr	x5
    3d54: 911783ff     	add	sp, sp, #0x5e0
    3d58: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3d5c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3d60: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3d64: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3d68: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3d6c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3d70: d65f03c0     	ret
    3d74: 52800e81     	mov	w1, #0x74               ; =116
    3d78: 90000006     	adrp	x6, 0x3000 <___pl_fn_0+0x3000>
    3d7c: f94000c6     	ldr	x6, [x6]
    3d80: f9424be0     	ldr	x0, [sp, #0x490]
    3d84: d63f00c0     	blr	x6
    3d88: 911783ff     	add	sp, sp, #0x5e0
    3d8c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3d90: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3d94: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3d98: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3d9c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3da0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3da4: d65f03c0     	ret
    3da8: 52800e61     	mov	w1, #0x73               ; =115
    3dac: 90000007     	adrp	x7, 0x3000 <___pl_fn_0+0x3000>
    3db0: f94000e7     	ldr	x7, [x7]
    3db4: f9424be0     	ldr	x0, [sp, #0x490]
    3db8: d63f00e0     	blr	x7
    3dbc: 911783ff     	add	sp, sp, #0x5e0
    3dc0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3dc4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3dc8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3dcc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3dd0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3dd4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3dd8: d65f03c0     	ret
    3ddc: 52800e41     	mov	w1, #0x72               ; =114
    3de0: 90000008     	adrp	x8, 0x3000 <___pl_fn_0+0x3000>
    3de4: f9400108     	ldr	x8, [x8]
    3de8: f9424be0     	ldr	x0, [sp, #0x490]
    3dec: d63f0100     	blr	x8
    3df0: 911783ff     	add	sp, sp, #0x5e0
    3df4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3df8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3dfc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3e00: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3e04: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3e08: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3e0c: d65f03c0     	ret
    3e10: 52800e21     	mov	w1, #0x71               ; =113
    3e14: 90000009     	adrp	x9, 0x3000 <___pl_fn_0+0x3000>
    3e18: f9400129     	ldr	x9, [x9]
    3e1c: f9424be0     	ldr	x0, [sp, #0x490]
    3e20: d63f0120     	blr	x9
    3e24: 911783ff     	add	sp, sp, #0x5e0
    3e28: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3e2c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3e30: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3e34: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3e38: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3e3c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3e40: d65f03c0     	ret
    3e44: 52800e01     	mov	w1, #0x70               ; =112
    3e48: 9000000a     	adrp	x10, 0x3000 <___pl_fn_0+0x3000>
    3e4c: f940014a     	ldr	x10, [x10]
    3e50: f9424be0     	ldr	x0, [sp, #0x490]
    3e54: d63f0140     	blr	x10
    3e58: 911783ff     	add	sp, sp, #0x5e0
    3e5c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3e60: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3e64: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3e68: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3e6c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3e70: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3e74: d65f03c0     	ret
    3e78: 52800de1     	mov	w1, #0x6f               ; =111
    3e7c: 9000000b     	adrp	x11, 0x3000 <___pl_fn_0+0x3000>
    3e80: f940016b     	ldr	x11, [x11]
    3e84: f9424be0     	ldr	x0, [sp, #0x490]
    3e88: d63f0160     	blr	x11
    3e8c: 911783ff     	add	sp, sp, #0x5e0
    3e90: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3e94: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3e98: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3e9c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3ea0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3ea4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3ea8: d65f03c0     	ret
    3eac: 52800dc1     	mov	w1, #0x6e               ; =110
    3eb0: 9000000c     	adrp	x12, 0x3000 <___pl_fn_0+0x3000>
    3eb4: f940018c     	ldr	x12, [x12]
    3eb8: f9424be0     	ldr	x0, [sp, #0x490]
    3ebc: d63f0180     	blr	x12
    3ec0: 911783ff     	add	sp, sp, #0x5e0
    3ec4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3ec8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3ecc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3ed0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3ed4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3ed8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3edc: d65f03c0     	ret
    3ee0: 52800d61     	mov	w1, #0x6b               ; =107
    3ee4: 9000000d     	adrp	x13, 0x3000 <___pl_fn_0+0x3000>
    3ee8: f94001ad     	ldr	x13, [x13]
    3eec: f9424be0     	ldr	x0, [sp, #0x490]
    3ef0: d63f01a0     	blr	x13
    3ef4: 911783ff     	add	sp, sp, #0x5e0
    3ef8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3efc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3f00: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3f04: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3f08: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3f0c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3f10: d65f03c0     	ret
    3f14: 52800d41     	mov	w1, #0x6a               ; =106
    3f18: 9000000e     	adrp	x14, 0x3000 <___pl_fn_0+0x3000>
    3f1c: f94001ce     	ldr	x14, [x14]
    3f20: f9424be0     	ldr	x0, [sp, #0x490]
    3f24: d63f01c0     	blr	x14
    3f28: 911783ff     	add	sp, sp, #0x5e0
    3f2c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3f30: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3f34: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3f38: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3f3c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3f40: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3f44: d65f03c0     	ret
    3f48: 52800ce1     	mov	w1, #0x67               ; =103
    3f4c: 9000000f     	adrp	x15, 0x3000 <___pl_fn_0+0x3000>
    3f50: f94001ef     	ldr	x15, [x15]
    3f54: f9424be0     	ldr	x0, [sp, #0x490]
    3f58: d63f01e0     	blr	x15
    3f5c: 911783ff     	add	sp, sp, #0x5e0
    3f60: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3f64: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3f68: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3f6c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3f70: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3f74: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3f78: d65f03c0     	ret
    3f7c: 52800c81     	mov	w1, #0x64               ; =100
    3f80: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3f84: f9400042     	ldr	x2, [x2]
    3f88: f9424be0     	ldr	x0, [sp, #0x490]
    3f8c: d63f0040     	blr	x2
    3f90: 911783ff     	add	sp, sp, #0x5e0
    3f94: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3f98: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3f9c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3fa0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3fa4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3fa8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3fac: d65f03c0     	ret
    3fb0: 52800be1     	mov	w1, #0x5f               ; =95
    3fb4: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3fb8: f9400042     	ldr	x2, [x2]
    3fbc: f9424be0     	ldr	x0, [sp, #0x490]
    3fc0: d63f0040     	blr	x2
    3fc4: 911783ff     	add	sp, sp, #0x5e0
    3fc8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    3fcc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    3fd0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    3fd4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    3fd8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    3fdc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    3fe0: d65f03c0     	ret
    3fe4: 52800bc1     	mov	w1, #0x5e               ; =94
    3fe8: 90000002     	adrp	x2, 0x3000 <___pl_fn_0+0x3000>
    3fec: f9400042     	ldr	x2, [x2]
    3ff0: f9424be0     	ldr	x0, [sp, #0x490]
    3ff4: d63f0040     	blr	x2
    3ff8: 911783ff     	add	sp, sp, #0x5e0
    3ffc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4000: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4004: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4008: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    400c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4010: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4014: d65f03c0     	ret
    4018: 52800ba1     	mov	w1, #0x5d               ; =93
    401c: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4020: f9400042     	ldr	x2, [x2]
    4024: f9424be0     	ldr	x0, [sp, #0x490]
    4028: d63f0040     	blr	x2
    402c: 911783ff     	add	sp, sp, #0x5e0
    4030: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4034: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4038: a8c163f7     	ldp	x23, x24, [sp], #0x10
    403c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4040: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4044: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4048: d65f03c0     	ret
    404c: 52800b81     	mov	w1, #0x5c               ; =92
    4050: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4054: f9400042     	ldr	x2, [x2]
    4058: f9424be0     	ldr	x0, [sp, #0x490]
    405c: d63f0040     	blr	x2
    4060: 911783ff     	add	sp, sp, #0x5e0
    4064: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4068: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    406c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4070: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4074: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4078: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    407c: d65f03c0     	ret
    4080: 52801321     	mov	w1, #0x99               ; =153
    4084: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4088: f9400042     	ldr	x2, [x2]
    408c: f9424be0     	ldr	x0, [sp, #0x490]
    4090: d63f0040     	blr	x2
    4094: 911783ff     	add	sp, sp, #0x5e0
    4098: a8c153f3     	ldp	x19, x20, [sp], #0x10
    409c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    40a0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    40a4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    40a8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    40ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    40b0: d65f03c0     	ret
    40b4: 910c43e3     	add	x3, sp, #0x310
    40b8: f9018bfc     	str	x28, [sp, #0x310]
    40bc: 52801341     	mov	w1, #0x9a               ; =154
    40c0: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    40c4: f9400084     	ldr	x4, [x4]
    40c8: f9424be0     	ldr	x0, [sp, #0x490]
    40cc: f942efe2     	ldr	x2, [sp, #0x5d8]
    40d0: d63f0080     	blr	x4
    40d4: 34fed200     	cbz	w0, 0x1b14 <___pl_fn_0+0x1b14>
    40d8: 14000732     	b	0x5da0 <___pl_fn_0+0x5da0>
    40dc: 910c63e3     	add	x3, sp, #0x318
    40e0: f9018ffc     	str	x28, [sp, #0x318]
    40e4: 52801361     	mov	w1, #0x9b               ; =155
    40e8: 9000000c     	adrp	x12, 0x4000 <___pl_fn_0+0x4000>
    40ec: f940018c     	ldr	x12, [x12]
    40f0: f9424be0     	ldr	x0, [sp, #0x490]
    40f4: f942ebe2     	ldr	x2, [sp, #0x5d0]
    40f8: d63f0180     	blr	x12
    40fc: 34fed3a0     	cbz	w0, 0x1b70 <___pl_fn_0+0x1b70>
    4100: 14000728     	b	0x5da0 <___pl_fn_0+0x5da0>
    4104: 910c83e3     	add	x3, sp, #0x320
    4108: f90193fc     	str	x28, [sp, #0x320]
    410c: 4e083e60     	mov.d	x0, v19[0]
    4110: f90197e0     	str	x0, [sp, #0x328]
    4114: 528013c1     	mov	w1, #0x9e               ; =158
    4118: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    411c: f9400084     	ldr	x4, [x4]
    4120: f9424be0     	ldr	x0, [sp, #0x490]
    4124: f942efe2     	ldr	x2, [sp, #0x5d8]
    4128: d63f0080     	blr	x4
    412c: 34fed6a0     	cbz	w0, 0x1c00 <___pl_fn_0+0x1c00>
    4130: 1400071c     	b	0x5da0 <___pl_fn_0+0x5da0>
    4134: 910cc3e3     	add	x3, sp, #0x330
    4138: f9019bfc     	str	x28, [sp, #0x330]
    413c: 528013e1     	mov	w1, #0x9f               ; =159
    4140: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4144: f9400084     	ldr	x4, [x4]
    4148: f9424be0     	ldr	x0, [sp, #0x490]
    414c: aa1803e2     	mov	x2, x24
    4150: d63f0080     	blr	x4
    4154: 34fed700     	cbz	w0, 0x1c34 <___pl_fn_0+0x1c34>
    4158: 14000712     	b	0x5da0 <___pl_fn_0+0x5da0>
    415c: 910ce3e3     	add	x3, sp, #0x338
    4160: f9019ffc     	str	x28, [sp, #0x338]
    4164: 52801401     	mov	w1, #0xa0               ; =160
    4168: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    416c: f9400084     	ldr	x4, [x4]
    4170: f9424be0     	ldr	x0, [sp, #0x490]
    4174: f942e7e2     	ldr	x2, [sp, #0x5c8]
    4178: d63f0080     	blr	x4
    417c: 34fed8a0     	cbz	w0, 0x1c90 <___pl_fn_0+0x1c90>
    4180: 14000708     	b	0x5da0 <___pl_fn_0+0x5da0>
    4184: 910d03e3     	add	x3, sp, #0x340
    4188: f901a3fc     	str	x28, [sp, #0x340]
    418c: 4e083c09     	mov.d	x9, v0[0]
    4190: f901a7e9     	str	x9, [sp, #0x348]
    4194: 52801461     	mov	w1, #0xa3               ; =163
    4198: 9000000a     	adrp	x10, 0x4000 <___pl_fn_0+0x4000>
    419c: f940014a     	ldr	x10, [x10]
    41a0: f9424be0     	ldr	x0, [sp, #0x490]
    41a4: aa1803e2     	mov	x2, x24
    41a8: d63f0140     	blr	x10
    41ac: 34fedb60     	cbz	w0, 0x1d18 <___pl_fn_0+0x1d18>
    41b0: 140006fc     	b	0x5da0 <___pl_fn_0+0x5da0>
    41b4: 910d43e3     	add	x3, sp, #0x350
    41b8: f901abfc     	str	x28, [sp, #0x350]
    41bc: 52801481     	mov	w1, #0xa4               ; =164
    41c0: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    41c4: f9400084     	ldr	x4, [x4]
    41c8: f9424be0     	ldr	x0, [sp, #0x490]
    41cc: aa1503e2     	mov	x2, x21
    41d0: d63f0080     	blr	x4
    41d4: 34fedbc0     	cbz	w0, 0x1d4c <___pl_fn_0+0x1d4c>
    41d8: 140006f2     	b	0x5da0 <___pl_fn_0+0x5da0>
    41dc: 910d63e3     	add	x3, sp, #0x358
    41e0: f901affc     	str	x28, [sp, #0x358]
    41e4: 528014a1     	mov	w1, #0xa5               ; =165
    41e8: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    41ec: f9400084     	ldr	x4, [x4]
    41f0: f9424be0     	ldr	x0, [sp, #0x490]
    41f4: f942e3e2     	ldr	x2, [sp, #0x5c0]
    41f8: d63f0080     	blr	x4
    41fc: 34fedd60     	cbz	w0, 0x1da8 <___pl_fn_0+0x1da8>
    4200: 140006e8     	b	0x5da0 <___pl_fn_0+0x5da0>
    4204: 910d83e3     	add	x3, sp, #0x360
    4208: f901b3fc     	str	x28, [sp, #0x360]
    420c: 4e083c00     	mov.d	x0, v0[0]
    4210: f901b7e0     	str	x0, [sp, #0x368]
    4214: 52801501     	mov	w1, #0xa8               ; =168
    4218: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    421c: f9400084     	ldr	x4, [x4]
    4220: f9424be0     	ldr	x0, [sp, #0x490]
    4224: aa1503e2     	mov	x2, x21
    4228: d63f0080     	blr	x4
    422c: 34fee020     	cbz	w0, 0x1e30 <___pl_fn_0+0x1e30>
    4230: 140006dc     	b	0x5da0 <___pl_fn_0+0x5da0>
    4234: 52801521     	mov	w1, #0xa9               ; =169
    4238: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    423c: f9400042     	ldr	x2, [x2]
    4240: f9424be0     	ldr	x0, [sp, #0x490]
    4244: d63f0040     	blr	x2
    4248: 911783ff     	add	sp, sp, #0x5e0
    424c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4250: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4254: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4258: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    425c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4260: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4264: d65f03c0     	ret
    4268: 528014e1     	mov	w1, #0xa7               ; =167
    426c: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4270: f9400042     	ldr	x2, [x2]
    4274: f9424be0     	ldr	x0, [sp, #0x490]
    4278: d63f0040     	blr	x2
    427c: 911783ff     	add	sp, sp, #0x5e0
    4280: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4284: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4288: a8c163f7     	ldp	x23, x24, [sp], #0x10
    428c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4290: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4294: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4298: d65f03c0     	ret
    429c: 528014c1     	mov	w1, #0xa6               ; =166
    42a0: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    42a4: f9400042     	ldr	x2, [x2]
    42a8: f9424be0     	ldr	x0, [sp, #0x490]
    42ac: d63f0040     	blr	x2
    42b0: 911783ff     	add	sp, sp, #0x5e0
    42b4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    42b8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    42bc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    42c0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    42c4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    42c8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    42cc: d65f03c0     	ret
    42d0: 52801441     	mov	w1, #0xa2               ; =162
    42d4: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    42d8: f9400042     	ldr	x2, [x2]
    42dc: f9424be0     	ldr	x0, [sp, #0x490]
    42e0: d63f0040     	blr	x2
    42e4: 911783ff     	add	sp, sp, #0x5e0
    42e8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    42ec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    42f0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    42f4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    42f8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    42fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4300: d65f03c0     	ret
    4304: 52801421     	mov	w1, #0xa1               ; =161
    4308: 90000003     	adrp	x3, 0x4000 <___pl_fn_0+0x4000>
    430c: f9400063     	ldr	x3, [x3]
    4310: f9424be0     	ldr	x0, [sp, #0x490]
    4314: d63f0060     	blr	x3
    4318: 911783ff     	add	sp, sp, #0x5e0
    431c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4320: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4324: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4328: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    432c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4330: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4334: d65f03c0     	ret
    4338: 528013a1     	mov	w1, #0x9d               ; =157
    433c: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4340: f9400084     	ldr	x4, [x4]
    4344: f9424be0     	ldr	x0, [sp, #0x490]
    4348: d63f0080     	blr	x4
    434c: 911783ff     	add	sp, sp, #0x5e0
    4350: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4354: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4358: a8c163f7     	ldp	x23, x24, [sp], #0x10
    435c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4360: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4364: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4368: d65f03c0     	ret
    436c: 52801381     	mov	w1, #0x9c               ; =156
    4370: 90000005     	adrp	x5, 0x4000 <___pl_fn_0+0x4000>
    4374: f94000a5     	ldr	x5, [x5]
    4378: f9424be0     	ldr	x0, [sp, #0x490]
    437c: d63f00a0     	blr	x5
    4380: 911783ff     	add	sp, sp, #0x5e0
    4384: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4388: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    438c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4390: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4394: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4398: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    439c: d65f03c0     	ret
    43a0: 52801301     	mov	w1, #0x98               ; =152
    43a4: 90000006     	adrp	x6, 0x4000 <___pl_fn_0+0x4000>
    43a8: f94000c6     	ldr	x6, [x6]
    43ac: f9424be0     	ldr	x0, [sp, #0x490]
    43b0: d63f00c0     	blr	x6
    43b4: 911783ff     	add	sp, sp, #0x5e0
    43b8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    43bc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    43c0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    43c4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    43c8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    43cc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    43d0: d65f03c0     	ret
    43d4: 528012e1     	mov	w1, #0x97               ; =151
    43d8: 90000007     	adrp	x7, 0x4000 <___pl_fn_0+0x4000>
    43dc: f94000e7     	ldr	x7, [x7]
    43e0: f9424be0     	ldr	x0, [sp, #0x490]
    43e4: d63f00e0     	blr	x7
    43e8: 911783ff     	add	sp, sp, #0x5e0
    43ec: a8c153f3     	ldp	x19, x20, [sp], #0x10
    43f0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    43f4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    43f8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    43fc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4400: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4404: d65f03c0     	ret
    4408: 528012c1     	mov	w1, #0x96               ; =150
    440c: 90000008     	adrp	x8, 0x4000 <___pl_fn_0+0x4000>
    4410: f9400108     	ldr	x8, [x8]
    4414: f9424be0     	ldr	x0, [sp, #0x490]
    4418: d63f0100     	blr	x8
    441c: 911783ff     	add	sp, sp, #0x5e0
    4420: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4424: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4428: a8c163f7     	ldp	x23, x24, [sp], #0x10
    442c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4430: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4434: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4438: d65f03c0     	ret
    443c: 528015c1     	mov	w1, #0xae               ; =174
    4440: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4444: f9400042     	ldr	x2, [x2]
    4448: f9424be0     	ldr	x0, [sp, #0x490]
    444c: d63f0040     	blr	x2
    4450: 911783ff     	add	sp, sp, #0x5e0
    4454: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4458: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    445c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4460: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4464: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4468: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    446c: d65f03c0     	ret
    4470: 910dc3e3     	add	x3, sp, #0x370
    4474: f901bbfc     	str	x28, [sp, #0x370]
    4478: 528015e1     	mov	w1, #0xaf               ; =175
    447c: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4480: f9400084     	ldr	x4, [x4]
    4484: f9424be0     	ldr	x0, [sp, #0x490]
    4488: f942efe2     	ldr	x2, [sp, #0x5d8]
    448c: d63f0080     	blr	x4
    4490: 34fed4c0     	cbz	w0, 0x1f28 <___pl_fn_0+0x1f28>
    4494: 14000643     	b	0x5da0 <___pl_fn_0+0x5da0>
    4498: 910de3e3     	add	x3, sp, #0x378
    449c: f901bffa     	str	x26, [sp, #0x378]
    44a0: 52801601     	mov	w1, #0xb0               ; =176
    44a4: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    44a8: f9400084     	ldr	x4, [x4]
    44ac: f9424be0     	ldr	x0, [sp, #0x490]
    44b0: f942efe2     	ldr	x2, [sp, #0x5d8]
    44b4: d63f0080     	blr	x4
    44b8: 34fed660     	cbz	w0, 0x1f84 <___pl_fn_0+0x1f84>
    44bc: 14000639     	b	0x5da0 <___pl_fn_0+0x5da0>
    44c0: 910e03e3     	add	x3, sp, #0x380
    44c4: f901c3fc     	str	x28, [sp, #0x380]
    44c8: 52801661     	mov	w1, #0xb3               ; =179
    44cc: 90000006     	adrp	x6, 0x4000 <___pl_fn_0+0x4000>
    44d0: f94000c6     	ldr	x6, [x6]
    44d4: f9424be0     	ldr	x0, [sp, #0x490]
    44d8: aa1803e2     	mov	x2, x24
    44dc: d63f00c0     	blr	x6
    44e0: 34fed940     	cbz	w0, 0x2008 <___pl_fn_0+0x2008>
    44e4: 1400062f     	b	0x5da0 <___pl_fn_0+0x5da0>
    44e8: 910e23e3     	add	x3, sp, #0x388
    44ec: f901c7fa     	str	x26, [sp, #0x388]
    44f0: 52801681     	mov	w1, #0xb4               ; =180
    44f4: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    44f8: f9400084     	ldr	x4, [x4]
    44fc: f9424be0     	ldr	x0, [sp, #0x490]
    4500: aa1803e2     	mov	x2, x24
    4504: d63f0080     	blr	x4
    4508: 34feda60     	cbz	w0, 0x2054 <___pl_fn_0+0x2054>
    450c: 14000625     	b	0x5da0 <___pl_fn_0+0x5da0>
    4510: 910e43e3     	add	x3, sp, #0x390
    4514: f901cbfc     	str	x28, [sp, #0x390]
    4518: 528016e1     	mov	w1, #0xb7               ; =183
    451c: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4520: f9400084     	ldr	x4, [x4]
    4524: f9424be0     	ldr	x0, [sp, #0x490]
    4528: aa1503e2     	mov	x2, x21
    452c: d63f0080     	blr	x4
    4530: 34fedd40     	cbz	w0, 0x20d8 <___pl_fn_0+0x20d8>
    4534: 1400061b     	b	0x5da0 <___pl_fn_0+0x5da0>
    4538: 910e63e3     	add	x3, sp, #0x398
    453c: f901cffa     	str	x26, [sp, #0x398]
    4540: 52801701     	mov	w1, #0xb8               ; =184
    4544: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4548: f9400084     	ldr	x4, [x4]
    454c: f9424be0     	ldr	x0, [sp, #0x490]
    4550: aa1503e2     	mov	x2, x21
    4554: d63f0080     	blr	x4
    4558: 34fede60     	cbz	w0, 0x2124 <___pl_fn_0+0x2124>
    455c: 14000611     	b	0x5da0 <___pl_fn_0+0x5da0>
    4560: 910e83e3     	add	x3, sp, #0x3a0
    4564: f901d3fc     	str	x28, [sp, #0x3a0]
    4568: 528018e1     	mov	w1, #0xc7               ; =199
    456c: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4570: f9400084     	ldr	x4, [x4]
    4574: f9424be0     	ldr	x0, [sp, #0x490]
    4578: f942ebe2     	ldr	x2, [sp, #0x5d0]
    457c: d63f0080     	blr	x4
    4580: 34feec80     	cbz	w0, 0x2310 <___pl_fn_0+0x2310>
    4584: 14000607     	b	0x5da0 <___pl_fn_0+0x5da0>
    4588: 910ea3e3     	add	x3, sp, #0x3a8
    458c: f901d7fa     	str	x26, [sp, #0x3a8]
    4590: 52801901     	mov	w1, #0xc8               ; =200
    4594: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4598: f9400084     	ldr	x4, [x4]
    459c: f9424be0     	ldr	x0, [sp, #0x490]
    45a0: aa1903e2     	mov	x2, x25
    45a4: d63f0080     	blr	x4
    45a8: 34feeda0     	cbz	w0, 0x235c <___pl_fn_0+0x235c>
    45ac: 140005fd     	b	0x5da0 <___pl_fn_0+0x5da0>
    45b0: 910ec3e3     	add	x3, sp, #0x3b0
    45b4: f901dbfc     	str	x28, [sp, #0x3b0]
    45b8: 4e083c05     	mov.d	x5, v0[0]
    45bc: f901dfe5     	str	x5, [sp, #0x3b8]
    45c0: 52801981     	mov	w1, #0xcc               ; =204
    45c4: 90000006     	adrp	x6, 0x4000 <___pl_fn_0+0x4000>
    45c8: f94000c6     	ldr	x6, [x6]
    45cc: f9424be0     	ldr	x0, [sp, #0x490]
    45d0: f942ebe2     	ldr	x2, [sp, #0x5d0]
    45d4: d63f00c0     	blr	x6
    45d8: 34fef200     	cbz	w0, 0x2418 <___pl_fn_0+0x2418>
    45dc: 140005f1     	b	0x5da0 <___pl_fn_0+0x5da0>
    45e0: 910f03e3     	add	x3, sp, #0x3c0
    45e4: f901e3fc     	str	x28, [sp, #0x3c0]
    45e8: 528019a1     	mov	w1, #0xcd               ; =205
    45ec: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    45f0: f9400084     	ldr	x4, [x4]
    45f4: f9424be0     	ldr	x0, [sp, #0x490]
    45f8: f942e7e2     	ldr	x2, [sp, #0x5c8]
    45fc: d63f0080     	blr	x4
    4600: 34fef360     	cbz	w0, 0x246c <___pl_fn_0+0x246c>
    4604: 140005e7     	b	0x5da0 <___pl_fn_0+0x5da0>
    4608: 910f23e3     	add	x3, sp, #0x3c8
    460c: f901e7fa     	str	x26, [sp, #0x3c8]
    4610: 528019c1     	mov	w1, #0xce               ; =206
    4614: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4618: f9400084     	ldr	x4, [x4]
    461c: f9424be0     	ldr	x0, [sp, #0x490]
    4620: aa1903e2     	mov	x2, x25
    4624: d63f0080     	blr	x4
    4628: 34fef480     	cbz	w0, 0x24b8 <___pl_fn_0+0x24b8>
    462c: 140005dd     	b	0x5da0 <___pl_fn_0+0x5da0>
    4630: 910f43e3     	add	x3, sp, #0x3d0
    4634: f901ebfc     	str	x28, [sp, #0x3d0]
    4638: 4e083c00     	mov.d	x0, v0[0]
    463c: f901efe0     	str	x0, [sp, #0x3d8]
    4640: 52801a41     	mov	w1, #0xd2               ; =210
    4644: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4648: f9400084     	ldr	x4, [x4]
    464c: f9424be0     	ldr	x0, [sp, #0x490]
    4650: f942e7e2     	ldr	x2, [sp, #0x5c8]
    4654: d63f0080     	blr	x4
    4658: 34fef8e0     	cbz	w0, 0x2574 <___pl_fn_0+0x2574>
    465c: 140005d1     	b	0x5da0 <___pl_fn_0+0x5da0>
    4660: 910f83e3     	add	x3, sp, #0x3e0
    4664: f901f3fc     	str	x28, [sp, #0x3e0]
    4668: 52801a61     	mov	w1, #0xd3               ; =211
    466c: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4670: f9400084     	ldr	x4, [x4]
    4674: f9424be0     	ldr	x0, [sp, #0x490]
    4678: f942e3e2     	ldr	x2, [sp, #0x5c0]
    467c: d63f0080     	blr	x4
    4680: 34fefa40     	cbz	w0, 0x25c8 <___pl_fn_0+0x25c8>
    4684: 140005c7     	b	0x5da0 <___pl_fn_0+0x5da0>
    4688: 910fa3e3     	add	x3, sp, #0x3e8
    468c: f901f7fa     	str	x26, [sp, #0x3e8]
    4690: 52801a81     	mov	w1, #0xd4               ; =212
    4694: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4698: f9400084     	ldr	x4, [x4]
    469c: f9424be0     	ldr	x0, [sp, #0x490]
    46a0: aa1903e2     	mov	x2, x25
    46a4: d63f0080     	blr	x4
    46a8: 34fefb60     	cbz	w0, 0x2614 <___pl_fn_0+0x2614>
    46ac: 140005bd     	b	0x5da0 <___pl_fn_0+0x5da0>
    46b0: 910fc3e3     	add	x3, sp, #0x3f0
    46b4: f901fbfc     	str	x28, [sp, #0x3f0]
    46b8: 4e083f60     	mov.d	x0, v27[0]
    46bc: f901ffe0     	str	x0, [sp, #0x3f8]
    46c0: 52801b01     	mov	w1, #0xd8               ; =216
    46c4: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    46c8: f9400084     	ldr	x4, [x4]
    46cc: f9424be0     	ldr	x0, [sp, #0x490]
    46d0: f942e3e2     	ldr	x2, [sp, #0x5c0]
    46d4: d63f0080     	blr	x4
    46d8: 34feffc0     	cbz	w0, 0x26d0 <___pl_fn_0+0x26d0>
    46dc: 140005b1     	b	0x5da0 <___pl_fn_0+0x5da0>
    46e0: 911003e3     	add	x3, sp, #0x400
    46e4: f90203fa     	str	x26, [sp, #0x400]
    46e8: 52801b21     	mov	w1, #0xd9               ; =217
    46ec: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    46f0: f9400084     	ldr	x4, [x4]
    46f4: f9424be0     	ldr	x0, [sp, #0x490]
    46f8: f942ebe2     	ldr	x2, [sp, #0x5d0]
    46fc: d63f0080     	blr	x4
    4700: 34ff0120     	cbz	w0, 0x2724 <___pl_fn_0+0x2724>
    4704: 140005a7     	b	0x5da0 <___pl_fn_0+0x5da0>
    4708: 911023e3     	add	x3, sp, #0x408
    470c: f90207fc     	str	x28, [sp, #0x408]
    4710: 52801b41     	mov	w1, #0xda               ; =218
    4714: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4718: f9400084     	ldr	x4, [x4]
    471c: f9424be0     	ldr	x0, [sp, #0x490]
    4720: aa1903e2     	mov	x2, x25
    4724: d63f0080     	blr	x4
    4728: 34ff0240     	cbz	w0, 0x2770 <___pl_fn_0+0x2770>
    472c: 1400059d     	b	0x5da0 <___pl_fn_0+0x5da0>
    4730: 911043e3     	add	x3, sp, #0x410
    4734: f9020bfa     	str	x26, [sp, #0x410]
    4738: 4e083e00     	mov.d	x0, v16[0]
    473c: f9020fe0     	str	x0, [sp, #0x418]
    4740: 52801bc1     	mov	w1, #0xde               ; =222
    4744: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4748: f9400084     	ldr	x4, [x4]
    474c: f9424be0     	ldr	x0, [sp, #0x490]
    4750: f942ebe2     	ldr	x2, [sp, #0x5d0]
    4754: d63f0080     	blr	x4
    4758: 34ff06a0     	cbz	w0, 0x282c <___pl_fn_0+0x282c>
    475c: 14000591     	b	0x5da0 <___pl_fn_0+0x5da0>
    4760: 911083e3     	add	x3, sp, #0x420
    4764: f90213fa     	str	x26, [sp, #0x420]
    4768: 52801be1     	mov	w1, #0xdf               ; =223
    476c: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4770: f9400084     	ldr	x4, [x4]
    4774: f9424be0     	ldr	x0, [sp, #0x490]
    4778: f942e7e2     	ldr	x2, [sp, #0x5c8]
    477c: d63f0080     	blr	x4
    4780: 34ff0800     	cbz	w0, 0x2880 <___pl_fn_0+0x2880>
    4784: 14000587     	b	0x5da0 <___pl_fn_0+0x5da0>
    4788: 9110a3e3     	add	x3, sp, #0x428
    478c: f90217fc     	str	x28, [sp, #0x428]
    4790: 52801c01     	mov	w1, #0xe0               ; =224
    4794: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4798: f9400084     	ldr	x4, [x4]
    479c: f9424be0     	ldr	x0, [sp, #0x490]
    47a0: aa1903e2     	mov	x2, x25
    47a4: d63f0080     	blr	x4
    47a8: 34ff0920     	cbz	w0, 0x28cc <___pl_fn_0+0x28cc>
    47ac: 1400057d     	b	0x5da0 <___pl_fn_0+0x5da0>
    47b0: 9110c3e3     	add	x3, sp, #0x430
    47b4: f9021bfa     	str	x26, [sp, #0x430]
    47b8: 4e083c04     	mov.d	x4, v0[0]
    47bc: f9021fe4     	str	x4, [sp, #0x438]
    47c0: 52801c81     	mov	w1, #0xe4               ; =228
    47c4: 90000005     	adrp	x5, 0x4000 <___pl_fn_0+0x4000>
    47c8: f94000a5     	ldr	x5, [x5]
    47cc: f9424be0     	ldr	x0, [sp, #0x490]
    47d0: f942e7e2     	ldr	x2, [sp, #0x5c8]
    47d4: d63f00a0     	blr	x5
    47d8: 34ff0d80     	cbz	w0, 0x2988 <___pl_fn_0+0x2988>
    47dc: 14000571     	b	0x5da0 <___pl_fn_0+0x5da0>
    47e0: 911103e3     	add	x3, sp, #0x440
    47e4: f90223fa     	str	x26, [sp, #0x440]
    47e8: 52801ca1     	mov	w1, #0xe5               ; =229
    47ec: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    47f0: f9400084     	ldr	x4, [x4]
    47f4: f9424be0     	ldr	x0, [sp, #0x490]
    47f8: f942e3e2     	ldr	x2, [sp, #0x5c0]
    47fc: d63f0080     	blr	x4
    4800: 34ff0ee0     	cbz	w0, 0x29dc <___pl_fn_0+0x29dc>
    4804: 14000567     	b	0x5da0 <___pl_fn_0+0x5da0>
    4808: 911123e3     	add	x3, sp, #0x448
    480c: f90227fc     	str	x28, [sp, #0x448]
    4810: 52801cc1     	mov	w1, #0xe6               ; =230
    4814: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4818: f9400084     	ldr	x4, [x4]
    481c: f9424be0     	ldr	x0, [sp, #0x490]
    4820: aa1903e2     	mov	x2, x25
    4824: d63f0080     	blr	x4
    4828: 34ff1000     	cbz	w0, 0x2a28 <___pl_fn_0+0x2a28>
    482c: 1400055d     	b	0x5da0 <___pl_fn_0+0x5da0>
    4830: 911143e3     	add	x3, sp, #0x450
    4834: f9022bfa     	str	x26, [sp, #0x450]
    4838: 4e083c00     	mov.d	x0, v0[0]
    483c: f9022fe0     	str	x0, [sp, #0x458]
    4840: 52801d41     	mov	w1, #0xea               ; =234
    4844: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    4848: f9400084     	ldr	x4, [x4]
    484c: f9424be0     	ldr	x0, [sp, #0x490]
    4850: f942e3e2     	ldr	x2, [sp, #0x5c0]
    4854: d63f0080     	blr	x4
    4858: 34ff1460     	cbz	w0, 0x2ae4 <___pl_fn_0+0x2ae4>
    485c: 14000551     	b	0x5da0 <___pl_fn_0+0x5da0>
    4860: 52801d61     	mov	w1, #0xeb               ; =235
    4864: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4868: f9400042     	ldr	x2, [x2]
    486c: f9424be0     	ldr	x0, [sp, #0x490]
    4870: d63f0040     	blr	x2
    4874: 911783ff     	add	sp, sp, #0x5e0
    4878: a8c153f3     	ldp	x19, x20, [sp], #0x10
    487c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4880: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4884: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4888: a8c173fb     	ldp	x27, x28, [sp], #0x10
    488c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4890: d65f03c0     	ret
    4894: 52801d21     	mov	w1, #0xe9               ; =233
    4898: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    489c: f9400042     	ldr	x2, [x2]
    48a0: f9424be0     	ldr	x0, [sp, #0x490]
    48a4: d63f0040     	blr	x2
    48a8: 911783ff     	add	sp, sp, #0x5e0
    48ac: a8c153f3     	ldp	x19, x20, [sp], #0x10
    48b0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    48b4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    48b8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    48bc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    48c0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    48c4: d65f03c0     	ret
    48c8: 52801d01     	mov	w1, #0xe8               ; =232
    48cc: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    48d0: f9400042     	ldr	x2, [x2]
    48d4: f9424be0     	ldr	x0, [sp, #0x490]
    48d8: d63f0040     	blr	x2
    48dc: 911783ff     	add	sp, sp, #0x5e0
    48e0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    48e4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    48e8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    48ec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    48f0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    48f4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    48f8: d65f03c0     	ret
    48fc: 52801ce1     	mov	w1, #0xe7               ; =231
    4900: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4904: f9400042     	ldr	x2, [x2]
    4908: f9424be0     	ldr	x0, [sp, #0x490]
    490c: d63f0040     	blr	x2
    4910: 911783ff     	add	sp, sp, #0x5e0
    4914: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4918: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    491c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4920: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4924: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4928: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    492c: d65f03c0     	ret
    4930: 52801c61     	mov	w1, #0xe3               ; =227
    4934: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4938: f9400042     	ldr	x2, [x2]
    493c: f9424be0     	ldr	x0, [sp, #0x490]
    4940: d63f0040     	blr	x2
    4944: 911783ff     	add	sp, sp, #0x5e0
    4948: a8c153f3     	ldp	x19, x20, [sp], #0x10
    494c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4950: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4954: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4958: a8c173fb     	ldp	x27, x28, [sp], #0x10
    495c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4960: d65f03c0     	ret
    4964: 52801c41     	mov	w1, #0xe2               ; =226
    4968: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    496c: f9400042     	ldr	x2, [x2]
    4970: f9424be0     	ldr	x0, [sp, #0x490]
    4974: d63f0040     	blr	x2
    4978: 911783ff     	add	sp, sp, #0x5e0
    497c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4980: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4984: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4988: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    498c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4990: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4994: d65f03c0     	ret
    4998: 52801c21     	mov	w1, #0xe1               ; =225
    499c: 90000003     	adrp	x3, 0x4000 <___pl_fn_0+0x4000>
    49a0: f9400063     	ldr	x3, [x3]
    49a4: f9424be0     	ldr	x0, [sp, #0x490]
    49a8: d63f0060     	blr	x3
    49ac: 911783ff     	add	sp, sp, #0x5e0
    49b0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    49b4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    49b8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    49bc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    49c0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    49c4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    49c8: d65f03c0     	ret
    49cc: 52801ba1     	mov	w1, #0xdd               ; =221
    49d0: 90000004     	adrp	x4, 0x4000 <___pl_fn_0+0x4000>
    49d4: f9400084     	ldr	x4, [x4]
    49d8: f9424be0     	ldr	x0, [sp, #0x490]
    49dc: d63f0080     	blr	x4
    49e0: 911783ff     	add	sp, sp, #0x5e0
    49e4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    49e8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    49ec: a8c163f7     	ldp	x23, x24, [sp], #0x10
    49f0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    49f4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    49f8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    49fc: d65f03c0     	ret
    4a00: 52801b81     	mov	w1, #0xdc               ; =220
    4a04: 90000005     	adrp	x5, 0x4000 <___pl_fn_0+0x4000>
    4a08: f94000a5     	ldr	x5, [x5]
    4a0c: f9424be0     	ldr	x0, [sp, #0x490]
    4a10: d63f00a0     	blr	x5
    4a14: 911783ff     	add	sp, sp, #0x5e0
    4a18: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4a1c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4a20: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4a24: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4a28: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4a2c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4a30: d65f03c0     	ret
    4a34: 52801b61     	mov	w1, #0xdb               ; =219
    4a38: 90000006     	adrp	x6, 0x4000 <___pl_fn_0+0x4000>
    4a3c: f94000c6     	ldr	x6, [x6]
    4a40: f9424be0     	ldr	x0, [sp, #0x490]
    4a44: d63f00c0     	blr	x6
    4a48: 911783ff     	add	sp, sp, #0x5e0
    4a4c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4a50: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4a54: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4a58: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4a5c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4a60: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4a64: d65f03c0     	ret
    4a68: 52801ae1     	mov	w1, #0xd7               ; =215
    4a6c: 90000007     	adrp	x7, 0x4000 <___pl_fn_0+0x4000>
    4a70: f94000e7     	ldr	x7, [x7]
    4a74: f9424be0     	ldr	x0, [sp, #0x490]
    4a78: d63f00e0     	blr	x7
    4a7c: 911783ff     	add	sp, sp, #0x5e0
    4a80: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4a84: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4a88: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4a8c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4a90: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4a94: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4a98: d65f03c0     	ret
    4a9c: 52801ac1     	mov	w1, #0xd6               ; =214
    4aa0: 90000008     	adrp	x8, 0x4000 <___pl_fn_0+0x4000>
    4aa4: f9400108     	ldr	x8, [x8]
    4aa8: f9424be0     	ldr	x0, [sp, #0x490]
    4aac: d63f0100     	blr	x8
    4ab0: 911783ff     	add	sp, sp, #0x5e0
    4ab4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4ab8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4abc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4ac0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4ac4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4ac8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4acc: d65f03c0     	ret
    4ad0: 52801aa1     	mov	w1, #0xd5               ; =213
    4ad4: 90000009     	adrp	x9, 0x4000 <___pl_fn_0+0x4000>
    4ad8: f9400129     	ldr	x9, [x9]
    4adc: f9424be0     	ldr	x0, [sp, #0x490]
    4ae0: d63f0120     	blr	x9
    4ae4: 911783ff     	add	sp, sp, #0x5e0
    4ae8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4aec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4af0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4af4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4af8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4afc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4b00: d65f03c0     	ret
    4b04: 52801a21     	mov	w1, #0xd1               ; =209
    4b08: 9000000a     	adrp	x10, 0x4000 <___pl_fn_0+0x4000>
    4b0c: f940014a     	ldr	x10, [x10]
    4b10: f9424be0     	ldr	x0, [sp, #0x490]
    4b14: d63f0140     	blr	x10
    4b18: 911783ff     	add	sp, sp, #0x5e0
    4b1c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4b20: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4b24: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4b28: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4b2c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4b30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4b34: d65f03c0     	ret
    4b38: 52801a01     	mov	w1, #0xd0               ; =208
    4b3c: 9000000b     	adrp	x11, 0x4000 <___pl_fn_0+0x4000>
    4b40: f940016b     	ldr	x11, [x11]
    4b44: f9424be0     	ldr	x0, [sp, #0x490]
    4b48: d63f0160     	blr	x11
    4b4c: 911783ff     	add	sp, sp, #0x5e0
    4b50: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4b54: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4b58: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4b5c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4b60: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4b64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4b68: d65f03c0     	ret
    4b6c: 528019e1     	mov	w1, #0xcf               ; =207
    4b70: 9000000c     	adrp	x12, 0x4000 <___pl_fn_0+0x4000>
    4b74: f940018c     	ldr	x12, [x12]
    4b78: f9424be0     	ldr	x0, [sp, #0x490]
    4b7c: d63f0180     	blr	x12
    4b80: 911783ff     	add	sp, sp, #0x5e0
    4b84: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4b88: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4b8c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4b90: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4b94: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4b98: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4b9c: d65f03c0     	ret
    4ba0: 52801961     	mov	w1, #0xcb               ; =203
    4ba4: 9000000d     	adrp	x13, 0x4000 <___pl_fn_0+0x4000>
    4ba8: f94001ad     	ldr	x13, [x13]
    4bac: f9424be0     	ldr	x0, [sp, #0x490]
    4bb0: d63f01a0     	blr	x13
    4bb4: 911783ff     	add	sp, sp, #0x5e0
    4bb8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4bbc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4bc0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4bc4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4bc8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4bcc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4bd0: d65f03c0     	ret
    4bd4: 52801941     	mov	w1, #0xca               ; =202
    4bd8: 9000000e     	adrp	x14, 0x4000 <___pl_fn_0+0x4000>
    4bdc: f94001ce     	ldr	x14, [x14]
    4be0: f9424be0     	ldr	x0, [sp, #0x490]
    4be4: d63f01c0     	blr	x14
    4be8: 911783ff     	add	sp, sp, #0x5e0
    4bec: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4bf0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4bf4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4bf8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4bfc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4c00: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4c04: d65f03c0     	ret
    4c08: 52801921     	mov	w1, #0xc9               ; =201
    4c0c: 9000000f     	adrp	x15, 0x4000 <___pl_fn_0+0x4000>
    4c10: f94001ef     	ldr	x15, [x15]
    4c14: f9424be0     	ldr	x0, [sp, #0x490]
    4c18: d63f01e0     	blr	x15
    4c1c: 911783ff     	add	sp, sp, #0x5e0
    4c20: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4c24: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4c28: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4c2c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4c30: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4c34: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4c38: d65f03c0     	ret
    4c3c: 528018c1     	mov	w1, #0xc6               ; =198
    4c40: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4c44: f9400042     	ldr	x2, [x2]
    4c48: f9424be0     	ldr	x0, [sp, #0x490]
    4c4c: d63f0040     	blr	x2
    4c50: 911783ff     	add	sp, sp, #0x5e0
    4c54: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4c58: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4c5c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4c60: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4c64: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4c68: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4c6c: d65f03c0     	ret
    4c70: 528018a1     	mov	w1, #0xc5               ; =197
    4c74: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4c78: f9400042     	ldr	x2, [x2]
    4c7c: f9424be0     	ldr	x0, [sp, #0x490]
    4c80: d63f0040     	blr	x2
    4c84: 911783ff     	add	sp, sp, #0x5e0
    4c88: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4c8c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4c90: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4c94: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4c98: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4c9c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4ca0: d65f03c0     	ret
    4ca4: 52801881     	mov	w1, #0xc4               ; =196
    4ca8: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4cac: f9400042     	ldr	x2, [x2]
    4cb0: f9424be0     	ldr	x0, [sp, #0x490]
    4cb4: d63f0040     	blr	x2
    4cb8: 911783ff     	add	sp, sp, #0x5e0
    4cbc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4cc0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4cc4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4cc8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4ccc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4cd0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4cd4: d65f03c0     	ret
    4cd8: 52801861     	mov	w1, #0xc3               ; =195
    4cdc: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4ce0: f9400042     	ldr	x2, [x2]
    4ce4: f9424be0     	ldr	x0, [sp, #0x490]
    4ce8: d63f0040     	blr	x2
    4cec: 911783ff     	add	sp, sp, #0x5e0
    4cf0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4cf4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4cf8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4cfc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4d00: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4d04: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4d08: d65f03c0     	ret
    4d0c: 52801841     	mov	w1, #0xc2               ; =194
    4d10: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4d14: f9400042     	ldr	x2, [x2]
    4d18: f9424be0     	ldr	x0, [sp, #0x490]
    4d1c: d63f0040     	blr	x2
    4d20: 911783ff     	add	sp, sp, #0x5e0
    4d24: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4d28: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4d2c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4d30: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4d34: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4d38: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4d3c: d65f03c0     	ret
    4d40: 52801821     	mov	w1, #0xc1               ; =193
    4d44: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4d48: f9400042     	ldr	x2, [x2]
    4d4c: f9424be0     	ldr	x0, [sp, #0x490]
    4d50: d63f0040     	blr	x2
    4d54: 911783ff     	add	sp, sp, #0x5e0
    4d58: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4d5c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4d60: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4d64: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4d68: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4d6c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4d70: d65f03c0     	ret
    4d74: 52801801     	mov	w1, #0xc0               ; =192
    4d78: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4d7c: f9400042     	ldr	x2, [x2]
    4d80: f9424be0     	ldr	x0, [sp, #0x490]
    4d84: d63f0040     	blr	x2
    4d88: 911783ff     	add	sp, sp, #0x5e0
    4d8c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4d90: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4d94: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4d98: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4d9c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4da0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4da4: d65f03c0     	ret
    4da8: 528017e1     	mov	w1, #0xbf               ; =191
    4dac: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4db0: f9400042     	ldr	x2, [x2]
    4db4: f9424be0     	ldr	x0, [sp, #0x490]
    4db8: d63f0040     	blr	x2
    4dbc: 911783ff     	add	sp, sp, #0x5e0
    4dc0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4dc4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4dc8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4dcc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4dd0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4dd4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4dd8: d65f03c0     	ret
    4ddc: 528017c1     	mov	w1, #0xbe               ; =190
    4de0: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4de4: f9400042     	ldr	x2, [x2]
    4de8: f9424be0     	ldr	x0, [sp, #0x490]
    4dec: d63f0040     	blr	x2
    4df0: 911783ff     	add	sp, sp, #0x5e0
    4df4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4df8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4dfc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4e00: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4e04: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4e08: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4e0c: d65f03c0     	ret
    4e10: 528017a1     	mov	w1, #0xbd               ; =189
    4e14: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4e18: f9400042     	ldr	x2, [x2]
    4e1c: f9424be0     	ldr	x0, [sp, #0x490]
    4e20: d63f0040     	blr	x2
    4e24: 911783ff     	add	sp, sp, #0x5e0
    4e28: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4e2c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4e30: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4e34: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4e38: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4e3c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4e40: d65f03c0     	ret
    4e44: 52801781     	mov	w1, #0xbc               ; =188
    4e48: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4e4c: f9400042     	ldr	x2, [x2]
    4e50: f9424be0     	ldr	x0, [sp, #0x490]
    4e54: d63f0040     	blr	x2
    4e58: 911783ff     	add	sp, sp, #0x5e0
    4e5c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4e60: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4e64: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4e68: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4e6c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4e70: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4e74: d65f03c0     	ret
    4e78: 52801761     	mov	w1, #0xbb               ; =187
    4e7c: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4e80: f9400042     	ldr	x2, [x2]
    4e84: f9424be0     	ldr	x0, [sp, #0x490]
    4e88: d63f0040     	blr	x2
    4e8c: 911783ff     	add	sp, sp, #0x5e0
    4e90: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4e94: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4e98: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4e9c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4ea0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4ea4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4ea8: d65f03c0     	ret
    4eac: 52801741     	mov	w1, #0xba               ; =186
    4eb0: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4eb4: f9400042     	ldr	x2, [x2]
    4eb8: f9424be0     	ldr	x0, [sp, #0x490]
    4ebc: d63f0040     	blr	x2
    4ec0: 911783ff     	add	sp, sp, #0x5e0
    4ec4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4ec8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4ecc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4ed0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4ed4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4ed8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4edc: d65f03c0     	ret
    4ee0: 52801721     	mov	w1, #0xb9               ; =185
    4ee4: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4ee8: f9400042     	ldr	x2, [x2]
    4eec: f9424be0     	ldr	x0, [sp, #0x490]
    4ef0: d63f0040     	blr	x2
    4ef4: 911783ff     	add	sp, sp, #0x5e0
    4ef8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4efc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4f00: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4f04: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4f08: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4f0c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4f10: d65f03c0     	ret
    4f14: 528016c1     	mov	w1, #0xb6               ; =182
    4f18: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4f1c: f9400042     	ldr	x2, [x2]
    4f20: f9424be0     	ldr	x0, [sp, #0x490]
    4f24: d63f0040     	blr	x2
    4f28: 911783ff     	add	sp, sp, #0x5e0
    4f2c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4f30: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4f34: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4f38: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4f3c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4f40: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4f44: d65f03c0     	ret
    4f48: 528016a1     	mov	w1, #0xb5               ; =181
    4f4c: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4f50: f9400042     	ldr	x2, [x2]
    4f54: f9424be0     	ldr	x0, [sp, #0x490]
    4f58: d63f0040     	blr	x2
    4f5c: 911783ff     	add	sp, sp, #0x5e0
    4f60: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4f64: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4f68: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4f6c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4f70: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4f74: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4f78: d65f03c0     	ret
    4f7c: 52801641     	mov	w1, #0xb2               ; =178
    4f80: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4f84: f9400042     	ldr	x2, [x2]
    4f88: f9424be0     	ldr	x0, [sp, #0x490]
    4f8c: d63f0040     	blr	x2
    4f90: 911783ff     	add	sp, sp, #0x5e0
    4f94: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4f98: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4f9c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4fa0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4fa4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4fa8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4fac: d65f03c0     	ret
    4fb0: 52801621     	mov	w1, #0xb1               ; =177
    4fb4: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4fb8: f9400042     	ldr	x2, [x2]
    4fbc: f9424be0     	ldr	x0, [sp, #0x490]
    4fc0: d63f0040     	blr	x2
    4fc4: 911783ff     	add	sp, sp, #0x5e0
    4fc8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    4fcc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    4fd0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    4fd4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    4fd8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    4fdc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    4fe0: d65f03c0     	ret
    4fe4: 528015a1     	mov	w1, #0xad               ; =173
    4fe8: 90000002     	adrp	x2, 0x4000 <___pl_fn_0+0x4000>
    4fec: f9400042     	ldr	x2, [x2]
    4ff0: f9424be0     	ldr	x0, [sp, #0x490]
    4ff4: d63f0040     	blr	x2
    4ff8: 911783ff     	add	sp, sp, #0x5e0
    4ffc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5000: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5004: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5008: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    500c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5010: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5014: d65f03c0     	ret
    5018: 52801581     	mov	w1, #0xac               ; =172
    501c: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5020: f9400042     	ldr	x2, [x2]
    5024: f9424be0     	ldr	x0, [sp, #0x490]
    5028: d63f0040     	blr	x2
    502c: 911783ff     	add	sp, sp, #0x5e0
    5030: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5034: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5038: a8c163f7     	ldp	x23, x24, [sp], #0x10
    503c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5040: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5044: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5048: d65f03c0     	ret
    504c: 52801561     	mov	w1, #0xab               ; =171
    5050: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5054: f9400042     	ldr	x2, [x2]
    5058: f9424be0     	ldr	x0, [sp, #0x490]
    505c: d63f0040     	blr	x2
    5060: 911783ff     	add	sp, sp, #0x5e0
    5064: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5068: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    506c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5070: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5074: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5078: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    507c: d65f03c0     	ret
    5080: 52801541     	mov	w1, #0xaa               ; =170
    5084: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5088: f9400042     	ldr	x2, [x2]
    508c: f9424be0     	ldr	x0, [sp, #0x490]
    5090: d63f0040     	blr	x2
    5094: 911783ff     	add	sp, sp, #0x5e0
    5098: a8c153f3     	ldp	x19, x20, [sp], #0x10
    509c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    50a0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    50a4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    50a8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    50ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    50b0: d65f03c0     	ret
    50b4: 528012a1     	mov	w1, #0x95               ; =149
    50b8: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    50bc: f9400042     	ldr	x2, [x2]
    50c0: f9424be0     	ldr	x0, [sp, #0x490]
    50c4: d63f0040     	blr	x2
    50c8: 911783ff     	add	sp, sp, #0x5e0
    50cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    50d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    50d4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    50d8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    50dc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    50e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    50e4: d65f03c0     	ret
    50e8: 52801281     	mov	w1, #0x94               ; =148
    50ec: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    50f0: f9400042     	ldr	x2, [x2]
    50f4: f9424be0     	ldr	x0, [sp, #0x490]
    50f8: d63f0040     	blr	x2
    50fc: 911783ff     	add	sp, sp, #0x5e0
    5100: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5104: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5108: a8c163f7     	ldp	x23, x24, [sp], #0x10
    510c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5110: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5114: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5118: d65f03c0     	ret
    511c: 52801261     	mov	w1, #0x93               ; =147
    5120: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5124: f9400042     	ldr	x2, [x2]
    5128: f9424be0     	ldr	x0, [sp, #0x490]
    512c: d63f0040     	blr	x2
    5130: 911783ff     	add	sp, sp, #0x5e0
    5134: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5138: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    513c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5140: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5144: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5148: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    514c: d65f03c0     	ret
    5150: 52800b61     	mov	w1, #0x5b               ; =91
    5154: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5158: f9400042     	ldr	x2, [x2]
    515c: f9424be0     	ldr	x0, [sp, #0x490]
    5160: d63f0040     	blr	x2
    5164: 911783ff     	add	sp, sp, #0x5e0
    5168: a8c153f3     	ldp	x19, x20, [sp], #0x10
    516c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5170: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5174: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5178: a8c173fb     	ldp	x27, x28, [sp], #0x10
    517c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5180: d65f03c0     	ret
    5184: 52800b41     	mov	w1, #0x5a               ; =90
    5188: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    518c: f9400042     	ldr	x2, [x2]
    5190: f9424be0     	ldr	x0, [sp, #0x490]
    5194: d63f0040     	blr	x2
    5198: 911783ff     	add	sp, sp, #0x5e0
    519c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    51a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    51a4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    51a8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    51ac: a8c173fb     	ldp	x27, x28, [sp], #0x10
    51b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    51b4: d65f03c0     	ret
    51b8: 52800b21     	mov	w1, #0x59               ; =89
    51bc: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    51c0: f9400042     	ldr	x2, [x2]
    51c4: f9424be0     	ldr	x0, [sp, #0x490]
    51c8: d63f0040     	blr	x2
    51cc: 911783ff     	add	sp, sp, #0x5e0
    51d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    51d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    51d8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    51dc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    51e0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    51e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    51e8: d65f03c0     	ret
    51ec: 52800ae1     	mov	w1, #0x57               ; =87
    51f0: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    51f4: f9400042     	ldr	x2, [x2]
    51f8: f9424be0     	ldr	x0, [sp, #0x490]
    51fc: d63f0040     	blr	x2
    5200: 911783ff     	add	sp, sp, #0x5e0
    5204: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5208: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    520c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5210: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5214: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5218: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    521c: d65f03c0     	ret
    5220: 52800ac1     	mov	w1, #0x56               ; =86
    5224: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5228: f9400042     	ldr	x2, [x2]
    522c: f9424be0     	ldr	x0, [sp, #0x490]
    5230: d63f0040     	blr	x2
    5234: 911783ff     	add	sp, sp, #0x5e0
    5238: a8c153f3     	ldp	x19, x20, [sp], #0x10
    523c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5240: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5244: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5248: a8c173fb     	ldp	x27, x28, [sp], #0x10
    524c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5250: d65f03c0     	ret
    5254: 52800aa1     	mov	w1, #0x55               ; =85
    5258: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    525c: f9400042     	ldr	x2, [x2]
    5260: f9424be0     	ldr	x0, [sp, #0x490]
    5264: d63f0040     	blr	x2
    5268: 911783ff     	add	sp, sp, #0x5e0
    526c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5270: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5274: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5278: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    527c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5280: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5284: d65f03c0     	ret
    5288: 52800a61     	mov	w1, #0x53               ; =83
    528c: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5290: f9400042     	ldr	x2, [x2]
    5294: f9424be0     	ldr	x0, [sp, #0x490]
    5298: d63f0040     	blr	x2
    529c: 911783ff     	add	sp, sp, #0x5e0
    52a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    52a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    52a8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    52ac: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    52b0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    52b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    52b8: d65f03c0     	ret
    52bc: 52800a41     	mov	w1, #0x52               ; =82
    52c0: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    52c4: f9400042     	ldr	x2, [x2]
    52c8: f9424be0     	ldr	x0, [sp, #0x490]
    52cc: d63f0040     	blr	x2
    52d0: 911783ff     	add	sp, sp, #0x5e0
    52d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    52d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    52dc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    52e0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    52e4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    52e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    52ec: d65f03c0     	ret
    52f0: 52800a21     	mov	w1, #0x51               ; =81
    52f4: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    52f8: f9400042     	ldr	x2, [x2]
    52fc: f9424be0     	ldr	x0, [sp, #0x490]
    5300: d63f0040     	blr	x2
    5304: 911783ff     	add	sp, sp, #0x5e0
    5308: a8c153f3     	ldp	x19, x20, [sp], #0x10
    530c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5310: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5314: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5318: a8c173fb     	ldp	x27, x28, [sp], #0x10
    531c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5320: d65f03c0     	ret
    5324: 528009e1     	mov	w1, #0x4f               ; =79
    5328: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    532c: f9400042     	ldr	x2, [x2]
    5330: f9424be0     	ldr	x0, [sp, #0x490]
    5334: d63f0040     	blr	x2
    5338: 911783ff     	add	sp, sp, #0x5e0
    533c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5340: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5344: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5348: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    534c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5350: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5354: d65f03c0     	ret
    5358: 528009c1     	mov	w1, #0x4e               ; =78
    535c: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5360: f9400042     	ldr	x2, [x2]
    5364: f9424be0     	ldr	x0, [sp, #0x490]
    5368: d63f0040     	blr	x2
    536c: 911783ff     	add	sp, sp, #0x5e0
    5370: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5374: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5378: a8c163f7     	ldp	x23, x24, [sp], #0x10
    537c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5380: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5384: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5388: d65f03c0     	ret
    538c: 528009a1     	mov	w1, #0x4d               ; =77
    5390: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5394: f9400042     	ldr	x2, [x2]
    5398: f9424be0     	ldr	x0, [sp, #0x490]
    539c: d63f0040     	blr	x2
    53a0: 911783ff     	add	sp, sp, #0x5e0
    53a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    53a8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    53ac: a8c163f7     	ldp	x23, x24, [sp], #0x10
    53b0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    53b4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    53b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    53bc: d65f03c0     	ret
    53c0: 911183e3     	add	x3, sp, #0x460
    53c4: f90233fc     	str	x28, [sp, #0x460]
    53c8: 52801d81     	mov	w1, #0xec               ; =236
    53cc: 90000004     	adrp	x4, 0x5000 <___pl_fn_0+0x5000>
    53d0: f9400084     	ldr	x4, [x4]
    53d4: f9424be0     	ldr	x0, [sp, #0x490]
    53d8: f942ebe2     	ldr	x2, [sp, #0x5d0]
    53dc: d63f0080     	blr	x4
    53e0: 34febbe0     	cbz	w0, 0x2b5c <___pl_fn_0+0x2b5c>
    53e4: 1400026f     	b	0x5da0 <___pl_fn_0+0x5da0>
    53e8: 9111a3e3     	add	x3, sp, #0x468
    53ec: f90237fc     	str	x28, [sp, #0x468]
    53f0: 52801da1     	mov	w1, #0xed               ; =237
    53f4: 9000000c     	adrp	x12, 0x5000 <___pl_fn_0+0x5000>
    53f8: f940018c     	ldr	x12, [x12]
    53fc: f9424be0     	ldr	x0, [sp, #0x490]
    5400: aa1903e2     	mov	x2, x25
    5404: d63f0180     	blr	x12
    5408: 34febd00     	cbz	w0, 0x2ba8 <___pl_fn_0+0x2ba8>
    540c: 14000265     	b	0x5da0 <___pl_fn_0+0x5da0>
    5410: 9111c3e3     	add	x3, sp, #0x470
    5414: f9023bfc     	str	x28, [sp, #0x470]
    5418: 52801e21     	mov	w1, #0xf1               ; =241
    541c: 90000004     	adrp	x4, 0x5000 <___pl_fn_0+0x5000>
    5420: f9400084     	ldr	x4, [x4]
    5424: f9424be0     	ldr	x0, [sp, #0x490]
    5428: f942e7e2     	ldr	x2, [sp, #0x5c8]
    542c: d63f0080     	blr	x4
    5430: 34fec120     	cbz	w0, 0x2c54 <___pl_fn_0+0x2c54>
    5434: 1400025b     	b	0x5da0 <___pl_fn_0+0x5da0>
    5438: 9111e3e3     	add	x3, sp, #0x478
    543c: f9023ffc     	str	x28, [sp, #0x478]
    5440: 52801e41     	mov	w1, #0xf2               ; =242
    5444: 90000004     	adrp	x4, 0x5000 <___pl_fn_0+0x5000>
    5448: f9400084     	ldr	x4, [x4]
    544c: f9424be0     	ldr	x0, [sp, #0x490]
    5450: aa1903e2     	mov	x2, x25
    5454: d63f0080     	blr	x4
    5458: 34fec240     	cbz	w0, 0x2ca0 <___pl_fn_0+0x2ca0>
    545c: 14000251     	b	0x5da0 <___pl_fn_0+0x5da0>
    5460: 911203e3     	add	x3, sp, #0x480
    5464: f90243fc     	str	x28, [sp, #0x480]
    5468: 52801ec1     	mov	w1, #0xf6               ; =246
    546c: 90000004     	adrp	x4, 0x5000 <___pl_fn_0+0x5000>
    5470: f9400084     	ldr	x4, [x4]
    5474: f9424be0     	ldr	x0, [sp, #0x490]
    5478: f942e3e2     	ldr	x2, [sp, #0x5c0]
    547c: d63f0080     	blr	x4
    5480: 34fec6a0     	cbz	w0, 0x2d54 <___pl_fn_0+0x2d54>
    5484: 14000247     	b	0x5da0 <___pl_fn_0+0x5da0>
    5488: 911223e3     	add	x3, sp, #0x488
    548c: f90247fc     	str	x28, [sp, #0x488]
    5490: 52801ee1     	mov	w1, #0xf7               ; =247
    5494: 90000004     	adrp	x4, 0x5000 <___pl_fn_0+0x5000>
    5498: f9400084     	ldr	x4, [x4]
    549c: f9424be0     	ldr	x0, [sp, #0x490]
    54a0: aa1903e2     	mov	x2, x25
    54a4: d63f0080     	blr	x4
    54a8: 34fec7c0     	cbz	w0, 0x2da0 <___pl_fn_0+0x2da0>
    54ac: 1400023d     	b	0x5da0 <___pl_fn_0+0x5da0>
    54b0: 52801f61     	mov	w1, #0xfb               ; =251
    54b4: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    54b8: f9400042     	ldr	x2, [x2]
    54bc: f9424be0     	ldr	x0, [sp, #0x490]
    54c0: d63f0040     	blr	x2
    54c4: 911783ff     	add	sp, sp, #0x5e0
    54c8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    54cc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    54d0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    54d4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    54d8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    54dc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    54e0: d65f03c0     	ret
    54e4: 52801f41     	mov	w1, #0xfa               ; =250
    54e8: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    54ec: f9400042     	ldr	x2, [x2]
    54f0: f9424be0     	ldr	x0, [sp, #0x490]
    54f4: d63f0040     	blr	x2
    54f8: 911783ff     	add	sp, sp, #0x5e0
    54fc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5500: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5504: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5508: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    550c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5510: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5514: d65f03c0     	ret
    5518: 52801f21     	mov	w1, #0xf9               ; =249
    551c: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5520: f9400042     	ldr	x2, [x2]
    5524: f9424be0     	ldr	x0, [sp, #0x490]
    5528: d63f0040     	blr	x2
    552c: 911783ff     	add	sp, sp, #0x5e0
    5530: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5534: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5538: a8c163f7     	ldp	x23, x24, [sp], #0x10
    553c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5540: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5544: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5548: d65f03c0     	ret
    554c: 52801f01     	mov	w1, #0xf8               ; =248
    5550: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5554: f9400042     	ldr	x2, [x2]
    5558: f9424be0     	ldr	x0, [sp, #0x490]
    555c: d63f0040     	blr	x2
    5560: 911783ff     	add	sp, sp, #0x5e0
    5564: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5568: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    556c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5570: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5574: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5578: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    557c: d65f03c0     	ret
    5580: 52801ea1     	mov	w1, #0xf5               ; =245
    5584: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5588: f9400042     	ldr	x2, [x2]
    558c: f9424be0     	ldr	x0, [sp, #0x490]
    5590: d63f0040     	blr	x2
    5594: 911783ff     	add	sp, sp, #0x5e0
    5598: a8c153f3     	ldp	x19, x20, [sp], #0x10
    559c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    55a0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    55a4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    55a8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    55ac: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    55b0: d65f03c0     	ret
    55b4: 52801e81     	mov	w1, #0xf4               ; =244
    55b8: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    55bc: f9400042     	ldr	x2, [x2]
    55c0: f9424be0     	ldr	x0, [sp, #0x490]
    55c4: d63f0040     	blr	x2
    55c8: 911783ff     	add	sp, sp, #0x5e0
    55cc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    55d0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    55d4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    55d8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    55dc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    55e0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    55e4: d65f03c0     	ret
    55e8: 52801e61     	mov	w1, #0xf3               ; =243
    55ec: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    55f0: f9400042     	ldr	x2, [x2]
    55f4: f9424be0     	ldr	x0, [sp, #0x490]
    55f8: d63f0040     	blr	x2
    55fc: 911783ff     	add	sp, sp, #0x5e0
    5600: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5604: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5608: a8c163f7     	ldp	x23, x24, [sp], #0x10
    560c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5610: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5614: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5618: d65f03c0     	ret
    561c: 52801e01     	mov	w1, #0xf0               ; =240
    5620: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5624: f9400042     	ldr	x2, [x2]
    5628: f9424be0     	ldr	x0, [sp, #0x490]
    562c: d63f0040     	blr	x2
    5630: 911783ff     	add	sp, sp, #0x5e0
    5634: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5638: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    563c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5640: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5644: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5648: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    564c: d65f03c0     	ret
    5650: 52801de1     	mov	w1, #0xef               ; =239
    5654: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5658: f9400042     	ldr	x2, [x2]
    565c: f9424be0     	ldr	x0, [sp, #0x490]
    5660: d63f0040     	blr	x2
    5664: 911783ff     	add	sp, sp, #0x5e0
    5668: a8c153f3     	ldp	x19, x20, [sp], #0x10
    566c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5670: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5674: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5678: a8c173fb     	ldp	x27, x28, [sp], #0x10
    567c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5680: d65f03c0     	ret
    5684: 52801dc1     	mov	w1, #0xee               ; =238
    5688: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    568c: f9400042     	ldr	x2, [x2]
    5690: f9424be0     	ldr	x0, [sp, #0x490]
    5694: d63f0040     	blr	x2
    5698: 911783ff     	add	sp, sp, #0x5e0
    569c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    56a0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    56a4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    56a8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    56ac: a8c173fb     	ldp	x27, x28, [sp], #0x10
    56b0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    56b4: d65f03c0     	ret
    56b8: 52800981     	mov	w1, #0x4c               ; =76
    56bc: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    56c0: f9400042     	ldr	x2, [x2]
    56c4: f9424be0     	ldr	x0, [sp, #0x490]
    56c8: d63f0040     	blr	x2
    56cc: 911783ff     	add	sp, sp, #0x5e0
    56d0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    56d4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    56d8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    56dc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    56e0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    56e4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    56e8: d65f03c0     	ret
    56ec: 52800961     	mov	w1, #0x4b               ; =75
    56f0: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    56f4: f9400042     	ldr	x2, [x2]
    56f8: f9424be0     	ldr	x0, [sp, #0x490]
    56fc: d63f0040     	blr	x2
    5700: 911783ff     	add	sp, sp, #0x5e0
    5704: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5708: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    570c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5710: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5714: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5718: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    571c: d65f03c0     	ret
    5720: 52800941     	mov	w1, #0x4a               ; =74
    5724: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5728: f9400042     	ldr	x2, [x2]
    572c: f9424be0     	ldr	x0, [sp, #0x490]
    5730: d63f0040     	blr	x2
    5734: 911783ff     	add	sp, sp, #0x5e0
    5738: a8c153f3     	ldp	x19, x20, [sp], #0x10
    573c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5740: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5744: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5748: a8c173fb     	ldp	x27, x28, [sp], #0x10
    574c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5750: d65f03c0     	ret
    5754: 52800921     	mov	w1, #0x49               ; =73
    5758: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    575c: f9400042     	ldr	x2, [x2]
    5760: f9424be0     	ldr	x0, [sp, #0x490]
    5764: d63f0040     	blr	x2
    5768: 911783ff     	add	sp, sp, #0x5e0
    576c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5770: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5774: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5778: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    577c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5780: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5784: d65f03c0     	ret
    5788: 52800901     	mov	w1, #0x48               ; =72
    578c: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5790: f9400042     	ldr	x2, [x2]
    5794: f9424be0     	ldr	x0, [sp, #0x490]
    5798: d63f0040     	blr	x2
    579c: 911783ff     	add	sp, sp, #0x5e0
    57a0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    57a4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    57a8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    57ac: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    57b0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    57b4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    57b8: d65f03c0     	ret
    57bc: 528008e1     	mov	w1, #0x47               ; =71
    57c0: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    57c4: f9400042     	ldr	x2, [x2]
    57c8: f9424be0     	ldr	x0, [sp, #0x490]
    57cc: d63f0040     	blr	x2
    57d0: 911783ff     	add	sp, sp, #0x5e0
    57d4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    57d8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    57dc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    57e0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    57e4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    57e8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    57ec: d65f03c0     	ret
    57f0: 528008a1     	mov	w1, #0x45               ; =69
    57f4: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    57f8: f9400042     	ldr	x2, [x2]
    57fc: f9424be0     	ldr	x0, [sp, #0x490]
    5800: d63f0040     	blr	x2
    5804: 911783ff     	add	sp, sp, #0x5e0
    5808: a8c153f3     	ldp	x19, x20, [sp], #0x10
    580c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5810: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5814: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5818: a8c173fb     	ldp	x27, x28, [sp], #0x10
    581c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5820: d65f03c0     	ret
    5824: 52800861     	mov	w1, #0x43               ; =67
    5828: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    582c: f9400042     	ldr	x2, [x2]
    5830: f9424be0     	ldr	x0, [sp, #0x490]
    5834: d63f0040     	blr	x2
    5838: 911783ff     	add	sp, sp, #0x5e0
    583c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5840: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5844: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5848: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    584c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5850: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5854: d65f03c0     	ret
    5858: 52800821     	mov	w1, #0x41               ; =65
    585c: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5860: f9400042     	ldr	x2, [x2]
    5864: f9424be0     	ldr	x0, [sp, #0x490]
    5868: d63f0040     	blr	x2
    586c: 911783ff     	add	sp, sp, #0x5e0
    5870: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5874: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5878: a8c163f7     	ldp	x23, x24, [sp], #0x10
    587c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5880: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5884: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5888: d65f03c0     	ret
    588c: 528007e1     	mov	w1, #0x3f               ; =63
    5890: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5894: f9400042     	ldr	x2, [x2]
    5898: f9424be0     	ldr	x0, [sp, #0x490]
    589c: d63f0040     	blr	x2
    58a0: 911783ff     	add	sp, sp, #0x5e0
    58a4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    58a8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    58ac: a8c163f7     	ldp	x23, x24, [sp], #0x10
    58b0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    58b4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    58b8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    58bc: d65f03c0     	ret
    58c0: 52800741     	mov	w1, #0x3a               ; =58
    58c4: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    58c8: f9400042     	ldr	x2, [x2]
    58cc: f9424be0     	ldr	x0, [sp, #0x490]
    58d0: d63f0040     	blr	x2
    58d4: 911783ff     	add	sp, sp, #0x5e0
    58d8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    58dc: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    58e0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    58e4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    58e8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    58ec: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    58f0: d65f03c0     	ret
    58f4: 52800701     	mov	w1, #0x38               ; =56
    58f8: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    58fc: f9400042     	ldr	x2, [x2]
    5900: f9424be0     	ldr	x0, [sp, #0x490]
    5904: d63f0040     	blr	x2
    5908: 911783ff     	add	sp, sp, #0x5e0
    590c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5910: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5914: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5918: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    591c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5920: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5924: d65f03c0     	ret
    5928: 528006c1     	mov	w1, #0x36               ; =54
    592c: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5930: f9400042     	ldr	x2, [x2]
    5934: f9424be0     	ldr	x0, [sp, #0x490]
    5938: d63f0040     	blr	x2
    593c: 911783ff     	add	sp, sp, #0x5e0
    5940: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5944: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5948: a8c163f7     	ldp	x23, x24, [sp], #0x10
    594c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5950: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5954: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5958: d65f03c0     	ret
    595c: 52800681     	mov	w1, #0x34               ; =52
    5960: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5964: f9400042     	ldr	x2, [x2]
    5968: f9424be0     	ldr	x0, [sp, #0x490]
    596c: d63f0040     	blr	x2
    5970: 911783ff     	add	sp, sp, #0x5e0
    5974: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5978: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    597c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5980: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5984: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5988: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    598c: d65f03c0     	ret
    5990: 528005e1     	mov	w1, #0x2f               ; =47
    5994: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5998: f9400042     	ldr	x2, [x2]
    599c: f9424be0     	ldr	x0, [sp, #0x490]
    59a0: d63f0040     	blr	x2
    59a4: 911783ff     	add	sp, sp, #0x5e0
    59a8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    59ac: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    59b0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    59b4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    59b8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    59bc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    59c0: d65f03c0     	ret
    59c4: 528005a1     	mov	w1, #0x2d               ; =45
    59c8: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    59cc: f9400042     	ldr	x2, [x2]
    59d0: f9424be0     	ldr	x0, [sp, #0x490]
    59d4: d63f0040     	blr	x2
    59d8: 911783ff     	add	sp, sp, #0x5e0
    59dc: a8c153f3     	ldp	x19, x20, [sp], #0x10
    59e0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    59e4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    59e8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    59ec: a8c173fb     	ldp	x27, x28, [sp], #0x10
    59f0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    59f4: d65f03c0     	ret
    59f8: 52800561     	mov	w1, #0x2b               ; =43
    59fc: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5a00: f9400042     	ldr	x2, [x2]
    5a04: f9424be0     	ldr	x0, [sp, #0x490]
    5a08: d63f0040     	blr	x2
    5a0c: 911783ff     	add	sp, sp, #0x5e0
    5a10: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5a14: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5a18: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5a1c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5a20: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5a24: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5a28: d65f03c0     	ret
    5a2c: 52800521     	mov	w1, #0x29               ; =41
    5a30: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5a34: f9400042     	ldr	x2, [x2]
    5a38: f9424be0     	ldr	x0, [sp, #0x490]
    5a3c: d63f0040     	blr	x2
    5a40: 911783ff     	add	sp, sp, #0x5e0
    5a44: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5a48: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5a4c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5a50: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5a54: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5a58: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5a5c: d65f03c0     	ret
    5a60: 52800481     	mov	w1, #0x24               ; =36
    5a64: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5a68: f9400042     	ldr	x2, [x2]
    5a6c: f9424be0     	ldr	x0, [sp, #0x490]
    5a70: d63f0040     	blr	x2
    5a74: 911783ff     	add	sp, sp, #0x5e0
    5a78: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5a7c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5a80: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5a84: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5a88: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5a8c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5a90: d65f03c0     	ret
    5a94: 52800441     	mov	w1, #0x22               ; =34
    5a98: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5a9c: f9400042     	ldr	x2, [x2]
    5aa0: f9424be0     	ldr	x0, [sp, #0x490]
    5aa4: d63f0040     	blr	x2
    5aa8: 911783ff     	add	sp, sp, #0x5e0
    5aac: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5ab0: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5ab4: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5ab8: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5abc: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5ac0: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5ac4: d65f03c0     	ret
    5ac8: 52800401     	mov	w1, #0x20               ; =32
    5acc: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5ad0: f9400042     	ldr	x2, [x2]
    5ad4: f9424be0     	ldr	x0, [sp, #0x490]
    5ad8: d63f0040     	blr	x2
    5adc: 911783ff     	add	sp, sp, #0x5e0
    5ae0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5ae4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5ae8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5aec: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5af0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5af4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5af8: d65f03c0     	ret
    5afc: 528003c1     	mov	w1, #0x1e               ; =30
    5b00: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5b04: f9400042     	ldr	x2, [x2]
    5b08: f9424be0     	ldr	x0, [sp, #0x490]
    5b0c: d63f0040     	blr	x2
    5b10: 911783ff     	add	sp, sp, #0x5e0
    5b14: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5b18: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5b1c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5b20: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5b24: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5b28: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5b2c: d65f03c0     	ret
    5b30: 52800261     	mov	w1, #0x13               ; =19
    5b34: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5b38: f9400042     	ldr	x2, [x2]
    5b3c: f9424be0     	ldr	x0, [sp, #0x490]
    5b40: d63f0040     	blr	x2
    5b44: 911783ff     	add	sp, sp, #0x5e0
    5b48: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5b4c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5b50: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5b54: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5b58: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5b5c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5b60: d65f03c0     	ret
    5b64: 52800241     	mov	w1, #0x12               ; =18
    5b68: 90000002     	adrp	x2, 0x5000 <___pl_fn_0+0x5000>
    5b6c: f9400042     	ldr	x2, [x2]
    5b70: f9424be0     	ldr	x0, [sp, #0x490]
    5b74: d63f0040     	blr	x2
    5b78: 911783ff     	add	sp, sp, #0x5e0
    5b7c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5b80: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5b84: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5b88: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5b8c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5b90: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5b94: d65f03c0     	ret
    5b98: 52800221     	mov	w1, #0x11               ; =17
    5b9c: 90000003     	adrp	x3, 0x5000 <___pl_fn_0+0x5000>
    5ba0: f9400063     	ldr	x3, [x3]
    5ba4: f9424be0     	ldr	x0, [sp, #0x490]
    5ba8: d63f0060     	blr	x3
    5bac: 911783ff     	add	sp, sp, #0x5e0
    5bb0: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5bb4: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5bb8: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5bbc: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5bc0: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5bc4: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5bc8: d65f03c0     	ret
    5bcc: 52800201     	mov	w1, #0x10               ; =16
    5bd0: 90000004     	adrp	x4, 0x5000 <___pl_fn_0+0x5000>
    5bd4: f9400084     	ldr	x4, [x4]
    5bd8: f9424be0     	ldr	x0, [sp, #0x490]
    5bdc: d63f0080     	blr	x4
    5be0: 911783ff     	add	sp, sp, #0x5e0
    5be4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5be8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5bec: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5bf0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5bf4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5bf8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5bfc: d65f03c0     	ret
    5c00: 528001e1     	mov	w1, #0xf                ; =15
    5c04: 90000005     	adrp	x5, 0x5000 <___pl_fn_0+0x5000>
    5c08: f94000a5     	ldr	x5, [x5]
    5c0c: f9424be0     	ldr	x0, [sp, #0x490]
    5c10: d63f00a0     	blr	x5
    5c14: 911783ff     	add	sp, sp, #0x5e0
    5c18: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5c1c: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5c20: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5c24: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5c28: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5c2c: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5c30: d65f03c0     	ret
    5c34: 528001a1     	mov	w1, #0xd                ; =13
    5c38: 90000006     	adrp	x6, 0x5000 <___pl_fn_0+0x5000>
    5c3c: f94000c6     	ldr	x6, [x6]
    5c40: f9424be0     	ldr	x0, [sp, #0x490]
    5c44: d63f00c0     	blr	x6
    5c48: 911783ff     	add	sp, sp, #0x5e0
    5c4c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5c50: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5c54: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5c58: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5c5c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5c60: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5c64: d65f03c0     	ret
    5c68: 52800161     	mov	w1, #0xb                ; =11
    5c6c: 90000007     	adrp	x7, 0x5000 <___pl_fn_0+0x5000>
    5c70: f94000e7     	ldr	x7, [x7]
    5c74: f9424be0     	ldr	x0, [sp, #0x490]
    5c78: d63f00e0     	blr	x7
    5c7c: 911783ff     	add	sp, sp, #0x5e0
    5c80: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5c84: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5c88: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5c8c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5c90: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5c94: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5c98: d65f03c0     	ret
    5c9c: 52800121     	mov	w1, #0x9                ; =9
    5ca0: 90000008     	adrp	x8, 0x5000 <___pl_fn_0+0x5000>
    5ca4: f9400108     	ldr	x8, [x8]
    5ca8: f9424be0     	ldr	x0, [sp, #0x490]
    5cac: d63f0100     	blr	x8
    5cb0: 911783ff     	add	sp, sp, #0x5e0
    5cb4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5cb8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5cbc: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5cc0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5cc4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5cc8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5ccc: d65f03c0     	ret
    5cd0: 528000e1     	mov	w1, #0x7                ; =7
    5cd4: 90000009     	adrp	x9, 0x5000 <___pl_fn_0+0x5000>
    5cd8: f9400129     	ldr	x9, [x9]
    5cdc: f9424be0     	ldr	x0, [sp, #0x490]
    5ce0: d63f0120     	blr	x9
    5ce4: 911783ff     	add	sp, sp, #0x5e0
    5ce8: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5cec: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5cf0: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5cf4: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5cf8: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5cfc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5d00: d65f03c0     	ret
    5d04: 528000a1     	mov	w1, #0x5                ; =5
    5d08: 9000000a     	adrp	x10, 0x5000 <___pl_fn_0+0x5000>
    5d0c: f940014a     	ldr	x10, [x10]
    5d10: f9424be0     	ldr	x0, [sp, #0x490]
    5d14: d63f0140     	blr	x10
    5d18: 911783ff     	add	sp, sp, #0x5e0
    5d1c: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5d20: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5d24: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5d28: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5d2c: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5d30: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5d34: d65f03c0     	ret
    5d38: 52800061     	mov	w1, #0x3                ; =3
    5d3c: 9000000b     	adrp	x11, 0x5000 <___pl_fn_0+0x5000>
    5d40: f940016b     	ldr	x11, [x11]
    5d44: f9424be0     	ldr	x0, [sp, #0x490]
    5d48: d63f0160     	blr	x11
    5d4c: 911783ff     	add	sp, sp, #0x5e0
    5d50: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5d54: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5d58: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5d5c: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5d60: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5d64: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5d68: d65f03c0     	ret
    5d6c: 52800021     	mov	w1, #0x1                ; =1
    5d70: 9000000c     	adrp	x12, 0x5000 <___pl_fn_0+0x5000>
    5d74: f940018c     	ldr	x12, [x12]
    5d78: f9424be0     	ldr	x0, [sp, #0x490]
    5d7c: d63f0180     	blr	x12
    5d80: 911783ff     	add	sp, sp, #0x5e0
    5d84: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5d88: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5d8c: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5d90: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5d94: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5d98: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5d9c: d65f03c0     	ret
    5da0: 911783ff     	add	sp, sp, #0x5e0
    5da4: a8c153f3     	ldp	x19, x20, [sp], #0x10
    5da8: a8c15bf5     	ldp	x21, x22, [sp], #0x10
    5dac: a8c163f7     	ldp	x23, x24, [sp], #0x10
    5db0: a8c16bf9     	ldp	x25, x26, [sp], #0x10
    5db4: a8c173fb     	ldp	x27, x28, [sp], #0x10
    5db8: a8c17bfd     	ldp	x29, x30, [sp], #0x10
    5dbc: d65f03c0     	ret
    5dc0: 54442d18     	bc.hi	0x8e360 <___pl_fn_0+0x8e360>
    5dc4: 400921fb     	<unknown>
    5dc8: 54442d18     	bc.hi	0x8e368 <___pl_fn_0+0x8e368>
    5dcc: 402921fb     	<unknown>
    5dd0: c9be45de     	<unknown>
    5dd4: 4043bd3c     	<unknown>
    5dd8: 0a3d70a4     	bic	w4, w5, w29, lsl #28
    5ddc: 4076d3d7     	<unknown>
    5de0: 343cd92c     	cbz	w12, 0x7f904 <___pl_fn_0+0x7f904>
    5de4: 40135da0     	<unknown>
    5de8: c01fdb7c     	<unknown>
    5dec: bff290ab     	<unknown>
    5df0: 6c25ebf0     	stnp	d16, d26, [sp, #-0x1a8]
    5df4: bfba86f9     	<unknown>
    5df8: 9b93ccbc     	<unknown>
    5dfc: 3fe36706     	<unknown>
    5e00: f57d949b     	cblo	x27, #0x3b, 0x6090 <___pl_fn_0+0x6090>
    5e04: 40067ef2     	<unknown>
    5e08: 9a5a0715     	<unknown>
    5e0c: 3f99d2d7     	<unknown>
    5e10: 9a5a0715     	<unknown>
    5e14: bf99d2d7     	<unknown>
    5e18: d9ab33d8     	<unknown>
    5e1c: 3fa34c95     	<unknown>
    5e20: c332ca67     	<unknown>
    5e24: 4020afcd     	<unknown>
    5e28: 31de01b0     	<unknown>
    5e2c: 40107fcb     	<unknown>
    5e30: e1eb467c     	<unknown>
    5e34: bfd9d353     	<unknown>
    5e38: b8879442     	ldrsw	x2, [x2], #0x79
    5e3c: 3ff02c21     	<unknown>
    5e40: b8879442     	ldrsw	x2, [x2], #0x79
    5e44: bff02c21     	<unknown>
    5e48: bf1f8f13     	<unknown>
    5e4c: 3ffd35e9     	<unknown>
    5e50: 5f1123b4     	<unknown>
    5e54: 3f813c48     	<unknown>
    5e58: 0d07c637     	<unknown>
    5e5c: 3f871d49     	<unknown>
    5e60: cea7d9cf     	<unknown>
    5e64: 4029c9ea     	<unknown>
    5e68: d626667e     	<unknown>
    5e6c: c02e38e8     	<unknown>
    5e70: be257da0     	<unknown>
    5e74: bfcc9557     	<unknown>
    5e78: a9911bef     	stp	x15, x6, [sp, #0x110]!
    5e7c: 3ff1531c     	<unknown>
    5e80: 3e54bbc5     	<unknown>
    5e84: 3febcc7f     	<unknown>
    5e88: faf23e7c     	<unknown>
    5e8c: 3f862f6b     	<unknown>
    5e90: faf23e7c     	<unknown>
    5e94: bf862f6b     	<unknown>
    5e98: 9cf41eb3     	ldr	q19, 0xfffffffffffee26c <___pl_fn_0+0xfffffffffffee26c>
    5e9c: 3f5c3dd2     	<unknown>
    5ea0: a905572a     	stp	x10, x21, [x25, #0x50]
    5ea4: 402ec267     	<unknown>
    5ea8: 33c8a220     	<unknown>
    5eac: c039eb58     	<unknown>
    5eb0: 93abe540     	<unknown>
    5eb4: 3fc6f1f3     	<unknown>
    5eb8: 1659bc4a     	b	0xfffffffff9674fe0 <___pl_fn_0+0xfffffffff9674fe0>
    5ebc: 3fef54b6     	<unknown>
    5ec0: 31c4fba3     	<unknown>
    5ec4: 3fe307c6     	<unknown>
    5ec8: 587665f6     	ldr	x22, 0xf2b84 <___pl_fn_0+0xf2b84>
    5ecc: 3fa1cb88     	<unknown>
    5ed0: 587665f6     	ldr	x22, 0xf2b8c <___pl_fn_0+0xf2b8c>
    5ed4: bfa1cb88     	<unknown>
    5ed8: 531799ac     	<unknown>
    5edc: 3f60a8f3     	<unknown>
    5ee0: 26340000     	<unknown>
    5ee4: 430c6bf5     	<unknown>
    5ee8: 47ae147b     	<unknown>
    5eec: 3f847ae1     	<unknown>
