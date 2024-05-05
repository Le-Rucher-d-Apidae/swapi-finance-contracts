// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { console } from "forge-std/src/console.sol";
import { stdMath } from "forge-std/src/StdMath.sol";

import "./StakingRewards2_base.t.sol";

import "../src/contracts/StakingRewards2Errors.sol";
import { StakingRewards2Events } from "../src/contracts/StakingRewards2Events.sol";

import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";
import { Ownable } from "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts@5.0.2/utils/Pausable.sol";

// ----------------

abstract contract StakingPreSetupVRR is StakingPreSetup {
    // // Rewards constants

    // Variable rewards
    // Limit max LP tokens staked
    uint256 internal constant VARIABLE_REWARD_MAXTOTALSUPPLY_LP = 6; // Max LP : 6
    uint256 internal constant VARIABLE_REWARD_MAXTOTALSUPPLY = VARIABLE_REWARD_MAXTOTALSUPPLY_LP * ONE_TOKEN;
    uint256 internal constant CONSTANT_REWARDRATE_PERTOKENSTORED = 1e3; // 1 000 ; for each LP token earn 1 000 reward
        // per second

    function setUp() public virtual /* override */ {
        debugLog("StakingPreSetupCRR setUp() start");
        // Max. budget for rewards
        REWARD_INITIAL_AMOUNT =
            CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY * REWARD_INITIAL_DURATION;
        // allocated to rewards
        verboseLog("StakingPreSetupCRR setUp()");
        debugLog("StakingPreSetupCRR setUp() end");
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
    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;

    function setUp() public virtual override(Erc20Setup1, StakingSetup) {
        debugLog("StakingSetup1 setUp() start");
        verboseLog("StakingSetup1");
        Erc20Setup1.setUp();
        StakingSetup.setUp();
        vm.prank(userStakingRewardAdmin);
        stakingRewards2 = new StakingRewards2(address(rewardErc20), address(stakingERC20));
        assertEq(userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner");

        vm.prank(userStakingRewardAdmin);
        stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_INITIAL_AMOUNT);

        vm.prank(userStakingRewardAdmin);
        // TODO : VARIABLE_REWARD_MAXTOTALSUPPLY
        stakingRewards2.notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY);

        // TODO : check event MaxTotalSupply(variableRewardMaxTotalSupply;
        // TODO : check event RewardAddedPerTokenStored( _constantRewardRatePerTokenStored );

        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup1 setUp() end");
    }

    function checkAliceStake() internal {
        itStakesCorrectly(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice");
    }
}

// ----------------

contract StakingSetup2 is Erc20Setup2, StakingSetup {
    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant BOB_STAKINGERC20_STAKEDAMOUNT = BOB_STAKINGERC20_MINTEDAMOUNT;

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
        stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);

        // console.log("StakingSetup2 setUp() mint REWARD_INITIAL_AMOUNT to contract", REWARD_INITIAL_AMOUNT);
        rewardErc20.mint(address(stakingRewards2), REWARD_INITIAL_AMOUNT);

        vm.prank(userStakingRewardAdmin);
        // TODO : VARIABLE_REWARD_MAXTOTALSUPPLY
        stakingRewards2.notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY);

        // TODO : check event MaxTotalSupply(variableRewardMaxTotalSupply;
        // TODO : check event RewardAddedPerTokenStored( _constantRewardRatePerTokenStored );

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
    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant BOB_STAKINGERC20_STAKEDAMOUNT = BOB_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant CHERRY_STAKINGERC20_STAKEDAMOUNT = CHERRY_STAKINGERC20_MINTEDAMOUNT;

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
        stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_INITIAL_AMOUNT);

        vm.prank(userStakingRewardAdmin);
        // TODO : VARIABLE_REWARD_MAXTOTALSUPPLY
        stakingRewards2.notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY);

        // TODO : check event MaxTotalSupply(variableRewardMaxTotalSupply;
        // TODO : check event RewardAddedPerTokenStored( _constantRewardRatePerTokenStored );

        // debugLog("Staking start time", stakingStartTime);
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
        // console.log("DepositSetup1 setUp()");
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
        // console.log("DepositSetup2 setUp()");
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
        // console.log("DepositSetup3 setUp()");
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

