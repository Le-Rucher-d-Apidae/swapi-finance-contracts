# Baguette Smart Contracts
This repo contains all of the smart contracts used to run [Swapi](https://www.swapi.finance/).

## Deployed Contracts

### Polygon Mumbai Testnet

Factory address:
0x15a34fd98dbf1c0116bdf740d501f735fca2891b
https://mumbai.polygonscan.com/address/0x15a34fd98dbf1c0116bdf740d501f735fca2891b

Router address:
0xFb89BAD7ee7Db9B8F8d3546D3cB361F3C2f6C3Ef
https://mumbai.polygonscan.com/tx/0x995db7cc49b48212bf6bdb84b37e9ee9a7a3d37f43c73f1791c28dd2405db962
0x15A34Fd98DbF1c0116BDf740D501f735fCa2891B, 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889

## Running
These contracts are compiled and deployed using [Hardhat](https://hardhat.org/). They can also be run using the Remix IDE.

To prepare the dev environment, run `yarn install`. To compile the contracts, run `yarn compile`. Yarn is available to install [here](https://classic.yarnpkg.com/en/docs/install/#debian-stable) if you need it.

## Accessing the ABI
If you need to use any of the contract ABIs, you can install this repo as an npm package with `npm install --dev @swapi-finance//contracts`. Then import the ABI like so: `import { abi as IBaguettePairABI } from '@swapi-finance//contracts/artifacts/contracts/swapi-core/interfaces/IBaguettePair.sol/IBaguettePair.json'`.

## Attribution
These contracts were adapted from these Uniswap repos: [uniswap-v2-core](https://github.com/Uniswap/uniswap-v2-core), [uniswap-v2-periphery](https://github.com/Uniswap/uniswap-v2-core), and [uniswap-lib](https://github.com/Uniswap/uniswap-lib).
