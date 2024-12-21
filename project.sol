
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InstitutionalIncentives {

    address public owner;
    uint public incentiveBalance;
    
    mapping(address => uint) public institutionRewards;
    mapping(address => bool) public isInstitutionVerified;

    event InstitutionRegistered(address indexed institution);
    event RewardsIssued(address indexed institution, uint amount);
    event TransactionVerified(address indexed institution, uint rewardAmount);

    constructor() {
        owner = msg.sender;
        incentiveBalance = 10000 ether; // Initial incentive balance in contract
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this");
        _;
    }

    modifier isVerifiedInstitution(address institution) {
        require(isInstitutionVerified[institution], "Institution not verified");
        _;
    }

    // Function to register an institution and mark them as verified
    function registerInstitution(address institution) external onlyOwner {
        require(!isInstitutionVerified[institution], "Institution already registered");
        isInstitutionVerified[institution] = true;
        emit InstitutionRegistered(institution);
    }

    // Function for institutions to verify transactions and earn rewards
    function verifyTransaction(address institution) external isVerifiedInstitution(institution) {
        uint rewardAmount = 10 ether; // Example reward for verification
        require(incentiveBalance >= rewardAmount, "Insufficient incentives in the system");

        // Issue rewards to the institution
        institutionRewards[institution] += rewardAmount;
        incentiveBalance -= rewardAmount;

        emit TransactionVerified(institution, rewardAmount);
    }

    // Function to issue rewards for participating in the platform
    function issueRewards(address institution, uint amount) external onlyOwner {
        require(isInstitutionVerified[institution], "Institution not verified");
        require(incentiveBalance >= amount, "Insufficient incentive balance");

        institutionRewards[institution] += amount;
        incentiveBalance -= amount;

        emit RewardsIssued(institution, amount);
    }

    // Function for an institution to withdraw rewards
    function withdrawRewards(address payable institution) external {
        uint rewards = institutionRewards[institution];
        require(rewards > 0, "No rewards to withdraw");

        institutionRewards[institution] = 0; // Reset reward balance before transferring
        institution.transfer(rewards);
    }

    // Function to refill the incentive pool
    function refillIncentivePool(uint amount) external onlyOwner {
        incentiveBalance += amount;
    }

    // View function to get current rewards of an institution
    function getInstitutionRewards(address institution) external view returns (uint) {
        return institutionRewards[institution];
    }

    // Function to get the current balance of the incentive pool
    function getIncentivePoolBalance() external view returns (uint) {
        return incentiveBalance;
    }
}