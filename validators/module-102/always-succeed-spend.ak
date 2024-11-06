use cardano/script_context.{Minting, ScriptContext}
use cardano/transaction.{OutputReference, Transaction, placeholder}
use mocktail/virgin_output_reference.{mock_utxo_ref}

/// Learning Objective:
/// 1. Basic type signature of spending validator smart contract
/// 2. Basic idea of transaction
/// 3. Running test case with smart contracts (validator)
validator always_succeed {
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

test m102_test_always_succeed_spending_validator() {
  always_succeed.spend(None, Void, mock_utxo_ref(0, 0), placeholder)
}

test m102_fail_test_always_succeed_spending_validator() {
  let context =
    ScriptContext {
      transaction: placeholder,
      redeemer: Void,
      info: Minting(#""),
    }
  !always_succeed.else(context)
}
