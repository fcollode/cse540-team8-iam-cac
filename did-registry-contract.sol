// SPDX-License-Identifier: GPL-3.0

/*
CSE 540 2026 Spring B
Team 8 IAM Corporate Access Control dApp
*/

pragma solidity >=0.8.2 <0.9.0;

contract DidRegistryContract {

    /*
    DidRegistryContract holds essential employee and contractor information, tracking updates on-chain
    for compliance and history reasons. Full credentials, however, are stored off-chain as a cost-saving measure.

    An 'Employee ID' is assigned to every employee or contractor during company onboarding. The ID is the primary
    key as it uniquely distinguishes employees. While keys of any sort can be issued, replaced, or revoked, the employee ID
    is immutable.

    This contract supports three registries:
    - DID registry
    - Employee registry
    - Contractor registry
    */

    // Map employeeId to DID Document
    mapping(uint => DidDocument) private didRegistry;

    // Map employeeId to Employee entry in employeeRegistry
    mapping(uint => Employee) private employeeRegistry;

    // Maps employeeId to Contractor entry in contractorRegistry
    mapping(uint => Contractor) private contractorRegistry;


    /*
    DID Registry
    didRegistry[employeeId] = DidDocument
    */
    struct DidDocument {

        // Decentralized Identifier (DID) v1.0 specification at https://www.w3.org/TR/did-core/
        // DID key method specification at https://w3c-ccg.github.io/did-key-spec
        // Ex. of valid Ed25519 did:key value: did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK
        string didKey;
        bool isValid;
    }


    /*
    Employee Registry
    employeeRegistry[employeeId] = Employee
    */
    struct Employee {
        Identity identity;
        EmploymentDetails employmentDetails;
        string[] roles; // Employees get permissions from roles
    }

    struct Identity {
        // IPFS Content Identifier (CID) for full credential blob
        // Ex.: ipfs://QmPK1s3pNYLi9ERiq3BDxKa4XosgWwFRQUydHUtz4YgpqB        
        string ipfsCid;
        bool isValid;
        string name;
        string email;
    }

    enum EmployeeStatus { FULL_TIME, PART_TIME, CONTRACTOR }
    struct EmploymentDetails {
        EmployeeStatus employeeStatus;
        uint startDate;
        uint endDate;
    }


    /*
    Contractor Registry
    contractorRegistry[employeeId] = Contractor
    */
    struct Contractor {
        Identity identity;
        EmploymentDetails employmentDetails;
        string agency;
        string[] groups; // Contractors get permissions from groups
    }


    // DID events
    event DidAdded(uint employeeId, string holderDidKey, address caller, uint256 timestamp);
    event DidRevoked(uint employeeId, address caller, uint256 timestamp);
    event DidUpdated(uint employeeId, string holderNewDidKey, address caller, uint256 timestamp);

    // Employee events
    event EmployeeAdded(uint employeeId, string name, address caller, uint256 timestamp);
    event EmployeeRevoked(uint employeeId, address caller, uint256 timestamp);
    event EmployeeNameUpdated(uint employeeId, string name, address caller, uint256 timestamp);
    event EmployeeEmailUpdated(uint employeeId, string email, address caller, uint256 timestamp);
    event EmployeeIpfsCidUpdated(uint employeeId, string ipfsCid, address caller, uint256 timestamp);
    event EmployeeStatusUpdated(uint employeeId, EmployeeStatus employeeStatus, address caller, uint256 timestamp);

    // Contractor events
    event ContractorAdded(uint employeeId, string name, address caller, uint256 timestamp);
    event ContractorRevoked(uint employeeId, address caller, uint256 timestamp);


    /*
    DID Registry Functions
    */
    function addDidKey(uint employeeId, string memory holderDidKey) public {

        require(bytes(didRegistry[employeeId].didKey).length == 0, "ERROR: did:key already exists for employee");

        didRegistry[employeeId] = DidDocument({
            didKey: holderDidKey,
            isValid: true
        });

        emit DidAdded(employeeId, holderDidKey, msg.sender, block.timestamp);

    }

    function revokeDidKey(uint employeeId) public {

        require(bytes(didRegistry[employeeId].didKey).length != 0, "ERROR: did:key does not exist");
        require(didRegistry[employeeId].isValid == true, "ERROR: did:key has already been revoked");

        didRegistry[employeeId].isValid = false;

        emit DidRevoked(employeeId, msg.sender, block.timestamp);

    }

    function updateDidKey(uint employeeId, string memory holderNewDidKey) public {

        require(bytes(didRegistry[employeeId].didKey).length != 0, "ERROR: A did:key must exist before it can be replaced");

        didRegistry[employeeId].didKey = holderNewDidKey;
        didRegistry[employeeId].isValid = true;

        emit DidUpdated(employeeId, holderNewDidKey, msg.sender, block.timestamp);

    }

    /*
    Employee Registry functions
    */

    function addEmployee(uint employeeId, string memory _name, string memory _email, uint _startDate, EmployeeStatus _employeeStatus) public {

        // Function arguments above represent the minimum required information to initialize a new employee in the system.

        require(bytes(employeeRegistry[employeeId].identity.name).length == 0, "ERROR: Employee already exists");

        employeeRegistry[employeeId].identity = Identity({
            name: _name,
            email: _email,
            ipfsCid: "",
            isValid: true
        });
        employeeRegistry[employeeId].employmentDetails = EmploymentDetails({
            employeeStatus: _employeeStatus,
            startDate: _startDate,
            endDate: 0
        });
        employeeRegistry[employeeId].roles[0] = "READ_ONLY";

        emit EmployeeAdded(employeeId, _name, msg.sender, block.timestamp);

    }

    function revokeEmployee(uint employeeId, uint _endDate) public {

        require(bytes(employeeRegistry[employeeId].identity.name).length != 0, "ERROR: Employee does not exist");

        employeeRegistry[employeeId].identity.isValid = false;
        employeeRegistry[employeeId].employmentDetails.endDate = _endDate;

        emit EmployeeRevoked(employeeId, msg.sender, block.timestamp);

    }

    function updateEmployeeName(uint employeeId, string memory _name) public {

        require(bytes(employeeRegistry[employeeId].identity.name).length != 0, "ERROR: Employee does not exist");

        employeeRegistry[employeeId].identity.name = _name;

        emit EmployeeNameUpdated(employeeId, _name, msg.sender, block.timestamp);

    }

    function updateEmployeeEmail(uint employeeId, string memory _email) public {

        require(bytes(employeeRegistry[employeeId].identity.name).length != 0, "ERROR: Employee does not exist");

        employeeRegistry[employeeId].identity.email = _email;

        emit EmployeeEmailUpdated(employeeId, _email, msg.sender, block.timestamp);

    }

    function updateEmployeeIpfsCid(uint employeeId, string memory _ipfsCid) public {

        require(bytes(employeeRegistry[employeeId].identity.name).length != 0, "ERROR: Employee does not exist");

        employeeRegistry[employeeId].identity.ipfsCid = _ipfsCid;

        emit EmployeeIpfsCidUpdated(employeeId, _ipfsCid, msg.sender, block.timestamp);

    }

    function updateEmployeeStatus(uint employeeId, EmployeeStatus _employeeStatus) public {

        require(bytes(employeeRegistry[employeeId].identity.name).length != 0, "ERROR: Employee does not exist");

        employeeRegistry[employeeId].employmentDetails.employeeStatus = _employeeStatus;

        emit EmployeeStatusUpdated(employeeId, _employeeStatus, msg.sender, block.timestamp);

    }

    function addRole(uint employeeId, string memory _role) public {}
    function removeRole(uint employeeId, string memory _role) public {}


    /*
    Contractor Registry functions
    */

    function addContractor(uint employeeId, string memory _name, string memory _email, uint _startDate, string memory _agency) public {

        // Function arguments above represent the minimum required information to initialize a new contractor in the system.

        require(bytes(contractorRegistry[employeeId].identity.name).length == 0, "ERROR: Contractor already exists");

        contractorRegistry[employeeId].identity = Identity({
            name: _name,
            email: _email,
            ipfsCid: "",
            isValid: true
        });
        contractorRegistry[employeeId].employmentDetails = EmploymentDetails({
            employeeStatus: EmployeeStatus.CONTRACTOR,
            startDate: _startDate,
            endDate: 0
        });
        contractorRegistry[employeeId].agency = _agency;
        contractorRegistry[employeeId].groups[0] = "GROUP_0";

        emit ContractorAdded(employeeId, _name, msg.sender, block.timestamp);

    }

    function revokeContractor(uint employeeId, uint _endDate) public {

        require(bytes(contractorRegistry[employeeId].identity.name).length != 0, "ERROR: Contractor does not exist");

        contractorRegistry[employeeId].identity.isValid = false;
        contractorRegistry[employeeId].employmentDetails.endDate = _endDate;

        emit ContractorRevoked(employeeId, msg.sender, block.timestamp);

    }

    function updateContractorName(uint employeeId, string memory _name) public {}
    function updateContractorEmail(uint employeeId, string memory _email) public {}
    function updateContractorIpfsCid(uint employeeId, string memory _ipfsCid) public {}
    function updateContractorAgency(uint employeeId, string memory _ipfsCid) public {}

}
