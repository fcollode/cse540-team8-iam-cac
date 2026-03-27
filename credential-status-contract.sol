// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract credentialStatusContract {

    struct credentialStatus {

        string issuer;
        uint256 bitmaskStatus;
        bool isValid;

    }

    mapping(string => credentialStatus) private credentialStatusRegistry;

    function createCredentialStatusRegistry(string memory issuerDidKey) public {

        // Creates a credential status registry for each Issuer

        require(bytes(credentialStatusRegistry[issuerDidKey].issuer).length == 0, "ERROR: Credential status registry already exists for this Issuer");

        credentialStatusRegistry[issuerDidKey] = credentialStatus({
            issuer: issuerDidKey,
            bitmaskStatus: 0,
            isValid: true
        });

    }

    function validateCredentialStatusRegistry(string memory issuerDidKey) private view returns (bool) {

        require(bytes(credentialStatusRegistry[issuerDidKey].issuer).length != 0, "ERROR: Credential status registry does not exist for this Issuer");
        require(credentialStatusRegistry[issuerDidKey].isValid == true, "ERROR: Credential status registry is revoked for this Issuer");

        return true;

    }

    function revokeCredentialStatusRegistry(string memory issuerDidKey) public {

        require(validateCredentialStatusRegistry(issuerDidKey));

        credentialStatusRegistry[issuerDidKey].isValid = false;
    
    }


    /*
    Credential status
    0 == Enabled
    1 == Revoked
    */

    function enableCredential(string memory issuerDidKey, uint256 credentialIndex) public {

        require(credentialIndex < 256, "ERROR: Credential index out of range");
        require(validateCredentialStatusRegistry(issuerDidKey));

        // AND NOT bitwise operation sets credential status bit to 0 (Valid)
        credentialStatusRegistry[issuerDidKey].bitmaskStatus &= ~(1 << credentialIndex);
    
    }

    function revokeCredential(string memory issuerDidKey, uint256 credentialIndex) public {

        require(credentialIndex < 256, "ERROR: Credential index out of range");
        require(validateCredentialStatusRegistry(issuerDidKey));

        // OR bitwise operation sets credential status bit to 1 (Revoked)
        credentialStatusRegistry[issuerDidKey].bitmaskStatus |= (1 << credentialIndex);
    
    }

    function isCredentialValid(string memory issuerDidKey, uint256 credentialIndex) public view returns (bool) {

        /*
        Returns
        TRUE  == Credential status bit is 0. Credential is valid.
        FALSE == Credential status bit is 1. Credential is revoked.
        */
        require(credentialIndex < 256, "ERROR: Credential index out of range");
        require(validateCredentialStatusRegistry(issuerDidKey));

        // AND bitwise operation returns credential status bit
        return (credentialStatusRegistry[issuerDidKey].bitmaskStatus & (1 << credentialIndex)) == 0;

    }

}
