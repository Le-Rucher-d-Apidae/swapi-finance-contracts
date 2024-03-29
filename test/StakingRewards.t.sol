// SPDX-License-Identifier: UNLICENSED
// pragma solidity >= 0.8.20 < 0.9.0;
// pragma solidity ^0.8.23;
// pragma solidity >= 0.8.20;
// pragma solidity ^0.7.6;
// pragma solidity >= 0.7.6 <= 0.8.0;
// pragma solidity >= 0.7.6;
pragma solidity <=0.8.0;
// incompatibility between solidity pragmas: test/ds-test/test.sol pragma solidity >=0.8.0;

import { console } from "forge-std/src/console.sol";
import { stdStorage, StdStorage, Test } from "forge-std/src/Test.sol";

import { Utils } from "./utils/Utils.sol";

import { StakingRewards } from "../src/contracts/StakingRewards.sol";
// import { IERC20Errors } from "@openzeppelin/contracts@5.0.2/interfaces/draft-IERC6093.sol";

contract UsersSetup is Test {

    function setUp() public virtual {
        console.log("TODO");
}

