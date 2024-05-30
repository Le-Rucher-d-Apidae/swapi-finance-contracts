// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { console } from "forge-std/src/console.sol";
import { Test } from "forge-std/src/Test.sol";
import { stdMath } from "forge-std/src/StdMath.sol";

import { Utils } from "./utils/Utils.sol";

import { StakingRewards2 } from "../src/contracts/StakingRewards2.sol";
import { StakingRewards2Events } from "../src/contracts/StakingRewards2Events.sol";
import { StakeZero, WithdrawZero } from "../src/contracts/StakingRewards2Errors.sol";

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

contract UsersSetup is TestLog {
    address payable[] internal users;

    /* solhint-disable var-name-mixedcase */
    uint256 internal constant MAX_USERS = 6;
    /* solhint-enable var-name-mixedcase */
    address internal erc20Admin;
    address internal erc20Minter;
    address internal userStakingRewardAdmin;

    address internal userAlice;
    address internal userBob;
    address internal userCherry;

    function setUp() public virtual {
        verboseLog("UsersSetup setUp()");
        debugLog("UsersSetup setUp() start");
        utils = new Utils();
        users = utils.createUsers(MAX_USERS);

        erc20Admin = users[0];
        vm.label(erc20Admin, "ERC20Admin");
        erc20Minter = users[1];
        vm.label(erc20Minter, "ERC20Minter");
        userStakingRewardAdmin = users[2];
        vm.label(userStakingRewardAdmin, "StakingRewardAdmin");

        userAlice = users[3];
        vm.label(userAlice, "Alice");

        userBob = users[4];
        vm.label(userBob, "Bob");

        userCherry = users[5];
        vm.label(userCherry, "Cherry");
    }
} // UsersSetup

contract Erc20Setup is UsersSetup {
    RewardERC20 internal rewardErc20;
    StakingERC20 internal stakingERC20;

    /* solhint-disable var-name-mixedcase */
    uint256 internal constant ALICE_STAKINGERC20_MINTEDAMOUNT = 3 * ONE_TOKEN;
    uint256 internal constant BOB_STAKINGERC20_MINTEDAMOUNT = 2 * ONE_TOKEN;
    uint256 internal constant CHERRY_STAKINGERC20_MINTEDAMOUNT = 1 * ONE_TOKEN;
    /* solhint-enable var-name-mixedcase */

    function setUp() public virtual override(UsersSetup) {
        debugLog("Erc20Setup0 setUp() start");
        verboseLog("Erc20Setup0 setUp()");
        UsersSetup.setUp();

        // Create ERC20 contracts
        rewardErc20 = new RewardERC20(erc20Admin, erc20Minter, "TestReward", "TSTRWD");
        stakingERC20 = new StakingERC20(erc20Admin, erc20Minter, "Uniswap V2 Staking", "UNI-V2 Staking");

        // Mint ERC20 tokens
        vm.startPrank(erc20Minter);

        debugLog("Erc20Setup1 setUp() minting Alice : %s", ALICE_STAKINGERC20_MINTEDAMOUNT);
        stakingERC20.mint(userAlice, ALICE_STAKINGERC20_MINTEDAMOUNT);
        stakingERC20.mint(userBob, BOB_STAKINGERC20_MINTEDAMOUNT);
        stakingERC20.mint(userCherry, CHERRY_STAKINGERC20_MINTEDAMOUNT);

        vm.stopPrank();

        debugLog("Erc20Setup0 setUp() end");
    }
} // Erc20Setup

// --------------------------------------------------------

/* solhint-disable contract-name-camelcase */

