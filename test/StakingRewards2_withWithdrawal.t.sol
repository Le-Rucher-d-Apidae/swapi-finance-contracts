// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import {
    DuringStaking1WithWithdral,
    DuringStaking2WithWithdral,
    DuringStaking3WithWithdral
} from "./StakingRewards2_setups.t.sol";

import {
    PERCENT_0,
    PERCENT_0_1,
    PERCENT_1,
    PERCENT_5,
    PERCENT_10,
    PERCENT_15,
    PERCENT_20,
    PERCENT_30,
    PERCENT_33,
    PERCENT_40,
    PERCENT_45,
    PERCENT_50,
    PERCENT_60,
    PERCENT_66,
    PERCENT_70,
    PERCENT_80,
    PERCENT_90,
    PERCENT_99,
    PERCENT_100,
    PERCENT_101,
    PERCENT_110,
    PERCENT_150,
    PERCENT_190,
    PERCENT_200,
    PERCENT_201,
    PERCENT_220
} from "./TestsConstants.sol";


// ----------------
/* solhint-disable no-empty-blocks */
/* solhint-disable contract-name-camelcase */

// 1 staker deposit right after staking starts and removes all staked amount after half of staking percentage duration
// 42 tests
// /*
contract DuringStaking1_WithWithdral__0 is DuringStaking1WithWithdral(PERCENT_0, PERCENT_0) { }

contract DuringStaking1_WithWithdral__1_0_1 is DuringStaking1WithWithdral(PERCENT_1, PERCENT_0_1) { }

contract DuringStaking1_WithWithdral__10__0 is DuringStaking1WithWithdral(PERCENT_10, PERCENT_0) { }

contract DuringStaking1_WithWithdral__10__5 is DuringStaking1WithWithdral(PERCENT_10, PERCENT_5) { }

contract DuringStaking1_WithWithdral__20__0 is DuringStaking1WithWithdral(PERCENT_20, PERCENT_0) { }

contract DuringStaking1_WithWithdral__20__10 is DuringStaking1WithWithdral(PERCENT_20, PERCENT_10) { }

contract DuringStaking1_WithWithdral__30__0 is DuringStaking1WithWithdral(PERCENT_30, PERCENT_0) { }

contract DuringStaking1_WithWithdral__30__20 is DuringStaking1WithWithdral(PERCENT_30, PERCENT_15) { }

contract DuringStaking1_WithWithdral__33__0 is DuringStaking1WithWithdral(PERCENT_33, PERCENT_0) { }

contract DuringStaking1_WithWithdral__33__10 is DuringStaking1WithWithdral(PERCENT_33, PERCENT_10) { }

contract DuringStaking1_WithWithdral__40__0 is DuringStaking1WithWithdral(PERCENT_40, PERCENT_0) { }

contract DuringStaking1_WithWithdral__40__5 is DuringStaking1WithWithdral(PERCENT_40, PERCENT_5) { }

contract DuringStaking1_WithWithdral__50__0 is DuringStaking1WithWithdral(PERCENT_50, PERCENT_0) { }

contract DuringStaking1_WithWithdral__50__5 is DuringStaking1WithWithdral(PERCENT_50, PERCENT_5) { }

contract DuringStaking1_WithWithdral__60__0 is DuringStaking1WithWithdral(PERCENT_60, PERCENT_0) { }

contract DuringStaking1_WithWithdral__60__20 is DuringStaking1WithWithdral(PERCENT_60, PERCENT_20) { }

contract DuringStaking1_WithWithdral__66__0 is DuringStaking1WithWithdral(PERCENT_66, PERCENT_0) { }

contract DuringStaking1_WithWithdral__66__30 is DuringStaking1WithWithdral(PERCENT_66, PERCENT_30) { }

contract DuringStaking1_WithWithdral__70__0 is DuringStaking1WithWithdral(PERCENT_70, PERCENT_0) { }

contract DuringStaking1_WithWithdral__70__10 is DuringStaking1WithWithdral(PERCENT_70, PERCENT_10) { }

contract DuringStaking1_WithWithdral__80__0 is DuringStaking1WithWithdral(PERCENT_80, PERCENT_0) { }

contract DuringStaking1_WithWithdral__80__70 is DuringStaking1WithWithdral(PERCENT_80, PERCENT_30) { }

contract DuringStaking1_WithWithdral__90__0 is DuringStaking1WithWithdral(PERCENT_90, PERCENT_0) { }

contract DuringStaking1_WithWithdral__90__50 is DuringStaking1WithWithdral(PERCENT_90, PERCENT_45) { }

contract DuringStaking1_WithWithdral__99__0 is DuringStaking1WithWithdral(PERCENT_99, PERCENT_0) { }

