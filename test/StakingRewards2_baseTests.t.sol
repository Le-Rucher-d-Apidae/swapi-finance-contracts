// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

// import { console } from "forge-std/src/console.sol";
// import { stdMath } from "forge-std/src/StdMath.sol";

// import "./StakingRewards2_commonbase.t.sol";
import { StakingSetup2 } from "./StakingRewards2Setups.t.sol";
// import {
//     DELTA_0_00000000022,
//     DELTA_0_015,
//     DELTA_0_31,
//     PERCENT_1,
//     PERCENT_5,
//     PERCENT_90,
//     PERCENT_100,
//     DELTA_0,
//     ONE_TOKEN
// } from "./TestsConstants.sol";

// import { StakingRewards2 } from "../src/contracts/StakingRewards2.sol";
// // import "../src/contracts/StakingRewards2Errors.sol";
import { RewardPeriodInProgress, ProvidedRewardTooHigh } from "../src/contracts/StakingRewards2Errors.sol";
import { StakingRewards2Events } from "../src/contracts/StakingRewards2Events.sol";

// import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";
import { Ownable } from "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts@5.0.2/utils/Pausable.sol";

// --------------------------------------------------------

// /*

contract CheckStakingPermissions2 is StakingSetup2 {
    function setUp() public virtual override {
        debugLog("CheckStakingPermissions2 setUp() start");
        verboseLog("CheckStakingPermissions2 setUp()");
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
        verboseLog("Staking contract: Only owner can notifyRewardAmount of ", 1);
        verboseLog("Staking contract: Event RewardAdded emitted");
    }

    function testStakingNotifyRewardAmount0() public {
        vm.prank(userStakingRewardAdmin);
        notifyRewardAmount(0);
        verboseLog("Staking contract: Only owner can notifyRewardAmount of ", 0);
        verboseLog("Staking contract: Event RewardAdded emitted");
    }

    function testStakingNotifyRewardAmountLimit1() public {
        uint256 rewardAmountToAddForRaisingError = REWARD_INITIAL_DURATION; // computed  reward rate must exceed by at
            // least one unit for raising an error
        vm.prank(userStakingRewardAdmin);
        notifyRewardAmount(rewardAmountToAddForRaisingError - 1);
        verboseLog("Staking contract: Only owner can notifyRewardAmount of ", rewardAmountToAddForRaisingError - 1);
        verboseLog("Staking contract: Event RewardAdded emitted");
    }

    function testStakingNotifyRewardAmountLimitMax() public {
        uint256 additionnalRewardAmount = REWARD_INITIAL_DURATION;

        // Mint reward ERC20 a second time
        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), additionnalRewardAmount);

        vm.prank(userStakingRewardAdmin);
        notifyRewardAmount(additionnalRewardAmount);
        verboseLog("Staking contract: Only owner can notifyRewardAmount of an additionnal ", additionnalRewardAmount);
        verboseLog("Staking contract: Event RewardAdded emitted");
    }

    function testStakingRewardAmountTooHigh1() public {
        uint256 rewardAmountToAddForRaisingError = REWARD_INITIAL_DURATION; // computed  reward rate must exceed by at
            // least one unit for raising an error

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

    function testStakingRewardAmountTooHigh2() public {
        uint256 rewardAmountToAddForRaisingError = REWARD_INITIAL_DURATION; // computed  reward rate must exceed by at
            // least one unit for raising an error

        // Mint reward ERC20 a second time
        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), rewardAmountToAddForRaisingError);

        vm.prank(userStakingRewardAdmin);
        // Check revert
        vm.expectRevert(
            abi.encodeWithSelector(
                ProvidedRewardTooHigh.selector,
                rewardAmountToAddForRaisingError * 2,
                REWARD_INITIAL_AMOUNT + rewardAmountToAddForRaisingError,
                REWARD_INITIAL_DURATION
            )
        );
        stakingRewards2.notifyRewardAmount(rewardAmountToAddForRaisingError * 2);

        verboseLog("Staking contract: Only owner can notifyRewardAmount of ", rewardAmountToAddForRaisingError + 1);
        verboseLog("Staking contract: Event RewardAdded emitted");
    }

    function testStakingSetRewardsDuration() public {
        // Previous reward epoch must have ended before setting a new duration
        vm.warp(STAKING_TIMESTAMP + REWARD_INITIAL_DURATION + 1); // epoch ended

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

    function testStakingSetRewardsDurationBeforeEpochEnd() public {
        // Previous reward epoch must have ended before setting a new duration
        vm.startPrank(userStakingRewardAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(
                RewardPeriodInProgress.selector, block.timestamp, STAKING_TIMESTAMP + REWARD_INITIAL_DURATION
            )
        );
        // vm.expectRevert( bytes(_MMPOR000) );
        stakingRewards2.setRewardsDuration(1);

        // Previous reward epoch must have ended before setting a new duration
        vm.warp(STAKING_TIMESTAMP + REWARD_INITIAL_DURATION); // epoch last time reward
        vm.expectRevert(
            abi.encodeWithSelector(
                RewardPeriodInProgress.selector, block.timestamp, STAKING_TIMESTAMP + REWARD_INITIAL_DURATION
            )
        );
        stakingRewards2.setRewardsDuration(1);

        verboseLog("Staking contract: Owner can't setRewardsDuration before previous epoch end");
        vm.stopPrank();
    }
}

// */
