# aiken-pbl-examples

This is a repository serving student examples of AikenPBL (a F12 Project Catalyst proposal)

## Testing with target module

All the tests in this student library is built with naming convention of `<module>_l<slt_number>`, for example:

- `m103_l1` for module 103 slt 1
- `m203_l3` for module 203 slt 3

There is a specific aiken test command to run specifc test cases which match the names, for example:

- Run below for `m103_l1`

  ```sh
  aiken check -m m103_l1
  ```

- Run below for `203_l3`

  ```sh
  aiken check -m 203_l3
  ```
