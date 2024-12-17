use cardano/assets.{from_lovelace}
use cardano/transaction.{InlineDatum, OutputReference, Transaction, find_input}
use cocktail.{inputs_at, outputs_at}
use mocktail.{
  complete, mock_script_address, mock_tx_hash, mock_utxo_ref, mocktail_tx, tx_in,
  tx_in_inline_datum, tx_out, tx_out_inline_datum,
}

pub type Datum {
  Initialize
  ActiveTransition { count: Int }
}

pub type Redeemer {
  IncrementCount
  CloseState
}

/// 1. Familiar in the state channel pattern of Cardano development
///    - find current utxo validating
///    - check only 1 input and output from same address with updated datum
/// 2. Can distinguish between: the smart contract updates the datum vs the script validate if datum is updated -> building early concept on cardano validator
/// 3. Understand that the script might not be performed as imagined - starter can start with ending datum
validator state_change {
  spend(
    datum_opt: Option<Datum>,
    redeemer: Redeemer,
    input: OutputReference,
    tx: Transaction,
  ) {
    let Transaction { inputs, outputs, .. } = tx
    expect Some(own_input) = find_input(inputs, input)
    let own_address = own_input.output.address

    when redeemer is {
      IncrementCount ->
        when
          (inputs_at(inputs, own_address), outputs_at(outputs, own_address))
        is {
          ([only_input], [only_output]) -> {
            expect InlineDatum(input_raw_datum) = only_input.output.datum
            expect InlineDatum(output_raw_datum) = only_output.datum
            expect input_datum: Datum = input_raw_datum
            expect output_datum: Datum = output_raw_datum
            let is_datum_updated =
              when input_datum is {
                Initialize -> output_datum == ActiveTransition { count: 1 }
                ActiveTransition { count } ->
                  output_datum == ActiveTransition { count: count + 1 }
              }
            is_datum_updated?
          }
          _ -> False
        }

      CloseState ->
        when datum_opt is {
          Some(ActiveTransition { count }) -> count >= 10
          _ -> False
        }
    }
  }

  else(_) {
    fail
  }
}

type IncrementTestCase {
  is_only_one_script_input: Bool,
  is_only_one_script_output: Bool,
  is_current_datum_initialize: Bool,
  is_datum_updated: Bool,
}

fn mock_increment_tx(test_case: IncrementTestCase) -> Transaction {
  let IncrementTestCase {
    is_only_one_script_input,
    is_only_one_script_output,
    is_current_datum_initialize,
    is_datum_updated,
  } = test_case
  let (input_datum, output_count) =
    if is_current_datum_initialize {
      (Initialize, 1)
    } else {
      (ActiveTransition { count: 1 }, 2)
    }
  let output_datum =
    if is_datum_updated {
      ActiveTransition { count: output_count }
    } else {
      ActiveTransition { count: output_count - 1 }
    }

  mocktail_tx()
    |> tx_in(
        True,
        mock_tx_hash(0),
        0,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_in_inline_datum(True, input_datum)
    |> tx_in(
        !is_only_one_script_input,
        mock_tx_hash(0),
        0,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_in_inline_datum(!is_only_one_script_input, input_datum)
    |> tx_out(True, mock_script_address(0, None), from_lovelace(1_000_000))
    |> tx_out_inline_datum(True, output_datum)
    |> tx_out(
        !is_only_one_script_output,
        mock_script_address(0, None),
        from_lovelace(1_000_000),
      )
    |> tx_out_inline_datum(!is_only_one_script_output, output_datum)
    |> complete()
}

test md202_l4_test_increment_success_at_initialization() {
  let tx =
    mock_increment_tx(
      IncrementTestCase {
        is_only_one_script_input: True,
        is_only_one_script_output: True,
        is_current_datum_initialize: True,
        is_datum_updated: True,
      },
    )
  state_change.spend(Some(Initialize), IncrementCount, mock_utxo_ref(0, 0), tx)
}

test md202_l4_test_increment_success_at_active_transition() {
  let tx =
    mock_increment_tx(
      IncrementTestCase {
        is_only_one_script_input: True,
        is_only_one_script_output: True,
        is_current_datum_initialize: False,
        is_datum_updated: True,
      },
    )
  state_change.spend(Some(Initialize), IncrementCount, mock_utxo_ref(0, 0), tx)
}

test md202_l4_test_increment_fail_with_wrong_datum_1() {
  let tx =
    mock_increment_tx(
      IncrementTestCase {
        is_only_one_script_input: True,
        is_only_one_script_output: True,
        is_current_datum_initialize: True,
        is_datum_updated: False,
      },
    )
  !state_change.spend(Some(Initialize), IncrementCount, mock_utxo_ref(0, 0), tx)
}

test md202_l4_test_increment_fail_with_wrong_datum_2() {
  let tx =
    mock_increment_tx(
      IncrementTestCase {
        is_only_one_script_input: True,
        is_only_one_script_output: True,
        is_current_datum_initialize: False,
        is_datum_updated: False,
      },
    )
  !state_change.spend(Some(Initialize), IncrementCount, mock_utxo_ref(0, 0), tx)
}

test md202_l4_test_increment_fail_with_multiple_script_inputs() {
  let tx =
    mock_increment_tx(
      IncrementTestCase {
        is_only_one_script_input: False,
        is_only_one_script_output: True,
        is_current_datum_initialize: True,
        is_datum_updated: True,
      },
    )
  !state_change.spend(Some(Initialize), IncrementCount, mock_utxo_ref(0, 0), tx)
}

test md202_l4_test_increment_fail_with_multiple_script_outputs() {
  let tx =
    mock_increment_tx(
      IncrementTestCase {
        is_only_one_script_input: True,
        is_only_one_script_output: False,
        is_current_datum_initialize: True,
        is_datum_updated: True,
      },
    )
  !state_change.spend(Some(Initialize), IncrementCount, mock_utxo_ref(0, 0), tx)
}

type CloseStateTestCase {
  is_count_sufficient: Bool,
}

fn mock_close_state_tx(test_case: CloseStateTestCase) -> Transaction {
  let CloseStateTestCase { is_count_sufficient } = test_case
  let count =
    if is_count_sufficient {
      11
    } else {
      10
    }

  mocktail_tx()
    |> tx_in(
        True,
        mock_tx_hash(0),
        0,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_in_inline_datum(True, ActiveTransition { count })
    |> complete()
}

test md202_l4_test_close_state_success() {
  let datum = Some(ActiveTransition { count: 10 })
  let tx = mock_close_state_tx(CloseStateTestCase { is_count_sufficient: True })
  state_change.spend(datum, CloseState, mock_utxo_ref(0, 0), tx)
}

test md202_l4_test_close_state_fail_with_insufficient_count() {
  let datum = Some(ActiveTransition { count: 9 })
  let tx =
    mock_close_state_tx(CloseStateTestCase { is_count_sufficient: False })
  !state_change.spend(datum, CloseState, mock_utxo_ref(0, 0), tx)
}
