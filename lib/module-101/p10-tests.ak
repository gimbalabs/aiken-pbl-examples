type Redeemer {
  Locking { name1: ByteArray }
  Unlocking { name2: ByteArray }
}

type Redeemer1 {
  Redeemer1 { name: ByteArray }
}

// test test_same_name_redeemer() {
//   let lock = Locking { name1: "John" }
//   let redeemer1 = Redeemer1 { name: "John" }
//   trace @"lock": lock
//   trace @"redeemer1": redeemer1
//   let Redeemer1 { name } = redeemer1
//   when lock is {
//     Locking { name1 } -> name == name1
//     _ -> False
//   }
// }

test test_same_name_redeemer() {
  let lock = Locking { name1: "John" }
  let redeemer1 = Redeemer1 { name: "John" }
  trace @"lock": lock
  trace @"redeemer1": redeemer1
  let Redeemer1 { name } = redeemer1
  expect Locking { name1 } = lock
  name == name1
}
