use aiken/collection/list
use cardano/assets.{PolicyId, from_lovelace}
use cardano/transaction.{Input, OutputReference, Transaction}
use mocktail.{
  complete, mock_policy_id, mock_pub_key_address, mock_tx_hash, mock_utxo_ref,
  mocktail_tx, tx_in,
}

/// Learning objecting
/// 1. Parameterizing script
/// 2. Familiar with property accessing for a type from transaction
/// 3. Familiar with control flow
validator always_succeed(utxo: OutputReference) {
  mint(_redeemer: Data, _policy_id: PolicyId, tx: Transaction) {
    when list.find(tx.inputs, fn(input) { input.output_reference == utxo }) is {
      Some(_) -> True
      _ -> False
    }
  }

  else(_) {
    fail
  }
}

test md201_l3_test_one_time_minting_policy() {
  let tx =
    mocktail_tx()
      |> tx_in(
          True,
          mock_tx_hash(2),
          0,
          from_lovelace(1_000_000),
          mock_pub_key_address(0, None),
        )
      |> complete()

  always_succeed.mint(mock_utxo_ref(2, 0), Void, mock_policy_id(0), tx)
}
