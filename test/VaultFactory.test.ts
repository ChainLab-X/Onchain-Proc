import { expect } from "chai";
import { ethers } from "hardhat";
import { VaultFactory } from "../typechain-types";

describe("VaultFactory", function () {
  let vaultFactory: VaultFactory;
  let owner: any;
  let user1: any;
  let user2: any;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    const VaultFactoryFactory = await ethers.getContractFactory("VaultFactory");
    vaultFactory = await VaultFactoryFactory.deploy(owner.address);
    await vaultFactory.waitForDeployment();
  });

  describe("User Registration", function () {
    it("Should register a new user successfully", async function () {
      const tx = await vaultFactory.connect(user1).registerUser("alice", "DeFi enthusiast");
      await expect(tx).to.emit(vaultFactory, "UserRegistered");

      expect(await vaultFactory.isUserRegistered(user1.address)).to.be.true;
      const [username, bio, timestamp] = await vaultFactory.getUserInfo(user1.address);
      expect(username).to.equal("alice");
      expect(bio).to.equal("DeFi enthusiast");
      expect(timestamp).to.be.gt(0);
    });

    it("Should prevent duplicate registration", async function () {
      await vaultFactory.connect(user1).registerUser("alice", "DeFi enthusiast");
      await expect(
        vaultFactory.connect(user1).registerUser("alice2", "New bio")
      ).to.be.revertedWithCustomError(vaultFactory, "AlreadyRegistered");
    });

    it("Should reject empty username", async function () {
      await expect(
        vaultFactory.connect(user1).registerUser("", "Valid bio")
      ).to.be.revertedWithCustomError(vaultFactory, "InvalidUsername");
    });

    it("Should reject username exceeding max length", async function () {
      const longUsername = "a".repeat(21);
      await expect(
        vaultFactory.connect(user1).registerUser(longUsername, "Valid bio")
      ).to.be.revertedWithCustomError(vaultFactory, "InvalidUsername");
    });

    it("Should reject empty bio", async function () {
      await expect(
        vaultFactory.connect(user1).registerUser("alice", "")
      ).to.be.revertedWithCustomError(vaultFactory, "InvalidBio");
    });

    it("Should reject bio exceeding max length", async function () {
      const longBio = "a".repeat(31);
      await expect(
        vaultFactory.connect(user1).registerUser("alice", longBio)
      ).to.be.revertedWithCustomError(vaultFactory, "InvalidBio");
    });

    it("Should prevent duplicate usernames", async function () {
      await vaultFactory.connect(user1).registerUser("alice", "First user");
      await expect(
        vaultFactory.connect(user2).registerUser("alice", "Second user")
      ).to.be.revertedWithCustomError(vaultFactory, "InvalidUsername");
    });

    it("Should reject invalid username characters", async function () {
      await expect(
        vaultFactory.connect(user1).registerUser("alice!", "Valid bio")
      ).to.be.revertedWithCustomError(vaultFactory, "InvalidUsername");
    });
  });

  describe("View Functions", function () {
    beforeEach(async function () {
      await vaultFactory.connect(user1).registerUser("alice", "DeFi enthusiast");
    });

    it("Should return correct user info", async function () {
      const [username, bio, timestamp] = await vaultFactory.getUserInfo(user1.address);
      expect(username).to.equal("alice");
      expect(bio).to.equal("DeFi enthusiast");
      expect(timestamp).to.be.gt(0);
    });

    it("Should return username via helper", async function () {
      expect(await vaultFactory.getUserUsername(user1.address)).to.equal("alice");
    });

    it("Should return bio via helper", async function () {
      expect(await vaultFactory.getUserBio(user1.address)).to.equal("DeFi enthusiast");
    });

    it("Should return registration timestamp", async function () {
      const timestamp = await vaultFactory.getRegistrationTimestamp(user1.address);
      expect(timestamp).to.be.gt(0);
    });

    it("Should return registered users count", async function () {
      expect(await vaultFactory.getRegisteredUsersCount()).to.equal(1);
      await vaultFactory.connect(user2).registerUser("bob", "Trader");
      expect(await vaultFactory.getRegisteredUsersCount()).to.equal(2);
    });
  });

  describe("Admin Functions", function () {
    beforeEach(async function () {
      await vaultFactory.connect(user1).registerUser("alice", "DeFi enthusiast");
    });

    it("Should allow owner to pause registration", async function () {
      await vaultFactory.pauseRegistration();
      expect(await vaultFactory.registrationPaused()).to.be.true;
      await expect(
        vaultFactory.connect(user2).registerUser("bob", "Trader")
      ).to.be.revertedWithCustomError(vaultFactory, "InvalidUsername");
    });

    it("Should allow owner to unpause registration", async function () {
      await vaultFactory.pauseRegistration();
      await vaultFactory.unpauseRegistration();
      expect(await vaultFactory.registrationPaused()).to.be.false;
      await vaultFactory.connect(user2).registerUser("bob", "Trader");
      expect(await vaultFactory.isUserRegistered(user2.address)).to.be.true;
    });

    it("Should allow owner to update user info", async function () {
      await vaultFactory.adminUpdateUserInfo(user1.address, "alice_new", "New bio");
      const [username, bio] = await vaultFactory.getUserInfo(user1.address);
      expect(username).to.equal("alice_new");
      expect(bio).to.equal("New bio");
    });

    it("Should allow owner to remove user", async function () {
      await vaultFactory.adminRemoveUser(user1.address);
      expect(await vaultFactory.isUserRegistered(user1.address)).to.be.false;
      expect(await vaultFactory.getRegisteredUsersCount()).to.equal(0);
    });

    it("Should not allow non-owner to pause", async function () {
      await expect(
        vaultFactory.connect(user1).pauseRegistration()
      ).to.be.revertedWithCustomError(vaultFactory, "OwnableUnauthorizedAccount");
    });
  });

  describe("Edge Cases", function () {
    it("Should handle batch user info lookup", async function () {
      await vaultFactory.connect(user1).registerUser("alice", "User 1");
      await vaultFactory.connect(user2).registerUser("bob", "User 2");
      
      const [isRegistered, usernames, bios, timestamps] = await vaultFactory.batchGetUserInfo([
        user1.address,
        user2.address,
        owner.address
      ]);
      
      expect(isRegistered[0]).to.be.true;
      expect(isRegistered[1]).to.be.true;
      expect(isRegistered[2]).to.be.false;
      expect(usernames[0]).to.equal("alice");
      expect(usernames[1]).to.equal("bob");
    });

    it("Should return correct getAllUserInfo", async function () {
      await vaultFactory.connect(user1).registerUser("alice", "DeFi enthusiast");
      const [isRegistered, username, bio, timestamp] = await vaultFactory.getAllUserInfo(user1.address);
      expect(isRegistered).to.be.true;
      expect(username).to.equal("alice");
      expect(bio).to.equal("DeFi enthusiast");
      expect(timestamp).to.be.gt(0);
    });

    it("Should handle unregistered user in getUserInfo", async function () {
      await expect(
        vaultFactory.getUserInfo(user1.address)
      ).to.be.revertedWithCustomError(vaultFactory, "UserNotRegistered");
    });

    it("Should check username availability", async function () {
      expect(await vaultFactory.isUsernameAvailable("alice")).to.be.true;
      await vaultFactory.connect(user1).registerUser("alice", "User 1");
      expect(await vaultFactory.isUsernameAvailable("alice")).to.be.false;
      expect(await vaultFactory.isUsernameAvailable("bob")).to.be.true;
    });
  });

  describe("Integration Tests", function () {
    it("Should handle complete registration flow", async function () {
      // Register multiple users
      await vaultFactory.connect(user1).registerUser("alice", "DeFi user");
      await vaultFactory.connect(user2).registerUser("bob", "Trader");
      
      // Verify counts
      expect(await vaultFactory.getRegisteredUsersCount()).to.equal(2);
      
      // Verify batch lookup
      const [isRegistered] = await vaultFactory.batchGetUserInfo([user1.address, user2.address]);
      expect(isRegistered[0]).to.be.true;
      expect(isRegistered[1]).to.be.true;
      
      // Verify individual lookups
      expect(await vaultFactory.isUserRegistered(user1.address)).to.be.true;
      expect(await vaultFactory.isUserRegistered(user2.address)).to.be.true;
    });

    it("Should handle admin operations flow", async function () {
      await vaultFactory.connect(user1).registerUser("alice", "Original bio");
      
      // Pause registration
      await vaultFactory.pauseRegistration();
      await expect(
        vaultFactory.connect(user2).registerUser("bob", "Should fail")
      ).to.be.revertedWithCustomError(vaultFactory, "InvalidUsername");
      
      // Unpause and register
      await vaultFactory.unpauseRegistration();
      await vaultFactory.connect(user2).registerUser("bob", "Should work");
      expect(await vaultFactory.isUserRegistered(user2.address)).to.be.true;
      
      // Update user info
      await vaultFactory.adminUpdateUserInfo(user1.address, "alice_updated", "Updated bio");
      const [username, bio] = await vaultFactory.getUserInfo(user1.address);
      expect(username).to.equal("alice_updated");
      expect(bio).to.equal("Updated bio");
    });
  });
});

