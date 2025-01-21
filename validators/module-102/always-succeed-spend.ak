use cardano/script_context.{Minting, ScriptContext}
// use cardano/transaction.{OutputReference, Transaction, find_input, placeholder}
use cardano/transaction.{OutputReference, Transaction, placeholder}
use mocktail.{mock_utxo_ref}

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
    // expect Some(current_input_unlocking_from_script) =
    //   find_input(tx.inputs, input)

    // when datum is {
    //   None -> True // the case of spending no datum utxo in a spending validator
    //   Some(_) -> True // w/ datum
    // }
    True
  }

  else(_) {
    fail
  }
}

test m102_test_always_succeed_spending_validator() {
  trace @"validate for any spending transaction"

  // let output_reference =
  //   OutputReference {
  //     transaction_id: #"0000000000000000000000000000000000000000000000000000000000000000",
  //     output_index: 0,
  //   }
  // always_succeed.spend(None, Void, output_reference, placeholder)
  always_succeed.spend(None, Void, mock_utxo_ref(0, 0), placeholder)
}

// Without fail assertion this will fail!
// test m102_fail_test_always_succeed_spending_validator() {
test m102_fail_test_always_succeed_spending_validator() fail {
  let context =
    ScriptContext {
      transaction: placeholder,
      redeemer: Void,
      info: Minting(#""),
    }
  !always_succeed.else(context)
}
