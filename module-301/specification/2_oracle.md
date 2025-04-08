# Specification - Spend - Oracle

## Parameter

## Datum

- `count`: The count of number of minted NFT in the collection
- `lovelace_price`: The fee in lovelace to collect when user mint the NFT
- `fee_address`: The address to collect fee when user mint the NFT

## User Action

1. Mint Plutus NFT - Redeemer `MintPlutusNFT`

   - Only 1 input from and output to current address
   - The only 1 output datum is updated count of +1, and the output value = input value
   - The only 1 output value doesn't containt other irrelevant tokens
   - Fee is paid to fee collector address

2. Stop the oracle validator - Redeemer `StopOracle`

   - The transaction is signed by payment key of the fee address
   - The `OracleNFT` is burnt
