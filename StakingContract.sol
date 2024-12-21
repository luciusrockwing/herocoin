// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable {
    IERC20 public token;
    uint256 public rewardRate; // Reward rate in percentage
    uint256 public stakeDuration; // Minimum duration for staking (in seconds)
    uint256 public totalStaked;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        bool active;
    }

    mapping(address => Stake) public stakes;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    constructor(IERC20 _token, uint256 _rewardRate, uint256 _stakeDuration) {
        token = _token;
        rewardRate = _rewardRate;
        stakeDuration = _stakeDuration;
    }

    function stakeTokens(uint256 _amount) external {
        require(stakes[msg.sender].active == false, "Already staking");
        require(_amount > 0, "Cannot stake 0 tokens");

        token.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender] = Stake({
            amount: _amount,
            startTime: block.timestamp,
            active: true
        });
        totalStaked += _amount;

        emit Staked(msg.sender, _amount);
    }

    function unstakeTokens() external {
        require(stakes[msg.sender].active == true, "No active stake");
        require(block.timestamp >= stakes[msg.sender].startTime + stakeDuration, "Stake duration not met");

        uint256 stakedAmount = stakes[msg.sender].amount;
        uint256 reward = calculateReward(msg.sender);

        delete stakes[msg.sender];
        totalStaked -= stakedAmount;

        token.transfer(msg.sender, stakedAmount + reward);
        emit Unstaked(msg.sender, stakedAmount);
        emit RewardClaimed(msg.sender, reward);
    }

    function calculateReward(address _staker) internal view returns (uint256) {
        Stake memory stake = stakes[_staker];
        uint256 stakingDuration = block.timestamp - stake.startTime;
        uint256 reward = (stake.amount * rewardRate * stakingDuration) / (100 * 365 days);
        return reward;
    }

    function adjustRewardRate(uint256 _newRewardRate) external onlyOwner {
        rewardRate = _newRewardRate;
    }

    function adjustStakeDuration(uint256 _newStakeDuration) external onlyOwner {
        stakeDuration = _newStakeDuration;
    }
}
