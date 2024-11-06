fn get_maybe_something(
  is_something: Bool,
  content: ByteArray,
) -> Option<ByteArray> {
  if is_something {
    Some(content)
  } else {
    None
  }
}

test m101_p7_unsafe_type_converion() {
  expect Some(something): Option<ByteArray> =
    get_maybe_something(True, "hello world")
  something == "hello world"
}

test m101_p7_safe_type_conversion() {
  when get_maybe_something(False, "hello world") is {
    Some(something) -> {
      trace @"hello world"
      something == "hello world"
    }
    None -> {
      trace @"goodnight!"
      True
    }
  }
}