abstract contract StakingPreSetupDuration is TestLog {
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
        debugLog("StakingPreSetupDuration setUp() start");
        debugLog("StakingPreSetupDuration: REWARD_INITIAL_DURATION = ", REWARD_INITIAL_DURATION);
        debugLog("StakingPreSetupDuration: BLOCK_TIME = ", BLOCK_TIME);
        verboseLog("StakingPreSetupDuration setUp()");
        debugLog("StakingPreSetupDuration setUp() end");
    }

    function expectedStakingRewards(
        uint256 _stakedAmount,
        uint256 _rewardDurationReached,
        uint256 _rewardTotalDuration
    )
        internal
        virtual
        returns (uint256 expectedRewardsAmount)
    {
        debugLog("expectedStakingRewards()");
        debugLog("expectedStakingRewards: _stakedAmount = ", _stakedAmount);
        debugLog("expectedStakingRewards: _rewardDurationReached = ", _rewardDurationReached);
        debugLog("expectedStakingRewards: _rewardTotalDuration = ", _rewardTotalDuration);
        assertFalse(true, "IMPLEMENT expectedStakingRewards() in derived contract");
        fail("expectedStakingRewards: not implemented");
        expectedRewardsAmount = 0;
    }

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
        if (_timeStamp < block.timestamp) {
            revert("Cannot go back in time");
        }
        vm.warp(_timeStamp);
        vm.roll(_timeStamp / BLOCK_TIME);
        if (_displayTime) {
            displayTime();
        }
    }
} // StakingPreSetupDuration

