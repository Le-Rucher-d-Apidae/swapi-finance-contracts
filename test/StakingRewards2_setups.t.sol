// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { StakingPreSetup, Erc20Setup } from "./StakingRewards2_commonbase.t.sol";
import {
    DELTA_0_00000000022,
    DELTA_0_015,
    DELTA_0_31,
    PERCENT_1,
    PERCENT_5,
    PERCENT_90,
    PERCENT_100,
    DELTA_0,
    ONE_TOKEN
} from "./TestsConstants.sol";

import { StakingRewards2 } from "../src/contracts/StakingRewards2.sol";
import { StakingRewards2Events } from "../src/contracts/StakingRewards2Events.sol";

import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";

// ----------------

abstract contract StakingPreSetupCRR is StakingPreSetup {
    // Rewards constants

    // Duration of the rewards program
    // see StakingPreSetup0

    function setUp() public virtual override {
        debugLog("StakingPreSetupCRR setUp() start");

        if (REWARD_INITIAL_DURATION == 0) {
            fail("StakingPreSetupCRR: REWARD_INITIAL_DURATION is 0");
        }

        // Constant reward amount allocated to the staking program during the reward duration
        // Same reward amount is distributed at each block
        // Stakers will share the reward budget based on their staked amount
        // REWARD_INITIAL_AMOUNT = 100_000; // 1e5
        REWARD_INITIAL_AMOUNT = REWARD_INITIAL_DURATION * 1e5; // x 1e5

        if (REWARD_INITIAL_AMOUNT < REWARD_INITIAL_DURATION) {
            errorLog("REWARD_INITIAL_AMOUNT", REWARD_INITIAL_AMOUNT);
            errorLog("REWARD_INITIAL_DURATION", REWARD_INITIAL_DURATION);
            fail("StakingPreSetupCRR: REWARD_INITIAL_AMOUNT < REWARD_INITIAL_DURATION");
        }

        verboseLog("StakingPreSetupCRR setUp()");
        debugLog("StakingPreSetupCRR setUp() end");
    }

    // All stakers share reward budget, the more staked amount, the less rewards for each staker
    // Reward rate is constant, same reward amount is "distributed" at each block, shared between stakers
    // All budget is spent during the reward duration
    function checkRewardForDuration(uint256 _delta) internal virtual override {
        debugLog("StakingPreSetupVRR: checkRewardForDuration");
        _checkRewardForDuration(_delta);
    }
} // StakingPreSetupCRR

