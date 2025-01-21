use cardano/assets.{from_lovelace}
use cardano/transaction.{OutputReference, Transaction}
use mocktail.{
  complete, mock_pub_key_address, mock_script_address, mock_tx_hash,
  mock_utxo_ref, mocktail_tx, tx_in, tx_out,
}

/// Learning objecting
/// 1. Familar with accessing transaction information - inputs & outputs
/// 2. Can interpret the single input validation means in current transaction, there is only script input
/// 3. Familiar with the control flow pattern matching with number of items in a list
validator check_only_script_input {
  spend(
    _datum: Option<Data>,
    _redeemer: Data,
    _input: OutputReference,
    tx: Transaction,
  ) {
    let Transaction { inputs, outputs, .. } = tx
    when (inputs, outputs) is {
      // Only true when there is only 1 input & 1 output
      ([_], [_]) -> True
      _ -> False
    }
  }

  else(_) {
    fail
  }
}

type TestCase {
  is_input_present: Bool,
  is_single_input: Bool,
  is_output_present: Bool,
  is_single_output: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase {
    is_input_present,
    is_single_input,
    is_output_present,
    is_single_output,
  } = test_case

  mocktail_tx()
    |> tx_in(
        is_input_present,
        mock_tx_hash(0),
        0,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_in(
        !is_single_input,
        mock_tx_hash(0),
        1,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_in(
        !is_single_input,
        mock_tx_hash(0),
        2,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_out(
        is_output_present,
        mock_pub_key_address(0, None),
        from_lovelace(1_000_000),
      )
    |> tx_out(
        !is_single_output,
        mock_pub_key_address(0, None),
        from_lovelace(1_000_000),
      )
    |> tx_out(
        !is_single_output,
        mock_pub_key_address(0, None),
        from_lovelace(1_000_000),
      )
    |> complete()
}

test md201_l7_test_success() {
  let tx =
    mock_tx(
      TestCase {
        is_input_present: True,
        is_single_input: True,
        is_output_present: True,
        is_single_output: True,
      },
    )

  check_only_script_input.spend(None, Void, mock_utxo_ref(0, 0), tx)
}

test md201_l7_test_fail_with_no_input() {
  let tx =
    mock_tx(
      TestCase {
        is_input_present: False,
        is_single_input: True,
        is_output_present: True,
        is_single_output: True,
      },
    )

  !check_only_script_input.spend(None, Void, mock_utxo_ref(0, 0), tx)
}

test md201_l7_test_fail_with_multiple_input() {
  let tx =
    mock_tx(
      TestCase {
        is_input_present: True,
        is_single_input: False,
        is_output_present: True,
        is_single_output: True,
      },
    )

  !check_only_script_input.spend(None, Void, mock_utxo_ref(0, 0), tx)
}

test md201_l7_test_fail_with_no_output() {
  let tx =
    mock_tx(
      TestCase {
        is_input_present: True,
        is_single_input: True,
        is_output_present: False,
        is_single_output: True,
      },
    )

  !check_only_script_input.spend(None, Void, mock_utxo_ref(0, 0), tx)
}

test md201_l7_test_fail_with_multiple_output() {
  let tx =
    mock_tx(
      TestCase {
        is_input_present: True,
        is_single_input: True,
        is_output_present: True,
        is_single_output: False,
      },
    )

  !check_only_script_input.spend(None, Void, mock_utxo_ref(0, 0), tx)
}