abstract contract StakingPreSetupUtils is StakingPreSetupDuration {
    StakingRewards2 internal stakingRewards2;
    /* solhint-disable var-name-mixedcase */
    uint256 internal STAKING_START_TIMESTAMP;
    uint256 internal STAKING_END_TIMESTAMP;

    uint256 internal TOTAL_STAKED_AMOUNT;
    uint256 internal STAKING_PERCENTAGE_DURATION;
    uint256 internal CLAIM_PERCENTAGE_DURATION;
    /* solhint-enable var-name-mixedcase */

    function setUp() public virtual override {
        debugLog("StakingPreSetupUtils setUp() start");
        StakingPreSetupDuration.setUp();
        verboseLog("StakingPreSetupUtils setUp()");
        debugLog("StakingPreSetupUtils setUp() end");
    }

    function checkStakingTotalSupplyStaked() internal {
        debugLog("StakingPreSetupUtils:checkStakingTotalSupplyStaked");
        uint256 stakingRewardsTotalSupply = stakingRewards2.totalSupply();
        debugLog(
            "StakingPreSetupUtils:checkStakingTotalSupplyStaked: stakingRewardsTotalSupply = ",
            stakingRewardsTotalSupply
        );
        assertEq(TOTAL_STAKED_AMOUNT, stakingRewardsTotalSupply);
    }

    function getRewardDurationReached() internal view returns (uint256) {
        debugLog("StakingPreSetupUtils:getRewardDurationReached");
        uint256 rewardDurationReached = (
            STAKING_PERCENTAGE_DURATION >= PERCENT_100
                ? REWARD_INITIAL_DURATION
                : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100
        );
        verboseLog("StakingPreSetupUtils:getRewardDurationReached: rewardDurationReached = %s", rewardDurationReached);
        return rewardDurationReached;
    }

    function getLastRewardTime() internal view returns (uint256) {
        debugLog("StakingPreSetupUtils: getLastRewardTime");
        uint256 lastTimeReward = (
            block.timestamp < STAKING_END_TIMESTAMP
                ? block.timestamp
                : STAKING_END_TIMESTAMP
        );
        verboseLog("StakingPreSetupUtils:getLastRewardTime: lastTimeReward = %s", lastTimeReward);
        return lastTimeReward;
    }

    function getRewardDurationReached(uint256 _durationReached) internal view /* pure */ returns (uint256) {
        debugLog("StakingPreSetupUtils:getRewardDurationReached: ", _durationReached);
        uint256 rewardDurationReached =
            (_durationReached >= REWARD_INITIAL_DURATION ? REWARD_INITIAL_DURATION : _durationReached);
        debugLog("StakingPreSetupUtils:getRewardDurationReached: rewardDurationReached = ", rewardDurationReached);
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
        debugLog("StakingPreSetupUtils:checkRewardPerToken: _expectedRewardPerToken = ", _expectedRewardPerToken);
        uint256 stakingRewardsRewardPerToken = stakingRewards2.rewardPerToken();
        if (stakingRewardsRewardPerToken != _expectedRewardPerToken) {
            debugLog(
                "StakingPreSetupUtils:checkRewardPerToken: stakingRewardsRewardPerToken = ",
                stakingRewardsRewardPerToken
            );
            if (_expectedRewardPerToken == 0) {
                fail(
                    "StakingPreSetupUtils:checkRewardPerToken: stakingReward!=expected && _expectedRewardPerToken == 0"
                );
            }
            uint256 percentDelta = stdMath.percentDelta(stakingRewardsRewardPerToken, _expectedRewardPerToken);

            debugLog("StakingPreSetupUtils;checkRewardPerToken: delta = ", percentDelta);
            if (percentDelta > _percentDelta) {
                if (_unitsDelta > 0) {
                    debugLog("StakingPreSetupUtils:checkRewardPerToken: _unitsDelta = ", _unitsDelta);
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
        verboseLog("StakingPreSetupUtils:claimDelta : ", claimDelta);
        return claimDelta;
    }

    function getRewardPercentDelta() public view returns (uint256) {
        verboseLog("StakingPreSetupUtils:getRewardPercentDelta");
        // Longer staking period = better accuracy : less delta
        uint256 rewardsPercentDelta = CLAIM_PERCENTAGE_DURATION > PERCENT_90
            ? (CLAIM_PERCENTAGE_DURATION > PERCENT_95 ? DELTA_5 : DELTA_0_5)
            : STAKING_PERCENTAGE_DURATION <= PERCENT_10
                ? STAKING_PERCENTAGE_DURATION <= PERCENT_5
                    ? STAKING_PERCENTAGE_DURATION <= PERCENT_1 ? DELTA_0_5 : DELTA_5
                    : DELTA_0_08
                : DELTA_0_015;

        verboseLog("StakingPreSetupUtils:getRewardDelta = ", rewardsPercentDelta);
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
        debugLog("StakingPreSetupUtils:checkStakingRewards: _stakerName : ", _stakerName);
        debugLog("StakingPreSetupUtils:checkStakingRewards: _expectedRewardAmount : ", _expectedRewardAmount);
        debugLog("StakingPreSetupUtils:checkStakingRewards: _percentDelta : ", _percentDelta);
        uint256 stakerRewards = stakingRewards2.earned(_staker);
        debugLog("StakingPreSetupUtils:checkStakingRewards: stakerRewards = ", stakerRewards);

        if (stakerRewards != _expectedRewardAmount) {
            debugLog("stakerRewards != _expectedRewardAmount");
            if (_expectedRewardAmount == 0) {
                fail("StakingPreSetupUtils:checkStakingRewards: rewards != _expected && _expectedRewardAmount == 0");
            }
            uint256 percentDelta = stdMath.percentDelta(stakerRewards, _expectedRewardAmount);
            debugLog("StakingPreSetupUtils:checkStakingRewards: delta = ", percentDelta);
            if (percentDelta > _percentDelta) {
                if (_unitsDelta > 0) {
                    debugLog("StakingPreSetupUtils:checkStakingRewards: _unitsDelta = ", _unitsDelta);
                    debugLog(
                        "StakingPreSetupUtils:checkStakingRewards: assertApproxEqAbs stakerRewards= ", stakerRewards
                    );
                    debugLog(
                        "StakingPreSetupUtils:checkStakingRewards: assertApproxEqAbs _expectedRewardAmount= ",
                        _expectedRewardAmount
                    );
                    debugLog(
                        "StakingPreSetupUtils:checkStakingRewards: assertApproxEqAbs stakerRewards= ", _unitsDelta
                    );
                    assertApproxEqAbs(stakerRewards, _expectedRewardAmount, _unitsDelta);
                } else {
                    if (_percentDelta == 0) {
                        assertEq(stakerRewards, _expectedRewardAmount);
                    } else {
                        assertApproxEqRel(stakerRewards, _expectedRewardAmount, _percentDelta);
                    }
                }
            }
        }
        verboseLog(_stakerName);
        verboseLog("StakingPreSetupUtils:checkStakingRewards: rewards = %s", stakerRewards);
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
            verboseLog("StakingPreSetupUtils:checkUserClaim:");
            verboseLog("StakingPreSetupUtils:checkUserClaim: _userName:", _userName);
            uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIMESTAMP;
            debugLog("StakingPreSetupUtils:checkUserClaim: stakingElapsedTime = ", stakingElapsedTime);
            uint256 rewardErc20UserBalance = rewardErc20.balanceOf(_user);
            verboseLog(
                "StakingPreSetupUtils:checkUserClaim: before: user (reward) balance = ", rewardErc20UserBalance
            );
            uint256 expectedRewards =
                expectedStakingRewards(_stakeAmount, stakingElapsedTime, REWARD_INITIAL_DURATION);
            verboseLog("StakingPreSetupUtils:checkUserClaim: expectedRewards = ", expectedRewards);
            vm.prank(_user);
            vm.expectEmit(true, true, false, false, address(stakingRewards2));
            emit StakingRewards2Events.RewardPaid(_user, expectedRewards);
            stakingRewards2.getReward();
            // Check user rewards balance before/after claim
            uint256 rewardErc20UserBalanceAfterClaim = rewardErc20.balanceOf(_user);
            claimedRewards_ = rewardErc20UserBalanceAfterClaim - rewardErc20UserBalance;
            verboseLog(
                "StakingPreSetupUtils:checkUserClaim: after: user reward balance = ", rewardErc20UserBalanceAfterClaim
            );
            verboseLog("StakingPreSetupUtils:checkUserClaim: -> user CLAIMEDREWARDS = ", claimedRewards_);
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
        debugLog("StakingPreSetupUtils:_checkRewardForDuration");
        if (REWARD_INITIAL_AMOUNT < REWARD_INITIAL_DURATION) {
            warningLog(
                "StakingPreSetupUtils:_checkRewardForDuration: REWARD_INITIAL_AMOUNT < REWARD_INITIAL_DURATION"
            );
            warningLog("StakingPreSetupUtils:_checkRewardForDuration: => reward is likely to be ZERO !");
        }
        uint256 rewardForDuration;
        rewardForDuration = stakingRewards2.getRewardForDuration();
        debugLog("StakingPreSetupUtils:_checkRewardForDuration: getRewardForDuration  = ", rewardForDuration);
        debugLog("StakingPreSetupUtils:_checkRewardForDuration: REWARD_INITIAL_AMOUNT = ", REWARD_INITIAL_AMOUNT);

        if (_delta == 0) {
            assertEq(rewardForDuration, REWARD_INITIAL_AMOUNT);
        } else {
            assertApproxEqRel(rewardForDuration, REWARD_INITIAL_AMOUNT, _delta);
        }
        verboseLog("StakingPreSetupUtils:_checkRewardForDuration: ok");
    }

    // Comment parameter name to silent "Unused function parameter." warning
    function checkRewardForDuration(uint256 /* _delta */ ) internal virtual {
        debugLog("checkRewardForDuration()");
        assertFalse(true, "IMPLEMENT checkRewardForDuration() in derived contract");
    }

    function checkStakingPeriod(uint256 _stakingPercentageDurationReached) internal {
        debugLog(
            "StakingPreSetupUtils:checkStakingPeriod: _stakingPercentageDurationReached : ",
            _stakingPercentageDurationReached
        );
        debugLog("StakingPreSetupUtils:checkStakingPeriod: _stakingPercentageDurationReached = %s %%", _stakingPercentageDurationReached * 100 / PERCENT_100);

        assertTrue(
            _stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION,
            "StakingPreSetupUtils:checkStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"
        );
        uint256 stakingTimeReached = STAKING_START_TIMESTAMP
            + (
                _stakingPercentageDurationReached >= PERCENT_100
                    ? REWARD_INITIAL_DURATION
                    : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100
            );
        debugLog("StakingPreSetupUtils:checkStakingPeriod: stakingTimeReached = ", stakingTimeReached);
        uint256 lastTimeReward = stakingRewards2.lastTimeRewardApplicable();
        debugLog("StakingPreSetupUtils:checkStakingPeriod: lastTimeReward = ", lastTimeReward);
        assertEq(block.timestamp, stakingTimeReached, "Wrong block.timestamp");
        assertEq(lastTimeReward, stakingTimeReached, "Wrong lastTimeReward");
    }

    // function withdrawStake(address _user, uint256 _amount) public {
    //     debugLog("StakingPreSetupUtils:withdrawStake: _user : ", _user);
    //     debugLog("StakingPreSetupUtils:withdrawStake: _amount : ", _amount);
    //     uint256 balanceOfUserBeforeWithdrawal = stakingRewards2.balanceOf(_user);
    //     debugLog(
    //         "StakingPreSetupUtils:withdrawStake: balanceOfUserBeforeWithdrawal = ", balanceOfUserBeforeWithdrawal
    //     );
    //     // Check emitted event
    //     vm.expectEmit(true, true, false, false, address(stakingRewards2));
    //     emit StakingRewards2Events.Withdrawn(_user, _amount);
    //     vm.prank(_user);
    //     stakingRewards2.withdraw(_amount);
    //     uint256 balanceOfUserAfterWithdrawal = stakingRewards2.balanceOf(_user);
    //     debugLog("StakingPreSetupUtils:withdrawStake: balanceOfUserAfterWithdrawal = ", balanceOfUserAfterWithdrawal);
    //     assertEq(balanceOfUserBeforeWithdrawal - _amount, balanceOfUserAfterWithdrawal);
    // }

    // Goto some staking time within period
    function gotoStakingPercentage(uint256 _stakingPercentageDurationReached) internal returns (uint256) {
        debugLog(
            "StakingPreSetupUtils:gotoStakingPercentage: _stakingPercentageDurationReached : ",
            _stakingPercentageDurationReached
        );
        assertTrue(
            _stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION,
            "StakingPreSetupUtils:gotoStakingPercentage:_stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"
        );
        uint256 gotoStakingPeriodResult = STAKING_START_TIMESTAMP
            + (
                _stakingPercentageDurationReached >= PERCENT_100
                    ? REWARD_INITIAL_DURATION
                    : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100
            );
        verboseLog("StakingPreSetupUtils:gotoStakingPercentage: gotoStakingPeriodResult = ", gotoStakingPeriodResult);

        gotoTimestamp(gotoStakingPeriodResult);

        return gotoStakingPeriodResult;
    }

    function getStakingTimeReached() internal view returns (uint256) {
        debugLog("StakingPreSetupUtils:getStakingTimeReached");
        uint256 rewardDurationReached = getRewardDurationReached();
        debugLog("StakingPreSetupUtils:getStakingTimeReached: rewardDurationReached : ", rewardDurationReached);
        return STAKING_START_TIMESTAMP + rewardDurationReached;
    }

    function getStakingDuration() internal view returns (uint256) {
        debugLog("StakingPreSetupUtils:getStakingDuration");
        uint256 stakingDuration = REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100;
        verboseLog("StakingPreSetupUtils:getStakingDuration: stakingDuration = ", stakingDuration);
        return stakingDuration;
    }

    function getRewardedStakingDuration(uint8 _divide) internal view returns (uint256) {
        debugLog("StakingPreSetupUtils:getRewardedStakingDuration: _divide : ", _divide);
        uint256 stakingDuration = getStakingDuration() / _divide;
        debugLog("StakingPreSetupUtils:getRewardedStakingDuration: stakingDuration = ", stakingDuration);
        uint256 rewardedStakingDuration = getRewardDurationReached(stakingDuration);
        verboseLog(
            "StakingPreSetupUtils:getRewardedStakingDuration: rewardedStakingDuration = ", rewardedStakingDuration
        );
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
            "StakingPreSetupUtils:notifyVariableRewardAmount: _constantRewardRatePerTokenStored : ",
            _constantRewardRatePerTokenStored
        );
        debugLog(
            "StakingPreSetupUtils:notifyVariableRewardAmount: _variableRewardMaxTotalSupply : ",
            _variableRewardMaxTotalSupply
        );

        if (_userStakingRewardAdmin != address(0)) vm.prank(_userStakingRewardAdmin);
        // Check emitted events
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.MaxTotalSupply(_variableRewardMaxTotalSupply);
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAddedPerTokenStored(_constantRewardRatePerTokenStored);
        stakingRewards2.notifyVariableRewardAmount(_constantRewardRatePerTokenStored, _variableRewardMaxTotalSupply);
        STAKING_START_TIMESTAMP = block.timestamp;
        STAKING_END_TIMESTAMP = STAKING_START_TIMESTAMP + REWARD_INITIAL_DURATION;
        debugLog("StakingPreSetupUtils:notifyVariableRewardAmount: STAKING_START_TIMESTAMP : ", STAKING_START_TIMESTAMP);
        debugLog("StakingPreSetupUtils:notifyVariableRewardAmount: STAKING_END_TIMESTAMP : ", STAKING_END_TIMESTAMP);
    }

    function notifyRewardAmount(uint256 _reward) internal {
        notifyRewardAmount(_reward, address(0));
    }

    function notifyRewardAmount(uint256 _reward, address _userStakingRewardAdmin) internal {
        debugLog("StakingPreSetupUtils:notifyRewardAmount: reward : ", _reward);
        if (_userStakingRewardAdmin != address(0)) vm.prank(_userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardAdded(1);
        stakingRewards2.notifyRewardAmount(_reward);
        STAKING_START_TIMESTAMP = block.timestamp;
        STAKING_END_TIMESTAMP = STAKING_START_TIMESTAMP + REWARD_INITIAL_DURATION;
        debugLog("StakingPreSetupUtils:notifyRewardAmount: STAKING_START_TIMESTAMP : ", STAKING_START_TIMESTAMP);
        debugLog("StakingPreSetupUtils:notifyRewardAmount: STAKING_END_TIMESTAMP : ", STAKING_END_TIMESTAMP);
    }

    function setRewardsDuration(uint256 _rewardsDuration) internal {
        setRewardsDuration(_rewardsDuration, address(0));
    }

    function setRewardsDuration(uint256 _rewardsDuration, address _userStakingRewardAdmin) internal {
        debugLog("StakingPreSetupUtils:setRewardsDuration: _rewardsDuration : ", _rewardsDuration);
        if (_userStakingRewardAdmin != address(0)) vm.prank(_userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2Events.RewardsDurationUpdated(_rewardsDuration);
        stakingRewards2.setRewardsDuration(_rewardsDuration);
    }

    function displayEarned(address _staker, string memory _stakerName) internal view {
        displayEarned(_staker, _stakerName, false);
    }

    function displayEarned(address _staker, string memory _stakerName, bool _displayTime) internal view {
        debugLog("StakingPreSetupUtils:displayEarned: %s ", _staker);
        debugLog("StakingPreSetupUtils:displayEarned: %s ", _stakerName);
        if (_displayTime) {
            displayTime();
        }
        uint256 stakerRewards = stakingRewards2.earned(_staker);
        debugLog("StakingPreSetupUtils:displayEarned: stakerRewards = %d ", stakerRewards);
    }
} // StakingPreSetupUtils

abstract contract StakingPreSetupErc20 is StakingPreSetupUtils, Erc20Setup {
    /* solhint-disable var-name-mixedcase */
    uint256 internal ALICE_STAKINGERC20_STAKEDAMOUNT;
    uint256 internal BOB_STAKINGERC20_STAKEDAMOUNT;
    uint256 internal CHERRY_STAKINGERC20_STAKEDAMOUNT;
    /* solhint-enable var-name-mixedcase */

    function setUp() public virtual override(StakingPreSetupUtils, Erc20Setup) {
        debugLog("StakingPreSetupErc20 setUp() start");
        StakingPreSetupUtils.setUp();
        Erc20Setup.setUp();

        // Create StakingRewards2 contract
        vm.prank(userStakingRewardAdmin);
        stakingRewards2 = new StakingRewards2(address(rewardErc20), address(stakingERC20));
        assertEq(userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner");

        // Set rewards duration
        vm.prank(userStakingRewardAdmin);
        setRewardsDuration(REWARD_INITIAL_DURATION);

        verboseLog("StakingPreSetupErc20 setUp()");
        debugLog("StakingPreSetupErc20 setUp() end");
    }

    function checkRewardForDuration(uint256 _delta) internal virtual override {
        debugLog("StakingPreSetupVRR: checkRewardForDuration");
        _checkRewardForDuration(_delta);
    }

    function _userStakes(address _userAddress, string memory _userName, uint256 _amount) internal {
        debugLog("StakingPreSetupErc20 _userStakes() start");
        debugLog("StakingPreSetupErc20 _userStakes userAddress", _userAddress);
        debugLog("StakingPreSetupErc20 _userStakes userName", _userName);
        debugLog("StakingPreSetupErc20 _userStakes amount", _amount);

        uint256 stakingRewardsBalanceOfUserBeforeDeposit = stakingRewards2.balanceOf(_userAddress);
        debugLog(
            "StakingPreSetupErc20:_userStakes: stakingRewardsBalanceOfUserBeforeDeposit = ", stakingRewardsBalanceOfUserBeforeDeposit
        );
        uint256 stakingERC20BalanceOfUserBeforeDeposit = stakingERC20.balanceOf(_userAddress);
        debugLog(
            "StakingPreSetupErc20:_userStakes: stakingERC20BalanceOfUserBeforeDeposit = ", stakingERC20BalanceOfUserBeforeDeposit
        );

        vm.startPrank(_userAddress);
        if (_amount == 0) {
            // Check expected events
            vm.expectRevert(
                abi.encodeWithSelector(
                    StakeZero.selector
                )
            );
        } else {
            stakingERC20.approve(address(stakingRewards2), _amount);

            debugLog("StakingPreSetupErc20 _userStakes stakingERC20 address: %s", address(stakingERC20));
            debugLog("StakingPreSetupErc20 _userStakes stakingRewards2 address: %s", address(stakingRewards2));
            debugLog(
                "StakingPreSetupErc20 _userStakes _userAddress stakingERC20 allowance",
                stakingERC20.allowance(_userAddress, address(stakingRewards2))
            );
            debugLog("StakingPreSetupErc20 _userStakes stakingERC20 balanceOf", stakingERC20.balanceOf(_userAddress));
            debugLog(
                "StakingPreSetupErc20 _userStakes _userAddress stakingERC20 allowance",
                stakingERC20.allowance(_userAddress, address(stakingRewards2))
            );

            // Check expected events
            vm.expectEmit(true, true, false, false, address(stakingRewards2));
            emit StakingRewards2Events.Staked(_userAddress, _amount);

        }
        stakingRewards2.stake(_amount);
        vm.stopPrank();

        // // Check expected events
        // vm.expectEmit(true, true, false, false, address(stakingRewards2));
        // emit StakingRewards2Events.Staked(_userAddress, _amount);
        // stakingRewards2.stake(_amount);
        // vm.stopPrank();

        uint256 stakingRewardsBalanceOfUserAfterDeposit = stakingRewards2.balanceOf(_userAddress);
        debugLog("StakingPreSetupErc20:_userStakes: stakingRewardsBalanceOfUserAfterDeposit = ", stakingRewardsBalanceOfUserAfterDeposit);
        assertEq(stakingRewardsBalanceOfUserBeforeDeposit + _amount, stakingRewardsBalanceOfUserAfterDeposit);

        uint256 stakingERC20BalanceOfUseAfterDeposit = stakingERC20.balanceOf(_userAddress);
        debugLog("StakingPreSetupErc20:_userStakes: stakingERC20BalanceOfUseAfterDeposit = ", stakingERC20BalanceOfUseAfterDeposit);
        assertEq(stakingERC20BalanceOfUserBeforeDeposit - _amount, stakingERC20BalanceOfUseAfterDeposit);

        TOTAL_STAKED_AMOUNT += _amount;
        debugLog("StakingPreSetupErc20 _userStakes() end");
    }

    function _userUnstakes(address _userAddress, string memory _userName, uint256 _amount) internal {
        debugLog("StakingPreSetupErc20 _userUnstakes() start");
        displayTime();
        debugLog("StakingPreSetupErc20 _userUnstakes userAddress", _userAddress);
        debugLog("StakingPreSetupErc20 _userUnstakes userName", _userName);
        debugLog("StakingPreSetupErc20 _userUnstakes amount", _amount);

        uint256 stakingRewardsBalanceOfUserBeforeWithdrawal = stakingRewards2.balanceOf(_userAddress);
        debugLog(
            "StakingPreSetupErc20:_userUnstakes: stakingRewardsBalanceOfUserBeforeWithdrawal = ", stakingRewardsBalanceOfUserBeforeWithdrawal
        );
        uint256 stakingERC20BalanceOfUserBeforeWithdrawal = stakingERC20.balanceOf(_userAddress);
        debugLog(
            "StakingPreSetupErc20:_userUnstakes: stakingERC20BalanceOfUserBeforeWithdrawal = ", stakingERC20BalanceOfUserBeforeWithdrawal
        );

        if (_amount > stakingRewardsBalanceOfUserBeforeWithdrawal) {
            debugLog("StakingPreSetupErc20 _userUnstakes: _amount > stakingRewardsBalanceOfUserBeforeWithdrawal");
            fail("StakingPreSetupErc20 _userUnstakes: _amount > stakingRewardsBalanceOfUserBeforeWithdrawal");
        }

        if (_amount == 0) {
            debugLog("StakingPreSetupErc20 _userUnstakes: _amount == ZERO");
            warningLog("StakingPreSetupErc20 _userUnstakes: _amount == ZERO");
        }

        // Check emitted event
        vm.prank(_userAddress);
        if (_amount == 0) {
            vm.expectRevert(
            abi.encodeWithSelector(
                WithdrawZero.selector
            )
        );
        } else {
            vm.expectEmit(true, true, false, false, address(stakingRewards2));
            emit StakingRewards2Events.Withdrawn(_userAddress, _amount);
        }
        stakingRewards2.withdraw(_amount);

        uint256 stakingRewardsBalanceOfUserAfterWithdrawal = stakingRewards2.balanceOf(_userAddress);
        debugLog("StakingPreSetupErc20:withdrawStake: stakingRewardsBalanceOfUserAfterWithdrawal = ", stakingRewardsBalanceOfUserAfterWithdrawal);
        assertEq(stakingRewardsBalanceOfUserBeforeWithdrawal - _amount, stakingRewardsBalanceOfUserAfterWithdrawal);

        uint256 stakingERC20BalanceOfUseAfterWithdrawal = stakingERC20.balanceOf(_userAddress);
        debugLog("StakingPreSetupErc20:_userUnstakes: stakingERC20BalanceOfUseAfterWithdrawal = ", stakingERC20BalanceOfUseAfterWithdrawal);
        assertEq(stakingERC20BalanceOfUserBeforeWithdrawal + _amount, stakingERC20BalanceOfUseAfterWithdrawal);

        TOTAL_STAKED_AMOUNT -= _amount;
        debugLog("StakingPreSetupErc20 _userUnstakes() end");
    }

    function AliceStakes(uint256 _amount) internal {
        debugLog("StakingPreSetupErc20 AliceStakes() start");
        _userStakes(userAlice, "Alice", _amount);
        ALICE_STAKINGERC20_STAKEDAMOUNT += _amount;
        debugLog("StakingPreSetupErc20 AliceStakes() end");
    }

    function BobStakes(uint256 _amount) internal {
        debugLog("StakingPreSetupErc20 BobStakes() start");
        _userStakes(userBob, "Bob", _amount);
        BOB_STAKINGERC20_STAKEDAMOUNT += _amount;
        debugLog("StakingPreSetupErc20 BobStakes() end");
    }

    function CherryStakes(uint256 _amount) internal {
        debugLog("StakingPreSetupErc20 CherryStakes() start");
        _userStakes(userCherry, "Cherry", _amount);
        CHERRY_STAKINGERC20_STAKEDAMOUNT += _amount;
        debugLog("StakingPreSetupErc20 CherryStakes() end");
    }

    function AliceUnstakes(uint256 _amount) internal {
        debugLog("StakingPreSetupErc20 AliceUnstakes() start");
        _userUnstakes(userAlice, "Alice", _amount);
        ALICE_STAKINGERC20_STAKEDAMOUNT -= _amount;
        debugLog("StakingPreSetupErc20 AliceUnstakes() end");
    }

    function BobUnstakes(uint256 _amount) internal {
        debugLog("StakingPreSetupErc20 BobUnstakes() start");
        _userUnstakes(userBob, "Bob", _amount);
        BOB_STAKINGERC20_STAKEDAMOUNT -= _amount;
        debugLog("StakingPreSetupErc20 BobUnstakes() end");
    }

    function CherryUnstakes(uint256 _amount) internal {
        debugLog("StakingPreSetupErc20 CherryUnstakes() start");
        _userUnstakes(userCherry, "Cherry", _amount);
        CHERRY_STAKINGERC20_STAKEDAMOUNT -= _amount;
        debugLog("StakingPreSetupErc20 CherryUnstakes() end");
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
} // StakingPreSetupErc20

/* solhint-enable contract-name-camelcase */
