// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { StakingPreSetup, Erc20Setup1, Erc20Setup2, Erc20Setup3 } from "./StakingRewards2_base.t.sol";
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

abstract contract StakingPreSetupVRR is StakingPreSetup {
    // // Rewards constants

    // Variable rewards
    // Limit max LP tokens staked
    uint256 internal constant CONSTANT_REWARD_MAXTOTALSUPPLY_LP = 6; // Max LP : 6
    uint256 internal constant CONSTANT_REWARD_MAXTOTALSUPPLY = CONSTANT_REWARD_MAXTOTALSUPPLY_LP * ONE_TOKEN;
    // uint256 internal constant CONSTANT_REWARDRATE_PERTOKENSTORED = 1e3; // 1 000 ; for each LP token earn 1 000
    // reward
    // uint256 internal constant CONSTANT_REWARDRATE = 1e3; // 1 000 ; for each LP token earn 1 000 reward

    uint256 internal constant APR = 10; // 10%
    uint256 internal constant APR_BASE = 100; // 100%
    // uint256 internal constant CONSTANT_REWARDRATE_PERTOKENSTORED = 1e3 * ONE_TOKEN ; // 1 000 * 1e18 ; for each LP
    // token earn 1 000 reward
    // uint256 internal constant REWARD_AMOUNT = CONSTANT_REWARD_MAXTOTALSUPPLY * APR / APR_BASE; // 10% of max supply
    // during reward duration

    // per second for one LP token
    uint256 internal constant CONSTANT_REWARDRATE_PERTOKENSTORED =
        ONE_TOKEN * APR / APR_BASE / REWARD_INITIAL_DURATION;
    // = 1e18 * 10 / 100 / 10 000 = 10 000 000 000 000 = 1e13

    function setUp() public virtual override {
        debugLog("StakingPreSetupCRR setUp() start");
        // Max. budget for rewards
        // REWARD_INITIAL_AMOUNT =
        //     CONSTANT_REWARDRATE_PERTOKENSTORED * CONSTANT_REWARD_MAXTOTALSUPPLY * REWARD_INITIAL_DURATION;
        REWARD_INITIAL_AMOUNT = CONSTANT_REWARD_MAXTOTALSUPPLY * APR / APR_BASE;
        // allocated to rewards

        debugLog("StakingPreSetupCRR APR = ", APR);
        debugLog("StakingPreSetupCRR APR_BASE = ", APR_BASE);
        debugLog("StakingPreSetupCRR CONSTANT_REWARD_MAXTOTALSUPPLY_LP  = ", CONSTANT_REWARD_MAXTOTALSUPPLY_LP);
        debugLog("StakingPreSetupCRR CONSTANT_REWARD_MAXTOTALSUPPLY     = ", CONSTANT_REWARD_MAXTOTALSUPPLY);
        debugLog("StakingPreSetupCRR CONSTANT_REWARDRATE_PERTOKENSTORED = ", CONSTANT_REWARDRATE_PERTOKENSTORED);
        debugLog("StakingPreSetupCRR REWARD_INITIAL_AMOUNT              = ", REWARD_INITIAL_AMOUNT);

        if (REWARD_INITIAL_DURATION == 0) {
            fail("StakingPreSetupCRR: REWARD_INITIAL_DURATION is 0");
        }
        if (REWARD_INITIAL_AMOUNT < REWARD_INITIAL_DURATION) {
            errorLog("REWARD_INITIAL_AMOUNT", REWARD_INITIAL_AMOUNT);
            errorLog("REWARD_INITIAL_DURATION", REWARD_INITIAL_DURATION);
            fail("StakingPreSetupCRR: REWARD_INITIAL_AMOUNT < REWARD_INITIAL_DURATION");
        }
        verboseLog("StakingPreSetupCRR setUp()");
        debugLog("StakingPreSetupCRR setUp() end");
    }

    // Each STAKER has the same CONSTANT reward rate
    // Global reward rate is VARIABLE
    // All budget might NOT be spent during the reward duration
    // But checkRewardForDuration should return the same amount as the initial budget
    function checkRewardForDuration(uint256 _delta) internal virtual override {
        debugLog("StakingPreSetupVRR: checkRewardForDuration");
        _checkRewardForDuration(_delta);
    }
}

contract StakingSetup is StakingPreSetupVRR {
    function setUp() public virtual override {
        debugLog("StakingSetup setUp() start");
        StakingPreSetupVRR.setUp();
        verboseLog("StakingSetup setUp()");
        debugLog("StakingSetup setUp() end");
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
        uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);
        verboseLog("expectedStakingRewards: rewardsDuration= ", rewardsDuration);
        uint256 expectedStakingRewardsAmount =
            CONSTANT_REWARDRATE_PERTOKENSTORED * _stakedAmount / ONE_TOKEN * rewardsDuration;
        verboseLog("expectedStakingRewards: expectedStakingRewardsAmount= ", expectedStakingRewardsAmount);
        return expectedStakingRewardsAmount;
    }
}

contract StakingSetup1 is Erc20Setup1, StakingSetup {
    uint256 internal constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;

    function setUp() public virtual override(Erc20Setup1, StakingSetup) {
        debugLog("StakingSetup1 setUp() start");
        verboseLog("StakingSetup1");
        Erc20Setup1.setUp();
        StakingSetup.setUp();
        vm.prank(userStakingRewardAdmin);
        stakingRewards2 = new StakingRewards2(address(rewardErc20), address(stakingERC20));
        assertEq(userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner");

        vm.prank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_INITIAL_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_INITIAL_AMOUNT);

        vm.prank(userStakingRewardAdmin);

        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(CONSTANT_REWARD_MAXTOTALSUPPLY);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(CONSTANT_REWARDRATE_PERTOKENSTORED);
        notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);

        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup1 setUp() end");
    }

    function checkAliceStake() internal {
        itStakesCorrectly(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice");
    }
}

// ----------------

