// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import {
    DuringStakingVariableRewardRate1WithoutWithdral,
    DuringStakingVariableRewardRate2WithoutWithdral,
    DuringStakingVariableRewardRate3WithoutWithdral
} from "./StakingRewards2_VariableRewardRate_setups.t.sol";

import {
    PERCENT_0,
    PERCENT_0_1,
    PERCENT_1,
    PERCENT_5,
    PERCENT_10,
    PERCENT_20,
    PERCENT_30,
    PERCENT_33,
    PERCENT_40,
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

/* solhint-disable no-empty-blocks */
/* solhint-disable contract-name-camelcase */

// ----------------------------------------------------------------------------

// 1 staker deposits right after staking starts and keeps staked amount until the end of staking period
// 42+ tests

// /*

contract DuringStakingConstantReward1_WithoutWithdral_0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_0, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_1_0_1 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_1, PERCENT_0_1)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_10__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_10, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_10__5 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_10, PERCENT_5)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_20__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_20, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_20__10 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_20, PERCENT_10)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_30__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_30, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_30__20 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_30, PERCENT_20)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_33__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_33, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_33__10 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_33, PERCENT_10)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_40__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_40, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_40__5 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_40, PERCENT_5)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_50__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_50, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_50__5 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_50, PERCENT_5)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_60__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_60, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_60__20 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_60, PERCENT_20)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_66__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_66, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_66__30 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_66, PERCENT_30)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_70__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_70, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_70__10 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_70, PERCENT_10)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_80__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_80, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_80__70 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_80, PERCENT_70)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_90__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_90, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_90__50 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_90, PERCENT_50)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_99__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_99, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_99__33 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_99, PERCENT_33)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_100__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_100, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_100__30 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_100, PERCENT_30)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_100__50 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_100, PERCENT_50)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_101__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_101, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_101__50 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_101, PERCENT_50)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_110__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_110, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_110__60 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_110, PERCENT_60)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_150__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_150, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_150__70 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_150, PERCENT_70)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_190__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_190, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_190__80 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_190, PERCENT_80)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_200__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_200, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_200__90 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_200, PERCENT_90)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_201__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_201, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_201__90 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_201, PERCENT_90)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_220__0 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_220, PERCENT_0)
{ }

contract DuringStakingConstantReward1_WithoutWithdral_220__99 is
    DuringStakingVariableRewardRate1WithoutWithdral(PERCENT_220, PERCENT_99)
{ }

// */

// ------------------------------------

// 2 stakers deposit right after staking starts and keep staked amount until the end of staking period
// 42+ tests

// /*

contract DuringStakingConstantReward2_WithoutWithdral_0__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_0, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_1__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_1, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_1__0_1 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_1, PERCENT_0_1)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_10__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_10, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_10__5 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_10, PERCENT_5)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_20__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_20, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_20__10 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_20, PERCENT_10)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_30__ is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_30, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_30__20 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_30, PERCENT_20)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_33__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_33, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_33__10 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_33, PERCENT_10)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_40__ is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_40, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_40__5 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_40, PERCENT_5)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_50__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_50, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_50__5 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_50, PERCENT_5)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_60__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_60, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_60__20 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_60, PERCENT_20)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_66__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_66, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_66__30 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_66, PERCENT_30)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_70__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_70, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_70__10 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_70, PERCENT_10)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_80__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_80, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_80__70 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_80, PERCENT_70)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_90__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_90, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_90__50 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_90, PERCENT_50)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_99__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_99, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_99__33 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_99, PERCENT_33)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_100__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_100, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_100__30 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_100, PERCENT_30)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_100__50 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_100, PERCENT_50)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_101__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_101, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_101__50 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_101, PERCENT_50)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_110__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_110, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_110__60 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_110, PERCENT_60)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_150__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_150, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_150__50 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_150, PERCENT_50)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_150__70 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_150, PERCENT_70)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_190__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_190, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_190__80 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_190, PERCENT_80)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_200__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_200, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_200__90 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_200, PERCENT_90)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_201__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_201, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_201__90 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_201, PERCENT_90)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_220__0 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_220, PERCENT_0)
{ }

contract DuringStakingConstantReward2_WithoutWithdral_220__99 is
    DuringStakingVariableRewardRate2WithoutWithdral(PERCENT_220, PERCENT_99)
{ }

// */

// ------------------------------------

// 3 stakers deposit right after staking starts and keep staked amount until the end of staking period
// 42+ tests

// /*

contract DuringStakingConstantReward3_WithoutWithdral_0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_0, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_1_0_1 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_1, PERCENT_0_1)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_10__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_10, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_10__5 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_10, PERCENT_5)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_20__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_20, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_20__10 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_20, PERCENT_10)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_30__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_30, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_30__20 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_30, PERCENT_20)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_33__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_33, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_33__10 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_33, PERCENT_10)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_40__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_40, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_40__5 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_40, PERCENT_5)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_50__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_50, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_50__5 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_50, PERCENT_5)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_60__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_60, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_60__20 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_60, PERCENT_20)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_66__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_66, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_66__30 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_66, PERCENT_30)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_70__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_70, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_70__10 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_70, PERCENT_10)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_80__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_80, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_80__70 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_80, PERCENT_70)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_90__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_90, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_90__50 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_90, PERCENT_50)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_99__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_99, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_99__33 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_99, PERCENT_33)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_100__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_100, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_100__30 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_100, PERCENT_30)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_100__50 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_100, PERCENT_50)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_101__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_101, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_101__50 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_101, PERCENT_50)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_110__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_110, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_110__60 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_110, PERCENT_60)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_150__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_150, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_150__70 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_150, PERCENT_70)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_190__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_190, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_190__80 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_190, PERCENT_80)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_200__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_200, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_200__90 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_200, PERCENT_90)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_201__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_201, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_201__90 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_201, PERCENT_90)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_220__0 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_220, PERCENT_0)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_220__99 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_220, PERCENT_99)
{ }

contract DuringStakingConstantReward3_WithoutWithdral_220__100 is
    DuringStakingVariableRewardRate3WithoutWithdral(PERCENT_220, PERCENT_100)
{ }

// */

// ----------------------------------------------------------------------------

/* solhint-enable no-empty-blocks */
/* solhint-enable contract-name-camelcase */
