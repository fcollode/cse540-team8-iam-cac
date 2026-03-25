// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract iamCac {

    struct didDocument {

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
    
    mapping(string => didDocument) private didRegistry;

    function addDidToRegistry(string memory holderDidKey) public {

        require(bytes(didRegistry[holderDidKey].id).length == 0, "ERROR: did:key value already exists");

        didRegistry[holderDidKey] = didDocument({
            id: holderDidKey,
            controller: holderDidKey,
            serviceEndpoint: "ipfs://",
            isValid: true
        });

    }

}