contract DuringStaking1_WithoutWithdral is DepositSetup1 {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration, "DuringStaking1_WithoutWithdral:
        // _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking1_WithoutWithdral setUp() start");
        DepositSetup1.setUp();
        verboseLog("DuringStaking1_WithoutWithdral");
        debugLog("DuringStaking1_WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
        checkUsersStake();
        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
        }

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        checkUsersStake();
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog("Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION);
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);

        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed
    }
}

// ------------------------------------

contract DuringStaking2_WithoutWithdral is DepositSetup2 {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration, "DuringStaking1_WithoutWithdral:
        // _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking2_WithoutWithdral setUp() start");
        DepositSetup2.setUp();
        verboseLog("DuringStaking2_WithoutWithdral");
        debugLog("DuringStaking2_WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
        checkUsersStake();
        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015, rewardErc20);
        }

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        checkUsersStake();
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0_31, 0);

        userBobExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userBobExpectedRewards -= userBobClaimedRewards;
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, DELTA_0_31, 0);

        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed
    }
}

// ------------------------------------

contract DuringStaking3_WithoutWithdral is DepositSetup3 {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration, "DuringStaking1_WithoutWithdral:
        // _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking3_WithoutWithdral setUp() start");
        DepositSetup3.setUp();
        verboseLog("DuringStaking3_WithoutWithdral");
        debugLog("DuringStaking3_WithoutWithdral setUp() end");
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
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userCherryExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobClaimedRewards;
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
        checkUsersStake();
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0_31, 0);

        userBobExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userBobExpectedRewards -= userBobClaimedRewards;
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, DELTA_0_31, 0);

        userCherryExpectedRewards =
            expectedStakingRewards(CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userCherryExpectedRewards -= userCherryClaimedRewards;
        checkStakingRewards(userCherry, "Cherry", userCherryExpectedRewards, DELTA_0_31, 0);

        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed
    }
}

// ------------------------------------

// 1 staker deposit right after staking starts and removes all staked amount after half of staking percentage duration

contract DuringStaking1_WithWithdral is DepositSetup1 {
    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computaton will underflow
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking1_WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
        }
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking1_WithWithdral setUp() start");
        DepositSetup1.setUp();
        verboseLog("DuringStaking1_WithWithdral");
        debugLog("DuringStaking1_WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
        checkUsersStake();
        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
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

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);

        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        // Alice withdraws all
        withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION);

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);

        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed
    }
}

// ------------------------------------
// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

contract DuringStaking2_WithWithdral is DepositSetup2 {
    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computaton will underflow
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking2_WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
        }
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking2_WithWithdral setUp() start");
        DepositSetup2.setUp();
        verboseLog("DuringStaking2_WithWithdral");
        debugLog("DuringStaking2_WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
        checkUsersStake();
        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userAliceClaimedRewards;
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

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);

        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        // Alice withdraws all
        withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);

        // Bob withdraws all
        withdrawStake(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION);

        uint256 delta = STAKING_PERCENTAGE_DURATION < PERCENT_10 ? DELTA_0_4 : DELTA_0_04; // Longer staking period =
            // better accuracy : less delta

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);

        userBobExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userBobExpectedRewards -= userBobClaimedRewards;
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, delta, 0);

        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed
    }
}

// ------------------------------------

// 3 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

contract DuringStaking3_WithWithdral is DepositSetup3 {
    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computaton will underflow
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking3_WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
        }
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking3_WithWithdral setUp() start");
        DepositSetup3.setUp();
        verboseLog("DuringStaking3_WithWithdral");
        debugLog("DuringStaking3_WithWithdral setUp() end");
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
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userCherryExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobClaimedRewards;
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

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);

        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        // Alice withdraws all
        withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);

        // Bob withdraws all
        withdrawStake(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);

        // Cherry withdraws all
        withdrawStake(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT);

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        verboseLog("Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION);

        uint256 delta = STAKING_PERCENTAGE_DURATION < PERCENT_10 ? DELTA_0_4 : DELTA_0_04; // Longer staking period =
            // better accuracy : less delta

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);

        userBobExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userBobExpectedRewards -= userBobClaimedRewards;
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, delta, 0);

        userCherryExpectedRewards =
            expectedStakingRewards(CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userCherryExpectedRewards -= userCherryClaimedRewards;
        checkStakingRewards(userCherry, "Cherry", userCherryExpectedRewards, delta, 0);

        checkRewardPerToken(CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0); // no delta needed
    }
}

// ----------------------------------------------------------------------------

