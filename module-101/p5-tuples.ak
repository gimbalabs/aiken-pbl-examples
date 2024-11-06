test m101_p5_tuples() {
  let my_tuple = (True, 1, "hello world")
  my_tuple.1st && my_tuple.2nd == 1 && my_tuple.3rd == "hello world"
}
