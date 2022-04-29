// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

// Start by importing Openzeppelin contracts

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol"; // Importing a library to work with base64 conversion

// We want to create an ERC721 standard contract, so let's inherit it from Openzeppelin

contract BlackSquareNFT is ERC721URIStorage {

  // Counters from OZ is used to keep track of NFT ID.
  // Keyword 'using' means that we use library Counters

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIDs;

  // Initialize string variables

  string baseSVG = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";  // Code that creates a black square
  string[] firstWord = ["Simple", "Effective", "Lazy", "Destructive", "Treacherous", "Gigantic", "Formal", "Petty", "Goofy", "Thick", "Rebel", "Literate", "Wild", "Ancient", "Demonic"]; // Arrays of words for our three word generator
  string[] secondWord = ["Eye", "Pirate", "Cucumber", "Manatee", "Pizza", "Mom", "Dealer", "Beer", "Committee", "Inspector", "Soup", "Customer", "Uncle", "Gene", "Salad", "Funeral"];
  string[] thirdWord = ["Conquers", "Helps", "Advises", "Runs", "Hides", "Laughs", "Endorses", "Rubs", "Manipulates", "Interferes", "Revives", "Delivers", "Protects", "Spoils", "Dominates"];

  // Pass the name and symbol of our NFTs

  constructor() ERC721 ("BlackSquareNFT", "SQUARE") {
    console.log("We're online!");
  }

  // Picking random words from array is a difficult problem without Chainlink, and for now we'll use crutches

  function chooseFirstWord(uint256 tokenId) public view returns (string memory) {
    uint256 randomNumber = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    randomNumber = randomNumber % firstWord.length; // Choose a number between 1 and the length of an array
    return firstWord[randomNumber];
  }

  function chooseSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 randomNumber = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    randomNumber = randomNumber % secondWord.length;
    return secondWord[randomNumber];
  }

  function chooseThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 randomNumber = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    randomNumber = randomNumber % thirdWord.length;
    return thirdWord[randomNumber];
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  // A function to create an NFTs
  function makeNFT () public {

    // Get current token ID, starting with 0
    uint256 newItemID = _tokenIDs.current();

    // Randomly grab words from all three arrays
    string memory first = chooseFirstWord(newItemID);
    string memory second = chooseSecondWord(newItemID);
    string memory third = chooseThirdWord(newItemID);
    string memory phrase = string(abi.encodePacked(first, second, third));

    // Combine everything together and finilize SVG code by adding closing "text" and "svg" tags
    string memory finalSVG = string(abi.encodePacked(baseSVG, first, second, third, "</text></svg>"));

    // Create and combine JSON metadata, and encode it in base64
    // Structure of writing JSON after "encodePacked" is better not to tinker with

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            // Give name to our NFT
            phrase,
            '", "description": "A black square with randomly generated phrase", "image": "data:image/svg+xml;base64,',
            // Way to decypher SVG image + encoded string containing finalSVG code
            Base64.encode(bytes(finalSVG)),
            '"}'


//            '{"name": "', phrase, // Give name to our NFT
//            '", "description": "A black square with randomly generated phrase", // Description of a collection
//            "image": "data:image/svg+xml;base64,', Base64.encode(bytes(finalSVG)), // Way to decypher SVG image + encoded string containing finalSVG code
//            '"}'
          )
        )
      )
    );

    string memory tokenURI = string(abi.encodePacked("data:application/json;base64,", json));

    console.log("\n--------------------");
    console.log(string(abi.encodePacked("https://nftpreview.0xdev.codes/?code=", tokenURI)));
    console.log("--------------------\n");

    // Mint the NFT
    _safeMint(msg.sender, newItemID);

    // Set NFT data

    _setTokenURI(newItemID, tokenURI);
    console.log("An NFT with ID %s has been minted to %s", newItemID, msg.sender);

    // Increment the _tokenIDs counter

    _tokenIDs.increment();
  }
}
