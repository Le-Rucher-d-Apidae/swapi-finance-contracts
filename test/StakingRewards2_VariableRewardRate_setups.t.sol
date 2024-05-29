// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { StakingPreSetupErc20 } from "./StakingRewards2_commonbase.t.sol";
import {
    DELTA_0_00000000022,
    DELTA_0_015,
    DELTA_0_04,
    DELTA_0_31,
    DELTA_0_4,
    PERCENT_10,
    PERCENT_100,
    DELTA_0,
    ONE_TOKEN
} from "./TestsConstants.sol";

import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";

// ----------------

contract StakingPreSetup is StakingPreSetupErc20 {
    // Rewards constants

    // Rewards program duration : see StakingPreSetupDuration

    // Variable rewards
    // Limit max LP tokens staked
    uint256 internal constant CONSTANT_REWARD_MAXTOTALSUPPLY_LP = 6; // Max LP : 6
    uint256 internal constant CONSTANT_REWARD_MAXTOTALSUPPLY = CONSTANT_REWARD_MAXTOTALSUPPLY_LP * ONE_TOKEN;

    uint256 internal constant APR = 10; // 10%
    uint256 internal constant APR_BASE = 100; // 100%

    // per second for one LP token
    uint256 internal constant CONSTANT_REWARDRATE_PERTOKENSTORED =
        ONE_TOKEN * APR / APR_BASE / REWARD_INITIAL_DURATION;
    // = 1e18 * 10 / 100 / 10 000 = 10 000 000 000 000 = 1e13

    function setUp() public virtual override {
        debugLog("StakingSetup setUp() start");

        if (REWARD_INITIAL_DURATION == 0) {
            fail("StakingSetup: REWARD_INITIAL_DURATION is 0");
        }

        StakingPreSetupErc20.setUp();

        // Max. budget for rewards
        REWARD_INITIAL_AMOUNT = CONSTANT_REWARD_MAXTOTALSUPPLY * APR / APR_BASE;

        debugLog("StakingSetup APR = ", APR);
        debugLog("StakingSetup APR_BASE = ", APR_BASE);
        debugLog("StakingSetup CONSTANT_REWARD_MAXTOTALSUPPLY_LP  = ", CONSTANT_REWARD_MAXTOTALSUPPLY_LP);
        debugLog("StakingSetup CONSTANT_REWARD_MAXTOTALSUPPLY     = ", CONSTANT_REWARD_MAXTOTALSUPPLY);
        debugLog("StakingSetup CONSTANT_REWARDRATE_PERTOKENSTORED = ", CONSTANT_REWARDRATE_PERTOKENSTORED);
        debugLog("StakingSetup REWARD_INITIAL_AMOUNT              = ", REWARD_INITIAL_AMOUNT);

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

    // Each STAKER has the same CONSTANT reward rate
    // Global reward rate is VARIABLE
    // All budget might NOT be spent during the reward duration
    // But checkRewardForDuration should return the same amount as the initial budget
    function checkRewardForDuration(uint256 _delta) internal virtual override {
        debugLog("StakingPreSetupVRR: checkRewardForDuration");
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
        verboseLog("StakingPreSetup:expectedStakingRewards: rewardsDuration= ", rewardsDuration);
        uint256 expectedStakingRewardsAmount =
            CONSTANT_REWARDRATE_PERTOKENSTORED * _stakedAmount / ONE_TOKEN * rewardsDuration;
        verboseLog(
            "StakingPreSetup:expectedStakingRewards: expectedStakingRewardsAmount= ", expectedStakingRewardsAmount
        );
        return expectedStakingRewardsAmount;
    }
} // StakingPreSetup

// ----------------------------------------------------------------------------

contract DuringStakingVariableRewardRate1WithoutWithdral is StakingPreSetup {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStakingVariableRewardRate1WithoutWithdral setUp() start");
        StakingPreSetup.setUp();
        verboseLog("DuringStakingVariableRewardRate1WithoutWithdral");
        debugLog("DuringStakingVariableRewardRate1WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
    }

    function testUsersStakingRewards() public {
        vm.prank(userStakingRewardAdmin);
        notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);

        debugLog("Staking start time", STAKING_START_TIMESTAMP);

        AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);

        checkUsersStake();
        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed
        checkRewardForDuration(DELTA_0_00000000022);
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceTotalExpectedRewards;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPercentage(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
        }

        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog("Staking duration reached (100%%=1e18) : ", STAKING_PERCENTAGE_DURATION);
        debugLog("Staking duration reached (100%%     ) :  1000000000000000000");
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );
        checkUsersStake();
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION);

        userAliceTotalExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards = userAliceTotalExpectedRewards - userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);

        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed

        verboseLog("-----------------------------------------");
        verboseLog("Alice Total Expected Rewards  : ", userAliceTotalExpectedRewards);
        verboseLog("Alice claimed                 : ", userAliceClaimedRewards);
        verboseLog("Alice expected remaining      : ", userAliceExpectedRewards);
        verboseLog("-----------------------------------------");
    }
}

