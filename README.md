# Ethereum Corporate Access Control IAM System
## Description
This project is a corporate access control system implemented in Solidity and Python, for blockchains based on the Ethereum Virtual Machine. 
We implement a DID system where the existence of user identities are stored on the blockchain in simple structures. For cost-saving purposes, additional information is stored off chain. 
We also implement a system to sign verified credentials, to be used as IAM permission tokens.
These are also stored off chain and then verified, using the presenting user's DID and the registry's current permission status. 
These actions are orchestrated via the Python CLI off-chain.
Web3 and other relevant libraries are used to provide a user-friendly and complete IAM system built on top of distributed and decentralized controls.

## Dependencies and Setup
### Dependencies
The dependencies are:
1. Foundry v1.6.0-rc1
2. Kubo 0.40.1
3. Python3 with libraries: web3, cryptography, base58, requests

### Setup
Currently the setup of this project involves deploying the contracts on a local test environment.

1. Install the Foundry smart contract development kit.
``` bash
$ curl -L https://foundry.paradigm.xyz | bash
$ source ~/.bashrc
$ foundryup
```
2. Start Anvil. By default, 10 wallets are initialized. Blocks are mined instantly.
``` bash
$ anvil
```
3. Clone this repository.
4. Initialize forge. The 'Counter' script and test file can be deleted.
``` bash
/cse540-team8-iam-cac$ forge init --no-git
/cse540-team8-iam-cac$ rm script/Counter.s.sol
/cse540-team8-iam-cac$ rm test/Counter.t.sol
```
5. Compile the smart contracts.
``` bash
/cse540-team8-iam-cac$ forge build
```
6. Deploy the contracts to the local blockchain. 
``` bash
/cse540-team8-iam-cac$ cd src/
/cse540-team8-iam-cac/src$ forge create did-registry-contract.sol:DidRegistryContract --rpc-url http://127.0.0.1:8545 --private-key <account[0] privatekey> --broadcast
/cse540-team8-iam-cac/src$ forge create credential-status-contract.sol:CredentialStatusContract --rpc-url http://127.0.0.1:8545 --private-key <account[0] privatekey> --broadcast
```
7. Download and install IPFS Kubo.
``` bash
$ wget https://dist.ipfs.tech/kubo/v0.40.1/kubo_v0.40.1_linux-amd64.tar.gz
$ tar -xvzf kubo_v0.40.1_linux-amd64.tar.gz
$ sudo kubo/install.sh
```
8. Initialize IPFS Kubo with localhost permissions.
``` bash
$ ipfs init
$ ipfs config Addresses.API /ip4/127.0.0.1/tcp/5001
$ ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://localhost:3000", "http://127.0.0.1:5001"]'
$ ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
```
9. Start IPFS Kubo.
``` bash
$ ipfs daemon
```
10. Initialize a Python virtual environment.
``` bash
$ python3 -m venv venv
$ source venv/bin/activate
```
11. Install the Python libraries listed as dependencies above.
``` bash
(venv) $ pip3 install web3
(venv) $ pip3 install cryptography
(venv) $ pip3 install base58
(venv) $ pip3 install requests
```
12. Run the IAM CAC CLI.
``` bash
(venv) /cse540-team8-iam-cac/src$ python3 iam-cac.py --help
```

## User Stories
Instructions for use are currently primarily illustrated using user stories. These stories represent how we intend for the end users and administrators of this system to be able to interact with the IAM system.

### 1. A new employee should be able to register a Decentralized Identity (DID). 
When a new employee is onboarded, the user should be able to generate and register a new Decentralized Identity (DID) on-chain and then store that DID in their personal wallet.

``` sh
$ python3 iam-cac.py user generatekey
$ python3 iam-cac.py user addkey --employeeid EMPLOYEEID --employeedidkey EMPLOYEEDIDKEY --sourcewallet SOURCEWALLET
```

### 2. An employee should be able to update its DID.
An employee should be able to update its DID on the blockchain.

``` sh
$ python3 iam-cac.py user updatekey --employeeid EMPLOYEEID --employeenewdidkey EMPLOYEENEWDIDKEY --sourcewallet SOURCEWALLET
```

### 3. An employee should be able to revoke its DID.
An employee should be able to revoke its DID on the blockchain.

``` sh
$ python3 iam-cac.py user revokekey --employeeid EMPLOYEEID --sourcewallet SOURCEWALLET
```

### 4. An admin should be able to add a new employee.
An user with the `admin` role should be able to add a new employee. Minimum information required to initialize a new employee is passed as argument. Optionally, the administrator can add employee information on-chain, passed in JSON format.

``` sh
$ python3 iam-cac.py admin addemployee --employeeid EMPLOYEEID [--employeeinfo EMPLOYEEINFO] --sourcewallet SOURCEWALLET
```

### 5. An admin should be able to revoke an employee.
During employee offboarding, a user with the `admin` role should be able to revoke another user, immediately terminating their access to all internal applications.

``` sh
$ python3 iam-cac.py admin revokeemployee --employeeid EMPLOYEEID --sourcewallet SOURCEWALLET
```

### 6. An admin should be able to enable (unrevoke) an employee.
An user with the `admin` role should be able to enable (unrevoke) an employee.

``` sh
$ python3 iam-cac.py admin enableemployee --employeeid EMPLOYEEID --sourcewallet SOURCEWALLET
```

### 7. An admin should be able to update employee's information.
Once an employee is added to the system, an user with 'admin' role should be able to update employee information, including the IPFS CID to either the employee information blob or the employee credentials blob.

``` solidity
function updateEmployeeipfsCidInformationFile(uint employeeId, string memory ipfsCidInformationFile) public {}
function updateEmployeeipfsCidCredentialsFile(uint employeeId, string memory ipfsCidCredentialsFile) public {}
```

### 8. An admin should be able to update an employee's permissions. 
An user with the `admin` role should be able to update another employee's permissions by either updating the employee's roles or groups. These permissions should correspond to the internal applications that an employee is able to access. 

``` sh
$ python3 iam-cac.py admin <WORK IN PROGRESS>
```

### 9. An employee should be granted access to login into an internal system by the Issuer.
If the employee has been given permission to access an internal system, the corresponding Issuer enables the user's credential status.

``` bash
$ python3 iam-cac.py issuer <WORK IN PROGRESS>
```

``` solidity
/*
Credential status
0 == Enabled
1 == Revoked
*/
function enableCredential(string memory issuerDidKey, uint256 credentialIndex) public {}
```

### 10. A system's Issuer should be able to revoke access to a user.
If the employee's permission to access an internal system is disabled, the corresponding Issuer revokes the user's credential status.

``` sh
$ python3 iam-cac.py issuer <WORK IN PROGRESS>
```

``` solidity
function revokeCredential(string memory issuerDidKey, uint256 credentialIndex) public {}
```

### 11. An employee with proper access should be able to login to an internal system. 
When an employee logs into an internal application, the Verifier checks the credential status on the IAM-CAC blockchain.

``` sh
$ python3 iam-cac.py verifier <WORK IN PROGRESS>
```

``` solidity
/*
Returns
TRUE  == Credential status bit is 0. Credential is valid.
FALSE == Credential status bit is 1. Credential is revoked.
*/
function isCredentialValid(string memory issuerDidKey, uint256 credentialIndex) public view returns (bool) {}
```
