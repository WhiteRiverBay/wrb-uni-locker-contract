// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./IUniLocker.sol";
import "./AbstractUniLocker.sol";
// IERC20
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// SafeERC20
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UniLockerV2LP is AbstractUniLocker {

    using SafeERC20 for IERC20;

    constructor() AbstractUniLocker("UniLockerV2LP", "UL-V2LP", msg.sender) {}

    function claimProfit(uint256 _id) external override {
        
    }

    function _transferLP(
        address lpToken,
        address to,
        uint256 amountOrId
    ) internal virtual override {
        IERC20(lpToken).safeTransferFrom(msg.sender, to, amountOrId);
    }
}