// ------------------------------------

contract DuringStakingVariableRewardRate2WithoutWithdral is StakingPreSetup {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStakingVariableRewardRate2WithoutWithdral setUp() start");
        StakingPreSetup.setUp();
        verboseLog("DuringStakingVariableRewardRate2WithoutWithdral");
        debugLog("DuringStakingVariableRewardRate2WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
    }

    function testUsersStakingRewards() public {
        vm.prank(userStakingRewardAdmin);
        notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);
        verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);

        AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);
        BobStakes(BOB_STAKINGERC20_MINTEDAMOUNT);

        checkUsersStake();
        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0);
        checkRewardForDuration(DELTA_0_00000000022);
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceTotalExpectedRewards;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobTotalExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userBobClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPercentage(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015, rewardErc20);
        }

        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("Staking duration reached (100%%=1e18) : ", STAKING_PERCENTAGE_DURATION);
        debugLog("Staking duration reached (100%%     ) :  1000000000000000000");
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );
        checkUsersStake();
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION);

        userAliceTotalExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards = userAliceTotalExpectedRewards - userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0_31, 0);

        userBobTotalExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userBobExpectedRewards = userBobTotalExpectedRewards - userBobClaimedRewards;
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, DELTA_0_31, 0);

        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed

        verboseLog("-----------------------------------------");
        verboseLog("Alice Total Expected Rewards  : ", userAliceTotalExpectedRewards);
        verboseLog("Alice claimed                 : ", userAliceClaimedRewards);
        verboseLog("Alice expected remaining      : ", userAliceExpectedRewards);
        verboseLog("Bob Total Expected Rewards    : ", userBobTotalExpectedRewards);
        verboseLog("Bob claimed                   : ", userBobClaimedRewards);
        verboseLog("Bob expected remaining        : ", userBobExpectedRewards);
        verboseLog("-----------------------------------------");
    }
}

// ------------------------------------

