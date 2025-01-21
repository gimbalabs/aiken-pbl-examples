test m101_p2_variable_tracing() {
  let check_a = False
  let check_b = True
  check_a? && check_b?
}

test m101_p2_trace_message() {
  trace @"is_even"
  10 % 2 == 0
}
