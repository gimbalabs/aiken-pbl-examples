use cardano/address.{Address, Script}
use cardano/assets.{from_lovelace}
use cardano/transaction.{InlineDatum, Output, Transaction, placeholder}
use mocktail.{
  add_output, complete, mock_script_address, mock_script_hash,
  mock_script_output, mocktail_tx, tx_out, tx_out_inline_datum,
}

type MockDatum {
  MockDatum
}

/// Learning objective
/// 1. Learn about the concept of balance transaction: input value = output value + fee
/// 2. Learn about locking transaction needs a datum, and the importance of that
/// 3. Learn about inline datum vs datum hash in conceptual level
/// 4. Learn about mocktail placeholder: mock_script_hash, mock_script_address, mock_script_output
/// 5. Learn about the mocktail way of building script output for Transaction
fn mock_locking_tx() -> Transaction {
  let output =
    Output {
      address: Address {
        payment_credential: Script(mock_script_hash(0)),
        stake_credential: None,
      },
      value: from_lovelace(10_000_000),
      datum: InlineDatum(MockDatum),
      reference_script: None,
    }
  Transaction { ..placeholder, outputs: [output] }
}

test m103_l3_mocktail_mock_address() {
  let tx = mock_locking_tx()
  expect [output] = tx.outputs
  output.address == mock_script_address(0, None)
}

// Mocktail tx builder

fn mock_locking_tx_mocktail_tx_builder() -> Transaction {
  mocktail_tx()
    |> tx_out(True, mock_script_address(0, None), from_lovelace(10_000_000))
    |> tx_out_inline_datum(True, MockDatum)
    |> complete()
}

test m103_l3_mocktail_tx_builder() {
  let tx = mock_locking_tx()
  let mocktail_tx = mock_locking_tx_mocktail_tx_builder()
  tx == mocktail_tx
}

fn mock_locking_tx_mocktail_tx() -> Transaction {
  let output =
    mock_script_output(
      mock_script_address(0, None),
      from_lovelace(10_000_000),
      InlineDatum(MockDatum),
    )
  placeholder
    |> add_output(True, output)
}

test m103_l3_mocktail_tx() {
  let tx = mock_locking_tx()
  let mocktail_tx = mock_locking_tx_mocktail_tx()
  tx == mocktail_tx
}
