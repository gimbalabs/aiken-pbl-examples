use cardano/assets.{from_asset}
use cardano/transaction.{Transaction, placeholder}
use mocktail.{add_mint, complete, mint, mock_policy_id, mocktail_tx}

fn mock_token_name() {
  "test token name"
}

/// Learning objective
/// 1. Understand that for testing purpose, we dont have to do balance tx
/// 2. Learn about mocktail placeholder: mock_policy_id
/// 3. Understand what's the difference between different key hex utils, e.g. mock_policy_id vs mock_pub_key_hash
/// 4. Learn about the mocktail way of building mint for Transaction
fn mock_minting_tx() -> Transaction {
  Transaction {
    ..placeholder,
    mint: from_asset(mock_policy_id(0), mock_token_name(), 1),
  }
}

test m103_l2_mock_minting_tx() {
  let tx = mock_minting_tx()
  tx.mint == from_asset(mock_policy_id(0), mock_token_name(), 1)
}

// Mocktail tx builder

fn mock_minting_tx_mocktail_tx_builder() -> Transaction {
  mocktail_tx()
    |> mint(True, 1, mock_policy_id(0), mock_token_name())
    |> complete()
}

test m103_l2_mocktail_tx_builder() {
  mock_minting_tx() == mock_minting_tx_mocktail_tx_builder()
}

fn mock_minting_tx_mocktail_tx() -> Transaction {
  placeholder
    |> add_mint(True, from_asset(mock_policy_id(0), mock_token_name(), 1))
}

test m103_l2_mocktail_tx() {
  mock_minting_tx() == mock_minting_tx_mocktail_tx()
}
