// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { StakingPreSetupErc20_18_18 } from "./StakingRewards2_commonbase.t.sol";
import {
  DELTA_0_00000000022,
  DELTA_0_00000000000002,
  DELTA_0_015,
  DELTA_0_04,
  PERCENT_0,
  PERCENT_1,
  PERCENT_5,
  PERCENT_90,
  PERCENT_99,
  PERCENT_100,
  PERCENT_220,
  DELTA_0,
  ONE_TOKEN_18
} from "./TestsConstants.sol";

import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";

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

  function testUsersStakingRewards(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) public {
    CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = bound(_stakingPercentageDuration, PERCENT_0, PERCENT_220);
    CLAIM_REWARDS_AT__PERCENTAGE_DURATION = bound(_claimPercentageDuration, PERCENT_0, PERCENT_99);
    vm.assume(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION >= CLAIM_REWARDS_AT__PERCENTAGE_DURATION);

    debugLog("CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = ", CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    debugLog("CLAIM_REWARDS_AT__PERCENTAGE_DURATION = ", CLAIM_REWARDS_AT__PERCENTAGE_DURATION);

    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(REWARD_INITIAL_AMOUNT);
    debugLog("Staking start time", STAKING_START_TIMESTAMP);

    AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);

    verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);
    checkUsersStake();
    checkRewardPerToken(0, 0, 0);
    checkRewardForDuration(DELTA_0_00000000022);
    checkStakingTotalSupplyStaked();

    uint256 stakingElapsedTime;
    uint256 userAliceExpectedRewards;
    uint256 userAliceClaimedRewards;

    if (CLAIM_REWARDS_AT__PERCENTAGE_DURATION > 0) {
      gotoStakingPercentage(CLAIM_REWARDS_AT__PERCENTAGE_DURATION);
      userAliceClaimedRewards =
        checkUserClaimFromRewardsStart(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
    }

    gotoStakingPercentage(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    checkUsersStake();
    checkRewardForDuration(DELTA_0_00000000022);
    checkStakingPeriod(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
    debugLog("stakingElapsedTime = ", stakingElapsedTime);
    debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
    debugLog(
      "Staking duration (%%) total staking reward duration = ",
      CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
    );

    userAliceExpectedRewards =
      expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
    userAliceExpectedRewards -= userAliceClaimedRewards;

    checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0_00000000000002, 4);

    uint256 expectedRewardPerToken = (
      getRewardDurationReached() == REWARD_INITIAL_DURATION
        ? REWARD_INITIAL_AMOUNT * ONE_TOKEN_18 / TOTAL_STAKED_AMOUNT
        : REWARD_INITIAL_AMOUNT * getRewardDurationReached() * ONE_TOKEN_18 / TOTAL_STAKED_AMOUNT / REWARD_INITIAL_DURATION
    );

    checkRewardPerToken(expectedRewardPerToken, DELTA_0_00000000000002, 4);
    checkRewardForDuration(DELTA_0_00000000022);
  }
}

// ------------------------------------

