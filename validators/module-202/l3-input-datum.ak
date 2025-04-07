use cardano/assets.{from_lovelace}
use cardano/transaction.{
  InlineDatum, Input, OutputReference, Transaction, find_input,
}
use mocktail.{
  complete, mock_pub_key_address, mock_tx_hash, mock_utxo_ref, mocktail_tx,
  tx_in, tx_in_inline_datum,
}

pub type Datum {
  Datum1 { secret: ByteArray }
  Datum2
}

pub type Redeemer {
  RedeemerWithMessage { message: ByteArray }
}

/// Learning objecting
/// 1. Understand the reason behind directly using datum producing in type signature input is unpopular in Cardano development
///    - since it can be accessed from context.transaction
/// 2. Learn about how to cast the Data type into the customized data type
validator check_script_input_value {
  spend( // This spending endpoint can be used to build an address
    _datum_opt: Option<Datum>,
    redeemer: Redeemer,
    input: OutputReference,
    tx: Transaction,
  ) {
    let Transaction { inputs, .. } = tx
    expect Some(own_input) = find_input(inputs, input)

    expect InlineDatum(raw_datum) = own_input.output.datum
    expect input_datum: Datum = raw_datum
    let RedeemerWithMessage { message } = redeemer
    when input_datum is {
      Datum1 { secret } -> message == secret
      Datum2 -> False
    }
  }

  else(_) {
    fail
  }
}

type TestCase {
  is_datum_correct: Bool,
  is_secret_provided: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase { is_datum_correct, is_secret_provided } = test_case
  let secret =
    if is_secret_provided {
      "GM Cardano"
    } else {
      "hello world"
    }
  let datum =
    if is_datum_correct {
      Datum1 { secret }
    } else {
      Datum2
    }

  mocktail_tx()
    |> tx_in(
        True,
        mock_tx_hash(0),
        0,
        from_lovelace(1_000_000),
        mock_pub_key_address(0, None),
      )
    |> tx_in_inline_datum(True, datum)
    |> complete()
}

test md202_l3_test_success() {
  let tx =
    mock_tx(TestCase { is_datum_correct: True, is_secret_provided: True })

  check_script_input_value.spend(
    Some(Datum1 { secret: "hello world" }),
    RedeemerWithMessage { message: "GM Cardano" },
    mock_utxo_ref(0, 0),
    tx,
  )
}

test md202_l3_test_fail_with_wrong_secret() {
  let tx =
    mock_tx(TestCase { is_datum_correct: True, is_secret_provided: False })

  check_script_input_value.spend(
    Some(Datum1 { secret: "hello world" }),
    RedeemerWithMessage { message: "hello world" },
    mock_utxo_ref(0, 0),
    tx,
  )
}

test md202_l3_test_fail_with_wrong_datum() {
  let tx =
    mock_tx(TestCase { is_datum_correct: False, is_secret_provided: True })
  !check_script_input_value.spend(
    Some(Datum1 { secret: "hello world" }),
    RedeemerWithMessage { message: "hello world" },
    mock_utxo_ref(0, 0),
    tx,
  )
}
