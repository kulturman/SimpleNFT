// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

interface IERC721Metadata { /* is ERC721 */
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 _tokenId) external view returns (string memory);
}
