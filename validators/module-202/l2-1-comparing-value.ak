use cardano/assets.{add, from_lovelace}
use cocktail.{value_geq}
use mocktail.{mock_policy_id}

test md202_l2_1_test_value_geq_1() {
  let value1 = from_lovelace(2_000_000)
  let value2 = from_lovelace(1_000_000)
  value_geq(value1, value2)
}

test md202_l2_1_test_value_geq_2() {
  let value1 = from_lovelace(2_000_000)
  let value2 = from_lovelace(2_000_000)
  value_geq(value1, value2)
}

test md202_l2_1_test_value_geq_3() {
  let value1 = from_lovelace(2_000_000) |> add(mock_policy_id(0), "", 1)
  let value2 = from_lovelace(2_000_000)
  value_geq(value1, value2)
}

test md202_l2_1_test_value_geq_4() {
  let value1 = from_lovelace(2_000_000) |> add(mock_policy_id(0), "", 1)
  let value2 = from_lovelace(2_000_000) |> add(mock_policy_id(0), "", 1)
  value_geq(value1, value2)
}

test md202_l2_1_test_value_geq_5() {
  let value1 = from_lovelace(2_000_000) |> add(mock_policy_id(0), "", 1)
  let value2 = from_lovelace(3_000_000) |> add(mock_policy_id(0), "", 1)
  !value_geq(value1, value2)
}

test md202_l2_1_test_value_geq_6() {
  let value1 = from_lovelace(2_000_000) |> add(mock_policy_id(0), "", 1)
  let value2 = from_lovelace(2_000_000) |> add(mock_policy_id(1), "", 1)
  !value_geq(value1, value2)
}
