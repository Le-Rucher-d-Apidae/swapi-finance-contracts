// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts@5.0.2/access/Ownable.sol";

import { RecoverERC20 } from "./recover/RecoverERC20.sol";

/**
 * @title TokenRecover
 * @dev Allows the contract owner to recover any ERC20 or ERC721 token sent into the contract and send them to a
 * receiver.
 */
abstract contract TokenRecover is Ownable, RecoverERC20 {
  /**
   * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
   */
  constructor(address initialOwner) Ownable(initialOwner) { }

  /**
   * @dev Recovers a `tokenAmount` of the ERC20 `tokenAddress` locked into this contract
   * and sends them to the `tokenReceiver` address.
   *
   * NOTE: restricting access to owner only. See `RecoverERC20::_recoverERC20`.
   *
   * @param tokenAddress The contract address of the token to recover.
   * @param tokenReceiver The address that will receive the recovered tokens.
   * @param tokenAmount Number of tokens to be recovered.
   */
  function recoverERC20(address tokenAddress, address tokenReceiver, uint256 tokenAmount) public virtual onlyOwner {
    _recoverERC20(tokenAddress, tokenReceiver, tokenAmount);
  }
}
