// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { StakingPreSetup
// , Erc20Setup1
, Erc20Setup2
// , Erc20Setup3
} from "./StakingRewards2_base.t.sol";
import {
    DELTA_0_00000000015,
    DELTA_0_015,
    DELTA_0_04,
    DELTA_0_31,
    DELTA_0_4,
    PERCENT_10,
    PERCENT_100,
    DELTA_0,
    ONE_TOKEN
} from "./TestsConstants.sol";

import { StakingRewards2 } from "../src/contracts/StakingRewards2.sol";
import {
    RewardPeriodInProgress,
    ProvidedVariableRewardTooHigh,
    StakeTotalSupplyExceedsAllowedMax
} from "../src/contracts/StakingRewards2Errors.sol";
import { StakingRewards2Events } from "../src/contracts/StakingRewards2Events.sol";

import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";
import { Ownable } from "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts@5.0.2/utils/Pausable.sol";

// ----------------

contract CheckStakingConstantRewardCustom1 is StakingPreSetup, Erc20Setup2
{
    // address payable[] internal users;
    // address internal userAlice;

  function setUp() public virtual override(Erc20Setup2, StakingPreSetup) {
//   function setUp() public virtual override(StakingPreSetup) {
      debugLog("CheckStakingConstantRewardLimits setUp() start");
      verboseLog("StakingSetup1");
      StakingPreSetup.setUp();
      Erc20Setup2.setUp();

        // utils = new Utils();
        // users = utils.createUsers(5);


      vm.prank(userStakingRewardAdmin);
      stakingRewards2 = new StakingRewards2(address(rewardErc20), address(stakingERC20));
      assertEq(userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner");

      debugLog("CheckStakingConstantRewardLimits setUp() end");
  }

  function expectedStakingRewards(
      uint256 _stakedAmount,
      uint256 _rewardDurationReached,
      uint256 _rewardTotalDuration
  )
      internal
      view
      virtual
      override
      returns (uint256 expectedRewardsAmount)
  {
      debugLog("expectedStakingRewards: _stakedAmount = ", _stakedAmount);
      debugLog("expectedStakingRewards: _rewardDurationReached = ", _rewardDurationReached);
      debugLog("expectedStakingRewards: _rewardTotalDuration = ", _rewardTotalDuration);
      verboseLog("expectedStakingRewards: NOT IMPLEMENTED");
      return 0;
  }

  // Check already deposited amount is lower or equal than max amount
  function testStakingVRR2Deposit1BeforeReward1After() public {
      // Reward rate : 10% yearly
      // Depositing 1 Token should give 0.1 ( = 10^17) token reward per year
      /* solhint-disable var-name-mixedcase */

      uint256 APR = 10; // 10%
      uint256 APR_BASE = 100; // 100%
      uint256 MAX_DEPOSIT_TOKEN_AMOUNT = 100;
      uint256 MAX_DEPOSIT_AMOUNT = MAX_DEPOSIT_TOKEN_AMOUNT * ONE_TOKEN; // 100 token // 100 000 000 000 000 000 000
          // = 1e20 = 100 * 1e18 (1 000 000 000 000 000 000)
      uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT * APR / APR_BASE; // 10 token
      uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year
      uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN * APR / APR_BASE) / REWARD_DURATION;

      uint256 ALICE_DEPOSIT_AMOUNT = 20 * ONE_TOKEN; // 20 tokens
      uint256 BOB_DEPOSIT_AMOUNT = 10 * ONE_TOKEN; // 10 tokens
      /* solhint-enable var-name-mixedcase */

      // Mint 10 * 10^18 token as reward
      vm.startPrank(erc20Minter);
      rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);

      // Mint Alice tokens
      stakingERC20.mint(userAlice, ALICE_DEPOSIT_AMOUNT);
      // Mint Bob tokens
      stakingERC20.mint(userBob, BOB_DEPOSIT_AMOUNT);

      vm.stopPrank();

      // Alice deposits tokens BEFORE rewards start
      vm.startPrank(userAlice);
      stakingERC20.approve(address(stakingRewards2), ALICE_DEPOSIT_AMOUNT);
      vm.expectEmit(true, true, false, false, address(stakingRewards2));
      emit StakingRewards2Events.Staked(userAlice, ALICE_DEPOSIT_AMOUNT);
      stakingRewards2.stake(ALICE_DEPOSIT_AMOUNT);
      vm.stopPrank();

// vm.warp

      vm.startPrank(userStakingRewardAdmin);
    //   vm.prank(userStakingRewardAdmin);
      // Check emitted events
      vm.expectEmit(true, true, false, false, address(stakingRewards2));
      emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
      stakingRewards2.setRewardsDuration(REWARD_DURATION);
      // Check emitted events
      vm.expectEmit(true, false, false, false, address(stakingRewards2));
      emit StakingRewards2Events.MaxTotalSupply(ONE_TOKEN);
      vm.expectEmit(true, false, false, false, address(stakingRewards2));
      emit StakingRewards2Events.RewardAddedPerTokenStored(REWARD_PER_TOKEN_STORED);
    //   stakingRewards2.notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);
      notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);
      verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
      STAKING_START_TIME = block.timestamp;
      vm.stopPrank();

      // Bob deposits tokens AFTER rewards start
      vm.startPrank(userBob);
      stakingERC20.approve(address(stakingRewards2), BOB_DEPOSIT_AMOUNT);
      vm.expectEmit(true, true, false, false, address(stakingRewards2));
      emit StakingRewards2Events.Staked(userBob, BOB_DEPOSIT_AMOUNT);
      stakingRewards2.stake(BOB_DEPOSIT_AMOUNT);
      vm.stopPrank();

  }

} // CheckStakingConstantRewardLimits2

// // */