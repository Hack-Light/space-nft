/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { ERC721Enumerable, ERC721 } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

import { DataTypes } from "../libraries/types/DataTypes.sol";
import { JupiterSVG } from "../libraries/logic/svg/JupiterSVG.sol";
import { TypeCast } from "../libraries/utils/TypeCast.sol";
import { ColorGen } from "../libraries/utils/ColorGen.sol";

error Jupiter__NotMinted();
error Jupiter__InvalidMintFee();
error Jupiter__TransferFailed();
error Jupiter__ZeroAddress();
error Jupiter__InvalidFeeCollector();
error Jupiter__NotOwner();

contract Jupiter is ERC721Enumerable, Ownable {
	using TypeCast for bytes;
	using Counters for Counters.Counter;

	event FeeCollectorChanged(address oldFeeCollector, address newFeeCollector);

	uint256 constant MINT_FEE = 0.01 ether;
	address s_feeCollector;
	Counters.Counter private s_tokenIds;

	mapping(uint256 jupiterId => DataTypes.Jupiter jupiter) private s_attributes;

	constructor(address feeCollector) ERC721("Jupiter", "Jupiter") {
		s_feeCollector = feeCollector;
	}

	function mint() public payable returns (uint256) {
		if (msg.value < MINT_FEE) revert Jupiter__InvalidMintFee();

		s_tokenIds.increment();

		uint256 tokenId = s_tokenIds.current();
		_mint(msg.sender, tokenId);

		string[] memory colors = new string[](5); // Declare as dynamic array

		// generate random cloud and button color
		for (uint256 i = 0; i < 5; i++) {
			colors[i] = ColorGen.RGB(bytes32(i));
		}

		// generate random color
		s_attributes[tokenId] = DataTypes.Jupiter({
			color1: colors[0],
			color2: colors[1],
			color3: colors[2],
			color4: colors[3],
			color5: colors[4]
		});

		// transfer mint fee
		(bool success, ) = payable(owner()).call{ value: msg.value }("");
		if (!success) revert Jupiter__TransferFailed();

		return tokenId;
	}

	function tokenURI(
		uint256 tokenId
	) public view override returns (string memory) {
		if (!_exists(tokenId)) revert Jupiter__NotMinted();

		DataTypes.Jupiter memory jupiter = s_attributes[tokenId];

		return JupiterSVG.tokenURI(jupiter, tokenId);
	}

	function renderTokenById(
		uint256 tokenId
	) public view returns (string memory) {
		DataTypes.Jupiter memory jupiter = s_attributes[tokenId];

		return JupiterSVG.renderTokenById(jupiter);
	}

	function setFeeCollector(address newFeeCollector) public onlyOwner {
		address oldFeeCollector = s_feeCollector;
		if (newFeeCollector == address(0)) revert Jupiter__ZeroAddress();
		if (newFeeCollector == oldFeeCollector)
			revert Jupiter__InvalidFeeCollector();

		s_feeCollector = newFeeCollector;

		emit FeeCollectorChanged(oldFeeCollector, newFeeCollector);
	}

	function getFeeCollector() public view returns (address) {
		return s_feeCollector;
	}

	function getAttributes(
		uint256 tokenId
	) public view returns (DataTypes.Jupiter memory) {
		return s_attributes[tokenId];
	}
}
