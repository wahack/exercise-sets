const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const chai = require("chai");
const hre = require("hardhat");
const {parseEther, toBigInt} = require("ethers");
// const chaiThings = require('chai-things');
// chai.use(chaiThings);

describe("TokenBank", function () {

  async function deployOneYearLockFixture() {
    const [owner, otherSigners] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Token", owner);
    const bigBankToken = await Token.deploy('BigBank', 'BB', 10, 1000000);

    const TokenBank = await ethers.getContractFactory("TokenBank", owner);
    const tokenBank = await TokenBank.deploy(bigBankToken.target);
    return {tokenBank, bigBankToken, owner, otherSigners};
  }

  describe("deploy a erc20 token", function () {
    const ONE_ETH = parseEther('1')
    const ONE_GWEI = 1_000_000_000; 
    // it("Token测试, 可存可授权可取", async function () {
    //   const {tokenBank, bigBankToken, owner, otherSigners} = await loadFixture(deployOneYearLockFixture);
    //   await bigBankToken.transfer(otherSigners.address, 1000);
    //   await chai.expect(bigBankToken.transferFrom(otherSigners.address, owner.address, 1000)).to.be.revertedWith(
    //     "Not enough allowance"
    //   );
    //   await bigBankToken.connect(otherSigners).approve(owner.address, 1000);
    //   await chai.expect(bigBankToken.transferFrom(otherSigners.address, owner.address, 1000)).not.to.be.reverted;
    // })

    it("TokenBank 测试，可存可转移token", async function () {
      const {tokenBank, bigBankToken, owner, otherSigners} = await loadFixture(deployOneYearLockFixture);
      await bigBankToken.transfer(otherSigners.address, 10000);
      bigBankToken.connect(otherSigners).approve(tokenBank.target, 10000);
      await tokenBank.connect(otherSigners).deposite(1000);
      await chai.expect(await bigBankToken.balanceOf(tokenBank.target)).to.be.equal(toBigInt(1000));
      await tokenBank.connect(owner).withdraw(1000);
      await chai.expect(await bigBankToken.balanceOf(tokenBank.target)).to.be.equal(toBigInt(0));
    })


  });
});
