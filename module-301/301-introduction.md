# Introduction

For the module 301, we will use the [plutus-nft example in mesh repository](https://github.com/MeshJS/mesh/tree/main/packages/mesh-contract/src/plutus-nft/aiken-workspace).

## Contract Description

> Covered in SLT 301.1

This is a set of simple description about the role of each contracts in a complex DApp. Aim to set a high level mental model about the architecture.

## Param Dependency Tree

> Covered in SLT 301.2

Preparation of this documentation servers 2 purposes:

- First, as aiding clarifying what parameters are needed in each contracts as an early way to detect circular parameterization issues.
- Second, to serve as reference at the time of deploying contract so we know exactly how we should compile and parameterized scripts in the off-chain paradigm.

## Specfication

> Covered in SLT 301.3 (Minting) and 301.4 (Spending)

The contract specification is the technical side of documentation to describe how the script validation can be passed. This has to be verbose and precise, so to communicate with other developers and auditors.

## User Action Documentation

> Covered in SLT 301.5

The user action documentation is the product side of documentation to describe how the DApp can be used. It is a documentation that describe in the DApp operation, how potentially one or more scripts are validated together, served as a reference for later developemnt of offchain code.

## Application Setup Documentation

> Covered in SLT 301.6

Similar to the user action documentation, this documentation describe how the DApp can be set up. We normally isolate this part from the user actions after setup since the application setup process is usually deemed as internal actions with less definite guard from scripts (e.g. multiple `oracle_nft` can be minted during setup, but this will harm the application). However, since users are normally in a easy position to audit the deployment process, we don't need enforce excessive contract check at setup (e.g. everyone can validate whether the `oracle_nft` has circulation of 1).
