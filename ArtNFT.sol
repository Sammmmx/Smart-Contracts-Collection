//SPDX-License_Identifier : MIT

pragma solidity ^0.8.23;

contract ArtNFT {

    string public Token = "ArtNFT";
    string public TokenSymbol = "ART";
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct details {
        address owner;
        string URI;
        address allowance;
    }
    mapping(uint256 => details) public Tokens;

    uint256 Id_count = 1;

    modifier checkTokenOwner(uint256 tokenId) {
        require(Tokens[tokenId].owner == msg.sender, "Its not your token");
        _;
    }

    function mint(address to, string memory URI) public {
        require(msg.sender == owner, "Only Owner can access");
        Tokens[Id_count] = details(to, URI, address(0));
        Id_count++;
    }

    function transfer(address to, uint256 tokenID) public 
    checkTokenOwner(tokenID) {
        Tokens[tokenID].owner == to;
        Tokens[tokenID].allowance = address(0);
    }

    function approve(address to, uint256 tokenID) public 
    checkTokenOwner(tokenID) {
        Tokens[tokenID].allowance = to;
    }

    function transferFrom(address from, address to, uint256 tokenID) public {
        require(Tokens[tokenID].allowance == msg.sender || Tokens[tokenID].owner == msg.sender, "You are not authorized");
        require(Tokens[tokenID].owner == from, "Incorrect address");
        Tokens[tokenID].owner == to;
    }

    function ownerOf(uint256 tokenID) public view returns(address) {
        return Tokens[tokenID].owner;
    }

    function tokenURI(uint256 tokenID) public view returns(string memory) {
        return Tokens[tokenID].URI;
    }
}