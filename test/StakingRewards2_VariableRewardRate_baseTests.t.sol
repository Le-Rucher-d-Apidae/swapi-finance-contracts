// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { StakingPreSetup } from "./StakingRewards2_VariableRewardRate_setups.t.sol";

import { ONE_TOKEN_18 } from "./TestsConstants.sol";

import { StakingRewards2 } from "../src/contracts/StakingRewards2.sol";
import {
  RewardPeriodInProgress,
  ProvidedVariableRewardTooHigh,
  StakeTotalSupplyExceedsAllowedMax,
  UpdateVariableRewardMaxTotalSupply
} from "../src/contracts/StakingRewards2Errors.sol";
import { StakingRewards2Events } from "../src/contracts/StakingRewards2Events.sol";

import { Ownable } from "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts@5.0.2/utils/Pausable.sol";

// ----------------------------------------------------------------------------

// Permissions tests

// 7 tests

// /*

contract CheckStakingPermissions is StakingPreSetup {
  function setUp() public virtual override {
    debugLog("CheckStakingPermissions setUp() start");
    StakingPreSetup.setUp();
    debugLog("CheckStakingPermissions setUp() end");
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

    // Unpausing again should not throw nor emit event and leave pause unchanged
    stakingRewards2.setPaused(false);
    // Check no event emitted ?
    assertEq(stakingRewards2.paused(), false);

    vm.stopPrank();
  }

  function testStakingPauseDuringRewarding() public {
    // start rewarding
    vm.prank(userStakingRewardAdmin);
    notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);

    testStakingPause();
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
    notifyVariableRewardAmount(1, 1);
    verboseLog("Staking contract: Only owner can notifyVariableRewardAmount of 1,1");
    verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
  }

  function testStakingNotifyUpdateVariableRewardAmountMinMax() public {
    verboseLog("Only staking reward contract owner can updateVariableRewardMaxTotalSupply");

    vm.prank(userStakingRewardAdmin);
    notifyVariableRewardAmount(1, 1);

    vm.startPrank(userAlice);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
    stakingRewards2.updateVariableRewardMaxTotalSupply(0);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
    stakingRewards2.updateVariableRewardMaxTotalSupply(1);
    vm.stopPrank();

    verboseLog("Staking contract: Alice can't updateVariableRewardMaxTotalSupply");

    vm.startPrank(userBob);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));
    stakingRewards2.updateVariableRewardMaxTotalSupply(0);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));
    stakingRewards2.updateVariableRewardMaxTotalSupply(1);
    verboseLog("Staking contract: Bob can't updateVariableRewardMaxTotalSupply");
    vm.stopPrank();

    vm.startPrank(userStakingRewardAdmin);
    // Check emitted events
    vm.expectEmit(true, false, false, false, address(stakingRewards2));
    emit StakingRewards2Events.MaxTotalSupply(0);
    stakingRewards2.updateVariableRewardMaxTotalSupply(0);

    // Check emitted events
    vm.expectEmit(true, false, false, false, address(stakingRewards2));
    emit StakingRewards2Events.MaxTotalSupply(0);
    stakingRewards2.updateVariableRewardMaxTotalSupply(1);
    vm.stopPrank();
    verboseLog("Staking contract: Only owner can updateVariableRewardMaxTotalSupply");
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
    notifyVariableRewardAmount(0, 0);
    verboseLog("Staking contract: Only owner can notifyVariableRewardAmount of 0, 0");
    verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
  }

  function testStakingNotifyVariableRewardAmount() public {
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
    notifyVariableRewardAmount(1, 1);
    verboseLog("Staking contract: Only owner can notifyVariableRewardAmount");
    verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
  }

  function testStakingNotifyVariableRewardAmountLimit1() public {
    vm.prank(userStakingRewardAdmin);
    notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);
    verboseLog(
      "Staking contract: Only owner can notifyVariableRewardAmount of ",
      CONSTANT_REWARDRATE_PERTOKENSTORED * CONSTANT_REWARD_MAXTOTALSUPPLY
    );
    verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
  }

  function testStakingSetRewardsDurationBeforeEpochEnd() public {
    // Previous reward epoch must have ended before setting a new duration

    vm.prank(userStakingRewardAdmin);
    notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY);
    verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);

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
        RewardPeriodInProgress.selector, block.timestamp, STAKING_START_TIMESTAMP + REWARD_INITIAL_DURATION
      )
    );
    stakingRewards2.setRewardsDuration(1);
    verboseLog("Staking contract: Owner can't setRewardsDuration before previous epoch end (RewardPeriodInProgress)");

    // Previous reward epoch must have ended before setting a new duration
    gotoTimestamp(STAKING_START_TIMESTAMP + REWARD_INITIAL_DURATION); // epoch last time reward

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
      "Staking contract: Bob can't setRewardsDuration just before previous epoch end" " (OwnableUnauthorizedAccount)"
    );

    vm.prank(userStakingRewardAdmin);
    vm.expectRevert(
      abi.encodeWithSelector(
        RewardPeriodInProgress.selector, block.timestamp, STAKING_START_TIMESTAMP + REWARD_INITIAL_DURATION
      )
    );
    stakingRewards2.setRewardsDuration(1);
    verboseLog(
      "Staking contract: Owner can't setRewardsDuration just before previous epoch end (RewardPeriodInProgress)"
    );

    vm.stopPrank();
  }
}

