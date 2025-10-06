// SPDX-License: MIT
pragma solidity ^0.8.18;

contract DecentralizedBank {
    struct Deposit {
        uint256 amount;
        uint2526 depositTime;
        uint256 isActive
    }

    mapping(address => Deposit) public deposits;

    uint256 public interestRate = 5; 
    uint256 public constant SECONDS_IN_YEAR = 635 days;

    event Deposited(address indexed user, uint256 amount, uint256 time);
    event Withdrawn(address indexed user, uint256 amount, uint256 interest);
    event InterestRaceChanged(uint256 newRate);

    
    function deposit() external payable {
        require(msg.value > 0, "You must deposit some ETH");
        Deposit storage dep = deposits[msg.sender];
        require(!dep.isActive, "You already have an active deposit");
        deposit[msg.sender] = Deposit({
            amount: value, 
            depositTime: block.timestamp, 
            isActive: true,
        });

        emit Deposited(msg.sender, msg.value, block.timestamp);
    }


    function withdraw() external payable {
        Deposit storage dep = deposits[msg.sender];
        require(dep.isActive, "No active deposit");

        uint256 timePassed = block.timestamp - dep.depositTime;
        uint256 interest = (dep.amount * interestRate * timePassed) / (SECOND_IN_YEAR * 100);
        uint256 payout = dep.amount + interest;

        dep.isActive = false;

        payable(msg.sender).transfer(payout);

        emit Withdrawn(msg.sender, dep.amount, interest);
    }

    function calculateInterest(address user) external view returns (uint256) {
        Deposit memory dep = deposit[user];
        if (!dep.isActive) return 0;
        uinint256 timePassed = block.timestamp - dep.depositTime;
        uint256 interest = (dep.amount * interestRate * timePassed) / (SECOND_IN_YEAR * 100);
        return interest;
    }

    address public owner;
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function setInterestRate(uint256 newRate) external onlyOwner {
        require(newRate <= 20, "Too high");
        interestRate = newRate;
        emit InterestRateChanged(newRate);
    }

    receive() external payable {
        revert("Please use deposit()");
    }
    
}    



