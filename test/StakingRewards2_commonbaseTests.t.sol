// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { StakingPreSetupErc20_18_18 } from "./StakingRewards2_commonbase.t.sol";
import { StakeZero, WithdrawZero } from "../src/contracts/StakingRewards2Errors.sol";

// ----------------

contract StakingPreSetup is StakingPreSetupErc20_18_18 {
  // Rewards constants

  // Rewards program duration : see StakingPreSetupDuration

  function setUp() public virtual override {
    debugLog("StakingSetup setUp() start");

    if (REWARD_INITIAL_DURATION == 0) {
      fail("StakingSetup: REWARD_INITIAL_DURATION is 0");
    }

    StakingPreSetupErc20_18_18.setUp();

    // Constant reward amount allocated to the staking program during the reward duration
    // Same reward amount is distributed at each block
    // Stakers will share the reward budget based on their staked amount
    /* solhint-disable var-name-mixedcase */
    uint256 REWARD_RATE = 1e5;
    REWARD_INITIAL_AMOUNT = REWARD_INITIAL_DURATION * REWARD_RATE;
    /* solhint-enable var-name-mixedcase */

    if (REWARD_INITIAL_AMOUNT < REWARD_INITIAL_DURATION) {
      errorLog("REWARD_INITIAL_AMOUNT", REWARD_INITIAL_AMOUNT);
      errorLog("REWARD_INITIAL_DURATION", REWARD_INITIAL_DURATION);
      fail("StakingSetup: REWARD_INITIAL_AMOUNT < REWARD_INITIAL_DURATION");
    }

    // Mint reward tokens
    vm.prank(erc20Minter);
    rewardErc20.mint(address(stakingRewards2), REWARD_INITIAL_AMOUNT);

    verboseLog("StakingSetup setUp()");
    debugLog("StakingSetup setUp() end");
  }

  // All stakers share reward budget, the more staked amount, the less rewards for each staker
  // Reward rate is constant, same reward amount is "distributed" at each block, shared between stakers
  // All budget is spent during the reward duration
  function checkRewardForDuration(uint256 _delta) internal virtual override {
    debugLog("StakingPreSetup: checkRewardForDuration");
    _checkRewardForDuration(_delta);
  }

  function expectedStakingRewards(
    uint256 _stakedAmount,
    uint256 _rewardDurationReached,
    uint256 _rewardTotalDuration
  )
    internal
    virtual
    override
    returns (uint256 expectedRewardsAmount)
  {
    debugLog("StakingPreSetup: expectedStakingRewards");
    debugLog("StakingPreSetup: _stakedAmount", _stakedAmount);
    debugLog("StakingPreSetup: _rewardDurationReached", _rewardDurationReached);
    debugLog("StakingPreSetup: _rewardTotalDuration", _rewardTotalDuration);
    return super.expectedStakingRewards(_stakedAmount, _rewardDurationReached, _rewardTotalDuration);
  }
} // StakingPreSetup

contract TestZero is StakingPreSetup {
  function setUp() public override {
    debugLog("TestZero setUp() start");
    StakingPreSetup.setUp();
    verboseLog("TestZero");
    debugLog("TestZero setUp() end");
  }

  function testUnstakeZeroSuccess() public {
    AliceUnstakes(0);
  }

  function testUnstakeZeroEvent() public {
    vm.prank(userAlice);
    vm.expectRevert(abi.encodeWithSelector(WithdrawZero.selector));
    stakingRewards2.withdraw(0);
  }

  function testStakeZeroSuccess() public {
    AliceStakes(0);
  }

  function testStakeZeroEvent() public {
    vm.prank(userAlice);
    vm.expectRevert(abi.encodeWithSelector(StakeZero.selector));
    stakingRewards2.stake(0);
  }
}
// ------------------------------------
