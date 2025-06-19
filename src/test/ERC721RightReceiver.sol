// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC721TokenReceiver} from "../../lib/forge-std/src/interfaces/IERC721.sol";
import {console} from "../../lib/forge-std/src/console.sol";

contract ERC721RightReceiver is IERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data)
        external
        returns (bytes4)
    {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}
