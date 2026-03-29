// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract DidRegistryContract {

    struct DidDocument {

        // Decentralized Identifier (DID) v1.0 specification at https://www.w3.org/TR/did-core/
        // DID key method specification at https://w3c-ccg.github.io/did-key-spec
        // Ex. of valid Ed25519 did:key value: did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK
        string id;
        string controller;

        // IPFS Content Identifier (CID) for full credential blob
        // Ex.: ipfs://QmPK1s3pNYLi9ERiq3BDxKa4XosgWwFRQUydHUtz4YgpqB
        string serviceEndpoint;
        bool isValid;
    }
    
    // users must upload their wallet's public key to be able to use the contract.  
    mapping(address => string) public publicKey;
    // mapping of public keys to DID documents on 
    mapping(string => DidDocument) private didRegistry;
    enum EmployeeStatus { FULL_TIME, PART_TIME, CONTRACTOR }

    struct Identity {
        DidDocument didDocument;
        string ipfsHash;
        bool isValid;
        string name;
        string email;
    }

    struct EmploymentDetails {
        uint employeeId;
        EmployeeStatus employeeStatus;
        uint startDate;
        uint endDate;
    }

    struct Employee {
        Identity identity;
        EmploymentDetails employmentDetails;
        string[] roles; // Employees get permissions from roles
    }

    struct Contractor {
        Identity identity;
        EmploymentDetails employmentDetails;
        string agency;
        string[] groups; // Contractors get permissions from groups
    }

    modifier checkPublicKey(bytes32 signedHash) {
        require(bytes(publicKey[msg.sender]).length != 0);
        string memory senderPublicKey = publicKey[msg.sender];
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly ("memory-safe") {
            r := mload(add(senderPublicKey, 0x20))
            s := mload(add(senderPublicKey, 0x40))
            v := byte(0, mload(add(senderPublicKey, 0x60)))
        }
        if (msg.sender != ecrecover(signedHash, v, r, s)) revert();
        _;
    }

    // verifies that a passed public key is in fact the key that corresponds to the wallet that passed it
    // if the verification is successful, the public key is stored to the public key mapping
    // TODO: cannot test this yet since Remix doesn't have a way to get a public or even private key of a test wallet out that I can see
    function verifyPublicKey(string memory toVerifyKey, bytes32 hashOfKey) public {
        require(bytes(publicKey[msg.sender]).length == 0, "ERROR: public key has already been proven for this wallet");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly ("memory-safe") {
            r := mload(add(toVerifyKey, 0x20))
            s := mload(add(toVerifyKey, 0x40))
            v := byte(0, mload(add(toVerifyKey, 0x60)))
        }
        if (msg.sender != ecrecover(hashOfKey, v, r, s)) revert();
        publicKey[msg.sender] = toVerifyKey;
    }

    function addDidToRegistry(string memory holderDidKey, bytes32 signedDidHash) public checkPublicKey(signedDidHash) {

        require(bytes(didRegistry[holderDidKey].id).length == 0, "ERROR: did:key already exists");

        didRegistry[holderDidKey] = DidDocument({
            id: holderDidKey,
            controller: holderDidKey,
            serviceEndpoint: "ipfs://",
            isValid: true
        });

    }

    function revokeDid (string memory holderDidKey) public {

        require(bytes(didRegistry[holderDidKey].id).length != 0, "ERROR: did:key does not exist");
        require(didRegistry[holderDidKey].isValid == true, "ERROR: did:key has already been revoked");

        didRegistry[holderDidKey].isValid = false;
    
    }

}
