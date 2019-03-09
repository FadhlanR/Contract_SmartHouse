pragma solidity <=0.5.0;
//Author: Fadhlan Ridhwanallah

contract ERC721 {
  // Required methods
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);

    // Events
    event Transfer(address from, address to, uint256 tokenId);
}
