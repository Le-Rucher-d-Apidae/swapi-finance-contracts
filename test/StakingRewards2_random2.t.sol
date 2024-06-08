// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { StakingPreSetupErc20 } from "./StakingRewards2_commonbase.t.sol";
import {
  DELTA_0_00000000022,
  DELTA_0_00000000000002,
  DELTA_0_015,
  DELTA_0_31,
  DELTA_0_04,
  DELTA_5,
  PERCENT_0,
  PERCENT_1,
  PERCENT_5,
  PERCENT_90,
  PERCENT_99,
  PERCENT_100,
  PERCENT_220,
  DELTA_0,
  ONE_TOKEN
} from "./TestsConstants.sol";

import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";

// ----------------

contract StakingPreSetup is StakingPreSetupErc20 {
  // Rewards constants

  // Rewards program duration : see StakingPreSetupDuration

  function setUp() public virtual override {
    debugLog("StakingSetup setUp() start");

    if (REWARD_INITIAL_DURATION == 0) {
      fail("StakingSetup: REWARD_INITIAL_DURATION is 0");
    }

    StakingPreSetupErc20.setUp();

    // Constant reward amount allocated to the staking program during the reward duration
    // Same reward amount is distributed at each block
    // Stakers will share the reward budget based on their staked amount
    uint256 REWARD_RATE = 1e5;
    REWARD_INITIAL_AMOUNT = REWARD_INITIAL_DURATION * REWARD_RATE;

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
    view
    virtual
    override
    returns (uint256 expectedRewardsAmount)
  {
    debugLog("StakingPreSetup:expectedStakingRewards: _stakedAmount = ", _stakedAmount);
    debugLog("StakingPreSetup:expectedStakingRewards: _rewardDurationReached = ", _rewardDurationReached);
    debugLog("StakingPreSetup:expectedStakingRewards: _rewardTotalDuration = ", _rewardTotalDuration);
    uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);
    debugLog("StakingPreSetup:expectedStakingRewards: rewardsDuration = ", rewardsDuration);

    uint256 expectedStakingRewards_;

    if (TOTAL_STAKED_AMOUNT == 0) {
      expectedStakingRewards_ = REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardTotalDuration;
    } else {
      expectedStakingRewards_ = (
        rewardsDuration == _rewardTotalDuration
          ? REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT
          : REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardTotalDuration / TOTAL_STAKED_AMOUNT
      );
    }

    debugLog("StakingPreSetup:expectedStakingRewards: expectedStakingRewards_ = ", expectedStakingRewards_);
    return expectedStakingRewards_;
  }
} // StakingPreSetup

// ------------------------------------

