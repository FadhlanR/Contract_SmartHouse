const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider('http://localhost:8545');
const web3 = new Web3(provider);
var BigNumber = require('bignumber.js');

const CMC = artifacts.require("./CMC.sol");
const HouseDB = artifacts.require("./HouseDB");
const House = artifacts.require("./House");
const TransactionDB = artifacts.require("./TransactionDB");
const Transaction = artifacts.require("./Transaction");
const SmartHouse= artifacts.require("./SmartHouse");

module.exports = async (accounts) => {
  const cmcInstance = await CMC.deployed();
  const houseDB = await HouseDB.deployed();
  const house = await House.deployed();
  const transactionDB = await TransactionDB.deployed();
  const transaction = await Transaction.deployed();
  const smartHouseInstance = await SmartHouse.deployed();


  // //Register on CMC
  const _housedb = "housedb";
  const _house = "house";
  const _transactiondb = "transactiondb";
  const _transaction = "transaction";
  const _smarthouse = "smarthouse";

  var receiptHouseDB = await cmcInstance.addContract(web3.utils.fromAscii(_housedb), houseDB.address);
  var receiptHouse = await cmcInstance.addContract(web3.utils.fromAscii(_house), house.address);
  var receiptTransactionDB = await cmcInstance.addContract(web3.utils.fromAscii(_transactiondb), transactionDB.address);
  var receiptTransaction = await cmcInstance.addContract(web3.utils.fromAscii(_transaction), transaction.address);
  var receiptSmartHouse = await cmcInstance.addContract(web3.utils.fromAscii(_smarthouse), smartHouseInstance.address);

}
