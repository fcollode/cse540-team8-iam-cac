import argparse
from web3 import Web3
import json
from cryptography.hazmat.primitives.asymmetric import x25519
import base58

class smartContract:
    def __init__(self):
        self.anvilURL = "http://127.0.0.1:8545"
        self.w3 = None
        self.contract = None

    def connect(self, deployedToAddress, jsonFile):
        try:
            self.w3 = Web3(Web3.HTTPProvider(self.anvilURL))
        except Exception as e:
            print(f"An unexpected error occurred: {e}")            

        # Load contract ABI
        contractJsonFile = open(jsonFile, 'r')
        contractJsonData = json.load(contractJsonFile)
        contractABI = contractJsonData["abi"]

        # Establish communication with the smart contract
        try:
            self.contract = self.w3.eth.contract(address=deployedToAddress, abi=contractABI)
        except Exception as e:
            print(f"An unexpected error occurred: {e}") 

    def addDidKey(self, args):
        try:
            txHash = self.contract.functions.addDidKey(args.employeeid, args.employeedidkey).transact({'from': self.w3.eth.accounts[0]})
            txReceipt = self.w3.eth.wait_for_transaction_receipt(txHash)
            print(f"Transaction receipt received in block: {txReceipt.blockNumber}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
    
    def revokeDidKey(self, args):
        try:
            txHash = self.contract.functions.revokeDidKey(args.employeeid).transact({'from': self.w3.eth.accounts[0]})
            txReceipt = self.w3.eth.wait_for_transaction_receipt(txHash)
            print(f"Transaction receipt received in block: {txReceipt.blockNumber}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")            

    def updateDidKey(self, args):
        try:
            txHash = self.contract.functions.updateDidKey(args.employeeid, args.employeenewdidkey).transact({'from': self.w3.eth.accounts[0]})
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

    # Admin User operations
    adminOperationsParser = adminRoleParser.add_subparsers(dest="operation", help="Admin User operations")

    # Admin User operation -- Add DID Key
    addDidKeyOperationParser = adminOperationsParser.add_parser("addkey", help="Register a DID key in the blockchain")
    addDidKeyOperationParser.add_argument("--employeeid", type=lambda x: int(x, 0), required=True, help="Employee HR ID")
    addDidKeyOperationParser.add_argument("--employeedidkey", required=True, help="DID key to link to employee")
    addDidKeyOperationParser.set_defaults(func=DIDRegistryContract.addDidKey)

    # Admin User operation -- Revoke DID Key
    revokeDidKeyOperationParser = adminOperationsParser.add_parser("revokekey", help="Revoke an existing DID key in the blockchain")
    revokeDidKeyOperationParser.add_argument("--employeeid", type=lambda x: int(x, 0), required=True, help="Employee HR ID")
    revokeDidKeyOperationParser.set_defaults(func=DIDRegistryContract.revokeDidKey)

    # Admin User operation -- Update DID Key
    updateDidKeyOperationParser = adminOperationsParser.add_parser("updatekey", help="Update an existing DID key in the blockchain")
    updateDidKeyOperationParser.add_argument("--employeeid", type=lambda x: int(x, 0), required=True, help="Employee HR ID")
    updateDidKeyOperationParser.add_argument("--employeenewdidkey", required=True, help="New DID key to link to employee")
    updateDidKeyOperationParser.set_defaults(func=DIDRegistryContract.updateDidKey)


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
