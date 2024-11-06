use cardano/assets.{from_lovelace}
use cardano/transaction.{OutputReference, Transaction}
use mocktail.{complete, mocktail_tx, ref_tx_in}
use mocktail/virgin_address.{mock_pub_key_address}
use mocktail/virgin_output_reference.{mock_tx_hash, mock_utxo_ref}

/// Learning objecting
/// 1. Accessing transaction information
/// 2. Distinguish control flow with when {} is {} and expect()
/// 3. Learn building reference input with Mocktail tx builder
/// 4. Learn about comprehensive test case with Mocktail tx builder pattern
validator check_reference_inputs {
  spend(
    _datum_opt: Option<Data>,
    _redeemer: Data,
    _input: OutputReference,
    tx: Transaction,
  ) {
    when tx.reference_inputs is {
      [_] -> True
      _ -> False
    }
  }

  else(_) {
    fail
  }
}

type TestCase {
  is_ref_input_present: Bool,
  is_multiple_ref_inputs: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase { is_ref_input_present, is_multiple_ref_inputs } = test_case
  mocktail_tx()
    |> ref_tx_in(
        is_ref_input_present,
        mock_tx_hash(0),
        1,
        from_lovelace(1_000_000),
        mock_pub_key_address(0, None),
      )
    |> ref_tx_in(
        is_multiple_ref_inputs,
        mock_tx_hash(0),
        2,
        from_lovelace(1_000_000),
        mock_pub_key_address(0, None),
      )
    |> ref_tx_in(
        is_multiple_ref_inputs,
        mock_tx_hash(0),
        3,
        from_lovelace(1_000_000),
        mock_pub_key_address(0, None),
      )
    |> complete()
}

test md201_l4_test_success() {
  let tx =
    mock_tx(
      TestCase { is_ref_input_present: True, is_multiple_ref_inputs: False },
    )

  check_reference_inputs.spend(None, Void, mock_utxo_ref(0, 0), tx)
}

test md201_l4_test_fail_with_no_ref_input() {
  let tx =
    mock_tx(
      TestCase { is_ref_input_present: False, is_multiple_ref_inputs: False },
    )

  !check_reference_inputs.spend(None, Void, mock_utxo_ref(0, 0), tx)
}

test md201_l4_test_fail_with_multiple_ref_input() {
  let tx =
    mock_tx(
      TestCase { is_ref_input_present: False, is_multiple_ref_inputs: True },
    )

  !check_reference_inputs.spend(None, Void, mock_utxo_ref(0, 0), tx)
}