// */

// Limits tests

// 2 tests

// /*

contract CheckStakingConstantRewardLimits1 is StakingPreSetup {
  function setUp() public virtual override {
    debugLog("CheckStakingConstantRewardLimits1 setUp() start");
    StakingPreSetup.setUp();
    debugLog("CheckStakingConstantRewardLimits1 setUp() end");
  }

  // Test that the owner can notifyVariableRewardAmount with a reward max total supply amount that is just low
  // enough
  function testStakingNotifyVariableRewardAmountSuccess1() public {
    /* solhint-disable var-name-mixedcase */
    uint256 REWARD_AVAILABLE_AMOUNT = rewardErc20.balanceOf(address(stakingRewards2));
    // Should be REWARD_INITIAL_AMOUNT
    assert(REWARD_AVAILABLE_AMOUNT == REWARD_INITIAL_AMOUNT);

    // Find the MAXTOTALSUPPLY_EXTRA_OVERFLOW that will overflow the balance
    uint256 MAXTOTALSUPPLY_EXTRA_OVERFLOW = CONSTANT_REWARD_MAXTOTALSUPPLY;
    uint256 TOTAL_REWARD_PERTOKENSTORED = CONSTANT_REWARDRATE_PERTOKENSTORED * REWARD_INITIAL_DURATION;
    uint256 BALANCE_E18 = REWARD_INITIAL_AMOUNT * ONE_TOKEN_18;
    for (uint256 i = CONSTANT_REWARD_MAXTOTALSUPPLY;; i += REWARD_INITIAL_DURATION) {
      if (i * TOTAL_REWARD_PERTOKENSTORED > BALANCE_E18) {
        debugLog("testStakingNotifyVariableRewardAmountSuccess1: i   = ", i);
        MAXTOTALSUPPLY_EXTRA_OVERFLOW = i - CONSTANT_REWARD_MAXTOTALSUPPLY;
        break;
      }
    }
    uint256 MAXTOTALSUPPLY_EXTRA_OK = MAXTOTALSUPPLY_EXTRA_OVERFLOW - REWARD_INITIAL_DURATION;
    /* solhint-enable var-name-mixedcase */
    vm.prank(userStakingRewardAdmin);

    notifyVariableRewardAmount(
      CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY + MAXTOTALSUPPLY_EXTRA_OK
    );

    verboseLog(
      "Staking contract: Only owner can notifyVariableRewardAmount of ",
      CONSTANT_REWARDRATE_PERTOKENSTORED * CONSTANT_REWARD_MAXTOTALSUPPLY
    );
    verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
  }

  // Test that the owner can notifyVariableRewardAmount and updateVariableRewardMaxTotalSupply
  // with a reward max total supply amount that is just low enough
  function testStakingNotifyAndUpdateVariableRewardAmountSuccess1() public {
    /* solhint-disable var-name-mixedcase */
    uint256 REWARD_AVAILABLE_AMOUNT = rewardErc20.balanceOf(address(stakingRewards2));
    // Should be REWARD_INITIAL_AMOUNT
    assert(REWARD_AVAILABLE_AMOUNT == REWARD_INITIAL_AMOUNT);

    // Find the MAXTOTALSUPPLY_EXTRA_OVERFLOW that will overflow the balance
    uint256 MAXTOTALSUPPLY_EXTRA_OVERFLOW = CONSTANT_REWARD_MAXTOTALSUPPLY;
    uint256 TOTAL_REWARD_PERTOKENSTORED = CONSTANT_REWARDRATE_PERTOKENSTORED * REWARD_INITIAL_DURATION;
    uint256 BALANCE_E18 = REWARD_INITIAL_AMOUNT * ONE_TOKEN_18;
    for (uint256 i = CONSTANT_REWARD_MAXTOTALSUPPLY;; i += REWARD_INITIAL_DURATION) {
      if (i * TOTAL_REWARD_PERTOKENSTORED > BALANCE_E18) {
        debugLog("testStakingNotifyVariableRewardAmountSuccess1: i   = ", i);
        MAXTOTALSUPPLY_EXTRA_OVERFLOW = i - CONSTANT_REWARD_MAXTOTALSUPPLY;
        break;
      }
    }
    uint256 MAXTOTALSUPPLY_EXTRA_OK = MAXTOTALSUPPLY_EXTRA_OVERFLOW - REWARD_INITIAL_DURATION;
    uint256 CONSTANT_REWARD_MAXTOTALSUPPLY_PLUS_EXTRA_OK = CONSTANT_REWARD_MAXTOTALSUPPLY + MAXTOTALSUPPLY_EXTRA_OK;
    /* solhint-enable var-name-mixedcase */
    vm.prank(userStakingRewardAdmin);

    notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY_PLUS_EXTRA_OK);

    verboseLog(
      "Staking contract: Only owner can notifyVariableRewardAmount of ",
      CONSTANT_REWARDRATE_PERTOKENSTORED * CONSTANT_REWARD_MAXTOTALSUPPLY
    );
    verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");

    // Check emitted events
    vm.expectEmit(true, false, false, false, address(stakingRewards2));
    emit StakingRewards2Events.MaxTotalSupply(CONSTANT_REWARD_MAXTOTALSUPPLY_PLUS_EXTRA_OK);
    vm.prank(userStakingRewardAdmin);
    stakingRewards2.updateVariableRewardMaxTotalSupply(CONSTANT_REWARD_MAXTOTALSUPPLY_PLUS_EXTRA_OK);
  }

  // Test that the owner can't notifyVariableRewardAmount with a reward max total supply amount that is too high
  function testStakingNotifyVariableRewardAmountFail1() public {
    /* solhint-disable var-name-mixedcase */
    uint256 REWARD_AVAILABLE_AMOUNT = rewardErc20.balanceOf(address(stakingRewards2));
    // Should be REWARD_INITIAL_AMOUNT
    assert(REWARD_AVAILABLE_AMOUNT == REWARD_INITIAL_AMOUNT);

    // Find the MAXTOTALSUPPLY_EXTRA_OVERFLOW that will overflow the balance
    uint256 MAXTOTALSUPPLY_EXTRA_OVERFLOW = CONSTANT_REWARD_MAXTOTALSUPPLY;
    uint256 TOTAL_REWARD_PERTOKENSTORED = CONSTANT_REWARDRATE_PERTOKENSTORED * REWARD_INITIAL_DURATION;
    uint256 BALANCE_E18 = REWARD_INITIAL_AMOUNT * ONE_TOKEN_18;
    /* solhint-enable var-name-mixedcase */

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
          (CONSTANT_REWARD_MAXTOTALSUPPLY + MAXTOTALSUPPLY_EXTRA_OVERFLOW) * CONSTANT_REWARDRATE_PERTOKENSTORED
            * REWARD_INITIAL_DURATION
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

  // Test that the owner can't notifyVariableRewardAmount with a reward max total supply amount that is too high
  function testStakingNotifyVariableRewardAmountSuccessUpdateFail1() public {
    /* solhint-disable var-name-mixedcase */
    uint256 REWARD_AVAILABLE_AMOUNT = rewardErc20.balanceOf(address(stakingRewards2));
    // Should be REWARD_INITIAL_AMOUNT
    assert(REWARD_AVAILABLE_AMOUNT == REWARD_INITIAL_AMOUNT);

    // Find the MAXTOTALSUPPLY_EXTRA_OVERFLOW that will overflow the balance
    uint256 MAXTOTALSUPPLY_EXTRA_OVERFLOW = CONSTANT_REWARD_MAXTOTALSUPPLY;
    uint256 TOTAL_REWARD_PERTOKENSTORED = CONSTANT_REWARDRATE_PERTOKENSTORED * REWARD_INITIAL_DURATION;
    uint256 BALANCE_E18 = REWARD_INITIAL_AMOUNT * ONE_TOKEN_18;
    for (uint256 i = CONSTANT_REWARD_MAXTOTALSUPPLY;; i += REWARD_INITIAL_DURATION) {
      if (i * TOTAL_REWARD_PERTOKENSTORED > BALANCE_E18) {
        debugLog("testStakingNotifyVariableRewardAmountSuccess1: i   = ", i);
        MAXTOTALSUPPLY_EXTRA_OVERFLOW = i - CONSTANT_REWARD_MAXTOTALSUPPLY;
        break;
      }
    }
    uint256 MAXTOTALSUPPLY_EXTRA_OK = MAXTOTALSUPPLY_EXTRA_OVERFLOW - REWARD_INITIAL_DURATION;
    uint256 CONSTANT_REWARD_MAXTOTALSUPPLY_PLUS_EXTRA_OK = CONSTANT_REWARD_MAXTOTALSUPPLY + MAXTOTALSUPPLY_EXTRA_OK;
    uint256 CONSTANT_REWARD_MAXTOTALSUPPLY_PLUS_EXTRA_OVERFLOW =
      CONSTANT_REWARD_MAXTOTALSUPPLY + MAXTOTALSUPPLY_EXTRA_OK + REWARD_INITIAL_DURATION;
    /* solhint-enable var-name-mixedcase */
    vm.prank(userStakingRewardAdmin);

    notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, CONSTANT_REWARD_MAXTOTALSUPPLY_PLUS_EXTRA_OK);

    verboseLog(
      "Staking contract: Only owner can notifyVariableRewardAmount of ",
      CONSTANT_REWARDRATE_PERTOKENSTORED * CONSTANT_REWARD_MAXTOTALSUPPLY
    );
    verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");

    // Check emitted events
    vm.expectRevert(
      abi.encodeWithSelector(
        UpdateVariableRewardMaxTotalSupply.selector,
        CONSTANT_REWARD_MAXTOTALSUPPLY_PLUS_EXTRA_OVERFLOW, // Max. total supply
        REWARD_INITIAL_AMOUNT // Current balance
      )
    );
    vm.prank(userStakingRewardAdmin);
    stakingRewards2.updateVariableRewardMaxTotalSupply(CONSTANT_REWARD_MAXTOTALSUPPLY_PLUS_EXTRA_OVERFLOW);
    verboseLog("Staking contract: Error UpdateVariableRewardMaxTotalSupply thrown");
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
    stakingRewards2.notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED + 1, CONSTANT_REWARD_MAXTOTALSUPPLY);

    verboseLog(
      "Staking contract: Only owner can notifyVariableRewardAmount of ",
      CONSTANT_REWARDRATE_PERTOKENSTORED * CONSTANT_REWARD_MAXTOTALSUPPLY
    );
    verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
  }
} // CheckStakingConstantRewardLimits1