contract DuringStaking1_WithWithdral__99__33 is DuringStaking1WithWithdral(PERCENT_99, PERCENT_33) { }

contract DuringStaking1_WithWithdral__100__0 is DuringStaking1WithWithdral(PERCENT_100, PERCENT_0) { }

contract DuringStaking1_WithWithdral__100__30 is DuringStaking1WithWithdral(PERCENT_100, PERCENT_30) { }

contract DuringStaking1_WithWithdral__101__0 is DuringStaking1WithWithdral(PERCENT_101, PERCENT_0) { }

contract DuringStaking1_WithWithdral__101__50 is DuringStaking1WithWithdral(PERCENT_101, PERCENT_50) { }

contract DuringStaking1_WithWithdral__110__0 is DuringStaking1WithWithdral(PERCENT_110, PERCENT_0) { }

contract DuringStaking1_WithWithdral__110__60 is DuringStaking1WithWithdral(PERCENT_110, PERCENT_40) { }

contract DuringStaking1_WithWithdral__150__0 is DuringStaking1WithWithdral(PERCENT_150, PERCENT_0) { }

contract DuringStaking1_WithWithdral__150__70 is DuringStaking1WithWithdral(PERCENT_150, PERCENT_70) { }

contract DuringStaking1_WithWithdral__190__0 is DuringStaking1WithWithdral(PERCENT_190, PERCENT_0) { }

contract DuringStaking1_WithWithdral__190__80 is DuringStaking1WithWithdral(PERCENT_190, PERCENT_80) { }

contract DuringStaking1_WithWithdral__200__0 is DuringStaking1WithWithdral(PERCENT_200, PERCENT_0) { }

contract DuringStaking1_WithWithdral__200__90 is DuringStaking1WithWithdral(PERCENT_200, PERCENT_90) { }

contract DuringStaking1_WithWithdral__201__0 is DuringStaking1WithWithdral(PERCENT_201, PERCENT_0) { }

contract DuringStaking1_WithWithdral__201__90 is DuringStaking1WithWithdral(PERCENT_201, PERCENT_90) { }

contract DuringStaking1_WithWithdral__220__0 is DuringStaking1WithWithdral(PERCENT_220, PERCENT_0) { }

contract DuringStaking1_WithWithdral__220__99 is DuringStaking1WithWithdral(PERCENT_220, PERCENT_99) { }
// */
// ------------------------------------

// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration
// /*
// 42 tests
contract DuringStaking2_WithWithdral__0 is DuringStaking2WithWithdral(PERCENT_0, PERCENT_0) { }

contract DuringStaking2_WithWithdral__1_0_1 is DuringStaking2WithWithdral(PERCENT_1, PERCENT_0_1) { }

contract DuringStaking2_WithWithdral__10__0 is DuringStaking2WithWithdral(PERCENT_10, PERCENT_0) { }

contract DuringStaking2_WithWithdral__10__5 is DuringStaking2WithWithdral(PERCENT_10, PERCENT_5) { }

contract DuringStaking2_WithWithdral__20__0 is DuringStaking2WithWithdral(PERCENT_20, PERCENT_0) { }

contract DuringStaking2_WithWithdral__20__10 is DuringStaking2WithWithdral(PERCENT_20, PERCENT_10) { }

contract DuringStaking2_WithWithdral__30__0 is DuringStaking2WithWithdral(PERCENT_30, PERCENT_0) { }

contract DuringStaking2_WithWithdral__30__20 is DuringStaking2WithWithdral(PERCENT_30, PERCENT_15) { }

contract DuringStaking2_WithWithdral__33__0 is DuringStaking2WithWithdral(PERCENT_33, PERCENT_0) { }

contract DuringStaking2_WithWithdral__33__10 is DuringStaking2WithWithdral(PERCENT_33, PERCENT_10) { }

contract DuringStaking2_WithWithdral__40__0 is DuringStaking2WithWithdral(PERCENT_40, PERCENT_0) { }

contract DuringStaking2_WithWithdral__40__5 is DuringStaking2WithWithdral(PERCENT_40, PERCENT_5) { }

contract DuringStaking2_WithWithdral__50__0 is DuringStaking2WithWithdral(PERCENT_50, PERCENT_0) { }

contract DuringStaking2_WithWithdral__50__5 is DuringStaking2WithWithdral(PERCENT_50, PERCENT_5) { }

contract DuringStaking2_WithWithdral__60__0 is DuringStaking2WithWithdral(PERCENT_60, PERCENT_0) { }

contract DuringStaking2_WithWithdral__60__20 is DuringStaking2WithWithdral(PERCENT_60, PERCENT_20) { }

contract DuringStaking2_WithWithdral__66__0 is DuringStaking2WithWithdral(PERCENT_66, PERCENT_0) { }

