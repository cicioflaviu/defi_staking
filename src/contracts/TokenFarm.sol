pragma solidity ^0.5.0;

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenFarm {
    string public name = "Dapp Token Farm"; //State variable
    DappToken public dappToken;
    DaiToken public daiToken;

    address public owner;
    address[] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => bool) public hasStaked;

    constructor(DappToken _dappToken, DaiToken _daiToken) public {
        dappToken = _dappToken;
        daiToken = _daiToken;
        owner = msg.sender;
    }

    // 1. Stakes Tokens (Deposit)
    function stakeTokens(uint _amount) public {
        // Require an amount greater than 0 to stake
        require(_amount > 0, "amount needs to be greater than 0");

        // Transfer Mock Dai tokens to this contract for staking
        daiToken.transferFrom(msg.sender, address(this), _amount);

        // Update stacking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // Add user to stakers array only if they haven't staked already
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    // Issue Tokens
    function issueTokens() public {
        // Only the owner can call this function
        require(msg.sender == owner, "caller must be the owner");

        // Issue tokens to all stakers
        for(uint i=0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];
            if(balance > 0) {
                dappToken.transfer(recipient, balance);
            }
        }
    }

    // Unstaking Tokens (Withdraw)
    function unstakeTokens() public {
        // Get investor balance
        uint balance = stakingBalance[msg.sender];

        // Require a balance greater than 0 to unstake
        require(balance > 0, "amount needs to be greater than 0");

        // Transfer Mock Dai tokens from this contract to the investor 
        daiToken.transfer(msg.sender, balance);

        // Reset staking balance and update status
        stakingBalance[msg.sender] = 0;
        isStaking[msg.sender] = false;
    }
}
