# Specification - Mint - PlutusNFT

## Parameter

- `collection_name`: The name of the NFT collection to be enforced in token name
- `oracle_nft`: The policy id of `OracleNFT`

## User Action

1. Mint - Redeemer `RMint`

   - There is 1 input with `oracle_nft`
   - There is exactly 1 token minted from current transaction, with correct token name (`${collection_name} (${count})`

2. Burn - Redeemer `RBurn`

   - The current policy id only has negative minting value in transaction body.
