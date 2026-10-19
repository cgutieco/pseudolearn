
/var/folders/6n/90y4jf_96s70_n0spy5lzk380000gn/T/pseudolearn_pairs_28184/sieve/program.o:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000000000000 <___pl_fn_0>:
       0: a9bf7bfd     	stp	x29, x30, [sp, #-0x10]!
       4: 910003fd     	mov	x29, sp
       8: f81f0ffb     	str	x27, [sp, #-0x10]!
       c: a9bf53f3     	stp	x19, x20, [sp, #-0x10]!
      10: d100c3ff     	sub	sp, sp, #0x30
      14: b9401001     	ldr	w1, [x0, #0x10]
      18: 11000421     	add	w1, w1, #0x1
      1c: b9001001     	str	w1, [x0, #0x10]
      20: aa0003fb     	mov	x27, x0
      24: d2827120     	mov	x0, #0x1389             ; =5001
      28: 910003e3     	mov	x3, sp
      2c: f80003e0     	stur	x0, [sp]
      30: 52800001     	mov	w1, #0x0                ; =0
      34: 52802042     	mov	w2, #0x102              ; =258
      38: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      3c: f9400084     	ldr	x4, [x4]
      40: aa1b03e0     	mov	x0, x27
      44: d63f0080     	blr	x4
      48: 35001540     	cbnz	w0, 0x2f0 <___pl_fn_0+0x2f0>
      4c: aa1b03e0     	mov	x0, x27
      50: f9401802     	ldr	x2, [x0, #0x30]
      54: b9401813     	ldr	w19, [x0, #0x18]
      58: b9401c01     	ldr	w1, [x0, #0x1c]
      5c: 11000660     	add	w0, w19, #0x1
      60: 6b01001f     	cmp	w0, w1
      64: 540013c8     	b.hi	0x2dc <___pl_fn_0+0x2dc>
      68: aa1b03e1     	mov	x1, x27
      6c: f9401021     	ldr	x1, [x1, #0x20]
      70: b8335822     	str	w2, [x1, w19, uxtw #2]
      74: aa1b03e1     	mov	x1, x27
      78: aa0203f4     	mov	x20, x2
      7c: b9001820     	str	w0, [x1, #0x18]
      80: 52800041     	mov	w1, #0x2                ; =2
      84: 52800002     	mov	w2, #0x0                ; =0
      88: 90000003     	adrp	x3, 0x0 <___pl_fn_0>
      8c: f9400063     	ldr	x3, [x3]
      90: aa1b03e0     	mov	x0, x27
      94: d63f0060     	blr	x3
      98: 350012c0     	cbnz	w0, 0x2f0 <___pl_fn_0+0x2f0>
      9c: aa1b03e0     	mov	x0, x27
      a0: f9401800     	ldr	x0, [x0, #0x30]
      a4: aa1b03e2     	mov	x2, x27
      a8: b9001853     	str	w19, [x2, #0x18]
      ac: d2800001     	mov	x1, #0x0                ; =0
      b0: eb00003f     	cmp	x1, x0
      b4: 9a9fc7e2     	cset	x2, le
      b8: 72001c5f     	tst	w2, #0xff
      bc: 540008c1     	b.ne	0x1d4 <___pl_fn_0+0x1d4>
      c0: d2800041     	mov	x1, #0x2                ; =2
      c4: d2800002     	mov	x2, #0x0                ; =0
      c8: eb00003f     	cmp	x1, x0
      cc: 9a9fc7e3     	cset	x3, le
      d0: 72001c7f     	tst	w3, #0xff
      d4: 54000241     	b.ne	0x11c <___pl_fn_0+0x11c>
      d8: 528000a1     	mov	w1, #0x5                ; =5
      dc: 52802003     	mov	w3, #0x100              ; =256
      e0: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
      e4: f9400084     	ldr	x4, [x4]
      e8: aa1b03e0     	mov	x0, x27
      ec: d63f0080     	blr	x4
      f0: 35001000     	cbnz	w0, 0x2f0 <___pl_fn_0+0x2f0>
      f4: aa1b03e0     	mov	x0, x27
      f8: b9401000     	ldr	w0, [x0, #0x10]
      fc: 51000400     	sub	w0, w0, #0x1
     100: aa1b03e1     	mov	x1, x27
     104: b9001020     	str	w0, [x1, #0x10]
     108: 9100c3ff     	add	sp, sp, #0x30
     10c: a8c153f3     	ldp	x19, x20, [sp], #0x10
     110: f84107fb     	ldr	x27, [sp], #0x10
     114: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     118: d65f03c0     	ret
     11c: aa1403e3     	mov	x3, x20
     120: 340007e3     	cbz	w3, 0x21c <___pl_fn_0+0x21c>
     124: aa0303f4     	mov	x20, x3
     128: aa1b03e3     	mov	x3, x27
     12c: f9400063     	ldr	x3, [x3]
     130: aa1403e4     	mov	x4, x20
     134: 2a0403e4     	mov	w4, w4
     138: 8b040c63     	add	x3, x3, x4, lsl #3
     13c: f9400864     	ldr	x4, [x3, #0x10]
     140: eb04003f     	cmp	x1, x4
     144: 540006e2     	b.hs	0x220 <___pl_fn_0+0x220>
     148: 8b010c64     	add	x4, x3, x1, lsl #3
     14c: 3940a084     	ldrb	w4, [x4, #0x28]
     150: 53001c85     	uxtb	w5, w4
     154: 710008bf     	cmp	w5, #0x2
     158: 54000640     	b.eq	0x220 <___pl_fn_0+0x220>
     15c: 72001c9f     	tst	w4, #0xff
     160: 54000160     	b.eq	0x18c <___pl_fn_0+0x18c>
     164: b27ff7ea     	mov	x10, #0x7ffffffffffffffe ; =9223372036854775806
     168: eb0a005f     	cmp	x2, x10
     16c: 5400096c     	b.gt	0x298 <___pl_fn_0+0x298>
     170: ab010024     	adds	x4, x1, x1
     174: 9a9f77ed     	cset	x13, vs
     178: 72001dbf     	tst	w13, #0xff
     17c: 540008a1     	b.ne	0x290 <___pl_fn_0+0x290>
     180: eb00009f     	cmp	x4, x0
     184: 540000ed     	b.le	0x1a0 <___pl_fn_0+0x1a0>
     188: 91000442     	add	x2, x2, #0x1
     18c: b27ff7e3     	mov	x3, #0x7ffffffffffffffe ; =9223372036854775806
     190: eb03003f     	cmp	x1, x3
     194: 540005cc     	b.gt	0x24c <___pl_fn_0+0x24c>
     198: 91000421     	add	x1, x1, #0x1
     19c: 17ffffcb     	b	0xc8 <___pl_fn_0+0xc8>
     1a0: aa1403e5     	mov	x5, x20
     1a4: 34000585     	cbz	w5, 0x254 <___pl_fn_0+0x254>
     1a8: f9400865     	ldr	x5, [x3, #0x10]
     1ac: eb05009f     	cmp	x4, x5
     1b0: 54000522     	b.hs	0x254 <___pl_fn_0+0x254>
     1b4: d2800005     	mov	x5, #0x0                ; =0
     1b8: 8b040c66     	add	x6, x3, x4, lsl #3
     1bc: f90014c5     	str	x5, [x6, #0x28]
     1c0: ab010084     	adds	x4, x4, x1
     1c4: 9a9f77e5     	cset	x5, vs
     1c8: 72001cbf     	tst	w5, #0xff
     1cc: 540005e1     	b.ne	0x288 <___pl_fn_0+0x288>
     1d0: 17ffffec     	b	0x180 <___pl_fn_0+0x180>
     1d4: aa1403e2     	mov	x2, x20
     1d8: 34000642     	cbz	w2, 0x2a0 <___pl_fn_0+0x2a0>
     1dc: aa1b03e2     	mov	x2, x27
     1e0: f9400042     	ldr	x2, [x2]
     1e4: aa1403e4     	mov	x4, x20
     1e8: 2a0403e3     	mov	w3, w4
     1ec: 8b030c42     	add	x2, x2, x3, lsl #3
     1f0: f9400843     	ldr	x3, [x2, #0x10]
     1f4: eb03003f     	cmp	x1, x3
     1f8: 54000542     	b.hs	0x2a0 <___pl_fn_0+0x2a0>
     1fc: d2800023     	mov	x3, #0x1                ; =1
     200: 8b010c42     	add	x2, x2, x1, lsl #3
     204: f9001443     	str	x3, [x2, #0x28]
     208: b27ff7e2     	mov	x2, #0x7ffffffffffffffe ; =9223372036854775806
     20c: eb02003f     	cmp	x1, x2
     210: 5400062c     	b.gt	0x2d4 <___pl_fn_0+0x2d4>
     214: 91000421     	add	x1, x1, #0x1
     218: 17ffffa6     	b	0xb0 <___pl_fn_0+0xb0>
     21c: aa0303f4     	mov	x20, x3
     220: 910023e3     	add	x3, sp, #0x8
     224: f80083e1     	stur	x1, [sp, #0x8]
     228: 528000c1     	mov	w1, #0x6                ; =6
     22c: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     230: f9400084     	ldr	x4, [x4]
     234: aa1403e2     	mov	x2, x20
     238: aa1b03e0     	mov	x0, x27
     23c: d63f0080     	blr	x4
     240: 35000580     	cbnz	w0, 0x2f0 <___pl_fn_0+0x2f0>
     244: 528000e1     	mov	w1, #0x7                ; =7
     248: 14000026     	b	0x2e0 <___pl_fn_0+0x2e0>
     24c: 52800141     	mov	w1, #0xa                ; =10
     250: 14000024     	b	0x2e0 <___pl_fn_0+0x2e0>
     254: 910043e3     	add	x3, sp, #0x10
     258: f80103e4     	stur	x4, [sp, #0x10]
     25c: d2800000     	mov	x0, #0x0                ; =0
     260: f80183e0     	stur	x0, [sp, #0x18]
     264: 52800161     	mov	w1, #0xb                ; =11
     268: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     26c: f9400084     	ldr	x4, [x4]
     270: aa1403e2     	mov	x2, x20
     274: aa1b03e0     	mov	x0, x27
     278: d63f0080     	blr	x4
     27c: 350003a0     	cbnz	w0, 0x2f0 <___pl_fn_0+0x2f0>
     280: 52800181     	mov	w1, #0xc                ; =12
     284: 14000017     	b	0x2e0 <___pl_fn_0+0x2e0>
     288: 528001a1     	mov	w1, #0xd                ; =13
     28c: 14000015     	b	0x2e0 <___pl_fn_0+0x2e0>
     290: 52800121     	mov	w1, #0x9                ; =9
     294: 14000013     	b	0x2e0 <___pl_fn_0+0x2e0>
     298: 52800101     	mov	w1, #0x8                ; =8
     29c: 14000011     	b	0x2e0 <___pl_fn_0+0x2e0>
     2a0: 910083e3     	add	x3, sp, #0x20
     2a4: f80203e1     	stur	x1, [sp, #0x20]
     2a8: d2800020     	mov	x0, #0x1                ; =1
     2ac: f80283e0     	stur	x0, [sp, #0x28]
     2b0: 528001c1     	mov	w1, #0xe                ; =14
     2b4: 90000004     	adrp	x4, 0x0 <___pl_fn_0>
     2b8: f9400084     	ldr	x4, [x4]
     2bc: aa1403e2     	mov	x2, x20
     2c0: aa1b03e0     	mov	x0, x27
     2c4: d63f0080     	blr	x4
     2c8: 35000140     	cbnz	w0, 0x2f0 <___pl_fn_0+0x2f0>
     2cc: 528001e1     	mov	w1, #0xf                ; =15
     2d0: 14000004     	b	0x2e0 <___pl_fn_0+0x2e0>
     2d4: 52800201     	mov	w1, #0x10               ; =16
     2d8: 14000002     	b	0x2e0 <___pl_fn_0+0x2e0>
     2dc: 52800021     	mov	w1, #0x1                ; =1
     2e0: 90000002     	adrp	x2, 0x0 <___pl_fn_0>
     2e4: f9400042     	ldr	x2, [x2]
     2e8: aa1b03e0     	mov	x0, x27
     2ec: d63f0040     	blr	x2
     2f0: 9100c3ff     	add	sp, sp, #0x30
     2f4: a8c153f3     	ldp	x19, x20, [sp], #0x10
     2f8: f84107fb     	ldr	x27, [sp], #0x10
     2fc: a8c17bfd     	ldp	x29, x30, [sp], #0x10
     300: d65f03c0     	ret