contract StakingSetup is StakingPreSetupCRR, Erc20Setup {
    /* solhint-disable var-name-mixedcase */
    uint256 internal ALICE_STAKINGERC20_STAKEDAMOUNT;
    uint256 internal BOB_STAKINGERC20_STAKEDAMOUNT;
    uint256 internal CHERRY_STAKINGERC20_STAKEDAMOUNT;
    /* solhint-enable var-name-mixedcase */

    function setUp() public virtual override(Erc20Setup, StakingPreSetupCRR) {
        debugLog("StakingSetup setUp() start");
        StakingPreSetupCRR.setUp();
        Erc20Setup.setUp();

        vm.prank(userStakingRewardAdmin);
        stakingRewards2 = new StakingRewards2(address(rewardErc20), address(stakingERC20));
        assertEq(userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner");

        vm.prank(userStakingRewardAdmin);
        setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_INITIAL_AMOUNT);

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
        debugLog("expectedStakingRewards: rewardsDuration = ", rewardsDuration);
        uint256 expectedStakingRewards_ = (
            rewardsDuration == _rewardTotalDuration
                ? REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT
                : REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardTotalDuration / TOTAL_STAKED_AMOUNT
        );
        debugLog("expectedStakingRewards: expectedStakingRewards_ = ", expectedStakingRewards_);
        return expectedStakingRewards_;
    }

    function _userStakes(address _userAddress, string memory _userName, uint256 _amount) internal {
        debugLog("StakingSetup _userStakes() start");
        debugLog("StakingSetup _userStakes userAddress", _userAddress);
        debugLog("StakingSetup _userStakes userName", _userName);
        debugLog("StakingSetup _userStakes amount", _amount);

        vm.startPrank(_userAddress);
        stakingERC20.approve(address(stakingRewards2), _amount);

        debugLog("StakingSetup _userStakes stakingERC20 address: %s", address(stakingERC20));
        debugLog("StakingSetup _userStakes stakingRewards2 address: %s", address(stakingRewards2));
        debugLog(
            "StakingSetup _userStakes _userAddress stakingERC20 allowance",
            stakingERC20.allowance(_userAddress, address(stakingRewards2))
        );
        debugLog("StakingSetup _userStakes _userStakes() balanceOf", stakingERC20.balanceOf(_userAddress));
        debugLog(
            "StakingSetup _userStakes _userAddress stakingERC20 allowance",
            stakingERC20.allowance(_userAddress, address(stakingRewards2))
        );

        // Check expected events
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Staked(_userAddress, _amount);
        stakingRewards2.stake(_amount);
        vm.stopPrank();
        TOTAL_STAKED_AMOUNT += _amount;
        debugLog("StakingSetup _userStakes() end");
    }

    function AliceStakes(uint256 _amount) internal {
        debugLog("StakingSetup AliceStakes() start");
        _userStakes(userAlice, "Alice", _amount);
        ALICE_STAKINGERC20_STAKEDAMOUNT += _amount;
        debugLog("StakingSetup AliceStakes() end");
    }

    function BobStakes(uint256 _amount) internal {
        debugLog("StakingSetup BobStakes() start");
        _userStakes(userBob, "Bob", _amount);
        BOB_STAKINGERC20_STAKEDAMOUNT += _amount;
        debugLog("StakingSetup BobStakes() end");
    }

    function CherryStakes(uint256 _amount) internal {
        debugLog("StakingSetup CherryStakes() start");
        _userStakes(userCherry, "Cherry", _amount);
        CHERRY_STAKINGERC20_STAKEDAMOUNT += _amount;
        debugLog("StakingSetup CherryStakes() end");
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

// ----------------------------------------------------------------------------

contract DuringStaking1WithoutWithdral is StakingSetup {
    /**
     * @param _stakingPercentageDuration : 0 - infinite
     * @param _claimPercentageDuration : 0 - 100
     */
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking1WithoutWithdral setUp() start");
        StakingSetup.setUp();
        verboseLog("DuringStaking1WithoutWithdral");
        debugLog("DuringStaking1WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
    }

    function testUsersStakingRewards() public {
        vm.prank(userStakingRewardAdmin);
        notifyRewardAmount(REWARD_INITIAL_AMOUNT);
        debugLog("Staking start time", STAKING_TIMESTAMP);

        AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);

        verboseLog("STAKING_TIMESTAMP = ", STAKING_TIMESTAMP);
        checkUsersStake();
        checkRewardPerToken(0, 0, 0);
        checkRewardForDuration(DELTA_0_00000000022);
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPercentage(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
        }

        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION);
        checkUsersStake();
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_TIMESTAMP;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);

        uint256 expectedRewardPerToken = (
            getRewardDurationReached() == REWARD_INITIAL_DURATION
                ? REWARD_INITIAL_AMOUNT * ONE_TOKEN / TOTAL_STAKED_AMOUNT
                : REWARD_INITIAL_AMOUNT * getRewardDurationReached() * ONE_TOKEN / TOTAL_STAKED_AMOUNT
                    / REWARD_INITIAL_DURATION
        );
        checkRewardPerToken(expectedRewardPerToken, 0, 0); // no delta needed
    }
}
// ------------------------------------

