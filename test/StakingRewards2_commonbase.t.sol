// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { console } from "forge-std/src/console.sol";
import { Test } from "forge-std/src/Test.sol";
import { stdMath } from "forge-std/src/StdMath.sol";

import { Utils } from "./utils/Utils.sol";

import { StakingRewards2 } from "../src/contracts/StakingRewards2.sol";
import { StakingRewards2Events } from "../src/contracts/StakingRewards2Events.sol";

import { RewardERC20 } from "./contracts/RewardERC20.sol";
import { StakingERC20 } from "./contracts/StakingERC20.sol";

import {
    PERCENT_1,
    PERCENT_5,
    PERCENT_10,
    PERCENT_90,
    PERCENT_95,
    PERCENT_100,
    DELTA_0_015,
    DELTA_0_08,
    DELTA_0_4,
    DELTA_0_5,
    DELTA_5,
    ONE_TOKEN
} from "./TestsConstants.sol";

// TODO : move to utils
contract TestLog is Test {
    bool internal debug = true; // TODO : set to false
    bool internal verbose = true; // TODO : set to false
    Utils internal utils;

    function debugLog(string memory _msg) public view {
        if (debug) console.log(_msg);
    }

    function debugLog(string memory _msg1, string memory _msg2) public view {
        if (debug) console.log(_msg1, _msg2);
    }

    function debugLog(string memory _msg, uint256 _val256) public view {
        if (debug) console.log(_msg, _val256);
    }

    function debugLog(string memory _msg, address _address) public view {
        if (debug) console.log(_msg, _address);
    }

    function debugLogTime(string memory _msg1, string memory _msg2) public view {
        if (debug) console.log(_msg1, _msg2, " ts: ", block.timestamp);
    }

    function debugLogTime(string memory _msg) public view {
        if (debug) console.log(_msg, " ts: ", block.timestamp);
    }

    function debugLogTime(string memory _msg, uint256 _val256) public view {
        if (debug) console.log(_msg, _val256, " ts: ", block.timestamp);
    }

    function debugLogTime(string memory _msg, address _address) public view {
        if (debug) console.log(_msg, _address, " ts: ", block.timestamp);
    }

    function verboseLog(string memory _msg1, string memory _msg2) public view {
        if (verbose) console.log(_msg1, _msg2);
    }

    function verboseLog(string memory _msg) public view {
        if (verbose) console.log(_msg);
    }

    function verboseLog(string memory _msg, uint256 _val256) public view {
        if (verbose) console.log(_msg, _val256);
    }

    function verboseLog(string memory _msg, address _address) public view {
        if (verbose) console.log(_msg, _address);
    }

    function verboseLogTime(string memory _msg1, string memory _msg2) public view {
        if (verbose) console.log(_msg1, _msg2, " ts: ", block.timestamp);
    }

    function verboseLogTime(string memory _msg) public view {
        if (verbose) console.log(_msg, " ts: ", block.timestamp);
    }

    function verboseLogTime(string memory _msg, uint256 _val256) public view {
        if (verbose) console.log(_msg, _val256, " ts: ", block.timestamp);
    }

    function verboseLogTime(string memory _msg, address _address) public view {
        if (verbose) console.log(_msg, _address, " ts: ", block.timestamp);
    }

    function errorLog(string memory _msg1, string memory _msg2) public view {
        console.log(_msg1, _msg2);
    }

    function errorLog(string memory _msg) public view {
        console.log(_msg);
    }

    function errorLog(string memory _msg, uint256 _val256) public view {
        console.log(_msg, _val256);
    }

    function errorLog(string memory _msg, address _address) public view {
        console.log(_msg, _address);
    }

    function errorLogTime(string memory _msg1, string memory _msg2) public view {
        console.log(_msg1, _msg2, " ts: ", block.timestamp);
    }

    function errorLogTime(string memory _msg) public view {
        console.log(_msg, " ts: ", block.timestamp);
    }

    function errorLogTime(string memory _msg, uint256 _val256) public view {
        console.log(_msg, _val256, " ts: ", block.timestamp);
    }

    function errorLogTime(string memory _msg, address _address) public view {
        console.log(_msg, _address, " ts: ", block.timestamp);
    }

    function warningLog(string memory _msg1, string memory _msg2) public view {
        console.log(_msg1, _msg2);
    }

    function warningLog(string memory _msg) public view {
        console.log(_msg);
    }

    function warningLog(string memory _msg, uint256 _val256) public view {
        console.log(_msg, _val256);
    }

    function warningLog(string memory _msg, address _address) public view {
        console.log(_msg, _address);
    }

    function warningLogTime(string memory _msg1, string memory _msg2) public view {
        console.log(_msg1, _msg2, " ts: ", block.timestamp);
    }

    function warningLogTime(string memory _msg) public view {
        console.log(_msg, " ts: ", block.timestamp);
    }

    function warningLogTime(string memory _msg, uint256 _val256) public view {
        console.log(_msg, _val256, " ts: ", block.timestamp);
    }

    function warningLogTime(string memory _msg, address _address) public view {
        console.log(_msg, _address, " ts: ", block.timestamp);
    }
} // TestLog

