pragma solidity <=0.5.0;
//Author: Fadhlan Ridhwanallah

import './CMCEnabled.sol';
import './ContractProvider.sol';

//PropertyBase
contract TransactionDB is CMCEnabled {

  function getTransaction() private view returns (address){
    return ContractProvider(contractManager).contracts('transaction');
  }

  enum State { Created, SellerPaid, BuyerPaid, Finished, Inactive }

  struct Transaction {
    address payable notary;
    address payable buyer;
    address payable seller;
    string ipfsHash;
    uint256 notaryPrice;
    uint256 amountPrice;
    uint256 depositAmount;
    uint256 amountPaymentSeller;
    uint256 amountPaymentBuyer;
    State state;
  }

  //All transaction store in this contract
  mapping(uint256 => Transaction) private transactionData;

  //Stores the index of a transaction in the transactionOf
  mapping(uint256 => uint256) private indexOfTransaction;

  modifier onlyTransactionContract() {
    require(msg.sender == getTransaction(), "Invalid transaction contract");
    _;
  }

  function getNotaryOf(uint256 _propertyId) public view onlyTransactionContract returns (address payable) {
    return transactionData[_propertyId].notary;
  }

  function getBuyerOf(uint256 _propertyId) public view onlyTransactionContract returns (address payable) {
    return transactionData[_propertyId].buyer;
  }

  function getSellerOf(uint256 _propertyId) public view onlyTransactionContract returns (address payable) {
    return transactionData[_propertyId].seller;
  }

  function getIpfsHashOf(uint256 _propertyId) public view onlyTransactionContract returns (string memory) {
    return transactionData[_propertyId].ipfsHash;
  }

  function getNotaryPriceOf(uint256 _propertyId) public view onlyTransactionContract returns (uint256) {
    return transactionData[_propertyId].notaryPrice;
  }

  function getAmountPriceOf(uint256 _propertyId) public view onlyTransactionContract returns (uint256) {
    return transactionData[_propertyId].amountPrice;
  }

  function getDepositAmountOf(uint256 _propertyId) public view onlyTransactionContract returns (uint256) {
    return transactionData[_propertyId].depositAmount;
  }

  function getAmountPaymentSellerOf(uint256 _propertyId) public view onlyTransactionContract returns (uint256) {
    return transactionData[_propertyId].amountPaymentSeller;
  }

  function getAmountPaymentBuyerOf(uint256 _propertyId) public view onlyTransactionContract returns (uint256) {
    return transactionData[_propertyId].amountPaymentBuyer;
  }

  function getStateOf(uint256 _propertyId) public view onlyTransactionContract returns (State) {
    return transactionData[_propertyId].state;
  }

  function isTransactionExist(uint256 _propertyId) public view onlyTransactionContract returns (bool) {
    return transactionData[_propertyId].seller != address(0x0);
  }

  function setTransaction(uint256 _propertyId, address payable _notary, address payable _buyer, address payable _seller, string memory _ipfsHash, uint256 _notaryPrice,
                          uint256 _amountPrice, uint256 _depositAmount, uint256 _amountPaymentSeller, uint256 _amountPaymentBuyer, State _state)
  public onlyTransactionContract {
    transactionData[_propertyId].notary = _notary;
    transactionData[_propertyId].buyer = _buyer;
    transactionData[_propertyId].seller = _seller;
    transactionData[_propertyId].ipfsHash = _ipfsHash;
    transactionData[_propertyId].notaryPrice = _notaryPrice;
    transactionData[_propertyId].amountPrice = _amountPrice;
    transactionData[_propertyId].depositAmount = _depositAmount;
    transactionData[_propertyId].amountPaymentSeller = _amountPaymentSeller;
    transactionData[_propertyId].amountPaymentBuyer = _amountPaymentBuyer;
    transactionData[_propertyId].state = _state;
  }

  function setStateOf(uint256 _propertyId, State _state) public onlyTransactionContract {
      transactionData[_propertyId].state = _state;
  }

}