// Permissions tests

// 8 tests

// /*
contract CheckStakingPermissions2 is StakingSetup2 {
    function setUp() public virtual override {
        // console.log("CheckStakingPermissions2 setUp()");
        debugLog("CheckStakingPermissions2 setUp() start");
        StakingSetup2.setUp();
        debugLog("CheckStakingPermissions2 setUp() end");
    }

    // TODO: Check staking MAX amount

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
        // Check emitted event
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
        // Check emitted event
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

    function testStakingnotifyVariableRewardAmountMin() public {
        verboseLog("Only staking reward contract owner can notifyVariableRewardAmount");

        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));

        stakingRewards2.notifyVariableRewardAmount(1, 1);
        verboseLog("Staking contract: Alice can't notifyVariableRewardAmount");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));
        stakingRewards2.notifyVariableRewardAmount(1, 1);
        verboseLog("Staking contract: Bob can't notifyVariableRewardAmount");

        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(1);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(1);
        stakingRewards2.notifyVariableRewardAmount(1, 1);
        verboseLog("Staking contract: Only owner can notifyVariableRewardAmount of ", 1);
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    function testStakingNotifyVariableRewardAmount0() public {
        vm.prank(userStakingRewardAdmin);
        // Check emitted event
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
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(VARIABLE_REWARD_MAXTOTALSUPPLY);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(CONSTANT_REWARDRATE_PERTOKENSTORED);
        stakingRewards2.notifyVariableRewardAmount(1, 1);
        verboseLog("Staking contract: Only owner can notifyVariableRewardAmount");
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    function testStakingnotifyVariableRewardAmountLimit1() public {
        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(VARIABLE_REWARD_MAXTOTALSUPPLY);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(CONSTANT_REWARDRATE_PERTOKENSTORED);
        stakingRewards2.notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY);
        verboseLog(
            "Staking contract: Only owner can notifyVariableRewardAmount of ",
            CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    function testStakingnotifyVariableRewardAmountFail() public {
        vm.prank(userStakingRewardAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                CONSTANT_REWARDRATE_PERTOKENSTORED, // constantRewardRatePerTokenStored
                VARIABLE_REWARD_MAXTOTALSUPPLY + 1, // Max. total supply
                VARIABLE_REWARD_MAXTOTALSUPPLY, // Min. expected balance
                REWARD_INITIAL_AMOUNT // Current balance
            )
        );
        stakingRewards2.notifyVariableRewardAmount(
            CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY + 1
        );

        verboseLog(
            "Staking contract: Only owner can notifyVariableRewardAmount of ",
            CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }



    function testStakingSetRewardsDuration() public {
        // Previous reward epoch must have ended before setting a new duration
        vm.warp(STAKING_START_TIME + REWARD_INITIAL_DURATION + 1); // epoch ended

        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
        verboseLog("Only staking reward contract owner can notifyVariableRewardAmount");

        stakingRewards2.setRewardsDuration(1);
        verboseLog("Staking contract: Alice can't setRewardsDuration");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));

        stakingRewards2.setRewardsDuration(1);
        verboseLog("Staking contract: Bob can't setRewardsDuration");

        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(1);
        stakingRewards2.setRewardsDuration(1);
        verboseLog("Staking contract: Only owner can setRewardsDuration");
        verboseLog("Staking contract: Event RewardsDurationUpdated emitted");
    }

    function testStakingSetRewardsDurationBeforeEpochEnd() public {
        // Previous reward epoch must have ended before setting a new duration
        vm.startPrank(userStakingRewardAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(
                RewardPeriodInProgress.selector, block.timestamp, STAKING_START_TIME + REWARD_INITIAL_DURATION
            )
        );
        // vm.expectRevert( bytes(_MMPOR000) );
        stakingRewards2.setRewardsDuration(1);

        // Previous reward epoch must have ended before setting a new duration
        vm.warp(STAKING_START_TIME + REWARD_INITIAL_DURATION); // epoch last time reward
        vm.expectRevert(
            abi.encodeWithSelector(
                RewardPeriodInProgress.selector, block.timestamp, STAKING_START_TIME + REWARD_INITIAL_DURATION
            )
        );
        stakingRewards2.setRewardsDuration(1);

        verboseLog("Staking contract: Owner can't setRewardsDuration before previous epoch end");
        vm.stopPrank();
    }
}


