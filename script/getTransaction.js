const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider('http://localhost:8545');
const web3 = new Web3(provider);
var BigNumber = require('bignumber.js');

const CMC = artifacts.require("./CMC.sol");
const HouseDB = artifacts.require("./HouseDB");
const House = artifacts.require("./House");
const TransactionDB = artifacts.require("./TransactionDB");
const Transaction = artifacts.require("./Transaction");
const SmartHouse = artifacts.require("./SmartHouse");

module.exports = async (accounts) => {
  const smartHouse = await SmartHouse.deployed();

  const propertyId = 12345;
  const location = "Jalan Cibiru Hilir No. 73"
  const notaryPrice = 10;
  const amountPrice = 100000000;
  const depositAmount = 5000000;

 var transactionData = await smartHouse.getTransactionData(propertyId);
 console.log(transactionData);

}