contract DuringStaking2WithoutWithdral is StakingSetup {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking2WithoutWithdral setUp() start");
        StakingSetup.setUp();
        verboseLog("DuringStaking2WithoutWithdral");
        debugLog("DuringStaking2WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
    }

    function testUsersStakingRewards() public {
        vm.prank(userStakingRewardAdmin);
        notifyRewardAmount(REWARD_INITIAL_AMOUNT);
        verboseLog("STAKING_TIMESTAMP = ", STAKING_TIMESTAMP);

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

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPercentage(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015, rewardErc20);
        }

        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION);
        checkUsersStake();
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_TIMESTAMP;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
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

        uint256 expectedRewardPerToken = (
            getRewardDurationReached() == REWARD_INITIAL_DURATION
                ? REWARD_INITIAL_AMOUNT * ONE_TOKEN / TOTAL_STAKED_AMOUNT
                : REWARD_INITIAL_AMOUNT * getRewardDurationReached() * ONE_TOKEN / TOTAL_STAKED_AMOUNT
                    / REWARD_INITIAL_DURATION
        );
        checkRewardPerToken(expectedRewardPerToken, DELTA_0_015, 0);
    }
}

// ------------------------------------

contract DuringStaking3WithoutWithdral is StakingSetup {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking3WithoutWithdral setUp() start");
        StakingSetup.setUp();
        verboseLog("DuringStaking3WithoutWithdral");
        debugLog("DuringStaking3WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
        checkCherryStake();
    }

    function testUsersStakingRewards() public {
        vm.prank(userStakingRewardAdmin);
        notifyRewardAmount(REWARD_INITIAL_AMOUNT);
        verboseLog("STAKING_TIMESTAMP = ", STAKING_TIMESTAMP);

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

        debugLog("STAKING_PERCENTAGE_DURATION : ", STAKING_PERCENTAGE_DURATION);
        debugLog("CLAIM_PERCENTAGE_DURATION > PERCENT_90 : ", (CLAIM_PERCENTAGE_DURATION > PERCENT_90 ? 1 : 0));
        debugLog("STAKING_PERCENTAGE_DURATION <= PERCENT_1 : ", (STAKING_PERCENTAGE_DURATION <= PERCENT_1 ? 1 : 0));
        debugLog("STAKING_PERCENTAGE_DURATION <= PERCENT_5 : ", (STAKING_PERCENTAGE_DURATION <= PERCENT_5 ? 1 : 0));
        debugLog("rewardsDelta : ", rewardsDelta);

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPercentage(CLAIM_PERCENTAGE_DURATION);
            debugLog("claimDelta : ", claimDelta);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", claimDelta, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", claimDelta, rewardErc20);
            userCherryClaimedRewards =
                checkUserClaim(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry", claimDelta, rewardErc20);
        }

        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION);
        checkUsersStake();
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_TIMESTAMP;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, rewardsDelta, 0);

        userBobExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("userBobExpectedRewards = ", userBobExpectedRewards);
        userBobExpectedRewards -= userBobClaimedRewards;
        debugLog("userBobExpectedRewards = ", userBobExpectedRewards);
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, rewardsDelta, 0);

        userCherryExpectedRewards =
            expectedStakingRewards(CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("userCherryExpectedRewards = ", userCherryExpectedRewards);
        userCherryExpectedRewards -= userCherryClaimedRewards;
        debugLog("userCherryExpectedRewards = ", userCherryExpectedRewards);
        checkStakingRewards(userCherry, "Cherry", userCherryExpectedRewards, rewardsDelta, 0);

        uint256 expectedRewardPerToken = (
            getRewardDurationReached() == REWARD_INITIAL_DURATION
                ? REWARD_INITIAL_AMOUNT * ONE_TOKEN / TOTAL_STAKED_AMOUNT
                : REWARD_INITIAL_AMOUNT * getRewardDurationReached() * ONE_TOKEN / TOTAL_STAKED_AMOUNT
                    / REWARD_INITIAL_DURATION
        );
        debugLog("expectedRewardPerToken = ", expectedRewardPerToken);

        checkRewardPerToken(expectedRewardPerToken, DELTA_0_015, 0);
    }
}

