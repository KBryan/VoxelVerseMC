const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('PixelDudes');
  const gameContract = await gameContractFactory.deploy(
      ["Motto", "Anzinga", "Kharicha", "SatoshiDon"],       // Names
      ["https://www.kwamebryan.com/pixel_dudes/1.png", // Images
        "https://www.kwamebryan.com/pixel_dudes/2.png",
        "https://www.kwamebryan.com/pixel_dudes/3.png",
        "https://www.kwamebryan.com/pixel_dudes/4.png"],
      [100, 200, 300, 400],                    // HP values
      [100, 50, 25, 15],                   // Attack damage values
      "TheBigDude", // Boss name
      "https://www.kwamebryan.com/pixel_dudes/10.png", // Boss image
      10000, // Boss hp
      50 // Boss attack damage                  // Attack damage values
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

 /* let txn;
  // We only have three characters.
  // an NFT w/ the character at index 2 of our array.
  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
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