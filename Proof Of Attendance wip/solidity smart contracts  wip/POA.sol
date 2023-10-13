// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
pragma experimental ABIEncoderV2;

import "./nft.sol";
import "./oracle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract POA is Ownable {
    address admin;
    address public claimant;
    address[] public claimants;
    address eventOrganiser;
    address[] eventOrganisers;
    ATT public nftContract;
    OracleContract public oracleContract;

    constructor(string memory nftName, string memory nftSymbol, address payable initialOwner, address payable oracleAddress) Ownable(initialOwner) {
        admin = msg.sender;

        // Deploy the ATT contract with the desired name and symbol
        nftContract = new ATT(nftName, nftSymbol);

        // Set the NFT contract address
        setConfig("nftAddress", address(nftContract));

        // Set the oracle contract address
        oracleContract = OracleContract(oracleAddress);
        setConfig("oracleAddress", oracleAddress);
    }

    struct Event {
        string eventName;
        string eventDate;
        string eventTime;
        string location;
        string tag;
    }

    struct Claim {
        string twitterName;
        string eventName;
        string eventDate;
        string eventTime;
        string location;
        string tag;
    }

    mapping(string => Event) public events;
    mapping(string => Claim) public claims;
    mapping(string => address) private configurations;

    function setConfig(string memory key, address value) private {
        configurations[key] = value;
    }

    function getConfig(string memory key) public view returns (address) {
        return configurations[key];
    }

    function Step1_addClaim(
        string memory twitterName,
        string memory eventName,
        string memory eventDate,
        string memory eventTime,
        string memory location
    ) public {
        claims[twitterName] = Claim(twitterName, eventName, eventDate, eventTime, location, "");
        claimant = msg.sender;
        claimants.push(msg.sender);
    }

    function Step2_ClaimRequestInitiate(string memory twitterName) public {
        require(claimant == msg.sender, "Only claimant can initiate their claim");
        oracleContract.updateTwitterTag(claims[twitterName].twitterName);
    }

    function viewClaim(string memory twitterName) public view returns (Claim memory) {
        require(claimant == msg.sender, "Only claimant can view their claim");
        return claims[twitterName];
    }

    function Step1_addEvent(
        string memory eventName,
        string memory eventDate,
        string memory eventTime,
        string memory location,
        string memory tag
    ) public {
        events[eventName] = Event(eventName, eventDate, eventTime, location, tag);
        eventOrganiser = msg.sender;
        eventOrganisers.push(msg.sender);
    }

    function viewEvent(string memory eventName) public view returns (Event memory) {
        require(eventOrganiser == msg.sender, "Only event organiser can view Events");
        return events[eventName];
    }

    function issueNft(address nftContractAddress, address _to) private {
        require(claimant == msg.sender, "Only claimant can issue their own POA NFT");
        ATT nftContract = ATT(payable(nftContractAddress));
        nftContract.safeMint(payable(_to));
    }

    function Step3_issuePOA() public {
        require(claimant == msg.sender, "Only claimant can issue their own POA NFT");
        // Consider adding error handling for this function
    }

    function Step4_issuePOA(string memory twitterName, string memory eventName) public {
        require(claimant == msg.sender, "Only claimant can issue their own POA NFT");
        bool tagsMatch =
            (keccak256(abi.encodePacked(events[eventName].tag)) == keccak256(abi.encodePacked(claims[twitterName].tag)));
        bool locationsMatch =
            (keccak256(abi.encodePacked(events[eventName].location)) ==
                keccak256(abi.encodePacked(claims[twitterName].location)));
        if (tagsMatch && locationsMatch) {
            address nftAddress = getConfig("nftAddress");
            issueNft(nftAddress, msg.sender);
        }
    }

    // Receive function to accept Ether
    receive() external payable {}
}
