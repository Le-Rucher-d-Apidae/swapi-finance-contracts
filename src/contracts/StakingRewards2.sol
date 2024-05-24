// SPDX-License-Identifier: GPL-3.0-or-later

// pragma solidity ^0.8.23;
pragma solidity >=0.8.20 < 0.9.0;

/* solhint-disable max-states-count */
/* warning  Contract has 18 states declarations */

import { IERC20, SafeERC20 } from "@openzeppelin/contracts@5.0.2/token/ERC20/utils/SafeERC20.sol";
import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";
import { Ownable } from "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts@5.0.2/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts@5.0.2/utils/ReentrancyGuard.sol";

import {
    RewardPeriodInProgress,
    CantWithdrawStakingToken,
    ProvidedRewardTooHigh,
    RewardTokenZeroAddress,
    StakingTokenZeroAddress,
    StakeZero,
    WithdrawZero,
    CompoundDifferentTokens,
    NotEnoughToWithdraw,
    NothingToWithdraw,
    ProvidedVariableRewardTooHigh,
    StakeTotalSupplyExceedsAllowedMax,
    CompounedTotalSupplyExceedsAllowedMax,
    NotVariableRewardRate,
    UpdateVariableRewardMaxTotalSupply
} from "./StakingRewards2Errors.sol";
import { StakingRewards2Events } from "./StakingRewards2Events.sol";

import { IUniswapV2ERC20 } from "./Uniswap/v2-core/interfaces/IUniswapV2ERC20.sol";

