// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { StakingPreSetup, Erc20Setup } from
// , Erc20Setup3
"./StakingRewards2_commonbase.t.sol";
import { DELTA_0_015, ONE_TOKEN } from "./TestsConstants.sol";

import { StakingRewards2 } from "../src/contracts/StakingRewards2.sol";
import { StakingRewards2Events } from "../src/contracts/StakingRewards2Events.sol";

import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";

// ----------------

contract CheckStakingConstantRewardCustom1 is StakingPreSetup, Erc20Setup {
    // Reward rate : 10% yearly
    // Depositing 1 Token should give 0.1 ( = 10^17) token reward per year

    /* solhint-disable var-name-mixedcase */
    uint256 internal constant APR = 10; // 10%
    uint256 internal constant APR_BASE = 100; // 100%
    uint256 internal constant MAX_DEPOSIT_TOKEN_AMOUNT = 100;
    uint256 internal constant MAX_DEPOSIT_AMOUNT = MAX_DEPOSIT_TOKEN_AMOUNT * ONE_TOKEN;
    // 100 token = 100 000 000 000 000 000 000 = 1e20 = 100 * 1e18 (1 000 000 000 000 000 000)
    uint256 internal constant REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT * APR / APR_BASE; // 10 token
    uint256 internal constant REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year
    uint256 internal constant CONSTANT_REWARDRATE_PERTOKENSTORED = (ONE_TOKEN * APR / APR_BASE) / REWARD_DURATION;

    uint256 internal constant ALICE_DEPOSIT_AMOUNT = 20 * ONE_TOKEN; // 20 tokens
    uint256 internal constant BOB_DEPOSIT_AMOUNT = 10 * ONE_TOKEN; // 10 tokens
    /* solhint-enable var-name-mixedcase */

    function setUp() public virtual override(Erc20Setup, StakingPreSetup) {
        debugLog("CheckStakingConstantRewardLimits setUp() start");
        verboseLog("StakingSetup1");
        StakingPreSetup.setUp();
        Erc20Setup.setUp();
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
        uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);
        verboseLog("expectedStakingRewards: rewardsDuration= ", rewardsDuration);
        uint256 expectedStakingRewardsAmount =
            CONSTANT_REWARDRATE_PERTOKENSTORED * _stakedAmount / ONE_TOKEN * rewardsDuration;
        verboseLog("expectedStakingRewards: expectedStakingRewardsAmount= ", expectedStakingRewardsAmount);
        return expectedStakingRewardsAmount;
    }

    // Check already deposited amount is lower or equal than max amount
    function testStakingVRR2Deposit1BeforeReward1After() public {
        gotoTimestamp(INITIAL_BLOCK_TIMESTAMP); // Go to the start of the test // init block.number

        // Mint 10 * 10^18 token as reward
        vm.startPrank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);

        // Mint Alice tokens
        stakingERC20.mint(userAlice, ALICE_DEPOSIT_AMOUNT);
        // Mint Bob tokens
        stakingERC20.mint(userBob, BOB_DEPOSIT_AMOUNT);

        // Check Alice and Bob staking balances
        // Nobody should have staked yet
        itStakesCorrectly(userAlice, 0, "Alice");
        itStakesCorrectly(userBob, 0, "Bob");

        vm.stopPrank();
        // /*
        // Alice deposit tokens BEFORE rewards start
        debugLog("Alice deposit tokens BEFORE rewards start at :");
        displayTime();
        //   debugLog("block.timestamp = ", block.timestamp);
        //   debugLog("block.number = ", block.number);

        vm.startPrank(userAlice);
        stakingERC20.approve(address(stakingRewards2), ALICE_DEPOSIT_AMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(userAlice, ALICE_DEPOSIT_AMOUNT);
        stakingRewards2.stake(ALICE_DEPOSIT_AMOUNT);
        vm.stopPrank();

        // Check Alice and Bob staking balances
        // Only Alice should have staked
        itStakesCorrectly(userAlice, ALICE_DEPOSIT_AMOUNT, "Alice");
        itStakesCorrectly(userBob, 0, "Bob");
        // */

        gotoTimestamp(INITIAL_BLOCK_TIMESTAMP + 100);

        debugLog("Set rewards duration at :");
        displayTime();

        // Start rewarding
        vm.startPrank(userStakingRewardAdmin);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(REWARD_DURATION);
        stakingRewards2.setRewardsDuration(REWARD_DURATION);

        debugLog("------------------");
        debugLog("displayEarned");
        displayTime();
        displayEarned(userAlice, "Alice");
        displayEarned(userBob, "Bob");
        debugLog("------------------");

        gotoTimestamp(INITIAL_BLOCK_TIMESTAMP + 200);

        debugLog("notifyVariableRewardAmount at :");
        displayTime();

        getLastRewardTime();

        notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, MAX_DEPOSIT_AMOUNT);
        debugLog("STAKING_TIMESTAMP = ", STAKING_TIMESTAMP);
        verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
        vm.stopPrank();

        debugLog("------------------");
        debugLog("displayEarned");
        displayTime();
        displayEarned(userAlice, "Alice");
        displayEarned(userBob, "Bob");
        debugLog("------------------");

        gotoTimestamp(STAKING_TIMESTAMP + 100);

        debugLog("Bob deposit tokens AFTER rewards at :");
        displayTime();

        // Bob deposits tokens AFTER rewards start
        vm.startPrank(userBob);
        stakingERC20.approve(address(stakingRewards2), BOB_DEPOSIT_AMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(userBob, BOB_DEPOSIT_AMOUNT);
        stakingRewards2.stake(BOB_DEPOSIT_AMOUNT);
        vm.stopPrank();

        gotoTimestamp(STAKING_TIMESTAMP + 200);
        /*
        // Alice deposit tokens AFTER rewards start
        debugLog("Alice deposit tokens AFTER rewards start at :");
        displayTime();

        vm.startPrank(userAlice);
        stakingERC20.approve(address(stakingRewards2), ALICE_DEPOSIT_AMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(userAlice, ALICE_DEPOSIT_AMOUNT);
        stakingRewards2.stake(ALICE_DEPOSIT_AMOUNT);
        vm.stopPrank();
        */

        // Check Alice and Bob staking balances
        // Alice and Bob should have staked
        itStakesCorrectly(userAlice, ALICE_DEPOSIT_AMOUNT, "Alice");
        itStakesCorrectly(userBob, BOB_DEPOSIT_AMOUNT, "Bob");

        // Go to the end of the reward period
        debugLog("Go to the end of the reward period at :");

        gotoTimestamp(STAKING_TIMESTAMP + REWARD_DURATION + 1);

        debugLog("block.timestamp = ", block.timestamp);
        debugLog("block.number = ", block.number);

        uint256 aliceTotalExpectedRewards =
            expectedStakingRewards(ALICE_DEPOSIT_AMOUNT, REWARD_DURATION, REWARD_DURATION);
        uint256 bobTotalExpectedRewards = expectedStakingRewards(BOB_DEPOSIT_AMOUNT, REWARD_DURATION, REWARD_DURATION);

        checkStakingRewards(userAlice, "Alice", aliceTotalExpectedRewards, DELTA_0_015, 0);
        checkStakingRewards(userBob, "Bob", bobTotalExpectedRewards, DELTA_0_015, 0);
    }
} // CheckStakingConstantRewardLimits2
