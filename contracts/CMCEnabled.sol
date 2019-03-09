pragma solidity <=0.5.0;
//Author: Fadhlan Ridhwanallah

//Base contract for contracts that are used in a smart property system.
contract CMCEnabled{
  address contractManager;

  function setContractManager(address _contractManager) external returns (bool){
    if(_contractManager != address(0x0) && msg.sender != _contractManager){
        return false;
    }

    contractManager = _contractManager;
    return true;
  }
}
