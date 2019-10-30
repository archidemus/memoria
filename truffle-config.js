
module.exports = {

  networks: {
    ganache: {
      host: "localhost",
      port: 8545,
      network_id: "5777",
      test_port: 8545,
    },
    ropsten: {
      host: "localhost",
      port: 8504,
      network_id: "3",
      test_port: 8504
    },
    private: {
      host: 'localhost',
      port: 8501,
      from: "0xcF9D370f9f6F2F99DD3d5FFab98cb3943F097461",
      network_id: '23451',
      test_port: 8502,
      gas: 0,
      gasPrice: 0
    }

  },

  mocha: {},

  compilers: {
    solc: {
      version: "0.5.10"
    }
  }
}
