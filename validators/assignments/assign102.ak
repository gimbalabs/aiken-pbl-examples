use cardano/transaction.{OutputReference, Transaction, placeholder}
use mocktail.{mock_utxo_ref}

pub type DatumOne {
  nameOne: Int,
}

pub type RedeemerOne {
  nameTwo: Int,
}

validator assignOne {
  spend(
    datum: Option<DatumOne>,
    redeemer: RedeemerOne,
    _input: OutputReference,
    _tx: Transaction,
  ) {
    // when (datum, redeemer) is {
    //   (Some(DatumOne { .. }), RedeemerOne { .. }) -> True
    //   _ -> False
    // }
    expect Some(DatumOne { .. }) = datum
    expect RedeemerOne { .. } = redeemer
    True
  }

  else(_) {
    fail
  }
}

test assign102_test_success() {
  let datum = Some(DatumOne { nameOne: 1 })
  let redeemer = RedeemerOne { nameTwo: 1 }
  assignOne.spend(datum, redeemer, mock_utxo_ref(0, 0), placeholder)
}

test assign102_test_fail() fail {
  let datum = Some(DatumOne { nameOne: 1 })
  let redeemer = RedeemerOne { nameTwo: 1 }
  !assignOne.spend(datum, redeemer, mock_utxo_ref(0, 0), placeholder)
}
