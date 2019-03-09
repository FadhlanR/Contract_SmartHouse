const CMC = artifacts.require("./CMC.sol");
const HouseDB = artifacts.require("./HouseDB");
const House = artifacts.require("./House");
const TransactionDB = artifacts.require("./TransactionDB");
const Transaction = artifacts.require("./Transaction");
const SmartHouse = artifacts.require("./SmartHouse");

module.exports = function(deployer, accounts) {
  deployer.deploy(CMC);
  deployer.deploy(HouseDB);
  deployer.deploy(House);
  deployer.deploy(TransactionDB);
  deployer.deploy(Transaction);
  deployer.deploy(SmartHouse);
};
