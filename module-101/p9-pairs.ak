use aiken/collection/list

type Dict<value_type> =
  Pairs<ByteArray, value_type>

fn get_pairs() -> Dict<Int> {
  let pair1 = Pair("pair_1", 10)
  let pair2 = Pair("pair_2", 20)
  let pair3 = Pair("pair_2", 30)
  [pair1, pair2, pair3]
}

test m101_p9_pairs() {
  let my_pairs = get_pairs()
  let count =
    list.foldr(
      my_pairs,
      0,
      fn(pair, acc) {
        let Pair(_, count): Pair<ByteArray, Int> = pair
        acc + count
      },
    )
  count == 60
}
