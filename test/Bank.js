const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const chai = require("chai");
const hre = require("hardhat");
// const chaiThings = require('chai-things');
// chai.use(chaiThings);

describe("Bank", function () {

  async function deployOneYearLockFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const Bank = await ethers.getContractFactory("Bank2");
    const bank = await Bank.deploy();

    return { bank, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { bank, owner } = await loadFixture(deployOneYearLockFixture);

      chai.expect(await bank.owner()).to.equal(owner.address);
    });

    // it("Should receive and store the funds to lock", async function () {
    //   const { lock, lockedAmount } = await loadFixture(
    //     deployOneYearLockFixture
    //   );

    //   chai.expect(await ethers.provider.getBalance(lock.target)).to.equal(
    //     lockedAmount
    //   );
    // });

    // it("Should fail if the unlockTime is not in the future", async function () {
    //   // We don't use the fixture here because we want a different deployment
    //   const latestTime = await time.latest();
    //   const Lock = await ethers.getContractFactory("Lock");
    //   await chai.expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
    //     "Unlock time should be in the future"
    //   );
    // });
  });

  describe("Receive", function () {
    const ONE_GWEI = 1_000_000_000;
    describe("小于3位发送人", function () {
      it("无重复情况", async function () {
        const { bank } = await loadFixture(deployOneYearLockFixture);
        const signers = await ethers.getSigners();
        await signers[0].sendTransaction({
          to: bank.target,
          value: ONE_GWEI
        });
        await signers[1].sendTransaction({
          to: bank.target,
          value: ONE_GWEI
        });
        await chai.expect(await bank.getTopThree()).to.deep.equals([
          signers[0].address,
          signers[1].address,
        ]);
      });
      it("有重复", async function () {
        const { bank } = await loadFixture(deployOneYearLockFixture);
        const signers = await ethers.getSigners();
        await signers[1].sendTransaction({
          to: bank.target,
          value: ONE_GWEI
        });
        await signers[1].sendTransaction({
          to: bank.target,
          value: ONE_GWEI
        });
        await chai.expect(await bank.getTopThree()).to.deep.equals([signers[1].address]);
      });
    });

    describe("大于3位发送人", function () {
      it("无重复情况", async function () {
        const { bank } = await loadFixture(deployOneYearLockFixture);
        const signers = await ethers.getSigners();
        await signers[1].sendTransaction({
          to: bank.target,
          value: ONE_GWEI
        });
        await signers[2].sendTransaction({
          to: bank.target,
          value: ONE_GWEI * 2
        });
        await signers[3].sendTransaction({
          to: bank.target,
          value: ONE_GWEI * 3
        });
        await signers[4].sendTransaction({
          to: bank.target,
          value: ONE_GWEI * 4
        });
        await signers[5].sendTransaction({
          to: bank.target,
          value: ONE_GWEI
        });
        let topThree = await bank.getTopThree()
         chai.expect([].concat(topThree).sort()).to.deep.equals([
          signers[2].address,
          signers[3].address,
          signers[4].address,
        ].sort());
      });
      it("有重复", async function () {
        const { bank } = await loadFixture(deployOneYearLockFixture);
        const signers = await ethers.getSigners();
        await signers[1].sendTransaction({
          to: bank.target,
          value: ONE_GWEI
        });
        await signers[2].sendTransaction({
          to: bank.target,
          value: ONE_GWEI * 2
        });
        await signers[3].sendTransaction({
          to: bank.target,
          value: ONE_GWEI * 3
        });
        await signers[4].sendTransaction({
          to: bank.target,
          value: ONE_GWEI * 4
        });
        await signers[1].sendTransaction({
          to: bank.target,
          value: ONE_GWEI * 5
        });
        await signers[2].sendTransaction({
          to: bank.target,
          value: ONE_GWEI * 5
        });
        let topThree = await bank.getTopThree()
        chai.expect([].concat(topThree).sort()).to.deep.equals([
          signers[1].address,
          signers[2].address,
          signers[4].address,
        ].sort());
      });
    });
  });
});