// ----------------

contract UsersSetup0 is TestLog {
    address payable[] internal users;

    uint256 internal constant MAX_USERS = 6;
    address internal erc20Admin;
    address internal erc20Minter;
    address internal userStakingRewardAdmin;

    function setUp() public virtual {
        verboseLog("UsersSetup0 setUp()");
        debugLog("UsersSetup0 setUp() start");
        utils = new Utils();
        users = utils.createUsers(MAX_USERS);

        erc20Admin = users[0];
        vm.label(erc20Admin, "ERC20Admin");
        erc20Minter = users[1];
        vm.label(erc20Minter, "ERC20Minter");
        userStakingRewardAdmin = users[2];
        vm.label(userStakingRewardAdmin, "StakingRewardAdmin");
    }
} // UsersSetup0

contract UsersSetup1 is UsersSetup0 {
    address internal userAlice;

    function setUp() public virtual override {
        verboseLog("UsersSetup1 setUp()");
        debugLog("UsersSetup1 setUp() start");
        UsersSetup0.setUp();

        userAlice = users[3];
        vm.label(userAlice, "Alice");
        debugLog("UsersSetup1 setUp() end");
    }
} // UsersSetup1

contract UsersSetup2 is UsersSetup1 {
    address internal userBob;

    function setUp() public virtual override {
        verboseLog("UsersSetup2 setUp()");
        debugLog("UsersSetup2 setUp() start");

        UsersSetup1.setUp();

        userBob = users[4];
        vm.label(userBob, "Bob");

        debugLog("UsersSetup2 setUp() end");
    }
} // UsersSetup2

// ----------------

contract UsersSetup3 is UsersSetup2 {
    address internal userCherry;

    function setUp() public virtual override {
        verboseLog("UsersSetup3 setUp()");
        debugLog("UsersSetup3 setUp() start");
        UsersSetup2.setUp();

        userCherry = users[5];
        vm.label(userCherry, "Cherry");

        debugLog("UsersSetup3 setUp() end");
    }
} // UsersSetup3

// ------------------------------------

contract Erc20Setup0 is UsersSetup0 {
    RewardERC20 internal rewardErc20;
    StakingERC20 internal stakingERC20;

    function setUp() public virtual override(UsersSetup0) {
        debugLog("Erc20Setup0 setUp() start");
        UsersSetup0.setUp();
        verboseLog("Erc20Setup0 setUp()");
        rewardErc20 = new RewardERC20(erc20Admin, erc20Minter, "TestReward", "TSTRWD");
        stakingERC20 = new StakingERC20(erc20Admin, erc20Minter, "Uniswap V2 Staking", "UNI-V2 Staking");
        debugLog("Erc20Setup0 setUp() end");
    }
} // Erc20Setup0

contract Erc20Setup1 is Erc20Setup0, UsersSetup1 {
    uint256 internal constant ALICE_STAKINGERC20_MINTEDAMOUNT = 3 * ONE_TOKEN;

    function setUp() public virtual override(Erc20Setup0, UsersSetup1) {
        debugLog("Erc20Setup1 setUp() start");
        Erc20Setup0.setUp();
        UsersSetup1.setUp();
        verboseLog("Erc20Setup1 setUp()");
        vm.startPrank(erc20Minter);
        stakingERC20.mint(userAlice, ALICE_STAKINGERC20_MINTEDAMOUNT);
        vm.stopPrank();
        debugLog("Erc20Setup1 setUp() end");
    }
} // Erc20Setup1

