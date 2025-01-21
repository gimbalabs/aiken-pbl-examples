// use aiken/crypto.{VerificationKeyHash}
use cardano/transaction.{OutputReference, Transaction}
use cocktail.{key_signed}
use mocktail.{
  complete, mock_pub_key_hash, mock_utxo_ref, mocktail_tx, required_signer_hash,
}

pub type Datum {
  owner: ByteArray,
}

// owner: VerificationKeyHash,

/// Learning objecting
/// 1. Familiar with data type short hand form (only one constructor)
/// 2. Learn about Vodka utils in checking signature
/// 3. Can distinguish between: who signed the transaction vs who is required to signed the transaction -> building early concept on cardano validator
/// 4. Learn building required signers with Mocktail tx builder
validator check_signatures {
  spend(
    datum_opt: Option<Datum>,
    _redeemer: Data,
    _input: OutputReference,
    tx: Transaction,
  ) {
    // otherwise - no datum, validator fail at this line
    expect Some(datum) = datum_opt
    key_signed(tx.extra_signatories, datum.owner)
  }

  else(_) {
    fail
  }
}

type TestCase {
  is_key_signed: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase { is_key_signed } = test_case
  mocktail_tx()
    |> required_signer_hash(is_key_signed, mock_pub_key_hash(0))
    |> complete()
}

test md201_l5_test_success() {
  let tx = mock_tx(TestCase { is_key_signed: True })
  let datum = Some(Datum { owner: mock_pub_key_hash(0) })
  check_signatures.spend(datum, Void, mock_utxo_ref(0, 0), tx)
}

test md201_l5_test_failed_without_signer() {
  let tx = mock_tx(TestCase { is_key_signed: False })
  let datum = Some(Datum { owner: mock_pub_key_hash(0) })
  !check_signatures.spend(datum, Void, mock_utxo_ref(0, 0), tx)
}

test md201_l5_test_failed_with_incorrect_signer() {
  let tx = mock_tx(TestCase { is_key_signed: True })
  let datum = Some(Datum { owner: mock_pub_key_hash(1) })
  !check_signatures.spend(datum, Void, mock_utxo_ref(0, 0), tx)
}

test md201_l5_test_failed_with_no_datum() fail {
  let tx = mock_tx(TestCase { is_key_signed: True })
  let datum = None
  // Whether true or false as the expected result, they are indeed identical
  // since we are checking the fail case by breaking program
  // check_signatures.spend(datum, Void, mock_utxo_ref(0, 0), tx)
  !check_signatures.spend(datum, Void, mock_utxo_ref(0, 0), tx)
}
