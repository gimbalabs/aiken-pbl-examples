type Dog {
  species: ByteArray,
  age: Int,
}

type Cat {
  species: ByteArray,
  age: Int,
}

test m101_p1_bool_pet() {
  trace @"a dog and a cat are different species"
  let dog = Dog { species: "canis", age: 1}
  let cat = Cat { species: "felis", age: 2}
  let result = (dog.species != cat.species)
  result
}

test m101_p1_bool_pet_2() {
  trace @"a dog and a cat with the same age"
  let dog = Dog { species: "canis", age: 2 }
  let cat = Cat { species: "felis", age: 2 }
  let result = (dog.age == cat.age)
  result
}

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