contract Erc20Setup2 is Erc20Setup1, UsersSetup2 {
    uint256 internal constant BOB_STAKINGERC20_MINTEDAMOUNT = 2 * ONE_TOKEN;

    function setUp() public virtual override(Erc20Setup1, UsersSetup2) {
        debugLog("Erc20Setup2 setUp() start");
        Erc20Setup1.setUp();
        UsersSetup2.setUp();
        verboseLog("Erc20Setup2 setUp()");
        vm.startPrank(erc20Minter);
        stakingERC20.mint(userBob, BOB_STAKINGERC20_MINTEDAMOUNT);
        vm.stopPrank();
        debugLog("Erc20Setup2 setUp() end");
    }
} // Erc20Setup2

contract Erc20Setup3 is Erc20Setup2, UsersSetup3 {
    uint256 internal constant CHERRY_STAKINGERC20_MINTEDAMOUNT = 1 * ONE_TOKEN;

    function setUp() public virtual override(Erc20Setup2, UsersSetup3) {
        debugLog("Erc20Setup3 setUp() start");
        Erc20Setup2.setUp();
        UsersSetup3.setUp();
        verboseLog("Erc20Setup3 setUp()");
        vm.startPrank(erc20Minter);
        stakingERC20.mint(userCherry, CHERRY_STAKINGERC20_MINTEDAMOUNT);
        vm.stopPrank();
        debugLog("Erc20Setup3 setUp() end");
    }
} // Erc20Setup3

// --------------------------------------------------------

abstract contract _StakingPreSetup is TestLog {
    // Rewards constants

    // Duration of the rewards program
    /* solhint-disable var-name-mixedcase */
    // uint256 internal constant REWARD_INITIAL_DURATION = 10_000; // 1e4 ; 10 000 s. = 2 h. 46 m. 40 s.
    uint256 internal constant REWARD_INITIAL_DURATION = 52 weeks; // = ~1 year

    // Initial timestamp and block number
    uint256 internal immutable INITIAL_BLOCK_TIMESTAMP = block.timestamp;
    uint256 internal immutable INITIAL_BLOCK_NUMBER = block.number;

    // 1 block each 10 seconds
    uint8 internal constant BLOCK_TIME = 10;

    uint256 internal REWARD_INITIAL_AMOUNT;
    /* solhint-enable var-name-mixedcase */

    function setUp() public virtual {
        debugLog("_StakingPreSetup setUp() start");
        debugLog("_StakingPreSetup: REWARD_INITIAL_DURATION = ", REWARD_INITIAL_DURATION);
        debugLog("_StakingPreSetup: BLOCK_TIME = ", BLOCK_TIME);
        verboseLog("_StakingPreSetup setUp()");
        debugLog("_StakingPreSetup setUp() end");
    }

    function expectedStakingRewards(
        uint256 _stakedAmount,
        uint256 _rewardDurationReached,
        uint256 _rewardTotalDuration
    )
        internal
        view
        virtual
        returns (uint256 expectedRewardsAmount);

    function displayTime() internal view {
        debugLog(" displayTime: block.timestamp = ", block.timestamp);
        debugLog(" displayTime: block.number", block.number);
    }

    // Use these functions to go to a specific timestamp in place of vm.warp
    // to insure that the block number is also updated consistently

    function gotoTimestamp(uint256 _timeStamp) internal {
        gotoTimestamp(_timeStamp, false);
    }

    function gotoTimestamp(uint256 _timeStamp, bool _displayTime) internal {
        debugLog("gotoTimestamp: ", _timeStamp);
        if (_displayTime) {
            displayTime();
        }
        vm.warp(_timeStamp);
        vm.roll(_timeStamp / BLOCK_TIME);
        if (_displayTime) {
            displayTime();
        }
    }
} // _StakingPreSetup

