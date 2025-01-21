// use aiken/collection/list
// use cardano/assets.{lovelace_of}
use cardano/assets.{from_lovelace}
use cardano/transaction.{OutputReference, Transaction}
use mocktail.{
  complete, mock_pub_key_address, mock_tx_hash, mock_utxo_ref, mocktail_tx,
  ref_tx_in,
}

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
    // We want to access the 2nd items of ref inputs
    // let ref_inputs = tx.reference_inputs
    // when list.at(ref_inputs, 1) is {
    //   Some(ref_input) -> {
    //     let value = ref_input.output.value
    //     let value_check = lovelace_of(value) >= 5_000_000
    //     value_check?
    //   }
    //   None -> False
    // }
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

  // Vodka tx builder apis does not preserve order for now (https://github.com/sidan-lab/vodka/issues/23)
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
        from_lovelace(5_000_000),
        mock_pub_key_address(0, None),
      )
    |> ref_tx_in(
        is_multiple_ref_inputs,
        mock_tx_hash(0),
        3,
        from_lovelace(3_000_000),
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
// test md201_l4_test_access_second_ref_inputs() {
//   let tx =
//     mock_tx(
//       TestCase { is_ref_input_present: True, is_multiple_ref_inputs: True },
//     )

//   check_reference_inputs.spend(None, Void, mock_utxo_ref(0, 0), tx)
// }

// test md201_l4_test_access_second_ref_inputs_2() {
//   let tx =
//     mock_tx(
//       TestCase { is_ref_input_present: False, is_multiple_ref_inputs: True },
//     )

//   !check_reference_inputs.spend(None, Void, mock_utxo_ref(0, 0), tx)
// }
