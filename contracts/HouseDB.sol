pragma solidity <=0.5.0;
//Author: Fadhlan Ridhwanallah

import './CMCEnabled.sol';
import './ContractProvider.sol';
import './SafeMath.sol';

//PropertyBase
contract HouseDB is CMCEnabled {
  using SafeMath for uint256;

  function getHouse() private view returns (address){
    return ContractProvider(contractManager).contracts('house');
  }

  uint256 private count;

  struct House {
    string location;
    bytes32 cryptoKey;
  }

  //All house store in contract
  mapping(uint256 => House) private houseData;

  //Stores an array of assets owned by a given account
  mapping(address => uint256[]) private houseOf;

  //Stores an array of assets owned by a given account
  mapping(uint256 => address) private holderOf;

  //Stores the index of a house in the `ownerOf` array of its owner
  mapping(uint256 => uint256) private indexOfHouse;

  modifier onlyHouseContract() {
    require(msg.sender == getHouse(), "Invalid Contract House");
    _;
  }

  function getHolderOf(uint256 _propertyId) public view onlyHouseContract returns(address) {
    return holderOf[_propertyId];
  }

  function getCount() public view onlyHouseContract returns(uint256) {
    return count;
  }

  function getHouseOf(address _owner) public view onlyHouseContract returns(uint256[] memory) {
    return houseOf[_owner];
  }

  function getHouseData(uint256 _propertyId) public view onlyHouseContract returns(string memory, bytes32) {
    return(houseData[_propertyId].location, houseData[_propertyId].cryptoKey);
  }

  //Internal Setter
  function setHouseData(uint256 _propertyId, string memory _location, bytes32 _cryptoKey) public onlyHouseContract {
    houseData[_propertyId].location = _location;
    houseData[_propertyId].cryptoKey = _cryptoKey;
  }

  function addTo(address _to, uint256 _propertyId) public onlyHouseContract {
    holderOf[_propertyId] = _to;

    uint256 length = houseOf[_to].length;

    houseOf[_to].push(_propertyId);

    indexOfHouse[_propertyId] = length;

    count++;
  }

  function removeFrom(address _from, uint256 _propertyId) public onlyHouseContract {
    uint256 houseIndex = indexOfHouse[_propertyId];
    uint256 lastHouseIndex = houseOf[_from].length.sub(1);
    uint256 lastHouseId = houseOf[_from][lastHouseIndex];

    holderOf[_propertyId] = address(0x0);

    // Insert the last house into the position previously occupied by the asset to be removed
    houseOf[_from][houseIndex] = lastHouseId;

    // Resize the array
    houseOf[_from][lastHouseIndex] = 0;
    houseOf[_from].length--;

    // Remove the array if no more assets are owned to prevent pollution
    if (houseOf[_from].length == 0) {
      delete houseOf[_from];
    }

    // Update the index of positions for the asset
    indexOfHouse[_propertyId] = 0;
    indexOfHouse[lastHouseIndex] = houseIndex;
    count.sub(1);
  }
}