contract DuringStakingVariableRewardRate3WithoutWithdral is StakingPreSetup {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStakingVariableRewardRate3WithoutWithdral setUp() start");
        StakingPreSetup.setUp();
        verboseLog("DuringStakingVariableRewardRate3WithoutWithdral");
        debugLog("DuringStakingVariableRewardRate3WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
        checkCherryStake();
    }

    function testUsersStakingRewards() public {
        vm.prank(userStakingRewardAdmin);
        notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);
        verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);

        AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);
        BobStakes(BOB_STAKINGERC20_MINTEDAMOUNT);
        CherryStakes(CHERRY_STAKINGERC20_MINTEDAMOUNT);

        checkUsersStake();
        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0);
        checkRewardForDuration(DELTA_0_00000000022);
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;

        uint256 userAliceTotalExpectedRewards;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;

        uint256 userBobTotalExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userBobClaimedRewards;

        uint256 userCherryTotalExpectedRewards;
        uint256 userCherryExpectedRewards;
        uint256 userCherryClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPercentage(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015, rewardErc20);
            userCherryClaimedRewards =
                checkUserClaim(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry", DELTA_0_015, rewardErc20);
        }

        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("Staking duration reached (100%%=1e18) : ", STAKING_PERCENTAGE_DURATION);
        debugLog("Staking duration reached (100%%     ) :  1000000000000000000");
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );
        checkUsersStake();
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION);

        userAliceTotalExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards = userAliceTotalExpectedRewards - userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0_31, 0);

        userBobTotalExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userBobExpectedRewards = userBobTotalExpectedRewards - userBobClaimedRewards;
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, DELTA_0_31, 0);

        userCherryTotalExpectedRewards =
            expectedStakingRewards(CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userCherryExpectedRewards = userCherryTotalExpectedRewards - userCherryClaimedRewards;
        checkStakingRewards(userCherry, "Cherry", userCherryExpectedRewards, DELTA_0_31, 0);

        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed

        verboseLog("-----------------------------------------");
        verboseLog("Alice Total Expected Rewards  : ", userAliceTotalExpectedRewards);
        verboseLog("Alice claimed                 : ", userAliceClaimedRewards);
        verboseLog("Alice expected remaining      : ", userAliceExpectedRewards);
        verboseLog("Bob Total Expected Rewards    : ", userBobTotalExpectedRewards);
        verboseLog("Bob claimed                   : ", userBobClaimedRewards);
        verboseLog("Bob expected remaining        : ", userBobExpectedRewards);
        verboseLog("Cherry Total Expected Rewards : ", userCherryTotalExpectedRewards);
        verboseLog("Cherry claimed                : ", userCherryClaimedRewards);
        verboseLog("Cherry expected remaining     : ", userCherryExpectedRewards);
        verboseLog("-----------------------------------------");
    }
}

// ------------------------------------

// 1 staker deposit right after staking starts and removes all staked amount after half of staking percentage duration

contract DuringStakingVariableRewardRate1WithWithdral is StakingPreSetup {
    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 internal immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computation will underflow
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail(
                "DuringStakingVariableRewardRate1WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION"
                " / DIVIDE"
            );
        }
    }

    function setUp() public override {
        debugLog("DuringStakingVariableRewardRate1WithWithdral setUp() start");
        StakingPreSetup.setUp();
        verboseLog("DuringStakingVariableRewardRate1WithWithdral");
        debugLog("DuringStakingVariableRewardRate1WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
    }

    function testUsersStakingRewards() public {
        vm.prank(userStakingRewardAdmin);
        notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);
        verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);

        AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);

        checkUsersStake();
        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0);
        checkRewardForDuration(DELTA_0_00000000022);
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 stakingPercentageDurationReached;

        uint256 userAliceTotalExpectedRewards;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;
        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPercentage(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
        }

        stakingPercentageDurationReached = STAKING_PERCENTAGE_DURATION / DIVIDE;
        gotoStakingPercentage(stakingPercentageDurationReached);

        stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("Staking duration reached (100%%=1e18) : ", stakingPercentageDurationReached);
        debugLog("Staking duration reached (100%%     ) :  1000000000000000000");
        debugLog(
            "reward duration (%%) of total staking reward duration = ",
            getRewardDurationReached(stakingPercentageDurationReached)
        );
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            // STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
            stakingPercentageDurationReached * REWARD_INITIAL_DURATION / PERCENT_100
        );
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);

        // Users withdraws all

        userAliceTotalExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards = userAliceTotalExpectedRewards - userAliceClaimedRewards;

        // Alice withdraws all
        // withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        AliceUnstakes(ALICE_STAKINGERC20_STAKEDAMOUNT);

        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (100%%=1e18) : ", STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (100%%     ) :  1000000000000000000");

        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);

        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed

        verboseLog("-----------------------------------------");
        verboseLog("Alice Total Expected Rewards  : ", userAliceTotalExpectedRewards);
        verboseLog("Alice claimed                 : ", userAliceClaimedRewards);
        verboseLog("Alice expected remaining      : ", userAliceExpectedRewards);
        verboseLog("-----------------------------------------");
    }
}

