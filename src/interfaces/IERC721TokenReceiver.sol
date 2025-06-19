// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data)
        external
        returns (bytes4);
}
