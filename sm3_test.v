module sm3

fn test_streaming() {
	{
		mut d := new()
		out := d.sum([])

		assert "1ab21d8355cfa17f8e61194831e81a8f22bec8c728fefb747ed035eb5082aa2b" == out.hex()
	}

	{
		mut d := new()
		d.write("abc".bytes())!
		out := d.sum([])

		assert "66c7f0f462eeedd9d1f2d46bdc10e4e24167c4875cf2f7a2297da02b8f4ba8e0" == out.hex()
	}

	{
		mut d := new()
		d.write("a".bytes())!
		d.write("b".bytes())!
		d.write("c".bytes())!
		out := d.sum([])

		assert "66c7f0f462eeedd9d1f2d46bdc10e4e24167c4875cf2f7a2297da02b8f4ba8e0" == out.hex()
	}

}

fn assert_equal_hash(expected_hex string, input string) {
	mut d := new()
	d.write(input.bytes()) or { panic(err) }
	out := d.sum([])

	assert expected_hex == out.hex()
}

fn test_single() {
	assert_equal_hash("1ab21d8355cfa17f8e61194831e81a8f22bec8c728fefb747ed035eb5082aa2b", "")
	assert_equal_hash("623476ac18f65a2909e43c7fec61b49c7e764a91a18ccb82f1917a29c86c5e88", "a")
	assert_equal_hash("66c7f0f462eeedd9d1f2d46bdc10e4e24167c4875cf2f7a2297da02b8f4ba8e0", "abc")
	assert_equal_hash("c522a942e89bd80d97dd666e7a5531b36188c9817149e9b258dfe51ece98ed77", "message digest")
	assert_equal_hash("b80fe97a4da24afc277564f66a359ef440462ad28dcc6d63adb24d5c20a61595", "abcdefghijklmnopqrstuvwxyz")
	assert_equal_hash("2971d10c8842b70c979e55063480c50bacffd90e98e2e60d2512ab8abfdfcec5", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
	assert_equal_hash("ad81805321f3e69d251235bf886a564844873b56dd7dde400f055b7dde39307a", "12345678901234567890123456789012345678901234567890123456789012345678901234567890")
}

fn test_sum() {
	out := sum("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".bytes())

	assert "2971d10c8842b70c979e55063480c50bacffd90e98e2e60d2512ab8abfdfcec5" == out.hex()
}

fn test_hexhash() {
	out := hexhash("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")

	assert "2971d10c8842b70c979e55063480c50bacffd90e98e2e60d2512ab8abfdfcec5" == out
}

fn test_hexhash2() {
	out := hexhash("V")

	assert "061e4f59bd1c9bcb58c0fe01b20ecde99b4fccee7fc495697dc811152d479345" == out
}

fn test_reset() {
	mut d := new()
	d.write("abc".bytes())!
	out := d.sum([])

	assert "66c7f0f462eeedd9d1f2d46bdc10e4e24167c4875cf2f7a2297da02b8f4ba8e0" == out.hex()

	d.reset()
	d.write("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".bytes())!
	out2 := d.sum([])

	assert "2971d10c8842b70c979e55063480c50bacffd90e98e2e60d2512ab8abfdfcec5" == out2.hex()
}
