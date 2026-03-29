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
Currently the setup of this project involves deploying the contracts on a test environment.
1. Using [Remix IDE](https://remix.live/), clone this repository.
2. Compile smart contract 'credential-status-contract.sol' and 'did-registry-contract.sol' in the File Explorer.
3. In the Deploy & Run Transactions section, deploy both compiled contracts using a Remix VM environment.
4. Interact with the different contract functions by passing arguments to the functions and observe interaction with the VM blockchain on the right side.
5. Observe the contract functions reject invalid inputs or scenarios, while successfully processing valid arguments according to the current state.


## Instructions and User Stories
Instructions for use are currently primarily illustrated using user stories. These stories represent how we intend for the end users and administrators of this system to be able to interact with the IAM system. Currently, any operations that involve bridging between IPFS and the on-chain Ethereum contract must be conducted manually.

### 1. A new employee should be able to register a Decentralized Identity (DID). 
When a new employee is onboarded, the should be able to generate and register a new Decentralized Identity (DID) on-chain and then store that DID in their personal wallet. 

#### Handler
``` solidity
function addDidToRegistry(string memory holderDidKey) public {

  require(bytes(didRegistry[holderDidKey].id).length == 0, "ERROR: did:key already exists");

  didRegistry[holderDidKey] = DidDocument({
    id: holderDidKey,
    controller: holderDidKey,
    serviceEndpoint: "ipfs://",
    isValid: true
  });

}
```

### 2. An employee should be able to gernate Verifiable Credentials.
An employee should be able to generate Verifiable Credentials on the blockchain.

#### Handler
``` solidity
function issueVC() public {
  // 
}
```

### 3. An admin should be able to update an employee's permissions. 
An user with the `admin` role should be able to update another employee's permissions by either updating the employee's roles or groups. These permissions should correspond to the internal applications that an employee is able to access. 

#### Handler
``` solidity
function addRole() public {
  // 
}

function removeRole() public {
  // 
}
```

### 4. An employee with proper access should be able to login to an internal system. 
When an employee logs into an internal application, the client should send the user's DID and Verifiable Credentials to be verified by the IAM-CAC blockchain.

#### Handler
``` solidity
function isCredentialValid(string memory issuerDidKey, uint256 credentialIndex) public view returns (bool) {

  require(credentialIndex < 256, "ERROR: Credential index out of range");
  require(validateCredentialStatusRegistry(issuerDidKey));

  return (credentialStatusRegistry[issuerDidKey].bitmaskStatus & (1 << credentialIndex)) == 0;

}
```

### 5. An admin only should be able to revoke an employee's Verifiable Credentials.
In case of security incidents, or during employee offboarding, a user with the `admin` role should be able to revoke another user's Verifiable Credentials, immediately removing their access to internal applications. 

#### Handler
``` solidity
function revokeCredential(string memory issuerDidKey, uint256 credentialIndex) public {

  require(credentialIndex < 256, "ERROR: Credential index out of range");
  require(validateCredentialStatusRegistry(issuerDidKey));

  credentialStatusRegistry[issuerDidKey].bitmaskStatus |= (1 << credentialIndex);
    
}
```

### 6. An admin only should be able to delete an employee's Decentralized Identity.
During the employee offboarding process, a user with the `admin` role should be able to delete another employee's DID from the DidRegistry. 

#### Handler
``` solidity
function revokeDid (string memory holderDidKey) public {

  require(bytes(didRegistry[holderDidKey].id).length != 0, "ERROR: did:key does not exist");
  require(didRegistry[holderDidKey].isValid == true, "ERROR: did:key has already been revoked");

  didRegistry[holderDidKey].isValid = false;
    
}
```
