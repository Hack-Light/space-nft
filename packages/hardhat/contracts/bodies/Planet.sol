/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { ERC721Enumerable, ERC721 } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

import { DataTypes } from "../libraries/types/DataTypes.sol";
import { PlanetSVG } from "../libraries/logic/svg/PlanetSVG.sol";
import { TypeCast } from "../libraries/utils/TypeCast.sol";
import { ColorGen } from "../libraries/utils/ColorGen.sol";

error Planet__NotMinted();
error Planet__AlreadyMinted();
error Planet__InvalidMintFee();
error Planet__TransferFailed();
error Planet__ZeroAddress();
error Planet__InvalidFeeCollector();
error Planet__NotOwner();

contract Planet is ERC721Enumerable, Ownable {
	using TypeCast for bytes;
	using Counters for Counters.Counter;

	event FeeCollectorChanged(address oldFeeCollector, address newFeeCollector);

	uint256 constant MINT_FEE = 0.01 ether;
	address s_feeCollector;
	Counters.Counter private s_tokenIds;

	mapping(uint256 planetId => DataTypes.Planet planet) private s_attributes;
	mapping(address => bool) private s_hasMinted;

	constructor(address feeCollector) ERC721("Planet", "Planet") {
		s_feeCollector = feeCollector;
	}

	function mint() public payable returns (uint256) {
		if (s_hasMinted[msg.sender]) revert Planet__AlreadyMinted();
		if (msg.value < MINT_FEE) revert Planet__InvalidMintFee();

		s_tokenIds.increment();

		uint256 tokenId = s_tokenIds.current();
		_mint(msg.sender, tokenId);

		string[] memory colors = new string[](2); // Declare as dynamic array

		// generate random cloud and button color
		for (uint256 i = 0; i < 2; i++) {
			colors[i] = ColorGen.RGB(bytes32(i));
		}

		// generate random color
		s_attributes[tokenId] = DataTypes.Planet({
			mainColor: colors[0],
			halfColor: colors[1]
		});

		s_hasMinted[msg.sender] = true;

		// transfer mint fee
		(bool success, ) = payable(owner()).call{ value: msg.value }("");
		if (!success) revert Planet__TransferFailed();

		return tokenId;
	}

	function tokenURI(
		uint256 tokenId
	) public view override returns (string memory) {
		if (!_exists(tokenId)) revert Planet__NotMinted();

		DataTypes.Planet memory planet = s_attributes[tokenId];

		return PlanetSVG.tokenURI(planet, tokenId);
	}

	function renderTokenById(
		uint256 tokenId
	) public view returns (string memory) {
		DataTypes.Planet memory planet = s_attributes[tokenId];

		return PlanetSVG.renderTokenById(planet);
	}

	function setFeeCollector(address newFeeCollector) public onlyOwner {
		address oldFeeCollector = s_feeCollector;
		if (newFeeCollector == address(0)) revert Planet__ZeroAddress();
		if (newFeeCollector == oldFeeCollector)
			revert Planet__InvalidFeeCollector();

		s_feeCollector = newFeeCollector;

		emit FeeCollectorChanged(oldFeeCollector, newFeeCollector);
	}

	function getFeeCollector() public view returns (address) {
		return s_feeCollector;
	}

	function getAttributes(
		uint256 tokenId
	) public view returns (DataTypes.Planet memory) {
		return s_attributes[tokenId];
	}
}
