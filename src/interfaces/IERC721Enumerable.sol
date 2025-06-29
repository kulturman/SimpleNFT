// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

interface IERC721Enumerable {
    error NoTokenAtIndex(uint256);

    function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 _index) external view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}
