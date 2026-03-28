# Ethereum Corporate Access Control IAM System
## Description
This project is a corporate access control system implemented in Solidity, for blockchains implementing the Ethereum Virtual Machine. 
We implement a DID system where the existence of user identities are stored to the blockchain in simple structures, and then read and written from the off chain layer. 
We also implement a system to sign verified credentials, to be used as IAM permission tokens.
These are also stored off chain and then verified, using the presenting user's DID and the registry's current permission status. 

These actions are orchestrated by off-chain tooling, to be developed in the next steps.
This system will be developed in standard general purpose programming languages appropriate to the use case in question.
Specifically, we expect to develop a basic management tool in Python, and a proof of concept user app in Javascript, but implementaion details are subject to change.
These tools will use Web3 and IPFS libraries to provide a user friendly and complete IAM system built on top of distributed and decentralized controls.

## Dependencies and Setup
### Dependencies
As the off-chain components have yet to be developed, the dependencies for this project are currently minimal, and will expand in the future as further components are implemented.
The current dependencies are:
1. [Remix IDE](https://remix.live/) with a Solidity compiler matching the pinned version in the contracts to run tests. Currently this is `>=0.8.2 <0.9.0;`.
2. An IPFS node running on the development machine. See [IPFS documentation](https://docs.ipfs.tech/install/ipfs-desktop/) The node must remain up for the duration of using the IAM system, as it cannot otherwise be guaranteed that the VC files will be available for download.

### Setup
Currently the setup of this project involves deploying the contracts and then setting up their pointers to other contracts, in order to utilize their other fuctionality.
1. Deploy each contract from this repository.
2. Because these contracts are dependent on each other's functionality, they must then be linked to each other using the `connectContracts` function of each contract by the initial wallet that deployed the contracts.
The passed address must match the deployed address of the other contract(s) specified in the `connectContracts` function of the appropriate contract.

## Instructions and User Stories
Instructions for use are currently primarily illustrated using user stories.
These stories represent how we intend for the end users and administrators of this system to be able to interact with the IAM system.
Currently, any operations that involve bridging between IPFS and the on-chain Ethereum contract must be conducted manually.

