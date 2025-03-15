// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

contract SimpleNFT is IERC721 {
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public owners;
    mapping(uint256 => address) public tokenApprovedAdresses;
    mapping(address => mapping(address => bool)) public authorizedOperators;
    address public  owner;
    uint256 public lastTokenId = 0;

    error NoAuthorizationOnToken(uint256 tokenId, address sender);
    error InvalidToken(uint256 token);
    error InvalidAddress(address adr);

    constructor() {
        owner = msg.sender;
    }

    function mint() public {
        require(msg.sender == owner);
        lastTokenId++;

        owners[lastTokenId] = owner;
        balances[owner]++;
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
        require(adr != address(0), 'invalid address');
        _;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), InvalidAddress(_owner));
        return balances[_owner];
    }

    function approve(address _approved, uint256 _tokenId) onlyOwnerAndAuthorizedOperator(_tokenId) external payable {
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

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) onlyValidAddress(_to) external payable {
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
    }
}