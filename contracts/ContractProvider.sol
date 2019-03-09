pragma solidity <=0.5.0;
// Interface for getting contracts from CMC

contract ContractProvider {
    function owner() public pure returns (address) {}
    function contracts(bytes32) public pure returns (address) {}
}
