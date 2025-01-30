const hre = require("hardhat");

async function main() {
    const proposals = [
        hre.ethers.encodeBytes32String("Option A"),
        hre.ethers.encodeBytes32String("Option B"),
        hre.ethers.encodeBytes32String("Option C")
    ];

    const Ballot = await hre.ethers.deployContract("Ballot", [proposals]);
    await Ballot.waitForDeployment();

    console.log("Ballot deployed at:", Ballot.target);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
