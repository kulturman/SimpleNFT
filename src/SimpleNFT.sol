// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "./interfaces/ERC165.sol";
import {IERC721TokenReceiver} from "./interfaces/IERC721TokenReceiver.sol";
import {IERC721} from "./interfaces/IERC721.sol";
import {console} from "forge-std/console.sol";

contract SimpleNFT is IERC721, ERC165 {
    address public owner;
    uint256 public lastTokenId = 0;

    mapping(address => uint256) public balances;
    mapping(uint256 => address) public owners;
    mapping(uint256 => address) public tokenApprovedAdresses;
    mapping(address => mapping(address => bool)) public authorizedOperators;

    constructor() {
        owner = msg.sender;
    }

    function mint() public {
        require(msg.sender == owner);
        lastTokenId++;

        owners[lastTokenId] = owner;
        balances[owner]++;
        emit Transfer(address(0), owner, lastTokenId);
    }

    modifier onlyOwnerAndAuthorizedOperator(uint256 tokenId) {
        address tokenOwner = owners[tokenId];

        require(
            msg.sender == tokenOwner || isApprovedForAll(tokenOwner, msg.sender),
            NoAuthorizationOnToken(tokenId, msg.sender)
        );
        _;
    }

    modifier onlyValidAddress(address adr) {
        //Change later
        require(adr != address(0), "Invalid address");
        _;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), InvalidAddress());
        return balances[_owner];
    }

    function approve(address _approved, uint256 _tokenId) external payable onlyOwnerAndAuthorizedOperator(_tokenId) {
        tokenApprovedAdresses[_tokenId] = _approved;
        emit Approval(ownerOf(_tokenId), _approved, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        return tokenApprovedAdresses[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return authorizedOperators[_owner][_operator];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address tokenOwner = owners[_tokenId];

        require(tokenOwner != address(0), InvalidToken(_tokenId));

        return owners[_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        emit ApprovalForAll(msg.sender, _operator, _approved);
        authorizedOperators[msg.sender][_operator] = _approved;
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable onlyValidAddress(_to) {
        _checkIfSenderCanSendToken(_from, _to, _tokenId);

        owners[_tokenId] = _to;
        balances[_to]++;
        balances[_from]--;
        tokenApprovedAdresses[_tokenId] = address(0);

        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data)
        external
        payable
        onlyValidAddress(_from)
        onlyValidAddress(_to)
    {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        _safeTransferFrom(_from, _to, _tokenId, bytes(""));
    }

    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) private {
        _checkIfSenderCanSendToken(_from, _to, _tokenId);

        owners[_tokenId] = _to;
        balances[_to]++;
        balances[_from]--;
        tokenApprovedAdresses[_tokenId] = address(0);

        if (_to.code.length > 0) {
            (bool success, bytes memory result) = _to.call(
                abi.encodeWithSignature(
                    "onERC721Received(address,address,uint256,bytes)", msg.sender, _from, _tokenId, data
                )
            );

            require(bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) == bytes4(result));
        }

        emit Transfer(_from, _to, _tokenId);
    }

    function _checkIfSenderCanSendToken(address from, address to, uint256 tokenId) private {
        require(from == ownerOf(tokenId), NoAuthorizationOnToken(tokenId, msg.sender));
        address tokenOwner = owners[tokenId];

        require(tokenOwner != address(0), InvalidToken(tokenId));

        require(
            msg.sender == tokenOwner || isApprovedForAll(tokenOwner, msg.sender) || getApproved(tokenId) == msg.sender,
            NoAuthorizationOnToken(tokenId, msg.sender)
        );
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        return type(IERC721).interfaceId == interfaceID;
    }
}
