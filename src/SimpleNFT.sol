// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {IERC165} from "./interfaces/IERC165.sol";
import {IERC721Metadata} from "./interfaces/IERC721Metadata.sol";
import {IERC721TokenReceiver} from "./interfaces/IERC721TokenReceiver.sol";
import {IERC721Enumerable} from "./interfaces/IERC721Enumerable.sol";
import {IERC721} from "./interfaces/IERC721.sol";

contract SimpleNFT is IERC721, IERC165, IERC721Metadata, IERC721Enumerable {
    address public owner;
    address public pendingOwner;
    uint256 public lastTokenId = 0;
    uint256 public constant TOKEN_UNIT_COST = 1 gwei;
    uint256 public totalEthersCollected;
    uint256 public revealTimestamp;
    uint256 public withdrawTimestamp;
    bool public revealed;

    string private _name = "Simple NFT";
    string private _symbol = "$NFT";

    uint256[] private allTokens;
    string public baseUrl;

    mapping(address => uint256) public balances;
    mapping(uint256 => address) public owners;
    mapping(uint256 => address) public tokenApprovedAddresses;
    mapping(address => mapping(address => bool)) public authorizedOperators;
    mapping(address => uint256) public etherOwners;
    mapping(uint256 => uint256) private allTokensIndex;
    mapping(address => uint256[]) private ownedTokens;
    mapping(uint256 => uint256) private ownedTokensIndex;

    constructor() {
        owner = msg.sender;
        revealTimestamp = block.timestamp + 1 hours;
        withdrawTimestamp = revealTimestamp + 1 hours;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function mint() external onlyOwner {
        __mint(msg.sender);
    }

    function mint(address receiver) external onlyOwner {
        __mint(receiver);
    }

    //Others will use this function to mint
    function mintSimpleNFT() external payable {
        require(msg.value >= TOKEN_UNIT_COST, InsufficientAmountOrNotMultipleOfTokenPrice(msg.value, TOKEN_UNIT_COST));
        uint256 numberOfTokensPurchased = msg.value / TOKEN_UNIT_COST;

        unchecked {
            for (uint256 i = 1; i <= numberOfTokensPurchased; i++) {
                __mint(msg.sender);
            }
        }

        totalEthersCollected += msg.value;
    }

    function __mint(address receiver) private {
        lastTokenId++;

        owners[lastTokenId] = receiver;
        balances[receiver]++;

        allTokens.push(lastTokenId);
        allTokensIndex[lastTokenId] = allTokens.length - 1;

        ownedTokens[receiver].push(lastTokenId);
        ownedTokensIndex[lastTokenId] = ownedTokens[receiver].length - 1;

        emit Transfer(address(0), receiver, lastTokenId);
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
        tokenApprovedAddresses[_tokenId] = _approved;
        emit Approval(ownerOf(_tokenId), _approved, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        return tokenApprovedAddresses[_tokenId];
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
        tokenApprovedAddresses[_tokenId] = address(0);

        _removeTokenFromOwnerEnumeration(_from, _tokenId);
        _addTokenToOwnerEnumeration(_to, _tokenId);

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
        tokenApprovedAddresses[_tokenId] = address(0);

        _removeTokenFromOwnerEnumeration(_from, _tokenId);
        _addTokenToOwnerEnumeration(_to, _tokenId);

        if (_to.code.length > 0) {
            (, bytes memory result) = _to.call(
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
        return interfaceID == type(IERC721).interfaceId || interfaceID == type(IERC721Metadata).interfaceId
            || interfaceID == type(IERC721Enumerable).interfaceId || interfaceID == type(IERC165).interfaceId;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        require(owners[_tokenId] != address(0), InvalidToken(_tokenId));

        if (!revealed) {
            return "Collection not revealed yet!";
        }

        return string(abi.encodePacked(baseUrl, "/", Strings.toString(_tokenId), ".json"));
    }

    function totalSupply() external view override returns (uint256) {
        return allTokens.length;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {
        require(_index < allTokens.length, NoTokenAtIndex(_index));
        return allTokens[_index];
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
        require(_index < ownedTokens[_owner].length, NoTokenAtIndex(_index));
        return ownedTokens[_owner][_index];
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastIndex = ownedTokens[from].length - 1;
        uint256 tokenIndex = ownedTokensIndex[tokenId];

        if (tokenIndex != lastIndex) {
            uint256 lastToken = ownedTokens[from][lastIndex];
            ownedTokens[from][tokenIndex] = lastToken;
            ownedTokensIndex[lastToken] = tokenIndex;
        }

        ownedTokens[from].pop();
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        ownedTokens[to].push(tokenId);
        ownedTokensIndex[tokenId] = ownedTokens[to].length - 1;
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= totalEthersCollected, "Not enough balance");
        require(revealed && block.timestamp >= withdrawTimestamp, "Too early to withdraw");
        totalEthersCollected -= amount;
        (bool success,) = owner.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        pendingOwner = _newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == pendingOwner, "Not pending owner");
        owner = pendingOwner;
        pendingOwner = address(0);
    }

    function reveal(string calldata url) external onlyOwner {
        withdrawTimestamp = revealTimestamp + 1 hours;
        require(block.timestamp >= revealTimestamp, "Too early to reveal");
        revealed = true;
    }
}
