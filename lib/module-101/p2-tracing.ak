test m101_p2_variable_tracing() {
  trace @"check if both are true"
  let is_it_true = True
  let is_this_true = True
  is_it_true? && is_this_true?
}

test m101_p2_trace_message() {
  trace @"is_odd_number"
  10 % 3 == 1
}
