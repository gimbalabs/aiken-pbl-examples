use aiken/collection/list
use cardano/address.{Address}
use cardano/assets.{from_lovelace}
use cardano/transaction.{Input, OutputReference, Transaction, find_input}
use cocktail.{inputs_at}
use mocktail.{
  complete, mock_pub_key_address, mock_pub_key_output, mock_script_address,
  mock_tx_hash, mock_utxo_ref, mocktail_tx, tx_in,
}

fn filter_address_for_inputs(
  inputs: List<Input>,
  address: Address,
) -> List<Input> {
  list.filter(inputs, fn(input) { input.output.address == address })
}

test md202_l1_test_vodka_util_inputs_at() {
  let address = mock_pub_key_address(0, None)
  let inputs =
    [
      Input {
        output_reference: mock_utxo_ref(0, 0),
        output: mock_pub_key_output(address, from_lovelace(1_000_000)),
      },
      Input {
        output_reference: mock_utxo_ref(0, 0),
        output: mock_pub_key_output(
          mock_pub_key_address(1, None),
          from_lovelace(1_000_000),
        ),
      },
    ]
  expect [target_input, _other_input] = inputs
  expect [only_filterd_input] = filter_address_for_inputs(inputs, address)
  expect [vodka_filtered_input] = inputs_at(inputs, address)
  only_filterd_input == target_input && vodka_filtered_input == target_input
}

/// Learning objecting
/// 1. Learn how to find the input current validating from context.transaction
/// 2. Learn how to filter address for the inputs, with Vodka util inputs_at
/// 3. Understand that in Cardano, seldomly there is only 1 input, i.e. script input + user input for covering some tx fee etc
validator check_only_script_input {
  spend(
    _datum: Option<Data>,
    _redeemer: Data,
    input: OutputReference,
    tx: Transaction,
  ) {
    // Prevent double-satisfaction attack
    let Transaction { inputs, .. } = tx
    expect Some(own_input) = find_input(inputs, input)
    when inputs_at(inputs, own_input.output.address) is {
      [_] -> True
      _ -> False
    }
  }

  else(_) {
    fail
  }
}

type TestCase {
  is_only_one_script_input: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase { is_only_one_script_input } = test_case

  mocktail_tx()
    |> tx_in(
        True,
        mock_tx_hash(0),
        0,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_in(
        !is_only_one_script_input,
        mock_tx_hash(0),
        1,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> complete()
}

test md202_l1_test_success() {
  let tx = mock_tx(TestCase { is_only_one_script_input: True })
  check_only_script_input.spend(None, Void, mock_utxo_ref(0, 0), tx)
}

test md202_l1_test_fail_with_multiple_script_inputs() {
  let tx = mock_tx(TestCase { is_only_one_script_input: False })
  !check_only_script_input.spend(None, Void, mock_utxo_ref(0, 0), tx)
}