// ------------------------------------

// 1 staker deposit right after staking starts and removes all staked amount after half of staking percentage duration

contract DuringStaking1WithWithdral is StakingSetup {
    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    /* solhint-disable var-name-mixedcase */
    uint8 internal immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration
    /* solhint-enable var-name-mixedcase */

    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computation will underflow
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking1WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
        }
    }

    function setUp() public override {
        debugLog("DuringStaking1WithWithdral setUp() start");
        StakingSetup.setUp();
        verboseLog("DuringStaking1WithWithdral");
        debugLog("DuringStaking1WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
    }

    function testUsersStakingRewards() public {
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking1WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
            return;
        }

        vm.prank(userStakingRewardAdmin);
        notifyRewardAmount(REWARD_INITIAL_AMOUNT);

        AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);

        verboseLog("STAKING_TIMESTAMP = ", STAKING_TIMESTAMP);
        checkUsersStake();
        checkRewardPerToken(0, 0, 0);
        checkRewardForDuration(DELTA_0_00000000022);
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPercentage(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
        }

        verboseLog(
            "Staking duration (%%) = STAKING_PERCENTAGE_DURATION / 2  : ", STAKING_PERCENTAGE_DURATION / DIVIDE
        );
        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION / DIVIDE);
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);

        verboseLog("Staking duration reached (%%) before withdrawal(s) = : ", STAKING_PERCENTAGE_DURATION / DIVIDE);
        // Alice withdraws all
        withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);

        stakingElapsedTime = block.timestamp - STAKING_TIMESTAMP;

        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION);

        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);
        uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN
            / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;
        debugLog("expectedRewardPerToken = ", expectedRewardPerToken);

        checkRewardPerToken(expectedRewardPerToken, 0, 0); // no delta needed
    }
}

// ------------------------------------
// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

contract DuringStaking2WithWithdral is StakingSetup {
    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    /* solhint-disable var-name-mixedcase */
    uint8 internal immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration
    /* solhint-enable var-name-mixedcase */

    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computation will underflow
        /* solhint-disable reason-string */
        /* solhint-disable custom-errors */
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking2WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
        }
        /* solhint-enable custom-errors */
        /* solhint-enable reason-string */
    }

    function setUp() public override {
        debugLog("DuringStaking2WithWithdral setUp() start");
        StakingSetup.setUp();
        verboseLog("DuringStaking2WithWithdral");
        debugLog("DuringStaking2WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
    }

    function testUsersStakingRewards() public {
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking2WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
            return;
        }

        vm.prank(userStakingRewardAdmin);
        notifyRewardAmount(REWARD_INITIAL_AMOUNT);
        verboseLog("STAKING_TIMESTAMP = ", STAKING_TIMESTAMP);

        AliceStakes(ALICE_STAKINGERC20_MINTEDAMOUNT);
        BobStakes(BOB_STAKINGERC20_MINTEDAMOUNT);

        checkUsersStake();
        checkRewardPerToken(0, 0, 0);
        checkRewardForDuration(DELTA_0_00000000022);
        checkStakingTotalSupplyStaked();

        uint256 claimDelta = getClaimPercentDelta();
        uint256 rewardsDelta = getRewardPercentDelta();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPercentage(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", claimDelta, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", claimDelta, rewardErc20);
        }

        verboseLog(
            "Staking duration (%%) = STAKING_PERCENTAGE_DURATION / 2  : ", STAKING_PERCENTAGE_DURATION / DIVIDE
        );
        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION / DIVIDE);
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);

        verboseLog("Staking duration reached (%%) before withdrawal(s) = : ", STAKING_PERCENTAGE_DURATION / DIVIDE);
        // Alice withdraws all
        withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        // Bob withdraws all
        withdrawStake(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);

        stakingElapsedTime = block.timestamp - STAKING_TIMESTAMP;
        uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN
            / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;

        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION);
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
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
        debugLog("expectedRewardPerToken = ", expectedRewardPerToken);

        checkRewardPerToken(expectedRewardPerToken, 0, 1);
    }
}

