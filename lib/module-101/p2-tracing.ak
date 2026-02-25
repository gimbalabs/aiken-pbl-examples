test m101_p2_variable_tracing() {
  let check_a = True
  let check_b = False
  check_b? || check_a?
}

test m101_p2_trace_message() {
  trace @"is_even_number"
  10 % 2 == 0
}
