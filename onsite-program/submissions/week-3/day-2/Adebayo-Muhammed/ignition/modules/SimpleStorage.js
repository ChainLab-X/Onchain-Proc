const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("SimpleStorageModule", (m) => {
  const storage = m.contract("SimpleStorage");
  return { storage };
});