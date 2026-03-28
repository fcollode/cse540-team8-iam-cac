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

    event DidAdded(string holderDidKey, address caller, uint256 timestamp);
    event DidRevoked(string holderDidKey, address caller, uint256 timestamp);

    function addDidToRegistry(string memory holderDidKey) public {

        require(bytes(didRegistry[holderDidKey].id).length == 0, "ERROR: did:key already exists");

        didRegistry[holderDidKey] = DidDocument({
            id: holderDidKey,
            controller: holderDidKey,
            serviceEndpoint: "ipfs://",
            isValid: true
        });

        emit DidAdded(holderDidKey, msg.sender, block.timestamp);

    }

    function revokeDid (string memory holderDidKey) public {

        require(bytes(didRegistry[holderDidKey].id).length != 0, "ERROR: did:key does not exist");
        require(didRegistry[holderDidKey].isValid == true, "ERROR: did:key has already been revoked");

        didRegistry[holderDidKey].isValid = false;

        emit DidRevoked(holderDidKey, msg.sender, block.timestamp);

    }

}
