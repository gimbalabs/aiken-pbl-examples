fn get_bytearray_data() -> Data {
  // This is safe conversion by "let" keyworld
  let data: Data = "hello world"
  data
}

test m101_p8_unsafe_conversion() {
  // let data = get_bytearray_data()
  // This is unsafe conversion by "expect" keyword
  expect data: ByteArray = get_bytearray_data()
  data == "hello world"
}