abstract contract StakingPreSetup is _StakingPreSetup {
    StakingRewards2 internal stakingRewards2;
    /* solhint-disable var-name-mixedcase */
    uint256 internal STAKING_TIMESTAMP;

    uint256 internal TOTAL_STAKED_AMOUNT;
    uint256 internal STAKING_PERCENTAGE_DURATION;
    uint256 internal CLAIM_PERCENTAGE_DURATION;
    /* solhint-enable var-name-mixedcase */

    function setUp() public virtual override {
        debugLog("StakingPreSetup setUp() start");
        _StakingPreSetup.setUp();
        verboseLog("StakingPreSetup setUp()");
        debugLog("StakingPreSetup setUp() end");
    }

    function checkStakingTotalSupplyStaked() internal {
        debugLog("checkStakingTotalSupplyStaked");
        uint256 stakingRewardsTotalSupply = stakingRewards2.totalSupply();
        debugLog("checkStakingTotalSupplyStaked: stakingRewardsTotalSupply = ", stakingRewardsTotalSupply);
        assertEq(TOTAL_STAKED_AMOUNT, stakingRewardsTotalSupply);
    }

    function getRewardDurationReached() internal view returns (uint256) {
        debugLog("getRewardDurationReached");
        uint256 rewardDurationReached = (
            STAKING_PERCENTAGE_DURATION >= PERCENT_100
                ? REWARD_INITIAL_DURATION
                : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100
        );
        verboseLog("getRewardDurationReached: rewardDurationReached = ", rewardDurationReached);
        return rewardDurationReached;
    }

    function getLastRewardTime() internal view returns (uint256) {
        // debugLog("getLastRewardTime");
        uint256 lastTimeReward = (
            block.timestamp < STAKING_TIMESTAMP + REWARD_INITIAL_DURATION
                ? block.timestamp
                : STAKING_TIMESTAMP + REWARD_INITIAL_DURATION
        ); // last time reward

        verboseLog("getLastRewardTime: lastTimeReward = ", lastTimeReward);
        return lastTimeReward;
    }

    function getRewardDurationReached(uint256 _durationReached) internal view /* pure */ returns (uint256) {
        debugLog("getRewardDurationReached: ", _durationReached);
        uint256 rewardDurationReached =
            (_durationReached >= REWARD_INITIAL_DURATION ? REWARD_INITIAL_DURATION : _durationReached);
        debugLog("getRewardDurationReached: rewardDurationReached = ", rewardDurationReached);
        return rewardDurationReached;
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) internal {
        uint256 userStakedBalance = stakingRewards2.balanceOf(address(_user));
        verboseLog(_userName);
        verboseLog(" staked balance: ", userStakedBalance);
        assertEq(_stakeAmount, userStakedBalance);
    }

    function checkRewardPerToken(
        uint256 _expectedRewardPerToken,
        uint256 _percentDelta,
        uint8 _unitsDelta
    )
        internal
    {
        debugLog("checkRewardPerToken: _expectedRewardPerToken = ", _expectedRewardPerToken);
        uint256 stakingRewardsRewardPerToken = stakingRewards2.rewardPerToken();
        if (stakingRewardsRewardPerToken != _expectedRewardPerToken) {
            debugLog("checkRewardPerToken: stakingRewardsRewardPerToken = ", stakingRewardsRewardPerToken);
            if (_expectedRewardPerToken == 0) {
                fail(
                    "StakingPreSetup: checkRewardPerToken: stakingReward != expected && _expectedRewardPerToken == 0"
                );
            }
            uint256 percentDelta = stdMath.percentDelta(stakingRewardsRewardPerToken, _expectedRewardPerToken);

            debugLog("checkRewardPerToken: delta = ", percentDelta);
            if (percentDelta > _percentDelta) {
                if (_unitsDelta > 0) {
                    debugLog("checkRewardPerToken: _unitsDelta = ", _unitsDelta);
                    assertApproxEqAbs(stakingRewardsRewardPerToken, _expectedRewardPerToken, _unitsDelta);
                } else {
                    if (_percentDelta == 0) {
                        assertEq(stakingRewardsRewardPerToken, _expectedRewardPerToken);
                    } else {
                        assertApproxEqRel(stakingRewardsRewardPerToken, _expectedRewardPerToken, _percentDelta);
                    }
                }
            }
        }
    }

    function getClaimPercentDelta() internal view returns (uint256) {
        // Longer staking period = better accuracy : less delta
        uint256 claimDelta = CLAIM_PERCENTAGE_DURATION <= PERCENT_10
            ? (CLAIM_PERCENTAGE_DURATION <= PERCENT_1 ? DELTA_5 : DELTA_0_4)
            : DELTA_0_015;
        verboseLog("claimDelta : ", claimDelta);
        return claimDelta;
    }

    function getRewardPercentDelta() public view returns (uint256) {
        verboseLog("getRewardPercentDelta");
        // Longer staking period = better accuracy : less delta
        uint256 rewardsPercentDelta = CLAIM_PERCENTAGE_DURATION > PERCENT_90
            ? (CLAIM_PERCENTAGE_DURATION > PERCENT_95 ? DELTA_5 : DELTA_0_5)
            : STAKING_PERCENTAGE_DURATION <= PERCENT_10
                ? STAKING_PERCENTAGE_DURATION <= PERCENT_5
                    ? STAKING_PERCENTAGE_DURATION <= PERCENT_1 ? DELTA_0_5 : DELTA_5
                    : DELTA_0_08
                : DELTA_0_015;

        verboseLog("getRewardDelta = ", rewardsPercentDelta);
        return rewardsPercentDelta;
    }

    function getRewardUnitsDelta() public pure returns (uint8) {
        // Longer staking period = better accuracy : less delta
        return 1;
    }

    function checkStakingRewards(
        address _staker,
        string memory _stakerName,
        uint256 _expectedRewardAmount,
        uint256 _percentDelta,
        uint8 _unitsDelta
    )
        internal
    {
        debugLog("checkStakingRewards: _stakerName : ", _stakerName);
        debugLog("checkStakingRewards: _expectedRewardAmount : ", _expectedRewardAmount);
        debugLog("checkStakingRewards: _percentDelta : ", _percentDelta);
        uint256 stakerRewards = stakingRewards2.earned(_staker);
        debugLog("checkStakingRewards: stakerRewards = ", stakerRewards);

        if (stakerRewards != _expectedRewardAmount) {
            debugLog("stakerRewards != _expectedRewardAmount");
            if (_expectedRewardAmount == 0) {
                fail("StakingSetup: checkStakingRewards: rewards != _expected && _expectedRewardAmount == 0");
            }
            uint256 percentDelta = stdMath.percentDelta(stakerRewards, _expectedRewardAmount);
            debugLog("checkStakingRewards: delta = ", percentDelta);
            if (percentDelta > _percentDelta) {
                if (_unitsDelta > 0) {
                    debugLog("checkStakingRewards: _unitsDelta = ", _unitsDelta);
                    debugLog("checkStakingRewards: assertApproxEqAbs stakerRewards= ", stakerRewards);
                    debugLog("checkStakingRewards: assertApproxEqAbs _expectedRewardAmount= ", _expectedRewardAmount);
                    debugLog("checkStakingRewards: assertApproxEqAbs stakerRewards= ", _unitsDelta);
                    assertApproxEqAbs(stakerRewards, _expectedRewardAmount, _unitsDelta);
                } else {
                    // debugLog("checkStakingRewards: 1");
                    if (_percentDelta == 0) {
                        // debugLog("checkStakingRewards: 2");
                        assertEq(stakerRewards, _expectedRewardAmount);
                    } else {
                        // debugLog("checkStakingRewards: 3");
                        assertApproxEqRel(stakerRewards, _expectedRewardAmount, _percentDelta);
                    }
                }
            }
        }
        // debugLog("checkStakingRewards: 4");
        verboseLog(_stakerName);
        verboseLog(" rewards: ", stakerRewards);
    }

    function checkUserClaim(
        address _user,
        uint256 _stakeAmount,
        string memory _userName,
        uint256 _delta,
        RewardERC20 rewardErc20
    )
        internal
        returns (uint256 claimedRewards_)
    {
        if (CLAIM_PERCENTAGE_DURATION > 0) {
            verboseLog("checkUserClaim:");
            verboseLog("checkUserClaim: _userName:", _userName);
            uint256 stakingElapsedTime = block.timestamp - STAKING_TIMESTAMP;
            debugLog("checkUserClaim: stakingElapsedTime = ", stakingElapsedTime);
            uint256 rewardErc20UserBalance = rewardErc20.balanceOf(_user);
            verboseLog("checkUserClaim: before: user (reward) balance = ", rewardErc20UserBalance);
            uint256 expectedRewards =
                expectedStakingRewards(_stakeAmount, stakingElapsedTime, REWARD_INITIAL_DURATION);
            verboseLog("checkUserClaim: expectedRewards = ", expectedRewards);
            vm.prank(_user);
            vm.expectEmit(true, true, false, false, address(stakingRewards2));
            emit StakingRewards2Events.RewardPaid(_user, expectedRewards);
            stakingRewards2.getReward();
            // Check user rewards balance before/after claim
            uint256 rewardErc20UserBalanceAfterClaim = rewardErc20.balanceOf(_user);
            claimedRewards_ = rewardErc20UserBalanceAfterClaim - rewardErc20UserBalance;
            verboseLog("checkUserClaim: after: user reward balance = ", rewardErc20UserBalanceAfterClaim);
            verboseLog("checkUserClaim: -> user CLAIMEDREWARDS = ", claimedRewards_);
            if (_delta == 0) {
                assertEq(expectedRewards, claimedRewards_);
            } else {
                assertApproxEqRel(expectedRewards, claimedRewards_, _delta);
            }
        }
    }

    // getRewardForDuration should stay constant
    //     Check getRewardForDuration() == REWARD_INITIAL_AMOUNT
    //     Unless the reward duration is greater than REWARD_INITIAL_DURATION => 0
    function _checkRewardForDuration(uint256 _delta) internal {
        debugLog("_checkRewardForDuration");
        if (REWARD_INITIAL_AMOUNT < REWARD_INITIAL_DURATION) {
            warningLog("_checkRewardForDuration: REWARD_INITIAL_AMOUNT < REWARD_INITIAL_DURATION");
            warningLog("_checkRewardForDuration: => reward is likely to be ZERO !");
        }
        uint256 INITIAL_BLOCK_TIMESTAMP = block.timestamp;
        uint256 rewardForDuration;
        rewardForDuration = stakingRewards2.getRewardForDuration();
        debugLog("_checkRewardForDuration: getRewardForDuration  = ", rewardForDuration);
        debugLog("_checkRewardForDuration: REWARD_INITIAL_AMOUNT = ", REWARD_INITIAL_AMOUNT);
        assertApproxEqRel(rewardForDuration, REWARD_INITIAL_AMOUNT, _delta);

        gotoTimestamp(STAKING_TIMESTAMP + REWARD_INITIAL_DURATION); // epoch last time reward
        rewardForDuration = stakingRewards2.getRewardForDuration();
        assertApproxEqRel(rewardForDuration, REWARD_INITIAL_AMOUNT, _delta);

        gotoTimestamp(STAKING_TIMESTAMP + REWARD_INITIAL_DURATION + 1); // epoch ended
        rewardForDuration = stakingRewards2.getRewardForDuration();
        assertApproxEqRel(rewardForDuration, REWARD_INITIAL_AMOUNT, _delta);

        // set back to initial time
        gotoTimestamp(INITIAL_BLOCK_TIMESTAMP);

        verboseLog("_checkRewardForDuration: ok");
    }

    // Comment parameter name to silent "Unused function parameter." warning
    function checkRewardForDuration(uint256 /* _delta */ ) internal virtual {
        debugLog("checkRewardForDuration()");
        assertFalse(true, "IMPLEMENT checkRewardForDuration() in derived contract");
    }

    function checkStakingPeriod(uint256 _stakingPercentageDurationReached) internal {
        debugLog("checkStakingPeriod: _stakingPercentageDurationReached : ", _stakingPercentageDurationReached);
        assertTrue(
            _stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION,
            "checkStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"
        );
        uint256 stakingTimeReached = STAKING_TIMESTAMP
            + (
                _stakingPercentageDurationReached >= PERCENT_100
                    ? REWARD_INITIAL_DURATION
                    : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100
            );
        debugLog("checkStakingPeriod: stakingTimeReached = ", stakingTimeReached);
        uint256 lastTimeReward = stakingRewards2.lastTimeRewardApplicable();
        debugLog("checkStakingPeriod: lastTimeReward = ", lastTimeReward);
        assertEq(block.timestamp, stakingTimeReached, "Wrong block.timestamp");
        assertEq(lastTimeReward, stakingTimeReached, "Wrong lastTimeReward");
    }

    function withdrawStake(address _user, uint256 _amount) public {
        debugLog("withdrawStake: _user : ", _user);
        debugLog("withdrawStake: _amount : ", _amount);
        uint256 balanceOfUserBeforeWithdrawal = stakingRewards2.balanceOf(_user);
        debugLog("withdrawStake: balanceOfUserBeforeWithdrawal = ", balanceOfUserBeforeWithdrawal);
        // Check emitted event
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.Withdrawn(_user, _amount);
        vm.prank(_user);
        stakingRewards2.withdraw(_amount);
        uint256 balanceOfUserAfterWithdrawal = stakingRewards2.balanceOf(_user);
        debugLog("withdrawStake: balanceOfUserAfterWithdrawal = ", balanceOfUserAfterWithdrawal);
        assertEq(balanceOfUserBeforeWithdrawal - _amount, balanceOfUserAfterWithdrawal);
    }

    // Goto some staking time within period
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) internal returns (uint256) {
        debugLog("gotoStakingPeriod: _stakingPercentageDurationReached : ", _stakingPercentageDurationReached);
        assertTrue(
            _stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION,
            "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"
        );
        uint256 gotoStakingPeriodResult = STAKING_TIMESTAMP
            + (
                _stakingPercentageDurationReached >= PERCENT_100
                    ? REWARD_INITIAL_DURATION
                    : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100
            );
        verboseLog("gotoStakingPeriod: gotoStakingPeriodResult = ", gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    function getStakingTimeReached() internal view returns (uint256) {
        debugLog("getStakingTimeReached");
        uint256 rewardDurationReached = getRewardDurationReached();
        debugLog("getStakingTimeReached: rewardDurationReached : ", rewardDurationReached);
        return STAKING_TIMESTAMP + rewardDurationReached;
    }

    function getStakingDuration() internal view returns (uint256) {
        debugLog("getStakingDuration");
        uint256 stakingDuration = REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100;
        verboseLog("getStakingDuration: stakingDuration = ", stakingDuration);
        return stakingDuration;
    }

    function getRewardedStakingDuration(uint8 _divide) internal view returns (uint256) {
        debugLog("getRewardedStakingDuration: _divide : ", _divide);
        uint256 stakingDuration = getStakingDuration() / _divide;
        debugLog("getRewardedStakingDuration: stakingDuration = ", stakingDuration);
        uint256 rewardedStakingDuration = getRewardDurationReached(stakingDuration);
        verboseLog("getRewardedStakingDuration: rewardedStakingDuration = ", rewardedStakingDuration);
        return rewardedStakingDuration;
    }

    function notifyVariableRewardAmount(
        uint256 _constantRewardRatePerTokenStored,
        uint256 _variableRewardMaxTotalSupply
    )
        internal
    {
        notifyVariableRewardAmount(_constantRewardRatePerTokenStored, _variableRewardMaxTotalSupply, address(0));
    }

    function notifyVariableRewardAmount(
        uint256 _constantRewardRatePerTokenStored,
        uint256 _variableRewardMaxTotalSupply,
        address _userStakingRewardAdmin
    )
        internal
    {
        debugLog(
            "notifyVariableRewardAmount: _constantRewardRatePerTokenStored : ", _constantRewardRatePerTokenStored
        );
        debugLog("notifyVariableRewardAmount: _variableRewardMaxTotalSupply : ", _variableRewardMaxTotalSupply);

        if (_userStakingRewardAdmin!= address(0)) vm.prank(_userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(_variableRewardMaxTotalSupply);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(_constantRewardRatePerTokenStored);
        stakingRewards2.notifyVariableRewardAmount(_constantRewardRatePerTokenStored, _variableRewardMaxTotalSupply);
        STAKING_TIMESTAMP = block.timestamp;

    }

    function notifyRewardAmount(
        uint256 _reward
    )
        internal
    {
        notifyRewardAmount(_reward, address(0));
    }

    function notifyRewardAmount(uint256 _reward, address _userStakingRewardAdmin) internal {
        debugLog("notifyRewardAmount: reward : ", _reward);
        if (_userStakingRewardAdmin!= address(0)) vm.prank(_userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAdded(1);
        stakingRewards2.notifyRewardAmount(_reward);
        STAKING_TIMESTAMP = block.timestamp;
    }

    function setRewardsDuration(uint256 _rewardsDuration) internal {
        setRewardsDuration(_rewardsDuration, address(0));
    }

    function setRewardsDuration(uint256 _rewardsDuration, address _userStakingRewardAdmin) internal {
        debugLog("setRewardsDuration: _rewardsDuration : ", _rewardsDuration);
        if (_userStakingRewardAdmin!= address(0)) vm.prank(_userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(_rewardsDuration);
        stakingRewards2.setRewardsDuration(_rewardsDuration);
    }

    function displayEarned(address _staker, string memory _stakerName) internal view {
        displayEarned(_staker, _stakerName, false);
    }

    function displayEarned(address _staker, string memory _stakerName, bool _displayTime) internal view {
        debugLog("displayEarned: %s ", _staker);
        debugLog("displayEarned: %s ", _stakerName);
        if (_displayTime) {
            displayTime();
        }
        uint256 stakerRewards = stakingRewards2.earned(_staker);
        debugLog("displayEarned: stakerRewards = %d ", stakerRewards);
    }
} // StakingPreSetup
