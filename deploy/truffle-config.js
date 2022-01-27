require('dotenv').config();

const HDWalletProvider = require('@truffle/hdwallet-provider');
const mnemonic = "";
const live_url = "https://bsc-dataseed1.binance.org";
const test_url = "https://data-seed-prebsc-1-s1.binance.org:8545";


module.exports = {
plugins: ['truffle-plugin-verify', 'truffle-contract-size'],
api_keys: { bscscan: ""},

  networks: {
    test: {
      networkCheckTimeout: 20000,
  provider: () => new HDWalletProvider(mnemonic, `https://data-seed-prebsc-1-s1.binance.org:8545`),
  network_id: 97, // Ropsten's id
  gas: 10000000, // Ropsten has a lower block limit than mainnet
  confirmations: 0, // # of confs to wait between deployments. (default: 0)
  timeoutBlocks: 500, // # of blocks before a deployment times out  (minimum/default: 50)
  skipDryRun: true // Skip dry run before migrations? (default: false for public nets )

    }
    
  },
  compilers: {
    solc: {
      version: "^0.8.6",  
    }
  }
};