// ------------------------------------

// 3 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

// contract DuringStaking3WithWithdral is DepositSetup3 {
contract DuringStaking3WithWithdral is StakingSetup {
    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    /* solhint-disable var-name-mixedcase */
    uint8 internal immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration
    /* solhint-enable var-name-mixedcase */

    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computation will underflow
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking3WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
        }
        // require(_claimPercentageDuration <= _stakingPercentageDuration, "DuringStaking3WithoutWithdral:
        // _claimPercentageDuration > _stakingPercentageDuration");
    }

    function setUp() public override {
        debugLog("DuringStaking3WithWithdral setUp() start");
        StakingSetup.setUp();
        verboseLog("DuringStaking3WithWithdral");
        debugLog("DuringStaking3WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
        checkCherryStake();
    }

    function testUsersStakingRewards() public {
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking3WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
            return;
        }

        vm.prank(userStakingRewardAdmin);
        notifyRewardAmount(REWARD_INITIAL_AMOUNT);
        verboseLog("STAKING_TIMESTAMP = ", STAKING_TIMESTAMP);

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
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userCherryExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobClaimedRewards;
        uint256 userCherryClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPercentage(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", claimDelta, rewardErc20);
            debugLog("testUsersStakingRewards: userAliceClaimedRewards = ", userAliceClaimedRewards);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", claimDelta, rewardErc20);
            debugLog("testUsersStakingRewards: userBobClaimedRewards = ", userBobClaimedRewards);
            userCherryClaimedRewards =
                checkUserClaim(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry", claimDelta, rewardErc20);
            debugLog("testUsersStakingRewards: userCherryClaimedRewards = ", userCherryClaimedRewards);
        }

        verboseLog(
            "Staking duration (%%) = STAKING_PERCENTAGE_DURATION / 2  : ", STAKING_PERCENTAGE_DURATION / DIVIDE
        );
        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION / DIVIDE);
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);

        verboseLog("Staking duration reached (%%) before withdrawal(s) = : ", STAKING_PERCENTAGE_DURATION / DIVIDE);

        // Alice withdraws all
        withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        // Bob withdraws all
        withdrawStake(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);
        // Cherry withdraws all
        withdrawStake(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT);
        stakingElapsedTime = block.timestamp - STAKING_TIMESTAMP;

        uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN
            / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;

        gotoStakingPercentage(STAKING_PERCENTAGE_DURATION);

        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("testUsersStakingRewards: userAliceExpectedRewards = ", userAliceExpectedRewards);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        debugLog("testUsersStakingRewards: userAliceExpectedRewards = ", userAliceExpectedRewards);
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, rewardsPercentDelta, rewardsUnitsDelta * 4);

        userBobExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("testUsersStakingRewards: userBobExpectedRewards = ", userBobExpectedRewards);
        userBobExpectedRewards -= userBobClaimedRewards;
        debugLog("testUsersStakingRewards: userBobExpectedRewards = ", userBobExpectedRewards);
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, rewardsPercentDelta, rewardsUnitsDelta * 2);

        userCherryExpectedRewards =
            expectedStakingRewards(CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("testUsersStakingRewards: userCherryExpectedRewards = ", userCherryExpectedRewards);
        userCherryExpectedRewards -= userCherryClaimedRewards;
        debugLog("testUsersStakingRewards: userCherryExpectedRewards = ", userCherryExpectedRewards);
        checkStakingRewards(
            userCherry, "Cherry", userCherryExpectedRewards, rewardsPercentDelta, rewardsUnitsDelta * 1
        );

        debugLog("expectedRewardPerToken = ", expectedRewardPerToken);
        checkRewardPerToken(expectedRewardPerToken, 0, 1);
    }
}

// --------------------------------------------------------