contract DuringStaking2_WithWithdral__66__30 is DuringStaking2WithWithdral(PERCENT_66, PERCENT_30) { }

contract DuringStaking2_WithWithdral__70__0 is DuringStaking2WithWithdral(PERCENT_70, PERCENT_0) { }

contract DuringStaking2_WithWithdral__70__10 is DuringStaking2WithWithdral(PERCENT_70, PERCENT_10) { }

contract DuringStaking2_WithWithdral__80__0 is DuringStaking2WithWithdral(PERCENT_80, PERCENT_0) { }

contract DuringStaking2_WithWithdral__80__70 is DuringStaking2WithWithdral(PERCENT_80, PERCENT_30) { }

contract DuringStaking2_WithWithdral__90__0 is DuringStaking2WithWithdral(PERCENT_90, PERCENT_0) { }

contract DuringStaking2_WithWithdral__90__50 is DuringStaking2WithWithdral(PERCENT_90, PERCENT_45) { }

contract DuringStaking2_WithWithdral__99__0 is DuringStaking2WithWithdral(PERCENT_99, PERCENT_0) { }

contract DuringStaking2_WithWithdral__99__33 is DuringStaking2WithWithdral(PERCENT_99, PERCENT_33) { }

contract DuringStaking2_WithWithdral__100__0 is DuringStaking2WithWithdral(PERCENT_100, PERCENT_0) { }

contract DuringStaking2_WithWithdral__100__30 is DuringStaking2WithWithdral(PERCENT_100, PERCENT_30) { }

contract DuringStaking2_WithWithdral__101__0 is DuringStaking2WithWithdral(PERCENT_101, PERCENT_0) { }

contract DuringStaking2_WithWithdral__101__50 is DuringStaking2WithWithdral(PERCENT_101, PERCENT_50) { }

contract DuringStaking2_WithWithdral__110__0 is DuringStaking2WithWithdral(PERCENT_110, PERCENT_0) { }

contract DuringStaking2_WithWithdral__110__60 is DuringStaking2WithWithdral(PERCENT_110, PERCENT_40) { }

contract DuringStaking2_WithWithdral__150__0 is DuringStaking2WithWithdral(PERCENT_150, PERCENT_0) { }

contract DuringStaking2_WithWithdral__150__70 is DuringStaking2WithWithdral(PERCENT_150, PERCENT_70) { }

contract DuringStaking2_WithWithdral__190__0 is DuringStaking2WithWithdral(PERCENT_190, PERCENT_0) { }

contract DuringStaking2_WithWithdral__190__80 is DuringStaking2WithWithdral(PERCENT_190, PERCENT_80) { }

contract DuringStaking2_WithWithdral__200__0 is DuringStaking2WithWithdral(PERCENT_200, PERCENT_0) { }

contract DuringStaking2_WithWithdral__200__90 is DuringStaking2WithWithdral(PERCENT_200, PERCENT_90) { }

contract DuringStaking2_WithWithdral__201__0 is DuringStaking2WithWithdral(PERCENT_201, PERCENT_0) { }

contract DuringStaking2_WithWithdral__201__90 is DuringStaking2WithWithdral(PERCENT_201, PERCENT_90) { }

contract DuringStaking2_WithWithdral__220__0 is DuringStaking2WithWithdral(PERCENT_220, PERCENT_0) { }

contract DuringStaking2_WithWithdral__220__99 is DuringStaking2WithWithdral(PERCENT_220, PERCENT_99) { }
// */
// ------------------------------------

// 3 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration
// /*
// 42 tests
contract DuringStaking3_WithWithdral__0 is DuringStaking3WithWithdral(PERCENT_0, PERCENT_0) { }

contract DuringStaking3_WithWithdral__1_0_1 is DuringStaking3WithWithdral(PERCENT_1, PERCENT_0_1) { }

contract DuringStaking3_WithWithdral__10__0 is DuringStaking3WithWithdral(PERCENT_10, PERCENT_0) { }

contract DuringStaking3_WithWithdral__10__5 is DuringStaking3WithWithdral(PERCENT_10, PERCENT_5) { }

contract DuringStaking3_WithWithdral__20__0 is DuringStaking3WithWithdral(PERCENT_20, PERCENT_0) { }

contract DuringStaking3_WithWithdral__20__10 is DuringStaking3WithWithdral(PERCENT_20, PERCENT_10) { }

contract DuringStaking3_WithWithdral__30__0 is DuringStaking3WithWithdral(PERCENT_30, PERCENT_0) { }

contract DuringStaking3_WithWithdral__30__20 is DuringStaking3WithWithdral(PERCENT_30, PERCENT_15) { }

contract DuringStaking3_WithWithdral__33__0 is DuringStaking3WithWithdral(PERCENT_33, PERCENT_0) { }

