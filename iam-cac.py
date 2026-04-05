import argparse
from web3 import Web3
import json
from cryptography.hazmat.primitives.asymmetric import x25519
import base58
import requests

class smartContract:
    def __init__(self):
        self.anvilURL = "http://127.0.0.1:8545"
        self.ipfsURL = "http://127.0.0.1:5001/api/v0/"
        self.w3 = None
        self.contract = None

    def connect(self, deployedToAddress, jsonFile):
        try:
            self.w3 = Web3(Web3.HTTPProvider(self.anvilURL))
        except Exception as e:
            print(f"An unexpected error occurred: {e}")            

        # Load contract ABI
        try:
            contractJsonFile = open(jsonFile, 'r')
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
        contractJsonData = json.load(contractJsonFile)
        contractABI = contractJsonData["abi"]

        # Establish communication with the smart contract
        try:
            self.contract = self.w3.eth.contract(address=deployedToAddress, abi=contractABI)
        except Exception as e:
            print(f"An unexpected error occurred: {e}") 

    def addDidKey(self, args):
        try:
            txHash = self.contract.functions.addDidKey(args.employeeid, args.employeedidkey).transact({'from': self.w3.eth.accounts[args.sourcewallet]})
            txReceipt = self.w3.eth.wait_for_transaction_receipt(txHash)
            print(f"Transaction receipt received in block: {txReceipt.blockNumber}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
    
    def revokeDidKey(self, args):
        try:
            txHash = self.contract.functions.revokeDidKey(args.employeeid).transact({'from': self.w3.eth.accounts[args.sourcewallet]})
            txReceipt = self.w3.eth.wait_for_transaction_receipt(txHash)
            print(f"Transaction receipt received in block: {txReceipt.blockNumber}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")            

    def updateDidKey(self, args):
        try:
            txHash = self.contract.functions.updateDidKey(args.employeeid, args.employeenewdidkey).transact({'from': self.w3.eth.accounts[args.sourcewallet]})
            txReceipt = self.w3.eth.wait_for_transaction_receipt(txHash)
            print(f"Transaction receipt received in block: {txReceipt.blockNumber}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
    
    def addEmployee(self, args):
        # Prepare JSON structure
        employeeInformationDict = json.loads(args.employeeinfo) if args.employeeinfo else {}
        employeeInformationDict['employeeId'] = args.employeeid
        employeeInformationJson = json.dumps(employeeInformationDict, sort_keys=True)

        # Prepare file for POST operation
        HTTPPostFile = {f'{args.employeeid}personalInformationFile': employeeInformationJson}

        # Write Employee Information JSON file to IPFS
        try:
            HTTPResponse = requests.post(f"{self.ipfsURL}add", files=HTTPPostFile)
            if HTTPResponse.status_code == 200:
                ipfsEmployeeInformationFileCid = HTTPResponse.json()['Hash']
            print(f"IPFS CID: {ipfsEmployeeInformationFileCid}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
        
        # Add new employee to blockchain
        try:
            txHash = self.contract.functions.addEmployee(args.employeeid, ipfsEmployeeInformationFileCid).transact({'from': self.w3.eth.accounts[args.sourcewallet]})
            txReceipt = self.w3.eth.wait_for_transaction_receipt(txHash)
            print(f"Transaction receipt received in block: {txReceipt.blockNumber}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")

    def revokeEmployee(self, args):
        try:
            txHash = self.contract.functions.revokeEmployee(args.employeeid).transact({'from': self.w3.eth.accounts[args.sourcewallet]})
            txReceipt = self.w3.eth.wait_for_transaction_receipt(txHash)
            print(f"Transaction receipt received in block: {txReceipt.blockNumber}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")

    def enableEmployee(self, args):
        try:
            txHash = self.contract.functions.enableEmployee(args.employeeid).transact({'from': self.w3.eth.accounts[args.sourcewallet]})
            txReceipt = self.w3.eth.wait_for_transaction_receipt(txHash)
            print(f"Transaction receipt received in block: {txReceipt.blockNumber}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")        


def generateDidKey(args):

    # Generate a DID Key as per did:key Method v0.9
    # https://w3c-ccg.github.io/did-key-spec/#create

    privateKey = x25519.X25519PrivateKey.generate()
    publicKeyBytes = privateKey.public_key().public_bytes_raw()
    
    # X25519 multi-codec identifier (0xec 0x01)
    multiCodecHeader = bytes([0xec, 0x01])
    prefixedPublicKey = multiCodecHeader + publicKeyBytes
    
    # Base58 encode with the 'z' multibase prefix
    didKey = "z" + base58.b58encode(prefixedPublicKey).decode()
    
    print(f"X25519 Private key: {privateKey.private_bytes_raw().hex()}")
    print(f"X25519 Public key : {publicKeyBytes.hex()}")
    print(f"DID key           : did:key:{didKey}")


if __name__ == "__main__":
    #
    #  Initialize communication with the Smart Contracts
    #
    #
    DIDRegistryContract = smartContract()
    DIDRegistryContract.connect("0x5FbDB2315678afecb367f032d93F642f64180aa3", "../out/did-registry-contract.sol/DidRegistryContract.json")
    
    CredentialStatusContract = smartContract()
    CredentialStatusContract.connect("0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512", "../out/credential-status-contract.sol/CredentialStatusContract.json")
    
    #
    #  Argument parsing definitions
    #
    #
    systemDescription = """
    CSE540 Spring 2026 B
    Identity Access Management Corporate Access Control
    Team members: Charles Saluski, Eric Culley, Frederico Collodetti, Midhun Mathew, Violet Ye
    """

    mainParser = argparse.ArgumentParser(description=systemDescription, formatter_class=argparse.RawDescriptionHelpFormatter)
    
    # Roles
    roleParser = mainParser.add_subparsers(dest="role", help="Supported roles for testing")

    # Operations per role
    userRoleParser = roleParser.add_parser("user", help="Regular User role")
    adminRoleParser = roleParser.add_parser("admin", help="Admin User role")
    issuerRoleParser = roleParser.add_parser("issuer", help="Issuer role")
    verifierRoleParser = roleParser.add_parser("verifier", help="Verifier role")

    # Regular User operations
    userOperationsParser = userRoleParser.add_subparsers(dest="operation", help="Regular User operations")

    # Regular User operation -- Generate DID Key
    generateDidKeyOperationParser = userOperationsParser.add_parser("generatekey", help="Generate a new DID key")
    generateDidKeyOperationParser.set_defaults(func=generateDidKey)

    # Regular User operation -- Add DID Key
    addDidKeyOperationParser = userOperationsParser.add_parser("addkey", help="Register a DID key in the blockchain")
    addDidKeyOperationParser.add_argument("--employeeid", type=lambda x: int(x, 0), required=True, help="Employee HR ID")
    addDidKeyOperationParser.add_argument("--employeedidkey", required=True, help="DID key to link to employee")
    addDidKeyOperationParser.add_argument("--sourcewallet", type=lambda x: int(x), required=True, help="Source Anvil wallet for blockchain transactions (0-9)")
    addDidKeyOperationParser.set_defaults(func=DIDRegistryContract.addDidKey)

    # Regular User operation -- Revoke DID Key
    revokeDidKeyOperationParser = userOperationsParser.add_parser("revokekey", help="Revoke an existing DID key in the blockchain")
    revokeDidKeyOperationParser.add_argument("--employeeid", type=lambda x: int(x, 0), required=True, help="Employee HR ID")
    revokeDidKeyOperationParser.add_argument("--sourcewallet", type=lambda x: int(x), required=True, help="Source Anvil wallet for blockchain transactions (0-9)")
    revokeDidKeyOperationParser.set_defaults(func=DIDRegistryContract.revokeDidKey)

    # Regular User operation -- Update DID Key
    updateDidKeyOperationParser = userOperationsParser.add_parser("updatekey", help="Update an existing DID key in the blockchain")
    updateDidKeyOperationParser.add_argument("--employeeid", type=lambda x: int(x, 0), required=True, help="Employee HR ID")
    updateDidKeyOperationParser.add_argument("--employeenewdidkey", required=True, help="New DID key to link to employee")
    updateDidKeyOperationParser.add_argument("--sourcewallet", type=lambda x: int(x), required=True, help="Source Anvil wallet for blockchain transactions (0-9)")
    updateDidKeyOperationParser.set_defaults(func=DIDRegistryContract.updateDidKey)

    # Admin User operations
    adminOperationsParser = adminRoleParser.add_subparsers(dest="operation", help="Admin User operations")

    # Admin User operation -- Add employee
    addEmployeeOperationParser = adminOperationsParser.add_parser("addemployee", help="Add new employee to blockchain Employee Registry")
    addEmployeeOperationParser.add_argument("--employeeid", type=lambda x: int(x, 0), required=True, help="Employee HR ID")
    addEmployeeOperationParser.add_argument("--employeeinfo", required=False, help="Employee personal information in JSON format e.g. '{\"name\": \"John Doe\", \"email\": \"john.doe@corp.com\", \"dept\": \"Accounting\"}'")
    addEmployeeOperationParser.add_argument("--sourcewallet", type=lambda x: int(x), required=True, help="Source Anvil wallet for blockchain transactions (0-9)")
    addEmployeeOperationParser.set_defaults(func=DIDRegistryContract.addEmployee)

    # Admin User operation -- Revoke employee
    revokeEmployeeOperationParser = adminOperationsParser.add_parser("revokeemployee", help="Revoke employee on blockchain Employee Registry")
    revokeEmployeeOperationParser.add_argument("--employeeid", type=lambda x: int(x, 0), required=True, help="Employee HR ID")
    revokeEmployeeOperationParser.add_argument("--sourcewallet", type=lambda x: int(x), required=True, help="Source Anvil wallet for blockchain transactions (0-9)")
    revokeEmployeeOperationParser.set_defaults(func=DIDRegistryContract.revokeEmployee)

    # Admin User operation -- Enable employee
    enableEmployeeOperationParser = adminOperationsParser.add_parser("enableemployee", help="Enable (unrevoke) employee on blockchain Employee Registry")
    enableEmployeeOperationParser.add_argument("--employeeid", type=lambda x: int(x, 0), required=True, help="Employee HR ID")
    enableEmployeeOperationParser.add_argument("--sourcewallet", type=lambda x: int(x), required=True, help="Source Anvil wallet for blockchain transactions (0-9)")
    enableEmployeeOperationParser.set_defaults(func=DIDRegistryContract.enableEmployee)

    #
    # Argument parsing execution
    #
    #
    args = mainParser.parse_args()   
   
    if hasattr(args, 'func'):
        args.func(args)
        exit(0)
    else:
        mainParser.print_help()
        exit(1)
