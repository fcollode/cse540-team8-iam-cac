// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract didRegistry {
    
    mapping(address => string) private didDocumentIpfsHash;
    mapping(address => bool) private isValidUser;

    function createDid(string memory ipfsHash) public {

        didDocumentIpfsHash[tx.origin] = ipfsHash;
        isValidUser[tx.origin] = true;

    }

    function retrieveStatus() public view returns (bool) {
        return isValidUser[tx.origin];
    }

}
