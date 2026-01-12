import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";

/**
 * Deployment data structure
 */
interface DeploymentData {
  network: string;
  chainId: number;
  timestamp: string;
  deployer: string;
  contracts: {
    ParkingToken?: {
      address: string;
      constructorArgs: string[];
    };
    ParkingDAO?: {
      address: string;
      constructorArgs: string[];
    };
    ParkingMarket?: {
      address: string;
      constructorArgs: string[];
    };
  };
}

/**
 * Save deployment data to JSON file
 */
function saveDeploymentData(data: DeploymentData): void {
  const deploymentsDir = path.join(__dirname, "..", "deployments");
  
  // Ensure deployments directory exists
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir, { recursive: true });
  }

  const filePath = path.join(deploymentsDir, `${data.network}.json`);
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
  console.log(`\n✅ Deployment data saved to ${filePath}`);
}

/**
 * Load existing deployment data
 */
function loadDeploymentData(network: string): DeploymentData | null {
  const filePath = path.join(__dirname, "..", "deployments", `${network}.json`);
  
  if (!fs.existsSync(filePath)) {
    return null;
  }

  const data = fs.readFileSync(filePath, "utf-8");
  return JSON.parse(data);
}

async function main() {
  console.log("🚀 Starting Urban Parking dApp deployment...\n");

  // Get network information
  const network = await ethers.provider.getNetwork();
  const networkName = process.env.HARDHAT_NETWORK || "hardhat";
  const [deployer] = await ethers.getSigners();
  
  console.log("📋 Deployment Configuration:");
  console.log(`   Network: ${networkName}`);
  console.log(`   Chain ID: ${network.chainId}`);
  console.log(`   Deployer: ${deployer.address}`);
  
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log(`   Balance: ${ethers.formatEther(balance)} ETH\n`);

  // Check if contracts are already deployed
  const existingDeployment = loadDeploymentData(networkName);
  if (existingDeployment) {
    console.log("⚠️  Existing deployment found. This will be overwritten.\n");
  }

  // Initialize deployment data
  const deploymentData: DeploymentData = {
    network: networkName,
    chainId: Number(network.chainId),
    timestamp: new Date().toISOString(),
    deployer: deployer.address,
    contracts: {},
  };

  try {
    // Get constructor parameters from environment variables
    const tokenName = process.env.PARKING_TOKEN_NAME || "Urban Parking Token";
    const tokenSymbol = process.env.PARKING_TOKEN_SYMBOL || "UPT";
    const tokenInitialPrice = process.env.PARKING_TOKEN_INITIAL_PRICE || "1000000000000000"; // 0.001 ETH in wei

    console.log("📝 Constructor Parameters:");
    console.log(`   Token Name: ${tokenName}`);
    console.log(`   Token Symbol: ${tokenSymbol}`);
    console.log(`   Token Initial Price: ${ethers.formatEther(tokenInitialPrice)} ETH\n`);

    // 1. Deploy ParkingToken
    console.log("1️⃣  Deploying ParkingToken...");
    const ParkingTokenFactory = await ethers.getContractFactory("ParkingToken");
    const parkingToken = await ParkingTokenFactory.deploy(
      tokenName,
      tokenSymbol,
      tokenInitialPrice
    );
    await parkingToken.waitForDeployment();
    const parkingTokenAddress = await parkingToken.getAddress();
    
    console.log(`   ✅ ParkingToken deployed to: ${parkingTokenAddress}`);
    deploymentData.contracts.ParkingToken = {
      address: parkingTokenAddress,
      constructorArgs: [tokenName, tokenSymbol, tokenInitialPrice],
    };

    // 2. Deploy ParkingDAO
    console.log("\n2️⃣  Deploying ParkingDAO...");
    const ParkingDAOFactory = await ethers.getContractFactory("ParkingDAO");
    const parkingDAO = await ParkingDAOFactory.deploy();
    await parkingDAO.waitForDeployment();
    const parkingDAOAddress = await parkingDAO.getAddress();
    
    console.log(`   ✅ ParkingDAO deployed to: ${parkingDAOAddress}`);
    deploymentData.contracts.ParkingDAO = {
      address: parkingDAOAddress,
      constructorArgs: [],
    };

    // 3. Deploy ParkingMarket (requires DAO address as fee collector)
    console.log("\n3️⃣  Deploying ParkingMarket...");
    const ParkingMarketFactory = await ethers.getContractFactory("ParkingMarket");
    const parkingMarket = await ParkingMarketFactory.deploy(parkingDAOAddress);
    await parkingMarket.waitForDeployment();
    const parkingMarketAddress = await parkingMarket.getAddress();
    
    console.log(`   ✅ ParkingMarket deployed to: ${parkingMarketAddress}`);
    console.log(`   📍 Fee Collector (DAO): ${parkingDAOAddress}`);
    deploymentData.contracts.ParkingMarket = {
      address: parkingMarketAddress,
      constructorArgs: [parkingDAOAddress],
    };

    // Save deployment data
    saveDeploymentData(deploymentData);

    console.log("\n🎉 Deployment completed successfully!");
    console.log("\n📊 Deployment Summary:");
    console.log(`   ParkingToken: ${parkingTokenAddress}`);
    console.log(`   ParkingDAO: ${parkingDAOAddress}`);
    console.log(`   ParkingMarket: ${parkingMarketAddress}`);

  } catch (error) {
    console.error("\n❌ Deployment failed:");
    if (error instanceof Error) {
      console.error(`   Error: ${error.message}`);
      console.error(`   Stack: ${error.stack}`);
    } else {
      console.error(`   Unknown error: ${error}`);
    }
    
    // Save partial deployment data if any contracts were deployed
    if (Object.keys(deploymentData.contracts).length > 0) {
      console.log("\n⚠️  Saving partial deployment data...");
      saveDeploymentData(deploymentData);
    }
    
    process.exit(1);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

