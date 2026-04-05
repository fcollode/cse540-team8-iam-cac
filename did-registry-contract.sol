// SPDX-License-Identifier: GPL-3.0

/*
CSE 540 2026 Spring B
Team 8 IAM Corporate Access Control dApp
*/

pragma solidity >=0.8.2 <0.9.0;

contract DidRegistryContract {

    /*
    DidRegistryContract holds the DID Registry and the Employee Registry, tracking updates on-chain.
    Full employee information and linked credentials, however, are stored off-chain in IPFS as a cost-saving measure.

    An 'Employee ID' is assigned to every employee during company onboarding. The ID is the primary
    key as it uniquely distinguishes employees. While keys of any sort can be issued, replaced, or revoked,
    the employee ID is immutable.
    */

    // Map employeeId to DID Document
    mapping(uint => DidDocument) private didRegistry;

    // Map employeeId to Employee entry in employeeRegistry
    mapping(uint => Employee) private employeeRegistry;


    /*
    DID Registry
    didRegistry[employeeId] = DidDocument
    */
    struct DidDocument {

        // Decentralized Identifier (DID) v1.0 specification at https://www.w3.org/TR/did-core/
        // DID key method specification at https://w3c-ccg.github.io/did-key-spec
        string didKey;
        bool isValid;
    }


    /*
    Employee Registry
    employeeRegistry[employeeId] = Employee
    */
    struct Employee {
        uint256 employeeId;
        string ipfsCidInformationFile;
        string ipfsCidCredentialsFile;
        bool isValid;        
    }

    // DID Registry events
    event DidAdded(uint employeeId, string didKey, address caller, uint256 timestamp);
    event DidRevoked(uint employeeId, address caller, uint256 timestamp);
    event DidUpdated(uint employeeId, string newDidKey, address caller, uint256 timestamp);

    // Employee Registry events
    event EmployeeAdded(uint employeeId, address caller, uint256 timestamp);
    event EmployeeRevoked(uint employeeId, address caller, uint256 timestamp);
    event EmployeeEnabled(uint employeeId, address caller, uint256 timestamp);
    event EmployeeUpdatedIpfsCidInformationFile(uint employeeId, address caller, uint256 timestamp);
    event EmployeeUpdatedIpfsCidCredentialsFile(uint employeeId, address caller, uint256 timestamp);


    /*
    DID Registry Functions
    */
    function addDidKey(uint employeeId, string memory didKey) public {

        require(bytes(didRegistry[employeeId].didKey).length == 0, "ERROR: did:key already exists for employee");

        didRegistry[employeeId] = DidDocument({
            didKey: didKey,
            isValid: true
        });

        emit DidAdded(employeeId, didKey, msg.sender, block.timestamp);

    }

    function revokeDidKey(uint employeeId) public {

        require(bytes(didRegistry[employeeId].didKey).length != 0, "ERROR: did:key does not exist");
        require(didRegistry[employeeId].isValid == true, "ERROR: did:key has already been revoked");

        didRegistry[employeeId].isValid = false;

        emit DidRevoked(employeeId, msg.sender, block.timestamp);

    }

    function updateDidKey(uint employeeId, string memory newDidKey) public {

        require(bytes(didRegistry[employeeId].didKey).length != 0, "ERROR: A did:key must exist before it can be replaced");

        didRegistry[employeeId].didKey = newDidKey;
        didRegistry[employeeId].isValid = true;

        emit DidUpdated(employeeId, newDidKey, msg.sender, block.timestamp);

    }

    /*
    Employee Registry functions
    */

    function addEmployee(uint employeeId, string memory ipfsCidInformationFile) public {

        // Function arguments above represent the minimum required information to initialize a new employee in the system.

        require(bytes(employeeRegistry[employeeId].ipfsCidInformationFile).length == 0, "ERROR: Employee already exists");

        employeeRegistry[employeeId] = Employee({
            employeeId: employeeId,
            ipfsCidInformationFile: ipfsCidInformationFile,
            ipfsCidCredentialsFile: "",
            isValid: true
        });

        emit EmployeeAdded(employeeId, msg.sender, block.timestamp);

    }

    function revokeEmployee(uint employeeId) public {

        require(bytes(employeeRegistry[employeeId].ipfsCidInformationFile).length != 0, "ERROR: Employee does not exist");
        employeeRegistry[employeeId].isValid = false;

        emit EmployeeRevoked(employeeId, msg.sender, block.timestamp);

    }
    
    function enableEmployee(uint employeeId) public {

        require(bytes(employeeRegistry[employeeId].ipfsCidInformationFile).length != 0, "ERROR: Employee does not exist");
        employeeRegistry[employeeId].isValid = true;

        emit EmployeeEnabled(employeeId, msg.sender, block.timestamp);

    }

    function updateEmployeeipfsCidInformationFile(uint employeeId, string memory ipfsCidInformationFile) public {

        require(bytes(employeeRegistry[employeeId].ipfsCidInformationFile).length != 0, "ERROR: Employee does not exist");
        employeeRegistry[employeeId].ipfsCidInformationFile = ipfsCidInformationFile;

        emit EmployeeUpdatedIpfsCidInformationFile(employeeId, msg.sender, block.timestamp);

    }

    function updateEmployeeipfsCidCredentialsFile(uint employeeId, string memory ipfsCidCredentialsFile) public {

        require(bytes(employeeRegistry[employeeId].ipfsCidInformationFile).length != 0, "ERROR: Employee does not exist");
        employeeRegistry[employeeId].ipfsCidCredentialsFile = ipfsCidCredentialsFile;

        emit EmployeeUpdatedIpfsCidCredentialsFile(employeeId, msg.sender, block.timestamp);

    }

}
