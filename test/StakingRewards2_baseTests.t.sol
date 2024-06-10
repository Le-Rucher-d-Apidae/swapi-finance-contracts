// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { StakingPreSetup } from "./StakingRewards2_setups.t.sol";
import { RewardPeriodInProgress, ProvidedRewardTooHigh, NotVariableRewardRate } from "../src/contracts/StakingRewards2Errors.sol";
import { StakingRewards2Events } from "../src/contracts/StakingRewards2Events.sol";

import { Ownable } from "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts@5.0.2/utils/Pausable.sol";

// ----------------

// /*

contract CheckStakingPermissions is StakingPreSetup {
  function setUp() public virtual override {
    debugLog("CheckStakingPermissions setUp() start");
    verboseLog("CheckStakingPermissions setUp()");
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

    // Unpausing again should not throw nor emit event and leave pause unchanged
    stakingRewards2.setPaused(false);
    // Check no event emitted ?
    assertEq(stakingRewards2.paused(), false);

    vm.stopPrank();
  }

  function testStakingPauseDuringRewarding() public {
    // start rewarding
    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(REWARD_INITIAL_AMOUNT);

    testStakingPause();
  }

  function testStakingNotifyRewardAmountMin() public {
    verboseLog("Only staking reward contract owner can notifyRewardAmount");

    vm.prank(userAlice);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
    stakingRewards2.notifyRewardAmount(1);
    verboseLog("Staking contract: Alice can't notifyRewardAmount");

    vm.prank(userBob);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));
    stakingRewards2.notifyRewardAmount(1);
    verboseLog("Staking contract: Bob can't notifyRewardAmount");

    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(1);
    verboseLog("Staking contract: Only owner can notifyRewardAmount of 1");
    verboseLog("Staking contract: Event RewardAdded emitted");
  }

  function testStakingNotifyRewardAmount0() public {
    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(0);
    verboseLog("Staking contract: Only owner can notifyRewardAmount of 0");
    verboseLog("Staking contract: Event RewardAdded emitted");
  }

  function testStakingNotifyRewardAmountLimit1() public {
    // computed reward rate must exceed by at least one unit for raising an error
    // one unit equals to REWARD_INITIAL_DURATION
    uint256 rewardAmountToAddForRaisingError = REWARD_INITIAL_DURATION - 1;
    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(REWARD_INITIAL_AMOUNT + rewardAmountToAddForRaisingError);
    verboseLog("Staking contract: Only owner can notifyRewardAmount of ", rewardAmountToAddForRaisingError - 1);
    verboseLog("Staking contract: Event RewardAdded emitted");
  }

  function testUpdateVariableRewardMaxTotalSupplyFail() public {
    // computed reward rate must exceed by at least one unit for raising an error
    // one unit equals to REWARD_INITIAL_DURATION
    uint256 rewardAmountToAddForRaisingError = REWARD_INITIAL_DURATION - 1;
    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(REWARD_INITIAL_AMOUNT + rewardAmountToAddForRaisingError);
    verboseLog("Staking contract: Only owner can notifyRewardAmount of ", rewardAmountToAddForRaisingError - 1);
    verboseLog("Staking contract: Event RewardAdded emitted");

    // Check emitted events
    vm.expectRevert( abi.encodeWithSelector( NotVariableRewardRate.selector ) );
    vm.prank(userStakingRewardAdmin);
    stakingRewards2.updateVariableRewardMaxTotalSupply(1);
    verboseLog("Staking contract: Error NotVariableRewardRate thrown");

  }

  function testStakingRewardAmountTooHigh1() public {
    uint256 rewardAmountToAddForRaisingError = REWARD_INITIAL_AMOUNT + REWARD_INITIAL_DURATION;
    vm.prank(userStakingRewardAdmin);
    // Check revert
    vm.expectRevert(
      abi.encodeWithSelector(
        ProvidedRewardTooHigh.selector,
        rewardAmountToAddForRaisingError,
        REWARD_INITIAL_AMOUNT,
        REWARD_INITIAL_DURATION
      )
    );
    stakingRewards2.notifyRewardAmount(rewardAmountToAddForRaisingError);
    verboseLog("Staking contract: Not enough reward balance");
  }

  // not enough reward balance BUT no error raised because of rounding
  function testStakingNotifyRewardAmountNotTooHighEnough1() public {
    uint256 additionnalRewardAmount = REWARD_INITIAL_DURATION;

    // Mint additionnal reward ERC20
    vm.prank(erc20Minter);
    rewardErc20.mint(address(stakingRewards2), additionnalRewardAmount);
    //
    additionnalRewardAmount += (REWARD_INITIAL_DURATION - 1);

    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(REWARD_INITIAL_AMOUNT + additionnalRewardAmount);
    verboseLog("Staking contract: Only owner can notifyRewardAmount of an additionnal ", additionnalRewardAmount);
    verboseLog("Staking contract: Event RewardAdded emitted");
  }

  function testSetRewardsDurationAfterRewardEnd() public {
    // start rewarding
    vm.prank(userStakingRewardAdmin);
    notifyRewardAmount(REWARD_INITIAL_AMOUNT);

    // Previous reward epoch must have ended before setting a new duration
    gotoTimestamp(STAKING_END_TIMESTAMP + 1);

    vm.prank(userAlice);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
    verboseLog("Only staking reward contract owner can setRewardsDuration");

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

  function testStakingSetRewardsDurationBeforeRewardEnd() public {
    // Previous reward epoch must have ended before setting a new duration
    vm.startPrank(userStakingRewardAdmin);
    notifyRewardAmount(REWARD_INITIAL_AMOUNT);
    verboseLog("STAKING_START_TIMESTAMP = ", STAKING_START_TIMESTAMP);

    vm.expectRevert(abi.encodeWithSelector(RewardPeriodInProgress.selector, block.timestamp, STAKING_END_TIMESTAMP));
    stakingRewards2.setRewardsDuration(1);

    // Previous reward epoch must have ended before setting a new duration
    gotoTimestamp(STAKING_END_TIMESTAMP); // epoch last time reward
    vm.expectRevert(abi.encodeWithSelector(RewardPeriodInProgress.selector, block.timestamp, STAKING_END_TIMESTAMP));
    stakingRewards2.setRewardsDuration(1);

    verboseLog("Staking contract: Owner can't setRewardsDuration before previous epoch end");
    vm.stopPrank();
  }
}

// */
