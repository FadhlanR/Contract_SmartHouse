pragma solidity <=0.5.0;
//Author: Fadhlan Ridhwanallah

import './CMCEnabled.sol';
import './House.sol';
import './Transaction.sol';
import './TransactionDB.sol';
import './ContractProvider.sol';

//Application Logic
contract SmartHouse is CMCEnabled {
  //House part
  function getHouse() private view returns (address){
    return ContractProvider(contractManager).contracts('house');
  }

  function getTransaction() private view returns (address){
    return ContractProvider(contractManager).contracts('transaction');
  }

  modifier onlyContractOwner() {
    require(ContractProvider(contractManager).owner() == msg.sender, "Invalid Owner Of Contract");
    _;
  }

  modifier onlyOwner(uint256 _propertyId) {
    require(isOwner(msg.sender, _propertyId), "Invalid owner");
    _;
  }

  modifier onlyCurrentOwner(address _claimant, uint256 _propertyId) {
    require(isOwner(_claimant, _propertyId), "Invalid owner");
    _;
  }

  modifier isDestinataryDefined(address _destinatary) {
    require(_destinatary != address(0x0), "Invalid destinatary");
    _;
  }

  modifier destinataryIsNotHolder(uint256 _propertyId, address _to) {
    require(ownerOf(_propertyId) != _to, "Destinatary is an owner");
    _;
  }

  function isOwner(address _claimant, uint256 _propertyId) public view returns (bool) {
    return ownerOf(_propertyId) == _claimant;
  }

  function totalSupply() public view returns (uint256) {
    return House(getHouse()).totalSupply();
  }

  function ownerOf(uint256 _propertyId) public view returns (address) {
    return House(getHouse()).ownerOf(_propertyId);
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return House(getHouse()).balanceOf(_owner);
  }

  function getHouseData(uint256 _propertyId) external view returns (string memory, address) {
    return House(getHouse()).getHouseData(_propertyId);
  }

  function getCryptoKey(uint256 _propertyId) external view onlyOwner(_propertyId) returns (bytes32) {
    return House(getHouse()).getCryptoKey(_propertyId);
  }

  //External setter
  function houseRegistration(uint256 _propertyId, string calldata _location, address _beneficiary) external onlyContractOwner {
    return House(getHouse()).houseRegistration(_propertyId, _location, _beneficiary);
  }

  function transferHouse(address _from, address _to, uint256 _propertyId)
    isDestinataryDefined(_to)
    destinataryIsNotHolder(_propertyId, _to)
    onlyCurrentOwner(_from, _propertyId)
    private
  {
    House(getHouse()).transferHouse(_from, _to, _propertyId);
  }

  //Transaction part
  //Modifier and Validate Function
  modifier onlyNotary(uint256 _propertyId) {
    require(isNotary(msg.sender, _propertyId), "Invalid notary for these transaction");
    _;
  }

  modifier onlyBuyer(uint256 _propertyId) {
    require(isBuyer(msg.sender, _propertyId), "Invalid buyer for these transaction");
    _;
  }

  modifier onlySeller(uint256 _propertyId) {
    require(isSeller(msg.sender, _propertyId), "Invalid seller for these transaction");
    _;
  }

  modifier onlyStakeHolder(uint256 _propertyId) {
    require(isSeller(msg.sender, _propertyId) || isBuyer(msg.sender, _propertyId) || isNotary(msg.sender, _propertyId), "Invalid seller for these transaction");
    _;
  }

  modifier whenCreated(uint256 _propertyId) {
    require(isCreated(_propertyId), "Invalid state");
    _;
  }

  modifier whenSellerPaid(uint256 _propertyId) {
    require(isSellerPaid(_propertyId), "Invalid state");
    _;
  }

  modifier whenBuyerPaid(uint256 _propertyId) {
    require(isBuyerPaid(_propertyId), "Invalid state");
    _;
  }

  function isNotary(address _claimant, uint256 _propertyId) private view returns (bool) {
    return Transaction(getTransaction()).notaryOf(_propertyId) == _claimant;
  }

  function isBuyer(address _claimant, uint256 _propertyId) private view returns (bool) {
    return Transaction(getTransaction()).buyerOf(_propertyId) == _claimant;
  }

  function isSeller(address _claimant, uint256 _propertyId) private view returns (bool) {
    return Transaction(getTransaction()).sellerOf(_propertyId) == _claimant;
  }

  function isCreated(uint256 _propertyId) private view returns (bool) {
    return Transaction(getTransaction()).stateOf(_propertyId) == TransactionDB.State.Created;
  }

  function isSellerPaid(uint256 _propertyId) private view returns (bool) {
    return Transaction(getTransaction()).stateOf(_propertyId) == TransactionDB.State.SellerPaid;
  }

  function isBuyerPaid(uint256 _propertyId) private view returns (bool) {
    return Transaction(getTransaction()).stateOf(_propertyId) == TransactionDB.State.BuyerPaid;
  }

  function isFinished(uint256 _propertyId) private view returns (bool) {
    return Transaction(getTransaction()).stateOf(_propertyId) == TransactionDB.State.Finished;
  }

  function isInActive(uint256 _propertyId) private view returns (bool) {
    return Transaction(getTransaction()).stateOf(_propertyId) == TransactionDB.State.Inactive;
  }

  function createTransaction(uint256 _propertyId, address payable _buyer, address payable _seller, string calldata _ipfsHash, uint256 _notaryPrice,
                             uint256 _amountPrice, uint256 _depositAmount)
  external {
    require(isFinished(_propertyId) || isInActive(_propertyId) || !(Transaction(getTransaction()).isTransactionExist(_propertyId)), "Invalid state");

    Transaction(getTransaction()).createTransaction(_propertyId, msg.sender, _buyer, _seller, _ipfsHash, _notaryPrice,
                               _amountPrice, _depositAmount);
  }

  function sellerTransaction(uint256 _propertyId) external onlySeller(_propertyId) whenCreated(_propertyId) payable {
    Transaction(getTransaction()).sellerTransaction.value(msg.value)(_propertyId);
  }

  function buyerTransaction(uint256 _propertyId) external onlyBuyer(_propertyId) whenSellerPaid(_propertyId) payable {
    Transaction(getTransaction()).buyerTransaction.value(msg.value)(_propertyId);
  }

  function completeTransaction(uint256 _propertyId) external onlyNotary(_propertyId) whenBuyerPaid(_propertyId) {
    Transaction(getTransaction()).completeTransaction(_propertyId);
    transferHouse(Transaction(getTransaction()).sellerOf(_propertyId), Transaction(getTransaction()).buyerOf(_propertyId), _propertyId);
  }

  function abortTransaction(uint256 _propertyId) external onlyStakeHolder(_propertyId) {
    require(!isFinished(_propertyId) && !isInActive(_propertyId), "Invalid state");

    Transaction(getTransaction()).abortTransaction(msg.sender, _propertyId);
  }

  function getTransactionData(uint256 _propertyId) external view onlyStakeHolder(_propertyId)
  returns(address, address, address, string memory, TransactionDB.State) {
    return(Transaction(getTransaction()).notaryOf(_propertyId), Transaction(getTransaction()).sellerOf(_propertyId), Transaction(getTransaction()).buyerOf(_propertyId),
           Transaction(getTransaction()).ipfsHashOf(_propertyId), Transaction(getTransaction()).stateOf(_propertyId));
  }

  function getTransactionPayment(uint256 _propertyId) external view onlyStakeHolder(_propertyId)
  returns(uint256, uint256, uint256, uint256, uint256) {
    return(Transaction(getTransaction()).notaryPriceOf(_propertyId), Transaction(getTransaction()).amountPriceOf(_propertyId),
    Transaction(getTransaction()).depositAmountOf(_propertyId), Transaction(getTransaction()).amountPaymentSellerOf(_propertyId),
    Transaction(getTransaction()).amountPaymentBuyerOf(_propertyId));
  }
}
