test m101_p2_variable_tracing() {
  let is_this_true = False
  let is_this_false = True
  is_this_true? && is_this_false?
}

test m101_p2_trace_message() {
  trace @"is_even"
  10 % 2 == 0
}
