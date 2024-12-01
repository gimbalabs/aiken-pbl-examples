test m101_p1_bool_true_type() {
  True
}

test m101_p1_bool_false_type() {
  !False
}

test m101_p1_bool_equal_operator() {
  True == True
}

test m101_p1_bool_not_equal_operator() {
  True != False
}

test m101_p1_bool_and_operator() {
  let result = and {
      True == True,
      False == False,
    }
  result
}

test m101_p1_bool_and_operator_short_form() {
  let result = True == True && False == False
  result
}

test m101_p1_bool_or_operator() {
  let result = or {
      True == True,
      False == True,
    }
  result
}

test m101_p1_bool_or_operator_short_form() {
  let result = True == True || False == True
  result
}

test m101_p1_bool_nested_operator() {
  let result = and {
      True,
      False,
      or {
        True,
        False,
      },
    }
  !result
}
