use cardano/address.{Address, VerificationKey}
use cardano/assets.{from_asset, from_lovelace}
use cardano/transaction.{Input, NoDatum, Output, Transaction, placeholder}
use mocktail.{
  add_input, add_output, complete, mock_pub_key_address, mock_pub_key_hash,
  mock_pub_key_output, mock_tx_hash, mock_utxo_ref, mocktail_tx, set_fee, tx_in,
  tx_out,
}

/// Learning objective
/// 1. Learn about the concept of balance transaction: input value = output value + fee
/// 2. Familiar with the structure of an input
/// 3. Familiar with the structure of an output
/// 4. Familiar with how to construct Cardano native value, lovelace and token
/// 5. Learn about mocktail placeholders: mock_pub_key_address, mock_pub_key_output
/// 6. Learn about the mocktail way of building input and output for Transaction
fn mock_spending_tx() -> Transaction {
  let input =
    Input {
      output_reference: mock_utxo_ref(0, 0),
      output: Output {
        address: Address {
          payment_credential: VerificationKey(mock_pub_key_hash(0)),
          stake_credential: None,
        },
        value: from_asset("", "", 10_000_000),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let output =
    Output {
      address: Address {
        payment_credential: VerificationKey(mock_pub_key_hash(1)),
        stake_credential: None,
      },
      value: from_lovelace(9_000_000),
      datum: NoDatum,
      reference_script: None,
    }
  Transaction {
    ..placeholder,
    inputs: [input],
    outputs: [output],
    fee: 1_000_000,
  }
}

test m103_l1_mocktail_mock_address() {
  let tx = mock_spending_tx()
  expect [input] = tx.inputs
  let address = input.output.address
  address == mock_pub_key_address(0, None)
}

test m103_l1_mocktail_mock_output() {
  let tx = mock_spending_tx()
  expect [input] = tx.inputs
  input.output == mock_pub_key_output(
    mock_pub_key_address(0, None),
    from_lovelace(10_000_000),
  )
}

test m103_l1_mocktail_mock_output_2() {
  let tx = mock_spending_tx()
  expect [output] = tx.outputs
  output == mock_pub_key_output(
    mock_pub_key_address(1, None),
    from_lovelace(9_000_000),
  )
}

// Mocktail tx builder

fn mock_spending_tx_mocktail_tx_builder() -> Transaction {
  mocktail_tx()
    |> tx_in(
        True,
        mock_tx_hash(0),
        0,
        from_lovelace(10_000_000),
        mock_pub_key_address(0, None),
      )
    |> tx_out(True, mock_pub_key_address(1, None), from_lovelace(9_000_000))
    |> complete()
    |> set_fee(True, 1_000_000)
}

test m103_l1_mocktail_tx_builder() {
  let tx = mock_spending_tx()
  let mocktail_tx = mock_spending_tx_mocktail_tx_builder()
  tx == mocktail_tx
}

fn mock_spending_tx_mocktail_tx() -> Transaction {
  let input =
    Input {
      output_reference: mock_utxo_ref(0, 0),
      output: mock_pub_key_output(
        mock_pub_key_address(0, None),
        from_lovelace(10_000_000),
      ),
    }
  let output =
    mock_pub_key_output(mock_pub_key_address(1, None), from_lovelace(9_000_000))
  placeholder
    |> add_input(True, input)
    |> add_output(True, output)
    |> set_fee(True, 1_000_000)
}

test m103_l1_mocktail_tx() {
  let tx = mock_spending_tx()
  let mocktail_tx = mock_spending_tx_mocktail_tx()
  tx == mocktail_tx
}
