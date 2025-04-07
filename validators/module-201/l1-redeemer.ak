use cardano/transaction.{OutputReference, Transaction, placeholder}
use mocktail.{mock_utxo_ref}

pub type Redeemer {
  SuccessRedeemer
  AnotherSuccessCase
  FailRedeemer
  AnotherFailCase
  AnotherWayToFail
  MoreFailure
  AnotherOne
  AndYetAnotherOne
  ThisOneToo
  AndYetAnotherOneHereToo
}

// SuccessRedeemer:
// {
//   constructor: 0,
//   fields: []
// }

// AnotherSuccessCase:
// {
//   constructor: 1,
//   fields: []
// }

/// Learning objecting
/// 1. Familiar with control flow pattern of routing redeemer to different validation logics
validator check_redeemer {
  spend(
    _datum: Option<Data>,
    redeemer: Redeemer,
    _input: OutputReference,
    _tx: Transaction,
  ) {
    when redeemer is {
      SuccessRedeemer -> True
      AnotherSuccessCase -> True
      _ -> False
    }
  }

  else(_) {
    fail
  }
}

test md201_l1_test_success_redeemer() {
  let redeemer = AnotherSuccessCase
  check_redeemer.spend(None, redeemer, mock_utxo_ref(0, 0), placeholder)
}

test md201_l1_test_fail_redeemer() {
  let redeemer = AnotherWayToFail
  !check_redeemer.spend(None, redeemer, mock_utxo_ref(0, 0), placeholder)
}
