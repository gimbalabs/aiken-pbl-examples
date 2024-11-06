use cardano/assets.{PolicyId}
use cardano/transaction.{Transaction, placeholder}

/// Learning Objective:
/// 1. Basic type signature of minting policy smart contract
/// 2. Basic idea of transaction
/// 3. Running test case with smart contracts (validator)
validator always_succeed {
  mint(_redeemer: Data, _policy_id: PolicyId, _tx: Transaction) {
    True
  }

  else(_) {
    fail
  }
}

test m102_test_always_succeed_minting_policy() {
  always_succeed.mint(Void, "", placeholder)
}