contract DuringStaking2WithoutWithdral is StakingPreSetup {
  function setUp() public override {
    debugLog("DuringStaking2WithoutWithdral setUp() start");
    StakingPreSetup.setUp();
    verboseLog("DuringStaking2WithoutWithdral");
    debugLog("DuringStaking2WithoutWithdral setUp() end");
  }

  function checkUsersStake() public {
    checkAliceStake();
    checkBobStake();
  }

  function testUsersStakingRewards(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) public {
    CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = bound(_stakingPercentageDuration, PERCENT_0, PERCENT_220);
    CLAIM_REWARDS_AT__PERCENTAGE_DURATION = bound(_claimPercentageDuration, PERCENT_0, PERCENT_99);
    vm.assume(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION >= CLAIM_REWARDS_AT__PERCENTAGE_DURATION);

    debugLog("CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = ", CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    debugLog("CLAIM_REWARDS_AT__PERCENTAGE_DURATION = ", CLAIM_REWARDS_AT__PERCENTAGE_DURATION);

    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(REWARD_INITIAL_AMOUNT);
    verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);

    AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);
    BobStakes(BOB_STAKINGERC20_MINTEDAMOUNT);

    checkUsersStake();
    checkRewardPerToken(0, 0, 0);
    checkRewardForDuration(DELTA_0_00000000022);
    checkStakingTotalSupplyStaked();

    uint256 stakingElapsedTime;
    uint256 userAliceExpectedRewards;
    uint256 userBobExpectedRewards;
    uint256 userAliceClaimedRewards;
    uint256 userBobClaimedRewards;

    if (CLAIM_REWARDS_AT__PERCENTAGE_DURATION > 0) {
      gotoStakingPercentage(CLAIM_REWARDS_AT__PERCENTAGE_DURATION);
      userAliceClaimedRewards =
        checkUserClaimFromRewardsStart(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
      userBobClaimedRewards =
        checkUserClaimFromRewardsStart(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015, rewardErc20);
    }

    gotoStakingPercentage(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    checkUsersStake();
    checkRewardForDuration(DELTA_0_00000000022);
    checkStakingPeriod(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
    debugLog("stakingElapsedTime = ", stakingElapsedTime);
    debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
    debugLog(
      "Staking duration (%%) total staking reward duration = ",
      CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
    );

    userAliceExpectedRewards =
      expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
    userAliceExpectedRewards -= userAliceClaimedRewards;
    checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0_00000000000002, 0); // DELTA_0_31

    userBobExpectedRewards =
      expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
    userBobExpectedRewards -= userBobClaimedRewards;
    checkStakingRewards(userBob, "Bob", userBobExpectedRewards, DELTA_0_00000000000002, 0); // DELTA_0_31

    uint256 expectedRewardPerToken = (
      getRewardDurationReached() == REWARD_INITIAL_DURATION
        ? REWARD_INITIAL_AMOUNT * ONE_TOKEN_18 / TOTAL_STAKED_AMOUNT
        : REWARD_INITIAL_AMOUNT * getRewardDurationReached() * ONE_TOKEN_18 / TOTAL_STAKED_AMOUNT / REWARD_INITIAL_DURATION
    );
    checkRewardPerToken(expectedRewardPerToken, DELTA_0, 0); // DELTA_0_015, 0
    checkRewardForDuration(DELTA_0_00000000022);
  }
}

// ------------------------------------

contract DuringStaking3WithoutWithdral is StakingPreSetup {
  function setUp() public override {
    debugLog("DuringStaking3WithoutWithdral setUp() start");
    StakingPreSetup.setUp();
    verboseLog("DuringStaking3WithoutWithdral");
    debugLog("DuringStaking3WithoutWithdral setUp() end");
  }

  function checkUsersStake() public {
    checkAliceStake();
    checkBobStake();
    checkCherryStake();
  }

  function testUsersStakingRewards(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) public {
    CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = bound(_stakingPercentageDuration, PERCENT_0, PERCENT_220);
    CLAIM_REWARDS_AT__PERCENTAGE_DURATION = bound(_claimPercentageDuration, PERCENT_0, PERCENT_99);
    vm.assume(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION >= CLAIM_REWARDS_AT__PERCENTAGE_DURATION);

    debugLog("CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = ", CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    debugLog("CLAIM_REWARDS_AT__PERCENTAGE_DURATION = ", CLAIM_REWARDS_AT__PERCENTAGE_DURATION);

    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(REWARD_INITIAL_AMOUNT);
    verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);

    AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);
    BobStakes(BOB_STAKINGERC20_MINTEDAMOUNT);
    CherryStakes(CHERRY_STAKINGERC20_MINTEDAMOUNT);

    checkUsersStake();
    checkRewardPerToken(0, 0, 0);
    checkRewardForDuration(DELTA_0_00000000022);
    checkStakingTotalSupplyStaked();

    uint256 stakingElapsedTime;
    uint256 userAliceExpectedRewards;
    uint256 userBobExpectedRewards;
    uint256 userCherryExpectedRewards;
    uint256 userAliceClaimedRewards;
    uint256 userBobClaimedRewards;
    uint256 userCherryClaimedRewards;

    uint256 claimDelta = getClaimPercentDelta();
    uint256 rewardsDelta = getRewardPercentDelta();

    debugLog("CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION : ", CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    debugLog(
      "CLAIM_REWARDS_AT__PERCENTAGE_DURATION > PERCENT_90 : ",
      (CLAIM_REWARDS_AT__PERCENTAGE_DURATION > PERCENT_90 ? 1 : 0)
    );
    debugLog(
      "CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION <= PERCENT_1 : ",
      (CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION <= PERCENT_1 ? 1 : 0)
    );
    debugLog(
      "CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION <= PERCENT_5 : ",
      (CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION <= PERCENT_5 ? 1 : 0)
    );
    debugLog("rewardsDelta : ", rewardsDelta);

    if (CLAIM_REWARDS_AT__PERCENTAGE_DURATION > 0) {
      gotoStakingPercentage(CLAIM_REWARDS_AT__PERCENTAGE_DURATION);
      debugLog("claimDelta : ", claimDelta);
      userAliceClaimedRewards =
        checkUserClaimFromRewardsStart(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", claimDelta, rewardErc20);
      userBobClaimedRewards =
        checkUserClaimFromRewardsStart(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", claimDelta, rewardErc20);
      userCherryClaimedRewards = checkUserClaimFromRewardsStart(
        userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry", claimDelta, rewardErc20
      );
    }

    gotoStakingPercentage(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    checkUsersStake();
    checkRewardForDuration(DELTA_0_00000000022);
    checkStakingPeriod(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
    debugLog("stakingElapsedTime = ", stakingElapsedTime);
    debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
    debugLog(
      "Staking duration (%%) total staking reward duration = ",
      CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
    );

    userAliceExpectedRewards =
      expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
    debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
    userAliceExpectedRewards -= userAliceClaimedRewards;
    debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
    checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, rewardsDelta, 2);

    userBobExpectedRewards =
      expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
    debugLog("userBobExpectedRewards = ", userBobExpectedRewards);
    userBobExpectedRewards -= userBobClaimedRewards;
    debugLog("userBobExpectedRewards = ", userBobExpectedRewards);
    checkStakingRewards(userBob, "Bob", userBobExpectedRewards, rewardsDelta, 1);

    userCherryExpectedRewards =
      expectedStakingRewards(CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
    debugLog("userCherryExpectedRewards = ", userCherryExpectedRewards);
    userCherryExpectedRewards -= userCherryClaimedRewards;
    debugLog("userCherryExpectedRewards = ", userCherryExpectedRewards);
    checkStakingRewards(userCherry, "Cherry", userCherryExpectedRewards, rewardsDelta, 1);

    uint256 expectedRewardPerToken = (
      getRewardDurationReached() == REWARD_INITIAL_DURATION
        ? REWARD_INITIAL_AMOUNT * ONE_TOKEN_18 / TOTAL_STAKED_AMOUNT
        : REWARD_INITIAL_AMOUNT * getRewardDurationReached() * ONE_TOKEN_18 / TOTAL_STAKED_AMOUNT / REWARD_INITIAL_DURATION
    );
    debugLog("expectedRewardPerToken = ", expectedRewardPerToken);

    checkRewardPerToken(expectedRewardPerToken, DELTA_0_015, 0);
    checkRewardForDuration(DELTA_0_00000000022);
  }
}

// ------------------------------------

// 1 staker deposit right after staking starts and removes all staked amount after half of staking percentage duration

contract DuringStaking1WithWithdral is StakingPreSetup {
  // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
  /* solhint-disable var-name-mixedcase */
  uint8 internal immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration
  /* solhint-enable var-name-mixedcase */

  function setUp() public override {
    debugLog("DuringStaking1WithWithdral setUp() start");
    StakingPreSetup.setUp();
    verboseLog("DuringStaking1WithWithdral");
    debugLog("DuringStaking1WithWithdral setUp() end");
  }

  function checkUsersStake() public {
    checkAliceStake();
  }

  function testUsersStakingRewards(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) public {
    CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = bound(_stakingPercentageDuration, PERCENT_0, PERCENT_220);
    CLAIM_REWARDS_AT__PERCENTAGE_DURATION = bound(_claimPercentageDuration, PERCENT_0, PERCENT_99);
    vm.assume(CLAIM_REWARDS_AT__PERCENTAGE_DURATION < CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION / DIVIDE);

    debugLog("CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = ", CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    debugLog("CLAIM_REWARDS_AT__PERCENTAGE_DURATION = ", CLAIM_REWARDS_AT__PERCENTAGE_DURATION);

    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(REWARD_INITIAL_AMOUNT);

    AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);

    verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);
    checkUsersStake();
    checkRewardPerToken(0, 0, 0);
    checkRewardForDuration(DELTA_0_00000000022);
    checkStakingTotalSupplyStaked();

    uint256 stakingElapsedTime;
    uint256 stakingPercentageDurationReached;
    uint256 userAliceExpectedRewards;
    uint256 userAliceClaimedRewards;

    stakingPercentageDurationReached = CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION / DIVIDE;
    verboseLog(
      "Staking duration (%%) = CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION / DIVIDE  : ",
      stakingPercentageDurationReached
    );
    gotoStakingPercentage(stakingPercentageDurationReached);
    stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
    debugLog("stakingElapsedTime = ", stakingElapsedTime);

    checkStakingPeriod(stakingPercentageDurationReached);

    verboseLog("Staking duration reached (%%) before withdrawal(s) = : ", stakingPercentageDurationReached);

    // Users withdraws all

    // Alice withdraws all
    userAliceExpectedRewards =
      expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);

    debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
    debugLog("userAliceClaimedRewards = ", userAliceClaimedRewards);
    userAliceExpectedRewards -= userAliceClaimedRewards;
    debugLog("userAliceExpectedRewards - userAliceClaimedRewards = ", userAliceExpectedRewards);

    uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN_18
      / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;
    debugLog("expectedRewardPerToken = ", expectedRewardPerToken);

    AliceUnstakes(ALICE_STAKINGERC20_STAKEDAMOUNT);

    gotoStakingPercentage(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    checkRewardForDuration(DELTA_0_00000000022);

    debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
    debugLog(
      "Staking duration (%%) total staking reward duration = ",
      CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
    );

    debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
    checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0_04, 2);
    checkRewardPerToken(expectedRewardPerToken, DELTA_0_015, 0); // no delta needed

    checkRewardForDuration(DELTA_0_00000000022);
  }
}

// ------------------------------------

// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

contract DuringStaking2WithWithdral is StakingPreSetup {
  // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
  /* solhint-disable var-name-mixedcase */
  uint8 internal immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration
  /* solhint-enable var-name-mixedcase */

  function setUp() public override {
    debugLog("DuringStaking2WithWithdral setUp() start");
    StakingPreSetup.setUp();
    verboseLog("DuringStaking2WithWithdral");
    debugLog("DuringStaking2WithWithdral setUp() end");
  }

  function checkUsersStake() public {
    checkAliceStake();
    checkBobStake();
  }

  function testUsersStakingRewards(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) public {
    CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = bound(_stakingPercentageDuration, PERCENT_0, PERCENT_220);
    CLAIM_REWARDS_AT__PERCENTAGE_DURATION = bound(_claimPercentageDuration, PERCENT_0, PERCENT_99);
    vm.assume(CLAIM_REWARDS_AT__PERCENTAGE_DURATION < CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION / DIVIDE);

    debugLog("CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = ", CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    debugLog("CLAIM_REWARDS_AT__PERCENTAGE_DURATION = ", CLAIM_REWARDS_AT__PERCENTAGE_DURATION);

    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(REWARD_INITIAL_AMOUNT);
    verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);

    AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);
    BobStakes(BOB_STAKINGERC20_MINTEDAMOUNT);

    checkUsersStake();
    checkRewardPerToken(0, 0, 0);
    checkRewardForDuration(DELTA_0_00000000022);
    checkStakingTotalSupplyStaked();

    uint256 claimDelta = getClaimPercentDelta();
    uint256 rewardsDelta = getRewardPercentDelta();

    uint256 stakingElapsedTime;
    uint256 stakingPercentageDurationReached;
    uint256 userAliceExpectedRewards;
    uint256 userBobExpectedRewards;
    uint256 userAliceClaimedRewards;
    uint256 userBobClaimedRewards;

    if (CLAIM_REWARDS_AT__PERCENTAGE_DURATION > 0) {
      gotoStakingPercentage(CLAIM_REWARDS_AT__PERCENTAGE_DURATION);
      userAliceClaimedRewards =
        checkUserClaimFromRewardsStart(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", claimDelta, rewardErc20);
      userBobClaimedRewards =
        checkUserClaimFromRewardsStart(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", claimDelta, rewardErc20);
    }

    stakingPercentageDurationReached = CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION / DIVIDE;
    verboseLog(
      "Staking duration (%%) = CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION / DIVIDE  : ",
      stakingPercentageDurationReached
    );
    gotoStakingPercentage(stakingPercentageDurationReached);
    stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
    debugLog("stakingElapsedTime = ", stakingElapsedTime);
    checkStakingPeriod(stakingPercentageDurationReached);

    verboseLog("Staking duration reached (%%) before withdrawal(s) = : ", stakingPercentageDurationReached);

    // Users withdraws all
    userAliceExpectedRewards =
      expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
    debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
    userAliceExpectedRewards -= userAliceClaimedRewards;
    debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);

    userBobExpectedRewards =
      expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
    debugLog("userBobExpectedRewards = ", userBobExpectedRewards);
    userBobExpectedRewards -= userBobClaimedRewards;
    debugLog("userBobExpectedRewards = ", userBobExpectedRewards);

    uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN_18
      / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;
    debugLog("expectedRewardPerToken = ", expectedRewardPerToken);

    // Alice withdraws all
    AliceUnstakes(ALICE_STAKINGERC20_STAKEDAMOUNT);
    // Bob withdraws all
    BobUnstakes(BOB_STAKINGERC20_STAKEDAMOUNT);

    gotoStakingPercentage(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    checkRewardForDuration(DELTA_0_00000000022);

    debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
    debugLog(
      "Staking duration (%%) total staking reward duration = ",
      CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
    );

    checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, rewardsDelta, 2);
    checkStakingRewards(userBob, "Bob", userBobExpectedRewards, rewardsDelta, 1);

    checkRewardPerToken(expectedRewardPerToken, 0, 1);
    checkRewardForDuration(DELTA_0_00000000022);
  }
}

// ------------------------------------

// 3 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

contract DuringStaking3WithWithdral is StakingPreSetup {
  // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
  /* solhint-disable var-name-mixedcase */
  uint8 internal immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration
  /* solhint-enable var-name-mixedcase */

  function setUp() public override {
    debugLog("DuringStaking3WithWithdral setUp() start");
    StakingPreSetup.setUp();
    verboseLog("DuringStaking3WithWithdral");
    debugLog("DuringStaking3WithWithdral setUp() end");
  }

  function checkUsersStake() public {
    checkAliceStake();
    checkBobStake();
    checkCherryStake();
  }

  function testUsersStakingRewards(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) public {
    CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = bound(_stakingPercentageDuration, PERCENT_0, PERCENT_220);
    CLAIM_REWARDS_AT__PERCENTAGE_DURATION = bound(_claimPercentageDuration, PERCENT_0, PERCENT_99);
    vm.assume(CLAIM_REWARDS_AT__PERCENTAGE_DURATION < CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION / DIVIDE);

    debugLog("CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION = ", CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    debugLog("CLAIM_REWARDS_AT__PERCENTAGE_DURATION = ", CLAIM_REWARDS_AT__PERCENTAGE_DURATION);

    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(REWARD_INITIAL_AMOUNT);
    verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);

    AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);
    BobStakes(BOB_STAKINGERC20_MINTEDAMOUNT);
    CherryStakes(CHERRY_STAKINGERC20_MINTEDAMOUNT);

    checkUsersStake();
    checkRewardPerToken(0, 0, 0);
    checkRewardForDuration(DELTA_0_00000000022);
    checkStakingTotalSupplyStaked();

    uint256 claimDelta = getClaimPercentDelta();
    uint256 rewardsPercentDelta = getRewardPercentDelta();
    uint8 rewardsUnitsDelta = getRewardUnitsDelta();

    uint256 stakingElapsedTime;
    uint256 stakingPercentageDurationReached;
    uint256 userAliceExpectedRewards;
    uint256 userBobExpectedRewards;
    uint256 userCherryExpectedRewards;
    uint256 userAliceClaimedRewards;
    uint256 userBobClaimedRewards;
    uint256 userCherryClaimedRewards;

    if (CLAIM_REWARDS_AT__PERCENTAGE_DURATION > 0) {
      gotoStakingPercentage(CLAIM_REWARDS_AT__PERCENTAGE_DURATION);
      userAliceClaimedRewards =
        checkUserClaimFromRewardsStart(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", claimDelta, rewardErc20);
      debugLog("testUsersStakingRewards: userAliceClaimedRewards = ", userAliceClaimedRewards);
      userBobClaimedRewards =
        checkUserClaimFromRewardsStart(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", claimDelta, rewardErc20);
      debugLog("testUsersStakingRewards: userBobClaimedRewards = ", userBobClaimedRewards);
      userCherryClaimedRewards = checkUserClaimFromRewardsStart(
        userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry", claimDelta, rewardErc20
      );
      debugLog("testUsersStakingRewards: userCherryClaimedRewards = ", userCherryClaimedRewards);
    }

    stakingPercentageDurationReached = CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION / DIVIDE;
    verboseLog(
      "Staking duration (%%) = CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION / DIVIDE  : ",
      stakingPercentageDurationReached
    );
    gotoStakingPercentage(stakingPercentageDurationReached);
    stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
    debugLog("stakingElapsedTime = ", stakingElapsedTime);
    checkStakingPeriod(stakingPercentageDurationReached);

    verboseLog("Staking duration reached (%%) before withdrawal(s) = : ", stakingPercentageDurationReached);

    // Users withdraws all

    userAliceExpectedRewards =
      expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
    debugLog("testUsersStakingRewards: userAliceExpectedRewards = ", userAliceExpectedRewards);
    userAliceExpectedRewards -= userAliceClaimedRewards;
    debugLog("testUsersStakingRewards: userAliceExpectedRewards = ", userAliceExpectedRewards);

    userBobExpectedRewards =
      expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
    debugLog("testUsersStakingRewards: userBobExpectedRewards = ", userBobExpectedRewards);
    userBobExpectedRewards -= userBobClaimedRewards;
    debugLog("testUsersStakingRewards: userBobExpectedRewards = ", userBobExpectedRewards);

    userCherryExpectedRewards =
      expectedStakingRewards(CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
    debugLog("testUsersStakingRewards: userCherryExpectedRewards = ", userCherryExpectedRewards);
    userCherryExpectedRewards -= userCherryClaimedRewards;
    debugLog("testUsersStakingRewards: userCherryExpectedRewards = ", userCherryExpectedRewards);

    uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN_18
      / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;
    debugLog("expectedRewardPerToken = ", expectedRewardPerToken);

    // Alice withdraws all
    AliceUnstakes(ALICE_STAKINGERC20_STAKEDAMOUNT);
    // Bob withdraws all
    BobUnstakes(BOB_STAKINGERC20_STAKEDAMOUNT);
    // Cherry withdraws all
    CherryUnstakes(CHERRY_STAKINGERC20_STAKEDAMOUNT);

    gotoStakingPercentage(CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION);
    checkRewardForDuration(DELTA_0_00000000022);

    debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
    debugLog(
      "Staking duration (%%) total staking reward duration = ",
      CHECK_REWARDS_AT__STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
    );

    checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, rewardsPercentDelta, rewardsUnitsDelta * 4);
    checkStakingRewards(userBob, "Bob", userBobExpectedRewards, rewardsPercentDelta, rewardsUnitsDelta * 2);
    checkStakingRewards(userCherry, "Cherry", userCherryExpectedRewards, rewardsPercentDelta, rewardsUnitsDelta * 2);

    checkRewardPerToken(expectedRewardPerToken, 0, 1);
    checkRewardForDuration(DELTA_0_00000000022);
  }
}

// --------------------------------------------------------
