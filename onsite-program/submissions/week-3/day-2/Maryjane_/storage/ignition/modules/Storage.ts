// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const GreeterModule = buildModule("GreeterModule", (m) => {
  const Greeter = m.contract("Greeter");
  return { Greeter };
});

export default GreeterModule;
