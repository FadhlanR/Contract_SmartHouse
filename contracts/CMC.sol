pragma solidity <=0.5.0;

//Author: Fadhlan Ridhwanallah
import "./CMCEnabled.sol";

//CMC from 5 type model
contract CMC {
  address public owner;

  // This is where we keep all the contracts.
  mapping (bytes32 => address) public contracts;

  modifier onlyOwner {
    require(msg.sender == owner, "Invalid owner"); // this ensures that only the owner can access the function
    _;
  }

  // Constructor
  constructor() public{
      owner = msg.sender;
  }

  event contractAdded(address indexed owner, bytes32 indexed _name, address _addr);
  event contractRemoved(address indexed owner, bytes32 indexed _name);
  event allContractRemoved(address indexed owner);

  // Add a new contract to Doug. This will overwrite an existing contract.
  function addContract(bytes32 _name, address _addr) external onlyOwner {
      CMCEnabled cmcEnabled = CMCEnabled(_addr);
      // Don't add the contract if this does not work.
      if(!cmcEnabled.setContractManager(address(this))) {
        revert("Add CMC Failed");
      }

      contracts[_name] = _addr;
      emit contractAdded(owner, _name, _addr);
  }
}
