// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract eventLoggingContract {

    struct logEntry {
        string holderDidKey;
        string action;
        // both verifier and timestamp are injected by EVM
        address verifier;
        uint256 timestamp;
    }

    mapping(uint256 => logEntry) private eventLog;
    uint256 private logCount;

    // action: "emp_added", "emp_revoked", "verification_success", "verification_failed"
    function logEvent(string memory holderDidKey, string memory action) public {

        require(bytes(holderDidKey).length != 0, "ERROR: holderDidKey is empty");
        require(bytes(action).length != 0, "ERROR: action is empty");

        eventLog[logCount] = logEntry({
            holderDidKey: holderDidKey,
            action      : action,
            verifier    : msg.sender,
            timestamp   : block.timestamp
        });

        logCount++;

    }

}
