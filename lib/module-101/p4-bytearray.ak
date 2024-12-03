test m101_p4_legit_byte_array() {
  #[10, 255] == #[10, 255]
}

// test m101_p4_not_legit_byte_array() {
//   #[10, 256] == #[10, 256]
// }

test m101_p4_byte_array_hex_syntax_rule() {
  #[0xff, 0x42] == #[255, 66]
  // 4 * 16 + 2 == 66
}

test m101_p4_byte_array_byte_string() {
  let byte_string = "foo"
  let byte_array_hex_literal = #[0x66, 0x6f, 0x6f]
  let raw_byte_array = #[102, 111, 111]
  byte_string == raw_byte_array && byte_array_hex_literal == raw_byte_array
}

test m101_p4_byte_array_hex_code() {
  let byte_array_hex_string = #"666f6f"
  let byte_array_hex_literal = #[0x66, 0x6f, 0x6f]
  let byte_string = "foo"
  let raw_byte_array = #[102, 111, 111]
  raw_byte_array == byte_array_hex_string && raw_byte_array == byte_array_hex_literal && raw_byte_array == byte_string
}

test m101_p4_byte_array_hex_string_vs_code() {
  let byte_string = "666f6f"
  let byte_array_hex_literal = #[0x36, 0x36, 0x36, 0x66, 0x36, 0x66]
  let raw_byte_array = #[54, 54, 54, 102, 54, 102]
  (raw_byte_array == byte_string)? && (raw_byte_array == byte_array_hex_literal)?
}
