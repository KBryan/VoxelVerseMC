/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");

module.exports = {
  solidity: '0.8.17',
  networks: {
    nebula: {
      url: '' +
          'https://mainnet.skalenodes.com/v1/green-giddy-denebola',
      accounts: ['YOUR_PRIVATE_KEY'],
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "ETHERSCAN_API"
  }
};
