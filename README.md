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
function addDidKey(uint employeeId, string memory holderDidKey) public {}
```

### 2. An employee should be able to update its DID.
An employee should be able to update its DID on the blockchain.

#### Handler
``` solidity
function updateDidKey(uint employeeId, string memory holderNewDidKey) public {}
```

### 3. An admin should be able to add a new employee.
An user with the `admin` role should be able to add a new employee. Minimum information required to initialize a new employee is passed as argument.

#### Handler
``` solidity
function addEmployee(uint employeeId, string memory _name, string memory _email, uint _startDate, EmployeeStatus _employeeStatus) public {}
```

### 4. An admin should be able to update employee's information.
Once an employee is added to the system, an user with 'admin' role should be able to update information, including the IPFS CID to full credential blob.

#### Handler
``` solidity
function updateEmployeeName(uint employeeId, string memory _name) public {}
function updateEmployeeEmail(uint employeeId, string memory _email) public {}
function updateEmployeeIpfsCid(uint employeeId, string memory _ipfsCid) public {}
function updateEmployeeStatus(uint employeeId, EmployeeStatus _employeeStatus) public {}
```

### 5. An admin should be able to update an employee's permissions. 
An user with the `admin` role should be able to update another employee's permissions by either updating the employee's roles or groups. These permissions should correspond to the internal applications that an employee is able to access. 

#### Handler
``` solidity
function addRole(uint employeeId, string memory _role) public {}
function removeRole(uint employeeId, string memory _role) public {}
```

### 6. An admin should be able to add a new contractor.
An user with the `admin` role should be able to add a new contractor. Minimum information required to initialize a new contractor is passed as argument.

#### Handler
``` solidity
function addContractor(uint employeeId, string memory _name, string memory _email, uint _startDate, string memory _agency) public {}
```

 ### 7. An admin should be able to update contractor's information.
Once a contractor is added to the system, an user with 'admin' role should be able to update information, including the IPFS CID to full credential blob.

#### Handler
``` solidity
function updateContractorName(uint employeeId, string memory _name) public {}
function updateContractorEmail(uint employeeId, string memory _email) public {}
function updateContractorIpfsCid(uint employeeId, string memory _ipfsCid) public {}
function updateContractorAgency(uint employeeId, string memory _ipfsCid) public {}
```

### 8. An employee should be granted access to login into an internal system by the Issuer.
If the employee has been given permission to access an internal system, the corresponding Issuer enables the user's credential status.

#### Handler
``` solidity
/*
Credential status
0 == Enabled
1 == Revoked
*/
function enableCredential(string memory issuerDidKey, uint256 credentialIndex) public {}
```

### 9. A system's Issuer should be able to revoke access to a user.
If the employee's permission to access an internal system is disabled, the corresponding Issuer revokes the user's credential status.

#### Handler
``` solidity
function revokeCredential(string memory issuerDidKey, uint256 credentialIndex) public {}
```

### 10. An employee with proper access should be able to login to an internal system. 
When an employee logs into an internal application, the Verifier checks the credential status on the IAM-CAC blockchain.

#### Handler
``` solidity
/*
Returns
TRUE  == Credential status bit is 0. Credential is valid.
FALSE == Credential status bit is 1. Credential is revoked.
*/
function isCredentialValid(string memory issuerDidKey, uint256 credentialIndex) public view returns (bool) {}
```

### 11. An admin only should be able to revoke an employee in the Employee Registry.
During employee offboarding, a user with the `admin` role should be able to revoke another user, immediately terminating their access to all internal applications. 

#### Handler
``` solidity
function revokeEmployee(uint employeeId, uint _endDate) public {}
```

### 12. An admin only should be able to revoke an employee in the Employee Registry.
During contractor offboarding, a user with the `admin` role should be able to revoke a contractor, immediately terminating their access to all internal applications. 

#### Handler
``` solidity
function revokeContractor(uint employeeId, uint _endDate) public {}
```

### 13. An admin only should be able to revoke an employee's Decentralized Identity.
During the employee offboarding process, a user with the `admin` role should be able to revoke another employee's DID from the DidRegistry. 

#### Handler
``` solidity
function revokeDidKey(uint employeeId) public {}
```
