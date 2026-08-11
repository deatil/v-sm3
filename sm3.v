module sm3

import encoding.binary

// The size of an SM3 checksum in bytes.
pub const size = 32
// The blocksize of SM3 in bytes.
pub const block_size = 64

const init0 = u32(0x7380166f)
const init1 = u32(0x4914b2b9)
const init2 = u32(0x172442d7)
const init3 = u32(0xda8a0600)
const init4 = u32(0xa96f30bc)
const init5 = u32(0x163138aa)
const init6 = u32(0xe38dee4d)
const init7 = u32(0xb0fb0e4e)

// Digest represents the partial evaluation of a checksum.
struct Digest {
mut:
	s   []u32
	x   []u8
	nx  int
	len u64
}

// free the resources taken by the Digest `d`
@[unsafe]
pub fn (mut d Digest) free() {
	$if prealloc {
		return
	}
	unsafe { d.x.free() }
}

fn (mut d Digest) init() {
	d.s = []u32{len: (8)}
	d.x = []u8{len: block_size}
	d.reset()
}

// reset the state of the Digest `d`
pub fn (mut d Digest) reset() {
	d.s[0] = u32(init0)
	d.s[1] = u32(init1)
	d.s[2] = u32(init2)
	d.s[3] = u32(init3)
	d.s[4] = u32(init4)
	d.s[5] = u32(init5)
	d.s[6] = u32(init6)
	d.s[7] = u32(init7)
	d.nx = 0
	d.len = 0
}

fn (d &Digest) clone() &Digest {
	return &Digest{
		...d
		s: d.s.clone()
		x: d.x.clone()
	}
}

// new returns a new Digest (implementing hash.Hash) computing the SM3 checksum.
pub fn new() &Digest {
	mut d := &Digest{}
	d.init()
	return d
}

// write writes the contents of `p_` to the internal hash representation.
pub fn (mut d Digest) write(b []u8) !int {
	unsafe {
		nn := b.len
		
		off := 0

        // Partial buffer exists from previous update. Copy into buffer then hash.
        if d.nx != 0 && d.nx + b.len >= 64 {
            off += 64 - d.nx
			copy(mut d.x[d.nx..], b[0..off])

			block(mut d, d.x)
            d.nx = 0
        }

        // Full middle blocks.
        for off + 64 <= b.len {
			block(mut d, b[off..off+64])

			off += 64
        }

        // Copy any remainder for next pass.
        b_slice := b[off..]
		copy(mut d.x[d.nx..d.nx+b_slice.len], b_slice)
        d.nx += b_slice.len

        // SM3 uses the bottom 16-bits for length padding
        d.len += u64(nn)

		return nn
	}
}

// sum returns the sm3 sum of the bytes in `b_in`.
pub fn (d &Digest) sum(b_in []u8) []u8 {
	// Make a copy of d so that caller can keep writing and summing.
	mut d0 := d.clone()
	hash := d0.checksum()
	mut b_out := b_in.clone()
	b_out << hash
	return b_out
}

// checksum returns the byte checksum of the `Digest`,
fn (mut d Digest) checksum() []u8 {
    d.nx &= 0x3f
    d.x[d.nx] = 0x80

	zeros := []u8{len: block_size}
	copy(mut d.x[d.nx + 1..], zeros)

    if block_size - d.nx < 9 {
		block(mut d, d.x)
        copy(mut d.x[0..], zeros)
    }

	bcount := d.len / block_size

    binary.big_endian_put_u32(mut d.x[56..], u32(bcount >> 23))
    binary.big_endian_put_u32(mut d.x[60..], u32((bcount << 9) + (u32(d.nx) << 3)))

	block(mut d, d.x)

	mut digest := []u8{len: size}
    for i := 0; i < 8; i++ {
        binary.big_endian_put_u32(mut digest[i*4..], d.s[i])
    }

    return digest
}

// size returns the size of the checksum in bytes.
pub fn (d &Digest) size() int {
	return size
}

// block_size returns the block size of the checksum in bytes.
pub fn (d &Digest) block_size() int {
	return block_size
}

fn block(mut dig Digest, p []u8) {
	// For now just use block_generic until we have specific
	// architecture optimized versions
	block_generic(mut dig, p)
}

// sum returns the SM3 checksum of the data.
pub fn sum(data []u8) []u8 {
	mut d := new()
	d.write(data) or { panic(err) }
	return d.checksum()
}

// hexhash returns a hexadecimal SM3 hash sum `string` of `s`.
// Example: assert sm3.hexhash('V') == '061e4f59bd1c9bcb58c0fe01b20ecde99b4fccee7fc495697dc811152d479345'
pub fn hexhash(s string) string {
	return sum(s.bytes()).hex()
}