contract StakingSetup2 is Erc20Setup2, StakingSetup {
    uint256 internal constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;
    uint256 internal constant BOB_STAKINGERC20_STAKEDAMOUNT = BOB_STAKINGERC20_MINTEDAMOUNT;

    function setUp() public virtual override(Erc20Setup2, StakingSetup) {
        debugLog("StakingSetup2 setUp() start");
        verboseLog("StakingSetup2");
        Erc20Setup2.setUp();
        StakingSetup.setUp();
        vm.prank(userStakingRewardAdmin);
        stakingRewards2 = new StakingRewards2(address(rewardErc20), address(stakingERC20));
        assertEq(userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner");

        // checkOnlyAddressCanInvoke( userStakingRewardAdmin, address[](users), address(stakingRewards2),
        // bytes4(keccak256("setRewardsDuration")) );

        vm.prank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_INITIAL_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);

        // console.log("StakingSetup2 setUp() mint REWARD_INITIAL_AMOUNT to contract", REWARD_INITIAL_AMOUNT);
        rewardErc20.mint(address(stakingRewards2), REWARD_INITIAL_AMOUNT);

        vm.prank(userStakingRewardAdmin);

        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(CONSTANT_REWARD_MAXTOTALSUPPLY);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(CONSTANT_REWARDRATE_PERTOKENSTORED);

        notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);

        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup2 setUp() end");
    }

    function checkAliceStake() internal {
        itStakesCorrectly(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice");
    }

    function checkBobStake() internal {
        itStakesCorrectly(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob");
    }
}

// ----------------

contract StakingSetup3 is Erc20Setup3, StakingSetup {
    uint256 internal constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;
    uint256 internal constant BOB_STAKINGERC20_STAKEDAMOUNT = BOB_STAKINGERC20_MINTEDAMOUNT;
    uint256 internal constant CHERRY_STAKINGERC20_STAKEDAMOUNT = CHERRY_STAKINGERC20_MINTEDAMOUNT;

    function setUp() public virtual override(Erc20Setup3, StakingSetup) {
        // console.log("StakingSetup3 setUp()");
        debugLog("StakingSetup3 setUp() start");
        verboseLog("StakingSetup3");
        Erc20Setup3.setUp();
        StakingSetup.setUp();
        vm.prank(userStakingRewardAdmin);
        stakingRewards2 = new StakingRewards2(address(rewardErc20), address(stakingERC20));
        assertEq(userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner");

        // checkOnlyAddressCanInvoke( userStakingRewardAdmin, address[](users), address(stakingRewards2),
        // bytes4(keccak256("setRewardsDuration")) );

        vm.prank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_INITIAL_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_INITIAL_AMOUNT);

        vm.prank(userStakingRewardAdmin);

        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(CONSTANT_REWARD_MAXTOTALSUPPLY);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(CONSTANT_REWARDRATE_PERTOKENSTORED);

        notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);

        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup3 setUp() end");
    }

    function checkAliceStake() internal {
        itStakesCorrectly(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice");
    }

    function checkBobStake() internal {
        itStakesCorrectly(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob");
    }

    function checkCherryStake() internal {
        itStakesCorrectly(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry");
    }
}

// ------------------------------------

contract DepositSetup1 is StakingSetup1 {
    // uint256 constant internal TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT;

    function setUp() public virtual override {
        debugLog("DepositSetup1 setUp() start");
        verboseLog("DepositSetup1 setUp()");
        StakingSetup1.setUp();
        vm.startPrank(userAlice);
        stakingERC20.approve(address(stakingRewards2), ALICE_STAKINGERC20_STAKEDAMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        stakingRewards2.stake(ALICE_STAKINGERC20_STAKEDAMOUNT);
        vm.stopPrank();
        TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT;
        debugLog("DepositSetup1 setUp() end");
    }
}

// ----------------

contract DepositSetup2 is StakingSetup2 {
    function setUp() public virtual override {
        debugLog("DepositSetup2 setUp() start");
        verboseLog("DepositSetup2 setUp()");
        StakingSetup2.setUp();
        vm.startPrank(userAlice);
        stakingERC20.approve(address(stakingRewards2), ALICE_STAKINGERC20_STAKEDAMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        stakingRewards2.stake(ALICE_STAKINGERC20_STAKEDAMOUNT);
        vm.startPrank(userBob);
        stakingERC20.approve(address(stakingRewards2), BOB_STAKINGERC20_STAKEDAMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);
        stakingRewards2.stake(BOB_STAKINGERC20_STAKEDAMOUNT);
        vm.stopPrank();
        TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT + BOB_STAKINGERC20_STAKEDAMOUNT;
        debugLog("DepositSetup2 setUp() end");
    }
}

// ----------------

contract DepositSetup3 is StakingSetup3 {
    function setUp() public virtual override {
        debugLog("DepositSetup3 setUp() start");
        verboseLog("DepositSetup3 setUp()");
        StakingSetup3.setUp();
        vm.startPrank(userAlice);
        stakingERC20.approve(address(stakingRewards2), ALICE_STAKINGERC20_STAKEDAMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        stakingRewards2.stake(ALICE_STAKINGERC20_STAKEDAMOUNT);
        vm.startPrank(userBob);
        stakingERC20.approve(address(stakingRewards2), BOB_STAKINGERC20_STAKEDAMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);
        stakingRewards2.stake(BOB_STAKINGERC20_STAKEDAMOUNT);
        vm.startPrank(userCherry);
        stakingERC20.approve(address(stakingRewards2), CHERRY_STAKINGERC20_STAKEDAMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT);
        stakingRewards2.stake(CHERRY_STAKINGERC20_STAKEDAMOUNT);
        vm.stopPrank();
        TOTAL_STAKED_AMOUNT =
            ALICE_STAKINGERC20_STAKEDAMOUNT + BOB_STAKINGERC20_STAKEDAMOUNT + CHERRY_STAKINGERC20_STAKEDAMOUNT;
        debugLog("DepositSetup3 setUp() end");
    }
}

// ----------------------------------------------------------------------------

contract DuringStakingVariableRewardRate1WithoutWithdral is DepositSetup1 {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration,
        // "DuringStakingVariableRewardRate1WithoutWithdral:
        // _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStakingVariableRewardRate1WithoutWithdral setUp() start");
        DepositSetup1.setUp();
        verboseLog("DuringStakingVariableRewardRate1WithoutWithdral");
        debugLog("DuringStakingVariableRewardRate1WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
        checkUsersStake();
        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed
        checkRewardForDuration(DELTA_0_00000000022);
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceTotalExpectedRewards;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
        }

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
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

contract DuringStakingVariableRewardRate2WithoutWithdral is DepositSetup2 {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration,
        // "DuringStakingVariableRewardRate2WithoutWithdral:
        // _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStakingVariableRewardRate2WithoutWithdral setUp() start");
        DepositSetup2.setUp();
        verboseLog("DuringStakingVariableRewardRate2WithoutWithdral");
        debugLog("DuringStakingVariableRewardRate2WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
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
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015, rewardErc20);
        }

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
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

contract DuringStakingVariableRewardRate3WithoutWithdral is DepositSetup3 {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration,
        // "DuringStakingVariableRewardRate3WithoutWithdral:
        // _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStakingVariableRewardRate3WithoutWithdral setUp() start");
        DepositSetup3.setUp();
        verboseLog("DuringStakingVariableRewardRate3WithoutWithdral");
        debugLog("DuringStakingVariableRewardRate3WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
        checkCherryStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
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
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015, rewardErc20);
            userCherryClaimedRewards =
                checkUserClaim(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry", DELTA_0_015, rewardErc20);
        }

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
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

contract DuringStakingVariableRewardRate1WithWithdral is DepositSetup1 {
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
        DepositSetup1.setUp();
        verboseLog("DuringStakingVariableRewardRate1WithWithdral");
        debugLog("DuringStakingVariableRewardRate1WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
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
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            // uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN
            // / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;
            // checkRewardPerToken( expectedRewardPerToken, 0, 0 ); // no delta needed
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
        }

        stakingPercentageDurationReached = STAKING_PERCENTAGE_DURATION / DIVIDE;
        gotoStakingPeriod(stakingPercentageDurationReached);

        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
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

        // Alice withdraws all
        withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (100%%=1e18) : ", STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (100%%     ) :  1000000000000000000");

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
// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

contract DuringStakingVariableRewardRate2WithWithdral is DepositSetup2 {
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
        DepositSetup2.setUp();
        verboseLog("DuringStakingVariableRewardRate2WithWithdral");
        debugLog("DuringStakingVariableRewardRate2WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
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
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            // uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN
            // / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;
            // checkRewardPerToken( expectedRewardPerToken, 0, 0 ); // no delta needed
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015, rewardErc20);
        }

        stakingPercentageDurationReached = STAKING_PERCENTAGE_DURATION / DIVIDE;
        gotoStakingPeriod(stakingPercentageDurationReached);

        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
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

        checkStakingPeriod(stakingPercentageDurationReached);

        // Alice withdraws all
        withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);

        // Bob withdraws all
        withdrawStake(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (100%%=1e18) : ", STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (100%%     ) :  1000000000000000000");

        uint256 delta = STAKING_PERCENTAGE_DURATION < PERCENT_10 ? DELTA_0_4 : DELTA_0_04; // Longer staking period =
            // better accuracy : less delta

        userAliceTotalExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards = userAliceTotalExpectedRewards - userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);

        userBobTotalExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userBobExpectedRewards = userBobTotalExpectedRewards - userBobClaimedRewards;
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

contract DuringStakingVariableRewardRate3WithWithdral is DepositSetup3 {
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
        DepositSetup3.setUp();
        verboseLog("DuringStakingVariableRewardRate3WithWithdral");
        debugLog("DuringStakingVariableRewardRate3WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
        checkCherryStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
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
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            // uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN
            // / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;
            // checkRewardPerToken( expectedRewardPerToken, 0, 0 ); // no delta needed
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015, rewardErc20);
            userCherryClaimedRewards =
                checkUserClaim(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry", DELTA_0_015, rewardErc20);
        }

        stakingPercentageDurationReached = STAKING_PERCENTAGE_DURATION / DIVIDE;
        gotoStakingPeriod(stakingPercentageDurationReached);

        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
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
        checkStakingPeriod(stakingPercentageDurationReached);

        // Alice withdraws all
        withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);

        // Bob withdraws all
        withdrawStake(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);

        // Cherry withdraws all
        withdrawStake(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT);

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (100%%=1e18) : ", STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (100%%     ) :  1000000000000000000");

        uint256 delta = STAKING_PERCENTAGE_DURATION < PERCENT_10 ? DELTA_0_4 : DELTA_0_04; // Longer staking period =
            // better accuracy : less delta

        userAliceTotalExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards = userAliceTotalExpectedRewards - userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);

        userBobTotalExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userBobExpectedRewards = userBobTotalExpectedRewards - userBobClaimedRewards;
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, delta, 0);

        userCherryTotalExpectedRewards =
            expectedStakingRewards(CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userCherryExpectedRewards = userCherryTotalExpectedRewards - userCherryClaimedRewards;
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

// Permissions tests

// 7 tests
/*
contract CheckStakingPermissions2 is StakingSetup2 {
    function setUp() public virtual override {
        // console.log("CheckStakingPermissions2 setUp()");
        debugLog("CheckStakingPermissions2 setUp() start");
        StakingSetup2.setUp();
        debugLog("CheckStakingPermissions2 setUp() end");
    }

    function testStakingPause() public {
        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
        verboseLog("Only staking reward contract owner can pause");

        stakingRewards2.setPaused(true);
        assertEq(stakingRewards2.paused(), false);
        verboseLog("Staking contract: Alice can't pause");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));

        stakingRewards2.setPaused(true);
        assertEq(stakingRewards2.paused(), false);
        verboseLog("Staking contract: Bob can't pause");

        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit Pausable.Paused(userStakingRewardAdmin);
        stakingRewards2.setPaused(true);
        assertEq(stakingRewards2.paused(), true);
        verboseLog("Staking contract: Only owner can pause");
        verboseLog("Staking contract: Event Paused emitted");

        // Pausing again should not throw nor emit event and leave pause unchanged
        stakingRewards2.setPaused(true);
        // Check no event emitted ?
        assertEq(stakingRewards2.paused(), true);
        vm.stopPrank();

        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
        verboseLog("Only staking reward contract owner can unpause");

        stakingRewards2.setPaused(false);
        assertEq(stakingRewards2.paused(), true);
        verboseLog("Staking contract: Alice can't unpause");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));

        stakingRewards2.setPaused(false);
        assertEq(stakingRewards2.paused(), true);
        verboseLog("Staking contract: Bob can't unpause");

        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit Pausable.Unpaused(userStakingRewardAdmin);
        stakingRewards2.setPaused(false);
        assertEq(stakingRewards2.paused(), false);

        verboseLog("Staking contract: Only owner can unpause");
        verboseLog("Staking contract: Event Unpaused emitted");

        // Unausing again should not throw nor emit event and leave pause unchanged
        stakingRewards2.setPaused(false);
        // Check no event emitted ?
        assertEq(stakingRewards2.paused(), false);

        vm.stopPrank();
    }

    function testStakingNotifyVariableRewardAmountMin() public {
        verboseLog("Only staking reward contract owner can notifyVariableRewardAmount 1, 1");

        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));

        stakingRewards2.notifyVariableRewardAmount(1, 1);
        verboseLog("Staking contract: Alice can't notifyVariableRewardAmount");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));
        stakingRewards2.notifyVariableRewardAmount(1, 1);
        verboseLog("Staking contract: Bob can't notifyVariableRewardAmount");

        vm.prank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(1);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(1);
        stakingRewards2.notifyVariableRewardAmount(1, 1);
        verboseLog("Staking contract: Only owner can notifyVariableRewardAmount of ", 1);
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    function testStakingNotifyVariableRewardAmount0() public {
        verboseLog("Only staking reward contract owner can notifyVariableRewardAmount 0, 0");

        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));

        stakingRewards2.notifyVariableRewardAmount(0, 0);
        verboseLog("Staking contract: Alice can't notifyVariableRewardAmount");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));
        stakingRewards2.notifyVariableRewardAmount(0, 0);
        verboseLog("Staking contract: Bob can't notifyVariableRewardAmount");

        vm.prank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(1);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(0);
        stakingRewards2.notifyVariableRewardAmount(0, 0);
        verboseLog("Staking contract: Only owner can notifyVariableRewardAmount of ", 0);
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    function testStakingNotifyVariableRewardAmount() public {
        // vm.prank(erc20Minter);
        // rewardErc20.mint( address(stakingRewards2), REWARD_INITIAL_AMOUNT );

        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
        verboseLog("Only staking reward contract owner can notifyVariableRewardAmount");

        stakingRewards2.notifyVariableRewardAmount(1, 1);
        verboseLog("Staking contract: Alice can't notifyVariableRewardAmount");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));
        stakingRewards2.notifyVariableRewardAmount(1, 1);
        verboseLog("Staking contract: Bob can't notifyVariableRewardAmount");

        vm.prank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(CONSTANT_REWARD_MAXTOTALSUPPLY);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(CONSTANT_REWARDRATE_PERTOKENSTORED);
        stakingRewards2.notifyVariableRewardAmount(1, 1);
        verboseLog("Staking contract: Only owner can notifyVariableRewardAmount");
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    function testStakingNotifyVariableRewardAmountLimit1() public {
        vm.prank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(CONSTANT_REWARD_MAXTOTALSUPPLY);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(CONSTANT_REWARDRATE_PERTOKENSTORED);
stakingRewards2.notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);
        verboseLog(
            "Staking contract: Only owner can notifyVariableRewardAmount of ",
            CONSTANT_REWARDRATE_PERTOKENSTORED * CONSTANT_REWARD_MAXTOTALSUPPLY
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    function testStakingSetRewardsDurationAfterEpochEnd() public {
        // Previous reward epoch must have ended before setting a new duration
        vm.warp(STAKING_START_TIME + REWARD_INITIAL_DURATION + 1); // epoch ended

        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
        stakingRewards2.setRewardsDuration(1);
        verboseLog("Staking contract: Alice can't setRewardsDuration");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));
        stakingRewards2.setRewardsDuration(1);
        verboseLog("Staking contract: Bob can't setRewardsDuration");

        vm.prank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(1);
        stakingRewards2.setRewardsDuration(1);
        verboseLog("Staking contract: Owner can setRewardsDuration right after last epoch end");
        verboseLog("Staking contract: Event RewardsDurationUpdated emitted");
    }

    function testStakingSetRewardsDurationBeforeEpochEnd() public {
        // Previous reward epoch must have ended before setting a new duration

        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
        stakingRewards2.setRewardsDuration(1);
        verboseLog("Staking contract: Alice can't setRewardsDuration (OwnableUnauthorizedAccount)");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));
        stakingRewards2.setRewardsDuration(1);
        verboseLog("Staking contract: Bob can't setRewardsDuration (OwnableUnauthorizedAccount)");

        vm.prank(userStakingRewardAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(
                RewardPeriodInProgress.selector, block.timestamp, STAKING_START_TIME + REWARD_INITIAL_DURATION
            )
        );
        stakingRewards2.setRewardsDuration(1);
        verboseLog(
            "Staking contract: Owner can't setRewardsDuration before previous epoch end (RewardPeriodInProgress)"
        );

        // Previous reward epoch must have ended before setting a new duration
        vm.warp(STAKING_START_TIME + REWARD_INITIAL_DURATION); // epoch last time reward

        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
        stakingRewards2.setRewardsDuration(1);
        verboseLog(
            "Staking contract: Alice can't setRewardsDuration just before previous epoch end"
            " (OwnableUnauthorizedAccount)"
        );

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));
        stakingRewards2.setRewardsDuration(1);
        verboseLog(
            "Staking contract: Bob can't setRewardsDuration just before previous epoch end"
            " (OwnableUnauthorizedAccount)"
        );

        vm.prank(userStakingRewardAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(
                RewardPeriodInProgress.selector, block.timestamp, STAKING_START_TIME + REWARD_INITIAL_DURATION
            )
        );
        stakingRewards2.setRewardsDuration(1);
        verboseLog(
            "Staking contract: Owner can't setRewardsDuration just before previous epoch end (RewardPeriodInProgress)"
        );

        vm.stopPrank();
    }
}
*/
// Limits tests

// 2 tests

contract CheckStakingConstantRewardLimits1 is StakingSetup1 {
    function setUp() public virtual override {
        // console.log("CheckStakingPermissions2 setUp()");
        debugLog("CheckStakingConstantRewardLimits1 setUp() start");
        StakingSetup1.setUp();
        debugLog("CheckStakingConstantRewardLimits1 setUp() end");
    }

    // Test that the owner can notifyVariableRewardAmount with a reward max total supply amount that is just low
    // enough
    function testStakingNotifyVariableRewardAmountSuccess1() public {
        uint256 REWARD_AVAILABLE_AMOUNT = rewardErc20.balanceOf(address(stakingRewards2)); // Should be
            // REWARD_INITIAL_AMOUNT
        assert(REWARD_AVAILABLE_AMOUNT == REWARD_INITIAL_AMOUNT);

        // Find the MAXTOTALSUPPLY_EXTRA_OVERFLOW that will overflow the balance
        uint256 MAXTOTALSUPPLY_EXTRA_OVERFLOW = CONSTANT_REWARD_MAXTOTALSUPPLY;
        uint256 TOTAL_REWARD_PERTOKENSTORED = CONSTANT_REWARDRATE_PERTOKENSTORED * REWARD_INITIAL_DURATION;
        uint256 BALANCE_E18 = REWARD_INITIAL_AMOUNT * ONE_TOKEN;
        for (uint256 i = CONSTANT_REWARD_MAXTOTALSUPPLY;; i += REWARD_INITIAL_DURATION) {
            if (i * TOTAL_REWARD_PERTOKENSTORED > BALANCE_E18) {
                debugLog("testStakingNotifyVariableRewardAmountSuccess1: i   = ", i);
                MAXTOTALSUPPLY_EXTRA_OVERFLOW = i - CONSTANT_REWARD_MAXTOTALSUPPLY;
                break;
            }
        }
        uint256 MAXTOTALSUPPLY_EXTRA_OK = MAXTOTALSUPPLY_EXTRA_OVERFLOW - REWARD_INITIAL_DURATION;
        vm.prank(userStakingRewardAdmin);

        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(CONSTANT_REWARD_MAXTOTALSUPPLY + MAXTOTALSUPPLY_EXTRA_OK);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(CONSTANT_REWARDRATE_PERTOKENSTORED);

        stakingRewards2.notifyVariableRewardAmount(
            CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY + MAXTOTALSUPPLY_EXTRA_OK
        );

        verboseLog(
            "Staking contract: Only owner can notifyVariableRewardAmount of ",
            CONSTANT_REWARDRATE_PERTOKENSTORED * CONSTANT_REWARD_MAXTOTALSUPPLY
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    // Test that the owner can't notifyVariableRewardAmount with a reward max total supply amount that is too high
    function testStakingNotifyVariableRewardAmountFail1() public {
        uint256 REWARD_AVAILABLE_AMOUNT = rewardErc20.balanceOf(address(stakingRewards2)); // Should be
            // REWARD_INITIAL_AMOUNT
        assert(REWARD_AVAILABLE_AMOUNT == REWARD_INITIAL_AMOUNT);

        // Find the MAXTOTALSUPPLY_EXTRA_OVERFLOW that will overflow the balance
        uint256 MAXTOTALSUPPLY_EXTRA_OVERFLOW = CONSTANT_REWARD_MAXTOTALSUPPLY;
        uint256 TOTAL_REWARD_PERTOKENSTORED = CONSTANT_REWARDRATE_PERTOKENSTORED * REWARD_INITIAL_DURATION;
        uint256 BALANCE_E18 = REWARD_INITIAL_AMOUNT * ONE_TOKEN;
        for (uint256 i = CONSTANT_REWARD_MAXTOTALSUPPLY;; i += REWARD_INITIAL_DURATION) {
            if (i * TOTAL_REWARD_PERTOKENSTORED > BALANCE_E18) {
                debugLog("testStakingNotifyVariableRewardAmountFail1: i   = ", i);
                MAXTOTALSUPPLY_EXTRA_OVERFLOW = i - CONSTANT_REWARD_MAXTOTALSUPPLY;
                break;
            }
        }
        vm.prank(userStakingRewardAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                CONSTANT_REWARDRATE_PERTOKENSTORED, // constantRewardRatePerTokenStored
                CONSTANT_REWARD_MAXTOTALSUPPLY + MAXTOTALSUPPLY_EXTRA_OVERFLOW, // Max. total supply
                (
                    (CONSTANT_REWARD_MAXTOTALSUPPLY + MAXTOTALSUPPLY_EXTRA_OVERFLOW)
                        * CONSTANT_REWARDRATE_PERTOKENSTORED * REWARD_INITIAL_DURATION
                ),
                // Min. expected balance
                REWARD_INITIAL_AMOUNT // Current balance
            )
        );
        stakingRewards2.notifyVariableRewardAmount(
            CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY + MAXTOTALSUPPLY_EXTRA_OVERFLOW
        );

        verboseLog(
            "Staking contract: Only owner can notifyVariableRewardAmount of ",
            CONSTANT_REWARDRATE_PERTOKENSTORED * CONSTANT_REWARD_MAXTOTALSUPPLY
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    // Test that the owner can't notifyVariableRewardAmount with a reward RATE amount that is too high
    function testStakingNotifyVariableRewardAmountFail2() public {
        vm.prank(userStakingRewardAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                CONSTANT_REWARDRATE_PERTOKENSTORED + 1, // constantRewardRatePerTokenStored
                CONSTANT_REWARD_MAXTOTALSUPPLY, // Max. total supply
                (CONSTANT_REWARD_MAXTOTALSUPPLY * (CONSTANT_REWARDRATE_PERTOKENSTORED + 1) * REWARD_INITIAL_DURATION),
                // Min. expected balance
                REWARD_INITIAL_AMOUNT // Current balance
            )
        );
        stakingRewards2.notifyVariableRewardAmount(
            CONSTANT_REWARDRATE_PERTOKENSTORED + 1, CONSTANT_REWARD_MAXTOTALSUPPLY
        );

        verboseLog(
            "Staking contract: Only owner can notifyVariableRewardAmount of ",
            CONSTANT_REWARDRATE_PERTOKENSTORED * CONSTANT_REWARD_MAXTOTALSUPPLY
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }
} // CheckStakingConstantRewardLimits1

// 13 tests

contract CheckStakingConstantRewardLimits2 is StakingPreSetup, Erc20Setup1 {
    function setUp() public virtual override(Erc20Setup1, StakingPreSetup) {
        debugLog("CheckStakingConstantRewardLimits2 setUp() start");
        // verboseLog("StakingSetup");
        StakingPreSetup.setUp();
        Erc20Setup1.setUp();

        vm.prank(userStakingRewardAdmin);
        stakingRewards2 = new StakingRewards2(address(rewardErc20), address(stakingERC20));
        assertEq(userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner");

        debugLog("CheckStakingConstantRewardLimits2 setUp() end");
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

    function testStakingNotifyVariableRewardAmountFail0() public {
        // Test some arbitrary values
        // Smallest amount (1,1), 0 reward minted

        // Should mint 99 / 10^18 token as reward
        // vm.prank(erc20Minter);
        // rewardErc20.mint( address(stakingRewards2), 0 );
        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(100);
        stakingRewards2.setRewardsDuration(100); // 100 s.

        // Set 1 unit (1 = 10^-18) of token as reward per token deposit
        // and max deposit of 1 / 1^18 token

        // Check emitted events
        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                1, // constantRewardRatePerTokenStored
                1, // variableRewardMaxTotalSupply
                100, // Min. expected
                0 // Current balance
            )
        );
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        // available reward should be at least 1 * 1 * 100 = 100
        stakingRewards2.notifyVariableRewardAmount(1, 1);
        vm.stopPrank();
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    function testStakingNotifyVariableRewardAmountSuccess1() public {
        // Test some arbitrary values
        // Smallest amount (1,1), sufficient reward minted

        // Mint 100 / 10^18 token as reward
        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), 100);
        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(100);
        stakingRewards2.setRewardsDuration(100); // 100 s.

        // Set 1 unit (1 = 10^-18) of token as reward per token deposit
        // and max deposit of 1 / 1^18 token

        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(1);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(1);
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        stakingRewards2.notifyVariableRewardAmount(1, 1);
        vm.stopPrank();
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    function testStakingNotifyVariableRewardAmountFail1_1_x() public {
        // Test some arbitrary values
        // Smallest amount (1,1), unsufficient reward minted

        /* solhint-disable var-name-mixedcase */
        uint256 APR = 31_536_000; // 0,000 000 000 031 536 %
        uint256 APR_BASE = 1e18; // 100% = 1e18 = 1000000000000000000 = 1 000 000 000 000 000 000

        uint256 MAX_DEPOSIT_AMOUNT = 3_171_000_000_000; // 3171×1e9 = 3 171 000 000 000,00
        uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year

        uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT * APR / APR_BASE;
        // 317 100 000 000 000 * 31 536 000 / 1e18 = 100

        uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN * APR / APR_BASE) / REWARD_DURATION;
        // = 1e18 * 31 536 000 / 1e18 / 31 536 000 = 1

        // Mint 99 / 10^18 token as reward
        uint256 MINTED_REWARD_AMOUNT = REWARD_AMOUNT - 1; // 99
        /* solhint-enable var-name-mixedcase */

        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), MINTED_REWARD_AMOUNT);
        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_DURATION); // 100 s.

        // Revert: expected min. balance 100, current balance 99
        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                REWARD_PER_TOKEN_STORED, // constantRewardPerTokenStored
                MAX_DEPOSIT_AMOUNT, // variableRewardMaxTotalSupply
                MAX_DEPOSIT_AMOUNT * REWARD_PER_TOKEN_STORED * REWARD_DURATION, // Min. expected balance
                MINTED_REWARD_AMOUNT // Current reward balance
            )
        );
        // Set 1 unit (1 = 10^-18) of token as reward per token deposit
        // and max deposit of 1 / 1^18 token
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        // available reward should be at least 1 * 1 * 100 = 100
        stakingRewards2.notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);
        vm.stopPrank();
        verboseLog("Staking contract: Events MaxTotalSupply, ProvidedVariableRewardTooHigh emitted");
    }

    function testStakingNotifyVariableRewardAmountFail1_x_1() public {
        // Test some arbitrary values
        // Smallest amount (1,1), unsufficient reward minted

        /* solhint-disable var-name-mixedcase */
        uint256 APR = 31_536_000; // 31 536 000 % 🔥
        uint256 APR_BASE = 1; // 100% = 1 / 1e18

        uint256 MAX_DEPOSIT_AMOUNT = 1; // 1 / 1e18
        uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year

        uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT * APR / APR_BASE;
        // 317 100 000 000 000 * 31 536 000 / 1e18 = 100

        uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN * APR / APR_BASE) / REWARD_DURATION;
        // = 1e18 * 31 536 000 / 1 / 31 536 000 = 1e18

        // Mint 99 / 10^18 token as reward
        uint256 MINTED_REWARD_AMOUNT = REWARD_AMOUNT - 1; // 99
        /* solhint-enable var-name-mixedcase */

        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), MINTED_REWARD_AMOUNT);
        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_DURATION); // 100 s.

        // Revert: expected min. balance 100, current balance 99
        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                REWARD_PER_TOKEN_STORED, // constantRewardPerTokenStored
                MAX_DEPOSIT_AMOUNT, // variableRewardMaxTotalSupply
                MAX_DEPOSIT_AMOUNT * REWARD_PER_TOKEN_STORED * REWARD_DURATION, // Min. expected balance
                MINTED_REWARD_AMOUNT // Current reward balance
            )
        );
        // Set 1 unit (1 = 10^-18) of token as reward per token deposit
        // and max deposit of 1 / 1^18 token
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        // available reward should be at least 1 * 1 * 100 = 100
        stakingRewards2.notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);
        vm.stopPrank();
        verboseLog("Staking contract: Events MaxTotalSupply, ProvidedVariableRewardTooHigh emitted");
    }

    function testStakingNotifyVariableRewardAmountSuccess2() public {
        // Reward rate : 10% yearly
        // Depositing 100 / 1e18 Token should give 10 / 1e18 token reward per year
        /* solhint-disable var-name-mixedcase */
        uint256 APR = 10; // 10%
        uint256 APR_BASE = 100; // 100%
        uint256 MAX_DEPOSIT_AMOUNT = 100; // 100 / 1e18
        uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT / APR;
        uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year
        uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN * APR / APR_BASE) / REWARD_DURATION;
        // REWARD_PER_TOKEN_STORED = 1e18 * 10 / APR_BASE / 31_536_000 = 1e17 / 315_360 = 3170979198
        // (3 170 979 198,376...)
        /* solhint-enable var-name-mixedcase */

        // Mint 10 / 1e18 token as total reward
        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_DURATION);

        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(MAX_DEPOSIT_AMOUNT);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(REWARD_PER_TOKEN_STORED);
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        stakingRewards2.notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
        vm.stopPrank();

        verboseLog("Staking contract: owner can notifyVariableRewardAmount of ", REWARD_PER_TOKEN_STORED);
    }

    // Mint insufficient reward
    function testStakingNotifyVariableRewardAmountFail2_1() public {
        // Reward rate : 10% yearly
        // Depositing 100 / 1e18 Token should give 10 / 1e18 token reward per year
        /* solhint-disable var-name-mixedcase */
        uint256 APR = 10; // 10%
        uint256 APR_BASE = 100; // 100%
        uint256 MAX_DEPOSIT_AMOUNT = 100; // 100
        uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT / APR;
        uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year
        uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN * APR / APR_BASE) / REWARD_DURATION;
        // REWARD_PER_TOKEN_STORED = 1e18 * 10 / 100 / 31_536_000 = 1e17 / 315_360 = 3170979198 (3 170 979 198,376...)
        // Mint insufficient reward
        uint256 INSUFFICIENT_MINTED_AMOUNT = REWARD_AMOUNT - 1;
        /* solhint-enable var-name-mixedcase */

        // Mint 10 / 1e18 token as total reward
        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), INSUFFICIENT_MINTED_AMOUNT);
        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_DURATION);

        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                REWARD_PER_TOKEN_STORED, // constantRewardPerTokenStored
                MAX_DEPOSIT_AMOUNT, // variableRewardMaxTotalSupply
                MAX_DEPOSIT_AMOUNT * REWARD_PER_TOKEN_STORED * REWARD_DURATION, // Min. expected balance
                INSUFFICIENT_MINTED_AMOUNT // Current balance
            )
        );

        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        stakingRewards2.notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
        vm.stopPrank();

        verboseLog("Staking contract: owner can't notifyVariableRewardAmount of ", REWARD_PER_TOKEN_STORED);
    }

    // Allow Max amount Deposit too high
    function testStakingNotifyVariableRewardAmountFail2_2() public {
        // Reward rate : 10% yearly
        // Depositing 100 / 1e18 Token should give 10 / 1e18 token reward per year
        /* solhint-disable var-name-mixedcase */
        uint256 APR = 10; // 10%
        uint256 APR_BASE = 100; // 100%
        uint256 MAX_DEPOSIT_AMOUNT = 100; // 100
        uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT / APR;
        uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year
        uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN * APR / APR_BASE) / REWARD_DURATION;
        // REWARD_PER_TOKEN_STORED = 1e18 * 10 / 100 / 31_536_000 = 1e17 / 315_360 = 3170979198 (3 170 979 198,376...)
        uint256 EXCESSIVE_MAX_DEPOSIT_AMOUNT = MAX_DEPOSIT_AMOUNT + 1;
        /* solhint-enable var-name-mixedcase */

        // Mint 10 / 1e18 token as total reward
        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_DURATION);

        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                REWARD_PER_TOKEN_STORED, // constantRewardPerTokenStored
                EXCESSIVE_MAX_DEPOSIT_AMOUNT, // variableRewardMaxTotalSupply
                EXCESSIVE_MAX_DEPOSIT_AMOUNT * REWARD_PER_TOKEN_STORED * REWARD_DURATION, // Min. expected balance
                REWARD_AMOUNT // Current balance
            )
        );

        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        stakingRewards2.notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, EXCESSIVE_MAX_DEPOSIT_AMOUNT);
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
        vm.stopPrank();

        verboseLog("Staking contract: owner can't notifyVariableRewardAmount of ", REWARD_PER_TOKEN_STORED);
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    // Check if the reward amount is correctly computed and matches limits
    function testStakingNotifyVariableRewardAmountSuccess3_1() public {
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

        // uint256 REWARD_PER_TOKEN_STORED = REWARD_AMOUNT / ONE_TOKEN / REWARD_DURATION; //
        // 0,000 000 317 097 919 837 645 865 043 125 32
        // REWARD_PER_TOKEN_STORED = 100 * ONE_TOKEN / 10 / ONE_TOKEN / REWARD_DURATION
        // REWARD_PER_TOKEN_STORED = 10 / 31 536 000 = 0

        uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN * APR / APR_BASE) / REWARD_DURATION;
        // ONE_TOKEN * 10 / 100 / REWARD_DURATION
        // 1e18 * 10 / 100 / 31536000 = 3170979198 (3 170 979 198,376 458 650 431 253 170 979 2)
        /* solhint-enable var-name-mixedcase */

        // Mint 10 * 10^18 token as reward
        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_DURATION);

        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(MAX_DEPOSIT_AMOUNT);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(REWARD_PER_TOKEN_STORED);
        stakingRewards2.notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);
        // 9999999998812800000000000000000000000 < 10000000000000000000000000000000000000
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
        verboseLog("Staking contract: notifyVariableRewardAmount of ", REWARD_PER_TOKEN_STORED * MAX_DEPOSIT_AMOUNT);
    }

    // Test if the max deposit amount margin (rounding) is correctly computed
    function testStakingNotifyVariableRewardAmountSuccess3_2() public {
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
        /* solhint-enable var-name-mixedcase */

        // Mint 10 * 10^18 token as reward
        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_DURATION);

        // Compute max deposit amount limit with rounding
        /* solhint-disable var-name-mixedcase */
        uint256 ROUNDING_MARGIN =
            (REWARD_AMOUNT - MAX_DEPOSIT_TOKEN_AMOUNT * REWARD_PER_TOKEN_STORED * REWARD_DURATION) * APR_BASE / APR;
        /* solhint-enable var-name-mixedcase */
        verboseLog("ROUNDING_MARGIN = ", ROUNDING_MARGIN);

        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(MAX_DEPOSIT_AMOUNT + ROUNDING_MARGIN);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(REWARD_PER_TOKEN_STORED);
        stakingRewards2.notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT + ROUNDING_MARGIN);
        vm.stopPrank();
        // 9999999999999999999859055616000000000 < 10000000000000000000000000000000000000

        verboseLog(
            "Staking contract: notifyVariableRewardAmount of ",
            REWARD_PER_TOKEN_STORED * MAX_DEPOSIT_AMOUNT + ROUNDING_MARGIN
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    // Override max deposit amount margin (rounding)
    function testStakingNotifyVariableRewardAmountFail3() public {
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
        uint256 MINTED_REWARD_AMOUNT = REWARD_AMOUNT;
        /* solhint-enable var-name-mixedcase */

        // Mint 10 * 10^18 token as reward
        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_DURATION);

        // Compute max deposit amount limit with rounding
        /* solhint-disable var-name-mixedcase */
        uint256 ROUNDING_MARGIN =
            (REWARD_AMOUNT - MAX_DEPOSIT_TOKEN_AMOUNT * REWARD_PER_TOKEN_STORED * REWARD_DURATION) * APR_BASE / APR;
        verboseLog("ROUNDING_MARGIN = ", ROUNDING_MARGIN);

        uint256 EXCESSIVE_MAX_DEPOSIT_AMOUNT = MAX_DEPOSIT_AMOUNT + ROUNDING_MARGIN + 100;
        /* solhint-enable var-name-mixedcase */

        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                REWARD_PER_TOKEN_STORED, // constantRewardPerTokenStored
                EXCESSIVE_MAX_DEPOSIT_AMOUNT, // variableRewardMaxTotalSupply
                EXCESSIVE_MAX_DEPOSIT_AMOUNT * REWARD_PER_TOKEN_STORED * REWARD_DURATION, // Min. expected balance
                MINTED_REWARD_AMOUNT // Current balance
            )
        );

        stakingRewards2.notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, EXCESSIVE_MAX_DEPOSIT_AMOUNT);
        vm.stopPrank();

        verboseLog(
            "Staking contract: notifyVariableRewardAmount of ",
            REWARD_PER_TOKEN_STORED * MAX_DEPOSIT_AMOUNT + ROUNDING_MARGIN
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    // Check already deposited amount is lower or equal than max amount
    function testStakingNotifyVariableRewardAmountSuccess4() public {
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

        uint256 ALICE_DEPOSIT_AMOUNT = MAX_DEPOSIT_AMOUNT;
        /* solhint-enable var-name-mixedcase */

        // Mint 10 * 10^18 token as reward
        vm.startPrank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
        stakingERC20.mint(userAlice, ALICE_DEPOSIT_AMOUNT);
        vm.stopPrank();

        // Deposit 1 token BEFORE starting rewards
        vm.startPrank(userAlice);
        stakingERC20.approve(address(stakingRewards2), ALICE_DEPOSIT_AMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(userAlice, ALICE_DEPOSIT_AMOUNT);
        stakingRewards2.stake(ALICE_DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_DURATION);
        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(ONE_TOKEN);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(REWARD_PER_TOKEN_STORED);
        stakingRewards2.notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
        vm.stopPrank();

        verboseLog(
            "Staking contract: Amount deposited before starting rewarding is lower or equal to max amount. ",
            MAX_DEPOSIT_AMOUNT
        );
    }

    // Check already deposited amount is lower or equal than max amount
    function testStakingNotifyVariableRewardAmountFail4_1() public {
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

        uint256 ALICE_DEPOSIT_AMOUNT = MAX_DEPOSIT_AMOUNT + 100;
        /* solhint-enable var-name-mixedcase */

        // Mint 10 * 10^18 token as reward
        vm.startPrank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
        stakingERC20.mint(userAlice, ALICE_DEPOSIT_AMOUNT);
        vm.stopPrank();

        // Deposit 1 token BEFORE starting rewards
        vm.startPrank(userAlice);
        stakingERC20.approve(address(stakingRewards2), ALICE_DEPOSIT_AMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(userAlice, ALICE_DEPOSIT_AMOUNT);
        stakingRewards2.stake(ALICE_DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_DURATION);

        vm.expectRevert(
            abi.encodeWithSelector(
                StakeTotalSupplyExceedsAllowedMax.selector,
                ALICE_DEPOSIT_AMOUNT, // newTotalSupply
                MAX_DEPOSIT_AMOUNT, // variableRewardMaxTotalSupply
                0, // depositAmount
                ALICE_DEPOSIT_AMOUNT // currentTotalSupply
            )
        );
        stakingRewards2.notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
        vm.stopPrank();

        verboseLog(
            "Staking contract: Amount deposited before starting rewarding is lower or equal to max amount. ",
            MAX_DEPOSIT_AMOUNT
        );
    }

    // check no minted reward
    function testStakingNotifyVariableRewardAmountFail4_2() public {
        // Reward rate : 10% yearly
        // Depositing 1 Token should give 0.1 ( = 10^17) token reward per year
        /* solhint-disable var-name-mixedcase */

        uint256 APR = 10; // 10%
        uint256 APR_BASE = 100; // 100%
        uint256 MAX_DEPOSIT_TOKEN_AMOUNT = 100;
        uint256 MAX_DEPOSIT_AMOUNT = MAX_DEPOSIT_TOKEN_AMOUNT * ONE_TOKEN; // 100 token // 100 000 000 000 000 000 000
            // = 1e20 = 100 * 1e18 (1 000 000 000 000 000 000)
        // uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT * APR / APR_BASE; // 10 token
        uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year
        uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN * APR / APR_BASE) / REWARD_DURATION;
        uint256 MINTED_REWARD_AMOUNT = 0;
        uint256 ALICE_DEPOSIT_AMOUNT = MAX_DEPOSIT_AMOUNT;
        /* solhint-enable var-name-mixedcase */

        // No minted reward
        // Mint 10 * 10^18 token as reward
        vm.startPrank(erc20Minter);
        // rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
        stakingERC20.mint(userAlice, ALICE_DEPOSIT_AMOUNT);
        vm.stopPrank();

        // Deposit 1 token BEFORE starting rewards
        vm.startPrank(userAlice);
        stakingERC20.approve(address(stakingRewards2), ALICE_DEPOSIT_AMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(userAlice, ALICE_DEPOSIT_AMOUNT);
        stakingRewards2.stake(ALICE_DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_DURATION);

        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                REWARD_PER_TOKEN_STORED, // constantRewardPerTokenStored
                MAX_DEPOSIT_AMOUNT, // variableRewardMaxTotalSupply
                MAX_DEPOSIT_AMOUNT * REWARD_PER_TOKEN_STORED * REWARD_DURATION, // Min. expected balance
                MINTED_REWARD_AMOUNT // Current balance
            )
        );
        stakingRewards2.notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);

        vm.stopPrank();

        verboseLog(
            "Staking contract: Amount deposited before starting rewarding is lower or equal to max amount. ",
            MAX_DEPOSIT_AMOUNT
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    // TODO : add some fuzzing
    // TODO : add some fuzzing
    // TODO : add some fuzzing
    // TODO : add some fuzzing

    // function testStakingNotifyVariableRewardAmountFuzz() public {
    // }
} // CheckStakingConstantRewardLimits2
