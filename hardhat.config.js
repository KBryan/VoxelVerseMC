/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");

module.exports = {
  solidity: '0.8.17',
  networks: {
    goerli: {
      url: '' +
          'https://goerli.infura.io/v3/YOUR_API',
      accounts: ['YOUR_PRIVATE_KEY'],
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "ETHERSCAN_API"
  }
};