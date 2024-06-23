// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UniLockerV3LP} from "../src/UniLockerV3LP.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockLP is ERC721 {
    constructor() ERC721("MockLP", "MLP") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

contract UniLockerV3LPTest is Test {
    UniLockerV3LP public locker;
    MockLP public lp;

    function setUp() public {
        lp = new MockLP();
        // assume 100 is the feeTo address
        locker = new UniLockerV3LP(address(100), 900, address(lp));
    }

    function test_lock() public {
        lp.mint(address(this), 1);
        // approve
        lp.approve(address(locker), 1);
        uint id = locker.lock(address(lp), 1, block.number + 100);

        // check the owner of the lp token
        assertEq(lp.ownerOf(1), address(locker), "owner of lp token should be locker");

        // check the lock item
        (address lpToken, uint256 amountOrId, uint256 unlockBlock) = locker.lockItems(0);
        assertEq(lpToken, address(lp), "lp token should be lp");
        assertEq(amountOrId, 1, "amountOrId should be 1");
        assertEq(unlockBlock, block.number + 100, "unlockBlock should be block.number + 100");
        
        // check the owner of the locker
        assertEq(locker.ownerOf(id), address(this), "owner of locker should be this");
    }

    function testFail_selfUnlockWhileLocked() public {
        lp.mint(address(this), 1);
        uint id = locker.lock(address(lp), 1, block.number + 100);

        vm.expectRevert("UniLocker: still locked");
        locker.unlock(id);
    }

    function testFail_otherUnlockWhileLocked() public {
        lp.mint(address(this), 1);
        uint id = locker.lock(address(lp), 1, block.number + 100);

        vm.prank(address(1), address(1));
        vm.expectRevert("UniLocker: still locked");
        locker.unlock(id);
    }

    function testFail_otherUnlockAfterExpired() public {
        lp.mint(address(this), 1);
        uint id = locker.lock(address(lp), 1, block.number + 100);
        // block
        vm.roll(block.number + 101);
        vm.prank(address(1), address(1));
        vm.expectRevert("UniLocker: not the LP owner");
        locker.unlock(id);
    }

    function test_unlock() public {
        lp.mint(address(this), 1);
        // approve
        lp.approve(address(locker), 1);
        uint id = locker.lock(address(lp), 1, block.number + 100);
        
        // block
        vm.roll(block.number + 101);
        locker.unlock(id);

        // check the owner of the lp token
        assertEq(lp.ownerOf(1), address(this), "owner of lp token should be this");

        // check the lock item
        (address lpToken, uint256 amountOrId, uint256 unlockBlock) = locker.lockItems(0);
        assertEq(lpToken, address(0), "lp token should be 0");
        assertEq(amountOrId, 0, "amountOrId should be 0");
        assertEq(unlockBlock, 0, "unlockBlock should be 0");
        
        // check the owner of the locker
        // vm.expectRevert("ERC721: owner query for nonexistent token");
        // locker.ownerOf(id);
    }

    function testFail_getTokenAfterUnlock() public {
        lp.mint(address(this), 1);
        // approve
        lp.approve(address(locker), 1);
        uint id = locker.lock(address(lp), 1, block.number + 100);
        
        // block
        vm.roll(block.number + 101);
        locker.unlock(id);

        // check the owner of the lp token
        assertEq(lp.ownerOf(1), address(this), "owner of lp token should be this");

        // check the lock item
        (address lpToken, uint256 amountOrId, uint256 unlockBlock) = locker.lockItems(0);
        assertEq(lpToken, address(0), "lp token should be 0");
        assertEq(amountOrId, 0, "amountOrId should be 0");
        assertEq(unlockBlock, 0, "unlockBlock should be 0");
        
        // check the owner of the locker
        vm.expectRevert("ERC721: owner query for nonexistent token");
        locker.ownerOf(id);
    }

    // claim
    
}
