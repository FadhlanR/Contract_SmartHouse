pragma solidity <=0.5.0;
//Author: Fadhlan Ridhwanallah

import './CMCEnabled.sol';
import './ContractProvider.sol';

//Application Logic
contract SmartHouseEnabled is CMCEnabled {
  function isSmartHouse() internal view returns (bool) {
    address smartHouse = ContractProvider(contractManager).contracts("smarthouse");
    return msg.sender == smartHouse;
  }
}
