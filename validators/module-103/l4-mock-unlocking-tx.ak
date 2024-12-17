use aiken/cbor
use aiken/collection/dict.{Dict}
use aiken/crypto.{Blake2b_256, Hash}
use cardano/address.{Address, Script}
use cardano/assets.{from_lovelace}
use cardano/transaction.{
  InlineDatum, Input, Output, Redeemer, ScriptPurpose, Spend, Transaction,
  placeholder,
}
use mocktail.{
  add_input, complete, mock_script_address, mock_script_hash, mock_script_output,
  mock_tx_hash, mock_utxo_ref, mocktail_tx, tx_in, tx_in_inline_datum,
}

type MockDatum {
  MockDatum
}

type MockRedeemer {
  MockRedeemer
}

// In unit test, we seldom use this field
fn get_mock_datums() -> Dict<Hash<Blake2b_256, Data>, Data> {
  let datum: Data = MockDatum
  dict.from_pairs([Pair(cbor.serialise(MockDatum), datum)])
}

// In unit test, we seldom use this field
fn get_mock_redeemers() -> Pairs<ScriptPurpose, Redeemer> {
  let redeemer: Redeemer = MockRedeemer
  [Pair(Spend(mock_utxo_ref(0, 0)), redeemer)]
}

/// Learning objective
/// 1. Learn about the concept of balance transaction: input value = output value + fee
/// 2. Learn about locking transaction needs a datum, and the importance of that
/// 3. Learn about inline datum vs datum hash in conceptual level
/// 4. Learn about the mocktail way of building script output for Transaction
fn mock_unlocking_tx() -> Transaction {
  let input =
    Input {
      output_reference: mock_utxo_ref(0, 0),
      output: Output {
        address: Address {
          payment_credential: Script(mock_script_hash(0)),
          stake_credential: None,
        },
        value: from_lovelace(10_000_000),
        datum: InlineDatum(MockDatum),
        reference_script: None,
      },
    }

  // In unit test, we seldom use this field
  Transaction {
    ..placeholder,
    inputs: [input],
    redeemers: get_mock_redeemers(),
    datums: get_mock_datums(),
  }
}

// Mocktail tx builder

fn mock_locking_tx_mocktail_tx_builder() -> Transaction {
  mocktail_tx()
    |> tx_in(
        True,
        mock_tx_hash(0),
        0,
        from_lovelace(10_000_000),
        mock_script_address(0, None),
      )
    |> tx_in_inline_datum(True, MockDatum)
    |> complete()
}

test m103_l4_mocktail_tx_builder() {
  let tx_inputs = mock_unlocking_tx().inputs
  let mocktail_tx_inputs = mock_locking_tx_mocktail_tx_builder().inputs
  tx_inputs == mocktail_tx_inputs
}

fn mock_locking_tx_mocktail_tx() -> Transaction {
  let input =
    Input {
      output_reference: mock_utxo_ref(0, 0),
      output: mock_script_output(
        mock_script_address(0, None),
        from_lovelace(10_000_000),
        InlineDatum(MockDatum),
      ),
    }
  placeholder
    |> add_input(True, input)
}

test m103_l4_mocktail_tx() {
  let tx_inputs = mock_unlocking_tx().inputs
  let mocktail_tx_inputs = mock_locking_tx_mocktail_tx().inputs
  tx_inputs == mocktail_tx_inputs
}
