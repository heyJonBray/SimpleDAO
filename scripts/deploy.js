// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require('hardhat');

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  const SDAO = await ethers.getContractFactory('SDAO');
  const governance = await ethers.getContractFactory('Governance');
  const voting = await ethers.getContractFactory('Voting');
  const treasury = await ethers.getContractFactory('Treasury');

  const sdao = await SDAO.deploy();
  const gov = await governance.deploy(sdao.address);
  const vot = await voting.deploy(sdao.address, gov.address);
  const tre = await treasury.deploy(gov.address, sdao.address, router.address);

  console.log('SDAO deployed to:', sdao.address);
  console.log('Governance deployed to:', gov.address);
  console.log('Voting deployed to:', vot.address);
  console.log('Treasury deployed to:', tre.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });
