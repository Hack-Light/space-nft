import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

/**
 * Deploys a contract named "Snowman" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deploySpace: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /*
    On localhost, the deployer account is the one that comes with Hardhat, which is already funded.

    When deploying to live networks (e.g `yarn deploy --network goerli`), the deployer account
    should have sufficient balance to pay for the gas fees for contract creation.

    You can generate a random account with `yarn generate` which will fill DEPLOYER_PRIVATE_KEY
    with a random private key in the .env file (then used on hardhat.config.ts)
    You can run the `yarn account` command to check your balance in every network.
  */
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;
  console.log("started");

  // Deploy libraries
  const TokenURIGen = await deploy("TokenURIGen", {
    from: deployer,
  });
  console.log(1, TokenURIGen.address);

  const spaceSVG = await deploy("SpaceSVG", {
    from: deployer,
    libraries: {
      TokenURIGen: TokenURIGen.address,
    },
  });
  console.log(2, spaceSVG.address);

  const bodyManager = await deploy("BodyManager", {
    from: deployer,
    libraries: {
      TokenURIGen: TokenURIGen.address,
    },
  });

  console.log(3, bodyManager.address);

  const attributesGen = await deploy("AttributesGen", {
    from: deployer,
  });

  console.log(4, attributesGen.address);
  console.log("4a", deployer);

  await deploy("Space", {
    from: deployer,
    args: [deployer],
    log: true,
    libraries: {
      AttributesGen: attributesGen.address,
      SpaceSVG: spaceSVG.address,
      BodyManager: bodyManager.address,
    },
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  console.log(5);

  // Get the deployed contract
  // const Snowman = await hre.ethers.getContract("Snowman", deployer);
};

export default deploySpace;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags Snowman
deploySpace.tags = ["Space"];
