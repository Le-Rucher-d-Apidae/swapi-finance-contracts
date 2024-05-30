// SPDX-License-Identifier: GPL-3.0-or-later

// pragma solidity ^0.8.23;
pragma solidity >=0.8.20 < 0.9.0;

contract StakingRewards2Events {
  event RewardAdded(uint256 reward);
  event RewardAddedPerTokenStored(uint256 rewardPerTokenStored);
  event MaxTotalSupply(uint256 maxTotalSupply);
  event Staked(address indexed user, uint256 amount);
  event Withdrawn(address indexed user, uint256 amount);
  event RewardPaid(address indexed user, uint256 reward);
  event RewardsDurationUpdated(uint256 newDuration);
  event Recovered(address token, uint256 amount);
}
