// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC721} from "./interfaces/IERC721.sol";
import {console} from "forge-std/console.sol";

contract SimpleNFT is IERC721 {
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public owners;
    mapping(uint256 => address) public tokenApprovedAdresses;
    mapping(address => mapping(address => bool)) public authorizedOperators;
    address public owner;
    uint256 public lastTokenId = 0;

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
        require(adr != address(0), "invalid address");
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
        require(_from == ownerOf(_tokenId));
        address tokenOwner = owners[_tokenId];

        require(tokenOwner != address(0), InvalidToken(_tokenId));

        require(
            msg.sender == tokenOwner || isApprovedForAll(tokenOwner, msg.sender) || getApproved(_tokenId) == msg.sender,
            NoAuthorizationOnToken(_tokenId, msg.sender)
        );

        owners[_tokenId] = _to;
        balances[_to]++;
        balances[_from]--;
        tokenApprovedAdresses[_tokenId] = address(0);

        emit Transfer(_from, _to, _tokenId);
        string memory key = string(abi.encodePacked("Transfer from ", _from, " to ", _to));
        console.log(key);
    }
}
