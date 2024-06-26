const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('VoxelVerseMC');
  const gameContract = await gameContractFactory.deploy();
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

 /* let txn;
  // We only have three characters.
  // an NFT w/ the character at index 2 of our array.
  txn = await gameContract.mintCharacterNFT(address);
  await txn.wait();
  console.log("Done!");*/
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();