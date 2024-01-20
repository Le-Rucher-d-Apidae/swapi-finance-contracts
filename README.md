# Baguette Smart Contracts
This repo contains all of the smart contracts used to run [Swapi](https://www.swapi.finance/).

## Deployed Contracts

### Fuji Testnet

Factory address: `0xBB6e8C136ca537874a6808dBFC5DaebEd9a57554`

Router address: `0xC386631E7D35c7231bE146b14cf4430b4A524F8A`

## Running
These contracts are compiled and deployed using [Hardhat](https://hardhat.org/). They can also be run using the Remix IDE.

To prepare the dev environment, run `yarn install`. To compile the contracts, run `yarn compile`. Yarn is available to install [here](https://classic.yarnpkg.com/en/docs/install/#debian-stable) if you need it.

## Accessing the ABI
If you need to use any of the contract ABIs, you can install this repo as an npm package with `npm install --dev @swapi-finance//contracts`. Then import the ABI like so: `import { abi as IBaguettePairABI } from '@swapi-finance//contracts/artifacts/contracts/swapi-core/interfaces/IBaguettePair.sol/IBaguettePair.json'`.

## Attribution
These contracts were adapted from these Uniswap repos: [uniswap-v2-core](https://github.com/Uniswap/uniswap-v2-core), [uniswap-v2-periphery](https://github.com/Uniswap/uniswap-v2-core), and [uniswap-lib](https://github.com/Uniswap/uniswap-lib).