contract DuringStaking3_WithWithdral__33__10 is DuringStaking3WithWithdral(PERCENT_33, PERCENT_10) { }

contract DuringStaking3_WithWithdral__40__0 is DuringStaking3WithWithdral(PERCENT_40, PERCENT_0) { }

contract DuringStaking3_WithWithdral__40__5 is DuringStaking3WithWithdral(PERCENT_40, PERCENT_5) { }

contract DuringStaking3_WithWithdral__50__0 is DuringStaking3WithWithdral(PERCENT_50, PERCENT_0) { }

contract DuringStaking3_WithWithdral__50__5 is DuringStaking3WithWithdral(PERCENT_50, PERCENT_5) { }

contract DuringStaking3_WithWithdral__60__0 is DuringStaking3WithWithdral(PERCENT_60, PERCENT_0) { }

contract DuringStaking3_WithWithdral__60__20 is DuringStaking3WithWithdral(PERCENT_60, PERCENT_20) { }

contract DuringStaking3_WithWithdral__66__0 is DuringStaking3WithWithdral(PERCENT_66, PERCENT_0) { }

contract DuringStaking3_WithWithdral__66__30 is DuringStaking3WithWithdral(PERCENT_66, PERCENT_30) { }

contract DuringStaking3_WithWithdral__70__0 is DuringStaking3WithWithdral(PERCENT_70, PERCENT_0) { }

contract DuringStaking3_WithWithdral__70__10 is DuringStaking3WithWithdral(PERCENT_70, PERCENT_10) { }

contract DuringStaking3_WithWithdral__80__0 is DuringStaking3WithWithdral(PERCENT_80, PERCENT_0) { }

contract DuringStaking3_WithWithdral__80__70 is DuringStaking3WithWithdral(PERCENT_80, PERCENT_30) { }

contract DuringStaking3_WithWithdral__90__0 is DuringStaking3WithWithdral(PERCENT_90, PERCENT_0) { }

contract DuringStaking3_WithWithdral__90__50 is DuringStaking3WithWithdral(PERCENT_90, PERCENT_45) { }

contract DuringStaking3_WithWithdral__99__0 is DuringStaking3WithWithdral(PERCENT_99, PERCENT_0) { }

contract DuringStaking3_WithWithdral__99__33 is DuringStaking3WithWithdral(PERCENT_99, PERCENT_33) { }

contract DuringStaking3_WithWithdral__100__0 is DuringStaking3WithWithdral(PERCENT_100, PERCENT_0) { }

contract DuringStaking3_WithWithdral__100__30 is DuringStaking3WithWithdral(PERCENT_100, PERCENT_30) { }

contract DuringStaking3_WithWithdral__101__0 is DuringStaking3WithWithdral(PERCENT_101, PERCENT_0) { }

contract DuringStaking3_WithWithdral__101__50 is DuringStaking3WithWithdral(PERCENT_101, PERCENT_50) { }

contract DuringStaking3_WithWithdral__110__0 is DuringStaking3WithWithdral(PERCENT_110, PERCENT_0) { }

contract DuringStaking3_WithWithdral__110__60 is DuringStaking3WithWithdral(PERCENT_110, PERCENT_40) { }

contract DuringStaking3_WithWithdral__150__0 is DuringStaking3WithWithdral(PERCENT_150, PERCENT_0) { }

contract DuringStaking3_WithWithdral__150__70 is DuringStaking3WithWithdral(PERCENT_150, PERCENT_70) { }

contract DuringStaking3_WithWithdral__190__0 is DuringStaking3WithWithdral(PERCENT_190, PERCENT_0) { }

contract DuringStaking3_WithWithdral__190__80 is DuringStaking3WithWithdral(PERCENT_190, PERCENT_80) { }

contract DuringStaking3_WithWithdral__200__0 is DuringStaking3WithWithdral(PERCENT_200, PERCENT_0) { }

contract DuringStaking3_WithWithdral__200__90 is DuringStaking3WithWithdral(PERCENT_200, PERCENT_90) { }

contract DuringStaking3_WithWithdral__201__0 is DuringStaking3WithWithdral(PERCENT_201, PERCENT_0) { }

contract DuringStaking3_WithWithdral__201__90 is DuringStaking3WithWithdral(PERCENT_201, PERCENT_90) { }

contract DuringStaking3_WithWithdral__220__0 is DuringStaking3WithWithdral(PERCENT_220, PERCENT_0) { }

contract DuringStaking3_WithWithdral__220__99 is DuringStaking3WithWithdral(PERCENT_220, PERCENT_99) { }
// */
/* solhint-enable no-empty-blocks */
/* solhint-enable contract-name-camelcase */
// --------------------------------------------------------
