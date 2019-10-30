const Web3 = require("web3");
const jsonContract = require("./build/contracts/ItemTrackingContract.json");
const truffleConf = require("./truffle-config");

const accounts = {
  owner1: "0xcF9D370f9f6F2F99DD3d5FFab98cb3943F097461",
  admin1: "0x97deC0F7f29A571E4C730234073dF151A34Da016",
  admin2: "0x97E3957dBa309E2a7558bA76F0b7558676CAAa33",
  admin3: "0x794B44D6B775343Fc3a75f4213635B5f9268f9f7",
  user1: "0x28542774261bF85100bd2B8D3b7Ed2dD75a44ab2",
  user2: "0x4A0dE930Dc9E44F15BeBcC124e8F0eB5a1f1df88",
  user3: "0x61C2254B3FF6BaBC6989aFc4915207D027F7d9D0",
  user4: "0x09ED5Be77368de70E6c480E46644777e80158a5d",
  user5: "0x9E319c14eDE476EA4F3D62C02faDD1BC0eDd121c",
  user6: "0xffD6980738433c3C8c1060438971e4F3DAE404a3"
}

configContract = async () => {
  const networkParams = truffleConf.networks[process.argv[2]];
  const web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:" + networkParams.test_port));
  const contract = new web3.eth.Contract(jsonContract.abi, jsonContract.networks[networkParams.network_id].address);

  if (process.argv[2] === "ganache") {
    const getAccounts = await web3.eth.getAccounts();
    accounts.owner1 = getAccounts[0];
    accounts.admin1 = getAccounts[1];
    accounts.admin2 = getAccounts[2];
    accounts.admin3 = getAccounts[3];
    accounts.user1 = getAccounts[4];
    accounts.user2 = getAccounts[5];
    accounts.user3 = getAccounts[6];
    accounts.user4 = getAccounts[7];
    accounts.user5 = getAccounts[8];
    accounts.user6 = getAccounts[9];
  }

  web3.eth.defaultAccount = accounts[0];
  return { web3, contract, accounts };
}

module.exports = configContract;