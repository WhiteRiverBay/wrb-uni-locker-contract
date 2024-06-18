// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./IUniLocker.sol";
import "./AbstractUniLocker.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract UniLockerV3LP is AbstractUniLocker {
    constructor() AbstractUniLocker("UniLockerV3LP", "UL-V3LP", msg.sender) {}

    function claimProfit(uint256 _id) external override {
        // calcuate profit from the lp token
        LockItem storage item = lockItems[_id];

        // calculate profit
        (uint256 profit0, uint256 profit1) = _calcProfit(item.lpToken, item.amountOrId);
        
    }

    function _calcProfit(address lpToken, uint256 amountOrId) internal view returns (uint256, uint256) {
        // calculate profit
        return (0, 0);
    }

    function _transferLP(
        address lpToken,
        address to,
        uint256 amountOrId
    ) internal virtual override {
        IERC721(lpToken).safeTransferFrom(msg.sender, to, amountOrId);
    }

}