// https://docs.synthetix.io/contracts/source/contracts/stakingrewards
contract StakingRewards2 is ReentrancyGuard, Ownable(msg.sender), Pausable, StakingRewards2Events {
    uint256 internal constant ONE_TOKEN = 1e18;

    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 1 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address user => uint256 amount) public userRewardPerTokenPaid;
    mapping(address user => uint256 amount) public rewards;

    uint256 private _totalSupply;
    mapping(address user => uint256 balance) private _balances;

    /* ========== Variable Reward Rate ========== */
    bool public isVariableRewardRate = false;
    bool public isConstantRewardRatePerTokenStored = false;
    uint256 public firstRewardTime;
    // uint256 public variableRewardRate = 0;
    uint256 public constantRewardRatePerTokenStored;
    uint256 public variableRewardMaxTotalSupply;
    // Naïve implementation for rewards computation: lastUpdateTime user map, updated every time a user interacts
    // with the contract
    mapping(address user => uint256 timeStamp) public userLastUpdateTime;

    // Pausable
    uint256 public lastPauseTime;
    uint256 public lastUnpauseTime;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _rewardsToken, address _stakingToken) {
        if (_rewardsToken == address(0)) revert RewardTokenZeroAddress();
        if (_stakingToken == address(0)) revert StakingTokenZeroAddress();
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (isVariableRewardRate) {
            return constantRewardRatePerTokenStored;
        }
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored
            + ((lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * ONE_TOKEN / _totalSupply);
    }

    function getUserLastUpdateTime(address account) internal view returns (uint256) {
        if (isVariableRewardRate) {
            if (userLastUpdateTime[account] == 0) {
                return firstRewardTime; // In case of deposit before first reward time
            }
            return userLastUpdateTime[account];
        }
        return lastUpdateTime; // should never be returned
    }

    function earned(address account) public view returns (uint256) {
        if (isVariableRewardRate) {
            return _balances[account] * constantRewardRatePerTokenStored
                * (lastTimeRewardApplicable() - getUserLastUpdateTime(account)) / ONE_TOKEN + rewards[account];
        }
        return
            _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / ONE_TOKEN + rewards[account];
    }

    function getRewardForDuration() external view returns (uint256) {
        if (isVariableRewardRate) {
            // Current MAX possible reward for duration
            return constantRewardRatePerTokenStored * variableRewardMaxTotalSupply * rewardsDuration / ONE_TOKEN;
        }
        return rewardRate * rewardsDuration;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount)
        external
        nonReentrant
        whenNotPaused
        updateReward(msg.sender)
        _stake(amount, msg.sender)
        stake_(amount, msg.sender)
    /* solhint-disable-next-line no-empty-blocks */
    { }

    function stakeWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        nonReentrant
        whenNotPaused
        updateReward(msg.sender)
        _stake(amount, msg.sender)
        stake_(amount, msg.sender)
    {
        // permit
        IUniswapV2ERC20(address(stakingToken)).permit(msg.sender, address(this), amount, deadline, v, r, s);
    }

    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {
        if (amount == 0) revert WithdrawZero();
        if (_balances[msg.sender] == 0) revert NothingToWithdraw();
        if (amount > _balances[msg.sender]) {
            revert NotEnoughToWithdraw({ amountToWithdraw: amount, currentBalance: _balances[msg.sender] });
        }

        _totalSupply = _totalSupply - amount;
        _balances[msg.sender] = _balances[msg.sender] - amount;
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function compoundReward() public nonReentrant updateReward(msg.sender) {
        if (stakingToken != rewardsToken) revert CompoundDifferentTokens();
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            _totalSupply = _totalSupply + reward;
            _balances[msg.sender] = _balances[msg.sender] + reward;
            rewards[msg.sender] = 0;
            emit Staked(msg.sender, reward);
        }
        // total supply updated
        if (isVariableRewardRate) {
            // Prevents compounding if total supply exceeds max
            if (_totalSupply > variableRewardMaxTotalSupply) {
                revert CompounedTotalSupplyExceedsAllowedMax({
                    newTotalSupply: _totalSupply,
                    variableRewardMaxTotalSupply: variableRewardMaxTotalSupply
                });
            }
        }
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    /*
     * @dev Notify a new reward amount for the current reward period.
     * Can only be called by the owner.
     * @param _constantRewardRatePerTokenStored The amount of reward token to be distributed.
     * @param _variableRewardMaxTotalSupply The max amount of token deposited in the contract.
     * @notice _variableRewardMaxTotalSupply is the LP amount count * 10^18 unit.
     *         e.g. if max LP is 10, 10 * 10^18 must be provided
     */
    function notifyVariableRewardAmount(
        uint256 _constantRewardRatePerTokenStored,
        uint256 _variableRewardMaxTotalSupply
    )
        external
        onlyOwner
    {
        isVariableRewardRate = true;
        constantRewardRatePerTokenStored = _constantRewardRatePerTokenStored;
        variableRewardMaxTotalSupply = _variableRewardMaxTotalSupply; // Set max LP cap ; if 0, no cap

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        // Substract total supply if staking token is the same as rewards token
        if (stakingToken == rewardsToken) {
            balance = balance - _totalSupply;
        }
        if (variableRewardMaxTotalSupply * _constantRewardRatePerTokenStored * rewardsDuration > balance * ONE_TOKEN)
        {
            revert ProvidedVariableRewardTooHigh({
                constantRewardPerTokenStored: constantRewardRatePerTokenStored,
                variableRewardMaxTotalSupply: variableRewardMaxTotalSupply,
                // minRewardBalance: returns 1e18 too much, should be :
                // minRewardBalance: variableRewardMaxTotalSupply * _constantRewardRatePerTokenStored *
                //                   rewardsDuration / ONE_TOKEN,
                // keeping it as is for accurracy : dividing by ONE_TOKEN will return 0 if the result is < 1e18
                minRewardBalance: variableRewardMaxTotalSupply * _constantRewardRatePerTokenStored * rewardsDuration,
                currentRewardBalance: balance
            });
        }
        // Guard: in case already existing deposits exceed max. cap
        if (_totalSupply > variableRewardMaxTotalSupply) {
            revert StakeTotalSupplyExceedsAllowedMax({
                newTotalSupply: _totalSupply,
                variableRewardMaxTotalSupply: _variableRewardMaxTotalSupply,
                depositAmount: 0,
                currentTotalSupply: _totalSupply
            });
        }

        emit MaxTotalSupply(variableRewardMaxTotalSupply);

        firstRewardTime = block.timestamp;
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
        emit RewardAddedPerTokenStored(constantRewardRatePerTokenStored);
    }

    function updateVariableRewardMaxTotalSupply(uint256 _variableRewardMaxTotalSupply) external onlyOwner {
        if (!isVariableRewardRate) revert NotVariableRewardRate();
        variableRewardMaxTotalSupply = _variableRewardMaxTotalSupply; // Set max LP cap ; if 0, no cap
        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        // Substract total supply if staking token is the same as rewards token
        if (stakingToken == rewardsToken) {
            balance = balance - _totalSupply;
        }
        if (variableRewardMaxTotalSupply * constantRewardRatePerTokenStored > balance / rewardsDuration) {
            revert UpdateVariableRewardMaxTotalSupply({
                variableRewardMaxTotalSupply: variableRewardMaxTotalSupply,
                rewardsBalance: balance
            });
        }
        emit MaxTotalSupply(variableRewardMaxTotalSupply);
        lastUpdateTime = block.timestamp; // not useful for rewards computations
    }

    function notifyRewardAmount(uint256 reward) external onlyOwner updateReward(address(0)) {
        isVariableRewardRate = false;

        if (block.timestamp >= periodFinish) {
            rewardRate = reward / rewardsDuration;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / rewardsDuration;
        }
        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        // Substract total supply if staking token is the same as rewards token
        if (stakingToken == rewardsToken) {
            balance = balance - _totalSupply;
        }
        if (rewardRate > balance / rewardsDuration) {
            revert ProvidedRewardTooHigh({ reward: reward, rewardBalance: balance, rewardsDuration: rewardsDuration });
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
        emit RewardAdded(reward);
    }

    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        if (tokenAddress == address(stakingToken)) revert CantWithdrawStakingToken();
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        if (block.timestamp <= periodFinish) {
            revert RewardPeriodInProgress({ currentTimestamp: block.timestamp, periodFinish: periodFinish });
        }
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        if (isVariableRewardRate) {
            // Update variable reward rate
            lastUpdateTime = lastTimeRewardApplicable(); // not useful for rewards computations when variable reward
            if (account != address(0)) {
                rewards[account] = earned(account);
                userLastUpdateTime[account] = lastUpdateTime;
            }
            // rate
        } else {
            rewardPerTokenStored = rewardPerToken();
            lastUpdateTime = lastTimeRewardApplicable();
            if (account != address(0)) {
                rewards[account] = earned(account);
                userRewardPerTokenPaid[account] = rewardPerTokenStored;
            }
        }
        _;
    }

    modifier _stake(uint256 amount, address account) {
        if (amount == 0) revert StakeZero();
        _totalSupply = _totalSupply + amount;
        if (isVariableRewardRate) {
            if (_totalSupply > variableRewardMaxTotalSupply) {
                revert StakeTotalSupplyExceedsAllowedMax({
                    newTotalSupply: _totalSupply,
                    variableRewardMaxTotalSupply: variableRewardMaxTotalSupply,
                    depositAmount: amount,
                    currentTotalSupply: _totalSupply - amount
                });
            }
        }
        _balances[account] = _balances[account] + amount;
        _;
    }

    modifier stake_(uint256 amount, address account) {
        _;
        stakingToken.safeTransferFrom(account, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    /* ========== PAUSABLE ========== */

    function setPaused(bool _paused) external onlyOwner {
        // Ensure we're actually changing the state before we do anything
        if (_paused == paused()) {
            return;
        }
        // Set our paused state.
        if (_paused) {
            lastPauseTime = block.timestamp;
            _pause();
        } else {
            lastUnpauseTime = block.timestamp;
            _unpause();
        }
        // Let everyone know that our pause state has changed.
        // Events Paused/Unpaused emmited by _pause()/_un_pause()
    }
}
/* solhint-enable max-states-count */
