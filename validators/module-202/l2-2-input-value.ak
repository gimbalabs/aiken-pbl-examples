use aiken/collection/list
use cardano/address.{Address}
use cardano/assets.{
  AssetName, PolicyId, Value, add, from_asset, from_lovelace, merge, zero,
}
use cardano/transaction.{Input, OutputReference, Transaction, find_input}
use cocktail.{get_all_value_from, value_geq}
use mocktail.{
  complete, mock_policy_id, mock_pub_key_address, mock_pub_key_output,
  mock_script_address, mock_tx_hash, mock_utxo_ref, mocktail_tx, tx_in,
}

fn inputs_value_from_address(inputs: List<Input>, address: Address) -> Value {
  list.foldr(
    inputs,
    zero,
    fn(input, acc_value) {
      if input.output.address == address {
        merge(acc_value, input.output.value)
      } else {
        acc_value
      }
    },
  )
}

test md202_l2_test_vodka_util_inputs_at() {
  let address = mock_pub_key_address(0, None)
  let inputs =
    [
      Input {
        output_reference: mock_utxo_ref(0, 0),
        output: mock_pub_key_output(address, from_lovelace(1_000_000)),
      },
      Input {
        output_reference: mock_utxo_ref(0, 0),
        output: mock_pub_key_output(address, from_lovelace(2_000_000)),
      },
      Input {
        output_reference: mock_utxo_ref(0, 0),
        output: mock_pub_key_output(
          address,
          from_lovelace(2_000_000) |> add(mock_policy_id(0), "", 1),
        ),
      },
      Input {
        output_reference: mock_utxo_ref(0, 0),
        output: mock_pub_key_output(
          mock_pub_key_address(1, None),
          from_lovelace(100_000_000) |> add(mock_policy_id(0), "", 10),
        ),
      },
    ]
  let correct_value = from_lovelace(5_000_000) |> add(mock_policy_id(0), "", 1)
  let input_value_sum = inputs_value_from_address(inputs, address)
  let vodka_input_value_sum = get_all_value_from(inputs, address)
  input_value_sum == input_value_sum && vodka_input_value_sum == correct_value
}

pub type Datum {
  minimum_script_lovelace: Int,
  minimum_script_token: Int,
}

// On-chain, this datum will look like this:
// {
//   constructor: 0,
//   fields: [
//     { int: 5000000 },
//     { int: 1 },
//   ]
// }

/// Learning objecting
/// 1. Learn how to accumulate input value from an address with Vodka util get_all_value_from
/// 2. Learn how to compare value with Vodka util value_geq
/// 3. Understand that in Cardano, seldomly there is only 1 input, i.e. script input + user input for covering some tx fee etc
validator check_script_input_value(
  token_policy_id: PolicyId,
  token_name: AssetName,
) {
  spend(
    datum_opt: Option<Datum>,
    _redeemer: Data,
    input: OutputReference,
    tx: Transaction,
  ) {
    let Transaction { inputs, .. } = tx
    expect Some(datum) = datum_opt
    expect Some(own_input) = find_input(inputs, input)



    let own_address_value = get_all_value_from(inputs, own_input.output.address)
    let is_lovelace_value_enough =
      value_geq(own_address_value, from_lovelace(datum.minimum_script_lovelace))
    let is_token_value_enough =
      value_geq(
        own_address_value,
        from_asset(token_policy_id, token_name, datum.minimum_script_token),
      )

    is_lovelace_value_enough? && is_token_value_enough?
  }

  else(_) {
    fail
  }
}

type TestCase {
  is_minimum_script_lovelace_provided: Bool,
  is_minimum_script_token_provided: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase {
    is_minimum_script_lovelace_provided,
    is_minimum_script_token_provided,
  } = test_case

  mocktail_tx()
    |> tx_in(
        True,
        mock_tx_hash(0),
        0,
        from_lovelace(10_000_000),
        mock_script_address(0, None),
      )
    |> tx_in(
        is_minimum_script_lovelace_provided,
        mock_tx_hash(0),
        1,
        from_lovelace(10_000_000),
        mock_script_address(0, None),
      )
    |> tx_in(
        True,
        mock_tx_hash(0),
        2,
        from_asset(mock_policy_id(0), "", 1),
        mock_script_address(0, None),
      )
    |> tx_in(
        is_minimum_script_token_provided,
        mock_tx_hash(0),
        3,
        from_asset(mock_policy_id(0), "", 1),
        mock_script_address(0, None),
      )
    |> complete()
}

test md202_l2_2_test_success() {
  let datum =
    Some(Datum { minimum_script_lovelace: 15_000_000, minimum_script_token: 2 })
  let tx =
    mock_tx(
      TestCase {
        is_minimum_script_lovelace_provided: True,
        is_minimum_script_token_provided: True,
      },
    )

  check_script_input_value.spend(
    mock_policy_id(0),
    "",
    datum,
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test md202_l2_2_test_failed_with_insufficient_lovelace() {
  let datum =
    Some(Datum { minimum_script_lovelace: 15_000_000, minimum_script_token: 2 })
  let tx =
    mock_tx(
      TestCase {
        is_minimum_script_lovelace_provided: False,
        is_minimum_script_token_provided: True,
      },
    )

  !check_script_input_value.spend(
    mock_policy_id(0),
    "",
    datum,
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test md202_l2_2_test_failed_with_insufficient_token() {
  let datum =
    Some(Datum { minimum_script_lovelace: 15_000_000, minimum_script_token: 2 })
  let tx =
    mock_tx(
      TestCase {
        is_minimum_script_lovelace_provided: True,
        is_minimum_script_token_provided: False,
      },
    )

  !check_script_input_value.spend(
    mock_policy_id(0),
    "",
    datum,
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}
