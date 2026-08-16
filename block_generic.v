module sm3

import math.bits
import encoding.binary

const sbox = [
	u32(0x79cc4519), 0xf3988a32, 0xe7311465, 0xce6228cb, 0x9cc45197, 0x3988a32f, 0x7311465e, 0xe6228cbc,
	0xcc451979, 0x988a32f3, 0x311465e7, 0x6228cbce, 0xc451979c, 0x88a32f39, 0x11465e73, 0x228cbce6,
	0x9d8a7a87, 0x3b14f50f, 0x7629ea1e, 0xec53d43c, 0xd8a7a879, 0xb14f50f3, 0x629ea1e7, 0xc53d43ce,
	0x8a7a879d, 0x14f50f3b, 0x29ea1e76, 0x53d43cec, 0xa7a879d8, 0x4f50f3b1, 0x9ea1e762, 0x3d43cec5,
	0x7a879d8a, 0xf50f3b14, 0xea1e7629, 0xd43cec53, 0xa879d8a7, 0x50f3b14f, 0xa1e7629e, 0x43cec53d,
	0x879d8a7a, 0xf3b14f5,  0x1e7629ea, 0x3cec53d4, 0x79d8a7a8, 0xf3b14f50, 0xe7629ea1, 0xcec53d43,
	0x9d8a7a87, 0x3b14f50f, 0x7629ea1e, 0xec53d43c, 0xd8a7a879, 0xb14f50f3, 0x629ea1e7, 0xc53d43ce,
	0x8a7a879d, 0x14f50f3b, 0x29ea1e76, 0x53d43cec, 0xa7a879d8, 0x4f50f3b1, 0x9ea1e762, 0x3d43cec5,
]

fn block_generic(mut d Digest, b []u8) {
	mut a := []u32{len: 8}
	mut w := []u32{len: 68}

	mut ss1 := u32(0)
	mut ss2 := u32(0)
	mut tt1 := u32(0)
	mut tt2 := u32(0)

	mut i := 0
	for i < 4 {
		w[i] = binary.big_endian_u32(b[i * 4 .. i * 4 + 4])
		i += 1
	}

	i = 0
	for i < 8 {
		a[i] = d.s[i]
		i += 1
	}

	i = 0
	for i < 12 {
		w[i + 4] = binary.big_endian_u32(b[(i + 4) * 4 .. (i + 4) * 4 + 4])

		tt2 = rotate_left_32(a[0], 12)
		ss1 = rotate_left_32(tt2 + a[4] + sbox[i], 7)
		ss2 = ss1 ^ tt2
		tt1 = (a[0] ^ a[1] ^ a[2]) + a[3] + ss2 + (w[i] ^ w[i + 4])
		tt2 = (a[4] ^ a[5] ^ a[6]) + a[7] + ss1 + w[i]

		a[3] = a[2]
		a[2] = rotate_left_32(a[1], 9)
		a[1] = a[0]
		a[0] = tt1
		a[7] = a[6]
		a[6] = rotate_left_32(a[5], 19)
		a[5] = a[4]
		a[4] = p0(tt2)

		i += 1
	}

	i = 12
	for i < 16 {
		w[i + 4] = p1(w[i - 12] ^ w[i - 5] ^ rotate_left_32(w[i + 1], 15)) ^ rotate_left_32(w[i - 9], 7) ^ w[i - 2]
		tt2 = rotate_left_32(a[0], 12)
		ss1 = rotate_left_32(tt2 + a[4] + sbox[i], 7)
		ss2 = ss1 ^ tt2
		tt1 = (a[0] ^ a[1] ^ a[2]) + a[3] + ss2 + (w[i] ^ w[i + 4])
		tt2 = (a[4] ^ a[5] ^ a[6]) + a[7] + ss1 + w[i]

		a[3] = a[2]
		a[2] = rotate_left_32(a[1], 9)
		a[1] = a[0]
		a[0] = tt1
		a[7] = a[6]
		a[6] = rotate_left_32(a[5], 19)
		a[5] = a[4]
		a[4] = p0(tt2)

		i += 1
	}

	i = 16
	for i < 64 {
		w[i + 4] = p1(w[i - 12] ^ w[i - 5] ^ rotate_left_32(w[i + 1], 15)) ^ rotate_left_32(w[i - 9], 7) ^ w[i - 2]
		tt2 = rotate_left_32(a[0], 12)
		ss1 = rotate_left_32(tt2 + a[4] + sbox[i], 7)
		ss2 = ss1 ^ tt2
		tt1 = ff(a[0], a[1], a[2]) + a[3] + ss2 + (w[i] ^ w[i + 4])
		tt2 = gg(a[4], a[5], a[6]) + a[7] + ss1 + w[i]

		a[3] = a[2]
		a[2] = rotate_left_32(a[1], 9)
		a[1] = a[0]
		a[0] = tt1
		a[7] = a[6]
		a[6] = rotate_left_32(a[5], 19)
		a[5] = a[4]
		a[4] = p0(tt2)

		i += 1
	}

	i = 0
	for i < 8 {
		d.s[i] ^= a[i]
		i += 1
	}
}

fn rotate_left_32(x u32, k int) u32 {
	return bits.rotate_left_32(x, k)
}

fn p0(x u32) u32 {
	return x ^ rotate_left_32(x, 9) ^ rotate_left_32(x, 17)
}

fn p1(x u32) u32 {
	return x ^ rotate_left_32(x, 15) ^ rotate_left_32(x, 23)
}

fn ff(x u32, y u32, z u32) u32 {
	return (x & y) | (x & z) | (y & z)
}

fn gg(x u32, y u32, z u32) u32 {
	return ((y ^ z) & x) ^ z
}