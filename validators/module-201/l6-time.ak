use cardano/transaction.{OutputReference, Transaction}
use cocktail.{valid_after, valid_before}
use mocktail.{
  complete, invalid_before, invalid_hereafter, mock_utxo_ref, mocktail_tx,
}

pub type Datum {
  must_be_after: Int,
  must_be_before: Int,
}

/// Learning objecting
/// 1. Familiar with data type short hand form (only one constructor)
/// 2. Learn about Vodka utils in checking time range
/// 3. Can distinguish between: when does the tx happened vs in which timeframe must the tx happened -> building early concept on cardano validator
/// 4. Learn building valid tx time range with Mocktail tx builder
validator check_time {
  spend(
    datum_opt: Option<Datum>,
    _redeemer: Data,
    _input: OutputReference,
    tx: Transaction,
  ) {
    expect Some(datum) = datum_opt
    let is_upper_bound_correct =
      valid_before(tx.validity_range, datum.must_be_before)
    let is_lower_bound_correct =
      valid_after(tx.validity_range, datum.must_be_after)
    is_upper_bound_correct? && is_lower_bound_correct?
  }

  else(_) {
    fail
  }
}

type TestCase {
  is_tx_before_valid_upper_bound: Bool,
  is_tx_after_valid_lower_bound: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase { is_tx_before_valid_upper_bound, is_tx_after_valid_lower_bound } =
    test_case
  mocktail_tx()
    |> invalid_hereafter(is_tx_before_valid_upper_bound, 199)
    |> invalid_before(is_tx_after_valid_lower_bound, 101)
    |> complete()
}

test md201_l6_test_success() {
  let datum = Some(Datum { must_be_after: 100, must_be_before: 200 })
  let tx =
    mock_tx(
      TestCase {
        is_tx_before_valid_upper_bound: True,
        is_tx_after_valid_lower_bound: True,
      },
    )
  check_time.spend(datum, Void, mock_utxo_ref(0, 0), tx)
}

test md201_l6_test_failed_with_invalid_before() {
  let datum = Some(Datum { must_be_after: 100, must_be_before: 200 })
  let tx =
    mock_tx(
      TestCase {
        is_tx_before_valid_upper_bound: False,
        is_tx_after_valid_lower_bound: True,
      },
    )
  !check_time.spend(datum, Void, mock_utxo_ref(0, 0), tx)
}

test md201_l6_test_failed_with_invalid_hereafter() {
  let datum = Some(Datum { must_be_after: 100, must_be_before: 200 })
  let tx =
    mock_tx(
      TestCase {
        is_tx_before_valid_upper_bound: True,
        is_tx_after_valid_lower_bound: False,
      },
    )
  !check_time.spend(datum, Void, mock_utxo_ref(0, 0), tx)
}