// ------------------------------------

// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

contract DuringStakingVariableRewardRate2WithWithdral is StakingPreSetup {
    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 internal immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computation will underflow
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail(
                "DuringStakingVariableRewardRate2WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION"
                " / DIVIDE"
            );
        }
    }

    function setUp() public override {
        debugLog("DuringStakingVariableRewardRate2WithWithdral setUp() start");
        StakingPreSetup.setUp();
        verboseLog("DuringStakingVariableRewardRate2WithWithdral");
        debugLog("DuringStakingVariableRewardRate2WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
    }

    function testUsersStakingRewards() public {
        vm.prank(userStakingRewardAdmin);
        notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);
        verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);

        AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);
        BobStakes(BOB_STAKINGERC20_MINTEDAMOUNT);
        checkUsersStake();
        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0);
        checkRewardForDuration(DELTA_0_00000000022);
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 stakingPercentageDurationReached;

        uint256 userAliceTotalExpectedRewards;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobTotalExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userBobClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPercentage(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015, rewardErc20);
        }

        stakingPercentageDurationReached = STAKING_PERCENTAGE_DURATION / DIVIDE;
        gotoStakingPercentage(stakingPercentageDurationReached);

        stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        checkStakingPeriod(stakingPercentageDurationReached);

        debugLog("Staking duration reached (100%%=1e18) : ", stakingPercentageDurationReached);
        debugLog("Staking duration reached (100%%     ) :  1000000000000000000");
        debugLog(
            "reward duration (%%) of total staking reward duration = ",
            getRewardDurationReached(stakingPercentageDurationReached)
        );
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            stakingPercentageDurationReached * REWARD_INITIAL_DURATION / PERCENT_100
        );

        // Users withdraws all
        userAliceTotalExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards = userAliceTotalExpectedRewards - userAliceClaimedRewards;

        userBobTotalExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userBobExpectedRewards = userBobTotalExpectedRewards - userBobClaimedRewards;

        // Alice withdraws all
        // withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        AliceUnstakes(ALICE_STAKINGERC20_STAKEDAMOUNT);

        // Bob withdraws all
        // withdrawStake(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);
        BobUnstakes(BOB_STAKINGERC20_STAKEDAMOUNT);

        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (100%%=1e18) : ", STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (100%%     ) :  1000000000000000000");

        // Longer staking period = better accuracy : less delta
        uint256 delta = STAKING_PERCENTAGE_DURATION < PERCENT_10 ? DELTA_0_4 : DELTA_0_04;

        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, delta, 0);

        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed

        verboseLog("-----------------------------------------");
        verboseLog("Alice Total Expected Rewards  : ", userAliceTotalExpectedRewards);
        verboseLog("Alice claimed                 : ", userAliceClaimedRewards);
        verboseLog("Alice expected remaining      : ", userAliceExpectedRewards);
        verboseLog("Bob Total Expected Rewards    : ", userBobTotalExpectedRewards);
        verboseLog("Bob claimed                   : ", userBobClaimedRewards);
        verboseLog("Bob expected remaining        : ", userBobExpectedRewards);
        verboseLog("-----------------------------------------");
    }
}

// ------------------------------------

// 3 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

