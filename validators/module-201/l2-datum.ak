use cardano/transaction.{OutputReference, Transaction, placeholder}
use mocktail.{mock_utxo_ref}

pub type Datum {
  Datum1 { secret: ByteArray }
  Datum2
}

pub type Redeemer {
  RedeemerWithMessage { message: ByteArray }
}

/// Learning objecting
/// 1. Get a sense of basic validation
/// 2. Can determine this is a dummy validator - not really guarding anything
/// 3. Can tell why the test cases can pass with placeholder transaction (nothing inside)
validator check_datum {
  spend(
    datum_opt: Option<Datum>,
    redeemer: Redeemer,
    _input: OutputReference,
    _tx: Transaction,
  ) {
    let RedeemerWithMessage { message } = redeemer
    when datum_opt is {
      Some(Datum1 { secret }) -> message == secret
      _ -> False
    }
  }

  else(_) {
    fail
  }
}

test md201_l2_test_success() {
  let datum = Some(Datum1 { secret: "hello world" })
  let redeemer = RedeemerWithMessage { message: "hello world" }

  check_datum.spend(datum, redeemer, mock_utxo_ref(0, 0), placeholder)
}

test md201_l2_test_fail_with_incorrect_redeemer_message() {
  let datum = Some(Datum1 { secret: "hello world" })
  let redeemer = RedeemerWithMessage { message: "GM Cardano" }

  !check_datum.spend(datum, redeemer, mock_utxo_ref(0, 0), placeholder)
}

test md201_l2_test_fail_with_fail_datum() {
  let datum = Some(Datum2)
  let redeemer = RedeemerWithMessage { message: "hello world" }

  !check_datum.spend(datum, redeemer, mock_utxo_ref(0, 0), placeholder)
}
