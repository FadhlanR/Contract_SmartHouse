pragma solidity <=0.5.0;
//Author: Fadhlan Ridhwanallah

import './SmartHouseEnabled.sol';
import './HouseDB.sol';
import './ERC721.sol';
import './ContractProvider.sol';

//Application Logic
contract House is SmartHouseEnabled, ERC721 {
  function getHouseDB() private view returns (address){
    return ContractProvider(contractManager).contracts('housedb');
  }

  //Modifier and Validate Function
  modifier onlySmartHouse() {
    require(isSmartHouse(), "Invalid Smart House Contract");
    _;
  }

  //Getter
  function totalSupply() external view onlySmartHouse returns (uint256) {
    return HouseDB(getHouseDB()).getCount();
  }

  function _ownerOf (uint256 _propertyId) private view returns (address) {
    return HouseDB(getHouseDB()).getHolderOf(_propertyId);
  }

  function ownerOf(uint256 _propertyId) external view onlySmartHouse returns (address) {
    return _ownerOf(_propertyId);
  }

  function balanceOf(address _owner) external view onlySmartHouse returns (uint256) {
    return HouseDB(getHouseDB()).getHouseOf(_owner).length;
  }

  function getHouseData(uint256 _propertyId) external view onlySmartHouse returns (string memory, address) {
    string memory location;
    bytes32 cryptoKey;

    (location, cryptoKey) = HouseDB(getHouseDB()).getHouseData(_propertyId);
    return (location, _ownerOf(_propertyId));
  }

  function getCryptoKey(uint256 _propertyId) external view onlySmartHouse returns (bytes32) {
    string memory location;
    bytes32 cryptoKey;

    (location, cryptoKey) = HouseDB(getHouseDB()).getHouseData(_propertyId);
    return (cryptoKey);
  }

  //External setter
  function  houseRegistration(uint256 _propertyId, string calldata _location, address _beneficiary) external onlySmartHouse {
    require(_ownerOf(_propertyId) == address(0x0), "House has owner");

    bytes32 cryptoKey = keccak256(abi.encodePacked(_beneficiary, _propertyId));

    HouseDB(getHouseDB()).setHouseData(_propertyId, _location, cryptoKey);
    HouseDB(getHouseDB()).addTo(_beneficiary, _propertyId);

    emit Transfer(address(0x0), _beneficiary, _propertyId);
  }

  function transferHouse(address _from, address _to, uint256 _propertyId)
    onlySmartHouse
    external
  {
    HouseDB(getHouseDB()).removeFrom(_from, _propertyId);
    HouseDB(getHouseDB()).addTo(_to, _propertyId);

    emit Transfer(_from, _to, _propertyId);
  }
}
