use aiken/collection/dict
use aiken/interval
use cardano/assets.{PolicyId}
use cardano/transaction.{OutputReference, Transaction, placeholder}
use mocktail.{complete, mock_utxo_ref, mocktail_tx}

/// Learning objective
/// 1. Get a basic understanding of transaction
/// 2. Understand that for every single smart contract validator, it has local access to entire current transaction
/// 3. Learn the Cardano type of utxo: txhash + txindex
/// 4. Learn about vodka mocktail util function: mock_utxo_ref
fn transaction_placeholder() -> Transaction {
  Transaction {
    inputs: [],
    reference_inputs: [],
    outputs: [],
    fee: 0,
    mint: assets.zero,
    certificates: [],
    withdrawals: [],
    validity_range: interval.everything,
    extra_signatories: [],
    redeemers: [],
    datums: dict.empty,
    id: #"0000000000000000000000000000000000000000000000000000000000000000",
    votes: [],
    proposal_procedures: [],
    current_treasury_amount: None,
    treasury_donation: None,
  }
}

test m103_l0_aiken_builtin_placeholder() {
  transaction_placeholder() == placeholder
}

test m103_l0_aiken_mocktail_tx() {
  let tx = mocktail_tx() |> complete()
  placeholder == tx
}

validator always_succeed {
  mint(_redeemer: Data, _policy_id: PolicyId, _tx: Transaction) {
    True
  }

  spend(
    _datum: Option<Data>,
    _redeemer: Data,
    _input: OutputReference,
    _tx: Transaction,
  ) {
    True
  }

  else(_) {
    fail
  }
}

test m103_l0_test_always_succeed_minting_policy() {
  always_succeed.mint(Void, "", placeholder)
}

test m103_l0_test_always_succeed_spending_validator() {
  let input =
    OutputReference {
      transaction_id: #"cd82a190d3b4ef95a50bd791882959f541e308adb69b12d022d94a6d9f02bcf0",
      output_index: 0,
    }

  always_succeed.spend(None, Void, input, placeholder)
}

test m103_l0_mocktail_mock_utxo_ref() {
  mock_utxo_ref(0, 0) == OutputReference {
    transaction_id: #"cd82a190d3b4ef95a50bd791882959f541e308adb69b12d022d94a6d9f02bcf0",
    output_index: 0,
  }
}
