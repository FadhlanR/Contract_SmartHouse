const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider('http://localhost:8545');
const web3 = new Web3(provider);
var BigNumber = require('bignumber.js');

var CMC = artifacts.require("./CMC.sol");
var HouseDB = artifacts.require("./HouseDB");
var House = artifacts.require("./House");
var TransactionDB = artifacts.require("./TransactionDB");
var Transaction = artifacts.require("./Transaction");
var smartHouse = artifacts.require("./SmartHouse");

var cmcInstance;
var smartHouseInstance;

var amountPaymentSeller;
contract('CMC', function(accounts) {
  const [notary, seller, buyer] = accounts;
  const propertyId = 12345;
  const location = "Jalan Cibiru Hilir No. 73"

  beforeEach(async () => {
    //Deploy contract
    cmcInstance = await CMC.new();
    var houseDB = await HouseDB.new();
    var house = await House.new();
    var transactionDB = await TransactionDB.new();
    var transaction = await Transaction.new();
    smartHouseInstance = await smartHouse.new();
   

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

    // // //define one smart house
    await smartHouseInstance.houseRegistration(propertyId, location, seller);
  });

  describe('One flow transaction test', () =>{
    it('Create transaction', async () => {
      const ipfsHash = "qxasdasfasdasdasfasd";
      const notaryPrice = 10;
      const amountPrice = 100000000;
      const depositAmount = 5000000;
      
      result = await smartHouseInstance.createTransaction(propertyId, buyer, seller, ipfsHash, notaryPrice,
                                 amountPrice, depositAmount, {from: notary});
      console.log("create");
      var resultSellerPaid = await smartHouseInstance.sellerTransaction(propertyId, {from: seller, value: 200000000});
      console.log("sell");
      var resultBuyerPaid = await smartHouseInstance.buyerTransaction(propertyId, {from: buyer, value: 200000000});
      console.log("buy");
      
      var completeTransaction = await smartHouseInstance.completeTransaction(propertyId, {from: notary});
      console.log("complete");
    })
  })

});
