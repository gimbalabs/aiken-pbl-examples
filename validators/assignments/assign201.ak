// Write a validator that succeeds before a deadline if it sends outputs to at least two different addresses, 
//and that succeeds after a deadline only if the transaction is signed by some "administrator".
use aiken/collection/list
use aiken/crypto.{VerificationKeyHash}
use aiken/interval.{is_entirely_before}
use cardano/assets.{from_lovelace}
use cardano/transaction.{OutputReference, Transaction}
use mocktail.{
  complete, invalid_hereafter, mock_pub_key_address, mock_pub_key_hash,
  mock_utxo_ref, mocktail_tx, tx_out,
}

validator assign201(deadline: Int, administrator: VerificationKeyHash) {
  spend(
    _datum: Option<Data>,
    _redeemer: Data,
    _own_ref: OutputReference,
    self: Transaction,
  ) {
    let Transaction { outputs, extra_signatories, validity_range, .. } = self

    let is_before_deadline = is_entirely_before(validity_range, deadline)

    when is_before_deadline is {
      True -> {
        let outputAddressList = list.map(outputs, fn(output) { output.address })
        let uniqueOutputAddressList = list.unique(outputAddressList)
        let is_at_least_two_different_addresses =
          list.length(uniqueOutputAddressList) >= 2
        is_at_least_two_different_addresses?
      }
      False -> list.has(extra_signatories, administrator)?
    }
  }

  else(_) {
    False
  }
}

// Success test1: deadline, validity range before deadline, outputs to at least two different addresses
test assign201_test_success() {
  let deadline = 1774400405

  let administrator = mock_pub_key_hash(0)

  let value1 = from_lovelace(1000)

  let value2 = from_lovelace(2000)

  let transaction =
    mocktail_tx()
      |> invalid_hereafter(True, deadline - 1)
      |> tx_out(True, mock_pub_key_address(0, None), value1)
      |> tx_out(True, mock_pub_key_address(1, None), value2)
      |> complete()
  assign201.spend(
    deadline,
    administrator,
    None,
    Void,
    mock_utxo_ref(0, 0),
    transaction,
  )
}
