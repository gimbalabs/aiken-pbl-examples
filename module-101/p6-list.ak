test m101_p6_list() {
  let my_list =
    [2, 3]
  let new_list =
    [1, ..my_list]
  new_list == [1, 2, 3]
}
