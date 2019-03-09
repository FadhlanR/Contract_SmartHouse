pragma solidity <=0.5.0;
//Author: Fadhlan Ridhwanallah

import './ContractProvider.sol';
import './SmartHouseEnabled.sol';
import './TransactionDB.sol';
import './SafeMath.sol';

//PropertyBase
contract Transaction is SmartHouseEnabled {
  using SafeMath for uint256;

  function getTransactionDB() private view returns (address){
    return ContractProvider(contractManager).contracts('transactiondb');
  }

  //Events
  event initiateTransaction(address  indexed notary, address indexed seller, address indexed buyer, uint256 propertyId, uint256 amountPrice);
  event sellerPayment(address indexed seller, uint256 amountTransfer, uint256 change);
  event buyerPayment(address indexed buyer, uint256 amountTransfer, uint256 change);
  event settledTransaction(address indexed notary, address indexed seller, address indexed buyer, uint256 propertyId, uint256 amountPrice);
  event cancelTransaction(address indexed canceller, uint256 propertyId);

  //Modifier and Validate Function
  modifier onlySmartHouse() {
    require(isSmartHouse(), "Invalid Smart House Contract");
    _;
  }

  modifier onlyTransactionExist(uint256 _propertyId) {
    require(isTransactionExist(_propertyId), "Transaction not exist");
    _;
  }

  function isTransactionExist(uint256 _propertyId) public view returns(bool) {
    return TransactionDB(getTransactionDB()).isTransactionExist(_propertyId);
  }

  //Getter
  function notaryOf(uint256 _propertyId) public view onlySmartHouse onlyTransactionExist(_propertyId) returns (address payable) {
    return TransactionDB(getTransactionDB()).getNotaryOf(_propertyId);
  }

  function buyerOf(uint256 _propertyId) public view onlySmartHouse onlyTransactionExist(_propertyId) returns (address payable) {
    return TransactionDB(getTransactionDB()).getBuyerOf(_propertyId);
  }

  function sellerOf(uint256 _propertyId) public view onlySmartHouse onlyTransactionExist(_propertyId) returns (address payable) {
    return TransactionDB(getTransactionDB()).getSellerOf(_propertyId);
  }

  function ipfsHashOf(uint256 _propertyId) public view onlySmartHouse onlyTransactionExist(_propertyId) returns (string memory) {
    return TransactionDB(getTransactionDB()).getIpfsHashOf(_propertyId);
  }

  function notaryPriceOf(uint256 _propertyId) public view onlySmartHouse onlyTransactionExist(_propertyId) returns (uint256) {
    return TransactionDB(getTransactionDB()).getNotaryPriceOf(_propertyId);
  }

  function amountPriceOf(uint256 _propertyId) public view onlySmartHouse onlyTransactionExist(_propertyId) returns (uint256) {
    return TransactionDB(getTransactionDB()).getAmountPriceOf(_propertyId);
  }

  function depositAmountOf(uint256 _propertyId) public view onlySmartHouse onlyTransactionExist(_propertyId) returns (uint256) {
    return TransactionDB(getTransactionDB()).getDepositAmountOf(_propertyId);
  }

  function amountPaymentSellerOf(uint256 _propertyId) public view onlySmartHouse onlyTransactionExist(_propertyId) returns (uint256) {
    return TransactionDB(getTransactionDB()).getAmountPaymentSellerOf(_propertyId);
  }

  function amountPaymentBuyerOf(uint256 _propertyId) public view onlySmartHouse onlyTransactionExist(_propertyId) returns (uint256) {
    return TransactionDB(getTransactionDB()).getAmountPaymentBuyerOf(_propertyId);
  }

  function stateOf(uint256 _propertyId) public view onlySmartHouse returns (TransactionDB.State) {
    return TransactionDB(getTransactionDB()).getStateOf(_propertyId);
  }

  function createTransaction(uint256 _propertyId, address payable _notary, address payable _buyer, address payable _seller, string calldata _ipfsHash, uint256 _notaryPrice,
                             uint256 _amountPrice, uint256 _depositAmount)
  external onlySmartHouse {
    require(_notaryPrice <= _amountPrice.div(100), "Invalid notary price");

    uint256 _amountPaymentSeller = ((_amountPrice.mul(5)).div(100)).add((_notaryPrice.div(2)));
    uint256 _amountPaymentBuyer = (((_amountPrice.mul(5)).div(100)).add((_notaryPrice.div(2)))).add(_amountPrice.sub(_depositAmount));

    TransactionDB(getTransactionDB()).setTransaction(_propertyId, _notary, _buyer, _seller, _ipfsHash,
      _notaryPrice, _amountPrice, _depositAmount, _amountPaymentSeller, _amountPaymentBuyer, TransactionDB.State.Created);

    emit initiateTransaction(_notary, _seller, _buyer, _propertyId, _amountPrice);
  }

  function sellerTransaction(uint256 _propertyId) external onlySmartHouse onlyTransactionExist(_propertyId) payable {
    address payable _seller = sellerOf(_propertyId);
    uint256 _amountPaymentSeller = amountPaymentSellerOf(_propertyId);
    require(_amountPaymentSeller <= msg.value, "Invalid amount of payment");

    uint256 change;

    if(msg.value > _amountPaymentSeller){
      change = msg.value - _amountPaymentSeller;
      _seller.transfer(change);
    }

    TransactionDB(getTransactionDB()).setStateOf(_propertyId, TransactionDB.State.SellerPaid);
    emit sellerPayment(_seller, msg.value, change);
  }

  function buyerTransaction(uint256 _propertyId) external onlySmartHouse onlyTransactionExist(_propertyId) payable {
    address payable _buyer = buyerOf(_propertyId);
    uint256 _amountPaymentBuyer = amountPaymentBuyerOf(_propertyId);
    require(_amountPaymentBuyer <= msg.value, "Invalid amount of payment");

    uint256 change;

    if(msg.value > _amountPaymentBuyer){
      change = msg.value - _amountPaymentBuyer;

      _buyer.transfer(change);
    }

    TransactionDB(getTransactionDB()).setStateOf(_propertyId, TransactionDB.State.BuyerPaid);
    emit buyerPayment(_buyer, msg.value, change);
  }

  function completeTransaction(uint256 _propertyId) external onlySmartHouse onlyTransactionExist(_propertyId) {
    address payable _notary = notaryOf(_propertyId);
    address payable _seller = sellerOf(_propertyId);
    address payable _buyer = buyerOf(_propertyId);
    uint256 _notaryPrice = notaryPriceOf(_propertyId);
    uint256 _amountPrice = amountPriceOf(_propertyId);
    uint256 _depositAmount = depositAmountOf(_propertyId);

    _notary.transfer(_notaryPrice);
    _seller.transfer(_amountPrice.sub(_depositAmount));

    TransactionDB(getTransactionDB()).setStateOf(_propertyId, TransactionDB.State.Finished);
    emit settledTransaction(_notary, _seller, _buyer, _propertyId,
                            _amountPrice);
  }

  function abortTransaction(address _canceller, uint256 _propertyId) external onlySmartHouse onlyTransactionExist(_propertyId) {
    TransactionDB.State _state = stateOf(_propertyId);
    address payable _seller = sellerOf(_propertyId);
    address payable _buyer = buyerOf(_propertyId);
    uint256 _amountPaymentSeller = amountPaymentSellerOf(_propertyId);

    if(_state == TransactionDB.State.SellerPaid){
      _seller.transfer(_amountPaymentSeller);
    }
    else if(_state == TransactionDB.State.BuyerPaid){
      uint256 _amountPaymentBuyer = amountPaymentBuyerOf(_propertyId);
      _seller.transfer(_amountPaymentSeller);
      _buyer.transfer(_amountPaymentBuyer);
    }

    TransactionDB(getTransactionDB()).setStateOf(_propertyId, TransactionDB.State.Inactive);
    emit cancelTransaction(_canceller, _propertyId);
  }
}