// */

// 13 tests

// contract CheckStakingConstantRewardLimits2 is StakingPreSetup, Erc20Setup_18_18 {
contract CheckStakingConstantRewardLimits2 is StakingPreSetup {
  // function setUp() public virtual override(Erc20Setup_18_18, StakingPreSetup) {
  function setUp() public virtual override(StakingPreSetup) {
    debugLog("CheckStakingConstantRewardLimits2 setUp() start");
    StakingPreSetup.setUp();

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

  // Nothing minted, no reward
  function testStakingNotifyVariableRewardAmountFail0() public {
    // Test some arbitrary values
    // Smallest amount (1,1), 0 reward minted

    // Should mint 99 / 10^18 token as reward
    // vm.prank(erc20Minter);
    // rewardErc20.mint( address(stakingRewards2), 0 );
    vm.startPrank(userStakingRewardAdmin);
    setRewardsDuration(100); // 100 s.

    // Set 1 unit (1 = 10^-18) of token as reward per token deposit
    // and max deposit of 1 / 1^18 token

    // Expect revert: expected min. balance 100, current balance 0
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
    setRewardsDuration(100); // 100 s.

    // Set 1 unit (1 = 10^-18) of token as reward per token deposit
    // and max deposit of 1 / 1^18 token

    notifyVariableRewardAmount(1, 1);
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

    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;
    // = 1e18 * 31 536 000 / 1e18 / 31 536 000 = 1

    // Mint 99 / 10^18 token as reward
    uint256 MINTED_REWARD_AMOUNT = REWARD_AMOUNT - 1; // 99
    /* solhint-enable var-name-mixedcase */

    vm.prank(erc20Minter);
    rewardErc20.mint(address(stakingRewards2), MINTED_REWARD_AMOUNT);
    vm.startPrank(userStakingRewardAdmin);
    setRewardsDuration(REWARD_DURATION); // 100 s.

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

    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;
    // = 1e18 * 31 536 000 / 1 / 31 536 000 = 1e18

    // Mint 99 / 10^18 token as reward
    uint256 MINTED_REWARD_AMOUNT = REWARD_AMOUNT - 1; // 99
    /* solhint-enable var-name-mixedcase */

    vm.prank(erc20Minter);
    rewardErc20.mint(address(stakingRewards2), MINTED_REWARD_AMOUNT);
    vm.startPrank(userStakingRewardAdmin);
    setRewardsDuration(REWARD_DURATION); // 100 s.

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
    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;
    // REWARD_PER_TOKEN_STORED = 1e18 * 10 / APR_BASE / 31_536_000 = 1e17 / 315_360 = 3170979198
    // (3 170 979 198,376...)
    /* solhint-enable var-name-mixedcase */

    // Mint 10 / 1e18 token as total reward
    vm.prank(erc20Minter);
    rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
    vm.startPrank(userStakingRewardAdmin);
    setRewardsDuration(REWARD_DURATION);
    notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);
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
    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;
    // REWARD_PER_TOKEN_STORED = 1e18 * 10 / 100 / 31_536_000 = 1e17 / 315_360 = 3170979198 (3 170 979 198,376...)
    // Mint insufficient reward
    uint256 INSUFFICIENT_MINTED_AMOUNT = REWARD_AMOUNT - 1;
    /* solhint-enable var-name-mixedcase */

    // Mint 10 / 1e18 token as total reward
    vm.prank(erc20Minter);
    rewardErc20.mint(address(stakingRewards2), INSUFFICIENT_MINTED_AMOUNT);
    vm.startPrank(userStakingRewardAdmin);
    setRewardsDuration(REWARD_DURATION);

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
    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;
    // REWARD_PER_TOKEN_STORED = 1e18 * 10 / 100 / 31_536_000 = 1e17 / 315_360 = 3170979198 (3 170 979 198,376...)
    uint256 EXCESSIVE_MAX_DEPOSIT_AMOUNT = MAX_DEPOSIT_AMOUNT + 1;
    /* solhint-enable var-name-mixedcase */

    // Mint 10 / 1e18 token as total reward
    vm.prank(erc20Minter);
    rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
    vm.startPrank(userStakingRewardAdmin);
    setRewardsDuration(REWARD_DURATION);

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
    uint256 MAX_DEPOSIT_AMOUNT = MAX_DEPOSIT_TOKEN_AMOUNT * ONE_TOKEN_18; // 100 token // 100 000 000 000 000 000 000
      // = 1e20 = 100 * 1e18 (1 000 000 000 000 000 000)
    uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT * APR / APR_BASE; // 10 token
    uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year

    // uint256 REWARD_PER_TOKEN_STORED = REWARD_AMOUNT / ONE_TOKEN_18 / REWARD_DURATION; //
    // 0,000 000 317 097 919 837 645 865 043 125 32
    // REWARD_PER_TOKEN_STORED = 100 * ONE_TOKEN_18 / 10 / ONE_TOKEN_18 / REWARD_DURATION
    // REWARD_PER_TOKEN_STORED = 10 / 31 536 000 = 0

    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;
    // ONE_TOKEN_18 * 10 / 100 / REWARD_DURATION
    // 1e18 * 10 / 100 / 31536000 = 3170979198 (3 170 979 198,376 458 650 431 253 170 979 2)
    /* solhint-enable var-name-mixedcase */

    // Mint 10 * 10^18 token as reward
    vm.prank(erc20Minter);
    rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
    vm.startPrank(userStakingRewardAdmin);
    setRewardsDuration(REWARD_DURATION);
    notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);
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
    uint256 MAX_DEPOSIT_AMOUNT = MAX_DEPOSIT_TOKEN_AMOUNT * ONE_TOKEN_18; // 100 token // 100 000 000 000 000 000 000
      // = 1e20 = 100 * 1e18 (1 000 000 000 000 000 000)
    uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT * APR / APR_BASE; // 10 token
    uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year

    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;
    /* solhint-enable var-name-mixedcase */

    // Mint 10 * 10^18 token as reward
    vm.prank(erc20Minter);
    rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
    vm.startPrank(userStakingRewardAdmin);
    setRewardsDuration(REWARD_DURATION);

    // Compute max deposit amount limit with rounding
    /* solhint-disable var-name-mixedcase */
    uint256 ROUNDING_MARGIN =
      (REWARD_AMOUNT - MAX_DEPOSIT_TOKEN_AMOUNT * REWARD_PER_TOKEN_STORED * REWARD_DURATION) * APR_BASE / APR;
    /* solhint-enable var-name-mixedcase */
    verboseLog("ROUNDING_MARGIN = ", ROUNDING_MARGIN);

    notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT + ROUNDING_MARGIN);
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
    uint256 MAX_DEPOSIT_AMOUNT = MAX_DEPOSIT_TOKEN_AMOUNT * ONE_TOKEN_18; // 100 token // 100 000 000 000 000 000 000
      // = 1e20 = 100 * 1e18 (1 000 000 000 000 000 000)
    uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT * APR / APR_BASE; // 10 token
    uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year
    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;
    uint256 MINTED_REWARD_AMOUNT = REWARD_AMOUNT;
    /* solhint-enable var-name-mixedcase */

    // Mint 10 * 10^18 token as reward
    vm.prank(erc20Minter);
    rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
    vm.startPrank(userStakingRewardAdmin);
    setRewardsDuration(REWARD_DURATION);

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
    uint256 MAX_DEPOSIT_AMOUNT = MAX_DEPOSIT_TOKEN_AMOUNT * ONE_TOKEN_18; // 100 token // 100 000 000 000 000 000 000
      // = 1e20 = 100 * 1e18 (1 000 000 000 000 000 000)
    uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT * APR / APR_BASE; // 10 token
    uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year
    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;

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
    setRewardsDuration(REWARD_DURATION);
    notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_AMOUNT);
    verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    vm.stopPrank();

    verboseLog(
      "Staking contract: Amount deposited before starting rewarding is lower or equal to max amount. ",
      MAX_DEPOSIT_AMOUNT
    );
  }

  // Check already deposited amount is lower or equal than max amount
  function testStakingNotifyAndUpdateVariableRewardAmountSuccess1() public {
    // Reward rate : 10% yearly
    // Depositing 1 Token should give 0.1 ( = 10^17) token reward per year
    /* solhint-disable var-name-mixedcase */

    uint256 APR = 10; // 10%
    uint256 APR_BASE = 100; // 100%
    uint256 MAX_DEPOSIT_TOKEN_AMOUNT = 100;
    uint256 MAX_DEPOSIT_INITIAL_AMOUNT = MAX_DEPOSIT_TOKEN_AMOUNT * ONE_TOKEN_18; // 100 token //
      // 100 000 000 000 000 000 000
      // = 1e20 = 100 * 1e18 (1 000 000 000 000 000 000)
    uint256 REWARD_AMOUNT = MAX_DEPOSIT_INITIAL_AMOUNT * APR / APR_BASE; // 10 token
    uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year
    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;

    uint256 ALICE_INITIAL_DEPOSIT_AMOUNT = MAX_DEPOSIT_INITIAL_AMOUNT;
    uint256 ALICE_ADDITIONNAL_DEPOSIT_AMOUNT = 1;
    // uint256 INITIAL_BLOCK_TIMESTAMP = 1;
    /* solhint-enable var-name-mixedcase */

    // Mint 10 * 10^18 token as reward
    vm.startPrank(erc20Minter);
    rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
    // Mint Alice's initial deposit(s)
    stakingERC20.mint(userAlice, ALICE_INITIAL_DEPOSIT_AMOUNT + ALICE_ADDITIONNAL_DEPOSIT_AMOUNT);
    vm.stopPrank();

    // Deposit 1 token BEFORE starting rewards
    vm.startPrank(userAlice);
    stakingERC20.approve(address(stakingRewards2), ALICE_INITIAL_DEPOSIT_AMOUNT);
    vm.expectEmit(true, true, false, false, address(stakingRewards2));
    emit StakingRewards2Events.Staked(userAlice, ALICE_INITIAL_DEPOSIT_AMOUNT);
    stakingRewards2.stake(ALICE_INITIAL_DEPOSIT_AMOUNT);
    vm.stopPrank();

    gotoTimestamp(INITIAL_BLOCK_TIMESTAMP + 1);

    vm.startPrank(userStakingRewardAdmin);
    setRewardsDuration(REWARD_DURATION);
    notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_INITIAL_AMOUNT);
    verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    vm.stopPrank();

    verboseLog(
      "Staking contract: Amount deposited before starting rewarding is lower or equal to max amount. ",
      MAX_DEPOSIT_INITIAL_AMOUNT
    );

    gotoTimestamp(INITIAL_BLOCK_TIMESTAMP + 2);

    // Deposit more tokens without updating the max deposit amount
    vm.startPrank(userAlice);
    stakingERC20.approve(address(stakingRewards2), ALICE_ADDITIONNAL_DEPOSIT_AMOUNT);
    vm.expectRevert(
      abi.encodeWithSelector(
        StakeTotalSupplyExceedsAllowedMax.selector,
        ALICE_INITIAL_DEPOSIT_AMOUNT + ALICE_ADDITIONNAL_DEPOSIT_AMOUNT, // newTotalSupply
        MAX_DEPOSIT_INITIAL_AMOUNT, // variableRewardMaxTotalSupply
        1, // depositAmount
        ALICE_INITIAL_DEPOSIT_AMOUNT // currentTotalSupply
      )
    );
    stakingRewards2.stake(ALICE_ADDITIONNAL_DEPOSIT_AMOUNT);
    vm.stopPrank();

    // Deposit more tokens after updating the max deposit amount
    // Update max deposit amount
    vm.expectEmit(true, false, false, false, address(stakingRewards2));
    emit StakingRewards2Events.MaxTotalSupply(ALICE_INITIAL_DEPOSIT_AMOUNT + ALICE_ADDITIONNAL_DEPOSIT_AMOUNT);
    vm.prank(userStakingRewardAdmin);
    stakingRewards2.updateVariableRewardMaxTotalSupply(
      ALICE_INITIAL_DEPOSIT_AMOUNT + ALICE_ADDITIONNAL_DEPOSIT_AMOUNT
    );

    // Deposit more tokens
    vm.prank(userAlice);
    vm.expectEmit(true, true, false, false, address(stakingRewards2));
    emit StakingRewards2Events.Staked(userAlice, ALICE_ADDITIONNAL_DEPOSIT_AMOUNT);
    stakingRewards2.stake(ALICE_ADDITIONNAL_DEPOSIT_AMOUNT);

    assertEq(stakingRewards2.totalSupply(), ALICE_INITIAL_DEPOSIT_AMOUNT + ALICE_ADDITIONNAL_DEPOSIT_AMOUNT);
  }

  // Check already deposited amount is lower or equal than max amount, allow more deposit and deposit more tokens
  function testStakingNotifyAndUpdateVariableRewardAmountFail0() public {
    // Reward rate : 10% yearly
    // Depositing 1 Token should give 0.1 ( = 10^17) token reward per year
    /* solhint-disable var-name-mixedcase */

    uint256 APR = 10; // 10%
    uint256 APR_BASE = 100; // 100%
    uint256 MAX_DEPOSIT_TOKEN_AMOUNT = 100;
    uint256 MAX_DEPOSIT_INITIAL_AMOUNT = MAX_DEPOSIT_TOKEN_AMOUNT * ONE_TOKEN_18; // 100 token //
      // 100 000 000 000 000 000 000
      // = 1e20 = 100 * 1e18 (1 000 000 000 000 000 000)
    uint256 REWARD_AMOUNT = MAX_DEPOSIT_INITIAL_AMOUNT * APR / APR_BASE; // 10 token
    uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year
    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;

    uint256 ALICE_INITIAL_DEPOSIT_AMOUNT = MAX_DEPOSIT_INITIAL_AMOUNT;
    uint256 ALICE_ADDITIONNAL_DEPOSIT_AMOUNT = 1;
    // uint256 INITIAL_BLOCK_TIMESTAMP = 1;
    /* solhint-enable var-name-mixedcase */

    // Mint 10 * 10^18 token as reward
    vm.startPrank(erc20Minter);
    rewardErc20.mint(address(stakingRewards2), REWARD_AMOUNT);
    // Mint Alice's initial deposit(s)
    stakingERC20.mint(userAlice, ALICE_INITIAL_DEPOSIT_AMOUNT + ALICE_ADDITIONNAL_DEPOSIT_AMOUNT);
    vm.stopPrank();

    // Deposit 1 token BEFORE starting rewards
    vm.startPrank(userAlice);
    stakingERC20.approve(address(stakingRewards2), ALICE_INITIAL_DEPOSIT_AMOUNT);
    vm.expectEmit(true, true, false, false, address(stakingRewards2));
    emit StakingRewards2Events.Staked(userAlice, ALICE_INITIAL_DEPOSIT_AMOUNT);
    stakingRewards2.stake(ALICE_INITIAL_DEPOSIT_AMOUNT);
    vm.stopPrank();

    gotoTimestamp(INITIAL_BLOCK_TIMESTAMP + 1);

    assertEq(stakingRewards2.totalSupply(), ALICE_INITIAL_DEPOSIT_AMOUNT);

    vm.startPrank(userStakingRewardAdmin);
    setRewardsDuration(REWARD_DURATION);
    notifyVariableRewardAmount(REWARD_PER_TOKEN_STORED, MAX_DEPOSIT_INITIAL_AMOUNT);
    verboseLog("Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted");
    vm.stopPrank();

    verboseLog(
      "Staking contract: Amount deposited before starting rewarding is lower or equal to max amount. ",
      MAX_DEPOSIT_INITIAL_AMOUNT
    );

    gotoTimestamp(INITIAL_BLOCK_TIMESTAMP + 2);

    // Deposit more tokens without updating the max deposit amount
    vm.startPrank(userAlice);
    stakingERC20.approve(address(stakingRewards2), ALICE_ADDITIONNAL_DEPOSIT_AMOUNT);
    vm.expectRevert(
      abi.encodeWithSelector(
        StakeTotalSupplyExceedsAllowedMax.selector,
        ALICE_INITIAL_DEPOSIT_AMOUNT + ALICE_ADDITIONNAL_DEPOSIT_AMOUNT, // newTotalSupply
        MAX_DEPOSIT_INITIAL_AMOUNT, // variableRewardMaxTotalSupply
        1, // depositAmount
        ALICE_INITIAL_DEPOSIT_AMOUNT // currentTotalSupply
      )
    );
    stakingRewards2.stake(ALICE_ADDITIONNAL_DEPOSIT_AMOUNT);
    vm.stopPrank();

    // Deposit more tokens after updating the max deposit amount
    // Update max deposit amount
    vm.expectEmit(true, false, false, false, address(stakingRewards2));
    emit StakingRewards2Events.MaxTotalSupply(ALICE_INITIAL_DEPOSIT_AMOUNT + ALICE_ADDITIONNAL_DEPOSIT_AMOUNT);
    vm.prank(userStakingRewardAdmin);
    stakingRewards2.updateVariableRewardMaxTotalSupply(
      ALICE_INITIAL_DEPOSIT_AMOUNT + ALICE_ADDITIONNAL_DEPOSIT_AMOUNT
    );

    // Deposit too much tokens
    vm.prank(userAlice);
    vm.expectRevert(
      abi.encodeWithSelector(
        StakeTotalSupplyExceedsAllowedMax.selector,
        ALICE_INITIAL_DEPOSIT_AMOUNT + ALICE_ADDITIONNAL_DEPOSIT_AMOUNT + 1, // newTotalSupply
        ALICE_INITIAL_DEPOSIT_AMOUNT + ALICE_ADDITIONNAL_DEPOSIT_AMOUNT, // variableRewardMaxTotalSupply
        ALICE_ADDITIONNAL_DEPOSIT_AMOUNT + 1, // depositAmount
        ALICE_INITIAL_DEPOSIT_AMOUNT // currentTotalSupply
      )
    );
    stakingRewards2.stake(ALICE_ADDITIONNAL_DEPOSIT_AMOUNT + 1);

    assertEq(stakingRewards2.totalSupply(), ALICE_INITIAL_DEPOSIT_AMOUNT);
  }

  // Check already deposited amount is lower or equal than max amount,
  // allow more deposit and deposit exessive token amount
  function testStakingNotifyVariableRewardAmountFail4_1() public {
    // Reward rate : 10% yearly
    // Depositing 1 Token should give 0.1 ( = 10^17) token reward per year
    /* solhint-disable var-name-mixedcase */

    uint256 APR = 10; // 10%
    uint256 APR_BASE = 100; // 100%
    uint256 MAX_DEPOSIT_TOKEN_AMOUNT = 100;
    uint256 MAX_DEPOSIT_AMOUNT = MAX_DEPOSIT_TOKEN_AMOUNT * ONE_TOKEN_18; // 100 token // 100 000 000 000 000 000 000
      // = 1e20 = 100 * 1e18 (1 000 000 000 000 000 000)
    uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT * APR / APR_BASE; // 10 token
    uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year
    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;

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
    setRewardsDuration(REWARD_DURATION);

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
    uint256 MAX_DEPOSIT_AMOUNT = MAX_DEPOSIT_TOKEN_AMOUNT * ONE_TOKEN_18; // 100 token // 100 000 000 000 000 000 000
      // = 1e20 = 100 * 1e18 (1 000 000 000 000 000 000)
    // uint256 REWARD_AMOUNT = MAX_DEPOSIT_AMOUNT * APR / APR_BASE; // 10 token
    uint256 REWARD_DURATION = 31_536_000; // 31 536 000 s. = 1 year
    uint256 REWARD_PER_TOKEN_STORED = (ONE_TOKEN_18 * APR / APR_BASE) / REWARD_DURATION;
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
    setRewardsDuration(REWARD_DURATION);

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