contract DuringStakingVariableRewardRate3WithWithdral is StakingPreSetup {
    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 internal immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computation will underflow
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail(
                "DuringStakingVariableRewardRate3WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION"
                " / DIVIDE"
            );
        }
    }

    function setUp() public override {
        debugLog("DuringStakingVariableRewardRate3WithWithdral setUp() start");
        StakingPreSetup.setUp();
        verboseLog("DuringStakingVariableRewardRate3WithWithdral");
        debugLog("DuringStakingVariableRewardRate3WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
        checkCherryStake();
    }

    function testUsersStakingRewards() public {
        vm.prank(userStakingRewardAdmin);
        notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);
        verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);

        AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);
        BobStakes(BOB_STAKINGERC20_MINTEDAMOUNT);
        CherryStakes(CHERRY_STAKINGERC20_MINTEDAMOUNT);

        checkUsersStake();
        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0);
        checkRewardForDuration(DELTA_0_00000000022);
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 stakingPercentageDurationReached;

        uint256 userAliceTotalExpectedRewards;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobTotalExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userBobClaimedRewards;
        uint256 userCherryTotalExpectedRewards;
        uint256 userCherryExpectedRewards;
        uint256 userCherryClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPercentage(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015, rewardErc20);
            userCherryClaimedRewards =
                checkUserClaim(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry", DELTA_0_015, rewardErc20);
        }

        stakingPercentageDurationReached = STAKING_PERCENTAGE_DURATION / DIVIDE;
        gotoStakingPercentage(stakingPercentageDurationReached);

        stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("Staking duration reached (100%%=1e18) : ", stakingPercentageDurationReached);
        debugLog("Staking duration reached (100%%     ) :  1000000000000000000");
        debugLog(
            "reward duration (%%) of total staking reward duration = ",
            getRewardDurationReached(stakingPercentageDurationReached)
        );
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            stakingPercentageDurationReached * REWARD_INITIAL_DURATION / PERCENT_100
        );
        checkStakingPeriod(stakingPercentageDurationReached);

        // Users withdraws all

        userAliceTotalExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards = userAliceTotalExpectedRewards - userAliceClaimedRewards;
        userBobTotalExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userBobExpectedRewards = userBobTotalExpectedRewards - userBobClaimedRewards;
        userCherryTotalExpectedRewards =
            expectedStakingRewards(CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userCherryExpectedRewards = userCherryTotalExpectedRewards - userCherryClaimedRewards;

        // Alice withdraws all
        // withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        AliceUnstakes(ALICE_STAKINGERC20_STAKEDAMOUNT);

        // Bob withdraws all
        // withdrawStake(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);
        BobUnstakes(BOB_STAKINGERC20_STAKEDAMOUNT);

        // Cherry withdraws all
        // withdrawStake(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT);
        CherryUnstakes(CHERRY_STAKINGERC20_STAKEDAMOUNT);

        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (100%%=1e18) : ", STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (100%%     ) :  1000000000000000000");

        // Longer staking period = better accuracy : less delta
        uint256 delta = STAKING_PERCENTAGE_DURATION < PERCENT_10 ? DELTA_0_4 : DELTA_0_04;

        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, delta, 0);
        checkStakingRewards(userCherry, "Cherry", userCherryExpectedRewards, delta, 0);

        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed

        verboseLog("-----------------------------------------");
        verboseLog("Alice Total Expected Rewards  : ", userAliceTotalExpectedRewards);
        verboseLog("Alice claimed                 : ", userAliceClaimedRewards);
        verboseLog("Alice expected remaining      : ", userAliceExpectedRewards);
        verboseLog("Bob Total Expected Rewards    : ", userBobTotalExpectedRewards);
        verboseLog("Bob claimed                   : ", userBobClaimedRewards);
        verboseLog("Bob expected remaining        : ", userBobExpectedRewards);
        verboseLog("Cherry Total Expected Rewards : ", userCherryTotalExpectedRewards);
        verboseLog("Cherry claimed                : ", userCherryClaimedRewards);
        verboseLog("Cherry expected remaining     : ", userCherryExpectedRewards);
        verboseLog("-----------------------------------------");
    }
}

// ----------------------------------------------------------------------------
