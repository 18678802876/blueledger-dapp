// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Educational public expense records in SGD cents. No money is transferred.
contract ExpenseLedger {
    struct Expense {
        uint256 amountCents;
        uint8 category;
        string note;
        uint256 timestamp;
    }
    mapping(address => Expense[]) private expenses;
    mapping(address => uint256) public totalSpent;
    event ExpenseAdded(address indexed owner, uint256 indexed index, uint256 amountCents, uint8 category);

    function appId() external pure returns (string memory) { return "BLUELEDGER_V1"; }

    function addExpense(uint256 amountCents, uint8 category, string calldata note) external {
        require(amountCents > 0 && amountCents <= 100000000, "Amount: 0.01 to 1000000 SGD");
        require(category < 5, "Invalid category");
        require(bytes(note).length <= 120, "Note exceeds 120 bytes");
        expenses[msg.sender].push(Expense(amountCents, category, note, block.timestamp));
        totalSpent[msg.sender] += amountCents;
        emit ExpenseAdded(msg.sender, expenses[msg.sender].length - 1, amountCents, category);
    }

    function getCount(address owner) external view returns (uint256) {
        return expenses[owner].length;
    }

    function getExpense(address owner, uint256 index) external view returns (Expense memory) {
        return expenses[owner][index];
    }
}
