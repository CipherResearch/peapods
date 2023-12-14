const hre = require("hardhat");

async function main() {
  const primary = await hre.ethers.deployContract("Whiteknight");

  await primary.waitForDeployment();

  console.log(`Deployed to ${primary.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
