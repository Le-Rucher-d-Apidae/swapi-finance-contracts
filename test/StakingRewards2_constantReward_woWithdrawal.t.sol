// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import "./StakingRewards2_constantReward.t.sol";

// ----------------------------------------------------------------------------

// 1 staker deposits right after staking starts and keeps staked amount until the end of staking period
// 42 tests
// /*
contract DuringStaking1_WithoutWithdral_0 is DuringStaking1_WithoutWithdral(PERCENT_0, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_1_0_1 is DuringStaking1_WithoutWithdral(PERCENT_1, PERCENT_0_1) { }

contract DuringStaking1_WithoutWithdral_10__0 is DuringStaking1_WithoutWithdral(PERCENT_10, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_10__5 is DuringStaking1_WithoutWithdral(PERCENT_10, PERCENT_5) { }

contract DuringStaking1_WithoutWithdral_20__0 is DuringStaking1_WithoutWithdral(PERCENT_20, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_20__10 is DuringStaking1_WithoutWithdral(PERCENT_20, PERCENT_10) { }

contract DuringStaking1_WithoutWithdral_30__0 is DuringStaking1_WithoutWithdral(PERCENT_30, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_30__20 is DuringStaking1_WithoutWithdral(PERCENT_30, PERCENT_20) { }

contract DuringStaking1_WithoutWithdral_33__0 is DuringStaking1_WithoutWithdral(PERCENT_33, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_33__10 is DuringStaking1_WithoutWithdral(PERCENT_33, PERCENT_10) { }

contract DuringStaking1_WithoutWithdral_40__0 is DuringStaking1_WithoutWithdral(PERCENT_40, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_40__5 is DuringStaking1_WithoutWithdral(PERCENT_40, PERCENT_5) { }

contract DuringStaking1_WithoutWithdral_50__0 is DuringStaking1_WithoutWithdral(PERCENT_50, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_50__5 is DuringStaking1_WithoutWithdral(PERCENT_50, PERCENT_5) { }

contract DuringStaking1_WithoutWithdral_60__0 is DuringStaking1_WithoutWithdral(PERCENT_60, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_60__20 is DuringStaking1_WithoutWithdral(PERCENT_60, PERCENT_20) { }

contract DuringStaking1_WithoutWithdral_66__0 is DuringStaking1_WithoutWithdral(PERCENT_66, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_66__30 is DuringStaking1_WithoutWithdral(PERCENT_66, PERCENT_30) { }

contract DuringStaking1_WithoutWithdral_70__0 is DuringStaking1_WithoutWithdral(PERCENT_70, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_70__10 is DuringStaking1_WithoutWithdral(PERCENT_70, PERCENT_10) { }

contract DuringStaking1_WithoutWithdral_80__0 is DuringStaking1_WithoutWithdral(PERCENT_80, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_80__70 is DuringStaking1_WithoutWithdral(PERCENT_80, PERCENT_70) { }

contract DuringStaking1_WithoutWithdral_90__0 is DuringStaking1_WithoutWithdral(PERCENT_90, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_90__50 is DuringStaking1_WithoutWithdral(PERCENT_90, PERCENT_50) { }

contract DuringStaking1_WithoutWithdral_99__0 is DuringStaking1_WithoutWithdral(PERCENT_99, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_99__33 is DuringStaking1_WithoutWithdral(PERCENT_99, PERCENT_33) { }

contract DuringStaking1_WithoutWithdral_100__0 is DuringStaking1_WithoutWithdral(PERCENT_100, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_100__30 is DuringStaking1_WithoutWithdral(PERCENT_100, PERCENT_30) { }

contract DuringStaking1_WithoutWithdral_101__0 is DuringStaking1_WithoutWithdral(PERCENT_101, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_101__50 is DuringStaking1_WithoutWithdral(PERCENT_101, PERCENT_50) { }

contract DuringStaking1_WithoutWithdral_110__0 is DuringStaking1_WithoutWithdral(PERCENT_110, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_110__60 is DuringStaking1_WithoutWithdral(PERCENT_110, PERCENT_60) { }

contract DuringStaking1_WithoutWithdral_150__0 is DuringStaking1_WithoutWithdral(PERCENT_150, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_150__70 is DuringStaking1_WithoutWithdral(PERCENT_150, PERCENT_70) { }

contract DuringStaking1_WithoutWithdral_190__0 is DuringStaking1_WithoutWithdral(PERCENT_190, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_190__80 is DuringStaking1_WithoutWithdral(PERCENT_190, PERCENT_80) { }

contract DuringStaking1_WithoutWithdral_200__0 is DuringStaking1_WithoutWithdral(PERCENT_200, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_200__90 is DuringStaking1_WithoutWithdral(PERCENT_200, PERCENT_90) { }

contract DuringStaking1_WithoutWithdral_201__0 is DuringStaking1_WithoutWithdral(PERCENT_201, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_201__90 is DuringStaking1_WithoutWithdral(PERCENT_201, PERCENT_90) { }

contract DuringStaking1_WithoutWithdral_220__0 is DuringStaking1_WithoutWithdral(PERCENT_220, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_220__99 is DuringStaking1_WithoutWithdral(PERCENT_220, PERCENT_99) { }
// */
// ------------------------------------

// 2 stakers deposit right after staking starts and keep staked amount until the end of staking period
// 42 tests
// /*
contract DuringStaking2_WithoutWithdral_0__0 is DuringStaking2_WithoutWithdral(PERCENT_0, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_1__0 is DuringStaking2_WithoutWithdral(PERCENT_1, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_1__0_1 is DuringStaking2_WithoutWithdral(PERCENT_1, PERCENT_0_1) { }

contract DuringStaking2_WithoutWithdral_10__0 is DuringStaking2_WithoutWithdral(PERCENT_10, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_10__5 is DuringStaking2_WithoutWithdral(PERCENT_10, PERCENT_5) { }

contract DuringStaking2_WithoutWithdral_20__0 is DuringStaking2_WithoutWithdral(PERCENT_20, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_20__10 is DuringStaking2_WithoutWithdral(PERCENT_20, PERCENT_10) { }

contract DuringStaking2_WithoutWithdral_30__ is DuringStaking2_WithoutWithdral(PERCENT_30, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_30__20 is DuringStaking2_WithoutWithdral(PERCENT_30, PERCENT_20) { }

contract DuringStaking2_WithoutWithdral_33__0 is DuringStaking2_WithoutWithdral(PERCENT_33, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_33__10 is DuringStaking2_WithoutWithdral(PERCENT_33, PERCENT_10) { }

contract DuringStaking2_WithoutWithdral_40__ is DuringStaking2_WithoutWithdral(PERCENT_40, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_40__5 is DuringStaking2_WithoutWithdral(PERCENT_40, PERCENT_5) { }

contract DuringStaking2_WithoutWithdral_50__0 is DuringStaking2_WithoutWithdral(PERCENT_50, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_50__5 is DuringStaking2_WithoutWithdral(PERCENT_50, PERCENT_5) { }

contract DuringStaking2_WithoutWithdral_60__0 is DuringStaking2_WithoutWithdral(PERCENT_60, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_60__20 is DuringStaking2_WithoutWithdral(PERCENT_60, PERCENT_20) { }

contract DuringStaking2_WithoutWithdral_66__0 is DuringStaking2_WithoutWithdral(PERCENT_66, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_66__30 is DuringStaking2_WithoutWithdral(PERCENT_66, PERCENT_30) { }

contract DuringStaking2_WithoutWithdral_70__0 is DuringStaking2_WithoutWithdral(PERCENT_70, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_70__10 is DuringStaking2_WithoutWithdral(PERCENT_70, PERCENT_10) { }

contract DuringStaking2_WithoutWithdral_80__0 is DuringStaking2_WithoutWithdral(PERCENT_80, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_80__70 is DuringStaking2_WithoutWithdral(PERCENT_80, PERCENT_70) { }

contract DuringStaking2_WithoutWithdral_90__0 is DuringStaking2_WithoutWithdral(PERCENT_90, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_90__50 is DuringStaking2_WithoutWithdral(PERCENT_90, PERCENT_50) { }

contract DuringStaking2_WithoutWithdral_99__0 is DuringStaking2_WithoutWithdral(PERCENT_99, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_99__33 is DuringStaking2_WithoutWithdral(PERCENT_99, PERCENT_33) { }

contract DuringStaking2_WithoutWithdral_100__0 is DuringStaking2_WithoutWithdral(PERCENT_100, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_100__30 is DuringStaking2_WithoutWithdral(PERCENT_100, PERCENT_30) { }

contract DuringStaking2_WithoutWithdral_101__0 is DuringStaking2_WithoutWithdral(PERCENT_101, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_101__50 is DuringStaking2_WithoutWithdral(PERCENT_101, PERCENT_50) { }

contract DuringStaking2_WithoutWithdral_110__0 is DuringStaking2_WithoutWithdral(PERCENT_110, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_110__60 is DuringStaking2_WithoutWithdral(PERCENT_110, PERCENT_60) { }

contract DuringStaking2_WithoutWithdral_150__0 is DuringStaking2_WithoutWithdral(PERCENT_150, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_150__70 is DuringStaking2_WithoutWithdral(PERCENT_150, PERCENT_70) { }

contract DuringStaking2_WithoutWithdral_190__0 is DuringStaking2_WithoutWithdral(PERCENT_190, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_190__80 is DuringStaking2_WithoutWithdral(PERCENT_190, PERCENT_80) { }

contract DuringStaking2_WithoutWithdral_200__0 is DuringStaking2_WithoutWithdral(PERCENT_200, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_200__90 is DuringStaking2_WithoutWithdral(PERCENT_200, PERCENT_90) { }

contract DuringStaking2_WithoutWithdral_201__0 is DuringStaking2_WithoutWithdral(PERCENT_201, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_201__90 is DuringStaking2_WithoutWithdral(PERCENT_201, PERCENT_90) { }

contract DuringStaking2_WithoutWithdral_220__0 is DuringStaking2_WithoutWithdral(PERCENT_220, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_220__99 is DuringStaking2_WithoutWithdral(PERCENT_220, PERCENT_99) { }
// */
// ------------------------------------

// 3 stakers deposit right after staking starts and keep staked amount until the end of staking period
// 42 tests
// /*
contract DuringStaking3_WithoutWithdral_0 is DuringStaking3_WithoutWithdral(PERCENT_0, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_1_0_1 is DuringStaking3_WithoutWithdral(PERCENT_1, PERCENT_0_1) { }

contract DuringStaking3_WithoutWithdral_10__0 is DuringStaking3_WithoutWithdral(PERCENT_10, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_10__5 is DuringStaking3_WithoutWithdral(PERCENT_10, PERCENT_5) { }

contract DuringStaking3_WithoutWithdral_20__0 is DuringStaking3_WithoutWithdral(PERCENT_20, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_20__10 is DuringStaking3_WithoutWithdral(PERCENT_20, PERCENT_10) { }

contract DuringStaking3_WithoutWithdral_30__0 is DuringStaking3_WithoutWithdral(PERCENT_30, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_30__20 is DuringStaking3_WithoutWithdral(PERCENT_30, PERCENT_20) { }

contract DuringStaking3_WithoutWithdral_33__0 is DuringStaking3_WithoutWithdral(PERCENT_33, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_33__10 is DuringStaking3_WithoutWithdral(PERCENT_33, PERCENT_10) { }

contract DuringStaking3_WithoutWithdral_40__0 is DuringStaking3_WithoutWithdral(PERCENT_40, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_40__5 is DuringStaking3_WithoutWithdral(PERCENT_40, PERCENT_5) { }

contract DuringStaking3_WithoutWithdral_50__0 is DuringStaking3_WithoutWithdral(PERCENT_50, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_50__5 is DuringStaking3_WithoutWithdral(PERCENT_50, PERCENT_5) { }

contract DuringStaking3_WithoutWithdral_60__0 is DuringStaking3_WithoutWithdral(PERCENT_60, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_60__20 is DuringStaking3_WithoutWithdral(PERCENT_60, PERCENT_20) { }

contract DuringStaking3_WithoutWithdral_66__0 is DuringStaking3_WithoutWithdral(PERCENT_66, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_66__30 is DuringStaking3_WithoutWithdral(PERCENT_66, PERCENT_30) { }

contract DuringStaking3_WithoutWithdral_70__0 is DuringStaking3_WithoutWithdral(PERCENT_70, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_70__10 is DuringStaking3_WithoutWithdral(PERCENT_70, PERCENT_10) { }

contract DuringStaking3_WithoutWithdral_80__0 is DuringStaking3_WithoutWithdral(PERCENT_80, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_80__70 is DuringStaking3_WithoutWithdral(PERCENT_80, PERCENT_70) { }

contract DuringStaking3_WithoutWithdral_90__0 is DuringStaking3_WithoutWithdral(PERCENT_90, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_90__50 is DuringStaking3_WithoutWithdral(PERCENT_90, PERCENT_50) { }

contract DuringStaking3_WithoutWithdral_99__0 is DuringStaking3_WithoutWithdral(PERCENT_99, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_99__33 is DuringStaking3_WithoutWithdral(PERCENT_99, PERCENT_33) { }

contract DuringStaking3_WithoutWithdral_100__0 is DuringStaking3_WithoutWithdral(PERCENT_100, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_100__30 is DuringStaking3_WithoutWithdral(PERCENT_100, PERCENT_30) { }

contract DuringStaking3_WithoutWithdral_101__0 is DuringStaking3_WithoutWithdral(PERCENT_101, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_101__50 is DuringStaking3_WithoutWithdral(PERCENT_101, PERCENT_50) { }

contract DuringStaking3_WithoutWithdral_110__0 is DuringStaking3_WithoutWithdral(PERCENT_110, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_110__60 is DuringStaking3_WithoutWithdral(PERCENT_110, PERCENT_60) { }

contract DuringStaking3_WithoutWithdral_150__0 is DuringStaking3_WithoutWithdral(PERCENT_150, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_150__70 is DuringStaking3_WithoutWithdral(PERCENT_150, PERCENT_70) { }

contract DuringStaking3_WithoutWithdral_190__0 is DuringStaking3_WithoutWithdral(PERCENT_190, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_190__80 is DuringStaking3_WithoutWithdral(PERCENT_190, PERCENT_80) { }

contract DuringStaking3_WithoutWithdral_200__0 is DuringStaking3_WithoutWithdral(PERCENT_200, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_200__90 is DuringStaking3_WithoutWithdral(PERCENT_200, PERCENT_90) { }

contract DuringStaking3_WithoutWithdral_201__0 is DuringStaking3_WithoutWithdral(PERCENT_201, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_201__90 is DuringStaking3_WithoutWithdral(PERCENT_201, PERCENT_90) { }

contract DuringStaking3_WithoutWithdral_220__0 is DuringStaking3_WithoutWithdral(PERCENT_220, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_220__99 is DuringStaking3_WithoutWithdral(PERCENT_220, PERCENT_99) { }
// */
// ------------------------------------