contract DuringStaking1WithoutWithdral is StakingPreSetup {
  function setUp() public override {
    debugLog("DuringStaking1WithoutWithdral setUp() start");
    StakingPreSetup.setUp();
    verboseLog("DuringStaking1WithoutWithdral");
    debugLog("DuringStaking1WithoutWithdral setUp() end");
  }

  function checkUsersStake() public {
    checkAliceStake();
  }

  function testUsersStakingRewards(
    uint256 _checkRewardsAtStakingPercentageDuration,
    uint256 _claimRewardsAtPercentageDuration,
    int64 _stakingStartAliceDelta
  )
    public
  {
    CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = bound(_checkRewardsAtStakingPercentageDuration, PERCENT_0, PERCENT_220);
    CLAIM_REWARDS_AT__PERCENTAGE_DURATION = bound(_claimRewardsAtPercentageDuration, PERCENT_0, PERCENT_99);
    vm.assume(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION >= CLAIM_REWARDS_AT__PERCENTAGE_DURATION);

    vm.assume( INITIAL_BLOCK_TIMESTAMP + _stakingStartAliceDelta > 0);

    debugLog("> CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = ", CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    debugLog("> CLAIM_REWARDS_AT__PERCENTAGE_DURATION         = ", CLAIM_REWARDS_AT__PERCENTAGE_DURATION);
    debugLog("> CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = %s %%", CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION * 100 / PERCENT_100);
    debugLog("> CLAIM_REWARDS_AT__PERCENTAGE_DURATION         = %s %%", CLAIM_REWARDS_AT__PERCENTAGE_DURATION * 100 / PERCENT_100);

    debugLog("_stakingStartAliceDelta = ", _stakingStartAliceDelta);

    int256 ALICE_STAKING_TIMESTAMP = INITIAL_BLOCK_TIMESTAMP + _stakingStartAliceDelta;

    initTimestamp(int256(Math.min(uint256(INITIAL_BLOCK_TIMESTAMP), uint256(ALICE_STAKING_TIMESTAMP))));

    debugLog("> INITIAL_BLOCK_TIMESTAMP = ", INITIAL_BLOCK_TIMESTAMP);
    debugLog("> ALICE_STAKING_TIMESTAMP = ", ALICE_STAKING_TIMESTAMP);
    uint256 stakingElapsedTime;
    uint256 userAliceExpectedRewards;
    uint256 userAliceClaimedRewards;
    uint256 stakingEffectiveStartTime_Alice;

    // Alice stakes before staking starts
    if (ALICE_STAKING_TIMESTAMP < INITIAL_BLOCK_TIMESTAMP) {
      debugLog("> Alice stakes BEFORE staking rewards starts");
      gotoTimestamp(ALICE_STAKING_TIMESTAMP);
      AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);
    }

    gotoTimestamp(INITIAL_BLOCK_TIMESTAMP);

    // Start staking rewards
    vm.prank(userStakingRewardAdmin);
    verboseLog("--- START REWARDING ---");
    notifyRewardAmount(REWARD_INITIAL_AMOUNT);

    stakingEffectiveStartTime_Alice = uint256(ALICE_STAKING_TIMESTAMP) < STAKING_START_TIMESTAMP ? STAKING_START_TIMESTAMP : uint256(ALICE_STAKING_TIMESTAMP);

    verboseLog("> STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);

    uint256 USERS_CLAIM_REWARDS_TIMESTAMP = getTimeStampFromStakingPercentage(CLAIM_REWARDS_AT__PERCENTAGE_DURATION);
    uint256 USER_CHECKSTAKINGREWARDS_TIMESTAMP = getTimeStampFromStakingPercentage(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    debugLog("> USERS_CLAIM_REWARDS_TIMESTAMP    = ", USERS_CLAIM_REWARDS_TIMESTAMP);
    debugLog("> USER_CHECKSTAKINGREWARDS_TIMESTAMP    = ", USER_CHECKSTAKINGREWARDS_TIMESTAMP);

    // Now: STAKING_START_TIMESTAMP ( = INITIAL_BLOCK_TIMESTAMP )

    checkUsersStake();
    checkRewardPerToken(0, 0, 0);
    checkRewardForDuration(DELTA_0_00000000022);
    checkStakingTotalSupplyStaked();

    // Claim Before staking : user rewards should be 0
    if (USERS_CLAIM_REWARDS_TIMESTAMP <= uint256(ALICE_STAKING_TIMESTAMP)) {
      if ( USERS_CLAIM_REWARDS_TIMESTAMP < uint256(ALICE_STAKING_TIMESTAMP) ) {
        debugLog("> Alice claims rewards before having staked");
      } else {
        debugLog("> Alice claims rewards exactly at staking start");
      }
      gotoTimestamp(USERS_CLAIM_REWARDS_TIMESTAMP);
      userAliceClaimedRewards =
        checkUserClaimFromRewardsStart(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
      // Should be 0
      if (userAliceClaimedRewards > 0) {
        errorLog("userAliceClaimedRewards greater than 0: ", userAliceClaimedRewards);
        fail("userAliceClaimedRewards > 0");
      }
    }

    // Alice stakes after staking starts (and before staking ends)
    if (ALICE_STAKING_TIMESTAMP >= int256(STAKING_START_TIMESTAMP) && ALICE_STAKING_TIMESTAMP <= int256(STAKING_END_TIMESTAMP)) {
      if ( ALICE_STAKING_TIMESTAMP >= int256(STAKING_START_TIMESTAMP) ) {
        debugLog("> Alice stakes AFTER staking starts");
      } else {
        debugLog("> Alice stakes exactly at staking rewards start");
      }
      gotoTimestamp(ALICE_STAKING_TIMESTAMP);
      AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);
      stakingEffectiveStartTime_Alice = uint256(ALICE_STAKING_TIMESTAMP) < STAKING_START_TIMESTAMP ? STAKING_START_TIMESTAMP : uint256(ALICE_STAKING_TIMESTAMP);
    }
    debugLog("stakingEffectiveStartTime_Alice = ", stakingEffectiveStartTime_Alice);

    // Claim After staking : user rewards should be > 0
    if (USERS_CLAIM_REWARDS_TIMESTAMP >= uint256(ALICE_STAKING_TIMESTAMP)) {
      if ( USERS_CLAIM_REWARDS_TIMESTAMP > uint256(ALICE_STAKING_TIMESTAMP) ) {
        debugLog("> Alice claims rewards after having staked");
      } else {
        debugLog("> Alice claims rewards exactly at staking start");
      }
      gotoTimestamp(USERS_CLAIM_REWARDS_TIMESTAMP);
      stakingElapsedTime = block.timestamp - stakingEffectiveStartTime_Alice;
      userAliceClaimedRewards =
        checkUserClaimFromUserStakingStart(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, "Alice", DELTA_0_015, rewardErc20);
      if ( USERS_CLAIM_REWARDS_TIMESTAMP == stakingEffectiveStartTime_Alice ) {
        debugLog("Alice claims rewards EXACTLY at staking start");
        if (userAliceClaimedRewards != 0) {
          errorLog("userAliceClaimedRewards not equal to 0: ", userAliceClaimedRewards);
          fail("userAliceClaimedRewards != 0");
        }
      } else {
        if (userAliceClaimedRewards <= 0) {
          errorLog("userAliceClaimedRewards lower or equal to 0: ", userAliceClaimedRewards);
          fail("userAliceClaimedRewards > 0");
        }
      }
    }

    if (USER_CHECKSTAKINGREWARDS_TIMESTAMP >= block.timestamp) {
      debugLog("--- Check staking rewards ---");
      gotoTimestamp(USER_CHECKSTAKINGREWARDS_TIMESTAMP);
      checkUsersStake();
      checkRewardForDuration(DELTA_0_00000000022);
      checkStakingPeriod(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    }
    if (block.timestamp >= stakingEffectiveStartTime_Alice) {
      stakingElapsedTime = block.timestamp - stakingEffectiveStartTime_Alice;
    }
    debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
    debugLog(
    "Staking duration (%%) total staking reward duration = ",
    CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
    );
    userAliceExpectedRewards =
      expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
    debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
    debugLog("userAliceClaimedRewards = ", userAliceClaimedRewards);
    userAliceExpectedRewards -= userAliceClaimedRewards;
    debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);

    checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0_00000000000002, 4);

    if (TOTAL_STAKED_AMOUNT > 0) {
        uint256 expectedRewardPerToken = (
        stakingElapsedTime == REWARD_INITIAL_DURATION
            ? REWARD_INITIAL_AMOUNT * ONE_TOKEN / TOTAL_STAKED_AMOUNT
            : REWARD_INITIAL_AMOUNT * stakingElapsedTime * ONE_TOKEN / TOTAL_STAKED_AMOUNT / REWARD_INITIAL_DURATION
        );
        debugLog("expectedRewardPerToken = ", expectedRewardPerToken);

        checkRewardPerToken(expectedRewardPerToken, DELTA_0_00000000000002, 4);
        checkRewardForDuration(DELTA_0_00000000022);
    }

    // Alice stakes after staking ends
    if ( ALICE_STAKING_TIMESTAMP > int256(STAKING_END_TIMESTAMP) ) {
      // Got to end of staking rewards
      gotoTimestamp(STAKING_END_TIMESTAMP);

      userAliceExpectedRewards =
        expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, 0, REWARD_INITIAL_DURATION);
      checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);

      if (userAliceExpectedRewards > 0) {
          errorLog("userAliceExpectedRewards greater than 0: ", userAliceExpectedRewards);
          fail("userAliceExpectedRewards > 0");
      }

      debugLog("Alice stakes AFTER staking ends");
      gotoTimestamp(ALICE_STAKING_TIMESTAMP);
      AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);

      gotoTimestamp(ALICE_STAKING_TIMESTAMP + 100);

      userAliceExpectedRewards =
        expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, 0, REWARD_INITIAL_DURATION);
      checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);

      if (userAliceExpectedRewards > 0) {
          errorLog("userAliceExpectedRewards greater than 0: ", userAliceExpectedRewards);
          fail("userAliceExpectedRewards > 0");
      }
    }

  }
}

// ------------------------------------

contract DuringStaking2WithoutWithdral is StakingPreSetup {}

// ------------------------------------

contract DuringStaking3WithoutWithdral is StakingPreSetup {}

// ------------------------------------

// 1 staker deposit right after staking starts and removes all staked amount after half of staking percentage duration

contract DuringStaking1WithWithdral is StakingPreSetup {}

// ------------------------------------

// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

contract DuringStaking2WithWithdral is StakingPreSetup {}

// ------------------------------------

// 3 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

contract DuringStaking3WithWithdral is StakingPreSetup {}

// --------------------------------------------------------
