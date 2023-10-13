// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "github.com/provable-things/ethereum-api/provableAPI.sol";

contract OracleContract is usingProvable {
    string public IPFSHash;
    string public twitterTag;
    address public owner;

    event LogNewProvableQuery(string description);
    event LogNewIPFSHash(string ipfsHash);
    event LogNewTwitterTag(string twitterTag);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(string memory _initialIPFSHash) {
        owner = msg.sender;
        IPFSHash = _initialIPFSHash;
    }

    ///Need a solution to implement call Key Management Service so keys are not stored in ipfs or in smart contract
    function setIPFSHash(string memory _newHash) public onlyOwner {
        IPFSHash = _newHash;
        emit LogNewIPFSHash(_newHash);
    }

    function updateTwitterTag(
        string memory _twitterTag
    )
        public 
        payable
        {
        provable_query("computation", [IPFSHash , _twitterTag]);
    }

    function __callback(bytes32 _myid, string memory _result) public {
        require(msg.sender == provable_cbAddress(), "Only Provable can call this function");
        twitterTag = _result;
        emit LogNewTwitterTag(_result);
    }

    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "Contract balance is zero");
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}