contract CheckStakingConstantRewardLimits is StakingPreSetup {

    RewardERC20 internal rewardErc20;
    StakingERC20 internal stakingERC20;
    address internal userAlice;


    function setUp() public virtual override(Erc20Setup1, StakingSetup) {
        debugLog("CheckStakingConstantRewardLimits setUp() start");
        verboseLog("StakingSetup1");
        StakingPreSetup.setUp();

        // Erc20 Setup
        vm.startPrank(erc20Minter);
        rewardErc20 = new RewardERC20(erc20Admin, erc20Minter, "TestReward", "TSTRWD");
        stakingERC20 = new StakingERC20(erc20Admin, erc20Minter, "Uniswap V2 Staking", "UNI-V2 Staking");
        vm.stopPrank();

        vm.prank(userStakingRewardAdmin);
        stakingRewards2 = new StakingRewards2(address(rewardErc20), address(stakingERC20));
        assertEq(userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner");

        // vm.prank(userStakingRewardAdmin);
        // stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        // vm.prank(erc20Minter);
        // rewardErc20.mint(address(stakingRewards2), REWARD_INITIAL_AMOUNT);

        // vm.prank(userStakingRewardAdmin);
        // // TODO : VARIABLE_REWARD_MAXTOTALSUPPLY
        // stakingRewards2.notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY);

        // TODO : check event MaxTotalSupply(variableRewardMaxTotalSupply;
        // TODO : check event RewardAddedPerTokenStored( _constantRewardRatePerTokenStored );

        debugLog("CheckStakingConstantRewardLimits setUp() end");
    }

    function testStakingNotifyVariableRewardAmountFail0() public {

        // Test some arbitrary values
        // Smallest amount (1,1), 0 reward minted

        // Mint 99 / 10^18 token as reward
        vm.prank(erc20Minter);
        // rewardErc20.mint( address(stakingRewards2), 0 );
        vm.startPrank(userStakingRewardAdmin);
        stakingRewards2.setRewardsDuration( 100 ) // 100 s.

        // Set 1 unit (1 = 10^-18) of token as reward per token deposit
        // and max deposit of 1 / 1^18 token

        // Check emitted event
        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                1,
                1,
                100, // Min. expected balance
                0 // Current balance
            )
        );
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        // notifyVariableRewardAmount(_constantRewardRatePerTokenStored,_variableRewardMaxTotalSupply)
        // available reward should be at least 1 * 1 * 100 = 100
        stakingRewards2.notifyVariableRewardAmount( 1, 1);
        vm.stopPrank();
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    function testStakingNotifyVariableRewardAmountSuccess1() public {

        // Test some arbitrary values
        // Smallest amount (1,1), sufficient reward minted

        // Mint 100 / 10^18 token as reward
        vm.prank(erc20Minter);
        rewardErc20.mint( address(stakingRewards2), 100 );
        vm.startPrank(userStakingRewardAdmin);
        stakingRewards2.setRewardsDuration( 100 ) // 100 s.

        // Set 1 unit (1 = 10^-18) of token as reward per token deposit
        // and max deposit of 1 / 1^18 token

        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply( 1 );
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(CONSTANT_REWARDRATE_PERTOKENSTORED);
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        // notifyVariableRewardAmount(_constantRewardRatePerTokenStored,_variableRewardMaxTotalSupply)
        stakingRewards2.notifyVariableRewardAmount( 1, 1);
        vm.stopPrank();
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }



    function testStakingNotifyVariableRewardAmountFail1() public {

        // Test some arbitrary values
        // Smallest amount (1,1), unsufficient reward minted

        // Mint 99 / 10^18 token as reward
        vm.prank(erc20Minter);
        rewardErc20.mint( address(stakingRewards2), 99 );
        vm.prank(userStakingRewardAdmin);
        stakingRewards2.setRewardsDuration( 100 ) // 100 s.
        // Check emitted event
        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                1,
                1,
                100, // Min. expected balance
                99 // Current balance
            )
        );
        // Set 1 unit (1 = 10^-18) of token as reward per token deposit
        // and max deposit of 1 / 1^18 token
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        // notifyVariableRewardAmount(_constantRewardRatePerTokenStored,_variableRewardMaxTotalSupply)
        // available reward should be at least 1 * 1 * 100 = 100
        stakingRewards2.notifyVariableRewardAmount( 1, 1);
        vm.stopPrank();
        verboseLog("Staking contract: Events MaxTotalSupply, ProvidedVariableRewardTooHigh emitted");
    }

    function testStakingnotifyVariableRewardAmountSuccess2() public {

        // Reward rate : 10% yearly
        // Depositing 1 Token should give 0.1 ( = 10^17) token reward per year
        uint256 MAX_DEPOSIT_AMOUNT = ONE_TOKEN
        uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT / 10;
        uint256 REWARD_DURATION = 31536000; // 31 536 000 s. = 1 year
        uint256 REWARD_PER_TOKEN_STORED = REWARD_AMOUNT / REWARD_DURATION;


        // Mint 0.1 * 10^18 token as reward
        vm.prank(erc20Minter);
        rewardErc20.mint( address(stakingRewards2), REWARD_AMOUNT);
        vm.startPrank(userStakingRewardAdmin);
        stakingRewards2.setRewardsDuration( REWARD_DURATION )


        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply( ONE_TOKEN );
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored( REWARD_PER_TOKEN_STORED );
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        // notifyVariableRewardAmount(_constantRewardRatePerTokenStored,_variableRewardMaxTotalSupply)
        stakingRewards2.notifyVariableRewardAmount( REWARD_PER_TOKEN_STORED, ONE_TOKEN );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
        stakingRewards2.notifyVariableRewardAmount(
            CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY + 1
        );
        vm.stopPrank();

        verboseLog(
            "Staking contract: Only owner can notifyVariableRewardAmount of ",
            CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

    function testStakingnotifyVariableRewardAmountFail2() public {

        // Reward rate : 10% yearly
        // Depositing 1 Token should give 0.1 ( = 10^17) token reward per year
        uint256 MAX_DEPOSIT_AMOUNT = ONE_TOKEN;
        uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT / 10;
        uint256 REWARD_DURATION = 31536000; // 31 536 000 s. = 1 year
        uint256 REWARD_PER_TOKEN_STORED = REWARD_AMOUNT / REWARD_DURATION + 1 ; // Round up


        // Mint 0.1 * 10^18 token as reward
        vm.prank(erc20Minter);
        rewardErc20.mint( address(stakingRewards2), REWARD_AMOUNT);
        vm.startPrank(userStakingRewardAdmin);
        stakingRewards2.setRewardsDuration( REWARD_DURATION )
        // Check emitted event
        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                1,
                1,
                100, // Min. expected balance
                99 // Current balance
            )
        );
        // Set 1 unit (1 = 10^-18) of token as reward per token deposit
        // and max deposit of 1 / 1^18 token
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        // notifyVariableRewardAmount(_constantRewardRatePerTokenStored,_variableRewardMaxTotalSupply)
        // available reward should be at least 1 * 1 * 100 = 100
        stakingRewards2.notifyVariableRewardAmount( REWARD_PER_TOKEN_STORED, ONE_TOKEN );
        verboseLog("Staking contract: Events MaxTotalSupply, ProvidedVariableRewardTooHigh emitted");


        stakingRewards2.notifyVariableRewardAmount(
            CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY + 1
        );

        verboseLog(
            "Staking contract: Only owner can notifyVariableRewardAmount of ",
            CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

// TODO: check StakeTotalSupplyExceedsAllowedMax error : amount already deposited
    function testStakingnotifyVariableRewardAmountSuccess3() public {

        // Reward rate : 10% yearly
        // Depositing 1 Token should give 0.1 ( = 10^17) token reward per year
        uint256 MAX_DEPOSIT_AMOUNT = ONE_TOKEN;
        uint256 ALICE_DEPOSIT_AMOUNT = MAX_DEPOSIT_AMOUNT;
        uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT / 10;
        uint256 REWARD_DURATION = 31536000; // 31 536 000 s. = 1 year
        uint256 REWARD_PER_TOKEN_STORED = REWARD_AMOUNT / REWARD_DURATION;

        // Mint 0.1 * 10^18 token as reward
        vm.startPrank(erc20Minter);
        rewardErc20.mint( address(stakingRewards2), REWARD_AMOUNT);
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
        stakingRewards2.setRewardsDuration( REWARD_DURATION )
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply( ONE_TOKEN );
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored( REWARD_PER_TOKEN_STORED );
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        // notifyVariableRewardAmount(_constantRewardRatePerTokenStored,_variableRewardMaxTotalSupply)
        stakingRewards2.notifyVariableRewardAmount( REWARD_PER_TOKEN_STORED, ONE_TOKEN );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
        stakingRewards2.notifyVariableRewardAmount(
            CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY + 1
        );
        vm.stopPrank();

        verboseLog(
            "Staking contract: Only owner can notifyVariableRewardAmount of ",
            CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

// TODO: check StakeTotalSupplyExceedsAllowedMax error : excessive amount already deposited
    function testStakingnotifyVariableRewardAmountFail3() public {

        // Reward rate : 10% yearly
        // Depositing 1 Token should give 0.1 ( = 10^17) token reward per year
        uint256 MAX_DEPOSIT_AMOUNT = ONE_TOKEN;
        uint256 ALICE_DEPOSIT_AMOUNT = MAX_DEPOSIT_AMOUNT * 2;
        uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT / 10;
        uint256 REWARD_DURATION = 31536000; // 31 536 000 s. = 1 year
        uint256 REWARD_PER_TOKEN_STORED = REWARD_AMOUNT / REWARD_DURATION;

        // Mint 0.1 * 10^18 token as reward
        vm.startPrank(erc20Minter);
        rewardErc20.mint( address(stakingRewards2), REWARD_AMOUNT);
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
        stakingRewards2.setRewardsDuration( REWARD_DURATION )
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply( ONE_TOKEN );
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored( REWARD_PER_TOKEN_STORED );
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        // notifyVariableRewardAmount(_constantRewardRatePerTokenStored,_variableRewardMaxTotalSupply)
        stakingRewards2.notifyVariableRewardAmount( REWARD_PER_TOKEN_STORED, ONE_TOKEN );
        // Check emitted event
        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                REWARD_PER_TOKEN_STORED, // constantRewardPerTokenStored
                ONE_TOKEN, // variableRewardMaxTotalSupply
                2 * ONE_TOKEN, // Min. expected balance
                ONE_TOKEN // Current balance
            )
        );
        vm.stopPrank();

        verboseLog(
            "Staking contract: Only owner can notifyVariableRewardAmount of ",
            CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

// TODO: check StakeTotalSupplyExceedsAllowedMax error : amount already deposited And 0 mint to staking contract
    function testStakingnotifyVariableRewardAmountFail4() public {

        // Reward rate : 10% yearly
        // Depositing 1 Token should give 0.1 ( = 10^17) token reward per year
        uint256 MAX_DEPOSIT_AMOUNT = 10 // ONE_TOKEN;
        uint256 ALICE_DEPOSIT_AMOUNT = 1; // MAX_DEPOSIT_AMOUNT * 2;
        // uint256 REWARD_AMOUNT = 0; // MAX_DEPOSIT_AMOUNT / 10;
        uint256 REWARD_DURATION = 100; // 31536000; // 31 536 000 s. = 1 year
        uint256 REWARD_PER_TOKEN_STORED = REWARD_AMOUNT / REWARD_DURATION;

        // Mint 0.1 * 10^18 token as reward
        vm.startPrank(erc20Minter);
        // rewardErc20.mint( address(stakingRewards2), 0);
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
        stakingRewards2.setRewardsDuration( REWARD_DURATION )
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply( ONE_TOKEN );
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored( REWARD_PER_TOKEN_STORED );
        // 1, 1 = 1 unit of token per token (10^18) deposit , max supply of 1 / 1^18 token
        // notifyVariableRewardAmount(_constantRewardRatePerTokenStored,_variableRewardMaxTotalSupply)
        stakingRewards2.notifyVariableRewardAmount( REWARD_PER_TOKEN_STORED, ONE_TOKEN );
        // Check emitted event
        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedVariableRewardTooHigh.selector,
                REWARD_PER_TOKEN_STORED, // constantRewardPerTokenStored
                MAX_DEPOSIT_AMOUNT, // variableRewardMaxTotalSupply
                MAX_DEPOSIT_AMOUNT * REWARD_PER_TOKEN_STORED * REWARD_DURATION, // Min. expected balance
                0 // Current balance
            )
        );
        vm.stopPrank();

        verboseLog(
            "Staking contract: Only owner can notifyVariableRewardAmount of ",
            CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY
        );
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    }

// TODO : add some fuzzing
// TODO : add some fuzzing
// TODO : add some fuzzing
// TODO : add some fuzzing
    function testStakingnotifyVariableRewardAmountFuzz() public {
        vm.prank(userStakingRewardAdmin);
    }
}

// */
