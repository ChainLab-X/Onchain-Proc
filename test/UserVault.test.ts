import { expect } from "chai";
import { ethers } from "hardhat";
import type { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import type { MockERC20 } from "../typechain-types/contracts/mocks/MockERC20";
import type { UserVault } from "../typechain-types/contracts/UserVault";

describe("UserVault — Core ERC-4626", function () {
  let owner: HardhatEthersSigner;
  let user1: HardhatEthersSigner;
  let user2: HardhatEthersSigner;

  let asset: MockERC20;
  let vault: UserVault;

  const NAME = "Vault Share";
  const SYMBOL = "VSHR";
  const DECIMALS = 18;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    // Deploy underlying asset (ERC20)
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    asset = (await MockERC20.deploy("Mock Token", "MOCK", DECIMALS)) as unknown as MockERC20;
    await asset.waitForDeployment();

    // Deploy UserVault with the underlying asset
    const UserVault = await ethers.getContractFactory("UserVault");
    vault = (await UserVault.deploy(
      await asset.getAddress(),
      NAME,
      SYMBOL,
      owner.address
    )) as unknown as UserVault;
    await vault.waitForDeployment();
  });

  describe("Initialization", function () {
    it("sets ERC20 share metadata and decimals equal to underlying", async function () {
      expect(await vault.name()).to.equal(NAME);
      expect(await vault.symbol()).to.equal(SYMBOL);
      expect(await vault.decimals()).to.equal(DECIMALS);
    });

    it("exposes correct asset and starts with zero totalAssets", async function () {
      expect(await vault.asset()).to.equal(await asset.getAddress());
      expect(await vault.totalAssets()).to.equal(0n);
    });

    it("depositLimit is unlimited by default", async function () {
      const max = await vault.maxDeposit(owner.address);
      expect(max).to.equal(ethers.MaxUint256);
    });
  });

  describe("Deposit and Mint", function () {
    it("first deposit mints shares 1:1 with assets", async function () {
      const amount = ethers.parseEther("100");
      await asset.mint(owner.address, amount);
      await asset.approve(await vault.getAddress(), amount);

      const previewShares = await vault.previewDeposit(amount);
      expect(previewShares).to.equal(amount);

      await expect(vault.deposit(amount, owner.address))
        .to.emit(vault, "Deposit")
        .withArgs(owner.address, owner.address, amount, amount);

      expect(await vault.totalAssets()).to.equal(amount);
      expect(await vault.totalSupply()).to.equal(amount);
      expect(await vault.balanceOf(owner.address)).to.equal(amount);
    });

    it("subsequent deposit mints shares proportionally", async function () {
      const first = ethers.parseEther("100");
      const second = ethers.parseEther("50");

      // First depositor
      await asset.mint(owner.address, first);
      await asset.approve(await vault.getAddress(), first);
      await vault.deposit(first, owner.address);

      const supplyBefore = await vault.totalSupply();
      const assetsBefore = await vault.totalAssets();
      expect(supplyBefore).to.equal(first);
      expect(assetsBefore).to.equal(first);

      // Second depositor (user1)
      await asset.mint(user1.address, second);
      await asset.connect(user1).approve(await vault.getAddress(), second);

      const previewShares = await vault.previewDeposit(second);
      // With equal supply/assets, shares == assets for the second deposit
      expect(previewShares).to.equal(second);

      await expect(vault.connect(user1).deposit(second, user1.address))
        .to.emit(vault, "Deposit")
        .withArgs(user1.address, user1.address, second, previewShares);

      expect(await vault.totalAssets()).to.equal(first + second);
      expect(await vault.totalSupply()).to.equal(first + previewShares);
      expect(await vault.balanceOf(user1.address)).to.equal(previewShares);
    });

    it("mint calculates required assets (round up) and emits Deposit", async function () {
      const targetShares = ethers.parseEther("75");

      // Seed owner so they can mint
      const seed = ethers.parseEther("100"); // Allow first mint to be 1:1
      await asset.mint(owner.address, seed);
      await asset.approve(await vault.getAddress(), seed);

      // First mint behaves like 1:1
      const previewAssets = await vault.previewMint(targetShares);
      expect(previewAssets).to.equal(targetShares);

      await expect(vault.mint(targetShares, owner.address))
        .to.emit(vault, "Deposit")
        .withArgs(owner.address, owner.address, previewAssets, targetShares);

      expect(await vault.totalSupply()).to.equal(targetShares);
      expect(await vault.totalAssets()).to.equal(previewAssets);
    });

    it("reverts on zero-amount deposit/mint", async function () {
      await expect(vault.deposit(0, owner.address)).to.be.revertedWith("Zero assets");
      await expect(vault.mint(0, owner.address)).to.be.revertedWith("Zero shares");
    });

    it("reverts when receiver is zero address", async function () {
      const amount = ethers.parseEther("1");
      await asset.mint(owner.address, amount);
      await asset.approve(await vault.getAddress(), amount);

      await expect(vault.deposit(amount, ethers.ZeroAddress)).to.be.revertedWith("Receiver zero");

      // Need initial mint pre-approval; but this should fail before transfer
      await expect(vault.mint(amount, ethers.ZeroAddress)).to.be.revertedWith("Receiver zero");
    });
  });

  describe("Withdraw and Redeem", function () {
    beforeEach(async function () {
      const amount = ethers.parseEther("100");
      await asset.mint(owner.address, amount);
      await asset.approve(await vault.getAddress(), amount);
      await vault.deposit(amount, owner.address);
    });

    it("withdraw burns the correct previewed shares (round up) and emits Withdraw", async function () {
      const withdrawAssets = ethers.parseEther("40");
      const previewShares = await vault.previewWithdraw(withdrawAssets);

      const ownerSharesBefore = await vault.balanceOf(owner.address);
      const totalAssetsBefore = await vault.totalAssets();

      await expect(vault.withdraw(withdrawAssets, owner.address, owner.address))
        .to.emit(vault, "Withdraw")
        .withArgs(owner.address, owner.address, owner.address, withdrawAssets, previewShares);

      const ownerSharesAfter = await vault.balanceOf(owner.address);
      const totalAssetsAfter = await vault.totalAssets();

      expect(ownerSharesAfter).to.equal(ownerSharesBefore - previewShares);
      expect(totalAssetsAfter).to.equal(totalAssetsBefore - withdrawAssets);
    });

    it("redeem sends previewed assets (round down) and emits Withdraw", async function () {
      const redeemShares = ethers.parseEther("25");
      const previewAssets = await vault.previewRedeem(redeemShares);

      const userBalBefore = await asset.balanceOf(owner.address);
      const totalAssetsBefore = await vault.totalAssets();

      await expect(vault.redeem(redeemShares, owner.address, owner.address))
        .to.emit(vault, "Withdraw")
        .withArgs(owner.address, owner.address, owner.address, previewAssets, redeemShares);

      const userBalAfter = await asset.balanceOf(owner.address);
      const totalAssetsAfter = await vault.totalAssets();

      expect(userBalAfter - userBalBefore).to.equal(previewAssets);
      expect(totalAssetsBefore - totalAssetsAfter).to.equal(previewAssets);
    });

    it("requires allowance when msg.sender != owner for withdraw", async function () {
      const withdrawAssets = ethers.parseEther("10");
      // user1 attempts to withdraw owner's assets without approval
      await expect(
        vault.connect(user1).withdraw(withdrawAssets, user1.address, owner.address)
      )
        .to.be.revertedWithCustomError(vault, "ERC20InsufficientAllowance");

      // Now approve sufficient shares
      const sharesNeeded = await vault.previewWithdraw(withdrawAssets);
      await vault.approve(user1.address, sharesNeeded);

      await expect(
        vault.connect(user1).withdraw(withdrawAssets, user1.address, owner.address)
      )
        .to.emit(vault, "Withdraw")
        .withArgs(user1.address, user1.address, owner.address, withdrawAssets, sharesNeeded);
    });

    it("requires allowance when msg.sender != owner for redeem", async function () {
      const redeemShares = ethers.parseEther("5");
      // user1 attempts redeem without approval
      await expect(
        vault.connect(user1).redeem(redeemShares, user1.address, owner.address)
      )
        .to.be.revertedWithCustomError(vault, "ERC20InsufficientAllowance");

      // Approve then redeem
      await vault.approve(user1.address, redeemShares);
      const previewAssets = await vault.previewRedeem(redeemShares);

      await expect(
        vault.connect(user1).redeem(redeemShares, user1.address, owner.address)
      )
        .to.emit(vault, "Withdraw")
        .withArgs(user1.address, user1.address, owner.address, previewAssets, redeemShares);
    });

    it("reverts when receiver or owner is zero address", async function () {
      await expect(
        vault.withdraw(ethers.parseEther("1"), ethers.ZeroAddress, owner.address)
      ).to.be.revertedWith("Receiver zero");

      await expect(
        vault.withdraw(ethers.parseEther("1"), owner.address, ethers.ZeroAddress)
      ).to.be.revertedWith("Owner zero");

      await expect(
        vault.redeem(ethers.parseEther("1"), ethers.ZeroAddress, owner.address)
      ).to.be.revertedWith("Receiver zero");

      await expect(
        vault.redeem(ethers.parseEther("1"), owner.address, ethers.ZeroAddress)
      ).to.be.revertedWith("Owner zero");
    });
  });

  describe("Accounting and Rounding", function () {
    it("convertToShares and convertToAssets reflect 1:1 on first deposit", async function () {
      const amount = ethers.parseEther("100");
      await asset.mint(owner.address, amount);
      await asset.approve(await vault.getAddress(), amount);

      expect(await vault.convertToShares(amount)).to.equal(amount);
      await vault.deposit(amount, owner.address);

      // After deposit, same ratio as no yield has been earned
      expect(await vault.convertToShares(amount)).to.equal(amount);
      expect(await vault.convertToAssets(amount)).to.equal(amount);
    });

    it("preview functions round in safe directions when vault has extra assets", async function () {
      // Initial deposit 100 shares/assets
      const amount = ethers.parseEther("100");
      await asset.mint(owner.address, amount);
      await asset.approve(await vault.getAddress(), amount);
      await vault.deposit(amount, owner.address);

      // Simulate yield by minting 1 wei of asset directly to the vault
      await asset.mint(await vault.getAddress(), 1n);

      const supply = await vault.totalSupply(); // 100e18
      const total = await vault.totalAssets();  // 100e18 + 1

      // previewDeposit rounds down: with 1 wei deposit, shares may be 0
      expect(await vault.previewDeposit(1n)).to.equal(0n);

      // previewMint rounds up
      const assetsFor1Share = await vault.previewMint(1n);
      // supply/total = 100e18 / (100e18 + 1) < 1, so we need >= 2 wei assets for 1 share
      expect(assetsFor1Share).to.equal(2n);

      // previewWithdraw rounds up
      const sharesFor1Asset = await vault.previewWithdraw(1n);
      // ceil(1 * supply / total) should be 1 in this setup
      expect(sharesFor1Asset).to.equal(1n);

      // previewRedeem rounds down
      const assetsForRedeem1Share = await vault.previewRedeem(1n);
      // floor(1 * total / supply) should be 1
      // Just to be safe, assert bounds
      expect(assetsForRedeem1Share).to.be.greaterThanOrEqual(1n);
      expect(assetsForRedeem1Share).to.be.lessThanOrEqual(2n);

      // Sanity check on invariants
      expect(total).to.equal((await vault.totalAssets()));
      expect(supply).to.equal((await vault.totalSupply()));
    });
  });

  describe("Access Control and Limits", function () {
    it("only owner can set deposit limit", async function () {
      const currentAssets = await vault.totalAssets();
      const newLimit = currentAssets + ethers.parseEther("1000");

      await expect(vault.connect(user1).setDepositLimit(newLimit))
        .to.be.revertedWithCustomError(vault, "OwnableUnauthorizedAccount")
        .withArgs(user1.address);

      await expect(vault.setDepositLimit(newLimit))
        .to.emit(vault, "DepositLimitUpdated")
        .withArgs(ethers.MaxUint256, newLimit);

      expect(await vault.maxDeposit(owner.address)).to.equal(newLimit - currentAssets);
    });

    it("cannot set limit below current totalAssets", async function () {
      // Seed the vault
      const seed = ethers.parseEther("10");
      await asset.mint(owner.address, seed);
      await asset.approve(await vault.getAddress(), seed);
      await vault.deposit(seed, owner.address);

      // Attempt to set lower than current assets
      await expect(vault.setDepositLimit(seed - 1n)).to.be.revertedWith(
        "New limit below current assets"
      );
    });

    it("deposit and mint respect maxDeposit/maxMint", async function () {
      const limit = ethers.parseEther("50");
      await vault.setDepositLimit(limit);

      // Owner maxDeposit reflects limit
      expect(await vault.maxDeposit(owner.address)).to.equal(limit);

      // Try to deposit over the limit
      const over = limit + 1n;
      await asset.mint(owner.address, over);
      await asset.approve(await vault.getAddress(), over);

      await expect(vault.deposit(over, owner.address)).to.be.revertedWith(
        "Deposit exceeds limit"
      );

      // Deposit exactly the limit
      await expect(vault.deposit(limit, owner.address))
        .to.emit(vault, "Deposit")
        .withArgs(owner.address, owner.address, limit, limit);

      // After reaching limit, further deposits are blocked
      expect(await vault.maxDeposit(owner.address)).to.equal(0n);
      await expect(vault.deposit(1n, owner.address)).to.be.revertedWith("Deposit exceeds limit");

      // maxMint should also be 0 now
      expect(await vault.maxMint(owner.address)).to.equal(0n);
      await expect(vault.mint(1n, owner.address)).to.be.revertedWith("Mint exceeds limit");
    });
  });

  describe("ERC20 Share Token behavior", function () {
    it("supports share transfers and allowances", async function () {
      const amount = ethers.parseEther("20");
      await asset.mint(owner.address, amount);
      await asset.approve(await vault.getAddress(), amount);
      await vault.deposit(amount, owner.address);

      const half = amount / 2n;
      await expect(vault.transfer(user1.address, half))
        .to.emit(vault, "Transfer")
        .withArgs(owner.address, user1.address, half);

      expect(await vault.balanceOf(user1.address)).to.equal(half);

      await expect(vault.connect(user1).approve(user2.address, half))
        .to.emit(vault, "Approval")
        .withArgs(user1.address, user2.address, half);

      await expect(vault.connect(user2).transferFrom(user1.address, user2.address, half))
        .to.emit(vault, "Transfer")
        .withArgs(user1.address, user2.address, half);

      expect(await vault.balanceOf(user2.address)).to.equal(half);
      expect(await vault.allowance(user1.address, user2.address)).to.equal(0n);
    });
  });
});
