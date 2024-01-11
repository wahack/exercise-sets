const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const chai = require("chai");
const hre = require("hardhat");
const {parseEther} = require("ethers");
// const chaiThings = require('chai-things');
// chai.use(chaiThings);

describe("Owner And BigBank", function () {

  async function deployOneYearLockFixture() {
    const signers = await ethers.getSigners();
    const BigBankDeployer = signers[0];
    const OwnableDeployer = signers[1];

    const BigBank = await ethers.getContractFactory("BigBank", BigBankDeployer);
    const bigBank = await BigBank.deploy();

    const Ownable = await ethers.getContractFactory("Ownable", OwnableDeployer);
    const ownable = await Ownable.deploy(bigBank.target);
    return {bigBank, ownable, BigBankDeployer, OwnableDeployer};
  }

  describe("run test", function () {
    const ONE_ETH = parseEther('1')
    const ONE_GWEI = 1_000_000_000; 
    it("minAmount", async function () {
      const { ownable, bigBank, BigBankDeployer, OwnableDeployer } = await loadFixture(deployOneYearLockFixture);
      
      await chai.expect(bigBank.deposite(ONE_GWEI)).to.be.revertedWith(
        "Not enough ETH sent"
      );
    })
    it("transfer ownership", async function () {
      const { ownable, bigBank, BigBankDeployer, OwnableDeployer } = await loadFixture(deployOneYearLockFixture);
      await bigBank.deposite(parseEther('10'));
      await chai.expect(ownable.withdraw(parseEther('0.2'))).to.be.revertedWith(
        "Not the owner"
      );
      await chai.expect(bigBank.withdraw(parseEther('0.01'))).to.be.reverted;
      await bigBank.transferOwner(OwnableDeployer.address);
      await chai.expect(bigBank.withdraw(parseEther('0.1'))).to.be.revertedWith(
        "Not the owner"
      );
      await chai.expect(ownable.withdraw(parseEther('0.2'))).not.to.be.reverted;
    });

  });
});
